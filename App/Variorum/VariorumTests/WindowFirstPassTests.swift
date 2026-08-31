//
//  WindowFirstPassTests.swift
//  VariorumTests
//
//  Phase 13e batch 8, RIDER 1 — the note-only window's CLIPPED TOP
//  (`notes/KnownIssuesAndTechDebt.md`, her 13g batch-6 report: *"opening in a
//  new window seems to be working pretty well but there is this bug where the
//  top of it i couldn't scroll to (where it says Untitled) and it was cut
//  off."*).
//
//  ── THE MECHANISM, MEASURED (not inferred) ──────────────────────────────
//  13g batch 6 reproduced it, instrumented it, and built three fixes that all
//  measured wrong. What it could not explain was *what the resize
//  invalidates*. The answer turned out to be upstream of the repair: at the
//  13g tree `ContextBar.hasContent` read
//
//      var hasContent: Bool { originLabel != nil || !books.isEmpty }
//
//  and a note-only window has NO history, so `originLabel` is always nil
//  (`NoteWindowView` passes `onBack: {}` and records nothing — its own file
//  says the back half is "honestly empty"). That leaves `!books.isEmpty` —
//  and `books` is filled by `PaneHost`'s `.task(id: noteID) { await
//  loadBooks() }`, i.e. AFTER the window's first presentation. So for a note
//  IN A BOOK the bar and its divider were INSERTED ABOVE THE MASTHEAD one
//  runloop late, and the already-presented pixels were never re-composited
//  for the insertion: the masthead kept the position it was drawn at and its
//  top rode under the band that had appeared above it. Any resize forces the
//  window's content to redisplay, which repairs it permanently — her "I
//  couldn't scroll to it", exactly.
//
//  That also explains the reproduction's odd precondition ("a note IN A
//  BOOK, so the context bar renders"): a BOOKLESS note never grew a bar and
//  never clipped.
//
//  ── PROVEN BY BEHAVIORAL REVERT ON THE LIVE APP (2026-08-18) ────────────
//  HEAD does not reproduce: a note in a book, opened in a fresh note-only
//  window, drew its masthead whole (capture `note2top.png`). Reverting
//  `ContextBar.hasContent` to the 13g expression above and rebuilding
//  reproduced the defect exactly — the title clipped to a sliver along its
//  top edge, with "Write ▾" and the inspector icons clipped beside it
//  (`revert_note.png`) — and a resize repaired it permanently
//  (`revert_after_resize.png`), matching every recorded symptom. The file was
//  restored, checksum-verified (`eda2131a…9279`).
//
//  ── WHAT FIXED IT, AND WHY THIS PIN EXISTS ──────────────────────────────
//  Nothing in this batch: **13k K11 fixed it as a side effect** when the
//  context bar was rebuilt as a constant icon row and `hasContent` gained its
//  `isNote` term. That is a fix nobody knew they had made, held by nothing —
//  so this pin states the property the fix created: **a note-only window's
//  bar has content on the FIRST pass, before any async read returns.** It is
//  red on the 13g rule (the revert above) and green on HEAD.
//

import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The note-only window's first pass (13e rider 1)")
struct NoteWindowFirstPassTests {
    private func bar(books: [Reading], isNote: Bool, origin: String? = nil) -> ContextBar {
        ContextBar(
            tokens: .fallback(for: .light), originLabel: origin, forwardLabel: nil,
            books: books, isNote: isNote,
            onBack: {}, onForward: {}, onOpenBook: { _ in })
    }

    /// **The clip's own precondition, closed.** A note-only window has no
    /// history and its books arrive from an async read — so on the first pass
    /// it holds a note and NOTHING ELSE. If the bar can be absent in that
    /// state, it appears above the masthead a runloop later and the top of
    /// the window is clipped until she resizes it.
    @Test func aNoteOnlyWindowsBarIsThereBeforeItsBooksAre() {
        #expect(bar(books: [], isNote: true).hasContent,
                "no history, no books yet — and still a bar, so nothing arrives above the masthead")
    }

    /// …and the same fact stated where the rule lives, so a future edit to
    /// either home is caught.
    @Test func theRuleItselfSaysANoteIsEnoughOnItsOwn() {
        #expect(ContextBarDoors.hasContent(
            isNote: true, canBack: false, canForward: false, bookCount: 0))
    }

    /// The pin is not "always true": a pane at the shelf still has no bar, so
    /// a cold launch keeps exactly the chrome it had before any of this
    /// shipped (`ContextBar`'s own comment). Without this half, deleting the
    /// gate entirely would pass the pin above.
    @Test func aPaneHoldingNoNoteStillHasNoBarAtAll() {
        #expect(!bar(books: [], isNote: false).hasContent)
        // …and the shelf's bar DOES appear once there is somewhere to go back
        // to, which is the pre-13k behaviour that was never wrong.
        #expect(bar(books: [], isNote: false, origin: "Library").hasContent)
    }
}
