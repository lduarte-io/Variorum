//
//  RetentionTests.swift
//  VariorumCoreTests — VX-305 U2: retention acts only on this Mac's copies of
//  this library (VX-302) — over a shared folder holding two Macs' and two
//  libraries' copies, nothing foreign is pruned; 14 in the container, 14
//  daily + 4 weekly in the far folder; legacy flat files listed, never pruned.
//

import Foundation
import Testing

@testable import VariorumCore

enum RF {
    /// `count` daily copies of `library` from `mac` in `place`, one per day
    /// from `firstDay`, each with its own pair.
    static func copies(
        _ place: CatalogPlace, library: String, mac: String, days: [Double], seconds: Double = 0
    ) throws -> [CatalogEntry] {
        let key = StoreKey.mint()
        let bytes = try CF.format3(library: library, key: key)
        return days.flatMap { day -> [CatalogEntry] in
            let when = CF.stamp(day, seconds)
            return [
                CatalogEntry(place: place, folders: CF.macFolder(library, mac), name: CF.snapshotName(when, key)),
                CatalogEntry(place: place, folders: CF.macFolder(library, mac), name: CF.pairName(when, key), bytes: bytes),
            ]
        }
    }

    static func ids(_ catalog: Catalog, _ predicate: (CatalogCopy) -> Bool) -> Set<String> {
        Set(catalog.copies.filter(predicate).map(\.id))
    }
}

@Suite("VX-305 U2 — retention: this Mac's copies of this library, and nothing else")
struct RetentionTests {
    static let mac8A = ProtectionNames.mac8(CF.macA)

