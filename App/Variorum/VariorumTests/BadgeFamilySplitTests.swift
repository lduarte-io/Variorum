//
//  BadgeFamilySplitTests.swift
//  VariorumTests (Mac)
//
//  VX-934 — THE BADGE FAMILY SPLIT. Her ruling (the VX-914 handoff sitting,
//  2026-11-08, QUESTIONS #269, verbatim): "let's split the 'book' related
//  badges setting and if they're shown up completely from the AI one, and move
//  it out of MCP back to where it was. and lets have one setting for 'show
//  shared with AI and private from AI' badges (doesn't have to be those exact
//  words despite my quotes). and that setting should be in MCP."
//
//  The contract these pins state (an Improvement — the NEW contract, red on
//  old by construction: before this batch the shared icon read no switch at
//  all and the eye read `ownership_badges`):
//    - the BOOK marks (the also-in-other-books mark, the "owned by" chip) stay
//      on `ownership_badges` — its row back in Settings ▸ Editor;
//    - the AI PAIR (the shared-with-AI icon and the Private eye) draws under its
//      own synced switch (`ai_marks`, Settings ▸ MCP), read off the window's
//      road by both faces through ONE rule (`MCPAIMarksSwitch`);
//    - the new switch is an AND on top of the pair's own gates — an approved
//      client (R-878-K3 / VX-272) and the rows drawn (P1) — and reads nothing
//      itself; VX-900's dimmed server-off face rides the drawn pair unchanged.
//  The run record: `notes/plans/fixes/vx-915-recents-sweep.md`, BATCH 1.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withSplitWorld<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // Random ids: the probes are keyed by subject id across the whole test
        // host (the icon twins' rule), so these never collide with another suite's.
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 934))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A window's road as the windows build it (no sheet — the pins read faces).
@MainActor
private func road(aiMarksOn: Bool, serverOn: Bool = true, canShare: Bool = true) -> MCPShareRoad {
    MCPShareRoad(
        canShare: canShare, serverOn: serverOn, aiMarksOn: aiMarksOn, open: { _ in },
        sheet: { _, _ in AnyView(EmptyView()) }, revoke: { _ in })
}

/// An approved client's reach on a place through an always Home wing grant.
private func wingReach() -> MCPPlaceReach {
    let client = MCPClient(
        id: "vx934-c", name: "claude-code", version: nil, state: .approved,
        firstSeenAt: "", lastSeenAt: "", decidedAt: nil)
    return MCPPlaceReach(
        client: client, rung: .read,
        grant: MCPGrantRow(
            id: "vx934-g", clientID: client.id, rung: .read, scopeKind: .wing, scopeID: "",
            duration: .always, createdAt: "", consumedAt: nil, revokedAt: nil),
        throughTitle: "Home")
}

private let vault = Queries.BookRef(id: "vx934-b-vault", name: "the vault")
private let owner = Queries.BookRef(id: "vx934-b-owner", name: "the owner")
private let other = Queries.BookRef(id: "vx934-b-other", name: "another book")

@MainActor
@Suite("VX-934 — the badge family split: the book marks' switch and the AI pair's own", .serialized)
struct BadgeFamilySplitTests {
    /// The subject ids one rig draws — FRESH per rig (`tag`), so a closed
    /// rig's late `onDisappear` (the probes clear an entry equal to their own)
    /// can never clear the next rig's entries.
    private struct Subjects {
        let tag: String
        var ownNote: String { "vx934-n-own-\(tag)" }
        var viaNote: String { "vx934-n-via-\(tag)" }
        var ownBook: String { "vx934-b-own-\(tag)" }
        var ownedNote: String { "vx934-n-owned-\(tag)" }
        var sharedNote: String { "vx934-n-shared-\(tag)" }
        var eyes: [String] { [ownNote, viaNote, ownBook] }
    }

    private func drawnEyes(_ s: Subjects) -> [String: PrivateMarkFace.Mark] {
        PrivateMarkProbe.drawn.filter { s.eyes.contains($0.key) }
    }

    private func drawnBadges(_ s: Subjects) -> [String: OwnershipBadgeFace.Badge] {
        OwnershipBadgeProbe.drawn.filter { [s.ownedNote, s.sharedNote].contains($0.key) }
    }

