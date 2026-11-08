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
        // VX-902 (A JUSTIFIED EDIT, the ritual — the VX-914 run, batch 1): her #264
        // word supersedes R-679's "From ‹client› · N" — the setup menu's label for
        // a client its table names ("claude-code" is Claude Code's tab's name).
        #expect(MCPTrailCopy.header(client: "claude-code", count: 2)
                    == "From \(MCPSetupClient.claudeCode.label) \u{00B7} 2",
                "her header, her words (VX-902)")
    }

    /// **VX-902 — the heading never says the client's raw name** (her #264
    /// word: "I don't like the From random name"; PROVISIONAL F-902 (a)+(w1)+(i)):
    /// "From ‹provider› · N" where the setup menu's OWN table names the client
    /// (the fenced labels, read — never a new literal, O-4), else "MCP · N".
    /// The client's own name stays everywhere it was: the row's helps, the
    /// details popover (its first line), the header's hover; two clients that
    /// both read MCP keep two groups (per client underneath — VX-904 folds a
    /// client's), told apart by the hover.
    @Test func theHeadingNamesTheProviderWhereTheSetupMenuDoesElseMCP() throws {
        // Her own example, verbatim in shape: "from claude" / "from codex".
        #expect(MCPTrailCopy.header(client: "claude-code", count: 3) == "From Claude Code \u{00B7} 3")
        #expect(MCPTrailCopy.header(client: "codex-mcp-client", count: 1) == "From Codex \u{00B7} 1")
        #expect(MCPTrailCopy.provider(of: "claude-code") == MCPSetupClient.claudeCode.label)
        #expect(MCPTrailCopy.provider(of: "codex-mcp-client") == MCPSetupClient.codex.label)
        // "or just mcp": her dev client that night, and any other name.
        for name in ["variorum-de", "cursor", "Claude-Code", "claude-code ", "", "codex"] {
            let heading = MCPTrailCopy.header(client: name, count: 2)
            #expect(heading == "MCP \u{00B7} 2", "“\(name)” names no setup — MCP (got “\(heading)”)")
            if !name.isEmpty { #expect(!heading.contains(name), "never the raw name: \(heading)") }
        }
        #expect(MCPTrailCopy.provider(of: "anything") == nil)
        #expect(MCPSetupClient.anyClient.expectedName == nil, "“Any MCP client” names nobody")

        // Two clients that both read MCP: two groups, one per client, both "MCP · N".
        var trail = MCPTrail()
        trail.record(write: receipt(client: "variorum-de", note: "n1"), at: at)
        trail.record(write: receipt(client: "cursor", note: "n2"), at: at.addingTimeInterval(1))
        let groups = trail.groups(showing: .everything)
        #expect(groups.map(\.clientName) == ["cursor", "variorum-de"], "groups stay per client underneath")
        #expect(groups.map { MCPTrailCopy.header(client: $0.clientName, count: $0.entries.count) }
                    == ["MCP \u{00B7} 1", "MCP \u{00B7} 1"])
        let hovers = groups.map { MCPTrailCopy.foldHelp(client: $0.clientName, folded: false) }
        #expect(hovers == ["Fold cursor\u{2019}s rows", "Fold variorum-de\u{2019}s rows"],
                "the header's hover tells two MCP groups apart")

        // The client's own name stays where it was (UNCHANGED by VX-902).
        let row = try #require(trail.entries.first { $0.clientName == "variorum-de" })
        #expect(MCPTrailCopy.openHelp(row).contains("variorum-de"))
        #expect(MCPTrailCopy.detailsHelp(row) == "What variorum-de asked or did here")
        let app = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let section = try String(
            contentsOf: app.appendingPathComponent("Variorum/Features/MCP/MCPTrailSection.swift"), encoding: .utf8)
        let details = try #require(section.range(of: "struct MCPTrailDetails: View {"))
        #expect(section[details.upperBound...].contains("Text(entry.clientName)"), "the popover names the real client")
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

// MARK: - VX-874 — the trail grows up (the VX-878 run, batch 3)

/// A shown ask on `note` from `client` (the trail's own feed).
private func ask(_ note: String, client: String = "claude-code", title: String? = nil) -> MCPShowRequest {
    MCPShowRequest(target: noteTarget(note), clientName: client, title: title ?? note, dial: .ask)
}

