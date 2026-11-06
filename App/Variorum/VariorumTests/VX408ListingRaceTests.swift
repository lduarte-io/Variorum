//
//  VX408ListingRaceTests.swift
//  VariorumTests
//
//  **VX-408 (the VX-819 run, batch 2) — an in-place refresh racing a newer
//  question.** The ticket (Bug · Suspected, never observed): the List's
//  one-shot `search()` answer can be overtaken by an in-place `refresh()` —
//  the listing follow (VX-384) or the `.variorumNotesDeleted` road — while a
//  newer question is still in flight. The pin comes FIRST, as the confirm
//  (the batch brief's rule); the record is the run file's BATCH 2 LIVE
//  STATUS.
//
//  The two orders, traced (`LibraryCatalogModel.read`: the generation is
//  bumped and the question captured synchronously before the one `await`;
//  only the newest read lands):
//
//  - **A — the refresh BEGUN BEFORE the newer question, its answer held
//    until that question has landed** (the brief's interleaving: "the older
//    answer could paint over the newer question's"). Its generation is older
//    when it resolves, so it never lands. Expected GREEN on the pre-fix tree:
//    the stale-paint mechanism is unreachable — the hollow half of the
//    ticket, kept as a guard of the generation rule.
//  - **B — the refresh BEGUN AFTER the newer question began** (the ticket's
//    own recorded edge, `notes/plans/fixes/vx-348-prelaunch-sweep.md`: "can
//    supersede a NEW question's `search()` still in flight … landed in place
//    rather than from its first page"). It bumps past the search, reads the
//    CURRENT question — the right answer — and lands it IN PLACE: at the old
//    listing's depth, with the old listing's visible positions kept (their
//    ids left the index, so no row's disappearance can ever remove them) —
//    the near window stretched over the old depth and every row asking for
//    the next page at once. Expected RED on the pre-fix tree.
//
//  The completion order A needs is held by `listingAnswerGate` (DEBUG only):
//  the in-memory store is a serial queue, so a read begun first always
//  resolves first on its own.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-408 — an in-place refresh racing a newer question", .serialized)
struct VX408ListingRaceTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(41) }
                return value
            }
        }
    }

    /// One read's answer, held at the seam until released — the FIRST read
    /// to reach the seam is the one held; every later read passes.
    @MainActor
    private final class Hold {
        private(set) var generation: Int?
        private var continuation: CheckedContinuation<Void, Never>?

        var isHolding: Bool { continuation != nil }

        func gate(_ generation: Int) async {
            guard self.generation == nil else { return }
            self.generation = generation
            await withCheckedContinuation { continuation = $0 }
        }

        func release() {
            continuation?.resume()
            continuation = nil
        }
    }

    private func withNotes<T>(
        _ count: Int,
        _ body: @MainActor (AppSession, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 408))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Created in order, so the default listing (edited, newest
            // first) and the title order (A–Z) disagree.
            for index in 0..<count {
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words \(index)")
            }
            let suite = "vx-408-race-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            return try await body(session, model)
        }
    }

    private var page: Int { LibraryCatalogModel.pageSize }

    /// The titles in the title sort's order (A–Z, ASCII case-folded — the
    /// listing's own `COLLATE NOCASE`).
    private func titleOrder(_ titles: [String]) -> [String] {
        titles.sorted { $0.lowercased() < $1.lowercased() }
    }

    /// **A — the brief's interleaving: a refresh begun BEFORE a newer
    /// question, its answer held until that question has landed, then
    /// released.** The newer question's answer stands: the older one never
    /// lands (its generation is no longer the newest). GREEN on the pre-fix
    /// tree by the trace — the stale-paint half of VX-408 is unreachable.
    @Test func aRefreshBegunBeforeANewerQuestionNeverPaintsOverItsAnswer() async throws {
        try await withNotes(12) { _, model in
            await model.search()
            #expect(model.sort == .lastTouched, "premise: the edited order")
            let edited = model.noteHits.map(\.title)
            #expect(edited != titleOrder(edited), "premise: the two orders differ")

            let hold = Hold()
            model.listingAnswerGate = { await hold.gate($0) }
            defer { model.listingAnswerGate = nil }

            // The refresh begins under the OLD question (edited), and its
            // answer is held at the seam.
            let refresh = Task { await model.refresh() }
            var spins = 0
            while !hold.isHolding, spins < 400 {
                spins += 1
                await Task.yield()
                try await Task.sleep(for: .milliseconds(5))
            }
            try #require(hold.isHolding, "premise: the refresh's answer is held")

            // The NEWER question lands while the refresh's answer is held.
            model.setSort(.title)
            await model.search()
            let newer = model.noteHits.map(\.title)
            #expect(newer == titleOrder(newer), "premise: the newer question (title) landed")

            // Released: the older answer resolves after the newer landed.
            hold.release()
            await refresh.value
            #expect(model.noteHits.map(\.title) == newer,
                    "the older (edited) answer never paints over the newer question's")
            #expect(model.listedGeneration == model.searchGeneration,
                    "the listed answer is the newest read's")
        }
    }

    /// **B — the ticket's recorded edge: a refresh begun AFTER a newer
    /// question began overtakes it.** The answer it lands is the newer
    /// question's (it read the current state) — and it must land as that
    /// question's FIRST page, starting over, never in place at the old
    /// listing's depth with the old listing's on-screen positions. RED on the
    /// pre-fix tree: 160 rows of the new question, the old positions 150…159
    /// still counted on screen, and the new question's FIRST row asking for
    /// the next page.
    @Test func aRefreshThatOvertakesANewerQuestionLandsItAsAFirstPage() async throws {
        try await withNotes(page * 2 + 10) { _, model in
            await model.search()
            await model.appearForVX408(model.noteHits[page - 3].id)
            #expect(model.noteHits.count == page * 2, "premise: she scrolled to the second page")
            // She is looking at rows 150…159 of the old listing.
            for position in (page * 2 - 10)..<(page * 2) {
                model.noteRowAppeared(model.noteHits[position].id, spawning: false)
            }
            for position in 0..<(page * 2 - 10) {
                model.noteRowDisappeared(model.noteHits[position].id, spawning: false)
            }
            #expect(model.visibleNoteIndices == Set((page * 2 - 10)..<(page * 2)), "premise: deep on screen")

            // A NEW question begins (a sort pick)…
            let generation = model.searchGeneration
            model.setSort(.title)
            let search = Task { await model.search() }
            await Task.yield()
            #expect(model.searchGeneration == generation + 1, "premise: the new question is in flight")
            // …and, before it lands, an in-place refresh begins (the listing
            // follow's road — a mint from another door).
            let refresh = Task { await model.refresh() }
            await Task.yield()
            #expect(model.searchGeneration == generation + 2, "premise: the refresh overtook it")
            await search.value
            await refresh.value

            #expect(model.listedGeneration == model.searchGeneration)
            let titles = model.noteHits.map(\.title)
            #expect(titles == titleOrder(titles), "the answer is the new question's (title order)")
            #expect(model.noteHits.count == page,
                    "a new question is a FIRST page, even when a refresh carried it (\(model.noteHits.count) rows)")
            #expect(model.visibleNoteIndices.isEmpty,
                    "the old listing's on-screen positions do not survive into the new one (\(model.visibleNoteIndices.sorted()))")
            #expect(!model.noteRowAppeared(model.noteHits[0].id, spawning: false),
                    "the new question's first row asks for no next page")
        }
    }
}

extension LibraryCatalogModel {
    /// The pins' synchronous "a row came on screen" (this suite's copy of
    /// `LibraryPagingModelTests`' helper): the appearance, the page read if
    /// it asked, then the near extras.
    fileprivate func appearForVX408(_ id: String) async {
        if noteRowAppeared(id, spawning: false) { await loadMoreNotes() }
        await loadNearExtras(generation: searchGeneration, replacing: false)
    }
}
