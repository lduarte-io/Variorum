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
            door: door.door, shown: door, typed: typed, gate: door.gate == nil ? .alwaysAsk : gate)
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
    /// The one confirm in flight.
    private(set) var confirm: RoadCrossingConfirmModel?
    /// RULE 11's one notice — owed after an entry turned the scheduled export off; standing until OK or reversed.
    private(set) var exportNotice = false
    /// The reversal failed — said under the notice.
    private(set) var exportNoticeMessage: String?
    /// The gate-style row: Touch ID asked for, waiting on the passphrase.
    private(set) var gateAsksPassphrase = false
    private(set) var gateBusy = false
    private(set) var gateRefusal: String?

    @ObservationIgnored let roads: RoadCrossingRoads
    /// Each re-read's number: only the newest lands.
    @ObservationIgnored private var reads = 0

    init(roads: RoadCrossingRoads) {
        self.roads = roads
    }

    func refresh() async {
        reads += 1
        let read = reads
        let fresh = await roads.read()
        guard read == reads else { return }
        faces = fresh
    }

    /// A door's press on the pane: its confirm, from the door as last read.
    func open(_ door: RoadCrossingDoor) {
        guard confirm == nil, let open = faces?.face(door).openDoor else { return }
        let roads = roads
        confirm = RoadCrossingConfirmModel(
            door: open, act: { request in await roads.cross(request) },
            finished: { [weak self] press in
                guard let self else { return }
                self.confirm = nil
                if case .made(let exportTurnedOff)? = press, exportTurnedOff {
                    self.exportNotice = true
                    self.exportNoticeMessage = nil
                }
                Task { await self.refresh() }
            })
    }

    /// The sheet's dismissal (a window closed under it) — the same as Cancel; a running press keeps its confirm.
    func dismissConfirm() {
        confirm?.cancel()
    }

    // MARK: - Rule 11's notice

    func exportNoticeOK() {
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
