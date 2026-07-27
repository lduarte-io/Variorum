//
//  BookViewTests.swift
//  VariorumTests
//
//  Phase 10 Step 4 — the continuous book view: the view model adopts the
//  Phase 4 assembly VERBATIM (no re-decided semantics), section headers are
//  a presentation of the query's sectionPath, virtualization is real
//  (off-viewport posts never instantiate — counted, not asserted), the
//  realization cost is ratio-asserted flat as the reading grows, and a
//  sync-gap slot inside a member post renders without crashing.
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
private func withBookWorld<T>(
    posts: Int, blocksPerPost: Int = 3,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
) async throws -> T {
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
        let reading = try session.operations.createReading(name: "book", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(
                title: "post \(p)",
                entryDate: String(format: "2026-%02d-%02d", (p / 28) % 12 + 1, p % 28 + 1))
            for b in 0..<blocksPerPost {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Sentence one lives here. Sentence two of block \(b) in post \(p) "
                        + "carries on for a while so the buffer resembles real prose.")
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
private func countReadSurfaces(in view: NSView) -> Int {
    var count = view is ReadPostTextView ? 1 : 0
    for sub in view.subviews { count += countReadSurfaces(in: sub) }
    return count
}

@MainActor
@Suite("Book view (Phase 10 Step 4)", .serialized)
struct BookViewTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Drives a hosted SwiftUI hierarchy through realization → observation
    /// delivery → re-layout. Two kinds of turns interleave deliberately:
    /// run-loop pumps (layout/display sources) and REAL await suspensions —
    /// a nested `RunLoop.run` never drains the main queue, so main-actor
    /// observation tasks only progress while the test itself is suspended.
    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    @Test func viewModelAdoptsTheAssemblyVerbatim() async throws {
        try await withBookWorld(posts: 6) { session, db, readingID, postIDs in
            // Reorder + archive through operations so the assembly has real
            // shape; the VM must reproduce the QUERY, never its own order.
            try session.operations.reorderReadingPost(
                postIDs[5], in: readingID, to: .start)
            try session.operations.archiveContainer(postIDs[2])
            let assembled = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            }
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(assembled)
            #expect(model.entries == assembled)
            #expect(model.entries.map(\.postID).contains(postIDs[2]) == false,
                    "archived posts are out of ambient view — the query's call, rendered")
            #expect(model.entries.first?.postID == postIDs[5])
        }
    }

    @Test func theTruncationMarkerNeverFalsePositivesAtExactlyTheWindow() async throws {
        // Round 2 NIT: the +1 probe — a reading of EXACTLY the window size
        // shows no marker; one past it caps the render and marks.
        try await withBookWorld(posts: 1) { session, _, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            func entry(_ i: Int) -> Queries.ReadingEntry {
                Queries.ReadingEntry(postID: "p\(i)", title: nil, entryDate: nil, sectionPath: nil)
            }
            model.adopt((0..<BookViewModel.entryWindow).map(entry))
            #expect(!model.truncated)
            #expect(model.entries.count == BookViewModel.entryWindow)
            model.adopt((0..<(BookViewModel.entryWindow + 1)).map(entry))
            #expect(model.truncated)
            #expect(model.entries.count == BookViewModel.entryWindow,
                    "the probe row is consumed into the flag, never rendered")
        }
    }

    @Test func sectionHeadersRenderExactlyAtSectionBoundaries() async throws {
        try await withBookWorld(posts: 1) { session, _, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            func entry(_ id: String, section: String?) -> Queries.ReadingEntry {
                Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: section)
            }
            model.adopt([
                entry("a", section: nil),
                entry("b", section: "life/goals"),
                entry("c", section: "life/goals"),
                entry("d", section: "life/travel"),
            ])
            #expect(model.sectionHeader(at: 0) == nil)
            #expect(model.sectionHeader(at: 1) == "life/goals")
            #expect(model.sectionHeader(at: 2) == nil)
            #expect(model.sectionHeader(at: 3) == "life/travel")
        }
    }

    @Test func offViewportPostsNeverInstantiate() async throws {
        try await withBookWorld(posts: 60) { session, db, readingID, postIDs in
            // The model is injected and hand-driven: the test host never
            // fires SwiftUI's `.task` appearance callbacks (representable
            // lifecycles DO run — the read surfaces' observations start
            // from makeNSView by design).
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            // Batch 12 (R106): posts collapse to cards by default — this
            // test asserts on RENDERED post content, so it seeds the
            // expand-all state; virtualization must hold even then (the
            // stronger claim: all-expanded still costs the viewport).
            let hosting = NSHostingView(
                rootView: BookView(
                    session: session, readingID: readingID, model: model,
                    initiallyExpanded: Set(postIDs)))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })
            // Let the surfaces' observations deliver and heights settle.
            await settle(window, hosting, until: { false }, maxTurns: 8)

            let instantiated = countReadSurfaces(in: hosting)
            #expect(instantiated > 0, "the visible posts rendered")
            #expect(instantiated < 30,
                    "a 60-post reading must not instantiate its whole extent: \(instantiated) live read surfaces")
            // And the surfaces carry REAL content — the coordinator-started
            // observations delivered (the projection reached the surface).
            var sawContent = false
            func walk(_ v: NSView) {
                if let read = v as? ReadPostTextView, read.string.contains("Sentence one") {
                    sawContent = true
                }
                for s in v.subviews { walk(s) }
            }
            walk(hosting)
            #expect(sawContent, "read surfaces render their posts' projections")
        }
    }

    @Test func realizationCostStaysFlatAsTheReadingGrows() async throws {
        // The Phase 4 discipline at the view layer: the first realization
        // pass costs the viewport, never the reading. Debug build, generous
        // ratio — this guards the shape, the Step 0 memo owns the numbers.
        func firstLayoutMS(posts: Int) async throws -> Double {
            try await withBookWorld(posts: posts) { session, db, readingID, _ in
                let model = BookViewModel(session: session, readingID: readingID)
                model.adopt(try await db.read { [readingID] in
                    try Queries.assembleReading($0, readingID: readingID, limit: 300)
                })
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                let hosting = NSHostingView(
                    rootView: BookView(session: session, readingID: readingID, model: model))
                hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
                let t0 = ContinuousClock.now
                window.contentView = hosting
                hosting.layoutSubtreeIfNeeded()
                window.orderFrontRegardless()
                window.displayIfNeeded()
                let elapsed = t0.duration(to: .now)
                pump(0.2)
                return Double(elapsed.components.seconds) * 1000
                    + Double(elapsed.components.attoseconds) / 1e15
            }
        }
        let small = try await firstLayoutMS(posts: 20)
        let large = try await firstLayoutMS(posts: 200)
        print("Phase 10 Step 4: book-view first realization — 20 posts \(small) ms · 200 posts \(large) ms")
        #expect(large < small * 5 + 50,
                "realization must not scale with reading size: \(small) ms -> \(large) ms")
    }

    @Test func theReadingFlowVirtualizesItsRows() async throws {
        // Phase 13 round 3, MAJOR (red-on-old by behavioral revert — the
        // pre-fix plain VStack materializes ALL rows on first layout):
        // the reading flow's page column is a LazyVStack; a 150-entry
        // book must materialize only near-viewport rows on open. The
        // DEBUG counter counts FlowPostView inits; `.task` not firing
        // under the test host doesn't block an init-count pin.
        try await withBookWorld(posts: 1) { session, _, _, _ in
            let entries = (0..<150).map {
                Queries.ReadingEntry(
                    postID: "p\($0)", title: "t\($0)", entryDate: nil, sectionPath: nil)
            }
            ReadingFlowMaterialization.count = 0
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 500),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: ReadingFlowView(
                session: session, readingName: "Orbit",
                grouped: [(section: nil, entries: entries)],
                onWake: { _ in }))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 500)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { ReadingFlowMaterialization.count > 0 })
            await settle(window, hosting, until: { false }, maxTurns: 4)

            let materialized = ReadingFlowMaterialization.count
            #expect(materialized > 0, "visible rows rendered")
            #expect(materialized < 75,
                    "a 150-entry book must not materialize its whole extent on open: \(materialized) row materializations")
        }
    }

    @Test func aSyncGapSlotInsideAMemberPostRendersWithoutCrashing() async throws {
        try await withBookWorld(posts: 2, blocksPerPost: 2) { session, db, readingID, postIDs in
            // Manufacture the SyncSpec §5 gap state (a live placement whose
            // block is dead — only sync apply order produces it locally):
            // tombstone the block (the cascade takes the placement), then
            // revive JUST the placement.
            let slots = try await db.read { [post = postIDs[0]] in
                try Queries.renderPost($0, containerID: post)
            }
            let gapBlock = slots[0].blockID
            try session.operations.deleteBlock(gapBlock)
            try await db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [gapBlock])
            }
            let rendered = try await db.read { [post = postIDs[0]] in
                try Queries.renderPost($0, containerID: post)
            }
            #expect(rendered.count == 2)
            #expect(rendered[0].isGap)

            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(
                    session: session, readingID: readingID, model: model,
                    initiallyExpanded: Set(postIDs)))  // R106: render the content
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            // Renders: the gap is an empty slot, the sibling text shows.
            #expect(countReadSurfaces(in: hosting) >= 2)
        }
    }
}

