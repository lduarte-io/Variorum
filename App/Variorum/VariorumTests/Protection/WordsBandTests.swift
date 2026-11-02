//
//  WordsBandTests.swift
//  VariorumTests — VX-307 U2b pieces 3 and 5 (VX-412; `notes/CastleRules.md` rules 2, 3, 6 and 7 as amended; her words
//  in `notes/plans/vx-307-castle-crossings.md` §3a): THE CARD ABOVE THE QUICK ENTRY and THE LOOK, as pure models over
//  planted roads, then through the REAL road on a planted session (rule 6's act in the core — the key unchanged,
//  nothing stored), and the tour's last card (the passphrase ask beside the words). Runs headless in the implementer's
//  harness (the record says how) and in the Mac suite.
//
//    - the card's states: fresh (the words offered) · snoozed to the next launch · dismissed for good + the toast's
//      sentence · the look (asked where a passphrase exists, minted where none does) · shown once with Copy · the
//      warning before close (her words) · recorded (the offer retires everywhere);
//    - rule 3's reminder folded in: the card stands for the reminder alone once the words are done;
//    - rule 2's card sentence byte-equal to the rules file.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A throwaway defaults suite (never the app's domain), removed by `purge`.
nonisolated final class ThrowawayDefaults: @unchecked Sendable {
    let name = "io.lduarte.Variorum.vx307-u2b-\(UUID().uuidString)"
    let defaults: UserDefaults

    init() { defaults = UserDefaults(suiteName: name) ?? .standard }

    func purge() { defaults.removePersistentDomain(forName: name) }
}

/// The band's planted world: a ledger in a throwaway suite, this test's own snoozes, a mint that answers as told.
@MainActor
final class PlantedBand {
    let store = ThrowawayDefaults()
    let snoozes = WordsCardSnoozes()
    var passphrase: String?
    var mints: [String?] = []
    var copies: [[String]] = []
    let libraryID = "library-\(UUID().uuidString)"

    var ledger: WordsCardLedger { WordsCardLedger(defaults: store.defaults) }
    var reminderLedger: PassphraseReminderLedger { PassphraseReminderLedger(defaults: store.defaults) }

    /// A reminder over this world's ledger (passphrase-less unless `passphrase` is set).
    func reminder(moment: PassphraseAsk? = nil) -> PassphraseReminderModel {
        PassphraseReminderModel(
            libraryID: libraryID, moment: moment, ledger: reminderLedger,
            facts: { [weak self] in (passphraseSet: self?.passphrase != nil, dismissals: 0) },
            recordDismissal: { true })
    }

    func band(reminder: PassphraseReminderModel? = nil, writes: Bool = true) -> WordsBandModel {
        WordsBandModel(
            libraryID: libraryID, writes: writes, ledger: ledger, snoozes: snoozes,
            reminder: reminder ?? self.reminder(),
            passphraseExists: { [weak self] in self?.passphrase != nil },
            mint: { [weak self] typed in
                guard let self else { return .refused("gone") }
                self.mints.append(typed)
                if let real = self.passphrase, typed != real { return .refused(ProtectionWords.passphraseDoesNotOpen) }
                return .minted((1...12).map { "word\($0)" })
            },
            copy: { [weak self] in self?.copies.append($0) })
    }

    deinit { store.purge() }
}

@Suite("VX-307 U2b — the card above the quick entry and the look (rules 2, 3, 6)")
@MainActor
struct WordsBandTests {
    // MARK: Her words

    /// RULE 2's card sentence is hers, byte-equal to the rules file (the first letter capitalized, the period added).
    @Test func theCardSaysRule2sSentenceVerbatim() throws {
        var url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        while url.pathComponents.count > 1, !FileManager.default.fileExists(
            atPath: url.appendingPathComponent("notes/CastleRules.md").path) {
            url.deleteLastPathComponent()
        }
        // The rules file wraps its lines: whitespace runs read as one space.
        let rules = try String(contentsOf: url.appendingPathComponent("notes/CastleRules.md"), encoding: .utf8)
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
        let hers = "your library is encrypted \u{2014} click here to record the twelve words that are its key"
        #expect(rules.contains("*\(hers)*"), "rule 2 carries her sentence")
        #expect(ProtectionWords.wordsCardLine == "Y" + hers.dropFirst() + ".")
        #expect(ProtectionWords.wordsLookWarning == "These words won't be shown again.", "her words, the close's warning")
        // Her no-shouty-caps rule: sentence case — no word in capitals for emphasis.
        for line in [ProtectionWords.wordsCardLine, ProtectionWords.wordsCardLater, ProtectionWords.wordsCardDismissedToast,
                     ProtectionWords.wordsLookLead, ProtectionWords.wordsLookWarning, ProtectionWords.wordsSectionLine] {
            for word in line.split(separator: " ") where word.count > 1 {
                #expect(word.uppercased() != word || word.allSatisfy { !$0.isLetter }, "\(word) shouts in “\(line)”")
            }
        }
    }

