//
//  ProtectionRoadActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U2 — THE HONEST FACES' ACTS on the new road (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum;
//  the contract `notes/CastleRules.md` rules 1, 3, 21, 27). Off the main actor, through the executor — the one thing
//  that writes — on the open library (`ProtectionRoadSession`). Nothing here decides: `assess` owes the acts, the
//  executor runs them, every key verifies itself.
//
//    - RULE 21's SEARCH (`searchIfOwed`) — run at the open when `assess` owes `.offerKeyFile`: a READ
//      (`ProtectionExecutor.searchKeyFiles`) over this Mac's keychain copy and every catalogued key file; its answer
//      rides the open's report to the faces (the offer card, the split pair's line, rule 27's banner).
//    - RULE 21's YES (`useOffer`) — `useOfferedKeyFile` (one act on a plan: the offered file beside the library,
//      then what this Mac remembers), then the open's repairs again (the quiet roads follow the right file). Nothing
//      is written before it; *Not now* calls nothing.
//    - RULE 3's DOOR (`setFirstPassphrase`) — P-VX306-U2-0 (a), the orchestrator's provisional ruling: the reset
//      door's Standard road, `resetPassphrase(_:authorization: .plainConfirm, new:)` (P-VX378-U3-1 (a) — this Mac
//      holds the key, so nothing else is asked); REFUSED when a passphrase already exists (the sheet sets the first
//      one only — a change is VX-308's key door). The key file gains the passphrase lock; the record's
//      `passphraseSet` follows (the plan's facts write stamps it).
//    - RULE 3's DISMISSAL (`recordReminderDismissed`) — `recordPassphraseReminderDismissed`, one record write.
//    - RULE 27's *Start a New Library* sets the unopenable library aside first (`setAsideUnopenableLibraryFor`).
//    - VX-329 U4 — RULE 26: a library from before this design leaves WHOLE (`setAsidePreDesignLibraryWholeFor` — core's
//      `PreDesignSetAside`: link, one rename, unlink, resumed from the files' identity), by every door that sets the slot
//      aside; the creation road finishes an interrupted one first (`finishAnInterruptedSetAside`).
//

import Foundation
import VariorumCore

/// What *Use it* did.
nonisolated enum UseOfferOutcome: Equatable, Sendable {
    case used
    case failed
}

/// What the set-passphrase sheet's act did.
nonisolated enum SetPassphraseOutcome: Equatable, Sendable {
    case set
    /// A passphrase exists already — nothing written (the sheet sets the first one only).
    case alreadySet
    /// Another act on this library is running — nothing written.
    case busy
    case failed
}

