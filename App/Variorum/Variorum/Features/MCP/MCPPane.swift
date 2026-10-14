//
//  MCPPane.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — SETTINGS ▸ MCP, the resting shape (mockups §1–§2 as amended by
//  R-13n-5/10 and R-13nb-5): the server toggle with its status, the
//  CONNECTION REQUESTS (Approve… / Deny), the CLIENTS, SHARED PLACES ("Shared
//  with AI" until 13n-c U2's VX-272), the
//  OPEN BOOK switch, and CONNECT A CLIENT ("Copy setup command"). Each list
//  shows a few rows and an "all N ›" road into the whole list — never one
//  growing pile (R-13n-10). The pane holds no rule: it renders `MCPDoor`'s
//  snapshot and calls its acts; every door renders its verb from the registry
//  (P-1) and is walked (`surfaceCapabilities`). U3 adds the ACTIVITY face —
//  the coarse log's newest lines (a run of one client's same act on one
//  target reads as one line with a count) and its own "all N ›" road.
//
//  13n-c U4 — WAITING (arrival X, the VX-156 brief §5): the asks a client
//  raised past its grant wait here, above Connection requests, newest first,
//  each answered by her press (Answer… opens its sheet); ⌥⌘, opens this pane
//  scrolled to them. Nothing in the app presents an ask by itself.
//
//  VX-281 U1 — IN TABS (R-VX184-6, her pick: "just clicking on it, you
//  wouldn't know without scrolling down where the command to set it up is …
//  as a settings pane, it has a LOT of text"): the server switch and its
//  status on top; Waiting (and Connection requests) above the tabs whenever
//  something waits on her; then Connect · Clients · Shared with AI ·
//  Activity — opening on Connect while no client is approved, else on
//  Clients, her pick remembered for the session (`MCPPaneTab`,
//  `MCPDoor.paneTab`). Every explainer is ONE line with the whole text behind
//  an (i) (`ExplainerLine`). The setup menu is its own file
//  (`MCPSetupMenu.swift` — the code block, VX-205).
//

import SwiftUI
import VariorumCore
import VariorumMCP

/// **VX-281 U1 — R-VX184-6's four tabs, in her order** (Connect · Clients ·
/// Shared with AI · Activity). Pure, so the opening rule and the search's
/// landing are pinned without mounting anything.
nonisolated enum MCPPaneTab: String, CaseIterable, Identifiable, Sendable {
    case connect, clients, shared, activity

    var id: String { rawValue }

    /// The tab's label — Connect's own word; the other three are their
    /// sections' titles (one name per place, said once).
    var label: String {
        switch self {
        case .connect: MCPPaneCopy.connectTab
        case .clients: MCPPaneCopy.clientsSection
        case .shared: MCPPaneCopy.sharedSection
        case .activity: MCPPaneCopy.activitySection
        }
    }

    /// **Where the pane opens** (her ruling): on her pick this session when
    /// she made one (`MCPDoor.paneTab`); else on Connect while no client is
    /// approved — setting one up is all there is to do — and on Clients once
    /// one is.
    static func opening(remembered: MCPPaneTab?, approvedCount: Int) -> MCPPaneTab {
        if let remembered { return remembered }
        return approvedCount > 0 ? .clients : .connect
    }

    /// **The tab a Settings search finding lands on** — the open-book row
    /// lives in Shared with AI, so the search opens it there (the catalog's
    /// promise, `AppSettingsView.rowIDsRendered`: the search never names a
    /// row the pane does not show). nil: the row sits above the tabs (the
    /// server switch, Waiting) or the finding is the pane itself.
    static func holding(findingLead lead: String) -> MCPPaneTab? {
        lead == SettingsCatalog.title("mcpOpenBook") ? .shared : nil
    }
}

struct MCPPane: View {
    let door: MCPDoor
    /// VX-281 U1 (R-VX184-6): the tab on screen — opened by the rule (her
    /// pick this session, else Connect while no client is approved, else
    /// Clients) and remembered on the door whenever she picks.
    @State private var tab: MCPPaneTab
    @State private var granting: MCPGrantOpening?
    @State private var full: FullList?
    /// 13n-c Stage B R1 B3 — the act whose whole member list is open (a
    /// grouped row's "and N more ›").
    @State private var members: MCPSharedGroup?
    /// 13n-c U4 — the ask Waiting's Answer… opened (her press).
    @State private var answering: MCPAskOpening?
    /// 13n-c U2 — the shared rows' distinguishers (the ONE rule over the
    /// offered books — the same label the sheet's picker shows), read once per
    /// change of the shared set, never per render.
    @State private var distinguishers: (books: [String: String], wings: [String: String]) = ([:], [:])
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(door: MCPDoor) {
        self.door = door
        _tab = State(initialValue: MCPPaneTab.opening(
            remembered: door.paneTab, approvedCount: door.snapshot.approvedCount))
    }

