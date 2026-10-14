//
//  CommentPanelHostLifecycleTests.swift
//  VariorumTests
//
//  VX-282 U5 — the comments panel's HOST LIFECYCLE, pinned through the
//  product's own presenters (the record: `notes/plans/fixes/vx-282-editor-
//  notes-fixes.md` § U5).
//
//  VX-229 (the ticket's leak): VX-179 FIX LEG 3 measured, offscreen, that a
//  dismissed popover's content is never torn down, so every opening of the
//  Takes margin note's comments would leave the previous panel whole — its
//  model and its store observation (a re-read per comment write, per stale
//  panel). Re-measured at U5 against the real module with the run loop's pool
//  drains and no window held, the OLD product released every dismissed panel:
//  the leak is EXPECTED HOLLOW (the run record's CORRECTION), and these cells
//  decide it in the runner. The sheet hosts are measured the same way.
//
//  Every host constructs the panel exactly as the app does —
//  `CommentsPanel(session:blockID:)`, no model passed in — and the pins read
//  the models THIS test's session minted through the DEBUG weak record
//  (`CommentsPanelModel.debugAliveModels(of:)`; suites share one process and
//  harness ids repeat, so the session is the filter).
//
//  Hosting: the popover's anchor is ordered in OFF-DISPLAY at alpha 0 and each
//  popover window is set alpha 0 the turn it appears (VX-179's machinery); the
//  sheet hosts use a titled window, as every sheet-presenting suite in this
//  target does. **No test ever holds a presented window across its
//  dismissal** — the rigs hand back window NUMBERS, and a composer is touched
//  inside its own scope: a strong reference to a dismissed popover's window
//  keeps its content (model, observation) alive — measured at U5 — and the app
//  holds none, so a held window would manufacture the very leak VX-229 asks
//  about (the run record's CORRECTION). RED ON OLD where marked: the pins are committed ahead of the
//  fix, so the pre-fix product is that commit's. GUARD = green on both sides by
//  design. VX-229's cells are marked as what the evidence predicts.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rigs

/// The presentation switches the hosts below bind to.
@Observable private final class LifecycleDriver {
    var shown = false
    var takePanelShown = false
}

/// `.sheet(item:)`'s item — Write's (`CommentsPanelState`) and the Takes bar's
/// (`CommentsRequest`) shape.
private struct SheetItem: Identifiable {
    let blockID: String
    var id: String { blockID }
}

/// The Takes margin note's presenter, exactly (`TakesShared.swift`'s
/// `CommentMarginNote`): a SwiftUI `.popover(isPresented:)` whose content is
/// `CommentsPanel(session:blockID:)`.
private struct PopoverHost: View {
    @Bindable var driver: LifecycleDriver
    let session: AppSession
    let blockID: String
    var body: some View {
        Text("anchor").frame(width: 120, height: 40)
            .popover(isPresented: $driver.shown) {
                CommentsPanel(session: session, blockID: blockID)
            }
            .frame(width: 300, height: 200)
    }
}

/// Write's and the Takes bar's presenter (`EditorView.swift`'s and
/// `TakesBottomBar.swift`'s `.sheet(item:)`).
private struct SheetHost: View {
    @Bindable var driver: LifecycleDriver
    let session: AppSession
    let blockID: String
    var body: some View {
        Color.clear.frame(width: 640, height: 560)
            .sheet(item: Binding(
                get: { driver.shown ? SheetItem(blockID: blockID) : nil },
                set: { driver.shown = $0 != nil })
            ) { item in
                CommentsPanel(session: session, blockID: item.blockID)
            }
    }
}

/// THE NESTED SHEET (U3's O-5): Write's take panel is itself a sheet
/// (`EditorView.swift`'s `.sheet(item: $model.fanPanel)`), and it presents the
/// comments as a sheet of its own (`WriteTakesPanel.swift`'s `.sheet(item:)`
/// over `model.commentsRequest`). The real panel; its model passed in so the
/// pin can raise and lower that request.
private struct TakePanelHost: View {
    @Bindable var driver: LifecycleDriver
    let session: AppSession
    let postID: String
    let blockID: String
    let takes: TakesViewModel
    var body: some View {
        Color.clear.frame(width: 900, height: 760)
            .sheet(isPresented: $driver.takePanelShown) {
                WriteTakesPanel(
                    session: session, postID: postID, blockID: blockID,
                    onClose: { driver.takePanelShown = false }, model: takes)
            }
    }
}

