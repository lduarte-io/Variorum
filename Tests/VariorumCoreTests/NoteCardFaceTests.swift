//
//  NoteCardFaceTests.swift
//  VariorumCoreTests
//
//  **13u3 UNIT B — her item 4, RULED** (2026-08-21): *"that's exactly the
//  right suggestion. I think that's what should show on the library - a
//  little snippet of what the post starts with"*, with the caveat that
//  decides half of these cells: *"it can't be the whole first sentence if
//  that sentence is super long."*
//
//  The brain is pure, so the rule is pinned here rather than through a
//  mounted card: the FACES then compose it (the `LibrarySortFace` shape —
//  one rule, both note renderers).
//

import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("What a note-list card leads with (13u3 UNIT B — her item 4)")
struct NoteCardFaceTests {

    // MARK: - The precedence

    /// **A NAME SHE TYPED ALWAYS LEADS.** Long, short, journal, dated — the
    /// derived rule exists for notes that have no name, and never overrides
    /// one.
    @Test func aStoredTitleAlwaysLeads() {
        let card = NoteCardFace.card(
            storedTitle: "three ways of working",
            leadingTexts: ["The lighthouse keeper counted the storms."],
            entryDate: "2026-01-15")
        #expect(card.lead == .title("three ways of working"))
        #expect(card.lead.text == "three ways of working")
        #expect(!card.lead.isDerived, "a name she typed is never a derived lead")
        #expect(card.preview == "The lighthouse keeper counted the storms.",
                "the words move DOWN to the preview line, they do not disappear")

        // A journal entry she named keeps her name too.
        let named = NoteCardFace.card(
            storedTitle: "the day the power went out", leadingTexts: ["It went out at four."],
            isJournal: true, entryDate: "2026-01-15")
        #expect(named.lead == .title("the day the power went out"))

