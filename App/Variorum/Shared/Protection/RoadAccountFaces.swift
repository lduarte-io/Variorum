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
//      where none exists — and the twelve words, typed, never made new); it HAS one → THE JOIN (VX-308 U2 — the plan's
//      `JoinPlan` said at the consent, ONE of the account's secrets typed, the gate choice into Castle, rule 12's sentence
//      out of it); its vault could not be read → *Variorum couldn't reach your account just now…* (decision 35).
//    - THE THREE LOCAL LEAVES (rule 16 — the arbitration's refined (b), P-VX308-U1-F1): no key, lock or secret changes and
//      nothing typed; each confirm says rule 16's sentences. ONE ROAD PER SITUATION (PROVISIONAL P-VX308-U1-2): in sync →
//      *Stop syncing here…* and *Delete the account from this Mac…* (the local leave, its one pointer naming the Account
//      sheet's Delete Account); signed out → *Use this Mac only…* (Continue / Cancel); `assess` also opens the same act
//      under the other names there, and rendering two doors for one act would be two roads where one is plain.
//    - ANOTHER ACCOUNT SIGNED IN → the situation's line once, *Move this library to …* (VX-308 U2's join — rule 16's leave
//      then rule 7's adoption; with no vault on that account the honest not-yet line) and *Sign out…*; the leaves'
//      "another account" refusals render nothing (the line said it).
//    - THE FOLLOW (VX-308 U2, R-U2-1): in sync, the account moved on another device — `assess`'s `followNow` door, its
//      notice beside it (the vault's last writer and day), one secret into Castle and on a replaced key (the gate choice
//      into Castle), nothing out of it (rule 12: quietly — its sentence said).
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
    /// VX-308 U2 — Move it to the account signed in (leave the record's account — rule 16 — and join this one — rule 7).
    case moveToSignedInAccount
    /// VX-308 U2 — the follow (rules 10, 12, 15): the account changed on another device.
    case follow

    var id: String { rawValue }

    /// The core's door.
    var door: Door {
        switch self {
        case .turnOnSync: return .turnOnSync
        case .stopSyncingHere: return .stopSyncingHere
        case .deleteAccountHere: return .deleteAccountHere
        case .thisMacOnly: return .thisMacOnly
        case .moveToSignedInAccount: return .moveToSignedInAccount
        case .follow: return .followNow
        }
    }

    /// The core's act for a leave (nil: turning sync on — `setUpSync` or a join — Move, and the follow).
    var leave: ProtectionAct? {
        switch self {
        case .turnOnSync, .moveToSignedInAccount, .follow: return nil
        case .stopSyncingHere: return .stopSyncingHere
        case .deleteAccountHere: return .deleteAccountHere
        case .thisMacOnly: return .thisMacOnly
        }
    }

    /// **VX-510 D-B6 — VX-511 (R-510-14):** a landed act through this door leaves the library holding the ACCOUNT's pair —
    /// Turn on sync's set-up hands the library's pair up (rule 7; its twelve words typed at the confirm — rule 14's moment),
    /// its join and Move adopt the account's (rule 7) — so the band card's words are recorded for the library: its look would
    /// mint new words and, synced, replace the account's. The leaves change no secret (rule 16) and the follow types one
    /// secret of a pair the library already holds; neither marks. Settings ▸ New Words stays the deliberate door.
    var landingRecordsTheWords: Bool {
        switch self {
        case .turnOnSync, .moveToSignedInAccount: return true
        case .stopSyncingHere, .deleteAccountHere, .thisMacOnly, .follow: return false
        }
    }

    var doorLabel: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncDoor
        case .stopSyncingHere: return ProtectionWords.stopSyncingHereDoor
        case .deleteAccountHere: return ProtectionWords.deleteAccountHereDoor
        case .thisMacOnly: return ProtectionWords.thisMacOnlyDoor
        case .moveToSignedInAccount: return ProtectionWords.moveDoor(nil)
        case .follow: return ProtectionWords.followDoor
        }
    }

    var title: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncTitle
        case .stopSyncingHere: return ProtectionWords.stopSyncingTitle
        case .deleteAccountHere: return ProtectionWords.deleteHereTitle
        case .thisMacOnly: return ProtectionWords.thisMacOnlyTitle
        case .moveToSignedInAccount: return ProtectionWords.moveTitle
        case .follow: return ProtectionWords.followTitle
        }
    }

    /// The confirm's one button (This Mac Only keeps the familiar Continue — one road, plain).
    var button: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncButton
        case .stopSyncingHere: return ProtectionWords.stopSyncingButton
        case .deleteAccountHere: return ProtectionWords.deleteHereButton
        case .thisMacOnly: return ProtectionWords.accountContinue
        case .moveToSignedInAccount: return ProtectionWords.moveButton
        case .follow: return ProtectionWords.followButton
        }
    }

    /// The act's receipt once it landed (a join's and the follow's are their open door's — `RoadAccountDoorOpen.receipt`).
    var receipt: String {
        switch self {
        case .turnOnSync: return ProtectionWords.turnOnSyncReceipt
        case .stopSyncingHere: return ProtectionWords.stopSyncingReceipt
        case .deleteAccountHere: return ProtectionWords.deleteHereReceipt
        case .thisMacOnly: return ProtectionWords.thisMacOnlyReceipt
        case .moveToSignedInAccount: return ProtectionWords.joinedReceipt(.sameMode, moved: true)
        case .follow: return ProtectionWords.followDone(.keysReplaced)
        }
    }
}

