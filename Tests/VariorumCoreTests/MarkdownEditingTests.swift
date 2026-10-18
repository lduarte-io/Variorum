import Foundation
import Testing
@testable import VariorumCore

/// Applies a plan to `text` the way the app does — LAST EDIT FIRST — so every
/// pin below reads as "this text became that text", which is the claim that
/// matters, rather than as offset arithmetic.
private func applied(_ plan: MarkdownEditing.Plan, to text: String) -> String {
    let result = NSMutableString(string: text)
    for edit in plan.edits.reversed() {
        result.replaceCharacters(
            in: NSRange(location: edit.range.lowerBound, length: edit.range.count),
            with: edit.replacement)
    }
    return result as String
}

/// `text` with the resulting selection marked by `|` (a caret) or `‹…›`.
private func selected(_ plan: MarkdownEditing.Plan, in text: String) -> String {
    let after = applied(plan, to: text) as NSString
    let selection = plan.selection
    let head = after.substring(to: selection.lowerBound)
    let tail = after.substring(from: selection.upperBound)
    if selection.isEmpty { return head + "|" + tail }
    return head + "‹"
        + after.substring(with: NSRange(
            location: selection.lowerBound, length: selection.count))
        + "›" + tail
}

private func plan(
    _ act: MarkdownEditing.Act, _ text: String, _ selection: Range<Int>
) -> MarkdownEditing.Plan {
    MarkdownEditing.plan(act, inLines: text, selection: selection)
}

/// The UTF-16 range of `needle` in `text` — so a pin can name the text it
/// selects instead of counting characters.
private func range(of needle: String, in text: String) -> Range<Int> {
    let found = (text as NSString).range(of: needle)
    return found.location..<(found.location + found.length)
}

@Suite("MarkdownEditing (13g batch 3, L8/L9 — the formatting acts)")
struct MarkdownEditingTests {

    // MARK: - The inline family: wrap

    @Test func wrappingASelectionPutsTheMarkersAroundItAndKeepsItSelected() {
        let text = "say this now"
        let bold = plan(.bold, text, range(of: "this", in: text))
        #expect(applied(bold, to: text) == "say **this** now")
        #expect(selected(bold, in: text) == "say **‹this›** now")

        let italic = plan(.italic, text, range(of: "this", in: text))
        #expect(applied(italic, to: text) == "say *this* now")

        let struck = plan(.strikethrough, text, range(of: "this", in: text))
        #expect(applied(struck, to: text) == "say ~~this~~ now")

        let code = plan(.code, text, range(of: "this", in: text))
        #expect(applied(code, to: text) == "say `this` now")
    }

    @Test func aCaretGestureInsertsBothMarkersAndSitsBetweenThem() {
        let text = "say  now"
        let bold = plan(.bold, text, 4..<4)
        #expect(applied(bold, to: text) == "say **** now")
        #expect(selected(bold, in: text) == "say **|** now")
        // ONE edit, not two at the same offset — the caret case is its own
        // shape so the plan stays ascending and disjoint.
        #expect(bold.edits.count == 1)
        #expect(bold.edits[0].replacement == "****")
    }

    @Test func aSelectionsSurroundingWhitespaceIsNotWrapped() {
        // Selecting a word by double-click-and-drag routinely picks up the
        // trailing space; wrapping it would break the flanking rule and the
        // markers would read as literal text.
        let text = "say this now"
        let bold = plan(.bold, text, range(of: " this ", in: text))
        #expect(applied(bold, to: text) == "say **this** now")
    }

    @Test func aWhitespaceOnlySelectionFallsBackToTheCaretGesture() {
        // Never a silent no-op: she asked for bold and gets the markers.
        let text = "a   b"
        let bold = plan(.bold, text, 1..<4)
        #expect(applied(bold, to: text) == "a****   b")
        #expect(selected(bold, in: text) == "a**|**   b")
    }

    // MARK: - The inline family: unwrap (read from the tokenizer, never guessed)

    @Test func theActUNWRAPSWhatIsAlreadyWrapped() {
        let text = "say **this** now"
        // The content selected — the ordinary "I selected the bold word".
        let content = plan(.bold, text, range(of: "this", in: text))
        #expect(applied(content, to: text) == "say this now")
        #expect(selected(content, in: text) == "say ‹this› now")

        // The whole span selected, markers included — the case the brief names.
        let whole = plan(.bold, text, range(of: "**this**", in: text))
        #expect(applied(whole, to: text) == "say this now")

        // A caret INSIDE the content unwraps too.
        let caret = plan(.bold, text, 7..<7)
        #expect(applied(caret, to: text) == "say this now")
    }

