//
//  BookFoldDisclosureTests.swift
//  VariorumTests
//
//  **VX-291 — the book's fold control, measured.** Her words (2026-10-13):
//  *"that one little triangle could stand to just be a bit bigger."* The
//  Outline card's ▸ was an ~11×14-pt target inside the card's own Button (a
//  near miss opened the note); the expanded header's ▾ was a different
//  control; the Index's chapter fold was the 11.5-pt glyph again.
//
//  A taste row (an Improvement), so its evidence is a GEOMETRY ORACLE plus
//  the walk, not red-on-old: `BookFoldGeometry` reports each mounted control's
//  TARGET (the square a click lands in) and FOOTPRINT (what its row laid out),
//  and these pins read the claims off those rectangles —
//
//  1. the target is ≥ 22 pt square, for ▸ and ▾ alike (one control);
//  2. it GREW OUTWARD — it overhangs the footprint on all four sides;
//  3. the footprint is no taller than the 11.5-pt glyph's line it replaced, so
//     no row grows for it (the Outline card keeps the height
//     `BookOutlineHeights` learned — its 46-pt chrome constant).
//
//  (That the target never reaches the title beside it is arithmetic — the
//  overhang, 5 pt, is under every host row's spacing, 6 and 8 — and the
//  walk's to see.)
//
//  On the pre-fix tree nothing reports (no oracle existed) — red by absence,
//  recorded as such; the walk is the use-shaped half.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-291 — the book's fold control (22-pt, grown outward)", .serialized)
struct BookFoldDisclosureTests {

    private struct Book {
        var session: AppSession
        var readingID: String
        var model: BookViewModel
        var structure: BookStructureModel
        var sectionIDs: [String]
        var postIDs: [String]
    }

