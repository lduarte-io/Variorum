//
//  PaneFindFaceTests.swift
//  VariorumTests
//
//  18l-c UNIT U7 — the pane's FIND face (`PaneFindFace`, `Surface/PaneSurface
//  .swift`): what a find running on a host asks of the ONE pane component.
//  Decision 7 — the matches painted on the READ tier only, as runs in the
//  pane's own attributed string (TEXTKIT2_NOTES §3), shed the moment the pane
//  goes live; decision 6 — a step's landing SELECTS the match; decision 1 —
//  a step driven from the find field leaves the keyboard in the field.
//  Every other pane is byte-unchanged: the face defaults to nil.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Observable
private final class PaneRig {
    var text: String
    var isLive = false
    var landing: PaneCaretLanding = .leave
    var face: PaneFindFace?

    init(text: String, face: PaneFindFace? = nil) {
        self.text = text
        self.face = face
    }
}

private struct PaneRigView: View {
    let rig: PaneRig

    var body: some View {
        PaneSurfaceView(
            text: rig.text, isLive: rig.isLive, caretOnGoingLive: rig.landing,
            findFace: rig.face)
            .frame(width: 420)
    }
}

@MainActor
@Suite("18l-c U7 — the pane's find face", .serialized)
struct PaneFindFaceTests {
    private static let matchTint = NSColor.systemGreen.withAlphaComponent(0.2)
    private static let currentTint = NSColor.systemGreen.withAlphaComponent(0.45)
    private static let text = "Hyde met Hyde at the door."  // matches 0+4 and 9+4

    private static func face(
        current: NSRange? = nil, request: PaneFindFace.Request? = nil,
        fieldHoldsKeyboard: Bool = false
    ) -> PaneFindFace {
        PaneFindFace(
            matches: [NSRange(location: 0, length: 4), NSRange(location: 9, length: 4)],
            current: current, matchTint: matchTint, currentTint: currentTint,
            request: request, fieldHoldsKeyboard: fieldHoldsKeyboard)
    }

    private static func pane(in view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews { if let found = pane(in: sub) { return found } }
        return nil
    }

