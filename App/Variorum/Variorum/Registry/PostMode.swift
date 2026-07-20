//
//  PostMode.swift
//  Variorum (Mac)
//
//  Phase 13b, Stage 1b (P-1): the seven post modes as a shared vocabulary
//  type. The mode enum used to live inside PostDetailView (the de-facto
//  mode shell); the capability registry declares per-mode availability, so
//  the type moves to the shared Registry layer. PostDetailView keeps a
//  typealias so every call site and pin reads unchanged.
//

import Foundation

/// The post detail's seven modes (Sitting 9's final row: Write · Takes ·
/// Lenses · Compare · Outline · Blocks · Canvas). Raw values are the
/// user-facing words — they also key the per-post mode memory (R79).
nonisolated enum PostMode: String, CaseIterable, Sendable {
    case write = "Write"
    case takes = "Takes"
    case lenses = "Lenses"
    case compare = "Compare"
    case outline = "Outline"
    case blocks = "Blocks"
    case canvas = "Canvas"
}
