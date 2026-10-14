//
//  MCPSharedIconClickTests.swift
//  VariorumTests (Mac)
//
//  VX-281 ladder round 1 — THE SHARED ICON, CLICKED, on every host U2 gave it.
//
//  R1-5 (the evidence gap): U2's walk opened the icon's popover only from the
//  Library's List rows and ⌘L's rows; Cards, the Timeline, the Book Panel and
//  the Pool captured the icon only — and two of them nest the icon's button in
//  a row-wide one (the Timeline row's `Button` inside its `List`; the Book
//  Panel row's `Button`), the other two in a tap-to-open card. Here each host
//  is mounted for real and its icon CLICKED with synthetic events (U3's shape —
//  the Bookcase row's nested-icon probe, never committed then): the click must
//  present the icon's popover and never fire the row's open. A red here is a
//  DEFECT, fixed red-first.
//
//  The road to the icon: in-process, SwiftUI builds no accessibility nodes, so
//  the icon carries a DEBUG anchor (`MCPSharedIconProbe` — its window frame,
//  and each popover's presentation by its first client's name).
//
//  The rig is the canvas/workbench rig's: a non-activating panel away from the
//  machine's pointer, the app's own event pump (SwiftUI's gestures conclude
//  only under `NSApp.nextEvent` dispatch — measured there).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The click rig (`BlocksWorkbenchFaceTests.Rig`'s shape).
@MainActor
final class SharedIconRig {
    let window: NSPanel
    let hosting: NSHostingView<AnyView>

    init<V: View>(_ view: V, width: CGFloat = 900, height: CGFloat = 600) {
        window = NSPanel(
            contentRect: Self.frameAwayFromThePointer(width: width, height: height),
            styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isFloatingPanel = true
        window.becomesKeyOnlyIfNeeded = false
        window.hidesOnDeactivate = false
        hosting = NSHostingView(rootView: AnyView(view))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
    }

    /// A row under the REAL pointer is hovered, and hover has its own faces
    /// (the cards' tags row) — the window goes where the pointer is not.
    private static func frameAwayFromThePointer(width: CGFloat, height: CGFloat) -> NSRect {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 2000, height: 1200)
        let x = mouse.x < screen.midX ? max(screen.midX, screen.maxX - width) : screen.minX
        let y = mouse.y < screen.midY ? screen.maxY - height : screen.minY
        return NSRect(x: x, y: y, width: width, height: height)
    }

    /// The app's own event pump.
    func pump(_ seconds: TimeInterval) {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if let event = NSApp.nextEvent(matching: .any, until: deadline, inMode: .default, dequeue: true) {
                if event.type == .appKitDefined || event.type == .systemDefined
                    || event.type == .applicationDefined {
                    continue
                }
                NSApp.sendEvent(event)
            }
        }
    }

    func turn() async {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump(0.02)
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(15))
    }

    @discardableResult
    func poll(timeout: TimeInterval, until condition: () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            await turn()
        }
        return condition()
    }

    /// A mouse event at a WINDOW point.
    func send(_ type: NSEvent.EventType, at point: NSPoint) {
        guard let event = NSEvent.mouseEvent(
            with: type, location: point, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 1, clickCount: 1,
            pressure: type == .leftMouseUp ? 0 : 1)
        else { return }
        NSApp.sendEvent(event)
    }

    /// One click — down, a beat, up — at a WINDOW point.
    func click(at point: NSPoint) async {
        window.makeKeyAndOrderFront(nil)
        send(.leftMouseDown, at: point)
        pump(0.03)
        send(.leftMouseUp, at: point)
        pump(0.03)
        await turn()
    }

    func close() {
        window.orderOut(nil)
        window.close()
        pump(0.02)
    }
}

/// A count a closure can bump (the hosts' open doors, the switcher's close).
@MainActor
final class SharedIconCounter {
    var count = 0
}

/// R1-9's host: one row whose reach a pin empties and restores.
@MainActor
@Observable
final class SharedIconReachBox {
    var reaches: [MCPPlaceReach] = []
}

private struct SharedIconBoxHost: View {
    let box: SharedIconReachBox

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("a note an AI act moves")
            MCPSharedIcon(reaches: box.reaches, tokens: .studyLight)
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(width: 420, height: 140, alignment: .topLeading)
    }
}

