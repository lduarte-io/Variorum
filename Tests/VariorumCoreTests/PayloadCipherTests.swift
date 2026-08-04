import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 1 — `PayloadCipher`: seal/open round-trips (empty,
/// multi-MB, unicode) and EVERY refusal arm (wrong key, wrong AAD
/// component by component, mangled prefix, truncated body, garbage).
@Suite("PayloadCipher (Phase 14b, batch 1)")
struct PayloadCipherTests {
    private let key = SymmetricKey(data: Data(repeating: 0x77, count: 32))
    private let otherKey = SymmetricKey(data: Data(repeating: 0x88, count: 32))
    private let binding = PayloadCipher.Binding(
        table: "variant",
        rowID: "aaaaaaaa-0000-0000-0000-000000000001",
        column: "working_text",
        keyID: "11111111-1111-1111-1111-111111111111")

    // MARK: - Round-trips

    @Test func sealOpenRoundTrip() throws {
        let plaintext = "The block is the atomic unit."
        let sealed = try PayloadCipher.seal(plaintext, key: key, binding: binding)
        #expect(sealed.hasPrefix("e1:"))
        #expect(PayloadCipher.isEncrypted(sealed))
        #expect(!PayloadCipher.isEncrypted(plaintext))
        let opened = try PayloadCipher.open(sealed, key: key, binding: binding)
        #expect(opened == plaintext)
    }

    @Test func emptyStringRoundTrips() throws {
        let sealed = try PayloadCipher.seal("", key: key, binding: binding)
        #expect(sealed.hasPrefix("e1:"))
        // Even an empty plaintext authenticates its binding.
        #expect(try PayloadCipher.open(sealed, key: key, binding: binding) == "")
        var wrong = binding
        wrong.column = "label"
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: key, binding: wrong)
        }
    }

    @Test func multiMegabyteTextRoundTrips() throws {
        // ~3 MB of prose-shaped text (the 100k-word-post class and beyond).
        let paragraph = "She rewrote the paragraph eleven times, and kept every one. "
        let plaintext = String(repeating: paragraph, count: 55_000)
        #expect(plaintext.utf8.count > 3_000_000)
        let sealed = try PayloadCipher.seal(plaintext, key: key, binding: binding)
        let opened = try PayloadCipher.open(sealed, key: key, binding: binding)
        #expect(opened == plaintext)
    }

    @Test func unicodeRoundTrips() throws {
        let plaintext = "варіант · 変奏 · e\u{301}tude — 🌒📓 \u{200D} \n\nnewlines are content\n"
        let sealed = try PayloadCipher.seal(plaintext, key: key, binding: binding)
        let opened = try PayloadCipher.open(sealed, key: key, binding: binding)
        #expect(opened == plaintext)  // byte-exact, composition untouched
    }

    @Test func noncesAreFreshPerSeal() throws {
        let sealed1 = try PayloadCipher.seal("same text", key: key, binding: binding)
        let sealed2 = try PayloadCipher.seal("same text", key: key, binding: binding)
        #expect(sealed1 != sealed2)  // per-value random nonce
        #expect(try PayloadCipher.open(sealed1, key: key, binding: binding) == "same text")
        #expect(try PayloadCipher.open(sealed2, key: key, binding: binding) == "same text")
    }

    // MARK: - Refusals: wrong key

    @Test func wrongKeyRefuses() throws {
        let sealed = try PayloadCipher.seal("secret", key: key, binding: binding)
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: otherKey, binding: binding)
        }
    }

    // MARK: - Refusals: wrong AAD, component by component

    @Test func eachWrongBindingComponentRefuses() throws {
        let sealed = try PayloadCipher.seal("bound text", key: key, binding: binding)

        var wrongTable = binding
        wrongTable.table = "commit_point"
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: key, binding: wrongTable)
        }

        var wrongRow = binding
        wrongRow.rowID = "aaaaaaaa-0000-0000-0000-000000000002"
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: key, binding: wrongRow)
        }

        var wrongColumn = binding
        wrongColumn.column = "label"
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: key, binding: wrongColumn)
        }

        var wrongKeyID = binding
        wrongKeyID.keyID = "22222222-2222-2222-2222-222222222222"
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealed, key: key, binding: wrongKeyID)
        }

        // The true binding still opens (the refusals above were the AAD).
        #expect(try PayloadCipher.open(sealed, key: key, binding: binding) == "bound text")
    }

    /// The swap the AAD exists to catch: a ciphertext moved between two
    /// rows of the same table/column refuses on both sides.
    @Test func ciphertextCannotBeSwappedBetweenRows() throws {
        var bindingB = binding
        bindingB.rowID = "bbbbbbbb-0000-0000-0000-000000000002"
        let sealedA = try PayloadCipher.seal("text A", key: key, binding: binding)
        let sealedB = try PayloadCipher.seal("text B", key: key, binding: bindingB)
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealedA, key: key, binding: bindingB)
        }
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(sealedB, key: key, binding: binding)
        }
    }

    // MARK: - Refusals: mangled prefix / encoding

    @Test func plaintextWithoutPrefixRefusesAsNotEncrypted() {
        #expect(throws: PayloadCipherError.notEncrypted) {
            _ = try PayloadCipher.open("just some stored plaintext", key: key, binding: binding)
        }
        #expect(throws: PayloadCipherError.notEncrypted) {
            _ = try PayloadCipher.open("", key: key, binding: binding)
        }
        // "e:" and "east:" are not version prefixes.
        #expect(throws: PayloadCipherError.notEncrypted) {
            _ = try PayloadCipher.open("e:AAAA", key: key, binding: binding)
        }
        #expect(throws: PayloadCipherError.notEncrypted) {
            _ = try PayloadCipher.open("east: of eden", key: key, binding: binding)
        }
    }

    @Test func foreignVersionPrefixRefusesAsUnsupported() throws {
        #expect(throws: PayloadCipherError.unsupportedVersion("e2:")) {
            _ = try PayloadCipher.open("e2:AAAA", key: key, binding: binding)
        }
        #expect(throws: PayloadCipherError.unsupportedVersion("e12:")) {
            _ = try PayloadCipher.open("e12:AAAA", key: key, binding: binding)
        }
        // A REAL e1 body behind a doctored version digit refuses as
        // unsupported — never decrypts under the wrong format label.
        let sealed = try PayloadCipher.seal("x", key: key, binding: binding)
        let doctored = "e2:" + sealed.dropFirst(3)
        #expect(throws: PayloadCipherError.unsupportedVersion("e2:")) {
            _ = try PayloadCipher.open(doctored, key: key, binding: binding)
        }
    }

    @Test func garbageBase64Refuses() {
        #expect(throws: PayloadCipherError.malformedEncoding) {
            _ = try PayloadCipher.open("e1:not-base64!!!", key: key, binding: binding)
        }
        // "e1:" with an EMPTY body: the empty string is valid base64
        // (empty Data), so this arm refuses one step later as a
        // ciphertext too short to hold nonce + tag.
        #expect(throws: PayloadCipherError.malformedCiphertext) {
            _ = try PayloadCipher.open("e1:", key: key, binding: binding)
        }
    }

    @Test func tooShortBodyRefusesAsMalformedCiphertext() {
        // Valid base64, but shorter than nonce (12) + tag (16).
        let short = Data(repeating: 0xAB, count: 20).base64EncodedString()
        #expect(throws: PayloadCipherError.malformedCiphertext) {
            _ = try PayloadCipher.open("e1:" + short, key: key, binding: binding)
        }
    }

    // MARK: - Refusals: truncation / tamper of a real ciphertext

    @Test func truncatedBodyRefuses() throws {
        let sealed = try PayloadCipher.seal("a value long enough to truncate", key: key, binding: binding)
        let combined = Data(base64Encoded: String(sealed.dropFirst(3)))!

        // Truncated but still ≥ the structural floor → authentication fails.
        let truncated = combined.dropLast(4)
        #expect(truncated.count >= 28)
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(
                "e1:" + truncated.base64EncodedString(), key: key, binding: binding)
        }

        // Truncated below the floor → malformed.
        let stub = combined.prefix(10)
        #expect(throws: PayloadCipherError.malformedCiphertext) {
            _ = try PayloadCipher.open(
                "e1:" + stub.base64EncodedString(), key: key, binding: binding)
        }
    }

    @Test func flippedCiphertextByteRefuses() throws {
        let sealed = try PayloadCipher.seal("tamper target", key: key, binding: binding)
        var combined = Data(base64Encoded: String(sealed.dropFirst(3)))!
        combined[combined.count - 1] ^= 0x01  // the tag
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(
                "e1:" + combined.base64EncodedString(), key: key, binding: binding)
        }
        combined[combined.count - 1] ^= 0x01  // restore tag…
        combined[14] ^= 0x40  // …flip a ciphertext byte instead
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(
                "e1:" + combined.base64EncodedString(), key: key, binding: binding)
        }
    }

    @Test func randomGarbageOfValidShapeRefuses() {
        // Well-formed length-wise, cryptographically garbage.
        let garbage = Data((0..<64).map { _ in UInt8.random(in: 0...255) })
        #expect(throws: PayloadCipherError.authenticationFailed) {
            _ = try PayloadCipher.open(
                "e1:" + garbage.base64EncodedString(), key: key, binding: binding)
        }
    }
}
