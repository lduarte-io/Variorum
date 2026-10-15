import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-256 re-ruled (VX-336 U7c — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// THE ORCHESTRATOR ON U7's WINDOW and the U7c UNIT RECORD): THE PAGE BUDGET BOUNDS THE WHOLE
// ANSWER. U7's live round measured the cap from bytes: on sherlock's "The Red-Headed League"
// (215 blocks, 49,007 characters of text) a `limit: 200` page ended by its 32,000-character
// TAKE-TEXT budget at 161 blocks, but its answer was 65,807 characters — the ids and records
// add ≈ 210 a block — and Claude Code saved it to a file instead of showing it; a 200-block
// `ids_only` page (no take text at all, so no budget) answered 54,731. Inline held at 43,062
// and spilled at 50,984. The ruling: a page ends at `limit` blocks, or as soon as adding the
// next block would carry the SERIALIZED ANSWER past 32,000 characters — counted on the very
// JSON text the tool returns; a block is never split, and one larger than what its page has
// left comes alone; the first page's note-wide carriage counts toward its budget; `ids_only`
// pages are bounded the same.
//
// "Characters" are measured here as UTF-16 code units (`utf16.count`) — what a JavaScript
// client such as Claude Code counts, and never fewer than Unicode scalars or Swift
// Characters, so "≤ 32,000 characters" holds under every reading.
//
// Wire only (the SDK's own client over a real socket). Every pin compiles on the tree before
// U7c (only builder B's arguments and types are named; the budget is this file's literal).

private let answerBudget = 32_000

private func spec(_ kind: MCPGrantRule.ScopeKind, _ id: String) -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: kind, scopeID: id, duration: .always)
}

private func readNote(
    _ connection: HarnessConnection, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: "read_note", arguments: arguments)
}

/// The answer's size in the unit the description states (see the header).
private func answerSize(_ text: String) -> Int { text.utf16.count }

/// A JSON value as one canonical string — the server's own encoding options.
private func canonical(_ value: Any) -> String {
    guard let data = try? JSONSerialization.data(
        withJSONObject: value, options: [.sortedKeys, .withoutEscapingSlashes, .fragmentsAllowed])
    else { return "<not JSON: \(value)>" }
    return String(decoding: data, as: UTF8.self)
}

private func blocksOf(_ page: [String: Any]) -> [[String: Any]] {
    page["blocks"] as? [[String: Any]] ?? []
}

/// One read page: the answer exactly as the wire carried it, and its parse.
private struct Page {
    let text: String
    let json: [String: Any]
    var blocks: [[String: Any]] { blocksOf(json) }
    var size: Int { answerSize(text) }
}

/// Every page of a paged read, following `next_cursor` (bounded — a server that never ends
/// its pages fails here, never hangs).
private func pages(
    _ connection: HarnessConnection, _ arguments: [String: Value], cap: Int = 80
) async throws -> [Page] {
    var read: [Page] = []
    var cursor: String?
    repeat {
        var args = arguments
        if let cursor { args["cursor"] = .string(cursor) }
        let answer = try await readNote(connection, args)
        #expect(answer.isError != true, "page \(read.count + 1): \(text(answer).prefix(200))")
        let page = Page(text: text(answer), json: try json(answer))
        read.append(page)
        cursor = page.json["next_cursor"] as? String
    } while cursor != nil && read.count < cap
    return read
}