/// **VX-874 — her rulings (1)–(4), the pure trail** (the record
/// `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD). A FEATURE
/// on the ratified baseline (QUESTIONS #262 — one row per client × place, cap
/// 50, rows survive a Deny): state pins, no red-on-old owed.
@MainActor
@Suite("VX-874 — navigation asks float, rows dismiss, a hand drag stays in its stratum, the dial filters")
struct MCPTrailHandModelTests {
    /// Ruling (1): "'move me' requests need to always go to the top of this
    /// pile". A navigation ask is a `shown` row; each group lists its asks
    /// first, and a group holding one leads the section.
    @Test func navigationAsksFloatAboveNoticesAndTheirGroupLeads() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(write: receipt(client: "codex", note: "n2"), at: at.addingTimeInterval(1))
        trail.record(show: ask("n3", client: "codex"), opened: false, at: at.addingTimeInterval(2))
        trail.record(write: receipt(note: "n4"), at: at.addingTimeInterval(3))
        // claude-code acted last, but codex holds the ask: codex leads, its ask first.
        let groups = trail.groups(showing: .everything)
        #expect(groups.map(\.clientName) == ["codex", "claude-code"])
        #expect(groups.first?.entries.map(\.place) == ["note:n3", "note:n2"])
        #expect(groups.last?.entries.map(\.place) == ["note:n4", "note:n1"])
        #expect(trail.entries.first(where: { $0.place == "note:n3" })?.isNavigationAsk == true)
        #expect(trail.entries.first(where: { $0.place == "note:n4" })?.isNavigationAsk == false)

        // Inside a group the float holds too, and the newest ask leads.
        trail.record(show: ask("n5"), opened: false, at: at.addingTimeInterval(4))
        let again = trail.groups(showing: .everything)
        #expect(again.map(\.clientName) == ["claude-code", "codex"], "the group with the newest ask leads")
        #expect(again.first?.entries.map(\.place) == ["note:n5", "note:n4", "note:n1"])
        #expect(trail.groups == again, "`groups` is everything on")

