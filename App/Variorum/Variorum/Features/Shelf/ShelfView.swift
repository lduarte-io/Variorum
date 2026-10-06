//
//  ShelfView.swift
//  Variorum
//
//  Phase 13, B2 — THE SHELF (home); REBUILT at 13i-d U1 as **THE BOOKCASE**
//  (the sitting record §7, §19–§24; mockup v5 — the SHAPE and idiom, the
//  app's own tokens/spacing/type/corners, never the mockup's rounded edges,
//  §22's caution).
//
//  Top to bottom, ONE line between the masthead and the books (§23):
//  · the masthead — "Bookcase", Today's Entry · + New Book (the old counts
//    line is gone: the № census holds every number now);
//  · THE STRIP (`BookcaseStrip`) — All · the shelves · ⋯ · + shelf, then the
//    utility run № · order ▾ · details;
//  · the № panel when she opened it — right-aligned under the №, and since
//    17y (r) an OVERLAY dropdown floating over the board (never in flow);
//  · the books: a solo'd shelf's rows, or ALL — UNSHELVED at the top under
//    its own collapsible header (§24's overrule), then every shelf in strip
//    order under the Library's gray section labels, collapsible;
//  · the quick-entry box (R3), and at the window's foot the ⌘K hint bar,
//    whose trailing end is now the board's QUIET RECEIPT home (18i) — the
//    old report overlay drew ON TOP of the hint (KnownIssues rows 103 and
//    108, closed by the rebuild).
//  Voiced through the token layer — no literal colors here.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

struct ShelfView: View {
    /// The REGISTRY capabilities this view's book menu renders (P-1's walk).
    /// The menu's other items (Rename…, Manage Notes…, Length & Extent…)
    /// are the shelf's own book-management vocabulary and were never
    /// registry acts. 13i-b U3 adds the rule editor's door (gatherings AND
    /// books) and the two strengthening doors (gatherings). 13i-c U3 adds
    /// the six STATE doors (Finish/Reopen joined the registry with them —
    /// the settings sheet renders them too) and the Trash door, drawn from
    /// the declaration it now shares with the rule editor's gathering gate.
    /// 13i-d U1 adds the Bookcase's three book doors: Move to Shelf ▸ and
    /// my order's Send to Top / Send to Bottom (§20, §24).
    static let contextMenuCapabilities: [CapabilityID] = [
        .toggleStar, .editRule, .bindIntoBook, .makeBookFromGathering,
    ] + BookStateDoorSet.all + [.deleteBook]
        // 13i-c U4: Duplicate Book… (§6 — shallow or with copies; an owned
        // book with copies only).
        + [.duplicateBook]
        + [.moveBookToShelf, .sendBookToTop, .sendBookToBottom]
        // 13i-d U3 — the Collecting pane's second road (the sitting record
        // §4): the book row reaches its settings sheet.
        + [.openBookSettings]
        // 13i-d U5b — Move to Wing ▸ (R-13id-6 item 9): books AND gatherings.
        + [.moveBookToWing]
        // 13i-e U2 — Archive beside Delete (R-13ie-1…4; `BookArchiveDoorSet`
        // — the daily Journal renders Archive and never Delete). Unarchive is
        // not this menu's: an archived book is never on the Bookcase.
        + [.archiveBook]

