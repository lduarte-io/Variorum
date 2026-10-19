import Dependencies
import Foundation
import GRDB

/// The push/pull engine (SyncSpec §4–5). The transport is a dumb CAS +
/// changefeed; every bit of merge intelligence lives here, client-side,
/// deterministic.
///
/// The standing discipline (the Phase 1 trap, SyncSpec §4): **every write
/// the engine makes on its own behalf runs in apply mode** — a bare
/// bookkeeping write re-enqueues the row it just pushed and the engine
/// pushes forever. The deliberate exceptions are repair writes and rescue/
/// conflict variants, which run inside the apply transaction where the
/// triggers are muted and therefore enqueue their outbox rows **explicitly**
/// (SyncSpec §7) — without that, repairs apply locally but never push and
/// the devices silently diverge.

/// VX-314's injected facts (the `keyProvider` pattern): who the library
/// belongs to, and who is signed in — both app-side truths this module
/// cannot see. Each closure answers nil freely (unbound, signed out, or
/// simply unknown); only a double answer that DISAGREES refuses a round.
public struct SyncAccountBinding: Sendable {
    /// The library's bound account (the protection record's; today's road
    /// never wires this — Release behavior byte-unchanged until VX-329).
    public var boundAccount: @Sendable () async -> String?
    /// The signed-in account (the auth session's user).
    public var signedInAccount: @Sendable () async -> String?

    public init(
        boundAccount: @escaping @Sendable () async -> String?,
        signedInAccount: @escaping @Sendable () async -> String?
    ) {
        self.boundAccount = boundAccount
        self.signedInAccount = signedInAccount
    }
}

public struct SyncEngine: Sendable {
    @Dependency(\.database) var database
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public let transport: any SyncTransport
    /// The E2EE key seam (Phase 14b): each round half asks the provider
    /// once and seals/opens every payload with the answer. The default is
    /// the UNENROLLED provider — post-14b there is no plaintext mode, so an
    /// engine nobody wired keys into refuses every round visibly (the
    /// designed pre-enrollment state; batch 3's enrollment flow installs
    /// the Keychain-backed provider).
    public let keyProvider: any SyncKeyProviding
    /// Rows per push batch / pull window (transport granularity; the pull
    /// APPLY transaction always covers everything fetched, so window size
    /// never affects convergence — the soak randomizes it to prove that).
    public var batchSize: Int
    /// One `push()` call re-pushes rejected-and-merged rows at most this
    /// many times; anything still dirty stays in the outbox for the next
    /// call. Bounded by design — retry/backoff hardening is Phase 12.
    public var maxPushIterations: Int
    /// The sample-library dedupe's injected facts (pre-13u Act 0,
    /// R-pre13u-8) — the `keyProvider` pattern: the identity predicate and
    /// per-note manifest live in app-target code this module cannot see,
    /// so the app layer hands them in at wiring (`SyncSession.configure`,
    /// shared by both platforms). EMPTY — the default — leaves that repair
    /// INERT: an engine nobody wired facts into cannot misidentify a book.
    /// pre-13x 5a (the batch's one `Sync/` touch, ruled): a LIST — one entry
    /// per seeded book (Sherlock, *Encryption Explained*); the pass runs per
    /// entry exactly as it ran for one — no rule or ordering change.
    public let sampleLibraryFacts: [SampleLibraryDedupeFacts]
    /// 17y B-DEDUPE (R-17y-5): the seeded-furniture pairwise fold's facts —
    /// the guide, the three gatherings, the quicknote/twin, the scraps pool
    /// (`SeededFurnitureDedupe.swift`). Nil = INERT, the standing pattern.
    public let furnitureFacts: SeededFurnitureDedupeFacts?
    /// VX-314 (the `keyProvider` pattern — nil = INERT): the account-binding
    /// facts the engine cannot see for itself. New writing belongs to the
    /// LIBRARY's account (the protection record's — "the record names the
    /// account; signing in or out never changes it"), not whoever is signed
    /// in, so a round under a mismatched sign-in refuses before any network
    /// contact. The gate refuses ONLY when both facts answer and disagree
    /// (an unbound library or a signed-out session is some other state's
    /// business, never this gate's).
    public let accountBinding: SyncAccountBinding?

    public init(
        transport: any SyncTransport, batchSize: Int = 200, maxPushIterations: Int = 5,
        keyProvider: any SyncKeyProviding = UnenrolledKeyProvider(),
        sampleLibraryFacts: [SampleLibraryDedupeFacts] = [],
        furnitureFacts: SeededFurnitureDedupeFacts? = nil,
        accountBinding: SyncAccountBinding? = nil
    ) {
        self.transport = transport
        self.batchSize = batchSize
        self.maxPushIterations = maxPushIterations
        self.keyProvider = keyProvider
        self.sampleLibraryFacts = sampleLibraryFacts
        self.furnitureFacts = furnitureFacts
        self.accountBinding = accountBinding
    }

