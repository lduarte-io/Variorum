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
    /// VX-308 U2 — into Castle (a join that enters it, the follow into it): her gate choice; nil elsewhere (the core's
    /// own default — this Mac's section).
    var gate: GateStyle? = nil
}

/// What an account press came to.
nonisolated enum RoadAccountPress: Equatable, Sendable {
    /// The act landed — its receipt (nil: owed to the reopen a re-keying act makes — said there, once); `wordsReplaced`:
    /// a join's `ActNotice.wordsReplacedByAccount` (rule 7 — the words moment is owed).
    case made(receipt: String?, wordsReplaced: Bool = false)
    case refused(String)
    /// The door is open but says something new (VX-108) — re-shown.
    case changed(RoadAccountDoorOpen)
}

/// What an account act came to on the session (VX-308 U2 — the re-keying acts reopen with `reopenKey`).
nonisolated struct AccountActResult: Sendable {
    var press: RoadAccountPress
    /// The key that opens the slot now — the new one once a re-keying act's swap landed, else the old one.
    var reopenKey: StoreKey
    /// The act ran to its end in this process. false with `.made`: it stopped past its swap — the next open's settle
    /// finishes it and says its Done there (VX-107's road), so nothing here says it.
    var landedWhole: Bool
}

/// What a re-keying account press's preflight found (VX-308 U2 — every read before the app's pool closes).
nonisolated enum AccountPreflight: Equatable, Sendable {
    case ready
    case refused(String)
    case changed(RoadAccountDoorOpen)
}

/// **VX-309 U2 — VX-457: THE FOLLOW'S DONE, A DURABLE MARK BY LIBRARY** (her ruling 2026-10-19 on P-VX308-U2-7, "I agree
/// with B"; rule 11's export-notice idiom — `ExportNoticeMark`, the per-library calm-asks ledger
/// `variorum.calmAsks.<topic>.<libraryID>.*`): the follow's kind, written in this Mac's defaults where the Done was owed —
/// the press that landed whole (`ProtectionAccountRoad.owed`), the open whose settle finished it (`RoadStandingModel.make`,
/// VX-107's durable reading) — read at every refresh of the account section, cleared ONLY by the notice's OK. So
/// `receipt_style` off and a quit before she looks lose nothing; a library standing in the slot later reads its own mark
/// only. A kind name, never a secret. Only new-road code writes it (today's road has no account section).
nonisolated enum FollowDoneMark {
    static func key(_ libraryID: String) -> String { "variorum.calmAsks.followDone.\(libraryID).kind" }

    /// The kind as stored (a plain name — `FollowKind` carries no raw value in the core).
    static func name(_ kind: FollowKind) -> String {
        switch kind {
        case .intoCastle: return "intoCastle"
        case .intoStandard: return "intoStandard"
        case .keysReplaced: return "keysReplaced"
        // VX-529 unit 1 (the run record's F-1): the core's third kind, named so this compiles; `owed` below does not read
        // it back yet (read as none) — UNIT 2 (the faces) reads it back with its own Done.
        case .pairChanged: return "pairChanged"
        }
    }

    /// The Done owed for `libraryID` (nil: none, or a name this build doesn't know — read as none).
    static func owed(_ libraryID: String, in defaults: UserDefaults) -> FollowKind? {
        switch defaults.string(forKey: key(libraryID)) {
        case "intoCastle": return .intoCastle
        case "intoStandard": return .intoStandard
        case "keysReplaced": return .keysReplaced
        default: return nil
        }
    }

    /// The mark written (a later follow's kind replaces an earlier one still unread — the newest Done is the true one)
    /// or, nil, cleared.
    static func set(_ libraryID: String, _ kind: FollowKind?, in defaults: UserDefaults) {
        if let kind { defaults.set(name(kind), forKey: key(libraryID)) } else { defaults.removeObject(forKey: key(libraryID)) }
    }
}

