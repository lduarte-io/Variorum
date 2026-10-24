//
//  RoadKeyDoorsModel.swift
//  Variorum (shared: Mac + Mobile — the phone's key doors are later; the brain is one)
//
//  VX-308 U3 piece 5 — THE KEY DOORS' BRAIN on the new road (`notes/plans/vx-308-accounts-key-doors.md` §5c). Every act is
//  an injected road (the bootstrap's — the pane's one read, the press on the open session; a test's, planted), so the
//  models run with no keychain, no disk and no window. Every sheet is presented through THE ONE PRESENTER
//  (`ProtectionSheetPresenter` — U1's R-6), shared with the crossings and the account section: one protection sheet at a
//  time, none re-presented after an unlock.
//
//    - `RoadKeyDoorsModel` — OWNED BY THE BOOTSTRAP beside the crossings and the account section (made once, handed to
//      each open library's faces): the faces as `assess` last said them (`refresh` — at each appearance of the pane and
//      after an act), each passphrase door's confirm, the landed act's receipt spoken ONCE.
//    - `RoadKeyDoorConfirmModel` — one passphrase door's confirm: Change (the current passphrase, a new one typed twice);
//      Reset (a new one typed twice, and — Castle — the twelve words or Touch ID). The words are checked for shape before
//      the road is asked anything; the road re-reads the door (VX-108) — a door that changed is RE-SHOWN, never acted on.
//    New Words has no confirm: its door is the Settings words section's look (U2b's `WordsLookModel`), the faces only
//    saying whether it stands and its refusal in its place.
//    - VX-510 D-B7 — `RoadSecretCheckModel`: the READ-ONLY CHECK's sheet (VX-513 — "Check my passphrase or twelve words…"),
//      its door `offersCheck` / `openCheck` beside the key doors, its road `RoadKeyDoorRoads.check`
//      (`ProtectionSecretCheck`). It writes nothing.
//

import Foundation
import Observation
import VariorumCore

/// The key doors' roads (the bootstrap's on the new road; a test's, planted).
struct RoadKeyDoorRoads {
    /// The doors now (a READ — the pane's one read). nil: no library open on the new road, or its facts unreadable.
    var read: @MainActor () async -> RoadKeyDoorFaces?
    /// The press — the re-read, then the act on the open session.
    var press: @MainActor (RoadKeyDoorRequest) async -> RoadKeyDoorPress
    /// The status seam's receipt line (`receipt_style` governs it).
    var receipt: @MainActor (String) -> Void = { _ in }
    /// An act landed: the rest of the pane re-reads (rule 3's set row, the words section).
    var landed: @MainActor () async -> Void = {}
    /// VX-510 D-B7 — VX-513: THE READ-ONLY CHECK on the open library (`ProtectionSecretCheck.check` — the bootstrap's, off the
    /// main actor; a test's, planted). nil: no check road here — its door is not rendered (P-2).
    var check: (@MainActor (String) async -> SecretCheckOutcome)? = nil
}

// MARK: - VX-510 D-B7 — the read-only check's sheet

/// **VX-513 — "Check my passphrase or twelve words…"** (D-B7, her R-510-15): ONE concealed field (the shared field with its
/// reveal eye — VX-463), its text checked through the check road, read as Look inside reads it; the sheet says what the
/// check said (`SecretCheckOutcome.lines`). It writes nothing and keeps nothing: the typed text lives in the sheet's field
/// alone (never in this model), and what was said is dropped the moment the field changes (unit C's W-10: a line left
/// standing beside a retyped field is a line about something no longer typed) — a check still running when it changes lands
/// nothing. Close is always open (nothing to cancel — the check reads only).
@MainActor
@Observable
final class RoadSecretCheckModel: Identifiable {
    let id = UUID()
    private(set) var busy = false
    /// What the last check said (nil: nothing checked yet, or the field changed since).
    private(set) var outcome: SecretCheckOutcome?

