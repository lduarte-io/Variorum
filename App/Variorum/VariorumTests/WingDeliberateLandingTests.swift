//
//  WingDeliberateLandingTests.swift
//  VariorumTests (Mac)
//
//  VX-833 (the VX-828 run, batch B) — her ask, verbatim: *"when you use the
//  wing picker in the upper left, it should automatically navigate you to the
//  bookcase of that wing. like you click in there for a reason it's annoying
//  to have to click again"* — and her final call: *"let's just keep landing in
//  the bookcase. i want it to be consistent."*
//
//  THE MECHANISM (traced, B0): every switcher door switched the app's one
//  wing (`WingState.currentID`) and nothing else — the focused pane kept
//  whatever it showed, so she stood in the old place in the new room.
//
//  THE FIX: ONE deliberate road, `WingsModel.goTo(_:saying:)` — the wing
//  switches (when it is another) and the window's wired landing asks the
//  shell's one request road for the Bookcase (`RootView.wireWingLanding` →
//  `pendingSelection = .shelf`). Every switcher door rides it (the fork's
//  ruling Q-B2 (a)): ⌘L's sheet (and so the toolbar label that opens it), the
//  masthead ▾ list, the masthead word's cycle — and the ⌘digit chord
//  (`WingNumberKeysTests`). A deliberate pick of the CURRENT wing lands too
//  (P-828-1 (ii)(a)), switching nothing and saying nothing. The follow and
//  the other switches (New Wing…, Delete Wing, revalidation, Compare's go-to,
//  MCP) never land.
//
//  RED ON OLD: on the pre-fix tree there is no landing at all — the revert
//  recipe (R-B2, the record) removes the one `landInBookcase()` call in
//  `WingsModel.goTo`, and every "lands" expectation here goes red while the
//  switch / receipt / never-lands lines stay green.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWingWorld<T>(
    _ body: @MainActor (AppSession, WingsModel, ShellRouter) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 833))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let wings = WingsModel(session: session)
        let router = ShellRouter()
        // The window's own wiring — exactly what `RootView.wireWorkspace` runs.
        RootView.wireWingLanding(wings: wings, router: router)
        return try await body(session, wings, router)
    }
}

@MainActor
private func settle(until condition: () -> Bool) async {
    for _ in 0..<200 where !condition() {
        try? await Task.sleep(for: .milliseconds(5))
    }
}

@MainActor
@Suite("VX-833 — a deliberate wing switch lands in that wing's Bookcase", .serialized)
struct WingDeliberateLandingTests {
    /// The said road (⌘L's sheet, the cycle, the chord): the wing switches,
    /// "Now in …" is said, and the focused pane is asked for the Bookcase.
    @Test func theSaidRoadSwitchesSaysAndLandsOnTheBookcase() async throws {
        try await withWingWorld { session, wings, router in
            let studio = try session.operations.createWing(name: "studio")
            await wings.load()
            #expect(router.pendingSelection == nil, "premise: nothing asked yet")

            wings.switchSaying(studio.id)
            #expect(session.wing.currentID == studio.id, "the wing switched")
            #expect(session.status.spoken?.text == "Now in \u{201C}studio\u{201D}.", "the existing receipt")
            #expect(router.pendingSelection == .shelf, "…and she lands on its Bookcase (VX-833)")
        }
    }

    /// The ▾ list's pick stays SILENT (13i-d) and lands like every other door.
    @Test func theMenuListsPickLandsSilently() async throws {
        try await withWingWorld { session, wings, router in
            let studio = try session.operations.createWing(name: "studio")
            await wings.load()
            wings.goTo(studio.id, saying: false)
            #expect(session.wing.currentID == studio.id)
            #expect(session.status.spoken == nil, "the list says nothing — she reads the name she picked")
            #expect(router.pendingSelection == .shelf, "the list's pick lands on the Bookcase")
        }
    }

    /// The masthead word's cycle — the fourth door — lands too (Q-B2 (a): no
    /// door carved out; the re-aim cost is recorded for her morning).
    @Test func theMastheadCycleLands() async throws {
        try await withWingWorld { session, wings, router in
            let studio = try session.operations.createWing(name: "studio")
            await wings.load()
            wings.cycle()
            #expect(session.wing.currentID == studio.id, "the next wing")
            #expect(router.pendingSelection == .shelf, "the cycle lands on the Bookcase")
        }
    }

    /// ⌘L's sheet: a commit — the CURRENT wing's included (P-828-1 (ii)(a)) —
    /// lands; the current wing's commit switches nothing and says nothing.
    @Test func theSheetsCommitLandsTheCurrentWingIncluded() async throws {
        try await withWingWorld { session, wings, router in
            let studio = try session.operations.createWing(name: "studio")
            await wings.load()

            let model = WingSwitcherModel(wings: wings)
            #expect(model.apply(.commit(studio.id)), "a commit closes the switcher")
            #expect(session.wing.currentID == studio.id)
            #expect(router.pendingSelection == .shelf)

            router.pendingSelection = nil
            session.status.clear()
            let again = WingSwitcherModel(wings: wings)
            let outcome = again.brain.returnPressed()
            #expect(outcome == .commit(studio.id), "⏎ on the current row is a deliberate pick of it")
            #expect(again.apply(outcome))
            #expect(session.wing.currentID == studio.id, "nothing switched")
            #expect(session.status.spoken == nil, "nothing said — the wing did not change")
            #expect(router.pendingSelection == .shelf, "but she lands on its Bookcase")
        }
    }

    /// Only DELIBERATE switches land. The follow (open/focus of a cross-wing
    /// note), the plain switch the wing acts use (New Wing…'s switch-in,
    /// Delete Wing's return to Home, revalidation) and the session's own
    /// switch (Compare's lineage go-to, the MCP door's wing landing) never
    /// ask for the Bookcase — the ruling's untouched list.
    @Test func theFollowAndTheOtherSwitchesNeverLand() async throws {
        try await withWingWorld { session, wings, router in
            let ops = session.operations
            let studio = try ops.createWing(name: "studio")
            let note = try ops.createPost(title: "studio note", wingId: studio.id)
            await wings.load()

            let workspace = WorkspaceModel()
            WingFollow.wire(workspace: workspace, session: session)
            workspace.select(.post(note.id))
            await settle { session.wing.currentID == studio.id }
            #expect(session.wing.currentID == studio.id, "premise: the follow switched")
            #expect(router.pendingSelection == nil, "the follow never lands — the note stays open")

            wings.switchTo("")
            #expect(session.wing.currentID == "")
            #expect(router.pendingSelection == nil, "the wing acts' plain switch never lands")

            session.wing.switchTo(studio.id)
            #expect(router.pendingSelection == nil, "Compare's go-to and the MCP road never land")

            #expect(await wings.mint(named: "letters"), "premise: minted")
            #expect(router.pendingSelection == nil, "New Wing…'s switch-in never lands")
        }
    }

    /// A model no window wired lands nowhere (a pin, a preview) — and the
    /// window wires it in `wireWorkspace` (composition by source, the
    /// `QuickEntryWingLabelTests` precedent).
    @Test func theWindowWiresItsLanding() throws {
        let root = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/RootView.swift"),
            encoding: .utf8)
        let wiring = try #require(root.range(of: "private func wireWorkspace() {"))
        let body = String(root[wiring.upperBound...].prefix(6_000))
        #expect(body.contains("Self.wireWingLanding(wings: wings, router: router)"),
                "the window wires its deliberate switches to its own Bookcase")
    }
}
