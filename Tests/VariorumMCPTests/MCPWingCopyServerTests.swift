import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-765 (the VX-771 run, batch 1): `copy_note_to_wing` — HER ⇧⌥⌘L COPY TO WING
// ON THE WIRE (VX-632; VX-368's parity class). The field report's #11: copying a
// note into another wing took `duplicate_note` + `move_note_to_wing` (two calls,
// two undo entries, the duplicate's whole per-block answer between). The tool
// wraps HER door's body (`Operations.copyNoteToWing(_:_:to:)` — `copyPost`'s
// family born in the destination, the note's tags ADOPTED there by path as row
// copies no intake hears, bookless in that wing's Pool), decided at READ on the
// source and WRITE NEW on the destination wing (`duplicate_note`'s two-sided
// shape, the once grants of both sides spent as one union inside the act), a
// fenced source refusing in one sentence naming no leg (P-VX311-1's shape), the
// note's own wing refusing in words (her door never offers it), ONE client-named
// ⌥⌘Z, and VX-766's brief answer.
//
// Wire only (the SDK's own client over a real socket). RED ON OLD by ABSENCE:
// on the tree before it every call answered `Unknown tool: copy_note_to_wing.`

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

private func rule(_ term: RuleTerm) throws -> String {
    try #require(try RuleGrammar.encode(term))
}

/// The fence's one sentence — no leg named.
private let fencedWords =
    "This note is shared with you only per ask, so it can't be copied to another wing \u{2014} a copy would "
    + "reach further than the note does. The author can copy it in Variorum."

private let sameWingWords =
    "That note is already in that wing, and copy_note_to_wing copies a note into another wing \u{2014} "
    + "to copy it within its own wing, use duplicate_note."

