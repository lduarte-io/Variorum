//
//  OutlineRoomTests.swift
//  VariorumTests
//
//  **THE OUTLINE'S ROOM** — the use-report round's 18d batch 3, her U-13:
//  *"the chapters feel too tightly clustered and the panel with the chapter
//  names should also be draggable to be a bit bigger"* · *"table of contents
//  in read mode for a note is horizontally limited and not changable, should
//  be adjustable."* (Ledger rows 22 · 26 · 33.)
//
//  Three claims, three kinds of evidence:
//
//  1. **The width brain's LEADING half is the trailing one's mirror** —
//     pure, and held against the shipped half rather than restated: for
//     every pointer x, leading(x) == trailing(total − x), R1-7's
//     past-the-edge floor included. The existing `SideColumnTests` ride
//     unmodified beside this (they own the trailing half).
//  2. **The navigator's rows have room** — a geometry oracle over the
//     MOUNTED book: what the chapter rows and the note rows actually drew,
//     and the air between one chapter's group and the next. RED on the
//     pre-fix shape (`VStack(spacing: 2)`, rows at their text height).
//  3. **Both columns remember their width across a remount** — the drawn
//     column, read back after a fresh hosting view over a fresh `@AppStorage`
//     read. RED on the pre-fix shape (a fixed `.frame(width: 190)` / the
//     fixed `NoteIndexColumn.width`, which no stored width can move).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The outline's room (18d batch 3, U-13)", .serialized)
struct OutlineRoomTests {

    // MARK: - 1. The width brain's leading half (pure)

