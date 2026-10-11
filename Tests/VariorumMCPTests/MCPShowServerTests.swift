import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// 13n-b U4 — NAVIGATION (R-13nb-23 + R-13nb-26 (g); AF-11 F-3): her etiquette
// as ONE pure decision (`MCPShowRule`), pinned at the decision seam; and
// `show_in_app` end to end over the socket with a fake app delivery that
// applies the same rule — decided at READ on the target, never spending a
// once grant, the one answer for an unreadable target, nothing delivered
// unless the rule says navigate. Plus the receipts' "Open ›" targets.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: (client: Client, fd: Int32), _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// A fake app: stands where the test says, applies the RULE, records what it
/// would have delivered — the contract `MCPHostHooks.show` states.
private final class FakeApp: @unchecked Sendable {
    let standing = LockIsolated(MCPShowRule.Standing.frontmostMainWindow)
    let delivered = LockIsolated<[MCPShowTarget]>([])

    var hook: @Sendable (MCPShowTarget) async -> MCPShowRule.Verdict {
        { [self] target in
            let verdict = MCPShowRule.verdict(standing.value)
            if verdict == .navigate { delivered.withValue { $0.append(target) } }
            return verdict
        }
    }
}

@Suite("13n-b U4 — show_in_app and the move dial's etiquette", .serialized)
struct MCPShowServerTests {
    // MARK: - The decision seam (pure)

