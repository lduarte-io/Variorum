import Foundation

/// **WHEN TWO BOOKS COUNT AS SHARING A NAME** — Phase 13e, ledger row E13.
///
/// Her observation (2026-08-02, the post-13k conversation — 13k K4's
/// shown-once rule surfaced it): *"i think that maybe being able to name
/// books the exact same thing is not the best? it seems a bit confusing. i
/// don't think it has to be a schema rule but maybe a UI rule that you
/// can't purposefully do that? I'm open to suggestions there."* Her RULING
/// at the 13e kickoff sitting (round 3): **REFUSE at the door**, case
/// insensitively, against any LIVE book — with honest wording.
///
/// ── WHY THIS IS A DOOR RULE AND NEVER A SCHEMA ONE ──────────────────────
/// A live-unique index on `reading.name` would owe a SyncSpec §7 repair
/// rule, and the only repairs available for a natural-key collision are
/// "keep the smaller id and tombstone the other" (which would delete a book
/// she made on her phone) or a forced rename (which would rename a book
/// behind her back). Her word covers exactly the case a door can see: two
/// books named the same thing **on purpose**, on one device, at the moment
/// she types the name. The offline race stays legal by design, and 13k K4's
/// shown-once display already absorbs a raced collision gracefully (a card
/// listing "Ideas" curated and "Ideas" smart shows the name once — the
/// #53(l) call).
///
/// ── THE KEY, AND WHAT IT DELIBERATELY DOES NOT FOLD ─────────────────────
/// Ends-trimmed and case-folded, and nothing else. Internal spacing is NOT
/// collapsed ("my  book" and "my book" are two names) and diacritics are
/// NOT folded ("Élan" and "Elan" are two names): her ruling said
/// case-insensitive, and every further fold would be a behaviour nobody
/// asked for, refusing a name she is entitled to use. `lowercased()` rather
/// than `localizedLowercase` on purpose — a comparison key that changes
/// with the system locale would make the same two names collide on one Mac
/// and not on another.
///
/// Pure and dependency-free — no GRDB, no AppKit. The store-truthful half
/// (which books are live) is `Operations.assertBookNameIsFree`.
public enum BookNaming {
    /// The comparison key two names share when they are "the same name".
    /// VX-357: any U+0000 is removed first (`StoredText.stripped`) — the store
    /// keeps a name without it, so a typed name collides exactly as it will
    /// be stored.
    public static func key(_ name: String) -> String {
        StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Do these two book names collide under the ruled rule?
    public static func sameName(_ a: String, _ b: String) -> Bool {
        key(a) == key(b)
    }
}
