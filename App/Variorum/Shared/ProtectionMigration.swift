//
//  ProtectionMigration.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13x batch 2a — §11, THE MIGRATION OF AN EXISTING STORE (the author's
//  two devices, in her presence at the batch 2 sitting; the DEV store and
//  the signed-host drill prove it here). Runs ONCE per store id at the
//  first READY after the install — never before unlock — behind a seam of
//  leaves (production: the Keychain, the defaults, the store; the pins:
//  recorders). Every leg LOGS A LINE and NEVER key material (pinned by a
//  scan of the log). Idempotent: a refused leg leaves what it found and the
//  next ready retries; a completed migration is marked and skipped.
//
//  THE LEGS, in order:
//   1. the sync custody re-scoped (1a's `migrateSyncCustodyToStoreScope`):
//      the 14b/CF-12 fixed-account items → the per-store record in the
//      library key's shape, the device identity from `sync_state.device_id`
//      (the row then deleted), the CF-12 opt-in retired; the legacy gated
//      item's material arrives from the lobby's ONE evaluated context
//      (`SyncCustodySession.legacyMaterial`, held from the unlock);
//   2. the LEGACY ESCROW item removed from iCloud Keychain — the 13p family
//      put the RAW library key there (the brief's fact ii) — under the
//      R1-m1 OWNERSHIP guard: only an item equal to the key in hand goes; a
//      foreign one is left (somebody's recovery leg);
//   3. the dial keys retired to the per-store keys (the read-through ends
//      for the store; her gate style survives as `alwaysAsk`);
//   4. custody ALIGNED to the derived posture (her Mac: the biometric item,
//      as it is; her phone: silent → Face ID — "her phone becomes Castle
//      at its migration"); a Mac without biometry takes Always ask;
//   5. the key file's MASTER copy + the corpus key id from HELD material
//      (no visit, no typing — this alone gives the vault road), and the
//      vault's KDF descriptor when the vault was reachable;
//   6. the passphrase confirm marked PENDING (an enrolled library): the
//      one-time face (copy §9) re-wraps the local P copy under the VAULT's
//      descriptor once the typed word has unwrapped the vault's master —
//      the migration may ask ONCE; *Later* defers to the next ready.
//  The proof hash's landing is 1b's engine round — nothing here.
//

import CryptoKit
import Foundation
import GRDB
import os
import VariorumCore

