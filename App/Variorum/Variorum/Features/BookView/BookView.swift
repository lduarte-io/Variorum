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

    var body: some View {
        HStack(spacing: 0) {
            navigator
            Divider().overlay(tokens.line)
            switch structure.mode {
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
                        onWake: { postID in
                            structure.mode = .outline
                            model.focus(postID)
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
                    .foregroundStyle(.red)
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

    private var navigator: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 6) {
                Text(tokens.path([readingName ?? model.readingName ?? "book"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    // 13c 2A (her 2026-07-23/24 direction): the three modes
                    // read OUTLINE · BOOK · READ — outline is where the book
                    // is written (A39), book is the post-per-page spread,
                    // read is the reading flow.
                    Picker("", selection: Binding(
                        get: { structure.mode },
                        set: { switchMode(to: $0) })) {
                        Text(tokens.chromeLabel("Outline")).tag(BookStructureModel.ViewMode.outline)
                        Text(tokens.chromeLabel("Book")).tag(BookStructureModel.ViewMode.spread)
                        Text(tokens.chromeLabel("Read")).tag(BookStructureModel.ViewMode.read)
                    }
                    .pickerStyle(.segmented)
                    // 13c 2D — found by this batch's visual loop, and
                    // PRE-EXISTING (verified by capturing with this batch's
                    // own control removed: identical). MEASURED with
                    // temporary borders on the padded content box vs the
                    // 190 pt frame box: the content's ideal width was
                    // ~209 pt. `.frame(width:)` does not clip — it CENTERS
                    // an over-wide child — so the whole navigator drew
                    // ~9.5 pt left of its column and EVERY row in it (the
                    // post list, the chapter doors, the smart-book notice)
                    // lost its first character off the window edge. The
                    // floor was the segmented picker's own minimum, which
                    // grew when 2A renamed the modes `Outline · Book · Read`;
                    // `.controlSize(.small)` brings the row under the column
                    // without touching the column's intended width, and the
                    // content box then sits inside the frame box exactly.
                    // The b6dae25 chrome-sizing class, which P-8 carries as
                    // standing law: chrome must never force its container
                    // wider. (`.frame(maxWidth: .infinity)` was tried first
                    // and did nothing — an HStack still reports its child's
                    // ideal width upward.) If the smaller picker ever reads
                    // wrong, the LOOK is the Design & UI review row's; a
                    // column that clips its own text is not a taste question.
                    .controlSize(.small)
                    Button {
                        settingsShown = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.borderless)
                    .help("Book settings — finish, length, rename")
                }
                // 13c 2C: READ's pair of faces (her direction — "the
                // Apple-Books/Kindle PAIR of modes"). It sits UNDER the mode
                // picker rather than in a bottom bar, because one of the two
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
                    .help("Read the book as one continuous scroll, or as real pages "
                        + "with the text flowing across them")
                }
                orderControl
                if let reading = structure.reading, reading.locked {
                    Text(tokens.chromeLabel("✓ finished"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
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
                                Button {
                                    // Navigate: land the book scroll at the
                                    // chapter (the flow view shows it too);
                                    // in the SPREAD, show the chapter's
                                    // first page (13b 4F; 13c 2B).
                                    let first = structure
                                        .grouped(entries: model.entries)
                                        .first(where: { $0.section?.id == section.id })?
                                        .entries.first
                                    if structure.mode == .spread {
                                        if let first { model.showPost(first.postID) }
                                    } else if structure.mode == .read,
                                              structure.readForm == .pages {
                                        // 13c 2C: a chapter opens at its
                                        // first PAGE, without leaving Read.
                                        if let first { model.focus(first.postID) }
                                    } else {
                                        scrollTarget = "chapter-\(section.id)"
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("⠿")
                                            .font(tokens.small)
                                            .foregroundStyle(tokens.faint)
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
                                .contextMenu { chapterMenu(section) }
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
                            // context jump).
                            ForEach(group.entries, id: \.postID) { entry in
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
                                        structure.mode = .outline
                                        model.focus(entry.postID)
                                        scrollTarget = "page-\(entry.postID)"
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
                        Button(tokens.chromeLabel("+ new post")) {
                            Task {
                                if let id = await structure.newPost() {
                                    model.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .help("A new post born inside this book — no drag needed")
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
                            + "convert, keeping every post it has collected.")
                    }
                    // Batch 6 legibility: a smart book's derived membership
                    // is DESIGNED (#25a) — but absent-and-silent read as
                    // broken. Say so. (ChromeNotice: navigator =
                    // non-scrolling chrome — the window-min class.)
                    ChromeNotice(
                        tokens: tokens,
                        text: "smart book — it collects posts by its tags. Tag a post "
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

    /// The book scroll's pending landing (chapter/outline clicks).
    @State private var scrollTarget: String?
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
                LazyVStack(alignment: .leading, spacing: 4) {
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
                    .padding(.bottom, 18)
                    if model.entries.isEmpty {
                        Text("This book has no posts yet.")
                            .foregroundStyle(tokens.muted)
                    }
                    if structure.chaptersActive {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                            if let section = group.section {
                                chapterHeader(section)
                            } else {
                                // UNFILED trails the chapters (ratified,
                                // QUESTIONS #26(b)) — the grouping brain's
                                // order, rendered, never re-decided here.
                                Text(tokens.chromeLabel("unfiled"))
                                    .font(tokens.heading)
                                    .foregroundStyle(tokens.muted)
                                    .padding(.top, 28)
                            }
                            ForEach(group.entries, id: \.postID) { entry in
                                postRow(entry)
                            }
                        }
                        bodyChapterEndZone  // N21: drag a chapter past the last
                    } else {
                        ForEach(Array(model.entries.enumerated()), id: \.element.postID) { i, entry in
                            if let section = model.sectionHeader(at: i) {
                                // Smart books keep tag-path sectioning
                                // (`grouping_tag_id`) — same heading voice.
                                Text(section)
                                    .font(tokens.title)
                                    .foregroundStyle(tokens.accent)
                                    .padding(.top, 28)
                            }
                            postRow(entry)
                        }
                    }
                    if model.truncated {
                        Text("Showing the first \(BookViewModel.entryWindow) posts — "
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
                                        scrollTarget = "page-\(id)"
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                        } else if structure.reading?.kind == .curated {
                            Button(tokens.chromeLabel("+ new post in this book")) {
                                Task {
                                    if let id = await structure.newPost() {
                                        model.focus(id)
                                        scrollTarget = "page-\(id)"
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                            .help("A new post born inside this book — no drag needed")
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
                .frame(maxWidth: Self.proseColumn, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .onChange(of: scrollTarget) { _, target in
                guard let target else { return }
                withAnimation { proxy.scrollTo(target, anchor: .top) }
                scrollTarget = nil
            }
            // 13f W21 — OUTLINE'S LANDING. Both halves are needed and for
            // different reasons: `onAppear` catches the arrival (this body
            // mounts only after the mode has already changed, so the carry's
            // request predates the view), `onChange` catches a reveal that
            // arrives while Outline is already on screen (W20's ascent into
            // a book that is open).
            //
            // Reveal is SCROLL-TO and never an auto-expand: posts open
            // collapsed by her #43(a) ruling, and the card carries the same
            // `page-<id>` anchor the expanded header does, so a collapsed
            // post is revealed exactly as well as an open one. (If she wants
            // the arrival unfolded, that is a ruling, not a fix.)
            .onAppear { landOutlineReveal(proxy) }
            .onChange(of: model.pendingReveal) { _, _ in landOutlineReveal(proxy) }
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

    /// Outline's half of W21's landing: scroll to the requested post and
    /// consume the request. Nothing else moves — no focus, no expansion.
    private func landOutlineReveal(_ proxy: ScrollViewProxy) {
        guard let postID = model.pendingReveal else { return }
        model.consumeReveal()
        guard model.entries.contains(where: { $0.postID == postID }) else { return }
        withAnimation { proxy.scrollTo("page-\(postID)", anchor: .top) }
    }

    /// 13b 3E (N21 — her "the dots … make me feel like it should be
    /// draggable and it isn't"): the body's chapter header now DRAGS. The
    /// dots are honest — same insert-before semantics, same indicator
    /// grammar, and the same model door (`moveChapter(before:)`) as the
    /// navigator; the end zone below the last group lands a chapter last.
    @ViewBuilder
    private func chapterHeader(_ section: ReadingSection) -> some View {
        if bodyChapterDropTarget == section.id {
            Rectangle()
                .fill(tokens.ring)
                .frame(height: 2)
        }
        HStack(spacing: 6) {
            Text("⠿")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .help("Drag to reorder this chapter — here or in the navigator "
                    + "(right-click for Move Up / Move Down)")
            // 13c 2A (A39: "has the chapter headings"): a chapter reads as
            // a HEADING in the book's own voice — the title face, with real
            // air above it — not as a chrome row above a list.
            Text(tokens.chromeLabel(section.name))
                .font(tokens.title)
                .foregroundStyle(tokens.accent)
        }
        .padding(.top, 28)
        // 13f W11a — THE REACH FIX, at the site batch 1's trace named: the
        // body header carried no `contentShape`, so its target was the
        // GLYPHS (the navigator's is a `Button` and takes its row). It is now
        // the full-width row INCLUDING the 28 pt of air above it, which is
        // the gap between one chapter's last post and the next chapter's
        // heading — the "target in the gap" her ruling asked for, without a
        // second view to keep in sync.
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .id("chapter-\(section.id)")
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

    /// Batch 12: kind + extent at a glance under the title.
    private var bookMetaLine: String {
        var parts: [String] = [structure.reading?.kind == .smart ? "smart book" : "book"]
        if structure.sections.count > 0 { parts.append("\(structure.sections.count) chapters") }
        parts.append("\(model.entries.count) posts")
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
#endif

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

    var body: some View {
        if model.isExpanded(entry.postID) {
            VStack(alignment: .leading, spacing: 6) {
                // The HEADER is the handle, not the prose: an expanded post
                // shows a live editor or a read-cheap text surface, and a
                // drag over those would fight selection. Its title row is
                // where "pick up this post" belongs.
                postHeader.bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                postBody
            }
            .padding(.bottom, 22)
        } else {
            collapsedPostCard
                .bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                .padding(.bottom, 10)
        }
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
                .help("Collapse this post back to its card")
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
            .help("Open this post in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.top, 10)
        .id("page-\(entry.postID)")  // the navigator's landing anchor
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
    }

    @ViewBuilder
    private var postBody: some View {
        // 13f batch 4: `liveFocusedPostID`, not `focusedPostID` — a book in
        // an unfocused PANE mounts no live editor (the mount rule). The
        // reading position itself is untouched, so regaining focus restores
        // exactly what she was editing.
        if model.liveFocusedPostID == entry.postID {
            // THE one live editor (P3 by construction: a single focused id;
            // it is the full-document editor, so every routed act — ⌘S,
            // divide, callout, comments — reaches this surface through the
            // capability registry's attached-editor arm, exactly as in
            // Write. Stage 4 lesson 2 holds here without a second handler.)
            EditorView(
                session: session, postID: entry.postID, inline: true,
                caretSeed: model.caretSeed, fanSeed: model.fanSeed)
                .id(entry.postID)
        } else {
            ReadPostView(
                session: session, postID: entry.postID,
                onFocusRequest: { offset in
                    model.focus(entry.postID, caret: offset)
                },
                onBadgeTap: { blockID in
                    // Interpretation 1 (PROVISIONAL): focus FIRST, then the
                    // fan panel opens on the one live surface.
                    model.focus(entry.postID, fanBlock: blockID)
                })
                .id("read-\(entry.postID)")
        }
    }

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
                    .help("Unfold this post in place — write in it right here")
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
                    .help("Open this post in the full editor (Write · Takes · Lenses · …)")
                }
                PostCardExcerpt(session: session, postID: entry.postID, tokens: tokens)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.card)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Click to open this post in the full editor; ▸ unfolds it here")
        .id("page-\(entry.postID)")  // the navigator's landing anchor
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
private func outlineEntryTitle(_ entry: Queries.ReadingEntry) -> String {
    entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
}

/// Batch 12 — the collapsed card's excerpt + meta line (her referenced
/// mockup: "2,140w · rev may 3" / "⑂ takes on 2 blocks"). Fetched per
/// visible card (LazyVStack realization — cost ∝ what's on screen, P1).
private struct PostCardExcerpt: View {
    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    @State private var excerpt = ""
    @State private var meta = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !excerpt.isEmpty {
                Text(excerpt)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            if !meta.isEmpty {
                Text(tokens.chromeLabel(meta))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        .task(id: postID) {
            let slots = (try? await session.database.read { [postID] db in
                try Queries.renderPost(db, containerID: postID)
            }) ?? []
            let first = slots.compactMap(\.text).first { !$0.isEmpty } ?? ""
            excerpt = String(first.prefix(280))
            let words = slots.reduce(0) { $0 + TextMetrics.wordCount($1.text ?? "") }
            let fanned = slots.filter(\.hasFan).count
            var parts = ["\(words.formatted())w"]
            if fanned > 0 {
                parts.append("⑂ takes on \(fanned) block\(fanned == 1 ? "" : "s")")
            }
            meta = parts.joined(separator: " · ")
        }
    }
}

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
                TextField("Post cap (blank = none)", text: $maxPostsField)
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
                Text(parseError).font(.caption).foregroundStyle(.red)
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