    @Test func aCaretJUSTOUTSIDEASpanStartsNewEmphasisInsteadOfUndoingTheOld() {
        // Typing on past `**bold**` and pressing ⌘B must begin the next bold,
        // not silently unwrap the word behind the caret.
        let text = "say **this** now"
        let after = plan(.bold, text, 12..<12)  // immediately after the closing **
        #expect(applied(after, to: text) == "say **this****** now")
        let before = plan(.bold, text, 4..<4)  // immediately before the opening **
        #expect(applied(before, to: text) == "say ******this** now")
    }

    @Test func aDifferentKindsSpanIsNotUnwrapped() {
        let text = "say *this* now"
        let bold = plan(.bold, text, range(of: "this", in: text))
        #expect(applied(bold, to: text) == "say ***this*** now")
    }

    // MARK: - The inline family across lines

    @Test func aMultiLineSelectionWrapsEACHLineAndSkipsTheBlankOnes() {
        // The tokenizer is line-scoped BY LAW (a span never crosses a
        // newline, which is also why it can never cross a block seam), so a
        // single pair of markers around a multi-line selection would be
        // literal text. Per-line is what the format can actually express.
        let text = "one\n\ntwo"
        let bold = plan(.bold, text, 0..<8)
        #expect(applied(bold, to: text) == "**one**\n\n**two**")
        #expect(bold.edits.count == 4, "two lines wrapped, the blank one untouched")
    }

    /// DISCRIMINATING REVERT: turn `wrapPlan`'s `allSatisfy` into `contains`
    /// and the first case fails — a selection with one bold line and one bare
    /// one would UNWRAP the bold instead of bolding the bare.
    @Test func aMultiLineSelectionUnwrapsOnlyWhenEVERYPieceIsWrapped() {
        let mixed = "**one**\ntwo"
        let wrapping = plan(.bold, mixed, 0..<11)
        #expect(applied(wrapping, to: mixed) == "**one**\n**two**",
                "one piece is bare, so the act WRAPS the bare one and leaves the other")

