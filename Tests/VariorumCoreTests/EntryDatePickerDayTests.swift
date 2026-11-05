import Foundation
import Testing
@testable import VariorumCore

/// **VX-832 (the VX-805 run, Unit A) — the date picker opens on the note's
/// creation day.** Her ask (2026-11-04): default the picker "to the creation
/// date or last edited date (i'm open to which one you think it should be)";
/// the ticket's call, ruled into the run (R §3): the CREATION day — the
/// gesture is backdating, and the Library's date sort already reads an undated
/// note as the day it was written (VX-758), so accepting the default changes
/// nothing about where the note sorts. A note that HAS an entry date opens on
/// it, unchanged.
///
/// THE MECHANISM (traced, pre-fix): both doors seeded the picker with
/// `CommitBar.date(fromDay: entryDate) ?? Date()` (`CommitBar.swift` and
/// `TakesBottomBar.swift`, the "Set date…" button) — an undated note's
/// `nil` fell through to `Date()`, so the picker opened on TODAY.
@Suite("VX-832 — the date picker opens on the creation day")
struct EntryDatePickerDayTests {
    /// 2026-06-20T12:00:00Z — the 20th locally in any zone within ±11 h.
    static let stamp = "2026-06-20T12:00:00.000Z"
    var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// RED ON OLD: an undated note opened on today (nil here — the face's
    /// `?? Date()`); it now opens on the day it was written — the very day
    /// its name and the Library's date sort already read.
    @Test func anUndatedNoteOpensOnItsCreationDay() throws {
        let day = EntryDatePickerDay.day(entryDate: nil, createdAt: Self.stamp, calendar: utc)
        #expect(day == "2026-06-20")
        #expect(day == DisplayTitle.day(fromStamp: Self.stamp, calendar: utc),
                "the same day its untitled name reads")
        // An EMPTY or malformed stored date is no date (the display rule's own
        // absence test) — the creation day again, never today.
        #expect(EntryDatePickerDay.day(entryDate: "", createdAt: Self.stamp, calendar: utc) == "2026-06-20")
        #expect(EntryDatePickerDay.day(entryDate: "June 5", createdAt: Self.stamp, calendar: utc) == "2026-06-20")
    }

    /// Unchanged: a dated note opens on its date, whatever its birth.
    @Test func aDatedNoteOpensOnItsDate() {
        #expect(EntryDatePickerDay.day(entryDate: "2026-05-05", createdAt: Self.stamp, calendar: utc)
                == "2026-05-05")
    }

    /// No stamp to read (a header still loading): nil — the face keeps today.
    @Test func noStampFallsBackToTheFacesToday() {
        #expect(EntryDatePickerDay.day(entryDate: nil, createdAt: nil, calendar: utc) == nil)
        #expect(EntryDatePickerDay.day(entryDate: nil, createdAt: "not a stamp", calendar: utc) == nil)
    }
}
