//
//  NoteBoxMountTests.swift
//  VariorumTests
//
//  18d batch 1 — the sidebar note box's MOUNTED pins (her U-10). The brains
//  are pinned pure in `NoteBoxTests`; a brain pin cannot prove a rectangle.
//
//  What these hold:
//  · **THE GEOMETRY ORACLE** — the box stands at the rail's EXACT drawn
//    height, in every state and in both voices, so the Open strip below it
//    never moves (her *"measured to take up the same amount of room"*). Two
//    measured rectangles, never a constant either view might not consult.
//  · **THE COMPOSITION** — a book opening in the real shell puts the box on
//    the column saying "no note selected", through the whole road: the book
//    publishes, `RootView` composes, the sidebar renders.
//  · **THE PUBLICATION** — the book's own report moves empty → live → empty
//    as she focuses and clicks out, carrying the identity the navigator holds.
//  · **THE RETIREMENT (U-17)** — the book's editing surfaces mount NO bar of
//    their own: not the Outline's focused row (its gutter is gone), not the
//    paged Book mode's page (her *"it won't be at the bottom"*).
//
//  Red-on-old: the box did not exist, so the oracle's second rectangle had
//  nothing to measure. The retirement's pins ARE red on old by construction
//  and were measured so — see the batch record.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The oracle's host

/// One root whose two inputs the test drives: which sidebar selection stands
/// (a note ⇒ the rail; a book ⇒ the box) and, for the box, which state.
@MainActor
private struct NoteBoxOracleHost: View {
    let session: AppSession
    let library: LibraryViewModel
    let pool: PoolViewModel
    let workspace: WorkspaceModel
    let stars: StarsModel
    let theme: ThemeStore
    var selection: SidebarSelection?
    var box: AnyView?

    var body: some View {
        SidebarView(
            session: session, model: library, pool: pool,
            workspace: workspace, stars: stars,
            selection: .constant(selection),
            noteBox: box)
            .frame(width: 230)
            .environment(theme)
    }
}

@MainActor
private func makeBox(
    _ state: NoteBoxState, tokens: VoiceTokens, subjectKey: String,
    withBar: Bool = false, model: EditorViewModel? = nil
) -> AnyView {
    AnyView(SidebarNoteBox(
        tokens: tokens,
        subjectKey: subjectKey,
        state: state,
        identity: state.postID.map {
            NoteBoxIdentity(
                postID: $0,
                title: "The Five Orange Pips and a title long enough to wrap",
                chapter: "chapter two", index: 5, total: 12)
        },
        facts: NoteBoxFacts(
            words: 3214, blocks: 41, fannedBlocks: 2,
            editedAt: Date(timeIntervalSince1970: 1_788_000_000),
            savedAt: Date(timeIntervalSince1970: 1_787_800_000)),
        caretLabel: state.isLive ? { BlockLineLabel.caret(ordinal: 3, of: 41) } : nil,
        onEditHere: {},
        bar: withBar && model != nil ? AnyView(CommitBar(model: model!, axis: .box)) : nil))
}