        let both = "**one**\n**two**"
        let clearing = plan(.bold, both, 0..<15)
        #expect(applied(clearing, to: both) == "one\ntwo")
    }

    // MARK: - The line family (headings, bullets, checkboxes)

    @Test func aLineLeadIsSetAtTheLinesFirstCharacter() {
        let text = "a thought"
        #expect(applied(plan(.heading(level: 1), text, 2..<2), to: text) == "# a thought")
        #expect(applied(plan(.heading(level: 2), text, 2..<2), to: text) == "## a thought")
        #expect(applied(plan(.heading(level: 3), text, 2..<2), to: text) == "### a thought")
        #expect(applied(plan(.bullet, text, 2..<2), to: text) == "- a thought")
        #expect(applied(plan(.checkbox, text, 2..<2), to: text) == "- [ ] a thought")
    }

    @Test func aLineLeadTogglesOffWhenItIsAlreadyExactlyThatLead() {
        #expect(applied(plan(.heading(level: 1), "# a", 2..<2), to: "# a") == "a")
        #expect(applied(plan(.bullet, "- a", 2..<2), to: "- a") == "a")
        #expect(applied(plan(.checkbox, "- [ ] a", 6..<6), to: "- [ ] a") == "a")
        // A CHECKED box is still a checkbox — the act is "this line is a
        // checkbox", not "this line is unchecked".
        #expect(applied(plan(.checkbox, "- [x] a", 6..<6), to: "- [x] a") == "a")
    }

    @Test func settingALeadREPLACESWhateverLeadTheLineHad() {
        // The three line kinds are mutually exclusive to the tokenizer;
        // prefixing instead of replacing would make `- # Title`, whose `#`
        // reads as literal text.
        #expect(applied(plan(.bullet, "# a", 2..<2), to: "# a") == "- a")
        #expect(applied(plan(.checkbox, "- a", 2..<2), to: "- a") == "- [ ] a")
        #expect(applied(plan(.bullet, "- [x] a", 6..<6), to: "- [x] a") == "- a")
        #expect(applied(plan(.heading(level: 2), "# a", 2..<2), to: "# a") == "## a")
    }

    @Test func aMultiLineLeadClearsOnlyWhenEVERYLineCarriesIt() {
        let mixed = "- one\ntwo"
        #expect(applied(plan(.bullet, mixed, 0..<9), to: mixed) == "- one\n- two")
        let both = "- one\n- two"
        #expect(applied(plan(.bullet, both, 0..<11), to: both) == "one\ntwo")
    }

    @Test func aBlankLineInsideAMultiLineSelectionKeepsItsShape() {
        let text = "one\n\ntwo"
        #expect(applied(plan(.bullet, text, 0..<8), to: text) == "- one\n\n- two")
        // …but a lone blank line IS bulleted — "caret on an empty line, start
        // a list" is the everyday gesture.
        #expect(applied(plan(.bullet, "", 0..<0), to: "") == "- ")
    }

    @Test func aSelectionEndingAtALinesFirstCharacterDoesNotReachThatLine() {
        let text = "one\ntwo"
        #expect(applied(plan(.bullet, text, 0..<4), to: text) == "- one\ntwo")
    }

    @Test func theCaretRidesTheLeadItJustGained() {
        let text = "a thought"
        #expect(selected(plan(.bullet, text, 0..<0), in: text) == "- |a thought")
        #expect(selected(plan(.bullet, text, 2..<2), in: text) == "- a |thought")
        // …and comes back with it when the lead goes.
        #expect(selected(plan(.bullet, "- a", 2..<2), in: "- a") == "|a")
    }

    // MARK: - L9's click

    /// DISCRIMINATING REVERT: relax `checkboxToggle`'s strict bounds to
    /// `<=` / `<=` and the two boundary expectations below fail — which is
    /// exactly the behaviour that would let a click aimed at the text toggle
    /// a box instead.
    @Test func aClickInsideTheBoxTogglesItAndNowhereElseDoes() throws {
        let text = "- [ ] milk"
        // The box occupies 2..<5; strictly inside is 3 and 4.
        let toggled = try #require(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 3))
        #expect(toggled.range == 2..<5)
        #expect(toggled.replacement == "[x]")
        #expect(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 4) != nil)
        // The BOUNDARIES are not hits: a click on the half-character outside
        // the box yields these very indices, and eating those clicks would
        // steal a caret the writer aimed at the text.
        #expect(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 2) == nil)
        #expect(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 5) == nil)
        #expect(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 7) == nil)
    }

    @Test func aCheckedBoxTogglesBackAndTheEditIsAlwaysThreeForThree() throws {
        let text = "- [x] milk"
        let toggled = try #require(MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 3))
        #expect(toggled.replacement == "[ ]")
        #expect(toggled.range.count == toggled.replacement.utf16.count,
                "same length ⇒ every offset in the note survives, caret included")
        // A bullet is not a checkbox, and neither is a malformed box.
        #expect(MarkdownEditing.checkboxToggle(inLines: "- milk", insertionIndex: 1) == nil)
        #expect(MarkdownEditing.checkboxToggle(inLines: "- [?] milk", insertionIndex: 3) == nil)
    }

    @Test func aClickFindsTheBoxOnTheLineItLandedOn() throws {
        let text = "- [ ] one\n- [x] two"
        let second = try #require(
            MarkdownEditing.checkboxToggle(inLines: text, insertionIndex: 13))
        #expect(second.range == 12..<15)
        #expect(second.replacement == "[ ]")
    }

    // MARK: - Shape guarantees the applier depends on

    @Test func editsComeBackAscendingAndDisjoint() {
        let text = "one\ntwo\nthree"
        for act: MarkdownEditing.Act in [
            .bold, .italic, .strikethrough, .code, .link,
            .heading(level: 2), .bullet, .checkbox,
        ] {
            let edits = plan(act, text, 0..<13).edits
            for (a, b) in zip(edits, edits.dropFirst()) {
                #expect(a.range.upperBound <= b.range.lowerBound,
                        "\(act): ascending and disjoint")
            }
        }
    }

    @Test func headingLevelsAreClampedToTheThreeTheTokenizerReads() {
        // F-3 names three sizes; a fourth `#` is plain text to the tokenizer,
        // so a caller asking for one must never mint invisible syntax.
        #expect(applied(plan(.heading(level: 9), "a", 0..<0), to: "a") == "### a")
        #expect(applied(plan(.heading(level: 0), "a", 0..<0), to: "a") == "# a")
    }

    @Test func anOutOfRangeSelectionIsClampedRatherThanTrapping() {
        let text = "one"
        #expect(applied(plan(.bullet, text, -5..<99), to: text) == "- one")
        #expect(applied(plan(.bold, text, 99..<99), to: text) == "one****")
    }

    @Test func offsetsAreUTF16AndSurviveGraphemesWiderThanOne() {
        // 👩‍👩‍👧 is one Character and several UTF-16 units; a marker range that
        // split it would corrupt the text.
        let text = "hi 👩‍👩‍👧 there"
        let family = range(of: "👩‍👩‍👧", in: text)
        let bold = plan(.bold, text, family)
        #expect(applied(bold, to: text) == "hi **👩‍👩‍👧** there")
    }

    // MARK: - Links (13g batch 4, L10 — the Add Link act)

    /// The act her brief names: a selection becomes `[selection]()` with the
    /// caret in the PARENS, because the words are already written and the
    /// ADDRESS is what the next keystroke supplies.
    @Test func addLinkWrapsTheSelectionAndLeavesTheCaretInTheParens() {
        let text = "read the notes later"
        let link = plan(.link, text, range(of: "the notes", in: text))
        #expect(applied(link, to: text) == "read [the notes]() later")
        #expect(selected(link, in: text) == "read [the notes](|) later")
    }

    /// With nothing selected the caret lands in the BRACKETS instead — the
    /// text is what she is about to type.
    @Test func addLinkWithNoSelectionLeavesTheCaretInTheBrackets() {
        let text = "read  later"
        let link = plan(.link, text, 5..<5)
        #expect(applied(link, to: text) == "read []() later")
        #expect(selected(link, in: text) == "read [|]() later")
        #expect(link.edits.count == 1, "one edit, so the plan stays disjoint")
    }

    /// The family's ruled toggle, applied to links: the act on a piece that
    /// is ALREADY a link removes it — and the whole `](url)` goes with the
    /// brackets, because a URL belongs to the link it named. (⌘Z puts it
    /// back, like every other formatting act.)
    @Test func addLinkOnAnExistingLinkREMOVESItWithItsAddress() {
        let text = "read [the notes](https://x.test/a) later"
        let inside = plan(.link, text, range(of: "notes", in: text))
        #expect(applied(inside, to: text) == "read the notes later")

        // …and selecting the WHOLE link, markers included, does the same.
        let whole = plan(.link, text, range(of: "[the notes](https://x.test/a)", in: text))
        #expect(applied(whole, to: text) == "read the notes later")
    }

    /// DISCRIMINATING REVERT: drop `act.wrapsFirstLineOnly` from `plan`'s
    /// line filter and this fails — a two-line selection mints TWO empty
    /// links (`[one]()\n[two]()`), and only one of them could hold the caret.
    ///
    /// **Links act on ONE line** — a build-time call (QUESTIONS #50), and the
    /// one place the link act deliberately parts company with the emphasis
    /// four: `**a**\n**b**` is two useful bolds, but two EMPTY links from one
    /// gesture are junk and only one of them could hold the caret.
    @Test func addLinkTakesOnlyTheLineTheSelectionSTARTSOn() {
        let text = "one\ntwo"
        let link = plan(.link, text, 0..<7)
        #expect(applied(link, to: text) == "[one]()\ntwo")

        // The contrast, pinned beside it so the difference is deliberate.
        let bold = plan(.bold, text, 0..<7)
        #expect(applied(bold, to: text) == "**one**\n**two**")
    }

    /// A caret JUST OUTSIDE a link starts a new one rather than removing the
    /// old — the same adjacency rule the emphasis four keep.
    @Test func aCaretJustAfterALinkStartsANewOne() {
        let text = "see [docs](https://x.test)"
        let link = plan(.link, text, 26..<26)
        #expect(applied(link, to: text) == "see [docs](https://x.test)[]()")
    }

    // MARK: - P1: the scan is the LINES, never the note

    #if DEBUG  // MarkdownScanCount is a DEBUG-only oracle (VX-345)
    @Test func planningScansOnlyTheLinesItWasHanded() {
        // The app hands whole lines in and shifts the result, exactly as
        // `MarkdownStyling.restyle` does — so this pin is what makes "⌘B
        // costs the lines it touches" checkable rather than asserted. The
        // counter lives on the scanner itself, so it cannot read zero against
        // a caller that scans everything.
        let lines = "one two three"
        MarkdownScanCount.reset()
        _ = plan(.bold, lines, 4..<7)
        #expect(MarkdownScanCount.current == lines.utf16.count,
                "one scan, of exactly the text handed in")
    }
    #endif
}

