//
//  ProtectionFixtures.swift
//  VariorumCoreTests — VX-305: the protection suites' shared fixtures.
//
//  Test-speed KDF parameters (the suites' existing `fastKDF` shape: 256 KiB,
//  one pass) and the RELAXED floor passed explicitly on every passphrase road —
//  explicitly, because under `swift test -c release` `PassphraseKDF.floor` is
//  the production floor (the test-host relaxation is `#if DEBUG`), and the
//  core is tested in both configurations from this phase on.
//

import CryptoKit
import Foundation

@testable import VariorumCore

enum PF {
    static let floor = PassphraseKDF.Floor.relaxedForTests

    static func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    static func passphraseKey(_ passphrase: String) throws -> PassphraseKey {
        try PassphraseKey.derive(passphrase, kdf: fastKDF())
    }

    static func words() throws -> [String] { try RecoveryPhrase.generate() }

    static func wordsKey(_ words: [String]) throws -> WordsKey { try WordsKey.derive(words) }

    static func id() -> String { UUID().uuidString.lowercased() }

    static let t0 = Date(timeIntervalSinceReferenceDate: 781_000_000.25)
    static func day(_ n: Double) -> Date { t0.addingTimeInterval(n * 86_400) }

    static func fp(_ key: StoreKey) -> String { KeyFingerprint.of(key) }

    /// The names an OLDER Variorum gave its key files — fixtures for rule 26's foreign files (VX-329 U1: today's
    /// envelope, which owned these names, was deleted with today's road; the bytes of the names are unchanged).
    static func olderKeyFilename(_ fingerprint: String) -> String { "variorum-keys-\(fingerprint).json" }
    static let olderLegacyKeyFilename = "variorum-keys.json"

    /// A reach over a set of keys, by fingerprint.
    static func reach(_ keys: [StoreKey]) -> (String) -> StoreKey? {
        let byFingerprint = Dictionary(uniqueKeysWithValues: keys.map { (fp($0), $0) })
        return { byFingerprint[$0] }
    }

    static func bytes(_ key: SymmetricKey) -> Data { key.withUnsafeBytes { Data($0) } }
}

/// The scan the secret tests run: does `haystack` carry `needle` as raw bytes,
/// as base64, or as lowercase or uppercase hex?
enum SecretScan {
    static func carries(_ haystack: Data, _ needle: Data) -> Bool {
        guard !needle.isEmpty else { return false }
        if haystack.range(of: needle) != nil { return true }
        let text = String(decoding: haystack, as: UTF8.self)
        let hex = needle.map { String(format: "%02x", $0) }.joined()
        return text.contains(needle.base64EncodedString())
            || text.contains(hex) || text.contains(hex.uppercased())
    }

    static func carries(_ haystack: Data, text needle: String) -> Bool {
        let utf8 = Data(needle.utf8)
        return carries(haystack, utf8) || String(decoding: haystack, as: UTF8.self).contains(needle)
    }
}
