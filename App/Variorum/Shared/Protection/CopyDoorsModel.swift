//
//  CopyDoorsModel.swift
//  Variorum (shared: Mac + Mobile — the phone's faces are later; the brain is one)
//
//  VX-306 U3 — THE TWO DOORS' BRAIN (`notes/plans/vx-306-castle-open-road.md` §2 U3 + its addendum; the contract
//  `notes/CastleRules.md` rules 17–19): a copy is a copy. Every act is an injected road (the bootstrap's, through the
//  executor's `lookInside` / `makeThisMyLibrary` off the main actor; a test's, planted), so the model is testable with
//  no keychain and no disk. No rule of its own: the catalogue says what a copy is, the executor says what opens it.
//
//    - THE RESTORE LIST (`CopyDoorsListing`, pure): the catalogue's copies OF THIS LIBRARY first, newest first; then
//      every other library's catalogued copy on this Mac (rule 19: "Copies of other libraries are listed"; §7c (8):
//      the library that stepped aside is "where you can look inside it or make it your library again" — PROVISIONAL
//      P-VX306-U3-1). A copy no format-3 key file names is not listed (rule 26: a copy from before this design is not
//      handled — and nothing could open it).
//    - MAKE THIS MY LIBRARY (`MakeMineModel` — §7c (8)): one confirmed door. The copy's own quiet road is tried first
//      (a READ); when it doesn't open the copy, the copy's own secret is asked — and an empty field tries her own
//      pair (rule 4: "your current ones open older backups of the same library"; PROVISIONAL P-VX306-U3-4). Her
//      current pair is ALWAYS typed (the words; the passphrase when one is set) — the executor requires it ("under
//      your current pair"), and her ruling: no keys carried, no choice of posture at the door.
//    - A PICKED THING (`CopyDoorsModel.begin(picked:)`): classified; a pair or a library folder is FILED FIRST into
//      this Mac's `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (P-VX306-U3-0 (a), the orchestrator's
//      ruling) and the doors then act on the catalogued copy; anything else is the honest refusal.
//    - LOOK INSIDE (`LookInsideModel` — the orchestrator's ruling P-VX306-U3-15, (b) the read-only facts sheet): on
//      every row and every picked copy. MAKE THIS MY LIBRARY with a library open (her current pair) AND — VX-309 U1b, T-5
//      — with none (the missing face, rule 27's lobby: `CopyDoorsRoads.landsInTheEmptySlot`): there the copy lands in the
//      empty slot as a new library under the secret typed FOR IT — its own passphrase or twelve words, always asked
//      (rule 14's precedent: a quiet road alone carries no pair to lock it under).
//

import Foundation
import Observation
import VariorumCore

// MARK: - The rows

/// One catalogued copy a door can act on.
nonisolated struct CopyDoorRow: Equatable, Sendable, Identifiable {
    let copy: CatalogCopy
    /// The copy is of the library open now.
    let isThisLibrary: Bool
    /// The day it is "as of": a backup's stamp, the day a previous library stepped aside, an opened copy's own day.
    let asOf: Date?

    var id: String { copy.id }
    var kind: CopyKind { copy.kind }
}

/// VX-309 U1c — VX-265: ONE other library's delete choice, as the listing knows it (rule 19: "Copies of other libraries are
/// listed and can be deleted" — one library's copies at a time, never bundled with any other act).
nonisolated struct CopyDeleteChoice: Equatable, Sendable {
    let libraryID: String
    /// What goes: THIS Mac's copies of it (`OwnCopies.thisMacsCopies` — the act's own fence, read here for the confirm).
    let copyIDs: [String]
    let backups: Int
    let previousLibraries: Int
    let openedCopies: Int
    /// The library's day as the listing knows it — its newest listed copy's.
    let newest: Date?
    /// Its listed copies that stay: another Mac's in a shared folder, or a far copy outside any Mac's subfolder.
    let staying: Int

    var count: Int { copyIDs.count }
}

