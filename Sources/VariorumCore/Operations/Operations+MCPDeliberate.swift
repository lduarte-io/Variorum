import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's DELIBERATE EDIT-RUNG ACTS (VX-168 U2) — VX-169's `save_commit`
// and VX-174's `choose_take` / `adopt_lens` (R-MERGE-1, "the door's merge
// button"). Each is one of §9's EXISTING operations surfaced on the wire — her
// commit (⌘S), her ✓ on a take (`chooseVariant`), her "✓ Make this the note" on
// a lens column (`adoptLensPreservingChosen`) — never special agent tooling:
// the SAME row transitions through the SAME brains (`commit`,
// `choosablePlacement`, `adoptSwapRows`), with the server's decision handed
// in as a `WriteGuard` run FIRST inside the act's own write transaction
// (AF-10 (a) — the edit rung's decide/act gap closed, as every edit act).
//
// THE UNDO STORY (argued in the run record's UNIT 2 RECORD): the two POINTER
// acts register ONE client-named entry each (R-13n-6 — every MCP write
// registers structural undo "exactly as her gestures do"; P-13nb-U2-4), whose
// pointer restores are COMPARE-AND-SET per slot (VX-184 ladder round 1 — the
// undo-overwrite class): a slot is set back only while it still points where
// the act left it (the redo: where the undo would leave it — the pre-act
// pointer), so the UNDO never overwrites a take she chose since with her own ✓
// (which registers no entry). The REDO does not yet keep that promise (VX-184
// ladder round 2, 2026-10-13): if her ✓ put the slot BACK on its pre-act take,
// ⌥⌘Z is quiet yet the entry still moves onto the redo stack (`UndoStack.undo`
// pops any inverse that does not throw), and ⇧⌥⌘Z — finding the pre-act
// pointer — re-chooses the client's take over hers. VX-276 owns the fix: the
// redo keyed on what its inverse wrote. The
// COMMIT registers NONE — exactly as her own commit registers none (AppSpec §9
// excludes commits from structural undo): a commit is append-only (I5) and
// `commit_point` carries no tombstone, so no inverse exists that would not
// destroy a row (S2). The brackets `edit_take` writes already stay when ⌥⌘Z
// walks an edit back (P-13nb-U3-2) — a deliberate commit stays the same way.
extension Operations {
    // MARK: - VX-169: a client's deliberate commit

    /// **The stored message of a client's commit** — THE CLIENT'S NAME,
    /// verbatim, prefixed: "‹client›: ‹message›" (her settlement at the
    /// 2026-10-12 pre-run sitting: the auto-brackets' own style, so Block
    /// History shows provenance at a glance on a `kind='manual'` row). The
    /// commit door then stores it through the ONE savepoint-name rule
    /// (`SavepointName`). A blank message leaves the name alone (the wire
    /// requires one; this keeps the rule total).
    public static func mcpCommitMessage(client: String, message: String) -> String {
        let said = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return said.isEmpty ? client : "\(client): \(said)"
    }

