//
//  BookcaseDragFaceTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-116 (17y B-WALK W-4 + W-5) — what a Bookcase book
//  drag SHOWS.** Her walk, two findings:
//
//  - W-4 (R-LWP-3): the drag image was the row's scattered full-line
//    snapshot — "needs to be clearer what is being dragged... maybe as you
//    drag it becomes just the title", refined at her sitting: "you should be
//    able to start the drag from anywhere on the row though - even if it's
//    only the title it should move to be where your cursor is so dragging
//    into something feels natural and you aren't dragging with an offset."
//  - W-5: in a–z a book drag shows a line that does nothing on release —
//    "remove the useless line". TRACED (the B-WALK record): the line is a
//    section HEADER's drop hairline — drawn under the header (right above
//    its first row, reading as an insertion line) for ANY book hovering it,
//    while a drop on the book's OWN shelf's header re-shelves it nowhere
//    (`reshelve`'s same-shelf guard returns silently). A door that does
//    nothing must not offer (§12).
//
//  Red-on-old, stated: the source pin was committed AHEAD of the fix and ran
//  red on that tree (no drag preview on the book row; the header's hover
//  lit for every drag). The rule's own pins land with the fix.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-116 — a book drag shows its title; a header lights only where a drop acts")
struct BookcaseDragFaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    @Test func theBookRowDragsItsTitleAndTheHeaderAsksTheRule() throws {
        let shelf = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/ShelfView.swift"),
            encoding: .utf8)
        #expect(shelf.contains("BookDragChip("), "the book row's drag image is the compact title chip")
        #expect(shelf.contains("model.headerDropLights("),
                "a header lights only where its drop would act")
    }
}
