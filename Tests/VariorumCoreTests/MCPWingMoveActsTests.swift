import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-c U6 — THE MCP DOOR's WING MOVE (VX-160; VX-160/-9; the brief §10's
// R1 · T1 · U1): her door's act, wrapped — the same rows her Move to Wing ▸
// writes, her refusals, plus ONE client-named undo entry whose inverse and
// redo replay the act's EXACT rows (no fresh row, ids surviving undo↔redo).
// Who may move is the server's per-call rule (`MCPWingMoveServerTests`).
// And VX-273's reach, decided by the rule (`decideGathering`) on the facts
// the one derivation site reads (`mcpGatheringFacts`).

private struct GuardRefused: Error, Equatable {}

@Suite("13n-c U6 — the MCP wing move (exact-row undo) and the gathering reach")
struct MCPWingMoveActsTests {
    private let label = Operations.MCPWriteAct.wingMove.undoLabel(client: "claude-code")

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func liveIDs(_ db: AppDatabase, _ sql: String, _ arguments: [(any DatabaseValueConvertible)?]) throws
        -> Set<String> {
        Set(try db.read { try String.fetchAll($0, sql: sql, arguments: StatementArguments(arguments)) })
    }

    private func liveMemberships(_ db: AppDatabase, _ post: String) throws -> Set<String> {
        try liveIDs(db, "SELECT id FROM reading_post WHERE post_id = ? AND deleted_at IS NULL", [post])
    }

    private func livePostTags(_ db: AppDatabase, _ post: String) throws -> Set<String> {
        try liveIDs(db, "SELECT id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [post])
    }

    private func liveBlockTags(_ db: AppDatabase, _ block: String) throws -> Set<String> {
        try liveIDs(db, "SELECT id FROM block_tag WHERE block_id = ? AND deleted_at IS NULL", [block])
    }

    private func wing(_ db: AppDatabase, _ id: String) throws -> String? {
        try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [id])
    }

    private func rowCount(_ db: AppDatabase, _ table: String) throws -> Int {
        try db.fetchInt("SELECT COUNT(*) FROM \(table)") ?? -1
    }

    /// Her sweep's shape in one note: two books it is a member of, a book it
    /// WAITS at (an arrival), a tag that ADOPTS in the destination, one that is
    /// MINTED there, a block tag, a saved version.
    private struct Fixture {
        let wing: Wing
        let note: Container
        let block: String
        let alpha: Reading
        let beta: Reading
        let waiting: Reading
        let version: String
    }

    /// Seeded with a STACK-LESS `Operations` — fixture acts are not gestures
    /// (`seedBlock`'s doctrine), so only the act under test registers.
    private func fixture(_ db: AppDatabase) throws -> Fixture {
        let ops = Operations()
        let wing = try ops.createWing(name: "variorum")
        let writing = try ops.createTag(name: "writing")
        let poems = try ops.createTag(name: "poems")
        _ = try ops.createTag(name: "writing", wingID: wing.id)
        let note = try ops.createPost(title: "parser notes")
        let block = try ops.seedBlock(in: note.id, text: "the lexer comes first")
        try ops.applyTag(writing.id, toPost: note.id)
        try ops.applyTag(poems.id, toPost: note.id)
        _ = try ops.applyTag(writing.id, toBlock: block.block.id)
        let alpha = try ops.createReading(name: "Alpha", kind: .book)
        let beta = try ops.createReading(name: "Beta", kind: .book)
        let waiting = try ops.createReading(name: "Gamma", kind: .book)
        _ = try ops.addPostToReading(note.id, to: alpha.id)
        _ = try ops.addPostToReading(note.id, to: beta.id)
        try db.write { db in
            try ReadingPost(
                id: "arrival-1", readingId: waiting.id, postId: note.id, position: "a",
                status: .arrival, createdAt: Date(timeIntervalSince1970: 1_782_864_000)
            ).insert(db)
        }
        let version = try ops.saveNoteVersion(note.id).post.id
        return Fixture(
            wing: wing, note: note, block: block.block.id, alpha: alpha, beta: beta, waiting: waiting,
            version: version)
    }

    // MARK: - The act: her door's rows, one client-named entry

