//
//  MobileWriteScrollAuthorityTests.swift
//  VariorumMobileTests
//
//  VM-10 — the Write page's SCROLL AUTHORITY. Her rule, verbatim (2026-10-06):
//  *"showing empty space should be allowed if you scroll there but it
//  shouldn't be forced."* The record is
//  `notes/plans/fixes/vm-10-the-write-scroll-authority.md` (the traced
//  mechanism, the red-on-old numbers, the walk).
//
//  THE MECHANISM (traced by running, the record has the stacks): UIKit's own
//  `-[UITextView _scrollToSelectionIfNeeded]` reveals the selection's LINE
//  rect, and for the document's LAST line that rect is padded by the bottom
//  `textContainerInset` — which on this surface IS the typewriter room (P24),
//  a page tall. Taller than the viewport, the rect is bottom-aligned, so the
//  caret's line lands at the top over a page of empty room. It fires after a
//  typed edit (`textInputDidChange:` — arm 2) and on every relayout while she
//  is first responder, including the keyboard's placement animation (arm 3's
//  fight). No line of ours issues those scrolls; the authority is the text
//  view's one choke point every reveal passes through.
//
//  Every surface here is the REAL `MobileWriteScreen` in a real key window,
//  and every keystroke rides the real door (`MobileEditorTextView.insertText`).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The page's own facts, read off the live text view.
@MainActor
private struct PageReading {
    let offsetY: CGFloat
    let firstVisibleChar: Int
    let caretLineVisible: Bool

    init(_ tv: UITextView) {
        offsetY = tv.contentOffset.y
        let top = CGPoint(x: 30, y: tv.contentOffset.y + 4)
        firstVisibleChar = tv.closestPosition(to: top).map {
            tv.offset(from: tv.beginningOfDocument, to: $0)
        } ?? -1
        let caret = tv.selectedTextRange.map { tv.caretRect(for: $0.end) } ?? .null
        let visible = CGRect(
            x: 0, y: tv.contentOffset.y, width: tv.bounds.width, height: tv.bounds.height)
        caretLineVisible = !caret.isNull && visible.contains(CGPoint(x: caret.midX, y: caret.midY))
    }
}

@MainActor
private func waitForText(_ model: MobileEditorViewModel, _ surface: HostedSurface<MobileWriteScreen>) async {
    for _ in 0..<300 {
        if let tv = model.textView, tv.textStorage.length > 0 { break }
        await surface.settle(1)
    }
    await surface.settle(30)
}

@MainActor
private func seedParagraphs(_ session: AppSession, _ count: Int) async throws -> String {
    try await makePost(session, blocks: (1...count).map {
        "Paragraph \($0) carries enough plain words to wrap across a couple of lines on a phone page."
    })
}

/// A production-clocked model (the screen's own road) — the scroll roads
/// are timing-sensitive, so nothing here stubs a sleep the app would not.
@MainActor
private func host(
    _ session: AppSession, postID: String, router: MobileShellRouter? = nil,
    beginEditing: Bool = false
) -> (MobileEditorViewModel, HostedSurface<MobileWriteScreen>) {
    let model = MobileEditorViewModel(session: session, postID: postID)
    let surface = HostedSurface(
        MobileWriteScreen(
            session: session, postID: postID, router: router,
            beginEditing: beginEditing, editor: model),
        size: CGSize(width: 402, height: 874))
    return (model, surface)
}

/// Places the caret at the document's end with its line the LAST visible
/// line — the ordinary journaling position, where her ⏎ lands.
@MainActor
private func caretAtEndOnTheViewportFoot(
    _ tv: UITextView, _ surface: HostedSurface<MobileWriteScreen>
) async {
    tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
    // Setting the caret while she holds the keyboard starts UIKit's own
    // animated reveal (and the authority's one-shot verify after it) — let
    // both land before placing the page, or the placement races them.
    await surface.settle(50)
    // TK2's estimates settle as the target lays out, so place, lay out, and
    // place again until the caret's line really is the last visible line.
    for _ in 0..<4 {
        guard let range = tv.selectedTextRange else { return }
        let caret = tv.caretRect(for: range.end)
        tv.setContentOffset(
            CGPoint(x: 0, y: max(0, caret.maxY - tv.bounds.height + 4)), animated: false)
        tv.layoutIfNeeded()
    }
    await surface.settle(20)
}

