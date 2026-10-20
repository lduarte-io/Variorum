//
//  ProtectionCrossingActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-307 U2a — THE CROSSINGS' ROADS on the open library, off the main actor (`notes/plans/vx-307-castle-crossings.md`
//  §5c; the contract `notes/CastleRules.md` rules 9, 11, 12, 20, 25). Through the session's executor — the one thing
//  that writes — and NOTHING HERE DECIDES: `assess` says what each door is, the core's acts (`useCastle`, `useStandard`,
//  `replaceAllKeys`, `changeSettings`) do what the rules say, on their sealed plans (rule 20 — VX-235's proof is the
//  core's crash harness).
//
//    - THE READ (`readCrossings`) — the doors as `assess` says them over the OPEN library's facts (VX-108: never a local
//      posture), with THIS MAC'S SCHEDULED EXPORT as it really is: the weekly plain-text copy's switch (today's
//      `MarkdownInsurance` key, the only scheduled export this app has) is read as the device's scheduled-export fact, so
//      Use Castle's door says it turns off exactly when it is on (PROVISIONAL P-VX307-U2a-3 — the sealed setting the core
//      reads and the switch the app runs are two places on the new road until the Data Safety toggle writes the sealed
//      one).
//      VX-308 U4 — F-4: the read also carries the RESTORE HOLD's gate (the 13x F1 R1-M1 rule on the new road): while the
//      hold's marker stands beside the store, a SYNCED Use Castle and Replace All Keys say their refusal in place — and,
//      the preflight re-reading through here, the press refuses with it before anything closes.
//    - THE PREFLIGHT (`preflight`) — every check before anything closes, all READS: the door RE-READ at the press
//      (VX-108 — a door that closed or changed since the confirm opened refuses, nothing written); the typed pair against
//      the live key file (the words always; the passphrase where its lock exists — else the one typed is the new one,
//      rule 3). A typo never tears the window down. A SYNCED library's pair is the account's: the act reads the vault
//      itself (doorSecrets), so the preflight leaves it to the act (synced crossings are VX-308's to face — no new-road
//      library names an account this phase).
//    - THE ACT (`cross`) — run with the app's pool CLOSED (the bootstrap's seam — the swap's precondition): Use Castle
//      first mirrors the switch into this Mac's sealed device settings (`changeSettings`), so the act's own step turns it
//      off and owes rule 11's notice; then the core's act; then the switch FOLLOWS the act's notice (the core decided —
//      the switch the app runs goes off with it). Before the swap a refusal leaves the
//      library under its old key (the core rolls back, rule 20); past the swap the library IS crossed and the next
//      open's settle finishes the act — the door says it landed.
//    - THE NOTICE'S REVERSAL (`turnExportBackOn`) — rule 11's "one notice you may reverse": the sealed setting and the
//      switch, back on.
//    - THE READY'S RECONCILE (`reconcileExport` — ladder round 1, MAJOR-1): the notice is a DURABLE mark written before
//      a Use Castle's act; every open on the new road follows the switch off once the core's step has run — so an entry
//      that stopped past its swap (finished by the next open's settle) and a quit before *OK* lose neither the switch-off
//      nor the notice.
//    - THE GATE-STYLE ROW (`changeGate`) — `changeSettings`: Touch ID on only with the passphrase where the hardware and
//      a finger are here; Always ask deletes the item.
//

import Foundation
import VariorumCore

