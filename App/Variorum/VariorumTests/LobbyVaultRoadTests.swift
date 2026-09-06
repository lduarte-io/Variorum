//
//  LobbyVaultRoadTests.swift
//  VariorumTests
//
//  pre-13x batch 4a — THE VAULT ROAD AT THE LOBBY (the postures design
//  §3.6 / corner 17 / ledger 10; copy §3), by use: after a passphrase change
//  elsewhere the NEW word opens this device online at once through the
//  vault and re-wraps the local copy under the vault's descriptor; the OLD
//  word still opens it until then, online and offline; a typo writes
//  nothing; the RETIRED sentence only under a stale recorded descriptor;
//  the offline note only after a transport failure; the twelve words open a
//  library whose local W copy never landed; the current passphrase opens an
//  old backup's key file online; a signed-out device has no vault road; the
//  ceiling hands off; the derivation count. The real road over a scripted
//  gate and a scripted vault format — no network, no Keychain.
//

import CryptoKit
import Dependencies
import Foundation
import Testing
@testable import Variorum
import VariorumCore

@Suite("pre-13x 4a — the lobby's vault road (§3.6): the new word everywhere, the old retiring by use", .serialized)
struct LobbyVaultRoadTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A Castle library whose key file was reconciled against the vault
    /// under the OLD word (`oldKDF` recorded), and a vault since re-wrapped
    /// under the NEW word (`newKDF`) on another device — the sibling of
    /// 3b's change-passphrase drill, at its lobby.
    @MainActor
    private final class World {
        let dir: URL
        let storeURL: URL
        let key: StoreKey
        let master: SymmetricKey
        let oldKDF: PassphraseKDF.Descriptor
        let newKDF: PassphraseKDF.Descriptor
        let words: [String]
        /// The vault as it stands NOW: the master under the NEW word (and
        /// the words), the class keys under the master.
        let format: KeyVaultFormat
        let gate: StoreLaunchGate
        let session = SyncCustodySession()
        let derivations = LockIsolated(0)
        let phases = LockIsolated<[StoreLobby.Phase]>([])
        static let corpusKeyID = "corpus-4a"

        init(localWord: String = "the old word 12", vaultWord: String = "the new word 12",
             landPassphraseCopy: Bool = true, landRecoveryCopy: Bool = false, enrolled: Bool = false,
             recordedKDF: PassphraseKDF.Descriptor? = nil, oldKDF: PassphraseKDF.Descriptor, newKDF: PassphraseKDF.Descriptor) throws {
            dir = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-4a-lobby-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            storeURL = dir.appendingPathComponent("variorum.sqlite")
            key = StoreKey.mint()
            master = SymmetricKey(size: .bits256)
            self.oldKDF = oldKDF
            self.newKDF = newKDF
            words = try RecoveryPhrase.generate()
            format = try KeyVaultFormat.create(
                masterKey: master,
                passphraseKey: try PassphraseKDF.deriveKey(passphrase: vaultWord, descriptor: newKDF),
                recoveryKey: try RecoveryPhrase.recoveryWrapKey(words: words),
                classKeys: [(keyClass: .corpus, keyID: Self.corpusKeyID, key: SymmetricKey(size: .bits256)),
                            (keyClass: .journalBridge, keyID: "bridge-4a", key: SymmetricKey(size: .bits256))],
                kdf: newKDF)
            var envelope = StoreKeyEnvelope()
            if landPassphraseCopy {
                try envelope.setPassphraseWrap(key: key, passphrase: localWord, kdf: oldKDF)
            }
            if landRecoveryCopy {
                try envelope.setRecoveryWrap(key: key, words: words)
            }
            try envelope.masterBox(key: key, under: master)
            try envelope.recordVaultReconciliation(
                kdf: recordedKDF ?? oldKDF, corpusKeyID: Self.corpusKeyID, recoveryWrapDigest: format.recoveryWrapDigest)
            try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
            gate = StoreLaunchGate(
                dials: { _, _ in ProtectionDials(alwaysAsk: true) },
                saveDials: { _, _, _ in },
                legacyMode: { _, _ in nil },
                retireLegacyDials: { _, _ in },
                guardFor: { _ in StoreKeyGuard.inMemory(backing: InMemoryStoreKeyGuardBacking()) },
                appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: InMemoryAppleKeyBacking()) },
                loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
                saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
                setAsideEnvelope: { _ in },
                stamp: { _, _ in nil },
                setStamp: { _, _, _ in },
                // An ENROLLED library (its sync custody present) is
                // INDETERMINATE at the route and acts as its custody shape —
                // gated-or-nowhere ⇒ Castle ⇒ the lobby (2d); a local-only
                // key file with no P copy would derive Standard instead.
                syncCustodyPresent: { _, _ in enrolled })
        }

        func tearDown() { try? FileManager.default.removeItem(at: dir) }

        var keyFileURL: URL {
            StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: StoreKeyEnvelope.fingerprint(of: key))
        }
        func keyFile() throws -> StoreKeyEnvelope { try #require(try StoreKeyEnvelope.load(at: keyFileURL)) }
        func keyFileBytes() throws -> Data { try Data(contentsOf: keyFileURL) }

        /// The road over this world: `vault` nil = offline / signed out.
        func road(vault: LobbyVaultRoad?, ceiling: Duration = .seconds(10))
            -> @Sendable (StoreLobby.Secret, @escaping @Sendable (StoreLobby.Phase) -> Void) async -> Result<StoreKey, StoreLobby.Refusal> {
            let derivations = derivations
            return StoreLobby.envelopeRoad(
                storeURL: storeURL, gate: gate, session: session, vaultRoad: vault, ceiling: ceiling,
                derive: { passphrase, descriptor in
                    derivations.withValue { $0 += 1 }
                    return try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: descriptor)
                })
        }

        var online: LobbyVaultRoad { LobbyVaultRoad(fetch: { [format] in format }) }

        func submit(_ secret: StoreLobby.Secret, vault: LobbyVaultRoad?, ceiling: Duration = .seconds(10))
            async -> Result<StoreKey, StoreLobby.Refusal> {
            let phases = phases
            derivations.setValue(0)
            phases.setValue([])
            return await road(vault: vault, ceiling: ceiling)(secret) { phase in phases.withValue { $0.append(phase) } }
        }
    }

    private func key(of result: Result<StoreKey, StoreLobby.Refusal>) -> StoreKey? {
        if case .success(let key) = result { return key }
        return nil
    }
    private func refusal(of result: Result<StoreKey, StoreLobby.Refusal>) -> StoreLobby.Refusal? {
        if case .failure(let refusal) = result { return refusal }
        return nil
    }

    /// THE VAULT ROAD, BY USE (§12; the 3b drill's RECORDED gap): after a
    /// change elsewhere the NEW word opens the device online at once and
    /// re-wraps the local copy under the vault's descriptor; the OLD word
    /// opens it until then (online and offline); the next open by the new
    /// word is LOCAL — one derivation; the old word then refuses plainly.
    @Test @MainActor func theNewWordOpensOnlineReWrapsTheLocalCopyAndTheOldWordOpensUntilThen() async throws {
        let world = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { world.tearDown() }
        let bytesBefore = try world.keyFileBytes()

        // (1) The OLD word, OFFLINE: the local copy — one derivation, the vault never asked.
        #expect(key(of: await world.submit(.passphrase("the old word 12"), vault: nil)) == world.key)
        #expect(world.derivations.value == 1 && world.phases.value.isEmpty)
        #expect(world.session.derivedWrappingKDF == world.oldKDF, "the held key is the LOCAL copy's derivation")
        // (2) The OLD word, ONLINE: still the local copy (the vault read is cancelled, never awaited).
        #expect(key(of: await world.submit(.passphrase("the old word 12"), vault: world.online)) == world.key)
        #expect(world.derivations.value == 1 && world.phases.value.isEmpty)
        #expect(try world.keyFileBytes() == bytesBefore, "an opened local copy is never rewritten")

        // (3) The NEW word, ONLINE: the local copy refuses, the vault road opens
        //     — two derivations (the local wrap's descriptor ≠ the vault's) —
        //     and the local copy is re-wrapped under the VAULT's descriptor.
        let opened = await world.submit(.passphrase("the new word 12"), vault: world.online)
        #expect(key(of: opened) == world.key, "\(String(describing: refusal(of: opened)?.message))")
        #expect(world.derivations.value == 2, "the local descriptor, then the vault's")
        #expect(world.phases.value == [.checkingAccount], "the phase reports the vault read")
        let rewrapped = try world.keyFile()
        #expect(rewrapped.passphrase?.kdf == world.newKDF, "the local P copy under the vault's descriptor")
        #expect(rewrapped.vaultKDF == world.newKDF && rewrapped.vaultCorpusKeyID == World.corpusKeyID
                && rewrapped.vaultRecoveryWrapDigest == world.format.recoveryWrapDigest,
                "the reconciliation recorded with the vault's digest")
        #expect(try rewrapped.unwrapKey(passphrase: "the new word 12") == world.key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try rewrapped.unwrapKey(passphrase: "the old word 12") }
        let viaMaster = try rewrapped.unwrapKey(master: world.master)
        #expect(rewrapped.master != nil && viaMaster == world.key, "the master-wrapped copy untouched")
        let held = try #require(world.session.derivedWrappingKey)
        #expect(held == (try PassphraseKDF.deriveKey(passphrase: "the new word 12", descriptor: world.newKDF))
                && world.session.derivedWrappingKDF == world.newKDF,
                "the held key is the VAULT's derivation — the ready reconcile's rule (iii) lands custody from it")

        // (4) The NEW word, OFFLINE: the local copy now — one derivation.
        #expect(key(of: await world.submit(.passphrase("the new word 12"), vault: nil)) == world.key)
        #expect(world.derivations.value == 1 && world.phases.value.isEmpty)
        // (5) The OLD word: refused — locally AND at the vault — and, the
        //     recorded descriptor now the vault's, worded as a wrong word.
        let old = try #require(refusal(of: await world.submit(.passphrase("the old word 12"), vault: world.online)))
        #expect(old.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase) && !old.offline)
        #expect(world.derivations.value == 1, "the descriptors agree — the derived key is reused at the vault")
    }

    /// A TYPO WRITES NOTHING (the vault unwrap must succeed first), and the
    /// RETIRED sentence (copy §3) speaks only under a STALE recorded
    /// descriptor — the same typo on a reconciled file is a plain wrong word.
    @Test @MainActor func aTypoWritesNothingAndTheRetiredSentenceSpeaksOnlyUnderAStaleRecord() async throws {
        // (a) The record is stale (the word was changed elsewhere): RETIRED.
        let stale = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { stale.tearDown() }
        let staleBytes = try stale.keyFileBytes()
        let typo = try #require(refusal(of: await stale.submit(.passphrase("not either word"), vault: stale.online)))
        #expect(typo.message == ProtectionCopy.lobbyRetiredPassphrase && !typo.offline)
        #expect(try stale.keyFileBytes() == staleBytes, "a typo writes nothing")
        #expect(stale.session.derivedWrappingKey == nil, "a refused word holds nothing")
        #expect(stale.derivations.value == 2)

        // (b) The record EQUALS the vault's while the P copy is still under the
        //     old descriptor (the migration's leg-5 class): a plain wrong word,
        //     and the vault's derivation still runs (the WRAP's descriptor is
        //     what the local key was made under — ORCHESTRATOR-DECIDED NOTES 2).
        let recorded = try World(recordedKDF: nil, oldKDF: fastKDF(), newKDF: fastKDF())
        defer { recorded.tearDown() }
        var file = try recorded.keyFile()
        try file.recordVaultReconciliation(kdf: recorded.newKDF, corpusKeyID: World.corpusKeyID, recoveryWrapDigest: recorded.format.recoveryWrapDigest)
        try file.write(at: recorded.keyFileURL)
        let recordedBytes = try recorded.keyFileBytes()
        let plain = try #require(refusal(of: await recorded.submit(.passphrase("not either word"), vault: recorded.online)))
        #expect(plain.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
        #expect(recorded.derivations.value == 2, "the wrap's descriptor differs from the vault's — a second derivation")
        #expect(try recorded.keyFileBytes() == recordedBytes)

        // (c) The P copy IS under the vault's descriptor: ONE derivation (reused
        //     at the vault), a plain wrong word.
        let same = fastKDF()
        let reconciled = try World(localWord: "the new word 12", oldKDF: same, newKDF: same)
        defer { reconciled.tearDown() }
        let reconciledBytes = try reconciled.keyFileBytes()
        let one = try #require(refusal(of: await reconciled.submit(.passphrase("not either word"), vault: reconciled.online)))
        #expect(one.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
        #expect(reconciled.derivations.value == 1, "the descriptors agree — derived ONCE")
        #expect(try reconciled.keyFileBytes() == reconciledBytes)
    }

    /// THE OFFLINE NOTE only after a TRANSPORT failure (never for "no vault
    /// / signed out"); the ~10 s CEILING hands off to the local verdict (a
    /// vault that never answers); through the lobby model, the note shows
    /// after that submit and clears at the next.
    @Test @MainActor func theOfflineNoteSpeaksOnlyAfterATransportFailureAndTheCeilingHandsOff() async throws {
        let world = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { world.tearDown() }
        let bytes = try world.keyFileBytes()
        let offline = LobbyVaultRoad(fetch: { throw URLError(.notConnectedToInternet) })
        let refused = try #require(refusal(of: await world.submit(.passphrase("the new word 12"), vault: offline)))
        #expect(refused.offline, "a transport failure ⇒ the offline note")
        #expect(refused.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase),
                "the local verdict — the retired sentence needs the vault's descriptor, which is unreachable")
        #expect(world.phases.value == [.checkingAccount])
        #expect(try world.keyFileBytes() == bytes)

        let signedOut = LobbyVaultRoad(fetch: { nil })
        let noVault = try #require(refusal(of: await world.submit(.passphrase("the new word 12"), vault: signedOut)))
        #expect(!noVault.offline, "no vault / signed out is not offline")

        // The ceiling: a vault that never answers hands off within the ceiling.
        let never = LobbyVaultRoad(fetch: { try await Task.sleep(for: .seconds(3600)); return nil })
        let started = ContinuousClock.now
        let timedOut = try #require(refusal(of: await world.submit(.passphrase("the new word 12"), vault: never, ceiling: .milliseconds(300))))
        #expect(ContinuousClock.now - started < .seconds(5), "the ceiling, not the hour")
        #expect(timedOut.offline && timedOut.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))

        // Through the lobby: the note appears after the offline submit, and
        // the next submit clears it; the phase line rides the report.
        let lobby = StoreLobby(
            demand: .passphrase, biometryOffered: false, passphraseOffered: true, recoveryOffered: false,
            gatedRoad: { nil },
            phasedRoad: world.road(vault: offline),
            progressDelay: .zero,
            complete: { _ in })
        #expect(!lobby.showsOfflineNote && lobby.phase == .idle)
        await lobby.unlock(passphrase: "the new word 12")
        #expect(lobby.showsOfflineNote, "copy §3's note — the lobby knows only by trying")
        #expect(lobby.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
        #expect(lobby.phase == .idle && !lobby.busy)
        let opened = LockIsolated<StoreKey?>(nil)
        let online = StoreLobby(
            demand: .passphrase, biometryOffered: false, passphraseOffered: true, recoveryOffered: false,
            gatedRoad: { nil },
            phasedRoad: world.road(vault: world.online),
            progressDelay: .zero,
            complete: { opened.setValue($0) })
        await online.unlock(passphrase: "the new word 12")
        #expect(opened.value == world.key && !online.showsOfflineNote && online.lastError == nil)
    }

    /// THE TWELVE WORDS open a library whose local W copy was never landed
    /// (§12) — through the vault's recovery wrap and the key file's
    /// master-wrapped copy — and the copy lands, with the vault's digest;
    /// the P copy's record is untouched. Wrong words refuse; a malformed
    /// phrase is its own refusal.
    @Test @MainActor func theTwelveWordsOpenALibraryWhoseLocalWCopyWasNeverLandedAndTheCopyLands() async throws {
        let world = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { world.tearDown() }
        let before = try world.keyFile()
        #expect(before.recovery == nil && before.master != nil)
        #expect(StoreLobby.recoveryRoadExists(before), "the road is OFFERED — the master-wrapped copy serves it")
        #expect(!StoreLobby.recoveryRoadExists(StoreKeyEnvelope()))
        let text = world.words.joined(separator: " ")
        // Offline: no local W copy, no road.
        let offline = try #require(refusal(of: await world.submit(.recoveryText(text), vault: nil)))
        #expect(offline.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.noRecoveryWrap) && !offline.offline)
        // Wrong (valid) words online: refused at the vault, nothing written.
        let other = try RecoveryPhrase.generate().joined(separator: " ")
        let wrong = try #require(refusal(of: await world.submit(.recoveryText(other), vault: world.online)))
        #expect(wrong.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongRecoveryPhrase))
        #expect(try world.keyFile().recovery == nil)
        // A malformed phrase: the phrase's own sentence, the vault never asked.
        let malformed = try #require(refusal(of: await world.submit(.recoveryText("one two three"), vault: world.online)))
        #expect(malformed.message == ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(3)))
        #expect(world.phases.value.isEmpty)
        // The account's words online: the vault road opens; the W copy lands.
        let opened = await world.submit(.recoveryText(text), vault: world.online)
        #expect(key(of: opened) == world.key, "\(String(describing: refusal(of: opened)?.message))")
        #expect(world.phases.value == [.checkingAccount])
        let landed = try world.keyFile()
        let viaWords = try landed.unwrapKey(recoveryWords: world.words)
        #expect(landed.recovery != nil && viaWords == world.key, "the W copy landed")
        #expect(landed.vaultRecoveryWrapDigest == world.format.recoveryWrapDigest)
        #expect(landed.vaultKDF == world.oldKDF && landed.passphrase?.kdf == world.oldKDF,
                "the P copy and its record untouched — a passphrase change elsewhere still speaks at ready")
        // The next words entry is LOCAL.
        #expect(key(of: await world.submit(.recoveryText(text), vault: nil)) == world.key)
    }

    /// THE CURRENT PASSPHRASE OPENS AN OLD BACKUP ONLINE (§12's
    /// master-wrapped-copy pin): a snapshot pair whose passphrase copy is
    /// under a RETIRED word, restored beside a library and opened by the
    /// current word through the vault; the backup FOLDER's pair is never
    /// rewritten — only the restored copy beside the live library is.
    @Test @MainActor func theCurrentPassphraseOpensAnOldBackupOnlineAndTheBackupFolderIsNeverRewritten() async throws {
        let world = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { world.tearDown() }
        // The backup folder holds the day's pair (its key file under the retired word).
        let backups = world.dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let pair = backups.appendingPathComponent("variorum-backup-20260901-\(StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: world.key))).keys.json")
        try FileManager.default.copyItem(at: world.keyFileURL, to: pair)
        let pairBytes = try Data(contentsOf: pair)
        // The retired word opens the restored copy offline (the day's word — decision 11).
        #expect(key(of: await world.submit(.passphrase("the old word 12"), vault: nil)) == world.key)
        // The CURRENT word opens it online through the vault's master and the
        // key file's master-wrapped copy of the library key.
        #expect(key(of: await world.submit(.passphrase("the new word 12"), vault: world.online)) == world.key)
        #expect(try world.keyFile().passphrase?.kdf == world.newKDF, "the restored copy beside the library re-wrapped")
        #expect(try Data(contentsOf: pair) == pairBytes, "the backup folder's pair is never rewritten")
    }

    /// A SIGNED-OUT DEVICE HAS NO VAULT ROAD: the production road over a
    /// throwaway scope reads no session and answers nil without a network
    /// contact; a road-less lobby refuses the new word with the local
    /// sentence and reports no account phase.
    @Test @MainActor func aSignedOutDeviceHasNoVaultRoad() async throws {
        let live = try #require(LobbyVaultRoad.live(scope: "Variorum-4a-throwaway-\(UUID().uuidString.prefix(8))"))
        #expect(try await live.fetch() == nil, "no session in that scope ⇒ no road (no network)")
        let world = try World(oldKDF: fastKDF(), newKDF: fastKDF())
        defer { world.tearDown() }
        let refused = try #require(refusal(of: await world.submit(.passphrase("the new word 12"), vault: nil)))
        #expect(refused.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase) && !refused.offline)
        #expect(world.phases.value.isEmpty && world.derivations.value == 1)
    }

    /// A key file with a master-wrapped copy but NO local secret copies
    /// (a follow by the words alone lands no P copy) still OFFERS the
    /// passphrase road at the lobby, and the vault road opens it — through
    /// the bootstrap's own composition (`lobbyVaultRoad` injected).
    @Test @MainActor func theBootstrapsLobbyOffersThePassphraseRoadOverAMasterOnlyKeyFileAndOpensOnlineThroughIt() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            // The follow-by-words shape (2c): W + the master-wrapped copy, no
            // P copy, an enrolled Castle device.
            // The follow recorded the vault's descriptor as it stood (2c's
            // `writeNewKeyFile`), so the record is CURRENT here.
            let current = fastKDF()
            let world = try World(landPassphraseCopy: false, landRecoveryCopy: true, enrolled: true,
                                  recordedKDF: current, oldKDF: fastKDF(), newKDF: current)
            defer { world.tearDown() }
            #expect(try world.keyFile().passphrase == nil)
            let session = SyncCustodySession()
            let openCount = LockIsolated(0)
            let bootstrap = AppBootstrap(
                testOpener: {
                    openCount.withValue { $0 += 1 }
                    return Result { try AppDatabase.onDisk(url: world.storeURL, key: world.key) }
                        .mapError { AppDatabase.StoreOpenError(storePath: world.storeURL.path, reason: String(describing: $0)) }
                },
                gate: world.gate, testStoreURL: world.storeURL,
                syncCustodySession: session, lobbyVaultRoad: world.online)
            await bootstrap.awaitOpen()
            guard case .locked(let lobby) = bootstrap.state else {
                Issue.record("expected .locked, got \(bootstrap.state)"); return
            }
            #expect(lobby.passphraseOffered && lobby.recoveryOffered, "both secret roads offered — the vault serves the missing local copy")
            await lobby.unlock(passphrase: "not the word")
            #expect(lobby.lastError == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase))
            #expect(openCount.value == 0)
            await lobby.unlock(passphrase: "the new word 12")
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else { Issue.record("expected .ready, got \(bootstrap.state)"); return }
            #expect(openCount.value == 1)
            let landed = try world.keyFile()
            let viaNewWord = try landed.unwrapKey(passphrase: "the new word 12")
            #expect(landed.passphrase?.kdf == world.newKDF && viaNewWord == world.key,
                    "the local P copy landed under the vault's descriptor by the vault road")
            #expect(session.derivedWrappingKDF == world.newKDF, "the shared session holds the vault's derivation for the reconcile")
        }
    }
    /// pre-13x 4b (ledger 59 — 4a's question 6, the one unpinned arm): a
    /// follow-by-words key file carries NO local passphrase copy (W + the
    /// master-wrapped copy only). An ABSENT local copy reads as REFUSED: a
    /// wrong word online under a CHANGED vault descriptor speaks the RETIRED
    /// sentence (the record differs from the vault's — a change happened
    /// elsewhere), under an UNCHANGED one the plain sentence; nothing is
    /// written either way. RED-ON-OLD: a road that treated the absent copy
    /// as "no road" spoke the no-passphrase sentence (4a's revert A2), and
    /// one that spoke plainly whenever the copy is absent loses the retired
    /// discriminator.
    @Test @MainActor func aWrongWordOverAWordsOnlyKeyFileSpeaksRetiredUnderAChangedVaultAndPlainUnderAnUnchangedOne() async throws {
        // (a) The vault's descriptor CHANGED since the record (a passphrase
        //     change elsewhere): RETIRED, nothing written.
        let changed = try World(landPassphraseCopy: false, landRecoveryCopy: true, enrolled: true,
                                oldKDF: fastKDF(), newKDF: fastKDF())
        defer { changed.tearDown() }
        #expect(try changed.keyFile().passphrase == nil && changed.keyFile().recovery != nil, "a follow-by-words file: W + the master copy, no P copy")
        #expect(StoreLobby.passphraseRoadExists(try changed.keyFile()), "the passphrase road is still OFFERED (the master copy serves it)")
        let changedBytes = try changed.keyFileBytes()
        let retired = try #require(refusal(of: await changed.submit(.passphrase("not either word"), vault: changed.online)))
        #expect(retired.message == ProtectionCopy.lobbyRetiredPassphrase && !retired.offline, "\(retired.message)")
        #expect(try changed.keyFileBytes() == changedBytes, "nothing written")
        #expect(changed.session.derivedWrappingKey == nil)
        // (b) The record EQUALS the vault's descriptor (nothing changed
        //     elsewhere): the plain sentence, nothing written.
        let current = fastKDF()
        let unchanged = try World(landPassphraseCopy: false, landRecoveryCopy: true, enrolled: true,
                                  recordedKDF: current, oldKDF: fastKDF(), newKDF: current)
        defer { unchanged.tearDown() }
        let unchangedBytes = try unchanged.keyFileBytes()
        let plain = try #require(refusal(of: await unchanged.submit(.passphrase("not either word"), vault: unchanged.online)))
        #expect(plain.message == ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase) && !plain.offline, "\(plain.message)")
        #expect(try unchanged.keyFileBytes() == unchangedBytes, "nothing written")
        // …and the account's word still opens both (the vault road).
        #expect(key(of: await unchanged.submit(.passphrase("the new word 12"), vault: unchanged.online)) == unchanged.key)
    }
}
