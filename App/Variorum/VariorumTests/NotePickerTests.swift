//
//  NotePickerTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2b, item 14 — the ONE searchable note-picker's
//  brains: the pure ranking rule, and the shipped sources over a real
//  ops-seeded store. The capability-survival pins ride here too: the
//  retired corpus submenus' ACTS (mark/unmark versions, add to book) are
//  untouched — what retired is chrome, and these pins hold the sources to
//  the same reachable population the old menus offered (minus the
//  unlinked-unmark picks, which were only ever refusals).
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
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 29))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - The pure ranking rule

@Suite("Note picker — the ranking rule (item 14)")
@MainActor
struct NotePickerRankingTests {
    private func row(_ id: String) -> NotePickerRow {
        NotePickerRow(id: id, title: id)
    }

    @Test func priorityRowsFloatStablyAndTheRestKeepTheirOrder() {
        let ranked = NotePickerRanking.rank(
            [row("a"), row("b"), row("c"), row("d")], priorityIDs: ["c", "b"])
        // Stable inside both partitions: b before c (the feed's order),
        // a before d untouched behind them.
        #expect(ranked.map(\.id) == ["b", "c", "a", "d"])
    }

    @Test func anEmptyPrioritySetIsTheIdentity() {
        let rows = [row("a"), row("b")]
        #expect(NotePickerRanking.rank(rows, priorityIDs: []) == rows)
    }

    @Test func theDayDetailIsSuppressedWhenTheTitleAlreadyIsTheDay() {
        // A nameless note DISPLAYS its day — repeating it as context says
        // nothing twice.
        #expect(NotePickerRanking.detail(title: "2026-08-01", day: "2026-08-01") == nil)
        #expect(NotePickerRanking.detail(title: "drafts", day: "2026-08-01") == "2026-08-01")
        #expect(NotePickerRanking.detail(title: "drafts", day: nil) == nil)
    }
}

// MARK: - The sources over a real store

@Suite("Note picker — the shipped sources (item 14)")
@MainActor
struct NotePickerSourceTests {
    @Test func theVersionsContextRanksPeersFirstAnnotatedAndExcludesTheSubject() async throws {
        try await withWorld { session, _ in
            let (subject, peer, recent) = try await session.runner.run {
                ops -> (String, String, String) in
                let subject = try ops.createPost(title: "the essay")
                _ = try ops.newBlock(in: subject.id, text: "subject body")
                let peer = try ops.createPost(title: "the essay, take two")
                _ = try ops.newBlock(in: peer.id, text: "peer body")
                _ = try ops.markPostsAsVersions(subject.id, peer.id)
                // A more recently touched non-peer — recency would put it
                // first; the versions context must not.
                let recent = try ops.createPost(title: "unrelated late note")
                _ = try ops.newBlock(in: recent.id, text: "late body")
                return (subject.id, peer.id, recent.id)
            }
            let source = NotePickerSource.corpusNotes(
                session: session, excluding: subject,
                versionPeersOf: subject, peerAnnotation: "already versions")
            let rows = await source.search("")
            // The peer leads despite being older; the subject never lists.
            #expect(rows.first?.id == peer)
            #expect(rows.first?.annotation == "already versions")
            #expect(!rows.contains { $0.id == subject })
            #expect(rows.contains { $0.id == recent })
            // Row context: the snippet is the note's opening words.
            #expect(rows.first?.snippet == "peer body")
        }
    }

    @Test func theUnmarkSourceOffersExactlyTheLinkedPeers() async throws {
        try await withWorld { session, _ in
            let subject = try await session.runner.run { ops -> String in
                let subject = try ops.createPost(title: "anchor")
                _ = try ops.newBlock(in: subject.id, text: "anchor body")
                let peer = try ops.createPost(title: "its version")
                _ = try ops.newBlock(in: peer.id, text: "version body")
                _ = try ops.markPostsAsVersions(subject.id, peer.id)
                let stranger = try ops.createPost(title: "stranger")
                _ = try ops.newBlock(in: stranger.id, text: "stranger body")
                return subject.id
            }
            let source = NotePickerSource.versionPeers(session: session, of: subject)
            let rows = await source.search("")
            // ONLY the peer — an unlinked pick is unreachable by
            // construction (R60/R68's corner closed structurally).
            #expect(rows.map(\.title) == ["its version"])
            // And the search filter narrows within the peers.
            let none = await source.search("stranger")
            #expect(none.isEmpty)
        }
    }

    @Test func theBookSourceOffersTheCuratedShelfSearchedWithFinishedMarked() async {
        let day = Date(timeIntervalSince1970: 1_782_864_000)
        let books = [
            Reading(id: "a", name: "field notes", kind: .book, createdAt: day, updatedAt: day),
            Reading(id: "b", name: "the smart one", kind: .gathering, createdAt: day, updatedAt: day),
            Reading(
                id: "c", name: "finished notebook", kind: .book, locked: true,
                createdAt: day, updatedAt: day),
        ]
        let source = NotePickerSource.curatedBooks(books)
        let all = await source.search("")
        // Curated only — the standing door's own population; the smart book
        // was never hand-addable and still isn't offered.
        #expect(all.map(\.id) == ["a", "c"])
        // The finished book stays OFFERED (the old dropdown offered it too;
        // the standing gate speaks on pick) — with the honest mark.
        #expect(all.first { $0.id == "c" }?.annotation == "finished")
        let searched = await source.search("field")
        #expect(searched.map(\.id) == ["a"])
    }
}