    /// VX-314's gate, in the round-entry refusal cascade (after the re-key
    /// check, before keys): the signed-in account against the library's
    /// bound account. A mismatch refuses `SyncError.accountMismatch` —
    /// outbox intact, cursor unmoved, before any network contact.
    private func refuseIfAccountMismatched() async throws {
        guard let binding = accountBinding else { return }
        guard let bound = await binding.boundAccount(),
              let signedIn = await binding.signedInAccount(),
              bound != signedIn
        else { return }
        throw SyncError.accountMismatch(bound: bound, signedIn: signedIn)
    }

    /// Ladder R1-1, re-based on pre-13x 2b's PER-STEP marker: the posture
    /// switch / Replace All Keys runner writes `RotationMarker` before its
    /// vault write and advances it step by step, clearing it only when the
    /// whole road completes — a crash anywhere between leaves it set across
    /// relaunches. While ANY step is set, both round halves refuse with a
    /// self-explaining error naming the resume road — outbox intact, cursor
    /// unmoved, the §12 refusal grammar. (`pullToHead` and
    /// `resyncReinitialize` are the runner's own tools and are deliberately
    /// NOT guarded: the runner calls them with the marker set.)
    private func refuseIfRekeyIncomplete() async throws {
        let incomplete = try await database.read { try RotationMarker.isSet($0) }
        guard !incomplete else { throw SyncError.accountRekeyIncomplete }
    }

    // MARK: - pre-13x 2b: the two named primitives (the BATCH 2 brief's fact iv)

    /// PULL TO HEAD — §4 step 1's named primitive: pull until the changefeed
    /// is read to head, retrying a STALLED pull (a straggler whose referents
    /// another device still owes) a bounded number of times; a pull that
    /// never un-stalls refuses typed (`pullStalled`) with the cursor where it
    /// holds. Deliberately NOT gated by the rotation marker (`pull()` is;
    /// this bypasses that one guard and nothing else): the runner calls it
    /// with the marker set to finish a rotation.
    @discardableResult
    public func pullToHead(maxAttempts: Int = 6) async throws -> PullReport {
        var last = PullReport()
        for _ in 0..<max(1, maxAttempts) {
            last = try await pullIgnoringMarker()
            if !last.stalled { return last }
        }
        throw SyncError.pullStalled(cursor: last.newCursor)
    }

