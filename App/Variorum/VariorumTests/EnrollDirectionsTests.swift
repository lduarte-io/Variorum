//
//  EnrollDirectionsTests.swift
//  VariorumTests
//
//  pre-13x batch 3a — ENROLL's join roads on the app seam (the postures
//  design §5's Enroll row; copy §2d): (b) the Castle enroll lands custody and
//  the key file through the landing hook with the VAULT's descriptor and the
//  typed secret (corner 27); (c) a Standard-born library joining a CASTLE
//  account routes the SAME door to the runner's follow (the re-key road)
//  instead of a bare custody save; (d) a Castle-born library joining a
//  STANDARD account, after consent, opens the vault by the iCloud key when
//  it is the one the copy is under (nothing typed), else by the typed secret,
//  lands custody + the master copy, then runs the follow into Standard;
//  Cancel moves nothing. Over the raw-JSON scripted vault the flow suites
//  keep — no network, no Keychain.
//

import CryptoKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// The raw-JSON `key_vault` responder the flow suites keep (theirs is
/// private to their file) — the ONE write road is the RPC emulation.
private final class ScriptedVault: @unchecked Sendable {
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
@Suite("pre-13x 3a — enroll's directed joins on the app seam (copy §2d)")
struct EnrollDirectionsTests {
    private final class Recorder: @unchecked Sendable {
        let lock = NSLock()
        var landings: [VaultLanding] = []
        var castleJoins: [(String?, [String]?)] = []
        var standardJoins = 0
        func with<T>(_ body: () -> T) -> T { lock.lock(); defer { lock.unlock() }; return body() }
    }

    private func makeClient(_ vault: ScriptedVault) -> KeyVaultClient {
        KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.3a.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token-3a", userID: "user-e2ee")),
            load: vault.load)
    }

    private func makeSession(store: DeviceKeyStore, client: KeyVaultClient) -> EncryptionSession {
        EncryptionSession(store: store, client: client, signedIn: { true })
    }

