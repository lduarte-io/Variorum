import Foundation

/// **The 30-day Trash clock** (Phase 13j, J1 — her ruling: *"some kind of
/// 'true delete' should be added for posts (going to a Trash for 30 days
/// before really deleting)"*, with the sitting's round-3 refinement that
/// EVERYTHING deleted rides one uniform story and the window is FIXED — no
/// setting; Delete Now is the impatience door).
///
/// **What this rule governs, exactly: what the app SHOWS.** Nothing here
/// deletes a byte. A tombstone older than the window stops appearing on every
/// recovery surface — the Trash, the per-note tray, the block's History face
/// — and with no surface listing it, no door can put it back. Removing the
/// rows themselves is the PURGE, which is sync-shaped (a peer that has not
/// pulled the deletion would re-push the row back) and is designed in
/// `notes/plans/phase-13j-purge-memo.md` rather than built here. Two halves
/// of one design: this is the half that is safe to ship on its own, because
/// hiding is reversible and purging is not.
///
/// Pure and clock-injected — every caller passes the `now` it read, so a test
/// can stand on day 29 and day 31 without touching the system clock, and one
/// listing can never disagree with another about where the boundary is.
public enum TrashWindow {
    /// The window, in days. Fixed by her ruling (round 3): no setting.
    public static let days = 30

    /// The oldest tombstone still in the window. A row deleted exactly at the
    /// cutoff is still IN (`>=` at every call site): the boundary belongs to
    /// the thing being recovered.
    public static func cutoff(now: Date) -> Date {
        now.addingTimeInterval(-Double(days) * 86_400)
    }

    /// The cutoff as the store's canonical stamp — the ONE parser/formatter
    /// (`DateFormatter.variorumISO8601`), so a SQL comparison against
    /// `deleted_at` is a comparison of the same text shape the writers wrote.
    public static func cutoffStamp(now: Date) -> String {
        DateFormatter.variorumISO8601.string(from: cutoff(now: now))
    }

    /// Is this tombstone still listed? An unparseable stamp reads as IN — the
    /// conservative answer, because hiding something we cannot date would
    /// remove its only door on a technicality.
    public static func isInWindow(_ stamp: String, now: Date) -> Bool {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return true }
        return date >= cutoff(now: now)
    }

    /// **"N days left"** — what a Trash row wears.
    ///
    /// Counted UP from the tombstone rather than down from a rendered clock:
    /// `days − whole days elapsed`, clamped to `0…days`, so a thing deleted a
    /// moment ago reads "30 days left" and one deleted 29½ days ago reads
    /// "1 day left" — the last day is a whole day, never a rounded-away one.
    /// Nil when the stamp does not parse (the row then wears no clock rather
    /// than a made-up one).
    public static func daysLeft(_ stamp: String, now: Date) -> Int? {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return nil }
        let elapsed = now.timeIntervalSince(date)
        let elapsedDays = Int(floor(elapsed / 86_400))
        return min(days, max(0, days - elapsedDays))
    }
}
