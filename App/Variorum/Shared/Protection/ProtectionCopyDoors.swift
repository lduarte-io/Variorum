//
//  ProtectionCopyDoors.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U3 — THE TWO DOORS' ROADS, off the main actor (`notes/plans/vx-306-castle-open-road.md` §2 U3 + its
//  addendum; rules 17–21). Through the executor — the one thing that writes — on the open library
//  (`ProtectionRoadSession`). Nothing here decides: the catalogue says what a copy is, the executor says what opens it.
//
//    - THE LIST (`listing`) — the catalogue's copies (`CopyDoorsListing`), a READ.
//    - THE QUIET PROBE (`opensQuietly`) — `lookInside` with nothing typed: the copy's own quiet road on this Mac, a
//      READ (rule 17: Look inside writes nothing).
//    - THE PREFLIGHT (`preflight`) — every check before anything closes, all READS: the copy still catalogued; it
//      opens with what she typed (`lookInside`); its schema is one this build can open (`LibraryClassifier
//      .schemaVerdict`, on a private copy — a newer Variorum's copy is never landed); her current pair opens the library
//      open now (the words always; the passphrase when its lock exists). A typo never tears the window down.
//    - THE ACT (`makeMine`) — run by `AppBootstrap.makeThisMyLibrary` with the app's pool CLOSED (the swap's
//      precondition — `SQLCipherLibraryLeaf.swapStaged` refuses a WAL with frames): the RESTORE HOLD first, by the
//      core writer, exactly as 13x's `LibraryAdoption.execute(holding:)` writes it (before anything moves — nothing
//      ever lands un-held; a refusal before the swap puts the hold back as it stood); then the executor's
//      `makeThisMyLibrary` on its plan (rule 20); then TODAY'S STORE ID minted fresh beside the new library (a NEW
//      library — rule 17; the creation's own mint, `AppBootstrap.ensureStoreIdentity(fresh: true)`), so the rest of
//      the app keeps its footing. Past the swap (the commit point) the copy IS the library: an act that threw there
//      finishes at the next open's settle, and the door says it was made.
//    - THE PICK (`pick`) — a picked thing classified and, when it is this design's pair, filed (`PickedCopy`); a copy
//      already in this Mac's catalogue is used where it is; the open library itself is refused.
//    - LOOK INSIDE (`lookInside`, P-VX306-U3-15 — the orchestrator's ruling (b)) — the executor's `lookInside` for the
//      key, then `ProtectionCopyPeek`'s read-only reader on a private copy; nothing written.
//    The reads and the pick stand on a `CopyDoorsContext` — the open library's, or (the missing face, rule 27's lobby) the
//    road's system with no library open.
//

import Foundation
import VariorumCore

/// What the doors' READS and the pick stand on: the protection system, an executor configuration, and the library open
/// now (nil — none: the missing face, rule 27's lobby). Look inside needs no library open; Make this my library does.
nonisolated struct CopyDoorsContext: Sendable {
    let system: ProtectionSystem
    let configuration: ExecutorConfiguration
    let guards: ProtectionGuards
    /// The library open now (its copies are "this library's").
    let libraryID: String?

    /// The open library's (the session's executor stays the acts').
    init(_ session: ProtectionRoadSession) {
        system = session.system
        configuration = session.executor.configuration
        guards = session.executor.guards
        libraryID = session.library.record?.libraryID
    }

    /// No library open (VX-306 U3 — the missing face's and rule 27's *Open Library…*): the road's system alone.
    init(_ road: RoadContext) {
        system = road.system
        configuration = road.system.configuration(session: road.session)
        guards = .all
        libraryID = nil
    }

    /// An executor for the doors' READS — its own instance.
    func readExecutor() -> ProtectionExecutor {
        ProtectionExecutor(leaves: system.leaves, configuration: configuration, guards: guards)
    }
}

/// What a look's opening came to (VX-306 U3 — Look inside, P-VX306-U3-15).
nonisolated enum LookInsideOpening: Sendable {
    /// The copy, open read-only on a private copy — the reader is the look; closing it forgets.
    case opened(ProtectionCopyPeek.Reader)
    case refused(CopyDoorRefusal)
}

