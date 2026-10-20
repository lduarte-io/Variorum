//
//  SetPassphraseModel.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U2 — THE SET-PASSPHRASE SHEET's brain (rule 3: "Every library is asked for a passphrase"; §7c (7);
//  P-VX306-U2-0 (a), the orchestrator's provisional ruling: the reset door's Standard road, `resetPassphrase(_:
//  authorization: .plainConfirm, new:)` — this Mac holds the key, so nothing else is asked). A new passphrase typed
//  twice; REFUSED when a passphrase already exists (the sheet sets the first one only — a change is VX-308's key
//  door); on success the host closes and §7c (7)'s receipt is spoken. The act is an injected road (the bootstrap's,
//  through the session's executor off the main actor; a test's, planted). Never trimmed: a passphrase may begin or
//  end with a space.
//

import Foundation
import Observation
import VariorumCore

/// **VX-309 U2 — VX-211: THE FLOOR, ON THE NEW ROAD** (her kickoff ruling, "Floor + quiet hint"; her 17n ruling: the floor
/// "binds where a passphrase is SET and nowhere else"). ONE check every new-road setter reads — the Set a passphrase sheet, a
/// crossing's new passphrase, turning sync on with a new one, the key doors' new passphrase — with today's road's one number
/// and one sentence (`ProtectionCopy.passphraseFloor` / `.passphraseTooShort`). The ONLY refusal: the strength line beside
/// the field is advice (`hint`), never a block.
nonisolated enum NewPassphraseRule {
    /// The refusal for a passphrase being SET under the floor (nil: it may be set).
    static func floorRefusal(_ passphrase: String) -> String? {
        passphrase.count < ProtectionCopy.passphraseFloor ? ProtectionCopy.passphraseTooShort : nil
    }

    /// VX-211's quiet line beside a new passphrase field — the Domain estimator's advice in words (nil: nothing said; an
    /// empty field says nothing).
    static func hint(_ passphrase: String) -> String? {
        ProtectionWords.passphraseHint(PassphraseStrength.advice(passphrase))
    }
}

@MainActor
@Observable
final class SetPassphraseModel: Identifiable {
    let id = UUID()
    /// A passphrase exists already — the sheet refuses at once and the button stays off.
    let alreadySet: Bool
    private(set) var busy = false
    /// Why nothing happened (nil: nothing to say).
    private(set) var refusal: String?

    @ObservationIgnored private let setRoad: (String) async -> SetPassphraseOutcome
    /// true: the passphrase was set; false: the sheet was left (nothing written).
    @ObservationIgnored private let finished: (Bool) -> Void

    init(
        alreadySet: Bool,
        setRoad: @escaping (String) async -> SetPassphraseOutcome,
        finished: @escaping (Bool) -> Void
    ) {
        self.alreadySet = alreadySet
        self.setRoad = setRoad
        self.finished = finished
        refusal = alreadySet ? ProtectionWords.setPassphraseAlreadySet : nil
    }

    /// The button: both fields typed, nothing running, no passphrase yet.
    func canSubmit(passphrase: String, again: String) -> Bool {
        !alreadySet && !busy && !passphrase.isEmpty && !again.isEmpty
    }

    func submit(passphrase: String, again: String) async {
        guard !alreadySet else {
            refusal = ProtectionWords.setPassphraseAlreadySet
            return
        }
        guard canSubmit(passphrase: passphrase, again: again) else { return }
        // VX-309 U2 — VX-211: the floor, today's order (the floor, then the match).
        if let floor = NewPassphraseRule.floorRefusal(passphrase) {
            refusal = floor
            return
        }
        guard passphrase == again else {
            refusal = ProtectionWords.setPassphraseMismatch
            return
        }
        busy = true
        refusal = nil
        let outcome = await setRoad(passphrase)
        busy = false
        switch outcome {
        case .set:
            finished(true)
        case .alreadySet:
            refusal = ProtectionWords.setPassphraseAlreadySet
        case .busy, .failed:
            refusal = ProtectionWords.setPassphraseFailed
        }
    }

    /// The sheet's way out — nothing written.
    func cancel() {
        guard !busy else { return }
        finished(false)
    }
}
