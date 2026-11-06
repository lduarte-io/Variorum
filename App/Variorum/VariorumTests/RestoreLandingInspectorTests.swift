//
//  RestoreLandingInspectorTests.swift
//  VariorumTests
//
//  VX-668 (the VX-677 run, batch 5 — `notes/plans/fixes/vx-677-editor-panes-
//  ai-door.md`, BATCH 5 RECORD) — **a Restore from the read-in-full SHEET,
//  opened from the Block History pane IN THE POST DETAIL'S INSPECTOR, lands
//  exactly as the pane row's Restore does: Write's caret at the restored
//  block's START, its first line washed.**
//
//  The walk (VX-440's vx440-reshoot row (c), both voices, burst-filmed): the
//  sheet road applied the restored words but never LANDED — the caret stayed
//  at the block's END (the delivery's rewrite's own signature) and no wash
//  came by +1.55 s — while the ROW road, in the identical state, landed at the
//  START with the wash at +0.23 s. The VX-440 record's "W-2, second pass"
//  traced it by elimination to ONE link — Write's push (`EditorView`'s
//  `onChange(of: pendingRestoreLanding)`) never fires with the parcel on the
//  sheet road — and found that its own hosted pin
//  (`RestoreLandingTests.aSheetRestoreLandsWhereTheRowRestoreDoesAfterTheSheetIsGone`)
//  LANDS in-host. That pin mounts the pane BESIDE the detail (an `HStack`)
//  and dismisses the sheet by writing the model; the app builds the pane
//  INSIDE the detail's inspector column (`PostDetailView`'s `SideColumn`
//  panel, the pane holding its OWN model), opened by Write's own history door
//  (`requestBlockHistory`), and the sheet goes by its button's own `dismiss`.
//  This suite is that structure, nothing else changed:
//
//  · the REAL detail alone in a window (and, in the third test, the whole
//    shell — `RootView` — around it), Write arrived;
//  · her caret at the END of the block, words TYPED there through the editor's
//    own road (the walk's "Write typed a third ending, to be undone by the
//    sheet");
//  · Write's own door → the detail's inspector stands the pane (its model
//    reached through the DEBUG pin door `BlockHistoryPaneOracle`);
//  · the row's Read-in-full door → the REAL sheet, presented from the
//    inspector's pane; its Restore pressed as its button presses it
//    (`CommitReadingSheet.pressRestore`, published by the same door: the act
//    handed over, then the sheet's OWN `dismiss`).
//
//  **RED here = VX-668 reproduced in-host** (the pin the fix needs, red on the
//  pre-fix tree). GREEN here = the host still does not reproduce the app's
//  miss — and it never did: the walk's DEBUG trace named the failed step
//  (S4 — the record's FIXES RECORD, F-1), served, and was removed; the fix's
//  pin is `RestoreLandingRewriteHopTests`, and these stay the green guard.
//  Each test prints one `VX668-PIN` line with what happened.
//
//  The control (`aRowRestoreFromTheInspectorLandsAtTheBlocksStart`) is the
//  walk's own control on the same staging: the pane row's Restore. Green on
//  every tree — red would mean THIS harness cannot land from the inspector at
//  all, and the sheet test's verdict would be no verdict.
//
//  VX-692 (the toolchain's closure merge, F-B3-1): no closure-bearing
//  expression sits inside `#expect`/`#require` here — every awaited or
//  closure-bearing read is bound to a local first.
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
@Suite("VX-668 — a restore from the inspector's read-in-full sheet lands (the VX-677 run)", .serialized)
struct RestoreLandingInspectorTests {
    // MARK: - Harness (`RestoreLandingTests`' real-detail pattern)

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

    /// A bounded pause that turns the run loop (no predicate to meet) — its
    /// own function, as `RestoreLandingTests` keeps it (an inline `{ false }`
    /// beside a predicate closure tripped a closure-type mismatch there).
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

    /// What she typed at the block's end before restoring (the walk's own
    /// state: "Write typed a third ending, to be undone by the sheet.").
    private static let typed = " Write typed a third ending, to be undone by the sheet."

    /// The restored block — the 30th of 40 (index 29), the walk's depth.
    private static let targetIndex = 29