    // MARK: The card's states

    @Test func aFreshLibrarysCardOffersTheWordsUntilSnoozedThenReturnsAtTheNextLaunch() {
        let world = PlantedBand()
        let band = world.band()
        #expect(band.offersWords && band.visible)
        band.later()
        #expect(!band.offersWords && !band.visible, "Later: gone for this launch")
        #expect(!world.band().offersWords, "a reopen in the same process keeps the snooze")
        // The next launch: this process's snooze is gone (a fresh process's set), the ledger untouched.
        let nextLaunch = WordsBandModel(
            libraryID: world.libraryID, writes: true, ledger: world.ledger, snoozes: WordsCardSnoozes(),
            reminder: world.reminder(), passphraseExists: { false }, mint: { _ in .refused("") }, copy: { _ in })
        #expect(nextLaunch.offersWords, "her snoozed card shows on the next launch")
        #expect(world.mints.isEmpty, "nothing was minted")
    }

    @Test func theCrossDismissesForGoodAndHandsBackTheToastNamingSettings() {
        let world = PlantedBand()
        let band = world.band()
        let toast = band.dismiss()
        #expect(toast == ProtectionWords.wordsCardDismissedToast)
        #expect(toast?.contains("Settings \u{25B8} Protection") == true, "her: look in Settings, Protection")
        #expect(!band.offersWords && !band.visible)
        #expect(world.ledger.dismissed(world.libraryID))
        #expect(!world.band().offersWords, "dismissed for good — every later open")
        let nextLaunch = WordsBandModel(
            libraryID: world.libraryID, writes: true, ledger: world.ledger, snoozes: WordsCardSnoozes(),
            reminder: world.reminder(), passphraseExists: { false }, mint: { _ in .refused("") }, copy: { _ in })
        #expect(!nextLaunch.offersWords, "and every later launch")
        #expect(band.dismiss() == nil, "a second ✕ says nothing")
        #expect(world.mints.isEmpty)
    }

    @Test func aReadOnlyRoadNeverOffersTheWords() {
        let world = PlantedBand()
        #expect(!world.band(writes: false).offersWords)
    }

    /// The look on a library with NO passphrase: minted at the click (nothing asked — P-VX307-U2b-1), shown once with
    /// Copy, the warning before close, then forgotten and recorded — the card's offer retires for good.
    @Test func theLookMintsAtTheClickShowsOnceWarnsAndRecords() async {
        let world = PlantedBand()
        let band = world.band()
        #expect(!band.look.saysRuleSix, "the first look says nothing of earlier words")
        await band.look.open()
        #expect(world.mints == [nil], "nothing asked: no passphrase exists")
        #expect(band.look.phase == .shown && band.look.words.count == 12)
        #expect(band.look.columns.map { $0.map(\.number) } == [Array(1...6), Array(7...12)])
        #expect(band.visible, "the card stands while the words are on screen")
        band.later()
        #expect(band.look.phase == .shown, "Later never puts shown words away")
        #expect(band.dismiss() == nil && band.look.phase == .shown, "nor does the ✕")
        band.look.copy()
        #expect(world.copies == [band.look.words] && band.look.copied, "VX-412's Copy door")
        band.look.writtenDown()
        #expect(band.look.phase == .warning && band.look.words.count == 12, "the warning, the words still there")
        band.look.goBack()
        #expect(band.look.phase == .shown)
        band.look.writtenDown()
        band.look.close()
        #expect(band.look.phase == .closed && band.look.words.isEmpty && !band.look.copied, "forgotten at the close")
        #expect(world.ledger.recorded(world.libraryID))
        #expect(!band.offersWords && !band.visible, "recorded: the card's offer retires")
        let later = world.band()
        #expect(!later.offersWords, "and stays retired")
        #expect(later.look.saysRuleSix, "a later look (Settings) says rule 6's sentence")
        await band.look.open()
        #expect(world.mints == [nil, nil], "a later look mints fresh words — nothing kept them")
    }

