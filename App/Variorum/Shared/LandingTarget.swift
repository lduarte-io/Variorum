//
//  LandingTarget.swift
//  Variorum (Shared)
//
//  The Act 10 correction round, batch B (row 38 — 13u item 17 pulled in):
//  **the scrolled-open door's ONE value.** A click on a sentence anywhere
//  read-cheap names where it wants to land — the note, and the block under
//  the click — and the arriving editing surface performs the landing: the
//  mode switch, the reveal, and making THAT block live, its caret at the
//  block's start. Built once here for the book (Read ▸ Scroll → the editable
//  Index); the note's own version (batch C: Read → the Index edit surface,
//  Write) consumes the same value.
//
//  Pure and tiny on purpose: it carries no decision. Which surface lands,
//  and how, is the consumer's; this only says where.
//

import Foundation

nonisolated struct LandingTarget: Equatable, Sendable {
    /// The note to land in.
    let postID: String
    /// The block under the click — nil when the surface knows only the
    /// note (a title, a whole-note tap): the landing then means the
    /// note's first block.
    var blockID: String? = nil

    // **No caret OFFSET rides this value** (18l-b U4 — the `utf16Offset`
    // field DELETED; QUESTIONS #153, PROVISIONAL). It was declared with a
    // paragraph of intent and set by no production site (the post-13u health
    // review's §1.3 item 4), and no face on its road SAYS where inside a
    // block she clicked: Read ▸ Scroll's paragraph is a SwiftUI `Text` under a
    // bare tap (it cannot), and the paged leaf hands its host a block, not the
    // CoreText index under the click (it could, cheaply — but a Read click
    // seeding a caret at a character is #149's product question, and #153
    // carries the trace). The caret offsets that DO exist travel on the
    // `FocusedBlock` road through `CommandRouter` (`focusedBlock` /
    // `currentBlock(for:)` — the note's remembered place, read by the
    // `WriteIntent` doors and `PaneCaretLanding.entering`), never on this
    // value. The book Index puts a landing's caret at the landed block's
    // START (`BookIndexEditModel.takePendingLiveBlock`). A clicked place
    // riding a landing is #153's alternative — a replica of the reading
    // page's type (`ReadTierClickPlace` for a third face) and #149's
    // carve-out extended to Read's own surfaces — hers to rule.
}
