//
//  RoadAccountFaces.swift
//  Variorum (shared: Mac + Mobile — the phone's account faces are later; the brain is one)
//
//  VX-308 U1 piece 3 — THE ACCOUNT SECTION'S FACES, as PURE values read from `assess` (`notes/plans/vx-308-accounts-key-
//  doors.md` §5a and its U1 ARBITRATION; the contract `notes/CastleRules.md` rules 7, 14, 16). No rule of its own: the
//  situation is `assess`'s `AccountSituation`, each door its `DoorState` over the OPEN library's facts with the CURRENT
//  sign-in and a fresh vault read (the pane's one read — R-2), and a door that cannot act is not rendered (P-2).
//
//    - TURN ON SYNC (a local library): signed out → *Sign in to turn on sync.* and the *Sign in…* door (R-5); the
//      signed-in account has NO vault yet → the set-up confirm (rule 7's hand-up: the passphrase — a NEW one typed twice
//      where none exists — and the twelve words, typed, never made new); it HAS one → a join, U2's face (R-4 — the honest
//      not-yet line); its vault could not be read → *Variorum couldn't reach your account just now…* (decision 35).
//    - THE THREE LOCAL LEAVES (rule 16 — the arbitration's refined (b), P-VX308-U1-F1): no key, lock or secret changes and
//      nothing typed; each confirm says rule 16's sentences. ONE ROAD PER SITUATION (PROVISIONAL P-VX308-U1-2): in sync →
//      *Stop syncing here…* and *Delete the account from this Mac…* (the local leave, its one pointer naming the Account
//      sheet's Delete Account); signed out → *Use this Mac only…* (Continue / Cancel); `assess` also opens the same act
//      under the other names there, and rendering two doors for one act would be two roads where one is plain.
//    - ANOTHER ACCOUNT SIGNED IN → the situation's line once, *Move it to …* (U2's join — the not-yet line) and *Sign out…*;
//      the leaves' "another account" refusals render nothing (the line said it).
//    - *Sign out…* wherever someone is signed in; *Sign in…* wherever no one is.
//

import Foundation
import VariorumCore

/// The section's confirmable doors.
nonisolated enum RoadAccountDoor: String, CaseIterable, Sendable, Identifiable, Hashable {
    case turnOnSync
    case stopSyncingHere
    case deleteAccountHere
    case thisMacOnly

    var id: String { rawValue }

    /// The core's door.
    var door: Door {
        switch self {
        case .turnOnSync: return .turnOnSync
        case .stopSyncingHere: return .stopSyncingHere
        case .deleteAccountHere: return .deleteAccountHere
        case .thisMacOnly: return .thisMacOnly
        }
    }

    /// The core's act for a leave (nil: turning sync on, which is `setUpSync`).
    var leave: ProtectionAct? {
        switch self {
        case .turnOnSync: return nil
        case .stopSyncingHere: return .stopSyncingHere
        case .deleteAccountHere: return .deleteAccountHere
        case .thisMacOnly: return .thisMacOnly
        }
    }

    var doorLabel: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncDoor
        case .stopSyncingHere: return ProtectionWords.stopSyncingHereDoor
        case .deleteAccountHere: return ProtectionWords.deleteAccountHereDoor
        case .thisMacOnly: return ProtectionWords.thisMacOnlyDoor
        }
    }

    var title: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncTitle
        case .stopSyncingHere: return ProtectionWords.stopSyncingTitle
        case .deleteAccountHere: return ProtectionWords.deleteHereTitle
        case .thisMacOnly: return ProtectionWords.thisMacOnlyTitle
        }
    }

    /// The confirm's one button (This Mac Only keeps the familiar Continue — one road, plain).
    var button: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncButton
        case .stopSyncingHere: return ProtectionWords.stopSyncingButton
        case .deleteAccountHere: return ProtectionWords.deleteHereButton
        case .thisMacOnly: return ProtectionWords.accountContinue
        }
    }

    /// The act's receipt once it landed.
    var receipt: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncReceipt
        case .stopSyncingHere: return ProtectionWords.stopSyncingReceipt
        case .deleteAccountHere: return ProtectionWords.deleteHereReceipt
        case .thisMacOnly: return ProtectionWords.thisMacOnlyReceipt
        }
    }
}

