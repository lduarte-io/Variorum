//
//  PostRescueFaceTests.swift
//  VariorumTests
//
//  R-683-4 — THE PANE'S FACE RIGHT AFTER A RESCUE (her ruling: "VX-664's
//  remaining half folds into this run: the pane's face right after a rescue is
//  walked and polished while the machinery is open"; the VX-849 run, batch 3,
//  piece 4 — the record `notes/plans/fixes/vx-849-typed-over-rescue.md`).
//
//  Two roads land a sync pull on the take her live Takes pane holds:
//  - B (batch 1's guarded autosave): the pull lands inside her debounce; her
//    autosave rescues — HER words keep the row, the pull's words become the
//    `'conflict'` take. The face: the SAME live pane, her words under her caret,
//    the card in the fan behind the corner badge (⑂2), the open-fan memory
//    untouched, the block's comment and the pane's place held.
//  - A (batch 1's flush-first occasion, then the standing S5 apply): her typing
//    landed before the round, the pull met a DIRTY row — the server's words on
//    the row, hers the card. The face: the ring ENDS (VX-664) and the pane, read,
//    shows the server's words; her words wait on the card.
//
//  Those face pins are COMPOSITION pins: green on both sides of THIS batch by
//  design (batch 1 built the rescue; the board's standing machinery holds the
//  face) — their liveness is proven by batch 1's revert R-B1 (no card) and
//  VX-677's rev664 (no ring-end), named in the record. The one face DEFECT the
//  sweep found is G2: in SLOT SPLIT a bloomed block that gains its second take
//  has its article cell REPLACED by fan cards, so the rescue's card took the
//  live pane out from under her ring (R112's class). PROVISIONAL P-849-5 (a):
//  such an adoption ends the ring by the flushed blur — that pin is RED ON OLD
//  by behavior (pre-fix API only).
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
@Suite("R-683-4 — the pane's face right after a rescue", .serialized)
struct PostRescueFaceTests {
    // MARK: - The mounted rig (`OutsideWriteLivePaneTests`' shape)

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated { RunLoop.main.run(until: Date().addingTimeInterval(seconds)) }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 6,
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

    private static func pane(_ role: String, _ variantID: String, in hosting: NSView) -> PaneTextView? {
        views(PaneTextView.self, in: hosting).first {
            $0.identifier?.rawValue == "pane:\(role)|\(variantID)"
        }
    }

    private static let typed = " She types on, mid-thought."
    private static let remoteWords = "The phone's version of this paragraph, pulled in."
    private static let serverWords = "The other Mac's rewrite of this paragraph."
    private static let comment = "Her note on this paragraph."