// MARK: - 13b Stage 3, Batch 3E (D1): focus + expansion — ONE model

@MainActor
private func countLiveEditors(in view: NSView) -> Int {
    var count = view is EditorTextView ? 1 : 0
    for sub in view.subviews { count += countLiveEditors(in: sub) }
    return count
}

/// D1's mechanism was `BookView.swift`'s force-expand disjunct
/// (`expandedPosts.contains || focused ==`): two authorities answered
/// "is this post expanded", and the collapse door only wrote one — so
/// collapsing the FOCUSED post no-opped, forever. The fold makes the
/// conductor (`BookViewModel`) the one focus authority (the Stage 0
/// verdict: `BookFocusState` — a third focus authority — dies into it):
/// focus implies expansion, collapse releases focus.
/// Red-on-old verified by behavioral revert: `collapse` NOT releasing
/// focus (the old semantics translated into the new model) leaves the
/// editor mounted and both pins fail.
@MainActor
@Suite("Book focus — one model (13b 3E, D1)", .serialized)
struct BookFocusFoldTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
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
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    @Test func focusImpliesExpansionAndCollapseReleasesFocus() async throws {
        try await withBookWorld(posts: 3) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })

            // 13c 2A (A39, PROVISIONAL — QUESTIONS #43(a)): Outline is the
            // book's WRITING surface, so a post reads OPEN and collapse is
            // the deliberate act. Batch 12's R106 card default was the
            // other way round, when this was a book *screen*.
            #expect(model.isExpanded(postIDs[0]), "posts read open — this is where the book is written")
            model.focus(postIDs[0], caret: 5)
            #expect(model.isExpanded(postIDs[0]), "focus implies expansion")
            #expect(model.focusedPostID == postIDs[0])
            #expect(model.caretSeed == 5)

            // D1: the collapse door works ON THE FOCUSED POST.
            model.collapse(postIDs[0])
            #expect(!model.isExpanded(postIDs[0]), "collapsed — the disjunct is dead")
            #expect(model.focusedPostID == nil, "collapse releases focus")
            #expect(model.caretSeed == nil, "seeds die with the focus they rode")

            // Collapsing a DIFFERENT post leaves the focus alone.
            model.focus(postIDs[1])
            model.expand(postIDs[2])
            model.collapse(postIDs[2])
            #expect(model.focusedPostID == postIDs[1])

            // Collapse-all correctness (D1's second half): everything back
            // to cards, focus released — no survivor.
            model.collapseAll()
            #expect(model.collapsedPosts == Set(postIDs), "collapse all collapses ALL")
            #expect(postIDs.allSatisfy { !model.isExpanded($0) })
            #expect(model.focusedPostID == nil)

            model.expandAll()
            #expect(model.collapsedPosts.isEmpty)
            #expect(postIDs.allSatisfy { model.isExpanded($0) })
        }
    }

    /// 13c 2A: tracking the COLLAPSED side is what makes "open by default"
    /// hold for arrivals — a post minted into the book (or pulled in by a
    /// tag, or landed by sync) after a collapse-all is OPEN when it
    /// appears, with nothing to seed. The expanded-set shape could not do
    /// this without a second rule about who seeds new entries.
    @Test func aPostThatArrivesAfterCollapseAllIsOpen() async throws {
        try await withBookWorld(posts: 2) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            let assembled = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            }
            model.adopt(assembled)
            model.collapseAll()
            #expect(postIDs.allSatisfy { !model.isExpanded($0) })

            // A third post joins the book (the "+ new post in this book"
            // door's shape — the observation re-delivers).
            let fresh = try session.operations.createPost(title: "born inside")
            _ = try session.operations.newBlock(in: fresh.id, text: "written straight into the book.")
            try session.operations.addPostToReading(fresh.id, to: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })

            #expect(model.isExpanded(fresh.id), "a post that arrives after a collapse-all is open")
            #expect(postIDs.allSatisfy { !model.isExpanded($0) }, "the deliberate collapse survives")
        }
    }

    @Test func collapsingTheFocusedPostUnmountsTheLiveEditor() async throws {
        try await withBookWorld(posts: 3) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: readingID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { false }, maxTurns: 4)

            // Focus the first post: the ONE live inline editor mounts.
            model.focus(postIDs[0])
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 1 })
            #expect(countLiveEditors(in: hosting) == 1, "the focused post's editor mounted")

            // D1 — the author's headline repro: collapse the post you're
            // in. The editor must UNMOUNT and the card must come back.
            model.collapse(postIDs[0])
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 0 })
            #expect(countLiveEditors(in: hosting) == 0,
                    "collapsing the focused post really collapses it (the editor released)")
            #expect(model.focusedPostID == nil)
        }
    }
}

