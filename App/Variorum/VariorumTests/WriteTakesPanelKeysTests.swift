//
//  WriteTakesPanelKeysTests.swift
//  VariorumTests
//
//  VX-150 (the VX-143 run, batch 2) — the sibling of VX-135's ⌘⏎ pin
//  (`WriteTakesPanelChooseTests`): Write's take panel answers the REST of the
//  take keys itself, on ITS block.
//
//  THE MECHANISM (traced in the run record, "Batch 2 traces"): every take key
//  is a menu item routed through `CommandRouter`'s LIFO stack. Since VX-135
//  the panel's handler is the top while it is mounted, but it claimed only
//  `.takes(.choose)`, so ⌃⌘←/→, ⌘T, ⌥⌘T, ⇧⌥⌘T and ⌘⇧A fell through to
//  Write's `EditorView.handleRouted`, whose arms all address Write's CARET:
//  stepping re-opened the caret block's panel (swapping the sheet when the
//  panel had come from another block's ⑂ badge), the mints grew the caret
//  block from the take Write SHOWS there, and ⌘⇧A archived that shown take —
//  never the take the panel's ring is in.
//
//  The pins drive the real panel over a fanned block that is NOT Write's
//  caret block (the ⑂-badge case), with a stand-in for Write's handler
//  registered beneath it that consumes every take key exactly as the real
//  one does. RED ON OLD: the stand-in swallows the keys and nothing happens
//  to the panel's block.
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
@Suite("Write's take panel — the take keys act on the panel's block (VX-150)", .serialized)
struct WriteTakesPanelKeysTests {
    // MARK: - The harness

    private struct Fixture {
        let session: AppSession
        let db: AppDatabase
        let postID: String
        /// Write's caret block in the app — a one-take block the panel is
        /// NOT showing.
        let caretBlockID: String
        /// The fanned block the panel shows (opened from its ⑂ badge).
        let panelBlockID: String
        /// The panel block's takes in fan order (asserted against the store);
        /// the first is chosen.
        let takeIDs: [String]
    }

