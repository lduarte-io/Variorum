//
//  FormatBar.swift
//  Variorum
//
//  Phase 13k, K7 — THE FORMATTING TOOLBAR, in the bottom bar.
//
//  Her ruling, verbatim: *"i think the formatting toolbar should be added to
//  the bottom - if i decide it's too cluttered later i'll remove it then, i
//  think other users would need it though."*
//
//  ── Three properties this file is built to have ──────────────────────────
//
//  **1. It is not a second brain (P-1).** Every button fires
//  `MarkdownActs.fire`, the same door the menu bar's Format menu fires
//  through `ShellActions.applyFormat` — so the act, its refusal, its undo
//  grouping and its targeting rule are all exactly the menu's. The rows come
//  from `MarkdownActs.rows`, the one table the menu bar and the context menu
//  already render, so a ninth act can never appear in one place and not
//  another.
//
//  **2. It is SELF-CONTAINED**, because she said she may remove it: this
//  file, two call sites (`CommitBar`, `TakesBottomBar`), and the `.bottomBar`
//  door on the eight formatting capabilities. Nothing else knows it exists.
//
//  **3. It reads as what it does.** The bar's standing grammar is quiet
//  clickable WORDS (R101), not bezels — so these are words too, set in the
//  format they apply: a bold **B**, an italic *I*, a struck S, a monospaced
//  backtick. Each carries its registry verb and key in `.help`, and the ⌘/
//  helper names all of them in prose (the WT-1 drift-guard lesson: a door
//  that exists but cannot be found is not a door).
//

import SwiftUI
import VariorumCore

struct FormatBar: View {
    let tokens: VoiceTokens
    let status: StatusCenter

    /// The registry ids this cluster renders — walk-asserted with the two
    /// bars' own tables against the `.bottomBar` door set. Derived from the
    /// ONE act table rather than re-listed, so the two can never drift.
    @MainActor static var renderedCapabilities: [CapabilityID] {
        MarkdownActs.rows.map(\.id)
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(MarkdownActs.rows, id: \.id) { row in
                if let act = row.act {
                    Button { MarkdownActs.fire(act, status: status) } label: {
                        Self.label(for: row.id)
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .help(help(row.id))
                } else {
                    // Headings are SIZES (F-3), so the three levels are shades
                    // of ONE act — the same shape the menus give them.
                    VoicedMenu(tokens: tokens, label: "H") {
                        ForEach(MarkdownActs.headingRows, id: \.title) { child in
                            Button(child.title) {
                                MarkdownActs.fire(child.act, status: status)
                            }
                        }
                    }
                    .help(help(row.id))
                }
            }
        }
    }

    /// The button's face: the mark set in the format it makes. Deliberately
    /// NOT the registry verb — "Strikethrough" beside "Inline Code" beside
    /// "Bullet List" is a paragraph, and the bar she already called crowded
    /// has no room for one. The verb rides `.help` and the helper.
    @ViewBuilder
    static func label(for id: CapabilityID) -> some View {
        switch id {
        case .formatBold:
            Text("B").fontWeight(.bold)
        case .formatItalic:
            Text("I").italic()
        case .formatStrikethrough:
            Text("S").strikethrough()
        case .formatCode:
            Text("`").font(.system(size: 12, design: .monospaced))
        case .formatAddLink:
            Text("link")
        case .formatBulletList:
            Text("•")
        case .formatChecklist:
            Text("☐")
        default:
            Text(CapabilityRegistry.capability(id).verb)
        }
    }

    /// Verb + key, from the registry — so the tooltip can never claim a
    /// chord the capability does not declare. (Ladder round A, A-4: the
    /// composition itself now lives on `Capability`, so this bar and the
    /// take card's rows format a chord the same single way.)
    private func help(_ id: CapabilityID) -> String {
        CapabilityRegistry.capability(id).menuTitle()
    }
}
