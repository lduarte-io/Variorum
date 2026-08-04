import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 1 — `KeyVaultFormat`: full wrap→unwrap round-trips and
/// EVERY tamper/mismatch arm, plus the Round-5 wrap-addition door.
@Suite("KeyVaultFormat (Phase 14b, batch 1)")
struct KeyVaultFormatTests {
    // Fixed keys so failures are reproducible; wrap outputs are still
    // deterministic under RFC 3394 (no nonce), which is fine for wraps.
    private let master = SymmetricKey(data: Data(repeating: 0x11, count: 32))
    private let passphraseKey = SymmetricKey(data: Data(repeating: 0x22, count: 32))
    private let recoveryKey = SymmetricKey(data: Data(repeating: 0x33, count: 32))
    private let corpusKey = SymmetricKey(data: Data(repeating: 0x44, count: 32))
    private let bridgeKey = SymmetricKey(data: Data(repeating: 0x55, count: 32))
    private let wrongKey = SymmetricKey(data: Data(repeating: 0x66, count: 32))

    private func keyHex(_ key: SymmetricKey) -> String {
        key.withUnsafeBytes { Data($0) }.map { String(format: "%02x", $0) }.joined()
    }

    private func makeVault(recoveryKey: SymmetricKey?) throws -> KeyVaultFormat {
        try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: recoveryKey,
            classKeys: [
                (.corpus, "11111111-1111-1111-1111-111111111111", corpusKey),
                (.journalBridge, "22222222-2222-2222-2222-222222222222", bridgeKey),
            ],
            kdf: .v1(salt: Data(repeating: 0x0B, count: 16)))
    }

    // MARK: - Round-trips

    @Test func fullWrapUnwrapRoundTrip() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        #expect(vault.formatVersion == 1)
        #expect(vault.masterWrappedByRecovery != nil)

        // Passphrase road.
        let viaPassphrase = try vault.unwrapMaster(withPassphraseKey: passphraseKey)
        #expect(keyHex(viaPassphrase) == keyHex(master))

        // Recovery road.
        let viaRecovery = try vault.unwrapMaster(withRecoveryKey: recoveryKey)
        #expect(keyHex(viaRecovery) == keyHex(master))

        // Class keys under the unwrapped master.
        let corpus = try vault.unwrapClassKey(.corpus, masterKey: viaPassphrase)
        #expect(keyHex(corpus) == keyHex(corpusKey))
        let bridge = try vault.unwrapClassKey(.journalBridge, masterKey: viaRecovery)
        #expect(keyHex(bridge) == keyHex(bridgeKey))

        // Key ids are carried plaintext for the AAD convention.
        #expect(vault.classKey(for: .corpus)?.keyID == "11111111-1111-1111-1111-111111111111")
        #expect(
            vault.classKey(for: .journalBridge)?.keyID
                == "22222222-2222-2222-2222-222222222222")
    }

    @Test func serializationRoundTrip() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        let encoded = try vault.encoded()
        let decoded = try KeyVaultFormat(decoding: encoded)
        #expect(decoded == vault)
        // Encoding is stable (sorted keys): re-encoding is byte-identical.
        #expect(try decoded.encoded() == encoded)
        // And the decoded vault still unwraps.
        let unwrapped = try decoded.unwrapMaster(withPassphraseKey: passphraseKey)
        #expect(keyHex(unwrapped) == keyHex(master))
    }

    @Test func endToEndWithRealDerivedKeys() throws {
        // The composed story: passphrase-KDF key + recovery-phrase key,
        // both real derivations, wrapping one master.
        let salt = Data(repeating: 0x0C, count: 16)
        let descriptor = PassphraseKDF.Descriptor(
            algorithm: "argon2id", argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: salt, outputBytes: 32)
        let kdfKey = try PassphraseKDF.deriveKey(
            passphrase: "her separate encryption passphrase", descriptor: descriptor)
        let phrase = try RecoveryPhrase.generate()
        let phraseKey = try RecoveryPhrase.recoveryWrapKey(words: phrase)

        let vault = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: kdfKey, recoveryKey: phraseKey,
            classKeys: [(.corpus, "id-corpus", corpusKey)], kdf: descriptor)

        // Both roads reach the same master; the vault's own descriptor is
        // what a fresh device re-derives from.
        let rederived = try PassphraseKDF.deriveKey(
            passphrase: "her separate encryption passphrase", descriptor: vault.kdf)
        #expect(keyHex(try vault.unwrapMaster(withPassphraseKey: rederived)) == keyHex(master))
        #expect(keyHex(try vault.unwrapMaster(withRecoveryKey: phraseKey)) == keyHex(master))

        // A wrong passphrase derives a key that REFUSES — never garbage.
        let wrong = try PassphraseKDF.deriveKey(
            passphrase: "her separate encryption passphrase!", descriptor: vault.kdf)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withPassphraseKey: wrong)
        }
    }

    // MARK: - Wrap-addition (Round 5)

    @Test func vaultBornWithoutRecoveryWrapGainsOneLater() throws {
        let overnight = try makeVault(recoveryKey: nil)
        #expect(overnight.masterWrappedByRecovery == nil)

        // The recovery road refuses loudly while absent.
        #expect(throws: KeyVaultError.recoveryWrapAbsent) {
            _ = try overnight.unwrapMaster(withRecoveryKey: recoveryKey)
        }
        // The passphrase road works meanwhile (the overnight state is live).
        #expect(
            keyHex(try overnight.unwrapMaster(withPassphraseKey: passphraseKey))
                == keyHex(master))

        // The morning act: add the recovery wrap.
        let complete = try overnight.addingRecoveryWrap(
            masterKey: master, recoveryKey: recoveryKey)
        #expect(keyHex(try complete.unwrapMaster(withRecoveryKey: recoveryKey)) == keyHex(master))
        // Untouched fields ride along.
        #expect(complete.masterWrappedByPassphrase == overnight.masterWrappedByPassphrase)
        #expect(complete.classKeys == overnight.classKeys)
    }

    @Test func wrapAdditionRefusesWhenAlreadyPresent() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        #expect(throws: KeyVaultError.recoveryWrapAlreadyPresent) {
            _ = try vault.addingRecoveryWrap(masterKey: master, recoveryKey: wrongKey)
        }
    }

    @Test func wrapAdditionRefusesAWrongMaster() throws {
        // The guard that matters most: a WRONG master can never become the
        // phrase's target (a silently unusable disaster road).
        let overnight = try makeVault(recoveryKey: nil)
        #expect(throws: KeyVaultError.masterKeyMismatch) {
            _ = try overnight.addingRecoveryWrap(masterKey: wrongKey, recoveryKey: recoveryKey)
        }
    }

    // MARK: - Tamper / mismatch arms

    @Test func wrongPassphraseKeyRefuses() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withPassphraseKey: wrongKey)
        }
    }

    @Test func wrongRecoveryKeyRefuses() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withRecoveryKey: wrongKey)
        }
    }

    @Test func wrongMasterRefusesClassKeys() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapClassKey(.corpus, masterKey: wrongKey)
        }
    }

    @Test func flippedBytesRefuseEverywhere() throws {
        let vault = try makeVault(recoveryKey: recoveryKey)

        var tampered = vault
        tampered.masterWrappedByPassphrase[3] ^= 0x01
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try tampered.unwrapMaster(withPassphraseKey: passphraseKey)
        }

        tampered = vault
        tampered.masterWrappedByRecovery![5] ^= 0x80
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try tampered.unwrapMaster(withRecoveryKey: recoveryKey)
        }

        tampered = vault
        tampered.classKeys[0].wrappedByMaster[0] ^= 0xFF
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try tampered.unwrapClassKey(.corpus, masterKey: master)
        }
        // The untampered sibling class key still unwraps — damage is scoped.
        #expect(throws: Never.self) {
            _ = try tampered.unwrapClassKey(.journalBridge, masterKey: master)
        }
    }

    @Test func truncatedWrapRefuses() throws {
        var vault = try makeVault(recoveryKey: recoveryKey)
        vault.masterWrappedByPassphrase = vault.masterWrappedByPassphrase.dropLast(8)
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withPassphraseKey: passphraseKey)
        }
        vault.masterWrappedByPassphrase = Data()
        #expect(throws: KeyVaultError.unwrapFailed) {
            _ = try vault.unwrapMaster(withPassphraseKey: passphraseKey)
        }
    }

    @Test func wrongFormatVersionRefusesEveryOperation() throws {
        var vault = try makeVault(recoveryKey: nil)
        vault.formatVersion = 2  // a future format
        #expect(throws: KeyVaultError.unsupportedFormatVersion(2)) {
            _ = try vault.unwrapMaster(withPassphraseKey: passphraseKey)
        }
        #expect(throws: KeyVaultError.unsupportedFormatVersion(2)) {
            _ = try vault.unwrapMaster(withRecoveryKey: recoveryKey)
        }
        #expect(throws: KeyVaultError.unsupportedFormatVersion(2)) {
            _ = try vault.unwrapClassKey(.corpus, masterKey: master)
        }
        #expect(throws: KeyVaultError.unsupportedFormatVersion(2)) {
            _ = try vault.addingRecoveryWrap(masterKey: master, recoveryKey: recoveryKey)
        }
    }

    @Test func unknownClassKeyRefuses() throws {
        let vault = try KeyVaultFormat.create(
            masterKey: master, passphraseKey: passphraseKey, recoveryKey: recoveryKey,
            classKeys: [(.corpus, "id-corpus", corpusKey)],
            kdf: .v1(salt: Data(repeating: 0x0B, count: 16)))
        #expect(vault.classKey(for: .journalBridge) == nil)
        #expect(throws: KeyVaultError.unknownClassKey(.journalBridge)) {
            _ = try vault.unwrapClassKey(.journalBridge, masterKey: master)
        }
    }

    @Test func createRefusesEmptyAndDuplicateClassKeys() {
        #expect(throws: KeyVaultError.noClassKeys) {
            _ = try KeyVaultFormat.create(
                masterKey: master, passphraseKey: passphraseKey, recoveryKey: nil,
                classKeys: [], kdf: .v1(salt: Data(repeating: 0x0B, count: 16)))
        }
        #expect(throws: KeyVaultError.duplicateClassKey) {
            _ = try KeyVaultFormat.create(
                masterKey: master, passphraseKey: passphraseKey, recoveryKey: nil,
                classKeys: [(.corpus, "a", corpusKey), (.corpus, "b", bridgeKey)],
                kdf: .v1(salt: Data(repeating: 0x0B, count: 16)))
        }
    }

    @Test func malformedPayloadRefuses() {
        #expect(throws: KeyVaultError.malformedPayload) {
            _ = try KeyVaultFormat(decoding: Data("not a vault".utf8))
        }
        #expect(throws: KeyVaultError.malformedPayload) {
            _ = try KeyVaultFormat(decoding: Data("{\"formatVersion\":1}".utf8))
        }
        #expect(throws: KeyVaultError.malformedPayload) {
            _ = try KeyVaultFormat(decoding: Data())
        }
    }
}
