//
//  EditorView.swift
//  Variorum
//
//  The editor feature's SwiftUI face (Phase 7): TK2 surface + functional,
//  unstyled chrome (canary banner, seal banner, commit bar, fan panel).
//  Calm default: no fan machinery is visible on unfanned blocks — the badge
//  appears only where a fan exists (AppSpec §12), as an overlay, never a
//  rendering attribute (memo obligation: decorations stay off the live view).
//

import AppKit
import SwiftUI
import VariorumCore

struct EditorView: View {
    let session: AppSession
    let postID: String
    /// ⌘⇧L in Write (Sitting 9, R73) — the save-choices prompt.
    @State private var saveLensPrompt = false
    /// 13b 1b: the routed-command registration's lifecycle token.
    @State private var commandToken: UUID?
    /// Inline mode (Phase 10 Step 3): the editor lives inside a multi-post
    /// container's scroll — a bare, content-sized TK2 surface instead of
    /// the detail editor's own scroll view. Exactly one EditorView exists
    /// per container by construction (one focused post), which is P3's
    /// one-live-editor rule.
    var inline = false
    /// Where the bar goes.
    ///
    /// - `.bottom` — the standing form everywhere: the `CommitBar` under the
    ///   surface, byte-unchanged.
    /// - `.inSidebarBox` — **the BOOK's editing surfaces (18d batch 1, her
    ///   U-10)**: this editor renders NO bar of its own, because its doors
    ///   live in the sidebar's note box, which the shell builds from the
    ///   editor UNDER THE CARET (`EditorRouter.editing`, never `active` —
    ///   its own comment carries the measured reason). Wave 2c's `.side`
    ///   arm — the same bar as a vertical rail in the Outline's right gutter
    ///   — RETIRED with the gutter itself (U-17), and her ruling's own
    ///   sentence is why: *"then it can stop taking up room on the right and
    ///   it won't be at the bottom when you're in that book editing mode."*
    enum BarPlacement { case bottom, inSidebarBox }
    var barPlacement: BarPlacement = .bottom
    /// **13u3 UNIT A1 — the INLINE surface's prose placement** (the read
    /// tier's twin; `Surface/ProseGutter`). Ignored by the full-document
    /// editor, which carries `.write` from its own factory. The BLEED is
    /// applied around the text surface ALONE, so this view's banners (the
    /// canary, the seal line, the block-selection banner) keep the host's
    /// own measure and only the prose reaches into the whitespace.
    var gutter: ProseGutter = .contained
    /// VX-75: the INLINE surface says, once, when it first shows the note —
    /// its initial render is in and the height measured from it has been
    /// reported. A host that keeps something on screen until then (the book
    /// Outline's read surface) releases it here. Ignored by the full-document
    /// editor.
    var onLiveShowing: (() -> Void)? = nil
    @State private var model: EditorViewModel
    @State private var inlineHeight: CGFloat = 24
    /// 13b 4D (S4-19, her ruling): drag handles reveal on hover — a
    /// Write-mode setting, default ON; OFF = the fully clean surface.
    /// Local (the density-settings class; the synced-setting alternative
    /// recorded — core is frozen this batch).
    @AppStorage("writeHoverHandles") private var writeHoverHandles = true
    /// Phase 13 (C1): the voice reaches the text surface — chrome, font,
    /// seams, indicator, comments all resolve from the theme environment
    /// (optional: test hosts lack it — the terminal fallback).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String, inline: Bool = false,
        caretSeed: Int? = nil, fanSeed: String? = nil,
        findSeed: EditorFindSeed? = nil,
        barPlacement: BarPlacement = .bottom,
        gutter: ProseGutter = .contained,
        onLiveShowing: (() -> Void)? = nil
    ) {
        self.session = session
        self.postID = postID
        self.inline = inline
        self.barPlacement = barPlacement
        self.gutter = gutter
        self.onLiveShowing = onLiveShowing
        let model = EditorViewModel(session: session, postID: postID)
        model.pendingCaretSeed = caretSeed
        model.pendingFanSeed = fanSeed
        // 13o U2 (D6): a search passage's landing — the third one-shot.
        model.pendingFindSeed = findSeed
        _model = State(initialValue: model)
    }

    private var themeSettings: Queries.ThemeSettings {
        themeStore?.settings ?? Queries.ThemeSettings()
    }

    /// 13d batch 4 (A23/A24): this Mac's editor-behaviour settings ride
    /// the chrome, so a change re-applies through the one chrome gate.
    @AppStorage(ParagraphGap.settingKey) private var paragraphGap = ParagraphGap.standard
    @AppStorage(SpellcheckLevel.settingKey) private var spellcheck = SpellcheckLevel.off

    private var chrome: EditorSurfaceChrome {
        EditorSurfaceChrome(
            tokens: themeSettings, dark: scheme == .dark,
            paragraphGap: paragraphGap, spellcheck: spellcheck)
    }

    private var chromeTokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The banners + the one text surface — everything above the bar,
    /// shared by both bar placements.
    @ViewBuilder private var surfaceColumn: some View {
        VStack(spacing: 0) {
            if let canary = model.canaryMessage {
                Text(canary)
                    .foregroundStyle(.white)
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .textSelection(.enabled)
            }
            if model.header?.locked == true {
                Text(chromeTokens.chromeLabel("sealed note — read-only"))
                    .font(chromeTokens.small)
                    .foregroundStyle(chromeTokens.muted)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(chromeTokens.wash)
            }
            blockSelectionBanner
            if inline {
                InlineEditorSurface(
                    model: model, height: $inlineHeight, chrome: chrome, gutter: gutter,
                    onShowing: onLiveShowing)
                    .frame(height: inlineHeight)
                    // THE BLEED (13u3 UNIT A1) — see `ReadPostView`'s twin:
                    // the frame reaches into the host's whitespace while
                    // this view's reported geometry is unmoved.
                    .padding(.horizontal, -gutter.bleed)
            } else {
                EditorSurface(model: model, chrome: chrome)
            }
        }
    }

    var body: some View {
        @Bindable var model = model
        Group {
            if case .inSidebarBox = barPlacement {
                // 18d batch 1: no bar here at all — the doors are in the
                // sidebar's note box, built by the shell from the registered
                // live editor. The prose gets the whole measure back.
                //
                // 13u3 UNIT D: which is why the commit door's name field is
                // presented HERE in this placement and on the bar in the
                // other — exactly one presentation per placement, decided by
                // the same switch that decides the bar, so two fields can
                // never be up for one ask. The box's bar is built from the
                // LIVE editor's model, and ⌘S in a book reaches whichever
                // editor's handler consumes it, so an ask hung only off the
                // box could land on a model the box is not showing. Anchored
                // on the prose, it is also nearer where she typed.
                surfaceColumn
                    .savepointNameAsk(
                        Binding(
                            get: { model.savepointAsk },
                            set: { model.savepointAsk = $0 }),
                        tokens: chromeTokens
                    ) { _, name in
                        Task { await model.fileSavepoint(named: name) }
                    }
            } else {
                VStack(spacing: 0) {
                    surfaceColumn
                    CommitBar(model: model)
                }
            }
        }
        .task { await model.start() }
        .onAppear { pushAppearance() }
        .onChange(of: themeSettings) { _, _ in pushAppearance() }
        .onChange(of: scheme) { _, _ in pushAppearance() }
        .onChange(of: writeHoverHandles) { _, _ in pushAppearance() }
        .onDisappear { model.teardown() }
        .sheet(item: $model.fanPanel) { panel in
            // Sitting 9 (R87): the FanPanel is retired — Write's take
            // machinery is the same v2 card grammar as everywhere else,
            // scoped to this block.
            WriteTakesPanel(session: session, postID: postID, blockID: panel.blockID)
        }
        .sheet(isPresented: $saveLensPrompt) {
            LensNameSheet(title: "Save current choices as a lens") { name in
                model.saveCurrentChoicesAsLens(named: name)
            }
        }
        .onAppear {
            // 13b 1b (P-4): the routed-command channel — a registered
            // handler by composition, not a notification observer.
            commandToken = session.commandRouter.registerHandler { handleRouted($0) }
        }
        .onDisappear {
            if let commandToken {
                session.commandRouter.unregisterHandler(commandToken)
            }
        }
        .sheet(item: $model.trayRequest) { request in
            // 13j J2: this note's tray — what it has deleted, and what a
            // divide or merge preserved whole. One view, presented wherever
            // a door raises it (the `CommentsPanel` precedent).
            //
            // The post-13l polish round (ledger row 9): the tray's HOME is
            // the post detail's side panel now, and this sheet is the
            // fallback for hosts that have no inspector — including the
            // scraps editor, which is why it hands down the container's KIND
            // (a pool's tray is the scraps area's own).
            TrayPanel(
                session: session, postID: request.postID,
                revealBlockID: request.revealBlockID,
                home: model.header?.kind ?? .post)
        }
        .sheet(item: $model.commentsPanel) { panel in
            // Phase 13 C1 (R7): the block's comments — margin/inline faces
            // all open here; deleted comments visible + resurrectable.
            CommentsPanel(session: session, blockID: panel.blockID)
        }
        .sheet(item: $model.divideWCeremony) { state in
            // The W ceremony (Phase 9, contract item 3): one sheet; any
            // dismissal other than Confirm is a cancel — no rows touched.
            DivideWSheet(ceremony: model.divideWCeremonyController, presented: state)
        }
        .sheet(item: $model.mergeCeremony) { state in
            // The merge ceremony (13b Stage 4, 4B — the W's mirror,
            // S4-23): one sheet; any dismissal other than Merge is a
            // cancel — no rows touched.
            MergeCeremonySheet(model: model, presented: state)
        }
        .alert(
            "Make one block across boundaries?",
            isPresented: Binding(
                get: { model.crossBlockMakeConfirm != nil },
                set: { if !$0 { model.crossBlockMakeConfirm = nil } }),
            presenting: model.crossBlockMakeConfirm
        ) { state in
            // Phase 11, A9 — the guided flow's CONFIRM (the v1 refusal's
            // replacement; cancel touches no rows).
            Button("Make Block") {
                Task { await model.confirmCrossBlockMakeBlock(state) }
            }
            Button("Cancel", role: .cancel) { model.crossBlockMakeConfirm = nil }
        } message: { state in
            Text("The selection crosses \(state.blockCount) blocks. Variorum will "
                + "cut the first and last blocks at the snapped edges and merge "
                + "everything inside into ONE block — undo (⌥⌘Z) restores it all.")
        }
    }
}

