import CryptoKit
import Foundation

// VX-305 U1 — THE HARDWARE MARKER (design §3.2, §3.6, §3.13; VX-340 option (a),
// confirmed by the author at the VX-305 kickoff): a hash of this Mac's
// hardware identity AND this macOS login's stable identity, with a random salt
// the protection record carries — never either identifier itself — so it
// recomputes on the same hardware and login, a second login on the same Mac
// gets a different marker (and so its own device identity), and a marker that
// leaks alone (say into a log) names no Mac.
//
// WHICH IDENTITIES (U1's call, PROVISIONAL — the record in the phase plan §8,
// QUESTIONS): the hardware identity is the Mac's hardware UUID
// (`IOPlatformUUID`); the login's stable identity is the account's
// directory-services UUID (`GeneratedUID` — what OpenDirectory's
// `kODAttributeTypeGUID` and Collaboration's `CBUserIdentity.uniqueIdentifier`
// return): the user RECORD's own identity — Apple keys APFS volume ownership
// and FileVault's crypto users on it — so it lives outside the keychain and
// the password, and a deleted-and-re-created account is a new login (the safe
// side: a new device identity). The numeric UID was set aside: Apple documents
// it as not unique, and a re-created account commonly re-uses it. Apple
// documents none of GeneratedUID's lifecycle directly (the one Sonnet lookup,
// 2026-10-14), so its stability across a password reset, a keychain reset and
// an OS update is phase 2's to verify on a real Mac, beside reading both
// identifiers in a SANDBOXED build. Reading either is a LEAF; the model takes
// them as plain values and never stores them.

/// The two identifiers the marker hashes — read by a leaf, held only for the
/// moment the marker is computed, NEVER stored, encoded or logged (it is
/// deliberately not `Codable`, and its description is redacted).
public struct MachineIdentity: Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    /// The Mac's hardware UUID (`IOPlatformUUID`).
    public var hardware: String
    /// The macOS login's `GeneratedUID`.
    public var login: String

    public init(hardware: String, login: String) {
        self.hardware = hardware
        self.login = login
    }

    public var description: String { "MachineIdentity(redacted)" }
    public var debugDescription: String { description }
}

public enum HardwareMarker {
    /// FORMAT: the domain separator inside the hashed message.
    public static let domain = "variorum.hardware-marker.v1"
    /// The salt's length — 256 random bits per record.
    public static let saltBytes = 32

    /// A fresh salt for a new record.
    public static func mintSalt() -> Data {
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }

    /// `HMAC-SHA256(key: salt, message: domain ‖ len‖hardware ‖ len‖login)`,
    /// lowercase hex. Length-prefixed so no pair of identifiers can collide
    /// with another by moving a boundary.
    public static func compute(_ machine: MachineIdentity, salt: Data) -> String {
        var message = Data(domain.utf8)
        for field in [machine.hardware, machine.login] {
            let bytes = Data(field.utf8)
            var length = UInt32(bytes.count).bigEndian
            message.append(Data(bytes: &length, count: 4))
            message.append(bytes)
        }
        let mac = HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: salt))
        return mac.map { String(format: "%02x", $0) }.joined()
    }
}
