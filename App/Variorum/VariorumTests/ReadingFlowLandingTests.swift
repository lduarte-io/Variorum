//
//  ReadingFlowLandingTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-4, PIN FIRST: batch B's
//  row 50 wired the navigator's chapter click in Read ▸ Scroll to
//  `model.requestReveal(first.postID)`, whose consumer is the flow's own
//  `land(_:)` — `withAnimation { proxy.scrollTo("flow-…", anchor: .top) }`
//  over a LazyVStack of ~20,000-pt `FlowPostView`s (the animated-scroll-
//  over-lazy-estimates class rows 44/9/12 traced), "not walked" by B's own
//  record. The first pin: the flow mounted over FIVE 215-block entries, the
//  reveal of the fifth requested after the mount (the navigator's road)
//  while the fifth is still UNLOADED, the fifth row's top at the flow's top
//  within tolerance. RED on the shipped form (1,562 pt short animated;
//  18,452 pt off unanimated and by identity alone — the pin-first runs;
//  11,828.5 pt off on the tree batch H began from, the pin disabled there
//  as ledger row 95); GREEN with batch H's segmented column — every story a
//  direct child at an honest height, the landing anchored.
//
//  The second pin (batch H): the reveal of the SECOND story requested at
//  the mount, before the first has loaded — the ascent's road, and the case
//  where the story directly above the target grows under it — lands and is
//  STILL at the top a second later.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Observable
final class FlowRevealBox {
    var reveal: String?
    var landedCount = 0
}

/// The host the app gives the flow, reduced to its landing half: the
/// reveal slot set after the mount, consumed through `onRevealLanded`.
private struct FlowHost: View {
    let session: AppSession
    let entries: [Queries.ReadingEntry]
    let box: FlowRevealBox
    /// Ladder R2-4: the book's cache, when the pin shares one across mounts.
    var extentsCache: FlowExtentsCache? = nil

    var body: some View {
        ReadingFlowView(
            session: session, readingName: "the flow",
            grouped: [(nil, entries)],
            onWake: { _, _ in },
            reveal: box.reveal,
            onRevealLanded: {
                box.landedCount += 1
                box.reveal = nil
            },
            extentsCache: extentsCache)
    }
}

@MainActor
@Suite("Read ▸ Scroll's chapter landing (ladder R1-4, pin-first; batch H)", .serialized)
struct ReadingFlowLandingTests {
    /// ONE tolerance with the finisher's (ladder R2-7).
    static let landingTolerance: CGFloat = ReadingFlowView.landingTolerance

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func documentHeight(_ view: NSView) -> CGFloat {
        if let scroll = view as? NSScrollView { return scroll.documentView?.frame.height ?? 0 }
        return view.subviews.map(documentHeight).max() ?? 0
    }

    /// Diagnostics: the flow's scroll view offset + document height.
    private static func scrollFacts(_ view: NSView) -> String {
        var facts: [String] = []
        func walk(_ v: NSView) {
            if let scroll = v as? NSScrollView {
                facts.append("offset=\(scroll.documentVisibleRect.origin.y) doc=\(scroll.documentView?.frame.height ?? 0) visible=\(scroll.documentVisibleRect.height)")
            }
            for s in v.subviews { walk(s) }
        }
        walk(view)
        return facts.joined(separator: " | ")
    }

    /// Sherlock-shaped stories (215 blocks each), in a fresh world.
    private func withFiveStories<T>(
        seed: UInt64,
        _ body: @MainActor (AppSession, [Queries.ReadingEntry]) async throws -> T
    ) async throws -> T {
        try await withStories(count: 5, seed: seed, body)
    }

