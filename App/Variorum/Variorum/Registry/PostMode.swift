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
/// pair (item 16, W8-1 — her rulings): **INDEX** ("obviously a need, seems
/// more fundamental, let's put it in under Takes" — confirmed a NEW MODE
/// TAB after Takes) and **READ** (the note READ surface, read-only,
/// vertical/book-like — "that's the thing that notes have been missing
/// relative to books, is the ability to read"). Read sits beside Index
/// deliberately (implementer's recorded taste call): the row then reads
/// as writing (Write · Takes), reading (Index · Read), comparing
/// (Lenses · Compare), managing (Blocks · Canvas) — and Read's
/// click-through lands in Index, so the neighbours are the pair.
///
/// Raw values are the user-facing words — they also key the per-post mode
/// memory (R79). The ⌘1–⌘8 keys derive from THIS order (EditorCommands'
/// ForEach), as do the sidebar rail and the masthead menu — one order,
/// three renderers, no way to disagree.
nonisolated enum PostMode: String, CaseIterable, Sendable {
    case write = "Write"
    case takes = "Takes"
    case index = "Index"
    case read = "Read"
    case lenses = "Lenses"
    case compare = "Compare"
    case blocks = "Blocks"
    case canvas = "Canvas"

    /// The decode door for STORED mode strings (the per-post memory's
    /// migration, 13b 4C): a post left in the retired Outline tab reopens
    /// in Compare — its successor — never in a stranded default. Unknown
    /// strings still decode nil (the caller's fallback owns those).
    static func fromStored(_ raw: String) -> PostMode? {
        if raw == "Outline" { return .compare }
        return PostMode(rawValue: raw)
    }
}
