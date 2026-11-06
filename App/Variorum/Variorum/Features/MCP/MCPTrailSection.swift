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
//  VX-874 (the VX-878 run, batch 3 — her rulings (1)–(4); the record
//  `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): the rows
//  behave like the sidebar's rows. A client's NAVIGATION ASKS float to the top
//  of their group, and groups holding one come first (`MCPTrail.groups(showing:)`
//  — her one exception to "mirror the sidebar"); every row carries a ✕ and a
//  right-click Dismiss (`.mcpDismissTrailEntry` — the row goes, nothing else);
//  every row's and header's right-click carries Clear All (`.mcpClearTrail` —
//  the Open list's Close All Notes grammar) and each header's the dial's twin
//  (`.mcpSetTrailDial`); a row DRAGS among its own stratum — the Open list's
//  two drop halves, a slot line where a drop would act, the settle (rail (a),
//  PROVISIONAL P-874-3). What the section draws follows Settings ▸ MCP's
//  three-state dial (`MCPDoor.trailDial` — everything on · notices off · fully
//  off).
//
//  P1, THE SHARED ICON'S LAW: the section renders its rows from the door's
//  session memory (`MCPTrailModel`) and READS NOTHING — no store read to
//  draw, whoever is approved; only her press re-reads its one place.
//
//  Composed by `RootView` and handed to `SidebarView` as a view to RENDER
//  (`SidebarView.FooterSection` — the note box's and the status rows' seam):
//  the sidebar never holds the door.
//

import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore
import VariorumMCP

struct MCPTrailSection: View {
    /// P-1's walk: the section is the two row doors' ONLY renderer.
    static let surfaceCapabilities: [CapabilityID] = [.mcpOpenTrailPlace, .mcpShowTrailDetails]
    /// VX-874: the row's ✕ — the dismiss's visible door (its only renderer).
    static let rowManageCapabilities: [CapabilityID] = [.mcpDismissTrailEntry]
    /// VX-874: the rows' right-click (Dismiss · Clear All) and the headers'
    /// (Clear All · the dial's twin) — their only renderer.
    static let contextMenuCapabilities: [CapabilityID] = [.mcpDismissTrailEntry, .mcpClearTrail, .mcpSetTrailDial]

