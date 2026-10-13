//
//  LensesBoardView.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9 — R65/R80/R81/R83/R89): the LENSES
//  tab, the editable multi-column editor and the lens machinery's ONE home.
//  Columns are swappable SLOTS (minimum one): Chosen (the post) · named
//  lenses · unnamed lenses ("Lens 1"… — a scratch column IS an unnamed
//  lens, visibly). Two new-column doors, named by what they do (R81's
//  arranging-vs-writing language, hover-glossed): ARRANGE existing takes
//  (mints nothing) vs WRITE new takes (a fresh take on every block).
//  Panes are editable (the ONE live editor migrates — editing a pane edits
//  that take's text everywhere); the per-block ‹ take k of n › switcher
//  moves THAT column's pick only. The one rule, stated in the footer:
//  nothing here changes the post except ✓ and ⧉.
//
//  Fan styles and blooms deliberately do NOT exist here (R86: the
//  fan-style × columns entanglement is dead — fan presentations belong to
//  the Takes tab; columns are whole-post readings).
//

import SwiftUI
import VariorumCore

/// **13j J5 — what a lens says when its pick is gone**, in ONE home (the
/// `TrayPath` pattern: the notice, the button and the receipt are three
/// sentences about one fact and must not drift).
///
/// Worded to the ACTUAL state, per her ruling — "archived" and "deleted" are
/// different things with different roads back, and a single hedged sentence
/// covering both would be exactly the guessing-copy defect J8 closed one
/// batch ago.
nonisolated enum LensFallbackCopy {
    static let restoreVerb = "Restore"

    static func notice(for state: Queries.DanglingPick.State) -> String {
        switch state {
        case .archived: "This pick was archived — showing the note's take instead"
        case .deleted: "This pick was deleted — showing the note's take instead"
        case .gone: "This pick is gone — showing the note's take instead"
        case .foreign: "This pick belongs to another block — showing the note's take instead"
        }
    }

    static func restoreHelp(for state: Queries.DanglingPick.State) -> String {
        switch state {
        case .archived: "Unarchive that take — this column goes back to showing it"
        case .deleted: "Put that take back — this column goes back to showing it"
        case .gone, .foreign: ""
        }
    }

    static let restoredArchived = "Take unarchived — this lens is showing its pick again."
    static let restoredDeleted = "Take put back — this lens is showing its pick again."
    /// 13j ladder A (A3): the exact flip can revive a take ARCHIVED — the
    /// pick then still dangles (the notice re-renders as archived, Restore
    /// now offering unarchive), and the line above would have lied.
    static let restoredDeletedButArchived =
        "Take put back — it came back archived, so this pick still shows the "
        + "note's take. Restore again to unarchive it."
    /// The two states with no road: nothing to act on, said plainly rather
    /// than by a button that could only fail.
    static let nothingToRestore =
        "That take isn't here to restore — pick another one for this block."
}

struct LensesBoardView: View {
    let session: AppSession
    let postID: String
    @State private var model: TakesViewModel
    @State private var lensNamePrompt: LensPrompt?
    @State private var diffPresentation: TakesDiffPresentation?
    /// 13b 1b: the routed-command registration's lifecycle token.
    @State private var commandToken: UUID?
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

    struct LensPrompt: Identifiable {
        let columnID: String
        var id: String { "save-\(columnID)" }
    }

    /// 13b Stage 3 (3D — N6): the rename door's payload.
    struct LensRenamePrompt: Identifiable {
        let lensID: String
        let currentName: String
        var id: String { "rename-\(lensID)" }
    }

    @State private var lensRenamePrompt: LensRenamePrompt?
    /// 13b 4C (S4-2d): the block drag-reorder's drop indicator.
    @State private var dropTargetBlockID: String?
    @State private var dropAtEnd = false

    /// The registry ids the column-header menus render (13b Stage 3, 3D —
    /// walk-asserted with the other contextMenu statics).
    static let columnMenuCapabilities: [CapabilityID] = [.renameLens]

