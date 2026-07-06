import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 7 Step 8: sync keeps converging under editor-rate writes. The
/// scripted session drives exactly the operations the editor emits —
/// keystroke-burst autosaves (the coalescing outbox's real load), type-time
/// crystallization mints, a manual commit, fan growth + choose, and the
/// teardown mint — while the Phase 5 engine syncs a second in-memory client
/// MID-session (not just at the end). Convergence bar unchanged: empty
/// outboxes, byte-identical synced tables.
@Suite("Sync under editor-rate writes (Phase 7, Step 8)")
struct EditorRateSyncTests {
    @Test func aTypingSessionConvergesUnderInterleavedSync() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        // The Mac editor opens a post; the first paragraph crystallized.
        let (postID, blockID, variantID): (String, String, String) = try mac.with { ops, _ in
            let post = try ops.createPost(title: "Editor session", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "First paragraph.", at: .end)
            return (post.id, minted.block.id, minted.variant.id)
        }
        // The phone captures a journal entry, offline so far.
        let phoneVariantID: String = try phone.with { ops, _ in
            let entry = try ops.createPost(title: "2026-07-06", profile: .journal)
            return try ops.newBlock(in: entry.id, text: "Phone thought.", at: .end).variant.id
        }

        // Five typing bursts, a sync round after each (the editor's autosave
        // debounce fires ~2/sec; the engine may run at any moment between).
        var buffer = "First paragraph."
        for _ in 1...5 {
            try mac.with { ops, _ in
                for _ in 1...20 {
                    buffer.append("x")
                    try ops.autosave(variantID, text: buffer, charDelta: 1)
                }
            }
            _ = try await mac.push()
            _ = try await phone.push()
            _ = try await mac.pull()
            _ = try await phone.pull()
        }

        // Mid-session structure: a crystallization mint, a manual commit,
        // fan growth + choose (the fan panel's gestures).
        try mac.with { ops, _ in
            _ = try ops.newBlock(in: postID, text: "Second paragraph, typed past.", at: .end)
            _ = try ops.commit(variantID, kind: .manual)
            let branch = try ops.branchVariant(blockID, from: variantID)
            try ops.autosave(branch.id, text: "A different take.", charDelta: 17)
            try ops.chooseVariant(blockID, variantID: branch.id)
        }
        // The phone keeps editing its own entry (capture surface).
        try phone.with { ops, _ in
            try ops.autosave(phoneVariantID, text: "Phone thought, extended.", charDelta: 10)
        }
        _ = try await mac.push()
        _ = try await phone.pull()

        // Teardown: the open tail crystallizes on editor close.
        try mac.with { ops, _ in
            _ = try ops.newBlock(in: postID, text: "Trailing tail, crystallized at teardown", at: .end)
        }

        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        #expect(try mac.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)

        // The phone sees the whole editor session, rendered identically.
        let macText = try await mac.db.read { try Queries.renderedText($0, containerID: postID) }
        let phoneText = try await phone.db.read { try Queries.renderedText($0, containerID: postID) }
        #expect(macText == phoneText)
        #expect(phoneText.contains("A different take."))          // the chosen branch
        #expect(phoneText.contains("Second paragraph"))
        #expect(phoneText.contains("Trailing tail"))
        let phoneCommits = try await phone.db.read {
            try Queries.commitHistory($0, variantID: variantID).count
        }
        #expect(phoneCommits == 1)                                 // the manual commit arrived
    }
}