    /// A library WITH a passphrase: the look asks it (rule 6), a wrong one says why and writes nothing, the right one
    /// mints; Cancel leaves without a mint.
    @Test func withAPassphraseTheLookAsksItFirst() async {
        let world = PlantedBand()
        world.passphrase = "chosen"
        let band = world.band()
        await band.look.open()
        #expect(band.look.phase == .asking && world.mints.isEmpty, "asked before anything is minted")
        band.look.cancel()
        #expect(band.look.phase == .closed && world.mints.isEmpty)
        await band.look.open()
        await band.look.submit(passphrase: "")
        #expect(world.mints.isEmpty, "an empty field asks nothing")
        await band.look.submit(passphrase: "not it")
        #expect(band.look.phase == .asking && band.look.message == ProtectionWords.passphraseDoesNotOpen)
        await band.look.submit(passphrase: "chosen")
        #expect(band.look.phase == .shown && band.look.message == nil)
        #expect(world.mints == ["not it", "chosen"])
    }

    /// ONE look holds words at a time (P-VX307-U2b-6): while the card's words are on screen, another home's look (the
    /// tour's last card, Settings) refuses to mint — a second mint would replace the words still shown, which would then
    /// no longer open the library. Closed, the next look mints.
    @Test func oneLookHoldsWordsAtATime() async {
        let world = PlantedBand()
        let band = world.band()
        await band.look.open()
        #expect(band.look.phase == .shown)
        let elsewhere = band.makeLook(
            passphraseExists: { false }, mint: { [weak world] typed in
                world?.mints.append(typed)
                return .minted((1...12).map { "other\($0)" })
            }, copy: { _ in })
        await elsewhere.open()
        #expect(elsewhere.phase == .closed && elsewhere.message == ProtectionWords.wordsLookElsewhere)
        #expect(world.mints == [nil], "nothing minted over the words on screen")
        band.look.writtenDown()
        band.look.close()
        await elsewhere.open()
        #expect(elsewhere.phase == .shown && world.mints == [nil, nil], "the card's look closed: the next one mints")
    }

    /// Rule 3's reminder folds into the same card: with the words done, the card stands for the reminder alone; with
    /// neither, it is gone.
    @Test func theReminderFoldsIntoTheSameCard() async {
        let world = PlantedBand()
        let reminder = world.reminder(moment: .beforeFirstBackup)
        reminder.evaluate()
        let band = world.band(reminder: reminder)
        #expect(band.offersWords && band.showsReminder, "both asks, one card")
        _ = band.dismiss()
        #expect(!band.offersWords && band.showsReminder && band.visible, "the reminder keeps the card")
        await reminder.notNow()
        #expect(!band.showsReminder && !band.visible, "neither: the card is gone")
    }

    // MARK: The real road (rule 6's act in the core, on a planted session)

