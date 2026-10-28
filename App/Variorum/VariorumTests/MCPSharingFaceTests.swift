//
//  MCPSharingFaceTests.swift
//  VariorumTests (Mac)
//
//  VX-590 — SETTINGS ▸ MCP's SHARING FACE WAITS FOR THE LIBRARY'S FIRST CLIENT
//  (the VX-620 run, batch 2; the record `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`,
//  BATCH 2 RECORD). Her words: "what's the lift on only showing the 'share with
//  AI' in the settings menu if someone has connected an MCP server? ... I don't
//  want someone who doesn't use AI to see that & get scared that their work is
//  shared." The design care (the ticket): the Connect road stays findable — it
//  is how the first client arrives — and it is the sharing face that hides.
//
//  As built (PROVISIONAL RB-3): the Shared with AI tab, and the open book it
//  holds, render once a client row exists — waiting, approved or denied:
//  VX-512's own fact (`MCPPane.saysClientsBelongToTheLibrary`) read the other
//  way, and monotone (a client row is never removed). Every share face OUTSIDE
//  the pane already waits for an approved client — VX-272's `hasApprovedClient`,
//  pinned by `MCPShareFacesTests.theGatesFollowAnApprovedClientAndTheServerSwitch`
//  and its neighbours (VERIFIED, not rebuilt). Red on old BY CONSTRUCTION: the
//  gate, the offered set and the search's leave-out did not exist — the pane
//  drew `MCPPaneTab.allCases` whatever the library held.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withFaceWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 590))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-590 — Settings ▸ MCP's sharing face waits for the library's first client", .serialized)
struct MCPSharingFaceTests {
    // MARK: - The gate (pure)

