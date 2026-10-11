//
//  MCPAskBoard.swift
//  Variorum (MAC ONLY) — Core/Views (the shared home: every face that shows a
//  waiting ask reads it)
//
//  13n-c U4 — ASKS WAIT QUIETLY (VX-156 item 4; the brief §5 face A + arrival
//  X, with R-AIR-6's pending-ask ICON in place of face A's chip). A client's
//  ask past its grant WAITS on the thing it names — a note, a book or a wing —
//  where she already looks; nothing presents itself. This is the ONE
//  projection every face reads (P-4: a value derived from the door's queue,
//  never a broadcast): the waiting asks KEYED BY TARGET, each carrying the
//  words its hover says. The door builds it (`MCPDoor.askBoard`, from
//  `MCPAskQueue`) and each window hands it down (`\.mcpAskBoard`); a face never
//  holds the door or the wire's `MCPAsk` — only these plain faces.
//

import SwiftUI

/// What an ask names (the wire's scope, as the faces key it).
nonisolated enum MCPAskTarget: Hashable, Sendable {
    case note(String)
    case book(String)
    case wing(String)
}

/// One waiting ask, as a face shows it.
nonisolated struct MCPAskFace: Equatable, Identifiable, Sendable {
    /// The ask's own id (client · target · rung — the queue's dedupe key);
    /// the press opens exactly this ask.
    let id: String
    let target: MCPAskTarget
    let clientName: String
    /// "claude-code asks to suggest here" — the hover on the target's own row.
    let here: String
    /// "claude-code asks to write new in the variorum wing" — the hover where
    /// the face does not sit on the target itself (the masthead's wing word).
    let named: String
}

/// **The waiting asks, keyed by target** (pure; Equatable so a window hands
/// it down and only the faces that read it re-render).
nonisolated struct MCPAskBoard: Equatable, Sendable {
    /// Per target, in ARRIVAL order (oldest first — a press answers the ask
    /// that has waited longest).
    private(set) var byTarget: [MCPAskTarget: [MCPAskFace]] = [:]
    /// Every waiting wing ask, in arrival order (the masthead's wing word).
    private(set) var wingAsks: [MCPAskFace] = []

    static let empty = MCPAskBoard()

    init(faces: [MCPAskFace] = []) {
        for face in faces {
            byTarget[face.target, default: []].append(face)
            if case .wing = face.target { wingAsks.append(face) }
        }
    }

    /// The asks waiting on one target (empty — the calm state — for most).
    func asks(_ target: MCPAskTarget) -> [MCPAskFace] { byTarget[target] ?? [] }

    /// Whether this ask still waits (a nested host's sheet closes when not).
    func contains(_ id: String) -> Bool {
        byTarget.values.contains { $0.contains { $0.id == id } }
    }

    var isEmpty: Bool { byTarget.isEmpty }
}

private struct MCPAskBoardKey: EnvironmentKey {
    static let defaultValue = MCPAskBoard.empty
}

extension EnvironmentValues {
    /// The window's waiting asks (`.empty` in harness mounts and wherever no
    /// window handed one down — every pending glyph is then simply absent).
    var mcpAskBoard: MCPAskBoard {
        get { self[MCPAskBoardKey.self] }
        set { self[MCPAskBoardKey.self] = newValue }
    }
}

/// **The pending-ask words** (13n-c U4). App-wide faces, so the app's voice
/// (P-13n-1); sentence case; 13s-a sweepable.
nonisolated enum MCPAskGlyphCopy {
    /// The hover: who asks, and what — then the one road her press takes.
    /// Several asks on one target are said together; the press answers the
    /// one that has waited longest (the next press, the next).
    static func help(_ lines: [String]) -> String {
        guard !lines.isEmpty else { return "" }
        let said = lines.joined(separator: " \u{00B7} ")
        return said + (lines.count == 1 ? " \u{2014} press to answer." : " \u{2014} press to answer the first.")
    }
}
