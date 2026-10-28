//
//  PaneLifecycleTests.swift
//  VariorumTests
//
//  VX-601 batch A — what happens to a pane when its take is DELETED or
//  RE-BOUND (the run record's BATCH A RECORD, `notes/plans/fixes/
//  vx-601-run-takes-editor-quick-fixes.md`, carries the traced mechanisms).
//
//  VX-421 (a LAUNCH GATE — her report: ⌘Z after deleting a take in Takes
//  crashes the app; her ruling R-601-1, the per-pane arm): every pane mounts
//  through ONE representable, and its typing landed on the WINDOW's undo
//  manager. Tearing a pane down left those actions there, aimed at a view
//  `NSUndoManager` does not retain — the next ⌘Z messaged a freed pane, or,
//  while something still held it, edited a pane that no longer exists. The
//  rule these pins hold: each pane's typing history is ITS OWN — ⌘Z undoes
//  only the pane the cursor is in, the history goes with the pane, and a
//  programmatic write of the pane's characters ends it (the words it
//  described have left the pane — VX-179 U3-g's rule, carried).
//
//  VX-248 (her ruled P-3 bend — QUESTIONS #217's "I think that we should
//  probably fix it", seated R-601-6): a LIVE pane never took projection
//  text, so a pane whose bound take changed while live kept the OLD take's
//  words under the NEW take's edit closure — the next keystroke saved them
//  over the new take. The rule: a re-key is a RE-BIND, not an edit — the
//  pane adopts the new take's text, its old history ends, and the caret
//  lands after the text is written.
//
//  RED ON OLD: every pin marked so below; the guards are green on both
//  sides and say so.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
@testable import Variorum

/// One pane's worth of host state — what a composition hands the ONE pane
/// component (its text, its liveness, the take it is BOUND to, where its
/// caret lands on going live) and whether the composition renders it at all
/// (a deleted take's pane is simply not rendered any more). File-scope: the
/// `@Observable` macro cannot expand on a `private` nested type.
@MainActor @Observable
fileprivate final class LifecyclePane {
    var shown = true
    var text: String
    var variantID: String?
    var isLive = false
    var landing: PaneCaretLanding = .leave
    /// Every edit the pane handed up, with the take its closure was bound to
    /// at render time — exactly how `TakesCellView` binds `resolved.variantID`
    /// into its `onEdit`, so a stale pane's keystroke shows up here as the
    /// NEW take's text carrying the OLD take's words.
    @ObservationIgnored var edits: [Edit] = []

    struct Edit: Equatable {
        let variantID: String?
        let text: String
    }

    init(text: String, variantID: String?, isLive: Bool = false) {
        self.text = text
        self.variantID = variantID
        self.isLive = isLive
    }
}

fileprivate struct LifecycleHost: View {
    let first: LifecyclePane
    let second: LifecyclePane?

    var body: some View {
        VStack(spacing: 8) {
            if first.shown { paneView(first, role: "first") }
            if let second, second.shown { paneView(second, role: "second") }
        }
        .frame(width: 420)
    }

    private func paneView(_ pane: LifecyclePane, role: String) -> some View {
        let bound = pane.variantID
        return PaneSurfaceView(
            text: pane.text, isLive: pane.isLive,
            role: role, variantID: bound,
            onEdit: { pane.edits.append(.init(variantID: bound, text: $0)) },
            caretOnGoingLive: pane.landing)
    }
}

