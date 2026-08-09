//
//  MobileMarkdownActs.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 2 (M11's first half) — the phone's THIN door over
//  the shared markdown brain. The law lives in `VariorumCore/Domain`
//  (`MarkdownSyntax`/`MarkdownEditing`); the line-lookup-and-rebase
//  arithmetic is `MarkdownSurfaceDoors` (Shared/EditorBrain, the parity
//  move); what THIS file owns is exactly the platform trio the Mac's
//  `MarkdownActs` owns over NSTextView — HERE it is UIKit's ordinary input
//  path: pre-gate through the UITextViewDelegate (the batch-1 verdict gate,
//  so every act edit is policed exactly like typing — autosave, churn,
//  refusals, the re-stamp, all for free), then `insertText`/`deleteBackward`
//  on the view so UIKit's own caret, undo, and input-system bookkeeping ride
//  along.
//
//  **A formatting act is an ordinary edit, applied through the ordinary
//  input path** — the Mac file's one architectural claim, held verbatim on
//  the phone. Nothing here writes a row, adds an operation, or touches a
//  schema; under F-1 the markers ARE the text. And no act can restructure a
//  note: every edit the brain emits sits inside ONE LINE, and a line sits
//  inside one block (blocks joined by a single "\n"), so the cross-block
//  refusal is unreachable from here by construction.
//

import UIKit
import VariorumCore

@MainActor
enum MobileMarkdownActs {
    // MARK: - The policed input-path primitives

    /// The batch-1 gate, asked the way the keyboard asks it. On a view whose
    /// delegate is the editor's gate (the VM installs it at attach) this
    /// arms the pending verdict the storage delegate then consumes — the
    /// exact police typing gets. Asking twice (the keyboard's own consult
    /// plus a door's) is idempotent: same inputs, same verdict.
    static func gateAllows(
        _ textView: UITextView, range: NSRange, replacement: String
    ) -> Bool {
        guard let delegate = textView.delegate,
              let answer = delegate.textView?(
                  textView, shouldChangeTextIn: range, replacementText: replacement)
        else { return true }
        return answer
    }

    /// One ordinary input-path replacement: pre-gate, select, then
    /// `insertText`/`deleteBackward` — UIKit's own editing machinery, so the
    /// storage delegate reports it, the verdict routes, and undo is the
    /// system's business. Returns whether the edit landed (false = refused
    /// or out of bounds; a refusal has already spoken through the gate).
    @discardableResult
    private static func inputReplace(
        _ textView: UITextView, range: NSRange, with replacement: String
    ) -> Bool {
        guard range.location >= 0, range.upperBound <= textView.textStorage.length,
              !(replacement.isEmpty && range.length == 0),
              gateAllows(textView, range: range, replacement: replacement)
        else { return false }
        textView.selectedRange = range
        if replacement.isEmpty {
            // Deleting a selection is the ordinary delete gesture.
            textView.deleteBackward()
        } else {
            textView.insertText(replacement)
        }
        return true
    }

    // MARK: - The acts (the bar's, and hardware Tab/⇧Tab's)

    /// Runs `act` through the ordinary input path. Edits are applied LAST
    /// FIRST so every earlier offset stays valid (the brain's own contract);
    /// a range the gate refuses is SKIPPED — its refusal has already spoken —
    /// and the selection is only re-placed when every edit landed, because a
    /// partly-applied plan's computed selection would be a guess. Returns
    /// whether anything changed (false doubles as the "not ours" fallthrough
    /// signal the Tab door keys on, the Mac `indentLists` shape).
    ///
    /// Marked text bails: mutating the note mid-composition would rewrite an
    /// input-method's in-progress region (the idle-mint takes the same
    /// guard, batch 1).
    @discardableResult
    static func apply(_ act: MarkdownEditing.Act, to textView: UITextView) -> Bool {
        guard textView.isEditable, textView.markedTextRange == nil else { return false }
        guard let plan = MarkdownSurfaceDoors.plan(
            act, document: textView.textStorage.string as NSString,
            selection: textView.selectedRange)
        else { return false }

        var applied = 0
        for edit in plan.edits.reversed()
        where inputReplace(textView, range: edit.range, with: edit.replacement) {
            applied += 1
        }
        guard applied == plan.edits.count else { return applied > 0 }
        textView.selectedRange = plan.selection
        return true
    }

