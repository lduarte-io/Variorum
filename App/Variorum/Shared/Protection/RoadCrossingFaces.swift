//
//  RoadCrossingFaces.swift
//  Variorum (shared: Mac + Mobile — the phone's crossing faces are later; the brain is one)
//
//  VX-307 U2a — THE CROSSINGS' FACES, as PURE values read from `assess` (`notes/plans/vx-307-castle-crossings.md`
//  §5c; the contract `notes/CastleRules.md` rules 9, 11, 12, 25 and Replace All Keys' P-VX378-U2-1). No rule of its own:
//  each door reads its `DoorState` from `assess` over the OPEN library's facts (VX-108 — never a local posture), asks
//  exactly what its `SecretRequirement` says (both typed at the crossings — P-VX378-U2-2), and says its spec's `Words`.
//
//    - A door `assess` opens → its confirm's asks, its sentences (the spec's words rendered — rule 12's leave sentence on
//      Use Standard; Use Castle's floor, its export-first line, the copies under a key this Mac can't delete NAMED
//      (rule 25), the scheduled export turning off), the gate choice at Use Castle (Touch ID where this Mac has the
//      hardware and an enrolled finger — `GateStyle`), and whether the passphrase is the CURRENT one or a NEW one (rule 3:
//      a library with none sets it at the door — nothing else "depends on it except entering Castle").
//    - A door `assess` refuses → its sentence in its place — EXCEPT the refusals that say "this is not your posture's
//      door" or "this door has no subject here" (`.wrongMode`, `.notSynced`, `.nothingToDo`, and `.locked`, which an open
//      library never meets): those render NOTHING (P-2 — a door that cannot act is not rendered; PROVISIONAL
//      P-VX307-U2a-2). Replace All Keys is therefore not rendered on a library with no account (its `.notSynced`).
//    - THE GATE-STYLE ROW (Castle only): this Mac's choice, standing, so the gate is changeable after the entry
//      (`changeSettings` — Touch ID on only with the passphrase where the hardware and a finger are here; Always ask
//      deletes the item).
//

import Foundation
import VariorumCore

/// The three crossings' doors on the open library.
nonisolated enum RoadCrossingDoor: String, CaseIterable, Sendable, Identifiable, Hashable {
    case useCastle
    case useStandard
    case replaceAllKeys

    var id: String { rawValue }

    /// The core's door.
    var door: Door {
        switch self {
        case .useCastle: return .useCastle
        case .useStandard: return .useStandard
        case .replaceAllKeys: return .replaceAllKeys
        }
    }

    /// The door's name (an ellipsis — a confirm follows).
    var doorLabel: String {
        switch self {
        case .useCastle: return ProtectionWords.useCastleDoor
        case .useStandard: return ProtectionWords.useStandardDoor
        case .replaceAllKeys: return ProtectionWords.replaceAllKeysDoor
        }
    }

    /// The confirm's title and its one button.
    var title: String {
        switch self {
        case .useCastle: return ProtectionWords.useCastleTitle
        case .useStandard: return ProtectionWords.useStandardTitle
        case .replaceAllKeys: return ProtectionWords.replaceAllKeysTitle
        }
    }

    /// The act's receipt once it landed.
    var receipt: String {
        switch self {
        case .useCastle: return ProtectionWords.enteredCastleReceipt
        case .useStandard: return ProtectionWords.leftCastleReceipt
        case .replaceAllKeys: return ProtectionWords.replacedKeysReceipt
        }
    }
}

