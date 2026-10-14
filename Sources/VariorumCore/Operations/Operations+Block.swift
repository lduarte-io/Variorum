import Dependencies
import Foundation
import GRDB

extension Operations {
    /// Everything `newBlock` mints, for callers and state-transition tests.
    public struct NewBlockResult: Equatable, Sendable {
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
    }

    /// AppSpec §9: INSERT block; INSERT variant(working_text=text); set
    /// block.default_variant_id; INSERT container_block(chosen=variant).
    /// The block↔variant FK circle resolves by inserting the block with a
    /// NULL default first, then pointing it at the freshly inserted variant.
    ///
    /// Minting text is working on the post (author decision 2026-07-07,
    /// QUESTIONS #5 option (a) — AppSpec §14's Phase 8 checkpoint delta):
    /// the mint stamps `last_touched_at` and feeds churn with the minted
    /// text's length, exactly like the other text-changing ops (§10 applies
    /// a fortiori after the 2026-07-06 structural-stamp ruling). This also
    /// closes both of Phase 8's documented idle-sweep residual gaps: a
    /// mint-only burst and an idle-/teardown-minted tail now re-enter the
    /// sweep's touch window like any other edit.
    /// **STRUCTURAL UNDO (author ruling R-13u-3, the 13u1 kickoff sitting —
    /// a canon extension of AppSpec §9's list, hers).** Her ask, through the
    /// `KnownIssuesAndTechDebt.md` row 18c's ladder opened: *"⌥⌘Z removes an
    /// empty block just minted by ⏎"*. `newBlock` had registered nothing
    /// since Phase 2 — not by ruling but by omission, harmless while the
    /// only door onto it was ⌘⇧⏎ and newly common the moment U-1 made the
    /// Return key mint blocks. **The inverse is a tombstone flip** (her
    /// words), so it costs exactly what every other structural inverse
    /// costs, and the redo is the exact-row mirror (13c A10's required
    /// `redo:` — a mint that could not be re-applied would end the redo
    /// future, which is the one thing a new registration must not do
    /// silently).
    ///
    /// Two behaviours ride in for free, and both are the right ones because
    /// they are `revertStructural`'s own:
    ///
    /// - **an untouched mint VANISHES; an EDITED one TRAYS.** The inverse
    ///   compares the block's takes against their BIRTH texts, and a
    ///   diverged one is stamped with `last_container_id` on the way out —
    ///   so undoing a ⏎-minted block she then typed into leaves her words in
    ///   the note's tray rather than dropping them. That is the standing
    ///   insurance doctrine, not a new rule.
    /// - **a sealed note refuses the undo and keeps the entry** (the
    ///   resolvable bucket): unseal, press again.
    ///
    /// `registeringUndo` exists for ONE class and names it rather than
    /// guessing: **type-time crystallization**, where a paragraph becomes a
    /// block *because she typed past it* (AppSpec §7: it "silently becomes a
    /// block as you type"). That is not a gesture she made, and registering
    /// it would put an entry on her stack per paragraph AND clear the redo
    /// future on every one — so the crystallizers pass `false`, at their own
    /// call sites, with that reason at the line. Every other door — ⌘⇧⏎, the
    /// Return key's act, the take↔block doors, a new snippet — is a gesture,
    /// and gestures undo. (The seeders never reach this question: they run
    /// on `Operations(undoStack: nil)` by construction.)
    @discardableResult
    public func newBlock(
        in containerID: String, text: String, at insert: InsertPosition = .end,
        registeringUndo: Bool = true
    ) throws -> NewBlockResult {
        let result: NewBlockResult = try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)

            let now = date.now
            let minted = try mintBlock(db, text: text, in: containerID, at: insert, now: now)
            try registerTextChange(
                db, blockID: minted.block.id, charDelta: text.count,
                forceMajorRevision: false, now: now)
            return NewBlockResult(
                block: minted.block, variant: minted.variant, placement: minted.placement)
        }
        guard registeringUndo else { return result }
        let minted = MintedPreImage(result.block.id, [result.variant])
        registerStructuralEntry(
            label: "New Block",
            minting: [minted])
        return result
    }

    /// Sets (or clears) the block's optional name (Phase 11, v1_6 — the
    /// block-TOC's explicit handle; AppSpec §14's 2026-07-07 delta).
    /// Whitespace-only names normalize to NIL — clearing, so the TOC row
    /// falls back to the read-time first sentence. Plain metadata: no
    /// touch stamp, no churn (naming is a handle, not working on the text).
    ///
    /// SEAL POSTURE (PROVISIONAL, Phase 11 — the QUESTIONS bundle): refused
    /// under a sealed post, per the ratified everything-UNDER-the-post
    /// letter (2026-07-05) — a block is under the post, unlike the post's
    /// own title (which stays retitle-able under seal because it lives ON
    /// the container row). The retitle-parallel alternative (allow — a name
    /// is identity metadata, not content) is recorded for the author.
    public func setBlockName(_ blockID: String, name: String?) throws {
        try database.write { db in
            var block = try liveBlock(db, blockID)
            try ensurePlacementUnlocked(db, blockID: blockID)
            let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized = (trimmed?.isEmpty ?? true) ? nil : trimmed
            guard block.name != normalized else { return }
            block.name = normalized
            block.updatedAt = date.now
            try block.update(db)
        }
    }

    /// Sets (or clears, with nil) the block's presentation frame (Phase 13,
    /// v1_9 — the callout, R16/R27). Stored as canonical JSON; a no-op set
    /// writes nothing. Plain metadata like `setBlockName`: no touch stamp,
    /// no churn (framing the prose is not working on the prose). An empty
    /// `kind` refuses — a frame must name its family.
    ///
    /// SEAL POSTURE (PROVISIONAL, Phase 13 — the QUESTIONS bundle): refused
    /// under a sealed post, per the everything-UNDER-the-post letter and
    /// the v1_6 block-name precedent (identity-level metadata on a block
    /// under the post). The viewing-isn't-authoring alternative is recorded
    /// for the author — but a callout frame CHANGES what the page shows,
    /// which reads closer to authoring than a lens does.
    public func setBlockPresentation(
        _ blockID: String, _ presentation: BlockPresentation?
    ) throws {
        try updateBlockPresentation(blockID) { _ in presentation }
    }

    /// Read-modify-write on the block's presentation in ONE transaction
    /// (Phase 13 C1 — the partial-edit doors: "set the emoji, keep the
    /// color" must transform the STORED frame, never a projection cache;
    /// the Stage B round-2 designation-read precedent). Same guards and
    /// no-op behavior as the plain setter — which now routes through here.
    public func updateBlockPresentation(
        _ blockID: String,
        _ transform: (BlockPresentation?) throws -> BlockPresentation?
    ) throws {
        try database.write { db in
            var block = try liveBlock(db, blockID)
            try ensurePlacementUnlocked(db, blockID: blockID)
            let presentation = try transform(BlockPresentation.decode(block.presentation))
            if let presentation,
               presentation.kind.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw OperationError.invalidPresentationKind
            }
            let encoded = try presentation?.encodedJSON()
            guard block.presentation != encoded else { return }
            block.presentation = encoded
            block.updatedAt = date.now
            try block.update(db)
        }
    }
}