/// An open account door's confirm, as data.
nonisolated struct RoadAccountDoorOpen: Equatable, Sendable {
    let door: RoadAccountDoor
    /// Turning sync on: both typed; a leave: nothing.
    let ask: RoadDoorAsk
    /// No passphrase yet — the door asks a NEW one, typed twice (the act sets it — rule 3).
    let newPassphrase: Bool
    /// The confirm's sentences, in order.
    let sentences: [String]
    /// The spec as `assess` gave it — the press compares the door it re-reads with this one (VX-108).
    let spec: DoorSpec
}

/// One account door as the section renders it.
nonisolated enum RoadAccountDoorFace: Equatable, Sendable {
    /// Not rendered (P-2): no act here, or another of the situation's doors carries it.
    case hidden
    /// The door can't act now — its sentence in its place.
    case refused(String)
    /// The door's face is a later unit's (U2's join) — the honest not-yet line.
    case notYet(String)
    case open(RoadAccountDoorOpen)

    var openDoor: RoadAccountDoorOpen? {
        if case .open(let open) = self { return open }
        return nil
    }
}

/// `assess`'s account situation, as the section says it.
nonisolated enum RoadAccountSituation: Equatable, Sendable {
    case localOnly
    case inSync(email: String?)
    case signedOut
    case otherAccount(signedInEmail: String?, sameEmail: Bool)
}

/// What the pane's one read found about the signed-in account's vault (decision 35).
nonisolated enum VaultReadState: Equatable, Sendable {
    /// No one is signed in — nothing asked.
    case notAsked
    /// Read now: the signed-in account has a vault, or none yet.
    case read(exists: Bool)
    /// It could not be read (offline, a refused session, a row this build can't read) — said, never guessed.
    case unreachable
}