extension EditorView {
    /// The registry ids this surface renders INLINE (the `.surface` door;
    /// walk-asserted): the block-selection banner (13e E2 — her A17).
    static let surfaceCapabilities: [CapabilityID] = [.deleteSelectedBlocks]

    /// **13e E2 (her A17) — the picked-blocks banner.** The Takes board's
    /// banner, on the other post surface that hosts the same selection
    /// (R118: Write is not privileged, and neither is the board). It renders
    /// ONLY while a selection exists, so at rest the page is exactly as calm
    /// as before — and its presence is what keeps ⌘-click from being a
    /// gesture with a highlight and no door.
    @ViewBuilder
    fileprivate var blockSelectionBanner: some View {
        let picked = model.selectedBlocksInOrder
        if !picked.isEmpty {
            HStack(spacing: 8) {
                Text(chromeTokens.chromeLabel(
                    BlockSelectionCopy.bannerLabel(picked: picked.count)))
                    .font(chromeTokens.small)
                    .foregroundStyle(chromeTokens.muted)
                    .lineLimit(1)
                Button(BlockSelectionCopy.deleteVerb(picked: picked.count)) {
                    Task { await model.deleteSelectedBlocks() }
                }
                .buttonStyle(VoicedButtonStyle(
                    tokens: chromeTokens, role: .primary, font: chromeTokens.mono))
                .help(BlockSelectionCopy.deleteHelp)
                Button(chromeTokens.chromeLabel("clear")) { model.clearBlockSelection() }
                    .buttonStyle(VoicedButtonStyle(tokens: chromeTokens, role: .quiet))
                    .help("Unpick every block")
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(chromeTokens.wash)
        }
    }

    /// The ONE appearance push (models never read SwiftUI environments or
    /// @AppStorage): theme + scheme + the S4-19 hover-handle setting.
    fileprivate func pushAppearance() {
        var appearance = EditorAppearance(themeSettings, dark: scheme == .dark)
        appearance.hoverHandles = writeHoverHandles
        model.appearance = appearance
    }

    /// Write's routed-command handler (13b 1b): the caret block is the
    /// target. The old choose/step LECTURES are retired (P-2): both now
    /// OPEN the caret block's takes panel — the surface where picking and
    /// stepping live, one click deep, right here.
    fileprivate func handleRouted(_ command: RoutedCommand) -> Bool {
        switch command {
        case .takes(let takes):
            switch takes {
            case .toggleFan:
                model.openCaretFan()
            case .branch:
                model.mintCaretTake(blank: false)
            case .blank:
                model.mintCaretTake(blank: true)
            case .blankChoose:
                model.mintCaretTake(blank: true, asChosen: true)
            case .archive:
                model.archiveCaretTake()
            case .choose, .stepPrev, .stepNext:
                // Fire-and-DO: choosing/stepping happens among the block's
                // takes — open them (the panel's cards carry ✓ and the
                // whole fan).
                model.openCaretFan()
            case .closeAll:
                break  // Write has no blooms; the plain page is already here.
            case .saveLens:
                saveLensPrompt = true
            }
            return true
        case .structural(let act):
            // 13j J4/J4b: the ceremony acts plan through their twin's command
            // and diverge at the fanned branch.
            Task {
                await model.invokeGesture(
                    EditorViewModel.plannerCommand(for: act),
                    ceremony: EditorViewModel.requestsCeremony(act))
            }
            return true
        case .deleteInEveryTake:
            Task { await model.deleteInEveryTake() }
            return true
        case .commit:
            model.commitCaretVariant()
            return true
        case .addBlockAtEnd:
            model.jumpToDocumentEnd()
            return true
        case .insertBlockBelow:
            // 13b 4D (N28/S4-13): native in Write — an empty block mints
            // under the caret block; the caret lands in it.
            Task { await model.insertBlockBelowCaret() }
            return true
        case .deleteBlock:
            // 13c 1B (A8): native in Write — the caret block goes, the
            // caret lands in the neighbour that takes its place.
            Task { await model.deleteCaretBlock() }
            return true
        case .archiveBlock:
            // 13j (her round-7 ruling): the same landing, the other verb —
            // the block is KEPT in the note's tray with no countdown.
            Task { await model.archiveCaretBlock() }
            return true
        case .toggleSeal:
            model.toggleSeal()
            return true
        case .comments:
            model.openCaretComments()
            return true
        case .callout(let edit):
            // 13c R2-2 (A13(a)): the frame door routes now — Write is one
            // surface among four, not the privileged one (R118).
            Task { await model.applyCallout(edit) }
            return true
        case .pageFan:
            return false  // fan pages live on the Takes board
        case .copyAllTakes:
            // 13e E6 (A21): native in Write — the caret block's fan, same
            // bytes and same sentence as the boards' door (R118).
            Task { await model.copyCaretBlockTakes() }
            return true
        case .takeToBlockBelow:
            // 13e E5 (A20): native in Write — the caret's take becomes the
            // block below, through the one structural flight.
            Task { await model.moveCaretTakeIntoBlockBelow() }
            return true
        case .takesToBlocks:
            // 13e E6b (A21/A45): the caret block's whole fan.
            Task { await model.turnCaretBlockTakesIntoBlocks() }
            return true
        case .showOriginBlock:
            // 13j J3: the ⌘K row — the caret block's released original, or
            // the honest note where it has none. Since the post-13l polish
            // round it lands in the Block History pane's came-from region,
            // which shows ALL of them (the 13l walk's P-3).
            model.revealCaretBlockOrigin()
            return true
        case .showBlockHistory:
            // The post-13l polish round (ledger row 17): the block she is
            // standing in, and its whole time.
            model.requestBlockHistory()
            return true
        case .showNoteTray:
            // The architect's adjudication 1: the ⌘K row, which is what gives
            // a book spread's inline note a way into its tray at all.
            model.requestNoteTray()
            return true
        case .showNoteVersions:
            // The post-13l polish round (rows 16/23): the note's saved moments.
            model.requestNoteVersions()
            return true
        case .saveNoteVersion:
            // ⌘⇧S — the whole note as it is, addressed to the note on screen.
            Task { await model.saveNoteVersion() }
            return true
        case .find(let action):
            // QoL batch 3 (L6): the find bar lives in THIS editor's own scroll
            // view. The inline book/spread/pool editor owns none, so it
            // declines and the router speaks the declared note (P-2).
            return model.performFind(action)
        }
    }
}

// MARK: - The TK2 surface

// Internal (not private) since 13u4 UNIT F2, on `InlineEditorSurface`'s own
// stated precedent one screen below: the re-font pins drive the REAL
// coordinator path — a chrome VALUE in, a viewport out — because the thing
// row 53 is about is what this coordinator does between the two, and a pin
// against the model's door alone would prove the door works while leaving
// "and the app's surface calls it" a claim.
struct EditorSurface: NSViewRepresentable {
    let model: EditorViewModel
    let chrome: EditorSurfaceChrome

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let (scrollView, textView) = EditorTextView.makeEditor()
        context.coordinator.surfaceDelegate.wire(to: textView)
        context.coordinator.applyChrome(chrome, to: textView, scrollView: scrollView)
        model.attach(textView: textView, scrollView: scrollView)
        let model = model
        textView.onPoolDrop = { [weak model] blockID, offset, includeFan in
            model?.poolDrop(blockID: blockID, atOffset: offset, includeFan: includeFan) ?? false
        }

