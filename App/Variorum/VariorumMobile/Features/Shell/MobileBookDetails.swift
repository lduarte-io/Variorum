//
//  MobileBookDetails.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C2 — THE BOOK DETAILS surface (the LK5
//  expansion ruling: "finishing / unfinishing should be a v1 phone
//  capability - there should be some way to get to book details from the
//  contents of a book"), built to the fork's repo-first ruling (the plan
//  file's "THE BOOK DETAILS RULING" section): the voiced "Details" word
//  in the contents screen's trailing chrome opens a medium-detent LK4
//  sheet over the contents. The act column:
//
//  · IDENTITY — the book's name + state through the ONE faces brain
//    (`MobileShelfFaces.name`/`meta` — count · tags · daily), and the
//    name row IS the rename door (the note-masthead parallel).
//  · FINISH / REOPEN — one state-mirroring row through the core's own
//    `lockReading`/`unlockReading` (the Mac menu's words; a reversible
//    guard — the row is its own inverse, no undo entry).
//  · TAGS — DISPLAY ONLY, both kinds (ruled (B) by her sitting answer:
//    smart-filter editing is the deferred 13i-class structure work; a
//    curated book's shelf tags are DERIVED from member notes by model
//    fact — there is no book-level tag row to edit).
//  · USE AS DAILY JOURNAL — rendered on curated journal-profile books
//    only (the Mac's exact render rule; P-2 — elsewhere the door could
//    never mean what it says), the designation state shown when held.
//
//  · DELETE BOOK — **arrived at round 2 batch 4 (PR4)**, where the
//    parity inventory's sweep found the phone could not delete a reading
//    from anywhere. Move to Trash, confirmed, and the confirm says the
//    thing she once had to teach: the book's NOTES stay in the library.
//    (The shelf row's long-press carries the same door; both speak
//    `MobileShelfFaces`' one wording.)
//
//  Deliberately absent, as ruled: extents (LK5's ranking) ·
//  chapters/reorder/sort/filter/convert (the Mac's coming book
//  redefinition — the post-13i round's).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileBookDetailsModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let readingID: String

    private(set) var book: Queries.ShelfBook?
    private(set) var tagPaths: [String] = []
    private(set) var isDaily = false
    private(set) var lastError: String?

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    // MARK: - Pure brains (pinned)

    /// The daily door's render rule — the Mac shelf menu's own (curated +
    /// journal profile; P-2: a door that can never mean what it says
    /// isn't rendered).
    nonisolated static func showsDailyDoor(_ reading: Reading) -> Bool {
        reading.kind == .curated && reading.profile == "journal"
    }

    /// The rename face's gate (the create sheet's rule: no nameless book).
    nonisolated static func canRename(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Reads

    /// ONE read delivers the identity block coherently: the shelf row +
    /// the tags column + the daily designation (the shelf's own sources,
    /// so details can never disagree with the shelf).
    func refresh() async {
        do {
            let id = readingID
            let (books, tags, dailyID) = try await session.database.read { db in
                (try Queries.bookshelf(db),
                 try Queries.shelfBookTags(db),
                 try Queries.dailyJournalBookID(db))
            }
            book = books.first { $0.reading.id == id }
            if let book {
                tagPaths = MobileShelfFaces.tagPaths(for: book, curatedTags: tags)
            }
            isDaily = dailyID == id
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The identity block's two lines, through the ONE faces brain.
    var nameLine: String? {
        book.map { MobileShelfFaces.name(for: $0) }
    }

    var metaLine: String? {
        book.map { MobileShelfFaces.meta(for: $0, tagPaths: tagPaths, isDaily: isDaily) }
    }

    // MARK: - Acts (every one an existing core operation)

    /// Finish / reopen — the `reading.locked` guard, reversible.
    func setFinished(_ finished: Bool) async {
        let id = readingID
        await run {
            finished ? try $0.lockReading(id) : try $0.unlockReading(id)
        }
    }

    /// Rename — free on a finished book (the Mac's renameReading has no
    /// lock guard; rename stays free under lock, the renameSection
    /// parallel). The face gates blank names.
    func rename(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard Self.canRename(trimmed) else { return }
        let id = readingID
        await run { try $0.renameReading(id, name: trimmed) }
    }

    /// **Delete the book** (round 2, batch 4 — PR4). Move to Trash: the
    /// reading tombstones with its chapters and memberships by cascade, and
    /// `restoreReading` waits on the other side for the window. Its NOTES
    /// are untouched — they are pointed at, never contained.
    ///
    /// Returns whether it went, so the sheet can dismiss and the book
    /// screen behind it can pop: a surface standing on a tombstoned book is
    /// exactly what this door must not leave behind.
    @discardableResult
    func deleteBook() async -> Bool {
        let id = readingID
        do {
            try await session.runner.run { ops in
                try ops.deleteReading(id)
            }
            lastError = nil
            return true
        } catch let error as OperationError {
            lastError = Self.refusal(error)
            return false
        } catch {
            lastError = String(describing: error)
            return false
        }
    }

    /// The daily-designation road (the Today door's refusals name it).
    func designateDaily() async {
        let id = readingID
        await run { try $0.setDailyJournalBook(id) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch let error as OperationError {
            lastError = Self.refusal(error)
        } catch {
            lastError = String(describing: error)
        }
        await refresh()
    }

    /// Phone words for the acts' refusals (no platform names).
    nonisolated static func refusal(_ error: OperationError) -> String {
        switch error {
        case .lockedReading:
            return "This book is finished — reopen it first."
        case .readingNotFound:
            return "That book is gone."
        default:
            return "Refused: \(error)"
        }
    }
}

/// The details sheet (LK4's grammar; medium detent — details is summoned
/// depth, never a place).
struct MobileBookDetailsSheet: View {
    @State private var model: MobileBookDetailsModel
    let tokens: VoiceTokens
    /// The book went — the screen behind this sheet must navigate away
    /// (round 2 batch 4, PR4). nil in harness/preview use.
    let onDeleted: (() -> Void)?
    @State private var renamePresented = false
    @State private var renameField = ""
    @State private var deletePresented = false
    @Environment(\.dismiss) private var dismiss

    init(
        session: AppSession, readingID: String, tokens: VoiceTokens,
        onDeleted: (() -> Void)? = nil
    ) {
        _model = State(initialValue: MobileBookDetailsModel(
            session: session, readingID: readingID))
        self.tokens = tokens
        self.onDeleted = onDeleted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(tokens.chromeLabel("Book Details"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            if let book = model.book {
                identityBlock(book)
                Divider().overlay(tokens.line)
                finishRow(book)
                if MobileBookDetailsModel.showsDailyDoor(book.reading) {
                    dailyRow
                }
                Divider().overlay(tokens.line)
                deleteRow
            }
            if let error = model.lastError {
                Text(error).font(tokens.small).foregroundStyle(.red)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
        .alert("Rename Book", isPresented: $renamePresented) {
            TextField("Name", text: $renameField)
            Button("Rename") {
                let name = renameField
                let model = model
                Task { await model.rename(name) }
            }
            // The face gate the model's comment promises (C2 ladder
            // R1-3): a blank name never fires a silent no-op.
            .disabled(!MobileBookDetailsModel.canRename(renameField))
            Button("Cancel", role: .cancel) {}
        }
        // PR4's confirm — a real `@State` binding (§15's trap (a)).
        .alert(
            MobileShelfFaces.deleteBookConfirmTitle,
            isPresented: $deletePresented
        ) {
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task {
                    if await model.deleteBook() {
                        dismiss()
                        onDeleted?()
                    }
                }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: {
            Text(MobileShelfFaces.deleteBookConfirmDetail(
                name: model.book?.reading.name))
        }
    }

    /// **Delete Book…** (PR4) — a plain Button, like every other act row
    /// here, so it is a door a pin can actually drive (§15's trap (b)).
    private var deleteRow: some View {
        Button {
            deletePresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel(MobileShelfFaces.deleteBookDoorTitle))
                    .font(tokens.body)
                    .foregroundStyle(.red)
                Spacer()
                Text(tokens.chromeLabel(RecoveryCopy.deleteBookKeepsItsNotes))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MobileShelfFaces.deleteBookDoorTitle)
    }

    /// The identity block — the name row IS the rename door (the
    /// note-masthead parallel; an alert confirms, a stray tap costs
    /// nothing).
    private func identityBlock(_ book: Queries.ShelfBook) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                renameField = book.reading.name
                renamePresented = true
            } label: {
                Text(tokens.chromeLabel(model.nameLine ?? ""))
                    .font(tokens.body.weight(.semibold))
                    .foregroundStyle(book.reading.locked ? tokens.accent : tokens.ink)
                    .lineLimit(2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Rename Book")
            if let meta = model.metaLine {
                Text(tokens.chromeLabel(meta))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
    }

    /// Finish / Reopen — one state-mirroring row (the Mac menu's words).
    private func finishRow(_ book: Queries.ShelfBook) -> some View {
        let finished = book.reading.locked
        return Button {
            let model = model
            Task { await model.setFinished(!finished) }
        } label: {
            HStack {
                Text(tokens.chromeLabel(finished ? "Reopen" : "Finish"))
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                Spacer()
                Text(tokens.chromeLabel(finished
                    ? "finished — its notes and order are frozen"
                    : "a finished book reads ✓ and freezes its notes"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// The daily-designation road (curated journal books only — P-2).
    private var dailyRow: some View {
        Button {
            let model = model
            Task { await model.designateDaily() }
        } label: {
            HStack {
                Text(tokens.chromeLabel("Use as Daily Journal"))
                    .font(tokens.body)
                    .foregroundStyle(model.isDaily ? tokens.faint : tokens.accent)
                Spacer()
                if model.isDaily {
                    Text(tokens.chromeLabel("daily ✓"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(model.isDaily)
    }
}
