//
//  TakesBoardView.swift
//  Variorum
//
//  Phase 11, Step A3 — the takes board; Phase 13 Stage C2 — the v2-canon
//  restyle (R12: tinted cards, the 3pt "✓ chosen" bar, ONE live ring; the
//  R24 short-block strip; R25 follow-the-scroll; the ＋new-take doors).
//
//  Taste-checkpoint fix round (Sitting 9 — R86): the TAKES tab is now
//  SINGLE-COLUMN ONLY — the post, block by block, with each block's fan in
//  the set style. The multi-column compositions and every piece of lens
//  machinery moved to the LENSES tab (LensesBoardView); fan styles and
//  columns never co-occupy a surface again. New here: first-take doors on
//  EVERY block (the 9d chicken-and-egg closed again — R72), the margin
//  grid's density option + reserved vertical room (R74), "Save current
//  choices as a lens…" (the elevate door), and "Write new takes on every
//  block" (R82 — the renamed branch-all, jargon retired per R70/R81).
//

import SwiftUI
import VariorumCore

struct TakesBoardView: View {
    let session: AppSession
    let postID: String
    @State private var model: TakesViewModel
    /// The carousel/slot-split EXPLICIT beneath-count control (1–4,
    /// user-chosen for their screen width — never auto-only).
    @AppStorage("takesBeneathCount") private var beneathCount = 2
    /// R13/R22 — the changing-block WASH, default ON, toggleable.
    @AppStorage("markChangingBlock") private var markChangingBlock = true
    /// R74 — the margin grid's density, hers to choose: cards stacked per
    /// column (1–3 high) and visible columns (1–2 wide). The rail reserves
    /// this much room while a block's takes are open.
    @AppStorage("takesGridRows") private var gridRows = 2
    /// **VX-136 — the column CHOICE, nil until she makes one.** The ruled
    /// default (*"two columns when the block has more than 2 takes"*) is
    /// per BLOCK, so it cannot be a stored number: an unset key — or her
    /// "auto" — means the default, and a stored 1 or 2 is her choice and
    /// always wins (R74's machinery, untouched). Same key as before, so a
    /// choice she already made is still hers.
    @AppStorage("takesGridCols") private var gridColsChoice: Int?
    @State private var lensNamePrompt = false
    @State private var diffPresentation: TakesDiffPresentation?
    /// 13b 1b: the routed-command registration's lifecycle token.
    @State private var commandToken: UUID?
    /// 13c 2B: the takes-board ATTACHMENT token (the availability half).
    @State private var attachToken: UUID?
    /// 17p batch a (row 1, R-Q1): the article's own scroll handle — the one
    /// road by which the remembered offset is restored.
    @State private var articleScroll = ScrollPosition()
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// 18l-c U8 (a): the arrival flash's discreet, unanimated variant.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
    }

    private var themeSettings: Queries.ThemeSettings {
        themeStore?.settings ?? Queries.ThemeSettings()
    }

    /// The Takes tab shows the POST — one fixed main column (columns live
    /// in Lenses now).
    private let mainColumn = TakesColumn(id: "takes-main", kind: .main)

    /// The registry ids this board renders INLINE (13b Stage 3, 3D — the
    /// `.surface` door; walk-asserted): the archived listing's Unarchive, and
    /// since 13e the take card's fan-order arrows (E4/A19) plus the merge
    /// selection banner (E3/A18).
    static let surfaceCapabilities: [CapabilityID] = [
        .unarchiveTake, .moveTakeEarlier, .moveTakeLater, .mergeSelectedBlocks,
        // 13u3 UNIT H: the LIVE take card's ⋯ menu — the F1 card grammar,
        // which reached this board's ARTICLE cell at the post-13l polish
        // round and never reached its cards. `.deleteTake` was already
        // declared here for the ARCHIVED card's own button, which is exactly
        // why the union walk could never see the gap; the per-surface pin in
        // `TakeCardDoorTests` is what holds it now.
        .archiveTake, .labelTake, .lockTake,
        // 18f batch 1 (her U-4/U-16): "Merge choosing takes…" beside Merge —
        // the two roads over the SAME picked run, never the pairing surface.
        .mergeWithCeremony,
        // The post-13l polish round (row 14 / F1): the archived card's own
        // Delete, declared where it is rendered.
        .deleteTake,
        // 13e E2 (A17): the same banner offers the delete door.
        .deleteSelectedBlocks,
        // VX-594 (R-601-4): the live card's ⌄ menu — "New branched take".
        .newTake,
        // 18c batch 3 (her U-6): …and the newline repair over that selection.
        .splitSelectedBlocksAtNewlines,
        // VX-372 (VX-383 U1 — D-C-2): the header's `note actions` row — the
        // shipped "Duplicate as Version", declared at last and running the
        // with-tags act under its verb.
        .duplicateNoteWithTags,
    ]

    /// Batch 14 (her image-#9 report — TWO live rings): the fan CARDS pane
    /// in their own namespace. When the chosen take's card was focused,
    /// its key EQUALED the article cell's (same column/block/variant) —
    /// both went live, and a live pane never adopts text, so the article
    /// froze stale. Distinct namespaces keep exactly ONE pane live (R22).
    static let fanColumnID = TakesViewModel.takesFanColumnID

    /// **The board's own coordinate space (13e batch 7 — the routed rider
    /// from batch 5's E12 sweep; `CanvasView.surfaceSpace`'s twin).** A
    /// `DragGesture` with no coordinate space measures in the gesture
    /// VIEW's space — and the slot-height handle sits directly BELOW the
    /// row it resizes, so shortening the row moves the handle, and each
    /// event then reports `pointerDelta − alreadyAppliedChange`: the drag
    /// converges to half the pointer's travel with an alternating stall
    /// (her canvas words exactly — "they jitter … and seemingly resist").
    /// A space the drag cannot move has no feedback term.
    static let surfaceSpace = "variorum-takes-surface"

    /// The rail card's geometry (13b 3F — her grid design input: the cards
    /// "a little bit wider and show the option better"; height stays the
    /// batch-7 uniform rule — "2 high" is literally two card-heights).
    static let railCardWidth: CGFloat = 250
    /// The card height lives on the geometry brain now (QoL batch 2 — the
    /// reserve arithmetic and the drag clamps all need it); this forward
    /// keeps every call site and pin reading unchanged.
    static let railCardHeight: CGFloat = TakesBoardLayout.railCardHeight

    /// R74: the rail's reserved width follows the column count — since
    /// VX-136, ONE block's count (her choice, else the ruled default for its
    /// fan).
    static func railWidth(columns: Int) -> CGFloat {
        CGFloat(columns) * railCardWidth + CGFloat(max(columns - 1, 0)) * 6
    }

    /// The columns this block's rail shows (VX-136 — the one brain the
    /// pagers ask too).
    private func railColumns(_ slot: Queries.RenderedBlock) -> Int {
        // VX-170: the takes the rail DRAWS (a filtered row's expand set).
        model.gridCols(takeCount: model.bloomTakes(slot).count, slotText: slot.text)
    }

    /// The widest rail the composition must make room for: her choice where
    /// she made one; otherwise the widest default among the blocks whose
    /// rails can be open — the expanded ones, or (follow-the-scroll) every
    /// fanned block, for the same reason `railEngaged` counts them all: the
    /// prose must not wobble as blooms come and go with scrolling.
    private var marginRailWidth: CGFloat {
        if let gridColsChoice { return Self.railWidth(columns: min(max(gridColsChoice, 1), 2)) }
        let candidates = model.projection.slots.filter { slot in
            // VX-170: under the `show ▾` filter, exactly the rows that bloom.
            model.lensFilter.filter != nil
                ? model.isBloomed(slot)
                : (model.followTheScroll ? slot.hasFan : model.expandedBlocks.contains(slot.blockID))
        }
        let columns = candidates.map(railColumns).max() ?? 1
        return Self.railWidth(columns: max(columns, 1))
    }

    /// R74's vertical room, HONEST about the fan (13b 3F, AD-7's other
    /// half): the row reserves what the tallest column can actually hold —
    /// steady across ◀ ▶ pages, never an empty reserve below a 1-take fan.
    ///
    /// QoL batch 2 (L4): the arithmetic moved to the geometry brain and
    /// now sums ACTUAL card heights bounded by the cap instead of uniform
    /// 110s. The max is taken over ALL columns, not the visible page —
    /// that is what preserves the steadiness property through the change
    /// to variable heights. With no measurements in yet it returns exactly
    /// what the old uniform arithmetic did.
    private func gridReservedHeight(takes: [Variant], rowsPerColumn: Int) -> CGFloat {
        model.reservedRailHeight(takes: takes, rowsPerColumn: rowsPerColumn)
    }

    init(session: AppSession, postID: String, model: TakesViewModel? = nil) {
        self.session = session
        self.postID = postID
        let model = model ?? TakesViewModel(session: session, postID: postID)
        // **A construction-time fact, never an appear-time one** (the 17q
        // ladder's R1-1, measured on her 262-block note): the article's
        // FIRST geometry report arrives before `.onAppear`, and the memory
        // read (`rememberedArticlePlace`) is gated on this flag — so set only
        // in `.onAppear` it read NO memory at the one moment that decides the
        // restore, the restore settled at once, and every entry became "the
        // top, then the landing's reveal". Which board a model is THE takes
        // board for is known here. (`.onAppear` still sets it — harmless.)
        // VX-428 (R-601-2): the same construction-time fact SEEDS the note's
        // open fans from the session — this line is what opens the board's
        // expansion memory, so the first geometry report is already judged
        // with the fans she left open drawn.
        model.landingEnabled = true
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            // 13b 1b (AD-14): the transient status line moved to the ONE
            // shell toast (StatusCenter) — consistent placement + a real
            // auto-dismiss; the board renders state banners only.
            if model.projection.sealed {
                Text(tokens.chromeLabel(
                    "sealed note — takes are viewable; choosing and new takes are frozen"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(tokens.wash)
            }
            if model.isJournalShaped {
                // R84's journal-entry note, its S5 half only — the Fragments
                // clause left with the bridge (2026-09-04; PROVISIONAL
                // wording, QUESTIONS #89).
                ChromeNotice(
                    tokens: tokens,
                    text: "Sync conflicts can add takes here; nothing is lost — "
                        + "choose what the entry shows.")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 4)
            }
            mergeSelectionBanner
            // 18l-c U7 (her R-18l-6): the board's find bar, above the article
            // like the selection banner — opened by ⌘F, closed by Esc.
            if model.find.isPresented {
                TakesFindBar(find: model.find, tokens: tokens)
            }
            singleColumnArticle
            TakesBottomBar(model: model)
        }
        .background(tokens.surface)
        // 13e batch 7 — THE ROUTED RIDER (batch 5's E12 sweep found this
        // board carrying the SAME coordinate-space defect the canvas had).
        // The board names a space so a drag measured in it is measured
        // against something the drag itself cannot move; the slot-height
        // handle below is the one gesture that needs it, and any future
        // board drag inherits the fix by being born here.
        .coordinateSpace(.named(Self.surfaceSpace))
        // VX-170 (R-VX170-4): the `show ▾` popover, seated under its door by
        // the door's published anchor (the Bookcase's host overlay, one idiom),
        // floating over the board without pushing a row. It lives like a MENU:
        // a press anywhere else closes it (consumed, as a menu's is), and so do
        // the board leaving, its window resigning key and the app resigning
        // active (`MenuLifeReporter` — the order popover's MINOR-1 lesson).
        .overlayPreferenceValue(MastheadDropperAnchors.self) { anchors in
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    if model.lensFilter.menuOpen {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { model.lensFilter.closeMenu() }
                    }
                    if model.lensFilter.menuOpen, let anchor = anchors[.takesShow] {
                        let rect = proxy[anchor]
                        TakesShowPopover(filter: model.lensFilter, tokens: tokens)
                            // The rows' words start under the door's words (the
                            // door's 5-pt label inset; the popover's 4 + row inset).
                            .padding(.leading, max(0, rect.minX + 5 - (4 + MastheadPopover.rowInsets.leading)))
                            .padding(.top, rect.maxY + MastheadPopover.gap)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
        }
        .reportsMenuLifeEnds { model.lensFilter.closeMenu() }
        .debugProbeScope(session)
        .task { await model.start() }
        // 13b Stage 3 (3D — N1): the archived listing is its own read
        // (the fans query stays active-only), refreshed at projection
        // cadence — the WriteTakesPanel precedent.
        .task { await model.refreshArchived() }
        .onChange(of: model.projection) { _, _ in
            Task { await model.refreshArchived() }
            // 18l-c U7: a settle / arrival while the bar is open recounts
            // (only the takes whose text moved rescan).
            model.find.projectionChanged()
        }
        .onAppear {
            model.followTheScroll = themeSettings.followTheScroll
            model.host = .takes
            // 13b 1b: this is THE takes board — landings (N9's "just
            // start typing" ring, cross-mode blooms) apply here, never in
            // the Write panel's embedded model.
            model.landingEnabled = true
            pushDensity()
            // The routed-command channel (P-4): a registered handler by
            // composition, not a notification observer.
            commandToken = session.commandRouter.registerHandler { handleRouted($0) }
            // …and the AVAILABILITY half (13c 2B, Stage 4 lesson 2): the
            // board says it is here, so the take family is live wherever it
            // mounts — including the book spread's takes page, where there
            // is no post detail to carry `mode == .takes`.
            attachToken = session.commandRouter.attachTakesBoard()
        }
        .onChange(of: themeSettings.followTheScroll) { _, new in
            model.followTheScroll = new
        }
        // 13n-b U4: a takes landing parked while this board was already up.
        .onChange(of: session.commandRouter.pendingTakesLanding) { _, _ in
            model.consumePendingTakesLanding()
        }
        .onChange(of: beneathCount) { _, _ in pushDensity() }
        .onChange(of: gridRows) { _, _ in pushDensity() }
        .onChange(of: gridColsChoice) { _, _ in pushDensity() }
        .onDisappear {
            if let commandToken {
                session.commandRouter.unregisterHandler(commandToken)
            }
            if let attachToken {
                session.commandRouter.detachTakesBoard(attachToken)
            }
            model.lensFilter.closeMenu()
            model.teardown()
        }
        // ⎋ — the plain page (R87); with the `show ▾` popover open, ⎋ closes
        // the popover first, as a menu's Escape does (VX-170).
        .onExitCommand {
            if model.lensFilter.menuOpen {
                model.lensFilter.closeMenu()
            } else {
                model.closeAllFans()
            }
        }
        .sheet(item: $diffPresentation) { diff in
            DiffView(
                leftTitle: diff.leftTitle, rightTitle: diff.rightTitle,
                leftText: diff.left, rightText: diff.right, tokens: tokens)
        }
        .sheet(isPresented: $lensNamePrompt) {
            LensNameSheet(title: "Save current choices as a lens") { name in
                Task { await model.saveCurrentChoicesAsLens(name: name) }
            }
        }
        .sheet(item: $model.divideWCeremony) { state in
            // 13d Batch 3 (A9): the take ceremony mounts HERE — a fanned
            // block's divide never leaves this view. Any dismissal other
            // than Divide is a cancel; no rows are touched by opening.
            DivideWSheet(ceremony: model.ceremony, presented: state)
        }
    }

    /// The board keeps the density inputs on the model (one paging brain —
    /// the keyboard door and the ◀ ▶ doors can never disagree).
    private func pushDensity() {
        model.beneathCount = beneathCount
        model.gridRows = gridRows
        model.gridColsChoice = gridColsChoice
    }

    /// The board's routed-command handler (13b 1b): the take family as
    /// before, plus the fire-and-DO structural doors (move-and-execute),
    /// the native add-block door, and keyboard fan paging.
    private func handleRouted(_ command: RoutedCommand) -> Bool {
        switch command {
        case .takes(let takes):
            handleTakesCommand(takes)
            return true
        case .structural(let act):
            // 13d Batch 3 (A9): DIVIDE acts natively here; the other three
            // keep the carry choreography. One model door so this handler,
            // the Lenses handler and the bar cannot drift.
            model.runStructuralDoor(act)
            return true
        case .deleteInEveryTake:
            model.moveToWriteAndRun(.deleteInEveryTake)
            return true
        case .commit:
            // 13u3 UNIT D: ⌘S summons the optional name at the bar's commit
            // door; ⏎ files it (empty = unnamed, the two-key road).
            model.askSavepointName()
            return true
        case .addBlockAtEnd:
            Task { await model.addBlockAtEnd() }
            return true
        case .insertBlockBelow:
            // 13b 4D (N28/S4-13): native in Takes — the minted block's pane
            // takes the ring when its slot arrives.
            Task { await model.insertBlockBelowFocused() }
            return true
        case .deleteBlock:
            // 13c 1B (A8): native in Takes (R118 parity) — the focused
            // block goes and the ring lands on its neighbour.
            Task { await model.deleteFocusedBlock() }
            return true
        case .archiveBlock:
            // 13j (her round-7 ruling): archive is native here for the same
            // R118 reason delete is — Takes is never behind Write.
            Task { await model.archiveFocusedBlock() }
            return true
        case .toggleSeal:
            Task { await model.toggleSeal() }
            return true
        case .comments:
            model.requestComments()
            return true
        case .callout(let edit):
            // 13c R2-2 (A13(a)): "i couldn't get callouts in takes" — the
            // frame is the block's, so it is set right here.
            Task { await model.applyCallout(edit) }
            return true
        case .pageFan(let delta):
            model.pageFocusedFan(by: delta)
            return true
        case .copyAllTakes:
            // 13e E6 (A21): the focused block's fan → the clipboard.
            Task { await model.copyAllTakes() }
            return true
        case .takeToBlockBelow:
            // 13e E5 (A20): native here — the take you're in becomes the
            // block below, and the ring follows it.
            Task { await model.moveTakeIntoBlockBelow() }
            return true
        case .takesToBlocks:
            // 13e E6b (A21/A45): the whole fan, in fan order, under ONE undo.
            Task { await model.turnTakesIntoBlocks() }
            return true
        case .showOriginBlock:
            // 13j J3: the focused block's released original — the peek, or
            // the honest note where there is none.
            model.revealFocusedBlockOrigin()
            return true
        case .showBlockHistory:
            // The post-13l polish round (ledger row 17): the focused block's
            // whole time — the shared model machinery, same as Write.
            model.requestBlockHistory()
            return true
        case .showNoteTray:
            // The architect's adjudication 1: the ⌘K row onto the note's tray.
            model.requestNoteTray()
            return true
        case .showNoteVersions:
            // The post-13l polish round (rows 16/23): the note's saved moments.
            model.requestNoteVersions()
            return true
        case .saveNoteVersion:
            Task { await model.saveNoteVersion() }
            return true
        case .find(let action):
            // 18l-c U7 (her R-18l-6): the board's OWN find — ⌘F opens its bar,
            // ⌘G / ⇧⌘G step. The replace half and ⌘E decline, and the router
            // speaks their declared note: find-only v1 (her R-18l-9).
            switch action {
            case .show:
                model.find.open()
                return true
            case .next:
                model.find.next()
                return true
            case .previous:
                model.find.previous()
                return true
            case .showReplace, .useSelection, .replaceAllInEveryTake:
                return false
            }
        }
    }

    /// The board's half of the R73 keyboard family — the focused pane is
    /// the target; without one, the command SAYS what to do.
    private func handleTakesCommand(_ command: TakesCommand) {
        switch command {
        case .toggleFan:
            model.toggleFocusedFan()
        case .closeAll:
            model.closeAllFans()
        case .branch:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a take first — ⌘T branches the take you're in.")
                return
            }
            Task {
                // Stage 2 walk fix: branch REVEALS — fan open, ring on the
                // new take (before this, ⌘T on a closed fan was invisible).
                await model.branchTakeRevealed(
                    blockID: pane.blockID, from: pane.variantID,
                    preferredColumnID: pane.columnID)
            }
        case .blank:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a block first — ⌥⌘T adds a blank take there.")
                return
            }
            Task {
                await model.newBlankTakeRevealed(
                    blockID: pane.blockID, preferredColumnID: pane.columnID)
            }
        case .blankChoose:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a block first — ⇧⌥⌘T opens a blank take as chosen there.")
                return
            }
            Task { await model.newBlankTakeAsChosen(blockID: pane.blockID) }
        case .choose:
            Task { await model.chooseFocusedTake() }
        case .stepPrev:
            Task { await model.stepTakes(by: -1) }
        case .stepNext:
            Task { await model.stepTakes(by: 1) }
        case .archive:
            Task { await model.archiveFocusedTake() }
        case .saveLens:
            lensNamePrompt = true
        }
    }

    // MARK: - Header

    /// VX-136: the `n wide` menu's words — her choice by its number, the
    /// ruled default as "auto" (PROVISIONAL).
    static let gridColsAutoItem = "auto — two past two takes"
    static func gridColsLabel(_ choice: Int?) -> String {
        choice.map { "\($0) wide" } ?? "auto wide"
    }

    /// Batch 9 (R101): ONE quiet voiced line — style/density as compact
    /// word-menus, the wash as a chip, expand/close as words, and the
    /// three rare post-level acts folded into a single "post actions"
    /// menu. Every door the old toolbar had is still one click away; the
    /// row just stops shouting over the page.
    private var header: some View {
        Group {
            // VX-170 (R-VX170-4): lens-aware Takes' door LEADS the line — the
            // first question this board answers is now "which takes?". It
            // renders only on a note with a saved lens (P-VX168-U4-1).
            //
            // WIDTH-AWARE (the U4 walk's W-1, measured: in margin grid the
            // line's fixed controls fill the 680-pt measure, and the door — the
            // one item that may yield — truncated to NOTHING; the filter was on
            // with no door to see or change it). One line while the door fits
            // WHOLE beside the controls; otherwise the door and its chip take a
            // line of their own above them (`MastheadRowTwo`'s one-or-two-lines
            // rule, in its simplest form). The controls never move for it.
            if model.lensFilter.offered {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        TakesShowDoor(filter: model.lensFilter, tokens: tokens)
                        headerControls
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        TakesShowDoor(filter: model.lensFilter, tokens: tokens)
                        HStack(spacing: 8) { headerControls }
                    }
                }
            } else {
                HStack(spacing: 8) { headerControls }
            }
        }
        // Batch 14 (her alignment ask): the control line shares the
        // article's measure and left edge — one column, like the mockup.
        .frame(maxWidth: articleMeasure, alignment: .leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
    }

    /// The header line's controls (style, density, wash, expand/close, note
    /// actions) — one copy, composed by `header` on one line or under the
    /// `show ▾` door's own (VX-170, W-1).
    @ViewBuilder
    private var headerControls: some View {
            VoicedMenu(tokens: tokens, label: "style: \(styleName)") {
                styleOption("Stack", .stack)
                styleOption("Carousel", .carousel)
                styleOption("Margin grid", .marginGrid)
                styleOption("Slot split", .slotSplit)
            }
            .help("How a block's takes fan open")

            if model.projection.fanStyle == .carousel || model.projection.fanStyle == .slotSplit {
                VoicedMenu(tokens: tokens, label: "× \(beneathCount) beside") {
                    ForEach(1...4, id: \.self) { n in
                        Button("× \(n)") { beneathCount = n }
                    }
                }
                .help("How many takes show side by side (your screen width, your call)")
            }
            if model.projection.fanStyle == .marginGrid {
                // R74 — the grid density option: "you should be able to
                // choose what grid you want, up to like 3 high and 2 wide".
                VoicedMenu(tokens: tokens, label: "\(gridRows) high") {
                    ForEach(1...3, id: \.self) { n in
                        Button("\(n) high") { gridRows = n }
                    }
                }
                .help("How many take cards stack vertically in the margin")
                // VX-136: the ruled default is per block, so it has its own
                // name here — "auto" — and her picking it gives the choice
                // back (PROVISIONAL wording; the run record's disposition).
                VoicedMenu(tokens: tokens, label: Self.gridColsLabel(gridColsChoice)) {
                    Button(Self.gridColsAutoItem) { gridColsChoice = nil }
                    ForEach(1...2, id: \.self) { n in
                        Button("\(n) wide") { gridColsChoice = n }
                    }
                }
                .help("How many card columns the margin shows before scrolling — "
                    + "auto shows two once a block has more than two takes")
            }
            if model.projection.fanStyle != .slotSplit {
                VoicedChip(
                    tokens: tokens,
                    text: markChangingBlock ? "wash: on" : "wash: off",
                    on: markChangingBlock
                ) { markChangingBlock.toggle() }
                    .help("Wash the block whose takes are open (R13 — the transient marker)")
            }

            if model.offersExpandAll {
                Button(tokens.chromeLabel("expand all")) { model.expandAllFans() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help("Open every block's fan (they stay open once expanded)")
                Button(tokens.chromeLabel("close all")) { model.closeAllFans() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .disabled(model.expandedBlocks.isEmpty)
                    .help("Back to the plain page (⎋)")
            }

            Spacer()

            VoicedMenu(tokens: tokens, label: "note actions", role: .primary) {
                Button("Write new takes on every block") {
                    Task { await model.writeNewTakesEverywhere() }
                }
                .help("A fresh take on every block, branched from what the note shows — "
                    + "a full rewrite pass. See them in each block's fan, or side by side in Lenses.")
                Button("Save choices as lens…") { lensNamePrompt = true }
                    .help("Keep the note's current takes as a named way of looking (a lens) — "
                        + "you can bring it back or compare against it in Lenses")
                // VX-372 (D-C-2, P-C-1): the shipped row, under its declared verb.
                Button(CapabilityRegistry.capability(.duplicateNoteWithTags).verb) {
                    Task { await model.duplicateAsVersion(tags: .applied) }
                }
                .help(DuplicateCopy.help(.applied))
            }
            .help("The rare whole-note acts: a rewrite pass, saving choices as a lens, "
                + "duplicating the note")
    }

    /// 18f batch 1 (U-4/U-16): the picked run's two roads. Its own function
    /// because the banner's `HStack` had already reached the type checker's
    /// patience (a compile error, not a preference).
    @ViewBuilder
    private func mergeRoadsMenu(picked: Int) -> some View {
        let blocks = max(3, picked)
        VoicedMenu(
            tokens: tokens,
            label: CapabilityRegistry.capability(.mergeWithCeremony).verb,
            role: .quiet
        ) {
            ForEach(MergeArrangement.offered(blocks: blocks)) { option in
                Button(option.title(blocks: blocks)) {
                    Task {
                        await model.mergeSelectedBlocks(
                            bringEveryTake: option == .bringEveryTake)
                    }
                }
            }
        }
        .help(MergeArrangementCopy.bannerHelp(blocks: blocks))
        // One enablement rule for the pair of merge doors (18f ladder R1-7):
        // its neighbour "Merge Selected Blocks" disables below two picks.
        .disabled(picked < 2)
    }

    private func styleOption(_ name: String, _ style: FanStyle) -> some View {
        Button(name) { Task { await model.setFanStyle(style) } }
    }

    // MARK: - The merge selection banner (13e E3 — her A18)

    /// While blocks are ⌘-clicked, the board says so and offers the act — the
    /// `.surface` half of the declared door (its twin is the article cell's
    /// context menu). It renders only while a selection exists, so at rest the
    /// page is exactly as calm as before.
    @ViewBuilder
    private var mergeSelectionBanner: some View {
        let picked = model.selectedBlocksInOrder
        if !picked.isEmpty {
            HStack(spacing: 8) {
                Text(tokens.chromeLabel(BlockSelectionCopy.bannerLabel(picked: picked.count)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Button(CapabilityRegistry.capability(.mergeSelectedBlocks).verb) {
                    Task { await model.mergeSelectedBlocks() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary, font: tokens.mono))
                .disabled(picked.count < 2)
                .help("Join the picked blocks into one — neighbours only; ⌥⌘Z undoes it")
                // 18f batch 1 (U-4: *"should be a button, not just a
                // shortcut"*; U-16: two choices over a run, never a pairing
                // surface). The picked run's own door, in this bar's own
                // vocabulary — the same `VoicedMenu` idiom its neighbours use.
                mergeRoadsMenu(picked: picked.count)
                // 13e E2 (her A17): the delete door, beside merge, over the
                // one selection. Never disabled — one pick is a legitimate
                // delete, so the button either acts or delivers the ops
                // layer's own refusal (P-2).
                Button(BlockSelectionCopy.deleteVerb(picked: picked.count)) {
                    Task { await model.deleteSelectedBlocks() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(BlockSelectionCopy.deleteHelp)
                // 18c batch 3 (her U-6): the newline repair over the same
                // selection — the workbench's bulk bar carries it too, and
                // one grammar means both banners do.
                Button(SplitAtNewlinesCopy.bulkDoor) {
                    Task { await model.splitSelectedBlocksAtNewlines() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(SplitAtNewlinesCopy.blockHelp)
                Button(tokens.chromeLabel("clear")) { model.clearMergeSelection() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help("Unpick every block")
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(tokens.wash)
        }
    }

    // MARK: - The article (ONE column; blooms in the set style)

    private var singleColumnArticle: some View {
        // The GeometryReader is the N8 fix's one width source: the comment
        // margin clamps into the room the centering ACTUALLY leaves,
        // instead of hanging a fixed 166pt into space the sidebar owns.
        GeometryReader { proxy in
            let commentRoom = max((proxy.size.width - articleMeasure) / 2, 0)
            ScrollViewReader { column in
            ScrollView {
                if model.projection.slots.isEmpty {
                    // Batch 6: an empty post must never be a dead end.
                    // 17o batch c (row 15, her punchlist 10): and the first
                    // block can be MADE here — one shared face with Lenses,
                    // so the two boards can never answer her differently.
                    TakesEmptyStateView(
                        tokens: tokens,
                        onNewBlock: { Task { await model.addBlockAtEnd() } },
                        onWrite: { session.commandRouter.requestMode(.write, postID: postID) })
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
                LazyVStack(alignment: .leading, spacing: 6) {
                    // VX-170 (R-VX170-2): a filter that names no block SAYS so,
                    // in place, in one muted line — never an empty room, and the
                    // note's map (the collapsed rows below) stays whole.
                    if let zero = model.lensFilter.zeroLine {
                        TakesShowCopy.text(zero, tokens: tokens)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.leading, Self.articleTextLeadingInset)
                            .padding(.bottom, 6)
                    }
                    ForEach(model.projection.slots, id: \.placementID) { slot in
                        // VX-170 (R-VX170-2): a block the `show ▾` filter does
                        // not name is ONE line; every other row is the article's
                        // own. Same identity either way (the placement), so the
                        // landings, the scroll memory and the tour read through.
                        Group {
                            if model.rowShape(slot) == .collapsed {
                                collapsedRow(slot: slot)
                            } else {
                                articleRow(slot: slot, commentRoom: commentRoom)
                            }
                        }
                            // 13s-b U2: step 7 points at the block she made a
                            // take of — both takes, side by side.
                            .tourAnchor(.takesBlock(slot.blockID), cornerRadius: 10)
                            .onAppear { model.rowAppeared(slot.blockID) }
                            .onDisappear {
                                model.rowDisappeared(slot.blockID)
                                model.forgetArticleRowFrame(slot.placementID)
                            }
                            // 17p batch a (row 1): the row says WHERE it is,
                            // in the scroll view's own space, so a landing can
                            // ask "is this already on screen?" and answer with
                            // geometry instead of guessing. `onGeometryChange`
                            // republishes only on change and the board stores
                            // it un-observed, so a scroll re-renders nothing.
                            .onGeometryChange(for: CGRect.self) {
                                $0.frame(in: .scrollView)
                            } action: { frame in
                                model.noteArticleRowFrame(slot.placementID, frame)
                                // 18l-b U2: a REPORT — the step until the
                                // one authority watches the landing, a
                                // report to it after (never an aim per row).
                                spendArticleLanding(column, asReport: true)
                            }
                    }
                    if !model.projection.slots.isEmpty {
                        // D3's third leg (13b 1b): the add-block door lives
                        // where blocks end — the same dashed grammar as the
                        // fan-growth doors. The minted block's pane takes the
                        // ring, so typing continues instantly.
                        Button(TakesEmptyState.newBlockVerb) {
                            Task { await model.addBlockAtEnd() }
                        }
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                        // P-8: a chrome `fixedSize` text always carries a
                        // `lineLimit` (the b6dae25 class) — the door the
                        // empty state's copies, closed on both.
                        .lineLimit(1)
                        .fixedSize()
                        .help("A new block at the end of the note — type right into it")
                        // The probe measures the DASHED RECT itself, so it
                        // sits INSIDE the padding below — a probe outside it
                        // reads the padding's own frame and reports the old
                        // place (measured).
                        .articleDoorProbe()
                        // 17p batch a (row 2, her R-Q2): the door's edge sits
                        // on the PROSE's edge, not the cell's. Derived from
                        // the two constants that actually create the daylight
                        // — never a magic number, so the door cannot drift
                        // from the text it stands under.
                        .padding(.leading, Self.articleTextLeadingInset)
                    }
                }
                .frame(maxWidth: articleMeasure, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                // 18l-c U8: the article's resting top air is ONE named constant
                // (KnownIssues row 94's sketch) — the comfort band's top edge
                // reads the same number this padding draws.
                .padding(.vertical, TakesArticleScroll.articleTopAir)
                if !model.projection.slots.isEmpty {
                    typewriterRoom(viewport: proxy.size.height)
                }
            }
            // 17p batch a (row 1, her ruling R-Q1): the page opens where she
            // left it. The PLACE (the row at the top of the page, or the top
            // itself) is the SESSION's (the model dies with the mount), the
            // restore is ONE-SHOT, and nothing is remembered until it has
            // been spent — a fresh mount reports offset 0 before the restore
            // runs, and recording that would erase the very thing we came
            // back for.
            .scrollPosition($articleScroll)
            .onScrollGeometryChange(for: TakesBoardLayout.ArticleGeometry.self) {
                TakesBoardLayout.ArticleGeometry(
                    offset: $0.contentOffset.y,
                    content: $0.contentSize.height,
                    viewport: $0.containerSize.height)
            } action: { _, geometry in
                // The RULE lives in the model (P-9, and the measured lesson
                // that a `@State` written and re-read inside one update
                // transaction is not a promise SwiftUI makes); the view only
                // performs the scroll it is told to.
                switch model.consumeArticleGeometry(
                    geometry, positionedByUser: articleScroll.isPositionedByUser
                ) {
                case .scrollToRow(let rowID, let anchorY):
                    // The restore's ONE move: put the block she was reading
                    // back where it sat — at the top of the page for a
                    // 17p-shaped place, `anchorY` down it otherwise (the 17q
                    // ladder, R1-1). Absolute, so re-aiming as the lazy
                    // column's real heights arrive converges.
                    // (`.top` IS `UnitPoint(x: 0.5, y: 0)` — one value, one
                    // spelling; the 17q ladder's round 2, R2-5.)
                    column.scrollTo(rowID, anchor: UnitPoint(x: 0.5, y: anchorY))
                case .remember, .wait:
                    break
                }
                spendArticleLanding(column, asReport: true)
            }
            // 17o batch b (ledger row 8, her words: *"open takes mode in write
            // from the takes menu is also not automatically navigating you to
            // where the take is"*) — REVISED by 17p batch a's R-Q1: the
            // landing REVEALS. It still names the slot on the ForEach's OWN
            // identity (the placement id — the Act 10 ladder's R1-3 lesson
            // about lazy columns and estimate drift), but it is spent as the
            // MINIMAL scroll (the row to the nearer edge of the page) and only
            // when the board's own geometry says the row is not fully on
            // screen, and only AFTER the scroll memory has been restored — so
            // a landing can never be the reason the page jumps to the bottom.
            .onChange(of: model.articleLanding, initial: true) { _, _ in
                spendArticleLanding(column)
            }
            // 18l-b U2: the one landing authority's CORRECTION — issued from
            // quiet, spent through the same step (the one scroll mechanism).
            .onChange(of: model.articleLandingCorrections) { _, _ in
                spendArticleLanding(column)
            }
            }
        }
    }

    /// A landing never runs before the page is where the memory says it
    /// should be, never hauls a row to the far edge, and ends at HER HAND
    /// (the 17o batch-b BLOCKER's class was a request outliving its moment
    /// across MOUNTS; this one dies with the model and is ended by a scroll,
    /// a click or an edit). The step machine is the board's
    /// (`articleLandingStep`, with the measured reasons); the view performs
    /// the scroll it is told to. Re-entered from the geometry hook, the
    /// landing's change, AND each row's frame report, so the request re-aims
    /// as the lazy column realizes and measures its rows (the 17p batch-a
    /// adjudication, J1). **18l-b U2:** the geometry hook and the row reports
    /// are REPORTS (`asReport`) — they spend the step only until the one
    /// landing authority is watching the landing (its first decided step);
    /// after that they report to the watch, and the re-aim comes from the
    /// watch's quiet (`articleLandingCorrections`) instead of once per row
    /// report inside a layout storm.
    private func spendArticleLanding(_ column: ScrollViewProxy, asReport: Bool = false) {
        switch asReport ? model.articleLandingReport() : model.articleLandingStep() {
        case .reveal(let rowID, let aim):
            // 18l-b U2: the edge's anchor through the aim kind's ONE
            // vocabulary door (`ViewportCarry.anchor` — 0 the head, 1 the
            // foot): `UnitPoint(x: 0.5, y: 0)` / `(0.5, 1)`, exactly the
            // `.top` / `.bottom` this line always passed — for every kind but
            // the mode switch's ENTRY, whose row rests at the comfort band's
            // edge instead (18l-c U8 (b): `TakesArticleScroll.revealAnchor`).
            column.scrollTo(rowID, anchor: model.board.article.revealAnchor(for: rowID, aim))
        case .wait, .done:
            break
        }
    }

    /// **13f W7 — HER RULING (2026-07-30):** *"the whitespace underneath works
    /// great on write — i would also like to have that whitespace option on
    /// takes."* A22's room, on the board.
    ///
    /// **The mechanism is the board's own, and simpler than Write's, because
    /// the surfaces are not alike.** Write's room is a scroll allowance on an
    /// `NSTextView`'s document frame, and it took A22 three mechanisms to get
    /// there (the QoL round's record: the first two were unreachable through
    /// the scroller knob, ⌘↓, jumps and the width-reflow restore). The board's
    /// article is an ordinary SwiftUI `ScrollView`, so the room is ordinary
    /// CONTENT EXTENT — a clear box below the last row. Every input path
    /// reaches it by construction: wheel, trackpad, the scroller knob, ⇟, ⌘↓.
    /// There is no allowance to be blind to, which is exactly why this is not
    /// a fourth A22 mechanism.
    ///
    /// The HEIGHT is the shared brain — `TypewriterRoom.height`, the same
    /// viewport-less-one-line arithmetic Write uses, so the two surfaces feel
    /// the same and neither can drift from the other.
    ///
    /// **Zero store bytes.** The room is space, never content: no block, no
    /// variant, no newline. A22's letter, pinned.
    private func typewriterRoom(viewport: CGFloat) -> some View {
        Color.clear
            .frame(
                height: TypewriterRoom.height(
                    viewport: viewport,
                    lineHeight: TypewriterRoom.lineHeight(of: EditorDocument.baseFont)))
            .contentShape(Rectangle())
            .onTapGesture { landInTheRoom() }
            .accessibilityHidden(true)
    }

    /// A click in the room lands the ring on the LAST block's shown take, with
    /// the caret at its end — A22's "the room is space the caret can enter",
    /// said in the board's vocabulary. It rides the standing focus door
    /// (`focusWithCaretAtEnd` → `focus` → the authority), so P-3 holds: still
    /// exactly one live pane, still one liveness authority.
    private func landInTheRoom() {
        guard let slot = model.projection.slots.last,
              let resolved = model.resolvedTake(column: mainColumn, slot: slot)
        else { return }
        // A slot-split bloom REPLACES the article cell with fan cards, so the
        // last block's pane lives in the fan namespace there (the same branch
        // `articleRow` takes).
        let splitBloomed = model.isBloomed(slot)
            && model.projection.fanStyle == .slotSplit && slot.hasFan
        model.focusWithCaretAtEnd(TakesViewModel.PaneKey(
            columnID: splitBloomed ? Self.fanColumnID : mainColumn.id,
            blockID: slot.blockID, variantID: resolved.variantID))
    }

    /// Whether the margin rail is part of the composition RIGHT NOW (13b
    /// 3F, D2/AD-6): only while some fan is actually open — the at-rest
    /// page must never shift for an empty reserve. Follow-the-scroll keeps
    /// the measure stable whenever the post has any fan at all (blooms
    /// come and go with scrolling; the prose must not wobble).
    private var railEngaged: Bool {
        guard model.projection.fanStyle == .marginGrid else { return false }
        // VX-170: under the `show ▾` filter the rail is engaged exactly while
        // some row blooms (a filtered row blooms without being "expanded").
        if model.lensFilter.filter != nil {
            return model.projection.slots.contains { model.isBloomed($0) }
        }
        return !model.expandedBlocks.isEmpty
            || (model.followTheScroll && model.projection.slots.contains { $0.hasFan })
    }

    /// R9's measure: 680pt of prose; an ENGAGED margin rail widens the
    /// composition by its reserved width (D2: at rest — any style — the
    /// article sits exactly where Write and stack put it).
    private var articleMeasure: CGFloat {
        Self.articleMeasure(engagedRailWidth: railEngaged ? marginRailWidth : nil)
    }

    /// The article cell's own breathing room around its pane (the washed
    /// card's inset). Named because the ＋ new block door has to line up
    /// against it (17p batch a, row 2).
    nonisolated static let articleCellPadding: CGFloat = 2

    /// **Where the article's PROSE starts, relative to the column** — the
    /// cell's padding plus the take pane's own text inset. Her ruling R-Q2
    /// aligns the ＋ new block door to this, not to the cell's edge; measured
    /// on the pre-fix tree the two were 8 pt apart, which is the daylight she
    /// read as misalignment (her image 2).
    @MainActor
    static var articleTextLeadingInset: CGFloat {
        articleCellPadding + PaneTextView.takeSurfaceInset
    }

    /// The composition-measure brain (13b 3F — the D2/AD-6 pin's target):
    /// at rest the article is the 680 prose column in EVERY style; only a
    /// rail that is actually engaged (an open fan in margin grid) widens
    /// the composition. The old always-wide margin-grid measure shifted
    /// the whole page ~118pt left for an EMPTY reserve.
    nonisolated static func articleMeasure(engagedRailWidth: CGFloat?) -> CGFloat {
        guard let engagedRailWidth else { return 680 }
        return 680 + 16 + engagedRailWidth
    }

    /// ONE structural shape for every style and bloom state (13b 3F): the
    /// article cell keeps a STABLE identity across expand/collapse —
    /// branch-per-state trees re-identified the cell's NSView on every
    /// bloom (a churned live pane momentarily doubled the ring; the board
    /// soak caught it) — the conditional parts render AROUND the cell.
    @ViewBuilder
    private func articleRow(slot: Queries.RenderedBlock, commentRoom: CGFloat) -> some View {
        let bloomed = model.isBloomed(slot)
        let style = model.projection.fanStyle
        // The slot-split bloom REPLACES the cell — the style's whole point
        // (the same branch flip the pre-3F tree had).
        let splitBloomed = bloomed && style == .slotSplit && slot.hasFan
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if !splitBloomed {
                    washedCell(slot: slot, washed: bloomed, commentRoom: commentRoom)
                }
                if splitBloomed {
                    closeFanLine(slot: slot)
                    slotSplitBloom(slot: slot)
                }
                if bloomed, !slot.hasFan, style != .marginGrid {
                    // The FIRST-take door (R72): an unfanned block blooms
                    // into just the growth doors, whatever the style (the
                    // grid renders them in its rail instead).
                    fanFooter(slot: slot).padding(.leading, 24)
                }
                if bloomed, slot.hasFan, style == .stack {
                    stackBloom(slot: slot)
                }
                if bloomed, slot.hasFan, style == .carousel {
                    carouselBloom(slot: slot)
                }
            }
            .frame(maxWidth: 680, alignment: .topLeading)
            if style == .marginGrid, bloomed {
                // VX-136: this block's OWN column count (her choice, else
                // the ruled default for its fan).
                marginRail(slot: slot)
                    .frame(width: Self.railWidth(columns: railColumns(slot)), alignment: .topLeading)
                    .takeRailGeometryProbe(.rail, blockID: slot.blockID)
            }
        }
        .modifier(TakesCalloutFrame(
            presentation: model.calloutFrame(slot.blockID),
            tokens: tokens, dark: scheme == .dark))
    }

    /// **VX-170 (R-VX170-2) — a block the `show ▾` filter does not name, as ONE
    /// LINE**: the shown take's first line (through the authority's overlay —
    /// never staler than a buffer), muted, truncated at its tail; and the
    /// article's own corner badge, the block's whole-fan door (her "the rest of
    /// the fan stays behind its usual control") — a press opens the block whole.
    /// Read-cheap by construction: no pane, no live editor (P3). The callout
    /// frame and the comment note stand down on a line that is only the map.
    private func collapsedRow(slot: Queries.RenderedBlock) -> some View {
        let text = model.resolvedTake(column: mainColumn, slot: slot)?.text ?? slot.text ?? ""
        let line = TakesShowCopy.firstLine(text)
        return HStack(spacing: 0) {
            Text(verbatim: line ?? tokens.chromeLabel(TakesShowCopy.emptyBlock))
                .font(tokens.small)
                .foregroundStyle(line == nil ? tokens.faint : tokens.muted)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
        }
        .padding(.leading, Self.articleTextLeadingInset)
        .padding(.vertical, 1)
        .frame(maxWidth: 680, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            fanBadge(slot: slot, bloomed: false)
                .offset(x: 40)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(line ?? TakesShowCopy.emptyBlock)
    }

    /// The fan door as a CORNER BADGE (13b 3F — the D2 ledger row's second
    /// traced candidate: `fanToggleRow` stacked a button row above EVERY
    /// block, unfanned included, so the takes page at rest carried 3-4×
    /// Write's inter-block gaps). Write's grammar, mirrored: ⑂n at the
    /// block's top-right, in the margin, zero vertical footprint — and
    /// R72's first-take door ("⑂+") keeps its always-visible offer.
    @ViewBuilder
    private func fanBadge(slot: Queries.RenderedBlock, bloomed: Bool) -> some View {
        Button(slot.hasFan ? "⑂\(slot.activeVariantCount)" : "⑂+") {
            model.toggleExpanded(slot.blockID)
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: slot.hasFan ? .primary : .quiet))
        // VX-170: under the `show ▾` filter the badge is the block's WHOLE-FAN
        // door, and its words say what a press does there.
        .help(model.lensFilter.badgeHelp(slot) ?? (slot.hasFan
              ? (bloomed
                 ? CapabilityRegistry.capability(.showTakes).menuTitle("Close this fan")
                 : "Open this fan (\(styleName))"
                   + (CapabilityRegistry.capability(.showTakes).shortcutLabel
                        .map { " — \($0)" } ?? ""))
              : CapabilityRegistry.capability(.showTakes)
                  .menuTitle("Give this block its first alternative take")))
    }

    /// The slot-split bloom's close door (its bloom REPLACES the cell, so
    /// the corner badge has no host there).
    private func closeFanLine(slot: Queries.RenderedBlock) -> some View {
        HStack {
            Spacer()
            fanBadge(slot: slot, bloomed: true)
        }
    }

    private func washedCell(
        slot: Queries.RenderedBlock, washed: Bool, commentRoom: CGFloat
    ) -> some View {
        let bloomed = model.isBloomed(slot)
        // N8/AD-8: the comment note clamps into the real gutter — the full
        // card where ≥90pt of margin exists, the compact // chip below
        // that; never laid out in space the sidebar owns.
        let compactNote = commentRoom < 90
        let noteWidth = min(150, max(commentRoom - 16, 24))
        let picked = model.isSelectedForMerge(slot.blockID)
        let resolved = model.resolvedTake(column: mainColumn, slot: slot)
        return TakesCellView(
            model: model, tokens: tokens, indicator: indicator,
            slot: slot, column: mainColumn,
            tinted: false, role: "article",
            // 13f W7: the room's landing — nonzero only for the pane it named.
            caretToEndToken: resolved
                .map { model.caretToEndToken(forVariant: $0.variantID) } ?? 0,
            // 13e E3 (her A18): ⌘-click picks this block for a merge. The
            // claim consumes the click, so the ring does not migrate here —
            // picking blocks is not writing in one.
            onCommandClick: { extending in
                // 13e E2: ⌘⇧-click extends the run from the anchor; plain
                // ⌘-click toggles. One gesture, two shades.
                if extending {
                    model.extendMergeSelection(to: slot.blockID)
                } else {
                    model.toggleMergeSelection(slot.blockID)
                }
                return true
            },
            // 18l-c U7: the find's face for the take the article shows.
            findFace: resolved.flatMap {
                model.find.face(forVariant: $0.variantID, tokens: tokens)
            },
            onDiff: { diffPresentation = $0 })
            .padding(Self.articleCellPadding)
            // 18l-c U8 (a): the mode switch's ARRIVAL FLASH on the block the
            // entry landing put home — its fill directly behind the pane (in
            // front of the changing-block wash), its border over the cell's
            // edge below; nothing at all unless an arrival names this row.
            .background {
                if let flash = arrivalFlash(slot) {
                    ArrivalFlashFace(
                        part: .fill, startedAt: flash, plan: flashPlan, tokens: tokens,
                        oracleKey: "takes|\(ObjectIdentifier(model.board.article))|\(slot.placementID)")
                }
            }
            .background(washed && markChangingBlock ? tokens.wash : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay {
                if let flash = arrivalFlash(slot) {
                    ArrivalFlashFace(
                        part: .stroke, startedAt: flash, plan: flashPlan, tokens: tokens,
                        oracleKey: "takes|\(ObjectIdentifier(model.board.article))|\(slot.placementID)")
                }
            }
            // 13e E3: a picked block SAYS it is picked (boundaries are
            // invisible at rest — a selection that shows nothing is the
            // silent-door class).
            .overlay {
                if picked {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(tokens.accent, lineWidth: 2)
                }
            }
            // Batch 14 (her "even when there is a comment, i can't really
            // see the comment anywhere (I suppose it oculd go on the left
            // in the blank area)"): the block's comments in the LEFT
            // margin — the round-2 margin-comment idiom, takes-side.
            .overlay(alignment: .topLeading) {
                CommentMarginNote(
                    session: session, blockID: slot.blockID, tokens: tokens,
                    compact: compactNote)
                    .frame(width: noteWidth, alignment: .topLeading)
                    .offset(x: -(noteWidth + (compactNote ? 4 : 16)))
            }
            // The fan door rides the cell's corner (never its own row) —
            // in an engaged grid bloom the rail's own header carries the
            // close instead (the badge would collide with the rail).
            .overlay(alignment: .topTrailing) {
                if !(model.projection.fanStyle == .marginGrid && bloomed) {
                    fanBadge(slot: slot, bloomed: bloomed)
                        .offset(x: 40)
                }
            }
            // 18l-c U7 (R-18l-10's first half): with "only chosen takes" OFF,
            // the count of matches on takes this block is not showing — in the
            // right margin under the fan badge, never over the prose (R-Q2),
            // and standing down where an engaged margin rail sits (the badge's
            // own rule, for its reason).
            .overlay(alignment: .topTrailing) {
                if !(model.projection.fanStyle == .marginGrid && bloomed),
                   let count = model.find.offScopeCount(forBlock: slot.blockID) {
                    // A ZERO-WIDTH frame at the cell's trailing edge, its content
                    // leading-aligned: the marker can only run out into the
                    // margin. (An `alignmentGuide(.trailing)` here did not take —
                    // the walk found the marker over the prose, pinned red.)
                    TakesFindOffScopeMarker(blockID: slot.blockID, count: count, tokens: tokens)
                        .frame(width: 0, alignment: .leading)
                        .offset(x: 12, y: 24)
                }
            }
    }

    /// **18l-c U8 (a): when the mode switch's arrival flash on this row began**
    /// — nil unless the entry landing's arrival names this row AND her setting
    /// has the flash on (R-18l-7: default ON, a switch to turn it off).
    private func arrivalFlash(_ slot: Queries.RenderedBlock) -> Date? {
        guard themeSettings.arrivalFlash,
              let arrival = model.board.article.articleArrival,
              arrival.placementID == slot.placementID
        else { return nil }
        return arrival.at
    }

    /// The flash's timing on this Mac right now — Reduce Motion's discreet,
    /// unanimated variant when the system asks for it.
    private var flashPlan: ArrivalFlash.Plan {
        ArrivalFlash.plan(reduceMotion: reduceMotion)
    }

    /// STACK: takes stacked under the block. The card's text routes
    /// through the AUTHORITY (13b 1a — the stack style fed panes raw
    /// `take.workingText`, bypassing the live buffers: the frozen-article
    /// class, still live in exactly this style; pinned in
    /// TakesArticleRenderTests's stack extension).
    private func stackBloom(slot: Queries.RenderedBlock) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // VX-170: the takes the bloom draws — a filtered row's expand set
            // (R-VX170-3), the whole fan everywhere else.
            ForEach(model.bloomTakes(slot), id: \.id) { take in
                CollapsibleTakeCard(
                    take: take, text: model.liveText(take),
                    isChosen: take.id == slot.variantID,
                    isLive: paneKeyIsLive(slot: slot, take: take),
                    tokens: tokens, indicator: indicator,
                    onFocus: { focusPane(slot: slot, take: take) },
                    onEdit: { model.paneEdited(variantID: take.id, newText: $0) },
                    onChoose: { Task { await model.choose(blockID: slot.blockID, variantID: take.id) } },
                    // 13e E4: the stack lays its cards out VERTICALLY, so
                    // earlier/later read as ▲ ▼ here.
                    reorder: reorderDoors(take: take, slot: slot, axis: .vertical),
                    // 13u3 UNIT H: the same four acts as every other card.
                    acts: cardActs(take: take),
                    // 18l-c U7: the find's face + a step's landing, as the
                    // other fan cards carry them.
                    caretOnGoingLive: model.find.fanCaretLanding(forVariant: take.id),
                    findFace: model.find.face(forVariant: take.id, tokens: tokens))
            }
            fanFooter(slot: slot)
        }
        .padding(.leading, 24)
    }

    /// CAROUSEL: the WHOLE fan as cards, chosen included and marked
    /// (Sitting 9 batch 7: filtering chosen out made "⑂3" show two cards
    /// with no way to reach the third — the count must match what blooms).
    ///
    /// **13f W8 — HER RULING (2026-07-30):** *"the longer slot split look
    /// works great and I like that it's draggable — but carousel needs the
    /// same treatment."* So carousel now renders at NATURAL FULL HEIGHT by
    /// default with the same shorten-drag, from the same per-block memory:
    /// byte-for-byte `slotSplitBloom`'s composition. **This extends the QoL
    /// round's supersession of S4-31b/N40 to carousel** — the round scoped it
    /// to slot split and pinned carousel's 110 as CHARACTERIZATION; her ruling
    /// retires that scoping and the pin flips with it.
    ///
    /// **The rail strip is deliberately untouched** — she named carousel only.
    private func carouselBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = model.bloomTakes(slot)  // VX-170: the expand set when filtered
        return VStack(alignment: .leading, spacing: 0) {
            pagedTakesRow(
                takes: takes, slot: slot, pageKey: slot.blockID,
                cardHeight: model.slotHeight(slot.blockID), reportsHeight: true)
            slotHeightHandle(slot: slot)
        }
        .padding(.leading, 24)
    }

    /// SLOT SPLIT: the fanned slot divides into an equal split in-flow.
    ///
    /// QoL batch 2 (L3, her report: *"on the slot split mode it's limited
    /// in height - you shoudl be able to see it at full length for that
    /// mode i think. maybe the height of the block should even be
    /// draggable?"*). The cards render at their NATURAL full height by
    /// default — `cardHeight: nil` — and a stored height (her drag) puts
    /// them back into the existing `capped` in-card-scroll machinery.
    /// **This supersedes S4-31b's one-fixed-strip-height rule FOR SLOT
    /// SPLIT ONLY**; carousel and the rail keep it byte-unchanged.
    private func slotSplitBloom(slot: Queries.RenderedBlock) -> some View {
        let takes = model.bloomTakes(slot)  // VX-170: the expand set when filtered
        return VStack(alignment: .leading, spacing: 0) {
            pagedTakesRow(
                takes: takes, slot: slot, pageKey: slot.blockID,
                cardHeight: model.slotHeight(slot.blockID), reportsHeight: true)
            slotHeightHandle(slot: slot)
        }
    }

    /// L3's shorten-drag: the bloom's bottom edge, on the Canvas
    /// `resizeGrip` precedent (live offset while dragging, clamped commit
    /// on end, LOCAL memory per block). Dragging back down to the slot's
    /// natural height restores full length, so undoing a shorten is the
    /// same gesture — the double-click door is the explicit twin.
    ///
    /// 13f W8: carousel shares this handle AND the same per-block store.
    /// Deliberate — it is one question ("how tall should this block's take
    /// cards be"), asked of one geometry (both styles size the same
    /// `pagedTakesRow` cards against the same `beneathCount`) with one natural
    /// height. Two stores would give a block two remembered heights with
    /// nothing on screen to say which one she set.
    private func slotHeightHandle(slot: Queries.RenderedBlock) -> some View {
        let shortened = model.slotHeight(slot.blockID) != nil
        return HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(shortened ? tokens.accent.opacity(0.55) : tokens.faint)
                .frame(width: 44, height: 3)
            if shortened {
                Text(tokens.chromeLabel("shortened — double-click for full length"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onHover { inside in
            if inside { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
        }
        .help("Drag to shorten this block's takes (remembered on this Mac); "
            + "drag back down — or double-click — for full length")
        .gesture(
            // 13e batch 7 (the routed rider): measured in the BOARD's named
            // space, never the handle's own — the handle moves with the
            // height it sets, and a self-moving space feeds its own change
            // back into every translation (batch 5's E12 mechanism, one
            // surface over).
            DragGesture(minimumDistance: 2, coordinateSpace: .named(Self.surfaceSpace))
                .onChanged { value in
                    model.beginSlotDrag(slot.blockID)
                    model.slotDragChanged(slot.blockID, translation: value.translation.height)
                }
                .onEnded { value in
                    model.slotDragEnded(slot.blockID, translation: value.translation.height)
                })
        .onTapGesture(count: 2) { model.resetSlotHeight(slot.blockID) }
    }

    /// MARGIN GRID's rail (R24 + R74): a SHORT fanned block's cards render
    /// one-card-high; longer blocks keep the grid — `gridRows` tall (her
    /// density call) with `gridCols` columns visible, and the row RESERVES
    /// that vertical room so cards get regular space (the post grows —
    /// Sitting 9's push-down ask).
    ///
    /// AD-2 (13b 1a): the rail PAGES DISCRETELY — whole columns, an
    /// explicit ◀ x–y of n ▶ door — instead of the old horizontal
    /// ScrollView, which realized every card but CLIPPED all past the
    /// rail's width with no pager, no scrollbar, no affordance ("takes ·
    /// 4", two cards, half the fan unreachable). The carousel's discrete-
    /// paging grammar (whole cards, never halfway) is now the rail's too.
    private func marginRail(slot: Queries.RenderedBlock) -> some View {
        // VX-170: the takes the bloom draws (a filtered row's expand set).
        let takes = model.bloomTakes(slot)
        let filtered: Bool = {
            if case .filtered = model.rowShape(slot) { return true }
            return false
        }()
        // R24's one-card-high strip for short blocks when density is
        // 1-high; an explicit 2/3-high setting outranks it (batch 14).
        // ONE brain with the keyboard pager (13b 1b): the model answers.
        let rowsPerColumn = model.railRowsPerColumn(slotText: slot.text)
        return VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                // VX-170: a filtered rail counts honestly — the takes it shows
                // OF the fan (R-VX170-2's honest counts).
                Text(filtered
                     ? "takes · \(takes.count) of \(slot.activeVariantCount)"
                     : "takes · \(takes.count)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                // The engaged grid bloom's CLOSE door (the corner badge
                // stands down here — this is where it would collide). Under
                // the `show ▾` filter it is the block's whole-fan door instead
                // (VX-170): "all" on a filtered rail, ✕ back to the filter's
                // shape on an opened one — the badge's own words either way.
                //
                // The U4 walk's W-2: on a filtered rail whose expand set IS the
                // whole fan ("2 of 2"), "all" would reveal nothing — a door that
                // changes nothing she can see is not drawn (P-2).
                if !filtered || takes.count < slot.activeVariantCount {
                    Button(filtered ? tokens.chromeLabel("all") : "✕") {
                        model.toggleExpanded(slot.blockID)
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(model.lensFilter.badgeHelp(slot)
                        ?? CapabilityRegistry.capability(.showTakes)
                            .menuTitle("Close this fan"))
                }
            }
            if takes.isEmpty {
                fanFooter(slot: slot, fitsRail: true)
            } else {
                railCards(takes: takes, slot: slot, rowsPerColumn: rowsPerColumn)
                    .frame(
                        minHeight: rowsPerColumn > 1
                            ? gridReservedHeight(
                                takes: takes, rowsPerColumn: rowsPerColumn)
                            : 0,
                        alignment: .top)
                // Batch 12 (her "i can't make a new take"): the growth
                // doors live BELOW the cards, always on screen (R72's
                // promise; never behind pagination either). VX-136: inside
                // the rail's own width — the one-line row overran a 1-wide
                // rail's cards by ~23 pt, so where it does not fit the two
                // doors stack.
                fanFooter(slot: slot, fitsRail: true)
            }
        }
    }

    /// The rail's card strip — the SCROLL + PAGER HYBRID (13b 4D, S4-24(1),
    /// her ruling: "free horizontal scrolling returns on the fan rail ON
    /// TOP of the pager"). Takes chunk into columns of `rowsPerColumn`;
    /// EVERY column is in the strip (nothing off-edge is undiscoverable —
    /// the AD-2 lesson binds three ways: scroll reaches it, ◀ ▶ reaches
    /// it, the counter names it); the scroll SETTLES onto whole-column
    /// boundaries (viewAligned) and the leading column writes back into
    /// the model's ONE paging brain, so the ◀ x–y of n ▶ counter, the
    /// keyboard pager, and the scroll position agree at rest by
    /// construction.
    private func railCards(
        takes: [Variant], slot: Queries.RenderedBlock, rowsPerColumn: Int
    ) -> some View {
        let columns = stride(from: 0, to: takes.count, by: rowsPerColumn).map {
            Array(takes[$0..<min($0 + rowsPerColumn, takes.count)])
        }
        let pageKey = TakesViewModel.railPageKey(slot.blockID)
        // VX-136: this block's own column count (the pager's brain too).
        let shown = railColumns(slot)
        let limit = max(columns.count - shown, 0)
        let offset = model.pageOffset(pageKey, limit: limit)
        // VX-136: the grid's ROWS — each card stands in its row's slot, so
        // row tops line up across columns (and stay put across pages).
        let rowHeights = model.railRowHeights(takes: takes, rowsPerColumn: rowsPerColumn)
        return VStack(alignment: .leading, spacing: 4) {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 6) {
                    ForEach(Array(columns.enumerated()), id: \.offset) { i, column in
                        VStack(spacing: 6) {
                            ForEach(Array(column.enumerated()), id: \.element.id) { row, take in
                                // QoL batch 2 (L4, her report: the margin
                                // note is "sticky note sized which isn't
                                // that helpful for long blocks"): the card
                                // GROWS with its content to the RULED cap
                                // (330 = three card-heights) and scrolls
                                // inside beyond it. Below the cap nothing
                                // is clipped and nothing is padded — a
                                // one-line take stays a sticky note.
                                // "n high" still means n cards per column
                                // (the chunking above is untouched); only
                                // the pixel arithmetic is variable now.
                                takeMiniPane(
                                    take: take, slot: slot, capped: true,
                                    reportsHeight: true)
                                    .frame(
                                        width: Self.railCardWidth,
                                        height: model.marginCardHeight(variantID: take.id),
                                        alignment: .topLeading)
                                    .clipped()
                                    // VX-136: the card keeps its own height
                                    // (L4); its ROW's slot says where the next
                                    // row starts, the same in every column.
                                    .frame(
                                        height: rowHeights.indices.contains(row)
                                            ? rowHeights[row] : nil,
                                        alignment: .top)
                            }
                        }
                        .frame(width: Self.railCardWidth)
                        .id(i)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(
                id: stripBinding(key: pageKey, limit: limit, ids: Array(columns.indices)),
                anchor: .leading)
            if columns.count > shown {
                let firstShown = offset * rowsPerColumn + 1
                let lastShown = min((offset + shown) * rowsPerColumn, takes.count)
                pagerLine(
                    pageKey: pageKey, limit: limit, offset: offset,
                    caption: "\(firstShown)–\(lastShown) of \(takes.count)")
            }
        }
    }

    /// The shared strip row (carousel + slot split) — the same HYBRID
    /// (S4-24(1)): every take is in the strip, free scrolling settles onto
    /// whole cards, the ◀ ▶ door and the counter ride the one paging
    /// brain. N40 (S4-31b, her ruling): ONE fixed strip height — every
    /// card is exactly one card-height and its content scrolls within, so
    /// the strip never changes height as takes differ or pages turn (the
    /// recorded #28(b) clip cost dissolves into the in-card scroll).
    ///
    /// QoL batch 2 (L3): `cardHeight` FORKS the two callers without
    /// forking the view tree — `frame(height:)` already takes a `CGFloat?`,
    /// so carousel's modifier chain is byte-identical to before (nil is
    /// slot split's full-length default, and `.clipped()` over a natural
    /// frame clips nothing). `reportsHeight` subscribes ONLY the
    /// compositions that size a wrapper, so carousel's invalidation
    /// profile is untouched too.
    private func pagedTakesRow(
        takes: [Variant], slot: Queries.RenderedBlock, pageKey: String,
        cardHeight: CGFloat?, reportsHeight: Bool
    ) -> some View {
        // Offsets live on the MODEL (13b 1a, AD-2's companion move): one
        // paging brain for carousel, slot split, and the rail — and the
        // soak can drive page coverage.
        let limit = max(takes.count - beneathCount, 0)
        let offset = model.pageOffset(pageKey, limit: limit)
        return VStack(alignment: .leading, spacing: 4) {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 6) {
                    ForEach(takes, id: \.id) { take in
                        takeMiniPane(
                            take: take, slot: slot, capped: cardHeight != nil,
                            reportsHeight: reportsHeight)
                            .frame(height: cardHeight, alignment: .topLeading)
                            .clipped()
                            .containerRelativeFrame(
                                .horizontal, count: max(beneathCount, 1), span: 1,
                                spacing: 6)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(
                id: stripBinding(key: pageKey, limit: limit, ids: takes.map(\.id)),
                anchor: .leading)
            if takes.count > beneathCount {
                pagerLine(
                    pageKey: pageKey, limit: limit, offset: offset,
                    caption: "\(offset + 1)–\(min(offset + beneathCount, takes.count)) of \(takes.count)")
            }
            fanFooter(slot: slot)
        }
    }

    /// The hybrid's shared write-back binding (S4-24(1) — the honesty
    /// mechanism, recorded): scrollPosition reads the model's clamped
    /// offset and a settled scroll writes the SAME clamped offset back
    /// (`setPage`) — the counter never lies because it derives from the
    /// exact state the scroll and the ◀ ▶ door both address.
    private func stripBinding<ID: Hashable>(
        key: String, limit: Int, ids: [ID]
    ) -> Binding<ID?> {
        Binding<ID?>(
            get: {
                let offset = model.pageOffset(key, limit: limit)
                return ids.indices.contains(offset) ? ids[offset] : ids.first
            },
            set: { leading in
                guard let leading, let index = ids.firstIndex(of: leading) else { return }
                model.setPage(key, to: index, limit: limit)
            })
    }

    /// The ◀ x–y of n ▶ line (unchanged grammar — the pager door survives
    /// ON TOP of the scroll, per the ruling's letter).
    private func pagerLine(
        pageKey: String, limit: Int, offset: Int, caption: String
    ) -> some View {
        HStack(spacing: 4) {
            Button("◀") { model.stepPage(pageKey, by: -1, limit: limit) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .disabled(offset == 0)
            Text(caption)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Button("▶") { model.stepPage(pageKey, by: 1, limit: limit) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .disabled(offset >= limit)
        }
    }

    /// The bloom's footer (13b Stage 3, 3D): the growth doors + — where
    /// archived takes exist — the archived listing's door (N1: the road
    /// back lives in Takes, right under the fan the take left).
    private func fanFooter(slot: Queries.RenderedBlock, fitsRail: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if fitsRail {
                // VX-136: the margin rail's doors fit its width — one line
                // where the line fits, the two doors stacked where it would
                // overrun the cards (the 1-wide rail is one card wide).
                ViewThatFits(in: .horizontal) {
                    newTakeDoors(slot: slot)
                    newTakeDoors(slot: slot, stacked: true)
                }
                .takeRailGeometryProbe(.doors, blockID: slot.blockID)
            } else {
                newTakeDoors(slot: slot)
            }
            archivedSection(slot: slot)
        }
    }

    /// "archived · n" — a quiet disclosure under the growth doors; open,
    /// it lists the block's archived takes on the one card grammar with
    /// Unarchive (the act, right here) and Delete.
    @ViewBuilder
    private func archivedSection(slot: Queries.RenderedBlock) -> some View {
        if let count = model.archivedCounts[slot.blockID], count > 0 {
            let revealed = model.revealedArchived.contains(slot.blockID)
            VStack(alignment: .leading, spacing: 4) {
                Button(tokens.chromeLabel(
                    "\(revealed ? "▾" : "▸") archived · \(count)")) {
                    model.toggleArchivedRevealed(slot.blockID)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("This block's archived takes — out of the fan, never gone")
                if revealed {
                    ForEach(model.archivedTakes[slot.blockID] ?? [], id: \.id) { take in
                        archivedCard(take: take)
                    }
                }
            }
        }
    }

    private func archivedCard(take: Variant) -> some View {
        TakeCardFrame(isChosen: false, tokens: tokens) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    if let label = take.label {
                        Text(label).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    Text(take.workingText.isEmpty
                         ? "(empty take)" : String(take.workingText.prefix(160)))
                        .font(tokens.small)
                        .lineLimit(3)
                        .foregroundStyle(tokens.muted)
                }
                Spacer()
                Button("Unarchive") { Task { await model.unarchiveTake(take.id) } }
                    .controlSize(.mini)
                    .help("Back into the fan — right here (the fan re-opens with it)")
                Button(TakeCardMenuCopy.deleteTake, role: .destructive) {
                    Task { await model.deleteTake(take.id) }
                }
                .controlSize(.mini)
            }
        }
        .frame(maxWidth: 420, alignment: .leading)
    }

    /// v2's dashed footer — the fan-growth doors (R23: takes are minted
    /// where takes are seen). Minting NEVER chooses (R90); the power
    /// variant lives on the keyboard (⇧⌥⌘T). Under a seal the ops refuse
    /// and the refusal speaks.
    ///
    /// VX-136: `stacked` puts the two doors one above the other (no `·`
    /// between them) — the margin rail's form where the line would overrun
    /// its one-card width. Same doors, same acts, same box.
    private func newTakeDoors(slot: Queries.RenderedBlock, stacked: Bool = false) -> some View {
        let layout = stacked
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 5))
            : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            Button("＋ new take (branch)") {
                guard let from = slot.variantID else { return }
                Task { await model.branchTakeRevealed(blockID: slot.blockID, from: from) }
            }
            .disabled(slot.variantID == nil)
            .help(CapabilityRegistry.capability(.newTake)
                .menuTitle("A new take that starts as a copy of what's shown"))
            if !stacked {
                Text("·").foregroundStyle(tokens.faint)
            }
            Button("＋ blank take") {
                Task { await model.newBlankTakeRevealed(blockID: slot.blockID) }
            }
            .help(CapabilityRegistry.capability(.blankTake)
                .menuTitle("A genuinely different take, from scratch")
                + (CapabilityRegistry.capability(.blankTakeAsChosen).shortcutLabel
                     .map { "; \($0) opens it as chosen" } ?? ""))
        }
        .buttonStyle(.plain)
        .font(tokens.small)
        .foregroundStyle(tokens.muted)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
        // states its own line policy, so its IDEAL width can never be a
        // wrapped one (the b6dae25 class's window-sizing hazard).
        .lineLimit(1)
        .fixedSize()
    }

    /// A take's pane inside a bloom, on the v2-canon card. 13b 3F (N25 +
    /// her grid inputs): choosing is the card's HEADER — one full-width
    /// clickable band ("choose" / "✓ chosen"), never a corner ✓ beside a
    /// "✓ chosen" text (the doubled checkmark), and it costs the text box
    /// no width. `capped` (the rail's fixed-height cards): the content
    /// SCROLLS in place, so no part of the take is unreachable (N23).
    private func takeMiniPane(
        take: Variant, slot: Queries.RenderedBlock, capped: Bool = false,
        reportsHeight: Bool = false
    ) -> some View {
        let isChosen = take.id == slot.variantID
        return TakeCardFrame(isChosen: isChosen, tokens: tokens) {
            VStack(alignment: .leading, spacing: 2) {
                TakeChooseHeader(
                    tokens: tokens, isChosen: isChosen, label: take.label,
                    onChoose: {
                        Task { await model.choose(blockID: slot.blockID, variantID: take.id) }
                    },
                    // 13e E4: carousel, slot split and the rail all lay their
                    // cards out HORIZONTALLY, so earlier/later read as ◀ ▶.
                    reorder: reorderDoors(take: take, slot: slot, axis: .horizontal),
                    // 13u3 UNIT H: the card's four acts, where the take is seen.
                    acts: cardActs(take: take))
                if capped {
                    ScrollView(.vertical) {
                        miniPaneSurface(take: take, slot: slot, reportsHeight: reportsHeight)
                    }
                } else {
                    miniPaneSurface(take: take, slot: slot, reportsHeight: reportsHeight)
                }
            }
        }
    }

    private func miniPaneSurface(
        take: Variant, slot: Queries.RenderedBlock, reportsHeight: Bool = false
    ) -> some View {
        PaneSurfaceView(
            text: model.liveText(take),
            isLive: paneKeyIsLive(slot: slot, take: take),
            tokens: tokens,
            indicator: indicator,
            role: "mini", variantID: take.id,
            onFocusRequest: { focusPane(slot: slot, take: take) },
            onEdit: { model.paneEdited(variantID: take.id, newText: $0) },
            // 18l-c U7: a find step onto this card lands with its match
            // selected (`.leave` on every other road — the shipped END).
            caretOnGoingLive: model.find.fanCaretLanding(forVariant: take.id),
            // QoL batch 2: ONLY margin grid and slot split subscribe — the
            // two compositions that size a wrapper around the pane.
            onMeasuredHeight: reportsHeight
                ? { model.notePaneMeasuredHeight(variantID: take.id, height: $0) }
                : nil,
            // 13f W7: the room's landing reaches a fan card too — a
            // slot-split bloom on the last block has no article cell.
            caretToEndToken: model.caretToEndToken(forVariant: take.id),
            // 18l-c U7: the find's face for this take.
            findFace: model.find.face(forVariant: take.id, tokens: tokens))
    }

    // MARK: - Small helpers

    private var styleName: String {
        switch model.projection.fanStyle {
        case .stack: return "stack"
        case .carousel: return "carousel"
        case .marginGrid: return "margin grid"
        case .slotSplit: return "slot split"
        }
    }

    /// **13u3 UNIT H — the live card's four acts** (her F1 rule: *"Write's
    /// panel ⋯ carries Archive · Label · Lock · Delete — Takes mode's card
    /// grammar must match"*). The targets are NAMED here rather than routed,
    /// for `unarchiveTake`'s reason and 13k K6's: the act belongs to the card
    /// you pointed at, and pointing at a card never moves the keyboard. The
    /// label sheet is hosted by `TakesBottomBar`, which rides this board, so
    /// `requestTakeLabel` opens it from here exactly as it does from Write's
    /// panel. Every refusal — a sealed note, a locked take, the take the note
    /// shows, the block's last take — comes from the operations layer through
    /// `model.run` and speaks (P-2).
    ///
    /// VX-594: the wiring lives on the model now (`TakesViewModel.cardActs`),
    /// ONE copy for this board and Write's panel, since the menu grew its
    /// branch row; the board's cards are the fan namespace's.
    private func cardActs(take: Variant) -> TakeCardActs {
        model.cardActs(for: take, columnID: Self.fanColumnID)
    }

    /// 13e E4 (her A19): the card's fan-order doors, or nil where the act
    /// cannot apply (a one-take fan, or a card whose take has left the fan).
    /// The enablement per direction is the fan's own arithmetic — first card,
    /// no "earlier"; last card, no "later" — the pager's disabled-◀ grammar.
    private func reorderDoors(
        take: Variant, slot: Queries.RenderedBlock, axis: Axis
    ) -> TakeChooseHeader.ReorderDoors? {
        // VX-170 (PROVISIONAL P-VX168-U4-5): a filtered bloom shows a SUBSET of
        // the fan, so its arrows would move a take past takes the filter hides —
        // a press could change nothing she can see, and the first card's
        // "earlier" would point at a hidden take. They stand down there; the
        // whole fan (the badge's door) carries them as ever.
        if case .filtered = model.rowShape(slot) { return nil }
        let fan = model.projection.fans[slot.blockID] ?? []
        guard fan.count > 1, let index = fan.firstIndex(where: { $0.id == take.id })
        else { return nil }
        return TakeChooseHeader.ReorderDoors(
            axis: axis,
            canMoveEarlier: index > 0,
            canMoveLater: index < fan.count - 1,
            move: { delta in
                Task { await model.moveTake(take.id, in: slot.blockID, by: delta) }
            })
    }

    private func paneKeyIsLive(slot: Queries.RenderedBlock, take: Variant) -> Bool {
        model.isPaneLive(
            TakesViewModel.PaneKey(
                columnID: Self.fanColumnID, blockID: slot.blockID, variantID: take.id))
    }

    private func focusPane(slot: Queries.RenderedBlock, take: Variant) {
        model.focus(TakesViewModel.PaneKey(
            columnID: Self.fanColumnID, blockID: slot.blockID, variantID: take.id))
    }
}

// MARK: - The choose header (13b 3F — N25 + her grid design inputs)

/// The card's chosen-marking as a clickable HEADER: "choose" marks the
/// take chosen; the chosen card reads "✓ chosen" (the ONE checkmark).
/// Full-width band — the text box below keeps its whole width.
struct TakeChooseHeader: View {
    let tokens: VoiceTokens
    let isChosen: Bool
    let label: String?
    let onChoose: () -> Void
    /// **13e E4 (her A19) — the fan-order doors on the card itself.** nil is
    /// the default, so every pre-13e renderer of this header reads unchanged
    /// and a one-take fan draws no arrows at all (P-2: a door that could
    /// never act isn't rendered).
    var reorder: ReorderDoors?
    /// **13u3 UNIT H — the card's ⋯ act menu.** nil by default for the same
    /// reason as `reorder`: a host that passes nothing renders exactly what
    /// it did before. Every live-card composition on the Takes board passes
    /// it, which is how one addition reaches all four fan styles.
    var acts: TakeCardActs?

    /// The band's act sentences — byte-identical to what the band said before
    /// VX-352's fix leg (a take with no label still hears exactly these).
    static let chooseHelp = "Choose this take — the note shows it (everywhere); ⌘⏎ from the keyboard"
    static let chosenHelp = "The note shows this take (everywhere)"

    /// **The band's ONE hover** (VX-352 fix leg 2a-F2): the whole label on its
    /// own line, then the act's sentence (`TakeLabelFace.hover`, pure).
    static func bandHelp(isChosen: Bool, label: String?) -> String {
        TakeLabelFace.hover(label: label, act: isChosen ? chosenHelp : chooseHelp)
    }

    /// What the card needs to offer the two moves: which way its strip runs,
    /// whether each direction can act (the FIRST card cannot move earlier —
    /// the pager's disabled-◀ grammar), and the act itself.
    struct ReorderDoors {
        let axis: Axis
        let canMoveEarlier: Bool
        let canMoveLater: Bool
        /// −1 = earlier, +1 = later.
        let move: (Int) -> Void
    }

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onChoose) {
                HStack(spacing: 4) {
                    Text(tokens.chromeLabel(isChosen ? "✓ chosen" : "choose"))
                        .font(tokens.small)
                        .foregroundStyle(isChosen ? tokens.chosen : tokens.muted)
                    if let label {
                        // VX-352 (PROVISIONAL MB-4): a narrow card keeps the
                        // label's own words and lets the client's name yield
                        // (`TakeLabelFace`, pure); the whole label rides the
                        // band's one hover (`bandHelp`, below).
                        TakeLabelLine(label: label, tokens: tokens)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isChosen)
            // VX-352 fix leg 2a-F2 (MB-4's hover half, PROVISIONAL): the band's
            // ONE hover carries the whole label, then the choose sentence —
            // a `.help` on the label inside this button was subsumed by it.
            .help(Self.bandHelp(isChosen: isChosen, label: label))
            if let reorder {
                Button(reorder.axis == .vertical ? "▲" : "◀") { reorder.move(-1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .disabled(!reorder.canMoveEarlier)
                    .help(CapabilityRegistry.capability(.moveTakeEarlier).verb
                        + " — one place \(reorder.axis == .vertical ? "up" : "left") in this "
                        + "block's fan (⌥⌘Z undoes)")
                Button(reorder.axis == .vertical ? "▼" : "▶") { reorder.move(1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .disabled(!reorder.canMoveLater)
                    .help(CapabilityRegistry.capability(.moveTakeLater).verb
                        + " — one place \(reorder.axis == .vertical ? "down" : "right") in this "
                        + "block's fan (⌥⌘Z undoes)")
            }
            if let acts {
                TakeCardMenu(acts: acts)
                    .help("This take's own acts — archive, label, lock, delete")
            }
        }
    }
}

// MARK: - The v2-canon card frame (Stage C2's grammar: card paper +
// takeLine border + the 3pt chosen leading bar)

struct TakeCardFrame<Content: View>: View {
    let isChosen: Bool
    let tokens: VoiceTokens
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.vertical, 5)
            .padding(.horizontal, 7)
            // The 3 pt the bar's own column used to occupy in the HStack, so
            // the content's leading edge does not move.
            .padding(.leading, 3)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(tokens.card)
            // 17o batch c, ledger row 14 (her punchlist 11: "the chosen
            // green line doesn't go all the way down", image 6). The bar
            // used to be an HStack SIBLING of the content, so it was sized
            // against the height the stack had RESOLVED — which, beside a
            // pane whose measured height publishes on a later turn, is the
            // pane's PREVIOUS height. An overlay is laid out against the
            // finished card instead, so the bar is the card's height by
            // construction, whenever the pane settles and however often.
            .overlay(alignment: .leading) {
                (isChosen ? tokens.chosen : Color.clear)
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
                    .takeCardGeometryProbe(.chosenBar)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.takeLine, lineWidth: 1))
            .takeCardGeometryProbe(.card)
            .coordinateSpace(name: TakeCardProbeSlot.space)
    }
}

/// The row-14 oracle's slots, and the card's own coordinate space (a
/// non-generic home, so the probe can name it without `TakeCardFrame`'s
/// `Content`).
enum TakeCardProbeSlot: Hashable {
    case card
    case chosenBar

    static let space = "take-card"
}

#if DEBUG
/// **SCOPED BY THE MOUNTING SESSION, AND BOUNDED** (13u2 UNIT E —
/// KnownIssues row 50, and row 47's second oracle-hygiene item).
///
/// Two defects, one rewrite. **(1) Parallel suites:** a process-global list
/// here took every board's cards in the process, so a pin's `tallest` could
/// be another suite's card — a green pin that proved nothing. The scope
/// travels by environment (`DebugProbeScope.swift`); a pin reads its own
/// session's. **(2) Append-only:** the list was pruned only by two `reset()`
/// calls in one suite and otherwise grew for a DEBUG process's whole life.
/// It is bounded now, per scope, dropping the OLDEST — and a scope's row
/// goes when the pin that owns it resets.
@MainActor
enum TakeCardGeometry {
    /// Per scope: EVERY report, in arrival order — a board draws many cards,
    /// and a last-one-wins dictionary would let a short card's numbers stand
    /// in for the long one the pin is about.
    private static var worlds: [String: [(slot: TakeCardProbeSlot, frame: CGRect)]] = [:]

    /// The bound. A board reports tens of times, not hundreds; this is big
    /// enough that no pin can reach it and small enough that a DEBUG process
    /// left running cannot grow without end. Oldest out, because the
    /// questions asked here are about the CURRENT board.
    static let reportLimit = 512

    static func record(_ slot: TakeCardProbeSlot, _ frame: CGRect, in scope: String) {
        worlds[scope, default: []].append((slot, frame))
        if var row = worlds[scope], row.count > reportLimit {
            row.removeFirst(row.count - reportLimit)
            worlds[scope] = row
        }
    }

    /// A pin's OWN board — every read below is this session's mount.
    @MainActor
    struct Reader {
        let scope: String

        var reports: [(slot: TakeCardProbeSlot, frame: CGRect)] {
            TakeCardGeometry.worlds[scope] ?? []
        }

        func latest(_ slot: TakeCardProbeSlot) -> CGRect? {
            reports.last { $0.slot == slot }?.frame
        }

        /// The TALLEST card reported, and the tallest bar — a board pin asks
        /// about the long card, whichever order SwiftUI reported them in.
        func tallest(_ slot: TakeCardProbeSlot) -> CGRect? {
            reports.filter { $0.slot == slot }.map(\.frame).max { $0.height < $1.height }
        }

        /// A pin resets before its mount, so a stale report can never satisfy
        /// it — its OWN scope and no other.
        func reset() { TakeCardGeometry.worlds[scope] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}

/// The probe, as a modifier rather than a bare `onGeometryChange`, because it
/// must READ the environment for its scope — which is also why the sweep did
/// not have to thread an argument through `TakeCardFrame`, a generic value
/// view with dozens of construction sites and no session of its own.
private struct TakeCardGeometryProbe: ViewModifier {
    let slot: TakeCardProbeSlot
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(TakeCardProbeSlot.space))
        } action: { TakeCardGeometry.record(slot, $0, in: scope) }
    }
}
#endif

/// VX-136's oracle slots — the margin rail and its new-take doors (a
/// non-DEBUG home, so the probe's signature compiles everywhere; the
/// `TakeCardProbeSlot` precedent).
enum TakeRailProbePart: String, Hashable {
    case rail, doors
}

#if DEBUG
/// **VX-136's oracle — the margin rail and its new-take doors, in the
/// window.** Her report names the doors (*"the new take area"*) against the
/// cards, so the pin compares two rectangles: the rail's own frame and the
/// doors' box under it. Scoped by the mounting session like
/// `TakeCardGeometry` (parallel suites never read each other's), keyed by the
/// block, last report wins (a block has one rail).
@MainActor
enum TakeRailGeometry {
    typealias Part = TakeRailProbePart

    private static var worlds: [String: [String: CGRect]] = [:]

    static func record(_ part: Part, blockID: String, _ frame: CGRect, in scope: String) {
        worlds[scope, default: [:]]["\(blockID)|\(part.rawValue)"] = frame
    }

    static func frame(_ part: Part, blockID: String, in scope: String) -> CGRect? {
        worlds[scope]?["\(blockID)|\(part.rawValue)"]
    }

    /// A pin resets ITS OWN scope before its mount, and no other.
    static func reset(_ scope: String) { worlds[scope] = nil }
}

private struct TakeRailGeometryProbe: ViewModifier {
    let part: TakeRailProbePart
    let blockID: String
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
            TakeRailGeometry.record(part, blockID: blockID, $0, in: scope)
        }
    }
}
#endif

extension View {
    /// VX-136's oracle write (a no-op outside DEBUG).
    @ViewBuilder
    func takeRailGeometryProbe(_ part: TakeRailProbePart, blockID: String) -> some View {
        #if DEBUG
        self.modifier(TakeRailGeometryProbe(part: part, blockID: blockID))
        #else
        self
        #endif
    }

    /// The DEBUG oracle write: this view's frame in the card's own
    /// coordinate space. A no-op outside DEBUG (the `LensesGeometry`
    /// pattern, one surface over).
    @ViewBuilder
    func takeCardGeometryProbe(_ slot: TakeCardProbeSlot) -> some View {
        #if DEBUG
        self.modifier(TakeCardGeometryProbe(slot: slot))
        #else
        self
        #endif
    }
}

// MARK: - The collapsible stack card (round 2: quick expand/collapse)

private struct CollapsibleTakeCard: View {
    let take: Variant
    /// The AUTHORITY-resolved display text (13b 1a): the card never reads
    /// `take.workingText` directly — that was the stack style's liveness
    /// bypass (a dirty edit showed stale store text in read cards).
    let text: String
    let isChosen: Bool
    let isLive: Bool
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): carried down to the pane, decided nowhere here.
    let indicator: EditingIndicatorStyle
    let onFocus: () -> Void
    let onEdit: (String) -> Void
    let onChoose: () -> Void
    /// 13e E4: the fan-order doors, forwarded to the header.
    var reorder: TakeChooseHeader.ReorderDoors?
    /// 13u3 UNIT H: the card's four acts, forwarded the same way — the stack
    /// style's card is the one live-card shape that is not `takeMiniPane`.
    var acts: TakeCardActs?
    /// 18l-c U7: a find step's landing and the find's face, forwarded to the
    /// pane exactly as `takeMiniPane` hands them over.
    var caretOnGoingLive: PaneCaretLanding = .leave
    var findFace: PaneFindFace?
    @State private var collapsed = false

    var body: some View {
        TakeCardFrame(isChosen: isChosen, tokens: tokens) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Button(collapsed ? "▸" : "▾") { collapsed.toggle() }
                        .controlSize(.mini)
                        .buttonStyle(.plain)
                    // 13b 3F (N25's grammar, unified): choosing is the
                    // header band here too — one checkmark, ever.
                    TakeChooseHeader(
                        tokens: tokens, isChosen: isChosen, label: take.label,
                        onChoose: onChoose, reorder: reorder, acts: acts)
                }
                if collapsed {
                    Text(text.split(separator: "\n").first.map(String.init) ?? "(empty)")
                        .font(.callout)
                        .lineLimit(1)
                        .foregroundStyle(tokens.muted)
                        .onTapGesture { collapsed = false }
                } else {
                    PaneSurfaceView(
                        text: text, isLive: isLive, tokens: tokens,
                        indicator: indicator,
                        role: "card", variantID: take.id,
                        onFocusRequest: onFocus, onEdit: onEdit,
                        caretOnGoingLive: caretOnGoingLive,
                        findFace: findFace)
                }
            }
        }
    }
}

#if DEBUG
/// **R-Q2's second oracle: where the article's ＋ new block door actually is.**
/// The door is a SwiftUI `Button` — drawn, never mounted as an `NSView` — and
/// a hosted board builds no accessibility tree in the test host (measured at
/// 17p batch a), so the door reports its own frame, in WINDOW space, and the
/// pin compares that x against the real pane's real text origin. The
/// `LensesGeometry` pattern.
@MainActor
enum TakesArticleDoorProbe {
    // **18k UNIT C4 — the frame NAMES ITS OWNER** (the rule and its reasons:
    // `Core/Views/DebugOracleOwnership.swift`): the door itself registers
    // (`ArticleDoorProbe`'s own token) and takes its frame with it when it
    // leaves. A bare static every board overwrote — after one window closed
    // the door stood where ITS door had been (measured red,
    // `DebugOracleTwoWindowTests`).
    private static var frameSlot = OwnedSlot<CGRect>()

    static var frame: CGRect? { frameSlot.value }

    static func record(_ frame: CGRect, owner: UUID) { frameSlot.publish(frame, owner: owner) }

    /// A door leaving: its own frame, and no other window's.
    static func release(owner: UUID) { frameSlot.release(owner: owner) }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() { frameSlot.forget() }
}

/// The door's registration as a modifier, for ONE reason (13u4 UNIT S2's
/// `CatalogStampRecorder`): a modifier can hold the `@State` token that says
/// who is registering; a chained `onGeometryChange` has nowhere to keep one.
private struct ArticleDoorProbe: ViewModifier {
    @State private var owner = UUID()

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { frame in
                TakesArticleDoorProbe.record(frame, owner: owner)
            }
            .onDisappear { TakesArticleDoorProbe.release(owner: owner) }
    }
}
#endif

extension View {
    /// The DEBUG oracle write (a no-op outside DEBUG).
    @ViewBuilder
    func articleDoorProbe() -> some View {
        #if DEBUG
        self.modifier(ArticleDoorProbe())
        #else
        self
        #endif
    }
}
