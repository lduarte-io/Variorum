//
//  RoadKeyDoorFaces.swift
//  Variorum (shared: Mac + Mobile — the phone's key doors are later; the brain is one)
//
//  VX-308 U3 piece 5 — THE KEY DOORS' FACES, as PURE values read from `assess` over THE PANE'S ONE READ (`notes/plans/
//  vx-308-accounts-key-doors.md` §5c; the contract `notes/CastleRules.md` rules 3, 6, 7; the core's three doors as built,
//  `Acts/KeyDoors.swift` — rule 7's together-change is core truth, the face only says it). No rule of its own: each door
//  is `assess`'s `DoorState` over the open library's facts with the CURRENT sign-in and a fresh vault read (U1's R-2), and a
//  door that cannot act is not rendered (P-2).
//
//    - CHANGE PASSPHRASE… — the current one verified (against the vault's copy when synced), a new one typed twice.
//    - RESET FORGOTTEN PASSPHRASE… — the forgot road (`ResetAuthorization`): Standard, the plain confirm (this Mac holds
//      the key); Castle, the twelve words — or Touch ID where this Mac has its item for the current key and a finger
//      (the press is a READ of that item: today's road's presence confirm, kept — the design's §3.9 "today's road, kept").
//      Both passphrase doors render only where a passphrase exists (*Set a passphrase…* stands in their place otherwise —
//      VX-306's sheet) and where the live key file of the key stands (they re-lock it; in rule 27's state only the new
//      words can act — VX-447).
//    - NEW WORDS — the Settings words section's door (U2b built it as rule 7's new-words door: one door, never two for
//      one act — R-U3-5), reading `.newWords` here so its refusal is said in its place.
//    Each door says VX-263's ONE line (`ProtectionWords.keyDoorsLine`); synced, the passphrase doors say the account's
//    passphrase changes with it (rule 7). Synced refusals in the pane's idiom: a follow owed (the account moved), the
//    vault out of reach, another account — `RoadCrossingFaces.refusalSentence`.
//

import Foundation
import VariorumCore

/// The three key doors on the open library.
nonisolated enum RoadKeyDoor: String, CaseIterable, Sendable, Identifiable, Hashable {
    case changePassphrase
    case newWords
    case resetForgottenPassphrase

    var id: String { rawValue }

    /// The core's door.
    var door: Door {
        switch self {
        case .changePassphrase: return .changePassphrase
        case .newWords: return .newWords
        case .resetForgottenPassphrase: return .resetForgottenPassphrase
        }
    }

    /// The door's name (an ellipsis — a confirm follows; New Words is the words section's own door).
    var doorLabel: String {
        switch self {
        case .changePassphrase: return ProtectionWords.changePassphraseDoor
        case .newWords: return ProtectionWords.wordsSectionDoor
        case .resetForgottenPassphrase: return ProtectionWords.resetPassphraseDoor
        }
    }

    var title: String {
        switch self {
        case .changePassphrase: return ProtectionWords.changePassphraseTitle
        case .newWords: return ProtectionWords.wordsSectionTitle
        case .resetForgottenPassphrase: return ProtectionWords.resetPassphraseTitle
        }
    }

    /// The act's receipt once it landed (New Words speaks through its look — no receipt of its own).
    var receipt: String? {
        switch self {
        case .changePassphrase: return ProtectionWords.changePassphraseReceipt
        case .newWords: return nil
        case .resetForgottenPassphrase: return ProtectionWords.resetPassphraseReceipt
        }
    }
}

/// The forgot road's authorization, by posture (`ResetAuthorization`).
nonisolated enum RoadResetRoad: Equatable, Sendable {
    /// Standard — a plain confirm (this Mac holds the key).
    case plainConfirm
    /// Castle — the twelve words; `touchID`: also Touch ID (this Mac has its item for the current key and a finger).
    case wordsOrTouchID(touchID: Bool)
}