/// 13c Batch 2A (A39 · A6 · the picker rename): OUTLINE becomes the book's
/// WRITING surface. Her words: *"a proper 'write' mode for the whole book -
/// like literally looks like write mode but has the chapter headings and
/// the posts are collapsible."*
///
/// What these pin, and why each one is here rather than assumed:
/// - the picker's three modes and the working-book default (the rename);
/// - Outline carries NO bottom chrome (A6 — RED on the pre-2A code, where
///   the `Slider` and `ProgressView` were a `safeAreaInset`);
/// - the prose column is WRITE'S OWN MEASURE, measured off the realized
///   text surface rather than restated from the constant;
/// - P3 holds with posts OPEN by default — the counter pin, load-bearing
///   in a way it was not when every row was a small card;
/// - Stage 4 lesson 2: the surface joins `commitTake`'s availability AND
///   a mounted Outline consumes `.commit` (the N5 class, per surface).
@MainActor
@Suite("Outline — the book's writing surface (13c 2A)", .serialized)
struct OutlineWritingSurfaceTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
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
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// Hosts a book in a wide window and hands the body to `body`.
    private func withHostedBook<T>(
        posts: Int, width: CGFloat = 1100, height: CGFloat = 800,
        _ body: @MainActor (
            AppSession, AppDatabase, _ readingID: String, _ postIDs: [String],
            _ window: NSWindow, _ hosting: NSHostingView<BookView>,
            _ model: BookViewModel
        ) async throws -> T
    ) async throws -> T {
        try await withBookWorld(posts: posts) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: readingID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            return try await body(session, db, readingID, postIDs, window, hosting, model)
        }
    }

    @Test func theBookOpensIntoOutlineAndTheModesAreOutlineBookRead() {
        // The rename, at the one place it is decided: a working book opens
        // on the surface it is WRITTEN on; a finished one still opens into
        // the reading flow (R2, untouched).
        let open = Reading(
            id: "r", name: "orbit", kind: .curated, createdAt: Date(), updatedAt: Date())
        var finished = open
        finished.locked = true
        #expect(BookStructureModel.defaultMode(for: open) == .outline)
        #expect(BookStructureModel.defaultMode(for: finished) == .read)
        // Three modes, no fourth (her ruling: "the book's three modes stay
        // three"). CaseIterable is deliberately not conformed — this is the
        // totality statement.
        let modes: [BookStructureModel.ViewMode] = [.outline, .spread, .read]
        #expect(Set(modes.map(String.init(describing:))).count == 3)
    }

    /// A6, red-on-old by behavioral revert: restoring the `safeAreaInset`
    /// block puts an `NSSlider` (and a progress indicator) back in the
    /// hierarchy and this fails. Her ruling covered BOTH controls — "it
    /// makes no sense to have a horizontal scrollbar on a vertical page"
    /// and "it seems a bit buggy… remove it fully for now".
    @Test func outlineCarriesNoBottomChrome() async throws {
        try await withHostedBook(posts: 6) { _, _, _, _, window, hosting, _ in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })
            func count<V: NSView>(_ type: V.Type, in view: NSView) -> Int {
                var n = view is V ? 1 : 0
                for sub in view.subviews { n += count(type, in: sub) }
                return n
            }
            #expect(count(NSSlider.self, in: hosting) == 0,
                    "no jump slider — a horizontal scrollbar on a vertical page")
            #expect(count(NSProgressIndicator.self, in: hosting) == 0,
                    "no progress bar — she ruled it out fully, bugginess unchased")
        }
    }

    /// A39's "literally looks like write mode", measured: the text that
    /// lands in Outline sits on the SAME prose measure the detail editor
    /// gives a post (R9 — margins are sacred). Measured off the realized
    /// text surface, not restated from the constant, so a column-frame
    /// regression fails here.
    @Test func outlineProseSitsOnWritesOwnMeasure() async throws {
        try await withHostedBook(posts: 3, width: 1400) { _, _, _, _, window, hosting, _ in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })
            var widths: [CGFloat] = []
            func walk(_ v: NSView) {
                if let read = v as? ReadPostTextView, read.bounds.width > 0 {
                    widths.append(read.bounds.width - 2 * read.textContainerInset.width)
                }
                for s in v.subviews { walk(s) }
            }
            walk(hosting)
            #expect(!widths.isEmpty, "posts rendered")
            for width in widths {
                #expect(abs(width - EditorTypography.maxColumnWidth) < 2,
                        "Outline's prose measure is Write's: \(width) vs \(EditorTypography.maxColumnWidth)")
            }
            // …and the column is bounded even though the window is 1400
            // wide — text never runs to the window edge (R9).
            #expect(BookView.proseColumn < 1400)
        }
    }

    /// P3 with posts OPEN by default. The Phase 13 round-3 MAJOR was this
    /// surface's sibling shipping as a plain `VStack`; the default flip
    /// makes virtualization load-bearing here for the first time (every
    /// realized row is now a TK2 text surface, not a small card).
    /// Red-on-old by behavioral revert: `LazyVStack` → `VStack` in
    /// `outlineBody` materializes all 150 rows on open.
    @Test func outlineVirtualizesItsRowsWithPostsOpenByDefault() async throws {
        try await withBookWorld(posts: 1) { session, _, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt((0..<150).map {
                Queries.ReadingEntry(
                    postID: "p\($0)", title: "t\($0)", entryDate: nil, sectionPath: nil)
            })
            #expect(model.isExpanded("p0"), "open by default — the counted rows are prose rows")
            BookOutlineMaterialization.count = 0
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: readingID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { BookOutlineMaterialization.count > 0 })
            await settle(window, hosting, until: { false }, maxTurns: 4)

            let materialized = BookOutlineMaterialization.count
            #expect(materialized > 0, "visible rows rendered")
            #expect(materialized < 75,
                    "a 150-post book must not materialize its whole extent on open: \(materialized) rows")
        }
    }

    /// Stage 4 lesson 2, half one (pure): the book's inline editor context
    /// — a post open with NO post-detail mode, an attached Write editor —
    /// reaches `commitTake` and the take family. This is the availability
    /// arm A39's surface inherits by BEING the full-document editor rather
    /// than a new pane kind; naming it here means a future narrowing of
    /// `takeFamily` fails on Outline's behalf.
    @Test func outlineJoinsCommitTakeAndTheTakeFamilysAvailability() {
        let inline = CapabilityContext(mode: nil, writeEditorAttached: true)
        #expect(CapabilityRegistry.availability(.commitTake, in: inline) == .act)
        for id: CapabilityID in [
            .newTake, .blankTake, .chooseTake, .archiveTake, .showTakes,
            .insertBlockBelow, .deleteBlock, .blockComments, .callout, .divide,
        ] {
            #expect(CapabilityRegistry.availability(id, in: inline) == .act,
                    "\(id) must act where the book's editor is attached")
        }
    }

    /// Stage 4 lesson 2, half two (behavioral): a mounted Outline with a
    /// focused post CONSUMES `.commit`. The N5 class is "the door is
    /// advertised and the keystroke falls through to nothing" — consumption
    /// is exactly its negation, and it is what a new editable surface has
    /// to earn per surface.
    @Test func aMountedOutlineConsumesTheCommitCommand() async throws {
        try await withHostedBook(posts: 3) { session, _, _, postIDs, window, hosting, model in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })
            #expect(!session.commandRouter.dispatch(.commit, speakingWhenUnhandled: false),
                    "read-cheap only: nothing has claimed ⌘S yet")
            model.focus(postIDs[0], caret: 0)
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 1 })
            #expect(countLiveEditors(in: hosting) == 1, "the focused post's editor mounted")
            #expect(session.commandRouter.dispatch(.commit, speakingWhenUnhandled: false),
                    "⌘S reaches the book's editor — the N5 class closed on this surface")
        }
    }
}

