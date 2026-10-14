import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's EDIT-RUNG ACTS (13n-b U3 — R-13n-4's edit rung: "edit takes
// under insurance (R-13n-7), structural ops, tombstone-only delete"; R-13n-6's
// paper trail; AF-10). Like the suggest and write-new acts beside them
// (`Operations+MCPWrites`), these are ORDINARY OPERATIONS: each registers
// exactly ONE structural-undo entry labeled with THE CLIENT'S NAME, so ⌥⌘Z
// walks an AI edit back one act at a time — and they decide nothing about
// clients. The server decides whether a client may act; it hands that
// decision to the act as a `WriteGuard`, which runs FIRST inside the act's
// own write transaction (AF-10 (a) — the U2 ladder's F2 closed rung-wide: a
// note fenced, or a block moved, by a sync apply landing between the
// server's decision and the act can never be written past).
//
// The structural acts are HER DOORS' acts, composed exactly as her keyboard
// composes them (the keyboard bar, R-13nb-14): a divide on a fanned block is
// keep-on-top (`KeepOnTopDivide`, U-2), a merge where either side carries a
// fan is the carry-all merge (`CarryAllMerge`, J4b), and every other case is
// the plain op. Each is relabeled for the client by `registeringUndo(as:)` —
// composition over the act's own registration, never a second inverse.
extension Operations {
    // MARK: - The client's label on a structural act

    /// Runs ONE structural act so the undo entry it registers carries
    /// `label` ("claude-code's divide") — `UndoStack.withCompound` over the
    /// act's own registration: the entry's inverse, redo and insurance are
    /// the act's own, exactly. With no stack, the act alone.
    public func registeringUndo<T>(as label: String, _ act: () throws -> T) throws -> T {
        guard let undoStack else { return try act() }
        return try undoStack.withCompound(label: label, operations: self, act)
    }

    // MARK: - EDIT: a take, under insurance (R-13n-7)

    /// What `editTakeUnderInsurance` did.
    public struct MCPTakeEdit: Equatable, Sendable {
        /// The take as it now stands.
        public let take: Variant
        /// "before <client>'s edit" — nil when the take's last commit already
        /// held the text it had (the standing dedupe: nothing to insure).
        public let before: CommitPoint?
        /// "after <client>'s edit".
        public let after: CommitPoint?
        /// False when the take already read as asked — nothing was written.
        public let changed: Bool
    }

    /// The two bracketing commits' names — THE CLIENT'S NAME, verbatim
    /// (R-13n-7: "the history reads as a cast of writers"; the app's voice,
    /// P-13n-1's boundary — sweepable at 13s-a).
    public static func mcpEditCommitNames(client: String) -> (before: String, after: String) {
        ("before \(client)'s edit", "after \(client)'s edit")
    }