    /// A real window (the keyboard is a window's), the rig's view hosted in it.
    private static func mount(_ rig: PaneRig) async throws -> (NSWindow, PaneTextView, NSTextField) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 460, height: 260),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 460, height: 260))
        let hosting = NSHostingView(rootView: PaneRigView(rig: rig))
        hosting.frame = NSRect(x: 0, y: 40, width: 460, height: 220)
        // A stand-in for the find FIELD — something else that can hold the keyboard.
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        content.addSubview(hosting)
        content.addSubview(field)
        window.contentView = content
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<30 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            if Self.pane(in: hosting) != nil { break }
            try? await Task.sleep(for: .milliseconds(10))
        }
        let pane = try #require(Self.pane(in: hosting), "the pane mounted")
        return (window, pane, field)
    }

    private static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private static func settle(_ window: NSWindow) async {
        for _ in 0..<8 {
            window.contentView?.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private static func background(_ pane: PaneTextView, at index: Int) -> NSColor? {
        pane.textStorage?.attribute(.backgroundColor, at: index, effectiveRange: nil) as? NSColor
    }

    private static func paintedRuns(_ pane: PaneTextView) -> [NSRange] {
        guard let storage = pane.textStorage else { return [] }
        var runs: [NSRange] = []
        storage.enumerateAttribute(
            .backgroundColor, in: NSRange(location: 0, length: storage.length)
        ) { value, range, _ in
            if value != nil { runs.append(range) }
        }
        return runs
    }

    /// Only the Takes board hands a pane a find face (its article cell through
    /// `TakesCellView`, its fan cards directly) — a third caller would be a
    /// find on a surface her rulings did not name, and must say so here first
    /// (the `PaneLineMetricsScopeTests` walk, one parameter over).
    @Test func onlyTheTakesBoardHandsAPaneAFindFace() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        var callers: Set<String> = []
        for root in ["Variorum", "Shared"] {
            let walker = try #require(FileManager.default.enumerator(
                at: app.appendingPathComponent(root), includingPropertiesForKeys: nil))
            for case let file as URL in walker
            where file.pathExtension == "swift" && file.lastPathComponent != "PaneSurface.swift" {
                let source = try String(contentsOf: file, encoding: .utf8)
                let code = source.split(separator: "\n").filter {
                    let line = $0.trimmingCharacters(in: .whitespaces)
                    return !line.hasPrefix("//") && !line.hasPrefix("*")
                }
                if code.contains(where: { $0.contains("findFace:") }) {
                    callers.insert(file.lastPathComponent)
                }
            }
        }
        #expect(callers == ["TakesBoardView.swift", "TakesShared.swift"],
                "the hosts handing a pane a find face: \(callers.sorted())")
    }

    @Test func aPaneWithNoFindFaceNeverPaints() async throws {
        let rig = PaneRig(text: Self.text)
        let (window, pane, _) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(pane.findPaintWrites == 0, "no face, no write — every other host's pane is untouched")
        #expect(Self.paintedRuns(pane).isEmpty)
    }

    @Test func aReadPanePaintsItsMatchesAndTheCurrentOneStronger() async throws {
        let rig = PaneRig(text: Self.text, face: Self.face())
        let (window, pane, _) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(Self.paintedRuns(pane)
                == [NSRange(location: 0, length: 4), NSRange(location: 9, length: 4)],
                "exactly the two matches, nothing between them")
        #expect(Self.background(pane, at: 0) == Self.matchTint)
        let writes = pane.findPaintWrites
        #expect(writes >= 1, "non-vacuity: the paint wrote")

        // The SAME face re-rendered writes nothing (the change gate).
        rig.text = Self.text
        await Self.settle(window)
        #expect(pane.findPaintWrites == writes, "an unchanged face writes nothing")

        // The current match wears the stronger tint; the other stays a match.
        rig.face = Self.face(current: NSRange(location: 9, length: 4))
        await Self.settle(window)
        #expect(Self.background(pane, at: 9) == Self.currentTint)
        #expect(Self.background(pane, at: 0) == Self.matchTint)
        #expect(pane.string == Self.text, "the paint never touches the characters")
    }

    @Test func aPaneGoingLiveShedsItsPaintAndLandsWithTheMatchSelected() async throws {
        let rig = PaneRig(text: Self.text, face: Self.face(current: NSRange(location: 9, length: 4)))
        let (window, pane, _) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(!Self.paintedRuns(pane).isEmpty, "non-vacuity: painted while read")

        rig.landing = .select(NSRange(location: 9, length: 4))
        rig.isLive = true
        await Self.settle(window)
        #expect(Self.paintedRuns(pane).isEmpty, "a LIVE pane wears no paint — the live editor stays clean")
        #expect(pane.selectedRange() == NSRange(location: 9, length: 4), "the match, SELECTED")
        #expect(window.firstResponder === pane, "the landed pane holds the keyboard")
        #expect(pane.typingAttributes[.backgroundColor] == nil, "she never types in a match's colour")
    }

    @Test func aStepFromTheFindFieldLeavesTheKeyboardInTheField() async throws {
        let rig = PaneRig(text: Self.text, face: Self.face(fieldHoldsKeyboard: true))
        let (window, pane, field) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        window.makeFirstResponder(field)
        await Self.settle(window)

        rig.landing = .select(NSRange(location: 0, length: 4))
        rig.isLive = true
        await Self.settle(window)
        #expect(pane.isEditable, "the pane went live all the same")
        #expect(pane.selectedRange() == NSRange(location: 0, length: 4), "with the match selected")
        #expect(window.firstResponder !== pane,
                "…and the keyboard stayed with the field, so ⏎ keeps stepping")
    }

    // MARK: - The keyboard survives a re-parent (the second row-7 road)

    /// The hosting view carrying the pane — detached and re-attached the way
    /// SwiftUI moves a representable's view during a lazy column's layout.
    private static func reparent(_ window: NSWindow, between: () -> Void = {}) throws {
        let content = try #require(window.contentView)
        let host = try #require(content.subviews.first { !($0 is NSTextField) })
        host.removeFromSuperview()
        between()
        content.addSubview(host)
    }

    /// **RED ON THE PRE-FIX TREE** (the ⌘G pin found it on the find's road;
    /// this is its component form): a LIVE pane holding the keyboard is
    /// detached and re-attached — AppKit drops a detached first responder to
    /// the window — and the pane takes back the keyboard it held.
    @Test func aLivePaneTakesTheKeyboardBackAfterAReparent() async throws {
        let rig = PaneRig(text: Self.text)
        rig.isLive = true
        rig.landing = .start
        let (window, pane, _) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(window.firstResponder === pane, "non-vacuity: the live pane holds the keyboard")
        try Self.reparent(window) {
            #expect(window.firstResponder === window, "AppKit drops a detached first responder")
        }
        await Self.settle(window)
        #expect(window.firstResponder === pane, "re-attached, the live pane takes back its keyboard")
    }

    /// …and never STEALS it: if something else took the keyboard while the
    /// pane was away, the pane leaves it there; and a READ pane never
    /// reclaims (it was never the writing surface).
    @Test func aReparentNeverStealsTheKeyboardAndAReadPaneNeverReclaims() async throws {
        let rig = PaneRig(text: Self.text)
        rig.isLive = true
        rig.landing = .start
        let (window, pane, field) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(window.firstResponder === pane)
        try Self.reparent(window) { window.makeFirstResponder(field) }
        await Self.settle(window)
        #expect(window.firstResponder !== pane, "the field took it meanwhile — the pane leaves it")

        rig.isLive = false
        await Self.settle(window)
        window.makeFirstResponder(pane)  // a read pane is selectable, so it can hold it
        try Self.reparent(window)
        await Self.settle(window)
        #expect(window.firstResponder !== pane, "a read pane does not reclaim")
    }

    // MARK: - VX-282 R1-1 — the read-going caret settle owns the runs it re-reads

    private static func isItalic(_ pane: PaneTextView, at index: Int) -> Bool {
        (pane.textStorage?.attribute(.font, at: index, effectiveRange: nil) as? NSFont)?
            .fontDescriptor.symbolicTraits.contains(.italic) ?? false
    }

    /// **RED ON OLD (the round-1 review's R1-1).** A pane goes READ while its
    /// caret sits at a VX-296 rescue point (`*Hyde |*` — the ring moved to
    /// another pane, or a find step's landing left this one). The update paints
    /// the match FIRST (`paintFind(live: false)`), then the liveness note's
    /// settle re-reads the honoured line caret-blind — and the face's clear
    /// owns `.backgroundColor` on every face run it re-derives, the match's
    /// paint included. The paint record still said "painted", so the
    /// change-gated repaint at the update's end wrote nothing and the match
    /// stood unpainted. The settle now says what it rewrote
    /// (`findPaintWasReset`), and the repaint lands.
    @Test func aPaneGoingReadAtACaretRescuePointKeepsItsMatchPainted() async throws {
        let rig = PaneRig(
            text: "*Hyde *",
            face: PaneFindFace(
                matches: [NSRange(location: 1, length: 4)], current: nil,
                matchTint: Self.matchTint, currentTint: Self.currentTint,
                request: nil, fieldHoldsKeyboard: false))
        rig.isLive = true
        let (window, pane, _) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        // Her caret between the space and the closing star: the span is
        // honoured — italic (non-vacuity: the settle has a line to re-read).
        pane.setSelectedRange(NSRange(location: 6, length: 0))
        await Self.settle(window)
        #expect(Self.isItalic(pane, at: 1), "non-vacuity: the live pane honours the caret at the rescue point")
        #expect(Self.paintedRuns(pane).isEmpty, "a LIVE pane wears no paint")

        rig.isLive = false
        await Self.settle(window)
        #expect(!pane.isEditable, "the pane went read")
        #expect(!Self.isItalic(pane, at: 1), "the read-going settle re-read the line caret-blind")
        #expect(Self.background(pane, at: 1) == Self.matchTint,
                "RED ON OLD: the match stays painted after the settle re-read its line")
        #expect(Self.paintedRuns(pane) == [NSRange(location: 1, length: 4)],
                "exactly the match, painted")
    }

    @Test func aRequestSelectsInAnAlreadyLivePaneAndABornRequestIsNotAStep() async throws {
        // Born live WITH a request outstanding: the baseline — nothing acts.
        let rig = PaneRig(
            text: Self.text,
            face: Self.face(request: .init(
                token: 5, select: NSRange(location: 9, length: 4), claimsKeyboard: true)))
        rig.isLive = true
        rig.landing = .start
        let (window, pane, field) = try await Self.mount(rig)
        defer { window.orderOut(nil) }
        await Self.settle(window)
        #expect(pane.selectedRange() == NSRange(location: 0, length: 0),
                "a remount is not a step: the request it was born with does not act")

        // A NEW request to the live pane: select, and take the keyboard.
        window.makeFirstResponder(field)
        rig.face = Self.face(request: .init(
            token: 6, select: NSRange(location: 9, length: 4), claimsKeyboard: true))
        await Self.settle(window)
        #expect(pane.selectedRange() == NSRange(location: 9, length: 4))
        #expect(window.firstResponder === pane)

        // Esc's hand-back: no selection move, the keyboard back to the pane.
        pane.setSelectedRange(NSRange(location: 2, length: 0))
        window.makeFirstResponder(field)
        rig.face = Self.face(request: .init(token: 7, select: nil, claimsKeyboard: true))
        await Self.settle(window)
        #expect(pane.selectedRange() == NSRange(location: 2, length: 0), "her place kept")
        #expect(window.firstResponder === pane, "the keyboard handed back")
    }
}
