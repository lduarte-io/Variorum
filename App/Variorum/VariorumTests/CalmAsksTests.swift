//
//  CalmAsksTests.swift
//  VariorumTests
//
//  Phase 13r U3-A — THE CALM-ASKS CADENCE (the plan's U3 section, ratified
//  as written) and the two asks it schedules: R-13r-11's update ask (Sparkle's
//  early prompt declined; the question asked from the 3rd day of use) and
//  R-13r-12's backup-folder ask (an offer toast from the 5th day, once the
//  library holds her own writing; ignored, it returns ONCE after 7 more days).
//
//  The rules are pinned pure; the scheduler is driven through a scripted
//  clock, a throwaway defaults suite and a scripted "nothing open" — a
//  simulated run of DAYS OF USE, each a launch-like `noteActive()` with the
//  clock moved, exactly as the cadence counts them. No Sparkle object, no
//  window, no store of the dev domain is touched (the OwnWriting pin runs
//  over an in-memory store).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The calm-asks cadence (13r U3-A — R-13r-11 + R-13r-12)", .serialized)
@MainActor
struct CalmAsksTests {
    // MARK: - The pure rules

    private static func ask(
        _ id: String, from: Int, wants: Bool = true, shown: Int = 0, last: Int? = nil,
        max: Int = .max, every: Int? = 1
    ) -> CalmAskRules.Ask {
        CalmAskRules.Ask(id: id, fromDay: from, wantsAsking: wants, timesShown: shown,
                         lastShownDay: last, maxShows: max, returnsAfterDays: every)
    }

    @Test func theShippedNumbersAreTheCadencesProvisionalOnes() {
        let n = CalmAskNumbers.shipped
        #expect(n.updateAskFromDay == 3 && n.backupAskFromDay == 5)
        #expect(n.openAtLeast == 120 && n.quietTypingFor == 20 && n.backupReturnsAfterDays == 7)
    }

    @Test func nothingBeforeItsDayAndOneAskPerDayInRankOrder() {
        let asks = [Self.ask("updates", from: 3), Self.ask("backupFolder", from: 5, max: 2, every: 7)]
        #expect(CalmAskRules.next(asks, day: 1, lastAskDay: nil) == nil, "nothing on the first day")
        #expect(CalmAskRules.next(asks, day: 2, lastAskDay: nil) == nil)
        #expect(CalmAskRules.next(asks, day: 3, lastAskDay: nil) == "updates")
        #expect(CalmAskRules.next(asks, day: 3, lastAskDay: 3) == nil, "at most one ask per day")
        // Day 5 with the update ask still open: it takes the day; the backup
        // ask waits — the two never share a day.
        #expect(CalmAskRules.next(asks, day: 5, lastAskDay: 4) == "updates")
        // Answered (in the popup or in Settings): it never asks again.
        let answered = [Self.ask("updates", from: 3, wants: false, shown: 1, last: 3),
                        Self.ask("backupFolder", from: 5, max: 2, every: 7)]
        #expect(CalmAskRules.next(answered, day: 4, lastAskDay: 3) == nil)
        #expect(CalmAskRules.next(answered, day: 5, lastAskDay: 3) == "backupFolder")
    }

