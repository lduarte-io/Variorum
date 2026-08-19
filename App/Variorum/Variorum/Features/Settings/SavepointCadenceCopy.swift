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
