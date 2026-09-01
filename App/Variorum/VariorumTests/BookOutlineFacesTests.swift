//
//  BookOutlineFacesTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch B — the Outline's faces, pinned pure:
//  the collapsed card's preview (row 45 — "A Scandal in Bohemia" previewed
//  as "I."), the details gutter's line (row 13 — the word count dropped,
//  the takes fact kept; C-6), and the navigator's duplicate line (row 8 —
//  a one-note chapter that says the note's name shows ONE row).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Outline's faces (Act 10 correction round, batch B)")
struct BookOutlineFacesTests {
    private let story = "It was a widespread, comfortable-looking building, two-storied, "
        + "slate-roofed, with great yellow blotches of lichen upon the grey walls. "
        + "The drawn blinds and the smokeless chimneys, however, gave it a stricken "
        + "look, as though the weight of this horror still lay heavy upon it."

    // MARK: Row 45 — the card preview

    /// RED on the old rule (the first non-empty block's first 280 chars):
    /// the Sherlock card previewed its section numeral alone.
    @Test func aLeadingNumeralBlockIsSkippedAndTheProseBeginsThePreview() {
        let preview = BookOutlineRows.cardPreview(blocks: ["I.", story])
        #expect(preview.hasPrefix("It was a widespread"), "the numeral is skipped: \(preview)")
        #expect(!preview.hasPrefix("I."))
        // A markdown heading at the front is a heading, not the preview.
        let headed = BookOutlineRows.cardPreview(blocks: ["# Part One", story])
        #expect(headed.hasPrefix("It was a widespread"))
        // Two-word stubs count as headings; a short SENTENCE does not.
        #expect(BookOutlineRows.cardPreview(blocks: ["Chapter 3", story]).hasPrefix("It was"))
        #expect(BookOutlineRows.cardPreview(blocks: ["He ran home.", story]).hasPrefix("He ran home."))
    }

    @Test func aProseFirstNoteKeepsItsOpeningAndAStubOnlyNotePreviewsTheStub() {
        #expect(BookOutlineRows.cardPreview(blocks: [story, "more"]).hasPrefix("It was a widespread"))
        #expect(BookOutlineRows.cardPreview(blocks: ["I."]) == "I.", "never an empty card")
        #expect(BookOutlineRows.cardPreview(blocks: ["", "  "]) == "")
    }

    @Test func thePreviewReadsAcrossLeadingBlocksToTheWordCapWithAnEllipsis() {
        let short = ["One two three.", "Four five six.", "Seven eight nine ten eleven."]
        let capped = BookOutlineRows.cardPreview(blocks: short, words: 8)
        #expect(capped == "One two three. Four five six. Seven eight…", "\(capped)")
        let exact = BookOutlineRows.cardPreview(blocks: short, words: 11)
        #expect(exact == "One two three. Four five six. Seven eight nine ten eleven.",
                "the whole note within the cap carries no ellipsis")
        let acrossBreak = BookOutlineRows.cardPreview(blocks: ["One two three.", "Four five six."], words: 3)
        #expect(acrossBreak == "One two three.…" || acrossBreak == "One two three…",
                "the cap met exactly at a block break still says the note goes on: \(acrossBreak)")
        // Internal newlines flatten to spaces — a card is three lines, not a page.
        #expect(!BookOutlineRows.cardPreview(blocks: ["a\nb c d"]).contains("\n"))
    }

    // MARK: Row 13 — the gutter's line (C-6's verdict)

    /// RED on the old line ("236w · ⑂ takes on 1 block"): the word count is
    /// gone; the takes fact stays; an unfanned card's gutter is empty.
    @Test func theGutterCarriesTheTakesFactAndNoWordCount() {
        #expect(BookOutlineRows.gutterLine(fannedBlocks: 0) == nil)
        #expect(BookOutlineRows.gutterLine(fannedBlocks: 1) == "⑂ takes on 1 block")
        #expect(BookOutlineRows.gutterLine(fannedBlocks: 3) == "⑂ takes on 3 blocks")
        for n in 0...3 {
            #expect(!(BookOutlineRows.gutterLine(fannedBlocks: n) ?? "").contains("w"),
                    "no word count rides the gutter")
        }
    }

    // MARK: Row 8 — the navigator's duplicate line

    private func entry(_ id: String, title: String?) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: title, entryDate: nil, sectionPath: nil)
    }
    private func section(_ name: String) -> ReadingSection {
        ReadingSection(
            id: "s-\(name)", readingId: "book", name: name, position: "a",
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    @Test func aOneNoteChapterThatSaysTheNotesNameCollapsesTheNoteLine() {
        // The Sherlock shape: chapter "A Scandal in Bohemia", note "A Scandal in Bohemia".
        #expect(BookOutlineRows.noteLineCollapsesIntoChapter(
            section: section("A Scandal in Bohemia"),
            entries: [entry("a", title: "A Scandal in Bohemia")]))
        // Case and end-whitespace do not break the match (BookNaming.key).
        #expect(BookOutlineRows.noteLineCollapsesIntoChapter(
            section: section("a scandal in bohemia "),
            entries: [entry("a", title: "A Scandal in Bohemia")]))
    }

    @Test func differentNamesOrSeveralNotesKeepEveryLine() {
        // The field guide: chapter "structure" over notes "divide", "merge"…
        #expect(!BookOutlineRows.noteLineCollapsesIntoChapter(
            section: section("structure"), entries: [entry("a", title: "divide")]))
        #expect(!BookOutlineRows.noteLineCollapsesIntoChapter(
            section: section("A Scandal in Bohemia"),
            entries: [entry("a", title: "A Scandal in Bohemia"), entry("b", title: "A Scandal in Bohemia")]),
                "two notes are two lines, whatever they are called")
        #expect(!BookOutlineRows.noteLineCollapsesIntoChapter(section: section("empty"), entries: []))
    }
}
