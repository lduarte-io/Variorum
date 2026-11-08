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

        /// **VX-874 — a NAVIGATION ASK** (her "move me" requests): a client's
        /// ask to show her this place, offered and not yet followed — the row
        /// kind `shown`. Every other row is a NOTICE (a write — `edited`; an
        /// ask she took or that moved her — `opened`): her ruling (4)'s
        /// "notices off (write/opened rows hidden, a client's navigation asks
        /// still show)" is exactly this split.
        var isNavigationAsk: Bool { kind == .shown }
    }

    /// The most rows kept (PROVISIONAL P-809-14): bounded memory, ∝ nothing
    /// in the library.
    static let cap = 50

    /// Newest first — save where her hand reordered a stratum (`move`).
    private(set) var entries: [Entry] = []

    /// **VX-904 — the clients whose group she FOLDED** (her press on its
    /// header; her word: "maybe add ability to collapse a whole client group").
    /// Session memory like the rows (`clear` — the session's end and Clear All
    /// — forgets it), and a fold lives exactly as long as its group: a client
    /// whose last row goes is no longer folded, so a later act of its lands an
    /// open group. Its own act lands in a folded group FOLDED (PROVISIONAL —
    /// her fold is her gesture; the ask's bottom-bar offer road is untouched;
    /// the alternative, a new navigation ask unfolding its group, recorded).
    private(set) var folded: Set<String> = []

    /// One client's rows — a client's group (its header: `MCPTrailCopy.header`):
    /// its navigation asks first, then its notices, each in the trail's order.
    struct Group: Equatable, Identifiable, Sendable {
        var id: String { clientName }
        let clientName: String
        /// Every row the dial lets the group draw — what the header COUNTS,
        /// folded or not (VX-904: a folded group's count stays honest).
        let entries: [Entry]
        /// VX-904: folded — the group draws its header alone.
        var folded: Bool = false

        /// The rows the section DRAWS for this group (none while folded).
        var drawnEntries: [Entry] { folded ? [] : entries }
    }

    /// The rows by client, everything on (`groups(showing:)`).
    var groups: [Group] { groups(showing: .everything) }

    /// **VX-874 — THE SECTION'S LAYOUT under the dial** (her rulings (1), (3)'s
    /// one exception, (4)). Inside the ratified "From ‹client› · N" grouping,
    /// each group lists its NAVIGATION ASKS first, then its notices, each in
    /// the trail's order (newest first, save her hand's); groups holding a
    /// navigation ask come first (by their newest ask), then the rest (by their
    /// newest act) — so with one client every navigation ask sits at the very
    /// top of the section: "'move me' requests need to always go to the top of
    /// this pile". PROVISIONAL P-874-1: with two clients that BOTH hold asks,
    /// the second's asks sit under the first's notices (recorded for her walk).
    /// Notices off (`.asksOnly`) lists the navigation asks alone, and a group
    /// with none goes; fully off (`.off`) lists nothing. Pure: memory in, the
    /// layout out — nothing read.
    func groups(showing dial: MCPTrailDial) -> [Group] {
        guard dial.drawsSection else { return [] }
        var order: [String] = []
        var firstAsk: [String: Int] = [:]
        var asks: [String: [Entry]] = [:]
        var notices: [String: [Entry]] = [:]
        for (index, entry) in entries.enumerated() {
            if !order.contains(entry.clientName) { order.append(entry.clientName) }
            if entry.isNavigationAsk {
                if firstAsk[entry.clientName] == nil { firstAsk[entry.clientName] = index }
                asks[entry.clientName, default: []].append(entry)
            } else if dial.drawsNotices {
                notices[entry.clientName, default: []].append(entry)
            }
        }
        let asking = order.filter { firstAsk[$0] != nil }.sorted { (firstAsk[$0] ?? 0) < (firstAsk[$1] ?? 0) }
        let quiet = order.filter { firstAsk[$0] == nil }
        // VX-904: a fold changes what a group DRAWS, never where it stands —
        // an ask-holding folded group still leads (the ordering as built).
        return (asking + quiet).compactMap { client in
            let rows = (asks[client] ?? []) + (notices[client] ?? [])
            return rows.isEmpty ? nil : Group(clientName: client, entries: rows, folded: folded.contains(client))
        }
    }

    /// The rows the section draws under `dial` — the sidebar's fit test's
    /// count. VX-904: a folded group's rows are not drawn, so not counted (its
    /// header is — `groups(showing:).count`).
    func drawnRowCount(showing dial: MCPTrailDial) -> Int {
        groups(showing: dial).reduce(0) { $0 + $1.drawnEntries.count }
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
        letGoOfEmptyFolds()
    }

    /// Clear All and the session's end: every row goes, and every fold with
    /// its group (VX-904).
    mutating func clear() {
        entries = []
        folded = []
    }

    // MARK: - VX-904 — her fold

    /// **Her press on a group's header**: fold an open group, open a folded
    /// one. A client with no row has no group to fold — nothing changes.
    mutating func toggleFold(_ clientName: String) {
        if folded.contains(clientName) {
            folded.remove(clientName)
        } else if entries.contains(where: { $0.clientName == clientName }) {
            folded.insert(clientName)
        }
    }

    /// A fold lives as long as its group: a client with no row left is no
    /// longer folded.
    private mutating func letGoOfEmptyFolds() {
        guard !folded.isEmpty else { return }
        let clients = Set(entries.map(\.clientName))
        folded.formIntersection(clients)
    }

    // MARK: - Her hand (VX-874 — rulings (1)–(3))

    /// **Dismiss** (ruling (1): "be dismissable"; rail (b)): THE ROW goes and
    /// nothing else — a standing ask keeps its bottom-bar line and its doors,
    /// ⌥⌘O's last change stays. A newer act on the place lands a fresh row.
    mutating func dismiss(_ id: UUID) {
        entries.removeAll { $0.id == id }
        letGoOfEmptyFolds()
    }

    /// A hand drag's drop: before or after a row (the Open list's two halves,
    /// VX-424).
    enum Slot: Equatable, Sendable {
        case before(UUID)
        case after(UUID)

        var rowID: UUID {
            switch self {
            case .before(let id), .after(let id): id
            }
        }
    }

    /// **Where a drop would put the dragged row — nil when it would not act**
    /// (rail (a), PROVISIONAL P-874-3; the false-offer rule: a slot lights only
    /// where a drop would act). A row moves only among its own STRATUM — its
    /// client's rows of its own kind, navigation asks among asks, notices among
    /// notices — so the float is never violated and a row never leaves its
    /// group; a drop on its own slot (before or after itself, or the gap it
    /// already fills) changes nothing. The answer is the stratum's new order.
    func reordered(_ id: UUID, onto slot: Slot) -> [UUID]? {
        guard let dragged = entry(id), slot.rowID != id, let target = entry(slot.rowID),
              target.clientName == dragged.clientName, target.isNavigationAsk == dragged.isNavigationAsk
        else { return nil }
        let order = stratum(of: dragged).map { entries[$0].id }
        var rest = order.filter { $0 != id }
        guard let at = rest.firstIndex(of: slot.rowID) else { return nil }
        if case .after = slot { rest.insert(id, at: at + 1) } else { rest.insert(id, at: at) }
        return rest == order ? nil : rest
    }

    /// **The landing**: the stratum's rows take their new order IN PLACE — the
    /// positions the stratum holds in the trail are kept, so no other row, no
    /// other group and no other stratum moves. A newer act on a place still
    /// lifts its row to the top (the trail is newest-first; her hand's order
    /// holds among the rest). Returns whether anything moved.
    @discardableResult
    mutating func move(_ id: UUID, onto slot: Slot) -> Bool {
        guard let dragged = entry(id), let order = reordered(id, onto: slot) else { return false }
        let positions = stratum(of: dragged)
        var byID: [UUID: Entry] = [:]
        for position in positions { byID[entries[position].id] = entries[position] }
        for (position, rowID) in zip(positions, order) {
            guard let row = byID[rowID] else { return false }
            entries[position] = row
        }
        return true
    }

    /// The positions of `entry`'s stratum in the trail, in order.
    private func stratum(of entry: Entry) -> [Int] {
        entries.indices.filter {
            entries[$0].clientName == entry.clientName && entries[$0].isNavigationAsk == entry.isNavigationAsk
        }
    }

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
        if entries.count > Self.cap {
            entries.removeLast(entries.count - Self.cap)
            letGoOfEmptyFolds()  // VX-904: the cap can take a folded client's last row
        }
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
    /// a wing (the receipt names the WING), a note added to or taken out of a
    /// book (the receipt names the NOTE, its landing the book) — the name it
    /// carries as its detail; else nil (the row says the place's noun — never
    /// a second read).
    ///
    /// **VX-858 (the VX-878 run, batch 3): THE ONE BRAIN for both roads** —
    /// the trail's rows and the receipt road's gone/unfinished words
    /// (`MCPDoor.landReceipt`'s `ShownChange`) both read it, so neither ever
    /// names a place that is not the landing. The remove/release arms joined
    /// the book add's: their `detail` is the book's name, exactly its shape.
    static func placeTitle(of receipt: MCPWriteReceipt) -> String? {
        guard let target = receipt.show else { return nil }
        switch receipt.act {
        case .wingMove, .wingCopy, .bookWingMove: return receipt.detail
        case .bookAdd, .bookRemove, .bookRelease:
            return Self.landingID(target) == receipt.targetID ? receipt.targetTitle : receipt.detail
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
