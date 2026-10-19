//
//  ProtectionAccountActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-308 U1 — THE ACCOUNT SECTION'S ROADS on the open library, off the main actor (`notes/plans/vx-308-accounts-key-
//  doors.md` §5a and its U1 ARBITRATION; the contract `notes/CastleRules.md` rules 7, 14, 16). Through the session's
//  executor — the one thing that writes — and NOTHING HERE DECIDES: `assess` says what each door is, the core's acts do
//  what the rules say, on their sealed plans (rule 20).
//
//    - THE PANE'S ONE READ (`ProtectionPaneRead.read` — R-2): `assess` over the open library's facts with the CURRENT
//      sign-in (read now: the open's is stale once she signs in or out) and a FRESH vault read for the signed-in account
//      (decision 35 — a synced door without one refuses `.needsFreshVault`; a local library needs it to tell setting sync
//      up from a join). The crossings' faces and the account faces derive from this one read, and both doors' press-time
//      re-reads (VX-108) read the same way, so a shown door and its re-read always compare like with like. The vault is
//      read through the leaf directly — the executor's own cache is the acts' (each act reads the vault it acts on).
//    - THE PRESS (`ProtectionAccountRoad.press`): one act at a time on the session; the door RE-READ through the one
//      read (VX-108 — a door that closed refuses, one that changed is re-shown, nothing written); the CURRENT sign-in
//      adopted into the executor's configuration UNDER the act's lock (R-2 — the open's sign-in is stale once she signs
//      in); then the core's act ON THE OPEN SESSION: turning sync on (`setUpSync` — rule 7's hand-up: the vault made, the
//      key file re-locked to carry the account's master, the record naming the account; the key unchanged) and the three
//      LOCAL leaves (`leaveAccount` — rule 16: the record stops naming the account and this Mac forgets its sync keys; no
//      key, lock or secret changes; the server keeps what was pushed). No swap, so no reopen: the pool stays open, as the
//      set-passphrase road's record write does.
//    - P-VX308-U1-F1's HOOK (`accountDeleted` — the U1 ARBITRATION's refined (b)): the Account sheet's Delete Account
//      landed (the server's deletion is the account lifecycle's, her ruled friction): when THIS library names the deleted
//      account, the protection half runs — the third local leave — so no record is left naming a dead account. When it
//      cannot run (another act running, no library open on the new road, a failure), the record keeps naming the account,
//      the next read finds no one signed in, and the signed-out screens' *Use this Mac only…* closes it.
//

import Foundation
import VariorumCore

/// One account door's press, as the confirm hands it to the road.
nonisolated struct RoadAccountRequest: Sendable {
    let door: RoadAccountDoor
    /// The door as the confirm showed it — the road compares the door it re-reads with this (VX-108).
    let shown: RoadAccountDoorOpen
    let typed: TypedSecrets
}

/// What an account press came to.
nonisolated enum RoadAccountPress: Equatable, Sendable {
    /// The act landed — its receipt.
    case made(receipt: String)
    case refused(String)
    /// The door is open but says something new (VX-108) — re-shown.
    case changed(RoadAccountDoorOpen)
}

