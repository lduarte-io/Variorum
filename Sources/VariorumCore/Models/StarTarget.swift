import Foundation

/// WHAT A STAR POINTS AT (Phase 13f, W4 — her sitting ruling, round 3:
/// *"stars = a synced `setting` list + a Starred sidebar section … up to 5
/// notes or books, star/unstar via context menu + ⌘K, section at the
/// sidebar's top"*).
///
/// Stars live under the `'starred'` **setting** key as a canonical JSON
/// array of these keys, in star order — the `shelf_pins` precedent exactly
/// (AppSpec §7's setting class: synced document semantics, upsert-only,
/// never tombstoned; plain metadata CAS, so a two-device star race
/// converges to either list and never to corruption). **ZERO schema, and
/// therefore no SyncSpec §12 lockstep event** — which is the whole reason
/// her ruling picked this shape over a column.
///
/// **The stored prefix is the MODEL's word, never the UI's** (K5's letter):
/// `post:` and `reading:`, matching `container.kind='post'` and the
/// `reading` table. The sweep that renames the UI's "post" to "note" and
/// "book" is UI-STRINGS-ONLY and can never reach a stored value, so the
/// ratified vocabulary stays unmuddied on both sides. The grammar is also
/// the app's own: `WorkspaceModel`'s title keys and the `book-chapter:` /
/// `lens-move:` drag payloads all discriminate by prefix this way.
public struct StarTarget: Hashable, Sendable {
    public enum Kind: String, Sendable, CaseIterable {
        /// A note — `container` where `kind = 'post'`.
        case post
        /// A book — a `reading` row, curated or smart alike.
        case reading
    }

    public let kind: Kind
    public let id: String

    public init(kind: Kind, id: String) {
        self.kind = kind
        self.id = id
    }

    public static func post(_ id: String) -> StarTarget { StarTarget(kind: .post, id: id) }
    public static func reading(_ id: String) -> StarTarget { StarTarget(kind: .reading, id: id) }

    /// The canonical stored form. One encoding, one decoder — so a list
    /// written by one device reads identically on the next.
    public var key: String { "\(kind.rawValue):\(id)" }

    /// Decodes a stored key; nil for anything this version does not
    /// understand (an unknown prefix, an empty id, a missing separator).
    /// Unreadable entries are DROPPED rather than fatal — stars are
    /// presentation, never truth (the `shelfPins` fail-open rule).
    public init?(key: String) {
        guard let separator = key.firstIndex(of: ":") else { return nil }
        let rawKind = String(key[key.startIndex..<separator])
        let rawID = String(key[key.index(after: separator)...])
        guard let kind = Kind(rawValue: rawKind), !rawID.isEmpty else { return nil }
        self.init(kind: kind, id: rawID)
    }
}
