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
/// memory (R79). The ⌘1–⌘n keys derive from THIS order (EditorCommands'
/// ForEach), as do the sidebar rail and the masthead menu — one order,
/// three renderers, no way to disagree.
///
/// **17y B2 (p) — CANVAS IS DEBUG-ONLY** (her word at the 2026-10-04 evening
/// sitting: "let's just do that now, in this run of things", debug-only
/// ratified; her explicit ok on ⌘7 no longer being Canvas). The case stays
/// (Debug keeps her tinkering surface, and every `switch` stays exhaustive);
/// the ORDER drops it in Release — here, in `allCases`, the one derivation
/// every renderer reads, never a per-view `#if` (P-1). Every other Canvas
/// door reads the same seam (`buildKeepsCanvas` + the pure flavour functions
/// below): the stored-mode decode, the ⌘-span words, the helper's dictionary
/// entry, the Snippets area's Canvas face. `CanvasDebugOnlyTests` pins both
/// flavours through the pure seam (the test target builds Debug only).
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
    /// strings still decode nil (the caller's fallback owns those). 17y B2
    /// (p): a mode the BUILD does not carry decodes nil too — a note she left
    /// in Canvas reopens in the default on a Release build (PROVISIONAL —
    /// the caller's default, Write; never a stranded mode).
    static func fromStored(_ raw: String, keepingCanvas: Bool = buildKeepsCanvas) -> PostMode? {
        if raw == "Outline" { return .compare }
        if raw == "Index" { return .read }
        guard let mode = PostMode(rawValue: raw),
              order(keepingCanvas: keepingCanvas).contains(mode) else { return nil }
        return mode
    }

    // MARK: - 17y B2 (p) — the build flavour's seam

    /// THE compile condition — read by nothing but this seam. A Debug build
    /// keeps Canvas; anything else (Release) drops it.
    static let buildKeepsCanvas: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    /// Every mode in the row's order (Debug's row). `order(keepingCanvas:)`
    /// filters it; a new case must join it (the row's order IS this list —
    /// `allCases` is overridden, so the compiler no longer lists cases for
    /// us; `CanvasDebugOnlyTests.everyCaseSitsInTheDebugRow` catches a miss).
    private static let declaredOrder: [PostMode] = [
        .write, .takes, .read, .lenses, .compare, .blocks, .canvas,
    ]

    /// The row for a build flavour — pure, so a Debug test run pins BOTH.
    static func order(keepingCanvas: Bool) -> [PostMode] {
        keepingCanvas ? declaredOrder : declaredOrder.filter { $0 != .canvas }
    }

    /// **THE ONE DERIVATION** every renderer reads — the mode row, ⌘1–⌘n,
    /// the sidebar rail, the masthead menu: this build's row.
    static var allCases: [PostMode] { order(keepingCanvas: buildKeepsCanvas) }

    /// "⌘1–7" (Debug) / "⌘1–6" (Release) — the registry's shortcut label and
    /// the helper's row (one string, so `everyDeclaredShortcutIsFindable…`
    /// keeps them one).
    static func keyLabel(keepingCanvas: Bool = buildKeepsCanvas) -> String {
        "\u{2318}1\u{2013}\(order(keepingCanvas: keepingCanvas).count)"
    }

    /// "⌘1–⌘7" / "⌘1–⌘6" — the long span the verbs and the help say.
    static func keySpan(keepingCanvas: Bool = buildKeepsCanvas) -> String {
        "\u{2318}1\u{2013}\u{2318}\(order(keepingCanvas: keepingCanvas).count)"
    }

    /// "Write · Takes · Read · Lenses · Compare · Blocks[ · Canvas]".
    static func modeList(keepingCanvas: Bool = buildKeepsCanvas) -> String {
        order(keepingCanvas: keepingCanvas).map(\.rawValue).joined(separator: " \u{00B7} ")
    }
}