    /// Two chapters, two notes each (OutlineRoomTests' shape), each note with
    /// a paragraph so its card carries a preview.
    private func withBook<T>(_ body: @MainActor (Book) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            // Live ids: the oracle is subject-keyed and suites run in parallel.
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 291))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the folds", kind: .book)
            var entries: [Queries.ReadingEntry] = []
            var sectionIDs: [String] = []
            for c in 0..<2 {
                let section = try session.operations.createSection(in: reading.id, name: "chapter \(c)")
                sectionIDs.append(section.id)
                for n in 0..<2 {
                    let post = try session.operations.createPost(title: "note \(c).\(n)")
                    _ = try session.operations.newBlock(
                        in: post.id, text: "Paragraph one of note \(c).\(n), a few words long.")
                    try session.operations.addPostToReading(post.id, to: reading.id)
                    try session.operations.assignPostToSection(post.id, in: reading.id, section: section.id)
                    entries.append(Queries.ReadingEntry(
                        postID: post.id, title: "note \(c).\(n)", entryDate: nil, sectionPath: nil))
                }
            }
            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(entries)
            let structure = BookStructureModel(session: session, readingID: reading.id)
            structure.adopt(.init(
                reading: try await db.read { [id = reading.id] in try Queries.reading($0, id: id) },
                sections: try await db.read { [id = reading.id] in
                    try Queries.readingSections($0, readingID: id)
                },
                deletedSections: [],
                assignments: try await db.read { [id = reading.id] in
                    try Queries.sectionAssignments($0, readingID: id)
                }))
            structure.mode = .outline
            return try await body(Book(
                session: session, readingID: reading.id, model: model, structure: structure,
                sectionIDs: sectionIDs, postIDs: entries.map(\.postID)))
        }
    }

    private func mount(_ book: Book) async -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: book.session, readingID: book.readingID,
                model: book.model, structure: book.structure)
                .environment(ThemeStore(session: book.session)))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(30))
        }
        return window
    }

    /// The glyph the Outline card's ▸ used to be: the voice's 11.5-pt small
    /// size (Terminal's is the monospaced one — what an unstarted
    /// `ThemeStore` draws), measured off the real font.
    private var replacedLineHeight: CGFloat {
        NSAttributedString(
            string: "\u{25B8}",
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: 11.5, weight: .regular)]
        ).size().height
    }

    #if DEBUG
    /// Claims 1–3 for one control's two rectangles.
    private func expectGrownOutward(_ frames: BookFoldGeometry.Frames, _ what: String) throws {
        let hit = try #require(frames.hit, "\(what): the target reported")
        let layout = try #require(frames.layout, "\(what): the footprint reported")
        #expect(hit.width >= BookFoldDisclosure.hitSide - 0.5 && hit.height >= BookFoldDisclosure.hitSide - 0.5,
                "\(what): a 22-pt target, not the old ~11×14: \(hit.size)")
        #expect(hit.minX < layout.minX - 1 && hit.maxX > layout.maxX + 1
                && hit.minY < layout.minY - 1 && hit.maxY > layout.maxY + 1,
                "\(what): the target grew OUTWARD past its footprint on every side: \(hit) vs \(layout)")
        let replaced = replacedLineHeight
        #expect(layout.height <= replaced + 0.5,
                "\(what): its row lays out no more than the 11.5-pt glyph's line it replaced (\(replaced)) — no row grows for it: \(layout.height)")
    }
    #endif

    /// **The Outline: the card's ▸ and the expanded header's ▾.** One note
    /// collapsed (its card), one expanded (its header) — the two states of
    /// the one control, measured.
    @Test func theOutlinesUnfoldAndFoldAreOneTwentyTwoPointTargetGrownOutward() async throws {
        try await withBook { book in
            let card = book.postIDs[0]
            let open = book.postIDs[1]
            book.model.expand(open)
            let window = await mount(book)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            let cardFrames = try #require(
                BookFoldGeometry.frames["card-\(card)"], "the card's ▸ reported its frames")
            let headerFrames = try #require(
                BookFoldGeometry.frames["header-\(open)"], "the expanded header's ▾ reported its frames")
            try expectGrownOutward(cardFrames, "the card's ▸")
            try expectGrownOutward(headerFrames, "the header's ▾")
            // One control: ▸ and ▾ are the same box.
            let a = try #require(cardFrames.hit), b = try #require(headerFrames.hit)
            #expect(abs(a.width - b.width) <= 0.5 && abs(a.height - b.height) <= 0.5,
                    "▸ and ▾ are one control: \(a.size) vs \(b.size)")
            #endif
        }
    }

    /// **FINDING W-1 (the walk): the target must TAKE THE CLICK, not only the
    /// hover.** A real click (the `SharedIconRig` road — down, a beat, up)
    /// INSIDE the 22-pt box but OUTSIDE the footprint, on the card's ▸ (left of
    /// the glyph), UNFOLDS the note in place. (The ▾ is the same control; a
    /// synthetic press on the header's draggable row HUNG the pre-fix run when
    /// it fell through, so the ▾'s click is the walk's.) RED on the walk's tree: the Button's own frame
    /// was the 12×13 footprint (the negative padding sat inside its style), so a
    /// press there was taken and dropped — the hover answered, the click didn't.
    @Test func aClickInTheOverhangUnfoldsTheNote() async throws {
        try await withBook { book in
            let card = book.postIDs[0]
            let rig = SharedIconRig(
                BookView(
                    session: book.session, readingID: book.readingID,
                    model: book.model, structure: book.structure)
                    .environment(ThemeStore(session: book.session)),
                width: 1200, height: 800)
            defer { rig.close() }
            #if DEBUG
            @MainActor func windowPoint(_ p: CGPoint) -> NSPoint {
                NSPoint(x: p.x, y: rig.hosting.bounds.height - p.y)
            }
            _ = await rig.poll(timeout: 8) { BookFoldGeometry.frames["card-\(card)"]?.hit != nil }
            let cardFrames = try #require(BookFoldGeometry.frames["card-\(card)"])
            let cardHit = try #require(cardFrames.hit), cardLayout = try #require(cardFrames.layout)
            // Left of the glyph: in the target, clear of the footprint.
            let left = CGPoint(x: cardHit.minX + 1.5, y: cardHit.midY)
            #expect(left.x < cardLayout.minX - 2, "the press is in the OVERHANG: \(left) vs \(cardLayout)")
            #expect(!book.model.isExpanded(card), "the premise: the card is folded")
            await rig.click(at: windowPoint(left))
            #expect(await rig.poll(timeout: 3) { book.model.isExpanded(card) },
                    "a click in the ▸'s overhang unfolds the note in place")
            #endif
        }
    }

    /// **The Index's chapter fold** (PROVISIONAL in the plan — "if she
    /// agrees"; built): the same control in the chapter rows.
    @Test func theIndexsChapterFoldIsTheSameControl() async throws {
        try await withBook { book in
            book.structure.mode = .index
            let window = await mount(book)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            for section in book.sectionIDs {
                let frames = try #require(
                    BookFoldGeometry.frames["chapter-\(section)"],
                    "chapter \(section)'s fold reported its frames")
                try expectGrownOutward(frames, "the Index chapter fold")
            }
            #endif
        }
    }
}