nonisolated enum ProtectionMigration {
    /// What the run reports — one line per leg, never key material.
    struct Report: Equatable, Sendable {
        var lines: [String] = []
        var syncCustody: CustodyHandover.Outcome?
        var escrowRemoved = false
        var escrowLeftForeign = false
        var dialsRetired = false
        var custodyAligned: StoreAtOpenMode?
        var masterCopyWritten = false
        var confirmPending = false
        var skippedAsDone = false
    }

    /// The facts the caller (the bootstrap, at ready) hands in.
    struct Facts: Sendable {
        var scope: String
        var storeID: String
        /// The library key in hand (the resident under Castle; the bound
        /// item's under Standard).
        var key: StoreKey
        /// The library key's custody shape NOW (the derived gate the route
        /// used).
        var effectiveGate: StoreAtOpenMode
        /// The posture the migration ALIGNS custody to (derived at ready —
        /// the vault's word when reachable, else the key file's).
        var targetGate: StoreAtOpenMode
        var biometryAvailable: Bool
        /// The vault, if reachable: its KDF descriptor (the key file records
        /// it) and whether it holds a passphrase wrap (the confirm's gate).
        var vaultKDF: PassphraseKDF.Descriptor?
        var vaultHasPassphraseWrap: Bool
    }

    /// The seams (production: `Leaves.live`; the pins: recorders).
    struct Leaves: Sendable {
        var isDone: @Sendable () -> Bool
        var markDone: @Sendable () -> Void
        var isConfirmPending: @Sendable () -> Bool
        var setConfirmPending: @Sendable (Bool) -> Void
        /// The 14b/CF-12 legacy plain item's material (the file-based
        /// `device-keys` item), if any.
        var legacyPlainMaterial: @Sendable () -> DeviceKeyMaterial?
        /// The legacy GATED item's material, read under the lobby's one
        /// evaluated context and held in the session until consumed.
        var legacyGatedMaterial: @Sendable () -> DeviceKeyMaterial?
        var deleteLegacyItems: @Sendable () -> Bool
        var retireOptIn: @Sendable () -> Void
        var syncLeaves: E2EECustodyLeaves
        var session: SyncCustodySession
        var readDeviceIDRow: @Sendable () async -> String?
        var deleteDeviceIDRow: @Sendable () async -> Void
        var loadLegacyEscrow: @Sendable (_ storeID: String) -> StoreKey?
        var removeLegacyEscrow: @Sendable (_ storeID: String) -> Bool
        var retireDialKeys: @Sendable () -> Void
        var setAlwaysAsk: @Sendable (Bool) -> Void
        /// The controller's both-items move (the lobby's resident key in
        /// hand). Returns true when the custody now matches the gate.
        var alignCustody: @Sendable (StoreAtOpenMode) async -> Bool
        var readEnvelope: @Sendable () -> StoreKeyEnvelope?
        var saveEnvelope: @Sendable (StoreKeyEnvelope) throws -> Void
        var log: @Sendable (String) -> Void
    }

    static let doneLeaf = "migrated2a"
    static let confirmPendingLeaf = "migration2aConfirmPending"

    /// THE RUN. Never throws; every leg records its line.
    /// The run — OFF the main thread by construction (the KeychainOffMain
    /// law: the legs read and write Keychain items; under approachable
    /// concurrency a nonisolated async function runs on its CALLER's
    /// actor, and the bootstrap calls from the MainActor). Measured before
    /// this hop: the test host's main thread parked in `SecItemCopyMatching`
    /// → securityd decrypt behind a login-keychain ACL prompt — a hang no
    /// face could interrupt. The leaves that must touch MainActor state
    /// (`alignCustody`) hop there themselves.
    static func run(facts: Facts, leaves: Leaves) async -> Report {
        await Task.detached(priority: .utility) {
            await runBody(facts: facts, leaves: leaves)
        }.value
    }

    private static func runBody(facts: Facts, leaves: Leaves) async -> Report {
        var report = Report()
        func note(_ line: String) {
            report.lines.append(line)
            leaves.log(line)
        }
        guard !leaves.isDone() else {
            report.skippedAsDone = true
            return report
        }
        note("migration 2a: begins for store \(facts.storeID.prefix(8))… under \(facts.effectiveGate.rawValue)")

        // 1. THE SYNC CUSTODY RE-SCOPE (1a's hook; her enrolled devices).
        let perStoreExists = leaves.syncLeaves.loadPlain()?.material != nil
            || leaves.session.record?.material != nil
        if perStoreExists {
            note("migration 2a: sync custody already per store — skipped")
        } else if let material = leaves.legacyGatedMaterial() ?? leaves.legacyPlainMaterial() {
            let deviceID = await leaves.readDeviceIDRow()
            let outcome = SyncCustodyMigration.migrateSyncCustodyToStoreScope(
                legacy: SyncCustodyMigration.Legacy(
                    material: material, deviceID: deviceID,
                    deleteLegacyItems: leaves.deleteLegacyItems,
                    retireOptIn: leaves.retireOptIn),
                shape: SyncCustodyShape(mode: facts.effectiveGate),
                leaves: leaves.syncLeaves, session: leaves.session)
            report.syncCustody = outcome
            note("migration 2a: sync custody re-scoped → \(outcome) (identity \(deviceID == nil ? "minted" : "from sync_state"))")
            if outcome == .done { await leaves.deleteDeviceIDRow() }
        } else {
            note("migration 2a: no legacy sync custody (never enrolled) — skipped")
        }

        // 2. THE LEGACY ESCROW ITEM (fact ii), ownership-guarded.
        if let escrowed = leaves.loadLegacyEscrow(facts.storeID) {
            if escrowed == facts.key {
                report.escrowRemoved = leaves.removeLegacyEscrow(facts.storeID)
                note("migration 2a: legacy iCloud escrow item removed → \(report.escrowRemoved)")
            } else {
                report.escrowLeftForeign = true
                note("migration 2a: legacy iCloud escrow item is another key's — left")
            }
        } else {
            note("migration 2a: no legacy iCloud escrow item")
        }

        // 3. THE DIAL KEYS retired (the read-through ends for this store).
        leaves.retireDialKeys()
        report.dialsRetired = true
        note("migration 2a: dial keys retired to the per-store keys")

        // 4. CUSTODY ALIGNED to the derived posture.
        var target = facts.targetGate
        if target == .biometric, !facts.biometryAvailable {
            target = .passphrase
            leaves.setAlwaysAsk(true)
            note("migration 2a: no biometry on this device — Always ask")
        }
        if target != facts.effectiveGate {
            let aligned = await leaves.alignCustody(target)
            report.custodyAligned = aligned ? target : nil
            note("migration 2a: custody aligned \(facts.effectiveGate.rawValue) → \(target.rawValue): \(aligned ? "done" : "REFUSED — the next ready retries")")
            if !aligned { return report }
        } else {
            report.custodyAligned = target
            note("migration 2a: custody already \(target.rawValue)")
        }

        // 5. THE KEY FILE'S MASTER COPY + the corpus key id (+ the vault's
        //    descriptor when reachable) from HELD material.
        if let material = leaves.session.record?.material ?? leaves.syncLeaves.loadPlain()?.material,
           var envelope = leaves.readEnvelope() {
            do {
                if envelope.master == nil {
                    try envelope.masterBox(key: facts.key, under: material.masterSymmetricKey)
                }
                try envelope.recordVaultReconciliation(
                    kdf: facts.vaultKDF ?? envelope.vaultKDF, corpusKeyID: material.corpusKeyID)
                try leaves.saveEnvelope(envelope)
                report.masterCopyWritten = true
                note("migration 2a: key file gains the master copy + corpus key id\(facts.vaultKDF == nil ? " (vault descriptor: next online ready)" : " + the vault's descriptor")")
            } catch {
                note("migration 2a: key file write refused — \(String(describing: error)); the next ready retries")
                return report
            }
            // 6. THE PASSPHRASE CONFIRM (copy §9), once, for an enrolled library.
            if facts.vaultHasPassphraseWrap {
                leaves.setConfirmPending(true)
                report.confirmPending = true
                note("migration 2a: passphrase confirm pending (the one-time face)")
            }
        } else {
            note("migration 2a: no sync material — the key file keeps no master copy (local-only)")
        }

        leaves.markDone()
        note("migration 2a: done")
        return report
    }
}

// MARK: - The production leaves

nonisolated extension ProtectionMigration.Leaves {
    /// The Keychain, the defaults and the store — per store id.
    @MainActor
    static func live(
        scope: String, storeID: String, storeURL: URL?,
        database: AppDatabase, gate: StoreLaunchGate,
        protection: ProtectionController,
        defaults: @escaping @Sendable () -> UserDefaults = { .standard },
        session: SyncCustodySession = .shared
    ) -> ProtectionMigration.Leaves {
        let custody = SyncCustodyScope(scope: scope, storeID: storeID)
        let doneKey = ProtectionDefaults.key(ProtectionMigration.doneLeaf, scope: scope, storeID: storeID)
        let pendingKey = ProtectionDefaults.key(ProtectionMigration.confirmPendingLeaf, scope: scope, storeID: storeID)
        let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")
        return ProtectionMigration.Leaves(
            isDone: { defaults().bool(forKey: doneKey) },
            markDone: { defaults().set(true, forKey: doneKey) },
            isConfirmPending: { defaults().bool(forKey: pendingKey) },
            setConfirmPending: { defaults().set($0, forKey: pendingKey) },
            legacyPlainMaterial: { E2EEKeychainStorage.legacyLoadPlain()?.material },
            legacyGatedMaterial: { session.takeLegacyMaterial() },
            deleteLegacyItems: { E2EEKeychainStorage.legacyDelete() },
            retireOptIn: { defaults().removeObject(forKey: SyncCustodyMigration.legacyOptInDefaultsKey) },
            syncLeaves: .live(scope: custody),
            session: session,
            readDeviceIDRow: {
                try? await database.read { db in
                    try String.fetchOne(db, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
                }
            },
            deleteDeviceIDRow: {
                _ = try? await database.write { db in
                    try db.execute(sql: "DELETE FROM sync_state WHERE key = 'device_id'")
                }
            },
            loadLegacyEscrow: { gate.guardFor(scope).loadLegacyEscrow($0) },
            removeLegacyEscrow: { gate.guardFor(scope).removeLegacyEscrow($0) },
            retireDialKeys: { gate.retireLegacyDials(scope, storeID) },
            setAlwaysAsk: { on in
                var dials = gate.dials(scope, storeID)
                dials.alwaysAsk = on
                gate.saveDials(dials, scope, storeID)
            },
            alignCustody: { target in await protection.moveCustodyChanged(to: target) },
            readEnvelope: { gate.readEnvelope(storeURL).envelope },
            saveEnvelope: { try gate.saveEnvelope($0, storeURL ?? URL(fileURLWithPath: "/dev/null")) },
            // pre-13x 2b (the orchestrator's addition): `notice`, not `info` —
            // macOS does not persist info-level entries, and the window reads
            // these lines with `log show` after the fact. Never key material.
            log: { logger.notice("\($0, privacy: .public)") })
    }

    /// The pending-confirm read (the notice's gate), per store id.
    static func confirmPending(scope: String, storeID: String, defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: ProtectionDefaults.key(ProtectionMigration.confirmPendingLeaf, scope: scope, storeID: storeID))
    }
}

// MARK: - The confirm's production composition

extension MigrationConfirmModel {
    /// The vault verify through the real client (the enrollment's unwrap —
    /// a wrong word refuses typed, nothing is written) and the controller's
    /// re-wrap; nil when no vault client is composed (unconfigured).
    static func make(
        keyVault: KeyVaultClient?, controller: ProtectionController
    ) -> MigrationConfirmModel? {
        guard let keyVault else { return nil }
        return MigrationConfirmModel(
            verify: { passphrase in
                let enrollment = VaultEnrollment(client: keyVault)
                let material = try await enrollment.enroll(passphrase: passphrase)
                guard let fetched = try await keyVault.fetchVault() else {
                    throw KeyVaultClientError.vaultAbsent
                }
                return (fetched.format.kdf, material.corpusKeyID)
            },
            rewrap: { passphrase, kdf, corpusKeyID in
                await controller.reconcilePassphraseWrap(
                    passphrase: passphrase, vaultKDF: kdf, corpusKeyID: corpusKeyID)
            },
            clearPending: { [weak controller] in
                Task { @MainActor in controller?.clearMigrationConfirmPending?() }
            })
    }
}

extension MigrationConfirmModel: Identifiable {}

// MARK: - The one-time confirm face's brain (copy §9)

/// *"…Confirm your passphrase once to finish."* — the typed word is
/// verified against the VAULT (it must unwrap the vault's master — never
/// a local compare), then the local passphrase copy is re-wrapped under
/// the vault's descriptor so the two agree and the lobby's vault road
/// derives ONCE (§3.6). A typo writes nothing. *Later* leaves the
/// pending mark for the next ready.
@MainActor
@Observable
final class MigrationConfirmModel {
    private(set) var busy = false
    private(set) var done = false
    var lastError: String?

    /// Verifies the passphrase against the vault; returns the vault's KDF
    /// descriptor and corpus key id on success. Wired by the composition
    /// (`VaultEnrollment.enroll` — the real unwrap, off the main actor).
    private let verify: @Sendable (String) async throws -> (kdf: PassphraseKDF.Descriptor, corpusKeyID: String)
    private let rewrap: @MainActor (String, PassphraseKDF.Descriptor, String) async -> String?
    private let clearPending: @Sendable () -> Void

    init(
        verify: @escaping @Sendable (String) async throws -> (kdf: PassphraseKDF.Descriptor, corpusKeyID: String),
        rewrap: @escaping @MainActor (String, PassphraseKDF.Descriptor, String) async -> String?,
        clearPending: @escaping @Sendable () -> Void
    ) {
        self.verify = verify
        self.rewrap = rewrap
        self.clearPending = clearPending
    }

    func confirm(passphrase: String) async {
        guard !busy, !passphrase.isEmpty else { return }
        busy = true
        lastError = nil
        defer { busy = false }
        do {
            let vault = try await verify(passphrase)
            if let refusal = await rewrap(passphrase, vault.kdf, vault.corpusKeyID) {
                lastError = refusal
                return
            }
            clearPending()
            done = true
        } catch {
            lastError = EncryptionSession.message(for: error)
        }
    }
}