nonisolated extension ProtectionOpenRoad {
    // MARK: - Rule 21: the search, at the open

    /// The search when the open owes the offer (a READ); nil when it is not owed or could not read.
    static func searchIfOwed(
        _ ctx: RoadContext, _ executor: ProtectionExecutor, _ library: UnlockedLibrary, _ report: RoadOpenReport
    ) -> KeyFileSearch? {
        guard report.acts.contains(.offerKeyFile) else { return nil }
        do {
            return try executor.searchKeyFiles(library, catalog: ctx.system.lister.catalog())
        } catch {
            log("road: the key-file search could not read — \(String(describing: error))")
            return nil
        }
    }

    // MARK: - Rule 21: the offer, accepted

    /// *Use it*: the offered key file beside the library (one act on a plan), then the open's repairs again.
    static func useOffer(_ ctx: RoadContext, session: ProtectionRoadSession, offer: KeyFileOffer) async -> UseOfferOutcome {
        guard session.writes, session.beginAct() else { return .failed }
        defer { session.endAct() }
        var library = session.library
        do {
            _ = try await session.executor.useOfferedKeyFile(&library, offer)
        } catch {
            log("road: the offered key file could not be used — \(String(describing: error))")
            session.library = library
            return .failed
        }
        var report = session.report
        repairPasses(ctx, session.executor, &library, &report)
        report.keyFileSearch = searchIfOwed(ctx, session.executor, library, report)
        report.besideIsEmpty = library.keyFile == nil
        session.library = library
        session.report = report
        log("road: the offered key file is beside the library (\(KeyFingerprint.short(offer.keyFile.fingerprint)))")
        return .used
    }

    // MARK: - Rule 3: the first passphrase

    /// The set-passphrase sheet's act (P-VX306-U2-0 (a)): the reset door's Standard road with a plain confirm.
    static func setFirstPassphrase(session: ProtectionRoadSession, new passphrase: String) async -> SetPassphraseOutcome {
        guard session.writes else { return .failed }
        if passphraseExists(session.library) { return .alreadySet }
        guard session.beginAct() else { return .busy }
        defer { session.endAct() }
        var library = session.library
        do {
            _ = try await session.executor.resetPassphrase(&library, authorization: .plainConfirm, new: passphrase)
            session.library = library
            log("road: a passphrase was set — the key file carries the passphrase lock (\(library.keyFile?.passphrase != nil))")
            return .set
        } catch {
            log("road: the passphrase could not be set — \(String(describing: error))")
            session.library = library
            return .failed
        }
    }

    /// A passphrase exists for the library: the record's fact (rule 3), or a passphrase lock on its key file.
    static func passphraseExists(_ library: UnlockedLibrary) -> Bool {
        library.record?.passphraseSet == true || library.keyFile?.passphrase != nil
    }

    /// VX-308 U3 (R-U3-4) — whether a LOOK asks the passphrase: rule 3's fact as the core states it NOW
    /// (`ProtectionRecord.passphraseExists` — a passphrase lock on the live key file of the library's key, or the
    /// account's). The record's stamp is that same fact as of its last write, so the two agree everywhere but VX-447's
    /// state: with every key file gone, the stamp still says "a passphrase" while no lock is left to verify one — the look
    /// would ask what nothing can check, and the act (rightly) refuses it.
    static func lookAsksPassphrase(_ library: UnlockedLibrary) -> Bool {
        let live = library.keyFile.flatMap { $0.fingerprint == library.fingerprint ? $0 : nil }
        return ProtectionRecord.passphraseExists(keyFile: live, account: library.record?.account)
    }

    // MARK: - Rule 2: the look (VX-307 U2b)

    /// VX-307 U2b (VX-412) — RULE 2's LOOK: fresh words (this system's minting, `ids.mintWords`) locked on the key
    /// file through rule 6's act (`regenerateWords` — the key unchanged; a library with a passphrase is asked it, one
    /// with none is asked nothing, PROVISIONAL P-VX307-U2b-1), handed back to be shown ONCE and never stored or logged.
    /// VX-308 U3 (R-U3-5 — the look is the New Words key door): `signIn` — the sign-in NOW, adopted into the executor under
    /// the act's one-act lock (U1's R-2: a synced library's look after a sign-in made since the open acts as whoever is
    /// signed in now); nil keeps the executor's (every earlier caller).
    static func mintFreshWords(
        session: ProtectionRoadSession, passphrase: String?, signIn: SessionFact? = nil
    ) async -> WordsMintOutcome {
        guard session.writes else { return .refused(ProtectionWords.wordsLookFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        if let signIn { session.executor.configuration.session = signIn }
        let fresh = session.system.leaves.ids.mintWords()
        guard fresh.count == 12 else {
            log("road: rule 2's look — the words could not be minted")
            return .refused(ProtectionWords.wordsLookFailed)
        }
        var library = session.library
        do {
            _ = try await session.executor.regenerateWords(&library, passphrase: passphrase, newWords: fresh)
            session.library = library
            log("road: rule 2's look — fresh words lock the key file; the key unchanged "
                + "(\(KeyFingerprint.short(library.fingerprint)))")
            return .minted(fresh)
        } catch ExecutorRefusal.passphraseDoesNotOpen {
            session.library = library
            return .refused(ProtectionWords.passphraseDoesNotOpen)
        } catch {
            log("road: rule 2's look failed — \(String(describing: error))")
            session.library = library
            return .refused(lookRefusal(error))
        }
    }

    /// VX-308 U3 — a look's refusal in the pane's idiom (the New Words door is a key door — R-U3-5): a synced library's
    /// own refusals said as the crossings and the account say them (`RoadCrossingFaces.actRefusalSentence` — signed out,
    /// another account, the vault out of reach, the account moved, an act running, the passphrase changed elsewhere);
    /// anything else U2b's sentence, as before.
    static func lookRefusal(_ error: any Error) -> String {
        if error is VaultRefusal { return ProtectionWords.doorRefusedNeedsVault }
        switch error as? ExecutorRefusal {
        case .signedOutUseThisMacOnly?, .otherAccountSignedIn?, .noAccountSignedIn?, .needsFreshVault?, .vaultOutOfReach?,
             .accountMoved?, .actInFlight?, .passphraseChangedElsewhere?:
            return RoadCrossingFaces.actRefusalSentence(error)
        default:
            return ProtectionWords.wordsLookFailed
        }
    }

    // MARK: - Rule 3: a dismissal, recorded

    /// The returning reminder's *Not now* / *Don't show again* — one record write (the schedule is the face's).
    static func recordReminderDismissed(session: ProtectionRoadSession) -> Bool {
        guard session.writes, session.beginAct() else { return false }
        defer { session.endAct() }
        var library = session.library
        do {
            try session.executor.recordPassphraseReminderDismissed(&library)
            session.library = library
            log("road: rule 3's reminder dismissed — the record counts \(library.record?.reminderDismissals ?? 0)")
            return true
        } catch {
            log("road: the reminder's dismissal could not be recorded — \(String(describing: error))")
            return false
        }
    }

    // MARK: - Rule 26: a library from before this design, set aside WHOLE (VX-329 U4 — THE RULING: (a) + (D))

    /// The slot holds a store from before this design — the fact (`AssessRules.preDesignStore`), re-read from disk NOW
    /// (names only: the store file's presence and the container's listing). Every act that sets one aside asks it first.
    static func slotHoldsAPreDesignStore(_ places: ProtectionPlaces) -> Bool {
        AssessRules.preDesignStore(
            storeFile: ProtectionFactsGatherer.storeFileFact(at: places.slot), catalog: CatalogLister(places: places).catalog())
    }

    /// The library from before this design moved WHOLE into `Previous Libraries/<stamp>/` (`PreDesignSetAside` — link,
    /// one rename, unlink; the resume first; no byte of it read). `carryingHold`: the restore hold beside it is THAT
    /// library's (Start fresh, T-8) — a landing that wrote its own hold first (T-5) keeps it. The folder, or nil when no
    /// store stood in the slot. Throws when nothing could be moved, or when a remainder could not leave yet (the aside
    /// whole; the next press or the creation road finishes it).
    @discardableResult
    static func setAsidePreDesignLibraryWholeFor(_ places: ProtectionPlaces, carryingHold: Bool) throws -> URL? {
        let report = try PreDesignSetAside.setAsideWhole(slotFolder: places.container, carryingHold: carryingHold)
        log("road: the library from before this design was set aside whole into Previous Libraries/"
            + "\(report.folder?.lastPathComponent ?? "-") (no byte read; resumed \(report.finished.count) entries, swept "
            + "\(report.sweptStaging) staging, kept \(report.keptStaging.count))")
        return report.folder
    }

    /// THE CREATION ROAD'S RESUME (THE RULING: the resume and the stale-staging sweep run at the press AND on the creation
    /// road): an interrupted set-aside's remainder beside the slot — entries that are the same files as a committed
    /// aside's — leaves before anything is created; stale staging is swept. Never blocks the creation (a remainder that
    /// cannot leave yet is said in the log, and the creation's own no-clobber preflight still guards the slot).
    static func finishAnInterruptedSetAside(_ places: ProtectionPlaces) {
        do {
            let report = try PreDesignSetAside.finishInterrupted(slotFolder: places.container)
            guard !report.finished.isEmpty || report.sweptStaging > 0 || !report.keptStaging.isEmpty else { return }
            log("road: an interrupted set-aside finished — \(report.finished.count) entries left the slot into "
                + "Previous Libraries/\(report.folder?.lastPathComponent ?? "-"); swept \(report.sweptStaging) staging, "
                + "kept \(report.keptStaging.count)")
        } catch {
            log("road: an interrupted set-aside could not be finished yet — \(String(describing: error))")
        }
    }

    // MARK: - Rule 27: Start a New Library over a library no key file opens

    /// The slot's library — the file, its sidecars, and anything in the live place — moved WHOLE into
    /// `Previous Libraries/<stamp>/` (never deleted), so the creation lands in an empty slot (PROVISIONAL
    /// P-VX306-U2-5).
    static func setAsideUnopenableLibraryFor(_ places: ProtectionPlaces) throws {
        if let folder = try setAsideLibraryWholeFor(places, carryingHold: false) {
            log("road: the library no key file opens was set aside whole into Previous Libraries/\(folder.lastPathComponent)")
        }
    }

    /// VX-309 U1b — the slot's library moved WHOLE into `Previous Libraries/<stamp>/` (never deleted): the file, its
    /// sidecars first (a creation never meets a stray WAL beside the slot; they go back if the file cannot move), the key
    /// file in the live place, and — `carryingHold` — the restore-hold marker beside it (the hold describes THAT library;
    /// T-8's new library is never held). The folder, or nil when nothing stood in the slot.
    /// VX-329 U4 — (D): a library from BEFORE this design in the slot leaves through the WHOLE act instead
    /// (`setAsidePreDesignLibraryWholeFor` — its older key files, its sidecars and its hold with it; crash-safe; never a
    /// byte read): every door that sets the slot aside — T-5's and T-8's landings, a face's *Start a New Library* — keeps
    /// her confirm's promise by this one fact.
    @discardableResult
    static func setAsideLibraryWholeFor(_ places: ProtectionPlaces, carryingHold: Bool) throws -> URL? {
        if slotHoldsAPreDesignStore(places) {
            return try setAsidePreDesignLibraryWholeFor(places, carryingHold: carryingHold)
        }
        let manager = FileManager.default
        guard manager.fileExists(atPath: places.slot.path) else { return nil }
        var date = Date()
        for _ in 0..<120 {
            let folder = places.previousLibraries.appendingPathComponent(CatalogNames.stampString(date), isDirectory: true)
            if !manager.fileExists(atPath: folder.path) {
                try manager.createDirectory(at: folder, withIntermediateDirectories: true)
                let destination = folder.appendingPathComponent(CatalogNames.libraryFilename)
                // The sidecars first, so a creation can never meet a stray WAL beside the slot; if the library
                // itself then cannot move, they go back beside it.
                var moved: [String] = []
                for suffix in ProtectionLibraryFiles.sidecarSuffixes {
                    let sidecar = URL(fileURLWithPath: places.slot.path + suffix)
                    if manager.fileExists(atPath: sidecar.path) {
                        try manager.moveItem(at: sidecar, to: URL(fileURLWithPath: destination.path + suffix))
                        moved.append(suffix)
                    }
                }
                do {
                    try manager.moveItem(at: places.slot, to: destination)
                } catch {
                    for suffix in moved {
                        try? manager.moveItem(
                            at: URL(fileURLWithPath: destination.path + suffix),
                            to: URL(fileURLWithPath: places.slot.path + suffix))
                    }
                    throw error
                }
                if manager.fileExists(atPath: places.liveKeyFile.path) {
                    try manager.moveItem(at: places.liveKeyFile, to: folder.appendingPathComponent(ProtectionNames.keyFilename))
                }
                let hold = LibraryRestoreHold.markerURL(besideStore: places.slot)
                if carryingHold, manager.fileExists(atPath: hold.path) {
                    try manager.moveItem(at: hold, to: folder.appendingPathComponent(LibraryRestoreHold.filename))
                }
                return folder
            }
            date += 1
        }
        return nil
    }
}
