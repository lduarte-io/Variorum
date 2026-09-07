//
//  StoreKeyEnvelopeTests.swift
//  VariorumCoreTests
//
//  Phase 13p, Batch 2 (commit 1) — the store key's wrapped copies
//  (R13p-4: one secret — the 14b Argon2id + BIP-39 machinery REUSED to
//  wrap the store key; RFC 3394 refuses a wrong secret, never yields
//  garbage), the replace-wholesale semantics the R13p-9 reset door rides
//  (after a re-wrap the OLD passphrase unwraps NOTHING), and the sidecar
//  file's IO honesty (absent reads as nil; CORRUPT throws — it must never
//  read as "no passphrase set").
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("pre-13x 3b — the descriptor floor on the key file's passphrase roads")
struct StoreKeyEnvelopeFloorTests {
    /// A key file whose passphrase wrap carries a BELOW-FLOOR descriptor is
    /// refused at both passphrase roads BEFORE any derivation runs — the
    /// descriptor here asks for 4 GiB of memory in ONE pass: a derivation
    /// would take seconds or die; the refusal is instant. The relaxed floor
    /// (the test host's) opens the same file, which is how the suites' fast
    /// wraps keep working. RED ON OLD: the tampered descriptor was derived
    /// as written.
    @Test func aWrapBelowTheFloorRefusesBeforeDerivingAtBothPassphraseRoads() throws {
        let key = StoreKey.mint()
        let cheap = PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: cheap)
        // The same wrap re-labelled with a monstrous, still-below-floor descriptor.
        var tampered = envelope
        var monstrous = cheap
        monstrous.memoryKiB = 4 * 1024 * 1024
        tampered.passphrase = StoreKeyEnvelope.PassphraseWrap(kdf: monstrous, wrapped: envelope.passphrase!.wrapped)
        let start = ContinuousClock.now
        #expect(throws: PassphraseKDFError.self) {
            _ = try tampered.unwrapKey(passphrase: "sesame", floor: .production)
        }
        #expect(ContinuousClock.now - start < .seconds(1), "refused before any derivation")
        #expect(throws: PassphraseKDFError.self) {
            _ = try tampered.unwrapKey(passphraseKey: SymmetricKey(size: .bits256), floor: .production)
        }
        #expect(throws: PassphraseKDFError.self) {
            _ = try envelope.unwrapKey(passphrase: "sesame", floor: .production)
        }
        #expect(try envelope.unwrapKey(passphrase: "sesame", floor: .relaxedForTests) == key)
    }
}

@Suite("Phase 13p — the vault's held-master passphrase re-wrap (R13p-9's vault half)")
struct VaultRewrapFormatTests {
    @Test func rewrapMovesThePassphraseAndNothingElse() throws {
        let master = SymmetricKey(size: .bits256)
        let corpus = SymmetricKey(size: .bits256)
        let oldSalt = PassphraseKDF.randomSalt()
        let oldDescriptor = PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1, salt: oldSalt, outputBytes: 32)
        let oldKey = try PassphraseKDF.deriveKey(passphrase: "old", descriptor: oldDescriptor)
        let recoveryKey = SymmetricKey(size: .bits256)
        let vault = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: oldKey, recoveryKey: recoveryKey,
            classKeys: [(keyClass: .corpus, keyID: "cid", key: corpus)],
            kdf: oldDescriptor)

        let newDescriptor = PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
        let newKey = try PassphraseKDF.deriveKey(passphrase: "new", descriptor: newDescriptor)
        let rewrapped = try vault.rewrappingPassphrase(
            masterKey: master, passphraseKey: newKey, kdf: newDescriptor)

        // The new passphrase unwraps; the OLD one no longer does.
        #expect(try rewrapped.unwrapMaster(withPassphraseKey: newKey).data == master.data)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try rewrapped.unwrapMaster(withPassphraseKey: oldKey)
        }
        // Recovery wrap and class keys untouched (R-7's soft door).
        #expect(rewrapped.masterWrappedByRecovery == vault.masterWrappedByRecovery)
        #expect(rewrapped.classKeys == vault.classKeys)
        #expect(rewrapped.kdf == newDescriptor)
    }

    @Test func rewrapRefusesAMismatchedMaster() throws {
        let master = SymmetricKey(size: .bits256)
        let descriptor = PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
        let passphraseKey = try PassphraseKDF.deriveKey(passphrase: "pp", descriptor: descriptor)
        let vault = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: passphraseKey, recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "cid", key: SymmetricKey(size: .bits256))],
            kdf: descriptor)
        #expect(throws: KeyVaultError.masterKeyMismatch) {
            _ = try vault.rewrappingPassphrase(
                masterKey: SymmetricKey(size: .bits256),
                passphraseKey: passphraseKey, kdf: descriptor)
        }
    }
}

