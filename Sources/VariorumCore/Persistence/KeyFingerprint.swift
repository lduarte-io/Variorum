import CryptoKit
import Foundation

// VX-329 U1 — THE KEY FINGERPRINT, relocated byte-for-byte from today's envelope (`StoreKeyEnvelope.fingerprint(of:)`
// and `shortFingerprint(_:)`, deleted with today's road at the release switch). The new protection core names every
// key file, custody item, seal and backup pair by it, so the algorithm is unchanged to the bit: the first eight bytes
// of SHA-256 over the key, as sixteen lowercase hex characters; the short form is its first eight characters. Public
// and non-secret: it reveals nothing about a random 256-bit key.

public enum KeyFingerprint {
    /// Sixteen lowercase hex characters — the first eight bytes of SHA-256 over the key.
    public static func of(_ key: StoreKey) -> String {
        Data(SHA256.hash(data: key.data)).prefix(8)
            .map { String(format: "%02x", $0) }.joined()
    }

    /// The first eight characters of a fingerprint (what a backup's name and a log line carry).
    public static func short(_ fingerprint: String) -> String {
        String(fingerprint.prefix(8))
    }
}
