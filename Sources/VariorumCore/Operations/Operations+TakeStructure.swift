import Dependencies
import Foundation
import GRDB

// Phase 13e, batch 3 — TAKE ↔ BLOCK structure: the two doors her 2026-07-25
// intake asked for, built under **architect ruling AR-1** (the plan file's
// binding text).
//
//  - **E5 / A20**, verbatim: *"shortcut for moving a take into being a new
//    block beneath the current block."*
//  - **E6b / A21**, verbatim: *"…or turning all takes into their own
//    blocks"* — which the A45 "sub-takes" finding reframes as the REPAIR
//    TOOL for work already shaped wrong (*"my current takes should've been
//    blocks"*). I7 is untouched by both: this is the sub-takes ANSWER —
//    sibling blocks, never nesting.
//
// **AR-1: MINT-COPY, and the source take is ARCHIVED.** The take does not
// move house: the new block gets a fresh variant carrying its text (the
// divide / poolDragCopy precedent — commits are never copied), and the
// original is archived on its own block, where it stays reachable in the
// archived listing WITH its commits, label and lock. The rejected road was
// flipping `variant.block_id`, which is not architecturally available: the
// sync repair layer's candidate set is populated from the ARRIVING row's
// `block_id` only, so the block a take LEFT never becomes a repair
// candidate — two devices each moving a different take out of one block
// converge to a live, placed block with zero live variants and NO self-heal
// (a new SyncSpec §7 repair class, i.e. spec + `Sync/` surgery). Archive
// composes with the ratified repairs instead: the same race lands two
// archived takes on the block, which the EXISTING archive/archive I10
// rescue heals.
//
// Everything else is the structural family's standing shape: fresh blocks
// placed by fractional key, `derived_from` lineage ('manual' — the existing
// CHECK vocabulary), presentation inherited, live comments COPIED onto the
// successor (AppSpec §9's travel rule), the seal refusing through
// `placedContext`, touch-without-churn (restructuring is working on the
// note, but it must never reshuffle the meaningful sort), and ONE undo
// entry carrying inverse AND redo from do-time pre-images.
extension Operations {
    // MARK: - E5: one take becomes the block below

    public struct TakeToBlockResult: Equatable, Sendable {
        /// The minted block, standing immediately below the source.
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
        public let edge: Edge
        /// The source take, now archived on the source block.
        public let archivedVariantID: String
    }

    /// **Her A20**: the named take leaves the fan and becomes its own block
    /// directly below the block it came from.
    ///
    /// The take must be a live ACTIVE take of this block (an archived take of
    /// the same block diagnoses precisely — the `divideDuplicating`
    /// validation grammar), and it must carry TEXT: a blank take has nothing
    /// to become, so it refuses rather than minting an empty block (AR-1(d) —
    /// `takesToBlocks` skips blanks instead). A one-take fan refuses through
    /// the standing I10 guard (`ensureNotLastActive`): a take moves out when
    /// there is another left behind; emptying a block is `divide`'s job, not
    /// this one.
    ///
    /// A LOCKED take is permitted, because that is exactly what
    /// `archiveVariant` does today (AR-1(b): follow that door, never invent a
    /// third behaviour) — the lock freezes the BUFFER and this operation
    /// never edits it. The COPY is not born locked (the poolDragCopy copy
    /// doctrine), and the archived original keeps its lock.
    ///
    /// The chosen pointer is deliberately left alone when the moved take was
    /// chosen: archiving a chosen take is a ratified state whose read-time
    /// rule renders the block default in its place (AppSpec §7), and the
    /// default is reassigned here exactly as `archiveVariant` reassigns it.
    @discardableResult
    public func takeToBlockBelow(
        _ blockID: String, variantID: String
    ) throws -> TakeToBlockResult {
        let (result, preImage): (TakeToBlockResult, TakeConversion) =
            try database.write { db in
                let context = try placedContext(db, blockID: blockID)
                let take = try convertibleTake(db, blockID: blockID, variantID: variantID)
                guard !take.workingText.isEmpty else {
                    throw OperationError.emptyTakeCannotBecomeABlock(variantID: variantID)
                }
                try ensureNotLastActive(db, take)

                let now = date.now
                let minted = try mintBlock(
                    db, text: take.workingText, in: context.container.id,
                    at: .after(blockID), presentation: context.block.presentation,
                    label: take.label, now: now)
                let edge = try insertLineageEdge(
                    db, from: minted.block.id, to: blockID, originOp: "manual", now: now)
                // AppSpec §9 travel: the successor gets COPIES; the source
                // block keeps its own notes (extract's rule, exactly).
                try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
                let wasDefault = try archiveTakeRow(db, take, now: now)
                try touchContainer(db, context.container.id, now: now)

                return (
                    TakeToBlockResult(
                        block: minted.block, variant: minted.variant,
                        placement: minted.placement, edge: edge,
                        archivedVariantID: take.id),
                    TakeConversion(
                        minted: MintedPreImage(minted.block.id, [minted.variant]),
                        sourceVariantID: take.id, sourceWasDefault: wasDefault))
            }
        registerTakeConversions([preImage], label: "Move Take into a Block")
        return result
    }

    // MARK: - E6b: the whole fan becomes blocks (the A45 repair)

    /// One take that became a block: the minted block and its take, plus the
    /// source take now archived on the source block.
    public struct ConvertedTake: Equatable, Sendable {
        public let block: Block
        public let variant: Variant
        public let sourceVariantID: String
    }

