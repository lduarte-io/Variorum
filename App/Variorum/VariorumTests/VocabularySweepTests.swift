//
//  VocabularySweepTests.swift
//  VariorumTests
//
//  13i-d U6 — THE VOCABULARY SWEEP's word-table pins (the plan's item 5 +
//  item 10, the riders routed to U6). Each test names its lettered piece in
//  the U6 RECORD. The dead SPELLINGS are banned by `DeadVocabularyTests`
//  (the grep pins); this file pins the words that replaced them, where a
//  sentence carries a fact (a count, a road, a state).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withSweepWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13i-d U6 — the vocabulary sweep's word tables", .serialized)
struct VocabularySweepTests {
    // MARK: - (g) F-U3-4 — the chip counts books and gatherings apart

    /// TRACED FIRST: `readingsContaining`'s membership arm reads BOOK rows
    /// only (13i-c's contract holds — no reader counted a gathering's row);
    /// the gatherings it appends SHOW the note. The lie was the word: the
    /// chip said "in 2 books" for one book and one gathering. Red on the old
    /// label by construction (its only words were "in N books").
    @Test func theChipCountsBooksAndGatheringsApart() {
        let path: (String) -> String = { "in \($0)" }
        #expect(MembershipChip.label(bookNames: [], gatheringCount: 0, singleBook: path)
                == "in no book")
        #expect(MembershipChip.label(bookNames: ["Orbit"], gatheringCount: 0, singleBook: path)
                == "in Orbit")
        #expect(MembershipChip.label(bookNames: ["Orbit"], gatheringCount: 1, singleBook: path)
                == "in Orbit \u{00B7} 1 gathering",
                "F-U3-4's walk case: ONE book and ONE gathering never reads \"in 2 books\"")
        #expect(MembershipChip.label(bookNames: [], gatheringCount: 2, singleBook: path)
                == "in no book \u{00B7} 2 gatherings")
        #expect(MembershipChip.label(bookNames: ["A", "B"], gatheringCount: 0, singleBook: path)
                == "in 2 books")
        #expect(MembershipChip.label(bookNames: ["A", "B"], gatheringCount: 1, singleBook: path)
                == "in 2 books \u{00B7} 1 gathering")

        #expect(MembershipChip.headline(bookCount: 0, gatheringCount: 0)
                == "This note is in no book \u{2014} it lives in the Pool.")
        #expect(MembershipChip.headline(bookCount: 1, gatheringCount: 1)
                == "This note is in 1 book and appears in 1 gathering:")
        #expect(MembershipChip.headline(bookCount: 2, gatheringCount: 0)
                == "This note is in 2 books:")
        #expect(MembershipChip.headline(bookCount: 0, gatheringCount: 3)
                == "This note is in no book \u{2014} it lives in the Pool \u{2014} and appears in "
                    + "3 gatherings:",
                "a gathering-only note is still a Pool note (§8) — it just shows elsewhere")
    }

    // MARK: - (f) item 10 — the dismiss receipt teaches the road back

    @Test func theDismissReceiptSaysHowToChangeYourMind() {
        #expect(ArrivalsCopy.dismissed("Ode")
                == "Dismissed \u{201C}Ode\u{201D} \u{2014} it won\u{2019}t come back on its own; "
                    + "add it by hand any time.")
    }

    // MARK: - (d) KnownIssues row 106 — a SEALED book's road is Unseal

    @Test func theArrivalsRefusalNamesUnsealOnASealedBook() {
        let locked = OperationError.lockedReading(id: "r")
        let sealed = ArrivalsCopy.refusal(for: locked, book: "Odes", cap: nil, sealed: true)
        #expect(sealed.contains("sealed") && sealed.contains("Unseal"))
        #expect(!sealed.contains("Reopen"), "Reopen refuses on a sealed book (R-13ic-3)")
        let finished = ArrivalsCopy.refusal(for: locked, book: "Odes", cap: nil)
        #expect(finished.contains("finished") && finished.contains("Reopen"))
    }

    /// The generic arms hold no book, so each names BOTH true roads — never
    /// the dead "locked — unlock" nor a bare "reopen" a sealed book refuses.
    @Test func theBooklessArmsNameBothRoads() {
        let locked = OperationError.lockedReading(id: "r")
        for words in [
            ReadingsViewModel.message(locked),
            DeletionRefusal.words(locked),
            SeededBookRestore.failureLine(for: locked),
        ] {
            #expect(words.contains("reopen"), "\(words)")
            #expect(words.contains("unseal"), "\(words)")
            #expect(!words.contains("unlock"), "\(words)")
        }
    }

    /// The choice sheet's TARGET sealed while the sheet stood open: the
    /// refusal reads the book FRESH and names Unseal. Red on the old arm
    /// ("“Mine” is finished — reopen it (its settings) to add to it.").
    @Test func aTargetSealedUnderTheSheetNamesUnseal() async throws {
        try await withSweepWorld { session, _ in
            let ops = session.operations
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let other = try ops.createReading(name: "Other", kind: .book)
            let shared = try ops.createPost(title: "shared")
            _ = try ops.addPostToReading(shared.id, to: other.id)
            let doors = MembershipDoors(session: session)
            _ = try await doors.addOrOffer(shared.id, to: mine.id)
            let item = try #require(doors.pending)
            try ops.sealReading(mine.id)

            #expect(await doors.copyIn(item) == nil)
            let refusal = try #require(session.status.current?.text)
            #expect(refusal.contains("sealed") && refusal.contains("unseal"), "\(refusal)")
            #expect(!refusal.contains("reopen it (its settings)"))
        }
    }

    /// The Bookcase holds the row, so a drop or a bind refused by a SEALED
    /// book speaks that book's own road (the generic arm said "locked —
    /// unlock it first").
    @Test func theBookcaseSpeaksASealedBooksOwnRoad() async throws {
        try await withSweepWorld { session, _ in
            let ops = session.operations
            let book = try ops.createReading(name: "Odes", kind: .book)
            try ops.sealReading(book.id)
            let model = ShelfViewModel(session: session)
            let task = Task { await model.start() }
            defer { task.cancel() }
            for _ in 0..<60 where !model.books.contains(where: { $0.reading.id == book.id }) {
                try await Task.sleep(for: .milliseconds(20))
            }
            let words = model.bookRefusal(.lockedReading(id: book.id), readingID: book.id)
            #expect(words.contains("\u{201C}Odes\u{201D} is sealed") && words.contains("unseal"),
                    "\(words)")
        }
    }
}
