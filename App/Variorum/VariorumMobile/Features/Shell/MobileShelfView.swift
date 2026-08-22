//
//  MobileShelfView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home (M7), the ratified mockup
//  §1's shape: the voiced path line ("~/shelf · 6 books" / "Shelf · 6
//  books"), the book rows with LK5's faces (note count + tags lead; ✓
//  finished a STATE on the name), the Today's Entry button (terminal's
//  blinking block cursor riding it — the quick-entry idiom), the tab bar
//  below. The settings door rides the path line's trailing edge
//  (PROVISIONAL placement, recorded).
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
    /// The starred set (parity C3, her ruling 10): the section at the
    /// shelf's top + the book rows' star door (ONE model, threaded by
    /// the shell — the Mac StarDoor's one-value discipline).
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
    /// Open a note for reading/editing without raising the keyboard —
    /// a starred NOTE row's landing (parity C3).
    let onOpenNote: (String) -> Void
    let onSettings: () -> Void

    @State private var createBookPresented = false

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            // A5-6: a FIXED row under the path line and OUTSIDE the
            // ScrollView — it never scrolls away, and nothing below it
            // moves (the Today button and the starred section keep their
            // order and their feel, which was her constraint).
            MobileQuickNoteBox(
                model: quickNote, tokens: tokens, onOpen: onOpenForWriting)
            ScrollView {
                LazyVStack(spacing: 0) {
                    starredSection
                    ForEach(model.orderedBooks, id: \.reading.id) { book in
                        bookRow(book)
                    }
                    if model.orderedBooks.isEmpty {
                        Text(tokens.chromeLabel("No books yet — Today's Entry starts your journal."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 24)
                    }
                    newBookRow
                }
                .padding(.horizontal, 8)
                todayButton
            }
            if let report = model.lastReport {
                Text(tokens.chromeLabel(report))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        .task { await model.start() }
        .task { await model.refreshTags() }
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

    private func bookRow(_ book: Queries.ShelfBook) -> some View {
        Button {
            onOpenBook(book.reading.id)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // Terminal reserves the selection-marker column (the
                // mockup's alignment); the marker itself marks nothing at
                // rest — rows are doors, not a selection.
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
                Text(tokens.chromeLabel(model.rowMeta(for: book)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        }
    }

    /// The starred section (parity C3 — the face's home, this batch's
    /// call: the Mac's sidebar-top placement mirrored onto the phone's
    /// home surface). Renders only when anything is starred; rows
    /// navigate — book to its contents, note into its page.
    @ViewBuilder
    private var starredSection: some View {
        if !stars.items.isEmpty {
            HStack {
                Text(tokens.chromeLabel(MobileStarsModel.sectionHeader))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 2)
            ForEach(stars.items, id: \.target) { item in
                starredRow(item)
            }
            Divider()
                .overlay(tokens.line)
                .padding(.vertical, 6)
        }
    }

    private func starredRow(_ item: Queries.StarredItem) -> some View {
        Button {
            switch MobileStarsModel.route(for: item.target) {
            case .book(let id): onOpenBook(id)
            case .note(let id, _): onOpenNote(id)
            case .bookRead(let id): onOpenBook(id)
            }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("★")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel(stars.displayName(item)))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(item.target.kind == .reading ? "book" : "note"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(tokens.chromeLabel(MobileStarsModel.doorTitle(starred: true))) {
                let stars = stars
                let target = item.target
                Task { await stars.toggle(target, from: .shelf) }
            }
        }
    }

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

    /// "✎ today's entry ▊" — create-or-open, straight into the editor.
    private var todayButton: some View {
        Button {
            Task {
                if let postID = await model.openToday() {
                    onOpenForWriting(postID)
                }
            }
        } label: {
            HStack(spacing: 2) {
                Text(tokens.chromeLabel("✎ Today's Entry"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                if tokens.showsBlockCursor {
                    BlinkingCursorBlock(color: tokens.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(tokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(tokens.line, lineWidth: 1)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 10)
        .accessibilityLabel("Today's Entry")
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
