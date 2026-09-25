//
//  DebugOracleTwoWindowTests.swift
//  VariorumTests
//
//  18k UNIT C4 — **the DEBUG oracles' ownership, in real pairs of windows.**
//
//  The defect (the post-13u health review §5.2, re-traced at C4): a DEBUG
//  oracle is a process-global slot a mounted surface writes and a pin reads.
//  Keyed by its SUBJECT, or not keyed at all, it has no record of WHO wrote
//  it — so with two windows standing, one window's teardown either CLEARS
//  the other's registration (the cross-clear arm: the survivor reads nil)
//  or leaves its OWN value standing as the answer while the window that is
//  still on screen says something else (the stale arm). Either way a pin
//  over the oracle is green or red because of the ORDER two mounts came and
//  went, not because of what is on screen. 13u4 UNIT S2/S3 fixed three sites
//  of this shape and stated the fix in one line: **the registrant names
//  itself, and a teardown clears only what it still owns.** C4 applies it to
//  the rest.
//
//  Every pin here has the same form, because the defect has one form: mount
//  the same kind of surface in TWO windows whose registrations DIFFER (a
//  different window size, a different note), tear one down, and assert the
//  oracle answers for the window still standing. The pins read the oracles
//  through the names the tree already had, so each one compiles on the
//  pre-fix tree and was RUN THERE FIRST — the red numbers are in the C4
//  record (`notes/plans/phase-18k-runtime-hygiene.md`, UNIT C4 RECORD).
//
//  What these pins do NOT claim: two LIVE windows in two different tests
//  (parallel suites) on one unscoped slot still answer from the newest
//  registrant, which can be the other test's. That is the 13u2 UNIT E
//  scoping axis (KnownIssues row 50's), not this one; the three reference
//  fixes share the same residual. The suite is `.serialized` and mints live
//  uuids so it does not lean on that axis itself.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG
@MainActor
@Suite("The DEBUG oracles answer for the window still open (18k UNIT C4)", .serialized)
struct DebugOracleTwoWindowTests {

