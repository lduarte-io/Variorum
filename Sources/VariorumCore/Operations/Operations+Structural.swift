import Dependencies
import Foundation
import GRDB

// The structural operations (AppSpec §9, OverallModel §7): extract, divide
// (single-variant and multi-variant W), merge — plus poolDragCopy, the other
// lineage-minting gesture. All are reversible pointer moves, never
// destructive rewrites: sources survive or release to lineage; new blocks
// carry `derived_from` edges back to their ancestors.
//
// Offsets and spans are UTF-16 code units (TextKit 2's unit) and must land on
// grapheme-cluster boundaries — `BoundarySnapping` owns the convention. Cut
// seams are whitespace-trimmed (separators are re-created by the rendering
// join, never stored — the SegmentationRules doctrine).
extension Operations {
    // MARK: - The rendered variant (the shared answer to "which text?")

    /// The variant a block's live slot renders: the placement's chosen
    /// variant while it is live and active, else the block's default variant
    /// while it is live — the read-time fallback rule (AppSpec §7), matching
    /// `renderedLength`'s COALESCE semantics. Every structural op resolves
    /// its source text through this one helper.
    func renderedVariant(
        _ db: Database, block: Block, placement: ContainerBlock?
    ) throws -> Variant {
        if let chosenID = placement?.chosenVariantId,
           let chosen = try Variant.fetchOne(db, key: chosenID),
           chosen.blockId == block.id,  // a foreign chosen must never let an op rewrite another block's text
           chosen.deletedAt == nil, chosen.status == .active {
            return chosen
        }
        if let defaultID = block.defaultVariantId,
           let fallback = try Variant.fetchOne(db, key: defaultID),
           fallback.deletedAt == nil {
            return fallback
        }
        // Unreachable for a live block (I10 + default reassignment), kept as
        // a typed refusal rather than a crash for sync-race tolerance.
        throw OperationError.noRenderableVariant(blockID: block.id)
    }

    func renderedVariant(_ db: Database, blockID: String) throws -> Variant {
        let block = try liveBlock(db, blockID)
        return try renderedVariant(db, block: block, placement: try livePlacement(db, blockID: blockID))
    }

    // MARK: - Extract (source survives)

    public struct ExtractResult: Equatable, Sendable {
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
        public let edge: Edge
    }

