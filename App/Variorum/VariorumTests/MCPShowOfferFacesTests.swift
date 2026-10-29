//
//  MCPShowOfferFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-676 + VX-675 (the VX-677 run, batch 3 — the record
//  `notes/plans/fixes/vx-677-editor-panes-ai-door.md`, BATCH 3 RECORD): the
//  app half of `show_in_app` LANDING AS AN OFFER, and of a SAVED VERSION's
//  full-size open. Her sitting (2026-10-28): the ask presents at the toast's
//  FULL prominence; after the toast fades it HOLDS the quiet line at the bottom
//  bar's trailing end until taken, replaced by a newer ask, or the client
//  disconnects; the line carries its own small ✕ (it kills the ask) and the
//  toast's ✕ sends it to the line; the ⌥⌘O family takes it from the keyboard;
//  Activity logs the ask and the take. Her amendment: a background arrival is
//  the ask under every dial value but never; nothing raises a window.
//
//  Every pin drives the door's REAL road (`MCPDoor.agentShow` with a standing
//  provider — the hook's own body), so the offer pins are red on `rev676` (the
//  old etiquette: moved in front, refused away) and the version pins on
//  `rev675`. Every read is bound before an assertion reads it (the record's
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

extension MCPShowRequest {
    /// A pin's request: `target` from `client` under `dial` (the titles the
    /// wire's decision would read ride along when given).
    static func pin(
        _ target: MCPShowTarget, dial: MCPShowDial, client: String = "claude-code", title: String? = nil,
        peerTitles: [String?] = []
    ) -> MCPShowRequest {
        MCPShowRequest(target: target, clientName: client, title: title, peerTitles: peerTitles, dial: dial)
    }
}

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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
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

/// A door attached to `session`, one FULL window registered (her take's
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
}

// MARK: - A place that EXISTS (the VX-677 ladder round 1, F-L2)

/// Her press re-reads the place an ask (or a receipt) names before it opens it (F-L2 — the grant
/// ask's own road), so a pin's ask must name a place that EXISTS, as a real ask always does (the
/// wire's read found it readable). These stage the rows under the pins' OWN literal ids, so every
/// assertion naming them stays byte-unchanged. Rows only: no operation, no undo, no behaviour.
private let stagedStamp = DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 1_782_864_000))

private func stageNote(_ db: AppDatabase, _ id: String, title: String) async throws {
    try await db.write { db in
        try db.execute(
            sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
            arguments: [id, title, stagedStamp, stagedStamp])
    }
}

private func stageBook(_ db: AppDatabase, _ id: String, name: String) async throws {
    try await db.write { db in
        try db.execute(
            sql: "INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES (?, ?, 'book', ?, ?)",
            arguments: [id, name, stagedStamp, stagedStamp])
    }
}

