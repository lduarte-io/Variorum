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
//      READ (rule 17: Look inside writes nothing). AUTOMATIC — it runs as the confirm opens — so it reads only what
//      never prompts: the silent item and the Apple wrap (`CopyQuietRoads.withoutAPress`; the ladder's round-1 m2 — a
//      Touch ID item's read IS the system prompt). Touch ID only at her deliberate press of *Make this my library*,
//      and ONCE (VX-307 U2c, the VX-306 ladder's round-2 NIT 1 (i)): the preflight's look may read it; the act takes
//      the key that look opened (`makeThisMyLibrary(opened:)`) and never opens the copy again. The look's typed *Open*
//      never presses (round-2 NIT 1 (ii) — a wrong secret refuses in words).
//    - THE PREFLIGHT (`preflight`) — every check before anything closes, all READS: the copy still catalogued; it
//      opens with what she typed (`lookInside`); its schema is one this build can open (`LibraryClassifier
//      .schemaVerdict`, on a private copy — a newer Variorum's copy is never landed); her current pair opens the library
//      open now (the words always; the passphrase when its lock exists). A typo never tears the window down.
//    - THE ACT (`makeMine`) — run by `AppBootstrap.makeThisMyLibrary` with the app's pool CLOSED (the swap's
//      precondition — `SQLCipherLibraryLeaf.swapStaged` refuses a WAL with frames): the RESTORE HOLD first, by the
//      core writer, in the order 13x's adoption wrote it (before anything moves — nothing
//      ever lands un-held; a refusal before the swap puts the hold back as it stood); then the executor's
//      `makeThisMyLibrary` on its plan (rule 20). Past the swap (the commit point) the copy IS the library: an act
//      that threw there finishes at the next open's settle, and the door says it was made. (VX-329 U1: today's store id
//      minted beside the new library left with today's road.)
//    - THE PICK (`pick`) — a picked thing classified and, when it is this design's pair, filed (`PickedCopy`) — the
//      filing said on the copies-changed seam, so a standing Restore list shows it (ladder round 2, NIT 3); a copy
//      already in this Mac's catalogue is used where it is; the open library itself is refused.
//    - LOOK INSIDE (`lookInside`, P-VX306-U3-15 — the orchestrator's ruling (b)) — the executor's `lookInside` for the
//      key, then `ProtectionCopyPeek`'s read-only reader on a private copy; nothing written.
//    - VX-309 U1b — A PLAINTEXT EXPORT IN, AS A NEW LIBRARY (T-8 — the mapping ruled at the plan's §5b-R): the pick names it
//      (never filed); `readPlaintextExport` plans it (reads only, a private staged copy); `landPlaintextExport` sets what
//      stands aside whole, runs the creation's road and mints the export's content into the new store headless, before its
//      first open, through the import road (no restore hold — a fresh mint never synced).
//    - VX-309 U1b — THE EMPTY-SLOT LANDING (`makeMineInTheEmptySlot`, T-5): with no library open, the preflight's reads (the
//      copy opens with what she TYPED — a quiet road alone is refused, rule 14's precedent), the hold, what stands in the
//      slot set aside (never written over), the core's act.
//    The reads and the pick stand on a `CopyDoorsContext` — the open library's, or (the missing face, rule 27's lobby) the
//    road's system with no library open.
//

