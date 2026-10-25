//
//  RoadAccountModel.swift
//  Variorum (shared: Mac + Mobile — the phone's account faces are later; the brain is one)
//
//  VX-308 U1 piece 5 — THE ACCOUNT SECTION'S BRAIN on the new road (`notes/plans/vx-308-accounts-key-doors.md` §5a and
//  its U1 ARBITRATION). Every act is an injected road (the bootstrap's — the pane's one read, the press on the open
//  session; the composition root's — the app's sign-out; a test's, planted), so the models run with no keychain, no disk
//  and no window. Every sheet is presented through THE ONE PRESENTER (`ProtectionSheetPresenter` — R-6), shared with the
//  crossings, so an account sheet and a crossing's confirm can never both stand, and none re-presents after an unlock.
//
//    - `RoadAccountModel` — OWNED BY THE BOOTSTRAP beside the crossings: the faces as `assess` last said them (`refresh`,
//      at each appearance of the pane and after every act), each door's confirm, *Sign in…* (the app's Account sheet —
//      R-5), *Sign out…* (today's shipped confirm, rendered only where the composition gives the road — P-2).
//    - `RoadAccountConfirmModel` — one door's confirm: turning sync on asks exactly the door's fields (the passphrase — a
//      NEW one typed twice where none exists — and the twelve words, checked for shape before the road is asked anything);
//      a leave asks nothing (rule 16 — the face still confirms). A door the road found CHANGED is re-shown (VX-108).
//      VX-308 U2: a join, Move and the follow ask ONE secret (rule 14 — the passphrase, the words, or both), into Castle
//      with the gate choice; a join whose words were replaced turns into THE WORDS MOMENT (rule 7; R-U2-5): the words she
//      TYPED shown over the one look idiom (`WordsLookModel` — numbered, never stored, closed behind her warning) under rule
//      7's sentence, or — the passphrase typed — the notice that they were replaced, WITHOUT showing them (P-VX378-U2-3
//      (a)); the sheet goes when the moment closes.
//    - `RoadSignOutModel` — the sign-out confirm.
//    - `RoadSignedOutCastleModel` — USE CASTLE WHILE SIGNED OUT (the signed-out screen, drafted to the current rules — her
//      word: the 10-13 block is superseded): *Continue* runs This Mac Only (the leave — nothing typed, no key changes) and
//      hands the floor to Use Castle's own confirm; *Cancel* writes nothing. (Presented by the crossings — Use Castle's
//      door — since its successor is theirs.)
//

import Foundation
import Observation
import VariorumCore

/// The account section's roads (the bootstrap's on the new road; a test's, planted).
struct RoadAccountRoads {
    /// The faces now (a READ — the pane's one read). nil: no library open on the new road, or its facts unreadable.
    var read: @MainActor () async -> RoadAccountFaces?
    /// The press — the re-read, then the act.
    var press: @MainActor (RoadAccountRequest) async -> RoadAccountPress
    /// An act landed: the rest of the pane re-reads (the crossings — the library's account changed under them).
    var landed: @MainActor () async -> Void = {}
    /// The status seam's receipt line (`receipt_style` governs it).
    var receipt: @MainActor (String) -> Void = { _ in }
    /// VX-308 U2 — the words moment's Copy door: the platform's ONE words clipboard rule (the bootstrap's `copyWords` —
    /// the same road the card above the quick entry rides; no new clipboard road).
    var copyWords: @MainActor ([String]) -> Void = { _ in }
    /// VX-309 U2 — VX-457: the follow's Done owed for the OPEN library — the durable mark (`FollowDoneMark`), re-read at
    /// every landing of the section, so `receipt_style` off and a quit lose nothing. (A test's roads that never follow keep
    /// the default: none.)
    var followDoneOwed: @MainActor () -> FollowKind? = { nil }
    /// VX-529 unit 2 — the durable notice owed, whole (`FollowDoneNotice`: a follow's Done, R-529-5's words arm, the heal);
    /// nil (a test's roads that only follow): `followDoneOwed`'s kind is read.
    var followDoneNoticeOwed: (@MainActor () -> FollowDoneNotice?)? = nil
    /// VX-309 U2 — VX-457: the notice's *OK* — the open library's mark clears (nothing else changes).
    var dismissFollowDone: @MainActor () -> Void = {}
}

