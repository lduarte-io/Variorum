//
//  PassphraseReminder.swift
//  Variorum (shared: Mac + Mobile — the phone's face is U3's)
//
//  VX-306 U2 — RULE 3's REMINDER (`notes/CastleRules.md` rule 3: "Until a passphrase exists, the app says so now and
//  then … at the third launch, then weekly twice, then with a 'don't show again'; and always right before the first
//  backup and at the first launch after a quiet road has failed"; §7c (7)'s words; the plan's U2 addendum).
//
//    - THE MODEL'S TWO MOMENTS are `assess`'s (`OwedAct.askPassphrase(.beforeFirstBackup / .quietRoadFailed)`,
//      read from the open's report): "always" — shown at the open that owes one, whatever the schedule, even after
//      *Don't show again* (which retires the schedule, not rule 3's "always"); their *Not now* writes nothing.
//    - THE SCHEDULE is the face's, a LOCAL ledger per library in this Mac's defaults, its keys beside `CalmAsks`'
//      (`variorum.calmAsks.passphrase.<libraryID>.*` — never synced, never in the store): the launches counted
//      (once per process, only on a writing road), the scheduled showings, the last one's moment, and the retire
//      flag. The first showing at the THIRD launch; each later one a week (7 × 24 h) after the last; *Don't show
//      again* offered once the record counts THREE dismissals (`ProtectionRecord.reminderDismissals` — the
//      executor's doc: "the returning reminder's 'don't show again' counts three"; PROVISIONAL P-VX306-U2-3).
//    - A scheduled showing's *Not now* — and *Don't show again* — record one dismissal through
//      `recordPassphraseReminderDismissed` (one record write); *Don't show again* also retires the schedule here.
//    - Never shown once a passphrase exists (`record.passphraseSet`).
//

import Foundation
import Observation
import VariorumCore

// MARK: - The rules (pure)

nonisolated enum PassphraseReminderRules {
    /// The launch of the first scheduled showing (rule 3: "at the third launch").
    static let firstLaunch = 3
    /// The gap between scheduled showings (rule 3: "weekly").
    static let returnGap: TimeInterval = 7 * 24 * 60 * 60
    /// The dismissals after which a scheduled showing offers *Don't show again* ("then with a 'don't show again'" —
    /// after the first showing and the two weekly ones).
    static let dismissalsBeforeDontShowAgain = 3

    /// What this Mac's ledger holds for one library.
    struct Ledger: Equatable, Sendable {
        var launches = 0
        var scheduledShows = 0
        var lastScheduledShowAt: Date?
        var retired = false
    }

    /// A showing: whether it is the schedule's (it counts, and its *Not now* is a recorded dismissal), the model's
    /// moment it answers (if any), and whether it offers *Don't show again*.
    struct Showing: Equatable, Sendable {
        var scheduled: Bool
        var moment: PassphraseAsk?
        var offersDontShowAgain: Bool
    }

    /// The schedule is due now.
    static func scheduledDue(_ ledger: Ledger, now: Date) -> Bool {
        guard !ledger.retired else { return false }
        guard ledger.scheduledShows > 0 else { return ledger.launches >= firstLaunch }
        guard let last = ledger.lastScheduledShowAt else { return true }
        return now.timeIntervalSince(last) >= returnGap
    }

    /// The showing owed now, or nil. `moment`: the model's moment still unanswered at this open.
    static func showing(
        passphraseSet: Bool, moment: PassphraseAsk?, ledger: Ledger, dismissals: Int, now: Date
    ) -> Showing? {
        guard !passphraseSet else { return nil }
        let scheduled = scheduledDue(ledger, now: now)
        guard scheduled || moment != nil else { return nil }
        return Showing(
            scheduled: scheduled, moment: moment,
            offersDontShowAgain: scheduled && dismissals >= dismissalsBeforeDontShowAgain)
    }
}

// MARK: - The ledger (this Mac's defaults — local, per library)

