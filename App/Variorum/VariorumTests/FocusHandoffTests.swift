//
//  FocusHandoffTests.swift
//  VariorumTests
//
//  Phase 10 Step 3 — ONE live editor, migrating: the brief's three
//  mid-state integration tests (focus switch mid-dirty-buffer,
//  mid-open-tail, mid-crystallization-flight — the states where a careless
//  handoff loses text), the exactly-one-live-editor walk, and the focus
//  seeds (caret from the read-tier click; focus-then-fan from a badge tap).
//
//  The harness performs the switch EXACTLY as the container does: tear the
//  leaving editor down (SwiftUI's onDisappear → teardown), then attach a
//  fresh editor for the newly focused post — in the INLINE shape (bare
//  content-sized text view, scrollView nil), which is the book view's.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
final class EditorWorldHarness {
    let session: AppSession
    let database: AppDatabase
    let postIDs: [String]
    private(set) var active: EditorHarness?

    init(session: AppSession, database: AppDatabase, postIDs: [String]) {
        self.session = session
        self.database = database
        self.postIDs = postIDs
    }

    /// The container's focus switch: teardown (returns the finalize task,
    /// awaited so the test observes the settled store — the app doesn't
    /// await it, but the store lands identically either way; the await is
    /// determinism, not a behavior difference), then a fresh inline editor
    /// attaches to the new post.
    @discardableResult
    func focus(
        _ postID: String?, caretSeed: Int? = nil, fanSeed: String? = nil
    ) async throws -> EditorHarness? {
        if let leaving = active {
            let finalize = leaving.model.teardown()
            active = nil
            await finalize?.value
            await leaving.settle()
        }
        guard let postID else { return nil }
        let model = EditorViewModel(session: session, postID: postID)
        model.tailIdleSleep = { _ in throw CancellationError() }
        model.pendingCaretSeed = caretSeed
        model.pendingFanSeed = fanSeed
        let textView = EditorTextView.makeInlineEditor()
        textView.frame = NSRect(x: 0, y: 0, width: 600, height: 100)
        let surfaceDelegate = EditorSurfaceDelegate(model: model)
        surfaceDelegate.wire(to: textView)
        model.attach(textView: textView, scrollView: nil)
        session.editorRouter.active = model
        let harness = EditorHarness(
            session: session, database: database, model: model,
            textView: textView, surfaceDelegate: surfaceDelegate, postID: postID)
        try harness.reload()
        active = harness
        return harness
    }

    func storeText(_ postID: String) throws -> [String] {
        try database.read { db in
            try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" }
        }
    }
}

@MainActor
func withEditorWorld<T>(
    posts: [[String]],
    _ body: @MainActor (EditorWorldHarness) async throws -> T
) async throws -> T {
    // 13s closeout — the same block `withEditor` carries (its comment has
    // the trace): process-fresh typography, restored as found, and the
    // store carries the Terminal voice row so any in-test adoption keeps
    // the voice every measurement here was calibrated against.
    let foundTypography = EditorTypography.current
    let foundAdopted = EditorTypography.isAdopted
    defer {
        EditorTypography.current = foundTypography
        EditorTypography.isAdopted = foundAdopted
    }
    EditorTypography.current = EditorTypography.resolve(voice: .terminal, inlineComments: false)
    EditorTypography.isAdopted = false
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(.terminal)
        var postIDs: [String] = []
        for (i, blocks) in posts.enumerated() {
            let post = try session.operations.createPost(title: "P\(i)")
            for text in blocks {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            postIDs.append(post.id)
        }
        return try await body(
            EditorWorldHarness(session: session, database: db, postIDs: postIDs))
    }
}

@Suite("Focus handoff (Phase 10 Step 3)")
struct FocusHandoffTests {
    @Test func switchingFocusMidDirtyBufferLandsTheKeystrokes() async throws {
        try await withEditorWorld(posts: [["alpha"], ["bravo"]]) { w in
            let a = try await w.focus(w.postIDs[0])!
            a.type("!!", at: 5)  // dirty buffer — debounce hasn't fired
            #expect(a.model.autosave.isDirty)
            let b = try await w.focus(w.postIDs[1])!
            // The keystrokes landed in A's store through the teardown flush.
            #expect(try w.storeText(w.postIDs[0]) == ["alpha!!"])
            // B renders B — nothing leaked across the handoff.
            #expect(b.documentText == "bravo")
            #expect(w.session.editorRouter.active === b.model)
        }
    }