        // Followed, an ask is a notice: it sinks below the asks.
        trail.markOpened(ask("n5"))
        #expect(trail.groups(showing: .everything).first?.clientName == "codex")
        #expect(trail.groups(showing: .everything).last?.entries.map(\.place) == ["note:n5", "note:n4", "note:n1"])
    }

    /// Ruling (4): notices off draws a client's navigation asks alone (a group
    /// with none goes); fully off draws nothing. The trail keeps RECORDING
    /// under every value — the dial filters what is drawn.
    @Test func theDialFiltersWhatIsDrawnAndTheTrailKeepsRecording() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(show: ask("n2", client: "codex"), opened: false, at: at.addingTimeInterval(1))
        trail.record(show: ask("n3", client: "codex"), opened: true, at: at.addingTimeInterval(2))
        #expect(trail.drawnRowCount(showing: .everything) == 3)
        let asks = trail.groups(showing: .asksOnly)
        #expect(asks.map(\.clientName) == ["codex"], "a group with no ask goes")
        #expect(asks.first?.entries.map(\.place) == ["note:n2"], "an opened ask is a notice")
        #expect(trail.drawnRowCount(showing: .asksOnly) == 1)
        #expect(trail.groups(showing: .off).isEmpty && trail.drawnRowCount(showing: .off) == 0)
        #expect(trail.entries.count == 3, "nothing forgotten — turning notices back on shows them")
    }

    /// Ruling (1) + rail (b): dismiss takes THE ROW and nothing else; a newer
    /// act on the place lands a fresh row (a dismissed place is not blocked).
    @Test func dismissTakesTheRowOnly() throws {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(show: ask("n2"), opened: false, at: at.addingTimeInterval(1))
        let row = try #require(trail.entries.first { $0.place == "note:n2" })
        trail.dismiss(row.id)
        #expect(trail.entries.map(\.place) == ["note:n1"])
        trail.record(show: ask("n2"), opened: false, at: at.addingTimeInterval(2))
        #expect(trail.entries.map(\.place) == ["note:n2", "note:n1"], "a newer ask lands a fresh row")
        #expect(trail.entries.first?.count == 1)
    }

    /// Rail (a) — PROVISIONAL P-874-3: a row moves only among its own stratum
    /// (its client's rows of its kind); a drop on its own slot, onto another
    /// client's row or across the float acts on nothing. A landing permutes the
    /// stratum IN PLACE (no other row moves), and a newer act still lifts its row.
    @Test func aHandMoveStaysInsideItsStratum() throws {
        var trail = MCPTrail()
        for (index, note) in ["n1", "n2", "n3"].enumerated() {
            trail.record(write: receipt(note: note), at: at.addingTimeInterval(Double(index)))
        }
        trail.record(write: receipt(client: "codex", note: "x1"), at: at.addingTimeInterval(3))
        trail.record(show: ask("a1"), opened: false, at: at.addingTimeInterval(4))
        let id = { (place: String) in trail.entries.first { $0.place == "note:\(place)" }?.id ?? UUID() }
        let (n1, n2, n3, x1, a1) = (id("n1"), id("n2"), id("n3"), id("x1"), id("a1"))
        // Notices newest first: n3, n2, n1.
        #expect(trail.reordered(n3, onto: .before(n3)) == nil, "its own slot")
        #expect(trail.reordered(n3, onto: .after(n3)) == nil, "its own slot")
        #expect(trail.reordered(n3, onto: .before(n2)) == nil, "the gap it already fills")
        #expect(trail.reordered(n2, onto: .after(n3)) == nil, "the gap it already fills")
        #expect(trail.reordered(n3, onto: .before(x1)) == nil, "another client's row")
        #expect(trail.reordered(n3, onto: .after(a1)) == nil, "across the float — an ask")
        #expect(trail.reordered(a1, onto: .before(n3)) == nil, "an ask never sinks among notices")
        #expect(trail.reordered(UUID(), onto: .before(n3)) == nil)
        #expect(trail.reordered(n3, onto: .after(n1)) == [n2, n1, n3])

        let before = trail.entries.map(\.id)
        let landed = trail.move(n3, onto: .after(n1))  // hoisted: #expect can't call a mutating member
        #expect(landed)
        let after = trail.entries.map(\.id)
        let others = before.filter { ![n1, n2, n3].contains($0) }
        #expect(others.allSatisfy { before.firstIndex(of: $0) == after.firstIndex(of: $0) }, "no other row moved")
        #expect(trail.groups(showing: .everything).map(\.clientName) == ["claude-code", "codex"])
        #expect(trail.groups(showing: .everything).first?.entries.map(\.id) == [a1, n2, n1, n3])
        let crossed = trail.move(n3, onto: .before(x1))
        #expect(!crossed, "a drop that would not act moves nothing")

        trail.record(write: receipt(note: "n3"), at: at.addingTimeInterval(5))
        #expect(trail.groups(showing: .everything).first?.entries.map(\.id) == [a1, n3, n2, n1],
                "a newer act on a place still lifts its row to the top of its stratum")
    }

    /// The slot line lights only where a drop would act (the false-offer
    /// rule), on the row's top for the slot before it and its bottom for the
    /// slot after; a drag of another section's never lands here.
    @Test func theSlotLineAndTheDropActOnlyWhereTheDropWould() throws {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(write: receipt(note: "n2"), at: at.addingTimeInterval(1))
        let n2 = try #require(trail.entries.first?.id)
        let n1 = try #require(trail.entries.last?.id)
        let drag = MCPTrailDragState()
        #expect(!drag.inFlight(in: trail))
        drag.began(n2)
        #expect(drag.inFlight(in: trail))
        drag.targeted(.after(n1), true)
        #expect(drag.lineEdge(on: n1, in: trail) == .bottom)
        #expect(drag.lineEdge(on: n2, in: trail) == nil)
        drag.targeted(.before(n1), true)
        #expect(drag.lineEdge(on: n1, in: trail) == nil, "the gap it already fills: no line")
        drag.targeted(.before(n1), false)
        #expect(drag.target == nil)
        drag.ended()
        #expect(drag.dragging == nil && !drag.inFlight(in: trail))
    }

    /// P-1: her hand's doors are declared once — the ✕ on the section's surface
    /// list, the right-clicks on its context list — and the guide's "the row's
    /// text and its icon are its two doors" list is unchanged.
    @Test func theHandsDoorsAreDeclaredOnce() {
        #expect(MCPTrailSection.surfaceCapabilities == [.mcpOpenTrailPlace, .mcpShowTrailDetails])
        #expect(MCPTrailSection.rowManageCapabilities == [.mcpDismissTrailEntry])
        #expect(MCPTrailSection.contextMenuCapabilities == [.mcpDismissTrailEntry, .mcpClearTrail, .mcpSetTrailDial])
        let dismiss = CapabilityRegistry.capability(.mcpDismissTrailEntry)
        #expect(dismiss.doors == [.surface, .contextMenu] && dismiss.verb == "Dismiss" && dismiss.scope == .app)
        let clear = CapabilityRegistry.capability(.mcpClearTrail)
        #expect(clear.doors == [.contextMenu] && clear.verb == "Clear All" && clear.scope == .app)
        let dial = CapabilityRegistry.capability(.mcpSetTrailDial)
        #expect(dial.doors == [.contextMenu] && dial.verb == MCPPaneCopy.trailDialTitle)
    }

    /// The face, read from its source (a context menu and a drag cannot be
    /// mounted headlessly): every row draws its ✕ BEFORE the symbol (the symbol
    /// stays at the row's END — the guide's "the icon at its end"), its
    /// right-click Dismiss and Clear All, its drag and its two halves; every
    /// header its Clear All and the dial's twin; the section draws what the
    /// dial lets it; the sidebar's fit counts the same.
    @Test func theFaceRendersItsDeclaredDoors() throws {
        let app = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let section = try String(
            contentsOf: app.appendingPathComponent("Variorum/Features/MCP/MCPTrailSection.swift"), encoding: .utf8)
        let rowStart = try #require(section.range(of: "private struct MCPTrailRow"))
        let row = String(section[rowStart.upperBound...])
        let cross = try #require(row.range(of: "Button(\"\\u{2715}\")"))
        let symbol = try #require(row.range(of: "Image(systemName: MCPSharedIcon.symbol)"))
        #expect(cross.lowerBound < symbol.lowerBound, "the ✕ sits before the symbol, which ends the row")
        for door in ["CapabilityRegistry.capability(.mcpDismissTrailEntry).verb",
                     "CapabilityRegistry.capability(.mcpClearTrail).verb", ".draggable(beginDrag())",
                     ".dropDestination(for: MCPTrailDragToken.self)"] {
            #expect(row.contains(door), "the row renders \(door)")
        }
        let header = try #require(section.range(of: "private func header("))
        let headerBody = String(section[header.upperBound..<rowStart.lowerBound])
        #expect(headerBody.contains("CapabilityRegistry.capability(.mcpClearTrail).verb"))
        #expect(headerBody.contains("CapabilityRegistry.capability(.mcpSetTrailDial).verb"))
        #expect(section.contains("trail.groups(showing: door.trailDial)"), "the section draws what the dial lets it")
        let root = try String(contentsOf: app.appendingPathComponent("Variorum/RootView.swift"), encoding: .utf8)
        #expect(root.contains("drawnRowCount(showing: mcp.trailDial)") && root.contains("groups(showing: mcp.trailDial)"),
                "the sidebar's fit counts what the section draws")
    }
}

