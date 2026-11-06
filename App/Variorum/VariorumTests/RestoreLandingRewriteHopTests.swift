//
//  RestoreLandingRewriteHopTests.swift
//  VariorumTests
//
//  VX-668 (the VX-677 run, the fixes unit — `notes/plans/fixes/vx-677-editor-
//  panes-ai-door.md`, FIXES RECORD, F-1) — **a restore's landing that Write
//  took BEFORE the restored words reached the page lands once they do, even
//  when the rewrite that brings them leaves the text view's frame where it
//  was.**
//
//  The final walk's trace (`.vx677-walk-shots/final/trace-sheet-study.log`,
//  reading key S4): on the read-in-full sheet road the parcel was posted
//  BETWEEN the restore's two deliveries — `refetchFresh`, then the post, Write's
//  push consuming it (`land … outcome=not-yet shown=false`), then the
//  `differential` rewrite — and NOTHING asked the parked landing again: no
//  settle hop came after the rewrite. The WHY (F-1): the landing's one re-ask
//  is the N14 settle hop, armed only by the text view's OWN `viewWillDraw`;
//  TextKit 2 draws its text in its own subviews, and a storage edit that does
//  not change the text view's frame never displays the text view itself
//  (measured, macOS 27.0.1 — the record's offscreen probes). The walk's note
//  is two short blocks, its frame floored at the page, so the restore that
//  removed her typing could not move it. `RestoreLandingInspectorTests` hops
//  (and stays green) only because its note is 40 paragraphs long — the
//  rewrite there changes the frame.
//
//  THE PIN stages that state deterministically on the walk's own note shape:
//  the parcel posted and TAKEN by Write's real push while the page still
//  shows the words being restored over, then the restore's store write
//  through the pane's own road, so the delivery's rewrite is the only thing
//  that can re-ask the landing. (The walk's post fell between the two
//  deliveries; posting before the write widens nothing — `refetchFresh`
//  touches neither the page nor the landing, so the editor holds exactly the
//  walk's state when the rewrite lands, and the order can no longer flip.)
//  Premises are `#require`d: the parcel was taken before the rewrite, and the
//  rewrite left the frame where it was — a frame change would display the text
//  view and make the pin hollow, so it fails as a fixture, never as a green.
//
//  **RED on the pre-fix tree / `vx677-c/rev668`** (no hop after the rewrite:
//  the landing never lands, the caret stays at the block's END); **GREEN on
//  the fix** (`EditorViewModel.adoptRewrite` makes the rewrite's display pass
//  certain while a landing is parked).
//
//  The GUARD is the row road's order on the same note — the rewrite shown
//  FIRST, the parcel after: Write lands at consume, no hop needed — green on
//  both trees; red would mean this harness cannot land on the short note at
//  all (then the pin's verdict is no verdict).
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
@Suite("VX-668 — a parked restore landing lands after a frame-constant rewrite (the VX-677 run)", .serialized)
struct RestoreLandingRewriteHopTests {
    // MARK: - Harness (`RestoreLandingInspectorTests`' real-detail pattern)

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

