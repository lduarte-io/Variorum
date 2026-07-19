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
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    struct LensPrompt: Identifiable {
        let columnID: String
        var id: String { "save-\(columnID)" }
    }

    init(session: AppSession, postID: String, model: TakesViewModel? = nil) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model ?? TakesViewModel(session: session, postID: postID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let status = model.statusMessage {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(tokens.accent)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
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
        .onDisappear { model.teardown() }
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
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            if model.columns.count > 1 {
                Toggle("Align blocks", isOn: Binding(
                    get: { model.alignmentLocked },
                    set: { model.alignmentLocked = $0 }))
                    .toggleStyle(.checkbox)
                    .help("Locked: registered comparison rows (honest whitespace). "
                        + "Unlocked: each column flows as its own read.")
            }
            Spacer()
            addColumnMenu
        }
        .controlSize(.small)
        .padding(8)
    }

    private var addColumnMenu: some View {
        Menu("+ Column") {
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
        .fixedSize()
        .disabled(model.columns.count >= 4)
        .help("You can have more views than you have takes — a column is a way of looking, not a copy.")
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if model.alignmentLocked {
            lockedColumns
        } else {
            unlockedColumns
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
                    HStack(alignment: .top, spacing: 8) {
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
                                    TakesCellView(
                                        model: model, tokens: tokens, slot: slot, column: column,
                                        tinted: false,
                                        onDiff: { diffPresentation = $0 })
                                    pickSwitcher(slot: slot, column: column)
                                }
                            }
                        }
                        .padding(6)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
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
        Text("Columns are ways of looking at the same post. Nothing here changes the post "
            + "except ✓ (make this the post) and ⧉ (make a new post). Typing edits the take "
            + "you're in — the same take, everywhere it appears.")
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }
}
