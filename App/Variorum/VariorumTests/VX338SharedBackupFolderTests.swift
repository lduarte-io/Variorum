//
//  VX338SharedBackupFolderTests.swift
//  VariorumTests
//
//  VX-338 (VX-348 U1 — the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`,
//  U1 UNIT RECORD): TWO MACS SHARING A BACKUP FOLDER PRUNED EACH OTHER'S
//  BACKUPS. Her ruling (2026-10-14, VX-266 design §9 call 4): "yeah we can do
//  the small bug fix." The shape: retention acts only on THIS Mac's own
//  snapshots and never deletes another Mac's; an existing shared folder is
//  never cleaned up by deletion.
//
//  Two Macs, here, are what make two Macs on her account: two app containers
//  (each its own `Backups/` and its own store), two device-local defaults
//  domains (each its own bookmark of the SAME picked folder), and ONE picked
//  folder they both write into — the iCloud Drive offer's shape
//  (`<pick>/Variorum/Backups`). Every run is the real run (`performRun`, the
//  hourly tick's and Back Up Now's body), forced so a day's copy always lands.
//
//  RED ON OLD, with no new API named (the defaults key is spelled as the
//  literal it is): before the fix the far sweep counted every app-named copy
//  in the folder, whichever Mac wrote it, so one Mac's run deleted the other's
//  older copies, and a copy from before the fix fell to the rule like any
//  other. The red product is built from the pre-fix `StoreBackup.swift` (the
//  run record names where it lives).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-338 — a shared backup folder: each Mac prunes only its own copies", .serialized)
struct VX338SharedBackupFolderTests {
    /// One Mac: its container's `Backups/`, its store, its own defaults domain
    /// (never `.standard` — the dev store's while the suite runs).
    private struct Mac {
        let backups: URL
        let store: AppDatabase
        let defaults: @Sendable () -> UserDefaults
    }

    /// Noon UTC on 2026-09-01 — day 0.
    private let dayZero = ISO8601DateFormatter().date(from: "2026-09-01T12:00:00Z")!

