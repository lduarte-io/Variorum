//
//  MCPAskSheet.swift
//  Variorum (MAC ONLY)
//
//  13n-b U2 — THE JUST-IN-TIME ASK (AF-6; the mockup §4 sheet): a client
//  asked past its grant on a target that exists; the call has ALREADY
//  answered (an ask never blocks — the latency-oracle reason), and this sheet
//  puts it to her, one ask at a time, on the main window. Her answer mints a
//  grant through the ordinary ops (the asked rung, the asked target): Once ·
//  While connected (a connected client only) · Always (never on a fenced
//  target — R-13n-4; R2-1's fix) · Don't allow. The register is the MCP
//  room's (direct and technical — R-13n-5).
//
//  13n-c U2: the title wears the asked place's distinguisher (the one rule —
//  mockup §1b), and a BOOK or WING ask says R-AIR-3's live reach above the
//  answers (the U1 ladder's F2 — every book grant says it).
//
//  13n-c U4 — ARRIVAL X (the brief §5; P-13nb-U2-9's arrival superseded):
//  this sheet NEVER presents itself. An ask waits at its pending glyph on the
//  thing it names and in Settings ▸ MCP ▸ Waiting; the sheet opens only on
//  HER press — in the window she pressed in (`mcpAskSheet(door:askID:)`, the
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
    /// 13n-c U2 — the asked place's distinguisher when its name collides
    /// with another offered place (`PlaceLabels`, the one rule).
    @State private var distinguisher: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            // U2 walk W-3: SYSTEM buttons — the sheet presents at the
            // WindowGroup level, where no session theme reaches (the
            // library-open sheet's own precedent beside it); voiced buttons
            // there fell back to the mono fallback face.
            HStack(spacing: 8) {
                ForEach(door.durations(for: ask), id: \.self) { duration in
                    if duration == .once {
                        Button(MCPAskCopy.button(duration)) { door.answer(ask, .grant(duration)) }
                            .keyboardShortcut(.defaultAction)
                    } else {
                        Button(MCPAskCopy.button(duration)) { door.answer(ask, .grant(duration)) }
                    }
                }
                Spacer(minLength: 8)
                Button(MCPAskCopy.dontAllow) { door.answer(ask, .dontAllow) }
                    .keyboardShortcut(.cancelAction)
            }
            .help(CapabilityRegistry.capability(.mcpAnswerAsk).verb)
            .padding(.top, 4)
        }
        .padding(20)
        .frame(width: 480)
        .task(id: ask.id) {
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
    func mcpAskSheet(door: MCPDoor?, askID: Binding<String?>) -> some View {
        sheet(item: Binding(
            get: { askID.wrappedValue.flatMap { id in door?.ask(id) } },
            set: { if $0 == nil { askID.wrappedValue = nil } })
        ) { ask in
            if let door { MCPAskSheet(door: door, ask: ask) }
        }
    }
}
