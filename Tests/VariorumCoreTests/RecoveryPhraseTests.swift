import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 1 — `RecoveryPhrase` (BIP-39, 12-word, R-5).
///
/// Vector provenance: the canonical BIP-39 English test vectors referenced
/// by BIP-0039 (the Trezor `python-mnemonic` `vectors.json`; seed
/// derivation passphrase "TREZOR") — all eight 128-bit/12-word vectors,
/// fetched verbatim 2026-08-04. The wordlist integrity pin is the
/// canonical SHA-256 of `bip-0039/english.txt`, independently recomputed
/// at vendoring (see `Vendor/BIP39/README.md`).
@Suite("RecoveryPhrase (Phase 14b, batch 1)")
struct RecoveryPhraseTests {
    private func hex(_ data: Data) -> String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    private func data(fromHex hexString: String) -> Data {
        var bytes = [UInt8]()
        var index = hexString.startIndex
        while index < hexString.endIndex {
            let next = hexString.index(index, offsetBy: 2)
            bytes.append(UInt8(hexString[index..<next], radix: 16)!)
            index = next
        }
        return Data(bytes)
    }

    /// All eight 128-bit (12-word) vectors: (entropy, mnemonic, seed with
    /// passphrase "TREZOR").
    private static let specVectors: [(String, String, String)] = [
        ("00000000000000000000000000000000",
         "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
         "c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e53495531f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04"),
        ("7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
         "legal winner thank year wave sausage worth useful legal winner thank yellow",
         "2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607"),
        ("80808080808080808080808080808080",
         "letter advice cage absurd amount doctor acoustic avoid letter advice cage above",
         "d71de856f81a8acc65e6fc851a38d4d7ec216fd0796d0a6827a3ad6ed5511a30fa280f12eb2e47ed2ac03b5c462a0358d18d69fe4f985ec81778c1b370b652a8"),
        ("ffffffffffffffffffffffffffffffff",
         "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong",
         "ac27495480225222079d7be181583751e86f571027b0497b5b5d11218e0a8a13332572917f0f8e5a589620c6f15b11c61dee327651a14c34e18231052e48c069"),
        ("9e885d952ad362caeb4efe34a8e91bd2",
         "ozone drill grab fiber curtain grace pudding thank cruise elder eight picnic",
         "274ddc525802f7c828d8ef7ddbcdc5304e87ac3535913611fbbfa986d0c9e5476c91689f9c8a54fd55bd38606aa6a8595ad213d4c9c9f9aca3fb217069a41028"),
        ("c0ba5a8e914111210f2bd131f3d5e08d",
         "scheme spot photo card baby mountain device kick cradle pact join borrow",
         "ea725895aaae8d4c1cf682c1bfd2d358d52ed9f0f0591131b559e2724bb234fca05aa9c02c57407e04ee9dc3b454aa63fbff483a8b11de949624b9f1831a9612"),
        ("23db8160a31d3e0dca3688ed941adbf3",
         "cat swing flag economy stadium alone churn speed unique patch report train",
         "deb5f45449e615feff5640f2e49f933ff51895de3b4381832b3139941c57b59205a42480c52175b6efcffaa58a2503887c1e8b363a707256bdd2b587b46541f5"),
        ("f30f8c1da665478f49b001d94c5fc452",
         "vessel ladder alter error federal sibling chat ability sun glass valve picture",
         "2aaa9242daafcee6aa9d7269f17d4efe271e1b9a529178d7dc139cd18747090bf9d60295d0ce74309a78852a9caadf0af48aae1c6253839624076224374bc63f"),
    ]

    // MARK: - Wordlist integrity

