import Foundation

/// **THE DAY A DUPLICATE KEEPS** — VX-759 (the VX-771 run, batch 1;
/// PROVISIONAL P-771-1, QUESTIONS #257's bundle).
///
/// A note with no typed title and no `entry_date` is NAMED by the day it was
/// born (`DisplayTitle.note`: the title, else the date, else the day of
/// `created_at`). A copy is born today, so a verbatim copy of such a note is
/// named — and sorted — for the day it was MADE, not the day its source is
/// named for (the field report's 28 copies all reading one day).
///
/// The rule: that class's copy takes the source's CREATION DAY as its
/// `entry_date`, in the store's day calendar (`JournalDay.storeCalendar`), so
/// it is named and sorted as its source is. Everything else is verbatim:
///
/// - a DATED source (a non-empty `entry_date`) keeps its date — already the
///   copy's name and sort key;
/// - a TYPED-TITLED source keeps no date — its name is its title, already
///   faithful, and nothing invents a date for it;
/// - a JOURNAL-profile source keeps no date — the notebook rule finds "the
///   day's entry" by `profile = 'journal' AND entry_date`
///   (`Queries.canonicalJournalEntry`), so a dated copy would claim a notebook
///   day its source never claimed (`mintNoteVersion`'s V3 reason).
///
/// Never a write of the TITLE (`DisplayTitle` stays a display rule — the name
/// is still derived), and never a forged `created_at`: the copy's own birth
/// stays its own. Pure and dependency-free; the copy machine's duplicate road
/// (`Operations.duplicateAsVersionBody`) is its one caller.
public enum DuplicateDay {
    /// The `entry_date` a duplicate of this source is born with.
    public static func entryDate(
        title: String?, entryDate: String?, profile: Profile?, createdAt: Date,
        calendar: Calendar = JournalDay.storeCalendar
    ) -> String? {
        let undated = entryDate?.isEmpty ?? true
        guard undated, DisplayTitle.isAbsent(title), profile != .journal else { return entryDate }
        return JournalDay.dayString(from: createdAt, calendar: calendar)
    }
}
