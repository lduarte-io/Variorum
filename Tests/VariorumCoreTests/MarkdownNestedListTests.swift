import Foundation
import Testing
@testable import VariorumCore

/// **Phase 13k, K8 — indented (nested) lists.**
///
/// Her ruling: *"we should allow indented lists and it should happen when you
/// click tab"*; sitting Q3 ruled ⇧Tab + Format ▸ Indent/Outdent as the way
/// back. The architect ruled all six of the batch's proposed calls: the unit
/// is TWO SPACES, the tokenizer reads spaces AND tabs (`tabs + floor(spaces/2)`)
/// UNCAPPED and LIST-ONLY, Read indents per level with one glyph (clamped at 6
/// where it DRAWS), the checkbox target is unchanged in kind, ⏎ on an empty
/// NESTED item OUTDENTS FIRST, and the two menu rows carry no shortcut label.
///
/// This suite pins the Domain half; the doors and the surfaces are pinned in
/// the Mac suite.
@Suite("Nested lists — the Domain half (13k K8)")
struct MarkdownNestedListTests {

    private func spans(_ text: String) -> [MarkdownSyntax.Span] {
        MarkdownSyntax.spans(in: text)
    }

    private func slice(_ text: String, _ range: Range<Int>) -> String {
        (text as NSString).substring(
            with: NSRange(location: range.lowerBound, length: range.count))
    }

    // MARK: - The tokenizer's widening

    /// DISCRIMINATING REVERT: put the shipped `guard chars[start] == "-"` back
    /// (i.e. drop the indent scan) and every indented case below reads as
    /// prose — `kinds` comes back empty — while the column-0 cases stay green.
    @Test func anIndentedListLeadIsAListLeadAndCarriesItsLEVEL() throws {
        #expect(spans("- milk").first?.indentLevel == 0)
        #expect(spans("  - milk").first?.kind == .bullet)
        #expect(spans("  - milk").first?.indentLevel == 1, "two spaces = one level")
        #expect(spans("    - milk").first?.indentLevel == 2)
        #expect(spans("\t- milk").first?.indentLevel == 1, "a tab is one level")
        #expect(spans("\t  - milk").first?.indentLevel == 2, "they sum")
        // An ODD count lands between levels — which is what the stored text
        // says, and nothing here ever rewrites it.
        #expect(spans("   - milk").first?.indentLevel == 1)
        // Uncapped: the transform reports what the text says (a surface may
        // clamp what it DRAWS — that is the look's call, not this one).
        #expect(spans(String(repeating: " ", count: 40) + "- deep").first?.indentLevel == 20)

        // The whole lead — indent included — is `markers[0]`, so a reading
        // surface that substitutes the lead strips the indent for free.
        let nested = "  - milk"
        let span = try #require(spans(nested).first)
        #expect(slice(nested, span.markers[0]) == "  - ")
        #expect(slice(nested, span.content) == "milk")
        #expect(span.range == 0..<8, "the span still covers its whole line")
    }

