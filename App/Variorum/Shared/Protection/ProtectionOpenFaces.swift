//
//  ProtectionOpenFaces.swift
//  Variorum (shared: Mac + Mobile — the phone's faces are U3's)
//
//  VX-306 U2 — WHAT THE OPEN SAYS, as values read from the open's report (`RoadOpenReport` — the executor's unlock,
//  `assess`'s faults and acts, the key-file search), and the two models the faces render. No rule of its own: each
//  face below is one of the core's answers read into words (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its
//  addendum; §7c (2) (3) (4) (6); the contract `notes/CastleRules.md` rules 1, 21, 27).
//
//    - THE INTERLUDE (`RoadInterlude`, `RoadInterludeModel`) — shown ONCE per open, in the lobby's room, between the
//      unlock and the library's open (PROVISIONAL P-VX306-U2-1): rule 21's NOTICE first (her sentence,
//      `LibraryNotice.sentence(date:)`, one *OK*), then the KEY-FILE OFFER (her sentence, `KeyFileOffer.sentence
//      (date:)`, *Not now* · *Use it*). *Use it* runs `useOfferedKeyFile` and owes the receipt naming the source;
//      *Not now* writes nothing. Then the library opens either way — the open does not wait on her answer to the
//      offer (rule 21: "it never decides for you"), and an offer she put off is owed again at the next open.
//    - THE STANDING FACES (`RoadStandingFaces`) — on the open library: RULE 27's banner after a quiet-road open
//      (`Fault.noKeyFileAnywhere`, or the search's `.noKeyFileAnywhere`) in §7c (3)'s words, no doors; the split
//      pair's line (`.besideOpensItOnlyThroughItsHistory`); rule 1's restore RECEIPT (`restoreKeyFileFromMirror`
//      among the open's repairs — §7c (6), on the status seam, `receipt_style` governing it as every receipt); and
//      rule 3's model moment (`.askPassphrase`), which the reminder reads.
//    - `RoadStandingModel` — the open library's faces model: the standing faces, rule 3's reminder, the
//      set-passphrase sheet's factory, and the receipts the open owes the status seam (taken once, spoken by the
//      composition that holds the seam).
//

import Foundation
import Observation
import VariorumCore

// MARK: - The interlude (rule 21: the notice, then the offer)

nonisolated enum RoadInterlude {
    enum Card: Equatable, Sendable {
        /// Rule 21's notice — her sentence (`LibraryNotice`), one *OK*.
        case notice(LibraryNotice)
        /// Rule 21's offer — her sentence (`KeyFileOffer`), *Not now* · *Use it*.
        case offer(KeyFileOffer)
        /// VX-307 U2a — VX-310's RE-ARM question (the design's §3.10): owed by `assess` ONLY after a Touch ID press failed
        /// on an item that exists and a typed secret then opened the library (`OwedAct.touchIDRearmQuestion`). *Always
        /// ask instead* · *Set it up again* — `answerTouchIDRearm` (a new item only on yes, at this press; a no records
        /// Always ask). Asked here, in the lobby's room after the unlock, before the library shows (PROVISIONAL
        /// P-VX307-U2a-5 — the interlude's idiom, P-VX306-U2-1).
        case rearm
    }

    /// The cards an open owes before the library shows, in order: the notice (the unlock said it), then the offer
    /// (the search found one), then the re-arm question (a press failed on an item that exists). Empty: nothing to say
    /// — the open goes straight on.
    static func cards(_ report: RoadOpenReport) -> [Card] {
        var cards: [Card] = []
        if let notice = report.notice { cards.append(.notice(notice)) }
        if case .offer(let offer)? = report.keyFileSearch { cards.append(.offer(offer)) }
        if report.acts.contains(.touchIDRearmQuestion) { cards.append(.rearm) }
        return cards
    }

    /// The card's one sentence — the model's, its `<date>` written in (`ProtectionWords.day`); a backup the
    /// catalogue can't date reads `ProtectionWords.offerUnknownDay` there.
    static func sentence(_ card: Card, day: (Date) -> String) -> String {
        switch card {
        case .notice(let notice):
            return notice.sentence(date: day)
        case .offer(let offer):
            if case .backup(_, nil) = offer.source {
                return offer.words.replacingOccurrences(of: "<date>", with: ProtectionWords.offerUnknownDay)
            }
            return offer.sentence(date: day)
        case .rearm:
            return ProtectionWords.rearmQuestion
        }
    }

    /// *Use it*'s receipt — §7c (2), the source named.
    static func receipt(_ offer: KeyFileOffer, day: (Date) -> String) -> String {
        switch offer.source {
        case .thisMacsKeychain:
            return ProtectionWords.offerRestoredFromKeychain
        case .backup(_, let date):
            return ProtectionWords.offerRestoredFromBackup(date.map(day) ?? ProtectionWords.offerUnknownDay)
        }
    }
}

