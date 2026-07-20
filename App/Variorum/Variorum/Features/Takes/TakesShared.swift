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
    let onDiff: (TakesDiffPresentation) -> Void

    var body: some View {
        if let resolved = model.resolvedTake(column: column, slot: slot) {
            let key = TakesViewModel.PaneKey(
                columnID: column.id, blockID: slot.blockID, variantID: resolved.variantID)
            PaneSurfaceView(
                text: resolved.text,
                isLive: model.authority.isLive(key, sealed: model.projection.sealed),
                tokens: tokens,
                role: role, variantID: resolved.variantID,
                onFocusRequest: { model.focus(key) },
                onEdit: { model.paneEdited(variantID: resolved.variantID, newText: $0) })
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
                .contextMenu {
                    menu(resolved: resolved)
                }
        } else {
            Text("· · ·")  // a gap slot renders a gap, never crashes
                .foregroundStyle(tokens.muted)
        }
    }

    @ViewBuilder
    private func menu(resolved: (variantID: String, text: String)) -> some View {
        // Batch 12 (the block-menu family): the most direct door of all —
        // right-click the text you're looking at.
        Button("＋ New take — branch of this one (⌘T)") {
            Task { await model.branchTake(blockID: slot.blockID, from: resolved.variantID) }
        }
        Button("＋ Blank take (⌥⌘T)") {
            Task { await model.newBlankTake(blockID: slot.blockID) }
        }
        Divider()
        Button("✓ Choose this take (the post shows it)") {
            Task { await model.choose(blockID: slot.blockID, variantID: resolved.variantID) }
        }
        .disabled(slot.variantID == resolved.variantID)
        Button("Diverge here (new take, this thread)") {
            Task {
                await model.divergeHere(
                    columnID: column.id, blockID: slot.blockID,
                    fromVariantID: resolved.variantID)
            }
        }
        if slot.variantID != resolved.variantID, let chosenText = slot.text {
            Button("Diff against chosen") {
                onDiff(TakesDiffPresentation(
                    leftTitle: "chosen", rightTitle: "this take",
                    left: chosenText, right: resolved.text))
            }
        }
        if let fan = model.projection.fans[slot.blockID], fan.count > 1 {
            Menu("Show take") {
                ForEach(fan, id: \.id) { take in
                    Button(TakesShared.takeLabel(take, chosen: slot.variantID)) {
                        Task {
                            await model.pick(
                                columnID: column.id, blockID: slot.blockID, variantID: take.id)
                        }
                    }
                }
            }
        }
    }
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
    @State private var comments: [BlockComment] = []
    @State private var panelShown = false

    var body: some View {
        if let first = comments.first {
            Button {
                panelShown = true
            } label: {
                VStack(alignment: .leading, spacing: 2) {
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
                .padding(.leading, 8)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(tokens.commentInk.opacity(0.5))
                        .frame(width: 2)
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

/// Naming sheet for lenses (save-as-lens, save-current-choices).
struct LensNameSheet: View {
    var title: String = "Name this lens"
    let onName: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            TextField("e.g. bolder thread", text: $name)
                .frame(width: 260)
                .onSubmit(submit)
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
