//
//  NoteOpenLandingTests.swift
//  VariorumTests
//
//  18l UNIT U0c — her kickoff report (2026-09-26, verbatim): *"When opening the
//  note, sometimes you're randomly autonavigated to the middle of the note,
//  sometimes the end, but opening a note should just show you the START of a
//  note. With the behavior where it goes to the bottom, it's auto navigating to
//  the bottom of the note and only leaving a single line of text on the screen
//  … and it's ignoring where I previously was in the note to do so."*
//
//  Her ruling R-18l-1 (the 18l kickoff sitting): *"First open of a note each
//  session shows the start; re-opening a note you already visited this session
//  restores where you were."* In-app deep links keep their targets.
//
//  ── THE TRACED MECHANISM (the U0c RECORD carries the reproductions) ─────────
//  A note opens when its detail registers (`CommandRouter.registerDetail`), and
//  a note DIFFERENT from the active one had its LIVE fact seeded from the
//  PERSISTED current-block memory — the caret she left, sessions ago. Every
//  mode's arrival lands on that fact: Write's bare arrival parks a reveal that
//  puts the caret's line at the viewport TOP (the typewriter room below — the
//  one line on screen); Takes' N9 arm reveals the block's row; Read selects and
//  scrolls to it. And within a session a re-open restored the page she left
//  (the RAISE-M1 anchor) and then let that same reveal jump to a caret she had
//  scrolled away from — the END again, "ignoring where I previously was".
//
//  Every mounted pin is the REAL detail (`PostDetailView`) in a real window;
//  an EARLIER RUN is a persisted `currentBlock.<id>` written before this
//  session's router ever reads it — exactly what a relaunch finds.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Opening a note: the start on the run's first open, where she was on a re-open (18l U0c — R-18l-1)", .serialized)
struct NoteOpenLandingTests {

    // MARK: - Harness (`CurrentBlockContinuityTests`' real-detail pattern)

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

    /// One note of `count` prose blocks (+ an EMPTY last block when asked — the
    /// ⏎-at-the-end shape her trailing-newline notes have).
    private struct World {
        let session: AppSession
        let postID: String
        let blocks: [String]
        let variants: [String]
        let index: BlockRangeIndex
        @MainActor var router: CommandRouter { session.commandRouter }
    }

    private static func prose(_ i: Int) -> String {
        "Paragraph \(i): honest prose on the measured line, long enough to wrap once at "
            + "the column's measure so the page has real height to scroll through."
    }

