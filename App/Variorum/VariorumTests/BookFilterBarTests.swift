//
//  BookFilterBarTests.swift
//  VariorumTests
//
//  13i-d U3 — THE IN-BOOK FILTER BAR's FACE (the sitting record §18.1, her
//  original sitting ask) over the 13i-b mechanics. What is pinned:
//  - the bar's draft maps onto the gathering grammar exactly (with / without,
//    all / any, ★) — so "save" mints what she was looking through;
//  - the book's model holds the NARROWED assembly through `viewFilter` and
//    writes NOTHING (membership and outbox unchanged); clearing restores the
//    whole book;
//  - the save door SAYS what the gathering will gather from before it mints
//    (a hand-made book: "every note in this library"), mints association ∧
//    filter, speaks its receipt, and refuses a taken name minting nothing.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withFilterWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(within seconds: Double = 3, _ condition: () -> Bool) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(condition(), "condition never settled")
}

@MainActor
@Suite("The in-book filter bar (13i-d U3)", .serialized)
struct BookFilterBarTests {
    // MARK: - The draft → the grammar

    @Test func theDraftMapsOntoTheGatheringGrammar() {
        var draft = BookFilterDraft()
        #expect(draft.rule == nil, "empty ⇒ no filter: the book as it is")
        draft.add(.tag("a"))
        #expect(draft.rule == .tag("a"))
        draft.add(.tag("a"))
        #expect(draft.terms.count == 1, "a target joins once")
        draft.flip(.tag("a"))
        #expect(draft.rule == .not(.tag("a")), "without")
        draft.add(.star)
        #expect(draft.rule == .and([.not(.tag("a")), .star]), "two ⇒ all of them by default")
        draft.match = .any
        #expect(draft.rule == .or([.not(.tag("a")), .star]))
        draft.remove(.tag("a"))
        #expect(draft.rule == .star)
        draft.remove(.star)
        #expect(draft.isEmpty && draft.rule == nil)
        #expect(BookFilterBar.surfaceCapabilities == [.saveFilterAsGathering])
        #expect(CapabilityRegistry.capability(.saveFilterAsGathering).doors == [.surface])
    }

    // MARK: - The view-local read (never membership)

    /// The book's model holds the NARROWED assembly while the filter stands
    /// — and writes nothing; clearing it brings the whole book back.
    @Test func theFilterNarrowsTheHeldAssemblyAndWritesNothing() async throws {
        try await withFilterWorld { session, db in
            let ops = session.operations
            let draftTag = try ops.createTag(name: "draft")
            let book = try ops.createReading(name: "Book", kind: .book)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            let c = try ops.createPost(title: "c")
            for note in [a, b, c] { try ops.addPostToReading(note.id, to: book.id) }
            _ = try ops.applyTag(draftTag.id, toPost: b.id)
            let counts: () async throws -> (members: Int, outbox: Int) = {
                try await db.read { db in
                    (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE deleted_at IS NULL") ?? -1,
                     try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1)
                }
            }
            let before = try await counts()

            let model = BookViewModel(session: session, readingID: book.id)
            var draft = BookFilterDraft()
            draft.add(.tag(draftTag.id))
            model.viewFilter = draft.rule
            var task = Task { await model.start() }
            try await settle { model.entries.map(\.postID) == [b.id] }
            #expect(model.entries.map(\.postID) == [b.id], "only the tagged note shows")
            draft.flip(.tag(draftTag.id))
            model.viewFilter = draft.rule
            task.cancel()
            task = Task { await model.start() }
            try await settle { model.entries.map(\.postID) == [a.id, c.id] }
            #expect(model.entries.map(\.postID) == [a.id, c.id], "without #draft, in the book's order")
            model.viewFilter = nil
            task.cancel()
            task = Task { await model.start() }
            try await settle { model.entries.count == 3 }
            #expect(model.entries.map(\.postID) == [a.id, b.id, c.id], "cleared — the whole book")
            task.cancel()
            let after = try await counts()
            #expect(after.members == before.members, "no note left the book")
            #expect(after.outbox == before.outbox, "nothing written")
        }
    }

