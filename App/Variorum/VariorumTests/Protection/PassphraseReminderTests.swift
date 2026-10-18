//
//  PassphraseReminderTests.swift
//  VariorumTests — VX-306 U2 piece 6: RULE 3's REMINDER and THE SET-PASSPHRASE SHEET, pure (no keychain, no store):
//  the schedule's arithmetic (the third launch, then weekly, *Don't show again* after three dismissals, retired ⇒
//  only rule 3's two "always" moments), the moments shown whatever the schedule, the ledger in a throwaway defaults
//  suite (never the app's domain), the model's presses (a scheduled *Not now* records a dismissal; a moment's writes
//  nothing; *Don't show again* retires the schedule), and the sheet's refusals. (The moments read from a real open,
//  the dismissal's record write and the passphrase's road through the executor are `ProtectionHonestFacesTests`'.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 3's reminder and the set-passphrase sheet (pure)")
@MainActor
struct PassphraseReminderTests {
    typealias Rules = PassphraseReminderRules
    static let t0 = Date(timeIntervalSinceReferenceDate: 790_000_000)
    static let day: TimeInterval = 24 * 60 * 60

    // MARK: - The schedule's arithmetic

    @Test func theFirstShowingIsAtTheThirdLaunch() {
        for launches in 0...2 {
            #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: .init(launches: launches),
                                  dismissals: 0, now: Self.t0) == nil, "launch \(launches)")
        }
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: .init(launches: 3), dismissals: 0, now: Self.t0)
            == .init(scheduled: true, moment: nil, offersDontShowAgain: false))
    }

    @Test func thenWeeklyAndDontShowAgainAfterThreeDismissals() {
        let shown = Rules.Ledger(launches: 9, scheduledShows: 1, lastScheduledShowAt: Self.t0)
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: shown, dismissals: 1,
                              now: Self.t0 + 6 * Self.day) == nil, "not within the week")
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: shown, dismissals: 1,
                              now: Self.t0 + 7 * Self.day)?.scheduled == true, "a week after the last")
        // The first showing and the two weekly ones dismissed: the next one offers Don't show again.
        let third = Rules.Ledger(launches: 20, scheduledShows: 3, lastScheduledShowAt: Self.t0)
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: third, dismissals: 2,
                              now: Self.t0 + 7 * Self.day)?.offersDontShowAgain == false)
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: third, dismissals: 3,
                              now: Self.t0 + 7 * Self.day)?.offersDontShowAgain == true)
    }

    @Test func retiredLeavesOnlyRule3sTwoAlwaysMoments() {
        let retired = Rules.Ledger(launches: 30, scheduledShows: 4, lastScheduledShowAt: Self.t0, retired: true)
        #expect(Rules.showing(passphraseSet: false, moment: nil, ledger: retired, dismissals: 4,
                              now: Self.t0 + 30 * Self.day) == nil)
        for moment in [PassphraseAsk.beforeFirstBackup, .quietRoadFailed] {
            #expect(Rules.showing(passphraseSet: false, moment: moment, ledger: retired, dismissals: 4, now: Self.t0)
                == .init(scheduled: false, moment: moment, offersDontShowAgain: false), "\(moment) is always")
        }
    }

    @Test func theMomentsShowAtTheFirstLaunchAndNothingShowsOnceAPassphraseExists() {
        #expect(Rules.showing(passphraseSet: false, moment: .beforeFirstBackup, ledger: .init(launches: 1),
                              dismissals: 0, now: Self.t0)?.moment == .beforeFirstBackup)
        #expect(Rules.showing(passphraseSet: true, moment: .quietRoadFailed, ledger: .init(launches: 3),
                              dismissals: 0, now: Self.t0) == nil)
    }

    // MARK: - The ledger (a throwaway suite)

    /// A throwaway defaults suite, removed when the test lets go of it.
    nonisolated final class Suite: @unchecked Sendable {
        let name = "vx306-reminder-\(UUID().uuidString)"
        let defaults: UserDefaults
        init() { defaults = UserDefaults(suiteName: name)! }
        deinit { defaults.removePersistentDomain(forName: name) }
    }

    @Test func theLedgerCountsShowsAndRetiresPerLibraryUnderTheCalmAsksKeys() {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        ledger.noteLaunch("lib-a")
        ledger.noteLaunch("lib-a")
        ledger.noteLaunch("lib-b")
        ledger.recordScheduledShow("lib-a", at: Self.t0)
        ledger.retire("lib-b")
        #expect(ledger.read("lib-a") == .init(launches: 2, scheduledShows: 1, lastScheduledShowAt: Self.t0, retired: false))
        #expect(ledger.read("lib-b") == .init(launches: 1, scheduledShows: 0, lastScheduledShowAt: nil, retired: true))
        #expect(PassphraseReminderLedger.Key.launches("lib-a").hasPrefix("variorum.calmAsks."), "beside CalmAsks' keys")
        // Once per process per library.
        let library = "lib-\(UUID().uuidString)"
        ledger.noteLaunchOncePerProcess(library)
        ledger.noteLaunchOncePerProcess(library)
        #expect(ledger.read(library).launches == 1)
    }

    // MARK: - The model's presses

    final class Dismissals { var count = 0 }

    func model(
        _ ledger: PassphraseReminderLedger, libraryID: String = "lib", moment: PassphraseAsk? = nil,
        passphraseSet: Bool = false, dismissals: Int = 0, now: Date = PassphraseReminderTests.t0,
        recorded: Dismissals = Dismissals()
    ) -> PassphraseReminderModel {
        PassphraseReminderModel(
            libraryID: libraryID, moment: moment, ledger: ledger,
            facts: { (passphraseSet: passphraseSet, dismissals: dismissals) },
            recordDismissal: { recorded.count += 1; return true }, now: { now })
    }

    @Test func aScheduledShowingCountsAndItsNotNowRecordsADismissal() async {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        for _ in 0..<3 { ledger.noteLaunch("lib") }
        let recorded = Dismissals()
        let reminder = model(ledger, recorded: recorded)
        reminder.evaluate()
        #expect(reminder.showing?.scheduled == true)
        #expect(ledger.read("lib").scheduledShows == 1 && ledger.read("lib").lastScheduledShowAt == Self.t0)
        reminder.evaluate()
        #expect(ledger.read("lib").scheduledShows == 1, "counted once while it shows")
        await reminder.notNow()
        #expect(reminder.showing == nil && recorded.count == 1)
        reminder.evaluate()
        #expect(reminder.showing == nil, "not again within the week")
    }

    @Test func aMomentsNotNowWritesNothingAndItIsNotShownAgainThisLaunch() async {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        ledger.noteLaunch("lib")
        let recorded = Dismissals()
        let reminder = model(ledger, moment: .beforeFirstBackup, recorded: recorded)
        reminder.evaluate()
        #expect(reminder.showing == .init(scheduled: false, moment: .beforeFirstBackup, offersDontShowAgain: false))
        await reminder.notNow()
        #expect(recorded.count == 0 && ledger.read("lib").scheduledShows == 0, "a moment's Not now writes nothing")
        reminder.evaluate()
        #expect(reminder.showing == nil)
    }

    @Test func dontShowAgainRetiresTheScheduleAndRecordsADismissal() async {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        for _ in 0..<12 { ledger.noteLaunch("lib") }
        ledger.recordScheduledShow("lib", at: Self.t0 - 8 * Self.day)
        let recorded = Dismissals()
        let reminder = model(ledger, dismissals: 3, recorded: recorded)
        reminder.evaluate()
        #expect(reminder.showing?.offersDontShowAgain == true)
        await reminder.dontShowAgain()
        #expect(reminder.showing == nil && recorded.count == 1 && ledger.read("lib").retired)
    }

    @Test func dontShowAgainIsRefusedWhenNotOfferedAndAPassphraseEndsIt() async {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        for _ in 0..<3 { ledger.noteLaunch("lib") }
        let recorded = Dismissals()
        let reminder = model(ledger, recorded: recorded)
        reminder.evaluate()
        await reminder.dontShowAgain()
        #expect(reminder.showing != nil && recorded.count == 0 && !ledger.read("lib").retired, "not offered — no-op")
        reminder.passphraseWasSet()
        #expect(reminder.showing == nil)
        let set = model(ledger, passphraseSet: true)
        set.evaluate()
        #expect(set.showing == nil, "never shown once a passphrase exists")
    }

    // MARK: - The set-passphrase sheet

    @Test func theSheetRefusesAMismatchAndSetsOnceOnTheRoad() async {
        var typed: [String] = []
        var finished: [Bool] = []
        let sheet = SetPassphraseModel(alreadySet: false, setRoad: { typed.append($0); return .set }) { finished.append($0) }
        #expect(sheet.refusal == nil)
        #expect(!sheet.canSubmit(passphrase: "a", again: ""))
        await sheet.submit(passphrase: "one", again: "two")
        #expect(sheet.refusal == ProtectionWords.setPassphraseMismatch && typed.isEmpty)
        await sheet.submit(passphrase: " one ", again: " one ")
        #expect(typed == [" one "], "never trimmed")
        #expect(finished == [true])
    }

    @Test func theSheetRefusesAtOnceWhenAPassphraseExistsAndSaysWhenTheRoadFails() async {
        var calls = 0
        let refused = SetPassphraseModel(alreadySet: true, setRoad: { _ in calls += 1; return .set }) { _ in }
        #expect(refused.refusal == ProtectionWords.setPassphraseAlreadySet)
        #expect(!refused.canSubmit(passphrase: "x", again: "x"))
        await refused.submit(passphrase: "x", again: "x")
        #expect(calls == 0)
        let failing = SetPassphraseModel(alreadySet: false, setRoad: { _ in .failed }) { _ in }
        await failing.submit(passphrase: "x", again: "x")
        #expect(failing.refusal == ProtectionWords.setPassphraseFailed)
        let lateRefusal = SetPassphraseModel(alreadySet: false, setRoad: { _ in .alreadySet }) { _ in }
        await lateRefusal.submit(passphrase: "x", again: "x")
        #expect(lateRefusal.refusal == ProtectionWords.setPassphraseAlreadySet)
        var left: [Bool] = []
        let cancelled = SetPassphraseModel(alreadySet: false, setRoad: { _ in .set }) { left.append($0) }
        cancelled.cancel()
        #expect(left == [false], "the way out writes nothing")
    }

    /// The open library's faces model: a passphrase set through its sheet retires the reminder and speaks §7c (7)'s
    /// receipt; the sheet refuses when one exists.
    @Test func aPassphraseSetThroughTheFacesModelRetiresTheReminderAndSpeaksTheReceipt() async {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let ledger = PassphraseReminderLedger(defaults: suite.defaults)
        let reminder = model(ledger, moment: .beforeFirstBackup)
        reminder.evaluate()
        var exists = false
        let standing = RoadStandingModel(
            faces: .none, reminder: reminder, setPassphrase: { _ in exists = true; return .set },
            passphraseExists: { exists }, receiptsOwed: { [] })
        var spoken: [String] = []
        standing.speak = { spoken.append($0) }
        var closed = 0
        #expect(standing.offersSetPassphrase, "no passphrase yet — the pane's row renders")
        let sheet = standing.makeSetPassphraseSheet { closed += 1 }
        #expect(!sheet.alreadySet)
        await sheet.submit(passphrase: "p", again: "p")
        #expect(closed == 1 && reminder.showing == nil)
        #expect(spoken == ["Passphrase set. Your twelve words still open the library too."])
        #expect(!standing.offersSetPassphrase, "a passphrase now — the pane's row goes (NIT 4)")
        #expect(standing.makeSetPassphraseSheet {}.alreadySet, "a second sheet refuses at once")
    }

    /// THE LADDER'S ROUND-1 NIT 4: over a library that already has a passphrase the pane's *Set a passphrase…* row is
    /// not offered (the sheet behind it could only refuse — P-2); a sheet opened anyway (the reminder never shows then)
    /// still refuses at once.
    @Test func aLibraryWithAPassphraseOffersNoSetPassphraseRow() {
        let suite = Suite()
        defer { withExtendedLifetime(suite) {} }
        let standing = RoadStandingModel(
            faces: .none, reminder: model(PassphraseReminderLedger(defaults: suite.defaults), moment: nil),
            setPassphrase: { _ in .alreadySet }, passphraseExists: { true }, receiptsOwed: { [] })
        #expect(!standing.offersSetPassphrase)
        #expect(standing.makeSetPassphraseSheet {}.alreadySet)
    }
}