    /// AppSpec §9: a boundary-adjacent prefix/suffix of the rendered
    /// variant's text leaves it to become a new adjacent block (before the
    /// source for a prefix, after it for a suffix) with a `derived_from`
    /// edge. The source keeps its identity and its entire fan untouched — so
    /// extracting from a *fanned* block edits only the rendered variant, and
    /// the other variants keep their own copy of the span (documented
    /// behavior, review #10; the editor may hint). A middle span refuses:
    /// that's a divide. `span` is UTF-16 offsets into the rendered text.
    /// Boundary discipline (sentence/paragraph snapping, OverallModel §7) is
    /// deliberately the editor's contract — the operation checks
    /// well-formedness only (bounds, grapheme alignment, edge adjacency,
    /// surviving remainder), never that the span sits on a sentence mark.
    @discardableResult
    public func extract(_ blockID: String, span: Range<Int>) throws -> ExtractResult {
        let (result, sourcePreImage): (ExtractResult, TextPreImage) =
            try database.write { db in
                let context = try placedContext(db, blockID: blockID)
                try ensureEditable(context.rendered)
                let text = context.rendered.workingText
                // The span's shape, and its GRAPHEME ALIGNMENT — the halves
                // below are taken by UTF-16 offset now (13f W24), so the
                // range's own validation is what keeps a cut off the middle
                // of an emoji. Kept as a check, not a binding.
                guard let kind = BoundarySnapping.extractableSpan(span, in: text),
                      BoundarySnapping.graphemeRange(span, in: text) != nil
                else { throw OperationError.spanNotExtractable(blockID: blockID) }

                // 13f W24 (her round-12 ruling: WIDEN A11 TO EXTRACT).
                // Extract's seam is a seam like any other, so it consults the
                // ONE seam-trim brain instead of trimming both sides away:
                // **the piece BEFORE the seam owns the blank line**, exactly
                // as a divide's first half does. The span's inner edge IS the
                // cut, so `seamTrimmedHalves` expresses extract with no second
                // implementation — and its guards are already satisfied here
                // (`extractableSpan` proves content on the far side, so the
                // cut is interior; `graphemeRange` proves alignment).
                //
                // The OUTER edges keep their standing treatment — the span
                // trims both of its own ends as before, the source's far edge
                // is untouched as before — so the only byte that moves is the
                // seam's, which is the ruling.
                let spanText: String
                let remainder: String
                let insertAt: InsertPosition
                switch kind {
                case .prefix:
                    guard let halves = BoundarySnapping.seamTrimmedHalves(
                        text, cutAtUTF16: span.upperBound)
                    else { throw OperationError.spanNotExtractable(blockID: blockID) }
                    spanText = BoundarySnapping.trimLeading(Substring(halves.first))
                    remainder = halves.second
                    insertAt = .before(blockID)
                case .suffix:
                    guard let halves = BoundarySnapping.seamTrimmedHalves(
                        text, cutAtUTF16: span.lowerBound)
                    else { throw OperationError.spanNotExtractable(blockID: blockID) }
                    remainder = halves.first
                    spanText = BoundarySnapping.trimTrailing(Substring(halves.second))
                    insertAt = .after(blockID)
                }

                let now = date.now
                var source = context.rendered
                source.workingText = remainder
                source.updatedAt = now
                try source.update(db)

                let minted = try mintBlock(
                    db, text: spanText, in: context.container.id, at: insertAt,
                    presentation: context.block.presentation, now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "extract", now: now)
                // Phase 13 (A2) travel: the source keeps its comments; the
                // minted half gets COPIES (the ratified duplicate-onto-
                // successors direction). The undo inverse needs nothing new
                // — tombstoning the minted block cascades to its copies.
                try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
                try registerTextChange(
                    db, blockID: blockID, charDelta: text.count - remainder.count,
                    forceMajorRevision: false, now: now)

                return (
                    ExtractResult(
                        block: minted.block, variant: minted.variant,
                        placement: minted.placement, edge: edge),
                    TextPreImage(variantID: context.rendered.id, text: text, postOpText: remainder)
                )
            }
        undoStack?.register(
            label: "Extract",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [sourcePreImage],
                    tombstoningBlocks: [.init(result.block.id, [result.variant])],
                    revivingPlacementRows: [])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [sourcePreImage],
                    untombstoningBlocks: [.init(result.block.id, [result.variant])],
                    releasingPlacementRows: [])
            },
            // A12: the source buffer this undo would restore.
            insuring: [sourcePreImage])
        return result
    }

    // MARK: - Divide, single-variant (the everyday in-place cut)

    public struct DivideResult: Equatable, Sendable {
        /// The freshly minted second half; the source keeps its identity as
        /// the first half.
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
        public let edge: Edge
    }

    /// AppSpec §9, the ~95% case: the source is consumed in place — it keeps
    /// its identity as the first half (lossless, no fan to desync) and a
    /// fresh block C is minted for the second half, placed immediately
    /// after, with a `derived_from`/'divide' edge. Requires exactly one live
    /// active variant — a fanned block refuses toward the W ceremony
    /// (`divideW`). `cut` is a UTF-16 offset into the rendered text; the
    /// halves are whitespace-trimmed at the seam. Boundary discipline is
    /// deliberately the editor's contract — `BoundarySnapping.settle`, the one
    /// snap brain every shipped door consults (S4-22's ruled cut rule: word
    /// edges are free, sentence ends and newlines pull a little); the
    /// operation checks well-formedness only (bounds, grapheme alignment,
    /// non-empty halves), never that the cut sits on a sentence mark.
    /// *(17f/P45: this line used to name a `snap` function with no production
    /// callers — a contract no door enforced.)*
    /// Note the documented
    /// restoreCommit behavior: a commit predating this cut still holds the
    /// full text, and restoring it resurrects both halves into the source's
    /// buffer while C sits next door (AppSpec §9; the editor warns, Phase 7).
    @discardableResult
    public func divide(_ blockID: String, cut: Int) throws -> DivideResult {
        let (result, sourcePreImage): (DivideResult, TextPreImage) =
            try database.write { db in try divideRows(db, blockID: blockID, cut: cut) }
        undoStack?.register(
            label: "Divide",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [sourcePreImage],
                    tombstoningBlocks: [.init(result.block.id, [result.variant])],
                    revivingPlacementRows: [])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [sourcePreImage],
                    untombstoningBlocks: [.init(result.block.id, [result.variant])],
                    releasingPlacementRows: [])
            },
            // A12: the source buffer this undo would restore.
            insuring: [sourcePreImage])
        return result
    }

    /// `divide`'s ROWS, inside a caller's transaction (18c batch 3 — the 3C
    /// parity refactor). `divide` above is this plus its undo registration;
    /// `splitBlockAtNewlines` composes several of these into ONE transaction
    /// and ONE undo entry, which is only possible if the body is separable
    /// from the `database.write` that wraps it. Behaviour is byte-unchanged —
    /// the whole body moved, nothing in it did.
    func divideRows(
        _ db: Database, blockID: String, cut: Int
    ) throws -> (result: DivideResult, preImage: TextPreImage) {
        let context = try placedContext(db, blockID: blockID)
        let activeVariants = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                """,
            arguments: [blockID]) ?? 0
        guard activeVariants == 1 else {
            throw OperationError.fannedBlock(id: blockID)
        }
        try ensureEditable(context.rendered)

        let text = context.rendered.workingText
        guard let halves = BoundarySnapping.seamTrimmedHalves(text, cutAtUTF16: cut),
              !halves.first.isEmpty, !halves.second.isEmpty
        else { throw OperationError.invalidCut(variantID: context.rendered.id, cut: cut) }

        let now = date.now
        var source = context.rendered
        source.workingText = halves.first
        source.updatedAt = now
        try source.update(db)

        let minted = try mintBlock(
            db, text: halves.second, in: context.container.id,
            at: .after(blockID),
            presentation: context.block.presentation, now: now)
        let edge = try insertLineageEdge(
            db, from: minted.block.id, to: blockID, originOp: "divide", now: now)
        // Phase 13 (A2) travel: both halves were the block's content
        // — A keeps its comments, C gets copies.
        try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
        try registerTextChange(
            db, blockID: blockID, charDelta: text.count - halves.first.count,
            forceMajorRevision: false, now: now)

        return (
            DivideResult(
                block: minted.block, variant: minted.variant,
                placement: minted.placement, edge: edge),
            TextPreImage(
                variantID: context.rendered.id, text: text, postOpText: halves.first)
        )
    }

    // MARK: - Divide, multi-variant (W — the one ceremony)

    /// One successor block of a W divide: its half-fan in marked order.
    public struct FanHalf: Equatable, Sendable {
        public let block: Block
        /// One variant per CONTRIBUTING source variant, in fan order. A
        /// take parked at its far end (S4-22 parking) contributes to only
        /// one successor, so the two halves' fans may differ in size.
        public let variants: [Variant]
        /// The marked source variant each entry of `variants` was cut (or
        /// parked whole) from — aligned index-for-index with `variants`.
        public let sourceVariantIDs: [String]
        public let placement: ContainerBlock
        public let edge: Edge
    }

    public struct DivideWResult: Equatable, Sendable {
        /// B — the first halves (plus takes parked whole at their END).
        public let first: FanHalf
        /// C — the second halves (plus takes parked whole at their START).
        public let second: FanHalf
        /// ALL marked source variants in fan order. A split take appears in
        /// both halves' `sourceVariantIDs`; a parked take in exactly one —
        /// the per-half arrays carry the correspondence since parking
        /// (13b Stage 4) made the two fans independently sized.
        public let markedSourceIDs: [String]
        /// A's released placement row (the pre-image undo flips back live).
        public let releasedPlacementID: String
    }

    /// AppSpec §9, W resolution: marked variants carry the cut through —
    /// B's fan is their first halves, C's fan their second halves, relative
    /// order preserved (enabling first-half-of-attempt-1 with
    /// second-half-of-attempt-3 via `chooseVariant`). The source block A is
    /// **preserved whole**: its placement is released (tombstoned — A stays
    /// live and unplaced, the unplaced-blocks population), every variant and
    /// commit untouched, unmarked variants staying on A as lineage.
    /// Reversible by re-pointing at A (`placeBlock`). B/C defaults are the
    /// halves of A's rendered variant when it contributes to that successor
    /// (also that placement's chosen), else that side's first contributing
    /// take (chosen left NULL). Cuts are per-variant UTF-16 offsets, seam-
    /// trimmed (well-formedness checked; boundary snapping is the editor's,
    /// as in `divide`). Marked variants may be locked — their buffers are
    /// copied, not edited. An unfanned block is accepted too, deliberately:
    /// W on a single variant is a divide with release-A semantics instead
    /// of in-place — the editor picks the gesture, the op doesn't
    /// second-guess.
    ///
    /// **Parking (13b Stage 4, S4-22 ruling 2):** a cut at a take's very
    /// END means the take doesn't split — ALL of it rides into B, verbatim
    /// (no seam exists, so nothing is trimmed; trailing newlines are
    /// meaningful stored spacing), and C's fan simply omits it. A cut at
    /// the very START is the mirror: the whole take rides into C. Every
    /// non-empty take therefore always has a legal placement — the single-
    /// sentence dead end is gone in both directions. Two guards ride the
    /// semantics: an EMPTY take's cut refuses (`invalidCut` — 0 and the
    /// end coincide, so which block gets the blank would be a guess), and
    /// every-take-parked-at-one-end refuses (`divideSideWouldBeEmpty` —
    /// the other successor would violate I10 at birth). **A parked take
    /// KEEPS ITS NAME** (18c batch 1): a whole-take ride carries its label
    /// exactly as `divideDuplicating`'s duplicates and `mergeCeremony`'s
    /// carries do — the same rule, stated once for every ride in §9. The
    /// CUT HALVES stay unlabeled and parentless, as they always have: they
    /// are fresh texts, not rides.
    ///
    /// **`displayedVariantID` — who anchors each side's chosen/default**
    /// (18c batch 1, the keep-on-top default; QUESTIONS #91, PROVISIONAL).
    /// By default the anchor is A's RENDERED take, which is right for the
    /// ceremony — its sheet opens on what the block shows. A caller that
    /// knows the author was working in a DIFFERENT take (the Takes board's
    /// caret sits in any take's pane; the phone's peek displays a take that
    /// is not the chosen one) names it here, and each successor then shows
    /// that take's contribution where it has one — which is what today's
    /// fanned default (`divideDuplicating`) has always guaranteed, and what
    /// keeps a keep-on-top divide from leaving B rendering another take
    /// whole beside C's tail of the divided one. Nil, or an id that is not
    /// among `cuts`, keeps `context.rendered` byte-for-byte.
    @discardableResult
    public func divideW(
        _ blockID: String, cuts: [String: Int], displayedVariantID: String? = nil
    ) throws -> DivideWResult {
        let result: DivideWResult = try database.write { db in
            try divideWRows(
                db, blockID: blockID, cuts: cuts, displayedVariantID: displayedVariantID)
        }
        // The label is the summoned door's own name (U-4, 2026-09-06; renamed
        // at the 18f ladder, R1-9): every OTHER caller wraps this op in a
        // compound labelled "Divide", so this is what the Edit menu reads
        // after "Divide choosing takes…" alone.
        undoStack?.register(
            label: "Divide choosing takes",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [],
                    tombstoningBlocks: [
                        .init(result.first.block.id, result.first.variants),
                        .init(result.second.block.id, result.second.variants),
                    ],
                    revivingPlacementRows: [result.releasedPlacementID])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [],
                    untombstoningBlocks: [
                        .init(result.first.block.id, result.first.variants),
                        .init(result.second.block.id, result.second.variants),
                    ],
                    releasingPlacementRows: [result.releasedPlacementID])
            })
        return result
    }

    /// `divideW`'s ROWS, inside a caller's transaction (18c batch 3 — the
    /// same 3C parity refactor as `divideRows`, for the same reason: the
    /// newline repair opens a fanned block with THIS and then splits the
    /// second successor in place, and "one transaction per block" means the
    /// two must share one. Behaviour byte-unchanged.
    func divideWRows(
        _ db: Database, blockID: String, cuts: [String: Int],
        displayedVariantID: String? = nil
    ) throws -> DivideWResult {
        let context = try placedContext(db, blockID: blockID)
        guard !cuts.isEmpty else {
            throw OperationError.noMarkedVariants(blockID: blockID)
        }
        for variantID in cuts.keys.sorted() {
            let variant = try liveVariant(db, variantID)
            guard variant.blockId == blockID else {
                throw OperationError.variantNotFound(id: variantID)
            }
            guard variant.status == .active else {
                throw OperationError.archivedVariant(id: variantID)
            }
        }

        let fan = try Variant.fetchAll(
            db,
            sql: """
                SELECT * FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY fan_position, id
                """,
            arguments: [blockID])
        let marked = fan.filter { cuts.keys.contains($0.id) }
        // Each side's (text, source, label) triples in fan order. A
        // split take contributes to both; a parked take (S4-22) to
        // exactly one — its WHOLE text, verbatim (no seam, nothing
        // trimmed) and under its own NAME, because a whole-take ride
        // keeps its name. A cut half rides as a fresh unlabeled text.
        var firstSide: [(text: String, sourceID: String, label: String?)] = []
        var secondSide: [(text: String, sourceID: String, label: String?)] = []
        for variant in marked {
            let cut = cuts[variant.id] ?? 0
            let length = variant.workingText.utf16.count
            if length > 0, cut == length {
                firstSide.append((variant.workingText, variant.id, variant.label))
            } else if length > 0, cut == 0 {
                secondSide.append((variant.workingText, variant.id, variant.label))
            } else if let pair = BoundarySnapping.seamTrimmedHalves(
                    variant.workingText, cutAtUTF16: cut),
                !pair.first.isEmpty, !pair.second.isEmpty {
                firstSide.append((pair.first, variant.id, nil))
                secondSide.append((pair.second, variant.id, nil))
            } else {
                throw OperationError.invalidCut(variantID: variant.id, cut: cut)
            }
        }
        // The parking guard (I10 by construction): each successor must
        // be born with at least one take.
        guard !firstSide.isEmpty, !secondSide.isEmpty else {
            throw OperationError.divideSideWouldBeEmpty(blockID: blockID)
        }

        let now = date.now

        // Release A's placement; A itself is preserved whole. The
        // release stamps last_container_id like deleteBlock does — a
        // released block deleted later must still know its last home
        // (tray + restoreBlock semantics; Phase 3 review finding).
        var released = context.placement
        released.deletedAt = now
        released.updatedAt = now
        try released.update(db)
        var sourceBlock = context.block
        sourceBlock.lastContainerId = context.container.id
        sourceBlock.updatedAt = now
        try sourceBlock.update(db)

        // B then C stand exactly where A stood.
        let containerID = context.container.id
        func neighbor(_ aggregate: String, _ comparison: String) throws -> String? {
            try String.fetchOne(
                db,
                sql: """
                    SELECT \(aggregate)(position) FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL AND position \(comparison) ?
                    """,
                arguments: [containerID, context.placement.position])
        }
        let follower = try neighbor("MIN", ">")
        let positionB = FractionalIndex.between(try neighbor("MAX", "<"), follower)
        let positionC = FractionalIndex.between(positionB, follower)

        // Defaults and chosen, PER SIDE (parking makes the two fans
        // independently populated): the ANCHOR take's half/copy where it
        // contributes to this successor, else the side's first
        // contributing take with chosen left NULL — the standing
        // rendered-unmarked rule, applied per side. The anchor is A's
        // rendered take unless the caller named the take the author was
        // actually in (`displayedVariantID`; an id outside `cuts` is not
        // a contributor and so cannot anchor — it falls back).
        let anchorID = displayedVariantID.flatMap { cuts.keys.contains($0) ? $0 : nil }
            ?? context.rendered.id
        var successors: [FanHalf] = []
        for (side, position) in [(firstSide, positionB), (secondSide, positionC)] {
            let renderedIndex = side.firstIndex { $0.sourceID == anchorID }
            let minted = try mintFanBlock(
                db, texts: side.map(\.text), in: containerID,
                position: position,
                defaultIndex: renderedIndex ?? 0, chosenIndex: renderedIndex,
                presentation: context.block.presentation,
                labels: side.map(\.label), now: now)
            let edge = try insertLineageEdge(
                db, from: minted.block.id, to: blockID, originOp: "divide", now: now)
            // Phase 13 (A2) travel: the W's copies land on BOTH
            // successors; A — preserved whole — keeps its originals.
            try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
            successors.append(FanHalf(
                block: minted.block, variants: minted.variants,
                sourceVariantIDs: side.map(\.sourceID),
                placement: minted.placement, edge: edge))
        }

        try touchContainer(db, containerID, now: now)

        return DivideWResult(
            first: successors[0], second: successors[1],
            markedSourceIDs: marked.map(\.id),
            releasedPlacementID: context.placement.id)
    }

    // MARK: - Divide, duplicate shape (the fanned DEFAULT — Q-M2, author ruling 2026-08-03)

    public struct DivideDuplicatingResult: Equatable, Sendable {
        /// B — the displayed take's first half leading its fan, every other
        /// active take duplicated whole behind it in source fan order.
        public let first: FanHalf
        /// C — the second half leading, the same duplicates behind.
        public let second: FanHalf
        /// A's released placement row (the pre-image undo flips back).
        public let releasedPlacementID: String
    }

    /// **The duplicate-shape divide — the ruled DEFAULT for dividing a
    /// fanned block** (author, 2026-08-03 at the mobile v1 gate sitting,
    /// Q-M2; her words are the spec, recorded verbatim in
    /// `notes/plans/mobile-app-plan.md`'s gate record): the DISPLAYED take
    /// is cut at `cut`; its first half seeds B, its second half seeds C;
    /// **every OTHER active take is duplicated WHOLE onto BOTH successors**
    /// — no `CutPropagation`, no unique-match gate, no ceremony. "It
    /// sidesteps smart divide rules entirely - the takes that you aren't
    /// dividing are just duplicated, one per each block." The extra takes
    /// are hers to delete — quicker than a ceremony, and nothing is ever
    /// hunted for. The phone's fanned divide door calls this; the Mac's
    /// door keeps opening the W ceremony until Phase 13j wires its switch
    /// (the operation is deliberately DORMANT for the Mac until then).
    ///
    /// Composition with the standing rules (the W resolution byte-intact):
    /// A is **preserved whole** and released to lineage — placement
    /// tombstoned, `last_container_id` stamped, every variant and commit
    /// untouched, reversible by re-pointing (`placeBlock`). Archived takes
    /// stay on A (the W's unmarked-variant precedent — nothing is lost);
    /// locked takes duplicate fine (buffers are COPIED, never edited — the
    /// W's locked-marked rule) and the duplicates are NOT born locked (the
    /// poolDragCopy rule). Duplicates are fresh rows with fresh UUIDs,
    /// texts, statuses (active by construction), and labels copied — a
    /// whole-take ride keeps its name, the merge-carry precedent — with the
    /// parent tree remapped INSIDE each successor's copy set (poolDragCopy's
    /// rule: a parent outside the set — the displayed take, or an archived
    /// take left on A — maps to nil). The cut halves mint unlabeled and
    /// parentless, exactly as the W's halves do. Each successor's
    /// chosen/default is its cut half; duplicates join the fan behind it in
    /// source fan order. Both successors inherit A's presentation and get
    /// COPIES of A's live comments (the divide-W travel rule; A keeps the
    /// originals); commits are never copied. Edges: `(B derived_from A)`
    /// and `(C derived_from A)`, originOp 'divide'. Touch-without-churn.
    /// I10 holds at birth by construction — each successor carries its cut
    /// half at minimum.
    ///
    /// The cut is a UTF-16 offset into the DISPLAYED take's text, halved by
    /// the ONE cut brain (`BoundarySnapping.seamTrimmedHalves`; snapping is
    /// the editor's contract, as in `divide`). A cut at the very start or
    /// end refuses (`invalidCut` — her "valid divider" condition; there is
    /// NO parking here, that is the ceremony's vocabulary). An unfanned
    /// block is accepted deliberately (the divideW precedent: the editor
    /// picks the gesture, the op doesn't second-guess) and degenerates to a
    /// divide with release-A semantics and no duplicates — PROVISIONAL,
    /// recorded in the A2 batch record.
    @discardableResult
    public func divideDuplicating(
        _ blockID: String, displayedVariantID: String, cut: Int
    ) throws -> DivideDuplicatingResult {
        let result: DivideDuplicatingResult = try database.write { db in
            let context = try placedContext(db, blockID: blockID)

            // The displayed take must be a live ACTIVE take of THIS block
            // (the ceremony's own validation grammar): an archived take of
            // the right block diagnoses precisely; anything else — missing,
            // tombstoned, or foreign — is not found among this block's takes.
            guard let displayed = try Variant.fetchOne(db, key: displayedVariantID),
                  displayed.deletedAt == nil, displayed.blockId == blockID
            else { throw OperationError.variantNotFound(id: displayedVariantID) }
            guard displayed.status == .active else {
                throw OperationError.archivedVariant(id: displayedVariantID)
            }

            // Her "valid divider": the cut must leave two non-empty halves
            // of the displayed take. Start/end cuts refuse — nothing to
            // divide, unchanged from plain divide.
            guard let halves = BoundarySnapping.seamTrimmedHalves(
                    displayed.workingText, cutAtUTF16: cut),
                  !halves.first.isEmpty, !halves.second.isEmpty
            else { throw OperationError.invalidCut(variantID: displayedVariantID, cut: cut) }

            // Every OTHER active take, in fan order — the duplicates.
            let others = try Variant.fetchAll(
                db,
                sql: """
                    SELECT * FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID]).filter { $0.id != displayedVariantID }

            let now = date.now

            // Release A's placement; A itself is preserved whole (divideW's
            // exact release — the stamp feeds the tray + restoreBlock).
            var released = context.placement
            released.deletedAt = now
            released.updatedAt = now
            try released.update(db)
            var sourceBlock = context.block
            sourceBlock.lastContainerId = context.container.id
            sourceBlock.updatedAt = now
            try sourceBlock.update(db)

            // B then C stand exactly where A stood.
            let containerID = context.container.id
            func neighbor(_ aggregate: String, _ comparison: String) throws -> String? {
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT \(aggregate)(position) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL AND position \(comparison) ?
                        """,
                    arguments: [containerID, context.placement.position])
            }
            let follower = try neighbor("MIN", ">")
            let positionB = FractionalIndex.between(try neighbor("MAX", "<"), follower)
            let positionC = FractionalIndex.between(positionB, follower)

            // Per successor: the cut half leads (chosen + default), the
            // duplicates follow in source fan order, labels riding, the
            // parent tree remapped inside the copy set (index 0 is the cut
            // half; duplicate i's slot is i+1; a parent outside the set
            // maps to nil).
            let indexBySource = Dictionary(
                uniqueKeysWithValues: others.enumerated().map { ($1.id, $0 + 1) })
            let duplicateLabels = others.map(\.label)
            let duplicateParents = others.map { $0.parentVariantId.flatMap { indexBySource[$0] } }
            var successors: [FanHalf] = []
            for (half, position) in [(halves.first, positionB), (halves.second, positionC)] {
                let minted = try mintFanBlock(
                    db, texts: [half] + others.map(\.workingText), in: containerID,
                    position: position, defaultIndex: 0, chosenIndex: 0,
                    presentation: context.block.presentation,
                    labels: [nil] + duplicateLabels,
                    parentIndices: [nil] + duplicateParents, now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "divide", now: now)
                // Phase 13 (A2) travel: copies to BOTH successors; A —
                // preserved whole — keeps the originals.
                try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
                successors.append(FanHalf(
                    block: minted.block, variants: minted.variants,
                    sourceVariantIDs: [displayedVariantID] + others.map(\.id),
                    placement: minted.placement, edge: edge))
            }

            try touchContainer(db, containerID, now: now)

            return DivideDuplicatingResult(
                first: successors[0], second: successors[1],
                releasedPlacementID: context.placement.id)
        }
        undoStack?.register(
            label: "Divide",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [],
                    tombstoningBlocks: [
                        .init(result.first.block.id, result.first.variants),
                        .init(result.second.block.id, result.second.variants),
                    ],
                    revivingPlacementRows: [result.releasedPlacementID])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [],
                    untombstoningBlocks: [
                        .init(result.first.block.id, result.first.variants),
                        .init(result.second.block.id, result.second.variants),
                    ],
                    releasingPlacementRows: [result.releasedPlacementID])
            })
        return result
    }

    // MARK: - Split at newlines (the repair — U-6, 2026-09-06)

    public struct SplitAtNewlinesResult: Equatable, Sendable {
        /// The blocks the source became, in reading order. Exactly
        /// `[blockID]` when the block was already one paragraph — the no-op,
        /// which writes nothing at all.
        public let blockIDs: [String]
        /// How many OTHER takes rode WHOLE onto the first block (the
        /// keep-on-top arm; 0 for a single-take block). *"The top paragraph
        /// is a block with all the takes"* — her words.
        public let takesKeptOnTop: Int
        /// Live active takes that could not park and stayed on the released
        /// original in lineage: an EMPTY take has no legal cut at all
        /// (`divideW` refuses it as `invalidCut`), so it keeps the archived
        /// takes company on A. Counted, never swallowed — a take that
        /// stopped following the block she split is exactly what the J8
        /// copy-truth doctrine says a receipt must be able to name.
        public let takesLeftBehind: Int

        public init(blockIDs: [String], takesKeptOnTop: Int, takesLeftBehind: Int) {
            self.blockIDs = blockIDs
            self.takesKeptOnTop = takesKeptOnTop
            self.takesLeftBehind = takesLeftBehind
        }

        /// True when the block was already one paragraph.
        public var isNoOp: Bool { blockIDs.count < 2 }
        public var blocksMade: Int { blockIDs.count }
    }

    /// **"Make every newline a block" — the repair** (author ruling **U-6**,
    /// 2026-09-06, the use-report round's 18c; her words: *"a 'make all
    /// newlines blocks' button… that automatically just leaves any take at
    /// the top paragraph of its block (aka, if you had a multi paragraph
    /// block now the top paragraph is a block with all the takes)"*). Her
    /// reason: a note written with the newlines chip OFF is one block per
    /// several paragraphs, and repairing it by hand was *"a lot of divides to
    /// run"* — and, under the superseded duplicate default, deleting an extra
    /// take between each.
    ///
    /// **ONE transaction, ONE undo entry per block.** The breaks come from
    /// the block's DISPLAYED take (`NewlineSplitting.breaks`, U-19 (4)'s list
    /// exception included); every cut then goes through the standing
    /// operations, so nothing here is a second implementation of a divide:
    ///
    /// - **Single-take block:** successive in-place `divide`s at each break.
    ///   A keeps its identity as the first paragraph (the everyday shape), so
    ///   its name, comments, presentation, tags and history stay where they
    ///   were and only the later paragraphs are minted.
    /// - **Fanned block:** the FIRST break is a keep-on-top `divideW` — the
    ///   displayed take cut there, every other take parked at its END
    ///   (`KeepOnTopDivide`, the same brain the three divide doors compose
    ///   through) — so B is paragraph 1 carrying every take, and C is the
    ///   rest as one take; C then splits in place at the remaining breaks. A
    ///   is released to lineage PRESERVED WHOLE, exactly as any W does.
    ///
    /// **Her spacing survives.** The seam trim is the ONE cut brain's
    /// (`BoundarySnapping.seamTrimmedHalves`), so a run of k newlines leaves
    /// k−1 on the preceding block and the rendering join re-creates the last
    /// — her A11 ruling, and the page reads byte-identically after the
    /// repair. This is deliberately NOT a re-segmentation: splitting at a
    /// blank line here does exactly what dividing there by hand does, because
    /// it IS dividing there.
    ///
    /// A block with **no break is a no-op**: nothing is read but the context,
    /// nothing is written, no touch, no churn, no outbox row, no undo entry.
    /// A **sealed** post refuses through `placedContext` like every
    /// structural op; a single-take block whose one take is **locked**
    /// refuses through `divide`'s own `ensureEditable` (the fanned arm copies
    /// buffers and so tolerates locks, exactly as `divideW` always has).
    @discardableResult
    public func splitBlockAtNewlines(_ blockID: String) throws -> SplitAtNewlinesResult {
        struct Landing {
            var result: SplitAtNewlinesResult
            var preImages: [TextPreImage] = []
            var minted: [MintedPreImage] = []
            var released: [String] = []
        }

        let landing: Landing = try database.write { db in
            let context = try placedContext(db, blockID: blockID)
            guard !NewlineSplitting.breaks(in: context.rendered.workingText).isEmpty else {
                return Landing(result: SplitAtNewlinesResult(
                    blockIDs: [blockID], takesKeptOnTop: 0, takesLeftBehind: 0))
            }
            let fan = try Variant.fetchAll(
                db,
                sql: """
                    SELECT * FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID])

            var blockIDs: [String] = []
            var preImages: [TextPreImage] = []
            var minted: [MintedPreImage] = []
            var released: [String] = []
            var keptOnTop = 0
            var leftBehind = 0
            var cursorID = blockID
            var cursorText = context.rendered.workingText

            if fan.count > 1 {
                // The fanned first break, through the ONE keep-on-top brain.
                let cut = NewlineSplitting.breaks(in: cursorText)[0].lowerBound
                guard let composition = KeepOnTopDivide.compose(
                    displayedID: context.rendered.id, cut: cut, fan: fan)
                else { throw OperationError.variantNotFound(id: context.rendered.id) }
                let w = try divideWRows(
                    db, blockID: blockID, cuts: composition.cuts,
                    displayedVariantID: composition.displayedID)
                blockIDs.append(w.first.block.id)
                minted.append(.init(w.first.block.id, w.first.variants))
                minted.append(.init(w.second.block.id, w.second.variants))
                released.append(w.releasedPlacementID)
                keptOnTop = max(0, w.first.variants.count - 1)
                leftBehind = composition.unparkable.count
                cursorID = w.second.block.id
                cursorText = try renderedVariant(db, blockID: cursorID).workingText
            }
            blockIDs.append(cursorID)

            while let brk = NewlineSplitting.breaks(in: cursorText).first {
                let divided = try divideRows(db, blockID: cursorID, cut: brk.lowerBound)
                preImages.append(divided.preImage)
                minted.append(.init(divided.result.block.id, [divided.result.variant]))
                cursorID = divided.result.block.id
                cursorText = divided.result.variant.workingText
                blockIDs.append(cursorID)
            }

            return Landing(
                result: SplitAtNewlinesResult(
                    blockIDs: blockIDs, takesKeptOnTop: keptOnTop,
                    takesLeftBehind: leftBehind),
                preImages: preImages, minted: minted, released: released)
        }

        guard !landing.result.isNoOp else { return landing.result }
        // ONE entry for the whole block, both halves from the SAME do-time
        // pre-images (the 13c rule — `redo:` is required, never defaulted).
        // Order matters and `revertStructural` already has it right: the
        // buffers go back BEFORE the mints are tombstoned, so every minted
        // block is back at its birth text when its tombstone lands and none
        // of them is mistaken for author work and stamped into the tray.
        let preImages = landing.preImages
        let minted = landing.minted
        let released = landing.released
        undoStack?.register(
            label: "Split at Newlines",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: preImages,
                    tombstoningBlocks: minted,
                    revivingPlacementRows: released)
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: preImages,
                    untombstoningBlocks: minted,
                    releasingPlacementRows: released)
            },
            // A12: the buffers this undo would restore.
            insuring: preImages)
        return landing.result
    }

    // MARK: - Merge (mirrors W)

    public struct MergeResult: Equatable, Sendable {
        /// A' — the fresh block whose single variant is the concatenation.
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
        /// A' derived_from the first (earlier-placed) source.
        public let firstEdge: Edge
        /// A' derived_from the second source.
        public let secondEdge: Edge
        /// The released placement rows (pre-images undo flips back).
        public let releasedFirstPlacementID: String
        public let releasedSecondPlacementID: String
    }

    /// AppSpec §9: combining two adjacent blocks mints a fresh block A'
    /// whose one variant is `rendered(first)` joined to `rendered(second)`.
    ///
    /// **WHICH join is `joining`'s answer — author ruling R-13u4-3,
    /// 2026-09-20** (13u4 UNIT E3; SUPERSEDES the 2026-07-06 single-space
    /// join). Every merge DOOR (`.door`, the default) makes the RENDERING
    /// join — `top + "\n" + bottom`, byte-exact, no trimming, no
    /// conditionals — so the page reads byte-identical before and after the
    /// merge, and a run of blocks merged together keeps every newline
    /// inside it (her words: *"it should just make all newlines within the
    /// selected portion part of a single block"*). The two DELETE roads
    /// (`.deleteKeystroke`: the seam carve, the cross-block compound's
    /// edge-join) keep the shipped space-unless-edged join, because a
    /// delete that produced the newline it just removed would visibly do
    /// nothing. The consequence, stated: dividing at a PARAGRAPH break and
    /// merging back now round-trips byte-exactly, while a MID-SENTENCE cut
    /// comes back with a newline (the ceremony's per-pairing `space` is the
    /// road back).
    ///
    /// Fans are NOT cartesian-producted: A' gets exactly one variant. Both
    /// sources release their placements and remain live as lineage
    /// (reversible by re-pointing, like W). The blocks must be placed
    /// adjacently in one container, `first` immediately before `second`.
    /// Rendered variants are copied, never edited — locks don't refuse.
    @discardableResult
    public func merge(
        _ firstBlockID: String, _ secondBlockID: String,
        joining: MergeJoinRule = .door
    ) throws -> MergeResult {
        let result: MergeResult = try database.write { db in
            let first = try placedContext(db, blockID: firstBlockID)
            let second = try placedContext(db, blockID: secondBlockID)
            let containerID = first.container.id
            let neighborID = try String.fetchOne(
                db,
                sql: """
                    SELECT block_id FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL AND position > ?
                    ORDER BY position, id LIMIT 1
                    """,
                arguments: [containerID, first.placement.position])
            guard second.container.id == containerID, neighborID == secondBlockID else {
                throw OperationError.blocksNotAdjacent(first: firstBlockID, second: secondBlockID)
            }

            let now = date.now

            // Release both placements; the blocks stay live as lineage,
            // stamped with their last home (same rule as divideW's release).
            for context in [first, second] {
                var released = context.placement
                released.deletedAt = now
                released.updatedAt = now
                try released.update(db)
                var sourceBlock = context.block
                sourceBlock.lastContainerId = containerID
                sourceBlock.updatedAt = now
                try sourceBlock.update(db)
            }

            // A' stands exactly where the pair stood.
            func outerNeighbor(_ aggregate: String, _ comparison: String, _ anchor: String) throws -> String? {
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT \(aggregate)(position) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL AND position \(comparison) ?
                        """,
                    arguments: [containerID, anchor])
            }
            let position = FractionalIndex.between(
                try outerNeighbor("MAX", "<", first.placement.position),
                try outerNeighbor("MIN", ">", second.placement.position))

            let head = first.rendered.workingText
            let tail = second.rendered.workingText
            // The join, through the ONE join brain (13b 4B; R-13u4-3 gave it
            // its two rules). Resolved HERE — inside the transaction, on the
            // store's rendered texts — so no caller can decide it from a
            // projection that only ever lags the store.
            let joined = joining.join(head: head, tail: tail).joined(head, tail)
            // Phase 13 (A2): A' keeps the frame only when BOTH sources
            // agree on it (both-nil included) — merging a callout with
            // plain prose mints a plain block rather than silently picking
            // a side (PROVISIONAL, QUESTIONS bundle).
            let presentation = first.block.presentation == second.block.presentation
                ? first.block.presentation : nil
            let minted = try mintFanBlock(
                db, texts: [joined],
                in: containerID, position: position,
                defaultIndex: 0, chosenIndex: 0, presentation: presentation, now: now)
            let firstEdge = try insertLineageEdge(
                db, from: minted.block.id, to: firstBlockID, originOp: "merge", now: now)
            let secondEdge = try insertLineageEdge(
                db, from: minted.block.id, to: secondBlockID, originOp: "merge", now: now)
            // Phase 13 (A2) travel: A' carries BOTH sides' notes (copies
            // preserve created_at, so the merged list reads chronologically
            // across both sources); B and C keep their originals as lineage.
            try copyLiveComments(db, from: firstBlockID, to: minted.block.id, now: now)
            try copyLiveComments(db, from: secondBlockID, to: minted.block.id, now: now)
            try touchContainer(db, containerID, now: now)

            return MergeResult(
                block: minted.block, variant: minted.variants[0], placement: minted.placement,
                firstEdge: firstEdge, secondEdge: secondEdge,
                releasedFirstPlacementID: first.placement.id,
                releasedSecondPlacementID: second.placement.id)
        }
        undoStack?.register(
            label: "Merge",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [],
                    tombstoningBlocks: [.init(result.block.id, [result.variant])],
                    revivingPlacementRows: [
                        result.releasedFirstPlacementID, result.releasedSecondPlacementID,
                    ])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [],
                    untombstoningBlocks: [.init(result.block.id, [result.variant])],
                    releasingPlacementRows: [
                        result.releasedFirstPlacementID, result.releasedSecondPlacementID,
                    ])
            })
        return result
    }

    // MARK: - The merge ceremony (13b Stage 4, Batch 4B — S4-23, ruled)

    /// One hand-placed ＋ pairing: the merged block gets a take that is the
    /// first block's take joined with the second block's take. `join` is
    /// explicit — the sheet resolves the door default
    /// (`MergeJoinRule.door`, a newline since R-13u4-3) or the author's
    /// three-way choice; the operation never guesses.
    public struct MergePairing: Equatable, Sendable {
        /// A take of the FIRST (earlier-placed) block.
        public let firstVariantID: String
        /// A take of the SECOND block.
        public let secondVariantID: String
        public let join: MergeJoin

        public init(firstVariantID: String, secondVariantID: String, join: MergeJoin) {
            self.firstVariantID = firstVariantID
            self.secondVariantID = secondVariantID
            self.join = join
        }
    }

    public struct MergeCeremonyResult: Equatable, Sendable {
        /// Where each minted take came from — index-aligned with `variants`
        /// (the 4A `sourceVariantIDs` precedent: correspondence arrays over
        /// positional promises).
        public enum TakeSource: Equatable, Sendable {
            case pairing(firstVariantID: String, secondVariantID: String)
            case carried(variantID: String)
        }

        /// A' — the fresh merged block.
        public let block: Block
        /// Its fan: one take per pairing (in the pairings' given order),
        /// then the carried takes (first block's in fan order, then the
        /// second's).
        public let variants: [Variant]
        /// The provenance of each entry in `variants`, index-aligned.
        public let sources: [TakeSource]
        public let placement: ContainerBlock
        /// A' derived_from the first (earlier-placed) source.
        public let firstEdge: Edge
        /// A' derived_from the second source.
        public let secondEdge: Edge
        /// The released placement rows (pre-images undo flips back).
        public let releasedFirstPlacementID: String
        public let releasedSecondPlacementID: String
    }

    /// The merge CEREMONY's operation (the ruled addendum,
    /// `notes/plans/phase-13b-memo-merge.md` — S4-23 ruling 1, her canon
    /// extension of AppSpec §9 / OverallModel §7): a ceremony merge mints
    /// ONE take per hand-placed ＋ pairing (left-half + right-half joined
    /// per the pairing's explicit join) PLUS each carried take whole
    /// (unjoined, its label riding along), all on ONE fresh merged block
    /// standing where the pair stood. NOTHING is cartesian-producted —
    /// pairing is choosing by hand, so divide-then-merge round-trips whole
    /// when you pair 1+1 and 2+2. Unpaired, uncarried takes stay with the
    /// released sources in lineage — today's rule, now visible and chosen.
    ///
    /// Everything else composes with `merge` byte-identically: adjacency
    /// required, both placements released with `last_container_id` stamped
    /// (sources stay live as lineage; reversible by re-pointing),
    /// `derived_from`/'merge' edges to both sources, comments copied from
    /// both sides, presentation kept only when both sources agree, the post
    /// touched without reshuffling, ONE undo entry restoring the sources
    /// whole. Locked takes pair/carry fine — their buffers are COPIED,
    /// never edited. The instant no-fan `merge` is untouched.
    ///
    /// Chosen/default on the merged block (the recorded rule): the take
    /// minted from the pairing of the two RENDERED takes when that pairing
    /// exists; else the first pairing in the given order; a carry becomes
    /// chosen only when no pairing exists. Guards: at least one pairing or
    /// carry (`mergedBlockWouldHaveNoTake` — I10 at birth); each take in at
    /// most one pairing and never both paired and carried
    /// (`takePairedTwice` — 1:1, PROVISIONAL); every referenced take must
    /// be a live ACTIVE take of its named side (`variantNotFound` /
    /// `archivedVariant`).
    @discardableResult
    public func mergeCeremony(
        _ firstBlockID: String, _ secondBlockID: String,
        pairings: [MergePairing], carries: [String]
    ) throws -> MergeCeremonyResult {
        let result: MergeCeremonyResult = try database.write { db in
            let first = try placedContext(db, blockID: firstBlockID)
            let second = try placedContext(db, blockID: secondBlockID)
            let containerID = first.container.id
            let neighborID = try String.fetchOne(
                db,
                sql: """
                    SELECT block_id FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL AND position > ?
                    ORDER BY position, id LIMIT 1
                    """,
                arguments: [containerID, first.placement.position])
            guard second.container.id == containerID, neighborID == secondBlockID else {
                throw OperationError.blocksNotAdjacent(first: firstBlockID, second: secondBlockID)
            }
            guard !pairings.isEmpty || !carries.isEmpty else {
                throw OperationError.mergedBlockWouldHaveNoTake(
                    first: firstBlockID, second: secondBlockID)
            }

            // 1:1 arity (PROVISIONAL): no take twice, no paired-and-carried.
            var participating = Set<String>()
            for id in pairings.flatMap({ [$0.firstVariantID, $0.secondVariantID] }) + carries {
                guard participating.insert(id).inserted else {
                    throw OperationError.takePairedTwice(variantID: id)
                }
            }

            // The two live ACTIVE fans, in fan order — validation and the
            // carries' mechanical ordering both read these.
            func activeFan(_ blockID: String) throws -> [Variant] {
                try Variant.fetchAll(
                    db,
                    sql: """
                        SELECT * FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        ORDER BY fan_position, id
                        """,
                    arguments: [blockID])
            }
            let firstFan = try activeFan(firstBlockID)
            let secondFan = try activeFan(secondBlockID)
            let firstByID = Dictionary(uniqueKeysWithValues: firstFan.map { ($0.id, $0) })
            let secondByID = Dictionary(uniqueKeysWithValues: secondFan.map { ($0.id, $0) })

            /// A referenced take must be a live ACTIVE take of its named
            /// side. An archived take of the right block diagnoses
            /// precisely; anything else — missing, tombstoned, or the wrong
            /// block — is not found among this side's takes.
            func resolve(
                _ id: String, among side: [String: Variant], of blockID: String
            ) throws -> Variant {
                if let take = side[id] { return take }
                if let stray = try Variant.fetchOne(db, key: id),
                   stray.deletedAt == nil, stray.status == .archived,
                   stray.blockId == blockID {
                    throw OperationError.archivedVariant(id: id)
                }
                throw OperationError.variantNotFound(id: id)
            }

            var texts: [String] = []
            var labels: [String?] = []
            var sources: [MergeCeremonyResult.TakeSource] = []
            for pairing in pairings {
                let head = try resolve(
                    pairing.firstVariantID, among: firstByID, of: firstBlockID)
                let tail = try resolve(
                    pairing.secondVariantID, among: secondByID, of: secondBlockID)
                texts.append(pairing.join.joined(head.workingText, tail.workingText))
                labels.append(nil)
                sources.append(.pairing(
                    firstVariantID: head.id, secondVariantID: tail.id))
            }
            // Every carry must be a live ACTIVE take of either side (the
            // arity set above already forbids doubles); an archived take of
            // either block diagnoses precisely.
            for id in carries where firstByID[id] == nil && secondByID[id] == nil {
                if let stray = try Variant.fetchOne(db, key: id),
                   stray.deletedAt == nil, stray.status == .archived,
                   stray.blockId == firstBlockID || stray.blockId == secondBlockID {
                    throw OperationError.archivedVariant(id: id)
                }
                throw OperationError.variantNotFound(id: id)
            }
            // Carries land in MECHANICAL order (the recorded rule): the
            // first block's carried takes in fan order, then the second's —
            // the caller's array order never reaches the store.
            let carrySet = Set(carries)
            for take in firstFan + secondFan where carrySet.contains(take.id) {
                texts.append(take.workingText)
                labels.append(take.label)
                sources.append(.carried(variantID: take.id))
            }

            let now = date.now

            // Release both placements; the blocks stay live as lineage,
            // stamped with their last home (merge's exact release).
            for context in [first, second] {
                var released = context.placement
                released.deletedAt = now
                released.updatedAt = now
                try released.update(db)
                var sourceBlock = context.block
                sourceBlock.lastContainerId = containerID
                sourceBlock.updatedAt = now
                try sourceBlock.update(db)
            }

            // A' stands exactly where the pair stood.
            func outerNeighbor(_ aggregate: String, _ comparison: String, _ anchor: String) throws -> String? {
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT \(aggregate)(position) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL AND position \(comparison) ?
                        """,
                    arguments: [containerID, anchor])
            }
            let position = FractionalIndex.between(
                try outerNeighbor("MAX", "<", first.placement.position),
                try outerNeighbor("MIN", ">", second.placement.position))

            // Chosen/default: the rendered×rendered pairing when it exists;
            // else the first pairing; a carry only when no pairing exists.
            let renderedPairing = pairings.firstIndex {
                $0.firstVariantID == first.rendered.id
                    && $0.secondVariantID == second.rendered.id
            }
            let defaultIndex = renderedPairing ?? 0

            // Phase 13 (A2): A' keeps the frame only when BOTH sources
            // agree on it (both-nil included) — merge's exact rule.
            let presentation = first.block.presentation == second.block.presentation
                ? first.block.presentation : nil
            let minted = try mintFanBlock(
                db, texts: texts, in: containerID, position: position,
                defaultIndex: defaultIndex, chosenIndex: defaultIndex,
                presentation: presentation, labels: labels, now: now)
            let firstEdge = try insertLineageEdge(
                db, from: minted.block.id, to: firstBlockID, originOp: "merge", now: now)
            let secondEdge = try insertLineageEdge(
                db, from: minted.block.id, to: secondBlockID, originOp: "merge", now: now)
            // Phase 13 (A2) travel: A' carries BOTH sides' notes (merge's
            // exact rule); the sources keep their originals as lineage.
            try copyLiveComments(db, from: firstBlockID, to: minted.block.id, now: now)
            try copyLiveComments(db, from: secondBlockID, to: minted.block.id, now: now)
            try touchContainer(db, containerID, now: now)

            return MergeCeremonyResult(
                block: minted.block, variants: minted.variants, sources: sources,
                placement: minted.placement,
                firstEdge: firstEdge, secondEdge: secondEdge,
                releasedFirstPlacementID: first.placement.id,
                releasedSecondPlacementID: second.placement.id)
        }
        undoStack?.register(
            label: "Merge Takes",
            inverse: {
                try $0.revertStructural(
                    restoringTexts: [],
                    tombstoningBlocks: [.init(result.block.id, result.variants)],
                    revivingPlacementRows: [
                        result.releasedFirstPlacementID, result.releasedSecondPlacementID,
                    ])
            },
            redo: {
                try $0.reapplyStructural(
                    restoringTexts: [],
                    untombstoningBlocks: [.init(result.block.id, result.variants)],
                    releasingPlacementRows: [
                        result.releasedFirstPlacementID, result.releasedSecondPlacementID,
                    ])
            })
        return result
    }

    // MARK: - Shared internals

    struct PlacedContext {
        let block: Block
        let placement: ContainerBlock
        let container: Container
        let rendered: Variant
    }

    /// The standing start of every structural op: a live block with a live
    /// placement (structure needs a spot in a reading order) in an unsealed
    /// container, and the variant its slot renders.
    func placedContext(_ db: Database, blockID: String) throws -> PlacedContext {
        let block = try liveBlock(db, blockID)
        guard let placement = try livePlacement(db, blockID: blockID) else {
            throw OperationError.blockNotPlaced(id: blockID)
        }
        let container = try liveContainer(db, placement.containerId)
        try ensureUnlocked(container)
        let rendered = try renderedVariant(db, block: block, placement: placement)
        return PlacedContext(
            block: block, placement: placement, container: container, rendered: rendered)
    }

    /// A variant whose buffer a structural op may rewrite: active and
    /// unlocked (the container seal is `placedContext`'s check).
    func ensureEditable(_ variant: Variant) throws {
        guard variant.status != .archived else {
            throw OperationError.archivedVariant(id: variant.id)
        }
        guard !variant.locked else {
            throw OperationError.lockedVariant(id: variant.id)
        }
    }

    struct MintedBlock {
        let block: Block
        let variant: Variant
        let placement: ContainerBlock
    }

    /// One fresh block with one variant, placed and chosen — `newBlock`'s
    /// row set, shared by the structural ops (which add lineage on top).
    /// The block↔variant FK circle resolves by inserting the block with a
    /// NULL default first, then pointing it at the freshly inserted variant.
    /// `presentation` is the Phase 13 travel half: a structural successor
    /// inherits its source's callout frame (nil for brand-new blocks).
    /// `label` is 13e batch 3's (E5/E6b): a take that rides WHOLE into a
    /// block keeps its name — the merge-carry precedent, where a carried
    /// take keeps its label because the name is part of the take it rides in
    /// on. Every other caller mints unlabeled, exactly as before.
    func mintBlock(
        _ db: Database, text: String, in containerID: String,
        at insert: InsertPosition, presentation: String? = nil,
        label: String? = nil, now: Date
    ) throws -> MintedBlock {
        var block = Block(
            id: newID(), ownerId: currentOwnerID(), presentation: presentation,
            createdAt: now, updatedAt: now)
        try block.insert(db)

        let variant = Variant(
            id: newID(), blockId: block.id, workingText: text,
            label: label,
            fanPosition: FractionalIndex.initial(),
            createdAt: now, updatedAt: now)
        try variant.insert(db)

        block.defaultVariantId = variant.id
        try block.update(db)

        let placement = ContainerBlock(
            id: newID(), containerId: containerID, blockId: block.id,
            position: try containerPosition(db, containerID: containerID, at: insert),
            chosenVariantId: variant.id,
            createdAt: now, updatedAt: now)
        try placement.insert(db)

        return MintedBlock(block: block, variant: variant, placement: placement)
    }

    struct MintedFanBlock {
        let block: Block
        let variants: [Variant]
        let placement: ContainerBlock
    }

    /// A fresh block carrying a whole fan (divide-W's successors, merge's
    /// single-variant result, the merge ceremony's paired+carried fan, the
    /// duplicate-shape divide's successors): one
    /// variant per text, fresh fan positions
    /// preserving the given order, parentless by default (block-level edges
    /// carry the lineage; the variant parent tree never crosses blocks),
    /// placed at an exact position. Lineage edges are the caller's — their
    /// count and ancestors differ per operation. `labels`, when given, rides
    /// index-aligned with `texts` (13b 4B: a carried take keeps its label —
    /// the name is part of the take it rides in on; pairings mint unlabeled).
    /// `parentIndices`, when given, remaps a parent tree INSIDE the minted
    /// set (the poolDragCopy pre-assigned-ID shape, `Operations+Pool`):
    /// every variant's ID is assigned up front and entry `i`'s parent
    /// resolves from that map, so the remap is ORDER-FREE — a parent may
    /// sit at ANY index. A parent at a LATER index is impossible through
    /// today's ops (`branchVariant` appends children after their parents)
    /// but reachable the day reorder-takes makes `fan_position` mutable
    /// (13e, PL-1); its pointer lands in a second pass AFTER every row
    /// exists, because the immediate FK refuses a forward reference at
    /// insert time. A self- or out-of-range index reads as parentless
    /// (the outside-the-set rule).
    func mintFanBlock(
        _ db: Database, texts: [String], in containerID: String, position: String,
        defaultIndex: Int, chosenIndex: Int?, presentation: String? = nil,
        labels: [String?]? = nil, parentIndices: [Int?]? = nil, now: Date
    ) throws -> MintedFanBlock {
        var block = Block(
            id: newID(), ownerId: currentOwnerID(), presentation: presentation,
            createdAt: now, updatedAt: now)
        try block.insert(db)

        // The poolDragCopy shape: IDs pre-assigned before any insert, so a
        // parent reference resolves by ID, never by index into the
        // partially built array.
        let ids = texts.map { _ in newID() }
        func mintedParent(_ i: Int) -> (id: String, index: Int)? {
            guard let parentIndices, i < parentIndices.count,
                  let parentIndex = parentIndices[i],
                  ids.indices.contains(parentIndex), parentIndex != i
            else { return nil }
            return (ids[parentIndex], parentIndex)
        }

        var variants: [Variant] = []
        var forwardParented: [Int] = []
        var lastFanPosition: String?
        for (i, text) in texts.enumerated() {
            let fanPosition = lastFanPosition.map { FractionalIndex.between($0, nil) }
                ?? FractionalIndex.initial()
            var parentID: String?
            if let parent = mintedParent(i) {
                // A backward parent already exists — it rides the insert; a
                // FORWARD parent's row doesn't yet, so its pointer waits for
                // the second pass below (the immediate FK would refuse it).
                if parent.index < i { parentID = parent.id } else { forwardParented.append(i) }
            }
            let variant = Variant(
                id: ids[i], blockId: block.id, parentVariantId: parentID,
                workingText: text,
                label: labels.flatMap { i < $0.count ? $0[i] : nil },
                fanPosition: fanPosition, createdAt: now, updatedAt: now)
            try variant.insert(db)
            variants.append(variant)
            lastFanPosition = fanPosition
        }
        for i in forwardParented {
            variants[i].parentVariantId = mintedParent(i)?.id
            try variants[i].update(db)
        }

        block.defaultVariantId = variants[defaultIndex].id
        try block.update(db)

        let placement = ContainerBlock(
            id: newID(), containerId: containerID, blockId: block.id,
            position: position, chosenVariantId: chosenIndex.map { variants[$0].id },
            createdAt: now, updatedAt: now)
        try placement.insert(db)

        return MintedFanBlock(block: block, variants: variants, placement: placement)
    }

    /// The coarse lineage record: `(descendant derived_from ancestor)`,
    /// stamped with the operation that minted it (AppSpec §7 edge note).
    func insertLineageEdge(
        _ db: Database, from descendantBlockID: String, to ancestorBlockID: String,
        originOp: String, now: Date
    ) throws -> Edge {
        let edge = Edge(
            id: newID(), sourceBlockId: descendantBlockID, targetBlockId: ancestorBlockID,
            type: .derivedFrom, originOp: originOp, createdAt: now)
        try edge.insert(db)
        return edge
    }
}
