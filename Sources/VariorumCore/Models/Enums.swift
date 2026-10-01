import GRDB

/// Column vocabularies, mirroring the CHECK constraints in AppSpec §7 exactly.
/// `DatabaseValueConvertible` so they can appear directly in query filters.

public enum ContainerKind: String, Codable, Sendable, DatabaseValueConvertible {
    case post, pool
}

/// `container.profile` — a UI profile, never a data-model difference
/// (CoreDescription §8). `reading.profile` is a different, un-CHECKed
/// vocabulary and stays a plain string.
public enum Profile: String, Codable, Sendable, DatabaseValueConvertible {
    case journal, blog, bookChapter = "book_chapter", generic, pool
}

public enum VariantStatus: String, Codable, Sendable, DatabaseValueConvertible {
    case active, archived
}

public enum EdgeType: String, Codable, Sendable, DatabaseValueConvertible {
    case derivedFrom = "derived_from"
    case versionOf = "version_of"
}

public enum CommitKind: String, Codable, Sendable, DatabaseValueConvertible {
    case manual, auto
}

/// The 13i recast (sitting record §1, migrated at v1_18): a BOOK holds
/// membership rows as truth; a GATHERING is a saved rule assembled at read,
/// holding nothing. The old values ('curated','smart') exist in no live
/// store past v1_18 and in no mirror past the marker-10 window.
public enum ReadingKind: String, Codable, Sendable, DatabaseValueConvertible {
    case book, gathering
}

/// `reading_post.status` (13i-a, v1_18): a MEMBER is seated membership —
/// truth, ordered, counted by capacity; an ARRIVAL is intake's bell waiting
/// at the door (sitting record §4) — visible, synced, never rendered as a
/// member. Dismissing an arrival tombstones its row (tombstone-means-
/// decided); seating flips it to member and mints its position.
public enum MembershipStatus: String, Codable, Sendable, DatabaseValueConvertible {
    case member, arrival
}

/// `reading.intake_seating` — the per-book join dial (sitting record §4):
/// new matches join quietly at the end, or wait at Arrivals for judgment.
/// NULL on gatherings (they have no membership to seat).
public enum IntakeSeating: String, Codable, Sendable, DatabaseValueConvertible {
    case auto, arrivals
}

public enum SortField: String, Codable, Sendable, DatabaseValueConvertible {
    case manual
    case entryDate = "entry_date"
    case createdAt = "created_at"
    case lastTouched = "last_touched"
    case lastMajorRevision = "last_major_revision"
}

public enum SortDirection: String, Codable, Sendable, DatabaseValueConvertible {
    case asc, desc
}

public enum Segmentation: String, Codable, Sendable, DatabaseValueConvertible {
    case oneBlock = "one_block"
    case paragraph, sentence
}

public enum ReferenceKind: String, Codable, Sendable, DatabaseValueConvertible {
    case file, url
}

/// The fan-out appearance (Phase 11 kickoff spike, record item 1 — ALL
/// FOUR ship as a user SETTING: "different styles of use that are super
/// defensible"). Stored in the synced `setting` table under 'fan_style'
/// (document semantics, like segmentation — the same fan opens the same
/// way on every device); whichever style is set is what expand-all-fans
/// opens document-wide. Default 'stack' (build-time call, recorded in the
/// Phase 11 closeout — the closest kin of the shipped FanPanel).
public enum FanStyle: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    case stack
    case carousel
    case marginGrid = "margin_grid"
    case slotSplit = "slot_split"
}

/// The design VOICE (Phase 13, B1 — sitting ruling R1: TWO first-class
/// voices, tokens AND idioms, the Terminal voice leading and the Study
/// voice — the Phase 11 mockups' look — switchable; hold at exactly two,
/// R12). Stored in the synced `setting` table under 'theme_voice'
/// (document semantics, the fan_style class). The voice carries the token
/// set AND the idiom slots — the app-side theme layer resolves both;
/// nothing here stores rendering.
public enum ThemeVoice: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    case terminal
    case study
}

