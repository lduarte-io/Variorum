//
//  ReadingFlowEstimateTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch H (ledger row 95) — the flow's
//  honest geometry, pinned pure: the SEGMENTS (every story a direct child,
//  the small rows in lazy runs) and the HONEST ESTIMATE of a never-measured
//  story's height (`FlowHeightEstimate` — the paged reader's paragraph
//  model at the flow's metrics), plus the measurement that calibrates it:
//  the estimate against the REAL laid-out height of every story of the
//  seeded Sherlock library. The measurement PRINTS its table for the
//  batch record and asserts only a sanity bound around it (the latency-pin
//  lesson: a number that flips under machine load cannot pin anything;
//  a model that drifts by a third would).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("Read ▸ Scroll's segments and honest estimate (batch H, row 95)")
struct ReadingFlowEstimateTests {
    private func entry(_ id: String) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: nil)
    }
    private func section(_ id: String) -> ReadingSection {
        ReadingSection(
            id: id, readingId: "r", name: "chapter \(id)", position: id,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    /// Every post is its own segment (a direct child of the column); the
    /// title, a chapter heading and the closing mark stay in lazy RUNS
    /// between them; the story segment's id IS the landing anchor.
    @Test func segmentsMakeEveryStoryADirectChildAndKeepSmallRowsInRuns() {
        let rows = FlowRows.rows(
            readingName: "the book",
            grouped: [
                (section: section("s1"), entries: [entry("a"), entry("b")]),
                (section: section("s2"), entries: [entry("c")]),
            ])
        let segments = FlowRows.segments(rows)
        #expect(segments.map(\.id) == [
            "run-flow-title", "flow-a", "flow-b", "run-flow-chapter-s2", "flow-c", "run-flow-end",
        ])
        if case .run(let head) = segments[0] {
            #expect(head.map(\.id) == ["flow-title", "flow-chapter-s1"], "the title and the first heading share a run")
        } else {
            Issue.record("the first segment is the title's run")
        }
        #expect(segments.filter { if case .story = $0 { true } else { false } }.count == 3,
                "three stories, each a segment")
        // A flat book without a title or chapters: stories and the end mark.
        let flat = FlowRows.segments(FlowRows.rows(readingName: nil, grouped: [(nil, [entry("x")])]))
        #expect(flat.map(\.id) == ["flow-x", "run-flow-end"])
    }

    /// The paragraph model at the flow's metrics: nothing renders nothing
    /// (the blank line); a block is its paragraphs — `max(1, newlines)`,
    /// the stored separator rendering nothing — each ending mid-line (a
    /// half-line tail); text wraps at the measure; `lineSpacing` sits
    /// between a paragraph's lines only; the column's 13-pt gaps sit
    /// between paragraphs and between blocks. C = 80 chars/line, pitch 25
    /// (a 19-pt line + the 6-pt spacing), so the expected numbers below are
    /// the model's arithmetic by hand.
    @Test func theEstimateFollowsTheParagraphModel() {
        let metrics = FlowHeightEstimate.Metrics(charsPerLine: 80, linePitch: 25)
        func extent(_ characters: Int, newlines: Int = 0) -> Queries.BlockExtent {
            Queries.BlockExtent(containerID: "p", blockID: UUID().uuidString, characters: characters, newlines: newlines)
        }
        func height(_ extents: [Queries.BlockExtent]) -> Double {
            Double(FlowHeightEstimate.height(extents: extents, metrics: metrics))
        }
        #expect(height([]) == Double(FlowHeightEstimate.emptyNoteHeight))
        #expect(height([extent(0)]) == Double(FlowHeightEstimate.emptyNoteHeight),
                "a blank take renders nothing — the empty note's line")
        // 40 chars: half a line + the half-line tail = ONE line — a 19-pt
        // line, no spacing after it.
        #expect(abs(height([extent(40)]) - 19) < 0.6, "\(height([extent(40)]))")
        // 400 chars: five full lines + the tail = 5.5 lines × 25 − one
        // spacing = 131.5.
        #expect(abs(height([extent(400)]) - 131.5) < 0.6, "\(height([extent(400)]))")
        // The normal stored block ends in its paragraph separator — ONE
        // newline that renders nothing: still one paragraph.
        #expect(abs(height([extent(400, newlines: 1)]) - 131.5) < 0.6)
        // A newline beyond the separator is a real break: two paragraphs
        // (each its own tail: 5 + 1 = 6 lines), two spacings less, one
        // paragraph gap inside the block: 150 − 12 + 13 = 151.
        #expect(abs(height([extent(400, newlines: 2)]) - 151) < 0.6, "\(height([extent(400, newlines: 2)]))")
        // Two blocks: their heights plus one block gap: 131.5 + 19 + 13.
        #expect(abs(height([extent(400), extent(40)]) - 163.5) < 0.6, "\(height([extent(400), extent(40)]))")
        // Monotone in text.
        #expect(height([extent(4000)]) > height([extent(400)]))
    }

    /// The navigator's collapsed one-note chapter row (row 8) is the
    /// CHAPTER's door in Read — the flow's landing on a one-note-per-chapter
    /// book like Sherlock is reachable through it — and the note's door
    /// everywhere else, as row 8 built it.
    @Test func aCollapsedChapterRowIsTheChaptersDoorInReadAndTheNotesElsewhere() {
        #expect(!BookOutlineRows.collapsedChapterRowOpensTheNote(mode: .read))
        for mode in [BookStructureModel.ViewMode.outline, .index, .spread] {
            #expect(BookOutlineRows.collapsedChapterRowOpensTheNote(mode: mode), "\(mode) opens the note")
        }
    }

    /// The metrics come off the real page font, not a guess: a 600-pt
    /// measure holds a plausible number of 16-pt serif characters, and the
    /// pitch is the font's line height plus the flow's line spacing.
    @Test @MainActor func theMetricsAreMeasuredOffTheRealFont() {
        let metrics = FlowHeightEstimate.metrics(columnWidth: 600)
        #expect(metrics.charsPerLine > 50 && metrics.charsPerLine < 120,
                "16-pt serif at 600 pt: \(metrics.charsPerLine) characters per line")
        #expect(metrics.linePitch > 18 && metrics.linePitch < 32, "one line's pitch: \(metrics.linePitch)")
        let narrow = FlowHeightEstimate.metrics(columnWidth: 300)
        #expect(narrow.charsPerLine < metrics.charsPerLine, "a narrower measure holds fewer characters")
    }
}

