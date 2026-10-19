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
//      (`Fault.noKeyFileAnywhere`, or the search's `.noKeyFileAnywhere`) in her U2-7 words (VX-414 — *Variorum opened
//      your library, but found no key file for it anywhere. …*), no doors; (the split pair's line —
//      `.besideOpensItOnlyThroughItsHistory` — is dropped: no state reaches it, VX-414); rule 1's restore RECEIPT
//      (`restoreKeyFileFromMirror`
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
        /// Rule 21's offer — her sentence (`KeyFileOffer`), *Not now* · *Use it*. `besideEmpty` (VX-414): the place
        /// beside the library held no key file — the sentence opens with her U2-7 variant instead.
        case offer(KeyFileOffer, besideEmpty: Bool = false)
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
        if case .offer(let offer)? = report.keyFileSearch {
            cards.append(.offer(offer, besideEmpty: report.besideIsEmpty))
        }
        if report.acts.contains(.touchIDRearmQuestion) { cards.append(.rearm) }
        return cards
    }

    /// The card's one sentence — the model's, its `<date>` written in (`ProtectionWords.day`); a backup the
    /// catalogue can't date reads `ProtectionWords.offerUnknownDay` there.
    static func sentence(_ card: Card, day: (Date) -> String) -> String {
        switch card {
        case .notice(let notice):
            return notice.sentence(date: day)
        case .offer(let offer, let besideEmpty):
            // VX-414 — her U2-7 variant (2): with NO key file beside the library and a backup holding the right one,
            // the offer opens *There is no key file beside your library. A backup holds one that opens it.* and asks her
            // sentence's question (her first sentence, that the key file beside doesn't open it, assumed one stood there).
            // This Mac's keychain copy never meets an empty place here — rule 1's quiet restore puts it back first —
            // so its sentence stays hers, as is.
            if besideEmpty, case .backup = offer.source {
                return ProtectionWords.offerBesideEmptyFromABackup + " " + ProtectionWords.offerUseItQuestion
            }
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
        guard case .offer(let offer, _)? = current, !busy else { return }
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
    /// RULE 27 after a quiet-road open: no key file anywhere — the banner (her U2-7 words, VX-414), no doors.
    var noKeyFileAnywhere: NoKeyFileAnywhere?
    /// VX-308 U3 — VX-447 (her ruling: the banner BECOMES THE DOOR): the place beside the library held NOTHING when the
    /// open's search ran (`RoadOpenReport.besideIsEmpty`) — the state the core's new-words act mints a key file in
    /// (`keyFileGoneEverywhere`). A STRAY there (another key's file — the fault's second arm) keeps her U2-7 banner with no
    /// door: a mint would write over it (rule 21).
    var noKeyFileDoor = false
    /// RULE 3: the model's moment owed at this open (`.beforeFirstBackup` / `.quietRoadFailed`), nil none.
    var passphraseMoment: PassphraseAsk?
    /// The receipts this open owes the status seam: rule 1's restore (§7c (6)); VX-308 U2 — a follow its settle finished
    /// (VX-107: the follow's Done).
    var receipts: [String]

    static let none = RoadStandingFaces(noKeyFileAnywhere: nil, passphraseMoment: nil, receipts: [])

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
        // (`.besideOpensItOnlyThroughItsHistory` says nothing: its line is dropped — no state reaches it, VX-414.)
        var receipts = report.repairsDone.contains(.restoreKeyFileFromMirror) ? [ProtectionWords.restoredFromMirror] : []
        // VX-308 U2 — VX-107: a follow this open's settle finished says its Done, the other-device sentence with it.
        if let followed = report.settledFollow { receipts.append(ProtectionWords.followDone(followed)) }
        var faces = RoadStandingFaces(noKeyFileAnywhere: nothing, passphraseMoment: moment, receipts: receipts)
        faces.noKeyFileDoor = nothing != nil && report.besideIsEmpty
        return faces
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
    /// VX-308 U1 — the account section (the BOOTSTRAP's model, beside the crossings) and THE ONE PRESENTER every protection
    /// sheet of the new road presents through (VX-239 + VX-243): handed to each open library's faces like the crossings.
    var account: RoadAccountModel?
    var sheets: ProtectionSheetPresenter?
    /// VX-308 U3 — the key doors (the BOOTSTRAP's model, beside the crossings and the account section; it presents through
    /// the one presenter): Change passphrase…, Reset forgotten passphrase…, and New Words' face for the words section.
    var keyDoors: RoadKeyDoorsModel?
    /// VX-307 U2b — THE CARD ABOVE THE QUICK ENTRY (rules 2 and 3 as amended): the words' offer and rule 3's reminder,
    /// one card (`WordsBandModel`). nil where no factory built one (a test's hand-made faces).
    let band: WordsBandModel?
    /// VX-307 U2c (VX-379's pane rows, U2a's F-6): the OPEN library's posture — the record's mode, read when this
    /// open's faces were made (a crossing reopens, and the reopened library gets faces of its own). Settings ▸ Data
    /// Safety's Castle warning reads it on the new road (today's controller's posture is today's road's). nil: not
    /// known (a test's hand-made faces).
    let posture: ProtectionMode?

    /// VX-308 U3 — VX-447: the look the no-key-file banner's door opened (the banner's ONE look, made through the band so
    /// one look holds words at a time), and whether a mint has since written the fresh key file (the banner then retires
    /// once that look closes).
    private(set) var noKeyFileLook: WordsLookModel?
    private(set) var keyFileRemade = false

    @ObservationIgnored private let setPassphrase: (String) async -> SetPassphraseOutcome
    @ObservationIgnored private let passphraseExists: () -> Bool
    /// VX-308 U3 (R-U3-4): whether a look asks the passphrase — the core's fact now (`lookAsksPassphrase`).
    @ObservationIgnored private let lookAsksPassphrase: () -> Bool
    /// VX-308 U3 — VX-447: the live key file of the library's key stands now; rule 5's pair taken (true: written).
    @ObservationIgnored private let keyFileStands: () -> Bool
    @ObservationIgnored private let takeBackupPair: () async -> Bool
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
        copyWords: @escaping ([String]) -> Void = { _ in },
        posture: ProtectionMode? = nil,
        lookAsksPassphrase: (() -> Bool)? = nil,
        keyFileStands: @escaping () -> Bool = { false },
        takeBackupPair: @escaping () async -> Bool = { false }
    ) {
        self.faces = faces
        self.reminder = reminder
        self.setPassphrase = setPassphrase
        self.passphraseExists = passphraseExists
        self.lookAsksPassphrase = lookAsksPassphrase ?? passphraseExists
        self.keyFileStands = keyFileStands
        self.takeBackupPair = takeBackupPair
        self.receiptsOwed = receiptsOwed
        self.band = band
        self.posture = posture
        self.mintWords = mintWords
        self.copyWords = copyWords
        offersSetPassphrase = !passphraseExists()
    }

    /// The open library's protection faces, from its session (the bootstrap's `.ready` on the new road): the standing faces read from the open's
    /// report, rule 3's reminder (its launch counted once per process on a writing road, then evaluated), and the
    /// set-passphrase sheet's road through the session's executor. VX-307 U2b: the card above the quick entry — the
    /// words' look minting through rule 6's act on the session (`mintFreshWords`), `copyWords` the platform's one
    /// clipboard rule (the Mac's `WordsClipboard.copyConcealed` — VX-448), its local ledger in the reminder ledger's defaults.
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
        // VX-308 U3 (R-U3-4): a look asks by the core's own fact NOW; (F-U2-3) a synced library's look says the account
        // line before minting.
        let lookAsks: () -> Bool = { ProtectionOpenRoad.lookAsksPassphrase(session.library) }
        let synced: () -> Bool = { session.library.record?.account != nil }
        // VX-447: a mint that wrote the FRESH key file is heard by the model this make returns (the banner retires and the
        // backup follows).
        let standing = StandingBox()
        let mint: (String?) async -> WordsMintOutcome = { passphrase in
            let outcome = await Task.detached(priority: .userInitiated) {
                await ProtectionOpenRoad.mintFreshWords(session: session, passphrase: passphrase)
            }.value
            if case .minted = outcome { standing.model?.mintLanded() }
            return outcome
        }
        let band = WordsBandModel(
            libraryID: libraryID, writes: session.writes, ledger: WordsCardLedger(defaults: ledger.defaults),
            snoozes: snoozes, reminder: reminder, passphraseExists: lookAsks, replacesAccountWords: synced, mint: mint,
            copy: copyWords)
        let model = RoadStandingModel(
            faces: faces, reminder: reminder,
            setPassphrase: { passphrase in
                await Task.detached(priority: .userInitiated) {
                    await ProtectionOpenRoad.setFirstPassphrase(session: session, new: passphrase)
                }.value
            },
            passphraseExists: passphraseExists,
            receiptsOwed: { session.takeReceipts() },
            band: band, mintWords: mint, copyWords: copyWords,
            posture: session.library.record?.mode,
            lookAsksPassphrase: lookAsks,
            keyFileStands: {
                let library = session.library
                return library.keyFile?.fingerprint == library.fingerprint
            },
            takeBackupPair: {
                await Task.detached(priority: .utility) { ProtectionBackupHook.takePair(session) == .written }.value
            })
        standing.model = model
        return model
    }

    /// The model a `make` returns, for the mint's closure built before it.
    private final class StandingBox {
        weak var model: RoadStandingModel?
    }

    /// VX-307 U2b — a look for another home (the tour's last card, Settings ▸ Protection): the band's roads; recording
    /// there retires the card's offer too. With no band (a test's hand-made faces), a look that refuses at once.
    func makeWordsLook() -> WordsLookModel {
        if let band, let mintWords {
            return band.makeLook(passphraseExists: lookAsksPassphrase, mint: mintWords, copy: copyWords)
        }
        return WordsLookModel(
            saysRuleSix: false, passphraseExists: passphraseExists,
            mint: { _ in .refused(ProtectionWords.wordsLookFailed) }, copy: copyWords, recorded: {})
    }

    // MARK: VX-308 U3 — VX-447: THE NO-KEY-FILE BANNER BECOMES THE DOOR (her ruling, QUESTIONS #235)

    /// The banner stands: the open found no key file anywhere — until a mint has written the fresh one AND the look that
    /// shows its words has closed (the words never vanish from under her: they are shown in the banner).
    var showsNoKeyFileBanner: Bool {
        guard faces.noKeyFileAnywhere != nil else { return false }
        return !keyFileRemade || (noKeyFileLook.map { $0.phase != .closed } ?? false)
    }

    /// The banner carries the act (the live place empty — `RoadStandingFaces.noKeyFileDoor`), until the fresh file stands.
    var offersNoKeyFileDoor: Bool { faces.noKeyFileDoor && !keyFileRemade }

    /// The banner's door: its look (made once, through the band — one look at a time; recording there retires the card's
    /// offer too), opened: on an unsynced Standard library the words are minted at once (nothing can verify a passphrase:
    /// no lock survived — R-U3-4); synced, the account's passphrase is asked first and the account line said (F-U2-3).
    func openNoKeyFileLook() async {
        guard offersNoKeyFileDoor else { return }
        let look = noKeyFileLook ?? makeWordsLook()
        noKeyFileLook = look
        await look.open()
    }

    /// A look's mint landed (any home): when the open found no key file anywhere and the live key file of the key now
    /// stands, the FRESH FILE was written (the core's VX-447 arm) — the banner's act is done but for THE BACKUP, which
    /// follows: rule 5's pair through its one road, off the main actor, then one receipt saying what stands now.
    func mintLanded() {
        guard faces.noKeyFileAnywhere != nil, !keyFileRemade, keyFileStands() else { return }
        keyFileRemade = true
        offersSetPassphrase = !passphraseExists()
        ProtectionOpenRoad.log("road: VX-447 — the fresh key file stands; the backup follows")
        let takeBackupPair = takeBackupPair
        Task { [weak self] in
            let backedUp = await takeBackupPair()
            self?.speak?(ProtectionWords.keyFileRemadeReceipt(backedUp: backedUp))
        }
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
