//
//  BookTitleTicker.swift
//  Variorum (Mac)
//
//  **VX-1080 (T-2 as amended by R-1036-35) — a long note title in a book.**
//  Her words (sitting 2, R-1036-19): *"what happens to a title that is too long
//  is already ugly - i think it might be better if it did the radio style
//  scroll when it's too long."* And sitting 3 (R-1036-35): *"title scroll -
//  only under the pointer and on the live note, otherwise just ... - and only
//  one at a time scrolling."* The architect's fill: the title under the
//  pointer moves and the live note's waits.
//
//  The ticker itself is the wing label's (`WingMarquee`, its `.ellipsis` rest
//  — one implementation, never a sibling). What lives here is the ARBITER:
//  which ONE title of the book may move now. Its own small model (P-9), kept
//  off `BookViewModel`.
//

import Observation
import SwiftUI

/// **Which title moves** (pure — pinned without a window): the title under the
/// pointer, if it overflows; else the live note's, if IT overflows; else none.
/// Only one, ever. A title that fits never claims the pointer (it would stop
/// the live note's for nothing).
enum BookTitleTickerRule {
    static func mover(hovered: String?, live: String?, overflowing: Set<String>) -> String? {
        if let hovered, overflowing.contains(hovered) { return hovered }
        if let live, overflowing.contains(live) { return live }
        return nil
    }
}

/// The book's ONE title arbiter: what each realized title reports (does it
/// overflow its line) and which card the pointer is on. Rows read
/// `isMoving(_:live:)`; nothing here moves anything — `WingMarquee` does.
@MainActor
@Observable
final class BookTitleTickerModel {
    /// The note whose card or header the pointer is on, or nil.
    private(set) var hovered: String?
    /// The realized titles that overflow their line.
    private(set) var overflowing: Set<String> = []

    func pointer(_ postID: String, isOn: Bool) {
        if isOn {
            if hovered != postID { hovered = postID }
        } else if hovered == postID {
            hovered = nil
        }
    }

    func title(_ postID: String, overflows: Bool) {
        if overflows {
            if !overflowing.contains(postID) { overflowing.insert(postID) }
        } else if overflowing.contains(postID) {
            overflowing.remove(postID)
        }
    }

    /// A title left the column (its row was released): it neither overflows
    /// nor holds the pointer any more.
    func forget(_ postID: String) {
        title(postID, overflows: false)
        pointer(postID, isOn: false)
    }

    func isMoving(_ postID: String, live: String?) -> Bool {
        BookTitleTickerRule.mover(hovered: hovered, live: live, overflowing: overflowing) == postID
    }
}

/// **A book note's title** — one line, "…" at rest; the radio ticker only
/// while the arbiter lets it move (never under Reduce Motion — the plan's own
/// rule). With no arbiter (a harness mount) it simply rests.
struct BookNoteTitle: View {
    let title: String
    let postID: String
    let ticker: BookTitleTickerModel?
    let live: String?

    var body: some View {
        WingMarquee(
            words: title, maxWidth: .infinity, resting: .ellipsis,
            active: ticker?.isMoving(postID, live: live) ?? false,
            onOverflow: { overflows in ticker?.title(postID, overflows: overflows) })
        .onDisappear { ticker?.forget(postID) }
    }
}