/// The mounted rig: an OFFSCREEN window that is never ordered in (the
/// `CommentTextAreaTests` undo pin's shape — a window owns the keyboard and
/// the undo road, nothing needs to be seen).
@MainActor
fileprivate struct LifecycleRig {
    let window: NSWindow
    let hosting: NSHostingView<LifecycleHost>

    init(first: LifecyclePane, second: LifecyclePane? = nil) {
        hosting = NSHostingView(rootView: LifecycleHost(first: first, second: second))
        hosting.frame = NSRect(x: 0, y: 0, width: 420, height: 400)
        window = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 420, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: true)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 400))
        content.addSubview(hosting)
        window.contentView = content
    }

    func close() {
        window.contentView = nil
        window.close()
    }

    /// Detach the hosting view and re-attach it — the way SwiftUI moves a
    /// representable's view during a lazy column's reveal (TEXTKIT2_NOTES §3,
    /// 18l-c U7; `PaneFindFaceTests.reparent`'s shape).
    func reparent(between: () -> Void = {}) {
        let content = hosting.superview
        hosting.removeFromSuperview()
        between()
        content?.addSubview(hosting)
    }

    /// Let SwiftUI apply what the rig changed (an update pass, a removal, a
    /// liveness flip) — layout, display and a few run-loop and task turns.
    func settle() async {
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
        }
    }

    /// A run-loop turn — a synchronous helper, because `run(until:)` is
    /// unavailable from an async context (`PaneFindFaceTests.pump`'s shape).
    private static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// The pane a role renders (`pane:<role>|<variant>`), nil once removed.
    func pane(_ role: String) -> PaneTextView? {
        Self.panes(in: hosting).first {
            $0.identifier?.rawValue.hasPrefix("pane:\(role)|") == true
        }
    }

    private static func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    /// Her keystrokes, through the real edit door (the NSTextInputClient road
    /// typing and paste share), at the END of the pane's text.
    func type(_ text: String, into pane: PaneTextView) {
        window.makeFirstResponder(pane)
        pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
        pane.insertText(text, replacementRange: pane.selectedRange())
    }

    /// …at wherever the caret already is.
    func typeAtCaret(_ text: String, into pane: PaneTextView) {
        pane.insertText(text, replacementRange: pane.selectedRange())
    }

    /// ⌘Z's own road: `undo:` up the responder chain to the window, which
    /// undoes through the FIRST RESPONDER's manager (measured at VX-179 U3-g).
    func commandZ() {
        let responder = window.firstResponder ?? window
        _ = responder.tryToPerform(Selector(("undo:")), with: nil)
    }
}

// MARK: - VX-421 — each pane owns its undo history (R-601-1)

@MainActor
@Suite("VX-421 — a pane's undo history is its own (R-601-1)", .serialized)
struct PaneUndoLifecycleTests {
    private static let take = "A take she is working in, before the paste."
    private static let pasted = " And a long pasted paragraph after it."

