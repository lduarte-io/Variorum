//
//  MCPTrailTests.swift
//  VariorumTests (Mac)
//
//  VX-679 (the VX-809 run, batch 5 — her R-679; the record
//  `notes/plans/fixes/vx-809-mcp-door-ergonomics.md`, BATCH 5 RECORD): THE
//  SIDEBAR'S AI SECTION — the session trail behind ⌥⌘O. A FEATURE (no
//  red-on-old owed): state pins on the pure trail, the door's feeds through
//  its REAL roads (`landReceipt`, `agentShow`, her take), the row's two doors
//  (the text through the existing landing roads, the place re-read first; the
//  symbol's details), the section's layout brain, and the registry's
//  declaration. ⌥⌘O's own behaviour is pinned UNCHANGED beside them.
//
//  Every read is bound before an assertion reads it (the VX-677 record's
//  F-B3-1 — no closure inside a testing macro in these nested closures).
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 679))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Polls `condition` on the main actor until it holds or `timeout` passes.
@MainActor
private func eventually(_ timeout: Duration = .seconds(3), _ condition: () async throws -> Bool) async rethrows -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while clock.now < deadline {
        if try await condition() { return true }
        try? await Task.sleep(for: .milliseconds(20))
    }
    return try await condition()
}

/// A door attached to `session`, one FULL window registered (her press's
/// `creationRouter`), standing where `standing` says.
@MainActor
private struct Rig {
    let door: MCPDoor
    let windows: WindowRegistry
    let router: ShellRouter

    init(_ session: AppSession, standing: MCPShowRule.Standing = .notFrontmost) {
        door = MCPDoor(serverAllowed: false)
        windows = WindowRegistry()
        router = ShellRouter()
        windows.register(UUID(), router: router, kind: .full)
        door.attach(session: session, windows: windows)
        let router = router
        door.standingProvider = { (standing, router) }
    }

    var entries: [MCPTrail.Entry] { door.trail.trail.entries }
}

private func receipt(
    _ act: Operations.MCPWriteAct = .take, client: String = "claude-code", note: String, title: String? = nil,
    show: MCPShowTarget? = nil
) -> MCPWriteReceipt {
    MCPWriteReceipt(
        clientName: client, act: act, targetID: note, targetTitle: title,
        show: show ?? .note(noteID: note, blockID: nil, select: nil))
}

private func noteTarget(_ id: String) -> MCPShowTarget { .note(noteID: id, blockID: nil, select: nil) }

private let at = Date(timeIntervalSince1970: 1_782_864_000)

// MARK: - The pure trail

