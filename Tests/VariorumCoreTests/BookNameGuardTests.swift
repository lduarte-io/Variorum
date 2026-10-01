import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13e, batch 1 — E13's core half: the duplicate-book-name DOOR guard
// (her kickoff-sitting round-3 ruling, REFUSE at the door) and the pure
// naming rule under it. The Mac doors that consult it are pinned in
// `VariorumTests/DoorSetTests.swift`.

@Suite("E13 — the book-name rule (13e)")
struct BookNamingRuleTests {
    @Test func theKeyTrimsEndsAndFoldsCase() {
        #expect(BookNaming.key("  Ideas ") == "ideas")
        #expect(BookNaming.key("IDEAS") == "ideas")
        #expect(BookNaming.sameName("Ideas", "ideas"))
        #expect(BookNaming.sameName("Ideas", " IDEAS\n"))
    }

    /// The two folds it deliberately does NOT do — her ruling said
    /// case-insensitive, and every wider fold refuses a name she is entitled
    /// to use. Stated as pins so a later "improvement" has to argue with her
    /// ruling rather than with nothing.
    @Test func internalSpacingAndDiacriticsAreNotFolded() {
        #expect(!BookNaming.sameName("my  book", "my book"))
        #expect(!BookNaming.sameName("\u{00c9}lan", "Elan"))
    }
}

@Suite("E13 — assertBookNameIsFree (13e)")
struct BookNameGuardTests {
    @Test func aLiveBookMakesItsNameUnavailableCaseInsensitively() throws {
        try withOperations { ops, _ in
            _ = try ops.createReading(name: "Ideas", kind: .book)

            // The refusal carries the EXISTING book's stored casing, so the
            // door can name back the book she already has.
            #expect(throws: OperationError.duplicateBookName(name: "Ideas")) {
                try ops.assertBookNameIsFree("ideas")
            }
            #expect(throws: OperationError.duplicateBookName(name: "Ideas")) {
                try ops.assertBookNameIsFree("  IDEAS  ")
            }
            // A different name is free — including one that only shares a
            // prefix (this is name equality, never a fuzzy match).
            try ops.assertBookNameIsFree("Ideas 2")
        }
    }

    /// It does not care what KIND the sitting book is: a curated "Ideas" and
    /// a smart "Ideas" are exactly the pair 13k K4 surfaced (#53(l)).
    @Test func theKindOfTheSittingBookIsIrrelevant() throws {
        try withOperations { ops, _ in
            _ = try ops.createReading(name: "Ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            #expect(throws: OperationError.duplicateBookName(name: "Ideas")) {
                try ops.assertBookNameIsFree("Ideas")
            }
        }
    }

    /// The RENAME door's own row never collides with itself — including a
    /// pure casing change, which is a rename she is entitled to make.
    @Test func theExcludedRowNeverCollidesWithItself() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "Ideas", kind: .book)
            try ops.assertBookNameIsFree("Ideas", excluding: book.id)
            try ops.assertBookNameIsFree("ideas", excluding: book.id)
            // …but another book's name is still taken.
            _ = try ops.createReading(name: "Orbit", kind: .book)
            #expect(throws: OperationError.duplicateBookName(name: "Orbit")) {
                try ops.assertBookNameIsFree("orbit", excluding: book.id)
            }
        }
    }

    /// Her words: *archived/deleted books don't count*. A FINISHED book does
    /// count — it sits on the shelf, so a second book wearing its name is the
    /// confusion the ruling is about.
    @Test func aDeletedBookFreesItsNameAndAFinishedOneDoesNot() throws {
        try withOperations { ops, _ in
            let gone = try ops.createReading(name: "Ideas", kind: .book)
            try ops.deleteReading(gone.id)
            try ops.assertBookNameIsFree("Ideas")

            let finished = try ops.createReading(name: "Orbit", kind: .book)
            try ops.lockReading(finished.id)
            #expect(throws: OperationError.duplicateBookName(name: "Orbit")) {
                try ops.assertBookNameIsFree("Orbit")
            }
        }
    }

    /// **The operations themselves are byte-unchanged** — the guard is a door
    /// rule, never an invariant. The seeders, `shelveInDailyJournalBook`'s
    /// create-and-pin ("it NEVER throws", AppSpec §9) and the sync apply path
    /// all mint through these, and a name refusal there would break them.
    @Test func createAndRenameStillAcceptDuplicateNamesThemselves() throws {
        try withOperations { ops, db in
            _ = try ops.createReading(name: "Ideas", kind: .book)
            let second = try ops.createReading(name: "Ideas", kind: .gathering, querySpec: try RuleGrammar.encode(.star))  // 13i-c: minted with a rule
            #expect(second.name == "Ideas")

            let third = try ops.createReading(name: "Orbit", kind: .book)
            try ops.renameReading(third.id, name: "ideas")
            let names = try db.read { try Queries.readings($0) }.map(\.name)
            #expect(names.sorted() == ["Ideas", "Ideas", "ideas"])
        }
    }
}