    // MARK: - Save this filter as a gathering

    @Test func theSaveDoorSaysWhatItGathersMintsAndRefusesATakenName() async throws {
        try await withFilterWorld { session, db in
            let ops = session.operations
            let draftTag = try ops.createTag(name: "draft")
            let essay = try ops.createTag(name: "essay")
            let plain = try ops.createReading(name: "Plain", kind: .book)
            let living = try ops.createReading(
                name: "Living", kind: .book, querySpec: try RuleGrammar.encode(.tag(essay.id)))
            let paths = [draftTag.id: "draft", essay.id: "essay"]
            let filter = RuleTerm.tag(draftTag.id)

            let plainOffer = try #require(await BookFilterDoor.offer(
                session: session, reading: plain, filter: filter, paths: paths))
            #expect(plainOffer.message.contains("every note in this library that matches #draft"),
                    "a hand-made book: the face says the gathering reaches the whole library")
            #expect(plainOffer.suggestedName == "Plain \u{00B7} #draft")
            let livingOffer = try #require(await BookFilterDoor.offer(
                session: session, reading: living, filter: filter, paths: paths))
            #expect(livingOffer.message.contains("(#essay)"), "\(livingOffer.message)")
            #expect(livingOffer.message.contains("#draft"))

            let mintedID = try #require(await BookFilterDoor.save(
                session: session, readingID: living.id, filter: filter, name: "Essay drafts"))
            let minted = try #require(try await db.read { try Queries.reading($0, id: mintedID) })
            #expect(minted.kind == .gathering)
            #expect(minted.querySpec
                    == (try RuleGrammar.encode(RuleGrammar.conjoin(.tag(essay.id), filter))),
                    "association ∧ filter — exactly what she was looking through")
            #expect(session.status.spoken?.text == BookFilterCopy.saved("Essay drafts"))

            // A taken name refuses at the door and mints nothing.
            let readings = try await db.read { try Queries.readings($0).count }
            #expect(await BookFilterDoor.save(
                session: session, readingID: plain.id, filter: filter, name: "Essay drafts") == nil)
            #expect(try await db.read { try Queries.readings($0).count } == readings)
            #expect(session.status.spoken?.text.contains("Essay drafts") == true,
                    "the refusal names the taken name: \(session.status.spoken?.text ?? "")")
        }
    }

    /// The walk's W-3 (capture `u3/tl-09`): under a filter the Index's
    /// footer said "2 notes" and the sidebar box "1 of 2 in this book" — the
    /// filtered few read as the book. Now: "shown", and no position at all.
    @Test func aFilteredIndexNeverClaimsTheBooksCount() {
        #expect(BookIndexColumn.footerWords(chapters: 9, notes: 34, filtered: false)
                == "9 chapters \u{00B7} 34 notes", "unfiltered: unchanged")
        #expect(BookIndexColumn.footerWords(chapters: 9, notes: 2, filtered: true)
                == "9 chapters \u{00B7} 2 shown")
        #expect(BookIndexColumn.footerWords(chapters: 0, notes: 2, filtered: true) == "2 shown")
        #expect(BookIndexColumn.footerWords(chapters: 0, notes: 5, filtered: false) == "5 notes")
        #expect(BookNoteBox.position(3, filtered: false) == 3)
        #expect(BookNoteBox.position(3, filtered: true) == 0,
                "unknown ⇒ the box omits the position line")
    }

    @Test func theAssociationSentencesSayTheTruthPerKind() {
        let rule = BookFilterCopy.association(.rule, associationWords: "#essay", filterWords: "#draft")
        #expect(rule.contains("this book gathers (#essay)") && rule.contains("#draft"))
        let outflow = BookFilterCopy.association(
            .autoTag, associationWords: "#essay", filterWords: "#draft")
        #expect(outflow.contains("tagged #essay"))
        let none = BookFilterCopy.association(.none, associationWords: nil, filterWords: "#draft")
        #expect(none.contains("not only this book's"))
        for sentence in [rule, outflow, none] {
            #expect(sentence.hasSuffix("No note moves."), "a filter never mutates membership")
        }
    }
}