    private func temporaryDirectory(_ tag: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx338-\(tag)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func populatedStore(_ words: String) throws -> AppDatabase {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: words, profile: .journal)
            _ = try ops.newBlock(in: post.id, text: words)
        }
        return db
    }

    /// A Mac whose defaults hold a bookmark of the SHARED picked folder.
    private func mac(_ tag: String, sharing picked: URL, cleanup: inout [URL]) throws -> Mac {
        let backups = try temporaryDirectory("\(tag)-container")
        cleanup.append(backups)
        let suite = "variorum-vx338-\(tag)-\(UUID().uuidString)"
        let defaults: @Sendable () -> UserDefaults = { UserDefaults(suiteName: suite)! }
        let bookmark = try picked.bookmarkData(
            options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults().set(bookmark, forKey: BackupDestination.defaultsKey)
        return Mac(backups: backups, store: try populatedStore("The library on \(tag)."), defaults: defaults)
    }

    /// One real, forced run on `mac` at `stamp` (off-main by contract).
    @discardableResult
    private func run(_ mac: Mac, at stamp: Date) async -> BackupRunRecord {
        await Task.detached {
            StoreBackup.performRun(
                database: mac.store, directory: mac.backups, configuration: .init(),
                defaults: mac.defaults(), now: stamp, force: true)
        }.value
    }

    /// The app-named snapshots in the shared folder (a raw listing).
    private func farNames(_ picked: URL) -> Set<String> {
        let far = BackupDestination.backupsFolder(in: picked)
        return Set(((try? FileManager.default.contentsOfDirectory(atPath: far.path)) ?? [])
            .filter { $0.hasPrefix(StoreBackup.filePrefix) && $0.hasSuffix(".\(StoreBackup.fileExtension)") })
    }

    /// The day-`n` stamp at `hour` UTC.
    private func day(_ n: Int, hour: Int = 12) -> Date {
        dayZero.addingTimeInterval(Double(n) * 86_400 + Double(hour - 12) * 3_600)
    }

    /// The pin the ticket names: two Macs' snapshots in one folder; one Mac
    /// prunes; the other Mac's snapshots all survive. The Air writes twenty
    /// daily copies (its own sweep keeping its own 14+4); then the Pro's run
    /// on the next day — before the fix, its sweep counted the Air's copies
    /// and deleted the oldest the combined set no longer kept.
    @Test func anotherMacsCopiesAllSurviveThisMacsSweep() async throws {
        var cleanup: [URL] = []
        defer { for url in cleanup { try? FileManager.default.removeItem(at: url) } }
        let picked = try temporaryDirectory("picked")
        cleanup.append(picked)
        let air = try mac("air", sharing: picked, cleanup: &cleanup)
        let pro = try mac("pro", sharing: picked, cleanup: &cleanup)

        for n in 0..<20 { await run(air, at: day(n, hour: 11)) }
        let airsCopies = farNames(picked)
        #expect(!airsCopies.isEmpty, "premise: the Air's copies are in the shared folder")

        let record = await run(pro, at: day(20))
        #expect(record.secondary.outcome == .written, "the Pro's copy landed: \(String(describing: record.secondary.detail))")
        let after = farNames(picked)
        #expect(airsCopies.isSubset(of: after),
                "the Pro's sweep deleted the Air's \(airsCopies.subtracting(after).sorted())")
        #expect(record.secondary.pruned == 0, "the Pro had nothing of its own to prune")
    }

    /// Both Macs, a month of alternate days: each Mac's own copies are pruned
    /// by its own 14+4 — retention still works — and never by the other's.
    @Test func eachMacPrunesItsOwnCopiesByItsOwnRuleAndNeverTheOthers() async throws {
        var cleanup: [URL] = []
        defer { for url in cleanup { try? FileManager.default.removeItem(at: url) } }
        let picked = try temporaryDirectory("picked")
        cleanup.append(picked)
        let air = try mac("air", sharing: picked, cleanup: &cleanup)
        let pro = try mac("pro", sharing: picked, cleanup: &cleanup)

        var airWrote: [String] = []
        var proWrote: [String] = []
        for n in 0..<40 {
            let airRecord = await run(air, at: day(n, hour: 11))
            if let file = airRecord.secondary.file, airRecord.secondary.outcome == .written { airWrote.append(file) }
            let proRecord = await run(pro, at: day(n))
            if let file = proRecord.secondary.file, proRecord.secondary.outcome == .written { proWrote.append(file) }
        }
        let far = BackupDestination.backupsFolder(in: picked)
        func survivors(_ wrote: [String]) -> Set<String> { Set(wrote).intersection(farNames(picked)) }
        func ruled(_ wrote: [String]) -> Set<String> {
            let candidates = wrote.compactMap { name -> BackupRetention.Candidate? in
                let url = far.appendingPathComponent(name)
                return StoreBackup.date(fromBackupURL: url).map { .init(url: url, date: $0) }
            }
            return Set(BackupRetention.keep(candidates, policy: .secondDestination).map(\.lastPathComponent))
        }
        #expect(airWrote.count == 40 && proWrote.count == 40, "premise: one copy a day from each Mac")
        #expect(survivors(airWrote) == ruled(airWrote), "the Air's copies are exactly what the Air's own rule keeps")
        #expect(survivors(proWrote) == ruled(proWrote), "the Pro's copies are exactly what the Pro's own rule keeps")
        #expect(survivors(airWrote).count <= 18 && survivors(proWrote).count <= 18, "each Mac's own 14+4")
        #expect(farNames(picked) == survivors(airWrote).union(survivors(proWrote)), "nothing else in the folder")
    }

    /// An existing shared folder is never cleaned up by deletion: copies
    /// written before the fix (no Mac's list holds them — here, placed as
    /// the older build left them) survive a month of this Mac's sweeps.
    @Test func copiesWrittenBeforeTheFixAreNeverDeleted() async throws {
        var cleanup: [URL] = []
        defer { for url in cleanup { try? FileManager.default.removeItem(at: url) } }
        let picked = try temporaryDirectory("picked")
        cleanup.append(picked)
        let pro = try mac("pro", sharing: picked, cleanup: &cleanup)
        let far = BackupDestination.backupsFolder(in: picked)
        try FileManager.default.createDirectory(at: far, withIntermediateDirectories: true)
        // Twenty app-named copies from before the fix — real snapshots of this
        // Mac's library, written into the folder as the older build left them
        // (no Mac's list holds them).
        let scratch = try temporaryDirectory("pre-fix")
        cleanup.append(scratch)
        var older: Set<String> = []
        for n in 0..<20 {
            let stamp = day(n - 60, hour: 9)
            let written = try await Task.detached { [store = pro.store] in
                try StoreBackup.performBackupIfDue(
                    database: store, directory: scratch, configuration: .init(), now: stamp, force: true)
            }.value
            let url = try #require(written)
            try FileManager.default.copyItem(at: url, to: far.appendingPathComponent(url.lastPathComponent))
            older.insert(url.lastPathComponent)
        }
        let pristine = farNames(picked).intersection(older)
        #expect(pristine == older, "premise: the older copies are in the folder")

        for n in 0..<30 { await run(pro, at: day(n)) }
        #expect(older.isSubset(of: farNames(picked)),
                "a copy from before the fix was deleted: \(older.subtracting(farNames(picked)).sorted())")
    }

    /// The list stays bounded and honest: a copy of this Mac's that someone
    /// deleted by hand (or an older build on the other Mac) leaves it, and the
    /// list never names more than the folder holds of this Mac's own.
    @Test func thisMacsListFollowsTheFolder() async throws {
        var cleanup: [URL] = []
        defer { for url in cleanup { try? FileManager.default.removeItem(at: url) } }
        let picked = try temporaryDirectory("picked")
        cleanup.append(picked)
        let pro = try mac("pro", sharing: picked, cleanup: &cleanup)
        for n in 0..<25 { await run(pro, at: day(n)) }
        let listed = { Set(pro.defaults().stringArray(forKey: "variorum.backup.ownFarSnapshots") ?? []) }
        #expect(listed() == farNames(picked), "the list names exactly this Mac's copies there")
        #expect(listed().count <= 18)
        let byHand = try #require(listed().sorted().first)
        try FileManager.default.removeItem(at: BackupDestination.backupsFolder(in: picked).appendingPathComponent(byHand))
        await run(pro, at: day(25))
        #expect(!listed().contains(byHand), "a copy gone by hand leaves the list")
        #expect(listed() == farNames(picked))
    }

    /// The pure half of the deletion-safety argument: whatever else the
    /// folder holds, the sweep's result is a subset of this Mac's own copies.
    @Test func theOwnSweepNeverReturnsACopyThatIsNotOwn() {
        let folder = URL(fileURLWithPath: "/shared/Variorum/Backups", isDirectory: true)
        func candidate(_ n: Int, _ who: String) -> BackupRetention.Candidate {
            .init(url: folder.appendingPathComponent("\(who)-\(n).sqlite"),
                  date: Date(timeIntervalSince1970: 1_782_864_000 + Double(n) * 86_400))
        }
        let mine = (0..<40).map { candidate($0, "mine") }
        let theirs = (0..<40).map { candidate($0, "theirs") }
        let own = Set(mine.map(\.url.lastPathComponent))
        let doomed = BackupRetention.prune(mine + theirs, policy: .secondDestination, ownedBy: own)
        #expect(doomed.allSatisfy { own.contains($0.lastPathComponent) }, "never another Mac's")
        #expect(Set(doomed) == Set(BackupRetention.prune(mine, policy: .secondDestination)),
                "exactly the rule over the own set")
        #expect(BackupRetention.prune(theirs, policy: .secondDestination, ownedBy: own).isEmpty,
                "a folder of nothing but another Mac's copies loses nothing")
    }
}