    @ObservationIgnored private let check: (String) async -> SecretCheckOutcome
    @ObservationIgnored private let finished: () -> Void
    /// Bumped by every check and every edit: a check's answer lands only while it is still the newest thing.
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private(set) var closed = false

    init(check: @escaping (String) async -> SecretCheckOutcome, finished: @escaping () -> Void) {
        self.check = check
        self.finished = finished
    }

    /// The main button: something typed, no check running, the sheet still up.
    func canSubmit(_ typed: String) -> Bool { !busy && !closed && !typed.isEmpty }

    /// The check — untrimmed (a passphrase may begin or end with a space); the answer said unless the field changed (or the
    /// sheet closed) while it ran.
    func submit(_ typed: String) async {
        guard canSubmit(typed) else { return }
        busy = true
        outcome = nil
        generation += 1
        let mine = generation
        let said = await check(typed)
        busy = false
        guard !closed, mine == generation else { return }
        outcome = said
    }

    /// The field changed: what was said no longer describes what is typed.
    func edited() {
        generation += 1
        outcome = nil
    }

    /// *Close* — the sheet goes; what was said goes with it.
    func close() {
        guard !closed else { return }
        closed = true
        generation += 1
        outcome = nil
        finished()
    }

    /// The host's dismissal is Close (a check reads only — nothing to keep the sheet up for).
    func cancel() { close() }
}

// MARK: - One passphrase door's confirm

@MainActor
@Observable
final class RoadKeyDoorConfirmModel: Identifiable {
    let id = UUID()
    /// The door as shown (replaced when the press found it changed).
    private(set) var door: RoadKeyDoorOpen
    private(set) var busy = false
    /// Why the press did nothing (nil: nothing to say).
    private(set) var refusal: String?

    @ObservationIgnored private let act: (RoadKeyDoorRequest) async -> RoadKeyDoorPress
    /// `.made` → the act landed; nil → she left (nothing written).
    @ObservationIgnored private let finished: (RoadKeyDoorPress?) -> Void

    init(
        door: RoadKeyDoorOpen, act: @escaping (RoadKeyDoorRequest) async -> RoadKeyDoorPress,
        finished: @escaping (RoadKeyDoorPress?) -> Void
    ) {
        self.door = door
        self.act = act
        self.finished = finished
    }

    var title: String { door.door.title }
    /// Change asks the current passphrase.
    var asksCurrent: Bool { door.door == .changePassphrase }
    /// Castle's forgot road: the twelve words field.
    var asksWords: Bool {
        if case .wordsOrTouchID? = door.reset { return true }
        return false
    }
    /// Castle's forgot road with this Mac's Touch ID item: the second button.
    var offersTouchID: Bool { door.reset == .wordsOrTouchID(touchID: true) }

    /// The main button: every field the door names typed (the words road at Castle's reset), nothing running.
    func canSubmit(current: String, new: String, again: String, words: String) -> Bool {
        guard !busy, !new.isEmpty, !again.isEmpty else { return false }
        if asksCurrent, current.isEmpty { return false }
        if asksWords, WordsInput.words(from: words).isEmpty { return false }
        return true
    }

    /// Castle's Touch ID button: the new passphrase typed twice, nothing running.
    func canSubmitWithTouchID(new: String, again: String) -> Bool {
        offersTouchID && !busy && !new.isEmpty && !again.isEmpty
    }

