//
//  FilePlanStoreLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `PlanStoreLeaf` (`Executor/Leaves.swift`): the ONE plan beside the library
//  (`ProtectionNames.planFilename`), sealed bytes (`Sealed<ProtectionPlan>` in `ProtectionCoding`'s
//  canonical JSON — a plan never holds a secret), written atomically, read back, and EXCLUDED FROM BACKUPS
//  (`isExcludedFromBackup` — design §3.2: a Time Machine copy of a plan is a replay waiting to happen; the
//  executor ignores an unnamed one anyway, §3.6).
//
//  Bytes that do not decode as a sealed plan read as NO plan (nil): the executor treats a plan it cannot
//  trust exactly as it treats none (before the commit point the act rolls back; after it, it finishes from
//  the record — §3.6), and the next `writePlan` replaces the debris.
//

import Foundation
import VariorumCore

nonisolated final class FilePlanStoreLeaf: PlanStoreLeaf, @unchecked Sendable {
    enum PlanStoreError: Error, Equatable { case writeDidNotReadBack }

    let places: ProtectionPlaces

    init(places: ProtectionPlaces) { self.places = places }

    func readPlan() throws -> Sealed<ProtectionPlan>? {
        let url = places.plan
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try? ProtectionCoding.decoder().decode(Sealed<ProtectionPlan>.self, from: data)
    }

    func writePlan(_ plan: Sealed<ProtectionPlan>) throws {
        var url = places.plan
        try FileManager.default.createDirectory(at: places.container, withIntermediateDirectories: true)
        let data = try ProtectionCoding.canonical(plan)
        try data.write(to: url, options: .atomic)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
        guard (try? Data(contentsOf: url)) == data else { throw PlanStoreError.writeDidNotReadBack }
    }

    func deletePlan() throws {
        let url = places.plan
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        try FileManager.default.removeItem(at: url)
    }
}
