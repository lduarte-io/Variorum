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

/// The containment scan, copied from `BookOrderConversionTests` (where it is
/// private) so the twin pin below reads exactly what the navigator's shipped
/// pin reads: the leftmost DARK pixel in a horizontal band. The b6dae25 class
/// is not a clip — `.frame(width:)` CENTRES an over-wide child, so chrome
/// that will not fit pushes the whole column left and every row loses its
/// first characters. That is visible as ink at x near 0.
@MainActor
private func leftmostInkX(in view: NSView, band: ClosedRange<CGFloat>, maxX: CGFloat) -> CGFloat? {
    guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
    view.cacheDisplay(in: view.bounds, to: rep)
    let scale = CGFloat(rep.pixelsWide) / view.bounds.width
    for px in 0..<Int(maxX * scale) {
        for py in Int(band.lowerBound * scale)...Int(band.upperBound * scale) {
            guard let color = rep.colorAt(x: px, y: py) else { continue }
            let luminance = 0.299 * color.redComponent + 0.587 * color.greenComponent
                + 0.114 * color.blueComponent
            if luminance < 0.6 { return CGFloat(px) / scale }
        }
    }
    return nil
}

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
    /// What the harness hands its body: the book, its models, and the ids
    /// of ITS rows — every pin reads its own rows out of the shared oracle,
    /// because Swift Testing runs suites in PARALLEL and a second book
    /// mounted elsewhere lands in the same statics.
    private struct Chaptered {
        var session: AppSession
        var readingID: String
        var model: BookViewModel
        var structure: BookStructureModel
        var sectionIDs: [String]
        var postIDs: [String]
    }

    private func withChapteredBook<T>(
        _ body: @MainActor (Chaptered) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            // The LIVE uuid generator, deliberately: `.incrementing` hands
            // every suite the same id sequence, so two books mounted in
            // parallel suites share `…0001` and land on each other's key in
            // the DEBUG oracle (measured — a 700-pt-tall frame arriving for
            // a book mounted in an 800-pt window). These pins assert about
            // rectangles, never about a particular id, so nothing here wants
            // determinism; uniqueness is what they need.
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 22))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the room", kind: .book)
            var entries: [Queries.ReadingEntry] = []
            var sectionIDs: [String] = []
            for c in 0..<2 {
                let section = try session.operations.createSection(
                    in: reading.id, name: "chapter \(c)")
                sectionIDs.append(section.id)
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
            return try await body(Chaptered(
                session: session, readingID: reading.id, model: model,
                structure: structure, sectionIDs: sectionIDs,
                postIDs: entries.map(\.postID)))
        }
    }

    /// Mount a book and pump until the navigator has reported.
    private func mountBook(
        _ book: Chaptered, width: CGFloat = 1200, height: CGFloat = 800
    ) async -> (NSWindow, NSHostingView<some View>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        // VX-77 (R-U2-B): the containment scan reads LUMINANCE, so a host
        // left dark (the test host IS the dev-store app, and a walk can leave
        // its `appearanceChoice` on dark) draws a black room the scan reads as
        // "ink at 0.0". The window is pinned light, so the verdict is the
        // chrome's and never the host's posture.
        window.appearance = NSAppearance(named: .aqua)
        let hosting = NSHostingView(
            rootView: BookView(
                session: book.session, readingID: book.readingID,
                model: book.model, structure: book.structure)
                .environment(ThemeStore(session: book.session)))
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
        try await withChapteredBook { book in
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            let (window, _) = await mountBook(book)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            // MY rows, by id — never "whatever is in the oracle".
            let chapters = book.sectionIDs.compactMap {
                BookOutlineGeometry.navigatorChapterRows[$0]
            }
            let notes = book.postIDs.compactMap { BookOutlineGeometry.navigatorNoteRows[$0] }
            #expect(chapters.count == 2, "both chapter rows drew: \(chapters.count)")
            #expect(notes.count == 4, "all four note rows drew: \(notes.count)")
            for (index, frame) in chapters.enumerated() {
                #expect(frame.height >= BookNavigatorLayout.chapterRowHeight - 0.5,
                        "chapter \(index) drew \(frame.height) pt tall")
            }
            for (index, frame) in notes.enumerated() {
                #expect(frame.height >= BookNavigatorLayout.noteRowHeight - 0.5,
                        "note \(index) drew \(frame.height) pt tall")
            }
            // The groups stand apart: the lower chapter row's top, against
            // the bottom of the last note row above it.
            let secondChapter = try #require(chapters.sorted { $0.minY < $1.minY }.last)
            let above = notes.filter { $0.maxY <= secondChapter.minY + 0.5 }.map(\.maxY).max()
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
        try await withChapteredBook { book in
            defer { UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey) }
            // Nothing remembered: exactly the shipped slab's width, so the
            // day she upgrades nothing moves until she drags.
            UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            let (first, _) = await mountBook(book)
            #if DEBUG
            let fresh = try #require(BookOutlineGeometry.navigatorFrames[book.readingID])
            #expect(abs(fresh.width - BookNavigatorLayout.idealWidth) <= 1,
                    "a book with nothing remembered opens at the shipped width: \(fresh.width)")
            #endif
            first.orderOut(nil); first.close()

            // What a drag writes, read back on a FRESH mount.
            UserDefaults.standard.set(300.0, forKey: BookNavigatorLayout.widthKey)
            #if DEBUG
            BookOutlineGeometry.resetNavigator()
            #endif
            let (second, _) = await mountBook(book)
            #if DEBUG
            let remembered = try #require(BookOutlineGeometry.navigatorFrames[book.readingID])
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
            let (third, _) = await mountBook(book)
            defer { third.orderOut(nil); third.close() }
            #if DEBUG
            let clamped = try #require(BookOutlineGeometry.navigatorFrames[book.readingID])
            #expect(abs(clamped.width - BookNavigatorLayout.maximumWidth) <= 1,
                    "the navigator's own ceiling held: \(clamped.width)")
            #endif
        }
    }

    /// **The book's OTHER chapter panel.** By wave 2c's rule the navigator
    /// steps aside in Index and the index column stands in its place, so
    /// "the panel with the chapter names" is that column there — and it
    /// truncated the same names (measured at the walk). It is the same
    /// leading column, with its OWN remembered width: dragging one panel
    /// never moves the other. RED on the pre-fix shape (`.frame(width: 300)`).
    @Test func theIndexsChapterPanelIsTheWidthSheLeftItAtAndKeepsItsOwnMemory() async throws {
        try await withChapteredBook { book in
            defer {
                UserDefaults.standard.removeObject(forKey: BookIndexColumn.widthKey)
                UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            }
            book.structure.mode = .index
            // The navigator's own remembered width is a DIFFERENT panel's.
            UserDefaults.standard.set(340.0, forKey: BookNavigatorLayout.widthKey)
            UserDefaults.standard.removeObject(forKey: BookIndexColumn.widthKey)
            #if DEBUG
            BookIndexGeometry.reset()
            BookOutlineGeometry.resetNavigator()
            #endif
            let (fresh, _) = await mountBook(book)
            #if DEBUG
            let shipped = try #require(BookIndexGeometry.columnFrames[book.readingID])
            #expect(abs(shipped.width - BookIndexColumn.idealWidth) <= 1,
                    "Index opens at the shipped 300 whatever the navigator remembers: \(shipped.width)")
            #expect(BookOutlineGeometry.navigatorFrames[book.readingID] == nil,
                    "and THIS book's navigator steps aside in Index (wave 2c)")
            #endif
            fresh.orderOut(nil); fresh.close()

            UserDefaults.standard.set(420.0, forKey: BookIndexColumn.widthKey)
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (wider, _) = await mountBook(book)
            defer { wider.orderOut(nil); wider.close() }
            #if DEBUG
            let remembered = try #require(BookIndexGeometry.columnFrames[book.readingID])
            #expect(abs(remembered.width - 420) <= 1,
                    "the remembered width came back: \(remembered.width)")
            #endif
        }
    }

    // MARK: - The floors, exercised (18d ladder, MINOR-5)

    /// **The twin of `theNavigatorsChromeStaysInsideItsColumn`, at the two
    /// floors batch 3 minted.** The Index chapter panel went 300 to [240,
    /// 460] and Read's contents column 340 to [240, 640] — 60 and 100 pt
    /// below the fixed measure that WAS their containment guarantee — and
    /// both carry chrome inside the column (the book's masthead and word-tab
    /// row, the order control and a filter field; a filter field and a
    /// fold-all door). The b6dae25 class is that a frame does not clip an
    /// over-wide child, it CENTRES it, so chrome that will not fit pushes the
    /// whole column left and every row loses its first characters. Nothing
    /// exercised either floor: the width pins assert widths, and the walk
    /// dragged both only WIDER.
    ///
    /// PIN-DECIDES (the ladder's arbitration): red at the floor means raise
    /// the floor or fix the chrome; green means the finding was a coverage
    /// gap, now closed, recorded with its numbers.
    @Test func bothColumnsChromeStaysInsideThemAtTheirFloors() async throws {
        // (a) The book Index's chapter panel at its 240-pt floor.
        try await withChapteredBook { book in
            defer { UserDefaults.standard.removeObject(forKey: BookIndexColumn.widthKey) }
            book.structure.mode = .index
            UserDefaults.standard.set(
                Double(BookIndexColumn.minimumWidth), forKey: BookIndexColumn.widthKey)
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = await mountBook(book)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            let drawn = try #require(BookIndexGeometry.columnFrames[book.readingID])
            #expect(abs(drawn.width - BookIndexColumn.minimumWidth) <= 1,
                    "it really is at its floor: \(drawn.width)")
            #endif
            // The band holding the column's chrome — the book's title and
            // word-tab row, the order control, the filter — and the rows.
            let margin = try #require(
                leftmostInkX(in: hosting, band: 20...460, maxX: 40),
                "the column drew something")
            print("[18d MINOR-5] Index panel at its floor: leftmost ink \(margin) pt")
            #expect(margin >= 6,
                    "Index chapter panel clipped at its 240-pt floor: ink at \(margin) pt")
        }

        // (b) Read's contents column at its 240-pt floor.
        UserDefaults.standard.set(true, forKey: "readModeOutlineShown")
        UserDefaults.standard.set(
            Double(NoteIndexColumn.minimumWidth), forKey: ReadModeView.indexColumnWidthKey)
        defer { UserDefaults.standard.removeObject(forKey: ReadModeView.indexColumnWidthKey) }
        try await withReadHost { postID, _, hosting in
            #if DEBUG
            let drawn = try #require(ReadModeOracle.indexColumnFrames[postID])
            #expect(abs(drawn.width - NoteIndexColumn.minimumWidth) <= 1,
                    "it really is at its floor: \(drawn.width)")
            #endif
            // Below the face bar: the filter field, the fold-all door, the rows.
            let margin = try #require(
                leftmostInkX(in: hosting, band: 50...600, maxX: 40),
                "the column drew something")
            print("[18d MINOR-5] Read column at its floor: leftmost ink \(margin) pt")
            #expect(margin >= 6,
                    "Read contents column clipped at its 240-pt floor: ink at \(margin) pt")
        }
    }

    // MARK: - The seam itself (18d ladder, MAJOR-2)

    /// **Ledger row 9, on the boundary her U-13 asked to be draggable.** The
    /// shell's seam was fixed three ways at 17o batch d; `SideColumn` kept
    /// the old 9-pt `.overlay` with `NSCursor.push()`, and batch 3 put that
    /// on three more boundaries — the symptom showed up in its OWN walk ("a
    /// drag whose press had missed the 9-pt grip, so nothing was ever
    /// written"). The claim, in rectangles, is the shell pin's verbatim:
    /// the grip is wide, centred on the line, and reaches into BOTH sides.
    ///
    /// RED on the pre-fix tree in the strongest way there is — nothing
    /// reported a grip frame at all, because there was no grip with a frame
    /// of its own (an `.overlay` is not a layout participant).
    ///
    /// The `.zIndex(1)` half cannot be asserted from a frame (a hit-test
    /// order is not a rectangle) — it is walked instead, by a drag whose
    /// press lands in the part of the grip that overhangs the CONTENT, which
    /// is exactly the half that was dead.
    @Test func theLeadingSeamsGripIsWideCentredAndReachesIntoBothSides() async throws {
        try await withChapteredBook { book in
            // Round 2's MINOR-2: MY navigator's seam, by the book's own id
            // — `widthKey` alone is a per-host constant, so every navigator
            // in every parallel suite wrote the same entry. Cleared for THIS
            // key only (the round-end Fable pass, MINOR-2 (c)): a
            // whole-oracle reset wiped parallel suites' seams, which
            // `onGeometryChange` never republishes.
            let seam = SeamGeometry.key(BookNavigatorLayout.widthKey, subject: book.readingID)
            #if DEBUG
            SeamGeometry.forget(seam)
            #endif
            UserDefaults.standard.removeObject(forKey: BookNavigatorLayout.widthKey)
            let (window, _) = await mountBook(book)
            defer { window.orderOut(nil); window.close() }
            #if DEBUG
            let grip = try #require(
                SeamGeometry.gripFrames[seam],
                "the grip publishes a frame of its own (an overlay never did)")
            let line = try #require(SeamGeometry.lineFrames[seam])
            #expect(grip.width >= SeamGrip.width - 0.5,
                    "a reachable target, not the old 9: \(grip.width)")
            #expect(abs(grip.midX - line.midX) <= 0.5,
                    "centred on the seam: \(grip.midX) vs \(line.midX)")
            #expect(grip.minX < line.minX - 4 && grip.maxX > line.maxX + 4,
                    "…and it reaches into the navigator AND the page: \(grip) vs \(line)")
            #expect(grip.height >= 100, "it runs the seam, not a handle")
            // ONE constant, both seams (the hoist rule's point).
            #expect(ShellSplit<EmptyView, EmptyView>.gripWidth == SeamGrip.width)
            #endif
        }
    }

    // MARK: - 3 (the other half). The note Read tab's contents column

    /// Mount Read (`edit`, the face it opens on) over a three-block note.
    private func withReadHost<T>(
        _ body: @MainActor (String, BlockTOCViewModel, NSHostingView<AnyView>) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            // Live ids, for the reason above: the oracle is keyed by the
            // NOTE's id and parallel suites share `.incrementing`'s sequence.
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 26))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note with contents")
            for text in [
                "# A heading whose first line is long enough to want the room",
                "A paragraph whose first line runs well past the column's shipped measure.",
                "A third block, so the column has something to scroll.",
            ] {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .read) { _ in }
            let model = BlockTOCViewModel(session: session, postID: post.id)
            let window = NSWindow(
                contentRect: NSRect(x: 100, y: 100, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            // VX-77 (R-U2-B): pinned light — the scan's verdict never the host's.
            window.appearance = NSAppearance(named: .aqua)
            let hosting = NSHostingView(rootView: AnyView(
                ReadModeView(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<12 {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(30))
            }
            defer { window.orderOut(nil); window.close() }
            return try await body(post.id, model, hosting)
        }
    }

    /// **Her U-13's other half, measured.** Read's contents column is the
    /// width she left it at, on a fresh mount — so a long first line has
    /// somewhere to go. RED on the pre-fix shape: `.frame(width:
    /// NoteIndexColumn.width)`, a constant no stored width can move.
    @Test func theReadContentsColumnIsTheWidthSheLeftItAtAcrossARemount() async throws {
        defer { UserDefaults.standard.removeObject(forKey: ReadModeView.indexColumnWidthKey) }
        UserDefaults.standard.set(true, forKey: "readModeOutlineShown")
        // Nothing remembered: the shipped measure, so nothing moves for her
        // until she drags.
        UserDefaults.standard.removeObject(forKey: ReadModeView.indexColumnWidthKey)
        try await withReadHost { postID, _, _ in
            #if DEBUG
            let fresh = try #require(ReadModeOracle.indexColumnFrames[postID])
            #expect(abs(fresh.width - NoteIndexColumn.width) <= 1,
                    "a note with nothing remembered opens at the shipped 340: \(fresh.width)")
            #endif
        }
        // What a drag writes, read back on a FRESH mount.
        UserDefaults.standard.set(480.0, forKey: ReadModeView.indexColumnWidthKey)
        try await withReadHost { postID, _, _ in
            #if DEBUG
            let wider = try #require(ReadModeOracle.indexColumnFrames[postID])
            #expect(abs(wider.width - 480) <= 1,
                    "the remembered width came back: \(wider.width)")
            #endif
        }
        // And the floor holds: dragged past it, the column stops being a
        // contents list, so it never goes under its minimum.
        UserDefaults.standard.set(80.0, forKey: ReadModeView.indexColumnWidthKey)
        try await withReadHost { postID, _, _ in
            #if DEBUG
            let floored = try #require(ReadModeOracle.indexColumnFrames[postID])
            #expect(abs(floored.width - NoteIndexColumn.minimumWidth) <= 1,
                    "the column's floor held: \(floored.width)")
            #endif
        }
    }
}
