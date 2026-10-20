//
//  RoadCrossingsModel.swift
//  Variorum (shared: Mac + Mobile — the phone's crossing faces are later; the brain is one)
//
//  VX-307 U2a — THE CROSSINGS' BRAIN on the new road (`notes/plans/vx-307-castle-crossings.md` §5c). Every act is an
//  injected road (the bootstrap's — the preflight, the app's pool closed, the core's act, the reopen; a test's,
//  planted), so the models are testable with no keychain, no disk and no window.
//
//    - `RoadCrossingsModel` — OWNED BY THE BOOTSTRAP: it outlives the reopen a crossing makes (the `.ready` tree, the
//      Settings pane and every `@State` go down and come back), so the confirm in flight, its refusal, and rule 11's
//      export notice survive it. It holds the doors as `assess` last said them (`refresh` — re-read at each appearance
//      of the pane), the one confirm, the notice, and the gate-style row's presses.
//    - `RoadCrossingConfirmModel` — one door's confirm: the door's sentences, exactly the fields its ask names (both
//      typed at the crossings — P-VX378-U2-2; a NEW passphrase typed twice when the library has none — rule 3), Use
//      Castle's gate choice, one button. The words are checked for shape before anything is asked of the road; the road
//      re-reads the door (VX-108) — a door that changed is RE-SHOWN with a line saying so, never acted on.
//

import Foundation
import Observation
import VariorumCore

/// One door's press, as the confirm hands it to the road.
nonisolated struct RoadCrossingRequest: Sendable {
    let door: RoadCrossingDoor
    /// The door as the confirm showed it — the road compares the door it re-reads with this (VX-108).
    let shown: RoadDoorOpen
    let typed: TypedSecrets
    /// Use Castle's choice (Always ask where it is not asked).
    let gate: GateStyle
    /// VX-308 U1: a sentence the crossing's receipt ends with (the signed-out road's — `ProtectionWords.bornCastleNote`);
    /// nil: the door's receipt alone.
    var receiptNote: String? = nil
}

/// What a press came to.
nonisolated enum RoadCrossingPress: Equatable, Sendable {
    /// The library crossed. `exportTurnedOff`: rule 11's notice is owed.
    case made(exportTurnedOff: Bool)
    case refused(String)
    /// The door is open but says something new (VX-108) — re-shown.
    case changed(RoadDoorOpen)
}

/// The crossings' roads (the bootstrap's on the new road; a test's, planted). Main-actor closures that hop off it.
struct RoadCrossingRoads {
    /// The doors now (a READ). nil: no library open on the new road, or its facts could not be read.
    var read: @MainActor () async -> RoadCrossingFaces?
    /// The press — the preflight, then the act.
    var cross: @MainActor (RoadCrossingRequest) async -> RoadCrossingPress
    /// The gate-style row (`changeSettings`).
    var changeGate: @MainActor (GateStyle, String?) async -> GateChangeOutcome
    /// Rule 11's reversal.
    var turnExportBackOn: @MainActor () async -> Bool
    /// Rule 11's notice owed — the DURABLE mark (ladder round 1, MAJOR-1): re-read at each refresh, so a quit before *OK*
    /// or an entry finished by a later open's settle never loses it.
    var exportNoticeOwed: @MainActor () async -> Bool
    /// *OK* — the mark clears.
    var dismissExportNotice: @MainActor () -> Void
    /// VX-308 U1 — the signed-out road's *Continue*: This Mac Only (rule 16's local leave), re-read at the press. nil: it
    /// landed; else its refusal. (A test's roads that never reach the signed-out road keep this default refusal.)
    var leaveForThisMacOnly: @MainActor () async -> String? = { ProtectionWords.crossingFailed }
    /// VX-309 U1c — VX-451: the idle dial — THIS MAC'S sealed `idleLockMinutes` through the core's `changeSettings` (nil =
    /// never). (A test's roads that never reach the dial keep this default refusal.)
    var changeIdleLock: @MainActor (Int?) async -> GateChangeOutcome = { _ in .refused(ProtectionWords.gateRowFailed) }
    /// VX-309 U1c — VX-451: *Lock Library Now* (the File menu's ⌃⌘L twin — one capability): the bootstrap's lock.
    var lockNow: @MainActor () async -> Void = {}
}