    private func withStories<T>(
        count: Int, seed: UInt64,
        _ body: @MainActor (AppSession, [Queries.ReadingEntry]) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            var entries: [Queries.ReadingEntry] = []
            for p in 0..<count {
                let post = try session.operations.createPost(title: "story \(p)")
                for b in 0..<215 {
                    _ = try session.operations.newBlock(
                        in: post.id,
                        text: "Paragraph \(b) of story \(p). We were seated at breakfast one "
                            + "morning, my wife and I, when the maid brought in a telegram. It was "
                            + "from Sherlock Holmes and ran in this way: have you a couple of days "
                            + "to spare, and will you come with me to the west of England?")
                }
                entries.append(Queries.ReadingEntry(
                    postID: post.id, title: "story \(p)", entryDate: nil, sectionPath: nil))
            }
            return try await body(session, entries)
        }
    }

    private func mount(
        session: AppSession, entries: [Queries.ReadingEntry], box: FlowRevealBox,
        extentsCache: FlowExtentsCache? = nil
    ) -> (NSWindow, NSHostingView<AnyView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1000, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            FlowHost(session: session, entries: entries, box: box, extentsCache: extentsCache)
                .environment(ThemeStore(session: session))))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 760)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// The navigator's chapter click on an OPEN flow: the reveal of the
    /// fifth story arrives after the mount, while the fifth is UNLOADED
    /// (row 95's common case — the column's placeholders make the page
    /// tall at once, so the request meets stories that have not read their
    /// text). RED on the pre-batch tree (11,828.5 pt off); the record has
    /// the numbers.
    @Test func aRevealOfTheFifthLongEntryLandsItsRowAtTheTop() async throws {
        try await withFiveStories(seed: 19) { session, entries in
            #if DEBUG
            ReadingFlowGeometry.anchorTops = [:]
            ReadingFlowGeometry.trace = []
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box)
            defer {
                window.orderOut(nil)
                window.close()
            }
            // The flow up and its page standing at its honest height — the
            // first stories loading, the far ones placeholders.
            #expect(await settle(window, hosting, timeout: 20) {
                Self.documentHeight(hosting) >= 3 * 11_000
            }, "the flow mounted at its honest height (\(Self.scrollFacts(hosting)))")
            let target = entries[4].postID
            print("[batch H] before the reveal: every row's top: \(entries.map { ReadingFlowGeometry.anchorTops[$0.postID] }); \(Self.scrollFacts(hosting))")

            box.reveal = target
            let landed = await settle(window, hosting, timeout: 10) {
                ReadingFlowGeometry.anchorTops[target].map { abs($0) <= Self.landingTolerance } ?? false
            }
            let top = ReadingFlowGeometry.anchorTops[target]
            print("[batch H] flow reveal of story 5: its top after the settle = \(String(describing: top)) (tolerance \(Self.landingTolerance)); realized rows = \(ReadingFlowGeometry.anchorTops.count); landed acknowledgements = \(box.landedCount)")
            print("[batch H] every row's top: \(entries.map { ReadingFlowGeometry.anchorTops[$0.postID] })")
            print("[batch H] scroll facts: \(Self.scrollFacts(hosting)); trace: \(ReadingFlowGeometry.trace.suffix(30))")
            #expect(box.landedCount == 1, "the reveal was consumed exactly once")
            #expect(landed, "the fifth story's row sits at the top of the flow — top \(String(describing: top))")
        }
    }

    /// The ascent's road: the reveal of the SECOND story is set BEFORE the
    /// mount, so the flow lands at its `onAppear` with the first story
    /// unloaded — and the first story then loads directly above the target
    /// (the one event that moves a landed target). The row must be at the
    /// top once the landing settles AND still be there a second later.
    /// RED on the pre-batch tree by construction: the first story grew by
    /// ~20,000 pt under the target after the scroll.
    @Test func aRevealOfTheSecondStoryWithTheFirstUnloadedLandsAndHolds() async throws {
        try await withFiveStories(seed: 23) { session, entries in
            #if DEBUG
            ReadingFlowGeometry.anchorTops = [:]
            ReadingFlowGeometry.trace = []
            #endif
            let box = FlowRevealBox()
            let target = entries[1].postID
            box.reveal = target
            let (window, hosting) = mount(session: session, entries: entries, box: box)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let landed = await settle(window, hosting, timeout: 10) {
                ReadingFlowGeometry.anchorTops[target].map { abs($0) <= Self.landingTolerance } ?? false
            }
            let first = ReadingFlowGeometry.anchorTops[target]
            print("[batch H] second story, first unloaded: landed=\(landed) top=\(String(describing: first)); \(Self.scrollFacts(hosting))")
            #expect(landed, "the second story's row reaches the top — top \(String(describing: first))")
            // The hold: a second later the story above has loaded and the
            // column has settled — the target must still be at the top.
            _ = await settle(window, hosting, timeout: 1.5) { false }
            let held = ReadingFlowGeometry.anchorTops[target]
            print("[batch H] second story a second later: top=\(String(describing: held)); \(Self.scrollFacts(hosting)); trace: \(ReadingFlowGeometry.trace.suffix(40))")
            #expect(box.landedCount == 1, "the reveal was consumed exactly once")
            #expect(held.map { abs($0) <= Self.landingTolerance } ?? false,
                    "the second story's row is STILL at the top a second later — top \(String(describing: held))")
            #expect(Self.documentHeight(hosting) > 3 * 11_000,
                    "the column stands at its honest height: \(Self.documentHeight(hosting))")
        }
    }

    /// Sherlock's own shape — the navigator's TWELFTH story revealed on a
    /// fresh open, eleven unloaded stories above it. With the HONEST
    /// estimate the eleven stand as placeholders of their stated heights,
    /// the landing is exact and at most the one story above it loads under
    /// the target. Under a behavioral revert of the estimate (every
    /// never-measured story one blank line tall) the whole column fits the
    /// near band, every story loads and shifts the target, and the bounded
    /// re-lands run out: RED — the record has the numbers.
    @Test func aRevealOfTheTwelfthStoryWithElevenUnloadedAboveLandsAndHolds() async throws {
        try await withStories(count: 12, seed: 29) { session, entries in
            #if DEBUG
            ReadingFlowGeometry.anchorTops = [:]
            ReadingFlowGeometry.trace = []
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box)
            defer {
                window.orderOut(nil)
                window.close()
            }
            _ = await settle(window, hosting, timeout: 5) { Self.documentHeight(hosting) > 0 }
            let target = entries[11].postID
            box.reveal = target
            let landed = await settle(window, hosting, timeout: 12) {
                ReadingFlowGeometry.anchorTops[target].map { abs($0) <= Self.landingTolerance } ?? false
            }
            let first = ReadingFlowGeometry.anchorTops[target]
            #expect(landed, "the twelfth story's row reaches the top — top \(String(describing: first))")
            _ = await settle(window, hosting, timeout: 1.5) { false }
            let held = ReadingFlowGeometry.anchorTops[target]
            let relands = ReadingFlowGeometry.trace.filter { $0.hasPrefix("RE-LAND") }.count
            print("[batch H] twelfth story, eleven unloaded above: landed=\(landed) top=\(String(describing: first)) · a second later \(String(describing: held)) · re-lands \(relands) · realized rows \(ReadingFlowGeometry.anchorTops.count); \(Self.scrollFacts(hosting))")
            print("[batch H] trace: \(ReadingFlowGeometry.trace.suffix(30))")
            #expect(box.landedCount == 1, "the reveal was consumed exactly once")
            #expect(held.map { abs($0) <= Self.landingTolerance } ?? false,
                    "the twelfth story's row is STILL at the top a second later — top \(String(describing: held))")
            // Ladder R2-6: a REAL bound — the record's worst case (2) + 1,
            // never the budget itself (`anchorMoved` cannot exceed the
            // budget, so that comparison could not fail on any tree).
            #expect(relands <= 3,
                    "the re-lands stayed at the recorded worst case + 1: \(relands)")
        }
    }

    /// Ladder fix 2 (R2-2 + R2-3): "the stories above the target have
    /// settled" is GEOMETRY, never a clock. A near story above the target
    /// blocks the finish until its surface has SAID it settled — however
    /// long it has been loaded — and a story released to a placeholder and
    /// re-realized must say so again (the once-stamped load date is gone);
    /// a story BELOW the target never blocks. The two-clock race the seam
    /// closes has no deterministic red-on-old (the disposition labels it
    /// so); the old finisher had no settled set at all — a pure pin on the
    /// contract.
    @Test func theFinisherWaitsOnTheSurfacesWordNeverOnAClock() async throws {
        let landing = FlowLanding()
        landing.begin(anchor: "flow-s2", target: "s2", storiesInOrder: ["s1", "s2", "s3"])
        #expect(landing.aboveTargetSettled(), "nothing near above: nothing to wait for")
        landing.rowNear("s1", true)
        #expect(!landing.aboveTargetSettled(), "a near story above, unsettled, blocks")
        try await Task.sleep(for: .milliseconds(400))
        #expect(!landing.aboveTargetSettled(), "…and no clock ever settles it")
        landing.rowNear("s3", true)
        #expect(!landing.aboveTargetSettled())
        landing.rowSettled("s1")
        #expect(landing.aboveTargetSettled(), "the surface's own word settles it; the story below never mattered")
        landing.rowNear("s1", false)
        #expect(landing.aboveTargetSettled(), "far: a placeholder of a stated height, nothing to wait for")
        landing.rowNear("s1", true)
        #expect(!landing.aboveTargetSettled(), "re-realized: its new surface must speak again")
        landing.rowSettled("s1")
        #expect(landing.aboveTargetSettled())
        landing.end()
        #expect(landing.aboveTargetSettled(), "no landing pending: trivially settled")
    }

    /// Ladder fix 2 (R2-4): the lengths query is book-proportional and the
    /// flow is re-created per mode — so its extents are cached on the BOOK.
    /// A second mount over the same cache performs NO extents read and
    /// stands at its honest height at once. RED ON OLD (behavioral revert —
    /// the cache never consulted): two mounts, two reads.
    @Test func aSecondFlowMountOverTheBooksCachePerformsNoExtentsRead() async throws {
        try await withStories(count: 2, seed: 41) { session, entries in
            #if DEBUG
            ReadingFlowExtentsReads.count = 0
            #endif
            let cache = FlowExtentsCache()
            let firstBox = FlowRevealBox()
            let (window1, hosting1) = mount(
                session: session, entries: entries, box: firstBox, extentsCache: cache)
            let firstRead = await settle(window1, hosting1, timeout: 10) {
                ReadingFlowExtentsReads.count == 1 && Self.documentHeight(hosting1) > 2 * 11_000
            }
            #expect(firstRead, "the first mount read the lengths once and stands at its honest height (\(ReadingFlowExtentsReads.count) reads; \(Self.scrollFacts(hosting1)))")
            window1.contentView = NSView()
            window1.orderOut(nil)
            window1.close()

            let secondBox = FlowRevealBox()
            let (window2, hosting2) = mount(
                session: session, entries: entries, box: secondBox, extentsCache: cache)
            defer {
                window2.orderOut(nil)
                window2.close()
            }
            let honestAtOnce = await settle(window2, hosting2, timeout: 5) {
                Self.documentHeight(hosting2) > 2 * 11_000
            }
            _ = await settle(window2, hosting2, timeout: 1) { false }
            let reads = ReadingFlowExtentsReads.count
            print("[fix 2] extents reads across two mounts over one cache: \(reads); second mount \(Self.scrollFacts(hosting2))")
            #expect(honestAtOnce, "the second mount stands at its honest height from the cache")
            #expect(reads == 1, "the second mount performed no extents read: \(reads)")
        }
    }

    /// Ladder fix 2 (R2-12): a pending landing dies WITH its flow. Flow A
    /// is torn down inside its landing's first second (before the minimum
    /// hold can let it finish); flow B — no reveal, nothing to land — is
    /// mounted next and left past A's whole time budget: NO landing may
    /// write a `DONE` into the trace, because A's is gone. RED ON OLD: A's
    /// check kept re-arming against the dead proxy and finished — `DONE:
    /// settled` after the hold, or `gave up` at the budget — into B's world
    /// (the harness's own leak, which round 2 read in the second-story
    /// pin's trace).
    @Test func aFlowTornDownMidLandingLeaksNoDoneIntoTheNextFlow() async throws {
        try await withStories(count: 5, seed: 43) { session, entries in
            #if DEBUG
            ReadingFlowGeometry.anchorTops = [:]
            ReadingFlowGeometry.trace = []
            #endif
            let boxA = FlowRevealBox()
            boxA.reveal = entries[3].postID
            let (windowA, hostingA) = mount(session: session, entries: entries, box: boxA)
            let began = await settle(windowA, hostingA, timeout: 5) {
                ReadingFlowGeometry.trace.contains { $0.hasSuffix(" LAND") }
            }
            #expect(began, "flow A's landing began")
            // Torn down at once — well inside the 1-s minimum hold.
            windowA.contentView = NSView()
            windowA.orderOut(nil)
            windowA.close()
            let doneBefore = ReadingFlowGeometry.trace.filter { $0.contains(" DONE: ") }.count
            #expect(doneBefore == 0, "nothing finished before the teardown: \(ReadingFlowGeometry.trace.suffix(6))")

            let boxB = FlowRevealBox()
            let (windowB, hostingB) = mount(session: session, entries: entries, box: boxB)
            defer {
                windowB.orderOut(nil)
                windowB.close()
            }
            // Past A's whole time budget (4 s) and then some.
            _ = await settle(windowB, hostingB, timeout: BookView.landingTimeBudget + 1.5) { false }
            let doneAfter = ReadingFlowGeometry.trace.filter { $0.contains(" DONE: ") }
            print("[fix 2] DONE lines after A's teardown and B's mount: \(doneAfter)")
            #expect(doneAfter.isEmpty, "the torn-down flow's landing wrote no DONE into the next flow: \(doneAfter)")
        }
    }

    /// P3 for the flow, and the honest estimate's load-bearing pin: a
    /// twelve-story book mounted at a 760-pt viewport realizes only the
    /// stories inside the near band — the first, and at most one below it
    /// (the rest stand as placeholders of their ESTIMATED heights, far).
    /// RED under a behavioral revert of the estimate (every never-measured
    /// story one blank line tall): the whole column fits the band and all
    /// twelve surfaces are realized at once. Ladder fix 2 (R2-5) tightened
    /// the bound from 4 to 2: before the extents landed every story stood
    /// at the 800-pt prior, so the first THREE flipped near and mounted
    /// surfaces (three 215-block reads), two of which the lengths then
    /// pushed far and threw away — the current tree read 3 (RED on it); a
    /// story now stays FAR until its height is known.
    @Test func theFlowRealizesOnlyTheNearStoriesAtTheMount() async throws {
        try await withStories(count: 12, seed: 31) { session, entries in
            #if DEBUG
            ReadingFlowMaterialization.count = 0
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box)
            defer {
                window.orderOut(nil)
                window.close()
            }
            _ = await settle(window, hosting, timeout: 2) { false }
            let realized = ReadingFlowMaterialization.count
            print("[batch H] twelve stories at the mount: \(realized) surfaces realized; document \(Self.documentHeight(hosting)) pt")
            #expect(realized > 0, "the first story rendered")
            #expect(realized <= 2,
                    "only the near stories are surfaces — the far ones are placeholders at their estimated heights, and none mounts before its height is known: \(realized) realized")
        }
    }
}