/// VX-308 U2 — THE WORDS MOMENT after a join (rule 7: "your library's twelve words are now your account's twelve words;
/// here they are; the old ones still open backups you made before today").
@MainActor
enum RoadJoinWordsMoment {
    /// The words were typed at the join: shown once, over the one look idiom, under rule 7's sentence.
    case shown(WordsLookModel)
    /// The passphrase was typed: the words were replaced and nothing here holds them (P-VX378-U2-3 (a)).
    case notShown
}

// MARK: - One door's confirm

@MainActor
@Observable
final class RoadAccountConfirmModel: Identifiable {
    let id = UUID()
    /// The door as shown (replaced when the press found it changed).
    private(set) var door: RoadAccountDoorOpen
    private(set) var busy = false
    /// Why the press did nothing (nil: nothing to say).
    private(set) var refusal: String?
    /// VX-308 U2 — into Castle: Touch ID or Always ask (the door's preselection — the follow's own default).
    var gate: GateStyle
    /// VX-308 U2 — the words moment standing after a join (nil: none).
    private(set) var moment: RoadJoinWordsMoment?
    /// **VX-510 D-A2 — the act's FIRST ROUND, confirmed in its own sheet (VX-507)**: set the moment an act that owes one
    /// lands (`running`), its outcome when the round comes back (`done`). The sheet shows it once any words moment has
    /// closed, and stays until her Done — which never cancels the round. nil: no first round here (none owed, no road —
    /// the confirm finishes exactly as before).
    private(set) var round: FirstRoundPhase?
    /// VX-529 unit 2 — what the landed sheet says beside its round (R-529-5's words arm: the window and the Reset chain);
    /// empty for every other landing.
    private(set) var landedLines: [String] = []

    @ObservationIgnored private let act: (RoadAccountRequest) async -> RoadAccountPress
    /// VX-308 U2 — the act LANDED while the sheet stays for the words moment (its receipt, the pane's re-read).
    @ObservationIgnored private let landed: ((RoadAccountPress) -> Void)?
    /// `.made` → the act landed (and any moment is closed); nil → she left (nothing written).
    @ObservationIgnored private let finished: (RoadAccountPress?) -> Void
    @ObservationIgnored private let copyWords: ([String]) -> Void
    @ObservationIgnored private var landedPress: RoadAccountPress?
    /// VX-510 D-A1 — the composition's first-round road, handed in only for an act that owes one
    /// (`RoadAccountDoorOpen.owesFirstRound`); nil: none here (a leave, a re-keying act, the phone until VM-8, a test world
    /// without one — the confirm finishes exactly as before).
    @ObservationIgnored private let firstRound: (() async -> FirstRoundOutcome)?
    /// The round the landing started (never cancelled from here — closing the sheet leaves it running).
    @ObservationIgnored private var roundTask: Task<FirstRoundOutcome, Never>?

    init(
        door: RoadAccountDoorOpen, act: @escaping (RoadAccountRequest) async -> RoadAccountPress,
        copyWords: @escaping ([String]) -> Void = { _ in },
        firstRound: (() async -> FirstRoundOutcome)? = nil,
        landed: ((RoadAccountPress) -> Void)? = nil,
        finished: @escaping (RoadAccountPress?) -> Void
    ) {
        self.door = door
        gate = door.gate?.preselected ?? .alwaysAsk
        self.act = act
        self.copyWords = copyWords
        self.firstRound = firstRound
        self.landed = landed
        self.finished = finished
    }

