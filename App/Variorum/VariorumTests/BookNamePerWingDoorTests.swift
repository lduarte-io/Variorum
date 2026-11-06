//
//  BookNamePerWingDoorTests.swift
//  VariorumTests
//
//  VX-816 (the VX-878 run, batch 3 — the record
//  `notes/plans/fixes/vx-878-book-doors-faces.md`, BATCH 3 RECORD): HER DOORS'
//  BOOK-NAME GUARD CHECKS THE TARGET'S WING. Wings isolate totally, so a name a
//  book of ANOTHER wing wears is free; one a book of the SAME wing wears is
//  still refused, in her E13 words (`BookNameCopy.refusal`). The core half (the
//  one predicate, as surfaces read wings) is `VariorumCoreTests/
//  BookNameGuardPerWingTests`; the wire's is `VariorumMCPTests/
//  MCPBookNamePerWingServerTests`.
//
//  RED ON OLD, per door: every door below is driven through an API that stands
//  on both sides of the fix, so the pre-fix tree runs it — each "another wing"
//  arm refused there (E13's store-wide scan found "Posted" in PlanetLillian).
//

import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withStore<T>(
    _ body: @MainActor (AppDatabase, AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 816))
    } operation: { @MainActor in
        try await body(db, AppSession(database: db))
    }
}

/// PlanetLillian holds "Posted"; Home holds "Letters" — the agent's report's
/// shape ("'posted' in writing was refused because PlanetLillian has 'Posted'").
@MainActor
private struct World {
    let planet: String
    let letters: String

    init(_ session: AppSession) throws {
        let ops = session.operations
        planet = try ops.createWing(name: "PlanetLillian").id
        _ = try ops.createReading(name: "Posted", kind: .book, wingId: planet)
        letters = try ops.createReading(name: "Letters", kind: .book).id
    }
}

private func names(_ db: AppDatabase, inWing wing: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db, sql: "SELECT name FROM reading WHERE deleted_at IS NULL AND wing_id = ? ORDER BY name",
            arguments: [wing])
    }
}

@MainActor
@Suite("VX-816 — her doors' book-name guard checks only the target's wing", .serialized)
struct BookNamePerWingDoorTests {
    /// New Book / New Gathering (the Bookcase's mint, `ReadingsViewModel.create`
    /// — the wing it mints in).
    @Test func newBookChecksTheWingItMintsIn() async throws {
        try await withStore { db, session in
            let world = try World(session)
            let readings = ReadingsViewModel(session: session)

            let made = await readings.create(name: "posted", kind: .book, wingId: "")
            #expect(made != nil, "RED ON OLD: another wing's book never blocks the name — \(readings.lastError ?? "")")
            #expect(readings.lastError == nil)
            let refused = await readings.create(name: "POSTED", kind: .book, wingId: world.planet)
            #expect(refused == nil)
            #expect(readings.lastError == BookNameCopy.refusal(existing: "Posted"), "the same wing's, named")
            #expect(try await names(db, inWing: world.planet) == ["Posted"], "nothing minted there")
        }
    }

    /// Both rename doors (the Bookcase's and the book's own navigator /
    /// Book Settings): the renamed book's OWN wing.
    @Test func theRenameDoorsCheckTheBooksOwnWing() async throws {
        try await withStore { db, session in
            _ = try World(session)
            let readings = ReadingsViewModel(session: session)
            let drafts = try session.operations.createReading(name: "drafts", kind: .book).id

            await readings.rename(drafts, to: "Posted")
            #expect(readings.lastError == nil, "RED ON OLD: \(readings.lastError ?? "")")
            await readings.rename(drafts, to: "letters")
            #expect(readings.lastError == BookNameCopy.refusal(existing: "Letters"))

            let structure = BookStructureModel(session: session, readingID: drafts)
            await structure.rename(to: "posted")
            #expect(structure.lastError == nil, "RED ON OLD: \(structure.lastError ?? "")")
            await structure.rename(to: "LETTERS")
            #expect(structure.lastError == BookNameCopy.refusal(existing: "Letters"))
            #expect(try await names(db, inWing: "") == ["Letters", "posted"])
        }
    }