    @Test func theMoveDialMovesOnlyWhenVariorumIsInFrontInItsMainWindow() {
        #expect(MCPShowRule.verdict(.frontmostMainWindow) == .navigate)
        #expect(MCPShowRule.verdict(.notFrontmost) == .refuse(MCPShowRule.notFrontmostWords),
                "never while she isn't at the app — refused, never queued")
        #expect(MCPShowRule.verdict(.frontmostOtherWindow) == .refuse(MCPShowRule.otherWindowWords),
                "never by raising another window")
    }

    // MARK: - End to end

    @Test func showInAppDeliversOnlyWhenTheRuleSaysNavigateAndNeverSpendsAOnceGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let note = try h.operations.createPost(title: "shared once")
            let block = try h.operations.newBlock(in: note.id, text: "Read me here.", registeringUndo: false)
            let other = try h.operations.createPost(title: "not shared")
            let foreign = try h.operations.newBlock(in: other.id, text: "Elsewhere.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id, .once))

            let shown = try await call(connection, "show_in_app", [
                "note_id": .string(note.id), "block_id": .string(block.block.id), "select": .string("Read me"),
            ])
            #expect(shown.isError != true, "\(text(shown))")
            #expect(app.delivered.value == [.note(noteID: note.id, blockID: block.block.id, select: "Read me")],
                    "the 13o landing road's three facts: the note, the block, the words")

            app.standing.setValue(.notFrontmost)
            let away = try await call(connection, "show_in_app", ["note_id": .string(note.id)])
            #expect(away.isError == true && text(away) == MCPShowRule.notFrontmostWords)
            app.standing.setValue(.frontmostOtherWindow)
            let otherWindow = try await call(connection, "show_in_app", ["note_id": .string(note.id)])
            #expect(otherWindow.isError == true && text(otherWindow) == MCPShowRule.otherWindowWords)
            #expect(app.delivered.value.count == 1, "nothing moved while she was away")
            app.standing.setValue(.frontmostMainWindow)

            let unshared = try await call(connection, "show_in_app", ["note_id": .string(other.id)])
            #expect(unshared.isError == true && text(unshared).hasPrefix("That note isn't shared with this client"),
                    "a target the client cannot read answers the ONE answer")
            let misaddressed = try await call(connection, "show_in_app", [
                "note_id": .string(note.id), "target": .string("takes"), "block_id": .string(foreign.block.id),
            ])
            #expect(misaddressed.isError == true && text(misaddressed) == "block_id isn't a block of this note.")
            #expect(app.delivered.value.count == 1)
            #expect(try await call(connection, "read_note", ["note_id": .string(note.id)]).isError != true,
                    "showing never spent the ONCE grant — the read still has it")
            await h.hangUp(connection)
        }
    }

    @Test func everyTargetIsAddressedAndCheckedAgainstItsHome() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let book = try h.operations.createReading(name: "lessons", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "1")
            let otherBook = try h.operations.createReading(name: "other", kind: .book)
            let otherChapter = try h.operations.createSection(in: otherBook.id, name: "x")
            let note = try h.operations.createPost(title: "lesson")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let block = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            let lens = try h.operations.createLens(post: note.id, name: "alt")
            let stranger = try h.operations.createPost(title: "stranger")
            let strangerLens = try h.operations.createLens(post: stranger.id, name: "theirs")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .book, book.id))

            for (arguments, target) in [
                (["target": Value.string("takes"), "note_id": .string(note.id), "block_id": .string(block.block.id)],
                 MCPShowTarget.takes(noteID: note.id, blockID: block.block.id)),
                (["target": .string("lens"), "note_id": .string(note.id), "lens_id": .string(lens.id)],
                 .lens(noteID: note.id, lensID: lens.id)),
                (["target": .string("book"), "book_id": .string(book.id), "section_id": .string(chapter.id)],
                 .book(bookID: book.id, sectionID: chapter.id)),
                (["target": .string("book"), "book_id": .string(book.id)], .book(bookID: book.id, sectionID: nil)),
            ] {
                let result = try await call(connection, "show_in_app", arguments)
                #expect(result.isError != true, "\(text(result))")
                #expect(app.delivered.value.last == target)
            }
            let wrongLens = try await call(connection, "show_in_app", [
                "target": .string("lens"), "note_id": .string(note.id), "lens_id": .string(strangerLens.id),
            ])
            #expect(wrongLens.isError == true && text(wrongLens) == "lens_id isn't a lens of this note.")
            let wrongChapter = try await call(connection, "show_in_app", [
                "target": .string("book"), "book_id": .string(book.id), "section_id": .string(otherChapter.id),
            ])
            #expect(wrongChapter.isError == true && text(wrongChapter) == "section_id isn't a chapter of this book.")
            let unsharedBook = try await call(connection, "show_in_app", [
                "target": .string("book"), "book_id": .string(otherBook.id),
            ])
            #expect(unsharedBook.isError == true && text(unsharedBook).hasPrefix("That book isn't shared with this client"))
            #expect(app.delivered.value.count == 4)
            await h.hangUp(connection)
        }
    }

    @Test func aHostWithNoAppShowsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let note = try h.operations.createPost(title: "n")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, note.id))
            let result = try await call(connection, "show_in_app", ["note_id": .string(note.id)])
            #expect(result.isError == true && text(result) == MCPShowRule.unavailableWords)
            await h.hangUp(connection)
        }
    }

    // MARK: - The receipts' "Open ›" (AF-11 F-2)

    @Test func everyWriteReceiptCarriesWhereItsOpenDoorGoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            let block = try h.operations.newBlock(in: note.id, text: "Words here.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let take = try json(try await call(connection, "add_take", [
                "block_id": .string(block.block.id), "text": .string("ai"),
            ]))
            let lens = try json(try await call(connection, "save_lens", [
                "note_id": .string(note.id), "name": .string("fact check"),
                "take_ids": .array([.string(take["take_id"] as? String ?? "")]),
            ]))
            let chapter = try json(try await call(connection, "create_section", [
                "book_id": .string(book.id), "name": .string("2"),
            ]))
            let shows = h.receipts.value.map(\.show)
            #expect(shows == [
                .takes(noteID: note.id, blockID: block.block.id),
                .lens(noteID: note.id, lensID: lens["lens_id"] as? String ?? ""),
                .book(bookID: book.id, sectionID: chapter["section_id"] as? String),
            ])
            await h.hangUp(connection)
        }
    }
}
