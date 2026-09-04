import Foundation

/// **WHAT A NOTE IS CALLED ON SCREEN** — Phase 13g, batch 7 (her ruling
/// R6-3, and the refinement she added with it, verbatim: *"I think a display
/// rule is fine - but maybe it should be preserved on export? someone might
/// be frustrated exporting a note with a date they see as a title and then
/// their exported note says 'Untitled'."*).
///
/// Her want, in her words: *"we should maybe just make 'Untitled' save with
/// the actual date as the name - I think it looks nicer and then even if
/// someone never titles things, it's more of a log look than 500 untitled
/// things … i do think you sohuld be able to rename it from the date, but
/// auto date name is better than just 'Untitled' … i don't want the title
/// to feel too forced."*
///
/// ── IT IS A DISPLAY RULE, NEVER A WRITE ─────────────────────────────────
/// The date is **never** written into `container.title`. Nothing is stored,
/// nothing is copied (the no-denormalization rule), and renaming edits the
/// real title exactly as it always did — which is what makes this fix every
/// EXISTING untitled note for free rather than only the ones minted from
/// now on. `renderedText` and the export BODY projections are untouched by
/// construction: a title has never
/// been body content.
///
/// ── ONE BRAIN, VIEWS **AND** EXPORTS ────────────────────────────────────
/// Her refinement is the reason this lives in core rather than in a view
/// helper: the reading export's per-note headings and the bulk manifest's
/// filenames ask the same question the masthead asks, so they ask it here.
///
/// Pure and dependency-free — no GRDB, no AppKit.
public enum DisplayTitle {
    /// The word a note falls back to when it has neither a name nor a date.
    /// Still reachable: a note with no title and no `entry_date` whose
    /// `created_at` a caller did not carry (every such caller degrades to
    /// exactly the behaviour it had before this existed).
    public static let placeholder = "Untitled"

    /// Is this stored title ABSENT, for display purposes?
    ///
    /// **Blank means blank, and nothing else** — nil, empty, whitespace-only.
    ///
    /// ── THE 13k K1 RETIREMENT (her ruling, 2026-08-02) ───────────────────
    /// 13g batch 7 shipped a wider test: the literal string `"Untitled"`
    /// ALSO counted as absent, because `⌘N` and the shell's New Note had
    /// been STORING that literal as a real title, so her library's "500
    /// untitled things" were titled rather than nameless and a nil-only
    /// rule would have carried none of them. She walked the consequence
    /// (QUESTIONS #52(a) — *a note you deliberately named "Untitled"
    /// renders its date instead*) and OVERTURNED it: **"i can delete them
    /// or rename them myself"**. A name she typed is a name.
    ///
    /// What that leaves standing, deliberately: the mint still stores
    /// `nil` (13g's other half — new notes are genuinely nameless and show
    /// their date), and **NO SWEEP EVER RUNS** — the legacy rows keep the
    /// literal title they were given, and she edits or deletes them by
    /// hand. Nothing is rewritten to fix a display problem.
    public static func isAbsent(_ title: String?) -> Bool {
        guard let title else { return true }
        return title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The note's name for display: its title, else its DATE, else the
    /// placeholder. The title is returned exactly as stored (the trim is
    /// only ever the absence test — leading space in a name she typed is
    /// hers).
    ///
    /// **The date source, pinned (QUESTIONS #52):** the user-set
    /// `entry_date` where there is one, else the day `created_at` fell on.
    /// Same precedence the bulk-export filename has used since 11b, and the
    /// same order of authority `entry_date` has everywhere else — what she
    /// SAID the note's date is outranks when it happened to be typed.
    public static func note(
        title: String?, entryDate: String?, createdAt stamp: String? = nil,
        calendar: Calendar = .current
    ) -> String {
        named(title) {
            if let entryDate, !entryDate.isEmpty { return entryDate }
            return day(fromStamp: stamp, calendar: calendar)
        }
    }

    /// **What a POOL is called on screen** (13k K2 — her ruling, 2026-08-02:
    /// *"i think pools can show their created day, i think that would be
    /// helpful"*).
    ///
    /// The same chain as a note, one link shorter: **a pool has no
    /// `entry_date`** (the column is a post concept — a pool row leaves the
    /// post-specific columns NULL, AppSpec §7), so a nameless pool falls
    /// straight to the day it was CREATED. This supersedes the 13g reading
    /// recorded at QUESTIONS #52(c) — *"A POOL with no name is still
    /// 'Untitled' — a pool has no date, and your ruling was about notes"* —
    /// which she overturned by pointing out that a pool does have one date
    /// worth showing.
    ///
    /// Same discipline as the note rule: a DISPLAY answer, never a write.
    /// `container.title` is untouched, and the export half asks this same
    /// question so a downloaded folder says what the app said.
    public static func pool(
        title: String?, createdAt date: Date?, calendar: Calendar = .current
    ) -> String {
        named(title) {
            date.map { JournalDay.dayString(from: $0, calendar: calendar) }
        }
    }

    /// The pool rule over a RAW STORED STAMP — the same rule, for the
    /// callers that read the column rather than a decoded row (the export
    /// manifest, the single-pool chrome read). Parsed with the canonical
    /// formatter, exactly like `day(fromStamp:)`.
    public static func pool(
        title: String?, createdAtStamp stamp: String?, calendar: Calendar = .current
    ) -> String {
        named(title) { day(fromStamp: stamp, calendar: calendar) }
    }

    /// The one shape both rules share: the stored name if there is one,
    /// else whatever date the caller's chain produces, else the
    /// placeholder. Written once so a third surface cannot invent a fourth
    /// precedence.
    private static func named(_ title: String?, day: () -> String?) -> String {
        if !isAbsent(title), let title { return title }
        if let day = day() { return day }
        return placeholder
    }

    /// The LOCAL calendar day of a stored UTC timestamp, "yyyy-MM-dd".
    ///
    /// Local, not the stamp's own leading ten characters, and the reason is
    /// that the two slots must mean the same KIND of day: `entry_date` is
    /// written by `JournalDay.dayString(from:)` over `Calendar.current`, so
    /// a UTC-sliced fallback beside it would read a day later for anything
    /// written after early evening in a negative-offset zone. One rule for
    /// both halves of the fallback chain.
    ///
    /// Parsed with the canonical formatter (never a second date brain); an
    /// unparseable stamp reads as no day rather than as a guess.
    public static func day(fromStamp stamp: String?, calendar: Calendar = .current) -> String? {
        guard let stamp, !stamp.isEmpty,
              let date = DateFormatter.variorumISO8601.date(from: stamp)
        else { return nil }
        return JournalDay.dayString(from: date, calendar: calendar)
    }
}
