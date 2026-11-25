//
//  BookMastheadFitsItsColumnTests.swift
//  VariorumTests
//
//  **VX-1014 — a book's search field, opened in a narrow column, never widens
//  the column.** Seen once at the VX-980 gate walk (Study, dark, 1270-pt
//  window): the 🔍 on a gathering's masthead opened its field and the masthead
//  (title · field · 🔍 · gear) grew wider than the navigator — the
//  navigator's content shifted left over the sidebar's edge, the 🔍 was
//  clipped and the gear left the row.
//
//  The mechanism (traced and measured in
//  `notes/plans/fixes/vx-1082-nov-24-fixes.md`, BATCH S): the title line was
//  an `HStack` whose open field had a hard 90-pt floor; SwiftUI offers an
//  HStack's room least-flexible-first, so a SHORT name keeps its whole width
//  and the field then takes its floor whatever is left — the line is wider
//  than its room. The navigator's flexible frame adopts the wider child and
//  `SideColumn`'s fixed `.frame(width:)` CENTRES it, so the whole navigator
//  hangs over both edges. The Index column carries the same masthead.
//
//  The oracle is the masthead TITLE LINE's own laid-out width
//  (`BookOutlineGeometry.mastheadTitleLines`, DEBUG — D-1082-S3: the first cut
//  read the whole column, which another child moved by 1 pt in Terminal at
//  rest), against the room its column gives it (the floor less the column's
//  padding). RED on the pre-fix tree for every open-field row below (by
//  the windowless measurement: "Poems" draws a 190-pt line in a 166-pt room,
//  "Video ideas" 200 pt, "Video ideas" with "12" at Arrivals 220 pt; in the
//  Index column at its 240-pt floor, 245 pt in 212). GUARD, green on both
//  trees: the field CLOSED never widens either column.
//
//  **VX-1091 (the VX-1036 run, at its merge of VX-1082 — A JUSTIFIED EDIT):**
//  the navigator's floor is PER VOICE now — the shipped 190 held up to the
//  mode row's stable tabs plus the navigator's padding
//  (`BookNavigatorLayout.minimumWidth(tabs:)` → `BookNavigatorFloor`; with the
//  List mode's fifth tab, 229 pt Terminal and 203 Study) — so the navigator's
//  room is 205 / 179, not the old floor's 166. The navigator pins read that
//  room from the same input `BookView` hands `SideColumn` (`navigatorRoom`),
//  and the tabs' `max` the room carried while VX-1091 was open collapses to
//  it, as its own note said it would. The CLAIM is unchanged: the title line
//  never widens its column. The red-on-old numbers above are VX-1082's, at
//  the old floor; the Index column's room is untouched.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1014 — the book masthead's open search field never widens its column", .serialized)
struct BookMastheadFitsItsColumnTests {
    struct Mounted {
        let session: AppSession
        let readingID: String
        let model: BookViewModel
        let structure: BookStructureModel
        let arrivals: BookArrivalsModel
        let search: BookSearchModel
    }

