//
//  KeyDoorTests.swift
//  VariorumTests
//
//  pre-13x batch 3b — the two RE-WRAP doors (copy §4's change passphrase and
//  regenerate twelve words; the postures design decisions 9 · 10 · 25; §5's
//  rows; §3.6; §13 — the 13p reset door MERGED into change passphrase's
//  forgot road) over the shared `KeyDoorModel`, the real `EncryptionSession`,
//  a real `ProtectionController` on a scripted gate, the production
//  `wireOneSecretHooks` composition and the raw-JSON scripted vault. No
//  network, no Keychain, no prompts.
//

import CryptoKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// The raw-JSON `key_vault` responder the flow suites keep, with an OFFLINE
/// switch (the transport's own `URLError` — decision 9's refusal).
private final class ScriptedVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?
    private var _offline = false
    var offline: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _offline }
        set { lock.lock(); defer { lock.unlock() }; _offline = newValue }
    }
    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            if self.offline { throw URLError(.notConnectedToInternet) }
            return self.respond(to: request)
        }
    }
    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock(); defer { lock.unlock() }
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        if let served = VaultRPCEmulation.serveUpdate(request, row: &row) { return response(served.status, served.body) }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else { return response(404) }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) { return response(refusal.status, refusal.body) }
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
@Suite("pre-13x 3b — the two re-wrap doors (copy §4) over the shared KeyDoorModel")
struct KeyDoorTests {
    private static let passphrase = "orchard-lantern-13"

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// One composed world: the library's key file + custody on a scripted
    /// gate; the account's vault on the raw-JSON responder; the real session,
    /// wired by production's own `wireOneSecretHooks`; the door's model over
    /// the tie's read-only checks and a recording Replace All Keys door.
    @MainActor
    private final class World {
        let vault: ScriptedVault
        let client: KeyVaultClient
        let store: DeviceKeyStore
        let encryption: EncryptionSession
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let envelopeBox: ScriptedEnvelopeBox
        let key: StoreKey
        let apple: AppleKey
        var words: [String] = []
        let replaceKeysOpened = LockIsolated<[(String?, [String]?)]>([])

