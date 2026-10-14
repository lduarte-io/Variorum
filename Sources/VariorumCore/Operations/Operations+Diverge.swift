//
//  Operations+Diverge.swift
//  VariorumCore
//
//  Phase 13f, batch 5 (W23) — DIVERGE FOR THIS BOOK, her round-10 ruling:
//
//  > *"'duplicate as version' should be a button you can click, not just an
//  > FYI (it seems a bit annoying to get the FYI but not have a button that
//  > nicely duplicates it as version and deletes the original for you all in
//  > one go - accessible from a menu maybe…)"*
//
//  The architect's parse, ratified: **"deletes the original" means removes it
//  from THIS BOOK only.** The copy takes the original's exact slot here — its
//  `position` AND its chapter assignment — and the original lives on in its
//  other books and in the library. Deleting it globally would gut them, which
//  is the standing chip "remove" wording's own rule.
//
//  ── WHY THIS IS AN OPERATION AND NOT AN APP-LAYER COMPOSITION ────────────
//  The batch's stop-and-propose found the reason. `duplicateAsVersion`
//  registers an exact-row inverse; **no reading-membership op registers
//  anything** (`addPostToReading` / `assignPostToSection` /
//  `removePostFromReading` are all in the no-undo-entry class). Composed at
//  the app layer under `withCompound`, the resulting entry's inverse would be
//  the mint's alone: undo would un-mint the copy and leave the ORIGINAL still
//  removed from the book — a half-undo presented as a whole one, and a book
//  silently short one post. `UndoStack.register` is internal to this module,
//  so the app cannot supply the missing inverse, and a view that supplied one
//  would be holding a business rule (CLAUDE.md). So the composite lives here,
//  where every mutation belongs, and registers ONE entry whose inverse AND
//  redo are built from do-time pre-images. **It adds no new SEMANTICS** — it
//  writes exactly the rows the standing paths write.
//
//  Composition note (the standing pattern, `newPostInReading`'s): the public
//  membership ops each open their own `database.write`, so a composite cannot
//  call them without nesting transactions. It inlines their guards and their
//  writes instead — same rules, one transaction.
//

import Dependencies
import Foundation
import GRDB

extension Operations {
    /// What a diverge minted and moved, for callers and the row-level pins.
    public struct DivergeResult: Equatable, Sendable {
        /// The fresh version-post — the one this book shows from now on.
        public let copy: PostCopyResult
        /// The membership row minted for the copy, at the original's slot.
        public let copyMembershipID: String
        /// The original's membership row, now tombstoned (undo revives it).
        public let originalMembershipID: String
    }

    /// Diverge `postID` for `readingID`: mint a full version copy, give it the
    /// original's EXACT slot in this book (position and `section_id`), and
    /// take the original out of this book — one transaction, one undo entry.
    ///
    /// **Refusals, all the standing ones, delivered as the ops layer's own:**
    /// a SMART book refuses (`wrongReadingKind`) — derived membership has no
    /// row to swap, and the road there is the tag, which 13i owns; a FINISHED
    /// book refuses (`lockedReading` — membership is frozen, #25's letter); a
    /// post that is not in the book refuses (`postNotInReading`).
    ///
    /// **Capacity is deliberately NOT gated.** The swap is net-zero — one
    /// membership in, one out — so `addPostToReading`'s at-capacity refusal
    /// would refuse an act that does not grow the book. Recorded rather than
    /// silently true.
    ///
    /// The copy is the `duplicateAsVersion` copy exactly (whole live fans,
    /// archived takes riding with statuses preserved, commits never copied,
    /// parent trees remapped, block names and presentations copied, per-block
    /// `derived_from` edges plus ONE `version_of` anchor); tags, references
    /// and lenses do not ride, as in every copy.
    @discardableResult
    public func divergePostForReading(
        _ postID: String, in readingID: String
    ) throws -> DivergeResult {
        let result: DivergeResult = try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var original = try liveMembership(db, postID: postID, readingID: readingID)
            else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }

            let copy = try copyPost(db, sourceID: postID, chosenPicks: nil, carryFans: true)

            // THE EXACT SLOT: the copy inherits the original's position and
            // its chapter. Position is copied verbatim rather than computed —
            // `(position, id)` is the sort key, and the original's row leaves
            // in this same transaction, so nothing is ever ambiguous.
            let now = date.now
            let membership = ReadingPost(
                id: newID(), readingId: readingID, postId: copy.post.id,
                position: original.position,
                sectionId: original.sectionId,
                createdAt: now)
            try membership.insert(db)

            original.deletedAt = now
            try original.update(db)