// MARK: - The measurement against Sherlock (the record's evidence)

@MainActor
private func withSeededSherlock<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1661))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let mark = LockIsolated(false)
        _ = await SampleLibrarySeeder.seedIfNeeded(
            session: session,
            loadMark: { mark.value },
            saveMark: { flag in mark.setValue(flag) })
        return try await body(session, db)
    }
}

@MainActor
@Observable
private final class MeasureRevealBox {
    var reveal: String?
}

private struct MeasureHost: View {
    let session: AppSession
    let entries: [Queries.ReadingEntry]
    let box: MeasureRevealBox
    let memory: SurfaceSizeMemory

    var body: some View {
        ReadingFlowView(
            session: session, readingName: "the adventures",
            grouped: [(nil, entries)],
            onWake: { _, _ in },
            reveal: box.reveal,
            onRevealLanded: { box.reveal = nil },
            sizes: memory)
    }
}

@MainActor
@Suite("The flow's estimate measured against Sherlock (batch H)", .serialized)
struct ReadingFlowEstimateMeasureTests {
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

    /// Every story of the seeded Sherlock library revealed in turn on the
    /// flow (each reveal realizes it; its settled size lands in the
    /// memory), then the estimate from its block extents against the real
    /// height. The table is the record's; the bound is a sanity fence.
    @Test func theEstimateIsWithinTheStatedBoundOfEverySherlockStory() async throws {
        try await withSeededSherlock { session, db in
            let bookID = try await db.read { db in
                try #require(Queries.readings(db)
                    .first { $0.name == SampleLibrarySeeder.bookName }).id
            }
            let entries = try await db.read { db in
                try Queries.assembleReading(db, readingID: bookID)
            }
            let extents = try await db.read { db in
                Dictionary(grouping: try Queries.blockExtents(db, containerIDs: entries.map(\.postID)),
                           by: \.containerID)
            }
            let memory = SurfaceSizeMemory()
            let box = MeasureRevealBox()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1000, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: AnyView(
                MeasureHost(session: session, entries: entries, box: box, memory: memory)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 760)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            _ = await settle(window, hosting, timeout: 3) { false }

            // Reveal each story; wait for its settled size (the memory is
            // written on the settle, ~1 s after the last size change).
            var reals: [String: CGFloat] = [:]
            for entry in entries {
                box.reveal = entry.postID
                let deadline = Date().addingTimeInterval(8)
                var last: CGFloat?
                var stableSince = Date()
                while Date() < deadline {
                    _ = await settle(window, hosting, timeout: 0.1) { false }
                    let now = memory.size(entry.postID)?.height
                    if now != last { last = now; stableSince = Date() }
                    if now != nil, Date().timeIntervalSince(stableSince) > 1.3 { break }
                }
                reals[entry.postID] = last
            }

            let metrics = FlowHeightEstimate.metrics(columnWidth: 600)
            print("[batch H] flow metrics at 600 pt: \(metrics.charsPerLine) chars/line · pitch \(metrics.linePitch) · calibration \(FlowHeightEstimate.calibration)")
            var ratios: [Double] = []
            for entry in entries {
                let blocks = extents[entry.postID] ?? []
                let estimate = FlowHeightEstimate.height(extents: blocks, metrics: metrics)
                guard let real = reals[entry.postID] else {
                    Issue.record("\(entry.displayTitle): its real height never settled")
                    continue
                }
                let ratio = Double(estimate / real)
                ratios.append(ratio)
                let chars = blocks.reduce(0) { $0 + $1.characters }
                let newlines = blocks.reduce(0) { $0 + $1.newlines }
                print("[batch H] \(entry.displayTitle) · \(blocks.count) blocks · \(chars) chars · \(newlines) newlines · real \(Int(real)) · estimate \(Int(estimate)) · ratio \(String(format: "%.3f", ratio))")
            }
            #expect(ratios.count == entries.count, "every story measured")
            let worst = ratios.map { abs($0 - 1) }.max() ?? 1
            let median = ratios.sorted()[ratios.count / 2]
            print("[batch H] estimate/real — median \(String(format: "%.3f", median)) · worst deviation \(String(format: "%.1f", worst * 100))%")
            #expect(worst < 0.33, "no story's estimate is off by a third: worst \(worst)")
            #expect(abs(median - 1) < 0.2, "the median estimate is within a fifth: \(median)")
        }
    }
}