/// THE RULE, checked page by page: every page's answer is within the budget unless it holds
/// ONE block (a block larger than what its page has left comes alone); and every page that
/// is not the last is FULL — adding the next page's first block (with its lens picks, and
/// its commit texts, when it carries any, back to `text_omitted`, as the page decision counts
/// them) would carry the answer past the budget, unless the page already holds `limit`
/// blocks.
private func expectTheBudgetRule(
    _ read: [Page], limit: Int, cursorOf: (String) throws -> String,
    sourceLocation: SourceLocation = #_sourceLocation
) rethrows {
    for (index, page) in read.enumerated() {
        if page.blocks.count > 1 {
            #expect(page.size <= answerBudget,
                    "page \(index + 1) (\(page.blocks.count) blocks) answers \(page.size) characters",
                    sourceLocation: sourceLocation)
        }
        guard index + 1 < read.count, page.blocks.count < limit,
              let next = read[index + 1].blocks.first else { continue }
        // The page as the decision weighed it, then with the next block appended and the
        // cursor moved to it (or gone, when that block ends the note).
        let weighed = withoutCommitText(page.json)
        var grown = weighed
        grown["blocks"] = blocksOf(weighed) + [withoutCommitText(next)]
        let nextID = next["block_id"] as? String ?? ""
        if var lenses = weighed["lenses"] as? [[String: Any]],
           let nextLenses = read[index + 1].json["lenses"] as? [[String: Any]] {
            for lens in lenses.indices where lens < nextLenses.count {
                let extra = (nextLenses[lens]["picks"] as? [[String: Any]] ?? [])
                    .filter { $0["block_id"] as? String == nextID }
                lenses[lens]["picks"] = (lenses[lens]["picks"] as? [[String: Any]] ?? []) + extra
            }
            grown["lenses"] = lenses
        }
        let endsTheNote = index + 2 == read.count && read[index + 1].blocks.count == 1
        grown["next_cursor"] = endsTheNote ? nil : try cursorOf(nextID)
        let delta = answerSize(canonical(grown)) - answerSize(canonical(weighed))
        let weighedSize = page.size - (answerSize(canonical(page.json)) - answerSize(canonical(weighed)))
        #expect(weighedSize + delta > answerBudget,
                "page \(index + 1) is full: with the next block it would answer \(weighedSize + delta)",
                sourceLocation: sourceLocation)
    }
}

/// A page (or a block entry) with every commit's text taken back to `text_omitted: true` —
/// the shape the page decision sizes a block by (commit text rides in what is left after).
private func withoutCommitText(_ value: [String: Any]) -> [String: Any] {
    var value = value
    if let list = value["blocks"] as? [[String: Any]] { value["blocks"] = list.map(withoutCommitText) }
    if let takes = value["takes"] as? [[String: Any]] {
        value["takes"] = takes.map { take -> [String: Any] in
            var take = take
            if let commits = take["commits"] as? [[String: Any]] {
                take["commits"] = commits.map { commit -> [String: Any] in
                    var commit = commit
                    commit["text"] = nil
                    commit["text_omitted"] = true
                    return commit
                }
            }
            return take
        }
    }
    return value
}

/// The resume cursor a page ending at `blockID` would carry (builder B's shape).
private func cursor(_ h: ServerHarness, container: String, block blockID: String) throws -> String {
    try h.database.read { db in
        let row = try #require(try Row.fetchOne(
            db, sql: "SELECT id, position FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID]))
        return NotePageCursor(containerID: container, position: row["position"], placementID: row["id"]).encoded
    }
}

/// THE FIXTURE: sherlock's "The Red-Headed League" exactly as the sample library seeds it
/// (the bundled text, split on its `%%% ` lines and trimmed, imported in paragraph mode) —
/// the note U7's live round measured the cap on.
private func redHeadedLeague() throws -> String {
    let url = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumMCPTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root
        .appendingPathComponent("App/Variorum/Shared/SampleLibrary/SherlockAdventures.txt")
    let raw = try String(contentsOf: url, encoding: .utf8)
    var body: [Substring] = []
    var inside = false
    for line in raw.split(separator: "\n", omittingEmptySubsequences: false) {
        if line.hasPrefix("%%% ") {
            if inside { break }
            inside = line.dropFirst(4).trimmingCharacters(in: .whitespaces) == "The Red-Headed League"
            continue
        }
        if inside { body.append(line) }
    }
    return body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
}