            return DivergeResult(
                copy: copy, copyMembershipID: membership.id,
                originalMembershipID: original.id)
        }
        let copyID = result.copy.post.id
        let copyMembershipID = result.copyMembershipID
        let originalMembershipID = result.originalMembershipID
        // VX-246 U2: the undo records what it did (the stamp, and which of its
        // three rows it moved); the redo re-applies only those, the copy only
        // while it is still dead on that stamp — a copy she deleted herself
        // before the undo is hers, and the redo never brings it back.
        let undone = LockIsolated<DivergeUndone?>(nil)
        undoStack?.register(
            label: "Diverge for This Book",
            inverse: {
                let did = try $0.revertDiverge(
                    copyID: copyID, copyMembershipID: copyMembershipID,
                    originalMembershipID: originalMembershipID)
                undone.setValue(did)
                return did != nil
            },
            redo: {
                try $0.reapplyDiverge(
                    copyID: copyID, copyMembershipID: copyMembershipID,
                    originalMembershipID: originalMembershipID, undone: undone.value)
            })
        return result
    }

    // MARK: - The two halves of the undo entry

    /// The inverse: the original comes back to its own row (it still carries
    /// its position and chapter — nothing ever rewrote them), the copy's
    /// membership goes, and the copy itself is tombstoned. Exact-row on
    /// do-time ids, like every inverse in this layer.
    ///
    /// Refusal buckets, the standing ones: a book deleted meanwhile ⇒
    /// obsolete, quiet (its cascade already took the memberships); a book
    /// FINISHED meanwhile ⇒ throws, so the entry stays on the stack for a
    /// retry after un-finishing.
    ///
    /// **13i-d U6 ACT 0 (F-U5b-2, RULED (a)):** the original's row would
    /// revive into a book in ANOTHER WING (the book moved after the diverge —
    /// the copy rode as its member, the original stayed behind) ⇒ obsolete,
    /// quiet, NOTHING written: the deleted bucket's shape, checked before any
    /// write and before the finished throw (re-opening cannot heal a
    /// crossing, so a retry-throw would wedge the stack). A half-undo — the
    /// copy out, the original not back — would leave the book short a note;
    /// a book never spans wings (§9).
    /// What a diverge's undo did (VX-246 U2): its stamp, and which rows.
    struct DivergeUndone: Sendable {
        let stamp: String
        var copyRow = false
        var original = false
        var copy = false
    }

    /// Returns what it did — nil when it changed nothing (quiet).
    func revertDiverge(
        copyID: String, copyMembershipID: String, originalMembershipID: String
    ) throws -> DivergeUndone? {
        try database.write { db in
            // ONE fetch serves the guard and the flip (13f cold review,
            // R1-6 — the row was fetched twice for no reason).
            guard var copyRow = try ReadingPost.fetchOne(db, key: copyMembershipID),
                  let reading = try Reading.fetchOne(db, key: copyRow.readingId),
                  reading.deletedAt == nil
            else { return nil }
            if let originalRow = try ReadingPost.fetchOne(db, key: originalMembershipID),
               originalRow.deletedAt != nil,
               try postIsLive(db, originalRow.postId),
               try !Queries.membershipRevivalStaysInOneWing(
                   db, postID: originalRow.postId, readingID: copyRow.readingId) {
                return nil
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: copyRow.readingId)
            }
            let now = date.now
            var did = DivergeUndone(stamp: DateFormatter.variorumISO8601.string(from: now))
            if copyRow.deletedAt == nil {
                copyRow.deletedAt = now
                try copyRow.update(db)
                did.copyRow = true
            }
            // The original's row revives with its slot intact — the swap
            // never rewrote its position or its `section_id`, which is what
            // makes this a tombstone flip rather than a re-computation.
            if var originalRow = try ReadingPost.fetchOne(db, key: originalMembershipID),
               originalRow.deletedAt != nil,
               try postIsLive(db, originalRow.postId) {
                originalRow.deletedAt = nil
                try originalRow.update(db)
                // 13i-c U2 (the 13i-c plan §4 row 9's family): the undo
                // REVIVES the original's membership — a note claimed by an
                // owned book since the diverge keeps its earliest
                // membership; R2's shape, applied locally.
                try enforceOwnershipAfterRevival(
                    db, postIDs: [originalRow.postId], now: now)
                did.original = true
            }
            if var container = try Container.fetchOne(db, key: copyID),
               container.deletedAt == nil {
                container.deletedAt = now
                container.updatedAt = now
                try container.update(db)
                did.copy = true
            }
            return did.copyRow || did.original || did.copy ? did : nil
        }
    }

    /// The RE-APPLY (13c 1B's contract: exact-row, never a re-run of the
    /// forward operation — re-running would mint a fresh copy with fresh
    /// UUIDs and strand the inverse's captured ids).
    ///
    /// **The copy comes back through `restoreContainer` (13f cold review,
    /// R1-1 — the fix).** The inverse's tombstone CASCADED: the copy's
    /// placements, blocks and variants all died with the container's exact
    /// stamp (`cascade_container_tombstone`), and no dead→live cascade
    /// exists — restores are the operations layer's. Flipping only the
    /// container row therefore left a live but EMPTY note in the book, its
    /// text stranded in rows no surface lists (cascade victims are excluded
    /// from the tray by the stamp rule; the recovery list shows deleted
    /// containers, and this one was live). `restoreContainer`'s exact-stamp
    /// cascade contract is precisely the reverse of what the inverse wrote —
    /// the same reason `reapplyMintedContainer` rides it. It revives the
    /// copy's MEMBERSHIP row too (the inverse stamped it with the same
    /// `now`); the flip below covers the copy that was independently
    /// restored meanwhile, whose membership carries this entry's stamp but
    /// whose container does not.
    ///
    /// Like `reapplyMintedContainer`, this is a guarded composite rather
    /// than one transaction (`restoreContainer` opens its own write); the
    /// guard-then-restore window is the headless sub-ms class, recorded
    /// rather than papered over.
    ///
    /// VX-246 U2: re-applies only what `undone` says its undo did — the copy
    /// back only while it is dead on the undo's own stamp, the copy's row
    /// only while dead on it, the original's row out again only if the undo
    /// brought it back. Returns whether it re-applied anything.
    @discardableResult
    func reapplyDiverge(
        copyID: String, copyMembershipID: String, originalMembershipID: String,
        undone: DivergeUndone?
    ) throws -> Bool {
        guard let undone else { return false }
        func onTheUndo(_ deletedAt: Date?) -> Bool {
            deletedAt.map { DateFormatter.variorumISO8601.string(from: $0) } == undone.stamp
        }
        // Guards first, read-only: a book deleted meanwhile ⇒ obsolete,
        // quiet (its cascade already took the memberships); FINISHED
        // meanwhile ⇒ throws, so the entry stays on the stack for a retry.
        //
        // 13i-d U6 ACT 0 (F-U5b-2, RULED (a) — the sibling the grep found):
        // the copy's row would revive into a book in ANOTHER WING (the book
        // moved after the undo — the original rode as its member, the dead
        // copy stayed behind) ⇒ obsolete, quiet, nothing written — before
        // `restoreContainer` (which would bring the copy back bookless) and
        // before the original's row is taken (a half-redo would leave the
        // book short a note). Checked ahead of the finished throw, as in the
        // inverse.
        let copyStillDead: Bool? = try database.read { db in
            guard let membership = try ReadingPost.fetchOne(db, key: copyMembershipID),
                  let reading = try Reading.fetchOne(db, key: membership.readingId),
                  reading.deletedAt == nil
            else { return nil }
            if membership.deletedAt != nil,
               try !Queries.membershipRevivalStaysInOneWing(
                   db, postID: copyID, readingID: membership.readingId) {
                return nil
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: membership.readingId)
            }
            guard undone.copy else { return false }
            return onTheUndo(try Container.fetchOne(db, key: copyID)?.deletedAt)
        }
        guard let copyStillDead else { return false }
        if copyStillDead {
            try restoreContainer(copyID)
        }
        let rows = try database.write { db -> Bool in
            let now = date.now
            var wrote = false
            if undone.original,
               var originalRow = try ReadingPost.fetchOne(db, key: originalMembershipID),
               originalRow.deletedAt == nil {
                originalRow.deletedAt = now
                try originalRow.update(db)
                wrote = true
            }
            if undone.copyRow || undone.copy,
               var copyRow = try ReadingPost.fetchOne(db, key: copyMembershipID),
               onTheUndo(copyRow.deletedAt), try postIsLive(db, copyRow.postId) {
                copyRow.deletedAt = nil
                try copyRow.update(db)
                // 13i-c U2 (row 9): the redo REVIVES the copy's membership.
                try enforceOwnershipAfterRevival(db, postIDs: [copyRow.postId], now: now)
                wrote = true
            }
            return wrote
        }
        return copyStillDead || rows
    }

    /// `restoreReading`'s live-parent guard, shared: a live membership row
    /// pointing at a dead post helps nobody.
    private func postIsLive(_ db: Database, _ postID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM container WHERE id = ? AND deleted_at IS NULL)",
            arguments: [postID]) ?? false
    }
}
