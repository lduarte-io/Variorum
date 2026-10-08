import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13s-b U2 — the tour's two reads (`Queries.tourLandmarks`,
/// `Queries.tourNoteFacts`): the landmarks found by their exact reserved
/// names (and missing ones answered as nil, never a guess), and one note's
/// tag and book counts — the facts step 11 and the keep-going leg wait on.
@Suite("13s-b U2 — the tour's landmarks and note facts")
struct TourQueriesTests {
    private func landmarks(_ db: AppDatabase, wing: String = "") throws -> Queries.TourLandmarks {
        try db.read {
            try Queries.tourLandmarks(
                $0, seededBookName: "the adventures of sherlock holmes",
                firstStoryTitle: "A Scandal in Bohemia",
                fieldGuideName: "the field guide", wingID: wing)
        }
    }

    @Test func theLandmarksAreFoundByTheirExactNamesInTheWing() throws {
        try withOperations { ops, db in
            let sherlock = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let about = try ops.createPost(title: "About this book")
            let scandal = try ops.createPost(title: "A Scandal in Bohemia")
            try ops.addPostToReading(about.id, to: sherlock.id)
            try ops.addPostToReading(scandal.id, to: sherlock.id)
            let guide = try ops.createReading(name: "the field guide", kind: .book)

            let found = try landmarks(db)
            #expect(found.seededBookID == sherlock.id)
            #expect(found.firstStoryID == scandal.id, "the story by its title, not the first row")
            #expect(found.fieldGuideID == guide.id)
            // Another wing has none of them.
            let other = try ops.createWing(name: "work")
            #expect(try landmarks(db, wing: other.id)
                    == .init(seededBookID: nil, firstStoryID: nil, fieldGuideID: nil))
        }
    }

    @Test func aRenamedDeletedOrArchivedLandmarkIsMissingNotGuessed() throws {
        try withOperations { ops, db in
            _ = try ops.createReading(name: "The Adventures of Sherlock Holmes", kind: .book)
            let guide = try ops.createReading(name: "the field guide", kind: .book)
            try ops.deleteReading(guide.id)
            let found = try landmarks(db)
            #expect(found.seededBookID == nil, "a renamed book is hers — never matched by case")
            #expect(found.fieldGuideID == nil, "a deleted guide is not a landmark")
            let archived = try ops.createReading(name: "the field guide", kind: .book)
            try ops.archiveReading(archived.id)
            #expect(try landmarks(db).fieldGuideID == nil)
            // The seeded book without its first story: the book, no story.
            let sherlock = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let found2 = try landmarks(db)
            #expect(found2.seededBookID == sherlock.id)
            #expect(found2.firstStoryID == nil)
        }
    }

    @Test func aNotesFactsCountItsLiveTagsAndItsBookMembershipsOnly() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "mine")
            func facts() throws -> Queries.TourNoteFacts {
                try db.read { try Queries.tourNoteFacts($0, postID: note.id) }
            }
            #expect(try facts() == .init(tagCount: 0, bookCount: 0))

            let ideas = try ops.createTag(name: "ideas")
            let gone = try ops.createTag(name: "gone")
            _ = try ops.applyTag(ideas.id, toPost: note.id)
            _ = try ops.applyTag(gone.id, toPost: note.id)
            #expect(try facts().tagCount == 2)
            try ops.deleteTag(gone.id)
            #expect(try facts().tagCount == 1, "a deleted tag is not a tag")
            try ops.removeTag(ideas.id, fromPost: note.id)
            #expect(try facts().tagCount == 0)

            let book = try ops.createReading(name: "essays", kind: .book)
            try ops.addPostToReading(note.id, to: book.id)
            #expect(try facts().bookCount == 1)
            _ = try ops.removePostFromReading(note.id, from: book.id)
            #expect(try facts().bookCount == 0, "a removed membership is not a book")
        }
    }
}
