//
//  UnusedTagsTests.swift
//  VariorumCoreTests
//
//  VX-840 (the VX-828 run, batch E) — Settings ▸ Tags' door to delete every
//  tag no note wears. Her ask (2026-11-04), verbatim: *"file a ticket to be
//  able to delete every tag that's not on a note currently please"*. The
//  fork's ruling: `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch E —
//  THE FORK'S RULING" (Q-E1 (a) the vendored brain, P-828-4 one combined
//  entry, Q-E3 (i) the linked boxes, Q-E4 (a) the counted door).
//
//  What these pin, exact rows throughout:
//  · the listing (`Queries.unusedTags`) — vx-809's ONE brain
//    (`tagSubtreeIsWorn`, `.library(countingTrashRevivable: true)`) read for
//    every tag of a wing: a live wearer (a note, a block in a note, a
//    snippet) keeps a tag off the list; so does a wearer in the Trash
//    (P-828-3 — a restore would bring the application back); an application
//    she removed does not; the subtree decides; each wing lists its own;
//  · the held observation's named region, complete and column-narrow;
//  · the act (`Operations.deleteUnusedTags`) — one write, one stamp, ONE undo
//    entry "Delete Unused Tags" that undoes and redoes whole; confirmed ∩
//    still-unused, subtree-aware, decided inside the write; nothing left ⇒
//    nothing written.
//
//  An Improvement, not a bug: the old tree had no listing and no act, so no
//  red-on-old exists. The mutation probes M-E1…M-E3 in the record show which
//  clauses these pins hold.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// MARK: - Helpers

private func unusedPaths(_ db: AppDatabase, wing: String = "") throws -> [String] {
    try db.read { try Queries.unusedTags($0, wingID: wing).map(\.path) }
}

private func livePaths(_ db: AppDatabase) throws -> [String] {
    try db.read {
        try String.fetchAll($0, sql: "SELECT path FROM tag WHERE deleted_at IS NULL ORDER BY path")
    }
}

@Suite("VX-840 — the wing's unused tags and the one-act sweep")
struct UnusedTagsTests {
    // MARK: - The listing