    private func withWorld(
        count: Int = 60, emptyLastBlock: Bool = false, rng: UInt64,
        _ body: @MainActor (World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let typography = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = typography
            EditorTypography.isAdopted = adopted
        }
        // 13s closeout — the Study-default harness class (`TerminalMetricsPin`
        // in EditorTestSupport has the trace): this save/restore predates the
        // Study no-voice default and assumed the process state WAS Terminal.
        // Begin process-fresh so the landing geometry measures the voice the
        // pins were calibrated against; the defer above restores as found.
        EditorTypography.current = EditorTypography.resolve(
            voice: .terminal, inlineComments: false)
        EditorTypography.isAdopted = false
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: rng))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // The store carries the Terminal voice row so any in-test
            // adoption keeps the calibrated voice.
            try session.operations.setThemeVoice(.terminal)
            let post = try session.operations.createPost(title: "the note she opens")
            var blocks: [String] = []
            var variants: [String] = []
            for i in 1...count {
                let m = try session.operations.newBlock(in: post.id, text: Self.prose(i))
                blocks.append(m.block.id)
                variants.append(m.variant.id)
            }
            if emptyLastBlock {
                let m = try session.operations.newBlock(in: post.id, text: "")
                blocks.append(m.block.id)
                variants.append(m.variant.id)
            }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            defer {
                session.commandRouter.forgetCurrentBlock(for: postID)
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(postID))
            }
            let slots = try await db.read { db in try Queries.renderPost(db, containerID: postID) }
            try await body(World(
                session: session, postID: postID, blocks: blocks, variants: variants,
                index: BlockRangeIndex(slots: slots, tail: nil)))
        }
    }

    /// What an EARLIER RUN left: the persisted `currentBlock.<id>` her last
    /// session wrote (its format, `blockID|variantID|utf16Offset`), in place
    /// before this session's router reads anything.
    private func rememberFromAnEarlierRun(_ w: World, entry: Int, offset: Int) {
        UserDefaults.standard.set(
            "\(w.blocks[entry])|\(w.variants[entry])|\(offset)",
            forKey: CurrentBlockMemory.key(w.postID))
    }

    /// Mounts the REAL detail in a real window (the note opens: `onAppear` →
    /// `registerDetail`). The caller unmounts with `leave`.
    private func open(
        _ w: World, in window: NSWindow, initialBlockID: String? = nil
    ) -> NSView {
        let hosting = NSHostingView(
            rootView: PostDetailView(session: w.session, postID: w.postID, initialBlockID: initialBlockID)
                .environment(ThemeStore(session: w.session)))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return hosting
    }

    /// The note leaves the screen — the detail's `onDisappear` (the router's
    /// unregister, the editor's teardown) runs as it does when she navigates.
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

    /// Write mounted, filled, and every arrival hop spent.
    private func writeArrived(_ w: World, _ window: NSWindow, _ hosting: NSView) async throws -> EditorTextView {
        #expect(await Self.settle(window, hosting) {
            guard let e = Self.views(EditorTextView.self, in: hosting).first else { return false }
            return e.string.count >= w.index.documentLength && w.router.focusedBlock != nil
        }, "Write mounts, fills and reports")
        _ = await Self.settle(window, hosting, timeout: 1.5) { false }  // the settle hop's parks
        return try #require(Self.views(EditorTextView.self, in: hosting).first)
    }

    private func clipY(_ editor: EditorTextView) throws -> Double {
        Double(try #require(editor.enclosingScrollView).contentView.bounds.minY)
    }

    // MARK: - A. The router: the run's FIRST open restores nothing; a re-open restores THIS run's

    /// The arm every mode inherits: a note arriving for the first time this run
    /// carries no current-block fact, whatever an earlier run persisted — so
    /// Write lands at the start, Takes rings the first block, Read selects the
    /// first row, and whatever she does next is what the memory follows. Red
    /// on the pre-fix tree (`fe4473bf`'s run): the persisted fact came back
    /// live. The opening's record (new API) rides beside it.
    @Test func theRunsFirstOpenOfANoteRestoresNothingAnEarlierRunLeft() async throws {
        try await withWorld(count: 5, rng: 1) { w in
            rememberFromAnEarlierRun(w, entry: 4, offset: 12)
            let token = w.router.registerDetail(postID: w.postID, mode: .write) { _ in }
            #expect(w.router.focusedBlock == nil,
                    "the first open this run lands at the START (red-on-old: the earlier run's block 5 @12 — \(String(describing: w.router.focusedBlock)))")
            let first = try #require(w.router.opening)
            #expect(!first.isReopen && first.mode == .write && first.seeded == nil,
                    "the run's FIRST open, seeded with nothing: \(first)")
            #expect(w.router.openingLanding(postID: w.postID, fact: nil) != nil,
                    "an arrival on the (absent) seeded fact is the opening's own landing")
            // …and what she does THIS run is what a re-open restores.
            w.router.noteFocusedBlock(w.blocks[2], variantID: w.variants[2], postID: w.postID, utf16Offset: 7)
            #expect(w.router.openingLanding(postID: w.postID, fact: w.router.focusedBlock) == nil,
                    "a place reported since the note arrived is a place someone chose")
            w.router.noteMode(.write)
            #expect(w.router.opening != nil, "the detail reporting its own mode keeps the opening")
            w.router.noteMode(.takes)
            #expect(w.router.opening == nil, "a mode switch ends the opening")
            w.router.unregisterDetail(token)
            let other = w.router.registerDetail(postID: "another note", mode: .write) { _ in }
            w.router.unregisterDetail(other)
            let again = w.router.registerDetail(postID: w.postID, mode: .takes) { _ in }
            let thisRun = FocusedBlock(
                postID: w.postID, blockID: w.blocks[2], variantID: w.variants[2], utf16Offset: 7)
            #expect(w.router.focusedBlock == thisRun, "a re-open this run restores where she was this run")
            let reopen = try #require(w.router.opening)
            #expect(reopen.isReopen && reopen.seeded == thisRun, "…recorded as a RE-open: \(reopen)")
            w.router.unregisterDetail(again)
            #expect(w.router.opening == nil, "the detail leaving ends it")
            w.router.forgetCurrentBlock(for: "another note")
        }
    }

    /// A re-open reads THIS run's memory only: a visit that reported nothing
    /// (a mode with no caret, a glance) re-opens at the start — never at the
    /// place an earlier run persisted. Red on the pre-fix tree (`fe4473bf`'s
    /// run): the earlier run's block came back on the re-open.
    @Test func aReopenNeverRestoresAnEarlierRunsPlace() async throws {
        try await withWorld(count: 5, rng: 2) { w in
            rememberFromAnEarlierRun(w, entry: 4, offset: 12)
            let first = w.router.registerDetail(postID: w.postID, mode: .lenses) { _ in }
            w.router.unregisterDetail(first)
            let again = w.router.registerDetail(postID: w.postID, mode: .write) { _ in }
            #expect(w.router.focusedBlock == nil,
                    "nothing this run said where she was — the start (red-on-old: \(String(describing: w.router.focusedBlock)))")
            #expect(w.router.opening?.isReopen == true)
            w.router.unregisterDetail(again)
        }
    }

    // MARK: - B. The FIRST open, per mode, with a caret an earlier run left elsewhere

    /// Her three shapes: the ⏎-at-the-end empty block (`pre-a6`: the empty
    /// line at the top, nothing else on screen), the end of the last line of
    /// text (*"only leaving a single line of text"*), and the Sherlock middle.
    enum Remembered: String, CaseIterable, Sendable {
        case emptyLastBlock, endOfTheLastLine, middle
    }

    @Test(arguments: Remembered.allCases)
    func writeOpensAtTheStart(_ remembered: Remembered) async throws {
        try await withWorld(emptyLastBlock: remembered == .emptyLastBlock, rng: 3) { w in
            let last = w.blocks.count - 1
            switch remembered {
            case .emptyLastBlock: rememberFromAnEarlierRun(w, entry: last, offset: 0)
            case .endOfTheLastLine:
                rememberFromAnEarlierRun(w, entry: last, offset: w.index.range(ofEntryAt: last).length)
            case .middle: rememberFromAnEarlierRun(w, entry: 34, offset: 5)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            let editor = try await writeArrived(w, window, hosting)
            let clip = try clipY(editor)
            print("[U0c write first open \(remembered.rawValue)] clip \(clip) · caret \(editor.selectedRange().location) of \(w.index.documentLength)")
            #expect(clip <= 0.5,
                    "the page opens at its START, the top air showing (red-on-old: the remembered line at the viewport top — clip \(clip))")
            #expect(editor.selectedRange().location == 0,
                    "…with the caret at the note's start (red-on-old: \(editor.selectedRange().location))")
            #expect(w.router.focusedBlock?.blockID == w.blocks[0], "and block 1 is the current block")
            await leave(window)
        }
    }

    @Test func takesOpensAtTheStart() async throws {
        try await withWorld(emptyLastBlock: true, rng: 4) { w in
            rememberFromAnEarlierRun(w, entry: w.blocks.count - 1, offset: 0)
            UserDefaults.standard.set(PostMode.takes.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            #expect(await Self.settle(window, hosting) { Self.liveArticlePane(in: hosting) != nil },
                    "the board rings a pane")
            _ = await Self.settle(window, hosting, timeout: 2) { false }  // the landing's steps
            let live = try #require(Self.liveArticlePane(in: hosting))
            let article = try #require(Self.articleScrollView(of: live, in: hosting))
            let clip = Double(article.contentView.bounds.minY)
            let liveID = live.identifier?.rawValue ?? "-"
            print("[U0c takes first open] article clip \(clip) · live \(liveID)")
            #expect(clip <= 0.5, "the article opens at the top (red-on-old: revealed at the end — \(clip))")
            #expect(liveID.hasSuffix("|\(w.variants[0])"),
                    "block 1's pane takes the ring — the first slot (red-on-old: the empty last block's)")
            await leave(window)
        }
    }

    /// THE WALK'S FINDING, pinned (`18l-screens/u0c/walk/letter/t-11`): a first open
    /// that keeps an earlier run's caret as the live fact shows the start —
    /// and the very next mode switch enters on that caret and reveals it, the
    /// blank END again. The first open restores no fact, so ⌘1 right after it
    /// stays at the start. Red on the pre-fix tree (the Takes first open was
    /// already at the END) and on the letter-reading build (`5d7c8bb6`: the
    /// Takes first open at the top, then ⌘1 → the END).
    @Test func aModeSwitchRightAfterAFirstOpenStaysAtTheStart() async throws {
        try await withWorld(emptyLastBlock: true, rng: 12) { w in
            rememberFromAnEarlierRun(w, entry: w.blocks.count - 1, offset: 0)
            UserDefaults.standard.set(PostMode.takes.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            #expect(await Self.settle(window, hosting) { Self.liveArticlePane(in: hosting) != nil })
            _ = await Self.settle(window, hosting, timeout: 1.5) { false }
            #expect(w.router.requestMode(.write, postID: w.postID))
            let editor = try await writeArrived(w, window, hosting)
            let clip = try clipY(editor)
            print("[U0c mode switch after first open] Write clip \(clip) · caret \(editor.selectedRange().location) of \(w.index.documentLength)")
            #expect(clip <= 0.5, "⌘1 right after the first open stays at the start (red: the blank END — \(clip))")
            await leave(window)
        }
    }

    /// The article's LIVE pane, if one is realized.
    private static func liveArticlePane(in root: NSView) -> PaneTextView? {
        views(PaneTextView.self, in: root)
            .first { $0.isEditable && $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
    }

    @Test func readOpensAtTheStart() async throws {
        try await withWorld(emptyLastBlock: true, rng: 5) { w in
            rememberFromAnEarlierRun(w, entry: w.blocks.count - 1, offset: 0)
            UserDefaults.standard.set(PostMode.read.rawValue, forKey: "postMode.\(w.postID)")
            UserDefaults.standard.set(ReadModeView.Face.edit.rawValue, forKey: ReadModeView.faceKey(w.postID))
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            #if DEBUG
            #expect(await Self.settle(window, hosting) { ReadModeOracle.selectedBlockID != nil },
                    "Read seeds its current block")
            _ = await Self.settle(window, hosting, timeout: 1.5) { false }
            let offsets = Self.views(NSScrollView.self, in: hosting).map { Double($0.contentView.bounds.minY) }
            print("[U0c read first open] selected \(ReadModeOracle.selectedBlockID ?? "-") · scrolls \(offsets)")
            #expect(ReadModeOracle.selectedBlockID == w.blocks[0],
                    "the first row is current (red-on-old: the earlier run's last block)")
            #expect(offsets.allSatisfy { $0 <= 0.5 },
                    "the page and its index column open at the top (red-on-old: scrolled to the end — \(offsets))")
            #endif
            await leave(window)
        }
    }

    /// The outermost scroll view between an article pane and the root (the
    /// Takes suites' own rule).
    private static func articleScrollView(of pane: NSView, in root: NSView) -> NSScrollView? {
        var outermost: NSScrollView?
        var current: NSView? = pane.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { outermost = scroll }
            current = node.superview
        }
        return outermost
    }

    // MARK: - C. The RE-open this run: the page she left

    /// B6 (the U0b record's hand-forward) and the probe's `clip 0 → 24`: the
    /// teardown anchor was an OFFSET, replayed as "that line at the viewport
    /// top", so a note left resting in its top air re-opened 24 pt down — the
    /// air eaten. Red on the pre-fix tree: 24.0.
    @Test func aReopenOfANoteLeftAtItsTopKeepsTheTopAir() async throws {
        try await withWorld(rng: 6) { w in
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let first = try await writeArrived(w, window, open(w, in: window))
            #expect(try clipY(first) <= 0.5, "the first open rests in the top air")
            await leave(window)
            let again = try await writeArrived(w, window, open(w, in: window))
            let clip = try clipY(again)
            print("[U0c reopen at top] clip \(clip)")
            #expect(clip <= 0.5, "the re-open is the page she left (red-on-old: 24.0 — the air eaten): \(clip)")
            await leave(window)
        }
    }

    /// Her in-session END (`pre-a10`): the caret at the note's END, the page
    /// read back up to its start without a click, the note left and re-opened —
    /// the page came back and then the parked caret reveal jumped to the END.
    /// The re-open is where she WAS; the caret stays where she left it (her
    /// editing state) until she types or clicks. Red on the pre-fix tree: the
    /// end line at the viewport top.
    @Test func aReopenAfterScrollingAwayFromTheCaretComesBackToThePageSheLeft() async throws {
        try await withWorld(emptyLastBlock: true, rng: 7) { w in
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            let first = try await writeArrived(w, window, hosting)
            // Her ⏎ at the end left the caret in the empty last block…
            first.setSelectedRange(NSRange(location: w.index.documentLength, length: 0))
            #expect(await Self.settle(window, hosting) {
                w.router.focusedBlock?.blockID == w.blocks.last
            }, "the caret's block is reported")
            // …and she read back up to the start (the page at its top — no click).
            let scroll = try #require(first.enclosingScrollView)
            scroll.contentView.scroll(to: .zero)
            scroll.reflectScrolledClipView(scroll.contentView)
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            await leave(window)
            let again = try await writeArrived(w, window, open(w, in: window))
            let clip = try clipY(again)
            print("[U0c reopen scrolled away] clip \(clip) · caret \(again.selectedRange().location) of \(w.index.documentLength)")
            #expect(clip <= 0.5, "the page she left — its top (red-on-old: the END's line at the viewport top, \(clip))")
            #expect(again.selectedRange().location == w.index.documentLength,
                    "…and her caret is where she left it (editing state, not moved by the re-open)")
            await leave(window)
        }
    }

    /// The re-open restores the page EXACTLY — a wheel-scrolled page whose top
    /// edge cuts a line keeps that cut (the reading line's place, not the line
    /// snapped to the top). Red on the pre-fix tree twice over: the anchor
    /// replayed the line at the top, and the caret reveal (block 1, far above)
    /// then hauled the page to the note's start.
    @Test func aReopenMidNoteComesBackToThePageExactly() async throws {
        try await withWorld(rng: 8) { w in
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            let first = try await writeArrived(w, window, hosting)
            let line = try #require(JumpPrimitive.lineSpan(
                ofOffset: w.index.range(ofEntryAt: 30).location, in: first))
            let left = line.top + 7  // the edge cuts the line above its baseline
            let scroll = try #require(first.enclosingScrollView)
            scroll.contentView.scroll(to: NSPoint(x: 0, y: left))
            scroll.reflectScrolledClipView(scroll.contentView)
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            #expect(abs(try clipY(first) - left) <= 0.5, "she rests mid-note at \(left)")
            await leave(window)
            let again = try await writeArrived(w, window, open(w, in: window))
            let clip = try clipY(again)
            print("[U0c reopen mid-note] left \(left) · back \(clip)")
            #expect(abs(clip - left) <= 1, "the page she left, exactly (red-on-old: \(clip))")
            await leave(window)
        }
    }

    /// A page left resting in the TYPEWRITER ROOM below the last line has no
    /// reading line (`topVisibleOffset` answers nil there), so a teardown there
    /// kept no anchor and the re-open fell back to the note's TOP. The place is
    /// now the last line with its negative inset, and the page comes back at
    /// the note's END. Measured: the settled page rested 137 pt below the last
    /// line's top, and at the re-open's settle hop the room's maximum scroll is
    /// the last line's top — so the restore lands the last line at the viewport
    /// top (the jump's live clamp, C6b), the end she left, never the start. Red
    /// with the room's place thrown away (R-room): the page at 0.
    @Test func aReopenOfANoteLeftRestingBelowItsLastLineComesBackThere() async throws {
        try await withWorld(rng: 11) { w in
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let hosting = open(w, in: window)
            let first = try await writeArrived(w, window, hosting)
            let scroll = try #require(first.enclosingScrollView)
            let lastLine = try #require(JumpPrimitive.lineSpan(ofOffset: w.index.documentLength, in: first))
            let left = lastLine.bottom + 120  // below the last line, in the room
            scroll.contentView.scroll(to: NSPoint(x: 0, y: left))
            scroll.reflectScrolledClipView(scroll.contentView)
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            #expect(abs(try clipY(first) - left) <= 0.5, "she rests in the room at \(left)")
            await leave(window)
            let again = try await writeArrived(w, window, open(w, in: window))
            let clip = try clipY(again)
            print("[U0c reopen in the room] left \(left) · back \(clip)")
            #expect(clip >= lastLine.top - 1,
                    "the page comes back at the note's END — the room she left, or its last line at the top (red with R-room: the start, \(clip))")
            await leave(window)
        }
    }

    /// The re-open's rule is the OPENING's only: a mode round trip after it is
    /// the standing machinery again — the RAISE-M1 anchor, then #98(a)'s reveal
    /// of a caret off the restored view. GUARD (green on both sides): the
    /// re-open's no-reveal never leaks into a mode switch.
    @Test func aModeRoundTripAfterAReopenStillRevealsTheCaret() async throws {
        try await withWorld(emptyLastBlock: true, rng: 9) { w in
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let first = try await writeArrived(w, window, open(w, in: window))
            first.setSelectedRange(NSRange(location: w.index.documentLength, length: 0))
            _ = await Self.settle(window, NSView(), timeout: 0.3) { false }
            let scroll = try #require(first.enclosingScrollView)
            scroll.contentView.scroll(to: .zero)
            scroll.reflectScrolledClipView(scroll.contentView)
            _ = await Self.settle(window, NSView(), timeout: 0.5) { false }
            await leave(window)
            let hosting = open(w, in: window)
            _ = try await writeArrived(w, window, hosting)
            #expect(w.router.requestMode(.takes, postID: w.postID))
            #expect(await Self.settle(window, hosting) { w.router.activeMode == .takes })
            _ = await Self.settle(window, hosting, timeout: 1) { false }
            #expect(w.router.requestMode(.write, postID: w.postID))
            let back = try await writeArrived(w, window, hosting)
            let caret = back.selectedRange().location
            let span = try #require(JumpPrimitive.lineSpan(ofOffset: caret, in: back))
            let visible = try #require(back.enclosingScrollView).contentView.bounds
            print("[U0c mode round trip after reopen] caret \(caret) · line \(span.top) · visible \(visible.minY)…\(visible.maxY)")
            #expect(span.top >= Double(visible.minY) - 1 && span.bottom <= Double(visible.maxY) + 1,
                    "a mode round trip still reveals the caret (#98(a), standing)")
            await leave(window)
        }
    }

    // MARK: - D. Deep links keep their targets

    /// A block-naming door (a Library/palette block hit — `initialBlockID`)
    /// on the run's FIRST open still lands its block, revealed. GUARD (green on
    /// both sides): R-18l-1 changes the plain opening only.
    @Test func aDeepLinkOnAFirstOpenStillLandsAtItsTarget() async throws {
        try await withWorld(emptyLastBlock: true, rng: 10) { w in
            rememberFromAnEarlierRun(w, entry: w.blocks.count - 1, offset: 0)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(w.postID)")
            let window = newWindow()
            defer { window.orderOut(nil); window.close() }
            let target = w.index.range(ofEntryAt: 40).location
            let hosting = open(w, in: window, initialBlockID: w.blocks[40])
            #expect(await Self.settle(window, hosting) {
                Self.views(EditorTextView.self, in: hosting).first?.selectedRange().location == target
            }, "the jump's caret lands at block 41's start")
            _ = await Self.settle(window, hosting, timeout: 1.5) { false }
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let span = try #require(JumpPrimitive.lineSpan(ofOffset: target, in: editor))
            let visible = try #require(editor.enclosingScrollView).contentView.bounds
            print("[U0c deep link first open] target line \(span.top) · visible \(visible.minY)…\(visible.maxY)")
            #expect(span.top >= Double(visible.minY) - 1 && span.bottom <= Double(visible.maxY) + 1,
                    "the deep link's block is on screen")
            await leave(window)
        }
    }
}