/// The Restore list — the catalogue's copies, grouped and ordered. Pure.
nonisolated struct CopyDoorsListing: Equatable, Sendable {
    var thisLibrary: [CopyDoorRow]
    var otherLibraries: [CopyDoorRow]
    /// VX-309 U1c — VX-265: each OTHER library's delete choice, by library ID — present only where this Mac holds a copy
    /// of it to delete (P-2: a door that cannot act is not rendered), never for a protected library.
    var deleteChoices: [String: CopyDeleteChoice] = [:]
    /// VX-309 U1c — VX-210: the copies Variorum leaves as they are — a library-shaped file in a place no build of this
    /// design writes (today's flat backups, a folder she made), a copy no key file names (rule 26), a far copy outside any
    /// Mac's subfolder. The listing's one honest line renders only when this is above zero.
    var unmanagedCopies = 0

    static let empty = CopyDoorsListing(thisLibrary: [], otherLibraries: [])

    var isEmpty: Bool { thisLibrary.isEmpty && otherLibraries.isEmpty }
    var all: [CopyDoorRow] { thisLibrary + otherLibraries }

    /// A row's delete choice (its library's; nil: no *Delete…* on this row).
    func deleteChoice(for row: CopyDoorRow) -> CopyDeleteChoice? {
        guard !row.isThisLibrary, let library = row.copy.library else { return nil }
        return deleteChoices[library]
    }

    /// The listing of `catalog` for the library `libraryID` (nil: none open — every copy is another library's).
    /// `asOf`: a copy's day (the road reads an opened copy's own day from its file). `protected`: libraries never offered
    /// a delete (VX-309 U1c — with no library open, the ones this Mac remembers; the open library never is).
    static func make(
        _ catalog: Catalog, libraryID: String?, protected: Set<String> = [], asOf: (CatalogCopy) -> Date? = { $0.stamp }
    ) -> CopyDoorsListing {
        var mine: [CopyDoorRow] = []
        var others: [CopyDoorRow] = []
        for copy in catalog.copies {
            // Rule 26: a copy no format-3 key file names (a pre-design copy, or one whose key file can't be read)
            // is not listed — nothing here could open it.
            guard let library = copy.library else { continue }
            let row = CopyDoorRow(copy: copy, isThisLibrary: library == libraryID, asOf: asOf(copy))
            if row.isThisLibrary { mine.append(row) } else { others.append(row) }
        }
        var listing = CopyDoorsListing(thisLibrary: newestFirst(mine), otherLibraries: newestFirst(others))
        listing.deleteChoices = deleteChoices(catalog, rows: listing.otherLibraries, protected: protected)
        listing.unmanagedCopies = unmanagedCopies(in: catalog)
        return listing
    }

    /// VX-265: each other library's choice — this Mac's copies of it (the core's one fence), counted by kind; none for a
    /// protected library or one this Mac holds no copy of.
    static func deleteChoices(
        _ catalog: Catalog, rows: [CopyDoorRow], protected: Set<String>
    ) -> [String: CopyDeleteChoice] {
        var choices: [String: CopyDeleteChoice] = [:]
        for library in Set(rows.compactMap(\.copy.library)) where !protected.contains(library) {
            let mine = OwnCopies.thisMacsCopies(ofLibrary: library, in: catalog)
            guard !mine.isEmpty else { continue }
            let listed = rows.filter { $0.copy.library == library }
            let ids = Set(mine.map(\.id))
            choices[library] = CopyDeleteChoice(
                libraryID: library, copyIDs: ids.sorted(),
                backups: mine.filter { $0.kind == .backup }.count,
                previousLibraries: mine.filter { $0.kind == .previousLibrary }.count,
                openedCopies: mine.filter { $0.kind == .adoptionSafetyCopy }.count,
                newest: listed.compactMap(\.asOf).max(),
                staying: listed.filter { !ids.contains($0.id) }.count)
        }
        return choices
    }

    /// VX-210: how many copies the catalogue sees that Variorum leaves as they are — a library-shaped file (`.sqlite`) in a
    /// place no build of this design writes (`Catalog.foreign`: today's flat backups, the A1 rail's copies, a folder she
    /// made), a copy no format-3 key file names (rule 26 — never listed), a far copy outside any Mac's subfolder
    /// (`unattributed` — no Mac here claims it). Pure.
    static func unmanagedCopies(in catalog: Catalog) -> Int {
        catalog.foreign.filter { $0.name.hasSuffix(".sqlite") }.count
            + catalog.copies.filter { $0.library == nil || ($0.place == .farFolder && $0.mac == .unattributed) }.count
    }

    /// Newest first; an undated copy last; ties by id (a stable order).
    static func newestFirst(_ rows: [CopyDoorRow]) -> [CopyDoorRow] {
        rows.sorted { a, b in
            switch (a.asOf, b.asOf) {
            case let (x?, y?) where x != y: return x > y
            case (.some, nil): return true
            case (nil, .some): return false
            default: return a.id < b.id
            }
        }
    }
}