    @Test func switchingFocusMidOpenTailMintsToTheOldPost() async throws {
        try await withEditorWorld(posts: [["alpha"], ["bravo"]]) { w in
            let a = try await w.focus(w.postIDs[0])!
            a.type("\n", at: 5)      // Enter at the document end opens the tail
            a.type("fresh tail text")
            #expect(a.model.hasOpenTail)
            _ = try await w.focus(w.postIDs[1])
            // The tail minted into the OLD post, exactly once.
            #expect(try w.storeText(w.postIDs[0]) == ["alpha", "fresh tail text"])
            #expect(try w.storeText(w.postIDs[1]) == ["bravo"])
        }
    }

    @Test func switchingFocusMidCrystallizationFlightReconciles() async throws {
        try await withEditorWorld(posts: [["alpha"], ["bravo"]]) { w in
            let a = try await w.focus(w.postIDs[0])!
            a.type("\n", at: 5)  // open the tail
            // Typing past a completed paragraph launches the mint flight…
            a.type("First fresh paragraph.\n\nSecond still typing")
            // …and the switch happens while it is (or may be) in flight:
            // the handoff must wait it out, reconcile, and mint the residue.
            _ = try await w.focus(w.postIDs[1])
            #expect(try w.storeText(w.postIDs[0]) == [
                "alpha", "First fresh paragraph.\n", "Second still typing",
            ])
            // No duplicate block, no dropped text — exactly three slots,
            // and the typed blank line persists as trailing content (the
            // 2026-07-12 spacing ruling).
        }
    }

    @Test func exactlyOneLiveEditorAcrossARandomizedFocusWalk() async throws {
        try await withEditorWorld(posts: [["p0"], ["p1"], ["p2"]]) { w in
            var rng = SeededGenerator(seed: 42)
            var typed: [String: Int] = [:]  // postID -> marker count
            for step in 0..<12 {
                let postID = w.postIDs[Int(rng.next() % 3)]
                let h = try await w.focus(postID)!
                // The router knows exactly ONE live editor — the focused one.
                #expect(w.session.editorRouter.active === h.model)
                // Type a marker at the block's start; every marker must
                // survive every subsequent handoff.
                h.type("m", at: 0)
                typed[postID, default: 0] += 1
                if step % 3 == 2 { await h.flush() }
            }
            _ = try await w.focus(nil)
            #expect(w.session.editorRouter.active == nil)
            for postID in w.postIDs {
                let expected = String(repeating: "m", count: typed[postID] ?? 0)
                    + "p\(w.postIDs.firstIndex(of: postID)!)"
                #expect(try w.storeText(postID) == [expected])
            }
        }
    }

    @Test func caretAndFanSeedsApplyAtTheFirstRender() async throws {
        try await withEditorWorld(posts: [["alpha", "fanned block"]]) { w in
            // Fan the second block so the fan seed has a fan to open.
            let slots = try await w.database.read { [postID = w.postIDs[0]] in
                try Queries.renderPost($0, containerID: postID)
            }
            _ = try w.session.operations.branchVariant(
                slots[1].blockID, from: slots[1].variantID!)

            // A read-tier click at offset 8 ("fanned…" starts at 6) focuses
            // with the caret seeded; a badge tap also seeds the fan panel.
            let h = try await w.focus(
                w.postIDs[0], caretSeed: 8, fanSeed: slots[1].blockID)!
            #expect(h.textView.selectedRange() == NSRange(location: 8, length: 0))
            #expect(h.model.caretBlockID == slots[1].blockID)
            // The fan panel opens on the ONE live surface (interpretation 1).
            var spins = 0
            while h.model.fanPanel == nil, spins < 200 {
                spins += 1
                await Task.yield()
            }
            #expect(h.model.fanPanel?.blockID == slots[1].blockID)
            // The panel carries the block and nothing else (17f/P43); the
            // fan itself is the sheet's own read. That the block really is
            // fanned is a store fact, so assert it there.
            let fan = try await w.database.read { db in
                try Queries.blockFan(db, blockID: slots[1].blockID)
            }
            #expect(fan.count == 2)
        }
    }

    @Test func aSeedBeyondTheDocumentClampsInsteadOfCrashing() async throws {
        try await withEditorWorld(posts: [["tiny"]]) { w in
            let h = try await w.focus(w.postIDs[0], caretSeed: 9999)!
            #expect(h.textView.selectedRange().location == 4)
        }
    }
}

