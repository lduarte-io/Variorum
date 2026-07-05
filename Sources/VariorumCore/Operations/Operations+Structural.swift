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
        throw OperationError.variantNotFound(id: block.defaultVariantId ?? block.id)
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
    @discardableResult
    public func extract(_ blockID: String, span: Range<Int>) throws -> ExtractResult {
        let (result, sourcePreImage): (ExtractResult, (id: String, text: String)) =
            try database.write { db in
                let context = try placedContext(db, blockID: blockID)
                try ensureEditable(context.rendered)
                let text = context.rendered.workingText
                guard let kind = BoundarySnapping.extractableSpan(span, in: text),
                      let indices = BoundarySnapping.graphemeRange(span, in: text)
                else { throw OperationError.spanNotExtractable(blockID: blockID) }

                let spanText = String(text[indices]).trimmingCharacters(in: .whitespacesAndNewlines)
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
                    db, text: spanText, in: context.container.id, at: insertAt, now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "extract", now: now)
                try registerTextChange(
                    db, blockID: blockID, charDelta: text.count - remainder.count,
                    forceMajorRevision: false, now: now)

                return (
                    ExtractResult(
                        block: minted.block, variant: minted.variant,
                        placement: minted.placement, edge: edge),
                    (context.rendered.id, text)
                )
            }
        undoStack?.register(label: "Extract") {
            try $0.revertStructural(
                restoringTexts: [.init(variantID: sourcePreImage.id, text: sourcePreImage.text)],
                tombstoningBlocks: [result.block.id],
                revivingPlacementRows: [])
        }
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
    /// halves are whitespace-trimmed at the seam. Note the documented
    /// restoreCommit behavior: a commit predating this cut still holds the
    /// full text, and restoring it resurrects both halves into the source's
    /// buffer while C sits next door (AppSpec §9; the editor warns, Phase 7).
    @discardableResult
    public func divide(_ blockID: String, cut: Int) throws -> DivideResult {
        let (result, sourcePreImage): (DivideResult, (id: String, text: String)) =
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
                    at: .after(blockID), now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "divide", now: now)
                try registerTextChange(
                    db, blockID: blockID, charDelta: text.count - halves.first.count,
                    forceMajorRevision: false, now: now)

                return (
                    DivideResult(
                        block: minted.block, variant: minted.variant,
                        placement: minted.placement, edge: edge),
                    (context.rendered.id, text)
                )
            }
        undoStack?.register(label: "Divide") {
            try $0.revertStructural(
                restoringTexts: [.init(variantID: sourcePreImage.id, text: sourcePreImage.text)],
                tombstoningBlocks: [result.block.id],
                revivingPlacementRows: [])
        }
        return result
    }

    // MARK: - Divide, multi-variant (W — the one ceremony)

    /// One successor block of a W divide: its half-fan in marked order.
    public struct FanHalf: Equatable, Sendable {
        public let block: Block
        /// One variant per marked source variant, in fan order.
        public let variants: [Variant]
        public let placement: ContainerBlock
        public let edge: Edge
    }

    public struct DivideWResult: Equatable, Sendable {
        /// B — the first halves.
        public let first: FanHalf
        /// C — the second halves.
        public let second: FanHalf
        /// The marked source variants in fan order — `first.variants[i]` and
        /// `second.variants[i]` are the halves of `markedSourceIDs[i]`.
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
    /// halves of A's rendered variant when it is marked (also the new
    /// placements' chosen), else the halves of the first marked variant
    /// (chosen left NULL). Cuts are per-variant UTF-16 offsets, seam-trimmed.
    /// Marked variants may be locked — their buffers are copied, not edited.
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
            var halves: [(first: String, second: String)] = []
            for variant in marked {
                let cut = cuts[variant.id] ?? 0
                guard let pair = BoundarySnapping.seamTrimmedHalves(
                        variant.workingText, cutAtUTF16: cut),
                      !pair.first.isEmpty, !pair.second.isEmpty
                else { throw OperationError.invalidCut(variantID: variant.id, cut: cut) }
                halves.append(pair)
            }

            let now = date.now

            // Release A's placement; A itself is preserved whole.
            var released = context.placement
            released.deletedAt = now
            released.updatedAt = now
            try released.update(db)

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

            // Defaults and chosen: the rendered variant's halves when it is
            // marked; otherwise the first marked variant's halves, chosen NULL.
            let renderedIndex = marked.firstIndex { $0.id == context.rendered.id }
            var successors: [FanHalf] = []
            for texts in [halves.map(\.first), halves.map(\.second)] {
                let minted = try mintFanBlock(
                    db, texts: texts, in: containerID,
                    position: successors.isEmpty ? positionB : positionC,
                    defaultIndex: renderedIndex ?? 0, chosenIndex: renderedIndex, now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "divide", now: now)
                successors.append(FanHalf(
                    block: minted.block, variants: minted.variants,
                    placement: minted.placement, edge: edge))
            }

            return DivideWResult(
                first: successors[0], second: successors[1],
                markedSourceIDs: marked.map(\.id),
                releasedPlacementID: context.placement.id)
        }
        undoStack?.register(label: "Divide") {
            try $0.revertStructural(
                restoringTexts: [],
                tombstoningBlocks: [result.first.block.id, result.second.block.id],
                revivingPlacementRows: [result.releasedPlacementID])
        }
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
    /// whose one variant is `rendered(first) + rendered(second)` — the exact
    /// concatenation, no separator invented (the spec says "chosen(B) +
    /// chosen(C)"; the author sees the raw join in the editor and adjusts).
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

            // Release both placements; the blocks stay live as lineage.
            for var released in [first.placement, second.placement] {
                released.deletedAt = now
                released.updatedAt = now
                try released.update(db)
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

            let minted = try mintFanBlock(
                db, texts: [first.rendered.workingText + second.rendered.workingText],
                in: containerID, position: position,
                defaultIndex: 0, chosenIndex: 0, now: now)
            let firstEdge = try insertLineageEdge(
                db, from: minted.block.id, to: firstBlockID, originOp: "merge", now: now)
            let secondEdge = try insertLineageEdge(
                db, from: minted.block.id, to: secondBlockID, originOp: "merge", now: now)

            return MergeResult(
                block: minted.block, variant: minted.variants[0], placement: minted.placement,
                firstEdge: firstEdge, secondEdge: secondEdge,
                releasedFirstPlacementID: first.placement.id,
                releasedSecondPlacementID: second.placement.id)
        }
        undoStack?.register(label: "Merge") {
            try $0.revertStructural(
                restoringTexts: [],
                tombstoningBlocks: [result.block.id],
                revivingPlacementRows: [
                    result.releasedFirstPlacementID, result.releasedSecondPlacementID,
                ])
        }
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
    func mintBlock(
        _ db: Database, text: String, in containerID: String,
        at insert: InsertPosition, now: Date
    ) throws -> MintedBlock {
        var block = Block(id: newID(), createdAt: now, updatedAt: now)
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
    /// single-variant result): one variant per text, fresh fan positions
    /// preserving the given order, parentless (block-level edges carry the
    /// lineage; the variant parent tree never crosses blocks), placed at an
    /// exact position. Lineage edges are the caller's — their count and
    /// ancestors differ per operation.
    private func mintFanBlock(
        _ db: Database, texts: [String], in containerID: String, position: String,
        defaultIndex: Int, chosenIndex: Int?, now: Date
    ) throws -> MintedFanBlock {
        var block = Block(id: newID(), createdAt: now, updatedAt: now)
        try block.insert(db)

        var variants: [Variant] = []
        var lastFanPosition: String?
        for text in texts {
            let fanPosition = lastFanPosition.map { FractionalIndex.between($0, nil) }
                ?? FractionalIndex.initial()
            let variant = Variant(
                id: newID(), blockId: block.id, workingText: text,
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
