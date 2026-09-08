//
//  LandingOffsetTests.swift
//  VariorumTests
//
//  The 2026-09-06 use-report round, 17o batch b — **THE LANDING FAMILY**
//  (ledger rows 7 · 20 · 42; her ruling U-20, verbatim: *"when you are within
//  a block and then click go to write, you also end up with your caret at the
//  start of the block rather than where you were within it, which is annoying
//  on long blocks"*, and row 20: *"Opening in write from blocks puts your
//  cursor in the right place but doesn't move you there"*).
//
//  ONE rule: every door into Write lands at the REMEMBERED CARET OFFSET
//  inside the note's current block, and the arrival REVEALS it. Surfaces
//  with no caret report nil and land at the block's start, exactly as today.
//
//  Three pins live here:
//   1. the memory (pure) — it round-trips the offset, an OLD two-field
//      string reads nil, and a nil report never erases what it does not know;
//   2. `bareArrivalLanding` (pure over the index) — start + clamped offset;
//   3. the REVEAL (mounted, 250 paragraphs) — the seeded caret's line is
//      inside the scroll view's visible rect. Red on the old tree: the seed
//      arm set the selection and never scrolled, so a far block's caret sat
//      thousands of points below the viewport.
//
//  The round-trip across the modes is `CurrentBlockContinuityTests` (row 39's
//  rig, one expectation moved by this ruling — see its step 5).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Every door into Write lands where the caret was (17o batch b — rows 7 · 20 · 42)", .serialized)
struct LandingOffsetTests {

    // MARK: - 1. The memory (pure)