@MainActor
@Suite("VX-679 — the trail behind ⌥⌘O, pure")
struct MCPTrailModelTests {
    /// A write WITH a landing is a row (`edited`); a write with none (a deleted
    /// note — no Open ›) names no place her press could open, so it leaves none.
    @Test func aWriteWithALandingIsARowAndOneWithoutIsNot() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1", title: "draft"), at: at)
        var deleted = receipt(.noteDelete, note: "n2", title: "gone")
        deleted.show = nil
        trail.record(write: deleted, at: at)
        #expect(trail.entries.count == 1)
        let row = trail.entries.first
        #expect(row?.kind == .edited && row?.title == "draft" && row?.place == "note:n1" && row?.count == 1)
        #expect(row?.target == noteTarget("n1"))
    }

    /// ONE ROW PER PLACE per client (PROVISIONAL P-809-14): a newer act on a
    /// place updates its row — kind, time, landing, the act — moves it to the
    /// top and counts; its id holds. A note's takes, lens and Compare landings
    /// are the note's place; a saved version and a book are their own.
    @Test func aNewerActOnAPlaceUpdatesItsRowAndMovesItToTheTop() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1", title: "draft"), at: at)
        trail.record(write: receipt(note: "n2", title: "other"), at: at.addingTimeInterval(1))
        let first = trail.entries.last?.id
        let later = receipt(.edit, note: "n1", title: "draft", show: .takes(noteID: "n1", blockID: "b1"))
        trail.record(write: later, at: at.addingTimeInterval(2))
        #expect(trail.entries.map(\.place) == ["note:n1", "note:n2"], "the updated row moved to the top")
        let row = trail.entries.first
        #expect(row?.id == first, "the row's identity holds")
        #expect(row?.count == 2 && row?.at == at.addingTimeInterval(2))
        #expect(row?.target == .takes(noteID: "n1", blockID: "b1"), "its landing is the newest act's")
        #expect(row?.act == .write(later))

        for target in [MCPShowTarget.lens(noteID: "n1", lensID: "l"), .compare(noteID: "n1", peerIDs: ["n9"])] {
            #expect(MCPTrail.placeKey(target) == "note:n1", "\(target) is the note's place")
        }
        #expect(MCPTrail.placeKey(.version(noteID: "n1", versionID: "v1")) == "version:v1")
        #expect(MCPTrail.placeKey(.book(bookID: "b", sectionID: "s")) == "book:b")
        #expect(MCPTrail.placeKey(.wing(wingID: "", name: "Home", shownBy: "x")) == "wing:")

        // An ask on the same place is the same row, its kind the newest act's.
        let ask = MCPShowRequest(target: noteTarget("n2"), clientName: "claude-code", title: "other", dial: .ask)
        trail.record(show: ask, opened: false, at: at.addingTimeInterval(3))
        #expect(trail.entries.count == 2 && trail.entries.first?.kind == .shown && trail.entries.first?.count == 2)
    }

    /// One group per client — "From ‹client› · N" — in the order of each
    /// client's newest act; another client's act on the same place is its own row.
    @Test func theRowsGroupByClientNewestFirst() {
        var trail = MCPTrail()
        trail.record(write: receipt(client: "claude-code", note: "n1"), at: at)
        trail.record(write: receipt(client: "codex", note: "n1"), at: at.addingTimeInterval(1))
        trail.record(write: receipt(client: "claude-code", note: "n2"), at: at.addingTimeInterval(2))
        let groups = trail.groups
        #expect(groups.map(\.clientName) == ["claude-code", "codex"])
        #expect(groups.first?.entries.map(\.place) == ["note:n2", "note:n1"])
        #expect(groups.last?.entries.map(\.place) == ["note:n1"], "another client's row of the same place")
        #expect(MCPTrailCopy.header(client: "claude-code", count: 2) == "From claude-code \u{00B7} 2",
                "her header, her words")
    }

    /// Bounded memory: past the cap the OLDEST place falls off.
    @Test func theTrailIsCapped() {
        var trail = MCPTrail()
        for index in 0 ..< (MCPTrail.cap + 5) {
            trail.record(write: receipt(note: "n\(index)"), at: at.addingTimeInterval(Double(index)))
        }
        #expect(trail.entries.count == MCPTrail.cap)
        #expect(trail.entries.first?.place == "note:n\(MCPTrail.cap + 4)")
        #expect(!trail.entries.contains { $0.place == "note:n0" }, "the oldest went")
    }

    /// Her take marks THAT ask's row `opened`; a row a newer act moved on from
    /// is left as it is. A gone place's rows go — every client's.
    @Test func herTakeMarksTheAsksRowAndAGonePlaceLetsItsRowsGo() {
        var trail = MCPTrail()
        let ask = MCPShowRequest(target: noteTarget("n1"), clientName: "claude-code", title: "draft", dial: .ask)
        trail.record(show: ask, opened: false, at: at)
        #expect(trail.entries.first?.kind == .shown)
        trail.markOpened(ask)
        #expect(trail.entries.first?.kind == .opened)

        let older = MCPShowRequest(target: noteTarget("n2"), clientName: "claude-code", title: "x", dial: .ask)
        trail.record(show: older, opened: false, at: at)
        trail.record(write: receipt(note: "n2"), at: at.addingTimeInterval(1))
        trail.markOpened(older)
        #expect(trail.entries.first?.kind == .edited, "a row a newer act moved on from keeps its kind")

        trail.record(write: receipt(client: "codex", note: "n1"), at: at.addingTimeInterval(2))
        trail.forget(placeOf: .takes(noteID: "n1", blockID: "b"))
        #expect(trail.entries.map(\.place) == ["note:n2"], "every client's row of the gone place went")
        trail.clear()
        #expect(trail.isEmpty)
    }

    /// The row names the LANDING's place from what the receipt carried — the
    /// acts whose receipt is keyed elsewhere name it by their detail; a
    /// landing the receipt carries no name for says the place's noun.
    @Test func theRowNamesTheLandingsPlace() {
        var move = MCPWriteReceipt(
            clientName: "c", act: .wingMove, targetID: "w1", targetTitle: "Studio", detail: "draft",
            show: noteTarget("n1"))
        #expect(MCPTrail.placeTitle(of: move) == "draft", "a moved note, never the wing's name")
        move = MCPWriteReceipt(
            clientName: "c", act: .bookWingMove, targetID: "w1", targetTitle: "Studio", detail: "the book",
            show: .book(bookID: "b1", sectionID: nil))
        #expect(MCPTrail.placeTitle(of: move) == "the book")
        let add = MCPWriteReceipt(
            clientName: "c", act: .bookAdd, targetID: "n1", targetTitle: "draft", detail: "the book",
            show: .book(bookID: "b1", sectionID: nil))
        #expect(MCPTrail.placeTitle(of: add) == "the book", "the landing is the book")
        let chapter = MCPWriteReceipt(
            clientName: "c", act: .chapter, targetID: "b1", targetTitle: nil, detail: "one",
            show: .book(bookID: "b1", sectionID: "s1"))
        #expect(MCPTrail.placeTitle(of: chapter) == nil)
        #expect(MCPTrailCopy.place(.book(bookID: "b1", sectionID: "s1"), title: nil) == "a book", "its noun")
        let moved = MCPWriteReceipt(
            clientName: "c", act: .move, targetID: "n1", targetTitle: "source", show: noteTarget("n2"))
        #expect(MCPTrail.placeTitle(of: moved) == nil, "a block moved into another note: not the source's name")
        #expect(MCPTrailCopy.place(.wing(wingID: "", name: "Home", shownBy: "c"), title: nil) == "Home")
        #expect(MCPTrailCopy.place(.version(noteID: "n", versionID: "v"), title: "draft") == "a saved version of draft")
    }

    /// The row's line and the details popover say what R-679 names: the kind
    /// (her three words) and when; the client, when it came in, a navigation
    /// ask or a write and which operation (the receipt's own words), the target.
    @Test func theRowAndTheDetailsSayWhatTheRulingNames() throws {
        #expect([MCPTrail.Kind.shown, .opened, .edited].map(MCPTrailCopy.kind) == ["shown", "opened", "edited"])
        var trail = MCPTrail()
        trail.record(write: receipt(.edit, note: "n1", title: "draft"), at: at)
        let write = try #require(trail.entries.first)
        #expect(MCPTrailCopy.detail(write, now: at) == "edited \u{00B7} \(MCPTrailCopy.when(at, now: at))")
        let writeLines = MCPTrailDetails.lines(write, now: at)
        #expect(writeLines == [
            "Came in at \(MCPTrailCopy.when(at, now: at))",
            "A write: it edited a take.",
            "Target: the note \u{201C}draft\u{201D}",
        ])
        let ask = MCPShowRequest(
            target: .book(bookID: "b1", sectionID: nil), clientName: "claude-code", title: "lessons", dial: .ask)
        trail.record(show: ask, opened: false, at: at)
        let shown = try #require(trail.entries.first)
        #expect(MCPTrailDetails.lines(shown, now: at) == [
            "Came in at \(MCPTrailCopy.when(at, now: at))",
            "A navigation ask: it asked to show you \u{201C}lessons\u{201D}.",
            "Target: the book \u{201C}lessons\u{201D}",
            "Offered to you; not opened yet.",
        ])
        trail.record(write: receipt(.edit, note: "n1", title: "draft"), at: at)
        #expect(MCPTrailDetails.lines(try #require(trail.entries.first), now: at).last
                == "The newest of 2 requests here this session.")
        let tomorrow = at.addingTimeInterval(86_400 * 2)
        #expect(MCPTrailCopy.when(at, now: tomorrow) != MCPTrailCopy.when(at, now: at), "another day says its day")
    }

    /// The section's layout brain: about three rows, then scrolling within;
    /// the column's fit test counts it as one more headed group, capped at the
    /// window (an extra row scrolls inside, it never compresses the column).
    @Test func theSectionHoldsAboutThreeRowsThenScrolls() {
        let pitch = SidebarLayout.generousRowHeight
        #expect(SidebarLayout.aiSectionWindow == 3)
        #expect(SidebarLayout.aiSectionMaxHeight(rowHeight: pitch) == SidebarLayout.groupHeaderHeight + pitch * 3.5)
        #expect(SidebarLayout.aiSectionFits(headers: 1, rows: 3, rowHeight: pitch), "three rows hug")
        #expect(!SidebarLayout.aiSectionFits(headers: 1, rows: 4, rowHeight: pitch), "a fourth scrolls within")
        #expect(SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 0, aiSection: 9)
                == SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 0) + 3)
        #expect(SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 0, aiSection: 0)
                == SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 0), "none ⇒ the column as it was")
    }

    /// P-1: the row's two doors are declared once, and the section is their
    /// only renderer (the registry walk's union carries its line).
    @Test func theRowsTwoDoorsAreDeclaredOnce() {
        #expect(MCPTrailSection.surfaceCapabilities == [.mcpOpenTrailPlace, .mcpShowTrailDetails])
        for id in MCPTrailSection.surfaceCapabilities {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.surface] && capability.scope == .app, "\(id)")
        }
        #expect(CapabilityRegistry.capability(.mcpOpenTrailPlace).verb == MCPTrailCopy.openVerb)
        #expect(CapabilityRegistry.capability(.mcpShowTrailDetails).verb == MCPTrailCopy.detailsVerb)
    }
}