    /// **RED ON OLD — the zombie hit, observable without the crash.** She
    /// pastes into a live pane, the pane is torn down (the take deleted — its
    /// composition stops rendering it), and ⌘Z arrives with no pane holding
    /// the keyboard. On the old tree the paste's undo was on the WINDOW's
    /// manager, aimed at the torn-down pane: held alive here, so the replay
    /// lands instead of crashing — and EDITS A PANE THAT NO LONGER EXISTS.
    /// The pane's history must go with it, leaving nothing to replay.
    @Test func aTornDownPanesTypingNeverReachesTheWindowsUndo() async throws {
        let first = LifecyclePane(text: Self.take, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let held = try #require(rig.pane("first"), "the pane mounted")
        rig.type(Self.pasted, into: held)
        await rig.settle()
        #expect(held.string == Self.take + Self.pasted)
        #expect(held.undoManager?.canUndo == true, "non-vacuity: the paste is undoable while the pane lives")

        first.shown = false  // the take is deleted: its pane stops rendering
        await rig.settle()
        #expect(rig.pane("first") == nil, "non-vacuity: the pane was torn down")
        #expect(rig.window.firstResponder !== held, "AppKit dropped the removed responder")
        #expect(rig.window.undoManager?.canUndo != true,
                "RED ON OLD: the torn-down pane's paste is still on the window's undo manager")

        rig.commandZ()
        await rig.settle()
        #expect(held.string == Self.take + Self.pasted,
                "RED ON OLD: ⌘Z replayed the paste's undo into a pane that no longer exists (shows: \(held.string))")
    }

    /// **RED ON OLD — the crash's precondition.** The same gesture with the
    /// torn-down pane RELEASED (nothing holds it): the replay would message a
    /// freed object — `EXC_BAD_ACCESS` in `popAndInvoke`, the ticket's crash.
    /// On the old tree this pin STOPS at the `#require` below rather than run
    /// the line that would bring the test host down with it; the crash itself
    /// is the walk's (her exact gesture). On the fixed tree ⌘Z is a clean
    /// no-op.
    @Test func undoAfterATornDownPaneIsReleasedIsACleanNoOp() async throws {
        let first = LifecyclePane(text: Self.take, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        weak var released: PaneTextView?
        do {
            let pane = try #require(rig.pane("first"), "the pane mounted")
            released = pane
            rig.type(Self.pasted, into: pane)
        }
        await rig.settle()
        #expect(released?.undoManager?.canUndo == true, "non-vacuity: the paste is undoable")

        first.shown = false
        await rig.settle()
        #expect(rig.pane("first") == nil, "non-vacuity: the pane was torn down")
        try #require(rig.window.undoManager?.canUndo != true,
                     "RED ON OLD: the window's manager still names the torn-down pane — the next ⌘Z messages it")
        rig.commandZ()  // the line that crashed: on the fixed tree, nothing to replay
        await rig.settle()
        #expect(rig.window.undoManager?.canUndo != true)
    }

    /// **RED ON OLD — ⌘Z undoes only the pane the cursor is in** (R-601-1's
    /// meaning). She types in one take, moves to another and types there: ⌘Z
    /// undoes HER LAST PANE's typing, and once that pane's history is spent,
    /// another ⌘Z reaches nothing of the first pane's. On the old tree both
    /// panes' typing shared the window's one stack — the first pane's history
    /// was still under her second ⌘Z.
    @Test func undoInAPaneUndoesOnlyThatPanesTyping() async throws {
        let first = LifecyclePane(text: "The first take.", variantID: "take-a", isLive: true)
        let second = LifecyclePane(text: "The second take.", variantID: "take-b")
        let rig = LifecycleRig(first: first, second: second)
        defer { rig.close() }
        await rig.settle()
        let one = try #require(rig.pane("first"))
        let two = try #require(rig.pane("second"))
        rig.type(" Typed in the first.", into: one)
        await rig.settle()

        // The ring moves to the second take (the one-live-pane rule).
        first.isLive = false
        second.isLive = true
        await rig.settle()
        #expect(two.isEditable && !one.isEditable, "non-vacuity: the ring moved")
        rig.type(" Typed in the second.", into: two)
        await rig.settle()
        #expect(rig.window.firstResponder === two)

        rig.commandZ()
        await rig.settle()
        #expect(two.string == "The second take.", "⌘Z undid the pane she is in")
        #expect(two.undoManager?.canUndo != true,
                "RED ON OLD: the FIRST pane's typing was still under ⌘Z in the second")
        rig.commandZ()
        await rig.settle()
        #expect(one.string == "The first take. Typed in the first.",
                "the first pane's words are untouched by ⌘Z in the second")
        #expect(two.string == "The second take.")
    }

    /// **RED ON OLD — a READ pane's ⌘Z moves nothing.** A read pane can still
    /// hold the keyboard (a drag-selection; the moment a parked follow's blur
    /// leaves it holding it), and AppKit applies an undo to a NON-EDITABLE
    /// text view (measured offscreen — the run record's probe). On the old
    /// tree ⌘Z there reverted a projection-authoritative pane's characters off
    /// its take's text. A read pane holds no caret of hers, so its history
    /// waits — and is there again when the pane next goes live over the same
    /// characters.
    @Test func aReadPaneHoldingTheKeyboardUndoesNothing() async throws {
        let first = LifecyclePane(text: Self.take, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type(Self.pasted, into: pane)
        await rig.settle()

        first.isLive = false  // the ring left her pane
        await rig.settle()
        #expect(!pane.isEditable, "non-vacuity: read")
        rig.window.makeFirstResponder(pane)  // …and her keyboard is still in it
        #expect(rig.window.firstResponder === pane, "non-vacuity: the read pane holds the keyboard")
        #expect(pane.undoManager?.canUndo != true,
                "RED ON OLD: ⌘Z in a read pane reached the typing under it")
        rig.commandZ()
        await rig.settle()
        #expect(pane.string == Self.take + Self.pasted,
                "RED ON OLD: ⌘Z reverted a READ pane's characters off its take (shows: \(pane.string))")

        first.isLive = true  // back live over the same characters
        await rig.settle()
        #expect(pane.undoManager?.canUndo == true, "her history waited for the pane's next going-live")
        rig.commandZ()
        await rig.settle()
        #expect(pane.string == Self.take, "⌘Z undid her paste, live again")
    }

    /// **A GUARD (green on both sides) — the re-parent edge** (TEXTKIT2_NOTES
    /// §3, 18l-c U7: SwiftUI may detach and re-attach a representable's view
    /// within one layout pass). The history SURVIVES a detach and re-attach:
    /// it is the pane's coordinator's, whose life is the representable's, not
    /// the window attachment's — the pane takes back its keyboard (U7) and ⌘Z
    /// still undoes its own typing.
    @Test func aPaneKeepsItsHistoryAcrossADetachAndReattach() async throws {
        let first = LifecyclePane(text: Self.take, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type(Self.pasted, into: pane)
        await rig.settle()
        #expect(rig.window.firstResponder === pane)

        rig.reparent {
            #expect(rig.window.firstResponder !== pane, "AppKit dropped the detached responder")
        }
        await rig.settle()
        #expect(rig.pane("first") === pane, "the same pane, re-attached")
        #expect(rig.window.firstResponder === pane, "the live pane took back its keyboard")
        #expect(pane.undoManager?.canUndo == true, "its history survived the re-parent")

        rig.commandZ()
        await rig.settle()
        #expect(pane.string == Self.take, "⌘Z undid the pane's own paste")
    }

    /// **RED ON OLD — a programmatic write ENDS the pane's history** (VX-179
    /// U3-g's rule, carried from `CommentTextArea` and `CaptureTextView`). She
    /// types in a take, the ring moves away, the take's words change elsewhere
    /// (another pane of the same take, sync, an agent) and the READ pane
    /// adopts them; back in the pane, ⌘Z must not replay ranges of the old
    /// text against the new — the `NSRangeException` class. The old tree kept
    /// that history on the window's manager across the adoption; this pin
    /// stops at the `#require` rather than replay it.
    @Test func aProgrammaticWriteEndsThePanesHistory() async throws {
        let first = LifecyclePane(text: Self.take, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type(Self.pasted, into: pane)
        await rig.settle()
        #expect(pane.undoManager?.canUndo == true, "non-vacuity")

        first.isLive = false
        await rig.settle()
        let elsewhere = "The same take, rewritten in another pane while she was away from this one."
        first.text = elsewhere
        await rig.settle()
        #expect(pane.string == elsewhere, "the read pane adopted the take's new words")

        first.isLive = true
        await rig.settle()
        #expect(pane.isEditable)
        try #require(pane.undoManager?.canUndo != true,
                     "RED ON OLD: the history of words that left the pane still stood under ⌘Z")
        rig.commandZ()
        await rig.settle()
        #expect(pane.string == elsewhere, "⌘Z had nothing of the old text to replay")
    }
}

