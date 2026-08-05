//
//  EncryptionFlowTests.swift
//  VariorumTests
//
//  Phase 14b, batch 3 (L9) — the app-layer E2EE seam: the EncryptionSession
//  state machine over an in-memory key store + a raw-JSON scripted vault
//  (public API only — no network, no core internals, never the real
//  Keychain), the refusal wording, and the sync status face's locked-state
//  classification with its keys-first no-network pin.
//
//  Phase 14b COPY/FLOW ROUND — the CF pins: the forget door (CF-11), the
//  biometric gate's arms + the passphrase fallback (CF-12's ruling, all
//  through the scripted in-memory backing — no real biometrics in tests),
//  the passphrase-authorized regenerate (CF-2), the setup flow's gates +
//  her exact checkbox sentence (CF-1/5/7), the CF-6/CF-13 copy pins, and
//  the terminology walk (nothing is ever called Passkey).
//
//  Phase 14b CROSSOVER ROUND — the CF-14/15/16 pins: the replaced-keys
//  projection + re-enroll road (CF-16, red-on-old against the
//  custody-exists-alone "enrolled"), the payload-crypto classifier and
//  its row face, the syncing row's door stability (CF-15), and the
//  locked/replaced states' one-act Encryption-tab doors with the sibling
//  "Encryption…" door retired (CF-14).
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// A raw-JSON `key_vault` PostgREST responder: stores the POSTed row bytes
/// verbatim and serves them back — the client's own encoder/decoder is the
/// only wire-shape authority exercised.
private final class ScriptedVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?

    var hasRow: Bool {
        lock.lock()
        defer { lock.unlock() }
        return row != nil
    }

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            guard row == nil else {
                return response(409, Data(#"{"code":"23505"}"#.utf8))
            }
            row = request.httpBody
            return response(201)
        case "PATCH":
            guard row != nil, let body = request.httpBody else {
                return response(200, Data("[]".utf8))
            }
            row = body
            return response(200, Data("[".utf8) + body + Data("]".utf8))
        default:
            return response(405)
        }
    }
}

@MainActor
private func makeEncryptionSession(
    store: DeviceKeyStore, vault: ScriptedVault
) -> EncryptionSession {
    let client = KeyVaultClient(
        configuration: KeyVaultClient.Configuration(
            projectURL: URL(string: "https://vault.test.invalid")!,
            apiKey: "publishable-test-key"),
        sessionProvider: StaticSessionProvider(
            session: UserSession(accessToken: "token-1", userID: "user-e2ee")),
        load: vault.load)
    return EncryptionSession(store: store, client: client, signedIn: { true })
}

@MainActor
@Suite("E2EE flows — the app seam (Phase 14b, L9)")
struct EncryptionFlowTests {
    @Test func setUpEnrollsThisDeviceAndFiresTheHealingHook() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        var healed = 0
        session.onKeysChanged = { healed += 1 }

        await session.setUp(passphrase: "orchard-lantern-13")

        #expect(session.lastError == nil)
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "Round 5: a fresh vault is passphrase-wrap-only — the phrase surface comes next")
        #expect(store.load() != nil, "custody landed in the (in-memory) key store")
        #expect(vault.hasRow, "the vault row was created")
        #expect(healed == 1, "landing keys triggers the sync heal exactly once")
        #expect(session.lastKDFSeconds.map { $0 > 0 } == true,
                "L12: the flow measures and surfaces its KDF derivation duration")
    }

    @Test func aWrongPassphraseSpeaksAndLandsNothing() async throws {
        let firstStore = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let first = makeEncryptionSession(store: firstStore, vault: vault)
        await first.setUp(passphrase: "orchard-lantern-13")
        #expect(first.lastError == nil)

        // A second device, same vault, wrong passphrase.
        let secondStore = DeviceKeyStore.inMemory()
        let second = makeEncryptionSession(store: secondStore, vault: vault)
        var healed = 0
        second.onKeysChanged = { healed += 1 }
        await second.enroll(passphrase: "orchard-lantern-14")

        #expect(second.lastError == "Wrong encryption passphrase.")
        #expect(secondStore.load() == nil, "a refused enrollment lands no keys")
        #expect(healed == 0)

        // The right passphrase enrolls the second device.
        await second.enroll(passphrase: "orchard-lantern-13")
        #expect(second.lastError == nil)
        #expect(secondStore.load() == firstStore.load(),
                "both devices hold the same unwrapped material")
    }

    @Test func refreshProjectsTheVaultAndCustodyStates() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)

        await session.refresh()
        #expect(session.state == .noVault)

        await session.setUp(passphrase: "orchard-lantern-13")
        await session.refresh()
        #expect(session.state == .enrolled(hasRecoveryWrap: false))

        // A fresh device against the same vault: not enrolled.
        let other = makeEncryptionSession(store: .inMemory(), vault: vault)
        await other.refresh()
        #expect(other.state == .notEnrolled(hasRecoveryWrap: false))
    }

    @Test func signedOutStateBlocksNothingButNamesTheOrder() async throws {
        let vault = ScriptedVault()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "k"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "t", userID: "u")),
            load: vault.load)
        let session = EncryptionSession(
            store: .inMemory(), client: client, signedIn: { false })
        await session.refresh()
        #expect(session.state == .signedOut,
                "the vault lives on the account — flows start with sign-in")
    }
}