    @Test func anIndentedCHECKBOXKeepsItsBoxAsMarkersOne() throws {
        let nested = "    - [x] wash up"
        let span = try #require(spans(nested).first)
        #expect(span.kind == .checkbox(checked: true))
        #expect(span.indentLevel == 2)
        // THE claim behind "the click target is unchanged in kind": the box is
        // still `markers[1]`, it has only moved right.
        #expect(slice(nested, span.markers[0]) == "    - ")
        #expect(slice(nested, span.markers[1]) == "[x]")
        #expect(slice(nested, span.content) == "wash up")

        // …and the toggle finds it there, with the same strict-inside rule.
        let box = span.markers[1]
        #expect(MarkdownEditing.checkboxToggle(
            inLines: nested, insertionIndex: box.lowerBound) == nil, "the boundary is not inside")
        #expect(MarkdownEditing.checkboxToggle(
            inLines: nested, insertionIndex: box.lowerBound + 1)
            == MarkdownEditing.Edit(range: box, replacement: "[ ]"))
    }

    /// **The widening is LIST-ONLY**, which is exactly what keeps 13g batch
    /// 2's shipped heading rule true: "it starts the line or it is text".
    @Test func anIndentedHEADINGIsStillPlainText() {
        #expect(spans("  # indented").isEmpty)
        #expect(spans("\t## also").isEmpty)
        #expect(spans("# heading").first?.kind == .heading(level: 1))
    }

    @Test func whitespaceAloneIsNeverAList() {
        #expect(spans("    ").isEmpty)
        #expect(spans("  -").isEmpty, "no space after the hyphen ⇒ not a lead")
        #expect(spans("  -milk").isEmpty)
    }

    // MARK: - Indent / outdent as edits

    private func plan(_ act: MarkdownEditing.Act, _ text: String, _ sel: Range<Int>)
        -> MarkdownEditing.Plan
    {
        MarkdownEditing.plan(act, inLines: text, selection: sel)
    }

    private func applied(_ act: MarkdownEditing.Act, _ text: String, _ sel: Range<Int>) -> String {
        let plan = plan(act, text, sel)
        let result = NSMutableString(string: text)
        for edit in plan.edits.reversed() {
            result.replaceCharacters(
                in: NSRange(location: edit.range.lowerBound, length: edit.range.count),
                with: edit.replacement)
        }
        return result as String
    }

    /// DISCRIMINATING REVERT: make `indentPlan` skip its list-lead guard (act
    /// on every affected line) and `aNonListLineIsNEVERTouched` fails — Tab
    /// would silently indent prose, which is the byte-unchanged promise this
    /// row is built on.
    @Test func tabIndentsAListLineByExactlyOneUnit() {
        #expect(applied(.indent, "- milk", 6..<6) == "  - milk")
        #expect(applied(.indent, "  - milk", 8..<8) == "    - milk")
        #expect(applied(.indent, "- [ ] milk", 10..<10) == "  - [ ] milk")
        // Wherever the caret sits in the line — indent is a LINE act, not an
        // end-of-line act like ⏎.
        #expect(applied(.indent, "- milk", 3..<3) == "  - milk")
    }

    @Test func shiftTabTakesOneUnitBackAndStopsAtZero() {
        #expect(applied(.outdent, "    - milk", 10..<10) == "  - milk")
        #expect(applied(.outdent, "  - milk", 8..<8) == "- milk")
        #expect(applied(.outdent, "\t- milk", 7..<7) == "- milk", "a tab is one whole level")
        // At level 0 there is nothing to remove — an EMPTY plan, which is the
        // signal a surface falls through to `super` on.
        #expect(plan(.outdent, "- milk", 6..<6).isEmpty)
        // An odd count gives back what there is rather than over-eating.
        #expect(applied(.outdent, "   - milk", 9..<9) == " - milk")
    }

    /// **13k cold review round 1, MINOR-1 — RED ON THE PRE-FIX CODE.** The
    /// two outdent doors now share ONE unit rule (`outdentUnitLength`). The
    /// ⇧Tab arm used to remove leading SPACES only, stopping at a tab — so
    /// on a pasted `" \t- x"` run (one drawn level: 1 tab + floor(1/2)
    /// spaces) it removed the lone space and the drawn level did not move: a
    /// visibly dead keypress, while ⏎ on the empty twin removed the whole
    /// `" \t"` unit and dropped the level. Both doors now remove the same
    /// unit, so the level genuinely drops.
    ///
    /// DISCRIMINATING REVERT (verified): restore the old space-only loop in
    /// `indentPlan`'s outdent arm and the FIRST expectation fails with
    /// `"\t- milk"` (level unchanged) while the ⏎-door expectation stays
    /// green — the revert is exactly the ⇧Tab arm.
    @Test func aSpaceThenTabRunOutdentsByARealLevelThroughBothDoors() {
        #expect(applied(.outdent, " \t- milk", 8..<8) == "- milk",
                "⇧Tab drops the drawn level — never a dead keypress")
        #expect(verdict(" \t- ", at: 4) == .outdentItem(unit: 0..<2),
                "the ⏎ door removes the same unit — one rule, two doors")
        // The single-tab and pure-space cases are byte-unchanged (pinned
        // above); the shared rule reproduces them exactly.
        #expect(applied(.outdent, "\t - milk", 8..<8) == " - milk",
                "tab-first still goes one whole tab")
    }

    @Test func aNonListLineIsNEVERTouched() {
        for text in ["ordinary prose", "# a heading", "  # an indented heading", "", "   "] {
            #expect(plan(.indent, text, 0..<0).isEmpty,
                    "\(text.debugDescription): Tab is the key it always was here")
            #expect(plan(.outdent, text, 0..<0).isEmpty)
        }
    }

    /// A selection indents every LIST line it touches and leaves the rest
    /// alone — the `leadPlan` blank-line-skip precedent, and the reason a
    /// mixed selection cannot silently indent prose.
    @Test func aSelectionIndentsTheListLinesItTouchesAndNothingElse() {
        let text = "- one\nprose\n- two"
        #expect(applied(.indent, text, 0..<17) == "  - one\nprose\n  - two")
        // A selection touching NO list line leaves an empty plan, so the
        // keystroke is `super`'s.
        #expect(plan(.indent, "prose\nmore prose", 0..<16).isEmpty)
    }

    /// Re-leading a NESTED item keeps its nesting; CLEARING removes the whole
    /// lead, indent and all (the line stops being a list, and a paragraph
    /// indented by two orphan spaces is not what "clear" means).
    @Test func settingALeadOnANestedItemKeepsTheIndentAndClearingRemovesIt() {
        #expect(applied(.checkbox, "  - milk", 8..<8) == "  - [ ] milk")
        #expect(applied(.bullet, "  - [ ] milk", 12..<12) == "  - milk")
        #expect(applied(.bullet, "  - milk", 8..<8) == "milk", "clearing takes the indent too")
    }

    /// **13k cold review round 1, MAJOR-1 — RED ON THE PRE-FIX CODE.** The
    /// indent survives a re-lead ONLY when the new act is itself a list
    /// lead. `leadPlan`'s preservation was act-agnostic, so Format ▸ Heading
    /// on a nested item minted `"  # milk"` — an INDENTED heading, which the
    /// LIST-ONLY widening deliberately cannot read (`anIndentedHEADINGIs
    /// StillPlainText` proves it spans as nothing): neither a heading nor a
    /// list, raw unstyled text, where the same act pre-K8 minted a WORKING
    /// column-0 heading. Heading takes the clearing rationale instead — the
    /// line stops being a list at all — restoring #49(b)'s ratified
    /// replace-the-lead behavior at every depth.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `actKeepsIndent` gate from
    /// `leadPlan`'s indent ternary and the first two expectations fail with
    /// `"  # milk"` / `"    ## milk"` while the list↔list cases above stay
    /// green — the revert is exactly the heading arm.
    @Test func headingOnANestedItemDropsTheIndentAndMintsARealHeading() {
        #expect(applied(.heading(level: 1), "  - milk", 8..<8) == "# milk")
        #expect(applied(.heading(level: 2), "    - [x] milk", 14..<14) == "## milk")
        #expect(applied(.heading(level: 1), "\t- milk", 7..<7) == "# milk",
                "a tab indent goes the same way — no construct can carry it")
        // …and what it minted IS a heading to the one tokenizer.
        #expect(spans("# milk").first?.kind == .heading(level: 1))
        // Column 0 is byte-unchanged: the act still replaces the lead there.
        #expect(applied(.heading(level: 1), "- milk", 6..<6) == "# milk")
    }

    // MARK: - ⏎ at depth

    private func verdict(_ line: String, at offset: Int) -> MarkdownEditing.ReturnKey {
        MarkdownEditing.returnKey(inLines: line, at: offset)
    }

    /// DISCRIMINATING REVERT: return the bare `lead` (drop the `indent +`)
    /// from `returnKey`'s continue arm and this fails — every ⏎ inside a
    /// nested list would collapse the next item to column 0.
    @Test func continuingANestedItemStaysAtItsOwnLevel() {
        #expect(verdict("  - milk", at: 8) == .continueList(lead: "  - "))
        #expect(verdict("    - [x] milk", at: 14) == .continueList(lead: "    - [ ] "),
                "and still born unchecked (#49(h))")
        #expect(verdict("\t- milk", at: 7) == .continueList(lead: "\t- "),
                "a tab-indented item keeps its TAB — this never rewrites her whitespace")
    }

    /// **The ruled call:** an empty NESTED item OUTDENTS first; at level 0 it
    /// exits exactly as her K5 ruling says, byte-identical.
    ///
    /// DISCRIMINATING REVERT: drop the `span.indentLevel > 0` guard and every
    /// nested case below returns `.exitList` over the whole lead — the literal
    /// reading, which is the recorded alternative on QUESTIONS #54(e).
    @Test func anEmptyNESTEDItemOutdentsAndOnlyLevelZeroExits() {
        #expect(verdict("  - ", at: 4) == .outdentItem(unit: 0..<2))
        #expect(verdict("    - [ ] ", at: 10) == .outdentItem(unit: 0..<2))
        #expect(verdict("\t- ", at: 3) == .outdentItem(unit: 0..<1), "one tab, one level")
        // Level 0 — K5's ruling, unchanged.
        #expect(verdict("- ", at: 2) == .exitList(lead: 0..<2))
        #expect(verdict("- [ ] ", at: 6) == .exitList(lead: 0..<6))
    }

    // MARK: - What Read is told

    /// DISCRIMINATING REVERT: stop carrying `span.indentLevel` onto the
    /// rendered line and the level expectations fail while the text ones stay
    /// green — Read would draw every level flush left with its spaces gone,
    /// which is strictly worse than not widening at all.
    @Test func readIsToldTheLevelAndTheIndentIsGoneFromWhatItDraws() throws {
        let rendered = MarkdownRendering.render("- one\n  - two\n    - [x] three")
        #expect(rendered.text == "\u{2022} one\n\u{2022} two\n\u{2611} three",
                "the leading whitespace is part of the lead, so it is substituted away")
        #expect(rendered.lines.map(\.indentLevel) == [0, 1, 2])
        #expect(rendered.lines.map(\.style)
                == [.bullet, .bullet, .checkbox(checked: true)])
        // The DRAWN clamp is a look decision and lives with the look; what the
        // transform reports is uncapped.
        let deep = MarkdownRendering.render(String(repeating: " ", count: 30) + "- deep")
        #expect(deep.lines.first?.indentLevel == 15)
        #expect(MarkdownRendering.maxDrawnIndentLevel == 6)
    }

    /// The line-scoped law is untouched by the widening: an indent run is
    /// leading WHITESPACE of one line, and a span still never crosses a
    /// newline — which is also why it can never cross a block seam.
    @Test func theLineScopedLawSurvivesTheWidening() {
        let text = "- one\n  - two"
        for span in MarkdownSyntax.spans(in: text) {
            #expect(!slice(text, span.range).contains("\n"))
        }
        #expect(MarkdownSyntax.spans(in: text).count == 2)
        #expect(MarkdownSyntax.indentUnit == "  ", "the ruled unit")
    }
}
