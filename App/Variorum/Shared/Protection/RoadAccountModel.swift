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

    @ObservationIgnored private let act: (RoadAccountRequest) async -> RoadAccountPress
    /// `.made` → the act landed; nil → she left (nothing written).
    @ObservationIgnored private let finished: (RoadAccountPress?) -> Void

    init(
        door: RoadAccountDoorOpen, act: @escaping (RoadAccountRequest) async -> RoadAccountPress,
        finished: @escaping (RoadAccountPress?) -> Void
    ) {
        self.door = door
        self.act = act
        self.finished = finished
    }

    var title: String { door.door.title }
    var button: String { door.door.button }
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

    func submit(passphrase: String = "", again: String = "", words wordsText: String = "") async {
        guard canSubmit(passphrase: passphrase, again: again, words: wordsText) else { return }
        var typedWords: [String]?
        if door.ask.asksWords {
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
        var typed = TypedSecrets.none
        if door.ask.asksPassphrase || door.ask.asksWords {
            // Untrimmed on purpose (a passphrase may begin or end with a space).
            let typedPassphrase = door.ask.asksPassphrase ? passphrase : nil
            typed = door.newPassphrase
                ? TypedSecrets(words: typedWords, newPassphrase: typedPassphrase)
                : TypedSecrets(passphrase: typedPassphrase, words: typedWords)
        }
        busy = true
        refusal = nil
        let press = await act(RoadAccountRequest(door: door.door, shown: door, typed: typed))
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

    @ObservationIgnored let roads: RoadAccountRoads
    @ObservationIgnored let presenter: ProtectionSheetPresenter
    /// The composition root's — the app's sign-out (its own session; rule 16: signing out never changes the record). nil:
    /// *Sign out…* is not rendered (P-2).
    @ObservationIgnored var signOutRoad: (@MainActor () async -> Void)?
    @ObservationIgnored private var reads = 0
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
        reads += 1
        let read = reads
        let fresh = await roads.read()
        guard read > landedRead else { return }
        landedRead = read
        faces = fresh
    }

    /// A door's press on the pane: its confirm, from the door as last read, on `host`.
    func open(_ door: RoadAccountDoor, on host: ProtectionSheetHost = .settings) {
        guard presenter.sheet == nil, let open = faces?.face(door).openDoor else { return }
        let roads = roads
        let presenter = presenter
        var id: UUID?
        let confirm = RoadAccountConfirmModel(
            door: open, act: { request in await roads.press(request) },
            finished: { [weak self] press in
                if let id { presenter.dismiss(id) }
                guard let self else { return }
                if case .made(let receipt)? = press { roads.receipt(receipt) }
                Task {
                    await self.refresh()
                    if press != nil { await roads.landed() }
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