// MARK: - The copy/flow round (Phase 14b — CF-1…CF-13 + the CF-12 ruling)

@MainActor
@Suite("The copy/flow round (Phase 14b — CF pins)")
struct CopyFlowRoundTests {
    private let passphrase = "orchard-lantern-13"

    /// CF-11's pin: forget ⇒ ZERO keys in custody, and the engine's key
    /// seam refuses again — the same `SyncKeyProviderError.notEnrolled`
    /// throw the locked-face pin proves surfaces as the visible locked
    /// line with zero transport contact. The account vault is untouched:
    /// the state returns to ENROLLMENT, never to setup.
    @Test func forgettingKeysClearsCustodyAndTheEngineSeamRefusesAgain() async throws {
        let backing = InMemoryKeyBacking()
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        #expect(session.lastError == nil)
        #expect(store.load() != nil)
        let provider = DeviceKeySyncProvider(store: store)
        #expect(throws: Never.self) { try provider.currentKeys() }

        var healed = 0
        session.onKeysChanged = { healed += 1 }
        await session.forgetDeviceKeys()

        #expect(store.load() == nil, "CF-11: forget ⇒ zero keys in custody")
        #expect(throws: SyncKeyProviderError.notEnrolled) {
            try provider.currentKeys()
        }
        #expect(session.state == .notEnrolled(hasRecoveryWrap: false),
                "the vault survives — this device just isn't enrolled anymore")
        #expect(healed == 1,
                "the hook fires so the next round surfaces the locked line NOW, not at the next cadence")
    }

    /// CF-12's gated arm: the toggle re-persists custody behind the gate;
    /// the SAME launch stays unlocked; a FRESH launch is locked — sync's
    /// key seam refuses — until the biometric unlock fills the launch.
    @Test func theBiometricGateLocksCustodyAcrossALaunchUntilUnlocked() async throws {
        let backing = InMemoryKeyBacking(
            biometryAvailable: true, biometricUnlockSucceeds: true)
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)

        session.setBiometricRequirement(true)
        #expect(session.lastError == nil)
        #expect(session.biometricRequired)
        #expect(store.load() != nil,
                "the toggle itself never locks the launch that flipped it")

        backing.simulateRelaunch()
        #expect(store.load() == nil,
                "a fresh launch is locked until an unlock")
        let provider = DeviceKeySyncProvider(store: store)
        #expect(throws: SyncKeyProviderError.notEnrolled) {
            try provider.currentKeys()
        }
        await session.refresh()
        #expect(session.state == .enrolledLocked(hasRecoveryWrap: false),
                "the surface offers the unlock, not re-enrollment")

        var healed = 0
        session.onKeysChanged = { healed += 1 }
        await session.unlockWithBiometrics()
        #expect(session.lastError == nil)
        #expect(store.load() != nil, "unlocked for the rest of the launch")
        #expect(session.state == .enrolled(hasRecoveryWrap: false))
        #expect(throws: Never.self) { try provider.currentKeys() }
        #expect(healed == 1, "the unlock heals sync immediately")
    }

    /// CF-12's fallback arm — her ruling's second half: biometric failure
    /// is never a dead end; the PASSPHRASE road unlocks the launch, and
    /// the gate policy SURVIVES it (turning it off is a deliberate act).
    @Test func aBiometricFailureFallsBackToThePassphraseRoadAndTheGateSurvives() async throws {
        let backing = InMemoryKeyBacking(
            biometryAvailable: true, biometricUnlockSucceeds: false)
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        session.setBiometricRequirement(true)
        backing.simulateRelaunch()

        await session.unlockWithBiometrics()
        #expect(session.lastError == EncryptionSession.biometricUnlockFailedMessage,
                "the failure speaks and names the fallback")
        #expect(store.load() == nil, "a failed unlock lands nothing")

        await session.enroll(passphrase: passphrase)
        #expect(session.lastError == nil)
        #expect(store.load() != nil,
                "the passphrase road re-derives from the vault and unlocks this launch")
        #expect(store.isBiometricGateOn(),
                "the gate survives the fallback — the policy is hers to turn off, never a side effect")
        #expect(session.state == .enrolled(hasRecoveryWrap: false))
    }

    /// CF-12's ungated arm: turning the gate OFF re-persists plain custody
    /// that reads across launches with no unlock at all (R-6's
    /// enrollment-only cadence, restored).
    @Test func turningTheGateOffRestoresUngatedCustodyAcrossLaunches() async throws {
        let backing = InMemoryKeyBacking(
            biometryAvailable: true, biometricUnlockSucceeds: true)
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        session.setBiometricRequirement(true)
        session.setBiometricRequirement(false)
        #expect(!session.biometricRequired)
        #expect(!store.isBiometricGateOn())

        backing.simulateRelaunch()
        #expect(store.load() != nil,
                "ungated custody reads across launches with no unlock")
        let provider = DeviceKeySyncProvider(store: store)
        #expect(throws: Never.self) { try provider.currentKeys() }
    }

    /// CF-2's pin: REGENERATING the phrase is authorized by the passphrase
    /// — a wrong passphrase refuses (verified against the vault by a real
    /// unwrap, never a local compare) and mints nothing; the right one
    /// mints 12 words whose confirm still lands through the replace road.
    @Test func regeneratingThePhraseIsAuthorizedByThePassphrase() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        let first = try #require(session.generatePhrase())
        await session.landRecoveryWrap(confirmedWords: first, allowReplace: false)
        #expect(session.state == .enrolled(hasRecoveryWrap: true))

        let refused = await session.generatePhraseAuthorized(passphrase: "not-the-passphrase")
        #expect(refused == nil, "a wrong passphrase mints nothing")
        #expect(session.lastError == "Wrong encryption passphrase.")

        let minted = await session.generatePhraseAuthorized(passphrase: passphrase)
        #expect(minted?.count == 12)
        #expect(session.lastError == nil)

        await session.landRecoveryWrap(
            confirmedWords: try #require(minted), allowReplace: true)
        #expect(session.lastError == nil)
        #expect(session.state == .enrolled(hasRecoveryWrap: true))
    }

    /// THE RE-KEY DRILL's step-0 pre-verification (the architect's mid-run
    /// handoff, 2026-08-04 — pinned BEFORE her live drill): a vault DELETED
    /// while local custody still EXISTS. `refresh()` maps the missing vault
    /// to `.noVault` regardless of custody (documented here), the setup
    /// flow proceeds, and `setUp()` OVERWRITES the stale custody cleanly —
    /// the provider serves the NEW corpus key, never the orphaned one, and
    /// the mandatory phrase step follows as for any fresh vault.
    @Test func aDeletedVaultWithStaleCustodyOffersSetupAndOverwritesCleanly() async throws {
        // Old world: a vault + enrolled custody.
        let backing = InMemoryKeyBacking()
        let store = DeviceKeyStore.inMemory(backing: backing)
        let oldVault = ScriptedVault()
        let oldSession = makeEncryptionSession(store: store, vault: oldVault)
        await oldSession.setUp(passphrase: "the-old-passphrase")
        let stale = try #require(store.load())

        // The vault is deleted (the drill's step 3) — custody survives.
        let freshVault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: freshVault)
        await session.refresh()
        #expect(session.state == .noVault,
                "a missing vault reads as no-vault even with stale custody — the setup flow is the offer")

        await session.setUp(passphrase: passphrase)
        #expect(session.lastError == nil)
        let fresh = try #require(store.load())
        #expect(fresh != stale, "setUp overwrites the stale custody wholesale")
        #expect(fresh.corpusKeyID != stale.corpusKeyID)
        let provider = DeviceKeySyncProvider(store: store)
        #expect(try provider.currentKeys().corpusKeyID == fresh.corpusKeyID,
                "sync serves the NEW key, never the orphaned one")
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "the mandatory phrase step follows, exactly as for any fresh vault")
    }

    /// CF-1/5/7: the stepped setup flow's gates — the passphrase step
    /// requires a matched non-empty entry, the warning step refuses to
    /// advance without HER checkbox, and the checkbox's label is her exact
    /// sentence.
    @Test func theSetupStepsRefuseToAdvanceWithoutTheirGates() {
        #expect(!EncryptionSetupRules.canLeavePassphraseStep(passphrase: "", confirm: ""))
        #expect(!EncryptionSetupRules.canLeavePassphraseStep(passphrase: "a", confirm: "b"))
        #expect(EncryptionSetupRules.canLeavePassphraseStep(passphrase: "a", confirm: "a"))

        #expect(!EncryptionSetupRules.canLeaveWarningStep(acknowledged: false),
                "CF-7: the warning step refuses to advance without the checkbox")
        #expect(EncryptionSetupRules.canLeaveWarningStep(acknowledged: true))

        #expect(EncryptionView.understandingCheckbox
                == "I understand that if I lose my recovery phrase and my passphrase, "
                + "that I will not be able to recover anything from sync or add new devices",
                "her exact sentence IS the checkbox copy")
    }

    /// CF-6's pin: the warning says the LOCAL copy survives (her find: "it
    /// seems like your local copy will be destroyed with the current
    /// phrasing") — while keeping the honest unrecoverable-by-design core.
    @Test func theWarningCopyCarriesTheLocalCopyClarification() {
        #expect(EncryptionView.setupWarning.contains(
            "the writing already on your devices stays readable"))
        #expect(EncryptionView.setupWarning.contains("Variorum cannot reset it"),
                "the honest core survives the clarification")
        #expect(EncryptionView.wholePhraseIsTheSecret.contains("no single word is a password"),
                "CF-13: the whole phrase is the secret")
    }
}

