import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-775 (the VX-913 run, B3 — the run record's B3 RECORD; her ruling at the #267
// sitting: "the error goes to her, the truth goes to the client"; this run's
// kickoff: the failure reaches her as a refusal-kind line on her status seam).
// A write tool's act COMMITS inside `MCPWriteTools.land`, then its Activity line is
// written in another write; when that write fails, the old `land` treated the
// LANDED act as refused — a second (refused) Activity line, an `isError` answer in
// the store-failure words, and no receipt: the client was told its write may not
// have landed, she was told nothing, and a transient failure left a FALSE "refused"
// line in Activity.
//
// The failures are made real on the harness's one connection by TEMP triggers that
// abort an `mcp_activity` insert the way a failing store does (VX-369's precedent —
// GRDB raises the same `DatabaseError` for a full disk, a read-only volume or a
// trigger's abort). RED ON OLD (the behavioural revert — the fix commit's
// `MCPWriteTools.swift` + `MCPWriteTools+NoteLists.swift` from its parent): every
// pin below answers `isError` there, sends no receipt and tells the app nothing.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// Every Activity insert aborts — the store stays broken (a full disk stays full).
private let everyLineFails = """
    CREATE TEMP TRIGGER vx775_log_failure BEFORE INSERT ON mcp_activity
    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
    """

/// Only a LANDED line aborts — the transient shape: a write that fails once and
/// would succeed a moment later (the old road's second, refused line then lands).
private let onlyTheLandedLineFails = """
    CREATE TEMP TRIGGER vx775_log_failure BEFORE INSERT ON mcp_activity WHEN NEW.outcome = 'allowed'
    BEGIN SELECT RAISE(ABORT, 'the store refused'); END
    """

private let dropTrigger = "DROP TRIGGER vx775_log_failure"

/// The store's words the app is handed (VX-369's form: SQLite's code and message).
private let storeWords = "SQLite error 19: the store refused"

/// One world: a note with one block, a client approved at `rung` on it.
private struct World {
    let h: ServerHarness
    let note: Container
    let take: Variant
    let block: String
    let connection: HarnessConnection
}

private func world(
    _ h: ServerHarness, rung: MCPGrantRule.Rung = .suggest, duration: MCPGrantRule.Duration = .always
) async throws -> World {
    let note = try h.operations.createPost(title: "ch 1")
    let seeded = try h.operations.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
    let connection = try await h.connect(as: "claude-code")
    _ = try h.approve("claude-code", spec(rung, .note, note.id, duration))
    return World(h: h, note: note, take: seeded.variant, block: seeded.block.id, connection: connection)
}

private func activityLines(_ h: ServerHarness, _ act: String) throws -> [String] {
    try h.database.read {
        try String.fetchAll($0, sql: "SELECT outcome FROM mcp_activity WHERE act = ? ORDER BY id", arguments: [act])
    }
}

private func liveComments(_ h: ServerHarness, _ blockID: String) throws -> Int {
    try h.database.read {
        try Int.fetchOne(
            $0, sql: "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID]) ?? 0
    }
}

@Suite("VX-775 — a landed write whose Activity line fails answers the act's truth; she is told", .serialized)
struct MCPActivityLogFailureServerTests {
    /// **RED ON OLD.** The store refuses every Activity line (it stays broken): a
    /// client's `add_comment` lands — and its answer is the act's own, BYTE FOR
    /// BYTE the answer of the same call in a twin world whose log works (R-825:
    /// nothing on the wire varies with her app-side state). The comment is in the
    /// store with its client-named ⌥⌘Z entry, its receipt is sent, and the app is
    /// told once — the client, the tool, the store's own words. Activity simply
    /// lacks the line (no second write, nothing synthesized).
    @Test func aLandedWriteWhoseLogFailsAnswersTheActsOwnAnswerAndTellsHer() async throws {
        // The twin: the same seed, the same calls, a log that works.
        let control = try ServerHarness(seed: 775)
        defer { control.tearDown() }
        let expected: String = try await control.within {
            let w = try await world(control)
            let answer = try await call(w.connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("A thought."),
            ])
            #expect(answer.isError != true, "the control lands: \(text(answer))")
            #expect(try activityLines(control, "add_comment") == ["allowed"], "non-vacuity: its line lands")
            #expect(control.onWriteReceipts.value.map(\.act) == [.comment] && control.tailReceipts.value.isEmpty
                    && control.activityLogFailures.value.isEmpty,
                    "F1: a call whose line landed sends its receipt through onWrite, never the tail")
            await control.hangUp(w.connection)
            return text(answer)
        }

        let h = try ServerHarness(seed: 775)
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h)
            try await h.database.write { db in try db.execute(sql: everyLineFails) }
            let answer = try await call(w.connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("A thought."),
            ])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(answer.isError != true, "RED ON OLD: a landed write is no error — \(text(answer))")
            #expect(text(answer) == expected, "RED ON OLD: the act's own answer, byte for byte the twin's")
            #expect(try liveComments(h, w.block) == 1, "the act landed (on both sides)")
            #expect(h.undoStack.depth == 1, "its client-named ⌥⌘Z entry stands")
            #expect(h.receipts.value.map(\.act) == [.comment], "RED ON OLD: her receipt is sent")
            #expect(h.onWriteReceipts.value.isEmpty && h.tailReceipts.value.map(\.act) == [.comment],
                    "F1: a failing call's receipt rides the ONE tail hook with the failure, never onWrite")
            #expect(h.activityLogFailures.value == [
                MCPActivityLogFailure(clientName: "claude-code", tool: "add_comment", unrecorded: 1, storeWords: storeWords),
            ], "RED ON OLD: the app is told — once, naming the client, the tool and the store's words")
            #expect(try activityLines(h, "add_comment").isEmpty, "Activity lacks the line — nothing synthesized")
            await h.hangUp(w.connection)
        }
    }

    /// **RED ON OLD.** The transient shape — only the LANDED line fails: the old
    /// road's catch-all wrote a second line, "refused", for an act that landed (and
    /// `list_my_activity` served it back to the client as its own refused act), and
    /// answered `isError`. Now: the act's answer, and NO false line.
    @Test func aTransientLogFailureNeverWritesARefusedLineForALandedAct() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h)
            try await h.database.write { db in try db.execute(sql: onlyTheLandedLineFails) }
            let answer = try await call(w.connection, "add_comment", [
                "block_id": .string(w.block), "text": .string("A thought."),
            ])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(answer.isError != true, "RED ON OLD: \(text(answer))")
            let landed = (try? json(answer)) ?? [:]   // old: the words, never JSON
            #expect(landed["block_id"] as? String == w.block && landed["note_id"] as? String == w.note.id
                    && landed["comment_id"] is String, "the act's own answer")
            #expect(try activityLines(h, "add_comment").isEmpty,
                    "RED ON OLD: no refused line for an act that landed")
            #expect(try liveComments(h, w.block) == 1)
            #expect(h.activityLogFailures.value.map(\.unrecorded) == [1])
            #expect(h.onWriteReceipts.value.isEmpty && h.tailReceipts.value.map(\.act) == [.comment], "F1")
            await h.hangUp(w.connection)
        }
    }

    /// **RED ON OLD.** A list form (VX-812): each item is the single call's own
    /// act, landing through the same body — so each landed item is LISTED as
    /// landed whatever its log did (old: every item read "refused" and a call that
    /// "landed nothing" answered `isError`), every landed item's receipt rides the
    /// call's run key, and the app is told ONCE, counting the items.
    @Test func aListCallsLandedItemsStayLandedAndHerLineCountsThem() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let one = try h.operations.createPost(title: "one")
            let two = try h.operations.createPost(title: "two")
            _ = try h.operations.createTag(name: "listed")
            let book = try h.operations.createReading(name: "Shelf", kind: .book)
            for note in [one, two] { _ = try h.operations.addPostToReading(note.id, to: book.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            try await h.database.write { db in try db.execute(sql: everyLineFails) }
            let result = try await call(connection, "apply_tag", [
                "note_ids": .array([.string(one.id), .string(two.id)]), "tag": .string("listed"),
            ])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(result.isError != true, "RED ON OLD: \(text(result))")
            let answer = try json(result)
            #expect(answer["landed_count"] as? Int == 2 && answer["refused_count"] as? Int == 0,
                    "RED ON OLD: both items landed and are listed so")
            let results = try #require(answer["results"] as? [[String: Any]])
            #expect(results.map { $0["changed"] as? Bool } == [true, true] && results.allSatisfy { $0["refused"] == nil })
            #expect(h.receipts.value.map(\.act) == [.tag, .tag], "RED ON OLD: each landed item's receipt")
            #expect(h.onWriteReceipts.value.isEmpty && h.tailReceipts.value.map(\.act) == [.tag, .tag]
                    && Set(h.tailReceipts.value.map(\.runKey)).count == 1 && h.tailReceipts.value[0].runKey != nil,
                    "F1: the list call's receipts — one run key — ride the tail together, never onWrite")
            #expect(h.activityLogFailures.value == [
                MCPActivityLogFailure(clientName: "claude-code", tool: "apply_tag", unrecorded: 2, storeWords: storeWords),
            ], "RED ON OLD: one line for the call, counting its items")
            #expect(h.undoStack.depth == 2, "each item's own entry")
            await h.hangUp(connection)
        }
    }

    /// **RED ON OLD.** `replace_tag` (VX-809's tag swap) — its own multi-act body,
    /// each wearer through the same landing: every swept note is REPLACED whatever
    /// its log did (old: each read "refused", and a call that replaced nothing
    /// answered `isError`), and the app is told once, counting them.
    @Test func aTagSwapsLandedNotesStayReplacedAndHerLineCountsThem() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let studio = try h.operations.createWing(name: "Studio")
            let a = try h.operations.createTag(name: "a", wingID: studio.id)
            var notes: [Container] = []
            for title in ["one", "two"] {
                let note = try h.operations.createPost(title: title, wingId: studio.id)
                _ = try h.operations.applyTag(a.id, toPost: note.id)
                notes.append(note)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, studio.id))
            try await h.database.write { db in try db.execute(sql: everyLineFails) }
            let result = try await call(connection, "replace_tag",
                                        ["wing_id": .string(studio.id), "tag": .string("#a"), "with": .string("b")])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(result.isError != true, "RED ON OLD: \(text(result))")
            let answer = (try? json(result)) ?? [:]
            #expect(answer["replaced"] as? [String] == notes.map(\.id) && answer["refused_count"] as? Int == 0,
                    "RED ON OLD: both notes replaced and listed so")
            #expect(h.receipts.value.map(\.act) == [.tagReplace, .tagReplace], "RED ON OLD")
            #expect(h.onWriteReceipts.value.isEmpty && h.tailReceipts.value.map(\.act) == [.tagReplace, .tagReplace],
                    "F1: the swap's receipts ride the tail, never onWrite")
            #expect(h.activityLogFailures.value == [
                MCPActivityLogFailure(clientName: "claude-code", tool: "replace_tag", unrecorded: 2, storeWords: storeWords),
            ], "RED ON OLD: one line for the call, counting its notes")
            await h.hangUp(connection)
        }
    }

    /// **RED ON OLD (the answer); the rest a GUARD.** What landed with the act
    /// stays landed — `edit_take` under a ONCE grant whose log fails: the take
    /// holds the new words, the bracket's savepoints are on file, the once grant is
    /// SPENT (one more write is never bought by a log failure), and the one
    /// client-named ⌥⌘Z entry stands.
    @Test func whatLandedWithTheActStaysLanded() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try await world(h, rung: .edit, duration: .once)
            let grant = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM mcp_grant WHERE duration = 'once' AND revoked_at IS NULL")
            })
            try await h.database.write { db in try db.execute(sql: everyLineFails) }
            let answer = try await call(w.connection, "edit_take", [
                "take_id": .string(w.take.id), "text": .string("Her line, rewritten."),
                "expected_text": .string("Her line."),
            ])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(answer.isError != true, "RED ON OLD: \(text(answer))")
            #expect((try? json(answer))?["changed"] as? Bool == true)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [w.take.id])
            } == "Her line, rewritten.", "the act landed")
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", arguments: [w.take.id])
            } == 2, "the bracket's before and after savepoints")
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grant])
            } != nil, "the once grant is spent")
            #expect(h.undoStack.depth == 1)
            #expect(h.activityLogFailures.value.map(\.tool) == ["edit_take"])
            #expect(h.onWriteReceipts.value.isEmpty && h.tailReceipts.value.count == 1, "F1")
            await h.hangUp(w.connection)
        }
    }

    /// **F1 (the ladder round 1 — the reviewer's final call; no red-on-old owed:
    /// it hardens this run's new ordering, not an old wrong output).** A NO-OP
    /// landing (`apply_tag` on a tag the note already wears — `changed: false`, no
    /// receipt, yet a landed Activity line) whose line fails: the answer is the
    /// no-op's own, and the tail hook carries the failure with NO receipts —
    /// nothing reaches `onWrite`.
    @Test func aNoOpLandingWhoseLogFailsHandsTheTailNoReceipts() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "worn")
            let tag = try h.operations.createTag(name: "listed")
            _ = try h.operations.applyTag(tag.id, toPost: note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            try await h.database.write { db in try db.execute(sql: everyLineFails) }
            let answer = try await call(connection, "apply_tag", ["note_id": .string(note.id), "tag": .string("listed")])
            try await h.database.write { db in try db.execute(sql: dropTrigger) }

            #expect(answer.isError != true, "\(text(answer))")
            #expect((try? json(answer))?["changed"] as? Bool == false, "the no-op's own answer")
            #expect(h.activityLogFailures.value.map(\.tool) == ["apply_tag"])
            #expect(h.tailReceipts.value.isEmpty && h.onWriteReceipts.value.isEmpty && h.receipts.value.isEmpty,
                    "the tail carried the failure with no receipts; nothing reached onWrite")
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both sides): the store-failure words, named once
    /// (`MCPStoreFailure`), are the chain's — the wire's sentence is unchanged for
    /// every store type, and anything else is no store failure.
    @Test func theStoreWordsAreNamedOnceAndTheChainsSentenceIsUnchanged() {
        let full = DatabaseError(
            resultCode: .SQLITE_FULL, message: "database or disk is full",
            sql: "UPDATE variant SET working_text = ? WHERE id = ?")
        let keyed = RedactedKeyedStatementError(
            description: "SQLite error 26: file is not a database - while executing `PRAGMA key = <store key redacted>`")
        #expect(MCPStoreFailure(full)?.detail == "SQLite error 13: database or disk is full")
        #expect(MCPStoreFailure(keyed)?.detail == nil && MCPStoreFailure(keyed) != nil)
        #expect(MCPStoreFailure(StoreLockedError())?.detail == "the library is locked")
        #expect(MCPStoreFailure(OperationError.containerNotFound(id: "x")) == nil)
        #expect(MCPWireRefusalCopy.spoken(full) { _ in nil }
                == MCPWireRefusalCopy.storeFailureWords("SQLite error 13: database or disk is full"))
        #expect(MCPWireRefusalCopy.spoken(StoreLockedError()) { _ in nil }
                == MCPWireRefusalCopy.storeFailureWords("the library is locked"))
    }
}
