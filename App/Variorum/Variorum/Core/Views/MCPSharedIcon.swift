//
//  MCPSharedIcon.swift
//  Variorum (MAC ONLY) — Core/Views (every place the waiting-ask glyph marks
//  renders it: the Bookcase rows, the note's indicator, and since VX-268 the
//  Library's note, book and gathering rows in List, Cards and Timeline, the
//  Pool's rows, the Book Panel's rows and the wing switcher's rows)
//
//  13n-c U3 — THE ONE SHARED ICON (VX-271, hers: "one consistent AI-shared
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
//  mark (U4's — `pendingSymbol`) was first its FILLED twin; at row size the
//  two read as near-twins (the orchestrator's O-1), so since the Stage B fix
//  pass it differs by SILHOUETTE: `questionmark.bubble` — "a question is
//  waiting for you", in the same outline language (PROVISIONAL P-13nc-SB-3;
//  the candidates captured — `sb-pending-candidates-*`; hers at the copy pass).
//
//  HOVER names who reaches it and how far; CLICK opens the permission: per
//  client, the rung · duration, the WHY when the reach comes from somewhere
//  wider ("through the Home wing grant", "through “the lightning thief”",
//  "through the open book"), and Change… (the sheet pre-filled on exactly
//  that grant — confirming REPLACES it, T-U3-8) · Revoke. The open book has no
//  grant to change or revoke: its row says where the switch lives.
//

import AppKit
import SwiftUI
import VariorumCore

struct MCPSharedIcon: View {
    /// The ONE glyph (PROVISIONAL P-13nc-U3-5).
    static let symbol = "point.3.connected.trianglepath.dotted"
    /// U4's pending-ask mark — the same outline family, a DIFFERENT
    /// silhouette (13n-c Stage B, O-1 — PROVISIONAL P-13nc-SB-3): a waiting
    /// ask must read apart from "shared" at a glance, beside it on one row.
    static let pendingSymbol = "questionmark.bubble"

    /// P-1's walk: the icon is the `.mcpShowSharing` door; its popover renders
    /// `.mcpChangeGrant` and `.mcpRevokeGrant`.
    static let surfaceCapabilities: [CapabilityID] = [.mcpShowSharing, .mcpChangeGrant, .mcpRevokeGrant]

    let reaches: [MCPPlaceReach]
    let tokens: VoiceTokens
    var font: Font? = nil
    /// 13n-c UX walk W-UX-12: where the popover opens. A host at a window's
    /// trailing edge (the note's indicator) opens it to the LEFT, so it stays
    /// on the window rather than hanging half past its edge.
    var arrowEdge: SwiftUI.Edge = .bottom
    /// After a Revoke lands (a one-shot face re-reads; a held one ignores it).
    var onChanged: () -> Void = {}
    /// **VX-281 ladder R1-2:** a host that must KNOW when the popover is up
    /// holds its state here — ⌘L's sheet, whose Esc takes a row's popover
    /// before the switcher. nil (every other host): the icon's own.
    var isPresented: Binding<Bool>? = nil
    @Environment(\.mcpShareRoad) private var road
    @State private var shown = false

    /// Whose state the popover rides: the host's when it holds one.
    private var presented: Binding<Bool> { isPresented ?? $shown }

    /// **13n-c UX walk W-UX-7 — the glyph's weight at row size.** The dotted
    /// triangle's strokes are hairlines; at `tokens.small` beside a row's
    /// title it read as a speck (worst in Terminal, and dark). The PICK stands
    /// (hers, ratified); it is drawn a size up and semibold, so its dots and
    /// lines carry the row's weight — the pending bubble beside it already
    /// read clearly at the small size and keeps it.
    static let rowScale: Image.Scale = .large
    static let rowWeight: Font.Weight = .semibold

