//
//  TakesShared.swift
//  Variorum
//
//  Taste-checkpoint fix round (Sitting 9, R86): the Takes/Lenses tab split
//  pulled the cell grammar both boards share into one home — a cell is the
//  column's resolved take, read-cheap until clicked, the ONE live editor
//  migrating on click (P3), with the explicit ✓ and the diverge/diff doors
//  on the context menu. The boards differ in COMPOSITION (article + fans vs
//  column slots), never in cell semantics.
//

import SwiftUI
import VariorumCore

/// A diff sheet's payload (shared by both boards).
struct TakesDiffPresentation: Identifiable {
    let leftTitle: String
    let rightTitle: String
    let left: String
    let right: String
    let id = UUID()
}

/// One cell: the column's resolved take for a slot. Rendering + gestures
/// only — every rule lives in the model.
struct TakesCellView: View {
    let model: TakesViewModel
    let tokens: VoiceTokens
    let slot: Queries.RenderedBlock
    let column: TakesColumn
    let tinted: Bool
    /// Surface identity for tests/soaks ("article" on the takes board's
    /// main cell; the default elsewhere).
    var role: String = "cell"
    /// 13f W7: forwarded to the pane, defaulted OFF so every host but the
    /// takes board's article column reads exactly as before.
    var caretToEndToken: Int = 0
    /// 13e E3 (her A18): the ⌘-click claim, set ONLY by the takes board's
    /// article cell — nil on the Lenses board and anywhere else, so no other
    /// composition's ⌘-click behaviour moves. The `Bool` is 13e E2's: ⇧ was
    /// held too, i.e. extend the run rather than toggle this one.
    var onCommandClick: ((Bool) -> Bool)?
    let onDiff: (TakesDiffPresentation) -> Void