    /// An account's vault as another device left it: the passphrase wrap,
    /// the recovery wrap, and (Standard) the Apple-held copy.
    private func establishVault(
        _ client: KeyVaultClient, passphrase: String, appleUnder apple: AppleKey? = nil
    ) async throws -> (DeviceKeyMaterial, [String]) {
        let enrollment = VaultEnrollment(client: client)
        let material = try await enrollment.setUp(passphrase: passphrase)
        let words = try RecoveryPhrase.generate()
        try await enrollment.landRecoveryWrap(words: words, material: material, allowReplace: false)
        if let apple {
            let fetched = try #require(try await client.fetchVault())
            try await client.updateVault(
                try fetched.format.settingAppleHeldCopy(
                    masterKey: material.masterSymmetricKey, appleKey: apple.symmetricKey, appleKeyID: apple.id),
                expectedRevision: fetched.revision,
                keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
        }
        return (material, words)
    }

    /// (b): the Castle enroll — custody + the landing with the vault's
    /// descriptor and the typed passphrase; the words road lands the typed
    /// words. RED ON OLD: the enroll fired `onPassphraseChanged` (a FRESH
    /// descriptor's store wrap — the lobby derived twice) and no master copy.
    @Test func theCastleEnrollLandsCustodyAndTheKeyFileUnderTheVaultsDescriptor() async throws {
        let vault = ScriptedVault()
        let recorder = Recorder()
        let client = makeClient(vault)
        _ = try await establishVault(client, passphrase: "orchard-lantern-13")
        let vaultKDF = try #require(try await client.fetchVault()).format.kdf

        let store = DeviceKeyStore.inMemory()
        let second = makeSession(store: store, client: client)
        second.onVaultMaterialLanded = { landing in recorder.with { recorder.landings.append(landing) } }
        second.enrollFacts = { EnrollFacts(accountPosture: .castle, libraryPosture: .castle, appleState: .notApplicable) }
        await second.enroll(passphrase: "orchard-lantern-13")
        #expect(second.lastError == nil)
        #expect(second.state == .enrolled(hasRecoveryWrap: true))
        #expect(store.load() != nil, "custody landed")
        let landing = try #require(recorder.with { recorder.landings.first })
        #expect(landing.kdf == vaultKDF, "the VAULT's descriptor rides to the key file — the lobby derives once")
        #expect(landing.passphrase == "orchard-lantern-13" && landing.recoveryWords == nil)
        #expect(landing.material.corpusKeyID == store.load()?.corpusKeyID)
    }

    /// (c): a Standard-born library joining CASTLE — the same door routes to
    /// the runner's follow with the typed secret (the re-key road), and the
    /// session itself saves NO custody (the runner's road does). RED ON OLD:
    /// the door saved custody bare and left the Standard-era key file with
    /// its iCloud copy beside a Castle account's library.
    @Test func aStandardBornLibraryJoiningCastleTakesTheFollowsRoad() async throws {
        let vault = ScriptedVault()
        let recorder = Recorder()
        let client = makeClient(vault)
        _ = try await establishVault(client, passphrase: "orchard-lantern-13")
        let store = DeviceKeyStore.inMemory()
        let joining = makeSession(store: store, client: client)
        joining.enrollFacts = { EnrollFacts(accountPosture: .castle, libraryPosture: .standard, appleState: .notApplicable) }
        joining.joinCastleAct = { passphrase, words in recorder.with { recorder.castleJoins.append((passphrase, words)) } }
        joining.onVaultMaterialLanded = { landing in recorder.with { recorder.landings.append(landing) } }

        await joining.enroll(passphrase: "orchard-lantern-13")
        #expect(recorder.with { recorder.castleJoins.map { $0.0 } } == ["orchard-lantern-13"], "the follow's road, with the typed passphrase")
        #expect(store.load() == nil, "the session saved no custody of its own — the runner's road lands it")
        #expect(recorder.with { recorder.landings.isEmpty }, "…and no bare landing")
        let words = try RecoveryPhrase.generate()
        await joining.enroll(recoveryWordsText: words.joined(separator: " "))
        #expect(recorder.with { recorder.castleJoins.count } == 2 && recorder.with { recorder.castleJoins.last?.1 } == words)
        // A malformed phrase never reaches the road.
        await joining.enroll(recoveryWordsText: "only three words")
        #expect(recorder.with { recorder.castleJoins.count } == 2)
        #expect(joining.lastError == EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(3)))
    }

    /// (d): a Castle-born library joining STANDARD after consent — A opens
    /// the vault's copy when it is the one (nothing typed), custody + the
    /// master copy land, the follow into Standard runs; A absent ⇒ the typed
    /// passphrase road; nothing typed and no A ⇒ refused in words; Cancel
    /// moves nothing. RED ON OLD: no join road existed (a Castle-born
    /// library on a Standard account could only enroll by the passphrase
    /// and kept its gate — the stricter gate decision 1 forbids).
    @Test func aCastleBornLibraryJoiningStandardOpensByTheAppleKeyThenFollowsIntoStandard() async throws {
        let vault = ScriptedVault()
        let recorder = Recorder()
        let apple = AppleKey.mint()
        let client = makeClient(vault)
        _ = try await establishVault(client, passphrase: "orchard-lantern-13", appleUnder: apple)
        let created = try #require(try await client.fetchVault()).format
        #expect(created.appleKeyID == apple.id, "the account's vault carries the Apple-held copy under this A")

        let store = DeviceKeyStore.inMemory()
        let joining = makeSession(store: store, client: client)
        joining.enrollFacts = { EnrollFacts(accountPosture: .standard, libraryPosture: .castle, appleState: .matched) }
        joining.readAppleKey = { apple }
        joining.joinStandardAct = { recorder.with { recorder.standardJoins += 1 } }
        joining.onVaultMaterialLanded = { landing in recorder.with { recorder.landings.append(landing) } }

        joining.declineStandardJoin()
        #expect(joining.declinedStandardJoin && store.load() == nil && recorder.with { recorder.standardJoins } == 0, "Cancel moves nothing")

        await joining.joinStandard()
        #expect(joining.lastError == nil)
        #expect(store.load()?.corpusKeyID == created.classKey(for: .corpus)?.keyID, "M by A: custody holds the account's keys, nothing typed")
        #expect(recorder.with { recorder.landings.first?.passphrase } == nil && recorder.with { recorder.landings.count } == 1)
        #expect(recorder.with { recorder.standardJoins } == 1, "the follow into Standard ran")
        #expect(!joining.declinedStandardJoin && joining.state == .enrolled(hasRecoveryWrap: true))

        // A absent: the typed passphrase road; nothing typed refuses in words.
        let noApple = DeviceKeyStore.inMemory()
        let typed = makeSession(store: noApple, client: client)
        typed.enrollFacts = { EnrollFacts(accountPosture: .standard, libraryPosture: .castle, appleState: .absent) }
        typed.readAppleKey = { nil }
        typed.joinStandardAct = { recorder.with { recorder.standardJoins += 1 } }
        typed.onVaultMaterialLanded = { landing in recorder.with { recorder.landings.append(landing) } }
        await typed.joinStandard()
        #expect(typed.lastError != nil && noApple.load() == nil, "nothing typed and no A: refused, nothing landed")
        await typed.joinStandard(typedPassphrase: "not-it")
        #expect(typed.lastError == "Wrong encryption passphrase." && noApple.load() == nil)
        await typed.joinStandard(typedPassphrase: "orchard-lantern-13")
        #expect(typed.lastError == nil && noApple.load() != nil)
        #expect(recorder.with { recorder.landings.last?.passphrase } == "orchard-lantern-13")
        #expect(recorder.with { recorder.standardJoins } == 2)
    }
}
