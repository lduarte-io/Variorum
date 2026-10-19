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
        if asksWords, EncryptionSession.words(from: words).isEmpty { return false }
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
}