// MARK: - What a door can say

/// Why a door did nothing — each one a sentence (`ProtectionWords`).
nonisolated enum CopyDoorRefusal: Equatable, Sendable {
    /// Nothing typed and no quiet road on this Mac opens the copy (rule 17).
    case copyDoesNotOpen
    /// The copy left its place between the list and the press.
    case copyGone
    /// Her twelve words, missing or not opening the library open now.
    case wordsDoNotOpen
    case wordsInvalid(RecoveryPhraseError)
    /// Her passphrase, missing or not opening the library open now.
    case passphraseDoesNotOpen
    /// The copy was written by a newer Variorum (its schema's own check — never landed).
    case newerCopy
    /// The copy opens but can't be read as a library.
    case unreadableCopy
    /// Another act on the library is running (one at a time).
    case busy
    /// Anything else — nothing moved, or the act rolled back whole.
    case failed
    /// VX-309 U1b — T-8: a plaintext export that cannot be brought in, said in its own words (the export's schema, a note
    /// the format cannot read back — named).
    case exportRefused(String)
    /// VX-309 U1c — rule 19's delete could not finish (a file that would not go; the act refused).
    case deleteFailed

    var sentence: String {
        switch self {
        case .copyDoesNotOpen: return ProtectionWords.copyDoesNotOpen
        case .copyGone: return ProtectionWords.copyGone
        case .wordsDoNotOpen: return ProtectionWords.wordsDoNotOpen
        case .wordsInvalid(let error): return ProtectionOpenRoad.sentence(for: error)
        case .passphraseDoesNotOpen: return ProtectionWords.passphraseDoesNotOpen
        case .newerCopy: return LibraryOpenCopy.newerSchemaRefusal
        case .unreadableCopy: return LibraryOpenCopy.unreadableRefusal
        case .busy: return ProtectionWords.copyDoorBusy
        case .failed: return ProtectionWords.makeMineFailed
        case .exportRefused(let sentence): return sentence
        case .deleteFailed: return ProtectionWords.deleteCopiesFailed
        }
    }
}

nonisolated enum CopyDoorOutcome: Equatable, Sendable {
    case made
    case refused(CopyDoorRefusal)
}

/// VX-309 U1c — what rule 19's delete came to: how many copies went, or why none did.
nonisolated enum CopyDeleteOutcome: Equatable, Sendable {
    case deleted(Int)
    case refused(CopyDoorRefusal)
}

/// What a picked thing came to (the road classifies and files it — `PickedCopy`).
nonisolated enum PickOutcome: Equatable, Sendable {
    /// A pair or library folder, now catalogued (filed first, or already one of the catalogue's).
    case copy(CopyDoorRow)
    /// A folder holding several stores — offered, never guessed.
    case several([URL])
    /// The honest refusal (its detail quiet).
    case refused(String, detail: String?)
    /// VX-309 U1b — T-8: a plaintext export, offered to be brought in as a new library (never filed).
    case plaintextExport(URL)
}

// MARK: - The roads

