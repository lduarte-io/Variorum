import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-596 — THE MCP DOOR's STAR (`Operations+MCPStars`): exact state transitions.
// Her ruling (2026-10-27): "let's add the star over the wire, it might as well be
// included." The act is HER star write (`writeStar` — the union star, the cap,
// intake hearing a note's star) behind the caller's guard, plus ONE client-named
// entry whose halves are compare-and-set on the star and put it back at its place
// in the Starred list. Who may act is the server's per-call rule
// (`MCPStarServerTests`). Red on old by construction: the act did not exist.

private struct GuardRefused: Error, Equatable {}

@Suite("VX-596 — set_starred's act: her star write, one client-named entry")
struct MCPStarActsTests {
    private let label = Operations.MCPWriteAct.star.undoLabel(client: "claude-code")
    private let unstarLabel = Operations.MCPWriteAct.unstar.undoLabel(client: "claude-code")

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func starred(_ db: AppDatabase) throws -> [StarTarget] {
        try db.read { try Queries.starred($0).map(\.target) }
    }

    private func stored(_ db: AppDatabase) throws -> String? {
        try db.read { try String.fetchOne($0, sql: "SELECT value FROM setting WHERE key = 'starred'") }
    }

    private func column(_ db: AppDatabase, _ readingID: String) throws -> Int? {
        try db.read { try Int.fetchOne($0, sql: "SELECT starred FROM reading WHERE id = ?", arguments: [readingID]) }
    }

    private func pair(_ db: AppDatabase, _ readingID: String, _ postID: String) throws -> String? {
        try db.read {
            try String.fetchOne(
                $0,
                sql: "SELECT status FROM reading_post WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL",
                arguments: [readingID, postID])
        }
    }

    // MARK: - The act

    /// A note starred through the act: her write (the list in star order),
    /// heard by intake exactly as her own star is — a living ★-rule book that
    /// joins quietly SEATS it, one whose dial says "wait at Arrivals" BELLS it —
    /// and ONE client-named entry.
    @Test func aStarActStarsTheNoteAsHerStarDoesWithOneClientNamedEntry() throws {
        try withUndo { ops, stack, db in
            let joins = try ops.createReading(name: "stars, seated", kind: .book, querySpec: try RuleGrammar.encode(.star))
            let waits = try ops.createReading(name: "stars, waiting", kind: .book, querySpec: try RuleGrammar.encode(.star))
            try ops.setReadingIntakeSeating(waits.id, .arrivals)
            let wire = try ops.createPost(title: "the client's")
            let hers = try ops.createPost(title: "hers")

            let change = try ops.setStarredForClient(.post(wire.id), starred: true, undoLabel: label)
            #expect(change == .init(target: .post(wire.id), starred: true, changed: true))
            try ops.setStarred(.post(hers.id), starred: true)  // her own door, the parity witness

            #expect(try starred(db) == [.post(wire.id), .post(hers.id)], "star time is the order")
            for note in [wire, hers] {
                #expect(try pair(db, joins.id, note.id) == "member", "\(note.title ?? ""): seated, as hers")
                #expect(try pair(db, waits.id, note.id) == "arrival", "\(note.title ?? ""): belled, as hers")
            }
            #expect(stack.depth == 1 && stack.topLabel == label, "ONE entry, the act's (her door registers none)")
        }
    }

    /// Un-starring is the same act the other way — an intake NON-EVENT (a seat
    /// the star caused stays) — and a book's star is the union's two stores.
    @Test func anUnstarIsANonEventAndABookStarWritesBothStores() throws {
        try withUndo { ops, stack, db in
            let joins = try ops.createReading(name: "stars", kind: .book, querySpec: try RuleGrammar.encode(.star))
            let note = try ops.createPost(title: "n")
            let book = try ops.createReading(name: "orbit", kind: .book)
            _ = try ops.setStarredForClient(.post(note.id), starred: true, undoLabel: label)
            #expect(try pair(db, joins.id, note.id) == "member")
            _ = try ops.setStarredForClient(.post(note.id), starred: false, undoLabel: unstarLabel)
            #expect(try starred(db).isEmpty)
            #expect(try pair(db, joins.id, note.id) == "member", "un-starring never evicts (§19)")

            _ = try ops.setStarredForClient(.reading(book.id), starred: true, undoLabel: label)
            #expect(try starred(db) == [.reading(book.id)] && (try column(db, book.id)) == 1, "both stores")
            #expect(stack.depth == 3)
            #expect(try stack.undo(with: ops) == label)
            #expect(try starred(db).isEmpty && (try column(db, book.id)) == 0, "the undo clears both")
            #expect(try stack.redo(with: ops) == label)
            #expect(try starred(db) == [.reading(book.id)] && (try column(db, book.id)) == 1, "the redo, both again")
        }
    }