    // MARK: - The two-window rig

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// A real window, hosting `view` at exactly `size`.
    private func mount<V: View>(_ view: V, width: CGFloat, height: CGFloat, x: CGFloat = 60)
        -> (window: NSWindow, hosting: NSView)
    {
        let window = NSWindow(
            contentRect: NSRect(x: x, y: 60, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<6 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return (window, hosting)
    }

    /// A window going away the way a closed window does: its content torn
    /// down first (so SwiftUI runs the departing views' `onDisappear`), then
    /// the window itself. Idempotent, so a `defer` may repeat it.
    private func close(_ window: NSWindow) {
        guard window.contentView != nil || window.isVisible else { return }
        window.contentView = nil
        window.orderOut(nil)
        window.close()
    }

    @discardableResult
    private func settle(
        _ mounts: [(window: NSWindow, hosting: NSView)],
        until predicate: () -> Bool, maxTurns: Int = 120
    ) async -> Bool {
        for _ in 0..<maxTurns {
            for mount in mounts where mount.window.contentView != nil {
                mount.hosting.layoutSubtreeIfNeeded()
                mount.window.layoutIfNeeded()
                mount.window.displayIfNeeded()
            }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
            if predicate() { return true }
        }
        return predicate()
    }

    /// A few turns with no predicate — the settle a teardown gets before the
    /// survivor is asked anything (long enough for any `onDisappear` to run).
    private func idle(_ mounts: [(window: NSWindow, hosting: NSView)], turns: Int = 12) async {
        await settle(mounts, until: { false }, maxTurns: turns)
    }

    private func withLiveWorld<T>(
        _ db: AppDatabase, seed: UInt64,
        _ body: @MainActor () async throws -> T
    ) async throws -> T {
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            // LIVE uuids: every keyed oracle row here is keyed by an id no
            // other suite can mint.
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            try await body()
        }
    }

    // MARK: - PostDetailOracle's four unkeyed singletons

    /// **`PostDetailOracle.inspectorPanel` / `.titleShown` /
    /// `.beginTitleEditing` / `.sideColumnDividerFrame`** — four bare
    /// statics every mounted detail overwrote, and the title door was never
    /// cleared by anyone. Window one (note α, no panel) stays; window two
    /// (note β, its tray open) goes. Asked afterwards, every one of the four
    /// must be window one's.
    ///
    /// RED ON OLD (measured — the C4 record): the title still says β, the
    /// panel is still β's tray, β's divider still stands, and the title door
    /// drives β's title — a view that no longer exists — so α never opens.
    @Test func thePostDetailsSingletonsAnswerForTheWindowStillOpen() async throws {
        // ONE store, TWO sessions: two session objects are two probe scopes
        // and two command routers (so each window's masthead and tray are
        // its own), while every SwiftUI body resolves the one `database`
        // dependency the world installs.
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 41) {
            let s1 = AppSession(database: db)
            let s2 = AppSession(database: db)
            let alpha = try s1.operations.createPost(title: "alpha, the window that stays")
            _ = try s1.operations.newBlock(in: alpha.id, text: "a block, so the mode can host.")
            let beta = try s2.operations.createPost(title: "beta, the window that goes")
            _ = try s2.operations.newBlock(in: beta.id, text: "a block, so the mode can host.")
            for post in [alpha.id, beta.id] {
                UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post)")
            }
            defer {
                for post in [alpha.id, beta.id] {
                    UserDefaults.standard.removeObject(forKey: "postMode.\(post)")
                }
            }
            let oneMasthead = MastheadGeometry.reader(s1.debugProbeScope)
            oneMasthead.resetTitleRow()

            let one = mount(
                PostDetailView(session: s1, postID: alpha.id)
                    .environment(ThemeStore(session: s1)),
                width: 1100, height: 750)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                PostDetailOracle.titleShown == alpha.title
                    && PostDetailOracle.beginTitleEditing != nil
            }), "window one's title reported")
            #expect(PostDetailOracle.inspectorPanel == nil, "window one holds no panel")

            let two = mount(
                PostDetailView(session: s2, postID: beta.id)
                    .environment(ThemeStore(session: s2)),
                width: 900, height: 560, x: 260)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                PostDetailOracle.titleShown == beta.title
                    && s2.commandRouter.activePostID == beta.id
            }), "window two's title reported")
            #expect(s2.commandRouter.requestNoteTray(TrayRequest(postID: beta.id)),
                    "window two's tray opened through its own router")
            #expect(await settle([one, two], until: {
                PostDetailOracle.inspectorPanel?.isTray == true
                    && PostDetailOracle.sideColumnDividerFrame != nil
            }), "window two's panel and divider reported")

            // Window two goes.
            close(two.window)
            await idle([one])

            #expect(PostDetailOracle.titleShown == alpha.title,
                    "the title is the open window's: \(PostDetailOracle.titleShown ?? "nil")")
            #expect(PostDetailOracle.inspectorPanel == nil,
                    "the open window holds no panel: \(String(describing: PostDetailOracle.inspectorPanel))")
            #expect(PostDetailOracle.sideColumnDividerFrame == nil,
                    "no divider stands in the open window: \(String(describing: PostDetailOracle.sideColumnDividerFrame))")

            // The title door opens the title that is ON SCREEN.
            #expect(oneMasthead.titleOpenMarkAppearances == 0, "window one's title rests")
            PostDetailOracle.beginTitleEditing?()
            #expect(await settle([one], until: { oneMasthead.titleOpenMarkAppearances > 0 },
                                 maxTurns: 60),
                    "the door opened window one's title, not a closed window's")
        }
    }

    // MARK: - BookOutlineGeometry — the focus door and the navigator

    /// The book's world, seeded by hand (the `BookRedesignMountTests`
    /// pattern): a curated book with two notes and one chapter.
    private func book(_ session: AppSession) throws -> (readingID: String, postIDs: [String]) {
        let reading = try session.operations.createReading(name: "a book in two windows", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<2 {
            let post = try session.operations.createPost(title: "note \(p)")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "Prose of note \(p), long enough to read like real writing "
                    + "and to give the surface something to lay out.")
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        let chapter = try session.operations.createSection(in: reading.id, name: "one")
        try session.operations.assignPostToSection(postIDs[0], in: reading.id, section: chapter.id)
        return (reading.id, postIDs)
    }

    private func loadedBook(
        session: AppSession, db: AppDatabase, readingID: String, mode: BookStructureModel.ViewMode
    ) async throws -> (BookViewModel, BookStructureModel) {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        structure.mode = mode
        return (model, structure)
    }

    /// **`BookOutlineGeometry.focusDoors` — the review's clearest instance —
    /// and the navigator's frame beside it.** The same book in two windows:
    /// each `BookView` publishes its ONE focus act under the book's id, and
    /// its `onDisappear` cleared that id — so whichever window left took the
    /// other's door with it, and the door itself captured a `@State` model.
    ///
    /// Phase 1 closes the NEWER window (the stale arm for the frames, the
    /// cross-clear arm for the door); phase 2 mounts a third and closes the
    /// OLDER, so the door must survive a teardown from either side.
    ///
    /// RED ON OLD (measured — the C4 record): after either teardown the door
    /// is nil with a book still on screen, and the navigator and its seam
    /// still answer with the closed window's rectangles.
    @Test func aBookInTwoWindowsKeepsTheOpenWindowsDoorAndNavigator() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 42) {
            let session = AppSession(database: db)
            let (readingID, postIDs) = try book(session)
            let seam = SeamGeometry.key(BookNavigatorLayout.widthKey, subject: readingID)
            let (m1, st1) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let one = mount(
                BookView(session: session, readingID: readingID, model: m1, structure: st1)
                    .environment(ThemeStore(session: session)),
                width: 1200, height: 900)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                BookOutlineGeometry.focusDoors[readingID] != nil
                    && BookOutlineGeometry.navigatorFrames[readingID] != nil
                    && SeamGeometry.lineFrames[seam] != nil
            }), "window one's book published its door, navigator and seam")
            await idle([one])
            let navigatorOne = try #require(BookOutlineGeometry.navigatorFrames[readingID])
            let seamOne = try #require(SeamGeometry.lineFrames[seam])

            // PHASE 1 — a second window on the SAME book, shorter, then gone.
            let (m2, st2) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let two = mount(
                BookView(session: session, readingID: readingID, model: m2, structure: st2)
                    .environment(ThemeStore(session: session)),
                width: 1000, height: 600, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                BookOutlineGeometry.navigatorFrames[readingID] != navigatorOne
                    && SeamGeometry.lineFrames[seam] != seamOne
            }), "window two drew its own navigator and seam — the two windows differ")
            close(two.window)
            await idle([one])

            #expect(BookOutlineGeometry.navigatorFrames[readingID] == navigatorOne,
                    "the navigator is the open window's: \(String(describing: BookOutlineGeometry.navigatorFrames[readingID])) vs \(navigatorOne)")
            #expect(SeamGeometry.lineFrames[seam] == seamOne,
                    "the navigator's seam is the open window's: \(String(describing: SeamGeometry.lineFrames[seam])) vs \(seamOne)")
            let door = BookOutlineGeometry.focusDoors[readingID]
            #expect(door != nil, "a book is on screen, so its focus door stands")
            door?(postIDs[1])
            #expect(m1.focusedPostID == postIDs[1], "…and it focuses the OPEN window's book")
            #expect(m2.focusedPostID == nil, "…never the closed window's")

            // PHASE 2 — a third window, then the OLDER one goes.
            let (m3, st3) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let three = mount(
                BookView(session: session, readingID: readingID, model: m3, structure: st3)
                    .environment(ThemeStore(session: session)),
                width: 1100, height: 700, x: 200)
            defer { close(three.window) }
            #expect(await settle([one, three], until: {
                BookOutlineGeometry.navigatorFrames[readingID] != navigatorOne
            }), "window three drew")
            close(one.window)
            await idle([three])
            let survivor = BookOutlineGeometry.focusDoors[readingID]
            #expect(survivor != nil, "the older window's teardown left the newer window's door")
            survivor?(postIDs[0])
            #expect(m3.focusedPostID == postIDs[0], "…and it is window three's")
        }
    }

    // MARK: - CommitBarGeometry — the bar's row and width

    /// **`CommitBarGeometry.rowFrame` / `.barWidth`** — two unkeyed frames
    /// every mounted bar overwrote and nothing cleared. A wide bar stays; a
    /// narrow one (which folds to its compact row) goes.
    ///
    /// RED ON OLD (measured — the C4 record): the width and the row are the
    /// closed narrow bar's. The `mounted` refcount beside them is the
    /// SAFE-AS-IS control: +1 on appear, −1 on disappear, so it already
    /// answers for what is on screen on both trees.
    @Test func theBarsGeometryIsTheOpenBarsAfterTheOtherCloses() async throws {
        try await withEditor(seedBlocks: ["A block to stand in.", "And a second one."]) { h in
            try h.reload()
            CommitBarGeometry.reset()
            let one = mount(
                CommitBar(model: h.model).environment(ThemeStore(session: h.model.session)),
                width: 900, height: 200)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                abs((CommitBarGeometry.barWidth ?? 0) - 900) < 0.5 && CommitBarGeometry.rowFrame != nil
            }), "bar one measured")
            await idle([one])
            let rowOne = try #require(CommitBarGeometry.rowFrame)
            let mountedOne = CommitBarGeometry.mounted(
                CommitBar.name(of: .horizontal), post: h.model.postID)

            let two = mount(
                CommitBar(model: h.model).environment(ThemeStore(session: h.model.session)),
                width: 420, height: 200, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                abs((CommitBarGeometry.barWidth ?? 0) - 420) < 0.5
                    && CommitBarGeometry.rowFrame != rowOne
            }), "bar two measured, and its row differs")
            close(two.window)
            await idle([one])

            #expect(abs((CommitBarGeometry.barWidth ?? 0) - 900) < 0.5,
                    "the width is the open bar's: \(String(describing: CommitBarGeometry.barWidth))")
            #expect(CommitBarGeometry.rowFrame == rowOne,
                    "the row is the open bar's: \(String(describing: CommitBarGeometry.rowFrame)) vs \(rowOne)")
            // The control (SAFE-AS-IS (A), a refcount): unchanged by the fix.
            #expect(CommitBarGeometry.mounted(CommitBar.name(of: .horizontal), post: h.model.postID)
                        == mountedOne,
                    "the mount count is back to what one bar makes")
        }
    }

    // MARK: - ReadModeOracle — the Read host's face, selection and frames

    /// A Read host over `postID`, the way `ReadModeTests` mounts one: its
    /// detail registered (the fact reports need an active post), its own
    /// model, and a scrubbed `@AppStorage` so a walk's toggles cannot move
    /// the index column this pin reads.
    private func readHost(
        _ session: AppSession, _ postID: String, storage: UserDefaults
    ) -> some View {
        _ = session.commandRouter.registerDetail(postID: postID, mode: .read) { _ in }
        return ReadModeView(
            session: session, postID: postID,
            model: BlockTOCViewModel(session: session, postID: postID))
            .environment(ThemeStore(session: session))
            .defaultAppStorage(storage)
    }

    private func scrubbedStorage(_ name: String) throws -> UserDefaults {
        let suite = "18k-c4-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func note(
        _ session: AppSession, _ title: String, blocks: Int = 3
    ) throws -> (postID: String, blockIDs: [String]) {
        let post = try session.operations.createPost(title: title)
        var ids: [String] = []
        for b in 0..<blocks {
            ids.append(try session.operations.newBlock(
                in: post.id,
                text: "Block \(b) of \(title) — a sentence of prose, long enough that a "
                    + "narrow window wraps it where a wide one does not.").block.id)
        }
        return (post.id, ids)
    }

    /// **`ReadModeOracle.face` / `.selectedBlockID`** — the Read host's
    /// unkeyed singletons. Window one reads note α on its `read` face; window
    /// two opens note β on `edit`, and goes.
    ///
    /// RED ON OLD (measured — the C4 record): the face is β's `edit` and the
    /// selection is β's block, with only α on screen.
    @Test func theReadHostsFaceAndSelectionAreTheOpenWindows() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 43) {
            let s1 = AppSession(database: db)
            let s2 = AppSession(database: db)
            let alpha = try note(s1, "alpha")
            let beta = try note(s2, "beta")
            ReadModeView.remember(.read, postID: alpha.postID)
            ReadModeView.remember(.edit, postID: beta.postID)
            let storage = try scrubbedStorage("read-faces")
            defer {
                for (s, n) in [(s1, alpha.postID), (s2, beta.postID)] {
                    UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(n))
                    s.commandRouter.forgetCurrentBlock(for: n)
                }
            }
            ReadModeOracle.reset()
            let one = mount(readHost(s1, alpha.postID, storage: storage), width: 1100, height: 750)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                ReadModeOracle.face == .read && ReadModeOracle.selectedBlockID == alpha.blockIDs[0]
            }), "window one reports its read face on α")

            let two = mount(readHost(s2, beta.postID, storage: storage), width: 900, height: 560, x: 260)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                ReadModeOracle.face == .edit && ReadModeOracle.selectedBlockID == beta.blockIDs[0]
            }), "window two reports its edit face on β")
            close(two.window)
            await idle([one])

            #expect(ReadModeOracle.face == .read,
                    "the face is the open window's: \(String(describing: ReadModeOracle.face))")
            #expect(ReadModeOracle.selectedBlockID == alpha.blockIDs[0],
                    "the selection is the open window's block")
        }
    }

    /// **`ReadModeOracle.faceFrames` / `.indexColumnFrames` /
    /// `.editBlockFrames` / `.firstEditRowPaintedAt`, and the index column's
    /// `SeamGeometry` row** — keyed by note or block, so the SAME note open
    /// twice shares every key. A tall window stays; a short one goes.
    ///
    /// RED ON OLD (measured — the C4 record): every one of them answers with
    /// the short window's rectangle (or its later first-paint time).
    @Test func oneNoteReadInTwoWindowsKeepsTheOpenWindowsFrames() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 44) {
            let session = AppSession(database: db)
            let theNote = try note(session, "one note, two windows")
            ReadModeView.remember(.edit, postID: theNote.postID)
            let storage = try scrubbedStorage("read-frames")
            defer {
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(theNote.postID))
                session.commandRouter.forgetCurrentBlock(for: theNote.postID)
            }
            let post = theNote.postID
            let block = theNote.blockIDs[0]
            let seam = SeamGeometry.key(ReadModeView.indexColumnWidthKey, subject: post)
            ReadModeOracle.reset()
            let one = mount(readHost(session, post, storage: storage), width: 1100, height: 750)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                ReadModeOracle.faceFrames[post] != nil
                    && ReadModeOracle.indexColumnFrames[post] != nil
                    && ReadModeOracle.editBlockFrames[block] != nil
                    && SeamGeometry.lineFrames[seam] != nil
            }), "window one reported its face, column, first row and seam")
            await idle([one])
            let faceOne = try #require(ReadModeOracle.faceFrames[post])
            let columnOne = try #require(ReadModeOracle.indexColumnFrames[post])
            let rowOne = try #require(ReadModeOracle.editBlockFrames[block])
            let seamOne = try #require(SeamGeometry.lineFrames[seam])
            let paintedOne = try #require(ReadModeOracle.firstEditRowPaintedAt)

            let two = mount(readHost(session, post, storage: storage), width: 820, height: 520, x: 280)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                ReadModeOracle.faceFrames[post] != faceOne
                    && ReadModeOracle.indexColumnFrames[post] != columnOne
                    && ReadModeOracle.editBlockFrames[block] != rowOne
                    && SeamGeometry.lineFrames[seam] != seamOne
            }), "window two drew every one of them differently")
            close(two.window)
            await idle([one])

            #expect(ReadModeOracle.faceFrames[post] == faceOne, "the face frame is the open window's")
            #expect(ReadModeOracle.indexColumnFrames[post] == columnOne, "the index column is the open window's")
            #expect(ReadModeOracle.editBlockFrames[block] == rowOne, "the row is the open window's")
            #expect(SeamGeometry.lineFrames[seam] == seamOne, "the column's seam is the open window's")
            #expect(ReadModeOracle.firstEditRowPaintedAt == paintedOne,
                    "the first paint is the open window's arrival")
        }
    }

    // MARK: - BookIndexGeometry — the book Index's column and panes

    /// **`BookIndexGeometry.columnFrames` / `.paneNoteHeights`** — the Index's
    /// chapter panel keyed by the book, its note panes keyed by the note.
    /// The same book in Index in a wide window (stays) and a narrow, short
    /// one (goes): the panel is shorter there and every pane wraps taller.
    ///
    /// RED ON OLD (measured — the C4 record): both answer with the closed
    /// window's numbers.
    @Test func aBookIndexInTwoWindowsKeepsTheOpenWindowsColumnAndPanes() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 45) {
            let session = AppSession(database: db)
            let (readingID, postIDs) = try book(session)
            let (m1, st1) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .index)
            let one = mount(
                BookView(session: session, readingID: readingID, model: m1, structure: st1)
                    .environment(ThemeStore(session: session)),
                width: 1400, height: 900)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                BookIndexGeometry.columnFrames[readingID] != nil
                    && BookIndexGeometry.paneNoteHeights[postIDs[0]] != nil
            }), "window one's Index reported its column and a pane")
            await idle([one])
            let columnOne = try #require(BookIndexGeometry.columnFrames[readingID])
            let paneOne = try #require(BookIndexGeometry.paneNoteHeights[postIDs[0]])

            let (m2, st2) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .index)
            let two = mount(
                BookView(session: session, readingID: readingID, model: m2, structure: st2)
                    .environment(ThemeStore(session: session)),
                width: 700, height: 560, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                BookIndexGeometry.columnFrames[readingID] != columnOne
                    && BookIndexGeometry.paneNoteHeights[postIDs[0]] != paneOne
            }), "window two drew a different column and a differently-wrapped pane")
            close(two.window)
            await idle([one])

            #expect(BookIndexGeometry.columnFrames[readingID] == columnOne,
                    "the column is the open window's: \(String(describing: BookIndexGeometry.columnFrames[readingID])) vs \(columnOne)")
            #expect(BookIndexGeometry.paneNoteHeights[postIDs[0]] == paneOne,
                    "the pane is the open window's: \(String(describing: BookIndexGeometry.paneNoteHeights[postIDs[0]])) vs \(paneOne)")
        }
    }

    // MARK: - LibraryPanelOracle — the catalog and its panel

    /// **`LibraryPanelOracle.rootFrame` / `.dividerFrame` / `.panelFrame`** —
    /// the catalog's unkeyed frames. Two catalogs with the panel standing, a
    /// tall window (stays) and a short one (goes). (Its per-row map,
    /// `noteRowFrames`, is converted with the oracle but cannot be separated
    /// here — the catalog lays out at its own minimum width in both windows,
    /// so the two rows are the same rectangle; measured, the C4 record. It
    /// rests on the structural arm, `DebugOracleOwnershipTests`.)
    ///
    /// RED ON OLD (measured — the C4 record): all three are the short
    /// window's.
    @Test func theLibraryCatalogInTwoWindowsKeepsTheOpenWindowsFrames() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 46) {
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the preview")
            _ = try session.operations.newBlock(in: post.id, text: "The first block's own words.")
            _ = try session.operations.newBlock(in: post.id, text: "The second block.")
            let firstModel = LibraryCatalogModel(session: session)
            await firstModel.search()
            firstModel.clickNoteRow(post.id, modifiers: .none)
            let secondModel = LibraryCatalogModel(session: session)
            await secondModel.search()
            secondModel.clickNoteRow(post.id, modifiers: .none)
            @MainActor func host(_ model: LibraryCatalogModel) -> some View {
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                    .environment(ThemeStore(session: session))
            }
            LibraryPanelOracle.reset()
            let one = mount(host(firstModel), width: 1100, height: 700)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                LibraryPanelOracle.rootFrame != nil && LibraryPanelOracle.dividerFrame != nil
                    && LibraryPanelOracle.panelFrame != nil
            }), "catalog one reported its room, divider and panel")
            await idle([one])
            let rootOne = try #require(LibraryPanelOracle.rootFrame)
            let dividerOne = try #require(LibraryPanelOracle.dividerFrame)
            let panelOne = try #require(LibraryPanelOracle.panelFrame)

            let two = mount(host(secondModel), width: 860, height: 520, x: 280)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                LibraryPanelOracle.rootFrame != rootOne && LibraryPanelOracle.dividerFrame != dividerOne
                    && LibraryPanelOracle.panelFrame != panelOne
            }), "catalog two drew every one of them differently")
            close(two.window)
            await idle([one])

            #expect(LibraryPanelOracle.rootFrame == rootOne, "the room is the open window's")
            #expect(LibraryPanelOracle.dividerFrame == dividerOne, "the divider is the open window's")
            #expect(LibraryPanelOracle.panelFrame == panelOne, "the panel is the open window's")
        }
    }

    // MARK: - CanvasArrivalOracle — the arrival's viewport

    /// **`CanvasArrivalOracle.viewport`** — the viewport the arrival read,
    /// an unkeyed singleton. The same note's canvas in a large window
    /// (stays) and a small one (goes).
    ///
    /// RED ON OLD (measured — the C4 record): the viewport is the small
    /// window's.
    @Test func aCanvasInTwoWindowsKeepsTheOpenWindowsArrival() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 47) {
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a spread of cards")
            for i in 1...12 {
                _ = try session.operations.newBlock(in: post.id, text: "Card \(i) of a canvas.")
            }
            @MainActor func host() async throws -> (some View, CanvasViewModel) {
                let model = CanvasViewModel(session: session, containerID: post.id)
                model.adopt(try await db.read { try Queries.canvasProjection($0, container: post.id) })
                return (CanvasView(session: session, containerID: post.id, model: model)
                    .environment(ThemeStore(session: session)), model)
            }
            CanvasArrivalOracle.reset()
            let (viewOne, modelOne) = try await host()
            defer { modelOne.teardown() }
            let one = mount(viewOne, width: 1300, height: 860)
            defer { close(one.window) }
            #expect(await settle([one], until: { CanvasArrivalOracle.viewport != nil }),
                    "canvas one arrived")
            await idle([one])
            let viewportOne = try #require(CanvasArrivalOracle.viewport)

            let (viewTwo, modelTwo) = try await host()
            defer { modelTwo.teardown() }
            let two = mount(viewTwo, width: 760, height: 520, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                CanvasArrivalOracle.viewport != nil && CanvasArrivalOracle.viewport != viewportOne
            }), "canvas two arrived in a different viewport")
            close(two.window)
            await idle([one])

            #expect(CanvasArrivalOracle.viewport == viewportOne,
                    "the arrival is the open window's: \(String(describing: CanvasArrivalOracle.viewport)) vs \(viewportOne)")
        }
    }

    // MARK: - TakesArticleDoorProbe — the article's ＋ new block door

    /// **`TakesArticleDoorProbe.frame`** — an unkeyed frame in WINDOW space.
    /// The same note's Takes board in a wide window (stays) and a narrow one
    /// (goes): the article's door stands at a different x in each.
    ///
    /// RED ON OLD (measured — the C4 record): the frame is the narrow
    /// window's.
    @Test func theTakesArticleDoorIsTheOpenWindows() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 48) {
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note in Takes")
            _ = try session.operations.newBlock(in: post.id, text: "Paragraph one.")
            _ = try session.operations.newBlock(in: post.id, text: "Paragraph two is a line.")
            let storage = try scrubbedStorage("takes")
            @MainActor func host() async throws -> (some View, TakesViewModel) {
                let model = TakesViewModel(session: session, postID: post.id, defaults: storage)
                model.landingEnabled = true
                model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
                return (TakesBoardView(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session)), model)
            }
            TakesArticleDoorProbe.reset()
            let (viewOne, modelOne) = try await host()
            defer { modelOne.teardown() }
            let one = mount(viewOne, width: 1300, height: 760)
            defer { close(one.window) }
            #expect(await settle([one], until: { TakesArticleDoorProbe.frame != nil }),
                    "board one's door reported")
            await idle([one])
            let doorOne = try #require(TakesArticleDoorProbe.frame)

            let (viewTwo, modelTwo) = try await host()
            defer { modelTwo.teardown() }
            let two = mount(viewTwo, width: 760, height: 560, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                TakesArticleDoorProbe.frame != nil && TakesArticleDoorProbe.frame != doorOne
            }), "board two's door stands elsewhere")
            close(two.window)
            await idle([one])

            #expect(TakesArticleDoorProbe.frame == doorOne,
                    "the door is the open window's: \(String(describing: TakesArticleDoorProbe.frame)) vs \(doorOne)")
        }
    }

    // MARK: - ReadingFlowGeometry — the flow's row tops

    /// **`ReadingFlowGeometry.anchorTops`** — keyed by the story's note, so
    /// the same book's flow in two windows shares every key. A wide window
    /// (stays) and a narrow one (goes): the narrow column wraps the first
    /// story taller, so the SECOND story's top differs.
    ///
    /// RED ON OLD (measured — the C4 record): the top is the narrow
    /// window's.
    @Test func aReadingFlowInTwoWindowsKeepsTheOpenWindowsRowTops() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 49) {
            let session = AppSession(database: db)
            var entries: [Queries.ReadingEntry] = []
            for p in 0..<3 {
                let story = try note(session, "story \(p)", blocks: 4)
                entries.append(Queries.ReadingEntry(
                    postID: story.postID, title: "story \(p)", entryDate: nil, sectionPath: nil))
            }
            let second = entries[1].postID
            @MainActor func host() -> some View {
                ReadingFlowView(
                    session: session, readingName: "the flow",
                    grouped: [(nil, entries)],
                    onWake: { _, _ in },
                    reveal: nil,
                    onRevealLanded: {})
                    .environment(ThemeStore(session: session))
            }
            let one = mount(host(), width: 1100, height: 900)
            defer { close(one.window) }
            #expect(await settle([one], until: { ReadingFlowGeometry.anchorTops[second] != nil }),
                    "flow one reported the second story's top")
            await idle([one], turns: 20)
            let topOne = try #require(ReadingFlowGeometry.anchorTops[second])

            let two = mount(host(), width: 520, height: 900, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                ReadingFlowGeometry.anchorTops[second] != nil
                    && ReadingFlowGeometry.anchorTops[second] != topOne
            }), "flow two's narrow column put the second story elsewhere")
            await idle([one, two], turns: 20)
            close(two.window)
            await idle([one])

            #expect(ReadingFlowGeometry.anchorTops[second] == topOne,
                    "the top is the open window's: \(String(describing: ReadingFlowGeometry.anchorTops[second])) vs \(topOne)")
        }
    }

    // MARK: - The shell: ShellGeometry, the rail, the note box

    private func shell(_ session: AppSession, _ router: ShellRouter) -> some View {
        RootView(session: session, services: nil, router: router)
    }

    /// **`ShellGeometry`'s two frames and `SidebarGeometry.railGroupHeights`**
    /// — the shell seam's unkeyed pair, and the "this note" rail keyed by
    /// the note. The same note in a tall shell (stays) and a short one
    /// (goes): the seam runs a different height, and the short column
    /// compresses the rail's pitch.
    ///
    /// RED ON OLD (measured — the C4 record): the seam and the rail are the
    /// short shell's.
    @Test func aNoteInTwoShellsKeepsTheOpenShellsSeamAndRail() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 50) {
            let session = AppSession(database: db)
            let theNote = try note(session, "one note, two shells", blocks: 2)
            let post = theNote.postID
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post)")
            defer { UserDefaults.standard.removeObject(forKey: "postMode.\(post)") }
            ShellGeometry.reset()
            let routerOne = ShellRouter()
            let one = mount(shell(session, routerOne), width: 1200, height: 900)
            defer { close(one.window) }
            routerOne.workspace.visit(.post(post))
            _ = routerOne.workspace.select(.post(post))
            #expect(await settle([one], until: {
                ShellGeometry.dividerLineFrame != nil && ShellGeometry.dividerGripFrame != nil
                    && SidebarGeometry.railGroupHeights[post] != nil
            }, maxTurns: 300), "shell one drew its seam and the note's rail")
            await idle([one])
            let lineOne = try #require(ShellGeometry.dividerLineFrame)
            let gripOne = try #require(ShellGeometry.dividerGripFrame)
            let railOne = try #require(SidebarGeometry.railGroupHeights[post])

            let routerTwo = ShellRouter()
            let two = mount(shell(session, routerTwo), width: 1000, height: 420, x: 300)
            defer { close(two.window) }
            routerTwo.workspace.visit(.post(post))
            _ = routerTwo.workspace.select(.post(post))
            #expect(await settle([one, two], until: {
                ShellGeometry.dividerLineFrame != lineOne && ShellGeometry.dividerGripFrame != gripOne
                    && SidebarGeometry.railGroupHeights[post] != railOne
            }, maxTurns: 300), "shell two's seam and compressed rail differ")
            close(two.window)
            await idle([one])

            #expect(ShellGeometry.dividerLineFrame == lineOne, "the seam's line is the open shell's")
            #expect(ShellGeometry.dividerGripFrame == gripOne, "the seam's grip is the open shell's")
            #expect(SidebarGeometry.railGroupHeights[post] == railOne,
                    "the rail is the open shell's: \(String(describing: SidebarGeometry.railGroupHeights[post])) vs \(railOne)")
        }
    }

    /// **`SidebarGeometry.noteBoxFrames` / `.noteBoxWhereLines`** — the book's
    /// note box, keyed by the book. The same book in a tall shell with its
    /// first note selected (stays) and a short shell with its second note
    /// selected (goes): the box is compressed there, and says another note.
    ///
    /// RED ON OLD (measured — the C4 record): the box and its where-line are
    /// the short shell's.
    @Test func aBookInTwoShellsKeepsTheOpenShellsNoteBox() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 51) {
            let session = AppSession(database: db)
            let (readingID, postIDs) = try book(session)
            let routerOne = ShellRouter()
            let one = mount(shell(session, routerOne), width: 1200, height: 900)
            defer { close(one.window) }
            routerOne.pendingSelection = .reading(readingID)
            #expect(await settle([one], until: {
                SidebarGeometry.noteBoxFrames[readingID] != nil
                    && BookOutlineGeometry.focusDoors[readingID] != nil
            }, maxTurns: 300), "shell one's book put its box up")
            BookOutlineGeometry.focusDoors[readingID]?(postIDs[0])
            #expect(await settle([one], until: {
                SidebarGeometry.noteBoxWhereLines[readingID] != nil
            }, maxTurns: 200), "shell one's box names its note")
            await idle([one])
            let boxOne = try #require(SidebarGeometry.noteBoxFrames[readingID])
            let lineOne = try #require(SidebarGeometry.noteBoxWhereLines[readingID])

            let routerTwo = ShellRouter()
            let two = mount(shell(session, routerTwo), width: 1000, height: 420, x: 300)
            defer { close(two.window) }
            routerTwo.pendingSelection = .reading(readingID)
            #expect(await settle([one, two], until: {
                SidebarGeometry.noteBoxFrames[readingID] != boxOne
            }, maxTurns: 300), "shell two's compressed box differs")
            // The newest book's door is shell two's (on both trees).
            BookOutlineGeometry.focusDoors[readingID]?(postIDs[1])
            #expect(await settle([one, two], until: {
                SidebarGeometry.noteBoxWhereLines[readingID] != lineOne
            }, maxTurns: 200), "shell two's box names its other note")
            close(two.window)
            await idle([one])

            #expect(SidebarGeometry.noteBoxFrames[readingID] == boxOne,
                    "the box is the open shell's: \(String(describing: SidebarGeometry.noteBoxFrames[readingID])) vs \(boxOne)")
            #expect(SidebarGeometry.noteBoxWhereLines[readingID] == lineOne,
                    "the where-line is the open shell's: \(String(describing: SidebarGeometry.noteBoxWhereLines[readingID])) vs \(lineOne)")
        }
    }
}
#endif