        init(standard: Bool, alwaysAsk: Bool = false, biometry: Bool = true, biometricSucceeds: Bool = true, fastKDF: PassphraseKDF.Descriptor) throws {
            vault = ScriptedVault()
            client = KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.3b-doors.invalid")!,
                    apiKey: "publishable-test-key", deviceName: "test device"),
                sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token", userID: "user-doors")),
                load: vault.load)
            store = DeviceKeyStore.inMemory()
            encryption = EncryptionSession(store: store, client: client, signedIn: { true })
            key = StoreKey.mint()
            apple = AppleKey.mint()
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: KeyDoorTests.passphrase, kdf: fastKDF)
            if standard {
                try envelope.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            }
            envelopeBox = ScriptedEnvelopeBox(envelope)
            backing = InMemoryStoreKeyGuardBacking(
                auto: standard ? key : nil, gated: standard ? nil : key,
                biometryAvailable: biometry, biometricSucceeds: biometricSucceeds)
            let gate = StoreLaunchGate.scripted(
                dials: ScriptedDialsBox(ProtectionDials(alwaysAsk: alwaysAsk)), backing: backing,
                envelope: envelopeBox, stamps: ScriptedStampsBox(),
                appleKey: InMemoryAppleKeyBacking(key: apple))
            controller = ProtectionController(configuration: .init(
                scope: "Variorum3b", storeURL: nil, gate: gate,
                isRealVariant: true, makeKDF: { fastKDF }))
            controller.adoptResident(standard ? nil : key)
            controller.refreshEnvelopeFacts()
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://auth.3b-doors.invalid")!, apiKey: "k"),
                store: .inMemory(initial: AuthTokens(
                    accessToken: "token", refreshToken: "refresh", expiresAt: Date(timeIntervalSinceNow: 86_400),
                    userID: "user-doors", email: "doors@test.invalid")),
                http: { _ in throw URLError(.notConnectedToInternet) })
            wireOneSecretHooks(protection: controller, encryption: encryption, keyVault: client, auth: auth)
            encryption.replaceKeysDoor = { [replaceKeysOpened] passphrase, words in
                replaceKeysOpened.withValue { $0.append((passphrase, words)) }
            }
        }

        /// The account's vault as another device left it (P + W + Standard's
        /// Apple copy), then THIS device enrolled by the passphrase — custody
        /// + the key file's master-wrapped copy of the library key + the
        /// vault's descriptor recorded, through the production landing.
        func establishAndEnroll(standard: Bool, fastKDF: PassphraseKDF.Descriptor) async throws {
            words = try RecoveryPhrase.generate()
            _ = try await VaultEnrollment(client: client).setUp(
                passphrase: KeyDoorTests.passphrase, recoveryWords: words,
                appleHeldCopy: standard ? (apple.symmetricKey, apple.id) : nil, kdf: fastKDF)
            await encryption.enroll(passphrase: KeyDoorTests.passphrase)
            #expect(encryption.lastError == nil)
            #expect(encryption.state == .enrolled(hasRecoveryWrap: true))
            #expect(envelopeBox.value?.master != nil && envelopeBox.value?.vaultKDF != nil,
                    "the enroll landed the master-wrapped copy of the library key + the reconciliation")
        }

        func door(_ kind: KeyDoorModel.Kind) -> KeyDoorModel {
            let tie = VaultTie(
                hasRecoveryWrap: true,
                verifyPassphrase: { [client] typed in
                    do { _ = try await VaultEnrollment(client: client).enroll(passphrase: typed); return .match }
                    catch VaultEnrollmentError.wrongPassphrase { return .mismatch("not the account's") }
                    catch { return .couldNotCheck("\(error)") }
                },
                verifyRecoveryWords: { [client] text in
                    do { _ = try await VaultEnrollment(client: client).enroll(recoveryWords: EncryptionSession.words(from: text)); return .match }
                    catch VaultEnrollmentError.wrongRecoveryPhrase { return .mismatch("not the account's words") }
                    catch { return .couldNotCheck("\(error)") }
                })
            guard let facts = encryption.keyDoorFacts else { fatalError("the facts are wired by wireOneSecretHooks") }
            return KeyDoorModel(
                kind: kind, encryption: encryption, facts: facts,
                verifyVaultPassphrase: tie.verifyPassphrase, verifyVaultWords: tie.verifyRecoveryWords,
                openReplaceKeys: encryption.replaceKeysDoor)
        }

        func vaultFormat() async throws -> KeyVaultFormat {
            try #require(try await client.fetchVault()).format
        }
        func envelope() throws -> StoreKeyEnvelope { try #require(envelopeBox.value) }
    }

    // MARK: - Change passphrase

    /// Copy §4 whole: the OFFLINE sentence first (a vault fetch before any
    /// field — decision 9); a wrong current passphrase refused AGAINST THE
    /// VAULT; a word changed ELSEWHERE worded RETIRED (copy §5 — the key
    /// file's recorded descriptor is no longer the vault's); the change
    /// lands the vault's new wrap AND the key file's copy under the SAME
    /// descriptor (§3.6 — derive once); the checkbox hands the NEW
    /// passphrase to Replace All Keys. RED ON OLD: no offline check before
    /// the fields; the plain wording for a retired word; the key file's
    /// copy under a FRESH descriptor of its own (the 13p road).
    @Test func changePassphraseRefusesOfflineFirstWordsARetiredWordAndLandsTheKeyFileUnderTheVaultsDescriptor() async throws {
        let kdf = fastKDF()
        let w = try World(standard: true, fastKDF: kdf)
        try await w.establishAndEnroll(standard: true, fastKDF: kdf)
        let before = try w.envelope()
        let materialBefore = w.store.load()

        // OFFLINE: the sentence, before any field.
        w.vault.offline = true
        let offline = w.door(.changePassphrase)
        await offline.start()
        #expect(offline.phase == .failed(ProtectionCopy.changePassphraseOffline))
        w.vault.offline = false

        // A wrong current passphrase — the recorded descriptor IS the vault's ⇒ the plain line.
        let door = w.door(.changePassphrase)
        await door.start()
        #expect(door.phase == .authorize && door.isEnrolledDoor && door.offersReplaceKeys)
        await door.changePassphrase(current: "not-it", new: "a-new-passphrase-12", confirmation: "a-new-passphrase-12")
        #expect(door.lastError == "Wrong encryption passphrase.")
        let fileAfterWrong = try w.envelope()
        #expect(door.phase == .authorize && fileAfterWrong == before, "nothing written")
        await door.changePassphrase(current: Self.passphrase, new: "short", confirmation: "short")
        #expect(door.lastError == ProtectionCopy.passphraseTooShort)
        await door.changePassphrase(current: Self.passphrase, new: "a-new-passphrase-12", confirmation: "a-new-passphrase-13")
        #expect(door.lastError == ProtectionCopy.passphraseMismatch)

        // The word was changed ELSEWHERE (another device): the old one is RETIRED here.
        _ = try await VaultEnrollment(client: w.client).changePassphrase(
            authorizedBy: .passphrase(Self.passphrase), newPassphrase: "elsewhere-passphrase-1")
        let stale = w.door(.changePassphrase)
        await stale.start()
        await stale.changePassphrase(current: Self.passphrase, new: "a-new-passphrase-12", confirmation: "a-new-passphrase-12")
        #expect(stale.lastError == ProtectionCopy.retiredPassphraseAtDoor,
                "copy §5: a passphrase you've since changed — the recorded descriptor is stale")

        // The CURRENT word: the change lands on the vault AND the key file, under ONE descriptor.
        stale.alsoReplaceKeys = true
        await stale.changePassphrase(current: "elsewhere-passphrase-1", new: "a-new-passphrase-12", confirmation: "a-new-passphrase-12")
        #expect(stale.lastError == nil)
        #expect(stale.phase == .closed, "the checkbox hands the new passphrase to Replace All Keys and closes")
        #expect(w.replaceKeysOpened.value.count == 1 && w.replaceKeysOpened.value.first?.0 == "a-new-passphrase-12"
                && w.replaceKeysOpened.value.first?.1 == nil)
        let vault = try await w.vaultFormat()
        _ = try vault.unwrapMaster(withPassphraseKey: try PassphraseKDF.deriveKey(passphrase: "a-new-passphrase-12", descriptor: vault.kdf))
        let after = try w.envelope()
        #expect(try after.unwrapKey(passphrase: "a-new-passphrase-12") == w.key, "the key file's copy followed")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try after.unwrapKey(passphrase: "elsewhere-passphrase-1") }
        #expect(after.passphrase?.kdf == vault.kdf && after.vaultKDF == vault.kdf,
                "ONE descriptor for both copies — the lobby derives once (§3.6)")
        #expect(after.master != nil && after.vaultCorpusKeyID == vault.classKey(for: .corpus)?.keyID)
        #expect(w.store.load() == materialBefore, "a re-wrap rotates nothing — custody holds the same keys")
    }

    /// THE FORGOT ROADS (the 13p reset door, merged): Standard — the plain
    /// confirm (this device holds the keys); Castle + Touch ID — the presence
    /// confirm, a refused confirm changing NOTHING; Castle + Always ask — no
    /// link, the twelve words authorize; the vault half that cannot run
    /// (custody gone) refuses WHOLE and the key file keeps its old wrap.
    /// RED ON OLD: no presence confirm on the biometric road; the vault
    /// half's failure not refusing the key file's re-wrap.
    @Test func theForgotRoadsAuthorizeByTheDeviceAndRefuseWhole() async throws {
        let kdf = fastKDF()
        // Standard: the plain confirm.
        let standard = try World(standard: true, fastKDF: kdf)
        try await standard.establishAndEnroll(standard: true, fastKDF: kdf)
        let s = standard.door(.changePassphrase)
        await s.start()
        #expect(s.offersForgotLink && s.forgotRoad == .forgotStandard)
        s.forgot()
        #expect(s.phase == .forgotStandard)
        await s.resetPassphrase(new: "reset-on-standard-1", confirmation: "reset-on-standard-1")
        #expect(s.lastError == nil && s.phase == .done, "\(s.lastError ?? "")")
        let sv = try await standard.vaultFormat()
        _ = try sv.unwrapMaster(withPassphraseKey: try PassphraseKDF.deriveKey(passphrase: "reset-on-standard-1", descriptor: sv.kdf))
        #expect(try standard.envelope().unwrapKey(passphrase: "reset-on-standard-1") == standard.key)
        #expect(try standard.envelope().passphrase?.kdf == sv.kdf)

        // Castle + Touch ID: the presence confirm — refused ⇒ nothing; passed ⇒ lands.
        let castle = try World(standard: false, biometricSucceeds: false, fastKDF: kdf)
        try await castle.establishAndEnroll(standard: false, fastKDF: kdf)
        #expect(castle.controller.effectiveGate == .biometric)
        let c = castle.door(.changePassphrase)
        await c.start()
        #expect(c.offersForgotLink && c.forgotRoad == .forgotBiometric)
        c.forgot()
        let vaultBefore = try await castle.vaultFormat()
        let fileBefore = try castle.envelope()
        await c.resetPassphraseWithBiometrics(new: "reset-on-castle-11", confirmation: "reset-on-castle-11")
        #expect(c.lastError == "Not confirmed — nothing was changed.")
        let vaultAfterRefusal = try await castle.vaultFormat()
        let fileAfterRefusal = try castle.envelope()
        #expect(vaultAfterRefusal == vaultBefore && fileAfterRefusal == fileBefore, "a refused confirm changes nothing")
        castle.backing.biometricSucceeds = true
        await c.resetPassphraseWithBiometrics(new: "reset-on-castle-11", confirmation: "reset-on-castle-11")
        #expect(c.lastError == nil && c.phase == .done, "\(c.lastError ?? "")")
        let cv = try await castle.vaultFormat()
        _ = try cv.unwrapMaster(withPassphraseKey: try PassphraseKDF.deriveKey(passphrase: "reset-on-castle-11", descriptor: cv.kdf))
        #expect(try castle.envelope().unwrapKey(passphrase: "reset-on-castle-11") == castle.key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try castle.envelope().unwrapKey(passphrase: Self.passphrase) }

        // Castle + Always ask: no link — the words authorize.
        let always = try World(standard: false, alwaysAsk: true, fastKDF: kdf)
        try await always.establishAndEnroll(standard: false, fastKDF: kdf)
        let a = always.door(.changePassphrase)
        await a.start()
        #expect(!a.offersForgotLink && a.forgotRoad == .forgotWords)
        a.forgot()
        #expect(a.phase == .forgotWords)
        await a.resetPassphraseWithWords(always.words.reversed().joined(separator: " "),
                                         new: "reset-by-words-111", confirmation: "reset-by-words-111")
        #expect(a.lastError != nil && a.phase == .forgotWords, "wrong words refused")
        await a.resetPassphraseWithWords(always.words.joined(separator: " "),
                                         new: "reset-by-words-111", confirmation: "reset-by-words-111")
        #expect(a.lastError == nil && a.phase == .done, "\(a.lastError ?? "")")
        #expect(try always.envelope().unwrapKey(passphrase: "reset-by-words-111") == always.key)

        // The vault half that cannot run: custody gone ⇒ refuses WHOLE.
        let locked = try World(standard: true, fastKDF: kdf)
        try await locked.establishAndEnroll(standard: true, fastKDF: kdf)
        locked.store.clear()
        let l = locked.door(.changePassphrase)
        await l.start()
        l.forgot()
        await l.resetPassphrase(new: "never-lands-here-1", confirmation: "never-lands-here-1")
        #expect(l.lastError?.contains("keys are locked") == true, "\(l.lastError ?? "nil")")
        #expect(try locked.envelope().unwrapKey(passphrase: Self.passphrase) == locked.key,
                "the key file's old wrap STANDS when the vault half cannot run")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try locked.envelope().unwrapKey(passphrase: "never-lands-here-1") }
    }

    // MARK: - Regenerate twelve words

    /// Copy §4: the SAME authorization as change passphrase (the current
    /// word checked against the vault, read-only); the fresh words shown
    /// ONCE and confirmed by exact re-entry; the vault's recovery wrap
    /// REPLACED (the old words dead at once) and the store's copy
    /// following; the checkbox hands the NEW words to Replace All Keys.
    @Test func regenerateAuthorizesLikeChangeShowsTheWordsOnceAndReplacesTheWrap() async throws {
        let kdf = fastKDF()
        let w = try World(standard: true, fastKDF: kdf)
        try await w.establishAndEnroll(standard: true, fastKDF: kdf)
        let oldWords = w.words
        let door = w.door(.regenerateWords)
        await door.start()
        #expect(door.phase == .authorize)
        await door.authorizeRegenerate(current: "not-it")
        #expect(door.lastError == "Wrong encryption passphrase." && door.phase == .authorize)
        await door.authorizeRegenerate(current: Self.passphrase)
        guard case .wordsShow(let fresh) = door.phase else {
            Issue.record("the fresh words are shown once: \(door.phase)")
            return
        }
        #expect(fresh.count == 12 && fresh != oldWords)
        door.acknowledgeWordsWritten()
        #expect(door.phase == .wordsConfirm(fresh))
        door.confirmWords(fresh.reversed().joined(separator: " "))
        #expect(door.lastError == ProtectionCopy.wordsMismatch && door.phase == .wordsConfirm(fresh))
        door.alsoReplaceKeys = true
        door.confirmWords(fresh.joined(separator: " "))
        for _ in 0..<50 where door.phase != .closed { try await Task.sleep(for: .milliseconds(50)) }
        #expect(door.phase == .closed, "the checkbox hands the NEW words to Replace All Keys: \(door.phase)")
        #expect(w.replaceKeysOpened.value.first?.1 == fresh && w.replaceKeysOpened.value.first?.0 == nil)
        let vault = try await w.vaultFormat()
        _ = try vault.unwrapMaster(withRecoveryKey: RecoveryPhrase.recoveryWrapKey(words: fresh))
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withRecoveryKey: RecoveryPhrase.recoveryWrapKey(words: oldWords))
        }
        #expect(try w.envelope().unwrapKey(recoveryWords: fresh) == w.key, "the store's copy followed the same words")
    }

    // MARK: - A local-only library

    /// A library with no vault changes its passphrase OFFLINE against its
    /// own key file (decision 9's exception): no vault fetch, no checkbox.
    @Test func aLocalOnlyLibraryChangesItsPassphraseOfflineAgainstTheKeyFile() async throws {
        let kdf = fastKDF()
        let w = try World(standard: true, fastKDF: kdf)
        w.vault.offline = true
        let door = w.door(.changePassphrase)
        await door.start()
        #expect(door.phase == .authorize && !door.isEnrolledDoor && !door.offersReplaceKeys,
                "no vault ⇒ no offline check, no Replace All Keys checkbox")
        await door.changePassphrase(current: "not-it", new: "local-only-change-1", confirmation: "local-only-change-1")
        #expect(door.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
        await door.changePassphrase(current: Self.passphrase, new: "local-only-change-1", confirmation: "local-only-change-1")
        #expect(door.lastError == nil && door.phase == .done)
        #expect(try w.envelope().unwrapKey(passphrase: "local-only-change-1") == w.key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try w.envelope().unwrapKey(passphrase: Self.passphrase) }
        // The forgot road on a local-only Standard library: the plain confirm.
        let forgot = w.door(.changePassphrase)
        await forgot.start()
        forgot.forgot()
        #expect(forgot.phase == .forgotStandard)
        await forgot.resetPassphrase(new: "local-only-reset-11", confirmation: "local-only-reset-11")
        #expect(forgot.phase == .done)
        #expect(try w.envelope().unwrapKey(passphrase: "local-only-reset-11") == w.key)
    }
}