    /// P-1: the acts this surface renders (the grant sheet's confirm
    /// included), declared once and walked.
    static let surfaceCapabilities: [CapabilityID] = [
        .mcpApproveClient, .mcpDenyClient, .mcpChangeClientAccess, .mcpRevokeClient,
        // VX-281 U1 (VX-205): `.mcpCopySetupCommand`'s door is the code
        // block's copy icon now — the act's new face, its verb the icon's
        // help and accessibility name (`MCPSetupCodeBlock`).
        .mcpRevokeGrant, .mcpCopySetupCommand, .mcpGrantAccess,
        // 13n-c U4: Waiting's Answer… (arrival X — the brief §5).
        .mcpOpenAsk,
        // 13n-c UX walk W-UX-19: every Shared-with-AI row's Change… (a new
        // renderer is a new line).
        .mcpChangeGrant,
    ]

    /// 13n-c U4 — where ⌥⌘, lands the pane when an ask waits.
    static let waitingAnchor = "mcp-waiting"

    /// ⌥⌘,'s scroll, decided purely: a fresh request with something waiting.
    nonisolated static func scrollsToWaiting(request: Int, scrolled: Int, waitingCount: Int) -> Bool {
        request > scrolled && waitingCount > 0
    }

    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    private static func verb(_ id: CapabilityID) -> String { CapabilityRegistry.capability(id).verb }

    enum FullList: String, Identifiable {
        case waiting, requests, clients, shared, activity
        var id: String { rawValue }
    }

    var body: some View {
        ScrollViewReader { proxy in
            form
                .onAppear { landAtWaiting(proxy) }
                .onChange(of: door.settingsRequest) { _, _ in landAtWaiting(proxy) }
                // UXR1-6: Waiting's caption leaves with the pane — it never
                // greets her over an empty Waiting when she comes back.
                .onDisappear { door.letWaitingNoteGo() }
        }
    }

    /// ⌥⌘, — scrolled to Waiting when an ask waits (each request once).
    /// VX-281 U1: Waiting sits ABOVE the tabs (R-VX184-6), so whichever tab
    /// is on screen, the landing is the same.
    private func landAtWaiting(_ proxy: ScrollViewProxy) {
        let request = door.settingsRequest
        guard request > door.settingsRequestScrolled else { return }
        let scrolls = Self.scrollsToWaiting(
            request: request, scrolled: door.settingsRequestScrolled, waitingCount: door.waiting.count)
        door.settingsRequestScrolled = request
        guard scrolls else { return }
        Task { @MainActor in
            await Task.yield()
            withAnimation { proxy.scrollTo(Self.waitingAnchor, anchor: .top) }
        }
    }

