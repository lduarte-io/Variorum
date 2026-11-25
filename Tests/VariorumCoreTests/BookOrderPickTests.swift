//
//  BookOrderPickTests.swift
//  VariorumCoreTests
//
//  VX-1040 (the VX-1036 run, batch 1 — D-1, R-1036-33): what a pick on the
//  order dial means, per book kind — the pure rule's table, and the state its
//  save writes through the one road (`setReadingSort`) on each kind.
//

import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("VX-1040 — a pick on the order dial saves on a gathering and a non-manual book, looks on a hand-ordered one")
struct BookOrderPickTests {
    @Test func theRuleByBookKind() {
        #expect(BookOrderPick.meaning(kind: .gathering, storedField: .manual, finished: false) == .save,
                "a gathering: the pick is its order at once (it has no hand order)")
        #expect(BookOrderPick.meaning(kind: .gathering, storedField: .createdAt, finished: false) == .save)
        #expect(BookOrderPick.meaning(kind: .book, storedField: .entryDate, finished: false) == .save,
                "a book whose order is not manual: the pick is its order at once")
        #expect(BookOrderPick.meaning(kind: .book, storedField: .manual, finished: false) == .look,
                "a hand-ordered book: a look, with save and back in plain sight")
        for field in [SortField.manual, .entryDate, .lastTouched] {
            #expect(BookOrderPick.meaning(kind: .book, storedField: field, finished: true) == .look,
                    "a finished book looks and cannot save (\(field))")
        }
    }

    @Test func aSavedPickIsWhatEveryReaderSees() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "week")
            let gathering = try ops.createReading(
                name: "this week", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let dated = try ops.createReading(name: "dated", kind: .book, sortField: .entryDate)
            let hand = try ops.createReading(name: "hand", kind: .book)
            for (reading, expected) in [(gathering, BookOrderPick.Meaning.save), (dated, .save), (hand, .look)] {
                let row = try #require(try db.read { try Queries.reading($0, id: reading.id) })
                #expect(BookOrderPick.meaning(for: row) == expected, "\(reading.name)")
            }
            // A pick that saves writes the stored pair (the wire's road, too).
            try ops.setReadingSort(gathering.id, field: .createdAt, direction: .desc)
            let saved = try #require(try db.read { try Queries.reading($0, id: gathering.id) })
            #expect(saved.sortField == .createdAt && saved.sortDir == .desc)
            #expect(BookOrderPick.meaning(for: saved) == .save, "still a gathering's pick")
            // Saving manual on a dated book makes it hand-ordered: picks look from then on.
            try ops.setReadingSort(dated.id, field: .manual, direction: .asc)
            let nowHand = try #require(try db.read { try Queries.reading($0, id: dated.id) })
            #expect(BookOrderPick.meaning(for: nowHand) == .look)
            // A finished book: the op refuses a save, and the rule never asks it.
            try ops.lockReading(hand.id)
            let finished = try #require(try db.read { try Queries.reading($0, id: hand.id) })
            #expect(BookOrderPick.meaning(for: finished) == .look)
            #expect(throws: OperationError.lockedReading(id: hand.id)) {
                try ops.setReadingSort(hand.id, field: .createdAt, direction: .asc)
            }
        }
    }
}