    /// TEST-VISIBLE: the first round the landing started, awaited to its outcome (nil: none was started). Production never
    /// awaits it — the sheet observes the phase.
    func awaitFirstRound() async -> FirstRoundOutcome? {
        await roundTask?.value
    }

    var title: String { door.title }
    var button: String { door.button }
    /// The passphrase field is a NEW passphrase typed twice (none set yet — rule 3).
    var asksNewPassphrase: Bool { door.newPassphrase }

    /// The button: every field the ask names typed, nothing running.
    func canSubmit(passphrase: String, again: String, words: String) -> Bool {
        guard !busy else { return false }
        switch door.ask {
        case .passphraseAndWords:
            let passphraseTyped = !passphrase.isEmpty && (!door.newPassphrase || !again.isEmpty)
            return passphraseTyped && !WordsInput.words(from: words).isEmpty
        case .passphrase:
            return !passphrase.isEmpty && (!door.newPassphrase || !again.isEmpty)
        case .oneSecret:
            return !passphrase.isEmpty || !WordsInput.words(from: words).isEmpty
        case .nothing:
            return true
        }
    }

    func submit(passphrase: String = "", again: String = "", words wordsText: String = "") async {
        guard moment == nil, round == nil, canSubmit(passphrase: passphrase, again: again, words: wordsText) else { return }
        var typedWords: [String]?
        // VX-308 U2: one secret (rule 14) — the words, when typed, checked for shape like any.
        let oneSecretWords = door.ask == .oneSecret && !WordsInput.words(from: wordsText).isEmpty
        if door.ask.asksWords || oneSecretWords {
            let words = WordsInput.words(from: wordsText)
            do {
                try RecoveryPhrase.validate(words)
            } catch let error as RecoveryPhraseError {
                refusal = ProtectionOpenRoad.sentence(for: error)
                return
            } catch {
                refusal = ProtectionWords.wordsDoNotOpen
                return
            }
            typedWords = words
        }
        // VX-309 U2 — VX-211: a passphrase being SET meets the floor first (today's order: the floor, then the match).
        if door.ask.asksPassphrase, door.newPassphrase, let floor = NewPassphraseRule.floorRefusal(passphrase) {
            refusal = floor
            return
        }
        if door.ask.asksPassphrase, door.newPassphrase, passphrase != again {
            refusal = ProtectionWords.setPassphraseMismatch
            return
        }
        var typed = TypedSecrets.none
        if door.ask == .oneSecret {
            // Untrimmed on purpose (a passphrase may begin or end with a space); either, or both.
            typed = TypedSecrets(passphrase: passphrase.isEmpty ? nil : passphrase, words: typedWords)
        } else if door.ask.asksPassphrase || door.ask.asksWords {
            // Untrimmed on purpose (a passphrase may begin or end with a space).
            let typedPassphrase = door.ask.asksPassphrase ? passphrase : nil
            typed = door.newPassphrase
                ? TypedSecrets(words: typedWords, newPassphrase: typedPassphrase)
                : TypedSecrets(passphrase: typedPassphrase, words: typedWords)
        }
        busy = true
        refusal = nil
        let request = RoadAccountRequest(door: door.door, shown: door, typed: typed, gate: door.gate == nil ? nil : gate)
        let press = await act(request)
        busy = false
        switch press {
        case .made(_, let wordsReplaced):
            // VX-529 unit 2 (R-529-5): the pair catch-up landed by the twelve words — the sheet says the window plainly and
            // the Reset chain beside its round.
            if case .caughtUpByTheWords? = ProtectionAccountRoad.followDoneNotice(for: request) {
                landedLines = [ProtectionWords.pairWordsWindow, ProtectionWords.pairResetChain]
            }
            // VX-510 D-A1 (VX-498): the act landed on the open session — its first round starts AT ONCE (while any words
            // moment is read), never waiting on the sheet; D-A2 (VX-507): the sheet stays to confirm it.
            if let firstRound, roundTask == nil {
                round = .running
                roundTask = Task { [weak self] in
                    let outcome = await firstRound()
                    self?.roundCameBack(outcome)
                    return outcome
                }
            }
            guard wordsReplaced, door.spec.join != nil, door.spec.join != .setsUpInLibrarysMode else {
                guard round != nil else {
                    finished(press)
                    return
                }
                // The act landed: its receipt and the pane's re-read now; the sheet stays for the round (Done closes it).
                landedPress = press
                landed?(press)
                return
            }
            // RULE 7's moment (R-U2-5): the act landed — its receipt and the pane's re-read now; the sheet stays.
            landedPress = press
            landed?(press)
            await openMoment(typedWords: typed.words)
        case .refused(let sentence):
            refusal = sentence
        case .changed(let fresh):
            door = fresh
            if fresh.gate?.touchIDAvailable == false { gate = .alwaysAsk }
            refusal = ProtectionWords.crossingDoorChanged
        }
    }

