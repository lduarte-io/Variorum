//
//  OrdinaryInputEdit.swift
//  Variorum
//
//  **Phase 13u1, UNIT 1 — item 7: the Mac's arm-then-hand-off residual.**
//
//  ── What this type is ────────────────────────────────────────────────────
//
//  ONE ordinary edit through the ordinary input path: the gate, the
//  mutation and the notification as a SINGLE call. Every Mac surface that
//  writes text the way typing does goes through here.
//
//  ── Why it exists, traced ────────────────────────────────────────────────
//
//  The editor's two-phase protocol is: `shouldChangeText` computes a verdict
//  against the PRE-edit index and ARMS it (`EditorViewModel.pendingEdit`);
//  the storage mutation then lands and `storageDidEdit` CONSUMES the arming.
//  Written as two statements, the pair is separable — and `storageDidEdit`'s
//  own comment has named the hazard by name since mobile round 2:
//
//      "Any of the arm-then-hand-off sites (`MarkdownActs.apply`,
//       `toggleCheckbox`, `insertNewlineContinuingLists`,
//       `deleteWithoutNewline`) is one refactor away from separating an
//       arming from its `replaceCharacters`; the binding makes that
//       harmless."
//
//  **The binding is real and this type does not replace it.** `ArmedEdit.
//  describes(…)` refuses to let an arming be consumed by an edit it does not
//  describe, so an abandoned arming falls through to `fallbackVerdict`
//  rather than applying the wrong bookkeeping to the wrong region — that is
//  mobile round 2's crash fix and it stays exactly as it is.
//
//  **What was left, precisely, and it was not a bug.** Every one of the five
//  Mac sites put `shouldChangeText` as the LAST condition of its guard with
//  `replaceCharacters` on the next line, so on 2026-09-14 no site armed and
//  abandoned — the residual was that nothing STOPPED one from doing so, and
//  the comment above says as much ("one refactor away"). A door with no
//  expressible gap is cheaper than a rule a future reader has to know: after
//  this, arming without applying is not something a call site can write.
//
//  So this is a structural change with **no behaviour change at all**, and
//  the proof is that every existing pin rides unmodified (the hoist
//  discipline's zero-test-edit standard) plus a grep pin
//  (`OneInputPathTests`) that fails the build's suite if a second call site
//  for AppKit's `shouldChangeText(in:replacementString:)` ever appears.
//

import AppKit
import Foundation

@MainActor
enum OrdinaryInputEdit {
    /// Applies one edit through the ordinary input path — `shouldChangeText`
    /// → `replaceCharacters` → `didChangeText` — and answers whether it
    /// landed. `false` means the pipeline refused (a sealed note, a locked
    /// take, a desynced index, a cross-block span the delegate defers), and
    /// the refusal has already spoken in its own words: a caller adds no
    /// message of its own.
    ///
    /// - Parameters:
    ///   - followingCaret: `false` runs the mutation inside
    ///     `EditorTextView.withoutCaretFollow` — the Act 10 item 11 carve
    ///     for an edit a CLICK caused rather than typing, where the caret
    ///     clearance in `didChangeText` would otherwise scroll the view to a
    ///     caret the click never moved (measured 6,103 pt; `CheckboxScrollTests`).
    ///     Only meaningful on an `EditorTextView`; harmless elsewhere.
    ///   - underFindReplace: `true` brackets BOTH the gate and the mutation
    ///     in `EditorTextView.withFindReplace` — the find bar's own
    ///     discipline, which the delegate reads to tell a hand-written 1:1
    ///     replacement from ordinary typing. It is a parameter rather than
    ///     an exemption precisely so the find road can use this door too and
    ///     the "one input path" claim needs no footnote.
    @discardableResult
    static func apply(
        _ replacement: String,
        over range: NSRange,
        in textView: NSTextView,
        followingCaret: Bool = true,
        underFindReplace: Bool = false
    ) -> Bool {
        let editor = underFindReplace ? textView as? EditorTextView : nil
        let allowed: Bool
        if let editor {
            allowed = editor.withFindReplace {
                editor.shouldChangeText(in: range, replacementString: replacement)
            }
        } else {
            allowed = textView.shouldChangeText(in: range, replacementString: replacement)
        }
        guard allowed else { return false }

        let mutate = {
            textView.replaceCharacters(in: range, with: replacement)
            textView.didChangeText()
        }
        if let editor {
            editor.withFindReplace(mutate)
        } else if !followingCaret, let editor = textView as? EditorTextView {
            editor.withoutCaretFollow(mutate)
        } else {
            mutate()
        }
        return true
    }
}
