//
//  MCPPane.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — SETTINGS ▸ MCP, the resting shape (mockups §1–§2 as amended by
//  R-13n-5/10 and R-13nb-5): the server toggle with its status, the
//  CONNECTION REQUESTS (Approve… / Deny), the CLIENTS, SHARED WITH AI, the
//  OPEN BOOK switch, and CONNECT A CLIENT ("Copy setup command"). Each list
//  shows a few rows and an "all N ›" road into the whole list — never one
//  growing pile (R-13n-10). The pane holds no rule: it renders `MCPDoor`'s
//  snapshot and calls its acts; every door renders its verb from the registry
//  (P-1) and is walked (`surfaceCapabilities`). The ACTIVITY face is U3's —
//  the log is already being written.
//

import SwiftUI
import VariorumCore

struct MCPPane: View {
    let door: MCPDoor
    @State private var granting: GrantTarget?
    @State private var full: FullList?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// P-1: the acts this surface renders (the grant sheet's confirm
    /// included), declared once and walked.
    static let surfaceCapabilities: [CapabilityID] = [
        .mcpApproveClient, .mcpDenyClient, .mcpChangeClientAccess, .mcpRevokeClient,
        .mcpRevokeGrant, .mcpCopySetupCommand, .mcpGrantAccess,
    ]

    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    private static func verb(_ id: CapabilityID) -> String { CapabilityRegistry.capability(id).verb }

    /// Who the grant sheet is for, and whether it is a first approval.
    struct GrantTarget: Identifiable {
        var id: String { client.id }
        let client: MCPClient
        let approving: Bool
        /// Connected right now — "while connected" is offered only then.
        var connected = false
    }

    enum FullList: String, Identifiable {
        case requests, clients, shared
        var id: String { rawValue }
    }

