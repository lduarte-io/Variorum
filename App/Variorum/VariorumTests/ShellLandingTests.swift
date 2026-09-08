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

    /// **Round 2's MAJOR, as arithmetic: a park is SPENT when it lands, and
    /// the identity generation does not move when it is.** The second half
    /// is the whole reason the identity keys on the generation rather than
    /// on the block — a spend that changed the key would rebuild the very
    /// view that had just landed.
    @Test func aParkIsSpentOnceAndTheGenerationDoesNotMoveWhenItIs() {
        let router = ShellRouter()
        #expect(router.landingGeneration(for: "X") == 0,
                "a container never opened at a block never churns its identity")

        router.park(ShellRouter.BlockLanding(containerID: "X", blockID: "b3"))
        #expect(router.landingGeneration(for: "X") == 1)
        #expect(router.landing(for: "X") == "b3")

        router.spendLanding(for: "X")
        #expect(router.landing(for: "X") == nil, "spent — a re-mount lands nowhere")
        #expect(router.landingGeneration(for: "X") == 1,
                "…and the identity is untouched, so the landed view survives")

        // Spending again, and spending someone else's, are free.
        router.spendLanding(for: "X")
        router.park(ShellRouter.BlockLanding(containerID: "X", blockID: "b7"))
        router.spendLanding(for: "Y")
        #expect(router.landing(for: "X") == "b7", "another container's spend is not ours")
        #expect(router.landingGeneration(for: "X") == 2,
                "a NEW park DOES move the identity — that is what re-lands her")
    }

    /// The one adoption door's landing, assembled in one place: only a
    /// container that can hold a landing gets one, and only when a block is
    /// actually named.
    @Test func onlyAContainerDestinationNamingABlockMakesALanding() {
        #expect(ShellRouter.BlockLanding(.post("p"), blockID: "b")
                == ShellRouter.BlockLanding(containerID: "p", blockID: "b"))
        #expect(ShellRouter.BlockLanding(.pool("s"), blockID: "b")
                == ShellRouter.BlockLanding(containerID: "s", blockID: "b"))
        #expect(ShellRouter.BlockLanding(.post("p"), blockID: nil) == nil,
                "an ordinary navigation names none")
        #expect(ShellRouter.BlockLanding(.reading("r"), blockID: "b") == nil)
        #expect(ShellRouter.BlockLanding(.library, blockID: "b") == nil)
    }
}

// MARK: - The reviewer's scenario, through the real shell

@Suite("A navigation expires the park (17o c/d/e round 1, MAJOR-2)", .serialized)
@MainActor
struct ShellLandingMountTests {
    nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    static func settle(
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

    static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
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

    /// **ROUND 2's MAJOR — a RE-MOUNT is not a navigation.** The shell
    /// re-creates the note's detail whenever the pane stops being the live
    /// one (a split's other pane taking focus, a second window becoming
    /// key), and the landing is applied in `onAppear`, which fires on every
    /// mount. With the park unspent, coming back threw her to the block a
    /// door named instead of the caret she left — U-20/row 42 again, by a
    /// road no navigation door passes through.
    ///
    /// Red on HEAD before this fix (a new finding, so red-on-HEAD is the
    /// test): the second mount re-jumped to block 3 and `landing(for: X)`
    /// still answered.
    @Test func aRemountAfterAFocusRoundTripLandsAtTheRememberedCaret() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
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
            let slots = try await db.read { [id = noteX.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let blockOneStart = index.range(ofEntryAt: 0).location
            let blockThreeStart = index.range(ofEntryAt: 2).location

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
                UserDefaults.standard.removeObject(forKey: "postMode.\(noteX.id)")
            }
            _ = await Self.settle(window, hosting) {
                router.workspace.history().current != nil
            }

            // The block door, then her caret elsewhere in the same note.
            router.pendingSelection = .post(noteX.id)
            let showing = await Self.settle(window, hosting) {
                router.workspace.focusedSelection == .post(noteX.id)
            }
            #expect(showing, "X is showing")
            router.park(ShellRouter.BlockLanding(
                containerID: noteX.id, blockID: blocks[2]))
            let landedOnThree = await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockThreeStart
            }
            #expect(landedOnThree, "the named block is where the caret lands")
            #expect(router.landing(for: noteX.id) == nil,
                    "RED ON HEAD: the park is SPENT the moment it lands")

            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            editor.setSelectedRange(NSRange(location: blockOneStart + 4, length: 0))
            let remembered = await Self.settle(window, hosting) {
                session.commandRouter.currentBlock(for: noteX.id)?.blockID == blocks[0]
            }
            #expect(remembered, "the caret's block is remembered")

