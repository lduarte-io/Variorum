//
//  SavepointCadenceCopy.swift
//  Variorum (Mac)
//
//  Phase 13j, J11 — the words of the ONE cadence setting (her sitting-round-1
//  ruling: *"a single enum-valued setting… Not full knobs; not settingless"*).
//
//  **The help copy's job is to not overclaim.** The setting governs exactly
//  two occasions; four others — sealing a note, locking a take with unsaved
//  changes, a structural undo about to overwrite an edited buffer, and a
//  Fragments-bridge landing — insure text that is about to become unreachable
//  (OverallModel §3) and stay on in every mode. A setting called "Only when I
//  commit" that left those unsaid would be read as "nothing else writes
//  savepoints", which is the J8 copy-truth defect exactly.
//

import Foundation
import VariorumCore

nonisolated enum SavepointCadenceCopy {
    static let title = "Savepoints Variorum takes for you"

    static func label(_ cadence: SavepointCadence) -> String {
        switch cadence {
        case .everySession: return "Every time I leave a note (recommended)"
        case .idleOnly: return "Only after a note sits untouched"
        case .onlyOnCommit: return "Only when I press ⌘S"
        }
    }

    static let help =
        "Every time I leave a note: closing it, switching away, or quitting "
        + "leaves one savepoint for each take you changed — and a note you "
        + "leave open gets one after about two hours. Only after a note sits "
        + "untouched: just that two-hour backstop. Only when I press ⌘S: "
        + "neither. A take you haven't changed is never saved twice, and "
        + "these quiet savepoints group into one line in a take's history."

    /// The sentence the setting must never leave out (see the header).
    static let insuranceNote =
        "Whichever you choose, Variorum still saves a take right before "
        + "something could make your text unreachable — marking a note "
        + "complete, locking a take with unsaved changes, undoing a "
        + "structural change over edits, and a journal entry arriving from "
        + "Fragments. Those aren't a schedule; they're insurance."
}

/// Phase 13j batch 6b — the words of the HISTORY PRUNING setting (her
/// round-9 ruling, verbatim: *"I think 90 days, N=10 is fine for a default,
/// but I think users should be able to choose to never prune. it might be
/// important for some users."*). The one sentence it must never leave out:
/// deliberate ⌘S savepoints are NEVER pruned, in either mode (the J8 bar —
/// a pruning setting that read as "your savepoints get thinned" would be
/// claiming a reach it doesn't have).
nonisolated enum HistoryPruningCopy {
    static let title = "Old quiet savepoints"

    static func label(_ pruning: HistoryPruning) -> String {
        switch pruning {
        case .standard: return "Tidy them after \(SavepointPruning.ageDays) days (recommended)"
        case .never: return "Keep every one, forever"
        }
    }

    static let help =
        "Tidy: once a take's quiet savepoints are older than "
        + "\(SavepointPruning.ageDays) days, only the newest "
        + "\(SavepointPruning.keepNewestQuiet) are kept — the rest are "
        + "deleted for good, everywhere, once every synced device has seen "
        + "them. Keep every one: nothing is ever thinned. Savepoints you "
        + "took yourself with ⌘S are never touched, in either mode."
}
