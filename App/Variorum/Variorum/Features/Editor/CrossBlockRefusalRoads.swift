//
//  CrossBlockRefusalRoads.swift
//  Variorum (Mac)
//
//  **The Mac's half of the hoist** (13u1 UNIT 2, item 8's U-5). The
//  diagnosis, the causes and every road that names an ACT now live once, in
//  `Shared/EditorBrain/CrossBlockRefusal.swift`; what stayed here is the one
//  sentence that names a Mac CHORD — the fan's way out — because a shared
//  home must not hold a door one platform does not have (MobileSoul §4.4,
//  read from the other side).
//
//  These three forwards exist so every Mac call site and every Mac pin reads
//  EXACTLY as it did before the hoist: a zero-test-edit suite is the proof a
//  hoist moved an address and not a behaviour (the 3C parity pattern).
//

import Foundation
import VariorumCore

extension CrossBlockRefusal {
    /// The ONE roads constant both fan-fold refusals share (`seamFanRefusal`
    /// is the other speaker) — A2's fix, which is why this is read and never
    /// re-worded here.
    static var macFanRoads: String { FannedDefaultsCopy.fanFoldRoads }

    static func roadClause(for cause: Cause) -> String {
        roadClause(for: cause, fanRoads: macFanRoads)
    }

    static func message(for cause: Cause) -> String {
        message(for: cause, fanRoads: macFanRoads)
    }

    static func message(
        range: NSRange, index: BlockRangeIndex, slots: [Queries.RenderedBlock]
    ) -> String {
        message(range: range, index: index, slots: slots, fanRoads: macFanRoads)
    }
}
