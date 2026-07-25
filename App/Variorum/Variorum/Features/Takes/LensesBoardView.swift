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
                Text("Sealed post — takes are viewable; choosing and new takes are frozen.")
                    .font(.caption)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)
            }
            content
            footerRule
            TakesBottomBar(model: model)
        }
        .background(tokens.surface)
        .task { await model.start() }
        .onAppear {
            model.host = .lenses
            // 13b 1b (P-4): registered handler, not a notification.
            commandToken = session.commandRouter.registerHandler { handleRouted($0) }
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
                leftText: diff.left, rightText: diff.right)
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
            model.moveToWriteAndRun(.structural(act))
            return true
        case .deleteInEveryTake:
            model.moveToWriteAndRun(.deleteInEveryTake)
            return true
        case .commit:
            Task { await model.commitFocusedTake() }
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
        case .toggleSeal:
            Task { await model.toggleSeal() }
            return true
        case .comments:
            model.requestComments()
            return true
        case .pageFan:
            return false  // fan pages live on the Takes board
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
                model.speak("Click into a pane first — ⌘T diverges that column at that block.")
                return
            }
            Task {
                await model.divergeHere(
                    columnID: pane.columnID, blockID: pane.blockID,
                    fromVariantID: pane.variantID)
            }
        case .blank:
            guard let pane = model.focusedPane else {
                model.speak("Click into a pane first — ⌥⌘T adds a blank take on that block.")
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
                model.speak("Click into a pane first — ⇧⌥⌘T opens a blank take as chosen there.")
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
                model.speak("Nothing unnamed to save — named lenses save themselves as you work.")
            }
        }
    }

    // MARK: - Header

    /// Batch 9 (R101): the same quiet voiced line as the Takes header —
    /// the align toggle as a chip, the column door as a word-menu.
    private var header: some View {
        HStack(spacing: 8) {
            if model.columns.count > 1 {
                VoicedChip(
                    tokens: tokens,
                    text: model.alignmentLocked ? "align: on" : "align: off",
                    on: model.alignmentLocked
                ) { model.alignmentLocked.toggle() }
                    .help("Locked: registered comparison rows (honest whitespace). "
                        + "Unlocked: each column flows as its own read.")
            }
            Spacer()
            addColumnMenu
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
    }

    /// The add-column MENU ITEMS — one body behind both doors (the header
    /// word-menu and the 4C dashed stub column below).
    @ViewBuilder
    private var addColumnMenuItems: some View {
        Button("New lens — arrange existing takes") { model.addScratchColumn() }
            .help("A fresh way of looking that starts as a mirror of the post. "
                + "Flip any block to a take that already exists — nothing new is written.")
        Button("New lens — write new takes") {
            Task { await model.addWriteColumn() }
        }
        .help("A fresh take on EVERY block, branched from what the post shows — "
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    tokens.faint, style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
        .padding(10)
        .help("A column is a way of looking, not a copy — open the post's chosen "
            + "takes, a saved lens, or a fresh one, side by side with this column")
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if model.projection.slots.isEmpty {
            VStack(spacing: 8) {
                Text(tokens.chromeLabel("Nothing here yet — blocks are born by typing."))
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                Button(tokens.chromeLabel("Start writing (Write mode)")) {
                    session.commandRouter.requestMode(.write, postID: postID)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary, font: tokens.mono))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 4C (S4-10): the dashed waiting column sits beside a lone
            // column — the door where the second column would appear.
            HStack(spacing: 0) {
                if model.alignmentLocked {
                    lockedColumns
                } else {
                    unlockedColumns
                }
                if model.columns.count == 1 {
                    addColumnStub.frame(width: 190)
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
                    VStack(alignment: .leading, spacing: 3) {
                        if dropTargetBlockID == slot.blockID {
                            Rectangle().fill(tokens.ring).frame(height: 2)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            dragHandle(slot.blockID)
                            LineageStripe(blockID: slot.blockID)
                            ForEach(Array(model.columns.enumerated()), id: \.element.id) { i, column in
                                VStack(alignment: .leading, spacing: 3) {
                                    TakesCellView(
                                        model: model, tokens: tokens, slot: slot, column: column,
                                        tinted: i < tints.count ? tints[i] : false,
                                        onDiff: { diffPresentation = $0 })
                                    pickSwitcher(slot: slot, column: column)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
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

    /// UNLOCKED: each column flows as its own complete read.
    private var unlockedColumns: some View {
        VStack(spacing: 0) {
            columnHeaders.padding(.horizontal, 12)
            HStack(alignment: .top, spacing: 8) {
                ForEach(model.columns) { column in
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
                                                model: model, tokens: tokens, slot: slot,
                                                column: column, tinted: false,
                                                onDiff: { diffPresentation = $0 })
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
                    .frame(maxWidth: .infinity)
                }
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
            .help("Drag to reorder this block — one post, one order: every column moves together")
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

    private var columnHeaders: some View {
        HStack(alignment: .top, spacing: 8) {
            Color.clear.frame(width: 4, height: 1)
            ForEach(model.columns) { column in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        slotPicker(column)
                        Spacer()
                    }
                    columnDoors(column)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// The column NAME is the slot picker (R83: names prominent BECAUSE
    /// slots swap — click the name to replace this column's occupant).
    private func slotPicker(_ column: TakesColumn) -> some View {
        Menu {
            Button("Chosen (the post)") { model.replaceColumnWithChosen(column.id) }
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
        .menuStyle(.borderlessButton)
        .fixedSize()
        .help("Replace this column with a different lens, the post itself, or a new lens")
    }

    private func columnTitle(_ column: TakesColumn) -> String {
        switch column.kind {
        case .main: return "Chosen (the post)"
        case .scratch: return column.name ?? "Lens"
        case .lens(let id):
            return model.projection.lenses.first { $0.id == id }?.name ?? "Lens"
        }
    }

    /// Every non-Chosen column's doors, visible — R89's "very obvious"
    /// mandate: ✓ Make this the post (the adopt-SWAP), ⧉ Make this a post,
    /// 💾 keep, ⋯ the rest.
    @ViewBuilder
    private func columnDoors(_ column: TakesColumn) -> some View {
        HStack(spacing: 6) {
            switch column.kind {
            case .main:
                Menu("⧉ Duplicate as Version") {
                    Button("A full copy of this post, linked as a version") {
                        Task { await model.promoteColumn(column.id) }
                    }
                }
                .help("Copies the post exactly as it is — takes and all — into a new linked post")
            case .scratch:
                adoptDoor(column)
                Menu("⧉ Make this a post") {
                    Button("New post from this column (takes ride)") {
                        Task { await model.promoteColumn(column.id, carryFans: true) }
                    }
                    Button("New post, only what this column shows") {
                        Task { await model.promoteColumn(column.id, carryFans: false) }
                    }
                    Divider()
                    Button("New post — and keep this as a lens too") {
                        Task { await model.promoteColumn(column.id, keepAsLens: true) }
                    }
                }
                .help("A new linked post whose text is what this column shows — no lens required (direct promote)")
                Button("💾") { lensNamePrompt = LensPrompt(columnID: column.id) }
                    .help("Keep this way of looking: save it as a named lens")
            case .lens(let lensID):
                adoptDoor(column)
                Menu("⧉ Make this a post") {
                    Button("New post from this lens (takes ride)") {
                        Task { await model.promoteColumn(column.id, carryFans: true) }
                    }
                    Button("New post, only what this lens shows") {
                        Task { await model.promoteColumn(column.id, carryFans: false) }
                    }
                }
                .help("A new linked post whose text is what this lens shows")
                Menu("⋯") {
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
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
            if model.columns.count > 1 {
                Button("✕") { model.removeColumn(column.id) }
                    .help("Close this column (a named lens stays saved; an unnamed one is let go)")
            }
        }
        .font(tokens.small)
        .controlSize(.mini)
    }

    private func adoptDoor(_ column: TakesColumn) -> some View {
        Button("✓ Make this the post") {
            Task { await model.adoptColumn(column.id) }
        }
        .help("The post's chosen takes become this column's — and the old chosen is "
            + "kept automatically as a lens (“chosen until …”), so you can always swap back")
    }

    // MARK: - The one rule (stated, not implied)

    private var footerRule: some View {
        ChromeNotice(
            tokens: tokens,
            text: "Columns are ways of looking at the same post. Nothing here changes the post "
                + "except ✓ (make this the post) and ⧉ (make a new post). Typing edits the take "
                + "you're in — the same take, everywhere it appears.")
            .padding(.horizontal, 24)
            .padding(.vertical, 6)
    }
}
