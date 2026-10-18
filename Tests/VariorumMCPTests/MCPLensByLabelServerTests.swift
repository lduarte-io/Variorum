import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-253 (VX-336 U5a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`):
// SAVE_LENS BY TAKE LABEL. Her ruling ("I like your 253 recommendation", with her
// clarification): three explicit fills, never a magic word — the picks (`take_ids`),
// `label`, or `pin_chosen: true`; the picks ride on either rule as per-block overrides,
// applied FIRST; a block with no take of that label shows its chosen take and is
// listed in `unmatched_blocks`; an AMBIGUOUS block no pick covers refuses the whole
// call, naming those blocks; labels match exactly as stored, plus the client's OWN
// suggestions by their own part (`<client> · <label>`, VX-267's form, and the legacy
// `<client> · suggested · <label>`), never another client's. The source: her
// bilingual book — ~7,700 take ids retyped for two lenses a note
// (`notes/mcp-agent-notes-2026-10-13-bilingual-book.md`, item 2).
//
// Wire only (the SDK's own client over a real socket), so every pin compiles — and
// runs RED — on the tree before the rule: there `label` and `pin_chosen` were
// silently ignored and the call saved an EMPTY lens.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// A refusal's JSON tail — the line after the sentence (nil when there is none).
private func refusalTail(_ result: (content: [Tool.Content], isError: Bool?)) -> [String: Any]? {
    let said = text(result)
    guard let newline = said.firstIndex(of: "\n") else { return nil }
    return (try? JSONSerialization.jsonObject(with: Data(said[said.index(after: newline)...].utf8))) as? [String: Any]
}

@Suite("VX-253 — save_lens by take label, end to end", .serialized)
struct MCPLensByLabelServerTests {
    /// A note in a book; each block her chosen take first, then the takes the test adds.
    private struct World {
        let book: Reading
        let note: Container
        let blocks: [String]
        let chosen: [String]
    }

    private func world(_ h: ServerHarness, _ texts: [String]) throws -> World {
        let book = try h.operations.createReading(name: "o ladrão de raios", kind: .book)
        let note = try h.operations.createPost(title: "ch 1")
        _ = try h.operations.addPostToReading(note.id, to: book.id)
        var blocks: [String] = []
        var chosen: [String] = []
        for text in texts {
            let made = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false)
            blocks.append(made.block.id)
            chosen.append(made.variant.id)
        }
        return World(book: book, note: note, blocks: blocks, chosen: chosen)
    }

    /// A take of hers on `blockID`, its text and stored label as given.
    private func take(_ h: ServerHarness, on blockID: String, _ text: String, label: String?) throws -> String {
        let made = try h.operations.newBlankVariant(blockID)
        try h.operations.autosave(made.id, text: text, charDelta: text.count)
        try h.operations.setTakeLabel(made.id, label: label)
        return made.id
    }

    private func selection(_ h: ServerHarness, _ lensID: String) async throws -> [String: String] {
        try await h.database.read { try Queries.effectiveLensSelection($0, lens: lensID) }
    }

    private func liveLenses(_ h: ServerHarness, _ noteID: String) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM lens WHERE container_id = ? AND deleted_at IS NULL",
                             arguments: [noteID]) ?? -1
        }
    }

    // MARK: - the label fill

    @Test func aLabelPicksEachBlocksTakeOfThatLabelAndListsTheBlocksWithNone() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, ["Olá.", "Tudo bem?", "Adeus.", "Fim.", "Obrigado."])
            let hers = try take(h, on: w.blocks[0], "Hello.", label: "english")
            // The legacy form — a take a client labelled before VX-267.
            let legacy = try take(h, on: w.blocks[2], "Goodbye.", label: "claude-code \u{00B7} suggested \u{00B7} english")
            // Another client's suggestion: never claude-code's by its own part.
            let theirs = try take(h, on: w.blocks[4], "Thanks.", label: "another-client \u{00B7} english")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            // claude-code's own suggestion, in VX-267's form, through the door.
            let added = try await call(connection, "add_take", [
                "block_id": .string(w.blocks[1]), "text": .string("All good?"), "label": .string("english"),
            ])
            let own = try #require(try json(added)["take_id"] as? String)
            let page = try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) }
            let depth = h.undoStack.depth

            let saved = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("english"), "label": .string("english"),
            ])
            #expect(saved.isError != true, "\(text(saved))")
            let answer = (try? json(saved)) ?? [:]
            let lensID = try #require(answer["lens_id"] as? String)
            let picked = try await selection(h, lensID)
            #expect(picked == [w.blocks[0]: hers, w.blocks[1]: own, w.blocks[2]: legacy],
                    "hers exactly as stored, its own in both forms — and never another client's")
            #expect(answer["unmatched_blocks"] as? [String] == [w.blocks[3], w.blocks[4]],
                    "the blocks with no take of that label, in note order: \(text(saved))")
            #expect(answer["unmatched_count"] as? Int == 2, "\(text(saved))")
            #expect(try await h.database.read { try Queries.renderedText($0, containerID: w.note.id) } == page,
                    "a lens never changes what the note shows")
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's lens",
                    "one client-named undo, as any lens")

            // Exactly as stored: the other client's FULL label matches its take.
            let exact = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("theirs"),
                "label": .string("another-client \u{00B7} english"),
            ])
            #expect(exact.isError != true, "\(text(exact))")
            let exactLens = try #require(try json(exact)["lens_id"] as? String)
            #expect(try await selection(h, exactLens) == [w.blocks[4]: theirs])
            #expect(try json(exact)["unmatched_count"] as? Int == 4)
            await h.hangUp(connection)
        }
    }

    // MARK: - the ambiguity refusal, then its retry

    @Test func anAmbiguousBlockRefusesTheWholeCallNamingItsTakesAndTheRetryWithTakeIdsLands() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, ["Olá.", "Tudo bem?", "Adeus."])
            // Block 0: her "english" AND claude-code's own suggested "english" — two.
            let hersOne = try take(h, on: w.blocks[0], "Hello.", label: "english")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let added = try await call(connection, "add_take", [
                "block_id": .string(w.blocks[0]), "text": .string("Hi."), "label": .string("english"),
            ])
            let ownOne = try #require(try json(added)["take_id"] as? String)
            // Block 1: one "english" only — no ambiguity.
            let hersTwo = try take(h, on: w.blocks[1], "All good?", label: "english")
            // Block 2: her "english" AND a legacy own suggestion — two, her ruling's case.
            let hersThree = try take(h, on: w.blocks[2], "Goodbye.", label: "english")
            let legacyThree = try take(h, on: w.blocks[2], "Bye.", label: "claude-code \u{00B7} suggested \u{00B7} english")
            let depth = h.undoStack.depth

            let refused = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("english"), "label": .string("english"),
            ])
            #expect(refused.isError == true, "the whole call refuses: \(text(refused))")
            #expect(text(refused).hasPrefix(
                "label \"english\" matches more than one take on 2 blocks, and a lens shows one take per block."),
                    "\(text(refused))")
            let tail = refusalTail(refused) ?? [:]
            let named = (tail["ambiguous_blocks"] as? [[String: Any]]) ?? []
            #expect(named.map { $0["block_id"] as? String } == [w.blocks[0], w.blocks[2]],
                    "the uncovered ambiguous blocks, in note order: \(text(refused))")
            let firstTakes = (named.first?["takes"] as? [[String: Any]]) ?? []
            #expect(firstTakes.map { $0["take_id"] as? String } == [hersOne, ownOne], "its matching takes, fan order")
            #expect(firstTakes.map { $0["label"] as? String } == ["english", "claude-code \u{00B7} english"])
            let lastTakes = (named.last?["takes"] as? [[String: Any]]) ?? []
            #expect(lastTakes.map { $0["take_id"] as? String } == [hersThree, legacyThree])
            #expect(tail["ambiguous_count"] as? Int == 2, "\(text(refused))")
            #expect(try await liveLenses(h, w.note.id) == 0 && h.undoStack.depth == depth, "nothing saved")

            // The retry: the same label, plus picks for exactly those blocks.
            let retried = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("english"), "label": .string("english"),
                "take_ids": .array([.string(ownOne), .string(hersThree)]),
            ])
            #expect(retried.isError != true, "\(text(retried))")
            let lensID = try #require(try json(retried)["lens_id"] as? String)
            #expect(try await selection(h, lensID) == [w.blocks[0]: ownOne, w.blocks[1]: hersTwo, w.blocks[2]: hersThree],
                    "picks first, then the label on every other block")
            #expect(try json(retried)["unmatched_blocks"] as? [String] == [])
            await h.hangUp(connection)
        }
    }

    // MARK: - pin_chosen: her Save Choices as Lens on the wire

    @Test func pinChosenPinsWhatEachBlockShowsNowWithThePicksFirst() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, ["One.", "Two.", "Three."])
            let alternative = try take(h, on: w.blocks[0], "One, again.", label: nil)
            let other = try take(h, on: w.blocks[1], "Two, again.", label: nil)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))

            let saved = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("as it reads"), "pin_chosen": .bool(true),
                "take_ids": .array([.string(alternative)]),
            ])
            #expect(saved.isError != true, "\(text(saved))")
            let lensID = try #require(try json(saved)["lens_id"] as? String)
            #expect(try await selection(h, lensID) == [w.blocks[0]: alternative, w.blocks[1]: w.chosen[1],
                                                        w.blocks[2]: w.chosen[2]],
                    "the pick first; every other block pinned to the take it shows")
            #expect(try json(saved)["unmatched_blocks"] as? [String] == [], "\(text(saved))")
            #expect(try json(saved)["unmatched_count"] as? Int == 0, "\(text(saved))")

            // Pinned: her later ✓ on block 1 never moves the lens.
            try h.operations.chooseVariant(w.blocks[1], variantID: other)
            #expect(try await selection(h, lensID)[w.blocks[1]] == w.chosen[1], "an explicit pick, not a fall-through")
            await h.hangUp(connection)
        }
    }

    // MARK: - the malformed fills

    @Test func everyMalformedFillRefusesAndSavesNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, ["Olá.", "Tudo bem?"])
            _ = try take(h, on: w.blocks[0], "Hello.", label: "english")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let base: [String: Value] = ["note_id": .string(w.note.id), "name": .string("a reading")]

            let cases: [([String: Value], String, String)] = [
                (["label": .string("english"), "pin_chosen": .bool(true)],
                 "Pass label or pin_chosen, not both \u{2014} take_ids can ride either.", "two rules"),
                ([:], "Pass take_ids (the take to show per block), label, or pin_chosen: true.", "no fill at all"),
                (["pin_chosen": .bool(false)],
                 "Pass take_ids (the take to show per block), label, or pin_chosen: true.", "pin_chosen false is none"),
                (["label": .string("")], "label can't be blank.", "an empty label"),
                (["label": .string("   ")], "label can't be blank.", "a blank label"),
                (["label": .int(5)], "label must be a string.", "a label that isn't a string"),
                (["pin_chosen": .string("yes")], "pin_chosen must be true or false.", "a pin_chosen that isn't a boolean"),
                (["label": .string("nope")],
                 "No take in this note is labelled \u{201C}nope\u{201D} \u{2014} nothing was saved.", "a label nothing wears"),
            ]
            for (extra, words, why) in cases {
                let answer = try await call(connection, "save_lens", base.merging(extra) { _, new in new })
                #expect(answer.isError == true && text(answer) == words, "\(why): \(text(answer))")
            }
            #expect(try await liveLenses(h, w.note.id) == 0, "nothing saved")
            await h.hangUp(connection)
        }
    }

    // MARK: - the fence (a GUARD — green on both sides by design)

    /// An unreachable note answers the ONE not-shared shape, byte-identical,
    /// whichever fill names it — the rule runs only after the decision.
    @Test func anUnreachableNoteAnswersTheOneNotSharedShapeWhateverTheFill() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, ["Olá."])
            _ = try take(h, on: w.blocks[0], "Hello.", label: "english")
            let unshared = try h.operations.createPost(title: "hers alone")
            let hidden = try h.operations.newBlock(in: unshared.id, text: "Segredo.", registeringUndo: false)
            _ = try take(h, on: hidden.block.id, "Secret.", label: "english")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))

            var answers: [String] = []
            for noteID in [unshared.id, "no-such-note"] {
                for fill: [String: Value] in [["take_ids": .array([])], ["label": .string("english")],
                                               ["pin_chosen": .bool(true)]] {
                    let answer = try await call(connection, "save_lens", [
                        "note_id": .string(noteID), "name": .string("a reading"),
                    ].merging(fill) { _, new in new })
                    #expect(answer.isError == true)
                    answers.append(text(answer))
                }
            }
            #expect(Set(answers).count == 1, "one answer, whatever the note or the fill: \(Set(answers))")
            #expect(try await liveLenses(h, unshared.id) == 0)
            await h.hangUp(connection)
        }
    }

    // MARK: - the answer's bounds

    /// A long note: `unmatched_blocks` carries the first 200 (note order), and
    /// `unmatched_count` the whole — the answer is bounded however long the note.
    @Test func unmatchedBlocksCarryTheFirstTwoHundredAndTheCountTheWhole() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, (0..<205).map { "Block \($0)." })
            let only = try take(h, on: w.blocks[3], "The one.", label: "english")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let saved = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("english"), "label": .string("english"),
            ])
            #expect(saved.isError != true, "\(text(saved))")
            let answer = (try? json(saved)) ?? [:]
            let lensID = try #require(answer["lens_id"] as? String)
            #expect(try await selection(h, lensID) == [w.blocks[3]: only])
            let unmatched = Array(w.blocks.enumerated().filter { $0.offset != 3 }.map(\.element))
            #expect(answer["unmatched_blocks"] as? [String] == Array(unmatched.prefix(200)))
            #expect(answer["unmatched_count"] as? Int == 204)
            await h.hangUp(connection)
        }
    }

    /// The ambiguity refusal names the first 200 ambiguous blocks, and the count the whole.
    @Test func theAmbiguityRefusalNamesTheFirstTwoHundredAndTheCountTheWhole() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h, (0..<201).map { "Block \($0)." })
            for blockID in w.blocks {
                _ = try take(h, on: blockID, "One.", label: "english")
                _ = try take(h, on: blockID, "Two.", label: "english")
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.suggest, .book, w.book.id))
            let refused = try await call(connection, "save_lens", [
                "note_id": .string(w.note.id), "name": .string("english"), "label": .string("english"),
            ])
            #expect(refused.isError == true, "\(text(refused).prefix(200))")
            let tail = refusalTail(refused) ?? [:]
            let named = (tail["ambiguous_blocks"] as? [[String: Any]]) ?? []
            #expect(named.map { $0["block_id"] as? String } == Array(w.blocks.prefix(200)))
            #expect(tail["ambiguous_count"] as? Int == 201)
            #expect(try await liveLenses(h, w.note.id) == 0)
            await h.hangUp(connection)
        }
    }
}
