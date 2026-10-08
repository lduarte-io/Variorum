import Foundation

// Phase 13x, U1 row 4 — THE CUSTODY-COLLISION RULE (the memo in
// `notes/plans/phase-13x-library-portability.md` §"ROW 4 — THE
// CUSTODY-COLLISION MEMO", written before this file; the sync trace's
// honest-list item 2). The older-key same-Mac adopt: a pre-Replace-All-
// Keys copy of THE SAME library (same store id — the id is stable across
// re-keys, §3.5) opened by its own day's key file under L_old, while this
// device's custody holds the live L_new.
//
// THE RULE: custody adopts the key that OPENS the now-live file. M, C and
// the device identity are UNTOUCHED — account-level facts riding the
// sync-custody item (§3.3), never facts about which file sits at the
// store path. The custody SHAPE follows the posture unchanged (silent /
// gated / none under Always ask). The moved-aside library keeps its own
// key-file roads (its key files travel with it — `LibraryAdoption`), so
// replacing the item retires only the SILENT road into it, by design.
//
// This type is the DECISION alone — pure, pinned. The one write the
// verdict names runs through the EXISTING save door (`StoreKeyCustody`'s
// save under the same (scope, store id) name) at U2's door; no custody
// write-path change exists or is needed (read-only composition, the row's
// own condition — verified against `StoreKeyCustody`/`StoreKeyKeychain`
// as shipped).

public enum CustodyCollisionRule {
    public enum Verdict: Equatable, Sendable {
        /// Custody's held key IS the key that opened the adopted copy
        /// (same fingerprint) — a same-key snapshot (ledger 14's class);
        /// nothing to write.
        case alreadyAligned
        /// Custody exists for this store id and holds a DIFFERENT key —
        /// the collision: at the adoption's completion the library-key
        /// item is replaced with the opener, through the existing door.
        case adoptOpeningKey
        /// No custody for this store id — this machine never opened the
        /// library (a new-Mac arrival, corner 33's enrollment class);
        /// the opener lands as this device's first custody.
        case mintFreshCustody
    }

    /// `custodyHeldFingerprint` — the fingerprint of the library key this
    /// device's custody holds for the adopted library's store id
    /// (`StoreKeyEnvelope.fingerprint(of:)` over the custody read), nil
    /// when custody holds none (a fresh machine, a wiped Keychain, or
    /// Always ask — whose session-held opener follows the same verdicts
    /// with no item written). `openingKeyFingerprint` — the fingerprint
    /// of the key that actually opened the adopted copy.
    public static func verdict(
        custodyHeldFingerprint: String?, openingKeyFingerprint: String
    ) -> Verdict {
        guard let custodyHeldFingerprint else { return .mintFreshCustody }
        return custodyHeldFingerprint == openingKeyFingerprint
            ? .alreadyAligned
            : .adoptOpeningKey
    }
}
