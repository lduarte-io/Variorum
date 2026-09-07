//
//  CommitBar.swift
//  Variorum
//
//  The commit shortcut's visible face (Phase 7 Step 5): commit the caret
//  block's take, toggle its history. Functional, unstyled.
//

import SwiftUI
import VariorumCore

struct CommitBar: View {
    let model: EditorViewModel

    /// Wave 2c (Act 10 item 18, W8-5 — "note details render to the SIDE
    /// never below the opening paragraphs"): the bar's SECOND arrangement.
    /// `.horizontal` is the standing bottom bar; `.vertical` stacks the
    /// same clusters into a narrow side rail for the book Outline's
    /// focused inline note — ONE brain, every door, two arrangements
    /// (the drift a second bar would invite is exactly why this is an
    /// axis and not a sibling view). In the vertical form the Aa slide-out
    /// becomes a popover (the formatting cluster's ideal width is wider
    /// than any side rail — same doors, summoned).
    enum Axis { case horizontal, vertical }
    var axis: Axis = .horizontal

    init(
        model: EditorViewModel, formattingExpanded: Bool = false,
        axis: Axis = .horizontal
    ) {
        self.model = model
        self.axis = axis
        _formattingShown = State(initialValue: formattingExpanded)
    }

    @State private var datePickerShown = false
    @State private var pickedDate = Date()
    /// 13l Act 2 (item 3): the note-delete confirm's pending ask. View-local
    /// like the date picker's flag — the ACT is `NoteDeletion`'s, and the
    /// wording and the dialog's shape are the shared modifier's.
    @State private var pendingDelete: NoteDeleteConfirm?
    /// N15: the bar's measured width — the one-row/two-row switch.
    @State private var barWidth: CGFloat = 0

    /// **Act 10 item 6 (her ruling: "this bottom bar should be spread out
    /// again, unless the window is small and it needs to be collapsed").**
    /// The shipped threshold was 1080 — an ordinary editor pane collapsed,
    /// which is exactly her screenshot. The clusters' one-row content
    /// measures ~800 pt in the wider (Terminal, monospace) voice, so 840
    /// keeps one row wherever it genuinely fits and the collapse becomes
    /// the genuinely-small fallback her ruling wants. Pure, so the decision
    /// is pinned (`CommitBarLayoutTests`), not observed.
    nonisolated static let twoRowThreshold: CGFloat = 840

    /// **Row 81 (the Act 10 correction round, batch G) — the flat bar's
    /// ARRANGEMENT by its measured width.** F's walk at a ~950-pt window
    /// with an inspector open (the bar ~316 pt) found item 6's two-row
    /// fallback wrapping AND truncating every label — "blo… · t… · c… ·
    /// h…" — P-8's one-line rule honored into illegibility. Her bar: a
    /// truncated verb is a verb nobody can read. So the bar never wraps and
    /// never truncates: it FOLDS. `.full` is the standing one row, byte-
    /// unchanged at ordinary widths. `.folded` (below the old two-row
    /// threshold) keeps the everyday doors on ONE row — where you are ·
    /// `block ▾` · commit ⌘S · history · `note ▾` — and slides the rest
    /// (takes · comments · Aa) into a `more ▾` overflow; the counts reduce to
    /// the note's total (the word-target door), the side rail's own C-6
    /// verdict. `.compact` (below `compactThreshold` — an inspector open
    /// beside a narrow window) keeps where you are · `block ▾` · `more ▾`
    /// (commit · takes · history · comments · Aa · the note's items as a
    /// submenu) · `?`. Every door survives at every width; the labels in
    /// the folded rows are `fixedSize`, so a label can never truncate — the
    /// tier guarantees the fit, and the pin holds it. Pure, so the decision
    /// is pinned (`CommitBarLayoutTests`), not observed.
    nonisolated enum Arrangement: Equatable { case full, folded, compact }

    /// Below this the folded row itself would not fit in the wider
    /// (Terminal, monospace) voice: its members measure ~570 pt there, plus
    /// the bar's 24 pt of padding.
    nonisolated static let compactThreshold: CGFloat = 600