/// An open key door, as data.
nonisolated struct RoadKeyDoorOpen: Equatable, Sendable {
    let door: RoadKeyDoor
    /// The door's sentences, in order: VX-263's one line; synced, the passphrase doors' rule-7 line; the forgot road's lead.
    let sentences: [String]
    /// The forgot road's authorization (Reset only).
    let reset: RoadResetRoad?
    /// The act runs on the account too (rule 7 — the vault's lock changes with the library's).
    let synced: Bool
    /// The spec as `assess` gave it — the press compares the door it re-reads with this one (VX-108).
    let spec: DoorSpec
}

/// One key door as the pane renders it.
nonisolated enum RoadKeyDoorFace: Equatable, Sendable {
    /// Not rendered (P-2): no subject here, or another door stands in its place.
    case hidden
    /// The door can't act now — its sentence in its place.
    case refused(String)
    case open(RoadKeyDoorOpen)

    var openDoor: RoadKeyDoorOpen? {
        if case .open(let open) = self { return open }
        return nil
    }
}

/// The key doors on the open library, read from one assessment.
nonisolated struct RoadKeyDoorFaces: Equatable, Sendable {
    let changePassphrase: RoadKeyDoorFace
    let newWords: RoadKeyDoorFace
    let resetForgottenPassphrase: RoadKeyDoorFace

    func face(_ door: RoadKeyDoor) -> RoadKeyDoorFace {
        switch door {
        case .changePassphrase: return changePassphrase
        case .newWords: return newWords
        case .resetForgottenPassphrase: return resetForgottenPassphrase
        }
    }

    /// The faces for the open library: `facts` as the pane's one read gathered them, `assessment` = `assess(facts)`.
    static func derive(_ facts: ProtectionFacts, _ assessment: Assessment) -> RoadKeyDoorFaces? {
        guard let unlocked = facts.unlocked, assessment.mode.mode != nil else { return nil }
        let live = facts.catalog.liveKeyFile?.document
        let keyFileStands = live?.fingerprint == unlocked.currentFingerprint
        // Rule 3's fact as the core states it NOW (R-U3-4): a passphrase lock on the live key file of the key, or the
        // account's.
        let passphraseExists = ProtectionRecord.passphraseExists(
            keyFile: keyFileStands ? live : nil, account: unlocked.record.account)
        let touchIDHere = facts.biometry.hardware && facts.biometry.enrolled
            && facts.custody.contains(CustodyItemFact(fingerprint: unlocked.currentFingerprint, itemClass: .touchid))
        func face(_ door: RoadKeyDoor) -> RoadKeyDoorFace {
            switch assessment.doors[door.door] ?? .refused(.nothingToDo) {
            case .refused(let refusal):
                return RoadCrossingFaces.refusalSentence(refusal).map(RoadKeyDoorFace.refused) ?? .hidden
            case .open(let spec):
                switch door {
                case .newWords:
                    return .open(RoadKeyDoorOpen(
                        door: door, sentences: [ProtectionWords.keyDoorsLine], reset: nil, synced: spec.synced, spec: spec))
                case .changePassphrase, .resetForgottenPassphrase:
                    // The passphrase doors re-lock a passphrase the live key file carries: none yet → *Set a
                    // passphrase…* stands in their place; no key file of the key (rule 27's state) → only new words act.
                    guard passphraseExists, keyFileStands else { return .hidden }
                    var sentences = [ProtectionWords.keyDoorsLine]
                    if spec.synced { sentences.append(ProtectionWords.keyDoorsSyncedPassphraseLine) }
                    var reset: RoadResetRoad?
                    if door == .resetForgottenPassphrase {
                        switch spec.requires {
                        case .touchIDOrWords:
                            reset = .wordsOrTouchID(touchID: touchIDHere)
                            sentences.append(touchIDHere
                                ? ProtectionWords.resetPassphraseCastleTouchIDLead : ProtectionWords.resetPassphraseCastleLead)
                        default:
                            reset = .plainConfirm
                            sentences.append(ProtectionWords.resetPassphraseStandardLead)
                        }
                    }
                    return .open(RoadKeyDoorOpen(door: door, sentences: sentences, reset: reset, synced: spec.synced, spec: spec))
                }
            }
        }
        return RoadKeyDoorFaces(
            changePassphrase: face(.changePassphrase), newWords: face(.newWords),
            resetForgottenPassphrase: face(.resetForgottenPassphrase))
    }
}
