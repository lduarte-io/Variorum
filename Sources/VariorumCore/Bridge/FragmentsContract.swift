import CryptoKit
import Foundation

/// The Fragments side of the bridge, as pinned in
/// `notes/fragments-bridge-contract.md` (Phase 9b). The contract is the WHOLE
/// interface — this repo's agents never read `~/dev/fragments`; anything the
/// contract does not pin is carried here as injectable configuration plus a
/// recorded ask, never as a guess baked into code.
///
/// What the contract pins: the `journal_entries` shape, live-unique
/// `(user_id, date)`, the deterministic id recipe
/// `UUIDv5("journal|<canonical-user>|<dayKey>")` with dayKey `"yyyy-MM-dd"`,
/// row-LWW on client-stamped `updated_at`, un-tombstone only strictly-newer,
/// and the ~2 s pull visibility horizon.
///
/// What the contract does NOT pin (Phase 9b finding — asks filed in the
/// contract file for the author to carry): the namespace UUID the derivation
/// runs in, a worked id example, the exact canonical-user string form, and
/// the RPC wire shapes. The first three ride `FragmentsBridgeConfiguration`
/// as author-supplied facts; the wire shapes are PROVISIONAL in
/// `FragmentsRPCTransport`.
public enum FragmentsContract {
    /// Fragments' UUIDv5 namespace — CONFIRMED by their agents 2026-07-09
    /// (ask 8 ANSWERED; `DeterministicID.swift` / their SyncSpec §2.1,
    /// "fixed forever" under their ID FREEZE). No longer a guessed value:
    /// configuration defaults to it; tests pin the journal vectors under it.
    public static let fragmentsNamespace = UUID(
        uuidString: "7B69C1E4-9C72-4D2F-9B3A-2A41F0F4C0DE")!

    /// The deterministic-id name string, exactly the contract's recipe:
    /// `journal|<canonical-user>|<dayKey>` — no trailing newline, no
    /// padding, UTF-8.
    public static func entryName(canonicalUser: String, dayKey: String) -> String {
        "journal|\(canonicalUser)|\(dayKey)"
    }

    /// The `journal_entries.id` for a calendar day: UUIDv5 of the recipe
    /// string in the namespace, emitted lowercase (Postgres `uuid`
    /// canonical text form). **The name is lowercased before hashing** —
    /// mirroring Fragments' `bcased()` (ask 9/10 ANSWERED: case is
    /// load-bearing at the hash level; their pipeline lowercases, and the
    /// canonical user is lowercased UUID text — a mis-cased input must
    /// still derive the ONE true id, pinned by the case vectors). `nil`
    /// for a malformed day key — a malformed key can never join, so no id
    /// may exist for it.
    public static func entryID(
        namespace: UUID, canonicalUser: String, dayKey: String
    ) -> String? {
        guard JournalDay.isValid(dayKey) else { return nil }
        return UUIDv5.derive(
            namespace: namespace,
            name: entryName(canonicalUser: canonicalUser, dayKey: dayKey).lowercased()
        ).uuidString.lowercased()
    }
}

/// RFC 4122 §4.3 name-based UUID, version 5 (SHA-1). The algorithm is the
/// standard's, pinned by test against the RFC-lineage vector
/// (DNS namespace + "python.org" → 886313e1-3b8a-5372-9b90-0c9aee199e5d);
/// only the NAMESPACE Fragments uses is an external fact (configuration).
public enum UUIDv5 {
    public static func derive(namespace: UUID, name: String) -> UUID {
        // `UUID.uuid` is the raw 16-byte canonical (network-order) sequence,
        // which is exactly what §4.3 hashes.
        var message = withUnsafeBytes(of: namespace.uuid) { Data($0) }
        message.append(contentsOf: Array(name.utf8))
        let digest = Insecure.SHA1.hash(data: message)
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50  // version 5
        bytes[8] = (bytes[8] & 0x3F) | 0x80  // RFC 4122 variant
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}

/// The body-hash the bridge's change detection rides (push idempotence — the
/// clobber-guard mirror — and landing echo/replay skips). SHA-256 hex of the
/// UTF-8 body; stored in the local-only `bridge_day` table, never synced.
public enum BridgeHash {
    public static func body(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

/// Bridge configuration (reconciled 2026-07-09 against the Fragments
/// agents' answers). The namespace is now a KNOWN constant (default);
/// `userID` is the auth uid from the session (the `journal_entries.user_id`
/// column — the server forces it to `auth.uid()` anyway, but all six NOT
/// NULL columns must be sent). **The canonical-user key is deliberately NOT
/// here** (asks 9/10 ANSWERED): it is `user_settings.local_user_id` —
/// minted by Fragments' first device, distinct from the auth uid by
/// design — and the engine RESOLVES it from the server each round, never
/// guesses it, and FAILS CLOSED while no row exists (the account has not
/// synced from Fragments yet; pushing then would claim canon with a
/// Variorum-invented id).
public struct FragmentsBridgeConfiguration: Equatable, Sendable {
    /// Fragments' UUIDv5 namespace. Defaults to the confirmed constant;
    /// injectable for tests only.
    public var idNamespace: UUID
    /// The `journal_entries.user_id` value: the authenticated Fragments
    /// user (`auth.uid()`).
    public var userID: String

    public init(
        idNamespace: UUID = FragmentsContract.fragmentsNamespace,
        userID: String
    ) {
        self.idNamespace = idNamespace
        self.userID = userID
    }
}