// MARK: - The door's feeds and her presses

@MainActor
@Suite("VX-679 — the trail's feeds and the row's doors, through the door's real roads", .serialized)
struct MCPTrailDoorTests {
    /// A landed write with a landing is a row — and ⌥⌘O is BYTE-UNCHANGED: it
    /// still opens the LAST change, never the list behind it.
    @Test func aLandedWriteIsARowAndCommandOptionOStillOpensTheLastChange() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let first = try session.operations.createPost(title: "first")
            let second = try session.operations.createPost(title: "second")
            let rig = Rig(session)
            defer { rig.door.detach() }
            rig.door.landReceipt(receipt(note: first.id, title: "first"))
            rig.door.landReceipt(receipt(client: "codex", note: second.id, title: "second"))
            var deleted = receipt(.noteDelete, note: "dead", title: "dead")
            deleted.show = nil
            rig.door.landReceipt(deleted)
            let places = rig.entries.map(\.place)
            #expect(places == ["note:\(second.id)", "note:\(first.id)"], "two rows, the delete none")
            #expect(rig.door.lastShow == noteTarget(second.id), "⌥⌘O's last change is the last WITH a landing")

            // Her press on the OLDER row goes there — and ⌥⌘O's last change holds.
            let older = try #require(rig.entries.last?.id)
            rig.door.openTrailEntry(older)
            let opened = await eventually { rig.router.workspace.focusedSelection == .post(first.id) }
            let quiet = session.status.current?.kind != .refusal
            let stillLast = rig.door.lastShow == noteTarget(second.id)
            #expect(opened, "the row's text went there — the receipt's Open › road")
            #expect(quiet, "nothing refused")
            #expect(stillLast, "⌥⌘O still names the LAST change")
            rig.door.showLastChange()
            let last = await eventually { rig.router.workspace.focusedSelection == .post(second.id) }
            #expect(last, "⌥⌘O opens the last change, as before")
        }
    }

    /// `show_in_app`: an OFFERED ask is a row, `shown`, and stays one after the
    /// ask ends; moved at once, `opened`; under never, no row (nothing shown or
    /// offered). Her take marks it `opened`.
    @Test func showAsksAreRowsByWhatHappenedToThem() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let book = try session.operations.createReading(name: "lessons", kind: .book)
            let rig = Rig(session)
            defer { rig.door.detach() }
            let ask = MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask, activityKind: "book", activityID: book.id)
            _ = await rig.door.agentShow(ask)
            #expect(rig.entries.first?.kind == .shown && rig.entries.first?.act == .show(ask))
            session.status.clear()
            let take = try #require(session.status.lineItem?.action)
            take.perform()
            let opened = await eventually { rig.door.trail.trail.entries.first?.kind == .opened }
            #expect(opened, "her take marks the ask's row opened")

            let never = MCPShowRequest(
                target: noteTarget("whatever"), clientName: "claude-code", title: "x", dial: .never)
            _ = await rig.door.agentShow(never)
            #expect(rig.entries.count == 1, "the never dial shows and offers nothing — no row")
        }
    }

    /// Moved at once while she is at the app in a full window: the place
    /// opened in front of her — its row reads `opened`.
    @Test func aMoveAtOnceIsAnOpenedRow() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let book = try session.operations.createReading(name: "moved", kind: .book)
            let rig = Rig(session, standing: .frontmostMainWindow)
            defer { rig.door.detach() }
            let verdict = await rig.door.agentShow(MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "moved",
                dial: .moveAtOnce))
            #expect(verdict == .navigate)
            #expect(rig.entries.first?.kind == .opened && rig.entries.first?.title == "moved")
        }
    }

    /// The row of an ask that NO LONGER STANDS (dismissed) lands exactly where
    /// the offer would have — the take's road: it opens, the take is logged,
    /// the row reads `opened`. While the ask STANDS, the row IS her take of it.
    @Test func anAsksRowLandsWhereTheOfferWouldHave() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let book = try session.operations.createReading(name: "lessons", kind: .book)
            let rig = Rig(session)
            defer { rig.door.detach() }
            let ask = MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask, activityKind: "book", activityID: book.id)
            _ = await rig.door.agentShow(ask)
            let row = try #require(rig.entries.first?.id)

            // While it stands: the row is her take — the ask ends.
            rig.door.openTrailEntry(row)
            let tookStanding = await eventually { rig.router.workspace.focusedSelection == .reading(book.id) }
            let ended = rig.door.showOffer == nil && session.status.standing == nil
            #expect(tookStanding, "the standing ask, taken from its row")
            #expect(ended, "taken: the ask is over")

            // Once it no longer stands: the take's road without the ask.
            rig.router.adopt(.library)
            rig.door.openTrailEntry(row)
            let landed = await eventually { rig.router.workspace.focusedSelection == .reading(book.id) }
            let takes = await eventually {
                let rows = (try? await db.read { try Queries.mcpActivity($0) }) ?? []
                return rows.filter { $0.act == MCPShowActivity.takenAct }.count == 2
            }
            let kind = rig.entries.first?.kind
            let quiet = session.status.current?.kind != .refusal
            #expect(landed, "it lands exactly where the offer would have")
            #expect(takes, "each press is logged as her take of that ask")
            #expect(kind == .opened)
            #expect(quiet, "nothing refused")
        }
    }

    /// THE RE-READ-THE-PLACE RULE: a row whose place is GONE says so where she
    /// pressed, opens nothing, logs no take — and the row goes (a dead door).
    @Test func aRowWhosePlaceIsGoneSaysSoOpensNothingAndGoes() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let written = try session.operations.createPost(title: "gone change")
            let asked = try session.operations.createPost(title: "gone ask")
            let rig = Rig(session)
            defer { rig.door.detach() }
            let resting = rig.router.workspace.focusedSelection
            rig.door.landReceipt(receipt(note: written.id, title: "gone change"))
            let ask = MCPShowRequest(
                target: noteTarget(asked.id), clientName: "codex", title: "gone ask", dial: .ask,
                activityKind: "note", activityID: asked.id)
            _ = await rig.door.agentShow(ask)
            rig.door.dismissShowOffer(try #require(rig.door.showOffer?.itemID))  // her ✕: the ask ends
            session.status.clear()
            try session.operations.deleteContainer(written.id)
            try session.operations.deleteContainer(asked.id)

            let writeRow = try #require(rig.entries.first { $0.place == "note:\(written.id)" }?.id)
            rig.door.openTrailEntry(writeRow)
            let writeRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            let writeWords = session.status.current?.text ?? "nothing"
            #expect(writeRefused && writeWords == "\u{201C}gone change\u{201D} is gone, so claude-code's change can't be opened.",
                    "said where she pressed: \(writeWords)")
            session.status.clear()

            let askRow = try #require(rig.entries.first { $0.place == "note:\(asked.id)" }?.id)
            rig.door.openTrailEntry(askRow)
            let askRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            try? await Task.sleep(for: .milliseconds(150))  // past any delivery and log
            let askWords = session.status.current?.text ?? "nothing"
            #expect(askRefused && askWords == "\u{201C}gone ask\u{201D} is gone, so codex's ask was let go.",
                    "said where she pressed: \(askWords)")
            let selection = rig.router.workspace.focusedSelection
            let rows = try await db.read { try Queries.mcpActivity($0) }
            let takeRows = rows.filter { $0.act == MCPShowActivity.takenAct }.count
            let empty = rig.door.trail.trail.isEmpty
            #expect(selection == resting, "nothing opened")
            #expect(takeRows == 0, "no take logged for a place that is gone")
            #expect(empty, "both rows went with their places")
        }
    }

    /// Session-scoped: the trail goes where ⌥⌘O's last change goes — the lock,
    /// the library closing, the quit (`letGoOfTheSession`).
    @Test func theTrailIsSessionScoped() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "draft")
            let rig = Rig(session)
            rig.door.landReceipt(receipt(note: post.id, title: "draft"))
            #expect(!rig.door.trail.trail.isEmpty)
            rig.door.detach()
            #expect(rig.door.trail.trail.isEmpty && rig.door.lastShow == nil, "gone with the last change")
        }
    }
}