nonisolated enum ProtectionCopyDoors {
    // MARK: - The list

    static func listing(_ session: ProtectionRoadSession) -> CopyDoorsListing { listing(CopyDoorsContext(session)) }

    static func listing(_ ctx: CopyDoorsContext) -> CopyDoorsListing {
        let places = ctx.system.places
        return CopyDoorsListing.make(
            ctx.system.lister.catalog(), libraryID: ctx.libraryID, asOf: { asOf($0, places: places) })
    }

    /// A copy's day: a backup's stamp; the day a previous library stepped aside; an OPENED copy's own day (the filed
    /// store keeps the picked file's modification date — its folder's stamp is only the filing's).
    static func asOf(_ copy: CatalogCopy, places: ProtectionPlaces) -> Date? {
        switch copy.kind {
        case .backup, .previousLibrary:
            return copy.stamp
        case .adoptionSafetyCopy:
            let modified: Date?? = places.withFile(catalogID: copy.id) { url in
                (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
            }
            return (modified ?? nil) ?? copy.stamp
        }
    }

    // MARK: - The quiet probe (a READ)

    static func opensQuietly(_ session: ProtectionRoadSession, _ copy: CatalogCopy) -> Bool {
        opensQuietly(CopyDoorsContext(session), copy)
    }

    static func opensQuietly(_ ctx: CopyDoorsContext, _ copy: CatalogCopy) -> Bool {
        let catalog = ctx.system.lister.catalog()
        guard let current = catalog.copies.first(where: { $0.id == copy.id }) else { return false }
        return (try? ctx.readExecutor().lookInside(current, in: catalog)) != nil
    }

    // MARK: - Look inside (rule 17 — P-VX306-U3-15, the read-only facts sheet)

    /// The look's opening: the executor's `lookInside` (a READ — its own quiet road, or what she typed) hands the key;
    /// `ProtectionCopyPeek.open` byte-copies the catalogued file into a private folder and opens ONE read-only keyed
    /// connection on it. The key is not kept past this call (it lives only inside the connection). NOTHING is written:
    /// no key file, keychain item, record, memory item or defaults key — the private folder is the look's own, deleted
    /// at its close.
    static func lookInside(_ ctx: CopyDoorsContext, copy: CatalogCopy, typed: TypedSecrets) -> LookInsideOpening {
        let catalog = ctx.system.lister.catalog()
        guard let current = catalog.copies.first(where: { $0.id == copy.id }) else { return .refused(.copyGone) }
        let looked: LookedInside
        do {
            looked = try ctx.readExecutor().lookInside(current, in: catalog, typed: typed)
        } catch {
            return .refused(.copyDoesNotOpen)
        }
        let scratch = ctx.system.places.scratch
        do {
            let reader = try ctx.system.places.withFile(catalogID: current.id) {
                try ProtectionCopyPeek.open($0, key: looked.key, inside: scratch)
            }
            guard let reader else { return .refused(.copyGone) }
            ProtectionOpenRoad.log("road: a look inside a copy (\(current.kind.rawValue), road \(looked.road)) — read-only, nothing written")
            return .opened(reader)
        } catch {
            ProtectionOpenRoad.log("road: a look inside could not read the copy — \(String(describing: error))")
            return .refused(.unreadableCopy)
        }
    }

    // MARK: - The preflight (READS only)

    enum Preflight {
        case ready(CatalogCopy, Catalog)
        case refused(CopyDoorRefusal)
    }

    static func preflight(
        _ session: ProtectionRoadSession, row: CopyDoorRow, copySecrets: TypedSecrets, currentPair: TypedSecrets
    ) -> Preflight {
        let catalog = session.system.lister.catalog()
        guard let copy = catalog.copies.first(where: { $0.id == row.id }) else { return .refused(.copyGone) }
        let looked: LookedInside
        do {
            looked = try CopyDoorsContext(session).readExecutor().lookInside(copy, in: catalog, typed: copySecrets)
        } catch {
            return .refused(.copyDoesNotOpen)
        }
        // The copy's own schema, read on a private copy (the catalogued file is only read).
        let verdict = session.system.places.withFile(catalogID: copy.id) {
            LibraryClassifier.schemaVerdict(at: $0, key: looked.key)
        }
        switch verdict {
        case .current?, .behindThisBuild?: break
        case .newer?: return .refused(.newerCopy)
        default: return .refused(.unreadableCopy)
        }
        // Her current pair, against the library open now (the executor verifies it again inside the act).
        let library = session.library
        let floor = session.system.floor
        guard let file = library.keyFile, file.fingerprint == library.fingerprint else { return .refused(.failed) }
        if file.passphrase != nil {
            guard let passphrase = currentPair.passphrase,
                  (try? file.open(passphrase: .passphrase(passphrase), floor: floor)) == library.key
            else { return .refused(.passphraseDoesNotOpen) }
        }
        guard let words = currentPair.words, (try? file.open(.words(words), floor: floor)) == library.key else {
            return .refused(.wordsDoNotOpen)
        }
        return .ready(copy, catalog)
    }

    // MARK: - The act (the pool CLOSED — `AppBootstrap.makeThisMyLibrary`)

    struct MakeMineResult: Sendable {
        var outcome: CopyDoorOutcome
        /// The key to reopen with: the new library's, or — nothing swapped — the old one's.
        var reopenKey: StoreKey
    }

    static func makeMine(
        _ session: ProtectionRoadSession, copy: CatalogCopy, catalog: Catalog, row: CopyDoorRow,
        copySecrets: TypedSecrets, currentPair: TypedSecrets, mintStoreIdentity: @Sendable (StoreKey) -> Void
    ) async -> MakeMineResult {
        let slot = session.system.places.slot
        let oldKey = session.key
        let marker = LibraryRestoreHold.markerURL(besideStore: slot)
        let standing = try? Data(contentsOf: marker)
        // THE RESTORE HOLD, before anything moves (13x F1 R1-M2's order — a failed write refuses with nothing moved).
        do {
            try LibraryRestoreHold.set(besideStore: slot, asOf: row.asOf, now: Date())
        } catch {
            ProtectionOpenRoad.log("road: Make this my library refused — the restore hold could not be written (\(String(describing: error)))")
            return MakeMineResult(outcome: .refused(.failed), reopenKey: oldKey)
        }
        var library = session.library
        do {
            _ = try await session.executor.makeThisMyLibrary(
                &library, copy: copy, in: catalog, copySecrets: copySecrets, currentPair: currentPair)
        } catch {
            session.library = library
            if ProtectionLibraryFiles.opens(slot, key: oldKey) {
                // Nothing swapped — the library stands as it was, and so does the hold it had (none, or its own).
                restoreHold(standing, at: marker)
                ProtectionOpenRoad.log("road: Make this my library did nothing — \(String(describing: error))")
                return MakeMineResult(outcome: .refused(refusal(for: error)), reopenKey: oldKey)
            }
            // Past the swap (the commit point): the copy IS the library; the act's last steps finish at the next
            // open's settle (rule 20). The hold stays.
            ProtectionOpenRoad.log("road: Make this my library swapped, then stopped — the next open finishes it (\(String(describing: error)))")
        }
        session.library = library
        if ProtectionLibraryFiles.opens(slot, key: library.key) {
            // Today's store id, minted fresh for the NEW library (the creation's mint — rule 17: a fresh identity).
            mintStoreIdentity(library.key)
        }
        ProtectionOpenRoad.log(
            "road: made a copy this Mac's library — library \(String((library.record?.libraryID ?? "none").prefix(8))) "
                + "key \(StoreKeyEnvelope.shortFingerprint(library.fingerprint)); the previous one in Previous Libraries; held")
        return MakeMineResult(outcome: .made, reopenKey: library.key)
    }

    /// The hold put back as it stood before the door (removed when none stood).
    static func restoreHold(_ standing: Data?, at marker: URL) {
        if let standing {
            try? standing.write(to: marker, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: marker)
        }
    }

    static func refusal(for error: any Error) -> CopyDoorRefusal {
        switch error as? ExecutorRefusal {
        case .copyDoesNotOpen?: return .copyDoesNotOpen
        case .wordsDoNotOpen?: return .wordsDoNotOpen
        case .passphraseDoesNotOpen?, .secretMissing?: return .passphraseDoesNotOpen
        case .actInFlight?: return .busy
        default: return .failed
        }
    }

    // MARK: - The pick

    static func pick(_ url: URL, session: ProtectionRoadSession) -> PickOutcome { pick(url, CopyDoorsContext(session)) }

    static func pick(_ url: URL, _ ctx: CopyDoorsContext) -> PickOutcome {
        let places = ctx.system.places
        let libraryID = ctx.libraryID
        let picked = url.resolvingSymlinksInPath().standardizedFileURL.path
        let container = places.container.resolvingSymlinksInPath().standardizedFileURL.path
        if picked == container || picked == places.slot.resolvingSymlinksInPath().standardizedFileURL.path {
            return .refused(ProtectionWords.pickedLiveLibrary, detail: nil)
        }
        // Already one of this Mac's catalogued copies: used where it is (never filed twice).
        let catalog = ctx.system.lister.catalog()
        if picked.hasPrefix(container + "/") {
            let relative = String(picked.dropFirst(container.count + 1))
            let matches = catalog.copies.filter { copy in
                copy.place == .container
                    && ((copy.folders + [copy.name]).joined(separator: "/") == relative
                        || copy.folders.joined(separator: "/") == relative)
            }
            if matches.count == 1, let copy = matches.first {
                guard copy.library != nil else { return .refused(ProtectionWords.pickedCopyUnreadable, detail: nil) }
                return .copy(CopyDoorRow(copy: copy, isThisLibrary: copy.library == libraryID, asOf: asOf(copy, places: places)))
            }
        }
        switch PickedCopy.classify(url) {
        case .refused(let message, let detail):
            return .refused(message, detail: detail)
        case .several(let stores):
            return .several(stores)
        case .pair(let pair):
            let folder: URL
            do {
                folder = try PickedCopy.file(pair, places: places, now: Date())
            } catch {
                ProtectionOpenRoad.log("road: a picked copy could not be filed — \(String(describing: error))")
                return .refused(ProtectionWords.filingFailed, detail: String(describing: error))
            }
            let id = PickedCopy.filedCopyID(folder)
            guard let copy = ctx.system.lister.catalog().copies.first(where: { $0.id == id }), copy.library != nil else {
                return .refused(ProtectionWords.pickedCopyUnreadable, detail: nil)
            }
            ProtectionOpenRoad.log("road: a picked copy was filed into Backups/safety-copies/\(folder.lastPathComponent)")
            return .copy(CopyDoorRow(copy: copy, isThisLibrary: copy.library == libraryID, asOf: asOf(copy, places: places)))
        }
    }
}
