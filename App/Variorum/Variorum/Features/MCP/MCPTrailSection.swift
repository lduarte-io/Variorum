//
//  MCPTrailSection.swift
//  Variorum (MAC ONLY)
//
//  VX-679 (the VX-809 run, batch 5 — her R-679, the 2026-11-04 sitting and
//  her refinements on the ticket): THE SIDEBAR'S AI SECTION. Its own section
//  near the sidebar's BOTTOM — never under Open — about three rows, scrolling
//  within when there are more, and GONE when the session's trail is empty.
//  One "From ‹client› · N" group per client (her header); each row names the
//  place, the kind (shown · opened · edited — her words) and when, and wears
//  the shared-with-AI symbol (`MCPSharedIcon.symbol`), so the list reads as
//  that icon's family at a glance.
//
//  TWO DOORS PER ROW (her refinement — "the two clicks split glance-vs-go the
//  same way the Library rows do"): the row's TEXT goes there
//  (`.mcpOpenTrailPlace` — `MCPDoor.openTrailEntry`, the existing landing
//  roads), the SYMBOL opens the request's details (`.mcpShowTrailDetails` — the
//  client, when it came in, what kind of act it was, what it targeted).
//
//  P1, THE SHARED ICON'S LAW: the section renders its rows from the door's
//  session memory (`MCPTrailModel`) and READS NOTHING — no store read to
//  draw, whoever is approved; only her press re-reads its one place.
//
//  Composed by `RootView` and handed to `SidebarView` as a view to RENDER
//  (`SidebarView.FooterSection` — the note box's and the status rows' seam):
//  the sidebar never holds the door.
//

import SwiftUI
import VariorumMCP

struct MCPTrailSection: View {
    /// P-1's walk: the section is the two row doors' ONLY renderer.
    static let surfaceCapabilities: [CapabilityID] = [.mcpOpenTrailPlace, .mcpShowTrailDetails]

    let door: MCPDoor
    /// The column's row pitch (it compresses with the column).
    let rowHeight: CGFloat
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    var body: some View {
        let trail = door.trail.trail
        let groups = trail.groups
        if !groups.isEmpty {
            let fits = SidebarLayout.aiSectionFits(
                headers: groups.count, rows: trail.entries.count, rowHeight: rowHeight)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(groups) { group in
                        Section {
                            ForEach(group.entries) { entry in
                                MCPTrailRow(door: door, entry: entry, rowHeight: rowHeight, tokens: tokens)
                            }
                        } header: {
                            header(MCPTrailCopy.header(client: group.clientName, count: group.entries.count))
                        }
                    }
                }
                // The margin INSIDE the scroll (VX-286's rule): the overlay
                // scroll bar rides beside the rows' symbols, never over them.
                .padding(.horizontal, SidebarLayout.groupPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxHeight: SidebarLayout.aiSectionMaxHeight(rowHeight: rowHeight))
            .fixedSize(horizontal: false, vertical: fits)
        }
    }

    /// The column's header grammar (`SidebarView.header`): small, in the
    /// accent, on the rows' text edge, at the header row's pitch — on the
    /// room's ground, since it pins while the rows scroll under it.
    private func header(_ title: String) -> some View {
        Text(tokens.chromeLabel(title))
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, SidebarLayout.rowPadding)
            .padding(.bottom, SidebarLayout.headerAir)
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .frame(height: SidebarLayout.groupHeaderHeight, alignment: .bottomLeading)
            .background(tokens.room)
    }
}

/// One row: the place, its kind and when (the text door), and the symbol (the
/// details door, its popover the row's own).
private struct MCPTrailRow: View {
    let door: MCPDoor
    let entry: MCPTrail.Entry
    let rowHeight: CGFloat
    let tokens: VoiceTokens
    @State private var showingDetails = false

    var body: some View {
        HStack(spacing: 4) {
            Button {
                door.openTrailEntry(entry.id)
            } label: {
                HStack(spacing: 6) {
                    Text(tokens.chromeLabel(MCPTrailCopy.place(entry.target, title: entry.title)))
                        .font(tokens.navigation)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer(minLength: 4)
                    Text(tokens.chromeLabel(MCPTrailCopy.detail(entry)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .fixedSize()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(MCPTrailCopy.openHelp(entry))
            .accessibilityLabel(MCPTrailCopy.openHelp(entry))

            Button {
                showingDetails.toggle()
            } label: {
                Image(systemName: MCPSharedIcon.symbol)
                    .font(tokens.small)
                    .fontWeight(MCPSharedIcon.rowWeight)
                    .imageScale(MCPSharedIcon.rowScale)
                    .foregroundStyle(tokens.accent)
                    .padding(.horizontal, 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(MCPTrailCopy.detailsHelp(entry))
            .accessibilityLabel(MCPTrailCopy.detailsHelp(entry))
            .popover(isPresented: $showingDetails, arrowEdge: .trailing) {
                MCPTrailDetails(entry: entry)
            }
        }
        .padding(.horizontal, SidebarLayout.rowPadding)
        .frame(height: rowHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// **The request's details** (her refinement: "the client, when it came in,
/// what kind of act it was (a navigation ask · a write and which operation),
/// and what it targeted"). A glance: nothing read, nothing written.
struct MCPTrailDetails: View {
    let entry: MCPTrail.Entry
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    /// The popover's lines, in order — pure, so the pins read exactly what it says.
    static func lines(_ entry: MCPTrail.Entry, now: Date = Date()) -> [String] {
        [
            MCPTrailCopy.detailsWhen(entry, now: now),
            MCPTrailCopy.detailsAct(entry),
            MCPTrailCopy.detailsTarget(entry),
        ] + [MCPTrailCopy.detailsState(entry), MCPTrailCopy.detailsCount(entry)].compactMap { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.clientName)
                .font(.callout.weight(.semibold))
                .lineLimit(1)
            ForEach(Array(Self.lines(entry).enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(minWidth: 220, maxWidth: 320, alignment: .leading)
        // The room's own ground under the words (the shared icon's popover —
        // W-UX-12).
        .presentationBackground(tokens.room)
        .tint(tokens.accent)
    }
}
