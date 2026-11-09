//
//  TrashObservationP2Tests.swift
//  VariorumCoreTests
//
//  VX-670 (the VX-678 run, Unit 3, part B) — WHEN the open Trash re-reads
//  itself. Her words: *"i click delete, then delete now, nothing happens for a
//  long time."*
//
//  The traced mechanism (`notes/plans/fixes/vx-678-trash-purge-resurrection.md`,
//  Unit 3): `AppDatabase.observe { }` is GRDB's `tracking` mode, which re-runs
//  the fetch SYNCHRONOUSLY ON THE WRITER CONNECTION inside every commit that
//  touches its region. The Mac's open Trash holds two such observations of
//  `Queries.trash`, so every write — her Put back, her Delete Now's intent,
//  the local sweep's family write, an autosave anywhere — returned only after
//  the Trash re-read itself twice (5.5 s per write at 600 seam rounds before
//  the A-678-1 rewrite made the read itself linear). `observeTrash` now names
//  its tables (`Queries.trashTables`, `observe(tracking:)`): GRDB re-fetches
//  on a READER after the commit and the write answers at once (P2).
//
//  · `aWriteWhileTheTrashIsOpenNeverPaysForItsListing` — RED ON OLD: the
//    writer connection's VM work for one autosave, Trash open vs closed.
//  · `theTrashsNamedTablesAreExactlyTheTablesItReads` — the region is
//    COMPLETE (a table read and not named would leave the open Trash stale on
//    its writes) and EXACT (a table named and not read wakes it for nothing),
//    against the regions GRDB itself derives from every statement the fetch
//    runs, every arm and every wing fence exercised.
//  · `theOpenTrashFollowsEveryActStill` — the liveness guard: the held
//    listing still answers each kind of act. Green on both sides by design —
//    it guards the change, it does not prove it.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

// MARK: - Helpers

private final class Counter: @unchecked Sendable { var value = 0 }

/// Starts counting every VM instruction the WRITER connection executes;
/// the returned closure stops and answers.
private func countWriter(_ db: AppDatabase) throws -> () throws -> Int {
    let counter = Counter()
    let context = Unmanaged.passRetained(counter).toOpaque()
    try db.writeWithoutTransaction { database in
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<Counter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
    }
    return {
        try db.writeWithoutTransaction { database in
            sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil)
        }
        Unmanaged<Counter>.fromOpaque(context).release()
        return counter.value
    }
}

// The held listings ride `HeldValues` ON THE OBSERVATION LANE
// (`Support/ObservationLane.swift`, VX-926 U3 — VX-625). Until then this file
// held them on a private poll with a 300 s ceiling, raised from 30 s after the
// first whole-package run saw the ceiling expire before a held listing's
// first value arrived (the test took 288 s; green in isolation in 1.3 s): the
// value was waiting on the cooperative pool's queue behind every test not yet
// started, which a ceiling cannot outlast. On the lane the delivery is
// milliseconds and the harness's one 30 s bound is ample.

/// The kinds the Mac's Trash lists (`TrashScope.listedKinds`, app-side).
private let listedKinds: Set<Queries.TrashItem.Kind> = [
    .note, .book, .block, .snippetGroup, .preservedOriginal,
]

/// An ON-DISK store (a `DatabasePool` — the app's shape; GRDB's in-memory
/// queue fetches every observation on its one connection either way, so it
/// cannot tell the two modes apart) in the harness's deterministic world.
private func withOnDiskOperations<T: Sendable>(
    _ body: (Operations, AppDatabase) async throws -> T
) async throws -> T {
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("vx670-p2-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: dir) }
    let db = try AppDatabase.onDisk(url: dir.appendingPathComponent("p2.sqlite"), key: nil)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
    } operation: {
        try await body(Operations(), db)
    }
}

private let seamText = "Paragraph seam has words. And a second sentence follows here."

/// A note whose paragraph went through `rounds` seam rounds; its placed block
/// is then deleted, so the Trash lists a stranded original whose lineage the
/// listing's fetch walks.
private func seamNoteDeleted(_ ops: Operations, rounds: Int) throws {
    let note = try ops.createPost(title: "the seam note")
    var seam = try ops.seedBlock(in: note.id, text: seamText).block.id
    for _ in 0..<rounds {
        let divided = try ops.divide(seam, cut: 24)
        seam = try ops.merge(seam, divided.block.id, joining: .deleteKeystroke).block.id
    }
    try ops.deleteBlock(seam)
}

