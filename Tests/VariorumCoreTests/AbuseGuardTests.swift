import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// 13y UNIT B — THE MINIMAL ABUSE GUARD + THE RE-AUTH DOORS + THE AUTH
/// RATE LIMIT (the ruled memo §4/§5; QUESTIONS #144(b)/(c); the
/// adjudicated table shape). The fake enforces exactly what 12 enforces
/// (the DDL pins hold the SQL's letter; the deploy window proves the
/// mirror); every pin below reads as a sentence about the doors'
/// behaviour. NEW-MECHANISM pins, green by design (stated per the brief)
/// — the guard did not exist before this unit, so no red-on-old is owed;
/// the non-vacuity arms are the recover/pass halves beside each refusal.
@Suite("The minimal abuse guard + the re-auth doors (13y UNIT B)")
struct AbuseGuardTests {
    private func containerRow(id: String, base: Int = 0) -> SyncRow {
        SyncRow(
            table: "container", rowID: id,
            columns: [
                "id": .text(id), "kind": .text("post"),
                "owner_id": .text(FakeSyncServer.defaultUserID),
                "title": .null,
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "deleted_at": .null,
            ],
            syncVersion: base)
    }

    // MARK: - The quota (memo §4; the adjudication's three points)

    /// AN OVER-QUOTA PUSH REFUSES CLEANLY AND RECOVERS WHEN THE WINDOW
    /// PASSES (the memo's named pin): past the lifetime pool, the
    /// tumbling window refuses the WHOLE call typed — no overshoot (the
    /// adjudication's point 1: the refuse-whole boundary) — with a
    /// retry-after; the outbox stays intact and the cursor unmoved on an
    /// ENGINE round; and when the window passes, the same round drains
    /// clean with nothing lost. Small knobs stand in for the ruled
    /// numbers (the DDL pins hold 2,000/500,000/50,000 verbatim).
    @Test func anOverQuotaPushRefusesCleanlyAndRecoversWhenTheWindowPasses() async throws {
        let server = FakeSyncServer()
        // Pool 0: every write is steady-state; window limit 3.
        await server.setWriteQuota(lifetimePool: 0, windowLimit: 3, windowTicks: 100)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in
            _ = try ops.createPost(title: "over the line", profile: .blog)
        }
        let outboxBefore = try a.outboxCount()
        #expect(outboxBefore > 3, "the scenario needs a batch past the window limit")
        let cursorBefore = try a.cursor()

