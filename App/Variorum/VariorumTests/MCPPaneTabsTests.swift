//
//  MCPPaneTabsTests.swift
//  VariorumTests (Mac)
//
//  VX-281 U1 — SETTINGS ▸ MCP IN TABS (R-VX184-6, her pick: "just clicking on
//  it, you wouldn't know without scrolling down where the command to set it
//  up is … as a settings pane, it has a LOT of text") and VX-232 (the setup
//  menu's choice lost on a remount while its copy receipt stayed). The run
//  record: `notes/plans/fixes/vx-281-mcp-settings-pane-shared-icon.md`, the U1
//  UNIT RECORD.
//
//  Two MOUNT pins, written against the pane as it stood before the rebuild so
//  each is red there:
//  - VX-232 (a bug): the menu's choice was VIEW state, the receipt the DOOR's
//    — a remounted pane showed Claude Code under the Any-client receipt;
//  - the GEOMETRY ORACLE (a design row, her ruling): inside VX-214's 748×520
//    Settings content, a fresh pane opens on Connect with its tab row whole
//    and the setup's code block in sight — no scroll to reach it — in both
//    voices.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// An in-memory library with deterministic ids and clock (the setup key's
/// mint needs a store — VX-168).
@MainActor
private func withPaneWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 281))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-281 U1 — Settings ▸ MCP in tabs (R-VX184-6) and the setup menu's memory (VX-232)", .serialized)
struct MCPPaneTabsTests {
    /// Her ruling's four tabs, in her order (R-VX184-6).
    static let tabLabels = ["Connect", "Clients", "Shared with AI", "Activity"]

    // MARK: - Mounting

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// A real window holding the view at `size` (the capture harnesses' road).
    private func mount<V: View>(_ view: V, size: NSSize) -> (NSWindow, NSView) {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.orderFrontRegardless()
        return (window, hosting)
    }

    private func unmount(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
        pump()
    }

    /// Lets the view's tasks and observations deliver until `condition` holds.
    private func settle(_ host: NSView, until condition: () -> Bool, turns: Int = 120) async {
        for _ in 0..<turns {
            host.layoutSubtreeIfNeeded()
            host.window?.displayIfNeeded()
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    private func segmented(in view: NSView) -> [NSSegmentedControl] {
        var found = (view as? NSSegmentedControl).map { [$0] } ?? []
        for sub in view.subviews { found += segmented(in: sub) }
        return found
    }

    private func labels(_ control: NSSegmentedControl) -> [String] {
        (0..<control.segmentCount).map { control.label(forSegment: $0) ?? "" }
    }

    /// The setup menu: the segmented control whose segments are its clients.
    private func clientMenu(in view: NSView) -> NSSegmentedControl? {
        segmented(in: view).first { labels($0) == MCPSetupClient.allCases.map(\.label) }
    }

    /// The pane's tab row: the segmented control whose segments are her four.
    private func tabRow(in view: NSView) -> NSSegmentedControl? {
        segmented(in: view).first { labels($0) == Self.tabLabels }
    }

    // MARK: - VX-232 (RED ON OLD)

    /// VX-184 U1's live round: Any MCP client chosen, its setup copied, then a
    /// voice flip (General and back) REMOUNTED the pane — the menu came back
    /// on Claude Code while the receipt beneath still spoke the Any-client
    /// sentence. The receipt must name the client the menu shows, and the
    /// choice she made survives the remount.
    @Test func aRemountedPaneShowsTheClientItsCopyReceiptNames() async throws {
        try await withPaneWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-vx281-remount-\(UUID().uuidString)"))
            defer { pasteboard.releaseGlobally() }

            // The copy she made with Any MCP client chosen, in a pane that is
            // gone now (her walk: Settings ▸ General to flip the voice).
            await door.copySetupCommand(for: .anyClient, to: pasteboard)
            #expect(door.note == MCPDoor.Note(text: MCPSetupClient.anyClient.copiedReceipt, place: .connect))

            // The pane mounted again.
            let (window, host) = mount(MCPPane(door: door), size: NSSize(width: 523, height: 1600))
            defer { unmount(window) }
            await settle(host, until: { clientMenu(in: host) != nil })
            let menu = try #require(clientMenu(in: host), "the setup menu renders")
            let shown = MCPSetupClient.allCases[menu.selectedSegment]

            #expect(door.note == nil || door.note?.text == shown.copiedReceipt,
                    "the receipt beneath the menu names the client it shows (shown \(shown.label), receipt “\(door.note?.text ?? "")”)")
            #expect(shown == .anyClient, "the choice she made survives the pane going away")
        }
    }

    // MARK: - The geometry oracle (her ruling's shape — a design row)

    /// Inside VX-214's Settings content (748×520), a FRESH pane — no client
    /// approved — opens on Connect: the tab row whole inside the detail
    /// column, and the setup's code block (its header holds the client menu)
    /// in sight with room for its first lines, no scroll. Both voices (the
    /// Settings header's subtitle sets in the voice's own type).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func aFreshPaneOpensOnConnectWithItsCodeBlockInSight(voice: ThemeVoice) async throws {
        try await withPaneWorld { session, _ in
            try session.operations.setThemeVoice(voice)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.requestSettings()  // ⌥⌘, — the window opens AT the MCP pane

            let size = AppSettingsView.contentSize
            let (window, host) = mount(AppSettingsView(session: session, mcp: door), size: size)
            defer { unmount(window) }
            await settle(host, until: { tabRow(in: host) != nil && clientMenu(in: host) != nil })
            await settle(host, until: { false }, turns: 15)

            let tabs = try #require(tabRow(in: host), "\(voice): the pane renders her four tabs")
            #expect(tabs.selectedSegment == 0, "\(voice): no client approved — the pane opens on Connect")
            let tabFrame = tabs.convert(tabs.bounds, to: nil)
            #expect(tabFrame.minX >= AppSettingsView.sidebarWidth + 1 && tabFrame.maxX <= size.width,
                    "\(voice): the tab row sits whole inside the detail column (\(tabFrame))")
            #expect(tabFrame.minY >= 0 && tabFrame.maxY <= size.height,
                    "\(voice): the tab row is on screen (\(tabFrame))")

            let menu = try #require(clientMenu(in: host), "\(voice): the setup menu renders on Connect")
            let menuFrame = menu.convert(menu.bounds, to: nil)
            let clip = menu.enclosingScrollView?.contentView ?? host
            let visible = clip.convert(clip.bounds, to: nil)
            #expect(visible.contains(menuFrame),
                    "\(voice): the code block's header is in sight (\(menuFrame) in \(visible))")
            // The code block's first lines sit under its header: at least
            // three lines of the 11-pt mono setup (≈ 14 pt each) plus the
            // block's padding are in sight below the menu, unscrolled.
            #expect(menuFrame.minY - visible.minY >= 56,
                    "\(voice): the setup's first lines are in sight below the menu (\(menuFrame.minY - visible.minY) pt)")
        }
    }
}
