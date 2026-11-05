//
//  MCPTrail.swift
//  Variorum (MAC ONLY)
//
//  VX-679 (the VX-809 run, batch 5 — her R-679, the 2026-11-04 sitting and her
//  refinements on the ticket; the record `notes/plans/fixes/vx-809-mcp-door-
//  ergonomics.md`, BATCH 5 RECORD): THE PLACES A CLIENT SHOWED HER OR CHANGED,
//  this session — the ⌥⌘O trail generalized. ⌥⌘O keeps jumping to the LAST
//  change (`MCPDoor.lastChange`, untouched); this is the list behind it, the
//  sidebar's "From ‹client› · N" section.
//
//  PURE: a value the door feeds (a landed write with a landing — the receipt's
//  `show`; a `show_in_app` ask that was offered or moved her view) and her
//  presses mark or let go. It holds what the receipt and the request already
//  carried (their titles included — the receipt line's and `lastChange`'s
//  precedent), reads NOTHING, and is session-scoped: the door clears it
//  exactly where it clears ⌥⌘O's last change (`letGoOfTheSession` — the lock,
//  the library closing, the quit). So the section draws its rows from memory
//  and reads nothing, whoever is approved (the shared icon's law, P1).
//
//  ONE ROW PER PLACE per client (PROVISIONAL P-809-14 — her title's word,
//  "places your AI changed"): a newer act on a place a row already names
//  updates that row — its kind, its time, its landing — and moves it to the
//  top, counting the acts it gathers, so a sweep of 48 acts on one note is one
//  row, never 48. Capped (`cap`) — the oldest place falls off.
//

import Foundation
import Observation
import VariorumCore
import VariorumMCP