/// This Mac's scheduled plain-text export — the switch the app's weekly copy runs on (production: `MarkdownInsurance`
/// over this Mac's defaults; a test's, in memory).
nonisolated struct ScheduledExportSwitch: Sendable {
    var isOn: @Sendable () -> Bool
    var set: @Sendable (Bool) -> Void
    /// RULE 11's one notice, OWED (ladder round 1, MAJOR-1): a DURABLE mark beside the switch (this Mac's defaults in
    /// production) — written before a Use Castle's act whenever the switch is on, cleared only by *OK*, *Turn it back
    /// on*, or a ready that finds the library not in Castle. So neither a crash past the swap nor a quit before *OK* can
    /// lose the notice, and the ready's reconcile (`ProtectionCrossings.reconcileExport`) knows an entry is owed its
    /// follow — never inferring it from "Castle + the switch on", which is also her own later choice.
    /// VX-308 U4 (NIT-R2-1): the mark is BY LIBRARY — `libraryID` names the library the entry was made in (the record's),
    /// so a ready of ANOTHER library standing in the slot (Make this my library; a library moved in by hand) never clears
    /// a notice she has not answered; the not-in-Castle clear fires only for the library that wrote it.
    var noticeOwed: @Sendable (_ libraryID: String) -> Bool
    var setNoticeOwed: @Sendable (_ libraryID: String, _ owed: Bool) -> Void
}

/// VX-308 U4 (NIT-R2-1) — RULE 11's durable mark in this Mac's defaults, ONE PER LIBRARY (the per-library ledger idiom,
/// `variorum.calmAsks.<topic>.<libraryID>.*` — `PassphraseReminderLedger`, `WordsCardLedger`): a boolean, never a secret.
/// The production switch reads and writes it here (`AppBootstrap.markdownInsuranceSwitch`); a test's suite rides it too.
nonisolated enum ExportNoticeMark {
    /// The library's own key.
    static func key(_ libraryID: String) -> String { "variorum.calmAsks.exportOffNotice.\(libraryID).owed" }
    /// The one-per-defaults-domain mark VX-307's MAJOR-1 wrote (before the mark was by library) — MIGRATED, never read as
    /// anyone's after the first consult.
    static let legacyKey = "variorum.protection.exportOffNoticeOwed"

    /// The notice owed for `libraryID` (the legacy mark adopted first — `adoptLegacy`).
    static func owed(_ libraryID: String, in defaults: UserDefaults) -> Bool {
        adoptLegacy(libraryID, in: defaults)
        return defaults.bool(forKey: key(libraryID))
    }

    /// The mark written or cleared for `libraryID` (the legacy mark adopted first).
    static func set(_ libraryID: String, owed: Bool, in defaults: UserDefaults) {
        adoptLegacy(libraryID, in: defaults)
        if owed { defaults.set(true, forKey: key(libraryID)) } else { defaults.removeObject(forKey: key(libraryID)) }
    }

    /// THE MIGRATION (the record's R-U4-4): an unkeyed mark left by an earlier build is adopted by the FIRST library whose
    /// mark is consulted — the reconcile at the first ready on the new road, before any pane or press reads it; and the
    /// library standing at the first ready after an entry is the one that entered (the round-2 ordering: the switch-off
    /// always lands before any other library can stand at ready) — then the legacy key is gone. Notice-visibility only:
    /// the switch-off never depended on the mark's key.
    static func adoptLegacy(_ libraryID: String, in defaults: UserDefaults) {
        guard defaults.object(forKey: legacyKey) != nil else { return }
        if defaults.bool(forKey: legacyKey) { defaults.set(true, forKey: key(libraryID)) }
        defaults.removeObject(forKey: legacyKey)
    }
}

/// What the press's preflight found.
nonisolated enum CrossingPreflight: Equatable, Sendable {
    case ready
    /// Nothing written; the sentence says why.
    case refused(String)
    /// The door is open but no longer the one the confirm showed (VX-108): the confirm re-shows it.
    case changed(RoadDoorOpen)
}

/// What a crossing came to.
nonisolated enum CrossingOutcome: Equatable, Sendable {
    /// The library crossed (or, past its swap, will finish at the next open). `exportTurnedOff`: rule 11's notice owed.
    case made(RoadCrossingDoor, exportTurnedOff: Bool)
    case refused(String)
}

nonisolated struct CrossingResult: Sendable {
    var outcome: CrossingOutcome
    /// The key that opens the slot now — the new one once the swap landed, else the old one.
    var reopenKey: StoreKey
}

