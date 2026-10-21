//
//  WordsBand.swift
//  Variorum (shared: Mac + Mobile — the Mac renders it this phase; the phone's calm first open is a VM ticket,
//  P-VX307-U2b-0)
//
//  VX-307 U2b — THE TWELVE WORDS, HER WAY (VX-412; `notes/CastleRules.md` rules 2, 3, 6 and 7 as amended at her
//  sitting on VX-306's bundle — her words verbatim in `notes/plans/vx-307-castle-crossings.md` §3a; her drawing
//  `notes/plans/vx-307/her-cards-area-2026-10-18.png`). The brains, pure over injected roads:
//
//    - THE LOOK (`WordsLookModel`) — the words are NEVER shown before she asks; nothing stores them, so a look MINTS
//      the words she records through rule 6's act (`regenerateWords` — the key unchanged; a library with a passphrase
//      is asked it, one with none is asked nothing — PROVISIONAL P-VX307-U2b-1), then shows them ONCE with a Copy door
//      (the one clipboard rule, `WordsClipboard` — VX-448: concealed, cleared at lock and at quit) and "write these down now", and WARNS before it closes that
//      they won't be shown again (her words). Closing forgets them. Three homes compose it: the band card, the tour's
//      last card (beside the passphrase ask — rule 3), and Settings ▸ Protection (the door the dismiss toast names).
//    - THE BAND CARD (`WordsBandModel`) — the card above the quick entry, between the shelf listing and it (her
//      drawing): it OFFERS the words (rule 2's sentence, hers) until she records them or dismisses it (✕ — dismissed
//      for good, and a toast says where to find them in Settings); *Later* snoozes it to the next launch (her "a
//      snoozed card showing on next launch is fine"). It is also RULE 3's ONE HOME: the passphrase reminder folds into
//      the same card ("the one home for both asks; never a second bar, never a popup"), its cadence unchanged
//      (`PassphraseReminderRules` — the third launch, weekly, then "don't show again"; the two always-moments).
//    - THE LEDGER (`WordsCardLedger`) — LOCAL, per library, in this Mac's defaults beside the reminder's keys
//      (`variorum.calmAsks.words.<libraryID>.*`): dismissed, recorded. Never the words — nothing stores the words.
//      The snooze is this process's only (`WordsCardSnoozes`): the next launch shows the card again.
//

import Foundation
import Observation
import VariorumCore

// MARK: - The rules (pure)

nonisolated enum WordsCardRules {
    /// The band card offers the words: on a writing road, until they are recorded or the card is dismissed, and not
    /// while snoozed in this launch.
    static func offersWords(writes: Bool, dismissed: Bool, recorded: Bool, snoozed: Bool) -> Bool {
        writes && !dismissed && !recorded && !snoozed
    }

    /// The two columns a look lays the words out in: 1–6, then 7–12 (each entry its number and word).
    static func columns(_ words: [String]) -> [[(number: Int, word: String)]] {
        let numbered = words.enumerated().map { (number: $0.offset + 1, word: $0.element) }
        let half = (numbered.count + 1) / 2
        return [Array(numbered.prefix(half)), Array(numbered.dropFirst(half))]
    }
}

// MARK: - The ledger (this Mac's defaults — local, per library; never the words)

nonisolated struct WordsCardLedger: @unchecked Sendable {
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    /// The keys, beside the reminder's (`variorum.calmAsks.passphrase.<libraryID>.*`).
    enum Key {
        static func dismissed(_ libraryID: String) -> String { "variorum.calmAsks.words.\(libraryID).dismissed" }
        static func recorded(_ libraryID: String) -> String { "variorum.calmAsks.words.\(libraryID).recorded" }
    }

    func dismissed(_ libraryID: String) -> Bool { defaults.bool(forKey: Key.dismissed(libraryID)) }
    func recorded(_ libraryID: String) -> Bool { defaults.bool(forKey: Key.recorded(libraryID)) }
    func dismiss(_ libraryID: String) { defaults.set(true, forKey: Key.dismissed(libraryID)) }
    func record(_ libraryID: String) { defaults.set(true, forKey: Key.recorded(libraryID)) }

    /// VX-309 U1c — VX-444: Make this my library keeps the current pair (rule 17: "under your current pair"), so the words
    /// she recorded — or chose to stop being offered — for the outgoing library are still the new library's: its marks
    /// carry onto the new library's id. Only a mark that stands is carried (never one cleared); the outgoing library's own
    /// marks stay (it lives on in Previous Libraries, where the doors may make it a library again).
    func carry(from outgoing: String, to landed: String) {
        guard !outgoing.isEmpty, !landed.isEmpty, outgoing != landed else { return }
        if recorded(outgoing) { record(landed) }
        if dismissed(outgoing) { dismiss(landed) }
    }
}

