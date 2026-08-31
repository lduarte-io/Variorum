//
//  NoteIndexOutlineTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — item 16 (W8-1): the Index mode's outline
//  brain. Headings become sections, everything else nests under the most
//  recent heading, a heading-less note reads FLAT — and the cheap
//  first-line lead check is pinned against `MarkdownRendering`'s own
//  answer so the two rules cannot drift apart silently.
//

import Testing
import VariorumCore
@testable import Variorum

@Suite("NoteIndexOutline (pre-13u Act 10 wave 2c)")
struct NoteIndexOutlineTests {
    @Test func headingsBecomeSectionsAndBlocksNestUnderTheMostRecent() {
        let outline = NoteIndexOutline.outline(of: [
            (id: "a", text: "An opening paragraph."),
            (id: "h1", text: "## Headings are sizes"),
            (id: "b", text: "- Lists are lines"),
            (id: "c", text: "Another block."),
            (id: "h2", text: "# The close"),
            (id: "d", text: "Final words."),
        ])
        #expect(!outline.isFlat)
        #expect(outline.groups.count == 3)
        // The preamble: head-less, holding what came before any heading.
        #expect(outline.groups[0].head == nil)
        #expect(outline.groups[0].rows.map(\.blockID) == ["a"])
        // First section: the ## block heads it, level carried.
        #expect(outline.groups[1].head?.blockID == "h1")
        #expect(outline.groups[1].headingLevel == 2)
        #expect(outline.groups[1].rows.map(\.blockID) == ["b", "c"])
        // Second section, level 1, one child.
        #expect(outline.groups[2].head?.blockID == "h2")
        #expect(outline.groups[2].rows.map(\.blockID) == ["d"])
        // Ordinals are 1-based note order, heads included.
        #expect(outline.allRows.map(\.ordinal) == [1, 2, 3, 4, 5, 6])
    }

    @Test func aHeadinglessNoteGetsTheHonestFlatIndex() {
        let outline = NoteIndexOutline.outline(of: [
            (id: "a", text: "plain"), (id: "b", text: "also plain"),
        ])
        #expect(outline.isFlat)
        #expect(outline.groups[0].rows.map(\.blockID) == ["a", "b"])
    }

    @Test func theHeadingRuleIsF3sLetter() {
        #expect(NoteIndexOutline.headingLevel(of: "# One") == 1)
        #expect(NoteIndexOutline.headingLevel(of: "## Two") == 2)
        #expect(NoteIndexOutline.headingLevel(of: "### Three") == 3)
        #expect(NoteIndexOutline.headingLevel(of: "#### four is plain") == nil)
        #expect(NoteIndexOutline.headingLevel(of: "#nospace") == nil)
        #expect(NoteIndexOutline.headingLevel(of: "plain # text") == nil)
        #expect(NoteIndexOutline.headingLevel(of: nil) == nil)
        #expect(NoteIndexOutline.headingLevel(of: "") == nil)
        // First-line scoped: a heading mark on a LATER line is content (I4
        // — internal newlines are content, not structure).
        #expect(NoteIndexOutline.headingLevel(of: "intro\n# not a section") == nil)
        // "# " alone is a heading with no words yet (the F-3 letter).
        #expect(NoteIndexOutline.headingLevel(of: "# ") == 1)
        #expect(NoteIndexOutline.headingTitle(of: "## Headings are sizes ") == "Headings are sizes")
        #expect(NoteIndexOutline.headingTitle(of: "# ") == "")
        #expect(NoteIndexOutline.headingTitle(of: "plain") == "")
    }

    /// The drift pin: the cheap first-line check answers exactly as the
    /// one rendering law does, over the shared vocabulary. If either rule
    /// ever moves, this reds before an index disagrees with a page.
    @Test func theCheapLeadCheckAgreesWithMarkdownRendering() {
        let vocabulary = [
            "# One", "## Two words here", "### Three", "#### too deep",
            "#nospace", "- a bullet", "plain text", "# ", "  # indented",
            "**bold** start", "# heading\nwith a second line",
        ]
        for text in vocabulary {
            let mine = NoteIndexOutline.headingLevel(of: text)
            let rendered = MarkdownRendering.render(text)
            let law: Int? =
                if case .heading(let level) = rendered.lines.first?.style {
                    level
                } else {
                    nil
                }
            #expect(mine == law, "disagree on \(text): mine \(String(describing: mine)) law \(String(describing: law))")
        }
    }
}
