import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// VX-314 (Castle rebuild phase 4) — the account-binding gate: new writing
/// belongs to the LIBRARY's account (the protection record's — "the record
/// names the account; signing in or out never changes it"), not whoever is
/// signed in. The engine refuses a round under a mismatched sign-in BEFORE
/// any network contact — outbox intact, cursor unmoved, the §12 refusal
/// grammar — and heals with no state surgery once the sign-in matches. The
/// facts are injected (`SyncAccountBinding`, the `keyProvider` pattern):
/// nil anywhere leaves the gate INERT, which is today's road exactly.
@Suite("VX-314 — the account-binding gate")
struct AccountBindingGateTests {
    @Test func aMismatchedSignInRefusesBothHalvesWithOutboxAndCursorIntact() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)

        // Seed a real cursor and a clean push in a matched world first.
        try a.with { ops, _ in
            _ = try ops.createPost(title: "written under the right account", profile: .journal)
        }
        _ = try await a.push()
        _ = try await a.pull()
        let cursorBefore = try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        try a.with { ops, _ in
            _ = try ops.createPost(title: "written while the wrong account is signed in", profile: .journal)
        }
        let outboxBefore = try a.outboxCount()
        #expect(outboxBefore > 0)

        // The library is bound to X; the session now belongs to Y.
        a.accountBinding = SyncAccountBinding(
            boundAccount: { "account-x" }, signedInAccount: { "account-y" })

        let expected = SyncError.accountMismatch(bound: "account-x", signedIn: "account-y")
        await #expect(throws: expected) { _ = try await a.push() }
        await #expect(throws: expected) { _ = try await a.pull() }
        await #expect(throws: expected) { _ = try await a.pullToHead() }

        #expect(try a.outboxCount() == outboxBefore,
                "the refusal keeps the outbox byte-intact")
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == cursorBefore,
                "the refusal never moves the cursor")
        #expect(await server.rowCount(table: "container") == 1,
                "nothing was pushed past the refusal — the second note never left")

        // Signing back into the library's account heals with no state
        // surgery — the same client, the same outbox.
        a.accountBinding = SyncAccountBinding(
            boundAccount: { "account-x" }, signedInAccount: { "account-x" })
        _ = try await a.push()
        _ = try await a.pull()
        #expect(try a.outboxCount() == 0)
        #expect(await server.rowCount(table: "container") == 2)
    }

    @Test func aNilFactAnywhereLeavesTheGateInert() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            _ = try ops.createPost(title: "an unbound or signed-out world still syncs", profile: .journal)
        }

        // An unbound library (bound nil) — some other state's business.
        a.accountBinding = SyncAccountBinding(
            boundAccount: { nil }, signedInAccount: { "account-y" })
        _ = try await a.push()

        // A signed-out session (signedIn nil) — the transport's business.
        try a.with { ops, _ in
            _ = try ops.createPost(title: "two", profile: .journal)
        }
        a.accountBinding = SyncAccountBinding(
            boundAccount: { "account-x" }, signedInAccount: { nil })
        _ = try await a.push()

        // No binding at all — production's today-road composition.
        a.accountBinding = nil
        _ = try await a.pull()
        #expect(try a.outboxCount() == 0)
        #expect(await server.rowCount(table: "container") == 2)
    }
}
