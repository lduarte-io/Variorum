import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// pre-13u Act 10 wave 2a — **T1's guard, pinned** (memo §9b): the
/// stale-copy re-key clobber's recency comparison. The probe reads the
/// server's PLAIN facts from the local copy's own cursor and counts what
/// the server holds that this copy lacks — while writing NOTHING: no
/// local row, no cursor move, no outbox entry, and (deviceID nil on every
/// window) no server-side device_cursor either.
@Suite("The re-key recency probe (T1's guard)")
struct RekeyRecencyProbeTests {
    private func probe(for client: SyncClient, server: FakeSyncServer) -> RekeyRecencyProbe {
        RekeyRecencyProbe(transport: server, keyProvider: client.keyProvider)
    }

    private func assess(
        _ client: SyncClient, _ server: FakeSyncServer
    ) async throws -> RekeyRecencyReport {
        try await client.withAsync { _ in
            try await probe(for: client, server: server).assess()
        }
    }

    /// The trap's exact shape: a copy that slept while the server moved
    /// on. N counts the notes it never saw, M the ones the server knows
    /// newer, and the latest date is named — her count-and-dates ruling.
    @Test func aStaleCopySeesWhatTheServerLearnedSinceItsDay() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let stale = try SyncClient(
            name: "Backup", prefix: "BB", transport: server, clockOffset: 60)

        // Day 1: three notes exist; the (future) stale copy is in sync.
        let editedID: String = try mac.with { ops, _ in
            let a = try ops.createPost(title: "Alpha", profile: .blog)
            _ = try ops.newBlock(in: a.id, text: "alpha body", at: .end)
            let b = try ops.createPost(title: "Beta", profile: .blog)
            _ = try ops.newBlock(in: b.id, text: "beta body", at: .end)
            _ = try ops.createPost(title: "Gamma", profile: .blog)
            return b.id
        }
        _ = try await mac.push()
        _ = try await stale.pull()

        // The month passes: one note retitled (a newer version), two new
        // notes born, and one born-then-deleted (must NOT count).
        try mac.with { ops, _ in
            try ops.renameContainer(editedID, title: "Beta, revised")
            _ = try ops.createPost(title: "Delta", profile: .blog)
            _ = try ops.createPost(title: "Epsilon", profile: .blog)
            let gone = try ops.createPost(title: "Ghost", profile: .blog)
            try ops.deleteContainer(gone.id)
        }
        _ = try await mac.push()

        // The vantage BEFORE the probe: the stale copy's client cursor,
        // and the server-side device cursor its one legitimate pull
        // recorded (the horizon's substrate).
        let cursorBefore = try await stale.db.read {
            try String.fetchOne(
                $0, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        }
        let staleDeviceID = try await stale.db.read {
            try String.fetchOne(
                $0, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
        }
        var serverCursorBefore: Int64?
        if let staleDeviceID { serverCursorBefore = await server.deviceCursor(staleDeviceID) }

        let report = try await assess(stale, server)
        #expect(report.notesOnlyOnServer == 2, "Delta + Epsilon; never the tombstoned Ghost")
        #expect(report.notesNewerOnServer == 1, "Beta's revision")
        #expect(report.serverIsAhead)
        #expect(report.latestServerChange != nil)

        // READ-ONLY, proven on both sides: the stale copy's cursor and
        // outbox untouched, and the server-side device cursor EXACTLY
        // where the legitimate pull left it (deviceID nil on every probe
        // window — a probe must never move the purge horizon's substrate).
        let cursorAfter = try await stale.db.read {
            try String.fetchOne(
                $0, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        }
        #expect(cursorAfter == cursorBefore)
        #expect(try stale.outboxCount() == 0)
        if let staleDeviceID {
            #expect(await server.deviceCursor(staleDeviceID) == serverCursorBefore)
        }
        // A second assess reads the same answer — nothing was consumed.
        let again = try await assess(stale, server)
        #expect(again == report)
    }

    /// The near-EMPTY corner (memo §9b's adjacent corner): a fresh store
    /// signed into a full account sees the WHOLE server picture — its
    /// cursor is 0, so emptiness can never silently clobber a full server.
    @Test func aFreshStoreSeesTheWholeServer() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        try mac.with { ops, _ in
            _ = try ops.createPost(title: "One", profile: .blog)
            _ = try ops.createPost(title: "Two", profile: .blog)
            _ = try ops.createPost(title: "Three", profile: .blog)
        }
        _ = try await mac.push()

        let fresh = try SyncClient(name: "Fresh", prefix: "CC", transport: server)
        let report = try await assess(fresh, server)
        #expect(report.notesOnlyOnServer == 3)
        #expect(report.notesNewerOnServer == 0)
        #expect(report.serverIsAhead)
    }

    /// A CURRENT copy — pulled to head — reports nothing, and the door
    /// proceeds without a word (the guard warns, never nags).
    @Test func aCurrentCopyReportsNothing() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        try mac.with { ops, _ in
            _ = try ops.createPost(title: "One", profile: .blog)
        }
        _ = try await mac.push()
        _ = try await mac.pull()  // the echo advances the cursor to head

        let report = try await assess(mac, server)
        #expect(!report.serverIsAhead)
        #expect(report.notesOnlyOnServer == 0)
        #expect(report.notesNewerOnServer == 0)
        #expect(RekeyGuardRule.decide(report) == .proceed)
    }

    /// The rule itself (the face's mechanism, revertible): server-ahead
    /// interposes the warning; current or unassessable proceeds.
    @Test func theRuleWarnsExactlyWhenTheServerIsAhead() {
        #expect(RekeyGuardRule.decide(nil) == .proceed)
        #expect(RekeyGuardRule.decide(RekeyRecencyReport()) == .proceed)
        #expect(RekeyGuardRule.decide(
            RekeyRecencyReport(notesOnlyOnServer: 1)) == .warnFirst)
        #expect(RekeyGuardRule.decide(
            RekeyRecencyReport(notesNewerOnServer: 1)) == .warnFirst)
    }

    /// Local edits PENDING (the copy ahead of the server) never trip the
    /// warning — the re-push is exactly what preserves them.
    @Test func aCopyAheadOfTheServerProceeds() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        try mac.with { ops, _ in
            _ = try ops.createPost(title: "One", profile: .blog)
        }
        _ = try await mac.push()
        _ = try await mac.pull()
        try mac.with { ops, _ in
            _ = try ops.createPost(title: "Two, unpushed", profile: .blog)
        }
        let report = try await assess(mac, server)
        #expect(!report.serverIsAhead)
    }
}