// MARK: - One door's confirm

@MainActor
@Observable
final class RoadCrossingConfirmModel: Identifiable {
    let id = UUID()
    /// The door as shown (replaced when the press found it changed).
    private(set) var door: RoadDoorOpen
    /// Use Castle's gate choice.
    var gate: GateStyle
    private(set) var busy = false
    /// Why the press did nothing (nil: nothing to say).
    private(set) var refusal: String?
    /// VX-308 U1: the sentence the crossing's receipt ends with (the signed-out road's); nil: none.
    @ObservationIgnored var receiptNote: String?

    @ObservationIgnored private let act: (RoadCrossingRequest) async -> RoadCrossingPress
    /// `.made` → the crossing landed (the export notice's flag); nil → she left (nothing written).
    @ObservationIgnored private let finished: (RoadCrossingPress?) -> Void

    init(
        door: RoadDoorOpen,
        act: @escaping (RoadCrossingRequest) async -> RoadCrossingPress,
        finished: @escaping (RoadCrossingPress?) -> Void
    ) {
        self.door = door
        gate = door.gate?.preselected ?? .alwaysAsk
        self.act = act
        self.finished = finished
    }

    var title: String { door.door.title }
    /// The passphrase field is a NEW passphrase typed twice (none set yet — rule 3).
    var asksNewPassphrase: Bool { door.newPassphrase }

    /// The button: every field the ask names typed, nothing running.
    func canSubmit(passphrase: String, again: String, words: String) -> Bool {
        guard !busy else { return false }
        switch door.ask {
        case .passphraseAndWords:
            let passphraseTyped = !passphrase.isEmpty && (!door.newPassphrase || !again.isEmpty)
            return passphraseTyped && !EncryptionSession.words(from: words).isEmpty
        case .passphrase:
            return !passphrase.isEmpty && (!door.newPassphrase || !again.isEmpty)
        case .oneSecret:
            return !passphrase.isEmpty || !EncryptionSession.words(from: words).isEmpty
        case .nothing:
            return true
        }
    }

    func submit(passphrase: String, again: String, words wordsText: String) async {
        guard canSubmit(passphrase: passphrase, again: again, words: wordsText) else { return }
        var typedWords: [String]?
        if door.ask.asksWords || (door.ask == .oneSecret && passphrase.isEmpty) {
            let words = EncryptionSession.words(from: wordsText)
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
        // Untrimmed on purpose (a passphrase may begin or end with a space).
        let typedPassphrase = door.ask.asksPassphrase || (door.ask == .oneSecret && !passphrase.isEmpty) ? passphrase : nil
        let typed = door.newPassphrase
            ? TypedSecrets(words: typedWords, newPassphrase: typedPassphrase)
            : TypedSecrets(passphrase: typedPassphrase, words: typedWords)
        let request = RoadCrossingRequest(
            door: door.door, shown: door, typed: typed, gate: door.gate == nil ? .alwaysAsk : gate, receiptNote: receiptNote)
        busy = true
        refusal = nil
        let press = await act(request)
        busy = false
        switch press {
        case .made:
            finished(press)
        case .refused(let sentence):
            refusal = sentence
        case .changed(let fresh):
            door = fresh
            if fresh.gate?.touchIDAvailable == false { gate = .alwaysAsk }
            refusal = ProtectionWords.crossingDoorChanged
        }
    }

    /// The confirm's way out — nothing written.
    func cancel() {
        guard !busy else { return }
        finished(nil)
    }
}

// MARK: - The crossings on the open library (the bootstrap's)

@MainActor
@Observable
final class RoadCrossingsModel {
    /// The doors as `assess` last said them (nil until read, or with no library open on the new road).
    private(set) var faces: RoadCrossingFaces?
    /// The one confirm in flight — VX-308 U1 (VX-239/VX-243): held by THE ONE PRESENTER (the bootstrap's, shared with the
    /// account's doors), never here; read through it so a crossing's confirm and an account sheet can never both stand.
    var confirm: RoadCrossingConfirmModel? {
        if case .crossing(let model)? = presenter.sheet { return model }
        return nil
    }
    /// RULE 11's one notice — owed after an entry turned the scheduled export off; standing until OK or reversed. Its
    /// truth is the road's durable mark (re-read at each refresh — MAJOR-1), never this process's memory alone.
    private(set) var exportNotice = false
    /// The reversal failed — said under the notice.
    private(set) var exportNoticeMessage: String?
    /// The gate-style row: Touch ID asked for, waiting on the passphrase.
    private(set) var gateAsksPassphrase = false
    private(set) var gateBusy = false
    private(set) var gateRefusal: String?
    /// VX-309 U1c — VX-451: the idle dial's press running, or why it did nothing.
    private(set) var idleBusy = false
    private(set) var idleRefusal: String?

