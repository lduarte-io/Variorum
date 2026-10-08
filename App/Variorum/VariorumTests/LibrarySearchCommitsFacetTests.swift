//
//  LibrarySearchCommitsFacetTests.swift
//  VariorumTests
//
//  VX-72 (the 13o follow-up run, VX-83 — U-C) — her split ruling R-VX83-5:
//  *"do the savepoints that's easy now - and it's the most important product
//  story (anything you've saved)"*; the facet's word hers, R-VX83-9: *"hmm. i
//  take it back - do + commits"*. The Library's answer sheet grows ONE facet
//  beside `+ archived`: `+ commits` brings savepoint history into the answer.
//
//  What these pin (the core composer's half — the fence, the road, liveness by
//  key — is `SearchSavepointFacetTests`): the Library's question carries the
//  facet and never remembers it; the band offers the chip only when the
//  question has WORDS; off the facet the Library lists no savepoint, on it the
//  saved words list under their note with the band saying "N commits" (R-VX83-10); a
//  savepoint line says its day (P-VX83-C6); a savepoint lands STEPPING only in
//  the take the note shows (P-VX83-C4).
//
//  Red on the pre-VX-72 tree by construction: no facet, no `.savepoint` kind.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-72 — the + commits facet (search what you saved)", .serialized)
struct LibrarySearchCommitsFacetTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 72))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "vx72-commits-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// Every passage line the sheet lists.
    private func lines(_ model: LibraryCatalogModel) -> [SearchPassage] {
        model.searchState.groups.flatMap(\.lines)
    }

    // MARK: - The facet in the Library

    /// A note whose take MOVED ON: "lanterns" lives only in what she saved.
    /// Off the facet the Library's answer never shows it (no group, no line,
    /// no count); `+ commits` brings it — under its note, the band saying
    /// "1 savepoint"; clearing the field puts the facet back.
    @Test func theCommitsFacetBringsTheSavedWordsAndNothingElseDoes() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let post = try ops.createPost(title: "Harbor Log")
            let minted = try ops.newBlock(in: post.id, text: "lanterns along the quay")
            let saved = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "the take moved on entirely", charDelta: 20)

            model.query = "lanterns"
            await model.search()
            #expect(model.isSearching, "words: the answer sheet")
            #expect(!model.searchState.includesSavepoints, "the facet starts off")
            #expect(model.searchState.groups.isEmpty, "never without the facet — no group")
            #expect(model.searchState.counts.map { $0.living.savepoints == 0 && $0.living.notes == 0 } ?? true)

            model.toggleSavepointsFacet()
            await model.search()
            #expect(model.searchState.includesSavepoints)
            #expect(model.searchState.groups.map(\.homeID) == [post.id], "the saved words' note")
            let line = try #require(lines(model).first)
            #expect(line.kind == .savepoint && line.sourceID == saved.id && line.blockID == minted.block.id)
            #expect(line.savedAt != nil, "its day rides the row")
            let counts = try #require(model.searchState.counts?.kinds(model.searchState.visibility))
            #expect(LibrarySearchCopy.counts(counts) == "1 note \u{00B7} 1 commit")

            model.query = ""
            await model.search()
            #expect(!model.searchState.includesSavepoints, "a cleared field puts the facet back — never remembered")
        }
    }

    /// The question carries the facet (the one AST's flag); the band offers
    /// the chip only for WORDS — a tag alone, a day alone and no question at
    /// all give it nothing to add (P-2).
    @Test func theChipIsOfferedOnlyWhenTheQuestionHasWords() {
        let off = LibrarySearchQuestion.read("lanterns")
        let on = LibrarySearchQuestion.read("lanterns", savepoints: true)
        #expect(off?.query.includesSavepoints == false && on?.query.includesSavepoints == true)
        #expect(LibrarySearchBand.offersCommits(off))
        #expect(LibrarySearchBand.offersCommits(LibrarySearchQuestion.read("lanterns #harbor")))
        #expect(!LibrarySearchBand.offersCommits(LibrarySearchQuestion.read("#harbor")), "a tag alone lists without the index")
        #expect(!LibrarySearchBand.offersCommits(nil))
        // Her word (R-VX83-9), the archived chip's grammar.
        #expect(LibrarySearchCopy.commitsOff == "+ commits" && LibrarySearchCopy.commitsOn == "commits")
    }

    // MARK: - The line and the landing

    /// A savepoint line says "commit · Oct 6" (R-VX83-10 — her word: within
    /// search the rows wear the chip's word; JUSTIFIED EDIT from the C6
    /// "savepoint" cells) — the day in the one stamp-wording brain's words,
    /// the year when it is not this one; the other kinds read as shipped.
    @Test func aSavepointLineSaysItsDay() {
        let locale = Locale(identifier: "en_US")
        let now = ISO8601DateFormatter().date(from: "2026-10-08T12:00:00Z")!
        #expect(LibrarySearchFace.kindLabel(
            kind: .savepoint, savedAt: "2026-10-06T15:30:00.000Z", now: now, calendar: utc, locale: locale)
            == "commit \u{00B7} Oct 6")
        #expect(LibrarySearchFace.kindLabel(
            kind: .savepoint, savedAt: "2025-03-02T15:30:00.000Z", now: now, calendar: utc, locale: locale)
            == "commit \u{00B7} Mar 2, 2025")
        #expect(LibrarySearchFace.kindLabel(kind: .savepoint, savedAt: nil, now: now) == "commit",
                "no day read — the kind alone")
        #expect(LibrarySearchFace.kindLabel(kind: .take, savedAt: nil, now: now) == nil, "prose says nothing")
        #expect(LibrarySearchFace.kindLabel(kind: .comment, savedAt: nil, now: now) == "comment")
        #expect(!LibrarySearchFace.isInAnotherTake(kind: .savepoint, rendered: false),
                "a savepoint's line says its day, not \"in another take\"")
    }

    /// P-VX83-C4: a savepoint STEPS only when its take is the one the note
    /// shows (there the editor's own road still arms when the words are gone
    /// from the buffer); a savepoint of an unrendered take arms. End to end:
    /// the facet's rows say which is which.
    @Test func aSavepointLandsSteppingOnlyInTheTakeTheNoteShows() async throws {
        let marked = SearchComposer.snippetSegments("…the \u{2}tide\u{3} \u{2}turns\u{3} at noon…")
        #expect(SearchLanding.findSeed(kind: .savepoint, rendered: true, snippet: marked)
                == EditorFindSeed(needle: "tide turns", steps: true))
        #expect(SearchLanding.findSeed(kind: .savepoint, rendered: false, snippet: marked)
                == EditorFindSeed(needle: "tide turns", steps: false))

        try await withLibrary { session, model in
            let ops = session.operations
            let post = try ops.createPost(title: "Tides")
            let minted = try ops.newBlock(in: post.id, text: "the tide turns at noon")
            let shown = try ops.commit(minted.variant.id)
            let branch = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let unshown = try ops.commit(branch.id)
            model.query = "tide"
            model.toggleSavepointsFacet()
            await model.search()
            let open = model.searchState.groups.first.map(\.homeID)
            #expect(open == post.id)
            await model.searchState.toggleExpansion(post.id)
            let all = model.searchState.expansions[post.id]?.lines ?? []
            let byID = Dictionary(uniqueKeysWithValues: all.map { ($0.sourceID, $0) })
            #expect(byID[shown.id].map { $0.kind == .savepoint && $0.isRenderedTake } == true)
            #expect(byID[unshown.id].map { $0.kind == .savepoint && !$0.isRenderedTake } == true)
            #expect(all.firstIndex { $0.kind == .savepoint }! > all.lastIndex { $0.kind == .take }!,
                    "the living takes lead, their savepoints follow (P-VX83-C2)")
        }
    }
}
