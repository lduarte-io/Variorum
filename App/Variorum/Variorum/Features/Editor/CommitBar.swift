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

    /// Wave 2c gave this bar a SECOND arrangement so the book Outline's
    /// focused note could carry its doors in the right gutter; **18d batch 1
    /// (her U-10) moved them to the sidebar's note box and retired the
    /// gutter entirely (U-17)**, so `.vertical` retired with it and `.box`
    /// took its place. ONE brain, every door, two arrangements — the drift a
    /// second bar would invite is exactly why this is an axis and not a
    /// sibling view.
    ///
    /// - `.horizontal` — the standing bottom bar, byte-unchanged.
    /// - `.box` — the sidebar note box's live state (mockup figure C): the
    ///   same doors as a two-column grid at the sidebar's pitch, the
    ///   formatting cluster summoned as a popover (its ideal width is wider
    ///   than any sidebar), and the counts as the box's footer. It draws NO
    ///   caret line: the box's own identity line carries where she is, from
    ///   the same `BlockLineLabel` this bar uses, so the two cannot drift.
    enum Axis { case horizontal, box }
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
    /// 13i-d U6 (k) — the note ▾ menu's cross-wing doors (Takes' bar carries
    /// the twin, R6-2): the shared wings model from the environment, the open
    /// note's wing + name, and the move's pending confirm.
    @Environment(WingsModel.self) private var wings: WingsModel?
    @State private var wingContext: NoteMenuWingContext?
    /// 13n-b U2 (R-13nb-4): the open note's Private row's state.
    @State private var privacy: NotePrivacyState?
    @State private var wingAsk: WingsModel.MoveAsk?
    /// N15: the bar's measured width — the one-row/two-row switch.
    @State private var barWidth: CGFloat = 0
    #if DEBUG
    /// **This bar's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape). DEBUG-only.
    @State private var oracleOwner = UUID()
    #endif

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
            // 18f batch 1 (her U-4): the two summoned doors, each beside its
            // plain twin in the block ▾ group.
            .divideWithCeremony, .mergeWithCeremony,
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
            // 13i-d U6 (k): the note ▾ menu's cross-wing doors (Takes' twin).
            .moveNoteToWing, .copyNoteToWing,
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
            // 13n-a (R-13n-11): Copy for AI — the note ▾ menu's push gesture.
            .copyForAI,
            // 13n-b U2 (R-13nb-4): the Private row, beside it (NOTE contexts).
            .markNotePrivate,
            // 18c batch 3 (her U-6): the note ▾ row and the block ▾ row.
            .splitEveryNewlineIntoBlocks, .splitBlockAtNewlines,
            // 13u4 UNIT C2 (her item 9, R-13u4-4): the `block ▾` row,
            // rendered only where the selection lies inside one block.
            .moveSelectionToTake,
        ]
        // 13k K7: the formatting toolbar's own eight, from ITS table (the
        // cluster is rendered here, so its doors are declared here).
        + FormatBar.renderedCapabilities
    }

    /// **The `block ▾` menu's six structural rows, titles and all** (13u4
    /// UNIT S1 — her item 7: *"where is the merge shortcut said ?? I don't
    /// see it in the shortcuts list or in the menu"*).
    ///
    /// Two things this static fixes at once. (1) Every row's words come from
    /// the registry through the ONE chord formatter (`menuTitle`), so the
    /// plain acts wear their declared keys exactly as the two ceremony rows
    /// already did — before this, the four plain rows were hard-coded
    /// literals sitting beside chorded ceremony rows, which made the menu
    /// read as *"the ⌥ variant has a key and the plain act does not."*
    /// (2) A truth pin can READ what the menu renders: a private
    /// `@ViewBuilder` is unreachable from a test, and a claim about a chord
    /// being visible has to be checkable (the H pattern — prose names a
    /// chord ⇒ a pin asserts the surface renders it).
    ///
    /// The bar's own SHORT words are kept (`menuTitle`'s override): this
    /// menu has always said "Divide", not "Divide Block at Cursor", and the
    /// chord is the thing that was missing, not the wording.
    static var structuralRows: [(id: CapabilityID, title: String)] {
        [
            (.divide, CapabilityRegistry.capability(.divide).menuTitle("Divide")),
            (.divideWithCeremony,
             CapabilityRegistry.capability(.divideWithCeremony).menuTitle()),
            (.extract, CapabilityRegistry.capability(.extract).menuTitle("Extract")),
            (.makeBlock,
             CapabilityRegistry.capability(.makeBlock).menuTitle("Make Block")),
            (.merge, CapabilityRegistry.capability(.merge).menuTitle("Merge")),
            (.mergeWithCeremony,
             CapabilityRegistry.capability(.mergeWithCeremony).menuTitle()),
        ]
    }

    /// The six rows' acts, one switch so the list above and the doors below
    /// cannot drift into a row that fires the wrong gesture.
    private func run(_ id: CapabilityID) {
        switch id {
        case .divide: model.divideAtCursor()
        case .divideWithCeremony: model.divideAtCursorWithCeremony()
        case .extract: model.extractSelection()
        case .makeBlock: model.makeBlockFromSelection()
        case .merge: model.mergeBlocks()
        case .mergeWithCeremony: model.mergeBlocksWithCeremony()
        default: break
        }
    }

    var body: some View {
        Group {
            if axis == .box {
                boxBody
            } else {
                horizontalBody
            }
        }
        // 13s-b U2 (A2): the tour's cards never cover the bar.
        .tourKeepClear()
#if DEBUG
        // 18d batch 1's retirement oracle: which arrangements are ON SCREEN.
        // "The book's editing surfaces render no bar of their own" is a claim
        // about what is mounted, and only a mount can answer it.
        .onAppear {
            CommitBarGeometry.mounted[model.postID, default: [:]][
                Self.name(of: axis), default: 0] += 1
        }
        .onDisappear {
            CommitBarGeometry.mounted[model.postID, default: [:]][
                Self.name(of: axis), default: 0] -= 1
            // 18k C4: this bar's row and width, and no other window's bar's.
            CommitBarGeometry.release(owner: oracleOwner)
        }
#endif
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
        // 13u3 UNIT D (item 14): the commit door's optional name. ONE
        // binding on the bar, so the two arrangements and the three
        // width tiers cannot put up two fields; the popover hangs off the
        // bar's own bounds, which is where the commit door is in every tier
        // (in `.compact` it is inside `more ▾`, and the bar is still the
        // thing she pressed).
        .savepointNameAsk(
            Binding(get: { model.savepointAsk }, set: { model.savepointAsk = $0 }),
            tokens: tokens
        ) { _, name in
            Task { await model.fileSavepoint(named: name) }
        }
    }

    /// **THE BOX'S BAR** (18d batch 1, her U-10: *"The block menu should move
    /// to being where the 'this note, write, lenses, compare, etc.' menu
    /// is"*). Mockup figure C, state 3: a two-column grid of the SAME doors
    /// this bar has always rendered — `block ▾` · Takes / `commit ⌘S` ·
    /// history / `note ▾` · comments — one wide row for the formatting door
    /// and the newlines chip, and the counts as the box's footer.
    ///
    /// What is deliberately NOT here, and why:
    /// - **the caret line** — the box's own identity line carries it (from
    ///   the same `BlockLineLabel`, so the two can never disagree);
    /// - **the fold** — the retired side rail folded because it stood in the
    ///   prose's gutter and she asked for it back (row 40); a box that never
    ///   changes height has nothing to fold away from;
    /// - **the box's own frame** — the box draws the border and the room, so
    ///   this arrangement is transparent chrome inside it.
    ///
    /// Every door survives at every width: each pair falls to one column
    /// where two will not fit, and the newlines chip rides inside the Aa
    /// popover where the wide row will not hold both — which is exactly what
    /// the flat bar's own folded and compact tiers do (row 81).
    private var boxBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            boxPair {
                boxCell(blockMenu)
                boxCell(takesDoor)
            }
            boxPair {
                boxCell(commitDoor, emphasised: true)
                boxCell(historyDoor)
            }
            boxPair {
                boxCell(presentingNoteDoors(noteMenu))
                boxCell(commentsDoor)
            }
            formattingWideRow
            boxFooter
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// A pair of cells: side by side where the box's width allows, stacked
    /// where it does not — a chrome label never wraps mid-word (P-8). The
    /// members are `fixedSize` inside the first arrangement so `ViewThatFits`
    /// measures their IDEAL widths: every cluster here is compressible, and
    /// a flexible child makes `ViewThatFits` judge any arrangement as fitting
    /// (the N15 gotcha, seen live on this same bar).
    private func boxPair<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 4) { content() }
            VStack(alignment: .leading, spacing: 4) { content() }
        }
    }

    /// One cell of the grid (the mockup's `.box .r`): the door itself, in a
    /// bordered 26-pt box at the sidebar's own pitch. `emphasised` is
    /// commit's — the column's OWN selected-row grammar (the wash under
    /// accent words), not a filled web button: a filled cell among five
    /// outlined ones at 69 pt shouts, and the wash is what every other
    /// "this one" in this column already looks like.
    private func boxCell<V: View>(_ content: V, emphasised: Bool = false) -> some View {
        content
            // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
            // states its own line policy, so its IDEAL width can never be a
            // wrapped one (the b6dae25 class's window-sizing hazard).
            // Every cell of this grid is one door on one line — the 24-pt
            // `boxCellHeight` below is the same decision in the other axis.
            .lineLimit(1)
            .fixedSize()
            .frame(maxWidth: .infinity)
            .frame(height: Self.boxCellHeight)
            .background(
                emphasised ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(tokens.surface),
                in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(emphasised ? tokens.accent.opacity(0.5) : tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
    }

    /// The mockup's `.box .r` is 26; the walk measured the TERMINAL voice's
    /// two-line identity line pushing the footer past the box's floor at the
    /// default sidebar width (its monospace runs wider than Study's), so the
    /// cell is 24 — the implementer's latitude figure C's caption names, and
    /// two points a voice cannot see against a footer she would have had to
    /// scroll for.
    nonisolated static let boxCellHeight: CGFloat = 24

#if DEBUG
    nonisolated static func name(of axis: Axis) -> String {
        switch axis {
        case .horizontal: return "horizontal"
        case .box: return "box"
        }
    }
#endif

    private var commentsDoor: some View {
        Button(tokens.chromeLabel("comments")) { model.openCaretComments() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens))
            .help("The caret block's comments — working remarks on a block, "
                + "never per-take")
    }

    /// The wide row: the formatting door and the newlines chip. Where both
    /// will not fit, the chip rides inside the popover the door opens (the
    /// formatting row carries it there already), so no door is lost — the
    /// flat bar's folded tier, one surface over.
    private var formattingWideRow: some View {
        let aa = VoicedChip(
            tokens: tokens, text: FormattingDoor.label, on: formattingShown
        ) {
            formattingShown.toggle()
        }
        .help(FormattingDoor.help(expanded: formattingShown))
        .popover(isPresented: $formattingShown, arrowEdge: .trailing) {
            // The same slide-out, summoned: the formatting cluster and the
            // newlines chip, at their own ideal width.
            formattingRow
        }
        return ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                aa.lineLimit(1).fixedSize()
                Spacer(minLength: 4)
                newlinesChip.lineLimit(1).fixedSize()
            }
            HStack(spacing: 6) {
                aa.lineLimit(1).fixedSize()
                Spacer(minLength: 0)
            }
        }
        .frame(height: Self.boxCellHeight)
    }

    /// The box's footer (mockup figure C): the counts and `?`. The full
    /// counts where they fit, the note's total alone where they do not —
    /// C-6's own verdict for a narrow column, and the same two faces the
    /// flat bar's full and folded rows use.
    private var boxFooter: some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider().overlay(tokens.line)
            // 18i: the book's live note gets the quiet slot in ITS footer —
            // its own row, ONE line like every other composition (the ladder
            // round 2's J39: two lines bought about one character in this
            // ~200 pt column and shoved the counts and the `?` door 14 pt on
            // every receipt that wrapped). Truncated at the column's edge,
            // the whole sentence in `help`.
            QuietReceiptLine(status: model.session.status, tokens: tokens)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 6) {
                ViewThatFits(in: .horizontal) {
                    countsFace().lineLimit(1).fixedSize()
                    countsFace(narrowed: true).lineLimit(1).fixedSize()
                }
                Spacer(minLength: 4)
                helperDoor.lineLimit(1).fixedSize()
            }
        }
    }

    /// **The bar's ONE counts face** (13u4 UNIT S2 — her item 1): the
    /// counts, her remembered condensation, and the word-target door that
    /// now lives on its context menu. `narrowed` is the width's own say —
    /// the folded row and the book box's footer pass it, and it can only
    /// shorten a FULL face, never lengthen one she condensed.
    ///
    /// *(It was two views, `trailingCountsFace` and `noteTotalFace`, one of
    /// which hard-coded the note's total. A remembered face cannot live in
    /// two views that each decide what to say.)*
    @ViewBuilder private func countsFace(narrowed: Bool = false) -> some View {
        if wordCounts.hasAnything {
            WordTargetFace(
                tokens: tokens, counts: wordCounts,
                words: model.postWordCount,
                target: model.header?.wordTarget,
                onSet: { target in await model.setPostWordTarget(target) },
                narrowed: narrowed)
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
                        // 18i (her R-Q5): the quiet slot — a receipt under
                        // her default, at the bar's trailing end BEFORE the
                        // counts. It yields first (`layoutPriority(-1)`),
                        // so no door or count ever moves for it.
                        quietReceipt
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
                        .lineLimit(1)
                        .fixedSize()
                        Spacer(minLength: 8)
                        quietReceipt
                        Group {
                            countsFace(narrowed: true)
                            helperDoor
                        }
                        .lineLimit(1)
                        .fixedSize()
                    }
                case .compact:
                    HStack(spacing: 10) {
                        Group {
                            caretLine
                            blockMenu
                            presentingNoteDoors(overflowMenu(compact: true))
                        }
                        .lineLimit(1)
                        .fixedSize()
                        Spacer(minLength: 8)
                        quietReceipt
                        helperDoor
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
            }
            #if DEBUG
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(Self.barSpace))
            } action: { CommitBarGeometry.recordRow($0, owner: oracleOwner) }
            #endif
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { barWidth = $0 }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tokens.room)
            .coordinateSpace(name: Self.barSpace)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                CommitBarGeometry.recordWidth($0, owner: oracleOwner)
            }
            #endif
        }
    }

    /// The bar's own coordinate space (row 81's DEBUG oracle reads the row's
    /// frame in it against the bar's width).
    nonisolated static let barSpace = "variorum-commit-bar"

    /// 18i: the ONE quiet slot this bar composes (both arrangements read
    /// it), reading the ONE centre — no per-bar copy, no second setting read.
    private var quietReceipt: some View {
        QuietReceiptLine(status: model.session.status, tokens: tokens)
    }

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
            // 13s-b U2: step 5 points here first ("Click Takes in the bottom
            // bar"). Chrome, never the text: the ring is the button's.
            .tourAnchor(.barTakes, cornerRadius: 5)
    }

    private var commitDoor: some View {
        Button(tokens.chromeLabel("commit ⌘S")) { model.commitCaretVariant() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .disabled(model.caretVariantID == nil || model.header?.locked == true)
            .help("An immutable saved moment of the take under the caret — name it, "
            + "or press ⏎ to save it unnamed")
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
            // 18f batch 1 (U-4): *"should be a button, not just a shortcut."*
            // Titles come from the registry with their chords, so a re-picked
            // key moves in one place.
            // 13u4 UNIT S1 (her item 7): …and the four PLAIN rows do that too
            // now. They were hard-coded literals beside two ceremony rows
            // built from `menuTitle()`, so this menu said "Merge choosing
            // takes… (⌥⌘⇧M)" next to a silent "Merge" — a face teaching the
            // opposite of the registry. All six render from `structuralRows`.
            ForEach(Self.structuralRows, id: \.id) { row in
                Button(row.title) { run(row.id) }
            }
            // 13u4 UNIT C2 (her item 9, R-13u4-4): the row appears only where
            // the selection lies inside ONE block — P-2, and the one
            // deliberate difference from this menu's fire-and-speak posture.
            // The posture retires the per-door DIMMING; it does not ask a
            // menu to offer a gesture whose population is another act's (a
            // cross-block span is Make Block from Selection's). The verdict
            // is the act's own brain's, via `gestureAvailability`.
            if model.gestureAvailability.moveToTake {
                Button(CapabilityRegistry.capability(.moveSelectionToTake).menuTitle()) {
                    Task { await model.moveSelectionToNewTake() }
                }
            }
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
            + "icon at the top of the note; a block's commits are the "
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
            .noteMenuWingDoors(
                session: model.session, postID: model.postID, wings: wings,
                context: $wingContext, ask: $wingAsk)
            // 13n-b U2 (R-13nb-4): the Private row's state, loaded per note.
            .notePrivacyDoor(session: model.session, postID: model.postID, state: $privacy)
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
            // 13n-a (R-13n-11) — COPY FOR AI: the note in the Variorum
            // document format, onto the clipboard (reads only). NOTE contexts
            // only — the scraps editor composes this bar with a pool's id,
            // and a pool is not a note (P-2; the delete door's own gate).
            if model.header?.kind == .post {
                Button(CapabilityRegistry.capability(.copyForAI).menuTitle()) {
                    let session = model.session
                    let postID = model.postID
                    Task { await CopyForAI.copy(postID: postID, session: session) }
                }
                // 13n-b U2 (R-13nb-4): "Private — never shared with AI", and
                // the note's quiet lines (a Private book holding it; the
                // clients that reach it).
                NotePrivacyMenuItems(session: model.session, postID: model.postID, state: privacy)
                Divider()
            }
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
                // 13i-d U6 (k): the note's own Move/Copy to Wing ▸ — the Library
                // and Pool rows' doors, one more renderer of the same acts:
                // NOTE contexts only (the gate above — a pool has no wing
                // doors), drawn only while another wing exists (P-2), listing
                // the wings OTHER than the note's own. Ladder B fix B: only a
                // context loaded for THIS note draws (a stale load never puts
                // another note's wing or title on these doors).
                if let wings,
                   let context = NoteMenuWingContext.matching(wingContext, postID: model.postID),
                   !wings.destinations(from: context.wingID).isEmpty {
                    Divider()
                    WingNoteDoors(
                        wings: wings, postID: model.postID, title: context.title,
                        fromWing: context.wingID, onAsk: { wingAsk = $0 },
                        onDone: {
                            // The sanity pass's NIT on fix B: an unstructured
                            // task never sees cancellation — the SUBJECT
                            // check is the guard (`reloadAdopts`).
                            Task {
                                let subject = model.postID
                                let loaded = await NoteMenuWingContext.load(
                                    model.session, postID: subject)
                                guard NoteMenuWingContext.reloadAdopts(
                                    over: wingContext, postID: subject) else { return }
                                wingContext = loaded
                            }
                        })
                }
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
        // R11: word-count PROMINENCE — the accent-colored, always-there
        // part of the editing surface. 13b 4F (N36): the counts are the
        // per-post word-target face too (zero new bar width; the target's
        // truth is the observed header). 13u4 UNIT S2 (her item 1): a click
        // condenses them and the target door moved to the context menu.
        countsFace()
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

    /// The counts in THIS bar's words — the parts, never a composed string,
    /// because her remembered face decides which of them are said (13u4
    /// UNIT S2, item 1). Every word here is byte-identical to what this bar
    /// has always said.
    private var wordCounts: WordCounts {
        WordCounts(
            unit: model.caretBlockWordCount.map { "\($0)w block" },
            selected: model.selectionWordCount.map { "\($0)w selected" },
            // R11: the post total, always ambient (incremental — never a
            // whole-document walk per keystroke).
            note: model.postWordCount.map { "\($0.formatted())w in note" },
            unitNoun: "block")
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
    // **18k UNIT C4 — the row and the width NAME THEIR OWNER** (the rule and
    // its reasons: `Core/Views/DebugOracleOwnership.swift`): the mounted
    // bar's `oracleOwner`, released when that bar leaves. They were bare
    // statics every bar overwrote — after one window closed they were ITS
    // (measured red, `DebugOracleTwoWindowTests`). `mounted` below is a
    // REFCOUNT (+1 on appear, −1 on disappear), which composes across owners
    // by construction — SAFE-AS-IS, untouched.
    private static var rowSlot = OwnedSlot<CGRect>()
    private static var widthSlot = OwnedSlot<CGFloat>()

    static var rowFrame: CGRect? { rowSlot.value }
    static var barWidth: CGFloat? { widthSlot.value }

    static func recordRow(_ frame: CGRect, owner: UUID) { rowSlot.publish(frame, owner: owner) }

    static func recordWidth(_ width: CGFloat, owner: UUID) { widthSlot.publish(width, owner: owner) }

    /// A bar leaving: its own row and width, and no other window's bar's.
    static func release(owner: UUID) {
        rowSlot.release(owner: owner)
        widthSlot.release(owner: owner)
    }
    /// 18d batch 1: how many bars of each arrangement are mounted right now,
    /// **keyed by the bar's POST** (the 18d ladder's MINOR-3). The
    /// retirement's oracle — the book's editing surfaces must mount NONE
    /// (their doors are in the sidebar's note box), and the box must mount
    /// exactly one when a note there is live. Per post, because a singleton
    /// counter asserting "zero horizontal bars" goes red the moment ANY
    /// other suite mounts an editor: suites run in parallel and `.serialized`
    /// only orders tests inside one.
    static var mounted: [String: [String: Int]] = [:]

    /// How many bars of `axis` are mounted for this post.
    static func mounted(_ axis: String, post: String) -> Int {
        mounted[post]?[axis] ?? 0
    }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() {
        rowSlot.forget()
        widthSlot.forget()
        mounted = [:]
    }
}
#endif
