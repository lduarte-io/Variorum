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
                guard let kind = BoundarySnapping.extractableSpan(span, in: text),
                      let indices = BoundarySnapping.graphemeRange(span, in: text)
                else { throw OperationError.spanNotExtractable(blockID: blockID) }

                let spanText = BoundarySnapping.trimmed(text[indices])
                let remainder: String
                let insertAt: InsertPosition
                switch kind {
                case .prefix:
                    remainder = BoundarySnapping.trimLeading(text[indices.upperBound...])
                    insertAt = .before(blockID)
                case .suffix:
                    remainder = BoundarySnapping.trimTrailing(text[..<indices.lowerBound])
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
            })
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
    /// deliberately the editor's contract (`BoundarySnapping.snap`) — the
    /// operation checks well-formedness only (bounds, grapheme alignment,
    /// non-empty halves), never that the cut sits on a sentence mark.
    /// Note the documented
    /// restoreCommit behavior: a commit predating this cut still holds the
    /// full text, and restoring it resurrects both halves into the source's
    /// buffer while C sits next door (AppSpec §9; the editor warns, Phase 7).
    @discardableResult
    public func divide(_ blockID: String, cut: Int) throws -> DivideResult {
        let (result, sourcePreImage): (DivideResult, TextPreImage) =
            try database.write { db in
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
            })
        return result
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
    /// the other successor would violate I10 at birth).
    @discardableResult
    public func divideW(_ blockID: String, cuts: [String: Int]) throws -> DivideWResult {
        let result: DivideWResult = try database.write { db in
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
            // Each side's (text, source) pairs in fan order. A split take
            // contributes to both; a parked take (S4-22) to exactly one —
            // its WHOLE text, verbatim (no seam, nothing trimmed).
            var firstSide: [(text: String, sourceID: String)] = []
            var secondSide: [(text: String, sourceID: String)] = []
            for variant in marked {
                let cut = cuts[variant.id] ?? 0
                let length = variant.workingText.utf16.count
                if length > 0, cut == length {
                    firstSide.append((variant.workingText, variant.id))
                } else if length > 0, cut == 0 {
                    secondSide.append((variant.workingText, variant.id))
                } else if let pair = BoundarySnapping.seamTrimmedHalves(
                        variant.workingText, cutAtUTF16: cut),
                    !pair.first.isEmpty, !pair.second.isEmpty {
                    firstSide.append((pair.first, variant.id))
                    secondSide.append((pair.second, variant.id))
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
            // independently populated): the rendered variant's half/copy
            // where it contributes to this successor, else the side's first
            // contributing take with chosen left NULL — the standing
            // rendered-unmarked rule, applied per side.
            var successors: [FanHalf] = []
            for (side, position) in [(firstSide, positionB), (secondSide, positionC)] {
                let renderedIndex = side.firstIndex { $0.sourceID == context.rendered.id }
                let minted = try mintFanBlock(
                    db, texts: side.map(\.text), in: containerID,
                    position: position,
                    defaultIndex: renderedIndex ?? 0, chosenIndex: renderedIndex,
                    presentation: context.block.presentation, now: now)
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
        undoStack?.register(
            label: "Divide into Variants",
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
    /// whose one variant is `rendered(first) + " " + rendered(second)` — a
    /// single space at the join unless either side's edge already carries
    /// whitespace (author decision 2026-07-06: a raw no-space join was more
    /// annoying than helpful). Note the space is the join even for
    /// paragraph-shaped halves — dividing at a paragraph break and merging
    /// back turns the break into a space; the author adjusts in the editor.
    /// Fans are NOT cartesian-producted: A' gets exactly one variant. Both
    /// sources release their placements and remain live as lineage
    /// (reversible by re-pointing, like W). The blocks must be placed
    /// adjacently in one container, `first` immediately before `second`.
    /// Rendered variants are copied, never edited — locks don't refuse.
    @discardableResult
    public func merge(_ firstBlockID: String, _ secondBlockID: String) throws -> MergeResult {
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
            // The canon join, through the ONE join brain (13b 4B —
            // `MergeJoin.canon` IS this rule; the ceremony's previews and
            // pairings share it, so they can never disagree about a byte).
            let joined = MergeJoin.canon(head: head, tail: tail).joined(head, tail)
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
    /// explicit — the sheet resolves the canon default (`MergeJoin.canon`)
    /// or the author's three-way choice; the operation never guesses.
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
    func mintBlock(
        _ db: Database, text: String, in containerID: String,
        at insert: InsertPosition, presentation: String? = nil, now: Date
    ) throws -> MintedBlock {
        var block = Block(
            id: newID(), ownerId: currentOwnerID(), presentation: presentation,
            createdAt: now, updatedAt: now)
        try block.insert(db)

        let variant = Variant(
            id: newID(), blockId: block.id, workingText: text,
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
    /// single-variant result, the merge ceremony's paired+carried fan): one
    /// variant per text, fresh fan positions
    /// preserving the given order, parentless (block-level edges carry the
    /// lineage; the variant parent tree never crosses blocks), placed at an
    /// exact position. Lineage edges are the caller's — their count and
    /// ancestors differ per operation. `labels`, when given, rides
    /// index-aligned with `texts` (13b 4B: a carried take keeps its label —
    /// the name is part of the take it rides in on; pairings mint unlabeled).
    private func mintFanBlock(
        _ db: Database, texts: [String], in containerID: String, position: String,
        defaultIndex: Int, chosenIndex: Int?, presentation: String? = nil,
        labels: [String?]? = nil, now: Date
    ) throws -> MintedFanBlock {
        var block = Block(
            id: newID(), ownerId: currentOwnerID(), presentation: presentation,
            createdAt: now, updatedAt: now)
        try block.insert(db)

        var variants: [Variant] = []
        var lastFanPosition: String?
        for (i, text) in texts.enumerated() {
            let fanPosition = lastFanPosition.map { FractionalIndex.between($0, nil) }
                ?? FractionalIndex.initial()
            let variant = Variant(
                id: newID(), blockId: block.id, workingText: text,
                label: labels.flatMap { i < $0.count ? $0[i] : nil },
                fanPosition: fanPosition, createdAt: now, updatedAt: now)
            try variant.insert(db)
            variants.append(variant)
            lastFanPosition = fanPosition
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