    static func sharedWorld() throws -> Catalog {
        var entries: [CatalogEntry] = []
        let forty = (0..<40).map(Double.init)
        // The far folder, shared by two Macs: lib1 from A and from B, lib2 from A.
        entries += try RF.copies(.farFolder, library: CF.lib1, mac: CF.macA, days: forty)
        entries += try RF.copies(.farFolder, library: CF.lib1, mac: CF.macB, days: forty)
        entries += try RF.copies(.farFolder, library: CF.lib2, mac: CF.macA, days: forty)
        // A copy in A's lib1 folder whose pair doesn't read — never attributable.
        entries.append(CatalogEntry(place: .farFolder, folders: CF.macFolder(CF.lib1, CF.macA),
                                    name: CF.snapshotName(CF.stamp(-30), StoreKey.mint())))
        // Today's legacy flat files.
        let flatKey = StoreKey.mint()
        for day in forty {
            entries.append(CatalogEntry(place: .farFolder, folders: ["Backups"], name: CF.snapshotName(CF.stamp(day), flatKey)))
        }
        entries.append(CatalogEntry(place: .farFolder, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(flatKey)),
                                    bytes: try CF.format2(library: CF.lib1, key: flatKey)))
        // The container: A's lib1 copies, and a predecessor's (B's) lib1 folder.
        entries += try RF.copies(.container, library: CF.lib1, mac: CF.macA, days: (0..<20).map(Double.init))
        entries += try RF.copies(.container, library: CF.lib1, mac: CF.macB, days: (0..<5).map(Double.init))
        return Catalog.build(entries)
    }

    @Test func overASharedFolderNothingForeignIsPruned() throws {
        let catalog = try Self.sharedWorld()
        let outcome = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA)
        let mine = RF.ids(catalog) { $0.kind == .backup && $0.mac == .mac8(Self.mac8A) && $0.library == CF.lib1 }
        #expect(!outcome.prune.isEmpty)
        #expect(Set(outcome.prune).isSubset(of: mine), "only this Mac's copies of this library")
        #expect(Set(outcome.prune).union(outcome.keep) == mine)
        // Another Mac's, another library's, the unattributable one, the legacy flat ones: untouched.
        for copy in catalog.copies where !mine.contains(copy.id) {
            #expect(!outcome.prune.contains(copy.id), "\(copy.id) is not this Mac's copy of this library")
        }
        #expect(Set(outcome.legacyFlat) == RF.ids(catalog) { $0.kind == .legacyFlatBackup })
        #expect(outcome.legacyFlat.count == 40)
    }

    @Test func theContainerKeepsItsNewestFourteen() throws {
        let catalog = try Self.sharedWorld()
        let outcome = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA)
        let containerKept = catalog.copies.filter { $0.place == .container && outcome.keep.contains($0.id) }
        #expect(containerKept.count == 14)
        #expect(containerKept.compactMap(\.stamp).min() == CF.stamp(6), "days 6–19 kept, 0–5 pruned")
        #expect(catalog.copies.filter { $0.place == .container && outcome.prune.contains($0.id) }.count == 6)
    }

    @Test func theFarFolderKeepsFourteenDailiesAndFourWeeklies() throws {
        let catalog = try Self.sharedWorld()
        let outcome = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA)
        let farKept = catalog.copies.filter { $0.place == .farFolder && outcome.keep.contains($0.id) }
        #expect(farKept.count == 18, "14 dailies + 4 weeklies")
        let days = Set(farKept.compactMap(\.stamp).map(Retention.dayIndex))
        let newest = Retention.dayIndex(CF.stamp(39))
        #expect((0..<14).allSatisfy { days.contains(newest - $0) }, "the fourteen most recent days")
        let dailies = farKept.filter { ($0.stamp.map(Retention.dayIndex) ?? 0) > newest - 14 }
        let weeklies = farKept.filter { ($0.stamp.map(Retention.dayIndex) ?? 0) <= newest - 14 }
        #expect(dailies.count == 14 && weeklies.count == 4)
        let dailyWeeks = Set(dailies.compactMap(\.stamp).map(Retention.weekIndex))
        let weeklyWeeks = weeklies.compactMap(\.stamp).map(Retention.weekIndex)
        #expect(Set(weeklyWeeks).count == 4 && dailyWeeks.isDisjoint(with: weeklyWeeks),
                "each weekly reaches a week the dailies don't cover")
    }

    /// Today's rule's own two lessons, kept: a day's newest copy represents
    /// it, and a day's second copy never claims a weekly slot for a week the
    /// dailies already cover.
    @Test func todaysFourteenPlusFourRuleIsKeptExactly() {
        let monday = Date(timeIntervalSince1970: 1_790_640_000)  // a day's start, UTC
        var candidates: [(id: String, date: Date)] = []
        for day in 0..<30 {
            candidates.append((id: "d\(day)", date: monday.addingTimeInterval(Double(day) * 86_400 + 3_600)))
        }
        // A second copy on the newest day (Back Up Now beside the automatic one).
        candidates.append((id: "d29-twin", date: monday.addingTimeInterval(29 * 86_400 + 7_200)))
        let kept = Retention.keepDailiesAndWeeklies(candidates, dailies: 14, weeklies: 4)
        #expect(kept.contains("d29-twin") && !kept.contains("d29"), "the day's newest copy represents it")
        let dailyWeeks = Set((16..<30).map { Retention.weekIndex(monday.addingTimeInterval(Double($0) * 86_400 + 3_600)) })
        let olderWeeks = Set((0..<16).map { Retention.weekIndex(monday.addingTimeInterval(Double($0) * 86_400 + 3_600)) })
            .subtracting(dailyWeeks)
        #expect(kept.count == 14 + min(4, olderWeeks.count),
                "the twin never claims a weekly slot for a week the dailies cover")
    }

    @Test func anotherLibraryOnThisMacIsKeptAsToday() throws {
        let catalog = try Self.sharedWorld()
        let outcome = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA)
        #expect(catalog.copies.filter { $0.library == CF.lib2 }.allSatisfy { !outcome.prune.contains($0.id) })
        #expect(catalog.copies.filter { $0.library == CF.lib2 }.count == 40)
    }
}

#if DEBUG
@Suite("VX-305 U2 — retention's guard, switched off, lets VX-302's cross-Mac prune through (DEBUG mutation pin)")
struct RetentionGuardMutationTests {
    @Test func pruneOwnCopiesOnly() throws {
        let catalog = try RetentionTests.sharedWorld()
        let otherMacs = RF.ids(catalog) { $0.mac == .mac8(ProtectionNames.mac8(CF.macB)) }
        let on = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA)
        #expect(otherMacs.isDisjoint(with: on.prune))
        var off = ProtectionGuards()
        off.pruneOwnCopiesOnly = false
        let broken = Retention.plan(catalog: catalog, libraryID: CF.lib1, thisMac: CF.macA, guards: off)
        #expect(!otherMacs.isDisjoint(with: broken.prune), "red with the guard off: another Mac's copies pruned")
    }
}
#endif