/// **THE COLOUR PALETTE, LAYERED UNDER THE VOICE** (the 2026-09-12
/// use-report round, 18g — her rulings R-Q6 · R-Q11 · R-Q13, from the
/// report: *"I need basic color themes that also update the lightly
/// colored text like (this note) and commit. I want at least lavender,
/// mint green, pink, blue, a pastel set. and maybe the ability to choose
/// the hex code of your default theme (should recolor the tan panels
/// basically) and the text that is going on top of those panels."*).
///
/// **A palette is NOT a third voice — R1/R12 hold at exactly two.** The
/// voice keeps everything that makes it a voice: its type (Study's serif,
/// Terminal's mono), its idioms (the `›` marker, `~/` path grammar, the
/// lowercased chrome, the blinking block cursor), and every token the
/// palette does not name. What a palette replaces is one derived FAMILY of
/// colours — the room (her "tan panels"), the wash, the accent (her
/// "lightly colored text like (this note) and commit"), the take tint and
/// its hairline — computed from one or two seed hues by ONE pure rule in
/// the app layer (`PaletteDerivation`). R1's *"never a palette swap"* was
/// about a voice being MORE than colours; a palette UNDER a voice keeps
/// that exactly true.
///
/// **Core knows the NAMES; the app knows the colours.** There is no hex in
/// this file on purpose: a seed pair and its intensity are design data that
/// belongs beside the token layer, and the stored value must stay a small
/// enum token for the reason below.
///
/// Stored in the synced `setting` table under `theme_palette` (document
/// semantics, the `theme_voice`/`fan_style` class — the same store looks
/// the same on every device; her R-Q6 asks for it synced). **E2EE-clean by
/// construction:** one enum token, never prose, so `setting.value`'s PLAIN
/// classification and its column-fenced disclosure promise (AppSpec §7, the
/// 14b ladder's R1-9) hold unchanged. No schema, no migration, no SyncSpec
/// §12 lockstep event — a `setting` key is upsert-only.
///
/// `custom` reads its seeds from `theme_tint` (the room) and, optionally,
/// `theme_accent_tint` (the accent) — six hex digits each, validated by the
/// one rule `ThemeTint`. A `custom` palette whose room seed is absent or
/// malformed resolves as `default`: a palette can never leave the app
/// half-coloured.
public enum ThemePalette: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    /// Each voice's shipped colours, byte-identical. The default, and the
    /// parity proof the token pins ride (`ThemeTokenTests`).
    case `default`

    // ── The four PASTELS (her R-Q11: *"yeah those look good, I like
    // those. I want them included."*). ONE seed: the accent is the same
    // hue, deepened.
    case lavender
    case mint
    case pink
    case blue

    // ── The six TWO-TONE builds (her R-Q11: *"a couple mixed color
    // builds, like how terminal has tan and blue… like gold and black"*,
    // then *"i'd do a light grey one with red or something too"* amended
    // to *"light grey & green"*). TWO seeds: a room hue and an accent hue.
    // Each is a LIGHT theme with two hues — her clarification: the black
    // strip in the mockup was the dark-mode preview, never part of them.
    case goldAndBlack = "gold_black"
    case sageAndTerracotta = "sage_terracotta"
    case slateAndAmber = "slate_amber"
    case plumAndCream = "plum_cream"
    case inkAndCoral = "ink_coral"
    case greyAndGreen = "grey_green"

    // ── The five BOLD builds (her R-Q11: *"the color themes don't also
    // have to be so pastel, you can add a little more personality to them.
    // or add a third batch"*). The same two-seed rule at the deeper
    // intensity table — still light themes.
    case cobaltAndTangerine = "cobalt_tangerine"
    case peachAndIndigo = "peach_indigo"
    case butterAndCobalt = "butter_cobalt"
    case roseAndMoss = "rose_moss"
    case tealAndRust = "teal_rust"

    /// Her own hex (R-Q13: *"I can also still put in one hex and what's
    /// the 'brain' that'll take care of the second value?"*) — ONE seed,
    /// with an optional second for the accent. The same brain, fed her
    /// colour.
    case custom
}

/// The editing-indicator setting (Phase 13 — rulings R14/R22, ratified
/// sitting 4): how the block being EDITED is marked in the plain editor.
/// OFF is the default ("sometimes people don't even want to see what
/// block they're editing"); cursor-only is legitimate. Marginalia keeps
/// its own always-on wash+ring rule regardless (R22's letter).
public enum EditingIndicatorStyle: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    case off
    case outline
    case background
}

