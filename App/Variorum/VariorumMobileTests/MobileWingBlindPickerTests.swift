//
//  MobileWingBlindPickerTests.swift
//  VariorumMobileTests
//
//  VM-59 (the VM-55 run, batch 1) — THE WING-BLIND PICKERS, a Bug: pin
//  before fix. Each pin is red on the tree before the fix and green after
//  (the batch record names the commits and the run). Each picker reads its
//  OWN note's or book's wing — never the app's current wing, which differs
//  whenever a note from another wing is open — so the two note pins stand
//  the app in one wing and open a note from the OTHER: a fix that read the
//  current wing would stay red.
//
//  The mechanisms, traced (batch record, VM-59):
//  · note tags — `MobileNoteTagsModel.refresh` read every wing's tags; a
//    tapped suggestion applies BY PATH in the note's wing (`TypedTagPath`),
//    so another wing's path minted a same-path TWIN there;
//  · add to book — `MobileMembershipModel.refresh` listed every wing's
//    books; picking another wing's refuses `crossWingMembership` ("move the
//    note here first", a road the phone lacks);
//  · the gathering picker — `MobileCreateBookModel.loadTags` listed every
//    wing's tags; a picked path the book's wing lacks normalizes to a DEAD
//    rule term (Core resolves a v1 path in the reading's own wing).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-59 — tag suggestions and book pickers stay inside the note's own wing", .serialized)
struct MobileWingBlindPickerTests {
    /// Every tag leaf a stored rule names — a dead term included (its id is
    /// empty), unlike `RuleGrammar.tagIDs`, which skips it.
    private func tagLeaves(_ term: RuleTerm?) -> [String] {
        switch term {
        case .none: return []
        case .and(let ts)?, .or(let ts)?: return ts.flatMap { tagLeaves($0) }
        case .not(let t)?: return tagLeaves(t)
        case .tag(let id)?: return [id]
        case .star?, .legacyProfile?, .legacyEntryDateFrom?, .legacyEntryDateTo?: return []
        }
    }

    /// A note in Work, opened while the app stands in Home: its suggestions
    /// are Work's vocabulary, and tapping every one of them mints nothing —
    /// no twin of a Home-only path appears in Work.
    @Test func aNotesTagSuggestionsReadTheNotesOwnWing() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            #expect(session.wing.currentID == "", "the app stands in Home")
            let model = MobileNoteTagsModel(session: session, postID: world.workNote)
            await model.refresh()
            #expect(model.allTags.map(\.id) == [world.workTrip],
                    "the note's own wing's vocabulary, not the app's and not every wing's")
            #expect(MobileNoteTagsModel.suggestions(model.allTags, typed: "home", applied: []).isEmpty,
                    "a Home-only path is never offered to a Work note")

            for tag in MobileNoteTagsModel.suggestions(
                model.allTags, typed: "", applied: Set(model.applied.map(\.path))
            ) {
                _ = await model.applyTypedPath(tag.path)
            }
            let workPaths = try await db.read { try Queries.allTags($0, wingID: world.work).map(\.path) }
            #expect(workPaths == ["trip"], "a tapped suggestion never mints a twin in the note's wing")
        }
    }

    /// A note in Work, opened while the app stands in Home: the add-to-book
    /// sheet offers Work's books and gatherings only — two books named
    /// "Essays" no longer read identically, and every offer can take the note.
    @Test func theAddToBookSheetListsTheNotesOwnWingsBooks() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let rule = try Queries.SmartQuerySpec(tags: ["trip"]).encodedJSON()
            _ = try session.operations.createReading(name: "Trips", kind: .gathering, querySpec: rule)
            let workGathering = try session.operations.createReading(
                name: "Trips", kind: .gathering, querySpec: rule, wingId: world.work).id
            #expect(session.wing.currentID == "", "the app stands in Home")
            let model = MobileMembershipModel(session: session, postID: world.workNote)
            await model.refresh()
            #expect(model.addableBooks.map(\.id) == [world.workBook],
                    "the note's own wing's books, not every wing's")
            #expect(model.addableSmartBooks.map(\.id) == [workGathering])
            for book in model.addableBooks {
                await model.add(to: book)
            }
            #expect(model.books.map(\.id) == [world.workBook], "every book offered took the note")
        }
    }

    /// The new-book sheet, opened in Work: the gathering's tag picker offers
    /// Work's vocabulary only, so a gathering made from what it offers names
    /// live Work tags and no dead term.
    @Test func theGatheringPickerWritesTermsFromTheBooksOwnWing() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let sheet = MobileCreateBookModel(session: session)
            await sheet.loadTags()
            #expect(sheet.tags.map(\.id) == [world.workTrip],
                    "the picker offers the book's own wing's tags")

            sheet.name = "Trips"
            sheet.kind = .smartFromTags
            sheet.selectedTagPaths = Set(sheet.tags.map(\.path))
            let id = try #require(await sheet.create())
            let reading = try #require(try await db.read { try Reading.fetchOne($0, key: id) })
            #expect(reading.wingId == world.work)
            #expect(tagLeaves(RuleGrammar.decode(reading.querySpec)) == [world.workTrip],
                    "every term the rule names is a live tag of the book's own wing — no dead term")
        }
    }
}