// MARK: - 13b Stage 3, Batch 3E (N12): the bare arrival claims the caret

/// N12 (3A-verified real, unlocked): a bare mode switch into Write — ⌘1,
/// no seed, no parked intent — left the caret NOWHERE; "⌘1 then type"
/// typed into the void. The fix rides `applyFocusSeeds` (the arriving
/// editor's one landing door): with nothing else claiming, the DETAIL
/// editor takes first responder at its first render. Scoped: the inline
/// book-view editor (scrollView nil) must NEVER steal focus as a render
/// side effect — the book's own focus model drives it.
/// Red-on-old: the claim branch is new — reverting it restores the
/// no-first-responder arrival and the first pin fails.
@MainActor
@Suite("Write's bare-arrival caret claim (13b 3E — N12)", .serialized)
struct BareArrivalFocusTests {
    @Test func aBareModeSwitchIntoWriteClaimsTheCaret() async throws {
        try await withEditor(seedBlocks: ["Alpha.", "Beta."]) { h in
            // A FRESH detail editor for the same post, hosted in a real
            // window BEFORE its first projection — the ⌘1 arrival shape.
            let model = EditorViewModel(session: h.session, postID: h.postID)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            model.attach(textView: textView, scrollView: scrollView)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 500),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = scrollView
            window.orderFrontRegardless()
            // A bare NSWindow AUTO-ASSIGNS its first key view on order-
            // front (the harness artifact the first run exposed) — the
            // real app's SwiftUI hosting does no such favor (the 3A drive
            // proved the void). Neutralize it so the pin exercises the
            // CLAIM, not AppKit's initial-key-view pick.
            window.makeFirstResponder(nil)
            #expect(window.firstResponder !== textView, "pre-arrival: nothing claimed")

            // The first projection arrives (the observation's delivery,
            // driven by hand): no caret seed, no fan seed, no intent.
            let (slots, header) = try await h.database.read { [postID = h.postID] db in
                (try Queries.renderPost(db, containerID: postID),
                 try Queries.containerHeader(db, containerID: postID))
            }
            model.adoptHeader(header)
            model.applyProjection(slots)

            #expect(window.firstResponder === textView,
                    "\u{2318}1 then type is literal — the arriving editor holds the caret")
            #expect(textView.selectedRange().location <= model.index.documentLength)
            model.teardown()
        }
    }

    @Test func theInlineBookEditorNeverStealsFocusOnRender() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { h in
            // The INLINE shape (the book view's): scrollView nil. Its
            // render must not grab the window from whatever the user is
            // doing — the book's focus model owns that.
            let model = EditorViewModel(session: h.session, postID: h.postID)
            model.tailIdleSleep = { _ in throw CancellationError() }
            let textView = EditorTextView.makeInlineEditor()
            let delegate = EditorSurfaceDelegate(model: model)
            delegate.wire(to: textView)
            model.attach(textView: textView, scrollView: nil)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 500),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 500))
            container.addSubview(textView)
            textView.frame = NSRect(x: 0, y: 0, width: 700, height: 200)
            window.contentView = container
            window.orderFrontRegardless()
            window.makeFirstResponder(nil)  // the same harness artifact

            let (slots, header) = try await h.database.read { [postID = h.postID] db in
                (try Queries.renderPost(db, containerID: postID),
                 try Queries.containerHeader(db, containerID: postID))
            }
            model.adoptHeader(header)
            model.applyProjection(slots)
            // Pumped turns so a (wrong) deferred claim would land too.
            for _ in 0..<4 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(15))
            }

            #expect(window.firstResponder !== textView,
                    "an inline render is never a focus grab")
            model.teardown()
        }
    }
}