    /// **The pane, top to bottom (VX-281 U1 — R-VX184-6, her pick):** the
    /// server switch and its status; WAITING whenever an ask waits;
    /// CONNECTION REQUESTS whenever one waits (beside Waiting — both wait on
    /// her answer; PROVISIONAL P-VX281-U1-1); then the tab row heading the
    /// chosen tab — Connect · Clients · Shared with AI · Activity. Every
    /// explainer is one line with the whole text behind its (i).
    private var form: some View {
        Form {
            Section {
                Toggle(SettingsCatalog.title("mcpServer"), isOn: Binding(
                    get: { door.snapshot.enabled },
                    set: { door.setEnabled($0) }))
                Text(MCPPaneCopy.status(door.serverState))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                ExplainerLine(line: MCPPaneCopy.enableSummary, detail: MCPPaneCopy.enableBlurb)
                // A refusal from any act lands where she is looking first
                // (the walk's second finding: a caption at the form's foot
                // sat below the fold).
                if let note = door.note, note.place == .top {
                    caption(note.text)
                }
            }
            // 13n-c U4 — WAITING (arrival X; mockup §4/§5): the asks a client
            // raised past its grant, newest first, each answered by HER press
            // (Answer… opens its sheet here). Above the tabs (R-VX184-6):
            // whatever tab she is on, what waits on her is in sight.
            // 13n-c UX walk W-UX-8: Waiting also stays while its own caption
            // speaks — a press on its only row whose place is gone says so
            // HERE, where she pressed, not at the pane's head.
            if !door.waiting.isEmpty || door.note?.place == .waiting {
                Section(MCPPaneCopy.waitingSection) {
                    if let note = door.note, note.place == .waiting {
                        caption(note.text)
                    }
                    ForEach(door.waiting.prefix(MCPDoor.waitingCap)) { entry in waitingRow(entry) }
                    allRoad(door.waiting.count, shown: min(door.waiting.count, MCPDoor.waitingCap), .waiting)
                }
                .id(Self.waitingAnchor)
                // Stage B R2-1 (b): Waiting is where a dead note's ask can
                // still show — its render re-validates every waiting ask in
                // one batch (silent; a gone one leaves the list).
                .task(id: door.waiting.map(\.id)) {
                    await door.revalidateAsks()
                    distinguishers = await door.placeDistinguishers()
                }
            }
            // VX-281 U1 (PROVISIONAL P-VX281-U1-1): a connection request waits
            // on her answer as an ask does, so it sits above the tabs too — a
            // client set up from Connect asks to connect right here, never
            // hidden behind Clients.
            if door.snapshot.pendingCount > 0 {
                Section(MCPPaneCopy.requestsSection) {
                    ForEach(door.snapshot.pending) { request in requestRow(request) }
                    allRoad(door.snapshot.pendingCount, shown: door.snapshot.pending.count, .requests)
                }
            }
            switch tab {
            case .connect: connectTab
            case .clients: clientsTab
            case .shared: sharedTab
            case .activity: activityTab
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .sheet(item: $granting) { opening in
            MCPGrantSheet(door: door, opening: opening) { granting = nil }
        }
        .sheet(item: $full) { list in
            MCPFullListSheet(door: door, list: list, tokens: tokens) { full = nil } grant: { target in
                full = nil
                granting = target
            } answer: { id in
                full = nil
                answering = door.opening(id)
            }
        }
        // 13n-c U4: the ask Waiting's Answer… opened (closes by itself once
        // the ask is answered anywhere).
        // Stage B R2-1 (a): a press here that finds the place gone says so in
        // the pane's own caption (Settings has no status seam).
        .mcpAskSheet(door: door, opening: $answering, seam: .pane)
        // 13n-c Stage B R1 B3: a grouped row's "and N more ›".
        .sheet(item: $members) { group in
            // W-UX-19: a member's Change… closes the list and opens THE
            // replace sheet on that one grant here.
            MCPSharedMembersSheet(door: door, group: group, tokens: tokens, done: { members = nil }) { opening in
                members = nil
                granting = opening
            }
        }
    }

    // MARK: - The tabs (VX-281 U1 — R-VX184-6)

    /// The tab row — her four, one segmented control, centred over the tab's
    /// content as its header. A pick is remembered for the session.
    private var tabRow: some View {
        HStack {
            Spacer(minLength: 0)
            Picker(SettingsPane.mcp.title, selection: Binding(
                get: { tab },
                set: { picked in
                    tab = picked
                    door.paneTab = picked
                })) {
                ForEach(MCPPaneTab.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            // P-8: a segmented control's labels are one line.
            .lineLimit(1)
            .fixedSize()
            Spacer(minLength: 0)
        }
        .padding(.bottom, 4)
    }

    /// CONNECT — the setup first (her "you wouldn't know without scrolling
    /// down where the command to set it up is"): the code block, its lines.
    /// Its section keeps "Connect a client" (the field guide's lesson 2).
    @ViewBuilder private var connectTab: some View {
        Section {
            // VX-232: the menu's choice is the door's (`MCPDoor.setupClient`).
            MCPSetupMenu(
                door: door,
                client: Binding(get: { door.setupClient }, set: { door.chooseSetupClient($0) }),
                tokens: tokens)
        } header: {
            VStack(alignment: .leading, spacing: 6) {
                tabRow
                Text(MCPPaneCopy.connectSection)
            }
        }
    }

    /// CLIENTS — every decided client (Change… / Deny…), its "all N ›", and
    /// L1's one line (the A-4 boundary, whole behind its (i)).
    @ViewBuilder private var clientsTab: some View {
        Section {
            if door.snapshot.clients.isEmpty {
                quiet(MCPPaneCopy.noClients)
            } else {
                ForEach(door.snapshot.clients) { row in clientRow(row) }
                allRoad(door.snapshot.clientCount, shown: door.snapshot.clients.count, .clients)
            }
            // 13n-c U2 — L1 (the VX-156 brief §12; mockup §11): the A-4
            // boundary, said where clients are listed (VX-168: true-er).
            ExplainerLine(line: MCPPaneCopy.clientBoundarySummary, detail: MCPPaneCopy.clientBoundary)
        } header: {
            tabRow
        }
    }

    /// SHARED WITH AI — one row per act (Change… · Revoke), its "all N ›",
    /// then the Open book switch (the one share-everything control).
    @ViewBuilder private var sharedTab: some View {
        Section {
            if door.snapshot.sharedGroups.isEmpty {
                quiet(MCPPaneCopy.nothingShared)
            } else {
                // 13n-c U3 (VX-156 item 2; mockup §2): ONE ROW PER ACT —
                // a bulk share's notes read as "3 notes", Revoke covering
                // every member.
                ForEach(door.snapshot.sharedGroups) { group in sharedGroup(group) }
                allRoad(door.snapshot.sharedCount, shown: door.snapshot.sharedGroups.count, .shared)
            }
        } header: {
            tabRow
        }
        .task(id: door.snapshot.sharedGroups.map(\.id)) { distinguishers = await door.placeDistinguishers() }
        Section(MCPPaneCopy.openBookSection) {
            Toggle(SettingsCatalog.title("mcpOpenBook"), isOn: Binding(
                get: { door.snapshot.openBook },
                set: { door.setOpenBook($0) }))
            quiet(MCPPaneCopy.openBookDetail)
        }
    }

    /// ACTIVITY — the coarse log's newest lines and its "all N ›".
    @ViewBuilder private var activityTab: some View {
        Section {
            if door.snapshot.activity.isEmpty {
                quiet(MCPPaneCopy.noActivity)
            } else {
                ForEach(door.snapshot.activity) { line in MCPActivityRowView(line: line) }
                allRoad(door.snapshot.activityCount, shown: door.snapshot.activity.map(\.count).reduce(0, +), .activity)
            }
        } header: {
            tabRow
        }
    }

    // MARK: - Waiting (13n-c U4)

    private func waitingRow(_ entry: MCPAskQueue.Entry) -> some View {
        MCPWaitingRowView(
            entry: entry, distinguisher: Self.distinguisher(entry.ask, distinguishers), tokens: tokens
        ) {
            answering = entry.opening
        }
    }

    /// An ask's distinguisher — the ONE rule's answer for its book or wing
    /// (a note ask wears none, as a note row does).
    static func distinguisher(
        _ ask: MCPAsk, _ labels: (books: [String: String], wings: [String: String])
    ) -> String? {
        switch ask.scopeKind {
        case .note: nil
        case .book: labels.books[ask.scopeID]
        case .wing: labels.wings[ask.scopeID]
        }
    }

    // MARK: - Rows

    private func requestRow(_ request: MCPClient) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(MCPPaneCopy.requestTitle(request.name))
                .font(.callout.weight(.semibold))
                .lineLimit(1)
            quiet(MCPPaneCopy.requestDetail(firstSeen: Self.relative(request.firstSeenAt)))
            HStack(spacing: 10) {
                Button(Self.verb(.mcpApproveClient)) {
                    granting = MCPGrantOpening(client: request, approving: true)
                }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                Button(Self.verb(.mcpDenyClient)) { door.deny(request.id) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 2)
    }

    private func clientRow(_ row: MCPDoor.ClientRow) -> some View {
        MCPClientRow(row: row, connected: door.connected.contains(row.client.name), tokens: tokens) {
            granting = MCPGrantOpening(client: row.client, approving: row.client.state != .approved)
        } revoke: {
            door.deny(row.client.id)
        }
    }

    @ViewBuilder
    private func sharedGroup(_ group: MCPSharedGroup) -> some View {
        if group.isGroup {
            // UXR1-2: Change… only where something stands (`MCPChangeOffer`).
            MCPSharedGroupView(
                group: group, tokens: tokens, showMembers: { members = group },
                change: MCPChangeOffer.offers(group)
                    ? { Task { granting = await door.changeOpening(act: group) } } : nil
            ) {
                door.revoke(grantIDs: group.grantIDs)
            }
        } else {
            MCPSharedRowView(
                row: group.lead, distinguisher: Self.distinguisher(group.lead, distinguishers), tokens: tokens,
                change: MCPChangeOffer.offers(group)
                    ? { Task { granting = await door.changeOpening(group.lead) } } : nil
            ) { door.revoke(grantID: group.lead.grant.id) }
        }
    }

    /// A shared row's distinguisher — the ONE rule's answer for its book or
    /// wing (a note row wears none — its picker told it apart by snippet).
    static func distinguisher(
        _ row: MCPSharedRow, _ labels: (books: [String: String], wings: [String: String])
    ) -> String? {
        switch row.grant.scopeKind {
        case .note: nil
        case .book: labels.books[row.grant.scopeID]
        case .wing: labels.wings[row.grant.scopeID]
        }
    }

    @ViewBuilder
    private func allRoad(_ count: Int, shown: Int, _ list: FullList) -> some View {
        if count > shown {
            Button(MCPPaneCopy.allRoad(count)) { full = list }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func quiet(_ text: String, lines: Int = 3) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(lines)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// "a minute ago", "yesterday", … from a stored ISO stamp.
    static func relative(_ stamp: String) -> String {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return stamp }
        return relative(date)
    }

    /// 13n-c U4 — the same words from a date (Waiting's age).
    static func relative(_ date: Date, now: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: now)
    }
}

/// **One waiting ask in Settings ▸ MCP ▸ Waiting** (13n-c U4; mockup §4's
/// "claude-code asks to suggest in “the lightning thief” · 2 minutes ago ·
/// Answer…"): the ask's own title (its place wearing the one rule's
/// distinguisher), its age, and Answer… — which opens its sheet.
struct MCPWaitingRowView: View {
    let entry: MCPAskQueue.Entry
    var distinguisher: String? = nil
    let tokens: VoiceTokens
    let answer: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(MCPAskCopy.title(entry.ask, distinguisher: distinguisher))
                    .font(.callout.weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                // The age reads live (every half-minute — never per frame).
                SwiftUI.TimelineView(.periodic(from: .now, by: 30)) { context in
                    Text(MCPPane.relative(entry.askedAt, now: context.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Button(CapabilityRegistry.capability(.mcpOpenAsk).verb, action: answer)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
    }
}

/// One client in the CLIENTS list (and its "all N" sheet).
struct MCPClientRow: View {
    let row: MCPDoor.ClientRow
    let connected: Bool
    let tokens: VoiceTokens
    let change: () -> Void
    let revoke: () -> Void
    /// 13n-c UX walk W-UX-4: Deny… ASKS first, naming what it takes — the
    /// client shut out and every grant it holds — in both hosts (the pane and
    /// its "all N ›" sheet render this one row).
    @State private var confirmingDeny = false

    private var detail: String {
        var parts: [String] = []
        parts.append(connected ? MCPPaneCopy.connectedNow
                     : MCPPaneCopy.lastSeen(MCPPane.relative(row.client.lastSeenAt)))
        switch row.client.state {
        case .denied: parts.append(MCPPaneCopy.deniedState)
        case .approved:
            // 13n-c U2 (R2-3): an inert grant is said as inert, never shared.
            parts.append(row.liveGrantCount == 0 && row.inertGrantCount == 0
                ? MCPPaneCopy.noAccess
                : MCPPaneCopy.reads(row.liveGrantCount, inert: row.inertGrantCount))
        case .pending: break
        }
        return parts.joined(separator: " \u{00B7} ")
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.client.name)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if row.client.state == .approved {
                Button(CapabilityRegistry.capability(.mcpChangeClientAccess).verb, action: change)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Button(CapabilityRegistry.capability(.mcpRevokeClient).verb) { confirmingDeny = true }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            } else {
                Button(CapabilityRegistry.capability(.mcpApproveClient).verb, action: change)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
        }
        .alert(MCPPaneCopy.denyClientTitle(row.client.name), isPresented: $confirmingDeny) {
            Button(MCPPaneCopy.denyClientConfirm, role: .destructive, action: revoke)
            Button(MCPPaneCopy.cancel, role: .cancel) {}
        } message: {
            Text(MCPPaneCopy.denyClientDetail(grants: row.liveGrantCount + row.inertGrantCount))
        }
    }
}

/// **Where Change… is offered** (the 13n-c UX-fix ladder's UXR1-2): only
/// where the replace sheet can open on something that stands. No delete
/// revokes a grant, so a live grant can name a deleted note, book or wing (its
/// row says "(gone)"); Change… there opened the sheet on nothing — a dead
/// wing's read as Home with a confirm that could only refuse, a deleted
/// book's said the fenced-reason sentence, an act whose notes were all gone
/// read "These 0 notes". Such a row keeps Revoke only. (An INERT row — its
/// target fenced since — still stands, and still offers: the sheet opens on
/// its current facts, W-UX-19.)
nonisolated enum MCPChangeOffer {
    /// One grant's row: while its target stands (`targetTitle` nil = gone).
    static func offers(_ row: MCPSharedRow) -> Bool { row.targetTitle != nil }

    /// An act's row: while at least one member's target stands — counted
    /// over EVERY member (`goneCount`), not only the titled few; a single
    /// grant's row by its own target.
    static func offers(_ group: MCPSharedGroup) -> Bool {
        group.isGroup ? group.goneCount < group.memberCount : offers(group.lead)
    }
}

/// One live grant in SHARED PLACES (13n-c U2: its distinguisher when its
/// name collides — mockup §1b's pane rows; INERT said when its target is
/// fenced since — R2-3, P-13nb-U2-3).
struct MCPSharedRowView: View {
    let row: MCPSharedRow
    var distinguisher: String? = nil
    let tokens: VoiceTokens
    /// 13n-c UX walk W-UX-19: Change… beside Revoke (the replace sheet).
    var change: (() -> Void)? = nil
    let revoke: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(row.targetTitle ?? MCPPaneCopy.missingTarget)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(row.inertFence == nil ? .primary : .secondary)
                        .lineLimit(1)
                    Text(MCPPaneCopy.kindChip(row.grant.scopeKind))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(tokens.seam, lineWidth: 1))
                    if let distinguisher {
                        Text(distinguisher)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
                Text(MCPPaneCopy.sharedDetail(client: row.clientName, rung: row.grant.rung, duration: row.grant.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let fence = row.inertFence {
                    Text(MCPPaneCopy.inertDetail(fence, kind: row.grant.scopeKind))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            if let change {
                Button(CapabilityRegistry.capability(.mcpChangeGrant).verb, action: change)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
            Button(CapabilityRegistry.capability(.mcpRevokeGrant).verb, action: revoke)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
    }
}

/// **One ACT in SHARED PLACES** (13n-c U3 — VX-156 item 2; mockup §2's "3
/// notes · claude-code · read · while connected", the members named under
/// it): the grants one bulk share minted on one stamp, and ONE Revoke that
/// covers them all.
struct MCPSharedGroupView: View {
    let group: MCPSharedGroup
    let tokens: VoiceTokens
    /// 13n-c Stage B R1 B3: the road to every member (the host presents the
    /// act's member list).
    var showMembers: () -> Void = {}
    /// 13n-c UX walk W-UX-19: the act's Change… — covers its grants as its
    /// one Revoke does.
    var change: (() -> Void)? = nil
    let revoke: () -> Void

    /// How many members the row does not name — the "and N more ›" road's N
    /// (zero ⇒ no road: every member is already named).
    nonisolated static func unnamedMembers(_ group: MCPSharedGroup) -> Int {
        max(group.memberCount - group.rows.count, 0)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(MCPPaneCopy.groupTitle(group.memberCount))
                        .font(.callout.weight(.semibold))
                        .lineLimit(1)
                    Text(MCPPaneCopy.groupChip)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(tokens.seam, lineWidth: 1))
                }
                Text(MCPPaneCopy.sharedDetail(
                    client: group.lead.clientName, rung: group.lead.grant.rung,
                    duration: group.lead.grant.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(MCPPaneCopy.groupMembers(group.rows.map(\.targetTitle)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                // Stage B R1 B3 (R-13n-10): the members past the first few are
                // a ROAD, never a phrase that names nothing.
                let unnamed = Self.unnamedMembers(group)
                if unnamed > 0 {
                    Button(MCPPaneCopy.groupMoreRoad(unnamed), action: showMembers)
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if group.inertCount > 0 {
                    Text(MCPPaneCopy.groupInert(group.inertCount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            if let change {
                Button(CapabilityRegistry.capability(.mcpChangeGrant).verb, action: change)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
            Button(CapabilityRegistry.capability(.mcpRevokeGrant).verb, action: revoke)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
    }
}

/// **ONE ACT's MEMBERS, every one named** (13n-c Stage B R1 B3 — R-13n-10's
/// "every 'all N ›' a real road"; lesson 6's "lists … everything shared"): the
/// road behind a grouped row's "and N more ›". One bounded read of THAT act
/// (`Queries.mcpSharedActMembers` — ∝ the act, never the corpus); each member
/// with its own Revoke (the 13n-b row's idiom — a member can be taken back
/// alone; the row's Revoke still covers them all). Part of the pane's surface
/// (`MCPPane.surfaceCapabilities` declares `.mcpRevokeGrant`).
struct MCPSharedMembersSheet: View {
    let door: MCPDoor
    let group: MCPSharedGroup
    let tokens: VoiceTokens
    let done: () -> Void
    /// 13n-c UX walk W-UX-19: a member's Change… — THE replace sheet on that
    /// one grant (the act's own row's Change… covers them all).
    var change: (MCPGrantOpening) -> Void = { _ in }
    @State private var rows: [MCPSharedRow] = []
    /// 13n-c Stage B R2-2 (B8's class — not loaded is not nothing left): the
    /// act's members have been read at least once.
    @State private var loaded = false

    /// The count the title says: the act's own until the list has loaded,
    /// then exactly what the list shows (never a stale count above it).
    nonisolated static func shownCount(loaded: Bool, rows: Int, memberCount: Int) -> Int {
        loaded ? rows : memberCount
    }

    /// A load that comes back EMPTY — every member revoked (here or anywhere)
    /// — leaves nothing to list, so the sheet closes.
    nonisolated static func closesAfterLoad(_ rows: [MCPSharedRow]) -> Bool { rows.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(MCPPaneCopy.membersTitle(
                Self.shownCount(loaded: loaded, rows: rows.count, memberCount: group.memberCount)))
                .font(.headline)
                .lineLimit(1)
            Text(MCPPaneCopy.sharedDetail(
                client: group.lead.clientName, rung: group.lead.grant.rung, duration: group.lead.grant.duration))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            List {
                ForEach(rows) { row in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.targetTitle ?? MCPPaneCopy.missingTarget)
                                .font(.callout)
                                .foregroundStyle(row.inertFence == nil ? .primary : .secondary)
                                .lineLimit(1)
                            if let fence = row.inertFence {
                                Text(MCPPaneCopy.inertDetail(fence, kind: row.grant.scopeKind))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .italic()
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer(minLength: 0)
                        // UXR1-2: a member whose note is gone keeps Revoke only.
                        if MCPChangeOffer.offers(row) {
                            Button(CapabilityRegistry.capability(.mcpChangeGrant).verb) {
                                Task { if let opening = await door.changeOpening(row) { change(opening) } }
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        }
                        Button(CapabilityRegistry.capability(.mcpRevokeGrant).verb) {
                            door.revoke(grantID: row.grant.id)
                        }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    }
                }
            }
            .frame(minHeight: 240)
            HStack {
                Spacer()
                Button(MCPPaneCopy.doneButton, action: done)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(18)
        .frame(width: 480)
        .task { await load() }
        // A member revoked here (or anywhere) leaves the list: it follows the
        // store, never the act.
        .onChange(of: door.snapshot) { _, _ in
            Task { await load() }
        }
    }

    /// One read of the act's members (R2-2): a failed read changes nothing; a
    /// read that lands sets the list, marks it loaded, and closes the sheet
    /// when nothing is left to list.
    private func load() async {
        guard let fresh = await door.sharedMembers(group.grantIDs) else { return }
        rows = fresh
        loaded = true
        if Self.closesAfterLoad(fresh) { done() }
    }
}

/// One line of ACTIVITY (U3): what a client did, and when.
struct MCPActivityRowView: View {
    let line: MCPActivityFace.Line

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(MCPPaneCopy.activityLine(line))
                .font(.callout)
                .foregroundStyle(line.allowed ? .primary : .secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Text(MCPPane.relative(line.at))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

/// THE "ALL N ›" ROAD (R-13n-10): a whole list in its own scrollable sheet.
struct MCPFullListSheet: View {
    let door: MCPDoor
    let list: MCPPane.FullList
    let tokens: VoiceTokens
    let done: () -> Void
    let grant: (MCPGrantOpening) -> Void
    /// 13n-c U4: Waiting's Answer… (opens the ask's sheet in the pane).
    var answer: (String) -> Void = { _ in }
    @State private var requests: [MCPClient] = []
    @State private var clients: [MCPDoor.ClientRow] = []
    @State private var shared: [MCPSharedGroup] = []
    @State private var activity: [MCPActivityFace.Line] = []
    @State private var distinguishers: (books: [String: String], wings: [String: String]) = ([:], [:])
    /// 13n-c Stage B R1 B3 — an act's member list, opened over this sheet.
    @State private var members: MCPSharedGroup?

    private var title: String {
        switch list {
        case .waiting: MCPPaneCopy.waitingSection
        case .requests: MCPPaneCopy.requestsSection
        case .clients: MCPPaneCopy.clientsSection
        case .shared: MCPPaneCopy.sharedSection
        case .activity: MCPPaneCopy.activitySection
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
            List {
                switch list {
                case .waiting:
                    // Live from the queue (in memory — no read): newest first.
                    ForEach(door.waiting) { entry in
                        MCPWaitingRowView(
                            entry: entry, distinguisher: MCPPane.distinguisher(entry.ask, distinguishers),
                            tokens: tokens
                        ) {
                            answer(entry.id)
                        }
                    }
                case .requests:
                    ForEach(requests) { request in
                        HStack {
                            Text(MCPPaneCopy.requestTitle(request.name)).lineLimit(1)
                            Spacer(minLength: 0)
                            Button(CapabilityRegistry.capability(.mcpApproveClient).verb) {
                                grant(MCPGrantOpening(client: request, approving: true))
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            Button(CapabilityRegistry.capability(.mcpDenyClient).verb) {
                                door.deny(request.id)
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        }
                    }
                case .clients:
                    ForEach(clients) { row in
                        MCPClientRow(row: row, connected: door.connected.contains(row.client.name), tokens: tokens) {
                            grant(MCPGrantOpening(client: row.client, approving: row.client.state != .approved))
                        } revoke: {
                            door.deny(row.client.id)
                        }
                    }
                case .shared:
                    // 13n-c U3: one row per act here too.
                    ForEach(shared) { group in
                        if group.isGroup {
                            MCPSharedGroupView(
                                group: group, tokens: tokens, showMembers: { members = group },
                                change: MCPChangeOffer.offers(group)
                                    ? { Task { if let opening = await door.changeOpening(act: group) { grant(opening) } } }
                                    : nil
                            ) {
                                door.revoke(grantIDs: group.grantIDs)
                            }
                        } else {
                            MCPSharedRowView(
                                row: group.lead, distinguisher: MCPPane.distinguisher(group.lead, distinguishers),
                                tokens: tokens,
                                change: MCPChangeOffer.offers(group)
                                    ? { Task { if let opening = await door.changeOpening(group.lead) { grant(opening) } } }
                                    : nil
                            ) {
                                door.revoke(grantID: group.lead.grant.id)
                            }
                        }
                    }
                case .activity:
                    ForEach(activity) { line in MCPActivityRowView(line: line) }
                }
            }
            .frame(minHeight: 280)
            HStack {
                Spacer()
                Button(MCPPaneCopy.doneButton, action: done)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(18)
        .frame(width: 520)
        .task { await reload() }
        // Every act lands as rows; the list follows the store, never the act.
        .onChange(of: door.snapshot) { _, _ in Task { await reload() } }
        // Stage B R1 B3: a grouped row's "and N more ›", over this sheet.
        .sheet(item: $members) { group in
            MCPSharedMembersSheet(door: door, group: group, tokens: tokens, done: { members = nil }) { opening in
                members = nil
                grant(opening)
            }
        }
    }

    private func reload() async {
        switch list {
        case .waiting:
            // Stage B R2-1 (b): the whole Waiting list re-validates as it
            // renders, as the pane's section does.
            await door.revalidateAsks()
            distinguishers = await door.placeDistinguishers()
        case .requests: requests = await door.allPending()
        case .clients: clients = await door.allClients()
        case .shared:
            shared = await door.allSharedGroups()
            distinguishers = await door.placeDistinguishers()
        case .activity: activity = await door.allActivity()
        }
    }
}
