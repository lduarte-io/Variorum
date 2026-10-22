import CryptoKit
import Dependencies
import Foundation

/// The `vault-bootstrap` runner's brain (Phase 14b batch 3, L10 — the
/// architect's pre-spawn concretization: the Round-5 overnight arrangement's
/// EXECUTOR). The wipe-and-repush client half (`resyncReinitialize`, R-2)
/// productized behind an explicit, announced door: a headless maintenance
/// act, never reachable from any app surface. Its CLI shell
/// (`Tools/VaultBootstrap/`) was deleted at VX-329 U1 (its unlock read today's
/// key file), so the tests are its only caller now — FLAGGED in the U1 record
/// for the orchestrator's carve.
///
/// The acts, each logged: create the vault (passphrase wrap ONLY, Round 5;
/// REFUSES on an existing row — idempotence by refusal, never overwrite) OR
/// unwrap the existing vault; then `resyncReinitialize` on the store; then
/// engine rounds until the outbox drains. **Keys live in memory only and
/// die with the process** — custody (Keychain) is the APP's act at
/// enrollment, deliberately never the runner's (this module contains no
/// Security import, by construction). `dryRun` prints the plan and writes
/// NOTHING — not a row, not an outbox entry, not a vault.
///
/// Sequencing note (the R-2 choreography): the runner is meant to run AFTER
/// the mirror's data-table truncate. Run too early, the wrong order refuses
/// itself loudly: the first pull would meet the pre-14b PLAINTEXT rows and
/// the decrypt seam refuses the round (`unencryptedValueInEncryptedColumn`)
/// before anything lands — cursor unmoved, nothing written.
public struct VaultBootstrap: Sendable {
    public let client: KeyVaultClient
    public let transport: any SyncTransport
    public let database: AppDatabase
    /// Step-by-step act log (the CLI prints; tests capture). NEVER receives
    /// the passphrase or any key material.
    public let log: @Sendable (String) -> Void
    /// Bounded drain: a mirror that keeps rejecting must fail visibly, not
    /// spin.
    public var maxRounds: Int

    /// GM-3: how the drain sleeps between transient-transport retries.
    /// Defaults to a real backoff sleep; tests inject a no-op so the
    /// retry arms run instantly.
    public var transportRetrySleep: @Sendable (Int) async throws -> Void
    /// GM-3's bound: this many transient drops WITHOUT PROGRESS abort the
    /// run (typed, outbox intact). Progress resets the count — a burst-
    /// killing gateway can drop every round of a large drain while the
    /// outbox still converges.
    public var maxConsecutiveTransportFailures: Int

    public init(
        client: KeyVaultClient,
        transport: any SyncTransport,
        database: AppDatabase,
        maxRounds: Int = 50,
        maxConsecutiveTransportFailures: Int = 8,
        transportRetrySleep: @escaping @Sendable (Int) async throws -> Void = { seconds in
            try await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
        },
        log: @escaping @Sendable (String) -> Void
    ) {
        self.client = client
        self.transport = transport
        self.database = database
        self.maxRounds = maxRounds
        self.maxConsecutiveTransportFailures = maxConsecutiveTransportFailures
        self.transportRetrySleep = transportRetrySleep
        self.log = log
    }

    public enum Arm: String, Sendable {
        case createVault = "create-vault"
        case unwrapExisting = "unwrap-existing"
    }

    public struct Report: Sendable {
        public var arm: Arm
        public var roundsRun = 0
        public var pushedAccepted = 0
        public var remainingOutbox = 0
        public var dryRun = false
    }

