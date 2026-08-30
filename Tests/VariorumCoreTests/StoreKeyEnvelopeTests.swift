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

import Foundation
import Testing

@testable import VariorumCore

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
        // the typo class, never a generic "wrong phrase".
        words[0] = words[0] == "abandon" ? "ability" : "abandon"
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
        #expect(throws: StoreKeyEnvelopeError.newerFormat(2)) {
            try envelope.setPassphraseWrap(key: key, passphrase: "x", kdf: fastKDF())
        }
        #expect(throws: StoreKeyEnvelopeError.newerFormat(2)) {
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
        let url = StoreKeyEnvelope.url(besideStore: storeURL)
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
