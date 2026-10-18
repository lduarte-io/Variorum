//
//  CanvasView.swift
//  Variorum
//
//  Phase 11, Step A7 — the sticky-notes canvas (AppSpec §12), pools first.
//  Blocks-as-cards over `canvas_layout`: a drag's END is ONE
//  `setCanvasPosition` (metadata CAS — a two-device race converges to
//  either position, pinned in core); layout rows tombstone with their
//  block/container (the A1 triggers).
//
//  Phase 13, Stage C3 (R40) — canvas is a VIEW you open on a post or the
//  scraps; fanned cards carry the MINIMAL takes switcher. Taste checkpoint
//  (R88, #28e): ‹ › is VIEW-LOCAL — chosen moves only through the explicit
//  ✓; picks persist per canvas and are savable as a lens. Movement is FREE
//  (negative coordinates legal; the board renders origin-shifted).
//
//  Phase 13b, Stage 4 (4E — N30/S4-7, built to the Batch 4E Phase-1
//  ruling; the model half is CanvasViewModel.swift, the geometry brain is
//  CanvasBoardGeometry.swift):
//  - cards realize LAZILY (the ForEach renders the model's culled set —
//    the P1 bound; the DEBUG materialization counter pins it, the
//    ReadingFlow precedent);
//  - cards are EDITABLE PaneSurface panes over the ONE authority (this
//    retires Canvas's slice of the fourth text path — ReadingFlow is the
//    recorded remainder);
//  - the HEADER STRIP is the grab region (the 3A drag-in-text note: a
//    drag in card text selects text — the NSTextView owns those events);
//  - cards RESIZE from the bottom-right grip (size = local view memory);
//  - the block-order NUMBER sits bottom-right (read-time derived);
//  - CLICK-IN-ORDER mode: panes suspend, clicks number the cards, ONE
//    confirm reorders the post (⌥⌘Z undoes), cancel inert;
//  - FIT-ALL: small boards scroll into view; larger boards enter the
//    read-only OVERVIEW (silhouette cards — cheap by construction, so the
//    realization bound survives the zoom; clicks return to 1:1 centered,
//    or assign sequence numbers while ordering — the γ rider).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

#if DEBUG
/// The 4E realization pin's hosted half (the ReadingFlow precedent):
/// counts card-content materializations so the culling pin can assert a
/// long post's mount realizes a bounded set (the pre-4E eager ForEach
/// realized every card — red on revert).
@MainActor
enum CanvasCardMaterialization {
    static var count = 0
}

/// 13e E7's half of the same pin: the bank strip's chips ride a
/// `LazyHStack`, so a canvas whose every card is unplaced renders its
/// WINDOW, never the corpus (the brief's bounded-realization rule — the
/// bank is a face over the same culling, not an escape from it).
@MainActor
enum CanvasBankChipMaterialization {
    static var count = 0
}
#endif

struct CanvasView: View {
    let session: AppSession
    let containerID: String
    /// Post canvases offer 💾 save-picks-as-lens; a pool has no lens home.
    var offersLensSave = true

    /// 13e E12 — THE canvas's drag measuring space, named on the whole
    /// surface (top strip · board · bank strip), so every drag reports
    /// against something the drag itself cannot move.
    ///
    /// The mechanism this exists for, measured (13e batch 5): a
    /// `DragGesture()` in the DEFAULT (`.local`) space measures against the
    /// gesture view's own frame — and that frame is displaced by the very
    /// `.offset` (or size) the drag's own translation applies. Each event's
    /// translation is therefore `pointerDelta − alreadyAppliedOffset`, which
    /// converges to HALF the pointer's travel and alternates step/stall:
    /// her *"they jitter while moving and seemingly resist moving"*. A space
    /// the drag does not move removes the feedback term entirely.
    static let surfaceSpace = "variorum-canvas-surface"
    @State private var model: CanvasViewModel
    @State private var lensPromptShown = false

    /// 13b 4D (N32(c) — S4-15): the card's "Tags…" — app-wide it was the
    /// ONE tag door; now registry-declared with its scrap-row siblings.
    /// 13e E7 adds the bank's two doors (the strip's toggle in the top
    /// strip; the card's own "Return to Bank" row).
    static let surfaceCapabilities: [CapabilityID] = [
        .tagBlock, .toggleCanvasBank, .returnCardToBank,
    ]

    init(
        session: AppSession, containerID: String, offersLensSave: Bool = true,
        model: CanvasViewModel? = nil
    ) {
        self.session = session
        self.containerID = containerID
        self.offersLensSave = offersLensSave
        let resolved = model ?? CanvasViewModel(session: session, containerID: containerID)
        resolved.loadViewMemory()
        _model = State(initialValue: resolved)
    }