nonisolated struct PassphraseReminderLedger: @unchecked Sendable {
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    /// The defaults suite a TEST bootstrap's ledger writes (never the app's own domain).
    static let testSuiteName = "io.lduarte.Variorum.vx306-reminder-tests"

    /// The keys, beside `CalmAskScheduler.Key`'s (`variorum.calmAsks.*`).
    enum Key {
        static func launches(_ libraryID: String) -> String { "variorum.calmAsks.passphrase.\(libraryID).launches" }
        static func shows(_ libraryID: String) -> String { "variorum.calmAsks.passphrase.\(libraryID).shows" }
        static func lastShownAt(_ libraryID: String) -> String { "variorum.calmAsks.passphrase.\(libraryID).lastShownAt" }
        static func retired(_ libraryID: String) -> String { "variorum.calmAsks.passphrase.\(libraryID).retired" }
    }

    func read(_ libraryID: String) -> PassphraseReminderRules.Ledger {
        let last = defaults.object(forKey: Key.lastShownAt(libraryID)) as? Double
        return PassphraseReminderRules.Ledger(
            launches: defaults.integer(forKey: Key.launches(libraryID)),
            scheduledShows: defaults.integer(forKey: Key.shows(libraryID)),
            lastScheduledShowAt: last.map { Date(timeIntervalSince1970: $0) },
            retired: defaults.bool(forKey: Key.retired(libraryID)))
    }

    func noteLaunch(_ libraryID: String) {
        defaults.set(defaults.integer(forKey: Key.launches(libraryID)) + 1, forKey: Key.launches(libraryID))
    }

    func recordScheduledShow(_ libraryID: String, at date: Date) {
        defaults.set(defaults.integer(forKey: Key.shows(libraryID)) + 1, forKey: Key.shows(libraryID))
        defaults.set(date.timeIntervalSince1970, forKey: Key.lastShownAt(libraryID))
    }

    func retire(_ libraryID: String) { defaults.set(true, forKey: Key.retired(libraryID)) }

    // MARK: Once per process

    private static let lock = NSLock()
    nonisolated(unsafe) private static var countedThisProcess: Set<String> = []

    /// A launch counted ONCE per process per library (a reopen inside one process — an adoption's — is not a launch).
    func noteLaunchOncePerProcess(_ libraryID: String) {
        let first = Self.lock.withLock { Self.countedThisProcess.insert(libraryID).inserted }
        if first { noteLaunch(libraryID) }
    }
}

// MARK: - The model

@MainActor
@Observable
final class PassphraseReminderModel {
    /// The bar on screen (nil: none).
    private(set) var showing: PassphraseReminderRules.Showing?

    @ObservationIgnored private let libraryID: String
    @ObservationIgnored private var moment: PassphraseAsk?
    @ObservationIgnored private let ledger: PassphraseReminderLedger
    @ObservationIgnored private let facts: () -> (passphraseSet: Bool, dismissals: Int)
    @ObservationIgnored private let recordDismissal: () async -> Bool
    @ObservationIgnored private let now: () -> Date

    init(
        libraryID: String, moment: PassphraseAsk?, ledger: PassphraseReminderLedger,
        facts: @escaping () -> (passphraseSet: Bool, dismissals: Int),
        recordDismissal: @escaping () async -> Bool,
        now: @escaping () -> Date = { Date() }
    ) {
        self.libraryID = libraryID
        self.moment = moment
        self.ledger = ledger
        self.facts = facts
        self.recordDismissal = recordDismissal
        self.now = now
    }

    /// Show the reminder when it is owed now (at the open, and when the app becomes active again — a week can pass
    /// in one session). A scheduled showing is counted the moment it shows.
    func evaluate() {
        guard showing == nil else { return }
        let standing = facts()
        guard let next = PassphraseReminderRules.showing(
            passphraseSet: standing.passphraseSet, moment: moment, ledger: ledger.read(libraryID),
            dismissals: standing.dismissals, now: now())
        else { return }
        if next.scheduled { ledger.recordScheduledShow(libraryID, at: now()) }
        showing = next
    }

    /// *Not now*: the bar goes; a scheduled showing records a dismissal (one record write).
    func notNow() async {
        guard let shown = showing else { return }
        showing = nil
        moment = nil
        if shown.scheduled { _ = await recordDismissal() }
    }

    /// *Don't show again* (offered by a scheduled showing after three dismissals): the schedule retires here, and
    /// one dismissal is recorded. Rule 3's two "always" moments are not retired by it.
    func dontShowAgain() async {
        guard let shown = showing, shown.offersDontShowAgain else { return }
        showing = nil
        moment = nil
        ledger.retire(libraryID)
        _ = await recordDismissal()
    }

    /// A passphrase now exists — the reminder is done.
    func passphraseWasSet() {
        showing = nil
        moment = nil
    }
}
