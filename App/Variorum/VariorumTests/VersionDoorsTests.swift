//
//  VersionDoorsTests.swift
//  VariorumTests
//
//  **VX-440 batch 1 — the doors onto a saved moment** (R-440-1 · R-440-2; the
//  record is `notes/plans/fixes/vx-440-sheets-history-clarity.md`, LIVE STATUS
//  → Batch 1): "Compare with Latest Version" (File · both `note ▾` · ⌘K,
//  rendered only while the note HAS a moment — P-2), a Versions row's "Compare
//  with now", and the full-size face.
//
//  The registry and router pins are pure; the detail pins DRIVE THE REAL
//  MOUNTED `PostDetailView` (the `NoteVersionsPaneTests` harness), because the
//  availability fact is the detail's own held observation.
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
@Suite("VX-440 batch 1 — the doors onto a saved moment", .serialized)
struct VersionDoorsTests {
    // MARK: - B1-4: "Compare with Latest Version", declared (P-1) and gated (P-2)

    @Test func theLatestVersionDoorIsDeclaredOnFileTheBarsAndThePalette() {
        let door = CapabilityRegistry.capability(.compareWithLatestVersion)
        #expect(door.verb == "Compare with Latest Version")
        #expect(door.scope == .post)
        #expect(door.doors == [.menuBar, .bottomBar, .palette])
        #expect(door.shortcutLabel == nil, "no chord was asked for")
        #expect(!door.unavailableNote.isEmpty)
        #expect(EditorCommands.menuRendered.contains(.compareWithLatestVersion))
        #expect(ShellActions.paletteActs.contains(.compareWithLatestVersion))
        for bar in [CommitBar.renderedCapabilities, TakesBottomBar.renderedCapabilities] {
            #expect(bar.contains(.compareWithLatestVersion), "both bars (R6-2)")
        }
    }