    nonisolated static func arrangement(width: CGFloat) -> Arrangement {
        // Width 0 = the first pass before geometry lands: the full row, so
        // the bar does not flash a fold while mounting.
        guard width > 0 else { return .full }
        if width >= twoRowThreshold { return .full }
        return width >= compactThreshold ? .folded : .compact
    }
    /// Ledger row 28: is the formatting row slid out? Session UI state, per
    /// bar — a fold is not document semantics (`FormattingDoor`'s own note).
    /// Seeded at birth so a pin can mount the bar in EITHER state and read
    /// what is really drawn (the `TrayPanel(model:)` seam pattern, and its
    /// reason: a `@State` toggle is unreachable from outside the view).
    @State private var formattingShown: Bool
    @Environment(\.openWindow) private var openWindow
    // Phase 13 C1 (R11): the status line wears the voice; the word counts
    // are PROMINENT (the terminal mockup's liked idiom).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The registry ids this bar renders (13b 1b — walk-asserted with the
    /// Takes bar's against the bottomBar door set).
    static var renderedCapabilities: [CapabilityID] {
        [
            .commitTake, .sealPost, .blockComments, .divide, .extract, .makeBlock,
            .merge, .showTakes,
            .insertBlockBelow,  // 13b 4D (N28/S4-13): editor parity — Write's bar door
            .deleteBlock,  // 13c 1B (A8): the delete door beside the insert door
            .archiveBlock,  // the post-13l polish round (row 14 / F1): its twin
            // (`.showNoteTray` LEFT this bar at the post-13l polish round,
            // ledger row 9 — her C1 ruling moved the tray to the masthead's
            // icon and the side panel, and *"the note ▾ menu's item follows
            // the move"*. The act is declared with `.surface` doors only now.)
            // 13l Act 2 (item 3): the door she went looking for and could not
            // find, in the same menu.
            .deleteNote,
            // The post-13l polish round (ledger row 17): **History**, beside
            // commit. Her ruling — *"history is quite similar to commit, it's
            // the natural pair to commit"* — so the bar carries the block's
            // two time controls side by side: write a moment, see the moments.
            .showBlockHistory,
            // The post-13l polish round (ledger rows 16/23): the NOTE's two
            // time controls, in the `note ▾` menu — ⌘⇧S saves the whole note as
            // it is, and Versions… is the list of the moments it has. The
            // grain pairing with commit/history one line up IS the teaching
            // moment her G4 chapter names.
            .saveNoteVersion, .showNoteVersions,
            // 18c batch 3 (her U-6): the note ▾ row and the block ▾ row.
            .splitEveryNewlineIntoBlocks, .splitBlockAtNewlines,
        ]
        // 13k K7: the formatting toolbar's own eight, from ITS table (the
        // cluster is rendered here, so its doors are declared here).
        + FormatBar.renderedCapabilities
    }

    var body: some View {
        Group {
            if axis == .vertical {
                verticalBody
            } else {
                horizontalBody
            }
        }
        // Ledger row 17: the FALLBACK host. The pane's named home is the post
        // detail's inspector; this editor is also composed where there is no
        // detail (the scraps hosts, the book spread's inline form), and a door
        // that cannot act in its context should not have been rendered (P-2).
        .sheet(item: Binding(
            get: { model.blockHistoryRequest },
            set: { model.blockHistoryRequest = $0 })
        ) { request in
            BlockHistoryPane(
                session: model.session, request: request,
                onOpenTray: { blockID in
                    // No inspector here either, so the tray takes the same
                    // road this pane did — the bar's own sheet host.
                    model.blockHistoryRequest = nil
                    model.trayRequest = TrayRequest(
                        postID: model.postID, revealBlockID: blockID)
                },
                // Ledger row 33: the sheet host re-points the same way the
                // inspector does — a new request in the same slot.
                onJump: { request in model.blockHistoryRequest = request })
        }
        // Rows 16/23: the same fallback host for the Versions listing, and for
        // the same reason — this editor is composed where no inspector exists.
        .sheet(isPresented: Binding(
            get: { model.versionsRequested },
            set: { model.versionsRequested = $0 })
        ) {
            NoteVersionsPane(session: model.session, postID: model.postID)
        }
    }