    func submit(current: String = "", new: String, again: String, words wordsText: String = "") async {
        guard canSubmit(current: current, new: new, again: again, words: wordsText) else { return }
        var typedWords: [String]?
        if asksWords {
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
        // VX-309 U2 — VX-211: the NEW passphrase meets the floor (the current one never — it already opens the library).
        if let floor = NewPassphraseRule.floorRefusal(new) {
            refusal = floor
            return
        }
        guard new == again else {
            refusal = ProtectionWords.setPassphraseMismatch
            return
        }
        // Untrimmed on purpose (a passphrase may begin or end with a space).
        await run(RoadKeyDoorRequest(
            door: door.door, shown: door, current: asksCurrent ? current : nil, new: new, words: typedWords))
    }

    /// Castle's forgot road by Touch ID (the press is the road's — a read of this Mac's item, which prompts).
    func submitWithTouchID(new: String, again: String) async {
        guard canSubmitWithTouchID(new: new, again: again) else { return }
        if let floor = NewPassphraseRule.floorRefusal(new) {
            refusal = floor
            return
        }
        guard new == again else {
            refusal = ProtectionWords.setPassphraseMismatch
            return
        }
        await run(RoadKeyDoorRequest(door: door.door, shown: door, new: new, touchID: true))
    }

    private func run(_ request: RoadKeyDoorRequest) async {
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
            refusal = ProtectionWords.crossingDoorChanged
        }
    }

    /// The confirm's way out — nothing written.
    func cancel() {
        guard !busy else { return }
        finished(nil)
    }
}

// MARK: - The key doors on the open library (the bootstrap's)

@MainActor
@Observable
final class RoadKeyDoorsModel {
    /// The faces as `assess` last said them (nil until read, or with no library open on the new road).
    private(set) var faces: RoadKeyDoorFaces?

    @ObservationIgnored let roads: RoadKeyDoorRoads
    @ObservationIgnored let presenter: ProtectionSheetPresenter
    @ObservationIgnored private var reads = 0
    @ObservationIgnored private var landedRead = 0

    init(roads: RoadKeyDoorRoads, presenter: ProtectionSheetPresenter = ProtectionSheetPresenter()) {
        self.roads = roads
        self.presenter = presenter
    }

    /// The door confirm standing (through the presenter).
    var confirm: RoadKeyDoorConfirmModel? {
        if case .keyDoor(let model)? = presenter.sheet { return model }
        return nil
    }

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

    /// Read `read`'s faces land unless a NEWER read already landed.
    func land(_ fresh: RoadKeyDoorFaces?, read: Int) {
        guard read > landedRead else { return }
        landedRead = read
        faces = fresh
    }

    /// A passphrase door's press on the pane: its confirm, from the door as last read, on `host` (nothing while another
    /// protection sheet stands; New Words has no confirm — its door is the look).
    func open(_ door: RoadKeyDoor, on host: ProtectionSheetHost = .settings) {
        guard door != .newWords, presenter.sheet == nil, let open = faces?.face(door).openDoor else { return }
        let roads = roads
        let presenter = presenter
        var id: UUID?
        let confirm = RoadKeyDoorConfirmModel(
            door: open, act: { request in await roads.press(request) },
            finished: { [weak self] press in
                if let id { presenter.dismiss(id) }
                if case .made(let receipt)? = press { roads.receipt(receipt) }
                Task {
                    await self?.refresh()
                    if press != nil { await roads.landed() }
                }
            })
        id = confirm.id
        presenter.present(.keyDoor(confirm), on: host)
    }

    // MARK: VX-510 D-B7 — VX-513, the read-only check's door

    /// The door stands: the pane's read says the live key file of the open key is beside the library, and a check road
    /// exists (P-2 — a door that cannot act is not rendered; no library open → no faces → no door).
    var offersCheck: Bool { roads.check != nil && faces?.checkStands == true }

    /// The check's sheet standing (through the presenter).
    var checkSheet: RoadSecretCheckModel? {
        if case .checkSecrets(let model)? = presenter.sheet { return model }
        return nil
    }

    /// The door's press: its sheet on `host` (nothing while another protection sheet stands — one at a time). Nothing is
    /// re-read when it closes: the check changed nothing.
    func openCheck(on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, offersCheck, let check = roads.check else { return }
        let presenter = presenter
        var id: UUID?
        let sheet = RoadSecretCheckModel(
            check: { typed in await check(typed) },
            finished: { if let id { presenter.dismiss(id) } })
        id = sheet.id
        presenter.present(.checkSecrets(sheet), on: host)
    }
}
