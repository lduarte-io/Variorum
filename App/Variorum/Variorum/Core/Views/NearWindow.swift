//
//  NearWindow.swift
//  Variorum (MAC ONLY) — Core/Views (the shared home: the Library's paged
//  listing and the Timeline each move one)
//
//  **THE NEAR WINDOW** — 17y B1 (k)'s pure rule (her "the library only shows
//  you the first 40 notes is completely unacceptable … no performance losses
//  are acceptable for it"), moved here from `LibraryCatalogPaging` at VX-281's
//  ladder (R1-1) so the Timeline's reach hold is shaped by the SAME rule
//  rather than a second one: the pages holding the rows on screen, one page
//  beyond on each side — a page boundary is the only thing that moves it, so
//  a hold aimed at it re-aims a few times per screenful, never per row.
//
//  A held observation's fetch must itself be viewport-shaped
//  (`AppDatabase.observe`); this is the shape, said once.
//

import Foundation

nonisolated enum NearWindow {
    /// The pages (of `pageSize` rows) around the `visible` positions in a
    /// listing of `count` rows. Nothing visible yet (a fresh listing) is the
    /// first page and the next.
    static func pages(visible: Set<Int>, count: Int, pageSize: Int) -> ClosedRange<Int> {
        let lastPage = max(0, (count - 1) / pageSize)
        guard let low = visible.min(), let high = visible.max() else {
            return 0...min(1, lastPage)
        }
        let from = max(0, low / pageSize - 1)
        let to = min(lastPage, high / pageSize + 1)
        return from...max(from, to)
    }
}