/// **13k K5 — what ⏎ does on a list line** (her ruling: *⏎ at the end of a
/// texted list line mints the next lead; ⏎ on an EMPTY list item removes the
/// lead and exits the list*).
///
/// The rule is deliberately a VERDICT, not a plan: the continuation half
/// hands back a LEAD for the caller to insert AFTER the ratified newline has
/// landed, precisely so the newline itself stays the single typed `"\n"`
/// every structural rule keys on (the open-tail gesture at the document end,
/// `one_block`'s newlines-don't-mint, A15's ⇧⏎, the idle-mint).
@Suite("The ⏎ list rule (13k K5)")
struct MarkdownReturnKeyTests {
    private func verdict(_ line: String, at offset: Int) -> MarkdownEditing.ReturnKey {
        MarkdownEditing.returnKey(inLines: line, at: offset)
    }

    @Test func aTextedBulletMintsTheNextBullet() {
        #expect(verdict("- milk", at: 6) == .continueList(lead: "- "))
    }

    /// A continued checklist item is born UNCHECKED — the same call
    /// `Act.checkbox` makes (QUESTIONS #49(h): checking is the click).
    @Test func aTextedChecklistItemMintsAnUNCHECKEDBox() {
        #expect(verdict("- [ ] milk", at: 10) == .continueList(lead: "- [ ] "))
        #expect(verdict("- [x] milk", at: 10) == .continueList(lead: "- [ ] "))
    }

