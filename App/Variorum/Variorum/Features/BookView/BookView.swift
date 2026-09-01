//
//  BookView.swift
//  Variorum
//
//  The continuous book view (Phase 10 Step 4; reworked Phase 13 B3): the
//  reading's posts in ONE continuous scroll with REAL CHAPTERS (R28/R50 —
//  reading_section rows, movable, superseding tag-path headers for curated
//  books), the terminal BOOK NAVIGATOR (R43: chapters · outline · settings;
//  clicking a post opens it IN the current editor — the inline focus, no
//  context jump; NO separate chapter view), and the READING FLOW mode
//  (R2 — direction C; a finished book opens into it). Unfocused posts
//  render read-cheap; exactly one upgrades to the live inline editor (P3).
//

import SwiftUI
import VariorumCore

struct BookView: View {
    let session: AppSession
    let readingID: String
    var readingName: String?
    /// 13f batch 4 (the MOUNT rule): whether this book's PANE is focused.
    /// Defaults true, so every pre-split call site reads unchanged.
    var paneFocused: Bool = true
    /// Focusing a post inside an UNFOCUSED pane claims the pane first, so
    /// one click both takes the pane and opens the post.
    var onPaneFocusRequest: (() -> Void)?
    /// 13f W20(a) — THE ASCENT: the shell asks this book to open AT a post
    /// (the membership chip's link, wired at last). One-shot; the landing
    /// itself is W21's brain, so the ascent lands in whatever mode the book
    /// opens in, revealed.
    var revealPostID: String?
    var onRevealConsumed: (() -> Void)?
    @State private var model: BookViewModel
    @State private var structure: BookStructureModel

    /// `model` is injectable for tests (hosted `.task` appearance callbacks
    /// don't fire under the test host — tests drive `adopt` by hand).
    /// `initiallyExpanded`: an explicit expand seed. Load-bearing again
    /// since her #43(a) ruling (13d batch 1) — Outline opens COLLAPSED, so
    /// a caller (or a pin) that needs prose on screen must expand what it
    /// means to read, exactly as she does.
    init(
        session: AppSession, readingID: String, readingName: String? = nil,
        model: BookViewModel? = nil,
        structure: BookStructureModel? = nil,
        initiallyExpanded: Set<String> = [],
        paneFocused: Bool = true,
        onPaneFocusRequest: (() -> Void)? = nil,
        revealPostID: String? = nil,
        onRevealConsumed: (() -> Void)? = nil
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        self.paneFocused = paneFocused
        self.onPaneFocusRequest = onPaneFocusRequest
        self.revealPostID = revealPostID
        self.onRevealConsumed = onRevealConsumed
        let resolved = model ?? BookViewModel(session: session, readingID: readingID)
        for postID in initiallyExpanded { resolved.expand(postID) }
        _model = State(initialValue: resolved)
        // `structure` is injectable for the same reason `model` is (13c 2C):
        // a hosted test drives the view MODE from outside, and hosted
        // `.task` appearance callbacks don't fire under the test host.
        _structure = State(
            initialValue: structure
                ?? BookStructureModel(session: session, readingID: readingID))
    }

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var newChapterPresented = false
    @State private var chapterNameField = ""
    @State private var renameChapterTarget: ReadingSection?
    @State private var settingsShown = false
    /// 13c 2D: the smart→curated offer, what it finishes afterwards, and the
    /// derived count it promises will stay.
    @State private var conversionOffer = false
    @State private var conversionFollowUp: SmartConversionFollowUp = .none
    @State private var conversionCount = 0

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Outline's prose column (13c 2A): Write's own measure. The contained
    /// text surfaces carry `inlineSurfaceInset` on each side, so the text
    /// itself lands on exactly `EditorTypography.maxColumnWidth`.
    static let proseColumn =
        EditorTypography.maxColumnWidth + 2 * EditorTypography.inlineSurfaceInset

    /// Wave 2c (item 18, W8-5 — "it's so bizarrely open on the right and
    /// it's ugly how the note details render below the note's opening
    /// paragraphs - if anything, those should render to the side"): the
    /// DETAILS GUTTER. A fixed rail to the prose column's right that
    /// carries each note's details — the card's meta, the expanded note's
    /// facts, and (through `EditorView`'s `.side` bar placement) the
    /// focused note's whole editor bar. The open right earns its keep.
    static let outlineGutterWidth: CGFloat = 190
    static let outlineGutterSpacing: CGFloat = 24
    /// The FOCUSED note's row: the prose measure + the editor's side bar
    /// (`EditorView(barPlacement: .side)` splits this into the surface and
    /// a 190 pt rail). Only the focused row is capped — the correction
    /// round (row 13) let the other rows span the pane with a flexible
    /// gutter, but a live editor spanning the pane would put the prose
    /// past Write's measure (R9 — margins are sacred).
    static let outlineFocusedRowWidth =
        proseColumn + outlineGutterSpacing + outlineGutterWidth

