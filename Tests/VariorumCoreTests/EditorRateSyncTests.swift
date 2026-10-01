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
///
/// RUN B batch B4 (ledger row 14): every mid-session sync beat and the
/// closing quiescence run production's round shape — pull → push per
/// device, never the retired push-both-then-pull order. Boundary cell:
/// the session's structural family (divide) is the sweep suite's S6; a
/// stranded `commit_point` chunk is a leaf append-only straggler with no
/// dependent, covered by the generic mid-drain resume
/// (FaultInjectionSyncTests (c)).
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
            _ = try await productionRound(mac)
            _ = try await productionRound(phone)
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
        _ = try await productionRound(mac)
        _ = try await productionRound(phone)

        // Teardown: the open tail crystallizes on editor close.
        try mac.with { ops, _ in
            _ = try ops.newBlock(in: postID, text: "Trailing tail, crystallized at teardown", at: .end)
        }

        _ = try await productionQuiescence(mac, phone, server: server)
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

    /// Phase 10 Step 10(iii): the same convergence bar at MULTI-POST scale —
    /// a book-view-shaped session (edits hopping across three posts, the
    /// focus-handoff write pattern) with held observations (library +
    /// reading + post — what the Phase 10 views hold) delivering THROUGHOUT
    /// the rounds, plus the 2026-07-12 spacing ruling's content shape
    /// (trailing-newline blocks) crossing the wire as ordinary content.
    @Test func aMultiPostEditingSessionConvergesWhileViewsObserve() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        // Three posts in a curated reading — the book view's world. Post 1
        // carries the spacing ruling's shape (a stored trailing newline).
        var postIDs: [String] = []
        var variantIDs: [String] = []
        let readingID: String = try mac.with { ops, _ in
            let reading = try ops.createReading(name: "book", kind: .book)
            for i in 0..<3 {
                let post = try ops.createPost(title: "post \(i)")
                let minted = try ops.newBlock(
                    in: post.id,
                    text: i == 1 ? "Spaced paragraph.\n" : "Body of post \(i).",
                    at: .end)
                postIDs.append(post.id)
                variantIDs.append(minted.variant.id)
                try ops.addPostToReading(post.id, to: reading.id)
            }
            return reading.id
        }
        _ = try await productionQuiescence(mac, phone, server: server)

        // The observations a Phase 10 shell holds, iterated concurrently
        // for the session's duration (the phone side).
        let libraryFeed = phone.db.observeLibrary(sort: .lastTouched, direction: .desc, limit: 50)
        let readingFeed = phone.db.observeReading(readingID, limit: 300)
        let postFeed = phone.db.observePost(postIDs[1])
        let deliveries = LockIsolated((library: 0, reading: 0, post: 0))
        let observers = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    var iterator = libraryFeed.makeAsyncIterator()
                    while (try? await iterator.next()) != nil {
                        deliveries.withValue { $0.library += 1 }
                    }
                }
                group.addTask {
                    var iterator = readingFeed.makeAsyncIterator()
                    while (try? await iterator.next()) != nil {
                        deliveries.withValue { $0.reading += 1 }
                    }
                }
                group.addTask {
                    var iterator = postFeed.makeAsyncIterator()
                    while (try? await iterator.next()) != nil {
                        deliveries.withValue { $0.post += 1 }
                    }
                }
                await group.waitForAll()
            }
        }

        // The focus-handoff write pattern: bursts land in ONE post, the
        // switch flushes, the next post gets the live editor — while the
        // phone edits a DIFFERENT post and engine rounds interleave.
        var buffers = ["Body of post 0.", "Spaced paragraph.\n", "Body of post 2."]
        for round in 1...4 {
            let focused = round % 3
            try mac.with { ops, _ in
                for _ in 1...10 {
                    buffers[focused].append("m")
                    try ops.autosave(variantIDs[focused], text: buffers[focused], charDelta: 1)
                }
            }
            try phone.with { ops, _ in
                let other = (focused + 1) % 3
                buffers[other].append("p")
                try ops.autosave(variantIDs[other], text: buffers[other], charDelta: 1)
            }
            _ = try await productionRound(mac)
            _ = try await productionRound(phone)
        }
        // A reorder (the readings face) and a fresh member mid-session.
        try mac.with { ops, _ in
            try ops.reorderReadingPost(postIDs[2], in: readingID, to: .start)
            let fresh = try ops.createPost(title: "late arrival")
            try ops.addPostToReading(fresh.id, to: readingID)
        }

        _ = try await productionQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        #expect(try mac.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)

        // The held observations delivered during the session and their
        // final values equal the converged store (UI state is a projection,
        // never a source of truth).
        try await Task.sleep(for: .milliseconds(100))
        observers.cancel()
        let counts = deliveries.value
        #expect(counts.library > 1 && counts.reading > 1 && counts.post > 1,
                "held observations deliver throughout the session: \(counts)")
        let macAssembly = try await mac.db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        }
        let phoneAssembly = try await phone.db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        }
        #expect(macAssembly == phoneAssembly)
        #expect(macAssembly.count == 4)
        #expect(macAssembly.first?.title == "post 2")

        // The spaced block's trailing newline crossed the wire as content;
        // the rendered projection completes it identically on both sides.
        let macText = try await mac.db.read { [post = postIDs[1]] in
            try Queries.renderedText($0, containerID: post)
        }
        let phoneText = try await phone.db.read { [post = postIDs[1]] in
            try Queries.renderedText($0, containerID: post)
        }
        #expect(macText == phoneText)
        #expect(macText.contains("Spaced paragraph.\n"))
    }
}
