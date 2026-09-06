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
        // pre-13x: the ONE vault write road is the RPC; PATCH is refused;
        // a create carries its proof hash (VaultRPCEmulation — the
        // core suites' linked ScriptedVaultServer's minimal twin).
        if let served = VaultRPCEmulation.serveUpdate(request, row: &row) {
            return response(served.status, served.body)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
            row = request.httpBody
            return response(201)
        case "PATCH":
            return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
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
            apiKey: "publishable-test-key", deviceName: "test device"),
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
        #expect(session.state == .enrolled(hasRecoveryWrap: true),
                "pre-13x 3a: a vault is born with its recovery wrap (decision 5) — the 14b phrase-comes-next shape retired")
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
        #expect(session.state == .enrolled(hasRecoveryWrap: true))

        // A fresh device against the same vault: not enrolled.
        let other = makeEncryptionSession(store: .inMemory(), vault: vault)
        await other.refresh()
        #expect(other.state == .notEnrolled(hasRecoveryWrap: true))
    }

    @Test func signedOutStateBlocksNothingButNamesTheOrder() async throws {
        let vault = ScriptedVault()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "k", deviceName: "test device"),
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
        #expect(session.state == .notEnrolled(hasRecoveryWrap: true),
                "the vault survives — this device just isn't enrolled anymore")
        #expect(healed == 1,
                "the hook fires so the next round surfaces the locked line NOW, not at the next cadence")
    }

    /// pre-13x 1a (§3.3) — CASTLE'S GATED SHAPE: under the library key's
    /// biometric mode the sync record lives in the gated item, so a fresh
    /// launch reads NO keys — the engine's seam refuses visibly — until the
    /// lobby's ONE gated read fills the session; a relock drops it again.
    /// Custody follows the library key's posture, never a toggle (the CF-12
    /// gate this pin replaces). RED ON OLD: the gate was a separate opt-in
    /// (`setBiometricRequirement`) — there was no shape to follow.
    @Test func underTheBiometricShapeAFreshLaunchReadsNoKeysUntilTheLobbysOneGatedRead() async throws {
        let backing = InMemoryKeyBacking(shape: .biometric)
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        #expect(session.lastError == nil)
        #expect(store.load() != nil,
                "the device that just proved the passphrase is unlocked for the rest of the launch")

        backing.simulateRelaunch()  // a fresh launch, or a relock
        #expect(store.load() == nil, "a locked library reads as no keys")
        let provider = DeviceKeySyncProvider(store: store)
        #expect(throws: SyncKeyProviderError.notEnrolled) {
            try provider.currentKeys()
        }
        await session.refresh()
        #expect(session.state == .notEnrolled(hasRecoveryWrap: true),
                "before the unlock the surface offers the roads, never a false enrolled")

        backing.simulateUnlock()  // the lobby's one Touch ID read
        #expect(store.load() != nil, "unlocked for the rest of the launch")
        #expect(throws: Never.self) { try provider.currentKeys() }
        await session.refresh()
        #expect(session.state == .enrolled(hasRecoveryWrap: true))
        #expect(try provider.deviceIdentity() == backing.deviceID,
                "the identity rides the same custody")
    }

    /// pre-13x 1a (decision 10) — ALWAYS ASK: no key item exists; the keys
    /// live in the session for the unlocked session and a relock drops
    /// them; the library keeps its IDENTITY across opens (the identity-only
    /// item).
    @Test func underAlwaysAskTheKeysLiveInTheSessionAndTheIdentitySurvivesARelock() async throws {
        let backing = InMemoryKeyBacking(shape: .sessionOnly)
        let store = DeviceKeyStore.inMemory(backing: backing)
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: passphrase)
        #expect(store.load() != nil, "held for the session")
        let identity = try DeviceKeySyncProvider(store: store).deviceIdentity()

        backing.simulateRelaunch()  // the relock
        #expect(store.load() == nil, "a relock drops the session's keys")
        #expect(throws: SyncKeyProviderError.notEnrolled) {
            try DeviceKeySyncProvider(store: store).currentKeys()
        }
        #expect(try DeviceKeySyncProvider(store: store).deviceIdentity() == identity,
                "an Always-ask library keeps its identity across opens")
    }

    /// The session memory itself (decision 10): an offline Always-ask
    /// unlock keeps the DERIVED wrapping key — never the typed word — and
    /// a relock drops it with the record.
    @Test func theSessionMemoryHoldsTheDerivedKeyNeverTheWordAndDropsAtRelock() {
        let memory = SyncCustodySession()
        let derived = SymmetricKey(size: .bits256)
        memory.holdDerivedWrappingKey(derived)
        memory.hold(SyncCustodyRecord(deviceID: "dev-1", material: nil))
        #expect(memory.derivedWrappingKey == derived)
        #expect(memory.record?.deviceID == "dev-1")
        memory.drop()
        #expect(memory.derivedWrappingKey == nil, "a relock drops the derived key")
        #expect(memory.record == nil, "…and the record")
    }

    /// CF-2's pin: REGENERATING the phrase is authorized by the passphrase
    /// — a wrong passphrase refuses (verified against the vault by a real
    /// unwrap, never a local compare) and mints nothing; the right one
    /// mints 12 words whose confirm still lands through the replace road.
    // pre-13x 3b: `generatePhraseAuthorized` RETIRED — regenerating the
    // twelve words is `KeyDoorModel`'s (copy §4: the same authorization as
    // change passphrase, the words shown once and confirmed, the wrap
    // replaced) — pinned in `KeyDoorTests.regenerateAuthorizesLikeChangeShowsTheWordsOnceAndReplacesTheWrap`.

    /// **Ladder R1-m3 — the phrase twin (one secret, the phrase's
    /// following direction).** The vault's own recovery-phrase generation
    /// had no hook landing the same words on the STORE envelope, though
    /// `onPassphraseChanged` established the pattern — so a vault-enrolled
    /// user could hold "the" twelve words that opened the account but not
    /// the library. Now `landRecoveryWrap` fires the twin with the
    /// CONFIRMED words on a land that happened (and NOT on a refused one),
    /// and — composed exactly as the app wires it — the store envelope
    /// ends up with a recovery wrap those same words unwrap.
    ///
    /// RED ON OLD (behavioral revert executed): with the hook's fire
    /// removed — the pre-fix world, where no twin exists — the follow
    /// assertion and the envelope unwrap both go red.
    @Test func landingTheVaultPhraseFollowsIntoTheStoreEnvelope() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)

        // The store side, composed as VariorumApp composes it: a real
        // ProtectionController over a scripted gate whose envelope box we
        // can read back.
        let storeKey = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(auto: storeKey)
        let envelopeBox = ScriptedEnvelopeBox(nil)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: envelopeBox)
        let controller = ProtectionController(configuration: .init(
            scope: "phrase-twin", storeURL: nil, gate: gate, isRealVariant: false,
            makeKDF: {
                PassphraseKDF.Descriptor(
                    algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                    memoryKiB: 256, iterations: 1, parallelism: 1,
                    salt: PassphraseKDF.randomSalt(), outputBytes: 32)
            }))
        // pre-13x 3a: the SETUP lands the words itself (a vault is never
        // born without its recovery wrap), and the follow into the store
        // envelope rides the production composition — `onVaultMaterialLanded`
        // → `landVaultMaterial`, whose words' copy is the twin. A second
        // phrase without `allowReplace` is refused as the deliberate step.
        let followed = LockIsolated<[String]>([])
        session.onVaultMaterialLanded = { landing in
            followed.setValue(landing.recoveryWords ?? [])
            _ = await controller.landVaultMaterial(landing)
        }

        let words = await session.setUp(passphrase: passphrase)
        #expect(session.lastError == nil)
        #expect(words.count == 12)
        #expect(followed.value == words,
                "the twin hands the SAME twelve words to the store side")
        let envelope = try #require(envelopeBox.value,
                "the store envelope landed beside the (scripted) store")
        #expect(try envelope.unwrapKey(recoveryWords: words) == storeKey,
                "the one phrase now opens the LIBRARY too — one secret, both directions")

        // A REFUSED land fires nothing: replacing without authorization
        // refuses at the vault, and the twin must not follow a refusal.
        followed.setValue([])
        let second = try #require(session.generatePhrase())
        await session.landRecoveryWrap(confirmedWords: second, allowReplace: false)
        #expect(session.lastError != nil, "the unauthorized replace refuses")
        #expect(followed.value == [], "a refused land must not fire the twin")
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
        #expect(session.state == .enrolled(hasRecoveryWrap: true),
                "the mandatory phrase step follows, exactly as for any fresh vault")
    }

    /// CF-13's pin survives the 14b setup flow's retirement (pre-13x 3a —
    /// copy §2a's ceremony replaced the stepped flow, its gates and its
    /// checkbox): the whole phrase is the secret, said where the words show.
    @Test func theWholePhraseIsTheSecretLineSurvives() {
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
        #expect(session.state == .keysReplaced(hasRecoveryWrap: true),
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
        #expect(session.state == .keysReplaced(hasRecoveryWrap: true))

        await session.enroll(passphrase: "the-new-passphrase")
        #expect(session.lastError == nil)
        let fresh = try #require(store.load())
        #expect(fresh != stale, "the enroll save overwrites the stale custody wholesale")
        #expect(fresh.corpusKeyID != stale.corpusKeyID)
        #expect(session.state == .enrolled(hasRecoveryWrap: true))
        let provider = DeviceKeySyncProvider(store: store)
        #expect(try provider.currentKeys().corpusKeyID == fresh.corpusKeyID,
                "sync serves the NEW key, never the orphaned one")
        await session.refresh()
        #expect(session.state == .enrolled(hasRecoveryWrap: true),
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

    /// pre-13x 2c (§7): the KEY PROOF's refusal (`SyncError.keyProofRefused`)
    /// is the same un-followed state as the fence's — its own classifier,
    /// disjoint from the others, presenting as the replaced-keys row whose
    /// door reaches the Encryption tab (where the follow's door stands).
    /// RED-ON-OLD: the proof refusal fell to the generic error face.
    @Test func theKeyProofRefusalPresentsAsTheReplacedRow() {
        let proof = String(describing: SyncError.keyProofRefused)
        #expect(EncryptionSession.isKeyProofRefusedError(proof))
        #expect(!EncryptionSession.isKeyProofRefusedError(String(describing: SyncError.encryptionKeysReplaced)))
        #expect(!EncryptionSession.isKeysReplacedError(proof), "two classifiers, one state — disjoint")
        #expect(!EncryptionSession.isPayloadCryptoError(proof))
        #expect(!EncryptionSession.isKeysLockedError(proof))
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: proof, lastErrorIsOffline: false)
        #expect(face.kind == .keysReplaced)
        #expect(face.doors == [SyncRowFace.Door(label: "Re-enroll…", act: .openAccount(.encryption))])
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

    /// Ladder R1-1: the engine's unfinished-re-key refusal (the persisted
    /// `RotationMarker`) presents as its OWN paused row whose one
    /// door reaches the completing surface directly — never the generic
    /// error face (red-on-old: that was the pre-fix presentation), and
    /// never the replaced-keys row, whose re-enroll prescription cannot
    /// complete a half-run re-key. The classifier stays disjoint from
    /// every sibling.
    @Test func theRekeyIncompleteRowSpeaksTheFinishRoad() {
        let text = String(describing: SyncError.accountRekeyIncomplete)
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: text, lastErrorIsOffline: false)
        #expect(face.kind == .rekeyIncomplete)
        #expect(face.doors == [SyncRowFace.Door(
            label: "Finish key replacement…", act: .openAccount(.encryption))],
                "one door, straight to the surface whose banner completes the road")
        #expect(SyncStatusRow.rekeyIncompleteLabel.contains("didn't finish"),
                "the row line names the state, not a generic error")

        // Disjointness both ways: the marker refusal never wears the
        // replaced/locked/tier faces, and their errors never wear this one.
        #expect(EncryptionSession.isRekeyIncompleteError(text))
        #expect(!EncryptionSession.isKeysReplacedError(text))
        #expect(!EncryptionSession.isKeysLockedError(text))
        #expect(!EncryptionSession.isPayloadCryptoError(text))
        #expect(!HostedSyncTier.isNotEntitledError(text))
        #expect(!EncryptionSession.isRekeyIncompleteError(
            String(describing: SyncError.encryptionKeysReplaced)))
        #expect(!EncryptionSession.isRekeyIncompleteError(
            String(describing: SyncError.encryptionKeysUnavailable)))
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
        // belongs to the locked, replaced, or (ladder R1-1)
        // rekey-incomplete state.
        let errors: [String?] = [
            nil,
            "Sync error: something else",
            String(describing: SyncError.encryptionKeysUnavailable),
            String(describing: SyncError.payloadCryptoFailure(
                table: "variant", rowID: "r", column: "working_text", detail: "d")),
            String(describing: SyncError.accountRekeyIncomplete),
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
                        #expect(face.kind == .keysLocked || face.kind == .keysReplaced
                                || face.kind == .rekeyIncomplete)
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

    /// pre-13x 3b: the 2c interim door (`rekeyRunner` / `rekeyAccount` —
    /// the passphrase alone) RETIRED for copy §4's ceremony on the controller
    /// (`PostureSwitchModel.Mode.replaceKeys`, pinned in `PostureSwitchTests`).
    /// What the session still owns: the persisted marker's surface read —
    /// refresh() projects the rerun prompt (ladder R1-1), and the door
    /// renders only when the root wired it (P-2).
    @Test func theSurfaceReSpeaksTheRerunRoadFromThePersistedMarker() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        await session.setUp(passphrase: "the-old-passphrase")

        // The relaunch shape after a mid-re-key crash: the marker reads
        // set; refresh projects it.
        let markerSet = LockIsolated(true)
        session.rekeyIncompleteCheck = { markerSet.value }
        await session.refresh()
        #expect(session.rekeyIncomplete,
                "refresh re-speaks the rerun road from the persisted marker")
        markerSet.setValue(false)
        await session.refresh()
        #expect(!session.rekeyIncomplete, "a completed run reads the marker clear")

        // The banner prompt: paused + the rerun act + nothing lost.
        #expect(EncryptionView.rekeyIncompletePrompt.contains("didn't finish"))
        #expect(EncryptionView.rekeyIncompletePrompt.contains("Replace Encryption Keys"))
        #expect(EncryptionView.rekeyIncompletePrompt.contains("nothing is lost"))
        // Ladder R2-1: the signed-out variant prescribes sign-in FIRST —
        // never a bare rerun the sessionless door would only refuse.
        #expect(EncryptionView.rekeyIncompleteSignedOutPrompt.contains("Sign in first"))
        #expect(EncryptionView.rekeyIncompleteSignedOutPrompt.contains("didn't finish"))
        #expect(!EncryptionView.rekeyIncompleteSignedOutPrompt.contains("Run Replace Encryption Keys again"))
        // pre-13x 3b (P-2): no root-wired door ⇒ the tab renders none.
        #expect(session.replaceKeysDoor == nil, "the Replace All Keys door is the root's to wire")
    }

    /// THE COPY PINS. Her Round-5 pinned rule (the CF-6 class): the
    /// deletion door's copy MUST say the local copy survives — what dies
    /// is the synced copy and the account. And the re-key copy names what
    /// a re-key does to OTHER devices (the CF-16 replaced state +
    /// re-enroll) and to the recovery phrase.
    @Test func theDoorCopySaysTheLocalCopySurvivesAndNamesTheConsequences() {
        // The deletion door — her pinned rule, byte-anchored (pre-13x 3b:
        // copy §4's body — the local copy survives, in its words).
        #expect(AccountView.deleteAccountExplanation.contains(
            "every library stays, and still opens exactly as it does today"),
            "HER PINNED RULE: the deletion copy says the local copy survives")
        #expect(AccountView.deleteAccountExplanation.contains(
            "Nothing on this \(ProtectionCopy.deviceName) or your other devices is touched"))
        #expect(AccountView.deleteAccountExplanation.contains(
            "its sync copy on our server, and its keys are deleted"),
            "the consequence is named honestly beside the survival")
        #expect(AccountView.deleteSubscriptionAdvisory.contains("cancel it first"),
                "subscription state warned first — the ruling's letter")
        #expect(AccountView.deleteConfirmationPhrase == "DELETE MY ACCOUNT")
        #expect(AccountView.phraseMatches("delete my account ") && !AccountView.phraseMatches("delete account"))
        #expect(ProtectionCopy.deleteAccountReauthLine == "Enter your account password to continue.")

        // pre-13x 3b: Replace All Keys' words are copy §4's (rendered
        // verbatim by `KeyDoorCopy`) — the honest body names what a copy or
        // a backup holds (no keys), what the other devices do (ask once),
        // and old backups' roads; the Standard addendum says decision 30's
        // limit; the authorization line names decision 33.
        #expect(ProtectionCopy.replaceKeysBody.contains("A copy of your library or a backup holds no keys"))
        #expect(ProtectionCopy.replaceKeysBody.contains("Your other devices will each ask for your passphrase once"))
        #expect(ProtectionCopy.replaceKeysBody.contains("an enrolled device's master key no longer opens them"))
        #expect(ProtectionCopy.replaceKeysStandardAddendum.contains("doesn't shut out someone inside your Apple account"))
        #expect(ProtectionCopy.replaceKeysAuthorization.contains("\(ProtectionCopy.biometryName) can't do that"))
        #expect(ProtectionCopy.replaceKeysDone == "Done. Your other devices will ask for your passphrase the next time they open.")
    }
}