/// The account section on the open library, read from one assessment.
nonisolated struct RoadAccountFaces: Equatable, Sendable {
    let situation: RoadAccountSituation
    let turnOnSync: RoadAccountDoorFace
    let stopSyncingHere: RoadAccountDoorFace
    let deleteAccountHere: RoadAccountDoorFace
    let thisMacOnly: RoadAccountDoorFace
    /// *Move it to …* — U2's join (the not-yet line), or hidden.
    let move: RoadAccountDoorFace
    /// *Sign out…* — someone is signed in.
    let signOut: Bool
    /// *Sign in…* — no one is (R-5: the app's Account sheet).
    let signIn: Bool
    /// Signed in to the library's account and its vault could not be read now — said once, beneath the situation.
    let vaultUnreachable: Bool

    func face(_ door: RoadAccountDoor) -> RoadAccountDoorFace {
        switch door {
        case .turnOnSync: return turnOnSync
        case .stopSyncingHere: return stopSyncingHere
        case .deleteAccountHere: return deleteAccountHere
        case .thisMacOnly: return thisMacOnly
        }
    }

    /// The faces for the open library: `facts` as the pane's one read gathered them (the current sign-in, the fresh vault
    /// reading), `assessment` = `assess(facts)`, `vault` what the read found.
    static func derive(_ facts: ProtectionFacts, _ assessment: Assessment, vault: VaultReadState) -> RoadAccountFaces? {
        guard let unlocked = facts.unlocked, let mode = assessment.mode.mode else { return nil }
        var email: String?
        if case .signedIn(_, let signedInEmail) = facts.session { email = signedInEmail }
        let signedIn = facts.session.accountID != nil
        let live = facts.catalog.liveKeyFile?.document
        let passphraseSet = unlocked.record.passphraseSet
            || (live?.fingerprint == unlocked.currentFingerprint && live?.passphrase != nil)
        let situation: RoadAccountSituation
        switch assessment.account.situation {
        case .localOnly: situation = .localOnly
        case .inSync: situation = .inSync(email: email)
        case .signedOut: situation = .signedOut
        case .otherAccount(_, _, let sameEmail): situation = .otherAccount(signedInEmail: email, sameEmail: sameEmail)
        }
        func state(_ door: RoadAccountDoor) -> DoorState { assessment.doors[door.door] ?? .refused(.nothingToDo) }
        func leaf(_ door: RoadAccountDoor) -> RoadAccountDoorFace {
            switch state(door) {
            case .open(let spec):
                return .open(RoadAccountDoorOpen(
                    door: door, ask: RoadDoorAsk.of(spec.requires), newPassphrase: false, sentences: leaveSentences(door),
                    spec: spec))
            case .refused(.followOwed):
                return .refused(ProtectionWords.doorRefusedFollowOwed)
            case .refused:
                // Not synced, no one signed in (the third leave needs the library's account signed in), another account
                // signed in (the situation's line says it once), nothing to do: not rendered.
                return .hidden
            }
        }
        var turnOnSync = RoadAccountDoorFace.hidden
        var stopSyncing = RoadAccountDoorFace.hidden, deleteHere = RoadAccountDoorFace.hidden
        var thisMacOnly = RoadAccountDoorFace.hidden, move = RoadAccountDoorFace.hidden
        switch situation {
        case .localOnly:
            switch state(.turnOnSync) {
            case .refused(.noAccountSignedIn):
                turnOnSync = .refused(ProtectionWords.accountSignInToTurnOnSync)
            case .refused:
                turnOnSync = .hidden
            case .open(let spec):
                if vault == .unreachable {
                    turnOnSync = .refused(ProtectionWords.doorRefusedNeedsVault)
                } else if spec.join == .setsUpInLibrarysMode {
                    let ask = RoadDoorAsk.of(spec.requires)
                    turnOnSync = .open(RoadAccountDoorOpen(
                        door: .turnOnSync, ask: ask, newPassphrase: ask.asksPassphrase && !passphraseSet,
                        sentences: [ProtectionWords.turnOnSyncLead, ProtectionWords.onePairAtATime,
                                    ProtectionWords.turnOnSyncPosture(mode)],
                        spec: spec))
                } else {
                    // The account already has its vault: a join (enter / leave Castle, or the same posture) — U2's.
                    turnOnSync = .notYet(ProtectionWords.joinNotYet)
                }
            }
        case .inSync:
            stopSyncing = leaf(.stopSyncingHere)
            deleteHere = leaf(.deleteAccountHere)
        case .signedOut:
            thisMacOnly = leaf(.thisMacOnly)
        case .otherAccount:
            // Move is a join (leave the record's account — rule 16 — and join the signed-in one): U2's face.
            if assessment.doors[.moveToSignedInAccount]?.isOpen == true { move = .notYet(ProtectionWords.moveNotYet) }
        }
        let signOutOpen = assessment.doors[.signOut]?.isOpen == true
        var unreachable = false
        if case .inSync = situation, vault == .unreachable { unreachable = true }
        return RoadAccountFaces(
            situation: situation, turnOnSync: turnOnSync, stopSyncingHere: stopSyncing, deleteAccountHere: deleteHere,
            thisMacOnly: thisMacOnly, move: move, signOut: signedIn && signOutOpen, signIn: !signedIn,
            vaultUnreachable: unreachable)
    }

    /// A leave's confirm: what it does here, rule 16's two sentences; the third leave's one pointer last.
    static func leaveSentences(_ door: RoadAccountDoor) -> [String] {
        let ruleSixteen = [ProtectionWords.ruleSixteen, ProtectionWords.signingBackInIsAJoin]
        switch door {
        case .turnOnSync: return []
        case .stopSyncingHere: return [ProtectionWords.stopSyncingLead] + ruleSixteen
        case .deleteAccountHere:
            return [ProtectionWords.deleteHereLead] + ruleSixteen + [ProtectionWords.deleteHerePointer]
        case .thisMacOnly: return [ProtectionWords.thisMacOnlyLead] + ruleSixteen
        }
    }

    /// What an account act's refusal says. `unfinished`: the act stopped mid-plan (its act in flight — the next open
    /// settles it, rule 20) — never "nothing changed" then.
    static func actRefusalSentence(_ error: any Error, unfinished: Bool) -> String {
        if unfinished { return ProtectionWords.accountActUnfinished }
        if error is VaultRefusal { return ProtectionWords.doorRefusedNeedsVault }
        switch error as? ExecutorRefusal {
        case .passphraseDoesNotOpen?: return ProtectionWords.passphraseDoesNotOpen
        case .wordsDoNotOpen?: return ProtectionWords.wordsDoNotOpen
        case .secretMissing?, .wordsMustBeTyped?, .secretsRequired?: return ProtectionWords.crossingSecretsMissing
        case .actInFlight?: return ProtectionWords.copyDoorBusy
        case .needsFreshVault?, .vaultOutOfReach?: return ProtectionWords.doorRefusedNeedsVault
        case .accountMoved?: return ProtectionWords.doorRefusedFollowOwed
        case .otherAccountSignedIn?: return ProtectionWords.doorRefusedOtherAccount
        case .noAccountSignedIn?: return ProtectionWords.doorRefusedNoAccount
        case .notSynced?, .nothingToDo?: return ProtectionWords.crossingDoorClosed
        default: return ProtectionWords.crossingFailed
        }
    }
}
