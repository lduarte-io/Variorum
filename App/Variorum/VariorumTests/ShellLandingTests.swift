//
//  ShellLandingTests.swift
//  VariorumTests
//
//  17o c/d/e round 1, MAJOR-2 — **a navigation expires a parked block
//  landing.**
//
//  The cold review traced it end to end: Stage C's parked target was
//  `@State` on `RootView`, written by the block-naming door and by nothing
//  else — every ordinary navigation door (`opener`/`openHere`, the
//  sidebar's own binding, ⌘K's rows, the back/forward chips, the open-post
//  broadcast) goes through `adopt`, which never touched it. So a park was
//  never consumed and never expired: re-entering the container re-landed a
//  block clicked an hour ago, against row 42/U-20's ruled promise that
//  every door into Write lands at the REMEMBERED caret. 17o batch e added a
//  new way to park one (a snippet card, for a POOL container), which is why
//  this lands with that batch.
//
//  The park lives on `ShellRouter` now — per-window navigation state on the
//  object the shell's doors already speak to (P-4, `pendingSelection`'s own
//  reason) — which is also what makes the rule readable by a pin at all.
//
//  Red-on-old is by BEHAVIORAL REVERT on the committed tree (the house
//  method, this batch's own): `adopt`'s `router.park(nil)` removed in place.
//  Numbers in the batch record.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, as arithmetic

@Suite("The shell's parked block landing (17o c/d/e round 1, MAJOR-2)")
@MainActor
struct ShellLandingRuleTests {
    @Test func aParkAnswersOnlyForItsOwnContainerAndOnlyUntilTheNextNavigation() {
        let router = ShellRouter()
        #expect(router.blockLanding == nil, "nothing is parked at rest")
        #expect(router.landing(for: "X") == nil)

        router.park(ShellRouter.BlockLanding(containerID: "X", blockID: "b3"))
        #expect(router.landing(for: "X") == "b3", "the container the door named")
        #expect(router.landing(for: "Y") == nil, "…and no other")

        // What every ordinary navigation does: name no block.
        router.park(nil)
        #expect(router.blockLanding == nil)
        #expect(router.landing(for: "X") == nil,
                "a park does not outlive the navigation that follows it")
    }

    /// A second park replaces the first outright — two containers can never
    /// both be waiting for a landing.
    @Test func asecondParkReplacesTheFirst() {
        let router = ShellRouter()
        router.park(ShellRouter.BlockLanding(containerID: "X", blockID: "b1"))
        router.park(ShellRouter.BlockLanding(containerID: "Y", blockID: "b9"))
        #expect(router.landing(for: "X") == nil)
        #expect(router.landing(for: "Y") == "b9")
    }
}

// MARK: - The reviewer's scenario, through the real shell

@Suite("A navigation expires the park (17o c/d/e round 1, MAJOR-2)", .serialized)
@MainActor
struct ShellLandingMountTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 8,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    /// **THE SCENARIO, exactly as the review designed it.** Open note X at
    /// block 3 through a block-naming door; put her caret somewhere else in
    /// X; navigate away to Y and back to X through the ordinary door — the
    /// park is gone, and Write lands where she LEFT the caret, not on the
    /// block a door named a navigation ago.
    ///
    /// Red on the pre-fix rule at the FIRST assertion (`adopt` cleared
    /// nothing, so the park survived the trip to Y) and again at the last
    /// (the surviving park re-seeded the caret at block 3's start).
    @Test func aTripAwayAndBackExpiresTheParkAndLandsAtTheRememberedCaret() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            let noteX = try session.operations.createPost(title: "X")
            var blocks: [String] = []
            for text in [
                "the first paragraph of note X, long enough to hold a caret.",
                "the second paragraph of note X.",
                "the third paragraph of note X — the one a door named.",
            ] {
                blocks.append(try session.operations.newBlock(
                    in: noteX.id, text: text, at: .end).block.id)
            }
            let noteY = try session.operations.createPost(title: "Y")
            _ = try session.operations.newBlock(in: noteY.id, text: "note Y.", at: .end)

            let slots = try await db.read { [id = noteX.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let blockOneStart = index.range(ofEntryAt: 0).location
            let blockThreeStart = index.range(ofEntryAt: 2).location
            #expect(blockThreeStart > blockOneStart)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.close()
                session.commandRouter.forgetCurrentBlock(for: noteX.id)
                session.commandRouter.forgetCurrentBlock(for: noteY.id)
                UserDefaults.standard.removeObject(forKey: "postMode.\(noteX.id)")
                UserDefaults.standard.removeObject(forKey: "postMode.\(noteY.id)")
            }
            _ = await Self.settle(window, hosting) {
                router.workspace.history().current != nil
            }

            // 1. The BLOCK-NAMING door: navigate to X and park block 3 — the
            //    two halves `RootView.open(_:blockID:)` performs.
            router.pendingSelection = .post(noteX.id)
            #expect(await Self.settle(window, hosting) {
                router.workspace.focusedSelection == .post(noteX.id)
            }, "X is showing")
            router.park(ShellRouter.BlockLanding(
                containerID: noteX.id, blockID: blocks[2]))
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockThreeStart
            }, "the named block is where the caret lands (wanted \(blockThreeStart))")

            // 2. Her caret moves into block 1; the surface reports it, and
            //    that report is what row 42/U-20 promises to bring back.
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            editor.setSelectedRange(NSRange(location: blockOneStart + 4, length: 0))
            #expect(await Self.settle(window, hosting) {
                session.commandRouter.currentBlock(for: noteX.id)?.blockID == blocks[0]
            }, "the caret's block is remembered")

            // 3. Away to Y through the ORDINARY door (the road the sidebar,
            //    ⌘K, the chips and the broadcast all share).
            router.pendingSelection = .post(noteY.id)
            #expect(await Self.settle(window, hosting) {
                router.workspace.focusedSelection == .post(noteY.id)
            }, "Y is showing")
            #expect(router.blockLanding == nil,
                    "RED ON OLD: the park did not survive the navigation")
            #expect(router.landing(for: noteX.id) == nil)

            // 4. Back to X through the same ordinary door: no park, so Write
            //    lands at the caret she left — not at block 3.
            router.pendingSelection = .post(noteX.id)
            #expect(await Self.settle(window, hosting) {
                router.workspace.focusedSelection == .post(noteX.id)
            }, "X is showing again")
            #expect(router.landing(for: noteX.id) == nil,
                    "…and coming back names no block either")
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockOneStart + 4
            }, "RED ON OLD: Write lands at the remembered caret \(blockOneStart + 4), not at the block a door named a navigation ago (\(blockThreeStart))")
        }
    }
}
