import Foundation

/// **THE DAY A DUPLICATE KEEPS** — VX-759 (the VX-771 run, batch 1;
/// PROVISIONAL P-771-1, QUESTIONS #258's bundle).
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
/// - a JOURNAL-profile source is the class too since VX-826 (A-809-10,
///   PROVISIONAL P-809-7 — her R-826: "never today's"); `profile` is kept on
///   the signature, unread.
///
/// Never a write of the TITLE (`DisplayTitle` stays a display rule — the name
/// is still derived), and never a forged `created_at`: the copy's own birth
/// stays its own. Pure and dependency-free; its callers are the copy machine's
/// duplicate road (`Operations.duplicateAsVersionBody`) and — A-771-1, fork
/// F-1's option (b) — her Copy to Wing (`Operations.copyNoteToWing`, both its
/// mint paths), which the wire's `copy_note_to_wing` shares. Promote, diverge,
/// the ownership forks and the saved version stay verbatim.
public enum DuplicateDay {
    /// The `entry_date` a duplicate of this source is born with.
    public static func entryDate(
        title: String?, entryDate: String?, profile: Profile?, createdAt: Date,
        calendar: Calendar = JournalDay.storeCalendar
    ) -> String? {
        let undated = entryDate?.isEmpty ?? true
        guard undated, DisplayTitle.isAbsent(title) else { return entryDate }
        return JournalDay.dayString(from: createdAt, calendar: calendar)
    }
}
