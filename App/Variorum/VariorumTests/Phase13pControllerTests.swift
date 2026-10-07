//
//  Phase13pControllerTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 4) — the ProtectionController's custody
//  choreography: the custody transitions under the custody law (a demanded
//  gate NEVER leaves a silently-releasing item behind — R13p-14's theater
//  prohibition made structural), the passphrase set + recovery landing
//  (knot 4), THE RESET DOOR'S RED PIN (R13p-9), the one-secret refusals,
//  the reconcile's foreign-sidecar set-aside, and the notice state machine.
//
//  pre-13x batch 2a — the POSTURE is derived (never a setting): a world is
//  scripted Standard by a key file carrying the Apple copy under the
//  scripted A, or Castle by a passphrase wrap without one (the derivation
//  `Posture.derive`, pinned in the brain suite). The mode transitions are
//  `moveCustody(to:)` — the primitive 2b's switches call — and Castle's
//  `setAlwaysAsk`, which moves BOTH custody items (the library key's and
//  the sync record's) in one act. The escrow arm is replaced by the APPLE
//  ARM: under Standard the reconcile reads A (else mints it), lands the key
//  file's Apple copy and VERIFIES it opens.
//
//  Everything runs through the scripted gate — no Keychain, no
//  LocalAuthentication, no prompts, anywhere.
//

import CryptoKit
import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// The sync record's custody leaves, recorded (the 17h R3-4 shape): what
/// each item HOLDS and which leaves ran, so the both-items pin can see
/// the twin move beside the library key's.
final class RecordingSyncLeaves: @unchecked Sendable {
    private let lock = NSLock()
    private var plain: SyncCustodyRecord?
    private var gated: SyncCustodyRecord?
    private var calls: [String] = []
    var deletesSucceed = true

    init(plain: SyncCustodyRecord? = nil, gated: SyncCustodyRecord? = nil) {
        self.plain = plain
        self.gated = gated
    }

    var plainRecord: SyncCustodyRecord? { lock.lock(); defer { lock.unlock() }; return plain }
    var gatedRecord: SyncCustodyRecord? { lock.lock(); defer { lock.unlock() }; return gated }
    var names: [String] { lock.lock(); defer { lock.unlock() }; return calls }
    func reset() { lock.lock(); calls = []; lock.unlock() }

    var leaves: E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { [self] record in
                lock.lock(); defer { lock.unlock() }
                calls.append("saveGated"); gated = record; return true
            },
            savePlain: { [self] record in
                lock.lock(); defer { lock.unlock() }
                calls.append("savePlain"); plain = record; return true
            },
            loadPlain: { [self] in
                lock.lock(); defer { lock.unlock() }
                calls.append("loadPlain"); return plain
            },
            gatedExists: { [self] in
                lock.lock(); defer { lock.unlock() }
                calls.append("gatedExists"); return gated != nil
            },
            deletePlain: { [self] in
                lock.lock(); defer { lock.unlock() }
                calls.append("deletePlain")
                guard deletesSucceed else { return false }
                plain = nil; return true
            },
            deleteGated: { [self] in
                lock.lock(); defer { lock.unlock() }
                calls.append("deleteGated")
                guard deletesSucceed else { return false }
                gated = nil; return true
            })
    }
}