    /// **`edit_take`'s act — THE EIGHTH QUIET AUTO-COMMIT OCCASION**
    /// (R-13n-7, insurance-class: always on, never governed by
    /// `savepoint_cadence`). ONE transaction: the caller's guard first; the
    /// take must be editable (live, active, unlocked, not under a seal —
    /// `editableVariant`'s refusals) and its buffer must still read EXACTLY
    /// `expectedText` (else `bufferChangedSinceGesture` — a client that read
    /// a stale take writes nothing). Then the bracket: a `kind='auto'` commit
    /// named "before <client>'s edit" of the text it is about to replace
    /// (deduped like the other occasions — none when the take's last commit
    /// already holds it), the write, and "after <client>'s edit" of the new
    /// text, stamped one millisecond later so the history's `(created_at,
    /// id)` order always reads before → after. Touch + churn exactly as any
    /// text edit (it IS one). A text equal to the buffer writes nothing — no
    /// commit, no entry.
    ///
    /// ONE undo entry, `undoLabel`: the buffer back to its pre-edit text
    /// (the fourth occasion insures a buffer she edited since), the redo the
    /// edit again — exact pre-images, never a re-run. The bracketing commits
    /// stay: commits are append-only (I5), and the history of what an AI did
    /// and she undid is hers to keep.
    @discardableResult
    public func editTakeUnderInsurance(
        _ variantID: String, text newText: String, expectedText: String, client: String,
        undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPTakeEdit {
        let names = Self.mcpEditCommitNames(client: client)
        let landed: (edit: MCPTakeEdit, preImage: TextPreImage?) = try database.write { db in
            try guardian?(db)
            var variant = try editableVariant(db, variantID)
            guard variant.workingText == expectedText else {
                throw OperationError.bufferChangedSinceGesture(variantID: variantID)
            }
            guard variant.workingText != newText else {
                return (MCPTakeEdit(take: variant, before: nil, after: nil, changed: false), nil)
            }
            let now = date.now
            let old = variant.workingText
            let before = try isDirty(db, variant)
                ? try insertCommit(db, variant: variant, kind: .auto, message: names.before, now: now)
                : nil
            variant.workingText = newText
            variant.updatedAt = now
            try variant.update(db)
            try registerTextChange(
                db, blockID: variant.blockId, charDelta: Self.churnCost(from: old, to: newText),
                forceMajorRevision: false, now: now)
            let after = try isDirty(db, variant)
                ? try insertCommit(
                    db, variant: variant, kind: .auto, message: names.after,
                    now: now.addingTimeInterval(0.001))
                : nil
            return (MCPTakeEdit(take: variant, before: before, after: after, changed: true),
                    TextPreImage(variantID: variantID, text: old, postOpText: newText))
        }
        if let preImage = landed.preImage {
            registerStructuralEntry(
                label: undoLabel,
                restoringTexts: [preImage],
                insuring: [preImage])
        }
        return landed.edit
    }

    /// An edit's churn (AppSpec §10): the inserted plus deleted UTF-16 units
    /// between the common prefix and suffix — the editor-reported delta's
    /// whole-buffer equivalent. ∝ the edit's text, never the note.
    static func churnCost(from old: String, to new: String) -> Int {
        let a = Array(old.utf16), b = Array(new.utf16)
        var prefix = 0
        while prefix < a.count, prefix < b.count, a[prefix] == b[prefix] { prefix += 1 }
        var suffix = 0
        while suffix < a.count - prefix, suffix < b.count - prefix,
              a[a.count - 1 - suffix] == b[b.count - 1 - suffix] { suffix += 1 }
        return (a.count - prefix - suffix) + (b.count - prefix - suffix)
    }

    // MARK: - EDIT: a block's name (R-13nb-8)

    /// **`set_block_name`'s act** — `setBlockName`'s rule exactly (nil or
    /// blank clears; no touch, no churn; refused under a seal; a no-op writes
    /// nothing) plus ONE undo entry, because EVERY MCP write registers one
    /// (P-13nb-U2-4): the old name back, the redo the new one — exact values,
    /// each only while the block still wears the other (VX-184 ladder round 1).
    /// Returns whether anything was written (a no-op registers nothing).
    @discardableResult
    public func setBlockName(
        _ blockID: String, name: String?, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Bool {
        let change: (old: String?, new: String?)? = try database.write { db in
            try guardian?(db)
            var block = try liveBlock(db, blockID)
            try ensurePlacementUnlocked(db, blockID: blockID)
            let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized = (trimmed?.isEmpty ?? true) ? nil : trimmed
            guard block.name != normalized else { return nil }
            let old = block.name
            block.name = normalized
            block.updatedAt = date.now
            try block.update(db)
            return (old, normalized)
        }
        guard let change else { return false }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreBlockName(blockID, from: change.new, to: change.old) },
            redo: { try $0.restoreBlockName(blockID, from: change.old, to: change.new) })
        return true
    }

    /// Both halves of the name entry, COMPARE-AND-SET (VX-184 ladder round 1 —
    /// the undo-overwrite class, brought to the U4/U5 rule): `to` only while
    /// the block is live and still wears `from`. A gone block, or a name she
    /// gave it since (her block-name door registers no entry), is the world
    /// moving past the entry (quiet); past that check, a sealed note refuses
    /// and keeps it (resolvable).
    @discardableResult
    func restoreBlockName(_ blockID: String, from: String?, to name: String?) throws -> Bool {
        try database.write { db in
            guard var block = try Block.fetchOne(db, key: blockID), block.deletedAt == nil,
                  block.name == from
            else { return false }
            try ensurePlacementUnlocked(db, blockID: blockID)
            block.name = name
            block.updatedAt = date.now
            try block.update(db)
            return true
        }
    }

    // MARK: - WRITE NEW: a chapter (R-13nb-11 G-1)

