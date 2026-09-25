//
//  DebugOracleSingletonWindowTests.swift
//  VariorumTests
//
//  18k UNIT C4 — **the UNKEYED DEBUG oracles' ownership, in real pairs of
//  windows — OPT-IN.** The defect and the form are
//  `DebugOracleTwoWindowTests`'s (read its header first); these seven pins
//  are the ones over slots with NO key at all — `PostDetailOracle`'s four,
//  `CommitBarGeometry`'s row and width, the Read host's face/selection/first
//  paint, the catalog's frames, the canvas's arrival, the Takes article
//  door, the shell's seam.
//
//  **DISABLED BY DEFAULT, and why** (the drills' opt-in pattern,
//  `ProtectionMigrationDrillTests`): an unkeyed slot is written by EVERY
//  surface of its kind in the process, and Swift Testing runs suites in
//  parallel — so while another suite has a post detail (or a bar, a catalog,
//  a canvas…) mounted, "the open window answers" is a claim about someone
//  else's window. That is the one axis C4 does not fix (two LIVE owners in
//  two different tests — 13u2 UNIT E's session-scoping axis, KnownIssues row
//  50's). The first closing run proved it on this very suite: another
//  suite's detail's divider answered. So these run deliberately, ALONE:
//
//      TEST_RUNNER_VARIORUM_ORACLE_SINGLETON_WINDOWS=1 xcodebuild test … \
//        -only-testing:VariorumTests/DebugOracleSingletonWindowTests
//
//  Their always-on guard is the structural arm (`DebugOracleOwnershipTests`
//  drives every one of these slots' doors synchronously, where no other
//  suite can interleave). The pins compile on the pre-fix tree and were run
//  there first — the red numbers are in the C4 record.
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
nonisolated enum OracleSingletonWindows {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_ORACLE_SINGLETON_WINDOWS"] == "1"
    }
}

@MainActor
@Suite(
    "The UNKEYED DEBUG oracles answer for the window still open (18k UNIT C4 — opt-in; DISABLED unless VARIORUM_ORACLE_SINGLETON_WINDOWS=1)",
    .serialized,
    .enabled(
        if: OracleSingletonWindows.requested,
        "unkeyed slots are written by every parallel suite's surfaces — run deliberately and alone with TEST_RUNNER_VARIORUM_ORACLE_SINGLETON_WINDOWS=1"))
struct DebugOracleSingletonWindowTests: DebugOracleWindowRig {
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

    /// **`ReadModeOracle.face` / `.selectedBlockID` / `.firstEditRowPaintedAt`**
    /// — the Read host's unkeyed singletons. Window one reads note α on its
    /// `read` face; window two opens note β on `edit`, and goes.
    ///
    /// RED ON OLD (measured — the C4 record): the face is β's `edit`, the
    /// selection is β's block, and the first edit-row paint is β's, with
    /// only α — which paints no edit row — on screen.
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
            await idle([one])
            let paintedOne = ReadModeOracle.firstEditRowPaintedAt

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
            #expect(ReadModeOracle.firstEditRowPaintedAt == paintedOne,
                    "the first edit-row paint is the open window's: \(String(describing: ReadModeOracle.firstEditRowPaintedAt)) vs \(String(describing: paintedOne))")
        }
    }

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

    /// **`ShellGeometry.dividerLineFrame` / `.dividerGripFrame`** — the shell
    /// seam's unkeyed pair. A tall shell (stays) and a short one (goes): the
    /// seam runs a different height in each.
    ///
    /// RED ON OLD (measured — the C4 record): the seam is the short shell's.
    @Test func aShellInTwoWindowsKeepsTheOpenShellsSeam() async throws {
        let db = try AppDatabase.inMemory()
        try await withLiveWorld(db, seed: 52) {
            let session = AppSession(database: db)
            ShellGeometry.reset()
            let one = mount(shell(session, ShellRouter()), width: 1200, height: 900)
            defer { close(one.window) }
            #expect(await settle([one], until: {
                ShellGeometry.dividerLineFrame != nil && ShellGeometry.dividerGripFrame != nil
            }, maxTurns: 300), "shell one drew its seam")
            await idle([one])
            let lineOne = try #require(ShellGeometry.dividerLineFrame)
            let gripOne = try #require(ShellGeometry.dividerGripFrame)

            let two = mount(shell(session, ShellRouter()), width: 1000, height: 420, x: 300)
            defer { close(two.window) }
            #expect(await settle([one, two], until: {
                ShellGeometry.dividerLineFrame != lineOne && ShellGeometry.dividerGripFrame != gripOne
            }, maxTurns: 300), "shell two's seam differs")
            close(two.window)
            await idle([one])

            #expect(ShellGeometry.dividerLineFrame == lineOne,
                    "the seam's line is the open shell's: \(String(describing: ShellGeometry.dividerLineFrame)) vs \(lineOne)")
            #expect(ShellGeometry.dividerGripFrame == gripOne, "the seam's grip is the open shell's")
        }
    }
}
#endif
