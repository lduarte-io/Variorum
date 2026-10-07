//
//  BookSearchTests.swift
//  VariorumTests
//
//  **13o U3 — SEARCH WITHIN A BOOK** (her R-13o-14: *"I like search this
//  book to the right (option 1), but collapse it into a magnifying glass and
//  only expand it when clicked on"*; the architect's F1: *"the answer sheet's
//  small sibling in place of the book's content while the field holds words"*
//  — one search idiom, landing identical to the Library's; ruling B: a
//  GATHERING searches its assembled members). The brain's state transitions
//  (the field, the answer, paging, "all N ›", the archived facet where it
//  can act), the masthead door's declaration, and the sheet mounted in every
//  room.
//
//  BUILD pins (a new surface): pre-U3 the book had no search at all
//  (`BookSearchModel`, `.searchThisBook` did not exist).
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
@Suite("13o U3 — search within a book (the masthead's 🔍, the answer in place)", .serialized)
struct BookSearchTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
                return value
            }
        }
    }

    private func withSession<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    // MARK: - The field and the answer

    @Test func theFieldOpensAsksTheBookAndClosesBackToTheGlyph() async throws {
        try await withSession { session in
            let ops = session.operations
            let book = try ops.createReading(name: "The Work", kind: .book)
            let member = try ops.createPost(title: "Night office")
            let block = try ops.newBlock(in: member.id, text: "woke with the dream still wet")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let outsider = try ops.createPost(title: "Elsewhere")
            _ = try ops.newBlock(in: outsider.id, text: "a dream outside the book")

            let search = BookSearchModel(session: session, readingID: book.id)
            #expect(!search.isOpen && !search.isAnswering, "the glyph at rest")
            search.open()
            #expect(search.isOpen)
            await search.setText("dream ")
            #expect(search.isAnswering, "words: the answer shows in place of the content (F1)")
            #expect(search.groups.map(\.homeID) == [member.id], "the book's members only")
            #expect(search.groups.first?.lines.first?.blockID == block.block.id)
            #expect(search.counts?.living.notes == 1 && search.counts?.living.passages == 1)
            #expect(search.words == "dream")
            #expect(BookSearchCopy.counts(try #require(search.counts).living) == "1 passage in 1 note")

            await search.setText("#dream")
            #expect(!search.isAnswering, "a tag alone has no words — the book's content stays")

            await search.setText("dream ")
            search.close()
            #expect(!search.isOpen && !search.isAnswering && search.text.isEmpty && search.groups.isEmpty,
                    "Esc / the glyph again: back to the glyph, the mode untouched beneath")
        }
    }

    @Test func aGatheringSearchesItsAssembledMembers() async throws {
        try await withSession { session in
            let ops = session.operations
            let dream = try ops.createTag(name: "dream")
            let gathering = try ops.createReading(
                name: "All dreams", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(dream.id)))
            let member = try ops.createPost(title: "Tagged")
            _ = try ops.newBlock(in: member.id, text: "lantern light")
            _ = try ops.applyTag(dream.id, toPost: member.id)
            let other = try ops.createPost(title: "Untagged")
            _ = try ops.newBlock(in: other.id, text: "lantern light")

            let search = BookSearchModel(session: session, readingID: gathering.id)
            search.open()
            await search.setText("lantern ")
            #expect(search.groups.map(\.homeID) == [member.id], "ruling B: the rule's members, at query time")
            #expect(!search.offersArchived, "nothing archived to add — the chip is not drawn (P-2)")
        }
    }

    @Test func everyGroupAndEveryPassageIsReachable() async throws {
        try await withSession { session in
            let ops = session.operations
            let book = try ops.createReading(name: "Big", kind: .book)
            var notes: [String] = []
            for n in 0..<30 {
                let post = try ops.createPost(title: "Note \(n)")
                _ = try ops.newBlock(in: post.id, text: "quokka words \(n)")
                _ = try ops.addPostToReading(post.id, to: book.id)
                notes.append(post.id)
            }
            let long = try ops.createPost(title: "Long")
            for n in 0..<6 { _ = try ops.newBlock(in: long.id, text: "quokka line \(n)") }
            _ = try ops.addPostToReading(long.id, to: book.id)

            let search = BookSearchModel(session: session, readingID: book.id)
            search.open()
            await search.setText("quokka ")
            #expect(search.groups.count == BookSearchModel.groupPageSize && search.hasMoreGroups)
            await search.loadMoreGroups()
            #expect(Set(search.groups.map(\.homeID)) == Set(notes + [long.id]), "every note, by paging")
            #expect(!search.hasMoreGroups)

            let longGroup = try #require(search.groups.first { $0.homeID == long.id })
            #expect(longGroup.lines.count == BookSearchModel.linesPerGroup && longGroup.lineCount == 6)
            await search.toggleExpansion(long.id)
            #expect(search.expansions[long.id]?.lines.count == 6, "all 6 › — the whole road")
            await search.toggleExpansion(long.id)
            #expect(search.expansions[long.id] == nil, "fewer ‹")
        }
    }

    @Test func theArchivedFacetIsOfferedWhereItCanAct() async throws {
        try await withSession { session in
            let ops = session.operations
            let book = try ops.createReading(name: "Kept", kind: .book)
            let live = try ops.createPost(title: "Live")
            _ = try ops.newBlock(in: live.id, text: "orchid on the sill")
            _ = try ops.addPostToReading(live.id, to: book.id)
            let stored = try ops.createPost(title: "Stored")
            _ = try ops.newBlock(in: stored.id, text: "orchid in a box")
            _ = try ops.addPostToReading(stored.id, to: book.id)
            try ops.archiveContainer(stored.id)

            let search = BookSearchModel(session: session, readingID: book.id)
            search.open()
            await search.setText("orchid ")
            #expect(search.groups.map(\.homeID) == [live.id])
            #expect(search.offersArchived, "the book's archived member holds a match")
            await search.toggleArchived()
            #expect(Set(search.groups.map(\.homeID)) == [live.id, stored.id])
            #expect(search.groups.first { $0.homeID == stored.id }?.isArchived == true, "it says so")
            search.close()
            #expect(search.visibility == .living, "a cleared field forgets the facet")
        }
    }

    // MARK: - The door and the face

    @Test func theMastheadDoorIsDeclared() {
        #expect(BookView.surfaceCapabilities.contains(.searchThisBook))
        let capability = CapabilityRegistry.capability(.searchThisBook)
        #expect(capability.verb == "Search This Book\u{2026}" && capability.scope == .book)
        #expect(capability.doors == [.surface])
        #expect(BookSearchCopy.placeholder == "search this book\u{2026}", "the mockup's own words")
        #expect(BookSearchCopy.counts(.init(books: 0, notes: 5, passages: 14, scraps: 0)) == "14 passages in 5 notes")
        #expect(BookSearchCopy.counts(.init(books: 0, notes: 2, passages: 0, scraps: 0)) == "2 notes")
        #expect(BookSearchCopy.counts(.init(books: 0, notes: 0, passages: 0, scraps: 0)) == BookSearchCopy.nothing)
    }

    @Test(arguments: [ThemeVoice.terminal, .study], [false, true])
    func theAnswerLaysOutInEveryRoom(voice: ThemeVoice, dark: Bool) async throws {
        try await withSession { session in
            let ops = session.operations
            let book = try ops.createReading(name: "The Work", kind: .book)
            let member = try ops.createPost(title: "Night office")
            _ = try ops.newBlock(in: member.id, text: "woke with the dream still wet")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let search = BookSearchModel(session: session, readingID: book.id)
            search.open()
            await search.setText("dream ")
            let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
            let sheet = BookSearchSheet(tokens: tokens, model: search) { _, _, _ in }
            let host = NSHostingView(rootView: sheet.frame(width: 700, height: 400))
            host.frame = NSRect(x: 0, y: 0, width: 700, height: 400)
            host.layoutSubtreeIfNeeded()
            #expect(host.fittingSize.width >= 700 && host.fittingSize.height >= 400, "it covers the body whole")
            let door = BookSearchDoor(tokens: tokens, model: search)
            let doorHost = NSHostingView(rootView: door)
            doorHost.layoutSubtreeIfNeeded()
            #expect(doorHost.fittingSize.height < 40, "one masthead line: \(doorHost.fittingSize)")
        }
    }
}
