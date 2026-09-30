//
//  BookNoteTrailTests.swift
//  VariorumTests
//
//  18o U4 — the RULE behind a book's leaving savepoint (R-18k-6), pure. The
//  mounted pins that prove the book actually reports through it — red on the
//  pre-fix tree — are `BookLeavingSavepointTests`; these hold the table the
//  rule's doc states (`BookNoteTrail.swift`), one row per clause, so a change
//  to what counts as "moving to another note" is loud (QUESTIONS #163 is
//  where that reading is PROVISIONAL).
//

import Testing
@testable import Variorum

@Suite("18o U4 — what counts as moving to another note in a book (BookNoteTrail)")
struct BookNoteTrailTests {

    @Test func theCaretMovingIntoADifferentNoteLeavesTheOneItWasIn() {
        var trail = BookNoteTrail()
        #expect(trail.observe(.live("a")) == nil, "arriving is not leaving")
        #expect(trail.observe(.live("b")) == "a")
        #expect(trail.current == "b")
    }

    @Test func theSameNoteAgainIsNeverALeaving() {
        var trail = BookNoteTrail()
        _ = trail.observe(.live("a"))
        #expect(trail.observe(.live("a")) == nil, "a re-render, a pane regaining focus")
        #expect(trail.observe(.selected("a")) == nil, "the Index's blur keeps the note selected")
        #expect(trail.observe(.live("a")) == nil, "a mode switch inside one note")
        #expect(trail.current == "a")
    }

    /// Clicking out, Read, an unfocused pane — no note is not another note.
    @Test func noNoteIsNotAnotherNote() {
        var trail = BookNoteTrail()
        _ = trail.observe(.live("a"))
        #expect(trail.observe(.empty) == nil)
        #expect(trail.current == "a", "…and 'a' is still the note she was last in")
        #expect(trail.observe(.live("b")) == "a", "the next move leaves it")
    }

    /// The Index's row click (which releases the ring) and a leaf turn in Book
    /// mode point the book at another note without a caret — that is moving
    /// on, and the note she left is forgotten, so it is reported once.
    @Test func pointingAtADifferentNoteWithoutACaretLeavesTheNoteSheWasIn() {
        var trail = BookNoteTrail()
        _ = trail.observe(.live("a"))
        #expect(trail.observe(.selected("b")) == "a")
        #expect(trail.current == nil)
        #expect(trail.observe(.selected("c")) == nil, "nothing is reported twice")
        #expect(trail.observe(.live("c")) == nil, "arriving in a note after moving on leaves nothing")
        #expect(trail.current == "c")
    }

    /// A note she only LOOKED at never enters the trail: the Index's arrival
    /// seed and a spread's pages are selections, never a caret.
    @Test func aNoteOnlyLookedAtIsNeverRemembered() {
        var trail = BookNoteTrail()
        #expect(trail.observe(.selected("seed")) == nil)
        #expect(trail.observe(.selected("page")) == nil)
        #expect(trail.current == nil)
        #expect(trail.observe(.live("b")) == nil, "the looked-at notes are never left")
        #expect(trail.leaveBook() == "b")
    }

    @Test func leavingTheBookLeavesTheNoteSheWasInOnce() {
        var trail = BookNoteTrail()
        #expect(trail.leaveBook() == nil, "a book she never wrote in leaves nothing")
        _ = trail.observe(.live("a"))
        _ = trail.observe(.empty)
        #expect(trail.leaveBook() == "a", "clicked out of, still the note she was in")
        #expect(trail.leaveBook() == nil)
    }
}