/// `note` and ONE saved version of it — born archived (`archived_at = created_at`) and linked block to
/// block by a live `version_of` edge: exactly `Queries.versionHistoryPredicate`'s facts.
private func stageVersion(_ db: AppDatabase, note: String, version: String) async throws {
    try await stageNote(db, note, title: "draft")
    try await db.write { db in
        try db.execute(
            sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at, archived_at)
                VALUES (?, 'post', 'draft', ?, ?, ?)
                """,
            arguments: [version, stagedStamp, stagedStamp, stagedStamp])
        for (container, block) in [(note, "\(note)-block"), (version, "\(version)-block")] {
            try db.execute(
                sql: "INSERT INTO block (id, created_at, updated_at) VALUES (?, ?, ?)",
                arguments: [block, stagedStamp, stagedStamp])
            try db.execute(
                sql: """
                    INSERT INTO container_block (id, container_id, block_id, position, created_at, updated_at)
                    VALUES (?, ?, ?, 'a0', ?, ?)
                    """,
                arguments: ["\(block)-placement", container, block, stagedStamp, stagedStamp])
        }
        try db.execute(
            sql: """
                INSERT INTO edge (id, source_block_id, target_block_id, type, created_at)
                VALUES (?, ?, ?, 'version_of', ?)
                """,
            arguments: ["\(version)-edge", "\(note)-block", "\(version)-block", stagedStamp])
    }
}

@MainActor
@Suite("VX-676 + VX-675 — the ask on the status seam, its doors, ⌥⌘O, a saved version", .serialized)
struct MCPShowOfferFacesTests {
    // MARK: - The ask presents (ruling (1)) and holds the line (ruling (2))

    /// Her default, the ask: the call is OFFERED at the toast's full prominence — the offer
    /// kind, its door "Open ›" and the line's ✕ named from the registry — and nothing moved,
    /// in front as away. **RED on `rev676`** (in front it moved; away it was refused).
    @Test func anAskPopsUpAtTheToastsFullProminenceAndMovesNothing() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            for standing in [MCPShowRule.Standing.frontmostMainWindow, .notFrontmost] {
                let rig = Rig(session, standing: standing)
                defer { rig.door.detach() }
                let resting = rig.router.workspace.focusedSelection
                let request = MCPShowRequest.pin(.note(noteID: "n1", blockID: nil, select: nil), dial: .ask, title: "ch 1")

                let verdict = await rig.door.agentShow(request)
                #expect(verdict == .offer, "\(standing)")
                let toast = session.status.current
                #expect(toast?.kind == .offer && toast?.text == "claude-code asks to show you \u{201C}ch 1\u{201D}")
                #expect(toast?.action?.label == CapabilityRegistry.capability(.mcpTakeShowAsk).verb)
                #expect(toast?.dismiss?.label == CapabilityRegistry.capability(.mcpDismissShowAsk).verb)
                #expect(session.status.lineItem == nil, "the toast is showing it — one message, one place")
                #expect(rig.router.workspace.focusedSelection == resting, "nothing moved")
                #expect(rig.door.showOffer?.request == request)
                session.status.clear()
            }
        }
    }

    /// After the toast fades the ask HOLDS the quiet line — past the receipt clock, and under
    /// receipt style OFF too (it is an offer, never a receipt) — with its door and its ✕.
    /// **RED on `rev676`.**
    ///
    /// **Staged as an ask can only arrive: the server ON, the asking client CONNECTED** (DA-1,
    /// the VX-677 fixes unit — the record's FIXES RECORD, F-2). The first form asked from a
    /// client that was never connected on a store whose server switch was OFF, and the door's
    /// first snapshot then did exactly what it must: `reconcileServer` stopped the (absent)
    /// server and `adoptConnected([])` ended the ask — "its client is gone" (ruling (2)) — so
    /// the line read nil after the 300-ms wait while every other offer pin, reading before
    /// that first snapshot, passed. Live (the final walk's W-676-1, both voices) the line held
    /// to +21.5 / +25.5 s with the server on and claude-code connected.
    @Test func afterTheToastFadesTheAskHoldsTheQuietLine() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            session.status.dismissAfter = .milliseconds(60)
            session.status.receiptStyle = .off
            try session.operations.setMCPSwitch(.server, on: true)
            let rig = Rig(session)
            defer { rig.door.detach() }
            // The door has heard its switch (the snapshot an ask's end would ride), and the
            // asking client is connected, as the host would report it.
            let heard = await eventually { rig.door.snapshot.enabled }
            try #require(heard, "fixture: the door adopted its first snapshot — the server ON")
            rig.door.previewConnected(["claude-code"])
            let request = MCPShowRequest.pin(.book(bookID: "r1", sectionID: nil), dial: .moveAtOnce, title: "lessons")

            let verdict = await rig.door.agentShow(request)
            #expect(verdict == .offer, "away under move at once: the ask")
            let faded = await eventually { session.status.current == nil }
            #expect(faded, "the toast fades on its own clock")
            try? await Task.sleep(for: .milliseconds(300))
            let line = session.status.lineItem
            #expect(line?.text == "claude-code asks to show you \u{201C}lessons\u{201D}", "it holds the line")
            #expect(line?.kind == .offer && line?.action != nil && line?.dismiss != nil)
            #expect(session.status.spoken == line, "on screen")
            let stillStanding = rig.door.showOffer != nil
            #expect(stillStanding, "the ask still stands on the door — nothing ended it")
        }
    }

    /// The TOAST's ✕ sends it to the line (the shell's dismiss is `clear()`, which never ends a
    /// standing ask); the LINE's ✕ ends it — nothing opened, nothing logged. **RED on `rev676`.**
    @Test func theToastsDismissSendsItToTheLineAndTheLinesDismissEndsIt() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let rig = Rig(session)
            defer { rig.door.detach() }
            let resting = rig.router.workspace.focusedSelection
            _ = await rig.door.agentShow(.pin(.note(noteID: "n1", blockID: nil, select: nil), dial: .ask, title: "ch 1"))

            session.status.clear()  // the toast's ✕ (`StatusToast`'s onDismiss)
            #expect(session.status.current == nil)
            let line = try #require(session.status.lineItem, "sent to the line")
            #expect(rig.door.showOffer != nil, "still standing")

            let dismiss = try #require(line.dismiss)
            dismiss.perform()  // the line's own ✕
            #expect(session.status.lineItem == nil && session.status.standing == nil)
            #expect(rig.door.showOffer == nil, "the ask is over")
            try? await Task.sleep(for: .milliseconds(150))
            #expect(rig.router.workspace.focusedSelection == resting, "nothing opened")
            let rows = try await db.read { try Queries.mcpActivity($0) }
            #expect(rows.isEmpty, "a dismissal is not logged (the ruling names the ask and the take)")
        }
    }

    /// A NEWER ask replaces the standing one — its words on the seam, its request on the door —
    /// and the older ask's door, pressed late, does nothing. **RED on `rev676`.**
    @Test func aNewerAskReplacesTheStandingOne() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let rig = Rig(session)
            defer { rig.door.detach() }
            _ = await rig.door.agentShow(.pin(.note(noteID: "n1", blockID: nil, select: nil), dial: .ask, title: "first"))
            let older = try #require(session.status.current?.action)
            let newer = MCPShowRequest.pin(.lens(noteID: "n2", lensID: "L2"), dial: .ask, client: "codex", title: "second")
            _ = await rig.door.agentShow(newer)

            #expect(rig.door.showOffer?.request == newer)
            #expect(session.status.current?.text == "codex asks to show you a lens of \u{201C}second\u{201D}")
            older.perform()  // the replaced ask's Open ›, pressed late
            #expect(rig.door.showOffer?.request == newer, "an older ask's door never acts on a newer one")
        }
    }

    /// The ask ends when ITS client disconnects — no live session left under its name — and
    /// only then (another client's going changes nothing). **RED on `rev676`.**
    @Test func theAskEndsWhenItsClientDisconnects() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let rig = Rig(session)
            defer { rig.door.detach() }
            rig.door.previewConnected(["claude-code", "codex"])
            _ = await rig.door.agentShow(.pin(.note(noteID: "n1", blockID: nil, select: nil), dial: .ask, title: "ch 1"))
            #expect(rig.door.showOffer != nil)

            rig.door.previewConnected(["claude-code"])
            #expect(rig.door.showOffer != nil, "another client's going leaves it standing")
            rig.door.previewConnected([])
            #expect(rig.door.showOffer == nil && session.status.standing == nil, "its client is gone: so is the ask")
            #expect(session.status.current == nil, "and from the toast, if it was still there")
        }
    }

    /// HER TAKE — the line's Open › — opens the target through her own road, in the full
    /// window, ends the ask, and logs the take as its own Activity row under the asking
    /// client's name, on the row its ask named. **RED on `rev676`.**
    @Test func takingTheAskOpensItAndLogsTheTake() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            // F-L2 (the VX-677 ladder round 1) — STAGING ONLY, assertions unchanged: the ask names
            // a book that exists, as a real ask does (her press now re-reads its place).
            try await stageBook(db, "r1", name: "lessons")
            let rig = Rig(session)
            defer { rig.door.detach() }
            let request = MCPShowRequest(
                target: .book(bookID: "r1", sectionID: nil), clientName: "claude-code", title: "lessons",
                dial: .ask, activityKind: "book", activityID: "r1")
            _ = await rig.door.agentShow(request)
            session.status.clear()
            let take = try #require(session.status.lineItem?.action)
            take.perform()

            let opened = await eventually { rig.router.workspace.focusedSelection == .reading("r1") }
            #expect(opened, "her press opened it")
            #expect(rig.door.showOffer == nil && session.status.standing == nil, "taken: over")
            let logged = await eventually {
                let rows = (try? await db.read { try Queries.mcpActivity($0) }) ?? []
                return rows.first?.act == MCPShowActivity.takenAct
            }
            #expect(logged, "the take is its own row")
            let rows = try await db.read { try Queries.mcpActivity($0) }
            let row = rows.first
            #expect(row?.clientName == "claude-code" && row?.targetKind == "book" && row?.targetID == "r1")
            #expect(row?.targetTitle == "lessons" && row?.allowed == true)
        }
    }

    /// ⌥⌘O takes a STANDING ASK first ("the ⌥⌘O family takes it from the keyboard"; "⌥⌘O
    /// takes it on arrival") — it acts with only an ask standing — and with none, the AI's
    /// last change opens as before. **RED on `rev676`** (no ask: the chord stays grey).
    @Test func commandOptionOTakesAStandingAskFirstThenTheLastChange() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            // F-L2 (the VX-677 ladder round 1) — STAGING ONLY, assertions unchanged: the ask's note
            // and the change's book exist, as real ones do (her press now re-reads the place).
            try await stageNote(db, "asked", title: "asked")
            try await stageBook(db, "written-book", name: "w")
            let rig = Rig(session)
            defer { rig.door.detach() }
            #expect(!session.commandRouter.isEnabled(.showLastAIChange))
            _ = await rig.door.agentShow(.pin(.note(noteID: "asked", blockID: nil, select: nil), dial: .ask))
            #expect(session.commandRouter.isEnabled(.showLastAIChange), "an ask alone ungreys ⌥⌘O")
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: "written", targetTitle: "w",
                show: .book(bookID: "written-book", sectionID: nil)))

            rig.door.showLastChange()
            let tookAsk = await eventually { rig.router.workspace.focusedSelection == .post("asked") }
            #expect(tookAsk, "the standing ask first")
            #expect(rig.door.showOffer == nil)
            rig.door.showLastChange()
            let tookChange = await eventually { rig.router.workspace.focusedSelection == .reading("written-book") }
            #expect(tookChange, "then the AI's last change, as before")
        }
    }

    /// Under NEVER nothing reaches the seam, wherever she stands. A GUARD of the rule's
    /// third arm at the door (green on both reverts' old roads where they refuse).
    @Test func neverPutsNothingOnTheSeam() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            for standing in [MCPShowRule.Standing.frontmostMainWindow, .notFrontmost] {
                let rig = Rig(session, standing: standing)
                defer { rig.door.detach() }
                let resting = rig.router.workspace.focusedSelection
                let verdict = await rig.door.agentShow(.pin(.note(noteID: "n1", blockID: nil, select: nil), dial: .never))
                #expect(verdict == .refuse(MCPShowRule.neverWords))
                #expect(session.status.spoken == nil && rig.door.showOffer == nil)
                #expect(rig.router.workspace.focusedSelection == resting)
            }
        }
    }

    // MARK: - Her press re-reads the place (the VX-677 ladder round 1, F-L2)
    //
    // Every read below is bound to a local BEFORE a macro reads it — no closure, `&&` or `??`
    // inside `#expect`/`#require` (VX-692).

    /// **F-L2 — RED ON OLD: her TAKE of an ask whose place is GONE.** Nothing ends an ask whose
    /// target dies while it stands (a wire `delete_note`, her own Delete, a sync removal), and the
    /// old take ended the ask and delivered anyway: the shell adopts any id (no liveness gate on
    /// adopt → select → the detail), so a pane stood on a TOMBSTONE, the take was logged, and
    /// nothing was said. Now her press re-reads the place off the main actor — the grant ask's own
    /// road (`refreshAsk` → `askStanding`): gone ⇒ the ask is let go and a refusal names the place
    /// and the client; nothing opens; no take row. The note target and a takes target (the takes
    /// arm's wait shrunk — the old road waited it out). Staged through `agentShow`, away (the
    /// suite's real-road rule). Old: three failing expectations per target.
    @Test func aTakeWhoseTargetIsGoneSaysSoAndOpensNothing() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let restoreWait = MCPNavigator.mountWait
            MCPNavigator.mountWait = .milliseconds(40)
            defer { MCPNavigator.mountWait = restoreWait }
            for kind in ["note", "takes"] {
                let title = "gone \(kind)"
                let post = try session.operations.createPost(title: title)
                let block = try session.operations.newBlock(in: post.id, text: "words").block.id
                let target: MCPShowTarget = kind == "note"
                    ? .note(noteID: post.id, blockID: nil, select: nil)
                    : .takes(noteID: post.id, blockID: block)
                let rig = Rig(session)
                defer { rig.door.detach() }
                let resting = rig.router.workspace.focusedSelection
                _ = await rig.door.agentShow(MCPShowRequest(
                    target: target, clientName: "claude-code", title: title, dial: .ask,
                    activityKind: "note", activityID: post.id))
                let stood = rig.door.showOffer != nil
                try #require(stood, "fixture: the ask stands (\(kind))")
                try session.operations.deleteContainer(post.id)  // the place dies while the ask stands
                session.status.clear()  // the toast's ✕: the ask goes to the line
                let take = try #require(session.status.lineItem?.action)
                take.perform()  // her press

                let refused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
                try? await Task.sleep(for: .milliseconds(150))  // past the old road's delivery and its log
                let words = session.status.current?.text ?? "nothing"
                let saidIt = refused && words == "\u{201C}\(title)\u{201D} is gone, so claude-code's ask was let go."
                let selection = rig.router.workspace.focusedSelection
                let openedNothing = selection == resting
                let rows = try await db.read { try Queries.mcpActivity($0) }
                let takeRows = rows.filter { $0.act == MCPShowActivity.takenAct }.count
                let noTakeRow = takeRows == 0
                let letGo = rig.door.showOffer == nil
                let noStaleItem = session.status.standing == nil
                #expect(saidIt, "RED ON OLD: a refusal naming the place and the client (\(kind)) — said: \(words)")
                #expect(openedNothing, "RED ON OLD: the dead note opened (\(kind)) — \(String(describing: selection))")
                #expect(noTakeRow, "RED ON OLD: a take was logged for a place that is gone (\(kind)): \(takeRows)")
                #expect(letGo, "the ask is let go (\(kind))")
                #expect(noStaleItem, "no stale item on the seam (\(kind))")
                session.status.clear()
            }
        }
    }

    /// **F-L2 — the GUARD: her take of an ask whose place STANDS opens it exactly as before** — the
    /// note target in place, and a takes target on its mounted note (her see-takes landing) — logs
    /// each take and says nothing. Green on both trees: it keeps the pin above able to tell a dead
    /// place from a live one (a fix that refused every take would fail here).
    @Test func aTakeWhoseTargetStandsStillOpensIt() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "standing note")
            let block = try session.operations.newBlock(in: post.id, text: "words").block.id
            let noteID = post.id
            let rig = Rig(session)
            defer { rig.door.detach() }

            _ = await rig.door.agentShow(MCPShowRequest(
                target: .note(noteID: noteID, blockID: nil, select: nil), clientName: "claude-code",
                title: "standing note", dial: .ask, activityKind: "note", activityID: noteID))
            session.status.clear()
            let take = try #require(session.status.lineItem?.action)
            take.perform()
            let opened = await eventually { rig.router.workspace.focusedSelection == .post(noteID) }
            let loggedOnce = await eventually {
                let rows = (try? await db.read { try Queries.mcpActivity($0) }) ?? []
                return rows.filter { $0.act == MCPShowActivity.takenAct }.count == 1
            }
            let quiet = session.status.current == nil
            #expect(opened, "her take opened the note")
            #expect(loggedOnce, "the take is its own row")
            #expect(quiet, "nothing refused")

            var applied: [PostMode] = []
            let token = session.commandRouter.registerDetail(postID: noteID, mode: .write) { applied.append($0) }
            defer { session.commandRouter.unregisterDetail(token) }
            _ = await rig.door.agentShow(MCPShowRequest(
                target: .takes(noteID: noteID, blockID: block), clientName: "claude-code",
                title: "standing note", dial: .ask, activityKind: "note", activityID: noteID))
            session.status.clear()
            let takeTakes = try #require(session.status.lineItem?.action)
            takeTakes.perform()
            let landed = await eventually {
                session.commandRouter.pendingTakesLanding == .bloom(postID: noteID, blockID: block)
            }
            let loggedTwice = await eventually {
                let rows = (try? await db.read { try Queries.mcpActivity($0) }) ?? []
                return rows.filter { $0.act == MCPShowActivity.takenAct }.count == 2
            }
            let modes = applied
            let stillQuiet = session.status.current == nil
            #expect(landed, "her see-takes landing, parked for the mounted note")
            #expect(modes == [.takes], "the mode, as her own door switches it")
            #expect(loggedTwice, "the second take is logged too")
            #expect(stillQuiet, "nothing refused")
        }
    }

    /// **F-L2 (batch 3's F-B3-2 folded in) — RED ON OLD: a write receipt's Open ›, and ⌥⌘O's
    /// last-change arm, on a change whose place is GONE.** The receipt road shared the take's hole:
    /// an AI's write landed, its note died, and her Open › (or ⌥⌘O) still adopted the dead id — a
    /// pane on a tombstone, nothing said. Now the same re-read: gone ⇒ a refusal naming the place
    /// and the client, nothing opens, and the gone change is no longer the last change ⌥⌘O can open
    /// — the chord greys (PROVISIONAL P-FL2-1: a door whose only press refuses is a dead door).
    /// Old: four failing expectations per arm.
    @Test func aReceiptsOpenOnAGoneChangeSaysSoAndOpensNothing() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let rig = Rig(session)
            defer { rig.door.detach() }
            let resting = rig.router.workspace.focusedSelection

            // The receipt line's own Open ›.
            let first = try session.operations.createPost(title: "gone change")
            let firstID = first.id
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: firstID, targetTitle: "gone change",
                show: .note(noteID: firstID, blockID: nil, select: nil)))
            let open = try #require(session.status.quietLine?.action)
            try session.operations.deleteContainer(firstID)  // the change's place dies
            open.perform()
            let lineRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            try? await Task.sleep(for: .milliseconds(100))  // past the old road's delivery
            let lineWords = session.status.current?.text ?? "nothing"
            let lineSaid = lineRefused
                && lineWords == "\u{201C}gone change\u{201D} is gone, so claude-code's change can't be opened."
            let afterLine = rig.router.workspace.focusedSelection
            let lineOpenedNothing = afterLine == resting
            let lineRetired = rig.door.lastShow == nil
            let lineGreyed = !session.commandRouter.isEnabled(.showLastAIChange)
            #expect(lineSaid, "RED ON OLD: a refusal naming the place and the client — said: \(lineWords)")
            #expect(lineOpenedNothing, "RED ON OLD: the dead note opened — \(String(describing: afterLine))")
            #expect(lineRetired, "RED ON OLD: the gone change is still the last change (PROVISIONAL P-FL2-1)")
            #expect(lineGreyed, "RED ON OLD: ⌥⌘O still offers a door that can only refuse")
            session.status.clear()

            // ⌥⌘O's last-change arm.
            let second = try session.operations.createPost(title: "gone too")
            let secondID = second.id
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "codex", act: .take, targetID: secondID, targetTitle: "gone too",
                show: .note(noteID: secondID, blockID: nil, select: nil)))
            session.status.clear()
            try session.operations.deleteContainer(secondID)
            let beforeChord = rig.router.workspace.focusedSelection
            rig.door.showLastChange()
            let chordRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            try? await Task.sleep(for: .milliseconds(100))
            let chordWords = session.status.current?.text ?? "nothing"
            let chordSaid = chordRefused
                && chordWords == "\u{201C}gone too\u{201D} is gone, so codex's change can't be opened."
            let afterChord = rig.router.workspace.focusedSelection
            let chordOpenedNothing = afterChord == beforeChord
            let chordRetired = rig.door.lastShow == nil
            let chordGreyed = !session.commandRouter.isEnabled(.showLastAIChange)
            #expect(chordSaid, "RED ON OLD: ⌥⌘O's refusal naming the place and the client — said: \(chordWords)")
            #expect(chordOpenedNothing, "RED ON OLD: ⌥⌘O opened the dead note — \(String(describing: afterChord))")
            #expect(chordRetired, "RED ON OLD: the gone change is still the last change (PROVISIONAL P-FL2-1)")
            #expect(chordGreyed, "RED ON OLD: ⌥⌘O stays lit over a door that can only refuse")
        }
    }

    /// **F-L2 (the fold-in) — the GUARD: a receipt's Open › and ⌥⌘O on a change whose place
    /// STANDS open it exactly as before**, say nothing, and keep it ⌥⌘O's last change (the chord
    /// lit). Green on both trees.
    @Test func aReceiptsOpenOnAStandingChangeStillOpensIt() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let post = try session.operations.createPost(title: "standing change")
            let noteID = post.id
            let rig = Rig(session)
            defer { rig.door.detach() }
            let target = MCPShowTarget.note(noteID: noteID, blockID: nil, select: nil)
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: noteID, targetTitle: "standing change",
                show: target))
            let open = try #require(session.status.quietLine?.action)
            open.perform()
            let opened = await eventually { rig.router.workspace.focusedSelection == .post(noteID) }
            let quiet = session.status.current == nil
            let kept = rig.door.lastShow == target
            let lit = session.commandRouter.isEnabled(.showLastAIChange)
            #expect(opened, "her Open › opened the note")
            #expect(quiet, "nothing refused")
            #expect(kept, "it stays the last change")
            #expect(lit, "⌥⌘O stays lit")

            rig.router.adopt(.library)
            rig.door.showLastChange()
            let reopened = await eventually { rig.router.workspace.focusedSelection == .post(noteID) }
            let stillQuiet = session.status.current == nil
            #expect(reopened, "⌥⌘O opens it again")
            #expect(stillQuiet, "nothing refused")
        }
    }

    /// **F-L2 — RED ON OLD: a show that cannot FINISH, or finds no full window, SAYS so.** Her take
    /// of a takes ask (and a receipt's Open › to a block's takes) opens the note, but the rest never
    /// lands when the note's detail never registers inside the wait (here a bare router, the wait
    /// shrunk) — and the old roads said nothing. Her words now say so (never the wire's
    /// `partialShowWords`, which speaks to the client). And a receipt's Open › with every full window
    /// closed (batch 3's F-B3-2) speaks the take's `noWindow` sibling instead of doing nothing.
    /// Old: one failing expectation per arm (three).
    @Test func aShowThatCannotFinishOrFindsNoWindowSaysSo() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let restoreWait = MCPNavigator.mountWait
            MCPNavigator.mountWait = .milliseconds(40)
            defer { MCPNavigator.mountWait = restoreWait }
            let post = try session.operations.createPost(title: "half shown")
            let block = try session.operations.newBlock(in: post.id, text: "words").block.id
            let noteID = post.id
            let rig = Rig(session)
            defer { rig.door.detach() }

            // 1 — her take of a takes ask: the note opens, the takes never land.
            _ = await rig.door.agentShow(MCPShowRequest(
                target: .takes(noteID: noteID, blockID: block), clientName: "claude-code", title: "half shown",
                dial: .ask, activityKind: "note", activityID: noteID))
            session.status.clear()
            let take = try #require(session.status.lineItem?.action)
            take.perform()
            let takeRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            let takeWords = session.status.current?.text ?? "nothing"
            let takeSaid = takeRefused
                && takeWords == "\u{201C}half shown\u{201D} opened, but the rest of what claude-code asked to show didn't land."
            let takeOpened = rig.router.workspace.focusedSelection == .post(noteID)
            #expect(takeSaid, "RED ON OLD: the unfinished take said nothing — said: \(takeWords)")
            #expect(takeOpened, "the note itself opened (non-vacuity)")
            session.status.clear()

            // 2 — a receipt's Open › to the same block's takes: the same, in the change's words.
            rig.door.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: noteID, targetTitle: "half shown",
                show: .takes(noteID: noteID, blockID: block)))
            let open = try #require(session.status.quietLine?.action)
            open.perform()
            let lineRefused = await eventually(.milliseconds(800)) { session.status.current?.kind == .refusal }
            let lineWords = session.status.current?.text ?? "nothing"
            let lineSaid = lineRefused
                && lineWords == "\u{201C}half shown\u{201D} opened, but the rest of claude-code's change didn't land."
            #expect(lineSaid, "RED ON OLD: the unfinished Open › said nothing — said: \(lineWords)")
            session.status.clear()

            // 3 — a receipt's Open › with no full window at all (F-B3-2).
            let noWindows = WindowRegistry()
            let lone = MCPDoor(serverAllowed: false)
            lone.attach(session: session, windows: noWindows)
            defer { lone.detach() }
            lone.landReceipt(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: noteID, targetTitle: "half shown",
                show: .note(noteID: noteID, blockID: nil, select: nil)))
            let loneOpen = try #require(session.status.quietLine?.action)
            loneOpen.perform()
            let loneRefused = session.status.current?.kind == .refusal
            let loneWords = session.status.current?.text ?? "nothing"
            let loneSaid = loneRefused && loneWords == "Open a Variorum window to see it."
            #expect(loneSaid, "RED ON OLD (F-B3-2): an Open › with no full window did nothing, silently — said: \(loneWords)")
        }
    }

    // MARK: - VX-675: a saved version, full size

    /// A version target opens the VX-440 full-size page — its own destination
    /// (`.noteVersion`), never the note's editor — moved at once in front, and from an ask by
    /// her take. **RED on `rev675`.**
    @Test func aVersionTargetOpensTheFullSizePage() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            // F-L2 (the VX-677 ladder round 1) — STAGING ONLY, assertions unchanged: the take half's
            // version is one of its note's saved versions, as a real ask's is (her press now re-reads
            // it). The move half never meets the read (the agent road is unchanged).
            try await stageVersion(db, note: "n2", version: "v2")
            let rig = Rig(session, standing: .frontmostMainWindow)
            defer { rig.door.detach() }
            let target = MCPShowTarget.version(noteID: "n1", versionID: "v1")
            let moved = await rig.door.agentShow(.pin(target, dial: .moveAtOnce))
            #expect(moved == .navigate)
            #expect(rig.router.workspace.focusedSelection == .noteVersion("v1", of: "n1"), "the full-size page")

            let rigAway = Rig(session)
            defer { rigAway.door.detach() }
            _ = await rigAway.door.agentShow(.pin(.version(noteID: "n2", versionID: "v2"), dial: .ask, title: "draft"))
            #expect(session.status.current?.text == "claude-code asks to show you a saved version of \u{201C}draft\u{201D}")
            rigAway.door.takeShowOffer()
            let opened = await eventually { rigAway.router.workspace.focusedSelection == .noteVersion("v2", of: "n2") }
            #expect(opened, "her take opens it full size")
        }
    }

    // MARK: - The words, the doors, the dial

    /// Every target's ask says what it would show, from the decision's own titles
    /// (PROVISIONAL words, P-676-6). A GUARD (new words).
    @Test func everyTargetsAskSaysWhatItWouldShow() {
        func line(_ target: MCPShowTarget, _ title: String?, _ peers: [String?] = []) -> String {
            MCPShowOfferCopy.line(.pin(target, dial: .ask, title: title, peerTitles: peers))
        }
        let q = { (s: String) in "\u{201C}\(s)\u{201D}" }
        #expect(line(.note(noteID: "n", blockID: "b", select: "w"), "ch 1") == "claude-code asks to show you \(q("ch 1"))")
        #expect(line(.note(noteID: "n", blockID: nil, select: nil), nil) == "claude-code asks to show you a note")
        #expect(line(.takes(noteID: "n", blockID: "b"), "ch 1") == "claude-code asks to show you the takes in \(q("ch 1"))")
        #expect(line(.lens(noteID: "n", lensID: "l"), "ch 1") == "claude-code asks to show you a lens of \(q("ch 1"))")
        #expect(line(.book(bookID: "r", sectionID: nil), "lessons") == "claude-code asks to show you \(q("lessons"))")
        #expect(line(.book(bookID: "r", sectionID: "s"), "lessons")
                == "claude-code asks to show you a chapter of \(q("lessons"))")
        #expect(line(.wing(wingID: "", name: "Home", shownBy: "claude-code"), "Home")
                == "claude-code asks to show you the Home wing")
        #expect(line(.wing(wingID: "w", name: "studio", shownBy: "claude-code"), "studio")
                == "claude-code asks to show you the wing \(q("studio"))")
        #expect(line(.compare(noteID: "a", peerIDs: ["b"]), "draft", ["revision"])
                == "claude-code asks to show you \(q("draft")) beside \(q("revision")) in Compare")
        #expect(line(.compare(noteID: "a", peerIDs: ["b", "c", "d"]), "draft", ["x", "y", "z"])
                == "claude-code asks to show you \(q("draft")) beside 3 other notes in Compare")
        #expect(line(.version(noteID: "n", versionID: "v"), "draft")
                == "claude-code asks to show you a saved version of \(q("draft"))")
    }

    /// Activity says the ask and the take in words, never a tool id (ruling (4); PROVISIONAL
    /// words). A GUARD (new acts).
    @Test func theAskAndTheTakeAreSaidInWords() {
        func line(_ act: String, _ title: String?, count: Int = 1) -> String {
            MCPPaneCopy.activityLine(MCPActivityFace.Line(
                id: 1, clientName: "claude-code", act: act, targetKind: "note", targetID: "n", targetTitle: title,
                allowed: true, count: count, at: "2026-10-28T00:00:00.000Z"))
        }
        #expect(line(MCPShowActivity.offeredAct, "ch 1") == "claude-code asked to show you \u{201C}ch 1\u{201D}")
        #expect(line(MCPShowActivity.offeredAct, "ch 1", count: 2)
                == "claude-code asked to show you \u{201C}ch 1\u{201D} (2 times)")
        #expect(line(MCPShowActivity.takenAct, "ch 1")
                == "You opened \u{201C}ch 1\u{201D}, which claude-code asked to show you")
        #expect(line(MCPShowActivity.takenAct, nil) == "You opened what claude-code asked to show you")
        #expect(line("show_in_app", "ch 1") == "claude-code showed you \u{201C}ch 1\u{201D}", "a move keeps its words")
    }

    /// P-1: the ask's two doors are declared once (`.surface`), the status seam's list names
    /// them, and the item wears their verbs. A GUARD.
    @Test func theAsksTwoDoorsAreDeclaredOnce() {
        let take = CapabilityRegistry.capability(.mcpTakeShowAsk)
        let dismiss = CapabilityRegistry.capability(.mcpDismissShowAsk)
        #expect(take.doors == [.surface] && take.verb == MCPReceiptCopy.openDoor)
        #expect(dismiss.doors == [.surface] && dismiss.verb == "Dismiss")
        #expect(MCPDoor.statusSeamCapabilities == [.mcpTakeShowAsk, .mcpDismissShowAsk])
        #expect(CapabilityRegistry.capability(.showLastAIChange).shortcutLabel == "\u{2325}\u{2318}O")
    }

    /// The dial (ruling (3)): Settings ▸ MCP's row above the tabs beside the switch
    /// (PROVISIONAL P-676-1), her three values in her order, the store's truth through the
    /// door's act and snapshot. A GUARD (new capability).
    @Test func theShowDialIsSettingsMCPsRowBesideTheSwitch() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(SettingsCatalog.title("mcpShowDial") == MCPPaneCopy.showDialTitle)
            let rendered = AppSettingsView.rowIDsRendered[.mcp] ?? []
            #expect(rendered.prefix(2) == ["mcpServer", "mcpShowDial"], "beside the switch")
            #expect(MCPPaneTab.holding(findingLead: SettingsCatalog.title("mcpShowDial")) == nil, "above the tabs")
            #expect(MCPShowDial.allCases.map(MCPPaneCopy.showDialChoice) == ["Move at once", "Ask", "Never"])
            let seen = await eventually { door.snapshot.showDial == .ask }
            #expect(seen, "her default")
            door.setShowDial(.never)
            let stored = await eventually {
                let dial = (try? await db.read { try Queries.mcpShowDial($0) }) ?? .ask
                return dial == .never
            }
            #expect(stored, "the act writes the store")
            let followed = await eventually { door.snapshot.showDial == .never }
            #expect(followed, "the pane's picker reads it back")
        }
    }
}
