//
//  GatheringCollectReceiptTests.swift
//  VariorumTests
//
//  VX-241 (Part of VX-381) — R98's add-by-tagging receipt overclaimed on an
//  ARCHIVED gathering.
//
//  THE MECHANISM (traced): the membership chip's add picker offers every
//  open gathering the note isn't in, archived ones included (13i-e: explicit
//  adds stay open — `MembershipChip.refresh` filters kind and lock only), and
//  `collectPostIntoSmartReading` applies the tags without reading the
//  archive. The chip then said "Added by tagging #… — “X” collects by
//  filter." (and the Bookcase's drop, "…the gathering shows it now.") while
//  the archived gathering assembled EMPTY everywhere. The tags are right;
//  only the receipt's claim was false.
//
//  THE FIX: the op reports the gathering's archived state from inside its
//  transaction (`SmartCollectResult.gatheringArchived`), and both Mac doors
//  decide their words from it: an archived target says the honest thing —
//  tagged, and the gathering shows it once it's unarchived (PROVISIONAL
//  wording). Red on old by behavioural revert (the deciders ignoring the
//  fact), recorded in the run file.
//

import Dependencies
import Foundation
import Testing
@testable import Variorum
import VariorumCore

@Suite("R98's receipt is honest on an archived gathering (VX-241)")
struct GatheringCollectReceiptTests {
    private func withOps(_ body: (Operations) throws -> Void) throws {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            try body(Operations())
        }
    }

    /// The archived target, through the real op: both doors' receipts say the
    /// tags landed and that the gathering shows the note once unarchived —
    /// never "shows it now", never "collects".
    @Test func anArchivedGatheringsCollectSaysItShowsOnceUnarchived() throws {
        try withOps { ops in
            let essays = try ops.createTag(name: "essays")
            let gathering = try ops.createReading(
                name: "put away", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(essays.id)))
            try ops.archiveReading(gathering.id)
            let note = try ops.createPost(title: "a piece")

            let tagged = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            let honest = "Tagged #essays \u{2014} the gathering shows it once it's unarchived."
            #expect(AddToBookCopy.collected(tagged, gatheringName: gathering.name) == honest)
            #expect(BookcaseCopy.collectReceipt(tagged) == honest)

            let again = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            let already = "It already matches \u{2014} the gathering shows it once it's unarchived."
            #expect(AddToBookCopy.collected(again, gatheringName: gathering.name) == already)
            #expect(BookcaseCopy.collectReceipt(again) == already)

            for line in [honest, already] {
                #expect(!line.contains("shows it now") && !line.contains("collect"), "\(line)")
            }
        }
    }

    /// The guard: a live gathering's receipts are what each door said
    /// before (the chip's shipped words; the board's P-VX381-1 register).
    @Test func aLiveGatheringKeepsEachDoorsWords() throws {
        try withOps { ops in
            let essays = try ops.createTag(name: "essays")
            let gathering = try ops.createReading(
                name: "open", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(essays.id)))
            let note = try ops.createPost(title: "a piece")

            let tagged = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            #expect(AddToBookCopy.collected(tagged, gatheringName: "open")
                    == "Added by tagging #essays \u{2014} \u{201C}open\u{201D} collects by filter.")
            #expect(BookcaseCopy.collectReceipt(tagged) == BookcaseCopy.shownByTagging(["essays"]))

            let again = try ops.collectPostIntoSmartReading(note.id, into: gathering.id)
            #expect(AddToBookCopy.collected(again, gatheringName: "open")
                    == "Already collected \u{2014} it matches \u{201C}open\u{201D}'s filter.")
            #expect(BookcaseCopy.collectReceipt(again) == BookcaseCopy.alreadyShowing)
        }
    }
}

/// VX-249 (Part of VX-381) — the collect door now SETS the star a rule needs
/// (her answer to the star asymmetry, QUESTIONS #217), and the receipt NAMES
/// it: the mint's family verbatim on a live gathering (R-VX381-A5 — both Mac
/// doors), and that family's head with VX-241's honest tail on an archived
/// one. Red on old by behavioural revert (the deciders ignoring `starred`:
/// the board said "Tagged  — …" with no tag and no star), recorded in the run
/// file.
@Suite("R98's receipt names the star it set (VX-249)")
struct GatheringCollectStarReceiptTests {
    private func withOps(_ body: (Operations) throws -> Void) throws {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            try body(Operations())
        }
    }

    @Test func aStarSetCollectNamesTheStarOnBothDoors() throws {
        try withOps { ops in
            let essays = try ops.createTag(name: "essays")
            let starOnly = try ops.createReading(
                name: "starred things", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let both = try ops.createReading(
                name: "starred essays", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(essays.id), .star])))

            let starred = try ops.collectPostIntoSmartReading(
                try ops.createPost(title: "one").id, into: starOnly.id)
            #expect(starred.starred)
            #expect(BookcaseCopy.collectReceipt(starred) == "Starred \u{2014} the gathering shows it now.")
            #expect(AddToBookCopy.collected(starred, gatheringName: starOnly.name)
                    == "Starred \u{2014} the gathering shows it now.")

            let tagged = try ops.collectPostIntoSmartReading(
                try ops.createPost(title: "two").id, into: both.id)
            let line = "Tagged #essays and starred \u{2014} the gathering shows it now."
            #expect(BookcaseCopy.collectReceipt(tagged) == line)
            #expect(AddToBookCopy.collected(tagged, gatheringName: both.name) == line)
            #expect(line == BookcaseCopy.shownByMint(["essays"], starred: true),
                    "the mint's own family, word for word")
        }
    }

    @Test func anArchivedStarCollectNamesTheStarWithTheHonestTail() throws {
        try withOps { ops in
            let essays = try ops.createTag(name: "essays")
            let starOnly = try ops.createReading(
                name: "starred things", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let both = try ops.createReading(
                name: "starred essays", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.tag(essays.id), .star])))
            try ops.archiveReading(starOnly.id)
            try ops.archiveReading(both.id)

            let starred = try ops.collectPostIntoSmartReading(
                try ops.createPost(title: "one").id, into: starOnly.id)
            let quiet = "Starred \u{2014} the gathering shows it once it's unarchived."
            #expect(BookcaseCopy.collectReceipt(starred) == quiet)
            #expect(AddToBookCopy.collected(starred, gatheringName: starOnly.name) == quiet)

            let tagged = try ops.collectPostIntoSmartReading(
                try ops.createPost(title: "two").id, into: both.id)
            let line = "Tagged #essays and starred \u{2014} the gathering shows it once it's unarchived."
            #expect(BookcaseCopy.collectReceipt(tagged) == line)
            #expect(AddToBookCopy.collected(tagged, gatheringName: both.name) == line)
        }
    }

    /// **Ladder r1 F-7 (NIT) — RED ON OLD.** The archived arm's head fell back
    /// to "Tagged " when the act wore nothing, building "Tagged  — the
    /// gathering shows it once it's unarchived." (a double space, and a tag
    /// that was never applied), while the live arm's same case says "Added to
    /// the gathering." Unreachable through the op today (an empty plan that
    /// isn't already met is a planner/belt disagreement, and the belt throws);
    /// the family now agrees on the empty case: the bare "Added" head
    /// (PROVISIONAL wording).
    @Test func anArchivedCollectThatWoreNothingNeverClaimsATag() {
        let line = BookcaseCopy.taggedWhileArchived([], starred: false)
        #expect(line == "Added \u{2014} the gathering shows it once it's unarchived.")
        #expect(!line.contains("Tagged"), "\(line)")
        #expect(!line.contains("  "), "no double space: \(line)")
    }
}
