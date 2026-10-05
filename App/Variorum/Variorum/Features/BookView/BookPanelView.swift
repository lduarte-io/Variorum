//
//  BookPanelView.swift
//  Variorum (Mac)
//
//  13i-d U2 — THE BOOK PANEL's face: the note's book as a table of contents
//  in the note's side column (the tray / scraps / references room), the open
//  note marked. Her design — the identity brief's round 5; the reasoning and
//  every rule behind it are in `BookPanelModel.swift`.
//
//  ── THE IDIOM ─────────────────────────────────────────────────────────────
//  The book NAVIGATOR's own (her "clean, and I like it"): chapter rows with
//  the grip and the accent name at the chapter pitch, note rows at the note
//  pitch, nested under their chapter, the voice's selection marker on the
//  open note, "unfiled" over the stragglers — `BookNavigatorLayout`'s
//  numbers, so the panel and the navigator are one grammar at two sizes.
//

import SwiftUI
import VariorumCore

struct BookPanelView: View {
    /// P-1's declared ⇔ rendered walk. The row MENUS carry the five structure
    /// doors (each a drag's twin) and the remove/release door; INLINE, a row's
    /// click is the ascent and a gathering's "remove #tag" its honest door.
    static let contextMenuCapabilities: [CapabilityID] = [
        .fileNoteInChapter, .moveNoteUpInBook, .moveNoteDownInBook,
        .moveChapterUpInBook, .moveChapterDownInBook, .removeFromBook,
    ]
    static let surfaceCapabilities: [CapabilityID] = [.openBookAtNote, .removeRuleTag]

    let session: AppSession
    let postID: String
    /// The note detail's membership observation (row 104's model), handed
    /// down — the panel never reads the note's books a second time.
    let membership: NoteMembershipModel
    var recentBookIDs: [String] = []
    var onClose: (() -> Void)?