    let session: AppSession
    let model: ShelfViewModel
    let readings: ReadingsViewModel
    /// Cross-feature routing lives in composition: open a book, a post.
    let onOpen: (SidebarSelection) -> Void
    /// The dated home's door (R38: the journal lives on the shelf).
    let onTodaysEntry: () -> Void
    /// 13f batch 6 (W4): the star door on the BOOK rows — her ruling's
    /// "notes or books", so the board renders the same act the note-row
    /// family does, from the same declaration.
    var starDoor: StarDoor? = nil
    /// 13i-d U5 — the WING switcher's brain (`Core/Views/WingsModel`, owned by
    /// the composition root and handed in). nil in harness mounts: the
    /// masthead then reads "Bookcase" alone, exactly as before.
    var wings: WingsModel? = nil

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    @State private var createPresented = false
    @State private var nameField = ""
    @State private var renameTarget: Reading?
    @State private var manageTarget: Reading?
    /// 13i-b U3: the rule editor — the sheet's item IS its model, so the
    /// draft can never be rebuilt under her by a shelf re-render.
    @State private var ruleEditor: RuleEditorModel?
    @State private var extentTarget: Reading?
    /// 13i-b U3: the BIND door's sheet item — and it carries its count
    /// (F-U2-3: the old door kept the count in a separate `@State` that the
    /// sheet's closure read from a stale snapshot, promising "0 notes").
    @State private var bindOffer: BindOffer?
    /// 13i-c U3: the SPAWN door's sheet — its item carries the gathering,
    /// the name and the outflow PREFILL.
    @State private var spawnOffer: SpawnOffer?
    /// 13i-c U3 (R-13ic-4): the MINT sheet — a gathering is made WITH its
    /// rule. The sheet's item is the mint-mode editor (it carries the name).
    @State private var mintEditor: RuleEditorModel?
    /// 13i-c U4: Duplicate Book…'s prompt — its item is the book it is FOR.
    @State private var duplicateOffer: DuplicateBookOffer?
    /// 13i-d U3 — the BOOK SETTINGS sheet, opened from the row (§4). Its item
    /// arrives LOADED (`BookSettingsTarget.load`); the sheet's Edit… hands
    /// the rule editor back here and opens it once the sheet is gone (W-1).
    @State private var settingsTarget: BookSettingsTarget?
    @State private var pendingRuleEditor: RuleEditorModel?
    // 13i-d U1 — the shelf doors' prompts (the strip asks; this view owns
    // the presentation, the `BookStateDoors` shape).
    @State private var newShelfPresented = false
    @State private var shelfNameField = ""
    @State private var renameShelfTarget: Shelf?
    @State private var glyphTarget: Shelf?
    @State private var deleteShelfTarget: Shelf?
    /// 13i-d U5b — the book move's confirm (its item IS the act's preview).
    @State private var bookMoveAsk: WingsModel.BookMoveAsk?
    /// The book row a dragged BOOK hovers over in "my order" (the insertion
    /// hairline), and the section header a book hovers over (re-shelve).
    @State private var rowDropTarget: String?
    @State private var headerDropTarget: String?
    /// Batch 9 (R102): the list region hugs its content, so the
    /// quick-entry bar rides RIGHT BELOW the rows — the round-2 mockup's
    /// geometry at every window size. On a board taller than the window the
    /// region fills the window and the bar stays pinned above the fold,
    /// exactly as R3 ruled.
    @State private var listContentHeight: CGFloat = 0
    #if DEBUG
    /// 17y B2 (F-B2-5): the board's own name in `BookcaseRowOracle` (the C4
    /// rule — its rows' records live exactly as long as this board).
    @State private var oracleOwner = UUID()
    #endif

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var shelfMenuActions: ShelfMenuActions {
        ShelfMenuActions(
            rename: { shelf in
                shelfNameField = shelf.name
                renameShelfTarget = shelf
            },
            setGlyph: { glyphTarget = $0 },
            delete: { deleteShelfTarget = $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            BookcaseStrip(
                model: model, tokens: tokens, menuActions: shelfMenuActions,
                onNewShelf: {
                    shelfNameField = ""
                    newShelfPresented = true
                })
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    BookcaseRowOracle.recordFrame(BookcaseRowOracle.stripKey, $0, owner: oracleOwner)
                }
                #endif
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    boardContent
                }
                .padding(.horizontal, 28)
                // A solo'd shelf draws no header, so its first row gets a
                // little air under the strip (All's headers carry their own).
                .padding(.top, model.effectiveScope == .all ? 0 : 6)
                .padding(.bottom, 10)
                .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) {
                    listContentHeight = $0
                }
            }
            .frame(maxHeight: listContentHeight > 0 ? listContentHeight : nil, alignment: .top)
            // 17y item (r) — THE № PANEL IS A TRUE DROPDOWN (her report: "it's
            // a dropdown, not a push down"). 13i-d U1 drew it IN FLOW between
            // the strip and the board, so opening it pushed every row down
            // by its height (148 pt, measured) and, in a window whose height
            // was spoken for, clipped the first row at the scroll region's top
            // edge. It now FLOATS over the board's top-right — hung from the
            // board's top edge (= the strip's bottom), right-aligned at the
            // strip's own 28-pt inset under the utility run's №, exactly where
            // it sat: zero layout push. The board draws above its later
            // siblings (`zIndex`) so a tall panel over a short board floats
            // over the entry bar too. Contents, solo acts and the remembered-
            // open state are untouched. (A first build hung it from the strip
            // with a custom bottom guide; SwiftUI ignored the guide and drew it
            // ABOVE the strip — the walk caught it, the pin now measures it.)
            .overlay(alignment: .topTrailing) {
                if model.censusOpen {
                    BookcaseCensusPanel(model: model, tokens: tokens)
                        #if DEBUG
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                            BookcaseRowOracle.recordFrame(
                                BookcaseRowOracle.censusPanelKey, $0, owner: oracleOwner)
                        }
                        #endif
                        .padding(.trailing, 28)
                }
            }
            .zIndex(1)
            entryBar
            // Batch 14: the ⌘k advice bar rides the WINDOW BOTTOM (her
            // ask); the entry box stays high with the list.
            Spacer(minLength: 0)
            hintBar
        }
        .background(tokens.surface)
        .task { await model.start() }
        .task { await model.refreshAggregates() }
        #if DEBUG
        .onAppear { BindDoorProbe.openShelfDoor = { openBindOffer($0) } }
        .onDisappear { BookcaseRowOracle.release(owner: oracleOwner) }
        #endif
        .alert("New Book", isPresented: $createPresented) {
            TextField("Name", text: $nameField)
            Button("Create Book") {
                let name = nameField
                mint { await readings.create(
                    name: name.isEmpty ? "Untitled" : name, kind: .book, shelfId: $0) }
            }
            // 13i-c U3 (R-13ic-4, F-U1-2): the mint door REQUIRES a rule, so
            // it opens the mint sheet (the rule drafted inline; Create
            // disabled until a term exists) instead of minting a rule-less
            // gathering the op refuses. 13i-d U6 (a): the gathering mint's
            // words (RuleEditorCopy.mintTitle's door).
            Button(RuleEditorCopy.mintTitle + "\u{2026}") {
                let editor = RuleEditorModel(session: session, mintingIn: model.wingID)
                editor.mintName = nameField
                // 13i-d U1: the context mint reaches the gathering mint too.
                editor.mintShelfID = model.mintShelfID
                mintEditor = editor
            }
            // §14 item 10's "starting a 'new' journal as a separate
            // notebook" — a journal-profile book (dated, one entry after
            // another; round 2's re-designation door pairs with it).
            Button("Create Journal Book") {
                let name = nameField
                mint { await readings.create(
                    name: name.isEmpty ? "Untitled Journal" : name,
                    kind: .book, profile: Queries.journalTraitProfile,
                    sortField: .entryDate, sortDir: .desc, shelfId: $0) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(model.mintShelfID.flatMap { id in model.shelves.first { $0.id == id } }
                .map { "It lands on \u{201C}\($0.name)\u{201D}, the shelf you're looking at. " } ?? "")
                + Text(BookcaseCopy.newBookMessage)
        }
        .alert(
            "Rename Book",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { reading in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task {
                    await readings.rename(reading.id, to: name)
                    if let error = readings.lastError { model.refuse(error) }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        // 13i-d U1 — the shelf prompts.
        .alert("New Shelf", isPresented: $newShelfPresented) {
            TextField("Name", text: $shelfNameField)
            Button("Make Shelf") {
                let name = shelfNameField
                Task { await model.createShelf(named: name) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("It joins the end of the strip. Drag a book onto its name to put it there.")
        }
        .alert(
            "Rename Shelf",
            isPresented: Binding(
                get: { renameShelfTarget != nil },
                set: { if !$0 { renameShelfTarget = nil } }),
            presenting: renameShelfTarget
        ) { shelf in
            TextField("Name", text: $shelfNameField)
            Button("Rename") {
                let name = shelfNameField
                Task { await model.renameShelf(shelf.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            deleteShelfTarget.map { BookcaseCopy.deleteShelfTitle($0.name) } ?? "",
            isPresented: Binding(
                get: { deleteShelfTarget != nil },
                set: { if !$0 { deleteShelfTarget = nil } }),
            presenting: deleteShelfTarget
        ) { shelf in
            Button(BookcaseCopy.deleteShelfVerb.replacingOccurrences(of: "\u{2026}", with: ""),
                   role: .destructive) {
                Task { await model.deleteShelf(shelf.id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { shelf in
            Text(BookcaseCopy.deleteShelfMessage(books: model.shelfCounts[shelf.id] ?? 0))
        }
        .sheet(item: $glyphTarget) { shelf in
            ShelfGlyphSheet(shelf: shelf) { glyph in
                Task { await model.setGlyph(shelf.id, glyph: glyph) }
            }
        }
        .sheet(item: $manageTarget) { reading in
            ManageReadingPostsSheet(session: session, model: readings, reading: reading)
        }
        // 13i-b U3 walk finding F-U3-1: the board's tags column and word
        // counts are ONE-SHOT aggregates; a saved rule changes what a
        // gathering shows, so the row refreshes when the editor closes.
        .sheet(item: $ruleEditor, onDismiss: {
            Task { await model.refreshAggregates() }
        }) { editor in
            RuleEditorSheet(model: editor)
        }
        // 13i-d U3 — the Book Settings sheet from the row (the same sheet the
        // book's gear opens). Its Edit… is handed back and opens the rule
        // editor AFTER this sheet dismisses (W-1's rule, the book view's).
        .sheet(item: $settingsTarget, onDismiss: {
            Task { await model.refreshAggregates() }
            if let next = pendingRuleEditor {
                pendingRuleEditor = nil
                ruleEditor = next
            }
        }) { target in
            BookSettingsHost(target: target) { editor in pendingRuleEditor = editor }
        }
        .sheet(item: $mintEditor, onDismiss: {
            Task { await model.refreshAggregates() }
        }) { editor in
            MintGatheringSheet(model: editor, readings: readings)
        }
        .sheet(item: $extentTarget) { reading in
            BookExtentSheet(model: model, reading: reading)
        }
        // 13i-c U4 — DUPLICATE BOOK… (§6).
        .sheet(item: $duplicateOffer, onDismiss: {
            Task { await model.refreshAggregates() }
        }) { offer in
            DuplicateBookSheet(session: session, offer: offer)
        }
        .sheet(item: $bindOffer) { offer in
            BindIntoBookSheet(offer: offer) { ownedNotes in
                Task { await model.bind(offer.reading.id, ownedNotes: ownedNotes) }
            }
        }
        // 13i-c U3: the STATE doors' confirms — the one presentation road the
        // settings sheet shares.
        .bookStateConfirms(model.stateDoors)
        // 13i-d U5b — the book move's counting confirm (R-13id-6).
        .wingBookMoveConfirm($bookMoveAsk, wings: wings) {
            Task { await model.refreshAggregates() }
        }
        // 13i-c U4 (§4 row 17): the row drop's ownership choice.
        .membershipChoices(model.membershipDoors) { _ in
            Task { await model.refreshAggregates() }
        }
        // 13i-c U3 — THE SPAWN SHEET.
        .sheet(item: $spawnOffer) { offer in
            SpawnBookSheet(offer: offer) { name, outflow in
                Task { await model.spawnBook(from: offer.source.id, named: name, outflow: outflow) }
            }
        }
    }

    #if DEBUG
    private func recordRow(_ readingID: String, placing: Bool) {
        BookcaseRowOracle.record(
            readingID, .init(placing: placing, details: model.detailsShown), owner: oracleOwner)
    }
    #endif

    /// 17y B2 (b), F-B2-5 — a book row's view identity: its SECTION and the
    /// book, so a book moving between shelves becomes a new row (pinned).
    nonisolated static func rowIdentity(section: String, book: String) -> String {
        section + "\u{1F}" + book
    }

    /// A book mint from the New Book prompt — the CONTEXT MINT (§19.1/§24:
    /// a solo'd shelf receives it, All leaves it unshelved) — speaking the
    /// door's refusal on the status seam (18i) rather than an overlay.
    private func mint(_ body: @escaping (String?) async -> String?) {
        let shelfID = model.mintShelfID
        Task {
            if await body(shelfID) == nil, let error = readings.lastError {
                model.refuse(error)
            } else {
                await model.refreshAggregates()
            }
        }
    }

    // MARK: - The masthead

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.path(["Bookcase"]))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
            // 13i-d U5 — "Bookcase · Home ▾" (§21 Direction C): which
            // library she is in, and the door to the others.
            if let wings {
                WingSwitcherMenu(tokens: tokens, wings: wings)
                    .reportsPress { model.mastheadDoorOpened() }
            }
            Spacer()
            Button(tokens.chromeLabel("Today's Entry")) { onTodaysEntry() }
                .buttonStyle(.borderless)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
            Button(tokens.chromeLabel("+ New Book")) {
                nameField = ""
                createPresented = true
            }
            .buttonStyle(.borderless)
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
    }

    // MARK: - The books

    @ViewBuilder
    private var boardContent: some View {
        let sections = model.sections
        let isAll = model.effectiveScope == .all
        if model.books.isEmpty, isAll {
            Text(tokens.chromeLabel("No books yet — create one, or just start typing below."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 24)
        }
        ForEach(sections) { section in
            if isAll {
                sectionHeader(section)
            }
            if !isAll || !model.isCollapsed(section.id) {
                ForEach(section.books, id: \.reading.id) { book in
                    shelfRow(book)
                        // 17y B2 (b) — F-B2-5, a PRE-EXISTING freeze the
                        // walk exposed: a book that MOVED between sections
                        // (re-shelved by its menu or by a drop) kept a row
                        // view that never updated again until the board was
                        // rebuilt — its meta ignored "details", its grip,
                        // hairline and drop site ignored the order. The row's
                        // identity is qualified by its SECTION, so a move is
                        // a new row, never a re-parented one.
                        .id(Self.rowIdentity(section: section.id, book: book.reading.id))
                    Divider().overlay(tokens.line.opacity(0.6))
                }
                // The hint is a SOLO'd shelf's; in All an empty shelf is its
                // header alone (four hints in a row read as noise — the walk).
                // 17y (s): the starred shelf says its own one-liner — here,
                // in the solo'd board, and nowhere on the strip.
                if section.books.isEmpty, model.solo == nil, !isAll {
                    Text(tokens.chromeLabel(section.kind == .starred
                        ? BookcaseCopy.starredShelfEmpty
                        : "Nothing on this shelf yet — drag a book onto its name."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .padding(.vertical, 10)
                }
            }
        }
        if let solo = model.solo, sections.allSatisfy(\.books.isEmpty) {
            Text(tokens.chromeLabel("Nothing in view matches \u{201C}"
                + "\(solo.label(count: 0).dropFirst(2))\u{201D} — click \u{2116} to clear it."))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.vertical, 10)
        }
    }

    /// A section label in All — the Library's gray label idiom (§21),
    /// collapsible (remembered), a DROP target (a book re-shelves here), and
    /// for a shelf the same right-click the strip's name carries.
    @ViewBuilder
    private func sectionHeader(_ section: BookcaseBoard.Section) -> some View {
        let collapsed = model.isCollapsed(section.id)
        let title: String = {
            switch section.kind {
            case .unshelved: return BookcaseCopy.unshelvedName
            case .shelf(let shelf): return ShelfFace.label(shelf)
            // Never drawn (the starred shelf has no All header — it is its
            // own scope), named for exhaustiveness.
            case .starred: return BookcaseCopy.starredShelfName
            }
        }()
        let label = HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(collapsed ? "\u{25B8}" : "\u{25BE}")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            if collapsed {
                Text("\(section.books.count)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .contentShape(Rectangle())
        .onTapGesture { model.toggleCollapsed(section.id) }
        .overlay(alignment: .bottom) {
            if headerDropTarget == section.id {
                Rectangle().fill(tokens.line).frame(height: 1)
            }
        }
        .bookcaseDropSite(
            onHover: { headerDropTarget = $0 ? section.id
                : (headerDropTarget == section.id ? nil : headerDropTarget) }
        ) { payload in
            if case .book(let readingID) = payload {
                Task { await model.reshelve(readingID, to: section.shelfID) }
            }
        }
        .help(collapsed ? "Show this shelf's books" : "Fold this shelf away")
        if case .shelf(let shelf) = section.kind {
            label.contextMenu { ShelfMenu(shelf: shelf, model: model, actions: shelfMenuActions) }
        } else {
            label
        }
    }

    private func shelfRow(_ book: Queries.ShelfBook) -> some View {
        let reading = book.reading
        // 17y B2 (b): ONE value for the row drop, the grip and Send to
        // Top/Bottom (`BookcaseBoard.placesByHand`, pinned).
        let placing = model.placesByHand
        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            // 17y B2 (b) — HER DRAG-BARS ASK: in my order every row shows the
            // app's handle (⠿). It lives in a fixed GRIP COLUMN the row always
            // carries, INSIDE the row's own bounds — drawn by opacity, never
            // inserted — and the row is pulled into the board's gutter by that
            // column's width, so the name column never moves when the order
            // changes. (The first build drew it at an offset OUTSIDE the row,
            // and the walk found rows that had moved between shelves drawing
            // the wrong grip state — F-B2-5.) Drawn exactly where a drag can
            // place (P-2); the whole row, grip included, is the drag source.
            Text(BookcaseCopy.gripGlyph)
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .frame(width: BookcaseCopy.gripColumn, alignment: .leading)
                .opacity(placing ? 1 : 0)
                .help(placing ? BookcaseCopy.gripHelp : "")
                .accessibilityHidden(!placing)
            Button {
                onOpen(.reading(reading.id))
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        // 13i-d U2 ACT 0: the UNION (`ShelfBook.starred`).
                        if book.starred {
                            Text(StarCopy.glyph)
                                .font(tokens.small)
                                .foregroundStyle(tokens.star)
                        }
                        Text(tokens.chromeLabel(reading.name))
                            .font(tokens.body.weight(.semibold))
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                    }
                    .frame(minWidth: 160, alignment: .leading)
                    Text(model.tagsColumn(for: book).map { "#\($0)" }.joined(separator: " "))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    // §23: details OFF hides the row meta AND the arrivals count
                    // ("the point is that the chrome can be clean if desired") —
                    // ONE value (`BookcaseRowMeta.drawn`, pinned), 13i-d U4.
                    if let meta = BookcaseRowMeta.drawn(
                        book, detailsShown: model.detailsShown,
                        words: model.wordCounts[book.reading.id],
                        progress: model.progress(for: book),
                        gatheringCount: model.gatheringCounts[book.reading.id],
                        archived: model.archivedCounts[book.reading.id] ?? 0) {
                        metaText(meta)
                            .font(tokens.small)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                // A BOOK dropped here (the Bookcase's own token — my order only,
                // the placing mode, §24) lands right ABOVE this row. On the inner
                // content so the row's NOTE drop below keeps its own road.
                .bookcaseDropSite(
                    enabled: placing,
                    onHover: { rowDropTarget = $0 ? reading.id
                        : (rowDropTarget == reading.id ? nil : rowDropTarget) }
                ) { payload in
                    if case .book(let dragged) = payload {
                        Task { await model.dropBook(dragged, before: reading.id) }
                    }
                }
            }
            .buttonStyle(.plain)
            .overlay(alignment: .top) {
                // My order's insertion hairline: the dragged book lands HERE.
                if placing, rowDropTarget == reading.id {
                    Rectangle().fill(tokens.accent.opacity(0.6)).frame(height: 1)
                }
            }
        }
        // The grip column sits in the board's gutter (see above).
        .padding(.leading, -BookcaseCopy.gripColumn)
        .draggable(BookcaseDragToken(.book(reading.id)))
        // A NOTE (plain text — "drag posts onto a book", sitting 1) joins
        // the book: the shipped road, unchanged.
        .onDrop(of: [.plainText], isTargeted: nil) { providers in
            for provider in providers where provider.canLoadObject(ofClass: NSString.self) {
                _ = provider.loadObject(ofClass: NSString.self) { value, _ in
                    guard let postID = value as? String else { return }
                    Task { @MainActor in await model.addPost(postID, to: reading.id) }
                }
            }
            return !providers.isEmpty
        }
        .contextMenu { bookMenu(book) }
        #if DEBUG
        // F-B2-5's oracle: what this row last DREW. A row view that froze
        // (U1's shape, a book moved between sections) never re-renders, so
        // its record keeps the state it moved with — which a pin can see.
        .onAppear { recordRow(reading.id, placing: placing) }
        .onChange(of: placing) { _, now in recordRow(reading.id, placing: now) }
        .onChange(of: model.detailsShown) { _, _ in recordRow(reading.id, placing: placing) }
        // ⚠ LOAD-BEARING for `BookcaseRowFreezeTests`' red-on-old (the B2
        // ladder's MINOR-1): with this frame recorder removed, that pin goes
        // HOLLOW — green even with the section-qualified identity reverted.
        // WHY a geometry observer on the row makes the old freeze reproducible
        // in-process is NOT explained (recorded, never claimed). That pin
        // never reads the rect's VALUE (it REQUIRES a frame record for both
        // of its rows, so removing this turns it red, never hollow — do not
        // "clean it up" without replacing its red-on-old); 17y B3 (r)'s
        // `BookcaseCensusOverlayTests` does read it (the № panel moves no row).
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
            BookcaseRowOracle.recordFrame(reading.id, frame, owner: oracleOwner)
        }
        #endif
    }

    /// The row meta: the accent arrival count first (§4 — a book asking
    /// for judgment), then the quiet facts (`BookcaseRowMeta`, pinned).
    private func metaText(_ meta: BookcaseRowMeta.Drawn) -> Text {
        let rest = Text(tokens.chromeLabel(meta.facts))
            .foregroundStyle(tokens.muted)
        guard let arrivals = meta.arrivals else { return rest }
        return Text(tokens.chromeLabel(arrivals)).foregroundStyle(tokens.accent).fontWeight(.semibold)
            + Text(" \u{00B7} ").foregroundStyle(tokens.muted)
            + rest
    }

    @ViewBuilder
    private func bookMenu(_ book: Queries.ShelfBook) -> some View {
        let reading = book.reading
        // 13f batch 6 (W4): starring a BOOK — it joins the sidebar's
        // Starred list. 13i-d U2 ACT 0 (F-U1-2 (A), ruled): this is the
        // row's ONE star door — the star floats the book atop its shelf AND
        // lists it in Starred (one truth, both stores written together), so
        // "Pin to Shelf Top" RETIRES on the Mac (the phone keeps its words
        // until its catch-up and writes the same truth).
        if let starDoor {
            Button(starDoor.title(for: .reading(reading.id))) {
                starDoor.toggle(.reading(reading.id))
            }
        }
        // 13i-d U1 — MOVE TO SHELF ▸ (the menu road beside the drag — every
        // shelf of this wing, and Unshelved; the one it is on is omitted).
        // Ladder A round 1, NIT 3 (P-2): in a shelf-less wing an unshelved
        // book has nowhere to move — the submenu is not drawn
        // (`BookcaseBoard.moveToShelfCanAct`, pinned).
        let here = model.shelfKey(of: reading.id)
        if BookcaseBoard.moveToShelfCanAct(shelfCount: model.shelves.count, here: here) {
            Menu(CapabilityRegistry.capability(.moveBookToShelf).verb) {
                ForEach(model.shelves, id: \.id) { shelf in
                    if here != shelf.id {
                        Button(ShelfFace.label(shelf)) {
                            Task { await model.reshelve(reading.id, to: shelf.id) }
                        }
                    }
                }
                if here != BookcaseBoard.unshelvedKey {
                    if !model.shelves.isEmpty { Divider() }
                    Button(BookcaseCopy.unshelvedName) {
                        Task { await model.reshelve(reading.id, to: nil) }
                    }
                }
            }
        }
        // 13i-d U5b — MOVE TO WING ▸ (R-13id-6 item 9; her R-13id-4 family):
        // a book or a gathering to another library, with its notes. The other
        // wings, Home first; never on the daily Journal (item 7) and never
        // while one library stands alone (`WingBookMoveDoor.drawn` — P-2).
        if let wings {
            let others = wings.destinations(from: model.wingID)
            if WingBookMoveDoor.drawn(reading: reading, destinations: others.count) {
                Menu(CapabilityRegistry.capability(.moveBookToWing).verb) {
                    ForEach(others) { row in
                        Button(row.name) {
                            Task { bookMoveAsk = await wings.bookMoveAsk(reading: reading, to: row.id) }
                        }
                    }
                }
            }
        }
        // My order's own doors (§20, §24): rendered only in the PLACING mode
        // — under A–Z or last edited a hand position would not show (P-2).
        if model.placesByHand {
            Button(CapabilityRegistry.capability(.sendBookToTop).verb) {
                Task { await model.place(reading.id, at: .top) }
            }
            Button(CapabilityRegistry.capability(.sendBookToBottom).verb) {
                Task { await model.place(reading.id, at: .bottom) }
            }
        }
        Divider()
        Button("Rename\u{2026}") {
            nameField = reading.name
            renameTarget = reading
        }
        // 13i-d U3 — the Collecting pane's door from the Bookcase (§4).
        Button(CollectingCopy.openVerb(isBook: reading.kind == .book)) {
            openSettings(reading.id)
        }
        // 13i-c U4 — DUPLICATE (§6): books only.
        if reading.kind == .book {
            Button(DuplicateBookCopy.verb(owned: reading.owned)) {
                duplicateOffer = DuplicateBookOffer(
                    readingID: reading.id, name: reading.name, owned: reading.owned)
            }
        }
        // 13i-b U3: the RULE EDITOR's door, for gatherings AND books.
        Button(CapabilityRegistry.capability(.editRule).verb) {
            ruleEditor = RuleEditorModel(session: session, readingID: reading.id)
        }
        if reading.kind == .book {
            Button("Manage Notes\u{2026}") { manageTarget = reading }
        } else {
            // 13i-b U3 — THE TWO STRENGTHENING DOORS (the sitting record §3).
            // Bind hides on a finished gathering and both hide on a rule-less
            // one (P-2 — the op refuses; a door that can't act isn't drawn).
            let hasRule = RuleGrammar.read(reading.querySpec) != .none
            if !reading.locked, hasRule {
                Button(CapabilityRegistry.capability(.bindIntoBook).verb) {
                    openBindOffer(reading)
                }
            }
            if hasRule {
                Button(CapabilityRegistry.capability(.makeBookFromGathering).verb) {
                    Task { spawnOffer = await SpawnOffer.load(session, gathering: reading) }
                }
            }
        }
        // 13i-d U1 — KnownIssues row 107's SHELF-MENU half (P-13ic-U3-2,
        // ruled to the sitting record §3's letter: a gathering has NO word
        // target or capacity): Length & Extent… is a BOOK's door only.
        if reading.kind == .book {
            Button("Length & Extent\u{2026}") { extentTarget = reading }
        }
        // 13i-d U5 (#169(b), RULED — the daily Journal is HOME-ONLY): the
        // designation door is drawn only on a HOME book (P-2 — the op refuses
        // any other wing's, `dailyJournalIsHomeOnly`).
        if reading.kind == .book, Queries.hasJournalTrait(reading.profile),
           model.wingID.isEmpty {
            // Round 2, MAJOR 2's re-designation door.
            Button("Use as Daily Journal") {
                Task { await model.designateDailyJournal(reading.id) }
            }
        }
        Divider()
        // 13i-c U3 — THE STATE DOORS, from the one table and named by the
        // registry. 13i-d U1 (row 107's shelf half): a gathering has no
        // FINISH (§3) — the door leaves its menu; Reopen stays ONLY on a
        // gathering that is already (legacy) finished, as its way out
        // (PROVISIONAL P-13id-U1-9). 13i-d U3 (F-U1-8): that rule now lives
        // IN the table, which the settings sheet reads too.
        ForEach(BookStateDoorSet.rendered(for: BookStateFacts(reading)), id: \.self) { act in
            Button(CapabilityRegistry.capability(act).verb) {
                Task { await model.stateDoors.open(act, readingID: reading.id) }
            }
        }
        Divider()
        Button("Export Markdown\u{2026}") { ReadingExport.export(session: session, reading: reading, asPDF: false) }
        Button("Export PDF\u{2026}") { ReadingExport.export(session: session, reading: reading, asPDF: true) }
        Divider()
        // 13i-e U2 — ARCHIVE beside the ONE delete road (13i-c U3/U4: plain /
        // owned two-choice / gathering confirms), both from the archive table
        // (P-1): the daily Journal renders Archive and NO Delete (P-2 — the op
        // refuses it; "it can be archived, never deleted"). Unarchive is the
        // Archived surface's door (an archived book never reaches this menu).
        ForEach(BookArchiveDoorSet.rendered(for: BookArchiveFacts(reading))
            .filter { $0 != .unarchiveBook }, id: \.self) { act in
            if act == .deleteBook {
                Button(CapabilityRegistry.capability(.deleteBook).verb + "\u{2026}", role: .destructive) {
                    Task { await model.stateDoors.open(.deleteBook, readingID: reading.id) }
                }
            } else {
                Button(BookStateCopy.archiveDoorLabel(asks: BookStateCopy.archiveAsks(reading))) {
                    Task { await model.stateDoors.open(act, readingID: reading.id) }
                }
            }
        }
    }

    /// 13i-d U3 — the settings door's one road: load the book, then present
    /// with ONE write (a book deleted in between refuses in words).
    private func openSettings(_ readingID: String) {
        Task {
            if let target = await BookSettingsTarget.load(session: session, readingID: readingID) {
                settingsTarget = target
            } else {
                model.refuse(OpsRefusalCopy.message(for: OperationError.readingNotFound(id: readingID)))
            }
        }
    }

    /// The bind door's one road: load the offer (count included), then
    /// present it with ONE write — the sheet reads everything from its item.
    private func openBindOffer(_ reading: Reading) {
        Task { bindOffer = await BindOffer.load(session, reading: reading) }
    }

    // MARK: - Quick entry (R3 — the shared bar; Library carries it too)

    private var entryBar: some View {
        QuickEntryBar(session: session, onOpen: onOpen, autofocus: true)
    }

    /// The ⌘K hint at the window's foot — and, at its trailing end, the
    /// board's QUIET RECEIPT home (18i's one slot; rows 103/108: the old
    /// report overlay drew over these words).
    private var hintBar: some View {
        HStack(spacing: 12) {
            Text(tokens.chromeLabel("⌘K — find anything: notes, books, commands"))
                .lineLimit(1)
            Spacer(minLength: 12)
            QuietReceiptLine(status: session.status, tokens: tokens)
            Text(tokens.chromeLabel("⌘J today · ⌘N new note"))
                .lineLimit(1)
                .fixedSize()
        }
        .font(tokens.small)
        .foregroundStyle(tokens.faint)
        .padding(.horizontal, 28)
        .padding(.vertical, 6)
        .background(tokens.room)
    }
}

/// **THE ROW META's words** (13i-d U1 — mockup v5's right column): the
/// counts, the words and the STATUS words, in the ruled vocabulary (§1: a
/// gathering · living; §5: finished · sealed; §6: owned). Pure, so a pin
/// reads exactly what a row says. The ARRIVAL count is separate — it draws in
/// the accent, first (§4: "a small accent count on the Bookcase row").
nonisolated enum BookcaseRowMeta {
    /// What the row's right column DRAWS: the accent arrival count (if any)
    /// and the quiet facts — or NOTHING with details off (§23, her overrule:
    /// details off hides the meta AND the arrivals count). The ONE value the
    /// row reads (13i-d U4 — so a pin reads exactly what the row draws,
    /// "5 notes · 2 archived" included).
    struct Drawn: Equatable {
        let arrivals: String?
        let facts: String
    }

    static func drawn(
        _ book: Queries.ShelfBook, detailsShown: Bool, words: Int?,
        progress: (percent: Int, target: Int)?, gatheringCount: Int?, archived: Int = 0
    ) -> Drawn? {
        guard detailsShown else { return nil }
        return Drawn(
            arrivals: arrivals(book),
            facts: facts(
                book, words: words, progress: progress,
                gatheringCount: gatheringCount, archived: archived))
    }

    static func arrivals(_ book: Queries.ShelfBook) -> String? {
        let n = book.arrivalCount
        guard n > 0 else { return nil }
        return "\(n) \(n == 1 ? "arrival" : "arrivals")"
    }

    /// 13i-d U4 — HONEST COUNTS (her #169(a)(1), "5 notes · 2 archived"):
    /// `archived` is the book's archived-member count (the one-shot
    /// aggregate). "N notes" counts what the book SHOWS — the held member
    /// count (`postCount`, every live member row) less the archived ones,
    /// clamped — and "M archived" follows it only when M > 0 (PROVISIONAL
    /// P-13id-U4-4). The whole meta hides with details off (§23).
    static func facts(
        _ book: Queries.ShelfBook, words: Int?, progress: (percent: Int, target: Int)?,
        gatheringCount: Int?, archived: Int = 0
    ) -> String {
        let reading = book.reading
        var parts: [String] = []
        if reading.kind == .gathering {
            if let gatheringCount {
                parts.append("\(gatheringCount) \(gatheringCount == 1 ? "note" : "notes")")
            }
        } else {
            let shown = max(0, book.postCount - max(0, archived))
            parts.append("\(shown) \(shown == 1 ? "note" : "notes")")
            if archived > 0 { parts.append("\(archived) archived") }
            if book.sectionCount > 0 { parts.append("\(book.sectionCount) ch") }
        }
        if let progress {
            parts.append("\(progress.percent)% of \(progress.target.formatted())w")
        } else if let words, words > 0 {
            parts.append("\(words.formatted())w")
        }
        if let cap = reading.maxPosts, reading.kind == .book { parts.append("cap \(cap)") }
        if reading.kind == .gathering {
            parts.append("gathering")
        } else if BookcaseBoard.isLiving(reading) {
            parts.append("living")
        }
        if reading.sealedAt != nil {
            parts.append("sealed")
        } else if reading.locked {
            parts.append("finished")
        }
        if reading.owned { parts.append("owned") }
        return parts.joined(separator: " \u{00B7} ")
    }
}

/// Extent-field parsing, ONE implementation for every extent door (round
/// 2, MINOR): empty = CLEAR, positive digits = a value, anything else =
/// INVALID — refuse and KEEP; a typo while editing must never silently
/// delete a stored extent (`Int("10k")` was nil, and nil meant clear).
/// 13b Stage 4 ladder round 1, MINOR-2 (the invalidExtent class sweep):
/// NON-POSITIVE input is INVALID here too — every consumer feeds an
/// extent setter and all three ops refuse `<= 0` (`invalidExtent`), so
/// the one parse rule refuses it AT the field, refuse-and-keep, and no
/// door can reach the op's raw refusal; the op stays the belt.
enum ExtentInput: Equatable {
    case clear
    case value(Int)

    static func parse(_ field: String) -> ExtentInput? {
        let trimmed = field.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return .clear }
        guard let value = Int(trimmed), value > 0 else { return nil }
        return .value(value)
    }

    var intValue: Int? {
        if case .value(let value) = self { return value }
        return nil
    }
}

/// The extent faces (word target / post cap — the machinery that existed
/// since v1 with "no UI face at all", plus v1_11's words unit).
struct BookExtentSheet: View {
    let model: ShelfViewModel
    let reading: Reading
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Length & Extent — “\(reading.name)”").font(.headline)
            Text("A word target shows progress on the Bookcase; at its end, extend it or start a new book. The note cap refuses further adds when full. Blank clears.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Form {
                TextField("Word target (e.g. 10000)", text: $wordTargetField)
                TextField("Note cap (max notes)", text: $maxPostsField)
            }
            if let parseError {
                Text(parseError).font(.caption).alarmVoice()
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    guard let target = ExtentInput.parse(wordTargetField),
                          let cap = ExtentInput.parse(maxPostsField)
                    else {
                        parseError = "Extents are plain positive numbers (e.g. 10000) — nothing was changed."
                        return
                    }
                    Task {
                        await model.setWordTarget(reading.id, target: target.intValue)
                        await model.setMaxPosts(reading.id, maxPosts: cap.intValue)
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
        .onAppear {
            wordTargetField = reading.wordTarget.map(String.init) ?? ""
            maxPostsField = reading.maxPosts.map(String.init) ?? ""
        }
    }
}

/// The shared reading-export door (moved out of the retired sidebar
/// section so the shelf and the book view share one shape).
enum ReadingExport {
    @MainActor
    static func export(session: AppSession, reading: Reading, asPDF: Bool) {
        let name = Queries.sanitizedFilename(reading.name)
        let base = name.isEmpty ? "Untitled" : name
        guard let url = ExportPanels.saveFile(
            defaultName: "\(base).\(asPDF ? "pdf" : "md")",
            type: asPDF ? .pdf : .markdownFile) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if asPDF {
                if let data = await exporter.pdfData(forReading: reading.id) {
                    exporter.writePDF(data, to: url)
                }
            } else if let markdown = await exporter.markdown(forReading: reading.id) {
                exporter.writeMarkdown(markdown, to: url)
            }
        }
    }
}

#if DEBUG
/// **17y B2 (F-B2-5) — what each Bookcase ROW last drew**: its `placing`
/// (the grip, the hairline, the row drop) and whether its meta showed. Keyed
/// by the book, owned by the board that drew it (`OwnedRegistrations` — the
/// 18k C4 rule). A row view that FROZE keeps the record it moved with.
@MainActor
enum BookcaseRowOracle {
    struct Drawn: Equatable {
        var placing: Bool
        var details: Bool
    }

    private static var store = OwnedRegistrations<String, Drawn>()

    static func drawn(_ readingID: String) -> Drawn? { store.current[readingID] }

    static func record(_ readingID: String, _ drawn: Drawn, owner: UUID) {
        store.publish(drawn, for: readingID, owner: owner)
    }

    private static var frames = OwnedRegistrations<String, CGRect>()

    /// Where the row sits, in its window (`.global`). `BookcaseRowFreezeTests`
    /// requires only that each of its rows HAS one, because the recorder
    /// writing it is load-bearing for that pin's red-on-old for a reason not
    /// understood (the B2 ladder's MINOR-1 — see the recorder at the row).
    /// 17y B3 (r): `BookcaseCensusOverlayTests` DOES read the value — the
    /// open № panel must not move a row.
    static func frame(_ readingID: String) -> CGRect? { frames.current[readingID] }

    static func recordFrame(_ readingID: String, _ frame: CGRect, owner: UUID) {
        frames.publish(frame, for: readingID, owner: owner)
    }

    static func release(owner: UUID) {
        store.release(owner: owner)
        frames.release(owner: owner)
    }

    /// 17y B3 (r): the reserved keys the strip and the № panel record their
    /// frames under (never a reading id — those are UUIDs).
    static let stripKey = "\u{2116}strip"
    static let censusPanelKey = "\u{2116}panel"

    /// A pin's door: start from empty.
    static func forgetAll() {
        store.forgetAll()
        frames.forgetAll()
    }
}
#endif
