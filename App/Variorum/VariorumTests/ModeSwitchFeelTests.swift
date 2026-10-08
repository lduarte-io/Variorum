//
//  ModeSwitchFeelTests.swift
//  VariorumTests
//
//  **18l-c UNIT U8 — the mode switch's feel on Write and note Read, through
//  REAL mode switches** (the real detail — `PostDetailView` in a real window —
//  and the app's own switch road, `CommandRouter.requestMode`; the
//  `NoteOpenLandingTests` / `ModeSwitchCarryTests` rig). What these hold:
//
//  - **(b) the COMFORT BAND on Write** — a caret the page she left does not
//    show lands with its line at the text container's top air (24 pt), never
//    flush with the top (#98(a)'s "line at the top", resolved then banded); a
//    caret line resting in the bottom room moves the minimum up into the band;
//    a caret line mid-band never moves;
//  - **(b) on note Read** — a block Write held flush with the top (a carried
//    fraction of 0) lands in Read's edit face at the face's resting top air
//    (its column lead), and one Write held flush with the bottom lands two
//    lines above the foot; a mid-band carry stays exact
//    (`ModeSwitchCarryTests` PIN A — rides unmodified);
//  - **(a) the ARRIVAL FLASH** — a mode switch into Write flashes the caret's
//    line; one into Read flashes the landed row; a note's RE-OPEN flashes
//    nothing (R-18l-1's opening is not a mode switch).
//
//  RED on the pre-U8 tree for the band arms (the shipped reveal lands the
//  line flush at the top; the visible bottom-room line stays; the carry lands
//  flush), by construction for the flash (no flash existed).
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
@Suite("18l-c U8 — the mode switch's comfort band and flash on Write and note Read", .serialized)
struct ModeSwitchFeelTests {

