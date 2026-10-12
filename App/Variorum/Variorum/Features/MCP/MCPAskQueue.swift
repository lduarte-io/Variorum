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
        /// 13n-c UX walk W-UX-1 — which RAISE this is: minted when the ask
        /// joins the queue, kept by a deduped re-raise (like its stamp), fresh
        /// for an equal ask raised after the last one left. A host presents
        /// the raise her press opened (`MCPAskOpening`), never a later one.
        var raise: Int = 0
        var id: String { ask.id }
        var opening: MCPAskOpening { MCPAskOpening(id: id, raise: raise) }
    }

    /// The asks kept waiting at once (P-13nb-U2-9's 8, carried): past it the
    /// OLDEST waiting ask she is not answering is forgotten — a dropped ask
    /// costs the client one re-ask (AF-6).
    static let cap = 8

    /// Arrival order, oldest first.
    private(set) var entries: [Entry] = []
    /// The next raise to mint (W-UX-1) — never reused while the queue lives.
    private var nextRaise = 1

    var isEmpty: Bool { entries.isEmpty }
    var count: Int { entries.count }

    func contains(_ id: String) -> Bool { entries.contains { $0.id == id } }
    func entry(_ id: String) -> Entry? { entries.first { $0.id == id } }

    /// Newest first — Settings ▸ MCP ▸ Waiting's order (the brief, mockup §4).
    var newestFirst: [Entry] { entries.reversed() }

    /// Queue an ask that arrived `now`. A re-raise of one already waiting
    /// keeps its first stamp and its place — and REFRESHES its payload (13n-c
    /// Stage B R1 B2: under arrival X an ask can wait for hours, so the
    /// target's title and fence the client's LATEST call saw are the truer
    /// picture). Past the cap, the oldest ask NOT in `answering` is forgotten.
    /// Returns whether the queue changed.
    @discardableResult
    mutating func enqueue(_ ask: MCPAsk, at now: Date, answering: Set<String> = []) -> Bool {
        if refresh(ask) { return true }
        guard !contains(ask.id) else { return false }
        entries.append(Entry(ask: ask, askedAt: now, raise: nextRaise))
        nextRaise += 1
        while entries.count > Self.cap,
              let oldest = entries.firstIndex(where: { !answering.contains($0.id) }) {
            entries.remove(at: oldest)
        }
        return true
    }

    /// A waiting ask's payload replaced by a fresher reading of the SAME ask
    /// (client · target · rung — the id): its first stamp and its place
    /// stand (Stage B R1 B2). False when it is not waiting or nothing changed.
    @discardableResult
    mutating func refresh(_ ask: MCPAsk) -> Bool {
        guard let index = entries.firstIndex(where: { $0.id == ask.id }), entries[index].ask != ask
        else { return false }
        entries[index] = Entry(ask: ask, askedAt: entries[index].askedAt, raise: entries[index].raise)
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
        MCPAskBoard(faces: entries.map { Self.face($0.ask, raise: $0.raise) })
    }

    static func target(_ ask: MCPAsk) -> MCPAskTarget {
        switch ask.scopeKind {
        case .note: .note(ask.scopeID)
        case .book: .book(ask.scopeID)
        case .wing: .wing(ask.scopeID)
        }
    }

    static func face(_ ask: MCPAsk, raise: Int = 0) -> MCPAskFace {
        MCPAskFace(
            id: ask.id, target: target(ask), clientName: ask.clientName,
            here: MCPAskCopy.here(ask), named: MCPAskCopy.title(ask), raise: raise)
    }
}
