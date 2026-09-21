//
//  AppleRelinkModel.swift
//  Variorum (shared: Mac + Mobile — the RE-LINK door's BRAIN; the Mac's
//  Settings ▸ Protection sheet renders it, and the phone composes THIS model
//  if the parity round ever gives it the door — MobileSoul §3: a capability
//  built Mac-side with its brain in app-local code is a parity defect at
//  birth. No door is rendered on the phone this run; see QUESTIONS #139.)
//
//  RUN A batch A3 — 17m, THE RE-LINK YOUR APPLE ACCOUNT DOOR (her ruling on
//  QUESTIONS #90's item 10, 2026-09-07 ~02:05: *"I think we do need a re-link
//  your apple account door. I'd maybe make it a 17 item and I'll have to run
//  that before release"*).
//
//  WHAT IT CLOSES (the ladder's MINOR-N1, option A as F3 built it): the heal
//  keys on a key READ, never a MINT — proof of a same-account duplicate is a
//  DIFFERENT id read back, and a mint proves nothing. So after an iCloud
//  Keychain RESET, or after the establishing device signs into ANOTHER Apple
//  ID, the account's Apple-held copy of the master is ORPHANED: this device
//  mints A′ for its own key file, the vault's copy stays wrapped under the
//  vanished A, and new Apple devices lose Standard's nothing-typed enroll
//  until the vault's copy is re-landed. The only road before this door was
//  the Castle → Standard round trip, which re-keys the whole account.
//
//  THE SHAPE, built from machinery that already exists — no new custody
//  semantics, no engine line, no schema:
//    1. THE DOOR REFUSES BEFORE ANY SCREEN (decision 32's pattern, applied to
//       this door exactly as F3's MINOR-N4 (1) applied it to Replace All
//       Keys): Castle, a follow owed, or an iCloud Keychain that hands back
//       NO key at all each end the door at its first phase, with nothing
//       asked and nothing written.
//    2. ONE CONSENT SCREEN naming WHICH Apple account will hold the key —
//       the only honest naming the client has, since no iCloud-account
//       identity is stored (the MAJOR-3 REFINED paragraph) — plus the key it
//       replaces, and the passphrase: the KEY ACT (§5's authorization
//       column; `KeyActPassphrase`, the ceremony's own rule).
//    3. ONE proof-authorized vault write, through the road F2 built for the
//       heal: `ProtectionController.healAppleHeldCopy` →
//       `EncryptionSession.relandAppleHeldCopy(under:)` — the master from
//       THIS device's custody, `settingAppleHeldCopy`, the CAS on the
//       fetched revision, the key proof. The door NEVER mints A
//       (`readAppleKey`, never `readOrMint`): minting here would be
//       MAJOR-3 (b)'s defect — the account's copy wrapped under a key iCloud
//       may never keep, decision 30's own prohibition.
//    4. The reconcile, which lands this key file's own copy under the read
//       key and re-reads the account, so every projection follows the disk
//       and the server it just changed.
//
//  Not this door's: minting A anywhere, rotating anything, touching another
//  device's key file, or deciding whether the Apple account is the "right"
//  one — that is what the consent sentence is for.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class AppleRelinkModel: Identifiable {
    /// What the door read at its threshold — the consent sentence's facts.
    nonisolated struct Facts: Equatable, Sendable {
        /// The iCloud key this device READS right now (never minted).
        var appleKeyID: String
        /// The key the account's copy is under, as the last reconcile read
        /// it; nil = no vault reading in hand (offline at ready, or an
        /// account whose copy was never landed).
        var recordedAppleKeyID: String?

        /// The key on file is already this Apple account's — the act still
        /// runs (it writes the same key again) and says so.
        var alreadyThisAccount: Bool { recordedAppleKeyID == appleKeyID }
    }

    enum Phase: Equatable {
        /// The door check (before any screen).
        case checking
        case consent(Facts)
        case running
        case done
        /// A refusal at the door, or a failure at the act (the sentence).
        case failed(String)
        case closed
    }

    let id = UUID()
    private(set) var phase: Phase = .checking
    private(set) var busy = false
    var lastError: String?

    private let controller: ProtectionController
    private let vaultTie: VaultTie?

    init(controller: ProtectionController, vaultTie: VaultTie?) {
        self.controller = controller
        self.vaultTie = vaultTie
    }

    /// The consent screen's sentences, from the facts it read.
    var consentSentences: [String] {
        guard case .consent(let facts) = phase else { return [] }
        var lines = [ProtectionCopy.relinkConsent(appleKeyID: facts.appleKeyID)]
        if facts.alreadyThisAccount {
            lines.append(ProtectionCopy.relinkAlreadyThisAccount)
        } else if let recorded = facts.recordedAppleKeyID {
            lines.append(ProtectionCopy.relinkReplaces(recordedKeyID: recorded))
        }
        return lines
    }

    // MARK: - The door (refuses before asking — decision 32 / MINOR-N4 (1))

    func start() async {
        guard case .checking = phase else { return }
        busy = true
        defer { busy = false }
        // Castle owes no Apple-held copy at all (§3.4's Castle table: "no
        // copy opens with it"). The pane renders this door only in Standard,
        // so this arm exists for the posture that moves under an open sheet.
        guard controller.posture == .standard else {
            phase = .failed(PostureSwitchModel.message(for: PostureSwitchError.wrongPosture(controller.posture)))
            return
        }
        // A follow is owed ⇒ this device's keys are not the account's, so its
        // proof would be refused anyway: the one sentence every key door
        // speaks instead of acting (§7's un-followed state).
        guard !controller.followPending else {
            phase = .failed(ProtectionCopy.pickUpKeysFirst)
            return
        }
        // READ, never mint (decision 30; MAJOR-3 b). No key at all ⇒ there is
        // nothing to re-link to: NIT-N8's waiting sentence, before any screen.
        guard let apple = controller.readAppleKey() else {
            phase = .failed(ProtectionCopy.relinkAppleKeyUnreadable)
            return
        }
        phase = .consent(Facts(
            appleKeyID: apple.id,
            recordedAppleKeyID: controller.vaultReading?.appleKeyID))
    }

    // MARK: - The act (the passphrase, then ONE proof-authorized vault write)

    func confirm(passphrase typed: String) async {
        guard case .consent(let facts) = phase, !busy else { return }
        lastError = nil
        guard !typed.isEmpty else {
            lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
            return
        }
        busy = true
        defer { busy = false }
        // THE KEY ACT: the vault's current copy where an account constrains
        // this library (a word retired elsewhere is refused here), else the
        // key file's — `KeyActPassphrase`, the ceremony's own rule.
        switch await KeyActPassphrase.verify(typed, against: vaultTie, orStore: controller) {
        case .verified: break
        case .refused(let message):
            lastError = message
            return
        }
        // The key is READ AGAIN at the act and must be the one the consent
        // named: consent was given for an Apple account, so a key that
        // changed under the open sheet is not a key she agreed to.
        guard let apple = controller.readAppleKey() else {
            phase = .failed(ProtectionCopy.relinkAppleKeyUnreadable)
            return
        }
        guard apple.id == facts.appleKeyID else {
            phase = .failed(ProtectionCopy.relinkAppleKeyChanged)
            return
        }
        phase = .running
        // ONE proof-authorized write, through the heal's own road. A nil
        // closure (no session composed) and a refused write are the same
        // fact for her — nothing was written — and say so in one sentence;
        // the server's own refusal while a key replacement is still
        // finishing (VARIORUM_ROTATION_IN_PROGRESS) lands here too.
        guard let reland = controller.healAppleHeldCopy, await reland(apple) else {
            phase = .failed(ProtectionCopy.relinkWriteRefused)
            return
        }
        // The reconcile lands THIS key file's own copy under the read key and
        // re-reads the account, so the projections follow what just changed.
        await controller.reconcile()
        phase = .done
    }

    func close() {
        phase = .closed
    }
}