@MainActor
private enum CommentHostRig {
    /// One turn: the queued app events dispatched, the run loop given a slice,
    /// then the main actor released so deferred main-queue work runs (the
    /// panel's reports and reveals defer one turn; a sheet animates).
    static func turns(_ count: Int = 20) async {
        for _ in 0..<count {
            while let event = NSApp.nextEvent(
                matching: [.keyDown, .leftMouseDown, .leftMouseUp], until: nil,
                inMode: .default, dequeue: true)
            {
                NSApp.sendEvent(event)
            }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    /// The run loop's slice — a synchronous call (`RunLoop.run` is unavailable
    /// from an async context; the routed suite's `pump()` shape).
    private static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.005))
    }

    /// Turns until `predicate` holds (or the budget runs out); answers it.
    @discardableResult
    static func turns(until predicate: () -> Bool, max: Int) async -> Bool {
        for _ in 0..<max {
            if predicate() { return true }
            await turns(1)
        }
        return predicate()
    }

    static func areas(in view: NSView?) -> [CommentTextAreaView] {
        guard let view else { return [] }
        return ((view as? CommentTextAreaView).map { [$0] } ?? [])
            + view.subviews.flatMap { areas(in: $0) }
    }

    /// The composer — the one area with a placeholder twin.
    static func composer(in window: NSWindow?) -> CommentTextAreaView? {
        areas(in: window?.contentView).first { $0.placeholderView != nil }
    }

    /// A window by its number — looked up at each use, never kept.
    static func window(_ number: Int?) -> NSWindow? {
        guard let number else { return nil }
        return NSApp.windows.first { $0.windowNumber == number }
    }

    static func isVisible(_ number: Int) -> Bool {
        window(number)?.isVisible ?? false
    }

    /// The composer's text and caret in window `number`, read inside this
    /// call so no reference outlives it.
    static func composerState(_ number: Int?) -> (text: String, caret: NSRange)? {
        guard let view = composer(in: window(number))?.textView else { return nil }
        return (view.string, view.selectedRange())
    }

    /// Types into window `number`'s composer through the real input road.
    @discardableResult
    static func typeIntoComposer(_ text: String, inWindow number: Int?) -> Bool {
        guard let area = composer(in: window(number)) else { return false }
        type(text, into: area)
        return true
    }

    /// The models THIS session's panels made that are still alive.
    static func alive(_ session: AppSession) -> [CommentsPanelModel] {
        CommentsPanelModel.debugAliveModels(of: session)
    }

    /// Types into an area through the real input road (`insertText` at the
    /// end), as a keystroke run would.
    static func type(_ text: String, into area: CommentTextAreaView) {
        let view = area.textView
        view.window?.makeFirstResponder(view)
        view.setSelectedRange(NSRange(location: (view.string as NSString).length, length: 0))
        view.insertText(text, replacementRange: view.selectedRange())
    }
}

/// The popover host, mounted: an off-display anchor at alpha 0; each opening's
/// window set alpha 0 the turn it appears.
@MainActor
private final class CommentPopoverRig {
    let driver = LifecycleDriver()
    let anchor: NSWindow

    init(session: AppSession, blockID: String) async {
        anchor = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 300, height: 200),
            styleMask: [.borderless], backing: .buffered, defer: false)
        anchor.isReleasedWhenClosed = false
        anchor.alphaValue = 0
        anchor.contentView = NSHostingView(rootView: PopoverHost(
            driver: driver, session: session, blockID: blockID))
        anchor.orderFront(nil)  // off every display
        await CommentHostRig.turns()
    }

    /// Opens the popover; answers its window's NUMBER — nil if no NEW window
    /// appeared (a reused popover window would read as nil here, by name).
    func open() async -> Int? {
        let before = Set(NSApp.windows.map(\.windowNumber))
        driver.shown = true
        var found: Int?
        await CommentHostRig.turns(until: {
            // OUR popover only: a new, visible window that is a CHILD of this
            // rig's anchor (a popover's window is its anchor's child while it
            // is shown) — never a window another suite running in the same
            // process happens to present.
            if let window = NSApp.windows.first(where: {
                !before.contains($0.windowNumber) && $0.parent === anchor && $0.isVisible
            }) {
                window.alphaValue = 0
                found = window.windowNumber
            }
            return found != nil
        }, max: 80)
        // The panel's `.task` — the park's restore, the focus ask, the
        // observation — runs once the content is installed.
        await CommentHostRig.turns(30)
        return found
    }

    /// The binding road — what a click away and the panel's own close both
    /// end on (`NSPopover` closes → `willClose`, then `didClose`).
    func dismiss(_ number: Int) async {
        driver.shown = false
        await CommentHostRig.turns(until: { !CommentHostRig.isVisible(number) }, max: 80)
        await CommentHostRig.turns(30)
    }

    func tearDown() {
        driver.shown = false
        anchor.orderOut(nil)
    }
}