    /// The caret line's current heading level (a selection reads its
    /// START line — the cycle's own rule); nil = not a heading line.
    static func currentHeadingLevel(in textView: UITextView) -> Int? {
        let string = textView.textStorage.string as NSString
        let selection = textView.selectedRange
        guard string.length > 0, selection.location != NSNotFound else { return nil }
        let location = min(selection.location, string.length)
        let lines = string.lineRange(for: NSRange(location: location, length: 0))
        for span in MarkdownSyntax.spans(in: string.substring(with: lines)) {
            if case .heading(let level) = span.kind, span.range.lowerBound == 0 {
                return level
            }
        }
        return nil
    }

    /// **The # button's brain (PROVISIONAL, batch 2):** the phone bar has ONE
    /// heading button where the Mac menu has a three-child submenu, so the
    /// tap CYCLES — no heading → H1 → H2 → H3 → clear (the last step is
    /// `.heading(3)` on an H3 line, which the shared toggle rule clears).
    /// A selection cycles off its START line's state.
    static func headingCycleAct(in textView: UITextView) -> MarkdownEditing.Act {
        guard let level = currentHeadingLevel(in: textView) else {
            return .heading(level: 1)
        }
        return .heading(level: min(level + 1, 3))
    }

    /// **The picker's clear row (P5, parity A3 — her ruled flip: "#
    /// tap still cycles; LONG-PRESS opens a direct H1/H2/H3/clear
    /// picker"):** clearing a heading is the shared toggle rule applied
    /// at the line's OWN level (`.heading(L)` on an H-L line clears —
    /// the Mac submenu's exact semantics, no new vocabulary); a line
    /// with no heading has nothing to clear (nil ⇒ the row no-ops).
    static func headingClearAct(in textView: UITextView) -> MarkdownEditing.Act? {
        currentHeadingLevel(in: textView).map { .heading(level: $0) }
    }

    // MARK: - K5/K8: what ⏎ does on a list line

    /// **The ⏎ door** — the Mac `insertNewlineContinuingLists`' phone twin.
    /// `ordinary` is the caller's own `super.insertText("\n")` — THE
    /// keystroke, invoked unchanged, so the open-tail gesture, `one_block`'s
    /// newlines-don't-mint, the idle mint and every refusal see the same
    /// single typed `"\n"` they always saw. The lead is a SECOND ordinary
    /// insertion at the caret the newline left, through the same gate typing
    /// takes — and it is only inserted if the newline actually landed.
    ///
    /// The exit and outdent halves CONSUME the keystroke — no newline at
    /// all, one policed deletion (the lead of an empty item at level 0; one
    /// indent unit at depth — the 13k K8 outdent-first rule, byte-identical
    /// to her K5 ruling at the margin).
    static func handleReturnKey(in textView: UITextView, ordinary: () -> Void) {
        guard textView.isEditable else {
            ordinary()
            return
        }
        let selection = textView.selectedRange
        guard selection.length == 0, selection.location != NSNotFound,
              selection.location <= textView.textStorage.length
        else {
            // A selection's ⏎ is deliberately ordinary — the ruling is about
            // a caret at the end of a line (the Mac's letter).
            ordinary()
            return
        }
        switch MarkdownSurfaceDoors.returnVerdict(
            document: textView.textStorage.string as NSString,
            caret: selection.location) {
        case .ordinary:
            ordinary()

        case .continueList(let lead):
            // Pre-gate the newline so the door's own path polices exactly
            // what the keyboard path polices (a sealed note refuses HERE,
            // as the Mac's `super.insertNewline` would through its own
            // delegate; the keyboard's earlier gate consult armed the same
            // verdict — arming twice is idempotent).
            guard gateAllows(textView, range: selection, replacement: "\n") else { return }
            let before = textView.textStorage.length
            ordinary()
            // The lead is only inserted if the newline actually landed.
            guard textView.textStorage.length == before + 1 else { return }
            let caret = textView.selectedRange
            guard caret.length == 0 else { return }
            _ = inputReplace(textView, range: caret, with: lead)

        case .exitList(let lead):
            consumeDelete(textView, lead)

        case .outdentItem(let unit):
            consumeDelete(textView, unit)
        }
    }

