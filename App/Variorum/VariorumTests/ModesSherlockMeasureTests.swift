//
//  ModesSherlockMeasureTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — the MODE-LEVEL P1 statement, measured on the
//  real seeded corpus (Act 3's Sherlock: 12 stories · ~105k words · 2,533
//  blocks; the biggest story ~9,944 words / 212 blocks). The wave's new
//  surfaces — Index, Read, the Blocks workbench, and the book's Index /
//  Outline — each assemble from a small set of reads; this suite runs
//  exactly those reads at the two scales her corpus targets (the 10k note
//  and the 105k book) and PRINTS the numbers for the wave record.
//
//  The asserted ceilings are SANITY BOUNDS two orders above the measured
//  cost (the latency-pin lesson: a pin that reds under machine load cannot
//  do its job) — the real numbers are stated in the record, not asserted.
//  Substrate honesty: this world is the suite's in-memory store; Act 4's
//  on-disk SQLCipher numbers for the same corpus ran within ~1–2 ms of
//  these, so the substrate flatters nothing that matters at these bounds.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

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
@Suite("The new modes measured on Sherlock (pre-13u Act 10 wave 2c)")
struct ModesSherlockMeasureTests {

    @Test("Note-mode reads on the 10k story are note-shaped, never corpus-shaped")
    func noteModeReadsOnTheBiggestStory() async throws {
        try await withSeededSherlock { _, db in
            let clock = ContinuousClock()
            let bookID = try await db.read { db in
                try #require(Queries.readings(db)
                    .first { $0.name == SampleLibrarySeeder.bookName }).id
            }
            let entries = try await db.read { db in
                try Queries.assembleReading(db, readingID: bookID)
            }
            let copper = try #require(
                entries.first { $0.title == "The Adventure of the Copper Beeches" })

            // INDEX + READ — both modes' row source is the block TOC.
            let postID = copper.postID
            let (toc, rows) = try await db.read { db -> (Duration, [Queries.TOCRow]) in
                var value: [Queries.TOCRow] = []
                let time = try clock.measure {
                    value = try Queries.blockTOC(db, post: postID)
                }
                return (time, value)
            }
            // The outline derivation both modes run per projection (pure).
            var outline = NoteIndexOutline.outline(of: [])
            let grouping = clock.measure {
                outline = NoteIndexOutline.outline(
                    of: rows.map { ($0.blockID, $0.text) })
            }
            // The masthead word total (each mode's footer/masthead sum).
            var words = 0
            let counting = clock.measure {
                words = rows.reduce(0) { $0 + Queries.wordCount($1.text ?? "") }
            }
            // BLOCKS — the workbench's row source, real-corpus edition.
            let (workbench, bench) = try await db.read { db -> (Duration, [Queries.WorkbenchRow]) in
                var value: [Queries.WorkbenchRow] = []
                let time = try clock.measure {
                    value = try Queries.blockWorkbench(db, post: postID)
                }
                return (time, value)
            }
            // READ's pane / the book Index's per-note pane: the render.
            let (render, rendered) = try await db.read { db -> (Duration, [Queries.RenderedBlock]) in
                var value: [Queries.RenderedBlock] = []
                let time = try clock.measure {
                    value = try Queries.renderPost(db, containerID: postID)
                }
                return (time, value)
            }

            #expect(rows.count > 200)
            #expect(bench.count == rows.count)
            #expect(rendered.count == rows.count)
            #expect(outline.isFlat, "prose paragraphs, no headings — honestly flat")
            #expect(words > 9_000)
            print("[wave2c sherlock] blockTOC(copper beeches, \(rows.count) blocks): \(toc)")
            print("[wave2c sherlock] NoteIndexOutline.outline(same): \(grouping)")
            print("[wave2c sherlock] word-count sum(same): \(counting)")
            print("[wave2c sherlock] blockWorkbench(same): \(workbench)")
            print("[wave2c sherlock] renderPost(same): \(render)")
            // Sanity ceilings, two orders above measured.
            #expect(toc < .seconds(1))
            #expect(grouping < .seconds(1))
            #expect(counting < .seconds(1))
            #expect(workbench < .seconds(1))
            #expect(render < .seconds(1))
        }
    }

    @Test("Book Index/Outline reads on the 105k book are page-shaped")
    func bookModeReadsOnTheWholeBook() async throws {
        try await withSeededSherlock { _, db in
            let clock = ContinuousClock()
            let bookID = try await db.read { db in
                try #require(Queries.readings(db)
                    .first { $0.name == SampleLibrarySeeder.bookName }).id
            }

            // The book snapshot — what BookStructureModel + BookViewModel
            // read to stand the Outline/Index chrome up.
            typealias Snapshot = (
                entries: [Queries.ReadingEntry], sections: [ReadingSection],
                assignments: [String: String])
            let (snapshot, world) = try await db.read { db -> (Duration, Snapshot) in
                var value: Snapshot = ([], [], [:])
                let time = try clock.measure {
                    value = (
                        try Queries.assembleReading(db, readingID: bookID),
                        try Queries.readingSections(db, readingID: bookID),
                        try Queries.sectionAssignments(db, readingID: bookID))
                }
                return (time, value)
            }
            let (entries, sections, assignments) = world
            // The pure flattening the Index column renders from.
            var groups: [BookIndexColumn.Group] = []
            let flattening = clock.measure {
                groups = BookIndexColumn.groups(
                    chapters: BookStructureModel.grouped(
                        entries: entries, sections: sections,
                        assignments: assignments))
            }
            // The worst case nobody pays at once: every note of the 105k
            // book fully rendered (both panes realize lazily, per note).
            let postIDs = entries.map(\.postID)
            let (fullRealization, blockTotal) = try await db.read { db -> (Duration, Int) in
                var total = 0
                let time = try clock.measure {
                    for postID in postIDs {
                        total += try Queries.renderPost(db, containerID: postID).count
                    }
                }
                return (time, total)
            }

            #expect(entries.count == 13)
            #expect(sections.count == 13)
            #expect(groups.count == 13)
            #expect(blockTotal > 2_000)
            print("[wave2c sherlock] book snapshot(13 entries · 13 chapters): \(snapshot)")
            print("[wave2c sherlock] index-column flattening(same): \(flattening)")
            print("[wave2c sherlock] FULL 105k realization(\(blockTotal) blocks): \(fullRealization)")
            #expect(snapshot < .seconds(1))
            #expect(flattening < .seconds(1))
            #expect(fullRealization < .seconds(2), "the never-paid-at-once full price")
        }
    }
}