/// The reading line the record quotes.
@MainActor
private func report(_ tag: String, _ tv: UITextView) {
    let r = PageReading(tv)
    print("VM10PIN \(tag): offsetY=\(r.offsetY) firstVisibleChar=\(r.firstVisibleChar) len=\(tv.textStorage.length) caretLineVisible=\(r.caretLineVisible)")
}

@MainActor
@Suite("VM-10 — the Write page's scroll authority", .serialized)
struct MobileWriteScrollAuthorityTests {
    // MARK: Arm 2 — the ⏎ forced scroll

    /// **⏎ at the end never throws the page onto empty room.** RED ON OLD
    /// (traced, 30 paragraphs, no keyboard): offsetY 1776.7 → 2471.3 with the
    /// first visible character = the last = the new empty line (2691) —
    /// nothing but room on screen. The rule: the caret's line stays visible and
    /// the page moves at most what visibility requires (here, one new line).
    @Test func aReturnAtTheEndRevealsTheNewLineMinimallyAndKeepsTheText() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            await caretAtEndOnTheViewportFoot(tv, surface)
            let before = PageReading(tv)
            let endBefore = tv.textStorage.length
            report("end-return before", tv)
            #expect(before.caretLineVisible, "the setup puts her caret's line on screen")

            tv.insertText("\n")
            await surface.settle(40)
            report("end-return after", tv)
            let after = PageReading(tv)
            let line = MobileTypewriterRoom.lineHeight(of: MobileEditorStyle.baseFont)