    @ObservationIgnored let roads: RoadCrossingRoads
    /// VX-308 U1 — the one presenter the confirm is presented through (the bootstrap's; a pin's own when none is given).
    @ObservationIgnored let presenter: ProtectionSheetPresenter
    /// Each re-read's number, and the newest that LANDED (an older read never lands over a newer one).
    @ObservationIgnored private var reads = 0
    @ObservationIgnored private var landed = 0

    init(roads: RoadCrossingRoads, presenter: ProtectionSheetPresenter = ProtectionSheetPresenter()) {
        self.roads = roads
        self.presenter = presenter
    }

    func refresh() async {
        let read = beginRead()
        await land(await roads.read(), read: read)
    }

    /// VX-308 ladder round 1 (MINOR-2): a read's number, taken BEFORE the read starts — the pane's one read for its three
    /// sections (`ProtectionPaneRefresh`) takes one here and lands its faces through `land`, by the same rule.
    func beginRead() -> Int {
        reads += 1
        return reads
    }

    /// Read `read`'s faces land (rule 11's notice re-read beside them).
    func land(_ fresh: RoadCrossingFaces?, read: Int) async {
        let owed = await roads.exportNoticeOwed()
        // A read LANDS unless a NEWER read has already landed: an older slow read never writes over a newer one, and an
        // awaited refresh always leaves the model at least as fresh as its own read. (The rule was "only the newest
        // STARTED read lands": a caller awaiting `refresh()` while the confirm's own refresh — started later — was still
        // in flight got back a model still on its pre-crossing faces and notice; the fix leg's Mac red.)
        guard read > landed else { return }
        landed = read
        faces = fresh
        exportNotice = owed
        if !owed { exportNoticeMessage = nil }
    }

    /// A door's press on the pane: its confirm, from the door as last read, presented on `host` through the one presenter
    /// (nothing while another protection sheet stands).
    func open(_ door: RoadCrossingDoor, on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, let open = faces?.face(door).openDoor else { return }
        presenter.present(.crossing(makeConfirm(open)), on: host)
    }

    /// A door's confirm (the one shape — VX-307 U2a's, unchanged): its close frees the presenter; a landed crossing owes
    /// rule 11's notice when the export turned off; the doors are re-read.
    private func makeConfirm(_ open: RoadDoorOpen, receiptNote: String? = nil) -> RoadCrossingConfirmModel {
        let roads = roads
        let presenter = presenter
        var id: UUID?
        let confirm = RoadCrossingConfirmModel(
            door: open, act: { request in await roads.cross(request) },
            finished: { [weak self] press in
                if let id { presenter.dismiss(id) }
                guard let self else { return }
                if case .made(let exportTurnedOff)? = press, exportTurnedOff {
                    self.exportNotice = true
                    self.exportNoticeMessage = nil
                }
                Task { await self.refresh() }
            })
        confirm.receiptNote = receiptNote
        id = confirm.id
        return confirm
    }

