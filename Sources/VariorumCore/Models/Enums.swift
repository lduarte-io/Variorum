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

public enum ReadingKind: String, Codable, Sendable, DatabaseValueConvertible {
    case curated, smart
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