    /// Every way a tag can be worn, and the ways it is not. A tag wearing
    /// nothing lists; a live note, a block in a note and a snippet each keep
    /// theirs off; a wearer in the Trash keeps it too (P-828-3); an
    /// application she removed does not — even when the note goes to the
    /// Trash after (no restore brings back what she removed before it).
    @Test func whatIsWornOrRevivableNeverLists() throws {
        try withOperations { ops, db in
            let fresh = try ops.createTag(name: "fresh")
            let onNote = try ops.createTag(name: "on-note")
            let onBlock = try ops.createTag(name: "on-block")
            let onSnippet = try ops.createTag(name: "on-snippet")
            let removed = try ops.createTag(name: "removed")
            let inTrash = try ops.createTag(name: "in-trash")
            let blockInTrash = try ops.createTag(name: "block-in-trash")
            let removedThenTrashed = try ops.createTag(name: "removed-then-trashed")
            _ = fresh

            let note = try ops.createPost(title: "kept")
            _ = try ops.applyTag(onNote.id, toPost: note.id)
            let block = try ops.seedBlock(in: note.id, text: "a block").block.id
            _ = try ops.applyTag(onBlock.id, toBlock: block)
            let pool = try ops.createPool()
            let snippet = try ops.seedBlock(in: pool.id, text: "a snippet").block.id
            _ = try ops.applyTag(onSnippet.id, toBlock: snippet)
            _ = try ops.applyTag(removed.id, toPost: note.id)
            try ops.removeTag(removed.id, fromPost: note.id)

            let trashed = try ops.createPost(title: "trashed")
            _ = try ops.applyTag(inTrash.id, toPost: trashed.id)
            _ = try ops.applyTag(removedThenTrashed.id, toPost: trashed.id)
            try ops.removeTag(removedThenTrashed.id, fromPost: trashed.id)
            try ops.deleteContainer(trashed.id)

            let trashedBlock = try ops.seedBlock(in: note.id, text: "gone").block.id
            _ = try ops.applyTag(blockInTrash.id, toBlock: trashedBlock)
            try ops.deleteBlock(trashedBlock)

            #expect(try unusedPaths(db) == ["fresh", "removed", "removed-then-trashed"],
                    "worn (live or Trash-revivable) tags never list; removed applications don't wear")

            // Put back: the trashed note's tag is worn by a live note again —
            // still not listed; the one she removed before the trash stays unused.
            try ops.restoreContainer(trashed.id)
            #expect(try unusedPaths(db) == ["fresh", "removed", "removed-then-trashed"])
            // Removing the last live wearer lists it.
            try ops.removeTag(onNote.id, fromPost: note.id)
            #expect(try unusedPaths(db) == ["fresh", "on-note", "removed", "removed-then-trashed"])
        }
    }

    /// The SUBTREE decides (deleteTag's own rule — vx-809's brain is
    /// subtree-honest): a parent over a worn child is worn; a worn parent's
    /// unused child lists alone; an unused root lists with its whole subtree.
    /// The listing's shortcut (an unused tag's subtree is unused — asked once)
    /// gives exactly the brain's answer for every tag.
    @Test func theSubtreeDecides() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            _ = try ops.createTag(parent: life.id, name: "dreams")
            let work = try ops.createTag(name: "work")
            let old = try ops.createTag(parent: work.id, name: "old")
            _ = try ops.createTag(parent: old.id, name: "x")
            let home = try ops.createTag(name: "home")
            _ = try ops.createTag(parent: home.id, name: "den")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(goals.id, toPost: note.id)
            _ = try ops.applyTag(home.id, toPost: note.id)

            #expect(try unusedPaths(db)
                    == ["home/den", "life/dreams", "work", "work/old", "work/old/x"])
            // Tag by tag, the brain agrees with the listing.
            try db.read { database in
                let listed = Set(try Queries.unusedTags(database, wingID: "").map(\.id))
                for tag in try Queries.allTags(database, wingID: "") {
                    let worn = try Queries.tagSubtreeIsWorn(
                        database, tagID: tag.id, scope: .library(countingTrashRevivable: true))
                    #expect(listed.contains(tag.id) == !worn, "\(tag.path)")
                }
            }
        }
    }

    /// The vocabulary is per wing: each wing lists its own unused tags — a
    /// same-path twin in another wing is another tag.
    @Test func eachWingListsItsOwn() throws {
        try withOperations { ops, db in
            let far = try ops.createWing(name: "Far")
            let homeA = try ops.createTag(name: "a")
            let farA = try ops.createTag(name: "a", wingID: far.id)
            let farB = try ops.createTag(name: "b", wingID: far.id)
            let farNote = try ops.createPost(title: "far", wingId: far.id)
            _ = try ops.applyTag(farB.id, toPost: farNote.id)

            let home = try db.read { try Queries.unusedTags($0, wingID: "") }
            let away = try db.read { try Queries.unusedTags($0, wingID: far.id) }
            #expect(home.map(\.id) == [homeA.id])
            #expect(away.map(\.id) == [farA.id], "Far's own unused twin; its worn b is off")
        }
    }

    // MARK: - The held observation's region

    /// COMPLETE: every column of every table the read touches — across every
    /// arm (a worn tag answers on the live arm, an unused one runs the Trash
    /// arm too; Home's scope reads `wing`) — is in the named region.
    /// NARROW: the keystroke-rate writes (a note's touch and churn stamps, a
    /// block's `updated_at`, any take) never wake it; a trash, a restore or an
    /// application write does.
    @Test func theRegionHoldsEverythingTheReadTouchesAndNoKeystroke() throws {
        try withOperations { ops, db in
            let far = try ops.createWing(name: "Far")
            let worn = try ops.createTag(name: "worn")
            _ = try ops.createTag(name: "idle")
            let blockWorn = try ops.createTag(name: "block-worn")
            _ = try ops.createTag(name: "far-idle", wingID: far.id)
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(worn.id, toPost: note.id)
            let block = try ops.seedBlock(in: note.id, text: "b").block.id
            _ = try ops.applyTag(blockWorn.id, toBlock: block)

            try db.read { database in
                let captured = LockIsolated<[String]>([])
                let capturing = LockIsolated(true)
                database.trace(options: .statement) { event in
                    guard capturing.value, case .statement(let statement) = event else { return }
                    let sql = statement.sql
                    captured.withValue { $0.append(sql) }
                }
                for wingID in ["", far.id] {
                    _ = try Queries.unusedTags(database, wingID: wingID)
                }
                capturing.setValue(false)
                var derived = DatabaseRegion()
                for sql in captured.value {
                    derived = derived.union(try database.makeStatement(sql: sql).databaseRegion)
                }
                var named = DatabaseRegion()
                for region in Queries.unusedTagRegions() {
                    named = named.union(try region.databaseRegion(database))
                }

                let tables = try String.fetchAll(
                    database,
                    sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
                for table in tables {
                    let columns = try database.columns(in: table).map(\.name)
                    for column in columns {
                        let event = DatabaseEventKind.update(tableName: table, columnNames: [column])
                        if derived.isModified(byEventsOfKind: event) {
                            #expect(named.isModified(byEventsOfKind: event),
                                    "read but not named: \(table).\(column)")
                        }
                    }
                    for event in [DatabaseEventKind.insert(tableName: table), .delete(tableName: table)]
                    where derived.isModified(byEventsOfKind: event) {
                        #expect(named.isModified(byEventsOfKind: event), "read but not named: \(event)")
                    }
                }

                // Narrow: what a keystroke writes never wakes it.
                for (table, column) in [
                    ("container", "last_touched_at"), ("container", "churn_accumulator"),
                    ("container", "baseline_length"), ("container", "updated_at"), ("container", "title"),
                    ("block", "updated_at"), ("wing", "name"),
                ] {
                    #expect(!named.isModified(byEventsOfKind: .update(tableName: table, columnNames: [column])),
                            "\(table).\(column) never wakes the count")
                }
                for event in [DatabaseEventKind.insert(tableName: "variant"),
                              .update(tableName: "variant", columnNames: ["working_text"])] {
                    #expect(!named.isModified(byEventsOfKind: event), "a take's writes never wake it")
                }
                // …and what changes the answer does.
                for event in [
                    DatabaseEventKind.update(tableName: "container", columnNames: ["deleted_at"]),
                    .update(tableName: "block", columnNames: ["deleted_at"]),
                    .insert(tableName: "post_tag"), .insert(tableName: "block_tag"),
                    .update(tableName: "post_tag", columnNames: ["deleted_at"]),
                    .delete(tableName: "container"), .insert(tableName: "tag"),
                ] {
                    #expect(named.isModified(byEventsOfKind: event), "\(event) wakes it")
                }
            }
        }
    }

    // MARK: - The act (P-828-4: ONE combined entry)

    /// The checked unused tags go in ONE write on ONE stamp with ONE undo
    /// entry, "Delete Unused Tags"; ⌥⌘Z brings every one back — paths whole —
    /// and the redo takes exactly them again. A worn tag is untouched.
    @Test func oneActOneStampOneEntryThatUndoesAndRedoesWhole() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let c = try ops.createTag(parent: b.id, name: "c")
            let w = try ops.createTag(name: "w")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(w.id, toPost: note.id)
            stack.removeAll()

            let listed = try db.read { try Queries.unusedTags($0, wingID: "") }
            #expect(listed.map(\.id) == [a.id, b.id, c.id])

            let taken = try ops.deleteUnusedTags(listed.map(\.id))
            #expect(taken == [a.id, b.id, c.id], "every checked tag, path order")
            #expect(try livePaths(db) == ["w"])
            let stamps = try db.read {
                Set(try String.fetchAll(
                    $0, sql: "SELECT deleted_at FROM tag WHERE id IN (?, ?, ?)", arguments: [a.id, b.id, c.id]))
            }
            #expect(stamps.count == 1, "ONE stamp across every root")
            #expect(stack.depth == 1, "ONE entry for the one act")
            #expect(stack.topLabel == Operations.deleteUnusedTagsUndoLabel)
            #expect(stack.topLabel == "Delete Unused Tags")

            let undone = try stack.undoReporting(with: ops)
            #expect(undone == UndoStack.Outcome(label: "Delete Unused Tags", changed: true))
            #expect(try livePaths(db) == ["a", "b", "b/c", "w"], "one ⌥⌘Z brings them all back, paths whole")
            #expect(stack.depth == 0 && stack.redoDepth == 1)

            let redone = try stack.redoReporting(with: ops)
            #expect(redone == UndoStack.Outcome(label: "Delete Unused Tags", changed: true))
            #expect(try livePaths(db) == ["w"], "the redo takes exactly them again")
            #expect(stack.depth == 1 && stack.redoDepth == 0)

            // The single delete keeps its own words.
            try ops.deleteTag(w.id)
            #expect(stack.topLabel == "Delete Tag")
        }
    }

    /// Confirmed ∩ still-unused, subtree-aware, decided INSIDE the write. In
    /// the pause between the sheet and the press: `a` was applied to a note
    /// (worn); `f`'s only wearer went to the Trash (revivable — worn); `b`
    /// gained a child she never saw (so `b` stays — the act never deletes
    /// more than the sheet showed — while its confirmed child `b/c` goes);
    /// and `d` was confirmed without its child (the linked boxes never send
    /// that; the op holds anyway — `d` stays, and the unconfirmed `d/e`).
    @Test func theActTakesOnlyWhatTheSheetShowedThatIsStillUnused() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let c = try ops.createTag(parent: b.id, name: "c")
            let d = try ops.createTag(name: "d")
            _ = try ops.createTag(parent: d.id, name: "e")
            let f = try ops.createTag(name: "f")
            let g = try ops.createTag(name: "g")
            let confirmed = [a.id, b.id, c.id, d.id, f.id, g.id]

            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(a.id, toPost: note.id)
            let gone = try ops.createPost(title: "gone")
            _ = try ops.applyTag(f.id, toPost: gone.id)
            try ops.deleteContainer(gone.id)
            _ = try ops.createTag(parent: b.id, name: "new")

            let taken = try ops.deleteUnusedTags(confirmed)
            #expect(taken == [c.id, g.id], "only the confirmed tags still unused with wholly-confirmed subtrees")
            #expect(try livePaths(db) == ["a", "b", "b/new", "d", "d/e", "f"])
        }
    }

    /// Nothing left to take ⇒ nothing written: no tag row, no outbox entry,
    /// no undo entry — the door speaks the refusal from the empty answer.
    @Test func nothingLeftWritesNothing() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let x = try ops.createTag(name: "x")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(x.id, toPost: note.id)
            stack.removeAll()
            try db.clearOutbox()

            #expect(try ops.deleteUnusedTags([x.id]).isEmpty, "x is worn now")
            #expect(try ops.deleteUnusedTags([]).isEmpty)
            #expect(try ops.deleteUnusedTags(["no-such-tag"]).isEmpty)
            #expect(try livePaths(db) == ["x"])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0, "not a row written")
            #expect(stack.depth == 0, "no entry for an act that did nothing")
        }
    }
}
