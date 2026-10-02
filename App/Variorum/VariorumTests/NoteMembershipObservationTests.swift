//
//  NoteMembershipObservationTests.swift
//  VariorumTests
//
//  13i-d U2 — KnownIssues row 104 (13i-b U3's F-U3-2): the note-side
//  membership read loaded ONCE, so an intake SEAT while the note was open
//  read "in no book" until it was reopened. The membership is one shared,
//  OBSERVED read now (`NoteMembershipModel`) — the chip and the Book Panel's
//  door both consume it.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Row 104 — the note's membership is observed (13i-d U2)", .serialized)
struct NoteMembershipObservationTests {
    /// **RED ON OLD** (the one-shot read): the note is open, a TAGGING ACT
    /// seats it in a living book (intake — the event 13i-b made able to
    /// change membership under an open note), and the membership in hand
    /// follows without a reopen.
    @Test func anIntakeSeatWhileTheNoteIsOpenShowsWithoutAReopen() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let work = try ops.createTag(name: "work")
            let living = try ops.createReading(
                name: "Living", kind: .book, querySpec: try RuleGrammar.encode(.tag(work.id)))
            let note = try ops.createPost(title: "the open note")

            let model = NoteMembershipModel()
            let task = Task { await model.track(session: session, postID: note.id) }
            defer { task.cancel() }
            try await settle { model.subject == note.id }
            #expect(model.books(for: note.id).isEmpty, "in no book yet")

            // The intake seat — while the note is open.
            _ = try ops.applyTag(work.id, toPost: note.id)
            try await settle { model.books(for: note.id).map(\.id) == [living.id] }
            #expect(model.books(for: note.id).map(\.id) == [living.id],
                    "the seat shows while the note is open")
        }
    }

    /// The subject guard: another note's readings never answer for this one.
    @Test func anotherNotesMembershipNeverAnswersForThisOne() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let book = try ops.createReading(name: "Book", kind: .book)
            let member = try ops.createPost(title: "member")
            let other = try ops.createPost(title: "other")
            try ops.addPostToReading(member.id, to: book.id)

            let model = NoteMembershipModel()
            let task = Task { await model.track(session: session, postID: member.id) }
            defer { task.cancel() }
            try await settle { !model.books(for: member.id).isEmpty }
            #expect(model.books(for: other.id).isEmpty)
            #expect(model.readings(for: other.id).isEmpty)
        }
    }
}

/// Poll until a condition holds (never a sync RunLoop pump — the standing
/// harness rule for settle hops through an observation).
@MainActor
private func settle(
    within seconds: Double = 3, _ condition: () async throws -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if try await condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(try await condition(), "condition never settled")
}