@Suite("VX-765 — copy_note_to_wing: her Copy to Wing on the wire", .serialized)
struct MCPWingCopyServerTests {
    private func liveNotes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
        }
    }

    private func consumed(_ h: ServerHarness, _ grantID: String?) async throws -> Bool {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grantID]) != nil
        }
    }

    private func activityCount(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0 }
    }

    // MARK: - The landing, the answer, the tags, the undo, the receipt

    /// READ on the note + WRITE NEW on another wing lands her door's copy bookless in that
    /// wing's Pool: every block and take, the tags ADOPTED by path (an existing same-path tag
    /// there takes the application; a missing path is made there), heard by NO book there (row
    /// copies — her door's letter); the source untouched. The answer is the brief record, its
    /// counts the store's; ONE client-named ⌥⌘Z; the receipt names the wing and opens the copy.
    @Test func theCopyLandsBooklessInTheOtherWingsPoolAndAnswersBrief() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let source = try h.operations.createPost(title: "field notes")
            _ = try h.operations.addPostToReading(source.id, to: book.id)
            _ = try h.operations.newBlock(in: source.id, text: "One.", registeringUndo: false)
            let two = try h.operations.newBlock(in: source.id, text: "Two.", registeringUndo: false)
            let again = try h.operations.branchVariant(two.block.id, from: two.variant.id)
            try h.operations.autosave(again.id, text: "Two, again.", charDelta: 7)
            try h.operations.chooseVariant(two.block.id, variantID: again.id)
            let essay = try h.operations.createTag(name: "essay")
            let draft = try h.operations.createTag(name: "draft")
            _ = try h.operations.applyTag(essay.id, toPost: source.id)
            _ = try h.operations.applyTag(draft.id, toPost: source.id)
            // The destination already speaks "essay" — and a living book there collects it.
            let theirEssay = try h.operations.createTag(name: "essay", wingID: research.id)
            let living = try h.operations.createReading(
                name: "collected", kind: .book, querySpec: try rule(.tag(theirEssay.id)), wingId: research.id)
            let sourceText = try await h.database.read { try Queries.renderedText($0, containerID: source.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, research.id))
            let depth = h.undoStack.depth

            let copied = try await call(connection, "copy_note_to_wing",
                                        ["note_id": .string(source.id), "wing_id": .string(research.id)])
            #expect(copied.isError != true, "\(text(copied))")
            let answer = try json(copied)
            #expect(Set(answer.keys) == ["note_id", "source_note_id", "wing_id", "tag_ids", "tags", "landed",
                                         "block_count", "take_count", "fan_sha256"],
                    "the brief record (A-771-2: its fan digest always present) — no per-block dump")
            let copyID = try #require(answer["note_id"] as? String)
            #expect(copyID != source.id && answer["source_note_id"] as? String == source.id)
            #expect(answer["wing_id"] as? String == research.id)
            #expect(answer["landed"] as? String == "the Pool of \u{201C}research\u{201D}")
            #expect(answer["block_count"] as? Int == 2 && answer["take_count"] as? Int == 3)

            // The copy: in that wing, bookless, the same words, the tags adopted by path.
            let (wing, memberships, worn) = try await h.database.read { db in
                (try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [copyID]),
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                  arguments: [copyID]),
                 try Row.fetchAll(db, sql: """
                     SELECT t.id, t.path, t.wing_id FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                     WHERE pt.post_id = ? AND pt.deleted_at IS NULL ORDER BY pt.created_at, pt.id
                     """, arguments: [copyID]).map { [$0["id"] as String, $0["path"] as String, $0["wing_id"] as String] })
            }
            #expect(wing == research.id && memberships == 0, "bookless in the destination — no book heard its tags")
            #expect(worn.map { $0[1] } == ["essay", "draft"])
            #expect(worn.allSatisfy { $0[2] == research.id }, "every tag the destination's")
            #expect(worn.first?[0] == theirEssay.id, "the same-path tag ADOPTS")
            #expect(answer["tag_ids"] as? [String] == worn.map { $0[0] })
            #expect(answer["tags"] as? [String] == ["essay", "draft"])
            #expect(try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?", arguments: [living.id])
            } == 0, "the living book there neither seats nor bells it")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: copyID) } == sourceText)

            // The counts are the store's (write new on the wing reads the copy).
            let read = try json(try await call(connection, "read_note",
                                               ["note_id": .string(copyID), "ids_only": .bool(true)]))
            let blocks = read["blocks"] as? [[String: Any]] ?? []
            #expect(blocks.count == 2 && blocks.reduce(0) { $0 + (($1["takes"] as? [Any])?.count ?? 0) } == 3)

            // The source untouched: its wing, its book, its tags.
            let (sourceWing, sourceBooks) = try await h.database.read { db in
                (try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [source.id]),
                 try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                                  arguments: [source.id]))
            }
            #expect(sourceWing == "" && sourceBooks == 1)

            // ONE client-named entry; the receipt names the wing and opens the copy.
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's wing copy")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .wingCopy && receipt.targetID == research.id && receipt.targetTitle == "research")
            #expect(receipt.detail == "field notes")
            #expect(receipt.show == .note(noteID: copyID, blockID: nil, select: nil), "Open › opens the copy")

            // Her ⌥⌘Z takes the copy away (into the Trash); ⇧⌥⌘Z brings it back.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's wing copy")
            #expect(try await h.database.read { try Container.fetchOne($0, key: copyID)?.deletedAt } != nil)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's wing copy")
            #expect(try await h.database.read { try Container.fetchOne($0, key: copyID)?.deletedAt } == nil)
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: copyID) } == sourceText)
            await h.hangUp(connection)
        }
    }

    /// Home is a place-name — said unquoted — and an EMPTY note copies as her door's bare note.
    @Test func aCopyIntoHomeAndAnEmptyNotesBareCopy() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let empty = try h.operations.createPost(title: "nothing yet", wingId: research.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, research.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, ""))

            let copied = try await call(connection, "copy_note_to_wing",
                                        ["note_id": .string(empty.id), "wing_id": .string("")])
            #expect(copied.isError != true, "\(text(copied))")
            let answer = try json(copied)
            #expect(answer["landed"] as? String == "the Pool of Home")
            #expect(answer["block_count"] as? Int == 0 && answer["take_count"] as? Int == 0)
            #expect(answer["fan_sha256"] as? String
                    == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                    "no blocks: the SHA-256 of the empty text")
            let copyID = try #require(answer["note_id"] as? String)
            #expect(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [copyID])
            } == "")
            #expect(h.receipts.value.last?.targetTitle == Queries.mcpHomeWingName)
            await h.hangUp(connection)
        }
    }

    /// **A-771-1 (fork F-1, option (b)):** an undated, untitled source's copy in the other
    /// wing keeps the day its source is named for — stored as its `entry_date`, its name (the
    /// one display rule, `mcpScopeTitle`) the source's, and the receipt naming it so. **RED ON
    /// OLD** (the tree before A-771-1): `entry_date` NULL, the copy named for the harness day.
    @Test func anUndatedUntitledSourcesWingCopyIsNamedAndDatedAsItsSource() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let source = try h.operations.createPost(title: nil)
            _ = try h.operations.newBlock(in: source.id, text: "Morning pages.", registeringUndo: false)
            let bornOn = Date(timeIntervalSince1970: 1_781_956_800)  // 2026-06-20T12:00:00Z
            try await h.database.write { db in
                try db.execute(
                    sql: "UPDATE container SET created_at = ? WHERE id = ?",
                    arguments: [DateFormatter.variorumISO8601.string(from: bornOn), source.id])
            }
            let day = JournalDay.dayString(from: bornOn, calendar: JournalDay.storeCalendar)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, research.id))

            let copied = try await call(connection, "copy_note_to_wing",
                                        ["note_id": .string(source.id), "wing_id": .string(research.id)])
            #expect(copied.isError != true, "\(text(copied))")
            let copyID = try #require(try json(copied)["note_id"] as? String)
            let (stored, copyName) = try await h.database.read { db in
                (try Container.fetchOne(db, key: copyID),
                 try Queries.mcpScopeTitle(db, kind: .note, id: copyID, calendar: JournalDay.storeCalendar))
            }
            #expect(stored?.entryDate == day, "the copy keeps the day its source is named for")
            #expect(stored?.title == nil, "no title is materialized")
            #expect(copyName == day, "the copy is NAMED as its source is")
            #expect(h.receipts.value.last?.detail == day, "the receipt names the note by that day")
            await h.hangUp(connection)
        }
    }

    // MARK: - The note's own wing (her door never offers it)

    /// The wing the note already lives in refuses in words naming the road that copies within
    /// a wing — nothing minted, nothing asked, nothing spent.
    @Test func theNotesOwnWingRefusesInWordsAndAsksNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let source = try h.operations.createPost(title: "home note")
            _ = try h.operations.newBlock(in: source.id, text: "Here.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            let once = try h.approve("claude-code", spec(.writeNew, .wing, "", .once))
            let notes = try await liveNotes(h)

            let refused = try await call(connection, "copy_note_to_wing",
                                         ["note_id": .string(source.id), "wing_id": .string("")])
            #expect(refused.isError == true && text(refused) == sameWingWords, "\(text(refused))")
            let spent = try await consumed(h, once)
            #expect(!spent, "a refused act spends nothing")
            #expect(try await liveNotes(h) == notes && h.asks.value.isEmpty && h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - The one not-shared shape (no oracle)

    /// Missing, tombstoned, a saved version, a scraps group, an unshared wing's note, an
    /// UNREACHED Private note: each byte-identical to an id naming nothing; nothing minted.
    @Test func anUnreachableSourceAnswersTheOneNotSharedShapeAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let elsewhere = try h.operations.createWing(name: "elsewhere")
            let foreign = try h.operations.createPost(title: "theirs", wingId: elsewhere.id)
            _ = try h.operations.newBlock(in: foreign.id, text: "Not yours.", registeringUndo: false)
            let kept = try h.operations.createPost(title: "kept")
            _ = try h.operations.newBlock(in: kept.id, text: "Kept.", registeringUndo: false)
            let version = try h.operations.saveNoteVersion(kept.id)
            let gone = try h.operations.createPost(title: "gone")
            _ = try h.operations.newBlock(in: gone.id, text: "Gone.", registeringUndo: false)
            try h.operations.deleteContainer(gone.id)
            let scraps = try h.operations.createPool(title: "scraps")
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.newBlock(in: hidden.id, text: "Private words.", registeringUndo: false)
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, research.id))
            let notes = try await liveNotes(h)

            let unknown = try await call(connection, "copy_note_to_wing",
                                         ["note_id": .string("no-such-note"), "wing_id": .string(research.id)])
            #expect(unknown.isError == true && text(unknown) == MCPRefusalCopy.words(.notShared, .note), "the ONE answer")
            for id in [foreign.id, version.post.id, gone.id, scraps.id, hidden.id] {
                let refused = try await call(connection, "copy_note_to_wing",
                                             ["note_id": .string(id), "wing_id": .string(research.id)])
                #expect(refused.isError == true && text(refused) == text(unknown),
                        "\(id) answers byte-identically to an id naming nothing")
            }
            #expect(try await liveNotes(h) == notes && h.undoStack.depth == 0, "nothing minted, no entry")
            await h.hangUp(connection)
        }
    }

    // MARK: - The landing's reach: a wing at write new, never a note or a book

    /// A client that can read the note but holds no write new on the destination — only read
    /// there, or write new on a BOOK there — hears the wing's refusal, and her ask is for that
    /// WING at write new.
    @Test func aDestinationWithoutWingWriteNewHearsTheWingsRefusalAndAsksForTheWing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let theirBook = try h.operations.createReading(name: "their book", kind: .book, wingId: research.id)
            let source = try h.operations.createPost(title: "to copy")
            _ = try h.operations.newBlock(in: source.id, text: "Words.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .wing, research.id))
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .book, theirBook.id))
            let notes = try await liveNotes(h)

            let refused = try await call(connection, "copy_note_to_wing",
                                         ["note_id": .string(source.id), "wing_id": .string(research.id)])
            #expect(refused.isError == true)
            #expect(text(refused) == MCPRefusalCopy.words(.rungTooLow(granted: .read), .wing, asked: true),
                    "\(text(refused))")
            let ask = try #require(h.asks.value.last)
            #expect(ask.scopeKind == .wing && ask.scopeID == research.id && ask.rung == .writeNew,
                    "her ask is for the wing the copy would land in")
            #expect(try await liveNotes(h) == notes)

            // An unshared destination answers the ONE not-shared shape for a wing.
            let unshared = try h.operations.createWing(name: "unshared")
            let hiddenWing = try await call(connection, "copy_note_to_wing",
                                            ["note_id": .string(source.id), "wing_id": .string(unshared.id)])
            #expect(hiddenWing.isError == true && text(hiddenWing) == MCPRefusalCopy.words(.notShared, .wing))
            let noWing = try await call(connection, "copy_note_to_wing",
                                        ["note_id": .string(source.id), "wing_id": .string("no-such-wing")])
            #expect(text(noWing) == text(hiddenWing), "hidden and missing read the same")
            #expect(try await liveNotes(h) == notes)
            await h.hangUp(connection)
        }
    }

    // MARK: - The fence (P-VX311-1's shape)

    /// A Private note and a journal entry the client reads through its own PER-ASK grant refuse
    /// in one sentence naming no leg — a copy would shed the fence — and nothing is minted,
    /// nothing asked.
    @Test func aFencedSourceUnderAPerAskGrantRefusesInOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let secret = try h.operations.createPost(title: "secret")
            _ = try h.operations.newBlock(in: secret.id, text: "Mine.", registeringUndo: false)
            _ = try h.operations.setNotePrivate(secret.id, true)
            let entry = try h.operations.createPost(title: "an entry", profile: .journal)
            _ = try h.operations.newBlock(in: entry.id, text: "Today.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, research.id))
            let client = try h.client("claude-code").id
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, secret.id, .connection))
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, entry.id, .connection))
            #expect(try await call(connection, "read_note", ["note_id": .string(secret.id)]).isError != true,
                    "the premise: the client CAN read it, per ask")
            let notes = try await liveNotes(h)
            let asks = h.asks.value.count

            for id in [secret.id, entry.id] {
                let refused = try await call(connection, "copy_note_to_wing",
                                             ["note_id": .string(id), "wing_id": .string(research.id)])
                #expect(refused.isError == true && text(refused) == fencedWords, "\(text(refused))")
            }
            #expect(try await liveNotes(h) == notes && h.undoStack.depth == 0 && h.asks.value.count == asks,
                    "nothing minted, no entry, nothing asked")
            await h.hangUp(connection)
        }
    }

    // MARK: - Once grants: both sides as one union; a refused act spends nothing

    @Test func onceGrantsOnBothSidesSpendAsOneAndARefusedActSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let source = try h.operations.createPost(title: "once")
            _ = try h.operations.newBlock(in: source.id, text: "Once.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            let noteGrant = try h.approve("claude-code", spec(.read, .note, source.id, .once))

            let refused = try await call(connection, "copy_note_to_wing",
                                         ["note_id": .string(source.id), "wing_id": .string(research.id)])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.notShared, .wing))
            let spentByRefusal = try await consumed(h, noteGrant)
            #expect(!spentByRefusal, "a refused act spends nothing")

            let wingGrant = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .wing, research.id, .once))
            let landed = try await call(connection, "copy_note_to_wing",
                                        ["note_id": .string(source.id), "wing_id": .string(research.id)])
            #expect(landed.isError != true, "\(text(landed))")
            let noteSpent = try await consumed(h, noteGrant)
            let wingSpent = try await consumed(h, wingGrant)
            #expect(noteSpent && wingSpent, "both sides spent, as one")
            let notes = try await liveNotes(h)
            let again = try await call(connection, "copy_note_to_wing",
                                       ["note_id": .string(source.id), "wing_id": .string(research.id)])
            let notesAfter = try await liveNotes(h)
            #expect(again.isError == true && notesAfter == notes, "spent is spent")
            await h.hangUp(connection)
        }
    }

    // MARK: - The call door and the parse

    /// VX-606 enforces the declared schema at the call door: an argument the tool does not
    /// declare (`brief` — `duplicate_note`'s, not this tool's) refuses before any decision —
    /// nothing read, written, asked, spent or logged.
    @Test func anUndeclaredArgumentRefusesBeforeAnyDecision() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let research = try h.operations.createWing(name: "research")
            let source = try h.operations.createPost(title: "door")
            _ = try h.operations.newBlock(in: source.id, text: "Door.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            let noteGrant = try h.approve("claude-code", spec(.read, .note, source.id, .once))
            let wingGrant = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .wing, research.id, .once))
            let notes = try await liveNotes(h)
            let logged = try await activityCount(h)

            let refused = try await call(connection, "copy_note_to_wing", [
                "note_id": .string(source.id), "wing_id": .string(research.id), "brief": .bool(true),
            ])
            #expect(refused.isError == true)
            #expect(text(refused) == "brief isn't an argument of copy_note_to_wing, so nothing was done — "
                    + "send only the arguments its input schema lists.")
            let noteSpent = try await consumed(h, noteGrant)
            let wingSpent = try await consumed(h, wingGrant)
            #expect(!noteSpent && !wingSpent, "nothing spent")
            #expect(try await liveNotes(h) == notes && h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            #expect(try await activityCount(h) == logged && h.asks.value.isEmpty, "nothing logged, nothing asked")
            await h.hangUp(connection)
        }
    }

    @Test func aCallMissingANoteOrAWingIsRefusedAtTheParse() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            let noNote = try await call(connection, "copy_note_to_wing", ["wing_id": .string("")])
            #expect(noNote.isError == true && text(noNote) == "note_id is required.")
            let noWing = try await call(connection, "copy_note_to_wing", ["note_id": .string("x")])
            #expect(noWing.isError == true && text(noWing) == "wing_id is required (\"\" is Home).")
            await h.hangUp(connection)
        }
    }

    // MARK: - Listed where it can act (P-2 on the wire)

    /// Listed under a wing grant at write new — the one grant that can name where a bookless
    /// copy lands — and not under a note grant or a book's write new alone.
    @Test func itIsListedOnlyWhereItCanLand() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "a note")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            let client = try h.client("claude-code").id
            let bookGrant = try h.operations.grantMCPAccess(client, spec(.writeNew, .book, book.id))
            #expect(!(try await connection.client.listTools().tools.map(\.name)).contains("copy_note_to_wing"),
                    "a note grant and a book's write new can never land a copy in another wing")
            _ = bookGrant
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .wing, ""))
            #expect(try await connection.client.listTools().tools.map(\.name).contains("copy_note_to_wing"))
            await h.hangUp(connection)
        }
    }
}
