//
//  MCPAskSheet.swift
//  Variorum (MAC ONLY)
//
//  13n-b U2 — THE JUST-IN-TIME ASK (AF-6; the mockup §4 sheet): a client
//  asked past its grant on a target that exists; the call has ALREADY
//  answered (an ask never blocks — the latency-oracle reason), and this sheet
//  puts it to her, one ask at a time, in the window or pane she pressed in.
//  Her answer mints a grant through the ordinary ops (the asked rung, the
//  asked target): Once · Until it disconnects (a connected client only —
//  P-13nc-U4-1's words for 13n-b's "while connected") · Always (never on a
//  fenced target — R-13n-4; the U1 ladder's R2-1 fix) · Don't allow. The
//  register is the MCP room's (direct and technical — R-13n-5).
//
//  13n-c U2: the title wears the asked place's distinguisher (the one rule —
//  mockup §1b), and a BOOK or WING ask says R-AIR-3's live reach above the
//  answers (the U1 ladder's F2 — every book grant says it).
//
//  13n-c U4 — ARRIVAL X (the brief §5; P-13nb-U2-9's arrival superseded):
//  this sheet NEVER presents itself. An ask waits at its pending glyph on the
//  thing it names and in Settings ▸ MCP ▸ Waiting; the sheet opens only on
//  HER press — in the window she pressed in (`mcpAskSheet(door:opening:)`, the
//  window's host) or in the pane (Waiting's Answer…). While it is open the
//  cap never forgets its ask, and it closes by itself if the ask is answered
//  elsewhere first (one ask never mints two grants — T-U4-5).
//

import SwiftUI
import VariorumCore
import VariorumMCP

struct MCPAskSheet: View {
    /// P-1: the one act this sheet renders (its answer), walked.
    static let surfaceCapabilities: [CapabilityID] = [.mcpAnswerAsk]

    let door: MCPDoor
    let ask: MCPAsk
    /// 13n-c Stage B R2-1 (a): where she pressed — a window or the pane — so a
    /// press that finds the place gone says so where she is looking.
    var seam: MCPDoor.AskSeam = .window
    /// 13n-c U2 — the asked place's distinguisher when its name collides
    /// with another offered place (`PlaceLabels`, the one rule).
    @State private var distinguisher: String?
    /// 13n-c Stage B R1 B2 — the ask has been read on CURRENT facts (her
    /// press's `refreshAsk`). Until then no answer that grants is drawn: an
    /// arrival-time snapshot may offer what the target can no longer take.
    @State private var checked = false

    /// The ask as it stands NOW — the queue's entry (refreshed by her open
    /// or by a client's re-raise), else what the host handed in. Every host
    /// renders this one view, so all three read the same truth.
    private var current: MCPAsk { door.ask(ask.id) ?? ask }

    /// 13n-c UX walk W-UX-9 / W-UX-11: the voice reaches this sheet in EVERY
    /// host now (the window hosts hand their theme to `mcpAskSheet`).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    var body: some View {
        let ask = current
        return VStack(alignment: .leading, spacing: 10) {
            Text(MCPAskCopy.title(ask, distinguisher: distinguisher))
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(MCPAskCopy.lead(ask))
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            // 13n-c U2 (the U1 ladder's F2): an answer here MINTS a book or
            // wing grant, so R-AIR-3's clause is said here too.
            if let reach = MCPAskCopy.reachLine(ask, distinguisher: distinguisher) {
                Text(reach)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            // 13n-c UX walk W-UX-9 / W-UX-11: SYSTEM buttons, as 13n-b U2's
            // walk W-3 left them — so Return answers Once and Esc answers
            // Don't allow (P-13nc-U4-8, ruled; a custom-styled button in a
            // sheet takes neither — the verify leg found it) — now in the
            // VOICE's accent: `mcpAskSheet` hands every host's theme in and
            // the sheet's `.tint` fills Once (`.borderedProminent`, the grant
            // sheet's one confirm idiom), never system blue.
            HStack(spacing: 8) {
                ForEach(checked ? door.durations(for: ask) : [], id: \.self) { duration in
                    if duration == .once {
                        Button(MCPAskCopy.button(duration)) { door.answer(ask, .grant(duration)) }
                            .buttonStyle(.borderedProminent)
                            .keyboardShortcut(.defaultAction)
                    } else {
                        Button(MCPAskCopy.button(duration)) { door.answer(ask, .grant(duration)) }
                            .buttonStyle(.bordered)
                    }
                }
                Spacer(minLength: 8)
                Button(MCPAskCopy.dontAllow) { door.answer(ask, .dontAllow) }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
            }
            .help(CapabilityRegistry.capability(.mcpAnswerAsk).verb)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(width: 480)
        .tint(tokens.accent)
        .task(id: ask.id) {
            // Stage B R1 B2: her open reads the target again (a gone target
            // forgets its ask, and this sheet closes — the hosts read the
            // queue); the answers draw on what it can take NOW.
            await door.refreshAsk(ask.id, from: seam)
            checked = true
            let labels = await door.placeDistinguishers()
            distinguisher = switch ask.scopeKind {
            case .note: nil
            case .book: labels.books[ask.scopeID]
            case .wing: labels.wings[ask.scopeID]
            }
        }
        // 13n-c U4: open by her press — the cap must not forget it while she
        // reads it.
        .onAppear { door.beginAnswering(ask.id) }
        .onDisappear { door.endAnswering(ask.id) }
    }
}

extension View {
    /// **13n-c U4 — a host's ask sheet** (a window's, the pane's): THE ask her
    /// press opened, presented while it still WAITS — answered anywhere, it
    /// closes here too (the getter reads the queue). Closing it any other way
    /// clears the request; the ask keeps waiting.
    /// Stage B R2-1 (a): `seam` says where a press that finds the place gone
    /// is answered — a window's status line (the default), or the pane's
    /// caption.
    /// 13n-c UX walk W-UX-1: the host holds the RAISE her press opened
    /// (`MCPAskOpening`), never the bare id — see `MCPAskSheetItem`.
    func mcpAskSheet(
        door: MCPDoor?, opening: Binding<MCPAskOpening?>, seam: MCPDoor.AskSeam = .window,
        theme: ThemeStore? = nil
    ) -> some View {
        sheet(item: MCPAskSheetItem.item(door: door, opening: opening)) { ask in
            if let door {
                // W-UX-11: a window host attaches this OUTSIDE its own
                // `.environment(theme)`, so it hands the theme in.
                if let theme {
                    MCPAskSheet(door: door, ask: ask, seam: seam).environment(theme)
                } else {
                    MCPAskSheet(door: door, ask: ask, seam: seam)
                }
            }
        }
    }
}

/// **The ask sheet's item, one rule for every host** (13n-c UX walk W-UX-1 —
/// its own type so the pin drives the very binding the hosts present). The
/// item is the ask her press opened while THAT raise still waits; SwiftUI
/// closes the sheet when it turns nil (answered — either way — anywhere,
/// forgotten, gone) without calling the setter, so the host keeps its opening
/// — harmless, because a later equal raise is never that opening.
enum MCPAskSheetItem {
    @MainActor
    static func item(door: MCPDoor?, opening: Binding<MCPAskOpening?>) -> Binding<MCPAsk?> {
        Binding(
            get: { opening.wrappedValue.flatMap { door?.ask($0) } },
            set: { if $0 == nil { opening.wrappedValue = nil } })
    }
}
