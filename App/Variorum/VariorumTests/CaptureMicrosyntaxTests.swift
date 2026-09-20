//
//  CaptureMicrosyntaxTests.swift
//  VariorumTests
//
//  13u4 UNIT C1 — the capture microsyntax's PURE brain, one arm per clause
//  of her ruling R-13u4-1:
//
//    · `{#tag/path}` applies the tag · `{t:"my title"}` sets the title
//    · ONLY the braced forms parse — a bare #hashtag is never touched
//    · malformed braces pass through as typed text
//    · tokens DISAPPEAR once parsed
//
//  This is a NEW RULE, not a defect fix, so no red-on-old is owed (13u4
//  CAST & DISCIPLINE): the pins are written to the ruling. What they are
//  worth is that every edge the ruling leaves to the build is written down
//  here as an assertion rather than as a sentence in a record — the five
//  PROVISIONALs in QUESTIONS #127 each have their pin below, named.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The capture microsyntax (13u4 item 2 — R-13u4-1)")
struct CaptureMicrosyntaxTests {

    // MARK: - The two forms

    /// Her own example, end to end.
    @Test func aBracedHashtagIsATagAndTheTokenDisappears() {
        let parsed = CaptureMicrosyntax.parse("Had a weird dream about the ocean {#dream}")
        #expect(parsed.tagPaths == ["dream"])
        #expect(parsed.title == nil)
        #expect(parsed.text == "Had a weird dream about the ocean")
    }

    @Test func aBracedTitleSetsTheTitleAndTheTokenDisappears() {
        let parsed = CaptureMicrosyntax.parse("{t:\"Ocean dream\"} Had a weird dream")
        #expect(parsed.title == "Ocean dream")
        #expect(parsed.tagPaths.isEmpty)
        #expect(parsed.text == "Had a weird dream")
    }

    /// A path, not just a name — the token is a TYPED PATH, which is why the
    /// application rides the typed-path brain and not a second tag rule.
    @Test func aTagTokenCarriesAHierarchy() {
        let parsed = CaptureMicrosyntax.parse("leg day {#health/workout}")
        #expect(parsed.tagPaths == ["health/workout"])
        #expect(parsed.text == "leg day")
    }

    /// SEVERAL are legal, and every one applies — in the order she typed
    /// them.
    @Test func everyBracedHashtagApplies() {
        let parsed = CaptureMicrosyntax.parse("{#dream} the ocean again {#sea} {#journal}")
        #expect(parsed.tagPaths == ["dream", "sea", "journal"])
        #expect(parsed.text == "the ocean again")
    }

    /// The FIRST title wins; a second one is still a token and still
    /// disappears (PROVISIONAL, QUESTIONS #127(a)).
    @Test func theFirstTitleWinsAndTheLaterOneStillDisappears() {
        let parsed = CaptureMicrosyntax.parse("{t:\"First\"} words {t:\"Second\"}")
        #expect(parsed.title == "First")
        #expect(parsed.text == "words")
    }

    /// The `t` is read case-insensitively (PROVISIONAL #127(b)) — iOS
    /// capitalizes the first letter of a capture, and a title token is
    /// exactly the thing she types first.
    @Test func anAutocapitalizedTitleTokenStillParses() {
        let parsed = CaptureMicrosyntax.parse("{T:\"Ocean dream\"} the sea")
        #expect(parsed.title == "Ocean dream")
        #expect(parsed.text == "the sea")
    }

    /// Scanning to the first `"}` rather than the first `"` is what lets a
    /// title carry quotes of its own.
    @Test func aTitleMayCarryItsOwnQuotes() {
        let parsed = CaptureMicrosyntax.parse("{t:\"she said \"hi\"\"} and left")
        #expect(parsed.title == "she said \"hi\"")
        #expect(parsed.text == "and left")
    }

    // MARK: - What is NEVER touched

    /// Her line: *"I wouldn't want it applied to just any hashtag."*
    @Test func aBareHashtagIsNeverTouched() {
        let raw = "#dream about the ocean — see also #sea/inland"
        let parsed = CaptureMicrosyntax.parse(raw)
        #expect(parsed.tagPaths.isEmpty)
        #expect(parsed.title == nil)
        #expect(parsed.text == raw, "byte-identical — nothing parsed, nothing moved")
    }

    /// Text with no brace at all takes the fast path and comes back byte
    /// for byte.
    @Test func ordinaryTextPassesThroughByteIdentical() {
        let raw = "First paragraph.\n\n  Second one, indented.  \n"
        #expect(CaptureMicrosyntax.parse(raw).text == raw)
    }