    /// The whole bootstrap. Throws typed on every refusal arm (wrong
    /// passphrase, newer-format vault, an undrainable outbox); a thrown
    /// error means the run stopped at the named step with nothing guessed.
    @discardableResult
    public func run(passphrase: String, dryRun: Bool) async throws -> Report {
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        if passphrase.count < 12 {
            // Round 6 item 1: non-empty is the only enforcement; under 12
            // characters gets the recorded warning. The passphrase itself
            // is never logged.
            log("WARNING: the passphrase is under 12 characters — long passphrases are the dump's only brute-force barrier.")
        }

        let (rowTotal, outboxBefore) = try await storeCounts()
        log("Store: \(rowTotal) synced rows across \(SyncSchema.tables.count) tables; outbox \(outboxBefore) pending.")

        // Which arm — a read either way (newer-format refuses here, typed).
        let existingVault = try await client.fetchVault()
        let arm: Arm = existingVault == nil ? .createVault : .unwrapExisting
        log("Vault: \(existingVault == nil ? "absent — the create arm runs (passphrase wrap ONLY; the recovery phrase is generated in the app, in her presence)" : "present — the unwrap arm runs (never overwritten)").")

        if dryRun {
            log("DRY RUN — the plan: \(arm.rawValue) → resyncReinitialize (every row's sync_version → 0, sync_row_seq + pull cursor cleared, ALL \(rowTotal) rows enqueued) → engine rounds until the outbox drains. Nothing was written.")
            var report = Report(arm: arm)
            report.remainingOutbox = outboxBefore
            report.dryRun = true
            return report
        }

        // The KDF hop, measured into the log (never the passphrase).
        let enrollment = VaultEnrollment(client: client, kdfMeasurement: { [log] seconds in
            log(String(format: "Passphrase KDF derivation: %.3f s on this machine.", seconds))
        })
        let material: DeviceKeyMaterial
        switch arm {
        case .createVault:
            material = try await enrollment.setUp(passphrase: passphrase)
            log("Vault row created (passphrase wrap only; corpus + journal-bridge class keys minted).")
        case .unwrapExisting:
            material = try await enrollment.enroll(passphrase: passphrase)
            log("Vault unwrapped — master and both class keys held in memory for this process only.")
        }

        let keys = SyncEncryptionKeys(
            corpusKey: material.corpusSymmetricKey,
            corpusKeyID: material.corpusKeyID,
            keyProof: KeyProofMaterial(master: material.masterSymmetricKey))

        return try await withDependencies {
            $0.database = database
        } operation: {
            // pre-13x 1a: a headless run is its own device — a fresh
            // identity per run (never persisted; the runner dies with it).
            let engine = SyncEngine(
                transport: transport, keyProvider: StaticSyncKeyProvider(
                    keys: keys, deviceID: UUID().uuidString.lowercased()))

            try await engine.resyncReinitialize()
            let (_, outboxAfterReset) = try await storeCounts()
            log("resyncReinitialize: sync_version → 0 everywhere, sync_row_seq + pull cursor cleared, \(outboxAfterReset) rows enqueued for the repush.")

            var report = Report(arm: arm)
            // THE DRAIN-SUMMARY ACCUMULATOR (the 14b acceptance drill's
            // recorded cosmetic quirk, fixed at this batch's runner touch
            // — 14c batch 2, L6): the engine's PushReport dies with a
            // THROWN round, and under GM-3's absorbed drops every round
            // but the last can throw AFTER accepting chunks — so summing
            // only the returned reports understated the total (the
            // drill's summary claimed the last round's 674 where the
            // mirror held all 7,274). The truthful source is the OUTBOX
            // ITSELF: in the runner's single-writer world an entry clears
            // exactly when the mirror accepts its row, so the drained
            // delta IS the accepted total, thrown rounds included.
            var lastObservedOutbox = outboxAfterReset
            func recordDrain(to remaining: Int) {
                report.pushedAccepted += max(0, lastObservedOutbox - remaining)
                lastObservedOutbox = remaining
                report.remainingOutbox = remaining
            }
            // GM-3: transient transport drops (the -1005 class — the live
            // gateway kills rapid-fire chunk bursts) RETRY IN-PROCESS with
            // backoff instead of aborting the run: the outbox is durable
            // and resyncReinitialize ran ONCE above, so the next round
            // resumes exactly where the drop left off — no re-zeroing, no
            // reject-settling churn. Consecutive drops are bounded so a
            // genuinely dead network still fails visibly.
            var consecutiveTransportFailures = 0
            var remainingAtLastFailure: Int?
            for round in 1...max(maxRounds, 1) {
                report.roundsRun = round
                do {
                    _ = try await engine.pull()
                    let pushReport = try await engine.push()
                    consecutiveTransportFailures = 0
                    remainingAtLastFailure = nil
                    let (_, remaining) = try await storeCounts()
                    recordDrain(to: remaining)
                    log("Round \(round): pushed \(pushReport.accepted) accepted (\(pushReport.rejected) rejected, \(pushReport.deferred) deferred); outbox \(remaining) remaining.")
                    if remaining == 0 { break }
                } catch let error where Self.isTransientTransport(error) {
                    let (_, remaining) = try await storeCounts()
                    recordDrain(to: remaining)
                    // "Consecutive" means WITHOUT PROGRESS: a round that
                    // pushed chunks before its drop is converging, not
                    // stuck — the gateway kills bursts (GM-3), so on a
                    // large drain EVERY round may end in a drop while the
                    // outbox still marches down. Only a drop with no
                    // movement since the last one counts against the bound.
                    if let last = remainingAtLastFailure, remaining < last {
                        consecutiveTransportFailures = 1
                    } else {
                        consecutiveTransportFailures += 1
                    }
                    remainingAtLastFailure = remaining
                    guard consecutiveTransportFailures < maxConsecutiveTransportFailures else {
                        throw VaultBootstrapError.transportRepeatedlyFailed(
                            consecutiveFailures: consecutiveTransportFailures,
                            lastError: String(describing: error))
                    }
                    let delaySeconds = min(1 << (consecutiveTransportFailures - 1), 8)
                    log("Round \(round): transient transport drop (\(consecutiveTransportFailures)/\(maxConsecutiveTransportFailures)) — outbox \(remaining) remaining; retrying in \(delaySeconds)s.")
                    try await transportRetrySleep(delaySeconds)
                }
            }
            guard report.remainingOutbox == 0 else {
                throw VaultBootstrapError.outboxNeverDrained(
                    remaining: report.remainingOutbox, rounds: report.roundsRun)
            }
            log("Outbox drained in \(report.roundsRun) round(s); \(report.pushedAccepted) rows accepted by the mirror. Keys die with this process — the app enrolls from the vault.")
            return report
        }
    }

