import CryptoKit
import Foundation

// VX-305 U1 — THE HARDWARE MARKER (design §3.2, §3.6, §3.13; VX-340 option (a),
// confirmed by the author at the VX-305 kickoff): this Mac's hardware identity
// AND this macOS login's stable identity, each hashed with a random salt the
// protection record carries — never either identifier itself — so it
// recomputes on the same hardware and login, a second login on the same Mac
// gets a different marker (and so its own device identity), and a marker that
// leaks alone (say into a log) names no Mac.
//
// TWO SALTED PARTS (her ruling 2026-10-14/15, the U4 sitting — P-U4-3 option
// (c), "split the marker"): a HARDWARE part and a LOGIN part, each its own
// salted hash, so identity resolution can tell the two ways a marker differs:
//   - the same hardware, another login → a SECOND LOGIN on this Mac: its own
//     identity, and it adopts nothing (VX-340);
//   - other hardware → a REPLACEMENT (Quick Start, Migration Assistant, a
//     restore onto another Mac): a new identity that takes over per §3.5.
// Each part alone, salted, names nothing; her "the marker covers the login"
// ruling stands — continuing on a section needs BOTH parts to match.
//
// WHICH IDENTITIES (U1's call, PROVISIONAL P-U1-1, confirmed by her
// 2026-10-14): the hardware identity is the Mac's hardware UUID
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

/// **The marker** — two salted parts, lowercase hex each. Equal markers are
/// the same hardware AND the same login.
public struct HardwareMarker: Codable, Equatable, Hashable, Sendable {
    /// `HMAC-SHA256(key: salt, message: hardwareDomain ‖ len‖hardware)`.
    public var hardware: String
    /// `HMAC-SHA256(key: salt, message: loginDomain ‖ len‖login)`.
    public var login: String

    public init(hardware: String, login: String) {
        self.hardware = hardware
        self.login = login
    }

    /// FORMAT: the domain separators inside the hashed messages — one per
    /// part, so neither part can ever equal the other's hash of the same text.
    public static let hardwareDomain = "variorum.hardware-marker.v2.hardware"
    public static let loginDomain = "variorum.hardware-marker.v2.login"
    /// The salt's length — 256 random bits per record.
    public static let saltBytes = 32

    /// A fresh salt for a new record.
    public static func mintSalt() -> Data {
        SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
    }

    /// Both parts for `machine` under `salt`.
    public static func compute(_ machine: MachineIdentity, salt: Data) -> HardwareMarker {
        HardwareMarker(
            hardware: part(hardwareDomain, machine.hardware, salt: salt),
            login: part(loginDomain, machine.login, salt: salt))
    }

    /// `HMAC-SHA256(key: salt, message: domain ‖ len‖field)`, lowercase hex —
    /// length-prefixed, so no field can collide with another by moving a
    /// boundary into the domain.
    static func part(_ domain: String, _ field: String, salt: Data) -> String {
        var message = Data(domain.utf8)
        let bytes = Data(field.utf8)
        var length = UInt32(bytes.count).bigEndian
        message.append(Data(bytes: &length, count: 4))
        message.append(bytes)
        let mac = HMAC<SHA256>.authenticationCode(for: message, using: SymmetricKey(data: salt))
        return mac.map { String(format: "%02x", $0) }.joined()
    }

    /// A library with no record yet (the migration's subject) has no salt to
    /// compute under: its placeholder section carries this until the
    /// migration writes the real one — never stored.
    public static let unset = HardwareMarker(hardware: "", login: "")

    /// The same hardware, whatever the login — with a different login part,
    /// a second login on this Mac (VX-340).
    public func sameHardware(as other: HardwareMarker) -> Bool { hardware == other.hardware }
}