    let door: MCPDoor
    /// The column's row pitch (it compresses with the column).
    let rowHeight: CGFloat
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme
    /// VX-874: this section's own drag (rail (a)) — one per section, so a drag
    /// from another window's section never lands here (its list id differs).
    @State private var drag = MCPTrailDragState()

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    var body: some View {
        let trail = door.trail.trail
        // VX-874: what the dial lets the section draw, the asks floated.
        let groups = trail.groups(showing: door.trailDial)
        if !groups.isEmpty {
            let fits = SidebarLayout.aiSectionFits(
                headers: groups.count, rows: groups.reduce(0) { $0 + $1.entries.count }, rowHeight: rowHeight)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(groups) { group in
                        Section {
                            ForEach(group.entries) { entry in
                                MCPTrailRow(
                                    door: door, entry: entry, trail: trail, drag: drag,
                                    rowHeight: rowHeight, tokens: tokens)
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
    /// room's ground, since it pins while the rows scroll under it. VX-874:
    /// its right-click carries Clear All and the dial's twin.
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
            .contentShape(Rectangle())
            .contextMenu {
                Button(CapabilityRegistry.capability(.mcpClearTrail).verb) { door.clearTrail() }
                Divider()
                // The dial's twin ("welcome if cheap"): the pane's own three
                // values, the stored one checked.
                Picker(CapabilityRegistry.capability(.mcpSetTrailDial).verb, selection: Binding(
                    get: { door.trailDial },
                    set: { door.setTrailDial($0) })) {
                    ForEach(MCPTrailDial.allCases, id: \.self) { dial in
                        Text(MCPPaneCopy.trailDialChoice(dial)).tag(dial)
                    }
                }
            }
    }
}

/// One row: the place, its kind and when (the text door), its ✕ (VX-874), and
/// the symbol at its END (the details door, its popover the row's own — the
/// guide says "the icon at its end").
private struct MCPTrailRow: View {
    let door: MCPDoor
    let entry: MCPTrail.Entry
    /// The trail as the section drew it — the drop rule reads it (a slot line
    /// lights only where a drop would act).
    let trail: MCPTrail
    let drag: MCPTrailDragState
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

            // VX-874 — the row's ✕ (the Open row's idiom): the row goes,
            // nothing else (rail (b)).
            Button("\u{2715}") { door.dismissTrailEntry(entry.id) }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .help(MCPTrailCopy.dismissHelp)
                .accessibilityLabel(CapabilityRegistry.capability(.mcpDismissTrailEntry).verb)

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
        // VX-874 — the slot line where a drop would act (the 2-pt ring line,
        // centred on the row's edge so the two halves of one boundary draw one
        // line), then the two drop halves, live only while this section's own
        // drag is in flight (at rest they take no hits — every door above is
        // the row's exactly as before).
        .overlay(alignment: .top) { slotLine(.top) }
        .overlay(alignment: .bottom) { slotLine(.bottom) }
        .overlay { halves }
        // The system drag with the row's own image (the Open list's title chip
        // stays its own — SurfaceContracts; VX-70 is Parked); the payload, made
        // when the drag begins, arms the section's drag.
        .draggable(beginDrag())
        .onDragSessionUpdated { session in drag.dragSessionUpdated(session.phase) }
        .contextMenu {
            Button(CapabilityRegistry.capability(.mcpDismissTrailEntry).verb) { door.dismissTrailEntry(entry.id) }
            Button(CapabilityRegistry.capability(.mcpClearTrail).verb) { door.clearTrail() }
        }
    }

    /// The payload — evaluated when the drag BEGINS (the Open list's trace).
    private func beginDrag() -> MCPTrailDragToken {
        drag.began(entry.id)
        return MCPTrailDragToken(entryID: entry.id.uuidString, listID: drag.listID)
    }

    @ViewBuilder
    private func slotLine(_ edge: VerticalEdge) -> some View {
        if drag.lineEdge(on: entry.id, in: trail) == edge {
            Rectangle()
                .fill(tokens.ring)
                .frame(height: SidebarLayout.OpenListDrop.lineThickness)
                .offset(y: edge == .top
                        ? -SidebarLayout.OpenListDrop.lineThickness / 2
                        : SidebarLayout.OpenListDrop.lineThickness / 2)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private var halves: some View {
        VStack(spacing: 0) {
            half(.before(entry.id))
            half(.after(entry.id))
        }
        .allowsHitTesting(drag.inFlight(in: trail))
        .accessibilityHidden(true)
    }

    private func half(_ slot: MCPTrail.Slot) -> some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .dropDestination(for: MCPTrailDragToken.self) { tokens, _ in
                MCPTrailDropDoor.perform(tokens, onto: slot, drag: drag, door: door)
            } isTargeted: { targeted in
                drag.targeted(slot, targeted)
            }
    }
}

/// **The section's drag payload** (VX-874): the dragged row and the section it
/// began in. A custom exported type, DECLARED in Info.plist (17y B2's rule —
/// `DragTypeDeclarationTests`).
nonisolated struct MCPTrailDragToken: Codable, Transferable, Sendable {
    let entryID: String
    let listID: String

    static let contentType = UTType(exportedAs: "io.lduarte.variorum.ai-trail-row")

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: contentType)
    }
}

/// **One section's drag, as it stands** (VX-874 — the Open list's
/// `OpenListDragState`, its own: the trail keys rows by id and has no scroll
/// window to read) — which row a drag of THIS section began on and which half
/// it targets.
@MainActor
@Observable
final class MCPTrailDragState {
    /// This section's name on its drags' payload (P-U2-3's precedent).
    @ObservationIgnored let listID = UUID().uuidString
    /// The row a drag of this section's began on; nil when none is in flight.
    private(set) var dragging: UUID?
    /// The half the drag targets now; nil while it is over none.
    private(set) var target: MCPTrail.Slot?

    func began(_ id: UUID) {
        dragging = id
        if target != nil { target = nil }
    }

    /// A half's `isTargeted` changed: a target replaces whatever stood; an
    /// un-target clears only the target IT set.
    func targeted(_ slot: MCPTrail.Slot, _ isTargeted: Bool) {
        if isTargeted {
            if target != slot { target = slot }
        } else if target == slot {
            target = nil
        }
    }

    /// The drag SESSION's end, wherever the release fell, ends the drag.
    func dragSessionUpdated(_ phase: DragSession.Phase) {
        guard case .ended = phase else { return }
        ended()
    }

    func ended() {
        if dragging != nil { dragging = nil }
        if target != nil { target = nil }
    }

    /// The halves' liveness: a drag began here AND its row is still in the
    /// trail (a row gone mid-drag stands them down — the Open list's m-7).
    func inFlight(in trail: MCPTrail) -> Bool {
        dragging.map { trail.entry($0) != nil } ?? false
    }

    /// Where the slot line draws on `rowID` — only where a drop would act
    /// (`MCPTrail.reordered`; the false-offer rule): its top for the slot
    /// before it, its bottom for the slot after it; nil anywhere else.
    func lineEdge(on rowID: UUID, in trail: MCPTrail) -> VerticalEdge? {
        guard let dragging, let target, target.rowID == rowID,
              trail.reordered(dragging, onto: target) != nil
        else { return nil }
        if case .after = target { return .bottom }
        return .top
    }
}

/// **The drop's door** — the release on a half, landing through the door's one
/// move (`MCPDoor.moveTrailEntry`) on the column's settle.
@MainActor
enum MCPTrailDropDoor {
    /// The settle — the Open list's beat (`SidebarLayout.railTransition`).
    static var settle: Animation { .snappy(duration: SidebarLayout.railTransition) }

    /// The release on `slot`: acts only on THIS section's drag (its list id)
    /// and only where the drop would act; the drag ends either way. Returns
    /// whether anything moved (false: the image slides back).
    @discardableResult
    static func perform(
        _ tokens: [MCPTrailDragToken], onto slot: MCPTrail.Slot, drag: MCPTrailDragState, door: MCPDoor,
        animation: Animation? = settle
    ) -> Bool {
        drag.ended()
        guard let token = tokens.first, token.listID == drag.listID, let id = UUID(uuidString: token.entryID)
        else { return false }
        var moved = false
        withAnimation(animation) { moved = door.moveTrailEntry(id, onto: slot) }
        return moved
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
