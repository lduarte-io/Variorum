//
//  LandingTarget.swift
//  Variorum (Shared)
//
//  The Act 10 correction round, batch B (row 38 — 13u item 17 pulled in):
//  **the scrolled-open door's ONE value.** A click on a sentence anywhere
//  read-cheap names where it wants to land — the note, the block under
//  the click, and (when the surface knows it) the UTF-16 offset inside
//  that block — and the arriving editing surface performs the landing:
//  the mode switch, the reveal, and making THAT block live with the caret
//  there. Built once here for the book (Read ▸ Scroll → the editable
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
    /// The caret's place inside the block, UTF-16, when the surface can
    /// say (a TK2 read tier can; a SwiftUI `Text` paragraph cannot — the
    /// landing then puts the caret at the block's start).
    var utf16Offset: Int? = nil
}