/// A sheet host, mounted on a titled window (the sheet-presenting suites'
/// precedent).
@MainActor
private final class CommentSheetRig {
    let driver = LifecycleDriver()
    let window: NSWindow

    init(session: AppSession, blockID: String) async {
        window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 640, height: 560),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: SheetHost(
            driver: driver, session: session, blockID: blockID))
        window.makeKeyAndOrderFront(nil)
        await CommentHostRig.turns()
    }

    /// Opens the sheet; answers the sheet window's NUMBER.
    func open() async -> Int? {
        driver.shown = true
        await CommentHostRig.turns(until: { window.attachedSheet != nil }, max: 80)
        await CommentHostRig.turns(30)
        return window.attachedSheet?.windowNumber
    }

    /// The binding road — a programmatic dismissal (the panel's
    /// `.onDisappear` leaving road).
    func dismiss() async {
        driver.shown = false
        await CommentHostRig.turns(until: { window.attachedSheet == nil }, max: 80)
        await CommentHostRig.turns(30)
    }

    func tearDown() {
        driver.shown = false
        window.attachedSheet.map { window.endSheet($0) }
        window.orderOut(nil)
        window.close()
    }
}

/// Write's take panel as a sheet, and the comments as ITS sheet.
@MainActor
private final class CommentTakePanelRig {
    let driver = LifecycleDriver()
    let window: NSWindow
    let takes: TakesViewModel
    let blockID: String

    init(session: AppSession, postID: String, blockID: String) async {
        self.blockID = blockID
        takes = TakesViewModel(session: session, postID: postID)
        window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 900, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: TakePanelHost(
            driver: driver, session: session, postID: postID, blockID: blockID, takes: takes))
        window.makeKeyAndOrderFront(nil)
        await CommentHostRig.turns()
        driver.takePanelShown = true
        await CommentHostRig.turns(until: { window.attachedSheet != nil }, max: 80)
        await CommentHostRig.turns(30)
    }

    /// The take panel's own sheet window.
    var takePanelSheet: NSWindow? { window.attachedSheet }

    /// The panel's comments door's request (`requestComments(blockID:)` sets
    /// exactly this); answers the comments sheet window's NUMBER.
    func openComments() async -> Int? {
        takes.commentsRequest = TakesViewModel.CommentsRequest(blockID: blockID)
        await CommentHostRig.turns(until: { takePanelSheet?.attachedSheet != nil }, max: 80)
        await CommentHostRig.turns(30)
        return takePanelSheet?.attachedSheet?.windowNumber
    }

    /// The request lowered — the sheet's binding road.
    func dismissComments() async {
        takes.commentsRequest = nil
        await CommentHostRig.turns(until: { takePanelSheet?.attachedSheet == nil }, max: 80)
        await CommentHostRig.turns(30)
    }

    func tearDown() {
        takes.commentsRequest = nil
        driver.takePanelShown = false
        if let sheet = takePanelSheet {
            sheet.attachedSheet.map { sheet.endSheet($0) }
            window.endSheet(sheet)
        }
        window.orderOut(nil)
        window.close()
    }
}

// MARK: - The two members' mounted cells, serialized TOGETHER

/// ONE serialized parent for VX-229's and VX-257's mounted suites: both present
/// popovers and sheets, and Swift Testing runs suites in parallel inside one
/// process — two hosts presenting at once would read each other's windows.
/// (`-only-testing:VariorumTests/CommentPanelHostSuites` runs both.)
@MainActor
@Suite("VX-282 U5 — the comments panel's hosts", .serialized)
struct CommentPanelHostSuites {

// MARK: - VX-229 — a dismissed host lets go of its panel

@MainActor
@Suite("VX-229 — a dismissed comments host lets go of its panel's model and observation", .serialized)
struct CommentPanelReleaseTests {
    private func seedComment(_ h: EditorHarness) async throws -> String {
        let blockID = try h.storeSlots()[0].blockID
        _ = try await h.session.runner.run { ops in
            try ops.addBlockComment(to: blockID, text: "First note.")
        }
        return blockID
    }