@Suite("VX-670 — the open Trash never makes a write wait for it", .serialized)
struct TrashObservationP2Tests {

    /// **RED ON OLD.** One autosave in another note, with the Trash closed and
    /// then open (both of `RecoveryView`'s observations held, exactly as the
    /// Mac starts them), over a small Trash and one six times its lineage:
    /// what the open Trash adds to the WRITER connection's work must not grow
    /// with what the Trash holds — the listing is re-read on a reader. (What
    /// it does add is GRDB's constant snapshot handshake for the concurrent
    /// read, ~80 instructions; one re-read of this Trash is tens of
    /// thousands.) Old: the writer re-ran `Queries.trash` for each held
    /// observation inside the autosave's commit.
    @Test func aWriteWhileTheTrashIsOpenNeverPaysForItsListing() async throws {
        func writerWork(trashOpen: Bool, rounds: Int) async throws -> Int {
            try await onTheObservationLane {
                try await withOnDiskOperations { ops, db in
                    try seamNoteDeleted(ops, rounds: rounds)
                    let elsewhere = try ops.createPost(title: "elsewhere")
                    let typed = try ops.seedBlock(in: elsewhere.id, text: "alpha beta")
                    let now = Date(timeIntervalSince1970: 1_782_864_000 + 86_400)
                    var held: [HeldValues<[Queries.TrashItem]>] = []
                    if trashOpen {
                        let listing = HeldValues(db.observeTrash(
                            now: now, kinds: listedKinds, oldestFirst: false, limit: 501, wingID: ""))
                        let total = HeldValues(db.observeTrash(
                            now: now, kinds: listedKinds, oldestFirst: false, limit: 1, wingID: ""))
                        held = [listing, total]
                        #expect(try await listing.latest(where: { $0.contains { $0.kind == .preservedOriginal } }) != nil)
                        #expect(try await total.latest(where: { $0.count == 1 }) != nil)
                    }
                    let stop = try countWriter(db)
                    try ops.autosave(typed.variant.id, text: "alpha gamma", charDelta: 5)
                    let work = try stop()
                    held.forEach { $0.cancel() }
                    return work
                }
            }
        }
        var added: [Int] = []
        for rounds in [10, 60] {
            let closed = try await writerWork(trashOpen: false, rounds: rounds)
            let open = try await writerWork(trashOpen: true, rounds: rounds)
            print("VX-670 one autosave's writer VM instructions (\(rounds) seam rounds in the Trash): "
                  + "Trash closed \(closed), Trash open \(open)")
            added.append(open - closed)
        }
        #expect(added[1] <= added[0] + 50,
                "the open Trash's added writer work grew with the Trash: \(added[0]) → \(added[1])")
        #expect(added.allSatisfy { $0 < 500 },
                "the open Trash added \(added) VM instructions to one write on the writer")
    }

    /// The named region against the regions GRDB derives from every
    /// statement `Queries.trash` runs — every kind (a saved version among the
    /// notes, so the peer lookup runs; a book; a snippet group; a block; a
    /// take; a stranded original) under every wing fence (nil, Home, a wing).
    @Test func theTrashsNamedTablesAreExactlyTheTablesItReads() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Far")
            let note = try ops.createPost(title: "note")
            _ = try ops.newBlock(in: note.id, text: "Kept.")
            let version = try ops.saveNoteVersion(note.id)
            try ops.deleteContainer(version.post.id)
            let gone = try ops.createPost(title: "gone", wingId: wing.id)
            try ops.deleteContainer(gone.id)
            let pool = try ops.createPool()
            try ops.deleteContainer(pool.id)
            let book = try ops.createReading(name: "a book", kind: .book)
            try ops.deleteReading(book.id)
            // A take deleted on its own lists only while its block lives.
            let kept = try ops.newBlock(in: note.id, text: "A block that stays.")
            let take = try ops.branchVariant(kept.block.id, from: kept.variant.id)
            try ops.deleteVariant(take.id)
            let fanned = try ops.newBlock(in: note.id, text: "Alpha one. Beta one.")
            let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            let block = try ops.newBlock(in: note.id, text: "A block.")
            try ops.deleteBlock(block.block.id)

            let (region, kindsSeen): (DatabaseRegion, Set<Queries.TrashItem.Kind>) = try db.read { database in
                let captured = LockIsolated<[String]>([])
                let capturing = LockIsolated(true)
                database.trace(options: .statement) { event in
                    guard capturing.value, case .statement(let statement) = event else { return }
                    let sql = statement.sql
                    captured.withValue { $0.append(sql) }
                }
                var seen: Set<Queries.TrashItem.Kind> = []
                for wingID in [nil, "", wing.id] as [String?] {
                    seen.formUnion(try Queries.trash(
                        database, now: harnessNow, kinds: Set(Queries.TrashItem.Kind.allCases),
                        limit: 501, wingID: wingID).map(\.kind))
                }
                capturing.setValue(false)
                var region = DatabaseRegion()
                for sql in captured.value {
                    region = region.union(try database.makeStatement(sql: sql).databaseRegion)
                }
                return (region, seen)
            }
            #expect(kindsSeen == Set(Queries.TrashItem.Kind.allCases),
                    "every arm answered something, so every arm's statement ran: \(kindsSeen)")
            let tables = try db.read { database in
                try String.fetchAll(
                    database,
                    sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
            }
            let read = Set(tables.filter { region.isModified(byEventsOfKind: .insert(tableName: $0)) })
            let unnamed = read.subtracting(Queries.trashTables).sorted()
            let unread = Set(Queries.trashTables).subtracting(read).sorted()
            #expect(read == Set(Queries.trashTables),
                    "read but not named: \(unnamed); named but not read: \(unread)")
        }
    }

    /// The held listing still answers each kind of act — a note deleted and
    /// put back, a block deleted, a purge intent, a book deleted, a stranded
    /// original appearing.
    @Test func theOpenTrashFollowsEveryActStill() async throws {
        try await onTheObservationLane {
            try await withOnDiskOperations { ops, db in
                let note = try ops.createPost(title: "a note")
                _ = try ops.seedBlock(in: note.id, text: "Its words.")
                let home = try ops.createPost(title: "home")
                let block = try ops.seedBlock(in: home.id, text: "A block to delete.")
                let book = try ops.createReading(name: "a book", kind: .book)
                let now = Date(timeIntervalSince1970: 1_782_864_000 + 86_400)
                let listing = HeldValues(db.observeTrash(
                    now: now, kinds: listedKinds, oldestFirst: false, limit: 501, wingID: ""))
                defer { listing.cancel() }
                func listed(_ id: String) -> ([Queries.TrashItem]) -> Bool { { $0.contains { $0.id == id } } }
                func unlisted(_ id: String) -> ([Queries.TrashItem]) -> Bool { { !$0.contains { $0.id == id } } }

                #expect(try await listing.latest(where: { $0.isEmpty }) != nil, "an empty Trash first")
                try ops.deleteContainer(note.id)
                #expect(try await listing.latest(where: listed(note.id)) != nil, "a deleted note lists")
                try ops.restoreContainer(note.id)
                #expect(try await listing.latest(where: unlisted(note.id)) != nil, "put back, it leaves")
                try ops.deleteBlock(block.block.id)
                #expect(try await listing.latest(where: listed(block.block.id)) != nil, "a deleted block lists")
                _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: block.block.id)])
                #expect(try await listing.latest(where: unlisted(block.block.id)) != nil, "an intent fences it")
                try ops.deleteReading(book.id)
                #expect(try await listing.latest(where: listed(book.id)) != nil, "a deleted book lists")
                let fanned = try ops.seedBlock(in: home.id, text: "Alpha one. Beta one.")
                let take2 = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
                let w = try ops.divideW(fanned.block.id, cuts: [fanned.variant.id: 10, take2.id: 10])
                try ops.deleteBlock(w.first.block.id)
                try ops.deleteBlock(w.second.block.id)
                #expect(try await listing.latest(where: listed(fanned.block.id)) != nil,
                        "a stranded original lists when its family's last block goes")
            }
        }
    }
}
