//
//  CalmAsks.swift
//  Variorum (MAC ONLY — never `Shared/`: the phone has neither ask)
//
//  Phase 13r U3-A — THE CALM-ASKS CADENCE (the plan's U3 section, ratified
//  by her U3 kickoff message as written). Her principle (R-13r-11): *opening
//  Variorum is calm, and no popup greets a first open.* Her ask (R-13r-12):
//  *"propose a cadance for the 'backup folder' iCloud prompt too … so the two
//  popups are handled, being kept in mind that the other exists, together."*
//
//  ONE small local scheduler owns the day-of-use counter and the shared
//  rules, and BOTH asks register with it, so a later ask (13s onboarding,
//  say) joins the same rules instead of stacking:
//
//    (1) NOTHING ON THE FIRST DAY OF USE. A "day of use" is a calendar day
//        on which Variorum was opened or brought forward, counted on THIS
//        Mac in a LOCAL preference (never synced). An app left open across
//        midnight counts the new day the next time it becomes active.
//    (2) NEVER AT THE LAUNCH MOMENT. An ask waits until the app has been open
//        at least 2 minutes and nothing has been typed for 20 seconds, and
//        never appears while a sheet, a ceremony, a modal or a menu is open
//        (or while the app is in the background).
//    (3) AT MOST ONE ASK PER DAY, and the two never share a day.
//    (4) BOTH ARE ANSWERABLE WITHOUT THE POPUP — Settings ▸ General's "Check
//        for updates automatically" and Data Safety's second-folder door;
//        answering there retires that ask for good (each ask's own
//        `wantsAsking` reads the answer where it lives).
//    (5) ONE HOME — this file.
//
//  The asks: THE UPDATE ASK from the 3rd day of use (Sparkle's own permission
//  window — `UpdateChannel.askPermission`); THE BACKUP-FOLDER ASK from the
//  5th day, only once the library holds writing of the user's own, as a quiet
//  OFFER toast whose Set Up… opens the existing three-door sheet and whose Not
//  Now retires it (the existing mark); ignored, it returns ONCE more after 7
//  further days of use, then never. The update ask ranks first: while it is
//  still open it takes its day, so the backup ask lands "at least one day
//  after the update ask was shown", as written.
//
//  THE NUMBERS ARE PROVISIONAL — QUESTIONS #180 (3rd day, 5th day, 2 minutes,
//  20 seconds, 7 days), tunable from beta use. A walk build may move the day
//  counter by the CONTAINER-PATH `defaults write` (the keys below; the walk
//  sheet carries the commands) — the shipped numbers are never shortened.
//

import AppKit
import Foundation
import GRDB
import VariorumCore

// MARK: - The numbers (PROVISIONAL — QUESTIONS #180)

nonisolated struct CalmAskNumbers: Equatable, Sendable {
    /// The update ask's first day of use.
    var updateAskFromDay = 3
    /// The backup-folder ask's first day of use.
    var backupAskFromDay = 5
    /// How long the app must have been open before any ask.
    var openAtLeast: TimeInterval = 120
    /// How long since the last keystroke before any ask.
    var quietTypingFor: TimeInterval = 20
    /// An ignored backup ask returns once, this many further days of use later.
    var backupReturnsAfterDays = 7

    static let shipped = CalmAskNumbers()
}

// MARK: - The rules (pure — every decision the cadence makes is here)

