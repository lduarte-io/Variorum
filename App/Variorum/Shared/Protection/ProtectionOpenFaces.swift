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
    }

    /// The cards an open owes before the library shows, in order: the notice (the unlock said it), then the offer
    /// (the search found one). Empty: nothing to say — the open goes straight on.
    static func cards(_ report: RoadOpenReport) -> [Card] {
        var cards: [Card] = []
        if let notice = report.notice { cards.append(.notice(notice)) }
        if case .offer(let offer)? = report.keyFileSearch { cards.append(.offer(offer)) }
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
    /// *Use it* failed — said under the buttons; both doors stay.
    private(set) var message: String?

    @ObservationIgnored private let day: (Date) -> String
    @ObservationIgnored private let useOffer: (KeyFileOffer) async -> UseOfferOutcome
    @ObservationIgnored private let receipt: (String) -> Void
    @ObservationIgnored private let finished: () -> Void
    @ObservationIgnored private var finishedOnce = false

    init(
        cards: [RoadInterlude.Card],
        day: @escaping (Date) -> String = { ProtectionWords.day($0) },
        useOffer: @escaping (KeyFileOffer) async -> UseOfferOutcome,
        receipt: @escaping (String) -> Void,
        finished: @escaping () -> Void
    ) {
        self.cards = cards
        self.day = day
        self.useOffer = useOffer
        self.receipt = receipt
        self.finished = finished
    }

    var current: RoadInterlude.Card? { cards.first }

    var sentence: String? { current.map { RoadInterlude.sentence($0, day: day) } }

    /// The notice's one button.
    func ok() {
        guard case .notice? = current, !busy else { return }
        advance()
    }

    /// The offer put off — NOTHING is written (rule 21: "nothing is written before your yes").
    func notNow() {
        guard case .offer? = current, !busy else { return }
        message = nil
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

    @ObservationIgnored private let setPassphrase: (String) async -> SetPassphraseOutcome
    @ObservationIgnored private let passphraseExists: () -> Bool
    @ObservationIgnored private let receiptsOwed: () -> [String]
    /// The status seam's receipt door — set by the composition that holds it (the Mac's ready window); the
    /// receipts owed wait for it.
    @ObservationIgnored var speak: ((String) -> Void)? {
        didSet { speakOwedReceipts() }
    }

    init(
        faces: RoadStandingFaces,
        reminder: PassphraseReminderModel,
        setPassphrase: @escaping (String) async -> SetPassphraseOutcome,
        passphraseExists: @escaping () -> Bool,
        receiptsOwed: @escaping () -> [String]
    ) {
        self.faces = faces
        self.reminder = reminder
        self.setPassphrase = setPassphrase
        self.passphraseExists = passphraseExists
        self.receiptsOwed = receiptsOwed
    }

    /// The open library's protection faces, from its session (the bootstrap's `.ready` on the new road): the standing faces read from the open's
    /// report, rule 3's reminder (its launch counted once per process on a writing road, then evaluated), and the
    /// set-passphrase sheet's road through the session's executor.
    static func make(_ session: ProtectionRoadSession, ledger: PassphraseReminderLedger) -> RoadStandingModel {
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
        return RoadStandingModel(
            faces: faces, reminder: reminder,
            setPassphrase: { passphrase in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.setFirstPassphrase(session: session, new: passphrase)
                }.value
            },
            passphraseExists: { ProtectionOpenRoad.passphraseExists(session.library) },
            receiptsOwed: { session.takeReceipts() })
    }

    /// The receipts the open owes, spoken once (each `receiptsOwed` call takes them).
    func speakOwedReceipts() {
        guard let speak else { return }
        for receipt in receiptsOwed() { speak(receipt) }
    }

    /// A set-passphrase sheet (P-VX306-U2-0 (a)) for a host to present (the reminder's bar, the Protection pane —
    /// each holds its own, so two windows never show one sheet); it refuses at once when a passphrase exists.
    /// `close` dismisses the host's sheet; a passphrase set retires the reminder and speaks §7c (7)'s receipt.
    func makeSetPassphraseSheet(close: @escaping () -> Void) -> SetPassphraseModel {
        SetPassphraseModel(alreadySet: passphraseExists(), setRoad: setPassphrase) { [weak self] wasSet in
            close()
            guard let self, wasSet else { return }
            self.reminder.passphraseWasSet()
            self.speak?(ProtectionWords.passphraseSetReceipt)
        }
    }
}
