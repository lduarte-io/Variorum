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

    // MARK: - The tabs (R-VX184-6 — pure)

    @Test func theTabsAreHerFourInHerOrder() {
        #expect(MCPPaneTab.allCases.map(\.label) == Self.tabLabels, "R-VX184-6, her four, her order")
        #expect(MCPPaneCopy.connectTab == "Connect")
        // The other three are their sections' own titles — the guide's pinned
        // words ("under Activity", "under Waiting") read the same constants.
        #expect(MCPPaneTab.clients.label == MCPPaneCopy.clientsSection)
        #expect(MCPPaneTab.shared.label == MCPPaneCopy.sharedSection)
        #expect(MCPPaneTab.activity.label == MCPPaneCopy.activitySection)
        // Connect's section keeps lesson 2's "Connect a client".
        #expect(MCPPaneCopy.connectSection == "Connect a client")
    }

    /// Her ruling: "it opens on Connect while no client is approved, else on
    /// Clients" — and a tab she picks is remembered for the session.
    @Test func thePaneOpensOnConnectUntilAClientIsApprovedAndKeepsHerPick() {
        #expect(MCPPaneTab.opening(remembered: nil, approvedCount: 0) == .connect)
        #expect(MCPPaneTab.opening(remembered: nil, approvedCount: 1) == .clients)
        #expect(MCPPaneTab.opening(remembered: nil, approvedCount: 7) == .clients)
        for picked in MCPPaneTab.allCases {
            #expect(MCPPaneTab.opening(remembered: picked, approvedCount: 0) == picked, "her pick wins")
            #expect(MCPPaneTab.opening(remembered: picked, approvedCount: 3) == picked, "her pick wins")
        }
        let door = MCPDoor(serverAllowed: false)
        #expect(door.paneTab == nil, "nothing is remembered before she picks")
    }

    /// The pick is the door's (app-lived): a pane mounted after a pick opens
    /// on it, and her press on the tab row is what writes it.
    @Test func herPickedTabIsRememberedAcrossTheSettingsWindow() async throws {
        try await withPaneWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.paneTab = .activity
            do {
                let (window, host) = mount(MCPPane(door: door), size: NSSize(width: 523, height: 700))
                defer { unmount(window) }
                await settle(host, until: { tabRow(in: host) != nil })
                let tabs = try #require(tabRow(in: host), "the tab row renders")
                #expect(tabs.selectedSegment == 3, "the pane opens on the tab she picked (Activity)")
                // Her press — the control's own action (AppKit's road).
                tabs.selectedSegment = 2
                _ = tabs.sendAction(tabs.action, to: tabs.target)
                await settle(host, until: { door.paneTab == .shared })
                #expect(door.paneTab == .shared, "her press is remembered")
            }
            // The Settings window closed and opened again (a fresh pane).
            let (window, host) = mount(MCPPane(door: door), size: NSSize(width: 523, height: 700))
            defer { unmount(window) }
            await settle(host, until: { tabRow(in: host) != nil })
            #expect(tabRow(in: host)?.selectedSegment == 2, "…and the pane opens there again")
        }
    }

    /// The catalog's promise (`AppSettingsView.rowIDsRendered`): a search
    /// never names a row the pane does not show — the open book lives in
    /// Shared with AI, so finding it opens that tab; the server switch and
    /// Waiting sit above the tabs, so they name none.
    @Test func aSearchForTheOpenBookLandsOnItsTab() throws {
        #expect(MCPPaneTab.holding(findingLead: SettingsCatalog.title("mcpOpenBook")) == .shared)
        #expect(MCPPaneTab.holding(findingLead: SettingsCatalog.title("mcpServer")) == nil)
        #expect(MCPPaneTab.holding(findingLead: SettingsCatalog.title("mcpWaiting")) == nil)
        let found = try #require(
            SettingsSearch.findings(matching: "open book", in: SettingsSearch.settingsEntries)
                .first { $0.pane == .mcp && $0.kind == .setting },
            "“open book” finds the MCP pane's row")
        #expect(MCPPaneTab.holding(findingLead: found.lead) == .shared, "the finding's own lead lands the tab")
        #expect(AppSettingsView.rowIDsRendered[.mcp] == ["mcpServer", "mcpWaiting", "mcpOpenBook"])
    }

    // MARK: - One line each (R-VX184-6 — "every explainer cut to one line")

    /// A summary's ideal width in SwiftUI's own `.caption` (measured, not
    /// assumed).
    private func idealWidth(_ text: String) -> CGFloat {
        NSHostingController(rootView: Text(text).font(.caption).lineLimit(1).fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 200)).width
    }

    /// The pane's row room for a line beside its (i): the detail column
    /// (523) less the grouped form's insets and the (i) — taken
    /// conservatively at 420 pt. The grant sheet's: 600 − 2 × 20 − the (i)
    /// → 520 pt.
    static let paneLineRoom: CGFloat = 420
    static let sheetLineRoom: CGFloat = 520

    @Test func everyPaneExplainerIsOneLineWithTheWholeTextBehindItsInfo() {
        var pairs: [(String, String)] = [
            (MCPPaneCopy.enableSummary, MCPPaneCopy.enableBlurb),
            (MCPPaneCopy.clientBoundarySummary, MCPPaneCopy.clientBoundary),
            (MCPPaneCopy.keySummary, MCPPaneCopy.keyLine),
            (MCPPaneCopy.stdioSummary, MCPPaneCopy.stdioLine),
        ]
        for client in MCPSetupClient.allCases { pairs.append((client.summary, client.sentence)) }
        for (line, whole) in pairs {
            #expect(ExplainerLine.opens(line: line, detail: whole), "an (i) holds the rest: \(line)")
            let width = idealWidth(line)
            #expect(width <= Self.paneLineRoom, "one line at the pane's room: \(width) pt — \(line)")
            #expect(line.range(of: #"\bAI\b"#, options: .regularExpression) == nil, "VX-272: \(line)")
            #expect(line.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil,
                    "no shouted word: \(line)")
        }
        // The whole texts stand as they were (their own truth pins read them):
        // her R-VX184-5 words, L1's caveat, the stdio facts.
        #expect(MCPPaneCopy.keyLine.hasSuffix("Running it again replaces the old setup."))
        #expect(MCPPaneCopy.keySummary.hasSuffix("running it again replaces the old setup."), "her words, in the line")
        #expect(MCPPaneCopy.clientBoundary.contains("not programs running as you"))
        #expect(MCPPaneCopy.clientBoundarySummary.contains("not programs running as you"),
                "L1's line never promises more than L1")
        #expect(MCPPaneCopy.stdioLine.contains("standard MCP server") && MCPPaneCopy.stdioLine.contains("one program"))
        // The path moved below the block — the sentence says so.
        #expect(MCPSetupClient.anyClient.sentence.contains("the path below"))
        #expect(!MCPSetupClient.anyClient.sentence.contains("the path above"))
        // A line that is the whole text has no (i) — never a door onto the same words.
        #expect(!ExplainerLine.opens(line: "x", detail: "x"))
        #expect(!ExplainerLine.opens(line: "x", detail: ""))
    }

    /// The grant sheet's HOW MUCH: one line per rung at every scope; the
    /// edit rung's line is the as-built clause (VX-184 round 2) — true at
    /// every scope, never "every change", nothing a note grant can't do.
    @Test func theGrantSheetsRungLineIsOneLineAndTheEditLineStaysAsBuilt() {
        for rung in MCPPaneCopy.offeredRungs {
            for scope in [MCPGrantRule.ScopeKind?.none, .note, .book, .wing] {
                let line = MCPPaneCopy.rungSummary(rung, scope: scope)
                let whole = MCPPaneCopy.rungDetail(rung, scope: scope)
                #expect(idealWidth(line) <= Self.sheetLineRoom, "\(rung) \(String(describing: scope)): \(line)")
                switch rung {
                case .read, .writeNew:
                    #expect(line == whole && !ExplainerLine.opens(line: line, detail: whole),
                            "already one line — no (i)")
                case .suggest, .edit:
                    #expect(ExplainerLine.opens(line: line, detail: whole), "cut — the rest behind the (i)")
                    #expect(whole.hasPrefix(line.components(separatedBy: " \u{2014} ").first ?? line),
                            "the line is the sentence's own lead: \(line)")
                }
            }
        }
        let edit = MCPPaneCopy.rungSummary(.edit)
        #expect(edit == "it can also change, archive and delete what you shared, your own words included")
        #expect(MCPPaneCopy.rungDetail(.edit).hasPrefix(edit), "the edit line is the as-built clause's head")
        for scope in [MCPGrantRule.ScopeKind.note, .book, .wing] {
            let line = MCPPaneCopy.rungSummary(.edit, scope: scope)
            #expect(!line.contains("book") && !line.contains("chapter") && !line.contains("every change"), "\(line)")
        }
        #expect(MCPPaneCopy.rungSummary(.suggest).contains("cannot touch a word you wrote"),
                "the suggest rung's promise stays in its line")
    }

    // MARK: - VX-205 — the copy icon is the ONE copy act's new face

    @Test func theCopyIconIsTheOneCopyActsNewFace() {
        let act = CapabilityRegistry.capability(.mcpCopySetupCommand)
        #expect(act.verb == "Copy setup command", "R-13nb-5, her words — the icon's help and VoiceOver name")
        #expect(act.doors == [.surface], "one act, one door kind")
        #expect(MCPPane.surfaceCapabilities.filter { $0 == .mcpCopySetupCommand }.count == 1,
                "declared once — rendered once (the icon)")
        #expect(MCPSetupCodeBlock.copySymbol == "doc.on.doc", "the standard copy glyph")
        #expect(MCPSetupCodeBlock.copiedSymbol == "checkmark")
    }

    // MARK: - VX-232 — the door's choice and its receipt

    /// Choosing another client clears ITS receipt (it names one client's next
    /// step); choosing the same keeps it; a refusal at the pane's head stays;
    /// a copy makes its client the chosen one.
    @Test func theChoiceAndTheReceiptMoveTogetherOnTheDoor() async throws {
        try await withPaneWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-vx281-choice-\(UUID().uuidString)"))
            defer { pasteboard.releaseGlobally() }
            #expect(door.setupClient == .claudeCode, "Claude Code first, as 13n-b shipped it")
            await door.copySetupCommand(for: .codex, to: pasteboard)
            #expect(door.setupClient == .codex, "the copy's client is the chosen one")
            #expect(door.note == MCPDoor.Note(text: MCPSetupClient.codex.copiedReceipt, place: .connect))
            door.chooseSetupClient(.codex)
            #expect(door.note?.text == MCPSetupClient.codex.copiedReceipt, "the same choice keeps its receipt")
            door.chooseSetupClient(.anyClient)
            #expect(door.setupClient == .anyClient)
            #expect(door.note == nil, "another client's receipt would be a lie under this one")
            door.note = MCPDoor.Note(text: "a refusal", place: .top)
            door.chooseSetupClient(.claudeCode)
            #expect(door.note?.place == .top, "a refusal at the head stays")
        }
    }

    /// **VX-281 ladder R1-3 (RED ON OLD):** a choice made while a copy is in
    /// flight. The copy sets the menu to its client, then waits on the key's
    /// mint (a store write — the writer may be busy with a sync round, an
    /// import, an MCP batch); she picks another client in that window. The
    /// copy that lands must never speak the OLD client's receipt under the NEW
    /// client's menu (VX-232's invariant: the receipt names the shown client),
    /// and the ✓ — which asks the same question of the receipt — never flashes
    /// beside the new client's text. Her press still completes: the copied
    /// client's setup is on the clipboard, exactly as a copy and then a choice.
    @Test func aChoiceMadeWhileACopyIsInFlightNeverLandsTheOldClientsReceipt() async throws {
        try await withPaneWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-vx281-inflight-\(UUID().uuidString)"))
            defer { pasteboard.releaseGlobally() }

            let copy = Task { await door.copySetupCommand(for: .anyClient, to: pasteboard) }
            // The copy's first line ran (the menu on its client); it now waits
            // on the mint — the main actor is ours until we await.
            for _ in 0..<200 where door.setupClient != .anyClient { await Task.yield() }
            #expect(door.setupClient == .anyClient, "non-vacuity: the copy is under way")
            door.chooseSetupClient(.claudeCode)  // her press, mid-copy
            await copy.value

            #expect(door.setupClient == .claudeCode, "her later choice stands")
            #expect(door.note == nil || door.note?.text == door.setupClient.copiedReceipt,
                    "the receipt names the shown client — got “\(door.note?.text ?? "")” under \(door.setupClient.label)")
            #expect(door.note != MCPDoor.Note(text: MCPSetupClient.anyClient.copiedReceipt, place: .connect),
                    "the ✓'s question (the copied client's receipt landed) answers no — it never flashes beside Claude Code")
            #expect(pasteboard.string(forType: .string)?.contains("\"mcpServers\"") == true,
                    "her press completed: the copied client's setup is on the clipboard")
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
