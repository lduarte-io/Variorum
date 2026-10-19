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
        log("road: the offered key file is beside the library (\(StoreKeyEnvelope.shortFingerprint(offer.keyFile.fingerprint)))")
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
    static func mintFreshWords(session: ProtectionRoadSession, passphrase: String?) async -> WordsMintOutcome {
        guard session.writes else { return .refused(ProtectionWords.wordsLookFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
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
                + "(\(StoreKeyEnvelope.shortFingerprint(library.fingerprint)))")
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

    // MARK: - Rule 27: Start a New Library over a library no key file opens

    /// The slot's library — the file, its sidecars, and anything in the live place — moved WHOLE into
    /// `Previous Libraries/<stamp>/` (never deleted), so the creation lands in an empty slot (PROVISIONAL
    /// P-VX306-U2-5).
    static func setAsideUnopenableLibraryFor(_ places: ProtectionPlaces) throws {
        let manager = FileManager.default
        guard manager.fileExists(atPath: places.slot.path) else { return }
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
                log("road: the library no key file opens was set aside whole into Previous Libraries/\(folder.lastPathComponent)")
                return
            }
            date += 1
        }
    }
}