/// The snooze — THIS PROCESS's only, so the next launch shows the card again (her "showing on next launch").
nonisolated final class WordsCardSnoozes: @unchecked Sendable {
    /// The app's one set (a test makes its own).
    static let process = WordsCardSnoozes()

    private let lock = NSLock()
    private var snoozed: Set<String> = []

    func snooze(_ libraryID: String) { lock.withLock { _ = snoozed.insert(libraryID) } }
    func isSnoozed(_ libraryID: String) -> Bool { lock.withLock { snoozed.contains(libraryID) } }
}

// MARK: - The look

/// What a look's mint did.
nonisolated enum WordsMintOutcome: Equatable, Sendable {
    /// Rule 6's act landed: these words lock the key file now (the key unchanged) — shown once, never stored.
    case minted([String])
    /// Nothing changed — the sentence says why (a wrong passphrase, another act running, a failure).
    case refused(String)
}

/// THE LOOK: ask (only where a passphrase exists — rule 6's door asks it), mint, show once with Copy, warn, close.
@MainActor
@Observable
final class WordsLookModel {
    enum Phase: Equatable, Sendable {
        /// Nothing open (the door is offered by its host).
        case closed
        /// The passphrase asked (rule 6: new words ask the passphrase where one exists).
        case asking
        /// The act running.
        case minting
        /// The words on screen, once.
        case shown
        /// Her close pressed: the warning that they won't be shown again, the words still on screen.
        case warning
    }

    private(set) var phase: Phase = .closed
    /// The words, held only while shown — empty otherwise (never stored anywhere).
    private(set) var words: [String] = []
    /// Why nothing happened (nil: nothing to say).
    private(set) var message: String?
    /// The Copy door was pressed (the caption shows).
    private(set) var copied = false
    /// Rule 6's one sentence (the key doesn't change; earlier backups open with the earlier words) — said when she
    /// has recorded words before, never on the first look (there were no words she knew).
    let saysRuleSix: Bool
    /// VX-308 U3 — F-U2-3 (the architect's ruling): the look's ask says, BEFORE anything is minted, that new words replace
    /// the ACCOUNT's words everywhere (a synced library — rule 7: the key doors change both locks together). Her *Show my
    /// twelve words* is the yes; the door is never blocked.
    private(set) var saysAccountWords = false

    @ObservationIgnored private let passphraseExists: () -> Bool
    /// Whether the library syncs NOW (read at each open — a library may turn sync on while the app runs).
    @ObservationIgnored private let replacesAccountWords: () -> Bool
    @ObservationIgnored private let mint: (String?) async -> WordsMintOutcome
    @ObservationIgnored private let copyRoad: ([String]) -> Void
    @ObservationIgnored private let recorded: () -> Void

    init(
        saysRuleSix: Bool,
        passphraseExists: @escaping () -> Bool,
        replacesAccountWords: @escaping () -> Bool = { false },
        mint: @escaping (String?) async -> WordsMintOutcome,
        copy: @escaping ([String]) -> Void,
        recorded: @escaping () -> Void
    ) {
        self.saysRuleSix = saysRuleSix
        self.passphraseExists = passphraseExists
        self.replacesAccountWords = replacesAccountWords
        self.mint = mint
        copyRoad = copy
        self.recorded = recorded
    }

    var columns: [[(number: Int, word: String)]] { WordsCardRules.columns(words) }

    /// Her click. `passphrase`: one she typed a moment ago at the same card (the tour's last card — rule 3's ask
    /// answered beside the words), so she is never asked it twice; otherwise a library with a passphrase is asked it
    /// and one with none mints at once. VX-308 U3 (F-U2-3): a SYNCED library always asks first and says that new words
    /// replace the account's words everywhere — before anything is minted.
    func open(passphrase known: String? = nil) async {
        guard phase == .closed else { return }
        message = nil
        saysAccountWords = replacesAccountWords()
        if saysAccountWords {
            phase = .asking
        } else if let known {
            await run(known, returningTo: .closed)
        } else if passphraseExists() {
            phase = .asking
        } else {
            await run(nil, returningTo: .closed)
        }
    }

