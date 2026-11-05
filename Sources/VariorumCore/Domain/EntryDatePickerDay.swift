import Foundation

/// **THE DAY A NOTE'S DATE PICKER OPENS ON** — VX-832 (the VX-805 run, Unit A).
///
/// The note ▾ menu's "Set date…" / "Date: …" door (Write's bar and Takes'
/// bar) opens a calendar picker; this is the day it opens on. Pure, shared by
/// both faces so they can never disagree.
///
/// The rule (the ticket's call, ruled into the run): a DATED note opens on
/// its date, unchanged; an UNDATED note opens on its CREATION day — the
/// gesture is backdating ("this note is really from when I wrote it"), and
/// that is exactly the day its untitled name already reads
/// (`DisplayTitle.day(fromStamp:)`, the one stamp→day rule) and the Library's
/// date sort already files it under (VX-758), so pressing Set on the default
/// changes nothing about where the note sorts — the date just becomes
/// explicit. Before VX-832 an undated note's picker opened on TODAY.
public enum EntryDatePickerDay {
    /// The day ("yyyy-MM-dd") the picker opens on, or nil for "today" (the
    /// face's own fallback — only when no stamp can be read, e.g. a header
    /// still loading). A stored day that is empty or malformed is no date.
    public static func day(
        entryDate: String?, createdAt stamp: String?, calendar: Calendar = .current
    ) -> String? {
        if let entryDate, JournalDay.isValid(entryDate) { return entryDate }
        return DisplayTitle.day(fromStamp: stamp, calendar: calendar)
    }
}