    @Test func anIgnoredBackupAskReturnsOnceAfterSevenMoreDaysThenNever() {
        let after = Self.ask("backupFolder", from: 5, shown: 1, last: 5, max: 2, every: 7)
        #expect(!CalmAskRules.isEligible(after, day: 11))
        #expect(CalmAskRules.isEligible(after, day: 12), "once more, 7 days of use later")
        let twice = Self.ask("backupFolder", from: 5, shown: 2, last: 12, max: 2, every: 7)
        #expect(!CalmAskRules.isEligible(twice, day: 19) && !CalmAskRules.isEligible(twice, day: 400),
                "then never")
    }

    @Test func aCalmMomentIsTwoMinutesInTwentySecondsQuietAndNothingOpen() {
        let t0 = Date(timeIntervalSince1970: 1_000_000)
        let n = CalmAskNumbers.shipped
        func calm(_ at: TimeInterval, typed: TimeInterval?, open: Bool = true) -> Bool {
            CalmAskRules.isCalm(now: t0.addingTimeInterval(at), launchedAt: t0,
                                lastTypedAt: typed.map { t0.addingTimeInterval($0) },
                                nothingOpen: open, numbers: n)
        }
        #expect(!calm(5, typed: nil), "never at the launch moment")
        #expect(!calm(119, typed: nil))
        #expect(calm(120, typed: nil))
        #expect(!calm(300, typed: 290), "typed ten seconds ago")
        #expect(calm(300, typed: 280), "twenty quiet seconds")
        #expect(!calm(300, typed: nil, open: false), "a sheet, ceremony, modal or menu is open")
    }

    @Test func aDayOfUseCountsOncePerCalendarDay() {
        #expect(CalmAskRules.countingUse(on: "2026-10-04", daysOfUse: 0, lastUseDay: nil) == (1, "2026-10-04"))
        #expect(CalmAskRules.countingUse(on: "2026-10-04", daysOfUse: 1, lastUseDay: "2026-10-04") == (1, "2026-10-04"))
        #expect(CalmAskRules.countingUse(on: "2026-10-09", daysOfUse: 1, lastUseDay: "2026-10-04") == (2, "2026-10-09"),
                "days of USE, not calendar days: a gap counts one")
    }

    // MARK: - The scheduler, over simulated days of use

    @MainActor
    final class World {
        var now = Date(timeIntervalSince1970: 1_790_000_000)  // a fixed instant
        var open = false
        var updateOpen = true
        var ownWriting = false
        var backupOpen = true
        var shown: [String] = []
        let defaults: UserDefaults
        let suite: String
        var calendar: Calendar = {
            var c = Calendar(identifier: .gregorian)
            c.timeZone = TimeZone(identifier: "America/Los_Angeles")!
            return c
        }()
        init() {
            suite = "variorum.tests.calmasks.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }
        func scheduler() -> CalmAskScheduler {
            let s = CalmAskScheduler(leaves: .init(
                now: { [unowned self] in self.now }, calendar: calendar, defaults: defaults,
                nothingOpen: { [unowned self] in !self.open }))
            s.register(.init(
                id: CalmAskScheduler.AskID.backupFolder, rank: 1, fromDay: 5, maxShows: 2,
                returnsAfterDays: 7, host: UUID(),
                wantsAsking: { [unowned self] in self.backupOpen && self.ownWriting },
                present: { [unowned self] in self.shown.append("backup") }))
            s.register(.init(
                id: CalmAskScheduler.AskID.update, rank: 0, fromDay: 3, maxShows: .max,
                returnsAfterDays: 1, host: nil,
                wantsAsking: { [unowned self] in self.updateOpen },
                present: { [unowned self] in self.shown.append("update") }))
            return s
        }
        /// A day of use: the clock moves to the next calendar day's noon, the
        /// app launches (a fresh scheduler over the same defaults), and is
        /// used past the two-minute line.
        func nextDay(_ days: Int = 1) -> CalmAskScheduler {
            now = calendar.date(byAdding: .day, value: days, to: now)!
            let s = scheduler()
            s.noteActive()
            now = now.addingTimeInterval(180)
            return s
        }
    }

    @Test func aSimulatedRunOfDaysAsksExactlyAsTheCadenceSays() async {
        let w = World()
        defer { w.defaults.removePersistentDomain(forName: w.suite) }
        // Day 1, 2: nothing.
        var s = w.nextDay()
        #expect(s.daysOfUse == 1)
        #expect(await s.evaluate() == nil)
        s = w.nextDay()
        #expect(await s.evaluate() == nil)
        // Day 3: the update ask — once, not again the same day.
        s = w.nextDay()
        #expect(s.daysOfUse == 3)
        #expect(await s.evaluate() == CalmAskScheduler.AskID.update)
        #expect(await s.evaluate() == nil, "one ask per day")
        w.updateOpen = false  // she answered (popup or Settings)
        // Day 4: nothing (the backup ask is not due yet).
        s = w.nextDay()
        #expect(await s.evaluate() == nil)
        // Day 5, no writing of her own yet: nothing.
        s = w.nextDay()
        #expect(await s.evaluate() == nil, "the backup ask waits for her own writing")
        w.ownWriting = true
        #expect(await s.evaluate() == CalmAskScheduler.AskID.backupFolder)
        // Ignored: back once, 7 days of use later (day 12), then never.
        for _ in 6...11 {
            s = w.nextDay()
            #expect(await s.evaluate() == nil)
        }
        s = w.nextDay()
        #expect(s.daysOfUse == 12)
        #expect(await s.evaluate() == CalmAskScheduler.AskID.backupFolder)
        for _ in 13...30 {
            s = w.nextDay()
            #expect(await s.evaluate() == nil)
        }
        #expect(w.shown == ["update", "backup", "backup"])
    }

    @Test func theAsksNeverAppearAtLaunchWhileTypingOrOverASheet() async {
        let w = World()
        defer { w.defaults.removePersistentDomain(forName: w.suite) }
        for _ in 1...2 { _ = w.nextDay() }
        // Day 3, the launch moment itself:
        w.now = w.calendar.date(byAdding: .day, value: 1, to: w.now)!
        let s = w.scheduler()
        s.noteActive()
        #expect(await s.evaluate() == nil, "never at the launch moment")
        w.now = w.now.addingTimeInterval(130)
        s.noteTyped()
        w.now = w.now.addingTimeInterval(5)
        #expect(await s.evaluate() == nil, "not while she is typing")
        w.now = w.now.addingTimeInterval(30)
        w.open = true
        #expect(await s.evaluate() == nil, "not over a sheet, ceremony or menu")
        w.open = false
        #expect(await s.evaluate() == CalmAskScheduler.AskID.update)
    }

    @Test func theUpdateAskStillOpenOnDayFiveTakesItAndTheBackupAskWaits() async {
        let w = World()
        defer { w.defaults.removePersistentDomain(forName: w.suite) }
        w.ownWriting = true
        for _ in 1...4 { _ = w.nextDay() }  // four short days: no calm moment evaluated
        var s = w.nextDay()
        #expect(await s.evaluate() == CalmAskScheduler.AskID.update)
        w.updateOpen = false
        s = w.nextDay()
        #expect(await s.evaluate() == CalmAskScheduler.AskID.backupFolder,
                "at least one day after the update ask was shown")
    }

    @Test func anAppLeftOpenAcrossMidnightCountsTheNewDayWhenItBecomesActive() {
        let w = World()
        defer { w.defaults.removePersistentDomain(forName: w.suite) }
        let s = w.nextDay()
        #expect(s.daysOfUse == 1)
        // The day began at 07:16 local; twenty hours on is 03:16 the next day.
        w.now = w.calendar.date(byAdding: .hour, value: 20, to: w.now)!  // past midnight
        #expect(s.daysOfUse == 1, "nothing counts until the app becomes active")
        s.noteActive()
        #expect(s.daysOfUse == 2)
        s.noteActive()
        #expect(s.daysOfUse == 2, "the same day counts once")
    }

    @Test func aClosingWindowTakesBackOnlyItsOwnRegistration() {
        let w = World()
        defer { w.defaults.removePersistentDomain(forName: w.suite) }
        let s = w.scheduler()
        #expect(s.registeredIDs == [CalmAskScheduler.AskID.update, CalmAskScheduler.AskID.backupFolder],
                "rank order: the update ask first")
        s.unregister(id: CalmAskScheduler.AskID.backupFolder, host: UUID())
        #expect(s.registeredIDs.contains(CalmAskScheduler.AskID.backupFolder), "another window's id")
    }

    // MARK: - The update ask's two halves (R-13r-11)

    /// Sparkle asks its delegate by the Objective-C selector, and prompts on
    /// the second launch only when it is NOT implemented (its source). The
    /// deferral implements exactly that selector and declines.
    @Test func theDeferralDeclinesSparklesEarlyPromptBySparklesOwnSelector() {
        let deferral = UpdateChannel.PermissionDeferral()
        #expect(deferral.responds(
            to: NSSelectorFromString("updaterShouldPromptForPermissionToCheckForUpdates:")))
        #expect(UpdateChannel.PermissionDeferral.promptsEarly == false)
    }

    /// The inert channel (every Debug build) never asks and answers nothing;
    /// the answer is read from Sparkle's own defaults key.
    @Test func theInertChannelNeverAsksAndTheAnswerIsSparklesOwnKey() {
        let suite = "variorum.tests.updates.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let channel = UpdateChannel(live: false, defaults: defaults)
        #expect(!channel.permissionAnswered && !channel.wantsPermissionAsked)
        channel.askPermission()
        channel.setAutomaticallyChecks(true)
        #expect(!channel.isAskingPermission && !channel.automaticallyChecks)
        #expect(UpdateChannel.answerKey == "SUEnableAutomaticChecks")
        defaults.set(false, forKey: UpdateChannel.answerKey)  // "Don't Check", once
        #expect(channel.permissionAnswered)
    }

    /// Rule 4: the Settings answer exists, in the cadence's own words.
    @Test func settingsGeneralCarriesTheUpdateAnswer() {
        #expect(UpdateSettingsCopy.title == "Check for updates automatically")
        #expect(SettingsCatalog.title("updates") == UpdateSettingsCopy.title)
        #expect(AppSettingsView.rowIDsRendered[.general]?.contains("updates") == true)
    }

    // MARK: - The backup ask (R-13r-12)

    @Test func theBackupOfferIsTheSheetsOwnQuestionWithTwoDoors() {
        let status = StatusCenter()
        var opened = 0, declined = 0
        status.offer(CalmAskCopy.backupQuestion,
                     action: .init(label: CalmAskCopy.backupSetUpDoor) { opened += 1 },
                     secondary: .init(label: CalmAskCopy.backupNotNowDoor) { declined += 1 })
        let item = status.current
        #expect(item?.kind == .offer && item?.text == "Keep a copy of your backups in iCloud Drive?")
        #expect(item?.action?.label == "Set Up\u{2026}" && item?.secondary?.label == "Not Now")
        item?.action?.perform()
        item?.secondary?.perform()
        #expect(opened == 1 && declined == 1)
    }

    /// "Writing of the user's own": the seeded field guide is not; a note of
    /// hers with words is; a blank note of hers is not; a note wearing a
    /// seeded tag is not.
    @Test func ownWritingIsANoteSheMadeNotTheSeed() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_950_400))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            _ = try await TutorialSeeder.restore(session: session)
            #expect(try await db.read { try OwnWriting.exists($0) } == false, "the seed is not her writing")
            let blank = try await session.runner.run { ops in try ops.createPost(title: "mine") }
            #expect(try await db.read { try OwnWriting.exists($0) } == false, "a blank note is not writing yet")
            let tutorialTag = try #require(try await db.read { db in
                try Queries.allTags(db).first { $0.path == TutorialSeeder.tagName }
            })
            _ = try await session.runner.run { ops in
                let post = try ops.createPost(title: "looks seeded")
                _ = try ops.newBlock(in: post.id, text: "words", registeringUndo: false)
                _ = try ops.applyTag(tutorialTag.id, toPost: post.id)
            }
            #expect(try await db.read { try OwnWriting.exists($0) } == false, "a seeded tag marks the seed")
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: blank.id, text: "My first real sentence.", registeringUndo: false)
            }
            #expect(try await db.read { try OwnWriting.exists($0) } == true, "her note with words")
        }
        #expect(OwnWriting.seedTagPaths.contains(TutorialSeeder.tagName))
        for book in SampleLibrarySeeder.Book.all {
            #expect(OwnWriting.seedTagPaths.contains(book.tagName), "every seeded book's tag")
        }
    }
}