    /// Through the REAL road: the band's look on a library just created — fresh words open the live key file, the
    /// creation's no longer do, the KEY is unchanged, the passphrase lock untouched, and nothing stores the words: not
    /// the files beside the library, not what this Mac remembers, not the defaults the card writes.
    @Test func throughTheRealRoadTheWordsLockTheKeyFileWithTheKeyUnchangedAndAreStoredNowhere() async throws {
        let road = PlantedRoad()
        let (session, creationWords) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        var copied: [[String]] = []
        let standing = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes(),
            copyWords: { copied.append($0) })
        let band = try #require(standing.band)
        #expect(band.offersWords, "a library just created: the card offers its words")
        let keyBefore = session.key
        let fileBefore = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        await band.look.open()
        #expect(band.look.phase == .shown, "\(band.look.message ?? "")")
        let words = band.look.words
        #expect(words.count == 12 && words != creationWords)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try live.open(words: words) == keyBefore, "the words she records open the library")
        #expect((try? live.open(words: creationWords)) == nil, "the creation's (never shown) no longer do")
        #expect(session.key == keyBefore && live.fingerprint == fileBefore.fingerprint, "rule 6: the key unchanged")
        #expect(live.passphrase == nil && live.apple == fileBefore.apple, "every other lock stays")
        #expect(session.library.keyFile == live, "the session holds the library as it is now")
        band.look.copy()
        #expect(copied == [words])
        band.look.writtenDown()
        band.look.close()
        #expect(band.look.words.isEmpty && !band.offersWords)
        // Nothing stores the words.
        let text = words.joined(separator: " ")
        var haystacks: [Data] = []
        let files = FileManager.default.enumerator(at: road.slot.root, includingPropertiesForKeys: nil)
        while let url = files?.nextObject() as? URL {
            if let data = try? Data(contentsOf: url) { haystacks.append(data) }
        }
        haystacks += road.memory.items.values.map(\.payload)
        if let plist = store.defaults.persistentDomain(forName: store.name) {
            haystacks.append(try PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0))
        }
        #expect(!haystacks.isEmpty)
        for haystack in haystacks {
            #expect(String(decoding: haystack, as: UTF8.self).contains(text) == false, "the words are stored")
            #expect(haystack.range(of: Data(text.utf8)) == nil, "the words are stored")
        }
    }

    /// Through the real road with a passphrase set: the look asks it; a wrong one is refused with nothing written.
    @Test func throughTheRealRoadAPassphraseIsAskedAndAWrongOneWritesNothing() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: "a passphrase") == .set)
        let standing = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes())
        let band = try #require(standing.band)
        let before = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        await band.look.open()
        #expect(band.look.phase == .asking)
        await band.look.submit(passphrase: "not it")
        #expect(band.look.message == ProtectionWords.passphraseDoesNotOpen)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == before, "nothing written")
        await band.look.submit(passphrase: "a passphrase")
        #expect(band.look.phase == .shown)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.open(words: band.look.words) == session.key)
    }

    // MARK: The tour's last card (piece 5)

    /// Rule 3: the tour's last card asks the passphrase AND shows the words beside the ask. A passphrase chosen there
    /// is handed to the look (never asked twice); the card's three doors wait while words are on screen.
    @Test func theToursLastCardAsksThePassphraseAndShowsTheWordsBesideIt() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes())
        let card = TourEndLibraryModel(standing: standing)
        let ask = try #require(card.passphrase, "no passphrase yet: the card asks one")
        #expect(!card.holdsTheDoors)
        await ask.submit(passphrase: "chosen at the end", again: "chosen at the end")
        #expect(card.passphraseSet && ask.refusal == nil)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.passphrase != nil)
        await card.showWords()
        #expect(card.look.phase == .shown, "minted with the passphrase she just chose — not asked twice")
        #expect(card.holdsTheDoors, "the tour's doors wait while the words are on screen")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.open(words: card.look.words) == session.key)
        card.look.writtenDown()
        #expect(card.holdsTheDoors)
        card.look.close()
        #expect(!card.holdsTheDoors)
        #expect(standing.band?.offersWords == false, "recorded at the tour's end: the card's offer retires")
        // A second visit to a library that has a passphrase: no ask, and the look asks the passphrase (rule 6).
        let again = TourEndLibraryModel(standing: RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes()))
        #expect(again.passphrase == nil)
        await again.showWords()
        #expect(again.look.phase == .asking)
    }

    // MARK: VX-735 (VX-736 R-736-5) — the tour's closing cards show only while their asks are owed

    /// **The words card is owed until the words are recorded — and only the BAND hears its own ✕ and *Later*.** Her
    /// *"make sure that this pane doesn't show if they already recorded their 12 words"*: a look closed past its
    /// warning at ANY home retires the tour's ask with the band's, and so does a landed account act
    /// (`accountHoldsTheWords`); a band dismissal or snooze retires the band alone (PROVISIONAL P-736-2 — rule 2 names
    /// the tutorial's last card as a home of its own); a read-only road owes nothing. RED on 2d82cb5a8 for the recorded
    /// arm by mechanism (the tour's close read no ledger at all).
    @Test func theToursWordsCardIsOwedUntilRecordedAndOnlyTheBandHearsItsCross() async {
        let world = PlantedBand()
        let band = world.band()
        #expect(band.wordsLookOwed, "a fresh library owes the tour's words card")
        band.later()
        #expect(!band.offersWords && band.wordsLookOwed, "Later snoozes the band, not the tour's ask")
        let crossed = world.band()
        _ = crossed.dismiss()
        #expect(world.ledger.dismissed(world.libraryID))
        #expect(!crossed.offersWords && crossed.wordsLookOwed, "the ✕ retires the band, not the tour's ask (P-736-2)")
        #expect(world.band().wordsLookOwed, "a reopen after the ✕ still owes it")
        // The tour's own look closes past its warning: recorded — owed nowhere, now or after a reopen.
        let tourLook = crossed.makeLook(
            passphraseExists: { false }, mint: { _ in .minted((1...12).map { "w\($0)" }) }, copy: { _ in })
        await tourLook.open()
        tourLook.writtenDown()
        #expect(crossed.wordsLookOwed, "the words still on screen: still owed until the close")
        tourLook.close()
        #expect(!crossed.wordsLookOwed, "recorded at the tour's card")
        #expect(!world.band().wordsLookOwed, "and every later open")
        // A landed account act retires it too; a read-only road never owes it.
        let other = PlantedBand()
        let synced = other.band()
        synced.accountHoldsTheWords()
        #expect(!synced.wordsLookOwed, "a landed account act: a look would replace the account's words")
        #expect(!other.band(writes: false).wordsLookOwed, "a read-only road owes nothing")
    }

    /// **The five fixture worlds through the REAL road** — what the tour's facts read (`TourEndLibraryModel.asks`): FRESH
    /// owes both; PASSPHRASE SET owes the words only (the passphrase arm was already this truth before VX-735 — green on
    /// both sides); WORDS RECORDED owes the passphrase only; BOTH owes nothing (RED on 2d82cb5a8 for the two recorded
    /// rows: the close offered the words door whatever the ledger said). The landed-account world is
    /// `WordsCardAfterAccountActTests`' (the bootstrap's own landing).
    @Test func theToursClosingAsksReadTheLibrarysOwnTruthsInEveryWorld() async throws {
        func asks(passphrase: Bool, recorded: Bool) async throws -> Tour.ClosingAsks {
            let road = PlantedRoad()
            let (session, _) = try await road.created()
            let store = ThrowawayDefaults()
            defer { store.purge() }
            if passphrase {
                #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: "a passphrase") == .set)
            }
            if recorded, let id = session.library.record?.libraryID {
                WordsCardLedger(defaults: store.defaults).record(id)
            }
            let standing = RoadStandingModel.make(
                session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes())
            return TourEndLibraryModel.asks(standing)
        }
        #expect(try await asks(passphrase: false, recorded: false) == .init(passphrase: true, words: true), "fresh")
        #expect(try await asks(passphrase: true, recorded: false) == .init(passphrase: false, words: true),
                "passphrase set")
        #expect(try await asks(passphrase: false, recorded: true) == .init(passphrase: true, words: false),
                "words recorded")
        #expect(try await asks(passphrase: true, recorded: true) == .init(passphrase: false, words: false), "both")
    }

    /// **The tour's close, answered on its own cards through the real road**: the passphrase set on the first card
    /// retires its ask (the rule moves on to the words card) and is handed to the look (never asked twice); the look
    /// closed past its warning retires the words' ask (the rule moves on to the end card). No faces: nothing owed.
    @Test func theToursClosingAsksAreAnsweredOnTheirOwnCards() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes())
        let card = TourEndLibraryModel(standing: standing)
        #expect(TourEndLibraryModel.asks(standing) == .init(passphrase: true, words: true))
        let ask = try #require(card.passphrase)
        await ask.submit(passphrase: "chosen on the card", again: "chosen on the card")
        #expect(TourEndLibraryModel.asks(standing) == .init(passphrase: false, words: true),
                "the passphrase set on its card: the rule moves on to the words")
        await card.showWords()
        #expect(card.look.phase == .shown, "not asked twice")
        card.look.writtenDown()
        #expect(TourEndLibraryModel.asks(standing).words, "still owed while the words are on screen")
        card.look.close()
        #expect(TourEndLibraryModel.asks(standing) == .init(passphrase: false, words: false),
                "the look closed past its warning: the rule moves on to the end card")
    }

    /// The words first, the passphrase after (no passphrase yet): the look mints with nothing asked.
    @Test func theToursLastCardShowsTheWordsBeforeAnyPassphrase() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let card = TourEndLibraryModel(standing: RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes()))
        await card.showWords()
        #expect(card.look.phase == .shown)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.open(words: card.look.words) == session.key)
    }
}