/// An open account door's confirm, as data.
nonisolated struct RoadAccountDoorOpen: Equatable, Sendable {
    let door: RoadAccountDoor
    /// Turning sync on: both typed; a leave: nothing; a join and the follow into Castle or on a replaced key: ONE secret
    /// (rule 14); the follow out: nothing (rule 12 — quietly).
    let ask: RoadDoorAsk
    /// No passphrase yet — the door asks a NEW one, typed twice (the act sets it — rule 3).
    let newPassphrase: Bool
    /// The confirm's sentences, in order.
    let sentences: [String]
    /// The spec as `assess` gave it — the press compares the door it re-reads with this one (VX-108).
    let spec: DoorSpec
    /// VX-308 U2 — into Castle (a join that enters it, the follow into it): Touch ID or Always ask (rule 9; the follow's
    /// own default — `Follow.swift`, the design's §3.10).
    var gate: RoadGateChoice? = nil
    /// VX-308 U2 — the follow's kind (`assess`'s owed act).
    var follow: FollowKind? = nil
    /// VX-308 U2 — the line the section shows beside the door (the follow's notice); nil: the door's name alone.
    var notice: String? = nil
    /// VX-308 U2 — the door's name where it carries the account (Move names the one signed in); nil: the door's own.
    var label: String? = nil
    /// VX-308 U2 — rule 25's copies under a key this Mac can't delete, named (a join into Castle — Use Castle's line).
    var undeletableCopies: [String] = []
    /// VX-309 U2 — the account a join or Move adopts, by its email as the sign-in names it (her draft names it in the
    /// words moment); nil: not known, or not a join.
    var accountEmail: String? = nil

    /// The door's name as rendered.
    var doorLabel: String { label ?? door.doorLabel }

    /// The act re-keys the library (a join that crosses postures, every follow): it runs with the app's pool closed and
    /// reopens — the crossings' seam (R-U2-2); else on the open session.
    var rekeys: Bool { spec.rekeys }

    /// **VX-510 D-A1 + D-B0 — a first round is owed the moment this act lands** (VX-498 · VX-507): its landing changes
    /// sync's standing — turning sync on (the set-up, a join), Move, and the follow. Never a leave (sync stops there). An
    /// act on the OPEN session asks the open session's services (D-A1); a RE-KEYING act (a join or Move across postures,
    /// every follow) lands through the reopen and asks the reopen's FRESH services once they are attached (D-B0 — F-6 (A),
    /// ruled).
    var owesFirstRound: Bool {
        switch door {
        case .turnOnSync, .moveToSignedInAccount, .follow: return true
        case .stopSyncingHere, .deleteAccountHere, .thisMacOnly: return false
        }
    }

    /// VX-510 D-A2 — the act JOINS an account that already syncs (a join, Move) rather than handing the library's pair up
    /// (the set-up): the first round's success line says which.
    var joinsAnAccount: Bool {
        switch door {
        case .moveToSignedInAccount: return true
        case .turnOnSync: return spec.join.map { $0 != .setsUpInLibrarysMode } ?? false
        case .stopSyncingHere, .deleteAccountHere, .thisMacOnly, .follow: return false
        }
    }

    /// The receipt once the act landed: the follow's Done (VX-107 — its other-device sentence), a join's (the posture said
    /// where it changed), else the door's.
    var receipt: String {
        if let follow { return ProtectionWords.followDone(follow) }
        switch door {
        case .turnOnSync:
            guard let join = spec.join, join != .setsUpInLibrarysMode else { return door.receipt }
            return ProtectionWords.joinedReceipt(join, moved: false)
        case .moveToSignedInAccount:
            return ProtectionWords.joinedReceipt(spec.join ?? .sameMode, moved: true)
        default:
            return door.receipt
        }
    }
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
    /// *Move this library to …* — the join into the account signed in (VX-308 U2), its not-yet line where that account
    /// has no vault, or hidden.
    let move: RoadAccountDoorFace
    /// *Sign out…* — someone is signed in.
    let signOut: Bool
    /// *Sign in…* — no one is (R-5: the app's Account sheet).
    let signIn: Bool
    /// Signed in to the library's account and its vault could not be read now — said once, beneath the situation.
    let vaultUnreachable: Bool
    /// VX-308 U2 — the follow owed (`assess`'s `followNow`), its notice beside the door; hidden when none is.
    var follow: RoadAccountDoorFace = .hidden

    func face(_ door: RoadAccountDoor) -> RoadAccountDoorFace {
        switch door {
        case .turnOnSync: return turnOnSync
        case .stopSyncingHere: return stopSyncingHere
        case .deleteAccountHere: return deleteAccountHere
        case .thisMacOnly: return thisMacOnly
        case .moveToSignedInAccount: return move
        case .follow: return follow
        }
    }

    /// The faces for the open library: `facts` as the pane's one read gathered them (the current sign-in, the fresh vault
    /// reading), `assessment` = `assess(facts)`, `vault` what the read found; `copyName` names a catalogued copy (rule 25's
    /// list at a join into Castle — nil when it is no longer catalogued).
    static func derive(
        _ facts: ProtectionFacts, _ assessment: Assessment, vault: VaultReadState,
        copyName: (String) -> String? = { _ in nil }
    ) -> RoadAccountFaces? {
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
        var follow = RoadAccountDoorFace.hidden
        let gateChoice = RoadGateChoice.make(earlier: unlocked.thisMac.settings.gateStyle, biometry: facts.biometry)
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
                    // VX-308 U2 — the account already has its vault: THE JOIN (enter / leave Castle, or the same posture).
                    var join = joinDoor(.turnOnSync, spec, library: mode, gate: gateChoice, copyName: copyName)
                    join.accountEmail = email
                    // VX-510 D-A3 (VX-506): the account is already on — the join's door says so in its own words, never
                    // the set-up arm's "Turn on sync…" (PROVISIONAL P-VX510-3 (a), hers).
                    join.label = ProtectionWords.joinSyncDoor
                    turnOnSync = .open(join)
                }
            }
        case .inSync:
            stopSyncing = leaf(.stopSyncingHere)
            deleteHere = leaf(.deleteAccountHere)
            // VX-308 U2 — THE FOLLOW (R-U2-1): the door `assess` opens while the account moved elsewhere, its kind the
            // owed act's, its notice naming the vault's last writer and day as this read found them.
            if case .open(let spec) = state(.follow),
               let kind = assessment.acts.lazy.compactMap({ act -> FollowKind? in
                   if case .follow(let kind, _) = act { return kind }
                   return nil
               }).first {
                follow = .open(followDoor(
                    kind, spec, vault: facts.vault, exportOn: unlocked.thisMac.settings.scheduledExport, gate: gateChoice))
            }
        case .signedOut:
            thisMacOnly = leaf(.thisMacOnly)
        case .otherAccount:
            // VX-308 U2 — Move is a join (leave the record's account — rule 16 — and join the signed-in one). The core's
            // `move` joins an account that ALREADY syncs: with no vault there the honest not-yet line (P-VX308-U2-6).
            if case .open(let spec) = state(.moveToSignedInAccount) {
                switch vault {
                case .read(exists: true):
                    var open = joinDoor(.moveToSignedInAccount, spec, library: mode, gate: gateChoice, copyName: copyName)
                    open.label = ProtectionWords.moveDoor(email)
                    open.accountEmail = email
                    move = .open(open)
                case .unreachable:
                    move = .refused(ProtectionWords.doorRefusedNeedsVault)
                case .read(exists: false), .notAsked:
                    move = .notYet(ProtectionWords.moveNotYet)
                }
            }
        }
        let signOutOpen = assessment.doors[.signOut]?.isOpen == true
        var unreachable = false
        if case .inSync = situation, vault == .unreachable { unreachable = true }
        return RoadAccountFaces(
            situation: situation, turnOnSync: turnOnSync, stopSyncingHere: stopSyncing, deleteAccountHere: deleteHere,
            thisMacOnly: thisMacOnly, move: move, signOut: signedIn && signOutOpen, signIn: !signedIn,
            vaultUnreachable: unreachable, follow: follow)
    }

    /// THE JOIN's confirm (rules 7, 14; `JoinPlan` — the consent says which): Move's leave first (rule 16 — no key or
    /// secret changes for it); the join's lead (the lifecycle page's stage 12) and rule 7's first sentence; what the plan
    /// does to the posture; into Castle, Use Castle's own door words (rule 9's promise, what entering does, the spec's
    /// floor, export-first line, rule 25's copies, the export turning off) and the gate choice; out of Castle, rule 12's
    /// leave sentence (the spec's `ruleFive`). ONE of the account's secrets (rule 14).
    static func joinDoor(
        _ door: RoadAccountDoor, _ spec: DoorSpec, library: ProtectionMode, gate: RoadGateChoice,
        copyName: (String) -> String?
    ) -> RoadAccountDoorOpen {
        let plan = spec.join ?? .sameMode
        var sentences: [String] = []
        if door == .moveToSignedInAccount { sentences += [ProtectionWords.moveLead, ProtectionWords.ruleSixteen] }
        sentences += [ProtectionWords.joinLead, ProtectionWords.onePairAtATime]
        if let line = ProtectionWords.joinPlanLine(plan, library: library) { sentences.append(line) }
        if plan == .entersCastle {
            // Use Castle's own door words, VX-469 (c)'s line with them.
            sentences += [ProtectionWords.castlePromise, ProtectionWords.useCastleLead,
                          ProtectionWords.castleLeavesPreviousLibraries]
        }
        var copies: [String] = []
        for words in spec.words {
            switch words {
            case .copiesUnderAKeyThisMacCantDelete(let ids):
                copies = ids.compactMap(copyName)
                if !copies.isEmpty { sentences.append(ProtectionWords.copiesUnderAKeyThisMacCantDelete) }
            case .sameEmailDifferentAccount:
                sentences.append(ProtectionWords.accountSameEmailDifferentAccount)
            default:
                if let sentence = RoadCrossingFaces.sentence(words) { sentences.append(sentence) }
            }
        }
        return RoadAccountDoorOpen(
            door: door, ask: RoadDoorAsk.of(spec.requires), newPassphrase: false, sentences: sentences, spec: spec,
            gate: plan == .entersCastle ? gate : nil, undeletableCopies: copies)
    }

    /// THE FOLLOW's confirm (rules 10, 12, 15): its notice (the vault's last writer and day, decision 34's names); into
    /// Castle, rule 10's "said plainly" and the gate choice (the follow's own default — Touch ID where a finger is here,
    /// else Always ask); out of Castle, rule 12's leave sentence (the spec's `ruleFive`), nothing typed; what it asks;
    /// into Castle with this Mac's scheduled export on, rule 11's turning-off sentence (the follow's own `exportOff` step).
    static func followDoor(
        _ kind: FollowKind, _ spec: DoorSpec, vault: VaultReading?, exportOn: Bool, gate: RoadGateChoice
    ) -> RoadAccountDoorOpen {
        let notice = ProtectionWords.followNotice(
            kind, device: vault?.updatedByDevice, day: vault?.updatedAt.map { ProtectionWords.day($0) })
        var sentences = [notice]
        if kind == .intoCastle { sentences.append(ProtectionWords.followUntilThen) }
        for words in spec.words {
            if let sentence = RoadCrossingFaces.sentence(words) { sentences.append(sentence) }
        }
        sentences.append(ProtectionWords.followAsk(kind))
        if kind == .intoCastle, exportOn { sentences.append(ProtectionWords.scheduledExportTurnsOff) }
        return RoadAccountDoorOpen(
            door: .follow, ask: RoadDoorAsk.of(spec.requires), newPassphrase: false, sentences: sentences, spec: spec,
            gate: kind == .intoCastle ? gate : nil, follow: kind, notice: notice)
    }

    /// A leave's confirm: what it does here, rule 16's two sentences; the third leave's one pointer last.
    static func leaveSentences(_ door: RoadAccountDoor) -> [String] {
        let ruleSixteen = [ProtectionWords.ruleSixteen, ProtectionWords.signingBackInIsAJoin]
        switch door {
        case .turnOnSync, .moveToSignedInAccount, .follow: return []
        case .stopSyncingHere: return [ProtectionWords.stopSyncingLead] + ruleSixteen
        case .deleteAccountHere:
            return [ProtectionWords.deleteHereLead] + ruleSixteen + [ProtectionWords.deleteHerePointer]
        case .thisMacOnly: return [ProtectionWords.thisMacOnlyLead] + ruleSixteen
        }
    }

    /// What an account act's refusal says. `unfinished`: the act stopped mid-plan (its act in flight — the next open
    /// settles it, rule 20) — never "nothing changed" then. `secretIsTheAccounts` (VX-464 — the join's and Move's,
    /// `ProtectionAccountRoad.typesTheAccountsSecret`): a secret that opens nothing is the ACCOUNT's, and is said so.
    static func actRefusalSentence(_ error: any Error, unfinished: Bool, secretIsTheAccounts: Bool = false) -> String {
        if unfinished { return ProtectionWords.accountActUnfinished }
        if error is VaultRefusal { return ProtectionWords.doorRefusedNeedsVault }
        switch error as? ExecutorRefusal {
        case .passphraseDoesNotOpen?:
            return secretIsTheAccounts ? ProtectionWords.passphraseDoesNotOpenAccount : ProtectionWords.passphraseDoesNotOpen
        case .wordsDoNotOpen?:
            return secretIsTheAccounts ? ProtectionWords.wordsDoNotOpenAccount : ProtectionWords.wordsDoNotOpen
        case .secretMissing?, .wordsMustBeTyped?, .secretsRequired?: return ProtectionWords.crossingSecretsMissing
        // VX-113 — her #205 ruling (ii): the old passphrase after a change elsewhere names the change (the device and the
        // day the vault's row says — the wire's `updated_at`, `AccountVaultClient.day`).
        case .passphraseChangedElsewhere(let device, let day)?:
            return ProtectionWords.passphraseChangedElsewhere(device: device, day: day.map { ProtectionWords.day($0) })
        case .actInFlight?: return ProtectionWords.copyDoorBusy
        case .needsFreshVault?, .vaultOutOfReach?: return ProtectionWords.doorRefusedNeedsVault
        case .accountMoved?: return ProtectionWords.doorRefusedFollowOwed
        case .otherAccountSignedIn?: return ProtectionWords.doorRefusedOtherAccount
        case .signedOutUseThisMacOnly?: return ProtectionWords.doorRefusedSignedOut
        case .noAccountSignedIn?: return ProtectionWords.doorRefusedNoAccount
        case .notSynced?, .nothingToDo?: return ProtectionWords.crossingDoorClosed
        default: return ProtectionWords.crossingFailed
        }
    }
}