/// Every act the doors take, injected (the bootstrap's on the new road; a test's, planted). Main-actor closures that
/// hop off it for their reads and writes.
struct CopyDoorsRoads {
    /// The Restore list now (a READ — the catalogue).
    var listing: @MainActor () async -> CopyDoorsListing
    /// Whether the copy opens by a quiet road on this Mac with nothing typed (a READ — Look inside's own road).
    var opensQuietly: @MainActor (CatalogCopy) async -> Bool
    /// Whether the library open now carries a passphrase (the confirm asks for it).
    var passphraseSet: @MainActor () -> Bool
    /// MAKE THIS MY LIBRARY: the copy's secrets, then her current pair (ignored where `landsInTheEmptySlot`). nil: the
    /// door is not offered.
    var makeMine: (@MainActor (CopyDoorRow, _ copySecrets: TypedSecrets, _ currentPair: TypedSecrets) async -> CopyDoorOutcome)?
    /// A picked thing classified and, when it is a pair or a library folder, filed (the picked thing is only read).
    var pick: @MainActor (URL) async -> PickOutcome
    /// LOOK INSIDE (rule 17; P-VX306-U3-15): the copy opened read-only on a private copy with what she typed (nothing:
    /// its own quiet road), trying the quiet roads it is given (the look's automatic first try never presses Touch ID —
    /// m2). nil: the door is not offered.
    var lookInside: (@MainActor (CatalogCopy, TypedSecrets, CopyQuietRoads) async -> LookInsideOpening)? = nil
    /// VX-307 U2c — VX-413: the platform's clipboard road for Look inside's *Copy full text* (the Mac's general
    /// pasteboard, written exactly as a live note's Copy full text writes it). nil: the door is not offered.
    var copyFullText: (@MainActor (String) -> Void)? = nil
    /// VX-309 U1b — T-5: no library is open (the missing face, rule 27's lobby) — Make this my library lands the copy in
    /// the empty slot under the secret typed for it, and its confirm asks exactly that (no current pair exists).
    var landsInTheEmptySlot = false
    /// VX-309 U1b — T-8: a plaintext export brought in as a NEW library through the import road (the library open now, if
    /// any, steps aside whole first). nil: the door is not offered (the export keeps its refusal).
    var bringInPlaintextExport: (@MainActor (URL) async -> CopyDoorOutcome)? = nil
    /// VX-309 U1c — VX-265: rule 19's delete — THIS Mac's copies of ONE other library (by its ID), re-read at the press.
    /// nil: the door is not offered.
    var deleteCopies: (@MainActor (String) async -> CopyDeleteOutcome)? = nil
}

// MARK: - VX-309 U1c — VX-265: the delete's confirm (rule 19 — one library's copies at a time, confirmed each time)

@MainActor
@Observable
final class CopyDeleteModel: Identifiable {
    let id = UUID()
    let choice: CopyDeleteChoice
    /// A library is open now (the lead says it is not touched).
    let libraryOpen: Bool
    private(set) var busy = false
    /// Why the press did nothing (nil: nothing to say).
    private(set) var refusal: String?

    @ObservationIgnored private let act: (String) async -> CopyDeleteOutcome
    /// The count deleted, or nil: she left (nothing written).
    @ObservationIgnored private let finished: (Int?) -> Void

    init(
        choice: CopyDeleteChoice, libraryOpen: Bool, act: @escaping (String) async -> CopyDeleteOutcome,
        finished: @escaping (Int?) -> Void
    ) {
        self.choice = choice
        self.libraryOpen = libraryOpen
        self.act = act
        self.finished = finished
    }

    /// The confirm's lead: the library named by its day, what goes counted, what stays said.
    var lead: String { ProtectionWords.deleteCopiesLead(choice, libraryOpen: libraryOpen) }

    /// Her press — the copies go (re-read at the press: what goes is what this Mac holds of that library NOW).
    func delete() async {
        guard !busy else { return }
        busy = true
        refusal = nil
        let outcome = await act(choice.libraryID)
        busy = false
        switch outcome {
        case .deleted(let count): finished(count)
        case .refused(let why): refusal = why.sentence
        }
    }

    /// The confirm's way out — nothing written.
    func cancel() {
        guard !busy else { return }
        finished(nil)
    }
}

// MARK: - Make this my library's confirm (§7c (8))

@MainActor
@Observable
final class MakeMineModel: Identifiable {
    let id = UUID()
    let row: CopyDoorRow
    /// The library open now carries a passphrase — the confirm asks for it beside the words.
    let passphraseSet: Bool
    /// VX-309 U1b — T-5: no library is open; the copy's own secret is the one thing asked (always — rule 14's precedent),
    /// and it becomes the new library's lock.
    let intoTheEmptySlot: Bool
    /// The copy's own quiet road is being tried (a READ).
    private(set) var checking = true
    /// No quiet road opens the copy — its own secret is asked (an empty field tries her own pair).
    private(set) var needsCopySecret = false
    private(set) var busy = false
    /// Why the press did nothing (nil: nothing to say).
    private(set) var refusal: String?