@MainActor
@Suite("13p — the protection controller (custody choreography)")
struct Phase13pControllerTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private struct World {
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let appleKeys: InMemoryAppleKeyBacking
        let syncLeaves: RecordingSyncLeaves
        let syncSession: SyncCustodySession
        let dialsBox: ScriptedDialsBox
        let envelopeBox: ScriptedEnvelopeBox
        let stamps: ScriptedStampsBox
        let key: StoreKey
        /// The store's persisted dials (per store id) — hoisted so the
        /// `#expect` macro sees no optional chain inside the call.
        var storedDials: ProtectionDials {
            dialsBox.dials(for: envelopeBox.value?.storeID)
        }
    }

    private func material() -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data(repeating: 0, count: 32),
            corpusKey: Data(repeating: 1, count: 32), corpusKeyID: "corpus",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge")
    }

    /// A STANDARD world: the key file carries the Apple copy under the
    /// scripted A (the reconcile's steady state), the silent item holds
    /// the key. `standard: false` scripts CASTLE: a passphrase wrap, no
    /// Apple copy, the key behind the gate and resident (unlocked).
    private func world(
        standard: Bool = true,
        dials: ProtectionDials = ProtectionDials(),
        key: StoreKey = .mint(),
        biometryAvailable: Bool = true,
        biometricSucceeds: Bool = true,
        envelope: StoreKeyEnvelope? = nil,
        enrolled: Bool = false,
        isReal: Bool = true
    ) throws -> World {
        let apple = AppleKey.mint()
        let appleKeys = InMemoryAppleKeyBacking(key: apple)
        var scriptedEnvelope = envelope
        if scriptedEnvelope == nil {
            var fresh = StoreKeyEnvelope()
            if standard {
                try fresh.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            } else {
                try fresh.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
            }
            scriptedEnvelope = fresh
        }
        let backing = InMemoryStoreKeyGuardBacking(
            auto: standard ? key : nil,
            gated: standard ? nil : key,
            biometryAvailable: biometryAvailable,
            biometricSucceeds: biometricSucceeds)
        let dialsBox = ScriptedDialsBox(dials)
        let envelopeBox = ScriptedEnvelopeBox(scriptedEnvelope)
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing, envelope: envelopeBox, stamps: stamps,
            appleKey: appleKeys)
        let syncSession = SyncCustodySession()
        let record = SyncCustodyRecord(deviceID: "device-1", material: enrolled ? material() : nil)
        let syncLeaves = RecordingSyncLeaves(
            plain: standard ? record : SyncCustodyRecord(deviceID: "device-1", material: nil),
            gated: standard || !enrolled ? nil : record)
        if !standard, enrolled { syncSession.hold(record) }
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate,
            isRealVariant: isReal,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) },
            storeID: { [storeID = scriptedEnvelope?.storeID] in storeID },
            syncCustodyLeaves: { _ in syncLeaves.leaves },
            syncCustodySession: syncSession))
        // pre-13x 2d: the bootstrap adopts the unlocked key on every road —
        // nil on the silent one — so the custody SHAPE is in view (corner 45).
        controller.adoptResident(standard ? nil : key)
        return World(
            controller: controller, backing: backing, appleKeys: appleKeys,
            syncLeaves: syncLeaves, syncSession: syncSession, dialsBox: dialsBox,
            envelopeBox: envelopeBox, stamps: stamps, key: key)
    }

    // MARK: - The posture projection

    @Test func thePostureIsDerivedFromTheKeyFileAndTheVault() async throws {
        let standard = try world()
        #expect(standard.controller.posture == .standard)
        #expect(standard.controller.effectiveGate == .auto)
        let castle = try world(standard: false)
        #expect(castle.controller.posture == .castle)
        #expect(castle.controller.effectiveGate == .biometric)
        let alwaysAsk = try world(standard: false, dials: ProtectionDials(alwaysAsk: true))
        #expect(alwaysAsk.controller.effectiveGate == .passphrase)

        // The vault's word outranks the key file once read (decision 8).
        castle.controller.readVaultPosture = {
            VaultPostureReading(hasAppleHeldCopy: true, appleKeyID: "a")
        }
        await castle.controller.reconcile()
        #expect(castle.controller.posture == .standard,
                "an enrolled library follows the account — the reconcile READ; the act is 2c's")
    }

    // MARK: - The passphrase + phrase artifacts

    @Test func setPassphraseLandsTheWrapAndStamps() async throws {
        let w = try world()
        #expect(!w.controller.hasPassphraseWrap)
        #expect(await w.controller.setPassphrase("sesame") == nil)
        #expect(w.controller.hasPassphraseWrap)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "sesame") == w.key)
        #expect(w.stamps.value[ProtectionController.passphraseSetAtStamp] != nil)
        #expect(w.controller.posture == .standard,
                "setting a passphrase under Standard keeps Standard — the Apple copy stands")
    }

    @Test func generateAndLandRecoveryPhraseShowsTwelveWordsThatUnwrap() async throws {
        let w = try world()
        let words = try #require(await w.controller.generateAndLandRecoveryPhrase())
        #expect(words.count == 12)
        #expect(w.controller.hasRecoveryWrap)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key)
    }

    // MARK: - The custody law (the moves)

    @Test func demandedGatesNeedThePassphraseFirst() async throws {
        let w = try world()
        #expect(await w.controller.moveCustody(to: .biometric) == .needsPassphrase)
        #expect(await w.controller.moveCustody(to: .passphrase) == .needsPassphrase)
        #expect(w.backing.auto != nil, "a refused transition changes nothing")
    }

    /// THE HANDOVER PIN (the brief's item 1): a move into the gated shape
    /// carries BOTH custody items — the library key's item AND the sync
    /// record's — in one act. RED ON OLD: the pre-2a `setMode` moved the
    /// store key alone; the sync record stayed in the plain item.
    @Test func aMoveIntoTheGateMovesTheLibraryKeyAndTheSyncRecordTogether() async throws {
        let w = try world(enrolled: true)
        _ = await w.controller.setPassphrase("sesame")
        w.syncLeaves.reset()
        #expect(await w.controller.moveCustody(to: .biometric) == .changed)
        #expect(w.backing.gated == w.key, "the gated item carries the library key")
        #expect(w.backing.auto == nil,
                "the silent item is GONE — a gate whose key still releases silently is theater (R13p-14)")
        #expect(w.syncLeaves.gatedRecord?.material != nil,
                "the sync record moved behind the gate WITH the library key")
        #expect(w.syncLeaves.plainRecord?.material == nil,
                "…and its plain item is identity-only now")
        #expect(w.syncLeaves.plainRecord?.deviceID == "device-1", "the identity stays")
        #expect(w.syncSession.record?.material != nil, "the session that moved stays unlocked")
    }

    /// 13p-fix R1-1, THE RED-ON-OLD PIN: the transition must prove the
    /// incoming custody READS BACK before releasing the outgoing one.
    @Test func aGatedWriteThatCannotBeReadBackRefusesInsteadOfDestroyingTheSilentItem() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.gatedWritesAreInvisible = true

        #expect(await w.controller.moveCustody(to: .biometric) != .changed,
                "a gated item nothing can find is not a landed gate")
        #expect(w.backing.auto == w.key,
                "the ONLY reachable copy of the key survives the refusal")
    }

    @Test func passphraseGateLeavesNoSilentCustodyAtAll() async throws {
        let w = try world(enrolled: true)
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.moveCustody(to: .passphrase) == .changed)
        #expect(w.backing.auto == nil)
        #expect(w.backing.gated == nil)
        #expect(w.syncLeaves.gatedRecord == nil, "no gated sync item under Always ask")
        #expect(w.syncLeaves.plainRecord?.material == nil, "the plain item is identity-only")
        #expect(w.syncSession.record?.material != nil,
                "the sync keys live in SESSION MEMORY under Always ask (decision 10)")
    }

    @Test func backToAutoRestoresTheSilentItemAndDropsTheGate() async throws {
        let w = try world(standard: false, enrolled: true)
        #expect(await w.controller.moveCustody(to: .auto) == .changed)
        #expect(w.backing.auto == w.key)
        #expect(w.backing.gated == nil)
        #expect(w.syncLeaves.plainRecord?.material != nil, "the sync record is silent again")
        #expect(w.syncLeaves.gatedRecord == nil)
    }

    /// A refused sync-record move REVERSES the library key's move — the
    /// two families never disagree about the shape.
    @Test func aRefusedSyncRecordMoveReversesTheLibraryKeysMove() async throws {
        let w = try world(enrolled: true)
        _ = await w.controller.setPassphrase("sesame")
        w.syncLeaves.deletesSucceed = false  // the plain→gated move cannot release... the gated
        // The gated shape's outgoing act is the identity-only rewrite (a
        // save, which succeeds); Always ask's outgoing act is the gated
        // delete — script that refusal.
        guard case .refused = await w.controller.moveCustody(to: .passphrase) else {
            // The passphrase move from Standard deletes the gated item,
            // which is absent: released trivially. Script the biometric →
            // passphrase road instead, where the gated item exists.
            w.syncLeaves.deletesSucceed = true
            #expect(await w.controller.moveCustody(to: .biometric) == .changed)
            w.syncLeaves.deletesSucceed = false
            w.backing.deletesSucceed = true
            let outcome = await w.controller.moveCustody(to: .passphrase)
            guard case .refused = outcome else {
                Issue.record("expected the sync half's refusal to back the move out, got \(outcome)")
                return
            }
            #expect(w.backing.gated == w.key,
                    "the library key's move was REVERSED — back behind the gate")
            #expect(w.syncLeaves.gatedRecord != nil, "the sync record never left the gate")
            return
        }
    }

    @Test func biometricGateRefusesWhereTheHardwareIsAbsent() async throws {
        let w = try world(biometryAvailable: false)
        _ = await w.controller.setPassphrase("sesame")
        guard case .refused(let message) = await w.controller.moveCustody(to: .biometric) else {
            Issue.record("expected a refusal")
            return
        }
        #expect(message.contains("no Touch ID"))
        #expect(message.contains("Always ask"), "the road that exists is named")
    }

    // MARK: - Castle's switches

    /// ALWAYS ASK (copy §1): Castle's first switch moves both items and
    /// persists the dial; in Standard it refuses (no gate exists there).
    @Test func alwaysAskMovesBothItemsAndPersistsTheDialInCastleOnly() async throws {
        let standard = try world()
        guard case .refused = await standard.controller.setAlwaysAsk(true) else {
            Issue.record("Always ask is a Castle switch")
            return
        }
        #expect(!standard.storedDials.alwaysAsk)

        let castle = try world(standard: false, enrolled: true)
        #expect(castle.controller.effectiveGate == .biometric)
        #expect(await castle.controller.setAlwaysAsk(true) == .changed)
        #expect(castle.controller.effectiveGate == .passphrase)
        #expect(castle.storedDials.alwaysAsk, "the dial persisted")
        #expect(castle.backing.gated == nil && castle.backing.auto == nil, "no key item at all")
        #expect(castle.syncLeaves.gatedRecord == nil, "the sync record left the gate too")
        #expect(castle.syncSession.record?.material != nil, "…for the session")

        #expect(await castle.controller.setAlwaysAsk(false) == .changed)
        #expect(castle.controller.effectiveGate == .biometric)
        #expect(castle.backing.gated == castle.key)
        #expect(castle.syncLeaves.gatedRecord?.material != nil, "the sync record is behind the gate again")
    }

    @Test func theIdleDialPersistsPerStore() throws {
        let w = try world(standard: false)
        #expect(w.controller.dials.relockAfterIdleMinutes == 10, "the design's default")
        w.controller.setRelockIdleMinutes(30)
        #expect(w.storedDials.relockAfterIdleMinutes == 30)
        w.controller.setRelockIdleMinutes(nil)
        #expect(w.storedDials.relockAfterIdleMinutes == nil)
    }

    // MARK: - THE APPLE ARM (the reconcile — §3.8; the brief's item 2)

    /// Under Standard with the key in hand: A is READ (else minted), the
    /// key file gains its Apple copy under A's id, and the leg is VERIFIED
    /// by the read-back's unwrap — never the write's own word. RED ON OLD:
    /// the pre-2a reconcile wrote the RAW key to the escrow item instead.
    @Test func reconcileLandsTheAppleCopyAndVerifiesItOpens() async throws {
        let key = StoreKey.mint()
        var stub = StoreKeyEnvelope(keyFingerprint: StoreKeyEnvelope.fingerprint(of: key))
        try stub.setRecoveryWrap(key: key, words: try RecoveryPhrase.generate())
        let w = try world(key: key, envelope: stub)
        w.appleKeys.key = nil  // no A on this iCloud yet — the first Standard library mints it
        #expect(w.controller.appleKeyVerified == nil, "unknown until a reconcile runs")
        await w.controller.reconcile()
        let minted = try #require(w.appleKeys.key, "A was minted")
        let envelope = try #require(w.envelopeBox.value)
        #expect(envelope.appleKeyID == minted.id)
        #expect(try envelope.unwrapKey(apple: minted.symmetricKey) == key,
                "the key file's Apple copy opens with A")
        #expect(w.controller.appleKeyVerified == true)
        #expect(!w.controller.appleKeyLandingFailed)
        #expect(w.stamps.value[ProtectionController.firstUseStamp] != nil)

        // Steady state: nothing rewritten, still verified.
        let before = w.envelopeBox.value
        await w.controller.reconcile()
        #expect(w.envelopeBox.value == before)
        #expect(w.controller.appleKeyVerified == true)
    }

    /// A REFUSED A write is a NOT-landed net, said so — never "covered".
    @Test func aRefusedAppleKeyWriteReadsAsNotLandedNeverCovered() async throws {
        let key = StoreKey.mint()
        let stub = StoreKeyEnvelope(keyFingerprint: StoreKeyEnvelope.fingerprint(of: key))
        let w = try world(key: key, envelope: stub)
        w.appleKeys.key = nil
        w.appleKeys.writesSucceed = false
        await w.controller.reconcile()
        #expect(w.controller.appleKeyVerified == false)
        #expect(w.controller.appleKeyLandingFailed)
        #expect(w.controller.legs.tier == .exposed,
                "Standard + no secrets + no Apple copy IS the exposed state copy §5 hardens the nudge for")
        #expect(w.envelopeBox.value?.apple == nil, "no copy was written under a key that did not land")
    }

    /// Under CASTLE no copy opens with A (§3.2) and A is never touched.
    @Test func reconcileUnderCastleNeverTouchesTheAppleKey() async throws {
        let w = try world(standard: false)
        w.appleKeys.key = nil
        await w.controller.reconcile()
        #expect(w.appleKeys.key == nil, "nothing minted under Castle")
        #expect(w.envelopeBox.value?.apple == nil)
        #expect(w.controller.appleKeyVerified == false)
        #expect(w.controller.posture == .castle)
    }

    /// The Apple arm runs on EVERY variant (A is per scope by construction
    /// — the dev build mints and reads its own).
    @Test func theAppleArmRunsOnTheDevVariantToo() async throws {
        let key = StoreKey.mint()
        let stub = StoreKeyEnvelope(keyFingerprint: StoreKeyEnvelope.fingerprint(of: key))
        let w = try world(key: key, envelope: stub, isReal: false)
        w.appleKeys.key = nil
        await w.controller.reconcile()
        #expect(w.appleKeys.key != nil)
        #expect(w.controller.appleKeyVerified == true)
    }

    /// A key file whose Apple copy is under ANOTHER A (a different Apple
    /// ID minted it) is re-landed under this device's A — the client
    /// VERIFIES the id, never adopts a key it cannot open with.
    @Test func anAppleCopyUnderAnotherIDIsReLandedUnderThisDevicesA() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "someone-elses")
        let w = try world(key: key, envelope: envelope)
        await w.controller.reconcile()
        let mine = try #require(w.appleKeys.key)
        #expect(w.envelopeBox.value?.appleKeyID == mine.id)
        #expect(w.controller.appleKeyVerified == true)
    }

    // MARK: - pre-13x ladder round 1, F2 (MAJOR-3 as REFINED): the iCloud key
    // is minted only by a device holding the master; the heal on proof

    /// A Standard vault reading for the Apple-arm pins: the account's copy
    /// is under `appleKeyID`; a corpus key id that matches nothing recorded
    /// keeps the follow road quiet.
    private func standardReading(appleKeyID: String) throws -> VaultPostureReading {
        let kdf = fastKDF()
        let master = SymmetricKey(size: .bits256)
        var format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: try PassphraseKDF.deriveKey(passphrase: "account-sesame", descriptor: kdf),
            recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "corpus-f2", key: SymmetricKey(size: .bits256)),
                        (keyClass: .journalBridge, keyID: "bridge-f2", key: SymmetricKey(size: .bits256))],
            kdf: kdf)
        // The account's copy under A₁ — whose BYTES this device never holds.
        format = try format.settingAppleHeldCopy(
            masterKey: master, appleKey: SymmetricKey(size: .bits256), appleKeyID: appleKeyID)
        return VaultPostureReading(
            hasAppleHeldCopy: true, appleKeyID: appleKeyID,
            passphraseKDF: kdf, hasPassphraseWrap: true,
            corpusKeyID: "corpus-f2", updatedAt: "2026-09-06T00:00:00Z",
            updatedByDevice: "Lillian's Mac", signedInUserID: "user-1",
            hasRecoveryWrap: false, format: format)
    }

    /// (a) RED ON OLD: a signed-in library under a Standard vault naming A₁,
    /// A not readable here, NO master in hand ⇒ nothing is minted — the arm
    /// WAITS (before F2 `readOrMint` minted A₂ beside the account's A₁ under
    /// propagation lag, and iCloud kept one of the two).
    @Test func aStandardVaultNamingAKeyThisDeviceCannotReadMintsNothingWithoutTheMaster() async throws {
        let w = try world(standard: true, enrolled: false)
        w.appleKeys.key = nil  // propagation lag: the account's A₁ has not arrived
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        w.controller.landEnrollment = { _, _ in false }
        await w.controller.reconcile()
        #expect(w.appleKeys.key == nil, "NOTHING minted — a mint here would duplicate the account's iCloud key")
        #expect(w.controller.appleKeyWaiting, "the arm waits")
        #expect(w.controller.appleKeyVerified == false && !w.controller.appleKeyLandingFailed,
                "not landed, not refused — waiting")
        #expect(w.controller.enrollReading?.appleState == .absent, "the waiting face speaks (its passphrase doors act)")
        // F3 (NIT-N8): a device merely WAITING is not EXPOSED — the legs'
        // tier says so, and the nudge brain speaks copy §2d's waiting line
        // (before F3 the tier read `.exposed` and the pane told a device
        // whose key was on its way to write its words down as if unguarded).
        #expect(w.controller.legs.appleKeyWaiting && w.controller.legs.tier == .waiting, "\(w.controller.legs.tier)")
        #expect(ProtectionCopy.nudgeSentence(for: w.controller.legs.tier) == ProtectionCopy.waitingTitle + " " + ProtectionCopy.waitingBody)
        // The next ready with A₁ landed: the silent road, nothing minted.
        let arrived = AppleKey(id: "a1-the-accounts", key: AppleKey.mint().key)
        w.appleKeys.key = arrived
        await w.controller.reconcile()
        #expect(w.appleKeys.key == arrived && !w.controller.appleKeyWaiting)
        #expect(w.controller.legs.tier != .waiting, "landed: no longer waiting")
    }

    /// (a) A device HOLDING the master (it enrolled by a typed secret) that
    /// still reads no A mints one and lands ITS OWN FILE's copy under it —
    /// the vault's copy untouched (a different Apple ID's device keeps the
    /// account's vault under the first Apple ID's A — corner 34).
    @Test func aDeviceHoldingTheMasterMintsAndLandsItsOwnFileCopyLeavingTheVaultsCopyAlone() async throws {
        let w = try world(standard: true, enrolled: true)
        w.appleKeys.key = nil
        let healed = LockIsolated<[String]>([])
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        w.controller.healAppleHeldCopy = { apple in healed.withValue { $0.append(apple.id) }; return true }
        await w.controller.reconcile()
        let minted = try #require(w.appleKeys.key, "holding M, the device mints its A")
        #expect(minted.id != "a1-the-accounts")
        #expect(w.envelopeBox.value?.appleKeyID == minted.id, "ITS file copy under the minted key")
        #expect(try w.envelopeBox.value?.unwrapKey(apple: minted.symmetricKey) == w.key)
        #expect(healed.value.isEmpty, "the vault's copy is NEVER written from a mint")
        #expect(w.controller.appleKeyVerified == true && !w.controller.appleKeyWaiting)
    }

    /// (c) THE HEAL, on proof: this device's key file records the vault's
    /// id AND iCloud Keychain now hands back a different key — only the
    /// same Apple account can have replaced the key this device minted —
    /// so, holding M, the vault's copy is re-landed FIRST under the
    /// readable A, then the file's copy. RED ON OLD: the file re-landed and
    /// the vault's copy stayed under a key iCloud no longer holds.
    @Test func aSameAccountDuplicateIsHealedOnProofVaultFirstThenTheFile() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a1-the-accounts")
        let w = try world(standard: true, key: key, envelope: envelope, enrolled: true)
        let replacedByICloud = AppleKey.mint()  // A₂ — what the Keychain now holds
        w.appleKeys.key = replacedByICloud
        let healed = LockIsolated<[String]>([])
        let fileAtHeal = LockIsolated<String?>(nil)
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        w.controller.healAppleHeldCopy = { [box = w.envelopeBox] apple in
            healed.withValue { $0.append(apple.id) }
            fileAtHeal.setValue(box.value?.appleKeyID)  // the file's copy at the moment of the vault write
            return true
        }
        await w.controller.reconcile()
        #expect(healed.value == [replacedByICloud.id], "ONE proof-authorized vault write, under the readable A")
        #expect(fileAtHeal.value == "a1-the-accounts", "the vault FIRST — the file still recorded the old id at the write")
        #expect(w.envelopeBox.value?.appleKeyID == replacedByICloud.id, "then the file's copy under A₂")
        #expect(try w.envelopeBox.value?.unwrapKey(apple: replacedByICloud.symmetricKey) == key)
        #expect(w.controller.appleKeyVerified == true)

        // A refused vault write leaves the file's copy as recorded — the
        // proof survives for the next ready (offline: the heal retries).
        let offline = try world(standard: true, key: key, envelope: envelope, enrolled: true)
        offline.appleKeys.key = replacedByICloud
        offline.controller.isSignedIn = { true }
        offline.controller.foreignOwner = { _ in false }
        offline.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        offline.controller.healAppleHeldCopy = { _ in false }
        await offline.controller.reconcile()
        #expect(offline.envelopeBox.value?.appleKeyID == "a1-the-accounts", "the file's copy is left as recorded")
        #expect(offline.controller.appleKeyVerified == false && !offline.controller.appleKeyLandingFailed)
    }

    /// (c) NO proof ⇒ no vault write: a device whose recorded id is NOT the
    /// vault's (a different Apple ID's device — corner 34; or a file
    /// already re-landed) re-lands only its own file copy under what it
    /// reads, as before, and never touches the account's Apple-held copy.
    @Test func aRecordedIdThatIsNotTheVaultsNeverWritesTheVault() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a0-this-devices-old")
        let w = try world(standard: true, key: key, envelope: envelope, enrolled: true)
        let mine = AppleKey.mint()
        w.appleKeys.key = mine
        let healed = LockedCounter()
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        w.controller.healAppleHeldCopy = { _ in healed.increment(); return true }
        await w.controller.reconcile()
        #expect(healed.value == 0, "no proof of a same-account duplicate — the vault is never written")
        #expect(w.envelopeBox.value?.appleKeyID == mine.id, "its own file copy under what it reads")
        #expect(w.controller.appleKeyVerified == true)
    }

    /// pre-13x ladder round 2, F3 (MINOR-N1 — option A, the refined rule
    /// (c)'s LETTER): a MINT is never proof. This device's key file records
    /// the vault's id (it established the account's A, or landed under it),
    /// it holds M, and iCloud Keychain now READS NOTHING (a same-account
    /// Keychain reset — or the device signed into ANOTHER Apple ID, which
    /// the client cannot tell apart): it mints A′ for ITS OWN file only;
    /// the vault's Apple-held copy is NEVER re-landed from a mint. RED ON
    /// OLD: the heal was handed the minted key and re-homed the account's
    /// copy under it — silently, under whichever Apple account this device
    /// now held (Ch.2 s25 false in that corner).
    @Test func aMintNeverHealsTheVaultEvenWhenTheFileRecordsTheVaultsId() async throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a1-the-accounts")
        let w = try world(standard: true, key: key, envelope: envelope, enrolled: true)
        w.appleKeys.key = nil  // the Keychain reads nothing: a reset, or another Apple ID
        let healed = LockIsolated<[String]>([])
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [r = try self.standardReading(appleKeyID: "a1-the-accounts")] in r }
        w.controller.healAppleHeldCopy = { apple in healed.withValue { $0.append(apple.id) }; return true }
        await w.controller.reconcile()
        let minted = try #require(w.appleKeys.key, "holding M and reading nothing, the device mints A′")
        #expect(minted.id != "a1-the-accounts")
        #expect(healed.value.isEmpty, "the vault's copy is NEVER written from a mint — a mint proves no same-account duplicate")
        #expect(w.envelopeBox.value?.appleKeyID == minted.id, "ITS OWN file copy under the mint")
        #expect(try w.envelopeBox.value?.unwrapKey(apple: minted.symmetricKey) == key)
        #expect(w.controller.appleKeyVerified == true && !w.controller.appleKeyWaiting)
    }

    // MARK: - THE RESET DOOR (R13p-9) — pre-13x 3b: MERGED into change
    // passphrase's forgot road (`KeyDoorModel`; the pins in `KeyDoorTests`:
    // the biometric confirm required in Castle, a refused confirm changing
    // nothing, the words road under Always ask, the vault half's failure
    // refusing whole). The controller's own `resetPassphrase` retired.

    // MARK: - One secret, both directions

    @Test func verifyAgainstStoreAnswersOnlyWhereAWrapExists() async throws {
        let w = try world()
        #expect(await w.controller.verifyPassphraseAgainstStore("anything") == nil)
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.verifyPassphraseAgainstStore("sesame") == true)
        #expect(await w.controller.verifyPassphraseAgainstStore("wrong") == false)
    }

    // pre-13x 3b: `followVaultPassphrase` (the 13p fresh-descriptor road)
    // RETIRED — a passphrase change lands the key file's copy under the
    // VAULT's descriptor through `landVaultMaterial` (pinned below in
    // `landingTheVaultMaterialWritesTheMasterCopyAndReconcilesUnderTheVaultsDescriptor`).

    @Test func aForeignSidecarIsSetAsideNeverOverwrittenInPlace() async throws {
        let foreignKey = StoreKey.mint()
        var foreign = StoreKeyEnvelope()
        try foreign.setPassphraseWrap(key: foreignKey, passphrase: "theirs", kdf: fastKDF())
        let w = try world(envelope: foreign)
        #expect(await w.controller.setPassphrase("mine") == nil)
        #expect(w.envelopeBox.setAsideCount == 1, "the foreign sidecar was moved aside")
        let fresh = try #require(w.envelopeBox.value)
        #expect(fresh.storeID != foreign.storeID, "a fresh envelope, fresh identity")
        #expect(try fresh.unwrapKey(passphrase: "mine") == w.key)
    }

    // MARK: - Notices

    @Test func noticesFollowThePolicies() async throws {
        let w = try world()
        let now = Date()
        // Fresh install: first use just stamped ⇒ no nudge yet.
        await w.controller.reconcile(now: now)
        #expect(w.controller.notice == nil)
        // A day later: the nudge (no artifacts yet).
        w.controller.refreshNotices(now: now.addingTimeInterval(2 * 24 * 3600))
        #expect(w.controller.notice == .nudge)
        // Snooze holds it.
        w.controller.snoozeNudge(now: now.addingTimeInterval(2 * 24 * 3600))
        #expect(w.controller.notice == nil)
        // Both artifacts land ⇒ the nudge never returns.
        _ = await w.controller.setPassphrase("sesame")
        _ = await w.controller.generateAndLandRecoveryPhrase()
        w.controller.refreshNotices(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(w.controller.notice != .nudge)

        // The reminder: CASTLE + a stale passphrase stamp ⇒ due (always on
        // in Castle, §13 — no dial).
        let castle = try world(standard: false)
        _ = await castle.controller.setPassphrase("sesame")
        castle.controller.refreshNotices(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(castle.controller.notice == .reminderDue)
        castle.controller.recordReminderConfirmed(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(castle.controller.notice == nil)
        #expect(w.controller.notice != .reminderDue, "Standard has no reminder — the nudge covers it")
    }

    // MARK: - The reminder's local check (one face — SecretCheck's road)

    @Test func theStoreSecretCheckRunsTheRealUnwrapAndDiscards() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        let words = try #require(await w.controller.generateAndLandRecoveryPhrase())
        let check = w.controller.makeStoreSecretCheck()
        #expect(await check(.passphrase, "sesame") == .correct)
        #expect(await check(.passphrase, "wrong") == .wrong)
        #expect(await check(.recoveryPhrase, words.joined(separator: " ")) == .correct)
        guard case .couldNotCheck = await check(.recoveryPhrase, "only three words") else {
            Issue.record("a malformed phrase is couldNotCheck, never wrong")
            return
        }
        let model = SecretCheckModel(
            client: nil, storeCheck: check, targetNoun: "this library's key")
        #expect(model.isAvailable)
        await model.check(.passphrase, entry: "sesame")
        #expect(model.result == .correct(.passphrase))
        #expect(model.message(for: .correct(.passphrase)).contains("this library's key"))
    }

    // MARK: - The nudge's direct phrase offer (ladder R2-m1)

    @Test func thePhraseOfferExtendsAnExistingVaultPhraseInsteadOfMintingASecond() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(!w.controller.hasRecoveryWrap, "the offer's own render gate")

        let vaultTie = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { _ in .match },
            verifyRecoveryWords: { _ in .match })
        let outcome = await PhraseOffer.take(
            controller: w.controller, vaultTie: vaultTie)
        guard case .extend(let model) = outcome else {
            Issue.record("a vault with the twelve words must route to the extend flow")
            return
        }
        #expect(model.phase == .extendExistingPhrase)
        #expect(!w.controller.hasRecoveryWrap, "NO second phrase was minted over the account's")
        #expect(w.envelopeBox.value?.recovery == nil)

        let words = try RecoveryPhrase.generate()
        await model.extendPhrase(typed: words.joined(separator: " "))
        #expect(model.lastError == nil)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key)

        let free = try world()
        _ = await free.controller.setPassphrase("sesame")
        let minted = await PhraseOffer.take(controller: free.controller, vaultTie: nil)
        guard case .minted(let fresh) = minted else {
            Issue.record("no vault ⇒ the fresh mint, unchanged")
            return
        }
        #expect(fresh.count == 12)
        #expect(free.controller.hasRecoveryWrap)
    }

    // MARK: - RUN A batch A2, row 15 — the phrase-transit corner (KnownIssues 32)

    /// **THE VERIFICATION KnownIssues 32 ASKS FOR, and the one world it
    /// still has.** The corner: `PhraseOffer.take` gates its fresh mint on
    /// `vaultTie.hasRecoveryWrap` alone, so a world where a vault EXISTS but
    /// reports no recovery wrap gets twelve STORE-ONLY words — which the
    /// account's own generation later overwrites, retiring the first phrase
    /// she wrote down with nothing said.
    ///
    /// Traced through every arm of `VaultTie.make`, that world needs a vault
    /// whose `masterWrappedByRecovery` is nil — and after pre-13x's 3a no
    /// production road can make one (`EncryptionSession.setUp(passphrase:
    /// recoveryWords:)` is the only creation door the app calls, and it
    /// births the wrap; `EncryptionFlowTests.setUpEnrollsThisDeviceAndFires
    /// TheHealingHook` pins the birth, and core's wrap-free
    /// `VaultEnrollment.setUp(passphrase:)` has no caller outside tests) —
    /// **except one: `.newerFormat`**, a vault this build cannot READ, whose
    /// tie is built with `hasRecoveryWrap: false` and verifies that refuse.
    /// There the offer minted a second secret under a vault it could not
    /// consult, which is exactly what the tie's own doctrine forbids for the
    /// passphrase ("the tie refuses rather than letting a second passphrase
    /// slip in under the unreadable one").
    ///
    /// The passphrase door cannot reach the corner — `commit` refuses on
    /// `.couldNotCheck` before `advanceToPhraseHalf` runs, and that half is
    /// private to it. The NUDGE'S DIRECT OFFER is the one door that starts
    /// at the phrase half, which is why the fix is there and nowhere else.
    ///
    /// **Arms 1 and 2 are the VERIFICATION (green either side — the row's own
    /// success criterion); arm 3 is RED ON OLD.**
    @Test func theStoreOnlyPhraseTransitHasNoWorldLeftExceptAVaultThisBuildCannotRead() async throws {
        // 1 — the world every road now produces: a vault WITH the words.
        let tied = try world()
        _ = await tied.controller.setPassphrase("sesame")
        let carrying = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { _ in .match }, verifyRecoveryWords: { _ in .match })
        guard case .extend = await PhraseOffer.take(controller: tied.controller, vaultTie: carrying) else {
            Issue.record("a vault carrying the words routes to the extend flow")
            return
        }
        #expect(!tied.controller.hasRecoveryWrap, "nothing store-only was minted")

        // 2 — no vault constrains: the store mints its own, as designed.
        let free = try world()
        _ = await free.controller.setPassphrase("sesame")
        guard case .minted = await PhraseOffer.take(controller: free.controller, vaultTie: nil) else {
            Issue.record("no vault ⇒ the store's own phrase, unchanged")
            return
        }
        #expect(free.controller.hasRecoveryWrap)

        // 3 — THE ONE REMAINING WORLD: a vault present and unreadable.
        let blind = try world()
        _ = await blind.controller.setPassphrase("sesame")
        let unreadable = VaultTie(
            hasRecoveryWrap: false,
            verifyPassphrase: { _ in .couldNotCheck(Self.newerVaultReason) },
            verifyRecoveryWords: { _ in .couldNotCheck(Self.newerVaultReason) },
            unreadableReason: Self.newerVaultReason)
        let outcome = await PhraseOffer.take(controller: blind.controller, vaultTie: unreadable)
        guard case .refused = outcome else {
            Issue.record("a vault this build cannot read must not get a second secret minted under it: \(outcome)")
            return
        }
        #expect(!blind.controller.hasRecoveryWrap, "nothing landed on the store")
        #expect(blind.envelopeBox.value?.recovery == nil, "and nothing on the key file")
        #expect(blind.controller.lastError?.contains(Self.newerVaultReason) == true,
                "and it says why: \(blind.controller.lastError ?? "nil")")
    }

    /// The `.newerFormat` tie's own reason, as `VaultTie.make` words it.
    private static let newerVaultReason =
        "your account's vault was written by a newer Variorum — update the app"

    // MARK: - RUN A batch A2, row 14 — the encryption passphrase's floor (17n)

    /// **THE FLOOR AT THE SETTING DOORS, AND NEVER AT UNLOCK** (her ruling
    /// 2026-09-07 ~02:30: *"we can make the encryption passphrase
    /// requirement 12 characters as well"*). The 12-character floor shipped
    /// at pre-13x 3b was the ACCOUNT password's; three encryption-passphrase
    /// doors picked one up along the way and are pinned in their own suites
    /// (`KeyDoorTests` · `PostureSwitchTests` · `SyncEnrollmentTests`). This
    /// pin holds the two that had NONE and the two that must never have one.
    ///
    /// `PassphraseSetModel` is FOUR door sites — Settings ▸ Protection and
    /// the nudge's offer on the Mac, the nudge's offer and the Protection
    /// sheet on the phone — so its gap was the widest, and one model closes
    /// it on both platforms.
    ///
    /// **RED ON OLD: a five-character passphrase was accepted and landed.**
    @Test func theEncryptionPassphraseFloorBindsWhereItIsSetAndNowhereElse() async throws {
        let short = "sesame"  // six
        #expect(short.count < ProtectionCopy.passphraseFloor)

        // (1) THE SET SHEET — the gap this row closes.
        let w = try world()
        let sheet = PassphraseSetModel(controller: w.controller, vaultTie: nil)
        await sheet.commit(passphrase: short, confirmation: short)
        #expect(sheet.lastError == ProtectionCopy.passphraseTooShort)
        #expect(sheet.phase == .enterPassphrase, "nothing advanced")
        #expect(!w.controller.hasPassphraseWrap, "and nothing landed on the key file")
        // The same door with a long enough word goes through.
        await sheet.commit(passphrase: "a-long-enough-passphrase", confirmation: "a-long-enough-passphrase")
        #expect(sheet.lastError == nil)
        #expect(w.controller.hasPassphraseWrap)

        // (2) NEVER AT UNLOCK: a word already on the key file keeps opening
        // the library whatever its length. The primitive has no floor by
        // design — the doors do — so a short word set before this build (or
        // by the migration's re-wrap) is not locked out by it.
        let old = try world()
        #expect(await old.controller.setPassphrase(short) == nil, "the primitive sets it")
        #expect(await old.controller.verifyPassphraseAgainstStore(short) == true,
                "and it still opens — the floor is about SETTING, never about opening")

        // (3) THE MIGRATION'S CONFIRM is not a setting door: it verifies an
        // EXISTING passphrase against the vault and re-wraps under it, so a
        // floor there would refuse her own shorter word at the one moment
        // she must not be refused.
        let rewrapped = LockIsolated<String?>(nil)
        let confirm = MigrationConfirmModel(
            verify: { _ in (kdf: PassphraseKDF.Descriptor.v1(salt: PassphraseKDF.randomSalt()),
                            corpusKeyID: "corpus-1", recoveryWrapDigest: nil) },
            rewrap: { passphrase, _, _, _ in rewrapped.setValue(passphrase); return nil },
            clearPending: {})
        await confirm.confirm(passphrase: short)
        #expect(confirm.lastError == nil && confirm.done)
        #expect(rewrapped.value == short, "the short existing word was re-wrapped, not refused")
    }

    // MARK: - RUN A batch A2, row 11 — the ceremony's root presenter (KnownIssues 40)

    /// **THE DEAD REPLACE-ALL-KEYS DOOR, and the two presenters that
    /// replace it.** The author pressed *Replace All Keys* from the main
    /// window's *Account…* sheet and got a standalone button and no
    /// ceremony: the door set `activeSwitch`, whose only Mac presenter was
    /// Settings ▸ Protection, so from the main window the sheet never
    /// appeared and a second press was a no-op behind `openSwitch`'s own
    /// guard. Nothing was ever written (the vault was verified untouched
    /// live), which is why this is a presenter defect and not a key one.
    ///
    /// The host is decided ONCE, at `openSwitch`, from whether a Protection
    /// pane is on screen — so the main window's notice bar presents the
    /// ceremonies opened from the main window, Settings presents its own,
    /// and **double presentation cannot happen**, including when the
    /// Settings window is opened DURING a root-hosted ceremony (which a
    /// per-frame rule would answer by tearing the sheet out of the window
    /// the author is looking at).
    @Test func theCeremonyHasARootPresenterWhenNoProtectionPaneIsMounted() async throws {
        let w = try world()
        w.controller.switchRunner = PostureSwitchRunner(leaves: inertLeaves(for: w))

        // 1 — the main window's road: no pane on screen.
        #expect(w.controller.mountedProtectionPanes == 0)
        w.controller.openSwitch(.replaceKeys, vaultTie: nil)
        #expect(w.controller.activeSwitch != nil, "the door opened a ceremony (it always did)")
        #expect(w.controller.ceremonyHost == .root)
        #expect(w.controller.ceremony(for: .root) != nil, "and the ROOT presents it — red before row 11")
        #expect(w.controller.ceremony(for: .pane) == nil, "never both")

        // 2 — the Settings window opening mid-ceremony does not steal it.
        w.controller.protectionPaneAppeared()
        #expect(w.controller.ceremony(for: .root) != nil, "the sheet stays where she is looking")
        #expect(w.controller.ceremony(for: .pane) == nil)
        w.controller.closeSwitch()
        #expect(w.controller.ceremony(for: .root) == nil && w.controller.ceremony(for: .pane) == nil)

        // 3 — opened WITH a pane on screen: Settings presents, the root does not.
        w.controller.openSwitch(.replaceKeys, vaultTie: nil)
        #expect(w.controller.ceremonyHost == .pane)
        #expect(w.controller.ceremony(for: .pane) != nil && w.controller.ceremony(for: .root) == nil)
        w.controller.closeSwitch()

        // 4 — the pane goes away; the next ceremony is the root's again.
        w.controller.protectionPaneDisappeared()
        #expect(w.controller.mountedProtectionPanes == 0)
        w.controller.openSwitch(.replaceKeys, vaultTie: nil)
        #expect(w.controller.ceremony(for: .root) != nil && w.controller.ceremony(for: .pane) == nil)
        w.controller.closeSwitch()

        // The count never goes negative (a pane torn down twice).
        w.controller.protectionPaneDisappeared()
        #expect(w.controller.mountedProtectionPanes == 0)
    }

    // MARK: - The unreadable-sidecar family (pre-13u Act 9 — 17a P1/P11)

    /// P1: the reconcile runs on every ready launch, and an unreadable
    /// sidecar used to be read as ABSENT — a fresh wrap-less envelope
    /// written OVER the file. The Apple arm SKIPS an unreadable sidecar
    /// whole, exactly as the escrow arm learned to.
    @Test func reconcileNeverOverwritesAnUnreadableSidecar() async throws {
        let w = try world()
        w.envelopeBox.unreadable = true
        await w.controller.reconcile()
        #expect(w.envelopeBox.value != nil, "the file is left exactly as it was")
        #expect(w.controller.envelopeUnreadable, "the projection carries the truth: unreadable, not absent")
        #expect(w.controller.appleKeyVerified == nil, "no claim from unknowns")
        #expect(w.controller.legs.tier == .unknown)
        #expect(w.controller.notice != .nudge,
                "the nudge stays quiet — it cannot honestly claim 'no passphrase' over unknown wraps")
    }

    /// P11(b): the set screen refuses over an unreadable sidecar — the
    /// old road wrapped the key into a fresh BLANK envelope, obliterating
    /// the `recovery` blob (her twelve written-down words) with no word said.
    @Test func setPassphraseRefusesOverAnUnreadableSidecarInsteadOfOverwritingIt() async throws {
        let w = try world()
        let before = w.envelopeBox.value
        w.envelopeBox.unreadable = true
        let refusal = await w.controller.setPassphrase("sesame")
        #expect(refusal == ProtectionCopy.message(
            for: StoreKeyEnvelopeError.unreadable("scripted unreadable sidecar")),
                "the refusal names the TRUE cause — the file exists and can't be read")
        #expect(w.envelopeBox.value == before, "nothing was written")
        #expect(await w.controller.generateAndLandRecoveryPhrase() == nil)
        #expect(w.controller.lastError != nil)
    }

    /// P2, THE RED-ON-OLD PIN: entering a demanded gate is authorized by
    /// a FRESH disk read, never the cached `hasPassphraseWrap` projection.
    @Test func aCustodyMoveAuthorizesFromTheDiskNotTheCachedProjection() async throws {
        let foreignKey = StoreKey.mint()
        var foreign = StoreKeyEnvelope()
        try foreign.setPassphraseWrap(key: foreignKey, passphrase: "theirs", kdf: fastKDF())
        let w = try world(envelope: foreign)
        #expect(w.controller.hasPassphraseWrap,
                "init reads the foreign envelope — the projection says a wrap exists")

        // The envelope changes UNDER the projection.
        w.envelopeBox.value = StoreKeyEnvelope()
        #expect(w.controller.hasPassphraseWrap, "the projection is now stale — the trap is set")

        let outcome = await w.controller.moveCustody(to: .passphrase)
        #expect(outcome == .needsPassphrase,
                "a wrap-less envelope cannot authorize a demanded gate — stale 'true' deleted both Keychain items here")
        #expect(w.backing.auto == w.key,
                "the silent item SURVIVES — the refused transition changed nothing")
    }

    // MARK: - R-pre13u-4: the nudge brain's legs, re-based on A

    @Test func theLegsTierNeverCountsAnUnverifiedAppleKey() {
        func legs(
            passphrase: Bool = false, recovery: Bool = false,
            apple: Bool? = nil, unknown: Bool = false
        ) -> ProtectionLegs {
            ProtectionLegs(
                hasPassphraseWrap: passphrase, hasRecoveryWrap: recovery,
                appleKeyVerified: apple, storeCustodyGated: false,
                factsUnknown: unknown)
        }
        #expect(legs().tier == .exposed,
                "Standard + no secrets + no verified Apple copy = only this device opens the work")
        #expect(legs(apple: nil).tier == .exposed,
                "an UNVERIFIED Apple copy (nil — never checked) counts for NOTHING")
        #expect(legs(apple: false).tier == .exposed,
                "a copy that did not verifiably land counts for nothing either")
        #expect(legs(apple: true).tier == .covered, "the verified key covers")
        #expect(legs(passphrase: true).tier == .covered)
        #expect(legs(recovery: true).tier == .covered)
        #expect(legs(unknown: true).tier == .unknown,
                "an unreadable sidecar claims NO tier — the nudge stays quiet (P1/P11)")
        #expect(ProtectionCopy.waysBackInLine(legs(apple: true)).contains("iCloud Keychain"))
        #expect(!ProtectionCopy.waysBackInLine(legs(apple: false)).contains("iCloud Keychain"),
                "the pane never lists a net that did not verifiably land")
    }

    /// P10, THE RED-ON-OLD PIN: a recovery wrap landed during the KDF
    /// survives `setPassphrase` (the fresh read AFTER the derivation).
    @Test func aRecoveryWrapLandedDuringTheKDFSurvivesSetPassphrase() async throws {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            auto: key, biometryAvailable: true, biometricSucceeds: true)
        let dialsBox = ScriptedDialsBox(ProtectionDials())
        let envelopeBox = ScriptedEnvelopeBox(nil)
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing, envelope: envelopeBox, stamps: stamps)
        let words = try RecoveryPhrase.generate()
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: {
                var landed = envelopeBox.value ?? StoreKeyEnvelope()
                try? landed.setRecoveryWrap(key: key, words: words)
                envelopeBox.value = landed
                return PassphraseKDF.Descriptor(
                    algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                    memoryKiB: 256, iterations: 1, parallelism: 1,
                    salt: PassphraseKDF.randomSalt(), outputBytes: 32)
            }))

        #expect(await controller.setPassphrase("sesame") == nil)
        let envelope = try #require(envelopeBox.value)
        #expect(envelope.recovery != nil,
                "the recovery wrap landed mid-derivation SURVIVES the passphrase save")
        #expect(try envelope.unwrapKey(recoveryWords: words) == key)
        #expect(try envelope.unwrapKey(passphrase: "sesame") == key)
    }

    // MARK: - pre-13x 2d: DECISION 35 — indeterminate writes nothing

    /// HER PHONE AT THE WINDOW, REPLAYED: a format-1 key file holding ONLY
    /// `formatVersion` + `storeID` (79 bytes, no secrets), the raw key in
    /// the SILENT item, a signed-in session, no sync custody yet, and a
    /// vault read that FAILS at ready (the session's scope migration / the
    /// network not yet answered). Decision 35: the library is ENROLLED
    /// (signed in), so its posture is INDETERMINATE until the vault
    /// answers — it opens through the custody it has (silent ⇒ `.auto`)
    /// and WRITES NOTHING: no Apple copy landed, no A minted, no custody
    /// move, no key-file change; the exposed nudge stays quiet. With the
    /// vault readable and STANDARD the Apple arm lands exactly as 2a built
    /// it; a library nobody is signed into keeps 2a's safety arm.
    /// RED ON OLD: `Posture.derive` read the secret-less file as a
    /// determined Standard and the Apple arm wrote `apple` + `appleKeyID`
    /// into it — the iCloud copy of her real phone library key on a Castle
    /// account's library.
    @Test func herPhoneReplayedAnEnrolledSecretlessLibraryWithTheVaultUnreadWritesNothing() async throws {
        let key = StoreKey.mint()
        let secretless = StoreKeyEnvelope(
            formatVersion: StoreKeyEnvelope.formatVersion1, storeID: "e6194a17-her-phone")
        let w = try world(standard: true, key: key, envelope: secretless)
        w.controller.isSignedIn = { true }
        w.controller.readVaultPosture = { nil }  // the vault unreachable at this ready
        let before = w.envelopeBox.value
        #expect(w.appleKeys.key != nil, "A is readable — the arm WOULD land if it ran")

        await w.controller.reconcile()

        #expect(w.envelopeBox.value == before, "the key file's bytes before == after")
        #expect(w.envelopeBox.value?.apple == nil && w.envelopeBox.value?.appleKeyID == nil,
                "no Apple copy landed on a library whose account may be Castle")
        #expect(w.controller.postureIndeterminate, "enrolled, the vault unread ⇒ indeterminate")
        #expect(w.controller.posture == .standard && w.controller.effectiveGate == .auto,
                "…and it opens through the custody it HAS (the silent item)")
        #expect(w.controller.appleKeyVerified == nil, "the Apple arm never ran")
        #expect(w.backing.auto == key && w.backing.gated == nil, "no custody move")
        #expect(w.controller.notice == nil, "no exposed nudge for an enrolled library")

        // The vault readable and STANDARD: 2a's Apple arm lands, unchanged.
        let appleID = w.appleKeys.key?.id
        w.controller.readVaultPosture = { VaultPostureReading(hasAppleHeldCopy: true, appleKeyID: appleID) }
        await w.controller.reconcile()
        #expect(!w.controller.postureIndeterminate && w.controller.posture == .standard)
        #expect(w.envelopeBox.value?.appleKeyID == appleID, "the Apple copy landed as 2a built it")
        #expect(w.controller.appleKeyVerified == true)

        // The same file with NO session and NO custody: 2a's safety arm — a
        // determined Standard whose Apple copy lands (nobody can re-open it
        // by any word; the exposed nudge's state).
        let local = try world(standard: true, envelope: StoreKeyEnvelope(
            formatVersion: StoreKeyEnvelope.formatVersion1, storeID: "local-only"))
        local.controller.readVaultPosture = { nil }
        await local.controller.reconcile()
        #expect(!local.controller.postureIndeterminate && local.controller.posture == .standard)
        #expect(local.envelopeBox.value?.apple != nil, "2a's arm lands for a library nobody is signed into")

        // Enrolled by CUSTODY alone (no session hook): indeterminate too.
        let byCustody = try world(standard: true, envelope: StoreKeyEnvelope(
            formatVersion: StoreKeyEnvelope.formatVersion1, storeID: "custody-only"), enrolled: true)
        byCustody.controller.readVaultPosture = { nil }
        let custodyBefore = byCustody.envelopeBox.value
        await byCustody.controller.reconcile()
        #expect(byCustody.controller.postureIndeterminate)
        #expect(byCustody.envelopeBox.value == custodyBefore, "nothing written")
    }

    // MARK: - pre-13x 2d: THE POSTURE-MISMATCH FOLLOW (decision 35)

    /// THE WINDOW's PHONE, the morning after: the vault says CASTLE (no
    /// Apple-held copy), the corpus key ids AGREE (nothing was rotated), and
    /// this library's custody is SILENT — a posture mismatch. The follow
    /// into Castle is owed (copy §5's *Account moved to Castle*, *[device]
    /// on [day]* from the vault; *Later* leaves the persistent banner); the
    /// verdict writes nothing itself. A vault that AGREES with the shape
    /// owes nothing; a GATED shape under a STANDARD vault takes the silent
    /// follow into Standard even when the key file already carries an Apple
    /// copy (2c's trigger) — the SHAPE is the trigger (decision 1). RED ON
    /// OLD: the follow keyed on the corpus key id alone — a silent-custody
    /// library under a Castle account stayed silent forever.
    @Test func aSilentCustodyLibraryUnderACastleVaultOwesTheFollowIntoCastleAndAGatedOneUnderStandardFollowsSilently() async throws {
        let w = try world(standard: true, enrolled: true)
        #expect(w.controller.libraryKeyCustodyShape == .silent)
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false, corpusKeyID: "corpus")] in reading }
        let fileBefore = w.envelopeBox.value
        await w.controller.reconcile()
        let owed = try #require(w.controller.followNotice)
        #expect(owed.kind == .castleStillOpensOldWay, "the account is Castle; this library opened silently — its OWN notice (2d.4)")
        #expect(owed.corpusKeyID == "corpus", "the keys are unchanged — the notice carries the same id")
        #expect(owed.body == ProtectionCopy.followCastleStillOpensOldWay, "copy §5's own sentence, never 'keys were replaced'")
        #expect(owed.laterSubline == ProtectionCopy.followCastleStillOpensLaterSubline)
        #expect(owed.waitingBody == ProtectionCopy.followCastleStillOpensOldWay)
        #expect(w.controller.notice == .follow(owed) && w.controller.followPending)
        #expect(w.controller.posture == .castle && !w.controller.postureIndeterminate, "the vault's word DETERMINES")
        #expect(w.envelopeBox.value == fileBefore, "the verdict writes nothing — the act does")
        #expect(w.backing.auto == w.key && w.backing.gated == nil, "custody untouched until she types")
        w.controller.deferFollow()
        #expect(w.controller.notice == .followWaiting(owed))
        // The next reconcile with the SAME mismatch keeps Later's banner (no re-ask).
        await w.controller.reconcile()
        #expect(w.controller.notice == .followWaiting(owed), "the same mismatch does not re-ask within the launch")

        // The vault AGREEING with the silent shape (Standard, the same id): nothing owed.
        let agreeing = try world(standard: true, enrolled: true)
        let acts = LockedCounter()
        agreeing.controller.followIntoStandardAct = { acts.increment() }
        agreeing.controller.foreignOwner = { _ in false }
        agreeing.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: true, corpusKeyID: "corpus")] in reading }
        await agreeing.controller.reconcile()
        #expect(agreeing.controller.followNotice == nil && !agreeing.controller.followPending)
        #expect(acts.value == 0, "Standard-shaped custody under a Standard vault: nothing moves")

        // A GATED shape under a STANDARD vault, the key file ALREADY carrying
        // an Apple copy (2c's key-file trigger false): the SHAPE triggers the
        // silent follow into Standard.
        let key = StoreKey.mint()
        var gatedFile = StoreKeyEnvelope()
        try gatedFile.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        try gatedFile.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a-elsewhere")
        let gated = try world(standard: false, key: key, envelope: gatedFile, enrolled: true)
        #expect(gated.controller.libraryKeyCustodyShape == .gatedOrNone)
        let silentActs = LockedCounter()
        gated.controller.followIntoStandardAct = { silentActs.increment() }
        gated.controller.foreignOwner = { _ in false }
        gated.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: true, corpusKeyID: "corpus")] in reading }
        await gated.controller.reconcile()
        #expect(silentActs.value == 1, "a stricter gate under a Standard account follows silently (decision 1)")
        #expect(gated.controller.followNotice == nil)
        #expect(gated.controller.movedToStandardNotice != nil)

        // A gated shape under a CASTLE vault: the shape agrees — nothing owed.
        let castle = try world(standard: false, enrolled: true)
        castle.controller.foreignOwner = { _ in false }
        castle.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false, corpusKeyID: "corpus")] in reading }
        await castle.controller.reconcile()
        #expect(castle.controller.followNotice == nil && castle.controller.notice != .follow(owed))
    }

    /// 13x F1 (ladder R1-BLOCKER) — THE ADOPTED STANDARD-ERA PAIR on the
    /// Mac the library lives on: the vault says CASTLE, the corpus key
    /// ids AGREE (this device followed when Castle was entered), custody
    /// is GATED — and the LIVE key file carries an `apple` copy, because
    /// the adoption door landed a pre-Castle snapshot pair whole. No
    /// earlier arm fires (the rotation arm needs differing ids; the
    /// silent arm needs the silent shape; the Apple arm under Castle only
    /// clears flags) — so before this arm the library stayed
    /// Apple-openable in steady state, and every later snapshot copied
    /// the wrap (`writeSnapshotKeyFile` copies the live file's bytes).
    /// The follow is OWED under its own kind; the verdict writes nothing
    /// (the act is the no-rotation follow's, whose `retireOldKeyFiles`
    /// removes the file). RED ON OLD: the arm's if-block removed ⇒
    /// `followNotice` stays nil — no notice, no re-key, the wrap stands
    /// (the round-1 report's named pin).
    @Test func anAdoptedStandardEraPairUnderACastleVaultOwesTheFollowThatRetiresItsAppleCopy() async throws {
        let key = StoreKey.mint()
        var pairFile = StoreKeyEnvelope()
        try pairFile.setPassphraseWrap(key: key, passphrase: "the-old-day", kdf: fastKDF())
        try pairFile.setAppleWrappedCopy(
            key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a-standard-era")
        let w = try world(standard: false, key: key, envelope: pairFile, enrolled: true)
        #expect(w.controller.libraryKeyCustodyShape == .gatedOrNone,
                "the adoption's landCustody saved the opener GATED — the silent arm cannot be the detector")
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false, corpusKeyID: "corpus")] in reading }
        let fileBefore = w.envelopeBox.value
        await w.controller.reconcile()
        let owed = try #require(
            w.controller.followNotice,
            "the follow is OWED — the live key file is Apple-openable under a Castle account")
        #expect(owed.kind == .castleKeyFileAppleOpenable,
                "its OWN kind — custody is gated, so the mismatch kind's 'still opens without asking' would be false")
        #expect(owed.corpusKeyID == "corpus", "the keys are unchanged — the no-rotation follow serves it")
        #expect(owed.body == ProtectionCopy.followCastleKeyFileAppleOpenable)
        #expect(owed.waitingBody == ProtectionCopy.followCastleKeyFileAppleOpenable,
                "no keys were replaced and sync is not paused — copy §5's waiting line would be untrue")
        #expect(owed.laterSubline == ProtectionCopy.followCastleStillOpensLaterSubline,
                "the same fact as the mismatch: writing after Later stays under the old, Apple-openable key")
        #expect(w.controller.notice == .follow(owed) && w.controller.followPending)
        #expect(w.controller.posture == .castle && !w.controller.postureIndeterminate, "the vault's word DETERMINES")
        #expect(w.envelopeBox.value == fileBefore, "the verdict writes nothing — the act is the follow's")
        #expect(w.backing.gated == key && w.backing.auto == nil, "custody untouched until she types")
    }

    /// pre-13x 3a (ledger 43 — the follow's own carry, as the REGRESSION
    /// guard the brief names): the device identity rides every custody
    /// move — silent → the gate (the identity-only bound item beside the
    /// gated record), the gate → Always ask (identity-only, the keys in the
    /// session), a relock (the session dropped), and back to silent — never
    /// re-minted. Green by construction on this tree (`SyncCustodyTransition
    /// .move` carries `record.deviceID`; `deviceID()` reads the session,
    /// then the plain item, and mints only when neither exists); recorded
    /// as such in the 3a record.
    @Test func theDeviceIdentityRidesEveryCustodyMoveAndARelock() async throws {
        let w = try world(standard: true, enrolled: true)
        #expect(w.syncLeaves.plainRecord?.deviceID == "device-1")
        #expect(await w.controller.setPassphrase("sesame") == nil)
        #expect(await w.controller.moveCustody(to: .biometric) == .changed)
        #expect(w.syncLeaves.gatedRecord?.deviceID == "device-1" && w.syncLeaves.gatedRecord?.material != nil)
        #expect(w.syncLeaves.plainRecord == SyncCustodyRecord(deviceID: "device-1", material: nil),
                "the identity-only bound item beside the gated record")
        #expect(w.syncSession.record?.deviceID == "device-1")
        #expect(await w.controller.moveCustody(to: .passphrase) == .changed)
        #expect(w.syncLeaves.gatedRecord == nil)
        #expect(w.syncLeaves.plainRecord == SyncCustodyRecord(deviceID: "device-1", material: nil))
        #expect(w.syncSession.record?.deviceID == "device-1", "Always ask: the keys in the session, the identity in the item")
        // A relock drops the session; the identity stays in the bound item.
        w.syncSession.drop()
        #expect(w.syncLeaves.plainRecord?.deviceID == "device-1")
        let store = DeviceKeyStore.custody(leaves: { w.syncLeaves.leaves }, shape: { .sessionOnly }, session: w.syncSession)
        #expect(store.deviceID() == "device-1", "the provider reads the carried id — no mint")
        #expect(await w.controller.moveCustody(to: .auto) == .changed)
        #expect(w.syncLeaves.plainRecord?.deviceID == "device-1", "back to silent: the same identity")
    }

    /// pre-13x 3a (decision 17; ledger 15) — THE CONNECT DOOR over the
    /// exact verdict: the EXACT read is what the verdict consults (a mixed
    /// library reads foreign even though its first row is the signed-in
    /// account's — `foreignOwner` answers true, and the verdict is
    /// `.differentOwner`); the Connect sheet is the follow model with the
    /// `.connectLibrary` kind (copy §3's sentence; the third door Cancel,
    /// which defers nothing); a wrong word refuses in the ACCOUNT's words
    /// and runs nothing; the right word runs the wired adopt act ONCE with
    /// the typed secret, the verdict clears, and the next reconcile (the
    /// rows now this account's) owes nothing. RED ON OLD: the verdict read
    /// `stampedOwnerID` (the first row — the signed-in id) and said SAME
    /// OWNER; `openConnect` did not exist.
    @Test func theExactOwnerReadOwesConnectAndTheConnectSheetRunsTheAdoptOnceAndClears() async throws {
        let w = try world(enrolled: true)
        let foreign = LockIsolated(true)  // the exact read: Y's rows exist beside the signed-in X's
        w.controller.foreignOwner = { _ in foreign.value }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false, corpusKeyID: "corpus")] in reading }
        await w.controller.reconcile()
        #expect(w.controller.differentOwner && w.controller.notice == .differentOwner)
        #expect(w.controller.followNotice == nil, "never a follow over a foreign library")

        // No runner / no act wired: the door does not open (P-2).
        w.controller.openConnect()
        #expect(w.controller.activeFollow == nil)
        let acts = LockIsolated<[(String?, [String]?)]>([])
        w.controller.connectAct = { passphrase, words in
            acts.withValue { $0.append((passphrase, words)) }
            guard passphrase == "account-sesame" || words != nil else { throw VaultEnrollmentError.wrongPassphrase }
            foreign.setValue(false)  // the rows are this account's now
        }
        w.controller.switchRunner = PostureSwitchRunner(leaves: inertLeaves(for: w))
        w.controller.openConnect()
        let model = try #require(w.controller.activeFollow)
        #expect(model.isConnectVariant && model.notice.body == ProtectionCopy.keysDontMatchThisLibrary)
        #expect(model.notice.dismissDoor == ProtectionCopy.connectCancelDoor)
        model.later()
        #expect(model.phase == .closed && w.controller.notice == .differentOwner, "Cancel defers nothing — the verdict stands")
        w.controller.closeFollow()

        w.controller.openConnect()
        let again = try #require(w.controller.activeFollow)
        again.choosePassphrase()
        await again.enter(passphrase: "not-the-account's")
        #expect(again.lastError == EncryptionSession.message(for: VaultEnrollmentError.wrongPassphrase), "the ACCOUNT's word, not the library's")
        #expect(again.phase == .askPassphrase && w.controller.differentOwner)
        await again.enter(passphrase: "account-sesame")
        #expect(again.phase == .done(insuranceOff: false, hasOffer: false), "\(again.phase)")
        #expect(acts.value.count == 2 && acts.value.last?.0 == "account-sesame", "the adopt act ran with the typed secret")
        #expect(!w.controller.differentOwner && w.controller.notice != .differentOwner, "the verdict cleared and the reconcile agreed")
    }

    /// pre-13x 3a — THE VAULT MATERIAL's LANDING on the key file (§3.5; the
    /// 2d hand-forward): after an enroll / setup / Connect, the key file
    /// gains the MASTER copy (L under M — the vault road, with no visit)
    /// and records the vault's descriptor + corpus key id (no confirm owed —
    /// the derived gate reads a recorded descriptor); a TYPED passphrase
    /// re-wraps the local P copy under the VAULT's descriptor (corner 27 —
    /// the account's passphrase becomes the library's; §3.6's derive-once)
    /// unless the copy already sits under it (then no re-derivation); typed
    /// words land the W copy; a landing with neither leaves the secret
    /// copies alone. Inherently red-on-old (no landing road existed — the
    /// 14c enroll wrote a passphrase copy under a FRESH descriptor and no
    /// master copy, the migrated-without-descriptor class).
    @Test func landingTheVaultMaterialWritesTheMasterCopyAndReconcilesUnderTheVaultsDescriptor() async throws {
        let w = try world(standard: true, enrolled: false)
        let held = material()
        let vaultKDF = fastKDF()
        w.controller.isSignedIn = { true }
        // (a) typed passphrase, no wrap yet: the P copy lands UNDER THE VAULT's descriptor.
        #expect(await w.controller.landVaultMaterial(VaultLanding(
            material: held, kdf: vaultKDF, passphrase: "account-sesame", recoveryWords: nil)) == nil)
        var file = try #require(w.envelopeBox.value)
        #expect(try file.unwrapKey(master: held.masterSymmetricKey) == w.key, "the master copy opens L")
        #expect(file.vaultKDF == vaultKDF && file.vaultCorpusKeyID == held.corpusKeyID, "the reconciliation recorded")
        let openedByAccountWord = try file.unwrapKey(passphrase: "account-sesame")
        #expect(file.passphrase?.kdf == vaultKDF && openedByAccountWord == w.key,
                "the P copy under the VAULT's descriptor — the lobby derives once")
        #expect(file.recovery == nil)
        #expect(!w.controller.migrationConfirmOwedByDerivation, "a recorded descriptor owes no confirm")
        // (b) the copy already under the vault's descriptor: no re-derivation (the KDF factory is not consulted).
        let derivations = LockIsolated(0)
        let counting = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: StoreLaunchGate.scripted(
                dials: w.dialsBox, backing: w.backing, envelope: w.envelopeBox, stamps: w.stamps, appleKey: w.appleKeys),
            isRealVariant: true,
            makeKDF: { derivations.withValue { $0 += 1 }; return PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) },
            storeID: { [id = file.storeID] in id },
            syncCustodyLeaves: { _ in w.syncLeaves.leaves }, syncCustodySession: w.syncSession))
        counting.adoptResident(nil)
        let before = file
        #expect(await counting.landVaultMaterial(VaultLanding(
            material: held, kdf: vaultKDF, passphrase: "account-sesame", recoveryWords: nil)) == nil)
        file = try #require(w.envelopeBox.value)
        #expect(file.passphrase == before.passphrase, "the P copy untouched — derive once")
        // (c) typed words: the W copy lands beside; nothing else moves.
        let words = try RecoveryPhrase.generate()
        #expect(await counting.landVaultMaterial(VaultLanding(
            material: held, kdf: vaultKDF, passphrase: nil, recoveryWords: words)) == nil)
        file = try #require(w.envelopeBox.value)
        #expect(try file.unwrapKey(recoveryWords: words) == w.key, "L under the typed words")
        #expect(file.passphrase == before.passphrase)
        // (d) no key in hand refuses in words.
        let locked = try world(standard: false, enrolled: false)
        locked.controller.dropResident()
        locked.backing.gated = nil
        #expect(await locked.controller.landVaultMaterial(VaultLanding(
            material: held, kdf: vaultKDF, passphrase: nil, recoveryWords: nil)) == ProtectionController.keyUnavailable)
    }

    /// pre-13x 3a — ENROLL's FOUR DIRECTIONS at the reconcile (design §5's
    /// Enroll row; copy §2d): a signed-in library with NO sync custody and
    /// no enrollment signature on its key file (no master copy, no recorded
    /// corpus key id). (a) Standard library + Standard account + the iCloud
    /// key matching the vault's copy: the SILENT road — A opens the vault's
    /// master, the class keys follow, custody and the key file land through
    /// the wired adopt, nothing typed, no face (`enrollReading` nil). A
    /// absent ⇒ the waiting face's facts; A under another Apple ID ⇒ the
    /// different-Apple-ID facts; a Standard library under a CASTLE account ⇒
    /// (c)'s facts (the re-key sentence); a Castle-born library under a
    /// STANDARD account ⇒ (d)'s facts (consent first — NOTHING lands
    /// silently); Castle under Castle ⇒ (b)'s facts. RED ON OLD: no arm
    /// existed — a Standard library on a Standard account landed nothing at
    /// ready and stayed on the 14c "type the passphrase" face; no facts.
    @Test func enrollsFourDirectionsAtTheReconcileAndTheStandardRoadLandsWithNothingTyped() async throws {
        let kdf = fastKDF()
        let master = SymmetricKey(size: .bits256)
        func vault(appleUnder apple: AppleKey?) throws -> KeyVaultFormat {
            var format = try KeyVaultFormat.create(
                masterKey: master, passphraseKey: try PassphraseKDF.deriveKey(passphrase: "account-sesame", descriptor: kdf),
                recoveryKey: nil,
                classKeys: [(keyClass: .corpus, keyID: "corpus-a", key: SymmetricKey(size: .bits256)),
                            (keyClass: .journalBridge, keyID: "bridge-a", key: SymmetricKey(size: .bits256))],
                kdf: kdf)
            if let apple {
                format = try format.settingAppleHeldCopy(masterKey: master, appleKey: apple.symmetricKey, appleKeyID: apple.id)
            }
            return format
        }
        func reading(_ format: KeyVaultFormat, appleKeyID: String? = nil) -> VaultPostureReading {
            VaultPostureReading(
                hasAppleHeldCopy: format.masterWrappedByAppleHeld != nil, appleKeyID: appleKeyID ?? format.appleKeyID,
                passphraseKDF: kdf, hasPassphraseWrap: true, corpusKeyID: "corpus-a",
                updatedAt: "2026-09-05T10:00:00Z", updatedByDevice: "Lillian's Mac",
                signedInUserID: "user-1", hasRecoveryWrap: false, format: format)
        }

        // (a) THE SILENT ROAD.
        let a = try world(standard: true, enrolled: false)
        let apple = try #require(a.appleKeys.key)
        let standardVault = try vault(appleUnder: apple)
        let landed = LockIsolated<[(DeviceKeyMaterial, PassphraseKDF.Descriptor)]>([])
        a.controller.isSignedIn = { true }
        a.controller.foreignOwner = { _ in false }
        a.controller.readVaultPosture = { [r = reading(standardVault)] in r }
        a.controller.landEnrollment = { material, kdf in landed.withValue { $0.append((material, kdf)) }; return true }
        await a.controller.reconcile()
        #expect(landed.value.count == 1, "the silent road landed once")
        #expect(landed.value.first?.0.corpusKeyID == "corpus-a" && landed.value.first?.0.masterKey == master.withUnsafeBytes { Data($0) },
                "the vault's master and class keys, opened by A")
        #expect(landed.value.first?.1 == kdf, "the vault's descriptor rides to the key file")
        #expect(a.controller.enrollReading == nil, "no face is owed")
        #expect(a.controller.followNotice == nil && !a.controller.differentOwner)

        // A absent ⇒ the waiting face; nothing lands.
        let waiting = try world(standard: true, enrolled: false)
        waiting.appleKeys.key = nil
        let waitingLanded = LockedCounter()
        waiting.controller.isSignedIn = { true }
        waiting.controller.foreignOwner = { _ in false }
        waiting.controller.readVaultPosture = { [r = reading(standardVault)] in r }
        waiting.controller.landEnrollment = { _, _ in waitingLanded.increment(); return true }
        await waiting.controller.reconcile()
        #expect(waiting.controller.enrollReading == EnrollFacts(accountPosture: .standard, libraryPosture: .standard, appleState: .absent))
        #expect(waitingLanded.value == 0)

        // A under another Apple ID ⇒ the different-Apple-ID face; nothing lands.
        let other = try world(standard: true, enrolled: false)
        let otherLanded = LockedCounter()
        other.controller.isSignedIn = { true }
        other.controller.foreignOwner = { _ in false }
        other.controller.readVaultPosture = { [r = reading(standardVault, appleKeyID: "someone-elses-apple-id")] in r }
        other.controller.landEnrollment = { _, _ in otherLanded.increment(); return true }
        await other.controller.reconcile()
        #expect(other.controller.enrollReading?.appleState == .differentAppleID)
        #expect(otherLanded.value == 0)

        // (c) a Standard library under a CASTLE account ⇒ the re-key sentence's facts; nothing lands.
        let castleVault = try vault(appleUnder: nil)
        let c = try world(standard: true, enrolled: false)
        let cLanded = LockedCounter()
        c.controller.isSignedIn = { true }
        c.controller.foreignOwner = { _ in false }
        c.controller.readVaultPosture = { [r = reading(castleVault)] in r }
        c.controller.landEnrollment = { _, _ in cLanded.increment(); return true }
        await c.controller.reconcile()
        let cFacts = try #require(c.controller.enrollReading)
        #expect(cFacts.standardBornJoinsCastle && cFacts.appleState == .notApplicable)
        #expect(cLanded.value == 0 && c.controller.followNotice == nil, "no follow is owed to a never-enrolled library")

        // (d) a Castle-born library under a STANDARD account ⇒ consent first; NOTHING lands silently.
        let d = try world(standard: false, enrolled: false)
        d.appleKeys.key = apple
        let dLanded = LockedCounter()
        d.controller.isSignedIn = { true }
        d.controller.foreignOwner = { _ in false }
        d.controller.readVaultPosture = { [r = reading(standardVault)] in r }
        d.controller.landEnrollment = { _, _ in dLanded.increment(); return true }
        await d.controller.reconcile()
        let dFacts = try #require(d.controller.enrollReading)
        #expect(dFacts.castleBornJoinsStandard && dFacts.appleState == .matched)
        #expect(dLanded.value == 0, "consent before anything moves — decision 1 with corner 6")
        #expect(d.backing.gated == d.key && d.backing.auto == nil, "custody untouched")

        // (b) Castle under Castle ⇒ the plain roads' facts.
        let b = try world(standard: false, enrolled: false)
        b.controller.isSignedIn = { true }
        b.controller.foreignOwner = { _ in false }
        b.controller.readVaultPosture = { [r = reading(castleVault)] in r }
        await b.controller.reconcile()
        #expect(b.controller.enrollReading == EnrollFacts(accountPosture: .castle, libraryPosture: .castle, appleState: .notApplicable))

        // pre-13x 3b (ledger 52 — the orchestrator's correction): a library
        // whose key file carries a master copy and the CURRENT recorded id,
        // with no custody in hand and no derived key held (opened by the
        // words, or a scripted controller with no lobby), is the enroll
        // block's too — Castle under Castle ⇒ the tab's passphrase door.
        // (3a read it as "enrolled once ⇒ no facts"; that excluded restored
        // copies, which §3.8 / §6 / §7 say enroll.)
        var enrolledFile = StoreKeyEnvelope()
        let enrolledKey = StoreKey.mint()
        try enrolledFile.setPassphraseWrap(key: enrolledKey, passphrase: "sesame", kdf: fastKDF())
        try enrolledFile.setMasterWrappedCopy(key: enrolledKey, under: master)
        try enrolledFile.recordVaultReconciliation(kdf: kdf, corpusKeyID: "corpus-a", recoveryWrapDigest: nil)
        let enrolled = try world(standard: false, dials: ProtectionDials(alwaysAsk: true), key: enrolledKey, envelope: enrolledFile)
        enrolled.controller.isSignedIn = { true }
        enrolled.controller.foreignOwner = { _ in false }
        enrolled.controller.readVaultPosture = { [r = reading(castleVault)] in r }
        await enrolled.controller.reconcile()
        #expect(enrolled.controller.enrollReading == EnrollFacts(accountPosture: .castle, libraryPosture: .castle, appleState: .notApplicable),
                "a current recorded id with nothing in hand is an enroll — the passphrase door, never silence")
        #expect(enrolled.controller.followNotice == nil && enrolled.controller.alwaysAskRetiredNotice == nil)
    }

    // MARK: - pre-13x 3b: THE RESTORED-COPY ENROLL (ledger 52)

    /// A RESTORED Standard snapshot — a master copy and the CURRENT recorded
    /// corpus id in its key file, no custody on this machine, A matched —
    /// enrolls SILENTLY at ready (the vault's master opened by A; the
    /// landing rewrites the master copy + the reconciliation); the same
    /// snapshot with a STALE recorded id owes the FOLLOW's notice — for any
    /// device, not only an Always-ask one. RED ON OLD (3a): the "never
    /// enrolled" gate (no master copy AND no recorded id) skipped the
    /// restored copy — nothing landed, no face owed — and the stale id's
    /// tail sat behind `effectiveGate == .passphrase`, which a silent
    /// Standard device never has.
    @Test func aRestoredSnapshotWithTheCurrentIdEnrollsSilentlyAndAStaleIdOwesTheFollow() async throws {
        let kdf = fastKDF()
        let master = SymmetricKey(size: .bits256)
        let apple = AppleKey.mint()
        func vault(appleUnder apple: AppleKey?) throws -> KeyVaultFormat {
            var format = try KeyVaultFormat.create(
                masterKey: master, passphraseKey: try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: kdf),
                recoveryKey: nil,
                classKeys: [(keyClass: .corpus, keyID: "corpus-now", key: SymmetricKey(size: .bits256)),
                            (keyClass: .journalBridge, keyID: "bridge-now", key: SymmetricKey(size: .bits256))],
                kdf: kdf)
            if let apple {
                format = try format.settingAppleHeldCopy(masterKey: master, appleKey: apple.symmetricKey, appleKeyID: apple.id)
            }
            return format
        }
        func reading(_ format: KeyVaultFormat) -> VaultPostureReading {
            VaultPostureReading(
                hasAppleHeldCopy: format.masterWrappedByAppleHeld != nil, appleKeyID: format.appleKeyID,
                passphraseKDF: kdf, hasPassphraseWrap: true, corpusKeyID: "corpus-now",
                updatedAt: "2026-09-06T10:00:00Z", updatedByDevice: "Lillian's Mac",
                signedInUserID: "user-1", hasRecoveryWrap: true, format: format)
        }
        /// The snapshot's key file: the Apple copy (Standard-era), the master
        /// copy, the passphrase copy, and the recorded id the snapshot had.
        func snapshotFile(recordedID: String) throws -> (StoreKey, StoreKeyEnvelope) {
            let key = StoreKey.mint()
            var file = StoreKeyEnvelope()
            try file.setPassphraseWrap(key: key, passphrase: "sesame", kdf: kdf)
            try file.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            try file.setMasterWrappedCopy(key: key, under: master)
            try file.recordVaultReconciliation(kdf: kdf, corpusKeyID: recordedID, recoveryWrapDigest: nil)
            return (key, file)
        }

        // (i) the current id ⇒ the silent Standard road lands ONCE.
        let standardVault = try vault(appleUnder: apple)
        let (currentKey, currentFile) = try snapshotFile(recordedID: "corpus-now")
        let restored = try world(standard: true, key: currentKey, envelope: currentFile)
        restored.appleKeys.key = apple
        let landed = LockIsolated<[(DeviceKeyMaterial, PassphraseKDF.Descriptor)]>([])
        restored.controller.isSignedIn = { true }
        restored.controller.foreignOwner = { _ in false }
        restored.controller.readVaultPosture = { [r = reading(standardVault)] in r }
        restored.controller.landEnrollment = { material, kdf in landed.withValue { $0.append((material, kdf)) }; return true }
        await restored.controller.reconcile()
        #expect(landed.value.count == 1, "a restored Standard snapshot enrolls with nothing typed")
        #expect(landed.value.first?.0.corpusKeyID == "corpus-now"
                && landed.value.first?.0.masterKey == master.withUnsafeBytes { Data($0) })
        #expect(landed.value.first?.1 == kdf)
        #expect(restored.controller.enrollReading == nil && restored.controller.followNotice == nil)

        // (ii) a STALE recorded id under a Standard vault ⇒ the follow (keys replaced), on a SILENT device.
        let (staleKey, staleFile) = try snapshotFile(recordedID: "corpus-of-the-snapshot")
        let stale = try world(standard: true, key: staleKey, envelope: staleFile)
        stale.appleKeys.key = apple
        let staleLanded = LockedCounter()
        stale.controller.isSignedIn = { true }
        stale.controller.foreignOwner = { _ in false }
        stale.controller.readVaultPosture = { [r = reading(standardVault)] in r }
        stale.controller.landEnrollment = { _, _ in staleLanded.increment(); return true }
        await stale.controller.reconcile()
        #expect(stale.controller.effectiveGate == .auto, "a silent Standard device — never the Always-ask gate")
        let owed = try #require(stale.controller.followNotice)
        #expect(owed.kind == .keysReplaced && owed.corpusKeyID == "corpus-now" && owed.device == "Lillian's Mac")
        #expect(staleLanded.value == 0, "a stale id never enrolls bare — the follow's road re-keys")
        #expect(stale.controller.enrollReading == nil)

        // (ii) the same, under a CASTLE vault while the file still carries an Apple copy ⇒ "moved to Castle".
        let castleVault = try vault(appleUnder: nil)
        let (movedKey, movedFile) = try snapshotFile(recordedID: "corpus-of-the-snapshot")
        let moved = try world(standard: true, key: movedKey, envelope: movedFile)
        moved.controller.isSignedIn = { true }
        moved.controller.foreignOwner = { _ in false }
        moved.controller.readVaultPosture = { [r = reading(castleVault)] in r }
        await moved.controller.reconcile()
        #expect(moved.controller.followNotice?.kind == .movedToCastle)
    }

    /// A RESTORED Castle copy opened by the PASSPHRASE on a Touch ID device:
    /// the lobby held the DERIVED key (every passphrase unlock does), its
    /// descriptor equals the vault's, the recorded id is the vault's — the
    /// material lands under the CURRENT shape through `landEnrollment`
    /// (the gated item + the identity item + the session), with no second
    /// entry; a derived key under ANOTHER descriptor with the current id ⇒
    /// the retired-word banner, on this gate too. RED ON OLD (2c/3a): the
    /// fill ran only under `effectiveGate == .passphrase` and only into the
    /// session — a Touch ID device landed nothing and kept the face owed.
    @Test func aRestoredCastleCopyOpenedByThePassphraseLandsCustodyUnderTheGateWithNoSecondEntry() async throws {
        let kdf = fastKDF()
        let derived = try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: kdf)
        let master = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: derived, recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "corpus-c", key: SymmetricKey(size: .bits256)),
                        (keyClass: .journalBridge, keyID: "bridge-c", key: SymmetricKey(size: .bits256))],
            kdf: kdf)
        var reading = VaultPostureReading(
            hasAppleHeldCopy: false, appleKeyID: nil, passphraseKDF: kdf, hasPassphraseWrap: true,
            corpusKeyID: "corpus-c", updatedAt: "2026-09-06T10:00:00Z",
            updatedByDevice: "Lillian's iPhone", signedInUserID: "user-1", hasRecoveryWrap: true)
        reading.format = format
        func copyFile() throws -> (StoreKey, StoreKeyEnvelope) {
            let key = StoreKey.mint()
            var file = StoreKeyEnvelope()
            try file.setPassphraseWrap(key: key, passphrase: "sesame", kdf: kdf)
            try file.setMasterWrappedCopy(key: key, under: master)
            try file.recordVaultReconciliation(kdf: kdf, corpusKeyID: "corpus-c", recoveryWrapDigest: nil)
            return (key, file)
        }

        let (key, file) = try copyFile()
        let w = try world(standard: false, key: key, envelope: file)
        #expect(w.controller.effectiveGate == .biometric, "a Touch ID device, not Always ask")
        w.syncSession.holdDerivedWrappingKey(derived, kdf: kdf)  // the lobby's passphrase road
        let landed = LockIsolated<[(DeviceKeyMaterial, PassphraseKDF.Descriptor)]>([])
        w.controller.isSignedIn = { true }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [reading] in reading }
        w.controller.landEnrollment = { material, kdf in landed.withValue { $0.append((material, kdf)) }; return true }
        await w.controller.reconcile()
        #expect(landed.value.count == 1, "the derived key opened the vault — landed under the current shape, nothing typed again")
        #expect(landed.value.first?.0.corpusKeyID == "corpus-c" && landed.value.first?.1 == kdf)
        #expect(w.controller.enrollReading == nil && w.controller.followNotice == nil
                && w.controller.alwaysAskRetiredNotice == nil)

        // The word was CHANGED elsewhere: a derived key under another descriptor ⇒ the banner, this gate too.
        let (retiredKey, retiredFile) = try copyFile()
        let retired = try world(standard: false, key: retiredKey, envelope: retiredFile)
        retired.syncSession.holdDerivedWrappingKey(
            try PassphraseKDF.deriveKey(passphrase: "old word", descriptor: fastKDF()), kdf: fastKDF())
        let retiredLanded = LockedCounter()
        retired.controller.isSignedIn = { true }
        retired.controller.foreignOwner = { _ in false }
        retired.controller.readVaultPosture = { [reading] in reading }
        retired.controller.landEnrollment = { _, _ in retiredLanded.increment(); return true }
        await retired.controller.reconcile()
        #expect(retired.controller.alwaysAskRetiredNotice?.kind == .alwaysAskRetiredWord)
        #expect(retiredLanded.value == 0 && retired.controller.enrollReading == nil)
    }

    /// The runner a Connect pin needs exists only so the sheet can open —
    /// the Connect road never touches it.
    private func inertLeaves(for w: World) -> PostureSwitchRunner.Leaves {
        PostureSwitchRunner.Leaves(
            scope: "Variorum", storeURL: URL(fileURLWithPath: "/dev/null"),
            database: try! AppDatabase.inMemory(), gate: StoreLaunchGate.scripted(
                dials: w.dialsBox, backing: w.backing, envelope: w.envelopeBox, stamps: w.stamps, appleKey: w.appleKeys),
            keyStore: .inMemory(), keyProvider: DeviceKeySyncProvider(store: .inMemory()),
            vault: nil, transport: nil, signedIn: { true },
            appleKeys: .inMemory(backing: w.appleKeys),
            libraryKeyInHand: { nil as StoreKey? }, posture: { .standard }, alwaysAsk: { false }, biometryAvailable: { true },
            moveCustody: { _ in .refused("inert") },
            rekeyLibrary: { _, _, _ in }, pauseSync: {}, resumeSync: {},
            takeSnapshot: { .notKept }, preSwitchSnapshots: { _ in [] }, deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: "io.lduarte.variorum.tests.3a.inert")! },
            reconcile: {}, now: { Date() }, log: { _ in })
    }

    // MARK: - pre-13x 2c: THE FOLLOW's detection (§7 / §3.6)

    private func rotatedReading(
        appleHeld: Bool, corpusKeyID: String = "corpus-2", user: String = "user-1"
    ) -> VaultPostureReading {
        VaultPostureReading(
            hasAppleHeldCopy: appleHeld, appleKeyID: appleHeld ? "a" : nil,
            passphraseKDF: fastKDF(), hasPassphraseWrap: true,
            corpusKeyID: corpusKeyID, updatedAt: "2026-09-04T10:00:00Z",
            updatedByDevice: "Lillian's iPhone", signedInUserID: user, hasRecoveryWrap: true)
    }

    /// §7: a Standard device whose account entered Castle elsewhere — the
    /// vault's corpus key id ≠ custody's under the SAME owner ⇒ the follow is
    /// owed; the notice names *[device] on [day]* (decision 34); *Later*
    /// leaves the persistent banner; the landing clears it. RED-ON-OLD: the
    /// reconcile READ the vault (2a) and derived the posture, but no verdict
    /// compared the key ids — `followNotice` stayed nil.
    @Test func aRotatedVaultUnderTheSameOwnerOwesTheFollowAndLaterLeavesTheBanner() async throws {
        let w = try world(enrolled: true)
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false)] in reading }
        await w.controller.reconcile()
        let owed = try #require(w.controller.followNotice)
        #expect(owed.kind == .movedToCastle, "Castle entered elsewhere, this library still Standard-shaped")
        #expect(owed.device == "Lillian's iPhone")
        #expect(owed.day == ProtectionCopy.day(from: "2026-09-04T10:00:00Z"))
        #expect(owed.body.hasPrefix("Your account is now in Castle — set on Lillian's iPhone on \(owed.day)."))
        #expect(w.controller.notice == .follow(owed))
        #expect(w.controller.followPending, "every key door says pick up your new keys first")
        #expect(!w.controller.differentOwner)

        w.controller.deferFollow()
        #expect(w.controller.notice == .followWaiting(owed), "Later ⇒ the persistent banner")
        #expect(owed.waitingBody == "Sync is paused until you enter your passphrase once — your keys were replaced on Lillian's iPhone on \(owed.day).")

        w.controller.followLanded()
        #expect(!w.controller.followPending)
        #expect(w.controller.notice != .followWaiting(owed) && w.controller.notice != .follow(owed))

        // Replace All Keys elsewhere (the vault still Standard-shaped) ⇒ the keys-replaced notice.
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: true)] in reading }
        await w.controller.reconcile()
        #expect(w.controller.followNotice?.kind == .keysReplaced)
        #expect(w.controller.followNotice?.body == "Your keys were replaced on Lillian's iPhone on \(owed.day). Enter your passphrase once to pick up the new ones.")
        #expect(w.controller.notice == .follow(w.controller.followNotice!), "a NEW rotation asks again even after Later")
    }

    /// §3.6 — THE OWNER DISTINCTION: the rows' `owner_id` stamp is not the
    /// signed-in account ⇒ copy §3's keys-don't-match sentence, NO follow
    /// (following would land another account's keys over this library).
    @Test func aDifferentOwnerSpeaksTheKeysDontMatchSentenceAndOwesNoFollow() async throws {
        let w = try world(enrolled: true)
        w.controller.foreignOwner = { _ in true }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: false)] in reading }
        let fileBefore = w.envelopeBox.value
        await w.controller.reconcile()
        #expect(w.controller.differentOwner)
        #expect(w.controller.notice == .differentOwner)
        // pre-13x 3a (§12): a change on another account never locks a device
        // out of its own library — the verdict writes nothing and moves nothing.
        #expect(w.envelopeBox.value == fileBefore && w.backing.auto == w.key && w.backing.gated == nil,
                "the key file and custody untouched under a foreign verdict")
        #expect(w.syncLeaves.plainRecord?.material != nil, "the held sync material stays — nothing is dropped")
        #expect(w.controller.followNotice == nil, "a different vault is the adopt road's (batch 3), never the follow's")
        #expect(!w.controller.followPending)
        #expect(ProtectionCopy.keysDontMatchThisLibrary
                == "This account's keys don't match this library. Enter your passphrase to connect it — everything in it will upload to this account.")
        // An unstamped library (never synced) has nothing to disagree with.
        w.controller.foreignOwner = { _ in false }
        await w.controller.reconcile()
        #expect(!w.controller.differentOwner)
        #expect(w.controller.followNotice?.kind == .movedToCastle)
    }

    /// §7 — the follow INTO Standard is silent: the vault carries an
    /// Apple-held copy under the SAME corpus key id and this Castle-shaped
    /// library carries none ⇒ the wired act runs once and the one-time
    /// notice speaks; under a DIFFERENT key id the act never runs (the
    /// follow is owed instead). RED-ON-OLD: the act was never called.
    @Test func theFollowIntoStandardRunsSilentlyWhenTheVaultCarriesAnAppleCopyUnderTheSameKey() async throws {
        let w = try world(standard: false, enrolled: true)
        let acts = LockedCounter()
        w.controller.followIntoStandardAct = { acts.increment() }
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: true, corpusKeyID: "corpus")] in reading }
        await w.controller.reconcile()
        #expect(acts.value == 1, "the silent follow ran")
        #expect(w.controller.followNotice == nil)
        let moved = try #require(w.controller.movedToStandardNotice)
        #expect(w.controller.notice == .movedToStandard(moved))
        #expect(moved.body.hasPrefix("Your account is back in Standard — set on Lillian's iPhone on \(moved.day)."))
        w.controller.dismissMovedToStandard()
        #expect(w.controller.movedToStandardNotice == nil)

        // A rotated vault with an Apple copy ⇒ keys replaced (the follow), the silent act untouched.
        let other = try world(standard: false, enrolled: true)
        let otherActs = LockedCounter()
        other.controller.followIntoStandardAct = { otherActs.increment() }
        other.controller.foreignOwner = { _ in false }
        other.controller.readVaultPosture = { [reading = rotatedReading(appleHeld: true)] in reading }
        await other.controller.reconcile()
        #expect(otherActs.value == 0, "a rotation is the follow's, never the silent road's")
        #expect(other.controller.followNotice?.kind == .keysReplaced)
    }

    /// Decision 10's exception (§3.6): an Always-ask device holds no sync
    /// keys before the vault read — the DERIVED key the lobby held opens the
    /// vault's master copy when the descriptors agree (the session fills,
    /// silently); a retired word (descriptors differ, the key file's recorded
    /// corpus id = the vault's) speaks the Always-ask banner; a rotation
    /// (recorded id ≠ the vault's) owes the follow. RED-ON-OLD: the session
    /// never filled and neither notice existed.
    @Test func anAlwaysAskDevicesHeldDerivedKeyFillsTheSessionOrTheRetiredWordBannerSpeaks() async throws {
        let kdf = fastKDF()
        let derived = try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: kdf)
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: derived, recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "corpus-9", key: corpus),
                        (keyClass: .journalBridge, keyID: "bridge-9", key: SymmetricKey(size: .bits256))],
            kdf: kdf)
        var reading = VaultPostureReading(
            hasAppleHeldCopy: false, appleKeyID: nil, passphraseKDF: kdf, hasPassphraseWrap: true,
            corpusKeyID: "corpus-9", updatedAt: "2026-09-04T10:00:00Z",
            updatedByDevice: "Lillian's iPhone", signedInUserID: "user-1", hasRecoveryWrap: false)
        reading.format = format

        // pre-13x 3a: an ENROLLED Always-ask library carries the key file's
        // master copy + the recorded corpus key id (the migration's leg 5 /
        // the landing). pre-13x 3b (ledger 52): the retired-word banner
        // needs that signature (the recorded id IS the vault's — a word
        // changed elsewhere); the fill in (a) does not.
        func enrolledFile(recordedID: String) throws -> (StoreKey, StoreKeyEnvelope) {
            let key = StoreKey.mint()
            var file = StoreKeyEnvelope()
            try file.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
            try file.setMasterWrappedCopy(key: key, under: master)
            try file.recordVaultReconciliation(kdf: kdf, corpusKeyID: recordedID, recoveryWrapDigest: nil)
            return (key, file)
        }
        // (a) the held derived key opens the vault ⇒ the session fills.
        // pre-13x 3b (ledger 52): the BARE shape again — no master copy, no
        // recorded id — the fill never needed 3a's enrollment signature.
        let filledKey = StoreKey.mint()
        var filledFile = StoreKeyEnvelope()
        try filledFile.setPassphraseWrap(key: filledKey, passphrase: "sesame", kdf: fastKDF())
        let filled = try world(standard: false, dials: ProtectionDials(alwaysAsk: true), key: filledKey, envelope: filledFile)
        #expect(filled.controller.effectiveGate == .passphrase)
        #expect(filled.syncSession.record?.material == nil, "Always ask holds nothing before the read")
        filled.syncSession.holdDerivedWrappingKey(derived, kdf: kdf)
        filled.controller.foreignOwner = { _ in false }
        filled.controller.readVaultPosture = { [reading] in reading }
        await filled.controller.reconcile()
        #expect(filled.syncSession.record?.material?.corpusKeyID == "corpus-9", "the sync keys are held for the session")
        #expect(filled.syncSession.record?.material?.masterKey == master.withUnsafeBytes { Data($0) })
        #expect(filled.controller.followNotice == nil && filled.controller.alwaysAskRetiredNotice == nil)

        // (b) the word was CHANGED elsewhere: a derived key under another descriptor.
        let (retiredKey, retiredFile) = try enrolledFile(recordedID: "corpus-9")
        let retired = try world(standard: false, dials: ProtectionDials(alwaysAsk: true), key: retiredKey, envelope: retiredFile)
        retired.syncSession.holdDerivedWrappingKey(
            try PassphraseKDF.deriveKey(passphrase: "old word", descriptor: fastKDF()), kdf: fastKDF())
        retired.controller.foreignOwner = { _ in false }
        retired.controller.readVaultPosture = { [reading] in reading }
        await retired.controller.reconcile()
        #expect(retired.syncSession.record?.material == nil)
        let banner = try #require(retired.controller.alwaysAskRetiredNotice)
        #expect(retired.controller.notice == .alwaysAskRetiredWord(banner))
        #expect(banner.body == "Your passphrase was changed on Lillian's iPhone on \(banner.day). The old one still opens this \(ProtectionCopy.deviceName), but sync waits until you enter the new one here.")
        #expect(!retired.controller.followPending, "sync waits, but no rotation is owed")

        // (c) the key file recorded ANOTHER corpus id: the account rotated ⇒ the follow.
        var recorded = StoreKeyEnvelope()
        let key = StoreKey.mint()
        try recorded.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        try recorded.setMasterWrappedCopy(key: key, under: SymmetricKey(size: .bits256))
        try recorded.recordVaultReconciliation(kdf: fastKDF(), corpusKeyID: "corpus-old", recoveryWrapDigest: nil)
        let rotated = try world(standard: false, dials: ProtectionDials(alwaysAsk: true), key: key, envelope: recorded)
        rotated.syncSession.holdDerivedWrappingKey(
            try PassphraseKDF.deriveKey(passphrase: "sesame", descriptor: fastKDF()), kdf: fastKDF())
        rotated.controller.foreignOwner = { _ in false }
        rotated.controller.readVaultPosture = { [reading] in reading }
        await rotated.controller.reconcile()
        #expect(rotated.controller.followNotice?.kind == .keysReplaced)
        #expect(rotated.controller.alwaysAskRetiredNotice == nil)
    }
    // MARK: - pre-13x 4a: THE CHANGE NOTICES ON EVERY GATE (copy §5's first two lines; ledger 33 · 53)

    /// A Touch ID / Face ID device that opened SILENTLY learns at ready
    /// that the passphrase was changed elsewhere (the key file's recorded
    /// descriptor ≠ the vault's) — copy §5's sentence with *Enter It Now…*,
    /// never a follow (sync keeps running); the door's landing
    /// (`reconcilePassphraseWrap` under the vault's descriptor) clears it;
    /// a device whose record already agrees owes nothing; the WORDS twin
    /// (ledger 53) rides the recovery-wrap digest the same way, and a nil
    /// record is unknown and owes nothing; the dismissal is per OPEN.
    @Test func aTouchIDDeviceLearnsAChangeElsewhereAtReadyAndTheDoorsLandingClearsIt() async throws {
        let key = StoreKey.mint()
        let oldKDF = fastKDF()
        let newKDF = fastKDF()
        func file(recordedKDF: PassphraseKDF.Descriptor, digest: String?) throws -> StoreKeyEnvelope {
            var file = StoreKeyEnvelope()
            try file.setPassphraseWrap(key: key, passphrase: "sesame", kdf: recordedKDF)
            try file.setMasterWrappedCopy(key: key, under: SymmetricKey(data: material().masterKey))
            try file.recordVaultReconciliation(kdf: recordedKDF, corpusKeyID: "corpus", recoveryWrapDigest: digest)
            return file
        }
        let reading: @Sendable (PassphraseKDF.Descriptor, String?) -> VaultPostureReading = { kdf, digest in
            VaultPostureReading(
                hasAppleHeldCopy: false, appleKeyID: nil, passphraseKDF: kdf, hasPassphraseWrap: true,
                corpusKeyID: "corpus", updatedAt: "2026-09-04T10:00:00Z",
                updatedByDevice: "Lillian's iPhone", signedInUserID: "user-1", hasRecoveryWrap: true,
                recoveryWrapDigest: digest)
        }
        // (a) The passphrase was changed elsewhere: a Castle Touch ID device,
        //     material in hand (the gated item + the session), the ids equal.
        let w = try world(standard: false, key: key, envelope: try file(recordedKDF: oldKDF, digest: "d1"), enrolled: true)
        #expect(w.controller.effectiveGate == .biometric)
        w.controller.foreignOwner = { _ in false }
        w.controller.readVaultPosture = { reading(newKDF, "d1") }
        await w.controller.reconcile()
        let change = try #require(w.controller.changeNotice)
        #expect(change.kind == .passphraseChangedElsewhere && change.vaultKDF == newKDF)
        #expect(change.body == "Your passphrase was changed on Lillian's iPhone on \(change.day). Use the new one here when you can — this \(ProtectionCopy.deviceName) still takes the old one until you do.")
        #expect(w.controller.notice == .changedElsewhere(change))
        #expect(!w.controller.followPending && w.controller.followNotice == nil, "a convenience change — never a follow; sync keeps running")
        // Dismiss: gone for this open; the reset (the lock road's) brings it back.
        w.controller.dismissChangeNotice()
        #expect(w.controller.notice != .changedElsewhere(change))
        w.controller.resetPerOpenDeferrals()
        w.controller.refreshNotices()
        #expect(w.controller.notice == .changedElsewhere(change), "Later / dismiss is per OPEN")
        // The door's landing: the NEW word's copy under the vault's descriptor clears it.
        #expect(await w.controller.reconcilePassphraseWrap(
            passphrase: "the new word 12", vaultKDF: newKDF, corpusKeyID: "corpus", recoveryWrapDigest: "d1") == nil)
        w.controller.changeNoticeLanded()
        #expect(w.controller.changeNotice == nil && w.controller.notice != .changedElsewhere(change))
        await w.controller.reconcile()
        #expect(w.controller.changeNotice == nil, "the record agrees with the vault now")
        let landed = try #require(w.envelopeBox.value)
        #expect(landed.passphrase?.kdf == newKDF && landed.vaultKDF == newKDF)

        // (b) A device whose record already agrees owes nothing.
        let agreeing = try world(standard: false, key: key, envelope: try file(recordedKDF: newKDF, digest: "d1"), enrolled: true)
        agreeing.controller.foreignOwner = { _ in false }
        agreeing.controller.readVaultPosture = { reading(newKDF, "d1") }
        await agreeing.controller.reconcile()
        #expect(agreeing.controller.changeNotice == nil && agreeing.controller.notice != .changedElsewhere(change))

        // (c) THE WORDS TWIN (ledger 53): the recorded digest ≠ the vault's.
        let words = try world(standard: false, key: key, envelope: try file(recordedKDF: newKDF, digest: "d1"), enrolled: true)
        words.controller.foreignOwner = { _ in false }
        words.controller.readVaultPosture = { reading(newKDF, "d2") }
        await words.controller.reconcile()
        let regenerated = try #require(words.controller.changeNotice)
        #expect(regenerated.kind == .wordsRegeneratedElsewhere)
        #expect(regenerated.body == "Your twelve words were regenerated on Lillian's iPhone on \(regenerated.day). Use the new ones here when you can — this \(ProtectionCopy.deviceName) still takes the old ones until you do.")
        #expect(words.controller.notice == .changedElsewhere(regenerated) && !words.controller.followPending)
        // The door's landing: the new words' copy with the vault's digest clears it.
        let fresh = try RecoveryPhrase.generate()
        #expect(await words.controller.landRecoveryWrap(words: fresh, recoveryWrapDigest: "d2") == nil)
        words.controller.changeNoticeLanded()
        await words.controller.reconcile()
        #expect(words.controller.changeNotice == nil)
        #expect(try #require(words.envelopeBox.value).vaultRecoveryWrapDigest == "d2")

        // (d) A nil record is UNKNOWN — owes nothing.
        let unknown = try world(standard: false, key: key, envelope: try file(recordedKDF: newKDF, digest: nil), enrolled: true)
        unknown.controller.foreignOwner = { _ in false }
        unknown.controller.readVaultPosture = { reading(newKDF, "d2") }
        await unknown.controller.reconcile()
        #expect(unknown.controller.changeNotice == nil)

        // (e) A ROTATION outranks: a stale record beside a stale corpus id owes the follow, never the change notice.
        let rotated = try world(standard: false, key: key, envelope: try file(recordedKDF: oldKDF, digest: "d1"), enrolled: true)
        rotated.controller.foreignOwner = { _ in false }
        var rotatedReading = reading(newKDF, "d1")
        rotatedReading.corpusKeyID = "corpus-new"
        rotated.controller.readVaultPosture = { [rotatedReading] in rotatedReading }
        await rotated.controller.reconcile()
        #expect(rotated.controller.followNotice?.kind == .keysReplaced && rotated.controller.changeNotice == nil)
    }

}

/// A thread-safe counter for the scripted acts above.
final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int { lock.lock(); defer { lock.unlock() }; return count }
    func increment() { lock.lock(); count += 1; lock.unlock() }
}
