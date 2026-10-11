//
//  MCPAskGlyph.swift
//  Variorum (MAC ONLY) — Core/Views (every face that shows a waiting ask
//  renders it: the Library's and the Pool's note rows, the Book Panel's rows,
//  both bars' note ▾, the Bookcase's book rows, the wing switcher's rows and
//  its masthead word, the in-note indicator)
//
//  13n-c U4 — THE PENDING-ASK GLYPH (R-AIR-6, hers: "a pending-ask icon in the
//  same family"; VX-156 item 4 — the brief §5's face A, its "asks" chip
//  superseded by this icon). `MCPSharedIcon.pendingSymbol` (the slot U3 left —
//  since the Stage B fix pass's O-1 a different SILHOUETTE from the shared
//  icon, `questionmark.bubble`, PROVISIONAL P-13nc-SB-3), drawn ONLY while an
//  ask waits on this target; the calm state draws nothing at all (no width,
//  no spacing — the hosts' shipped alignment pins measure exactly what they
//  did). HOVER names who asks and what ("claude-code asks to suggest here —
//  press to answer."); HER PRESS opens that ask's sheet in this window (the
//  road's `answerAsk`). It never raises, scrolls, toasts or presents itself
//  — the ask's arrival changes this glyph and nothing else (R-13nb-23/26g).
//

import SwiftUI

struct MCPAskGlyph: View {
    /// P-1's walk: the glyph is the `.mcpOpenAsk` door.
    static let surfaceCapabilities: [CapabilityID] = [.mcpOpenAsk]

    /// What the glyph stands for.
    nonisolated enum Subject: Equatable, Sendable {
        /// The asks waiting on this one note, book or wing — on its own row,
        /// so the hover says "here".
        case target(MCPAskTarget)
        /// Every waiting WING ask — the masthead's wing word, which names the
        /// current wing but is the door to them all, so the hover names each
        /// wing.
        case anyWing
    }

    let subject: Subject
    let tokens: VoiceTokens
    var font: Font? = nil
    @Environment(\.mcpAskBoard) private var board
    @Environment(\.mcpShareRoad) private var road

    init(_ subject: Subject, tokens: VoiceTokens, font: Font? = nil) {
        self.subject = subject
        self.tokens = tokens
        self.font = font
    }

    init(_ target: MCPAskTarget, tokens: VoiceTokens, font: Font? = nil) {
        self.init(.target(target), tokens: tokens, font: font)
    }

    /// The asks this glyph shows, oldest first (a press answers the first).
    static func asks(_ subject: Subject, on board: MCPAskBoard) -> [MCPAskFace] {
        switch subject {
        case .target(let target): board.asks(target)
        case .anyWing: board.wingAsks
        }
    }

    /// The hover (and the accessibility label): every waiting ask said.
    static func help(_ subject: Subject, _ asks: [MCPAskFace]) -> String {
        let lines = asks.map { ask in
            if case .anyWing = subject { return ask.named }
            return ask.here
        }
        return MCPAskGlyphCopy.help(lines)
    }

    var body: some View {
        // The calm state is NO view (the `if` at the top of the body) — so a
        // host's stack gains neither width nor spacing until an ask waits.
        let asks = Self.asks(subject, on: board)
        if let first = asks.first, let road {
            Button {
                road.answerAsk(first.id)
            } label: {
                Image(systemName: MCPSharedIcon.pendingSymbol)
                    .font(font ?? tokens.small)
                    .foregroundStyle(tokens.accent)
                    .padding(.horizontal, 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(Self.help(subject, asks))
            .accessibilityLabel(Self.help(subject, asks))
        }
    }
}
