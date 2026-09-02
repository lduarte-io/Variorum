//
//  NavigatorReadRowsTests.swift
//  VariorumTests
//
//  R-cor-17 (the Act 10 correction round, ladder fix 2 — R2-10 ruled a
//  fix): in the book's READ tab — Scroll and Pages — a navigator NOTE row
//  lands the read page at that story and the navigator NEVER leaves Read;
//  Outline keeps opening the note for editing. The door is
//  `BookNavigatorDoor.noteRowClicked` on the two real models, so the pin
//  drives it without a window: on both Read faces the mode STAYS `.read`
//  and the story is handed to the face's landing road (the flow's reveal
//  slot — H's landing pins are its consumer; the paged reader's focus —
//  `PagedReadView` follows it); in Outline the note opens. RED ON OLD
//  (behavioral revert — the Read acts back to the note-open road): the
//  mode flipped to `.outline` on both faces.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The Read tab's navigator note rows land the read page (R-cor-17)")
struct NavigatorReadRowsTests {
    private func withChapteredBook<T>(
        _ body: @MainActor (AppSession, AppDatabase, String, [Queries.ReadingEntry], BookStructureModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 47))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the read tab", kind: .curated)
            var entries: [Queries.ReadingEntry] = []
            for c in 0..<2 {
                let section = try session.operations.createSection(in: reading.id, name: "chapter \(c)")
                for n in 0..<2 {
                    let post = try session.operations.createPost(title: "note \(c).\(n)")
                    _ = try session.operations.newBlock(in: post.id, text: "Paragraph one of note \(c).\(n).")
                    try session.operations.addPostToReading(post.id, to: reading.id)
                    try session.operations.assignPostToSection(post.id, in: reading.id, section: section.id)
                    entries.append(Queries.ReadingEntry(
                        postID: post.id, title: "note \(c).\(n)", entryDate: nil, sectionPath: nil))
                }
            }
            let structure = BookStructureModel(session: session, readingID: reading.id)
            structure.adopt(.init(
                reading: try await db.read { [id = reading.id] in try Queries.reading($0, id: id) },
                sections: try await db.read { [id = reading.id] in try Queries.readingSections($0, readingID: id) },
                deletedSections: [],
                assignments: try await db.read { [id = reading.id] in try Queries.sectionAssignments($0, readingID: id) }))
            return try await body(session, db, reading.id, entries, structure)
        }
    }

    /// Read ▸ Scroll: the note row hands the story to the flow's landing
    /// road (the reveal slot) and the tab stays Read.
    @Test func inReadScrollANoteRowLandsTheFlowAndNeverLeavesRead() async throws {
        try await withChapteredBook { session, _, readingID, entries, structure in
            let model = BookViewModel(session: session, readingID: readingID)
            structure.mode = .read
            structure.readForm = .flow
            let second = entries[1]
            BookNavigatorDoor.noteRowClicked(second, model: model, structure: structure)
            #expect(structure.mode == .read, "the navigator never leaves Read")
            #expect(model.pendingReveal == second.postID, "the flow's landing road carries the story")
            #expect(model.focusedPostID == nil, "Read edits nothing: no editing focus is claimed")
            // The collapsed one-note chapter row is the note's row: the same act.
            let first = entries[0]
            BookNavigatorDoor.noteRowClicked(first, model: model, structure: structure)
            #expect(structure.mode == .read)
            #expect(model.pendingReveal == first.postID)
        }
    }

    /// Read ▸ Pages: the note row turns the reader to the story (the
    /// paged reader follows the book's focus) and the tab stays Read.
    @Test func inReadPagesANoteRowTurnsTheReaderAndNeverLeavesRead() async throws {
        try await withChapteredBook { session, _, readingID, entries, structure in
            let model = BookViewModel(session: session, readingID: readingID)
            structure.mode = .read
            structure.readForm = .pages
            let third = entries[2]
            BookNavigatorDoor.noteRowClicked(third, model: model, structure: structure)
            #expect(structure.mode == .read, "the navigator never leaves Read")
            #expect(model.focusedPostID == third.postID, "the reader follows the focus to the story")
            #expect(model.pendingReveal == nil, "the pages road is the focus, not the flow's slot")
        }
    }

    /// Outline is unchanged: the row opens the note for editing (focus +
    /// reveal, landed by Outline).
    @Test func inOutlineANoteRowStillOpensTheNote() async throws {
        try await withChapteredBook { session, _, readingID, entries, structure in
            let model = BookViewModel(session: session, readingID: readingID)
            structure.mode = .outline
            let fourth = entries[3]
            BookNavigatorDoor.noteRowClicked(fourth, model: model, structure: structure)
            #expect(structure.mode == .outline)
            #expect(model.focusedPostID == fourth.postID)
            #expect(model.pendingReveal == fourth.postID)
            // …and from the spread the note row page-jumps, never leaving the Book tab.
            structure.mode = .spread
            model.adopt(entries)
            BookNavigatorDoor.noteRowClicked(entries[2], model: model, structure: structure)
            #expect(structure.mode == .spread, "the spread's row is a page-jump, not a jump into Outline")
        }
    }
}