    var body: some View {
        Form {
            Section {
                Toggle(SettingsCatalog.title("mcpServer"), isOn: Binding(
                    get: { door.snapshot.enabled },
                    set: { door.setEnabled($0) }))
                Text(MCPPaneCopy.status(door.serverState))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(MCPPaneCopy.enableBlurb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                // A refusal from any act lands where she is looking first
                // (the walk's second finding: a caption at the form's foot
                // sat below the fold).
                if let note = door.note, note.place == .top {
                    caption(note.text)
                }
            }
            if door.snapshot.pendingCount > 0 {
                Section(MCPPaneCopy.requestsSection) {
                    ForEach(door.snapshot.pending) { request in requestRow(request) }
                    allRoad(door.snapshot.pendingCount, shown: door.snapshot.pending.count, .requests)
                }
            }
            Section(MCPPaneCopy.clientsSection) {
                if door.snapshot.clients.isEmpty {
                    quiet(MCPPaneCopy.noClients)
                } else {
                    ForEach(door.snapshot.clients) { row in clientRow(row) }
                    allRoad(door.snapshot.clientCount, shown: door.snapshot.clients.count, .clients)
                }
            }
            Section(MCPPaneCopy.sharedSection) {
                if door.snapshot.shared.isEmpty {
                    quiet(MCPPaneCopy.nothingShared)
                } else {
                    ForEach(door.snapshot.shared) { row in sharedRow(row) }
                    allRoad(door.snapshot.sharedCount, shown: door.snapshot.shared.count, .shared)
                }
            }
            Section(MCPPaneCopy.openBookSection) {
                Toggle(SettingsCatalog.title("mcpOpenBook"), isOn: Binding(
                    get: { door.snapshot.openBook },
                    set: { door.setOpenBook($0) }))
                quiet(MCPPaneCopy.openBookDetail)
            }
            Section(MCPPaneCopy.connectSection) {
                Text(MCPPaneCopy.connectSentence)
                    .font(.callout)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button(Self.verb(.mcpCopySetupCommand)) { door.copySetupCommand() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    Spacer(minLength: 0)
                }
                if let note = door.note, note.place == .connect {
                    caption(note.text)
                }
                // Shown WHOLE, verbatim and selectable (R-13nb-5) — a Debug
                // build's DerivedData path runs four lines at this width (the
                // walk's first finding: three lines clipped it).
                Text(verbatim: door.setupCommand)
                    .font(.system(size: 11, design: .monospaced))
                    .textSelection(.enabled)
                    .lineLimit(10)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .sheet(item: $granting) { target in
            MCPGrantSheet(door: door, target: target) { granting = nil }
        }
        .sheet(item: $full) { list in
            MCPFullListSheet(door: door, list: list, tokens: tokens) { full = nil } grant: { target in
                full = nil
                granting = target
            }
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
                    granting = GrantTarget(
                        client: request, approving: true, connected: door.connected.contains(request.name))
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
            granting = GrantTarget(
                client: row.client, approving: row.client.state != .approved,
                connected: door.connected.contains(row.client.name))
        } revoke: {
            door.deny(row.client.id)
        }
    }

    private func sharedRow(_ row: MCPSharedRow) -> some View {
        MCPSharedRowView(row: row, tokens: tokens) { door.revoke(grantID: row.grant.id) }
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

    private func quiet(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// "a minute ago", "yesterday", … from a stored ISO stamp.
    static func relative(_ stamp: String) -> String {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return stamp }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// One client in the CLIENTS list (and its "all N" sheet).
struct MCPClientRow: View {
    let row: MCPDoor.ClientRow
    let connected: Bool
    let tokens: VoiceTokens
    let change: () -> Void
    let revoke: () -> Void

    private var detail: String {
        var parts: [String] = []
        parts.append(connected ? MCPPaneCopy.connectedNow
                     : MCPPaneCopy.lastSeen(MCPPane.relative(row.client.lastSeenAt)))
        switch row.client.state {
        case .denied: parts.append(MCPPaneCopy.deniedState)
        case .approved:
            parts.append(row.liveGrantCount == 0 ? MCPPaneCopy.noAccess : MCPPaneCopy.reads(row.liveGrantCount))
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
                Button(CapabilityRegistry.capability(.mcpRevokeClient).verb, action: revoke)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            } else {
                Button(CapabilityRegistry.capability(.mcpApproveClient).verb, action: change)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
        }
    }
}

/// One live grant in SHARED WITH AI.
struct MCPSharedRowView: View {
    let row: MCPSharedRow
    let tokens: VoiceTokens
    let revoke: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(row.targetTitle ?? MCPPaneCopy.missingTarget)
                        .font(.callout.weight(.semibold))
                        .lineLimit(1)
                    Text(MCPPaneCopy.kindChip(row.grant.scopeKind))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 5)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(tokens.seam, lineWidth: 1))
                }
                Text(MCPPaneCopy.sharedDetail(client: row.clientName, rung: row.grant.rung, duration: row.grant.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Button(CapabilityRegistry.capability(.mcpRevokeGrant).verb, action: revoke)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
    }
}

/// THE "ALL N ›" ROAD (R-13n-10): a whole list in its own scrollable sheet.
struct MCPFullListSheet: View {
    let door: MCPDoor
    let list: MCPPane.FullList
    let tokens: VoiceTokens
    let done: () -> Void
    let grant: (MCPPane.GrantTarget) -> Void
    @State private var requests: [MCPClient] = []
    @State private var clients: [MCPDoor.ClientRow] = []
    @State private var shared: [MCPSharedRow] = []

    private var title: String {
        switch list {
        case .requests: MCPPaneCopy.requestsSection
        case .clients: MCPPaneCopy.clientsSection
        case .shared: MCPPaneCopy.sharedSection
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
            List {
                switch list {
                case .requests:
                    ForEach(requests) { request in
                        HStack {
                            Text(MCPPaneCopy.requestTitle(request.name)).lineLimit(1)
                            Spacer(minLength: 0)
                            Button(CapabilityRegistry.capability(.mcpApproveClient).verb) {
                                grant(MCPPane.GrantTarget(
                                    client: request, approving: true,
                                    connected: door.connected.contains(request.name)))
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
                            grant(MCPPane.GrantTarget(
                                client: row.client, approving: row.client.state != .approved,
                                connected: door.connected.contains(row.client.name)))
                        } revoke: {
                            door.deny(row.client.id)
                        }
                    }
                case .shared:
                    ForEach(shared) { row in
                        MCPSharedRowView(row: row, tokens: tokens) {
                            door.revoke(grantID: row.grant.id)
                        }
                    }
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
    }

    private func reload() async {
        switch list {
        case .requests: requests = await door.allPending()
        case .clients: clients = await door.allClients()
        case .shared: shared = await door.allShared()
        }
    }
}