    /// The mirror, stated as a relation and not as a second table of
    /// numbers: a leading column dragged to x keeps exactly the width a
    /// trailing column dragged to (total − x) keeps. If either half ever
    /// grows a rule the other lacks, this fails without anyone having to
    /// have thought of the case.
    @Test func theLeadingDragMirrorsTheTrailingOneAboutTheColumn() {
        let total: CGFloat = 1100
        for x in stride(from: CGFloat(-120), through: 1220, by: 20) {
            let leading = SideColumnLayout.draggedWidthFromLeading(
                pointerX: x, total: total, ideal: 420, minimum: 280)
            let trailing = SideColumnLayout.draggedWidth(
                pointerX: total - x, total: total, ideal: 420, minimum: 280)
            #expect(leading == trailing,
                    "x=\(x): leading \(leading) vs trailing \(trailing)")
        }
        // And with a host's own lowered ceiling (the navigator's), the two
        // halves still agree.
        for x in stride(from: CGFloat(-40), through: 900, by: 20) {
            let leading = SideColumnLayout.draggedWidthFromLeading(
                pointerX: x, total: 900, ideal: 190, minimum: 190, maximum: 360)
            let trailing = SideColumnLayout.draggedWidth(
                pointerX: 900 - x, total: 900, ideal: 190, minimum: 190, maximum: 360)
            #expect(leading == trailing, "x=\(x) at the navigator's clamps")
        }
    }

    /// R1-7's floor, on the LEADING side: a pointer dragged past the
    /// window's leading edge proposes ≤ 0, which the width rule reads as
    /// "nothing remembered" — so without the floor a column being dragged
    /// NARROW would snap WIDE at the edge. The mirror of the defect the
    /// trailing half was fixed for.
    @Test func aLeadingDragPastTheEdgeMeansTheMinimumNeverTheIdeal() {
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: -40, total: 1100, ideal: 420, minimum: 280) == 280)
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 0, total: 1100, ideal: 420, minimum: 280) == 280)
        // An ordinary drag asks for the room LEFT of the pointer.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 400, total: 1100, ideal: 420, minimum: 280) == 400)
        // Clamped by the ceiling the host set — the navigator's 360.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 900, total: 1400, ideal: 190, minimum: 190, maximum: 360) == 360)
        // And by the room the content keeps, whatever is dragged: a 600-pt
        // pane leaves the book's page its 320-pt floor, so the navigator
        // stops at 280 however far right the pointer goes.
        #expect(SideColumnLayout.draggedWidthFromLeading(
            pointerX: 500, total: 600, ideal: 190, minimum: 190, maximum: 360) == 280)
    }

    /// A host may LOWER the ceiling; nothing else about the rule moves, and
    /// the shared default is what every caller written before 18d reads.
    @Test func aHostsOwnCeilingClampsTheRememberedWidth() {
        // The navigator's clamps: 190 … 360.
        #expect(SideColumnLayout.width(
            remembered: 900, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 360)
        #expect(SideColumnLayout.width(
            remembered: 300, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 300)
        #expect(SideColumnLayout.width(
            remembered: 40, ideal: 190, minimum: 190, total: 1400, maximum: 360) == 190)
        // Unmeasured (the first pass, before any geometry read): inside the
        // host's floor and ceiling, so a stored 900 never draws at 900 for
        // a frame in a column whose ceiling is 360.
        #expect(SideColumnLayout.width(
            remembered: 900, ideal: 190, minimum: 190, total: 0, maximum: 360) == 360)
        // The default IS the shared ceiling (the note's panels, unchanged).
        #expect(SideColumnLayout.width(remembered: 900, ideal: 420, minimum: 280, total: 1100)
            == SideColumnLayout.width(remembered: 900, ideal: 420, minimum: 280,
                                      total: 1100, maximum: SideColumnLayout.maximum))
    }

    // MARK: - 2 + 3. The book navigator (mounted)

    /// A chaptered book, mounted: two chapters, two notes each (so no
    /// chapter row collapses into its one note — row 8's rule).
    private func withChapteredBook<T>(
        _ body: @MainActor (AppSession, String, BookViewModel, BookStructureModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 22))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the room", kind: .curated)
            var entries: [Queries.ReadingEntry] = []
            for c in 0..<2 {
                let section = try session.operations.createSection(
                    in: reading.id, name: "chapter \(c)")
                for n in 0..<2 {
                    let post = try session.operations.createPost(title: "note \(c).\(n)")
                    _ = try session.operations.newBlock(
                        in: post.id, text: "Paragraph one of note \(c).\(n).")
                    try session.operations.addPostToReading(post.id, to: reading.id)
                    try session.operations.assignPostToSection(
                        post.id, in: reading.id, section: section.id)
                    entries.append(Queries.ReadingEntry(
                        postID: post.id, title: "note \(c).\(n)",
                        entryDate: nil, sectionPath: nil))
                }
            }
            let model = BookViewModel(session: session, readingID: reading.id)
            model.adopt(entries)
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
            return try await body(session, reading.id, model, structure)
        }
    }

    /// Mount a book and pump until the navigator has reported.
    private func mountBook(
        session: AppSession, readingID: String,
        model: BookViewModel, structure: BookStructureModel,
        width: CGFloat = 1200, height: CGFloat = 800
    ) async -> (NSWindow, NSHostingView<some View>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure)
                .environment(ThemeStore(session: session)))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<10 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(30))
        }
        return (window, hosting)
    }

    /// **Her U-13's first half, measured.** The chapters are not clustered:
    /// each chapter row draws at the generous pitch, each note row at the
    /// compact one, and one chapter's group stands clear of the next by the
    /// mockup's group gap. RED on the pre-fix shape — `VStack(spacing: 2)`
    /// over rows at their text height gave ~17-pt rows 2 pt apart, and the
    /// gap between groups was those same 2 pt.
    @Test func theNavigatorsChaptersHaveRoom() async throws {
        try await withChapteredBook { session, readingID, model, structure in
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            let (window, _) = await mountBook(
                session: session, readingID: readingID, model: model, structure: structure)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            let chapters = BookOutlineGeometry.navigatorChapterRows
            let notes = BookOutlineGeometry.navigatorNoteRows
            #expect(chapters.count == 2, "two chapter rows drew: \(chapters.keys.sorted())")
            #expect(notes.count == 4, "four note rows drew: \(notes.count)")
            for (id, frame) in chapters {
                #expect(frame.height >= BookNavigatorLayout.chapterRowHeight - 0.5,
                        "chapter \(id) drew \(frame.height) pt tall")
            }
            for (id, frame) in notes {
                #expect(frame.height >= BookNavigatorLayout.noteRowHeight - 0.5,
                        "note \(id) drew \(frame.height) pt tall")
            }
            // The groups stand apart: the lower chapter row's top, against
            // the bottom of the last note row above it.
            let orderedChapters = chapters.values.sorted { $0.minY < $1.minY }
            let secondChapter = try #require(orderedChapters.last)
            let above = notes.values.filter { $0.maxY <= secondChapter.minY + 0.5 }
                .map(\.maxY).max()
            let lastAbove = try #require(above, "two notes drew above the second chapter")
            #expect(secondChapter.minY - lastAbove >= BookNavigatorLayout.groupSpacing - 0.5,
                    "the groups are \(secondChapter.minY - lastAbove) pt apart")
            #endif
        }
    }

    /// **Her U-13's second half, measured.** The navigator is the width she
    /// left it at — on a fresh mount, from the store, over and over. RED on
    /// the pre-fix shape: a fixed `.frame(width: 190)` no stored width can
    /// move. (The drag that WRITES the store is the width brain's, pinned
    /// pure above and walked on the real build; this is the read half.)
    @Test func theNavigatorIsTheWidthSheLeftItAtAcrossARemount() async throws {
        try await withChapteredBook { session, readingID, model, structure in
            defer { UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey) }
            // Nothing remembered: exactly the shipped slab's width, so the
            // day she upgrades nothing moves until she drags.
            UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            let (first, _) = await mountBook(
                session: session, readingID: readingID, model: model, structure: structure)
            #if DEBUG
            let fresh = try #require(BookOutlineGeometry.navigatorFrame)
            #expect(abs(fresh.width - BookNavigatorLayout.idealWidth) <= 1,
                    "a book with nothing remembered opens at the shipped width: \(fresh.width)")
            #endif
            first.orderOut(nil); first.close()

            // What a drag writes, read back on a FRESH mount.
            UserDefaults.standard.set(300.0, forKey: BookNavigatorLayout.widthKey)
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            let (second, _) = await mountBook(
                session: session, readingID: readingID, model: model, structure: structure)
            #if DEBUG
            let remembered = try #require(BookOutlineGeometry.navigatorFrame)
            #expect(abs(remembered.width - 300) <= 1,
                    "the remembered width came back: \(remembered.width)")
            #endif
            second.orderOut(nil); second.close()

            // And it is CLAMPED by the navigator's own ceiling, not the
            // note panels' — a stored 900 draws at 360.
            UserDefaults.standard.set(900.0, forKey: BookNavigatorLayout.widthKey)
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            let (third, _) = await mountBook(
                session: session, readingID: readingID, model: model, structure: structure)
            defer { third.orderOut(nil); third.close() }
            #if DEBUG
            let clamped = try #require(BookOutlineGeometry.navigatorFrame)
            #expect(abs(clamped.width - BookNavigatorLayout.maximumWidth) <= 1,
                    "the navigator's own ceiling held: \(clamped.width)")
            #endif
        }
    }
}