    /// THE WORDS MOMENT: the typed words shown over the one look idiom (they are the account's words now — and the
    /// library's), held only by the look while shown; the passphrase typed, the notice alone.
    private func openMoment(typedWords: [String]?) async {
        guard let words = typedWords else {
            moment = .notShown
            return
        }
        let look = WordsLookModel(
            saysRuleSix: false, passphraseExists: { false }, mint: { _ in .minted(words) }, copy: copyWords,
            recorded: { [weak self] in self?.closeMoment() })
        moment = .shown(look)
        await look.open()
    }

    /// The moment closed (past the look's warning, or the notice's OK): the words forgotten with the look; the sheet goes —
    /// or, with a first round standing (VX-510 D-A2), the sheet turns to it and stays until her Done.
    func closeMoment() {
        guard moment != nil else { return }
        moment = nil
        guard round == nil else { return }
        finished(landedPress)
    }

    /// The round came back (the sheet may already be closed — the outcome is then the status row's alone).
    private func roundCameBack(_ outcome: FirstRoundOutcome) {
        guard round != nil else { return }
        round = .done(outcome)
    }

    /// **VX-510 D-A2 — Done**, the round phase's one door, always available: the sheet goes and the act's landing is
    /// finished; the round is NOT cancelled — it keeps going, and the sync row says when it is done (a long first catch-up
    /// never holds the sheet hostage).
    func done() {
        guard round != nil, moment == nil else { return }
        finished(landedPress)
    }

    /// What the round phase says once its outcome came back (nil while it runs, or with no round): a success line, or what
    /// blocks it in the sync row's own words (`firstRoundLine`).
    var roundLine: String? {
        guard case .done(let outcome)? = round else { return nil }
        return Self.firstRoundLine(outcome, joins: door.joinsAnAccount, follows: door.door == .follow)
    }

    /// The round's error as the row shows it under its error face (`ErrorCauseNote`'s text) — the sheet shows the same
    /// note beneath the line; nil for every other outcome.
    var roundErrorCause: String? {
        guard case .done(.ran(let status))? = round, let error = status.lastError else { return nil }
        return Self.rowFace(status).kind == .error ? error : nil
    }