    /// Every malformed shape, one assertion each — the whole point is that
    /// she SEES what she typed rather than losing it to a rule that nearly
    /// matched (PROVISIONAL #127(d)).
    @Test func malformedBracesPassThroughAsTypedText() {
        for raw in [
            "{#}",                      // no name
            "{#dream",                  // never closed
            "{ #dream}",                // the opener is exactly "{#"
            "{t:my title}",             // no quotes
            "{t:\"\"}",                 // no name
            "{t:\"unterminated}",       // never closed
            "{tag:\"x\"}",              // not the t: opener
            "a { b } c",                // ordinary braces in prose
            "{#dream\nand more}",       // a token never crosses a newline
        ] {
            let parsed = CaptureMicrosyntax.parse(raw)
            #expect(parsed.text == raw, "byte-intact: \(raw)")
            #expect(parsed.tagPaths.isEmpty, "nothing parsed: \(raw)")
            #expect(parsed.title == nil, "nothing parsed: \(raw)")
        }
    }

    /// A malformed opener resumes the scan one character on, so a
    /// well-formed token standing inside it is still found — and the
    /// malformed half is still hers, byte for byte.
    @Test func aMalformedOpenerKeepsItsTextAndTheGoodTokenInsideItStillParses() {
        let parsed = CaptureMicrosyntax.parse("{#a{#b}")
        #expect(parsed.tagPaths == ["b"])
        #expect(parsed.text == "{#a")
    }

    // MARK: - Where the whitespace goes (PROVISIONAL #127(c))

    @Test func aTokenTakesItsSeamWhitespaceWithIt() {
        // Trailing: the space before it goes with it.
        #expect(CaptureMicrosyntax.parse("Had a dream {#dream}").text == "Had a dream")
        // Leading: the token opens the line, so the space AFTER it goes.
        #expect(CaptureMicrosyntax.parse("{#dream} Had a dream").text == "Had a dream")
        // In the middle: one seam, one space.
        #expect(CaptureMicrosyntax.parse("Had {#dream} a dream").text == "Had a dream")
        // Her own indentation is not a seam.
        #expect(CaptureMicrosyntax.parse("   {#dream} indented").text == "   indented")
    }

    /// A line that held nothing but tokens goes entirely — otherwise a
    /// title on its own line leaves a blank paragraph at the top of the
    /// note (`bulkSegments` stores the blank line as content).
    @Test func aLineOfNothingButTokensGoesWithThem() {
        let parsed = CaptureMicrosyntax.parse(
            "{t:\"Ocean dream\"}\nHad a weird dream about the ocean.\n\nIt was blue.")
        #expect(parsed.title == "Ocean dream")
        #expect(parsed.text == "Had a weird dream about the ocean.\n\nIt was blue.")
    }

    @Test func aTokenLineBetweenParagraphsLeavesTheParagraphsAdjacent() {
        let parsed = CaptureMicrosyntax.parse("Paragraph one.\n{#dream}\nParagraph two.")
        #expect(parsed.tagPaths == ["dream"])
        #expect(parsed.text == "Paragraph one.\nParagraph two.")
    }

    /// A blank line SHE typed is not a token line and never moves.
    @Test func herOwnBlankLinesAreUntouched() {
        let parsed = CaptureMicrosyntax.parse("One.\n\n{#dream} Two.")
        #expect(parsed.text == "One.\n\nTwo.")
    }

    // MARK: - The degenerate capture

    /// A capture that is ONLY tokens leaves nothing to file. The doors take
    /// their standing empty-capture branch from here (PROVISIONAL #127(f));
    /// the brain's job is only to say the text is empty.
    @Test func aCaptureOfNothingButTokensLeavesNoText() {
        let parsed = CaptureMicrosyntax.parse("{t:\"Title\"} {#dream}")
        #expect(parsed.title == "Title")
        #expect(parsed.tagPaths == ["dream"])
        #expect(parsed.text.isEmpty)
        #expect(parsed.carriesTokens)
    }

    /// A well-formed token whose value is all separators parses and then
    /// names no tag — the one shape that reaches `applyTags`' `nothingTyped`
    /// arm, pinned so that arm is known to be reachable rather than
    /// defensive.
    @Test func aTagOfNothingButSlashesParsesAndNamesNoTag() {
        let parsed = CaptureMicrosyntax.parse("words {#///}")
        #expect(parsed.tagPaths == ["///"])
        #expect(TypedTagPath.segments("///").isEmpty)
    }
}