@MainActor
@Suite("The note box's geometry (18d batch 1 — U-10's 'the same amount of room')", .serialized)
struct NoteBoxGeometryTests {
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// Mount one column and read what it drew. A fresh window per case: the
    /// column's own `@State` (its measured height, its fit verdict) is what
    /// decides the row pitch, and a fresh mount is the honest way to ask two
    /// different columns the same question.
    private func drawnColumn(
        session: AppSession, theme: ThemeStore,
        selection: SidebarSelection?, box: AnyView?,
        openNote: String?,
        until predicate: @escaping () -> Bool
    ) async -> (NSWindow, NSHostingView<NoteBoxOracleHost>) {
        let workspace = WorkspaceModel()
        if let openNote { workspace.visit(.post(openNote)) }
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 230, height: 900),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: NoteBoxOracleHost(
            session: session, library: LibraryViewModel(session: session),
            pool: PoolViewModel(session: session), workspace: workspace,
            stars: StarsModel(session: session), theme: theme,
            selection: selection, box: box))
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: predicate)
        return (window, hosting)
    }

    /// **THE ORACLE.** The rail's group and the box are measured in the SAME
    /// column at the SAME width, and must agree to the point — in all three
    /// states, in both voices.
    ///
    /// RED ON OLD: `SidebarGeometry.noteBoxFrames` had nothing to publish;
    /// with a book open the column drew no group at all where the rail
    /// stands, so the Open strip sat a whole rail-group higher than it does
    /// for a note — which is exactly what her ruling forbids.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func theBoxStandsAtTheRailsExactHeightInEveryStateAndBothVoices(
        voice: ThemeVoice
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // The LIVE uuid generator, deliberately (the 18d ladder's
            // MINOR-3): `.incrementing` hands every parallel suite the SAME
            // ids, so the oracle keys below would collide across suites and
            // the keying would buy nothing.
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 10))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            try session.operations.setThemeVoice(voice)
            let post = try session.operations.createPost(title: "a note")
            _ = try session.operations.newBlock(in: post.id, text: "so the rail has a note.")
            let book = try session.operations.createReading(name: "a book", kind: .curated)
            // The store — started and RESTORED by the one helper (round 2's
            // NIT-2): this arm adopts the DB's voice on the store's first
            // emission and used to leave it standing process-wide, with only
            // a `cancel()` that never joined the store's own task.
            try await withAdoptedTheme(session: session) { theme in

#if DEBUG
                // MY rail — keyed by the note it draws for (the round-end Fable
                // pass, MINOR-2 (a)): a rail drawn concurrently by another suite
                // used to supply this reference, spuriously red at a compressed
                // pitch and meaninglessly green at the generous one.
                SidebarGeometry.forgetRail(post.id)
                let (railWindow, _) = await drawnColumn(
                    session: session, theme: theme, selection: .post(post.id), box: nil,
                    openNote: post.id, until: { SidebarGeometry.railGroupHeights[post.id] != nil })
                defer {
                    railWindow.orderOut(nil)
                    railWindow.close()
                }
                let rail = try #require(
                    SidebarGeometry.railGroupHeights[post.id], "the rail drew for the selected note")
                #expect(
                    rail == SidebarLayout.railGroupHeight(
                        rowHeight: SidebarLayout.generousRowHeight,
                        railRows: PostDetailView.Mode.allCases.count),
                    "the rail's DRAWN group is the arithmetic the box reads: \(rail)")

                let tokens = VoiceTokens.resolve(voice: voice, dark: false)
                for state in [
                    NoteBoxState.empty,
                    NoteBoxState.selected(post.id),
                    NoteBoxState.live(post.id),
                ] {
                    SidebarGeometry.forgetBoxFrame(book.id)
                    let (window, _) = await drawnColumn(
                        session: session, theme: theme, selection: .reading(book.id),
                        box: makeBox(state, tokens: tokens, subjectKey: book.id),
                        openNote: post.id,
                        until: { SidebarGeometry.noteBoxFrames[book.id] != nil })
                    let box = SidebarGeometry.noteBoxFrames[book.id]
                    window.orderOut(nil)
                    window.close()
                    let drawn = try #require(box, "the box drew in state \(state)")
                    #expect(abs(drawn.height - rail) <= 0.5,
                            "\(voice) · \(state): the box is the rail's height — \(drawn.height) vs \(rail)")
                }
#endif
            }
        }
    }

    /// Her punchlist 3's *"the items in that pane should all be aligned"*,
    /// applied to a bordered box: the box's header words start on exactly the
    /// left edge the column's own rows start on.
    @Test func theBoxesHeaderSitsOnTheColumnsOneLeftEdge() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note")
            _ = try session.operations.newBlock(in: post.id, text: "text.")
            let book = try session.operations.createReading(name: "a book", kind: .curated)
            let theme = ThemeStore(session: session)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 230, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            // Row 50: this pin's OWN column, named by its own session —
            // and a reset that clears its scope alone.
            let column = SidebarGeometry.headers(session.debugProbeScope)
            column.resetHeaders()
