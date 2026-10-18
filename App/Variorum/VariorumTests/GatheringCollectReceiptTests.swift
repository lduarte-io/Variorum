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
