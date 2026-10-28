//
//  RestoreLandingTests.swift
//  VariorumTests
//
//  VX-431 (the VX-440 run, batch 2) — **a restore says where it landed.** Her
//  words on the ticket: restoring a long commit, *"it's unclear which part came
//  back (briefly highlight at least where it starts)"*. The plan's Batch 2
//  design, item 4: after a confirmed Restore the writing surface lands at the
//  restored take's block and briefly washes it — the existing landing roads
//  plus the arrival flash's face, an OVERLAY and never a rendering attribute.
//
//  The road: a LANDED restore posts `RestoreLanding` on the router; the
//  surface beside the pane — the detail's Write editor, or the Takes board —
//  hears it on CHANGE, waits until it SHOWS the restored words, and lands
//  (Write: the caret at the block's start, rested in the comfort band, the
//  first line washed through the decor layer; Takes: the article's own landing
//  kind `.restore`, flashed on arrival). A surface that does not show the
//  restored take lands nothing and lets the parcel go. NOT governed by the
//  mode-switch flash setting (PROVISIONAL P-440-8) — the Write pin runs with
//  that setting OFF for exactly that reason.
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
@Suite("A restore says where it landed (VX-431)", .serialized)
struct RestoreLandingTests {
    // MARK: - Harness (`ModeSwitchFeelTests`' real-detail pattern)

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

    /// A bounded pause that turns the run loop (no predicate to meet). Its
    /// own function: an inline `{ false }` beside a predicate closure in one
    /// test body tripped a compiler closure-type mismatch at this build.
    private static func pause(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        _ = await settle(window, hosting, timeout: seconds) { false }
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
        @MainActor var router: CommandRouter { session.commandRouter }
    }

    private static func prose(_ i: Int) -> String {
        "Paragraph \(i): honest prose on the measured line, long enough to wrap once at "
            + "the column's measure so the page has real height to scroll through."
    }

