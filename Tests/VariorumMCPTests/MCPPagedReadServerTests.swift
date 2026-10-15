import CryptoKit
import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-256 (VX-336 U7 — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U7 UNIT RECORD D-256-1…10 and THE ORCHESTRATOR'S RULINGS ON U7's FORKS: F-256-1…7 all
// (a); P-VX256-1's numbers 50 / 200 / 32,000): A BIG NOTE READS IN PAGES. Her bilingual
// book's chapters read `with_ids` at 100–133k characters — past the client's tool-output
// cap, so the answer spilled to a file and an agent without a filesystem could not check
// its own work. `read_note` now pages: `limit` (blocks per page, 1–200, 50 with a cursor
// alone) and `cursor` (the previous page's `next_cursor`), a page also ending once its
// takes' text passes 32,000 characters (a block is never split; the first block always
// rides whole). `ids_only` answers each take's `sha256` in place of its text, so a whole
// note is checked against a source cheaply. Every page is the with-ids object; the first
// says `block_count`; `next_cursor` comes back only while blocks remain.
//
// U7c (P-VX256-1 re-ruled — THE ORCHESTRATOR ON U7's WINDOW): the page budget now bounds
// the WHOLE SERIALIZED ANSWER, not the take text — a page ends at `limit` blocks or as soon
// as the next block would carry the answer past 32,000 characters (a block larger than
// what its page has left comes alone). The two pins whose meaning that changed are
// re-pinned below, each edit commented; `MCPPageAnswerBudgetServerTests` pins the rule.
//
// Wire only (the SDK's own client over a real socket). Each pin compiles on the tree
// before VX-256 — the new arguments are named by string, every expected digest is the
// test's own CryptoKit — so the red pins run RED there by absence (the old tree ignores
// the new arguments and answers the whole note). The GUARDS (the fence; every form
// without the new asks byte-for-byte) are green on both sides by design.

private func spec(
    _ kind: MCPGrantRule.ScopeKind, _ id: String, _ rung: MCPGrantRule.Rung = .read,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// `read_note`, the tool this suite reads.
private func call(
    _ connection: HarnessConnection, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await call(connection, "read_note", arguments)
}

/// The test's own digest — plain SHA-256 of the UTF-8 bytes, lowercase hex.
private func digest(_ text: String) -> String {
    SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
}

/// A JSON value as one canonical string (sorted keys) — equal values, equal strings.
private func canonical(_ value: Any) -> String {
    guard JSONSerialization.isValidJSONObject(value) || value is String || value is NSNumber,
          let data = try? JSONSerialization.data(
              withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes, .fragmentsAllowed])
    else { return "<not JSON: \(value)>" }
    return String(decoding: data, as: UTF8.self)
}

private func blocks(_ page: [String: Any]) -> [[String: Any]] {
    page["blocks"] as? [[String: Any]] ?? []
}

/// Every page of a paged read, following `next_cursor` (bounded — a server that never
/// ends its pages fails here, never hangs). The first call carries `arguments`; each later
/// call carries them plus the cursor.
private func pages(
    _ connection: HarnessConnection, _ arguments: [String: Value], cap: Int = 60
) async throws -> [[String: Any]] {
    var answers: [[String: Any]] = []
    var cursor: String?
    repeat {
        var args = arguments
        if let cursor { args["cursor"] = .string(cursor) }
        let answer = try await call(connection, args)
        #expect(answer.isError != true, "page \(answers.count + 1): \(text(answer))")
        let page = try json(answer)
        answers.append(page)
        cursor = page["next_cursor"] as? String
    } while cursor != nil && answers.count < cap
    return answers
}

/// A note of `count` blocks in a book the client reads (always): block `i`'s text is
/// `text(i)`, each block one take.
private struct LongNote {
    let book: Reading
    let note: Container
    let blockIDs: [String]
    let takeIDs: [String]
}

private func longNote(
    _ h: ServerHarness, title: String = "long", count: Int, text: (Int) -> String
) throws -> LongNote {
    let book = try h.operations.createReading(name: "drafts \(title)", kind: .book)
    let note = try h.operations.createPost(title: title)
    _ = try h.operations.addPostToReading(note.id, to: book.id)
    var blockIDs: [String] = []
    var takeIDs: [String] = []
    for index in 0..<count {
        let minted = try h.operations.newBlock(in: note.id, text: text(index), registeringUndo: false)
        blockIDs.append(minted.block.id)
        takeIDs.append(minted.variant.id)
    }
    return LongNote(book: book, note: note, blockIDs: blockIDs, takeIDs: takeIDs)
}

private func numbered(_ index: Int) -> String { String(format: "Block %03d, in its own words.", index + 1) }

@Suite("VX-256 — read_note in pages, and ids_only", .serialized)
struct MCPPagedReadServerTests {
    // MARK: - P-256-1: pages tile the note

    /// A 7-block note read with `limit: 3` comes back as 3 + 3 + 1; `next_cursor` on the
    /// first two pages only; `block_count` (7) on the first page only; and the pages'
    /// blocks, concatenated, equal the unpaged with-ids blocks entry for entry.
    @Test func pagesTileTheNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 7, text: numbered)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let whole = try json(try await call(connection, ["note_id": .string(w.note.id), "with_ids": .bool(true)]))
            let paged = try await pages(connection, ["note_id": .string(w.note.id), "limit": 3])
            #expect(paged.map { blocks($0).count } == [3, 3, 1], "pages of 3, 3 and 1")
            #expect(paged.map { $0["next_cursor"] != nil } == [true, true, false], "a cursor while blocks remain")
            #expect(paged.map { $0["block_count"] as? Int } == [7, nil, nil], "block_count on the first page only")
            #expect(paged.flatMap(blocks).map(canonical) == blocks(whole).map(canonical),
                    "the pages' blocks are the note's, entry for entry, in order")
            for page in paged {
                #expect(page["note_id"] as? String == w.note.id && page["title"] as? String == "long",
                        "every page carries the note's header")
                #expect(canonical(page["books"] ?? "absent") == canonical(whole["books"] ?? "absent"))
            }
            await h.hangUp(connection)
        }
    }

    /// `cursor` alone reads 50; `limit` clamps to 1…200 like `list_notes`; an empty note
    /// is one empty page; a page that ends exactly at the note's end says no cursor.
    ///
    /// U7c re-pin (P-VX256-1 re-ruled): `limit: 1000` read [200, 5] — but under the answer
    /// budget no 200-block page fits (the smallest block entry, its two ids and its take's,
    /// is ≈ 207 characters, so ≈ 150 blocks reach 32,000), so the clamp is no longer seen as
    /// a 200-block page. It is pinned as what it is — the parse: `limit: 1000` reads exactly
    /// as `limit: 200` does, page for page.
    @Test func aCursorAloneReadsFiftyAndTheLimitClamps() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 205, text: numbered)
            let empty = try h.operations.createPost(title: "empty")
            _ = try h.operations.addPostToReading(empty.id, to: w.book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let first = try json(try await call(connection, ["note_id": .string(w.note.id), "limit": 3]))
            let cursor = try #require(first["next_cursor"] as? String)
            let fifty = try json(try await call(connection, ["note_id": .string(w.note.id), "cursor": .string(cursor)]))
            #expect(blocks(fifty).count == 50, "a cursor alone reads 50")
            #expect(fifty["block_count"] == nil, "a cursor's page is never the first")
            #expect(blocks(fifty).first?["block_id"] as? String == w.blockIDs[3])

            let big = try await pages(connection, ["note_id": .string(w.note.id), "limit": 1000])
            // U7c re-pin: [200, 5] → the limit-200 read's own pages (see the doc comment).
            let twoHundred = try await pages(connection, ["note_id": .string(w.note.id), "limit": 200])
            #expect(big.map { blocks($0).map { $0["block_id"] as? String ?? "" } }
                        == twoHundred.map { blocks($0).map { $0["block_id"] as? String ?? "" } },
                    "the limit clamps to 200: 1000 reads as 200 does")
            #expect(big.flatMap(blocks).count == 205 && big.allSatisfy { blocks($0).count < 200 },
                    "every block read; the answer budget ends each page before 200")
            let small = try json(try await call(connection, ["note_id": .string(w.note.id), "limit": 0]))
            #expect(blocks(small).count == 1, "the limit clamps up to 1")

            let none = try json(try await call(connection, ["note_id": .string(empty.id), "limit": 5]))
            #expect(blocks(none).isEmpty && none["next_cursor"] == nil && none["block_count"] as? Int == 0)

            let six = try h.operations.createPost(title: "six")
            for index in 0..<6 { _ = try h.operations.newBlock(in: six.id, text: numbered(index), registeringUndo: false) }
            _ = try h.operations.addPostToReading(six.id, to: w.book.id)
            let exact = try await pages(connection, ["note_id": .string(six.id), "limit": 3])
            #expect(exact.map { blocks($0).count } == [3, 3] && exact.map { $0["next_cursor"] != nil } == [true, false],
                    "a page ending exactly at the note's end says no cursor")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-2: the page budget (re-pinned at U7c: the answer, not the take text)

    /// A page also ends once the answer would pass 32,000 characters — the first block
    /// always whole: blocks of 20,000 read one per page; a 40,000-character block is a page
    /// alone, and the small blocks after it share the next; four of 10,600 read as two and
    /// two. Under `ids_only` the answer budget bounds the page too; three digests fit it.
    ///
    /// U7c re-pin (P-VX256-1 re-ruled): `tens` was four blocks of 10,000 read as three, then
    /// one — true under both budgets, so it no longer told them apart. At 10,600 a block,
    /// three blocks' TEXT (31,800) fits the old take-text budget, while their ANSWER (≈ 210
    /// characters more a block, plus the header) does not: [3, 1] before, [2, 2] now. The
    /// `ids_only` line's meaning changed too (it said "the limit governs"): the answer budget
    /// governs, and three small entries are well within it.
    @Test func aPageEndsAtItsTextBudgetNeverSplittingABlock() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let twenties = try longNote(h, title: "twenties", count: 3) { String(repeating: "\($0)", count: 20_000) }
            let opener = try longNote(h, title: "opener", count: 3) { $0 == 0 ? String(repeating: "x", count: 40_000) : "short \($0)" }
            // U7c re-pin: 10,000 → 10,600 (see the doc comment).
            let tens = try longNote(h, title: "tens", count: 4) { String(repeating: "\($0)", count: 10_600) }
            let connection = try await h.connect(as: "claude-code")
            for book in [twenties.book, opener.book, tens.book] {
                _ = try h.approve("claude-code", spec(.book, book.id))
            }

            let a = try await pages(connection, ["note_id": .string(twenties.note.id), "limit": 10])
            #expect(a.map { blocks($0).count } == [1, 1, 1], "20,000 + 20,000 passes the budget")
            let b = try await pages(connection, ["note_id": .string(opener.note.id), "limit": 10])
            #expect(b.map { blocks($0).count } == [1, 2], "the 40,000-character block is a page alone, never split")
            let shownText = b.first.flatMap { blocks($0).first }.flatMap { block in
                (block["takes"] as? [[String: Any]])?.first?["text"] as? String
            }
            #expect(shownText?.count == 40_000, "the block rides whole")
            let c = try await pages(connection, ["note_id": .string(tens.note.id), "limit": 10])
            // U7c re-pin: [3, 1] → [2, 2] — 31,800 characters of text fit the old budget; the
            // three blocks' answer does not.
            #expect(c.map { blocks($0).count } == [2, 2], "two blocks' answer fits; three's would not")
            let ids = try await pages(connection, ["note_id": .string(twenties.note.id), "limit": 10, "ids_only": true])
            // U7c: the expectation stands; its meaning is the answer budget's (it said the limit governs).
            #expect(ids.map { blocks($0).count } == [3], "ids_only's three digest entries fit the answer budget")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-3: ids_only

    /// `ids_only` answers every take without its text and with its `sha256` — the digest
    /// of the text the with-ids read gives for that take — and everything else exactly as
    /// with-ids (labels, chosen, shown_take_id, comments WITH their text), paged or not.
    @Test func idsOnlyCarriesEachTakesDigestInsteadOfItsText() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 5) { index in
                ["“Curly” — dash", "beliscou", "e\u{0301} decomposed", "two\nlines", "trailing "][index]
            }
            let other = try h.operations.branchVariant(w.blockIDs[1], from: w.takeIDs[1])
            try h.operations.autosave(other.id, text: "beliscáu", charDelta: 1)
            try h.operations.setTakeLabel(other.id, label: "english")
            _ = try h.operations.newBlankVariant(w.blockIDs[4])
            _ = try h.operations.addBlockComment(to: w.blockIDs[2], text: "a comment keeps its words")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let whole = try json(try await call(connection, ["note_id": .string(w.note.id), "with_ids": .bool(true)]))
            var texts: [String: String] = [:]
            for block in blocks(whole) {
                for take in block["takes"] as? [[String: Any]] ?? [] {
                    texts[take["take_id"] as? String ?? ""] = take["text"] as? String
                }
            }
            #expect(texts.count == 7, "five takes, the label's and the blank's")
            /// The with-ids blocks with each take's text taken out — what ids_only keeps.
            func stripped(_ list: [[String: Any]], key: String) -> [String] {
                list.map { block in
                    var block = block
                    block["takes"] = (block["takes"] as? [[String: Any]] ?? []).map { take in
                        var take = take
                        take[key] = nil
                        return take
                    }
                    return canonical(block)
                }
            }
            for arguments: [String: Value] in [
                ["note_id": .string(w.note.id), "ids_only": true],
                ["note_id": .string(w.note.id), "ids_only": true, "limit": 2],
            ] {
                let read = arguments["limit"] == nil
                    ? [try json(try await call(connection, arguments))]
                    : try await pages(connection, arguments)
                let all = read.flatMap(blocks)
                try #require(all.count == 5, "every block read")
                for take in all.flatMap({ $0["takes"] as? [[String: Any]] ?? [] }) {
                    let id = take["take_id"] as? String ?? ""
                    #expect(take["text"] == nil, "ids_only carries no take text")
                    #expect(take["sha256"] as? String == digest(texts[id] ?? "∅"), "\(id)'s digest is its text's")
                }
                #expect(stripped(all, key: "sha256") == stripped(blocks(whole), key: "text"),
                        "everything but the take text is the with-ids answer (\(arguments))")
                let comment = all[2]["comments"] as? [[String: Any]]
                #expect(comment?.first?["text"] as? String == "a comment keeps its words")
            }
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-4: stale cursors

    /// A cursor this read would not have minted — undecodable, a `list_notes` cursor, a
    /// `list_my_activity` cursor, or another note's — answers the one stale sentence.
    @Test func aCursorThisReadDidNotMintAnswersStale() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 4, text: numbered)
            let other = try h.operations.createPost(title: "the other")
            for index in 0..<3 { _ = try h.operations.newBlock(in: other.id, text: "other \(index)", registeringUndo: false) }
            _ = try h.operations.addPostToReading(other.id, to: w.book.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let listed = try json(try await call(connection, "list_notes", ["book_id": .string(w.book.id), "limit": 1]))
            let listCursor = try #require(listed["next_cursor"] as? String)
            let otherPage = try json(try await call(connection, ["note_id": .string(other.id), "limit": 1]))
            let otherCursor = try #require(otherPage["next_cursor"] as? String, "the other note's page 1 cursor")
            let acts = try json(try await call(connection, "list_my_activity", ["include_reads": true, "limit": 1]))
            let actsCursor = try #require(acts["next_cursor"] as? String, "two reads logged, a page of one")

            for (cursor, why) in [
                ("not a cursor", "undecodable"), (Data("n\nonly-two".utf8).base64EncodedString(), "too few parts"),
                (listCursor, "a list_notes cursor"), (actsCursor, "a list_my_activity cursor"),
                (otherCursor, "another note's cursor"),
            ] {
                let answer = try await call(connection, ["note_id": .string(w.note.id), "cursor": .string(cursor)])
                #expect(answer.isError == true && text(answer) == MCPReadTools.staleCursorMessage,
                        "\(why): \(text(answer).prefix(80))")
            }
            await h.hangUp(connection)
        }
    }

    // MARK: - GUARD (P-256-5): the fence's one shape

    /// An unreachable note answers the ONE refusal byte-for-byte with paging, `ids_only`,
    /// a readable note's cursor, or none of them — exactly as an id naming nothing does.
    /// (A GUARD: the old tree ignores the new arguments, so it is green there too.)
    @Test func theFenceAnswersOneShapeWithOrWithoutTheNewAsks() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 4, text: numbered)
            let hidden = try h.operations.createPost(title: "not shared")
            _ = try h.operations.newBlock(in: hidden.id, text: "never for the client", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            // Tolerant on purpose (a GUARD): the old tree answers this as the Level 0 text.
            let first = text(try await call(connection, ["note_id": .string(w.note.id), "limit": 1]))
            let readable = (try? JSONSerialization.jsonObject(with: Data(first.utf8))) as? [String: Any] ?? [:]
            let cursor = readable["next_cursor"] as? String ?? Data("n\n\(w.note.id)\nV\nid".utf8).base64EncodedString()
            let nothing = try await call(connection, ["note_id": "no-such-note"])
            #expect(nothing.isError == true)
            for target in [hidden.id, "no-such-note"] {
                for extra: [String: Value] in [
                    [:], ["limit": 2], ["ids_only": true], ["cursor": .string(cursor)],
                    ["limit": 2, "ids_only": true, "cursor": .string(cursor), "with_ids": true],
                ] {
                    var args = extra
                    args["note_id"] = .string(target)
                    let answer = try await call(connection, args)
                    #expect(answer.isError == true && text(answer) == text(nothing),
                            "\(target == hidden.id ? "hidden" : "missing") \(extra): \(text(answer))")
                    #expect(!text(answer).contains("never"))
                }
            }
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-6: not a snapshot

    /// Between pages the note may change, and a page shows it as it is THEN: a block added
    /// before the cursor is not seen, one added after it is; deleting the cursor's own
    /// block never breaks the resume.
    @Test func pagesShowTheNoteAsItIsWhenEachIsRead() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 6, text: numbered)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let first = try json(try await call(connection, ["note_id": .string(w.note.id), "limit": 3]))
            #expect(blocks(first).map { $0["block_id"] as? String } == Array(w.blockIDs.prefix(3)))
            let cursor = try #require(first["next_cursor"] as? String)
            let before = try h.operations.newBlock(
                in: w.note.id, text: "added before the cursor", at: .after(w.blockIDs[0]), registeringUndo: false)
            let after = try h.operations.newBlock(
                in: w.note.id, text: "added after the cursor", at: .after(w.blockIDs[3]), registeringUndo: false)

            let second = try json(try await call(connection, ["note_id": .string(w.note.id), "cursor": .string(cursor), "limit": 3]))
            let seen = blocks(second).map { $0["block_id"] as? String ?? "" }
            #expect(seen == [w.blockIDs[3], after.block.id, w.blockIDs[4]], "the after-one is seen, in place")
            #expect(!seen.contains(before.block.id), "the before-one is behind the cursor")

            try h.operations.deleteBlock(w.blockIDs[2])
            let resumed = try json(try await call(connection, ["note_id": .string(w.note.id), "cursor": .string(cursor), "limit": 3]))
            #expect(blocks(resumed).map { $0["block_id"] as? String ?? "" } == seen,
                    "the cursor's own block deleted, the read resumes where it stood")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-7: a once grant reads one page

    /// A note shared ONCE is spent by its first read — page 1 — so page 2 refuses as any
    /// second read does (AF-7's rule, unchanged; P-VX256-3 for her eye).
    @Test func aOnceGrantIsSpentByTheFirstPage() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "once")
            for index in 0..<6 { _ = try h.operations.newBlock(in: note.id, text: numbered(index), registeringUndo: false) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.note, note.id, .read, .once))

            let first = try await call(connection, ["note_id": .string(note.id), "limit": 3])
            #expect(first.isError != true, "\(text(first))")
            let cursor = try #require(try json(first)["next_cursor"] as? String)
            let second = try await call(connection, ["note_id": .string(note.id), "cursor": .string(cursor)])
            let nothing = try await call(connection, ["note_id": "no-such-note"])
            #expect(second.isError == true && text(second) == text(nothing), "the once grant is spent: \(text(second))")
            await h.hangUp(connection)
        }
    }

    /// A STALE cursor never spends a once grant (D-256-6: the cursor's container is checked
    /// after the decision and BEFORE the spend): another note's cursor answers stale, and the
    /// once grant then still reads its note.
    @Test func aStaleCursorNeverSpendsAOnceGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 3, text: numbered)
            let once = try h.operations.createPost(title: "once")
            _ = try h.operations.newBlock(in: once.id, text: "read me once", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.note, once.id, .read, .once))

            let other = try json(try await call(connection, ["note_id": .string(w.note.id), "limit": 1]))
            let foreign = try #require(other["next_cursor"] as? String)
            let stale = try await call(connection, ["note_id": .string(once.id), "cursor": .string(foreign)])
            #expect(stale.isError == true && text(stale) == MCPReadTools.staleCursorMessage, "\(text(stale))")
            let read = try await call(connection, ["note_id": .string(once.id)])
            #expect(read.isError != true && text(read).contains("read me once"), "the once grant still reads: \(text(read))")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-8: a lens through every page

    /// `lens_id` reads every page through the lens — per block `via` and `shown_take_id`
    /// exactly as the unpaged lens read — and `with_lenses` lists the lenses on every page
    /// with picks for THAT page's blocks, `dangling_picks` on the first page only.
    @Test func aLensReadsThroughEveryPage() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 6, text: numbered)
            var others: [String] = []
            for index in 0..<6 {
                let other = try h.operations.branchVariant(w.blockIDs[index], from: w.takeIDs[index])
                try h.operations.autosave(other.id, text: "other \(index)", charDelta: 7)
                others.append(other.id)
            }
            let lens = try h.operations.createLens(post: w.note.id, name: "the others")
            _ = try h.operations.setLensChoice(lens: lens.id, block: w.blockIDs[1], variant: others[1])
            _ = try h.operations.setLensChoice(lens: lens.id, block: w.blockIDs[4], variant: others[4])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let whole = try json(try await call(connection, [
                "note_id": .string(w.note.id), "with_ids": .bool(true), "lens_id": .string(lens.id),
            ]))
            let paged = try await pages(connection, ["note_id": .string(w.note.id), "lens_id": .string(lens.id), "limit": 3])
            try #require(paged.count == 2, "two pages")
            #expect(paged.flatMap(blocks).map(canonical) == blocks(whole).map(canonical),
                    "every block through the lens, as the unpaged lens read")
            #expect(paged.flatMap(blocks).map { $0["via"] as? String } == ["chosen", "lens", "chosen", "chosen", "lens", "chosen"])
            #expect(paged.allSatisfy { $0["lens_id"] as? String == lens.id }, "every page says the lens")

            let listed = try await pages(connection, ["note_id": .string(w.note.id), "with_lenses": true, "limit": 3])
            let picks = listed.map { page -> [String] in
                let entry = (page["lenses"] as? [[String: Any]])?.first
                return (entry?["picks"] as? [[String: Any]] ?? []).map { "\($0["block_id"] ?? "")=\($0["take_id"] ?? "")" }
            }
            #expect(picks == [["\(w.blockIDs[1])=\(others[1])"], ["\(w.blockIDs[4])=\(others[4])"]],
                    "each page's picks are its own blocks'")
            let lensEntries = listed.map { ($0["lenses"] as? [[String: Any]])?.first ?? [:] }
            #expect(lensEntries.map { $0["lens_id"] as? String } == [lens.id, lens.id])
            #expect(lensEntries.map { $0["dangling_picks"] as? Int } == [0, nil], "dangling_picks on the first page only")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-9: the commit asks under paging

    /// `with_commits` paged carries the PAGE's takes' commits, their text riding within what
    /// the page's budget has left (past it `text_omitted`, fetched by `commit_ids`); a
    /// `commit_ids` entry that is not a commit of a take on this page refuses.
    @Test func theCommitAsksRideThePage() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 4, text: numbered)
            // Block 1's take: an OLD 40,000-character moment, then two small newer ones.
            try h.operations.autosave(w.takeIDs[0], text: String(repeating: "m", count: 40_000), charDelta: 40_000)
            let big = try h.operations.commit(w.takeIDs[0], message: "the long one")
            try h.operations.autosave(w.takeIDs[0], text: "Block 001, smaller.", charDelta: 40_000)
            let small = try h.operations.commit(w.takeIDs[0], message: "small")
            try h.operations.autosave(w.takeIDs[0], text: numbered(0), charDelta: 3)
            let newest = try h.operations.commit(w.takeIDs[0], message: "newest")
            let later = try h.operations.commit(w.takeIDs[3], message: "on page two")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let paged = try await pages(connection, ["note_id": .string(w.note.id), "with_commits": true, "limit": 2])
            try #require(paged.count == 2, "two pages")
            func commits(_ page: [String: Any]) -> [[String: Any]] {
                blocks(page).flatMap { $0["takes"] as? [[String: Any]] ?? [] }.flatMap { $0["commits"] as? [[String: Any]] ?? [] }
            }
            #expect(commits(paged[0]).map { $0["commit_id"] as? String } == [newest.id, small.id, big.id],
                    "page 1 carries its takes' commits, newest first")
            #expect(commits(paged[1]).map { $0["commit_id"] as? String } == [later.id], "page 2 its own")
            let longOne = commits(paged[0]).first { $0["commit_id"] as? String == big.id }
            #expect(longOne?["text_omitted"] as? Bool == true && longOne?["text"] == nil,
                    "past the page's budget the text is omitted")
            #expect(commits(paged[0]).first?["text"] as? String == numbered(0), "within it, the text rides")

            let fetched = try json(try await call(connection, [
                "note_id": .string(w.note.id), "limit": 2, "commit_ids": .array([.string(big.id)]),
            ]))
            let asked = commits(fetched).first { $0["commit_id"] as? String == big.id }
            #expect((asked?["text"] as? String)?.count == 40_000, "a commit asked by id always carries its text")

            let off = try await call(connection, [
                "note_id": .string(w.note.id), "limit": 2, "commit_ids": .array([.string(later.id)]),
            ])
            #expect(off.isError == true && text(off) == "commit_id \(later.id) isn't a commit of a take on this page.",
                    "\(text(off))")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-256-10: a saved version pages the same way

    /// `version_id` with `limit` tiles the saved version; its cursor names the version,
    /// so it never resumes the live note (and the live note's never the version).
    @Test func aSavedVersionPagesLikeItsNote() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try longNote(h, count: 5, text: numbered)
            let version = try h.operations.saveNoteVersion(w.note.id).post.id
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let whole = try json(try await call(connection, [
                "note_id": .string(w.note.id), "version_id": .string(version), "with_ids": .bool(true),
            ]))
            let paged = try await pages(connection, [
                "note_id": .string(w.note.id), "version_id": .string(version), "limit": 2,
            ])
            #expect(paged.map { blocks($0).count } == [2, 2, 1])
            #expect(paged.flatMap(blocks).map(canonical) == blocks(whole).map(canonical), "the version, tiled")
            #expect(paged.allSatisfy { $0["version_id"] as? String == version && $0["version_of"] as? String == w.note.id })
            #expect(paged.first?["block_count"] as? Int == 5)

            let versionCursor = try #require(paged.first?["next_cursor"] as? String)
            let crossed = try await call(connection, ["note_id": .string(w.note.id), "cursor": .string(versionCursor)])
            #expect(crossed.isError == true && text(crossed) == MCPReadTools.staleCursorMessage, "\(text(crossed))")
            let live = try json(try await call(connection, ["note_id": .string(w.note.id), "limit": 2]))
            let liveCursor = try #require(live["next_cursor"] as? String)
            let back = try await call(connection, [
                "note_id": .string(w.note.id), "version_id": .string(version), "cursor": .string(liveCursor),
            ])
            #expect(back.isError == true && text(back) == MCPReadTools.staleCursorMessage, "\(text(back))")
            await h.hangUp(connection)
        }
    }

    // MARK: - F-256-7: the note-wide carriage rides the first page

    /// `with_tray` and `with_versions` (note-wide lists) ride the FIRST page only — and the
    /// tray counts toward that page's budget (a 28,000-character deleted block leaves room
    /// for one more block only, the page within 32,000).
    ///
    /// U7c re-pin (P-VX256-1 re-ruled — the first page's carriage counts toward its ANSWER):
    /// at 31,000 the tray plus its one block now answered PAST the budget, the page holding
    /// that block only by the one-block floor — no longer "room for one more block". At
    /// 28,000 the one block fits within the answer budget and a second does not, while the
    /// old take-text budget seated two (28,000 + 2,000 + 2,000).
    @Test func theNoteWideCarriageRidesTheFirstPage() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            // U7c re-pin: the tray block 31,000 → 28,000 (see the doc comment).
            let w = try longNote(h, count: 5) { $0 == 0 ? String(repeating: "g", count: 28_000) : String(repeating: "\($0)", count: 2_000) }
            try h.operations.deleteBlock(w.blockIDs[0])
            _ = try h.operations.saveNoteVersion(w.note.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, w.book.id))

            let paged = try await pages(connection, [
                "note_id": .string(w.note.id), "with_tray": true, "with_versions": true, "limit": 10,
            ])
            try #require(paged.count >= 2, "more than one page")
            #expect(blocks(paged[0]).count == 1, "28,000 of tray + 2,000 leaves no room for a second block")
            // U7c: the page, carriage and all, answers within the budget.
            let firstPage = try await call(connection, [
                "note_id": .string(w.note.id), "with_tray": true, "with_versions": true, "limit": 10,
            ])
            #expect(text(firstPage).utf16.count <= 32_000, "the first page answers \(text(firstPage).utf16.count)")
            #expect(((paged[0]["tray"] as? [String: Any])?["blocks"] as? [[String: Any]])?.count == 1)
            #expect((paged[0]["versions"] as? [[String: Any]])?.count == 1)
            #expect(paged.dropFirst().allSatisfy { $0["tray"] == nil && $0["versions"] == nil },
                    "the tray and the versions ride the first page only")
            #expect(paged.flatMap(blocks).count == 4)
            await h.hangUp(connection)
        }
    }

    // MARK: - The catalog

    /// `read_note` declares the three new inputs, each saying what it asks for.
    @Test func readNoteDeclaresItsPagingInputs() throws {
        let properties = try #require(MCPToolCatalog.readNote.inputSchema.objectValue?["properties"]?.objectValue)
        #expect(properties["limit"]?.objectValue?["type"] == "integer")
        #expect(properties["limit"]?.objectValue?["minimum"] == 1 && properties["limit"]?.objectValue?["maximum"] == 200)
        #expect(properties["cursor"]?.objectValue?["type"] == "string")
        #expect(properties["ids_only"]?.objectValue?["type"] == "boolean")
        let words = MCPToolCatalog.readNote.description
        for needle in ["limit", "next_cursor", "32,000", "block_count", "ids_only", "sha256", MCPToolCatalog.digestSentence] {
            #expect(words.contains(needle), "the description says \(needle.prefix(40))")
        }
    }
}

