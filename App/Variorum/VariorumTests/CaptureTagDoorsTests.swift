//
//  CaptureTagDoorsTests.swift
//  VariorumTests
//
//  VX-1078 (the VX-1036 run, batch 4) — the tag button beside the title
//  suggestion, AT BOTH MAC CAPTURE DOORS (the new-note box's model,
//  `QuickEntryModel`, and the menu-bar pad's, `QuickNotePad`), driven end to
//  end through the REAL `importPost` and the REAL tag road against a real
//  in-memory store: a filed capture wears the picked tags through the one
//  application road (an existing tag adopted by path, a new one minted with its
//  parents), a living book hears the birth and seats the note, a capture's own
//  `{#…}` tokens apply first and unchanged, only what filed is cleared, a
//  refusal keeps the picks, the pad's picks adopt-or-mint in the LANDING wing,
//  and a refused pad capture parks its picks with its words. The pure half is
//  `CaptureTagPicksTests`.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1078 — tags picked on a capture door, filed through the one road", .serialized)
struct CaptureTagDoorsTests {
    private func withWorld<T>(
        seed: UInt64, _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // A living book's seat places through the fractional index's
            // generator — provided the house way.
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// The note's tags: path → (id, wing).
    private func worn(_ db: AppDatabase, _ postID: String) async throws -> [String: VariorumCore.Tag] {
        try await db.read { db in
            Dictionary(uniqueKeysWithValues: try Queries.postTags(db, postID: postID).map { ($0.path, $0) })
        }
    }

    // MARK: - The new-note box (both hosts render the one bar)

    /// **The filing wears the picks through the one road**: an existing tag is
    /// ADOPTED by path (the same row), a new nested path is MINTED with its
    /// missing parent — the typed-path rule a token rides — and the box clears
    /// its words, its title decision and the picks that filed.
    @Test func theBoxFilesANoteWearingThePickedTags() async throws {
        try await withWorld(seed: 1078) { session, db in
            let travel = try session.operations.createTag(name: "travel")
            let box = QuickEntryModel(session: session)
            box.text = "Ring the ferry office about the bike"
            box.tagPicks.add("travel")
            box.tagPicks.add("errands/calls")

            let noteID = try #require(await box.submit())
            let tags = try await worn(db, noteID)

            #expect(Set(tags.keys) == ["travel", "errands/calls"])
            #expect(tags["travel"]?.id == travel.id, "the existing tag adopted — never a twin")
            let all = try await db.read { try Queries.allTags($0, wingID: "").map(\.path) }
            #expect(all.contains("errands"), "the missing parent minted on the way (the typed-path road)")
            #expect(box.text.isEmpty && box.tagPicks.isEmpty, "a completed hand-off clears the box and its picks")
            #expect(session.status.spoken?.kind != .refusal, "nothing refused")
        }
    }

    /// **A living book hears the birth**: a book whose rule names #week seats
    /// the note the picked tag went on — the one application road, the same
    /// intake a typed `{#week}` or the masthead's field would wake.
    @Test func aLivingBookHearsAPickedTagAndSeatsTheNote() async throws {
        try await withWorld(seed: 1079) { session, db in
            let week = try session.operations.createTag(name: "week")
            let spec = try #require(try RuleGrammar.encode(.tag(week.id)))
            let living = try session.operations.createReading(name: "this week", kind: .book, querySpec: spec)
            let box = QuickEntryModel(session: session)
            box.text = "Call the plumber"
            box.tagPicks.add("week")

            let noteID = try #require(await box.submit())
            let seated = try await db.read { try Queries.assembleReading($0, readingID: living.id).map(\.postID) }
            #expect(seated == [noteID], "the living book seated the note its picked tag went on")
        }
    }

    /// **The microsyntax at the door, untouched**: the capture's own tokens
    /// apply first and exactly as before (the title from `{t:"…"}`, the tokens
    /// gone from the text), and a pick a token already named is no second
    /// application and no refusal.
    @Test func theTokensStillApplyAndAPickTheyNamedIsNotAppliedTwice() async throws {
        try await withWorld(seed: 1080) { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "{t:\"Ocean dream\"} Had a weird dream about the ocean {#dream}"
            box.tagPicks.add("dream")
            box.tagPicks.add("sleep")

            let noteID = try #require(await box.submit())
            let (title, text) = try await db.read { db in
                (try Queries.containerHeader(db, containerID: noteID)?.title,
                 try Queries.renderPost(db, containerID: noteID).compactMap(\.text)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            }
            #expect(title == "Ocean dream")
            #expect(text == ["Had a weird dream about the ocean"], "the tokens gone, as always")
            #expect(Set(try await worn(db, noteID).keys) == ["dream", "sleep"])
            #expect(session.status.spoken?.kind != .refusal, "no tag refused")
        }
    }

    /// **Only what filed is cleared** — a pick made while the mint was in the
    /// air is not on that note and stays for the next one (the box's own
    /// clear-only-what-minted rule, VX-928's flight).
    @Test func aPickMadeDuringTheFlightStaysForTheNextNote() async throws {
        try await withWorld(seed: 1081) { session, db in
            let box = QuickEntryModel(session: session)
            box.mint = { text, title in
                box.tagPicks.add("later")
                return try session.operations.importPost(title: title, text: text).container.id
            }
            box.text = "First thought"
            box.tagPicks.add("first")

            let noteID = try #require(await box.submit())
            #expect(Set(try await worn(db, noteID).keys) == ["first"], "the filing read its picks at the press")
            #expect(box.tagPicks.paths == ["later"], "the pick made in the flight is kept")
        }
    }

    /// **A refusal keeps the picks** with her words and her title decision —
    /// a second ⏎ must do what the first was asked to.
    @Test func aRefusedFilingKeepsThePicks() async throws {
        try await withWorld(seed: 1082) { session, _ in
            let box = QuickEntryModel(session: session)
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            box.text = "the paragraph she just wrote"
            box.tagPicks.add("travel")

            #expect(await box.submit() == nil)
            #expect(box.text == "the paragraph she just wrote")
            #expect(box.tagPicks.paths == ["travel"], "the picks are still in front of her")
        }
    }

    /// An empty box files nothing — and lets go of its picks with its words
    /// (the title decision's own empty branch).
    @Test func anEmptyBoxFilesNothingAndForgetsItsPicks() async throws {
        try await withWorld(seed: 1083) { session, _ in
            let box = QuickEntryModel(session: session)
            box.tagPicks.add("travel")
            #expect(await box.submit() == nil)
            #expect(box.tagPicks.isEmpty)
        }
    }

    // MARK: - The menu-bar pad

    /// The pad's filing wears the picks beside its own #quicknote (untouched).
    @Test func thePadFilesItsNoteWearingThePicksBesideItsQuicknoteTag() async throws {
        try await withWorld(seed: 1084) { session, db in
            let pad = QuickNotePad(session: session)
            pad.text = "Buy string for the bean poles"
            pad.tagPicks.add("tools")

            let noteID = try #require(await pad.fileExplicitly().postID)
            #expect(Set(try await worn(db, noteID).keys) == [Operations.quicknoteTagPath, "tools"])
            #expect(pad.text.isEmpty && pad.tagPicks.isEmpty)
        }
    }

    /// **A redirected capture's tags adopt-or-mint in the LANDING wing**
    /// (R-13ia-1's class — the per-wing vocabulary): Home has #garden, the pad
    /// is aimed at Fieldwork, and the note wears FIELDWORK's own #garden —
    /// minted there, a different row — while Home's is untouched.
    @Test func aRedirectedCapturesTagsAreTheLandingWings() async throws {
        try await withWorld(seed: 1085) { session, db in
            let homeGarden = try session.operations.createTag(name: "garden")
            let fieldwork = try await session.runner.run { try $0.createWing(name: "Fieldwork") }
            let pad = QuickNotePad(session: session)
            pad.landingWingID = fieldwork.id
            pad.text = "Soil sample from the far bed"
            pad.tagPicks.add("garden")

            let noteID = try #require(await pad.fileExplicitly().postID)
            let garden = try #require(try await worn(db, noteID)["garden"])
            #expect(garden.wingId == fieldwork.id, "the landing wing's own tag")
            #expect(garden.id != homeGarden.id, "never Home's row")
            let homeGardens = try await db.read { try Queries.allTags($0, wingID: "").filter { $0.path == "garden" } }
            #expect(homeGardens.map(\.id) == [homeGarden.id], "Home's vocabulary untouched")
        }
    }

    /// **A refused pad capture parks its picks** with its words, and the next
    /// summon restores the pills.
    @Test func aRefusedPadCaptureParksItsPicksAndTheNextSummonRestoresThem() async throws {
        try await withWorld(seed: 1086) { session, _ in
            let pad = QuickNotePad(session: session)
            pad.mint = { _, _ in .refused(QuickNoteCopy.refusal(for: OperationError.lockedPost(id: "c1"))) }
            pad.text = "Keep this"
            pad.tagPicks.add("errands")
            pad.tagPicks.add("travel")

            #expect(await pad.close() == .refused(QuickNoteCopy.refusal(for: OperationError.lockedPost(id: "c1"))))
            #expect(session.quickNotePark.held?.tagPaths == ["errands", "travel"])

            let next = QuickNotePad(session: session)
            next.restoreParkedCapture()
            #expect(next.text == "Keep this")
            #expect(next.tagPicks.paths == ["errands", "travel"], "the pills come back with the words")
        }
    }
}