nonisolated enum ProtectionAccountRoad {
    /// **The press** — every check first (all reads), then the act; one act at a time on the session.
    static func press(
        _ session: ProtectionRoadSession, request: RoadAccountRequest, signIn: SessionFact,
        exportSwitch: ScheduledExportSwitch?
    ) async -> RoadAccountPress {
        guard session.writes else { return .refused(ProtectionWords.crossingFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        // VX-108: the door as it stands NOW, read the way the shown one was.
        let read = await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exportSwitch)
        guard let faces = read.flatMap(ProtectionPaneRead.accountFaces) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        switch faces.face(request.door) {
        case .hidden, .notYet: return .refused(ProtectionWords.crossingDoorClosed)
        case .refused(let sentence): return .refused(sentence)
        case .open(let now):
            guard now == request.shown else { return .changed(now) }
        }
        return await act(session, door: request.door, typed: request.typed, signIn: signIn)
    }

    /// The core's act on the open session (the caller holds the session's one-act lock).
    static func act(
        _ session: ProtectionRoadSession, door: RoadAccountDoor, typed: TypedSecrets, signIn: SessionFact
    ) async -> RoadAccountPress {
        // R-2: the sign-in NOW — never the open's.
        session.executor.configuration.session = signIn
        var library = session.library
        do {
            if let leave = door.leave {
                _ = try await session.executor.leaveAccount(leave, &library)
            } else {
                _ = try await session.executor.setUpSync(&library, typed: typed)
            }
        } catch {
            session.library = library
            let unfinished = library.section.actInFlight != nil
            ProtectionOpenRoad.log(
                "road: \(door.rawValue) did not land\(unfinished ? " — its act stays in flight; the next open settles it" : "")"
                    + " — \(String(describing: error))")
            return .refused(RoadAccountFaces.actRefusalSentence(error, unfinished: unfinished))
        }
        session.library = library
        ProtectionOpenRoad.log(
            "road: \(door.rawValue) — library \(String((library.record?.libraryID ?? "none").prefix(8))) now names "
                + "\(library.record?.account.map { "account \(String($0.prefix(8)))" } ?? "no account"); its key unchanged "
                + "(\(StoreKeyEnvelope.shortFingerprint(library.fingerprint)))")
        return .made(receipt: door.receipt)
    }

    /// **P-VX308-U1-F1's hook** — the Account sheet's Delete Account landed for `accountID`: when this library names it,
    /// the protection half runs (the third local leave). True when it ran. The caller holds the session's one-act lock.
    static func accountDeleted(_ session: ProtectionRoadSession, accountID: String, signIn: SessionFact) async -> Bool {
        guard session.library.record?.account == accountID else { return false }
        switch await act(session, door: .deleteAccountHere, typed: .none, signIn: signIn) {
        case .made:
            ProtectionOpenRoad.log("road: the account was deleted — this library no longer names it (rule 16's local leave)")
            return true
        case .refused, .changed:
            ProtectionOpenRoad.log("road: the account was deleted, but this library still names it — the signed-out "
                + "screens' This Mac Only closes it")
            return false
        }
    }
}

/// The pane's one read: the facts `assess` reads, and what the vault read found.
nonisolated struct ProtectionPaneFacts: Sendable {
    var facts: ProtectionFacts
    var vault: VaultReadState
}

nonisolated enum ProtectionPaneRead {
    /// **THE PANE'S ONE READ** (a READ): the open library's facts with `signIn` (the sign-in now) and the signed-in
    /// account's vault, read fresh; this Mac's scheduled export as the weekly copy's switch says it (U2a's
    /// P-VX307-U2a-3). nil: the facts could not be read (logged) — the pane shows no door rather than a guess.
    static func read(
        _ session: ProtectionRoadSession, signIn: SessionFact, exportSwitch: ScheduledExportSwitch?
    ) async -> ProtectionPaneFacts? {
        var facts: ProtectionFacts
        do {
            facts = try session.system.facts(session: signIn, unlocked: session.library)
        } catch {
            ProtectionOpenRoad.log("road: the pane's facts could not be read — \(String(describing: error))")
            return nil
        }
        if let exportSwitch { facts.unlocked?.thisMac.settings.scheduledExport = exportSwitch.isOn() }
        guard let account = signIn.accountID else { return ProtectionPaneFacts(facts: facts, vault: .notAsked) }
        do {
            let snapshot = try await session.system.leaves.vault.fetchVault(accountID: account)
            facts.vault = snapshot?.reading
            return ProtectionPaneFacts(facts: facts, vault: .read(exists: snapshot != nil))
        } catch {
            ProtectionOpenRoad.log("road: the account's vault could not be read — \(String(describing: error))")
            return ProtectionPaneFacts(facts: facts, vault: .unreachable)
        }
    }

    /// The account section's faces from one read.
    static func accountFaces(_ read: ProtectionPaneFacts) -> RoadAccountFaces? {
        RoadAccountFaces.derive(read.facts, assess(read.facts), vault: read.vault)
    }
}