    /// One policed deletion, no newline — the shape both consuming ⏎
    /// verdicts take. The caret returns to where the Mac's would land:
    /// shifted left by exactly the deleted run (NSTextView adjusts a caret
    /// past a deletion this way on its own; UIKit's deleteBackward leaves it
    /// at the deletion point, so the phone re-places it).
    private static func consumeDelete(_ textView: UITextView, _ span: Range<Int>) {
        let caret = textView.selectedRange
        let range = NSRange(location: span.lowerBound, length: span.count)
        guard inputReplace(textView, range: range, with: "") else { return }
        textView.selectedRange = NSRange(
            location: max(range.location, caret.location - range.length), length: 0)
    }

    // MARK: - The checkbox tap (scope item 4)

    /// A tap landing ON a checkbox's box toggles it — one ordinary policed
    /// edit of three characters for three, so every offset in the note (the
    /// caret included) is exactly where it was. The strictly-inside decision
    /// is the shared door's (`MarkdownEditing.checkboxToggle` carries the
    /// boundary reasoning); a refusal has already spoken through the gate
    /// and the tap is still consumed, because it landed on a box and moving
    /// the caret there instead would be answering a different gesture (the
    /// Mac `toggleCheckbox`'s exact posture).
    @discardableResult
    static func toggleCheckbox(at point: CGPoint, in textView: UITextView) -> Bool {
        guard textView.isEditable, textView.markedTextRange == nil else { return false }
        let string = textView.textStorage.string as NSString
        guard string.length > 0,
              let position = textView.closestPosition(to: point)
        else { return false }
        let index = textView.offset(from: textView.beginningOfDocument, to: position)
        guard let edit = MarkdownSurfaceDoors.checkboxToggleEdit(
            document: string, insertionIndex: index)
        else { return false }

        let selection = textView.selectedRange
        if inputReplace(textView, range: edit.range, with: edit.replacement) {
            // Three characters for three — the caret goes back where it was.
            textView.selectedRange = selection
        }
        return true
    }
}

// MARK: - The tap's router

/// The checkbox tap recognizer's delegate + target — a separate object
/// because UIScrollView already adopts `UIGestureRecognizerDelegate`, and
/// overriding optional protocol methods on the view would be fighting the
/// superclass's own conformance. The DECISION runs at receive time
/// (`shouldReceive`), so a tap anywhere but strictly inside a box is never
/// consumed and the ordinary caret tap proceeds untouched — the Mac's
/// before-`super.mouseDown` claim, in UIKit's grammar.
@MainActor
final class MobileCheckboxTapRouter: NSObject, UIGestureRecognizerDelegate {
    private weak var textView: MobileEditorTextView?

    init(textView: MobileEditorTextView) {
        self.textView = textView
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch
    ) -> Bool {
        guard let textView, textView.isEditable, textView.markedTextRange == nil
        else { return false }
        let point = touch.location(in: textView)
        let string = textView.textStorage.string as NSString
        guard string.length > 0,
              let position = textView.closestPosition(to: point)
        else { return false }
        let index = textView.offset(from: textView.beginningOfDocument, to: position)
        return MarkdownSurfaceDoors.checkboxToggleEdit(
            document: string, insertionIndex: index) != nil
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let textView else { return }
        _ = MobileMarkdownActs.toggleCheckbox(
            at: recognizer.location(in: textView), in: textView)
    }
}
