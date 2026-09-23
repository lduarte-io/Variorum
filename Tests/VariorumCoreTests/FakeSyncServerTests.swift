import Foundation
import Testing
@testable import VariorumCore

@Suite("Fake sync server: CAS + changefeed fidelity (Phase 5, Step 2)")
struct FakeSyncServerTests {
    /// Phase 14c: a crafted row carries the caller's `owner_id` — the
    /// born-multi-tenant mirror refuses a client-carried owner table's row
    /// that does not (`is distinct from caller`), and the fake enforces
    /// that arm since the isolation round's finding I-2 retired its NULL
    /// latitude. These CAS/changefeed fixtures are the default account's.
    private func containerRow(
        id: String, title: String, base: Int, deletedAt: String? = nil
    ) -> SyncRow {
        SyncRow(
            table: "container", rowID: id,
            columns: [
                "id": .text(id), "kind": .text("post"),
                "owner_id": .text(FakeSyncServer.defaultUserID),
                "title": .text(title),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "deleted_at": deletedAt.map(SyncValue.text) ?? .null,
            ],
            syncVersion: base)
    }

    @Test func casAcceptBumpsVersionAndStampsMonotonicSeq() async throws {
        let server = FakeSyncServer()
        let first = try await server.push([containerRow(id: "c1", title: "a", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .accepted(let v1, let s1) = first[0] else {
            Issue.record("fresh row not accepted"); return
        }
        #expect(v1 == 1)
        #expect(s1 == 1)

        let second = try await server.push([containerRow(id: "c1", title: "b", base: 1)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .accepted(let v2, let s2) = second[0] else {
            Issue.record("matching base not accepted"); return
        }
        #expect(v2 == 2)
        #expect(s2 > s1, "server_seq must be globally monotonic")
    }

    @Test func staleBaseRejectsWithTheCurrentServerRow() async throws {
        let server = FakeSyncServer()
        _ = try await server.push([containerRow(id: "c1", title: "server truth", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        // A second writer still at base 0: rejected, and the reject carries
        // the CURRENT row (version + seq + payload), never a merge.
        let result = try await server.push([containerRow(id: "c1", title: "stale attempt", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .rejected(let current) = result[0], let current else {
            Issue.record("stale base was not rejected with the current row"); return
        }
        #expect(current.row.columns["title"] == .text("server truth"))
        #expect(current.row.syncVersion == 1)
        #expect(current.serverSeq == 1)
        // The reject changed nothing server-side.
        #expect(await server.headSeq == 1)
    }

    @Test func nonZeroBaseAgainstAbsentRowRejectsWithNil() async throws {
        let server = FakeSyncServer()
        let result = try await server.push([containerRow(id: "ghost", title: "x", base: 3)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        #expect(result[0] == .rejected(current: nil))
    }

    @Test func interleavedWritersConvergeThroughRejectAndRebase() async throws {
        let server = FakeSyncServer()
        _ = try await server.push([containerRow(id: "c1", title: "from A", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        // B races with base 0 → rejected; B rebases onto the current version
        // and pushes again → accepted at version 2.
        let rejected = try await server.push([containerRow(id: "c1", title: "from B", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .rejected(let current) = rejected[0], let current else {
            Issue.record("race not rejected"); return
        }
        let rebased = try await server.push(
            [containerRow(id: "c1", title: "from B", base: current.row.syncVersion)],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .accepted(let version, _) = rebased[0] else {
            Issue.record("rebased push not accepted"); return
        }
        #expect(version == 2)
        #expect(await server.currentRow(table: "container", rowID: "c1")?
            .columns["title"] == .text("from B"))
    }

    @Test func pullOrdersBySeqAndWindowsByCursorAndLimit() async throws {
        let server = FakeSyncServer()
        for (id, title) in [("c1", "one"), ("c2", "two"), ("c3", "three")] {
            _ = try await server.push([containerRow(id: id, title: title, base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        }

        let firstWindow = try await server.pull(since: 0, limit: 2, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(firstWindow.map(\.row.rowID) == ["c1", "c2"])
        #expect(firstWindow.map(\.serverSeq) == [1, 2])

        let rest = try await server.pull(since: firstWindow.last!.serverSeq, limit: 100, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(rest.map(\.row.rowID) == ["c3"])

        let empty = try await server.pull(since: rest.last!.serverSeq, limit: 100, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(empty.isEmpty)
    }

    /// State-based changefeed: an updated row appears ONCE, in its latest
    /// state, at its latest seq — a client that pulls from an old cursor
    /// never sees intermediate states.
    @Test func updatedRowAppearsOnceWithLatestStateAndSeq() async throws {
        let server = FakeSyncServer()
        _ = try await server.push([containerRow(id: "c1", title: "draft", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        _ = try await server.push([containerRow(id: "c2", title: "other", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        _ = try await server.push([containerRow(id: "c1", title: "final", base: 1)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))

        let all = try await server.pull(since: 0, limit: 100, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(all.map(\.row.rowID) == ["c2", "c1"], "re-accepted row moves to its new seq")
        let c1 = all.first { $0.row.rowID == "c1" }!
        #expect(c1.row.columns["title"] == .text("final"))
        #expect(c1.serverSeq == 3)
        #expect(all.count == 2, "each row appears exactly once")
    }

    @Test func tombstonesAreOrdinaryAcceptedUpdates() async throws {
        let server = FakeSyncServer()
        _ = try await server.push([containerRow(id: "c1", title: "alive", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        let result = try await server.push(
            [containerRow(id: "c1", title: "alive", base: 1, deletedAt: Fixture.now)],
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .accepted = result[0] else {
            Issue.record("tombstone update rejected"); return
        }
        let pulled = try await server.pull(since: 1, limit: 10, activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_pull"), deviceID: nil)
        #expect(pulled.count == 1)
        #expect(pulled[0].row.isTombstoned)
        #expect(await server.rowCount(table: "container") == 1, "tombstone never removes the row")
    }

    /// The dumbness is load-bearing (SyncSpec §2): the server accepts rows a
    /// client's live-unique indexes would refuse — two live placements for
    /// one block (an I2 violation locally) both land, because apply-time
    /// repair is the CLIENT's job.
    @Test func serverAcceptsRowsThatViolateClientUniqueIndexes() async throws {
        let server = FakeSyncServer()
        func placement(_ id: String) -> SyncRow {
            SyncRow(
                table: "container_block", rowID: id,
                columns: [
                    "id": .text(id), "container_id": .text("c\(id)"),
                    "block_id": .text("b1"),  // same block, both live
                    "position": .text("V"), "chosen_variant_id": .null,
                    "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                    "deleted_at": .null,
                ],
                syncVersion: 0)
        }
        let results = try await server.push([placement("p1"), placement("p2")], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        #expect(results.allSatisfy {
            if case .accepted = $0 { return true } else { return false }
        }, "the dumb server must accept both sides of an I2 race")
        // And a dangling reference: a variant whose block the server has
        // never seen. No FKs on the mirror.
        let dangling = SyncRow(
            table: "variant", rowID: "v-dangling",
            columns: [
                "id": .text("v-dangling"), "block_id": .text("b-never-pushed"),
                "working_text": .text("x"), "status": .text("active"),
                "locked": .integer(0), "fan_position": .text("V"),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "deleted_at": .null,
            ],
            syncVersion: 0)
        let danglingResult = try await server.push([dangling], activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        guard case .accepted = danglingResult[0] else {
            Issue.record("dangling FK refused — the mirror must not have FKs"); return
        }
    }
}
