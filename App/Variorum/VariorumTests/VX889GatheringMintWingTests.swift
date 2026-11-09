//
//  VX889GatheringMintWingTests.swift
//  VariorumTests (Mac)
//
//  VX-889 (Bug, Confirmed; the VX-913 run, B2): Settings ▸ Tags' Make a
//  Gathering minted in HOME whatever wing the pane showed. The run record:
//  `notes/plans/fixes/vx-913-freeze-fixes.md`, "B2 RECORD".
//
//  THE MECHANISM (traced at the code): the pane lists the SHOWN wing's
//  vocabulary (`TagsViewModel.shownWing`, R-828-2), but the door handed the
//  sheet PATHS only, and the sheet's mint named no wing — `createReading`'s
//  `wingId` defaults to Home, and `normalizedRuleSpec` resolves the v1 draft's
//  paths against `wing_id = ''`: the gathering landed on Home's Bookcase, its
//  terms Home's same-path twins or dead terms, and the name guard asked
//  Home's books. The checked paths were also never cleared on a switch, so
//  they rode onto another wing's twins.
//
//  RED ON OLD — every arm marked so, on the SEAM commit (the checks on the
//  model and the mint hoisted to `PromoteTagsSheet.mint`, the pre-fix
//  behaviour kept exactly: the mint names Home, the adopt never clears).
//  The behavioural revert is the fix commit's two source files restored from
//  its parent (`TagsViewModel.swift`, `AppSettingsView.swift`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// An in-memory library with deterministic ids and clock.
@MainActor
private func withGatheringWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 889))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-889 — Settings ▸ Tags' Make a Gathering mints in the wing the pane shows", .serialized)
struct VX889GatheringMintWingTests {
    // MARK: - Helpers

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Lets the model's held read deliver until `condition` holds.
    private func settle(until condition: () -> Bool, turns: Int = 150) async {
        for _ in 0..<turns {
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    /// The pane's model, started the way the pane starts it (its keyed task:
    /// the CURRENT wing's vocabulary, adopted with that wing as `shownWing`),
    /// settled on `wingID`'s listing of `paths`.
    private func startedModel(
        _ session: AppSession, in wingID: String, listing paths: Set<String>
    ) async -> (TagsViewModel, Task<Void, Never>) {
        session.wing.switchTo(wingID)
        let model = TagsViewModel(session: session)
        let run = Task { await model.start() }
        await settle(until: { model.shownWing.id == wingID && Set(model.tags.map(\.path)) == paths })
        return (model, run)
    }

    private func attempt(_ body: () async throws -> Reading) async -> Result<Reading, Error> {
        do { return .success(try await body()) } catch { return .failure(error) }
    }

    private func liveReadings(named name: String, _ db: AppDatabase) async throws -> [Reading] {
        try await db.read { db in
            try Reading.fetchAll(
                db, sql: "SELECT * FROM reading WHERE deleted_at IS NULL")
        }.filter { BookNaming.key($0.name) == BookNaming.key(name) }
    }

    // MARK: - A — the row and its rule (RED ON OLD)

    /// In Garden — where Home holds a same-path twin "stars" — checking
    /// "stars" and "moon" mints a gathering ON Garden whose rule's terms are
    /// exactly Garden's two tags.
    @Test func aGatheringMadeInAnotherWingLandsThereWithThatWingsVocabulary() async throws {
        try await withGatheringWorld { session, db in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            let homeStars = try ops.createTag(name: "stars")
            let gardenStars = try ops.createTag(name: "stars", wingID: garden.id)
            let gardenMoon = try ops.createTag(name: "moon", wingID: garden.id)

            let (model, run) = await startedModel(session, in: garden.id, listing: ["moon", "stars"])
            defer { run.cancel() }
            #expect(model.shownWing == .init(id: garden.id, name: "Garden"))

            model.setGatheringCheck("stars", true)
            model.setGatheringCheck("moon", true)
            let request = try #require(model.gatheringRequest())
            #expect(request == .init(wingID: garden.id, paths: ["moon", "stars"]),
                    "the door's snapshot pairs the paths with the wing they were checked in")

            let minted = try await PromoteTagsSheet.mint(
                session, request: request, name: "Night sky", joinAll: false)
            let stored = try #require(try await db.read { try Queries.reading($0, id: minted.id) })
            #expect(stored.kind == .gathering)
            #expect(stored.wingId == garden.id,
                    "RED ON OLD: the gathering landed on Home's Bookcase (wing_id '')")
            let rule = RuleGrammar.decode(stored.querySpec)
            #expect(rule == .or([.tag(gardenMoon.id), .tag(gardenStars.id)]),
                    "RED ON OLD: Home's \"stars\" and a dead term for \"moon\"")
            #expect(!RuleGrammar.tagIDs(of: rule).contains(homeStars.id),
                    "never Home's same-path twin")
        }
    }

    // MARK: - B — the guard asks the mint's wing (RED ON OLD)

    /// A name worn only in HOME mints from Garden; a name worn in GARDEN
    /// refuses in the guard's words and nothing lands in either wing.
    @Test func theNameGuardAsksTheSameWingTheMintLandsIn() async throws {
        try await withGatheringWorld { session, db in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            try ops.createTag(name: "stars", wingID: garden.id)
            _ = try ops.createReading(name: "Night sky", kind: .book)
            _ = try ops.createReading(name: "Orchard log", kind: .book, wingId: garden.id)

            let (model, run) = await startedModel(session, in: garden.id, listing: ["stars"])
            defer { run.cancel() }
            model.setGatheringCheck("stars", true)
            let request = try #require(model.gatheringRequest())

            // Home's "Night sky" does not block Garden (wings isolate — VX-816).
            switch await attempt({
                try await PromoteTagsSheet.mint(session, request: request, name: "night sky", joinAll: false)
            }) {
            case .success(let minted):
                #expect(minted.wingId == garden.id)
            case .failure(let error):
                Issue.record("RED ON OLD: the guard asked Home's books — \(error)")
            }

            // Garden's own "Orchard log" does.
            switch await attempt({
                try await PromoteTagsSheet.mint(session, request: request, name: "orchard LOG", joinAll: false)
            }) {
            case .success(let minted):
                Issue.record("RED ON OLD: a name Garden wears passed and minted in wing '\(minted.wingId)'")
            case .failure(let error):
                #expect(error as? OperationError == .duplicateBookName(name: "Orchard log"))
            }
            let orchards = try await liveReadings(named: "Orchard log", db)
            #expect(orchards.count == 1, "nothing landed in either wing")
            #expect(orchards.first?.wingId == garden.id)
        }
    }

    // MARK: - C — Home is unchanged (the control: GREEN ON BOTH)

    @Test func inHomeTheRowItsRuleAndTheGuardAreAsBefore() async throws {
        try await withGatheringWorld { session, db in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            let homeStars = try ops.createTag(name: "stars")
            try ops.createTag(name: "stars", wingID: garden.id)
            _ = try ops.createReading(name: "Taken", kind: .book)
            _ = try ops.createReading(name: "Elsewhere", kind: .book, wingId: garden.id)

            let (model, run) = await startedModel(session, in: "", listing: ["stars"])
            defer { run.cancel() }
            model.setGatheringCheck("stars", true)
            let request = try #require(model.gatheringRequest())
            #expect(request == .init(wingID: "", paths: ["stars"]))

            let minted = try await PromoteTagsSheet.mint(
                session, request: request, name: "Sky", joinAll: true)
            let stored = try #require(try await db.read { try Queries.reading($0, id: minted.id) })
            #expect(stored.wingId == "")
            #expect(RuleGrammar.decode(stored.querySpec) == .tag(homeStars.id))

            switch await attempt({
                try await PromoteTagsSheet.mint(session, request: request, name: "taken", joinAll: false)
            }) {
            case .success:
                Issue.record("Home's own name must still refuse")
            case .failure(let error):
                #expect(error as? OperationError == .duplicateBookName(name: "Taken"))
            }
            let elsewhere = try await PromoteTagsSheet.mint(
                session, request: request, name: "elsewhere", joinAll: false)
            #expect(elsewhere.wingId == "", "a Garden name never blocks Home")
        }
    }

    // MARK: - D — the checks belong to the listed wing (RED ON OLD)

    /// A listing of ANOTHER wing clears the checks — a Home check never rides
    /// onto Garden's same-path twin — while a re-list of the SAME wing (a new
    /// tag, the wing renamed) keeps them.
    @Test func anotherWingsListingClearsTheChecksTheSameWingsKeepsThem() async throws {
        try await withGatheringWorld { session, _ in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            let homeStars = try ops.createTag(name: "stars")
            let homeMoon = try ops.createTag(name: "moon")
            let gardenStars = try ops.createTag(name: "stars", wingID: garden.id)
            let gardenSun = try ops.createTag(name: "sun", wingID: garden.id)

            let model = TagsViewModel(session: session)
            model.adopt([homeStars], wing: .init(id: "", name: "Home"))
            model.setGatheringCheck("stars", true)

            model.adopt([homeMoon, homeStars], wing: .init(id: "", name: "Home"))
            #expect(model.gatheringChecks == ["stars"], "a re-list of the same wing keeps the checks")

            model.adopt([gardenStars], wing: .init(id: garden.id, name: "Garden"))
            #expect(model.gatheringChecks.isEmpty,
                    "RED ON OLD: Home's check rode onto Garden's same-path twin")
            #expect(model.gatheringRequest() == nil, "nothing to make — the door greys")

            model.setGatheringCheck("stars", true)
            model.adopt([gardenStars, gardenSun], wing: .init(id: garden.id, name: "Orchard"))
            #expect(model.gatheringChecks == ["stars"], "renaming the shown wing is the same wing")
            #expect(model.gatheringRequest() == .init(wingID: garden.id, paths: ["stars"]))
        }
    }

    // MARK: - E — a wing deleted under the sheet (RED ON OLD)

    /// The request names a wing that died while the sheet was up (another
    /// device emptied and deleted it; here, the ops' own road). The mint
    /// refuses in `wingNotFound`'s words and lands NOWHERE — the Bookcase's
    /// New Gathering's posture — never silently in Home.
    @Test func aWingThatDiedUnderTheSheetLandsNowhere() async throws {
        try await withGatheringWorld { session, db in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            try ops.createTag(name: "stars")
            let gardenStars = try ops.createTag(name: "stars", wingID: garden.id)

            let (model, run) = await startedModel(session, in: garden.id, listing: ["stars"])
            model.setGatheringCheck("stars", true)
            let request = try #require(model.gatheringRequest())
            run.cancel()

            try ops.deleteTag(gardenStars.id)
            try ops.deleteWing(garden.id)

            switch await attempt({
                try await PromoteTagsSheet.mint(session, request: request, name: "Night sky", joinAll: false)
            }) {
            case .success(let minted):
                Issue.record("RED ON OLD: minted into wing '\(minted.wingId)' after its wing died")
            case .failure(let error):
                #expect(error as? OperationError == .wingNotFound(id: garden.id))
                #expect(OpsRefusalCopy.message(for: error)
                        == "That library isn't there any more \u{2014} nothing changed.")
            }
            #expect(try await liveReadings(named: "Night sky", db).isEmpty, "nothing landed anywhere")
        }
    }
}