nonisolated enum CalmAskRules {
    /// One ask as the rules see it on one evaluation.
    struct Ask: Equatable, Sendable {
        var id: String
        /// The first day of use it may appear on.
        var fromDay: Int
        /// The ask's own answer to "is the question still open?" (answered
        /// in Settings or in the popup ⇒ false, for good).
        var wantsAsking: Bool
        var timesShown: Int
        var lastShownDay: Int?
        /// How many times it may ever appear.
        var maxShows: Int
        /// Days of use between showings (nil = never again once shown).
        var returnsAfterDays: Int?
    }

    /// Eligible TODAY on its own terms (the shared one-per-day rule is
    /// `next`'s).
    static func isEligible(_ ask: Ask, day: Int) -> Bool {
        guard ask.wantsAsking, day >= ask.fromDay, ask.timesShown < ask.maxShows else { return false }
        guard ask.timesShown > 0 else { return true }
        guard let gap = ask.returnsAfterDays, let last = ask.lastShownDay else { return false }
        return day >= last + gap
    }

    /// The ONE ask to show today, or nil. `asks` are in priority order; an
    /// ask already shown today blocks every other (rules 3: one per day,
    /// never two on one day).
    static func next(_ asks: [Ask], day: Int, lastAskDay: Int?) -> String? {
        guard lastAskDay != day else { return nil }
        return asks.first { isEligible($0, day: day) }?.id
    }

    /// Rule 2 — a calm moment.
    static func isCalm(
        now: Date, launchedAt: Date, lastTypedAt: Date?, nothingOpen: Bool,
        numbers: CalmAskNumbers
    ) -> Bool {
        guard nothingOpen, now.timeIntervalSince(launchedAt) >= numbers.openAtLeast else { return false }
        guard let lastTypedAt else { return true }
        return now.timeIntervalSince(lastTypedAt) >= numbers.quietTypingFor
    }

    /// Rule 1's counter: noting a use on `today` (a local calendar day) —
    /// a new day counts once; the same day counts nothing.
    static func countingUse(
        on today: String, daysOfUse: Int, lastUseDay: String?
    ) -> (daysOfUse: Int, lastUseDay: String) {
        lastUseDay == today ? (daysOfUse, today) : (daysOfUse + 1, today)
    }

    /// The local calendar day of a moment, as the counter stores it.
    static func dayString(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

// MARK: - The scheduler (one per app — the app delegate holds it)

@MainActor
final class CalmAskScheduler {
    /// THE LOCAL PREFERENCES (this Mac only — never a synced `setting`). The
    /// day counter's two keys are the walk's container-path `defaults write`
    /// targets.
    nonisolated enum Key {
        static let daysOfUse = "variorum.calmAsks.daysOfUse"
        static let lastUseDay = "variorum.calmAsks.lastUseDay"
        static let lastAskDay = "variorum.calmAsks.lastAskDay"
        static func timesShown(_ id: String) -> String { "variorum.calmAsks.\(id).timesShown" }
        static func lastShownDay(_ id: String) -> String { "variorum.calmAsks.\(id).lastShownDay" }
    }

    /// The two asks' ids (each ask's keys carry it).
    nonisolated enum AskID {
        static let update = "updates"
        static let backupFolder = "backupFolder"
    }

    /// One registered ask.
    struct Registration {
        let id: String
        /// Lower ranks first.
        let rank: Int
        let fromDay: Int
        let maxShows: Int
        let returnsAfterDays: Int?
        /// Which host registered it (a window), so a closing window can take
        /// back only ITS registration.
        var host: UUID?
        /// The question is still open (checked only when the ask is otherwise
        /// due, so a costly answer — a store read — is asked rarely).
        let wantsAsking: @MainActor () async -> Bool
        /// Put the ask on screen.
        let present: @MainActor () -> Void
    }

    /// The injectable seams (production: `live`; the pins: scripted).
    struct Leaves {
        var now: @MainActor () -> Date
        var calendar: Calendar
        var defaults: UserDefaults
        /// No sheet, ceremony, modal or menu, and the app frontmost.
        var nothingOpen: @MainActor () -> Bool
    }

    let numbers: CalmAskNumbers
    private let leaves: Leaves
    private(set) var launchedAt: Date
    private(set) var lastTypedAt: Date?
    private var registrations: [Registration] = []
    private var loop: Task<Void, Never>?
    private var keyMonitor: Any?
    /// One evaluation at a time.
    private var evaluating = false

    init(leaves: Leaves, numbers: CalmAskNumbers = .shipped) {
        self.leaves = leaves
        self.numbers = numbers
        launchedAt = leaves.now()
    }

    /// The app's own scheduler.
    static func live() -> CalmAskScheduler {
        CalmAskScheduler(leaves: Leaves(
            now: { Date() },
            calendar: .current,
            defaults: .standard,
            nothingOpen: { CalmAskScheduler.nothingIsOpen() }))
    }

    // MARK: The day of use (rule 1)

    var daysOfUse: Int { leaves.defaults.integer(forKey: Key.daysOfUse) }

    /// At launch and whenever the app becomes active: a new calendar day
    /// counts once.
    func noteActive() {
        let today = CalmAskRules.dayString(for: leaves.now(), calendar: leaves.calendar)
        let counted = CalmAskRules.countingUse(
            on: today, daysOfUse: daysOfUse,
            lastUseDay: leaves.defaults.string(forKey: Key.lastUseDay))
        leaves.defaults.set(counted.daysOfUse, forKey: Key.daysOfUse)
        leaves.defaults.set(counted.lastUseDay, forKey: Key.lastUseDay)
    }

    /// A keystroke reached the app (rule 2's quiet-typing clock).
    func noteTyped() { lastTypedAt = leaves.now() }

    // MARK: Registration

    /// Registers one ask. A host re-registering its OWN ask (same id AND
    /// host) replaces it; a different host's registration for the same id
    /// stands BESIDE the earlier one (F3, ladder round 1: two windows may
    /// each carry the backup ask — replacing by id alone discarded the
    /// earlier window's, so closing the later window left the ask
    /// unregistered while the earlier window still stood). The stored array
    /// keeps REGISTRATION ORDER; rank ordering and the one-voice-per-id
    /// choice live in `effective`.
    func register(_ registration: Registration) {
        registrations.removeAll { $0.id == registration.id && $0.host == registration.host }
        registrations.append(registration)
    }

    /// Takes back an ask — only the registering host's (a window closing
    /// never removes another window's registration).
    func unregister(id: String, host: UUID?) {
        registrations.removeAll { $0.id == id && $0.host == host }
    }

    /// ONE registration speaks per ask id — the most recently registered
    /// surviving one — in rank order. `evaluate` reads THIS list for both
    /// the snapshot and the `present` lookup (the same choice, F3's shape).
    private var effective: [Registration] {
        var newestByID: [String: Registration] = [:]
        for registration in registrations { newestByID[registration.id] = registration }
        return newestByID.values.sorted {
            $0.rank != $1.rank ? $0.rank < $1.rank : $0.id < $1.id
        }
    }

    var registeredIDs: [String] { effective.map(\.id) }

    // MARK: One evaluation

    /// One pass of the cadence: at a calm moment, the one ask due today (if
    /// any) is recorded as shown and put on screen. Returns its id.
    @discardableResult
    func evaluate() async -> String? {
        guard !evaluating else { return nil }
        evaluating = true
        defer { evaluating = false }
        let now = leaves.now()
        guard CalmAskRules.isCalm(
            now: now, launchedAt: launchedAt, lastTypedAt: lastTypedAt,
            nothingOpen: leaves.nothingOpen(), numbers: numbers)
        else { return nil }
        let day = daysOfUse
        let lastAskDay = leaves.defaults.object(forKey: Key.lastAskDay) as? Int
        guard lastAskDay != day else { return nil }
        // The cheap terms first; an ask's own `wantsAsking` (which may read
        // the store) only when it is otherwise due today. `effective` (the
        // newest surviving registration per id, rank order) is the one list
        // this pass and the `present` lookup below both read.
        var snapshot: [CalmAskRules.Ask] = []
        for registration in effective {
            var ask = CalmAskRules.Ask(
                id: registration.id, fromDay: registration.fromDay, wantsAsking: true,
                timesShown: leaves.defaults.integer(forKey: Key.timesShown(registration.id)),
                lastShownDay: leaves.defaults.object(forKey: Key.lastShownDay(registration.id)) as? Int,
                maxShows: registration.maxShows, returnsAfterDays: registration.returnsAfterDays)
            if CalmAskRules.isEligible(ask, day: day) {
                ask.wantsAsking = await registration.wantsAsking()
            }
            snapshot.append(ask)
            if CalmAskRules.isEligible(ask, day: day) { break }  // the highest-ranked due ask wins
        }
        // The world may have moved while an answer was awaited.
        guard CalmAskRules.isCalm(
            now: leaves.now(), launchedAt: launchedAt, lastTypedAt: lastTypedAt,
            nothingOpen: leaves.nothingOpen(), numbers: numbers),
            let id = CalmAskRules.next(snapshot, day: day, lastAskDay: lastAskDay),
            let registration = effective.first(where: { $0.id == id })
        else { return nil }
        let shown = leaves.defaults.integer(forKey: Key.timesShown(id))
        leaves.defaults.set(shown + 1, forKey: Key.timesShown(id))
        leaves.defaults.set(day, forKey: Key.lastShownDay(id))
        leaves.defaults.set(day, forKey: Key.lastAskDay)
        registration.present()
        return id
    }

    // MARK: Running

    /// Starts the cadence: the keystroke clock (a LOCAL key monitor — this
    /// app's own keystrokes only, the event returned untouched) and a quiet
    /// evaluation every 15 s. Cost per pass: O(registered asks); a store read
    /// only when an ask is otherwise due today (P1).
    func start(every interval: Duration = .seconds(15)) {
        guard loop == nil else { return }
        noteActive()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.noteTyped()
            return event
        }
        loop = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled, let self else { return }
                await self.evaluate()
            }
        }
    }

    /// Rule 2's "nothing open", read from AppKit: the app frontmost, no modal
    /// session, no sheet on any visible window (a ceremony is a sheet; What's
    /// New is a sheet), and not inside a menu or a drag (the run loop is in
    /// its event-tracking mode then).
    static func nothingIsOpen() -> Bool {
        guard NSApp.isActive, NSApp.modalWindow == nil else { return false }
        if RunLoop.main.currentMode == .eventTracking { return false }
        for window in NSApp.windows where window.isVisible {
            if window.attachedSheet != nil || window.isSheet { return false }
        }
        return true
    }
}

