//
//  MobileShelfView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home (M7), the ratified mockup
//  §1's shape: the voiced path line ("~/shelf · 6 books" / "Shelf · 6
//  books"), the book rows with LK5's faces (note count + tags lead; ✓
//  finished a STATE on the name), the tab bar below. The settings door
//  rides the path line's trailing edge (PROVISIONAL placement, recorded).
//
//  ── ROUND 2, BATCH 5 — HER R26/R27 LAYOUT ─────────────────────────────
//  She said it twice: *"I still see today's entry where i don't want it
//  and the quick note where i don't want it."* Three changes, one shape
//  (§40/§41 of `mobile-round-2.md`):
//
//  1. **The quick-note box takes Today's Entry's place** — its own
//     separated box below `+ new book`, and it is the shelf's MAIN area.
//  2. **The books list is BOUNDED and scrolls inside itself.** Past ~8
//     books the LIST scrolls; it never pushes the writing area down.
//  3. **The writing area is about half the phone screen.** The
//     proportions are `MobileShelfLayout`'s — a pure brain, because they
//     are a rule and not a modifier, and because the keyboard case (§53
//     row 6) is exactly the same arithmetic with a smaller region.
//  3b. **HER TWO 2026-08-30 REFINEMENTS, after reading the result:** the
//     box is **one line until she clicks into it** (so the books have the
//     room at rest, and the writing area opens exactly when it is wanted),
//     and the shelf is **bounded so there is ALWAYS decent room to write**
//     — the floor is now a GUARANTEE, pinned as a promise rather than as
//     the arithmetic that happens to produce it.
//  4. **Today's Entry is now a BADGE on the Journal book's row** (R26.2),
//     carrying NO blinking cursor (R26.3 — the blinking block is the
//     terminal voice's QUICK-ENTRY idiom, and now that a real quick-note
//     box exists the cursor belongs to it; the badge was only ever
//     borrowing it). When no book on the shelf is the daily journal, the
//     door falls back to its own row at the end of the list, so it is
//     reachable in every state (§40's open consequence, answered).
//
//  Reading is cheap: the one LIVE editor never lives here (P3); the list
//  is author-scale (a shelf holds books, not corpus). Since round 2's M5
//  the surface does carry ONE focusable control — the quick-note box's
//  plain `TextField` — which is not an editor in the invariant's sense:
//  it mounts no TK2 surface, holds no `BlockRangeIndex`, and is not a
//  `MobileEditorViewModel`, so the one-live-ring invariant is not
//  extended here, it is simply not engaged (the Mac pad's own reasoning,
//  and the Library tab has shipped a `TextField` on this same composition
//  since parity C3).
//

import SwiftUI
import VariorumCore

struct MobileShelfView<TabBar: View>: View {
    @Bindable var model: MobileShelfViewModel
    /// The starred set (parity C3, her ruling 10) — since batch 10 this
    /// surface wears only the book rows' STAR DOOR and the star refusal's
    /// message slot; the starred LIST moved to its own page at her word
    /// (*"I don't like where it appears above the shelf, I think it's
    /// awkward placing"*). Still ONE model, threaded by the shell — the Mac
    /// StarDoor's one-value discipline.
    @Bindable var stars: MobileStarsModel
    /// The home-screen quick note (round 2, M5). Owned by the shell router
    /// so the app-lifecycle seam can reach it; the shelf only wears it.
    @Bindable var quickNote: MobileQuickNoteModel
    let tokens: VoiceTokens
    @ViewBuilder let tabBar: () -> TabBar
    let onOpenBook: (String) -> Void
    /// Open a note straight into typing — the Today button's landing AND
    /// the + New Note door's (P33: "the note opens for writing").
    let onOpenForWriting: (String) -> Void
    let onSettings: () -> Void
    /// **The Trash room's door, SECOND renderer** (batch 6c — the design
    /// record's finding 1, and PROVISIONAL by its Q6). Books live HERE and
    /// a deleted book rows in the Trash, so a trash door reachable only from
    /// the Library would put a tab switch between deleting a book and
    /// getting it back. One declaration (`MobileRecoveryDoors`), two
    /// renderers, no new surface. nil in harness/preview use.
    var onOpenTrash: (() -> Void)?

