//
//  WriteTakesPanelRoutedTests.swift
//  VariorumTests
//
//  VX-154 (the VX-282 run, U3) — the third pin of the class VX-135 opened and
//  VX-150 widened: while Write's take panel is up, EVERY routed command about
//  a block or a take acts on the PANEL's block, never on Write's caret block
//  beneath the sheet.
//
//  THE MECHANISM (traced in `notes/plans/fixes/vx-282-editor-notes-fixes.md`
//  § U3): the menu bar and ⌘K dispatch through `CommandRouter`'s LIFO handler
//  stack. The panel is the top while it is mounted, but its handler claimed
//  only `.takes(…)`, so ⌘S, comments, callout, copy-all-takes, the take↔block
//  pair, history, origin, delete/archive/insert block and the structural verbs
//  all fell through to Write's `EditorView.handleRouted`, whose arms address
//  Write's CARET — another block entirely when the panel came from a ⑂ badge —
//  and ⌘⇧T swapped the sheet to the caret block's panel.
//
//  The pins drive the real panel over a fanned block that is NOT Write's caret
//  block, with a stand-in for Write's handler registered beneath it that
//  consumes EVERY routed command, exactly as the real one does (the strongest
//  shape for this class — the VX-143 ladder's word). Each asserts against the
//  STORE where the act writes, and against the stand-in's log where it routes.
//  The panel's own model is passed in so a pin can read the request state its
//  acts set (the commit field, the comments and history presentations).
//
//  RED ON OLD where marked (the pins were committed ahead of the fix; the
//  pre-fix product is that commit's). GUARD = green on both sides by design.
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
@Suite("Write's take panel — every routed command acts on the panel's block (VX-154)", .serialized)
struct WriteTakesPanelRoutedCommandTests {
    // MARK: - The harness

    private struct Fixture {
        let session: AppSession
        let db: AppDatabase
        let postID: String
        /// Write's caret block in the app — a one-take block the panel is NOT
        /// showing.
        let caretBlockID: String
        let caretVariantID: String
        /// The fanned block the panel shows (opened from its ⑂ badge).
        let panelBlockID: String
        /// The panel block's takes in fan order (asserted against the store);
        /// the first is chosen.
        let takeIDs: [String]
        /// The panel's own model (the pin's road in).
        let model: TakesViewModel
        /// What Write's stand-in consumed beneath the sheet.
        let writeSaw: LockIsolated<[RoutedCommand]>
        /// How many times the panel asked its host to close it.
        let closes: LockIsolated<Int>
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

    private func livePanes(in view: NSView) -> [String] {
        panelPanes(in: view).filter(\.isEditable).compactMap {
            $0.identifier?.rawValue.replacingOccurrences(of: "pane:panel|", with: "")
        }
    }

    /// The take whose pane is live in the panel — the ring (nil unless exactly
    /// one pane is live).
    private func ringTake(in view: NSView) -> String? {
        let live = livePanes(in: view)
        return live.count == 1 ? live[0] : nil
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

    /// The note's placed blocks, in order, with the text each renders.
    private func page(_ db: AppDatabase, postID: String) async throws
        -> [(blockID: String, text: String)]
    {
        try await db.read { db in
            try Queries.renderPost(db, containerID: postID).map { ($0.blockID, $0.text ?? "") }
        }
    }

    private func blockColumn(
        _ db: AppDatabase, _ column: String, blockID: String
    ) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(
                db, sql: "SELECT \(column) FROM block WHERE id = ?", arguments: [blockID])
        }
    }

