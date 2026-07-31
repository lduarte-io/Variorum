//
//  PaneHost.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 4 (W1/A25 — the SPLIT): one pane's CHROME, around
//  whatever the shell renders inside it.
//
//  The chrome split is the gate's ruling (d):
//
//  - **Per pane:** the back chip (batch 3 put it in the shell rather than
//    in `PostDetailView` precisely because "where did I come from" is the
//    PANE's fact — it moves in here unchanged, one per pane, each reading
//    its own `PaneID`), and — when the pane is NOT focused — a quiet name
//    line, because a focused pane brings its own masthead and an unfocused
//    one would otherwise be anonymous. **The difference between a full
//    masthead and a thin name line IS the focus signal**, which is a better
//    thing to have than a border.
//  - **Per window** (and therefore not here): the sidebar, the status
//    toast, the ⌘K palette.
//
//  Nothing in this file decides anything: the mount fork is `PaneMount`'s
//  and the shell's, and the chip's arithmetic is `NavigationHistory`'s.
//

import SwiftUI

struct PaneHost<Content: View>: View {
    let tokens: VoiceTokens
    let workspace: WorkspaceModel
    let pane: PaneID
    /// True for exactly one pane (`PaneMount.liveCount`), and the reason
    /// this one shows a masthead-bearing detail and the others do not.
    let focused: Bool
    /// Whether a split exists at all — with one pane there is nothing to
    /// signal, so the name line stays away and the chrome reads as it did
    /// before the split existed.
    let split: Bool
    let onBack: () -> Void
    let onToggleCollapse: () -> Void
    let onFocus: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            if let origin = workspace.history(pane).origin {
                BackChip(
                    tokens: tokens,
                    originLabel: workspace.label(for: origin),
                    collapsed: workspace.backChipCollapsed,
                    onBack: onBack,
                    onToggleCollapse: onToggleCollapse)
                Divider().overlay(tokens.line)
            }
            if split, !focused, let selection = workspace.selections[pane] {
                nameLine(selection)
                Divider().overlay(tokens.line)
            }
            content()
        }
    }

    /// The quiet name line an unfocused pane wears in place of a masthead.
    /// `lineLimit(1)` on the name is P-8's chrome rule (the b6dae25 class:
    /// an unlimited `fixedSize` text in chrome inflates the window's
    /// min-height probe).
    private func nameLine(_ selection: SidebarSelection) -> some View {
        HStack(spacing: 6) {
            Text(tokens.chromeLabel(workspace.label(for: selection)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            Text(tokens.chromeLabel("click to edit"))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(tokens.surface)
        .contentShape(Rectangle())
        .onTapGesture(perform: onFocus)
        .help("This pane is showing — click in it to write here")
    }
}