    /// **Every mark a row can wear, exactly as the hosts compose them:** the
    /// AI pair from its faces under the window's road (whose switch the window
    /// reads off its theme store — `RootView.mcpRoad`), the book marks through
    /// `OwnershipBadgeFace` under `ownership_badges` (every badge host's call).
    private func marks(
        _ session: AppSession, _ s: Subjects, settings: Queries.ThemeSettings, serverOn: Bool = true
    ) -> some View {
        let tokens = VoiceTokens.studyLight
        let owned = Queries.OwnershipFacts(ownedBy: owner, otherBooks: [owner])
        let shared = Queries.OwnershipFacts(ownedBy: nil, otherBooks: [other])
        return VStack(alignment: .leading, spacing: 8) {
            MCPSharedIcon(reaches: [wingReach()], tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(mark: .ownNote(alsoVia: []), subjectID: s.ownNote, session: session),
                tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(mark: .viaBooks([vault]), subjectID: s.viaNote, session: session),
                tokens: tokens)
            PrivateMarkView(
                door: PrivateMarkDoor(
                    mark: .ownBook, subjectID: s.ownBook, subjectName: "the vault", session: session),
                tokens: tokens)
            if let badge = OwnershipBadgeFace.badge(
                owned, placement: .outside, badgesOn: settings.ownershipBadges) {
                OwnershipBadgeView(tokens: tokens, badge: badge, postID: s.ownedNote)
            }
            if let badge = OwnershipBadgeFace.badge(
                shared, placement: .inBook, badgesOn: settings.ownershipBadges) {
                OwnershipBadgeView(tokens: tokens, badge: badge, postID: s.sharedNote)
            }
        }
        .padding(12)
        .environment(\.mcpShareRoad, road(aiMarksOn: settings.aiMarks, serverOn: serverOn))
    }

    // MARK: - The rule, pure