    @ObservationIgnored private let opensQuietly: () async -> Bool
    @ObservationIgnored private let act: (TypedSecrets, TypedSecrets) async -> CopyDoorOutcome
    /// true: the copy is her library now; false: she left the confirm (nothing written).
    @ObservationIgnored private let finished: (Bool) -> Void

    init(
        row: CopyDoorRow, passphraseSet: Bool, intoTheEmptySlot: Bool = false,
        opensQuietly: @escaping () async -> Bool,
        act: @escaping (TypedSecrets, TypedSecrets) async -> CopyDoorOutcome,
        finished: @escaping (Bool) -> Void
    ) {
        self.row = row
        self.passphraseSet = passphraseSet
        self.intoTheEmptySlot = intoTheEmptySlot
        self.opensQuietly = opensQuietly
        self.act = act
        self.finished = finished
    }

    /// The lead — §7c (8) (the passphrase clause only when one is set — P-VX306-U3-3); T-5's own when no library is open.
    var lead: String {
        intoTheEmptySlot ? ProtectionWords.makeMineEmptySlotLead : ProtectionWords.makeMineLeadShown(passphraseSet: passphraseSet)
    }

    /// The quiet road tried once, at the confirm's open — AUTOMATIC, so the road it is given never presses Touch ID
    /// (`ProtectionCopyDoors.opensQuietly` — m2). Into the empty slot no quiet road counts: the copy's secret is asked at once.
    func begin() async {
        if intoTheEmptySlot {
            needsCopySecret = true
            checking = false
            return
        }
        checking = true
        needsCopySecret = !(await opensQuietly())
        checking = false
    }

    /// VX-309 U1b — T-5's button: the copy's own secret typed, nothing running.
    func canSubmitIntoTheEmptySlot(copySecret: String) -> Bool {
        intoTheEmptySlot && !checking && !busy && !copySecret.isEmpty
    }

    /// VX-309 U1b — T-5's press: the copy's own secret (twelve valid words are the words, anything else a passphrase —
    /// untrimmed), and no current pair (none exists).
    func submitIntoTheEmptySlot(copySecret: String) async {
        guard canSubmitIntoTheEmptySlot(copySecret: copySecret) else { return }
        let copySecrets = Self.copySecrets(copySecret, currentPair: .none)
        busy = true
        refusal = nil
        let outcome = await act(copySecrets, .none)
        busy = false
        switch outcome {
        case .made: finished(true)
        case .refused(let why): refusal = why.sentence
        }
    }

    /// The button: her words typed, her passphrase typed when one is set, nothing running.
    func canSubmit(words: String, passphrase: String) -> Bool {
        !checking && !busy && !EncryptionSession.words(from: words).isEmpty && (!passphraseSet || !passphrase.isEmpty)
    }

    func submit(copySecret: String, words wordsText: String, passphrase: String) async {
        guard canSubmit(words: wordsText, passphrase: passphrase) else { return }
        let words = EncryptionSession.words(from: wordsText)
        do {
            try RecoveryPhrase.validate(words)
        } catch let error as RecoveryPhraseError {
            refusal = CopyDoorRefusal.wordsInvalid(error).sentence
            return
        } catch {
            refusal = ProtectionWords.wordsDoNotOpen
            return
        }
        // Untrimmed on purpose (a passphrase may begin or end with a space).
        let currentPair = TypedSecrets(passphrase: passphraseSet ? passphrase : nil, words: words)
        let copySecrets = Self.copySecrets(needsCopySecret ? copySecret : "", currentPair: currentPair)
        busy = true
        refusal = nil
        let outcome = await act(copySecrets, currentPair)
        busy = false
        switch outcome {
        case .made: finished(true)
        case .refused(let why): refusal = why.sentence
        }
    }

    /// The confirm's way out — nothing written.
    func cancel() {
        guard !busy else { return }
        finished(false)
    }

    /// What opens the copy at its door: what she typed in the copy's field — twelve valid words are the words,
    /// anything else a passphrase — or, with the field empty, her own pair (rule 4; PROVISIONAL P-VX306-U3-4).
    nonisolated static func copySecrets(_ text: String, currentPair: TypedSecrets) -> TypedSecrets {
        guard !text.isEmpty else { return currentPair }
        let words = EncryptionSession.words(from: text)
        if words.count == 12, (try? RecoveryPhrase.validate(words)) != nil { return TypedSecrets(words: words) }
        return TypedSecrets(passphrase: text)
    }
}