        context.coordinator.install(scrollView: scrollView, textView: textView)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // Projection updates flow through the model; only the VOICE
        // (chrome/typography) applies here, on change.
        if let textView = nsView.documentView as? EditorTextView {
            context.coordinator.applyChrome(chrome, to: textView, scrollView: nsView)
        }
    }

    static func dismantleNSView(_ nsView: NSScrollView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject {
        let model: EditorViewModel
        let surfaceDelegate: EditorSurfaceDelegate
        private var badges: BadgeOverlayController?
        private var decor: BlockDecorOverlayController?
        private var anchor: ScrollAnchorController?
        private var appliedChrome: EditorSurfaceChrome?

        init(model: EditorViewModel) {
            self.model = model
            self.surfaceDelegate = EditorSurfaceDelegate(model: model)
        }

        func install(scrollView: NSScrollView, textView: EditorTextView) {
            badges = BadgeOverlayController(model: model, textView: textView)
            decor = BlockDecorOverlayController(model: model, textView: textView)
            anchor = ScrollAnchorController(model: model, scrollView: scrollView)
        }

        /// Idempotent per chrome value — a real voice/scheme change
        /// re-styles the whole surface (rare, deliberate).
        ///
        /// 13u4 UNIT F2 (row 53): a chrome whose BASE ATTRIBUTES moved
        /// re-flows the whole document, and this surface keeps its scroll
        /// offset in pixels — so the re-font runs inside the model's
        /// reading-position keeper, which captures the top visible LOCATION
        /// first and restores it on the settle hop. Byte-unchanged for a
        /// colour-only chrome (the keeper's own guard).
        func applyChrome(
            _ chrome: EditorSurfaceChrome, to textView: EditorTextView,
            scrollView: NSScrollView
        ) {
            guard appliedChrome != chrome else { return }
            let previous = appliedChrome
            appliedChrome = chrome
            // A re-font is a CHANGE from one chrome to another. The FIRST
            // application is a birth — `needsStorageRefresh(from: nil)` says
            // "everything" because everything must be WRITTEN, not because
            // anything re-flowed — and there is no reading position yet to
            // keep. Parking one anyway is not merely useless: measured, it
            // is a yank, because a park is spent by the first settle hop that
            // is new enough and the surface is at offset 0 when it is born,
            // so a jump taken later lands her at the top of the note.
            model.keepingReadingPosition(
                acrossRefont: previous != nil && chrome.needsStorageRefresh(from: previous)
            ) {
                textView.applyVoiceChrome(chrome, previous: previous)
            }
            scrollView.backgroundColor = chrome.paper
            scrollView.drawsBackground = true
            model.refreshBadges()
        }

        func uninstall() {
            badges?.uninstall()
            decor?.uninstall()
            anchor?.uninstall()
        }
    }
}

// MARK: - The inline TK2 surface (Phase 10 Step 3 — the book-view editor)

/// The same editor machinery over a BARE, content-sized text view: no own
/// scroll view (the multi-post container scrolls), no ScrollAnchorController
/// (the container owns scroll position), height published to SwiftUI after
/// every storage change so the row grows with typing. Everything else —
/// delegate pipeline, badges, tint, model — is the one editor brain.
///
/// **18k C2 — the height is reported on the NEXT TURN, never inside SwiftUI's
/// update.** `makeNSView` (through `install`) and every `updateNSView` used to
/// write the `@Binding` synchronously: measured, that write was the source of
/// every "Modifying state during view update" this representable emitted (20
/// of 20 in `BookOutlineLandingTests`' run), and SwiftUI was measured
/// IGNORING one (an update-phase 16,134 pt no body pass saw, rescued ~29 ms
/// later by the storage road). All three triggers — the mount, an update
/// pass, a storage edit — now go through ONE coalescing hop
/// (`scheduleRemeasure`, newest trigger wins), so a burst reports once, and the binding is only
/// ever written outside an update, where it reads live (inside one, the
/// captured binding was measured reading a stale 24). The mount still
/// schedules its report: wiring is the delivery (the constitution's sink
/// law) — a surface whose text is already in place when it mounts has no
/// storage edit to prompt one. The review's claim that this write caused
/// the Outline's double realization was DISPROVED by measurement (the unit
/// record, M4). Pinned: `InlineHeightReportTests`.
// Internal (not private): the inline window tests drive the REAL
// coordinator path — its per-edit remeasure is the measured cost
// (review round 1, MINOR 6).
struct InlineEditorSurface: NSViewRepresentable {
    let model: EditorViewModel
    @Binding var height: CGFloat
    var chrome = EditorSurfaceChrome(tokens: Queries.ThemeSettings(), dark: false)
    /// 13u3 UNIT A1: the host's prose placement (see `EditorView.gutter`).
    var gutter: ProseGutter = .contained
    /// VX-75 (see `EditorView.onLiveShowing`).
    var onShowing: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> EditorTextView {
        let textView = EditorTextView.makeInlineEditor()
        textView.proseGutter = gutter
        context.coordinator.onShowing = onShowing
        context.coordinator.surfaceDelegate.wire(to: textView)
        context.coordinator.applyChrome(chrome, to: textView)
        model.attach(textView: textView, scrollView: nil)
        let model = model
        textView.onPoolDrop = { [weak model] blockID, offset, includeFan in
            model?.poolDrop(blockID: blockID, atOffset: offset, includeFan: includeFan) ?? false
        }

        context.coordinator.install(textView: textView) { [self] newHeight in
            if abs(height - newHeight) > 0.5 { height = newHeight }
        }
        return textView
    }