import Dependencies
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

    /// VX-309 U1b — an executor for an act with NO library open (T-5's empty-slot landing): its own instance over the
    /// road's leaves (the act names its new library itself).
    func actExecutor() -> ProtectionExecutor {
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
            ctx.system.lister.catalog(), libraryID: ctx.libraryID, protected: protectedFromDelete(ctx),
            asOf: { asOf($0, places: places) })
    }

    /// VX-309 U1c — the libraries rule 19's delete is never offered for (beyond the open library, which is never another's):
    /// with NO library open, every library this Mac remembers (the library missing from the slot — its copies are what the
    /// empty-slot landing lands from; the core act's own exclusion, P-VX309-U1c-2); and, while a library STANDS in the slot
    /// (rule 27's lobby — its ID inside the file no key opens), every library: any of them could be it (the core act refuses
    /// there too). A read that fails offers no delete at all (never a guess).
    static func protectedFromDelete(_ ctx: CopyDoorsContext) -> Set<String> {
        if let open = ctx.libraryID { return [open] }
        let everyLibrary = Set(ctx.system.lister.catalog().copies.compactMap(\.library))
        guard (try? ctx.system.leaves.library.slotIsOccupied()) == false,
              let remembered = try? ctx.system.leaves.memory.rememberedLibraryIDs() else { return everyLibrary }
        return remembered
    }

    // MARK: - VX-309 U1c — VX-265: rule 19's delete (one other library's copies, at her confirmed press)

    /// **With a library open** (Data Safety's Restore list): the core's planned act on the OPEN session (`offerDelete` —
    /// one act at a time), over a FRESH catalogue read at the press: what goes is THIS Mac's copies of `libraryID` now
    /// (`OwnCopies.thisMacsCopies` — the act's own fence re-applies it). Never the open library. The copies-changed seam is
    /// said, so every standing list re-reads.
    static func deleteCopies(_ session: ProtectionRoadSession, libraryID: String) async -> CopyDeleteOutcome {
        guard session.writes, libraryID != session.library.record?.libraryID else { return .refused(.deleteFailed) }
        guard session.beginAct() else { return .refused(.busy) }
        defer { session.endAct() }
        let catalog = session.system.lister.catalog()
        let mine = OwnCopies.thisMacsCopies(ofLibrary: libraryID, in: catalog)
        guard !mine.isEmpty else { return .refused(.copyGone) }
        var library = session.library
        do {
            _ = try await session.executor.offerDelete(&library, copies: mine, catalog: catalog)
        } catch {
            session.library = library
            ProtectionOpenRoad.log("road: another library's copies were not deleted — \(String(describing: error))")
            tellCopiesChanged()
            return .refused(refusal(for: error) == .busy ? .busy : .deleteFailed)
        }
        session.library = library
        tellCopiesChanged()
        ProtectionOpenRoad.log(
            "road: deleted \(mine.count) of another library's copies on this Mac — library \(ProtectionNames.library8(libraryID))")
        return .deleted(mine.count)
    }

    /// **With NO library open** (the empty-slot listing — the missing face, rule 27's lobby): the core's no-library road
    /// (`offerDeleteWithNoLibraryOpen` — the same fence, never a library this Mac remembers), over a fresh catalogue read.
    static func deleteCopies(_ ctx: CopyDoorsContext, libraryID: String) -> CopyDeleteOutcome {
        let catalog = ctx.system.lister.catalog()
        let deleted: [String]
        do {
            deleted = try ctx.actExecutor().offerDeleteWithNoLibraryOpen(
                copies: catalog.copies(ofLibrary: libraryID), catalog: catalog)
        } catch ExecutorRefusal.nothingToDo {
            return .refused(.copyGone)
        } catch {
            ProtectionOpenRoad.log("road: another library's copies were not deleted (no library open) — \(String(describing: error))")
            tellCopiesChanged()
            return .refused(.deleteFailed)
        }
        tellCopiesChanged()
        ProtectionOpenRoad.log(
            "road: deleted \(deleted.count) of another library's copies on this Mac (no library open) — library "
                + ProtectionNames.library8(libraryID))
        return .deleted(deleted.count)
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
        // The confirm's automatic probe — never a press (m2).
        return (try? ctx.readExecutor().lookInside(current, in: catalog, quietRoads: .withoutAPress)) != nil
    }

    // MARK: - Look inside (rule 17 — P-VX306-U3-15, the read-only facts sheet)

    /// The look's opening: the executor's `lookInside` (a READ — its own quiet road, or what she typed) hands the key;
    /// `ProtectionCopyPeek.open` byte-copies the catalogued file into a private folder and opens ONE read-only keyed
    /// connection on it. The key is not kept past this call (it lives only inside the connection). NOTHING is written:
    /// no key file, keychain item, record, memory item or defaults key — the private folder is the look's own, deleted
    /// at its close. `quietRoads`: the look's first try, as its sheet opens, is AUTOMATIC — `.withoutAPress` (the
    /// default: the silent item and the Apple wrap, never a Touch ID prompt — m2); her typed *Open* is a press.
    static func lookInside(
        _ ctx: CopyDoorsContext, copy: CatalogCopy, typed: TypedSecrets, quietRoads: CopyQuietRoads = .withoutAPress
    ) -> LookInsideOpening {
        let catalog = ctx.system.lister.catalog()
        guard let current = catalog.copies.first(where: { $0.id == copy.id }) else { return .refused(.copyGone) }
        let looked: LookedInside
        do {
            looked = try ctx.readExecutor().lookInside(current, in: catalog, typed: typed, quietRoads: quietRoads)
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
        /// Every check passed: the copy, the catalogue read, and the look that OPENED it at her press — handed to the
        /// act, so her one press opens the copy once (VX-307 U2c — never a second Touch ID prompt).
        case ready(CatalogCopy, Catalog, LookedInside)
        case refused(CopyDoorRefusal)
    }

    static func preflight(
        _ session: ProtectionRoadSession, row: CopyDoorRow, copySecrets: TypedSecrets, currentPair: TypedSecrets
    ) -> Preflight {
        let catalog = session.system.lister.catalog()
        guard let copy = catalog.copies.first(where: { $0.id == row.id }) else { return .refused(.copyGone) }
        let looked: LookedInside
        do {
            // Her press of *Make this my library* — the copy's own quiet roads, Touch ID's included (m2).
            looked = try CopyDoorsContext(session).readExecutor().lookInside(
                copy, in: catalog, typed: copySecrets, quietRoads: .includingTouchID)
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
        return .ready(copy, catalog, looked)
    }

    // MARK: - The act (the pool CLOSED — `AppBootstrap.makeThisMyLibrary`)

    struct MakeMineResult: Sendable {
        var outcome: CopyDoorOutcome
        /// The key to reopen with: the new library's, or — nothing swapped — the old one's.
        var reopenKey: StoreKey
    }

    /// `opened`: the preflight's look at her press — the act takes ITS key (re-verified against the copy's file, a read
    /// that never prompts) instead of opening the copy a second time (VX-307 U2c — one Touch ID press, never two).
    /// VX-309 U1c — VX-444: `wordsLedger` (the band card's ledger — the bootstrap's; nil: none) carries the outgoing
    /// library's words marks onto the new library's id once the copy IS the library (rule 17: under the current pair).
    /// VX-529 L2 — VX-523 (her R-529-7): signed in, ONE read of the account's vault answered within `bound` (VX-501's race,
    /// the standing bound) — READ before anything moves, handed to the core act as the caller's read
    /// (`AccountsVaultRead.taken`), which writes the join's two proof fields only where the current pair's words open it.
    /// Offline, a slow server, no vault, signed out: nil — today's key file, byte for byte.
    static func makeMine(
        _ session: ProtectionRoadSession, copy: CatalogCopy, catalog: Catalog, row: CopyDoorRow,
        opened: LookedInside, currentPair: TypedSecrets, wordsLedger: WordsCardLedger? = nil,
        vaultWithin bound: Duration = ProtectionOpenRoad.typedUnlockVaultBound
    ) async -> MakeMineResult {
        let slot = session.system.places.slot
        let oldKey = session.key
        let outgoingID = session.library.record?.libraryID
        let marker = LibraryRestoreHold.markerURL(besideStore: slot)
        let standing = try? Data(contentsOf: marker)
        let accountsVault = await proofVaultRead(session, within: bound)
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
                &library, opened: opened, copy: copy, in: catalog, currentPair: currentPair,
                accountsVault: .taken(accountsVault))
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
        // VX-444: the pair carried, so do its words marks (the card never re-offers words she already recorded).
        if let outgoingID, let landedID = library.record?.libraryID, landedID != outgoingID {
            wordsLedger?.carry(from: outgoingID, to: landedID)
        }
        ProtectionOpenRoad.log(
            "road: made a copy this Mac's library — library \(String((library.record?.libraryID ?? "none").prefix(8))) "
                + "key \(KeyFingerprint.short(library.fingerprint)); the previous one in Previous Libraries; held")
        return MakeMineResult(outcome: .made, reopenKey: library.key)
    }

    /// VX-523 — Make this my library's ONE read of the signed-in account's vault (as the executor is signed in), answered
    /// within `bound` or not at all (`ProtectionOpenRoad.boundedVaultRead` — a later answer is dropped). nil: a read-only
    /// road (a hosted test run reads nothing), signed out, no vault, a failure, the bound passed.
    static func proofVaultRead(_ session: ProtectionRoadSession, within bound: Duration) async -> VaultSnapshot? {
        guard session.writes, let account = session.executor.configuration.session.accountID else { return nil }
        switch await ProtectionOpenRoad.boundedVaultRead(session.system.leaves.vault, accountID: account, within: bound) {
        case .read(let snapshot):
            if snapshot == nil { ProtectionOpenRoad.log("road: Make this my library found no vault for the signed-in account") }
            return snapshot
        case .failed(let error):
            ProtectionOpenRoad.log("road: Make this my library's vault read failed — \(String(describing: error)); "
                + "today's key file")
            return nil
        case .timedOut:
            ProtectionOpenRoad.log("road: Make this my library's vault read took longer than \(bound) — today's key file")
            return nil
        }
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

    // MARK: - VX-309 U1b — T-5: Make this my library into the EMPTY slot (no library open)

    /// What the empty-slot landing came to: the outcome, and the new library's key when one landed (nil: nothing did — or
    /// the act stopped past its swap, and the reopen finds the new library by its silent item).
    struct EmptySlotResult: Sendable {
        var outcome: CopyDoorOutcome
        var key: StoreKey?
    }

    /// **The landing with NO library open** (the missing face, rule 27's lobby — run by `AppBootstrap
    /// .makeThisMyLibraryInTheEmptySlot`; no pool is open on the slot). THE PREFLIGHT, all reads, before anything moves: the
    /// copy still catalogued; it opens with WHAT SHE TYPED (rule 14's precedent — a quiet road alone carries no pair, so it
    /// is refused like a wrong secret); its schema one this build opens. Then, in 13x's order: THE RESTORE HOLD first (the
    /// core writer — nothing lands un-held); WHAT STANDS IN THE SLOT steps aside, never written over — exactly the faces'
    /// *Start a New Library* pre-steps (rule 27's library no key file opens moves WHOLE, P-VX306-U2-5; else a missing
    /// library's key file still in the live place moves alone, P-VX306-U1b-3); then the core's act
    /// (`makeThisMyLibraryInTheEmptySlot` — a NEW library, nothing of the slot's to step aside). Nothing landed ⇒ the hold put
    /// back as it stood (what stepped aside stays aside, in
    /// Previous Libraries). The twelve words minted for a passphrase-opened copy are DROPPED here, never logged — the card
    /// above the quick entry offers fresh ones at the first look (rule 2; the Mac's creation idiom).
    /// VX-309 U1c — F-U1b-5 (VX-444's second half): `wordsLedger` marks the new library's words RECORDED when the copy's own
    /// TYPED WORDS became its words lock (she just typed them); with its passphrase the words are minted fresh and dropped
    /// unseen, so nothing is marked and the card offers them.
    static func makeMineInTheEmptySlot(
        _ ctx: CopyDoorsContext, row: CopyDoorRow, copySecrets: TypedSecrets, wordsLedger: WordsCardLedger? = nil
    ) async -> EmptySlotResult {
        let places = ctx.system.places
        let catalog = ctx.system.lister.catalog()
        guard let copy = catalog.copies.first(where: { $0.id == row.id }) else {
            return EmptySlotResult(outcome: .refused(.copyGone), key: nil)
        }
        let looked: LookedInside
        do {
            looked = try ctx.readExecutor().lookInside(copy, in: catalog, typed: copySecrets, quietRoads: .withoutAPress)
        } catch {
            return EmptySlotResult(outcome: .refused(.copyDoesNotOpen), key: nil)
        }
        if case .quietRoad = looked.road { return EmptySlotResult(outcome: .refused(.copyDoesNotOpen), key: nil) }
        let verdict = places.withFile(catalogID: copy.id, { LibraryClassifier.schemaVerdict(at: $0, key: looked.key) })
        switch verdict {
        case .current?, .behindThisBuild?: break
        case .newer?: return EmptySlotResult(outcome: .refused(.newerCopy), key: nil)
        default:
            // Said, never swallowed — the refusal's sentence stays one honest line; the reason is the log's.
            ProtectionOpenRoad.log(
                "road: Make this my library (empty slot) refused — the copy's schema could not be read "
                    + "(\(verdict.map { String(describing: $0) } ?? "the copy's file could not be resolved"))")
            return EmptySlotResult(outcome: .refused(.unreadableCopy), key: nil)
        }
        let marker = LibraryRestoreHold.markerURL(besideStore: places.slot)
        let standing = try? Data(contentsOf: marker)
        do {
            try LibraryRestoreHold.set(besideStore: places.slot, asOf: row.asOf, now: Date())
        } catch {
            ProtectionOpenRoad.log("road: Make this my library (empty slot) refused — the restore hold could not be written (\(String(describing: error)))")
            return EmptySlotResult(outcome: .refused(.failed), key: nil)
        }
        do {
            try ProtectionOpenRoad.setAsideUnopenableLibraryFor(places)
            try ProtectionOpenRoad.setAsideLiveKeyFileFor(places)
        } catch {
            restoreHold(standing, at: marker)
            ProtectionOpenRoad.log("road: Make this my library (empty slot) refused — what stood in the slot could not step aside (\(String(describing: error)))")
            return EmptySlotResult(outcome: .refused(.failed), key: nil)
        }
        let landed: LandedCopy
        do {
            landed = try await ctx.actExecutor().makeThisMyLibraryInTheEmptySlot(copy: copy, in: catalog, typed: copySecrets)
        } catch {
            if (try? ctx.system.leaves.library.slotIsOccupied()) == true {
                // Past the swap (the commit point): the copy IS the library; its plan finishes at the next open, which
                // finds it by its silent item. The hold stays.
                ProtectionOpenRoad.log("road: Make this my library (empty slot) swapped, then stopped — the next open finishes it (\(String(describing: error)))")
                return EmptySlotResult(outcome: .made, key: nil)
            }
            restoreHold(standing, at: marker)
            ProtectionOpenRoad.log("road: Make this my library (empty slot) did nothing — \(String(describing: error))")
            return EmptySlotResult(outcome: .refused(refusal(for: error)), key: nil)
        }
        // F-U1b-5: her typed words ARE the new library's words — recorded (the card never offers words she just typed).
        if landed.mintedWords == nil, let landedID = landed.library.record?.libraryID { wordsLedger?.record(landedID) }
        ProtectionOpenRoad.log(
            "road: a copy landed in the empty slot — library \(String((landed.library.record?.libraryID ?? "none").prefix(8))) "
                + "key \(KeyFingerprint.short(landed.library.fingerprint)); nothing stepped aside; held"
                + (landed.mintedWords == nil ? "" : "; its words wait for her look"))
        return EmptySlotResult(outcome: .made, key: landed.library.key)
    }

    // MARK: - VX-309 U1b — T-8: a plaintext export brought in as a NEW library

    enum PlaintextExportRead: Sendable {
        case plan(PlaintextExportPlan)
        case refused(CopyDoorRefusal)
    }

    /// THE PREFLIGHT, reads only (before anything moves — with a library open, before the window comes down): the picked
    /// thing is a plaintext export, and its content plans on a private staged copy — this build's schema or an earlier
    /// one's (the subset rule — VX-502 (her ratified rule, 2026-10-27; supersedes P-VX309-U1b-7)). A NEWER build's export
    /// never plans here, and never gets the newer words from here either: the classifier answers `.newerSchema` before it
    /// tells export from library, so this returns `.refused(.unreadableCopy)` for it — the PICK (`PickedCopy.classify`)
    /// is what refuses it in `LibraryOpenCopy.newerSchemaRefusal`'s words. The `schemaNewer` catch below answers only a
    /// file that gains an unknown identifier between this function's own two staged reads.
    static func readPlaintextExport(_ url: URL) -> PlaintextExportRead {
        guard case .plaintextExport(let store) = LibraryClassifier.classify(at: url) else {
            return .refused(.unreadableCopy)
        }
        do {
            return .plan(try PlaintextExportReading.read(exportAt: store))
        } catch PlaintextExportReading.Failure.schemaNewer {
            return .refused(.exportRefused(LibraryOpenCopy.newerSchemaRefusal))
        } catch PlaintextExportReading.Failure.unreadableNote(let title, let line) {
            return .refused(.exportRefused(ProtectionWords.exportNoteUnreadable(title, line: line)))
        } catch {
            ProtectionOpenRoad.log("road: a plaintext export could not be read — \(String(describing: error))")
            return .refused(.unreadableCopy)
        }
    }

    /// What the bring-in came to: the new library's session and its once-shown words (the creation's — the band offers
    /// them), what landed, and whether the import stopped part of the way; or why nothing was made.
    struct PlaintextLanding: Sendable {
        var created: (session: ProtectionRoadSession, words: OnceShownWords)?
        var landing = PlaintextExportLanding()
        var stoppedEarly = false
        var refusal: CopyDoorRefusal?
    }

    /// THE ACT (writes; with a library open, its pool already CLOSED by the bootstrap): what stands in the slot steps aside
    /// WHOLE into Previous Libraries — the library, its sidecars, its key file and its restore hold (the hold is THAT
    /// library's) — else a missing library's key file alone; any hold still standing goes (T-8's new library is never held
    /// — a fresh mint never synced, the ruling); the creation's road (`ProtectionOpenRoad.create` — fresh identity, key and
    /// device ID, Standard, its words for the band); then the export's content minted into the NEW store HEADLESS, before
    /// its first open, through the import road (`Operations.importPlaintextExport` — no undo stack: a library's birth); the
    /// store's pool closed. The end says what landed (the log line here; the receipt the caller owes) — a partial landing
    /// is visible against it (the ruling's one requirement on the crash window, PROVISIONAL P-VX309-U1b-8).
    /// `outgoing` (VX-488 R1 F1): the library OPEN when the landing began (nil from the no-library faces) — the session whose
    /// record names the account whose hold must leave with it.
    static func landPlaintextExport(
        _ ctx: RoadContext, plan: PlaintextExportPlan, outgoing: ProtectionRoadSession? = nil
    ) async -> PlaintextLanding {
        let places = ctx.system.places
        var result = PlaintextLanding()
        // A read-only road (a hosted test run's) never creates — so nothing steps aside for a creation that cannot land.
        guard ctx.writes else {
            result.refusal = .failed
            return result
        }
        do {
            try ProtectionOpenRoad.setAsideLibraryWholeFor(places, carryingHold: true)
            try ProtectionOpenRoad.setAsideLiveKeyFileFor(places)
        } catch {
            ProtectionOpenRoad.log("road: a plaintext export was not brought in — what stood in the slot could not step aside (\(String(describing: error)))")
            result.refusal = .failed
            return result
        }
        LibraryRestoreHold.clear(besideStore: places.slot)
        guard case .created(let session, let words) = await ProtectionOpenRoad.create(ctx, setAsideLiveKeyFile: false) else {
            result.refusal = .failed
            return result
        }
        result.created = (session, words)
        // VX-488 R1 F1 — the third clear: the library that was OPEN has stepped aside and a new one (no account) stands, so
        // its account's session hold leaves with it — its record is still in hand in its session (only its files left the
        // slot). With the process's one sync-keys leaf (VX-487 F-M1-1) nothing else would ever clear it.
        if let outgoing { ProtectionRoadLock.dropSessionMemory(outgoing) }
        // What the export holds, said BEFORE the import — a crash part of the way leaves this line without the end's, so
        // what landed reads against what was to land (the ruling's requirement on the crash window).
        ProtectionOpenRoad.log(
            "road: bringing in a plaintext export — it holds \(plan.books.count) books · \(plan.notes.count) notes · "
                + "\(plan.pools.count) snippet groups · \(plan.wings.count) wings")
        final class Box: @unchecked Sendable { var landing = PlaintextExportLanding() }
        let box = Box()
        do {
            let database = try AppDatabase.onDisk(url: places.slot, key: session.key)
            do {
                _ = try withDependencies {
                    $0.database = database
                    $0.uuid = .init { UUID() }
                    $0.date = .init { Date() }
                    $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
                } operation: {
                    try Operations().importPlaintextExport(plan, landed: { box.landing = $0 })
                }
            } catch {
                result.stoppedEarly = true
                ProtectionOpenRoad.log("road: the plaintext export's import stopped — \(String(describing: error))")
            }
            let (_, binding) = database.asRebindable()
            binding.lock()
        } catch {
            result.stoppedEarly = true
            ProtectionOpenRoad.log("road: the new library's store could not be opened for the import — \(String(describing: error))")
        }
        result.landing = box.landing
        let landed = box.landing
        ProtectionOpenRoad.log(
            "road: a plaintext export brought in as a new library — \(landed.books) books · \(landed.notes) notes · "
                + "\(landed.snippets) snippet groups · \(landed.wings) wings; empty books left out \(landed.emptyBooks.count); "
                + "memberships left out \(landed.membershipsLeftOut)\(result.stoppedEarly ? "; STOPPED part of the way" : "")")
        return result
    }

    // MARK: - The pick

    /// This Mac's catalogued copies changed — said on the main actor (`CopyDoorsListModel.copiesChanged`, the ladder's
    /// round-1 m4 seam the backup hook posts on), so every standing Restore list re-reads.
    static func tellCopiesChanged() {
        Task { @MainActor in NotificationCenter.default.post(name: CopyDoorsListModel.copiesChanged, object: nil) }
    }

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
        case .plaintextExport(let store):
            // VX-309 U1b — T-8: a plaintext export is brought in through the import road, never filed or adopted.
            return .plaintextExport(store)
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
            // The filing LANDED a copy in this Mac's safety copies (P-VX306-U3-0 — it stays listed): say so on m4's seam,
            // so a standing Restore list re-reads and shows it now, not at the pane's next opening (ladder r2 NIT 3).
            tellCopiesChanged()
            let id = PickedCopy.filedCopyID(folder)
            guard let copy = ctx.system.lister.catalog().copies.first(where: { $0.id == id }), copy.library != nil else {
                return .refused(ProtectionWords.pickedCopyUnreadable, detail: nil)
            }
            ProtectionOpenRoad.log("road: a picked copy was filed into Backups/safety-copies/\(folder.lastPathComponent)")
            return .copy(CopyDoorRow(copy: copy, isThisLibrary: copy.library == libraryID, asOf: asOf(copy, places: places)))
        }
    }
}