// MARK: - The doors' AppServices wiring (Phase 14c, batch 2)

@MainActor
@Suite("Account door wiring (Phase 14c, batch 2)", .serialized)
struct AccountDoorWiringTests {
    private actor RecordingLifecycle: AccountLifecycleProviding {
        private(set) var truncateKeyIDs: [String] = []
        private(set) var purgeCalls = 0
        func truncateAccountData(activeKeyID: String, keyProof: String) async throws -> [String: Int] {
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
        func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
            batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] { [] }
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
        // pre-13x 3b: the auth answers the deletion door's re-authentication
        // (the password grant — the right account password gets a fresh
        // pair, a wrong one the credentials refusal) and the revocations;
        // everything else stays "no network".
        let routed: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            func response(_ status: Int, _ body: String = "") -> (Data, URLResponse) {
                (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!)
            }
            let url = request.url!.absoluteString
            if url.contains("grant_type=password") {
                let body = request.httpBody.flatMap { try? JSONDecoder().decode([String: String].self, from: $0) }
                if body?["password"] == "right-account-password" {
                    return response(200, """
                        {"access_token": "fresh-access", "refresh_token": "fresh-refresh", "expires_in": 3600,
                         "user": {"id": "user-door", "email": "door@example.com"}}
                        """)
                }
                return response(400, #"{"error":"invalid_grant","error_description":"Invalid login credentials"}"#)
            }
            if url.contains("/auth/v1/logout") { return response(204) }
            throw AuthSessionError.malformedResponse("no network")
        }
        let auth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://variorum-project.test.invalid")!,
                apiKey: "publishable"),
            store: authStore,
            http: routed)
        await auth.adopt(AuthTokens(
            accessToken: "access", refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userID: "user-door", email: "door@example.com"))
        let vault = ScriptedVault()
        let keyVault = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: auth,
            load: vault.load)
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
                backupEnabled: false,
                auth: auth, encryption: encryption,
                makeSyncTransport: { _ in QuietTransport() },
                makeSyncKeyProvider: { AppTestKeyProvider() },
                keyVault: keyVault,
                makeAccountLifecycle: { _ in lifecycle },
                // The bridge retirement's round 2 (N1): the retired-credential
                // sweep is inert in test worlds (a real login-keychain delete).
                legacyCleanup: {})
            await services.start()
            try await body(services, encryption, store, lifecycle, db, auth)
            services.stop()
        }
    }

    /// THE REKEY WIRING through the app seam, pre-13x 2b: the 14c brain's
    /// truncate-and-re-enqueue road is RETIRED (the rotation is in place —
    /// `PostureSwitchRunner`, composed by the ROOT because it needs the
    /// bootstrap's re-key road and the protection controller). What
    /// `AppServices.start()` still wires is the persisted marker's read:
    /// the door stays honestly dormant until the root hands it the runner,
    /// the truncate is never called, and a marker in the store projects
    /// as `rekeyIncomplete` through `refresh()`.
    @Test func theRekeyDoorStaysDormantUntilTheRootWiresTheRunnerAndTheMarkerReadIsWired() async throws {
        try await withDoorWorld { services, encryption, store, lifecycle, db, _ in
            await encryption.setUp(passphrase: "orchard-lantern-13")
            #expect(encryption.lastError == nil)
            let old = try #require(store.load())
            _ = try await services.session.runner.run { ops in
                try ops.createPost(title: "pre-rekey").id
            }

            // No root-wired door (pre-13x 3b): the tab renders no Replace
            // All Keys door at all (P-2) — custody untouched, no truncate.
            #expect(encryption.replaceKeysDoor == nil, "the door is the ROOT's to wire")
            #expect(store.load() == old, "custody untouched")
            #expect(await lifecycle.truncateKeyIDs == [], "the truncate road is retired — never called")

            // The marker read IS wired: a crashed switch's marker projects.
            try await db.write { dbi in
                try RotationMarker.write(
                    RotationMarker(step: .rekeyLibrary, entersCastle: true, startedAt: "2026-09-05T00:00:00.000Z"), dbi)
            }
            await encryption.refresh()
            #expect(encryption.rekeyIncomplete, "the persisted marker re-speaks the resume road")
            try await db.write { dbi in try RotationMarker.clear(dbi) }
            await encryption.refresh()
            #expect(!encryption.rekeyIncomplete)
        }
    }

    /// Ladder R1-1, the WIRING loop closed over the real store: a marker
    /// in the app database (what a mid-re-key crash leaves) reaches the
    /// surface through the check `AppServices.start()` wired — refresh()
    /// projects the rerun prompt — and account deletion clears it (a
    /// purged account owes no completion). Red-on-old by behavioral
    /// revert: without the AppServices wiring the check stays nil and the
    /// projection assertion fails.
    @Test func thePersistedMarkerReachesTheSurfaceAndDeletionClearsIt() async throws {
        try await withDoorWorld { services, encryption, store, lifecycle, db, _ in
            await encryption.setUp(passphrase: "orchard-lantern-13")
            #expect(encryption.lastError == nil)

            // The crash residue, in the REAL store this world composes over.
            try await db.write { dbi in
                try RotationMarker.write(
                    RotationMarker(step: .reencrypt, entersCastle: false, startedAt: "2026-09-05T00:00:00.000Z"), dbi)
            }
            await encryption.refresh()
            #expect(encryption.rekeyIncomplete,
                    "the wired check reads the real sync_state row — the surface re-speaks the road on relaunch")

            // Deletion clears it: the road no longer exists.
            await services.deleteAccount(accountPassword: "right-account-password")
            #expect(services.account.lastError == nil)
            let marker = try await db.read { try RotationMarker.isSet($0) }
            #expect(!marker, "a purged account owes no re-key completion")
        }
    }

    /// THE DELETION WIRING (pre-13x 3b — decision 16; copy §4): the purge
    /// runs only after the ACCOUNT PASSWORD's fresh re-authentication; a
    /// wrong password refuses with copy's line and purges NOTHING; success
    /// purges, KEEPS custody (every library stays and opens as it did — the
    /// keys sit dead server-side), and signs out; the local STORE survives.
    /// RED ON OLD: the encryption passphrase authorized (keystone 3's
    /// breach) and the road CLEARED custody (`forgetDeviceKeys`).
    @Test func theDeletionWiringVerifiesTheAccountPasswordPurgesKeepsCustodyAndSignsOut() async throws {
        try await withDoorWorld { services, encryption, store, lifecycle, db, auth in
            await encryption.setUp(passphrase: "orchard-lantern-13")
            let custody = try #require(store.load())
            let signedInBefore = await auth.currentUserID
            #expect(signedInBefore != nil)

            // The wrong ACCOUNT password: nothing server-side, nothing local.
            await services.deleteAccount(accountPassword: "not-the-account-password")
            #expect(services.account.lastError == ProtectionCopy.deleteAccountWrongPassword)
            #expect(await lifecycle.purgeCalls == 0, "no purge without the re-authentication")
            #expect(store.load() == custody, "custody untouched by a refused deletion")
            let stillSignedIn = await auth.currentUserID
            #expect(stillSignedIn != nil, "still signed in")

            // The real arm: re-auth → purge → sign-out. Custody KEPT; the
            // local STORE survives (her pinned rule made mechanical).
            let postID = try await services.session.runner.run { ops in
                try ops.createPost(title: "survives deletion").id
            }
            await services.deleteAccount(accountPassword: "right-account-password")
            #expect(services.account.lastError == nil, "\(services.account.lastError ?? "")")
            #expect(await lifecycle.purgeCalls == 1)
            #expect(store.load() == custody, "custody KEPT — the keys stay on the device, dead server-side (copy §4)")
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

/// pre-13x 5a (§13 — the sweep's pin): the names the postures design
/// DELETED appear in NO shipped source file — the app targets, `Shared/`,
/// and core — comments included (a comment that still narrates a retired
/// family as live is the stale-copy class the sweep re-worded). Test
/// sources are exempt (this file is the pin, and it names them).
@Suite("Retired names (pre-13x 5a — the §13 sweep)")
struct RetiredNamesPinTests {
    /// Composed so this file's own text never trips the walk.
    private static let retired: [String] = [
        "Protection" + "Shapes", "Protection" + "ExplainerView",
        "loss" + "Legs", "loss" + "Math",
        "SyncGate" + "OptIn", "E2EELaunch" + "KeyCache",
        "Protection" + "Preset", "openResetting" + "ModeToAuto",
        "effective" + "EscrowOn", "escrowUnder" + "DemandedMode",
        "need" + "States", "escrowLeg" + "Sentence", "lockMoment" + "Framing",
    ]

    @Test func theDeletedNamesAppearInNoShippedSource() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let repoRoot = appRoot.deletingLastPathComponent().deletingLastPathComponent()
        let roots = [
            appRoot.appendingPathComponent("Shared", isDirectory: true),
            appRoot.appendingPathComponent("Variorum", isDirectory: true),
            appRoot.appendingPathComponent("VariorumMobile", isDirectory: true),
            repoRoot.appendingPathComponent("Sources/VariorumCore", isDirectory: true),
        ]
        var walked = 0
        var offenders: [String] = []
        for root in roots {
            #expect(FileManager.default.fileExists(atPath: root.path), "sweep root missing: \(root.lastPathComponent)")
            let walk = try #require(FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil))
            for case let url as URL in walk where url.pathExtension == "swift" {
                walked += 1
                let text = try String(contentsOf: url, encoding: .utf8)
                for name in Self.retired where text.contains(name) {
                    offenders.append("\(url.lastPathComponent): \(name)")
                }
            }
        }
        #expect(walked > 150, "the walk must actually reach the shipped sources")
        #expect(offenders.isEmpty, "§13's deleted names survive in shipped source: \(offenders)")
    }
}

@MainActor
@Suite("The locked sync face (Phase 14b, L9)")
struct SyncLockedFaceTests {
    private actor CountingTransport: SyncTransport {
        private(set) var calls = 0
        func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
            calls += 1
            return batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
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
        func deviceIdentity() throws -> String {
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

// MARK: - Fresh-account vault provisioning generality (Phase 14c batch 3 — THE DESIGN 6)

/// THE GENERALITY PIN. THE DESIGN 6's claim is that per-user vault
/// provisioning at signup "= the 14b stepped setup flow running for a
/// fresh account (verify its generality; it was built account-agnostic)".
/// Verified here, not assumed: a BRAND-NEW account — an arbitrary fresh
/// uid, NO vault row, NO custody — walks the SAME mandatory-phrase setup
/// her account did (the rules gates, the create act, the CF-5 step-4
/// landing, the phrase confirm), a second device of the same fresh
/// account enrolls by passphrase into identical custody, and the
/// 12-word disaster road unlocks a third. Nothing anywhere keys on HER
/// account: the walk is parameterized over arbitrary uids.
@MainActor
@Suite("Fresh-account setup generality (Phase 14c, batch 3)")
struct FreshAccountSetupGeneralityTests {
    private func session(
        userID: String, store: DeviceKeyStore, vault: ScriptedVault
    ) -> EncryptionSession {
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "t-fresh", userID: userID)),
            load: vault.load)
        return EncryptionSession(store: store, client: client, signedIn: { true })
    }

    @Test(arguments: [
        "9b1c2d3e-4f50-4a61-8b72-000000000901",
        "not-even-uuid-shaped-stranger-id",
    ])
    func aBrandNewAccountWalksTheMandatoryPhraseSetupExactlyAsHers(userID: String) async throws {
        let vault = ScriptedVault()
        let firstStore = DeviceKeyStore.inMemory()
        let first = session(userID: userID, store: firstStore, vault: vault)

        await first.refresh()
        #expect(first.state == .noVault,
                "a fresh account with no vault row is offered SETUP — the same door as hers")

        // pre-13x 3a (copy §2a): the setup door takes the twelve words — the
        // vault is BORN with its recovery wrap, for a stranger exactly as
        // for her (decision 5's letter, account-agnostic).
        let words = try RecoveryPhrase.generate()
        await first.setUp(passphrase: "meadow-lantern-9", recoveryWords: words)
        #expect(first.lastError == nil)
        #expect(first.state == .enrolled(hasRecoveryWrap: true),
                "one row: the passphrase wrap AND the recovery wrap at birth")
        #expect(vault.hasRow, "the stranger's vault row was created")
        #expect(firstStore.load() != nil, "custody landed")
        // Words are REQUIRED: a wordless setup refuses before anything is minted.
        let wordless = session(userID: userID + "-wordless", store: .inMemory(), vault: ScriptedVault())
        await wordless.setUp(passphrase: "meadow-lantern-9", recoveryWords: [])
        #expect(wordless.lastError != nil && wordless.state != .enrolled(hasRecoveryWrap: true))

        // A second device of the SAME fresh account: ordinary enrollment.
        let secondStore = DeviceKeyStore.inMemory()
        let second = session(userID: userID, store: secondStore, vault: vault)
        await second.refresh()
        #expect(second.state == .notEnrolled(hasRecoveryWrap: true))
        await second.enroll(passphrase: "meadow-lantern-9")
        #expect(second.lastError == nil)
        #expect(secondStore.load() == firstStore.load(),
                "the stranger's vault is a REAL vault — a second device unwraps identical custody")

        // And the 12-word disaster road unlocks a third device.
        let thirdStore = DeviceKeyStore.inMemory()
        let third = session(userID: userID, store: thirdStore, vault: vault)
        await third.enroll(recoveryWordsText: words.joined(separator: " "))
        #expect(third.lastError == nil)
        #expect(thirdStore.load() == firstStore.load(),
                "the phrase road is account-agnostic too")
    }
}
