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

/// The post detail's six modes (Sitting 9's row, minus Outline — retired
/// into Compare at the Stage 4 kickoff, S4-3: Write · Takes · Lenses ·
/// Compare · Blocks · Canvas). Raw values are the user-facing words —
/// they also key the per-post mode memory (R79).
nonisolated enum PostMode: String, CaseIterable, Sendable {
    case write = "Write"
    case takes = "Takes"
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