    @State private var createBookPresented = false

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            // R27: the books region and the writing region SHARE this
            // space by rule. The reader is real — it already carries the
            // safe areas, the path line, the status rows, the tab bar,
            // and (the §53 row 6 case) the keyboard's own inset — so the
            // brain never has to guess at any of them.
            GeometryReader { proxy in
                let split = MobileShelfLayout.split(
                    region: proxy.size.height,
                    bookRows: model.orderedBooks.count,
                    extraRows: extraBooksRegionRows,
                    // Her 2026-08-30 ruling: one line until she clicks in.
                    writing: quickNote.isFocused ? .expanded : .collapsed)
                VStack(spacing: 0) {
                    booksRegion
                        .frame(height: split.booksHeight)
                        .accessibilityIdentifier("shelf.booksRegion")
                    MobileQuickNoteBox(
                        model: quickNote, tokens: tokens,
                        writingHeight: split.writingHeight,
                        onOpen: onOpenForWriting)
                        .frame(height: split.writingHeight, alignment: .top)
                        .accessibilityIdentifier("shelf.writingRegion")
                }
                .frame(
                    width: proxy.size.width, height: proxy.size.height,
                    alignment: .top)
                // The two shapes are a state change she asked for, so it
                // reads as one motion rather than a jump. Chrome-only:
                // nothing here wakes the text layer (P3).
                .animation(.easeOut(duration: 0.18), value: quickNote.isFocused)
            }
            if let report = model.lastReport {
                Text(tokens.chromeLabel(report))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let starsError = stars.error(on: .shelf) {
                // A star refusal fired HERE (D2 — one home per refusal:
                // it speaks at its own door's root and clears after a
                // beat; the old one-field rendering sat on both tabs).
                Text(tokens.chromeLabel(starsError))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        .task { await model.start() }
        .task { await model.refreshTags() }
        // PR4's confirm. `$model.deleteBookPresented` is a real `@Bindable`
        // projection over the observable model — never a computed
        // `Binding(get:set:)` (§15's trap (a), the Mac's dead purge doors) —
        // AND the book rides into the action closure through `presenting:`,
        // which is the half batch 4 was missing: read back after SwiftUI's
        // dismissal, it was already `nil` and the book was never deleted
        // (batch 4.5b's BLOCKER; the rule is at
        // `MobileShelfViewModel.deleteBookPresented`). The message now names
        // the book from the SAME captured value, so it can never blank
        // mid-presentation either.
        .alert(
            MobileShelfFaces.deleteBookConfirmTitle,
            isPresented: $model.deleteBookPresented,
            presenting: model.pendingDeleteBook
        ) { book in
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task { await model.confirmDeleteBook(book) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: { book in
            Text(MobileShelfFaces.deleteBookConfirmDetail(
                name: book.reading.name))
        }
    }

    // MARK: - The books region (R27.2 — bounded, and it scrolls)

    /// The trailing doors the region always or sometimes carries, counted
    /// for the layout brain: `+ new book`, plus the Today fallback row
    /// when no book on the shelf is the daily journal.
    private var extraBooksRegionRows: Int {
        showsTodayFallbackRow ? 2 : 1
    }

    /// R26.2's open consequence, answered: the badge hangs off the daily
    /// journal's row, so the door needs a home when that row does not
    /// exist — a fresh account with no Journal, or one she deleted.
    /// (R27b seeds a Journal on a genuinely new store, so this is the
    /// deliberate-deletion and arriving-from-an-existing-account case.)
    private var showsTodayFallbackRow: Bool {
        !model.orderedBooks.contains { $0.reading.id == model.dailyBookID }
    }

    private var booksRegion: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.orderedBooks, id: \.reading.id) { book in
                    bookRow(book)
                }
                if model.orderedBooks.isEmpty {
                    // Act 0: a fresh install now genuinely holds nothing
                    // until she writes, so the empty shelf names BOTH
                    // roads — start one, or bring yours down.
                    VStack(spacing: 6) {
                        Text(tokens.chromeLabel(MobileEmptyStoreCopy.noBooks))
                        Text(tokens.chromeLabel(MobileEmptyStoreCopy.signIn))
                            .foregroundStyle(tokens.faint)
                    }
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                newBookRow
                if showsTodayFallbackRow {
                    todayFallbackRow
                }
            }
            .padding(.horizontal, 8)
        }
    }