    /// Random ids (never `.incrementing`): no two worlds share a block id, so
    /// the DEBUG flash oracle's keys cannot collide across tests.
    private func withWorld(
        count: Int = 40, flashOn: Bool = true,
        _ body: @MainActor (World, ThemeStore) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 431))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note she restores in")
            var blocks: [String] = []
            for i in 1...count {
                blocks.append(try session.operations.newBlock(in: post.id, text: Self.prose(i)).block.id)
            }
            if !flashOn { try session.operations.setArrivalFlash(false) }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(postID)")
            defer {
                session.commandRouter.forgetCurrentBlock(for: postID)
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
            }
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

    private func open(_ w: World, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(
            rootView: PostDetailView(session: w.session, postID: w.postID).environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    private static func editor(_ hosting: NSView) -> EditorTextView? {
        views(EditorTextView.self, in: hosting).first
    }

    /// The Write detail's EditorViewModel (the router's active editor).
    private static func writeModel(_ w: World) -> EditorViewModel? {
        w.session.editorRouter.editingOrActive
    }

    /// Write mounted, filled, and every arrival hop spent.
    private func writeArrived(_ w: World, _ window: NSWindow, _ hosting: NSView) async {
        #expect(await Self.settle(window, hosting) {
            guard let e = Self.editor(hosting) else { return false }
            return e.string.contains(Self.prose(w.blocks.count)) && w.router.activeMode == .write
        }, "Write mounts and fills")
        _ = await Self.settle(window, hosting, timeout: 1.5) { false }
    }

    private static func topOfPage(_ hosting: NSView) {
        guard let editor = editor(hosting), let scroll = editor.enclosingScrollView else { return }
        editor.setSelectedRange(NSRange(location: 0, length: 0))
        scroll.contentView.scroll(to: .zero)
        scroll.reflectScrolledClipView(scroll.contentView)
    }

    /// The caret's line, in the Write viewport's own coordinates.
    private static func caretLineInViewport(_ hosting: NSView) -> (top: Double, bottom: Double, viewport: Double)? {
        guard let editor = editor(hosting), let scroll = editor.enclosingScrollView,
              let span = JumpPrimitive.lineSpan(ofOffset: editor.selectedRange().location, in: editor)
        else { return nil }
        let visible = scroll.contentView.bounds
        return (span.top - Double(visible.minY), span.bottom - Double(visible.minY),
                Double(visible.height))
    }

    private func chosen(_ w: World, _ blockID: String) async throws -> String {
        try #require(try await w.session.database.read {
            try Queries.renderPost($0, containerID: w.postID)
        }.first { $0.blockID == blockID }?.variantID)
    }

    // MARK: - The parcel

    /// **A LANDED restore posts its landing; a refused one posts nothing.**
    /// The parcel names the note, the block, the take and the words it holds
    /// now — what a surface needs to know it SHOWS the restore.
    @Test func aLandedRestorePostsItsLandingAndARefusedOneNothing() async throws {
        try await withWorld(count: 3) { w, _ in
            let ops = w.session.operations
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            let commit = try ops.commit(take)
            try ops.autosave(take, text: "Other words now.", charDelta: 9)

            let history = BlockHistoryModel(session: w.session, postID: w.postID, blockID: target)
            await history.restore(commit, of: take)
            let landing = try #require(w.router.pendingRestoreLanding, "the restore landed — it says so")
            #expect(landing.postID == w.postID && landing.blockID == target
                && landing.variantID == take && landing.text == Self.prose(2))

            w.router.pendingRestoreLanding = nil
            try ops.lockPost(w.postID)
            await history.restore(commit, of: take)
            #expect(history.status?.isRefusal == true)
            #expect(w.router.pendingRestoreLanding == nil, "a refused restore landed nowhere")
        }
    }

    /// **The parcel is let go with its detail** — the staleness discipline of
    /// the landings beside it: another note's arrival, or the detail leaving.
    @Test func aStaleRestoreLandingIsLetGoWithItsDetail() async throws {
        try await withWorld(count: 1) { w, _ in
            let router = w.router
            let first = router.registerDetail(postID: w.postID, mode: .write) { _ in }
            router.pendingRestoreLanding = RestoreLanding(
                postID: w.postID, blockID: "b", variantID: "v", text: "t")
            let other = router.registerDetail(postID: "another-note", mode: .write) { _ in }
            #expect(router.pendingRestoreLanding == nil, "another note arrived: not its landing")
            router.unregisterDetail(first)
            router.pendingRestoreLanding = RestoreLanding(
                postID: "another-note", blockID: "b", variantID: "v", text: "t")
            router.unregisterDetail(other)
            #expect(router.pendingRestoreLanding == nil, "the detail left: nothing to land on")
        }
    }

    // MARK: - Write

    /// **Write lands at the restored block's start and washes its first line**
    /// — the caret moved there, the line on screen, the arrival flash's face
    /// drawn through the decor layer — **with the mode-switch flash setting
    /// OFF** (P-440-8: that setting's words name mode switches only).
    @Test func writeLandsAtTheRestoredBlockAndWashesItsFirstLine() async throws {
        try await withWorld(count: 40, flashOn: false) { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            let ops = w.session.operations
            let target = w.blocks[29]
            let take = try await chosen(w, target)
            let commit = try ops.commit(take)
            try ops.autosave(take, text: "Rewritten: the thirtieth paragraph, short now.", charDelta: 60)
            let rewritten = await Self.settle(window, hosting) {
                Self.editor(hosting)?.string.contains("Rewritten: the thirtieth") == true
            }
            #expect(rewritten, "fixture: the page shows the rewrite")
            Self.topOfPage(hosting)
            await Self.pause(window, hosting, 0.6)
            let before = Self.writeModel(w)?.restoreLandings ?? 0
            #if DEBUG
            ArrivalFlashOracle.reset()
            #endif

            let history = BlockHistoryModel(
                session: w.session, postID: w.postID, blockID: target, focusedVariantID: take)
            await history.restore(commit, of: take)
            #expect(history.status?.isRefusal == false)
            let landed = await Self.settle(window, hosting, timeout: 4) {
                (Self.writeModel(w)?.restoreLandings ?? 0) > before
            }
            #expect(landed, "Write landed the restore")

            let slots = try await w.session.database.read {
                try Queries.renderPost($0, containerID: w.postID)
            }
            let start = BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: 29).location
            #expect(Self.editor(hosting)?.selectedRange().location == start,
                    "the caret at the restored block's start")
            #expect(Self.writeModel(w)?.lastRestoreLanding?.offset == start)
            #expect(Self.editor(hosting)?.string.contains(Self.prose(30)) == true,
                    "the page shows the restored words")
            let line = try #require(Self.caretLineInViewport(hosting))
            #expect(line.top >= 0 && line.bottom <= line.viewport,
                    "the restored block's first line is on screen: \(line)")
            #expect(w.router.pendingRestoreLanding == nil, "the parcel was taken")
            #if DEBUG
            let washed = ArrivalFlashOracle.seen.filter { $0.key.hasPrefix("write|") }
            #expect(washed.contains { $0.value.peakFill >= 1 && $0.value.peakStroke >= 1 },
                    "the line was washed with the flash's face, setting OFF: \(washed)")
            #endif
        }
    }

    /// **A restore of a take the page does not show lands nothing** — there is
    /// none of the restored words on this page to wash — and the caret, hers,
    /// stays where it was.
    @Test func writeLandsNothingForATakeItDoesNotShow() async throws {
        try await withWorld(count: 12) { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            let ops = w.session.operations
            let target = w.blocks[8]
            let shown = try await chosen(w, target)
            let other = try ops.branchVariant(target, from: shown)
            try ops.autosave(other.id, text: "An unchosen take's own words.", charDelta: 10)
            let commit = try ops.commit(other.id)
            try ops.autosave(other.id, text: "The unchosen take, rewritten.", charDelta: 10)
            Self.topOfPage(hosting)
            await Self.pause(window, hosting, 0.6)
            let before = Self.writeModel(w)?.restoreLandings ?? 0

            let history = BlockHistoryModel(session: w.session, postID: w.postID, blockID: target)
            await history.restore(commit, of: other.id)
            #expect(history.status?.isRefusal == false, "fixture: the restore itself landed")
            await Self.pause(window, hosting, 1.5)
            #expect(Self.writeModel(w)?.restoreLandings == before, "nothing of it is on this page")
            #expect(w.router.pendingRestoreLanding == nil, "…and the parcel is let go")
            #expect(Self.editor(hosting)?.selectedRange().location == 0, "her caret, unmoved")
        }
    }

    // MARK: - Takes (the board's model)

    private func takesBoard(_ w: World) async throws -> TakesViewModel {
        let suite = "RestoreLandingTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let model = TakesViewModel(session: w.session, postID: w.postID, defaults: defaults)
        model.host = .takes
        model.landingEnabled = true
        try await adoptFresh(model, w)
        return model
    }

    private func adoptFresh(_ model: TakesViewModel, _ w: World) async throws {
        let postID = w.postID
        model.adopt(try await w.session.database.read { try Queries.takesProjection($0, post: postID) })
    }

    /// **The article lands only once it SHOWS the restored words** — a landing
    /// made against the old projection would be ended by the delivery that
    /// brings them (`noteProjectionArrived`). Then it is the article's own
    /// landing, kind `.restore` (flashed on arrival — `TakesEntryBandTests`'
    /// mounted pin holds the face).
    @Test func takesLandsOnlyOnceTheArticleShowsTheRestoredWords() async throws {
        try await withWorld(count: 6) { w, _ in
            let ops = w.session.operations
            let target = w.blocks[3]
            let take = try await chosen(w, target)
            let commit = try ops.commit(take)
            try ops.autosave(take, text: "Changed since the moment.", charDelta: 12)
            let model = try await takesBoard(w)
            #expect(model.board.articleLanding == nil, "fixture: nothing landing")

            try ops.restoreCommit(take, commitID: commit.id)   // the store has the words; the board does not yet
            w.router.pendingRestoreLanding = RestoreLanding(
                postID: w.postID, blockID: target, variantID: take, text: Self.prose(4))
            model.consumeRestoreLanding()
            #expect(w.router.pendingRestoreLanding == nil, "the board took the parcel")
            #expect(model.board.articleLanding == nil,
                    "parked: the article still shows the old words")

            try await adoptFresh(model, w)
            let placement = try #require(model.projection.slots.first { $0.blockID == target }?.placementID)
            #expect(model.board.articleLanding == placement, "landed on the restored block's row")
            #expect(model.board.articleLandingKind == .restore)
        }
    }

    /// The article shows CHOSEN takes only: a restore of another take of the
    /// block lands nothing there.
    @Test func takesLandsNothingForATakeTheArticleDoesNotShow() async throws {
        try await withWorld(count: 6) { w, _ in
            let ops = w.session.operations
            let target = w.blocks[2]
            let shown = try await chosen(w, target)
            let other = try ops.branchVariant(target, from: shown)
            try ops.autosave(other.id, text: "Unchosen words.", charDelta: 6)
            let commit = try ops.commit(other.id)
            try ops.autosave(other.id, text: "Unchosen, rewritten.", charDelta: 6)
            let model = try await takesBoard(w)
            try ops.restoreCommit(other.id, commitID: commit.id)
            w.router.pendingRestoreLanding = RestoreLanding(
                postID: w.postID, blockID: target, variantID: other.id, text: "Unchosen words.")
            model.consumeRestoreLanding()
            try await adoptFresh(model, w)
            #expect(model.board.articleLanding == nil, "the article does not show that take")
        }
    }

    // MARK: - W-1 (the vx440 walk) — the live pane beside the pane road

    private static func pane(_ role: String, _ variantID: String, in hosting: NSView) -> PaneTextView? {
        views(PaneTextView.self, in: hosting).first {
            $0.identifier?.rawValue == "pane:\(role)|\(variantID)"
        }
    }

    private func mountBoard<V: View>(_ board: V, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(rootView: board.environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    private func storeText(_ w: World, _ variantID: String) async throws -> String? {
        try await w.session.database.read { db in
            try Variant.fetchOne(db, key: variantID)?.workingText
        }
    }

    /// **W-1 (RED ON THE PRE-FIX TREE) — a restore from the pane's ROW while
    /// TAKES is mounted leaves the article showing the RESTORED words.** The
    /// walk's finding, traced: the Takes bar's history door opens Block
    /// History on the block her ring is in, so the restored take's article
    /// pane is the LIVE pane — and a live pane is buffer-authoritative: it
    /// never adopts projection text (`PaneSurface.updateNSView`'s `isLive`
    /// arm; `PaneTextAuthority`'s contract), the one exception being VX-248's
    /// RE-BIND, which keys on the bound take's id, and a restore keeps the id.
    /// So the cell kept the pre-restore words under the wash — and her next
    /// keystroke would have handed those words up and written them back over
    /// the restore. On the pre-fix tree the pane still reads the pre-restore
    /// words here.
    @Test func aRestoreBesideTakesLeavesTheArticleShowingTheRestoredWords() async throws {
        try await withWorld(count: 6) { w, theme in
            let ops = w.session.operations
            let target = w.blocks[2]
            let take = try await chosen(w, target)
            let commit = try ops.commit(take)
            let typed = "Changed since the moment, and typed into."
            try ops.autosave(take, text: typed, charDelta: 20)
            let model = try await takesBoard(w)
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                TakesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let mounted = await Self.settle(window, hosting) {
                Self.pane("article", take, in: hosting)?.string == typed
            }
            #expect(mounted, "fixture: the article shows the take as it is now")
            // Her ring in that block's article pane — the block the bar's
            // history door opens Block History on.
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: target, variantID: take))
            let live = await Self.settle(window, hosting) {
                Self.pane("article", take, in: hosting)?.isEditable == true
            }
            #expect(live, "fixture: the pane is LIVE")

            let history = BlockHistoryModel(
                session: w.session, postID: w.postID, blockID: target, focusedVariantID: take)
            await history.restore(commit, of: take)
            #expect(history.status?.isRefusal == false)
            let shows = await Self.settle(window, hosting, timeout: 4) {
                Self.pane("article", take, in: hosting)?.string == Self.prose(3)
            }
            #expect(shows, "the article shows the restored words, not: \(Self.pane("article", take, in: hosting)?.string ?? "nil")")
            #expect(Self.pane("article", take, in: hosting)?.isEditable == false,
                    "the ring that was over the pre-restore words ended")
            await Self.pause(window, hosting, 0.6)
            #expect(try await storeText(w, take) == Self.prose(3), "the restore stands")
        }
    }

    /// **W-1's twin on the LENSES board (RED ON THE PRE-FIX TREE)** — the same
    /// pane road beside Lenses (its own history door): the Chosen column's
    /// live cell on the restored take shows the restored words.
    @Test func aRestoreBesideLensesLeavesTheLiveCellShowingTheRestoredWords() async throws {
        try await withWorld(count: 6) { w, theme in
            let ops = w.session.operations
            let target = w.blocks[1]
            let take = try await chosen(w, target)
            let commit = try ops.commit(take)
            let typed = "A lens cell's own later words."
            try ops.autosave(take, text: typed, charDelta: 12)
            let suite = "RestoreLandingTests-lenses-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = TakesViewModel(session: w.session, postID: w.postID, defaults: defaults)
            model.host = .lenses
            try await adoptFresh(model, w)
            let chosenColumn = try #require(model.columns.first { $0.kind == .main })
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountBoard(
                LensesBoardView(session: w.session, postID: w.postID, model: model),
                theme: theme, in: window)
            let mounted = await Self.settle(window, hosting) {
                Self.pane("cell", take, in: hosting)?.string == typed
            }
            #expect(mounted, "fixture: the Chosen column shows the take as it is now")
            model.focus(TakesViewModel.PaneKey(
                columnID: chosenColumn.id, blockID: target, variantID: take))
            let live = await Self.settle(window, hosting) {
                Self.pane("cell", take, in: hosting)?.isEditable == true
            }
            #expect(live, "fixture: the cell is LIVE")

            let history = BlockHistoryModel(session: w.session, postID: w.postID, blockID: target)
            await history.restore(commit, of: take)
            let shows = await Self.settle(window, hosting, timeout: 4) {
                Self.pane("cell", take, in: hosting)?.string == Self.prose(2)
            }
            #expect(shows, "the live cell shows the restored words, not: \(Self.pane("cell", take, in: hosting)?.string ?? "nil")")
        }
    }
}