    /// A star already as asked writes NOTHING — no setting write, no entry —
    /// and answers `changed: false` (VX-362's `apply_tag` shape), by EITHER store
    /// of the union: a book starred by its column alone is starred.
    @Test func aStarAlreadyAsAskedWritesNothingAndRegistersNoEntry() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "n")
            try ops.setStarred(.post(note.id), starred: true)
            let other = try ops.createPost(title: "other")
            let columnOnly = try ops.createReading(name: "pinned long ago", kind: .book)
            try db.write { try $0.execute(sql: "UPDATE reading SET starred = 1 WHERE id = ?", arguments: [columnOnly.id]) }
            let before = try stored(db)
            let outboxBefore = try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") }

            for (target, value) in [(StarTarget.post(note.id), true), (.post(other.id), false), (.reading(columnOnly.id), true)] {
                let change = try ops.setStarredForClient(target, starred: value, undoLabel: label)
                #expect(!change.changed, "\(target): already as asked")
            }
            #expect(try stored(db) == before, "the stored list untouched (no self-heal write either)")
            #expect(try db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") } == outboxBefore)
            #expect(stack.depth == 0, "nothing to undo")
        }
    }

    /// The cap refuses the act in HER words' case (`starLimitReached` — the wire
    /// speaks it through her `OpsRefusalCopy`), nothing written, no entry.
    @Test func theCapRefusesTheActAndWritesNothing() throws {
        try withUndo { ops, stack, db in
            for index in 0..<Operations.starLimit {
                try ops.setStarred(.post(try ops.createPost(title: "n\(index)").id), starred: true)
            }
            let full = try starred(db)
            let one = try ops.createPost(title: "one too many")
            #expect(throws: OperationError.starLimitReached(limit: Operations.starLimit)) {
                try ops.setStarredForClient(.post(one.id), starred: true, undoLabel: label)
            }
            #expect(try starred(db) == full && stack.depth == 0)
        }
    }

    /// The guard runs FIRST, inside the act's own transaction: a refusal writes
    /// nothing and registers nothing.
    @Test func theGuardRunsFirstAndARefusalWritesNothing() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "n")
            #expect(throws: GuardRefused()) {
                try ops.setStarredForClient(.post(note.id), starred: true, undoLabel: label) { _ in
                    throw GuardRefused()
                }
            }
            #expect(try starred(db).isEmpty && (try stored(db)) == nil && stack.depth == 0)
        }
    }

    // MARK: - The entry: exact, at its place, compare-and-set (VX-276)

    /// An un-star's undo puts the star back WHERE IT STOOD in her Starred list —
    /// never at the end — and undo ↔ redo round-trips to the same list.
    @Test func anUnstarsUndoPutsTheStarBackWhereItStood() throws {
        try withUndo { ops, stack, db in
            let notes = try (0..<4).map { try ops.createPost(title: "n\($0)") }
            for note in notes { try ops.setStarred(.post(note.id), starred: true) }
            let order = notes.map { StarTarget.post($0.id) }

            _ = try ops.setStarredForClient(.post(notes[1].id), starred: false, undoLabel: unstarLabel)
            #expect(try starred(db) == [order[0], order[2], order[3]])
            #expect(try stack.undo(with: ops) == unstarLabel)
            #expect(try starred(db) == order, "back at its place, second")
            #expect(try stack.redo(with: ops) == unstarLabel)
            #expect(try starred(db) == [order[0], order[2], order[3]])
            #expect(try stack.undo(with: ops) == unstarLabel)
            #expect(try starred(db) == order)

            // A star act's undo and redo: the redo puts it back where the undo took it from.
            let fifth = try ops.createPost(title: "n4")
            _ = try ops.setStarredForClient(.post(fifth.id), starred: true, undoLabel: label)
            #expect(try starred(db) == order + [.post(fifth.id)])
            #expect(try stack.undo(with: ops) == label)
            #expect(try starred(db) == order)
            #expect(try stack.redo(with: ops) == label)
            #expect(try starred(db) == order + [.post(fifth.id)])
        }
    }

    /// **VX-276's class:** a half writes back only while the star still reads the
    /// value its partner left. Her own un-star (or re-star) since is HERS — the
    /// half is quiet, the entry RETIRES, and no redo ever writes over her.
    @Test func eachHalfWritesOnlyWhileTheStarReadsItsPartnersValue() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "n")
            // Undo side, a star act: she un-stars by hand first.
            _ = try ops.setStarredForClient(.post(note.id), starred: true, undoLabel: label)
            try ops.setStarred(.post(note.id), starred: false)
            let quiet = try #require(try stack.undoReporting(with: ops))
            #expect(!quiet.changed && stack.depth == 0 && stack.redoDepth == 0, "quiet, retired, no redo future")
            #expect(try starred(db).isEmpty)

            // Undo side, an un-star act: she re-stars by hand first.
            try ops.setStarred(.post(note.id), starred: true)
            _ = try ops.setStarredForClient(.post(note.id), starred: false, undoLabel: unstarLabel)
            try ops.setStarred(.post(note.id), starred: true)
            #expect(try stack.undoReporting(with: ops)?.changed == false)
            #expect(try starred(db) == [.post(note.id)] && stack.redoDepth == 0)

            // Redo side: the undo ran, then she put the star back herself.
            try ops.setStarred(.post(note.id), starred: false)
            _ = try ops.setStarredForClient(.post(note.id), starred: true, undoLabel: label)
            #expect(try stack.undo(with: ops) == label)
            try ops.setStarred(.post(note.id), starred: true)
            let redo = try #require(try stack.redoReporting(with: ops))
            #expect(!redo.changed && stack.depth == 0 && stack.redoDepth == 0, "quiet, retired")

            // A note trashed since: the world moved on — quiet.
            _ = try ops.setStarredForClient(.post(note.id), starred: false, undoLabel: unstarLabel)
            try ops.deleteContainer(note.id)
            #expect(try stack.undoReporting(with: ops)?.changed == false, "a dead note is never re-starred")
        }
    }

    /// The halves are not applying acts: a replayed star SEATS nothing
    /// (`apply_tag`'s replay doctrine) — her own star, at the same moment, would.
    @Test func aReplayedStarIsNoApplyingAct() throws {
        try withUndo { ops, stack, db in
            let note = try ops.createPost(title: "n")
            _ = try ops.setStarredForClient(.post(note.id), starred: true, undoLabel: label)
            #expect(try stack.undo(with: ops) == label)
            // A living ★-rule book born now (its backfill finds nothing starred).
            let joins = try ops.createReading(name: "stars", kind: .book, querySpec: try RuleGrammar.encode(.star))
            #expect(try pair(db, joins.id, note.id) == nil)
            #expect(try stack.redo(with: ops) == label)
            #expect(try starred(db) == [.post(note.id)])
            #expect(try pair(db, joins.id, note.id) == nil, "the replay's star is heard by no book")
            // Her own star at the same moment IS an applying act.
            let witness = try ops.createPost(title: "witness")
            try ops.setStarred(.post(witness.id), starred: true)
            #expect(try pair(db, joins.id, witness.id) == "member")
        }
    }

    /// A half that would star past the cap REFUSES in her words and KEEPS its
    /// entry — resolvable: she un-stars one, and the undo then lands.
    @Test func aHalfThatWouldPassTheCapRefusesAndKeepsItsEntry() throws {
        try withUndo { ops, stack, db in
            var notes: [Container] = []
            for index in 0..<Operations.starLimit {
                let note = try ops.createPost(title: "n\(index)")
                notes.append(note)
                try ops.setStarred(.post(note.id), starred: true)
            }
            _ = try ops.setStarredForClient(.post(notes[3].id), starred: false, undoLabel: unstarLabel)
            let filler = try ops.createPost(title: "filler")
            try ops.setStarred(.post(filler.id), starred: true)  // the list is full again
            #expect(throws: OperationError.starLimitReached(limit: Operations.starLimit)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1 && stack.topLabel == unstarLabel, "the entry is kept")
            try ops.setStarred(.post(filler.id), starred: false)
            #expect(try stack.undo(with: ops) == unstarLabel)
            #expect(try starred(db) == notes.map { .post($0.id) }, "back at its place, fourth")
        }
    }
}