/// What the gate-style row's press came to.
nonisolated enum GateChangeOutcome: Equatable, Sendable {
    case changed
    case refused(String)
}

nonisolated enum ProtectionCrossings {
    // MARK: - The read

    /// The crossings on the open library now (a READ). nil: the facts could not be read (logged) — the section shows
    /// no door rather than a guess. VX-308 U1 (R-2): `read` is the pane's ONE read (the current sign-in, the fresh vault
    /// reading — `ProtectionPaneRead`); nil keeps this function's own read (the open's session, no vault).
    static func readCrossings(
        _ session: ProtectionRoadSession, exportSwitch: ScheduledExportSwitch, read: ProtectionPaneFacts? = nil
    ) -> RoadCrossingFaces? {
        let library = session.library
        var facts: ProtectionFacts
        if let read {
            facts = read.facts
        } else {
            do {
                facts = try session.system.facts(session: session.executor.configuration.session, unlocked: library)
            } catch {
                ProtectionOpenRoad.log("road: the crossings' facts could not be read — \(String(describing: error))")
                return nil
            }
        }
        // P-VX307-U2a-3: this Mac's scheduled export IS the weekly copy's switch.
        facts.unlocked?.thisMac.settings.scheduledExport = exportSwitch.isOn()
        let assessment = assess(facts)
        let faces = RoadCrossingFaces.derive(facts, assessment, copyName: copyName(session, catalog: facts.catalog))
        // VX-308 U4 — F-4: the restore hold's gate, read HERE — the one read both the pane's doors and the press's re-read
        // take (the preflight below calls this), so a shown door and its press agree; the hold's MARKER beside the store
        // is the gates' one source (13x R3-2), never a projection.
        guard LibraryRestoreHold.isHeld(besideStore: session.system.places.slot) else { return faces }
        return faces?.heldForRestore()
    }

    /// Rule 25's list: a catalogued copy named by its kind and day (nil when it is no longer catalogued) — Use Castle's door
    /// and (VX-308 U2) a join into Castle name the same copies the same way.
    static func copyName(_ session: ProtectionRoadSession, catalog: Catalog) -> (String) -> String? {
        let places = session.system.places
        return { id in
            guard let copy = catalog.copies.first(where: { $0.id == id }) else { return nil }
            let day = ProtectionCopyDoors.asOf(copy, places: places).map { ProtectionWords.day($0) }
                ?? ProtectionWords.offerUnknownDay
            return ProtectionWords.namedCopy(kind: copy.kind, day: day)
        }
    }

    // MARK: - The preflight (READS only)

    /// VX-308 U1 (R-2): `read` — the press's own fresh read, taken the same way the shown door was (the pane's one read).
    static func preflight(
        _ session: ProtectionRoadSession, door: RoadCrossingDoor, shown: RoadDoorOpen, typed: TypedSecrets,
        exportSwitch: ScheduledExportSwitch, read: ProtectionPaneFacts? = nil
    ) -> CrossingPreflight {
        // VX-108: the door as it stands NOW — never the one read when the confirm opened.
        guard let faces = readCrossings(session, exportSwitch: exportSwitch, read: read) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        let now: RoadDoorOpen
        switch faces.face(door) {
        case .hidden, .signedOutRoad: return .refused(ProtectionWords.crossingDoorClosed)
        case .refused(let sentence): return .refused(sentence)
        case .open(let open): now = open
        }
        guard now == shown else { return .changed(now) }
        // A synced library's pair is the account's — the act verifies it against the vault it reads (doorSecrets).
        guard !now.synced else { return .ready }
        let library = session.library
        let floor = session.system.floor
        guard let file = library.keyFile, file.fingerprint == library.fingerprint else {
            return .refused(ProtectionWords.crossingFailed)
        }
        if now.ask.asksWords {
            guard let words = typed.words, (try? file.open(.words(words), floor: floor)) == library.key else {
                return .refused(ProtectionWords.wordsDoNotOpen)
            }
        }
        if now.ask.asksPassphrase {
            if file.passphrase != nil {
                guard let passphrase = typed.passphrase,
                      (try? file.open(passphrase: .passphrase(passphrase), floor: floor)) == library.key
                else { return .refused(ProtectionWords.passphraseDoesNotOpen) }
            } else {
                // Rule 3: none yet — the one typed becomes the library's (the act sets it).
                guard let new = typed.newPassphrase ?? typed.passphrase, !new.isEmpty else {
                    return .refused(ProtectionWords.crossingSecretsMissing)
                }
            }
        }
        return .ready
    }

    // MARK: - The act (the app's pool CLOSED — the bootstrap's seam)

    static func cross(
        _ session: ProtectionRoadSession, door: RoadCrossingDoor, typed: TypedSecrets, gate: GateStyle,
        exportSwitch: ScheduledExportSwitch
    ) async -> CrossingResult {
        let slot = session.system.places.slot
        let oldKey = session.key
        var library = session.library
        let executor = session.executor
        var acted: ActOutcome?
        // MAJOR-1: the notice is owed BEFORE anything moves (a crash anywhere after this still finds the mark) — VX-308 U4
        // (NIT-R2-1): THIS library's mark (a crossing never changes the library's id).
        let libraryID = library.record?.libraryID
        let markedHere = door == .useCastle ? markCastleEntry(exportSwitch, libraryID: libraryID) : false
        do {
            if door == .useCastle {
                // P-VX307-U2a-3: the switch into this Mac's sealed settings first, so the act's own step turns it off.
                if let settings = mirroredExportSettings(library, exportSwitch: exportSwitch) {
                    _ = try await executor.changeSettings(&library, to: settings)
                }
            }
            switch door {
            case .useCastle: acted = try await executor.useCastle(&library, typed: typed, gate: gate)
            case .useStandard: acted = try await executor.useStandard(&library, typed: typed)
            case .replaceAllKeys: acted = try await executor.replaceAllKeys(&library, typed: typed)
            }
        } catch {
            session.library = library
            if ProtectionLibraryFiles.opens(slot, key: oldKey) {
                // Nothing swapped — the library stands as it was (the core rolled the act back, rule 20); no notice.
                if markedHere, let libraryID { exportSwitch.setNoticeOwed(libraryID, false) }
                ProtectionOpenRoad.log("road: \(door.rawValue) did nothing — \(String(describing: error))")
                return CrossingResult(outcome: .refused(RoadCrossingFaces.actRefusalSentence(error)), reopenKey: oldKey)
            }
            // Past the swap (the commit point): the library IS crossed; its last steps finish at the next open's settle.
            ProtectionOpenRoad.log("road: \(door.rawValue) swapped, then stopped — the next open finishes it (\(String(describing: error)))")
        }
        session.library = library
        // The act's own notice (rule 11) — the core's step turned this Mac's scheduled export off; the switch the app
        // runs follows it here. An entry that stopped past its swap BEFORE that step finishes it at the next open's
        // settle; the ready after it follows the switch (`reconcileExport`, MAJOR-1) — the owed mark says so.
        let exportTurnedOff = acted?.notices.contains(.scheduledExportTurnedOff) ?? false
        if exportTurnedOff { followExportSwitch(exportSwitch) }
        let reopenKey = ProtectionLibraryFiles.opens(slot, key: library.key) ? library.key : oldKey
        ProtectionOpenRoad.log(
            "road: \(door.rawValue) — library \(String((library.record?.libraryID ?? "none").prefix(8))) now "
                + "\(library.record?.mode.rawValue ?? "?") under \(StoreKeyEnvelope.shortFingerprint(library.fingerprint)); "
                + "the export notice owed \(exportTurnedOff)")
        return CrossingResult(outcome: .made(door, exportTurnedOff: exportTurnedOff), reopenKey: reopenKey)
    }

    /// RULE 11 BEFORE AN ACT THAT ENTERS CASTLE (Use Castle; VX-308 U2 — a join into a Castle account, the follow into
    /// Castle): the notice owed DURABLY before anything moves (MAJOR-1) whenever the weekly switch is on and no notice is
    /// owed yet. True when the mark was written HERE (an act refused before anything swapped clears it). VX-308 U4
    /// (NIT-R2-1): the mark is the entering library's (`libraryID` — the record's; none, no mark).
    static func markCastleEntry(_ exportSwitch: ScheduledExportSwitch, libraryID: String?) -> Bool {
        guard let libraryID, exportSwitch.isOn(), !exportSwitch.noticeOwed(libraryID) else { return false }
        exportSwitch.setNoticeOwed(libraryID, true)
        return true
    }

    /// P-VX307-U2a-3 — the weekly switch mirrored into this Mac's SEALED setting before an act that enters Castle, so the
    /// core's own `exportOff` step decides and owes rule 11's notice: the settings to write (`changeSettings`), nil when
    /// they already agree.
    static func mirroredExportSettings(_ library: UnlockedLibrary, exportSwitch: ScheduledExportSwitch) -> DeviceSettings? {
        let switchOn = exportSwitch.isOn()
        guard library.section.settings.scheduledExport != switchOn else { return nil }
        var settings = library.section.settings
        settings.scheduledExport = switchOn
        return settings
    }

    /// The switch FOLLOWS the core's step (rule 11: the scheduled export turned off at the entry).
    static func followExportSwitch(_ exportSwitch: ScheduledExportSwitch) {
        guard exportSwitch.isOn() else { return }
        exportSwitch.set(false)
        ProtectionOpenRoad.log("road: the scheduled plain-text export turned off (rule 11)")
    }

    /// **THE READY'S RECONCILE** (ladder round 1, MAJOR-1 — run at every open on the new road, `AppBootstrap`'s ready):
    /// rule 11's switch-off re-derived from DURABLE facts, never from one process's memory. Only while the notice is
    /// owed (the mark a Use Castle wrote before its act):
    ///   - the library is NOT in Castle → nothing is owed (the entry rolled back, or she has since left) — the mark clears;
    ///   - in Castle with this Mac's sealed export still ON → the entry has not finished (an act in flight that could
    ///     not settle) — nothing yet, the mark stands;
    ///   - in Castle with the sealed export OFF → the core's step ran (in-process, or at a settle's resume after a crash)
    ///     — the switch follows it off; the notice stays owed until *OK* or *Turn it back on*.
    /// True when it turned the switch off HERE (the crash corner: the in-process tail never ran).
    /// VX-308 U4 (NIT-R2-1): only THIS library's mark is read and cleared — a ready of another library standing in the slot
    /// leaves a notice the entering library still owes her (the not-in-Castle clear fires only for the library that wrote it).
    @discardableResult
    static func reconcileExport(_ library: UnlockedLibrary, exportSwitch: ScheduledExportSwitch) -> Bool {
        guard let libraryID = library.record?.libraryID, exportSwitch.noticeOwed(libraryID) else { return false }
        guard library.record?.mode == .castle else {
            exportSwitch.setNoticeOwed(libraryID, false)
            ProtectionOpenRoad.log("road: rule 11's notice no longer owed (the library is not in Castle)")
            return false
        }
        guard !library.section.settings.scheduledExport, exportSwitch.isOn() else { return false }
        exportSwitch.set(false)
        ProtectionOpenRoad.log("road: the scheduled plain-text export turned off at the ready (rule 11 — an entry finished by its settle)")
        return true
    }

    /// *OK* on rule 11's notice — the open library's mark clears (nothing else changes). VX-308 U4 (NIT-R2-1): `libraryID`
    /// is the open library's (none — nothing to clear).
    static func dismissExportNotice(exportSwitch: ScheduledExportSwitch, libraryID: String?) {
        guard let libraryID else { return }
        exportSwitch.setNoticeOwed(libraryID, false)
    }

    // MARK: - Rule 11's notice, reversed

    /// *Turn it back on*: this Mac's sealed setting and the switch, back on (her call — rule 11).
    static func turnExportBackOn(_ session: ProtectionRoadSession, exportSwitch: ScheduledExportSwitch) async -> Bool {
        guard session.writes, session.beginAct() else { return false }
        defer { session.endAct() }
        var library = session.library
        var settings = library.section.settings
        settings.scheduledExport = true
        do {
            _ = try await session.executor.changeSettings(&library, to: settings)
        } catch {
            session.library = library
            ProtectionOpenRoad.log("road: the scheduled export could not be turned back on — \(String(describing: error))")
            return false
        }
        session.library = library
        exportSwitch.set(true)
        if let libraryID = library.record?.libraryID { exportSwitch.setNoticeOwed(libraryID, false) }
        ProtectionOpenRoad.log("road: the scheduled plain-text export turned back on (her call)")
        return true
    }

    // MARK: - VX-310's re-arm (the interlude's card)

    /// The re-arm question answered (`answerTouchIDRearm` — guarded in the core on the item's existence): yes makes a
    /// new Touch ID item at this press, no records Always ask; the stale item goes either way. True when written.
    static func answerRearm(_ session: ProtectionRoadSession, yes: Bool) async -> Bool {
        guard session.writes, session.beginAct() else { return false }
        defer { session.endAct() }
        var library = session.library
        do {
            _ = try await session.executor.answerTouchIDRearm(&library, yes: yes)
        } catch {
            session.library = library
            ProtectionOpenRoad.log("road: the Touch ID re-arm could not be answered — \(String(describing: error))")
            return false
        }
        session.library = library
        ProtectionOpenRoad.log("road: the Touch ID re-arm answered \(yes ? "yes — a new item at this press" : "no — Always ask")")
        return true
    }

    // MARK: - The gate-style row

    /// This Mac's gate: Touch ID (with the passphrase, where it works here) or Always ask (the item deleted).
    static func changeGate(_ session: ProtectionRoadSession, to gate: GateStyle, passphrase: String?) async -> GateChangeOutcome {
        guard session.writes else { return .refused(ProtectionWords.gateRowFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        var library = session.library
        var settings = library.section.settings
        settings.gateStyle = gate
        do {
            _ = try await session.executor.changeSettings(&library, to: settings, passphrase: passphrase)
        } catch {
            session.library = library
            ProtectionOpenRoad.log("road: the gate style could not change — \(String(describing: error))")
            switch error as? ExecutorRefusal {
            case .passphraseDoesNotOpen?, .secretMissing?: return .refused(ProtectionWords.passphraseDoesNotOpen)
            default: return .refused(ProtectionWords.gateRowFailed)
            }
        }
        session.library = library
        ProtectionOpenRoad.log("road: this Mac's gate is \(gate.rawValue) now")
        return .changed
    }

    /// VX-309 U1c — VX-451: THE IDLE DIAL — this Mac's sealed `idleLockMinutes` (nil = never) through the core's one road,
    /// `changeSettings` (never UserDefaults — the design's §3.2/§3.15; F-U4-1's option (a), no core line). In Castle only:
    /// Standard never locks (`RoadRelockPolicy` — rule 8), so the dial is not rendered there and its write refuses. The
    /// relock monitors read the policy from the session's library at each tick, so the new minutes count at once.
    static func changeIdleLock(_ session: ProtectionRoadSession, minutes: Int?) async -> GateChangeOutcome {
        guard session.writes, session.library.record?.mode == .castle else { return .refused(ProtectionWords.gateRowFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        var library = session.library
        var settings = library.section.settings
        guard settings.idleLockMinutes != minutes else { return .changed }
        settings.idleLockMinutes = minutes
        do {
            _ = try await session.executor.changeSettings(&library, to: settings)
        } catch {
            session.library = library
            ProtectionOpenRoad.log("road: the idle lock could not change — \(String(describing: error))")
            return .refused(ProtectionWords.gateRowFailed)
        }
        session.library = library
        ProtectionOpenRoad.log("road: this Mac locks after \(minutes.map { "\($0) minutes" } ?? "never") away now")
        return .changed
    }
}