/// The interlude's brain: the cards in order, the presses, and — when the last card is answered — the open goes on.
@MainActor
@Observable
final class RoadInterludeModel {
    private(set) var cards: [RoadInterlude.Card]
    private(set) var busy = false
    /// *Use it* failed — said under the buttons; both doors stay. (The re-arm's answer failing — said, with *OK*.)
    private(set) var message: String?
    /// VX-307 U2a — the re-arm's answer could not be written: the card offers *OK* and the open goes on with nothing
    /// decided (the question is asked again after the next failed press) — never a dead end in the lobby's room.
    private(set) var rearmFailed = false

    @ObservationIgnored private let day: (Date) -> String
    @ObservationIgnored private let useOffer: (KeyFileOffer) async -> UseOfferOutcome
    /// VX-307 U2a — the re-arm's answer (`answerTouchIDRearm`): true when it was written.
    @ObservationIgnored private let answerRearm: (Bool) async -> Bool
    @ObservationIgnored private let receipt: (String) -> Void
    @ObservationIgnored private let finished: () -> Void
    @ObservationIgnored private var finishedOnce = false

    init(
        cards: [RoadInterlude.Card],
        day: @escaping (Date) -> String = { ProtectionWords.day($0) },
        useOffer: @escaping (KeyFileOffer) async -> UseOfferOutcome,
        answerRearm: @escaping (Bool) async -> Bool = { _ in false },
        receipt: @escaping (String) -> Void,
        finished: @escaping () -> Void
    ) {
        self.cards = cards
        self.day = day
        self.useOffer = useOffer
        self.answerRearm = answerRearm
        self.receipt = receipt
        self.finished = finished
    }

    var current: RoadInterlude.Card? { cards.first }

    var sentence: String? { current.map { RoadInterlude.sentence($0, day: day) } }

    /// The notice's one button — and, once the re-arm's answer could not be written, the re-arm card's way on.
    func ok() {
        guard !busy else { return }
        switch current {
        case .notice?:
            advance()
        case .rearm? where rearmFailed:
            rearmFailed = false
            message = nil
            ProtectionOpenRoad.log("road: the Touch ID re-arm left unanswered (its answer could not be written)")
            advance()
        default:
            return
        }
    }

    /// VX-310's re-arm, answered: yes makes a new item at this press; no records Always ask (`answerTouchIDRearm`).
    func rearm(yes: Bool) async {
        guard case .rearm? = current, !busy, !rearmFailed else { return }
        busy = true
        message = nil
        let written = await answerRearm(yes)
        busy = false
        if written {
            advance()
        } else {
            rearmFailed = true
            message = ProtectionWords.rearmFailed
        }
    }

    /// The offer put off — NOTHING is written (rule 21: "nothing is written before your yes").
    func notNow() {
        guard case .offer? = current, !busy else { return }
        message = nil
        ProtectionOpenRoad.log("road: the key-file offer put off (Not now) — nothing written")
        advance()
    }

    /// The offer accepted: `useOfferedKeyFile`, then the receipt naming where it came from.
    func useIt() async {
        guard case .offer(let offer)? = current, !busy else { return }
        busy = true
        message = nil
        let outcome = await useOffer(offer)
        busy = false
        switch outcome {
        case .used:
            receipt(RoadInterlude.receipt(offer, day: day))
            advance()
        case .failed:
            message = ProtectionWords.offerUseFailed
        }
    }

    private func advance() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()
        if cards.isEmpty, !finishedOnce {
            finishedOnce = true
            finished()
        }
    }
}

// MARK: - The standing faces (on the open library)