    /// Random ids (never `.incrementing`): no two worlds share a block id.
    /// The mode-switch flash setting is OFF — the restore's wash is not
    /// governed by it (P-440-8), so a landing here is the restore's own.
    private func withWorld(
        count: Int = 40,
        _ body: @MainActor (World) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 668))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note she restores in")
            var blocks: [String] = []
            for i in 1...count {
                blocks.append(try session.operations.newBlock(in: post.id, text: Self.prose(i)).block.id)
            }
            try session.operations.setArrivalFlash(false)
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(postID)")
            defer {
                session.commandRouter.forgetCurrentBlock(for: postID)
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
            }
            try session.operations.setThemeVoice(.terminal)
            try await body(World(session: session, postID: postID, blocks: blocks))
        }
    }

    private func newWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1520, height: 780),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// THE APP'S COMPOSITION, the detail alone: `PostDetailView` in a window
    /// wide enough for its inspector column beside the page.
    private func mountDetail(_ w: World, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(
            rootView: PostDetailView(session: w.session, postID: w.postID).environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1520, height: 780)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    /// Write's own text view — the editor model's (in the shell there are
    /// other text surfaces in the window), else the first in the tree.
    private static func editor(_ w: World, _ hosting: NSView) -> EditorTextView? {
        writeModel(w)?.textView ?? views(EditorTextView.self, in: hosting).first
    }

    /// The Write detail's EditorViewModel (the router's active editor).
    private static func writeModel(_ w: World) -> EditorViewModel? {
        w.session.editorRouter.editingOrActive
    }

    private func chosen(_ w: World, _ blockID: String) async throws -> String {
        let postID = w.postID
        let slots = try await w.session.database.read {
            try Queries.renderPost($0, containerID: postID)
        }
        let slot = slots.first { $0.blockID == blockID }
        return try #require(slot?.variantID)
    }

    private func blockRange(_ w: World, _ i: Int) async throws -> NSRange {
        let postID = w.postID
        let slots = try await w.session.database.read {
            try Queries.renderPost($0, containerID: postID)
        }
        return BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i)
    }

    private func storeText(_ w: World, _ variantID: String) async throws -> String? {
        try await w.session.database.read { db in
            try Variant.fetchOne(db, key: variantID)?.workingText
        }
    }

    private func variantRow(_ w: World, _ variantID: String) async throws -> Variant {
        let row = try await w.session.database.read { db in
            try Variant.fetchOne(db, key: variantID)
        }
        return try #require(row)
    }

    // MARK: - The staging every road shares (the walk's state, then the door)

    private struct Staged {
        let history: BlockHistoryModel
        let commit: CommitPoint
        let take: String
        let target: String
        /// Write's landed restores before the act.
        let before: Int
    }

    /// Write arrived on `hosting`; then the walk's state and Write's OWN
    /// history door, answered by the mounted detail's INSPECTOR.
    private func stage(_ w: World, _ window: NSWindow, _ hosting: NSView) async throws -> Staged {
        let arrived = await Self.settle(window, hosting) {
            guard let e = Self.editor(w, hosting) else { return false }
            return e.string.contains(Self.prose(w.blocks.count)) && w.router.activeMode == .write
        }
        try #require(arrived, "fixture: Write mounts and fills")
        await Self.pause(window, hosting, 1.5)  // every arrival hop spent

        let target = w.blocks[Self.targetIndex]
        let take = try await chosen(w, target)
        let commit = try w.session.operations.commit(take, message: "first light")

        // Her caret at the END of the block, and words typed there through
        // the editor's own road — the coordinator dirty, as on the walk.
        let foundEditor = Self.editor(w, hosting)
        let editor = try #require(foundEditor)
        window.makeFirstResponder(editor)
        let range = try await blockRange(w, Self.targetIndex)
        editor.setSelectedRange(NSRange(location: range.upperBound, length: 0))
        await Self.pause(window, hosting, 0.3)
        editor.insertText(Self.typed, replacementRange: editor.selectedRange())
        let dirtyAfterTyping = Self.writeModel(w)?.autosave.isDirty ?? false
        let shows = await Self.settle(window, hosting) { editor.string.contains(Self.typed) }
        try #require(shows, "fixture: the page shows her typing")
        await Self.pause(window, hosting, 0.3)

        // The road that stands the pane in the mounted detail's INSPECTOR —
        // the caret's block, the focused take.
        //
        // VX-801 (VX-827 U3a) — A JUSTIFIED PIN EDIT: Write's HISTORY door
        // opens the Commits face in the full pane now (Write is replaced, so
        // there is no page beside it to land on — the face's restore is the
        // "elsewhere a receipt" arm). The PANEL survives behind the origin
        // door alone (gate G2), and THAT is the inspector road this suite
        // guards: the same request, through the origin door's own router seam
        // (`requestOriginHistory` — what `revealCaretBlockOrigin` calls; the
        // fixture holds no original, so the seam is driven directly). Every
        // claim below about the pane, the sheet and the landing is unchanged.
        let foundModel = Self.writeModel(w)
        let writeModel = try #require(foundModel)
        let caretBlock = writeModel.caretBlockID
        #expect(caretBlock == target, "fixture: her caret is in the block she will restore")
        let opened = w.router.requestOriginHistory(BlockHistoryRequest(
            postID: w.postID, blockID: target, focusedVariantID: writeModel.caretVariantID))
        try #require(opened, "fixture: the detail took the panel's request")
        // The pane is the INSPECTOR's: the router took the request (Write's own
        // fallback sheets — `blockHistoryRequest`, `originHistoryRequest` —
        // never armed) and no sheet
        // hangs on the window. Session-scoped facts only, so a parallel
        // suite's detail on the process-wide `PostDetailOracle` cannot answer.
        let paneUp = await Self.settle(window, hosting) {
            BlockHistoryPaneOracle.model(forPost: w.postID)?.blockID == target
                && writeModel.blockHistoryRequest == nil
                && writeModel.originHistoryRequest == nil
                && window.attachedSheet == nil
        }
        let inspectorSaid = PostDetailOracle.inspectorPanel.map { "\($0)" } ?? "nil"
        print("VX668-PIN door: paneUp=\(paneUp) fallbackArmed=\(writeModel.blockHistoryRequest != nil) "
            + "sheet=\(window.attachedSheet != nil) PostDetailOracle.inspectorPanel=\(inspectorSaid)")
        try #require(paneUp, "fixture: the pane stands in the detail's INSPECTOR, on her block")
        let foundHistory = BlockHistoryPaneOracle.model(forPost: w.postID)
        let history = try #require(foundHistory)
        let listed = await Self.settle(window, hosting) {
            history.loaded && history.history.savepoints[take]?.contains { $0.id == commit.id } == true
        }
        try #require(listed, "fixture: the pane lists the moment")
        await Self.pause(window, hosting, 0.4)
        let before = writeModel.restoreLandings
        print("VX668-PIN staged post=\(w.postID.prefix(8)) block=\(target.prefix(8)) "
            + "take=\(take.prefix(8)) dirtyAfterTyping=\(dirtyAfterTyping) "
            + "caretBefore=\(editor.selectedRange().location) blockEnd=\(range.upperBound) "
            + "landingsBefore=\(before)")
        return Staged(history: history, commit: commit, take: take, target: target, before: before)
    }

    /// The verdict every road shares: the restore stands, Write landed it at
    /// the block's START. Prints one `VX668-PIN` line first, whatever happens.
    private func expectLanded(
        _ w: World, _ s: Staged, _ window: NSWindow, _ hosting: NSView, road: String, host: String
    ) async throws {
        let landed = await Self.settle(window, hosting, timeout: 5) {
            (Self.writeModel(w)?.restoreLandings ?? 0) > s.before
        }
        let restored = try await blockRange(w, Self.targetIndex)
        let caret = Self.editor(w, hosting)?.selectedRange().location ?? -1
        let parcelLeft = w.router.pendingRestoreLanding?.id.uuidString.prefix(8) ?? "nil"
        let lastLanding = Self.writeModel(w)?.lastRestoreLanding?.offset ?? -1
        let sheetGone = window.attachedSheet == nil
        let receipt = s.history.status?.text ?? "nil"
        print("VX668-PIN host=\(host) road=\(road) landed=\(landed) caret=\(caret) "
            + "blockStart=\(restored.location) blockEnd=\(restored.upperBound) "
            + "lastLanding=\(lastLanding) parcelLeft=\(parcelLeft) sheetGone=\(sheetGone) "
            + "trace=\(s.history.readingTrace) receipt=\(receipt)")
        let stored = try await storeText(w, s.take)
        #expect(stored == Self.prose(Self.targetIndex + 1), "fixture: the restore stands in the store")
        let refused = s.history.status?.isRefusal ?? true
        #expect(!refused, "fixture: the restore landed — its receipt, not a refusal")
        #expect(landed, "Write landed the restore (\(road) road, \(host)) — the parcel was heard")
        #expect(caret == restored.location,
                "the caret at the restored block's START, as the row road lands it — not its END (\(restored.upperBound))")
    }

    /// The sheet road, from the pane `s.history` the inspector holds: the
    /// row's Read-in-full door, the REAL sheet, its Restore as the button does it.
    private func restoreFromTheSheet(
        _ w: World, _ s: Staged, _ window: NSWindow, _ hosting: NSView
    ) async throws {
        let row = try await variantRow(w, s.take)
        s.history.readInFull(s.commit, of: row, heading: "this take")
        let commitID = s.commit.id
        let presented = await Self.settle(window, hosting) {
            window.attachedSheet != nil && BlockHistoryPaneOracle.sheetRestore(forCommit: commitID) != nil
        }
        try #require(presented, "fixture: the read-in-full sheet is up, presented from the inspector's pane")
        await Self.pause(window, hosting, 0.5)  // she reads
        let foundPress = BlockHistoryPaneOracle.sheetRestore(forCommit: commitID)
        let press = try #require(foundPress)
        press()  // `onRestore(false)`, then the sheet's own `dismiss()`
    }

    // MARK: - The pins

    /// **VX-668 — the sheet road, the pane in the detail's inspector.**
    @Test func aSheetRestoreFromTheInspectorLandsAtTheBlocksStart() async throws {
        try await withWorld { w in
            let theme = ThemeStore(session: w.session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountDetail(w, theme: theme, in: window)
            let s = try await stage(w, window, hosting)
            try await restoreFromTheSheet(w, s, window, hosting)
            try await expectLanded(w, s, window, hosting, road: "sheet", host: "detail")
            #expect(s.history.readingTrace == [.dismissed, .acted],
                    "the act ran after the sheet was gone (VX-440's W-2 order): \(s.history.readingTrace)")
        }
    }

    /// **The CONTROL — the pane row's Restore, the same staging.** The walk's
    /// own control (it landed at +0.23 s); green on every tree.
    @Test func aRowRestoreFromTheInspectorLandsAtTheBlocksStart() async throws {
        try await withWorld { w in
            let theme = ThemeStore(session: w.session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountDetail(w, theme: theme, in: window)
            let s = try await stage(w, window, hosting)
            // The row's Restore (`CommitRowView`'s `onRestore`).
            await s.history.restore(s.commit, of: s.take)
            try await expectLanded(w, s, window, hosting, road: "row", host: "detail")
        }
    }

    /// **VX-668 — the sheet road through the WHOLE shell** (`RootView` — the
    /// pane mount rule, the detail's landing-generation identity, the shell's
    /// own chrome around the same detail). The same staging and press.
    @Test func aSheetRestoreFromTheInspectorInTheShellLandsAtTheBlocksStart() async throws {
        try await withWorld { w in
            let router = ShellRouter()
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = NSHostingView(
                rootView: RootView(session: w.session, services: nil, router: router))
            hosting.frame = NSRect(x: 0, y: 0, width: 1520, height: 780)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // Wait for the shell before routing (`onChange` never fires for an
            // initial value — batch 3's shell-mount discipline).
            let shellUp = await Self.settle(window, hosting) {
                router.workspace.history().current == .shelf
            }
            try #require(shellUp, "fixture: the shell mounted on the Bookcase")
            router.pendingSelection = .post(w.postID)
            let opened = await Self.settle(window, hosting) {
                w.router.activePostID == w.postID
            }
            try #require(opened, "fixture: the shell opened the note in its detail")
            let s = try await stage(w, window, hosting)
            try await restoreFromTheSheet(w, s, window, hosting)
            try await expectLanded(w, s, window, hosting, road: "sheet", host: "shell")
        }
    }
}