    /// A book (a living one on `#inbox` whose matches WAIT at Arrivals, one
    /// member seated, `waiting` notes rung to the door by real intake) or a
    /// gathering on the same rule, in `voice`.
    private func withMasthead<T>(
        name: String, kind: ReadingKind, waiting: Int, voice: ThemeVoice,
        mode: BookStructureModel.ViewMode = .outline,
        _ body: @MainActor (Mounted, ThemeStore) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            // Unique ids: the DEBUG geometry oracles are keyed by book id, and
            // parallel suites must never land on each other's key
            // (`OutlineRoomTests`' reason).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1014))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            try ops.setThemeVoice(voice)
            let inbox = try ops.createTag(name: "inbox")
            let rule = try #require(try RuleGrammar.encode(.tag(inbox.id)))
            let reading = kind == .book
                ? try ops.createReading(name: name, kind: .book, querySpec: rule, intakeSeating: .arrivals)
                : try ops.createReading(name: name, kind: .gathering, querySpec: rule)
            if kind == .book {
                let member = try ops.createPost(title: "a member")
                _ = try ops.newBlock(in: member.id, text: "A member's prose, a sentence long.")
                try ops.addPostToReading(member.id, to: reading.id)
            }
            for w in 0..<waiting {
                let post = try ops.createPost(title: "waiting \(w)")
                _ = try ops.newBlock(in: post.id, text: "Waiting note \(w), at the door.")
                _ = try ops.applyTag(inbox.id, toPost: post.id)
            }
            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            })
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
            structure.mode = mode
            let arrivals = BookArrivalsModel(session: session, readingID: reading.id)
            let limit = arrivals.listingLimit
            arrivals.adopt(try await db.read { [id = reading.id] in
                try Queries.bookArrivals($0, readingID: id, limit: limit)
            })
            let search = BookSearchModel(session: session, readingID: reading.id)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            return try await body(
                Mounted(session: session, readingID: reading.id, model: model, structure: structure,
                        arrivals: arrivals, search: search),
                theme)
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    /// Mount the book in a window and pump until its columns have reported.
    private func mount(_ book: Mounted, _ theme: ThemeStore) async -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1_200, height: 800),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: book.session, readingID: book.readingID,
                model: book.model, structure: book.structure, arrivals: book.arrivals,
                bookSearch: book.search)
                .environment(theme))
        hosting.frame = NSRect(x: 0, y: 0, width: 1_200, height: 800)
        window.contentView = hosting
        window.orderFrontRegardless()
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(30))
        }
        return window
    }

    /// The two remembered column widths, put back as found (the test host is
    /// the dev-store app — its defaults are real). VX-1091: the navigator's
    /// remembered 190 sits under both voices' floors, and the column holds a
    /// remembered width up to its floor (`SideColumnLayout.width`), so the
    /// navigator lays out AT its floor in the voice the book draws.
    private func withColumnsAtTheirFloors<T>(_ body: () async throws -> T) async rethrows -> T {
        let defaults = UserDefaults.standard
        let navigator = defaults.object(forKey: BookNavigatorLayout.widthKey)
        let index = defaults.object(forKey: BookIndexColumn.widthKey)
        defer {
            if let navigator { defaults.set(navigator, forKey: BookNavigatorLayout.widthKey) }
            else { defaults.removeObject(forKey: BookNavigatorLayout.widthKey) }
            if let index { defaults.set(index, forKey: BookIndexColumn.widthKey) }
            else { defaults.removeObject(forKey: BookIndexColumn.widthKey) }
        }
        defaults.set(Double(BookNavigatorLayout.minimumWidth), forKey: BookNavigatorLayout.widthKey)
        defaults.set(Double(BookIndexColumn.minimumWidth), forKey: BookIndexColumn.widthKey)
        return try await body()
    }

    /// The navigator as it laid out, against its panel width.
    /// **The ORACLE (D-1082-S3): the masthead TITLE LINE's own laid-out
    /// width** (`BookOutlineGeometry.mastheadTitleLines`, DEBUG) — the line
    /// this fix owns, read directly. The first cut read the whole column's
    /// width, which any other child can move: the window's green pass (00:41)
    /// caught a 1-pt Terminal overflow from another navigator element at REST
    /// (the record's LIVE STATUS rows 7–8), so the pins now test what they
    /// claim.
    private func titleLineWidth(_ readingID: String) -> CGFloat? {
        #if DEBUG
        BookOutlineGeometry.mastheadTitleLines[readingID]
        #else
        nil
        #endif
    }

    /// The room the Index column gives its masthead line: the column's floor
    /// less the masthead's `.padding(.horizontal, 14)` (`BookIndexView.column`).
    static let indexRoom: CGFloat = BookIndexColumn.minimumWidth - 28

    /// The room the navigator gives its masthead line, IN THE VOICE THE BOOK
    /// DREW: the navigator's floor less its `.padding(12)` each side
    /// (`BookView.navigator`, `BookNavigatorLayout.contentInset`).
    ///
    /// VX-1091 (the VX-1036 run — A JUSTIFIED EDIT): this was
    /// `BookNavigatorLayout.minimumWidth - 24` (the old single 190-pt floor,
    /// 166) and the pins took `max` of it and the mode row's placed tabs —
    /// **the room the column's OTHER children leave the title line** (D-1082-S3's
    /// measured read: a stack places every child at its widest child's width,
    /// so where the tabs outgrew the room — Terminal, 167 pt in 166 — the title
    /// line filled that point too; "When VX-1091 is fixed the max collapses to
    /// the panel's room"). VX-1091 is fixed by the floor itself: it holds the
    /// tabs' stable width plus the padding, so the tabs fit the room by
    /// construction (`BookNavigatorFloorTests`) and the `max` is the room. The
    /// floor is read from the input `BookView` hands `SideColumn` — the mode
    /// row's own probe's STABLE tab width (`OutlineRoomTests`' precedent) —
    /// never from the navigator's laid-out width, which would let a widened
    /// navigator widen its own oracle. A child that outgrows the room now
    /// fails here, as the claim wants.
    private func navigatorRoom(_ readingID: String) throws -> CGFloat {
        #if DEBUG
        let tabs = try #require(BookMastheadProbe.placed[readingID]?.tabsWidth,
                                "the mode row reported the tabs it counted")
        return BookNavigatorLayout.minimumWidth(tabs: tabs) - 2 * BookNavigatorLayout.contentInset
        #else
        return BookNavigatorLayout.minimumWidth - 2 * BookNavigatorLayout.contentInset
        #endif
    }

    // MARK: - The navigator at its floor in the voice (VX-1091: 229 Terminal, 203 Study)

    /// Her sighting's shape — a short-named GATHERING — and her own book's
    /// name, nothing waiting; and a book whose Arrivals door shows a count.
    /// The field OPEN: the title line is no wider than the room its column
    /// gives it. RED on the pre-fix tree (the HStack drew 190–220 pt in a
    /// 166-pt room).
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theOpenFieldNeverWidensTheNavigator(voice: ThemeVoice) async throws {
        #if DEBUG
        let cases: [(name: String, kind: ReadingKind, waiting: Int)] = [
            ("Poems", .gathering, 0),
            ("Video ideas", .book, 0),
            ("Video ideas", .book, 12),
        ]
        for (name, kind, waiting) in cases {
            try await withColumnsAtTheirFloors {
                try await withMasthead(name: name, kind: kind, waiting: waiting, voice: voice) { book, theme in
                    BookOutlineGeometry.resetNavigator()
                    book.search.open()
                    let window = await mount(book, theme)
                    defer { window.orderOut(nil); window.close() }
                    let width = try #require(titleLineWidth(book.readingID), "\(voice) \(name): the title line reported")
                    let room = try navigatorRoom(book.readingID)
                    #expect(width <= room + 0.5,
                            "\(voice) \(name) (\(kind), \(waiting) waiting): the open title line drew \(width) pt in a \(room)-pt room")
                }
            }
        }
        #endif
    }

    /// GUARD (green on both trees): the field at REST — the bare 🔍 — the
    /// title line fits its room, the Arrivals count shown or not.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theRestingGlyphNeverWidensTheNavigator(voice: ThemeVoice) async throws {
        #if DEBUG
        for (name, waiting) in [("Poems", 0), ("Video ideas", 12)] {
            try await withColumnsAtTheirFloors {
                try await withMasthead(name: name, kind: .book, waiting: waiting, voice: voice) { book, theme in
                    BookOutlineGeometry.resetNavigator()
                    let window = await mount(book, theme)
                    defer { window.orderOut(nil); window.close() }
                    let width = try #require(titleLineWidth(book.readingID), "\(voice) \(name): the title line reported")
                    let room = try navigatorRoom(book.readingID)
                    #expect(width <= room + 0.5,
                            "\(voice) \(name): the resting title line drew \(width) pt in a \(room)-pt room")
                    // D-1082-S3's ONE measured read (printed, never asserted —
                    // the 1-pt Terminal overflow is ANOTHER element's, named
                    // headless as the mode row's tabs and ticketed): the mode
                    // row's own placement at this floor, beside the navigator
                    // and the title line, for the record.
                    if let placed = BookMastheadProbe.placed[book.readingID] {
                        print("D-1082-S3 MEASURED READ \(voice) \(name): room \(room) · "
                              + "mode row bounds \(placed.boundsWidth) · tabs \(placed.arrangement.tabs.width) "
                              + "(stable \(placed.tabsWidth)) · navigator \(BookOutlineGeometry.navigatorFrames[book.readingID]?.width ?? -1) "
                              + "· title line \(width)")
                    }
                }
            }
        }
        #endif
    }

    // MARK: - The Index column at its 240-pt floor (the same masthead)

    /// The Index column carries the same masthead (wave 2c): the field OPEN on
    /// a book whose Arrivals door shows a count, the column at its floor —
    /// the title line within the column's room. RED on the pre-fix tree.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theOpenFieldNeverWidensTheIndexColumn(voice: ThemeVoice) async throws {
        #if DEBUG
        try await withColumnsAtTheirFloors {
            try await withMasthead(name: "Video ideas", kind: .book, waiting: 12, voice: voice, mode: .index) { book, theme in
                BookIndexGeometry.reset()
                BookOutlineGeometry.resetNavigator()
                book.search.open()
                let window = await mount(book, theme)
                defer { window.orderOut(nil); window.close() }
                let width = try #require(titleLineWidth(book.readingID), "\(voice): the Index column's title line reported")
                // VX-1091 (A JUSTIFIED EDIT): the tabs' `max` collapses here
                // too — five tabs (205 / 179 pt) sit inside the column's
                // 212-pt room in both voices; the room is the column's own.
                let room = Self.indexRoom
                #expect(width <= room + 0.5,
                        "\(voice): the open title line drew \(width) pt in the Index column's \(room)-pt room")
            }
        }
        #endif
    }
}