/// **VX-874 — her hand through the door's REAL roads**, and the dial read
/// where the section composes; the ask's bottom-bar offer road is pinned
/// UNTOUCHED by every value.
@MainActor
@Suite("VX-874 — dismiss, Clear All and the dial through the door's real roads", .serialized)
struct MCPTrailHandDoorTests {
    /// Rail (b): dismissing an ASK's row removes the row only — the standing
    /// ask keeps its bottom-bar line and ⌥⌘O still takes it; a write's row
    /// dismissed leaves ⌥⌘O's last change.
    @Test func dismissingAnAsksRowLeavesTheStandingAskAlone() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let book = try session.operations.createReading(name: "lessons", kind: .book)
            let post = try session.operations.createPost(title: "draft")
            let rig = Rig(session)
            defer { rig.door.detach() }
            rig.door.landReceipt(receipt(note: post.id, title: "draft"))
            let request = MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask, activityKind: "book", activityID: book.id)
            _ = await rig.door.agentShow(request)
            let askRow = try #require(rig.entries.first { $0.place == "book:\(book.id)" }?.id)
            let writeRow = try #require(rig.entries.first { $0.place == "note:\(post.id)" }?.id)

            rig.door.dismissTrailEntry(askRow)
            let stands = rig.door.showOffer?.request == request && session.status.standing != nil
            #expect(stands, "the ask still stands on its line")
            #expect(rig.entries.map(\.id) == [writeRow], "only the row went")
            rig.door.dismissTrailEntry(writeRow)
            #expect(rig.door.trail.trail.isEmpty)
            #expect(rig.door.lastShow == noteTarget(post.id), "⌥⌘O's last change stays")

            rig.door.showLastChange()  // ⌥⌘O takes the standing ask first, as ever
            let took = await eventually { rig.router.workspace.focusedSelection == .reading(book.id) }
            #expect(took, "the ask's own road, untouched")
        }
    }

    /// Ruling (2): Clear All takes every row — every client's — and nothing else.
    @Test func clearAllTakesEveryRowAndNothingElse() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "draft")
            let book = try session.operations.createReading(name: "lessons", kind: .book)
            let rig = Rig(session)
            defer { rig.door.detach() }
            rig.door.landReceipt(receipt(note: post.id, title: "draft"))
            rig.door.landReceipt(receipt(client: "codex", note: post.id, title: "draft"))
            _ = await rig.door.agentShow(MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask))
            #expect(rig.entries.count == 3)
            rig.door.clearTrail()
            #expect(rig.door.trail.trail.isEmpty)
            #expect(rig.door.showOffer != nil && session.status.standing != nil, "the standing ask stays")
            #expect(rig.door.lastShow == noteTarget(post.id), "⌥⌘O's last change stays")
        }
    }

    /// Ruling (4): the dial lives in the store (one local-only row), the door
    /// holds it as the section reads it, and under FULLY OFF the section draws
    /// nothing while a client's ask STILL lands as its one-press bottom-bar
    /// offer (the separate road, untouched) and the trail still records it;
    /// notices off draws the ask alone.
    ///
    /// **THE WINDOW'S RED, RE-SEEDED (A JUSTIFIED EDIT — the batch 3 record's
    /// "THE CLOSING WINDOW'S TWO REDS, TRACED", red 2):** the first run went red
    /// at the second `standing` check because the rig's server switch was OFF
    /// with no connection — every snapshot's `reconcileServer()` then runs its
    /// OFF arm (`stopServer` → `adoptConnected([])`) and VX-676's disconnect
    /// rule ends any standing ask: the dial's write re-landed the snapshot, the
    /// HARNESS ended the ask. In the app an ask stands only while its client is
    /// connected over a running host, where reconcile returns before touching
    /// the connected set. So the house fixture for exactly this trap
    /// (`MCPShowOfferFacesTests.afterTheToastFadesTheAskHoldsTheQuietLine`): the
    /// switch ON, the first snapshot heard, the asking client connected — and
    /// the claim is tested as worded, the SAME ask standing across both dial
    /// writes. Assertions unchanged, plus the same-ask check.
    @Test func theDialFiltersTheSectionAndTheOfferRoadIsUntouched() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "draft")
            let book = try session.operations.createReading(name: "lessons", kind: .book)
            try session.operations.setMCPSwitch(.server, on: true)
            let rig = Rig(session)
            defer { rig.door.detach() }
            let heard = await eventually { rig.door.snapshot.enabled }
            try #require(heard, "fixture: the door adopted its first snapshot — the server ON")
            rig.door.previewConnected(["claude-code"])  // the asking client, as the host would report it
            let seenDefault = await eventually { rig.door.snapshot.trailDial == .everything }
            #expect(seenDefault && rig.door.trailDial == .everything, "everything on, the default")

            rig.door.setTrailDial(.off)
            let off = await eventually { rig.door.trailDial == .off }
            let stored = try await db.read { try Queries.mcpTrailDial($0) }
            #expect(off && stored == .off, "the act writes the store; the door holds it")
            rig.door.landReceipt(receipt(note: post.id, title: "draft"))
            let request = MCPShowRequest(
                target: .book(bookID: book.id, sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask)
            let verdict = await rig.door.agentShow(request)
            #expect(verdict == .offer && session.status.standing != nil, "the offer road is untouched")
            #expect(rig.entries.count == 2, "the trail still records")
            #expect(rig.door.trail.trail.drawnRowCount(showing: rig.door.trailDial) == 0, "fully off draws nothing")

            rig.door.setTrailDial(.asksOnly)
            let asks = await eventually { rig.door.trailDial == .asksOnly }
            #expect(asks)
            let drawn = rig.door.trail.trail.groups(showing: rig.door.trailDial).flatMap(\.entries).map(\.place)
            #expect(drawn == ["book:\(book.id)"], "notices off: the ask alone")
            #expect(session.status.standing != nil, "still standing")
            #expect(rig.door.showOffer?.request == request, "the SAME ask, across both dial writes")
        }
    }

    /// The drop door acts only on THIS section's drag and only where a drop
    /// would act, landing through the door's one move; the drag ends either way.
    @Test func theDropDoorLandsOnlyThisSectionsDrag() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let rig = Rig(session)
            defer { rig.door.detach() }
            for note in ["n1", "n2", "n3"] { rig.door.landReceipt(receipt(note: note, title: note)) }
            let ids = rig.entries.map(\.id)  // n3, n2, n1
            let drag = MCPTrailDragState()
            drag.began(ids[0])
            let foreign = MCPTrailDragToken(entryID: ids[0].uuidString, listID: "another section")
            #expect(!MCPTrailDropDoor.perform([foreign], onto: .after(ids[2]), drag: drag, door: rig.door, animation: nil))
            #expect(drag.dragging == nil, "the drop ends the drag either way")
            let own = MCPTrailDragToken(entryID: ids[0].uuidString, listID: drag.listID)
            #expect(!MCPTrailDropDoor.perform([own], onto: .before(ids[1]), drag: drag, door: rig.door, animation: nil),
                    "its own gap moves nothing")
            #expect(MCPTrailDropDoor.perform([own], onto: .after(ids[2]), drag: drag, door: rig.door, animation: nil))
            #expect(rig.entries.map(\.id) == [ids[1], ids[2], ids[0]])
        }
    }

    /// Settings ▸ MCP: the dial's row sits under the ACTIVITY tab's log — never
    /// above the tabs, where a row pushes a fresh pane's Connect code block out
    /// of sight (VX-281's geometry row, `MCPPaneTabsTests.aFreshPaneOpensOnConnect…`
    /// — the closing window's red, fixed by this placement); a search finding
    /// opens that tab; her three words in her order, the line and its whole text.
    @Test func theTrailDialIsSettingsMCPsRowOnTheActivityTab() throws {
        #expect(SettingsCatalog.title("mcpTrailDial") == MCPPaneCopy.trailDialTitle)
        let rendered = AppSettingsView.rowIDsRendered[.mcp] ?? []
        #expect(rendered.last == "mcpTrailDial", "the last tab's row")
        #expect(MCPPaneTab.holding(findingLead: SettingsCatalog.title("mcpTrailDial")) == .activity,
                "a finding opens the Activity tab")
        #expect(MCPPaneTab.offered(sharing: false).contains(.activity), "a tab every library offers")
        let pane = try String(
            contentsOf: URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/MCP/MCPPane.swift"), encoding: .utf8)
        let picker = "Picker(SettingsCatalog.title(\"mcpTrailDial\")"
        let activity = try #require(pane.range(of: "@ViewBuilder private var activityTab: some View {"))
        let tabs = try #require(pane.range(of: "switch shownTab {"))
        #expect(pane[activity.upperBound...].contains(picker), "the picker is the Activity tab's")
        #expect(!pane[..<tabs.lowerBound].contains(picker), "never in the sections above the tabs")
        #expect(MCPTrailDial.allCases.map(MCPPaneCopy.trailDialChoice) == ["Everything on", "Notices off", "Fully off"])
        #expect(!MCPPaneCopy.trailDialTitle.contains("AI"), "settings-class wording: client, never AI (VX-272)")
        #expect(MCPPaneCopy.trailDialDetail.contains(MCPPaneCopy.showDialTitle),
                "the whole text points at the show dial's own road")
        let found = SettingsSearch.findings(matching: "notices", in: SettingsSearch.settingsEntries)
            .contains { $0.pane == .mcp }
        #expect(found, "“notices” finds the row")
    }
}

