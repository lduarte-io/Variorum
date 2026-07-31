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
#endif

struct CanvasView: View {
    let session: AppSession
    let containerID: String
    /// Post canvases offer 💾 save-picks-as-lens; a pool has no lens home.
    var offersLensSave = true
    @State private var model: CanvasViewModel
    @State private var lensPromptShown = false

    /// 13b 4D (N32(c) — S4-15): the card's "Tags…" — app-wide it was the
    /// ONE tag door; now registry-declared with its scrap-row siblings.
    static let surfaceCapabilities: [CapabilityID] = [.tagBlock]

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
    /// The voice reaches the canvas (optional environment, terminal
    /// fallback — the established pattern).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    struct TagSheetBlock: Identifiable {
        let id: String
        let preview: String?
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topStrip
            ScrollViewReader { proxy in
                ScrollView([.horizontal, .vertical]) {
                    board
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
                        proxy.scrollTo("canvas-scroll-marker", anchor: .center)
                        DispatchQueue.main.async { scrollTarget = nil }
                    }
                }
            }
        }
        .background(tokens.room)
        .task { await model.start() }
        .task { await model.startTags() }
        .sheet(item: $tagSheetBlock) { target in
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
                    Task { await model.commitFocusedTake() }
                    return true
                case .takes(.stepPrev), .takes(.stepNext), .takes(.choose):
                    guard let open = switcherBlockID else {
                        model.speak(
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
        }
    }

    // MARK: - The top strip

    private var topStrip: some View {
        HStack(spacing: 8) {
            // 13b 4D (N32(b) — S4-8b): the picker NAMES itself a tag
            // filter and its help de-blurs the model — a LABEL filter,
            // never a container switch.
            Picker("Tag filter", selection: Binding(
                get: { model.filterTagID },
                set: { tagID in Task { await model.applyFilter(tagID: tagID) } })) {
                Text("tag filter: all").tag(String?.none)
                ForEach(model.allTags, id: \.id) { tag in
                    Text("#\(tag.path)").tag(String?.some(tag.id))
                }
            }
            .fixedSize()
            .help("Show only cards wearing a tag — a LABEL filter, not a pool: "
                + "pools are containers (a block lives in exactly one); tags are "
                + "labels (a block can wear many). Every card stays where it lives.")

            if model.overviewActive {
                Button("back to 1:1") { model.exitOverview() }
                    .help("Leave the overview — or click any card to land on it")
            } else {
                Button("fit all") { handleFitAll() }
                    .help("See every card at once — small boards scroll into "
                        + "view; big boards open a read-only overview")
            }

            // S4-7f — the ONE spatial→structural door: explicit mode,
            // numbered preview, one confirm, ⌥⌘Z undoes, cancel inert.
            if model.orderMode {
                Text("click cards in reading order — \(model.orderSequence.count) numbered")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                Button("Apply order") { Task { await model.applyOrder() } }
                    .disabled(model.orderSequence.isEmpty)
                    .help("The numbered cards lead the note in click order; "
                        + "everything else keeps its relative order after them (⌥⌘Z undoes)")
                Button("Cancel") { model.cancelOrderMode() }
            } else {
                Button("order by clicking…") { model.enterOrderMode() }
                    .help("Click cards in the order the note should read — "
                        + "one confirm reorders the note; the spatial arrangement never moves")
            }

            Spacer()
            if offersLensSave, !model.viewPicks.isEmpty {
                // R88: the canvas's picks are a lens-shaped arrangement —
                // keep them.
                Button("💾 Save picks as lens…") { lensPromptShown = true }
                    .help("This canvas's viewed takes become a named lens — "
                        + "open it in Lenses, adopt it, or promote it later")
            }
        }
        .controlSize(.small)
        .padding(6)
        // 13b 1b (AD-14): outcomes speak through the ONE shell toast.
    }

    private func handleFitAll() {
        switch model.fitAll(viewport: model.visibleRect.isEmpty
            ? CGSize(width: 1200, height: 800) : model.visibleRect.size) {
        case .empty, .overview:
            break  // the overview re-renders scaled; empty spoke
        case .scroll(let center):
            scrollTarget = center
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
                    ForEach(model.visibleCards, id: \.block.placementID) { item in
                        silhouette(item, scale: scale, origin: origin)
                    }
                }
                .frame(width: size.width, height: size.height, alignment: .topLeading)
                .scaleEffect(scale, anchor: .topLeading)
            } else {
                // LAZY REALIZATION (the 4E P1 bound): exactly the model's
                // culled set renders — plus the live pane's card and any
                // in-flight drag/resize (the model's exemptions).
                ForEach(model.realizedCards, id: \.block.placementID) { item in
                    CanvasCardView(
                        model: model, item: item, tokens: tokens,
                        origin: origin,
                        switcherBlockID: $switcherBlockID,
                        tagSheetBlock: $tagSheetBlock)
                }
            }
        }
    }

    /// FREE movement (Sitting 9): stored coordinates may be negative — the
    /// board renders shifted so the minimum card sits at the top-left
    /// margin and the scroll area covers the whole span.
    private var boardOrigin: CGPoint {
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        for frame in model.cardFrames.values {
            minX = min(minX, frame.minX)
            minY = min(minY, frame.minY)
        }
        return CGPoint(x: minX - 20, y: minY - 20)
    }

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
    let origin: CGPoint
    @Binding var switcherBlockID: String?
    @Binding var tagSheetBlock: CanvasView.TagSheetBlock?

    init(
        model: CanvasViewModel, item: Queries.PoolItem, tokens: VoiceTokens,
        origin: CGPoint,
        switcherBlockID: Binding<String?>,
        tagSheetBlock: Binding<CanvasView.TagSheetBlock?>
    ) {
        self.model = model
        self.item = item
        self.tokens = tokens
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
            DragGesture()
                .onChanged { value in
                    model.dragOffsets[blockID] = value.translation
                }
                .onEnded { value in
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
                DragGesture()
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
        Button("Reset position") {
            Task { await model.resetPosition(blockID: blockID) }
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
                title: "Reset position",
                action: { [model, blockID] in
                    Task { await model.resetPosition(blockID: blockID) }
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

    enum Mode: String, CaseIterable {
        case scraps = "Scraps"
        case canvas = "Canvas"
    }

    @State private var mode: Mode = .scraps
    @State private var pendingCaret: Int?

    var body: some View {
        VStack(spacing: 0) {
            Picker("Pool mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 220)
            .padding(6)
            Divider()
            switch mode {
            case .scraps:
                EditorView(session: session, postID: poolID, caretSeed: pendingCaret)
                    .id("\(poolID)-caret-\(pendingCaret ?? -1)")
            case .canvas:
                // A pool has no lens home — the save-picks door hides.
                CanvasView(session: session, containerID: poolID, offersLensSave: false)
                    .id("canvas-\(poolID)")
            }
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
                if let offset { pendingCaret = offset }
            }
        }
    }
}