    @Test func theMemoryRoundTripsTheCaretOffsetAndReadsOldTwoFieldFactsAsUnknown() {
        let suite = "landing-offset-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }  // R1-8: no orphan plist per run
        var memory = CurrentBlockMemory()

        // An OLD memory — written before this batch, two fields — reads as an
        // unknown offset, which the landing spells "the block's start".
        defaults.set("b1|v1", forKey: CurrentBlockMemory.key("p1"))
        let old = CurrentBlockMemory()
        #expect(old.current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: nil))

        // A fact with an offset round-trips through a fresh memory (a relaunch).
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: 417),
            defaults: defaults)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: 417))

        // nil means UNKNOWN, never zero: a surface with no caret (Blocks' row,
        // the outline's card) reporting the SAME block keeps what is known.
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: nil),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.utf16Offset == 417)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)?.utf16Offset == 417,
                "…and it survives the persisted form too")

        // A DIFFERENT block resets it — an offset inside block one means
        // nothing inside block two.
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: nil),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: nil))

        // Zero is a real place (the block's first character), not "unknown".
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: 0),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.utf16Offset == 0)
        // The PERSISTED copy is written at block changes and when the note
        // leaves the screen — a caret walking inside one block never touches
        // `UserDefaults` (measured ~100 µs a write; the session dict is the
        // caret-rate truth). `persist` is the leaving door.
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: 55),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.utf16Offset == 55)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)?.utf16Offset == nil,
                "…the walk inside the block has not been written yet; b2 was persisted at its block change, with no offset known then")
        memory.persist(postID: "p1", defaults: defaults)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)?.utf16Offset == 55,
                "…and the leaving door writes it")

        memory.forget(postID: "p1", defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults) == nil)
    }

    /// The router's half of the same rule: the OBSERVED identity keeps its
    /// row-33 cadence (it changes when the block changes), while the offset
    /// rides fresh on every read — one truth, two lifetimes.
    @Test func theRouterCarriesTheOffsetWithoutMovingTheObservedIdentity() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = session.commandRouter
            defer { router.forgetCurrentBlock(for: "p1") }
            let token = router.registerDetail(postID: "p1", mode: .write) { _ in }
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1", utf16Offset: 0)
            #expect(router.focusedBlock?.utf16Offset == 0)
            // The ladder's R1-10 — the CADENCE itself, pinned (J18(1)'s
            // load-bearing claim): a same-block report at another offset
            // wakes NO observer of `focusedBlock`…
            let wakes = LockIsolated(0)
            withObservationTracking {
                _ = router.focusedBlock
            } onChange: {
                wakes.withValue { $0 += 1 }
            }
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1", utf16Offset: 312)
            #expect(wakes.value == 0, "a caret walking inside one block wakes nobody")
            #expect(router.focusedBlock == FocusedBlock(
                postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: 312),
                    "the caret walked inside the block and the fact says so")
            // A surface with no caret reports the same block: nothing known
            // is lost.
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1")
            #expect(router.focusedBlock?.utf16Offset == 312)
            // The memory holds it across the detail's life.
            router.unregisterDetail(token)
            #expect(router.focusedBlock == nil)
            #expect(router.currentBlock(for: "p1")?.utf16Offset == 312)
            let again = router.registerDetail(postID: "p1", mode: .takes) { _ in }
            #expect(router.focusedBlock?.utf16Offset == 312, "restored with the mount")
            // …and a BLOCK change DOES wake it (R1-10's positive arm — a
            // router that notified nobody at all would pass the negative).
            // Relative: the first tracker above is one-shot and fired at the
            // unregister's identity → nil, which is itself a real change.
            let before = wakes.value
            withObservationTracking {
                _ = router.focusedBlock
            } onChange: {
                wakes.withValue { $0 += 1 }
            }
            router.noteFocusedBlock("b2", variantID: "v2", postID: "p1", utf16Offset: 0)
            #expect(wakes.value == before + 1, "a block change wakes the observer")
            #expect(router.focusedBlock == FocusedBlock(
                postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: 0))
            router.unregisterDetail(again)
        }
    }

    // MARK: - 1b. The persisted copy at QUIT and at LOCK (the ladder's R1-4)

    /// 17o batch b's ladder, round 1 — R1-4 (MAJOR). Piece 5a made the
    /// persisted copy write only at a block/take change and "when the note
    /// leaves the screen" — `registerDetail` (a note change) and
    /// `unregisterDetail` (`onDisappear`). Neither runs at app termination:
    /// `applicationShouldTerminate` awaited the editors and replied, and
    /// `onDisappear` never fires when the process exits — so after ⌘Q the
    /// persisted offset was the block's ENTRY offset, never where she left
    /// (the record's capture 11 was written by the pre-5a binary's per-report
    /// write; the final binary only read it). The quit door and the lock
    /// door (`macWillLock`, the same leave-the-note event) both persist now.
    /// Red on the pre-fix tree at both doors: the fresh memory reads 3.
    @Test func theQuitAndLockDoorsPersistTheCaretPlaceTheSessionDictHolds() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = session.commandRouter
            defer { router.forgetCurrentBlock(for: "p1") }
            let token = router.registerDetail(postID: "p1", mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            // The block change writes the persisted copy (offset 3 — the
            // ENTRY offset); the walk inside the block does not (by design,
            // piece 5a).
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1", utf16Offset: 3)
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1", utf16Offset: 55)
            #expect(CurrentBlockMemory().current(for: "p1")?.utf16Offset == 3,
                    "the persisted copy lags the walk until a leaving door writes it")

            // THE QUIT DOOR — the real delegate method, nothing pending, so
            // the reply is the synchronous `.terminateNow` (the test host is
            // never asked to terminate: `.terminateLater`'s Task would call
            // `NSApp.reply(toApplicationShouldTerminate:)`).
            #expect(session.editorRouter.active == nil)
            #expect(session.quitFinalize.isEmpty)
            let delegate = VariorumAppDelegate()
            delegate.session = session
            let reply = delegate.applicationShouldTerminate(NSApp)
            #expect(reply == .terminateNow, "nothing pending ⇒ the synchronous branch")
            #expect(CurrentBlockMemory().current(for: "p1")?.utf16Offset == 55,
                    "⌘Q persists where she left (red-on-old: 3, the entry offset)")

            // THE LOCK DOOR — `macWillLock`'s road, the same leave-the-note event.
            router.noteFocusedBlock("b1", variantID: "v1", postID: "p1", utf16Offset: 72)
            #expect(CurrentBlockMemory().current(for: "p1")?.utf16Offset == 55)
            await macWillLock(session: session, stopServices: {})()
            #expect(CurrentBlockMemory().current(for: "p1")?.utf16Offset == 72,
                    "locking the store persists where she left (red-on-old: 55)")
        }
    }

    // MARK: - 2. The bare arrival's landing (pure over the index)

    @Test func theBareArrivalLandsAtTheBlocksStartPlusTheRememberedOffsetClamped() async throws {
        try await withEditor(seedBlocks: [
            "Block one — a short opening line.",
            "Block two — the long one she was standing in the middle of.",
            "Block three — the last.",
        ]) { h in
            let model = h.model
            let blocks = model.index.entries.map(\.blockID)
            let two = model.index.range(ofEntryAt: 1)

            // No fact at all: the document's start (unchanged).
            #expect(model.bareArrivalLanding(fact: nil) == 0)
            // A fact with NO offset: the block's start (unchanged — surfaces
            // that hold no caret land exactly as they did).
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(postID: h.postID, blockID: blocks[1], variantID: nil))
                == two.location)
            // U-20: the remembered offset INSIDE the block.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: h.postID, blockID: blocks[1], variantID: nil, utf16Offset: 12))
                == two.location + 12)
            // Past the block's current length (it shrank while she was away):
            // clamped to the block's END, never into the next block.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: h.postID, blockID: blocks[1], variantID: nil, utf16Offset: 9_999))
                == two.location + two.length)
            // A negative offset is nonsense: the block's start.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: h.postID, blockID: blocks[1], variantID: nil, utf16Offset: -5))
                == two.location)
            // Another post's fact is not this post's business (unchanged).
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: "elsewhere", blockID: blocks[1], variantID: nil, utf16Offset: 12))
                == 0)
        }
    }

    // MARK: - 2b. The parked reveal survives a stale-generation settle hop (the ladder's R1-5)

    /// 17o batch b's ladder, round 1 — R1-5 (MAJOR, timing). The reveal is
    /// PARKED at the landing and spent at the N14 layout-settle hop, because
    /// at landing time the text view's frame is still the pre-fill height.
    /// But a hop is scheduled with the generation it SAW: the empty editor's
    /// first display pass queues hop(G₁), and if the projection's delivery
    /// drains ahead of it — `renderFull` bumps G₂ and parks the reveal — that
    /// older hop ran `consumePendingReveal` against the very frame the park
    /// exists to wait out, spent it (the jump clamps at a couple of dozen
    /// points), and the honest hop(G₂) then found nothing parked: the row-20
    /// defect back, under a timing window. Now the park is stamped with its
    /// generation and a hop for an OLDER one leaves it alone — hop(G₂), which
    /// the bump guarantees, spends it. Red on the pre-fix tree: nil.
    @Test func aSettleHopForAnOlderGenerationLeavesTheParkedRevealForTheHonestOne() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the stale hop")
            var far: (block: String, variant: String)?
            for i in 1...40 {
                let minted = try session.operations.newBlock(
                    in: post.id, text: "Paragraph \(i): a line of the story, prose enough to matter.")
                if i == 30 { far = (minted.block.id, minted.variant.id) }
            }
            let target = try #require(far)
            let router = session.commandRouter
            router.forgetCurrentBlock(for: post.id)
            defer { router.forgetCurrentBlock(for: post.id) }
            let token = router.registerDetail(postID: post.id, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(target.block, variantID: target.variant, postID: post.id, utf16Offset: 9)

            // An UNLOADED model with a real surface attached (G₁) — the
            // `withEditor` harness pre-loads, so it is built by hand here.
            let model = EditorViewModel(session: session, postID: post.id)
            model.tailIdleSleep = { _ in throw CancellationError() }
            model.longBlockLayout.sleep = { _ in throw CancellationError() }
            let (scrollView, textView) = EditorTextView.makeEditor()
            let surfaceDelegate = EditorSurfaceDelegate(model: model)
            surfaceDelegate.wire(to: textView)
            model.attach(textView: textView, scrollView: scrollView)
            withExtendedLifetime((scrollView, surfaceDelegate)) {}

            // The projection, fetched FIRST: nothing may suspend between the
            // hop's scheduling and the park, or the hop runs before there is
            // anything to spend (the ordering under test is hop queued →
            // projection drains ahead of it).
            let (slots, header) = try await db.read { db in
                (try Queries.renderPost(db, containerID: post.id),
                 try Queries.containerHeader(db, containerID: post.id))
            }
            // The empty editor's first display pass: hop(G₁) is QUEUED.
            model.overlayLayoutDidSettle()
            // The projection drains ahead of that hop: renderFull (G₂) and
            // the arrival parks its reveal at the current block's place.
            model.adoptHeader(header)
            model.applyProjection(slots)
            let parked = model.pendingRevealOffset
            #expect(parked != nil, "the arrival parked a reveal (the landing is far down)")
            // hop(G₁) runs. A real suspension: the test body is itself a
            // main-queue job, so a nested runloop pump cannot re-enter the
            // main queue and a bare yield re-enqueues ahead of the older
            // dispatch block — `Task.sleep` hands the queue back.
            try await Task.sleep(for: .milliseconds(60))
            #expect(model.pendingRevealOffset == parked,
                    "a hop for the OLDER generation leaves the park for the honest one (red-on-old: spent — nil)")

            // The rider's arm: a park is per model, and models are per mount —
            // another note's editor never sees it.
            let other = try session.operations.createPost(title: "another note")
            let otherModel = EditorViewModel(session: session, postID: other.id)
            #expect(otherModel.pendingRevealOffset == nil)
            withExtendedLifetime((model, otherModel)) {}
        }
    }

    // MARK: - 3. The reveal (mounted, 250 paragraphs) — row 20

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
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

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    /// The 250-paragraph world, mounted: a real detail `EditorView` seeded at
    /// `entryIndex`'s block start — exactly what `PostDetailView.jump(to:)`
    /// hands it from the Blocks workbench's Open in Write. Reports the caret's
    /// laid-out line top and the scroll view's visible rect once the arrival
    /// has settled.
    private static func mountedLongNote(
        seed entryIndex: Int, rng: UInt64,
        _ body: @MainActor (_ caretTop: Double, _ visible: NSRect) throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: rng))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the long note")
            for i in 1...250 {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i): a sentence of the story, long enough to read as prose "
                        + "and to take a line or two of the column at this width.")
            }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            let slots = try await db.read { db in
                try Queries.renderPost(db, containerID: postID)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let seed = index.range(ofEntryAt: entryIndex).location

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: EditorView(session: session, postID: postID, caretSeed: seed)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first else {
                    return false
                }
                return view.string.count >= index.documentLength
                    && view.selectedRange().location == seed
            }, "the seeded caret lands in the target block")
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let scrollView = try #require(editor.enclosingScrollView)
            // Let the arrival's post-layout reveal settle.
            _ = await Self.settle(window, hosting, timeout: 2) { false }
            let caretTop = try #require(
                JumpPrimitive.lineTop(ofOffset: seed, in: editor), "the caret's line is laid out")
            let visible = scrollView.contentView.bounds
            try body(caretTop, visible)
            window.orderOut(nil)
            window.close()
            session.commandRouter.forgetCurrentBlock(for: postID)
        }
    }

    @Test func aSeededCaretFarDownALongNoteArrivesInsideTheVisibleRect() async throws {
        try await Self.mountedLongNote(seed: 199, rng: 20) { caretTop, visible in
            print("[17o b row 20] caret line top \(caretTop) · visible \(visible.minY)…\(visible.maxY)")
            #expect(caretTop >= Double(visible.minY) - 1,
                    "the caret's line is not above the viewport: \(caretTop) vs \(visible.minY)")
            #expect(caretTop <= Double(visible.maxY) - 1,
                    "the caret's line is ON SCREEN, not thousands of points below the viewport: \(caretTop) vs \(visible.maxY)")
        }
    }

    /// The guard's other half: a landing the page can ALREADY see moves
    /// nothing. "Reveal" means make visible, never "move" — without this a
    /// bare arrival would haul the caret's line to the viewport top on every
    /// ⌘2-then-⌘1, which is a lurch she never asked for.
    @Test func aSeededCaretTheViewportAlreadyShowsDoesNotScrollThePage() async throws {
        try await Self.mountedLongNote(seed: 1, rng: 21) { caretTop, visible in
            print("[17o b guard] caret line top \(caretTop) · visible \(visible.minY)…\(visible.maxY)")
            #expect(visible.minY == 0, "the page never scrolled: \(visible.minY)")
            #expect(caretTop <= Double(visible.maxY) - 1, "…and the caret is on screen anyway")
        }
    }

    // MARK: - 4. A landing at the NOTE'S END the viewport already shows (the ladder's round 2, R2-1)

    /// 17o batch b's ladder, round 2 — R2-1 (MAJOR). The bare arrival's
    /// landing is the document's END whenever the caret was remembered at the
    /// end of the last block (the ordinary "I stopped typing, then ⌘2, then
    /// ⌘1"). TK2 enumerates NO layout fragment from the document's end
    /// location, so `JumpPrimitive.lineSpan` answered nil there, the reveal's
    /// visibility guard was skipped, and `jump` — running the same
    /// enumeration — could not correct: the page sat at the clamped
    /// proportional estimate, `maxScroll`, the last line at the viewport top
    /// with the typewriter room below. On a three-block note that is the
    /// whole note scrolled off but its last line. Red on the pre-fix tree:
    /// `span nil`, `visible.minY 72.0` (docHeight 791, room 702, the text at
    /// 0…89). Now both functions resolve the end to the last line, so J18(2)'s
    /// rule — nothing moves when the caret is already on screen — reaches the
    /// one offset it could never see.
    @Test func aBareArrivalAtTheNotesEndTheViewportAlreadyShowsDoesNotScrollThePage() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a short note")
            var last: (block: String, variant: String)?
            for i in 1...3 {
                let minted = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i): a short line of prose, the whole note fits on one screen.")
                last = (minted.block.id, minted.variant.id)
            }
            let target = try #require(last)
            let postID = post.id
            let router = session.commandRouter
            router.forgetCurrentBlock(for: postID)
            defer { router.forgetCurrentBlock(for: postID) }
            let slots = try await db.read { db in try Queries.renderPost(db, containerID: postID) }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let lastRange = index.range(ofEntryAt: 2)
            #expect(lastRange.location + lastRange.length == index.documentLength,
                    "no open tail: the last block's end IS the document's end")
            // The memory: she was at the very END of the last block — the
            // commonest resting place after writing — so the bare arrival's
            // landing is the document's end.
            let token = router.registerDetail(postID: postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                target.block, variantID: target.variant, postID: postID,
                utf16Offset: lastRange.length)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: EditorView(session: session, postID: postID, caretSeed: nil)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first else { return false }
                return view.string.count >= index.documentLength
                    && view.selectedRange().location == index.documentLength
            }, "the bare arrival lands at the note's end")
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let scrollView = try #require(editor.enclosingScrollView)
            // Let the arrival's post-layout reveal settle.
            _ = await Self.settle(window, hosting, timeout: 2) { false }
            let visible = scrollView.contentView.bounds
            let span = JumpPrimitive.lineSpan(ofOffset: index.documentLength, in: editor)
            print("[17o b R2-1] visible \(visible.minY)…\(visible.maxY) · docHeight \(editor.frame.height) · room \(editor.typewriterRoom) · span \(String(describing: span))")
            #expect(span != nil,
                    "the note's end has a line — the last line of the last block (red-on-old: nil)")
            #expect(visible.minY == 0,
                    "a short note whose end is already on screen never scrolls on arrival (red-on-old: moved to maxScroll — \(visible.minY))")
            window.orderOut(nil)
            window.close()
        }
    }

    // MARK: - 5. The cold mount restores the session scroll anchor (the ladder's round 2, RAISE-M1)

    /// The 250-paragraph world mounted as a BARE arrival (no seed) with a
    /// session scroll anchor at `anchorEntry`'s start and, when `memoryEntry`
    /// is given, a remembered caret at that block's start + `memoryOffset`.
    /// Hands the body the anchor offset, the caret offset (or -1), the editor
    /// and the visible rect once the arrival and its settle hop are done.
    /// (Ints and views only — the SendNonSendable crash the batch's record
    /// names bites richer shapes.)
    private static func mountedLongNoteWithAnchor(
        anchorEntry: Int, memoryEntry: Int, memoryOffset: Int, rng: UInt64,
        _ body: @MainActor (_ anchor: Int, _ caret: Int, _ editor: EditorTextView, _ visible: NSRect) throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: rng))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the long note")
            var blocks: [String] = []
            var variants: [String] = []
            for i in 1...250 {
                let m = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i): a sentence of the story, long enough to read as prose "
                        + "and to take a line or two of the column at this width.")
                blocks.append(m.block.id)
                variants.append(m.variant.id)
            }
            let postID = post.id
            session.commandRouter.forgetCurrentBlock(for: postID)
            let slots = try await db.read { db in try Queries.renderPost(db, containerID: postID) }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let anchor = index.range(ofEntryAt: anchorEntry).location
            let caret = memoryEntry >= 0 ? index.range(ofEntryAt: memoryEntry).location + memoryOffset : -1
            // The session anchor she left with — the line at the viewport top
            // (a block's start is a line start).
            session.editorRouter.scrollAnchors[postID] = anchor
            let token = session.commandRouter.registerDetail(postID: postID, mode: .write) { _ in }
            // The cap's R3-3: the teardown on a `defer`, so a `#require`
            // throwing inside a body cannot leak this post's memory into
            // `UserDefaults.standard` (the R1-7 class). It captures only the
            // router and the id — a main-actor class and a String — which is
            // the shape the R1-4 pin's own `defer` already uses; the
            // dictionary-free form is what the `SendNonSendable` crash asked
            // for and is untouched.
            defer {
                session.commandRouter.unregisterDetail(token)
                session.editorRouter.scrollAnchors[postID] = nil
                session.commandRouter.forgetCurrentBlock(for: postID)
            }
            if memoryEntry >= 0 {
                session.commandRouter.noteFocusedBlock(
                    blocks[memoryEntry], variantID: variants[memoryEntry],
                    postID: postID, utf16Offset: memoryOffset)
            }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: EditorView(session: session, postID: postID, caretSeed: nil)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first else { return false }
                return view.string.count >= index.documentLength
            }, "the arrival fills the editor")
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let scrollView = try #require(editor.enclosingScrollView)
            // Let the arrival's settle hop (the anchor, then the reveal) land.
            _ = await Self.settle(window, hosting, timeout: 2) { false }
            try body(anchor, caret, editor, scrollView.contentView.bounds)
            window.orderOut(nil)
            window.close()
        }
    }

    /// The round-2 sanity pass's RAISE-M1, verified in use (capture M08):
    /// `renderFull` restored the session anchor through `JumpPrimitive.jump`
    /// against the PRE-FILL frame, whose `maxScroll` is a couple of dozen
    /// points — the very clamp the batch measured for the reveal and answered
    /// with the N14 settle hop — so on every cold mount (a mode switch mints
    /// one) the anchor contributed nothing and the page sat at ~24 pt. Now
    /// the cold mount PARKS the restore for the same hop, generation-stamped
    /// like the reveal. Red on the pre-fix tree: `visible.minY` ≈ 24 where
    /// the anchor's line top (thousands of points down) was owed.
    ///
    /// **It is also row 47's boundary** (17o batch d): this note remembers
    /// NOTHING, so the bare arrival's landing of 0 is a default rather than a
    /// place she left, and the reveal must not honour it — dropping the old
    /// `landing > 0` condition outright (the cap's designed shape) turns this
    /// pin red by 6927 pt, which is why the reveal now tests REMEMBERED.
    @Test func aColdMountRestoresTheSessionScrollAnchorAtTheSettleHop() async throws {
        try await Self.mountedLongNoteWithAnchor(
            anchorEntry: 199, memoryEntry: -1, memoryOffset: 0, rng: 51
        ) { anchor, _, editor, visible in
            let anchorTop = try #require(JumpPrimitive.lineTop(ofOffset: anchor, in: editor))
            print("[17o b RAISE-M1] anchor line top \(anchorTop) · visible \(visible.minY)…\(visible.maxY)")
            #expect(abs(Double(visible.minY) - anchorTop) <= 1,
                    "the page comes back to the anchor she left (red-on-old: ~24, the pre-fill clamp): \(visible.minY) vs \(anchorTop)")
        }
    }

    /// The same raise's felt half — her row 7's "doesn't leave you where you
    /// were", the PAGE's half: a mode round trip whose remembered caret is
    /// INSIDE the view she left returns to that view and moves nothing
    /// (the reveal's guard finds the caret on screen once the anchor is
    /// restored). Red on the pre-fix tree: the anchor clamped, the caret's
    /// block was off screen, and the reveal re-topped the page on it.
    @Test func aModeRoundTripReturnsToTheViewSheLeftWhenTheCaretIsInsideIt() async throws {
        try await Self.mountedLongNoteWithAnchor(
            anchorEntry: 199, memoryEntry: 202, memoryOffset: 5, rng: 52
        ) { anchor, caret, editor, visible in
            let anchorTop = try #require(JumpPrimitive.lineTop(ofOffset: anchor, in: editor))
            #expect(editor.selectedRange().location == caret, "the bare arrival landed at the remembered place")
            let caretSpan = try #require(JumpPrimitive.lineSpan(ofOffset: caret, in: editor))
            print("[17o b RAISE-M1 round trip] anchor top \(anchorTop) · caret line \(caretSpan.top)…\(caretSpan.bottom) · visible \(visible.minY)…\(visible.maxY)")
            #expect(abs(Double(visible.minY) - anchorTop) <= 1,
                    "the view she left, not the caret's line re-topped (red-on-old: \(visible.minY) == the caret's line top \(caretSpan.top))")
            #expect(caretSpan.top >= Double(visible.minY) - 1 && caretSpan.bottom <= Double(visible.maxY) + 1,
                    "…and the caret is on screen in it")
        }
    }

    /// **A remembered caret at offset 0 is revealed like any other** (ledger
    /// row 47; the batch-b ladder's cap, R3-1). The bare arrival parked its
    /// reveal only `if landing > 0` — an exemption round 1 dismissed as
    /// hollow because the cold-mount anchor restore clamped at ~24 pt and so
    /// hid nothing. Round 2's RAISE-M1 made the restore EXACT, and the
    /// exemption became reachable: the page returns to the far view she left
    /// (correct) and a landing of 0 — a real remembered 0 at the note's very
    /// start, a first block with no offset, or no memory at all — parks no
    /// reveal, so "⌘1 then type" (N12's literal promise) types off screen
    /// until AppKit's own insertion reveal hauls the page to the top.
    ///
    /// The fix is the condition's removal, not a second special case: the
    /// reveal's own visibility guard is the whole rule, which is why the
    /// no-anchor 0 (`aSeededCaretTheViewportAlreadyShowsDoesNotScrollThePage`)
    /// stays green on both sides — its line at 24 is already inside 0…719.
    @Test func aRememberedCaretAtTheNotesStartIsOnScreenUnderAFarAnchor() async throws {
        try await Self.mountedLongNoteWithAnchor(
            anchorEntry: 199, memoryEntry: 0, memoryOffset: 0, rng: 53
        ) { anchor, caret, editor, visible in
            #expect(caret == 0, "the memory really is the note's first character")
            #expect(editor.selectedRange().location == 0, "the bare arrival landed there")
            let anchorTop = try #require(JumpPrimitive.lineTop(ofOffset: anchor, in: editor))
            let caretSpan = try #require(JumpPrimitive.lineSpan(ofOffset: 0, in: editor))
            print("[17o d row 47] caret line \(caretSpan.top)…\(caretSpan.bottom) "
                  + "· anchor top \(anchorTop) · visible \(visible.minY)…\(visible.maxY)")
            #expect(caretSpan.top >= Double(visible.minY) - 1
                    && caretSpan.bottom <= Double(visible.maxY) + 1,
                    "the caret she will type at is on screen — red-on-old: the line at \(caretSpan.top) against a viewport at \(visible.minY)")
        }
    }
}
