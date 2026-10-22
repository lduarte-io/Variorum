//
//  ProtectionCopyCounts.swift
//  Variorum (shared: Mac + Mobile — read on the Mac, by Settings ▸ Data Safety)
//
//  VX-309 U1a — VX-397: DATA SAFETY'S COUNTS ON THE NEW ROAD are per library per Mac. The copies the pane counts there
//  are THIS Mac's backup PAIRS of THIS library in each place — the catalogue read fresh, through core's one predicate
//  (`OwnCopies`, retention's own), never the folder's flat files — so another Mac's copy in a shared folder, another
//  library's, today's flat files and a copy whose key file doesn't read are never counted as this Mac's. Newest and
//  oldest read trusted stamps only (18o U1's rule). The open library's faces carry the road (`RoadStandingModel.copyCounts`);
//  since VX-329 U1 these are Data Safety's only counts (today's flat-file count left with today's road).
//  A READ: nothing is written.
//

import Foundation
import VariorumCore

/// This Mac's pairs of the open library, in the container and in the picked far folder.
nonisolated struct RoadCopyCounts: Equatable, Sendable {
    var container: OwnCopies.Summary
    var far: OwnCopies.Summary
}

nonisolated enum ProtectionCopyCounts {
    static func read(_ session: ProtectionRoadSession, now: Date = Date()) -> RoadCopyCounts {
        let catalog = session.system.lister.catalog()
        let libraryID = session.library.record?.libraryID ?? ""
        let deviceID = session.library.section.deviceID
        return RoadCopyCounts(
            container: OwnCopies.summary(catalog, libraryID: libraryID, thisMac: deviceID, in: .container, now: now),
            far: OwnCopies.summary(catalog, libraryID: libraryID, thisMac: deviceID, in: .farFolder, now: now))
    }
}