            #expect(after.caretLineVisible, "the new line is visible — she can keep typing")
            #expect(after.firstVisibleChar < endBefore,
                    "text above the caret stays on screen (first visible \(after.firstVisibleChar), the new line starts at \(endBefore))")
            #expect(after.offsetY - before.offsetY <= 2 * line + 8,
                    "the page moved \(after.offsetY - before.offsetY) pt — at most what one new line needs (\(line) pt)")
        }
    }

    /// The same on a SHORT note — the class at its worst: RED ON OLD with the
    /// keyboard up (the trace's forced software keyboard), a 3-paragraph note
    /// went 0 → 254 and showed NONE of its text. Keyboard-free here (the pins
    /// never flip process-wide keyboard state); the reveal is the same call.
    @Test func aReturnAtTheEndOfAShortNoteKeepsTheWholeNoteOnScreen() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 3)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
            await surface.settle(20)
            #expect(tv.contentOffset.y <= 0.5, "a short note sits at the top")

            tv.insertText("\n")
            await surface.settle(40)
            report("short-note-return after", tv)
            let after = PageReading(tv)
            #expect(tv.contentOffset.y <= 0.5,
                    "nothing needed revealing — the page stayed (offsetY \(tv.contentOffset.y))")
            #expect(after.firstVisibleChar <= 1, "the note's first line is still the page's first line")
            #expect(after.caretLineVisible)
        }
    }

    /// A ⏎ in the MIDDLE of the document at the viewport's foot was already
    /// minimal on the old tree (303.3 → 336.0, a 32.7-pt reveal) — kept as a
    /// guard that the authority never stops UIKit's ordinary reveal.
    @Test func aReturnMidDocumentStillRevealsTheCaretMinimally() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            let ranges = model.blockRangesByID().values.sorted { $0.location < $1.location }
            let caret = ranges[11].location + ranges[11].length
            tv.selectedRange = NSRange(location: caret, length: 0)
            let rect = tv.caretRect(for: try #require(tv.selectedTextRange).end)
            tv.setContentOffset(CGPoint(x: 0, y: rect.maxY - tv.bounds.height + 4), animated: false)
            await surface.settle(20)
            let before = PageReading(tv)

            tv.insertText("\n")
            await surface.settle(40)
            let after = PageReading(tv)
            let line = MobileTypewriterRoom.lineHeight(of: MobileEditorStyle.baseFont)
            #expect(after.caretLineVisible, "the caret left the foot and was revealed")
            #expect(after.offsetY > before.offsetY, "a reveal happened")
            #expect(after.offsetY - before.offsetY <= 2 * line + 8)
        }
    }

    // MARK: Arm 3 — the scroll-back fight

    /// **A relayout after she scrolls back up does not throw her to the room.**
    /// The traced fight: every relayout while she holds the keyboard — the
    /// keyboard's placement animation above all, which `.interactive`
    /// dismissal runs whenever her drag engages it — re-runs
    /// `_scrollToSelectionIfNeeded` with the room-padded rect (trace, keyboard
    /// up: 1643 → 2435, first/last visible 2680/2691). Here the relayout is a
    /// focus round trip (hardware-keyboard mode: the accessory bar's rise
    /// changes the guide). GREEN ON OLD (a GUARD, not a red-on-old pin) — the number lands in the record.
    @Test func aRelayoutAfterHerScrollUpNeverForcesTheRoom() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            await caretAtEndOnTheViewportFoot(tv, surface)
            tv.insertText("\n")
            await surface.settle(40)
            // She scrolls back up to read.
            tv.setContentOffset(CGPoint(x: 0, y: max(0, tv.contentOffset.y - 500)), animated: false)
            await surface.settle(10)
            let caretLineStart = tv.textStorage.length

            _ = tv.resignFirstResponder()
            await surface.settle(30)
            _ = tv.becomeFirstResponder()
            await surface.settle(40)
            report("relayout after scroll-up", tv)
            let after = PageReading(tv)
            #expect(after.firstVisibleChar < caretLineStart,
                    "the page shows text, not only the room (offsetY \(after.offsetY), first visible \(after.firstVisibleChar), the empty line at \(caretLineStart))")
        }
    }

    /// **Typing after she scrolled the caret away reveals it minimally — never
    /// the room.** The fight's keystroke face: she scrolls up to read, carries
    /// on typing, and UIKit's `_scrollToSelectionIfNeeded` (from
    /// `textInputDidChange:`) guards the minimal re-reveal (green on old: without a trailing newline there is no room padding, so old was minimal too; the record's provenance block is the authority).
    /// ON OLD — the number lands in the record. Revealing the caret's line at
    /// the viewport's foot is the ordinary, ruled minimal reveal.
    @Test func typingAfterScrollingTheCaretAwayRevealsItMinimally() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            await caretAtEndOnTheViewportFoot(tv, surface)
            // She scrolls well above her caret (a page and a half).
            tv.setContentOffset(
                CGPoint(x: 0, y: max(0, tv.contentOffset.y - 1.5 * tv.bounds.height)),
                animated: false)
            await surface.settle(10)
            let endBefore = tv.textStorage.length
            report("typing-after-scroll-up before", tv)

            tv.insertText("w")
            await surface.settle(40)
            report("typing-after-scroll-up after", tv)
            let after = PageReading(tv)
            #expect(after.caretLineVisible, "typing brings the caret back into view")
            #expect(after.firstVisibleChar < endBefore - 40,
                    "…with the text above it on screen, not a page of room (first visible \(after.firstVisibleChar))")
        }
    }

    /// **Her gesture wins — the authority's own guard pin** (arm 3's rule:
    /// *"no programmatic scroll overrides a live or just-finished user
    /// pan"*). A pan cannot be synthesized in process, so this drives the
    /// authority at its traced choke point: her pan's stamp (the recognizer
    /// target's own body), then a reveal UIKit would make — refused while the
    /// page is hers; once the quiet window passes, the same reveal runs and is
    /// MINIMAL. NOT a red-on-old pin (the clock is new API); the fight's real
    /// trigger is recorded with its trace numbers in the record.
    @Test func whileHerPanHoldsThePageNoRevealMovesIt() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let (model, surface) = host(session, postID: postID, beginEditing: true)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView as MobileEditorTextView?)
            await caretAtEndOnTheViewportFoot(tv, surface)
            tv.insertText("\n")
            await surface.settle(40)
            // She drags back up to read.
            var now: CFTimeInterval = 1_000
            tv.clock = { now }
            tv.setContentOffset(CGPoint(x: 0, y: max(0, tv.contentOffset.y - 600)), animated: false)
            tv.noteHerScroll()
            let hers = tv.contentOffset.y
            let caret = tv.caretRect(for: try #require(tv.selectedTextRange).end)

            now += 0.3 // inside the quiet window: the spring-back's moment
            tv.scrollRectToVisible(caret, animated: false)
            #expect(tv.contentOffset.y == hers, "a reveal inside her gesture's window moves nothing")

            now += 1.0 // she has let go and the page has settled
            tv.scrollRectToVisible(caret, animated: false)
            let after = PageReading(tv)
            #expect(after.caretLineVisible, "after the window the ordinary reveal runs")
            #expect(after.firstVisibleChar < tv.textStorage.length,
                    "…minimally: text above the caret, never a page of room")
        }
    }

    // MARK: Arm 1 — the arrival (her ruled shape)

    /// **Nothing remembered → the page opens at the TOP.** GREEN ON OLD — the
    /// trace measured offset 0 and first visible char 1 on every road (the bare
    /// screen with focus off and on, the real shell's Library push, the forced
    /// software keyboard): this half of the ruled shape was already true. Kept
    /// as the guard that the memory never invents a place for a note she has
    /// not visited.
    @Test func aNoteNeverVisitedOpensAtTheTop() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let router = MobileShellRouter()
            let (model, surface) = host(session, postID: postID, router: router)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            let tv = try #require(model.textView)
            let reading = PageReading(tv)
            #expect(tv.contentOffset.y <= 0.5)
            #expect(reading.firstVisibleChar <= 1, "the note's first line is on screen")
        }
    }

    /// **A note left mid-way re-opens THERE** (her ruled shape (2) — the page's
    /// place remembered per note for the session). RED ON OLD: no memory
    /// existed, so a re-entry landed at offset 0.
    @Test func aNoteLeftMidwayReopensWhereSheLeftIt() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await seedParagraphs(session, 30)
            let router = MobileShellRouter()
            let ranges: [NSRange]
            let leftAt: Int
            do {
                let (model, surface) = host(session, postID: postID, router: router)
                await waitForText(model, surface)
                let tv = try #require(model.textView)
                ranges = model.blockRangesByID().values.sorted { $0.location < $1.location }
                model.jumpToBlock(try #require(model.blockID(atSurfaceOffset: ranges[11].location)))
                await surface.settle(20)
                leftAt = PageReading(tv).firstVisibleChar
                #expect(leftAt > ranges[10].location, "the page sits mid-note when she leaves")
                surface.tearDown()
                await surface.settle(10)
                #expect(router.writePlaces.place(for: postID) != nil,
                        "leaving remembered the page's place")
            }
            // Re-entry: a FRESH screen (the push builds a new one), same session.
            let (model, surface) = host(session, postID: postID, router: router)
            defer { surface.tearDown() }
            await waitForText(model, surface)
            await surface.settle(20)
            let tv = try #require(model.textView)
            report("memory re-entry (left at first visible \(leftAt))", tv)
            let back = PageReading(tv)
            #expect(abs(back.firstVisibleChar - leftAt) <= 90,
                    "re-opened at the place she left (first visible \(back.firstVisibleChar), left at \(leftAt), offsetY \(back.offsetY))")
        }
    }
}

