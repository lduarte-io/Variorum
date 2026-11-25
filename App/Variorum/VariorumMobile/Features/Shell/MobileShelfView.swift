//
//  MobileShelfView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home (M7), the ratified mockup
//  §1's shape: the voiced top line (since VM-255 the wing's name alone, the
//  count a quiet line under it), the book rows with LK5's faces (note count +
//  tags lead; ✓ finished a STATE on the name), the tab bar's place below. The
//  settings door (a gear again since VM-255) rides the line's trailing edge.
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
    /// VM-56 — the wing the phone stands in, named (her SW-1: the wing's
    /// name is the title on every root); nil while unknown.
    var wingName: String? = nil
    /// VM-225 — the wing's name in the path line is the interim wing door
    /// (the shell opens the list); nil in harness use draws the plain line.
    var onWingDoor: (() -> Void)? = nil
    /// The bar's place at the foot (VM-253: the shell hands its reserved place
    /// and draws the one bar over it, outside the band; a harness hands nothing).
    @ViewBuilder let tabBar: () -> TabBar
    let onOpenBook: (String) -> Void
    /// Open a note straight into typing — the Today button's landing AND
    /// the New Note door's (P33: "the note opens for writing").
    let onOpenForWriting: (String) -> Void
    // (The Trash room's SECOND renderer — batch 6c's finding 1, a deleted book
    // rows in the Trash — retired at VM-255, her words: "let's just only show
    // the trash icon within library." The Library's top line is its one door.)
    /// VM-48: the quick-entry box types in the note body, which follows the
    /// text size; the layout brain's floor is in lines of it.
    @Environment(\.dynamicTypeSize) private var typeSize

    @State private var createBookPresented = false
    /// VM-83: the delete confirm's title, held so a gathering's never flashes
    /// the book's word while the alert animates away (the model clears
    /// `pendingDeleteBook` on dismissal).
    @State private var deleteTitle = MobileShelfFaces.deleteConfirmTitle(for: .book)

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
                    writing: quickNote.isFocused ? .expanded : .collapsed,
                    // VM-48 (W-024): her floor in lines of the box's own
                    // text, at the current text size.
                    lineHeight: MobileShelfLayout.quickEntryLineHeight(
                        voice: tokens.voice, typeSize: typeSize))
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
                // VM-51 (R-47-1, "prose should not be on the tint"): her books
                // and the box she writes into on the paper; the path line, the
                // status lines and the tab bar stay on the room.
                .background(tokens.surface)
                // The two shapes are a state change she asked for, so it
                // reads as one motion rather than a jump. Chrome-only:
                // nothing here wakes the text layer (P3).
                .animation(.easeOut(duration: 0.18), value: quickNote.isFocused)
            }
            // VM-61: the shelf's report, its error and a star refusal speak
            // on the shell's one line (`MobileMessageLine`), never here.
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        // VM-47 (the walk's W-A1, redone): the strips beyond the shell's band —
        // the path line's room above, the bar's room below.
        .mobileEdgeGrounds(top: tokens.room, bottom: tokens.room)
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
            model.pendingDeleteBook.map {
                MobileShelfFaces.deleteConfirmTitle(for: $0.reading.kind)
            } ?? deleteTitle,
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
        .onChange(of: model.pendingDeleteBook) { _, book in
            if let book { deleteTitle = MobileShelfFaces.deleteConfirmTitle(for: book.reading.kind) }
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
                            .foregroundStyle(tokens.phone.muted)
                    }
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
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

    /// **The top line** (VM-255 — her four changes): the wing's name ALONE, the
    /// wing door (R-260-1: "it says on the bottom what area you're in" — the
    /// page word left; Study "Home", Terminal "~/home"), with the Bookcase's
    /// count as a quiet muted line UNDER it, inside the door's 44 pt box
    /// (R-260-6, "12 books"); trailing, the Mac's writing glyph for New Note
    /// (P33 — the Library's twin) and the Settings gear (S-260-1, the ⋯ gone).
    /// No trash door here ("only show the trash icon within library").
    ///
    /// **ONE 44 pt line** (VM-50): the doors are the phone's icon buttons with
    /// 44 pt hit areas that touch; the name's two lines sit inside the door's
    /// own 44. Pinned by `MobilePathLineGeometryTests`.
    private var pathLine: some View {
        HStack(alignment: .center, spacing: 0) {
            MobileWingPath(
                tokens: tokens, wing: wingName,
                detail: tokens.chromeLabel(MobileShelfFaces.bookCount(model.books.count)),
                onDoor: onWingDoor)
            Spacer(minLength: PhoneMetrics.Space.s16)
            MobileNewNoteGlyphDoor(tokens: tokens) {
                Task {
                    if let postID = await model.newNote() {
                        onOpenForWriting(postID)
                    }
                }
            }
            MobileSettingsGear(tokens: tokens)
        }
        .padding(.horizontal, PhoneMetrics.gutter)
        .padding(.top, PhoneMetrics.Space.s4)
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
                    // at rest — rows are doors, not a selection. A marker is
                    // chrome, so `meta` (batch 1's role map; the wing list's
                    // ✓ column): it holds at xxxLarge, where `rowTitle` grew
                    // with her words to ≈55 pt at AX5 and left two letters of
                    // a name (VM-47, the walk's W-A3).
                    if !tokens.selectionMarker.isEmpty {
                        Text(tokens.selectionMarker)
                            .phoneType(.meta, tokens)
                            .foregroundStyle(tokens.accent)
                            .opacity(0)
                    }
                    Text(tokens.chromeLabel(model.rowName(for: book)))
                        .phoneType(.rowTitle, tokens)
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
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                        .lineLimit(1)
                }
                // The padding rides INSIDE the button's label, so the whole
                // row height is the tap target — and so the row's own
                // accessibility frame is the row, not the text line inside
                // it. (Measured: with the padding on the enclosing HStack
                // the element came back 17 pt tall against a 39 pt row.)
                .padding(.vertical, 11)
                .padding(.leading, 12)
                .phoneHitArea(alignment: .leading)
            }
            .buttonStyle(.plain)
            if isDaily {
                todayBadge
            }
        }
        .padding(.trailing, 12)
        // The long-press menu (parity C2/C3 — the Mac shelf row's own context
        // menu, the phone's long-press grammar): Star, then Delete (or
        // Archive on the daily Journal); the book's other acts live on its
        // details surface. VM-83 (W-071): the Pin door is retired — it wrote
        // the same star. The menu is the model's act table (`rowActs`), drawn
        // in its order — the doors are data, so a pin reads what she sees.
        .contextMenu {
            let target = StarTarget.reading(book.reading.id)
            ForEach(
                Array(model.rowActs(for: book, starred: stars.isStarred(target)).enumerated()),
                id: \.offset
            ) { _, act in
                rowActButton(act, book: book, target: target)
            }
        }
    }

    /// One act of the row's menu. Star (parity C3) lifts the book to the top
    /// of the shelf. Delete (round 2 batch 4 — PR4): the confirm and the
    /// wording are the model's, so this door and the book-details door
    /// cannot describe one act two ways. 13i-e U2 (P-2; the sitting record
    /// §10): the daily Journal's row offers ARCHIVE in Delete's place.
    @ViewBuilder
    private func rowActButton(
        _ act: MobileShelfRowAct, book: Queries.ShelfBook, target: StarTarget
    ) -> some View {
        switch act {
        case .star:
            Button(tokens.chromeLabel(act.title)) {
                let stars = stars
                Task { await stars.toggle(target, from: .shelf) }
            }
        case .archiveDailyJournal:
            Button(tokens.chromeLabel(act.title)) {
                let model = model
                Task { await model.archiveDailyJournal(book) }
            }
        case .delete:
            Button(tokens.chromeLabel(act.title), role: .destructive) {
                model.requestDeleteBook(book)
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
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .phoneHitArea(alignment: .leading)
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
        }
        // VM-50: the chip (sheet §E's Today door — a 32 pt capsule, 15
        // medium, a 44 pt hit area), replacing the badge's own calm build.
        .buttonStyle(PhoneChipStyle(tokens: tokens))
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
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .phoneHitArea(alignment: .leading)
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