    /// **VX-510 D-A2 — the outcome, in words (P-VX510-1, PROVISIONAL, hers)**: a clean round — the set-up's or the join's
    /// success line; anything else — "Sync hasn't run yet: ‹the sync row's own sentence›." (ONE presentation source:
    /// `SyncStatusRow.line(for:lastSuccessAt:)`, which the row renders too). Held has no row face of its own: the row's
    /// held refusal, said for a sheet that stands over Settings (PROVISIONAL P-VX510-A1). Not configured is the row's
    /// signed-in, no-chain face ("Sync is off" — a failed owner adoption, F-5). VX-510 D-B0: the follow's clean round says
    /// its own line (`follows` — PROVISIONAL P-VX510-B1-1); the follow's Done stays the section's durable notice (VX-457).
    /// The ladder's F-R1-1 (the belt beside `SyncSession.runRound`'s settle): a status still reading SYNCING is a round
    /// still running — the running-progress words, never "Sync hasn't run yet: Syncing…".
    static func firstRoundLine(_ outcome: FirstRoundOutcome, joins: Bool, follows: Bool = false) -> String {
        switch outcome {
        case .held:
            return ProtectionWords.firstRoundBlocked(ProtectionWords.firstRoundHeld)
        case .notConfigured:
            return ProtectionWords.firstRoundBlocked(SyncStatusRow.line(for: .syncOff, lastSuccessAt: nil))
        case .ran(let status):
            let face = rowFace(status)
            if face.kind == .syncing { return ProtectionWords.firstRoundProgress }
            guard face.kind != .idle else {
                if follows { return ProtectionWords.firstRoundFollowLanded }
                return joins ? ProtectionWords.firstRoundJoinLanded : ProtectionWords.firstRoundSetUpLanded
            }
            return ProtectionWords.firstRoundBlocked(SyncStatusRow.line(for: face.kind, lastSuccessAt: status.lastSuccessAt))
        }
    }

    /// The sync row's face for a round's status — the row's own classification (configured, signed in: the act just
    /// joined the library to the account signed in).
    static func rowFace(_ status: SyncScheduler.Status) -> SyncRowFace {
        SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: status.isSyncing,
            lastError: status.lastError, lastErrorIsOffline: status.lastErrorIsOffline, stalled: status.pullStalled)
    }

    /// The confirm's way out — nothing written. (With the moment standing the act already landed: its way out is the
    /// moment's close — a window closing under it closes it. With the first round standing: Done — the round goes on.)
    func cancel() {
        guard !busy else { return }
        if moment != nil {
            closeMoment()
            return
        }
        if round != nil {
            done()
            return
        }
        finished(nil)
    }
}

/// **VX-510 D-A2** — an account act's first round as its sheet shows it.
enum FirstRoundPhase: Equatable {
    /// The round is running (her Done is open throughout — sync keeps going).
    case running
    /// It came back — confirmed, or what blocks it.
    case done(FirstRoundOutcome)
}

// MARK: - The sign-out confirm

@MainActor
@Observable
final class RoadSignOutModel: Identifiable {
    let id = UUID()
    private(set) var busy = false

    @ObservationIgnored private let signOut: () async -> Void
    /// true: signed out; false: she left.
    @ObservationIgnored private let finished: (Bool) -> Void

    init(signOut: @escaping () async -> Void, finished: @escaping (Bool) -> Void) {
        self.signOut = signOut
        self.finished = finished
    }

    func confirm() async {
        guard !busy else { return }
        busy = true
        await signOut()
        busy = false
        finished(true)
    }

    func cancel() {
        guard !busy else { return }
        finished(false)
    }
}

// MARK: - Use Castle while signed out

@MainActor
@Observable
final class RoadSignedOutCastleModel: Identifiable {
    let id = UUID()
    let title = ProtectionWords.signedOutCastleTitle
    /// The screen's sentences, in order (drafted to the current rules — PROVISIONAL).
    let sentences = [ProtectionWords.signedOutCastleLead, ProtectionWords.signedOutCastleWholeAccount]
    private(set) var busy = false
    private(set) var refusal: String?

    /// This Mac Only — nil: the leave landed; else its refusal.
    @ObservationIgnored private let leave: () async -> String?
    /// true: the leave landed (Use Castle's confirm follows); false: she left (nothing written).
    @ObservationIgnored private let finished: (Bool) -> Void

    init(leave: @escaping () async -> String?, finished: @escaping (Bool) -> Void) {
        self.leave = leave
        self.finished = finished
    }

    /// *Continue* — the leave, then the floor handed to Use Castle's confirm.
    func proceed() async {
        guard !busy else { return }
        busy = true
        refusal = nil
        let refused = await leave()
        busy = false
        if let refused {
            refusal = refused
        } else {
            finished(true)
        }
    }

    func cancel() {
        guard !busy else { return }
        finished(false)
    }
}