// MARK: - The crossover round (Phase 14b — CF-14 · CF-15 · CF-16)

@MainActor
@Suite("The crossover round (Phase 14b — CF-14/15/16 pins)")
struct CrossoverRoundTests {
    /// CF-16 (a), RED-ON-OLD: before the fix, `refresh()` decided
    /// "enrolled" by custody-exists alone (EncryptionSession.swift:105 in
    /// the landed round) — a re-keyed account's stale device read
    /// `.enrolled` while its rounds failed generically. Now the key-id
    /// comparison projects the honest REPLACED state, custody untouched by
    /// the projection itself.
    @Test func aReKeyedAccountProjectsTheReplacedStateOverStaleCustody() async throws {
        // The old world: this device enrolls against vault #1.
        let store = DeviceKeyStore.inMemory(backing: InMemoryKeyBacking())
        let oldVault = ScriptedVault()
        let old = makeEncryptionSession(store: store, vault: oldVault)
        await old.setUp(passphrase: "the-old-passphrase")
        #expect(old.lastError == nil)
        let stale = try #require(store.load())

        // The account is RE-KEYED elsewhere (the drill's shape: vault
        // deleted, a fresh setup ran) — a new vault with new class-key ids
        // now answers for the account; this device's custody survives.
        let freshVault = ScriptedVault()
        let reKeyer = makeEncryptionSession(store: .inMemory(), vault: freshVault)
        await reKeyer.setUp(passphrase: "the-new-passphrase")
        #expect(reKeyer.lastError == nil)

        let session = makeEncryptionSession(store: store, vault: freshVault)
        await session.refresh()
        #expect(session.state == .keysReplaced(hasRecoveryWrap: false),
                "CF-16: stale custody against a re-keyed vault projects REPLACED — never a false 'enrolled'")
        #expect(store.load() == stale,
                "the projection alone touches nothing — custody is replaced only by the re-enroll save")
    }

    /// CF-16 (b): the replaced state's road is ORDINARY re-enrollment —
    /// the enroll save overwrites custody wholesale (the step-0 proven
    /// class) and the device reads `.enrolled` again, serving the NEW key.
    @Test func reEnrollingFromTheReplacedStateOverwritesCustodyWholesale() async throws {
        let store = DeviceKeyStore.inMemory(backing: InMemoryKeyBacking())
        let oldVault = ScriptedVault()
        let old = makeEncryptionSession(store: store, vault: oldVault)
        await old.setUp(passphrase: "the-old-passphrase")
        let stale = try #require(store.load())

        let freshVault = ScriptedVault()
        let reKeyer = makeEncryptionSession(store: .inMemory(), vault: freshVault)
        await reKeyer.setUp(passphrase: "the-new-passphrase")

        let session = makeEncryptionSession(store: store, vault: freshVault)
        await session.refresh()
        #expect(session.state == .keysReplaced(hasRecoveryWrap: false))

        await session.enroll(passphrase: "the-new-passphrase")
        #expect(session.lastError == nil)
        let fresh = try #require(store.load())
        #expect(fresh != stale, "the enroll save overwrites the stale custody wholesale")
        #expect(fresh.corpusKeyID != stale.corpusKeyID)
        #expect(session.state == .enrolled(hasRecoveryWrap: false))
        let provider = DeviceKeySyncProvider(store: store)
        #expect(try provider.currentKeys().corpusKeyID == fresh.corpusKeyID,
                "sync serves the NEW key, never the orphaned one")
        await session.refresh()
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "a fresh projection agrees — the ids match again")
    }

    /// CF-16 (c): the app-side classifier — true for the engine's
    /// payload-crypto refusal (whatever row it names), false for the
    /// locked-keys refusal, the unencrypted-value refusal (the other
    /// "Sync refused:" case, which never means stale keys), and anything
    /// else.
    @Test func theCryptoFailureClassifierMatchesTheEngineRefusalShape() {
        #expect(EncryptionSession.isPayloadCryptoError(
            String(describing: SyncError.payloadCryptoFailure(
                table: "variant", rowID: "r-1", column: "working_text",
                detail: "authenticationFailure"))))
        #expect(EncryptionSession.isPayloadCryptoError(
            String(describing: SyncError.payloadCryptoFailure(
                table: "tag", rowID: "t-9", column: "path", detail: "x"))),
                "row coordinates vary — the classifier holds across them")
        #expect(!EncryptionSession.isPayloadCryptoError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!EncryptionSession.isPayloadCryptoError(
            String(describing: SyncError.unencryptedValueInEncryptedColumn(
                table: "variant", rowID: "r-1", column: "working_text"))))
        #expect(!EncryptionSession.isPayloadCryptoError("Sync error: something else"))
    }

    /// Phase 14c — the FENCE's classifier arm (CF-16's new server-side
    /// trigger): the vault-key-id fence refusal classifies TRUE here and
    /// FALSE everywhere it must not; the other classifiers stay disjoint
    /// from it.
    @Test func theFenceRefusalClassifiesIntoTheReplacedStateAndNowhereElse() {
        let fence = String(describing: SyncError.encryptionKeysReplaced)
        #expect(EncryptionSession.isKeysReplacedError(fence))
        #expect(!EncryptionSession.isKeysReplacedError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!EncryptionSession.isKeysReplacedError(
            String(describing: SyncError.syncNotEntitled)),
            "the tier refusal is NOT a keys state — it must never wear the replaced face")
        #expect(!EncryptionSession.isPayloadCryptoError(fence),
                "the two CF-16 arms are disjoint classifiers for one state")
        #expect(!EncryptionSession.isKeysLockedError(fence))
    }

    /// Phase 14c: the fence refusal PRESENTS as the same replaced-keys row
    /// as the payload-crypto arm — one state, one face, one door (the
    /// Encryption tab), whichever trigger fired.
    @Test func theFenceRefusalPresentsAsTheReplacedRow() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false,
            lastError: String(describing: SyncError.encryptionKeysReplaced),
            lastErrorIsOffline: false)
        #expect(face.kind == .keysReplaced)
        #expect(face.doors == [SyncRowFace.Door(
            label: "Re-enroll…", act: .openAccount(.encryption))],
                "the fence's row door opens the Encryption tab directly — CF-16's one act")
    }

    /// CF-16 (the classifier's face) + the ruled copy: a payload-crypto
    /// refusal presents as the replaced-keys row with ONE door opening the
    /// Encryption tab, and the surface's headline is the ruled sentence
    /// byte-exact.
    @Test func theReplacedRowNamesTheFixAndOpensTheEncryptionTab() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false,
            lastError: String(describing: SyncError.payloadCryptoFailure(
                table: "variant", rowID: "r-1", column: "working_text",
                detail: "authenticationFailure")),
            lastErrorIsOffline: false)
        #expect(face.kind == .keysReplaced)
        #expect(face.doors == [SyncRowFace.Door(
            label: "Re-enroll…", act: .openAccount(.encryption))],
                "the replaced row's one door opens the Encryption tab directly")
        #expect(EncryptionView.keysReplacedExplanation
                == "This account's encryption keys were replaced. Enter your passphrase to re-enroll.",
                "the ruled copy shape, byte-exact")
    }

    /// CF-15, RED-ON-OLD: the old `isSyncing` branch REPLACED the row's
    /// content ("Sync now"/"Account…" vanished and reappeared every
    /// round). Her ruling: the buttons must not move — "Sync now" stays
    /// present and merely disables; "Account…" stays present.
    @Test func theSyncingRowKeepsItsDoorsAndMerelyDisablesSyncNow() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: true, lastError: nil, lastErrorIsOffline: false)
        #expect(face.kind == .syncing)
        let syncNow = face.doors.first { $0.label == "Sync now" }
        #expect(syncNow != nil, "CF-15: 'Sync now' stays present while a round runs")
        #expect(syncNow?.enabled == false, "…and merely disables")
        #expect(face.doors.contains { $0.label == "Account…" && $0.enabled },
                "'Account…' stays present (and usable) too")
    }

    /// CF-14: the LOCKED state's own affordance reaches the unlock surface
    /// in ONE act — the door opens the tabbed Account sheet directly at
    /// the Encryption tab, never buried behind the Account tab.
    @Test func theLockedRowReachesTheUnlockSurfaceInOneAct() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false,
            lastError: String(describing: SyncError.encryptionKeysUnavailable),
            lastErrorIsOffline: false)
        #expect(face.kind == .keysLocked)
        #expect(face.doors == [SyncRowFace.Door(
            label: "Unlock…", act: .openAccount(.encryption))],
                "CF-14: 'Unlock…' stays in place and opens the Encryption tab in one act")
    }

    /// CF-14 (the retirement half): the separate "Encryption…" sibling
    /// door is gone from every face — the surface is reached through the
    /// Account sheet's Encryption tab (or the locked/replaced states' own
    /// one-act doors).
    @Test func theSeparateEncryptionDoorIsRetiredIntoTheAccountTabs() {
        let idle = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: nil, lastErrorIsOffline: false)
        #expect(idle.kind == .idle)
        #expect(idle.doors == [
            SyncRowFace.Door(label: "Sync now", act: .syncNow),
            SyncRowFace.Door(label: "Account…", act: .openAccount(.account)),
        ], "the idle row offers exactly Sync now + Account… — no sibling Encryption door")

        // Sweep the face family: no face anywhere mints an "Encryption…"
        // door (the retired label), and every encryption-targeted door
        // belongs to the locked or replaced state.
        let errors: [String?] = [
            nil,
            "Sync error: something else",
            String(describing: SyncError.encryptionKeysUnavailable),
            String(describing: SyncError.payloadCryptoFailure(
                table: "variant", rowID: "r", column: "working_text", detail: "d")),
        ]
        for isSyncing in [false, true] {
            for error in errors {
                for offline in [false, true] {
                    let face = SyncRowFace.face(
                        allowsSync: true, isConfigured: true, signedIn: true,
                        isSyncing: isSyncing, lastError: error,
                        lastErrorIsOffline: offline)
                    #expect(!face.doors.contains { $0.label == "Encryption…" })
                    for door in face.doors
                    where door.act == .openAccount(.encryption) {
                        #expect(face.kind == .keysLocked || face.kind == .keysReplaced)
                    }
                }
            }
        }
    }
}

