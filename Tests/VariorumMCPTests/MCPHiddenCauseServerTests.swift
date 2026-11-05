import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-825 (the VX-809 run, batch 1 — her R-825-sweep (b), the orchestrator's
// A-809-4; PROVISIONAL P-809-2): A REFUSAL WHOSE CAUSE IS BEYOND REACH speaks
// one fixed sentence per act family; a refusal a READABLE entity explains keeps
// her words, re-keyed to the readable entities alone (no unreadable book's id
// rides the error into any host's words).
//
// - `add_note_to_book` and the ownership consult (`noteOwnedElsewhere` /
//   `noteMemberedElsewhere`) — the one live wire road (the record's F-2 trace);
// - `move_note_to_wing` and a FINISHED or SEALED holder (S-2 folds in).
//
// The forced bit stays: where the cause is hidden, a store without it lets the
// act land — these are the law's ONE recorded exception class, so each such pin
// asserts the refusal is EXACTLY the fixed sentence and carries nothing of the
// hidden book. Where a readable entity explains the refusal, the two stores'
// answers are byte-identical.
//
// RED ON OLD (run on the tree before this build): the hidden-cause arms answered
// the op's raw refusal — the harness's words carry the error whole, so the
// unreadable owner's or claimant's id crossed (`F0000000-…`), and on the Mac her
// table's words said its KIND ("…a book that owns its notes…"); the
// readable-claimant arm's two stores differed by the hidden claimant's id in
// `elsewhere`.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

@Suite("VX-825 — a refusal whose cause is beyond reach speaks one fixed sentence", .serialized)
struct MCPHiddenCauseServerTests {
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

    // MARK: - add_note_to_book: a claimant beyond reach

    /// A PLAIN target; the note is OWNED by a book the client can't read. A
    /// store without that book lets the add land; this one refuses — in the
    /// one fixed sentence, naming no book and no kind.
    @Test func anOwnerBeyondReachRefusesInTheOneSentence() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let target = try h.operations.createReading(name: "Target", kind: .book)
            let note = try h.operations.createPost(title: "loose")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            if hidden {
                let ops = hiddenOperations(h)
                let owner = try ops.createReading(name: "Vault", kind: .book)
                _ = try ops.setReadingOwned(owner.id, owned: true)
                _ = try ops.addPostToReading(note.id, to: owner.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, target.id))
            let added = try await connection.client.callTool(
                name: "add_note_to_book", arguments: ["note_id": .string(note.id), "book_id": .string(target.id)])
            await h.hangUp(connection)
            return added
        }
        #expect(!without.1, "a store without the owner lets it land: \(without.0)")
        #expect(withHidden.1 && withHidden.0 == MCPWriteTools.addHiddenCauseWords, "\(withHidden.0)")
    }

    /// An OWNED target; the note lives in a book the client can't read. The
    /// same one sentence — the owned-vs-membered kind collapses.
    @Test func aClaimantBeyondReachOfAnOwnedTargetRefusesInTheSameSentence() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let target = try h.operations.createReading(name: "Owned target", kind: .book)
            _ = try h.operations.setReadingOwned(target.id, owned: true)
            let note = try h.operations.createPost(title: "loose")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            if hidden {
                let ops = hiddenOperations(h)
                let other = try ops.createReading(name: "Elsewhere", kind: .book)
                _ = try ops.addPostToReading(note.id, to: other.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, target.id))
            let added = try await connection.client.callTool(
                name: "add_note_to_book", arguments: ["note_id": .string(note.id), "book_id": .string(target.id)])
            await h.hangUp(connection)
            return added
        }
        #expect(!without.1, "\(without.0)")
        #expect(withHidden.1 && withHidden.0 == MCPWriteTools.addHiddenCauseWords, "\(withHidden.0)")
    }

    // (No "readable plain book beside a hidden owner" arm: an owned book holds
    // its notes EXCLUSIVELY, so a note owned elsewhere has no second, plain
    // membership to read — only a sync residue could make one.)

    // MARK: - add_note_to_book: a readable claimant keeps her words

    /// An OWNED target; the note lives in a book the client READS — and, in
    /// the hidden store, in an unshared one too. The readable book explains
    /// the refusal: her words (the harness's: the op's error whole), keyed to
    /// the readable claimant ONLY — byte-identical across the stores.
    @Test func aReadableClaimantKeepsHerWordsKeyedToItAlone() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let target = try h.operations.createReading(name: "Owned target", kind: .book)
            _ = try h.operations.setReadingOwned(target.id, owned: true)
            let open = try h.operations.createReading(name: "Open", kind: .book)
            let note = try h.operations.createPost(title: "shared")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            _ = try h.operations.addPostToReading(note.id, to: open.id)
            if hidden {
                let ops = hiddenOperations(h)
                let other = try ops.createReading(name: "Elsewhere", kind: .book)
                _ = try ops.addPostToReading(note.id, to: other.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, open.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, target.id))
            let added = try await connection.client.callTool(
                name: "add_note_to_book", arguments: ["note_id": .string(note.id), "book_id": .string(target.id)])
            await h.hangUp(connection)
            return added
        }
        #expect(withHidden.1 && without.1, "both refuse: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        #expect(withHidden.0.contains("noteMemberedElsewhere") && !withHidden.0.contains("F0000000"), "\(withHidden.0)")
    }

    // MARK: - move_note_to_wing: a frozen holder beyond reach (S-2)

    /// The note is a member of a FINISHED book the client can't read: the
    /// move's one fixed sentence — never "finished", never the book.
    @Test(arguments: ["finished", "sealed"])
    func aFrozenHolderBeyondReachRefusesTheMoveInTheOneSentence(_ how: String) async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let wing = try h.operations.createWing(name: "elsewhere")
            let note = try h.operations.createPost(title: "stuck")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            if hidden {
                let ops = hiddenOperations(h)
                let frozen = try ops.createReading(name: "Done", kind: .book)
                _ = try ops.addPostToReading(note.id, to: frozen.id)
                if how == "sealed" { _ = try ops.sealReading(frozen.id) } else { try ops.lockReading(frozen.id) }
            } else if how == "sealed" {
                // A seal stamps the NOTE sealed too — a fact of the readable
                // note itself, so the store without the book has it as well.
                try h.operations.lockPost(note.id)
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .note, note.id, .connection))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, wing.id))
            let moved = try await connection.client.callTool(
                name: "move_note_to_wing", arguments: ["note_id": .string(note.id), "wing_id": .string(wing.id)])
            await h.hangUp(connection)
            return moved
        }
        #expect(!without.1, "\(without.0)")
        #expect(withHidden.1 && withHidden.0 == MCPWriteTools.moveHiddenCauseWords, "\(withHidden.0)")
    }

    /// A readable FINISHED book holds the note — and, in the hidden store, an
    /// older unreadable SEALED one too (the op meets it first). The readable
    /// book explains the refusal: the same refusal in both stores, keyed to it.
    @Test func aReadableFrozenHolderIsTheOneNamedWhateverTheOpMetFirst() async throws {
        let (withHidden, without) = try await twoStores { h, hidden in
            let wing = try h.operations.createWing(name: "elsewhere")
            let note = try h.operations.createPost(title: "stuck")
            _ = try h.operations.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            if hidden {
                let ops = hiddenOperations(h)
                let sealed = try ops.createReading(name: "Sealed", kind: .book)
                _ = try ops.addPostToReading(note.id, to: sealed.id)
                _ = try ops.sealReading(sealed.id)
            }
            let done = try h.operations.createReading(name: "Done", kind: .book)
            _ = try h.operations.addPostToReading(note.id, to: done.id)
            try h.operations.lockReading(done.id)
            // The seal stamps the NOTE sealed too — a fact of the readable note,
            // mirrored in the store without the book (after the ids that answer).
            if !hidden { try h.operations.lockPost(note.id) }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, done.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, wing.id))
            let moved = try await connection.client.callTool(
                name: "move_note_to_wing", arguments: ["note_id": .string(note.id), "wing_id": .string(wing.id)])
            await h.hangUp(connection)
            return moved
        }
        #expect(withHidden.1 && without.1, "both refuse: \(withHidden.0) / \(without.0)")
        #expect(withHidden.0 == without.0, "byte-identical:\n\(withHidden.0)\n\(without.0)")
        #expect(withHidden.0.contains("lockedReading") && !withHidden.0.contains("F0000000"), "\(withHidden.0)")
    }
}
