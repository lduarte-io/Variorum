import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-247 — `deleteTag` JOINS AppSpec §9's structural-undo list** (her
/// ruling 2026-10-13, QUESTIONS #217: "adding an undo to the tag delete could
/// be a quick ticket before launch… that fits with being able to undo AI
/// actions with one command"). ONE entry, "Delete Tag": the inverse revives
/// the subtree's tags and their applications dead on the delete's EXACT
/// stamp; the redo re-applies exactly what the undo revived; a half that
/// finds nothing of its partner's result is QUIET and retires its entry
/// (VX-246 U2).
///
/// RED ON OLD by construction (the marked pins): before VX-247 `deleteTag`
/// registered nothing, so the stack was empty after the delete and ⌥⌘Z
/// reached past it to whatever came before.
@Suite("deleteTag's structural undo (VX-247)")
struct TagDeleteUndoTests {
    /// `life` ⊃ `life/goals` ⊃ `life/goals/2024`, a sibling `work`, and
    /// applications: `life` on note A, `life/goals` on note B, `2024` on a
    /// block of note A, `work` on note B — plus a `life/goals` application on
    /// note C that she REMOVED before the delete (its own stamp).
    private struct World {
        let life: VariorumCore.Tag, goals: VariorumCore.Tag, year: VariorumCore.Tag, work: VariorumCore.Tag
        let a: Container, b: Container, c: Container
        let block: String
        let removedEarlier: String
    }

    private func world(_ ops: Operations) throws -> World {
        let life = try ops.createTag(name: "life")
        let goals = try ops.createTag(parent: life.id, name: "goals")
        let year = try ops.createTag(parent: goals.id, name: "2024")
        let work = try ops.createTag(name: "work")
        let a = try ops.createPost(title: "a")
        let b = try ops.createPost(title: "b")
        let c = try ops.createPost(title: "c")
        let block = try ops.newBlock(in: a.id, text: "a block").block.id
        _ = try ops.applyTag(life.id, toPost: a.id)
        _ = try ops.applyTag(goals.id, toPost: b.id)
        _ = try ops.applyTag(year.id, toBlock: block)
        _ = try ops.applyTag(work.id, toPost: b.id)
        let removed = try ops.applyTag(goals.id, toPost: c.id).id
        try ops.removeTag(goals.id, fromPost: c.id)
        return World(
            life: life, goals: goals, year: year, work: work, a: a, b: b, c: c,
            block: block, removedEarlier: removed)
    }

    /// Every tag, post_tag and block_tag row as (id, deleted_at) — the exact
    /// row state the round trip must reproduce, ids included.
    private func rows(_ db: AppDatabase) throws -> [String: [String: String?]] {
        try db.read { db in
            var out: [String: [String: String?]] = [:]
            for table in ["tag", "post_tag", "block_tag"] {
                var byID: [String: String?] = [:]
                for row in try Row.fetchAll(db, sql: "SELECT id, deleted_at FROM \(table)") {
                    byID[row["id"]] = row["deleted_at"] as String?
                }
                out[table] = byID
            }
            return out
        }
    }

    private func liveTagIDs(_ db: AppDatabase, on postID: String) throws -> Set<String> {
        try db.read {
            Set(try String.fetchAll(
                $0, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [postID]))
        }
    }

    private func liveTags(_ db: AppDatabase) throws -> Set<String> {
        try db.read { Set(try String.fetchAll($0, sql: "SELECT path FROM tag WHERE deleted_at IS NULL")) }
    }

    /// RED ON OLD. The delete registers ONE entry; undo brings the whole
    /// subtree back with every application it took — and only those.
    @Test func undoRevivesTheSubtreeAndItsApplications() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            let before = try rows(db)

            try ops.deleteTag(w.life.id)
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Delete Tag")
            #expect(try liveTags(db) == ["work"])
            let stamps = try db.read {
                Set(try String.fetchAll(
                    $0, sql: "SELECT deleted_at FROM tag WHERE id IN (?, ?, ?)",
                    arguments: [w.life.id, w.goals.id, w.year.id]))
            }
            #expect(stamps.count == 1, "the subtree dies on ONE stamp")