/// **How a RECEIPT shows itself** (the 2026-09-12 use-report round, 18i —
/// her ruling R-Q5, from the report: *"there's these little text confirmation
/// popups that are always appearing… i either need them off, more subtle in
/// the bottom bar in more muted text, or a setting if i can turn it on or
/// off. maybe the setting is the best option?… i don't always need it less
/// noticable because for some operations it's the right confirmation text to
/// show."* — and her call on the default: *"Quiet should be the default, but
/// toast should still be an option"*).
///
/// It governs **RECEIPTS ONLY** — the after-the-fact confirmations of an act
/// that LANDED ("Blocks joined — ⌥⌘Z undoes it.", "Block divided", the
/// newlines chip's sentence). **A REFUSAL and an OFFER always show as the
/// toast, under every value here**, because a door that could not act must
/// deliver the operations layer's real refusal (P-2, fire-and-DO) and an
/// offer carries a button she has to be able to press. The app-side seam
/// (`StatusCenter`) is where the three kinds live; this enum is only the
/// stored answer to "what does a receipt do".
///
/// Stored in the synced `setting` table under `receipt_style` (document
/// semantics, the `fan_style`/`savepoint_cadence` class — the same act
/// confirms the same way on every device). **E2EE-clean by construction:**
/// three enum tokens, never prose, so `setting.value`'s PLAIN classification
/// and its column-fenced disclosure promise (AppSpec §7, the 14b ladder's
/// R1-9) hold unchanged. No schema, no migration, no §12 lockstep event —
/// a setting key is upsert-only.
public enum ReceiptStyle: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    /// What every receipt did before 18i: the shell's status toast.
    case toast
    /// **Her default**: a muted line at the bottom bar's trailing end,
    /// fading on the same clock the toast uses.
    case quiet
    /// Nothing at all. Refusals and offers still toast.
    case off
}

/// **The savepoint cadence** (Phase 13j, J11 — her sitting-round-1 ruling:
/// *"ONE simple setting"*, after her observation that *"unless you've been
/// remembering to commit version history is kind of weak right now"*).
///
/// Stored in the synced `setting` table under `savepoint_cadence` (document
/// semantics, the `fan_style`/`default_segmentation` class — the same note
/// keeps the same history habits on every device). **E2EE-clean by
/// construction:** the value is one of three enum tokens, never prose, so
/// `setting.value`'s PLAIN classification and its column-fenced disclosure
/// promise (AppSpec §7, the 14b ladder's R1-9) hold unchanged.
///
/// **It governs exactly TWO occasions — the CADENCE ones — and no others.**
/// The quiet auto-commits that exist to INSURE something about to become
/// unreachable (sealing a post, locking a dirty take, a structural undo about
/// to overwrite an edited buffer — OverallModel §3) are not a cadence and stay on in every mode. Two booleans rather than
/// per-call-site `switch`es, so a third occasion can never quietly acquire a
/// fourth reading of the same enum.
public enum SavepointCadence: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    /// Her default: a savepoint per changed take when a note stops being
    /// the open one, plus the idle backstop for notes left open.
    case everySession = "every_session"
    /// The backstop alone — nothing at close.
    case idleOnly = "idle_only"
    /// Neither. ⌘S (and the insurance occasions) are all that write.
    case onlyOnCommit = "only_on_commit"

    /// Does leaving a note leave a savepoint behind?
    public var savesOnLeaving: Bool { self == .everySession }

    /// Does the long-idle sweep still insure a note left open?
    public var savesWhenIdle: Bool { self != .onlyOnCommit }
}

/// **History pruning** (Phase 13j batch 6b — her round-9 ruling: the 90-day
/// / keep-10 default *"plus a user setting with a 'Never prune' choice. it
/// might be important for some users"*).
///
/// Stored in the synced `setting` table under `history_pruning` (document
/// semantics, the `savepoint_cadence` class — one answer on every device,
/// which is what makes "Never means never on every device" true, memo §4d).
/// **E2EE-clean by construction:** two enum tokens, never prose, so
/// `setting.value`'s PLAIN classification and its column-fenced disclosure
/// promise hold unchanged.
///
/// It governs exactly one thing: whether the purge janitor MINTS savepoint
/// purge intents (`SavepointPruning` is the brain; deliberate ⌘S commits
/// are never prunable in either mode). Intents already minted — by this
/// device earlier, or pulled from a peer — are honored regardless: an
/// instruction that traveled is a fact, not a preference.
public enum HistoryPruning: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    /// Her default: quiet savepoints older than 90 days prune down to the
    /// newest 10 per take.
    case standard
    /// Prune nothing, ever.
    case never
}