    // MARK: - Harness (`NoteOpenLandingTests`' real-detail pattern)

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

    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
        let index: BlockRangeIndex
        @MainActor var router: CommandRouter { session.commandRouter }
    }

    private static func prose(_ i: Int) -> String {
        "Paragraph \(i): honest prose on the measured line, long enough to wrap once at "
            + "the column's measure so the page has real height to scroll through."
    }

    /// Random ids (never `.incrementing`): no two worlds share a block id, so
    /// the DEBUG flash oracle's keys cannot collide across tests.
    private func withWorld(
        count: Int = 80, flashOn: Bool = true, _ body: @MainActor (World, ThemeStore) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 81))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note she switches through")
            var blocks: [String] = []
            for i in 1...count {
                blocks.append(try session.operations.newBlock(in: post.id, text: Self.prose(i)).block.id)
            }
            if !flashOn { try session.operations.setArrivalFlash(false) }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(postID)")
            UserDefaults.standard.set(ReadModeView.Face.edit.rawValue, forKey: ReadModeView.faceKey(postID))
            defer {
                session.commandRouter.forgetCurrentBlock(for: postID)
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(postID))
            }
            // 13s-b U1a (A JUSTIFIED EDIT): this rig was measured in the world
            // a voiceless store used to read — Terminal. A store with no voice
            // reads Study since her 2026-10-05 ruling, so the world is named.
            try session.operations.setThemeVoice(.terminal)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let slots = try await db.read { db in try Queries.renderPost(db, containerID: postID) }
            try await body(
                World(session: session, postID: postID, blocks: blocks,
                      index: BlockRangeIndex(slots: slots, tail: nil)),
                theme)
        }
    }

    private func open(_ w: World, theme: ThemeStore, in window: NSWindow) -> NSView {
        let hosting = NSHostingView(
            rootView: PostDetailView(session: w.session, postID: w.postID).environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    private func leave(_ window: NSWindow) async {
        window.contentView = nil
        _ = await Self.settle(window, NSView(), timeout: 0.6) { false }
    }

    private func newWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        return window
    }

    /// Write mounted, filled, and every arrival hop spent. (Returns nothing:
    /// the pins never hold the text view across an `await` — the
    /// `SendNonSendable` compiler crash `ModeSwitchCarryTests` records; every
    /// read and act below is one synchronous call that fetches it fresh.)
    private func writeArrived(_ w: World, _ window: NSWindow, _ hosting: NSView) async {
        #expect(await Self.settle(window, hosting) {
            guard let e = Self.views(EditorTextView.self, in: hosting).first else { return false }
            return e.string.count >= w.index.documentLength && w.router.activeMode == .write
        }, "Write mounts and fills")
        _ = await Self.settle(window, hosting, timeout: 1.5) { false }  // the settle hop's parks
    }

    private static func editor(_ hosting: NSView) -> EditorTextView? {
        views(EditorTextView.self, in: hosting).first
    }

    /// Where the caret's LINE sits below the Write viewport's top edge, the
    /// viewport's height, the text container's top air, and the caret.
    private static func caretLine(
        _ hosting: NSView
    ) -> (top: Double, bottom: Double, viewport: Double, air: Double, caret: Int)? {
        guard let editor = editor(hosting), let scroll = editor.enclosingScrollView,
              let span = JumpPrimitive.lineSpan(ofOffset: editor.selectedRange().location, in: editor)
        else { return nil }
        let visible = scroll.contentView.bounds
        return (span.top - Double(visible.minY), span.bottom - Double(visible.minY),
                Double(visible.height), Double(editor.textContainerOrigin.y),
                editor.selectedRange().location)
    }

    private static func putCaret(_ hosting: NSView, at location: Int) -> Bool {
        guard let editor = editor(hosting) else { return false }
        editor.setSelectedRange(NSRange(location: location, length: 0))
        return true
    }

    /// Scroll Write's page so the line holding `offset` sits `inset` points
    /// below the viewport's top (JumpPrimitive's own contract).
    private static func place(_ hosting: NSView, offset: Int, inset: Double) -> Bool {
        guard let editor = editor(hosting) else { return false }
        JumpPrimitive.jump(toOffset: offset, textView: editor,
                           scrollView: editor.enclosingScrollView, landingInset: inset)
        return true
    }

    private static func scrollToTop(_ hosting: NSView) -> Bool {
        guard let scroll = editor(hosting)?.enclosingScrollView else { return false }
        scroll.contentView.scroll(to: .zero)
        scroll.reflectScrolledClipView(scroll.contentView)
        return true
    }

    /// The caret line's span in text-view coordinates (for the flash pin).
    private static func caretSpan(_ hosting: NSView) -> (top: Double, bottom: Double)? {
        guard let editor = editor(hosting) else { return nil }
        return JumpPrimitive.lineSpan(ofOffset: editor.selectedRange().location, in: editor)
    }

    /// The Write detail's EditorViewModel (the router's active editor).
    private static func writeModel(_ w: World) -> EditorViewModel? {
        w.session.editorRouter.editingOrActive
    }

    /// Write → Takes → Write, nothing clicked in Takes (a plain round trip).
    private func roundTripThroughTakes(_ w: World, _ window: NSWindow, _ hosting: NSView) async {
        #expect(w.router.requestMode(.takes, postID: w.postID))
        #expect(await Self.settle(window, hosting) { w.router.activeMode == .takes })
        _ = await Self.settle(window, hosting, timeout: 1.5) { false }
        #expect(w.router.requestMode(.write, postID: w.postID))
        await writeArrived(w, window, hosting)
    }

    // MARK: - (b) Write: the top clamp

    /// **A caret the page she left does not show lands at the TOP AIR.** Her
    /// caret in block 41; her page scrolled back to the note's top (the caret
    /// off it); ⌘2, ⌘1. Write restores its page (the RAISE-M1 anchor) and
    /// #98(a) reveals the caret's line — and the band rests it the text
    /// container's own 24-pt top air below the edge. RED on the pre-U8 tree:
    /// the line flush with the top (0).
    @Test func aCaretOffThePageLandsAtTheTopAirNeverFlush() async throws {
        try await withWorld { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            let caret = w.index.range(ofEntryAt: 40).location + 5
            #expect(Self.putCaret(hosting, at: caret))
            #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[40] })
            #expect(Self.scrollToTop(hosting))
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            await roundTripThroughTakes(w, window, hosting)
            let line = try #require(Self.caretLine(hosting))
            print("[18l-c U8 write top] caret line \(line.top)…\(line.bottom) · viewport \(line.viewport) · air \(line.air)")
            #expect(line.caret == caret, "non-vacuity: the caret came back to block 41")
            #expect(abs(line.top - line.air) <= 1,
                    "the caret's line rests at the top air \(line.air) — measured \(line.top) (red on the pre-U8 tree: 0, flush)")
            await leave(window)
        }
    }

    // MARK: - (b) Write: the bottom clamp

    /// **A caret line resting in the bottom room moves the minimum up.** Her
    /// page left with the caret's line one point above the viewport's foot;
    /// the round trip restores that page exactly — and the band lifts the line
    /// to two lines above the foot. RED on the pre-U8 tree: the line stays at
    /// the foot (it was "on screen", so #98(a) never revealed it).
    @Test func aCaretLineInTheBottomRoomRisesTheMinimumIntoTheBand() async throws {
        try await withWorld { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            let caret = w.index.range(ofEntryAt: 30).location + 5
            #expect(Self.putCaret(hosting, at: caret))
            #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[30] })
            let first = try #require(Self.caretLine(hosting))
            #expect(Self.place(hosting, offset: caret, inset: first.viewport - (first.bottom - first.top) - 1))
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            let left = try #require(Self.caretLine(hosting))
            #expect(left.viewport - left.bottom < 3,
                    "non-vacuity: she left the line at the foot (\(left.bottom) of \(left.viewport))")
            await roundTripThroughTakes(w, window, hosting)
            let line = try #require(Self.caretLine(hosting))
            let room = 2 * Double(TypewriterRoom.lineHeight(of: EditorDocument.baseFont))
            print("[18l-c U8 write bottom] caret line \(line.top)…\(line.bottom) · viewport \(line.viewport) · room \(line.viewport - line.bottom)")
            #expect(abs((line.viewport - line.bottom) - room) <= 1.5,
                    "two lines (\(room)) of room under the caret's line — measured \(line.viewport - line.bottom) (red on the pre-U8 tree: ~1)")
            await leave(window)
        }
    }

    // MARK: - (b) Write: mid-band exact

    /// **A caret line mid-band never moves** — the page comes back exactly
    /// (the RAISE-M1 anchor) and the band asks for nothing. Green on both
    /// sides by design.
    @Test func aCaretLineMidBandComesBackExactly() async throws {
        try await withWorld { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            let caret = w.index.range(ofEntryAt: 30).location + 5
            #expect(Self.putCaret(hosting, at: caret))
            #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[30] })
            #expect(Self.place(hosting, offset: caret, inset: 250.5))
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            let left = try #require(Self.caretLine(hosting))
            await roundTripThroughTakes(w, window, hosting)
            let line = try #require(Self.caretLine(hosting))
            print("[18l-c U8 write mid] left \(left.top) · back \(line.top)")
            #expect(abs(line.top - left.top) <= 1, "mid-band: exactly where she left it (\(left.top) → \(line.top))")
            await leave(window)
        }
    }

    // MARK: - (a) Write: the flash, and never on a re-open

    #if DEBUG
    /// **A mode switch into Write flashes the caret's line; a re-open does
    /// not.** RED on the pre-U8 tree by construction (no flash existed).
    @Test func aModeSwitchIntoWriteFlashesTheCaretsLineAndAReopenDoesNot() async throws {
        try await withWorld { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            #expect(Self.writeModel(w)?.arrivalFlashes == 0, "the note's first open does not flash")
            #expect(Self.putCaret(hosting, at: w.index.range(ofEntryAt: 20).location + 3))
            #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[20] })
            await roundTripThroughTakes(w, window, hosting)
            let span = try #require(Self.caretSpan(hosting))
            let flashes = Self.writeModel(w)?.arrivalFlashes
            let flashed = Self.writeModel(w)?.lastArrivalFlashLine
            #expect(flashes == 1, "the mode switch flashed once (\(String(describing: flashes)))")
            #expect(flashed.map { abs($0.top - span.top) < 0.5 && abs($0.bottom - span.bottom) < 0.5 } == true,
                    "…the caret's own line (\(String(describing: flashed)) vs \(span))")
            // A RE-open (leave, open again) is the note's opening — no flash.
            await leave(window)
            let again = open(w, theme: theme, in: window)
            await writeArrived(w, window, again)
            #expect(Self.writeModel(w)?.arrivalFlashes == 0, "a re-open never flashes (R-18l-1's opening)")
            await leave(window)
        }
    }

    /// **Her setting OFF: no flash** — and the landing is unchanged.
    @Test func withTheSettingOffAModeSwitchIntoWriteDoesNotFlash() async throws {
        try await withWorld(flashOn: false) { w, theme in
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            #expect(await Self.settle(window, NSView()) { theme.settings.arrivalFlash == false })
            let hosting = open(w, theme: theme, in: window)
            await writeArrived(w, window, hosting)
            #expect(Self.putCaret(hosting, at: w.index.range(ofEntryAt: 20).location))
            #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[20] })
            await roundTripThroughTakes(w, window, hosting)
            #expect(Self.writeModel(w)?.arrivalFlashes == 0, "the setting OFF: no flash")
            await leave(window)
        }
    }
    #endif

    // MARK: - (b)+(a) note Read: the carry banded, the row flashed

    #if DEBUG
    /// Where a block sits in Read's `edit` face — its top below the face's
    /// top, its bottom's distance above the face's foot (the DEBUG oracle's
    /// frames, the `ModeSwitchCarryTests` read).
    private static func readRow(postID: String, block: String) -> (top: Double, room: Double)? {
        guard let row = ReadModeOracle.editBlockFrames[block],
              let face = ReadModeOracle.faceFrames[postID] else { return nil }
        return (Double(row.minY - face.minY), Double(face.maxY - row.maxY))
    }

    /// Put block `range` at a fraction of Write's viewport (0 flush top, 1
    /// flush bottom) — one synchronous call.
    private static func placeBlock(_ hosting: NSView, range: NSRange, atEdge edge: Double) -> Bool {
        guard let editor = editor(hosting), let scroll = editor.enclosingScrollView,
              let first = JumpPrimitive.lineSpan(ofOffset: range.location, in: editor),
              let last = JumpPrimitive.lineSpan(
                ofOffset: range.location + max(0, range.length - 1), in: editor)
        else { return false }
        let height = last.bottom - first.top
        let viewport = Double(scroll.contentView.bounds.height)
        JumpPrimitive.jump(toOffset: range.location, textView: editor, scrollView: scroll,
                           landingInset: edge * (viewport - height))
        return true
    }

    /// Write → Read with the block Write held at an extreme edge (`edge` 0 =
    /// flush with the top, 1 = flush with the bottom): returns where Read's
    /// edit face rested it, and the flash its row drew. A plain async method
    /// (a closure parameter here trips the `SendNonSendable` compiler crash).
    private func carryIntoRead(
        _ w: World, _ theme: ThemeStore, fromEdge edge: Double
    ) async -> (top: Double, room: Double, flash: ArrivalFlashOracle.Seen?)? {
        ReadModeOracle.reset()
        ArrivalFlashOracle.reset()
        let window = newWindow()
        defer { window.orderOut(nil); window.close() }
        let hosting = open(w, theme: theme, in: window)
        await writeArrived(w, window, hosting)
        let target = 40
        let range = w.index.range(ofEntryAt: target)
        #expect(Self.putCaret(hosting, at: range.location + 5))
        #expect(await Self.settle(window, hosting) { w.router.focusedBlock?.blockID == w.blocks[target] })
        #expect(Self.placeBlock(hosting, range: range, atEdge: edge))
        _ = await Self.settle(window, hosting, timeout: 0.6) { false }
        #expect(w.router.requestMode(.read, postID: w.postID))
        #expect(await Self.settle(window, hosting) { ReadModeOracle.selectedBlockID == w.blocks[target] })
        _ = await Self.settle(window, hosting, timeout: 2) { false }  // the landing settles, the flash arrives
        let row = Self.readRow(postID: w.postID, block: w.blocks[target])
        let flash = ArrivalFlashOracle.seen["read-edit|\(w.blocks[target])"]
        await leave(window)
        return row.map { ($0.top, $0.room, flash) }
    }

    /// **The top clamp on Read**: a block Write held flush with the top lands
    /// in Read's edit face at the face's resting top air (its column lead),
    /// never flush. RED on the pre-U8 tree: ~0 (the carry's fraction 0).
    @Test func aBlockFlushWithWritesTopLandsInReadAtItsTopAir() async throws {
        try await withWorld { w, theme in
            let row = try #require(await carryIntoRead(w, theme, fromEdge: 0))
            print("[18l-c U8 read top] row top \(row.top)")
            #expect(abs(row.top - Double(ReadEditPane.columnLead)) <= 2,
                    "the carried block rests at the face's top air \(ReadEditPane.columnLead) — measured \(row.top) (red on the pre-U8 tree: ~0)")
        }
    }

    /// **The bottom clamp on Read**: a block Write held flush with the bottom
    /// lands two lines above the face's foot. RED on the pre-U8 tree: ~0.
    @Test func aBlockFlushWithWritesFootLandsInReadTwoLinesAboveItsFoot() async throws {
        try await withWorld { w, theme in
            let row = try #require(await carryIntoRead(w, theme, fromEdge: 1))
            let room = 2 * Double(TypewriterRoom.lineHeight(of: EditorDocument.baseFont))
            print("[18l-c U8 read bottom] row room \(row.room) · want \(room)")
            #expect(abs(row.room - room) <= 2,
                    "two lines (\(room)) under the carried block — measured \(row.room) (red on the pre-U8 tree: ~0)")
        }
    }

    /// **The flash on Read**: the mode switch's landing flashes the landed
    /// row once it has arrived (fill and border at full strength).
    @Test func aModeSwitchIntoReadFlashesTheLandedRow() async throws {
        try await withWorld { w, theme in
            let row = try #require(await carryIntoRead(w, theme, fromEdge: 0.5))
            #expect((row.flash?.peakFill ?? 0) > 0.9 && (row.flash?.peakStroke ?? 0) > 0.9,
                    "the landed row drew the flash: \(String(describing: row.flash))")
        }
    }
    #endif
}
