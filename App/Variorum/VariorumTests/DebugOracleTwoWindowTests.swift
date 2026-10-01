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
//  the rest (`Core/Views/DebugOracleOwnership.swift`).
//
//  Every pin has one form, because the defect has one form: mount the same
//  kind of surface in TWO windows whose registrations DIFFER (a different
//  window size, a different note), tear one down, and assert the oracle
//  answers for the window still standing. The pins read the oracles through
//  the names the tree already had, so each compiles on the pre-fix tree and
//  was RUN THERE FIRST — the red numbers are in the C4 record
//  (`notes/plans/phase-18k-runtime-hygiene.md`, UNIT C4 RECORD).
//
//  **TWO SUITES, and why.** The pins in THIS suite read only slots keyed by
//  a live uuid this pin minted (a book, a note, a block) — no other suite
//  can write those keys, so they are exact under parallel suites and run
//  always. The pins over UNKEYED singletons live in
//  `DebugOracleSingletonWindowTests`, OPT-IN: an unkeyed slot is written by
//  every parallel suite that mounts the same kind of surface, so "the open
//  window answers" is only a meaningful claim with nothing else mounted —
//  the one axis C4 does not fix (two LIVE owners in two different tests;
//  13u2 UNIT E's session-scoping axis, KnownIssues row 50's). Their
//  always-on guard is the structural arm, `DebugOracleOwnershipTests`
//  (synchronous, so no other suite can interleave).
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
/// The two-window rig both suites share (18k UNIT C4): real windows, a
/// teardown the way a closed window tears down, a settle, and the worlds —
/// live uuids throughout, so every keyed oracle row is this pin's own.
@MainActor
protocol DebugOracleWindowRig {}

extension DebugOracleWindowRig {
    func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// A real window, hosting `view` at exactly `size`.
    func mount<V: View>(_ view: V, width: CGFloat, height: CGFloat, x: CGFloat = 60)
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
    func close(_ window: NSWindow) {
        guard window.contentView != nil || window.isVisible else { return }
        window.contentView = nil
        window.orderOut(nil)
        window.close()
    }

    @discardableResult
    func settle(
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
    func idle(_ mounts: [(window: NSWindow, hosting: NSView)], turns: Int = 12) async {
        await settle(mounts, until: { false }, maxTurns: turns)
    }

    func withLiveWorld<T>(
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

    /// The book's world, seeded by hand (the `BookRedesignMountTests`
    /// pattern): a curated book with two notes and one chapter.
    func book(_ session: AppSession) throws -> (readingID: String, postIDs: [String]) {
        let reading = try session.operations.createReading(name: "a book in two windows", kind: .book)
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

    func loadedBook(
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

    /// A Read host over `postID`, the way `ReadModeTests` mounts one: its
    /// detail registered (the fact reports need an active post), its own
    /// model, and a scrubbed `@AppStorage` so a walk's toggles cannot move
    /// the index column this pin reads.
    func readHost(
        _ session: AppSession, _ postID: String, storage: UserDefaults
    ) -> some View {
        _ = session.commandRouter.registerDetail(postID: postID, mode: .read) { _ in }
        return ReadModeView(
            session: session, postID: postID,
            model: BlockTOCViewModel(session: session, postID: postID))
            .environment(ThemeStore(session: session))
            .defaultAppStorage(storage)
    }

    func scrubbedStorage(_ name: String) throws -> UserDefaults {
        let suite = "18k-c4-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    func note(
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

    func shell(_ session: AppSession, _ router: ShellRouter) -> some View {
        RootView(session: session, services: nil, router: router)
    }
}

@MainActor
@Suite("The keyed DEBUG oracles answer for the window still open (18k UNIT C4)", .serialized)
struct DebugOracleTwoWindowTests: DebugOracleWindowRig {
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

    /// **`ReadModeOracle.faceFrames` / `.indexColumnFrames` /
    /// `.editBlockFrames`, and the index column's `SeamGeometry` row** —
    /// keyed by note or block, so the SAME note open twice shares every key.
    /// A tall window stays; a short one goes.
    ///
    /// RED ON OLD (measured — the C4 record): every one of them answers with
    /// the short window's rectangle.
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
        }
    }

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

    /// **`SidebarGeometry.railGroupHeights`** — the "this note" rail, keyed
    /// by the note. The same note in a tall shell (stays) and a short one
    /// (goes): the short column compresses the rail's pitch.
    ///
    /// RED ON OLD (measured — the C4 record): the rail is the short shell's.
    @Test func aNoteInTwoShellsKeepsTheOpenShellsRail() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 50) {
            let session = AppSession(database: db)
            let theNote = try note(session, "one note, two shells", blocks: 2)
            let post = theNote.postID
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post)")
            defer { UserDefaults.standard.removeObject(forKey: "postMode.\(post)") }
            let routerOne = ShellRouter()
            let one = mount(shell(session, routerOne), width: 1200, height: 900)
            defer { close(one.window) }
            routerOne.workspace.visit(.post(post))
            _ = routerOne.workspace.select(.post(post))
            #expect(await settle([one], until: {
                SidebarGeometry.railGroupHeights[post] != nil
            }, maxTurns: 300), "shell one drew the note's rail")
            await idle([one])
            let railOne = try #require(SidebarGeometry.railGroupHeights[post])

            let routerTwo = ShellRouter()
            let two = mount(shell(session, routerTwo), width: 1000, height: 420, x: 300)
            defer { close(two.window) }
            routerTwo.workspace.visit(.post(post))
            _ = routerTwo.workspace.select(.post(post))
            #expect(await settle([one, two], until: {
                SidebarGeometry.railGroupHeights[post] != railOne
            }, maxTurns: 300), "shell two's compressed rail differs")
            close(two.window)
            await idle([one])

            #expect(SidebarGeometry.railGroupHeights[post] == railOne,
                    "the rail is the open shell's: \(String(describing: SidebarGeometry.railGroupHeights[post])) vs \(railOne)")
        }
    }

    /// **`SidebarGeometry.noteBoxFrames` / `.noteBoxWhereLines`** — the book's
    /// note box, keyed by the book. The same book in a tall shell with its
    /// first note live (stays) and a short shell with its second note live
    /// (goes): the box is compressed there, and says another note.
    ///
    /// **Two sessions on one store** (the post-detail pin's arrangement), and
    /// the reason is measured: the ONE live editor is a SESSION's (P-3), so
    /// with one session the second shell's focus stepped the first shell's
    /// note down from live — its where-line legitimately changed form, and a
    /// pin comparing it to the live form it had was timing (the final closing
    /// run caught it: `"one · 1 of 2 in this book"` against `"one · 1 of 2 ·
    /// block 1/1"`, shell ONE's line both times).
    ///
    /// RED ON OLD (measured — the C4 record): the box and its where-line are
    /// the short shell's.
    @Test func aBookInTwoShellsKeepsTheOpenShellsNoteBox() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 51) {
            let session = AppSession(database: db)
            let sessionTwo = AppSession(database: db)
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
            let two = mount(shell(sessionTwo, routerTwo), width: 1000, height: 420, x: 300)
            defer { close(two.window) }
            routerTwo.pendingSelection = .reading(readingID)
            #expect(await settle([one, two], until: {
                SidebarGeometry.noteBoxFrames[readingID] != boxOne
            }, maxTurns: 300), "shell two's compressed box differs")
            // The newest book's door is shell two's (on both trees).
            BookOutlineGeometry.focusDoors[readingID]?(postIDs[1])
            #expect(await settle([one, two], until: {
                SidebarGeometry.noteBoxWhereLines[readingID]?.hasPrefix("2 of 2") == true
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
