//
//  VaultRewrapFormatTests.swift
//  VariorumCoreTests
//
//  Phase 13p — the vault's held-master passphrase re-wrap (R13p-9's vault half). VX-329 U1: moved byte-for-byte out of
//  `StoreKeyEnvelopeTests.swift` when today's envelope and its suites were deleted — this suite's subject
//  (`KeyVaultFormat.rewrappingPassphrase`) survives.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

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
