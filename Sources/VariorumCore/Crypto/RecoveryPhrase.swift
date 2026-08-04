import CommonCrypto
import CryptoKit
import Foundation

/// The 12-word BIP-39 recovery phrase (Phase 14b, ruling R-5 — "12-word
/// BIP-39 (Recommended)"): 128-bit entropy with the built-in SHA-256
/// checksum (typos detected, never silently accepted), the 2048-word
/// English wordlist (bundled resource; provenance pin in
/// `Vendor/BIP39/README.md`).
///
/// The phrase is the DISASTER road: it encodes a high-entropy secret whose
/// derived key wraps the master directly — immune to brute force, which is
/// why no Argon2 stretching rides this path. Derivation is the standard
/// BIP-39 seed derivation (PBKDF2-HMAC-SHA512, 2048 iterations, salt
/// "mnemonic") followed by HKDF-SHA256 down to the 256-bit recovery wrap
/// key. Every constant below is FORMAT: changing any of them silently
/// orphans existing recovery wraps, so the derivation tests pin exact
/// bytes.
public enum RecoveryPhrase {
    /// R-5 fixed the format at exactly 12 words (128-bit entropy); other
    /// BIP-39 lengths are deliberately not accepted — the vault only ever
    /// mints 12-word phrases, so a different count is a typo by definition.
    public static let wordCount = 12
    private static let entropyBytes = 16  // 128 bits
    private static let checksumBits = 4   // ENT/32
    private static let bitsPerWord = 11

    /// HKDF context strings (format constants — see the type comment).
    private static let hkdfSalt = Data("variorum.suite.e2ee.v1".utf8)
    private static let hkdfInfo = Data("recovery-wrap-key".utf8)

    // MARK: - Wordlist

    /// The bundled English wordlist, loaded once. `nil` means the resource
    /// is missing/corrupted — surfaced as a typed error by `wordlist()`.
    private static let loadedWordlist: [String]? = {
        guard let url = Bundle.module.url(forResource: "bip39-english", withExtension: "txt"),
            let raw = try? String(contentsOf: url, encoding: .utf8)
        else { return nil }
        let words = raw.split(separator: "\n").map(String.init)
        guard words.count == 2048 else { return nil }
        return words
    }()

    /// Index by word for O(1) validation lookups.
    private static let wordIndex: [String: Int]? = loadedWordlist.map { list in
        Dictionary(uniqueKeysWithValues: list.enumerated().map { ($1, $0) })
    }

    /// The 2048-word English list (throws if the bundled resource is
    /// unavailable — a build/packaging defect, but it must speak, never
    /// crash).
    public static func wordlist() throws -> [String] {
        guard let list = loadedWordlist else {
            throw RecoveryPhraseError.wordlistUnavailable
        }
        return list
    }

    // MARK: - Generate / encode

    /// Mint a fresh 12-word phrase from 128 bits of CSPRNG entropy.
    /// (Key-material randomness deliberately does not flow through the
    /// seedable `@Dependency` generator; the pure encoding path
    /// `mnemonic(fromEntropy:)` is what the spec vectors test.)
    public static func generate() throws -> [String] {
        let entropy = SymmetricKey(size: .bits128).withUnsafeBytes { Data($0) }
        return try mnemonic(fromEntropy: entropy)
    }

    /// Pure BIP-39 encoding: 16-byte entropy → 12 words. The checksum is
    /// the first 4 bits of SHA-256(entropy), appended to make 132 bits =
    /// 12 × 11-bit wordlist indices.
    public static func mnemonic(fromEntropy entropy: Data) throws -> [String] {
        guard entropy.count == entropyBytes else {
            throw RecoveryPhraseError.invalidEntropyLength(entropy.count)
        }
        let list = try wordlist()
        let checksum = Data(SHA256.hash(data: entropy))
        var bits = bitString(of: entropy)
        bits += bitString(of: checksum.prefix(1)).prefix(checksumBits)
        return stride(from: 0, to: wordCount * bitsPerWord, by: bitsPerWord).map { start in
            let slice = bits[bits.index(bits.startIndex, offsetBy: start)..<bits.index(bits.startIndex, offsetBy: start + bitsPerWord)]
            return list[Int(slice, radix: 2)!]
        }
    }

    // MARK: - Validate / decode