    func updateNSView(_ nsView: EditorTextView, context: Context) {
        // Projection-driven through the model; the width is SwiftUI's.
        context.coordinator.onShowing = onShowing
        context.coordinator.viewUpdated(chrome: chrome, gutter: gutter, on: nsView)
    }

    static func dismantleNSView(_ nsView: EditorTextView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    @MainActor
    final class Coordinator: NSObject {
        let model: EditorViewModel
        let surfaceDelegate: EditorSurfaceDelegate
        private var badges: BadgeOverlayController?
        private var decor: BlockDecorOverlayController?
        private weak var textView: EditorTextView?
        private var storageToken: NSObjectProtocol?
        private var reportHeight: ((CGFloat) -> Void)?
        private var appliedChrome: EditorSurfaceChrome?
        /// VX-75: the host's "this surface now shows its note" door, fired
        /// once — by the first report measured after the initial render, so
        /// the height binding and the host's release land in the same turn.
        var onShowing: (() -> Void)?
        private var announcedShowing = false

        init(model: EditorViewModel) {
            self.model = model
            self.surfaceDelegate = EditorSurfaceDelegate(model: model)
        }

        /// 13u4 UNIT F2: the same door as the detail editor's, so the rule
        /// lives in ONE place — and INERT here by construction, because this
        /// surface owns no scroll view (the keeper's own guard, the same one
        /// `parkAnchorRestore` and `revealLanding` already carry): the book
        /// /spread/pool editor scrolls inside its host and has no viewport of
        /// its own to keep. Byte-unchanged behaviour; the call is here so a
        /// reader does not have to wonder whether the contained surface was
        /// forgotten or excluded.
        func applyChrome(_ chrome: EditorSurfaceChrome, to textView: EditorTextView) {
            guard appliedChrome != chrome else { return }
            let previous = appliedChrome
            appliedChrome = chrome
            model.keepingReadingPosition(
                acrossRefont: previous != nil && chrome.needsStorageRefresh(from: previous)
            ) {
                textView.applyVoiceChrome(chrome, previous: previous)
            }
            model.refreshBadges()
        }

        /// `updateNSView`'s body, on the coordinator (18k C2) so a pin can
        /// drive the SAME road a SwiftUI update takes without a `Context`.
        func viewUpdated(
            chrome: EditorSurfaceChrome, gutter: ProseGutter, on textView: EditorTextView
        ) {
            textView.proseGutter = gutter
            applyChrome(chrome, to: textView)
            scheduleRemeasure()
        }

        /// 18k C2: the newest trigger's number — only its hop measures.
        private var reportGeneration = 0

        /// The ONE report hop (18k C2). Every trigger — the mount, an update
        /// pass, a storage edit — schedules a hop, and only the NEWEST one
        /// measures, so a burst in one turn reports ONCE and at exactly the
        /// point the old road's LAST report measured: after every trigger of
        /// the burst and after any main-queue work those triggers queued
        /// ahead of it. (A first-trigger latch would have measured BEFORE the
        /// work the later triggers queued — earlier than the road it
        /// replaces.) A trigger the measurement itself causes bumps the
        /// generation and gets its own hop, never swallowed.
        func scheduleRemeasure() {
            reportGeneration &+= 1
            let generation = reportGeneration
            DispatchQueue.main.async { [weak self] in
                guard let self, generation == reportGeneration else { return }
                remeasure()
            }
        }

        func install(textView: EditorTextView, reportHeight: @escaping (CGFloat) -> Void) {
            self.textView = textView
            self.reportHeight = reportHeight
            badges = BadgeOverlayController(model: model, textView: textView)
            decor = BlockDecorOverlayController(model: model, textView: textView)
            // **18l U0 (her clipped-descenders report) — A WIDTH CHANGE
            // RE-MEASURES, on its own door.** A width change re-wraps the text
            // with NO storage edit, and the update pass SwiftUI runs for a
            // resize is not guaranteed to see the final width: traced, the one
            // `updateNSView` of a narrowing saw the view at an INTERMEDIATE
            // width, measured the old wrap, and the final frame arrived in
            // layout with nothing left to re-measure — so the frame kept the
            // old wrap's height and the new, longer wrap was cut through (her
            // capture; up to three lines, measured). The comment this replaces
            // said an update pass always covered it (18k C2's measurement on
            // one live-resize drag — true of THAT road, not of every width
            // change). The text view already announces every width change
            // after placing its prose column for it (`onWidthReflow`, fired
            // from `setFrameSize`); the model wires that door for its
            // OVERLAYS (attach runs before this install), and the height is
            // composed onto it here — the model's handler first, then the one
            // coalescing hop, which measures at the new width on the next
            // turn. Termination: a report changes only the frame's HEIGHT, and
            // the door fires only when the WIDTH changed.
            let overlaysReflow = textView.onWidthReflow
            textView.onWidthReflow = { [weak self] in
                overlaysReflow?()
                self?.settleHealsLeft = Self.settleHealBudget
                self?.scheduleRemeasure()
            }
            // **18l U0 — THE SETTLE NET (item 2's residual: the brief's named
            // suspect).** TextKit 2's full measure on the turn after a width
            // change (or a window entry) can be far from the layout its later
            // passes settle to — measured in the app, 22,884 pt reported where
            // the story settled at 23,082 once a scroll laid its end out (the
            // tail cut: her capture's shape), and in the pins 631 pt SHORT and
            // 229 pt TALL (the TALL side is KnownIssues row 75's gap). The pane
            // component heals this class through `PanePublisher`; this surface
            // had no heal. So every display pass (`viewWillDraw` → the model's
            // `onLayoutSettle` door, composed like the width door above: the
            // model's overlay refresh first) reads the LAST layout fragment's
            // bottom — O(1), the layout already there, no `ensureLayout` — and
            // when that bottom has MOVED since the last look and no longer
            // matches what was last reported, it schedules the one report hop.
            // EDGE-triggered (only a moved bottom re-arms), so a stable
            // disagreement between the O(1) read and the full measure can never
            // spin; BOUNDED per occasion (`settleHealBudget`, re-armed by a
            // width change, the mount, and a storage edit); and terminating,
            // because a report changes only the frame's HEIGHT, which moves no
            // fragment.
            let overlaysSettle = textView.onLayoutSettle
            textView.onLayoutSettle = { [weak self] in
                overlaysSettle?()
                self?.displayPassSettled()
            }
            //
            // Every storage change (typing, projections, structural
            // rewrites) can change the content height; re-measure after
            // the edit settles. Cost: layout validation over a warm
            // document — ∝ the edit, the focused post bounds the walk.
            if let storage = textView.textStorage {
                storageToken = NotificationCenter.default.addObserver(
                    forName: NSTextStorage.didProcessEditingNotification,
                    object: storage, queue: nil
                ) { [weak self] _ in
                    // didProcessEditing fires INSIDE the edit transaction;
                    // geometry reads must wait for it to close — the
                    // scheduled hop is that wait (one turn, as before; 18k C2
                    // only lets it share the hop with the other triggers).
                    // Text storage is edited on the main thread, so the
                    // notification arrives there (the canary's pattern).
                    MainActor.assumeIsolated {
                        self?.settleHealsLeft = Self.settleHealBudget
                        self?.scheduleRemeasure()
                    }
                }
            }
            // The FIRST height — scheduled, never written inside the mount.
            settleHealsLeft = Self.settleHealBudget
            scheduleRemeasure()
        }

        /// 18l U0 — the settle net's bookkeeping (see `install`).
        /// How many settle-triggered reports one occasion may make. TextKit
        /// was measured settling over up to four display passes after a
        /// reflow; the budget is generous so a real settle always lands, and
        /// finite so nothing can re-measure the post forever.
        static let settleHealBudget = 8
        private var settleHealsLeft = 0
        /// The height the last report carried (nil before the first).
        private var lastReportedHeight: CGFloat?
        /// The laid-out bottom the last display pass saw.
        private var lastSeenBottomHeight: CGFloat?

        /// A display pass happened: has the laid-out text's bottom moved off
        /// what was last reported? O(1) — the last layout fragment only, and
        /// only the layout TextKit already holds.
        func displayPassSettled() {
            guard let textView, let layoutManager = textView.textLayoutManager else { return }
            var bottom: CGFloat?
            layoutManager.enumerateTextLayoutFragments(
                from: layoutManager.documentRange.endLocation, options: [.reverse]
            ) { fragment in
                bottom = fragment.layoutFragmentFrame.maxY
                return false
            }
            guard let bottom else { return }
            let height = max(bottom + textView.textContainerInset.height * 2, 24)
            if let seen = lastSeenBottomHeight, abs(seen - height) < 0.5 { return }
            lastSeenBottomHeight = height
            guard let reported = lastReportedHeight, abs(reported - height) > 0.5,
                  settleHealsLeft > 0 else { return }
            settleHealsLeft -= 1
            scheduleRemeasure()
        }

        func remeasure() {
            // The ONE measurement brain (13b 1a — the third private copy
            // retired; the inline editor keeps its own re-measure TRIGGER,
            // the storage-edit notification, because its heights change on
            // model-driven storage writes, not only on width).
            guard let textView else { return }
            let height = max(PaneMeasurement.height(of: textView), 24)
            lastReportedHeight = height
            reportHeight?(height)
            if model.loaded, !announcedShowing {
                announcedShowing = true
                onShowing?()
            }
        }

        func uninstall() {
            if let storageToken { NotificationCenter.default.removeObserver(storageToken) }
            storageToken = nil
            badges?.uninstall()
            decor?.uninstall()
            reportHeight = nil
        }
    }
}

/// The delegate glue between AppKit's edit pipeline and the view model —
/// its own (internal) class so tests can drive the REAL NSTextView path
/// (shouldChange → storage edit → didProcessEditing) without SwiftUI.
@MainActor
final class EditorSurfaceDelegate: NSObject {
    let model: EditorViewModel

