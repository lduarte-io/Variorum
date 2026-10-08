import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13p, cold-review ladder R1-m6 — DIRECT evidence for the phase's
/// VERIFICATION bullet "convergence suites green over the encrypted
/// store": the Phase 5 two-client shape run over ON-DISK KEYED stores,
/// each device holding its OWN store key (R13p-4's per-store key),
/// proving the engine is byte-indifferent to the cipher. The convergence
/// suite proper runs in-memory/unkeyed, so until this pass "the engine
/// never sees the cipher" was an architectural claim (the pager sits
/// below the connection) with no observed fact behind it. One pass, the
/// cheapest honest form: push/pull/apply, a working-text race (S5), a
/// metadata race, quiescence — over ciphertext files, byte-scanned.
@Suite("Two-client convergence over KEYED stores (13p ladder R1-m6)")
struct KeyedStoreConvergenceTests {
    @Test func theEngineConvergesOverOnDiskKeyedStoresAndTheFilesStayCiphertext() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "variorum-13p-keyed-sync-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let server = FakeSyncServer()
        let urlA = dir.appendingPathComponent("device-a.sqlite")
        let urlB = dir.appendingPathComponent("device-b.sqlite")
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: server,
            storeURL: urlA, custody: .inMemory(initial: StoreKey.mint()))
        let b = try SyncClient(
            name: "B", prefix: "BB", transport: server, clockOffset: 977, seed: 2,
            storeURL: urlB, custody: .inMemory(initial: StoreKey.mint()))

        // Both stores are genuinely encrypted before a single row moves.
        #expect(StoreFilePresence.classify(at: urlA) == .encryptedOrUnknown,
                "device A's store is born ciphertext")
        #expect(StoreFilePresence.classify(at: urlB) == .encryptedOrUnknown,
                "device B's store is born ciphertext")

        // The Phase 5 classes, over the cipher: disjoint offline edits,
        // then a same-row working-text race (S5) and quiescence.
        let prose = "keyed convergence prose that must never reach the disk in the clear"
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "keyed", profile: .journal)
            return try ops.newBlock(in: post.id, text: prose, at: .end).variant.id
        }
        try b.with { ops, _ in
            let entry = try ops.createPost(title: "from B", profile: .blog)
            _ = try ops.newBlock(in: entry.id, text: "B's keyed thoughts.", at: .end)
        }
        try await syncToQuiescence(a, b, server: server)

        try a.with { ops, _ in
            try ops.autosave(variantID, text: prose + " — A's rewrite", charDelta: 12)
        }
        try b.with { ops, _ in
            try ops.autosave(variantID, text: prose + " — B's rewrite", charDelta: 12)
        }
        try await a.push()
        try await syncToQuiescence(a, b, server: server)

        // The crown, byte-unchanged from the in-memory suite: identical
        // synced tables, empty outboxes — the engine never noticed the key.
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
        // S5 held over the cipher: the losing edit is a card in the fan on
        // BOTH devices, nothing clobbered.
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL")
                == 1,
                "\(client.name): conflict-as-variant over the encrypted store")
        }

        // And the FILES never held the prose in the clear: close the pools and
        // byte-scan store + WAL.
        //
        // **17f/P50 — the WAL scan was reviewed as unfalsifiable ("the WAL is
        // checkpointed away before the test reads it") and MEASURED NOT TO BE.**
        // The premise was that `lock()` closes the last connection, so SQLite
        // checkpoints and deletes-or-truncates the `-wal`. Probed on this tree:
        // the WAL measures 1,100,072 / 1,153,632 bytes BEFORE `lock()` and the
        // identical byte counts AFTER it — the frames are still there, and the
        // scan below has always read real WAL content. The finding is recorded
        // as hollow rather than fixed.
        //
        // What WAS real is the silent-skip: `if let walBytes = try? …` meant a
        // missing WAL would make the assertion vanish with nothing said — the
        // hole the finding described would open later, unannounced. So the read
        // is HARD and the frames are asserted present: if a future change ever
        // does checkpoint the WAL away here, this says so instead of quietly
        // becoming the dead belt. (`StoreEncryptionTests`' "WAL pages encrypt
        // too" is the live sibling pin, scanning while its pool is open.)
        //
        // **13x W-1 — the future change this paragraph anticipated arrived:**
        // `lock()` now checkpoint-truncates, so the WAL is empty after it and
        // this pin said so, as designed. The WAL is therefore scanned WHILE
        // THE POOLS ARE OPEN (the sibling pin's shape), hard read and frames
        // asserted present; the main-file scan after the lock now also covers
        // every checkpointed frame.
        for url in [urlA, urlB] {
            let wal = URL(fileURLWithPath: url.path + "-wal")
            let walBytes = try Data(contentsOf: wal)
            #expect(!walBytes.isEmpty,
                    "\(url.lastPathComponent)'s WAL holds frames — an empty one scans nothing")
            #expect(walBytes.range(of: Data(prose.utf8)) == nil,
                    "\(url.lastPathComponent)'s WAL carries no plaintext prose")
        }
        a.db.asRebindable().binding.lock()
        b.db.asRebindable().binding.lock()
        for url in [urlA, urlB] {
            let bytes = try Data(contentsOf: url)
            #expect(bytes.range(of: Data(prose.utf8)) == nil,
                    "\(url.lastPathComponent) carries no plaintext prose")
        }
    }
}