    @State private var tagSheetBlock: TagSheetBlock?
    /// C3 (R40): the ONE open takes switcher — minimal by design (opening
    /// another card's closes this one).
    @State private var switcherBlockID: String?
    /// 13b 1b: the routed-command registration's lifecycle token.
    @State private var commandToken: UUID?
    /// A one-shot programmatic scroll target (board coordinates): the
    /// fit-all scroll and the overview's click-to-return land through a
    /// positioned marker + ScrollViewReader (the API-conservative road —
    /// recorded judgment call; ScrollPosition stays available if this
    /// ever proves insufficient).
    @State private var scrollTarget: CGPoint?
    /// Where the marker lands in the viewport: the centre for a card
    /// landing; the top-leading corner for the arrival's overview (row 88 —
    /// the fitted content still opened with its top rows above the
    /// viewport, the 2-axis scroll view's own start).
    @State private var scrollAnchor: UnitPoint = .center
    /// Row 88(a) (R-cor-11(3)): whether this canvas has already been
    /// landed on arrival — once per mount.
    @State private var arrivalFitted = false
    #if DEBUG
    /// **This canvas's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape). DEBUG-only.
    @State private var oracleOwner = UUID()
    #endif
    /// The chip under the pointer while dragging out of the bank (the
    /// ghost's whole state — nothing model-side moves until the drop).
    @State private var bankDrag: BankDrag?
    /// The voice reaches the canvas (optional environment, terminal
    /// fallback — the established pattern).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
    }

    struct TagSheetBlock: Identifiable {
        let id: String
        let preview: String?
    }

    /// A bank chip mid-drag: which card, and where the pointer is in the
    /// surface space.
    struct BankDrag: Equatable {
        let blockID: String
        let point: CGPoint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topStrip
            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical]) {
                    board
                }
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named(Self.surfaceSpace))
                } action: { rect in
                    model.noteBoardViewport(rect)
                }
                .onScrollGeometryChange(for: CGRect.self, of: { $0.visibleRect }) { _, rect in
                    // The model culls in BOARD coordinates; the content
                    // renders origin-shifted (and overview-scaled), so
                    // shift the report back before it feeds the brain.
                    let origin = boardOrigin
                    let scale = model.overviewScale ?? 1
                    model.noteVisibleRect(
                        CGRect(x: rect.origin.x / scale + origin.x,
                               y: rect.origin.y / scale + origin.y,
                               width: rect.width / scale,
                               height: rect.height / scale))
                }
                .onChange(of: scrollTarget) { _, target in
                    guard target != nil else { return }
                    // The marker renders this pass; scroll on the next
                    // turn, then clear (one-shot).
                    DispatchQueue.main.async {
                        proxy.scrollTo("canvas-scroll-marker", anchor: scrollAnchor)
                        DispatchQueue.main.async {
                            scrollTarget = nil
                            scrollAnchor = .center
                        }
                    }
                }
            }
            if model.bankOpen {
                bankStrip
            }
        }
        .coordinateSpace(.named(Self.surfaceSpace))
        .overlay(alignment: .topLeading) { bankGhost }
        .background(tokens.room)
        .task { await model.start() }
        .task { await model.startTags() }
        // Row 88(a) (R-cor-11(3)): a FIRST arrival with no remembered
        // layout opens FIT-ALL — never mid-bank. The orchestrator's walk
        // found the 215-card story opening with the viewport somewhere in
        // the middle of its spread grid (rows 97–162, the edges clipped,
        // `fit all` a click away): a 2-axis scroll view's own initial
        // position, not a landing of ours. Now a canvas whose store holds
        // NO card position lands through the fit-all door as its
        // projection arrives — small boards scroll to their bounds' centre
        // at 1:1, big ones open the read-only overview (a click lands on a
        // card). A board with a remembered layout is left as it was.
        // Ladder R1-14: the arrival waits for the VIEWPORT to report — the
        // centre-vs-origin decision used to run against the 1200 × 800
        // fallback when `visibleRect` was still empty (it is, on arrival), so
        // a board that fits the real viewport landed top-left, and one that
        // fits 1200 × 800 but not a smaller real viewport landed centred with
        // its edges clipped — the mid-bank symptom in miniature.
        .onChange(of: model.projection.cards.count, initial: true) { _, _ in
            landOnArrivalIfReady()
        }
        .onChange(of: model.visibleRect.isEmpty) { _, _ in
            landOnArrivalIfReady()
        }
        .sheet(item: $tagSheetBlock) { target in
            // Row 45: the canvas keeps the DEFAULT noun deliberately — it is
            // opened on a note or on the scraps area and holds no fact that
            // says which, so a word chosen here would be right half the time
            // (PROVISIONAL, QUESTIONS #133).
            BlockTagAssignmentSheet(
                session: session, blockID: target.id, preview: target.preview)
        }
        .sheet(isPresented: $lensPromptShown) {
            LensNameSheet(title: "Save this canvas's takes as a lens") { name in
                Task { await model.saveViewPicksAsLens(name: name) }
            }
        }
        .onAppear {
            // 13b 1b (P-4): registered handler, not a notification. The
            // canvas handles the switcher's step/choose (speaking with no
            // switcher open) and — 4E, the ruling's (c)(2) — ⌘S commits
            // the live pane's take (the 4D compare precedent, third
            // surface). Everything else falls through to the router's
            // honest note.
            commandToken = session.commandRouter.registerHandler { command in
                switch command {
                case .commit:
                    // 13u3 UNIT D: ⌘S summons the optional name (the strip
                    // hosts the field — this board renders no commit door).
                    model.askSavepointName()
                    return true
                case .takes(.stepPrev), .takes(.stepNext), .takes(.choose):
                    guard let open = switcherBlockID else {
                        model.refuse(
                            "Open a card's ‹ › switcher first — stepping and choosing act on it.")
                        return true
                    }
                    switch command {
                    case .takes(.stepPrev): model.switchTake(blockID: open, delta: -1)
                    case .takes(.stepNext): model.switchTake(blockID: open, delta: 1)
                    default: Task { await model.chooseViewedTake(blockID: open) }
                    }
                    return true
                default:
                    return false
                }
            }
        }
        .onDisappear {
            if let commandToken {
                session.commandRouter.unregisterHandler(commandToken)
            }
            model.teardown()
            #if DEBUG
            // 18k C4: this canvas's arrival, and no other window's.
            CanvasArrivalOracle.release(owner: oracleOwner)
            #endif
        }
    }

    // MARK: - The top strip

    /// **Row 88(b) (the Act 10 correction round, batch G — R-cor-11(3)):
    /// the strip in the calm-chip grammar.** It mixed grammars — a "Tag
    /// filter" LABEL beside a system popup reading "tag filter: all", system
    /// buttons beside calm chips (the orchestrator's walk, both voices).
    /// One chip per control now, in `VoiceControls`'s vocabulary (P-8: THE
    /// chrome vocabulary); the redundant label is dropped — the menu's own
    /// face says what it is; the Blocks tool row's container (card, a
    /// bottom line).
    private var topStrip: some View {
        HStack(spacing: 10) {
            // 13b 4D (N32(b) — S4-8b): the filter NAMES itself a tag
            // filter and its help de-blurs the model — a LABEL filter,
            // never a container switch.
            VoicedMenu(tokens: tokens, label: tagFilterLabel, role: .quiet) {
                Button("all tags") { Task { await model.applyFilter(tagID: nil) } }
                ForEach(model.allTags, id: \.id) { tag in
                    Button("#\(tag.path)") { Task { await model.applyFilter(tagID: tag.id) } }
                }
            }
            .help("Show only cards wearing a tag — a LABEL filter, not a pool: "
                + "pools are containers (a block lives in exactly one); tags are "
                + "labels (a block can wear many). Every card stays where it lives.")

            if model.overviewActive {
                VoicedChip(tokens: tokens, text: "back to 1:1", on: true) { model.exitOverview() }
                    .help("Leave the overview — or click any card to land on it")
            } else {
                VoicedChip(tokens: tokens, text: "fit all") { handleFitAll() }
                    .help("See every card at once — small boards scroll into "
                        + "view; big boards open a read-only overview")
            }

            // 13e E7 — the bank's door. It appears when there is something
            // to park or somewhere parked: on a fully-arranged board with
            // the bank closed there is nothing for it to say (P-2).
            if model.bankOpen || !model.bankCards.isEmpty {
                VoicedChip(
                    tokens: tokens,
                    text: model.bankOpen
                        ? "hide bank"
                        : "\(CapabilityRegistry.capability(.toggleCanvasBank).verb) · \(model.bankCards.count)",
                    on: model.bankOpen
                ) {
                    model.toggleBank()
                }
                .help("Cards you haven't placed wait in the bank — drag one out "
                    + "to put it where you drop it, or drop a placed card back in")
            }

            // S4-7f — the ONE spatial→structural door: explicit mode,
            // numbered preview, one confirm, ⌥⌘Z undoes, cancel inert.
            if model.orderMode {
                Text(tokens.chromeLabel(
                    "click cards in reading order — \(model.orderSequence.count) numbered"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                Button(tokens.chromeLabel("apply order")) { Task { await model.applyOrder() } }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                    .disabled(model.orderSequence.isEmpty)
                    .help("The numbered cards lead the note in click order; "
                        + "everything else keeps its relative order after them (⌥⌘Z undoes)")
                Button(tokens.chromeLabel("cancel")) { model.cancelOrderMode() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            } else {
                VoicedChip(tokens: tokens, text: "order by clicking…") { model.enterOrderMode() }
                    .help("Click cards in the order the note should read — "
                        + "one confirm reorders the note; the spatial arrangement never moves")
            }

            Spacer()
            if offersLensSave, !model.viewPicks.isEmpty {
                // R88: the canvas's picks are a lens-shaped arrangement —
                // keep them.
                VoicedChip(tokens: tokens, text: "save picks as lens…") { lensPromptShown = true }
                    .help("This canvas's viewed takes become a named lens — "
                        + "open it in Lenses, adopt it, or promote it later")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .bottom) { Divider().overlay(tokens.line) }
        // 13u3 UNIT D (item 14): the commit door's optional name hangs at
        // the strip's leading edge — this board's only commit door is ⌘S
        // itself, so the field needs a home with a place on screen. An
        // OVERLAY, never a child: a zero-WIDTH child still takes the
        // stack's spacing, which moved Compare's toolbar 8 pt and was caught
        // by its one-left-edge pin (the same mistake, one file over).
        .overlay(alignment: .topLeading) {
            Color.clear
                .frame(width: 0, height: 0)
                .savepointNameAsk(
                    Binding(get: { model.savepointAsk }, set: { model.savepointAsk = $0 }),
                    tokens: tokens, arrowEdge: .bottom
                ) { pending, name in
                    // VX-347: the take ⌘S ASKED about, whichever way the field was left.
                    Task { await model.fileSavepoint(pending, named: name) }
                }
        }
        // 13b 1b (AD-14): outcomes speak through the ONE shell toast.
    }

    /// The tag filter's own face: the chosen tag's path, else "tag filter: all".
    private var tagFilterLabel: String {
        if let id = model.filterTagID, let tag = model.allTags.first(where: { $0.id == id }) {
            return "#\(tag.path)"
        }
        return "tag filter: all"
    }

    // MARK: - The bank (13e E7)

    /// The parking strip: the cards the store has no position for. It is a
    /// FACE over the same culling — chips realize lazily, so a canvas whose
    /// every card is unplaced renders its window, never the corpus.
    private var bankStrip: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text("bank · \(model.bankCards.count)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Text(model.orderMode
                     ? "click a card to number it, here or on the board"
                     : "drag a card onto the board to place it — drop a placed card here to unplace it")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Button("hide") { model.toggleBank() }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            if model.bankCards.isEmpty {
                Text("every card is placed — drop one here to park it again")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 6) {
                        ForEach(model.bankCards, id: \.block.placementID) { item in
                            bankChip(item)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(height: 60)
            }
        }
        .padding(6)
        .background(tokens.wash)
        .overlay(alignment: .top) { Rectangle().fill(tokens.line).frame(height: 1) }
        .contentShape(Rectangle())
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(Self.surfaceSpace))
        } action: { rect in
            model.noteBankRect(rect)
        }
    }

    private func bankChip(_ item: Queries.PoolItem) -> some View {
        #if DEBUG
        CanvasBankChipMaterialization.count += 1
        #endif
        let blockID = item.block.blockID
        let pending = model.pendingOrderNumber(blockID: blockID)
        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("⠿")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                if let pending {
                    Text("\(pending)")
                        .font(tokens.small.bold())
                        .foregroundStyle(tokens.accent)
                }
                Spacer(minLength: 0)
            }
            Text(bankPreview(item))
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(6)
        .frame(width: 150, height: 52, alignment: .topLeading)
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(
            pending == nil ? tokens.takeLine : tokens.accent,
            lineWidth: pending == nil ? 1 : 2))
        .opacity(bankDrag?.blockID == blockID ? 0.35 : 1)
        .contentShape(Rectangle())
        .help("Drag onto the board to place this card where you drop it")
        .gesture(
            // The surface space again (E12): a chip that follows the
            // pointer must be measured against something the drag doesn't
            // move — and the SAME space carries the drop test below.
            DragGesture(coordinateSpace: .named(Self.surfaceSpace))
                .onChanged { value in
                    bankDrag = BankDrag(blockID: blockID, point: value.location)
                }
                .onEnded { value in
                    bankDrag = nil
                    guard case .board(let point) =
                        model.dropTarget(atSurface: value.location) else { return }
                    Task { await model.placeFromBank(blockID: blockID, at: point) }
                })
        .onTapGesture {
            // Order mode reaches the bank too (the overview's γ rider, one
            // surface over): a banked card is never stranded outside the
            // ONE spatial→structural door.
            if model.orderMode { model.toggleOrderClick(blockID: blockID) }
        }
        .contextMenu {
            Button("Place on the board") {
                Task {
                    await model.placeFromBank(
                        blockID: blockID, at: model.restingPosition(blockID: blockID))
                }
            }
            Button("Tags…") {
                tagSheetBlock = CanvasView.TagSheetBlock(id: blockID, preview: item.block.text)
            }
        }
    }

    private func bankPreview(_ item: Queries.PoolItem) -> String {
        let text = (item.block.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "· · ·" : String(text.prefix(90))
    }

    /// The dragged chip under the pointer — view-local, hit-testing off, so
    /// it can never intercept its own drop.
    @ViewBuilder
    private var bankGhost: some View {
        if let bankDrag,
           let item = model.bankCards.first(where: { $0.block.blockID == bankDrag.blockID }) {
            Text(bankPreview(item))
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .padding(6)
                .frame(width: 150, height: 52, alignment: .topLeading)
                .background(tokens.card)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(tokens.accent, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
                .offset(x: bankDrag.point.x - 75, y: bankDrag.point.y - 26)
                .allowsHitTesting(false)
        }
    }

    /// Row 88(a) + ladder R1-14: a never-arranged canvas lands through the
    /// fit-all door once BOTH its projection and its viewport have arrived.
    private func landOnArrivalIfReady() {
        guard !model.visibleRect.isEmpty,
              CanvasArrival.fitsAllOnArrival(
                cards: model.projection.cards.count,
                storedPositions: model.projection.positions.count,
                alreadyFitted: arrivalFitted)
        else { return }
        arrivalFitted = true
        handleFitAll(onArrival: true)
    }

    private func handleFitAll(onArrival: Bool = false) {
        let viewport = model.visibleRect.isEmpty
            ? CGSize(width: 1200, height: 800) : model.visibleRect.size
        #if DEBUG
        if onArrival { CanvasArrivalOracle.recordViewport(viewport, owner: oracleOwner) }
        #endif
        let outcome = model.fitAll(viewport: viewport)
        guard onArrival else {
            switch outcome {
            case .empty, .overview:
                break  // the overview re-renders scaled; empty spoke
            case .scroll(let center):
                scrollAnchor = .center
                scrollTarget = center
            }
            return
        }
        // Row 88(a) — THE ARRIVAL'S LANDING (her ruling's two shapes: "opens
        // FIT-ALL (or at the bank's top-left), never mid-bank"): a board that
        // fits at 1:1 lands on its bounds' centre (fit-all's own road); a
        // board too big to fit lands at its TOP-LEFT AT 1:1 — NOT in the
        // read-only overview: 4E's realization bounds (`realizedCards`
        // < 80, a live pane on arrival) are measured on a 1:1 arrival and
        // hold by construction there, and a 215-card note opening as a
        // wall of silhouettes on every visit would be its own surprise.
        // Chosen under R-cor-8 and recorded; the summoned `fit all` still
        // opens the overview.
        let landing = CanvasArrival.landing(after: outcome)
        #if DEBUG
        CanvasArrivalOracle.recordLanding(landing, owner: oracleOwner)
        #endif
        switch landing {
        case .none:
            break
        case .centre(let point):
            scrollAnchor = .center
            scrollTarget = point
        case .origin:
            model.exitOverview()
            scrollAnchor = .topLeading
            scrollTarget = boardOrigin
        }
    }

    // MARK: - The board

    private var board: some View {
        let origin = boardOrigin
        let size = boardSize
        let scale = model.overviewScale ?? 1
        return ZStack(alignment: .topLeading) {
            Color.clear.frame(width: size.width * scale, height: size.height * scale)
            if let target = scrollTarget {
                Color.clear
                    .frame(width: 1, height: 1)
                    .position(x: (target.x - origin.x) * scale,
                              y: (target.y - origin.y) * scale)
                    .id("canvas-scroll-marker")
            }
            if model.overviewActive {
                // The read-only overview (fit-all ruling, option (i)):
                // SILHOUETTES for every card — cheap rounded rects, no
                // panes, so the realization bound survives the zoom.
                ZStack(alignment: .topLeading) {
                    // 13e E7: the overview shows the BOARD's cards — what
                    // the open bank holds is not on the board to fit.
                    ForEach(model.boardCards, id: \.block.placementID) { item in
                        silhouette(item, scale: scale, origin: origin)
                    }
                }
                .frame(width: size.width, height: size.height, alignment: .topLeading)
                .scaleEffect(scale, anchor: .topLeading)
                // Row 91 (found by row 88's walk — the arrival's overview
                // drew NOTHING): `scaleEffect` is a visual transform; the
                // ZStack kept its UNSCALED layout size, so the scroll
                // content stayed board-sized and the scaled drawing sat at
                // the content's top-left while the 2-axis scroll view's own
                // position lay mid-content — off screen. The overview's
                // layout is the SCALED size now, so it fits the viewport
                // exactly as the fit-all door promises.
                .frame(width: size.width * scale, height: size.height * scale, alignment: .topLeading)
            } else {
                // LAZY REALIZATION (the 4E P1 bound): exactly the model's
                // culled set renders — plus the live pane's card and any
                // in-flight drag/resize (the model's exemptions).
                ForEach(model.realizedCards, id: \.block.placementID) { item in
                    CanvasCardView(
                        model: model, item: item, tokens: tokens,
                        indicator: indicator,
                        origin: origin,
                        switcherBlockID: $switcherBlockID,
                        tagSheetBlock: $tagSheetBlock)
                }
            }
        }
        #if DEBUG
        .onGeometryChange(for: CGSize.self) { $0.size } action: {
            CanvasArrivalOracle.recordBoardContentSize($0, owner: oracleOwner)
        }
        #endif
    }

    /// FREE movement (Sitting 9): stored coordinates may be negative — the
    /// board renders shifted so the minimum card sits at the top-left
    /// margin and the scroll area covers the whole span. 13e E7 moved the
    /// arithmetic onto the MODEL (the drop decision needs the same answer;
    /// one brain, never two).
    private var boardOrigin: CGPoint { model.boardOrigin }

    private var boardSize: CGSize {
        let origin = boardOrigin
        var maxX = origin.x + 600
        var maxY = origin.y + 400
        for frame in model.cardFrames.values {
            maxX = max(maxX, frame.maxX + 20)
            maxY = max(maxY, frame.maxY + 20)
        }
        return CGSize(width: maxX - origin.x, height: maxY - origin.y)
    }

    /// An overview card: a cheap shape + the order number, counter-scaled
    /// so it stays legible at any zoom (the γ rider's requirement).
    private func silhouette(
        _ item: Queries.PoolItem, scale: CGFloat, origin: CGPoint
    ) -> some View {
        let blockID = item.block.blockID
        let frame = CGRect(origin: model.restingPosition(blockID: blockID),
                           size: model.cardSize(blockID: blockID))
        let pending = model.pendingOrderNumber(blockID: blockID)
        let ordinal = model.currentOrdinal(blockID: blockID)
        let badge = pending.map(String.init) ?? ordinal.map(String.init) ?? ""
        return ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 6)
                .fill(tokens.card)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                    pending == nil ? tokens.takeLine : tokens.accent,
                    lineWidth: pending == nil ? 1 : 3))
            Text(String((item.block.text ?? "").prefix(80)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(3)
                .padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            Text(badge)
                .font(.system(size: 13, weight: pending == nil ? .regular : .bold))
                .foregroundStyle(pending == nil ? tokens.muted : tokens.accent)
                .scaleEffect(min(1 / scale, 3), anchor: .bottomTrailing)
                .padding(4)
        }
        .frame(width: frame.width, height: frame.height)
        .offset(x: frame.minX - origin.x, y: frame.minY - origin.y)
        .contentShape(Rectangle())
        .onTapGesture {
            // Order mode: clicks number (the γ rider); otherwise return
            // to 1:1 centered on the clicked card.
            if let center = model.overviewClicked(blockID: blockID) {
                scrollTarget = center
            }
        }
    }
}

