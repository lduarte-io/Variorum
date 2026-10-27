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

    /// **18l-c U8 (her R-18l-7): the mode-switch ARRIVAL FLASH, on or off** —
    /// *"you should also be able to turn this flash where your cursor is
    /// setting off, but it should default to on."* The `receipt_style`
    /// precedent exactly: synced document semantics (upsert-only, never
    /// tombstoned — the same switch on every device), the default resolved at
    /// READ time (no seed — `Queries.ThemeSettings.arrivalFlash`), and a
    /// value that is a token ("1"/"0"), never prose, so `setting.value`'s
    /// PLAIN classification (AppSpec §7, the 14b constraint) holds. Zero
    /// schema, so no SyncSpec §12 lockstep event: the marker stays where it is.
    public func setArrivalFlash(_ on: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "arrival_flash", value: on ? "1" : "0")
        }
    }

    /// **13i-c U2 — the GLOBAL hide-owned default** (the sitting record §6:
    /// "the HIDE-OWNED toggle is the release valve: per-gathering + a global
    /// default, scope = gathering assemblies, tag listings, search; Library
    /// EXEMPT"). The `arrival_flash` precedent exactly: synced document
    /// semantics (upsert-only, never tombstoned), the default — SHOW —
    /// resolved at READ time (`Queries.ThemeSettings.hideOwnedByDefault`),
    /// a token value ("1"/"0"), zero schema.
    public func setHideOwnedDefault(_ hide: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "hide_owned_default", value: hide ? "1" : "0")
        }
    }

    /// **13i-c U2 — the ownership BADGE family's one switch** (§6 — "toggleable
    /// as a set"; PROVISIONAL P-13ic-10: synced, the `arrival_flash` class).
    /// ON by default, resolved at read (`ThemeSettings.ownershipBadges`).
    public func setOwnershipBadges(_ on: Bool) throws {
        try database.write { db in
            try upsertSetting(db, key: "ownership_badges", value: on ? "1" : "0")
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
    ///
    /// **PINNING needs a live book; UNPINNING never does** (18o U1, 17e P35):
    /// the liveness check guards the pin alone, so the pin of a book that has
    /// since been deleted can always be taken off — it used to refuse
    /// `readingNotFound` forever.
    ///
    /// **13i-d U2 ACT 0 — A PIN IS A STAR** (F-U1-2 (A), ruled: "`setShelfPinned`
    /// routes through the same write"): this door IS `setStarred(.reading)` —
    /// both stores, the cap, the self-heal. The phone's "Pin to Shelf Top"
    /// keeps its words until its catch-up and writes the same truth (so it
    /// now refuses at the cap like every star door, naming un-starring).
    public func setShelfPinned(_ readingID: String, pinned: Bool) throws {
        try setStarred(.reading(readingID), starred: pinned)
    }

    /// The pin write at db level, so a caller already inside a write
    /// transaction shares the ONE implementation instead of copying it
    /// (13d batch 5 — the daily book's create-and-pin ensure; the
    /// Quicknotes mint). An in-transaction caller has just inserted the
    /// reading it is pinning (live by then).
    ///
    /// **13i-d U2 ACT 0:** it routes through the ONE star write — both
    /// stores — and is EXEMPT from the cap's refusal (PROVISIONAL
    /// P-13id-U2-1): her R-13id-5 keeps the daily Journal and Quicknotes
    /// BORN STARRED, and a mint must never fail on a star. The book counts
    /// toward the cap thereafter like any star. The name survives until
    /// 13i-d's vocabulary sweep.
    func setShelfPinned(_ db: Database, _ readingID: String, pinned: Bool) throws {
        try writeStar(db, .reading(readingID), starred: pinned, enforcingCap: false)
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
    ///
    /// **13i-d U2 ACT 0 — THE UNION STAR** (F-U1-2 (A), ruled; the sitting
    /// record §7's "one mechanism"): a BOOK's star is also its
    /// `reading.starred` column (the Bookcase's float). Every star write on a
    /// reading writes BOTH stores in this one transaction, and un-starring
    /// clears both; the cap counts the union (`Queries.starred` — the list
    /// plus the column-only tail). See `writeStar`.
    public func setStarred(_ target: StarTarget, starred: Bool) throws {
        try database.write { db in
            try writeStar(db, target, starred: starred, enforcingCap: true)
        }
    }

    /// **THE ONE STAR WRITE** (13i-d U2 ACT 0), at db level so the
    /// in-transaction mints share it (`setShelfPinned(_:_:pinned:)`).
    /// `enforcingCap` is false only for those born-starred mints
    /// (PROVISIONAL P-13id-U2-1 — a mint never fails on a star).
    ///
    /// **VX-596 — the MCP undo's two parameters** (`Operations+MCPStars`; every
    /// other caller keeps both defaults, byte-unchanged): `position` puts a NEW
    /// list entry back at that place in star order (clamped) instead of the
    /// end — an un-star's undo returns the row where it stood; `heard: false`
    /// keeps intake from hearing a note's star — a replay's exact revival is
    /// no applying act (`apply_tag`'s replay doctrine: it seats nothing).
    func writeStar(
        _ db: Database, _ target: StarTarget, starred: Bool, enforcingCap: Bool,
        at position: Int? = nil, heard: Bool = true
    ) throws {
        let stored = try Queries.starredTargets(db)
        // The LIST's live entries — what the self-heal persists (a dead
        // entry leaves the stored value at the next write).
        var next = try Queries.starredListItems(db).map(\.target)
        // 13i-b U1: starring a NOTE is an applying act — it fires intake
        // on every living book whose rule carries a star term, once the
        // list below is written. Un-starring is a NON-EVENT (§19, ratified
        // §24): it never evicts a member.
        var starsANote = false
        if starred {
            // The UNION — the ONE rule the read side states, so the cap and
            // the section can never disagree about what is starred. A target
            // already in it (by either store) is already counted.
            let union = try Queries.starred(db).map(\.target)
            if !union.contains(target) {
                guard try starTargetIsLive(db, target) else {
                    throw target.kind == .post
                        ? OperationError.containerNotFound(id: target.id)
                        : OperationError.readingNotFound(id: target.id)
                }
                if enforcingCap, union.count >= Self.starLimit {
                    throw OperationError.starLimitReached(limit: Self.starLimit)
                }
                starsANote = target.kind == .post
            }
            // Both stores: a column-only book gains its list entry (its star
            // TIME is now — the section's order from here on). VX-596: at
            // `position` when a replay puts a star back where it stood.
            if !next.contains(target) {
                if let position {
                    next.insert(target, at: min(max(position, 0), next.count))
                } else {
                    next.append(target)
                }
            }
        } else {
            next.removeAll { $0 == target }
        }
        // The COLUMN half (a reading's only). Live rows only: un-starring a
        // dead book leaves its tombstoned row's flag alone, so a restore
        // still brings the star back with the row (13i-a's upgrade, kept).
        // The `<>` guard keeps a no-op from writing a row or an outbox entry.
        if target.kind == .reading {
            try db.execute(
                sql: """
                    UPDATE reading SET starred = ?
                    WHERE id = ? AND deleted_at IS NULL AND starred <> ?
                    """,
                arguments: [starred, target.id, starred])
        }
        // Un-starring a target that has since died is not a no-op: the
        // list still loses it here, because `next` is already the
        // pruned one. The guard is on the VALUE, so nothing is written
        // when nothing changed.
        guard next != stored else { return }
        let json = String(decoding: try JSONEncoder().encode(next.map(\.key)), as: UTF8.self)
        try upsertSetting(db, key: "starred", value: json)
        if starsANote, heard {
            try intakeAfterStarring(db, postID: target.id, now: date.now)
        }
    }

    /// Is this star's target a live note or book? The `liveReading` guard's
    /// shape, over the two kinds a star can point at. (VX-596: internal — the
    /// MCP star replays ask it before putting a star back.)
    func starTargetIsLive(_ db: Database, _ target: StarTarget) throws -> Bool {
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
    ///
    /// **13i-d U5 — HOME-ONLY (#169(b), RULED; KnownIssues row 105's
    /// mechanism):** a book of ANOTHER wing refuses
    /// (`dailyJournalIsHomeOnly`). ⌘J / Today's Entry mint the day's entry in
    /// Home, so a designation in another wing would put Home's entries into
    /// that wing's book — a membership across libraries (§9), which the
    /// membership guard now refuses anyway; this keeps the designation itself
    /// honest at the door.
    public func setDailyJournalBook(_ readingID: String) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard try sameEffectiveWing(db, reading.wingId, "") else {
                throw OperationError.dailyJournalIsHomeOnly(id: readingID)
            }
            try setDailyJournalBook(db, readingID)
        }
    }

    /// The designation write at db level — same reason as `setShelfPinned`'s
    /// twin above (13d batch 5).
    ///
    /// **13i-a (ladder R1 M-3): the 'daily' MARKER moves WITH the
    /// designation, in the same transaction.** The marker is the identity
    /// (the memo §3 — the keeper repair, `isDailyJournalMintShape` and the
    /// constitutive-trait refusal all key on it), so a re-designation that
    /// moved only the setting left a STALE marker-bearer behind — and a
    /// later dangling-designation mint would then put TWO marker-bearing
    /// books in front of the keeper repair, which would MERGE them (the F6
    /// class re-opened through staleness). Every OTHER live 'daily' row
    /// demotes to the journal TRAIT it was wearing as the daily book; the
    /// live designee gains 'daily' (whatever profile it wore — designating
    /// a book MAKES it the daily Journal, trait included). Ordinary CAS
    /// metadata writes; outbox via the live triggers (this runs outside
    /// apply).
    ///
    /// **13i-e U2 ACT 0 (the architect's F-U1-2 ruling): a NON-BOOK refuses**
    /// (`wrongReadingKind`), ahead of every write — the daily Journal IS a
    /// book wearing the marker (`isDailyJournalMintShape`), so designating a
    /// gathering used to demote the live Journal, stamp a marker the identity
    /// ignores, and let the next ⌘J mint a second Journal beside the first.
    ///
    /// **13i-e ladder round 1 (F-R1-1): a DEAD or MISSING designee refuses
    /// too** (`readingNotFound` — the public door's own word), ahead of every
    /// write: the demote UPDATE strips every live marker-bearer while the
    /// stamp UPDATE filters `deleted_at IS NULL`, so a dead designee would
    /// leave NO live marker-bearer and a dangling cache — the F-U1-2
    /// double-mint through the liveness door. Together the two guards keep
    /// ACT 0's whole promise at the db level: no caller, present or future,
    /// can demote the live daily Journal against a designee that cannot be
    /// stamped.
    func setDailyJournalBook(_ db: Database, _ readingID: String) throws {
        guard let kind = try String.fetchOne(
            db, sql: "SELECT kind FROM reading WHERE id = ? AND deleted_at IS NULL",
            arguments: [readingID])
        else { throw OperationError.readingNotFound(id: readingID) }
        guard kind == ReadingKind.book.rawValue else {
            throw OperationError.wrongReadingKind(id: readingID, expected: .book)
        }
        try db.execute(
            sql: """
                UPDATE reading SET profile = ?
                WHERE profile = ? AND id <> ? AND deleted_at IS NULL
                """,
            arguments: [Queries.journalTraitProfile, Queries.dailyJournalBookProfile, readingID])
        try db.execute(
            sql: """
                UPDATE reading SET profile = ?
                WHERE id = ? AND deleted_at IS NULL AND profile IS NOT ?
                """,
            arguments: [Queries.dailyJournalBookProfile, readingID,
                        Queries.dailyJournalBookProfile])
        try upsertSetting(db, key: "daily_journal_book", value: readingID)
    }

    /// The designated daily book, read THROUGH the operations seam so the
    /// ensure-membership door can check-and-act inside ONE runner-serialized
    /// sequence (Stage B review round 2, MINOR: a pre-runner read let two
    /// rapid Today's-Entry invocations both see nil and mint two "Journal"
    /// books). Since 13i-e the answer is DERIVED from the 'daily' marker
    /// (`Queries.dailyJournalBookID` — the live marker-bearer, archived
    /// included); no live marker-bearer reads as nil.
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
