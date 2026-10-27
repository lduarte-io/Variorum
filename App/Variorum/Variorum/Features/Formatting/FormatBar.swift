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

/// **THE Aa DOOR** (the post-13l polish round, ledger row 28 — her kickoff
/// addition, verbatim: *"for more space on the bottom chrome, please condense
/// all the current options into an Aa style button that when clicked expands
/// into the full bar"*, with the SCOPE she ruled at the sitting: **formatting
/// only behind Aa**).
///
/// The chip and the slide-out row live here rather than in each bar, for the
/// same reason `FormatBar` itself does: this is one cluster with one grammar,
/// and R6-2's whole point is that the two bars read as one. What it condenses
/// is exactly what her ruling named — the eight formatting doors and the
/// newlines chip — and `block ▾` · Takes · commit · **history** · `note ▾` ·
/// comments · the counts · `?` all stay visible at rest, so *"the bar becomes
/// the block's time controls"* survives by construction.
///
/// **Registry ids are UNCHANGED and that is deliberate** (P-1, the R6-2/13g
/// slide-out class exactly): each bar's `renderedCapabilities` still declares
/// the same eight formatting acts, because rendering them behind an expansion
/// is still rendering them. Only WHERE they are drawn moved — the same
/// property the two `note ▾` / `block ▾` groups established.
///
/// Expansion is SESSION UI STATE, held per bar: a fold is not document
/// semantics (the tray's takes disclosure and every savepoint run say the
/// same thing), and two bars that are never on screen at once have nothing
/// to keep in step.
nonisolated enum FormattingDoor {
    /// The chip's face — the door's own name, in the app's mouth.
    static let label = "Aa"

    static func help(expanded: Bool) -> String {
        expanded
            ? "Put the formatting row away — bold, italics, sizes, lists, "
                + "links and the newlines setting"
            // VX-426 (A-439-17): the "Aa" glyph's tooltip leads with its name.
            : "Formatting \u{2014} bold, italics, sizes, lists, links, and whether ⏎ makes new "
                + "blocks. They slide out here; the rest of the bar stays put."
    }

    /// **WHAT GOES BEHIND THE DOOR, AS A VALUE.** Her ruling at the kickoff
    /// sitting was *"formatting only behind Aa"*, and a comment beside a view
    /// body cannot be checked. This can: it is exactly `FormatBar`'s own act
    /// table, so a ninth formatting act joins the fold automatically and a
    /// NON-formatting act cannot wander into it without this line changing.
    ///
    /// (The newlines chip rides the row too and is deliberately NOT here: it
    /// is a per-note SETTING rather than a declared act — the wash-chip class,
    /// recorded not declared since 13b 4D — so it has no id to name.)
    @MainActor static var condensed: Set<CapabilityID> {
        Set(FormatBar.renderedCapabilities)
    }
}
