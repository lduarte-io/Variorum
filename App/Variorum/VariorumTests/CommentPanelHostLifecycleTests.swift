//
//  CommentPanelHostLifecycleTests.swift
//  VariorumTests
//
//  VX-282 U5 — the comments panel's HOST LIFECYCLE, pinned through the
//  product's own presenters (the record: `notes/plans/fixes/vx-282-editor-
//  notes-fixes.md` § U5).
//
//  VX-229 (the leak): SwiftUI never tears a dismissed popover's content down
//  and makes a NEW popover window per opening (measured — VX-179's
//  `stale.swift`, re-measured at U5 by a standalone probe), so every opening of
//  the Takes margin note's comments left the previous panel whole: its model
//  and its store observation (the panel's `.task` never cancels — one more
//  re-read per comment write, per stale panel, for the app's life). The sheet
//  hosts are expected to tear their content down — GUARDS here measure it per
//  host shape rather than assume it.
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
//  target does. RED ON OLD where marked: the pins are committed ahead of the
//  fix, so the pre-fix product is that commit's. GUARD = green on both sides by
//  design.
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

    /// Opens the popover; answers its window — nil if no NEW window appeared
    /// (a reused popover window would read as nil here, by name).
    func open() async -> NSWindow? {
        let before = Set(NSApp.windows.map(ObjectIdentifier.init))
        driver.shown = true
        var found: NSWindow?
        await CommentHostRig.turns(until: {
            found = NSApp.windows.first {
                !before.contains(ObjectIdentifier($0)) && $0 !== anchor && $0.isVisible
            }
            found?.alphaValue = 0
            return found != nil
        }, max: 80)
        // The panel's `.task` — the park's restore, the focus ask, the
        // observation — runs once the content is installed.
        await CommentHostRig.turns(30)
        return found
    }

    /// The binding road — what a click away and the panel's own close both
    /// end on (`NSPopover` closes → `willClose`, then `didClose`).
    func dismiss(_ window: NSWindow) async {
        driver.shown = false
        await CommentHostRig.turns(until: { !window.isVisible }, max: 80)
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

    /// Opens the sheet; answers the sheet's window.
    func open() async -> NSWindow? {
        driver.shown = true
        await CommentHostRig.turns(until: { window.attachedSheet != nil }, max: 80)
        await CommentHostRig.turns(30)
        return window.attachedSheet
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
    /// exactly this); answers the comments sheet's window.
    func openComments() async -> NSWindow? {
        takes.commentsRequest = TakesViewModel.CommentsRequest(blockID: blockID)
        await CommentHostRig.turns(until: { takePanelSheet?.attachedSheet != nil }, max: 80)
        await CommentHostRig.turns(30)
        return takePanelSheet?.attachedSheet
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

    /// **RED ON OLD — the ticket's measurement, through the product's
    /// presenter.** Three openings of the margin note's popover, each
    /// dismissed: every one was a NEW window holding a live panel, and after
    /// the third dismissal NONE of the three panels' models is alive, none
    /// observes the store, and a comment written afterwards is re-read by
    /// nobody. (Old: three models alive, three observations running, three
    /// re-reads of the write.)
    @Test func aDismissedPopoverLetsGoOfItsPanelsModelAndItsObservation() async throws {
        try await withEditor(seedBlocks: ["A block."]) { h in
            let blockID = try await seedComment(h)
            let rig = await CommentPopoverRig(session: h.session, blockID: blockID)
            defer { rig.tearDown() }
            #expect(CommentHostRig.alive(h.session).isEmpty, "premise: no panel of this session yet")

            var windows: Set<ObjectIdentifier> = []
            for opening in 1...3 {
                let opened = await rig.open()
                let window = try #require(opened, "premise: opening \(opening) showed a NEW popover window")
                windows.insert(ObjectIdentifier(window))
                try #require(CommentHostRig.composer(in: window) != nil,
                             "premise: opening \(opening) holds a mounted panel")
                try #require(CommentHostRig.alive(h.session).contains { $0.isObserving },
                             "premise: the open panel observes its comments")
                await rig.dismiss(window)
                #expect(!window.isVisible, "premise: opening \(opening) closed")
            }
            #expect(windows.count == 3, "premise: three openings, three windows")

            // The release lands one hop after the close (the popover's
            // `didClose`, then SwiftUI's removal): wait for it, bounded.
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
                try #require(CommentHostRig.composer(in: sheet) != nil,
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
                try #require(CommentHostRig.composer(in: sheet) != nil,
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
        _ window: NSWindow?, _ h: EditorHarness, _ blockID: String, _ host: String
    ) async throws {
        let composer = try #require(CommentHostRig.composer(in: window), "premise: \(host) reopened a panel")
        #expect(composer.textView.string == Self.half, "\(host): the half-typed comment is back")
        #expect(composer.textView.selectedRange()
                    == NSRange(location: (Self.half as NSString).length, length: 0),
                "\(host): the caret sits after it")
        #expect(try await stored(h, blockID) == ["First note."], "\(host): parking filed nothing")
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
            let composer = try #require(CommentHostRig.composer(in: first), "premise: a mounted panel")
            CommentHostRig.type(Self.half, into: composer)
            await CommentHostRig.turns()
            try #require(composer.textView.string == Self.half, "premise: typed into the composer")
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
            let opened = await rig.open()
            let composer = try #require(CommentHostRig.composer(in: opened), "premise: the sheet holds a panel")
            CommentHostRig.type(Self.half, into: composer)
            await CommentHostRig.turns()
            try #require(composer.textView.string == Self.half, "premise: typed into the composer")
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
            let opened = await rig.openComments()
            let composer = try #require(CommentHostRig.composer(in: opened), "premise: the nested sheet holds a panel")
            CommentHostRig.type(Self.half, into: composer)
            await CommentHostRig.turns()
            try #require(composer.textView.string == Self.half, "premise: typed into the composer")
            await rig.dismissComments()

            try await expectRestored(await rig.openComments(), h, blockID, "the nested sheet")
            await rig.dismissComments()
        }
    }
}