    /// **`create_section`'s act** — `createSection`'s rules exactly (a book,
    /// not a gathering; not finished; a non-blank name; at the chapter
    /// order's end) plus ONE undo entry (P-13nb-U2-4): the chapter tombstoned
    /// (memberships filed into it keep their pointer — a dangling one reads
    /// unsectioned, `deleteSection`'s doctrine), the redo the same row back.
    @discardableResult
    public func createSection(
        in readingID: String, name: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> ReadingSection {
        let section = try database.write { db in
            try guardian?(db)
            return try insertSection(db, in: readingID, name: name, at: .end)
        }
        let sectionID = section.id
        // VX-246 U2: the redo revives the chapter only on the stamp its own
        // undo wrote — her delete since (another stamp) is hers to keep.
        let undoneOn = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.tombstoneCreatedSection(sectionID) else { return false }
                undoneOn.setValue(stamp)
                return true
            },
            redo: { try $0.reviveCreatedSection(sectionID, undoneOn: undoneOn.value) })
        return section
    }

    /// The chapter entry's two halves: a reading gone, or the row already as
    /// asked, is quiet; a finished (locked) reading refuses and keeps the
    /// entry (the chapter-structure rule).
    /// The undo: the live chapter tombstoned; returns the stamp, nil when it
    /// was already gone (VX-246 U2 — a quiet half).
    func tombstoneCreatedSection(_ id: String) throws -> String? {
        try database.write { db in
            guard var section = try ReadingSection.fetchOne(db, key: id), section.deletedAt == nil,
                  let reading = try Reading.fetchOne(db, key: section.readingId), reading.deletedAt == nil
            else { return nil }
            guard !reading.locked else { throw OperationError.lockedReading(id: reading.id) }
            let now = date.now
            section.deletedAt = now
            section.updatedAt = now
            try section.update(db)
            return DateFormatter.variorumISO8601.string(from: now)
        }
    }

    /// The redo: the chapter back only while it is dead on `stamp` — the
    /// stamp its own undo wrote (VX-246 U2); returns whether it revived.
    @discardableResult
    func reviveCreatedSection(_ id: String, undoneOn stamp: String?) throws -> Bool {
        guard let stamp else { return false }
        return try database.write { db in
            guard var section = try ReadingSection.fetchOne(db, key: id),
                  section.deletedAt.map({ DateFormatter.variorumISO8601.string(from: $0) }) == stamp,
                  let reading = try Reading.fetchOne(db, key: section.readingId), reading.deletedAt == nil
            else { return false }
            guard !reading.locked else { throw OperationError.lockedReading(id: reading.id) }
            section.deletedAt = nil
            section.updatedAt = date.now
            try section.update(db)
            return true
        }
    }

    // MARK: - EDIT: divide and merge, as her keyboard composes them

    /// What `divideBlock` did.
    public struct MCPDivideResult: Equatable, Sendable {
        /// The block holding the first half (the source itself on a
        /// single-take divide; the fresh B on a fanned one).
        public let firstBlockID: String
        public let secondBlockID: String
        /// Other takes that rode WHOLE onto the first block (keep-on-top).
        public let keptOnTop: Int
        /// Empty takes that could not park and stayed on the original block
        /// in lineage (`KeepOnTopDivide.unparkable` — said, never swallowed).
        public let stayedBehind: Int
    }

    /// **`divide_block`'s act — her divide door's composition**: a block
    /// with one take divides in place (`divide`); a FANNED block divides
    /// keep-on-top (U-2: the shown take splits, every other take rides
    /// whole onto the first block — `KeepOnTopDivide` over `divideW`). `cut`
    /// is a UTF-16 offset into `shownTakeID`'s text, which the caller
    /// measured as `expectedText`: the guard re-checks the WHOLE composition
    /// inside the act's transaction — that text, the take still rendered,
    /// and the fan's membership and texts the arrangement was built from
    /// (U3 ladder round 1, F2; anything moved refuses as
    /// `bufferChangedSinceGesture`, never a cut in the wrong place). The
    /// ops' own refusals ride (start/end cuts, a sealed note, a locked take).
    /// ONE undo entry, `undoLabel`.
    public func divideBlock(
        _ blockID: String, cut: Int, shownTakeID: String, expectedText: String,
        undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPDivideResult {
        let fan = try database.read { db in try liveActiveFan(db, blockID: blockID) }
        let measured: WriteGuard = { db in
            try guardian?(db)
            // THE COMPOSITION's premises, re-verified on the act's own rows
            // (U3 ladder round 1, F2 — the expectedText precondition class,
            // widened to everything the arrangement was built from): the fan
            // it composed over, ids AND texts — a parked cut is POSITIONAL,
            // its take's old length — and the measured take still this
            // block's RENDERED take. Only a sync apply can land between the
            // read and this transaction (the serial body); when one did,
            // ONE honest refusal, never a cut in a place nobody chose.
            let current = try liveActiveFan(db, blockID: blockID)
            guard current.map(\.id) == fan.map(\.id),
                  current.map(\.workingText) == fan.map(\.workingText),
                  let shown = try? renderedVariant(db, blockID: blockID),
                  shown.id == shownTakeID, shown.workingText == expectedText
            else { throw OperationError.bufferChangedSinceGesture(variantID: shownTakeID) }
        }
        if fan.count <= 1 {
            let result = try registeringUndo(as: undoLabel) {
                try divide(blockID, cut: cut, guardedBy: measured)
            }
            return MCPDivideResult(
                firstBlockID: blockID, secondBlockID: result.block.id, keptOnTop: 0, stayedBehind: 0)
        }
        guard let composition = KeepOnTopDivide.compose(displayedID: shownTakeID, cut: cut, fan: fan) else {
            throw OperationError.bufferChangedSinceGesture(variantID: shownTakeID)
        }
        let result = try registeringUndo(as: undoLabel) {
            try divideW(
                blockID, cuts: composition.cuts, displayedVariantID: composition.displayedID,
                guardedBy: measured)
        }
        return MCPDivideResult(
            firstBlockID: result.first.block.id, secondBlockID: result.second.block.id,
            keptOnTop: max(0, result.first.variants.count - 1),
            stayedBehind: composition.unparkable.count)
    }

    /// What `mergeBlocks` did.
    public struct MCPMergeResult: Equatable, Sendable {
        /// The fresh merged block A′ (the sources stay as lineage).
        public let blockID: String
        /// Other takes carried whole onto A′ (the carry-all merge).
        public let carried: Int
    }

    /// **`merge_blocks`'s act — her ⌘⇧M composition**: two blocks with one
    /// take each merge by the instant `merge` (the rendering join, R-13u4-3);
    /// where either carries a fan, the CARRY-ALL merge (`CarryAllMerge` over
    /// `mergeCeremony` — the two shown takes paired, every other take carried
    /// whole). Adjacency, seals and the rest are the ops' own refusals. A
    /// shown take that vanished from its fan since the read refuses as
    /// `bufferChangedSinceGesture` (the 13d F-3 class — never a fallback),
    /// and the guard re-verifies both fans' membership and both shown takes
    /// inside the act's transaction (U3 ladder round 1, F2).
    /// ONE undo entry, `undoLabel`.
    public func mergeBlocks(
        _ firstBlockID: String, _ secondBlockID: String,
        undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPMergeResult {
        let (leadingFan, trailingFan, leadingShown, trailingShown) = try database.read { db in
            (try liveActiveFan(db, blockID: firstBlockID), try liveActiveFan(db, blockID: secondBlockID),
             try? renderedVariant(db, blockID: firstBlockID).id, try? renderedVariant(db, blockID: secondBlockID).id)
        }
        let measured: WriteGuard = { db in
            try guardian?(db)
            // THE COMPOSITION's premises, re-verified on the act's own rows
            // (U3 ladder round 1, F2): both fans' MEMBERSHIP (which road —
            // plain or carry-all — and which takes pair and carry) and both
            // SHOWN takes still their block's rendered one. Texts need no
            // check here — the ops read them inside this same transaction.
            // A sync apply landing in the window refuses honestly instead of
            // leaving its take behind in silence or pairing takes she was
            // never looking at. An empty side passes through: the op's own
            // typed refusal is the honest diagnosis there (the chain's rule).
            let leadingNow = try liveActiveFan(db, blockID: firstBlockID)
            let trailingNow = try liveActiveFan(db, blockID: secondBlockID)
            guard leadingNow.map(\.id) == leadingFan.map(\.id),
                  trailingNow.map(\.id) == trailingFan.map(\.id),
                  (try? renderedVariant(db, blockID: firstBlockID))?.id == leadingShown,
                  (try? renderedVariant(db, blockID: secondBlockID))?.id == trailingShown
            else { throw OperationError.bufferChangedSinceGesture(variantID: leadingShown ?? firstBlockID) }
        }
        if leadingFan.count <= 1, trailingFan.count <= 1 {
            let result = try registeringUndo(as: undoLabel) {
                try merge(firstBlockID, secondBlockID, guardedBy: measured)
            }
            return MCPMergeResult(blockID: result.block.id, carried: 0)
        }
        guard let composition = CarryAllMerge.compose(
            leadingDisplayedID: leadingShown, leadingFan: leadingFan,
            trailingDisplayedID: trailingShown, trailingFan: trailingFan)
        else { throw OperationError.bufferChangedSinceGesture(variantID: leadingShown ?? firstBlockID) }
        let result = try registeringUndo(as: undoLabel) {
            try mergeCeremony(
                firstBlockID, secondBlockID, pairings: [composition.pairing],
                carries: composition.carries, guardedBy: measured)
        }
        return MCPMergeResult(blockID: result.block.id, carried: composition.carries.count)
    }

    /// A block's live ACTIVE fan in fan order — read from the STORE (the 13d
    /// discipline: the compositions are authorized by store reads, never a
    /// projection).
    func liveActiveFan(_ db: Database, blockID: String) throws -> [Variant] {
        try Variant.fetchAll(
            db,
            sql: """
                SELECT * FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY fan_position, id
                """,
            arguments: [blockID])
    }
}
