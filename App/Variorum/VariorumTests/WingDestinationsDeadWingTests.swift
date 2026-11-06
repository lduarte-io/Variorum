//
//  WingDestinationsDeadWingTests.swift
//  VariorumTests
//
//  VX-878 ladder round 1, F1 (the cold review's MINOR; the reviewer's final
//  call: normalize inside `WingsModel.destinations(from:)`). A reading whose
//  stored `wing_id` names a DEAD wing (R-13ia-2's dangling case — a sync race:
//  another device's book landed in a wing this one deleted) reads as Home's on
//  every surface (`Queries.wingScope`, `Queries.effectiveWing`, the model's own
//  `name(of:)`). Its Move to Wing ▸ destinations must read it the same way:
//  Home is where it already lives, so Home is never offered — on the Bookcase
//  row, the Library's book row, Book Settings' wing row and ⌘K's selector
//  alike (all read `destinations(from: reading.wingId)`).
//
//  RED ON OLD: the pre-fix `destinations(from:)` filtered the STORED id over
//  the live rows, so a dead id filtered nothing and Home stayed in the list
//  (`["", studio]`, and `[""]` — a drawn door offering only Home — when no
//  other wing lives).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withDeadWingWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 878))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-878 ladder F1 — a book whose wing died is never offered Home", .serialized)
struct WingDestinationsDeadWingTests {
    /// The guard pin's own fixture shape (`BookNameGuardPerWingTests`): a wing
    /// can only be deleted empty, so the dangling pointer is made by SQL.
    private func orphanInDeadWing(
        _ session: AppSession, _ db: AppDatabase
    ) async throws -> (reading: Reading, deadWing: String) {
        let ops = session.operations
        let attic = try ops.createWing(name: "Attic")
        let orphan = try ops.createReading(name: "Orphan", kind: .book, wingId: attic.id)
        try await db.write { db in
            try db.execute(sql: "UPDATE wing SET deleted_at = ? WHERE id = ?",
                           arguments: ["2026-07-01T00:00:00.000Z", attic.id])
        }
        let reading = try #require(try await db.read { try Queries.reading($0, id: orphan.id) })
        #expect(reading.wingId == attic.id, "the stored pointer dangles")
        #expect(try await db.read { try Queries.effectiveWing($0, ofReading: orphan.id) } == "",
                "surfaces read it as Home's (R-13ia-2)")
        return (reading, attic.id)
    }

    /// With another LIVE wing (so the door IS drawn and the list is non-empty
    /// — the arm that tells "Home wrongly offered" from "no door"): every face
    /// offers that wing alone, never Home.
    @Test func aBookWhoseWingDiedIsOfferedTheOtherWingsButNeverHome() async throws {
        try await withDeadWingWorld { session, db in
            let (reading, dead) = try await orphanInDeadWing(session, db)
            let studio = try session.operations.createWing(name: "Studio")
            let wings = WingsModel(session: session)
            await wings.load()

            // The one heal point every face reads (Bookcase row, Library book
            // row, the note-title menu's WingNoteDoors via the book's wing).
            #expect(wings.destinations(from: reading.wingId).map(\.id) == [studio.id])  // RED ON OLD
            #expect(wings.destinations(from: dead).map(\.id) == wings.destinations(from: "").map(\.id),
                    "a dead id reads exactly as Home's")
            #expect(wings.name(of: dead) == "Home", "the model's own name rule — unchanged")

            // Book Settings' wing row.
            #expect(BookSettingsSheet.wingDestinations(for: reading, wings: wings).map(\.id)
                    == [studio.id])  // RED ON OLD

            // ⌘K's selector (WingDestinationSheet's open + init).
            let selector = try #require(await WingDestinationModel.open(
                .init(act: .moveBook(reading.id), token: UUID()), wings: wings, session: session))
            #expect(selector.brain.rows.map(\.id) == [studio.id])  // RED ON OLD
            #expect(selector.foot.contains("is in Home"))
        }
    }

    /// With NO other live wing, a dead-wing book has nowhere to go: no door is
    /// drawn (P-2) and ⌘K says why instead of opening a list that offers Home.
    @Test func withNoOtherLiveWingTheDoorIsNotDrawn() async throws {
        try await withDeadWingWorld { session, db in
            let (reading, _) = try await orphanInDeadWing(session, db)
            let wings = WingsModel(session: session)
            await wings.load()

            #expect(wings.destinations(from: reading.wingId).isEmpty)  // RED ON OLD ([""])
            #expect(!WingBookMoveDoor.drawn(
                reading: reading, destinations: wings.destinations(from: reading.wingId).count))
            #expect(BookSettingsSheet.wingDestinations(for: reading, wings: wings).isEmpty)
            #expect(await WingDestinationModel.open(
                .init(act: .moveBook(reading.id), token: UUID()), wings: wings, session: session) == nil)
            #expect(session.status.spoken?.text == WingCopy.switchWingUnavailable)
        }
    }

    /// Unchanged by the heal: an EFFECTIVE id — Home's `""` or a live wing's —
    /// lists every other row, Home first.
    @Test func effectiveIdsListEveryOtherWingAsBefore() async throws {
        try await withDeadWingWorld { session, _ in
            let a = try session.operations.createWing(name: "Imports")
            let b = try session.operations.createWing(name: "Work")
            let wings = WingsModel(session: session)
            await wings.load()
            #expect(wings.destinations(from: "").map(\.id) == [a.id, b.id])
            #expect(wings.destinations(from: a.id).map(\.id) == ["", b.id])
        }
    }
}
