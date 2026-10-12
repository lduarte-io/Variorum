import CryptoKit
import Foundation

/// **THE SETUP-KEY RULE — who a connection IS** (VX-168; the VX-156 brief §12's
/// K2, her kickoff ruling R-VX168-1 — the run record
/// `notes/plans/fixes/vx-168-mcp-client-secret.md`).
///
/// A client names itself in `initialize` (A-4 — the name IS the identity a
/// grant gates). Since VX-168 every setup copied from Settings ▸ MCP carries a
/// fresh KEY, which the `variorum-mcp` shim speaks as a one-line preamble
/// before the first frame; this rule decides, ONCE PER CONNECTION, whether the
/// key the connection presented ties it to the name it claims. It decides
/// identity only — whether the name is approved, pending or denied stays
/// `MCPGrantRule`'s, per call, exactly as before.
///
/// The arms (each pinned by a state-transition test, `MCPSetupKeyTests`):
/// - **No key (a bare shim, or any process that never ran a setup) → refuse**,
///   under ANY name, bound or not — her word: no grandfathering.
/// - **A name bound to a key:** its own key → admit; any other key → refuse
///   (two tools under one name told apart — a fresh key from a newer copy is
///   still another key).
/// - **A name with no key bound** (approved before VX-168, released by Deny,
///   or a fresh name): a key minted by a copy and not yet presented CLAIMS it
///   — an UNKNOWN name becomes a connection request bound to the key (K2:
///   "the first name that presents it binds to it", effective at her
///   approval); a KNOWN unbound name binds it at once (R-VX168-1: "just re-run
///   the setup" — no revoke, no re-approval ceremony). A key already bound to
///   another name, or one this library never minted (or no longer holds),
///   refuses.
///
/// Every refusal answers the CLIENT with ONE sentence (no oracle telling a
/// wrong key from a missing binding); `Refusal` exists for her Activity
/// list, which speaks precisely.
///
/// Recorded non-defeat (K2's own): the key lives in the client's settings,
/// readable by any program running as her — it tells tools apart and turns
/// away a stray bare launch, never same-user malware.
public enum MCPSetupKeyRule {
    // MARK: - The key's form

    /// The key's version prefix — a key is `vmk1_` + 43 base64url characters
    /// (256 random bits), shell- and JSON-safe as written.
    public static let prefix = "vmk1_"

    /// The key minted from 32 random bytes (the caller supplies the bytes —
    /// CryptoKit's generator in production — so this stays pure).
    public static func key(fromRandomBytes bytes: Data) -> String {
        prefix + bytes.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// The stored form: hex SHA-256 over a domain-separated encoding of the
    /// key exactly as presented. The library never holds a key, only this;
    /// a 256-bit random key needs no salt or slow hash (nothing to guess).
    public static func hash(_ key: String) -> String {
        let digest = SHA256.hash(data: Data(("variorum.mcp-setup-key.v1:" + key).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - The facts

    /// The client row the connection's name finds, as the rule needs it.
    public struct Client: Equatable, Sendable {
        public var id: String
        /// The hash of the key bound to the name; nil = unbound.
        public var boundHash: String?

        public init(id: String, boundHash: String?) {
            self.id = id
            self.boundHash = boundHash
        }
    }

    /// Where the PRESENTED key stands in this library.
    public enum KeyStanding: Equatable, Sendable {
        /// Minted by a copy and not yet presented by any name.
        case unclaimed
        /// Bound to the client with this id.
        case boundTo(clientID: String)
        /// Never minted here, or no longer held (pushed past the cap, or
        /// released by Deny or an adoption).
        case unknown
    }

    // MARK: - The decision

    public enum Decision: Equatable, Sendable {
        /// The name's own key.
        case admit
        /// A KNOWN name with no key bound claims this unclaimed key
        /// (R-VX168-1).
        case bind
        /// An UNKNOWN name claims this unclaimed key: a new connection
        /// request, bound to it (K2).
        case request
        case refuse(Refusal)

        public var admits: Bool {
            if case .refuse = self { return false }
            return true
        }
    }

    /// Why a connection was refused — for her Activity list only; the
    /// client hears one sentence for all of them.
    public enum Refusal: String, CaseIterable, Sendable {
        /// `initialize` named no client.
        case unnamed
        /// No key was presented (a bare shim).
        case bare
        /// A key this library never minted, or no longer holds.
        case notIssued
        /// The key is bound to a different name.
        case anotherNamesKey
        /// The name is bound to a different key (the impostor).
        case notThisNamesKey
    }

    /// **The one decision**, per connection.
    /// - `name`: the name `initialize` declared, trimmed.
    /// - `client`: the row that name finds (nil = a name never seen).
    /// - `presentedHash`: `hash(key)` of the presented key; nil = bare.
    /// - `standing`: where that key stands (ignored when bare).
    public static func decide(
        name: String, client: Client?, presentedHash: String?, standing: KeyStanding
    ) -> Decision {
        guard !name.isEmpty else { return .refuse(.unnamed) }
        guard let presentedHash else { return .refuse(.bare) }
        if let bound = client?.boundHash {
            return bound == presentedHash ? .admit : .refuse(.notThisNamesKey)
        }
        switch standing {
        case .unclaimed: return client == nil ? .request : .bind
        case .boundTo: return .refuse(.anotherNamesKey)
        case .unknown: return .refuse(.notIssued)
        }
    }

    // MARK: - The activity log's acts (her Activity list's words key on these)

    /// The act a refused connection logs.
    public static func activityAct(_ refusal: Refusal) -> String {
        switch refusal {
        case .unnamed: "connect_unnamed"
        case .bare: "connect_bare"
        case .notIssued: "connect_not_issued"
        case .anotherNamesKey: "connect_another_names_key"
        case .notThisNamesKey: "connect_not_this_names_key"
        }
    }

    /// The act an existing name's FIRST key logs when it binds (allowed).
    public static let boundAct = "connect_bound"
}
