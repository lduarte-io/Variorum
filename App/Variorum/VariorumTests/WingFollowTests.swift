//
//  WingFollowTests.swift
//  VariorumTests
//
//  17y B3 item (f) — THE CROSS-WING FOLLOW (the shape RULED by her 2026-10-04
//  — QUESTIONS #174's refinement): the app's ONE wing switches on OPEN of a
//  cross-wing note, with the quiet "Now in X" receipt; under split panes it
//  follows the FOCUSED pane's note on focus too; a same-wing open stays
//  silent; editors NEVER close on a wing switch; cross-wing Open rows carry
//  a wing indicator.
//
//  The workspace raises what the focused pane is asked to show
//  (`onFocusedSubjectChanged` — the `onNotesLeft` precedent: driven here
//  without SwiftUI), and `WingFollow.wire` is the shell's own wiring, so these
//  pins run the production road end to end.
//
//  A ruled BUILD (no red-on-old owed); the walk captures the face.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withFollowWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 29))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(until condition: () -> Bool) async {
    for _ in 0..<200 where !condition() {
        try? await Task.sleep(for: .milliseconds(5))
    }
}

@Suite("17y (f) — the cross-wing follow: the pure decision")
struct WingFollowDecisionTests {
    @Test func onlyAnotherWingIsFollowed() {
        #expect(WingFollow.decision(current: "", subjectWing: "studio") == .switchTo("studio"))
        #expect(WingFollow.decision(current: "studio", subjectWing: "") == .switchTo(""))
        #expect(WingFollow.decision(current: "studio", subjectWing: "studio") == .stay)
        #expect(WingFollow.decision(current: "", subjectWing: nil) == .stay,
                "a subject with no wing (the Bookcase, Snippets…) is never followed")
        #expect(WingFollow.nowIn("Studio", isHome: false) == "Now in \u{201C}Studio\u{201D}.")
        #expect(WingFollow.nowIn("Home", isHome: true) == "Now in Home.")
    }
}

@MainActor
@Suite("17y (f) — the cross-wing follow, through the workspace", .serialized)
struct WingFollowTests {
    /// OPEN: a note living in another wing switches the app's one wing to
    /// it, and the quiet receipt says so.
    @Test func openingACrossWingNoteSwitchesTheWingWithTheReceipt() async throws {
        try await withFollowWorld { session, _ in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let note = try ops.createPost(title: "studio note", wingId: studio.id)
            let workspace = WorkspaceModel()
            WingFollow.wire(workspace: workspace, session: session)
            #expect(session.wing.currentID == "")

            workspace.select(.post(note.id))
            await settle { session.wing.currentID == studio.id }
            #expect(session.wing.currentID == studio.id)
            #expect(session.status.spoken?.kind == .receipt)
            #expect(session.status.spoken?.text == "Now in \u{201C}Studio\u{201D}.")
            #expect(workspace.focusedSelection == .post(note.id), "the note stays open")
        }
    }

    /// A same-wing open stays silent — no switch, no receipt.
    @Test func aSameWingOpenStaysSilent() async throws {
        try await withFollowWorld { session, _ in
            let note = try session.operations.createPost(title: "home note")
            let workspace = WorkspaceModel()
            WingFollow.wire(workspace: workspace, session: session)
            workspace.select(.post(note.id))
            try await Task.sleep(for: .milliseconds(120))
            #expect(session.wing.currentID == "")
            #expect(session.status.spoken == nil, "nothing said")
        }
    }

    /// SPLIT PANES: focus moving to the other pane follows ITS note; focus
    /// moving back follows back — and neither editor ever closes.
    @Test func underSplitPanesTheWingFollowsTheFocusedPanesNote() async throws {
        try await withFollowWorld { session, _ in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let homeNote = try ops.createPost(title: "home note")
            let studioNote = try ops.createPost(title: "studio note", wingId: studio.id)
            let workspace = WorkspaceModel()
            WingFollow.wire(workspace: workspace, session: session)

            workspace.select(.post(homeNote.id))
            let beside = workspace.openBeside(.post(studioNote.id))
            guard case .opened(let rightPane) = beside else {
                Issue.record("the split opened: \(beside)")
                return
            }
            await settle { session.wing.currentID == studio.id }
            #expect(session.wing.currentID == studio.id, "the new focused pane's note leads")

            workspace.focus(.primary)
            await settle { session.wing.currentID == "" }
            #expect(session.wing.currentID == "", "focus back on the Home note — Home")
            #expect(session.status.spoken?.text == "Now in Home.")

            workspace.focus(rightPane)
            await settle { session.wing.currentID == studio.id }
            #expect(session.wing.currentID == studio.id)

            // Editors NEVER close on a wing switch (wings scope listings).
            #expect(workspace.panes.count == 2)
            #expect(workspace.selections[.primary] == .post(homeNote.id))
            #expect(workspace.selections[rightPane] == .post(studioNote.id))
        }
    }

    /// A switch the SWITCHER made is never undone by a standing pane: only a
    /// fresh open or a focus move is followed.
    @Test func theSwitchersChoiceStandsUntilAnOpenOrAFocusMove() async throws {
        try await withFollowWorld { session, _ in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let homeNote = try ops.createPost(title: "home note")
            let workspace = WorkspaceModel()
            WingFollow.wire(workspace: workspace, session: session)
            workspace.select(.post(homeNote.id))
            try await Task.sleep(for: .milliseconds(60))

            session.wing.switchTo(studio.id)  // the masthead switcher
            try await Task.sleep(for: .milliseconds(120))
            #expect(session.wing.currentID == studio.id, "the pane's standing note pulls nothing")

            workspace.select(.post(homeNote.id))  // she OPENS it again (the Open row)
            await settle { session.wing.currentID == "" }
            #expect(session.wing.currentID == "", "an open is followed")
        }
    }

    /// The Open rows' indicator: only notes of ANOTHER wing are named.
    @Test func theIndicatorNamesOnlyCrossWingRows() async throws {
        try await withFollowWorld { session, db in
            let ops = session.operations
            let studio = try ops.createWing(name: "Studio")
            let homeNote = try ops.createPost(title: "home note")
            let studioNote = try ops.createPost(title: "studio note", wingId: studio.id)
            let fromHome = try await db.read { db in
                try WingFollow.crossWingNames(
                    db, noteIDs: [homeNote.id, studioNote.id], current: "")
            }
            #expect(fromHome == [studioNote.id: "Studio"])
            let fromStudio = try await db.read { db in
                try WingFollow.crossWingNames(
                    db, noteIDs: [homeNote.id, studioNote.id], current: studio.id)
            }
            #expect(fromStudio == [homeNote.id: "Home"])
        }
    }
}