    @Test func theMoveIsHerDoorsActWithOneClientNamedEntry() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            let result = try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)

            #expect(result.move.leftBooks == ["Alpha", "Beta"], "the members her confirm would list — never the arrival")
            #expect(result.leftBookIDs == [f.alpha.id, f.beta.id])
            #expect(result.move.adoptedTags == 1 && result.move.mintedTags == 1,
                    "writing adopts the destination's own; poems is made there")
            #expect(try wing(db, f.note.id) == f.wing.id)
            #expect(try wing(db, f.version) == f.wing.id, "its versions ride it")
            #expect(try liveMemberships(db, f.note.id).isEmpty, "every book left, the arrival dismissed")
            let destinationTags = try liveIDs(
                db, "SELECT t.path FROM post_tag pt JOIN tag t ON t.id = pt.tag_id WHERE pt.post_id = ? "
                    + "AND pt.deleted_at IS NULL AND t.wing_id = ?", [f.note.id, f.wing.id])
            #expect(destinationTags == ["writing", "poems"])
            #expect(stack.depth == 1 && stack.topLabel == "claude-code's wing move")
        }
    }

    // MARK: - U1: the exact-row inverse and redo

    @Test func itsUndoAndRedoReplayTheExactRowsAndMintNothing() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            let memberships = try liveMemberships(db, f.note.id)
            let postTags = try livePostTags(db, f.note.id)
            let blockTags = try liveBlockTags(db, f.block)
            let membershipSnapshots = try memberships.sorted().map { try db.snapshotRow("reading_post", $0, excluding: []) }

            try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            let movedPostTags = try livePostTags(db, f.note.id)
            let movedBlockTags = try liveBlockTags(db, f.block)
            #expect(movedPostTags.isDisjoint(with: postTags) && movedBlockTags.isDisjoint(with: blockTags))
            let minted = try #require(try db.fetchString(
                "SELECT id FROM tag WHERE wing_id = ? AND path = 'poems'", [f.wing.id]))
            let counts = try ["reading_post", "post_tag", "block_tag", "tag"].map { try rowCount(db, $0) }

            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, f.note.id) == "" && wing(db, f.version) == "", "back in Home, versions too")
            #expect(try liveMemberships(db, f.note.id) == memberships, "the SAME rows, members and the arrival")
            #expect(try memberships.sorted().map { try db.snapshotRow("reading_post", $0, excluding: []) }
                    == membershipSnapshots, "each row exactly as it stood — status, position, chapter")
            #expect(try livePostTags(db, f.note.id) == postTags && liveBlockTags(db, f.block) == blockTags,
                    "the original applications revived, the copies tombstoned")
            #expect(try db.deletedAt("tag", minted) == nil, "a tag the move made stays as vocabulary")
            #expect(try ["reading_post", "post_tag", "block_tag", "tag"].map { try rowCount(db, $0) } == counts,
                    "no fresh row anywhere")

            #expect(try stack.redo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, f.note.id) == f.wing.id && wing(db, f.version) == f.wing.id)
            #expect(try liveMemberships(db, f.note.id).isEmpty)
            #expect(try livePostTags(db, f.note.id) == movedPostTags && liveBlockTags(db, f.block) == movedBlockTags,
                    "the redo revives the move's OWN copies — ids survive undo↔redo")
            #expect(try ["reading_post", "post_tag", "block_tag", "tag"].map { try rowCount(db, $0) } == counts)

            // The ping-pong holds: a second undo matches the redo's stamp.
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            #expect(try liveMemberships(db, f.note.id) == memberships)
            #expect(try livePostTags(db, f.note.id) == postTags)
        }
    }

    @Test func aGuardRefusalWritesNothingAndRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            let before = try db.snapshotRow("container", f.note.id, excluding: [])
            #expect(throws: GuardRefused.self) {
                try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label,
                                          guardedBy: { _ in throw GuardRefused() })
            }
            #expect(try db.snapshotRow("container", f.note.id, excluding: []) == before)
            #expect(try liveMemberships(db, f.note.id).count == 3)
            #expect(stack.depth == 0)
        }
    }

    @Test func herRefusalsAreHersAndWriteNothing() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            #expect(throws: OperationError.postAlreadyInWing(postID: f.note.id, wingID: "")) {
                try ops.mcpMoveNoteToWing(f.note.id, to: "", undoLabel: label)
            }
            #expect(throws: OperationError.wingNotFound(id: "no-such-wing")) {
                try ops.mcpMoveNoteToWing(f.note.id, to: "no-such-wing", undoLabel: label)
            }
            try ops.lockReading(f.beta.id)
            #expect(throws: OperationError.lockedReading(id: f.beta.id)) {
                try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            }
            try ops.unlockReading(f.beta.id)
            #expect(try wing(db, f.note.id) == "")
            #expect(try liveMemberships(db, f.note.id).count == 3, "a refusal severs nothing")
            // A sealed book's member (a note membered only there — sealing a
            // SHARED member forks it in place, her seal's own rule).
            let sealedNote = try Operations().createPost(title: "sealed member")
            _ = try Operations().seedBlock(in: sealedNote.id, text: "words")
            let edition = try Operations().createReading(name: "Edition", kind: .book)
            _ = try Operations().addPostToReading(sealedNote.id, to: edition.id)
            _ = try Operations().sealReading(edition.id)
            #expect(throws: OperationError.readingSealed(id: edition.id)) {
                try ops.mcpMoveNoteToWing(sealedNote.id, to: f.wing.id, undoLabel: label)
            }
            #expect(stack.depth == 0)
        }
    }

    // MARK: - The edges (PROVISIONAL P-13nc-U6-3)

    @Test func aNoteThatJoinedABookOrTookATagSinceRefusesTheUndoAndKeepsTheEntry() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            let her = Operations()
            let there = try her.createReading(name: "launch notes", kind: .book, wingId: f.wing.id)
            _ = try her.addPostToReading(f.note.id, to: there.id)  // her act, no entry
            #expect(throws: OperationError.wingMoveChangedSince(postID: f.note.id)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1, "a resolvable refusal keeps the entry")
            #expect(try wing(db, f.note.id) == f.wing.id, "nothing written")
            _ = try her.removePostFromReading(f.note.id, from: there.id)

            let tag = try her.createTag(name: "todo", wingID: f.wing.id)
            try her.applyTag(tag.id, toPost: f.note.id)
            #expect(throws: OperationError.wingMoveChangedSince(postID: f.note.id)) {
                try stack.undo(with: ops)
            }
            try her.removeTag(tag.id, fromPost: f.note.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move", "resolved, the undo lands")
            #expect(try wing(db, f.note.id) == "")
            #expect(try liveMemberships(db, f.note.id).count == 3)
        }
    }

    @Test func anEntryWhoseNoteMovedOnOrWentIsObsoleteAndQuiet() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            try Operations().moveNoteToWing(f.note.id, to: "")  // her own door, back
            let tagsAfterHerMove = try livePostTags(db, f.note.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move", "the pop happens — never wedged")
            #expect(try wing(db, f.note.id) == "" && livePostTags(db, f.note.id) == tagsAfterHerMove,
                    "nothing written: her move stands")
            #expect(try liveMemberships(db, f.note.id).isEmpty, "the rows she let go stay let go")

            let other = try ops.createPost(title: "second")
            _ = try ops.seedBlock(in: other.id, text: "words")
            try ops.mcpMoveNoteToWing(other.id, to: f.wing.id, undoLabel: label)
            try ops.deleteContainer(other.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, other.id) == f.wing.id, "a trashed note stays where it was trashed")
        }
    }

    /// **The combined ladder R1's F1 (MINOR, both manifestations AGREED):** a
    /// replay whose stood-in wing has DIED is OBSOLETE and quiet — in either
    /// direction. Before the fix the dead id resolved to Home
    /// (`sameEffectiveWing`'s `''` arm) and the divergence check, scoped to
    /// the STORED id, missed Home-vocabulary applications — so (1) an undo
    /// could carry a live HOME-tag application onto a note in another wing (a
    /// cross-wing vocabulary split, R-13ia-1 — reachable only by a
    /// sync-arrived wing tombstone, the staging's direct write), and (2) an
    /// entry whose note HER door had moved on replayed once the emptied wing
    /// was deleted (door-reachable), against P-13nc-U6-3's recorded letter.
    @Test func aDeadWingMakesTheReplayObsoleteInEitherDirection() throws {
        try withUndo { ops, stack, db in
            let her = Operations()
            let tombstone = { (wingID: String) in
                try db.write { try $0.execute(
                    sql: "UPDATE wing SET deleted_at = '2026-10-11T23:00:00.000Z' WHERE id = ?",
                    arguments: [wingID]) }
            }

            // (1) UNDO, the invariant-grade manifestation: note in wing B with
            // a B tag, moved B → A; A's tombstone arrives by sync; she tags
            // the (effectively Home) note with a HOME tag; the undo must be a
            // quiet no-op — never a note in B wearing a Home application.
            let origin = try her.createWing(name: "origin")
            let away = try her.createWing(name: "away")
            let note = try her.createPost(title: "ferns", wingId: origin.id)
            _ = try her.seedBlock(in: note.id, text: "frond by frond")
            let originTag = try her.createTag(name: "ferns", wingID: origin.id)
            try her.applyTag(originTag.id, toPost: note.id)
            try ops.mcpMoveNoteToWing(note.id, to: away.id, undoLabel: label)
            try tombstone(away.id)
            let homeTag = try her.createTag(name: "moss")
            try her.applyTag(homeTag.id, toPost: note.id)  // legal: the note reads as Home
            let tagsBefore = try livePostTags(db, note.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move", "the pop happens — never wedged")
            #expect(try wing(db, note.id) == away.id,
                    "a dead stood-in wing makes the undo OBSOLETE — the note is not moved")
            #expect(try livePostTags(db, note.id) == tagsBefore, "nothing written")
            let crossWing = try db.fetchInt("""
                SELECT COUNT(*) FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                JOIN container c ON c.id = pt.post_id
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL AND t.deleted_at IS NULL
                  AND t.wing_id = '' AND c.wing_id = ?
                """, [note.id, origin.id])
            #expect(crossWing == 0, "no live Home application may ride a note in another wing (R-13ia-1)")

            // (2) REDO, the mirror: moved C → D and undone (back in C); C's
            // tombstone arrives; the redo must be obsolete, not a move to D.
            let c = try her.createWing(name: "c")
            let d = try her.createWing(name: "d")
            let second = try her.createPost(title: "second", wingId: c.id)
            _ = try her.seedBlock(in: second.id, text: "words")
            try ops.mcpMoveNoteToWing(second.id, to: d.id, undoLabel: label)
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, second.id) == c.id)
            try tombstone(c.id)
            #expect(try stack.redo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, second.id) == c.id,
                    "a dead source makes the redo OBSOLETE — the note is not moved")

            // (3) The door-reachable letter case: Home → E, HER door moves it
            // back, the emptied E is deleted by her door; the undo stays
            // obsolete (it was obsolete while E lived — the dead id must not
            // revive it) and the pre-move membership stays let go.
            let home = try her.createReading(name: "home book", kind: .book)
            let third = try her.createPost(title: "third")
            _ = try her.seedBlock(in: third.id, text: "words")
            _ = try her.addPostToReading(third.id, to: home.id)
            let e = try her.createWing(name: "e")
            try ops.mcpMoveNoteToWing(third.id, to: e.id, undoLabel: label)
            try her.moveNoteToWing(third.id, to: "")  // her own door, back
            try her.deleteWing(e.id)  // empty now — her door allows it
            let membershipsBefore = try liveMemberships(db, third.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, third.id) == "", "her move stands")
            #expect(try liveMemberships(db, third.id) == membershipsBefore,
                    "the rows she let go stay let go — a deleted wing cannot un-obsolete the entry")
        }
    }

    /// **The combined ladder R2's N1 — RULED QUIET-OBSOLETE (her sitting's
    /// fourth round, "quiet obsolote is fine"):** a dead CURRENT wing makes
    /// the replay obsolete in either direction — the moved-on letter
    /// (P-13nc-U6-3) outranks dangling-reads-as-Home (P-13id-U5-2) inside the
    /// replay guards. Before the fix a dead stored wing resolved to Home and
    /// satisfied `sameEffectiveWing` against a HOME stood-in wing, so an entry
    /// whose note HER door had moved on (Home → X) replayed once X's tombstone
    /// arrived by sync: a bare note was MOVED (the undo back to the source,
    /// the redo's mirror on to the destination), and a tagged one was REFUSED
    /// `wingMoveChangedSince` — a misleading wedge about tags she never
    /// applied in Home — where the ruling says quiet.
    @Test func aDeadCurrentWingMakesTheReplayObsoleteInEitherDirection() throws {
        try withUndo { ops, stack, db in
            let her = Operations()
            let tombstone = { (wingID: String) in
                try db.write { try $0.execute(
                    sql: "UPDATE wing SET deleted_at = '2026-10-11T23:30:00.000Z' WHERE id = ?",
                    arguments: [wingID]) }
            }

            // (1) UNDO, bare: client moves S → Home; HER door moves the note
            // on, Home → X; X's tombstone arrives by sync (no door deletes a
            // wing while contents live). The undo must be a quiet no-op —
            // never a move back to S of a note her door moved on.
            let s = try her.createWing(name: "s")
            let x = try her.createWing(name: "x")
            let note = try her.createPost(title: "estuary", wingId: s.id)
            _ = try her.seedBlock(in: note.id, text: "tidal flats")
            try ops.mcpMoveNoteToWing(note.id, to: "", undoLabel: label)
            try her.moveNoteToWing(note.id, to: x.id)
            try tombstone(x.id)
            let touched = try db.fetchString("SELECT updated_at FROM container WHERE id = ?", [note.id])
            #expect(try stack.undo(with: ops) == "claude-code's wing move", "the pop happens — never wedged")
            #expect(try wing(db, note.id) == x.id,
                    "a dead CURRENT wing makes the undo OBSOLETE — the moved-on note is not moved back")
            #expect(try db.fetchString("SELECT updated_at FROM container WHERE id = ?", [note.id]) == touched,
                    "nothing written")

            // (2) REDO, the mirror: moved Home → D and undone (back in Home);
            // her door moves it on, Home → X2; X2 dies. The redo must be
            // obsolete, never a move on to D.
            let d = try her.createWing(name: "d")
            let x2 = try her.createWing(name: "x2")
            let second = try her.createPost(title: "second")
            _ = try her.seedBlock(in: second.id, text: "words")
            try ops.mcpMoveNoteToWing(second.id, to: d.id, undoLabel: label)
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            try her.moveNoteToWing(second.id, to: x2.id)
            try tombstone(x2.id)
            #expect(try stack.redo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, second.id) == x2.id,
                    "a dead CURRENT wing makes the redo OBSOLETE — the moved-on note is not moved on")

            // (3) UNDO, tagged — QUIET, never the misleading refusal: the
            // note's tag rode her Home → X3 move (an X3 twin the entry never
            // knew; X3 dead puts it in the leaving-Home scope), so pre-fix
            // the divergence check threw `wingMoveChangedSince` about tags
            // she never applied in Home.
            let s3 = try her.createWing(name: "s3")
            let x3 = try her.createWing(name: "x3")
            let third = try her.createPost(title: "third", wingId: s3.id)
            _ = try her.seedBlock(in: third.id, text: "words")
            let reeds = try her.createTag(name: "reeds", wingID: s3.id)
            try her.applyTag(reeds.id, toPost: third.id)
            try ops.mcpMoveNoteToWing(third.id, to: "", undoLabel: label)
            try her.moveNoteToWing(third.id, to: x3.id)
            try tombstone(x3.id)
            let tagsBefore = try livePostTags(db, third.id)
            #expect(try stack.undo(with: ops) == "claude-code's wing move",
                    "quiet — never a wingMoveChangedSince wedge about tags she never applied")
            #expect(try wing(db, third.id) == x3.id, "obsolete: nothing moved")
            #expect(try livePostTags(db, third.id) == tagsBefore, "nothing re-pointed")
        }
    }

    @Test func theUndoRevivesIntoAFinishedBookButNotASealedOne() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            try ops.lockReading(f.alpha.id)  // finished while the note was away
            let sealedSince = try ops.createReading(name: "edition", kind: .book)
            _ = sealedSince
            _ = try ops.sealReading(f.beta.id)  // sealed while the note was away
            #expect(try stack.undo(with: ops) == "claude-code's wing move")
            let back = try db.read { db in
                try Row.fetchAll(db, sql: """
                    SELECT reading_id, status FROM reading_post WHERE post_id = ? AND deleted_at IS NULL
                    """, arguments: [f.note.id]).map { ($0["reading_id"] as String) }
            }
            #expect(Set(back) == [f.alpha.id, f.waiting.id],
                    "a finished book takes its row back (R-13id-3); a sealed one only takes a sealed note")
        }
    }

    @Test func theRedoReRunsHerFrozenRefusalAndKeepsItsEntry() throws {
        try withUndo { ops, stack, db in
            let f = try fixture(db)
            try ops.mcpMoveNoteToWing(f.note.id, to: f.wing.id, undoLabel: label)
            _ = try stack.undo(with: ops)
            try ops.lockReading(f.beta.id)
            #expect(throws: OperationError.lockedReading(id: f.beta.id)) { try stack.redo(with: ops) }
            #expect(stack.redoDepth == 1, "kept for retry")
            try ops.unlockReading(f.beta.id)
            let joined = try ops.createReading(name: "since", kind: .book)
            _ = try ops.addPostToReading(f.note.id, to: joined.id)
            #expect(throws: OperationError.wingMoveChangedSince(postID: f.note.id)) { try stack.redo(with: ops) }
            _ = try ops.removePostFromReading(f.note.id, from: joined.id)
            #expect(try stack.redo(with: ops) == "claude-code's wing move")
            #expect(try wing(db, f.note.id) == f.wing.id)
        }
    }

    // MARK: - VX-273: the gathering's reach, decided by the rule

    @Test func aGatheringIsReachedOnlyByWingLevelReachAtReadAndNeverSpends() throws {
        let gathering = MCPGrantRule.BookFacts(id: "g", wingID: "w")
        func grant(_ kind: MCPGrantRule.ScopeKind, _ id: String, _ rung: MCPGrantRule.Rung = .read,
                   _ duration: MCPGrantRule.Duration = .always) -> MCPGrantRule.Grant {
            .init(id: "\(kind)-\(id)-\(duration)", rung: rung, scopeKind: kind, scopeID: id, duration: duration)
        }
        func decide(_ grants: [MCPGrantRule.Grant], open: Bool = false, _ facts: MCPGrantRule.BookFacts = gathering)
            -> MCPGrantRule.Decision {
            MCPGrantRule.decideGathering(client: .approved, grants: grants, openBook: open, gathering: facts)
        }
        #expect(decide([grant(.wing, "w")]) == .allow(grantID: "wing-w-always", consumesOnce: false))
        #expect(decide([grant(.wing, "w", .edit)]).isAllowed, "any rung on the wing reads its gatherings")
        #expect(decide([grant(.wing, "w", .read, .once)]) == .allow(grantID: "wing-w-once", consumesOnce: false),
                "a once wing grant is never spent by a gathering")
        #expect(decide([], open: true) == .allow(grantID: nil, consumesOnce: false), "the open book reads everything")
        #expect(!decide([grant(.wing, "other")]).isAllowed, "another wing's grant never reaches it")
        #expect(!decide([grant(.book, "g")]).isAllowed, "no book grant reaches a gathering — not a target")
        #expect(!decide([grant(.note, "g")]).isAllowed)
        let fenced = MCPGrantRule.BookFacts(id: "g", wingID: "w", fence: .privateMark)
        #expect(decide([grant(.wing, "w")], open: true, fenced) == .ask(.fenced(.privateMark), offersAlways: false),
                "a fenced gathering matches nothing — the one answer")
        #expect(MCPGrantRule.decideGathering(client: .pending, grants: [], openBook: true, gathering: gathering)
                == .refuse(.clientPending))
    }

    @Test func aGatheringsFactsAreItsOwnAndNeverABooks() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "variorum")
            let tag = try ops.createTag(name: "parser", wingID: wing.id)
            let gathering = try ops.createReading(
                name: "parser things", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                wingId: wing.id)
            let book = try ops.createReading(name: "a book", kind: .book, wingId: wing.id)
            let facts = try db.read { db in
                (try Queries.mcpGatheringFacts(db, readingID: gathering.id),
                 try Queries.mcpGatheringFacts(db, readingID: book.id),
                 try Queries.mcpBookFacts(db, readingID: gathering.id))
            }
            #expect(facts.0 == MCPGrantRule.BookFacts(id: gathering.id, wingID: wing.id))
            #expect(facts.1 == nil, "a book is never read as a gathering")
            #expect(facts.2 == nil, "a gathering is never read as a book — no grant road can name one")
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET ai_private_at = '2026-07-01T00:00:00.000Z' WHERE id = ?",
                               arguments: [gathering.id])
            }
            #expect(try db.read { try Queries.mcpGatheringFacts($0, readingID: gathering.id) }?.fence == .privateMark,
                    "a stale Private stamp fences it, on the book's own fragment")
        }
    }
}