    /// VX-308 U1 (VX-264, R-1 as amended) — USE CASTLE WHILE SIGNED OUT: the signed-out screen on `host`. *Continue* runs
    /// This Mac Only (the leave), re-reads the doors, and hands the floor to Use Castle's own confirm on the now-local
    /// library (its receipt ending with `bornCastleNote`); a leave refused says so in the screen; *Cancel* writes nothing.
    func openSignedOutRoad(on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, faces?.useCastle == .signedOutRoad else { return }
        let roads = roads
        let presenter = presenter
        var id: UUID?
        let screen = RoadSignedOutCastleModel(leave: { await roads.leaveForThisMacOnly() }) { [weak self] left in
            guard let id else { return }
            guard left, let self else {
                presenter.dismiss(id)
                return
            }
            Task {
                await self.refresh()
                guard let open = self.faces?.useCastle.openDoor else {
                    // The library is no longer where Use Castle opens (it changed again meanwhile): the screen goes; the
                    // pane shows the doors as they stand.
                    presenter.dismiss(id)
                    return
                }
                presenter.replace(id, with: .crossing(self.makeConfirm(open, receiptNote: ProtectionWords.bornCastleNote)))
            }
        }
        id = screen.id
        presenter.present(.signedOutCastle(screen), on: host)
    }

    /// The sheet's dismissal (a window closed under it) — the same as Cancel; a running press keeps its confirm.
    func dismissConfirm() {
        confirm?.cancel()
    }

    // MARK: - Rule 11's notice

    func exportNoticeOK() {
        roads.dismissExportNotice()
        exportNotice = false
        exportNoticeMessage = nil
    }

    func turnExportBackOn() async {
        guard exportNotice else { return }
        if await roads.turnExportBackOn() {
            exportNotice = false
            exportNoticeMessage = nil
        } else {
            exportNoticeMessage = ProtectionWords.exportTurnBackOnFailed
        }
    }

    // MARK: - The gate-style row (Castle)

    func useAlwaysAsk() async {
        guard !gateBusy else { return }
        gateAsksPassphrase = false
        await changeGate(.alwaysAsk, passphrase: nil)
    }

    /// *Use Touch ID…* — the passphrase is asked first (§3.10: Touch ID comes on only with it).
    func beginTouchID() {
        guard !gateBusy else { return }
        gateRefusal = nil
        gateAsksPassphrase = true
    }

    func cancelTouchID() {
        guard !gateBusy else { return }
        gateAsksPassphrase = false
        gateRefusal = nil
    }

    func useTouchID(passphrase: String) async {
        guard gateAsksPassphrase, !gateBusy, !passphrase.isEmpty else { return }
        await changeGate(.touchID, passphrase: passphrase)
    }

    // MARK: - VX-309 U1c — VX-451: the idle dial and Lock Now (Castle only — where the gate-style row stands)

    /// The dial: this Mac's sealed minutes (nil = never) — a write through `changeSettings`, then the doors re-read (the row
    /// says the value now sealed). Weakening is hers to choose here (the design's §3.2: a device setting, sealed — never
    /// asked twice).
    func setIdleMinutes(_ minutes: Int?) async {
        guard !idleBusy, faces?.gateRow != nil, faces?.gateRow?.idleMinutes != minutes else { return }
        idleBusy = true
        idleRefusal = nil
        let outcome = await roads.changeIdleLock(minutes)
        idleBusy = false
        switch outcome {
        case .changed: await refresh()
        case .refused(let sentence): idleRefusal = sentence
        }
    }

    /// *Lock Library Now* — the one lock (the bootstrap's; it lands in the open road's own lobby, the Settings window
    /// closing as the library closes — VX-224).
    func lockNow() async {
        guard faces?.gateRow != nil else { return }
        await roads.lockNow()
    }

    private func changeGate(_ gate: GateStyle, passphrase: String?) async {
        gateBusy = true
        gateRefusal = nil
        let outcome = await roads.changeGate(gate, passphrase)
        gateBusy = false
        switch outcome {
        case .changed:
            gateAsksPassphrase = false
            await refresh()
        case .refused(let sentence):
            gateRefusal = sentence
        }
    }
}