    init(model: EditorViewModel) {
        self.model = model
    }

    /// Wires both delegates the pipeline needs.
    func wire(to textView: EditorTextView) {
        textView.delegate = self
        textView.textStorage?.delegate = self
    }
}

extension EditorSurfaceDelegate: NSTextViewDelegate {
    func textView(
        _ textView: NSTextView,
        shouldChangeTextIn affectedCharRange: NSRange,
        replacementString: String?
    ) -> Bool {
        model.shouldChangeText(in: affectedCharRange, replacement: replacementString)
    }

    func textView(
        _ textView: NSTextView,
        shouldChangeTextInRanges affectedRanges: [NSValue],
        replacementStrings: [String]?
    ) -> Bool {
        // Multi-range edits (find-and-replace-all, multi-caret) are out of
        // editor v1's scope: each range would need its own verdict and the
        // index shifts would interleave — refuse rather than guess.
        guard affectedRanges.count == 1 else {
            model.refuse("Multi-range edits aren't supported yet.")
            return false
        }
        return model.shouldChangeText(
            in: affectedRanges[0].rangeValue,
            replacement: replacementStrings?.first)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        model.updateCaretContext()
    }
}

extension EditorSurfaceDelegate: NSTextStorageDelegate {
    nonisolated func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        guard editedMask.contains(.editedCharacters) else { return }
        MainActor.assumeIsolated {
            model.storageDidEdit(editedRange, changeInLength: delta)
        }
    }
}

// MARK: - Fan badges (overlay views, not text attributes)

/// Reconciles small AppKit badge buttons over the fanned blocks currently in
/// view. Buttons live in the text view's coordinate space, so no cross-
/// framework geometry mapping is needed. Functional, unstyled.
@MainActor
final class BadgeOverlayController {
    private let model: EditorViewModel
    private weak var textView: EditorTextView?
    private var buttons: [String: NSButton] = [:]