/// The authority's two rules, pure.
@Suite("VM-10 — the scroll authority's brain")
struct MobileScrollAuthorityBrainTests {
    @Test func aRevealNeverReachesPastTheText() {
        // The traced last-line rect: (15, 2242.9, 372, 711.4) with the text
        // ending at 2297 — clamped to the line's own extent.
        let clamped = MobileScrollAuthority.revealRect(
            CGRect(x: 15, y: 2242.9, width: 372, height: 711.4), textBottom: 2297)
        #expect(clamped.minY == 2242.9)
        #expect(abs(clamped.maxY - 2297) < 0.001)
        #expect(clamped.width == 372)
        // A mid-document line rect is untouched.
        let line = CGRect(x: 20, y: 987.5, width: 362, height: 22.7)
        #expect(MobileScrollAuthority.revealRect(line, textBottom: 2297) == line)
        // A rect wholly in the room collapses to the text's foot.
        let inRoom = MobileScrollAuthority.revealRect(
            CGRect(x: 0, y: 2400, width: 10, height: 300), textBottom: 2297)
        #expect(inRoom.maxY <= 2297 && inRoom.height == 1)
    }

    @Test func herGestureHoldsWhileLiveAndForTheQuietWindow() {
        let quiet = MobileScrollAuthority.userScrollQuiet
        #expect(MobileScrollAuthority.herGestureHolds(
            now: 10, lastUserScroll: -.infinity, dragging: true, decelerating: false))
        #expect(MobileScrollAuthority.herGestureHolds(
            now: 10, lastUserScroll: -.infinity, dragging: false, decelerating: true))
        #expect(MobileScrollAuthority.herGestureHolds(
            now: 10, lastUserScroll: 10 - quiet / 2, dragging: false, decelerating: false))
        #expect(!MobileScrollAuthority.herGestureHolds(
            now: 10, lastUserScroll: 10 - quiet - 0.01, dragging: false, decelerating: false))
        #expect(!MobileScrollAuthority.herGestureHolds(
            now: 10, lastUserScroll: -.infinity, dragging: false, decelerating: false),
            "never touched: the page is UIKit's to reveal")
    }
}