    /// The ONE rule both faces read: the road's switch read OFF hides the
    /// pair; ON, or no road (a harness mount), draws it — the switch's own
    /// default. A flip is a change of the road, so every face reading it
    /// re-renders; the ask leg's gate (`indicatorOn`) is no part of the pair.
    @Test func theAIPairsSwitchIsOneRuleReadOffTheRoad() {
        #expect(!MCPAIMarksSwitch.drawn(aiMarksOn: false))
        #expect(MCPAIMarksSwitch.drawn(aiMarksOn: true))
        #expect(MCPAIMarksSwitch.drawn(aiMarksOn: nil), "no road: the pair draws as before (the default, ON)")
        #expect(road(aiMarksOn: true) != road(aiMarksOn: false), "a flip of her switch re-renders the faces")
        #expect(road(aiMarksOn: true) == road(aiMarksOn: true))
        #expect(road(aiMarksOn: false).indicatorOn == road(aiMarksOn: true).indicatorOn,
                "the pending-ask leg is no part of the pair — the switch never moves its gate")
    }

    /// The switch the faces read is the STORE's — the synced setting the
    /// theme store hands on (`ThemeStore.start` assigns the one read's value;
    /// the read itself is pinned headless, `OwnershipHideAndBadgesTests`) —
    /// and both windows hand exactly that value to their road. (No theme store
    /// is started here: its start adopts the app-wide editor typography, a
    /// global the parallel suites read.)
    @Test func theWindowsHandTheSyncedSwitchToTheRoad() async throws {
        try await withSplitWorld { session, db in
            try session.operations.setAIMarks(false)
            let settings = try await db.read { try Queries.themeSettings($0) }
            #expect(settings.aiMarks == false, "the store's switch is the settings' value")
            #expect(settings.ownershipBadges == true, "the book marks' switch is untouched by it")

            let app = URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Variorum")
            for window in ["RootView.swift", "Workspace/NoteWindowView.swift"] {
                let text = try String(contentsOf: app.appendingPathComponent(window), encoding: .utf8)
                #expect(text.contains("aiMarksOn: theme.settings.aiMarks,"), "\(window) hands the switch to its road")
            }
            let store = try String(contentsOf: app.appendingPathComponent("Theme/ThemeStore.swift"), encoding: .utf8)
            #expect(store.contains("try Queries.themeSettings(db)") && store.contains("settings = value"),
                    "the theme store lands the one settings read whole")
        }
    }

    // MARK: - The split, mounted (both directions)

    /// **(a) The AI switch OFF ⇒ neither AI mark draws while the owned-by
    /// chip (and the in-book mark) still does.** The control, the same rig
    /// shape: the switch back ON brings the pair — so the absence is the switch's.
    @Test func theAISwitchOffHidesTheSharedIconAndTheEyeWhileTheBookMarksStay() async throws {
        try await withSplitWorld { session, db in
            #if DEBUG
            try session.operations.setAIMarks(false)
            var settings = try await db.read { try Queries.themeSettings($0) }
            #expect(settings.aiMarks == false && settings.ownershipBadges == true, "fixture: AI off, badges on")
            let a = Subjects(tag: "off")
            let off = SharedIconRig(marks(session, a, settings: settings), width: 420, height: 260)
            let booksDrew = await off.poll(timeout: 6) { drawnBadges(a).count == 2 }
            await off.poll(timeout: 0.6) { false }  // room for an icon or an eye to (wrongly) arrive
            #expect(booksDrew, "the book marks drew (\(drawnBadges(a)))")
            #expect(drawnBadges(a)[a.ownedNote] == .ownedBy(owner), "the owned-by chip still draws")
            #expect(drawnBadges(a)[a.sharedNote] == .shared(["another book"]), "the in-book mark still draws")
            #expect(MCPSharedIconProbe.faces(in: off.window).isEmpty, "AI switch off: no shared icon")
            #expect(drawnEyes(a).isEmpty, "AI switch off: no eye on a note, a via-book note or a book (\(drawnEyes(a)))")
            off.close()

            // The control: the switch ON — the pair arrives in the same rig shape.
            try session.operations.setAIMarks(true)
            settings = try await db.read { try Queries.themeSettings($0) }
            let b = Subjects(tag: "on")
            let on = SharedIconRig(marks(session, b, settings: settings), width: 420, height: 260)
            defer { on.close() }
            let pairDrew = await on.poll(timeout: 6) {
                MCPSharedIconProbe.faces(in: on.window).count == 1 && drawnEyes(b).count == 3
                    && drawnBadges(b).count == 2
            }
            #expect(pairDrew, "control: the AI switch on — the shared icon, the three eyes and the book marks")
            #expect(drawnEyes(b)[b.viaNote] == .viaBooks([vault]), "the via-book eye is its own mark, as before")
            #endif
        }
    }

    /// **(b) The reverse — `ownership_badges` OFF ⇒ the book marks go while the
    /// AI pair still draws under its own switch** (the eye no longer follows the
    /// badge family — D-831-3's "no badges is no badges" superseded). VX-900's
    /// dimmed face rides the drawn pair unchanged: with the server off, the
    /// pair is drawn dimmed.
    @Test func theBadgeSwitchOffHidesTheBookMarksWhileTheAIPairStillDraws() async throws {
        try await withSplitWorld { session, db in
            #if DEBUG
            try session.operations.setOwnershipBadges(false)
            let settings = try await db.read { try Queries.themeSettings($0) }
            #expect(settings.ownershipBadges == false && settings.aiMarks == true, "fixture: badges off, AI on")
            for serverOn in [true, false] {
                let s = Subjects(tag: serverOn ? "server-on" : "server-off")
                let rig = SharedIconRig(marks(session, s, settings: settings, serverOn: serverOn), width: 420, height: 260)
                defer { rig.close() }
                let drew = await rig.poll(timeout: 6) {
                    MCPSharedIconProbe.faces(in: rig.window).count == 1 && drawnEyes(s).count == 3
                }
                await rig.poll(timeout: 0.4) { false }
                let label = serverOn ? "server on" : "server off"
                #expect(drew, "\(label): the AI pair draws with the badge family off")
                #expect(drawnBadges(s).isEmpty, "\(label): no owned-by chip, no in-book mark (\(drawnBadges(s)))")
                #expect(MCPSharedIconProbe.faces(in: rig.window).first?.dimmed == !serverOn,
                        "\(label): VX-900's face rides the pair unchanged")
                #expect(PrivateMarkProbe.faces[s.ownNote]?.dimmed == !serverOn)
            }
            #endif
        }
    }

    // MARK: - Both gates still AND in (the masthead, over a store)

    /// **The switch is an AND, never a door past the gates:** at the note's
    /// masthead (the real gated reads over a real store) — switch ON with no
    /// approved client draws neither mark; an approval with a wing grant draws
    /// both (the control); the switch OFF with that same approval draws
    /// neither. The masthead's held read never restarts for the switch (its
    /// task key carries no switch), so turning the pair off adds no read and
    /// drops none.
    @Test func theSwitchANDsOnTopOfTheApprovedClientGateAndTheRowsDrawn() async throws {
        try await withSplitWorld { session, _ in
            #if DEBUG
            let ops = session.operations
            let open = try ops.createPost(title: "an open page")
            _ = try ops.newBlock(in: open.id, text: "an open page text", registeringUndo: false)
            let secret = try ops.createPost(title: "a secret")
            _ = try ops.newBlock(in: secret.id, text: "a secret text", registeringUndo: false)
            try ops.setNotePrivate(secret.id, true)
            let tokens = VoiceTokens.studyLight

            @MainActor func mount(aiMarksOn: Bool) -> SharedIconRig {
                PrivateMarkProbe.faces[secret.id] = nil
                PrivateMarkProbe.drawn[secret.id] = nil
                return SharedIconRig(
                    VStack(alignment: .trailing, spacing: 8) {
                        MCPNoteIndicator(session: session, postID: open.id, tokens: tokens)
                        MCPNoteIndicator(session: session, postID: secret.id, tokens: tokens)
                    }
                    .padding(12)
                    .environment(\.mcpShareRoad, road(aiMarksOn: aiMarksOn)),
                    width: 320, height: 120)
            }

            // Switch ON, no approved client: neither mark (the gate stands).
            let unapproved = mount(aiMarksOn: true)
            await unapproved.poll(timeout: 1.2) { false }
            #expect(MCPSharedIconProbe.faces(in: unapproved.window).isEmpty, "switch on, no approved client: no icon")
            #expect(PrivateMarkProbe.faces[secret.id] == nil, "switch on, no approved client: no eye")
            unapproved.close()

            // The control: approved, a wing grant — both arrive (the open note's
            // icon; the Private note's eye — the wing grant never reaches it).
            let client = try ops.recordMCPContact(name: "claude-code", version: "2")
            try ops.approveMCPClient(client.id, granting: nil)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let approved = mount(aiMarksOn: true)
            let arrived = await approved.poll(timeout: 8) {
                MCPSharedIconProbe.faces(in: approved.window).count == 1 && PrivateMarkProbe.faces[secret.id] != nil
            }
            #expect(arrived, "control: approved + reached — the icon and the eye draw at the masthead")
            approved.close()

            // Switch OFF, the same approval: neither mark.
            let off = mount(aiMarksOn: false)
            await off.poll(timeout: 1.5) { false }
            #expect(MCPSharedIconProbe.faces(in: off.window).isEmpty, "switch off: no icon though a client reaches it")
            #expect(PrivateMarkProbe.faces[secret.id] == nil, "switch off: no eye though the note is Private")
            off.close()

            // Nothing new is read: the masthead's held read is keyed on the note
            // and the approved-client gate alone — never on the switch.
            let indicator = try String(
                contentsOf: URL(fileURLWithPath: #filePath)
                    .deletingLastPathComponent().deletingLastPathComponent()
                    .appendingPathComponent("Variorum/Core/Views/MCPNoteIndicator.swift"),
                encoding: .utf8)
            #expect(indicator.contains(".task(id: WatchKey(postID: postID, includingReach: drawsReach))"))
            #expect(!indicator.contains("aiMarks"), "the masthead never reads the switch — the faces do")
            #endif
        }
    }

    // MARK: - The one seam, by source

    /// Both faces read the ONE rule off the road — the switch's only reader
    /// besides the windows and the ⌘L ▾ menu's image of the shared icon — and
    /// no host passes the badge family's switch to the eye any more.
    @Test func bothFacesReadTheOneRuleAndNoHostHandsTheBadgeSwitchToTheEye() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Variorum")
        func source(_ path: String) throws -> String {
            try String(contentsOf: app.appendingPathComponent(path), encoding: .utf8)
        }
        #expect(try source("Core/Views/MCPSharedIcon.swift")
            .contains("if !reaches.isEmpty, MCPAIMarksSwitch.drawn(aiMarksOn: road?.aiMarksOn) {"))
        #expect(try source("Core/Views/PrivateMarkView.swift")
            .contains("if let door, MCPAIMarksSwitch.drawn(aiMarksOn: road?.aiMarksOn) {"))
        #expect(try source("Core/Views/WingSwitcherMenu.swift")
            .contains("shared: MCPAIMarksSwitch.drawn(aiMarksOn: road?.aiMarksOn)"),
                "the ⌘L ▾ menu's image of the shared icon follows the one rule")

        // The eye's rule takes no switch at all (the compiler holds every host
        // to it): the badge family's switch cannot reach the eye any more.
        let face = try source("Core/Views/PrivateMarkView.swift")
        #expect(face.contains("static func note(_ fact: Queries.PrivateMark?) -> Mark? {"))
        #expect(face.contains("static func book(marked: Bool) -> Mark? {"))
        #expect(!face.contains("badgesOn"), "the eye's face names no badge switch")

        let files = try #require(FileManager.default.enumerator(at: app, includingPropertiesForKeys: nil))
            .compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        var readers: [String] = []
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            if text.contains("MCPAIMarksSwitch.drawn(") { readers.append(file.lastPathComponent) }
        }
        #expect(!files.isEmpty, "the app's sources were read (non-vacuity)")
        #expect(Set(readers) == ["MCPSharedIcon.swift", "PrivateMarkView.swift", "WingSwitcherMenu.swift"],
                "the switch's rule is read by the two faces and the menu's image only (\(readers))")
    }
}