    /// A bounded pause that turns the run loop (no predicate to meet).
    private static func pause(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        _ = await settle(window, hosting, timeout: seconds) { false }
    }

    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
        @MainActor var router: CommandRouter { session.commandRouter }
    }

    /// The walk's own note: two short blocks, the restored block LAST.
    private static let words = [
        "VX668 alpha opens the note.",
        "VX668 bravo is the block she restores.",
    ]

    /// What she typed at the block's end before restoring (the walk's).
    private static let typed = " Write typed a third ending, to be undone by the sheet."

    private static let targetIndex = 1

    /// Random ids (never `.incrementing`). The mode-switch flash setting is
    /// OFF — the restore's wash is not governed by it (P-440-8), so a landing
    /// here is the restore's own. Study, the walk's voice.
    private func withWorld(_ body: @MainActor (World) async throws -> Void) async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 6681))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "2026-10-29")
            var blocks: [String] = []
            for text in Self.words {
                blocks.append(try session.operations.newBlock(in: post.id, text: text).block.id)
            }
            try session.operations.setArrivalFlash(false)
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(postID)")
            defer {
                session.commandRouter.forgetCurrentBlock(for: postID)
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
            }
            try session.operations.setThemeVoice(.study)
            try await body(World(session: session, postID: postID, blocks: blocks))
        }
    }

    private func newWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1240, height: 840),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// THE APP'S COMPOSITION, the detail alone (the walk's window size).
    private func mountDetail(_ w: World, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(
            rootView: PostDetailView(session: w.session, postID: w.postID).environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1240, height: 840)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

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

    // MARK: - The staging both tests share (the walk's state)

    private struct Staged {
        let editor: EditorTextView
        let model: EditorViewModel
        let commit: CommitPoint
        let take: String
        let target: String
        /// Write's landed restores before the act.
        let before: Int
        /// The text view's frame with her typing on the page.
        let frameBefore: NSRect
    }

    /// Write arrived; the moment saved; her typing at the block's END,
    /// flushed (the restore's own first step); the page clean and settled.
    private func stage(_ w: World, _ window: NSWindow, _ hosting: NSView) async throws -> Staged {
        let arrived = await Self.settle(window, hosting) {
            guard let e = Self.writeModel(w)?.textView else { return false }
            return e.string.contains(Self.words[Self.targetIndex]) && w.router.activeMode == .write
        }
        try #require(arrived, "fixture: Write mounts and fills")
        await Self.pause(window, hosting, 1.5)  // every arrival hop spent

        let target = w.blocks[Self.targetIndex]
        let take = try await chosen(w, target)
        let commit = try w.session.operations.commit(take, message: "vx668 moment")

        let foundModel = Self.writeModel(w)
        let model = try #require(foundModel)
        let foundEditor = model.textView
        let editor = try #require(foundEditor)
        window.makeFirstResponder(editor)
        let range = try await blockRange(w, Self.targetIndex)
        editor.setSelectedRange(NSRange(location: range.upperBound, length: 0))
        await Self.pause(window, hosting, 0.3)
        editor.insertText(Self.typed, replacementRange: editor.selectedRange())
        let shows = await Self.settle(window, hosting) { editor.string.contains(Self.typed) }
        try #require(shows, "fixture: the page shows her typing")
        await Self.pause(window, hosting, 0.3)

        // The restore's own first step (`CommitsFaceModel.restore` — the panel's, before VX-827 U3b): her
        // pending typing lands before anything writes the take.
        let flushed = await w.session.flushExistingAutosave(forPost: w.postID)
        let clean = await Self.settle(window, hosting) { !model.autosave.isDirty }
        try #require(clean, "fixture: her typing is flushed (flushed=\(flushed))")
        await Self.pause(window, hosting, 0.5)  // the echo adopted, every hop spent

        let before = model.restoreLandings
        let frameBefore = editor.frame
        print("VX668-PIN-C staged post=\(w.postID.prefix(8)) block=\(target.prefix(8)) "
            + "take=\(take.prefix(8)) caret=\(editor.selectedRange().location) "
            + "blockEnd=\(range.upperBound + (Self.typed as NSString).length) "
            + "frame=\(frameBefore) landingsBefore=\(before)")
        return Staged(
            editor: editor, model: model, commit: commit, take: take, target: target,
            before: before, frameBefore: frameBefore)
    }

    /// The restore's store write, through the pane's own road.
    private func writeTheRestore(_ w: World, _ s: Staged) async throws {
        let take = s.take
        let commitID = s.commit.id
        try await w.session.runner.run { ops in
            try ops.restoreCommit(take, commitID: commitID)
        }
    }

    /// The parcel exactly as `CommitsFaceModel.restore` posts it (the panel's road before VX-827 U3b).
    private func postTheParcel(_ w: World, _ s: Staged) {
        w.router.pendingRestoreLanding = RestoreLanding(
            postID: w.postID, blockID: s.target, variantID: s.take, text: s.commit.text)
    }

    /// The verdict both tests share: Write landed at the restored block's
    /// START. Prints one `VX668-PIN-C` line first, whatever happens.
    private func expectLanded(
        _ w: World, _ s: Staged, _ window: NSWindow, _ hosting: NSView, road: String
    ) async throws {
        let landed = await Self.settle(window, hosting, timeout: 4) {
            s.model.restoreLandings > s.before
        }
        let restored = try await blockRange(w, Self.targetIndex)
        let caret = s.editor.selectedRange().location
        let lastLanding = s.model.lastRestoreLanding?.offset ?? -1
        let parcelLeft = w.router.pendingRestoreLanding?.id.uuidString.prefix(8) ?? "nil"
        print("VX668-PIN-C road=\(road) landed=\(landed) caret=\(caret) "
            + "blockStart=\(restored.location) blockEnd=\(restored.upperBound) "
            + "lastLanding=\(lastLanding) parcelLeft=\(parcelLeft) frame=\(s.editor.frame)")
        #expect(landed, "Write landed the restore (\(road)) — the rewrite re-asked the parked landing")
        #expect(caret == restored.location,
                "the caret at the restored block's START — not its END (\(restored.upperBound))")
    }

    // MARK: - The pin

    /// **VX-668 — the walk's order on the walk's note: the parcel taken while
    /// the page still shows the words being restored over, then the rewrite
    /// that brings them, leaving the text view's frame where it was.**
    @Test func aLandingTakenBeforeAFrameConstantRewriteLandsWhenTheWordsArrive() async throws {
        try await withWorld { w in
            let theme = ThemeStore(session: w.session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountDetail(w, theme: theme, in: window)
            let s = try await stage(w, window, hosting)

            // Write's real push takes the parcel; the page still shows her
            // typing, so the landing parks `not-yet` (the walk's S4 state).
            postTheParcel(w, s)
            let taken = await Self.settle(window, hosting) { w.router.pendingRestoreLanding == nil }
            try #require(taken, "fixture: Write's push took the parcel")
            let stillOld = s.editor.string.contains(Self.typed)
            let landedEarly = s.model.restoreLandings > s.before
            try #require(stillOld && !landedEarly,
                         "fixture: the parcel was taken while the page still showed the words being restored over")

            // The restore's write; its delivery's rewrite is now the only
            // thing that can ask the parked landing again.
            try await writeTheRestore(w, s)
            let rewritten = await Self.settle(window, hosting) { !s.editor.string.contains(Self.typed) }
            try #require(rewritten, "fixture: the delivery rewrote the block with the restored words")
            let frameAfter = s.editor.frame
            print("VX668-PIN-C rewrite frameBefore=\(s.frameBefore) frameAfter=\(frameAfter)")
            try #require(frameAfter == s.frameBefore,
                         "fixture: the walk's shape — the rewrite left the text view's frame where it was")

            try await expectLanded(w, s, window, hosting, road: "taken-before-the-rewrite")
        }
    }

    // MARK: - The guard

    /// **The row road's order on the same note — the rewrite shown FIRST, the
    /// parcel after:** Write lands at consume, no hop needed. Green on both
    /// trees.
    @Test func aLandingWhoseWordsAreAlreadyShownLandsAtOnce() async throws {
        try await withWorld { w in
            let theme = ThemeStore(session: w.session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = mountDetail(w, theme: theme, in: window)
            let s = try await stage(w, window, hosting)

            try await writeTheRestore(w, s)
            let rewritten = await Self.settle(window, hosting) { !s.editor.string.contains(Self.typed) }
            try #require(rewritten, "fixture: the delivery rewrote the block with the restored words")
            await Self.pause(window, hosting, 0.5)  // nothing parked, nothing pending

            postTheParcel(w, s)
            try await expectLanded(w, s, window, hosting, road: "after-the-rewrite")
        }
    }
}
