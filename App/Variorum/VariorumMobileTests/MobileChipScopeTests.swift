//
//  MobileChipScopeTests.swift
//  VariorumMobileTests
//
//  VM-69 (the VM-64 run, batch 6) — hazard (d): **the chips' scoped reads
//  show exactly what the full reads showed.** The masthead's books and tags
//  chips now read only what they show (`refreshChip()`: the books holding the
//  note, the note's own tags); the sheets keep the full `refresh()` (every
//  book for "Add to a book", every tag for the suggestions), on appear as
//  before. The chip must not change by a row: the same books in the same
//  order with the same archived state, the same tags, the same line.
//
//  This suite names the new chip reads, so it does not compile against the
//  pre-fix tree and is set aside for the red-on-old build — it is a guard on
//  the fix's own equivalence, not a red-on-old pin (the record, §7 batch 6).
//  The red-on-old pin for the chips is `MobileNoteOpenOnceTests
//  .openingANoteReadsNoListingOfEveryBookOrEveryTag`.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-69 — the chips' scoped reads show what the full reads showed")
struct MobileChipScopeTests {
    /// A note in two curated books — one of them ARCHIVED (membership is a
    /// fact; the faces mark it) — and collected by a gathering through its
    /// tag; books and a gathering it is NOT in; three tags, two of them worn;
    /// one reference.
    private func world(_ session: AppSession) async throws -> String {
        try await session.runner.run { ops -> String in
            let post = try ops.createPost(title: "Harbor", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Base.", at: .end)
            let sea = try ops.createTag(name: "sea")
            let salt = try ops.createTag(name: "salt")
            _ = try ops.createTag(name: "wind")
            _ = try ops.applyTag(sea.id, toPost: post.id)
            _ = try ops.applyTag(salt.id, toPost: post.id)
            let essays = try ops.createReading(name: "Essays", kind: .book)
            _ = try ops.addPostToReading(post.id, to: essays.id)
            let log = try ops.createReading(name: "Old Log", kind: .book)
            _ = try ops.addPostToReading(post.id, to: log.id)
            try ops.archiveReading(log.id)
            _ = try ops.createReading(name: "Spare", kind: .book)
            _ = try ops.createReading(
                name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#)
            _ = try ops.createReading(
                name: "Windy", kind: .gathering, querySpec: #"{"tags":["wind"]}"#)
            _ = try ops.addReference(to: post.id, kind: .url, name: "Tides", url: "https://example.com/tides")
            return post.id
        }
    }

    @Test func theBooksChipShowsTheSameBooksInTheSameOrder() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await world(session)
            let chip = MobileMembershipModel(session: session, postID: postID)
            await chip.refreshChip()
            let full = MobileMembershipModel(session: session, postID: postID)
            await full.refresh()

            #expect(chip.books.map(\.id) == full.books.map(\.id), "the same books, in the same order")
            #expect(chip.books.map(\.name) == ["Essays", "Old Log", "By the Water"],
                    "curated before gathering, name order inside each: \(chip.books.map(\.name))")
            #expect(chip.books.map { $0.archivedAt != nil } == full.books.map { $0.archivedAt != nil },
                    "the archived book is there, archived, on both")
            #expect(chip.books.map(\.kind) == full.books.map(\.kind))
            #expect(MobileMembershipModel.labelText(bookNames: chip.books.map(\.name))
                    == MobileMembershipModel.labelText(bookNames: full.books.map(\.name)),
                    "the chip's words are the same")
            #expect(chip.status == nil && full.status == nil)

            // What the chip no longer reads is the SHEET's, and the sheet's
            // read still has it.
            #expect(chip.addableBooks.isEmpty && chip.addableSmartBooks.isEmpty,
                    "the chip read no listing of every book")
            #expect(full.addableBooks.map(\.name) == ["Spare"])
            #expect(full.addableSmartBooks.map(\.name) == ["Windy"])
        }
    }

    @Test func theTagsChipShowsTheSameTags() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await world(session)
            let chip = MobileNoteTagsModel(session: session, postID: postID)
            await chip.refreshChip()
            let full = MobileNoteTagsModel(session: session, postID: postID)
            await full.refresh()

            #expect(chip.applied.map(\.id) == full.applied.map(\.id), "the same tags, in the same order")
            #expect(chip.chipLine == full.chipLine)
            #expect(chip.chipLine == "#salt #sea", "path order: \(chip.chipLine ?? "nil")")
            #expect(chip.status == nil && full.status == nil)
            #expect(chip.allTags.isEmpty, "the chip read no listing of every tag")
            #expect(full.allTags.map(\.path) == ["salt", "sea", "wind"], "the sheet's read still has them")
        }
    }

    /// The references chip's read was already the note's own rows
    /// (`Queries.references(containerID:)`) and is unchanged — held here so
    /// the three chips' answers are pinned together.
    @Test func theReferencesChipIsUnchanged() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await world(session)
            let references = MobileReferencesModel(session: session, postID: postID)
            await references.refresh()
            #expect(references.references.map(\.name) == ["Tides"])
            #expect(MobileReferencesModel.chipLabel(count: references.references.count)
                    == MobileReferencesModel.chipLabel(count: 1))
        }
    }
}