// MARK: - VX-248 — a re-bound pane adopts its new take (her P-3 bend)

@MainActor
@Suite("VX-248 — a pane re-bound to another take adopts it", .serialized)
struct PaneRebindTests {
    private static let takeA = "Take A, the words she was typing into."
    private static let takeB = "Take B says something else entirely, and at greater length than A does."

    /// **RED ON OLD — the contamination itself.** A live pane on take A; she
    /// types; the composition re-keys the SAME pane to take B while it stays
    /// live (the naive same-turn follow VX-227's park exists to avoid). The
    /// pane must show B's own words, carry none of A's history, and hand her
    /// next keystroke up as B's text — on the old tree it kept A's words and
    /// the keystroke handed `A's words + "!"` up as take B: the autosave that
    /// would have written them over B.
    @Test func aLivePaneReboundToAnotherTakeShowsThatTakesWords() async throws {
        let first = LifecyclePane(text: Self.takeA, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type("x", into: pane)
        await rig.settle()
        #expect(first.edits.last == .init(variantID: "take-a", text: Self.takeA + "x"),
                "non-vacuity: the keystroke reached take A")

        // The re-key: one change, the pane stays live.
        first.variantID = "take-b"
        first.text = Self.takeB
        await rig.settle()
        #expect(rig.pane("first") === pane, "non-vacuity: the SAME pane was re-bound, not remounted")
        #expect(pane.isEditable, "still live")
        #expect(pane.string == Self.takeB,
                "RED ON OLD: the re-bound live pane kept take A's words (shows: \(pane.string))")
        #expect(pane.undoManager?.canUndo != true,
                "RED ON OLD: take A's typing history survived the re-bind")

        rig.typeAtCaret("!", into: pane)
        await rig.settle()
        let last = try #require(first.edits.last)
        #expect(last.variantID == "take-b")
        #expect(!last.text.contains(Self.takeA),
                "RED ON OLD: her keystroke handed take A's words up as take B's text (\(last.text))")
        #expect(last.text.contains(Self.takeB), "the keystroke landed in take B's own words")
    }

    /// **RED ON OLD — the revival shape (VX-222's step 4).** A READ pane on
    /// take A turns live in the SAME render that re-keys it to take B. The
    /// pane must show B's words with its caret where the composition asked —
    /// on the old tree it went live over A's words, keyed to B.
    @Test func aReadPaneReboundAsItGoesLiveShowsTheNewTake() async throws {
        let first = LifecyclePane(text: Self.takeA, variantID: "take-a")
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        #expect(!pane.isEditable, "non-vacuity: read")

        first.landing = .offset(5)
        first.isLive = true
        first.variantID = "take-b"
        first.text = Self.takeB
        await rig.settle()
        #expect(pane.isEditable, "the flip made the pane live")
        #expect(pane.string == Self.takeB,
                "RED ON OLD: the pane went live over take A's words (shows: \(pane.string))")
        #expect(pane.selectedRange() == NSRange(location: 5, length: 0), "the landing the host asked for")
        #expect(rig.window.firstResponder === pane, "a programmatic going-live claims the keyboard")

        rig.typeAtCaret("!", into: pane)
        await rig.settle()
        let expected = (Self.takeB as NSString).replacingCharacters(
            in: NSRange(location: 5, length: 0), with: "!")
        #expect(first.edits.last == .init(variantID: "take-b", text: expected),
                "RED ON OLD: the keystroke wrote into take B through take A's words")
    }

    /// **RED ON OLD — the caret lands AFTER the new text is written** (the
    /// ticket's own clause: "the caret landing moves in `noteLiveness` after
    /// the text write"). Take B is longer than take A, and the host asks for
    /// a place past A's end: a landing made against A's text would clamp short
    /// of it, and a text write after a landing would leave AppKit's END.
    @Test func aReboundLivePaneLandsItsCaretInTheNewText() async throws {
        let short = "Short A."
        let first = LifecyclePane(text: short, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type("x", into: pane)
        await rig.settle()

        let place = 20
        #expect(place > (short as NSString).length + 1 && place < (Self.takeB as NSString).length,
                "non-vacuity: the place exists only in take B")
        first.landing = .offset(place)
        first.variantID = "take-b"
        first.text = Self.takeB
        await rig.settle()
        #expect(pane.string == Self.takeB, "RED ON OLD: still take A's words")
        #expect(pane.selectedRange() == NSRange(location: place, length: 0),
                "the caret landed in take B's text, after the write (at \(pane.selectedRange().location))")
    }

    /// **A GUARD — a re-bind is not an edit.** Re-keying a live pane hands
    /// nothing up: writing the new take's words into the pane is adoption,
    /// never her typing, so no autosave can follow from it.
    @Test func aRebindHandsNothingUp() async throws {
        let first = LifecyclePane(text: Self.takeA, variantID: "take-a", isLive: true)
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))
        rig.type("x", into: pane)
        await rig.settle()
        let before = first.edits.count
        #expect(before >= 1, "non-vacuity")

        first.variantID = "take-b"
        first.text = Self.takeB
        await rig.settle()
        #expect(first.edits.count == before, "the re-bind handed nothing up (\(first.edits.suffix(2)))")
    }

    /// **A GUARD — a READ pane's re-bind reads exactly as before**: it shows
    /// the new take's words (the read adoption always did that), and it stays
    /// read.
    @Test func aReadPaneReboundShowsTheNewTakeAndStaysRead() async throws {
        let first = LifecyclePane(text: Self.takeA, variantID: "take-a")
        let rig = LifecycleRig(first: first)
        defer { rig.close() }
        await rig.settle()
        let pane = try #require(rig.pane("first"))

        first.variantID = "take-b"
        first.text = Self.takeB
        await rig.settle()
        #expect(pane.string == Self.takeB)
        #expect(!pane.isEditable)
        #expect(first.edits.isEmpty)
    }
}
