//
//  MCPAskQueue.swift
//  Variorum (MAC ONLY)
//
//  13n-c U4 — THE ASKS WAITING FOR HER (AF-6's queue; arrival X — the brief
//  §5, mockup §4). Pure, so the pins drive it without a door: the rule that
//  was inline in `MCPDoor.enqueue` (P-13nb-U2-9 — in memory, deduped per
//  client · target · rung, capped), grown by what arrival X needs:
//
//  · an ask WAITS — it is never "on screen" by itself (13n-b's sheet that
//    presented the first one is retired), so the cap's protection is now the
//    set of asks whose sheet SHE opened (a press on its glyph, or Answer… in
//    Waiting — several windows and the pane can each hold one);
//  · an ask carries WHEN it first arrived (Waiting's "2 minutes ago"); a
//    deduped re-raise keeps its first stamp and its place;
//  · a client's asks can be forgotten whole (a denied client's ask could only
//    ever refuse — P-2);
//  · the KEYED PROJECTION every face reads (`MCPAskBoard`) is derived here.
//
//  The wire is untouched: the client still hears the one answer AF-6 gave it.
//

import Foundation
import VariorumCore
import VariorumMCP

nonisolated struct MCPAskQueue: Equatable, Sendable {
    /// One waiting ask and when it FIRST arrived.
    nonisolated struct Entry: Equatable, Sendable, Identifiable {
        let ask: MCPAsk
        let askedAt: Date
        var id: String { ask.id }
    }

    /// The asks kept waiting at once (P-13nb-U2-9's 8, carried): past it the
    /// OLDEST waiting ask she is not answering is forgotten — a dropped ask
    /// costs the client one re-ask (AF-6).
    static let cap = 8

    /// Arrival order, oldest first.
    private(set) var entries: [Entry] = []

    var isEmpty: Bool { entries.isEmpty }
    var count: Int { entries.count }

    func contains(_ id: String) -> Bool { entries.contains { $0.id == id } }
    func entry(_ id: String) -> Entry? { entries.first { $0.id == id } }

    /// Newest first — Settings ▸ MCP ▸ Waiting's order (the brief, mockup §4).
    var newestFirst: [Entry] { entries.reversed() }

    /// Queue an ask that arrived `now`. A re-raise of one already waiting
    /// changes nothing (its first stamp and its place stand). Past the cap,
    /// the oldest ask NOT in `answering` is forgotten. Returns whether the
    /// queue changed.
    @discardableResult
    mutating func enqueue(_ ask: MCPAsk, at now: Date, answering: Set<String> = []) -> Bool {
        guard !contains(ask.id) else { return false }
        entries.append(Entry(ask: ask, askedAt: now))
        while entries.count > Self.cap,
              let oldest = entries.firstIndex(where: { !answering.contains($0.id) }) {
            entries.remove(at: oldest)
        }
        return true
    }

    /// Take one ask out (her answer — either way). nil when it was not
    /// waiting (already answered elsewhere, forgotten by the cap, or the
    /// library closed).
    @discardableResult
    mutating func remove(_ id: String) -> Entry? {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return nil }
        return entries.remove(at: index)
    }

    /// Forget every ask one client raised (that client was denied — its asks
    /// could only ever refuse, P-2). Returns how many left.
    @discardableResult
    mutating func forget(client name: String) -> Int {
        let before = entries.count
        entries.removeAll { $0.ask.clientName == name }
        return before - entries.count
    }

    /// **The keyed projection** — every waiting ask as a face, keyed by the
    /// thing it names, in arrival order.
    var board: MCPAskBoard {
        MCPAskBoard(faces: entries.map { Self.face($0.ask) })
    }

    static func target(_ ask: MCPAsk) -> MCPAskTarget {
        switch ask.scopeKind {
        case .note: .note(ask.scopeID)
        case .book: .book(ask.scopeID)
        case .wing: .wing(ask.scopeID)
        }
    }

    static func face(_ ask: MCPAsk) -> MCPAskFace {
        MCPAskFace(
            id: ask.id, target: target(ask), clientName: ask.clientName,
            here: MCPAskCopy.here(ask), named: MCPAskCopy.title(ask))
    }
}
