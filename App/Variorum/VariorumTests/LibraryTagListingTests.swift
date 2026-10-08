//
//  LibraryTagListingTests.swift
//  VariorumTests
//
//  VX-84 (the 13o follow-up run, VX-83) — her report: *"classics are not
//  showing notes tagged classics, in fact searching a tag is not revealing the
//  notes tagged that at all."* The trace (§M1(a) of
//  `notes/plans/fixes/vx-83-search-followup.md`): a `#tag` typed without words
//  answered with its ASSOCIATED BOOKS only (P-13o-U2-6 as narrowed at U3) —
//  the composer serves no text-less question (P-13o-U1-7), so the tagged notes
//  were never read.
//
//  The provisional call D-1: a tag alone NARROWS THE LIBRARY like a day does —
//  the catalog's own listing (paged, the sort door live, the scope picker
//  live), narrowed by the tag through the ONE composer; the Books section
//  (the association join) unchanged above; with words, everything reads
//  exactly as shipped.
//
//  Red on the pre-fix tree: a tag alone listed no notes.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-84 — a tag alone lists the notes it tags", .serialized)
struct LibraryTagListingTests {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 84))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "vx84-listing-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    /// Her shelf: #classics on two notes, its child #classics/doyle on a
    /// third (the SUBTREE), #other on a fourth, a fifth untagged.
    private struct Classics {
        let hound: Container, study: Container, sign: Container, other: Container, plain: Container
        let classics: VariorumCore.Tag
    }

    private func classics(_ ops: Operations) throws -> Classics {
        let classics = try ops.createTag(name: "classics")
        let doyle = try ops.createTag(parent: classics.id, name: "doyle")
        let otherTag = try ops.createTag(name: "other")
        func note(_ title: String, _ tag: VariorumCore.Tag?) throws -> Container {
            let post = try ops.createPost(title: title)
            _ = try ops.newBlock(in: post.id, text: "\(title) — the words of it")
            if let tag { _ = try ops.applyTag(tag.id, toPost: post.id) }
            return post
        }
        return Classics(
            hound: try note("The Hound", classics), study: try note("A Study in Scarlet", classics),
            sign: try note("The Sign of Four", doyle), other: try note("Elsewhere", otherTag),
            plain: try note("Untagged", nil), classics: classics)
    }

    @Test func aTagAloneListsTheNotesItTagsSubtreeIncluded() async throws {
        try await withLibrary { session, model in
            let s = try classics(session.operations)
            model.query = "#classics"
            await model.search()
            #expect(Set(model.noteHits.map(\.id)) == [s.hound.id, s.study.id, s.sign.id],
                    "post-level applications, the subtree included — never #other, never the untagged")
            #expect(!model.isSearching, "no words: the Library's own listing, never the ranked sheet")
            #expect(model.searchState.asksAnything, "the band still says the question")
        }
    }

    @Test func theTagAloneListingFollowsTheSortDoor() async throws {
        try await withLibrary { session, model in
            let s = try classics(session.operations)
            model.setSort(.title)
            model.query = "#classics"
            await model.search()
            #expect(model.noteHits.map(\.id) == [s.study.id, s.hound.id, s.sign.id],
                    "the sort ▾ stays live (a–z) — nothing was ranked, so nothing is fabricated")
            model.setDirection(.desc)
            await model.search()
            #expect(model.noteHits.map(\.id) == [s.sign.id, s.hound.id, s.study.id])
        }
    }

    /// Control (green on both trees): with words beside the tag, the answer
    /// sheet reads exactly as shipped — the tag a filter of the ranked groups.
    @Test func withWordsTheTagFiltersTheAnswerSheetAsShipped() async throws {
        try await withLibrary { session, model in
            let s = try classics(session.operations)
            model.query = "#classics hound "
            await model.search()
            #expect(model.isSearching, "words: the answer sheet")
            #expect(model.searchState.groups.map(\.homeID) == [s.hound.id])
            #expect(model.noteHits.map(\.id) == [s.hound.id], "the heads mirror the groups")
        }
    }
}
