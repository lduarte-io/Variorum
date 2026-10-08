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
    /// 13i-c U4: the navigator's and Outline's note-row CONTEXT MENUS render
    /// the remove/release door (§20) — one act, its word the book's.
    static let contextMenuCapabilities: [CapabilityID] = [.removeFromBook]
        // 13i-d U3 (F-U2-3, the adjudication after U2): the book view's OWN
        // structure doors, declared — the note rows' "Move to Chapter ▸" and
        // the chapter rows' "Move Chapter Up / Down" are the Book Panel's acts
        // with a second renderer here (the drags are their twins' class).
        + [.fileNoteInChapter, .moveChapterUpInBook, .moveChapterDownInBook]
    /// 13i-d U3: the masthead's GEAR is the book's own door into its
    /// settings sheet (the sitting record §4's "the book's ⋯ menu" — the
    /// book's one masthead door, P-13id-U3-1), declared at last.
    static let surfaceCapabilities: [CapabilityID] = [.openBookSettings]
        // 13o U3 — the masthead's 🔍 (R-13o-14), the search-within-a-book door.
        + [.searchThisBook]

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
    /// **18d batch 1 (her U-10): what this book's sidebar note box shows.**
    /// A VALUE and a DOOR, published upward — the sidebar never constructs or
    /// holds this book's model, and `RootView` composes the box from what
    /// arrives here (CLAUDE.md's P39 refinement; "features receive view
    /// models, values, and closures"). Only the FOCUSED pane publishes: two
    /// books in a split would otherwise fight over one column.
    /// The publisher's own `readingID` rides every call, INCLUDING the clear
    /// on disappear: SwiftUI mounts the arriving `.id` before it unmounts the
    /// departing one, so an unstamped clear would erase the box the next book
    /// just filled (the `CommandRouter.unregisterDetail` token, one seam over).
    var onNoteBox: ((String, NoteBoxReport?, NoteBoxDoor?) -> Void)?
    /// **13o U3 — where a search passage lands** (the architect's F1:
    /// "landing identical to the Library's"): the note opens IN WRITE AT ITS
    /// BLOCK with the find seed, through the shell's caret-precise road —
    /// composition (`RootView`), never a sibling's model. nil = no landing
    /// road (a test host); the passage then does nothing.
    var onOpenSearchHit: ((_ postID: String, _ blockID: String?, _ find: EditorFindSeed?) -> Void)?
    @State private var model: BookViewModel
    @State private var structure: BookStructureModel
    /// 13i-b U2 — the book's DOOR (the Arrivals face's model). Its own model
    /// rather than more of `BookViewModel` (P-9): the line atop Index and Book
    /// observes and judges arrivals and nothing else.
    @State private var arrivals: BookArrivalsModel
    /// 13i-d U4 — the book's ARCHIVED LINE (her #169(a)(1)): its own model
    /// (P-9), the Arrivals line's sibling on the same three hosts.
    @State private var archived: BookArchivedModel
    /// 13i-c U4 — THE BADGE FAMILY's facts for this book's rows (§6): ONE
    /// page-driven observation over the entries the book holds. Injectable
    /// for `model`'s reason (a pin loads it by hand).
    @State private var ownership: OwnershipFactsModel
    /// 13i-d U3 — the Index's GROUPED-BY state (the sitting record §17(f)):
    /// the masthead's `group ▾` sets it, the Index regroups by it. Its own
    /// model (P-9), remembered per book in a LOCAL store.
    @State private var grouping: BookIndexGroupingModel
    /// 13o U3 — SEARCH WITHIN THIS BOOK (R-13o-14 + the architect's F1): its
    /// own model (P-9) — the masthead's 🔍 and the answer drawn over the
    /// mode's body. Injectable for `model`'s reason.
    @State private var bookSearch: BookSearchModel

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
        arrivals: BookArrivalsModel? = nil,
        archived: BookArchivedModel? = nil,
        ownership: OwnershipFactsModel? = nil,
        grouping: BookIndexGroupingModel? = nil,
        initiallyExpanded: Set<String> = [],
        paneFocused: Bool = true,
        onPaneFocusRequest: (() -> Void)? = nil,
        revealPostID: String? = nil,
        onRevealConsumed: (() -> Void)? = nil,
        onNoteBox: ((String, NoteBoxReport?, NoteBoxDoor?) -> Void)? = nil,
        bookSearch: BookSearchModel? = nil,
        onOpenSearchHit: ((String, String?, EditorFindSeed?) -> Void)? = nil
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        self.paneFocused = paneFocused
        self.onPaneFocusRequest = onPaneFocusRequest
        self.revealPostID = revealPostID
        self.onRevealConsumed = onRevealConsumed
        self.onNoteBox = onNoteBox
        self.onOpenSearchHit = onOpenSearchHit
        let resolved = model ?? BookViewModel(session: session, readingID: readingID)
        for postID in initiallyExpanded { resolved.expand(postID) }
        _model = State(initialValue: resolved)
        // `structure` is injectable for the same reason `model` is (13c 2C):
        // a hosted test drives the view MODE from outside, and hosted
        // `.task` appearance callbacks don't fire under the test host.
        _structure = State(
            initialValue: structure
                ?? BookStructureModel(session: session, readingID: readingID))
        // Injectable for `model`'s reason: a pin drives the door's `adopt`.
        _arrivals = State(
            initialValue: arrivals
                ?? BookArrivalsModel(session: session, readingID: readingID))
        _archived = State(
            initialValue: archived
                ?? BookArchivedModel(session: session, readingID: readingID))
        _ownership = State(initialValue: ownership ?? OwnershipFactsModel())
        _grouping = State(initialValue: grouping ?? BookIndexGroupingModel(readingID: readingID))
        _bookSearch = State(
            initialValue: bookSearch ?? BookSearchModel(session: session, readingID: readingID))
    }

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var newChapterPresented = false
    #if DEBUG
    /// **This book's own name in the DEBUG oracles** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape): minted once per view identity, it
    /// owns this book's focus door, navigator and anchor rows, and its rows
    /// read it by environment. DEBUG-only; the shipping build carries
    /// neither the field nor the mint.
    @State private var oracleOwner = UUID()
    #endif
    @State private var chapterNameField = ""
    @State private var renameChapterTarget: ReadingSection?
    @State private var settingsShown = false
    /// 13i-c U3 (the U3 walk's finding W-1): the settings sheet's "Edit…"
    /// door HANDS the rule editor to the book view and closes itself — the
    /// editor's "also tag the N current members" OFFER is a toast on the
    /// window, and a still-open window-modal settings sheet blocked its
    /// button until the toast's clock ran out (walked: the press never
    /// landed). `pendingRuleEditor` waits for the settings sheet's dismissal;
    /// `ruleEditor` is the book view's own sheet item.
    @State private var pendingRuleEditor: RuleEditorModel?
    @State private var ruleEditor: RuleEditorModel?
    /// **13u3 UNIT A1 — the Outline PANE's width**, which is the only thing
    /// its text surfaces need that the prose column itself cannot tell them:
    /// how much whitespace stands beside the column. Read from the scroll
    /// view (the pane), written on a real change only, on the next turn (a
    /// harmless hop — `NearViewportObserver`'s doc). Zero until the
    /// first pass, where `outlineGutter` answers `.contained` — the shipped
    /// geometry, so the first frame is unchanged.
    @State private var outlinePaneWidth: CGFloat = 0
    // (13i-b U3: the bind sheet's state moved to `structure.bindOffer` — an
    // item that carries its own count, F-U2-3 — because the teaching offer
    // opens it from the structure model too.)

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Outline's prose column (13c 2A): Write's own measure. The contained
    /// text surfaces carry `inlineSurfaceInset` on each side, so the text
    /// itself lands on exactly `EditorTypography.maxColumnWidth`.
    static let proseColumn =
        EditorTypography.maxColumnWidth + 2 * EditorTypography.inlineSurfaceInset

    /// **THE OUTLINE'S PROSE PLACEMENT** (13u3 UNIT A1, her R-13u-9). The
    /// column above is still the CHROME's measure — the masthead, the cards,
    /// the headings all stand on it — but the text surfaces now span the
    /// whole pane and place their prose back on exactly the point the
    /// centred column put it, so the whitespace beside it is theirs to
    /// decorate in.
    ///
    /// The bleed, term by term: the pane is padded 20 and two flexible
    /// margins centre a `min(pane − 40, proseColumn)` column, so the
    /// whitespace on each side is `(pane − column) / 2`, which is
    /// `max(20, (pane − proseColumn) / 2)` — 20 exactly while the column is
    /// squeezed, and the centring leftover plus the padding once it is not.
    private var outlineGutter: ProseGutter {
        guard outlinePaneWidth > 0 else { return .contained }
        return .outline(bleed: max(20, (outlinePaneWidth - BookView.proseColumn) / 2))
    }

    // (Wave 2c's DETAILS GUTTER — `outlineGutterWidth` · `outlineGutterSpacing`
    //  · `outlineFocusedRowWidth` — RETIRED at 18d batch 1, her U-17: *"the
    //  book's right gutter retires ENTIRELY"* once the bar moves into the
    //  sidebar's note box. Her ruling's own reason, U-10: *"then it can stop
    //  taking up room on the right."* The bar went to the box; the unfocused
    //  rows' facts line went with it — state 2 of the box carries the note's
    //  facts now, for the whole book rather than one card at a time. What is
    //  left is the prose at Write's measure, and it is CENTRED in the pane
    //  rather than left-anchored beside dead space (§5.4: *"the prose
    //  recentres on the full width"* — the taste note the correction round
    //  recorded as HELD, now answered).)

    var body: some View {
        // **18d batch 3 (her U-13): the navigator is the shared LEADING side
        // column** — *"the panel with the chapter names should also be
        // draggable to be a bit bigger."* It was an `HStack` of a 190-pt slab,
        // a `Divider` and the mode; it is the same three things, drawn by
        // `SideColumn` so the boundary carries the drag grammar (`SeamGrip`'s
        // 14-pt grip and resize pointer, our own line in every window state) and
        // the width she chooses is remembered. `shown` keeps wave 2c's rule
        // exactly: in INDEX the minimal navigator steps aside — the index
        // column IS the outline pane grown up, and it carries the same
        // masthead so no chrome is lost. The minimal pane stays beside every
        // other mode (her sharpening: "i do like the more minimal outline to
        // go along with the current modes").
        SideColumn(
            tokens: tokens,
            shown: structure.mode != .index,
            widthKey: BookNavigatorLayout.widthKey,
            subjectKey: readingID,
            edge: .leading,
            ideal: BookNavigatorLayout.idealWidth,
            minimum: BookNavigatorLayout.minimumWidth,
            maximum: BookNavigatorLayout.maximumWidth
        ) {
            // The mode's own body. Nothing wraps it: Outline's prose column
            // claims Write's measure by `layoutPriority` INSIDE this body
            // (18d batch 1's closing-suite finding), and a container of ours
            // around it would take that measure back.
            switch structure.mode {
            case .index:
                BookIndexView(
                    session: session, model: model, structure: structure,
                    archived: archived,
                        masthead: { bookMasthead },
                    ownershipBadge: { ownershipBadge($0) },
                    grouping: grouping,
                    hostsQuietReceipt: BookNoteBox.bookHostsQuietReceipt(noteBoxReport?.state),
                    // 13o U3 (F1): in Index the answer covers the PANE — the
                    // column keeps the masthead (and so the field) in view.
                    searchAnswer: bookSearch.isAnswering ? AnyView(searchSheet) : nil,
                    onEditInOutline: { postID in
                        // Editing lives where editing lives: land the note
                        // focused in Outline through the ascent's own door
                        // (the reveal is consumed by Outline's landing).
                        model.focus(postID)
                        model.requestReveal(postID)
                        structure.mode = .outline
                    })
            case .outline:
                // 13i-d U4: the archived line atop the content (zero height
                // when nothing is set aside). 17y B3 (h): the Arrivals line
                // that stood above it here (her 13i-b morning ruling) LEFT
                // the content — the door is the masthead's icon (R-17y-1),
                // visible in every mode, Outline included.
                VStack(spacing: 0) {
                    BookArchivedLine(model: archived, structure: structure)
                    outlineBody
                }
                .overlay { searchAnswerOverlay }
            case .spread:
                // The picker's "Book" (13c 2A's rename, 2B's build): the
                // TWO-UP spread — each page a whole scrollable post, the
                // active one editable in Write or the takes stack (A43/A44).
                SpreadBookView(
                    session: session, model: model, structure: structure,
                    archived: archived)
                    .overlay { searchAnswerOverlay }
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
                        onRevealLanded: { model.consumeReveal() },
                        sizes: model.flowSurfaceSizes,
                        extentsCache: model.flowExtents)
                    .overlay { searchAnswerOverlay }
                case .pages:
                    pagedRead
                        .overlay { searchAnswerOverlay }
                }
            }
        } panel: {
            navigator
        }
        .background(tokens.surface)
        #if DEBUG
        // 18k C4: the navigator's rows register under THIS book's name.
        .environment(\.debugOracleOwner, oracleOwner)
        #endif
        // 13c 2D (A31): the assembly's ORDER is a task input, so changing
        // the way she is looking restarts the observation rather than
        // re-sorting delivered rows (the window is applied by the query —
        // a post-fetch sort would sort the first N of the OLD order).
        // 13i-d U3: the in-book FILTER is the same kind of task input (the
        // Index's filter bar narrows the assembly by it, never a re-filter).
        .task(id: model.observationKey) { await model.start() }
        .task { await structure.start() }
        // 13i-c U4 — the badge facts, keyed on WHICH notes the book shows (a
        // title edit re-delivers entries but changes no id, so no re-read).
        .task(id: ownershipKey) {
            await ownership.observe(
                session: session, postIDs: model.entries.map(\.postID), inBook: readingID)
        }
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
        // 18d batch 1 (her U-10): publish this book's note box. `.onAppear`
        // and `.onChange` together, because the box must be right on the
        // book's OPEN and not only after something moves; `.onDisappear`
        // clears it, so a book leaving the pane takes its box with it.
        .onAppear {
            publishNoteBox()
            // 18o U4 (R-18k-6): the book's leaving road, wired before the
            // first report (the trail starts empty, so the first can leave
            // nothing).
            SavepointOnLeave.wire(book: model, session: session)
            reportNotePlace()
#if DEBUG
            // The round-end Fable pass, MAJOR-1's door: a pin that mounts the
            // REAL shell has no road to this book's focus (the model is this
            // view's `@State`), so the book publishes its one focus act,
            // keyed by its own id (J41: never a singleton) — and, since 18k
            // C4, under THIS view's own name, so a second window on the same
            // book neither overwrites it nor takes it down on leaving.
            BookOutlineGeometry.publishFocusDoor(readingID, owner: oracleOwner) { model.focus($0) }
#endif
        }
        .onChange(of: noteBoxReport) { _, _ in
            publishNoteBox()
            reportNotePlace()
        }
        .onDisappear {
            onNoteBox?(readingID, nil, nil)
            // 18o U4 (R-18k-6): the book leaving its pane is a leaving for the
            // note she was in (the pane shows something else, the split
            // closes, another book takes the pane, the window goes).
            model.leaveBook()
#if DEBUG
            // 18k C4: THIS book's registrations — its door, its navigator,
            // its rows' anchors — and nothing another window's book still
            // answers for (the old `focusDoors[readingID] = nil` cleared the
            // other window's door too; measured, `DebugOracleTwoWindowTests`).
            BookOutlineGeometry.release(owner: oracleOwner)
#endif
        }
        // 13f W20(a): the ascent's request, taken once — whether this book
        // was already open (onChange) or opened by the ascent (onAppear).
        .onChange(of: revealPostID) { _, _ in takeAscentRequest() }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? structure.lastError ?? bookSearch.lastError {
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
        .sheet(isPresented: $settingsShown, onDismiss: {
            // The Edit… handoff: the editor opens once the settings sheet is
            // gone, over the book itself (W-1).
            if let next = pendingRuleEditor {
                pendingRuleEditor = nil
                ruleEditor = next
            }
        }) {
            BookSettingsSheet(structure: structure) { editor in
                pendingRuleEditor = editor
            }
        }
        .sheet(item: $ruleEditor) { editor in
            RuleEditorSheet(model: editor)
        }
        // 13i-b U3 — BIND INTO A BOOK (the door 13c 2D shipped as the
        // conversion offer). One sheet, whichever road opened it: the
        // navigator's "+ new chapter" on a gathering, or the teaching offer a
        // hand-drag earns. The item carries its count (F-U2-3) and the view
        // order she was looking through (K2).
        .sheet(item: Bindable(structure).bindOffer) { offer in
            BindIntoBookSheet(offer: offer) { ownedNotes in
                Task {
                    let bound = await structure.bind(order: offer.order, ownedNotes: ownedNotes)
                    // FROZEN is the book's order now — drop the override
                    // so the menu stops claiming a separate way of
                    // looking (the "Save as This Book's Order" door's own
                    // rule; the content is identical at this instant, so
                    // nothing on screen moves).
                    if bound { model.viewOrder = nil }
                    // P-2: the door performs the act she asked for —
                    // binding was the step on the way, not the point.
                    if bound, offer.followUp == .createChapter {
                        chapterNameField = ""
                        newChapterPresented = true
                    }
                }
            }
        }
    }

    // MARK: - Search within this book (13o U3 — R-13o-14 + the architect's F1)

    /// The book's answer sheet — the passages land through the shell's road.
    private var searchSheet: some View {
        BookSearchSheet(tokens: tokens, model: bookSearch) { postID, blockID, find in
            onOpenSearchHit?(postID, blockID, find)
        }
    }

    /// **Drawn OVER the mode's body while the field holds words** — an
    /// overlay, never a container (the Outline's measure is claimed inside
    /// its own body; an overlay leaves every mode's layout, scroll and live
    /// editor exactly as they were, so clearing the field returns the mode
    /// untouched).
    @ViewBuilder private var searchAnswerOverlay: some View {
        if bookSearch.isAnswering {
            searchSheet
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
            // 13o U3 — SEARCH THIS BOOK (her R-13o-14): the masthead's right,
            // a magnifying glass at rest, the field only when clicked.
            BookSearchDoor(tokens: tokens, model: bookSearch)
            // 17y B3 item (h) — THE ARRIVALS DOOR (R-17y-1): the small icon
            // beside the gear, calm when nothing waits, presence when
            // something does; its popover lists the rows. A BOOK's door
            // only — a gathering holds nothing, so it has none (P-2).
            if BookArrivalsDoor.isDrawn(for: structure.reading) {
                BookArrivalsDoor(model: arrivals, structure: structure)
            }
            Button {
                settingsShown = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help(CapabilityRegistry.capability(.openBookSettings).verb
                + " — collecting, finish, seal, own, length, rename")
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
        // 13i-d U3 — THE GROUPED-BY CONTROL (the sitting record §17(f), ruled:
        // "the Index masthead"): drawn only while the Index is the mode.
        if structure.mode == .index {
            BookIndexGroupingControl(tokens: tokens, grouping: grouping, structure: structure)
        }
        // 13i-c U4 (F-U3-7): the chip reads the book's state from the one
        // pure rule — a SEALED book says sealed (it is finished too, but
        // "the book is done" is the truer word).
        if let reading = structure.reading,
           let chip = BookStateCopy.navigatorChip(
               finished: reading.locked, sealed: reading.sealedAt != nil,
               // 13i-e U2: a book opened from Archived says where it lives.
               archived: reading.archivedAt != nil) {
            Text(tokens.chromeLabel(chip))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
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
        // 13s-b U2: step 9's climb ends on the Index tab.
        .tourAnchor(.bookModeTab(Self.tourMode(mode)), cornerRadius: 5)
    }

    /// 13s-b U2: a book mode in the tour's vocabulary.
    static func tourMode(_ mode: BookStructureModel.ViewMode) -> Tour.BookMode {
        switch mode {
        case .outline: .outline
        case .index: .index
        case .spread: .book
        case .read: .read
        }
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
                    // **18d batch 3 (her U-13): the chapters have room.** The
                    // list was one `VStack(spacing: 2)` of text-height rows, so
                    // a book of chapters read as a solid block of words —
                    // *"the chapters feel too tightly clustered."* Now each
                    // GROUP is its own stack (its chapter row and the notes
                    // under it, touching, because they belong together) and the
                    // groups stand apart by the mockup's own group gap; the
                    // rows themselves carry the sidebar's generous pitch.
                    VStack(alignment: .leading, spacing: BookNavigatorLayout.groupSpacing) {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                          VStack(alignment: .leading, spacing: BookNavigatorLayout.rowSpacing) {
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
                                    // A collapsed one-note chapter row IS
                                    // the note's row (row 8) and takes the
                                    // note row's act by tab — R-cor-17: in
                                    // Read it lands the read page, never a
                                    // jump into Outline.
                                    if let collapsedNote {
                                        BookNavigatorDoor.noteRowClicked(
                                            collapsedNote, model: model, structure: structure)
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
                                    // 13f W11a: the whole ROW is the target,
                                    // not the glyphs — INSIDE the label (the
                                    // correction round's walk, capture 23: a
                                    // click right of the text did nothing,
                                    // because a plain Button acts on its
                                    // LABEL's shape; a frame + contentShape
                                    // outside the button widened the
                                    // hover/menu shape only).
                                    //
                                    // 18d batch 3: at the generous pitch, and
                                    // the taller row is a bigger target too.
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: BookNavigatorLayout.chapterRowHeight,
                                        alignment: .leading)
                                    .contentShape(Rectangle())
                                    .navigatorRowFrame(section.id, chapter: true)
                                }
                                .buttonStyle(.plain)
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
                                    .frame(
                                        minHeight: BookNavigatorLayout.chapterRowHeight,
                                        alignment: .leading)
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
                                    // ONE door, by tab (R-cor-17): in Read
                                    // the row lands the read page (Scroll:
                                    // the flow; Pages: the reader) and never
                                    // leaves Read; the spread page-jumps
                                    // (13b 4F); Outline opens the note.
                                    BookNavigatorDoor.noteRowClicked(
                                        entry, model: model, structure: structure)
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
                                    // The whole row is the target — inside
                                    // the label (see the chapter row). 18d
                                    // batch 3: a note row nests UNDER its
                                    // chapter, so it takes the column's
                                    // compact pitch rather than the chapter's
                                    // generous one — the step between them is
                                    // the hierarchy, drawn.
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: BookNavigatorLayout.noteRowHeight,
                                        alignment: .leading)
                                    .contentShape(Rectangle())
                                    .navigatorRowFrame(entry.postID, chapter: false)
                                }
                                .buttonStyle(.plain)
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
                        }
                        // The end drop zone: drag a chapter past the last
                        // one to land it at the end (R19). 13f W11a: taller,
                        // because with TWO chapters this strip was the ONLY
                        // way to move one down and it was 14 pt of nothing.
                        if structure.chaptersActive, structure.reading?.kind == .book {
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
                if structure.reading?.kind == .book {
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
                    if Queries.hasJournalTrait(structure.reading?.profile),
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
                    } else if structure.reading?.kind == .book,
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
                if structure.reading?.kind == .gathering {
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
                            Task {
                                await structure.openBindOffer(
                                    followUp: .createChapter, order: model.viewOrder)
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .help("Chapters need a book that holds its notes — this "
                            + "offers to bind the gathering into one, keeping every "
                            + "note it shows; "
                            // 13i-d U6 (row 111): the promise only where an
                            // act can reach the rule.
                            + ((structure.reading.map(BindCopy.hearsActs) ?? true)
                                ? "it keeps collecting after."
                                : "after that it collects only when it catches up."))
                    }
                    // Batch 6 legibility: a gathering's derived membership
                    // is DESIGNED (#25a) — but absent-and-silent read as
                    // broken. Say so. (ChromeNotice: navigator =
                    // non-scrolling chrome — the window-min class.)
                    ChromeNotice(
                        tokens: tokens,
                        text: BookViewCopy.gatheringFooter,
                        lines: 6)
                }
                // 13i-d U3 — KnownIssues row 103's book-surface half: the
                // quiet slot at the navigator's FOOT (Outline · Book · Read),
                // the Bookcase hint bar's shape; empty while the sidebar's live
                // note box hosts it (P-13id-U3-6).
                quietReceiptHost
            }
            .padding(12)
            // 18d batch 3: NO fixed width any more — `SideColumn` gives the
            // panel the width she dragged (190 … 360, remembered).
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.room)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                #if DEBUG
                BookOutlineGeometry.recordNavigator(
                    readingID, CGRect(origin: .zero, size: size), owner: oracleOwner)
                #endif
            }
            .coordinateSpace(name: BookNavigatorLayout.space)
        }
    }

    /// The navigator's quiet slot (row 103). Always mounted (18i: a slot that
    /// comes and goes moves doors); faded out while the box is live.
    private var quietReceiptHost: some View {
        let hosting = BookNoteBox.bookHostsQuietReceipt(noteBoxReport?.state)
        return QuietReceiptLine(status: session.status, tokens: tokens)
            .opacity(hosting ? 1 : 0)
            .accessibilityHidden(!hosting)
    }

    // MARK: - The sidebar's note box (18d batch 1 — her U-10)

    /// What the box should show, derived from facts the modes already hold
    /// (`BookNoteBox`, pure). nil ⇒ nothing to show: Read, or an UNFOCUSED
    /// pane — a split's second book must not speak for the one column.
    private var noteBoxReport: NoteBoxReport? {
        guard paneFocused, BookNoteBox.shows(mode: structure.mode) else { return nil }
        let selected = BookNoteBox.selectedPost(
            mode: structure.mode,
            focusedPostID: model.focusedPostID,
            spreadPostIDs: model.spreadEntries.map(\.postID),
            indexPostID: model.indexSelectedPostID)
        let live = BookNoteBox.livePost(
            mode: structure.mode,
            liveFocusedPostID: model.liveFocusedPostID,
            indexLivePostID: model.indexLivePostID)
        return NoteBoxReport(
            readingID: readingID, selected: selected, live: live,
            identity: identity(of: live ?? selected))
    }

    /// The note's identity as THIS book knows it — its title, the chapter it
    /// sits under, and its place in the reading order. `sectionPath` already
    /// carries the chapter's NAME where chapters govern (and the tag path
    /// where they do not), so this walks the entries once and asks the
    /// grouping brain nothing.
    ///
    /// `entries` is the book's WINDOW (`BookViewModel.entryWindow`), so the
    /// total is a floor past it and the line says so (`totalIsAtLeast` — the
    /// round-end Fable pass, NIT-3). The nil branch is a GUARD, not a reachable
    /// state: every door that can make a note this box's subject (the
    /// navigator, Outline's rows, the Index column, the spread) builds its rows
    /// from this same windowed list, so a note past the window cannot be
    /// clicked and cannot arrive here.
    private func identity(of postID: String?) -> NoteBoxIdentity? {
        guard let postID,
              let i = model.entries.firstIndex(where: { $0.postID == postID })
        else { return nil }
        let entry = model.entries[i]
        // 13i-d U3 (the walk's W-3): under the in-book FILTER the entries are
        // the filtered few, so "1 of 2 in this book" would be false — the
        // position is UNKNOWN there (index 0, which the box omits).
        return NoteBoxIdentity(
            postID: postID, title: entry.displayTitle, chapter: entry.sectionPath,
            index: BookNoteBox.position(i + 1, filtered: model.viewFilter != nil),
            total: model.entries.count, totalIsAtLeast: model.truncated)
    }

    private func publishNoteBox() {
        let report = noteBoxReport
        onNoteBox?(
            readingID, report,
            report.map { report in
                NoteBoxDoor(
                    editHere: { editHere(report) },
                    removeFromBook: removeDoor(report))
            })
    }

    /// 13i-c U4 (§20) — the note box's book context: the remove/release door
    /// for the box's note, in the book's word. A gathering has no membership
    /// to remove, so no door (P-2: a door that can never act isn't rendered).
    private func removeDoor(_ report: NoteBoxReport) -> NoteBoxRemoveDoor? {
        guard let book = structure.reading, book.kind == .book,
              let postID = report.selected ?? report.live
        else { return nil }
        let session = session
        return NoteBoxRemoveDoor(verb: RemoveFromBookCopy.verb(owned: book.owned)) {
            Task {
                await RemoveFromBookDoor.remove(session: session, postID: postID, book: book)
            }
        }
    }

    /// **18o U4 (R-18k-6) — the same fact, to the book's leaving road.** The
    /// box's state IS the book's answer to "which note is she in" (`.live` —
    /// her caret's note; `.selected` — the note the book points at; `.empty`
    /// — none: clicked out, Read, an unfocused pane), so moving into another
    /// note reads exactly what the box shows; `BookNoteTrail` holds the rule.
    /// Not folded into `publishNoteBox`: the box is a face, this is a
    /// lifecycle signal, and a clear on the box's side must never read as
    /// her leaving a note.
    private func reportNotePlace() {
        model.notePlaceChanged(noteBoxReport?.state ?? .empty)
    }

    /// **The box's one act**, and it is mode-shaped because "live" is:
    ///
    /// - Outline and the spread mount the ONE full-document editor through
    ///   the book's own focus authority, so the door focuses the note — and
    ///   parks a bare `WriteIntent` at the block she was last in, which is
    ///   the shipped road every "open in Write at this block" door already
    ///   takes (a bare focus lands at the note's FIRST block by design).
    /// - Index upgrades ONE BLOCK to a live pane instead, and its own
    ///   landing door is the book's `requestLanding` — the same
    ///   `LandingTarget` the Read click travels on (row 38).
    private func editHere(_ report: NoteBoxReport) {
        guard let postID = report.selected ?? report.live else { return }
        let remembered = session.commandRouter.currentBlock(for: postID)
        switch structure.mode {
        case .index:
            model.requestLanding(
                LandingTarget(postID: postID, blockID: remembered?.blockID))
        case .outline, .spread:
            if let blockID = remembered?.blockID {
                session.commandRouter.pendingWriteIntent = WriteIntent(
                    postID: postID, blockID: blockID,
                    offsetInBlock: remembered?.utf16Offset ?? 0)
            }
            model.focus(postID)
            model.requestReveal(postID)
        case .read:
            break
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

    // MARK: - Outline's landing (the Act 10 correction round, rows 9/12/14/44/47 — and row 53)
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
    // placement). The fix shape: NO animation, and a convergence on the
    // TARGET'S MEASURED FRAME — land, read back where the anchor actually
    // sits, and hop again while it is not at the top.
    //
    // Row 53 (the orchestrator's walk): the first cut of that convergence
    // hopped at most FOUR times, each hop fired on the very next run-loop
    // turn after a report. With two or more expanded stories in play that
    // is not enough, twice over: (1) the rows around the target are still
    // LOADING while the hops run — an expanded read-cheap story or a live
    // editor realizes at 40/24 pt and grows to ~8,500 pt a beat later
    // (its DB read, then its projection fill) — so the anchor oscillates
    // (traced: 8517 → 470 → −80 → 269 → 200 pt, budget spent, then it
    // drifted to 361) and the page ends inside the WRONG story; (2) a hop
    // issued in the same burst as the report it answers scrolls against a
    // lazy layout whose estimates have not yet absorbed the sizes that
    // just changed, so four immediate hops can land at the same wrong
    // offset four times (traced: 399 → 419 → 416 → 417 → 414 pt). The
    // convergence is therefore STABILITY-driven, never count-driven: every
    // anchor report re-arms a short quiet interval; when the interval
    // passes with the anchor AT the top, the landing is done; when it
    // passes with the anchor away from the top (or with no report at all —
    // the target may have been de-realized by a shift), the landing hops
    // ONCE, against a layout that has had the interval to settle, and
    // waits again. Two fences bound it — a generous hop cap and a time
    // budget (the watchdog) — so a target that will not settle stops
    // moving the page rather than chasing it for the rest of the session.
    // When the click also EXPANDS the target (a collapsed story opened
    // from the navigator), the same loop lands it after its expansion has
    // laid out: the target's own growth is downward and leaves its top
    // where it is, and any neighbour's growth is one more report.

    /// The Outline's own page bookkeeping — NOT render state. Nothing in the
    /// body reads it, so it lives in a reference box that `@State` merely
    /// holds: its mutations never invalidate the view. (The second cut of the
    /// row-53 fix wrote a `@State` slot on every content report; every
    /// such write re-laid the lazy column out, every relayout re-estimated
    /// the unrealized rows and moved the content height, which was one
    /// more report — a loop of the landing's own making, at ~7 Hz.)
    ///
    /// **13u2b UNIT 2:** the LANDING's own bookkeeping left this box for the
    /// one authority (`LandingAuthority`, `Surface/`) — the pending anchor,
    /// the hops, the quiet interval's timer and the seed of where every row
    /// last said it was. What stays here is what belongs to this PAGE rather
    /// than to any landing: which row is at the top (the width change's
    /// anchor) and, in DEBUG, the per-landing height log.
    @MainActor private final class OutlineLandingBox {
        /// **13u2b UNIT 1: the row at the top of the page right now** — the
        /// one thing about the current scroll offset worth keeping across a
        /// WIDTH change, which changes every row's height and so makes the
        /// offset itself meaningless (the trace watched a width change
        /// relocate a settled page mid-story).
        ///
        /// Kept by the reports the rows already send, in two lines: a report
        /// for the row we are holding updates it; any other row closer to the
        /// top takes it; a holder that has scrolled off the top lets go, so
        /// the next row below can take it (without that last clause the
        /// holder's own receding top would out-rank every candidate forever).
        var topRow: (id: String, top: CGFloat)?
        #if DEBUG
        /// Realized row heights, for the trace's "who grew" line.
        var rowHeights: [String: CGFloat] = [:]
        #endif
    }
    @State private var landingBox = OutlineLandingBox()

    /// **THE ONE LANDING AUTHORITY** (13u2b UNIT 2 — `Surface/LandingAuthority.swift`).
    /// The aim/hold/quiet/hop discipline that grew here at row 53 lives there
    /// now, parameterized; this surface keeps the policy's numbers (below,
    /// unchanged) and hands the authority its one act — an unanimated
    /// `scrollTo` — its manifest facts, and every row's geometry report.
    #if DEBUG
    @State private var landing = LandingAuthority(
        policy: .bookOutline,
        storyboard: LandingStoryboard(
            note: { BookOutlineGeometry.trace.append($0) },
            dump: {
                // A landing's story is only this landing's: print from the
                // last line that ENDS in " LAND". (Measured the hard way on
                // UNIT 1's own walk, when every landing printed the whole
                // session's trace.)
                let start = BookOutlineGeometry.trace
                    .lastIndex(where: { $0.hasSuffix(" LAND") }) ?? 0
                return BookOutlineGeometry.trace[start...].joined(separator: " | ")
            }))
    #else
    @State private var landing = LandingAuthority(policy: .bookOutline)
    #endif

    /// The scroll's named space — anchor frames read in it are visible-
    /// relative, so "at the top" is `minY ≈ 0`.
    static let outlineSpace = "book-outline-scroll"

    /// **The Outline's landing policy** — the row-53 numbers, unchanged by
    /// the hoist and now stated in one place with the reasoning for each
    /// (`LandingPolicy.bookOutline`). The five names below are kept as
    /// aliases because the suites and the flow already speak them: the
    /// address moved, not the behaviour.
    static let landingPolicy = LandingPolicy.bookOutline
    static var landingTolerance: CGFloat { landingPolicy.tolerance }
    static var landingSettleInterval: TimeInterval { landingPolicy.settleInterval }
    static var landingMinimumHold: TimeInterval { landingPolicy.minimumHold }
    static var landingMaxWait: TimeInterval { landingPolicy.maxWait }
    static var landingHopBudget: Int { landingPolicy.correctionBudget }
    static var landingTimeBudget: TimeInterval { landingPolicy.timeBudget }
    /// **13u2b UNIT 1: how far beyond the viewport a SMALL row still draws
    /// real content** (`OutlineRunRow`). Smaller than the expanded rows'
    /// 2,500 because a heading or a card is ~50–100 pt, so this is already
    /// a dozen rows of slack above and below — and the hysteresis triples it
    /// before a row lets go again. Bigger would keep a hundred cards' text,
    /// their drop targets and their context menus alive for nothing (P3).
    static let runRowNearMargin: CGFloat = 1200

    /// Put an Outline anchor at the top of the page (no animation — see the
    /// mark above), and watch it settle. **13u2b UNIT 2: the watching is the
    /// authority's**; what stays here is this surface's own act (the scroll)
    /// and what only this surface knows (its manifest's facts about the
    /// column, and the per-landing height log).
    private func landOutline(_ anchorID: String, _ proxy: ScrollViewProxy) {
        #if DEBUG
        landingBox.rowHeights = [:]
        #endif
        landing.land(
            anchorID,
            // Built on every landing rather than only in DEBUG since this
            // unit: the SIGNPOST is what they are for, and it ships. It is
            // arithmetic over the rows in hand — ∝ entries, measured at
            // 1.16 ms for the 400-row window cap and ~0.08 ms at Sherlock's
            // 26 — paid once per click.
            facts: LandingFacts(manifest: outlineHeightManifest, anchor: anchorID)
        ) { id in
            proxy.scrollTo(id, anchor: .top)
        }
    }

    /// A realized anchor reported where it sits. Every report feeds the
    /// DEBUG geometry oracle; a report for the PENDING landing records the
    /// top and re-arms the quiet interval — the decision is the interval's,
    /// never the report's (row 53).
    fileprivate func outlineAnchorMoved(
        _ anchorID: String, top: CGFloat, height: CGFloat, _ proxy: ScrollViewProxy
    ) {
        // 13u2b UNIT 1: who is at the top (the width change's anchor). Where
        // EVERY row is — the landing's seed — is the authority's, below.
        if landingBox.topRow?.id == anchorID {
            landingBox.topRow = top >= -Self.landingTolerance ? (anchorID, top) : nil
        } else if top >= -Self.landingTolerance,
                  top < landingBox.topRow?.top ?? .greatestFiniteMagnitude {
            landingBox.topRow = (anchorID, top)
        }
        #if DEBUG
        BookOutlineGeometry.recordAnchor(anchorID, top: top, height: height, owner: oracleOwner)
        if landing.isPending {
            let known = landingBox.rowHeights[anchorID]
            if known == nil || abs((known ?? 0) - height) > 0.5 {
                BookOutlineGeometry.trace.append("\(anchorID.prefix(13)) h=\(Int(height))")
            }
            landingBox.rowHeights[anchorID] = height
        }
        if landing.anchor == anchorID {
            BookOutlineGeometry.trace.append("\(anchorID) top=\(top) hops=\(landing.corrections)")
        }
        #endif
        landing.noteTop(anchorID, top)
    }

    /// The column's content height changed (a realized row loaded its
    /// text, a card its excerpt, a story its editor): the layout is still
    /// settling, whatever the anchor last said — re-arm the interval.
    fileprivate func outlineContentResized(_ height: CGFloat, _ proxy: ScrollViewProxy) {
        landing.contentChanged(height)
    }

    /// The user scrolled while a landing was pending: she took over — the
    /// landing ends where she put the page, never fighting her.
    fileprivate func outlineUserScrolled() {
        landing.userTookOver()
    }

    /// The navigator's note-row click in Outline (the correction round,
    /// rows 7/23/47): REVEAL the note and land in it at its first block —
    /// through the model's one landing slot, which Outline lands whether the
    /// card is on screen or unrealized far below (`landOutline`). The
    /// chapter row of a one-note chapter that says the note's name (row 8)
    /// takes this same door. Since R-cor-17 the rows go through
    /// `BookNavigatorDoor`, whose Outline act is exactly this.
    private func openFromNavigator(_ entry: Queries.ReadingEntry) {
        BookNavigatorDoor.openTheNote(entry, model: model, structure: structure)
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
        case .outline:
            // 18d batch 1 (her U-10: the box shows *"no note selected"* when
            // *"you've clicked out of something"*): a chapter row is a click
            // OUT of the note — you asked for the chapter, not the note you
            // were in — so the focus is released and the box empties. The
            // expansion is untouched: what you unfolded stays unfolded.
            model.focus(nil)
            model.requestChapterReveal(section.id)
        case .index:
            // Ladder R1-16: nothing in Index consumes a chapter reveal
            // (`BookIndexView.landOrSeed` reads `pendingReveal` only) and the
            // navigator is hidden there — a parked chapter request would
            // land on the NEXT Outline entry as a surprise scroll. No act.
            break
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
        // 13i-d U3 (F-U2-3): the book view's own chapter moves join the
        // registry as the Book Panel's acts (one act, a second renderer),
        // spelled from it ("Move Chapter Up / Down"), and an edge move that
        // could never act is not drawn (P-2 — the panel's own rule).
        if BookPanelBrain.chapterMove(section.id, up: true, sections: structure.sections) != nil {
            Button(CapabilityRegistry.capability(.moveChapterUpInBook).verb) {
                Task { await structure.moveChapter(section.id, up: true) }
            }
        }
        if BookPanelBrain.chapterMove(section.id, up: false, sections: structure.sections) != nil {
            Button(CapabilityRegistry.capability(.moveChapterDownInBook).verb) {
                Task { await structure.moveChapter(section.id, up: false) }
            }
        }
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

    /// Row 53: the column is a plain `VStack` of SEGMENTS — each run of small
    /// rows (headings, cards) in its own `LazyVStack`, each expanded note a
    /// direct child virtualized by the row itself (`BookOutlineRows.Segment`
    /// has the trace and the reason). A lazy container never again holds
    /// both a 100-pt card and a 20,000-pt story, so its estimates stay
    /// honest and the column's geometry is exact wherever it matters.
    private var outlineBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                clickOutMargin
                VStack(alignment: .leading, spacing: BookOutlineHeights.rowSpacing) {
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
                    ForEach(outlineSegments) { segment in
                        switch segment {
                        case .run(let rows):
                            // 13u2b UNIT 1: a plain `VStack`, and each row
                            // virtualizes ITSELF at a height the manifest
                            // knows (`OutlineRunRow` carries the trace). A
                            // lazy container's average estimate for its
                            // unrealized rows is what moved the page out from
                            // under a landing that had already arrived.
                            VStack(alignment: .leading, spacing: BookOutlineHeights.rowSpacing) {
                                ForEach(rows) { row in
                                    switch row {
                                    case .chapter(let section):
                                        OutlineRunRow(
                                            anchorID: row.id, shape: .chapterHeading,
                                            book: self, model: model, proxy: proxy
                                        ) {
                                            chapterHeader(section)
                                        }
                                    case .unfiledHeading:
                                        // UNFILED trails the chapters (ratified,
                                        // QUESTIONS #26(b)) — the grouping brain's
                                        // order, rendered, never re-decided here.
                                        OutlineRunRow(
                                            anchorID: row.id, shape: .unfiledHeading,
                                            book: self, model: model, proxy: proxy
                                        ) {
                                            Text(tokens.chromeLabel("unfiled"))
                                                .font(tokens.heading)
                                                .foregroundStyle(tokens.muted)
                                                .padding(.top, 28)
                                        }
                                    case .tagHeading(let path, _):
                                        // Smart books keep tag-path sectioning
                                        // (`grouping_tag_id`) — same heading voice.
                                        OutlineRunRow(
                                            anchorID: row.id, shape: .tagHeading,
                                            book: self, model: model, proxy: proxy
                                        ) {
                                            Text(path)
                                                .font(tokens.title)
                                                .foregroundStyle(tokens.accent)
                                                .padding(.top, 28)
                                        }
                                    case .note(let entry):
                                        // A note inside a RUN is collapsed by
                                        // construction (`segments` splits at
                                        // every expanded one), so its shape is
                                        // its card's.
                                        OutlineRunRow(
                                            anchorID: row.id,
                                            shape: model.outlineCardShape(entry.postID),
                                            book: self, model: model, proxy: proxy
                                        ) {
                                            postRow(entry)
                                        }
                                    }
                                }
                            }
                        case .expanded(let entry):
                            // An expanded note stands on its own — the row
                            // virtualizes its surface (near the viewport ⇒
                            // real; far ⇒ a placeholder of its remembered
                            // height), so the column's geometry is exact
                            // and only near-viewport text surfaces exist.
                            postRow(entry)
                                .outlineAnchor(segment.id, in: self, proxy)
                        }
                    }
                    if structure.chaptersActive {
                        bodyChapterEndZone  // N21: drag a chapter past the last
                    }
                    // 13o U3 (P-13o-U3-8): the window's line with its road
                    // (the stale "windowing arrives with Phase 12" promise
                    // retired — the road IS the windowing).
                    BookWindowLine(tokens: tokens, model: model)
                    // Sitting 9 batch 6: the add-post door lives IN the
                    // book's flow too, where writing ends — the navigator
                    // rail's twin (R62/R75; discoverability is the point).
                    if structure.reading?.locked != true {
                        if Queries.hasJournalTrait(structure.reading?.profile) {
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
                        } else if structure.reading?.kind == .book {
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
                // the measure Write puts a post's on.
                //
                // **18d batch 1 — it RECENTRES** (§5.4: *"the prose recentres
                // on the full width"*; the taste note the correction round
                // recorded as HELD, now answered by her U-17). It was
                // left-anchored because a 190-pt details gutter stood to its
                // right and the pane's right edge was the gutter's; with the
                // gutter retired, left-anchoring would leave exactly the
                // *"bizarrely open on the right"* she reported at wave 2c.
                .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                // 13u2b UNIT 1: the measure the manifest's heights stand at.
                // A card wraps differently at another width and a story
                // reflows, so everything learned under the old one is dropped
                // when this moves (`BookOutlineHeights.stand`). Written only
                // on a real change (the app's one 1-pt tolerance), and on the
                // next turn (a harmless hop, kept — `NearViewportObserver`'s
                // doc says why it is not the state-during-update class it
                // was once blamed on).
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                    guard abs(width - model.outlineContentWidth) > stableSurfaceWidthTolerance
                    else { return }
                    DispatchQueue.main.async { model.reportOutlineContentWidth(width) }
                }
                // The column claims its measure BEFORE the margins flex —
                // the same device the retired gutter's row used, and the
                // reason it is needed here: `maxWidth` only CAPS, so three
                // flexible children split the pane evenly and the prose
                // landed at 374 pt against Write's 680 (caught by
                // `outlineProseSitsOnWritesOwnMeasure`, which exists for
                // exactly this).
                .padding(.vertical, 22)
                .layoutPriority(1)
                clickOutMargin
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .coordinateSpace(name: Self.outlineSpace)
            // 13u3 UNIT A1: the PANE's width — what the text surfaces need
            // to know to absorb the whitespace beside the column.
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                guard abs(width - outlinePaneWidth) > stableSurfaceWidthTolerance
                else { return }
                DispatchQueue.main.async { outlinePaneWidth = width }
            }
            // Row 53: the landing listens to the WHOLE column, not only its
            // anchor — any content-height change re-arms its quiet
            // interval, and a scroll by the user ends it.
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height
            } action: { _, height in
                outlineContentResized(height, proxy)
            }
            .onScrollPhaseChange { _, phase in
                #if DEBUG
                if landing.isPending { BookOutlineGeometry.trace.append("phase=\(phase)") }
                #endif
                if phase == .interacting { outlineUserScrolled() }
            }
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
            // Ladder R2-12 (the flow's and the Index's own line, brought here at
            // 18l-b U4 — the health review's §1.3 item 4): a pending landing dies
            // WITH the Outline. The authority is `BookView`'s `@State`, so a mode
            // switch mid-landing left it alive with its check armed: it finished
            // `DONE: settled` on the last report a second later (or aimed through
            // the dead proxy until the watchdog filed `gave up`) — a landing, and
            // a signpost line, for a surface already gone. Silent by the
            // authority's own rule. Pinned: `OutlineLandingTeardownTests`.
            .onDisappear { landing.end() }
            .onChange(of: model.pendingReveal) { _, _ in landOutlineReveal(proxy) }
            .onChange(of: model.pendingChapterReveal) { _, _ in landOutlineReveal(proxy) }
            // Row 73 (the correction round, batch G): a reveal that arrived
            // BEFORE the entries (an ascent into a not-yet-mounted book —
            // the Library panel's outline row, the membership chip's link)
            // stays parked, and the entries' arrival lands it.
            .onChange(of: model.entries.map(\.postID)) { _, _ in landOutlineReveal(proxy) }
            .onChange(of: structure.sections.map(\.id)) { _, _ in landOutlineReveal(proxy) }
            // **13u2b UNIT 1 — A WIDTH CHANGE KEEPS HER PLACE.** The trace
            // measured it directly: after a settled landing, a width change
            // alone silently relocated the page mid-story. It has to — every
            // row's height changes with the measure, so a scroll offset
            // kept through it points at different prose. The column re-lands
            // on the row that was at the top, which is the only thing about
            // the old offset worth keeping. (The FIRST report is not a
            // change: `previous == 0` is the column arriving.)
            .onChange(of: model.outlineContentWidth) { previous, _ in
                guard previous > 0, let top = landingBox.topRow?.id else { return }
                landOutline(top, proxy)
            }
            // The VOICE moved: the type the heights were measured in is gone
            // (Study's 16-pt Iowan is not Terminal's 14-pt monospace), so the
            // column re-measures and forgets what it learned. The rows
            // re-render anyway — the tokens are what changed. **What is OWED
            // here and recorded UNBUILT — QUESTIONS #115(b) (13u2b ladder
            // round 1, MINOR 2):** the width road above also RE-LANDS the row
            // that was at the top; this road does not yet, so a voice change
            // mid-book silently relocates the page (the same class, strictly
            // stronger). #115(b) carries the two load-bearing guards the fix
            // must wear (re-land only when `stand` reports movement AND no
            // landing is in flight — `tokens` flips once at mount on a Study
            // store) and why the pin could not be built honestly yet.
            .onChange(of: tokens) { _, _ in model.restandOutlineHeights() }
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

    /// **The page's empty margin, and it is a DOOR** (18d batch 1, her U-10:
    /// the box says *"no note selected"* when *"you've clicked out of
    /// something"*). A click beside the column releases the note's focus —
    /// the live editor comes down and flushes exactly as a collapse brings it
    /// down — and leaves every expansion alone.
    ///
    /// It is a SIBLING of the prose, never an overlay or a background: a tap
    /// layer under a live text surface would fight the caret, which is the
    /// one thing this must not do. Scrolling is untouched (a tap is not a
    /// drag), and nothing droppable lives out here — the rows' drop targets
    /// are the cards themselves.
    private var clickOutMargin: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { model.focus(nil) }
    }

    /// Outline's half of W21's landing — and the chapter landing's only
    /// consumer: put the requested note (or chapter) at the top and consume
    /// the request. Nothing else moves — no focus, no expansion.
    ///
    /// **Row 73 (the Act 10 correction round, batch G — E's trace):** this
    /// used to CONSUME the request BEFORE checking that its note was in
    /// `entries`; at Outline's `onAppear` the book's entries have not
    /// arrived yet, so an ascent INTO a not-yet-mounted book (the Library
    /// panel's outline row, the standing 13f W20 chip link — reproduced
    /// twice in E's walk) consumed and DROPPED its reveal, and the book
    /// opened at the top. Now a request whose note the entries have not
    /// delivered stays PARKED; the entries' arrival (`onChange` above)
    /// lands it. A request for a note the DELIVERED entries do not hold is
    /// foreign and is dropped as before — a stale request must never land
    /// on a later navigation.
    private func landOutlineReveal(_ proxy: ScrollViewProxy) {
        if let sectionID = model.pendingChapterReveal {
            if structure.sections.contains(where: { $0.id == sectionID }) {
                model.consumeChapterReveal()
                landOutline(BookOutlineRows.Row.chapterAnchor(sectionID), proxy)
            } else if !structure.sections.isEmpty {
                model.consumeChapterReveal()
            }
        }
        guard let postID = model.pendingReveal else { return }
        guard model.entries.contains(where: { $0.postID == postID }) else {
            if !model.entries.isEmpty { model.consumeReveal() }
            return
        }
        model.consumeReveal()
        landOutline(BookOutlineRows.Row.noteAnchor(postID), proxy)
    }

    /// Row 82 (the correction round, batch G): the paged Read's paragraph
    /// click is the SAME door as the flow's — the editable index at that
    /// block (its own property: the body's expression outgrew the
    /// type-checker with the closure inline).
    private var pagedRead: some View {
        PagedReadView(
            session: session, model: model, structure: structure,
            onWake: { postID, blockID in
                model.requestLanding(LandingTarget(postID: postID, blockID: blockID))
                structure.mode = .index
            })
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
        if structure.chaptersActive, structure.reading?.kind == .book {
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

    /// Row 53: the rows split at every expanded note (`BookOutlineRows.Segment`).
    private var outlineSegments: [BookOutlineRows.Segment] {
        BookOutlineRows.segments(rows: outlineRows, isExpanded: model.isExpanded)
    }

    /// **13u2b UNIT 1: the whole column, as heights and offsets.** Built on
    /// demand — it is arithmetic over the rows in hand (∝ entries, no read,
    /// no layout), and building it fresh is cheaper than keeping it correct.
    /// The rows themselves ask the same brain one row at a time
    /// (`BookViewModel.outlineRowHeight`), so the two can never disagree.
    ///
    /// Offsets are from the FIRST ROW, not from the top of the scroll's
    /// content: the column's own lead (the book's title block and the
    /// vertical padding) is voice- and width-dependent, and nothing here
    /// consumes an absolute offset — the landing addresses rows by anchor,
    /// which is exact now that no row's height is estimated. UNIT 2's flow is
    /// the first consumer that may want the absolute number, and measuring
    /// the lead is its own small piece of work when it does.
    var outlineHeightManifest: BookHeightManifest {
        model.outlineHeightManifest(rows: outlineRows)
    }

    /// Batch 12: kind + extent at a glance under the title.
    /// 13i-c U4: the badge facts' task key — the ids the book shows.
    private var ownershipKey: [String] { model.entries.map(\.postID) }

    /// **The badge a row wears** (§6's direction): inside a BOOK, the shared
    /// mark; a GATHERING's view is outside every book, so its rows wear the
    /// owned-by mark. The setting silences the set (P-13ic-10).
    func ownershipBadge(_ postID: String) -> OwnershipBadgeFace.Badge? {
        ownership.badge(
            for: postID,
            placement: structure.reading?.kind == .gathering ? .outside : .inBook,
            badgesOn: themeStore?.settings.ownershipBadges ?? true)
    }

    private var bookMetaLine: String {
        BookViewCopy.metaLine(
            gathering: structure.reading?.kind == .gathering,
            chapters: structure.sections.count, notes: model.entries.count,
            archived: archived.door.count)
    }

    /// One post in the outline (13c 2A — extracted from four inline
    /// builders so the row has an INIT the virtualization counter can ride,
    /// the `ReadingFlowView` precedent; P-9's split rides along).
    private func postRow(_ entry: Queries.ReadingEntry) -> some View {
        OutlinePostRow(
            session: session, model: model, structure: structure,
            entry: entry, tokens: tokens, gutter: outlineGutter,
            badge: ownershipBadge(entry.postID))
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

// (Ladder R1-10's `BookOutlineFactsReads` counter RETIRED at 13u2 UNIT A2
//  with the thing it counted: the Outline's rows perform no whole-note facts
//  read at all now — the book primes the cards' openings in one bounded read
//  (`BookViewModel`), and `BookCardPreviewReads` beside it counts THOSE. A
//  counter whose incrementer has been deleted is a pin that cannot fail, so
//  it goes rather than standing as reassurance.)

/// The correction round's landing oracle: where every REALIZED Outline
/// anchor (`page-<postID>` · `chapter-<sectionID>`) sits, in the scroll's
/// visible space — `0` is the top of the page. Fed by the same geometry
/// reports the landing's convergence reads, so a pin asserts the landing
/// the user sees, not a scroll request that was merely issued.
@MainActor
enum BookOutlineGeometry {
    // **18k UNIT C4 — EVERY REGISTRATION BELOW NAMES ITS OWNER** (the rule
    // and its reasons: `Core/Views/DebugOracleOwnership.swift`). The owner is
    // the mounted `BookView`'s `oracleOwner` — its rows read it by
    // environment — and a `BookView` leaving releases ONLY its own. Before,
    // the same book in two windows shared every key: the focus door was nil
    // after EITHER window's teardown (its `onDisappear` cleared the book's
    // key), and the navigator answered with the closed window's rectangle —
    // measured red, `DebugOracleTwoWindowTests`. The read names and shapes
    // are unchanged; a pin that used to ASSIGN a reset calls the named door.
    private static var anchorTopStore = OwnedRegistrations<String, CGFloat>()
    private static var rowHeightStore = OwnedRegistrations<String, CGFloat>()
    private static var navigatorFrameStore = OwnedRegistrations<String, CGRect>()
    private static var navigatorChapterRowStore = OwnedRegistrations<String, CGRect>()
    private static var navigatorNoteRowStore = OwnedRegistrations<String, CGRect>()
    private static var focusDoorStore = OwnedRegistrations<String, @MainActor (String?) -> Void>()

    static var anchorTops: [String: CGFloat] { anchorTopStore.current }
    /// **13u2 UNIT A2: each anchor row's CURRENT height**, recorded on the
    /// same report as its top and keyed the same way (the anchor id carries
    /// the post/section id, so this is subject-keyed like `anchorTops` beside
    /// it — never "the row"). What item 18's pin reads: a card whose height
    /// MOVES when its preview read returns is the drift TRACE 2 measured on
    /// the real Sherlock book. The landing's own `landingBox.rowHeights`
    /// below is untouched — that one is a per-landing change LOG, and this is
    /// the current fact.
    static var rowHeights: [String: CGFloat] { rowHeightStore.current }
    /// The pending landing's report sequence (id · top · hop) — what a pin
    /// prints when a landing does not converge. An append-only LOG, so it is
    /// not a registration (18k C4: no owner's teardown can erase another's
    /// lines — SAFE-AS-IS (A)); what C4 adds is the BOUND, the 13u2 UNIT E
    /// `TakeCardGeometry` rule: it used to grow for a DEBUG process's whole
    /// life, pruned only by pins.
    static var trace: [String] = [] {
        didSet { DebugOracleLog.bound(&trace) }
    }
    /// **18d batch 3 (her U-13): what the NAVIGATOR actually drew** — the
    /// column's own rect, and each chapter/note row's rect in the
    /// navigator's own named space. "The chapters have room" and "the
    /// column is the width she dragged" are claims about rectangles, so
    /// the pins read rectangles rather than the constants below.
    /// Keyed by the BOOK's id, and the rows by their own: Swift Testing runs
    /// SUITES in parallel, so a second book mounted in another suite lands in
    /// the same statics — a pin that reads "the navigator" rather than "MY
    /// navigator" is flaky by construction (measured: 4 chapter rows in a
    /// two-chapter book, and a frame from someone else's mount).
    static var navigatorFrames: [String: CGRect] { navigatorFrameStore.current }
    static var navigatorChapterRows: [String: CGRect] { navigatorChapterRowStore.current }
    static var navigatorNoteRows: [String: CGRect] { navigatorNoteRowStore.current }
    /// The round-end Fable pass, MAJOR-1: each mounted book's ONE focus act
    /// (`BookViewModel.focus`), published by the view whose `@State` holds
    /// the model — the only way a pin over the real shell can make a note
    /// live in the Outline. Keyed by the book's id and OWNED by the view
    /// that published it (18k C4): the most recently mounted book answers,
    /// and a book leaving takes only its own door.
    static var focusDoors: [String: @MainActor (String?) -> Void] { focusDoorStore.current }

    // MARK: - The writes (each names its owner)

    static func recordAnchor(_ anchorID: String, top: CGFloat, height: CGFloat, owner: UUID) {
        anchorTopStore.publish(top, for: anchorID, owner: owner)
        rowHeightStore.publish(height, for: anchorID, owner: owner)
    }

    static func recordNavigator(_ readingID: String, _ frame: CGRect, owner: UUID) {
        navigatorFrameStore.publish(frame, for: readingID, owner: owner)
    }

    static func recordNavigatorRow(_ id: String, chapter: Bool, _ frame: CGRect, owner: UUID) {
        if chapter {
            navigatorChapterRowStore.publish(frame, for: id, owner: owner)
        } else {
            navigatorNoteRowStore.publish(frame, for: id, owner: owner)
        }
    }

    static func publishFocusDoor(
        _ readingID: String, owner: UUID, _ door: @escaping @MainActor (String?) -> Void
    ) {
        focusDoorStore.publish(door, for: readingID, owner: owner)
    }

    /// A `BookView` leaving: its own registrations, every one, and nothing
    /// another window's book still answers for.
    static func release(owner: UUID) {
        anchorTopStore.release(owner: owner)
        rowHeightStore.release(owner: owner)
        navigatorFrameStore.release(owner: owner)
        navigatorChapterRowStore.release(owner: owner)
        navigatorNoteRowStore.release(owner: owner)
        focusDoorStore.release(owner: owner)
    }

    // MARK: - A pin's doors (unconditional — a pin owns nothing)

    static func resetNavigator() {
        navigatorFrameStore.forgetAll()
        navigatorChapterRowStore.forgetAll()
        navigatorNoteRowStore.forgetAll()
    }

    static func forgetAnchorTops() { anchorTopStore.forgetAll() }

    static func forgetRowHeights() { rowHeightStore.forgetAll() }

    static func forgetFocusDoor(_ readingID: String) { focusDoorStore.forget(readingID) }
}
#endif

/// **THE NAVIGATOR'S ROOM** (18d batch 3, her U-13: *"the chapters feel too
/// tightly clustered and the panel with the chapter names should also be
/// draggable to be a bit bigger"*).
///
/// The pitch numbers take the SIDEBAR's as their reference — the mockup's
/// `.sb-row` grammar, 5 px of padding around a 13 pt line, which
/// `SidebarLayout.generousRowHeight`/`compactRowHeight` round to 30 and 24 —
/// and the group gap is the mockup's own `.sb-group { margin-bottom: 20px }`.
/// They are stated HERE rather than read from `SidebarLayout` deliberately:
/// the sidebar's numbers are a pitch that COMPRESSES with its column's
/// height, and this column never compresses, so the two are the same value
/// for the same reason and not one truth two places read (a change to the
/// sidebar's compression must not silently retune the book's navigator).
nonisolated enum BookNavigatorLayout {
    /// One posture for every book, like `readModeOutlineShown` — the width
    /// she settles on is how she wants to read books, not a fact about one.
    static let widthKey = "bookNavigatorWidth"
    static let space = "book-navigator"
    /// Where it starts: exactly the slab's shipped width, so nothing moves
    /// until she drags it.
    static let idealWidth: CGFloat = 190
    static let minimumWidth: CGFloat = 190
    /// *"a bit bigger"* — a chapter list dragged half the window wide is not
    /// a chapter list; the note's panels keep the brain's own 640.
    static let maximumWidth: CGFloat = 360
    static let chapterRowHeight: CGFloat = 30
    static let noteRowHeight: CGFloat = 24
    /// Inside a group the rows touch — a chapter and its notes belong
    /// together, and their own pitches carry the air.
    static let rowSpacing: CGFloat = 1
    /// Between groups: the mockup's group gap.
    static let groupSpacing: CGFloat = 20
}

private extension View {
    /// A navigator row's rect, for the DEBUG oracle only (the
    /// `outlineAnchor` pattern: the reporter lives at the row, and the app
    /// build carries nothing).
    @ViewBuilder func navigatorRowFrame(_ id: String, chapter: Bool) -> some View {
        #if DEBUG
        self.modifier(NavigatorRowProbe(id: id, chapter: chapter))
        #else
        self
        #endif
    }
}

#if DEBUG
/// 18k C4: a modifier rather than a bare `onGeometryChange`, because it must
/// READ its owning book from the environment (`TakeCardGeometryProbe`'s own
/// reason) — the row's rectangle is that book's, and goes when it does.
private struct NavigatorRowProbe: ViewModifier {
    let id: String
    let chapter: Bool
    @Environment(\.debugOracleOwner) private var owner

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(BookNavigatorLayout.space))
        } action: { frame in
            BookOutlineGeometry.recordNavigatorRow(
                id, chapter: chapter, frame, owner: owner ?? DebugOracleOwner.unowned)
        }
    }
}
#endif

/// What an Outline anchor reports: where its top sits in the scroll's
/// visible space, and how tall the row is (the landing converges on the
/// first; the DEBUG trace names the growing row by the second).
nonisolated private struct OutlineAnchorGeometry: Equatable, Sendable {
    var top: CGFloat
    var height: CGFloat
}

private extension View {
    /// An Outline row's landing anchor, at the LAZY STACK's level: the id
    /// the scroll reader lands on, and the geometry report the landing
    /// converges on (`BookView.outlineAnchorMoved`). At the row, not inside
    /// it — an unrealized lazy row's inner views do not exist yet, so an id
    /// on the card or the header was invisible to `scrollTo` until the row
    /// happened to be on screen (row 47's "the page did not move").
    ///
    /// **13u2b UNIT 1:** this is now the EXPANDED rows' anchor only — a small
    /// row carries the same report inside `OutlineRunRow`, where one
    /// observation serves the landing, the height learning and the near/far
    /// decision at once.
    func outlineAnchor(_ id: String, in book: BookView, _ proxy: ScrollViewProxy) -> some View {
        self
            .id(id)
            .onGeometryChange(for: OutlineAnchorGeometry.self) { geometry in
                let frame = geometry.frame(in: .named(BookView.outlineSpace))
                return OutlineAnchorGeometry(top: frame.minY, height: frame.height)
            } action: { geometry in
                book.outlineAnchorMoved(id, top: geometry.top, height: geometry.height, proxy)
            }
    }
}

/// **One small row of Outline's column (13u2b UNIT 1): real near the
/// viewport, a manifest-height placeholder far from it — and its landing
/// anchor either way.**
///
/// This is the row-53 virtualization the expanded notes have shipped since
/// the Act 10 correction round, extended downward to the headings and cards,
/// and it is here for a measured reason rather than for symmetry. The runs
/// used to be `LazyVStack`s, and a lazy container answers "how tall is a row
/// I have not realized" with the AVERAGE of the ones it has — so arriving at
/// a landing target de-realized the rows above it, the column shrank ~70 pt
/// above the target, and the page slid off the thing it had just landed on
/// (the plan's UNIT 1 RECORD has the trace and the probe: thirteen hops, four
/// seconds, and `top = 0` is not a fixpoint of such a column). A height the
/// column ASSERTS cannot do that.
///
/// **What it is NOT:** it is not the closed "one row scale per lazy run"
/// road. The expanded notes — and therefore the ONE live editor — keep their
/// exact identity and position as direct children of the column (P-3's
/// fence); only runs of headings and collapsed cards change form, and no
/// liveness mechanism is touched. Anchors are kept on every row, realized or
/// not, so `scrollTo(id:)` is unchanged and no landing pin's mechanism moves.
private struct OutlineRunRow<Content: View>: View {
    let anchorID: String
    let shape: BookOutlineHeights.Shape
    let book: BookView
    let model: BookViewModel
    let proxy: ScrollViewProxy
    @ViewBuilder let content: () -> Content
    /// Starts false so a far row never draws real content for one frame; the
    /// row's own first geometry report decides (`OutlinePostRow`'s rule).
    @State private var near = false

    var body: some View {
        Group {
            if near {
                content()
            } else {
                Color.clear.frame(height: model.outlineRowHeight(anchorID, shape: shape))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(anchorID)
        // ONE geometry report, three readers — the landing converges on the
        // top, the manifest learns the height, and the row decides near or
        // far. The band's rule is `NearBand`'s, shared with
        // `NearViewportObserver` rather than copied: at the window's 300-note
        // cap a second observer per row would be 400 more of them, and P-8 is
        // this phase's spine.
        .onGeometryChange(for: OutlineAnchorGeometry.self) { geometry in
            let frame = geometry.frame(in: .named(BookView.outlineSpace))
            return OutlineAnchorGeometry(top: frame.minY, height: frame.height)
        } action: { geometry in
            if near { model.learnOutlineRowHeight(anchorID, shape: shape, height: geometry.height) }
            book.outlineAnchorMoved(
                anchorID, top: geometry.top, height: geometry.height, proxy)
            let distance = NearBand.distance(
                top: geometry.top, height: geometry.height, margin: BookView.runRowNearMargin)
            guard let becomesNear = NearBand.decide(
                distance: distance, near: near, margin: BookView.runRowNearMargin)
            else { return }
            // On the next turn, as `NearViewportObserver` does (a harmless
            // hop, kept; its doc corrects the reason once given for it).
            DispatchQueue.main.async { near = becomesNear }
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
    /// 13u3 UNIT A1: the Outline's prose placement, handed down from the
    /// pane that knows its own width (`BookView.outlineGutter`).
    let gutter: ProseGutter
    /// 13i-c U4 (§6): the badge this row wears, or nil — decided by the book
    /// (`BookView.ownershipBadge`), drawn beside the title.
    let badge: OwnershipBadgeFace.Badge?

    init(
        session: AppSession, model: BookViewModel, structure: BookStructureModel,
        entry: Queries.ReadingEntry, tokens: VoiceTokens, gutter: ProseGutter,
        badge: OwnershipBadgeFace.Badge? = nil
    ) {
        self.session = session
        self.model = model
        self.structure = structure
        self.entry = entry
        self.tokens = tokens
        self.gutter = gutter
        self.badge = badge
    }

    /// Row 53: is this row near the viewport? An EXPANDED row far from it
    /// renders a placeholder of its remembered height instead of its text
    /// surface — the book's own virtualization of the heavy unit, now that
    /// expanded rows stand outside the lazy containers. Starts false so a
    /// far row never mounts a surface for one frame; the row's first
    /// geometry report decides.
    @State private var nearViewport = false
    /// How far beyond the viewport (in points, above and below) a row still
    /// counts as near — generous, so a surface is realized before it
    /// scrolls into view and released well after it leaves.
    private static let nearMargin: CGFloat = 2500
    /// The placeholder height for an expanded note the column has never
    /// measured (expanded far away, by "expand all"); it corrects when the
    /// row nears the viewport.
    private static let unmeasuredSurfaceHeight: CGFloat = 800

    /// 13f W11: this row's drop indicator (a chapter or a post is hovering).
    @State private var dropTargeted = false

    /// VX-75: whether the live editor mounted in this row has drawn its note
    /// at its real height. Until it has, the read surface stays mounted under
    /// it and the editor stays invisible, so a click into editing never shows
    /// an empty note while the editor's first projection is on its way.
    @State private var liveShowing = false

    /// VX-82 — the INVERSE swap's flag: whether the CURRENTLY mounted read
    /// surface has drawn the note at its real height (`ReadPostView.
    /// onShowing`; reset when that surface leaves). On leaving edit mode the
    /// fresh read surface mounts empty and fills asynchronously, so the
    /// outgoing editor HOLDS — mounted, visible, inert — exactly until this
    /// flips, the mirror of what `liveShowing` does for the forward swap.
    /// Every condition reads row `@State` already correct in the body
    /// evaluation that acts on it, so no `onChange` ordering is involved.
    @State private var readShowing = false

    /// The card's preview — **the BOOK's, in hand before this row's first
    /// frame** (13u2 UNIT A2, item 18). It used to be this row's own `@State`,
    /// filled by a `.task` that rendered the WHOLE note; the card therefore
    /// grew from 46 pt to 103 pt whenever that read happened to return, which
    /// on the real Sherlock book meant 854 pt of column drift AFTER a landing
    /// had already arrived — her *"stutter … once I've already arrived"* and
    /// the second, separate hop that followed it. The model primes every
    /// entry's opening words in one bounded read as the entries arrive
    /// (`BookViewModel.adopt`), so there is no moment at which this row knows
    /// less than it will know.
    private var excerpt: String { model.cardPreview(entry.postID) }

    var body: some View {
        Group {
            if model.isExpanded(entry.postID) {
                // ONE expanded shape for both states (VX-75). The focused
                // note's live editor and the read-cheap surface used to be two
                // separate branches, so focusing dismantled the read surface
                // at once while the editor was still born empty — every frame
                // until its first projection showed a blank row (her "whole
                // screen text disappears"). In one ZStack the read surface
                // keeps its identity across the focus flip and is released
                // only once the editor has drawn the note at its real height.
                // P-3 holds: the read surface is never live, and there is
                // still exactly one live editor.
                let isLive = model.liveFocusedPostID == entry.postID
                VStack(alignment: .leading, spacing: 6) {
                    // The HEADER is the handle, not the prose: an expanded
                    // post shows a text surface, and a drag over it would
                    // fight selection. 18d batch 1 (U-10/U-17): the focused
                    // note's editor renders NO bar here — its doors are in the
                    // sidebar's note box — so the row is the prose at Write's
                    // measure and nothing else.
                    postHeader
                        .bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                        .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                    // VX-91: `nearViewport` alone left the clicked far
                    // story's row a placeholder until the scroll ARRIVED —
                    // the title-alone-over-blank beat. The row she is on
                    // her way to pre-mounts (`outlineRowPreMounts`: focused
                    // or the reveal's target, with a width-matched memory
                    // so the reservation holds the column's geometry).
                    if nearViewport || model.outlineRowPreMounts(entry.postID) {
                        ZStack(alignment: .topLeading) {
                            if !(isLive && liveShowing) {
                                StableSurface(
                                    known: model.rememberedSurfaceSize(entry.postID),
                                    followsShrinks: false,
                                    settled: { model.persistSurfaceSize(entry.postID) },
                                    remember: { model.rememberSurfaceSize(entry.postID, $0) }
                                ) {
                                    ReadPostView(
                                        session: session, postID: entry.postID,
                                        gutter: gutter,
                                        onFocusRequest: { offset in
                                            model.focus(entry.postID, caret: offset)
                                        },
                                        onBadgeTap: { blockID in
                                            // Interpretation 1 (PROVISIONAL): focus
                                            // FIRST, then the fan panel opens on the
                                            // one live surface.
                                            model.focus(entry.postID, fanBlock: blockID)
                                        },
                                        onShowing: { readShowing = true })
                                }
                                .id("read-\(entry.postID)")
                                .onAppear { materialized() }
                                .onDisappear { readShowing = false }
                            }
                            // VX-82: `isLive` alone unmounted the editor the
                            // instant focus left, while the fresh read surface
                            // above was still empty — a reserved-height blank
                            // beat ∝ the story (her "that pause is noticable").
                            // The editor now lingers — visible, no hit testing,
                            // never first responder — until that surface has
                            // drawn the note (`readShowing`), the exact mirror
                            // of the forward swap's hold. A re-click during the
                            // beat finds it still mounted: instant return.
                            if isLive || (liveShowing && !readShowing) {
                                StableSurface(
                                    known: model.rememberedSurfaceSize(entry.postID),
                                    followsShrinks: true,
                                    // 18d batch 4 (U-12): the settle is the ONE
                                    // occasion this note's remembered length
                                    // reaches the disk — the memory itself takes
                                    // every geometry report, and a live editor
                                    // reports on every keystroke.
                                    settled: { model.persistSurfaceSize(entry.postID) },
                                    remember: { model.rememberSurfaceSize(entry.postID, $0) }
                                ) {
                                    EditorView(
                                        session: session, postID: entry.postID, inline: true,
                                        caretSeed: model.caretSeed, fanSeed: model.fanSeed,
                                        barPlacement: .inSidebarBox,
                                        gutter: gutter,
                                        onLiveShowing: { liveShowing = true })
                                }
                                .id(entry.postID)
                                .opacity(liveShowing ? 1 : 0)
                                // VX-82: no hit testing while lingering — a
                                // click during the beat falls through to the
                                // read surface's own focus-request road.
                                .allowsHitTesting(isLive && liveShowing)
                                .onAppear { materialized() }
                                .onDisappear { liveShowing = false }
                            }
                        }
                    } else {
                        surfacePlaceholder
                    }
                }
                .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                .padding(.bottom, 26)
                .modifier(NearViewportObserver(near: $nearViewport, margin: Self.nearMargin, space: BookView.outlineSpace))
            } else {
                collapsedPostCard
                    .bookDropRow(self, targeted: $dropTargeted, tokens: tokens)
                    .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                    .padding(.bottom, 2)
                    .onAppear { materialized() }
            }
        }
        // (13u2 UNIT A2 — THE PER-ROW READ IS GONE. What stood here was a
        //  `.task` that rendered the WHOLE note to get the card's forty
        //  words, once per realized row, keyed so that a row collapsing later
        //  re-read. Ladder R1-10 had already narrowed it to collapsed rows
        //  because "expand all" on Sherlock otherwise read twelve full
        //  stories for nothing rendered — the narrowing was right and the
        //  read was still the wrong shape twice over: it cost ∝ the note's
        //  text (0.24 → 16 ms as a note grows; the bounded read is a flat
        //  0.16), and it delivered the card's HEIGHT late, which is item 18.
        //  The book now primes every entry's opening in ONE bounded read as
        //  the entries arrive, and the freshness the task's id used to buy —
        //  a re-read when a note closes — rides `BookViewModel.collapse`.)
    }

    /// The far expanded row's stand-in: exactly the surface's remembered
    /// height (so the column's geometry is what it will be when the row
    /// nears), or the unmeasured fallback.
    /// **What this reads, and what it deliberately does NOT check (18d batch
    /// 4).** The memory is now persisted, so this — the FAR row's stand-in,
    /// and therefore the height an expanded note holds in the first frames
    /// after a relaunch — can stand on a record written at another window
    /// width. It does so on purpose. The record's TYPOGRAPHY is checked for
    /// it (`SurfaceSizeMemory.size` refuses a record stamped under another
    /// voice, so a Study launch falls back to the unmeasured height), but its
    /// WIDTH is not, because a placeholder is a GUESS and a note's height
    /// measured at 696 pt is a far better guess for the same note at 500 pt
    /// than `unmeasuredSurfaceHeight` — off by the width ratio rather than by
    /// twenty-five times. The place a wrong width must never be believed is
    /// the RESERVATION, and `StableSurface.reserved` refuses it there
    /// (`stableSurfaceWidthTolerance`, ladder R1-1 — pinned twice, once on a
    /// persisted record). The reading flow makes the same split for the same
    /// reason through one brain (`FlowHeightEstimate.honestHeight`, R2-1 — the
    /// rule its story row calls, and since 18l-b U4 the manifest's own
    /// precedence over `FlowHeightEstimate.storyInput`), where it has an
    /// estimate to fall back to and the Outline has none.
    /// **13u2b UNIT 1 — and the ESTIMATE arm arrived here.** The order is
    /// now remembered-at-this-width → the lengths estimate → a remembered
    /// size from another width → the unmeasured constant
    /// (`BookViewModel.outlineSurfaceHeight` states each step's reason). The
    /// paragraph above still holds for the third step, which is the one it
    /// was written about; what changed is that a width her memories were NOT
    /// taken at now falls to an estimate built from this note's own block
    /// lengths instead of straight to 800 pt — the case the architectural
    /// trace measured at 20,848 pt of first-aim error. 18d's per-width
    /// refusal in `StableSurface.reserved` is untouched: covering that case
    /// is exactly what this arm is for.
    private var surfacePlaceholder: some View {
        Color.clear.frame(height: model.outlineSurfaceHeight(entry.postID))
    }

    /// 13c 2A's virtualization count (`BookOutlineMaterialization`): a row
    /// counts when it renders REAL content — a card, or an expanded note's
    /// text surface — never a far row's placeholder (row 53 moved the count
    /// from the row's init: expanded rows now stand outside the lazy
    /// containers, so the init runs for every one of them; the P3 fact the
    /// pin guards is how many SURFACES exist).
    private func materialized() {
        #if DEBUG
        BookOutlineMaterialization.count += 1
        #endif
    }

    // (The gutter's details view RETIRED at 18d batch 1 with the gutter
    //  itself — U-17. The takes fact it carried is a fact about a NOTE, and
    //  the note box's second state says it for whichever note the book is
    //  pointing at, beside its words, its blocks and its two stamps. One
    //  place, more facts, and no rail reserved down the right of every card.)

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
            if let badge {
                OwnershipBadgeView(tokens: tokens, badge: badge, postID: entry.postID)
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
                    // 13i-c U4 (§6): the badge family, beside the title.
                    if let badge {
                        OwnershipBadgeView(tokens: tokens, badge: badge, postID: entry.postID)
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
                // Wave 2c (W8-5): the excerpt stays on the card, and the
                // note's facts are not under it. They were in the details
                // gutter to the right until 18d batch 1 retired it (U-17);
                // the sidebar's note box carries them now, for whichever
                // note the book is pointing at.
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
        // 13i-c U4 walk (W-2): the card's hover carries its badge's sentence.
        .help(OwnershipBadgeCopy.rowHelp(
            "Click to open this note in the full editor; ▸ unfolds it here", badge: badge))
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
        // 13s-b U2: step 3 points at the first story's card (the card's body
        // IS the door into the note's own page).
        .tourAnchor(.outlineCard(entry.postID), cornerRadius: 10)
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
    if let book = structure.reading, book.kind == .book {
        // 13i-d U3 (F-U2-3): the Book Panel's act, spelled from the registry
        // — "Move to Chapter ▸" with "No Chapter" (was "Chapter ▸ … None");
        // 17y (i), R-17y-4: that destination now says the headers' "unfiled".
        Menu(CapabilityRegistry.capability(.fileNoteInChapter).verb) {
            ForEach(structure.sections, id: \.id) { section in
                Button(section.name) {
                    Task { await structure.assign(postID, to: section.id) }
                }
            }
            Divider()
            Button(BookPanelCopy.noChapter) {
                Task { await structure.assign(postID, to: nil) }
            }
        }
        // 13i-c U4 (the sitting record §20): the remove/release door — one
        // act, its word the book's ("Release from This Book" on an owned
        // book: the note goes back to the Pool, whole). A gathering holds no
        // membership, so it renders none here (its honest door is the chip's).
        Divider()
        Button(RemoveFromBookCopy.verb(owned: book.owned)) {
            Task {
                await RemoveFromBookDoor.remove(
                    session: structure.session, postID: postID, book: book)
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

// (PostCardExcerpt was absorbed into OutlinePostRow at wave 2c; since 18d
// batch 1 retired the gutter (U-17) the one fetch serves the card's excerpt
// alone, at the same per-realized-row cadence.)

// (13i-c U3: `BookSettingsSheet` — the navigator's settings leg, R43 — moved
// to its own file, `BookSettingsSheet.swift`, when it grew the Collecting and
// State sections; P-9.)

// MARK: - The navigator's note-row door (R-cor-17; ladder fix 2, R2-10)

/// ONE door behind every navigator NOTE row — and the collapsed one-note
/// chapter row, which is that note's row (row 8): the act is decided by
/// the pure brain (`BookOutlineRows.navigatorNoteRowAct`) and PERFORMED
/// here on the two models, so a pin can drive it without a window and the
/// two Buttons cannot drift (P-1's one-declaration rule). Her ruling
/// R-cor-17 (2026-09-02): in Read — Scroll and Pages — the row lands the
/// read page at that story and the navigator never leaves Read; Outline
/// keeps opening the note for editing.
@MainActor
enum BookNavigatorDoor {
    static func noteRowClicked(
        _ entry: Queries.ReadingEntry, model: BookViewModel, structure: BookStructureModel
    ) {
        switch BookOutlineRows.navigatorNoteRowAct(mode: structure.mode, readForm: structure.readForm) {
        case .openTheNote:
            openTheNote(entry, model: model, structure: structure)
        case .showOnSpread:
            // 13b 4F: show the post read-cheap; a post already on the
            // spread stays where it is (13c 2B).
            model.showPost(entry.postID)
        case .turnThePages:
            // 13c 2C: the paged reader follows the book's focus to the
            // story's first page — the road the chapter row takes there.
            model.focus(entry.postID)
        case .landTheFlow:
            // Batch B's row 50 road: the flow consumes the reveal and lands
            // the story (its chapter's heading when it opens the chapter).
            model.requestReveal(entry.postID)
        }
    }

    /// Outline's act (rows 7/23/47): focus + reveal, landed by Outline
    /// whether the card is on screen or unrealized far below.
    static func openTheNote(
        _ entry: Queries.ReadingEntry, model: BookViewModel, structure: BookStructureModel
    ) {
        structure.mode = .outline
        model.focus(entry.postID)
        model.requestReveal(entry.postID)
    }
}

/// **The book view's own words** (13i-d U6 — the vocabulary sweep), pure and
/// static so the pins read the sentences the faces draw.
nonisolated enum BookViewCopy {
    /// The masthead's count line: the kind, chapters, notes and the
    /// set-aside count. "gathering", never "smart book" (the sitting record
    /// §1 — "smart" retired app-wide, §14); singular where one (KnownIssues
    /// row 111 — "1 chapters"). 13i-d U4's honest counts kept as built: the
    /// archived count rides only when there is one.
    static func metaLine(gathering: Bool, chapters: Int, notes: Int, archived: Int) -> String {
        var parts: [String] = [gathering ? "gathering" : "book"]
        if chapters > 0 { parts.append("\(chapters) chapter\(chapters == 1 ? "" : "s")") }
        parts.append("\(notes) note\(notes == 1 ? "" : "s")")
        if archived > 0 { parts.append(ArchivedLineCopy.line(count: archived)) }
        return parts.joined(separator: " \u{00B7} ")
    }

    /// A gathering's navigator footer. KnownIssues row 111: "it collects
    /// notes by its tags. Tag a note anywhere and it appears here." was false
    /// for a ★ rule (13i-b U4 F-U4-4) and said "collects" of a thing that
    /// holds nothing. The ruled noun and lesson 1/3's truth, for ANY rule:
    /// it shows, it holds nothing, and a note comes and goes with what the
    /// rule reads — its tags and its star.
    static let gatheringFooter =
        "gathering \u{2014} it shows every note its rule matches and holds none of them. "
        + "A note comes and goes with its tags and its star."
}

