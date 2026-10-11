//
//  MCPSharedIcon.swift
//  Variorum (MAC ONLY) — Core/Views (the Bookcase rows and the note's
//  indicator both render it)
//
//  13n-c U3 — THE ONE SHARED ICON (R-AIR-6, hers: "one consistent AI-shared
//  ICON, not text … hover names it, click shows the permission; icon language
//  matches the sidebar set"). It REPLACES the Bookcase's "shared with AI" text
//  chip (P-13nb-U2-11's honest-under-every-grant-shape rule carried: it draws
//  wherever an approved client reaches the place now, through any standing).
//
//  THE GLYPH — PROVISIONAL P-13nc-U3-5 (hers at the copy pass; the candidates
//  captured in the U3 record): `point.3.connected.trianglepath.dotted`, the
//  outline line-glyph Settings ▸ MCP's own pane wears (`SettingsShape` —
//  "where the permission lives" is the same picture as "the permission is
//  here"), in the sidebar set's outline language (books.vertical ·
//  text.book.closed · tray · square.on.square · archivebox). The pending-ask
//  sibling (U4's) is its FILLED twin, `point.3.filled.connected.trianglepath
//  .dotted` — the same family, the slot left here (`pendingSymbol`).
//
//  HOVER names who reaches it and how far; CLICK opens the permission: per
//  client, the rung · duration, the WHY when the reach comes from somewhere
//  wider ("through the Home wing grant", "through “the lightning thief”",
//  "through the open book"), and Change… (the sheet pre-filled on exactly
//  that grant — confirming REPLACES it, T-U3-8) · Revoke. The open book has no
//  grant to change or revoke: its row says where the switch lives.
//

import SwiftUI
import VariorumCore

struct MCPSharedIcon: View {
    /// The ONE glyph (PROVISIONAL P-13nc-U3-5).
    static let symbol = "point.3.connected.trianglepath.dotted"
    /// U4's pending-ask sibling — the same family, filled.
    static let pendingSymbol = "point.3.filled.connected.trianglepath.dotted"

    /// P-1's walk: the icon is the `.mcpShowSharing` door; its popover renders
    /// `.mcpChangeGrant` and `.mcpRevokeGrant`.
    static let surfaceCapabilities: [CapabilityID] = [.mcpShowSharing, .mcpChangeGrant, .mcpRevokeGrant]

    let reaches: [MCPPlaceReach]
    let tokens: VoiceTokens
    var font: Font? = nil
    /// After a Revoke lands (a one-shot face re-reads; a held one ignores it).
    var onChanged: () -> Void = {}
    @Environment(\.mcpShareRoad) private var road
    @State private var shown = false

    var body: some View {
        Button {
            shown.toggle()
        } label: {
            Image(systemName: Self.symbol)
                .font(font ?? tokens.small)
                .foregroundStyle(tokens.accent)
                .padding(.horizontal, 2)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(MCPShareCopy.iconHelp(reaches))
        .accessibilityLabel(MCPShareCopy.iconHelp(reaches))
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            MCPReachPopover(reaches: reaches, road: road, onChanged: onChanged) { shown = false }
        }
    }
}

/// **The permission, shown** (R-AIR-6's click; R-AIR-7's why) — the popover
/// both the Bookcase icon and the note's indicator open. Settings-class words
/// (R-AIR-8: no "AI" — the client's own name says who).
struct MCPReachPopover: View {
    let reaches: [MCPPlaceReach]
    let road: MCPShareRoad?
    var onChanged: () -> Void = {}
    let close: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(MCPShareCopy.popoverTitle)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
            ForEach(reaches) { reach in
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(reach.clientName)
                            .font(.callout.weight(.semibold))
                            .lineLimit(1)
                        Text(MCPShareCopy.reachLine(reach))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    if let why = MCPShareCopy.why(reach) {
                        Text(why)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let grant = reach.grant, let road {
                        HStack(spacing: 10) {
                            Button(CapabilityRegistry.capability(.mcpChangeGrant).verb) {
                                close()
                                road.open(MCPReachPopover.changeOpening(reach.client, grant))
                            }
                            Button(CapabilityRegistry.capability(.mcpRevokeGrant).verb) {
                                close()
                                Task {
                                    await road.revoke([grant.id])
                                    onChanged()
                                }
                            }
                        }
                        .buttonStyle(.link)
                        .font(.caption)
                    } else if reach.grant == nil {
                        Text(MCPShareCopy.openBookNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .frame(minWidth: 240, maxWidth: 340, alignment: .leading)
    }

    /// **Change… on a grant** — THE sheet pre-filled on exactly that grant (its
    /// client, its own place — a wider grant's wing or book, not the row it
    /// was seen from — its rung and duration), REPLACING it on confirm
    /// (T-U3-8). Pure, so the pins read it.
    static func changeOpening(_ client: MCPClient, _ grant: MCPGrantRow) -> MCPGrantOpening {
        let place: MCPGrantPrefill = switch grant.scopeKind {
        case .note: .note(grant.scopeID)
        case .book: .book(grant.scopeID)
        case .wing: .wing(grant.scopeID)
        }
        return MCPGrantOpening(
            client: client, place: place, rung: grant.rung, duration: grant.duration,
            replacing: [grant.id], origin: .place)
    }
}