// MARK: - The account section on the open library (the bootstrap's)

@MainActor
@Observable
final class RoadAccountModel {
    /// The faces as `assess` last said them (nil until read, or with no library open on the new road).
    private(set) var faces: RoadAccountFaces?
    /// VX-309 U2 — VX-457: the follow's Done standing in the section until her OK (its truth is the durable mark, re-read at
    /// every landing — never this process's memory alone). VX-529 unit 2: the whole notice (`FollowDoneNotice`).
    private(set) var followDone: FollowDoneNotice?

    @ObservationIgnored let roads: RoadAccountRoads
    @ObservationIgnored let presenter: ProtectionSheetPresenter
    /// The composition root's — the app's sign-out (its own session; rule 16: signing out never changes the record). nil:
    /// *Sign out…* is not rendered (P-2).
    @ObservationIgnored var signOutRoad: (@MainActor () async -> Void)?
    /// **VX-510 D-A1 — the composition root's first-round road** (`signOutRoad`'s precedent; wired by
    /// `AppBootstrap.attach(services:)` to `AppServices.runFirstRound`): one round run to its end and what it came to, asked
    /// the moment an act that changes sync's standing on the open session lands (`RoadAccountDoorOpen.owesFirstRound`). nil
    /// (the phone until VM-8, a test world without one): the confirm finishes exactly as before (P-2).
    @ObservationIgnored var firstRound: (@MainActor () async -> FirstRoundOutcome)?
    /// **VX-510 D-B0 — a RE-KEYING act's first round** (F-6 (A), ruled; wired by `AppBootstrap.attach(services:)` beside
    /// `firstRound`). A re-keying act lands through the reopen, whose teardown releases the open session's services; its
    /// `.made` comes back before the reopen's fresh services are composed. So the press takes the bootstrap's services
    /// generation, and at `.made` the round waits for services attached after it (the reopen's — bounded) and asks THEM.
    /// nil (the phone until VM-8, a test world without one): a re-keying act's confirm finishes as before (P-2).
    @ObservationIgnored var firstRoundAfterReopen: FirstRoundAfterReopen?
    @ObservationIgnored private var reads = 0

    /// VX-510 D-B0 — the composition root's road for a re-keying act's first round.
    struct FirstRoundAfterReopen {
        /// The services generation NOW — taken at the press, before the reopen's teardown releases the services.
        let generation: @MainActor () -> Int
        /// At `.made`: the services attached after `generation` (the reopen's fresh ones), asked for one round to its end.
        let round: @MainActor (Int) async -> FirstRoundOutcome
    }
    @ObservationIgnored private var landedRead = 0

    init(roads: RoadAccountRoads, presenter: ProtectionSheetPresenter = ProtectionSheetPresenter()) {
        self.roads = roads
        self.presenter = presenter
    }

    /// The door confirm standing (through the presenter).
    var confirm: RoadAccountConfirmModel? {
        if case .account(let model)? = presenter.sheet { return model }
        return nil
    }

    /// The sign-out confirm standing.
    var signOutConfirm: RoadSignOutModel? {
        if case .signOut(let model)? = presenter.sheet { return model }
        return nil
    }

    /// *Sign out…* renders: someone is signed in and the composition gave the road.
    var offersSignOut: Bool { faces?.signOut == true && signOutRoad != nil }

    /// Re-read — the crossings' landing rule: a read lands unless a NEWER one already landed.
    func refresh() async {
        let read = beginRead()
        land(await roads.read(), read: read)
    }

    /// VX-308 ladder round 1 (MINOR-2): a read's number, taken BEFORE the read starts (the pane's one read for its three
    /// sections lands here through `land`, by the same rule).
    func beginRead() -> Int {
        reads += 1
        return reads
    }

