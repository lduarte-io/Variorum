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
/// now on. `renderedText`, the export BODY projections and the Fragments
/// bridge's join brain are untouched by construction: a title has never
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
    /// Empty and whitespace-only are obvious. **The literal `"Untitled"`
    /// counts too**, and that is the load-bearing half: until this batch,
    /// `⌘N` and the shell's New Note stored the literal string `"Untitled"`
    /// as a real title (`createPost(title: "Untitled")`), so her library's
    /// existing untitled notes are titled, not nameless — a rule keyed on
    /// nil/empty alone would have fixed none of the "500 untitled things"
    /// she was looking at. The mint stores `nil` from this batch on, and
    /// this test is what carries the ones already in her store.
    ///
    /// The app has treated the literal as a placeholder since Phase 11b
    /// (`LibraryCatalogView.exportFileName`'s `hit.title != "Untitled"`);
    /// this makes that reading the one rule instead of one site's habit.
    /// Deliberately a build-time call (QUESTIONS #52): a note she
    /// deliberately NAMES "Untitled" renders its date instead.
    public static func isAbsent(_ title: String?) -> Bool {
        guard let title else { return true }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == placeholder
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
        if !isAbsent(title), let title { return title }
        if let entryDate, !entryDate.isEmpty { return entryDate }
        if let day = day(fromStamp: stamp, calendar: calendar) { return day }
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
