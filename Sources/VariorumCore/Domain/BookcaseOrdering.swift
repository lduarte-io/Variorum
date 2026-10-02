import Foundation

/// **THE BOOKCASE'S SHARED ORDERING RULES** (13i-d U1 — the sitting record
/// §7, §19, §20, §24; the plan's U1 brief).
///
/// Two consumers read these rules and they must never disagree: the
/// operations layer (`placeReading` computes where a hand-placed book lands)
/// and the board (it draws "my order" from the same sequence). So the rules
/// live once, here, pure — the `BoundarySnapping` precedent: one rule the op
/// and the face both consult.
///
/// ── THE MODEL (her rulings, stated as mechanism) ─────────────────────────
/// - A book sits on ONE shelf (`reading.shelf_id`). A nil or DANGLING pointer
///   — a shelf that was deleted, or one in another wing — means UNSHELVED
///   (§19's ruling; deleting a shelf never touches a book).
/// - "My order" is ONE position sequence per shelf (and one for the
///   unshelved run): placed books by `(shelf_position, id)`, then the
///   never-placed books (`shelf_position` NULL) A–Z (§24: "it remembers every
///   placement and appends never-placed books at the end").
/// - **The star is never part of the sequence** (§20, her rider: *"send to
///   top would still be underneath starred"*). The DISPLAY floats starred
///   books first under any order; positions do not know about stars, so
///   Send to Top writes the smallest position and an unstarred book tops the
///   unstarred run while a starred one tops the starred run — no special
///   cases.
public enum BookcaseOrdering {
    /// **A–Z** — the Bookcase's default order (§24: *"the cleanest rule for
    /// all and makes it seem more neat and serious"*). Finder's rule
    /// (`localizedStandardCompare`: case-insensitive, digit-aware, so "Book
    /// 2" sorts before "Book 10"), the id breaking ties so two same-named
    /// books (a legal offline race) still order deterministically.
    public static func nameAscending(
        _ a: (name: String, id: String), _ b: (name: String, id: String)
    ) -> Bool {
        switch a.name.localizedStandardCompare(b.name) {
        case .orderedAscending: return true
        case .orderedDescending: return false
        case .orderedSame: return a.id < b.id
        }
    }

    /// The shelf a book RESOLVES to: its pointer when that names a live
    /// shelf of the book's own wing, else nil (= unshelved — the dangling
    /// rule). `liveShelfIDs` is the set of the wing's live shelves.
    public static func resolvedShelf(of reading: Reading, liveShelfIDs: Set<String>) -> String? {
        guard let shelfID = reading.shelfId, liveShelfIDs.contains(shelfID) else { return nil }
        return shelfID
    }

    /// The "my order" SEQUENCE of one shelf's books (or the unshelved run):
    /// placed by `(shelf_position, id)`, then never-placed A–Z. Callers pass
    /// the books of ONE resolved shelf; the star is deliberately ignored.
    public static func placementSequence(_ readings: [Reading]) -> [Reading] {
        let placed = readings.filter { $0.shelfPosition != nil }.sorted {
            ($0.shelfPosition!, $0.id) < ($1.shelfPosition!, $1.id)
        }
        let unplaced = readings.filter { $0.shelfPosition == nil }.sorted {
            nameAscending(($0.name, $0.id), ($1.name, $1.id))
        }
        return placed + unplaced
    }

    /// Where a hand-placed book goes in its shelf's sequence.
    public enum Placement: Equatable, Sendable {
        /// Send to Top — the smallest position (§20).
        case top
        /// Send to Bottom — after every book, the never-placed ones included.
        case bottom
        /// Immediately before this book (the drag's drop target).
        case before(String)
    }