    var body: some View {
        // VX-268: the calm state is NO view (the ask glyph's own rule) — a
        // place no approved client reaches gains neither width nor spacing,
        // so every host writes the icon once, unguarded, and a row nobody
        // reaches measures exactly what it did.
        if !reaches.isEmpty {
            Button {
                presented.wrappedValue.toggle()
            } label: {
                Image(systemName: Self.symbol)
                    .font(font ?? tokens.small)
                    .fontWeight(Self.rowWeight)
                    .imageScale(Self.rowScale)
                    .foregroundStyle(tokens.accent)
                    .padding(.horizontal, 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(MCPShareCopy.iconHelp(reaches))
            .accessibilityLabel(MCPShareCopy.iconHelp(reaches))
            .popover(isPresented: presented, arrowEdge: arrowEdge) {
                MCPReachPopover(reaches: reaches, road: road, onChanged: onChanged) {
                    presented.wrappedValue = false
                }
                .sharedIconPopoverProbe(reaches)
            }
            .sharedIconAnchorProbe()
        }
    }
}

#if DEBUG
/// **VX-281 ladder R1-5 — the icon's DEBUG oracle** (a no-op outside DEBUG):
/// where each drawn icon sits in its WINDOW (an AppKit anchor behind the
/// button — never a click target), and which popovers presented and are up,
/// by the first reaching client's name. In-process, SwiftUI builds no
/// accessibility nodes (`ComposedSliders`' measured note), so a pin that
/// clicks the icon needs its own road to the icon's frame — this is it.
@MainActor
enum MCPSharedIconProbe {
    final class Anchor {
        weak var view: NSView?
        init(_ view: NSView) { self.view = view }
    }

    static var anchors: [Anchor] = []
    /// Every presentation, in order, by the first reaching client's name.
    static var presented: [String] = []
    /// Each popover's content appearances minus its disappearances, by the
    /// first reaching client's name. Reliable for "went up" only: SwiftUI did
    /// not report a dismissed popover's content leaving (VX-281 STAGE WINDOW
    /// R1b), so a pin asks AppKit whether a popover is gone (no visible
    /// popover window).
    static var up: [String: Int] = [:]

    /// The icons drawn in `window` now, in window coordinates.
    static func frames(in window: NSWindow) -> [NSRect] {
        anchors.removeAll { $0.view == nil }
        return anchors.compactMap(\.view)
            .filter { $0.window === window && !$0.isHiddenOrHasHiddenAncestor }
            .map { $0.convert($0.bounds, to: nil) }
    }

    static func presentations(of client: String) -> Int {
        presented.filter { $0 == client }.count
    }
}

/// The anchor behind the icon's button: transparent to every click.
private struct MCPSharedIconAnchor: NSViewRepresentable {
    final class AnchorView: NSView {
        override func hitTest(_ point: NSPoint) -> NSView? { nil }
    }

    func makeNSView(context: Context) -> AnchorView {
        let view = AnchorView()
        MCPSharedIconProbe.anchors.append(.init(view))
        return view
    }

    func updateNSView(_ view: AnchorView, context: Context) {}
}
#endif

extension View {
    /// The icon's place, for the DEBUG click pins (a no-op outside DEBUG).
    @ViewBuilder
    fileprivate func sharedIconAnchorProbe() -> some View {
        #if DEBUG
        background(MCPSharedIconAnchor())
        #else
        self
        #endif
    }

    /// The popover's presentations, for the DEBUG pins (a no-op outside DEBUG).
    @ViewBuilder
    fileprivate func sharedIconPopoverProbe(_ reaches: [MCPPlaceReach]) -> some View {
        #if DEBUG
        let name = reaches.first?.clientName ?? ""
        onAppear {
            MCPSharedIconProbe.presented.append(name)
            MCPSharedIconProbe.up[name, default: 0] += 1
        }
        .onDisappear { MCPSharedIconProbe.up[name, default: 0] -= 1 }
        #else
        self
        #endif
    }
}

/// **The permission, shown** (VX-271's click; VX-164's why) — the popover
/// both the Bookcase icon and the note's indicator open. Settings-class words
/// (VX-272: no "AI" — the client's own name says who).
struct MCPReachPopover: View {
    let reaches: [MCPPlaceReach]
    let road: MCPShareRoad?
    var onChanged: () -> Void = {}
    let close: () -> Void
    /// 13n-c UX walk W-UX-11: the links wear the VOICE's accent (they drew
    /// system blue, even in dark Terminal) — the popover reads its host's
    /// theme (a popover inherits the environment).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

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
                            // W-UX-5: a wider grant's Revoke says which grant.
                            Button(MCPShareCopy.revokeLabel(reach)) {
                                close()
                                Task {
                                    await road.revoke([grant.id])
                                    onChanged()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(tokens.accent)
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
        // W-UX-12: the room's own ground under the words — the popover
        // material took the colour of whatever sat behind the window (a
        // pink browser toolbar in the walk). The arrow and rim stay the
        // system's material: that much macOS draws itself (recorded).
        .presentationBackground(tokens.room)
        .tint(tokens.accent)
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