// MARK: - GUARD G-256-1: every existing form, byte for byte

/// With none of the new arguments, every `read_note` form answers EXACTLY as before —
/// each expected answer written out here byte for byte (the ids interpolated, the
/// stamps read from the rows), so the guard is green on the tree before VX-256 and must
/// stay green after it. `export_note` ignores the new arguments altogether.
@Suite("VX-256 — every read form without the new asks is byte-unchanged (a guard)", .serialized)
struct MCPReadFormsUnchangedServerTests {
    @Test func everyFormWithoutTheNewAsksIsByteUnchanged() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let section = try h.operations.createSection(in: book.id, name: "one")
            let note = try h.operations.createPost(title: "golden", entryDate: "2026-07-02")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            try h.operations.assignPostToSection(note.id, in: book.id, section: section.id)
            let first = try h.operations.newBlock(in: note.id, text: "First words.", registeringUndo: false)
            let second = try h.operations.newBlock(in: note.id, text: "Second words.", registeringUndo: false)
            let gone = try h.operations.newBlock(in: note.id, text: "Gone words.", registeringUndo: false)
            let other = try h.operations.branchVariant(second.block.id, from: second.variant.id)
            try h.operations.autosave(other.id, text: "Other words.", charDelta: 12)
            try h.operations.setTakeLabel(other.id, label: "alt")
            let comment = try h.operations.addBlockComment(to: second.block.id, text: "a note on two")
            let saved = try h.operations.commit(first.variant.id, message: "m1")
            let lens = try h.operations.createLens(post: note.id, name: "view")
            _ = try h.operations.setLensChoice(lens: lens.id, block: second.block.id, variant: other.id)
            try h.operations.deleteBlock(gone.block.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, book.id))
            let (committedAt, goneAt) = try await h.database.read { db in
                (try String.fetchOne(db, sql: "SELECT created_at FROM commit_point WHERE id = ?", arguments: [saved.id]) ?? "",
                 try String.fetchOne(db, sql: "SELECT deleted_at FROM block WHERE id = ?", arguments: [gone.block.id]) ?? "")
            }

            let (b1, t1, b2, t2, t3) = (first.block.id, first.variant.id, second.block.id, second.variant.id, other.id)
            let books = #"[{"book_id":"\#(book.id)","name":"drafts","section_id":"\#(section.id)","section_name":"one"}]"#
            let block1 = #"{"block_id":"\#(b1)","comments":[],"shown_take_id":"\#(t1)","takes":[{"chosen":true,"take_id":"\#(t1)","text":"First words."}]}"#
            let comments2 = #"[{"comment_id":"\#(comment.id)","text":"a note on two"}]"#
            let takes2 = #"[{"chosen":true,"take_id":"\#(t2)","text":"Second words."},{"chosen":false,"label":"alt","take_id":"\#(t3)","text":"Other words."}]"#
            let block2 = #"{"block_id":"\#(b2)","comments":\#(comments2),"shown_take_id":"\#(t2)","takes":\#(takes2)}"#
            let tail = #""books":\#(books),"entry_date":"2026-07-02","note_id":"\#(note.id)","title":"golden"}"#

            let withIDs = try await call(connection, ["note_id": .string(note.id), "with_ids": .bool(true)])
            #expect(text(withIDs) == #"{"blocks":[\#(block1),\#(block2)],\#(tail)"#, "with_ids:\n\(text(withIDs))")

            let commit1 = #"[{"commit_id":"\#(saved.id)","created_at":"\#(committedAt)","kind":"manual","length":12,"message":"m1","text":"First words."}]"#
            let block1c = #"{"block_id":"\#(b1)","comments":[],"shown_take_id":"\#(t1)","takes":[{"chosen":true,"commits":\#(commit1),"take_id":"\#(t1)","text":"First words."}]}"#
            let takes2c = #"[{"chosen":true,"commits":[],"take_id":"\#(t2)","text":"Second words."},{"chosen":false,"commits":[],"label":"alt","take_id":"\#(t3)","text":"Other words."}]"#
            let block2c = #"{"block_id":"\#(b2)","comments":\#(comments2),"shown_take_id":"\#(t2)","takes":\#(takes2c)}"#
            let withCommits = try await call(connection, ["note_id": .string(note.id), "with_commits": true])
            #expect(text(withCommits) == #"{"blocks":[\#(block1c),\#(block2c)],\#(tail)"#, "with_commits:\n\(text(withCommits))")

            let lenses = #""lenses":[{"dangling_picks":0,"lens_id":"\#(lens.id)","name":"view","picks":[{"block_id":"\#(b2)","take_id":"\#(t3)"}]}]"#
            let tray = #""tray":{"blocks":[{"block_id":"\#(gone.block.id)","deleted_at":"\#(goneAt)","text":"Gone words."}],"takes":[]}"#
            let carried = try await call(connection, ["note_id": .string(note.id), "with_lenses": true, "with_tray": true])
            #expect(text(carried) == #"{"blocks":[\#(block1),\#(block2)],"books":\#(books),"entry_date":"2026-07-02",\#(lenses),"note_id":"\#(note.id)","title":"golden",\#(tray)}"#,
                    "with_lenses + with_tray:\n\(text(carried))")

            let lensed = try await call(connection, ["note_id": .string(note.id), "with_ids": .bool(true), "lens_id": .string(lens.id)])
            let block1l = #"{"block_id":"\#(b1)","comments":[],"shown_take_id":"\#(t1)","takes":[{"chosen":true,"take_id":"\#(t1)","text":"First words."}],"via":"chosen"}"#
            let block2l = #"{"block_id":"\#(b2)","comments":\#(comments2),"shown_take_id":"\#(t3)","takes":\#(takes2),"via":"lens"}"#
            #expect(text(lensed) == #"{"blocks":[\#(block1l),\#(block2l)],"books":\#(books),"entry_date":"2026-07-02","lens_id":"\#(lens.id)","note_id":"\#(note.id)","title":"golden"}"#,
                    "through a lens:\n\(text(lensed))")

            let plainText = try await call(connection, ["note_id": .string(note.id)])
            let document = try await h.database.read { try Queries.variorumDocumentText($0, postID: note.id) }
            #expect(text(plainText) == document, "the Level 0 text form")
            let exported = try await call(connection, "export_note", ["note_id": .string(note.id), "limit": 1, "ids_only": true])
            let rendered = try await h.database.read { try Queries.renderedText($0, containerID: note.id) }
            #expect(exported.isError != true && text(exported) == rendered, "export_note ignores the new arguments")

            let stranger = try await call(connection, ["note_id": .string(note.id), "commit_ids": .array(["nope"])])
            #expect(stranger.isError == true && text(stranger) == "commit_id nope isn't a commit of this note.",
                    "the unpaged commit_ids words: \(text(stranger))")
            await h.hangUp(connection)
        }
    }
}