/// What a door asks — `SecretRequirement` read into fields.
nonisolated enum RoadDoorAsk: Equatable, Sendable {
    /// Both typed (P-VX378-U2-2): the passphrase and the twelve words — the crossings' ask.
    case passphraseAndWords
    /// One secret: the passphrase or the twelve words.
    case oneSecret
    /// The current passphrase alone.
    case passphrase
    /// Nothing typed.
    case nothing

    static func of(_ requirement: SecretRequirement) -> RoadDoorAsk {
        switch requirement {
        // `wordsMayBeNew` is false at every crossing (rule 7: fresh words only at a library's own first look or the
        // new-words door) — the words are TYPED either way.
        case .passphraseAndWords: return .passphraseAndWords
        // Castle's forgot road (Touch ID or the words) is no crossing's; read as one secret if it ever reached a face.
        case .oneSecret, .touchIDOrWords: return .oneSecret
        case .currentPassphrase: return .passphrase
        case .plainConfirm, .none: return .nothing
        }
    }

    var asksPassphrase: Bool { self == .passphraseAndWords || self == .passphrase }
    var asksWords: Bool { self == .passphraseAndWords }
}

/// Use Castle's gate choice (rule 9: "Touch ID on this Mac is optional").
nonisolated struct RoadGateChoice: Equatable, Sendable {
    /// Touch ID hardware AND an enrolled finger on this Mac — else Always ask is the only choice.
    let touchIDAvailable: Bool
    /// The choice the confirm opens on: this Mac's earlier one (its section), else Touch ID where it works here, else
    /// Always ask (the design's §3.10: "starts on Touch ID where this Mac has an enrolled finger … and on Always ask
    /// otherwise").
    let preselected: GateStyle

    static func make(earlier: GateStyle?, biometry: BiometryFacts) -> RoadGateChoice {
        let available = biometry.hardware && biometry.enrolled
        var pick = earlier ?? (available ? .touchID : .alwaysAsk)
        if pick == .touchID, !available { pick = .alwaysAsk }
        return RoadGateChoice(touchIDAvailable: available, preselected: pick)
    }
}

/// An open door's confirm, as data.
nonisolated struct RoadDoorOpen: Equatable, Sendable {
    let door: RoadCrossingDoor
    let ask: RoadDoorAsk
    /// The library has no passphrase yet — the door asks a NEW one, typed twice (the executor sets it — rule 3).
    let newPassphrase: Bool
    /// The confirm's sentences, in order: the door's lead, then the spec's words rendered.
    let sentences: [String]
    /// Rule 25: the copies under a key this Mac can't delete, each named (kind and day).
    let undeletableCopies: [String]
    /// Use Castle only: Touch ID or Always ask.
    let gate: RoadGateChoice?
    /// The act runs on the account (a vault write).
    let synced: Bool
    /// The spec as `assess` gave it — the press compares the door it re-reads with this one (VX-108).
    let spec: DoorSpec
}

/// One door as the pane renders it.
nonisolated enum RoadDoorFace: Equatable, Sendable {
    /// Not rendered (P-2): not this posture's door, or no subject here.
    case hidden
    /// The door can't act now — its sentence in its place.
    case refused(String)
    case open(RoadDoorOpen)
    /// VX-308 U1 (VX-264, R-1 as amended): Use Castle while SIGNED OUT of the library's account — `assess` refuses it
    /// `.signedOutUseThisMacOnly` ("the one plain road (This Mac Only) stands in its place"), so the door renders and its
    /// press shows the signed-out screen (drafted to the current rules): *Continue* runs This Mac Only, then Use Castle's
    /// own confirm; *Cancel* writes nothing.
    case signedOutRoad

    var openDoor: RoadDoorOpen? {
        if case .open(let open) = self { return open }
        return nil
    }
}

/// The standing gate-style row (Castle only).
nonisolated struct RoadGateRow: Equatable, Sendable {
    /// This Mac's choice now (no choice yet reads as Always ask — no item exists without a press).
    let current: GateStyle
    let touchIDAvailable: Bool
    /// VX-309 U1c — VX-451: lock after time away, in minutes — THIS MAC'S SEALED setting (`DeviceSettings.idleLockMinutes`,
    /// never UserDefaults — the design's §3.2/§3.15); nil = never. The relock policy reads the same value
    /// (`RoadRelockPolicy`).
    var idleMinutes: Int? = DeviceSettings.defaultIdleLockMinutes

    /// The dial's honest set — 5 · 10 · 30 · never (`DeviceSettings`' own "Offered 5 · 10 · 30 · never"; 10 by default).
    static let idleChoices: [Int?] = [5, 10, 30, nil]
}

