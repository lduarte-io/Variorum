//
//  PostMode.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (P-1): the post modes as a shared vocabulary
//  type. The mode enum used to live inside PostDetailView (the de-facto
//  mode shell); the capability registry declares per-mode availability, so
//  the type moves to the shared Registry layer. PostDetailView keeps a
//  typealias so every call site and pin reads unchanged.
//
//  13b Stage 4 (4C — S4-3): OUTLINE RETIRED as a tab; the row is SIX.
//  Compare absorbed it ("outline should probably just be folded into the
//  compare tab… I don't think it as an outline needs to be anything that
//  a compare already isn't") — make-outline-post lives in Compare's
//  header now, and a remembered "Outline" mode decodes as Compare
//  (`fromStored` — no stored value strands).
//

import Foundation

/// The post detail's modes. Sitting 9's row minus Outline (retired into
/// Compare at the Stage 4 kickoff, S4-3), PLUS the pre-13u Act 10 wave 2c
/// pair — and then MINUS one of them: **the Act 10 correction round (her
/// rulings R-cor-5/7) retired INDEX INTO READ.** Her words: *"I like one
/// tab named read … making it more similar to book, where it's a selector
/// within a place you're in"*; *"there is an editable index surface, then
/// you click read and it isn't anymore."* So READ is ONE tab carrying an
/// in-place `edit · read` switch — `edit` the editable index surface (the
/// `▸ 01` column beside a text pane whose clicked block goes live), `read`
/// the calm page, never editable — and a remembered "Index" decodes as Read
/// (`fromStored`, the Outline→Compare precedent: no stored value strands).
/// The row reads as writing (Write · Takes), reading (Read), comparing
/// (Lenses · Compare), managing (Blocks · Canvas).
///
/// Raw values are the user-facing words — they also key the per-post mode
/// memory (R79). The ⌘1–⌘7 keys derive from THIS order (EditorCommands'
/// ForEach), as do the sidebar rail and the masthead menu — one order,
/// three renderers, no way to disagree.
nonisolated enum PostMode: String, CaseIterable, Sendable {
    case write = "Write"
    case takes = "Takes"
    case read = "Read"
    case lenses = "Lenses"
    case compare = "Compare"
    case blocks = "Blocks"
    case canvas = "Canvas"

    /// The decode door for STORED mode strings (the per-post memory's
    /// migration, 13b 4C): a post left in the retired Outline tab reopens
    /// in Compare — its successor — never in a stranded default; a post
    /// left in the retired Index tab reopens in Read (the correction round,
    /// R-cor-5/7 — Read's `edit` face IS the index surface). Unknown
    /// strings still decode nil (the caller's fallback owns those).
    static func fromStored(_ raw: String, keepingCanvas: Bool = buildKeepsCanvas) -> PostMode? {
        if raw == "Outline" { return .compare }
        if raw == "Index" { return .read }
        return PostMode(rawValue: raw)
    }

    // MARK: - 17y B2 (p) — the build flavour's seam (PRE-FIX SHAPE: Canvas in every build)

    static let buildKeepsCanvas: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    static func order(keepingCanvas: Bool) -> [PostMode] {
        [.write, .takes, .read, .lenses, .compare, .blocks, .canvas]
    }

    static func keyLabel(keepingCanvas: Bool) -> String {
        "\u{2318}1\u{2013}\(order(keepingCanvas: keepingCanvas).count)"
    }

    static func keySpan(keepingCanvas: Bool) -> String {
        "\u{2318}1\u{2013}\u{2318}\(order(keepingCanvas: keepingCanvas).count)"
    }

    static func modeList(keepingCanvas: Bool) -> String {
        order(keepingCanvas: keepingCanvas).map(\.rawValue).joined(separator: " \u{00B7} ")
    }
}
