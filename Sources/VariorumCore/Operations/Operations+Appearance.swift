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

    /// **18i (her ruling R-Q5): how a RECEIPT shows itself** — toast (what
    /// every receipt did before), quiet (her default: the bottom bar's muted
    /// line), or off. Refusals and offers are untouched by it and always
    /// toast; `ReceiptStyle` carries the whole reasoning, including why the
    /// value is E2EE-clean.
    ///
    /// Synced document semantics like every other `setting` row here
    /// (upsert-only, never tombstoned — the `fan_style` class). Zero schema,
    /// so no §12 lockstep event: the marker stays where it is.
    public func setReceiptStyle(_ style: ReceiptStyle) throws {
        try database.write { db in
            try upsertSetting(db, key: "receipt_style", value: style.rawValue)
        }
    }

    // MARK: - The colour palette (18g — her R-Q6 · R-Q11 · R-Q13)

    /// **The palette layered UNDER the voice** (`ThemePalette` carries the
    /// whole reasoning, including why this is not a third voice). Synced
    /// document semantics like every other `setting` row here (upsert-only,
    /// never tombstoned — the `theme_voice` class); zero schema, so no
    /// SyncSpec §12 lockstep event and the marker stays where it is.
    public func setThemePalette(_ palette: ThemePalette) throws {
        try database.write { db in
            try upsertSetting(db, key: "theme_palette", value: palette.rawValue)
        }
    }

    /// **The `custom` palette's seeds** (her R-Q13: *"Custom = ONE hex,
    /// with an optional second"*) — the room hue and, optionally, the
    /// accent hue.
    ///
    /// Both go through the ONE rule (`ThemeTint`): a value that is not six
    /// hex digits REFUSES the whole write (`invalidTint`) rather than
    /// landing a colour nobody can name — the door fires and delivers the
    /// operations layer's real refusal (P-2), and the face shows its words.
    /// `nil` CLEARS, and a cleared seed is the empty string because a
    /// `setting` row is upsert-only and never tombstoned; the read side
    /// turns it back into absence through the same rule.
    ///
    /// One transaction for both, so the pair can never land half-written —
    /// a room with a stale accent from the colour before it is exactly the
    /// state the derivation could not explain.
    public func setThemeTints(room: String?, accent: String?) throws {
        let roomValue = try normalizedTint(room)
        let accentValue = try normalizedTint(accent)
        try database.write { db in
            try upsertSetting(db, key: "theme_tint", value: roomValue)
            try upsertSetting(db, key: "theme_accent_tint", value: accentValue)
        }
    }

    /// nil clears; a colour normalizes; anything else refuses. Outside the
    /// transaction on purpose — nothing is written when either half is bad.
    private func normalizedTint(_ raw: String?) throws -> String {
        guard let raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ThemeTint.cleared
        }
        guard let normalized = ThemeTint.normalize(raw) else {
            throw OperationError.invalidTint(value: raw)
        }
        return normalized
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

    // MARK: - The savepoint cadence (13j, J11)

    /// The ONE cadence setting (her sitting-round-1 ruling: *"a single
    /// enum-valued setting… Not full knobs; not settingless"*). Synced
    /// document semantics like every other `setting` row, and E2EE-clean by
    /// its enum values (`SavepointCadence` carries the reasoning).
    ///
    /// It governs the two CADENCE occasions only —
    /// `Operations.closeAutoCommit` and `Operations.idleAutoCommit`, each of
    /// which reads it inside its own transaction. The insurance occasions
    /// (post-seal, locking a dirty take, structural-undo divergence) are
    /// deliberately NOT governed by it and stay on in every
    /// mode; the setting's help copy says so, because a setting that reads
    /// as "stop making savepoints" while savepoints still happen is exactly
    /// the copy-truth defect this phase is about.
    public func setSavepointCadence(_ cadence: SavepointCadence) throws {
        try database.write { db in
            try upsertSetting(db, key: "savepoint_cadence", value: cadence.rawValue)
        }
    }

    /// **History pruning** (Phase 13j batch 6b — her round-9 ruling: the
    /// Standard/Never pair beside the cadence setting). Synced document
    /// semantics, E2EE-clean by its enum values (`HistoryPruning` carries
    /// the reasoning). Governs MINTING only — the purge janitor consults it
    /// before writing any savepoint purge intent; intents already minted
    /// (or pulled from a peer) are honored regardless, and deliberate ⌘S
    /// commits are never prunable in either mode.
    public func setHistoryPruning(_ pruning: HistoryPruning) throws {
        try database.write { db in
            try upsertSetting(db, key: "history_pruning", value: pruning.rawValue)
        }
    }

    // MARK: - Shelf pins (R38)

    /// Pins a book to the shelf's top (appended to pin order); unpinning
    /// removes it. Idempotent both ways. The list is canonical JSON so
    /// equal pin states are byte-equal under CAS.
    public func setShelfPinned(_ readingID: String, pinned: Bool) throws {
        try database.write { db in
            _ = try liveReading(db, readingID)
            try setShelfPinned(db, readingID, pinned: pinned)
        }
    }

    /// The pin write itself, at db level, so a caller already inside a write
    /// transaction shares the ONE implementation instead of copying it
    /// (13d batch 5 — the daily book's create-and-pin ensure). The liveness
    /// check stays with the public door: an in-transaction caller has just
    /// inserted the reading it is pinning.
    func setShelfPinned(_ db: Database, _ readingID: String, pinned: Bool) throws {
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

    // MARK: - Stars (13f W4)

    /// How many things may be starred at once — her ruling's number
    /// (raised 5 → 15 at her 2026-09-18 ruling on QUESTIONS #112(b),
    /// "scroll should be allowed, maybe 15 items max" — superseding 13f
    /// W4's "up to 5"; the Starred section scrolls past its window of 7).
    /// Public so a face can name it without re-stating it (and so the
    /// refusal below carries it rather than hard-coding a word).
    public static let starLimit = 15

    /// Star or un-star a note or a book (13f W4 — her round-3 ruling).
    /// Stars are a synced `setting` list in STAR ORDER, exactly the
    /// `shelf_pins` shape: ZERO schema, no §12 lockstep event, plain
    /// metadata CAS.
    ///
    /// Three rules, all of them visible in the body:
    ///
    /// 1. **Star time is the order** — a new star is APPENDED, so the
    ///    section reads in the order she starred things.
    /// 2. **THE CAP REFUSES HONESTLY** (`starLimitReached`) rather than
    ///    silently dropping the oldest star. P-2: the door fires and
    ///    delivers the operations layer's real refusal, and the refusal
    ///    names un-starring as the road (`OpsRefusalCopy`).
    /// 3. **EVERY WRITE SELF-HEALS.** It rewrites the list `Queries.starred`
    ///    would return — i.e. live targets only — so a star whose note or
    ///    book was deleted disappears from the stored value the next time
    ///    she stars anything. That is what keeps the CAP honest: it counts
    ///    exactly the stars she can see, never ghosts she cannot un-star.
    ///
    /// Idempotent both ways, and a write that changes nothing writes
    /// nothing — no `updated_at`, no outbox row (the identity-metadata
    /// convention `setBlockName` established).
    public func setStarred(_ target: StarTarget, starred: Bool) throws {
        try database.write { db in
            let stored = try Queries.starredTargets(db)
            // The live list — and the ONE rule the read side states, so the
            // cap and the section can never disagree about what is starred.
            var next = try Queries.starred(db).map(\.target)
            if starred {
                if !next.contains(target) {
                    guard try starTargetIsLive(db, target) else {
                        throw target.kind == .post
                            ? OperationError.containerNotFound(id: target.id)
                            : OperationError.readingNotFound(id: target.id)
                    }
                    guard next.count < Self.starLimit else {
                        throw OperationError.starLimitReached(limit: Self.starLimit)
                    }
                    next.append(target)
                }
            } else {
                next.removeAll { $0 == target }
            }
            // Un-starring a target that has since died is not a no-op: the
            // list still loses it here, because `next` is already the
            // pruned one. The guard is on the VALUE, so nothing is written
            // when nothing changed.
            guard next != stored else { return }
            let json = String(decoding: try JSONEncoder().encode(next.map(\.key)), as: UTF8.self)
            try upsertSetting(db, key: "starred", value: json)
        }
    }

    /// Is this star's target a live note or book? The `liveReading` guard's
    /// shape, over the two kinds a star can point at.
    private func starTargetIsLive(_ db: Database, _ target: StarTarget) throws -> Bool {
        switch target.kind {
        case .post:
            return try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (
                      SELECT 1 FROM container
                      WHERE id = ? AND kind = 'post' AND deleted_at IS NULL)
                    """,
                arguments: [target.id]) ?? false
        case .reading:
            return try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM reading WHERE id = ? AND deleted_at IS NULL)",
                arguments: [target.id]) ?? false
        }
    }

    /// Designates THE daily journal book (Phase 13 B3, PROVISIONAL — the
    /// R50 binding's Mac shape: "Today's Entry" ensures membership here;
    /// the one-entry-per-day rule stays the DAILY door's and is untouched).
    public func setDailyJournalBook(_ readingID: String) throws {
        try database.write { db in
            _ = try liveReading(db, readingID)
            try setDailyJournalBook(db, readingID)
        }
    }

    /// The designation write at db level — same reason as `setShelfPinned`'s
    /// twin above (13d batch 5).
    func setDailyJournalBook(_ db: Database, _ readingID: String) throws {
        try upsertSetting(db, key: "daily_journal_book", value: readingID)
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
