//
//  NotePlacingTagsTests.swift
//  VariorumCoreTests
//
//  VX-1038 (the VX-1036 run, batch 2 — her R-1036-34/-39): the per-book tags
//  switch's three positions, and "other tags" leaving off the tags that PLACE a
//  note — the pure rule over `RuleGrammar`'s tree (`NotePlacingTags`), as a
//  table; and the three reads the book's pills and the "+" field stand on
//  (`wornTagRows`, `liveTags`, `tagUseCounts` — VX-576's order key), as exact
//  reads over a real store. A FEATURE, so its pins are a table and state reads.
//

import Foundation
import GRDB
import Testing
@testable import VariorumCore

private typealias Tag = VariorumCore.Tag

@Suite("VX-1038 — the tags switch's three positions and the tags that place a note")
struct NotePlacingTagsTests {
    private static let day = Date(timeIntervalSince1970: 0)

    private func tag(_ id: String, _ path: String, wing: String = "") -> Tag {
        Tag(id: id, name: String(path.split(separator: "/").last ?? ""), path: path, wingId: wing,
            createdAt: Self.day, updatedAt: Self.day)
    }

    // The vocabulary: a week, a project, a nested family, and a twin in
    // another wing.
    private var week: Tag { tag("week", "week") }
    private var monday: Tag { tag("mon", "week/monday") }
    private var tuesday: Tag { tag("tue", "week/tuesday") }
    private var todo: Tag { tag("todo", "todo") }
    private var done: Tag { tag("done", "done") }
    private var video: Tag { tag("video", "video") }
    private var ideas: Tag { tag("ideas", "video/ideas") }
    private var kitchenVideo: Tag { tag("kvideo", "video", wing: "kitchen") }
    private var ruleTags: [String: Tag] {
        Dictionary(uniqueKeysWithValues: [week, monday, tuesday, todo, done, video, ideas, kitchenVideo].map { ($0.id, $0) })
    }

    private func placing(_ rule: RuleTerm, _ worn: [Tag], starred: Bool? = nil) -> Set<String> {
        NotePlacingTags.placing(rules: [rule], worn: worn, ruleTags: ruleTags, starred: starred)
    }

    // MARK: - The rule (pure)