    /// **THE PLACEMENT ARITHMETIC** — the `shelf_position` writes that put
    /// `movingID` at `placement` in `sequence` (the shelf's whole my-order
    /// sequence, the moving book included). Returns nil when the anchor is
    /// not in the sequence (the caller refuses), and an EMPTY list when the
    /// book already sits exactly there (a no-op writes nothing).
    ///
    /// The one subtle case is a target inside the NEVER-PLACED run: a
    /// position always sorts before every NULL, so landing "before the third
    /// never-placed book" means first MATERIALIZING positions for the
    /// never-placed books ahead of it, in their current (A–Z) order — so the
    /// drop lands exactly where it was aimed and nothing it passed over
    /// moves. Send to Bottom materializes the whole never-placed run for the
    /// same reason (a position can only sit at the very end once nothing
    /// after it is NULL).
    ///
    /// Equal positions (two devices' jitter colliding — vanishingly rare,
    /// but `FractionalIndex.between` refuses `a == b`) are handled by taking
    /// the largest placed position STRICTLY below the anchor, the shared
    /// `listPosition` neighbour rule.
    public static func placementWrites(
        moving movingID: String, in sequence: [Reading], to placement: Placement,
        between: (String?, String?) -> String = FractionalIndex.between
    ) -> [(readingID: String, position: String)]? {
        let others = sequence.filter { $0.id != movingID }
        let target: Int
        switch placement {
        case .top: target = 0
        case .bottom: target = others.count
        case .before(let anchorID):
            guard anchorID != movingID,
                  let index = others.firstIndex(where: { $0.id == anchorID })
            else { return nil }
            target = index
        }
        // Already there: the book's own index in the full sequence IS the
        // target slot among the others (it sits right before what would
        // follow it). Nothing is written.
        if let current = sequence.firstIndex(where: { $0.id == movingID }), current == target {
            return []
        }
        let placedOthers = others.prefix { $0.shelfPosition != nil }
        let firstUnplaced = placedOthers.count
        if target < firstUnplaced {
            let upper = others[target].shelfPosition!
            // The strict-below neighbour (equal keys tolerated).
            let lower = placedOthers.compactMap(\.shelfPosition).filter { $0 < upper }.max()
            return [(movingID, between(lower, upper))]
        }
        // At or past the placed run's end: materialize the never-placed
        // books AHEAD of the target, then the mover after them.
        var writes: [(readingID: String, position: String)] = []
        var running = placedOthers.last?.shelfPosition
        for book in others[firstUnplaced..<target] {
            let next = between(running, nil)
            writes.append((book.id, next))
            running = next
        }
        writes.append((movingID, between(running, nil)))
        return writes
    }
}

/// **A SHELF'S GLYPH** (the sitting record §7 — *"optional, ONE GRAPHEME,
/// monochrome, inheriting the text's ink — the callout frame's ruled
/// precedent reused … No emoji, no color"*). Pure, so the op's refusal and
/// the sheet's live check are one rule.
public enum ShelfGlyph {
    /// The curated set the Set Glyph sheet offers (§7's working set — FEW and
    /// visually distinct at strip size; no cross, hers; hieroglyphs and the
    /// moon IN). Free Unicode entry beyond it goes through `normalize`.
    public static let curated = ["\u{263E}", "\u{2767}", "\u{2736}", "\u{25C6}",
                                 "\u{13080}", "\u{13153}", "\u{131A3}"]

    /// The stored form of what she typed: trimmed; empty = nil (no glyph);
    /// otherwise EXACTLY ONE grapheme with no emoji presentation — or nil
    /// with `valid == false` when it is not one.
    public static func normalize(_ raw: String?) -> (glyph: String?, valid: Bool) {
        let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return (nil, true) }
        guard trimmed.count == 1, let character = trimmed.first else { return (nil, false) }
        // "No emoji": a scalar that DEFAULTS to emoji presentation, or any
        // explicit emoji variation selector (U+FE0F), is a picture, not ink.
        // A text-presentation symbol (☾, ◆, ★) stays a glyph.
        let isEmoji = character.unicodeScalars.contains {
            $0.properties.isEmojiPresentation || $0.value == 0xFE0F
        }
        return isEmoji ? (nil, false) : (trimmed, true)
    }
}
