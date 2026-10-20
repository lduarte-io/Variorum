//
//  OwnCopiesTests.swift
//  VariorumCoreTests — VX-309 U1a (VX-397, P-VX306-U1a-4's deferral): every new-road read of the copies is PER LIBRARY
//  PER MAC. The far folder's due-check and Data Safety's counts read this Mac's pairs of this library in a place —
//  retention's own predicate, now shared (`OwnCopies`) — so another Mac's fresh copy in a shared folder never satisfies
//  this Mac's due-check and never counts as this Mac's copy; nor does another library's, a pair whose key file doesn't
//  read, today's flat files, or a copy filed under another library's folder. A stamp later than now is never freshness
//  (StoreBackup's `stampIsTrusted`, restated).
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U1a — this Mac's copies of this library, per place: the one predicate every new-road read uses")
struct OwnCopiesTests {
    static let now = CF.stamp(10)

    /// One pair (snapshot + its own key file) of `library` by `mac` in `place`, stamped `when`, filed under
    /// `filedUnder`'s folder (default: the library's own).
    static func pair(
        _ place: CatalogPlace, library: String, mac: String, at when: Date, filedUnder: String? = nil,
        readableKeyFile: Bool = true
    ) throws -> [CatalogEntry] {
        let key = StoreKey.mint()
        let folders = CF.macFolder(filedUnder ?? library, mac)
        var entries = [CatalogEntry(place: place, folders: folders, name: CF.snapshotName(when, key))]
        if readableKeyFile {
            entries.append(CatalogEntry(
                place: place, folders: folders, name: CF.pairName(when, key), bytes: try CF.format3(library: library, key: key)))
        }
        return entries
    }

    static func due(_ entries: [CatalogEntry], now: Date = OwnCopiesTests.now) -> Bool {
        OwnCopies.farPairIsDue(Catalog.build(entries), libraryID: CF.lib1, thisMac: CF.macA, now: now, interval: 86_400)
    }

    @Test func thisMacsPairsOfThisLibraryPerPlaceAndNothingElse() throws {
        let catalog = try RetentionTests.sharedWorld()
        let container = OwnCopies.of(catalog, libraryID: CF.lib1, thisMac: CF.macA, in: .container)
        let far = OwnCopies.of(catalog, libraryID: CF.lib1, thisMac: CF.macA, in: .farFolder)
        #expect(container.count == 20, "A's lib1 pairs beside the library — not B's five")
        #expect(far.count == 40, "A's lib1 pairs in the shared far folder — not B's forty, not lib2's, not the flat files")
        let mac8A = ProtectionNames.mac8(CF.macA)
        for copy in container + far {
            #expect(copy.kind == .backup && copy.mac == .mac8(mac8A) && copy.library == CF.lib1, "\(copy.id)")
        }
        // The one predicate retention prunes by: its keep ∪ prune is exactly these.
        let plan = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA, now: CF.stamp(1_000))
        #expect(Set(plan.keep).union(plan.prune) == Set((container + far).map(\.id)))
    }

    /// A copy whose key file names this library but which is filed under ANOTHER library's folder is not this
    /// library's copy (retention's rule, kept in the shared predicate).
    @Test func aPairFiledUnderAnotherLibrarysFolderIsNotThisLibrarys() throws {
        let entries = try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(9.9), filedUnder: CF.lib2)
        let catalog = Catalog.build(entries)
        #expect(catalog.copies.count == 1 && catalog.copies.first?.library == CF.lib1)
        #expect(OwnCopies.of(catalog, libraryID: CF.lib1, thisMac: CF.macA, in: .farFolder).isEmpty)
    }

    @Test func aSummaryCountsEveryPairAndShowsOnlyTrustedStamps() throws {
        var entries: [CatalogEntry] = []
        for day in [0.0, 1, 2, 3, 4] { entries += try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(day)) }
        // A copy stamped ahead of the clock: a real file, counted — never the newest.
        entries += try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(12))
        // Another Mac's and another library's: not counted.
        entries += try Self.pair(.farFolder, library: CF.lib1, mac: CF.macB, at: CF.stamp(5))
        entries += try Self.pair(.farFolder, library: CF.lib2, mac: CF.macA, at: CF.stamp(5))
        let summary = OwnCopies.summary(
            Catalog.build(entries), libraryID: CF.lib1, thisMac: CF.macA, in: .farFolder, now: Self.now)
        #expect(summary == OwnCopies.Summary(count: 6, newest: CF.stamp(4), oldest: CF.stamp(0)))
        #expect(OwnCopies.summary(
            Catalog.build(entries), libraryID: CF.lib1, thisMac: CF.macA, in: .container, now: Self.now) == .none)
    }

    /// THE FAR DUE-CHECK, PER LIBRARY PER MAC (VX-397). Only THIS Mac's own trusted pair of THIS library in the FAR
    /// folder, younger than the interval, makes it not due.
    @Test func theFarPairIsDueUnlessThisMacsOwnFreshPairOfThisLibraryIsThere() throws {
        #expect(Self.due([]), "nothing there")
        let fresh = CF.stamp(9.5)  // twelve hours old
        // THE WRONG SHAPES — each fresh, none this Mac's own pair of this library in the far folder:
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macB, at: fresh)),
                "another Mac's fresh copy in the shared folder never satisfies this Mac's due-check")
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib2, mac: CF.macA, at: fresh)), "another library's")
        #expect(Self.due(try Self.pair(.container, library: CF.lib1, mac: CF.macA, at: fresh)), "the container's")
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: fresh, filedUnder: CF.lib2)),
                "filed under another library's folder")
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: fresh, readableKeyFile: false)),
                "a snapshot with no key file naming this library")
        let flatKey = StoreKey.mint()
        #expect(Self.due([CatalogEntry(place: .farFolder, folders: ["Backups"], name: CF.snapshotName(fresh, flatKey))]),
                "today's flat far file (foreign since rule 26)")
        // A stamp later than now is not freshness (18o U1's rule).
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(10, 3_600))),
                "a pair stamped an hour ahead of the clock")
        // THIS Mac's own pair of this library: fresh ⇒ not due; older than the interval ⇒ due.
        #expect(!Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: fresh)))
        #expect(!Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(9, 3_600))), "23 hours old")
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(9, -3_600))), "25 hours old")
        #expect(Self.due(try Self.pair(.farFolder, library: CF.lib1, mac: CF.macA, at: CF.stamp(9))), "exactly the interval")
    }

    @Test func aStampIsTrustedOnlyWhenItIsNoLaterThanNow() {
        #expect(OwnCopies.stampIsTrusted(Self.now.addingTimeInterval(-1), now: Self.now))
        #expect(OwnCopies.stampIsTrusted(Self.now, now: Self.now))
        #expect(!OwnCopies.stampIsTrusted(Self.now.addingTimeInterval(1), now: Self.now))
    }
}