    @Test func wordlistIntegrity() throws {
        let words = try RecoveryPhrase.wordlist()
        #expect(words.count == 2048)
        #expect(words.first == "abandon")
        #expect(words.last == "zoo")
        #expect(words == words.sorted())
        #expect(Set(words).count == 2048)
        #expect(words.allSatisfy { $0.allSatisfy { $0.isLowercase && $0.isASCII } })
        // The canonical SHA-256 of bip-0039/english.txt — the exact bytes
        // as vendored (LF line endings, trailing newline).
        let joined = words.joined(separator: "\n") + "\n"
        let digest = SHA256.hash(data: Data(joined.utf8))
        #expect(
            hex(Data(digest))
                == "2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda")
    }

    // MARK: - Spec vectors

    @Test(arguments: 0..<8)
    func entropyToMnemonic(_ index: Int) throws {
        let (entropyHex, mnemonic, _) = Self.specVectors[index]
        let words = try RecoveryPhrase.mnemonic(fromEntropy: data(fromHex: entropyHex))
        #expect(words.joined(separator: " ") == mnemonic)
    }

    @Test(arguments: 0..<8)
    func mnemonicValidatesBackToEntropy(_ index: Int) throws {
        let (entropyHex, mnemonic, _) = Self.specVectors[index]
        let entropy = try RecoveryPhrase.validate(mnemonic.split(separator: " ").map(String.init))
        #expect(hex(entropy) == entropyHex)
    }

    @Test(arguments: 0..<8)
    func mnemonicToSeed(_ index: Int) throws {
        let (_, mnemonic, seedHex) = Self.specVectors[index]
        let seed = try RecoveryPhrase.seed(
            words: mnemonic.split(separator: " ").map(String.init),
            passphrase: "TREZOR")
        #expect(hex(seed) == seedHex)
    }

    /// The product path uses the EMPTY passphrase; pin one empty-passphrase
    /// seed (this value is also the well-known BIP-32 reference seed for
    /// this mnemonic — independent cross-check of the PBKDF2 path).
    @Test func emptyPassphraseSeedPin() throws {
        let words = Self.specVectors[0].1.split(separator: " ").map(String.init)
        let seed = try RecoveryPhrase.seed(words: words)
        #expect(
            hex(seed)
                == "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4")
    }

    // MARK: - The recovery wrap key (our HKDF stage — drift pin)

    /// Generated by this implementation once and pinned: phrase → seed →
    /// HKDF-SHA256 → 256-bit wrap key. A silent change to the HKDF salt/
    /// info constants or the seed path would orphan every recovery wrap.
    @Test func recoveryWrapKeyPin() throws {
        let words = Self.specVectors[0].1.split(separator: " ").map(String.init)
        let key = try RecoveryPhrase.recoveryWrapKey(words: words)
        let keyData = key.withUnsafeBytes { Data($0) }
        #expect(keyData.count == 32)
        #expect(
            hex(keyData)
                == "9ad4834b34187029210cb59b51ee7cc8dbd38cef8358f5540f95e88733fa6a57")
    }

    // MARK: - Generate

    @Test func generateMintsValidTwelveWordPhrases() throws {
        let a = try RecoveryPhrase.generate()
        let b = try RecoveryPhrase.generate()
        #expect(a.count == 12)
        #expect(b.count == 12)
        #expect(a != b)  // 128-bit entropy: a collision is a broken CSPRNG
        // Round-trip: generated phrases validate and re-encode to themselves.
        let entropy = try RecoveryPhrase.validate(a)
        #expect(try RecoveryPhrase.mnemonic(fromEntropy: entropy) == a)
    }

    // MARK: - Typed refusals

    @Test func wrongWordCountRefuses() {
        #expect(throws: RecoveryPhraseError.invalidWordCount(11)) {
            try RecoveryPhrase.validate(Array(repeating: "abandon", count: 11))
        }
        // 24-word phrases are real BIP-39 but not OUR format (R-5 fixed 12).
        #expect(throws: RecoveryPhraseError.invalidWordCount(24)) {
            try RecoveryPhrase.validate(Array(repeating: "abandon", count: 24))
        }
        #expect(throws: RecoveryPhraseError.invalidWordCount(0)) {
            try RecoveryPhrase.validate([])
        }
    }

    @Test func unknownWordRefusesAndNamesTheOffender() {
        var words = Self.specVectors[0].1.split(separator: " ").map(String.init)
        words[4] = "variorum"  // not a BIP-39 word
        #expect(throws: RecoveryPhraseError.unknownWord("variorum")) {
            try RecoveryPhrase.validate(words)
        }
    }

    @Test func checksumMismatchSpeaks() {
        // Valid words, wrong final word: "about" → "abandon" breaks the
        // checksum (a classic last-word typo).
        let words = Array(repeating: "abandon", count: 12)
        #expect(throws: RecoveryPhraseError.checksumMismatch) {
            try RecoveryPhrase.validate(words)
        }
        // Two swapped words: every word valid, checksum catches the order.
        var swapped = Self.specVectors[4].1.split(separator: " ").map(String.init)
        swapped.swapAt(0, 1)
        #expect(throws: RecoveryPhraseError.checksumMismatch) {
            try RecoveryPhrase.validate(swapped)
        }
    }

    @Test func derivationRefusesInvalidPhrases() {
        // The derive doors are guarded by the same validation.
        #expect(throws: RecoveryPhraseError.checksumMismatch) {
            _ = try RecoveryPhrase.recoveryWrapKey(
                words: Array(repeating: "abandon", count: 12))
        }
        #expect(throws: RecoveryPhraseError.invalidWordCount(3)) {
            _ = try RecoveryPhrase.seed(words: ["abandon", "abandon", "about"])
        }
    }

    @Test func invalidEntropyLengthRefuses() {
        #expect(throws: RecoveryPhraseError.invalidEntropyLength(15)) {
            _ = try RecoveryPhrase.mnemonic(fromEntropy: Data(repeating: 0, count: 15))
        }
        #expect(throws: RecoveryPhraseError.invalidEntropyLength(32)) {
            // 256-bit entropy is real BIP-39 (24 words) but not OUR format.
            _ = try RecoveryPhrase.mnemonic(fromEntropy: Data(repeating: 0, count: 32))
        }
    }

    // MARK: - Forgiving input

    @Test func validationForgivesCaseAndWhitespace() throws {
        let (entropyHex, mnemonic, _) = Self.specVectors[0]
        let messy = mnemonic.split(separator: " ").enumerated().map { index, word in
            index.isMultiple(of: 2) ? "  \(word.uppercased())  " : String(word)
        }
        let entropy = try RecoveryPhrase.validate(messy)
        #expect(hex(entropy) == entropyHex)
    }
}