            // A FOCUS ROUND TRIP — no navigation anywhere: the pane stops
            // being live, its detail unmounts, and it comes back.
            router.openBeside(.shelf)
            let split = await Self.settle(window, hosting) {
                router.workspace.panes.count == 2
                    && router.workspace.focusedPane != .primary
                    // The note's detail must actually be GONE before the trip
                    // back, or SwiftUI coalesces the two focus moves into one
                    // update, nothing re-mounts, and the last assertion below
                    // stops discriminating (measured — the first cut of this
                    // pin passed under the revert probe for exactly that).
                    && Self.views(EditorTextView.self, in: hosting).isEmpty
            }
            #expect(split, "the split's second pane has the focus and the note's detail is unmounted")
            router.workspace.focus(.primary)
            let backLive = await Self.settle(window, hosting) {
                router.workspace.focusedPane == .primary
            }
            #expect(backLive, "and the note's pane is live again")

            #expect(router.landing(for: noteX.id) == nil,
                    "nothing is waiting to re-throw her")
            let remount = await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockOneStart + 4
            }
            #expect(remount, "RED ON HEAD: the re-mount lands at the remembered caret \(blockOneStart + 4), not at the named block (\(blockThreeStart))")
        }
    }
}

// MARK: - The block-naming door, through the real road (round 2, MINOR-1)

@Suite("The shell's block-naming door navigates AND parks (17o c/d/e round 2, MINOR-1)", .serialized)
@MainActor
struct ShellLandingDoorTests {
    /// **The order, held where it lives.** Round 1 shipped the rule as two
    /// statements in `RootView.open` — adopt (which clears) then park — and
    /// nothing held it: `open` is private, every production caller is a view
    /// closure, and both existing pins reach past the shell (one calls
    /// `router.park` itself, the other mounts `PoolDetailView` directly), so
    /// reversing the two lines left the suite green while the whole Stage C
    /// landing road died. The landing is folded into the one adoption door
    /// now — an order that cannot be expressed — and this drives the REAL
    /// door through the shell's own DEBUG publication of it.
    @Test func theDoorNavigatesAndLeavesItsLandingParked() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            let note = try session.operations.createPost(title: "X")
            let one = try session.operations.newBlock(in: note.id, text: "first.", at: .end)
            let two = try session.operations.newBlock(in: note.id, text: "second.", at: .end)
            _ = one

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.close()
                ShellRouter.blockNamingDoor = nil
                session.commandRouter.forgetCurrentBlock(for: note.id)
                UserDefaults.standard.removeObject(forKey: "postMode.\(note.id)")
            }
            _ = await ShellLandingMountTests.settle(window, hosting) {
                ShellRouter.blockNamingDoor != nil
            }
            let door = try #require(ShellRouter.blockNamingDoor,
                                    "the mounted shell publishes its block-naming door")

            // THE REAL ROAD: one call, both halves.
            door(.post(note.id), two.block.id)
            #expect(router.workspace.focusedSelection == .post(note.id),
                    "it navigated")
            #expect(router.landing(for: note.id) == two.block.id,
                    "RED on a reversed order: …and its landing is parked, not eaten")

            // And a door that names NO block expires it, through the same road.
            door(.library, nil)
            #expect(router.workspace.focusedSelection == .library)
            #expect(router.landing(for: note.id) == nil)
        }
    }
}