// MARK: - The doors on one copy (the picked flow, and a list row's press)

@MainActor
@Observable
final class CopyDoorsModel: Identifiable {
    enum Phase {
        /// A pick being classified and filed.
        case reading
        /// The honest refusal (a quiet detail beneath).
        case refused(String, detail: String?)
        /// A folder holding several stores — offered, never guessed.
        case choosing([URL])
        /// A picked copy, catalogued: its doors.
        case doors(CopyDoorRow)
        /// VX-309 U1b — this Mac's catalogued copies with NO library open (the missing face's and rule 27's *Restore from
        /// Backup…* on the new road — rule 17: "The app's Restore from Backup is this door"): each row its doors.
        case listing(CopyDoorsListing)
        /// VX-309 U1b — T-8: a picked plaintext export, its one door (bring it in as a new library).
        case plaintextExport(URL)
        /// Make this my library's confirm.
        case makeMine(MakeMineModel)
        /// Look inside — the copy read-only (P-VX306-U3-15).
        case lookInside(LookInsideModel)
        /// VX-309 U1c — VX-265: rule 19's delete's confirm (one other library's copies).
        case deleteCopies(CopyDeleteModel)
        /// The act is done (the host closes the sheet).
        case done
    }

    let id = UUID()
    private(set) var phase: Phase = .reading
    /// VX-309 U1b — T-8: the export is being brought in (the door's working line), or why it was not.
    private(set) var bringingIn = false
    private(set) var bringInRefusal: String?
    /// VX-309 U1c — the listing's receipt after a delete there (the listing re-read beneath it; nil: none).
    private(set) var listingReceipt: String?
    @ObservationIgnored private let roads: CopyDoorsRoads

    init(roads: CopyDoorsRoads) {
        self.roads = roads
    }

    /// The doors a copy is offered here: Look inside always when its road exists; Make this my library only with a
    /// library open.
    var offersLookInside: Bool { roads.lookInside != nil }
    var offersMakeMine: Bool { roads.makeMine != nil }

    /// A picked thing (File ▸ Open Library… on the new road): classified, filed when it is a pair, then its doors.
    func begin(picked: URL) async {
        phase = .reading
        switch await roads.pick(picked) {
        case .copy(let row): phase = .doors(row)
        case .several(let stores): phase = .choosing(stores)
        case .refused(let message, let detail): phase = .refused(message, detail: detail)
        case .plaintextExport(let store):
            // The door exists only where its road does (P-2); else the export keeps its honest refusal.
            phase = roads.bringInPlaintextExport == nil
                ? .refused(ProtectionWords.plaintextCopyNotYet, detail: nil) : .plaintextExport(store)
        }
    }

    /// VX-309 U1b — T-8: whether a library is open now (its confirm says the library steps aside).
    var bringInStepsALibraryAside: Bool { !roads.landsInTheEmptySlot }

    /// VX-309 U1b — T-8's press: the export brought in as a new library; made ⇒ the sheet leaves (the open is already
    /// routing), refused ⇒ the sentence under the door.
    func bringIn(_ store: URL) async {
        guard let bring = roads.bringInPlaintextExport, !bringingIn else { return }
        bringingIn = true
        bringInRefusal = nil
        let outcome = await bring(store)
        bringingIn = false
        switch outcome {
        case .made: phase = .done
        case .refused(let why): bringInRefusal = why.sentence
        }
    }

    /// The chooser's pick.
    func choose(_ store: URL) async { await begin(picked: store) }

    /// VX-309 U1b — the catalogue's copies on this Mac, read now, each row's doors offered (the faces with no library open:
    /// the missing face, rule 27's lobby).
    func beginListing() async {
        phase = .reading
        phase = .listing(await roads.listing())
    }

    /// Look inside `row` (a list row's press, or the picked copy's door) — the quiet road tried first.
    func openLookInside(_ row: CopyDoorRow) async {
        guard let lookInside = roads.lookInside else { return }
        let model = LookInsideModel(
            row: row, offersMakeMine: roads.makeMine != nil,
            open: { typed, quietRoads in await lookInside(row.copy, typed, quietRoads) },
            finished: { [weak self] exit in
                guard let self else { return }
                switch exit {
                case .closed: self.phase = .done
                case .makeMine: Task { await self.openMakeMine(row) }
                }
            },
            copyText: roads.copyFullText)
        phase = .lookInside(model)
        await model.begin()
    }