    /// The Act 10 correction round, row 16: the board's ONE horizontal inset
    /// — the toolbar leads where the rows lead (the ⠿ handle's edge); the
    /// toolbar sat at 24 while the rows sat at 12.
    static let boardInset: CGFloat = 12
    /// The board's own coordinate space (the DEBUG geometry oracle's).
    static let boardSpace = "lenses-board"

    /// The drag payload (one post — no cross-post scoping needed here).
    static func dragPayload(blockID: String) -> String {
        "lens-move:\(blockID)"
    }

    static func parseDragPayload(_ raw: String) -> String? {
        guard raw.hasPrefix("lens-move:") else { return nil }
        return String(raw.dropFirst("lens-move:".count))
    }

    init(session: AppSession, postID: String, model: TakesViewModel? = nil) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model ?? TakesViewModel(session: session, postID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            // 13b 1b (AD-14): the transient status line moved to the ONE
            // shell toast (StatusCenter — its lineLimit stays load-bearing
            // there, the b6dae25 class); the board renders state banners
            // only.
            if model.projection.sealed {
                Text("Sealed note — takes are viewable; choosing and new takes are frozen.")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)
            }
            content
            TakesBottomBar(model: model)
        }
        .background(tokens.surface)
        .coordinateSpace(name: Self.boardSpace)
        .debugProbeScope(session)
        .task { await model.start() }
        .onAppear {
            model.host = .lenses
            // 13b 1b (P-4): registered handler, not a notification.
            commandToken = session.commandRouter.registerHandler { handleRouted($0) }
            // 13n-b U4: a parked lens landing (show_in_app / "Open ›").
            model.consumePendingLensLanding()
        }
        .onChange(of: session.commandRouter.pendingLensLanding) { _, _ in
            model.consumePendingLensLanding()
        }
        .onDisappear {
            if let commandToken {
                session.commandRouter.unregisterHandler(commandToken)
            }
            model.teardown()
        }
        .sheet(item: $diffPresentation) { diff in
            DiffView(
                leftTitle: diff.leftTitle, rightTitle: diff.rightTitle,
                leftText: diff.left, rightText: diff.right, tokens: tokens)
        }
        .sheet(item: $lensNamePrompt) { prompt in
            LensNameSheet { name in
                Task { await model.saveScratchAsLens(columnID: prompt.columnID, name: name) }
            }
        }
        .sheet(item: $lensRenamePrompt) { prompt in
            LensNameSheet(title: "Rename lens", initialName: prompt.currentName) { name in
                Task { await model.renameLens(prompt.lensID, to: name) }
            }
        }
        .sheet(item: $model.divideWCeremony) { state in
            // 13d Batch 3 (A9): the take ceremony mounts HERE — a fanned
            // block's divide never leaves this view. Any dismissal other
            // than Divide is a cancel; no rows are touched by opening.
            DivideWSheet(ceremony: model.ceremony, presented: state)
        }
    }

    /// The Lenses routed-command handler (13b 1b): the take family as
    /// before, plus the fire-and-DO structural doors and the native
    /// add-block door (shared model machinery with the Takes board).
    private func handleRouted(_ command: RoutedCommand) -> Bool {
        switch command {
        case .takes(let takes):
            handleTakesCommand(takes)
            return true
        case .structural(let act):
            // 13d Batch 3 (A9): the shared model machinery, same as Takes
            // — divide native, the rest carried (the deleteBlock/callout
            // precedent: a native door lands in BOTH handlers).
            model.runStructuralDoor(act)
            return true
        case .deleteInEveryTake:
            model.moveToWriteAndRun(.deleteInEveryTake)
            return true
        case .commit:
            // 13u3 UNIT D: the same door as Takes — one model, one bar.
            model.askSavepointName()
            return true
        case .addBlockAtEnd:
            Task { await model.addBlockAtEnd() }
            return true
        case .insertBlockBelow:
            // 13b 4D (N28/S4-13): the shared model machinery — the mint's
            // pane takes the ring via the landing (first column resolves).
            Task { await model.insertBlockBelowFocused() }
            return true
        case .deleteBlock:
            // 13c 1B (A8): the shared model machinery, same as Takes.
            Task { await model.deleteFocusedBlock() }
            return true
        case .archiveBlock:
            // 13j (her round-7 ruling): the shared machinery again.
            Task { await model.archiveFocusedBlock() }
            return true
        case .toggleSeal:
            Task { await model.toggleSeal() }
            return true
        case .comments:
            model.requestComments()
            return true
        case .callout(let edit):
            // 13c R2-2 (A13(a)): the shared model machinery, same as Takes.
            Task { await model.applyCallout(edit) }
            return true
        case .pageFan:
            return false  // fan pages live on the Takes board
        case .copyAllTakes:
            // 13e E6 (A21): the shared model machinery, same as Takes.
            Task { await model.copyAllTakes() }
            return true
        case .takeToBlockBelow:
            // 13e E5 (A20): the shared model machinery, same as Takes.
            Task { await model.moveTakeIntoBlockBelow() }
            return true
        case .takesToBlocks:
            // 13e E6b (A21/A45): likewise.
            Task { await model.turnTakesIntoBlocks() }
            return true
        case .showOriginBlock:
            // 13j J3: the shared model machinery, same as Takes and Write.
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
        case .find:
            // QoL batch 3 (L6): find is the full-document editor's — a lens
            // column is one take's pane, not the post's text. Declining lets
            // the router speak the declared note rather than a per-site copy.
            return false
        }
    }

    /// The Lenses half of the R73 family: the focused pane's COLUMN is the
    /// thread — branching diverges the thread; stepping moves its pick.
    private func handleTakesCommand(_ command: TakesCommand) {
        switch command {
        case .toggleFan:
            // Fire-and-DO (13b 1b — the lecture retired): blooms live in
            // Takes, so GO there, visibly, and bloom the focused block. A
            // refused switch clears the parking (the round-1 MAJOR's
            // half-a pattern); `requestMode` speaks the refusal itself.
            if let pane = model.focusedPane {
                session.commandRouter.pendingTakesLanding =
                    .bloom(postID: postID, blockID: pane.blockID)
            }
            if !session.commandRouter.requestMode(.takes, postID: postID) {
                session.commandRouter.pendingTakesLanding = nil
            }
        case .closeAll:
            break
        case .branch:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a pane first — ⌘T diverges that column at that block.")
                return
            }
            Task {
                await model.divergeHere(
                    columnID: pane.columnID, blockID: pane.blockID,
                    fromVariantID: pane.variantID)
            }
        case .blank:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a pane first — ⌥⌘T adds a blank take on that block.")
                return
            }
            // R2-A: ONE brain with the bar/menu doors (host-gated inside).
            // The old mint-then-pick pair REFUSED the pick on the Chosen
            // column after minting — an invisible take plus a lecture.
            Task {
                await model.newBlankTakeRevealed(
                    blockID: pane.blockID, preferredColumnID: pane.columnID)
            }
        case .blankChoose:
            guard let pane = model.focusedPane else {
                model.refuse("Click into a pane first — ⇧⌥⌘T opens a blank take as chosen there.")
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
            if let pane = model.focusedPane,
               let column = model.columns.first(where: { $0.id == pane.columnID }),
               case .scratch = column.kind {
                lensNamePrompt = LensPrompt(columnID: column.id)
            } else if let scratch = model.columns.first(where: {
                if case .scratch = $0.kind { return true } else { return false }
            }) {
                lensNamePrompt = LensPrompt(columnID: scratch.id)
            } else {
                model.refuse("Nothing unnamed to save — named lenses save themselves as you work.")
            }
        }
    }

    // MARK: - Header

    /// Batch 9 (R101), reshaped at wave 2c (item 15): the align chip, the
    /// ?-disclosure (the retired footer sentence's new home — her copy
    /// doctrine: structure first, a sentence behind ? for depth), and the
    /// column door as a generous calm control.
    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if model.columns.count > 1 {
                VoicedChip(
                    tokens: tokens,
                    text: model.alignmentLocked ? "align: on" : "align: off",
                    on: model.alignmentLocked
                ) { model.alignmentLocked.toggle() }
                    .help("Locked: registered comparison rows (honest whitespace). "
                        + "Unlocked: each column flows as its own read.")
                    .lensesGeometryProbe(.toolbarLead)
            }
            Spacer()
            Button("?") { ruleShown.toggle() }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .popover(isPresented: $ruleShown, arrowEdge: .bottom) {
                    // The ONE rule — the exact sentence the footer carried,
                    // now summoned instead of standing (item 15's bar: the
                    // structure teaches; the words wait behind the ?).
                    Text("Columns are ways of looking at the same note. Nothing here "
                        + "changes the note except ✓ (make this the note) and ⧉ (make "
                        + "a new note). Typing edits the take you're in — the same "
                        + "take, everywhere it appears.")
                        .font(tokens.small)
                        .foregroundStyle(tokens.ink)
                        .frame(width: 300, alignment: .leading)
                        .padding(14)
                }
                .help("What a lens column is — the one rule")
            addColumnMenu
        }
        .padding(.horizontal, Self.boardInset)
        .padding(.vertical, 8)
    }

    @State private var ruleShown = false

    /// The add-column MENU ITEMS — one body behind both doors (the header
    /// word-menu and the 4C dashed stub column below).
    @ViewBuilder
    private var addColumnMenuItems: some View {
        Button("New lens — arrange existing takes") { model.addScratchColumn() }
            .help("A fresh way of looking that starts as a mirror of the note. "
                + "Flip any block to a take that already exists — nothing new is written.")
        Button("New lens — write new takes") {
            Task { await model.addWriteColumn() }
        }
        .help("A fresh take on EVERY block, branched from what the note shows — "
            + "a full rewrite pass beside the original. New takes are written.")
        if !model.projection.lenses.isEmpty {
            Divider()
            ForEach(model.projection.lenses, id: \.id) { lens in
                Button("Open “\(lens.name)”") { model.addLensColumn(lens.id) }
            }
        }
    }

    private var addColumnMenu: some View {
        VoicedMenu(tokens: tokens, label: "+ column", role: .primary) {
            addColumnMenuItems
        }
        .disabled(model.columns.count >= 4)
        .help("You can have more views than you have takes — a column is a way of looking, not a copy.")
    }

    /// 13b 4C (S4-10/N32d — she could not find the "+ column" door): while
    /// ONE column is open, an EMPTY DASHED COLUMN waits beside it — the
    /// shelf's dashed new-post grammar, the door rendered exactly where a
    /// column would appear. It retreats once a second column exists (the
    /// header word-menu remains the standing door). An in-view affordance
    /// of the same un-registered add-column act, recorded — not a new
    /// registry act.
    ///
    /// The Act 10 correction round, row 16: a HEADER-HEIGHT door at the
    /// strip's end — it used to fill the page's whole height with its two
    /// lines floating mid-way down ("a lone '+ column' ghost floating
    /// mid-right", her image 9). Its top meets the header cards' top.
    private var addColumnStub: some View {
        Menu {
            addColumnMenuItems
        } label: {
            VStack(spacing: 8) {
                Text(tokens.chromeLabel("＋ column"))
                    .font(tokens.mono)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel("open another reading beside this one"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        // The plain-button menu (VoicedMenu's idiom) renders the label at its
        // PROPOSED size; `.borderlessButton` sized the control to the label's
        // intrinsic width and clipped the second line to a one-word pill once
        // the page-tall frame was gone (caught in this batch's own walk).
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
        .lensesGeometryProbe(.stub)
        // The rows' content padding is `boardInset` on every side; the stub's
        // top sits on the header cards' top, and it keeps the same trailing
        // edge the rows keep.
        .padding(.top, Self.boardInset)
        .padding(.trailing, Self.boardInset)
        .padding(.leading, 4)
        .help("A column is a way of looking, not a copy — open the note's chosen "
            + "takes, a saved lens, or a fresh one, side by side with this column")
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if model.projection.slots.isEmpty {
            // 17o batch c (row 15): the same face Takes shows — the first
            // block is made here too.
            TakesEmptyStateView(
                tokens: tokens,
                onNewBlock: { Task { await model.addBlockAtEnd() } },
                onWrite: { session.commandRouter.requestMode(.write, postID: postID) })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 4C (S4-10): the dashed waiting column sits beside a lone
            // column — the door where the second column would appear.
            HStack(alignment: .top, spacing: 0) {
                if model.alignmentLocked {
                    lockedColumns
                } else {
                    unlockedColumns
                }
                if model.columns.count == 1 {
                    // Row 16: top-aligned — a door at the header's height,
                    // never a page-tall dashed column.
                    addColumnStub
                        .frame(width: 190)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
    }

    /// LOCKED: registered comparison rows — block starts aligned, honest
    /// whitespace.
    private var lockedColumns: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                columnHeaders
                ForEach(model.projection.slots, id: \.placementID) { slot in
                    let tints = Sameness.tints(model.rowTexts(slot: slot))
                    let isFirstRow = slot.placementID == model.projection.slots.first?.placementID
                    VStack(alignment: .leading, spacing: 3) {
                        if dropTargetBlockID == slot.blockID {
                            Rectangle().fill(tokens.ring).frame(height: 2)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            dragHandle(slot.blockID)
                                .lensesGeometryProbe(isFirstRow ? .rowLead : nil)
                            LineageStripe(blockID: slot.blockID)
                            ForEach(Array(model.columns.enumerated()), id: \.element.id) { i, column in
                                VStack(alignment: .leading, spacing: 3) {
                                    TakesCellView(
                                        model: model, tokens: tokens, indicator: indicator,
                                        slot: slot, column: column,
                                        tinted: i < tints.count ? tints[i] : false,
                                        onDiff: { diffPresentation = $0 })
                                    dangleNotice(slot: slot, column: column)
                                    pickSwitcher(slot: slot, column: column)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .lensesGeometryProbe(isFirstRow && i == 0 ? .firstCell : nil)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .dropDestination(for: String.self) { items, _ in
                        dropBlock(items, before: slot.blockID)
                    } isTargeted: { targeted in
                        noteDropTarget(slot.blockID, targeted: targeted)
                    }
                }
                endDropZone
            }
            .padding(12)
        }
    }

    /// UNLOCKED: each column flows as its own complete read. Row 16: each
    /// column carries its OWN header card over its own cells (one strip over
    /// N independently padded scroll columns could never sit over them).
    private var unlockedColumns: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(Array(model.columns.enumerated()), id: \.element.id) { index, column in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 4) {
                        Text("⠿").font(tokens.small).hidden()
                        headerCard(column, index: index)
                    }
                    .padding(.horizontal, 6)
                    .padding(.top, Self.boardInset)
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(model.projection.slots, id: \.placementID) { slot in
                                VStack(alignment: .leading, spacing: 3) {
                                    if dropTargetBlockID == slot.blockID {
                                        Rectangle().fill(tokens.ring).frame(height: 2)
                                    }
                                    HStack(alignment: .top, spacing: 4) {
                                        dragHandle(slot.blockID)
                                        VStack(alignment: .leading, spacing: 3) {
                                            TakesCellView(
                                                model: model, tokens: tokens,
                                                indicator: indicator, slot: slot,
                                                column: column, tinted: false,
                                                onDiff: { diffPresentation = $0 })
                                            dangleNotice(slot: slot, column: column)
                                            pickSwitcher(slot: slot, column: column)
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                                .dropDestination(for: String.self) { items, _ in
                                    dropBlock(items, before: slot.blockID)
                                } isTargeted: { targeted in
                                    noteDropTarget(slot.blockID, targeted: targeted)
                                }
                            }
                            endDropZone
                        }
                        .padding(6)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Block drag-reorder (13b 4C, S4-2d — one post, one order)

    /// The ⠿ handle: dragging a block reorders THE POST — every column
    /// moves together by construction (all columns render the one slot
    /// order; no column keeps an order of its own).
    private func dragHandle(_ blockID: String) -> some View {
        Text("⠿")
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .help("Drag to reorder this block — one note, one order: every column moves together")
            .draggable(Self.dragPayload(blockID: blockID))
    }

    private func dropBlock(_ items: [String], before targetBlockID: String?) -> Bool {
        guard let raw = items.first, let blockID = Self.parseDragPayload(raw) else {
            return false
        }
        Task { await model.reorderBlock(blockID, before: targetBlockID) }
        return true
    }

    private func noteDropTarget(_ blockID: String, targeted: Bool) {
        if targeted {
            dropTargetBlockID = blockID
        } else if dropTargetBlockID == blockID {
            dropTargetBlockID = nil
        }
    }

    /// Drag past the last block to land it at the end.
    private var endDropZone: some View {
        VStack(spacing: 2) {
            if dropAtEnd {
                Rectangle().fill(tokens.ring).frame(height: 2)
            }
            Color.clear.frame(height: 12)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { items, _ in
            dropBlock(items, before: nil)
        } isTargeted: { dropAtEnd = $0 }
    }

    /// **13j J5 — the lens says it IN PLACE.** Her mobile-gate ruling: when a
    /// saved lens's pick dangles at an archived or deleted take, the Mac must
    /// *"say loudly if that take was archived and this is a fallback WITH a
    /// button for quick restore."*
    ///
    /// The read-time fallback (`effectiveLensSelection` drops the pick, the
    /// slot resolves ordinarily) is CORRECT and completely silent — which is
    /// the defect: the column shows a take she never chose, with nothing
    /// saying so. This is the notice, worded to the actual state, rendered in
    /// the column that made the pick and nowhere else.
    @ViewBuilder
    private func dangleNotice(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        if let pick = model.danglingPick(columnID: column.id, slot: slot) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(LensFallbackCopy.notice(for: pick.state)))
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
                if pick.isRestorable {
                    Button(LensFallbackCopy.restoreVerb) {
                        Task { await model.restoreDanglingPick(pick) }
                    }
                    .controlSize(.mini)
                    .help(LensFallbackCopy.restoreHelp(for: pick.state))
                }
                Spacer(minLength: 4)
            }
            .font(tokens.small)
        }
    }

    /// The per-block ‹ take k of n › switcher (the canvas grammar reused —
    /// R83/R89): moves THIS column's pick only; ends clamp; the Chosen
    /// column deliberately has none (✓ is its one door).
    @ViewBuilder
    private func pickSwitcher(slot: Queries.RenderedBlock, column: TakesColumn) -> some View {
        if column.kind != .main,
           let pos = model.pickPosition(columnID: column.id, slot: slot) {
            HStack(spacing: 4) {
                Button("‹") { Task { await model.stepPick(columnID: column.id, slot: slot, by: -1) } }
                    .disabled(pos.index <= 1)
                Text("take \(pos.index) of \(pos.count)")
                    .foregroundStyle(tokens.muted)
                Button("›") { Task { await model.stepPick(columnID: column.id, slot: slot, by: 1) } }
                    .disabled(pos.index >= pos.count)
            }
            .font(tokens.small)
            .buttonStyle(.plain)
            .controlSize(.mini)
        }
    }

    // MARK: - Column headers (prominent names + the slot picker + doors)

    /// Wave 2c (item 15): the column headers are CARDS whose identity is a
    /// LENS — a name, a kind line, the doors — never a note title or a
    /// relationship line (that is Compare's card; the two modes now tell
    /// themselves apart by exactly this structure).
    private var columnHeaders: some View {
        HStack(alignment: .top, spacing: 8) {
            // Row 16: the strip leads with the ROW's own gutter — the same
            // glyph in the same font, hidden, then the stripe's width — so
            // the cards sit over their panes by construction. The old 4-pt
            // spacer stood in for a ⠿ + stripe gutter and left every card
            // ~17 pt left of the pane under it.
            HStack(alignment: .top, spacing: 8) {
                Text("⠿").font(tokens.small).hidden()
                Color.clear.frame(width: 4, height: 1)
            }
            ForEach(Array(model.columns.enumerated()), id: \.element.id) { index, column in
                headerCard(column, index: index)
            }
        }
    }

    /// ONE column's header card (the strip's and the unlocked column's).
    private func headerCard(_ column: TakesColumn, index: Int) -> some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    slotPicker(column)
                    Spacer(minLength: 4)
                    if model.columns.count > 1 {
                        Button("✕") { model.removeColumn(column.id) }
                            .buttonStyle(.plain)
                            .foregroundStyle(tokens.muted)
                            .help("Close this column (a named lens stays saved; "
                                + "an unnamed one is let go)")
                    }
                }
                Text(tokens.chromeLabel(kindCaption(column)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                columnDoors(column)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .lensesGeometryProbe(.headerCard(index))
    }

    /// What KIND of way-of-looking this column is — said as a fact line,
    /// not an explainer sentence.
    private func kindCaption(_ column: TakesColumn) -> String {
        switch column.kind {
        case .main: "the note — its chosen takes"
        case .scratch: "unnamed lens — 💾 keeps it"
        case .lens: "saved lens"
        }
    }

    /// The column NAME is the slot picker (R83: names prominent BECAUSE
    /// slots swap — click the name to replace this column's occupant).
    private func slotPicker(_ column: TakesColumn) -> some View {
        // VX-223: the chrome pull-down (its rows already read at menu size —
        // no mini host here — but every borderless pull-down is the one
        // component now, so none can inherit a mini row's size again).
        ChromePullDown {
            Button("Chosen (the note)") { model.replaceColumnWithChosen(column.id) }
            if !model.projection.lenses.isEmpty {
                Divider()
                ForEach(model.projection.lenses, id: \.id) { lens in
                    Button("“\(lens.name)”") {
                        model.replaceColumnWithLens(column.id, lensID: lens.id)
                    }
                }
            }
            Divider()
            Button("New lens — arrange existing takes") {
                model.replaceColumnWithNewScratch(column.id)
            }
            Button("New lens — write new takes") {
                Task { await model.replaceColumnWithNewWrite(column.id) }
            }
        } label: {
            HStack(spacing: 4) {
                Text(columnTitle(column))
                    .font(.callout.weight(.bold))
                    .foregroundStyle(tokens.ink)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(tokens.muted)
            }
        }
        .help("Replace this column with a different lens, the note itself, or a new lens")
    }

    private func columnTitle(_ column: TakesColumn) -> String {
        switch column.kind {
        case .main: return "Chosen (the note)"
        case .scratch: return column.name ?? "Lens"
        case .lens(let id):
            return model.projection.lenses.first { $0.id == id }?.name ?? "Lens"
        }
    }

    /// Every non-Chosen column's doors, visible — R89's "very obvious"
    /// mandate: ✓ Make this the note (the adopt-SWAP, the PRIMARY door),
    /// ⧉ Make this a note, 💾 keep, ⋯ the rest. Wave 2c: generous calm
    /// targets (W8-2); the ✕ moved to the card's title row.
    @ViewBuilder
    private func columnDoors(_ column: TakesColumn) -> some View {
        HStack(spacing: 5) {
            switch column.kind {
            case .main:
                ChromePullDown("⧉ Duplicate as Version") {
                    Button("A full copy of this note, linked as a version") {
                        Task { await model.promoteColumn(column.id) }
                    }
                }
                .help("Copies the note exactly as it is — takes and all — into a new linked note")
            case .scratch:
                adoptDoor(column)
                ChromePullDown("⧉ Make this a note") {
                    Button("New note from this column (takes ride)") {
                        Task { await model.promoteColumn(column.id, carryFans: true) }
                    }
                    Button("New note, only what this column shows") {
                        Task { await model.promoteColumn(column.id, carryFans: false) }
                    }
                    Divider()
                    Button("New note — and keep this as a lens too") {
                        Task { await model.promoteColumn(column.id, keepAsLens: true) }
                    }
                }
                .help("A new linked note whose text is what this column shows — no lens required (direct promote)")
                Button("💾") { lensNamePrompt = LensPrompt(columnID: column.id) }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                    .help("Keep this way of looking: save it as a named lens")
            case .lens(let lensID):
                adoptDoor(column)
                ChromePullDown("⧉ Make this a note") {
                    Button("New note from this lens (takes ride)") {
                        Task { await model.promoteColumn(column.id, carryFans: true) }
                    }
                    Button("New note, only what this lens shows") {
                        Task { await model.promoteColumn(column.id, carryFans: false) }
                    }
                }
                .help("A new linked note whose text is what this lens shows")
                ChromePullDown("⋯") {
                    Button("Rename lens…") {
                        // 13b Stage 3 (3D — N6): `renameLens` (core since
                        // 11a) finally gets its door.
                        lensRenamePrompt = LensRenamePrompt(
                            lensID: lensID, currentName: columnTitle(column))
                    }
                    Button("Duplicate lens") { Task { await model.duplicateLens(lensID) } }
                    Button("Delete lens", role: .destructive) {
                        Task { await model.deleteLens(lensID) }
                    }
                }
            }
        }
        .font(tokens.small)
        .controlSize(.mini)
    }

    private func adoptDoor(_ column: TakesColumn) -> some View {
        Button(tokens.chromeLabel("✓ Make this the note")) {
            Task { await model.adoptColumn(column.id) }
        }
        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
        .help("The note's chosen takes become this column's — and the old chosen is "
            + "kept automatically as a lens (“chosen until …”), so you can always swap back")
    }

    // (The footer's standing rule sentence retired at wave 2c — item 15's
    // copy doctrine. The exact sentence lives behind the header's ? now:
    // structure teaches at rest, the words wait to be summoned.)
}

// MARK: - The geometry oracle (DEBUG — the correction round's row 16 pins)

/// Where the board's chrome sits, as rectangles in the board's own space —
/// the `MastheadGeometry` idiom. A pin asserts what she SEES: the header
/// cards over their panes, the toolbar on the rows' leading edge, the
/// `＋ column` door at the header's height and never page-tall.
enum LensesProbeSlot: Hashable {
    case toolbarLead
    case headerCard(Int)
    case firstCell
    case rowLead
    case stub
}

#if DEBUG
/// **SCOPED BY THE MOUNTING SESSION** (13u2 UNIT E — KnownIssues row 50).
/// Swift Testing runs SUITES IN PARALLEL, so a process-global static here
/// lets another suite's mounted board answer this pin's question — a green
/// pin that proved nothing. The scope travels by environment
/// (`DebugProbeScope.swift`); a pin reads its own session's.
@MainActor
enum LensesGeometry {
    private static var worlds: [String: [LensesProbeSlot: CGRect]] = [:]

    static func record(_ slot: LensesProbeSlot, _ frame: CGRect, in scope: String) {
        worlds[scope, default: [:]][slot] = frame
    }

    /// A pin's OWN board — every read below is this session's mount.
    @MainActor
    struct Reader {
        let scope: String

        var frames: [LensesProbeSlot: CGRect] { LensesGeometry.worlds[scope] ?? [:] }

        /// A pin resets before its mount — its OWN scope and no other.
        func reset() { LensesGeometry.worlds[scope] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}

/// The probe, as a modifier rather than a bare `onGeometryChange`, because it
/// must READ the environment for its scope.
private struct LensesGeometryProbe: ViewModifier {
    let slot: LensesProbeSlot
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(LensesBoardView.boardSpace))
        } action: { LensesGeometry.record(slot, $0, in: scope) }
    }
}
#endif

extension View {
    /// The DEBUG oracle write: this view's frame in the lenses board's own
    /// coordinate space, under `slot` (nil = not a probed view). A no-op
    /// outside DEBUG.
    @ViewBuilder
    func lensesGeometryProbe(_ slot: LensesProbeSlot?) -> some View {
        #if DEBUG
        if let slot {
            self.modifier(LensesGeometryProbe(slot: slot))
        } else {
            self
        }
        #else
        self
        #endif
    }
}