    @State private var model: BookPanelModel
    @State private var gatheringsOpen = false
    @State private var wornTags: [String: [VariorumCore.Tag]] = [:]
    /// The line a drag hovers (the insertion hairline's place).
    @State private var dropTarget: String?
    /// The book whose table of contents has been brought to the open note
    /// (once per book — a later delivery never yanks her scroll).
    @State private var revealedIn: String?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String, membership: NoteMembershipModel,
        recentBookIDs: [String] = [], onClose: (() -> Void)? = nil
    ) {
        self.session = session
        self.postID = postID
        self.membership = membership
        self.recentBookIDs = recentBookIDs
        self.onClose = onClose
        _model = State(initialValue: BookPanelModel(session: session, postID: postID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        let readings = membership.readings(for: postID)
        let books = BookPanelBrain.switcherBooks(readings, recentlyVisited: recentBookIDs)
        let shown = BookPanelBrain.shownBook(
            readings, chosen: model.chosenBookID, recentlyVisited: recentBookIDs)
        VStack(alignment: .leading, spacing: 8) {
            header(shown, books: books)
            if let shown {
                contents(shown)
            } else {
                Text(tokens.chromeLabel(BookPanelCopy.inNoBook))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            gatheringsLine(membership.gatherings(for: postID))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.surface)
        // The shown book's contents, held while it shows — a switch restarts.
        .task(id: shown?.id) {
            if let id = shown?.id { await model.observe(bookID: id) }
        }
    }

    // MARK: - The header (the switcher atop, for a shared note)

    @ViewBuilder
    private func header(_ shown: Reading?, books: [Reading]) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if let shown, books.count > 1 {
                VoicedMenu(tokens: tokens, label: shown.name, role: .secondary) {
                    // An inline picker: the menu's native checkmark marks the
                    // book on show (U1's order-menu lesson).
                    Picker("", selection: Binding(
                        get: { shown.id },
                        set: { model.chosenBookID = $0 })
                    ) {
                        ForEach(books, id: \.id) { book in
                            // 13i-e U2: an archived book named "(archived)".
                            Text(BookArchiveCopy.name(book)).tag(book.id)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .help(BookPanelCopy.switcherHelp)
            } else if let shown {
                Text(shown.name)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer(minLength: 4)
            if let onClose {
                Button(BookPanelCopy.close) { onClose() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            }
        }
        if let shown, let state = BookPanelCopy.stateWords(shown) {
            Text(tokens.chromeLabel(state))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
        }
    }

    // MARK: - The table of contents

    @ViewBuilder
    private func contents(_ book: Reading) -> some View {
        if let snapshot = model.snapshot(for: book.id) {
            let groups = model.groups(for: book.id)
            let lines = BookPanelBrain.lines(groups)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: BookNavigatorLayout.rowSpacing) {
                        ForEach(lines) { line in
                            lineView(line, book: book, snapshot: snapshot, groups: groups)
                                .id(line.id)
                        }
                        if snapshot.truncated {
                            Text(tokens.chromeLabel(BookPanelCopy.windowed(BookPanelModel.entryWindow)))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(2)
                                .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
                // The open note, brought into view once per book — never a
                // second landing mechanism, just the panel's own scroll.
                .onAppear { reveal(in: book.id, lines: lines, proxy: proxy) }
                .onChange(of: book.id) { _, _ in reveal(in: book.id, lines: lines, proxy: proxy) }
            }
        } else {
            Spacer(minLength: 0)
        }
    }

    private func reveal(in bookID: String, lines: [BookPanelBrain.Line], proxy: ScrollViewProxy) {
        guard revealedIn != bookID else { return }
        let target = lines.first { line in
            switch line {
            case .note(let entry, _): entry.postID == postID
            case .chapter(_, let collapsed): collapsed?.postID == postID
            case .unfiled: false
            }
        }
        guard let target else { return }
        revealedIn = bookID
        proxy.scrollTo(target.id, anchor: .center)
    }

    @ViewBuilder
    private func lineView(
        _ line: BookPanelBrain.Line, book: Reading, snapshot: BookPanelModel.Snapshot,
        groups: [BookPanelBrain.Group]
    ) -> some View {
        switch line {
        case .chapter(let section, let collapsed):
            chapterRow(section, collapsed: collapsed, line: line, book: book,
                       snapshot: snapshot, groups: groups)
        case .unfiled:
            Text(tokens.chromeLabel(BookPanelCopy.unfiled))
                .font(tokens.small.weight(.semibold))
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: BookNavigatorLayout.chapterRowHeight,
                       alignment: .leading)
                .contentShape(Rectangle())
                .panelDropSite(line.id, target: $dropTarget, tokens: tokens) { drag in
                    Task { await model.drop(drag, onto: .unfiled, in: book) }
                }
        case .note(let entry, let indented):
            noteRow(entry, indented: indented, line: line, book: book,
                    snapshot: snapshot, groups: groups)
        }
    }

    private func chapterRow(
        _ section: ReadingSection, collapsed: Queries.ReadingEntry?, line: BookPanelBrain.Line,
        book: Reading, snapshot: BookPanelModel.Snapshot, groups: [BookPanelBrain.Group]
    ) -> some View {
        let marked = collapsed?.postID == postID
        let gripDrawn = BookPanelBrain.chapterGripDrawn(chapterCount: snapshot.sections.count)
        return Button {
            // A collapsed one-note chapter row IS the note's row (row 8):
            // its click is that note's click-through. A plain heading is a
            // heading — its menu and its drag are its doors.
            if let collapsed { model.open(book: book, at: collapsed.postID) }
        } label: {
            HStack(spacing: 4) {
                // A lone chapter's grip is not drawn (#184(b)) — by OPACITY in
                // a slot every chapter row keeps, so the names never shift as
                // the chapter count crosses 1↔2 (the B2 ladder's NIT-3; the
                // Bookcase grip column's own idiom).
                Text("\u{283F}")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .opacity(gripDrawn ? 1 : 0)
                    .accessibilityHidden(!gripDrawn)
                if marked { marker }
                Text(tokens.chromeLabel(section.name))
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: BookNavigatorLayout.chapterRowHeight,
                   alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(collapsed.map { _ in BookPanelCopy.openHelp(book: book.name) } ?? "")
        .contextMenu {
            chapterMenu(section, book: book, snapshot: snapshot)
            if let collapsed {
                Divider()
                noteMenu(collapsed.postID, book: book, snapshot: snapshot, groups: groups)
            }
        }
        .draggable(BookPanelDragToken(.chapter(section.id)))
        .panelDropSite(line.id, target: $dropTarget, tokens: tokens) { drag in
            Task { await model.drop(drag, onto: .chapter(section.id), in: book) }
        }
    }

    private func noteRow(
        _ entry: Queries.ReadingEntry, indented: Bool, line: BookPanelBrain.Line,
        book: Reading, snapshot: BookPanelModel.Snapshot, groups: [BookPanelBrain.Group]
    ) -> some View {
        let isThis = entry.postID == postID
        return Button {
            model.open(book: book, at: entry.postID)
        } label: {
            HStack(spacing: 2) {
                if isThis { marker }
                Text(entry.displayTitle)
                    .font(isThis ? tokens.small.weight(.semibold) : tokens.small)
                    .foregroundStyle(isThis ? tokens.ink : tokens.muted)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.leading, indented ? 10 : 0)
            .frame(maxWidth: .infinity, minHeight: BookNavigatorLayout.noteRowHeight,
                   alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isThis
              ? BookPanelCopy.thisNoteHelp + " \u{2014} " + BookPanelCopy.openHelp(book: book.name)
              : BookPanelCopy.openHelp(book: book.name))
        .contextMenu { noteMenu(entry.postID, book: book, snapshot: snapshot, groups: groups) }
        .draggable(BookPanelDragToken(.note(entry.postID)))
        .panelDropSite(line.id, target: $dropTarget, tokens: tokens) { drag in
            Task { await model.drop(drag, onto: .note(entry.postID), in: book) }
        }
    }

    /// The open note's mark — the voice's own selection marker (the
    /// navigator's), in the accent; Study's empty marker leaves the weight
    /// and the ink to say it.
    @ViewBuilder private var marker: some View {
        if !tokens.selectionMarker.isEmpty {
            Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                .font(tokens.small.weight(.bold))
                .foregroundStyle(tokens.accent)
        }
    }

    // MARK: - The row menus (each drag's twin; the remove door)

    @ViewBuilder
    private func noteMenu(
        _ notePostID: String, book: Reading, snapshot: BookPanelModel.Snapshot,
        groups: [BookPanelBrain.Group]
    ) -> some View {
        if !snapshot.sections.isEmpty {
            Menu(CapabilityRegistry.capability(.fileNoteInChapter).verb) {
                ForEach(snapshot.sections, id: \.id) { section in
                    Button(section.name) {
                        Task { await model.file(notePostID, in: book, chapter: section.id) }
                    }
                }
                Divider()
                Button(BookPanelCopy.noChapter) {
                    Task { await model.file(notePostID, in: book, chapter: nil) }
                }
            }
        }
        let manual = snapshot.reading?.sortField == .manual
        if BookPanelBrain.noteMove(notePostID, up: true, groups: groups, manualOrder: manual) != nil {
            Button(CapabilityRegistry.capability(.moveNoteUpInBook).verb) {
                Task { await model.move(notePostID, in: book, up: true) }
            }
        }
        if BookPanelBrain.noteMove(notePostID, up: false, groups: groups, manualOrder: manual) != nil {
            Button(CapabilityRegistry.capability(.moveNoteDownInBook).verb) {
                Task { await model.move(notePostID, in: book, up: false) }
            }
        }
        Divider()
        // §20: one act, the book's word ("Release from This Book" on an
        // owned book — the note goes back to the Pool, whole).
        Button(RemoveFromBookCopy.verb(owned: book.owned)) {
            Task { await model.remove(notePostID, from: book) }
        }
    }

    @ViewBuilder
    private func chapterMenu(
        _ section: ReadingSection, book: Reading, snapshot: BookPanelModel.Snapshot
    ) -> some View {
        if BookPanelBrain.chapterMove(section.id, up: true, sections: snapshot.sections) != nil {
            Button(CapabilityRegistry.capability(.moveChapterUpInBook).verb) {
                Task { await model.moveChapter(section.id, in: book, up: true) }
            }
        }
        if BookPanelBrain.chapterMove(section.id, up: false, sections: snapshot.sections) != nil {
            Button(CapabilityRegistry.capability(.moveChapterDownInBook).verb) {
                Task { await model.moveChapter(section.id, in: book, up: false) }
            }
        }
    }

    // MARK: - "appears in N gatherings" (names on click — §15, ruled)

    @ViewBuilder
    private func gatheringsLine(_ gatherings: [Reading]) -> some View {
        if let line = BookPanelCopy.gatheringsLine(count: gatherings.count) {
            VStack(alignment: .leading, spacing: 4) {
                Divider().overlay(tokens.line)
                Button {
                    gatheringsOpen.toggle()
                    if gatheringsOpen {
                        Task { wornTags = await model.wornRuleTags(gatherings) }
                    }
                } label: {
                    Text(tokens.chromeLabel(line + (gatheringsOpen ? " \u{25BE}" : " \u{25B8}")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(BookPanelCopy.gatheringsHelp)
                if gatheringsOpen {
                    ForEach(gatherings, id: \.id) { gathering in
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Button(gathering.name) {
                                model.open(book: gathering, at: postID)
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                            .help(BookPanelCopy.openGatheringHelp(gathering.name))
                            Spacer(minLength: 4)
                            // §20: a gathering holds no membership — its
                            // honest door is the tag the note wears.
                            ForEach(wornTags[gathering.id] ?? [], id: \.id) { tag in
                                Button(RemoveFromBookCopy.removeTagRowWord(path: tag.path)) {
                                    Task {
                                        await model.removeTag(tag, from: gathering)
                                        wornTags = await model.wornRuleTags(
                                            membership.gatherings(for: postID))
                                    }
                                }
                                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                                .help(RemoveFromBookCopy.removeTagHelp(gathering: gathering.name))
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - The panel's drop site (its private token only)

private struct PanelDropSite: ViewModifier {
    let lineID: String
    @Binding var target: String?
    let tokens: VoiceTokens
    let onDrop: @MainActor (BookPanelDrag) -> Void

    func body(content: Content) -> some View {
        content
            .dropDestination(for: BookPanelDragToken.self) { items, _ in
                guard let drag = items.first?.drag else { return false }
                onDrop(drag)
                return true
            } isTargeted: { targeted in
                if targeted {
                    target = lineID
                } else if target == lineID {
                    target = nil
                }
            }
            // The insertion hairline: a dropped row lands right above this one.
            .overlay(alignment: .top) {
                if target == lineID {
                    Rectangle().fill(tokens.ring).frame(height: 2)
                }
            }
    }
}

private extension View {
    func panelDropSite(
        _ lineID: String, target: Binding<String?>, tokens: VoiceTokens,
        onDrop: @escaping @MainActor (BookPanelDrag) -> Void
    ) -> some View {
        modifier(PanelDropSite(lineID: lineID, target: target, tokens: tokens, onDrop: onDrop))
    }
}