nonisolated struct RoadStandingFaces: Equatable, Sendable {
    /// RULE 27 after a quiet-road open: no key file anywhere — the banner, §7c (3)'s words, no doors.
    var noKeyFileAnywhere: NoKeyFileAnywhere?
    /// The key file beside reaches the library only through its history (P-VX378-U4-6 (a)) — §7c (2)'s last line.
    var splitPair: Bool
    /// RULE 3: the model's moment owed at this open (`.beforeFirstBackup` / `.quietRoadFailed`), nil none.
    var passphraseMoment: PassphraseAsk?
    /// The receipts this open owes the status seam: rule 1's restore (§7c (6)).
    var receipts: [String]

    static let none = RoadStandingFaces(noKeyFileAnywhere: nil, splitPair: false, passphraseMoment: nil, receipts: [])

    static func derive(_ report: RoadOpenReport) -> RoadStandingFaces {
        var nothing: NoKeyFileAnywhere?
        for fault in report.faults {
            if case .noKeyFileAnywhere(let refusal) = fault { nothing = refusal }
        }
        if nothing == nil, case .noKeyFileAnywhere(let refusal)? = report.keyFileSearch { nothing = refusal }
        var moment: PassphraseAsk?
        for act in report.acts {
            if case .askPassphrase(let ask) = act, moment == nil { moment = ask }
        }
        return RoadStandingFaces(
            noKeyFileAnywhere: nothing,
            splitPair: report.keyFileSearch == .besideOpensItOnlyThroughItsHistory,
            passphraseMoment: moment,
            receipts: report.repairsDone.contains(.restoreKeyFileFromMirror) ? [ProtectionWords.restoredFromMirror] : [])
    }
}

/// The open library's protection faces: the standing faces, rule 3's reminder, the set-passphrase sheet's factory,
/// and the receipts owed the status seam. Every act is an injected road (the bootstrap's, through the session's
/// executor; a test's, planted).
@MainActor
@Observable
final class RoadStandingModel {
    private(set) var faces: RoadStandingFaces
    let reminder: PassphraseReminderModel
    /// The Protection pane's *Set a passphrase…* row renders only while this library has NO passphrase — the sheet
    /// would refuse at once otherwise, forever (P-2: a door that cannot act is not rendered; the ladder's round-1 NIT 4).
    /// Re-read from the library each time a set-passphrase sheet closes.
    private(set) var offersSetPassphrase: Bool
    /// VX-307 U2a — the crossings (Use Castle, Use Standard, Replace All Keys, the gate-style row, rule 11's notice):
    /// the BOOTSTRAP's model, handed to each open library's faces so the Protection pane finds it (it outlives the
    /// reopen a crossing makes; this model does not).
    var crossings: RoadCrossingsModel?
    /// VX-307 U2b — THE CARD ABOVE THE QUICK ENTRY (rules 2 and 3 as amended): the words' offer and rule 3's reminder,
    /// one card (`WordsBandModel`). nil where no factory built one (a test's hand-made faces).
    let band: WordsBandModel?

    @ObservationIgnored private let setPassphrase: (String) async -> SetPassphraseOutcome
    @ObservationIgnored private let passphraseExists: () -> Bool
    @ObservationIgnored private let receiptsOwed: () -> [String]
    /// The status seam's receipt door — set by the composition that holds it (the Mac's ready window); the
    /// receipts owed wait for it.
    @ObservationIgnored var speak: ((String) -> Void)? {
        didSet { speakOwedReceipts() }
    }

    /// VX-307 U2b — the look's roads for the other homes (`makeWordsLook`): the mint and the clipboard.
    @ObservationIgnored private let mintWords: ((String?) async -> WordsMintOutcome)?
    @ObservationIgnored private let copyWords: ([String]) -> Void

    init(
        faces: RoadStandingFaces,
        reminder: PassphraseReminderModel,
        setPassphrase: @escaping (String) async -> SetPassphraseOutcome,
        passphraseExists: @escaping () -> Bool,
        receiptsOwed: @escaping () -> [String],
        band: WordsBandModel? = nil,
        mintWords: ((String?) async -> WordsMintOutcome)? = nil,
        copyWords: @escaping ([String]) -> Void = { _ in }
    ) {
        self.faces = faces
        self.reminder = reminder
        self.setPassphrase = setPassphrase
        self.passphraseExists = passphraseExists
        self.receiptsOwed = receiptsOwed
        self.band = band
        self.mintWords = mintWords
        self.copyWords = copyWords
        offersSetPassphrase = !passphraseExists()
    }

