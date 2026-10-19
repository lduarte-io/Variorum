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
    /// no door rather than a guess.
    static func readCrossings(_ session: ProtectionRoadSession, exportSwitch: ScheduledExportSwitch) -> RoadCrossingFaces? {
        let library = session.library
        var facts: ProtectionFacts
        do {
            facts = try session.system.facts(session: session.executor.configuration.session, unlocked: library)
        } catch {
            ProtectionOpenRoad.log("road: the crossings' facts could not be read — \(String(describing: error))")
            return nil
        }
        // P-VX307-U2a-3: this Mac's scheduled export IS the weekly copy's switch.
        facts.unlocked?.thisMac.settings.scheduledExport = exportSwitch.isOn()
        let assessment = assess(facts)
        let places = session.system.places
        let catalog = facts.catalog
        return RoadCrossingFaces.derive(facts, assessment) { id in
            guard let copy = catalog.copies.first(where: { $0.id == id }) else { return nil }
            let day = ProtectionCopyDoors.asOf(copy, places: places).map { ProtectionWords.day($0) }
                ?? ProtectionWords.offerUnknownDay
            return ProtectionWords.namedCopy(kind: copy.kind, day: day)
        }
    }

    // MARK: - The preflight (READS only)

    static func preflight(
        _ session: ProtectionRoadSession, door: RoadCrossingDoor, shown: RoadDoorOpen, typed: TypedSecrets,
        exportSwitch: ScheduledExportSwitch
    ) -> CrossingPreflight {
        // VX-108: the door as it stands NOW — never the one read when the confirm opened.
        guard let faces = readCrossings(session, exportSwitch: exportSwitch) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        let now: RoadDoorOpen
        switch faces.face(door) {
        case .hidden: return .refused(ProtectionWords.crossingDoorClosed)
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
        do {
            if door == .useCastle {
                // P-VX307-U2a-3: the switch into this Mac's sealed settings first, so the act's own step turns it off.
                let switchOn = exportSwitch.isOn()
                if library.section.settings.scheduledExport != switchOn {
                    var settings = library.section.settings
                    settings.scheduledExport = switchOn
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
                // Nothing swapped — the library stands as it was (the core rolled the act back, rule 20).
                ProtectionOpenRoad.log("road: \(door.rawValue) did nothing — \(String(describing: error))")
                return CrossingResult(outcome: .refused(RoadCrossingFaces.actRefusalSentence(error)), reopenKey: oldKey)
            }
            // Past the swap (the commit point): the library IS crossed; its last steps finish at the next open's settle.
            ProtectionOpenRoad.log("road: \(door.rawValue) swapped, then stopped — the next open finishes it (\(String(describing: error)))")
        }
        session.library = library
        // The act's own notice (rule 11) — the core's step turned this Mac's scheduled export off; the switch the app
        // runs follows it. (An entry that stopped past its swap BEFORE that step finishes it at the next open's settle,
        // which this road does not see: the switch is not followed there — a recorded hand-forward, never a silent claim.)
        let exportTurnedOff = acted?.notices.contains(.scheduledExportTurnedOff) ?? false
        if exportTurnedOff { followExportSwitch(exportSwitch) }
        let reopenKey = ProtectionLibraryFiles.opens(slot, key: library.key) ? library.key : oldKey
        ProtectionOpenRoad.log(
            "road: \(door.rawValue) — library \(String((library.record?.libraryID ?? "none").prefix(8))) now "
                + "\(library.record?.mode.rawValue ?? "?") under \(StoreKeyEnvelope.shortFingerprint(library.fingerprint)); "
                + "the export notice owed \(exportTurnedOff)")
        return CrossingResult(outcome: .made(door, exportTurnedOff: exportTurnedOff), reopenKey: reopenKey)
    }

    /// The switch FOLLOWS the core's step (rule 11: the scheduled export turned off at the entry).
    static func followExportSwitch(_ exportSwitch: ScheduledExportSwitch) {
        guard exportSwitch.isOn() else { return }
        exportSwitch.set(false)
        ProtectionOpenRoad.log("road: the scheduled plain-text export turned off (rule 11)")
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
        ProtectionOpenRoad.log("road: the scheduled plain-text export turned back on (her call)")
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
}
