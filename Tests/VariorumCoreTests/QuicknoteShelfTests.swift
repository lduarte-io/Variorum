import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13g, batch 7 — her ruling R6-4, verbatim: *"i also like the idea of
/// quicknotes automatically adding a quicknote tag and there being a smart
/// 'quicknotes' book that's just based on tag, so if you remove the tag it
/// leaves the book."*
///
/// The point of this suite is how LITTLE had to be built: an ordinary post
/// tag and an ordinary smart book pointed at each other. The leaving half is
/// smart membership's own semantics, and it is pinned here precisely because
/// nothing was written to make it true.
@Suite("The quicknote tag & its smart book (13g batch 7 — R6-4)")
struct QuicknoteShelfTests {
    @Test func filingTagsTheNoteAndPutsThePinnedSmartBookOnTheShelf() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            let outcome = ops.fileAsQuicknote(note.id)

            guard case .filed(let tagID, let readingID) = outcome else {
                Issue.record("expected .filed, got \(outcome)")
                return
            }
            let (tags, book, pins) = try db.read { database in
                (try Queries.postTags(database, postID: note.id),
                 try Queries.reading(database, id: readingID),
                 try Queries.shelfPins(database))
            }
            #expect(tags.map(\.path) == [Operations.quicknoteTagPath])
            #expect(tags.first?.id == tagID)
            #expect(book?.name == Operations.defaultQuicknoteBookName)
            #expect(book?.kind == .gathering)
            #expect(pins.contains(readingID))
            // Designated the daily book's way — so the SECOND quick note
            // finds it rather than minting a rival.
            #expect(try db.read { try Queries.quicknotesBookID($0) } == readingID)
        }
    }

    /// DISCRIMINATING REVERT (verified): mint the book `kind: .book`
    /// instead of `.gathering` in `ensureQuicknotesBook` and this test fails on
    /// its FIRST assembly — a curated book collects nothing, because
    /// membership would have to be a row somebody wrote.
    @Test func theBookCOLLECTSTheTagAndRemovingTheTagLEAVESIt() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "Jotted.").container
            guard case .filed(let tagID, let readingID) = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .filed")
                return
            }

            let collected = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(collected.map(\.postID) == [note.id])

            // Her sentence's second half — and nothing was built for it.
            try ops.removeTag(tagID, fromPost: note.id)
            let afterUntag = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(afterUntag.isEmpty)

            // …and it left by DERIVATION: no membership row was ever
            // written, live or tombstoned, so nothing had to be cleaned up.
            let membershipRows = try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?",
                    arguments: [readingID])
            }
            #expect(membershipRows == 0)

            // Re-tagging brings it back, for the same reason.
            _ = try ops.applyTag(tagID, toPost: note.id)
            let again = try db.read {
                try Queries.assembleReading($0, readingID: readingID)
            }
            #expect(again.map(\.postID) == [note.id])
        }
    }

    @Test func theSecondQuickNoteReusesTheSameTagAndTheSameBook() throws {
        try withOperations { ops, db in
            let first = try ops.importPost(title: nil, text: "One.").container
            let second = try ops.importPost(title: nil, text: "Two.").container
            guard case .filed(let tagID, let readingID) = ops.fileAsQuicknote(first.id),
                  case .filed(let tagID2, let readingID2) = ops.fileAsQuicknote(second.id)
            else {
                Issue.record("expected two .filed outcomes")
                return
            }
            #expect(tagID == tagID2)
            #expect(readingID == readingID2)
            let (tagCount, bookCount) = try db.read { database in
                (try Int.fetchOne(
                    database, sql: "SELECT COUNT(*) FROM tag WHERE deleted_at IS NULL"),
                 try Int.fetchOne(
                    database, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL"))
            }
            #expect(tagCount == 1)
            #expect(bookCount == 1)
            // Both notes are in the book, collected by the predicate.
            let collected = try db.read {
                try Queries.assembleReading($0, readingID: readingID).map(\.postID)
            }
            #expect(Set(collected) == Set([first.id, second.id]))
        }
    }

    /// The #37(iii) precedent's two halves: a DANGLING designation reads as
    /// none (so a book she threw away is not resurrected), and a LIVE
    /// designation is never replaced (a book she renamed stays hers).
    ///
    /// DISCRIMINATING REVERT (verified): drop the liveness clause from
    /// `Queries.quicknotesBookID`'s designation read and the first half
    /// fails — the second filing hands back the DELETED book's id.
    @Test func aDanglingDesignationMintsAfreshAndALiveOneIsNeverReplaced() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "One.").container
            guard case .filed(_, let firstBook) = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .filed")
                return
            }
            try ops.deleteReading(firstBook)

            let second = try ops.importPost(title: nil, text: "Two.").container
            guard case .filed(_, let secondBook) = ops.fileAsQuicknote(second.id) else {
                Issue.record("expected .filed")
                return
            }
            #expect(secondBook != firstBook)
            #expect(try db.read { try Queries.quicknotesBookID($0) } == secondBook)

            // Now it is LIVE and she has made it her own — renaming it must
            // not cause a rival to be minted beside it.
            try ops.renameReading(secondBook, name: "My jots")
            let third = try ops.importPost(title: nil, text: "Three.").container
            guard case .filed(_, let thirdBook) = ops.fileAsQuicknote(third.id) else {
                Issue.record("expected .filed")
                return
            }
            #expect(thirdBook == secondBook)
            #expect(try db.read { try Queries.reading($0, id: secondBook)?.name } == "My jots")
        }
    }

    /// It NEVER THROWS — the note is already minted and durable by the time
    /// this runs, so a failure here must report rather than take the capture
    /// with it (`shelveInDailyJournalBook`'s rule, and its reason).
    @Test func itNeverThrowsAndSaysWhatHappened() throws {
        try withOperations { ops, db in
            let note = try ops.importPost(title: nil, text: "One.").container
            _ = ops.fileAsQuicknote(note.id)
            // Filing the same note twice reports rather than refusing.
            guard case .alreadyTagged = ops.fileAsQuicknote(note.id) else {
                Issue.record("expected .alreadyTagged on a re-file")
                return
            }
            // A note that is gone reports too — and in words, never an
            // error dump with a row id in it.
            guard case .refused(let reason) = ops.fileAsQuicknote("no-such-note") else {
                Issue.record("expected .refused for a missing note")
                return
            }
            #expect(reason == "the note is no longer there")
            // Nothing partial was left behind by the refusal.
            let applications = try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM post_tag WHERE deleted_at IS NULL")
            }
            #expect(applications == 1)
        }
    }
}