// MARK: - The account lifecycle doors (Phase 14c, batch 2 — CF-8 + deletion)

@MainActor
@Suite("The account lifecycle doors (Phase 14c, batch 2)")
struct AccountLifecycleDoorTests {
    private func material(_ seed: UInt8) -> DeviceKeyMaterial {
        DeviceKeyMaterial(
            masterKey: Data(repeating: seed, count: 32),
            corpusKey: Data(repeating: seed &+ 1, count: 32),
            corpusKeyID: "corpus-\(seed)",
            journalBridgeKey: Data(repeating: seed &+ 2, count: 32),
            journalBridgeKeyID: "journal-\(seed)")
    }

    /// CF-8's flow state machine: a successful run lands in
    /// `enrolled(hasRecoveryWrap: false)` — the standing CF-5 MANDATORY
    /// phrase step (the old phrase died with the old master; setup's own
    /// machinery mints the new one) — with the runner-adopted custody in
    /// place.
    @Test func theRekeyDoorLandsInTheMandatoryPhraseStepWithNewCustody() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: "the-old-passphrase")
        let old = try #require(store.load())

        let fresh = material(7)
        session.rekeyRunner = { passphrase in
            #expect(passphrase == "the-old-passphrase")
            // The runner's CONTRACT: custody adopted mid-run.
            await MainActor.run { session.adoptRekeyedMaterial(fresh) }
            return fresh
        }
        var healed = 0
        session.onKeysChanged = { healed += 1 }
        await session.rekeyAccount(passphrase: "the-old-passphrase")

        #expect(session.lastError == nil)
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "the landing IS the CF-5 mandatory phrase step — the new 12 words follow")
        #expect(store.load() == fresh, "custody holds the NEW keys")
        #expect(store.load() != old)
        #expect(healed == 1, "adoption fires the healing hook")
    }

    /// The non-atomic sequence's honest voice: ANY mid-run failure speaks
    /// the rerun road (the brain's pinned recovery), never a bare error.
    @Test func aFailedRekeySpeaksTheRerunRoad() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: "the-old-passphrase")

        session.rekeyRunner = { _ in
            throw AccountLifecycleError.httpFailure(status: 503, body: "gateway")
        }
        await session.rekeyAccount(passphrase: "the-old-passphrase")
        let error = try #require(session.lastError)
        #expect(error.contains("run Replace Keys again"),
                "the rerun road is spoken on every failure")
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "the state is untouched by the failure (setup's step-4 state stands)")
    }

    /// No runner wired (unconfigured project) ⇒ the door refuses in the
    /// standing dormant grammar, exactly like the other flows.
    @Test func theRekeyDoorIsDormantWithoutARunner() async throws {
        let session = makeEncryptionSession(
            store: .inMemory(), vault: ScriptedVault())
        await session.rekeyAccount(passphrase: "anything")
        #expect(session.lastError == "Project keys not configured (ProjectConfig.swift)")
    }

    /// THE COPY PINS. Her Round-5 pinned rule (the CF-6 class): the
    /// deletion door's copy MUST say the local copy survives — what dies
    /// is the synced copy and the account. And the re-key copy names what
    /// a re-key does to OTHER devices (the CF-16 replaced state +
    /// re-enroll) and to the recovery phrase.
    @Test func theDoorCopySaysTheLocalCopySurvivesAndNamesTheConsequences() {
        // The deletion door — her pinned rule, byte-anchored.
        #expect(AccountView.deleteAccountExplanation.contains(
            "The writing on this device stays on this device"),
            "HER PINNED RULE: the deletion copy says the local copy survives")
        #expect(AccountView.deleteAccountExplanation.contains(
            "anything on your other devices stays there too"))
        #expect(AccountView.deleteAccountExplanation.contains(
            "Only the account and its synced copy are deleted"))
        #expect(AccountView.deleteAccountExplanation.contains("permanently"),
                "the consequence is named honestly beside the survival")
        #expect(AccountView.deleteSubscriptionAdvisory.contains("cancel it first"),
                "subscription state warned first — the ruling's letter")
        #expect(AccountView.deleteConfirmationPhrase == "delete my account")

        // The re-key door — the honest warning names the other devices'
        // fate and the phrase's death (the CF-7 checkbox grammar).
        #expect(EncryptionView.rekeyExplanation.contains("Every OTHER device will pause syncing"))
        #expect(EncryptionView.rekeyExplanation.contains("re-enroll"))
        #expect(EncryptionView.rekeyExplanation.contains(
            "Your writing on this device is untouched"))
        #expect(EncryptionView.rekeyExplanation.contains(
            "current recovery phrase stops working"))
        #expect(EncryptionView.rekeyUnderstandingCheckbox.contains("I understand"))
    }
}