// MARK: - VX-904 — a whole client group folds (the VX-914 run, batch 1)

/// **VX-904 — her word at the #264 sitting: "asks floating within each client
/// group - fine, maybe add ability to collapse a whole client group."** An
/// Improvement on the as-built ordering (which stands): state pins on the pure
/// trail, the door's press, the session's end, and the face read from source.
/// PROVISIONAL edges (the record's BATCH 1 block): a fold lives as long as its
/// group; a new act or ask lands in a folded group FOLDED; Clear All and the
/// session's end forget every fold.
@MainActor
@Suite("VX-904 — a whole client group folds, its count honest, the ordering as built")
struct MCPTrailFoldTests {
    /// The fold: the group keeps EVERY row the dial lets it draw (the header's
    /// honest count) while drawing none; the fit test counts the drawn rows
    /// only; the header stays — so the section stays.
    @Test func aFoldedGroupDrawsItsHeaderAloneWithAnHonestCount() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(write: receipt(note: "n2"), at: at.addingTimeInterval(1))
        trail.record(write: receipt(client: "codex", note: "x1"), at: at.addingTimeInterval(2))
        #expect(trail.drawnRowCount(showing: .everything) == 3)

        trail.toggleFold("claude-code")
        #expect(trail.folded == ["claude-code"])
        let groups = trail.groups(showing: .everything)
        let folded = groups.first { $0.clientName == "claude-code" }
        #expect(folded?.folded == true && folded?.entries.count == 2, "the count stays honest")
        #expect(folded?.drawnEntries.isEmpty == true, "a folded group draws no row")
        #expect(groups.first { $0.clientName == "codex" }?.folded == false, "only THAT client's group folds")
        #expect(trail.drawnRowCount(showing: .everything) == 1, "the fit counts the drawn rows")
        #expect(groups.count == 2, "both headers still draw — the section stays")
        #expect(MCPTrailCopy.header(client: "claude-code", count: folded?.entries.count ?? 0)
                    == MCPTrailCopy.header(client: "claude-code", count: 2), "the header says every row")

        trail.toggleFold("claude-code")
        #expect(trail.folded.isEmpty && trail.drawnRowCount(showing: .everything) == 3, "her press opens it again")
        trail.toggleFold("nobody")
        #expect(trail.folded.isEmpty, "a client with no row has no group to fold")
    }

    /// The ordering stands AS BUILT (her ruling): a fold changes what a group
    /// draws, never where it stands — an ask-holding folded group still LEADS;
    /// a new ask landing in a folded group leaves it folded (PROVISIONAL), its
    /// count growing.
    @Test func aFoldedAskHoldingGroupStillLeadsAndANewAskLeavesItFolded() {
        var trail = MCPTrail()
        trail.record(write: receipt(note: "n1"), at: at)
        trail.record(show: ask("a1", client: "codex"), opened: false, at: at.addingTimeInterval(1))
        trail.record(write: receipt(note: "n2"), at: at.addingTimeInterval(2))
        trail.toggleFold("codex")
        let groups = trail.groups(showing: .everything)
        #expect(groups.map(\.clientName) == ["codex", "claude-code"], "the ask-holding group leads, folded or not")
        #expect(groups.first?.folded == true)

        trail.record(show: ask("a2", client: "codex"), opened: false, at: at.addingTimeInterval(3))
        let after = trail.groups(showing: .everything).first
        #expect(after?.clientName == "codex" && after?.folded == true, "her fold stands")
        #expect(after?.entries.map(\.place) == ["note:a2", "note:a1"], "the count grows honestly")

        // Notices off: a folded group's asks still count; the fold is kept.
        #expect(trail.groups(showing: .asksOnly).first?.entries.count == 2)
        #expect(trail.groups(showing: .asksOnly).first?.folded == true)
    }

    /// A fold lives as long as its group (and the session): Clear All forgets
    /// every fold; a folded client's last row going — dismissed, or its place
    /// gone — lets its fold go, so a later act lands an OPEN group.
    @Test func aFoldLivesAsLongAsItsGroup() throws {
        var trail = MCPTrail()
        trail.record(write: receipt(client: "codex", note: "x1"), at: at)
        trail.toggleFold("codex")
        let only = try #require(trail.entries.first?.id)
        trail.dismiss(only)
        #expect(trail.folded.isEmpty, "its last row dismissed — no group, no fold")
        trail.record(write: receipt(client: "codex", note: "x2"), at: at.addingTimeInterval(1))
        #expect(trail.groups(showing: .everything).first?.folded == false, "a later act lands an open group")

        trail.toggleFold("codex")
        trail.forget(placeOf: noteTarget("x2"))
        #expect(trail.folded.isEmpty, "its place gone — the fold with it")

        trail.record(write: receipt(note: "n1"), at: at.addingTimeInterval(2))
        trail.toggleFold("claude-code")
        trail.clear()
        #expect(trail.folded.isEmpty && trail.isEmpty, "Clear All forgets every fold")
    }

    /// Her press goes through the door (view state in the trail's session
    /// memory — no act, no store); the session's end forgets the fold with the
    /// rows (`letGoOfTheSession`).
    @Test func herPressFoldsThroughTheDoorAndTheSessionsEndForgetsIt() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "draft")
            let rig = Rig(session)
            rig.door.landReceipt(receipt(note: post.id, title: "draft"))
            rig.door.toggleTrailFold("claude-code")
            #expect(rig.door.trail.trail.folded == ["claude-code"])
            #expect(rig.door.trail.trail.drawnRowCount(showing: rig.door.trailDial) == 0)
            #expect(rig.door.trail.trail.groups(showing: rig.door.trailDial).count == 1, "the header stays")
            rig.door.detach()
            #expect(rig.door.trail.trail.folded.isEmpty && rig.door.trail.trail.isEmpty, "gone with the session")
        }
    }

    /// The face, read from its source: the whole header is the press, its
    /// glyph the app's fold pair at the trailing end, its hover naming the
    /// client; the section draws a group's DRAWN rows and fits by them; the
    /// header's right-click is unchanged; the sidebar keeps the section while
    /// any header draws (a folded group's header alone).
    @Test func theHeaderIsTheFoldsPressAndTheSidebarKeepsAFoldedSection() throws {
        let app = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let section = try String(
            contentsOf: app.appendingPathComponent("Variorum/Features/MCP/MCPTrailSection.swift"), encoding: .utf8)
        let header = try #require(section.range(of: "private func header(_ group: MCPTrail.Group)"))
        let rowStart = try #require(section.range(of: "private struct MCPTrailRow"))
        let headerBody = String(section[header.upperBound..<rowStart.lowerBound])
        #expect(headerBody.contains("door.toggleTrailFold(group.clientName)"), "the header's press folds")
        #expect(headerBody.contains("MCPTrailCopy.foldGlyph(folded: group.folded)"))
        #expect(headerBody.contains(".help(MCPTrailCopy.foldHelp(client: group.clientName, folded: group.folded))"))
        #expect(headerBody.contains("count: group.entries.count"), "the header counts every row, folded or not")
        #expect(headerBody.contains("CapabilityRegistry.capability(.mcpClearTrail).verb")
                    && headerBody.contains("CapabilityRegistry.capability(.mcpSetTrailDial).verb"),
                "the right-click is unchanged")
        #expect(section.contains("ForEach(group.drawnEntries)"), "a folded group draws no row")
        #expect(section.contains("$0 + $1.drawnEntries.count"), "the section fits by its drawn rows")
        #expect(MCPTrailCopy.foldGlyph(folded: false) == "\u{25BE}" && MCPTrailCopy.foldGlyph(folded: true) == "\u{25B8}",
                "the Shortcuts tab's pair")
        #expect(MCPTrailCopy.foldHelp(client: "variorum-de", folded: false) == "Fold variorum-de\u{2019}s rows")
        #expect(MCPTrailCopy.foldHelp(client: "variorum-de", folded: true) == "Show variorum-de\u{2019}s rows")

        let sidebar = try String(
            contentsOf: app.appendingPathComponent("Variorum/Features/Library/SidebarView.swift"), encoding: .utf8)
        #expect(sidebar.contains("private var footerShows: Bool { (footerSection?.headers() ?? 0) > 0 }"))
        #expect(sidebar.contains("if let footerSection, footerShows {"), "a folded section still draws")
        #expect(!sidebar.contains("footerRows > 0"), "presence is no longer the drawn-row count")
    }
}