    /// "~/shelf · 6 books" (terminal) / "Shelf · 6 books" (study); the
    /// + New Note door (P33 — Library's twin, same path-line placement)
    /// and the settings door trailing.
    private var pathLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(tokens.path(["Shelf"]) + tokens.chromeLabel("  ·  \(model.books.count) book\(model.books.count == 1 ? "" : "s")"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            if let onOpenTrash {
                MobileTrashDoor(tokens: tokens, act: onOpenTrash)
            }
            Button {
                Task {
                    if let postID = await model.newNote() {
                        onOpenForWriting(postID)
                    }
                }
            } label: {
                Text(tokens.chromeLabel(MobileNewNoteDoor.doorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New Note")
            Button {
                onSettings()
            } label: {
                Text(tokens.chromeLabel("Settings"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    /// One book's row. Since batch 5 the row is an HStack of two doors
    /// rather than one Button — a Button nested inside another Button's
    /// label is swallowed by the outer one, and R26.2 puts a real door
    /// (the Today badge) on this row.
    private func bookRow(_ book: Queries.ShelfBook) -> some View {
        let isDaily = book.reading.id == model.dailyBookID
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            Button {
                onOpenBook(book.reading.id)
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    // Terminal reserves the selection-marker column (the
                    // mockup's alignment); the marker itself marks nothing
                    // at rest — rows are doors, not a selection.
                    if !tokens.selectionMarker.isEmpty {
                        Text(tokens.selectionMarker)
                            .font(tokens.body)
                            .foregroundStyle(tokens.accent)
                            .opacity(0)
                    }
                    Text(tokens.chromeLabel(model.rowName(for: book)))
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(book.reading.locked ? tokens.accent : tokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    // The badge IS the daily marker, so the meta line does
                    // not also say "daily" on the row that wears it — one
                    // marker for one fact, and phone width is scarce.
                    // (PROVISIONAL: a view-level call. The brain is
                    // untouched, so every other surface still reads
                    // `meta(…, isDaily:)` exactly as before.)
                    Text(tokens.chromeLabel(model.rowMeta(for: book, showingDailyMarker: !isDaily)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                // The padding rides INSIDE the button's label, so the whole
                // row height is the tap target — and so the row's own
                // accessibility frame is the row, not the text line inside
                // it. (Measured: with the padding on the enclosing HStack
                // the element came back 17 pt tall against a 39 pt row.)
                .padding(.vertical, 11)
                .padding(.leading, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if isDaily {
                todayBadge
            }
        }
        .padding(.trailing, 12)
        // Pin/unpin (parity C2): the long-press menu — the act belongs
        // where the list it orders lives (the Mac shelf row's own context
        // menu, the phone's long-press grammar). One state-mirroring door;
        // the book's other acts live on its details surface, not here.
        .contextMenu {
            let pinned = model.pins.contains(book.reading.id)
            Button(tokens.chromeLabel(MobileShelfFaces.pinDoorTitle(pinned: pinned))) {
                Task { await model.setPinned(book.reading.id, pinned: !pinned) }
            }
            // Star (parity C3) — deliberately beside Pin, the Mac 13f
            // adjacency: pinning orders THIS list; a star lifts the book
            // to the starred section at the top.
            let target = StarTarget.reading(book.reading.id)
            Button(tokens.chromeLabel(
                MobileStarsModel.doorTitle(starred: stars.isStarred(target)))) {
                let stars = stars
                Task { await stars.toggle(target, from: .shelf) }
            }
            // Delete the book (round 2 batch 4 — PR4). The row's long-press
            // is where its other acts already live; the confirm and the
            // wording are the model's, so this door and the book-details
            // door cannot describe one act two ways.
            // 13i-e U2 (P-2; the sitting record §10): the daily Journal can
            // be archived, never deleted — its row offers ARCHIVE instead.
            if MobileShelfFaces.offersArchiveInsteadOfDelete(book.reading) {
                Button(tokens.chromeLabel(MobileShelfFaces.archiveDailyJournalDoorTitle)) {
                    let model = model
                    Task { await model.archiveDailyJournal(book) }
                }
            } else {
                Button(
                    tokens.chromeLabel(MobileShelfFaces.deleteBookDoorTitle),
                    role: .destructive
                ) {
                    model.requestDeleteBook(book)
                }
            }
        }
    }

    // **THE STARRED SECTION IS RETIRED FROM THIS SURFACE** (batch 10 —
    // her words: *"we have the ability to star a note but I don't like
    // where it appears above the shelf, I think it's awkward placing"*).
    //
    // It is a MOVE, not a deletion: the header, the rows and the un-star
    // door all live on `MobileStarredView` now, reached by the band's
    // swipe-right and by the tab bar's own door. Retiring it here is what
    // the brief conditions on — *"should STOP rendering there only if the
    // new face replaces its job"* — and the new face replaces it whole,
    // including the books the shelf section also listed.
    //
    // Two consequences, both deliberate: the books region no longer
    // reserves height for stars (the layout brain's `starredRows` parameter
    // was retired with them at the cold review's NIT 1 — its only caller had
    // been passing `0`), and the shelf's `onOpenNote` callback went with the
    // rows that were its only caller.
    // What STAYS here is the shelf's own star DOOR (the book row's
    // long-press) and its message slot, because the door still fires here.

    /// "+ new book" (parity C2 — her feel-round finding): the list's own
    /// trailing row, where a list of books naturally ends with the door
    /// that adds one; the path line stays two doors wide (the P38
    /// crowding lesson). Opens the create sheet; the created book lands
    /// on its contents front.
    private var newBookRow: some View {
        Button {
            createBookPresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel(MobileCreateBookSheet.doorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New Book")
        .sheet(isPresented: $createBookPresented) {
            MobileCreateBookSheet(
                session: model.session, tokens: tokens,
                onCreated: { onOpenBook($0) })
        }
    }

    // MARK: - Today's Entry (R26.2 — a badge, not a button of its own)

    /// The badge beside the Journal book's name. NO blinking cursor
    /// (R26.3): the block cursor is the quick-entry idiom and it went
    /// home to the quick-note box. The words live on `MobileShelfFaces`
    /// so this door and its fallback row cannot drift.
    private var todayBadge: some View {
        Button {
            openToday()
        } label: {
            Text(tokens.chromeLabel(MobileShelfFaces.todayDoorTitle))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(tokens.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(tokens.line, lineWidth: 1)))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MobileShelfFaces.todayDoorSpoken)
    }

    /// The same door as its own row, for the states in which no shelf row
    /// can carry the badge. `shelveInDailyJournalBook` creates and pins
    /// the Journal book when none is designated (AppSpec §9, her 13d
    /// #37(iii) ruling), so pressing this is also how a shelf that lost
    /// its Journal gets one back — deliberately, by her asking.
    private var todayFallbackRow: some View {
        Button {
            openToday()
        } label: {
            HStack {
                Text(tokens.chromeLabel(MobileShelfFaces.todayDoorRowTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MobileShelfFaces.todayDoorSpoken)
    }

    private func openToday() {
        Task {
            if let postID = await model.openToday() {
                onOpenForWriting(postID)
            }
        }
    }
}

/// The terminal quick-entry idiom: a blinking block cursor
/// (`VoiceTokens.showsBlockCursor` — R1's "special little ways").
struct BlinkingCursorBlock: View {
    let color: Color
    @State private var on = true

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 7, height: 14)
            .opacity(on ? 1 : 0)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(550))
                    on.toggle()
                }
            }
            .accessibilityHidden(true)
    }
}