// MARK: - The doors' AppServices wiring (Phase 14c, batch 2)

@MainActor
@Suite("Account door wiring (Phase 14c, batch 2)", .serialized)
struct AccountDoorWiringTests {
    private actor RecordingLifecycle: AccountLifecycleProviding {
        private(set) var truncateKeyIDs: [String] = []
        private(set) var purgeCalls = 0
        func truncateAccountData(activeKeyID: String) async throws -> [String: Int] {
            truncateKeyIDs.append(activeKeyID)
            return [:]
        }
        func purgeAccount() async throws -> AccountPurgeReport {
            purgeCalls += 1
            return AccountPurgeReport(
                dataRows: 1, vaultRows: 1, entitlementRows: 1, authUserRemoved: true)
        }
        func fetchEntitlements() async throws -> [AccountEntitlement] { [] }
    }

    private actor QuietTransport: SyncTransport {
        func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome] {
            batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String) async throws -> [SyncPulledRow] { [] }
        func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
    }

    /// One composed world: real AppServices over an in-memory store, an
    /// in-memory auth session (adopted tokens), the shared scripted vault
    /// serving BOTH the encryption session and the door brains (the
    /// one-Postgres shape), and the recording lifecycle.
    private func withDoorWorld(
        _ body: @MainActor (AppServices, EncryptionSession, DeviceKeyStore,
                            RecordingLifecycle, AppDatabase, AuthSession) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let authStore = AuthTokensStore.inMemory()
        let auth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://variorum-project.test.invalid")!,
                apiKey: "publishable"),
            store: authStore,
            http: { _ in throw AuthSessionError.malformedResponse("no network") })
        await auth.adopt(AuthTokens(
            accessToken: "access", refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userID: "user-door", email: "door@example.com"))
        let vault = ScriptedVault()
        let keyVault = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key"),
            sessionProvider: auth,
            load: vault.load)
        let fragmentsAuth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://fragments-project.test.invalid")!,
                apiKey: "publishable"),
            store: .inMemory(),
            http: { _ in throw AuthSessionError.malformedResponse("no network") })
        let store = DeviceKeyStore.inMemory()
        let encryption = EncryptionSession(
            store: store, client: keyVault, signedIn: { true })
        let lifecycle = RecordingLifecycle()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.ownerIdentity = OwnerIdentity { authStore.load()?.userID }
        } operation: { @MainActor in
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .real,
                backupEnabled: false, bridgeEnabled: false,
                auth: auth, fragmentsAuth: fragmentsAuth, encryption: encryption,
                makeSyncTransport: { _ in QuietTransport() },
                makeSyncKeyProvider: { AppTestKeyProvider() },
                keyVault: keyVault,
                makeAccountLifecycle: { _ in lifecycle })
            await services.start()
            try await body(services, encryption, store, lifecycle, db, auth)
            services.stop()
        }
    }

    /// THE REKEY WIRING, end to end through the app seam: the wired
    /// runner drives the REAL brain — new vault written (new ids), the
    /// truncate presented the NEW corpus key id, custody adopted mid-run,
    /// the store fully re-enqueued, the bridge's agreed day staged — and
    /// the flow lands in the mandatory phrase step.
    @Test func theRekeyWiringRunsTheBrainAdoptsCustodyAndReEnqueues() async throws {
        try await withDoorWorld { services, encryption, store, lifecycle, db, _ in
            await encryption.setUp(passphrase: "orchard-lantern-13")
            #expect(encryption.lastError == nil)
            let old = try #require(store.load())
            // A synced row + an agreed bridge day, both pre-re-key.
            _ = try await services.session.runner.run { ops in
                try ops.createPost(title: "pre-rekey").id
            }
            try await db.write { dbi in
                try dbi.execute(
                    sql: "INSERT INTO bridge_day (day_key, last_synced_hash) VALUES (?, ?)",
                    arguments: ["2026-08-01", "aaaa1111"])
            }

            await encryption.rekeyAccount(passphrase: "orchard-lantern-13")

            #expect(encryption.lastError == nil)
            #expect(encryption.state == .enrolled(hasRecoveryWrap: false),
                    "the mandatory NEW phrase step follows the re-key")
            let fresh = try #require(store.load())
            #expect(fresh.corpusKeyID != old.corpusKeyID, "custody holds the NEW keys")
            #expect(await lifecycle.truncateKeyIDs == [fresh.corpusKeyID],
                    "the truncate presented the NEW key id — after the vault write, by the brain's pinned order")
            let outbox = try #require(try db.doorInt("SELECT COUNT(*) FROM sync_outbox"))
            let rows = try #require(try db.doorInt(
                "SELECT (SELECT COUNT(*) FROM container) + (SELECT COUNT(*) FROM block) + (SELECT COUNT(*) FROM variant) + (SELECT COUNT(*) FROM container_block)"))
            #expect(outbox >= rows, "resyncReinitialize re-enqueued the store")
            let stagedHash = try #require(try db.doorString(
                "SELECT last_synced_hash FROM bridge_day WHERE day_key = '2026-08-01'"))
            #expect(stagedHash == "restaged:repush-from-truth",
                    "the bridge's staged re-push trigger rode the re-key (inert until 14d; the literal is core's restagedHashSentinel, symbol-pinned there)")
        }
    }

    /// THE DELETION WIRING: the purge runs only under the verified
    /// passphrase; success clears custody (the CF-11 machinery) and signs
    /// out; refusal touches NOTHING local — the wrong-passphrase arm is
    /// the order's own proof (server first, local after).
    @Test func theDeletionWiringPurgesThenForgetsThenSignsOut() async throws {
        try await withDoorWorld { services, encryption, store, lifecycle, db, auth in
            await encryption.setUp(passphrase: "orchard-lantern-13")
            #expect(store.load() != nil)
            let signedInBefore = await auth.currentUserID
            #expect(signedInBefore != nil)

            // The wrong-passphrase arm: nothing server-side, nothing local.
            await services.deleteAccount(passphrase: "not-the-passphrase")
            #expect(services.account.lastError == "Wrong encryption passphrase.")
            #expect(await lifecycle.purgeCalls == 0, "no purge without authorization")
            #expect(store.load() != nil, "custody untouched by a refused deletion")
            let stillSignedIn = await auth.currentUserID
            #expect(stillSignedIn != nil, "still signed in")

            // The real arm: purge → forget → sign-out. The local STORE
            // survives (her pinned rule made mechanical).
            let postID = try await services.session.runner.run { ops in
                try ops.createPost(title: "survives deletion").id
            }
            await services.deleteAccount(passphrase: "orchard-lantern-13")
            #expect(services.account.lastError == nil)
            #expect(await lifecycle.purgeCalls == 1)
            #expect(store.load() == nil, "device custody cleared through the forget machinery")
            let signedOut = await auth.currentUserID
            #expect(signedOut == nil, "signed out")
            #expect(try db.doorString(
                "SELECT id FROM container WHERE id = ?", [postID]) == postID,
                "the local copy SURVIVES — only the account and its synced copy died")
        }
    }
}