    /// Read `read`'s faces land unless a NEWER read already landed (VX-457: the follow's Done re-read beside them).
    func land(_ fresh: RoadAccountFaces?, read: Int) {
        guard read > landedRead else { return }
        landedRead = read
        faces = fresh
        // VX-529 unit 2 (scope 2 — the VX-510 repro's stale line): a follow's Done says this Mac caught up, which is false
        // while a follow is OWED — it never stands beside the follow door. The mark itself stays (her OK is its only clear;
        // the follow that lands next writes its own — the newest Done is the true one).
        followDone = fresh?.follow.openDoor != nil
            ? nil : (roads.followDoneNoticeOwed.map { $0() } ?? roads.followDoneOwed().map(FollowDoneNotice.followed))
    }

    /// VX-309 U2 — VX-457: the follow's Done's *OK* — the mark clears; the notice goes.
    func followDoneOK() {
        roads.dismissFollowDone()
        followDone = nil
    }

    /// A door's press on the pane: its confirm, from the door as last read, on `host`.
    func open(_ door: RoadAccountDoor, on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, let open = faces?.face(door).openDoor else { return }
        let roads = roads
        let presenter = presenter
        var id: UUID?
        // A landed act's receipt is spoken ONCE and the pane re-read — at the landing, or (no words moment) at the close.
        var landedOnce = false
        let land: (RoadAccountPress) -> Void = { [weak self] press in
            guard !landedOnce else { return }
            landedOnce = true
            if case .made(let receipt?, _) = press { roads.receipt(receipt) }
            Task {
                await self?.refresh()
                await roads.landed()
            }
        }
        // VX-510 D-A1 + D-B0: the first round, for an act whose landing changes sync's standing — on the open session
        // through its services (D-A1), or, a re-keying act, through the reopen's fresh services (D-B0). Which road is the
        // PRESSED door's (a door re-shown CHANGED may change its plan); the generation is taken at that press. No road for
        // the door (the phone until VM-8, a test world without one): no round — the confirm finishes as before (P-2).
        let openSession = self.firstRound
        let reopen = self.firstRoundAfterReopen
        var pressed: (rekeys: Bool, generation: Int)?
        let act: (RoadAccountRequest) async -> RoadAccountPress = { request in
            pressed = (request.shown.rekeys, reopen?.generation() ?? 0)
            return await roads.press(request)
        }
        let hasRoad = open.rekeys ? reopen != nil : openSession != nil
        let firstRound: (() async -> FirstRoundOutcome)? = open.owesFirstRound && hasRoad ? {
            guard let pressed, pressed.rekeys else { return await openSession?() ?? .notConfigured }
            return await reopen?.round(pressed.generation) ?? .notConfigured
        } : nil
        let confirm = RoadAccountConfirmModel(
            door: open, act: act, copyWords: roads.copyWords,
            firstRound: firstRound, landed: land,
            finished: { [weak self] press in
                if let id { presenter.dismiss(id) }
                if let press {
                    land(press)
                } else {
                    Task { await self?.refresh() }
                }
            })
        id = confirm.id
        presenter.present(.account(confirm), on: host)
    }

    /// *Sign in…* — the app's Account sheet (R-5); the section re-reads when it closes.
    func openSignIn(on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, faces?.signIn == true else { return }
        let roads = roads
        presenter.present(.signIn(ProtectionSignInRequest { [weak self] in
            Task {
                await self?.refresh()
                await roads.landed()
            }
        }), on: host)
    }

    /// *Sign out…* — today's shipped confirm.
    func openSignOut(on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, offersSignOut, let signOut = signOutRoad else { return }
        let roads = roads
        let presenter = presenter
        var id: UUID?
        let model = RoadSignOutModel(signOut: signOut) { [weak self] signedOut in
            if let id { presenter.dismiss(id) }
            guard signedOut else { return }
            Task {
                await self?.refresh()
                await roads.landed()
            }
        }
        id = model.id
        presenter.present(.signOut(model), on: host)
    }

    /// The sheet's dismissal (a window closed under it) — the presenter's host rule.
    func dismissSheet(on host: ProtectionSheetHost = .settings) {
        presenter.hostDismissed(host)
    }
}
