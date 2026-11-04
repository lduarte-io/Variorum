//
//  TakesCommentFeed.swift
//  Variorum (Mac)
//
//  **VX-732 (VX-770 batch 3) — the Takes board's comments, LIVE.** Her
//  recording: ⌥⌘Z undid an AI's comments, the receipt said so, and the board
//  kept drawing them in the gutter until she switched modes. The traced
//  mechanism (the run record's BATCH 3 trace): each article row's comment face
//  kept a copy filled by ONE read when the row was realized, keyed only on its
//  block id — the undo's delivery re-rendered the row, the copy survived it,
//  and nothing ever read it again.
//
//  The board now draws from the one feed every other comment surface draws
//  from: a live, per-NOTE read of `Queries.containerComments` — Write's own
//  query and its own shape (`EditorViewModel.observeComments`), the read tier's,
//  Compare's (batch 2). A store change by any road — an undo, the AI, another
//  window's panel, a sync apply — reaches the gutter at the observation's next
//  value. **Cost (P1, P-8):** one observation per mounted board; its region is
//  `block_comment` + `container_block`, so it wakes on comment and placement
//  writes, never on a keystroke (autosave writes `variant` and `container`),
//  and each wake reads ∝ the note's own comments — exactly what Write pays for
//  the same note. Never per row, never polled.
//

import Foundation
import Observation
import VariorumCore

/// The board's comment projection: block id → its live comments, panel order.
/// Plain storage — THE takes board's conductor runs the observation
/// (`TakesViewModel.observeComments`) and hands each value here; each row's
/// face reads its own block's entries in its own body, so a comment change
/// re-renders only the realized faces.
@MainActor
@Observable
final class TakesCommentFeed {
    /// blockID → its live comments, `(created_at, id)` order; blocks with none
    /// are absent (`Queries.containerComments`' shape).
    private(set) var byBlock: [String: [BlockDecor.CommentBrief]] = [:]

    /// The texts a block's face draws, panel order.
    func entries(for blockID: String) -> [String] {
        byBlock[blockID]?.map(\.text) ?? []
    }

    /// Internal so pins drive the feed without an observation. A value equal
    /// to the held one changes nothing (every face reads `byBlock` when it is
    /// drawn, so nothing waits on a change it was not shown).
    func adopt(_ value: [String: [BlockDecor.CommentBrief]]) {
        guard value != byBlock else { return }
        byBlock = value
    }
}