    @Test func theFaceShowsOnceTheLibraryHasHadAClientWaitingApprovedOrDenied() {
        var snapshot = MCPDoor.Snapshot()
        #expect(!MCPPane.showsSharingFace(snapshot), "a library that never had a client: no sharing face")
        snapshot.pendingCount = 1
        #expect(MCPPane.showsSharingFace(snapshot), "a client asked to connect")
        snapshot.pendingCount = 0
        snapshot.clientCount = 1
        #expect(MCPPane.showsSharingFace(snapshot), "an approved or a denied client")
        // VX-512's line and the face are one fact, read both ways.
        for pending in 0...2 {
            for clients in 0...2 {
                var s = MCPDoor.Snapshot()
                s.pendingCount = pending
                s.clientCount = clients
                #expect(MCPPane.showsSharingFace(s) == !MCPPane.saysClientsBelongToTheLibrary(s),
                        "pending \(pending), decided \(clients)")
            }
        }
        // The open book alone never brings the face: it reaches only approved
        // clients, and the approval sheet says it is on (`approveAloneDetail`).
        var openBook = MCPDoor.Snapshot()
        openBook.openBook = true
        #expect(!MCPPane.showsSharingFace(openBook))
        #expect(MCPPaneCopy.approveAloneDetail(openBook: true).contains("The open book is on"),
                "the first approval says it, where the face would have")
    }

    /// The door's own fact, on a real library: a fresh one hides the face, a
    /// first request brings it, and a Deny never takes it back ("ever").
    @Test func theDoorsFactFollowsTheClientRowsAndNeverGoesBack() async throws {
        try await withFaceWorld { (session: AppSession, db: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            try await Task.sleep(for: .milliseconds(100))
            #expect(!MCPPane.showsSharingFace(door.snapshot), "a fresh library")
            let request = try session.operations.recordMCPContact(name: "claude-code", version: "2")
            #expect(try await Self.settle { MCPPane.showsSharingFace(door.snapshot) }, "a first connection request")
            try session.operations.denyMCPClient(request.id)
            #expect(try await Self.settle { door.snapshot.clientCount == 1 && door.snapshot.pendingCount == 0 })
            #expect(MCPPane.showsSharingFace(door.snapshot), "denied, the client's row stays — so does the face")
        }
    }

    // MARK: - The tabs offered and shown (pure)

    @Test func theTabsOfferedLeaveOutSharedWithAIUntilTheFaceShows() {
        #expect(MCPPaneTab.offered(sharing: true) == MCPPaneTab.allCases, "her four, her order")
        #expect(MCPPaneTab.offered(sharing: false) == [.connect, .clients, .activity],
                "the Connect road stays — the first client arrives by it")
        // Her pick shows while it is offered…
        for picked in MCPPaneTab.offered(sharing: false) {
            #expect(MCPPaneTab.shown(picked, sharing: false, approvedCount: 0) == picked)
        }
        for picked in MCPPaneTab.allCases {
            #expect(MCPPaneTab.shown(picked, sharing: true, approvedCount: 3) == picked)
        }
        // …and a Shared with AI pick that isn't offered (remembered from another
        // library this app run) opens by the rule: Connect.
        #expect(MCPPaneTab.shown(.shared, sharing: false, approvedCount: 0) == .connect)
        // The rule never lands on a hidden tab: an approved client means the face shows.
        #expect(MCPPaneTab.opening(remembered: nil, approvedCount: 0) != .shared)
    }

    // MARK: - The search names no row the hidden tab holds

    @Test func theSearchNeverNamesTheOpenBookWhileTheFaceHides() throws {
        func mcpFindings(_ query: String, sharing: Bool) -> [SettingsFinding] {
            SettingsSearch.findings(
                matching: query, in: SettingsSearch.wholeIndex(accountSection: true, mcpSharingFace: sharing))
                .filter { $0.pane == .mcp && $0.kind == .setting }
        }
        // MID620-1 (A JUSTIFIED EDIT, the ritual — the VX-620 mid window's first run of this pin): the
        // query asks for the open book's OWN row, never "no MCP row at all" — "open book" also matches
        // the Waiting row by its DETAIL ("…the note, book or wing it names … ⌥⌘, opens it."), a row
        // above the tabs the search lists whatever the library holds (13n-c U4's standing; whether it
        // too should wait for a first client is RB-14, her call).
        let openBook = SettingsCatalog.title("mcpOpenBook")
        let hiddenLeads = mcpFindings("open book", sharing: false).map { $0.lead }
        let shownLeads = mcpFindings("open book", sharing: true).map { $0.lead }
        #expect(!hiddenLeads.contains(openBook), "the open book lives in the hidden tab: \(hiddenLeads)")
        #expect(shownLeads.contains(openBook), "once the face shows, the search finds it: \(shownLeads)")
        // …and whatever the words, no finding lands on the hidden tab (the search's promise).
        for word in ["open book", "read everything", "share all", "always", "mcp", "ai", "everything is readable"] {
            let landings = mcpFindings(word, sharing: false).map { MCPPaneTab.holding(findingLead: $0.lead) }
            #expect(!landings.contains(MCPPaneTab.shared), "“\(word)” never lands on the hidden tab: \(landings)")
        }
        // Exactly the hidden tab's rows leave — the rows whose finding lands there.
        let all = Set(SettingsSearch.settingsEntries(accountSection: true).map(\.finding.lead))
        let hidden = Set(SettingsSearch.settingsEntries(accountSection: true, mcpSharingFace: false).map(\.finding.lead))
        #expect(all.subtracting(hidden) == [SettingsCatalog.title("mcpOpenBook")])
        // The Connect road and the rest of the pane stay findable.
        for word in ["mcp", "codex", "setup", "client"] {
            #expect(!mcpFindings(word, sharing: false).isEmpty, "“\(word)” still finds the pane")
        }
        let connect = try #require(mcpFindings("setup", sharing: false).first)
        #expect(MCPPaneTab.holding(findingLead: connect.lead) == .connect)
        // The window asks its own pane (the account question's precedent, by source).
        let features = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features")
        let view = try String(contentsOf: features.appendingPathComponent("Settings/AppSettingsView.swift"), encoding: .utf8)
        #expect(view.contains("mcpSharingFace: mcp.map { MCPPane.showsSharingFace($0.snapshot) } ?? true"))
    }

    // MARK: - The pane, mounted

    /// A fresh library's pane: three tabs, on Connect. Her client's first
    /// connection request brings Shared with AI into the row — and the pane
    /// stays where she is (Connect, where she copied its setup).
    @Test func aFirstConnectionRequestBringsTheTabAndThePaneStaysWhereSheIs() async throws {
        try await withFaceWorld { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let (window, host) = Self.mount(MCPPane(door: door), size: NSSize(width: 523, height: 900))
            defer { Self.unmount(window) }
            let fresh = MCPPaneTab.offered(sharing: false).map(\.label)
            await Self.settle(host, until: { Self.tabRow(in: host, labels: fresh) != nil })
            let three = try #require(Self.tabRow(in: host, labels: fresh), "a fresh library's three tabs")
            #expect(three.selectedSegment == 0, "on Connect")

            _ = try session.operations.recordMCPContact(name: "claude-code", version: "2")
            let four = MCPPaneTab.allCases.map(\.label)
            await Self.settle(host, until: { Self.tabRow(in: host, labels: four) != nil })
            let tabs = try #require(Self.tabRow(in: host, labels: four), "the request brings Shared with AI")
            #expect(tabs.selectedSegment == 0, "the pane stays on Connect")
            #expect(Self.tabRow(in: host, labels: fresh) == nil, "one tab row")
            #expect(door.paneTab == nil, "nothing was picked for her")
        }
    }

    // MARK: - Helpers (the tab pins' mount road)

    private static func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<300 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    private static func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private static func mount<V: View>(_ view: V, size: NSSize) -> (NSWindow, NSView) {
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

    private static func unmount(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
        pump()
    }

    private static func settle(_ host: NSView, until condition: () -> Bool, turns: Int = 150) async {
        for _ in 0..<turns {
            host.layoutSubtreeIfNeeded()
            host.window?.displayIfNeeded()
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    private static func segmented(in view: NSView) -> [NSSegmentedControl] {
        var found = (view as? NSSegmentedControl).map { [$0] } ?? []
        for sub in view.subviews { found += segmented(in: sub) }
        return found
    }

    private static func tabRow(in view: NSView, labels expected: [String]) -> NSSegmentedControl? {
        segmented(in: view).first { control in
            (0..<control.segmentCount).map { control.label(forSegment: $0) ?? "" } == expected
        }
    }
}