    init(model: EditorViewModel, textView: EditorTextView) {
        self.model = model
        self.textView = textView
        model.badgeSink = { [weak self] badges in self?.render(badges) }
        // R2-B (Stage 2 ladder round 2): wiring DELIVERS — badges computed
        // before this host existed must not stay invisible until the next
        // real badge/viewport change (the decor twin's fix, badge field).
        model.pushBadgesToSink()
    }

    func uninstall() {
        model.badgeSink = nil
        for button in buttons.values { button.removeFromSuperview() }
        buttons.removeAll()
    }

    private func render(_ badges: [EditorViewModel.BlockBadge]) {
        guard let textView else { return }
        var seen = Set<String>()
        for badge in badges {
            seen.insert(badge.blockID)
            let button = buttons[badge.blockID] ?? makeButton(blockID: badge.blockID)
            button.title = "⑂\(badge.variantCount)"
            button.sizeToFit()
            // Corner badge: top-right of the block's first fragment — at
            // the prose COLUMN's edge, not the window's (Phase 13 C1, R9:
            // wide gutters put the window edge far from the text). The
            // edge is the surface's ONE derivation (`proseRight` — 17p
            // batch b ladder round 1, R1-3): `bounds − textContainerInset
            // .width` is the symmetric MEAN once the decoration lane makes
            // the insets asymmetric, and a second copy of that arithmetic
            // here would drift from the decor pass's the next time the lane
            // or the trailing inset moved.
            let size = button.frame.size
            let columnRight = textView.proseRight
            button.frame = NSRect(
                x: min(textView.bounds.width - size.width - 8, columnRight + 6),
                y: badge.frame.minY,
                width: size.width, height: size.height)
            if button.superview == nil { textView.addSubview(button) }
        }
        for (blockID, button) in buttons where !seen.contains(blockID) {
            button.removeFromSuperview()
            buttons.removeValue(forKey: blockID)
        }
    }

