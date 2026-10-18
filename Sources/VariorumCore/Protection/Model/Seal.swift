import CryptoKit
import Foundation

// VX-305 U1 — THE SEAL (design §3.6, VX-313):
//
//     HMAC-SHA256(key: HKDF-SHA256(ikm: L, salt: libraryID,
//                                  info: "variorum.seal.v1:" + purpose),
//                 message: the sealed fields' canonical JSON)
//
// naming the sealing key's fingerprint. A seal proves what a value SAYS, never
// that it is current — freshness is the section's version (§3.6), not this.
//
// THE STORED-BYTES RULE: a `Sealed` value keeps the exact canonical bytes it
// was sealed over and verifies THOSE, then decodes them — it never re-encodes
// to verify. So a future Foundation that formats a number differently can
// never make yesterday's seals fail, and what was verified is byte-for-byte
// what is read.

/// The one encoder and decoder every sealed or stored protection value uses.
/// Canonical: sorted keys, no slash escaping, dates as `Date`'s own reference
/// seconds (`.deferredToDate` — a bit-exact round trip), data as base64.
public enum ProtectionCoding {
    public static func canonicalEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .deferredToDate
        encoder.dataEncodingStrategy = .base64
        return encoder
    }

    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.dataDecodingStrategy = .base64
        return decoder
    }

    public static func canonical<T: Encodable>(_ value: T) throws -> Data {
        try canonicalEncoder().encode(value)
    }
}

/// What a seal is for — part of the derived key, so a value sealed for one
/// purpose can never verify as another's. FORMAT constants.
public struct SealPurpose: RawRepresentable, Hashable, Codable, Sendable {
    public var rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }

    /// What this Mac remembers (§3.2 — "sealed (purpose `memory`)").
    public static let memory = SealPurpose(rawValue: "memory")
    /// A plan (§3.6).
    public static let plan = SealPurpose(rawValue: "plan")
    /// This Mac's device section inside the record — the first of this Mac's
    /// facts' two sealed homes (§3.6).
    public static let deviceSection = SealPurpose(rawValue: "device-section")
}

/// The seal itself: the MAC and the fingerprint of the library key it was
/// made under (so a verifier knows which key to reach for — the current one,
/// or an older one through the history, §3.6 "Checking").
public struct Seal: Codable, Equatable, Sendable {
    public var keyFingerprint: String
    public var mac: Data

    public init(keyFingerprint: String, mac: Data) {
        self.keyFingerprint = keyFingerprint
        self.mac = mac
    }
}

public enum SealError: Error, Equatable, Sendable {
    /// The value was sealed under a key whose fingerprint is not the key
    /// offered (and no reachable key carries it).
    case sealedUnderAnotherKey(String)
    /// The MAC does not verify — an edited value, a value moved between
    /// libraries or purposes, or a forged seal.
    case doesNotVerify
    /// The bytes verified but do not decode as the expected value.
    case undecodable(String)
}

public enum ProtectionSeal {
    /// FORMAT: the info prefix of the HKDF.
    public static let infoPrefix = "variorum.seal.v1:"

    /// The derived sealing key. Internal — no caller outside the seal ever
    /// holds it (the secret scans assert it never lands in a stored value).
    static func sealingKey(libraryKey: StoreKey, libraryID: String, purpose: SealPurpose) -> SymmetricKey {
        HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: libraryKey.data),
            salt: Data(libraryID.utf8),
            info: Data((infoPrefix + purpose.rawValue).utf8),
            outputByteCount: 32)
    }

    public static func seal(
        _ message: Data, libraryKey: StoreKey, libraryID: String, purpose: SealPurpose
    ) -> Seal {
        let key = sealingKey(libraryKey: libraryKey, libraryID: libraryID, purpose: purpose)
        let mac = HMAC<SHA256>.authenticationCode(for: message, using: key)
        return Seal(keyFingerprint: StoreKeyEnvelope.fingerprint(of: libraryKey), mac: Data(mac))
    }

    /// Constant-time verification (`HMAC.isValidAuthenticationCode`).
    public static func verify(
        _ message: Data, seal: Seal, libraryKey: StoreKey, libraryID: String, purpose: SealPurpose
    ) -> Bool {
        guard seal.keyFingerprint == StoreKeyEnvelope.fingerprint(of: libraryKey) else { return false }
        let key = sealingKey(libraryKey: libraryKey, libraryID: libraryID, purpose: purpose)
        return HMAC<SHA256>.isValidAuthenticationCode(seal.mac, authenticating: message, using: key)
    }
}

/// **A sealed value**: the canonical bytes it was sealed over, and the seal.
/// The purpose and the library ID are NOT stored — the verifier supplies the
/// ones it expects, and anything else fails (`doesNotVerify`).
public struct Sealed<Value: Codable & Sendable>: Codable, Sendable {
    public let payload: Data
    public let seal: Seal

    public init(payload: Data, seal: Seal) {
        self.payload = payload
        self.seal = seal
    }

    public static func sealing(
        _ value: Value, purpose: SealPurpose, libraryID: String, key: StoreKey
    ) throws -> Sealed<Value> {
        let payload = try ProtectionCoding.canonical(value)
        return Sealed(
            payload: payload,
            seal: ProtectionSeal.seal(payload, libraryKey: key, libraryID: libraryID, purpose: purpose))
    }

    /// The fingerprint of the key the value was sealed under.
    public var sealedUnder: String { seal.keyFingerprint }

    /// Verify with `key`, then decode the verified bytes.
    public func open(purpose: SealPurpose, libraryID: String, key: StoreKey) throws -> Value {
        guard seal.keyFingerprint == StoreKeyEnvelope.fingerprint(of: key) else {
            throw SealError.sealedUnderAnotherKey(seal.keyFingerprint)
        }
        guard ProtectionSeal.verify(payload, seal: seal, libraryKey: key, libraryID: libraryID, purpose: purpose) else {
            throw SealError.doesNotVerify
        }
        do {
            return try ProtectionCoding.decoder().decode(Value.self, from: payload)
        } catch {
            throw SealError.undecodable(String(describing: error))
        }
    }

    /// Verify with whichever key `reach` hands back for the sealing
    /// fingerprint — the current key, or an older one through the history
    /// ("reached through the history when the plan's own act has since
    /// re-keyed", §3.6).
    public func open(
        purpose: SealPurpose, libraryID: String, reach: (String) -> StoreKey?
    ) throws -> Value {
        guard let key = reach(seal.keyFingerprint) else {
            throw SealError.sealedUnderAnotherKey(seal.keyFingerprint)
        }
        return try open(purpose: purpose, libraryID: libraryID, key: key)
    }
}

extension Sealed: Equatable where Value: Equatable {}
