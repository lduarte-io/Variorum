//
//  BookFacesWordsTests.swift
//  VariorumTests
//
//  The VX-914 run, batch 3 — the book faces' WORDS: VX-897 (the delete and
//  archive confirms' em dashes become commas, RULED in her chat, Nov 7) and
//  VX-667 (the context bar's book icon speaks kinds — a gathering is never
//  counted as a book). The record: `notes/plans/fixes/vx-914-walkthrough-
//  followups.md`, BATCH 3.
//

import Foundation
import Testing
import VariorumCore

@testable import Variorum

// MARK: - VX-897

@Suite("VX-897 — the owned book's delete and archive confirms say it with a comma")
struct ConfirmCommaWordsTests {
    /// **The ruled sentence, exactly** (her chat, Nov 7): "…the book goes to
    /// the Trash for 30 days, and Put back returns whatever went in together,
    /// together." — the comma where the em dash stood; the N stays dynamic.
    @Test func theOwnedDeleteConfirmsSecondLineIsTheRuledSentence() {
        let confirm = BookStateCopy.deleteOwnedBook(readingID: "o", name: "Mine", notes: 2)
        #expect(confirm.lines.count == 2)
        #expect(confirm.lines.last
                == "Either way the book goes to the Trash for \(TrashWindow.days) days, and "
                + "Put back returns whatever went in together, together.")
        #expect(confirm.lines.last?.contains("\u{2014}") == false, "no em dash on the ruled line")
        // Outside the ruling, unchanged: the first line keeps its own words.
        #expect(confirm.lines.first
                == "\u{201C}Mine\u{201D} owns its notes. Delete the book only, and its 2 notes go "
                + "back to the Pool \u{2014} or delete the book and its 2 notes together.")
    }

    /// **Its archive twin** (`keptLine`, the owned book's two-choice archive
    /// confirm): the em dash becomes a comma too.
    @Test func theArchiveConfirmsKeptLineSaysItWithAComma() {
        #expect(BookStateCopy.keptLine
                == "Either way it's kept under Archived, with no countdown, and Unarchive brings "
                + "back whatever went in together, together.")
        #expect(!BookStateCopy.keptLine.contains("\u{2014}"))
        let confirm = BookStateCopy.archiveOwnedBook(readingID: "o", name: "Mine", notes: 2)
        #expect(confirm.lines.contains(BookStateCopy.keptLine), "the confirm speaks the kept line")
    }
}

// MARK: - VX-667

@Suite("VX-667 — the book icon's popover and hover speak kinds")
struct AscentKindWordsTests {
    /// **Her case** (a note in one book and one gathering): the popover's
    /// headline was "This note is in 2 books — open one at this note:" while
    /// the chip beside it said "in ‹book› · 1 gathering". It speaks the chip's
    /// headline grammar now — books "in", gatherings "appears in".
    @Test func aNoteInOneBookAndOneGatheringIsNeverTwoBooks() {
        let header = WorkspaceNaming.ascentListHeader(bookCount: 1, gatheringCount: 1)
        #expect(header == "This note is in 1 book and appears in 1 gathering — open one at this note:")
        #expect(!header.contains("2 books"))
        let help = WorkspaceNaming.ascentHelp(topBook: "Essays", bookCount: 1, gatheringCount: 1)
        #expect(help == "This note is in 1 book and appears in 1 gathering — click to pick one")
        #expect(!help.contains("2 books"))
    }

    /// Gatherings alone: "appears in", never "is in … books".
    @Test func gatheringsAloneAppear() {
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 0, gatheringCount: 1)
                == "This note appears in 1 gathering — open it at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 0, gatheringCount: 2)
                == "This note appears in 2 gatherings — open one at this note:")
        #expect(WorkspaceNaming.ascentHelp(topBook: "#reading", bookCount: 0, gatheringCount: 2)
                == "This note appears in 2 gatherings — click to pick one")
        // One gathering alone: the one place is named and opened (the count
        // of places decides the click, never the kind).
        #expect(WorkspaceNaming.ascentHelp(topBook: "#reading", bookCount: 0, gatheringCount: 1)
                == "Open \u{201c}#reading\u{201d} at this note (\u{2318}-click to see it listed)")
    }

    /// The plural arms by kind, and the books-only sentences byte-for-byte the
    /// shipped ones.
    @Test func thePluralsFollowEachKindsOwnCount() {
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 2, gatheringCount: 3)
                == "This note is in 2 books and appears in 3 gatherings — open one at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 2, gatheringCount: 0)
                == "This note is in 2 books — open one at this note:")
        #expect(WorkspaceNaming.ascentListHeader(bookCount: 1, gatheringCount: 0)
                == "This note is in 1 book — open it at this note:")
    }

    /// The context bar hands the words its places BY KIND (the chip's own
    /// split), never the mixed total — grep form (a popover is not evaluated
    /// by the test host). The click's arity still reads the total: a
    /// gathering is a place she can open.
    @Test func theContextBarCountsByKind() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appending(path: "Variorum/Workspace/ContextBar.swift"),
            encoding: .utf8)
        #expect(source.components(separatedBy: "bookCount: memberBookCount, gatheringCount: gatheringCount")
            .count - 1 == 2, "the help and the headline both read the kinds")
        #expect(source.contains("books.filter { $0.kind == .book }.count"))
        #expect(source.contains("books.filter { $0.kind == .gathering }.count"))
        #expect(!source.contains("count: books.count))"), "no ascent sentence reads the mixed total")
        #expect(source.contains("bookCount: books.count,"), "the click's arity: every place")
    }
}