        // Leading space in a name she typed is HERS (`DisplayTitle`'s rule —
        // the trim is only ever the absence test).
        #expect(NoteCardFace.card(storedTitle: "  spaced", leadingTexts: []).lead
                == .title("  spaced"))
    }

    /// **A BLANK title is no title** — nil, empty, whitespace-only — and then
    /// the note's own words lead.
    @Test func aBlankTitleIsNoTitleAndTheWordsLead() {
        for blank: String? in [nil, "", "   ", "\n\t "] {
            let card = NoteCardFace.card(
                storedTitle: blank, leadingTexts: ["Nothing was written on the wall."])
            #expect(card.lead == .words("Nothing was written on the wall."),
                    "title \(String(describing: blank)) is absent")
            #expect(card.lead.isDerived)
        }
    }

    /// **A JOURNAL-PROFILE NOTE STAYS DATE-LED** (her rule, riding with item
    /// 4: a daily entry's date IS its identity) — and its words still show
    /// underneath.
    @Test func aJournalEntryIsItsDay() {
        let card = NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["Woke early. The frost had come."],
            isJournal: true, entryDate: "2026-01-15")
        #expect(card.lead == .day("2026-01-15"))
        #expect(card.preview == "Woke early. The frost had come.")

        // The SAME note, not journal-profile: its words lead. The marker is
        // the daily mint's `profile`, never "it has a date" — a note she
        // merely dated is not a diary entry.
        let dated = NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["Woke early. The frost had come."],
            isJournal: false, entryDate: "2026-01-15")
        #expect(dated.lead == .words("Woke early. The frost had come."))

        // A journal-profile note with no day at all still has to say
        // something: its words.
        let dayless = NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["No day on this one."], isJournal: true)
        #expect(dayless.lead == .words("No day on this one."))
    }

    /// **NO NAME, NO WORDS — the day, exactly as every other surface names
    /// this note; and then the placeholder.** The `entry_date`-then-created
    /// chain is `DisplayTitle`'s own, asked through it.
    @Test func aNoteWithNothingInItFallsBackTheWayEverySurfaceDoes() {
        let stated = NoteCardFace.card(storedTitle: nil, leadingTexts: [], entryDate: "2026-01-15")
        #expect(stated.lead == .day("2026-01-15"))
        #expect(stated.preview.isEmpty)

        let created = NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["", "   \n  "],
            createdAt: "2026-01-15T09:00:00.000Z",
            calendar: {
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = TimeZone(identifier: "UTC")!
                return calendar
            }())
        #expect(created.lead == .day("2026-01-15"), "whitespace-only blocks are no words")

        let nothing = NoteCardFace.card(storedTitle: nil, leadingTexts: [])
        #expect(nothing.lead == .untitled)
        #expect(nothing.lead.text == DisplayTitle.placeholder)
    }

    // MARK: - The cap (her caveat)

    /// **"IT CAN'T BE THE WHOLE FIRST SENTENCE IF THAT SENTENCE IS SUPER
    /// LONG"** — the cut is at a word edge, it carries an ellipsis, and it
    /// never runs past the cap.
    @Test func aLongOpeningIsCutAtAWordEdge() {
        let sentence =
            "The lighthouse keeper counted the storms and wrote none of them down, year after year."
        let card = NoteCardFace.card(storedTitle: nil, leadingTexts: [sentence])
        let lead = card.lead.text
        #expect(lead.hasSuffix(NoteCardFace.ellipsis))
        #expect(lead.count <= NoteCardFace.leadCap + 1, "the ellipsis is the only overrun")
        #expect(!lead.dropLast().hasSuffix(" "), "no space left hanging before the ellipsis")
        #expect(sentence.hasPrefix(lead.dropLast()), "the words are the note's own, in order")
        // The cut fell at a word edge: the next character in the source is a
        // space, so no word was sawn in half.
        let cutAt = sentence.index(sentence.startIndex, offsetBy: lead.count - 1)
        #expect(sentence[cutAt] == " ")
        #expect(card.preview.hasPrefix("wrote"),
                "…and the preview CARRIES ON rather than saying the same words twice: \(card.preview)")
    }

    /// An opening that FITS is left alone — no ellipsis on a complete name.
    @Test func aShortOpeningIsWholeAndUnmarked() {
        let card = NoteCardFace.card(storedTitle: nil, leadingTexts: ["A short one."])
        #expect(card.lead == .words("A short one."))
        #expect(!card.lead.text.contains(NoteCardFace.ellipsis))
        #expect(card.preview.isEmpty, "nothing was left behind, so nothing is said twice")

        // Exactly at the cap: still whole.
        let exact = String(repeating: "a", count: NoteCardFace.leadCap)
        #expect(NoteCardFace.card(storedTitle: nil, leadingTexts: [exact]).lead == .words(exact))
    }

    /// **ONE LONG WORD** — a 200-character token with no edge to cut at is
    /// cut where the cap falls, because a name still has to fit.
    @Test func oneLongWordIsCutWhereTheCapFalls() {
        let word = String(repeating: "supercalifragilistic", count: 10)
        let card = NoteCardFace.card(storedTitle: nil, leadingTexts: [word])
        let lead = card.lead.text
        #expect(lead.count == NoteCardFace.leadCap + 1, "the cap, plus the ellipsis")
        #expect(word.hasPrefix(lead.dropLast()))
        #expect(!card.preview.isEmpty, "the rest of the word is still the preview's")
    }

    /// **EMOJI AND GRAPHEME CLUSTERS ARE NEVER SPLIT** — the cap counts
    /// Characters, so a family sequence is one character and survives whole.
    @Test func theCapCountsGraphemesSoAnEmojiIsNeverSplit() {
        let family = "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"  // 👨‍👩‍👧, one Character
        #expect(family.count == 1)
        let line = String(repeating: family + " ", count: 30)
        let lead = NoteCardFace.card(storedTitle: nil, leadingTexts: [line]).lead.text
        #expect(lead.count <= NoteCardFace.leadCap + 1)
        // Every kept character is a whole family — no lone man, woman or
        // girl fell out of one.
        for character in lead.dropLast() where !character.isWhitespace {
            #expect(String(character) == family, "a cluster was split: \(character.unicodeScalars)")
        }
    }

    // MARK: - Markdown

    /// **A NOTE THAT OPENS `# Garden plans` IS CALLED *Garden plans***. The
    /// app's own display brain renders it; there is no second stripper.
    @Test func theLeadIsDisplayTextNotRawMarkdown() {
        #expect(NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["# Garden plans", "Beds, bulbs, and a fence."]
        ).lead == .words("Garden plans"))

        #expect(NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["**Bold** opening"]).lead == .words("Bold opening"))
        #expect(NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["*soft* opening"]).lead == .words("soft opening"))
        #expect(NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["[the link](https://example.com) first"]
        ).lead == .words("the link first"))

        // A list lead's substituted glyph is a structure mark, not a word.
        #expect(NoteCardFace.card(storedTitle: nil, leadingTexts: ["- milk"]).lead
                == .words("milk"))
        #expect(NoteCardFace.card(storedTitle: nil, leadingTexts: ["- [ ] call the bank"]).lead
                == .words("call the bank"))
    }

    /// **A HEADING IS THE NAME, AND THE PROSE UNDER IT IS THE PREVIEW** — the
    /// lead is the first LINE with words in it, never the first forty words
    /// running on through the paragraph beneath.
    @Test func theLeadIsTheFirstLineAndThePreviewIsWhatFollows() {
        let card = NoteCardFace.card(
            storedTitle: nil,
            leadingTexts: ["# Garden plans\nBeds first.", "Then the fence."])
        #expect(card.lead == .words("Garden plans"))
        #expect(card.preview == "Beds first. Then the fence.",
                "the lines and the blocks that follow, flattened into one preview line")

        // A blank opening line is skipped rather than named.
        #expect(NoteCardFace.card(
            storedTitle: nil, leadingTexts: ["", "   ", "The real opening."]
        ).lead == .words("The real opening."))
    }

    // MARK: - The bound (P1)

    /// **THIS BRAIN NEVER LOOKS AT MORE THAN `sourceLimit` CHARACTERS** —
    /// whatever it is handed. A card's name may not cost the note's length,
    /// and the capture chip's source is whatever a paste made it.
    @Test func theBrainIsBoundedWhateverItIsHanded() throws {
        let huge = String(repeating: "word ", count: 50_000)
        let words = try #require(NoteCardFace.firstWords([huge, huge, huge]))
        #expect(words.lead.count <= NoteCardFace.leadCap + 1)
        #expect(words.whole.count <= NoteCardFace.sourceLimit,
                "the preview is bounded too — it is a preview")
    }

    // MARK: - The capture chip's suggestion

    /// The chip offers the SAME words the card would lead with, from a buffer
    /// that is not a note yet — one rule, both sides of the mint.
    @Test func theTypedSuggestionIsTheSameRule() throws {
        #expect(NoteCardFace.suggestedTitle(forTypedText: "# Garden plans\nBeds first.")
                == "Garden plans")
        #expect(NoteCardFace.suggestedTitle(forTypedText: "   ") == nil, "nothing to suggest")
        #expect(NoteCardFace.suggestedTitle(forTypedText: "") == nil)

        let long = "The lighthouse keeper counted the storms and wrote none of them down, ever."
        let suggestion = try #require(NoteCardFace.suggestedTitle(forTypedText: long))
        #expect(suggestion.count <= NoteCardFace.leadCap)
        // **A NAME IS NOT A TRUNCATION.** The card's lead carries the
        // ellipsis (there is more of this sentence); the title she adopts
        // does not — the app must not put its own truncation mark into her
        // prose. Same words, same word edge.
        #expect(!suggestion.hasSuffix(NoteCardFace.ellipsis))
        #expect(long.hasPrefix(suggestion))
        let lead = try #require(NoteCardFace.firstWords([long])).lead
        #expect(lead == suggestion + NoteCardFace.ellipsis, "one rule, two marks")
    }

    // MARK: - The fact the rows had to start carrying

    /// **The daily mint's marker rides the rows a CARD is drawn from** — the
    /// catalog's note hits and the Pool's listing — so the journal split is
    /// read off the row rather than guessed from "it has a date". Both are
    /// nil-defaulted additions: every other listing and caller is unchanged
    /// and simply has no opinion.
    @Test func theJournalMarkerRidesTheRowsACardIsDrawnFrom() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-01-15")
            let dated = try ops.createPost(title: nil, entryDate: "2026-01-16")
            _ = try ops.createReading(name: "the field guide", kind: .curated)

            let hits = try db.read { try Queries.searchCatalog($0, query: "") }
            let byID = Dictionary(
                hits.filter { $0.kind == .post }.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first })
            #expect(byID[entry.container.id]?.isJournalEntry == true)
            #expect(byID[dated.id]?.profile == nil,
                    "a note she merely DATED is not a diary entry")
            #expect(byID[dated.id]?.isJournalEntry == false)
            #expect(hits.first { $0.kind == .book }?.isJournalEntry == false,
                    "a book hit has no profile at all")

            // The Pool's listing carries it too (a journal entry whose book
            // membership was removed is bookless like any other note).
            let pool = try db.read { try Queries.poolPosts($0, limit: 50) }
            let poolByID = Dictionary(
                uniqueKeysWithValues: pool.map { ($0.postID, $0) })
            #expect(poolByID[entry.container.id]?.isJournalEntry == true)
            #expect(poolByID[dated.id]?.isJournalEntry == false)
        }
    }
}