    /// **`save_commit`'s act — her commit door, exactly** (`commit`,
    /// `kind='manual'` — the settled kind; a third kind would be a §12
    /// lockstep event): the take live (an ARCHIVED take may commit — her
    /// 2026-07-05 ratification), unlocked (`lockedVariant`), not under a seal
    /// (`lockedPost`); a major-revision stamp, as every manual commit (AppSpec
    /// §10); APPENDED ALWAYS — her ⌘S never dedupes against the take's last
    /// commit, and neither does this (PROVISIONAL P-VX168-U2-1). The caller's
    /// guard runs first, in the same transaction. No undo entry (above).
    @discardableResult
    public func commitTakeForClient(
        _ variantID: String, message: String, client: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> CommitPoint {
        try commit(
            variantID, kind: .manual, message: Self.mcpCommitMessage(client: client, message: message),
            guardedBy: guardian)
    }

    // MARK: - VX-174: choose a take (per block)

    /// What `chooseTake` did.
    public struct MCPTakeChoice: Equatable, Sendable {
        public let takeID: String
        public let blockID: String
        /// False when the block already SHOWED the take — nothing was written
        /// and nothing registered.
        public let changed: Bool
    }

    /// **`choose_take`'s act — her ✓ on a take** (`chooseVariant`'s row
    /// transition through its own guards, `choosablePlacement`: the block
    /// live and placed, the note unsealed, the take live, ACTIVE and this
    /// block's; a LOCKED take may be chosen, as hers may — the lock guards
    /// the buffer). Guards FIRST, the no-op second (`renameCommitPoint`'s
    /// order): a block that already SHOWS the take (the structural ops'
    /// rendered rule — the wire's own `chosen` fact) writes nothing and
    /// registers nothing, so no act lands that she could not see
    /// (PROVISIONAL P-VX168-U2-5 — the shown take, not the raw pointer).
    /// ONE undo entry, `undoLabel`: the slot's exact pre-image pointer back
    /// (nil included) while the slot still points at the act's take, the redo
    /// the take again while it still points at the pre-image —
    /// `revertChosenPointersIfUnchanged` (a dead slot, or a take she chose
    /// since, is the world moving past the entry — quiet; past that check a
    /// sealed note refuses and keeps it). A pointer move: no text written, no
    /// touch, no churn — exactly as her ✓.
    @discardableResult
    public func chooseTake(
        _ variantID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTakeChoice {
        let landed: (choice: MCPTakeChoice, placementID: String, previous: String?) = try database.write { db in
            try guardian?(db)
            let take = try liveVariant(db, variantID)
            var placement = try choosablePlacement(db, blockID: take.blockId, variantID: variantID)
            let previous = placement.chosenVariantId
            guard (try? renderedVariant(db, blockID: take.blockId))?.id != variantID else {
                return (MCPTakeChoice(takeID: variantID, blockID: take.blockId, changed: false), placement.id, previous)
            }
            placement.chosenVariantId = variantID
            placement.updatedAt = date.now
            try placement.update(db)
            return (MCPTakeChoice(takeID: variantID, blockID: take.blockId, changed: true), placement.id, previous)
        }
        if landed.choice.changed {
            let placementID = landed.placementID
            let previous = landed.previous
            undoStack?.register(
                label: undoLabel,
                inverse: {
                    try $0.revertChosenPointersIfUnchanged([(placementID: placementID, from: variantID, to: previous)])
                },
                redo: {
                    try $0.revertChosenPointersIfUnchanged([(placementID: placementID, from: previous, to: variantID)])
                })
        }
        return landed.choice
    }

    /// One slot an MCP pointer act moved, as its entry replays it: set the
    /// slot to `to` only while it reads `from`.
    typealias PointerMove = (placementID: String, from: String?, to: String?)

    /// `restoreChosenPointersIfUnchanged` in its own transaction.
    func revertChosenPointersIfUnchanged(_ moves: [PointerMove]) throws {
        try database.write { db in try restoreChosenPointersIfUnchanged(db, moves) }
    }

    /// **THE MCP POINTER ACTS' RESTORE, COMPARE-AND-SET** (VX-184 ladder round
    /// 1 — the undo-overwrite class): each slot's `chosen_variant_id` becomes
    /// `to` only while the slot is live and still reads `from`; a slot she has
    /// re-chosen since (her ✓ registers no entry) is hers, and is skipped
    /// quietly. Past that check a sealed note refuses (the pointer brain's
    /// rule) — the whole transaction rolls back and the entry stays. HER adopt
    /// doors keep `restoreChosenPointers` (their entries are hers, outside the
    /// MCP family this pass covers — noted in the run record's sweep).
    func restoreChosenPointersIfUnchanged(_ db: Database, _ moves: [PointerMove]) throws {
        let now = date.now
        for move in moves {
            guard var placement = try ContainerBlock.fetchOne(db, key: move.placementID),
                  placement.deletedAt == nil, placement.chosenVariantId == move.from
            else { continue }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            placement.chosenVariantId = move.to
            placement.updatedAt = now
            try placement.update(db)
        }
    }

    // MARK: - VX-174: a lens made the note (wholesale)

    /// What `adoptLensAsNote` did.
    public struct MCPLensAdoption: Equatable, Sendable {
        public let lensID: String
        public let noteID: String
        /// How many blocks' chosen pointer the act set to the lens's take
        /// (her door's own count — a nil pointer the lens names is set too).
        public let moved: Int
        /// The lens the outgoing chosen was kept as ("chosen until …") — nil
        /// when nothing moved (nothing went out; nothing to keep).
        public let keptAs: Lens?

        public var changed: Bool { moved > 0 }
    }

    /// **`adopt_lens`'s act — her "✓ Make this the note" on a lens column**
    /// (`adoptLensPreservingChosen`, R89/R92: adopting SWAPS, never
    /// destroys): the lens live, its note unsealed; the outgoing chosen kept
    /// as a full-fidelity lens ("chosen until …"), then every pick the lens
    /// makes → that block's chosen — `adoptSwapRows`, her door's own body.
    /// Guards FIRST; then the no-op: a lens that already AGREES with the note
    /// — every take it names is the one its block shows (the rendered rule,
    /// as `choose_take`'s) — writes NOTHING, no preservation lens either
    /// (PROVISIONAL P-VX168-U2-3 — her door mints one regardless).
    ///
    /// ONE undo entry, `undoLabel`, walking the WHOLE act back in ONE
    /// transaction: the pointers' exact pre-images — each slot only while it
    /// still shows the adopted take (a slot she re-chose since keeps her ✓ —
    /// VX-184 ladder round 1, slot by slot) — AND the preservation lens
    /// tombstoned (its choices cascade on that stamp); the redo re-adopts the
    /// exact pointers (each slot only while it still reads its pre-image) and
    /// revives exactly that lens with the choices that died on the undo's
    /// stamp (PROVISIONAL P-VX168-U2-4 — her own door's entry restores the
    /// pointers only, its lens left as "the lens class, trivially deleted"; on
    /// the wire a minted lens is undoable — `save_lens` — so the act's lens
    /// walks back with it). A sealed note refuses the undo and keeps the entry
    /// (the pointer brain's rule).
    @discardableResult
    public func adoptLensAsNote(
        _ lensID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPLensAdoption {
        let landed: (adoption: MCPLensAdoption, moved: [AdoptedPointer]) = try database.write { db in
            try guardian?(db)
            let lens = try liveLens(db, lensID)
            let post = try livePost(db, lens.containerId)
            try ensureUnlocked(post)
            guard try lensDisagrees(db, lensID: lensID, postID: post.id) else {
                return (MCPLensAdoption(lensID: lensID, noteID: post.id, moved: 0, keptAs: nil), [])
            }
            let (kept, moved) = try adoptSwapRows(db, lensID: lensID)
            return (MCPLensAdoption(lensID: lensID, noteID: post.id, moved: moved.count, keptAs: kept), moved)
        }
        if let kept = landed.adoption.keptAs, !landed.moved.isEmpty {
            let back: [PointerMove] = landed.moved.map { (placementID: $0.placementID, from: $0.adopted, to: $0.previous) }
            let again: [PointerMove] = landed.moved.map { (placementID: $0.placementID, from: $0.previous, to: $0.adopted) }
            let keptID = kept.id
            let undoneOn = LockIsolated<String?>(nil)
            undoStack?.register(
                label: undoLabel,
                inverse: { ops in
                    if let stamp = try ops.revertLensAdoption(back, keptLensID: keptID) {
                        undoneOn.setValue(stamp)
                    }
                },
                redo: { try $0.reapplyLensAdoption(again, keptLensID: keptID, undoneOn: undoneOn.value) })
        }
        return landed.adoption
    }

    /// Does the lens name, anywhere in its note, a take its block does not
    /// SHOW right now? (The lens's live picks — `effectiveLensSelection`,
    /// which drops a dangling pick — against each placed block's rendered
    /// take.) ∝ the note.
    func lensDisagrees(_ db: Database, lensID: String, postID: String) throws -> Bool {
        let picks = try Queries.effectiveLensSelection(db, lens: lensID)
        for placement in try ContainerBlock
            .filter(Column("container_id") == postID && Column("deleted_at") == nil)
            .fetchAll(db) {
            guard let pick = picks[placement.blockId] else { continue }
            let shown = (try? liveBlock(db, placement.blockId))
                .flatMap { try? renderedVariant(db, block: $0, placement: placement) }
            if shown?.id != pick { return true }
        }
        return false
    }

    /// The adoption's inverse, ONE transaction: the pointers back where each
    /// slot still shows the adopted take (the compare-and-set pointer brain —
    /// sealed refuses whole), the preservation lens tombstoned; returns that
    /// stamp (nil when she had already deleted it).
    func revertLensAdoption(_ back: [PointerMove], keptLensID: String) throws -> String? {
        try database.write { db in
            try restoreChosenPointersIfUnchanged(db, back)
            return try tombstoneSavedLens(db, keptLensID)
        }
    }

    /// The adoption's redo, ONE transaction: the adopted pointers exactly,
    /// each slot only while it still reads its pre-image, and the
    /// preservation lens back with the choices that died on the undo's stamp
    /// (a lens she deleted since stays deleted).
    func reapplyLensAdoption(_ again: [PointerMove], keptLensID: String, undoneOn stamp: String?) throws {
        try database.write { db in
            try restoreChosenPointersIfUnchanged(db, again)
            if let stamp { try reviveSavedLens(db, keptLensID, undoneOn: stamp) }
        }
    }
}