nonisolated enum ProtectionAccountRoad {
    /// **VX-309 U2 — VX-457: what a re-keying account act OWES after it ran** (the bootstrap's seam reads it): a follow
    /// that landed WHOLE owes its Done DURABLY (`followDone` — the pane's notice until OK), never a receipt; any other act
    /// that landed whole owes its receipt to the reopen, as before; an act that stopped past its swap owes nothing here
    /// (the next open's settle finishes it and the open marks the Done — VX-107's road).
    static func owed(after result: AccountActResult, request: RoadAccountRequest) -> (receipts: [String], followDone: FollowKind?) {
        guard case .made(let receipt, _) = result.press, result.landedWhole else { return ([], nil) }
        if let kind = request.shown.follow { return ([], kind) }
        return ([receipt].compactMap { $0 }, nil)
    }

    /// **The press on the OPEN session** — every check first (all reads), then the act; one act at a time on the session.
    /// For the acts that change no key (turning sync on, a join in the same posture, Move in the same posture, the three
    /// leaves); a re-keying act (a join that crosses postures, every follow) is the bootstrap's crossing seam's —
    /// `preflight`, the pool closed, `perform`, the reopen — and is refused here (never re-keyed under an open pool).
    static func press(
        _ session: ProtectionRoadSession, request: RoadAccountRequest, signIn: SessionFact,
        exportSwitch: ScheduledExportSwitch?
    ) async -> RoadAccountPress {
        guard session.writes else { return .refused(ProtectionWords.crossingFailed) }
        guard !request.shown.rekeys else { return .refused(ProtectionWords.crossingFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        // VX-108: the door as it stands NOW, read the way the shown one was.
        let read = await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exportSwitch)
        guard let faces = read.flatMap({ ProtectionPaneRead.accountFaces($0, session: session) }) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        switch faces.face(request.door) {
        case .hidden, .notYet: return .refused(ProtectionWords.crossingDoorClosed)
        case .refused(let sentence): return .refused(sentence)
        case .open(let now):
            guard now == request.shown else { return .changed(now) }
        }
        return await perform(session, request: request, signIn: signIn, exportSwitch: exportSwitch).press
    }

    /// **A RE-KEYING ACCOUNT PRESS's PREFLIGHT** (VX-308 U2, R-U2-3 — READS only, before the bootstrap closes anything):
    /// the door RE-READ through the pane's one read (VX-108 — closed refuses, changed re-shows, nothing written), then the
    /// typed secret against the vault that read fetched — the same derivation and the same refusals the core's `join` and
    /// `follow` make before their plans begin (VX-113's `passphraseChangedElsewhere` among them), so a typo never tears
    /// the window down.
    static func preflight(
        _ session: ProtectionRoadSession, request: RoadAccountRequest, signIn: SessionFact,
        exportSwitch: ScheduledExportSwitch?
    ) async -> AccountPreflight {
        let read = await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exportSwitch)
        guard let read, let faces = ProtectionPaneRead.accountFaces(read, session: session) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        switch faces.face(request.door) {
        case .hidden, .notYet: return .refused(ProtectionWords.crossingDoorClosed)
        case .refused(let sentence): return .refused(sentence)
        case .open(let now):
            guard now == request.shown else { return .changed(now) }
        }
        guard request.shown.ask == .oneSecret else { return .ready }
        if let refusal = accountSecretRefusal(
            request, snapshot: read.snapshot, library: session.library, floor: session.system.floor) {
            return .refused(refusal)
        }
        return .ready
    }

    /// **VX-464 (W-VX309-3): whether the secret this door types is the ACCOUNT's** — the join (turning sync on where the
    /// account already has a vault) and Move check it against the vault (rule 14), so their refusals name the account.
    /// The follow types the library's pair, which the account's already is (rule 7), and set-up the library's own pair
    /// (rule 7's hand-up): theirs keep "this library".
    static func typesTheAccountsSecret(_ request: RoadAccountRequest) -> Bool {
        switch request.door {
        case .moveToSignedInAccount: return true
        case .turnOnSync: return request.shown.spec.join.map { $0 != .setsUpInLibrarysMode } ?? false
        case .follow, .stopSyncingHere, .deleteAccountHere, .thisMacOnly: return false
        }
    }

    /// The typed secret against the account's vault (a READ): what the core's own checks would refuse, said in the act's
    /// words — a join types one of the account's secrets, either or both, each that is typed opening the vault (rule 14);
    /// the follow types one — the passphrase when it is typed, else the words — and an old passphrase whose lock is not
    /// the vault's any more names the change (VX-113); VX-529 unit 2 (scope 5): so do the follow's OLD twelve words, which
    /// open this library through its own key file but not the account's vault (the core's P7-2 split,
    /// `refusalForWordsTheVaultRefusesAtTheFollow`, mirrored — the preflight never pre-empts it with a false sentence).
    /// nil: it opens.
    static func accountSecretRefusal(
        _ request: RoadAccountRequest, snapshot: VaultSnapshot?, library: UnlockedLibrary, floor: PassphraseKDF.Floor
    ) -> String? {
        guard let snapshot else { return ProtectionWords.doorRefusedNeedsVault }
        let vault = snapshot.vault
        let follows = request.door == .follow
        let accounts = typesTheAccountsSecret(request)
        func said(_ refusal: ExecutorRefusal) -> String {
            RoadAccountFaces.actRefusalSentence(refusal, unfinished: false, secretIsTheAccounts: accounts)
        }
        let typed = request.typed
        guard typed.passphrase != nil || typed.words != nil else { return said(.secretMissing) }
        if let text = typed.passphrase {
            guard (try? vault.kdf.validateFloor(floor)) != nil, let key = try? PassphraseKey.derive(text, kdf: vault.kdf)
            else { return ProtectionWords.crossingFailed }
            if VaultModel.master(of: vault, passphrase: key, words: nil) == nil {
                if follows, let known = library.keyFile?.passphrase?.kdf, known != vault.kdf {
                    return said(.passphraseChangedElsewhere(device: vault.updatedByDevice, day: snapshot.updatedAt))
                }
                return said(.passphraseDoesNotOpen)
            }
            // The follow uses the passphrase alone once it is typed (`Follow.swift`); a join checks the words too.
            if follows { return nil }
        }
        if let words = typed.words {
            guard let key = try? WordsKey.derive(words), VaultModel.master(of: vault, passphrase: nil, words: key) != nil
            else {
                if follows, let file = library.keyFile, file.fingerprint == library.fingerprint,
                   (try? file.open(.words(words), floor: floor)) == library.key {
                    return said(.wordsChangedElsewhere(device: vault.updatedByDevice, day: snapshot.updatedAt))
                }
                return said(.wordsDoNotOpen)
            }
        }
        return nil
    }

    /// The core's act on the open session (U1's road for the doors that change no key — the caller holds the session's
    /// one-act lock).
    static func act(
        _ session: ProtectionRoadSession, door: RoadAccountDoor, typed: TypedSecrets, signIn: SessionFact
    ) async -> RoadAccountPress {
        let shown = RoadAccountDoorOpen(door: door, ask: .nothing, newPassphrase: false, sentences: [], spec: DoorSpec(requires: .none))
        return await perform(
            session, request: RoadAccountRequest(door: door, shown: shown, typed: typed), signIn: signIn,
            exportSwitch: nil).press
    }

    /// **THE ACCOUNT ACT** (the caller holds the session's one-act lock; for a re-keying act the app's pool is CLOSED —
    /// the bootstrap's seam): the CURRENT sign-in adopted (R-2); into Castle, rule 11 first (the notice owed durably, the
    /// weekly switch mirrored into this Mac's sealed setting — U2a's MAJOR-1 machinery, the one home); then the core's act:
    /// turning sync on (`setUpSync` — rule 7's hand-up — or, the account already syncing, `enroll`: the join), Move
    /// (`move`), the follow (`follow` — its kind the owed act's), a leave (`leaveAccount` — rule 16). Before a swap a
    /// refusal leaves the library under its old key (rolled back — rule 20 — or, an act stopped mid-plan, finished by the
    /// next open); past the swap the act LANDED and the next open's settle finishes it (VX-107: its Done said there).
    static func perform(
        _ session: ProtectionRoadSession, request: RoadAccountRequest, signIn: SessionFact,
        exportSwitch: ScheduledExportSwitch?
    ) async -> AccountActResult {
        // R-2: the sign-in NOW — never the open's.
        session.executor.configuration.session = signIn
        let door = request.door
        let shown = request.shown
        let slot = session.system.places.slot
        let oldKey = session.key
        let executor = session.executor
        var library = session.library
        let entersCastle = shown.follow == .intoCastle || shown.spec.join == .entersCastle
        // VX-308 U4 (NIT-R2-1): rule 11's mark is THIS library's (an account act never changes the library's id).
        let libraryID = library.record?.libraryID
        let markedHere = entersCastle
            ? exportSwitch.map { ProtectionCrossings.markCastleEntry($0, libraryID: libraryID) } ?? false : false
        var acted: ActOutcome?
        do {
            if entersCastle, let exportSwitch,
               let settings = ProtectionCrossings.mirroredExportSettings(library, exportSwitch: exportSwitch) {
                _ = try await executor.changeSettings(&library, to: settings)
            }
            switch door {
            case .turnOnSync:
                if let join = shown.spec.join, join != .setsUpInLibrarysMode {
                    acted = try await executor.enroll(&library, typed: request.typed, gate: request.gate)
                } else {
                    acted = try await executor.setUpSync(&library, typed: request.typed)
                }
            case .moveToSignedInAccount:
                acted = try await executor.move(&library, typed: request.typed, gate: request.gate)
            case .follow:
                guard let kind = shown.follow else { throw ExecutorRefusal.nothingToDo }
                acted = try await executor.follow(&library, kind: kind, typed: request.typed, gate: request.gate)
            case .stopSyncingHere, .deleteAccountHere, .thisMacOnly:
                guard let leave = door.leave else { throw ExecutorRefusal.nothingToDo }
                acted = try await executor.leaveAccount(leave, &library)
            }
        } catch {
            session.library = library
            if ProtectionLibraryFiles.opens(slot, key: oldKey) {
                // Nothing swapped — the library stands under its old key (rolled back, or an act stopped mid-plan that
                // the next open settles — rule 20); no export notice.
                if markedHere, let libraryID { exportSwitch?.setNoticeOwed(libraryID, false) }
                let unfinished = library.section.actInFlight != nil
                ProtectionOpenRoad.log(
                    "road: \(door.rawValue) did not land\(unfinished ? " — its act stays in flight; the next open settles it" : "")"
                        + " — \(String(describing: error))")
                return AccountActResult(
                    press: .refused(RoadAccountFaces.actRefusalSentence(
                        error, unfinished: unfinished, secretIsTheAccounts: typesTheAccountsSecret(request))),
                    reopenKey: oldKey, landedWhole: false)
            }
            // Past the swap (the commit point): the act LANDED; its last steps finish at the next open's settle.
            ProtectionOpenRoad.log(
                "road: \(door.rawValue) swapped, then stopped — the next open finishes it (\(String(describing: error)))")
        }
        session.library = library
        // Rule 11's notice, the core's own (the entry's `exportOff` step): the switch the app runs follows it here. An entry
        // that stopped past its swap before that step is the ready's reconcile's (MAJOR-1 — the mark says so).
        if acted?.notices.contains(.scheduledExportTurnedOff) == true, let exportSwitch {
            ProtectionCrossings.followExportSwitch(exportSwitch)
        }
        let reopenKey = ProtectionLibraryFiles.opens(slot, key: library.key) ? library.key : oldKey
        ProtectionOpenRoad.log(
            "road: \(door.rawValue) — library \(String((library.record?.libraryID ?? "none").prefix(8))) now names "
                + "\(library.record?.account.map { "account \(String($0.prefix(8)))" } ?? "no account"), "
                + "\(library.record?.mode.rawValue ?? "?") under \(KeyFingerprint.short(library.fingerprint))"
                + (acted == nil ? " — its last steps at the next open" : ""))
        return AccountActResult(
            press: .made(
                receipt: acted == nil ? nil : shown.receipt,
                wordsReplaced: acted?.notices.contains(.wordsReplacedByAccount) ?? false),
            reopenKey: reopenKey, landedWhole: acted != nil)
    }

    /// **The signed-out road's *Continue*** (Use Castle while signed out — VX-264, R-1 as amended): This Mac Only, its
    /// door re-read at the press (VX-108 — signed in meanwhile, it is no longer open: refused, nothing written). nil: the
    /// leave landed; else its refusal. One act at a time on the session.
    static func leaveForUseCastle(
        _ session: ProtectionRoadSession, signIn: SessionFact, exportSwitch: ScheduledExportSwitch?
    ) async -> String? {
        guard session.writes else { return ProtectionWords.crossingFailed }
        guard session.beginAct() else { return ProtectionWords.copyDoorBusy }
        defer { session.endAct() }
        let read = await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exportSwitch)
        guard let faces = read.flatMap({ ProtectionPaneRead.accountFaces($0, session: session) }) else { return ProtectionWords.crossingFailed }
        guard faces.thisMacOnly.openDoor != nil else { return ProtectionWords.crossingDoorClosed }
        switch await act(session, door: .thisMacOnly, typed: .none, signIn: signIn) {
        case .made: return nil
        case .refused(let sentence): return sentence
        case .changed: return ProtectionWords.crossingDoorChanged
        }
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
    /// VX-308 U2 — the vault row as the read fetched it (non-secret on its own: every key in it is wrapped) — a
    /// re-keying account press's preflight checks the typed secret against it (R-U2-3). nil: none read, or none there.
    var snapshot: VaultSnapshot? = nil
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
            return ProtectionPaneFacts(facts: facts, vault: .read(exists: snapshot != nil), snapshot: snapshot)
        } catch {
            ProtectionOpenRoad.log("road: the account's vault could not be read — \(String(describing: error))")
            return ProtectionPaneFacts(facts: facts, vault: .unreachable)
        }
    }

    /// The account section's faces from one read (`copyName`: rule 25's list at a join into Castle).
    static func accountFaces(
        _ read: ProtectionPaneFacts, copyName: (String) -> String? = { _ in nil }
    ) -> RoadAccountFaces? {
        RoadAccountFaces.derive(read.facts, assess(read.facts), vault: read.vault, copyName: copyName)
    }

    /// The account section's faces from one read over `session` (rule 25's copies named by the session's places).
    static func accountFaces(_ read: ProtectionPaneFacts, session: ProtectionRoadSession) -> RoadAccountFaces? {
        accountFaces(read, copyName: ProtectionCrossings.copyName(session, catalog: read.facts.catalog))
    }

    /// **VX-308 ladder round 1, MINOR-2 — ONE READ, THREE SECTIONS** (R-2's letter: the sections derive from ONE
    /// assessment): the pane's one read taken ONCE — one facts gather, one vault fetch — and the crossings', the account
    /// section's and the key doors' faces each derived from it exactly as each section's own read derives them, so an
    /// appearance's three sections agree with one another and cost one wire read. A read that fails gives no faces (each
    /// section's own read gives none the same way).
    static func wave(
        _ session: ProtectionRoadSession, signIn: SessionFact, exportSwitch: ScheduledExportSwitch
    ) async -> ProtectionPaneWave {
        guard let read = await read(session, signIn: signIn, exportSwitch: exportSwitch) else { return ProtectionPaneWave() }
        return ProtectionPaneWave(
            crossings: ProtectionCrossings.readCrossings(session, exportSwitch: exportSwitch, read: read),
            account: accountFaces(read, session: session),
            keyDoors: ProtectionKeyDoorRoad.faces(read))
    }
}

/// VX-308 ladder round 1 (MINOR-2) — one pane read's faces for the three sections (nil: that section has none to show).
nonisolated struct ProtectionPaneWave: Sendable {
    var crossings: RoadCrossingFaces?
    var account: RoadAccountFaces?
    var keyDoors: RoadKeyDoorFaces?
}