    private func commits(_ db: AppDatabase) async throws -> [(variantID: String, message: String?)] {
        try await db.read { db in
            try Row.fetchAll(
                db, sql: "SELECT variant_id, message FROM commit_point ORDER BY created_at, id"
            ).map { ($0["variant_id"], $0["message"]) }
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
    /// beneath it, runs `body`, and tears both down. `mergedPanelBlock` makes
    /// the panel's block a MERGE result, so it has released originals behind
    /// it (the origin door's positive case).
    private func withPanel(
        seed: UInt64, mergedPanelBlock: Bool = false,
        _ body: (Fixture, NSWindow, NSHostingView<WriteTakesPanel>) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_950_400)
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
            // Write's full-document editor is mounted beneath the sheet in the
            // app — the registry's context says so (the router's own wire).
            session.commandRouter.writeEditorAttached = { true }
            let ops = session.operations
            let post = try ops.createPost(title: "the routed commands post")
            let caret = try ops.newBlock(in: post.id, text: "the caret block — Write's caret is here")
            let panelBlockID: String
            let shownID: String
            if mergedPanelBlock {
                let left = try ops.newBlock(in: post.id, text: "the left half")
                let right = try ops.newBlock(in: post.id, text: "the right half")
                let merged = try ops.merge(left.block.id, right.block.id)
                panelBlockID = merged.block.id
                shownID = merged.variant.id
            } else {
                let fanned = try ops.newBlock(in: post.id, text: "the shown take")
                panelBlockID = fanned.block.id
                shownID = fanned.variant.id
            }
            let second = try ops.branchVariant(panelBlockID, from: shownID)
            try ops.autosave(second.id, text: "the second take", charDelta: 4)
            // A branch lands right AFTER its source in the fan, so the third
            // branches from the second to keep the fan in this order.
            let third = try ops.branchVariant(panelBlockID, from: second.id)
            try ops.autosave(third.id, text: "the third take", charDelta: 4)

            // Write's handler, standing beneath the sheet exactly as
            // `EditorView` registers it: it consumes EVERY routed command (in
            // the app its arms act on the caret block; `.pageFan` and a find
            // with no bar are the only ones the real one declines).
            let writeSaw = LockIsolated<[RoutedCommand]>([])
            let writeToken = session.commandRouter.registerHandler { command in
                writeSaw.withValue { $0.append(command) }
                return true
            }
            defer { session.commandRouter.unregisterHandler(writeToken) }

            let model = TakesViewModel(session: session, postID: post.id)
            let closes = LockIsolated(0)
            let fixture = Fixture(
                session: session, db: db, postID: post.id,
                caretBlockID: caret.block.id, caretVariantID: caret.variant.id,
                panelBlockID: panelBlockID, takeIDs: [shownID, second.id, third.id],
                model: model, writeSaw: writeSaw, closes: closes)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 800, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.attachedSheet.map { window.endSheet($0) }
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: WriteTakesPanel(
                    session: session, postID: post.id, blockID: panelBlockID,
                    onClose: { closes.withValue { $0 += 1 } }, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { panelPanes(in: hosting).count >= 3 })
            #expect(panelPanes(in: hosting).count == 3, "the panel shows the fanned block's three takes")
            #expect(try await takes(db, blockID: panelBlockID).map(\.id) == fixture.takeIDs,
                    "the fixture's fan order is the store's")

            try await body(fixture, window, hosting)
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

    /// The menu item's (and the ⌘K row's) exact act: `router.dispatch`.
    private func press(_ command: RoutedCommand, _ fixture: Fixture) {
        fixture.session.commandRouter.dispatch(command)
    }

    // MARK: - ⌘S (row 1)

    /// RED ON OLD: ⌘S fell through to Write — the stand-in saw it, and the
    /// panel never asked.
    @Test func commitAsksForTheTakeTheRingIsInAndFilesIt() async throws {
        try await withPanel(seed: 1540) { fixture, window, hosting in
            try await clickInto(fixture.takeIDs[1], window, hosting)

            press(.commit, fixture)
            await settle(window, hosting, until: { fixture.model.savepointAsk != nil }, maxTurns: 12)
            #expect(fixture.writeSaw.value.isEmpty,
                    "⌘S is the panel's — Write's caret door never saw it (saw \(fixture.writeSaw.value))")
            let ask = try #require(fixture.model.savepointAsk,
                                   "the panel asked for a name — the commit door's field")
            #expect(ask.targetID == fixture.takeIDs[1], "the ask names the take the ring is in")

            // The field's ⏎ (the popover's onFile is exactly this call).
            await fixture.model.fileSavepoint(named: "vx154")
            var rows: [(variantID: String, message: String?)] = []
            try await waitForStore(window, hosting) {
                rows = try await commits(fixture.db)
                return !rows.isEmpty
            }
            #expect(rows.map(\.variantID) == [fixture.takeIDs[1]],
                    "ONE commit, on the ring's take (\(rows.map(\.variantID)))")
            #expect(rows.first?.message == "vx154", "named as she typed it")
            #expect(!rows.contains { $0.variantID == fixture.caretVariantID },
                    "Write's caret take committed nothing")
        }
    }

    /// RED ON OLD. With no take clicked into, ⌘S commits what the block SHOWS
    /// (PROVISIONAL P-U3-1 — P-VX150-1's rule): the ring moves onto it, so the
    /// take being committed is the one that wears the ring.
    @Test func commitWithNoRingAsksForWhatTheBlockShows() async throws {
        try await withPanel(seed: 1541) { fixture, window, hosting in
            #expect(ringTake(in: hosting) == nil, "nothing clicked into yet")

            press(.commit, fixture)
            await settle(window, hosting, until: {
                fixture.model.savepointAsk != nil && ringTake(in: hosting) != nil
            }, maxTurns: 12)
            #expect(fixture.writeSaw.value.isEmpty,
                    "⌘S is the panel's (saw \(fixture.writeSaw.value))")
            #expect(fixture.model.savepointAsk?.targetID == fixture.takeIDs[0],
                    "the ask names the take the block shows")
            #expect(ringTake(in: hosting) == fixture.takeIDs[0],
                    "the ring moved onto it — the take being committed wears the ring")
        }
    }

    // MARK: - Comments · callout · copy all takes (rows 2–4)

    /// RED ON OLD: the stand-in consumed ⌘⇧' and no sheet came up.
    @Test func commentsOpenOnThePanelsBlockInThePanel() async throws {
        try await withPanel(seed: 1542) { fixture, window, hosting in
            press(.comments, fixture)
            await settle(window, hosting, until: { window.attachedSheet != nil }, maxTurns: 20)
            #expect(fixture.writeSaw.value.isEmpty,
                    "⌘⇧' is the panel's (saw \(fixture.writeSaw.value))")
            #expect(fixture.model.commentsRequest?.blockID == fixture.panelBlockID,
                    "the comments are the PANEL's block's")
            #expect(window.attachedSheet != nil,
                    "…and the panel presented them (P-2: the door acts where it was pressed)")
        }
    }

    /// RED ON OLD: the frame landed nowhere (the stand-in consumed it).
    @Test func theCalloutFramesThePanelsBlock() async throws {
        try await withPanel(seed: 1543) { fixture, window, hosting in
            press(.callout(.toggle), fixture)
            var framed: String?
            try await waitForStore(window, hosting) {
                framed = try await blockColumn(fixture.db, "presentation", blockID: fixture.panelBlockID)
                return framed != nil
            }
            #expect(framed?.contains(BlockPresentation.calloutKind) == true,
                    "⌥⌘C framed the panel's block (\(framed ?? "nil"))")
            #expect(try await blockColumn(fixture.db, "presentation", blockID: fixture.caretBlockID) == nil,
                    "Write's caret block stays plain")
            #expect(fixture.writeSaw.value.isEmpty, "the callout is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    /// RED ON OLD: the clipboard never received the panel's fan.
    @Test func copyAllTakesCopiesThePanelsFan() async throws {
        let board = NSPasteboard.general
        let saved = board.string(forType: .string)
        defer {
            board.clearContents()
            if let saved { board.setString(saved, forType: .string) }
        }
        board.clearContents()
        board.setString("vx154 sentinel", forType: .string)
        try await withPanel(seed: 1544) { fixture, window, hosting in
            press(.copyAllTakes, fixture)
            var copied = ""
            try await waitForStore(window, hosting) {
                copied = board.string(forType: .string) ?? ""
                return copied != "vx154 sentinel"
            }
            #expect(copied.contains("the second take") && copied.contains("the third take"),
                    "⌘⇧C copied the panel's block's whole fan (\(copied))")
            #expect(!copied.contains("the caret block"), "…never the caret block's")
            #expect(fixture.writeSaw.value.isEmpty, "the copy is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    // MARK: - The take↔block pair (rows 5–6)

    /// RED ON OLD: nothing moved. After the act the ring does NOT land on the
    /// minted block (`parkFocus` hands it a pane the panel never renders) —
    /// the panel's ring never leaves its block.
    @Test func aTakeIntoABlockBelowMovesTheRingsTakeAndTheRingStaysHome() async throws {
        try await withPanel(seed: 1545) { fixture, window, hosting in
            try await clickInto(fixture.takeIDs[1], window, hosting)

            press(.takeToBlockBelow, fixture)
            var blocks: [(blockID: String, text: String)] = []
            try await waitForStore(window, hosting) {
                blocks = try await page(fixture.db, postID: fixture.postID)
                return blocks.count == 3
            }
            #expect(blocks.map(\.text) == [
                "the caret block — Write's caret is here", "the shown take", "the second take",
            ], "the ring's take is now the block right below the PANEL's block (\(blocks.map(\.text)))")
            let rows = try await takes(fixture.db, blockID: fixture.panelBlockID)
            #expect(rows.first { $0.id == fixture.takeIDs[1] }?.status == "archived",
                    "its original is archived on the panel's block (AR-1)")
            #expect(try await takes(fixture.db, blockID: fixture.caretBlockID).count == 1,
                    "Write's caret block is untouched")
            await settle(window, hosting, until: { false }, maxTurns: 10)
            #expect(fixture.model.focusedPane == nil,
                    "the ring did not follow onto the minted block, a pane the panel never renders (\(String(describing: fixture.model.focusedPane)))")
            #expect(fixture.writeSaw.value.isEmpty, "⌥⌘⏎ is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    /// RED ON OLD (the stand-in consumed it). With no take clicked into, ⌥⌘⏎
    /// refuses as the Takes board does (PROVISIONAL P-U3-3 — ⌘⇧A's precedent:
    /// an act that takes a take OUT of the fan needs the ring).
    @Test func aTakeIntoABlockBelowWithNoRingRefusesAndMovesNothing() async throws {
        try await withPanel(seed: 1546) { fixture, window, hosting in
            press(.takeToBlockBelow, fixture)
            await settle(window, hosting, until: { fixture.model.status != nil }, maxTurns: 12)
            #expect(fixture.model.status?.isRefusal == true,
                    "the panel refused, in the panel (\(fixture.model.status?.text ?? "nil"))")
            let blockCount = try await page(fixture.db, postID: fixture.postID).count
            let fan = try await takes(fixture.db, blockID: fixture.panelBlockID)
            #expect(blockCount == 2, "no block was minted")
            #expect(fan.allSatisfy { $0.status == "active" }, "no take left the fan")
            #expect(fixture.writeSaw.value.isEmpty, "never handed to Write (saw \(fixture.writeSaw.value))")
        }
    }

    /// RED ON OLD.
    @Test func allTakesIntoBlocksActsOnThePanelsBlock() async throws {
        try await withPanel(seed: 1547) { fixture, window, hosting in
            press(.takesToBlocks, fixture)
            var blocks: [(blockID: String, text: String)] = []
            try await waitForStore(window, hosting) {
                blocks = try await page(fixture.db, postID: fixture.postID)
                return blocks.count == 4
            }
            #expect(blocks.map(\.text) == [
                "the caret block — Write's caret is here", "the shown take",
                "the second take", "the third take",
            ], "the panel's block's other takes became the blocks below it (\(blocks.map(\.text)))")
            #expect(try await takes(fixture.db, blockID: fixture.caretBlockID).count == 1,
                    "Write's caret block is untouched")
            #expect(fixture.writeSaw.value.isEmpty, "⌥⇧⌘⏎ is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    // MARK: - History · origin (rows 7–8)

    /// RED ON OLD. No post detail is mounted in the harness, so the router's
    /// inspector road declines and the panel presents the board's fallback
    /// sheet itself (in the app the inspector opens — the walk's row).
    @Test func blockHistoryOpensForThePanelsBlock() async throws {
        try await withPanel(seed: 1548) { fixture, window, hosting in
            press(.showBlockHistory, fixture)
            await settle(window, hosting, until: { window.attachedSheet != nil }, maxTurns: 20)
            #expect(fixture.model.blockHistoryRequest?.blockID == fixture.panelBlockID,
                    "History is the PANEL's block's")
            #expect(window.attachedSheet != nil, "…presented by the panel where no inspector exists")
            #expect(fixture.writeSaw.value.isEmpty, "History is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    /// RED ON OLD. The panel's block is a merge; its released originals open
    /// in its History pane, as the origin door does everywhere.
    @Test func originOpensThePanelsBlocksOriginals() async throws {
        try await withPanel(seed: 1549, mergedPanelBlock: true) { fixture, window, hosting in
            press(.showOriginBlock, fixture)
            await settle(window, hosting, until: { fixture.model.blockHistoryRequest != nil }, maxTurns: 20)
            #expect(fixture.model.blockHistoryRequest?.blockID == fixture.panelBlockID,
                    "the origin door opened the PANEL's block's History")
            #expect(fixture.writeSaw.value.isEmpty, "the origin door is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    // MARK: - Delete · archive the block (rows 9–10)

    /// RED ON OLD. The panel's block goes, the panel shows its own gone face,
    /// and the ring — parked on the survivor by the board's arm — does NOT
    /// land on a block the panel never renders.
    @Test func deleteBlockDeletesThePanelsBlockAndTheRingNeverLeavesIt() async throws {
        try await withPanel(seed: 1550) { fixture, window, hosting in
            try await clickInto(fixture.takeIDs[1], window, hosting)

            press(.deleteBlock, fixture)
            var deletedAt: String?
            try await waitForStore(window, hosting) {
                deletedAt = try await blockColumn(fixture.db, "deleted_at", blockID: fixture.panelBlockID)
                return deletedAt != nil
            }
            #expect(deletedAt != nil, "the PANEL's block was deleted")
            #expect(try await blockColumn(fixture.db, "deleted_at", blockID: fixture.caretBlockID) == nil,
                    "Write's caret block stands")
            await settle(window, hosting, until: { panelPanes(in: hosting).isEmpty })
            #expect(panelPanes(in: hosting).isEmpty, "the panel shows its gone face")
            await settle(window, hosting, until: { false }, maxTurns: 10)
            #expect(fixture.model.focusedPane == nil,
                    "the ring did not land on the survivor (\(String(describing: fixture.model.focusedPane)))")
            #expect(fixture.writeSaw.value.isEmpty, "Delete Block is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    /// RED ON OLD.
    @Test func archiveBlockArchivesThePanelsBlock() async throws {
        try await withPanel(seed: 1551) { fixture, window, hosting in
            press(.archiveBlock, fixture)
            var archivedAt: String?
            try await waitForStore(window, hosting) {
                archivedAt = try await blockColumn(fixture.db, "archived_at", blockID: fixture.panelBlockID)
                return archivedAt != nil
            }
            #expect(archivedAt != nil, "the PANEL's block was archived")
            #expect(try await blockColumn(fixture.db, "archived_at", blockID: fixture.caretBlockID) == nil,
                    "Write's caret block stays")
            #expect(fixture.writeSaw.value.isEmpty, "Archive Block is the panel's (saw \(fixture.writeSaw.value))")
        }
    }

    // MARK: - The verbs that act where she writes (rows 11–14)

    /// RED ON OLD: every door was live and every command fell to Write. While
    /// the panel is up these are GREY by the registry's data (P-1/P-2), and a
    /// dispatch that reaches the panel anyway is consumed with the panel's
    /// line — never handed to Write's caret.
    @Test func theWriteVerbsAreGreyWhileThePanelIsUpAndNeverReachTheCaret() async throws {
        try await withPanel(seed: 1552) { fixture, window, hosting in
            let grey: [(CapabilityID, RoutedCommand)] = [
                (.divide, .structural(.divide)),
                (.divideWithCeremony, .structural(.divideWithCeremony)),
                (.extract, .structural(.extract)),
                (.makeBlock, .structural(.makeBlock)),
                (.merge, .structural(.merge)),
                (.mergeWithCeremony, .structural(.mergeWithCeremony)),
                (.deleteInEveryTake, .deleteInEveryTake),
                (.insertBlockBelow, .insertBlockBelow),
                (.addBlockAtEnd, .addBlockAtEnd),
            ]
            for (id, _) in grey {
                #expect(!fixture.session.commandRouter.isEnabled(id),
                        "\(id) is grey while the panel is up")
            }
            for (_, command) in grey {
                press(command, fixture)
            }
            await settle(window, hosting, until: { false }, maxTurns: 8)
            #expect(fixture.writeSaw.value.isEmpty,
                    "none reached Write's caret (saw \(fixture.writeSaw.value))")
            #expect(fixture.model.status?.isRefusal == true,
                    "the panel said so, in the panel (\(fixture.model.status?.text ?? "nil"))")
            let blockCount = try await page(fixture.db, postID: fixture.postID).count
            #expect(blockCount == 2, "no block was cut, joined or added")
        }
    }

    // MARK: - ⌘⇧T (row 15)

    /// RED ON OLD: ⌘⇧T reached Write, whose arm swaps the sheet to the CARET
    /// block's panel. Now it closes the panel — the toggle's close half
    /// (PROVISIONAL P-U3-4).
    @Test func showTakesClosesThePanel() async throws {
        try await withPanel(seed: 1553) { fixture, window, hosting in
            press(.takes(.toggleFan), fixture)
            #expect(fixture.closes.value == 1, "⌘⇧T asked the host to close the panel")
            #expect(fixture.writeSaw.value.isEmpty,
                    "Write's caret door never saw ⌘⇧T — no swap to the caret block (saw \(fixture.writeSaw.value))")
        }
    }

    // MARK: - The rider: the archive receipt names the panel's own list

    /// RED ON OLD: the receipt named the Takes board's "archived · n"
    /// disclosure, which the panel does not have — its list is headed
    /// "archived takes".
    @Test func theArchiveReceiptNamesThePanelsOwnList() async throws {
        try await withPanel(seed: 1554) { fixture, window, hosting in
            try await clickInto(fixture.takeIDs[1], window, hosting)
            press(.takes(.archive), fixture)
            await settle(window, hosting, until: { fixture.model.status != nil }, maxTurns: 30)
            let receipt = fixture.model.status?.text ?? ""
            #expect(fixture.model.status?.isRefusal == false, "a receipt (\(receipt))")
            #expect(receipt.contains("archived takes"),
                    "it names the list the panel shows (\(receipt))")
            #expect(!receipt.contains("archived \u{B7} n"),
                    "…not the board's disclosure the panel does not have")
        }
    }

    // MARK: - What still belongs to Write (GUARDS — green on both sides by design)

    /// The NOTE-scoped commands reach Write: the note is the same note either
    /// way (VX-150's ruling for ⌘⇧L, kept and widened to the note family).
    @Test func theNoteCommandsStillReachWrite() async throws {
        try await withPanel(seed: 1555) { fixture, window, hosting in
            let note: [RoutedCommand] = [
                .toggleSeal, .saveNoteVersion, .showNoteVersions, .showNoteTray,
                .takes(.saveLens), .takes(.closeAll), .find(.show),
            ]
            for command in note { press(command, fixture) }
            #expect(fixture.writeSaw.value == note,
                    "the note's commands are Write's (saw \(fixture.writeSaw.value))")
        }
    }

    /// The lifecycle: when the panel closes, every command it answered is
    /// Write's again, and the grey lifts.
    @Test func whenThePanelClosesEveryCommandIsWritesAgain() async throws {
        try await withPanel(seed: 1556) { fixture, window, hosting in
            window.contentView = NSView()
            await settle(window, hosting, until: { false }, maxTurns: 4)
            #expect(fixture.session.commandRouter.isEnabled(.divide),
                    "with the panel gone, Divide is live again")
            #expect(fixture.session.commandRouter.isEnabled(.insertBlockBelow),
                    "…and New Block Below")
            let claimed: [RoutedCommand] = [
                .commit, .comments, .callout(.toggle), .copyAllTakes, .takeToBlockBelow,
                .takesToBlocks, .showBlockHistory, .showOriginBlock, .deleteBlock, .archiveBlock,
                .structural(.divide), .insertBlockBelow, .takes(.toggleFan),
            ]
            for command in claimed { press(command, fixture) }
            #expect(fixture.writeSaw.value == claimed,
                    "after the panel closes the commands are Write's again (saw \(fixture.writeSaw.value))")
        }
    }
}