extension AppDatabase {
    fileprivate func doorString(
        _ sql: String, _ arguments: [(any DatabaseValueConvertible)?] = []
    ) throws -> String? {
        try read { db in
            try String.fetchOne(db, sql: sql, arguments: StatementArguments(arguments))
        }
    }

    fileprivate func doorInt(_ sql: String) throws -> Int? {
        try read { db in try Int.fetchOne(db, sql: sql) }
    }
}

/// Her ruling, made durable: "let's not call anything Passkey to not
/// confuse users" — the word (any case) appears in NO shipped app source.
/// The walk is DEEP (the R1-3 precedent) over all three shipped source
/// roots; test sources are exempt (this file is the pin).
@Suite("Terminology (Phase 14b — her ruling)")
struct TerminologyPinTests {
    /// Composed so the pin's own source never trips a future widening of
    /// the walk.
    private var forbidden: String { "pass" + "key" }

    @Test func nothingShippedIsEverCalledPasskey() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        var walked = 0
        var offenders: [String] = []
        for root in ["Shared", "Variorum", "VariorumMobile"] {
            let dir = appRoot.appendingPathComponent(root, isDirectory: true)
            guard let walk = FileManager.default.enumerator(
                at: dir, includingPropertiesForKeys: nil)
            else { continue }
            for case let url as URL in walk where url.pathExtension == "swift" {
                walked += 1
                let text = try String(contentsOf: url, encoding: .utf8)
                if text.lowercased().contains(forbidden) {
                    offenders.append(url.lastPathComponent)
                }
            }
        }
        #expect(walked > 100, "the walk must actually reach the shipped sources")
        #expect(offenders.isEmpty,
                "her ruling: nothing is ever called Passkey — found in \(offenders)")
    }
}