#endif
            let workspace = WorkspaceModel()
            workspace.visit(.post(post.id))
            let hosting = NSHostingView(rootView: NoteBoxOracleHost(
                session: session, library: LibraryViewModel(session: session),
                pool: PoolViewModel(session: session), workspace: workspace,
                stars: StarsModel(session: session), theme: theme,
                selection: .reading(book.id),
                box: makeBox(.selected(post.id), tokens: .terminalLight,
                             subjectKey: book.id)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
#if DEBUG
            await settle(window, hosting, until: {
                SidebarGeometry.noteBoxHeaderFrames[book.id] != nil
                    && column.firstRowContentFrames[
                        WorkspaceNaming.openSectionHeader] != nil
            })
            let words = try #require(SidebarGeometry.noteBoxHeaderFrames[book.id])
            // The Open strip's first row is the column's own row-text edge —
            // the same rectangle row 13 measured the rail's header against.
            let row = try #require(
                column.firstRowContentFrames[WorkspaceNaming.openSectionHeader])
            #expect(abs(words.minX - row.minX) <= 1.5,
                    "the box's header starts where the column's rows do — \(words.minX) vs \(row.minX)")
#endif
        }
    }
}

// MARK: - The composition, the publication, and the retirement

@MainActor
private func withOutlineBook<T>(
    posts: Int,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // LIVE uuids (MINOR-3): the oracle keys are these ids.
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the box's book", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "note \(p)")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "Prose of note \(p), long enough to read like real writing "
                    + "and to give the surface something to lay out.")
            // A SECOND block: the caret-door pin needs somewhere to jump to,
            // and a one-block note cannot exercise ⌃⌘↓ at all.
            _ = try session.operations.newBlock(
                in: post.id,
                text: "A second paragraph of note \(p), so this note has two "
                    + "blocks and a caret can move between them.")
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        let one = try session.operations.createSection(in: reading.id, name: "one")
        for postID in postIDs.prefix(1) {
            try session.operations.assignPostToSection(postID, in: reading.id, section: one.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
@Suite("The note box's composition and the gutter's retirement (18d batch 1)", .serialized)
struct NoteBoxCompositionTests {
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// The book's two models, SEEDED by hand — the mount-test pattern
    /// (`BookRedesignMountTests`): `start()` is an endless observation, and a
    /// hosted `.task` never fires under the test host anyway.
    private func loadedBook(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> (BookViewModel, BookStructureModel) {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in
                try Queries.reading($0, id: readingID)
            },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return (model, structure)
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// **THE WHOLE ROAD.** A book opening in the real shell puts the box on
    /// the column, at the rail's height, saying *"no note selected"* — the
    /// book publishes, `RootView` composes, the sidebar renders.
    ///
    /// RED ON OLD: with a book open the column drew nothing where the rail
    /// stands, so `noteBoxFrames` had nothing to publish and the empty face
    /// did not exist.
    @Test func aBookOpeningPutsTheBoxOnTheColumnSayingNoNoteSelected() async throws {
        try await withOutlineBook(posts: 3) { session, db, readingID, postIDs in
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            // MY rail, by its note (the round-end Fable pass, MINOR-2 (a)) —
            // and MY box, by its book (round 2's MINOR-2: the whole-oracle
            // `resetHeaders()` that stood here wiped every other suite's box
            // too, and `onGeometryChange` never republishes a wiped frame).
            SidebarGeometry.forgetRail(postIDs[0])
            SidebarGeometry.forgetBox(subject: readingID)
#endif
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // A note first: the rail draws, and its height is what the box
            // must match on this very column.
            router.workspace.visit(.post(postIDs[0]))
            _ = router.workspace.select(.post(postIDs[0]))
#if DEBUG
            await settle(window, hosting, until: {
                SidebarGeometry.railGroupHeights[postIDs[0]] != nil
            })
            let rail = try #require(SidebarGeometry.railGroupHeights[postIDs[0]], "the rail drew")
            // The local proof that the rail drew at the pitch the box's frame
            // assumes — its own number now, not cross-suite noise.
            #expect(rail == SidebarLayout.railGroupHeight(
                rowHeight: SidebarLayout.generousRowHeight,
                railRows: PostDetailView.Mode.allCases.count),
                    "the rail's DRAWN group is the arithmetic the box reads: \(rail)")

            // …then the book.
            router.pendingSelection = .reading(readingID)
            await settle(window, hosting, until: {
                SidebarGeometry.noteBoxFrames[readingID] != nil
                    && (SidebarGeometry.noteBoxFaces[readingID]?["empty"] ?? 0) > 0
            })
            let box = try #require(
                SidebarGeometry.noteBoxFrames[readingID], "the box drew for the open book")
            #expect((SidebarGeometry.noteBoxFaces[readingID]?["empty"] ?? 0) > 0,
                    "and it says 'no note selected' — nothing has been clicked")
            #expect(abs(box.height - rail) <= 0.5,
                    "at the rail's own height: \(box.height) vs \(rail)")
#endif
        }
    }

    /// **THE PUBLICATION.** The book's report moves empty → live → empty as
    /// she focuses a note and clicks out of it, and carries the identity the
    /// navigator holds (title, chapter, place in the reading order).
    ///
    /// RED ON OLD: `onNoteBox` did not exist — the book published nothing,
    /// and its doors lived in a 190-pt gutter down the right of the page.
    @Test func theBookPublishesItsNoteAndTheIdentityTheNavigatorHolds() async throws {
        try await withOutlineBook(posts: 3) { session, db, readingID, postIDs in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID)
            let reports = LockIsolated<[NoteBoxReport?]>([])
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure,
                onNoteBox: { _, report, _ in
                    reports.withValue { $0.append(report) }
                }))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !reports.value.isEmpty })

            #expect(reports.value.last??.state == NoteBoxState.empty,
                    "an Outline with nothing focused points at no note")

            model.focus(postIDs[0])
            await settle(window, hosting, until: {
                reports.value.last??.state == NoteBoxState.live(postIDs[0])
            })
            let live = try #require(reports.value.last ?? nil)
            #expect(live.state == .live(postIDs[0]))
            let identity = try #require(live.identity)
            #expect(identity.postID == postIDs[0])
            #expect(identity.title == "note 0")
            #expect(identity.chapter == "one", "the chapter the navigator shows it under")
            #expect(identity.index == 1)
            #expect(identity.total == 3)

            // …and clicking out empties it (her U-10's own sentence).
            model.focus(nil)
            await settle(window, hosting, until: {
                reports.value.last??.state == NoteBoxState.empty
            })
            #expect(reports.value.last??.state == NoteBoxState.empty)
        }
    }

    /// **THE TWO CARET DOORS, IN AN OUTLINE NOTE** (the 18d ladder's
    /// MINOR-1). ⌃⌘↑/↓ (`EditorCommands`' `previousBlock`/`nextBlock`) and
    /// Export ▸ This Block (`ShellActions.exportCaretBlock`) both act on the
    /// caret, and both used to read `EditorRouter.active` — which in the
    /// Outline is the projection-less shadow the KnownIssues row traces. The
    /// menu closure and the save panel are unreachable from a test; what IS
    /// reachable is the exact expression each door evaluates, so the pin
    /// holds THAT and the record names the two call sites (one grep).
    ///
    /// **THE SHADOW IS REPRODUCED HERE, DELIBERATELY.** A hosted mount does
    /// not grow the Outline's second `InlineEditorSurface` (the same reason
    /// `BookRedesignMountTests` measures exactly one `EditorTextView`) — it
    /// is a live-app timing, traced on the dev build with an attach-time
    /// stack. Waiting for SwiftUI to produce it would make this pin green on
    /// both sides and prove nothing, so the pin reproduces the MECHANISM the
    /// trace names: a second `EditorViewModel` for the same post attaches a
    /// text view and takes `active`, exactly as the shadow does. RED ON OLD,
    /// measured by behavioural revert of both doors to the bare `active`:
    /// `caretBlockID → nil` — the export door's guard fails and speaks the
    /// unavailable note, and the jump returns at its first `guard` with the
    /// caret where it was (2 issues).
    @Test func theCaretDoorsActOnTheEditorSheIsWritingInNotTheLastToAttach() async throws {
        try await withOutlineBook(posts: 3) { session, db, readingID, postIDs in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !model.entries.isEmpty })

            // A note focused in Outline: the ONE full-document editor mounts.
            model.focus(postIDs[0])
            await settle(window, hosting, until: {
                session.editorRouter.editing?.caretBlockID != nil
            })
            let writing = try #require(session.editorRouter.editing)

            // THE SHADOW, reproduced: a second model for the same post
            // attaches a text view and takes `active`, with no projection
            // and no caret — the live condition the KnownIssues row traces.
            let shadow = EditorViewModel(session: session, postID: postIDs[0])
            shadow.attach(textView: EditorTextView.makeInlineEditor(), scrollView: nil)
            #expect(session.editorRouter.active === shadow,
                    "the last text view to attach took `active`, as it does live")
            #expect(shadow.caretBlockID == nil,
                    "…and it knows nothing: no projection, no caret")
            #expect(session.editorRouter.editing === writing,
                    "`editing` still names the editor she is writing in")

            // THE DOORS' OWN EXPRESSION. `exportCaretBlock` guards on exactly
            // this pair; the jump's first guard reads the same two.
            let door = try #require(
                session.editorRouter.editingOrActive,
                "a caret door finds an editor while a note is focused in Outline")
            // …and it is the editor she is writing in: the block she is in is
            // exactly what Export ▸ This Block would name.
            let firstBlock = try #require(door.caretBlockID)
            #expect(door.blockCount > 1, "the fixture has blocks to jump between")

            // ⌃⌘↓: the caret MOVES to the next block.
            door.jumpToAdjacentBlock(1)
            await settle(window, hosting, until: { door.caretBlockID != firstBlock })
            #expect(door.caretBlockID != nil)
            #expect(door.caretBlockID != firstBlock,
                    "⌃⌘↓ moved the caret — the act the enabled menu item promises (P-2)")

            // …and ⌃⌘↑ comes back, so the pair is symmetric through the
            // same accessor.
            door.jumpToAdjacentBlock(-1)
            await settle(window, hosting, until: { door.caretBlockID == firstBlock })
            #expect(door.caretBlockID == firstBlock)
        }
    }

    /// **THE RETIREMENT (U-17).** The book's editing surfaces render NO bar
    /// of their own — her *"then it can stop taking up room on the right and
    /// it won't be at the bottom when you're in that book editing mode."*
    ///
    /// RED ON OLD, measured by behavioural revert (the batch record has the
    /// numbers): Outline's focused row mounted a `CommitBar(axis: .vertical)`
    /// in a 190-pt gutter, and the paged Book mode's active page mounted the
    /// horizontal bar INSIDE the page's own scroll.
    @Test func theBooksEditingSurfacesMountNoBarOfTheirOwn() async throws {
        try await withOutlineBook(posts: 3) { session, db, readingID, postIDs in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            CommitBarGeometry.reset()
#endif
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { false }, maxTurns: 8)

            // OUTLINE, a note focused: one live editor, zero bars.
            model.focus(postIDs[0])
            await settle(window, hosting, until: { model.liveFocusedPostID == postIDs[0] })
            await settle(window, hosting, until: { false }, maxTurns: 12)
#if DEBUG
            #expect(CommitBarGeometry.mounted("horizontal", post: postIDs[0]) == 0,
                    "Outline's focused note draws no bar in the page")
            // (`rowFrame` stays a singleton — it belongs to row 81's own
            //  pin and is not this batch's to re-key; the per-post counter
            //  above is what this pin reads, so a bar mounted by another
            //  suite cannot answer for this book.)

            // THE PAGED BOOK MODE: the same, at the bottom of the page.
            structure.mode = .spread
            model.seedSpreadFromFocus()
            await settle(window, hosting, until: { !model.spreadEntries.isEmpty })
            await settle(window, hosting, until: { false }, maxTurns: 12)
            for postID in postIDs {
                #expect(CommitBarGeometry.mounted("horizontal", post: postID) == 0,
                        "the paged Book mode's page draws no floating bar either")
            }
