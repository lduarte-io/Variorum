import Foundation
import Testing
@testable import VariorumCore

/// The Phase 5 author-assist gate (SyncSpec §10, phase plan Step 8): ONE
/// integration pass of the Step 7 basic offline-edit convergence scenario
/// against a REAL Supabase project — two local in-memory stores, the real
/// `SupabaseTransport`, the real `sync_push`/`sync_pull` RPCs. The whole
/// correctness suite is already green against the in-process fake; this
/// proves only the wire: transport ↔ RPC ↔ Postgres mirrors.
///
/// Env-gated: skipped (and `swift test` unaffected) unless all three of
/// VARIORUM_SUPABASE_URL / VARIORUM_SUPABASE_API_KEY / VARIORUM_SUPABASE_TOKEN
/// are set — sourced from the untracked `.env.supabase.local` at the author's
/// machine, never from anything committed.
///
/// The server is stateful across runs, so this test is written to be
/// re-runnable: clients mint random UUIDs (`mintsRandomUUIDs`) so a previous
/// run's rows never CAS-collide, a per-run nonce marks this run's content,
/// and prior runs' rows simply pull into both stores equally — the
/// byte-equality surface stays valid.
@Suite("Supabase integration pass (Phase 5, Step 8 — REAL server)")
struct SupabaseIntegrationTests {
    private static var configuration: SupabaseTransport.Configuration? {
        let env = ProcessInfo.processInfo.environment
        guard
            let urlString = env["VARIORUM_SUPABASE_URL"], !urlString.isEmpty,
            let url = URL(string: urlString),
            let apiKey = env["VARIORUM_SUPABASE_API_KEY"], !apiKey.isEmpty,
            let token = env["VARIORUM_SUPABASE_TOKEN"], !token.isEmpty
        else { return nil }
        return .init(projectURL: url, apiKey: apiKey, authToken: token)
    }

    @Test(
        .enabled(
            if: configuration != nil,
            "Set VARIORUM_SUPABASE_URL / _API_KEY / _TOKEN (see .env.supabase.local) to run the real-server pass"))
    func basicOfflineEditsConvergeOverTheRealServer() async throws {
        let transport = SupabaseTransport(configuration: try #require(Self.configuration))
        let a = try SyncClient(
            name: "A", prefix: "AA", transport: transport, mintsRandomUUIDs: true)
        let b = try SyncClient(
            name: "B", prefix: "BB", transport: transport, clockOffset: 977, seed: 2,
            mintsRandomUUIDs: true)
        let nonce = UUID().uuidString.prefix(8)

        // The Step 7 basic scenario: disjoint offline edits on two devices.
        try a.with { ops, _ in
            let post = try ops.createPost(title: "from the Mac \(nonce)", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Desk thoughts \(nonce).", at: .end)
        }
        try b.with { ops, _ in
            let entry = try ops.createPost(title: "from the phone \(nonce)", profile: .journal)
            _ = try ops.newBlock(in: entry.id, text: "Phone thoughts \(nonce).", at: .end)
        }

        // Push/pull rounds until quiescence. The fake-server helper reads the
        // server's head seq directly; against the real server quiescence is
        // observed from the outside: empty outboxes, a round in which neither
        // pull applies or merges anything, no stall, and matching cursors.
        //
        // Rounds are PACED: since A5 (03_visibility_horizon.sql) the
        // changefeed serves nothing younger than ~2 s, so back-to-back
        // rounds would see an empty (not-yet-quiesced) head and burn the
        // budget before the pushes become visible.
        var quiesced = false
        for _ in 1...12 {
            try await a.push()
            try await b.push()
            let reportA = try await a.pull()
            let reportB = try await b.pull()
            if try a.outboxCount() == 0, try b.outboxCount() == 0,
                reportA.applied == 0, reportA.merged == 0, !reportA.stalled,
                reportB.applied == 0, reportB.merged == 0, !reportB.stalled,
                reportA.newCursor == reportB.newCursor,
                // A quiet round while this run's pushes are still inside the
                // horizon is NOT quiescence — the dumps say so.
                try a.syncedDump() == b.syncedDump()
            {
                quiesced = true
                break
            }
            try await Task.sleep(for: .milliseconds(900))
        }
        #expect(quiesced, "the pair failed to quiesce against the real server within 12 rounds")

        // The phase's convergence bar: byte-identical synced tables.
        #expect(try a.syncedDump() == b.syncedDump())

        // And each device holds the other's offline edit.
        #expect(try a.db.fetchString(
            "SELECT working_text FROM variant WHERE working_text = ?",
            ["Phone thoughts \(nonce)."]) != nil)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE working_text = ?",
            ["Desk thoughts \(nonce)."]) != nil)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE title LIKE ?", ["%\(nonce)"]) == 2)
        #expect(try b.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE title LIKE ?", ["%\(nonce)"]) == 2)
    }
}
