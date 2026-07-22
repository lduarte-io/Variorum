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

            #expect(!model.isExpanded(postIDs[0]), "cards by default (R106)")
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
            #expect(model.expandedPosts.isEmpty, "collapse all collapses ALL")
            #expect(model.focusedPostID == nil)

            model.expandAll()
            #expect(model.expandedPosts == Set(postIDs))
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

/// 13b Stage 4, Batch 4F (S4-9, ledger N31): the book-view package's model
/// brains + the paged view's P1/P3 shape. Progress and pages are BOTH
/// model-driven over the POST LIST (the Phase 6 memo's ruling — never live
/// text/pixel geometry); the paged view mounts exactly ONE page.
@MainActor
@Suite("Paged view + progress bar (13b 4F, S4-9)", .serialized)
struct PagedBookViewTests {
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

    @Test func theProgressBrainIsPureModelDrivenAndSticky() async throws {
        try await withBookWorld(posts: 5) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            #expect(model.readingProgress == nil, "an unadopted book shows nothing")
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })

            // Before any visibility report: position 1 (the top).
            #expect(model.readingProgress?.position == 1)
            #expect(model.readingProgress?.total == 5)

            // The FURTHEST visible post is the position (post domain,
            // never pixels).
            model.noteVisible(postIDs[0], true)
            model.noteVisible(postIDs[1], true)
            #expect(model.readingProgress?.position == 2)
            #expect(model.readingProgress?.fraction == 0.4)

            // Scrolling on: 1 leaves, 3 arrives (index 2 visible too).
            model.noteVisible(postIDs[0], false)
            model.noteVisible(postIDs[2], true)
            #expect(model.readingProgress?.position == 3)

            // STICKY: a transition frame with zero reports keeps the last
            // position instead of snapping to nothing.
            model.noteVisible(postIDs[1], false)
            model.noteVisible(postIDs[2], false)
            #expect(model.readingProgress?.position == 3)

            // A foreign id (a stale report after entries changed) counts
            // for nothing.
            model.noteVisible("not-a-post", true)
            #expect(model.readingProgress?.position == 3)

            // The pure half directly: last page = 100%.
            let position = BookViewModel.progressPosition(
                visible: [postIDs[4]], entries: model.entries, previous: nil)
            #expect(position == 5)
        }
    }

    @Test func thePageBrainClampsFlipsSeedsAndReleasesFocus() async throws {
        try await withBookWorld(posts: 4) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })

            #expect(model.pagedIndex == 0)
            #expect(model.currentPage?.postID == postIDs[0])

            // Flips clamp at both covers.
            model.flipPage(by: -1)
            #expect(model.pagedIndex == 0)
            model.flipPage(by: 1)
            #expect(model.pagedIndex == 1)
            model.openPage(99)
            #expect(model.pagedIndex == 3, "clamped to the last page")

            // The navigator's page-jump door.
            model.openPage(post: postIDs[2])
            #expect(model.pagedIndex == 2)
            model.openPage(post: "not-a-post")
            #expect(model.pagedIndex == 2, "a foreign id flips nothing")

            // Entering pages lands on the post you were in (focus wins).
            model.focus(postIDs[1])
            model.seedPageFromFocus()
            #expect(model.pagedIndex == 1)

            // Flipping AWAY from a live page releases focus (pages open
            // read-cheap — the calm default; the editor's teardown flush
            // is the standing discipline).
            model.flipPage(by: 1)
            #expect(model.focusedPostID == nil, "the flip released focus")

            // Adoption clamps a stale page index (a shrunk book).
            model.openPage(3)
            model.adopt(Array(model.entries.prefix(2)))
            #expect(model.pagedIndex == 1)

            // The scrub brain is the SAME one the scroll view uses.
            #expect(BookViewModel.scrubIndex(fraction: 0, count: 4) == 0)
            #expect(BookViewModel.scrubIndex(fraction: 1, count: 4) == 3)
        }
    }

    @Test func thePagedViewRealizesExactlyOnePageAndFlipsContent() async throws {
        try await withBookWorld(posts: 60) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let structure = BookStructureModel(session: session, readingID: readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: PagedBookView(session: session, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })

            // P1/P3's shape: ONE page mounts — a 60-post book realizes
            // exactly one read surface, independent of book size.
            #expect(countReadSurfaces(in: hosting) == 1,
                    "the paged view mounts exactly the current page")
            func pageText() -> String {
                var text = ""
                func walk(_ v: NSView) {
                    if let read = v as? ReadPostTextView { text += read.string }
                    for s in v.subviews { walk(s) }
                }
                walk(hosting)
                return text
            }
            await settle(window, hosting, until: { pageText().contains("in post 0") })
            #expect(pageText().contains("in post 0"), "page 1 shows the first post")

            // Flip: still one surface, and the CONTENT is the next post's.
            model.flipPage(by: 1)
            await settle(window, hosting, until: { pageText().contains("in post 1") })
            #expect(countReadSurfaces(in: hosting) == 1,
                    "a flip swaps the page — it never accumulates surfaces")
            #expect(pageText().contains("in post 1"))
            #expect(!pageText().contains("in post 0"), "the old page unmounted")

            // Focus upgrades the current page to THE one live editor.
            model.focus(postIDs[1])
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 1 })
            #expect(countLiveEditors(in: hosting) == 1)
            #expect(countReadSurfaces(in: hosting) == 0,
                    "the page upgraded — read tier swapped for the live editor")

            // Flipping away releases focus and returns read-cheap.
            model.flipPage(by: 1)
            await settle(window, hosting, until: { countLiveEditors(in: hosting) == 0 })
            #expect(countLiveEditors(in: hosting) == 0)
            #expect(countReadSurfaces(in: hosting) == 1)
        }
    }
}