    /// File ▸ Import… / the Bookcase drop (`DocumentImporter.run` — the wing
    /// it imports into, the current one): the preflight and `importBook`'s own
    /// guard agree.
    @Test func theFolderImportChecksTheWingItImportsInto() async throws {
        try await withStore { db, session in
            _ = try World(session)
            let one = VariorumDocument.NamedDocument(
                fallbackTitle: "", document: try VariorumDocument.parse("{t:\"one\"}\n\nOne."))
            func book(_ name: String) -> DocumentImportItem {
                .book(VariorumDocument.Book(name: name, chapters: [], unfiled: [one]))
            }
            _ = try await DocumentImporter.run([book("posted")], session: session)  // RED ON OLD: refused
            await #expect(throws: OperationError.duplicateBookName(name: "Letters")) {
                _ = try await DocumentImporter.run([book("letters")], session: session)
            }
            #expect(try await names(db, inWing: "") == ["Letters", "posted"])
        }
    }

    /// Duplicate Book… (the source's wing, where `duplicateReading` lands it).
    @Test func duplicateBookChecksTheSourcesWing() async throws {
        try await withStore { db, session in
            _ = try World(session)
            let drafts = try session.operations.createReading(name: "drafts", kind: .book).id
            let offer = DuplicateBookOffer(readingID: drafts, name: "drafts", owned: false)

            let landed = await DuplicateBookDoor.perform(session: session, offer: offer, name: "posted", deep: false)
            if case .refused(let words) = landed { Issue.record("RED ON OLD: \(words)") }
            let refused = await DuplicateBookDoor.perform(session: session, offer: offer, name: "letters", deep: false)
            #expect(refused == .refused(BookNameCopy.refusal(existing: "Letters")))
            #expect(try await names(db, inWing: "") == ["Letters", "drafts", "posted"])
        }
    }

    /// Make a Book from This Gathering… (the gathering's wing).
    @Test func theSpawnChecksTheGatheringsWing() async throws {
        try await withStore { db, session in
            _ = try World(session)
            let gathering = try session.operations.createReading(
                name: "Starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star)).id
            let shelf = ShelfViewModel(session: session)

            let made = await shelf.spawnBook(from: gathering, named: "posted")
            #expect(made != nil, "RED ON OLD: \(shelf.lastError ?? "")")
            let refused = await shelf.spawnBook(from: gathering, named: "LETTERS")
            #expect(refused == nil)
            #expect(shelf.lastError == BookNameCopy.refusal(existing: "Letters"))
            #expect(try await names(db, inWing: "") == ["Letters", "Starred", "posted"])
        }
    }

    /// The membership choice's "New book…" mint (the NOTE's wing — read now
    /// BEFORE the guard).
    @Test func theMembershipMintChecksTheNotesWing() async throws {
        try await withStore { db, session in
            let world = try World(session)
            let home = try session.operations.createPost(title: "an essay")
            let doors = MembershipDoors(session: session)

            let outcome = try await doors.mintAndAdd("posted", postID: home.id)  // RED ON OLD: threw
            #expect(outcome == .added(book: "posted"))
            let elsewhere = try session.operations.createPost(title: "a planet note", wingId: world.planet)
            await #expect(throws: OperationError.duplicateBookName(name: "Posted")) {
                _ = try await doors.mintAndAdd("POSTED", postID: elsewhere.id)
            }
            #expect(try await names(db, inWing: world.planet) == ["Posted"])
        }
    }

    /// A book's filter, saved as a gathering (the book's wing, where
    /// `saveFilterAsGathering` lands it).
    @Test func savingAFilterChecksTheBooksWing() async throws {
        try await withStore { db, session in
            _ = try World(session)
            let drafts = try session.operations.createReading(name: "drafts", kind: .book).id

            let saved = await BookFilterDoor.save(session: session, readingID: drafts, filter: .star, name: "posted")
            #expect(saved != nil, "RED ON OLD: \(session.status.current?.text ?? "")")
            let refused = await BookFilterDoor.save(session: session, readingID: drafts, filter: .star, name: "letters")
            #expect(refused == nil)
            #expect(session.status.current?.text == OpsRefusalCopy.message(
                for: OperationError.duplicateBookName(name: "Letters")))
            #expect(try await names(db, inWing: "") == ["Letters", "drafts", "posted"])
        }
    }
}
