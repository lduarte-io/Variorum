import CArgon2
import CryptoKit
import Foundation

/// Argon2id passphrase-key derivation (Phase 14b, ruling R-7 — author-
/// confirmed: "Confirmed — Argon2id (Recommended)").
///
/// The passphrase wrap is the ONLY brute-forceable wrap in the vault
/// (the recovery wrap is high-entropy by construction, R-5), so this is
/// where the KDF hardening lives: Argon2id via the vendored PHC reference
/// implementation (`Vendor/CArgon2/`, pinned commit in its README),
/// parameters in the ~64 MiB class — exceeding the OWASP floor
/// (19 MiB / t=2 / p=1) — with the exact parameters VERSIONED in the
/// `Descriptor` stored beside the wrapped key. R-7's soft-door fact rides
/// on that: a future parameter/algorithm change is a one-key re-wrap at
/// next unlock (mint a new descriptor, re-wrap the master), never a corpus
/// re-encrypt — which is why `deriveKey` honors whatever descriptor it is
/// handed rather than assuming the current default.
///
/// The passphrase is normalized to NFKD before hashing (the same
/// normalization convention BIP-39 uses in `RecoveryPhrase`), so the same
/// characters typed on any device derive the same key regardless of the
/// platform text input's composition form.
public enum PassphraseKDF {
    /// The one supported algorithm identifier. The field exists so a vault
    /// written by a future version refuses loudly here instead of deriving
    /// garbage.
    public static let algorithmArgon2id = "argon2id"

    /// The versioned KDF parameter record stored in the vault beside the
    /// passphrase-wrapped master (AppSpec-style rows-as-truth: the
    /// descriptor IS the truth about how the wrap key was derived — never
    /// re-derive parameters from app defaults when unwrapping).
    public struct Descriptor: Codable, Equatable, Sendable {
        /// Algorithm identifier; only `argon2id` is supported.
        public var algorithm: String
        /// Argon2 version number (0x13 = 19, the current and only version
        /// the reference implementation recommends).
        public var argon2Version: Int
        /// Memory cost in KiB.
        public var memoryKiB: Int
        /// Passes over memory (t_cost).
        public var iterations: Int
        /// Lanes (p). Kept 1 in the v1 default: the vendored build is
        /// single-threaded (`ARGON2_NO_THREADS`), so extra lanes buy no
        /// wall-clock parallelism, and one lane keeps derivation identical
        /// and simple on every device.
        public var parallelism: Int
        /// The per-vault random salt (16 bytes in the v1 default).
        public var salt: Data
        /// Derived key length in bytes (32 — an AES-256 wrap key).
        public var outputBytes: Int

        public init(
            algorithm: String, argon2Version: Int, memoryKiB: Int, iterations: Int,
            parallelism: Int, salt: Data, outputBytes: Int
        ) {
            self.algorithm = algorithm
            self.argon2Version = argon2Version
            self.memoryKiB = memoryKiB
            self.iterations = iterations
            self.parallelism = parallelism
            self.salt = salt
            self.outputBytes = outputBytes
        }

        /// The v1 default parameter set (R-7: the ~64 MiB class, OWASP-
        /// floor-exceeding; latency measured by the harness test on the Mac
        /// and by batch 3 on the phone): m = 64 MiB, t = 3, p = 1,
        /// 32-byte output. RFC 9106's second recommended option is
        /// m = 64 MiB, t = 3, p = 4; we hold m and t and keep one lane for
        /// the single-threaded build (see `parallelism`).
        public static func v1(salt: Data) -> Descriptor {
            Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id,
                argon2Version: 0x13,
                memoryKiB: 64 * 1024,
                iterations: 3,
                parallelism: 1,
                salt: salt,
                outputBytes: 32
            )
        }
    }

    /// A fresh random 16-byte salt for a new descriptor (CSPRNG via
    /// CryptoKit — key-material randomness deliberately does NOT flow
    /// through the seedable `@Dependency` generator; tests exercise the
    /// pure derivation path with fixed salts instead).
    public static func randomSalt() -> Data {
        SymmetricKey(size: .bits128).withUnsafeBytes { Data($0) }
    }

    /// Derive the passphrase wrap key for `descriptor`. The heavy call
    /// (~64 MiB transient, tenths of a second) — callers run it off the
    /// main thread and only at setup/enrollment (R-6: enrollment-only
    /// cadence).
    public static func deriveKey(
        passphrase: String, descriptor: Descriptor
    ) throws -> SymmetricKey {
        guard descriptor.algorithm == algorithmArgon2id else {
            throw PassphraseKDFError.unsupportedAlgorithm(descriptor.algorithm)
        }
        guard descriptor.argon2Version == 0x13 else {
            throw PassphraseKDFError.unsupportedParameters(
                "argon2Version \(descriptor.argon2Version)")
        }
        guard descriptor.outputBytes >= 16, descriptor.outputBytes <= 64,
            descriptor.memoryKiB > 0, descriptor.iterations > 0,
            descriptor.parallelism > 0,
            descriptor.memoryKiB >= 8 * descriptor.parallelism,
            !descriptor.salt.isEmpty
        else {
            throw PassphraseKDFError.unsupportedParameters("out-of-range descriptor")
        }

        let password = Data(passphrase.decomposedStringWithCompatibilityMapping.utf8)
        var output = Data(count: descriptor.outputBytes)
        let code = output.withUnsafeMutableBytes { outBytes in
            password.withUnsafeBytes { pwdBytes in
                descriptor.salt.withUnsafeBytes { saltBytes in
                    argon2id_hash_raw(
                        UInt32(descriptor.iterations),
                        UInt32(descriptor.memoryKiB),
                        UInt32(descriptor.parallelism),
                        pwdBytes.baseAddress, password.count,
                        saltBytes.baseAddress, descriptor.salt.count,
                        outBytes.baseAddress, descriptor.outputBytes
                    )
                }
            }
        }
        guard code == ARGON2_OK.rawValue else {
            let message = argon2_error_message(code).map { String(cString: $0) } ?? "unknown"
            throw PassphraseKDFError.derivationFailed(code: Int(code), message: message)
        }
        return SymmetricKey(data: output)
    }
}

/// Typed refusals — a KDF problem must speak, never crash and never
/// silently derive a wrong key.
public enum PassphraseKDFError: Error, Equatable, Sendable {
    /// The descriptor names an algorithm this build does not implement
    /// (a vault written by a future format — refuse, don't guess).
    case unsupportedAlgorithm(String)
    /// Descriptor parameters outside what this build supports.
    case unsupportedParameters(String)
    /// The vendored Argon2 call itself refused (its error message carried).
    case derivationFailed(code: Int, message: String)
}
