import CryptoKit
import Foundation

/// The value cipher for synced text (Phase 14b, THE DESIGN's "ciphertext
/// format" — this doc comment is the format's record):
///
/// - **AEAD:** AES-256-GCM via CryptoKit (hardware-accelerated), per-value
///   random 96-bit nonce (CryptoKit-generated).
/// - **AAD binding:** `table:rowID:column:keyID` (UTF-8) — a ciphertext
///   cannot be swapped between rows/columns, or silently re-attributed to
///   a different key, without the open refusing — even though ids stay
///   plaintext on the mirror.
/// - **Encoding:** `e1:` + base64(nonce ‖ ciphertext ‖ tag) — a
///   version-prefixed string carried in the EXISTING TEXT columns; no
///   mirror column-type changes. The prefix is the seam's and the
///   mirror-dump assertion's marker (`isEncrypted`).
/// - **Key granularity (batch-1's recorded call, per THE DESIGN):** the
///   per-class key is used DIRECTLY — no HKDF per-table subkeys in v1.
///   NIST SP 800-38D's random-nonce bound (2^32 encryptions per key) sits
///   orders of magnitude above personal-corpus write volume, subkeys would
///   spread key-custody logic across the seam and Keychain story for
///   marginal benefit, and the `e1:` version prefix plus the vault's
///   `format_version` leave an `e2:` subkey format addable later with zero
///   ambiguity.
///
/// Refusals are typed and total: wrong key, wrong AAD, a mangled prefix,
/// truncated or garbage bodies all SPEAK — nothing here ever crashes on
/// hostile input, and `open` never returns bytes that failed
/// authentication.
public enum PayloadCipher {
    /// The one supported encoding version prefix.
    public static let encodingPrefix = "e1:"

    /// What a ciphertext is bound to (the AAD). `table`/`column` are SQL
    /// identifiers and `rowID`/`keyID` are UUID strings, so the `:` joiner
    /// is unambiguous.
    public struct Binding: Equatable, Sendable {
        public var table: String
        public var rowID: String
        public var column: String
        public var keyID: String

        public init(table: String, rowID: String, column: String, keyID: String) {
            self.table = table
            self.rowID = rowID
            self.column = column
            self.keyID = keyID
        }

        var aad: Data {
            Data("\(table):\(rowID):\(column):\(keyID)".utf8)
        }
    }

    /// True when a stored value carries this format's prefix — the seam's
    /// and the mirror-dump assertion's marker.
    public static func isEncrypted(_ value: String) -> Bool {
        value.hasPrefix(encodingPrefix)
    }

    // MARK: - Seal / open

    /// Encrypt one value. The empty string seals fine (GCM handles empty
    /// plaintext; the tag still authenticates the binding).
    public static func seal(
        _ plaintext: String, key: SymmetricKey, binding: Binding
    ) throws -> String {
        do {
            let sealed = try AES.GCM.seal(
                Data(plaintext.utf8), using: key, authenticating: binding.aad)
            guard let combined = sealed.combined else {
                // Unreachable with a CryptoKit-generated 12-byte nonce;
                // typed anyway — never a crash.
                throw PayloadCipherError.sealFailed
            }
            return encodingPrefix + combined.base64EncodedString()
        } catch let error as PayloadCipherError {
            throw error
        } catch {
            throw PayloadCipherError.sealFailed
        }
    }

    /// Decrypt one value. Every refusal arm is typed:
    /// - no/foreign prefix → `notEncrypted` (the caller decides whether a
    ///   plaintext passthrough is legal at its seam — this type never
    ///   guesses),
    /// - an `e<n>:` prefix this build doesn't speak → `unsupportedVersion`,
    /// - non-base64 body → `malformedEncoding`,
    /// - a body too short to hold nonce+tag → `malformedCiphertext`,
    /// - wrong key / wrong AAD / flipped or truncated bytes →
    ///   `authenticationFailed` (indistinguishable by design; nothing is
    ///   returned on this arm).
    public static func open(
        _ encoded: String, key: SymmetricKey, binding: Binding
    ) throws -> String {
        guard encoded.hasPrefix(encodingPrefix) else {
            if let foreign = foreignVersionPrefix(of: encoded) {
                throw PayloadCipherError.unsupportedVersion(foreign)
            }
            throw PayloadCipherError.notEncrypted
        }
        let body = String(encoded.dropFirst(encodingPrefix.count))
        guard let combined = Data(base64Encoded: body) else {
            throw PayloadCipherError.malformedEncoding
        }
        // 12-byte nonce + 16-byte tag is the floor for a combined box.
        guard combined.count >= 28 else {
            throw PayloadCipherError.malformedCiphertext
        }
        let opened: Data
        do {
            let box = try AES.GCM.SealedBox(combined: combined)
            opened = try AES.GCM.open(box, using: key, authenticating: binding.aad)
        } catch {
            throw PayloadCipherError.authenticationFailed
        }
        guard let plaintext = String(data: opened, encoding: .utf8) else {
            // Cannot arise from our own seal (which only seals UTF-8);
            // defensive against a foreign writer — typed, never a crash.
            throw PayloadCipherError.invalidPlaintext
        }
        return plaintext
    }

    // MARK: - Helpers

    /// Matches `e<digits>:` prefixes other than ours, so a future format's
    /// value refuses as "unsupported version" rather than "not encrypted".
    private static func foreignVersionPrefix(of value: String) -> String? {
        guard value.first == "e" else { return nil }
        let digits = value.dropFirst().prefix(while: \.isNumber)
        guard !digits.isEmpty,
            value.dropFirst(1 + digits.count).first == ":"
        else { return nil }
        return "e\(digits):"
    }
}

/// Typed refusals for the value cipher — see `PayloadCipher.open`.
public enum PayloadCipherError: Error, Equatable, Sendable {
    case notEncrypted
    case unsupportedVersion(String)
    case malformedEncoding
    case malformedCiphertext
    case authenticationFailed
    case invalidPlaintext
    case sealFailed
}
