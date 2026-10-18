//
//  LookInsideModel.swift
//  Variorum (shared: Mac + Mobile — the Mac's face this unit; the phone has no door that reaches a copy yet)
//
//  VX-306 U3 — LOOK INSIDE's brain (rule 17: "Look inside: any copy … opens read-only with its own secrets (or its own
//  quiet road on this Mac). The app writes nothing … Close it and the app forgets it."; the orchestrator's ruling
//  P-VX306-U3-15 — (b), the read-only facts sheet; §7c (10)'s line first). The open is an injected road (the
//  bootstrap's, through the executor's `lookInside` and `ProtectionCopyPeek` off the main actor; a test's, planted): it
//  tries the copy's own quiet road first, then what she types in the copy's field. The look holds ONE reader — a
//  read-only connection on a private copy — and NOTHING ELSE of the copy's: no key (it lives only inside the
//  connection), nothing written. Every read runs off the main actor, a page of notes at a time. Closing — *Close*, the
//  sheet going away, or *Make this my library…* — closes the reader: the connection closed, the private folder deleted.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class LookInsideModel: Identifiable {
    enum Phase: Equatable {
        /// The copy's own quiet road is being tried.
        case opening
        /// No quiet road opens it — its own secret is asked.
        case needsSecret
        /// The copy is gone or unreadable — said, nothing more to do.
        case unavailable
        /// Open, read-only.
        case open
        /// Closed — the look forgotten.
        case closed
    }

    /// How the look ended.
    enum Exit: Equatable {
        case closed
        /// *Make this my library…* from inside the look (the look closes first).
        case makeMine
    }

    let id = UUID()
    let row: CopyDoorRow
    /// Make this my library is offered beside *Close* (a library is open — T-5's empty-slot landing is VX-309's).
    let offersMakeMine: Bool
    private(set) var phase: Phase = .opening
    private(set) var busy = false
    private(set) var refusal: String?
    private(set) var books: [ProtectionCopyPeek.Book] = []
    private(set) var notes: [ProtectionCopyPeek.Note] = []
    private(set) var hasMoreNotes = false
    /// The note shown read-only (nil: the lists).
    private(set) var shown: ProtectionCopyPeek.NoteText?

    @ObservationIgnored private var reader: ProtectionCopyPeek.Reader?
    @ObservationIgnored private let open: (TypedSecrets) async -> LookInsideOpening
    @ObservationIgnored private let finished: (Exit) -> Void
    @ObservationIgnored private let day: (Date) -> String

    init(
        row: CopyDoorRow, offersMakeMine: Bool,
        open: @escaping (TypedSecrets) async -> LookInsideOpening,
        finished: @escaping (Exit) -> Void,
        day: @escaping (Date) -> String = { ProtectionWords.day($0) }
    ) {
        self.row = row
        self.offersMakeMine = offersMakeMine
        self.open = open
        self.finished = finished
        self.day = day
    }

    /// §7c (10)'s line — the copy's day written in.
    var frameLine: String { ProtectionWords.lookInsideFrame(row.asOf.map(day) ?? ProtectionWords.offerUnknownDay) }

    /// The copy's kind.
    var kindLine: String { ProtectionWords.copyKind(row.kind) }

    /// Whether a look is holding a reader now (the write-nothing proof reads it).
    var isHoldingAReader: Bool { reader != nil }

    /// The quiet road first (a READ).
    func begin() async { await attempt(.none, quietly: true) }

    /// What she typed in the copy's field — twelve valid words are the words, anything else a passphrase.
    func submit(secret: String) async {
        guard !secret.isEmpty, !busy else { return }
        await attempt(MakeMineModel.copySecrets(secret, currentPair: .none), quietly: false)
    }

    private func attempt(_ typed: TypedSecrets, quietly: Bool) async {
        busy = true
        refusal = nil
        let opening = await open(typed)
        switch opening {
        case .opened(let opened):
            guard phase != .closed else {
                opened.close()
                busy = false
                return
            }
            reader = opened
            await load()
            busy = false
            phase = .open
        case .refused(let why):
            busy = false
            switch why {
            case .copyDoesNotOpen:
                phase = .needsSecret
                if !quietly { refusal = why.sentence }
            default:
                phase = .unavailable
                refusal = why.sentence
            }
        }
    }

    private func load() async {
        guard let reader else { return }
        let page = ProtectionCopyPeek.pageSize
        let (books, notes) = await Task.detached(priority: .userInitiated) {
            ((try? reader.books()) ?? [], (try? reader.notes(offset: 0, limit: page + 1)) ?? [])
        }.value
        self.books = books
        hasMoreNotes = notes.count > page
        self.notes = Array(notes.prefix(page))
    }

    /// The next page of notes.
    func moreNotes() async {
        guard let reader, hasMoreNotes, !busy else { return }
        busy = true
        let page = ProtectionCopyPeek.pageSize
        let offset = notes.count
        let next = await Task.detached(priority: .userInitiated) {
            (try? reader.notes(offset: offset, limit: page + 1)) ?? []
        }.value
        busy = false
        hasMoreNotes = next.count > page
        notes += next.prefix(page)
    }

    /// A note's text, read-only.
    func show(_ note: ProtectionCopyPeek.Note) async {
        guard let reader, !busy else { return }
        busy = true
        shown = await Task.detached(priority: .userInitiated) { try? reader.note(id: note.id) }.value
        busy = false
    }

    /// Back to the lists.
    func back() { shown = nil }

    /// *Close* — the look forgotten.
    func close() {
        forget()
        finished(.closed)
    }

    /// *Make this my library…* from inside the look — the look forgotten first.
    func makeMine() {
        guard offersMakeMine else { return }
        forget()
        finished(.makeMine)
    }

    /// The reader closed (its connection, its private folder), everything read dropped. Idempotent.
    func forget() {
        let outgoing = reader
        reader = nil
        books = []
        notes = []
        shown = nil
        hasMoreNotes = false
        phase = .closed
        outgoing?.close()
    }
}
