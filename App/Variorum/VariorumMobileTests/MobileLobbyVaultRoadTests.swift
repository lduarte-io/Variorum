//
//  MobileLobbyVaultRoadTests.swift
//  VariorumMobileTests
//
//  pre-13x batch 4a — THE PHONE'S LOBBY VAULT ROAD on the simulator (drill
//  (iv); the postures design §3.6 / copy §3): over the phone's own bootstrap
//  and a scripted vault, a Castle phone whose passphrase was changed on
//  another device opens by the OLD word offline (its local copy), by the
//  NEW word online (the vault road, its local copy re-wrapped under the
//  vault's descriptor), then by the new word offline; a typo under the
//  stale record speaks the RETIRED sentence and writes nothing; a
//  transport failure speaks the offline note.
//

import CryptoKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("pre-13x 4a phone — the lobby's vault road: the new word opens the phone online, the old until then", .serialized)
@MainActor
struct MobileLobbyVaultRoadTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    @Test func theNewWordOpensThePhoneOnlineAndReWrapsItsCopyWhileTheOldWordOpensOffline() async throws {
        try await withDeps { try await drive() }
    }

    private func drive() async throws {
        do {
            let dir = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-4a-phone-lobby-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: dir) }
            let storeURL = dir.appendingPathComponent("store.sqlite")
            let key = StoreKey.mint()
            let master = SymmetricKey(size: .bits256)
            let oldKDF = fastKDF()
            let newKDF = fastKDF()
            // The vault as another device left it: the master under the NEW word.
            let format = try KeyVaultFormat.create(
                masterKey: master,
                passphraseKey: try PassphraseKDF.deriveKey(passphrase: "the new word 12", descriptor: newKDF),
                recoveryKey: nil,
                classKeys: [(keyClass: .corpus, keyID: "corpus-4a", key: SymmetricKey(size: .bits256)),
                            (keyClass: .journalBridge, keyID: "bridge-4a", key: SymmetricKey(size: .bits256))],
                kdf: newKDF)
            // The phone's key file: the P copy under the OLD word, reconciled
            // under the OLD descriptor, the master-wrapped copy of the library key.
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "the old word 12", kdf: oldKDF)
            try envelope.setMasterWrappedCopy(key: key, under: master)
            try envelope.recordVaultReconciliation(kdf: oldKDF, corpusKeyID: "corpus-4a", recoveryWrapDigest: nil)
            let box = ScriptedEnvelopeBox(envelope)
            // Castle, Always ask (no biometry on the scripted device).
            let backing = InMemoryStoreKeyGuardBacking(biometryAvailable: false, biometricSucceeds: false)
            let gate = StoreLaunchGate.scripted(
                dials: ScriptedDialsBox(ProtectionDials(alwaysAsk: true)), backing: backing, envelope: box)
            let session = SyncCustodySession()
            let offline = LockIsolated(false)
            let vaultReads = LockIsolated(0)
            let road = LobbyVaultRoad(fetch: {
                if offline.value { throw URLError(.notConnectedToInternet) }
                vaultReads.withValue { $0 += 1 }
                return format
            })
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                        .mapError { AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: $0)) }
                },
                gate: gate, testStoreURL: storeURL,
                syncCustodySession: session, lobbyVaultRoad: road)
            await bootstrap.awaitOpen()
            guard case .locked(let lobby) = bootstrap.state else {
                Issue.record("expected .locked, got \(bootstrap.state)"); return
            }
            #expect(lobby.demand == .passphrase && lobby.passphraseOffered)

            // A typo ONLINE under the stale record: the vault refused too ⇒ the
            // RETIRED sentence (copy §3); nothing written, nothing opened.
            let bytesBefore = box.value
            await lobby.unlock(passphrase: "not either word")
            #expect(lobby.lastError == ProtectionCopy.lobbyRetiredPassphrase, "\(lobby.lastError ?? "nil")")
            #expect(!lobby.showsOfflineNote && box.value == bytesBefore && openCount.value == 0)

            // The OLD word: the local copy opens the phone — the vault never read for it.
            let readsBefore = vaultReads.value
            await lobby.unlock(passphrase: "the old word 12")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else { Issue.record("expected .ready by the old word, got \(bootstrap.state)"); return }
            #expect(openCount.value == 1 && box.value == bytesBefore)
            #expect(session.derivedWrappingKDF == oldKDF, "the held key is the local copy's derivation")
            _ = readsBefore

            // Lock; the NEW word ONLINE: the vault road opens the phone and
            // re-wraps its local copy under the vault's descriptor.
            await bootstrap.lock()
            guard case .locked(let second) = bootstrap.state else { Issue.record("expected .locked after Lock Now"); return }
            #expect(second.passphraseOffered)
            await second.unlock(passphrase: "the new word 12")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("expected .ready by the new word online, got \(bootstrap.state) — \(second.lastError ?? "")"); return
            }
            #expect(openCount.value == 2)
            let rewrapped = try #require(box.value)
            #expect(rewrapped.passphrase?.kdf == newKDF && rewrapped.vaultKDF == newKDF && rewrapped.vaultCorpusKeyID == "corpus-4a",
                    "the phone's local copy under the vault's descriptor; the reconciliation recorded")
            #expect(try rewrapped.unwrapKey(passphrase: "the new word 12") == key)
            #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try rewrapped.unwrapKey(passphrase: "the old word 12") }
            #expect(session.derivedWrappingKDF == newKDF, "the held key is the vault's derivation — the ready reconcile lands custody from it")

            // Lock; OFFLINE: the NEW word opens by the local copy now; the OLD
            // word is refused with the plain sentence and the offline note.
            await bootstrap.lock()
            guard case .locked(let third) = bootstrap.state else { Issue.record("expected .locked"); return }
            offline.setValue(true)
            let bytesRewrapped = box.value
            await third.unlock(passphrase: "the old word 12")
            #expect(third.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
            #expect(third.showsOfflineNote, "copy §3's offline note — after a submit whose vault read failed")
            #expect(box.value == bytesRewrapped && openCount.value == 2)
            await third.unlock(passphrase: "the new word 12")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else { Issue.record("expected .ready by the new word offline, got \(bootstrap.state)"); return }
            #expect(openCount.value == 3 && !third.showsOfflineNote)
        }
    }
}