            let outcome = try stack.undoReporting(with: ops)
            #expect(outcome == UndoStack.Outcome(label: "Delete Tag", changed: true))
            #expect(try liveTags(db) == ["life", "life/goals", "life/goals/2024", "work"])
            #expect(try liveTagIDs(db, on: w.a.id) == [w.life.id])
            #expect(try liveTagIDs(db, on: w.b.id) == [w.goals.id, w.work.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_tag WHERE block_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [w.block, w.year.id]) == 1)
            #expect(try db.deletedAt("post_tag", w.removedEarlier) != nil,
                    "an application she removed BEFORE the delete died on its own stamp — it stays removed")
            #expect(try liveTagIDs(db, on: w.c.id).isEmpty)
            // Exact rows: the same ids, back to their pre-delete liveness —
            // no row minted (only `updated_at` moved on the tag rows).
            let after = try rows(db)
            #expect(after == before, "undo returns every tag/application row to its pre-delete state")
            #expect(stack.depth == 0 && stack.redoDepth == 1)
        }
    }

    /// RED ON OLD. Redo is an exact-row re-apply — the same rows die again,
    /// on one fresh stamp, and the next undo brings exactly them back.
    @Test func redoReturnsToTheExactPostDeleteRows() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            let before = try rows(db)
            try ops.deleteTag(w.life.id)
            let deleted = try rows(db)

            _ = try stack.undo(with: ops)
            let redone = try stack.redoReporting(with: ops)
            #expect(redone == UndoStack.Outcome(label: "Delete Tag", changed: true))
            let afterRedo = try rows(db)
            #expect(afterRedo.mapValues { $0.mapValues { $0 != nil } }
                    == deleted.mapValues { $0.mapValues { $0 != nil } },
                    "the same rows are dead as after the delete — ids included")
            #expect(try liveTags(db) == ["work"])
            #expect(stack.depth == 1 && stack.redoDepth == 0)

            _ = try stack.undo(with: ops)
            #expect(try rows(db) == before, "and the next undo brings exactly them back")
            _ = w
        }
    }

    /// RED ON OLD. A delete that took nothing but a leaf: undo is that one
    /// row and its applications, nothing else.
    @Test func undoingALeafDeleteTouchesOnlyTheLeaf() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.year.id)
            #expect(try liveTags(db) == ["life", "life/goals", "work"])
            _ = try stack.undo(with: ops)
            #expect(try liveTags(db) == ["life", "life/goals", "life/goals/2024", "work"])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block_tag WHERE tag_id = ? AND deleted_at IS NULL", [w.year.id]) == 1)
        }
    }

    /// The quiet-half rule (VX-246 U2): an undo that finds the tags already
    /// back (a sync apply, another device's restore) changes nothing and
    /// RETIRES its entry — no redo is left to re-delete what came back.
    @Test func anUndoFindingTheTagsBackIsQuietAndRetires() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.year.id)
            try db.write { db in
                try db.execute(sql: "UPDATE tag SET deleted_at = NULL WHERE id = ?", arguments: [w.year.id])
            }
            let quiet = try stack.undoReporting(with: ops)
            #expect(quiet == UndoStack.Outcome(label: "Delete Tag", changed: false))
            #expect(stack.depth == 0 && stack.redoDepth == 0, "retired — neither stack holds it")
        }
    }

    /// The mirror: a redo whose tags are already gone again is quiet too.
    @Test func aRedoFindingTheTagsGoneIsQuietAndRetires() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.year.id)
            _ = try stack.undo(with: ops)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE tag SET deleted_at = '2026-07-02T00:00:00.000Z' WHERE id = ?",
                    arguments: [w.year.id])
            }
            let quiet = try stack.redoReporting(with: ops)
            #expect(quiet == UndoStack.Outcome(label: "Delete Tag", changed: false))
            #expect(stack.depth == 0 && stack.redoDepth == 0)
        }
    }

    /// A tag she made since with the SAME path refuses the undo (the path is
    /// unique) and KEEPS the entry — rename hers, and the undo lands.
    @Test func aLiveTagHoldingThePathRefusesAndKeepsTheEntry() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.work.id)
            let mine = try ops.createTag(name: "work")
            #expect(throws: OperationError.duplicateTagPath(path: "work")) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1, "the entry stays for retry")
            #expect(try db.deletedAt("tag", w.work.id) != nil, "nothing revived")

            try ops.renameTag(mine.id, newName: "work-new")
            _ = try stack.undo(with: ops)
            #expect(try liveTags(db).isSuperset(of: ["work", "work-new"]))
            #expect(try liveTagIDs(db, on: w.b.id).contains(w.work.id))
        }
    }

    /// An application revives only onto a LIVE note: one deleted since the
    /// tag delete stays as its own delete left it (no live row under a dead
    /// note — the invariant sweep's rule).
    @Test func anApplicationRevivesOnlyOntoALiveNote() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.life.id)
            try ops.deleteContainer(w.b.id)
            _ = try stack.undo(with: ops)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [w.b.id, w.goals.id]) == 0)
            #expect(try liveTagIDs(db, on: w.a.id) == [w.life.id], "a live note's application revives")
        }
    }

    private func assembled(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func tag(_ db: AppDatabase, _ id: String) throws -> VariorumCore.Tag? {
        try db.read { try VariorumCore.Tag.fetchOne($0, key: id) }
    }

    /// **Ladder r1 F-2 (BLOCKER) — RED ON OLD.** `path` is the model's ONE
    /// deliberate denormalization and `renameTag` rewrites only LIVE
    /// descendants, so a parent renamed while its child lay dead leaves the
    /// child's stored path stale. The old inverse revived that stale row as
    /// it was — `life/goals` under `home` — so a gathering on `#home` lost the
    /// note (subtree matching walks paths), and a later delete of `home`
    /// (which takes the `home/` prefix) left `life/goals` LIVE under a dead
    /// parent. The undo now rebuilds the path from the live parent.
    @Test func aTagRevivedUnderARenamedParentTakesTheParentsNewPath() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let note = try ops.createPost(title: "a note")
            _ = try ops.applyTag(goals.id, toPost: note.id)
            let gathering = try ops.createReading(
                name: "home things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(life.id)))
            #expect(try assembled(db, gathering.id) == [note.id], "premise: the subtree rule shows the note")
            stack.removeAll()

            try ops.deleteTag(goals.id)
            try ops.renameTag(life.id, newName: "home")
            #expect(stack.topLabel == "Delete Tag", "a rename registers nothing — the delete is still the top")
            _ = try stack.undo(with: ops)

            let revived = try #require(try tag(db, goals.id))
            #expect(revived.deletedAt == nil)
            #expect(revived.parentId == life.id)
            #expect(revived.path == "home/goals", "the path is rebuilt from the live parent, never the stale one")
            #expect(try assembled(db, gathering.id) == [note.id], "the #home gathering shows the note again")

            try ops.deleteTag(life.id)
            #expect(try db.deletedAt("tag", goals.id) != nil, "the revived tag dies with its parent")
            #expect(try liveTags(db).isEmpty, "no live tag is left under a dead parent")
        }
    }

    /// F-2's deeper form — RED ON OLD. A pass rooted below a renamed tag
    /// revives its whole chain parents first, each child's path built from
    /// its revived parent's REBUILT path (never its own stale one).
    @Test func aRevivedChainRebuildsEveryPathParentsFirst() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's

            try ops.deleteTag(w.goals.id)  // takes life/goals and life/goals/2024
            try ops.renameTag(w.life.id, newName: "home")
            _ = try stack.undo(with: ops)

            #expect(try tag(db, w.goals.id)?.path == "home/goals")
            #expect(try tag(db, w.year.id)?.path == "home/goals/2024")
            #expect(try liveTags(db) == ["home", "home/goals", "home/goals/2024", "work"])
            #expect(try liveTagIDs(db, on: w.b.id) == [w.goals.id, w.work.id], "the applications ride back")

            // …and the redo re-deletes by the CURRENT path, which the revival
            // kept coherent — the whole chain goes again, nothing stranded.
            _ = try stack.redo(with: ops)
            #expect(try liveTags(db) == ["home", "work"])
        }
    }

    /// F-2's collision half — RED ON OLD. The live-unique check reads the
    /// REBUILT path: a `home/goals` she made since refuses the undo (the old
    /// inverse checked the stale `life/goals`, found nothing, and revived a
    /// second tag under `home` named `goals`).
    @Test func theCollisionCheckReadsTheRebuiltPath() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            stack.removeAll()

            try ops.deleteTag(goals.id)
            try ops.renameTag(life.id, newName: "home")
            let mine = try ops.createTag(parent: life.id, name: "goals")
            #expect(throws: OperationError.duplicateTagPath(path: "home/goals")) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1, "the entry stays for retry")
            #expect(try db.deletedAt("tag", goals.id) != nil, "nothing revived")

            try ops.renameTag(mine.id, newName: "aims")
            _ = try stack.undo(with: ops)
            #expect(try liveTags(db) == ["home", "home/aims", "home/goals"])
        }
    }

    // MARK: - P1 (ladder r1 F-1)

    /// The query plan of a shipped revival statement, exactly as it ships
    /// (the SQL is a constant precisely so this reads the real thing).
    private func plan(_ db: AppDatabase, _ sql: String) throws -> String {
        try db.read { database in
            try Row.fetchAll(
                database, sql: "EXPLAIN QUERY PLAN \(sql)",
                arguments: ["a-tag", "2026-07-01T00:00:00.000Z"])
                .map { ($0["detail"] as String?) ?? "" }
                .joined(separator: "\n")
        }
    }

    /// **Ladder r1 F-1 (BLOCKER, P1) — RED ON OLD.** The inverse's revivals
    /// guarded their targets with `post_id IN (SELECT id FROM container …)` /
    /// `block_id IN (SELECT id FROM block …)`: a non-correlated list subquery
    /// SQLite MATERIALISES by scanning the whole table, once per revived tag
    /// that wore anything — an undo whose cost grew with every note (and every
    /// block) in the store, not with the applications it revives (measured by
    /// the reviewer: 0.439 s vs 0.0005 s at a million containers). A SHAPE pin,
    /// like `ReadLayerP1Tests`' — no list subquery, no table scanned: each
    /// target is SEEKED by its key, the twin by its live-unique index.
    @Test func theApplicationRevivalsSeekTheirTargetsAndNeverScanACorpusTable() throws {
        try withOperations { ops, db in
            _ = try world(ops)  // a store with notes, blocks and applications in it
            for (sql, target) in [
                (Operations.revivePostTagApplicationsSQL, "container"),
                (Operations.reviveBlockTagApplicationsSQL, "block"),
            ] {
                let plan = try plan(db, sql)
                let lines = plan.split(separator: "\n").map(String.init)
                #expect(!plan.contains("LIST SUBQUERY"),
                        "the \(target) guard must be correlated, never a materialised list; plan was:\n\(plan)")
                #expect(!lines.contains { $0.hasPrefix("SCAN") },
                        "no table may be scanned (the \(target) table least of all); plan was:\n\(plan)")
                #expect(lines.contains { $0.hasPrefix("SEARCH") && $0.contains("sqlite_autoindex_\(target)_1 (id=?)") },
                        "the \(target) row is seeked by its key; plan was:\n\(plan)")
            }
        }
    }

    /// A child she made under a revived tag goes with it on redo — the
    /// delete's own subtree rule (no live tag is left under a dead parent) —
    /// and the next undo brings it back on that same stamp.
    @Test func aChildMadeSinceTheUndoRidesTheRedoAndComesBackWithTheNextUndo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            stack.removeAll()  // the fixture's own acts (its New Block) aren't this pin's
            try ops.deleteTag(w.life.id)
            _ = try stack.undo(with: ops)
            let fresh = try ops.createTag(parent: w.goals.id, name: "2025")

            _ = try stack.redo(with: ops)
            #expect(try db.deletedAt("tag", fresh.id) != nil, "never left live under a dead parent")
            #expect(try liveTags(db) == ["work"])
            _ = try stack.undo(with: ops)
            #expect(try liveTags(db).contains("life/goals/2025"))
        }
    }
}