    /// The open library's protection faces, from its session (the bootstrap's `.ready` on the new road): the standing faces read from the open's
    /// report, rule 3's reminder (its launch counted once per process on a writing road, then evaluated), and the
    /// set-passphrase sheet's road through the session's executor. VX-307 U2b: the card above the quick entry — the
    /// words' look minting through rule 6's act on the session (`mintFreshWords`), `copyWords` the platform's one
    /// clipboard rule (the Mac's `WordsClipboard`), its local ledger in the reminder ledger's defaults.
    static func make(
        _ session: ProtectionRoadSession, ledger: PassphraseReminderLedger,
        snoozes: WordsCardSnoozes = .process, copyWords: @escaping ([String]) -> Void = { _ in }
    ) -> RoadStandingModel {
        let faces = RoadStandingFaces.derive(session.report)
        let libraryID = session.library.record?.libraryID ?? ""
        if session.writes, !libraryID.isEmpty { ledger.noteLaunchOncePerProcess(libraryID) }
        let reminder = PassphraseReminderModel(
            libraryID: libraryID, moment: session.writes ? faces.passphraseMoment : nil, ledger: ledger,
            facts: {
                let library = session.library
                // A read-only road (a hosted test run) never reminds: nothing could be set or recorded.
                return (passphraseSet: !session.writes || ProtectionOpenRoad.passphraseExists(library),
                        dismissals: library.record?.reminderDismissals ?? 0)
            },
            recordDismissal: {
                await Task.detached(priority: .userInitiated) {
                    ProtectionOpenRoad.recordReminderDismissed(session: session)
                }.value
            })
        reminder.evaluate()
        let passphraseExists: () -> Bool = { ProtectionOpenRoad.passphraseExists(session.library) }
        let mint: (String?) async -> WordsMintOutcome = { passphrase in
            await Task.detached(priority: .userInitiated) {
                await ProtectionOpenRoad.mintFreshWords(session: session, passphrase: passphrase)
            }.value
        }
        let band = WordsBandModel(
            libraryID: libraryID, writes: session.writes, ledger: WordsCardLedger(defaults: ledger.defaults),
            snoozes: snoozes, reminder: reminder, passphraseExists: passphraseExists, mint: mint, copy: copyWords)
        return RoadStandingModel(
            faces: faces, reminder: reminder,
            setPassphrase: { passphrase in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.setFirstPassphrase(session: session, new: passphrase)
                }.value
            },
            passphraseExists: passphraseExists,
            receiptsOwed: { session.takeReceipts() },
            band: band, mintWords: mint, copyWords: copyWords)
    }

    /// VX-307 U2b — a look for another home (the tour's last card, Settings ▸ Protection): the band's roads; recording
    /// there retires the card's offer too. With no band (a test's hand-made faces), a look that refuses at once.
    func makeWordsLook() -> WordsLookModel {
        if let band, let mintWords {
            return band.makeLook(passphraseExists: passphraseExists, mint: mintWords, copy: copyWords)
        }
        return WordsLookModel(
            saysRuleSix: false, passphraseExists: passphraseExists,
            mint: { _ in .refused(ProtectionWords.wordsLookFailed) }, copy: copyWords, recorded: {})
    }

    /// The receipts the open owes, spoken once (each `receiptsOwed` call takes them).
    func speakOwedReceipts() {
        guard let speak else { return }
        for receipt in receiptsOwed() { speak(receipt) }
    }

    /// A set-passphrase sheet (P-VX306-U2-0 (a)) for a host to present (the reminder's bar, the Protection pane —
    /// each holds its own, so two windows never show one sheet); it refuses at once when a passphrase exists.
    /// `close` dismisses the host's sheet; a passphrase set retires the reminder and speaks §7c (7)'s receipt.
    /// VX-307 U2b: `onSet` hears the passphrase she just set (the tour's last card hands it to the words' look beside
    /// it, so she is never asked it twice; held in memory only, for that card).
    func makeSetPassphraseSheet(
        close: @escaping () -> Void, onSet: ((String) -> Void)? = nil
    ) -> SetPassphraseModel {
        let setPassphrase = setPassphrase
        let road: (String) async -> SetPassphraseOutcome = { passphrase in
            let outcome = await setPassphrase(passphrase)
            if outcome == .set { onSet?(passphrase) }
            return outcome
        }
        return SetPassphraseModel(alreadySet: passphraseExists(), setRoad: road) { [weak self] wasSet in
            close()
            guard let self else { return }
            self.offersSetPassphrase = !self.passphraseExists()
            guard wasSet else { return }
            self.reminder.passphraseWasSet()
            self.speak?(ProtectionWords.passphraseSetReceipt)
        }
    }
}