    /// The exit half — the ONE case where ⏎ is consumed and no newline is
    /// inserted at all. The range is exactly the LEAD: anything past it is
    /// text she typed and stays.
    @Test func anEmptyListItemExitsTheListByLosingItsLead() {
        #expect(verdict("- ", at: 2) == .exitList(lead: 0..<2))
        #expect(verdict("- [ ]", at: 5) == .exitList(lead: 0..<5))
        #expect(verdict("- [ ] ", at: 6) == .exitList(lead: 0..<6))
        // Whitespace is not content — an item with only spaces in it is
        // still an empty item, and only the lead goes.
        #expect(verdict("- [ ]   ", at: 8) == .exitList(lead: 0..<6))
    }

    /// **The caret must be at the line's END** — her ruling's letter. A caret
    /// mid-item splits the item without leading the remainder; widening this
    /// is one comparison (a recorded build-time call).
    @Test func onlyACaretAtTheLinesEndContinuesOrExits() {
        #expect(verdict("- milk", at: 0) == .ordinary)
        #expect(verdict("- milk", at: 3) == .ordinary)
        #expect(verdict("- ", at: 1) == .ordinary)
    }

    /// A heading is not a list. Her ruling names the two list leads, and a
    /// second `# ` under every heading is nobody's intent.
    @Test func headingsAndPlainProseAreOrdinary() {
        #expect(verdict("# Title", at: 7) == .ordinary)
        #expect(verdict("## Title", at: 8) == .ordinary)
        #expect(verdict("plain prose", at: 11) == .ordinary)
        #expect(verdict("", at: 0) == .ordinary)
        // 13k K8 UPDATED THIS EXPECTATION DELIBERATELY. It read
        // `verdict("  - milk", at: 8) == .ordinary` — the column-0 law, which
        // this batch widened for LIST leads on her ruling. An indented list
        // item is a list item now, and it continues at its own level.
        #expect(verdict("  - milk", at: 8) == .continueList(lead: "  - "))
        // What did NOT widen: an indented HEADING is still plain text.
        #expect(verdict("  # Title", at: 9) == .ordinary)
        // `*` is not a bullet (13g batch 2: it collides with italic).
        #expect(verdict("* milk", at: 6) == .ordinary)
    }

    /// The rule reads the caret's OWN line when handed several, and answers
    /// in the offsets it was handed (the `checkboxToggle` shape).
    @Test func offsetsComeBackRelativeToTheTextHandedIn() {
        let two = "- milk\n- "
        #expect(verdict(two, at: 6) == .continueList(lead: "- "))
        #expect(verdict(two, at: 9) == .exitList(lead: 7..<9))
    }

    /// Emphasis inside the item does not disturb the verdict — a line-leading
    /// span's content IS inline-scanned (13g batch 2's one exception), and
    /// the leading span still covers the whole line.
    @Test func anItemCarryingEmphasisStillContinues() {
        #expect(verdict("- **bold** milk", at: 15) == .continueList(lead: "- "))
        #expect(verdict("- [ ] `code`", at: 12) == .continueList(lead: "- [ ] "))
    }
}