    private static func prose(_ i: Int) -> String {
        "Paragraph \(i): honest prose on the measured line, long enough to wrap once at "
            + "the column's measure so the page has real height to scroll through."
    }

    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
    }

    private func withWorld(
        count: Int = 4, _ body: @MainActor (World, ThemeStore) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let typography = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = typography
            EditorTypography.isAdopted = adopted
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 6834))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note a pull lands in")
            var blocks: [String] = []
            for i in 1...count {
                blocks.append(try session.operations.newBlock(in: post.id, text: Self.prose(i)).block.id)
            }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            defer { session.commandRouter.forgetCurrentBlock(for: postID) }
            try session.operations.setThemeVoice(.terminal)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            try await body(World(session: session, postID: postID, blocks: blocks), theme)
        }
    }

    private func newWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    private func mountBoard<V: View>(_ board: V, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(rootView: board.environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    private func chosen(_ w: World, _ blockID: String) async throws -> String {
        try #require(try await w.session.database.read {
            try Queries.renderPost($0, containerID: w.postID)
        }.first { $0.blockID == blockID }?.variantID)
    }

    private func boardModel(_ w: World) async throws -> TakesViewModel {
        let suite = "PostRescueFaceTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let model = TakesViewModel(session: w.session, postID: w.postID, defaults: defaults)
        model.host = .takes
        let postID = w.postID
        model.adopt(try await w.session.database.read { try Queries.takesProjection($0, post: postID) })
        return model
    }

    private func storeText(_ w: World, _ variantID: String) async throws -> String? {
        try await w.session.database.read { try Variant.fetchOne($0, key: variantID)?.workingText }
    }

    /// The block's live takes other than `take`, as (text, label).
    private func cards(_ w: World, block: String, besides take: String) async throws
        -> [(text: String, label: String?)]
    {
        try await w.session.database.read { db in
            try Row.fetchAll(
                db,
                sql: """
                SELECT working_text, label FROM variant
                WHERE block_id = ? AND id != ? AND deleted_at IS NULL ORDER BY fan_position
                """,
                arguments: [block, take]
            ).map { ($0["working_text"], $0["label"]) }
        }
    }

    /// A pull's own row write on the LOCALLY-CLEAN path (apply mode — the outbox
    /// triggers suppressed). No `Sync/` source is called.
    private func applyAsSyncPull(_ w: World, _ variantID: String, _ text: String) async throws {
        try await w.session.database.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [text, variantID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    /// The mounted board with her ring LIVE in `target`'s article pane and her
    /// keystrokes typed through the pane's own typing road (pending in the
    /// debounce). Answers the pane and its place in the window.
    private func ringAndType(
        _ w: World, _ model: TakesViewModel, target: String, take: String,
        window: NSWindow, hosting: NSView
    ) async throws -> (pane: PaneTextView, place: CGPoint) {
        let shown: () -> Bool = { Self.pane("article", take, in: hosting)?.string == Self.prose(2) }
        let showsTheTake = await Self.settle(window, hosting, until: shown)
        #expect(showsTheTake, "fixture: the article shows the take")
        model.focus(TakesViewModel.PaneKey(
            columnID: TakesViewModel.takesMainColumnID, blockID: target, variantID: take))
        let editable: () -> Bool = { Self.pane("article", take, in: hosting)?.isEditable == true }
        let isLive = await Self.settle(window, hosting, until: editable)
        #expect(isLive, "fixture: the pane is LIVE")
        let pane = try #require(Self.pane("article", take, in: hosting))
        window.makeFirstResponder(pane)
        pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
        pane.insertText(Self.typed, replacementRange: pane.selectedRange())
        #expect(model.autosave.isDirty, "fixture: her typing sits in the debounce")
        return (pane, pane.convert(pane.bounds.origin, to: nil))
    }

    // MARK: - B — the rescue under her live pane

    /// **B, the fan CLOSED (the default posture — stack, follow-the-scroll off):**
    /// the same live pane keeps her words under her caret; the pull's words are
    /// the `'conflict'` card behind the corner badge (⑂2); the closed fan stays
    /// closed; the block's comment and the pane's place hold.
    @Test func aRescueUnderHerLivePaneKeepsHerWordsAndShowsTheCardBehindTheBadge() async throws {
        try await withWorld { w, theme in
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            _ = try w.session.operations.addBlockComment(to: target, text: Self.comment)
            let model = try await boardModel(w)
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                TakesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let (pane, place) = try await ringAndType(
                w, model, target: target, take: take, window: window, hosting: hosting)
            let hers = Self.prose(2) + Self.typed
            #expect(pane.string == hers, "fixture: typed through the pane's own road")

            try await applyAsSyncPull(w, take, Self.remoteWords)
            await model.autosave.flushNow()   // her debounce fires — the rescue

            let fanned: () -> Bool = {
                model.projection.slots.first { $0.blockID == target }?.activeVariantCount == 2
            }
            let cardArrived = await Self.settle(window, hosting, until: fanned)
            #expect(cardArrived, "the rescued card reached the board")
            let after = Self.pane("article", take, in: hosting)
            #expect(after.map(ObjectIdentifier.init) == ObjectIdentifier(pane),
                    "the SAME live pane — never re-made under her")
            #expect(after?.isEditable == true, "her ring stays: nothing landed on the row from outside")
            #expect(after?.string == hers, "her words, under her caret (R-683-1)")
            #expect(model.focusedPane?.variantID == take)
            #expect(try await storeText(w, take) == hers, "her words keep the row")
            let rescued = try await cards(w, block: target, besides: take)
            #expect(rescued.map(\.text) == [Self.remoteWords], "the pull's words are the card")
            #expect(rescued.first?.label == "conflict", "R-683-2")
            let slot = model.projection.slots.first { $0.blockID == target }
            #expect(slot?.hasFan == true && slot?.activeVariantCount == 2, "the corner badge reads ⑂2")
            #expect(model.expandedBlocks.isEmpty, "a closed fan stays closed — the card waits behind its badge")
            #expect(model.commentFeed.entries(for: target) == [Self.comment], "the block's comment holds")
            if let after {
                let now = after.convert(after.bounds.origin, to: nil)
                #expect(abs(now.x - place.x) < 0.5 && abs(now.y - place.y) < 0.5,
                        "the pane did not move (was \(place), now \(now))")
            }
        }
    }

    /// **B, the fan OPEN (her first-take door, stack):** the rescued card joins
    /// the bloom; the article pane — the same object — stays live with her words;
    /// the block stays open.
    @Test func aRescueOnAnOpenStackFanAddsTheCardAndLeavesHerRing() async throws {
        try await withWorld { w, theme in
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            let model = try await boardModel(w)
            model.toggleExpanded(target)   // the first-take door, open on a one-take block
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                TakesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let (pane, _) = try await ringAndType(
                w, model, target: target, take: take, window: window, hosting: hosting)
            let hers = Self.prose(2) + Self.typed

            try await applyAsSyncPull(w, take, Self.remoteWords)
            await model.autosave.flushNow()

            let fanned: () -> Bool = {
                model.projection.slots.first { $0.blockID == target }?.activeVariantCount == 2
            }
            let cardArrived = await Self.settle(window, hosting, until: fanned)
            #expect(cardArrived, "the rescued card reached the board")
            let slot = try #require(model.projection.slots.first { $0.blockID == target })
            let bloom = model.bloomTakes(slot)
            let joined = bloom.contains { $0.label == "conflict" && $0.workingText == Self.remoteWords }
            #expect(joined, "the card joins the open bloom")
            #expect(model.expandedBlocks == [target], "the block stays open")
            let after = Self.pane("article", take, in: hosting)
            #expect(after.map(ObjectIdentifier.init) == ObjectIdentifier(pane), "the same live pane")
            #expect(after?.isEditable == true && after?.string == hers, "her ring and her words stay")
        }
    }

    // MARK: - A — the flush-first round, then the standing S5 apply

    /// **A:** her typing landed before the round; the pull met a DIRTY row —
    /// the server's words on the row, hers the `'conflict'` card (the engine's
    /// S5 merge, staged through its two writes). The ring ENDS (VX-664) and the
    /// pane, read, shows the server's words; her words wait on the card behind
    /// ⑂2; the fan stays closed; the comment holds.
    @Test func aFlushFirstRoundEndsHerRingOnTheServersWordsAndKeepsHersOnTheCard() async throws {
        try await withWorld { w, theme in
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            _ = try w.session.operations.addBlockComment(to: target, text: Self.comment)
            let model = try await boardModel(w)
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                TakesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            _ = try await ringAndType(w, model, target: target, take: take, window: window, hosting: hosting)
            let hers = Self.prose(2) + Self.typed
            await w.session.flushPendingTypingBeforeRound()   // A's occasion: her typing lands
            #expect(try await storeText(w, take) == hers, "fixture: her typing landed before the round")

            try await applyAsSyncPull(w, take, Self.serverWords)               // server wins the row…
            _ = try w.session.operations.resolveSyncConflict(take, losingText: hers)   // …hers the card

            let ended: () -> Bool = {
                guard let cell = Self.pane("article", take, in: hosting) else { return false }
                return cell.string == Self.serverWords && !cell.isEditable
            }
            let endedOnTheServersWords = await Self.settle(window, hosting, timeout: 4, until: ended)
            #expect(endedOnTheServersWords, "the ring ends and the pane, read, shows the server's words")
            #expect(model.focusedPane == nil)
            let rescued = try await cards(w, block: target, besides: take)
            #expect(rescued.map(\.text) == [hers], "her words wait on the card")
            #expect(rescued.first?.label == "conflict")
            let slot = model.projection.slots.first { $0.blockID == target }
            #expect(slot?.activeVariantCount == 2, "the corner badge reads ⑂2")
            #expect(model.expandedBlocks.isEmpty, "the closed fan stays closed")
            #expect(model.commentFeed.entries(for: target) == [Self.comment], "the block's comment holds")
        }
    }

    // MARK: - G2 — slot split (model-level; PROVISIONAL P-849-5 (a))

    private func withModelWorld(
        _ body: @MainActor (AppSession, AppDatabase, String, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 6835))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the slot-split note")
            var blocks: [String] = []
            for i in 1...3 {
                blocks.append(try session.operations.newBlock(
                    in: post.id, text: Self.prose(i), registeringUndo: false).block.id)
            }
            try await body(session, db, post.id, blocks)
        }
    }

    private func modelOnly(_ session: AppSession, _ postID: String) throws -> TakesViewModel {
        let suite = "PostRescueFaceTests-model-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return TakesViewModel(session: session, postID: postID, defaults: defaults)
    }

    private static func applyAsSyncPull(_ db: AppDatabase, _ variantID: String, _ text: String) throws {
        try db.write { db in
            try db.execute(sql: "INSERT INTO _sync_applying (applying) VALUES (1)")
            try db.execute(
                sql: "UPDATE variant SET working_text = ?, sync_version = sync_version + 1 WHERE id = ?",
                arguments: [text, variantID])
            try db.execute(sql: "DELETE FROM _sync_applying")
        }
    }

    private static func eventually(
        timeout: TimeInterval = 2, _ predicate: @MainActor () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !predicate(), Date() < deadline {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        return predicate()
    }

    /// **RED ON OLD — G2: SLOT SPLIT, her first-take door open on the block her
    /// ring is in; the rescue's card makes it a fan, and the slot-split bloom
    /// REPLACES the article cell holding her live pane.** On the old tree the ring
    /// stood on a `takes-main` key no surface renders any more (R112's class — her
    /// keyboard dead until she clicked a card). P-849-5 (a): the adoption that
    /// replaces the cell ends the ring by the flushed blur (VX-222's outside-
    /// change shape; VX-577's style rule). Her words are on the row either way.
    @Test func aRescuedCardThatSlotSplitsHerBlockEndsTheRingByTheFlushedBlur() async throws {
        try await withModelWorld { session, db, postID, blocks in
            try session.operations.setFanStyle(.slotSplit)
            let rendered = try await db.read { try Queries.renderPost($0, containerID: postID) }
            let take = try #require(rendered.first { $0.blockID == blocks[1] }?.variantID)
            let model = try modelOnly(session, postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(model.projection.fanStyle == .slotSplit, "fixture: slot split")
            model.toggleExpanded(blocks[1])   // the first-take door, open on a one-take block
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            #expect(model.focusedPane?.columnID == TakesViewModel.takesMainColumnID, "fixture: the article is live")

            let hers = Self.prose(2) + Self.typed
            model.paneEdited(variantID: take, newText: hers)
            try Self.applyAsSyncPull(db, take, Self.remoteWords)
            #expect(await model.flushPendingText(), "the rescue landed")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })

            let slot = try #require(model.projection.slots.first { $0.blockID == blocks[1] })
            #expect(model.slotSplitReplacesArticleCell(slot), "fixture: the bloom now replaces the article cell")
            let offTheGhost = await Self.eventually {
                model.focusedPane?.columnID != TakesViewModel.takesMainColumnID
            }
            #expect(offTheGhost, "RED ON OLD: the ring stands on an article cell no surface renders")
            #expect(model.focusedPane == nil, "ended by the flushed blur — P-849-5 (a)")
            let row = try await db.read { try Variant.fetchOne($0, key: take)?.workingText }
            #expect(row == hers, "her words keep the row")
        }
    }

    /// GUARD — the same arrival in STACK (the article cell survives a bloom
    /// there): her ring stays.
    @Test func theSameArrivalOnAnOpenStackFanLeavesTheRing() async throws {
        try await withModelWorld { session, db, postID, blocks in
            let rendered = try await db.read { try Queries.renderPost($0, containerID: postID) }
            let take = try #require(rendered.first { $0.blockID == blocks[1] }?.variantID)
            let model = try modelOnly(session, postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(model.projection.fanStyle == .stack, "fixture: stack (the default)")
            model.toggleExpanded(blocks[1])
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: blocks[1], variantID: take))
            model.paneEdited(variantID: take, newText: Self.prose(2) + Self.typed)
            try Self.applyAsSyncPull(db, take, Self.remoteWords)
            #expect(await model.flushPendingText())
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            let ringLeft = await Self.eventually(timeout: 0.4) { model.focusedPane?.variantID != take }
            #expect(!ringLeft, "her ring stays where the article cell survives")
            #expect(model.focusedPane?.columnID == TakesViewModel.takesMainColumnID)
        }
    }
}