    @Test func aOneTagRuleIsPlacedByThatTagAndNothingElse() {
        #expect(placing(.tag("todo"), [todo, monday]) == ["todo"],
                "the gathering's own tag places the note; monday is another tag")
    }

    @Test func aRuleNamingAFamilyIsPlacedByTheWornTagInsideIt() {
        #expect(placing(.tag("video"), [ideas, todo]) == ["ideas"], "subtree matching: video/ideas places a #video rule")
        #expect(placing(.tag("week"), [monday, tuesday]) == ["mon", "tue"], "every worn tag in the subtree places it")
    }

    @Test func anotherWingsSamePathTwinNeverPlacesANote() {
        #expect(placing(.tag("kvideo"), [video, ideas]).isEmpty,
                "the assembly matches within the term tag's wing (R-13ia-1)")
    }

    @Test func anAnyOfRuleIsPlacedByEveryTagThatSatisfiesIt() {
        let rule = RuleTerm.or([.tag("mon"), .tag("tue")])
        #expect(placing(rule, [monday, tuesday, todo]) == ["mon", "tue"])
        #expect(placing(rule, [tuesday, todo]) == ["tue"])
    }

    @Test func anAllOfRuleIsPlacedByAllItsTags() {
        #expect(placing(.and([.tag("todo"), .tag("week")]), [todo, monday, video]) == ["todo", "mon"])
    }

    @Test func aNotPlacesNothingAndADoubleNotIsItsTag() {
        let rule = RuleTerm.and([.tag("todo"), .not(.tag("done"))])
        #expect(placing(rule, [todo, monday]) == ["todo"], "the not's tag is absent; nothing of the not places")
        #expect(placing(.not(.not(.tag("todo"))), [todo]) == ["todo"], "NOT NOT #todo is #todo")
    }

    @Test func aBranchThatDoesNotHoldPlacesNothing() {
        let rule = RuleTerm.or([.and([.tag("todo"), .tag("done")]), .tag("video")])
        #expect(placing(rule, [todo, video]) == ["video"],
                "(#todo AND #done) fails for a note without #done — its #todo places nothing")
    }

    @Test func theStarAndTheLegacyTermsPlaceNoTag() {
        #expect(placing(.star, [todo], starred: true).isEmpty)
        #expect(placing(.or([.star, .tag("todo")]), [todo], starred: true) == ["todo"])
        #expect(placing(.and([.star, .tag("todo")]), [todo], starred: false).isEmpty,
                "a known un-starred note fails the star's AND: its tag places nothing")
        #expect(placing(.and([.star, .tag("todo")]), [todo]) == ["todo"],
                "the star unknown (a book's entries do not carry it): never blocks")
        #expect(placing(.and([.legacyProfile("journal"), .tag("todo")]), [todo]) == ["todo"],
                "an unknown legacy term neither holds nor fails — it never blocks the tag the rest supports")
        let known = NotePlacingTags.placing(
            rules: [.and([.legacyProfile("journal"), .tag("todo")])], worn: [todo], ruleTags: ruleTags,
            legacy: { _ in false })
        #expect(known.isEmpty, "a legacy term the caller knows fails: the branch places nothing")
    }

    @Test func aDeadTermMatchesNothing() {
        #expect(placing(.tag(""), [todo]).isEmpty)
        #expect(placing(.tag("gone"), [todo]).isEmpty, "a term tag absent from the live rule tags")
    }

    @Test func severalRulesPlaceByTheirUnion() {
        // A lane (VX-1085) beside the gathering's own rule.
        let both = NotePlacingTags.placing(
            rules: [.tag("todo"), .tag("mon")], worn: [todo, monday, video], ruleTags: ruleTags)
        #expect(both == ["todo", "mon"])
    }

    // MARK: - The switch (pure)

    @Test func theSwitchHasThreePositionsHiddenFirst() {
        #expect(BookTagsShown.allCases == [.hidden, .otherTags, .allTags])
        #expect(BookTagsShown.initial == .hidden, "T-5: hidden by default")
        #expect(BookTagsShown(stored: nil) == .hidden)
        #expect(BookTagsShown(stored: "nonsense") == .hidden, "a way of looking never refuses")
        for position in BookTagsShown.allCases {
            #expect(BookTagsShown(stored: position.rawValue) == position, "\(position) round-trips")
        }
    }

    @Test func eachPositionDrawsItsPills() {
        let worn = [todo, monday, video]
        #expect(BookTagsShown.hidden.pills(worn: worn, placing: ["todo"], id: \.id) == nil,
                "hidden: no pills and no +")
        #expect(BookTagsShown.allTags.pills(worn: worn, placing: ["todo"], id: \.id)?.map(\.id) == ["todo", "mon", "video"])
        #expect(BookTagsShown.otherTags.pills(worn: worn, placing: ["todo"], id: \.id)?.map(\.id) == ["mon", "video"],
                "other tags leaves off the tags that place the note, in their order")
        #expect(BookTagsShown.otherTags.pills(worn: worn, placing: [], id: \.id)?.map(\.id) == ["todo", "mon", "video"],
                "in a plain book (nothing places) the middle position shows everything")
        #expect(BookTagsShown.allTags.pills(worn: [Tag](), placing: [], id: \.id) == [], "a tagless note: the + alone")
    }

    // MARK: - The reads (exact, over a real store)

    @Test func theCardsReadEachNotesOwnLiveTagsAsRows() throws {
        try withOperations { ops, db in
            let a = try ops.createPost(title: "A")
            let b = try ops.createPost(title: "B")
            let c = try ops.createPost(title: "C")
            let zed = try ops.createTag(name: "zed")
            let alpha = try ops.createTag(name: "alpha")
            let gone = try ops.createTag(name: "gone")
            try ops.applyTag(zed.id, toPost: a.id)
            try ops.applyTag(alpha.id, toPost: a.id)
            try ops.applyTag(gone.id, toPost: b.id)
            try ops.applyTag(alpha.id, toPost: b.id)
            try ops.removeTag(alpha.id, fromPost: b.id)          // a taken-off application
            try ops.deleteTag(gone.id)                            // a dead tag
            let rows = try db.read { try Queries.wornTagRows($0, noteIDs: [a.id, b.id, c.id]) }
            #expect(rows[a.id]?.map(\.path) == ["alpha", "zed"], "by path, as rows")
            #expect(rows[b.id] == nil, "a removed application and a dead tag are not worn")
            #expect(rows[c.id] == nil, "a note wearing none is absent")
            #expect(try db.read { try Queries.wornTagRows($0, noteIDs: []) }.isEmpty)
        }
    }

    @Test func theRulesTagsAreReadLiveByID() throws {
        try withOperations { ops, db in
            let week = try ops.createTag(name: "week")
            let gone = try ops.createTag(name: "gone")
            try ops.deleteTag(gone.id)
            let live = try db.read { try Queries.liveTags($0, ids: [week.id, gone.id, "missing"]) }
            #expect(live.map(\.id) == [week.id], "missing and tombstoned ids are absent")
        }
    }

    @Test func theUseCountsAreLiveNotesWearingEachTagInTheWing() throws {
        try withOperations { ops, db in
            let notes = try (0..<4).map { try ops.createPost(title: "note \($0)") }
            let often = try ops.createTag(name: "often")
            let once = try ops.createTag(name: "once")
            let never = try ops.createTag(name: "never")
            for note in notes.prefix(3) { try ops.applyTag(often.id, toPost: note.id) }
            try ops.applyTag(once.id, toPost: notes[3].id)
            try ops.applyTag(once.id, toPost: notes[0].id)
            try ops.removeTag(once.id, fromPost: notes[0].id)    // taken off: not a use
            try ops.deleteContainer(notes[2].id)                 // a dead note's application: not a use
            let counts = try db.read { try Queries.tagUseCounts($0, wingID: "") }
            #expect(counts[often.id] == 2)
            #expect(counts[once.id] == 1)
            #expect(counts[never.id] == nil, "no live note wears it")
            let elsewhere = try ops.createWing(name: "Kitchen")
            #expect(try db.read { try Queries.tagUseCounts($0, wingID: elsewhere.id) }.isEmpty,
                    "another wing's vocabulary counts nothing of Home's")
        }
    }
}
