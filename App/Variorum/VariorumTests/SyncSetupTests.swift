//
//  SyncSetupTests.swift
//  VariorumTests
//
//  pre-13x batch 3a — SYNC SETUP's brain (copy §2a whole; the postures design
//  decision 5, §5's Set-up-sync row, corners 26/27, ledger 27) over a scripted
//  store tie and the raw-JSON scripted vault: the ceremony walks the copy's
//  order; ONE SECRET — a library with a passphrase makes the user TYPE it and
//  refuses the wrong one against the key file; existing words are typed and
//  verified against the key file, or regenerated (the file's copy replaced —
//  never a silent reuse); fresh words are shown once and confirmed by exact
//  re-entry; the vault is BORN with P, W and (a Standard library) the
//  Apple-held copy in one row, under the key file's descriptor (derive once);
//  a Castle library's vault carries no Apple copy; the pre-Screen-1 confirm
//  runs the adopt road right after the create; the landing carries the words.
//

import CryptoKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

private final class ScriptedVaultDouble: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?
    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
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
@Suite("pre-13x 3a — sync setup: copy §2a's ceremony over the store tie and the scripted vault")
struct SyncSetupTests {
    /// The library's key file as the ceremony sees it: a scripted store.
    @MainActor
    final class ScriptedStore {
        var posture: Posture = .standard
        var passphrase: String?
        var passphraseKDF: PassphraseKDF.Descriptor?
        var words: [String]?
        var setCalls: [String] = []
        var verifyCalls: [String] = []
        var wordChecks: [String] = []

        var tie: StoreTie {
            StoreTie(
                libraryPosture: { self.posture },
                hasPassphrase: { self.passphrase != nil },
                hasRecoveryWords: { self.words != nil },
                verifyPassphrase: { typed in
                    self.verifyCalls.append(typed)
                    guard let on = self.passphrase else { return nil }
                    return on == typed
                },
                setPassphrase: { typed in
                    self.setCalls.append(typed)
                    self.passphrase = typed
                    self.passphraseKDF = PassphraseKDF.Descriptor(
                        algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                        memoryKiB: 256, iterations: 1, parallelism: 1,
                        salt: PassphraseKDF.randomSalt(), outputBytes: 32)
                    return nil
                },
                verifyRecoveryWords: { typed in
                    self.wordChecks.append(typed)
                    guard let on = self.words else { return nil }
                    return EncryptionSession.words(from: typed).map { $0.lowercased() } == on
                },
                passphraseKDF: { self.passphraseKDF })
        }
    }

    private struct World {
        let vault: ScriptedVaultDouble
        let client: KeyVaultClient
        let store: DeviceKeyStore
        let encryption: EncryptionSession
        let scripted: ScriptedStore
        let apple: InMemoryAppleKeyBacking
        let landings: LockIsolated<[VaultLanding]>
        let adopts: LockIsolated<Int>
        let model: SyncSetupModel
    }

