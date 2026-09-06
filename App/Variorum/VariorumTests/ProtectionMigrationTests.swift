//
//  ProtectionMigrationTests.swift
//  VariorumTests
//
//  pre-13x batch 2a — §11's migration, pinned over recording leaves (the
//  legs in order; the ownership-guarded escrow removal; the dial keys
//  retired; custody aligned; the key file's master copy; the confirm
//  pending), the NO-KEY-MATERIAL log scan, idempotence, and the one-time
//  confirm face's brain (copy §9): a wrong word writes nothing, the right
//  one re-wraps under the VAULT's descriptor and clears the mark; Later
//  keeps it. The signed-host drill under throwaway scopes is
//  `ProtectionMigrationDrillTests` (opt-in).
//

import CryptoKit
import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("pre-13x 2a — the §11 migration over recording leaves")
struct ProtectionMigrationTests {
    nonisolated private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func material() -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data((0..<32).map { _ in UInt8.random(in: 0...255) }),
            corpusKey: Data((0..<32).map { _ in UInt8.random(in: 0...255) }), corpusKeyID: "corpus-7",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")
    }

    private final class World: @unchecked Sendable {
        let lock = NSLock()
        var done = false
        var confirmPending = false
        var legacyPlain: DeviceKeyMaterial?
        var legacyGated: DeviceKeyMaterial?
        var legacyDeleted = false
        var optInRetired = false
        var deviceIDRow: String?
        var escrow: [String: StoreKey] = [:]
        var dialsRetired = false
        var alwaysAsk = false
        var aligned: [StoreAtOpenMode] = []
        var alignSucceeds = true
        var envelope: StoreKeyEnvelope?
        var log: [String] = []
        /// Which Keychain-class leaves ran on the MAIN thread (the
        /// KeychainOffMain law's pin).
        var onMain: [String] = []
        let sync: RecordingSyncLeaves
        let session = SyncCustodySession()

        init(sync: RecordingSyncLeaves = RecordingSyncLeaves()) { self.sync = sync }

        func with<T>(_ body: () -> T) -> T { lock.lock(); defer { lock.unlock() }; return body() }

        var leaves: ProtectionMigration.Leaves {
            ProtectionMigration.Leaves(
                isDone: { [self] in with { done } },
                markDone: { [self] in with { done = true } },
                isConfirmPending: { [self] in with { confirmPending } },
                setConfirmPending: { [self] on in with { confirmPending = on } },
                legacyPlainMaterial: { [self] in
                    if Thread.isMainThread { with { onMain.append("legacyPlainMaterial") } }
                    return with { legacyPlain }
                },
                legacyGatedMaterial: { [self] in with { let m = legacyGated; legacyGated = nil; return m } },
                deleteLegacyItems: { [self] in with { legacyDeleted = true; legacyPlain = nil; return true } },
                retireOptIn: { [self] in with { optInRetired = true } },
                syncLeaves: sync.leaves,
                session: session,
                readDeviceIDRow: { [self] in with { deviceIDRow } },
                deleteDeviceIDRow: { [self] in with { deviceIDRow = nil } },
                loadLegacyEscrow: { [self] id in
                    if Thread.isMainThread { with { onMain.append("loadLegacyEscrow") } }
                    return with { escrow[id] }
                },
                removeLegacyEscrow: { [self] id in with { escrow[id] = nil; return true } },
                retireDialKeys: { [self] in with { dialsRetired = true } },
                setAlwaysAsk: { [self] on in with { alwaysAsk = on } },
                alignCustody: { [self] target in with { aligned.append(target); return alignSucceeds } },
                readEnvelope: { [self] in with { envelope } },
                saveEnvelope: { [self] new in with { envelope = new } },
                log: { [self] line in with { log.append(line) } })
        }
    }

    /// pre-13x 2d (decision 35): the facts are the RAW ones — the session,
    /// the vault's word (`vault`: false = Castle, true = Standard, nil =
    /// unread), the gate style — and the run derives the target itself.
    private func facts(
        key: StoreKey, effective: StoreAtOpenMode = .auto, vault: Bool? = false,
        signedIn: Bool = true, alwaysAsk: Bool = false,
        biometry: Bool = true, vaultKDF: PassphraseKDF.Descriptor? = nil
    ) -> ProtectionMigration.Facts {
        ProtectionMigration.Facts(
            scope: "probe", storeID: "store-2a", key: key, effectiveGate: effective,
            signedIn: signedIn, vaultHasAppleHeldCopy: vault, alwaysAsk: alwaysAsk,
            biometryAvailable: biometry, vaultKDF: vaultKDF)
    }

    /// HER PHONE'S SHAPE: a 14b plain item + a `sync_state.device_id` row +
    /// the legacy escrow item holding the RAW key + a silent store key —
    /// the vault says Castle. Every leg runs, in order; the log carries no
    /// key material. RED ON OLD by construction (no migration existed).
    @Test func everyLegRunsInOrderAndTheLogCarriesNoKeyMaterial() async throws {
        let key = StoreKey.mint()
        let w = World()
        let held = material()
        w.legacyPlain = held
        w.deviceIDRow = "phone-device-id"
        w.escrow["store-2a"] = key
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        w.envelope = envelope
        let vaultKDF = fastKDF()

        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: false, vaultKDF: vaultKDF),
            leaves: w.leaves)

        #expect(report.syncCustody == .done, "the sync custody re-scoped under the SILENT shape (the gate the route used)")
        #expect(w.sync.plainRecord?.material == held, "the per-store record holds the legacy material")
        #expect(w.sync.plainRecord?.deviceID == "phone-device-id", "the identity from sync_state")
        #expect(w.deviceIDRow == nil, "…and the row is deleted")
        #expect(w.legacyDeleted && w.optInRetired)
        #expect(report.escrowRemoved && w.escrow.isEmpty, "the legacy escrow item (the RAW key in iCloud) removed")
        #expect(report.dialsRetired && w.dialsRetired)
        #expect(w.aligned == [.biometric], "custody ALIGNED to Castle — her phone becomes Face ID")
        #expect(report.custodyAligned == .biometric)
        #expect(report.masterCopyWritten)
        let written = try #require(w.envelope)
        #expect(try written.unwrapKey(master: held.masterSymmetricKey) == key,
                "the key file's master copy opens with the held master — the vault road, with no visit")
        #expect(written.vaultCorpusKeyID == "corpus-7")
        #expect(written.vaultKDF == vaultKDF, "the vault's descriptor recorded")
        #expect(report.confirmPending && w.confirmPending, "the one-time face is owed")
        #expect(w.done)

        // The order, by the log's own lines.
        let order = w.log.compactMap { line -> String? in
            if line.contains("sync custody re-scoped") { return "sync" }
            if line.contains("escrow item removed") { return "escrow" }
            if line.contains("dial keys retired") { return "dials" }
            if line.contains("custody aligned") { return "align" }
            if line.contains("master copy") { return "master" }
            if line.contains("confirm pending") { return "confirm" }
            return nil
        }
        #expect(order == ["sync", "escrow", "dials", "align", "master", "confirm"], "\(order)")

        // NO KEY MATERIAL in any line (pinned: the §11 rule).
        let forbidden = [key.hexEncoded, key.data.base64EncodedString(),
                         held.masterKey.base64EncodedString(), held.corpusKey.base64EncodedString(),
                         held.masterKey.map { String(format: "%02x", $0) }.joined()]
        for line in w.log {
            for secret in forbidden {
                #expect(!line.contains(secret), "key material in the log: \(line)")
            }
        }
        #expect(!w.log.contains { $0.contains("sesame") }, "no passphrase in the log")

        // IDEMPOTENT: a second run is skipped whole.
        let again = await ProtectionMigration.run(facts: facts(key: key), leaves: w.leaves)
        #expect(again.skippedAsDone)
        #expect(w.aligned == [.biometric], "nothing re-run")
    }

    /// THE OWNERSHIP GUARD (R1-m1): a legacy escrow item holding ANOTHER key
    /// is somebody's recovery leg — left, and said so.
    @Test func aForeignLegacyEscrowItemIsLeftAlone() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.escrow["store-2a"] = StoreKey.mint()
        w.envelope = StoreKeyEnvelope()
        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .biometric, vault: false),
            leaves: w.leaves)
        #expect(report.escrowLeftForeign)
        #expect(!report.escrowRemoved)
        #expect(w.escrow["store-2a"] != nil, "a foreign item survives the migration")
        #expect(w.log.contains { $0.contains("another key's — left") })
    }

    /// HER MAC'S SHAPE: already Biometric, a legacy GATED item read under
    /// the lobby's context; the custody is already aligned (no move); the
    /// legacy gated material lands in the gated per-store record.
    @Test func anAlreadyGatedLibraryReScopesWithoutMoving() async throws {
        let key = StoreKey.mint()
        let w = World()
        let held = material()
        w.legacyGated = held
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        w.envelope = envelope
        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .biometric, vault: false), leaves: w.leaves)
        #expect(report.syncCustody == .done)
        #expect(w.sync.gatedRecord?.material == held, "the material behind the gate")
        #expect(w.sync.plainRecord?.material == nil, "the plain item is identity-only")
        #expect(w.session.record?.material == held, "the session that migrated is unlocked")
        #expect(w.aligned.isEmpty, "custody already matches — nothing moved")
        #expect(report.custodyAligned == .biometric)
        #expect(report.masterCopyWritten)
        #expect(w.legacyGated == nil, "the held legacy material consumed once")
    }

    /// A Mac WITHOUT biometry aligning to Castle takes Always ask (§14.36).
    @Test func noBiometryMeansAlwaysAsk() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.legacyPlain = material()
        w.envelope = StoreKeyEnvelope()
        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: false, biometry: false), leaves: w.leaves)
        #expect(w.alwaysAsk)
        #expect(w.aligned == [.passphrase])
        #expect(report.custodyAligned == .passphrase)
    }

    /// A REFUSED custody move stops the run before the key file; the mark
    /// is NOT set, so the next ready retries.
    @Test func aRefusedAlignmentLeavesTheMigrationUndoneForTheNextReady() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.legacyPlain = material()
        w.envelope = StoreKeyEnvelope()
        w.alignSucceeds = false
        let report = await ProtectionMigration.run(facts: facts(key: key), leaves: w.leaves)
        #expect(report.custodyAligned == nil)
        #expect(!report.masterCopyWritten)
        #expect(!w.done, "undone — retried at the next ready")
        #expect(w.log.contains { $0.contains("REFUSED — the next ready retries") })
    }

    /// A never-enrolled local-only library: no sync legs, no master copy,
    /// no confirm — the dial keys retire and it is done.
    @Test func aLocalOnlyLibraryRetiresItsDialsAndOwesNoConfirm() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.envelope = StoreKeyEnvelope()
        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: nil, signedIn: false), leaves: w.leaves)
        #expect(report.syncCustody == nil)
        #expect(report.dialsRetired)
        #expect(!report.masterCopyWritten && !report.confirmPending)
        #expect(w.done)
    }

    /// THE OFF-MAIN LAW: the legs that touch the Keychain never run on the
    /// main thread, whoever calls `run` (the bootstrap calls from the
    /// MainActor; this suite is MainActor too). RED ON OLD: without the
    /// detached hop inside `run`, approachable concurrency runs the body
    /// on the caller's actor and both leaves record "main" — the shape
    /// that parked the test host behind a login-keychain ACL prompt.
    @Test func theKeychainLegsNeverRunOnTheMainThread() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.legacyPlain = material()
        w.escrow["store-2a"] = key
        w.envelope = StoreKeyEnvelope()
        _ = await ProtectionMigration.run(facts: facts(key: key), leaves: w.leaves)
        #expect(w.onMain.isEmpty, "Keychain-class leaves ran on main: \(w.onMain)")
        #expect(w.legacyDeleted, "…and the run did run")
    }

    /// DECISION 35 (pre-13x 2d): an ENROLLED library whose vault is unread
    /// at its migration — her phone's 14b plain item + a session, a
    /// secret-less format-1 key file, the vault's word unavailable at that
    /// instant — runs legs 1–2 (the custody re-scoped under the shape it
    /// HAS; the escrow), then STOPS before leg 3 with one line and WITHOUT
    /// marking done: no dial-key retirement, no custody move, no key-file
    /// write, no confirm. The next ready, with the vault's word (Castle),
    /// runs legs 3–6 — her phone becomes Face ID THEN. Enrolled by custody
    /// alone reads the same; a library with NO session and NO custody keeps
    /// 2a's safety arm and finishes. RED ON OLD: the bootstrap derived a
    /// determined Standard from the secret-less file and the run aligned
    /// nothing, wrote nothing it should not, and marked itself DONE — the
    /// phone's repair could never come through the migration again.
    @Test func anEnrolledLibraryWhoseVaultIsUnreadStopsBeforeLegThreeUndoneAndTheNextReadyFinishes() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.legacyPlain = material()
        w.deviceIDRow = "phone-device-id"
        let secretless = StoreKeyEnvelope(formatVersion: StoreKeyEnvelope.formatVersion1, storeID: "store-2a")
        w.envelope = secretless

        let first = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: nil, signedIn: true), leaves: w.leaves)
        #expect(first.syncCustody == .done, "leg 1: the custody re-scoped under the shape it has (silent)")
        #expect(w.sync.plainRecord?.material != nil)
        #expect(!first.dialsRetired && !w.dialsRetired, "the legacy-key retirement WAITS")
        #expect(w.aligned.isEmpty && first.custodyAligned == nil, "no custody move")
        #expect(!first.masterCopyWritten && w.envelope == secretless, "the key file untouched")
        #expect(!first.confirmPending && !w.confirmPending)
        #expect(!w.done, "UNDONE — the next ready retries")
        #expect(w.log.contains { $0.contains("indeterminate") && $0.contains("the run stays undone") },
                "one honest line: \(w.log)")

        // The next ready — the vault's word CASTLE: legs 3–6 run.
        let vaultKDF = fastKDF()
        let second = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: false, signedIn: true, vaultKDF: vaultKDF),
            leaves: w.leaves)
        #expect(second.lines.contains { $0.contains("already per store — skipped") }, "leg 1 idempotent")
        #expect(second.dialsRetired && w.dialsRetired)
        #expect(w.aligned == [.biometric] && second.custodyAligned == .biometric, "her phone becomes Face ID with the vault's word")
        #expect(second.masterCopyWritten && w.envelope?.vaultKDF == vaultKDF)
        #expect(second.confirmPending && w.confirmPending)
        #expect(w.done)

        // Enrolled by CUSTODY alone (no session): indeterminate too.
        let byCustody = World(sync: RecordingSyncLeaves(
            plain: SyncCustodyRecord(deviceID: "d", material: material())))
        byCustody.envelope = secretless
        let custody = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: nil, signedIn: false), leaves: byCustody.leaves)
        #expect(!byCustody.done && byCustody.aligned.isEmpty && !custody.dialsRetired)

        // NO session, NO custody, no secrets: 2a's safety arm — determined
        // Standard, the run finishes (nothing to align: silent stays silent).
        let local = World()
        local.envelope = secretless
        let alone = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: nil, signedIn: false), leaves: local.leaves)
        #expect(alone.dialsRetired && local.aligned.isEmpty && alone.custodyAligned == .auto)
        #expect(!alone.masterCopyWritten && local.done)
    }

    /// pre-13x 2d (the brief's item 3) — THE CONFIRM's GATE: her Mac after
    /// the window — enrolled, the migration DONE, the key file carrying
    /// the MASTER copy + a passphrase copy but NO recorded vault descriptor
    /// (the vault was unreachable at the migration's instant; nothing
    /// re-ran) and the pending mark NEVER set — owes the one-time confirm
    /// by DERIVATION; *Later* hides it for the launch and the condition
    /// stands; typing the passphrase lands `vaultKDF` + the reconciled copy
    /// and the confirm is gone. A library WITHOUT a master copy (a 14c-era
    /// Encryption-tab enrollee) owes nothing; one whose descriptor is
    /// recorded owes nothing. RED ON OLD: the confirm showed on the mark
    /// alone, and the migration's leg 6 set the mark only when the vault
    /// was reachable — her Mac never saw the sheet and `vaultKDF` never
    /// landed.
    @Test func anEnrolledLibraryWithAMasterCopyAndNoRecordedDescriptorOwesTheConfirmByDerivation() async throws {
        let key = StoreKey.mint()
        let held = material()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        try envelope.masterBox(key: key, under: held.masterSymmetricKey)
        #expect(envelope.vaultKDF == nil, "the migration's leg 5 without the vault: no descriptor")
        let backing = InMemoryStoreKeyGuardBacking(gated: key, biometryAvailable: true, biometricSucceeds: true)
        let envelopeBox = ScriptedEnvelopeBox(envelope)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing, envelope: envelopeBox)
        let session = SyncCustodySession()
        session.hold(SyncCustodyRecord(deviceID: "mac-1", material: held))
        let controller = ProtectionController(configuration: .init(
            scope: "probe", storeURL: nil, gate: gate, isRealVariant: false,
            makeKDF: { self.fastKDF() }, storeID: { [id = envelope.storeID] in id },
            syncCustodySession: session))
        controller.adoptResident(key)
        let mark = LockIsolated(false)  // never set — her Mac
        controller.readMigrationConfirmPending = { mark.value }
        controller.clearMigrationConfirmPending = { mark.setValue(false) }
        controller.isSignedIn = { true }
        controller.readVaultPosture = { nil }

        await controller.reconcile()
        #expect(controller.migrationConfirmOwedByDerivation)
        #expect(controller.notice == .migrationConfirm, "the confirm shows by derivation, the mark absent")
        controller.deferMigrationConfirm()
        #expect(controller.notice != .migrationConfirm, "Later hides it for this launch")
        #expect(controller.migrationConfirmOwedByDerivation, "…and the condition stands for the next ready")

        let vaultKDF = fastKDF()
        #expect(await controller.reconcilePassphraseWrap(
            passphrase: "sesame", vaultKDF: vaultKDF, corpusKeyID: held.corpusKeyID) == nil)
        let written = try #require(envelopeBox.value)
        #expect(written.vaultKDF == vaultKDF && written.passphrase?.kdf == vaultKDF,
                "typing it lands the descriptor + the reconciled copy")
        #expect(try written.unwrapKey(passphrase: "sesame") == key)
        #expect(!controller.migrationConfirmOwedByDerivation)
        await controller.reconcile()
        #expect(controller.notice != .migrationConfirm, "the confirm is gone")

        // A 14c-era enrollee: a passphrase copy under a fresh descriptor,
        // NO master copy — nothing owed (copy §9 is her migration's).
        var fresh = StoreKeyEnvelope()
        try fresh.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        let enrollee = ProtectionController(configuration: .init(
            scope: "probe", storeURL: nil, gate: StoreLaunchGate.scripted(
                dials: ScriptedDialsBox(ProtectionDials()), backing: backing, envelope: ScriptedEnvelopeBox(fresh)),
            isRealVariant: false, makeKDF: { self.fastKDF() }, storeID: { [id = fresh.storeID] in id },
            syncCustodySession: session))
        enrollee.adoptResident(key)
        enrollee.readMigrationConfirmPending = { false }
        enrollee.isSignedIn = { true }
        await enrollee.reconcile()
        #expect(!enrollee.migrationConfirmOwedByDerivation && enrollee.notice != .migrationConfirm)
    }

    /// pre-13x 2d: the migration's leg 6 marks the confirm for EVERY
    /// enrolled library that reached leg 5 (the vault in hand by then,
    /// after decision 35), and leg 5's line names the passphrase entry as
    /// where the descriptor lands when it is absent.
    @Test func theMigrationMarksTheConfirmForEveryEnrolledLibraryAndNamesThePassphraseEntry() async throws {
        let key = StoreKey.mint()
        let w = World()
        w.legacyPlain = material()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        w.envelope = envelope
        let report = await ProtectionMigration.run(
            facts: facts(key: key, effective: .auto, vault: false, vaultKDF: fastKDF()), leaves: w.leaves)
        #expect(report.masterCopyWritten && report.confirmPending && w.confirmPending && w.done)
        #expect(w.log.contains { $0.contains("+ the vault's descriptor") })
        #expect(!w.log.contains { $0.contains("next online ready") }, "the retired sentence")
    }

    // MARK: - The one-time confirm face's brain (copy §9)

    @Test func theConfirmVerifiesAgainstTheVaultThenReWrapsUnderItsDescriptor() async throws {
        let vaultKDF = fastKDF()
        let rewraps = LockIsolated<[(String, PassphraseKDF.Descriptor, String)]>([])
        let cleared = LockIsolated(false)
        let model = MigrationConfirmModel(
            verify: { passphrase in
                guard passphrase == "sesame" else { throw VaultEnrollmentError.wrongPassphrase }
                return (vaultKDF, "corpus-7")
            },
            rewrap: { passphrase, kdf, corpusKeyID in
                rewraps.withValue { $0.append((passphrase, kdf, corpusKeyID)) }
                return nil
            },
            clearPending: { cleared.setValue(true) })

        await model.confirm(passphrase: "not it")
        #expect(model.lastError == "Wrong encryption passphrase.")
        #expect(rewraps.value.isEmpty, "a typo writes NOTHING")
        #expect(!cleared.value && !model.done)

        await model.confirm(passphrase: "sesame")
        #expect(model.lastError == nil)
        #expect(rewraps.value.count == 1)
        #expect(rewraps.value.first?.1 == vaultKDF, "re-wrapped under the VAULT's descriptor")
        #expect(rewraps.value.first?.2 == "corpus-7")
        #expect(cleared.value && model.done)
    }

    /// The controller's half: the re-wrap lands under the vault's
    /// descriptor and records the reconciliation; the notice shows while
    /// pending, hides for the launch on Later, and clears on confirm.
    @Test func theControllerReWrapsUnderTheVaultDescriptorAndTheNoticeFollowsThePendingMark() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        let backing = InMemoryStoreKeyGuardBacking(gated: key, biometryAvailable: true, biometricSucceeds: true)
        let envelopeBox = ScriptedEnvelopeBox(envelope)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing, envelope: envelopeBox)
        let pending = LockIsolated(true)
        let controller = ProtectionController(configuration: .init(
            scope: "probe", storeURL: nil, gate: gate, isRealVariant: false,
            makeKDF: { self.fastKDF() }, storeID: { [id = envelope.storeID] in id }))
        controller.adoptResident(key)
        controller.readMigrationConfirmPending = { pending.value }
        controller.clearMigrationConfirmPending = { pending.setValue(false) }

        controller.refreshNotices()
        #expect(controller.notice == .migrationConfirm, "the one-time face shows while pending")
        controller.deferMigrationConfirm()
        #expect(controller.notice != .migrationConfirm, "Later hides it for this launch")
        #expect(pending.value, "…but the mark stays for the next ready")

        let vaultKDF = fastKDF()
        #expect(await controller.reconcilePassphraseWrap(
            passphrase: "sesame", vaultKDF: vaultKDF, corpusKeyID: "corpus-7") == nil)
        let written = try #require(envelopeBox.value)
        #expect(written.passphrase?.kdf == vaultKDF, "the local copy is under the VAULT's descriptor now")
        #expect(try written.unwrapKey(passphrase: "sesame") == key)
        #expect(written.vaultKDF == vaultKDF && written.vaultCorpusKeyID == "corpus-7")
        #expect(!pending.value, "the mark cleared")
        #expect(controller.notice != .migrationConfirm)
    }
}