    private func makeButton(blockID: String) -> NSButton {
        let button = NSButton(title: "⑂", target: nil, action: nil)
        button.bezelStyle = .badge
        button.controlSize = .small
        button.target = self
        button.action = #selector(badgeClicked(_:))
        button.identifier = NSUserInterfaceItemIdentifier(blockID)
        buttons[blockID] = button
        return button
    }

    @objc private func badgeClicked(_ sender: NSButton) {
        guard let blockID = sender.identifier?.rawValue else { return }
        model.openFan(blockID: blockID)
    }
}

// MARK: - Content-anchored scroll restore (the memo's resize obligation)

/// The spike measured the real position-loss hazard: NSScrollView keeps the
/// PIXEL offset across a width reflow while the geometry under it changes
/// (−79 paragraphs on a 900→600 resize). Restore by TEXT location via the
/// hybrid primitive: capture the top visible location while scrolling is
/// stable, restore it when the width changes (one-shot after live resize).
@MainActor
final class ScrollAnchorController {
    private let model: EditorViewModel
    private weak var scrollView: NSScrollView?
    private var tokens: [NSObjectProtocol] = []
    private var stableAnchor: ReadingAnchor?
    private var lastWidth: CGFloat = 0
    private var inLiveResize = false

    init(model: EditorViewModel, scrollView: NSScrollView) {
        self.model = model
        self.scrollView = scrollView
        lastWidth = scrollView.contentView.bounds.width
        let clip = scrollView.contentView
        clip.postsBoundsChangedNotifications = true
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification, object: clip, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.boundsChanged() }
        })
        // Only a Sendable window identity crosses into the isolated region
        // (Notification itself is not Sendable — Swift 6 mode).
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSWindow.willStartLiveResizeNotification, object: nil, queue: .main
        ) { [weak self] note in
            let windowID = (note.object as? NSWindow).map(ObjectIdentifier.init)
            MainActor.assumeIsolated { self?.liveResizeStarted(windowID: windowID) }
        })
        tokens.append(NotificationCenter.default.addObserver(
            forName: NSWindow.didEndLiveResizeNotification, object: nil, queue: .main
        ) { [weak self] note in
            let windowID = (note.object as? NSWindow).map(ObjectIdentifier.init)
            MainActor.assumeIsolated { self?.liveResizeEnded(windowID: windowID) }
        })
    }

    func uninstall() {
        for token in tokens { NotificationCenter.default.removeObserver(token) }
        tokens.removeAll()
    }

    private var window: NSWindow? { scrollView?.window }

    private func boundsChanged() {
        guard !inLiveResize, let scrollView else { return }
        let width = scrollView.contentView.bounds.width
        if width != lastWidth {
            // A width reflow outside live resize (split-view divider, etc.):
            // the pixel offset now points at different text — restore.
            lastWidth = width
            if let anchor = stableAnchor {
                model.restoreReadingAnchor(anchor)
            }
        } else {
            // Ordinary scrolling: keep the anchor current — with its place
            // (18l U0b: a page resting in its top air keeps it across the
            // reflow; `ReadingAnchor.reflowLandingInset`).
            stableAnchor = model.readingAnchor() ?? stableAnchor
        }
        model.refreshBadges()
        // 13c 1E (the phantom fix, PROVISIONAL — QUESTIONS #39): the
        // viewport moved, so a block TK2 has only ESTIMATED may now be
        // what she is looking at. Debounced (the work lands after the
        // scroll settles, never during it), one block per pass, once per
        // block — `LongBlockLayout.swift` carries the bounds.
        model.considerLongBlockLayout()
    }

    private func liveResizeStarted(windowID: ObjectIdentifier?) {
        guard let window, windowID == ObjectIdentifier(window) else { return }
        stableAnchor = model.readingAnchor() ?? stableAnchor
        inLiveResize = true
    }

    private func liveResizeEnded(windowID: ObjectIdentifier?) {
        guard let window, windowID == ObjectIdentifier(window) else { return }
        inLiveResize = false
        lastWidth = scrollView?.contentView.bounds.width ?? lastWidth
        if let anchor = stableAnchor {
            model.restoreReadingAnchor(anchor)
        }
    }
}