    /// **The ticket's measurement, through the product's presenter — RED ON
    /// OLD if VX-229's leak is real in the runner; EXPECTED GREEN ON BOTH
    /// SIDES** (the run record's CORRECTION: pools drained and no window held,
    /// the old product released every dismissed panel offscreen). Three
    /// openings of the margin note's popover, each dismissed: every one was a
    /// NEW window holding a live, observing panel, and after the third
    /// dismissal NONE of the three panels' models is alive, none observes the
    /// store, and a comment written afterwards is re-read by nobody.
    @Test func aDismissedPopoverLetsGoOfItsPanelsModelAndItsObservation() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentPopoverRig(session: h.session, blockID: blockID)
            defer { rig.tearDown() }
            #expect(CommentHostRig.alive(h.session).isEmpty, "premise: no panel of this session yet")

            var windows: Set<Int> = []
            for opening in 1...3 {
                let opened = await rig.open()
                let number = try #require(opened, "premise: opening \(opening) showed a NEW popover window")
                windows.insert(number)
                try #require(CommentHostRig.composerState(number) != nil,
                             "premise: opening \(opening) holds a mounted panel")
                try #require(CommentHostRig.alive(h.session).contains { $0.isObserving },
                             "premise: the open panel observes its comments")
                await rig.dismiss(number)
                #expect(!CommentHostRig.isVisible(number), "premise: opening \(opening) closed")
            }
            #expect(windows.count == 3, "premise: three openings, three windows")

            // Any release lands within the close's own turns or one hop after
            // (the popover's `didClose`, SwiftUI's removal): wait, bounded.
            await CommentHostRig.turns(until: { CommentHostRig.alive(h.session).isEmpty }, max: 150)
            let alive = CommentHostRig.alive(h.session)
            #expect(alive.filter(\.isObserving).isEmpty,
                    "no dismissed panel still observes the store (\(alive.filter(\.isObserving).count) do)")
            #expect(alive.isEmpty, "no dismissed panel's model is still alive (\(alive.count) are)")

            // The symptom: a later write is re-read by every stale panel.
            _ = try await h.session.runner.run { ops in
                try ops.addBlockComment(to: blockID, text: "A later note.")
            }
            await CommentHostRig.turns(30)
            let rereads = CommentHostRig.alive(h.session).filter { $0.comments.count == 2 }
            #expect(rereads.isEmpty, "a later write is re-read by no dismissed panel (\(rereads.count) did)")
        }
    }

    /// **GUARD — measured, not assumed: a SHEET host tears its panel down.**
    /// Write's and the Takes bar's presenter, three openings: after each
    /// dismissal no model of this session is alive.
    @Test func aDismissedSheetLetsGoOfItsPanel() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentSheetRig(session: h.session, blockID: blockID)
            defer { rig.tearDown() }
            for opening in 1...3 {
                let opened = await rig.open()
                let sheet = try #require(opened, "premise: opening \(opening) attached a sheet")
                try #require(CommentHostRig.composerState(sheet) != nil,
                             "premise: opening \(opening) holds a mounted panel")
                try #require(CommentHostRig.alive(h.session).contains { $0.isObserving },
                             "premise: the open panel observes its comments")
                await rig.dismiss()
                await CommentHostRig.turns(until: { CommentHostRig.alive(h.session).isEmpty }, max: 150)
                #expect(CommentHostRig.alive(h.session).isEmpty,
                        "opening \(opening): the dismissed sheet's panel is gone")
            }
        }
    }

    /// **GUARD — the take panel's NESTED comments sheet (U3's O-5) tears its
    /// panel down too.** The real `WriteTakesPanel` as a sheet, the comments
    /// as its sheet, three openings.
    @Test func theTakePanelsNestedCommentsSheetLetsGoOfItsPanel() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentTakePanelRig(session: h.session, postID: h.postID, blockID: blockID)
            defer { rig.tearDown() }
            try #require(rig.takePanelSheet != nil, "premise: the take panel is up as a sheet")
            for opening in 1...3 {
                let opened = await rig.openComments()
                let sheet = try #require(opened, "premise: opening \(opening) attached the comments sheet")
                try #require(CommentHostRig.composerState(sheet) != nil,
                             "premise: opening \(opening) holds a mounted panel")
                await rig.dismissComments()
                await CommentHostRig.turns(until: { CommentHostRig.alive(h.session).isEmpty }, max: 150)
                #expect(CommentHostRig.alive(h.session).isEmpty,
                        "opening \(opening): the nested sheet's panel is gone")
            }
        }
    }
}

