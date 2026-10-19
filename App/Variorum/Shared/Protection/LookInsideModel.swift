//
//  LookInsideModel.swift
//  Variorum (shared: Mac + Mobile — the Mac's face this unit; the phone has no door that reaches a copy yet)
//
//  VX-306 U3 — LOOK INSIDE's brain (rule 17: "Look inside: any copy … opens read-only with its own secrets (or its own
//  quiet road on this Mac). The app writes nothing … Close it and the app forgets it."; the orchestrator's ruling
//  P-VX306-U3-15 — (b), the read-only facts sheet; §7c (10)'s line first). The open is an injected road (the
//  bootstrap's, through the executor's `lookInside` and `ProtectionCopyPeek` off the main actor; a test's, planted): it
//  tries the copy's own quiet road first — AUTOMATICALLY, as the sheet opens, so that first try never presses Touch ID
//  (`CopyQuietRoads.withoutAPress`: the silent item and the Apple wrap — the ladder's round-1 m2) — then what she types
//  in the copy's field (her press of *Open*, which may). The look holds ONE reader — a
//  read-only connection on a private copy — and NOTHING ELSE of the copy's: no key (it lives only inside the
//  connection), nothing written. Every read runs off the main actor, a page of notes at a time. Closing — *Close*, the
//  sheet going away, or *Make this my library…* — closes the reader: the connection closed, the private folder deleted —
//  OFF the main actor and only after the read in flight (if any) finished, and a read that finishes after the look was
//  forgotten lands nothing (the ladder's round-1 NIT 3).
//  VX-307 U2c — VX-413 (her ruling, 2026-10-18: "copy full text is a good idea"): the note page's *Copy full text* puts
//  the note shown on the clipboard in the Variorum document format (Copy full text's own projection, read from the
//  private copy) — the one thing the look hands out; nothing else about the look changes.
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
    /// VX-307 U2c — VX-413: what the note page's *Copy full text* said — the receipt, or why nothing was copied — in
    /// the sheet under the door (the sheet is where she is; a status seam may sit behind it, or — no library open — not
    /// exist; PROVISIONAL P-VX307-U2c-1). nil: nothing said yet for the note shown.
    private(set) var copyLine: CopyLine?

    /// What the Copy door said.
    enum CopyLine: Equatable {
        /// The receipt — Copy full text's own sentence.
        case copied
        /// The note has no text and no name (Copy full text's own refusal).
        case nothingToCopy
        /// The note's full text could not be read from the copy.
        case failed

        var sentence: String {
            switch self {
            case .copied: return ProtectionWords.lookInsideCopied
            case .nothingToCopy: return ProtectionWords.lookInsideNothingToCopy
            case .failed: return ProtectionWords.lookInsideCopyFailed
            }
        }
    }

    @ObservationIgnored private var reader: ProtectionCopyPeek.Reader?
    /// The read running on the reader now (one at a time — `busy`): a close waits for it before the reader closes.
    @ObservationIgnored private var inFlight: Task<Void, Never>?
    /// The last forget's close of the reader — off the main actor, after the read in flight (a test awaits it).
    @ObservationIgnored private(set) var closing: Task<Void, Never>?
    @ObservationIgnored private let open: (TypedSecrets, CopyQuietRoads) async -> LookInsideOpening
    @ObservationIgnored private let finished: (Exit) -> Void
    @ObservationIgnored private let day: (Date) -> String
    /// VX-307 U2c — VX-413: the platform's clipboard road for *Copy full text* (the Mac's general pasteboard, exactly as
    /// a live note's Copy full text writes it). nil: the door is not offered (P-2).
    @ObservationIgnored private let copyText: (@MainActor (String) -> Void)?

    init(
        row: CopyDoorRow, offersMakeMine: Bool,
        open: @escaping (TypedSecrets, CopyQuietRoads) async -> LookInsideOpening,
        finished: @escaping (Exit) -> Void,
        day: @escaping (Date) -> String = { ProtectionWords.day($0) },
        copyText: (@MainActor (String) -> Void)? = nil
    ) {
        self.row = row
        self.offersMakeMine = offersMakeMine
        self.open = open
        self.finished = finished
        self.day = day
        self.copyText = copyText
    }

    /// VX-307 U2c — VX-413: the note page carries *Copy full text* wherever a clipboard road exists.
    var offersCopyFullText: Bool { copyText != nil }

    /// §7c (10)'s line — the copy's day written in.
    var frameLine: String { ProtectionWords.lookInsideFrame(row.asOf.map(day) ?? ProtectionWords.offerUnknownDay) }

    /// The copy's kind.
    var kindLine: String { ProtectionWords.copyKind(row.kind) }

    /// Whether a look is holding a reader now (the write-nothing proof reads it).
    var isHoldingAReader: Bool { reader != nil }

    /// The quiet road first (a READ) — automatic, so never a press (m2).
    func begin() async { await attempt(.none, quietRoads: .withoutAPress, quietly: true) }

    /// What she typed in the copy's field — twelve valid words are the words, anything else a passphrase.
    func submit(secret: String) async {
        guard !secret.isEmpty, !busy else { return }
        // Her press of *Open* — the copy's own quiet roads, Touch ID's included.
        await attempt(MakeMineModel.copySecrets(secret, currentPair: .none), quietRoads: .includingTouchID, quietly: false)
    }

    private func attempt(_ typed: TypedSecrets, quietRoads: CopyQuietRoads, quietly: Bool) async {
        busy = true
        refusal = nil
        let opening = await open(typed, quietRoads)
        switch opening {
        case .opened(let opened):
            guard phase != .closed else {
                // Forgotten while it opened: the reader closes off the main actor, nothing of it kept.
                closing = Task.detached(priority: .utility) { opened.close() }
                busy = false
                return
            }
            reader = opened
            await load()
            busy = false
            // Forgotten while its first page read: the look stays closed.
            guard reader === opened else { return }
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

    /// One read on `reader`, off the main actor; the read is kept as the one in flight, so a close waits for it.
    private func read<T: Sendable>(
        _ reader: ProtectionCopyPeek.Reader, _ body: @escaping @Sendable (ProtectionCopyPeek.Reader) -> T
    ) async -> T {
        let task = Task.detached(priority: .userInitiated) { body(reader) }
        inFlight = Task.detached { _ = await task.value }
        return await task.value
    }

    private func load() async {
        guard let reader else { return }
        let page = ProtectionCopyPeek.pageSize
        let (books, notes) = await read(reader) { reader in
            ((try? reader.books()) ?? [], (try? reader.notes(offset: 0, limit: page + 1)) ?? [])
        }
        // Forgotten while it read: nothing lands on a closed look.
        guard self.reader === reader else { return }
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
        let next = await read(reader) { reader in (try? reader.notes(offset: offset, limit: page + 1)) ?? [] }
        busy = false
        guard self.reader === reader else { return }
        hasMoreNotes = next.count > page
        notes += next.prefix(page)
    }

    /// A note's text, read-only.
    func show(_ note: ProtectionCopyPeek.Note) async {
        guard let reader, !busy else { return }
        busy = true
        let id = note.id
        let text = await read(reader) { reader in try? reader.note(id: id) }
        busy = false
        guard self.reader === reader else { return }
        shown = text
        copyLine = nil
    }

    /// Back to the lists.
    func back() {
        shown = nil
        copyLine = nil
    }

    /// What a full-text read came to (off the main actor).
    private enum FullTextRead: Sendable {
        case text(String)
        case noNote
        case failed
    }

    /// VX-307 U2c — VX-413 (her word, 2026-10-18: "copy full text is a good idea"): the note shown, onto the clipboard
    /// in the Variorum document format — Copy full text's own projection, read from the look's private copy off the main
    /// actor (`ProtectionCopyPeek.Reader.fullText(id:)`): the title, every live take, the tags, re-importable whole by
    /// File ▸ Import. Writes NOTHING to the copy or the library — only the clipboard; the look stays as it was (read-only,
    /// and closing forgets). Speaks Copy full text's own receipt, or its refusal for a note with nothing to copy.
    func copyFullText() async {
        guard let reader, let copyText, let note = shown, !busy else { return }
        busy = true
        copyLine = nil
        let id = note.id
        let read = await read(reader) { reader -> FullTextRead in
            do {
                guard let text = try reader.fullText(id: id) else { return .noNote }
                return .text(text)
            } catch {
                return .failed
            }
        }
        busy = false
        // Forgotten, or another note shown, while it read: nothing lands.
        guard self.reader === reader, shown?.id == id else { return }
        switch read {
        case .text(let text) where !text.isEmpty:
            copyText(text)
            copyLine = .copied
        case .text:
            copyLine = .nothingToCopy
        case .noNote, .failed:
            copyLine = .failed
        }
    }

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

    /// Everything read dropped at once, the look closed; the reader closed (its connection, its private folder) OFF the
    /// main actor, after the read in flight finished — so *Close* during a page's read neither races that read nor
    /// waits on the main actor for it and the folder's delete (the ladder's round-1 NIT 3). Idempotent.
    func forget() {
        let outgoing = reader
        let pending = inFlight
        reader = nil
        inFlight = nil
        books = []
        notes = []
        shown = nil
        copyLine = nil
        hasMoreNotes = false
        phase = .closed
        guard let outgoing else { return }
        closing = Task.detached(priority: .utility) {
            await pending?.value
            outgoing.close()
        }
    }
}