        // The REFUSE-WHOLE boundary: window_rows(0) + batch > limit — the
        // whole call refuses typed with a retry-after; NOTHING lands.
        await #expect(throws: SyncError.writeQuotaExceeded(retryAfterSeconds: 100)) {
            _ = try await a.push()
        }
        #expect(await server.rowCount(table: "container") == 0, "no overshoot — zero rows landed")
        #expect(try a.outboxCount() == outboxBefore, "the outbox is byte-intact")
        #expect(try a.cursor() == cursorBefore, "the cursor never moved")
        // The engine's own status sentence is the honest §12 wording.
        #expect(SyncError.writeQuotaExceeded(retryAfterSeconds: 100).description
                    .contains("hit today's write limit"))
        #expect(SyncError.writeQuotaExceeded(retryAfterSeconds: 100).description
                    .contains("nothing is lost"),
                "the wording promises what the refusal grammar delivers")

        // RECOVERY: the window passes (the tumbling reset — the
        // adjudication's point 2 accepts the seam), the SAME round drains.
        await server.advanceClock(by: 101)
        // The reset only arms past the pool; window limit must now admit
        // the batch — widen it to the batch size (a day passed).
        await server.setWriteQuota(lifetimePool: 0, windowLimit: Int64(outboxBefore), windowTicks: 100)
        let report = try await a.push()
        #expect(report.accepted == outboxBefore, "the held writing drains whole — nothing was lost")
        #expect(try a.outboxCount() == 0)
    }

    /// THE IMPORT BURST PASSES UNTOUCHED (her named constraint, verbatim
    /// in the plan: "I do need to account for onetime migrations…"): a
    /// first load FAR past the daily window sails through the LIFETIME
    /// POOL with no daily check at all.
    @Test func theImportBurstShapePassesUntouchedThroughTheLifetimePool() async throws {
        let server = FakeSyncServer()
        // The ruled proportions, scaled: pool 500, window 50 — the
        // "import" is 200 rows: 4× the daily limit, well under the pool.
        await server.setWriteQuota(lifetimePool: 500, windowLimit: 50, windowTicks: 100)
        let rows = (0..<200).map { containerRow(id: String(format: "import-%03d", $0)) }
        let outcomes = try await server.push(
            rows, activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        #expect(outcomes.count == 200)
        #expect(outcomes.allSatisfy { if case .accepted = $0 { return true } else { return false } },
                "an honest import is never refused — the pool's whole point")
        #expect(await server.writeBudgetFacts()?.lifetime == 200,
                "the pool metered every accepted row")
    }

    /// THE PER-CALL BATCH CAP (2,000 = the measured shipped chunk,
    /// `SyncEngine.batchSize` 200, ×10): a malformed client's oversized
    /// call refuses typed BEFORE any row lands; the SHIPPED engine can
    /// never meet it — its chunks are a tenth of the cap by construction.
    @Test func theBatchCapRefusesAMalformedClientAndTheShippedChunkNeverMeetsIt() async throws {
        let server = FakeSyncServer()
        await server.setWriteQuota(batchCap: 5)
        let oversized = (0..<6).map { containerRow(id: "cap-\($0)") }
        await #expect(throws: SyncError.writeQuotaExceeded(retryAfterSeconds: 0)) {
            _ = try await server.push(
                oversized, activeKeyID: SyncTestKeys.corpusKeyID,
                keyProof: server.mintProof(rpc: "sync_push"))
        }
        #expect(await server.rowCount(table: "container") == 0, "the cap refuses before any row")
        // The shipped relation, stated executable: the engine's chunk is
        // a tenth of the ruled cap (the DDL pin holds 2000 verbatim).
        #expect(SyncEngine(transport: server).batchSize * 10 == 2_000,
                "cap = the measured shipped chunk ×10 — either moving alone breaks this line")
    }

    /// THE TRUNCATE RESETS THE POOL (memo §4: delete-and-set-up-again's
    /// repush IS a first load — the adopt road's guarantee): a spent pool
    /// refuses; the account truncate deletes the budget row; the repush
    /// passes as a fresh first load. CAS rejects burn nothing on the way.
    @Test func theAccountTruncateResetsThePoolSoTheAdoptRoadsRepushIsAFirstLoad() async throws {
        let server = FakeSyncServer()
        await server.setWriteQuota(lifetimePool: 3, windowLimit: 1, windowTicks: 1_000)
        // Spend the pool (3 rows), crossing into steady state.
        _ = try await server.push(
            (0..<3).map { containerRow(id: "spend-\($0)") },
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        // Steady state now: the 1-row window refuses a 2-row batch.
        await #expect(throws: SyncError.self, "the spent pool hands over to the daily window") {
            _ = try await server.push(
                (0..<2).map { containerRow(id: "post-pool-\($0)") },
                activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        }
        // The re-key road: truncate (re-auth fresh by default — the doors
        // sign in immediately before acting) → the pool is FRESH.
        try await server.truncateAccount(
            FakeSyncServer.defaultUserID, activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "account_data_truncate"))
        #expect(await server.writeBudgetFacts() == nil, "the budget row went with the truncate")
        let repush = try await server.push(
            (0..<3).map { containerRow(id: "repush-\($0)") },
            activeKeyID: SyncTestKeys.corpusKeyID, keyProof: server.mintProof(rpc: "sync_push"))
        #expect(repush.allSatisfy { if case .accepted = $0 { return true } else { return false } },
                "the repush is a first load — the adopt road converges")
    }

    /// CAS REJECTS BURN NOTHING (12's letter: the increment counts the
    /// ACTUAL accepted rows, after the loop): a batch of stale-base
    /// rejects leaves the budget unmoved.
    @Test func casRejectsBurnNoQuota() async throws {
        let server = FakeSyncServer()
        _ = try await server.push(
            [containerRow(id: "c1")], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        let after = await server.writeBudgetFacts()?.lifetime
        // A stale base (0 against the stored 1) rejects; the budget holds.
        _ = try await server.push(
            [containerRow(id: "c1", base: 0)], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        #expect(await server.writeBudgetFacts()?.lifetime == after,
                "a rejected row is not an accepted row-write")
    }

    // MARK: - The re-auth doors (memo §5; QUESTIONS #144(c))

    /// THE DESTRUCTIVE RPCs DEMAND RECENT RE-AUTH: a session whose newest
    /// password-method amr entry is absent or stale refuses BOTH doors
    /// typed — a stolen long-lived token cannot empty an account's server
    /// copy — and nothing is deleted; a fresh re-auth (the doors' own
    /// flow: they verify the password immediately before acting) passes.
    /// The fake enforces the CLAIM check on synthetic claims (the
    /// 10-minute letter is the DDL pin's — an emulation choice, recorded).
    @Test func theDestructiveDoorsRefuseWithoutRecentReauthAndPassWithIt() async throws {
        let server = FakeSyncServer()
        _ = try await server.push(
            [containerRow(id: "c1")], activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_push"))
        // The stolen-token shape: valid keys, valid proofs, STALE re-auth.
        await server.setRecentPasswordAuth(false)
        await #expect(throws: SyncError.reauthRequired, "sync_purge_execute") {
            _ = try await server.executePurge(
                [SyncPurgeTarget(table: "container", rowID: "c1")],
                activeKeyID: SyncTestKeys.corpusKeyID,
                keyProof: server.mintProof(rpc: "sync_purge_execute"))
        }
        await #expect(throws: SyncError.reauthRequired, "account_data_truncate") {
            try await server.truncateAccount(
                FakeSyncServer.defaultUserID, activeKeyID: SyncTestKeys.corpusKeyID,
                keyProof: server.mintProof(rpc: "account_data_truncate"))
        }
        #expect(await server.rowCount(table: "container") == 1, "nothing deleted, nothing purged")
        #expect(await server.purgedLedgerCount() == 0)
        // The gate ORDER holds: a wrong proof still refuses AS a proof
        // fault (fence/proof outrank the re-auth check — 12's letter).
        await #expect(throws: SyncError.keyProofRefused) {
            try await server.truncateAccount(
                FakeSyncServer.defaultUserID, activeKeyID: SyncTestKeys.corpusKeyID,
                keyProof: server.mintProof(
                    rpc: "account_data_truncate",
                    material: KeyProofMaterial(master: SymmetricKey(size: .bits256))))
        }
        // The doors' own flow: a fresh sign-in immediately before acting.
        await server.setRecentPasswordAuth(true)
        _ = try await server.executePurge(
            [SyncPurgeTarget(table: "container", rowID: "c1")],
            activeKeyID: SyncTestKeys.corpusKeyID,
            keyProof: server.mintProof(rpc: "sync_purge_execute"))
        #expect(await server.rowCount(table: "container") == 0)
        // …and the honest wording.
        #expect(SyncError.reauthRequired.description.contains("fresh sign-in"))
    }

    /// THE ROUND DOORS NEVER DEMAND RE-AUTH: rounds run unattended — a
    /// stale claim refuses nothing on push/pull (the fake's twin of 12's
    /// scoping, whose DDL pin holds the letter).
    @Test func aStaleReauthClaimNeverTouchesTheRoundDoors() async throws {
        let server = FakeSyncServer()
        await server.setRecentPasswordAuth(false)
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try a.with { ops, _ in _ = try ops.createPost(title: "unattended", profile: .blog) }
        let report = try await a.push()
        #expect(report.accepted > 0, "a round needs no fresh password — it runs while she sleeps")
        _ = try await a.pull()
    }

    // MARK: - The auth rate limit (memo §5's stated numbers; Step 4b's
    // "burst of wrong passwords" pin + the honest wording)

    /// A minimal model of Supabase's token endpoint: the STATED default —
    /// 150 requests per 5 minutes per IP — after which GoTrue answers 429
    /// with the `over_request_rate_limit` code. The model exists to make
    /// the stated numbers EXECUTABLE (the docs' letter, not a discovered
    /// fact); the recorded caveats (IP-scoped; under-enforcement reports)
    /// live on `AuthRateLimit`'s doc — a speed bump, never the wall.
    private final class FakeTokenEndpoint: @unchecked Sendable {
        private let lock = NSLock()
        private var requestsByIP: [String: Int] = [:]
        let windowLimit: Int
        init(windowLimit: Int = 150) { self.windowLimit = windowLimit }

        /// One password-grant attempt from `ip` with a WRONG password:
        /// the credentials refusal until the limiter trips, then 429.
        func wrongPasswordAttempt(from ip: String) -> (status: Int, body: String) {
            lock.lock(); defer { lock.unlock() }
            requestsByIP[ip, default: 0] += 1
            if requestsByIP[ip]! > windowLimit {
                return (429, #"{"code":429,"error_code":"over_request_rate_limit","msg":"Request rate limit reached"}"#)
            }
            return (400, #"{"error":"invalid_grant","error_description":"Invalid login credentials"}"#)
        }
    }

    /// A BURST OF WRONG PASSWORDS IS REFUSED (the ADDENDUM's named pin):
    /// the first 150 answer the credentials refusal ("wrong password" —
    /// never the limiter's); the 151st crosses the stated limit and the
    /// classifier reads it as rate-limited, whose wording is the honest
    /// sentence — never "wrong password", because nothing about the
    /// credential was judged.
    @Test func aBurstOfWrongPasswordsIsRefusedAtTheStatedLimitWithTheHonestWording() {
        let endpoint = FakeTokenEndpoint()
        for attempt in 1...150 {
            let (status, body) = endpoint.wrongPasswordAttempt(from: "203.0.113.7")
            #expect(status == 400, "attempt \(attempt): still the credentials refusal")
            #expect(!AuthRateLimit.isRateLimited(status: status, body: body),
                    "a credentials refusal is never presented as the limiter's")
        }
        let (status, body) = endpoint.wrongPasswordAttempt(from: "203.0.113.7")
        #expect(status == 429, "the 151st attempt crosses the stated 150-per-window limit")
        #expect(AuthRateLimit.isRateLimited(status: status, body: body))
        #expect(AuthRateLimit.refusalWording == "Too many attempts — wait a few minutes and try again.",
                "the ONE honest sentence the app renders (the sign-in arm adopts it verbatim)")
        // The recorded caveat, executable: the limit is IP-scoped — a
        // second IP's attempt still gets the credentials refusal.
        let (otherStatus, _) = endpoint.wrongPasswordAttempt(from: "198.51.100.9")
        #expect(otherStatus == 400,
                "IP-scoped: a distributed brute-force is not capped per account — the stated caveat")
        // And the body-token arm (older proxies strip statuses; the
        // two-vocabulary precedent).
        #expect(AuthRateLimit.isRateLimited(
            status: 400, body: #"{"error_code":"over_request_rate_limit"}"#))
    }
}