    /// Make this my library's confirm for `row` (a list row's press, or the picked copy's door).
    func openMakeMine(_ row: CopyDoorRow) async {
        guard let makeMine = roads.makeMine else { return }
        let roads = roads
        let model = MakeMineModel(
            row: row, passphraseSet: roads.passphraseSet(), intoTheEmptySlot: roads.landsInTheEmptySlot,
            opensQuietly: { await roads.opensQuietly(row.copy) },
            act: { copySecrets, currentPair in await makeMine(row, copySecrets, currentPair) },
            finished: { [weak self] made in
                guard let self else { return }
                if made {
                    self.phase = .done
                } else if case .makeMine = self.phase {
                    self.phase = .done
                }
            })
        phase = .makeMine(model)
        await model.begin()
    }

    /// VX-309 U1c — VX-265: whether a row offers *Delete…* here (its library's choice in the listing, and the road).
    var offersDelete: Bool { roads.deleteCopies != nil }

    /// VX-309 U1c — rule 19's delete's confirm for `choice` (a listing row's press, or Data Safety's row). Confirmed, the
    /// copies go and — from the listing — the listing is read again with the receipt above it; from a row elsewhere the
    /// sheet leaves (the host's list re-reads on the copies-changed seam). Left, nothing is written.
    func openDeleteCopies(_ choice: CopyDeleteChoice) {
        guard let deleteCopies = roads.deleteCopies else { return }
        let fromListing: Bool
        if case .listing = phase { fromListing = true } else { fromListing = false }
        listingReceipt = nil
        let model = CopyDeleteModel(
            choice: choice, libraryOpen: !roads.landsInTheEmptySlot, act: { await deleteCopies($0) },
            finished: { [weak self] count in
                guard let self else { return }
                guard fromListing else {
                    self.phase = .done
                    return
                }
                Task {
                    await self.beginListing()
                    if let count { self.listingReceipt = ProtectionWords.deleteCopiesReceipt(count) }
                }
            })
        phase = .deleteCopies(model)
    }

    /// The sheet's way out — a look standing is forgotten first.
    func close() {
        if case .lookInside(let look) = phase { look.forget() }
        phase = .done
    }
}

/// The Restore list's brain on the new road: the listing, re-read at each appearance AND whenever this Mac's
/// catalogued copies change while it stands — a backup pair LANDING (Back Up Now in the same pane, or a scheduled run):
/// the ladder's round-1 m4, the walk's W-13. The seam is the backup hook's own (`StoreBackup.onRun` →
/// `ProtectionBackupHook.handle`), which posts `copiesChanged` once the pair is written.
@MainActor
@Observable
final class CopyDoorsListModel {
    /// Posted on the main actor once this Mac's catalogued copies changed — a backup pair landed (the backup hook), or a
    /// picked copy was filed into this Mac's safety copies (`ProtectionCopyDoors.pick` — ladder round 2, NIT 3).
    nonisolated static let copiesChanged = Notification.Name("io.lduarte.Variorum.protection.copiesChanged")

    private(set) var listing: CopyDoorsListing = .empty
    @ObservationIgnored let roads: CopyDoorsRoads
    /// Each re-read's number: only the newest lands (an older read finishing late never writes over a newer one).
    @ObservationIgnored private var reads = 0
    @ObservationIgnored private var observer: CopiesChangedObserver?

    init(roads: CopyDoorsRoads) {
        self.roads = roads
        observer = CopiesChangedObserver { [weak self] in
            Task { await self?.refresh() }
        }
    }

    func refresh() async {
        reads += 1
        let read = reads
        let fresh = await roads.listing()
        guard read == reads else { return }
        listing = fresh
    }
}

/// `CopyDoorsListModel.copiesChanged`, observed for as long as the list stands (removed when it goes).
nonisolated final class CopiesChangedObserver: @unchecked Sendable {
    private let token: any NSObjectProtocol

    init(_ changed: @escaping @MainActor @Sendable () -> Void) {
        token = NotificationCenter.default.addObserver(
            forName: CopyDoorsListModel.copiesChanged, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { changed() }
        }
    }

    deinit { NotificationCenter.default.removeObserver(token) }
}
