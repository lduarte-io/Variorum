import Foundation

/// **WHAT A NOTE-LIST CARD LEADS WITH** — Phase 13u3 UNIT B, her item 4
/// (`DetailedPlanForPhases.md`'s `### 13u`, RULED 2026-08-21 the same day she
/// raised it).
///
/// Her words: *"that's exactly the right suggestion. I think that's what
/// should show on the library - a little snippet of what the post starts
/// with."* The rule she gave with it: a card leads with the **EXPLICIT title
/// where set**, else a **length-capped SNIPPET of the note's first words**
/// (*"it can't be the whole first sentence if that sentence is super long"*),
/// derived at read time, **NEVER stored, nothing ever renamed** — the
/// block-TOC precedent extended to note cards; the date demotes to the
/// metadata line. **Journal-profile notes stay date-led** (a daily entry's
/// date IS its identity). A stored Apple-Notes-style auto-title is
/// DEFINITIVELY rejected — *"what I hate is battling the apple notes title"*.
///
/// ── WHY THIS IS NOT `DisplayTitle` ──────────────────────────────────────
/// `DisplayTitle.note` answers **what a note is CALLED** — its title, else its
/// date — and that answer is load-bearing far outside any list: the masthead,
/// the export headings, the bulk manifest's filenames, every picker. It stays
/// exactly as it is (13g R6-3 and her refinement about exports).
///
/// This answers a *different* question, and only a LIST asks it: **what does
/// a card LEAD with when it has a whole row to spend and fifty neighbours to
/// be told apart from.** A date is a fine name for a note and a poor way to
/// tell fifty notes apart, which is precisely the report item 4 came from. So
/// the two live side by side, each with one job, and nothing here ever writes
/// a title or feeds an export.
///
/// Pure and dependency-free — no GRDB, no AppKit. Cost is bounded by
/// `sourceLimit` whatever a caller hands it (P1: a card's name may not cost
/// the note's length).
public enum NoteCardFace {
    // MARK: - What a card shows

    /// What the card's first line IS. Carried as a kind rather than a bare
    /// string so a surface can treat a name she TYPED differently from words
    /// the app derived (the rename door's seed must never be a derived
    /// string — 13g batch 7's lesson: seeding "2026-08-01" had her naming a
    /// note after itself).
    public enum Lead: Equatable, Sendable {
        /// The title she typed, exactly as stored.
        case title(String)
        /// The note's own first words, capped (this item's whole subject).
        case words(String)
        /// The day — a journal entry's identity, and the honest fallback for
        /// a note with no name and no text.
        case day(String)
        /// Neither a name, nor a day, nor a word of text.
        case untitled

        public var text: String {
            switch self {
            case .title(let text): text
            case .words(let text): text
            case .day(let day): day
            case .untitled: DisplayTitle.placeholder
            }
        }

        /// True when the app derived this line rather than reading it off the
        /// row. Nothing may be seeded from a derived lead.
        public var isDerived: Bool {
            if case .title = self { return false }
            return true
        }
    }

    /// A card's two lines: what it leads with, and the prose under it.
    public struct Card: Equatable, Sendable {
        public let lead: Lead
        /// The preview line — **the CONTINUATION** when the lead is the
        /// note's own words, so one card never says the same words twice;
        /// the opening words when the lead is a name or a day. Empty when
        /// there is nothing more to show.
        public let preview: String

        public init(lead: Lead, preview: String) {
            self.lead = lead
            self.preview = preview
        }
    }

    // MARK: - The numbers

    /// **How long a derived lead may be, in CHARACTERS** (grapheme clusters,
    /// so an emoji or a family sequence is one and is never split).
    ///
    /// PROVISIONAL (QUESTIONS #119(a)): 48 is the note title's own measured
    /// room on the Mac — item 13's title cutoff was found HEALED at ~48
    /// characters (13u2, pinned at two widths), and her item 4 asks for a
    /// snippet that reads like a NAME. Wider and the List row's tags and
    /// stamps start yielding to it (the title is the compressible member of
    /// that row, #105); narrower and *"a little snippet of what the post
    /// starts with"* stops being a sentence.
    public static let leadCap = 48

