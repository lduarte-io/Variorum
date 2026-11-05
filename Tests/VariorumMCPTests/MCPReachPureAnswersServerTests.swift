import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-825 (the VX-809 run, batch 1 — her ruling R-825, 2026-11-04: "every MCP
// answer is a PURE FUNCTION OF THE CLIENT'S REACHABLE STATE — nothing on the wire
// may vary with what the client cannot reach"). The counted-not-named class
// RETIRES: `remove_tag`'s `still_in_books_hidden_count`, `duplicate_note`'s
// `landed` "a book not shared with you", and `move_note_to_wing`'s `left_books`
// arm that listed an UNREADABLE book by its id. In their place one fixed
// sentence (`beyond_reach`, PROVISIONAL P-809-1), byte-identical whether hidden
// things exist or not; the reach-NAMED parts stay.
//
// Each pin builds the SAME reachable world in two stores — one where hidden
// books exist, one where none do — through the same calls in the same order (so
// every reachable id and stamp aligns: `ServerHarness`'s incrementing ids and
// ticking clock), the hidden rows minted by a SEPARATE operations value with its
// own id space and clock (`hiddenOperations`), then makes the same wire call in
// both and asserts the two answers are BYTE-IDENTICAL.
//
// RED ON OLD (run on the pre-fix tree, `56a3a7334`): each pin's two answers
// differed — the count, the "not shared with you" words, the unreadable book's
// id — and none carried `beyond_reach`.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// **The hidden half of a two-store world** — an operations value on the SAME
/// store with its OWN ids (`F0000000-…`, never the harness's incrementing
/// space) and its OWN clock (a day before the harness's), so minting hidden
/// rows moves neither the reachable ids nor the reachable stamps.
func hiddenOperations(_ h: ServerHarness) -> Operations {
    let counter = LockIsolated(0)
    let tick = LockIsolated(0)
    let start = Date(timeIntervalSince1970: 1_782_864_000 - 86_400)
    return withDependencies {
        $0.database = h.database
        $0.uuid = UUIDGenerator {
            let n = counter.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return UUID(uuidString: String(format: "F0000000-0000-0000-0000-%012X", n))!
        }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
    } operation: { Operations() }
}

@Suite("VX-825 — the counted arms retire: answers are a pure function of reach", .serialized)
struct MCPReachPureAnswersServerTests {
    private func rule(_ term: RuleTerm) throws -> String? { try RuleGrammar.encode(term) }

    /// Runs `world` in two fresh stores — `hidden` true then false — and
    /// returns each store's answer text (and whether it was an error).
    private func twoStores(
        _ world: (ServerHarness, Bool) async throws -> (content: [Tool.Content], isError: Bool?)
    ) async throws -> (withHidden: (String, Bool), without: (String, Bool)) {
        var answers: [(String, Bool)] = []
        for hidden in [true, false] {
            let h = try ServerHarness()
            defer { h.tearDown() }
            let result = try await h.within { try await world(h, hidden) }
            answers.append((text(result), result.isError == true))
        }
        return (answers[0], answers[1])
    }

    // MARK: - remove_tag: still_in_books_hidden_count retires

    /// The note is in the readable board "Board" (the client's EDIT book
    /// grant) and — in the hidden store only — in an unshared board of the
    /// same wing that collects by the same tag. The answer names the readable
    /// board, counts nothing, and carries the scope words: identical bytes.
    @Test func removeTagAnswersTheSameWhetherAnUnreadableBookStillHoldsTheNote() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let board = try h.operations.createTag(name: "board")
            let open = try h.operations.createReading(name: "Board", kind: .book, querySpec: try rule(.tag(board.id)))
            let note = try h.operations.createPost(title: "card")
            _ = try h.operations.newBlock(in: note.id, text: "Ship it.", registeringUndo: false)
            _ = try h.operations.applyTag(board.id, toPost: note.id)
            if hidden {
                let ops = hiddenOperations(h)
                // A living book's creation backfills: it seats the tagged note.
                _ = try ops.createReading(name: "Secret board", kind: .book, querySpec: try rule(.tag(board.id)))
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, open.id))
            let removed = try await connection.client.callTool(
                name: "remove_tag", arguments: ["note_id": .string(note.id), "tag": .string("board")])
            await h.hangUp(connection)
            return removed
        }
        #expect(!withHidden.1 && !without.1, "both land: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        let answer = try #require(try JSONSerialization.jsonObject(with: Data(withHidden.0.utf8)) as? [String: Any])
        #expect(answer["still_in_books_hidden_count"] == nil, "the count retired: \(answer)")
        #expect((answer["still_in_books"] as? [[String: Any]])?.map { $0["name"] as? String } == ["Board"],
                "the readable board is still named: \(answer)")
        #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords,
                "the scope words ride: \(answer)")
        #expect(!withHidden.0.contains("F0000000"), "no hidden id crosses")
    }

    /// Only an unreadable book still holds the note (the client reads no
    /// board at all): the hidden store's answer is exactly the answer of a
    /// store where nothing holds it — an empty named list and the scope words.
    @Test func removeTagWithOnlyAnUnreadableHolderAnswersAsIfNothingHeldIt() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let board = try h.operations.createTag(name: "board")
            let note = try h.operations.createPost(title: "card")
            _ = try h.operations.newBlock(in: note.id, text: "Ship it.", registeringUndo: false)
            _ = try h.operations.applyTag(board.id, toPost: note.id)
            if hidden {
                let ops = hiddenOperations(h)
                // A living book's creation backfills: it seats the tagged note.
                _ = try ops.createReading(name: "Secret board", kind: .book, querySpec: try rule(.tag(board.id)))
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            let removed = try await connection.client.callTool(
                name: "remove_tag", arguments: ["note_id": .string(note.id), "tag": .string("board")])
            await h.hangUp(connection)
            return removed
        }
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        let answer = try #require(try JSONSerialization.jsonObject(with: Data(without.0.utf8)) as? [String: Any])
        #expect((answer["still_in_books"] as? [Any])?.isEmpty == true, "an empty list, always present: \(answer)")
        #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
    }

    // MARK: - duplicate_note: landed's "a book not shared with you" retires

    /// The wing road: the client holds write new on Home; in the hidden store a
    /// PRIVATE living book collects the note's tag, so with_tags seats the copy
    /// there. `landed` reads the same Pool words in both stores (it can name
    /// only what the client reads), and the scope words ride beside it.
    @Test func duplicateLandedReadsTheSameWhenAPrivateBookTakesTheCopyIn() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let idea = try h.operations.createTag(name: "idea")
            let note = try h.operations.createPost(title: "seed")
            _ = try h.operations.newBlock(in: note.id, text: "A thought.", registeringUndo: false)
            _ = try h.operations.applyTag(idea.id, toPost: note.id)
            if hidden {
                let ops = hiddenOperations(h)
                // Its creation backfills the source in; taking the source out
                // again leaves it unfenced (a decided pair) — the Private book
                // then hears only the COPY's tagging.
                let diary = try ops.createReading(name: "Diary", kind: .book, querySpec: try rule(.tag(idea.id)))
                _ = try ops.setBookPrivate(diary.id, true)
                _ = try ops.removePostFromReading(note.id, from: diary.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let duplicated = try await connection.client.callTool(
                name: "duplicate_note", arguments: ["note_id": .string(note.id), "brief": .bool(true)])
            await h.hangUp(connection)
            return duplicated
        }
        #expect(!withHidden.1 && !without.1, "both land: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        #expect(!withHidden.0.contains("not shared with you"), "the counted words retired: \(withHidden.0)")
        let answer = try #require(try JSONSerialization.jsonObject(with: Data(withHidden.0.utf8)) as? [String: Any])
        #expect(answer["landed"] as? String == "the Pool of Home", "\(answer)")
        #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
    }

    /// The book road: filed into the readable book "Drafts" (write new on it,
    /// read through it); in the hidden store an UNSHARED living book of the
    /// same wing collects the copy's tag and takes it in too. `landed` names
    /// the filing only, in both stores.
    @Test func duplicateLandedIntoABookNamesOnlyWhatTheClientReads() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let idea = try h.operations.createTag(name: "idea")
            let drafts = try h.operations.createReading(name: "Drafts", kind: .book)
            let note = try h.operations.createPost(title: "seed")
            _ = try h.operations.newBlock(in: note.id, text: "A thought.", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: drafts.id)
            _ = try h.operations.applyTag(idea.id, toPost: note.id)
            if hidden {
                let ops = hiddenOperations(h)
                _ = try ops.createReading(name: "Ideas", kind: .book, querySpec: try rule(.tag(idea.id)))
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, drafts.id))
            let duplicated = try await connection.client.callTool(
                name: "duplicate_note",
                arguments: ["note_id": .string(note.id), "book_id": .string(drafts.id), "brief": .bool(true)])
            await h.hangUp(connection)
            return duplicated
        }
        #expect(!withHidden.1 && !without.1, "both land: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        let answer = try #require(try JSONSerialization.jsonObject(with: Data(withHidden.0.utf8)) as? [String: Any])
        #expect(answer["landed"] as? String == "the end of \u{201C}Drafts\u{201D}", "\(answer)")
        #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
    }

    // MARK: - move_note_to_wing: left_books' unreadable arm retires

    /// The note sits in the readable book "Alpha" (the client's EDIT book
    /// grant) and — in the hidden store — in an unshared book of Home. The
    /// move severs both; `left_books` names Alpha only — no id of the unshared
    /// book crosses — and the scope words ride.
    @Test func moveNoteToWingLeftBooksListsOnlyReadableBooks() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let wing = try h.operations.createWing(name: "variorum")
            let alpha = try h.operations.createReading(name: "Alpha", kind: .book)
            let note = try h.operations.createPost(title: "parser notes")
            _ = try h.operations.newBlock(in: note.id, text: "the lexer comes first", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: alpha.id)
            if hidden {
                let ops = hiddenOperations(h)
                let beta = try ops.createReading(name: "Beta", kind: .book)
                _ = try ops.addPostToReading(note.id, to: beta.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, alpha.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, wing.id))
            let moved = try await connection.client.callTool(
                name: "move_note_to_wing", arguments: ["note_id": .string(note.id), "wing_id": .string(wing.id)])
            await h.hangUp(connection)
            return moved
        }
        #expect(!withHidden.1 && !without.1, "both land: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        #expect(!withHidden.0.contains("F0000000"), "no unreadable book's id crosses: \(withHidden.0)")
        let answer = try #require(try JSONSerialization.jsonObject(with: Data(withHidden.0.utf8)) as? [String: Any])
        #expect((answer["left_books"] as? [[String: Any]])?.map { $0["name"] as? String } == ["Alpha"], "\(answer)")
        #expect(answer[MCPWriteTools.beyondReachKey] as? String == MCPWriteTools.beyondReachWords)
    }

    // MARK: - The descriptions say the new shape

    @Test func theThreeDescriptionsSayTheScopeWordsAndNoCount() throws {
        for name in ["remove_tag", "duplicate_note", "move_note_to_wing"] {
            let description = try #require(MCPToolCatalog.declaration(named: name)).description
            #expect(description.contains(MCPWriteTools.beyondReachKey), "\(name) names the scope key: \(description)")
            #expect(!description.contains("hidden_count") && !description.contains("not shared with you")
                    && !description.contains("counts"), "\(name) promises no count: \(description)")
        }
    }
}
