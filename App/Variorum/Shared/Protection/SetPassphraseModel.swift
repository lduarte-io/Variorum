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