nonisolated struct MCPTrail: Equatable, Sendable {
    /// Her three words (R-679: "the kind (shown · opened · edited)").
    /// PROVISIONAL P-809-14's mapping: `shown` — a client asked to show her the
    /// place and it is offered (it waits on her status seam, or waited);
    /// `opened` — the place opened in front of her (move at once moved her
    /// view, or she took the ask); `edited` — a client wrote there.
    enum Kind: String, Equatable, Sendable {
        case shown, opened, edited
    }

    /// What the request was (the details popover's "what kind of act it was —
    /// a navigation ask · a write and which operation").
    enum Act: Equatable, Sendable {
        case show(MCPShowRequest)
        case write(MCPWriteReceipt)
    }

    struct Entry: Equatable, Identifiable, Sendable {
        /// Stable while the row lives (a newer act on its place keeps it).
        let id: UUID
        let clientName: String
        /// The place's key (`placeKey`) — what makes two acts one row.
        let place: String
        var kind: Kind
        /// When the newest request on this place came in.
        var at: Date
        /// The newest request on this place.
        var act: Act
        /// Where the row's text lands — the newest request's landing.
        var target: MCPShowTarget
        /// The place's name as the request carried it (nil when it carried
        /// none the row can trust — the row then says the place's noun).
        var title: String?
        /// How many requests this row gathers (1 for a fresh row).
        var count: Int
    }

    /// The most rows kept (PROVISIONAL P-809-14): bounded memory, ∝ nothing
    /// in the library.
    static let cap = 50

    /// Newest first.
    private(set) var entries: [Entry] = []

    /// One client's rows, newest first — a "From ‹client› · N" group.
    struct Group: Equatable, Identifiable, Sendable {
        var id: String { clientName }
        let clientName: String
        let entries: [Entry]
    }

    /// The rows by client, each group ordered by its newest row (the clients
    /// in the order of their newest act).
    var groups: [Group] {
        var order: [String] = []
        var byClient: [String: [Entry]] = [:]
        for entry in entries {
            if byClient[entry.clientName] == nil { order.append(entry.clientName) }
            byClient[entry.clientName, default: []].append(entry)
        }
        return order.map { Group(clientName: $0, entries: byClient[$0] ?? []) }
    }

    var isEmpty: Bool { entries.isEmpty }

    func entry(_ id: UUID) -> Entry? { entries.first { $0.id == id } }

    // MARK: - The feeds

    /// A landed write — only one with a landing (the receipt's `show`, the
    /// one ⌥⌘O would open): a write with none (a deleted note) names no place
    /// her press could open, so it leaves no row (P-2 — a door that can only
    /// refuse is a dead door).
    mutating func record(write receipt: MCPWriteReceipt, at now: Date, id: UUID = UUID()) {
        guard let target = receipt.show else { return }
        land(
            clientName: receipt.clientName, target: target, title: Self.placeTitle(of: receipt),
            kind: .edited, act: .write(receipt), at: now, id: id)
    }

    /// A `show_in_app` ask that was OFFERED (`.shown`) or that moved her view
    /// (`.opened`). A refused one (the never dial, no window) leaves no row —
    /// nothing was shown or offered.
    mutating func record(show request: MCPShowRequest, opened: Bool, at now: Date, id: UUID = UUID()) {
        land(
            clientName: request.clientName, target: request.target, title: request.title,
            kind: opened ? .opened : .shown, act: .show(request), at: now, id: id)
    }

    /// She took an ask (its Open ›, ⌥⌘O, or the row): the row of that very ask
    /// reads `opened`. A row a newer act has moved on from is left as it is.
    mutating func markOpened(_ request: MCPShowRequest) {
        guard let index = entries.firstIndex(where: { $0.act == .show(request) }) else { return }
        entries[index].kind = .opened
    }

    /// Her press found the place GONE: every row naming that place goes (the
    /// receipt's own rule — a gone last change stops lighting ⌥⌘O).
    mutating func forget(placeOf target: MCPShowTarget) {
        let place = Self.placeKey(target)
        entries.removeAll { $0.place == place }
    }

    mutating func clear() { entries = [] }

    private mutating func land(
        clientName: String, target: MCPShowTarget, title: String?, kind: Kind, act: Act, at now: Date, id: UUID
    ) {
        let place = Self.placeKey(target)
        if let index = entries.firstIndex(where: { $0.clientName == clientName && $0.place == place }) {
            var entry = entries.remove(at: index)
            entry.kind = kind
            entry.at = now
            entry.act = act
            entry.target = target
            if let title { entry.title = title }
            entry.count += 1
            entries.insert(entry, at: 0)
        } else {
            entries.insert(
                Entry(id: id, clientName: clientName, place: place, kind: kind, at: now, act: act,
                      target: target, title: title, count: 1),
                at: 0)
        }
        if entries.count > Self.cap { entries.removeLast(entries.count - Self.cap) }
    }

    // MARK: - The place

    /// What makes two acts ONE row: the note a note, takes, lens or Compare
    /// target opens (Compare by its anchor); a saved version (its own page); a
    /// book or gathering; a wing ('' is Home).
    static func placeKey(_ target: MCPShowTarget) -> String {
        switch target {
        case .note(let noteID, _, _), .takes(let noteID, _), .lens(let noteID, _), .compare(let noteID, _):
            "note:\(noteID)"
        case .version(_, let versionID): "version:\(versionID)"
        case .book(let bookID, _): "book:\(bookID)"
        case .wing(let wingID, _, _): "wing:\(wingID)"
        }
    }

    /// The landing's place's name, from what the receipt carried: its target's
    /// title where the receipt's target IS the landing's place; for the acts
    /// whose receipt is keyed elsewhere — a note or a book moved or copied to
    /// a wing (the receipt names the WING), a note added to a book (the receipt
    /// names the NOTE, its landing the book) — the name it carries as its
    /// detail; else nil (the row says the place's noun — never a second read).
    static func placeTitle(of receipt: MCPWriteReceipt) -> String? {
        guard let target = receipt.show else { return nil }
        switch receipt.act {
        case .wingMove, .wingCopy, .bookWingMove: return receipt.detail
        case .bookAdd: return Self.landingID(target) == receipt.targetID ? receipt.targetTitle : receipt.detail
        default: return Self.landingID(target) == receipt.targetID ? receipt.targetTitle : nil
        }
    }

    /// The id of the place a landing opens (for a version, its NOTE — the
    /// receipt's target is the note).
    private static func landingID(_ target: MCPShowTarget) -> String {
        switch target {
        case .note(let noteID, _, _), .takes(let noteID, _), .lens(let noteID, _), .compare(let noteID, _),
             .version(let noteID, _):
            noteID
        case .book(let bookID, _): bookID
        case .wing(let wingID, _, _): wingID
        }
    }
}

/// **The trail the door keeps** — the observable holder the section reads
/// (narrow, as `MCPAskBoard` is: only the section and the sidebar's fit read
/// it, so an AI write re-renders those faces and nothing else). Every write is
/// the door's (`MCPDoor`'s feeds and her presses).
@MainActor
@Observable
final class MCPTrailModel {
    private(set) var trail = MCPTrail()

    func update(_ body: (inout MCPTrail) -> Void) {
        var next = trail
        body(&next)
        if next != trail { trail = next }
    }
}