    private func makeWorld(
        posture: Posture = .standard, passphrase: String? = nil, words: [String]? = nil,
        foreign: Bool = false, apple: AppleKey? = AppleKey.mint(), appleWritesSucceed: Bool = true
    ) -> World {
        let vault = ScriptedVaultDouble()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.3a-setup.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token", userID: "user-setup")),
            load: vault.load)
        let store = DeviceKeyStore.inMemory()
        let encryption = EncryptionSession(store: store, client: client, signedIn: { true })
        let scripted = ScriptedStore()
        scripted.posture = posture
        scripted.passphrase = passphrase
        if passphrase != nil {
            scripted.passphraseKDF = PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32)
        }
        scripted.words = words
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        appleBacking.writesSucceed = appleWritesSucceed
        let appleLeaves = AppleKeyLeaves.inMemory(backing: appleBacking)
        encryption.storeTie = scripted.tie
        encryption.libraryPosture = { scripted.posture }
        encryption.readOrMintAppleKey = { appleLeaves.readOrMint() }
        encryption.storePassphraseGuard = { typed in
            guard let on = scripted.passphrase else { return nil }
            return on == typed
        }
        let landings = LockIsolated<[VaultLanding]>([])
        encryption.onVaultMaterialLanded = { landing in landings.withValue { $0.append(landing) } }
        let adopts = LockIsolated(0)
        let model = SyncSetupModel(
            encryption: encryption, tie: scripted.tie,
            foreignOwner: { foreign },
            adopt: { adopts.withValue { $0 += 1 } })
        return World(vault: vault, client: client, store: store, encryption: encryption, scripted: scripted,
                     apple: appleBacking, landings: landings, adopts: adopts, model: model)
    }

    private func fetched(_ w: World) async throws -> KeyVaultFormat {
        try #require(try await w.client.fetchVault()).format
    }

    /// A fresh Standard library (no passphrase, no words): Screen 1 with the
    /// Standard addendum → the passphrase SET (short and mismatched
    /// refused) → fresh words shown once → written down → a wrong re-entry
    /// refused → the exact one → the create → done(Standard). The vault is
    /// born with P + W + the Apple-held copy in ONE row under the key file's
    /// descriptor; custody landed; the landing carried the words and the
    /// passphrase. RED ON OLD: the 14b flow created a passphrase-only vault
    /// (the words landed in a later, separate step) and never an Apple copy.
    @Test func aFreshStandardLibraryWalksTheCopysOrderAndTheVaultIsBornWhole() async throws {
        let w = makeWorld()
        await w.model.start()
        #expect(w.model.phase == .explain && w.model.facts?.libraryPosture == .standard)
        w.model.continueFromExplain()
        #expect(w.model.phase == .passphrase(existing: false))

        await w.model.submitPassphrase("short", confirmation: "short")
        #expect(w.model.lastError == ProtectionCopy.passphraseTooShort && w.model.phase == .passphrase(existing: false))
        await w.model.submitPassphrase("orchard-lantern-13", confirmation: "orchard-lantern-14")
        #expect(w.model.lastError == ProtectionCopy.passphraseMismatch)
        #expect(w.scripted.setCalls.isEmpty, "nothing landed on a refusal")
        await w.model.submitPassphrase("orchard-lantern-13", confirmation: "orchard-lantern-13")
        #expect(w.scripted.setCalls == ["orchard-lantern-13"], "the passphrase set on the key file")
        guard case .wordsShow(let words) = w.model.phase else {
            Issue.record("fresh words shown once: \(w.model.phase)"); return
        }
        #expect(words.count == 12)
        w.model.acknowledgeWordsWritten()
        #expect(w.model.phase == .wordsConfirm(words))
        w.model.confirmWords(words.reversed().joined(separator: " "))
        #expect(w.model.lastError == ProtectionCopy.wordsMismatch && w.model.phase == .wordsConfirm(words))
        w.model.confirmWords("only three words")
        #expect(w.model.lastError == EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(3)))
        w.model.confirmWords(words.joined(separator: " "))
        // The create runs on the mirror's Task; wait for it.
        for _ in 0..<200 where w.model.phase != .done(.standard) { try await Task.sleep(for: .milliseconds(20)) }
        #expect(w.model.phase == .done(.standard), "\(w.model.phase)")

        let vault = try await fetched(w)
        let apple = try #require(w.apple.key)
        #expect(vault.masterWrappedByRecovery != nil && vault.appleKeyID == apple.id, "P + W + the Apple copy in ONE row")
        #expect(vault.kdf == w.scripted.passphraseKDF, "born under the key file's descriptor — derive once")
        let material = try #require(w.store.load())
        #expect(try vault.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: words)).withUnsafeBytes { Data($0) } == material.masterKey)
        #expect(try vault.unwrapMaster(withAppleKey: apple.symmetricKey).withUnsafeBytes { Data($0) } == material.masterKey)
        #expect(w.encryption.state == .enrolled(hasRecoveryWrap: true))
        let landing = try #require(w.landings.value.first)
        #expect(landing.recoveryWords == words && landing.passphrase == "orchard-lantern-13" && landing.kdf == vault.kdf)
        #expect(w.adopts.value == 0, "no foreign owner — no adopt")
    }

    /// A Castle library WITH a passphrase and words: Screen 1's Castle
    /// addendum → the passphrase TYPED (the wrong one refused against the
    /// key file — one secret) → *Type My Words…* (the wrong words refused
    /// against the key file; the right ones become the account's) → the
    /// create → done(Castle). The vault carries NO Apple copy (pin the
    /// absence) and its W wrap opens with the library's own words.
    @Test func aCastleLibraryTypesItsPassphraseAndItsWordsAndTheVaultCarriesNoAppleCopy() async throws {
        let words = try RecoveryPhrase.generate()
        let w = makeWorld(posture: .castle, passphrase: "orchard-lantern-13", words: words)
        await w.model.start()
        #expect(w.model.facts?.libraryPosture == .castle)
        w.model.continueFromExplain()
        #expect(w.model.phase == .passphrase(existing: true))
        await w.model.submitPassphrase("not-the-librarys", confirmation: nil)
        #expect(w.model.lastError == ProtectionCopy.passphraseNotTheLibrarys && w.scripted.verifyCalls == ["not-the-librarys"])
        await w.model.submitPassphrase("orchard-lantern-13", confirmation: nil)
        #expect(w.model.phase == .wordsExisting && w.scripted.setCalls.isEmpty, "typed, never re-set")
        w.model.chooseTypeWords()
        #expect(w.model.phase == .wordsType)
        await w.model.submitExistingWords(try RecoveryPhrase.generate().joined(separator: " "))
        #expect(w.model.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongRecoveryPhrase))
        #expect(w.model.phase == .wordsType)
        await w.model.submitExistingWords(words.joined(separator: " "))
        for _ in 0..<200 where w.model.phase != .done(.castle) { try await Task.sleep(for: .milliseconds(20)) }
        #expect(w.model.phase == .done(.castle), "\(w.model.phase)")
        let vault = try await fetched(w)
        #expect(vault.masterWrappedByAppleHeld == nil && vault.appleKeyID == nil, "a Castle library gives the vault its shape: NO Apple copy")
        #expect(w.apple.key != nil, "…and A is never touched (it exists for other libraries)")
        let material = try #require(w.store.load())
        #expect(try vault.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: words)).withUnsafeBytes { Data($0) } == material.masterKey,
                "the library's own words are the account's")
        #expect(w.landings.value.first?.recoveryWords == words)
    }

    /// *Generate New Ones* over an existing set: fresh words shown once and
    /// confirmed; the landing carries the NEW words (the key file's copy is
    /// replaced at the land — decision 5: never a silent reuse); the vault's
    /// W wrap is under the new words, not the old.
    @Test func generateNewOnesReplacesTheLibrarysWordsEverywhere() async throws {
        let old = try RecoveryPhrase.generate()
        let w = makeWorld(passphrase: "orchard-lantern-13", words: old)
        await w.model.start()
        w.model.continueFromExplain()
        await w.model.submitPassphrase("orchard-lantern-13", confirmation: nil)
        w.model.chooseGenerateNewWords()
        guard case .wordsShow(let fresh) = w.model.phase else { Issue.record("\(w.model.phase)"); return }
        #expect(fresh != old && w.model.wordsRegenerated)
        w.model.acknowledgeWordsWritten()
        w.model.confirmWords(fresh.joined(separator: " "))
        for _ in 0..<200 where w.model.phase != .done(.standard) { try await Task.sleep(for: .milliseconds(20)) }
        let vault = try await fetched(w)
        #expect((try? vault.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: old))) == nil, "the old words open nothing")
        #expect(try vault.unwrapMaster(withRecoveryKey: try RecoveryPhrase.recoveryWrapKey(words: fresh)) != nil)
        #expect(w.landings.value.first?.recoveryWords == fresh, "the key file's copy replaced at the land")
    }

    /// The pre-Screen-1 confirm: a library that last synced under ANOTHER
    /// account shows copy §2a's sentence first; *Move It to This Account*
    /// leads into Screen 1 and the adopt road runs right after the create.
    @Test func aForeignLibraryConfirmsTheMoveAndAdoptsAfterTheCreate() async throws {
        let w = makeWorld(foreign: true)
        await w.model.start()
        #expect(w.model.phase == .confirmMove)
        w.model.confirmMove()
        #expect(w.model.phase == .explain)
        w.model.continueFromExplain()
        await w.model.submitPassphrase("orchard-lantern-13", confirmation: "orchard-lantern-13")
        guard case .wordsShow(let words) = w.model.phase else { Issue.record("\(w.model.phase)"); return }
        w.model.acknowledgeWordsWritten()
        w.model.confirmWords(words.joined(separator: " "))
        for _ in 0..<200 where w.model.phase != .done(.standard) { try await Task.sleep(for: .milliseconds(20)) }
        #expect(w.model.phase == .done(.standard) && w.adopts.value == 1, "the adopt road ran once, after the create")
    }

    /// The Keychain refusing to hold the iCloud key under a STANDARD library
    /// refuses the setup whole — a vault born without its Apple copy would
    /// be Castle-shaped, a posture the user never chose.
    @Test func aRefusedAppleKeyRefusesTheSetupBeforeAnythingIsMinted() async throws {
        let w = makeWorld(apple: nil, appleWritesSucceed: false)
        await w.encryption.setUp(passphrase: "orchard-lantern-13", recoveryWords: try RecoveryPhrase.generate())
        #expect(w.encryption.lastError == EncryptionSession.appleKeyRefusedAtSetup)
        #expect(try await w.client.fetchVault() == nil && w.store.load() == nil, "nothing minted")
    }
}