// MARK: - "Writing of the user's own" (the backup ask's condition)

/// The backup-folder ask waits until the library holds a note the user MADE
/// — not the seeded welcome content. Read as: a live note with words on its
/// page that wears none of the SEEDED tags (every seeded note wears its
/// book's reserved tag — the tutorial's, each sample book's, and #classics)
/// and is not the seeded quick note (recognised by its reserved title, the
/// seeders' own identity convention). An EXISTS read that stops at the
/// first match (P1: a store with writing answers on its first row); a store
/// holding only the seed scans the seed's few dozen notes.
nonisolated enum OwnWriting {
    /// The seeded tags, from the seeders' own constants (a new seeded book
    /// joins through `SampleLibrarySeeder.Book.all`).
    static var seedTagPaths: [String] {
        [TutorialSeeder.tagName, SampleLibrarySeeder.classicsTagPath]
            + SampleLibrarySeeder.Book.all.map(\.tagName)
    }

    /// The seeded notes recognised by title.
    static var seedTitles: [String] { [SampleLibraryWelcome.quicknoteTitle] }

    static func exists(_ db: Database) throws -> Bool {
        let tags = seedTagPaths
        let titles = seedTitles
        let tagMarks = Array(repeating: "?", count: tags.count).joined(separator: ", ")
        let titleMarks = Array(repeating: "?", count: titles.count).joined(separator: ", ")
        let sql = """
            SELECT EXISTS (
              SELECT 1 FROM container c
              WHERE c.kind = 'post' AND c.deleted_at IS NULL
                AND COALESCE(c.title, '') NOT IN (\(titleMarks))
                AND NOT EXISTS (
                  SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                  WHERE pt.post_id = c.id AND pt.deleted_at IS NULL AND t.deleted_at IS NULL
                    AND t.path IN (\(tagMarks)))
                AND EXISTS (
                  SELECT 1 FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  JOIN variant v ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
                  WHERE cb.container_id = c.id AND cb.deleted_at IS NULL AND v.deleted_at IS NULL
                    AND length(trim(v.working_text)) > 0))
            """
        return try Bool.fetchOne(db, sql: sql, arguments: StatementArguments(titles + tags)) ?? false
    }
}

/// The backup ask's `wantsAsking` half that reads the STORE: once true it
/// stays true (writing does not un-happen for the purpose of an ask); a "no"
/// is re-read at most every five minutes, so the 15-s cadence never becomes a
/// 15-s store read.
@MainActor
final class OwnWritingProbe {
    private let session: AppSession
    private var found = false
    private var lastNoAt: Date?

    init(session: AppSession) { self.session = session }

    func holdsOwnWriting() async -> Bool {
        if found { return true }
        if let lastNoAt, Date().timeIntervalSince(lastNoAt) < 300 { return false }
        let yes = (try? await session.database.read { db in try OwnWriting.exists(db) }) ?? false
        if yes { found = true } else { lastNoAt = Date() }
        return yes
    }
}

/// The backup ask's words (functional and honest; 13s re-voices). The
/// question is the sheet's own title, word for word (R-13r-14's lesson
/// quotes it); Not Now is the sheet's own door.
nonisolated enum CalmAskCopy {
    static var backupQuestion: String { ProtectionCopy.iCloudOfferTitle }
    static let backupSetUpDoor = "Set Up\u{2026}"
    static var backupNotNowDoor: String { ProtectionCopy.iCloudOfferNotNowDoor }
}