    public struct TakesToBlocksResult: Equatable, Sendable {
        /// The take that STAYED on the source block — what the note reads as,
        /// unchanged (AR-1(c)).
        public let keptVariantID: String
        /// One entry per converted take, in fan order.
        public let converted: [ConvertedTake]
        /// Blank takes passed over rather than minted as empty blocks
        /// (AR-1(d)) — the door's receipt says so.
        public let skippedBlankTakes: Int
    }

    /// **Her A21's second half, and A45's repair tool**: every OTHER take of
    /// this block becomes its own block, in fan order, directly below it.
    ///
    /// **The block keeps showing what it showed** (AR-1(c)): the take the
    /// slot RENDERS stays on the source block, and the alternates become
    /// blocks after it — the same order the clipboard door writes (shown
    /// take, then alternates), so the two halves of A21 agree, and a
    /// conversion never silently changes what the note reads as.
    ///
    /// Blank takes are SKIPPED, counted, and reported (AR-1(d)); archived
    /// takes ride nowhere and stay on the source block (AR-1(f) — the
    /// divide-W unmarked-variant precedent). ONE transaction, ONE undo entry
    /// whose inverse tombstones every mint and un-archives every source.
    /// Refuses when the block has no other take with prose in it.
    @discardableResult
    public func takesToBlocks(_ blockID: String) throws -> TakesToBlocksResult {
        let (result, preImages): (TakesToBlocksResult, [TakeConversion]) =
            try database.write { db in
                let context = try placedContext(db, blockID: blockID)
                let fan = try Variant.fetchAll(
                    db,
                    sql: """
                        SELECT * FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        ORDER BY fan_position, id
                        """,
                    arguments: [blockID])
                let others = fan.filter { $0.id != context.rendered.id }
                let convertible = others.filter { !$0.workingText.isEmpty }
                guard !convertible.isEmpty else {
                    throw OperationError.noConvertibleTakes(blockID: blockID)
                }

                let now = date.now
                var converted: [ConvertedTake] = []
                var preImages: [TakeConversion] = []
                // Each mint lands after the PREVIOUS one, so the run reads in
                // fan order below the source block.
                var anchorID = blockID
                for take in convertible {
                    let minted = try mintBlock(
                        db, text: take.workingText, in: context.container.id,
                        at: .after(anchorID), presentation: context.block.presentation,
                        label: take.label, now: now)
                    _ = try insertLineageEdge(
                        db, from: minted.block.id, to: blockID, originOp: "manual", now: now)
                    try copyLiveComments(db, from: blockID, to: minted.block.id, now: now)
                    let wasDefault = try archiveTakeRow(db, take, now: now)
                    converted.append(ConvertedTake(
                        block: minted.block, variant: minted.variant,
                        sourceVariantID: take.id))
                    preImages.append(TakeConversion(
                        minted: MintedPreImage(minted.block.id, [minted.variant]),
                        sourceVariantID: take.id, sourceWasDefault: wasDefault))
                    anchorID = minted.block.id
                }
                try touchContainer(db, context.container.id, now: now)

                return (
                    TakesToBlocksResult(
                        keptVariantID: context.rendered.id, converted: converted,
                        skippedBlankTakes: others.count - convertible.count),
                    preImages)
            }
        registerTakeConversions(preImages, label: "Turn Takes into Blocks")
        return result
    }

    // MARK: - Shared internals

    /// A take these doors may convert: a live ACTIVE take of THIS block. An
    /// archived take of the right block diagnoses precisely; anything else —
    /// missing, tombstoned, or foreign — is not found among this block's
    /// takes (the `divideDuplicating` grammar, verbatim).
    private func convertibleTake(
        _ db: Database, blockID: String, variantID: String
    ) throws -> Variant {
        guard let take = try Variant.fetchOne(db, key: variantID),
              take.deletedAt == nil, take.blockId == blockID
        else { throw OperationError.variantNotFound(id: variantID) }
        guard take.status == .active else {
            throw OperationError.archivedVariant(id: variantID)
        }
        return take
    }

    /// `archiveVariant`'s ROW work, inline (these doors are one transaction,
    /// and the public op opens its own and registers its own undo entry).
    /// Byte-for-byte the same transition: status archived, `updated_at`
    /// stamped, the block default reassigned when it named this take.
    /// Returns whether it WAS the default, which is what the inverse needs.
    private func archiveTakeRow(_ db: Database, _ take: Variant, now: Date) throws -> Bool {
        let wasDefault = try liveBlock(db, take.blockId).defaultVariantId == take.id
        var archived = take
        archived.status = .archived
        archived.updatedAt = now
        try archived.update(db)
        try reassignDefaultIfNeeded(db, blockID: take.blockId, removing: take.id, now: now)
        return wasDefault
    }

    /// One converted take's do-time images: the block it minted and the
    /// source take that was archived for it.
    struct TakeConversion: Sendable {
        let minted: MintedPreImage
        let sourceVariantID: String
        let sourceWasDefault: Bool
    }

    /// The ONE undo registration both doors use — inverse AND redo from the
    /// same do-time pre-images (13c 1B), exact-row in both directions: no
    /// row is ever minted by either half, so do → undo → redo returns the
    /// store to the post-op rows with every ID intact.
    private func registerTakeConversions(_ conversions: [TakeConversion], label: String) {
        guard !conversions.isEmpty else { return }
        registerStructuralEntry(
            label: label,
            minting: conversions.map(\.minted),
            archivingTakes: conversions.map { ($0.sourceVariantID, $0.sourceWasDefault) })
    }
}
