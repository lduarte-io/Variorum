//
//  ReadingFlowTitleLinesTests.swift
//  VariorumTests
//
//  VX-881 (the VX-1036 run, batch 4) — the quiet title line in Read ▸ Scroll,
//  HOSTED: the line rides inside its story row, so it is realized only while
//  its story is near the viewport (P1/P3 — the round-3 materialization
//  counter's pattern), and a landing over titled stories still puts the
//  target's row — its title line — at the top of the page (the far rows stand
//  at the lead plus the prose, the column's manifest asks the same brain).
//  The harness is `ReadingFlowLandingTests`' own shape, re-stated here so this
//  suite needs nothing private of that one.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The flow as the book gives it, with the titles switch's value.
private struct TitledFlowHost: View {
    let session: AppSession
    let entries: [Queries.ReadingEntry]
    let box: FlowRevealBox
    let noteTitles: Bool

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
            noteTitles: noteTitles)
    }
}

@MainActor
@Suite("VX-881 — the title lines in Read ▸ Scroll (hosted)", .serialized)
struct ReadingFlowTitleLinesTests {
    /// ONE tolerance with the finisher's (the flow landing suite's own).
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

    /// Sherlock-shaped stories (215 blocks each), TITLED, in a fresh world.
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
        noteTitles: Bool
    ) -> (NSWindow, NSHostingView<AnyView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1000, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            TitledFlowHost(session: session, entries: entries, box: box, noteTitles: noteTitles)
                .environment(ThemeStore(session: session))))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 760)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// **The title lines are realized WITH their stories and no others** — a
    /// twelve-story book at a 760-pt viewport realizes only the near stories
    /// (the round-3 bound: at most two), and exactly one title line for each;
    /// the other ten titles exist nowhere (their rows are placeholders that
    /// carry the line's height, not the line).
    @Test func theTitleLinesAreRealizedOnlyWithTheirNearStories() async throws {
        try await withStories(count: 12, seed: 881) { session, entries in
            #if DEBUG
            ReadingFlowMaterialization.count = 0
            ReadingFlowMaterialization.titleLines = 0
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box, noteTitles: true)
            defer {
                window.orderOut(nil)
                window.close()
            }
            _ = await settle(window, hosting, timeout: 2) { false }
            #if DEBUG
            let stories = ReadingFlowMaterialization.count
            let titles = ReadingFlowMaterialization.titleLines
            print("[VX-881] twelve titled stories at the mount: \(stories) surfaces, \(titles) title lines")
            #expect(stories > 0 && stories <= 2, "only the near stories are realized: \(stories)")
            #expect(titles == stories, "one title line per realized story, none for the far ones: \(titles) for \(stories)")
            #endif
        }
    }

    /// A book hiding titles draws no line at all — today's page.
    @Test func aBookHidingTitlesDrawsNoLine() async throws {
        try await withStories(count: 4, seed: 882) { session, entries in
            #if DEBUG
            ReadingFlowMaterialization.count = 0
            ReadingFlowMaterialization.titleLines = 0
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box, noteTitles: false)
            defer {
                window.orderOut(nil)
                window.close()
            }
            _ = await settle(window, hosting, timeout: 2) { false }
            #if DEBUG
            #expect(ReadingFlowMaterialization.count > 0, "the first story rendered")
            #expect(ReadingFlowMaterialization.titleLines == 0, "no title line while the book hides them")
            #endif
        }
    }

    /// **A landing over titled stories** — the fifth story revealed after the
    /// mount, while it is unloaded: its row (the title line on top) lands at
    /// the top of the page. The stories above it stand at the lead plus their
    /// prose while far, the column's manifest counts the same, so the landing
    /// aims by honest geometry.
    @Test func aRevealOfATitledStoryLandsItsTitleAtTheTop() async throws {
        try await withStories(count: 5, seed: 883) { session, entries in
            #if DEBUG
            ReadingFlowGeometry.forgetAnchorTops()
            ReadingFlowGeometry.trace = []
            #endif
            let box = FlowRevealBox()
            let (window, hosting) = mount(session: session, entries: entries, box: box, noteTitles: true)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let mounted = await settle(window, hosting, timeout: 20) {
                Self.documentHeight(hosting) >= 3 * 11_000
            }
            #expect(mounted, "the flow mounted at its honest height")
            let target = entries[4].postID
            box.reveal = target
            let landed = await settle(window, hosting, timeout: 10) {
                ReadingFlowGeometry.anchorTops[target].map { abs($0) <= Self.landingTolerance } ?? false
            }
            let top = ReadingFlowGeometry.anchorTops[target]
            print("[VX-881] titled reveal of story 5: top \(String(describing: top)); trace \(ReadingFlowGeometry.trace.suffix(12))")
            #expect(box.landedCount == 1, "the reveal was consumed exactly once")
            #expect(landed, "the fifth story's row — its title line — sits at the top: \(String(describing: top))")
        }
    }
}