@Suite("Phase 13p — the store-key envelope (wraps)")
struct StoreKeyEnvelopeTests {
    /// Small-but-valid Argon2id parameters so the suite stays fast; the
    /// production default (the v1 ~64 MiB class) is pinned by the 14b KDF
    /// tests — `setPassphraseWrap` honors whatever descriptor it stores,
    /// which is exactly the R-7 parameter-agility contract.
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id,
            argon2Version: 0x13,
            memoryKiB: 256,
            iterations: 1,
            parallelism: 1,
            salt: PassphraseKDF.randomSalt(),
            outputBytes: 32)
    }

    @Test func passphraseWrapRoundTrips() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(
            key: key, passphrase: "correct horse battery staple", kdf: fastKDF())
        let unwrapped = try envelope.unwrapKey(passphrase: "correct horse battery staple")
        #expect(unwrapped == key)
    }

    @Test func wrongPassphraseRefusesTyped() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "right", kdf: fastKDF())
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            try envelope.unwrapKey(passphrase: "wrong")
        }
    }

    @Test func emptyPassphraseRefusesAtTheWrap() {
        var envelope = StoreKeyEnvelope()
        #expect(throws: StoreKeyEnvelopeError.emptyPassphrase) {
            try envelope.setPassphraseWrap(
                key: .mint(), passphrase: "", kdf: fastKDF())
        }
    }

    @Test func missingWrapsRefuseByName() {
        let envelope = StoreKeyEnvelope()
        #expect(throws: StoreKeyEnvelopeError.noPassphraseWrap) {
            try envelope.unwrapKey(passphrase: "anything")
        }
        #expect(throws: StoreKeyEnvelopeError.noRecoveryWrap) {
            try envelope.unwrapKey(recoveryWords: ["abandon"])
        }
    }

    /// THE RESET DOOR'S SUBSTRATE PIN (R13p-9, "red-pinned: the old wrap
    /// must stop unwrapping"): a re-wrap REPLACES wholesale — the old
    /// passphrase's derived key has nothing left to unwrap. The
    /// app-level reset door's behavioral revert (skip-the-replace) is
    /// exercised against this exact property.
    @Test func reWrapReplacesWholesale_theOldPassphraseStopsUnwrapping() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the old one", kdf: fastKDF())
        let oldWrap = envelope.passphrase

        try envelope.setPassphraseWrap(key: key, passphrase: "the new one", kdf: fastKDF())
        #expect(envelope.passphrase != oldWrap, "the wrap row itself is replaced")
        #expect(try envelope.unwrapKey(passphrase: "the new one") == key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            try envelope.unwrapKey(passphrase: "the old one")
        }
    }

    @Test func recoveryWrapRoundTripsAndWrongPhraseRefuses() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        let words = try RecoveryPhrase.generate()
        try envelope.setRecoveryWrap(key: key, words: words)
        #expect(try envelope.unwrapKey(recoveryWords: words) == key)

        // A DIFFERENT valid phrase: checksum passes, unwrap refuses.
        let other = try RecoveryPhrase.generate()
        #expect(throws: StoreKeyEnvelopeError.wrongRecoveryPhrase) {
            try envelope.unwrapKey(recoveryWords: other)
        }
    }

    @Test func phraseTyposSpeakAsThemselves() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        var words = try RecoveryPhrase.generate()
        try envelope.setRecoveryWrap(key: key, words: words)
        // A swapped word breaks the built-in checksum — the refusal names
        // the typo class, never a generic "wrong phrase". The checksum is
        // FOUR bits, so one substituted word still passes it 1 time in 16
        // (pre-13x 2c found this pin red at those odds in a full run —
        // `wrongRecoveryPhrase` from the unwrap that then ran); substitute
        // word by word until the checksum actually breaks (12 misses in a
        // row: 16^-12), so the pin asserts the typo class it names.
        for index in words.indices {
            var candidate = words
            candidate[index] = candidate[index] == "abandon" ? "ability" : "abandon"
            if (try? RecoveryPhrase.recoveryWrapKey(words: candidate)) == nil {
                words = candidate
                break
            }
        }
        do {
            _ = try envelope.unwrapKey(recoveryWords: words)
            Issue.record("a checksum-breaking typo must refuse")
        } catch let error as RecoveryPhraseError {
            #expect(error == .checksumMismatch || {
                if case .unknownWord = error { return true } else { return false }
            }())
        }
    }

    @Test func newerFormatRefusesEveryOperation() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope(formatVersion: StoreKeyEnvelope.currentFormatVersion + 1)
        #expect(throws: StoreKeyEnvelopeError.newerFormat(StoreKeyEnvelope.currentFormatVersion + 1)) {
            try envelope.setPassphraseWrap(key: key, passphrase: "x", kdf: fastKDF())
        }
        #expect(throws: StoreKeyEnvelopeError.newerFormat(StoreKeyEnvelope.currentFormatVersion + 1)) {
            try envelope.unwrapKey(passphrase: "x")
        }
    }

    // MARK: - The sidecar file

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-env-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @Test func fileRoundTripsBesideTheStore() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let url = StoreKeyEnvelope.legacyURL(besideStore: storeURL)
        #expect(url.lastPathComponent == StoreKeyEnvelope.filename)
        #expect(url.deletingLastPathComponent() == storeURL.deletingLastPathComponent())

        #expect(try StoreKeyEnvelope.load(at: url) == nil, "absent reads as nil")

        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: .mint(), passphrase: "pp", kdf: fastKDF())
        try envelope.write(at: url)
        let loaded = try StoreKeyEnvelope.load(at: url)
        #expect(loaded == envelope)
    }

    @Test func corruptFileThrows_neverReadsAsNoPassphrase() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent(StoreKeyEnvelope.filename)
        try Data("not json at all".utf8).write(to: url)
        do {
            _ = try StoreKeyEnvelope.load(at: url)
            Issue.record("a corrupt envelope must throw, not read as absent")
        } catch let error as StoreKeyEnvelopeError {
            guard case .unreadable = error else {
                Issue.record("expected .unreadable, got \(error)")
                return
            }
        }
    }

    @Test func envelopeCarriesNoKeyBytes() throws {
        // The sidecar is deliberately non-secret: the raw key must never
        // appear in it, hex or bytes.
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "pp", kdf: fastKDF())
        let words = try RecoveryPhrase.generate()
        try envelope.setRecoveryWrap(key: key, words: words)
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent(StoreKeyEnvelope.filename)
        try envelope.write(at: url)
        let bytes = try Data(contentsOf: url)
        #expect(bytes.range(of: key.data) == nil)
        #expect(bytes.range(of: Data(key.hexEncoded.utf8)) == nil)
    }
}