@MainActor
@Suite("The locked sync face (Phase 14b, L9)")
struct SyncLockedFaceTests {
    private actor CountingTransport: SyncTransport {
        private(set) var calls = 0
        func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome] {
            calls += 1
            return batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String) async throws -> [SyncPulledRow] {
            calls += 1
            return []
        }
        func schemaVersion() async throws -> Int {
            calls += 1
            return SyncSchema.lockstepVersion
        }
    }

    private struct LockedProvider: SyncKeyProviding {
        func currentKeys() throws -> SyncEncryptionKeys {
            throw SyncKeyProviderError.notEnrolled
        }
    }

    /// The classifier is EXACT: true for the engine's keys-refusal as the
    /// scheduler surfaces it, false for everything else (a substring match
    /// would swallow unrelated errors into the calm locked face).
    @Test func theClassifierMatchesExactlyTheEngineRefusal() {
        #expect(EncryptionSession.isKeysLockedError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!EncryptionSession.isKeysLockedError("Sync error: something else"))
        #expect(!EncryptionSession.isKeysLockedError(
            String(describing: SyncError.schemaLockstepMismatch(client: 5, server: 4))))
    }

    /// THE WIRING PIN (fails without L9's keyProvider plumb-through): a
    /// locked provider composed at the SESSION seam refuses the round with
    /// the classified status and ZERO transport contact — outbox posture
    /// intact, the row's locked face reachable.
    @Test func aLockedProviderRefusesVisiblyBeforeAnyTransportContact() async throws {
        let db = try AppDatabase.inMemory()
        // GM-2 fix: the round runs through SyncScheduler/SyncEngine, which
        // read `@Dependency(\.database/.date/.uuid)` — the wiring suites'
        // standard bootstrap (the Phase 8/9b pattern) provides them; the
        // bare test context reports unimplemented-dependency issues instead
        // of running the round. Assertions unchanged.
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = SyncSession(database: db, allowsSync: true)
            let transport = CountingTransport()
            await session.configure(transport: transport, keyProvider: LockedProvider())
            session.triggerSync()
            // Settle until the round reports.
            for _ in 0..<400 {
                if session.status.roundsCompleted > 0 { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(session.status.roundsCompleted > 0)
            #expect(session.status.lastError.map(EncryptionSession.isKeysLockedError) == true,
                    "the keys-refusal surfaces classified — the locked face's trigger")
            #expect(await transport.calls == 0,
                    "keys are checked FIRST: a locked device refuses with zero network contact")
            session.stop()
        }
    }
}
