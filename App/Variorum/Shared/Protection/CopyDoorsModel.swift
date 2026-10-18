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
//    - LOOK INSIDE is PROPOSE-THEN-RULE (the U3 record's piece 4): its door renders only once its face is built
//      (`CopyDoorsRoads.lookInside` nil until then — P-2: a door that cannot act is not rendered).
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

/// The Restore list — the catalogue's copies, grouped and ordered. Pure.
nonisolated struct CopyDoorsListing: Equatable, Sendable {
    var thisLibrary: [CopyDoorRow]
    var otherLibraries: [CopyDoorRow]

    static let empty = CopyDoorsListing(thisLibrary: [], otherLibraries: [])

    var isEmpty: Bool { thisLibrary.isEmpty && otherLibraries.isEmpty }
    var all: [CopyDoorRow] { thisLibrary + otherLibraries }

    /// The listing of `catalog` for the library `libraryID` (nil: none open — every copy is another library's).
    /// `asOf`: a copy's day (the road reads an opened copy's own day from its file).
    static func make(
        _ catalog: Catalog, libraryID: String?, asOf: (CatalogCopy) -> Date? = { $0.stamp }
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
        return CopyDoorsListing(thisLibrary: newestFirst(mine), otherLibraries: newestFirst(others))
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
        }
    }
}

nonisolated enum CopyDoorOutcome: Equatable, Sendable {
    case made
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
    /// MAKE THIS MY LIBRARY: the copy's secrets, then her current pair.
    var makeMine: @MainActor (CopyDoorRow, _ copySecrets: TypedSecrets, _ currentPair: TypedSecrets) async -> CopyDoorOutcome
    /// A picked thing classified and, when it is a pair or a library folder, filed (the picked thing is only read).
    var pick: @MainActor (URL) async -> PickOutcome
}

// MARK: - Make this my library's confirm (§7c (8))

@MainActor
@Observable
final class MakeMineModel: Identifiable {
    let id = UUID()
    let row: CopyDoorRow
    /// The library open now carries a passphrase — the confirm asks for it beside the words.
    let passphraseSet: Bool
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
        row: CopyDoorRow, passphraseSet: Bool,
        opensQuietly: @escaping () async -> Bool,
        act: @escaping (TypedSecrets, TypedSecrets) async -> CopyDoorOutcome,
        finished: @escaping (Bool) -> Void
    ) {
        self.row = row
        self.passphraseSet = passphraseSet
        self.opensQuietly = opensQuietly
        self.act = act
        self.finished = finished
    }

    /// The lead — §7c (8) (the passphrase clause only when one is set — P-VX306-U3-3).
    var lead: String { ProtectionWords.makeMineLeadShown(passphraseSet: passphraseSet) }

    /// The quiet road tried once, at the confirm's open.
    func begin() async {
        checking = true
        needsCopySecret = !(await opensQuietly())
        checking = false
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
        /// Make this my library's confirm.
        case makeMine(MakeMineModel)
        /// The act is done (the host closes the sheet).
        case done
    }

    let id = UUID()
    private(set) var phase: Phase = .reading
    @ObservationIgnored private let roads: CopyDoorsRoads

    init(roads: CopyDoorsRoads) {
        self.roads = roads
    }

    /// A picked thing (File ▸ Open Library… on the new road): classified, filed when it is a pair, then its doors.
    func begin(picked: URL) async {
        phase = .reading
        switch await roads.pick(picked) {
        case .copy(let row): phase = .doors(row)
        case .several(let stores): phase = .choosing(stores)
        case .refused(let message, let detail): phase = .refused(message, detail: detail)
        }
    }

    /// The chooser's pick.
    func choose(_ store: URL) async { await begin(picked: store) }

    /// Make this my library's confirm for `row` (a list row's press, or the picked copy's door).
    func openMakeMine(_ row: CopyDoorRow) async {
        let roads = roads
        let model = MakeMineModel(
            row: row, passphraseSet: roads.passphraseSet(),
            opensQuietly: { await roads.opensQuietly(row.copy) },
            act: { copySecrets, currentPair in await roads.makeMine(row, copySecrets, currentPair) },
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

    /// The sheet's way out.
    func close() { phase = .done }
}

/// The Restore list's brain on the new road: the listing, re-read at each appearance.
@MainActor
@Observable
final class CopyDoorsListModel {
    private(set) var listing: CopyDoorsListing = .empty
    @ObservationIgnored let roads: CopyDoorsRoads

    init(roads: CopyDoorsRoads) { self.roads = roads }

    func refresh() async { listing = await roads.listing() }
}
