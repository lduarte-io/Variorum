//
//  BookFootDoorsTests.swift
//  VariorumTests
//
//  VX-553 (the VX-439 run, A-439-5) — her words: "'restore deleted chapter'
//  can NOT be in between new note and new chapter at the bottom of a book —
//  that's so annoying, def the wrong place for it." A DESIGN row, so its pin
//  is the order the foot renders FROM (`BookFootDoors.book` — `BookView`'s
//  navigator foot draws exactly this list), plus the walk's capture (the
//  orchestrator's). The old foot drew chapter · restore · note: the case
//  `restoreNeverSitsBetweenTheMintPair` names.
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-553 — the book foot keeps its two mints together; restore comes after, set apart")
struct BookFootDoorsTests {
    @Test func theEverydayPairStandsTogetherAndRestoreComesLast() {
        #expect(BookFootDoors.book(journalTrait: false, finished: false, hasDeletedChapters: true)
                == [.newChapter, .newNote, .restoreChapter])
        #expect(BookFootDoors.book(journalTrait: true, finished: false, hasDeletedChapters: true)
                == [.newChapter, .newEntry, .restoreChapter])
        // No deleted chapter waiting: no recovery door at all.
        #expect(BookFootDoors.book(journalTrait: false, finished: false, hasDeletedChapters: false)
                == [.newChapter, .newNote])
        // A FINISHED book draws no mint door (Round 3's rule, unchanged); the
        // chapter door and the recovery door keep their places.
        #expect(BookFootDoors.book(journalTrait: false, finished: true, hasDeletedChapters: true)
                == [.newChapter, .restoreChapter])
    }

    @Test func restoreNeverSitsBetweenTheMintPair() {
        for journal in [false, true] {
            for finished in [false, true] {
                let doors = BookFootDoors.book(
                    journalTrait: journal, finished: finished, hasDeletedChapters: true)
                #expect(doors.last == .restoreChapter, "the recovery door is after every mint door")
                if let chapter = doors.firstIndex(of: .newChapter),
                   let mint = doors.firstIndex(where: { $0 == .newNote || $0 == .newEntry }) {
                    #expect(mint == chapter + 1, "new chapter and the note door are adjacent")
                }
            }
        }
        #expect(BookFootDoors.recoveryGap > 0, "set apart, not just after")
    }
}