    /// **It acts exactly where a note's detail is mounted AND that note has a
    /// moment** — with none it could only refuse (P-2), and with no detail
    /// there is no Compare mode to land in.
    @Test func theLatestVersionDoorActsOnlyWhereTheNoteHasAMoment() {
        func availability(_ context: CapabilityContext) -> Capability.Availability {
            CapabilityRegistry.availability(.compareWithLatestVersion, in: context)
        }
        #expect(availability(CapabilityContext(mode: .write)) == .unavailable,
                "a note with no saved moment: no door")
        #expect(availability(CapabilityContext(mode: nil, noteHasSavedVersion: true)) == .unavailable,
                "no detail mounted: nothing to switch to Compare")
        for mode in PostMode.allCases {
            #expect(availability(CapabilityContext(mode: mode, noteHasSavedVersion: true)) == .act,
                    "\(mode): a mounted note with a moment")
        }
    }

    /// **The fact is the MOUNTED note's, and only its.** A late report from a
    /// departing detail is dropped; a different note's arrival and the detail
    /// leaving both clear it.
    @Test func theRoutersLatestVersionFactBelongsToTheMountedNote() {
        let router = CommandRouter()
        let token = router.registerDetail(postID: "note-a", mode: .write, applyMode: { _ in })
        router.noteLatestVersion("moment-b", postID: "note-b")
        #expect(router.activeNoteLatestVersionID == nil, "another note's report is dropped")
        router.noteLatestVersion("moment-a", postID: "note-a")
        #expect(router.activeNoteLatestVersionID == "moment-a")
        #expect(router.currentContext().noteHasSavedVersion)
        #expect(router.isEnabled(.compareWithLatestVersion))

        _ = router.registerDetail(postID: "note-c", mode: .write, applyMode: { _ in })
        #expect(router.activeNoteLatestVersionID == nil, "the arriving note reports its own")
        router.noteLatestVersion("moment-c", postID: "note-c")
        router.unregisterDetail(token)  // a stale teardown changes nothing
        #expect(router.activeNoteLatestVersionID == "moment-c")
    }

    /// **The road onto the board** — parked for the anchor, then Compare
    /// requested; a switch refused for another note takes the parcel back.
    @Test func requestCompareParksTheLandingAndSwitchesToCompare() {
        let router = CommandRouter()
        var applied: [PostMode] = []
        _ = router.registerDetail(postID: "note-a", mode: .write, applyMode: { applied.append($0) })
        #expect(router.requestCompare(postID: "note-a", peers: ["moment-a"]))
        #expect(applied == [.compare])
        #expect(router.pendingCompareLanding == CompareLanding(postID: "note-a", peerIDs: ["moment-a"]))

        router.pendingCompareLanding = nil
        router.refuse = { _ in }
        #expect(!router.requestCompare(postID: "note-b", peers: ["moment-b"]),
                "a stale target is refused (and speaks)")
        #expect(router.pendingCompareLanding == nil, "…leaving nothing armed for a later board")
    }

    /// **⌘K lists it only while the note has a moment** (P-2); the harness'
    /// every-row listing (the walk) still carries it.
    @Test func thePaletteListsTheLatestDoorOnlyWhileTheNoteHasAMoment() throws {
        let db = try AppDatabase.inMemory()
        withDependencies { $0.database = db } operation: {
            let session = AppSession(database: db)
            let actions = ShellActions(session: session, shell: ShellRouter())
            let verb = CapabilityRegistry.capability(.compareWithLatestVersion).verb
            let facts = WingPaletteDoors.Facts(focus: .note("note-a"), wingCount: 1)
            #expect(!actions.paletteEntries(listing: facts, noteHasSavedVersion: false)
                .map(\.title).contains(verb))
            #expect(actions.paletteEntries(listing: facts, noteHasSavedVersion: true)
                .map(\.title).contains(verb))
            #expect(actions.paletteEntries(listing: nil).map(\.title).contains(verb),
                    "every-row listing (the registry walk's) carries every declared row")
        }
    }

    // MARK: - B1-4, mounted: the detail's held fact, and "Compare with now"

    /// **The mounted detail tells the router its note's newest moment** — so the
    /// door appears the moment ⌘⇧S saves one, follows the next save, and goes
    /// when the last one is promoted.
    @Test func theMountedDetailReportsItsNotesNewestMomentLive() async throws {
        try await mounted { session, post, window, hosting in
            let router = session.commandRouter
            await Self.settle(window, hosting) { router.activePostID == post }
            #expect(router.activeNoteLatestVersionID == nil)
            #expect(!router.isEnabled(.compareWithLatestVersion), "no moment, no door")

            let first = try await session.runner.run { ops in try ops.saveNoteVersion(post).post.id }
            await Self.settle(window, hosting) { router.activeNoteLatestVersionID == first }
            #expect(router.activeNoteLatestVersionID == first)
            #expect(router.isEnabled(.compareWithLatestVersion))

            let second = try await session.runner.run { ops in try ops.saveNoteVersion(post).post.id }
            await Self.settle(window, hosting) { router.activeNoteLatestVersionID == second }
            #expect(router.activeNoteLatestVersionID == second, "the newest, always")

            try await session.runner.run { ops in
                try ops.promoteNoteVersion(second, of: post)
                try ops.promoteNoteVersion(first, of: post)
            }
            await Self.settle(window, hosting) { router.activeNoteLatestVersionID == nil }
            #expect(!router.isEnabled(.compareWithLatestVersion), "the last moment left: the door goes")
        }
    }

    /// **"Compare with now" lands the moment beside the note in Compare** — the
    /// Versions row's door, through the real mounted detail: the mode switches
    /// and the arriving board consumes the landing parked for it.
    @Test func compareWithNowLandsTheMomentBesideTheNoteInCompare() async throws {
        try await mounted { session, post, window, hosting in
            let router = session.commandRouter
            await Self.settle(window, hosting) { router.activePostID == post }
            try await session.runner.run { ops in _ = try ops.saveNoteVersion(post) }
            let moment = try #require(try await session.database.read {
                try Queries.noteVersions($0, of: post)
            }.first)
            let model = NoteVersionsModel(session: session, postID: post)
            #expect(model.canCompareHere, "the note's detail is the mounted one")
            model.compareWithNow(moment)
            await Self.settle(window, hosting) {
                router.activeMode == .compare && router.pendingCompareLanding == nil
            }
            #expect(router.activeMode == .compare, "the detail switched to Compare")
            #expect(router.pendingCompareLanding == nil, "…and its board took the landing")

            let elsewhere = NoteVersionsModel(session: session, postID: "another-note")
            #expect(!elsewhere.canCompareHere,
                    "over a note whose detail is not mounted the door is not drawn (P-2)")
        }
    }

    // MARK: - Harness (the `NoteVersionsPaneTests` mount)

    private func mounted(
        _ body: @escaping (AppSession, String, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note")
            _ = try session.operations.newBlock(
                in: post.id, text: "A block, so the page has one.")
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            try await body(session, post.id, window, hosting)
        }
    }

    private nonisolated static func pump(_ seconds: TimeInterval = 0.03) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView,
        maxTurns: Int = 80, until predicate: () -> Bool
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }
}