// MARK: - VX-257 — a host's closing keeps the half-typed comment

/// Her ruling (2026-10-13, verbatim): *"yes, clicking away should save your
/// half typed comment on a draft."* Each host's closing road, end to end
/// through the product's presenter: the composer typed into by the real input
/// road, the host closed by its binding (a popover's click away ends there —
/// `NSPopover` closes → `willClose`; a sheet's programmatic dismissal tears its
/// content down → `.onDisappear`), then a NEW presentation on the same block.
/// The model-level cells — ⎋, another block, a refused draft, a panel that
/// never opened — are `CommentPanelLeaveTests`.
@MainActor
@Suite("VX-257 — a host's closing keeps the half-typed comment; the reopen shows it", .serialized)
struct CommentPanelHostLeavingTests {
    private static let half = "half a thought, left by a click away "

    private func seedComment(_ h: EditorHarness) async throws -> String {
        let blockID = try h.storeSlots()[0].blockID
        _ = try await h.session.runner.run { ops in
            try ops.addBlockComment(to: blockID, text: "First note.")
        }
        return blockID
    }

    private func stored(_ h: EditorHarness, _ blockID: String) async throws -> [String] {
        try await h.database.read { db in
            try Queries.blockComments(db, blockID: blockID).map(\.text)
        }
    }

    /// The reopened composer reads her words back, with the caret after them
    /// (she picks up where she stopped), and nothing was filed.
    private func expectRestored(
        _ number: Int?, _ h: EditorHarness, _ blockID: String, _ host: String
    ) async throws {
        let state = try #require(CommentHostRig.composerState(number), "premise: \(host) reopened a panel")
        #expect(state.text == Self.half, "\(host): the half-typed comment is back")
        #expect(state.caret == NSRange(location: (Self.half as NSString).length, length: 0),
                "\(host): the caret sits after it")
        #expect(try await stored(h, blockID) == ["First note."], "\(host): parking filed nothing")
    }

    /// Types the half comment into window `number`'s composer and confirms it
    /// landed — every reference released before the host closes.
    private func typeHalf(into number: Int?, _ host: String) async throws {
        try #require(CommentHostRig.typeIntoComposer(Self.half, inWindow: number),
                     "premise: \(host) holds a mounted panel")
        await CommentHostRig.turns()
        try #require(CommentHostRig.composerState(number)?.text == Self.half,
                     "premise: typed into \(host)'s composer")
    }

    /// **RED ON OLD — the popover (the Takes margin note's), her ruling's
    /// road.**
    @Test func aClickAwayFromThePopoverKeepsTheDraftForTheReopen() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentPopoverRig(session: h.session, blockID: blockID)
            defer { rig.tearDown() }
            let opened = await rig.open()
            let first = try #require(opened, "premise: the popover opened")
            try await typeHalf(into: first, "the popover")
            await rig.dismiss(first)

            let reopened = await rig.open()
            try await expectRestored(reopened, h, blockID, "the popover")
            if let reopened { await rig.dismiss(reopened) }
        }
    }

    /// **RED ON OLD — Write's / the Takes bar's sheet** (`.sheet(item:)`),
    /// dismissed by its binding.
    @Test func aSheetsClosingKeepsTheDraftForTheReopen() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentSheetRig(session: h.session, blockID: blockID)
            defer { rig.tearDown() }
            try await typeHalf(into: await rig.open(), "the sheet")
            await rig.dismiss()

            try await expectRestored(await rig.open(), h, blockID, "the sheet")
            await rig.dismiss()
        }
    }

    /// **RED ON OLD — the take panel's NESTED comments sheet** (U3's O-5: the
    /// fourth host), closed by its request's binding.
    @Test func theTakePanelsNestedSheetKeepsTheDraftForTheReopen() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentTakePanelRig(session: h.session, postID: h.postID, blockID: blockID)
            defer { rig.tearDown() }
            try #require(rig.takePanelSheet != nil, "premise: the take panel is up as a sheet")
            try await typeHalf(into: await rig.openComments(), "the nested sheet")
            await rig.dismissComments()

            try await expectRestored(await rig.openComments(), h, blockID, "the nested sheet")
            await rig.dismissComments()
        }
    }
}

}  // CommentPanelHostSuites