// MARK: - One card

/// One canvas card: the grab header (the honest drag region — a drag in
/// the text is a SELECTION, the pane owns those events), the editable
/// pane (or the order-mode static face), the footer with tags/switcher
/// and the read-time block ordinal bottom-right, and the resize grip.
private struct CanvasCardView: View {
    let model: CanvasViewModel
    let item: Queries.PoolItem
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): carried to the card's pane, decided nowhere here.
    let indicator: EditingIndicatorStyle
    let origin: CGPoint
    @Binding var switcherBlockID: String?
    @Binding var tagSheetBlock: CanvasView.TagSheetBlock?

    init(
        model: CanvasViewModel, item: Queries.PoolItem, tokens: VoiceTokens,
        indicator: EditingIndicatorStyle,
        origin: CGPoint,
        switcherBlockID: Binding<String?>,
        tagSheetBlock: Binding<CanvasView.TagSheetBlock?>
    ) {
        self.model = model
        self.item = item
        self.tokens = tokens
        self.indicator = indicator
        self.origin = origin
        _switcherBlockID = switcherBlockID
        _tagSheetBlock = tagSheetBlock
        #if DEBUG
        CanvasCardMaterialization.count += 1
        #endif
    }

    private var blockID: String { item.block.blockID }

    var body: some View {
        let resting = model.restingPosition(blockID: blockID)
        let dragOffset = model.dragOffsets[blockID] ?? .zero
        let size = liveSize
        let resolved = model.resolvedCard(item: item)
        let pendingNumber = model.pendingOrderNumber(blockID: blockID)
        return VStack(alignment: .leading, spacing: 4) {
            grabHeader
            if model.orderMode {
                staticBody(resolved: resolved)
            } else {
                paneBody(resolved: resolved)
            }
            footer
        }
        .padding(8)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(
            pendingNumber == nil ? tokens.takeLine : tokens.accent,
            lineWidth: pendingNumber == nil ? 1 : 2))
        .overlay(alignment: .bottomTrailing) { resizeGrip }
        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        .offset(x: resting.x - origin.x + dragOffset.width,
                y: resting.y - origin.y + dragOffset.height)
        .contextMenu { menuBody }
    }

    /// The card's live size: the remembered/default size plus any
    /// in-flight resize translation, clamped.
    private var liveSize: CGSize {
        let base = model.cardSize(blockID: blockID)
        let offset = model.resizeOffsets[blockID] ?? .zero
        return CanvasBoardGeometry.clampedSize(
            CGSize(width: base.width + offset.width, height: base.height + offset.height))
    }

    // MARK: The grab header (the 3A note's answer)

    private var grabHeader: some View {
        HStack(spacing: 6) {
            Text("⠿")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            if model.viewedDiffersFromChosen(blockID: blockID) {
                // R88's marker: this card is a WAY OF LOOKING right now.
                Text("viewing — not what the note shows")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .help("Drag here to move the card — dragging in the text selects text")
        .gesture(
            // 13e E12: measured in the SURFACE space (see
            // `CanvasView.surfaceSpace`) — the default local space moves
            // with the `.offset` this drag applies, which halved every
            // translation and made the card stutter.
            DragGesture(coordinateSpace: .named(CanvasView.surfaceSpace))
                .onChanged { value in
                    model.dragOffsets[blockID] = value.translation
                }
                .onEnded { value in
                    // 13e E7: dropped ON the open bank ⇒ the card unplaces
                    // (its position row tombstones) instead of landing at a
                    // coordinate under the strip. The test is possible at
                    // all because the drag and the strip's frame are read in
                    // the SAME space (E12's fix, composing).
                    if model.dropTarget(atSurface: value.location) == .bank {
                        Task { await model.returnToBank(blockID: blockID) }
                        return
                    }
                    Task {
                        await model.dragEnded(blockID: blockID, translation: value.translation)
                    }
                })
    }

    // MARK: The body (pane, or the order-mode static face)

    @ViewBuilder
    private func paneBody(resolved: (variantID: String, text: String)?) -> some View {
        if let resolved {
            // The editable pane (S4-7c): edits land on the take the card
            // DISPLAYS (R88's view-local pick) through the per-post
            // autosave; the ONE ring (tokens.ring, drawn by the pane)
            // marks the live card. The content scrolls in place (the
            // N23/N40 shape) — no part of a long take is unreachable at
            // any card size.
            ScrollView(.vertical) {
                PaneSurfaceView(
                    text: resolved.text,
                    isLive: model.isPaneLive(blockID: blockID, variantID: resolved.variantID),
                    tokens: tokens,
                    indicator: indicator,
                    role: "canvas", variantID: resolved.variantID,
                    onFocusRequest: {
                        model.focus(blockID: blockID, variantID: resolved.variantID)
                    },
                    onEdit: { newText in
                        model.paneEdited(
                            blockID: blockID, variantID: resolved.variantID, newText: newText)
                    },
                    menuItems: { paneMenuItems() })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            // Gap slots render gaps, never crash (SyncSpec §5).
            Text("· · ·")
                .font(Font(EditorDocument.baseFont))
                .foregroundStyle(tokens.muted)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    /// Order mode's card body: plain SwiftUI (panes suspend — clicks mean
    /// SEQUENCE, and an NSTextView would eat them; liveness is refused by
    /// the model while the mode is on).
    private func staticBody(resolved: (variantID: String, text: String)?) -> some View {
        Text(resolved?.text.isEmpty == false ? resolved!.text : "· · ·")
            .font(Font(EditorDocument.baseFont))
            .foregroundStyle(tokens.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture { model.toggleOrderClick(blockID: blockID) }
    }

    // MARK: The footer (tags · switcher · the ordinal bottom-right)

    private var footer: some View {
        HStack(alignment: .bottom, spacing: 6) {
            VStack(alignment: .leading, spacing: 3) {
                if !item.tagPaths.isEmpty {
                    Text(item.tagPaths.joined(separator: " · "))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                if item.block.hasFan, !model.orderMode {
                    takesFooter
                }
            }
            Spacer(minLength: 0)
            // S4-7e: the block-order number, bottom-right — read-time
            // derived from pointer order, never stored. In order mode a
            // clicked card's PENDING sequence number takes the spot
            // (accent, bold).
            if let pending = model.pendingOrderNumber(blockID: blockID) {
                Text("\(pending)")
                    .font(tokens.small.bold())
                    .foregroundStyle(tokens.accent)
            } else if let ordinal = model.currentOrdinal(blockID: blockID) {
                Text("\(ordinal)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .help("Block \(ordinal) of the note's current order")
            }
        }
    }

    /// R40's MINIMAL takes switcher: "see takes" → ‹ take k of n › — one
    /// at a time, that block only, nothing else of the fan machinery (the
    /// mobile-inheritable pattern).
    @ViewBuilder
    private var takesFooter: some View {
        if switcherBlockID == blockID, let position = model.takePosition(blockID: blockID) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Button("‹") { model.switchTake(blockID: blockID, delta: -1) }
                        .disabled((position.index ?? 0) <= 0)
                    Text(switcherLabel(position: position))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                    Button("›") { model.switchTake(blockID: blockID, delta: 1) }
                        .disabled(position.index.map { $0 >= position.count - 1 } ?? false)
                    Spacer()
                    Button("done") { switcherBlockID = nil }
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                if model.viewedDiffersFromChosen(blockID: blockID) {
                    // The ONE careful gesture (R88): viewing never chooses;
                    // this does, and says so.
                    Button("✓ choose this take (the note shows it)") {
                        Task { await model.chooseViewedTake(blockID: blockID) }
                    }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.chosen)
                }
            }
            .controlSize(.mini)
        } else {
            Button("⑂ see takes (\(item.block.activeVariantCount))") {
                switcherBlockID = blockID
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
        }
    }

    private func switcherLabel(position: (index: Int?, count: Int)) -> String {
        guard let index = position.index else { return "take — of \(position.count)" }
        let fan = model.projection.fans[blockID] ?? []
        let label = fan.indices.contains(index) ? fan[index].label : nil
        let name = label.map { " · \($0)" } ?? ""
        return "take \(index + 1) of \(position.count)\(name)"
    }

    // MARK: The resize grip (S4-7d)

    private var resizeGrip: some View {
        // The extreme corner is the grip; the ordinal sits just inside
        // (both read bottom-right — recorded judgment call).
        Text("◢")
            .font(.system(size: 9))
            .foregroundStyle(tokens.faint)
            .padding(2)
            .contentShape(Rectangle())
            .help("Drag to resize this card (remembered on this Mac)")
            .gesture(
                // 13e E12, the same class one gesture over: the grip sits
                // at the card's bottom-right, so the size this drag
                // applies MOVES the grip — in the default local space the
                // resize resisted exactly as the move did.
                DragGesture(coordinateSpace: .named(CanvasView.surfaceSpace))
                    .onChanged { value in
                        model.resizeOffsets[blockID] = value.translation
                    }
                    .onEnded { value in
                        model.resizeEnded(blockID: blockID, translation: value.translation)
                    })
    }

    // MARK: Menus (the SwiftUI menu on chrome; the pane's own on text)

    @ViewBuilder
    private var menuBody: some View {
        Button("Tags…") {
            tagSheetBlock = CanvasView.TagSheetBlock(id: blockID, preview: item.block.text)
        }
        // 13e E7: the shipped "Reset position" row, wearing the bank's own
        // words — it is the same op (`removeCanvasPosition`) and now the
        // same act as dropping the card on the strip, so it says so
        // (#61(d)). Registry-declared with the toggle.
        Button(CapabilityRegistry.capability(.returnCardToBank).verb) {
            Task { await model.returnToBank(blockID: blockID) }
        }
        Button("Reset size") {
            model.resetSize(blockID: blockID)
        }
    }

    /// The pane's Variorum context menu (the AD-4 pattern — right-clicking
    /// INSIDE the text view never reaches the SwiftUI .contextMenu, so the
    /// same doors ride the pane's own menu).
    private func paneMenuItems() -> [PaneTextView.MenuItemSpec] {
        var items: [PaneTextView.MenuItemSpec] = [
            PaneTextView.MenuItemSpec(
                title: "Tags…",
                action: { [blockID, preview = item.block.text] in
                    tagSheetBlock = CanvasView.TagSheetBlock(id: blockID, preview: preview)
                }),
            PaneTextView.MenuItemSpec(
                title: CapabilityRegistry.capability(.returnCardToBank).verb,
                action: { [model, blockID] in
                    Task { await model.returnToBank(blockID: blockID) }
                }),
            PaneTextView.MenuItemSpec(
                title: "Reset size",
                action: { [model, blockID] in model.resetSize(blockID: blockID) }),
        ]
        if model.viewedDiffersFromChosen(blockID: blockID) {
            items.append(PaneTextView.MenuItemSpec(
                title: "✓ Choose this take (the note shows it)",
                action: { [model, blockID] in
                    Task { await model.chooseViewedTake(blockID: blockID) }
                }))
        }
        return items
    }
}

// MARK: - The pool detail's mode switcher (editor | canvas)

/// The pool's two faces (Phase 11, A7/A8): the ordinary detail editor (the
/// ratified Phase 10 shape — a pool is a container; scraps get typed here)
/// and the canvas as its second face.
struct PoolDetailView: View {
    let session: AppSession
    let poolID: String
    /// Stage C: a caret-precise landing (palette/Library block hits).
    var initialBlockID: String? = nil
    /// 13o U2 (D6 — land-at-match): a scrap passage's matched words, riding
    /// the block landing (`PostDetailView.initialFind`'s twin).
    var initialFind: EditorFindSeed? = nil

    enum Mode: String, CaseIterable {
        case scraps = "Scraps"
        case canvas = "Canvas"

        /// 17y B2 (p): the Snippets area's Canvas face is a Canvas door
        /// too ("Canvas = a VIEW on a post or the scraps area" — AppSpec
        /// §12) — gone in Release, from the ONE seam (`PostMode`'s).
        static func faces(keepingCanvas: Bool) -> [Mode] {
            keepingCanvas ? [.scraps, .canvas] : [.scraps]
        }

        static var allCases: [Mode] { faces(keepingCanvas: PostMode.buildKeepsCanvas) }
    }

    @State private var mode: Mode = .scraps
    @State private var pendingCaret: Int?
    @State private var pendingFind: EditorFindSeed?
    /// **The scraps area's own tray, in its own side panel** (the post-13l
    /// polish round, ledger row 9 + batch 1's deferred item).
    ///
    /// The scraps editor composes the same bars over a `kind='pool'`
    /// container, so it inherited the `note ▾` menu's *"This Note's Tray…"*
    /// item — a door with the wrong noun on it. Her C1 ruling moved that door
    /// to an icon, and this surface takes the same icon: a pool's tray is the
    /// scraps area's own, and `TrayPath.menuLabel(for:)` is where the noun is
    /// decided (13l row 26's kind machinery, applied to the door's own name).
    @State private var trayShown = false

    /// The `.surface` act this view renders (P-1). Same act, same walk — the
    /// scraps area is the third renderer of the one tray door.
    static let surfaceCapabilities: [CapabilityID] = [.showNoteTray]

    /// Row 74 (the Act 10 correction round, batch G): the scraps area's tray
    /// stands in a `SideColumn` of our own — the same class of `.inspector`
    /// the note's side and the Library retired: its divider is the system's,
    /// drawn in a KEY window only.
    static let sideColumnWidthKey = "scrapsSideColumnWidth"
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        SideColumn(
            tokens: tokens, shown: trayShown,
            widthKey: Self.sideColumnWidthKey, subjectKey: poolID
        ) {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // 17y B2 (p): with ONE face (a Release build) the picker
                // could only re-select what shows — a control that cannot
                // act is not drawn (P-2).
                if Mode.allCases.count > 1 {
                    Picker("Pool mode", selection: $mode) {
                        ForEach(Mode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 220)
                }
                Spacer()
                Button(TrayPath.menuLabel(for: .pool), systemImage: "tray") {
                    withAnimation(PostDetailView.panelAnimation) { trayShown.toggle() }
                }
                .labelStyle(.iconOnly)
                .help("What this scraps area has set aside: blocks it archived, "
                    + "and everything of its own on the \(TrashWindow.days)-day clock")
            }
            .padding(6)
            Divider()
            switch mode {
            case .scraps:
                EditorView(
                    session: session, postID: poolID, caretSeed: pendingCaret,
                    findSeed: pendingFind)
                    .id("\(poolID)-caret-\(pendingCaret ?? -1)")
            case .canvas:
                // A pool has no lens home — the save-picks door hides.
                CanvasView(session: session, containerID: poolID, offersLensSave: false)
                    .id("canvas-\(poolID)")
            }
        }
        } panel: {
            TrayPanel(
                session: session, postID: poolID, home: .pool,
                onClose: { withAnimation(PostDetailView.panelAnimation) { trayShown = false } })
        }
        .onAppear {
            guard let initialBlockID else { return }
            Task {
                // The same landing math as PostDetailView.jump — the
                // block's surface offset seeds the editor's caret.
                let offset: Int? = try? await session.database.read { [poolID] db in
                    let slots = try Queries.renderPost(db, containerID: poolID)
                    guard let i = slots.firstIndex(where: { $0.blockID == initialBlockID })
                    else { return nil }
                    return BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i).location
                }
                if let offset {
                    pendingFind = initialFind  // before the caret re-keys the editor
                    pendingCaret = offset
                }
            }
        }
    }
}

/// **Row 88(a)'s rule, pure (pinned):** a canvas lands through fit-all on
/// its arrival exactly when it has cards, its store holds NO position for
/// any of them (never arranged), and it has not been landed already.
nonisolated enum CanvasArrival {
    static func fitsAllOnArrival(cards: Int, storedPositions: Int, alreadyFitted: Bool) -> Bool {
        cards > 0 && storedPositions == 0 && !alreadyFitted
    }

    /// Where an arrival lands, from fit-all's own verdict: a board that
    /// fits at 1:1 on its bounds' centre; a board too big to fit at its
    /// top-left at 1:1 (never the overview, never mid-bank); nothing when
    /// there is nothing to fit.
    enum Landing: Equatable {
        case none
        case centre(CGPoint)
        case origin
    }

    static func landing(after outcome: CanvasViewModel.FitAllOutcome) -> Landing {
        switch outcome {
        case .empty: .none
        case .scroll(let centre): .centre(centre)
        case .overview: .origin
        }
    }
}

#if DEBUG
/// Row 88(a)'s DEBUG oracle: how the arrival landed — nil until it does.
@MainActor
enum CanvasArrivalOracle {
    // **18k UNIT C4 — the three facts NAME THEIR OWNER** (the rule and its
    // reasons: `Core/Views/DebugOracleOwnership.swift`): the mounted canvas's
    // `oracleOwner`, released when that canvas leaves. They were bare
    // statics every canvas overwrote — after one window closed the arrival
    // was ITS (measured red, `DebugOracleTwoWindowTests`).
    private static var landingSlot = OwnedSlot<CanvasArrival.Landing>()
    private static var contentSizeSlot = OwnedSlot<CGSize>()
    private static var viewportSlot = OwnedSlot<CGSize>()

    static var landing: CanvasArrival.Landing? { landingSlot.value }
    /// Row 91: the board's scroll-content size — in the overview it must be
    /// the SCALED size (the drawing fits the viewport), never the board's.
    static var boardContentSize: CGSize? { contentSizeSlot.value }
    /// Ladder R1-14: the viewport the arrival's decision read — the REPORTED
    /// one, never the 1200 × 800 fallback.
    static var viewport: CGSize? { viewportSlot.value }

    static func recordLanding(_ landing: CanvasArrival.Landing, owner: UUID) {
        landingSlot.publish(landing, owner: owner)
    }

    static func recordBoardContentSize(_ size: CGSize, owner: UUID) {
        contentSizeSlot.publish(size, owner: owner)
    }

    static func recordViewport(_ size: CGSize, owner: UUID) {
        viewportSlot.publish(size, owner: owner)
    }

    /// A canvas leaving: its own arrival, and no other window's.
    static func release(owner: UUID) {
        landingSlot.release(owner: owner)
        contentSizeSlot.release(owner: owner)
        viewportSlot.release(owner: owner)
    }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() {
        landingSlot.forget()
        contentSizeSlot.forget()
        viewportSlot.forget()
    }
}
#endif