/// pre-13x batch 1a — THE KEY FILE, FORMAT 2 (the postures design §3.5).
/// Red-on-old by construction: the format-2 fields, the master/apple roads
/// and the fingerprint naming do not exist on the pre-1a tree (compile
/// failure); the format-1 READ pin below is the behavioural half — a
/// 13p-era file decodes with the new fields nil, never refuses.
@Suite("pre-13x 1a — the key file, format 2")
struct StoreKeyEnvelopeFormat2Tests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-env2-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A 13p-era file (formatVersion 1, passphrase + recovery only) reads as
    /// "no master copy, no iCloud copy, unknown descriptor" — and still
    /// opens by its passphrase.
    @Test func aFormatOneFileReadsWithTheNewFieldsNilAndStillOpens() throws {
        let key = StoreKey.mint()
        var legacy = StoreKeyEnvelope(formatVersion: StoreKeyEnvelope.formatVersion1)
        try legacy.setPassphraseWrap(key: key, passphrase: "pp", kdf: fastKDF())
        legacy.formatVersion = StoreKeyEnvelope.formatVersion1  // a file the OLD build wrote
        let encoder = JSONEncoder()
        var object = try JSONSerialization.jsonObject(with: encoder.encode(legacy)) as! [String: Any]
        // Exactly the 13p on-disk shape: no format-2 keys at all.
        for gone in ["master", "apple", "appleKeyID", "vaultKDF", "vaultCorpusKeyID"] {
            object.removeValue(forKey: gone)
        }
        let bytes = try JSONSerialization.data(withJSONObject: object)
        let read = try JSONDecoder().decode(StoreKeyEnvelope.self, from: bytes)
        #expect(read.formatVersion == 1)
        #expect(read.master == nil, "no master copy")
        #expect(read.apple == nil && read.appleKeyID == nil, "no iCloud copy")
        #expect(read.vaultKDF == nil && read.vaultCorpusKeyID == nil, "unknown descriptor")
        #expect(try read.unwrapKey(passphrase: "pp") == key, "the passphrase road is untouched")
        #expect(throws: StoreKeyEnvelopeError.noMasterWrappedCopy) { _ = try read.unwrapKey(master: SymmetricKey(size: .bits256)) }
        #expect(throws: StoreKeyEnvelopeError.noAppleWrappedCopy) { _ = try read.unwrapKey(apple: SymmetricKey(size: .bits256)) }
    }

    /// A wrap landing on a format-1 envelope writes it as format 2.
    @Test func aWrapLandingRewritesAFormatOneFileAsFormatTwo() throws {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope(formatVersion: StoreKeyEnvelope.formatVersion1)
        #expect(envelope.formatVersion == 1)
        try envelope.setPassphraseWrap(key: key, passphrase: "pp", kdf: fastKDF())
        #expect(envelope.formatVersion == StoreKeyEnvelope.currentFormatVersion)
    }

    @Test func theMasterRoadRoundTripsAndRefusesAForeignMaster() throws {
        let key = StoreKey.mint()
        let master = SymmetricKey(size: .bits256)
        var envelope = StoreKeyEnvelope()
        try envelope.setMasterWrappedCopy(key: key, under: master)
        #expect(envelope.master != nil)
        #expect(envelope.keyFingerprint == StoreKeyEnvelope.fingerprint(of: key))
        #expect(try envelope.unwrapKey(master: master) == key)
        #expect(throws: StoreKeyEnvelopeError.wrongMasterKey) {
            _ = try envelope.unwrapKey(master: SymmetricKey(size: .bits256))
        }
    }

    @Test func theAppleRoadRoundTripsRecordsItsKeyIDAndCanBeRemoved() throws {
        let key = StoreKey.mint()
        let apple = SymmetricKey(size: .bits256)
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: apple, appleKeyID: "apple-key-1")
        #expect(envelope.appleKeyID == "apple-key-1")
        #expect(try envelope.unwrapKey(apple: apple) == key)
        #expect(throws: StoreKeyEnvelopeError.wrongAppleKey) {
            _ = try envelope.unwrapKey(apple: SymmetricKey(size: .bits256))
        }
        try envelope.removeAppleWrappedCopy()
        #expect(envelope.apple == nil && envelope.appleKeyID == nil, "Castle: no iCloud copy")
        #expect(throws: StoreKeyEnvelopeError.noAppleWrappedCopy) { _ = try envelope.unwrapKey(apple: apple) }
    }

    @Test func theVaultReconciliationIsRecorded() throws {
        var envelope = StoreKeyEnvelope()
        let kdf = fastKDF()
        try envelope.recordVaultReconciliation(kdf: kdf, corpusKeyID: "corpus-9", recoveryWrapDigest: "ab12")
        #expect(envelope.vaultKDF == kdf)
        #expect(envelope.vaultCorpusKeyID == "corpus-9")
        #expect(envelope.vaultRecoveryWrapDigest == "ab12")
        try envelope.recordVaultRecoveryWrapDigest("cd34")
        #expect(envelope.vaultRecoveryWrapDigest == "cd34" && envelope.vaultKDF == kdf, "the digest alone moves")
    }

    /// pre-13x 4a (ledger 53): the recovery-wrap digest is a format-2
    /// ADDITIVE optional — a file written without it decodes nil (unknown,
    /// owes no notice); a recorded one round-trips through the file; the
    /// digest is SHA-256 hex of the wrap's bytes and nil for no wrap.
    @Test func theRecoveryWrapDigestIsAdditiveAndRoundTrips() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-4a-digest-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("variorum-keys.json")
        let wrap = Data((0..<40).map { UInt8($0) })
        let digest = try #require(RecoveryWrapDigest.hex(of: wrap))
        #expect(digest.count == 64 && digest.allSatisfy(\.isHexDigit))
        #expect(RecoveryWrapDigest.hex(of: nil) == nil)
        #expect(RecoveryWrapDigest.hex(of: wrap) == digest, "deterministic")
        var envelope = StoreKeyEnvelope()
        try envelope.recordVaultReconciliation(kdf: fastKDF(), corpusKeyID: "corpus-1", recoveryWrapDigest: digest)
        try envelope.write(at: url)
        let back = try #require(try StoreKeyEnvelope.load(at: url))
        #expect(back.vaultRecoveryWrapDigest == digest)
        // A pre-4a file: the same JSON without the field decodes nil.
        var json = try #require(try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any])
        json.removeValue(forKey: "vaultRecoveryWrapDigest")
        try JSONSerialization.data(withJSONObject: json).write(to: url)
        let older = try #require(try StoreKeyEnvelope.load(at: url))
        #expect(older.vaultRecoveryWrapDigest == nil && older.vaultCorpusKeyID == "corpus-1")
    }

    /// pre-13x 4a (ledger 54): a passphrase wrap made from a DERIVED key
    /// under a descriptor opens under the TYPED word — the follow's new key
    /// file from the word typed at the lobby, never asked twice.
    @Test func aWrapFromADerivedKeyOpensUnderTheTypedWord() throws {
        let key = StoreKey.mint()
        let kdf = fastKDF()
        let derived = try PassphraseKDF.deriveKey(passphrase: "typed once", descriptor: kdf)
        let wrap = try StoreKeyEnvelope.makePassphraseWrap(key: key, passphraseKey: derived, kdf: kdf)
        var envelope = StoreKeyEnvelope()
        try envelope.adoptPassphraseWrap(wrap, key: key)
        #expect(try envelope.unwrapKey(passphrase: "typed once") == key)
        #expect(try envelope.unwrapKey(passphraseKey: derived) == key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) { _ = try envelope.unwrapKey(passphrase: "typed twice") }
    }

    /// Naming: `variorum-keys-<fp16>.json`; the legacy name parses to no
    /// fingerprint; a writer with a fingerprint prefers the fingerprint name.
    @Test func filesAreNamedByFingerprint() throws {
        let key = StoreKey.mint()
        let fp = StoreKeyEnvelope.fingerprint(of: key)
        #expect(fp.count == 16)
        let name = StoreKeyEnvelope.filename(forFingerprint: fp)
        #expect(name == "variorum-keys-\(fp).json")
        #expect(StoreKeyEnvelope.fingerprint(fromFilename: name) == fp)
        #expect(StoreKeyEnvelope.fingerprint(fromFilename: StoreKeyEnvelope.filename) == nil)
        #expect(StoreKeyEnvelope.fingerprint(fromFilename: "variorum-keys-nothex.json") == nil)
        #expect(StoreKeyEnvelope.shortFingerprint(fp) == String(fp.prefix(8)))
        let storeURL = URL(fileURLWithPath: "/tmp/lib/variorum.sqlite")
        var envelope = StoreKeyEnvelope()
        #expect(envelope.preferredURL(besideStore: storeURL).lastPathComponent == StoreKeyEnvelope.filename,
                "a fingerprint-less envelope still writes under the legacy name")
        try envelope.setPassphraseWrap(key: key, passphrase: "pp", kdf: fastKDF())
        #expect(envelope.preferredURL(besideStore: storeURL).lastPathComponent == name)
    }

    /// `locate` finds the store's CURRENT key file without the key: the
    /// sole fingerprint file wins over a legacy one; a legacy file alone is
    /// it; nothing ⇒ nil.
    @Test func locateFindsTheCurrentKeyFileWithoutTheKey() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL) == nil)
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL) == nil)

        let legacyKey = StoreKey.mint()
        var legacy = StoreKeyEnvelope(formatVersion: 1)
        try legacy.setPassphraseWrap(key: legacyKey, passphrase: "pp", kdf: fastKDF())
        legacy.formatVersion = 1
        try legacy.write(at: StoreKeyEnvelope.legacyURL(besideStore: storeURL))
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.lastPathComponent == StoreKeyEnvelope.filename,
                "the legacy file is read for the current key when no fingerprint file exists")

        let key = StoreKey.mint()
        var current = StoreKeyEnvelope(storeID: legacy.storeID)
        try current.setPassphraseWrap(key: key, passphrase: "pp", kdf: fastKDF())
        try current.write(at: current.preferredURL(besideStore: storeURL))
        let located = StoreKeyEnvelope.locate(besideStore: storeURL)
        #expect(located?.lastPathComponent == StoreKeyEnvelope.filename(forFingerprint: StoreKeyEnvelope.fingerprint(of: key)),
                "a fingerprint file beside the store wins over the legacy one")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL) == current)
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: storeURL).count == 2)
    }

    /// Several fingerprint files (a re-key's state) resolve to the most
    /// recently modified one — the recorded 1a interim.
    @Test func severalFingerprintFilesResolveToTheNewest() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let older = StoreKey.mint(), newer = StoreKey.mint()
        var a = StoreKeyEnvelope(); try a.setPassphraseWrap(key: older, passphrase: "pp", kdf: fastKDF())
        var b = StoreKeyEnvelope(storeID: a.storeID); try b.setPassphraseWrap(key: newer, passphrase: "pp", kdf: fastKDF())
        let aURL = a.preferredURL(besideStore: storeURL), bURL = b.preferredURL(besideStore: storeURL)
        try a.write(at: aURL)
        try b.write(at: bURL)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1_000)], ofItemAtPath: aURL.path)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 2_000)], ofItemAtPath: bURL.path)
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.lastPathComponent == bURL.lastPathComponent)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 3_000)], ofItemAtPath: aURL.path)
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.lastPathComponent == aURL.lastPathComponent)
    }
}