    /// The passphrase typed (never trimmed — a passphrase may begin or end with a space).
    func submit(passphrase: String) async {
        guard phase == .asking, !passphrase.isEmpty else { return }
        message = nil
        await run(passphrase, returningTo: .asking)
    }

    /// The ask's way out — nothing written.
    func cancel() {
        guard phase == .asking else { return }
        phase = .closed
        message = nil
        saysAccountWords = false
    }

    /// VX-412's Copy door: the words to the clipboard by the host's one rule (VX-448: concealed; cleared at lock and quit).
    func copy() {
        guard phase == .shown || phase == .warning, !words.isEmpty else { return }
        copyRoad(words)
        copied = true
    }

    /// *I've written them down* — first the warning (her "these words won't be shown again").
    func writtenDown() {
        guard phase == .shown else { return }
        phase = .warning
    }

    /// Back to the words from the warning.
    func goBack() {
        guard phase == .warning else { return }
        phase = .shown
    }

    /// The close, past the warning: the words forgotten, the look recorded.
    func close() {
        guard phase == .warning else { return }
        words = []
        copied = false
        saysAccountWords = false
        phase = .closed
        recorded()
    }

    /// Whether the look holds words on screen (a host keeps its other doors back meanwhile — closing them would put
    /// the words away without the warning).
    var holdsWords: Bool { phase == .shown || phase == .warning || phase == .minting }

    private func run(_ passphrase: String?, returningTo back: Phase) async {
        phase = .minting
        switch await mint(passphrase) {
        case .minted(let fresh):
            words = fresh
            copied = false
            phase = .shown
        case .refused(let sentence):
            message = sentence
            phase = back
        }
    }
}

// MARK: - The band card

/// The card above the quick entry: the words' offer (until recorded or dismissed; snoozed to the next launch) and
/// rule 3's reminder folded in (its own cadence, its own doors).
@MainActor
@Observable
final class WordsBandModel {
    /// The words' row is offered (the look closed).
    private(set) var offersWords: Bool
    let look: WordsLookModel
    let reminder: PassphraseReminderModel

    @ObservationIgnored private let libraryID: String
    @ObservationIgnored private let writes: Bool
    @ObservationIgnored private let ledger: WordsCardLedger
    @ObservationIgnored private let snoozes: WordsCardSnoozes
    /// VX-308 U3 (F-U2-3): every look this band makes says the account line first on a synced library.
    @ObservationIgnored private let replacesAccountWords: () -> Bool
    /// Every look made over this library's roads (the card's, the tour's, Settings') — weakly: a look whose host went
    /// away is gone. ONE look may hold words at a time: a second look's mint would replace the words the first still
    /// shows, which would then no longer open the library (P-VX307-U2b-6).
    @ObservationIgnored private var looks: [WeakLook] = []

    private struct WeakLook {
        weak var look: WordsLookModel?
    }

    init(
        libraryID: String, writes: Bool, ledger: WordsCardLedger, snoozes: WordsCardSnoozes = .process,
        reminder: PassphraseReminderModel,
        passphraseExists: @escaping () -> Bool,
        replacesAccountWords: @escaping () -> Bool = { false },
        mint: @escaping (String?) async -> WordsMintOutcome,
        copy: @escaping ([String]) -> Void
    ) {
        self.libraryID = libraryID
        self.replacesAccountWords = replacesAccountWords
        self.writes = writes
        self.ledger = ledger
        self.snoozes = snoozes
        self.reminder = reminder
        offersWords = Self.offers(libraryID, writes: writes, ledger: ledger, snoozes: snoozes)
        // The first look on a library whose words were never recorded here says nothing of earlier words.
        var recordedHook: () -> Void = {}
        var mintHook: (String?) async -> WordsMintOutcome = mint
        look = WordsLookModel(
            saysRuleSix: !libraryID.isEmpty && ledger.recorded(libraryID),
            passphraseExists: passphraseExists, replacesAccountWords: replacesAccountWords, mint: { await mintHook($0) },
            copy: copy, recorded: { recordedHook() })
        recordedHook = { [weak self] in self?.wordsRecorded() }
        mintHook = guarded(mint)
        looks.append(WeakLook(look: look))
    }

