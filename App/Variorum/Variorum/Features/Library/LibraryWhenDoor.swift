//
//  LibraryWhenDoor.swift
//  Variorum (Mac)
//
//  **VX-87 — the `when ▾` door rebuilt to her DIRECTION 1** (R-VX83-2, the
//  2026-10-07 sitting: *"I choose direction 1 on the calendar - but make sure
//  that the popover looks good"*; the mockup `notes/plans/mockups/
//  when-door.html` is the visual record). Her report, verbatim: *"I think
//  that the date selector is ugly and it's very unclear if there's
//  confirmation. the nested drop downs where a new dropdown appears is also a
//  big of an ugly ux experience."*
//
//  The cure is one surface: the press opens ONE popover — a mode row (on a
//  day · between days), a month grid, and the ARMED SENTENCE at its foot
//  ("Showing notes edited on Oct 6.") — so the confirmation sits under the
//  hand that made it. Nothing arms until a day is pressed (it superseded
//  P-13o-U2-9's arm-at-once FOR THIS DOOR — her "unclear if there's
//  confirmation" is the reason); Esc or a click outside keeps whatever the
//  sentence last said, because every press has already armed exactly that.
//
//  This file holds the door's BRAIN — pure, so the pins read the rule and the
//  face only renders it (P-9). The face joins it (the grid's form is the
//  orchestrator's ruling on the measured fork, the U-B record's §P1).
//

import Foundation
import VariorumCore

// MARK: - The brain

/// **What a press inside the `when` popover DOES** (VX-87, direction 1).
///
/// The armed range itself is NOT here: it is the catalog model's
/// (`LibraryCatalogModel.editedRange`), and the popover reads it through the
/// door's `range` — so the sentence and the band's chip can never say two
/// different things. The brain holds only what the popover is in the middle
/// of: which question the mode row is asking, and — between days — the first
/// day of a run waiting for its last.
///
/// **The no-silent-arm rule is structural:** opening (`opening`) and the mode
/// row (`ask`) RETURN NOTHING a caller could arm; the one member that yields
/// a range is `press(_:)`, the act of touching a day.
nonisolated struct LibraryWhenDoorBrain: Equatable, Sendable {
    /// The mode row's two questions.
    enum Mode: Hashable, CaseIterable, Sendable {
        /// **on a day** — a press arms that one day.
        case oneDay
        /// **between days** — the first press arms its day and waits; the
        /// second makes the run, first through last (any order).
        case between
    }

    private(set) var mode: Mode
    /// Between days: the day the last press began a run on, waiting for the
    /// run's last day. nil = the next press begins (or, on a day, picks).
    private(set) var runStart: String?

    /// Whether the popover is waiting for a run's last day (the foot's hint
    /// says so).
    var waitsForRunEnd: Bool { mode == .between && runStart != nil }

    /// **Opening** — the mode the ARMED state reads in (a run opens on
    /// between days; one day, or nothing, on a day), and nothing arms: the
    /// shipped door's arm-at-once (P-13o-U2-9 — "today" armed by merely
    /// choosing a menu item) is exactly the silent arming her report names.
    static func opening(range: LibraryDayRange?) -> Self {
        LibraryWhenDoorBrain(mode: range.map { $0.isOneDay ? .oneDay : .between } ?? .oneDay)
    }

    private init(mode: Mode) {
        self.mode = mode
        self.runStart = nil
    }

    /// **The mode row** — changes what the NEXT press means and arms
    /// nothing; a run waiting for its end forgets its start (the armed day
    /// that start already armed stays armed, and the sentence keeps saying
    /// it).
    mutating func ask(_ mode: Mode) {
        self.mode = mode
        runStart = nil
    }

    /// **A day pressed** — the ONE act that arms. Returns the range the door
    /// hands its `onPick`: on a day, that day; between days, the first press
    /// arms its own day (so Esc right after keeps exactly what the sentence
    /// says) and waits, the second arms the run from the waiting day to this
    /// one, put in order — and a third begins a fresh run. nil only for a key
    /// that is not a real day (a face draws what it has, never a guess).
    mutating func press(_ day: String) -> LibraryDayRange? {
        guard JournalDay.isValid(day) else { return nil }
        switch mode {
        case .oneDay:
            runStart = nil
            return LibraryDayRange(day: day)
        case .between:
            if let start = runStart {
                runStart = nil
                return LibraryDayRange(first: start, last: day)
            }
            runStart = day
            return LibraryDayRange(day: day)
        }
    }
}
