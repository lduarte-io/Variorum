import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **13i-d U7 — THE WELCOME SHELF, core half** (F-U1-3; the sitting record
/// §7, §17(a), §19). Nothing minted a `role='welcome'` shelf before this unit:
/// 13i-a shipped the column and the R5 keeper repair that converges two
/// seeders' Welcomes (`Sync/Repairs.swift`), and U1 built the shelf ops
/// without a role. `ensureWelcomeShelf` is the seeders' one door — it ADOPTS
/// the shelf the keeper would keep, or mints the role'd one. These pins hold
/// its state transitions and, through the two-device harness, the keeper's
/// letter: the seeders and the repair agree on which shelf is Welcome.
@Suite("The Welcome shelf — adopted or minted (13i-d U7)")
struct WelcomeShelfTests {
    private func liveWelcomes(_ db: AppDatabase, wing: String = "") throws -> [Shelf] {
        try db.read { db in
            try Shelf.fetchAll(
                db,
                sql: """
                    SELECT * FROM shelf WHERE wing_id = ? AND role = 'welcome'
                    AND deleted_at IS NULL ORDER BY id
                    """,
                arguments: [wing])
        }
    }

    private func rawShelf(
        _ db: AppDatabase, id: String, name: String, role: String?, position: String,
        wing: String = ""
    ) throws {
        try db.write { db in
            try db.execute(
                sql: """
                    INSERT INTO shelf (id, wing_id, name, role, position, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, '2026-06-30T00:00:00.000Z', '2026-06-30T00:00:00.000Z')
                    """,
                arguments: [id, wing, name, role, position])
        }
    }

    /// A fresh store: the shelf is minted, named Welcome, wearing the ONE key
    /// the keeper converges on, in Home, at the end of the (empty) strip.
    @Test func aFreshStoreMintsTheRoledWelcomeShelf() throws {
        try withOperations { ops, db in
            let ensured = try ops.ensureWelcomeShelf()
            #expect(ensured.minted)
            #expect(ensured.shelf.name == Operations.welcomeShelfName)
            #expect(ensured.shelf.name == "Welcome", "her §7/§17(a) name")
            #expect(ensured.shelf.role == Operations.welcomeShelfRole)
            #expect(ensured.shelf.role == "welcome", "the R5 keeper's key, exactly")
            #expect(ensured.shelf.wingId == "", "Home holds the seeded books (§7)")
            #expect(try liveWelcomes(db).map(\.id) == [ensured.shelf.id])
            #expect(try db.outboxContains("shelf", ensured.shelf.id),
                    "an ordinary synced row — the keeper can see it")
        }
    }

    /// Idempotent: a second ensure ADOPTS — never a twin.
    @Test func aSecondEnsureAdoptsAndMintsNothing() throws {
        try withOperations { ops, db in
            let first = try ops.ensureWelcomeShelf()
            let second = try ops.ensureWelcomeShelf()
            #expect(!second.minted)
            #expect(second.shelf.id == first.shelf.id)
            #expect(try liveWelcomes(db).count == 1)
        }
    }

    /// A store that already has shelves: Welcome joins at the END of the
    /// strip (her own order is never disturbed by a restore).
    @Test func intoAStoreWithHerShelvesWelcomeJoinsAtTheEnd() throws {
        try withOperations { ops, db in
            _ = try ops.createShelf(name: "Essays")
            _ = try ops.createShelf(name: "Letters")
            _ = try ops.ensureWelcomeShelf()
            let strip = try db.read { try Queries.shelves($0, wingID: "").map(\.name) }
            #expect(strip == ["Essays", "Letters", "Welcome"])
        }
    }

    /// Identity is the ROLE, never the name: a RENAMED Welcome is still
    /// adopted, and a shelf SHE named "Welcome" by hand is never taken over.
    @Test func identityIsTheRoleNeverTheName() throws {
        try withOperations { ops, db in
            let seeded = try ops.ensureWelcomeShelf()
            try ops.renameShelf(seeded.shelf.id, to: "Front Door")
            let again = try ops.ensureWelcomeShelf()
            #expect(!again.minted)
            #expect(again.shelf.id == seeded.shelf.id, "a renamed Welcome is still the seed's")
            #expect(again.shelf.name == "Front Door", "and keeps her name")
        }
        try withOperations { ops, db in
            let hers = try ops.createShelf(name: "Welcome")
            let ensured = try ops.ensureWelcomeShelf()
            #expect(ensured.minted, "a role-less shelf named Welcome is hers, not the seed's")
            #expect(ensured.shelf.id != hers.id)
            let stillHers = try #require(try db.read { try Shelf.fetchOne($0, key: hers.id) })
            #expect(stillHers.role == nil, "and is never stamped with the seed's role")
        }
    }

    /// THE KEEPER'S LETTER, read by the ensure: with two live role'd shelves
    /// (two seeders raced and the repair has not run yet), the SMALLEST id is
    /// adopted — exactly the shelf `convergeWelcomeShelves` keeps.
    @Test func betweenTwoLiveWelcomesTheSmallestIDIsAdopted() throws {
        try withOperations { ops, db in
            try rawShelf(db, id: "BB-welcome", name: "Welcome", role: "welcome", position: "a0")
            try rawShelf(db, id: "AA-welcome", name: "Welcome", role: "welcome", position: "a1")
            let ensured = try ops.ensureWelcomeShelf()
            #expect(!ensured.minted)
            #expect(ensured.shelf.id == "AA-welcome", "the keeper's keep, never a third")
            #expect(try liveWelcomes(db).count == 2, "the ensure repairs nothing — the keeper does")
        }
    }

    /// A tombstoned Welcome is not revived (shelves are not Trash objects,
    /// §18.3): an explicit restore mints a fresh one. Per wing: another
    /// wing's Welcome is never Home's; a dead wing refuses.
    @Test func aDeletedWelcomeIsReplacedAndWingsAreSeparate() throws {
        try withOperations { ops, db in
            let first = try ops.ensureWelcomeShelf()
            try ops.deleteShelf(first.shelf.id)
            let second = try ops.ensureWelcomeShelf()
            #expect(second.minted)
            #expect(second.shelf.id != first.shelf.id)
            #expect(try db.deletedAt("shelf", first.shelf.id) != nil, "the old one stays dead")

            let wing = try ops.createWing(name: "Annex")
            let annex = try ops.ensureWelcomeShelf(wingID: wing.id)
            #expect(annex.minted)
            #expect(annex.shelf.wingId == wing.id)
            #expect(try liveWelcomes(db).map(\.id) == [second.shelf.id], "Home's is untouched")
            #expect(throws: OperationError.wingNotFound(id: "nope")) {
                try ops.ensureWelcomeShelf(wingID: "nope")
            }
        }
    }

    /// **The R5 keeper, end to end through the seeders' own door:** two
    /// devices each ensure a Welcome offline, each shelving a book on it; the
    /// pair meets under sync and converges on ONE Welcome holding both books
    /// — and an ensure on either device afterwards ADOPTS the survivor.
    @Test func twoDevicesEnsuringWelcomeConvergeAndTheEnsureAdoptsTheKeeper() async throws {
        let (a, b, server) = try furniturePair()
        for (client, name) in [(a, "the field guide A"), (b, "the field guide B")] {
            try client.with { ops, _ in
                let welcome = try ops.ensureWelcomeShelf()
                #expect(welcome.minted, "each device correctly saw no Welcome")
                let book = try ops.createReading(name: name, kind: .book)
                try ops.setReadingShelf(book.id, shelf: welcome.shelf.id)
            }
        }
        try await assertFurnitureConverged(a, b, server)
        let keeper = try #require(try a.db.fetchString(
            "SELECT id FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL"))
        for client in [a, b] {
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL") == 1)
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM reading WHERE shelf_id = ? AND deleted_at IS NULL",
                [keeper]) == 2, "both seeded books sit on the keeper")
            let adopted = try client.with { ops, _ in try ops.ensureWelcomeShelf() }
            #expect(!adopted.minted)
            #expect(adopted.shelf.id == keeper, "a later restore adopts the converged Welcome")
        }
    }
}