    var body: some View {
        HStack(spacing: 0) {
            // Wave 2c (item 18, W8-5): in INDEX the minimal navigator steps
            // aside — the index column IS the outline pane grown up, and it
            // carries the same masthead so no chrome is lost. The minimal
            // pane stays beside every other mode (her sharpening: "i do
            // like the more minimal outline to go along with the current
            // modes").
            if structure.mode != .index {
                navigator
                Divider().overlay(tokens.line)
            }
            switch structure.mode {
            case .index:
                BookIndexView(
                    session: session, model: model, structure: structure,
                    masthead: { bookMasthead },
                    onEditInOutline: { postID in
                        // Editing lives where editing lives: land the note
                        // focused in Outline through the ascent's own door
                        // (the reveal is consumed by Outline's landing).
                        model.focus(postID)
                        model.requestReveal(postID)
                        structure.mode = .outline
                    })
            case .outline:
                outlineBody
            case .spread:
                // The picker's "Book" (13c 2A's rename, 2B's build): the
                // TWO-UP spread — each page a whole scrollable post, the
                // active one editable in Write or the takes stack (A43/A44).
                SpreadBookView(session: session, model: model, structure: structure)
            case .read:
                // READ is a PAIR (13c 2C, her direction): the vertical
                // infinite scroll, and true book pagination. Neither is
                // editable — her A43 ruling, which is what keeps Read a
                // place to read rather than a third editor.
                switch structure.readForm {
                case .flow:
                    ReadingFlowView(
                        session: session,
                        readingName: readingName ?? model.readingName,
                        grouped: structure.chaptersActive
                            ? structure.grouped(entries: model.entries)
                            : [(nil, model.entries)],
                        onWake: { postID, blockID in
                            // The scrolled-open door (row 38, R-cor-7): a
                            // click on a sentence in Read lands in the
                            // EDITABLE index at THAT block — the one
                            // `LandingTarget`, consumed by the index.
                            model.requestLanding(LandingTarget(postID: postID, blockID: blockID))
                            structure.mode = .index
                        },
                        reveal: model.pendingReveal,
                        onRevealLanded: { model.consumeReveal() })
                case .pages:
                    PagedReadView(session: session, model: model, structure: structure)
                }
            }
        }
        .background(tokens.surface)
        // 13c 2D (A31): the assembly's ORDER is a task input, so changing
        // the way she is looking restarts the observation rather than
        // re-sorting delivered rows (the window is applied by the query —
        // a post-fetch sort would sort the first N of the OLD order).
        .task(id: model.viewOrder) { await model.start() }
        .task { await structure.start() }
        // 13f batch 4: the pane's focus reaches the book's own focus
        // authority. `onChange` alone would miss the initial value, and a
        // book that mounts into an unfocused pane must not bring a live
        // editor with it.
        .onAppear {
            model.paneFocused = paneFocused
            model.onPaneFocusRequest = onPaneFocusRequest
            takeAscentRequest()
        }
        .onChange(of: paneFocused) { _, focused in model.paneFocused = focused }
        // 13f W20(a): the ascent's request, taken once — whether this book
        // was already open (onChange) or opened by the ascent (onAppear).
        .onChange(of: revealPostID) { _, _ in takeAscentRequest() }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? structure.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .alert("New Chapter", isPresented: $newChapterPresented) {
            TextField("Name", text: $chapterNameField)
            Button("Create") {
                let name = chapterNameField
                Task { await structure.createChapter(named: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Rename Chapter",
            isPresented: Binding(
                get: { renameChapterTarget != nil },
                set: { if !$0 { renameChapterTarget = nil } }),
            presenting: renameChapterTarget
        ) { section in
            TextField("Name", text: $chapterNameField)
            Button("Rename") {
                let name = chapterNameField
                Task { await structure.renameChapter(section.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $settingsShown) {
            BookSettingsSheet(structure: structure)
        }
        // 13c 2D (C2/N38): the conversion offer — the memo's §3 "the
        // refusal becomes an offer". One sheet, whichever door opened it.
        .sheet(isPresented: $conversionOffer) {
            if let reading = structure.reading {
                SmartConversionOfferSheet(
                    reading: reading,
                    // The DERIVED count, not `entries.count` — the book
                    // view's assembly is windowed (entryWindow), so a book
                    // collecting more than the window would have promised
                    // fewer posts than the conversion actually keeps.
                    memberCount: conversionCount,
                    followUp: conversionFollowUp
                ) { keepCollecting, collectingName in
                    let followUp = conversionFollowUp
                    Task {
                        // K2 (13c K6 review): the sheet promises "the order
                        // you're looking at them" — with an A31 override on,
                        // that is the override, so it rides the conversion.
                        let converted = await structure.convertToCurated(
                            keepCollecting: keepCollecting,
                            collectingName: collectingName,
                            order: model.viewOrder)
                        // FROZEN is the book's order now — drop the override
                        // so the menu stops claiming a separate way of
                        // looking (the "Save as This Book's Order" door's own
                        // rule; the content is identical at this instant, so
                        // nothing on screen moves).
                        if converted { model.viewOrder = nil }
                        // P-2: the door performs the act she asked for —
                        // conversion was the step on the way, not the point.
                        if converted, followUp == .createChapter {
                            chapterNameField = ""
                            newChapterPresented = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - The navigator (R43: chapters · outline · settings)

    /// The book's masthead chrome — title, the mode tabs, settings, the
    /// order control, the finished chip. ONE definition for the navigator
    /// AND the index column's header (wave 2c), so the two can never
    /// disagree about what the book's header says.
    ///
    /// The mode control is quiet voiced WORD-TABS now, not the segmented
    /// picker (wave 2c, the W8-2 restyle mandate — the segmented control is
    /// exactly the dated chrome grammar the mockups retire, and its ideal
    /// width already forced `.controlSize(.small)` at three labels; a
    /// fourth would have re-run the b6dae25 overflow the old comment here
    /// documented). The tabs own their line WHOLE (gear on the title line,
    /// labels lineLimit(1) + fixedSize): the first claim that "four labels
    /// + the gear measure under 190 pt" was falsified by the walk — the
    /// compressed row wrapped the words mid-letter.
    @ViewBuilder private var bookMasthead: some View {
        // The gear rides the TITLE line (which truncates and so always
        // yields), leaving the tab row the column's whole width — in the
        // 190 pt navigator, tabs + gear on one line compressed the labels
        // into mid-word wraps ("outl/ine"), the b6dae25 class this walk
        // caught live (2026-08-31).
        HStack(spacing: 4) {
            Text(tokens.path([readingName ?? model.readingName ?? "book"]))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
            Spacer(minLength: 2)
            Button {
                settingsShown = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help("Book settings — finish, length, rename")
        }
        HStack(spacing: 8) {
            // Outline · Index · Book · Read — Index sits beside the
            // writing surface, mirroring the note row's Write · Takes ·
            // Index · Read shape (her cohesion mandate, W8-2).
            modeTab("Outline", .outline)
            modeTab("Index", .index)
            modeTab("Book", .spread)
            modeTab("Read", .read)
        }
        // 13c 2C: READ's pair of faces (her direction — "the
        // Apple-Books/Kindle PAIR of modes"). It sits UNDER the mode
        // tabs rather than in a bottom bar, because one of the two
        // faces (the flow) is a vertical scroll and carries no bottom
        // chrome at all — the A6 argument. Surface-local, so
        // recorded rather than declared (Stage 4 lesson 10).
        if structure.mode == .read {
            Picker("", selection: Binding(
                get: { structure.readForm },
                set: { switchReadForm(to: $0) })) {
                Text(tokens.chromeLabel("Scroll")).tag(BookStructureModel.ReadForm.flow)
                Text(tokens.chromeLabel("Pages")).tag(BookStructureModel.ReadForm.pages)
            }
            .pickerStyle(.segmented)
            .controlSize(.small)
            .help("Read the book as one continuous scroll, or as real pages "
                + "with the text flowing across them")
        }
        orderControl
        if let reading = structure.reading, reading.locked {
            Text(tokens.chromeLabel("✓ finished"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        }
    }

    /// One quiet word-tab (the note masthead's grammar): the active mode
    /// wears ink weight + the accent; every other is a muted word.
    private func modeTab(_ label: String, _ mode: BookStructureModel.ViewMode) -> some View {
        Button {
            switchMode(to: mode)
        } label: {
            Text(tokens.chromeLabel(label))
                .font(structure.mode == mode
                    ? tokens.small.weight(.semibold) : tokens.small)
                .foregroundStyle(structure.mode == mode ? tokens.accent : tokens.muted)
                // P-8: a chrome label never wraps — a compressed row
                // must yield elsewhere, not split a word.
                .lineLimit(1)
                .fixedSize()
        }
        .buttonStyle(.plain)
        .help(modeHelp(mode))
    }

    private func modeHelp(_ mode: BookStructureModel.ViewMode) -> String {
        switch mode {
        case .outline: "The book's writing surface — every note in one column"
        case .index: "The book's index — chapters and notes beside the whole text"
        case .spread: "The two-up spread — each page a whole note"
        case .read: "Read the book as pure text"
        }
    }

    private var navigator: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 6) {
                bookMasthead
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                            if let section = group.section {
                                // R19's insertion bar: the drop target
                                // shows exactly where the chapter lands.
                                if chapterDropTarget == section.id {
                                    Rectangle()
                                        .fill(tokens.ring)
                                        .frame(height: 2)
                                }
                                // Row 8 (her "the chapters + the blocks named
                                // the same" — the Sherlock book): a chapter
                                // whose ONE note says its name shows ONE row,
                                // and that row OPENS the note.
                                let collapsedNote = BookOutlineRows.noteLineCollapsesIntoChapter(
                                    section: section, entries: group.entries)
                                    ? group.entries.first : nil
                                Button {
                                    if let collapsedNote {
                                        openFromNavigator(collapsedNote)
                                    } else {
                                        navigateToChapter(section)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("⠿")
                                            .font(tokens.small)
                                            .foregroundStyle(tokens.faint)
                                        if let collapsedNote, navigatorMarks(collapsedNote),
                                           !tokens.selectionMarker.isEmpty {
                                            Text(tokens.selectionMarker
                                                .trimmingCharacters(in: .whitespaces))
                                                .font(tokens.small.weight(.bold))
                                                .foregroundStyle(tokens.accent)
                                        }
                                        Text(tokens.chromeLabel(section.name))
                                            .font(tokens.small.weight(.semibold))
                                            .foregroundStyle(tokens.accent)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                                // 13f W11a: the whole ROW is the target, not
                                // the glyphs (the batch-1 reach trace).
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    chapterMenu(section)
                                    if let collapsedNote {
                                        Divider()
                                        outlineChapterMenu(
                                            structure: structure, postID: collapsedNote.postID)
                                    }
                                }
                                .draggable(BookStructureModel.BookDrag.chapter(section.id).payload)
                                .dropDestination(for: String.self) { items, _ in
                                    acceptDrop(
                                        items, chapter: .chapter(section.id),
                                        post: .chapter(section.id))
                                } isTargeted: { targeted in
                                    if targeted {
                                        chapterDropTarget = section.id
                                    } else if chapterDropTarget == section.id {
                                        chapterDropTarget = nil
                                    }
                                }
                            } else if structure.chaptersActive {
                                Text(tokens.chromeLabel("unfiled"))
                                    .font(tokens.small.weight(.semibold))
                                    .foregroundStyle(tokens.muted)
                            }
                            // The top-level outline: posts; clicking one
                            // opens it in the CURRENT editor (R43 — no
                            // context jump). A note line that collapsed into
                            // its chapter row (row 8) is not drawn twice.
                            let noteLines = group.section.map { section in
                                BookOutlineRows.noteLineCollapsesIntoChapter(
                                    section: section, entries: group.entries)
                                    ? [] : group.entries
                            } ?? group.entries
                            ForEach(noteLines, id: \.postID) { entry in
                                Button {
                                    // In the SPREAD the navigator is a
                                    // page-jump: show the post, read-cheap
                                    // (13b 4F — the calm default; a click in
                                    // the page upgrades it to the live
                                    // editor). A post already on the spread
                                    // stays where it is (13c 2B).
                                    if structure.mode == .spread {
                                        model.showPost(entry.postID)
                                    } else if structure.mode == .read,
                                              structure.readForm == .pages {
                                        // 13c 2C: in paginated Read the
                                        // navigator is a PAGE jump — it must
                                        // not throw her out of the reading
                                        // surface into the editor (the 4F
                                        // no-context-jump rule, R43).
                                        model.focus(entry.postID)
                                    } else {
                                        openFromNavigator(entry)
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        // Batch 9 (R100's continuation): the
                                        // focused post wears the color › in
                                        // the navigator too — and while
                                        // PAGING, the current page does
                                        // (13b 4F).
                                        if navigatorMarks(entry),
                                           !tokens.selectionMarker.isEmpty {
                                            Text(tokens.selectionMarker
                                                .trimmingCharacters(in: .whitespaces))
                                                .font(tokens.small.weight(.bold))
                                                .foregroundStyle(tokens.accent)
                                        }
                                        Text(outlineEntryTitle(entry))
                                            .font(tokens.small)
                                            .foregroundStyle(
                                                navigatorMarks(entry)
                                                    ? tokens.ink : tokens.muted)
                                            .lineLimit(1)
                                    }
                                    .padding(.leading, group.section != nil ? 10 : 0)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    outlineChapterMenu(
                                        structure: structure, postID: entry.postID)
                                }
                                // 13f W11: a post row DRAGS (her ruling —
                                // "pick up a post and move it to another
                                // chapter") and RECEIVES (a chapter dropped
                                // between posts snaps to the nearest chapter
                                // boundary — W11a's reach half).
                                .draggable(
                                    BookStructureModel.BookDrag.post(entry.postID).payload)
                                .dropDestination(for: String.self) { items, _ in
                                    acceptDrop(
                                        items, chapter: .post(entry.postID),
                                        post: .post(entry.postID))
                                } isTargeted: { targeted in
                                    if targeted {
                                        postDropTarget = entry.postID
                                    } else if postDropTarget == entry.postID {
                                        postDropTarget = nil
                                    }
                                }
                                .overlay(alignment: .top) {
                                    if postDropTarget == entry.postID {
                                        Rectangle().fill(tokens.ring).frame(height: 2)
                                    }
                                }
                            }
                        }
                        // The end drop zone: drag a chapter past the last
                        // one to land it at the end (R19). 13f W11a: taller,
                        // because with TWO chapters this strip was the ONLY
                        // way to move one down and it was 14 pt of nothing.
                        if structure.chaptersActive, structure.reading?.kind == .curated {
                            if chapterDropAtEnd {
                                Rectangle()
                                    .fill(tokens.ring)
                                    .frame(height: 2)
                            }
                            Color.clear
                                .frame(height: 28)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .dropDestination(for: String.self) { items, _ in
                                    acceptDrop(items, chapter: .end, post: .unfiled)
                                } isTargeted: { chapterDropAtEnd = $0 }
                        }
                    }
                    .id("nav-noop")
                }
                Spacer(minLength: 4)
                if structure.reading?.kind == .curated {
                    Button(tokens.chromeLabel("+ new chapter")) {
                        chapterNameField = ""
                        newChapterPresented = true
                    }
                    .buttonStyle(.borderless)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    // Round 2, MINOR: the recovery door lives HERE too —
                    // deleting the ONLY chapter leaves no section row to
                    // hang the context menu off.
                    if !structure.deletedSections.isEmpty {
                        Button(tokens.chromeLabel("restore deleted chapter")) {
                            Task { await structure.restoreLastDeletedChapter() }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    }
                    // Round 3, MINOR: no entry door on a FINISHED book
                    // (additive — the model's in-closure gate covers the
                    // concurrent-lock race the hidden button can't).
                    if structure.reading?.profile == "journal",
                       structure.reading?.locked != true {
                        Button(tokens.chromeLabel("+ new entry")) {
                            Task {
                                if let id = await structure.newEntry() {
                                    model.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    } else if structure.reading?.kind == .curated,
                              structure.reading?.locked != true {
                        // Sitting 9 (R62/R75): "it needs to be easy to make
                        // a post inside of a book" — the non-journal door.
                        Button(tokens.chromeLabel("+ new note")) {
                            Task {
                                if let id = await structure.newPost() {
                                    model.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .help("A new note born inside this book — no drag needed")
                    }
                }
                if structure.reading?.kind == .smart {
                    // 13c 2D (C2/N38, the memo's §3 + P-2): the chapter door
                    // is RENDERED on a smart book and it ACTS — it opens the
                    // conversion offer and, on confirm, creates the chapter.
                    // Before this, chapters were a dead end here: the notice
                    // below explained the absence honestly, which is better
                    // than silence but is still lecture-and-stop.
                    //
                    // NOTE what deliberately did NOT become an offer: adding
                    // a post to a smart book already has a BETTER answer
                    // than converting — R98's `collectPostIntoSmartReading`
                    // applies the filter's tags and reports. Chapters are
                    // the one genuinely dead end, because `section_id` lives
                    // on a membership row and derived membership has none.
                    if structure.reading?.locked != true {
                        Button(tokens.chromeLabel("+ new chapter")) {
                            conversionFollowUp = .createChapter
                            Task {
                                conversionCount = await SmartConversionCount.collected(
                                    session, readingID: readingID)
                                conversionOffer = true
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .help("Chapters need a hand-shaped book — this offers to "
                            + "convert, keeping every note it has collected.")
                    }
                    // Batch 6 legibility: a smart book's derived membership
                    // is DESIGNED (#25a) — but absent-and-silent read as
                    // broken. Say so. (ChromeNotice: navigator =
                    // non-scrolling chrome — the window-min class.)
                    ChromeNotice(
                        tokens: tokens,
                        text: "smart book — it collects notes by its tags. Tag a note "
                            + "anywhere and it appears here.",
                        lines: 6)
                }
            }
            .padding(12)
            .frame(width: 190)
            .background(tokens.room)
        }
    }

    /// 13f W20(a) — the ascent, adopted. The shell's one-shot request becomes
    /// this book's landing (W21's slot), so "open the book at this post"
    /// needs no second mechanism: it is the same reveal a mode switch parks,
    /// consumed by whichever surface the book opens in.
    private func takeAscentRequest() {
        guard let revealPostID else { return }
        model.requestReveal(revealPostID)
        onRevealConsumed?()
    }

    // MARK: - W21 — the mode click-over CARRIES your place

    /// Her round-8 condition, answered YES: *"if you click over does it move
    /// where you are?"* The DEPARTING mode is the one that knows where she
    /// is, so the place is captured before the mode changes and parked as a
    /// landing the arriving surface consumes (`BookAnchor` holds the rule;
    /// `BookViewModel` holds the slot; each surface performs its own
    /// landing, because "reveal" means something different on a scroll, a
    /// spread and a page domain).
    private func switchMode(to newMode: BookStructureModel.ViewMode) {
        guard newMode != structure.mode else { return }
        model.carryPlace(from: structure.mode, readForm: structure.readForm)
        structure.mode = newMode
    }

    /// Read's two faces are a mode switch by any other name — the same
    /// carry, so Scroll ↔ Pages keeps her place too.
    private func switchReadForm(to newForm: BookStructureModel.ReadForm) {
        guard newForm != structure.readForm else { return }
        model.carryPlace(from: structure.mode, readForm: structure.readForm)
        structure.readForm = newForm
    }

    // MARK: - The order control (13c 2D — A31)

    /// *"see a book either by its saved custom order or by an attribute
    /// like time to freely change the order of it - should be more like
    /// lenses where the order can be saved."*
    ///
    /// The lens grammar, exactly: picking an attribute is a way of LOOKING
    /// (view-local, writes nothing, every other reader still sees the
    /// book's own order); "Save as this book's order" is the adopt door
    /// (`setReadingSort`). A FINISHED book browses freely and cannot save —
    /// its order is part of what "done" froze, and the op refuses anyway.
    private var orderControl: some View {
        let stored = BookOrderChoices.storedLabel(for: structure.reading)
        let current = model.viewOrder.map(BookOrderChoices.label(for:))
        // Deliberately NOT `VoicedMenu`: that control carries `.fixedSize()`,
        // and this label is long enough that forcing its ideal width pushed
        // the whole 190 pt navigator wider than its frame — every row in the
        // column lost a character off its left edge (caught in the batch's
        // visual loop, P-7; the b6dae25 chrome-sizing class). The label
        // TRUNCATES instead; the menu still says everything in full.
        return Menu {
            Button {
                model.viewOrder = nil
            } label: {
                if model.viewOrder == nil {
                    Label("This book's order (\(stored))", systemImage: "checkmark")
                } else {
                    Text("This book's order (\(stored))")
                }
            }
            Divider()
            ForEach(BookOrderChoices.all) { choice in
                Button {
                    model.viewOrder = choice.order
                } label: {
                    if model.viewOrder == choice.order {
                        Label(choice.label, systemImage: "checkmark")
                    } else {
                        Text(choice.label)
                    }
                }
            }
            if let order = model.viewOrder, structure.reading?.locked != true {
                Divider()
                Button("Save as This Book's Order") {
                    Task {
                        await structure.saveOrder(order)
                        // Saved IS the book's order now — drop the override
                        // so the menu stops claiming a separate way of
                        // looking (and every other reader agrees).
                        model.viewOrder = nil
                    }
                }
            }
        } label: {
            Text(tokens.chromeLabel("order · \(current ?? stored)") + " ▾")
                .font(tokens.small)
                .foregroundStyle(model.viewOrder == nil ? tokens.muted : tokens.accent)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .help("Look at this book in a different order — nothing is written until "
            + "you save it as the book's own order.")
    }

    // MARK: - Outline's landing (the Act 10 correction round, rows 9/12/14/44/47)
    //
    // The one programmatic-scroll mechanism Outline has. What it replaces:
    // a view-private `scrollTarget` beside W21's model slot (two landing
    // doors), and `withAnimation { proxy.scrollTo(…) }` toward targets in a
    // LazyVStack. The animated form was the traced class behind her
    // "scrolling went absolutely berserk … landed me at the end of the
    // note" and the triage walk's livelock: an animation travels toward an
    // ESTIMATED offset (unrealized lazy rows, and a focused inline editor
    // whose row is 20,000 pt tall after its projection fills), rows
    // realize under the travel, the target moves, and the animation either
    // stops short (reproduced twice, deterministically, on the Sherlock
    // book — a chapter click landed mid-story at the same paragraph) or
    // retargets forever (the walk's 190 s sample: every hot frame lazy
    // placement). The fix shape: NO animation, and a BOUNDED convergence —
    // land, read back where the anchor actually sits, hop again while it
    // is not at the top (at most `landingHopBudget` hops). The
    // PanePublisher's own heal-turn discipline, applied to a scroll.

    /// One pending landing: the anchor id and how many hops it has taken.
    private struct OutlineLanding: Equatable {
        var anchorID: String
        var hops = 0
    }
    @State private var outlineLanding: OutlineLanding?
    /// The scroll's named space — anchor frames read in it are visible-
    /// relative, so "at the top" is `minY ≈ 0`.
    static let outlineSpace = "book-outline-scroll"
    /// Within this many points of the top, a landing is DONE.
    static let landingTolerance: CGFloat = 2
    /// The most hops one landing may take (a hop re-scrolls after the
    /// realized geometry moved the target). Bounded by construction — a
    /// target that will not settle stops moving the page rather than
    /// chasing it for the rest of the session.
    static let landingHopBudget = 4

    /// Put an Outline anchor at the top of the page (no animation — see the
    /// mark above), and watch it settle.
    private func landOutline(_ anchorID: String, _ proxy: ScrollViewProxy) {
        outlineLanding = OutlineLanding(anchorID: anchorID)
        proxy.scrollTo(anchorID, anchor: .top)
    }

    /// A realized anchor reported where it sits. Every report feeds the
    /// DEBUG geometry oracle; a report for the PENDING landing decides
    /// whether to hop again.
    fileprivate func outlineAnchorMoved(_ anchorID: String, top: CGFloat, _ proxy: ScrollViewProxy) {
        #if DEBUG
        BookOutlineGeometry.anchorTops[anchorID] = top
        if outlineLanding?.anchorID == anchorID {
            BookOutlineGeometry.trace.append("\(anchorID) top=\(top) hops=\(outlineLanding?.hops ?? -1)")
        }
        #endif
        guard var landing = outlineLanding, landing.anchorID == anchorID else { return }
        if abs(top) <= Self.landingTolerance || landing.hops >= Self.landingHopBudget {
            outlineLanding = nil
            return
        }
        landing.hops += 1
        outlineLanding = landing
        // The next turn, never inside the geometry pass that reported.
        DispatchQueue.main.async { proxy.scrollTo(anchorID, anchor: .top) }
    }

    /// The navigator's note-row click in Outline (the correction round,
    /// rows 7/23/47): REVEAL the note and land in it at its first block —
    /// through the model's one landing slot, which Outline lands whether the
    /// card is on screen or unrealized far below (`landOutline`). The
    /// chapter row of a one-note chapter that says the note's name (row 8)
    /// takes this same door.
    private func openFromNavigator(_ entry: Queries.ReadingEntry) {
        structure.mode = .outline
        model.focus(entry.postID)
        model.requestReveal(entry.postID)
    }

    /// The navigator's chapter click — and, since the correction round
    /// (row 14), the body's chapter HEADING: one act, mode by mode. In the
    /// SPREAD it shows the chapter's first page; in paginated Read it turns
    /// to that page; in Read ▸ Scroll it lands the flow on the chapter's
    /// first note (before this round the click wrote Outline's private
    /// target there and nothing consumed it — the flow never moved); in
    /// Outline it lands the chapter heading at the top.
    private func navigateToChapter(_ section: ReadingSection) {
        let first = structure
            .grouped(entries: model.entries)
            .first(where: { $0.section?.id == section.id })?
            .entries.first
        switch structure.mode {
        case .spread:
            if let first { model.showPost(first.postID) }
        case .read where structure.readForm == .pages:
            // 13c 2C: a chapter opens at its first PAGE, without leaving Read.
            if let first { model.focus(first.postID) }
        case .read:
            if let first { model.requestReveal(first.postID) }
        case .outline, .index:
            model.requestChapterReveal(section.id)
        }
    }
    /// R19 drag state: the chapter the dragged one would land BEFORE, and
    /// the end zone's highlight.
    @State private var chapterDropTarget: String?
    @State private var chapterDropAtEnd = false

    @ViewBuilder
    private func chapterMenu(_ section: ReadingSection) -> some View {
        Button("Rename…") {
            chapterNameField = section.name
            renameChapterTarget = section
        }
        Button("Move Up") { Task { await structure.moveChapter(section.id, up: true) } }
        Button("Move Down") { Task { await structure.moveChapter(section.id, up: false) } }
        Divider()
        Button("Delete Chapter", role: .destructive) {
            Task { await structure.deleteChapter(section.id) }
        }
        Button("Restore Last Deleted Chapter") {
            Task { await structure.restoreLastDeletedChapter() }
        }
    }


    // MARK: - OUTLINE: the book's writing surface (13c 2A — A39)
    //
    // Her words: *"i also feel like I need more of a proper 'write' mode for
    // the whole book - like literally looks like write mode but has the
    // chapter headings and the posts are collapsible."* And the finding that
    // gives it weight (A45): she wanted sub-takes, refused the idea herself,
    // and diagnosed the cause — the BOOK level had never been a writing
    // surface, so the only natural place to compose was inside one post.
    // So this is not a decorated list: it is Write's measure, Write's
    // typography, chapter headings inline, and one live editor that migrates
    // exactly as it does everywhere else (P3).
    //
    // What is NOT here, deliberately: no second liveness mechanism (the
    // focused post mounts the ONE full-document editor, `BookViewModel` is
    // the single focus authority — 13b 3E's fold), no in-place TK2 text
    // folding (collapse is view state — TEXTKIT2 §3; AppSpec §12), and no
    // bottom chrome (A6).

    private var outlineBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    // Batch 12 (her mockup reference): the book's TITLE
                    // heads the content column, aligned with the posts —
                    // never floating in rail-side dead space.
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tokens.chromeLabel(readingName ?? model.readingName ?? "book"))
                            .font(tokens.title)
                            .foregroundStyle(tokens.ink)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(bookMetaLine))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                            // Her #43(a) ruling (13d batch 1): the book opens
                            // as CARDS and "expand all" opens it whole in one
                            // click; "collapse all" folds it back (13b 3E D1:
                            // it releases the focused post's editor too).
                            Button(tokens.chromeLabel("expand all")) {
                                model.expandAll()
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            Button(tokens.chromeLabel("collapse all")) {
                                model.collapseAll()
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        }
                    }
                    .padding(.bottom, 22)
                    if model.entries.isEmpty {
                        Text("This book has no notes yet.")
                            .foregroundStyle(tokens.muted)
                    }
                    // ONE flat ForEach whose identities ARE the landing
                    // anchors (`BookOutlineRows` — the correction round): a
                    // chapter heading, the unfiled heading, a tag-path
                    // heading and a note are each one lazy item, so a
                    // landing on an UNREALIZED row is reachable by the
                    // reader (the nested-ForEach shape hid every anchor
                    // until its row happened to be on screen).
                    ForEach(outlineRows) { row in
                        switch row {
                        case .chapter(let section):
                            chapterHeader(section)
                                .outlineAnchor(row.id, in: self, proxy)
                        case .unfiledHeading:
                            // UNFILED trails the chapters (ratified,
                            // QUESTIONS #26(b)) — the grouping brain's
                            // order, rendered, never re-decided here.
                            Text(tokens.chromeLabel("unfiled"))
                                .font(tokens.heading)
                                .foregroundStyle(tokens.muted)
                                .padding(.top, 28)
                                .outlineAnchor(row.id, in: self, proxy)
                        case .tagHeading(let path, _):
                            // Smart books keep tag-path sectioning
                            // (`grouping_tag_id`) — same heading voice.
                            Text(path)
                                .font(tokens.title)
                                .foregroundStyle(tokens.accent)
                                .padding(.top, 28)
                                .outlineAnchor(row.id, in: self, proxy)
                        case .note(let entry):
                            postRow(entry)
                                .outlineAnchor(row.id, in: self, proxy)
                        }
                    }
                    if structure.chaptersActive {
                        bodyChapterEndZone  // N21: drag a chapter past the last
                    }
                    if model.truncated {
                        Text("Showing the first \(BookViewModel.entryWindow) notes — "
                            + "the rest of this book isn't loaded yet "
                            + "(windowing arrives with Phase 12).")
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 8)
                    }
                    // Sitting 9 batch 6: the add-post door lives IN the
                    // book's flow too, where writing ends — the navigator
                    // rail's twin (R62/R75; discoverability is the point).
                    if structure.reading?.locked != true {
                        if structure.reading?.profile == "journal" {
                            Button(tokens.chromeLabel("+ new entry")) {
                                Task {
                                    if let id = await structure.newEntry() {
                                        model.focus(id)
                                        model.requestReveal(id)
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                        } else if structure.reading?.kind == .curated {
                            Button(tokens.chromeLabel("+ new note in this book")) {
                                Task {
                                    if let id = await structure.newPost() {
                                        model.focus(id)
                                        model.requestReveal(id)
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                            .help("A new note born inside this book — no drag needed")
                        }
                    }
                }
                // 13c 2A: WRITE'S OWN MEASURE, at book scale (A39's
                // "literally looks like write mode"; R9 — margins are
                // sacred). The detail editor centers an
                // `EditorTypography.maxColumnWidth` prose column; both text
                // tiers in this column (the inline editor and the read
                // surface) carry the same 8pt container inset, so a column
                // of maxColumn + 2×inset puts this book's prose on exactly
                // the measure Write puts a post's on. It stays LEFT-ANCHORED
                // beside the navigator (batch 12, her mockup reference:
                // "there shouldn't be so much open space to the left").
                // Wave 2c: the row includes the details gutter — the prose
                // keeps its measure; the gutter takes the right. The
                // correction round (row 13): the gutter is FLEXIBLE, so the
                // row spans the pane and the right edge is the pane's own
                // rather than a rail's cliff 190 pt past the prose.
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 22)
            }
            .coordinateSpace(name: Self.outlineSpace)
            // 13f W21 — OUTLINE'S LANDING. Both halves are needed and for
            // different reasons: `onAppear` catches the arrival (this body
            // mounts only after the mode has already changed, so the carry's
            // request predates the view), `onChange` catches a reveal that
            // arrives while Outline is already on screen (W20's ascent into
            // a book that is open, the navigator's rows).
            //
            // Reveal is SCROLL-TO and never an auto-expand: posts open
            // collapsed by her #43(a) ruling, and the ROW carries the
            // `page-<id>` anchor whichever form it wears (the correction
            // round moved the anchor from the card/header INSIDE the row to
            // the row itself — an id on an inner view of an unrealized lazy
            // row is unknown to the scroll reader, which is why an off-screen
            // note could not be revealed: row 47). The navigator's note-row
            // click focuses AND reveals, so the arrival is unfolded by her
            // own act, never by the reveal.
            .onAppear { landOutlineReveal(proxy) }
            .onChange(of: model.pendingReveal) { _, _ in landOutlineReveal(proxy) }
            .onChange(of: model.pendingChapterReveal) { _, _ in landOutlineReveal(proxy) }
            // 13c 2A (her item A6, RULED 2026-07-24): Outline's ENTIRE
            // bottom inset is gone — the `Slider` jump control ("it makes
            // no sense to have a horizontal scrollbar on a vertical page")
            // AND the progress bar above it ("it seems a bit buggy… remove
            // it fully for now, I'll add it later if I feel inclined").
            // If it is ever re-added, the bugginess she saw is investigated
            // FIRST — an observed defect parked by removal, not chased.
            // Outline ends as a clean vertical scroll + the navigator.
            // The model's scrub/progress brains stay (pure, pinned): the
            // Book spread and Read's paginated sub-mode both KEEP a bottom
            // bar, and 2B/2C are their owners.
        }
    }

    /// Outline's half of W21's landing — and the chapter landing's only
    /// consumer: put the requested note (or chapter) at the top and consume
    /// the request. Nothing else moves — no focus, no expansion.
    private func landOutlineReveal(_ proxy: ScrollViewProxy) {
        if let sectionID = model.pendingChapterReveal {
            model.consumeChapterReveal()
            if structure.sections.contains(where: { $0.id == sectionID }) {
                landOutline(BookOutlineRows.Row.chapterAnchor(sectionID), proxy)
            }
        }
        guard let postID = model.pendingReveal else { return }
        model.consumeReveal()
        guard model.entries.contains(where: { $0.postID == postID }) else { return }
        landOutline(BookOutlineRows.Row.noteAnchor(postID), proxy)
    }

    /// 13b 3E (N21 — her "the dots … make me feel like it should be
    /// draggable and it isn't"): the body's chapter header now DRAGS. The
    /// dots are honest — same insert-before semantics, same indicator
    /// grammar, and the same model door (`moveChapter(before:)`) as the
    /// navigator; the end zone below the last group lands a chapter last.
    private func chapterHeader(_ section: ReadingSection) -> some View {
        HStack(spacing: 6) {
            Text("⠿")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .help("Drag to reorder this chapter — here or in the navigator "
                    + "(right-click for Move Up / Move Down)")
            // 13c 2A (A39: "has the chapter headings"): a chapter reads as
            // a HEADING in the book's own voice — the title face, with real
            // air above it — not as a chrome row above a list. The
            // correction round (row 14 — "clicking on the chapters isn't
            // even TRYING to navigate"): the heading is a DOOR too — a
            // click puts the chapter at the top of the page, exactly as the
            // navigator's row does; the drag handle stays a handle.
            Button {
                navigateToChapter(section)
            } label: {
                Text(tokens.chromeLabel(section.name))
                    .font(tokens.title)
                    .foregroundStyle(tokens.accent)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Put this chapter at the top of the page")
        }
        .padding(.top, 28)
        // The drop indicator rides as an overlay rather than a sibling row,
        // so the heading is ONE lazy item carrying one anchor (the row-level
        // identity the scroll reader lands on — see `outlineAnchor`).
        .overlay(alignment: .top) {
            if bodyChapterDropTarget == section.id {
                Rectangle()
                    .fill(tokens.ring)
                    .frame(height: 2)
            }
        }
        // 13f W11a — THE REACH FIX, at the site batch 1's trace named: the
        // body header carried no `contentShape`, so its target was the
        // GLYPHS (the navigator's is a `Button` and takes its row). It is now
        // the full-width row INCLUDING the 28 pt of air above it, which is
        // the gap between one chapter's last post and the next chapter's
        // heading — the "target in the gap" her ruling asked for, without a
        // second view to keep in sync.
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .contextMenu { chapterMenu(section) }
        .draggable(BookStructureModel.BookDrag.chapter(section.id).payload)
        .dropDestination(for: String.self) { items, _ in
            acceptDrop(items, chapter: .chapter(section.id), post: .chapter(section.id))
        } isTargeted: { targeted in
            if targeted {
                bodyChapterDropTarget = section.id
            } else if bodyChapterDropTarget == section.id {
                bodyChapterDropTarget = nil
            }
        }
    }

    /// Every drop target in this view routes through the model's one
    /// dispatcher (13f W11); the view only says what a chapter and a post
    /// MEAN at this spot.
    @MainActor
    private func acceptDrop(
        _ items: [String],
        chapter chapterSite: BookStructureModel.ChapterDropSite,
        post postSite: BookStructureModel.PostDropSite
    ) -> Bool {
        structure.acceptDrop(
            items, chapter: chapterSite, post: postSite,
            entries: model.entries, viewOrder: model.viewOrder)
    }

    /// The body's end drop zone (N21's twin of the navigator's R19 zone).
    @ViewBuilder
    private var bodyChapterEndZone: some View {
        if structure.chaptersActive, structure.reading?.kind == .curated {
            if bodyChapterDropAtEnd {
                Rectangle()
                    .fill(tokens.ring)
                    .frame(height: 2)
            }
            Color.clear
                // 13f W11a: 14 → 44. In the BODY this strip sits after a
                // whole book's prose and was the only "put this chapter
                // last" target there is; a two-chapter book had nowhere else
                // to go. Empty space at the end of a scroll costs nothing.
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .dropDestination(for: String.self) { items, _ in
                    acceptDrop(items, chapter: .end, post: .unfiled)
                } isTargeted: { bodyChapterDropAtEnd = $0 }
        }
    }

    @State private var bodyChapterDropTarget: String?
    @State private var bodyChapterDropAtEnd = false
    /// 13f W11: the navigator's post-row drop indicator.
    @State private var postDropTarget: String?

    /// The navigator's "you are here": the focused post — and, in the
    /// SPREAD, BOTH pages on screen (13b 4F; 13c 2B — a spread shows two
    /// posts, so two rows are honestly "here").
    private func navigatorMarks(_ entry: Queries.ReadingEntry) -> Bool {
        model.focusedPostID == entry.postID
            || (structure.mode == .spread && model.isOnSpread(entry.postID))
    }

    /// Outline's flat row list (`BookOutlineRows`): chapters from the
    /// structure model where they govern, else the tag-path grammar.
    private var outlineRows: [BookOutlineRows.Row] {
        structure.chaptersActive
            ? BookOutlineRows.rows(grouped: structure.grouped(entries: model.entries))
            : BookOutlineRows.rows(flat: model.entries)
    }

    /// Batch 12: kind + extent at a glance under the title.
    private var bookMetaLine: String {
        var parts: [String] = [structure.reading?.kind == .smart ? "smart book" : "book"]
        if structure.sections.count > 0 { parts.append("\(structure.sections.count) chapters") }
        parts.append("\(model.entries.count) notes")
        return parts.joined(separator: " · ")
    }

    /// One post in the outline (13c 2A — extracted from four inline
    /// builders so the row has an INIT the virtualization counter can ride,
    /// the `ReadingFlowView` precedent; P-9's split rides along).
    private func postRow(_ entry: Queries.ReadingEntry) -> some View {
        OutlinePostRow(
            session: session, model: model, structure: structure,
            entry: entry, tokens: tokens)
    }
}

#if DEBUG
/// 13c 2A's virtualization pin support (the `ReadingFlowMaterialization`
/// precedent): counts `OutlinePostRow` materializations so the P3 pin can
/// assert the `LazyVStack` defers off-viewport rows. Load-bearing HERE in a
/// way it was not before: posts render OPEN by default now, so an
/// unvirtualized outline would realize a text surface per post in the book.
@MainActor
enum BookOutlineMaterialization {
    static var count = 0
}

/// The correction round's landing oracle: where every REALIZED Outline
/// anchor (`page-<postID>` · `chapter-<sectionID>`) sits, in the scroll's
/// visible space — `0` is the top of the page. Fed by the same geometry
/// reports the landing's convergence reads, so a pin asserts the landing
/// the user sees, not a scroll request that was merely issued.
@MainActor
enum BookOutlineGeometry {
    static var anchorTops: [String: CGFloat] = [:]
    /// The pending landing's report sequence (id · top · hop) — what a pin
    /// prints when a landing does not converge.
    static var trace: [String] = []
}
#endif

private extension View {
    /// An Outline row's landing anchor, at the LAZY STACK's level: the id
    /// the scroll reader lands on, and the geometry report the landing
    /// converges on (`BookView.outlineAnchorMoved`). At the row, not inside
    /// it — an unrealized lazy row's inner views do not exist yet, so an id
    /// on the card or the header was invisible to `scrollTo` until the row
    /// happened to be on screen (row 47's "the page did not move").
    func outlineAnchor(_ id: String, in book: BookView, _ proxy: ScrollViewProxy) -> some View {
        self
            .id(id)
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.frame(in: .named(BookView.outlineSpace)).minY
            } action: { top in
                book.outlineAnchorMoved(id, top: top, proxy)
            }
    }
}

/// One post in Outline: batch 12's card until it is deliberately expanded,
/// and then its prose (read-cheap, or THE one live editor when focused).
///
/// Her #43(a) ruling (13d batch 1) put the CARD back as the default here —
/// 2A's open-by-default was PROVISIONAL and she overturned it; `expand` is
/// the deliberate act (the model tracks the EXPANDED set). Either way it is
/// pure view state — never in-place text folding inside a live TK2 editor
/// (TEXTKIT2 §3; AppSpec §12).
///
/// 13b 3E (D1): expansion + focus live on the MODEL — ONE authority. The
/// focused post is expanded because `focus` insists, and `collapse`
/// releases focus, so the old force-expand disjunct is gone.
private struct OutlinePostRow: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    let entry: Queries.ReadingEntry
    let tokens: VoiceTokens

    init(
        session: AppSession, model: BookViewModel, structure: BookStructureModel,
        entry: Queries.ReadingEntry, tokens: VoiceTokens
    ) {
        self.session = session
        self.model = model
        self.structure = structure
        self.entry = entry
        self.tokens = tokens
        #if DEBUG
        BookOutlineMaterialization.count += 1
        #endif
    }

    /// 13f W11: this row's drop indicator (a chapter or a post is hovering).
    @State private var dropTargeted = false
    /// The note's details for the gutter (wave 2c — fetched once per
    /// realized row, the PostCardExcerpt cadence it replaces).
    @State private var excerpt = ""
    @State private var meta = ""

    var body: some View {
        Group {
            if model.isExpanded(entry.postID) {
                if model.liveFocusedPostID == entry.postID {
                    // THE FOCUSED NOTE: the editor's bar rides the gutter
                    // (`.side` — W8-5's "those should render to the side";
                    // the ONE bar, arranged vertically, exactly where the
                    // unfocused rows put their details).
                    VStack(alignment: .leading, spacing: 6) {
                        postHeader
                            .bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                            .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                        EditorView(
                            session: session, postID: entry.postID, inline: true,
                            caretSeed: model.caretSeed, fanSeed: model.fanSeed,
                            barPlacement: .side)
                            .id(entry.postID)
                    }
                    .frame(maxWidth: BookView.outlineFocusedRowWidth, alignment: .leading)
                    .padding(.bottom, 26)
                } else {
                    // Expanded, read-cheap: prose at the measure, the
                    // note's facts in the gutter.
                    HStack(alignment: .top, spacing: BookView.outlineGutterSpacing) {
                        VStack(alignment: .leading, spacing: 6) {
                            // The HEADER is the handle, not the prose: an
                            // expanded post shows a read-cheap text surface,
                            // and a drag over it would fight selection.
                            postHeader.bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                            ReadPostView(
                                session: session, postID: entry.postID,
                                onFocusRequest: { offset in
                                    model.focus(entry.postID, caret: offset)
                                },
                                onBadgeTap: { blockID in
                                    // Interpretation 1 (PROVISIONAL): focus
                                    // FIRST, then the fan panel opens on the
                                    // one live surface.
                                    model.focus(entry.postID, fanBlock: blockID)
                                })
                                .id("read-\(entry.postID)")
                        }
                        .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                        .layoutPriority(1)  // the prose claims its measure before the gutter flexes
                        // An expanded note's takes wear their own badges on
                        // the prose; the gutter beside it stays calm (row 13).
                        Spacer(minLength: BookView.outlineGutterWidth)
                    }
                    .padding(.bottom, 26)
                }
            } else {
                HStack(alignment: .top, spacing: BookView.outlineGutterSpacing) {
                    collapsedPostCard
                        .bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                        .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                        .layoutPriority(1)  // the card claims its measure before the gutter flexes
                    // Row 13: the gutter shares the pane's width with the
                    // card honestly (flexible, never a fixed rail with a
                    // cliff at its right), and carries the one fact a card
                    // cannot show — that a block has takes.
                    gutterDetails
                        .frame(minWidth: BookView.outlineGutterWidth, maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 13)
                }
                .padding(.bottom, 2)
            }
        }
        .task(id: entry.postID) { await loadFacts() }
    }

    /// The gutter's details beside a card: the takes fact (row 13 — the
    /// note info that used to sit BELOW the card's opening paragraphs,
    /// W8-5 — to the side, never below; the word count dropped, C-6).
    @ViewBuilder private var gutterDetails: some View {
        if !meta.isEmpty {
            Text(tokens.chromeLabel(meta))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .multilineTextAlignment(.leading)
        }
    }

    /// One fetch per realized row (LazyVStack — cost ∝ what's on screen,
    /// P1; the PostCardExcerpt cadence, hoisted so the card and the gutter
    /// share it).
    private func loadFacts() async {
        let slots = (try? await session.database.read { [postID = entry.postID] db in
            try Queries.renderPost(db, containerID: postID)
        }) ?? []
        // Row 45: the preview reads ACROSS the leading blocks and skips a
        // lone heading/numeral ("I."); row 13: the gutter carries the takes
        // fact alone — the per-card word count is DROPPED (C-6).
        excerpt = BookOutlineRows.cardPreview(blocks: slots.compactMap(\.text))
        meta = BookOutlineRows.gutterLine(fannedBlocks: slots.filter(\.hasFan).count) ?? ""
    }

    /// 13f W11 — the row's own drag/drop contract, shared by both forms
    /// (collapsed card and expanded header) through `bookDropRow`.
    fileprivate var dragPayload: String {
        BookStructureModel.BookDrag.post(entry.postID).payload
    }

    fileprivate func accept(_ items: [String]) -> Bool {
        structure.acceptDrop(
            items, chapter: .post(entry.postID), post: .post(entry.postID),
            entries: model.entries, viewOrder: model.viewOrder)
    }

    /// The post's heading in the book's own voice (13c 2A): the title reads
    /// as a title; the doors — collapse, and out into the full editor —
    /// recede to quiet chrome beside it, because this is a page she writes
    /// on, not a catalog row.
    private var postHeader: some View {
        HStack(spacing: 6) {
            // 13b 3E (D1): the ONE collapse door — it releases focus too,
            // so collapsing the post you're typing in actually collapses it.
            Button("▾") { model.collapse(entry.postID) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Collapse this note back to its card")
            Text(outlineEntryTitle(entry))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
            if let date = entry.entryDate {
                Text(date)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            // Sitting 9 batch 7: the door OUT of the book into the post's
            // full editor (modes, takes, lenses — everything).
            Button(tokens.chromeLabel("open ↗")) {
                NotificationCenter.default.post(
                    name: .variorumOpenPost, object: nil,
                    userInfo: ["postID": entry.postID])
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help("Open this note in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.top, 10)
        // (The `page-<id>` landing anchor moved to the ROW, at the lazy
        // stack's level — `BookView.outlineAnchor`; the correction round.)
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
    }

    // (postBody's two branches were inlined into `body` at wave 2c — the
    // focused branch is still THE one live editor, P3 by construction (a
    // single focused id via `liveFocusedPostID`, 13f batch 4's mount rule);
    // its bar now rides the gutter through `barPlacement: .side`.)

    /// The collapsed card (batch 12's ruling — and, since her #43(a) ruling
    /// at the 13c walk, this surface's DEFAULT form again). 13b 3E
    /// (N22): the card BODY opens the post in the full editor; the ▸
    /// disclosure unfolds it in place. Each target does what it looks like.
    private var collapsedPostCard: some View {
        Button {
            NotificationCenter.default.post(
                name: .variorumOpenPost, object: nil,
                userInfo: ["postID": entry.postID])
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Button {
                        model.expand(entry.postID)
                    } label: {
                        Text("▸")
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .padding(.horizontal, 2)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Unfold this note in place — write in it right here")
                    Text(outlineEntryTitle(entry))
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                    if let date = entry.entryDate {
                        Text(date)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                    Spacer()
                    Button(tokens.chromeLabel("open ↗")) {
                        NotificationCenter.default.post(
                            name: .variorumOpenPost, object: nil,
                            userInfo: ["postID": entry.postID])
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .help("Open this note in the full editor (Write · Takes · Lenses · …)")
                }
                // Wave 2c (W8-5): the excerpt stays on the card; the META
                // moved out to the gutter — details to the side, never
                // below the opening paragraphs.
                if !excerpt.isEmpty {
                    Text(excerpt)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.card)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Click to open this note in the full editor; ▸ unfolds it here")
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
    }
}

private extension View {
    /// 13f W11 — one modifier, both of an outline row's forms: the row drags
    /// (its post) and receives (a chapter snapping to the nearest boundary,
    /// or another post filing into this one's chapter). The insertion bar is
    /// the same grammar the chapter drag has used since R19.
    func bookDropRow(
        _ row: OutlinePostRow, targeted: Binding<Bool>, tokens: VoiceTokens
    ) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .draggable(row.dragPayload)
            .dropDestination(for: String.self) { items, _ in
                row.accept(items)
            } isTargeted: { targeted.wrappedValue = $0 }
            .overlay(alignment: .top) {
                if targeted.wrappedValue {
                    Rectangle().fill(tokens.ring).frame(height: 2)
                }
            }
    }
}

/// A post's chapter-filing menu — ONE definition, two callers (the
/// navigator's rows and the outline's own rows). Curated books only:
/// chapters are a curated-reading concept (QUESTIONS #25(a)).
@MainActor
@ViewBuilder
private func outlineChapterMenu(
    structure: BookStructureModel, postID: String
) -> some View {
    if structure.reading?.kind == .curated {
        Menu("Chapter") {
            ForEach(structure.sections, id: \.id) { section in
                Button(section.name) {
                    Task { await structure.assign(postID, to: section.id) }
                }
            }
            Divider()
            Button("None") {
                Task { await structure.assign(postID, to: nil) }
            }
        }
    }
}

/// A reading entry's display title — shared by every book surface's rows.
/// 13g batch 7 (R6-3): the ONE display brain — title, else the note's
/// date. Kept as a named helper only so the call sites read the same.
private func outlineEntryTitle(_ entry: Queries.ReadingEntry) -> String {
    entry.displayTitle
}

// (PostCardExcerpt was absorbed into OutlinePostRow at wave 2c — the one
// fetch now serves the card's excerpt AND the gutter's meta, same
// per-realized-row cadence.)

/// The navigator's settings leg (R43): finish, rename, extents — the book's
/// own faces, beside the shelf's.
struct BookSettingsSheet: View {
    let structure: BookStructureModel
    @State private var nameField = ""
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Book Settings").font(.headline)
            Form {
                TextField("Name", text: $nameField)
                TextField("Word target (blank = none)", text: $wordTargetField)
                TextField("Note cap (blank = none)", text: $maxPostsField)
                if let reading = structure.reading {
                    Toggle("Finished", isOn: Binding(
                        get: { reading.locked },
                        set: { finished in Task { await structure.setFinished(finished) } }))
                }
            }
            Text("Finishing freezes the book's membership and order (reversible). A finished book opens as pure text.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let parseError {
                Text(parseError).font(.caption).alarmVoice()
            }
            HStack {
                Spacer()
                Button("Close") {
                    if save() { dismiss() }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
        .onAppear {
            nameField = structure.reading?.name ?? ""
            wordTargetField = structure.reading?.wordTarget.map(String.init) ?? ""
            maxPostsField = structure.reading?.maxPosts.map(String.init) ?? ""
        }
    }

    /// Round 2, MINOR: unparseable input REFUSES and keeps (ExtentInput —
    /// the one parse rule shared with the shelf's sheet).
    private func save() -> Bool {
        guard let target = ExtentInput.parse(wordTargetField),
              let cap = ExtentInput.parse(maxPostsField)
        else {
            parseError = "Extents are plain positive numbers (e.g. 10000) — nothing was changed."
            return false
        }
        let name = nameField.trimmingCharacters(in: .whitespaces)
        Task {
            if !name.isEmpty, name != structure.reading?.name {
                await structure.rename(to: name)
            }
            if target.intValue != structure.reading?.wordTarget {
                await structure.setWordTarget(target.intValue)
            }
            if cap.intValue != structure.reading?.maxPosts {
                await structure.setMaxPosts(cap.intValue)
            }
        }
        return true
    }
}