/// The crossings on the open library, read from one assessment.
nonisolated struct RoadCrossingFaces: Equatable, Sendable {
    /// The record's mode — the posture line.
    let mode: ProtectionMode
    let useCastle: RoadDoorFace
    let useStandard: RoadDoorFace
    let replaceAllKeys: RoadDoorFace
    /// Castle only.
    let gateRow: RoadGateRow?

    func face(_ door: RoadCrossingDoor) -> RoadDoorFace {
        switch door {
        case .useCastle: return useCastle
        case .useStandard: return useStandard
        case .replaceAllKeys: return replaceAllKeys
        }
    }

    /// VX-308 U4 — F-4 (the 13x F1 R1-M1 rule, carried onto the new road): while the RESTORE HOLD stands beside the store,
    /// the SYNCED account-wide crossings — Use Castle and Replace All Keys — say their refusal in place (P-VX307-U2a-2's
    /// idiom; the sentence names Resume Sync). Use Standard is not the gate's (today's rule's own exemption — it drives no
    /// round); a LOCAL Use Castle is not either (the hold is about sync: a local crossing writes no vault and runs no round).
    func heldForRestore() -> RoadCrossingFaces {
        func held(_ face: RoadDoorFace) -> RoadDoorFace {
            guard let open = face.openDoor, open.synced else { return face }
            return .refused(ProtectionWords.restoreHoldRefusal(open.door.title))
        }
        return RoadCrossingFaces(
            mode: mode, useCastle: held(useCastle), useStandard: useStandard, replaceAllKeys: held(replaceAllKeys),
            gateRow: gateRow)
    }

    /// The faces for the open library: `facts` as gathered (unlocked), `assessment` = `assess(facts)`; `copyName` names a
    /// catalogued copy (rule 25's list) — nil when it is no longer catalogued.
    static func derive(
        _ facts: ProtectionFacts, _ assessment: Assessment, copyName: (String) -> String?
    ) -> RoadCrossingFaces? {
        guard let unlocked = facts.unlocked, let mode = assessment.mode.mode else { return nil }
        let live = facts.catalog.liveKeyFile?.document
        let passphraseSet = unlocked.record.passphraseSet
            || (live?.fingerprint == unlocked.currentFingerprint && live?.passphrase != nil)
        let earlierGate = unlocked.thisMac.settings.gateStyle
        func face(_ door: RoadCrossingDoor) -> RoadDoorFace {
            switch assessment.doors[door.door] ?? .refused(.nothingToDo) {
            case .refused(.signedOutUseThisMacOnly) where door == .useCastle:
                // VX-308 U1: the signed-out road (Use Standard and Replace All Keys keep their sentence in place).
                return .signedOutRoad
            case .refused(let refusal):
                return refusalSentence(refusal).map(RoadDoorFace.refused) ?? .hidden
            case .open(let spec):
                return .open(open(door, spec, passphraseSet: passphraseSet, gate: earlierGate,
                                  biometry: facts.biometry, copyName: copyName))
            }
        }
        let gateRow = mode == .castle
            ? RoadGateRow(current: earlierGate ?? .alwaysAsk,
                          touchIDAvailable: facts.biometry.hardware && facts.biometry.enrolled,
                          idleMinutes: unlocked.thisMac.settings.idleLockMinutes)
            : nil
        return RoadCrossingFaces(
            mode: mode, useCastle: face(.useCastle), useStandard: face(.useStandard),
            replaceAllKeys: face(.replaceAllKeys), gateRow: gateRow)
    }

    static func open(
        _ door: RoadCrossingDoor, _ spec: DoorSpec, passphraseSet: Bool, gate: GateStyle?, biometry: BiometryFacts,
        copyName: (String) -> String?
    ) -> RoadDoorOpen {
        var sentences: [String]
        switch door {
        case .useCastle: sentences = [ProtectionWords.castlePromise, ProtectionWords.useCastleLead]
        case .useStandard: sentences = [ProtectionWords.useStandardLead]
        case .replaceAllKeys: sentences = [ProtectionWords.replaceAllKeysLead]
        }
        var copies: [String] = []
        for words in spec.words {
            switch words {
            case .copiesUnderAKeyThisMacCantDelete(let ids):
                copies = ids.compactMap(copyName)
                if !copies.isEmpty { sentences.append(ProtectionWords.copiesUnderAKeyThisMacCantDelete) }
            default:
                if let sentence = sentence(words) { sentences.append(sentence) }
            }
        }
        let ask = RoadDoorAsk.of(spec.requires)
        return RoadDoorOpen(
            door: door, ask: ask, newPassphrase: ask.asksPassphrase && !passphraseSet, sentences: sentences,
            undeletableCopies: copies,
            gate: door == .useCastle ? RoadGateChoice.make(earlier: gate, biometry: biometry) : nil,
            synced: spec.synced, spec: spec)
    }

    /// A spec's typed words, said (nil: not a crossing's — the Move door's same-email line is VX-308's face).
    static func sentence(_ words: Words) -> String? {
        switch words {
        case .ruleFive: return ProtectionWords.leaveSentence
        case .floorSentence: return ProtectionWords.castleFloor
        case .exportAPlainCopyFirst: return ProtectionWords.exportAPlainCopyFirst
        case .scheduledExportTurnsOff: return ProtectionWords.scheduledExportTurnsOff
        case .copiesUnderAKeyThisMacCantDelete: return ProtectionWords.copiesUnderAKeyThisMacCantDelete
        case .sameEmailDifferentAccount: return nil
        }
    }

    /// A door's refusal, said — nil: the door is not rendered (P-2; PROVISIONAL P-VX307-U2a-2).
    static func refusalSentence(_ refusal: DoorRefusal) -> String? {
        switch refusal {
        case .locked, .wrongMode, .notSynced, .nothingToDo: return nil
        case .otherAccountSignedIn: return ProtectionWords.doorRefusedOtherAccount
        case .signedOutUseThisMacOnly: return ProtectionWords.doorRefusedSignedOut
        case .needsFreshVault: return ProtectionWords.doorRefusedNeedsVault
        case .followOwed: return ProtectionWords.doorRefusedFollowOwed
        case .noAccountSignedIn: return ProtectionWords.doorRefusedNoAccount
        }
    }

    /// What an act's refusal says (the act refused before anything moved, or rolled back whole).
    static func actRefusalSentence(_ error: any Error) -> String {
        switch error as? ExecutorRefusal {
        case .passphraseDoesNotOpen?: return ProtectionWords.passphraseDoesNotOpen
        case .wordsDoNotOpen?: return ProtectionWords.wordsDoNotOpen
        case .secretMissing?, .wordsMustBeTyped?, .secretsRequired?: return ProtectionWords.crossingSecretsMissing
        case .passphraseChangedElsewhere(let device, let day)?:
            return ProtectionWords.passphraseChangedElsewhere(device: device, day: day.map { ProtectionWords.day($0) })
        case .actInFlight?: return ProtectionWords.copyDoorBusy
        case .needsFreshVault?, .vaultOutOfReach?: return ProtectionWords.doorRefusedNeedsVault
        case .accountMoved?: return ProtectionWords.doorRefusedFollowOwed
        case .otherAccountSignedIn?: return ProtectionWords.doorRefusedOtherAccount
        case .signedOutUseThisMacOnly?: return ProtectionWords.doorRefusedSignedOut
        case .noAccountSignedIn?: return ProtectionWords.doorRefusedNoAccount
        case .wrongMode?, .notSynced?, .nothingToDo?: return ProtectionWords.crossingDoorClosed
        default: return ProtectionWords.crossingFailed
        }
    }
}