    /// The outbox's size — the "this device's writing has reached the
    /// server" fact a rotation gates on (hoisted from the scheduler, which
    /// reads it through this now).
    public func outboxCount() async throws -> Int {
        try await database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
        }
    }

    /// The round's crypto seam, or the visible refusal (Phase 14b): ANY
    /// provider throw maps to `SyncError.encryptionKeysUnavailable` — a
    /// self-explaining status naming the fix, pinned exactly like the §12
    /// lockstep-skew refusal. Called BEFORE any network contact, so a
    /// locked device refuses for free.
    private func roundCrypto() throws -> SyncPayloadCrypto {
        do {
            return SyncPayloadCrypto(keys: try keyProvider.currentKeys())
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
    }

    // MARK: - Push (SyncSpec §4)

    public struct PushReport: Equatable, Sendable {
        public var accepted = 0
        /// Rejects merged locally this call (each re-pushes next iteration
        /// or next call).
        public var rejected = 0
        /// Rejects whose merged row references rows this store has not seen
        /// yet (a straggler, SyncSpec §5) — left enqueued untouched; a pull
        /// brings the referent, then the next push retries.
        public var deferred = 0
        /// Phase 13j: rows the server refused as PURGED (the ledger fence)
        /// — outbox entry dropped, local family removed. Never retried.
        public var purged = 0
        public var iterations = 0
        public init() {}
    }

    /// Drains the outbox: snapshot dirty rows → load current payloads (a
    /// tombstone is a push like any other) → CAS batch → accepted rows get
    /// their server-granted `sync_version` recorded in apply mode and leave
    /// the outbox **only if not re-dirtied since the snapshot**; rejected
    /// rows merge per SyncSpec §6 and re-push on the next iteration.
    @discardableResult
    public func push() async throws -> PushReport {
        // An unfinished re-key on THIS device refuses first (ladder
        // R1-1): rounds against a mid-re-key account can silently strand
        // the hosted copy — see `AccountRekeyMarker`. Before keys and
        // lockstep because its prescription (re-run the re-key door)
        // subsumes both; before any network contact by construction.
        try await refuseIfRekeyIncomplete()
        // The library's account, not whoever is signed in (VX-314): a
        // mismatched sign-in refuses before keys say anything — the bound
        // account's keys may well be in custody, and "keys unavailable"
        // would name the wrong fix.
        try await refuseIfAccountMismatched()
        // Keys first (Phase 14b): absent/locked keys refuse the round
        // before any network contact — outbox intact, cursor unmoved.
        let crypto = try roundCrypto()
        try await verifySchemaLockstep()
        // 13y UNIT B: one challenge signer per round half — a nonce batch
        // fetched once, one nonce consumed per RPC call.
        let signer = SyncChallengeSigner(
            transport: transport, material: crypto.keys.keyProof,
            activeKeyID: crypto.keys.corpusKeyID)
        var report = PushReport()
        for _ in 0..<maxPushIterations {
            let batch: [SyncRow] = try await database.read { db in
                let entries = try Row.fetchAll(
                    db, sql: "SELECT table_name, row_id FROM sync_outbox")
                return try entries
                    .compactMap { entry -> SyncRow? in
                        guard let table = SyncSchema.table(named: entry["table_name"]) else { return nil }
                        return try SyncRow.fetch(db, table: table, rowID: entry["row_id"])
                    }
                    .sorted(by: Self.precedesInDrain)
            }
            guard !batch.isEmpty else { break }
            report.iterations += 1

            var madeProgress = false
            for chunk in stride(from: 0, to: batch.count, by: batchSize).map({
                Array(batch[$0..<min($0 + batchSize, batch.count)])
            }) {
                // THE SEAM, push half (Phase 14b): the wire carries sealed
                // payloads; `chunk` itself stays PLAINTEXT — it is what the
                // accept bookkeeping compares against the live row
                // (clear-vs-re-dirty) and what the reject path merges from.
                // Phase 14c: the round's held key id rides every call — the
                // server's vault-key-id fence compares it (THE DESIGN 2).
                let wireChunk = try chunk.map(crypto.encryptForWire)
                // pre-13x: the key proof rides beside the key id — the
                // authorization (decision 12); the id stays the honesty
                // check. 13y UNIT B: PER-REQUEST — the round's signer
                // turns the material into one single-use bound proof per
                // call (the stale-retry-once and enroll roads live there).
                let keyID = crypto.keys.corpusKeyID
                let rawOutcomes = try await signer.call(rpc: "sync_push") { proof in
                    try await self.transport.push(
                        wireChunk, activeKeyID: keyID, keyProof: proof)
                }
                // THE SEAM, reject-merge half: a reject's `current` row is
                // opened HERE, before the FK check and the merge — inland
                // logic sees plaintext only.
                let outcomes = try rawOutcomes.map { outcome -> SyncPushOutcome in
                    guard case .rejected(let current) = outcome, let current else {
                        return outcome
                    }
                    return .rejected(current: try crypto.decryptFromWire(current))
                }
                let processed: ChunkResult = try await applyingRemoteWithDeferredFKs { db in
                    var result = ChunkResult()
                    var touched = TouchedRows()
                    for (pushed, outcome) in zip(chunk, outcomes) {
                        switch outcome {
                        case .purged:
                            // Phase 13j (the memo's §2 ledger): the server
                            // says this id was PURGED. Drop the outbox
                            // entry — and the local copy, family-complete,
                            // or the two stores would never converge (the
                            // row would linger here as a live orphan no
                            // feed can ever correct, since its mirror rows
                            // no longer exist). Runs inside the apply
                            // transaction with the triggers muted, so the
                            // family removal's survivor detachment and
                            // intent completion enqueue EXPLICITLY (the
                            // SyncSpec §7 repair-write discipline).
                            let family = try PurgeFamily.expand(
                                db,
                                roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)])
                            try PurgeFamily.deleteLocal(
                                db, family: family, stamp: nowStamp(),
                                enqueue: { try self.enqueueExplicitly(db, table: $0, rowID: $1) })
                            try clearOutboxEntry(db, table: pushed.table, rowID: pushed.rowID)
                            result.purged += 1
                        case .accepted(let newVersion, let serverSeq):
                            try recordAccepted(
                                db, pushed: pushed, newVersion: newVersion, serverSeq: serverSeq)
                            result.accepted += 1
                        case .rejected(let current):
                            guard let current else {
                                // The server has no row for a non-zero base
                                // (mirror reset): rebase to 0; the next
                                // iteration re-pushes it as an insert.
                                try setLocalSyncVersion(db, table: pushed.table, rowID: pushed.rowID, to: 0)
                                result.rejected += 1
                                continue
                            }
                            // Merge against the CURRENT local row, never the
                            // pre-transport snapshot: an edit landing during
                            // the network await must be rescued, not
                            // clobbered-and-unenqueued (Phase 5 review
                            // BLOCKER — the reject-path twin of
                            // recordAccepted's content comparison).
                            guard let table = SyncSchema.table(named: pushed.table),
                                  let local = try SyncRow.fetch(db, table: table, rowID: pushed.rowID)
                            else {
                                // An outbox entry with no row cannot arise in
                                // production (rows are never physically
                                // deleted); leave it for the next drain.
                                result.deferred += 1
                                continue
                            }
                            // RUN B B5 (ledger row 17, finding F-3 — the
                            // ruled Shape A, shape-scoped): a reject whose
                            // current row is TOMBSTONED while the local row
                            // is LIVE at base 0 means "my never-acked row
                            // was killed before I learned" — reachable only
                            // through the half-landed-drain class (rows
                            // travel nowhere but by push). Landing that
                            // tombstone HERE delivers a death outside §9's
                            // ordering authority, ahead of any context: the
                            // local cascade killed the stranded children
                            // (tag applications, Journal memberships) that
                            // §7 promises to the keeper, and no repair leg
                            // could fire on either device. DEFER instead —
                            // the standing straggler idiom below: the reject
                            // itself proves the current state sits on the
                            // feed beyond our cursor, so the next post-band
                            // pull delivers the death IN seq order, keeper
                            // first (the drain order guarantees it), where
                            // the shipped legs adjudicate with full context.
                            // Every other reject shape is byte-unchanged
                            // (restore-vs-redelete and F-1's ride carry
                            // base ≥ 1; a lost-ack echo's current is live;
                            // a mirror reset's is nil; metadata CAS is
                            // live-vs-live).
                            if current.row.isTombstoned, !local.isTombstoned,
                               local.syncVersion == 0 {
                                result.deferred += 1
                                continue
                            }
                            if try foreignKeysSatisfiable(db, row: current.row, arriving: [:]) {
                                try merge(
                                    db, local: local, server: current.row,
                                    serverSeq: current.serverSeq, touched: &touched)
                                result.rejected += 1
                            } else {
                                // Merged row would reference rows this store
                                // has never seen (straggler): leave the row
                                // enqueued and untouched; pull first.
                                result.deferred += 1
                            }
                        }
                    }
                    // One repair pass per chunk transaction — batch-scoped
                    // like the pull path.
                    try runPostApplyRepairs(db, touched: touched)
                    return result
                }
                report.accepted += processed.accepted
                report.rejected += processed.rejected
                report.deferred += processed.deferred
                report.purged += processed.purged
                madeProgress = madeProgress || processed.accepted > 0 || processed.rejected > 0
                    || processed.purged > 0
            }
            guard madeProgress else { break }
        }
        return report
    }

    private struct ChunkResult: Sendable {
        var accepted = 0
        var rejected = 0
        var deferred = 0
        var purged = 0
    }

    /// **THE DRAIN ORDER** — the one comparator the push sorts the outbox
    /// by: registry (apply) order across tables, then ASCENDING `rowID`
    /// within a table. Named rather than inlined (the ladder's R2-7)
    /// because a repair silently depends on the second half: the Journal
    /// keeper's fresh-store leg (`Repairs.swift`, direction 1) holds only
    /// because the keeper's `reading` INSERT precedes the loser's `reading`
    /// TOMBSTONE in `server_seq` whenever both ride one push — and they do
    /// precisely because the keeper is, by the repair's own definition, the
    /// SMALLER id. Reverse the within-table order and a third device meets
    /// the loser's tombstone with no keeper in sight: an ordinary dead
    /// insert, its memberships dangling live under a dead book until the
    /// repairer's re-points happen to arrive. Pinned as the architectural
    /// class it is (`TheDrainOrderTests`): green on both sides by nature,
    /// red the day someone changes the comparator.
    static func precedesInDrain(_ lhs: SyncRow, _ rhs: SyncRow) -> Bool {
        let (a, b) = (SyncSchema.applyOrderIndex(of: lhs.table),
                      SyncSchema.applyOrderIndex(of: rhs.table))
        return a == b ? (lhs.rowID < rhs.rowID) : (a < b)
    }

    // MARK: - Pull (SyncSpec §5)

    public struct PullReport: Equatable, Sendable {
        /// Locally-clean rows written verbatim (echoes of our own pushes
        /// included).
        public var applied = 0
        /// Locally-dirty rows merged per §6.
        public var merged = 0
        /// Repair writes (SyncSpec §7) made inside the apply transaction.
        public var repairs = 0
        public var newCursor: Int64 = 0
        /// True when the batch stopped early at a row whose referents have
        /// not reached the server yet (the other device's outbox still owes
        /// them); the cursor holds just before that row and the next pull
        /// retries. Self-heals when the owing device drains.
        public var stalled = false
        /// RUN B B2 row 9 (17d P8): the stall's IDENTITY — which arriving
        /// row truncated the batch, whether it is a tombstone, and which
        /// referents could not be satisfied. Client-side detail only (no
        /// wire change); the scheduler hands it to the janitor's
        /// ledger-verified orphan heal, which is the ONLY consumer that
        /// may act on it.
        public var stall: PullStall?
        public init() {}
    }

    /// The stalled row's identity (row 9 — 17d P8). `tombstoneStamp` is
    /// the arriving row's `deleted_at` when it carries one: the heal's
    /// ruled narrowing (a LIVE stalled row is never healed) and the
    /// cascade-residue discriminator both read it.
    public struct PullStall: Equatable, Sendable {
        public struct MissingReferent: Equatable, Sendable {
            public var table: String
            public var rowID: String
            public init(table: String, rowID: String) {
                self.table = table
                self.rowID = rowID
            }
        }

        public var table: String
        public var rowID: String
        public var tombstoneStamp: String?
        public var missingReferents: [MissingReferent]
        /// LADDER R1 F-R4: the stalled row's FK targets that DID resolve —
        /// locally, or via the batch's applied prefix (which committed with
        /// it). The heal's completion set scopes its same-stamp cascade
        /// residue THROUGH these, never by a store-wide stamp sweep: a
        /// millisecond stamp collision must not hand an unrelated family
        /// to `executePurge` (a pre-horizon mirror purge — the §4f class).
        /// The element type is the same (table, row) pair; the field name
        /// carries the meaning.
        public var presentReferents: [MissingReferent]
        public init(
            table: String, rowID: String, tombstoneStamp: String?,
            missingReferents: [MissingReferent],
            presentReferents: [MissingReferent] = []
        ) {
            self.table = table
            self.rowID = rowID
            self.tombstoneStamp = tombstoneStamp
            self.missingReferents = missingReferents
            self.presentReferents = presentReferents
        }
    }

    /// Fetches the changefeed to head, then applies **everything in one
    /// `applyingRemote` transaction** with `PRAGMA defer_foreign_keys = ON`
    /// set inside it (multi-row operations arrive as row sets; deferred FKs
    /// make the batch atomic-consistent at commit). Locally-clean rows are
    /// written verbatim with their server `sync_version`; locally-dirty rows
    /// merge per §6 and stay enqueued as long as local intent survives.
    /// Repairs run inside the same transaction, after rows land. The cursor
    /// advances inside the transaction — a rollback rewinds it with
    /// everything else.
    @discardableResult
    public func pull() async throws -> PullReport {
        // The unfinished-re-key guard, the push half's twin (ladder R1-1).
        try await refuseIfRekeyIncomplete()
        return try await pullIgnoringMarker()
    }

    /// The pull's body — everything but the marker guard (pre-13x 2b:
    /// `pullToHead` runs it with the marker set).
    private func pullIgnoringMarker() async throws -> PullReport {
        // VX-314: the push half's twin — here rather than `pull()` so
        // `pullToHead` is gated too (the binding is nil on every
        // deliberate-act engine, so only the live session's rounds feel it).
        try await refuseIfAccountMismatched()
        // Keys first (Phase 14b): absent/locked keys refuse the round
        // before any network contact — outbox intact, cursor unmoved.
        let crypto = try roundCrypto()
        // pre-13x 1a: the device identity rides the sync-key custody item,
        // read through the same provider (never the store file — a copy of
        // the library is writing, not a device). No custody ⇒ no identity ⇒
        // the same visible refusal as absent keys.
        let deviceID = try roundDeviceIdentity()
        try await verifySchemaLockstep()
        // 13y UNIT B: the pull half's own signer (one per round half).
        let signer = SyncChallengeSigner(
            transport: transport, material: crypto.keys.keyProof,
            activeKeyID: crypto.keys.corpusKeyID)
        let since = try await database.read { try cursor($0) }
        var pulled: [SyncPulledRow] = []
        var fetchCursor = since
        while true {
            // Phase 14c: the held key id rides the pull half too — both
            // round halves are fenced (THE DESIGN 2).
            //
            // Phase 13j: the device id rides the FIRST window only, where
            // `since` is this device's COMMITTED cursor — the server's
            // device_cursor upsert is what makes the purge horizon
            // computable. Mid-round windows pass nil: their `since` values
            // are uncommitted fetch positions, and recording one would
            // over-report what this device has integrated if the apply
            // below never commits.
            let keyID = crypto.keys.corpusKeyID
            let windowSince = fetchCursor
            let windowDevice = fetchCursor == since ? deviceID : nil
            let window = try await signer.call(rpc: "sync_pull") { proof in
                try await self.transport.pull(
                    since: windowSince, limit: self.batchSize, activeKeyID: keyID,
                    keyProof: proof, deviceID: windowDevice)
            }
            guard !window.isEmpty else { break }
            // THE SEAM, pull half (Phase 14b): every arriving row is opened
            // BEFORE the apply transaction exists — a decrypt refusal
            // (plaintext-in-encrypted-column, tamper, wrong key) throws
            // here, with the cursor unmoved and nothing written. Everything
            // downstream (straggler guard, merge, repairs, apply) is
            // plaintext-only and byte-untouched.
            pulled.append(contentsOf: try window.map(crypto.decryptFromWire))
            fetchCursor = window.last!.serverSeq
        }
        var emptyReport = PullReport()
        emptyReport.newCursor = since
        guard !pulled.isEmpty else {
            // The ladder's F2: a sample-library dedupe pass deferred at the
            // previous batch (a copy's book had just arrived) re-runs at an
            // empty window too — the head-reached moment is exactly when
            // "quiescent since a prior batch" becomes true with nothing
            // else arriving. One local-only marker read per empty pull;
            // the apply transaction opens only when the marker is set.
            // (`isPullBatch`: this IS a pull — the dedupe's only road.)
            // 17y B-DEDUPE: the seeded-furniture fold's own deferral marker
            // rides the same head-reached moment.
            if try await database.read({ db in
                try self.sampleDedupePending(db)
                    || Bool.fetchOne(
                        db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)",
                        arguments: [Self.furnitureDedupePendingKey]) ?? false
            }) {
                emptyReport.repairs = try await applyingRemoteWithDeferredFKs { db in
                    try runPostApplyRepairs(db, touched: TouchedRows(isPullBatch: true))
                }
            }
            return emptyReport
        }

        let batch = pulled
        return try await applyingRemoteWithDeferredFKs { db in
            var report = PullReport()
            // Straggler guard, to a FIXPOINT: rows apply in seq order up to
            // the first row whose FK closure is satisfiable neither locally
            // nor by a row in the APPLIED PREFIX. Satisfiability against the
            // full fetched set would let a prefix row lean on a referent
            // that itself stalls past the stop point — turning the designed
            // graceful stall into a deferred-FK commit failure and a
            // whole-batch rollback on every retry (Phase 5 review MAJOR).
            // The index strictly decreases, so the loop terminates.
            var stopIndex = batch.count
            while true {
                let prefixArriving = arrivingRowIDs(Array(batch[..<stopIndex]))
                var shrunk = stopIndex
                for (index, item) in batch[..<stopIndex].enumerated() {
                    guard try foreignKeysSatisfiable(db, row: item.row, arriving: prefixArriving) else {
                        shrunk = index
                        break
                    }
                }
                if shrunk == stopIndex { break }
                stopIndex = shrunk
            }

            // A pull's apply: the sample-library dedupe's one firing road
            // (the ladder's R2-1 — the push path's per-chunk pass never
            // runs it; see `TouchedRows.isPullBatch`).
            var touched = TouchedRows(isPullBatch: true)
            for item in batch[..<stopIndex] where item.row.isTombstoned {
                touched.arrivingDeadIDs[item.row.table, default: []].insert(item.row.rowID)
            }
            for item in batch[..<stopIndex] {
                if try isEnqueued(db, table: item.row.table, rowID: item.row.rowID),
                   let table = SyncSchema.table(named: item.row.table),
                   let local = try SyncRow.fetch(db, table: table, rowID: item.row.rowID) {
                    // Echo/stale guard (Phase 5 review BLOCKER): the
                    // changefeed replays this device's own accepted rows. A
                    // dirty local row with `local.syncVersion >=` the
                    // incoming version holds a PENDING CAS WIN — the next
                    // push lands it cleanly on top of that very version.
                    // Merging here would revert the buffer under the
                    // author's cursor and demote her newer text to a
                    // spurious 'conflict' card. Same version ⇒ same
                    // server state we already integrated; nothing to merge.
                    guard item.row.syncVersion > local.syncVersion else {
                        try recordSeq(db, table: item.row.table, rowID: item.row.rowID, seq: item.serverSeq)
                        continue  // stays enqueued; push ships the local intent
                    }
                    try merge(db, local: local, server: item.row,
                              serverSeq: item.serverSeq, touched: &touched)
                    report.merged += 1
                } else {
                    // Locally clean (or an outbox entry with no local row,
                    // impossible in production): write verbatim.
                    try writeResolvedRow(db, item.row, serverSeq: item.serverSeq, touched: &touched)
                    try recordSeq(db, table: item.row.table, rowID: item.row.rowID, seq: item.serverSeq)
                    report.applied += 1
                }
            }
            report.repairs = try runPostApplyRepairs(db, touched: touched) + touched.inlineRepairs
            let newCursor = stopIndex > 0 ? batch[stopIndex - 1].serverSeq : since
            try setCursor(db, newCursor)
            report.newCursor = newCursor
            report.stalled = stopIndex < batch.count
            if stopIndex < batch.count {
                // Row 9 (17d P8): name the stall — the first unsatisfiable
                // row and exactly which referents are missing (neither
                // local nor in the applied prefix). Read-only detail; the
                // janitor's ledger-verified heal is its one consumer.
                let stalledRow = batch[stopIndex].row
                let prefixArriving = arrivingRowIDs(Array(batch[..<stopIndex]))
                var missing: [PullStall.MissingReferent] = []
                var present: [PullStall.MissingReferent] = []
                for fk in try foreignKeyColumns(db, table: stalledRow.table) {
                    guard case .text(let target) = stalledRow.columns[fk.column] else { continue }
                    // A prefix-satisfied referent commits WITH this batch —
                    // it is local by the time any consumer reads the stall
                    // (F-R4: the heal's residue scoping needs it named).
                    if prefixArriving[fk.targetTable]?.contains(target) == true {
                        present.append(.init(table: fk.targetTable, rowID: target))
                        continue
                    }
                    let exists = try Bool.fetchOne(
                        db,
                        sql: "SELECT EXISTS (SELECT 1 FROM \(fk.targetTable) WHERE \(fk.targetPrimaryKey) = ?)",
                        arguments: [target]) ?? false
                    if exists {
                        present.append(.init(table: fk.targetTable, rowID: target))
                    } else {
                        missing.append(.init(table: fk.targetTable, rowID: target))
                    }
                }
                var stamp: String?
                if case .text(let value) = stalledRow.columns["deleted_at"] { stamp = value }
                report.stall = PullStall(
                    table: stalledRow.table, rowID: stalledRow.rowID,
                    tombstoneStamp: stamp, missingReferents: missing,
                    presentReferents: present)
            }
            return report
        }
    }

    // MARK: - Wipe-and-repush re-initialization (Phase 14b, ruling R-2)

    /// The CLIENT half of wipe-and-repush — core semantics only (batch 3
    /// productizes the door behind an explicit, announced act; this is the
    /// harness-proven function the gate runs after the mirror's data-table
    /// truncate). No in-place migration machinery exists: local SQLite is
    /// truth, the mirror is a peer, so the mirror re-initializes by
    /// truncate + a full re-push through the (now encrypting) serializer.
    ///
    /// One plain write transaction — deliberately NOT apply mode: the
    /// `sync_version = 0` sweeps fire the outbox triggers, which is the
    /// goal, and the explicit outbox INSERTs guarantee totality regardless
    /// (tombstoned rows, `commit_point`, `setting` — EVERY row of EVERY
    /// synced table re-pushes; tombstones must reach the fresh mirror or a
    /// later device would resurrect the dead).
    ///
    ///  - every synced row's `sync_version` → 0 (the CAS base for a fresh
    ///    insert against an empty mirror);
    ///  - `sync_row_seq` cleared (no row has a server seq anymore — repair
    ///    ranking starts over, SyncSpec §3);
    ///  - the pull cursor cleared (the next pull reads from 0; the global
    ///    `server_seq` itself is NEVER reset — SyncSpec §9);
    ///  - EVERY row enqueued into the outbox.
    ///
    /// Nothing key-shaped and nothing identity-shaped lives in the file
    /// (pre-13x 1a): the device identity rides the sync-key custody item,
    /// so re-initialization has nothing of it to spare or to reset.
    public func resyncReinitialize() async throws {
        try await database.write { db in
            for table in SyncSchema.tables {
                try db.execute(sql: "UPDATE \(table.name) SET sync_version = 0")
                try db.execute(sql: """
                    INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                    SELECT '\(table.name)', \(table.primaryKey),
                           strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
                    FROM \(table.name)
                    """)
            }
            try db.execute(sql: "DELETE FROM sync_row_seq")
            try db.execute(sql: "DELETE FROM sync_state WHERE key = 'last_server_seq'")
        }
    }

    // MARK: - The §12 version check (Phase 11, Step A1)

    /// SyncSpec §12's version-check mechanism, shipped with the first
    /// post-sync migration that needs it (the Phase 11 lockstep event):
    /// every round half opens by comparing the mirror's deployed schema
    /// marker against this client's `SyncSchema.lockstepVersion`. ANY
    /// mismatch — behind OR ahead — refuses the round with a visible,
    /// self-explaining error; the outbox keeps everything and the cursor
    /// never moves. Stalling is free (offline is free); a client that
    /// guessed would push columns `jsonb_populate_record` silently drops,
    /// or pull tables it has no home for.
    public func verifySchemaLockstep() async throws {
        let server = try await transport.schemaVersion()
        guard server == SyncSchema.lockstepVersion else {
            throw SyncError.schemaLockstepMismatch(
                client: SyncSchema.lockstepVersion, server: server)
        }
    }

    // MARK: - Accept bookkeeping

    /// The Phase 1 trap made concrete: this runs inside apply mode. The
    /// outbox entry is cleared **only if the row still matches what was
    /// pushed** — a row re-dirtied mid-push keeps its entry and re-pushes
    /// (clearing it would lose the newer edit forever; the plan's named
    /// clear-vs-re-dirty race).
    private func recordAccepted(
        _ db: Database, pushed: SyncRow, newVersion: Int, serverSeq: Int64
    ) throws {
        try setLocalSyncVersion(db, table: pushed.table, rowID: pushed.rowID, to: newVersion)
        try recordSeq(db, table: pushed.table, rowID: pushed.rowID, seq: serverSeq)
        guard let table = SyncSchema.table(named: pushed.table),
              let current = try SyncRow.fetch(db, table: table, rowID: pushed.rowID),
              current.columns == pushed.columns
        else { return }
        try clearOutboxEntry(db, table: pushed.table, rowID: pushed.rowID)
    }

    private func setLocalSyncVersion(
        _ db: Database, table: String, rowID: String, to version: Int
    ) throws {
        guard let table = SyncSchema.table(named: table) else { return }
        try db.execute(
            sql: "UPDATE \(table.name) SET sync_version = ? WHERE \(table.primaryKey) = ?",
            arguments: [version, rowID])
    }

    // MARK: - Apply-transaction plumbing

    /// One apply-mode transaction with deferred FK enforcement — the pragma
    /// must be executed INSIDE the transaction (it resets at commit;
    /// SyncSpec §5, Phase 5 plan risk list).
    func applyingRemoteWithDeferredFKs<T>(_ body: (Database) throws -> T) throws -> T {
        try database.applyingRemote { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            return try body(db)
        }
    }

    /// The async twin the engine's own paths use, so an apply transaction
    /// never blocks a cooperative-pool thread (Phase 5 review).
    func applyingRemoteWithDeferredFKs<T: Sendable>(
        _ body: @escaping @Sendable (Database) throws -> T
    ) async throws -> T {
        try await database.applyingRemote { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            return try body(db)
        }
    }

    /// All row IDs arriving in this batch, by table — a forward-referenced
    /// parent inside the batch satisfies a child under deferred FKs.
    private func arrivingRowIDs(_ pulled: [SyncPulledRow]) -> [String: Set<String>] {
        var arriving: [String: Set<String>] = [:]
        for item in pulled {
            arriving[item.row.table, default: []].insert(item.row.rowID)
        }
        return arriving
    }

    /// True when every non-NULL FK value in the row resolves to a row that
    /// exists locally (live or tombstoned) or arrives in this batch. FK
    /// columns are introspected from the live schema, never hardcoded.
    func foreignKeysSatisfiable(
        _ db: Database, row: SyncRow, arriving: [String: Set<String>]
    ) throws -> Bool {
        for fk in try foreignKeyColumns(db, table: row.table) {
            guard case .text(let target) = row.columns[fk.column] else { continue }
            if arriving[fk.targetTable]?.contains(target) == true { continue }
            let exists = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM \(fk.targetTable) WHERE \(fk.targetPrimaryKey) = ?)",
                arguments: [target]) ?? false
            guard exists else { return false }
        }
        return true
    }

    private func foreignKeyColumns(
        _ db: Database, table: String
    ) throws -> [(column: String, targetTable: String, targetPrimaryKey: String)] {
        try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(\(table))").compactMap { fk in
            let targetTable: String = fk["table"]
            guard let target = SyncSchema.table(named: targetTable) else { return nil }
            return (fk["from"], targetTable, target.primaryKey)
        }
    }

    // MARK: - Local sync-state helpers

    func cursor(_ db: Database) throws -> Int64 {
        let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        return value.flatMap(Int64.init) ?? 0
    }

    func setCursor(_ db: Database, _ seq: Int64) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES ('last_server_seq', ?)",
            arguments: [String(seq)])
    }

    /// pre-13x 1a: the round's device identity, from the provider (the
    /// custody item), mapped to the keys refusal exactly as `roundCrypto`
    /// maps absent keys — a locked or copied library has neither.
    func roundDeviceIdentity() throws -> String {
        do {
            return try keyProvider.deviceIdentity()
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
    }

    /// Per-row server_seq bookkeeping (v1_3): what makes "higher server_seq
    /// wins" decidable client-side. Rows the server never accepted rank 0.
    func recordSeq(_ db: Database, table: String, rowID: String, seq: Int64) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_row_seq (table_name, row_id, server_seq) VALUES (?, ?, ?)",
            arguments: [table, rowID, seq])
    }

    func knownSeq(_ db: Database, table: String, rowID: String) throws -> Int64 {
        try Int64.fetchOne(
            db,
            sql: "SELECT server_seq FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
            arguments: [table, rowID]) ?? 0
    }

    func isEnqueued(_ db: Database, table: String, rowID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM sync_outbox WHERE table_name = ? AND row_id = ?)",
            arguments: [table, rowID]) ?? false
    }

    /// The explicit enqueue for writes made while the triggers are muted —
    /// repairs and rescue variants MUST reach the outbox or the devices
    /// silently diverge (SyncSpec §7; every repair test asserts this row).
    func enqueueExplicitly(_ db: Database, table: String, rowID: String) throws {
        try db.execute(
            sql: """
                INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                VALUES (?, ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
                """,
            arguments: [table, rowID])
    }

    func clearOutboxEntry(_ db: Database, table: String, rowID: String) throws {
        try db.execute(
            sql: "DELETE FROM sync_outbox WHERE table_name = ? AND row_id = ?",
            arguments: [table, rowID])
    }

    // MARK: - Shared timestamp

    /// Repair tombstones and rescue variants stamp with the injected clock,
    /// in the canonical format. Wall time is display/domain data only —
    /// never sync ordering (SyncSpec §9).
    func nowStamp() -> String {
        DateFormatter.variorumISO8601.string(from: date.now)
    }
}