#endif
        }
    }

    /// **The round-end Fable pass, MAJOR-1 — a keystroke in a book note
    /// re-runs the BOX, never the SHELL.** The box's where-line reads the
    /// live editor's `caretOrdinal`/`blockCount`, which `updateCaretContext`
    /// rewrites on every keystroke; read as a VALUE inside `ShellSplit`'s
    /// sidebar closure, that registered the whole shell against the caret,
    /// and every keystroke re-ran the sidebar column and the pane row.
    ///
    /// Through the REAL shell: a book opened in Outline, a note made live
    /// through the book's published focus door, the box's bar mounted; then
    /// twenty caret-context updates (the per-keystroke call), each given its
    /// own run-loop turn so SwiftUI cannot coalesce them, against a counter
    /// that increments INSIDE `SidebarView.body`. The second arm proves the
    /// label still follows the caret — the count must fall AND the where-line
    /// must move, or the pin is satisfied by deleting the feature.
    ///
    /// RED ON OLD (measured by behavioural revert — the value read back in
    /// the shell's closure): twenty updates ran the sidebar's body twenty
    /// times. Green after: fewer than five.
    @Test func aKeystrokeInABookNoteReRunsTheBoxAndNotTheShell() async throws {
        try await withOutlineBook(posts: 2) { session, db, readingID, postIDs in
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            // MY box, by its book (round 2's MINOR-2 folded the two hand-nils
            // that stood here into the one keyed door).
            SidebarGeometry.forgetBox(subject: readingID)
            BookOutlineGeometry.forgetFocusDoor(readingID)
#endif
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            router.pendingSelection = .reading(readingID)
#if DEBUG
            await settle(window, hosting, until: {
                SidebarGeometry.noteBoxFrames[readingID] != nil
                    && BookOutlineGeometry.focusDoors[readingID] != nil
            })
            let focus = try #require(
                BookOutlineGeometry.focusDoors[readingID], "the book published its focus door")
            focus(postIDs[0])
            await settle(window, hosting, until: {
                session.editorRouter.editing?.postID == postIDs[0]
                    && CommitBarGeometry.mounted("box", post: postIDs[0]) == 1
                    && SidebarGeometry.noteBoxWhereLines[readingID]?.contains("block 1/2") == true
            }, maxTurns: 160)
            let editing = try #require(session.editorRouter.editing, "the note is live in Outline")
            #expect(editing.postID == postIDs[0])
            #expect(CommitBarGeometry.mounted("box", post: postIDs[0]) == 1, "the box's bar is up")
            #expect(SidebarGeometry.noteBoxWhereLines[readingID]?.contains("block 1/2") == true,
                    "the where-line names the caret's block: \(String(describing: SidebarGeometry.noteBoxWhereLines[readingID]))")

            // Let the mount's own churn drain, then count.
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let key = SidebarGeometry.bodyKey(for: router.workspace)
            let before = SidebarGeometry.bodyEvaluations[key] ?? 0
            for _ in 0..<20 {
                editing.updateCaretContext()
                await settle(window, hosting, until: { false }, maxTurns: 1)
            }
            let ran = (SidebarGeometry.bodyEvaluations[key] ?? 0) - before
            print("[round-end Fable pass · MAJOR-1] twenty caret-context updates ran "
                  + "the sidebar's body \(ran) times")
            #expect(ran < 5,
                    "the shell must not re-render per keystroke — twenty caret-context updates ran the sidebar's body \(ran) times")

            // The second arm: the label still follows the caret.
            editing.jumpToAdjacentBlock(1)
            editing.updateCaretContext()
            await settle(window, hosting, until: {
                SidebarGeometry.noteBoxWhereLines[readingID]?.contains("block 2/2") == true
            })
            #expect(SidebarGeometry.noteBoxWhereLines[readingID]?.contains("block 2/2") == true,
                    "…and the box's where-line still moves with the caret: \(String(describing: SidebarGeometry.noteBoxWhereLines[readingID]))")
#endif
        }
    }
}