    var body: some View {
        if let resolved = model.resolvedTake(column: column, slot: slot) {
            let key = TakesViewModel.PaneKey(
                columnID: column.id, blockID: slot.blockID, variantID: resolved.variantID)
            PaneSurfaceView(
                text: resolved.text,
                isLive: model.isPaneLive(key),
                tokens: tokens,
                role: role, variantID: resolved.variantID,
                onFocusRequest: { model.focus(key) },
                onEdit: { model.paneEdited(variantID: resolved.variantID, newText: $0) },
                onCommandClick: onCommandClick,
                onSelectionChange: { range in
                    // The choreography's carried caret (13b 1b): what a
                    // fire-and-DO landing brings into Write.
                    model.notePaneSelection(variantID: resolved.variantID, range: range)
                },
                menuItems: { menuSpecs(resolved: resolved) },
                caretToEndToken: caretToEndToken)
                .background(tinted ? tokens.accent.opacity(0.12) : Color.clear)
                .overlay(alignment: .topLeading) {
                    // Batch 9 (R103, her ruling): a take deleted down to
                    // nothing KEEPS the block's own line — and the kept
                    // line says what it is instead of sitting as an
                    // invisible void (boundaries are invisible at rest).
                    // Write renders the same empty line as plain prose;
                    // export still skips blank takes (the Phase 4 rule —
                    // output, not editing). `resolved.text` already
                    // overlays the live buffer (the authority), so the
                    // emptiness check is one equality (13b 1a).
                    if resolved.text.isEmpty {
                        Text(tokens.chromeLabel("empty take — line kept"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .padding(.leading, 8)
                            .padding(.top, 6)
                            .allowsHitTesting(false)
                    }
                }
        } else {
            Text("· · ·")  // a gap slot renders a gap, never crashes
                .foregroundStyle(tokens.muted)
        }
    }

    /// The take card's context menu (13b 1b, AD-4): right-clicking a pane
    /// used to show ONLY the stock text menu — the SwiftUI `.contextMenu`
    /// never fired inside the NSTextView. The Variorum vocabulary now
    /// renders through the pane surface's real menu path, above the
    /// standard edit items. Registry-declared: see
    /// `TakesCellView.contextMenuCapabilities`.
    private func menuSpecs(
        resolved: (variantID: String, text: String)
    ) -> [PaneTextView.MenuItemSpec] {
        var specs: [PaneTextView.MenuItemSpec] = [
            // R2-A: the cell KNOWS its column — on the Lenses host the
            // mint lands as THIS column's pick (the ring follows).
            .init(title: "＋ New take — branch of this one (⌘T)") {
                Task {
                    await model.branchTakeRevealed(
                        blockID: slot.blockID, from: resolved.variantID,
                        preferredColumnID: column.id)
                }
            },
            .init(title: "＋ Blank take (⌥⌘T)") {
                Task {
                    await model.newBlankTakeRevealed(
                        blockID: slot.blockID, preferredColumnID: column.id)
                }
            },
            .init(
                title: "✓ Choose this take (the note shows it)",
                enabled: slot.variantID != resolved.variantID
            ) {
                Task { await model.choose(blockID: slot.blockID, variantID: resolved.variantID) }
            },
            .init(title: "Diverge here (new take, this thread)") {
                Task {
                    await model.divergeHere(
                        columnID: column.id, blockID: slot.blockID,
                        fromVariantID: resolved.variantID)
                }
            },
            .init(title: "Archive this take (⌘⇧A)") {
                Task { await model.archiveTake(resolved.variantID) }
            },
            // 13b Stage 3 (3D — N6): the 3B `setTakeLabel` op's card door;
            // the bar hosts the sheet on both boards.
            .init(title: "Label take\u{2026}") {
                model.requestTakeLabel(variantID: resolved.variantID)
            },
            // 13e E6 (her A21's clipboard half): the whole fan as text. The
            // target is named EXPLICITLY — a right-click never moves the
            // keyboard, so the routed target could name another card's block
            // (13k K6's lesson, same fix).
            .init(title: "\(CapabilityRegistry.capability(.copyAllTakes).verb) (⌘⇧C)") {
                Task { await model.copyAllTakes(blockID: slot.blockID) }
            },
            // 13e batch 3 (her A20/A21's second half — AR-1): the take↔block
            // pair, on the card that IS the take. Both name their target
            // explicitly, for the same right-click reason.
            .init(title: "\(CapabilityRegistry.capability(.takeToBlockBelow).verb) (⌥⌘⏎)") {
                Task {
                    await model.moveTakeIntoBlockBelow(
                        blockID: slot.blockID, variantID: resolved.variantID)
                }
            },
            .init(title: "\(CapabilityRegistry.capability(.takesToBlocks).verb) (⇧⌥⌘⏎)") {
                Task { await model.turnTakesIntoBlocks(blockID: slot.blockID) }
            },
        ]
        // 13e E3 (her A18): the merge door for a ⌘-click selection, rendered
        // only where it can act — on the Takes board, with two or more blocks
        // picked (the `.diffAgainstChosen` per-target shape, P-2). The count
        // is in the row's words so the menu says what it will join.
        if model.host == .takes {
            let picked = model.selectedBlocksInOrder
            if picked.count >= 2 {
                specs.append(.init(
                    title: "\(CapabilityRegistry.capability(.mergeSelectedBlocks).verb) "
                        + "(\(picked.count))"
                ) {
                    Task { await model.mergeSelectedBlocks() }
                })
            }
            // 13e E2 (her A17): the delete door over the SAME selection.
            // Rendered from ONE pick, not two — one picked block is a
            // perfectly good thing to delete, where a merge needs a partner.
            if !picked.isEmpty {
                specs.append(.init(
                    title: BlockSelectionCopy.deleteVerb(picked: picked.count)
                ) {
                    Task { await model.deleteSelectedBlocks() }
                })
            }
        }
        if slot.variantID != resolved.variantID, let chosenText = slot.text {
            specs.append(.init(title: "Diff against chosen") {
                onDiff(TakesDiffPresentation(
                    leftTitle: "chosen", rightTitle: "this take",
                    left: chosenText, right: resolved.text))
            })
        }
        // 13f W10b: the road back to the RELEASED original — rendered only on
        // a block that has one (P-2), which is why it sits behind the same
        // kind of per-target condition as "Diff against chosen" above. This
        // is the answer to her sitting question where she asked it: looking
        // at a divide's successor takes.
        if let originID = model.projection.unplacedOrigins[slot.blockID]?.first {
            specs.append(.init(
                title: CapabilityRegistry.capability(.showOriginBlock).verb
            ) {
                model.revealOriginBlock(originID)
            })
        }
        if let fan = model.projection.fans[slot.blockID], fan.count > 1 {
            specs.append(.init(
                title: "Show take",
                children: fan.map { take in
                    .init(title: TakesShared.takeLabel(take, chosen: slot.variantID)) {
                        Task {
                            await model.pick(
                                columnID: column.id, blockID: slot.blockID, variantID: take.id)
                        }
                    }
                }))
        }
        // 13k K6: the CALLOUT submenu — the same rows the menu bar and
        // Write's right-click offer, from the one vocabulary
        // (`CalloutMenu.rows`). The frame is the BLOCK's and takes share it
        // (R16/R27), so a card's right-click is a legitimate place to set
        // it; the act is the board's own `applyCallout`, i.e. the same
        // routed transform 13c R2-2 gave every other door.
        specs.append(.init(
            title: CalloutMenu.title,
            children: CalloutMenu.rows.compactMap { row in
                guard !row.isSeparator else { return nil }  // specs carry no dividers
                if row.promptsForEmoji {
                    return .init(title: row.title) {
                        guard let glyph = CalloutMenu.promptEmoji() else { return }
                        Task {
                            await model.applyCallout(.emoji(glyph), blockID: slot.blockID)
                        }
                    }
                }
                guard let edit = row.edit else { return nil }
                return .init(
                    title: row.title,
                    action: { Task { await model.applyCallout(edit, blockID: slot.blockID) } },
                    // 13e E1: the swatch, from the one vocabulary's own row —
                    // the card's right-click shows the same chip the menu bar
                    // and Write's right-click show.
                    image: row.swatch.map { CalloutMenu.swatchImage(for: $0) })
            }))
        return specs
    }

    /// The registry ids this menu renders (walk-asserted against the
    /// contextMenu door set's take-scope half).
    static let contextMenuCapabilities: [CapabilityID] = [
        .newTake, .blankTake, .chooseTake, .divergeHere, .archiveTake, .diffAgainstChosen,
        .labelTake,
        .showOriginBlock,  // 13f W10b — rendered only where an origin exists
        .callout,  // 13k K6 — the frame door where the takes are
        // 13e E3 (A18) — rendered only on the Takes board with a selection
        .mergeSelectedBlocks,
        // 13e E2 (A17) — the delete door over the same selection
        .deleteSelectedBlocks,
        // 13e E6 (A21) — the clipboard half's card door
        .copyAllTakes,
        // 13e batch 3 (A20/A21) — the take↔block pair's card doors
        .takeToBlockBelow, .takesToBlocks,
    ]
}

enum TakesShared {
    static func takeLabel(_ take: Variant, chosen: String?) -> String {
        var label = take.label ?? String(take.workingText.prefix(40))
        if label.isEmpty { label = "(empty take)" }
        if take.id == chosen { label = "✓ " + label }
        return label
    }
}

/// The 9d stable-color family: same block, same color, forever — the
/// same-ORIGIN signal (sameness's other channel).
struct LineageStripe: View {
    let blockID: String

    var body: some View {
        let hue = Double(BlockTint.stableHash(blockID) % 360) / 360.0
        Color(hue: hue, saturation: 0.5, brightness: 0.85)
            .frame(width: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

/// Batch 14 — the takes article's LEFT-MARGIN comment note (her placement
/// suggestion; the round-2 margin-comment idiom, takes-side): the block's
/// first comment, glyph-prefixed, click for the full panel. Fetched per
/// visible row (LazyVStack — cost ∝ viewport).
struct CommentMarginNote: View {
    let session: AppSession
    let blockID: String
    let tokens: VoiceTokens
    /// 13b 3F (N8/AD-8): under ~90pt of real gutter the full card cannot
    /// fit — the note degrades to the // chip (count included) instead of
    /// laying out in space the sidebar owns. Same philosophy as Write's
    /// `gutterFitsCards` degrade.
    var compact = false
    @State private var comments: [BlockComment] = []
    @State private var panelShown = false

    var body: some View {
        if let first = comments.first {
            Button {
                panelShown = true
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    if compact {
                        Text(tokens.chromeLabel(
                            comments.count > 1
                                ? "\(tokens.commentPrefix)\(comments.count)"
                                : tokens.commentPrefix))
                            .font(tokens.small)
                            .foregroundStyle(tokens.commentInk)
                            .lineLimit(1)
                    } else {
                        Text(tokens.commentPrefix + first.text)
                            .font(tokens.small)
                            .foregroundStyle(tokens.commentInk)
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                        if comments.count > 1 {
                            Text(tokens.chromeLabel("+\(comments.count - 1) more"))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                        }
                    }
                }
                .padding(.leading, compact ? 0 : 8)
                .overlay(alignment: .leading) {
                    if !compact {
                        Rectangle()
                            .fill(tokens.commentInk.opacity(0.5))
                            .frame(width: 2)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("This block's comments — click to read, add, or edit them")
            .popover(isPresented: $panelShown) {
                CommentsPanel(session: session, blockID: blockID)
            }
            .onChange(of: panelShown) { _, shown in
                if !shown { Task { await refresh() } }
            }
            .task(id: blockID) { await refresh() }
        } else {
            Color.clear
                .frame(width: 1, height: 1)
                .task(id: blockID) { await refresh() }
        }
    }

    private func refresh() async {
        comments = (try? await session.database.read { [blockID] db in
            try Queries.blockComments(db, blockID: blockID)
        }) ?? []
    }
}

/// The take-label prompt (13b Stage 3, 3D — N6's face): set, change, or
/// clear a label on one take. Empty commits clear (the core op NULLs).
struct TakeLabelSheet: View {
    let currentLabel: String?
    let onSet: (String?) -> Void
    @State private var label = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(currentLabel == nil ? "Label this take" : "Change the take's label")
                .font(.headline)
            TextField("e.g. bolder opening", text: $label)
                .frame(width: 260)
                .onSubmit(submit)
            Text("A label names a take on its card and in exports — identity only, never printed in the prose.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 260, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if currentLabel != nil {
                    Button("Clear Label") {
                        onSet(nil)
                        dismiss()
                    }
                }
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Set") { submit() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .onAppear { label = currentLabel ?? "" }
    }

    private func submit() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        onSet(trimmed.isEmpty ? nil : trimmed)
        dismiss()
    }
}

/// Naming sheet for lenses (save-as-lens, save-current-choices, rename).
struct LensNameSheet: View {
    var title: String = "Name this lens"
    /// Prefill (the rename door starts from the current name).
    var initialName: String = ""
    let onName: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            TextField("e.g. bolder thread", text: $name)
                .frame(width: 260)
                .onSubmit(submit)
                .onAppear { if name.isEmpty { name = initialName } }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        onName(trimmed)
        dismiss()
    }
}