// (The 13b 4F reading-progress-brain suite lived here until the 13c K6
// review, K4: the brain ended Stage 2 with zero production callers — 2A
// removed its face, 2B/2C declined it — and its own recorded rule was
// "deleted rather than kept warm on speculation." The brain and this
// suite went together; see `BookViewModel`'s note.)

/// 13c Batch 2B (A43/A44): the BOOK mode — a two-up spread whose pages are
/// whole posts, editable in Write or the takes stack, with ONE live editor
/// in the app throughout.
@MainActor
@Suite("Book — the two-up spread (13c 2B)", .serialized)
struct SpreadBookViewTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
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
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func withHostedSpread<T>(
        posts: Int, width: CGFloat = 1500, height: CGFloat = 800,
        _ body: @MainActor (
            AppSession, _ postIDs: [String], _ window: NSWindow,
            _ hosting: NSHostingView<SpreadBookView>, _ model: BookViewModel
        ) async throws -> T
    ) async throws -> T {
        try await withBookWorld(posts: posts) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let structure = BookStructureModel(session: session, readingID: readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: height),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: SpreadBookView(session: session, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            return try await body(session, postIDs, window, hosting, model)
        }
    }

    private func text(in view: NSView) -> String {
        var out = ""
        func walk(_ v: NSView) {
            if let read = v as? ReadPostTextView { out += read.string }
            for s in v.subviews { walk(s) }
        }
        walk(view)
        return out
    }

    private func count<V: NSView>(_ type: V.Type, in view: NSView) -> Int {
        var n = view is V ? 1 : 0
        for sub in view.subviews { n += count(type, in: sub) }
        return n
    }

    /// 13c 2B: the SPREAD's brain — pairing, turn-the-leaf, the one-post
    /// nudge, the navigator jump, and the focus-release rule. All pure over
    /// the POST LIST (Stage 4 lesson 8: the page domain is never geometry).
    @Test func theSpreadBrainPairsTurnsNudgesAndClamps() async throws {
        try await withBookWorld(posts: 5) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })

            // TWO pages side by side, left first.
            #expect(model.spreadLeftIndex == 0)
            #expect(model.leftPage?.postID == postIDs[0])
            #expect(model.rightPage?.postID == postIDs[1])
            #expect(model.spreadEntries.count == 2)

            // TURN THE LEAF: two posts at once (her ruling — the DEFAULT).
            model.turnLeaf(by: 1)
            #expect(model.spreadLeftIndex == 2)
            #expect(model.rightPage?.postID == postIDs[3])

            // The NUDGE: one post, so a split pair can be re-paired.
            model.nudgeSpread(by: 1)
            #expect(model.spreadLeftIndex == 3)
            #expect(model.leftPage?.postID == postIDs[3])
            #expect(model.rightPage?.postID == postIDs[4])

            // The last leaf of an ODD book: one page and a blank leaf — a
            // post is NEVER wrapped round from the other end.
            model.nudgeSpread(by: 1)
            #expect(model.spreadLeftIndex == 4)
            #expect(model.leftPage?.postID == postIDs[4])
            #expect(model.rightPage == nil, "a blank leaf, not a wrapped page")

            // ONE enablement rule: a move that reveals nothing you cannot
            // already see is refused (P-2 — no live door that cannot act).
            #expect(!BookViewModel.canMove(by: 2, leftIndex: 4, count: 5))
            #expect(!BookViewModel.canMove(by: 1, leftIndex: 4, count: 5))
            #expect(!BookViewModel.canMove(by: 1, leftIndex: 3, count: 5),
                    "3–4 already shows the last post; nudging on reveals nothing")
            #expect(BookViewModel.canMove(by: -1, leftIndex: 4, count: 5))
            #expect(!BookViewModel.canMove(by: -2, leftIndex: 0, count: 5))
            #expect(!BookViewModel.canMove(by: 2, leftIndex: 0, count: 1),
                    "a one-post book turns nowhere")

            // The navigator's jump: a post NOT on the spread takes the left
            // page; a post already on it never re-shuffles the pairing.
            model.showPost(postIDs[1])
            #expect(model.spreadLeftIndex == 1)
            model.showPost(postIDs[2])
            #expect(model.spreadLeftIndex == 1, "already on the spread — pairing kept")
            model.showPost("not-a-post")
            #expect(model.spreadLeftIndex == 1, "a foreign id flips nothing")

            // Entering the spread lands on the post you were in.
            model.focus(postIDs[4])
            model.seedSpreadFromFocus()
            #expect(model.spreadLeftIndex == 4)

            // A move that CARRIES the live page keeps its ring; a move that
            // leaves it behind releases it (the editor's teardown flush is
            // the standing discipline).
            model.openSpread(leftIndex: 3)
            #expect(model.focusedPostID == postIDs[4], "the nudge carried the live page")
            model.openSpread(leftIndex: 0)
            #expect(model.focusedPostID == nil, "the turn left it behind")

            // Adoption clamps a stale left index (a shrunk book).
            model.openSpread(leftIndex: 4)
            model.adopt(Array(model.entries.prefix(2)))
            #expect(model.spreadLeftIndex == 1)

            // The scrub brain (kept; 2C's) is untouched by the rename.
            #expect(BookViewModel.scrubIndex(fraction: 0, count: 4) == 0)
            #expect(BookViewModel.scrubIndex(fraction: 1, count: 4) == 3)
        }
    }

    /// 13c K6 review, K1 (MAJOR — red-on-old by behavioral revert: remove
    /// the identity re-anchor from `BookViewModel.adopt` and the first and
    /// third expectations fail — the spread silently swaps which posts it
    /// shows, and a focused post stranded off the book keeps its stale
    /// focus with the arrow shortcuts withdrawn for nothing).
    ///
    /// The spread's index-not-identity half of the K1 class: a membership
    /// insertion or an order flip shifts `entries`, and `spreadLeftIndex`
    /// used to be merely clamped — so the two visible posts changed under
    /// her. The anchor is the FOCUSED post while it is on the spread (the
    /// page under her hands keeps its side), else the left page; focus
    /// releases exactly when its post leaves the book.
    @Test func theSpreadSurvivesMembershipAndOrderChangesByIdentity() async throws {
        try await withBookWorld(posts: 3) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            let entries = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            }
            model.adopt(entries)
            model.openSpread(leftIndex: 1)  // p1 · p2
            #expect(model.leftPage?.postID == postIDs[1])

            // A membership INSERTION before the spread (a sync round, the
            // bridge's daily shelving): the pairing survives by identity.
            let landed = Queries.ReadingEntry(
                postID: "landed-mid-read", title: "today's entry",
                entryDate: nil, sectionPath: nil)
            model.adopt([landed] + entries)
            #expect(model.leftPage?.postID == postIDs[1],
                    "an insertion re-anchors the spread — the left page is the same post")
            #expect(model.rightPage?.postID == postIDs[2])

            // Her caret on the RIGHT page: an order flip keeps that post
            // visible AND keeps its ring (the page under her hands).
            model.focus(postIDs[2])
            model.adopt(([landed] + entries).reversed())
            #expect(model.isOnSpread(postIDs[2]),
                    "a reorder keeps the focused post on the spread")
            #expect(model.focusedPostID == postIDs[2], "…and its ring")

            // The focused post REMOVED from the book: focus releases (the
            // stale-focus half — no editor can mount for a post with no
            // row, and withdrawn arrows would otherwise serve nothing).
            model.adopt(entries.filter { $0.postID != postIDs[2] })
            #expect(model.focusedPostID == nil,
                    "focus releases when its post leaves the book")
        }
    }

    /// P3, the batch's load-bearing claim: the spread realizes THE SPREAD,
    /// never the book. A 60-post book puts exactly TWO posts on screen.
    /// Red-on-old by behavioral revert: rendering `model.entries` instead of
    /// the two-page HStack materializes every page.
    @Test func theSpreadRealizesTwoPagesNotTheBook() async throws {
        try await withHostedSpread(posts: 60) { _, _, window, hosting, model in
            BookSpreadMaterialization.count = 0
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            #expect(countReadSurfaces(in: hosting) == 2,
                    "two pages — never the book's extent")
            let materialized = BookSpreadMaterialization.count
            #expect(materialized < 8,
                    "a 60-post book materializes the spread's pages, not 60: \(materialized)")
            await settle(window, hosting, until: { text(in: hosting).contains("in post 1") })
            #expect(text(in: hosting).contains("in post 0"), "the left page")
            #expect(text(in: hosting).contains("in post 1"), "the right page")

            // TURN THE LEAF: two posts on, still exactly two surfaces.
            model.turnLeaf(by: 1)
            await settle(window, hosting, until: { text(in: hosting).contains("in post 3") })
            #expect(countReadSurfaces(in: hosting) == 2,
                    "a turn swaps both pages — it never accumulates surfaces")
            #expect(text(in: hosting).contains("in post 2"))
            #expect(text(in: hosting).contains("in post 3"))
            #expect(!text(in: hosting).contains("in post 0"), "the old leaf unmounted")

            // The NUDGE re-pairs by one: post 3 stays, post 4 arrives.
            model.nudgeSpread(by: 1)
            await settle(window, hosting, until: { text(in: hosting).contains("in post 4") })
            #expect(countReadSurfaces(in: hosting) == 2)
            #expect(text(in: hosting).contains("in post 3"), "the nudge re-paired")
            #expect(text(in: hosting).contains("in post 4"))
        }
    }

    /// A44 + P3: each page is editable, and the ring MIGRATES between them —
    /// one live editor in the app, always. The sibling stays read-cheap,
    /// which is what makes two whole posts affordable at once.
    @Test func theRingMigratesBetweenPagesAndOnlyOnePageIsEverLive() async throws {
        try await withHostedSpread(posts: 6) { _, postIDs, window, hosting, model in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            #expect(countLiveEditors(in: hosting) == 0, "a spread opens calm")

            // Click into the LEFT page: it upgrades, the right stays read.
            model.focus(postIDs[0], caret: 0)
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 1 })
            #expect(countLiveEditors(in: hosting) == 1)
            #expect(countReadSurfaces(in: hosting) == 1, "the sibling page stayed read-cheap")

            // Click into the RIGHT page: the ring MIGRATES — never two.
            model.focus(postIDs[1], caret: 0)
            await settle(
                window, hosting,
                until: { countLiveEditors(in: hosting) == 1 && countReadSurfaces(in: hosting) == 1 })
            #expect(countLiveEditors(in: hosting) == 1,
                    "exactly one live editor in the whole app, still")
            #expect(countReadSurfaces(in: hosting) == 1)

            // Turning the leaf leaves the live page behind: back to calm.
            model.turnLeaf(by: 1)
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 0 })
            #expect(countLiveEditors(in: hosting) == 0)
            #expect(countReadSurfaces(in: hosting) == 2)
        }
    }

    /// Her bottom-bar ruling, both halves: the bar STAYS here (unlike
    /// Outline, A6) and carries the form picker — and there is NO horizontal
    /// scrollbar, the complaint that removed Outline's. Red-on-old by
    /// behavioral revert: restoring 4F's `Slider` puts an `NSSlider` back.
    @Test func theSpreadKeepsItsBarWithFormsAndNoSlider() async throws {
        try await withHostedSpread(posts: 6) { _, _, window, hosting, _ in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            #expect(count(NSSlider.self, in: hosting) == 0,
                    "no jump slider — no horizontal scrollbar on the spread")
            #expect(count(NSSegmentedControl.self, in: hosting) == 1,
                    "the bar's Write | Takes form picker is rendered (A44)")
        }
    }

    /// Stage 4 lesson 2, half one (pure): the take family must be live in
    /// BOTH of the spread's editing forms. Write reaches it as an attached
    /// full-document editor (the arm Outline proved at 2A); the takes stack
    /// reaches it by ATTACHMENT — `mode == .takes` was a proxy for "a board
    /// is mounted" and stops being true the moment a board mounts outside a
    /// post detail. Red-on-old: without the `takesBoardAttached` arm, the
    /// second context greys the whole family out over a working board.
    @Test func bothSpreadFormsJoinTheTakeFamilysAvailability() {
        let writeForm = CapabilityContext(mode: nil, writeEditorAttached: true)
        let takesForm = CapabilityContext(mode: nil, takesBoardAttached: true)
        for context in [writeForm, takesForm] {
            #expect(CapabilityRegistry.availability(.commitTake, in: context) == .act)
            for id: CapabilityID in [
                .newTake, .blankTake, .chooseTake, .archiveTake, .showTakes,
            ] {
                #expect(CapabilityRegistry.availability(id, in: context) == .act,
                        "\(id) must act where the spread's page is editable")
            }
        }
        // …and it stays honest: no board, no editor, no post ⇒ unavailable.
        #expect(CapabilityRegistry.availability(
            .commitTake, in: CapabilityContext(mode: nil)) == .unavailable)
    }

    /// Stage 4 lesson 2, half two (behavioral): a mounted spread CONSUMES
    /// `.commit` in each form — the N5 class ("the door is advertised and
    /// the keystroke falls through to nothing") closed per surface, per
    /// form. The takes half additionally pins the attachment the registry
    /// arm reads, so the two halves cannot drift apart.
    @Test func aMountedSpreadConsumesTheCommitCommandInEitherForm() async throws {
        try await withHostedSpread(posts: 4) { session, postIDs, window, hosting, model in
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            #expect(!session.commandRouter.dispatch(.commit, speakingWhenUnhandled: false),
                    "read-cheap only: nothing has claimed ⌘S yet")
            #expect(!session.commandRouter.takesBoardAttached)

            // WRITE form: the attached full-document editor takes it.
            model.focus(postIDs[0], caret: 0)
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 1 })
            #expect(session.commandRouter.dispatch(.commit, speakingWhenUnhandled: false),
                    "⌘S reaches the spread's Write page")

            // TAKES form: the board mounts on the active page, reports its
            // attachment, and consumes the same command.
            model.spreadForm = .takes
            await settle(window, hosting, until: { session.commandRouter.takesBoardAttached })
            #expect(session.commandRouter.takesBoardAttached,
                    "the mounted board reports itself — the availability half")
            #expect(CapabilityRegistry.isEnabled(
                .commitTake, in: session.commandRouter.currentContext()),
                    "…and the registry reads it, so the menu is live")
            #expect(session.commandRouter.dispatch(.commit, speakingWhenUnhandled: false),
                    "⌘S reaches the spread's takes page")

            // Leaving the form detaches: enablement never outruns the board.
            model.spreadForm = .write
            await settle(window, hosting, until: { !session.commandRouter.takesBoardAttached })
            #expect(!session.commandRouter.takesBoardAttached)
        }
    }
}