    private struct TakeRow: Equatable {
        let id: String
        let text: String
        let status: String
    }

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panelPanes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView,
           pane.identifier?.rawValue.hasPrefix("pane:panel|") == true {
            found.append(pane)
        }
        for sub in view.subviews { found.append(contentsOf: panelPanes(in: sub)) }
        return found
    }

    /// The take whose pane is live in the panel — the ring (nil unless
    /// exactly one pane is live).
    private func ringTake(in view: NSView) -> String? {
        let live = livePanes(in: view)
        return live.count == 1 ? live[0] : nil
    }

    private func livePanes(in view: NSView) -> [String] {
        panelPanes(in: view).filter(\.isEditable).compactMap {
            $0.identifier?.rawValue.replacingOccurrences(of: "pane:panel|", with: "")
        }
    }

    private func takes(_ db: AppDatabase, blockID: String) async throws -> [TakeRow] {
        try await db.read { db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT id, working_text, status FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID]
            ).map { TakeRow(id: $0["id"], text: $0["working_text"], status: $0["status"]) }
        }
    }

    private func chosenVariant(_ db: AppDatabase, blockID: String) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(
                db,
                sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
        }
    }

    /// Polls the store (the acts run through the async runner) while the
    /// window keeps settling, until `predicate` holds or the budget runs out.
    private func waitForStore(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () async throws -> Bool
    ) async throws {
        for _ in 0..<60 {
            if try await predicate() { return }
            await settle(window, hosting, until: { false }, maxTurns: 1)
        }
    }

    /// Mounts the real panel over the fanned block with Write's stand-in
    /// beneath it, runs `body`, and tears both down.
    private func withPanel(
        seed: UInt64,
        _ body: (Fixture, NSWindow, NSHostingView<WriteTakesPanel>, LockIsolated<[TakesCommand]>)
            async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let post = try ops.createPost(title: "the take keys post")
            let caret = try ops.newBlock(in: post.id, text: "the caret block — Write's caret is here")
            let fanned = try ops.newBlock(in: post.id, text: "the shown take")
            let second = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(second.id, text: "the second take", charDelta: 4)
            // A branch lands right AFTER its source in the fan, so the third
            // branches from the second to keep the fan in this order.
            let third = try ops.branchVariant(fanned.block.id, from: second.id)
            try ops.autosave(third.id, text: "the third take", charDelta: 4)
            let fixture = Fixture(
                session: session, db: db, postID: post.id,
                caretBlockID: caret.block.id, panelBlockID: fanned.block.id,
                takeIDs: [fanned.variant.id, second.id, third.id])

            // Write's handler, standing beneath the sheet exactly as
            // `EditorView` registers it: its `.takes` arms consume EVERY take
            // key (in the app they act on the caret block).
            let writeSaw = LockIsolated<[TakesCommand]>([])
            let writeToken = session.commandRouter.registerHandler { command in
                guard case .takes(let takes) = command else { return false }
                writeSaw.withValue { $0.append(takes) }
                return true
            }
            defer { session.commandRouter.unregisterHandler(writeToken) }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 800, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: WriteTakesPanel(
                    session: session, postID: post.id, blockID: fanned.block.id))
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { panelPanes(in: hosting).count >= 3 })
            #expect(panelPanes(in: hosting).count == 3, "the panel shows the fanned block's three takes")
            #expect(try await takes(db, blockID: fanned.block.id).map(\.id) == fixture.takeIDs,
                    "the fixture's fan order is the store's")

            try await body(fixture, window, hosting, writeSaw)
        }
    }

    /// The ring goes into `variantID`'s pane by the real click road.
    private func clickInto(
        _ variantID: String, _ window: NSWindow, _ hosting: NSView
    ) async throws {
        let pane = try #require(panelPanes(in: hosting).first {
            $0.identifier?.rawValue == "pane:panel|\(variantID)"
        })
        pane.onPlainClick?(0)
        await settle(window, hosting, until: { pane.isEditable })
        #expect(pane.isEditable, "the clicked take is the live one — the ring is in it")
    }

    /// The menu item's exact act (`ShellActions.dispatch` is
    /// `router.dispatch(command)`).
    private func press(_ command: TakesCommand, _ fixture: Fixture) {
        fixture.session.commandRouter.dispatch(.takes(command))
    }

    // MARK: - ⌃⌘← / ⌃⌘→

    @Test func theStepKeysMoveTheRingThroughThePanelsTakes() async throws {
        try await withPanel(seed: 150) { fixture, window, hosting, writeSaw in
            try await clickInto(fixture.takeIDs[0], window, hosting)

            press(.stepNext, fixture)
            await settle(window, hosting, until: { ringTake(in: hosting) == fixture.takeIDs[1] })
            #expect(ringTake(in: hosting) == fixture.takeIDs[1],
                    "⌃⌘→ moved the ring to the panel's second take (live: \(livePanes(in: hosting)))")

            press(.stepNext, fixture)
            await settle(window, hosting, until: { ringTake(in: hosting) == fixture.takeIDs[2] })
            #expect(ringTake(in: hosting) == fixture.takeIDs[2],
                    "⌃⌘→ again — the third take")

            press(.stepPrev, fixture)
            await settle(window, hosting, until: { ringTake(in: hosting) == fixture.takeIDs[1] })
            #expect(ringTake(in: hosting) == fixture.takeIDs[1],
                    "⌃⌘← stepped back to the second take")

            #expect(writeSaw.value.isEmpty,
                    "the panel answered the step keys — Write's caret door never saw them (saw \(writeSaw.value))")
        }
    }

    // MARK: - ⌘⇧A

    @Test func theArchiveKeyArchivesTheTakeTheRingIsIn() async throws {
        try await withPanel(seed: 151) { fixture, window, hosting, writeSaw in
            try await clickInto(fixture.takeIDs[1], window, hosting)

            press(.archive, fixture)
            var rows: [TakeRow] = []
            try await waitForStore(window, hosting) {
                rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
                return rows.first { $0.id == fixture.takeIDs[1] }?.status == "archived"
            }
            #expect(rows.first { $0.id == fixture.takeIDs[1] }?.status == "archived",
                    "⌘⇧A archived the take the ring is in (rows: \(rows.map(\.status)))")
            #expect(rows.first { $0.id == fixture.takeIDs[0] }?.status == "active",
                    "the shown take is untouched")
            #expect(try await chosenVariant(fixture.db, blockID: fixture.panelBlockID) == fixture.takeIDs[0],
                    "the chosen pointer never moved")
            #expect(writeSaw.value.isEmpty,
                    "Write's caret door never saw ⌘⇧A (saw \(writeSaw.value))")
        }
    }

    // MARK: - ⌘T · ⌥⌘T · ⇧⌥⌘T

    @Test func theMintKeysGrowThePanelsBlockAndTheRingFollows() async throws {
        try await withPanel(seed: 152) { fixture, window, hosting, writeSaw in
            try await clickInto(fixture.takeIDs[1], window, hosting)

            // ⌘T — a copy of the take the ring is in, on the panel's block.
            press(.branch, fixture)
            var rows: [TakeRow] = []
            try await waitForStore(window, hosting) {
                rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
                return rows.count == 4
            }
            #expect(rows.count == 4, "⌘T grew the panel's block by one take (\(rows.count))")
            let branched = rows.first { !fixture.takeIDs.contains($0.id) }
            #expect(branched?.text == "the second take",
                    "⌘T copied the take the ring is in (got \(branched?.text ?? "nil"))")
            await settle(window, hosting, until: { ringTake(in: hosting) == branched?.id })
            #expect(branched != nil && ringTake(in: hosting) == branched?.id,
                    "the ring followed onto the new take")

            // ⌥⌘T — a blank take on the panel's block; never chosen (R90).
            press(.blank, fixture)
            try await waitForStore(window, hosting) {
                rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
                return rows.count == 5
            }
            #expect(rows.count == 5, "⌥⌘T grew the panel's block by a blank take (\(rows.count))")
            let blank = rows.first { !fixture.takeIDs.contains($0.id) && $0.id != branched?.id }
            #expect(blank?.text == "", "⌥⌘T's take is blank")
            await settle(window, hosting, until: { ringTake(in: hosting) == blank?.id })
            #expect(ringTake(in: hosting) == blank?.id, "the ring followed onto the blank take")
            #expect(try await chosenVariant(fixture.db, blockID: fixture.panelBlockID) == fixture.takeIDs[0],
                    "minting never chooses (R90)")

            // ⇧⌥⌘T — the power variant: blank AND chosen, on the panel's block.
            press(.blankChoose, fixture)
            try await waitForStore(window, hosting) {
                rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
                return rows.count == 6
            }
            #expect(rows.count == 6, "⇧⌥⌘T grew the panel's block (\(rows.count))")
            let powerTake = rows.first {
                !fixture.takeIDs.contains($0.id) && $0.id != branched?.id && $0.id != blank?.id
            }
            let chosenNow = try await chosenVariant(fixture.db, blockID: fixture.panelBlockID)
            #expect(powerTake != nil && chosenNow == powerTake?.id && powerTake?.text == "",
                    "⇧⌥⌘T's blank take is the chosen one")

            #expect(try await takes(fixture.db, blockID: fixture.caretBlockID).count == 1,
                    "Write's caret block grew nothing")
            #expect(writeSaw.value.isEmpty,
                    "Write's caret door never saw the mint keys (saw \(writeSaw.value))")
        }
    }

    /// With no take clicked into, ⌘T copies what the block SHOWS — the panel's
    /// own "＋ new take (branch)" door, which advertises ⌘T (PROVISIONAL — the
    /// Takes bar's "+ take" rule: the ring's take, else what's shown).
    @Test func theBranchKeyWithoutARingCopiesWhatIsShown() async throws {
        try await withPanel(seed: 153) { fixture, window, hosting, writeSaw in
            #expect(ringTake(in: hosting) == nil, "nothing clicked into yet")

            press(.branch, fixture)
            var rows: [TakeRow] = []
            try await waitForStore(window, hosting) {
                rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
                return rows.count == 4
            }
            let branched = rows.first { !fixture.takeIDs.contains($0.id) }
            #expect(branched?.text == "the shown take",
                    "⌘T with no ring branched the shown take (got \(branched?.text ?? "nil"))")
            await settle(window, hosting, until: { ringTake(in: hosting) == branched?.id })
            #expect(branched != nil && ringTake(in: hosting) == branched?.id,
                    "the ring landed on the new take")
            #expect(writeSaw.value.isEmpty, "Write's caret door never saw ⌘T (saw \(writeSaw.value))")
        }
    }

    // MARK: - What still belongs to Write (characterization — green on both sides)

    @Test func theBloomAndLensKeysStillReachWriteAndEverythingReturnsWhenThePanelCloses()
        async throws
    {
        try await withPanel(seed: 154) { fixture, window, hosting, writeSaw in
            for key in [TakesCommand.toggleFan, .closeAll, .saveLens] {
                press(key, fixture)
            }
            #expect(writeSaw.value == [.toggleFan, .closeAll, .saveLens],
                    "⌘⇧T, ⎋ and ⌘⇧L are not the panel's — they reach Write (saw \(writeSaw.value))")

            // Lifecycle: with the panel gone, every take key is Write's again.
            window.contentView = NSView()
            await settle(window, hosting, until: { false }, maxTurns: 4)
            writeSaw.setValue([])
            let family: [TakesCommand] = [.choose, .stepPrev, .stepNext, .branch, .blank,
                                          .blankChoose, .archive]
            for key in family { press(key, fixture) }
            #expect(writeSaw.value == family,
                    "after the panel closes the take keys are Write's again (saw \(writeSaw.value))")
        }
    }
}
