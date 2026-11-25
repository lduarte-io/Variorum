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
import GRDB // `Database` in the archived-book read's signature
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
    /// VM-61: every value this slot holds is a refusal, so it speaks on the
    /// phone's one line as it is set (nil says nothing); no screen draws it.
    private(set) var lastError: String? {
        get { lastRefusal?.sentence }
        set { lastRefusal = newValue.map { RefusalWords($0) } }
    }
    /// VM-277 (A-260-4 (a)): the refusal behind `lastError` — its sentence and,
    /// where the refusal table authored one, its short headline — spoken on the
    /// one line, which draws the headline and keeps the sentence behind a tap.
    private(set) var lastRefusal: RefusalWords? {
        didSet { MobileLine.refuse(lastRefusal, session: session) }
    }
    /// VM-81 — the Finish confirm on screen (nil = none asked).
    private(set) var pendingFinish: FinishConfirm?

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    // MARK: - Pure brains (pinned)

    /// The daily door's render rule — the Mac shelf menu's own (curated +
    /// journal profile; P-2: a door that can never mean what it says
    /// isn't rendered).
    nonisolated static func showsDailyDoor(_ reading: Reading) -> Bool {
        reading.kind == .book && Queries.hasJournalTrait(reading.profile)
    }

    /// The rename face's gate (the create sheet's rule: no nameless book).
    nonisolated static func canRename(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// VM-81 — the finish row's one act, or nil where no such door is drawn.
    nonisolated enum FinishRowAct: Equatable, Sendable {
        case finish
        case reopen
    }

    /// **Which finish door the row draws** (VM-81, W-106) — the Mac's finish
    /// pair (`BookStateDoorSet`), read for the phone's one row: a GATHERING
    /// has no Finish (`lockReading` refuses it `wrongReadingKind` — P-2: a
    /// door that can never act is not drawn), and one ALREADY finished (a
    /// legacy 13i-b finish, or one synced so) keeps Reopen as its way out. A
    /// SEALED book keeps Reopen too, by the batch's brief: the phone has no
    /// Unseal door until wave 4 (VM-161), so the door stays and its refusal
    /// explains in the shared sentence. (A phone-side reading of the Mac's
    /// table until the door sets are hoisted — W-070, W-112.)
    nonisolated static func finishRowAct(for reading: Reading) -> FinishRowAct? {
        guard reading.kind == .book else { return reading.locked ? .reopen : nil }
        return reading.locked ? .reopen : .finish
    }

    /// **What the finish row says beside its door** (VM-81, W-106). The
    /// shipped "freezes its notes" was false — a finished book's text stays
    /// editable (AppSpec §7: assembly frozen, intake paused). The Mac's
    /// settings caption, its first sentence (the second says how a finished
    /// book opens on the Mac); a SEALED book says the sealed caption, because
    /// there the writing really can't change.
    nonisolated static func finishCaption(for reading: Reading) -> String {
        reading.sealedAt != nil ? BookStateCopy.sealedMeans : BookStateCopy.finishedMeans
    }

    /// **VM-81 — the Finish confirm, whole** (W-105): the alert's only input,
    /// so nothing it says can be read from a stale second piece of state (the
    /// Mac's `BookStateConfirm` lesson). The count lives in `line` alone (the
    /// act's own set, read by the dismissal's predicate) — as on the Mac,
    /// whose confirm carries no separate count (round 1, N3). `readingID` is
    /// the act's subject (`confirmFinish`).
    nonisolated struct FinishConfirm: Equatable, Identifiable, Sendable {
        let readingID: String
        let title: String
        let line: String
        var id: String { readingID }
    }

    // MARK: - Reads

    /// ONE read delivers the identity block coherently: the shelf row +
    /// the tags column + the daily designation (the shelf's own sources,
    /// so details can never disagree with the shelf).
    func refresh() async {
        do {
            let id = readingID
            let (books, tags, rules, dailyID, archived) = try await session.database.read { db in
                let books = try Queries.bookshelf(db)
                return (books,
                        try Queries.shelfBookTags(db),
                        try Queries.ruleTagPaths(db),
                        try Queries.dailyJournalBookID(db),
                        try Self.archivedBook(db, id: id, absentFrom: books))
            }
            book = books.first { $0.reading.id == id } ?? archived
            if let book {
                tagPaths = MobileShelfFaces.tagPaths(
                    for: book, curatedTags: tags, ruleTags: rules)
            }
            isDaily = dailyID == id
        } catch {
            lastRefusal = OpsRefusalCopy.refusalWords(for: error, roads: .phone)
        }
    }

    /// **VM-81 (W-120) — an ARCHIVED book resolves too.** The shelf's listing
    /// drops archived books (R-13ie-1 — the one choke point,
    /// `bookcaseReadings`), but archiving never unstars, so an archived book
    /// still opens from Starred — and its Details was EMPTY, with no way back.
    /// Only when the shelf does not hold it: the live, archived reading, with
    /// the shelf row's counts read for this one book (`liveMemberNoteCount` —
    /// the same members the shelf counts, read here with the note's liveness
    /// joined; the shelf's held read counts live member ROWS without that join,
    /// a P1 choice. Equal in a settled store — round 1, N8).
    nonisolated static func archivedBook(
        _ db: Database, id: String, absentFrom shelf: [Queries.ShelfBook]
    ) throws -> Queries.ShelfBook? {
        guard !shelf.contains(where: { $0.reading.id == id }),
              let reading = try Queries.reading(db, id: id), reading.archivedAt != nil
        else { return nil }
        return Queries.ShelfBook(
            reading: reading,
            postCount: try Queries.liveMemberNoteCount(db, readingID: id),
            sectionCount: try Queries.readingSections(db, readingID: id).count)
    }

    /// The identity block's two lines, through the ONE faces brain. An
    /// archived book says so in the shared mark ("Name (archived)" —
    /// `BookArchiveCopy`, the pickers' and chips' word).
    var nameLine: String? {
        book.map {
            BookArchiveCopy.name(
                MobileShelfFaces.name(for: $0), archived: $0.reading.archivedAt != nil)
        }
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

    /// **The Finish door was pressed** (VM-81, W-105 — her ruling; the Mac's
    /// `BookStateDoors.open(.finishBook)`). `lockReading` dismisses every
    /// waiting arrival in its own transaction (AppSpec §9), so when anything
    /// waits the door ASKS first, naming how many: N is read FRESH by the
    /// dismissal's own predicate (`Queries.pendingArrivalCount`), so the
    /// confirm can never promise a different set than the act takes. With
    /// nothing waiting it simply acts (`finishNeedsConfirm`). The Mac's
    /// "Open Arrivals first" button waits for the phone's Arrivals review
    /// (VM-175, wave 4).
    func requestFinish() async {
        let id = readingID
        let opening: (name: String, waiting: Int)?
        do {
            opening = try await session.database.read { db -> (name: String, waiting: Int)? in
                guard let reading = try Queries.reading(db, id: id) else { return nil }
                return (reading.name, try Queries.pendingArrivalCount(db, readingID: id))
            }
        } catch {
            lastError = DeletionRefusal.sentence(error, roads: .phone)
            return
        }
        guard let opening else {
            lastError = DeletionRefusal.sentence(OperationError.readingNotFound(id: id), roads: .phone)
            return
        }
        guard BookStateCopy.finishNeedsConfirm(pendingArrivals: opening.waiting) else {
            await setFinished(true)
            return
        }
        lastError = nil
        pendingFinish = FinishConfirm(
            readingID: id, title: BookStateCopy.finishTitle(opening.name),
            line: BookStateCopy.waitingLine(opening.waiting))
    }

    /// The confirm's Finish. The confirm is PASSED IN, never read back (the
    /// shelf's `confirmDeleteBook` rule — a binding setter clears
    /// `pendingFinish` before an action's task runs), and the act takes its
    /// subject from it (round 1, N3 — the Mac's confirm acts on its own
    /// `readingID` the same way).
    func confirmFinish(_ confirm: FinishConfirm) async {
        pendingFinish = nil
        let id = confirm.readingID
        await run { try $0.lockReading(id) }
    }

    /// The alert host's binding (`confirmDeleteBook`'s rule: the setter only
    /// ever clears; the act takes its subject as a parameter). It is also the
    /// alert's Cancel: the button acts nothing and SwiftUI's write-back
    /// clears the confirm (round 1, F5 retired a `cancelFinish()` that no
    /// face called).
    var finishConfirmPresented: Bool {
        get { pendingFinish != nil }
        set { if !newValue { pendingFinish = nil } }
    }

    /// **VM-81 (W-120) — whether this book's way out of the archive is drawn.**
    var offersUnarchive: Bool {
        book?.reading.archivedAt != nil
    }

    /// Unarchive — `unarchiveReading`, the book back on the shelf whole.
    func unarchive() async {
        let id = readingID
        await run { _ = try $0.unarchiveReading(id) }
    }

    /// Rename — free on a finished book (the Mac's renameReading has no
    /// lock guard; rename stays free under lock, the renameSection
    /// parallel). The face gates blank names.
    ///
    /// **THE DUPLICATE-NAME GUARD ARRIVES HERE AT PL-10(b)** (her 13e E13
    /// ruling: *refuse at the door*), the create sheet's twin. `excluding:`
    /// is THIS book's own row — renaming a book to the name it already has,
    /// or only changing its casing, is not a collision with itself, and
    /// without that argument this door could refuse her a rename it just
    /// performed. The read rides INSIDE the runner closure with the write,
    /// for the operation's own stated reason (runner bodies are
    /// synchronous, so nothing lands between the read and the update).
    func rename(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard Self.canRename(trimmed) else { return }
        let id = readingID
        await run { ops in
            try ops.assertBookNameIsFree(trimmed, excluding: id)
            try ops.renameReading(id, name: trimmed)
        }
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
            // VM-61: the shelf row's own delete line, said by this door too —
            // the same act, the same words, the same Put back (her ruling: a
            // delete answers with a line and Undo). VM-83 (W-073): the shelf
            // row's words name a GATHERING a gathering, so this door's do too.
            MobileLine.say(
                RecoveryCopy.movedToTrashReceipt(
                    .book, isGathering: book?.reading.kind == .gathering),
                as: .removal(.putBackBook(id)), session: session)
            return true
        } catch let error as OperationError {
            lastError = Self.refusal(error)
            return false
        } catch {
            lastRefusal = OpsRefusalCopy.refusalWords(for: error, roads: .phone)
            return false
        }
    }

    /// **13i-e U2 — ARCHIVE the daily Journal** (its delete row's place, P-2;
    /// the sitting record §10). Returns whether it went, so the sheet can
    /// dismiss — the archived Journal leaves the shelf behind it.
    @discardableResult
    func archiveDailyJournal() async -> Bool {
        let id = readingID
        do {
            try await session.runner.run { ops in try ops.archiveReading(id) }
            lastError = nil
            // VM-61: the shelf row's own archive line (same act, same words),
            // with Undo as the existing unarchive.
            if let name = book?.reading.name {
                MobileLine.say(
                    MobileShelfFaces.archivedDailyJournalReceipt(name: name),
                    as: .removal(.unarchiveBook(id)), session: session)
            }
            return true
        } catch {
            lastRefusal = OpsRefusalCopy.refusal(for: error, roads: .phone)
                ?? RefusalWords(DeletionRefusal.sentence(error, roads: .phone))
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
            lastRefusal = OpsRefusalCopy.refusalWords(for: error, roads: .phone)
        }
        await refresh()
    }

    /// **Forwards to the ONE deletion-refusal home** (A1-18) — this table
    /// and the Trash's covered different subsets of the same errors, so one
    /// refused act read two ways depending on the door.
    ///
    /// **One arm sits in front of it** (PL-10(b)): a taken book name is not
    /// a deletion refusal, so it is not `DeletionRefusal`'s to word — it has
    /// its own shared home, `BookNameCopy`, which the Mac's five book doors
    /// already speak. Routing here rather than copying the sentence is what
    /// keeps the two platforms saying the same thing (MobileSoul §3);
    /// without the arm it would fall to `DeletionRefusal.fallback`, whose
    /// honest last resort still ends in a raw `duplicateBookName(name:)`.
    /// (VM-62: the phone's road ends in the shared table, then the one plain
    /// fallback — never a dump: Finish on a gathering, Reopen on a sealed
    /// book.)
    nonisolated static func refusal(_ error: OperationError) -> String {
        if case .duplicateBookName(let existing) = error {
            return BookNameCopy.refusal(existing: existing)
        }
        // VM-81 (W-106) and round 1's F3 — Reopen on a SEALED book
        // (`readingSealed`) and a raced Unarchive (`readingNotArchived`) —
        // ride this road since VM-62: `DeletionRefusal` has no arm for either,
        // so both reach the shared table's sentence on the phone's roads ("This
        // book is sealed, so it can't be reopened here." · "That book isn't
        // archived any more — nothing changed."), never the raw enum.
        return DeletionRefusal.sentence(error, roads: .phone)
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
    /// VM-81: the Finish confirm's title, held so it never blanks while the
    /// alert animates away (the model clears `pendingFinish` on dismissal).
    @State private var finishTitle = BookStateCopy.finishVerb
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
            PhoneSheetHeader(tokens.chromeLabel("Book Details"), tokens: tokens) { dismiss() }
            if let book = model.book {
                identityBlock(book)
                // VM-81: a gathering draws no Finish (and no daily door), so the
                // state group — and its divider — draws only when it holds a row.
                if MobileBookDetailsModel.finishRowAct(for: book.reading) != nil
                    || MobileBookDetailsModel.showsDailyDoor(book.reading) {
                    Divider().overlay(tokens.line)
                    finishRow(book)
                    if MobileBookDetailsModel.showsDailyDoor(book.reading) {
                        dailyRow
                    }
                }
                Divider().overlay(tokens.line)
                if model.offersUnarchive {
                    // VM-81 (W-120): an archived book's way out. Delete stays
                    // beside it (the Mac's archived rows: Unarchive + Delete);
                    // the daily Journal keeps no Delete on the phone.
                    unarchiveRow(book.reading)
                    if !MobileShelfFaces.offersArchiveInsteadOfDelete(book.reading) {
                        deleteRow(book.reading.kind)
                    }
                } else if MobileShelfFaces.offersArchiveInsteadOfDelete(book.reading) {
                    // 13i-e U2 (P-2): the daily Journal's row is ARCHIVE.
                    archiveRow
                } else {
                    deleteRow(book.reading.kind)
                }
            }
            // VM-61: a refusal here speaks on the shell's one line, which
            // draws above this sheet.
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
        // VM-81 (W-105) — THE FINISH CONFIRM: the title and the Mac's line
        // ("N waiting at Arrivals will be dismissed."), Finish and Cancel. The
        // confirm rides into the action through `presenting:` (the shelf's
        // delete rule: a binding setter clears state before an action's task
        // runs, so the act takes its subject as a parameter).
        .alert(
            model.pendingFinish?.title ?? finishTitle,
            isPresented: $model.finishConfirmPresented,
            presenting: model.pendingFinish
        ) { confirm in
            Button(tokens.chromeLabel(BookStateCopy.finishVerb)) {
                let model = model
                Task { await model.confirmFinish(confirm) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: { confirm in
            Text(confirm.line)
        }
        .onChange(of: model.pendingFinish) { _, confirm in
            if let confirm { finishTitle = confirm.title }
        }
        // PR4's confirm — a real `@State` binding (§15's trap (a)).
        .alert(
            MobileShelfFaces.deleteConfirmTitle(for: model.book?.reading.kind ?? .book),
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

    /// **13i-e U2 — Archive** (the daily Journal's delete row's place): a
    /// plain Button acting at once (archive is reversible — the day brings it
    /// back), the §10 sentence beside it.
    private var archiveRow: some View {
        Button {
            let model = model
            Task {
                if await model.archiveDailyJournal() {
                    dismiss()
                    onDeleted?()
                }
            }
        } label: {
            HStack {
                Text(tokens.chromeLabel(MobileShelfFaces.archiveDailyJournalDoorTitle))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.accent)
                Spacer()
                Text(tokens.chromeLabel(MobileShelfFaces.archiveDailyJournalDetail))
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .lineLimit(3)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PhoneMenuRowStyle())
        .accessibilityLabel(MobileShelfFaces.archiveDailyJournalDoorTitle)
        // Ladder round 2, R2-N1: the caption the row draws, for VoiceOver.
        .accessibilityHint(MobileShelfFaces.archiveDailyJournalDetail)
    }

    /// **VM-81 (W-120) — Unarchive**, an archived book's way out: a plain
    /// Button acting at once (`unarchiveReading`; Archive is its way back, as
    /// on the Mac), beside the visible pause when there is one
    /// (`BookArchiveCopy.pausedSentence` — a living book or a gathering). No
    /// line after it: the sheet itself changes (the mark and this row go).
    private func unarchiveRow(_ reading: Reading) -> some View {
        Button {
            let model = model
            Task { await model.unarchive() }
        } label: {
            HStack {
                Text(tokens.chromeLabel(BookStateCopy.unarchiveVerb))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.accent)
                Spacer()
                if let paused = BookArchiveCopy.pausedSentence(for: reading) {
                    Text(tokens.chromeLabel(paused))
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                        .lineLimit(3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PhoneMenuRowStyle())
        .accessibilityLabel(BookStateCopy.unarchiveVerb)
        // Ladder round 2, R2-N1: the pause sentence the row draws, when it
        // draws one — no hint otherwise.
        .accessibilityHint(ifAny: BookArchiveCopy.pausedSentence(for: reading))
    }

    /// **Delete Book…** (PR4) — a plain Button, like every other act row
    /// here, so it is a door a pin can actually drive (§15's trap (b)).
    private func deleteRow(_ kind: ReadingKind) -> some View {
        Button {
            deletePresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel(MobileShelfFaces.deleteDoorTitle(for: kind)))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.alarm)
                Spacer()
                Text(tokens.chromeLabel(RecoveryCopy.deleteBookKeepsItsNotes))
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .lineLimit(2)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PhoneMenuRowStyle())
        .accessibilityLabel(MobileShelfFaces.deleteDoorTitle(for: kind))
        // Ladder round 2, R2-N1: the caption the row draws, for VoiceOver.
        .accessibilityHint(RecoveryCopy.deleteBookKeepsItsNotes)
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
                    .phoneType(.rowTitle, tokens)
                    .foregroundStyle(book.reading.locked ? tokens.accent : tokens.ink)
                    .lineLimit(2)
                    .phoneHitArea(alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Rename Book")
            if let meta = model.metaLine {
                Text(tokens.chromeLabel(meta))
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
            }
        }
    }

    /// Finish / Reopen — one state-mirroring row (the Mac menu's words).
    @ViewBuilder
    private func finishRow(_ book: Queries.ShelfBook) -> some View {
        if let act = MobileBookDetailsModel.finishRowAct(for: book.reading) {
            Button {
                let model = model
                Task {
                    switch act {
                    case .finish: await model.requestFinish()
                    case .reopen: await model.setFinished(false)
                    }
                }
            } label: {
                HStack {
                    Text(tokens.chromeLabel(act == .reopen
                        ? BookStateCopy.reopenVerb : BookStateCopy.finishVerb))
                        .phoneType(.control, tokens)
                        .foregroundStyle(tokens.accent)
                    Spacer()
                    // The Mac's sentence is longer than the shipped caption:
                    // three lines, the archive row's own cap.
                    Text(tokens.chromeLabel(
                        MobileBookDetailsModel.finishCaption(for: book.reading)))
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                        .lineLimit(3)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PhoneMenuRowStyle())
            // Round 1, F5: the row's verb as its label, like the archive,
            // unarchive and delete rows beside it — so VoiceOver and the
            // hosted pin name the door. Round 2, R2-N1: the caption the row
            // draws is its hint, so VoiceOver still hears what Finished means.
            .accessibilityLabel(act == .reopen ? BookStateCopy.reopenVerb : BookStateCopy.finishVerb)
            .accessibilityHint(MobileBookDetailsModel.finishCaption(for: book.reading))
        }
    }

    /// The daily-designation road (curated journal books only — P-2).
    private var dailyRow: some View {
        Button {
            let model = model
            Task { await model.designateDaily() }
        } label: {
            HStack {
                Text(tokens.chromeLabel("Use as Daily Journal"))
                    .phoneType(.control, tokens)
                    .foregroundStyle(model.isDaily ? tokens.phone.faint : tokens.accent)
                Spacer()
                if model.isDaily {
                    Text(tokens.chromeLabel("daily ✓"))
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                }
            }
            // VM-49: 44 tall; its own disabled read stays (the ✓ is a readout).
            .phoneHitArea(alignment: .leading)
        }
        .buttonStyle(.plain)
        .disabled(model.isDaily)
    }
}

private extension View {
    /// A VoiceOver hint only when there is one to give (ladder round 2,
    /// R2-N1 — the Unarchive row's pause sentence is drawn only for a living
    /// book or a gathering; elsewhere the row carries no hint at all).
    @ViewBuilder
    func accessibilityHint(ifAny hint: String?) -> some View {
        if let hint {
            accessibilityHint(hint)
        } else {
            self
        }
    }
}