    /// **How much text this brain will ever LOOK at**, whatever it is handed.
    /// The leads are bounded reads already (the Library's card load, the note
    /// picker's `SUBSTR`), and the capture chip's source is whatever she has
    /// typed — which a paste makes unbounded. So the bound lives here, once,
    /// and no caller can forget it.
    public static let sourceLimit = 400

    // MARK: - The one entry point

    /// What this card shows, from what the row already carries.
    ///
    /// - Parameters:
    ///   - storedTitle: the raw `container.title` — **never** a display
    ///     answer (a displayed date handed in here would read as a name).
    ///   - leadingTexts: the note's opening blocks' text, in order, already
    ///     bounded by whatever read produced them.
    ///   - isJournal: `container.profile == 'journal'` — the daily mint's own
    ///     marker, not "has a date" (a note she merely dated is not a diary
    ///     entry).
    ///   - entryDate / createdAt: the date chain `DisplayTitle` already owns,
    ///     asked through it so a card and a masthead can never disagree about
    ///     which day a note is.
    public static func card(
        storedTitle: String?,
        leadingTexts: [String],
        isJournal: Bool = false,
        entryDate: String? = nil,
        createdAt: String? = nil,
        calendar: Calendar = .current,
        cap: Int = leadCap
    ) -> Card {
        let words = firstWords(leadingTexts, cap: cap)

        // 1. A NAME SHE TYPED ALWAYS LEADS — journal or not, long or short.
        if !DisplayTitle.isAbsent(storedTitle), let storedTitle {
            return Card(lead: .title(storedTitle), preview: words?.whole ?? "")
        }

        let day = statedDay(entryDate: entryDate, createdAt: createdAt, calendar: calendar)

        // 2. A DAILY ENTRY IS ITS DAY (her ruling, riding with item 4).
        if isJournal, let day {
            return Card(lead: .day(day), preview: words?.whole ?? "")
        }

        // 3. THE NOTE'S OWN FIRST WORDS — the item.
        if let words {
            return Card(lead: .words(words.lead), preview: words.rest)
        }

        // 4. No words at all: the day, exactly as every other surface names
        //    this note — and then the placeholder.
        if let day { return Card(lead: .day(day), preview: "") }
        return Card(lead: .untitled, preview: "")
    }

    /// **The title a capture surface OFFERS** — her item 4's other half: the
    /// first words *"offered, one tap to adopt, ignorable forever — a
    /// suggestion, never an action taken for her"*. Same rule and same bound
    /// as a card's lead; the text is treated as one leading block.
    ///
    /// **With one difference, and it is deliberate: no ellipsis.** A lead's
    /// ellipsis says *there is more of this sentence*, which is true of a
    /// card's first line and false of a NAME she has chosen — the words stop
    /// at the same word edge either way, and a stored title reading
    /// `Garden plans…` would be the app putting its own truncation mark into
    /// her prose. (PROVISIONAL, QUESTIONS #119(d).)
    public static func suggestedTitle(forTypedText text: String, cap: Int = leadCap) -> String? {
        guard let lead = firstWords([text], cap: cap)?.lead else { return nil }
        let name = (lead.hasSuffix(ellipsis) ? String(lead.dropLast()) : lead)
            .trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? nil : name
    }

    // MARK: - The words

    /// The result of reading a note's opening: the capped LEAD, what is left
    /// after it, and the whole opening as one line (for the surfaces that
    /// lead with something else).
    public struct Words: Equatable, Sendable {
        public let lead: String
        public let rest: String
        public let whole: String
    }

