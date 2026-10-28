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

    /// **VX-616** (her ruling 2026-10-28, "agree with removing the button"):
    /// a GATHERING's foot is "+ new note" alone — its "+ new chapter" (the bind
    /// offer in a chapter's clothes) is retired; a BOOK keeps its chapter door
    /// in every state. A design row, so its pin is the list the foot renders
    /// FROM (`BookView`'s gathering foot draws exactly this), plus the walk's
    /// capture. Binding stays asked for by name — the row menu's
    /// `.bindIntoBook` — and earned by the hand-drag's teaching offer (their
    /// own pins, `BindDoorTests`, unchanged).
    @Test func aGatheringsFootIsTheNoteDoorAloneAndABookKeepsItsChapterDoor() {
        #expect(BookFootDoors.gathering() == [.newNote])
        #expect(!BookFootDoors.gathering().contains(.newChapter), "no chapter door on a gathering")
        for journal in [false, true] {
            for finished in [false, true] {
                for deleted in [false, true] {
                    #expect(BookFootDoors.book(
                        journalTrait: journal, finished: finished, hasDeletedChapters: deleted
                    ).first == .newChapter, "a book's foot leads with its chapter door, always")
                }
            }
        }
        // The bind's named door is still declared where a gathering's row
        // menu draws it.
        #expect(ShelfView.contextMenuCapabilities.contains(.bindIntoBook))
    }
}