@MainActor
@Suite("VX-281 ladder R1 — the shared icon clicked on every host (R1-5), its own state (R1-9), ⌘L's Esc (R1-2)", .serialized)
struct MCPSharedIconClickTests {
    private func withWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2815))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func defaults(_ name: String) throws -> UserDefaults {
        let suite = "vx281-icon-click-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @discardableResult
    private func approved(_ ops: Operations, _ name: String) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func note(_ ops: Operations, _ title: String) throws -> Container {
        let post = try ops.createPost(title: title)
        _ = try ops.newBlock(in: post.id, text: "\(title) — words", registeringUndo: false)
        return post
    }

    private func grant(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
    }

    /// Wait (bounded, ~4 s) for a condition a held observation settles.
    private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<400 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    /// **The pin's act:** the host draws exactly ONE icon (one reached row);
    /// a click on it presents the popover of `client`'s reach — and the row's
    /// own open (`opens`) never fires.
    private func clickTheOneIcon(
        _ rig: SharedIconRig, client: String, host: String, opens: () -> Int
    ) async throws {
        let drawn = await rig.poll(timeout: 8) { MCPSharedIconProbe.frames(in: rig.window).count == 1 }
        // A host's own `.task` may re-read its rows on appear (where the host
        // runs it): let the first turns settle, then read the frame afresh.
        await rig.poll(timeout: 0.6) { false }
        #expect(drawn && MCPSharedIconProbe.frames(in: rig.window).count == 1,
                "\(host): exactly one row wears the icon (\(MCPSharedIconProbe.frames(in: rig.window).count) drawn)")
        let frame = try #require(MCPSharedIconProbe.frames(in: rig.window).first, "\(host): the icon drew")
        #expect(frame.width >= 6 && frame.height >= 6, "\(host): the icon has a body to click (\(frame))")
        let before = MCPSharedIconProbe.presentations(of: client)
        await rig.click(at: NSPoint(x: frame.midX, y: frame.midY))
        let shown = await rig.poll(timeout: 3) { MCPSharedIconProbe.presentations(of: client) > before }
        #expect(shown, "\(host): a click on the icon presents its popover")
        await rig.poll(timeout: 0.4) { false }
        #expect(opens() == 0, "\(host): the row's open never fired for the icon's click")
    }

    // MARK: - R1-5 — Cards

    @Test func aCardsIconClickShowsItsPopoverAndNeverOpensTheNote() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "r15-cards")
            let shared = try note(ops, "a shared card")
            _ = try note(ops, "a plain card")
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, shared.id))
            let model = LibraryCatalogModel(session: session, defaults: try defaults("cards"))
            model.mode = .notes
            await model.search()
            defer { model.stopHoldingFacts() }
            let opens = SharedIconCounter()
            let rig = SharedIconRig(LibraryCatalogView(
                session: session, model: model, library: LibraryViewModel(session: session),
                tags: TagsViewModel(session: session), onOpen: { _ in opens.count += 1 }))
            defer { rig.close() }
            #expect(try await settle { !model.rowExtras(for: shared.id).reach.isEmpty }, "the card's reach landed")
            try await clickTheOneIcon(rig, client: "r15-cards", host: "Cards") { opens.count }
        }
    }

    // MARK: - R1-5 — the Timeline (a row Button inside a List)

    @Test func aTimelineRowsIconClickShowsItsPopoverAndNeverOpensTheNote() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "r15-timeline")
            let shared = try note(ops, "a shared timeline note")
            _ = try note(ops, "a plain timeline note")
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, shared.id))
            let model = TimelineViewModel(session: session)
            await model.reload()
            let hold = Task { await model.holdReach(model.reachIDs) }
            defer { hold.cancel() }
            #expect(try await settle { model.reach[shared.id] != nil }, "the row's reach landed")
            let opens = SharedIconCounter()
            let rig = SharedIconRig(TimelineView(session: session, model: model) { _ in opens.count += 1 })
            defer { rig.close() }
            try await clickTheOneIcon(rig, client: "r15-timeline", host: "Timeline") { opens.count }
        }
    }

    // MARK: - R1-5 — the Book Panel (a row Button around the icon's)

    @Test func aBookPanelRowsIconClickShowsItsPopoverAndNeverOpensTheNote() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "r15-panel")
            let open = try note(ops, "the open note")
            let sibling = try note(ops, "its sibling")
            let book = try ops.createReading(name: "the panel book", kind: .book)
            _ = try ops.addPostToReading(open.id, to: book.id)
            _ = try ops.addPostToReading(sibling.id, to: book.id)
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, sibling.id))

            let membership = NoteMembershipModel()
            let track = Task { await membership.track(session: session, postID: open.id) }
            defer { track.cancel() }
            let model = BookPanelModel(session: session, postID: open.id)
            let contents = Task { await model.observe(bookID: book.id) }
            defer { contents.cancel() }
            #expect(try await settle {
                model.entryIDs(for: book.id).count == 2 && membership.readings(for: open.id).count == 1
            }, "the panel's book and contents landed")
            let hold = Task { await model.holdReach(model.entryIDs(for: book.id)) }
            defer { hold.cancel() }
            #expect(try await settle { model.reach[sibling.id] != nil }, "the sibling row's reach landed")

            let opens = LockIsolated(0)
            let observer = NotificationCenter.default.addObserver(
                forName: .variorumOpenBookAtPost, object: nil, queue: nil
            ) { _ in opens.withValue { $0 += 1 } }
            defer { NotificationCenter.default.removeObserver(observer) }
            let rig = SharedIconRig(
                BookPanelView(session: session, postID: open.id, membership: membership, model: model),
                width: 340, height: 600)
            defer { rig.close() }
            try await clickTheOneIcon(rig, client: "r15-panel", host: "Book Panel") { opens.value }
        }
    }

    // MARK: - R1-5 — the Pool (a tap-to-open card)

    @Test func aPoolCardsIconClickShowsItsPopoverAndNeverOpensTheNote() async throws {
        try await withWorld { session, db in
            let ops = session.operations
            let client = try approved(ops, "r15-pool")
            let shared = try note(ops, "a shared pool note")
            _ = try note(ops, "a loose pool note")
            _ = try ops.grantMCPAccess(client.id, grant(.read, .note, shared.id))
            let model = PoolPostsModel(session: session)
            await model.adopt(try await db.read {
                try Queries.notePoolListing($0, window: PoolPostsModel.window)
            })
            let hold = Task { await model.holdReach(model.drawnIDs) }
            defer { hold.cancel() }
            #expect(try await settle { model.reach[shared.id] != nil }, "the card's reach landed")
            let opens = SharedIconCounter()
            let rig = SharedIconRig(PoolPostsView(
                session: session, model: model,
                onDuplicateAsVersion: { _ in }, onArchive: { _ in },
                readings: ReadingsViewModel(session: session),
                tags: TagsViewModel(session: session),
                onOpen: { _ in opens.count += 1 }))
            defer { rig.close() }
            try await clickTheOneIcon(rig, client: "r15-pool", host: "Pool") { opens.count }
        }
    }

    // MARK: - R1-9 — the icon never presents itself (R-13nb-23/26g)

    private func reach(_ client: String) -> [MCPPlaceReach] {
        [MCPPlaceReach(
            client: MCPClient(
                id: "c-\(client)", name: client, version: "2", state: .approved,
                firstSeenAt: "2026-07-01T00:00:00.000Z", lastSeenAt: "2026-07-01T00:00:00.000Z",
                decidedAt: nil),
            rung: .read, grant: nil, throughTitle: nil)]
    }

    /// **R1-9 (the reviewer's SPECULATIVE nit, settled here):** since VX-268 the
    /// icon's calm state lives INSIDE the icon, so a host keeps the icon (and
    /// its `shown`) while its reach empties. Her popover is up; an AI act takes
    /// the reach away (spends a once grant, moves the note, removes it from the
    /// granting book) — the button and its popover leave; the reach returns.
    /// The popover must NOT present itself: only her press opens it
    /// (never-present-yourself, R-13nb-23/26g). Red ⇒ the icon kept
    /// `shown == true` across the empty spell; green on the pre-fix tree ⇒
    /// SwiftUI wrote `false` back itself and the finding is HOLLOW.
    @Test func anIconWhoseReachLeavesAndReturnsNeverPresentsItsPopoverByItself() async throws {
        let name = "r19-client"
        let box = SharedIconReachBox()
        box.reaches = reach(name)
        let rig = SharedIconRig(SharedIconBoxHost(box: box), width: 420, height: 140)
        defer { rig.close() }
        try await clickTheOneIcon(rig, client: name, host: "R1-9's row") { 0 }
        #expect(MCPSharedIconProbe.presentations(of: name) == 1, "her press presented it once")

        // The reach leaves while the popover is up…
        box.reaches = []
        await rig.poll(timeout: 1.5) { MCPSharedIconProbe.frames(in: rig.window).isEmpty }
        #expect(MCPSharedIconProbe.frames(in: rig.window).isEmpty, "the calm icon draws nothing")
        await rig.poll(timeout: 0.6) { false }

        // …and comes back.
        box.reaches = reach(name)
        await rig.poll(timeout: 1.5) { MCPSharedIconProbe.frames(in: rig.window).count == 1 }
        await rig.poll(timeout: 1.2) { MCPSharedIconProbe.presentations(of: name) > 1 }
        #expect(MCPSharedIconProbe.presentations(of: name) == 1,
                "the popover never presents itself when the reach returns (presented \(MCPSharedIconProbe.presentations(of: name))×, up now \(MCPSharedIconProbe.up[name] ?? 0))")
    }

    // MARK: - R1-2 — ⌘L: Esc over a row's popover dismisses the popover, never the switcher

    /// The pure decision (macOS's own rule: Esc dismisses the topmost
    /// transient; the nested ask sheet already keeps its own Esc).
    @Test func escapeOverARowsPopoverDismissesThePopoverAndAloneClosesTheSwitcher() {
        #expect(WingSwitcherKeys.escape(rowPopoverShown: true) == .dismissRowPopover,
                "a row's popover up: Esc takes the popover, the switcher stays")
        #expect(WingSwitcherKeys.escape(rowPopoverShown: false) == .closeSwitcher,
                "nothing over the rows: Esc closes the switcher, as it always has")
    }

    private static func view<T: NSView>(_ type: T.Type, in root: NSView) -> T? {
        if let found = root as? T { return found }
        for sub in root.subviews {
            if let found = view(type, in: sub) { return found }
        }
        return nil
    }

    /// U2's walk, as a pin: ⌘L up, a row's shared icon clicked open, then Esc
    /// as the switcher's own key catcher hears it (its window kept key — the
    /// field keeps focus, the popover holds plain buttons). The popover goes;
    /// the switcher, and her typed filter, stay. A second Esc closes it.
    @Test func escapeOverARowsPopoverLeavesTheSwitcherUp() async throws {
        try await withWorld { session, _ in
            let ops = session.operations
            let client = try approved(ops, "r12-client")
            _ = try ops.grantMCPAccess(client.id, grant(.read, .wing, ""))
            _ = try ops.createWing(name: "elsewhere")
            let wings = WingsModel(session: session)
            await wings.load()
            let watch = Task { await wings.watchSharing() }
            defer { watch.cancel() }
            #expect(try await settle { wings.reach[""] != nil }, "Home's row is reached (its wing grant)")

            let closes = SharedIconCounter()
            let rig = SharedIconRig(
                WingSwitcherSheet(
                    model: WingSwitcherModel(wings: wings), tokens: .studyLight,
                    close: { closes.count += 1 }),
                width: 440, height: 420)
            defer { rig.close() }
            try await clickTheOneIcon(rig, client: "r12-client", host: "⌘L's Home row") { closes.count }
            #expect((MCPSharedIconProbe.up["r12-client"] ?? 0) == 1, "the row's popover is up")

            // "Gone" is AppKit's word — no visible popover window left (the
            // content's own disappear record, `up`, rides the message).
            func popoverGone() -> Bool {
                !NSApp.windows.contains {
                    $0.isVisible && String(describing: type(of: $0)).contains("Popover")
                }
            }
            #expect(!popoverGone(), "non-vacuity: AppKit shows the row's popover before the Esc")

            let catcher = try #require(
                Self.view(WingSwitcherKeyCatcher.CatcherView.self, in: rig.hosting), "the switcher's key catcher")
            #expect(catcher.onKey?(.escape) == true, "Esc is the switcher's to act on")
            await rig.poll(timeout: 2) { popoverGone() }
            #expect(closes.count == 0, "the switcher stays — Esc took the row's popover")
            #expect(popoverGone(),
                    "the popover is gone (up \(MCPSharedIconProbe.up["r12-client"] ?? 0); popover windows visible: \(NSApp.windows.filter { $0.isVisible && String(describing: type(of: $0)).contains("Popover") }.count))")

            #expect(catcher.onKey?(.escape) == true)
            #expect(closes.count == 1, "with nothing over the rows, Esc closes the switcher")
        }
    }
}