    /// **The note's opening, as display text** — nil when there is not one
    /// word in it.
    ///
    /// Three things happen here and nowhere else:
    ///
    /// 1. **The markdown is RENDERED, not printed.** A note that opens
    ///    `# Garden plans` is called *Garden plans*, not `# Garden plans` —
    ///    through the app's own display brain (`MarkdownRendering`), never a
    ///    second stripper. A list lead's substituted glyph (`• `, `☐ `) is a
    ///    structure mark rather than a word, so a leading one is dropped too.
    ///    PROVISIONAL (#119(b)).
    /// 2. **The lead is the first LINE with words in it**, not the first
    ///    forty words — a heading IS the note's name, and a name that ran on
    ///    through the paragraph under it would not be one.
    /// 3. **The cut is at a word edge**, with an ellipsis, and never
    ///    mid-word — unless the first word is itself longer than the cap, in
    ///    which case it is cut where the cap falls (a 200-character word is
    ///    still a name that has to fit).
    public static func firstWords(_ texts: [String], cap: Int = leadCap) -> Words? {
        let source = bounded(texts)
        guard !source.isEmpty else { return nil }
        let display = MarkdownRendering.render(source).text
        var lines = display
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { stripLead(String($0).trimmingCharacters(in: .whitespaces)) }
        lines.removeAll { $0.isEmpty }
        guard let first = lines.first else { return nil }

        let (lead, tail) = cut(first, cap: cap)
        let rest = ([tail] + lines.dropFirst())
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return Words(lead: lead, rest: rest, whole: lines.joined(separator: " "))
    }

    // MARK: - The pieces

    /// Everything this brain will look at: the leading texts joined by a
    /// newline (a block break is a paragraph break — I4's surface rule), cut
    /// at `sourceLimit` characters.
    private static func bounded(_ texts: [String]) -> String {
        var source = ""
        for text in texts {
            guard source.count < sourceLimit else { break }
            if !source.isEmpty { source += "\n" }
            source += String(text.prefix(sourceLimit - source.count))
        }
        return source
    }

    /// Drop a leading display glyph the markdown renderer substituted for a
    /// list lead — `"• "`, `"☐ "`, `"☑ "`. The words after it are the name.
    private static func stripLead(_ line: String) -> String {
        for glyph in [
            MarkdownRendering.bulletLead,
            MarkdownRendering.uncheckedBox,
            MarkdownRendering.checkedBox,
        ] where line.hasPrefix(glyph) {
            return String(line.dropFirst(glyph.count))
                .trimmingCharacters(in: .whitespaces)
        }
        return line
    }

    /// Cut one line at the cap, at a word edge, with an ellipsis — and hand
    /// back what was left behind so the card's second line can carry on
    /// rather than repeat.
    private static func cut(_ line: String, cap: Int) -> (lead: String, rest: String) {
        guard cap > 0 else { return ("", line) }
        guard line.count > cap else { return (line, "") }
        let hard = line.index(line.startIndex, offsetBy: cap)
        var edge = hard
        if !line[hard].isWhitespace,
           let space = line[..<hard].lastIndex(where: { $0.isWhitespace })
        {
            edge = space
        }
        let lead = String(line[..<edge]).trimmingCharacters(in: .whitespaces)
        let rest = String(line[edge...]).trimmingCharacters(in: .whitespaces)
        // A cap so small that the first word does not fit leaves nothing to
        // lead with; the hard cut is the honest answer there.
        guard !lead.isEmpty else {
            return (String(line[..<hard]) + ellipsis, String(line[hard...]))
        }
        return (lead + ellipsis, rest)
    }

    /// The day this note is about, by the chain every other surface uses.
    private static func statedDay(
        entryDate: String?, createdAt: String?, calendar: Calendar
    ) -> String? {
        if let entryDate, !entryDate.isEmpty { return entryDate }
        return DisplayTitle.day(fromStamp: createdAt, calendar: calendar)
    }

    /// The one ellipsis — a single character, never three dots (the chrome
    /// vocabulary's own mark).
    public static let ellipsis = "\u{2026}"
}
