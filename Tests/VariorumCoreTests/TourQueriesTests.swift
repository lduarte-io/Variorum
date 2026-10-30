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

    /// The extra-pass MINOR-1 honesty gate: the end card's readme sentence
    /// may only show when a live, unarchived note wearing the reserved title
    /// exists in the wing. An existing store that predates the seeded readme
    /// answers false; a version (born archived) never counts; the fact is
    /// read only when the title is asked for.
    @Test func theReadmeGateAnswersOnlyForALiveUnarchivedReadmeInTheWing() throws {
        try withOperations { ops, db in
            func gate(_ wing: String = "") throws -> Bool {
                try db.read {
                    try Queries.tourLandmarks(
                        $0, seededBookName: "x", firstStoryTitle: "y",
                        fieldGuideName: "z", wingID: wing,
                        readmeTitle: "readme"
                    ).readmeNoteExists
                }
            }
            #expect(try gate() == false, "an empty store promises nothing")
            let readme = try ops.createPost(title: "readme")
            #expect(try gate() == true)
            // Unasked, the fact stays false (older callers unchanged).
            #expect(try db.read {
                try Queries.tourLandmarks(
                    $0, seededBookName: "x", firstStoryTitle: "y",
                    fieldGuideName: "z", wingID: "")
            }.readmeNoteExists == false)
            // Another wing does not see it.
            let other = try ops.createWing(name: "work")
            #expect(try gate(other.id) == false)
            // Archived (a version's shape) stops counting; deleted too.
            try ops.archiveContainer(readme.id)
            #expect(try gate() == false, "archived never promises")
            try ops.unarchiveContainer(readme.id)
            try ops.deleteContainer(readme.id)
            #expect(try gate() == false, "deleted never promises")
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

    /// **VX-292 R-292-17 — a half-gutted seeded book walks on real props.**
    /// Her words: *"what if they've deleted all the takes in the prince?
    /// wouldn't that ruin the tutorial?"* The toured chapter PREFERS the
    /// named one while it carries a fanned block (a live block with two or
    /// more live, active takes), else the FIRST live member (book order)
    /// that still does, else the named one as it stands; and the props are
    /// BROKEN — the start's cue to ask the book's own restore road — when
    /// the named chapter is not a live member or no live member carries a
    /// fan. RED ON OLD: the old read answered the named title or nothing,
    /// and said nothing about props.
    @Test func theTouredChapterPrefersTheNamedOneWhileItCarriesAFan() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            func chapter(_ title: String, fanned: Bool) throws -> (id: String, take: String?) {
                let note = try ops.createPost(title: title)
                _ = try ops.newBlock(in: note.id, text: "an opening line.", at: .end)
                let block = try ops.newBlock(in: note.id, text: "a middle line.", at: .end)
                try ops.addPostToReading(note.id, to: book.id)
                let take = fanned
                    ? try ops.branchVariant(block.block.id, from: block.variant.id).id : nil
                return (note.id, take)
            }
            let about = try chapter("About this book", fanned: false)
            let early = try chapter("A Case of Identity", fanned: true)
            let scandal = try chapter("A Scandal in Bohemia", fanned: true)
            let late = try chapter("The Red-Headed League", fanned: true)
            _ = (about, late)

            var found = try landmarks(db)
            #expect(found.firstStoryID == scandal.id, "the named chapter, fanned: it")
            #expect(found.seededBookPropsBroken == false)

            // Its fan archived (out of the fan, kept): the FIRST fanned member.
            try ops.archiveVariant(try #require(scandal.take))
            found = try landmarks(db)
            #expect(found.firstStoryID == early.id, "the first live member still carrying a fan")
            #expect(found.seededBookPropsBroken == false, "a fanned chapter stands: the props hold")

            // The named chapter deleted: still the fanned one — and broken.
            try ops.deleteContainer(scandal.id)
            found = try landmarks(db)
            #expect(found.firstStoryID == early.id)
            #expect(found.seededBookPropsBroken == true, "the named chapter is gone")

            // Every fan gone (a deleted take, a member removed): nothing fanned.
            try ops.deleteVariant(try #require(early.take))
            _ = try ops.removePostFromReading(late.id, from: book.id)
            found = try landmarks(db)
            #expect(found.firstStoryID == nil, "no named chapter, no fan: any note serves")
            #expect(found.seededBookPropsBroken == true)
        }
    }

    /// The named chapter live but unfanned with no fan anywhere: it is the
    /// tour's chapter as it stands (the mechanics need any note; step 5
    /// makes the take) — and the props are broken. No seeded book: nothing
    /// is broken (the other case — no book at all).
    @Test func aBookWithNoFanToursTheNamedChapterAndSaysItsPropsAreBroken() throws {
        try withOperations { ops, db in
            #expect(try landmarks(db).seededBookPropsBroken == false, "no book: not this case")
            let book = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            let scandal = try ops.createPost(title: "A Scandal in Bohemia")
            _ = try ops.newBlock(in: scandal.id, text: "one line.", at: .end)
            try ops.addPostToReading(scandal.id, to: book.id)
            let found = try landmarks(db)
            #expect(found.firstStoryID == scandal.id)
            #expect(found.seededBookPropsBroken == true)
        }
    }

    /// VX-292 U3 — the carried copy note (the U2 RECORD): step 3's card names
    /// a chapter, so the landmarks say whether the toured chapter IS that
    /// one. Under R-292-17's fallback (the named chapter unfanned or gone, a
    /// fanned one rung instead) the answer is false, and the card stops
    /// naming a chapter its ring is not on. RED ON OLD by construction (the
    /// field did not exist).
    @Test func theLandmarksSayWhetherTheTouredChapterIsTheNamedOne() throws {
        try withOperations { ops, db in
            #expect(try landmarks(db).firstStoryIsNamed, "no book: the card keeps its words")
            let book = try ops.createReading(name: "the adventures of sherlock holmes", kind: .book)
            func chapter(_ title: String) throws -> (note: String, take: String) {
                let note = try ops.createPost(title: title)
                let block = try ops.newBlock(in: note.id, text: "a line.", at: .end)
                try ops.addPostToReading(note.id, to: book.id)
                return (note.id, try ops.branchVariant(block.block.id, from: block.variant.id).id)
            }
            let early = try chapter("A Case of Identity")
            let scandal = try chapter("A Scandal in Bohemia")
            var found = try landmarks(db)
            #expect(found.firstStoryID == scandal.note && found.firstStoryIsNamed)
            try ops.archiveVariant(scandal.take)
            found = try landmarks(db)
            #expect(found.firstStoryID == early.note)
            #expect(!found.firstStoryIsNamed, "the ring sits on another chapter: say so")
            try ops.deleteContainer(scandal.note)
            #expect(!(try landmarks(db).firstStoryIsNamed))
        }
    }

    /// VX-292 U3 — step 7's block, as the store says it: the PREFERRED block
    /// (the one she made a take of) while it is placed and fanned, else the
    /// note's first placed fanned block, else nil; its SHOWN take resolved as
    /// rendering resolves it (the placement's chosen while it is a live,
    /// active take, else the block's default); the takes in fan order; the
    /// take wearing the card's label. RED ON OLD by construction (no read).
    @Test func theFlipFactsNameTheBlockItsShownTakeAndTheTakeTheCardNames() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "XVII")
            let plain = try ops.newBlock(in: note.id, text: "an opening line.", at: .end)
            let toured = try ops.newBlock(in: note.id, text: "Upon this a question arises.", at: .end)
            let later = try ops.newBlock(in: note.id, text: "Men love at their own will.", at: .end)
            func facts(prefer: String?) throws -> Tour.BlockFacts? {
                try db.read {
                    try Queries.tourFlipFacts(
                        $0, postID: note.id, preferBlockID: prefer, namedLabel: "il principe 1532")
                }
            }
            #expect(try facts(prefer: toured.block.id) == nil, "no fan anywhere: nothing to flip")

            let italian = try ops.branchVariant(toured.block.id, from: toured.variant.id)
            try ops.setTakeLabel(italian.id, label: "il principe 1532")
            let laterTake = try ops.branchVariant(later.block.id, from: later.variant.id)
            var found = try #require(try facts(prefer: toured.block.id))
            #expect(found == Tour.BlockFacts(
                noteID: note.id, blockID: toured.block.id, chosenTakeID: toured.variant.id,
                takeIDs: [toured.variant.id, italian.id], namedTakeID: italian.id))

            // Choosing the Italian: the shown take is it.
            try ops.chooseVariant(toured.block.id, variantID: italian.id)
            found = try #require(try facts(prefer: toured.block.id))
            #expect(found.chosenTakeID == italian.id)

            // An unfanned or unknown preference: the note's first fanned block.
            #expect(try facts(prefer: plain.block.id)?.blockID == toured.block.id)
            #expect(try facts(prefer: nil)?.blockID == toured.block.id)
            #expect(try facts(prefer: "gone")?.blockID == toured.block.id)

            // The Italian archived (out of the fan): the toured block is
            // unfanned, so the next fanned block — and the chosen pointer at
            // an archived take falls back to the block's default.
            try ops.chooseVariant(toured.block.id, variantID: toured.variant.id)
            try ops.archiveVariant(italian.id)
            found = try #require(try facts(prefer: toured.block.id))
            #expect(found.blockID == later.block.id)
            #expect(found.takeIDs == [later.variant.id, laterTake.id])
            #expect(found.namedTakeID == nil, "no take wears the card's label here")
            #expect(found.chosenTakeID == later.variant.id)
        }
    }

    /// **VX-292 ladder round 1 (the MAJOR's final call) — deletion EVIDENCE,
    /// never an edit.** A note deleted while the book held it names its
    /// title; a RELEASED note (its membership dead, the note live) does not;
    /// released and LATER deleted does (no stamp equality — her final act
    /// governs); a renamed-then-deleted note names its NEW title, never the
    /// shipped one; a dismissed arrival was never a membership; a note put
    /// back from the Trash is no longer deleted. RED ON OLD by construction
    /// (the read did not exist: the tour's mend could not tell a deletion
    /// from a rename or a release).
    @Test func deletionEvidenceNamesOnlyNotesDeletedWhileTheBookHeldThem() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "the prince", kind: .book)
            func member(_ title: String) throws -> String {
                let note = try ops.createPost(title: title)
                try ops.addPostToReading(note.id, to: book.id)
                return note.id
            }
            func evidence() throws -> Set<String> {
                try db.read { try Queries.deletedMemberTitles($0, readingID: book.id) }
            }
            let deleted = try member("XVII")
            let released = try member("XVIII")
            let releasedThenDeleted = try member("XIX")
            let renamedThenDeleted = try member("XX")
            let putBack = try member("XXI")
            _ = try member("XXII")   // stands

            try ops.deleteContainer(deleted)
            _ = try ops.removePostFromReading(released, from: book.id)
            _ = try ops.removePostFromReading(releasedThenDeleted, from: book.id)
            try ops.deleteContainer(releasedThenDeleted)
            try ops.renameContainer(renamedThenDeleted, title: "her own title")
            try ops.deleteContainer(renamedThenDeleted)
            try ops.deleteContainer(putBack)
            try ops.restoreContainer(putBack)

            #expect(try evidence() == ["XVII", "XIX", "her own title"],
                    "deleted (directly, or after a release) only; never a release, never a shipped title she renamed away")
            // Another book's deletions are not this book's evidence.
            let other = try ops.createReading(name: "other", kind: .book)
            let elsewhere = try ops.createPost(title: "XXIII")
            try ops.addPostToReading(elsewhere.id, to: other.id)
            try ops.deleteContainer(elsewhere.id)
            #expect(try evidence().contains("XXIII") == false)
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