    /// Validate a typed-in phrase and recover its entropy. Refusals are
    /// typed and specific — a checksum failure speaks (R-5's letter),
    /// an unknown word names itself (the UX can point at it).
    /// Input is forgiving: surrounding whitespace trimmed, case folded.
    @discardableResult
    public static func validate(_ words: [String]) throws -> Data {
        guard let index = wordIndex else {
            throw RecoveryPhraseError.wordlistUnavailable
        }
        let normalized = normalize(words)
        guard normalized.count == wordCount else {
            throw RecoveryPhraseError.invalidWordCount(normalized.count)
        }
        var bits = ""
        for word in normalized {
            guard let value = index[word] else {
                throw RecoveryPhraseError.unknownWord(word)
            }
            let binary = String(value, radix: 2)
            bits += String(repeating: "0", count: bitsPerWord - binary.count) + binary
        }
        let entropyBitCount = entropyBytes * 8
        let entropyBits = String(bits.prefix(entropyBitCount))
        let checksumClaim = String(bits.suffix(checksumBits))
        var entropy = Data(capacity: entropyBytes)
        for start in stride(from: 0, to: entropyBitCount, by: 8) {
            let byteSlice = entropyBits[
                entropyBits.index(entropyBits.startIndex, offsetBy: start)..<entropyBits.index(entropyBits.startIndex, offsetBy: start + 8)]
            entropy.append(UInt8(byteSlice, radix: 2)!)
        }
        let checksum = Data(SHA256.hash(data: entropy))
        let expected = String(bitString(of: checksum.prefix(1)).prefix(checksumBits))
        guard checksumClaim == expected else {
            throw RecoveryPhraseError.checksumMismatch
        }
        return entropy
    }

    // MARK: - Derive

    /// The standard BIP-39 seed: PBKDF2-HMAC-SHA512(password: NFKD
    /// mnemonic sentence, salt: "mnemonic" + NFKD passphrase, 2048
    /// iterations, 64 bytes). The `passphrase` parameter exists for the
    /// spec test vectors (passphrase "TREZOR"); the product path always
    /// uses the empty passphrase.
    public static func seed(words: [String], passphrase: String = "") throws -> Data {
        try validate(words)
        let sentence = normalize(words).joined(separator: " ")
            .decomposedStringWithCompatibilityMapping
        let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping
        let password = Data(sentence.utf8)
        let saltData = Data(salt.utf8)
        var output = Data(count: 64)
        let status = output.withUnsafeMutableBytes { outBytes in
            password.withUnsafeBytes { pwdBytes in
                saltData.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        pwdBytes.baseAddress?.assumingMemoryBound(to: CChar.self),
                        password.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        saltData.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                        2048,
                        outBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        64
                    )
                }
            }
        }
        guard status == kCCSuccess else {
            throw RecoveryPhraseError.derivationFailed(Int(status))
        }
        return output
    }

    /// The recovery wrap key: BIP-39 seed → HKDF-SHA256 → 256 bits.
    /// Validates the phrase first, so every refusal arm of `validate`
    /// guards this door too.
    public static func recoveryWrapKey(words: [String]) throws -> SymmetricKey {
        let seed = try seed(words: words)
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: seed),
            salt: hkdfSalt,
            info: hkdfInfo,
            outputByteCount: 32
        )
    }

    // MARK: - Helpers

    private static func normalize(_ words: [String]) -> [String] {
        words
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
    }

    private static func bitString(of data: Data) -> String {
        data.map { byte in
            let binary = String(byte, radix: 2)
            return String(repeating: "0", count: 8 - binary.count) + binary
        }.joined()
    }
}

/// Typed refusals — checksum failures speak (R-5), unknown words name
/// themselves, and a missing wordlist is a loud packaging defect.
public enum RecoveryPhraseError: Error, Equatable, Sendable {
    /// The bundled wordlist resource is missing or malformed.
    case wordlistUnavailable
    /// `mnemonic(fromEntropy:)` was handed entropy of the wrong length.
    case invalidEntropyLength(Int)
    /// Not exactly 12 words after trimming (the count found is carried).
    case invalidWordCount(Int)
    /// A word not in the BIP-39 English list (the offender carried).
    case unknownWord(String)
    /// The phrase's built-in checksum failed — a typo somewhere.
    case checksumMismatch
    /// CommonCrypto PBKDF2 refused (status carried; not expected in practice).
    case derivationFailed(Int)
}