    /// **Row 40's collapse (the Act 10 correction round — her "maybe the
    /// note menu needs to be collapsible"):** the side rail folds to its
    /// where-you-are line and the count. A preference, not per-bar state:
    /// the bar is re-created with every focused note, and a fold she chose
    /// should survive that (the `writeHoverHandles` density class).
    @AppStorage("bookSideRailCollapsed") private var sideRailCollapsed = false

    /// The SIDE RAIL (wave 2c; re-shaped at the Act 10 correction round,
    /// row 40 — her image 16: *"a tall rounded card stacking the bottom
    /// bar's items VERTICALLY … looks kind of weird … what's in that menu
    /// and how it looks needs to be a bit clearer"*). ONE calm control in
    /// four groups, read top-down: where you are (with the fold) · the
    /// block's doors, paired — `block ▾ · Takes`, then its two time
    /// controls `commit ⌘S · history` · the note's doors `note ▾ ·
    /// comments · Aa` · ONE count line, the word-target door. Pairs are
    /// `ViewThatFits`: side by side where the rail's width allows, stacked
    /// where it does not — a chrome label never wraps mid-word (P-8). The
    /// rail's `Nw block` / `Nw selected` lines are GONE (C-6 — a narrow rail
    /// is exactly where a metric "just because" reads as noise; the flat
    /// bar keeps its R11 status idiom). Every door survives.
    private var verticalBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(caretLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Button {
                    sideRailCollapsed.toggle()
                } label: {
                    Text(sideRailCollapsed ? "▸" : "▾")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .padding(.horizontal, 2)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(sideRailCollapsed
                    ? "Show this note's controls" : "Fold the controls away")
            }
            if !sideRailCollapsed {
                railPair {
                    blockMenu
                    gestureButton("Takes", available: model.gestureAvailability.takes,
                                  action: model.openCaretFan)
                }
                railPair {
                    Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                        .disabled(model.caretVariantID == nil || model.header?.locked == true)
                        .help("An immutable savepoint of the take under the caret")
                    Button(tokens.chromeLabel(BlockHistoryPath.doorLabel)) {
                        model.requestBlockHistory()
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens))
                    .help("Everything this block has been: each take's saved moments, "
                        + "its archived and deleted takes, and the block it came out of")
                }
                Divider().overlay(tokens.line).padding(.vertical, 1)
                railPair {
                    presentingNoteDoors(noteMenu)
                    Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens))
                        .help("The caret block's comments — working remarks on a block, "
                            + "never per-take")
                    VoicedChip(
                        tokens: tokens, text: FormattingDoor.label, on: formattingShown
                    ) {
                        formattingShown.toggle()
                    }
                    .help(FormattingDoor.help(expanded: formattingShown))
                    .popover(isPresented: $formattingShown, arrowEdge: .trailing) {
                        // The same slide-out, summoned: the formatting
                        // cluster and the newlines chip, at their own
                        // ideal width.
                        formattingRow
                    }
                }
                Divider().overlay(tokens.line).padding(.vertical, 1)
            }
            HStack(spacing: 6) {
                if let total = model.postWordCount {
                    WordTargetFace(
                        tokens: tokens, baseLabel: "\(total.formatted())w in note",
                        words: model.postWordCount,
                        target: model.header?.wordTarget,
                        onSet: { target in await model.setPostWordTarget(target) })
                }
                Spacer(minLength: 4)
                Button("?") { openWindow(id: "variorum-helper") }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(HelperCheatSheet.summary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.room, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tokens.line, lineWidth: 1))
    }

    /// A rail group: its doors side by side where they fit, else stacked
    /// — never a wrapped label.
    private func railPair<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) { content() }
            VStack(alignment: .leading, spacing: 6) { content() }
        }
    }

    private var horizontalBody: some View {
        VStack(spacing: 0) {
            Divider().overlay(tokens.line)
            // Ledger row 28: the formatting row slides out ABOVE the flat row
            // — upward, away from the page's bottom edge — so the doors she
            // was reaching for do not move under her cursor when it opens.
            if formattingShown {
                formattingRow
                Divider().overlay(tokens.line)
            }
            // Batch 9 (R101): the round-2 status-line grammar — quiet
            // voiced words on the room; every door stays. 13b 3F (N15):
            // the bar is ADAPTIVE — one row where it fits (the detail
            // editor), two rows where it doesn't (the book-inline form,
            // whose default width wrapped every label mid-word — "com mit
            // ⌘S"; her call: "it needs 2 rows or something"). MEASURED
            // width, not ViewThatFits: every cluster is compressible
            // (lineLimit(1) truncation), so ViewThatFits judged the
            // one-row arrangement as "fitting" at any width and never
            // fell through — the flexible-children gotcha, seen live.
            // 13g batch 7 (her ruling R6-2, from round 5: *"i feel like the
            // bottom bar is looking a little bit overly crowded … something
            // where there could be groupings on the bottom of settings and
            // clicking on them brings all the options out in a slide - almost
            // like tab groups in a brwoser"*): the flat row keeps exactly
            // what she named — the block line, `block ▾`, the take door,
            // commit, `note ▾`, comments, newlines-make-blocks, the counts
            // and `?` — and the rest slide out of the two groups. The doors
            // are the SAME registry ids in the same numbers; only where they
            // are rendered moved (`renderedCapabilities` is unchanged, and
            // the registry walk proves it).
            // Row 81: the width-responsive FOLD (Act 10 item 6's "collapse
            // only when the window is genuinely small", delivered as one
            // row that folds rather than two rows that truncate). The
            // folded rows' members are `fixedSize`: a label never truncates,
            // the tier guarantees the fit.
            Group {
                switch Self.arrangement(width: barWidth) {
                case .full:
                    HStack(spacing: 10) {
                        identityCluster
                        StatusDot(tokens: tokens)
                        postCluster
                        Spacer()
                        trailingCluster
                    }
                case .folded:
                    // A `Group`'s modifier applies to EACH child: every member
                    // takes its ideal width, so none can truncate; the tier
                    // guarantees they fit (the pin holds the edge).
                    HStack(spacing: 10) {
                        Group {
                            caretLine
                            blockMenu
                            commitDoor
                            historyDoor
                            presentingNoteDoors(noteMenu)
                            overflowMenu(compact: false)
                        }
                        .fixedSize()
                        Spacer(minLength: 8)
                        Group {
                            noteTotalFace
                            helperDoor
                        }
                        .fixedSize()
                    }
                case .compact:
                    HStack(spacing: 10) {
                        Group {
                            caretLine
                            blockMenu
                            presentingNoteDoors(overflowMenu(compact: true))
                        }
                        .fixedSize()
                        Spacer(minLength: 8)
                        helperDoor
                            .fixedSize()
                    }
                }
            }
            #if DEBUG
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(Self.barSpace))
            } action: { CommitBarGeometry.rowFrame = $0 }
            #endif
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { barWidth = $0 }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tokens.room)
            .coordinateSpace(name: Self.barSpace)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                CommitBarGeometry.barWidth = $0
            }
            #endif
        }
    }

    /// The bar's own coordinate space (row 81's DEBUG oracle reads the row's
    /// frame in it against the bar's width).
    nonisolated static let barSpace = "variorum-commit-bar"

    /// The flat row's block half: where you are, the block group, and the
    /// take door she said earns its place.
    @ViewBuilder private var identityCluster: some View {
        caretLine
        blockMenu
        takesDoor
        commitDoor
        historyDoor
    }

    /// Where you are — "block 6/23".
    private var caretLine: some View {
        Text(tokens.chromeLabel(caretLabel))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
    }

    private var takesDoor: some View {
        gestureButton("Takes", available: model.gestureAvailability.takes,
                      action: model.openCaretFan)
    }

    private var commitDoor: some View {
        Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .disabled(model.caretVariantID == nil || model.header?.locked == true)
            .help("An immutable savepoint of the take under the caret")
    }

    /// Ledger row 17 — THE PAIR. It is never disabled: unlike commit,
    /// which needs a take to write into, a block always has a history to
    /// read, and where the caret is nowhere the act SPEAKS the registry's
    /// note rather than sitting grey (P-2, the standing fire-and-speak
    /// posture for a door with no target).
    private var historyDoor: some View {
        Button(tokens.chromeLabel(BlockHistoryPath.doorLabel)) {
            model.requestBlockHistory()
        }
        .buttonStyle(VoicedButtonStyle(tokens: tokens))
        .help("Everything this block has been: each take's saved moments, "
            + "its archived and deleted takes, and the block it came out of")
    }

    /// **`more ▾`** (row 81): the doors a folded row slides out of sight —
    /// the same acts, the same calls, in a menu. `compact` folds the whole
    /// block-and-note family in (commit · takes · history · comments · Aa ·
    /// the note's items as a submenu); the folded row keeps commit, history
    /// and `note ▾` visible and folds only takes · comments · Aa.
    private func overflowMenu(compact: Bool) -> some View {
        VoicedMenu(tokens: tokens, label: "more") {
            if compact {
                Button("commit ⌘S") { model.commitCaretVariant() }
                    .disabled(model.caretVariantID == nil || model.header?.locked == true)
            }
            Button("Takes") { model.openCaretFan() }
            if compact {
                Button(BlockHistoryPath.doorLabel) { model.requestBlockHistory() }
            }
            Divider()
            Button("comments") { model.openCaretComments() }
            Button(formattingShown
                ? "\(FormattingDoor.label) — put the formatting row away"
                : "\(FormattingDoor.label) — formatting") { formattingShown.toggle() }
            if compact {
                Divider()
                Menu("note") { noteMenuItems }
            }
        }
        .help(compact
            ? "The rest of this bar at this width: commit, takes, history, "
                + "comments, formatting, and the note's own menu"
            : "The rest of this bar at this width: takes, comments and formatting")
    }

    /// The note's word total — the word-target door alone (the folded
    /// row's counts, C-6's verdict from the side rail: the block/selected
    /// counts are noise where the width is short).
    @ViewBuilder private var noteTotalFace: some View {
        if let total = model.postWordCount {
            WordTargetFace(
                tokens: tokens, baseLabel: "\(total.formatted())w in note",
                words: model.postWordCount,
                target: model.header?.wordTarget,
                onSet: { target in await model.setPostWordTarget(target) })
        }
    }

    /// Sitting 9 (R73/R91): hover = the cheat sheet; click = the full
    /// helper with the dictionary.
    private var helperDoor: some View {
        Button("?") { openWindow(id: "variorum-helper") }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(HelperCheatSheet.summary)
    }

    /// **block ▾** (R6-2): the structural gestures plus the two block-scoped
    /// mints, one slide-out. Fire-and-DO is unchanged — every row invokes the
    /// same call its button did, so a refusal still speaks (P-2). What is
    /// deliberately gone is the per-door DIMMING by the planner's verdict:
    /// a menu row cannot carry it, and the Takes bar's own block menu has
    /// shipped enabled-and-speaking since 13b (QUESTIONS #52).
    private var blockMenu: some View {
        VoicedMenu(tokens: tokens, label: "block") {
            Button("Divide") { model.divideAtCursor() }
            Button("Extract") { model.extractSelection() }
            Button("Make Block") { model.makeBlockFromSelection() }
            Button("Merge") { model.mergeBlocks() }
            Divider()
            Button("＋ New block below this one (⌘⇧⏎)") {
                Task { await model.insertBlockBelowCaret() }
            }
            // 18c batch 3 (her U-6): the block-sized half of the newline
            // repair, beside the block mints because that is what it does —
            // it turns this block's paragraphs into blocks.
            Button(SplitAtNewlinesCopy.blockDoor) {
                Task { await model.splitCaretBlockAtNewlines() }
            }
            // Ledger row 14 (F1): the kept road, beside the clocked one and
            // BEFORE it — the order the menu bar's Block menu and the block
            // context menu already use, so the three doors read alike.
            Button(CapabilityRegistry.capability(.archiveBlock).menuTitle()) {
                Task { await model.archiveCaretBlock() }
            }
            Button("− Delete this block") {
                Task { await model.deleteCaretBlock() }
            }
        }
        .help("Everything block-scoped: divide, extract, make block, merge, "
            + "the two block mints, splitting this block at its newlines, and "
            + "the two ways to set a block aside")
    }

    /// The flat row's note half: `note ▾`, comments, the newlines chip — and
    /// (13k K7) the formatting toolbar, which sits with them because it acts
    /// on the text of the note you are writing.
    @ViewBuilder private var postCluster: some View {
        presentingNoteDoors(noteMenu)
        Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The caret block's comments — working remarks on a block, never per-take")
        StatusDot(tokens: tokens)
        // Ledger row 28 (her kickoff addition, scope ruled at the sitting):
        // the eight formatting doors and the newlines chip condense to ONE
        // Aa chip; everything else in this bar stays visible at rest.
        VoicedChip(
            tokens: tokens, text: FormattingDoor.label, on: formattingShown
        ) {
            formattingShown.toggle()
        }
        .help(FormattingDoor.help(expanded: formattingShown))
    }

    /// What Aa slides out: the formatting cluster, and the newlines chip
    /// beside it (13b 4D — N34/S4-14/S4-21: the one_block face's Write half,
    /// an in-view setting chip over the Phase-1 machinery; the header
    /// observation keeps `effectiveSegmentation` and this chip live).
    @ViewBuilder private var formattingRow: some View {
        HStack(spacing: 10) {
            FormatBar(tokens: tokens, status: model.session.status)
            StatusDot(tokens: tokens)
            newlinesChip
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(tokens.room)
    }

    /// **note ▾** (R6-2): history, the seal, the entry date. The date
    /// picker's popover is anchored on the MENU rather than on a row —
    /// a menu item cannot host one (`presentingNoteDoors`, which the full
    /// and folded rows put on this menu and the compact row on the
    /// overflow menu that carries the note's items as a submenu).
    private var noteMenu: some View {
        VoicedMenu(tokens: tokens, label: "note") {
            noteMenuItems
        }
        .help("The note itself: its versions, its seal, its date, and the "
            + "repair that makes every newline a block (its tray is the tray "
            + "icon at the top of the note; a block's savepoints are the "
            + "history door beside commit)")
    }

    /// The note menu's two presentations — the date picker's popover and
    /// the delete confirm — on whichever control carries the note's items.
    private func presentingNoteDoors<V: View>(_ control: V) -> some View {
        control
            .popover(isPresented: $datePickerShown, content: datePickerPopover)
            .deleteNoteConfirmDialog($pendingDelete) { confirm in
                NoteDeletion.fire(session: model.session, postIDs: confirm.postIDs)
            }
    }

    /// The note's items — one list, rendered by `noteMenu` and, in the
    /// compact row, by the overflow's `note` submenu.
    @ViewBuilder private var noteMenuItems: some View {
        Group {
            // (The "History" item LEFT this menu at the post-13l polish round,
            // ledger row 17 — and its being here is exactly what her F2 report
            // was about: *"it's unclear that history is under Note, that makes
            // it seem like the Note's history."* It was the BLOCK's, and it is
            // now a door in the bar that says so.)
            // The post-13l polish round (ledger rows 16/23): the note's own two
            // time controls, in the menu that IS the note. They sit first
            // because they are what the menu is most often opened for now.
            Button(CapabilityRegistry.capability(.saveNoteVersion).menuTitle()) {
                Task { await model.saveNoteVersion() }
            }
            Button(VersionsPath.menuLabel) { model.requestNoteVersions() }
            Divider()
            // 18c batch 3 — **HER U-6's own button**, in the menu that IS the
            // note: every paragraph in this note becomes its own block, the
            // takes staying with their top paragraph. One ⌥⌘Z undoes it.
            Button(SplitAtNewlinesCopy.noteDoor) {
                Task { await model.splitEveryNewlineIntoBlocks() }
            }
            Divider()
            Button(model.header?.locked == true ? "Unseal" : "Seal") {
                model.toggleSeal()
            }
            Divider()
            Button(model.header?.entryDate.map { "Date: \($0)…" } ?? "Set date…") {
                pickedDate = Self.date(fromDay: model.header?.entryDate) ?? Date()
                datePickerShown = true
            }
            // 13l post-close, her #77 ruling (2026-08-24): the door renders in
            // NOTE contexts only — the scraps editor composes this same bar
            // with the POOL's id, and a door that can never act isn't rendered
            // (P-2; the walk observed the pre-fence version tombstone the
            // scraps area). The act-level kind fence in `NoteDeletion.run`
            // stays as the belt; this is the braces. The availability rule is
            // the header's own kind — nil (still loading) hides with it.
            if model.header?.kind == .post {
                Divider()
                // 13l Act 2 (item 3) — HER DOOR, in the menu she went looking
                // in. It is ordinary move-to-Trash and NOTHING else: Delete
                // Now never appears in a note context (her 13j round-3 rider),
                // so the only way past the 30 days from here is the Trash
                // itself.
                Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                    Task { pendingDelete = await NoteDeletion.ask(
                        session: model.session, postIDs: [model.postID]) }
                }
            }
        }
    }

    /// The one_block chip (its truth is the observed header).
    @ViewBuilder private var newlinesChip: some View {
        let mints = model.header?.effectiveSegmentation != .oneBlock
        VoicedChip(
            tokens: tokens,
            text: mints ? SegmentationFaceCopy.chipOn : SegmentationFaceCopy.chipOff,
            on: mints
        ) {
            Task { await model.setNewlinesMintBlocks(!mints) }
        }
        .help(SegmentationFaceCopy.help)
    }

    @ViewBuilder private func datePickerPopover() -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Entry date").font(.headline)
                DatePicker(
                    "Entry date", selection: $pickedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                HStack {
                    Button("Clear Date") {
                        datePickerShown = false
                        Task { await model.updateEntryDate(nil) }
                    }
                    Spacer()
                    Button("Set") {
                        datePickerShown = false
                        let day = JournalDay.dayString(from: pickedDate)
                        Task { await model.updateEntryDate(day) }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(12)
    }

    /// 13b 1b (AD-14): the transient status line moved to the ONE shell
    /// toast (StatusCenter — R93's readability rides there).
    @ViewBuilder private var trailingCluster: some View {
        if let words = wordCountLabel {
            // R11: word-count PROMINENCE — the accent-colored,
            // always-there part of the editing surface. 13b 4F (N36):
            // the counts are now the per-post word-target face too —
            // progress rides the label, clicking opens the setter (zero
            // new bar width; the target's truth is the observed header).
            WordTargetFace(
                tokens: tokens, baseLabel: words,
                words: model.postWordCount,
                target: model.header?.wordTarget,
                onSet: { target in await model.setPostWordTarget(target) })
        }
        helperDoor
    }

    private func gestureButton(
        _ title: String, available: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(tokens.chromeLabel(title), action: action)
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .opacity(available ? 1 : 0.55)
    }

    private var caretLabel: String {
        if model.caretBlockID != nil {
            // "block 6/23" (9d): the user-facing number is the current
            // order, derived at read time; the stable ID stays the identity.
            // 13g R5-4: the raw ID and the "blk" abbreviation are gone — one
            // shared label so this bar and the Takes bar cannot drift.
            return BlockLineLabel.caret(ordinal: model.caretOrdinal, of: model.blockCount)
        }
        if model.hasOpenTail { return "open tail" }
        return "—"
    }

    private var wordCountLabel: String? {
        var parts: [String] = []
        if let block = model.caretBlockWordCount { parts.append("\(block)w block") }
        if let selected = model.selectionWordCount { parts.append("\(selected)w selected") }
        // R11: the post total, always ambient (incremental — never a
        // whole-document walk per keystroke).
        if let total = model.postWordCount {
            parts.append("\(total.formatted())w in note")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// "yyyy-MM-dd" → a local-calendar Date (the picker's seed). Pure and
    /// nonisolated: the View conformance makes CommitBar MainActor-isolated,
    /// and an isolated static traps when called off-main (the 9c
    /// SignInFlow lesson).
    nonisolated static func date(fromDay day: String?) -> Date? {
        guard let day, JournalDay.isValid(day) else { return nil }
        let parts = day.split(separator: "-").compactMap { Int($0) }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        components.hour = 12
        return Calendar.current.date(from: components)
    }
}

#if DEBUG
/// Row 81's DEBUG oracle (the `MastheadGeometry` idiom): the flat bar's
/// row frame in the bar's own space and the bar's width — so a pin holds
/// "one row, nothing past the edge" at a narrow measure as two numbers,
/// not a layout the code merely intends.
@MainActor
enum CommitBarGeometry {
    static var rowFrame: CGRect?
    static var barWidth: CGFloat?

    static func reset() {
        rowFrame = nil
        barWidth = nil
    }
}
#endif