    /// A look's mint, refused while ANOTHER look already holds words (the caller itself is minting, so it counts one).
    private func guarded(_ mint: @escaping (String?) async -> WordsMintOutcome) -> (String?) async -> WordsMintOutcome {
        { [weak self] passphrase in
            if let self, self.looks.filter({ $0.look?.holdsWords == true }).count > 1 {
                return .refused(ProtectionWords.wordsLookElsewhere)
            }
            return await mint(passphrase)
        }
    }

    private static func offers(
        _ libraryID: String, writes: Bool, ledger: WordsCardLedger, snoozes: WordsCardSnoozes
    ) -> Bool {
        guard !libraryID.isEmpty else { return false }
        return WordsCardRules.offersWords(
            writes: writes, dismissed: ledger.dismissed(libraryID), recorded: ledger.recorded(libraryID),
            snoozed: snoozes.isSnoozed(libraryID))
    }

    /// The reminder's row is showing (rule 3's cadence or one of its always-moments).
    var showsReminder: Bool { reminder.showing != nil }

    /// The card is on screen: the words offered or a look in progress, or the reminder.
    var visible: Bool { offersWords || look.phase != .closed || showsReminder }

    /// *Later* — the card waits for the next launch (this process's snooze; nothing written).
    func later() {
        guard offersWords, look.phase == .closed else { return }
        snoozes.snooze(libraryID)
        offersWords = false
        ProtectionOpenRoad.log("road: the words card snoozed to the next launch")
    }

    /// The ✕ — the card is dismissed for good (her "present until the user clicks the dismissing x button"), and the
    /// toast's sentence is handed back for the host to say on the status seam (always shown — a direction).
    func dismiss() -> String? {
        guard offersWords, look.phase == .closed else { return nil }
        ledger.dismiss(libraryID)
        offersWords = false
        ProtectionOpenRoad.log("road: the words card dismissed — Settings ▸ Protection keeps the door")
        return ProtectionWords.wordsCardDismissedToast
    }

    /// A look closed past its warning — here or at another home (the tour's last card, Settings): the words are
    /// recorded, and the card's words row retires.
    func wordsRecorded() {
        guard !libraryID.isEmpty else { return }
        ledger.record(libraryID)
        offersWords = false
        ProtectionOpenRoad.log("road: rule 2's look closed — the words card's offer retires")
    }

    /// A look for another home (the tour's last card, Settings ▸ Protection) over the same roads: recording there
    /// retires this card's offer too.
    func makeLook(
        passphraseExists: @escaping () -> Bool,
        mint: @escaping (String?) async -> WordsMintOutcome,
        copy: @escaping ([String]) -> Void
    ) -> WordsLookModel {
        let look = WordsLookModel(
            saysRuleSix: !libraryID.isEmpty && ledger.recorded(libraryID),
            passphraseExists: passphraseExists, replacesAccountWords: replacesAccountWords, mint: guarded(mint), copy: copy,
            recorded: { [weak self] in self?.wordsRecorded() })
        looks = looks.filter { $0.look != nil } + [WeakLook(look: look)]
        return look
    }
}

// MARK: - The tour's last card (rule 3: "The tutorial's last card asks, and shows the twelve words beside the ask")

/// The end card's two asks, side by side: the passphrase (rule 3's — only while the library has none) and the words
/// (rule 2's look). A passphrase set here a moment before the look is handed to it, so she is never asked it twice.
@MainActor
@Observable
final class TourEndLibraryModel {
    /// The passphrase ask (nil: the library already had one when the card opened).
    let passphrase: SetPassphraseModel?
    /// The passphrase was set at this card.
    private(set) var passphraseSet = false
    let look: WordsLookModel

    @ObservationIgnored private var justSet: String?

    init(standing: RoadStandingModel) {
        let look = standing.makeWordsLook()
        self.look = look
        var setHook: (String) -> Void = { _ in }
        passphrase = standing.offersSetPassphrase
            ? standing.makeSetPassphraseSheet(close: {}, onSet: { setHook($0) }) : nil
        setHook = { [weak self] typed in
            self?.justSet = typed
            self?.passphraseSet = true
        }
    }

    /// The words door: the look, handed the passphrase she just chose here (if she did).
    func showWords() async {
        await look.open(passphrase: justSet)
        if look.phase != .closed { justSet = nil }
    }

    /// The end card's three doors wait while words are on screen (closing the card would put them away without the
    /// warning).
    var holdsTheDoors: Bool { look.holdsWords || passphrase?.busy == true }
}