private struct Story {
    let book: Reading
    let noteID: String
}

private func importStory(_ h: ServerHarness) throws -> Story {
    let book = try h.operations.createReading(name: "the adventures of sherlock holmes", kind: .book)
    let note = try h.operations.importPost(
        title: "The Red-Headed League", text: try redHeadedLeague(), segmentation: .paragraph).container
    _ = try h.operations.addPostToReading(note.id, to: book.id)
    return Story(book: book, noteID: note.id)
}

/// The block ids of a note, in its order, from the store.
private func blockOrder(_ h: ServerHarness, _ noteID: String) throws -> [String] {
    try h.database.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT cb.block_id FROM container_block cb JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL ORDER BY cb.position, cb.id
                """,
            arguments: [noteID])
    }
}

private func sizes(_ read: [Page]) -> String {
    read.map { "\($0.blocks.count)b/\($0.size)" }.joined(separator: " · ")
}

@Suite("VX-256 U7c — the page budget bounds the whole answer", .serialized)
struct MCPPageAnswerBudgetServerTests {
    // MARK: - P-U7c-1: sherlock-sized prose

    /// "The Red-Headed League" read at `limit` 200, 100 and 50: every page answers within
    /// 32,000 characters and is full (the next block would pass it); the pages tile the note
    /// exactly — every block once, in order, entry for entry the unpaged with-ids blocks —
    /// and `block_count` says the note's blocks. On the tree before U7c the 200-block page
    /// ended by its TAKE text at ≈ 161 blocks and answered ≈ 65k characters: RED.
    @Test func aSherlockSizedNoteReadsInPagesWithinTheAnswerBudget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let story = try importStory(h)
            let order = try blockOrder(h, story.noteID)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, story.book.id))

            let wholeText = text(try await readNote(connection, ["note_id": .string(story.noteID), "with_ids": .bool(true)]))
            let whole = try #require(try JSONSerialization.jsonObject(with: Data(wholeText.utf8)) as? [String: Any])
            let takeText = blocksOf(whole).flatMap { $0["takes"] as? [[String: Any]] ?? [] }
                .reduce(0) { $0 + (($1["text"] as? String)?.count ?? 0) }
            try #require(order.count >= 200 && takeText >= 45_000,
                         "the fixture is sherlock-sized: \(order.count) blocks, \(takeText) characters of text")
            print("U7c P-1 fixture: \(order.count) blocks · \(takeText) characters of take text · the unpaged with-ids answer \(answerSize(wholeText))")

            for limit in [200, 100, 50] {
                let read = try await pages(connection, ["note_id": .string(story.noteID), "limit": .int(limit)])
                print("U7c P-1 limit \(limit): \(read.count) pages — \(sizes(read))")
                try expectTheBudgetRule(read, limit: limit) { try cursor(h, container: story.noteID, block: $0) }
                let tiled = read.flatMap(\.blocks)
                #expect(tiled.map { $0["block_id"] as? String ?? "" } == order,
                        "limit \(limit): every block once, in order")
                #expect(tiled.map(canonical) == blocksOf(whole).map(canonical),
                        "limit \(limit): the pages' blocks are the note's, entry for entry")
                #expect(read.first?.json["block_count"] as? Int == order.count)
                #expect(read.dropFirst().allSatisfy { $0.json["block_count"] == nil })
            }

            // A saved version pages the same way — its echoes (version_id, version_of, saved_at)
            // ride inside the answer the budget measures.
            let version = try h.operations.saveNoteVersion(story.noteID).post.id
            let versioned = try await pages(connection, [
                "note_id": .string(story.noteID), "version_id": .string(version), "limit": 200,
            ])
            print("U7c P-1 a version at limit 200: \(versioned.count) pages — \(sizes(versioned))")
            try expectTheBudgetRule(versioned, limit: 200) { try cursor(h, container: version, block: $0) }
            #expect(versioned.flatMap(\.blocks).count == order.count, "the version, tiled")
            #expect(versioned.allSatisfy { $0.json["version_id"] as? String == version })
            await h.hangUp(connection)
        }
    }

    // MARK: - P-U7c-2: ids_only

    /// `ids_only` pages carry no take text, yet the answer budget bounds them too: the
    /// sherlock note read `ids_only` at `limit: 200` pages within 32,000 characters, full,
    /// tiling the note exactly (entry for entry the unpaged `ids_only` read). Before U7c the
    /// limit alone governed: one 200-block page of ≈ 55k characters — RED.
    @Test func idsOnlyPagesStayWithinTheAnswerBudget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let story = try importStory(h)
            let order = try blockOrder(h, story.noteID)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, story.book.id))

            let whole = try json(try await readNote(connection, ["note_id": .string(story.noteID), "ids_only": true]))
            let read = try await pages(connection, ["note_id": .string(story.noteID), "ids_only": true, "limit": 200])
            print("U7c P-2 ids_only limit 200: \(read.count) pages — \(sizes(read))")
            try expectTheBudgetRule(read, limit: 200) { try cursor(h, container: story.noteID, block: $0) }
            let tiled = read.flatMap(\.blocks)
            #expect(tiled.map { $0["block_id"] as? String ?? "" } == order, "every block once, in order")
            #expect(tiled.map(canonical) == blocksOf(whole).map(canonical), "entry for entry the unpaged ids_only read")
            #expect(tiled.allSatisfy { block in
                (block["takes"] as? [[String: Any]] ?? []).allSatisfy { $0["text"] == nil && $0["sha256"] != nil }
            }, "digests, never text")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-U7c-3: a block larger than the budget comes alone

    /// The answer is counted on the wire's own encoding: a block of 17,000 double quotes is
    /// 17,000 characters of text but ≈ 34,000 of answer (each quote travels escaped), so it
    /// is larger than the budget — it comes ALONE, whole, never split, and the blocks around
    /// it share their own pages. Under `ids_only` a block whose COMMENT is 40,000 characters
    /// (comments keep their text) comes alone the same way. Before U7c the quotes counted
    /// once and every block shared one page; `ids_only` counted nothing — RED.
    @Test func aBlockLargerThanTheBudgetComesAloneNeverSplit() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let quotes = String(repeating: "\"", count: 17_000)
            let note = try h.operations.createPost(title: "quoted")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            for text in ["before it", quotes, "after it", "and after that"] {
                _ = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
            }
            let commented = try h.operations.createPost(title: "commented")
            _ = try h.operations.addPostToReading(commented.id, to: book.id)
            var commentedBlocks: [String] = []
            for index in 0..<4 {
                commentedBlocks.append(try h.operations.newBlock(
                    in: commented.id, text: "block \(index)", registeringUndo: false).block.id)
            }
            _ = try h.operations.addBlockComment(to: commentedBlocks[1], text: String(repeating: "c", count: 40_000))
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, book.id))

            let read = try await pages(connection, ["note_id": .string(note.id), "limit": 10])
            print("U7c P-3 the quoted block: \(sizes(read))")
            #expect(read.map(\.blocks.count) == [1, 1, 2], "the quotes alone, the others around them")
            let alone = try #require(read.dropFirst().first)
            #expect(alone.size > answerBudget, "the lone block is larger than the budget: \(alone.size)")
            let shown = (alone.blocks.first?["takes"] as? [[String: Any]])?.first?["text"] as? String
            #expect(shown == quotes, "it rides whole")
            try expectTheBudgetRule(read, limit: 10) { try cursor(h, container: note.id, block: $0) }

            let ids = try await pages(connection, ["note_id": .string(commented.id), "limit": 10, "ids_only": true])
            print("U7c P-3 the commented block, ids_only: \(sizes(ids))")
            #expect(ids.map(\.blocks.count) == [1, 1, 2], "the 40,000-character comment's block alone")
            #expect((ids.dropFirst().first?.blocks.first?["comments"] as? [[String: Any]])?.first?["text"] as? String
                    == String(repeating: "c", count: 40_000), "its comment whole")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-U7c-4: the first page's carriage counts

    /// The note-wide carriage — the tray, the versions, each lens's `dangling_picks`,
    /// `block_count` — rides the FIRST page and counts toward ITS answer: a 28,000-character
    /// deleted block in the tray leaves room for only one 2,000-character block, the page
    /// staying within 32,000; later pages, free of it, hold several. Before U7c only the
    /// tray's TEXT counted (28,000 + 2,000 + 2,000 fit) and the page answered past the
    /// budget — RED.
    @Test func theFirstPagesCarriageCountsTowardItsAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "carried")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let gone = try h.operations.newBlock(
                in: note.id, text: String(repeating: "g", count: 28_000), registeringUndo: false).block.id
            for index in 0..<12 {
                _ = try h.operations.newBlock(
                    in: note.id, text: String(repeating: "\(index % 10)", count: 2_000), registeringUndo: false)
            }
            try h.operations.deleteBlock(gone)
            _ = try h.operations.saveNoteVersion(note.id)
            _ = try h.operations.createLens(post: note.id, name: "a view")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, book.id))

            let read = try await pages(connection, [
                "note_id": .string(note.id), "with_tray": true, "with_versions": true, "with_lenses": true,
                "limit": 50,
            ])
            print("U7c P-4 the carriage: \(sizes(read))")
            try expectTheBudgetRule(read, limit: 50) { try cursor(h, container: note.id, block: $0) }
            #expect(read.first?.blocks.count == 1, "28,000 of tray leaves room for one block")
            #expect((read.first?.size ?? .max) <= answerBudget, "the first page, carriage and all, within the budget")
            #expect(read.dropFirst().first.map { $0.blocks.count > 1 } == true, "a page free of it holds several")
            #expect(read.first?.json["tray"] != nil && read.first?.json["versions"] != nil)
            #expect(read.dropFirst().allSatisfy { $0.json["tray"] == nil && $0.json["versions"] == nil })
            #expect(read.flatMap(\.blocks).count == 12)
            await h.hangUp(connection)
        }
    }

    /// The one-block floor stands over the carriage too (PROVISIONAL, the U7c record): a page
    /// always holds one whole block, so when the first page's carriage alone leaves no room
    /// (a 31,800-character tray) the first block still rides on it, the answer past the
    /// budget, and the pages after it are within it.
    @Test func theFirstPageHoldsOneBlockWhenItsCarriageLeavesNoRoom() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "crowded")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let gone = try h.operations.newBlock(
                in: note.id, text: String(repeating: "g", count: 31_800), registeringUndo: false).block.id
            for index in 0..<4 {
                _ = try h.operations.newBlock(in: note.id, text: "block \(index)", registeringUndo: false)
            }
            try h.operations.deleteBlock(gone)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, book.id))

            let read = try await pages(connection, ["note_id": .string(note.id), "with_tray": true, "limit": 50])
            print("U7c P-4b the crowded first page: \(sizes(read))")
            #expect(read.first?.blocks.count == 1, "one whole block, whatever the carriage")
            #expect(read.dropFirst().allSatisfy { $0.size <= answerBudget })
            #expect(read.flatMap(\.blocks).count == 4)
            await h.hangUp(connection)
        }
    }

    // MARK: - P-U7c-5: the composed asks

    /// Lens picks, lineage and commits all live in the answer, so they all count: a note of
    /// 60 two-take blocks, eight lenses each picking every block, every take carrying two
    /// 900-character commits and a short newest one, read `with_lenses`, `with_lineage` and
    /// `with_commits` at `limit: 200` — every page within 32,000 and full, the blocks tiling
    /// the note (compared with commit text set aside: which commit texts ride is each page's
    /// own budget), each page's picks only its own blocks', and commit text riding only in
    /// what each page has left (the newest, short, rides; the first that does not fit ends
    /// them). Before U7c none of the picks, records or commit metadata counted — RED.
    @Test func lensPicksLineageAndCommitsAllCountTowardThePage() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "composed")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            var blockIDs: [String] = []
            var others: [String] = []
            for index in 0..<60 {
                let minted = try h.operations.newBlock(
                    in: note.id, text: "Block \(index), the first take's words.", registeringUndo: false)
                blockIDs.append(minted.block.id)
                let other = try h.operations.branchVariant(minted.block.id, from: minted.variant.id)
                for take in [minted.variant.id, other.id] {
                    for round in 0..<3 {
                        let words = round == 2 ? "round 2, short." : String(repeating: "\(round)", count: 900)
                        try h.operations.autosave(take, text: words, charDelta: 900)
                        _ = try h.operations.commit(take, message: "round \(round)")
                    }
                }
                try h.operations.autosave(other.id, text: "Block \(index), the other take.", charDelta: 30)
                others.append(other.id)
            }
            for lensIndex in 0..<8 {
                let lens = try h.operations.createLens(post: note.id, name: "lens \(lensIndex)")
                for (block, take) in zip(blockIDs, others) {
                    _ = try h.operations.setLensChoice(lens: lens.id, block: block, variant: take)
                }
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.book, book.id))

            let asks: [String: Value] = [
                "note_id": .string(note.id), "with_lenses": true, "with_lineage": true, "with_commits": true,
            ]
            let whole = try json(try await readNote(connection, asks))
            var paged = asks
            paged["limit"] = 200
            let read = try await pages(connection, paged)
            print("U7c P-5 the composed asks: \(read.count) pages — \(sizes(read))")
            try #require(read.count > 1, "the budget pages it")
            try expectTheBudgetRule(read, limit: 200) { try cursor(h, container: note.id, block: $0) }
            let tiled = read.flatMap(\.blocks)
            #expect(tiled.map { $0["block_id"] as? String ?? "" } == blockIDs, "every block once, in order")
            #expect(tiled.map { canonical(withoutCommitText($0)) } == blocksOf(whole).map { canonical(withoutCommitText($0)) },
                    "entry for entry the unpaged read, commit text set aside")
            for page in read {
                let onPage = Set(page.blocks.map { $0["block_id"] as? String ?? "" })
                for lens in page.json["lenses"] as? [[String: Any]] ?? [] {
                    let picked = (lens["picks"] as? [[String: Any]] ?? []).map { $0["block_id"] as? String ?? "" }
                    #expect(Set(picked) == onPage, "each lens picks exactly the page's blocks")
                }
            }
            let riding = tiled.flatMap { $0["takes"] as? [[String: Any]] ?? [] }
                .flatMap { $0["commits"] as? [[String: Any]] ?? [] }
            #expect(riding.contains { $0["text"] != nil } && riding.contains { $0["text_omitted"] as? Bool == true },
                    "commit text rides in what each page has left, the rest omitted")
            await h.hangUp(connection)
        }
    }

    // MARK: - P-U7c-6: the description says it

    /// `read_note`'s description says the page bound as built: the answer, about 32,000
    /// characters, a block never split, a single larger block alone — and no longer the
    /// take-text budget.
    @Test func theDescriptionSaysTheAnswerBound() throws {
        let words = MCPToolCatalog.readNote.description
        #expect(words.contains(
            "A page also ends once the answer reaches about 32,000 characters (a block is never split; a single larger block comes alone)"),
            "the ruled sentence")
        #expect(!words.contains("takes' text passes"), "the take-text budget's words are gone")
        #expect(words.contains("commit text rides in what is left of that"), "the commit sentence kept")
    }
}