    /// GM-3's transient class: URL-loading transport drops that the app's
    /// scheduler absorbs by retrying rounds. Deliberately tight — anything
    /// else (auth refusals, CAS storms, crypto refusals) still aborts.
    static func isTransientTransport(_ error: any Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }
        switch nsError.code {
        case NSURLErrorNetworkConnectionLost, NSURLErrorTimedOut,
             NSURLErrorCannotConnectToHost, NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed:
            return true
        default:
            return false
        }
    }

    private func storeCounts() async throws -> (rows: Int, outbox: Int) {
        try await database.read { db in
            var total = 0
            for table in SyncSchema.tables {
                total += try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM \(table.name)") ?? 0
            }
            let outbox = try Int.fetchOne(
                db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            return (total, outbox)
        }
    }

    // MARK: - CLI helpers (pure; tested)

    /// The passphrase file's contract (Round 5 item 4): the file's bytes
    /// ARE the passphrase; ONE trailing newline is stripped, forgiving
    /// (`\n` or `\r\n` — her `read -s` shell writes one). Never printed,
    /// never logged. Empty (after the strip) refuses.
    public static func passphrase(fromFileBytes data: Data) throws -> String {
        guard let text = strippedFileText(data) else {
            throw VaultBootstrapError.passphraseFileUnreadable
        }
        guard !text.isEmpty else { throw VaultBootstrapError.passphraseFileEmpty }
        return text
    }

    /// The access-token file's contract (ladder R1-8 — argv rides `ps`
    /// output, so the gate hands the short-lived token in by FILE): same
    /// byte contract as the passphrase file — the file's bytes ARE the
    /// token, ONE trailing newline stripped; never printed, never logged.
    /// The `--access-token` argv form is retained; exactly one of the two
    /// is required (the CLI enforces the exactly-one).
    public static func accessToken(fromFileBytes data: Data) throws -> String {
        guard let text = strippedFileText(data) else {
            throw VaultBootstrapError.accessTokenFileUnreadable
        }
        guard !text.isEmpty else { throw VaultBootstrapError.accessTokenFileEmpty }
        return text
    }

    /// Strip ONE trailing newline at the BYTE level ("\r\n" is one grapheme
    /// to Swift strings; the file contracts are about bytes), then decode
    /// UTF-8. Nil = not UTF-8.
    private static func strippedFileText(_ data: Data) -> String? {
        var bytes = data
        if bytes.last == 0x0A {
            bytes.removeLast()
            if bytes.last == 0x0D { bytes.removeLast() }
        }
        return String(data: bytes, encoding: .utf8)
    }

    /// The `sub` claim of a JWT access token — the session's `auth.uid()`,
    /// needed only to compose the client's session (RLS is the real
    /// authority; nothing here verifies the signature and nothing needs
    /// to). Typed refusal on anything that isn't a three-part JWT with a
    /// string `sub`.
    public static func subject(ofAccessToken token: String) throws -> String {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else { throw VaultBootstrapError.malformedAccessToken }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 { payload += "=" }
        guard let data = Data(base64Encoded: payload),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = object["sub"] as? String, !sub.isEmpty
        else { throw VaultBootstrapError.malformedAccessToken }
        return sub
    }
}


public enum VaultBootstrapError: Error, Equatable, Sendable {
    /// The passphrase file's bytes are not UTF-8.
    case passphraseFileUnreadable
    /// The passphrase file is empty (after the one-newline strip).
    case passphraseFileEmpty
    /// The access-token file's bytes are not UTF-8 (R1-8's file form).
    case accessTokenFileUnreadable
    /// The access-token file is empty (after the one-newline strip).
    case accessTokenFileEmpty
    /// The access token is not a decodable JWT with a `sub` claim.
    case malformedAccessToken
    /// The outbox did not drain within the round bound — the mirror kept
    /// rejecting or deferring; nothing is lost (the outbox keeps
    /// everything), the run just refuses to claim success.
    case outboxNeverDrained(remaining: Int, rounds: Int)
    /// Too many CONSECUTIVE transient transport drops (gate finding GM-3:
    /// the live gateway kills rapid-fire chunk bursts with
    /// NSURLError -1005; the app's scheduler absorbs this class by
    /// retrying rounds, so the runner's drain must too). Nothing is lost —
    /// the outbox keeps everything; re-running resumes.
    case transportRepeatedlyFailed(consecutiveFailures: Int, lastError: String)
}
