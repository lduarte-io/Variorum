import Dependencies
import Foundation
import GRDB

// The Phase 13 appearance settings (Step B1 — the sittings' global
// settings): voice (R1/R12), seam visibility (R42 — "a global setting for
// now"), the editing indicator (R14/R22), inline comments (R7 — the
// terminal idiom "as a setting"), and follow-the-scroll (R25 — a
// takes-viewing option in ALL modes). All live in the synced `setting`
// table (document semantics, upsert-only, never tombstoned — the
// fan_style/segmentation class); the theme layer reads them through
// `Queries.themeSettings`.
//
// Shelf pins (R38 — "pinning is a general shelf mechanism"; the Journal
// pinned INTO the shelf) live under 'shelf_pins' as a canonical JSON array
// of reading IDs, in pin order. Plain metadata CAS: a two-device pin race
// converges to either list, never corruption.
extension Operations {
    public func setThemeVoice(_ voice: ThemeVoice) throws {
        try database.write { db in
            try upsertSetting(db, key: "theme_voice", value: voice.rawValue)
        }
    }

    /// R42: the seam-visibility toggle is GLOBAL for now. §12's
    /// boundaries-invisible-at-rest holds — this is the on-demand door.
    public func setSeamsVisible(_ visible: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "seams_visible", value: visible ? "1" : "0")
        }
    }

    public func setEditingIndicator(_ style: EditingIndicatorStyle) throws {
        try database.write { db in
            try upsertSetting(db, key: "editing_indicator", value: style.rawValue)
        }
    }

    /// R7: margin is the ruling; the inline-tinted comment is the offered
    /// setting ("can that be a setting?").
    public func setInlineComments(_ inline: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "inline_comments", value: inline ? "1" : "0")
        }
    }

    /// R25: follow-the-scroll as a takes-viewing OPTION in all modes
    /// ("that is an excellent idea!! for all the different modes").
    public func setFollowTheScroll(_ follows: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "follow_the_scroll", value: follows ? "1" : "0")
        }
    }

    /// The DOCUMENT-GLOBAL segmentation default (`default_segmentation` —
    /// AppSpec §7's seed, 'paragraph'): what fresh text does in every post
    /// that carries no per-post override. 13d batch 4 (her A16); 13b's 4D
    /// built the per-post face and recorded the exact blocker for this one
    /// — "no public `default_segmentation` setter exists; `upsertSetting`
    /// is Operations-internal". This is that setter and nothing more.
    ///
    /// **No semantics change, anywhere.** The value has been read since
    /// Phase 7 (`Queries.containerHeader.effectiveSegmentation` resolves
    /// per-post override → this setting → `.paragraph`), and `one_block`
    /// has always been ENTRY-WIDE — typing and paste alike (S4-21's
    /// ratification). Per-post `segmentation_default` is untouched and
    /// still wins where it is set.
    ///
    /// Synced document semantics like every other `setting` row
    /// (upsert-only, never tombstoned, ordinary outbox ride — the
    /// fan_style class).
    public func setDefaultSegmentation(_ segmentation: Segmentation) throws {
        try database.write { db in
            try upsertSetting(db, key: "default_segmentation", value: segmentation.rawValue)
        }
    }

    // MARK: - Shelf pins (R38)

    /// Pins a book to the shelf's top (appended to pin order); unpinning
    /// removes it. Idempotent both ways. The list is canonical JSON so
    /// equal pin states are byte-equal under CAS.
    public func setShelfPinned(_ readingID: String, pinned: Bool) throws {
        try database.write { db in
            _ = try liveReading(db, readingID)
            var pins = try Queries.shelfPins(db)
            if pinned {
                guard !pins.contains(readingID) else { return }
                pins.append(readingID)
            } else {
                guard pins.contains(readingID) else { return }
                pins.removeAll { $0 == readingID }
            }
            let encoder = JSONEncoder()
            let json = String(decoding: try encoder.encode(pins), as: UTF8.self)
            try upsertSetting(db, key: "shelf_pins", value: json)
        }
    }

    /// Designates THE daily journal book (Phase 13 B3, PROVISIONAL — the
    /// R50 binding's Mac shape: "Today's Entry" ensures membership here;
    /// the one-entry-per-day rule stays the DAILY door's and is untouched).
    public func setDailyJournalBook(_ readingID: String) throws {
        try database.write { db in
            _ = try liveReading(db, readingID)
            try upsertSetting(db, key: "daily_journal_book", value: readingID)
        }
    }

    /// The designated daily book, read THROUGH the operations seam so the
    /// ensure-membership door can check-and-act inside ONE runner-serialized
    /// sequence (Stage B review round 2, MINOR: a pre-runner read let two
    /// rapid Today's-Entry invocations both see nil and mint two "Journal"
    /// books). Dangling designations read as nil (the fallback class).
    public func dailyJournalBookID() throws -> String? {
        try database.read { try Queries.dailyJournalBookID($0) }
    }

    /// The designated daily book's display name — the ensure door's
    /// speaking notes name the book they couldn't add to.
    public func dailyJournalBookName() throws -> String? {
        guard let id = try dailyJournalBookID() else { return nil }
        return try database.read { try Queries.reading($0, id: id)?.name }
    }

    // MARK: - The one upsert shape

    /// UPDATE-then-INSERT, never `INSERT OR REPLACE`: an outer ON CONFLICT
    /// clause overrides the conflict handling INSIDE trigger bodies (SQLite
    /// semantics), which would break the outbox trigger's coalescing — the
    /// `setFanStyle` pattern, shared from here on.
    func upsertSetting(_ db: Database, key: String, value: String) throws {
        try db.execute(
            sql: "UPDATE setting SET value = ? WHERE key = ?",
            arguments: [value, key])
        if db.changesCount == 0 {
            try db.execute(
                sql: "INSERT INTO setting (key, value) VALUES (?, ?)",
                arguments: [key, value])
        }
    }
}
