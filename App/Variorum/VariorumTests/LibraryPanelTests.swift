//
//  LibraryPanelTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch E — the Library's right panel becomes
//  THE SIMPLE READ PREVIEW (rows 1 + 33; R-cor-3 as ratified at
//  R-cor-10(1)), the boundary holds when the window is inactive (row 34),
//  the pick wears the calm grammar instead of the system band (row 56), the
//  receipt is laid out rather than overlaid on the quick-entry bar (F's (a)),
//  and the book row's target spans the row (row 33 (a)).
//
//  ── WHAT THESE PINS REACH ────────────────────────────────────────────────
//  The BRAIN (`LibraryPreview`) is pure and pinned on an in-memory store:
//  what a note shows (its blocks, its facts line) and what a book shows (its
//  chapters and notes in the book's own order, row 8's one-note-chapter
//  collapse). The HOST is mounted for real in a window and read through the
//  DEBUG `LibraryPanelOracle` — frames in the catalog's own named space (a
//  `.global` read inside a macOS `ScrollView` answers in the scroll view's
//  space; batch C's lesson) — so the inactive-window boundary, the message
//  row's place and the book line's width are MEASURED, never asserted from a
//  type. The Open door's landing rides batch C's authority and is pinned from
//  the Library's side: a note whose memory holds block 2 mounts with the
//  caret in block 2.
//
//  ── WHAT THEY DO NOT REACH, NAMED ────────────────────────────────────────
//  The row backgrounds live inside a `ForEach`, which the reflection road
//  cannot see into (batch D's lesson) — the List's retired selection binding
//  is what the reflection pin reads (`List<Set<String>` on the old tree,
//  `List<Never` now), and the wash + border is the walk's to see. The
//  presence animation (0.22 s) is walked, not pinned (batch A's precedent).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withLibrary<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - The brain

@MainActor
@Suite("The Library panel's preview brain (the Act 10 correction round, batch E)")
struct LibraryPreviewBrainTests {
    /// Row 1: a NOTE's preview is its rendered blocks in order and ONE calm
    /// facts line — words · blocks · edited — nothing more.
    @Test func aNotePreviewsItsBlocksInOrderWithOneFactsLine() async throws {
        try await withLibrary { session, db in
            let post = try session.operations.createPost(title: "the preview")
            _ = try session.operations.newBlock(in: post.id, text: "First block, four words.")
            _ = try session.operations.newBlock(in: post.id, text: "# A heading\n\nSecond block.")
            let read = try await db.read { [id = post.id] db in
                try LibraryPreview.note(db, id: id)
            }
            let preview = try #require(read)
            #expect(preview.blocks.map(\.text)
                    == ["First block, four words.", "# A heading\n\nSecond block."])
            #expect(preview.words == 4 + 4)
            // VX-351 (the VX-348 run, U4), a JUSTIFIED EDIT: the line speaks the
            // ONE stamp rule — the List row's words — where it printed the raw
            // day key (`edited 2026-07-01`, a second wording rule).
            let edited = TimeStampFace.stamp(
                .edited, date: Date(timeIntervalSince1970: 1_782_864_000), now: Date())
            #expect(preview.factsLine == "8 words · 2 blocks · \(edited)")
            #expect(!preview.sealed && !preview.archived)
        }
    }

    @Test func anEmptyNotePreviewsNothingAndSaysSo() async throws {
        try await withLibrary { session, db in
            let post = try session.operations.createPost(title: "empty")
            let read = try await db.read { [id = post.id] db in
                try LibraryPreview.note(db, id: id)
            }
            let preview = try #require(read)
            #expect(preview.blocks.isEmpty)
            #expect(preview.factsLine.hasPrefix("0 words · 0 blocks"))
        }
    }

    @Test func theFactsLineNamesOnlyTheStatesThatAreTrue() {
        #expect(LibraryPreview.factsLine(
            words: 1, blocks: 1, edited: nil, sealed: false, archived: false)
            == "1 word · 1 block")
        #expect(LibraryPreview.factsLine(
            words: 1_200, blocks: 3, edited: "2026-09-01", sealed: true, archived: true)
            == "1,200 words · 3 blocks · edited 2026-09-01 · sealed · archived")
        #expect(LibraryPreview.bookFactsLine(kind: .book, finished: false, chapters: 0, notes: 1)
                == "book · 1 note")
        #expect(LibraryPreview.bookFactsLine(kind: .gathering, finished: true, chapters: 2, notes: 13)
                // 13i-d U6 (a), a JUSTIFIED EDIT: "smart" is retired app-wide
                // (the sitting record §14) — a gathering is a gathering.
                == "gathering · 2 chapters · 13 notes · finished")
    }

    /// Row 33: a BOOK's preview is its OUTLINE — chapters and notes in the
    /// book's own order; a chapter whose ONE note says its name collapses
    /// into one row that opens the note (row 8's rule); strays trail unfiled.
    @Test func aBookPreviewsItsChaptersAndNotesInTheBooksOwnOrder() async throws {
        try await withLibrary { session, db in
            let ops = session.operations
            let scandal = try ops.createPost(title: "A Scandal in Bohemia")
            let first = try ops.createPost(title: "the first")
            let second = try ops.createPost(title: "the second")
            let stray = try ops.createPost(title: "a stray")
            let book = try ops.createReading(name: "the book", kind: .book)
            for post in [scandal, first, second, stray] {
                _ = try ops.addPostToReading(post.id, to: book.id)
            }
            let one = try ops.createSection(in: book.id, name: "A Scandal in Bohemia")
            let two = try ops.createSection(in: book.id, name: "Two")
            try ops.assignPostToSection(scandal.id, in: book.id, section: one.id)
            try ops.assignPostToSection(first.id, in: book.id, section: two.id)
            try ops.assignPostToSection(second.id, in: book.id, section: two.id)

            let read = try await db.read { [id = book.id] db in
                try LibraryPreview.book(db, id: id)
            }
            let preview = try #require(read)
            #expect(preview.chapters == 2)
            #expect(preview.notes == 4)
            #expect(preview.factsLine == "book · 2 chapters · 4 notes")
            #expect(preview.rows == [
                .chapter(id: one.id, name: "A Scandal in Bohemia", opensPostID: scandal.id, collapsed: true),
                .chapter(id: two.id, name: "Two", opensPostID: first.id, collapsed: false),
                .note(postID: first.id, title: "the first", indented: true),
                .note(postID: second.id, title: "the second", indented: true),
                .heading(id: "unfiled", name: "unfiled"),
                .note(postID: stray.id, title: "a stray", indented: true),
            ])
        }
    }

    @Test func aChapterlessBookPreviewsItsNotesFlush() async throws {
        try await withLibrary { session, db in
            let ops = session.operations
            let a = try ops.createPost(title: "alpha")
            let b = try ops.createPost(title: "beta")
            let book = try ops.createReading(name: "flat", kind: .book)
            _ = try ops.addPostToReading(a.id, to: book.id)
            _ = try ops.addPostToReading(b.id, to: book.id)
            let read = try await db.read { [id = book.id] db in
                try LibraryPreview.book(db, id: id)
            }
            let preview = try #require(read)
            #expect(preview.rows == [
                .note(postID: a.id, title: "alpha", indented: false),
                .note(postID: b.id, title: "beta", indented: false),
            ])
            #expect(preview.factsLine == "book · 2 notes")
        }
    }

    /// The column's width: the inspector's own ideal (420), a third of the
    /// library between. *(VX-350 — a JUSTIFIED EDIT by the VX-348 run's U3:
    /// the floor was the note-side sibling's 280, which held the panel at
    /// 280 while the window narrowed and pushed it off the window's edge — her
    /// "steadily cut off". The floor is 200 now and the third keeps shrinking
    /// the panel until it: 700 → 238, was 280. The 0 / 1488 / 900 rows are
    /// unchanged; `VX350ControlsWidthClassTests` pins the rest.)*
    @Test func thePanelWidthIsTheInspectorsNumbersClampedToTheRoom() {
        #expect(LibraryPanelLayout.width(total: 0) == 420, "unmeasured: the ideal")
        #expect(LibraryPanelLayout.width(total: 1488) == 420)
        #expect(LibraryPanelLayout.width(total: 900) == 306)
        #expect(LibraryPanelLayout.width(total: 700) == 238)
    }
}

// MARK: - The host, mounted

@MainActor
@Suite("The Library panel's host, mounted (the Act 10 correction round, batch E)", .serialized)
struct LibraryPanelHostTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 6,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    private struct Mounted {
        let window: NSWindow
        let hosting: NSHostingView<AnyView>

        @MainActor func tearDown() {
            window.orderOut(nil)
            window.close()
        }
    }

    private static func mount<V: View>(_ view: V, width: CGFloat = 1000, height: CGFloat = 640) -> Mounted {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(view))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return Mounted(window: window, hosting: hosting)
    }

    private static func catalog(
        _ session: AppSession, _ model: LibraryCatalogModel, library: LibraryViewModel
    ) -> LibraryCatalogView {
        LibraryCatalogView(
            session: session, model: model, library: library,
            tags: TagsViewModel(session: session), onOpen: { _ in })
    }

    /// Rows 1 + 34 + 24: a note row's body click stands the panel up as a
    /// column of OUR OWN — the 1 pt divider at its leading edge, the panel at
    /// the ruled width — with the note's FIRST block rendered in it; and the
    /// same column stands, divider and all, in an INACTIVE window
    /// (`controlActiveState = .inactive`), because nothing of it is the
    /// system's to fade. No `.inspector` anywhere in the composition.
    ///
    /// **Red on old** (behavioural revert: the `.inspector` host back): the
    /// oracle never reports a divider or a panel of ours — nil — in either
    /// window state, and the composition carries the inspector modifier.
    @Test func aNoteSelectionStandsThePanelUpWithItsBoundaryActiveAndInactive() async throws {
        try await withLibrary { session, _ in
            let post = try session.operations.createPost(title: "the preview")
            _ = try session.operations.newBlock(in: post.id, text: "The first block's own words.")
            _ = try session.operations.newBlock(in: post.id, text: "The second block.")
            let model = LibraryCatalogModel(session: session)
            let library = LibraryViewModel(session: session)
            await model.search()
            model.clickNoteRow(post.id, modifiers: .none)
            #expect(model.infoHit?.id == post.id)

            for state in [ControlActiveState.key, .inactive] {
                LibraryPanelOracle.reset()
                let mounted = Self.mount(
                    Self.catalog(session, model, library: library)
                        .environment(\.controlActiveState, state))
                defer { mounted.tearDown() }
                #expect(await Self.settle(mounted.window, mounted.hosting) {
                    LibraryPanelOracle.dividerFrame != nil
                        && LibraryPanelOracle.panelFrame != nil
                        && LibraryPanelOracle.rootFrame != nil
                        && LibraryPanelOracle.shownBlockIDs.count >= 2
                }, "\(state): the divider, the panel and the preview's rows reported")
                let root = try #require(LibraryPanelOracle.rootFrame)
                let divider = try #require(LibraryPanelOracle.dividerFrame)
                let panel = try #require(LibraryPanelOracle.panelFrame)
                #expect(divider.width == 1, "\(state): OUR one honest line")
                #expect(abs(divider.height - root.height) <= 2,
                        "\(state): the boundary runs the column's whole height")
                #expect(abs(divider.maxX - panel.minX) <= 1,
                        "\(state): the line sits at the panel's leading edge")
                #expect(abs(panel.width - LibraryPanelLayout.width(total: root.width)) <= 1,
                        "\(state): the ruled width")
                #expect(abs(panel.maxX - root.maxX) <= 1, "\(state): the panel ends at the room's edge")
                let slots = try await session.database.read { [id = post.id] db in
                    try Queries.renderPost(db, containerID: id)
                }
                // The rows' `onAppear` order is not the visual order (a lazy
                // stack realizes as it pleases) — the ORDER is the brain's pin;
                // here: both blocks rendered, the first among them.
                #expect(Set(LibraryPanelOracle.shownBlockIDs).isSuperset(of: Set(slots.map(\.blockID))),
                        "\(state): the note's blocks rendered in the preview")
            }

            // 18k C6 (KnownIssues row 65, item 5): the ban reads the body's
            // STATIC TYPE — the modifier chain exactly as this view composes
            // it — never the VALUE dump. The dump descends into SwiftUI's own
            // stored fields, and on macOS 27 SwiftUI's sheet-presentation
            // modifier (this view's two `.sheet(item:)`s) grew a stored
            // `activeInspector: nil`, which the dump's text matched with no
            // inspector anywhere. It also reaches the dependency context the
            // models captured, test NAME included, so any test named with
            // the word would have tripped it on any OS. The type carries
            // exactly what the correction round's batch E retired: with the old
            // `.inspector(isPresented:)` host put back, the type spells
            // `SwiftUI.InspectorModifier<…>`; today it spells no inspector.
            let composedType = String(
                reflecting: type(of: Self.catalog(session, model, library: library).body))
            let spellsAnInspector = composedType.lowercased().contains("inspector")
            #expect(spellsAnInspector == false,
                    "the panel is a column of our own, never a system inspector")
        }
    }

    /// Row 33: a BOOK row's body click shows the book's OUTLINE in the panel
    /// — its chapters and notes — never the note the panel showed before.
    @Test func aBookSelectionShowsTheBooksOutline() async throws {
        try await withLibrary { session, _ in
            let ops = session.operations
            let note = try ops.createPost(title: "a note")
            _ = try ops.newBlock(in: note.id, text: "A note's text.")
            let one = try ops.createPost(title: "chapter one's note")
            let two = try ops.createPost(title: "chapter two's note")
            let book = try ops.createReading(name: "the book", kind: .book)
            _ = try ops.addPostToReading(one.id, to: book.id)
            _ = try ops.addPostToReading(two.id, to: book.id)
            let chapterOne = try ops.createSection(in: book.id, name: "one")
            let chapterTwo = try ops.createSection(in: book.id, name: "two")
            try ops.assignPostToSection(one.id, in: book.id, section: chapterOne.id)
            try ops.assignPostToSection(two.id, in: book.id, section: chapterTwo.id)

            let model = LibraryCatalogModel(session: session)
            let library = LibraryViewModel(session: session)
            await model.search()
            // The note first (the state her report describes), then the book.
            model.clickNoteRow(note.id, modifiers: .none)
            let bookHit = try #require(model.hits.first { $0.kind == .book && $0.id == book.id })
            model.selectBook(bookHit)
            #expect(model.infoHit?.kind == .book)
            #expect(model.selectedPosts.isEmpty, "a book selection drops the note pick")

            LibraryPanelOracle.reset()
            let mounted = Self.mount(Self.catalog(session, model, library: library))
            defer { mounted.tearDown() }
            #expect(await Self.settle(mounted.window, mounted.hosting) {
                LibraryPanelOracle.shownOutlineRowIDs.count >= 4
            }, "the book's outline rows rendered")
            // As above: appearance order is the lazy stack's, the order is
            // the brain's pin — every chapter and note row rendered.
            #expect(Set(LibraryPanelOracle.shownOutlineRowIDs) == [
                "chapter-\(chapterOne.id)", "note-\(one.id)",
                "chapter-\(chapterTwo.id)", "note-\(two.id)",
            ])
            #expect(LibraryPanelOracle.shownBlockIDs.isEmpty,
                    "no note text in a book's panel — the outline is the preview")
        }
    }

    /// F's (a): the archive door's receipt is a LAID-OUT row — inside the
    /// host, never on the quick-entry bar (it was an overlay pinned to the
    /// column's bottom-left, on the bar, clipped at the window's edge).
    ///
    /// **Red on old** (behavioural revert: the `.overlay(alignment:
    /// .bottomLeading)` back): the receipt's frame intersects the bar's.
    @Test func theReceiptIsLaidOutAboveTheBarNeverOverIt() async throws {
        try await withLibrary { session, _ in
            let post = try session.operations.createPost(title: "to archive")
            _ = try session.operations.newBlock(in: post.id, text: "Going to Archived.")
            let model = LibraryCatalogModel(session: session)
            let library = LibraryViewModel(session: session)
            await library.archive(postID: post.id)
            let receipt = try #require(library.receipt, "the archive door's own sentence")
            await model.search()

            LibraryPanelOracle.reset()
            let mounted = Self.mount(Self.catalog(session, model, library: library))
            defer { mounted.tearDown() }
            #expect(await Self.settle(mounted.window, mounted.hosting) {
                LibraryPanelOracle.messageFrame != nil
                    && LibraryPanelOracle.quickEntryFrame != nil
                    && LibraryPanelOracle.rootFrame != nil
            }, "the receipt \"\(receipt)\", the bar and the root reported")
            let root = try #require(LibraryPanelOracle.rootFrame)
            let message = try #require(LibraryPanelOracle.messageFrame)
            let bar = try #require(LibraryPanelOracle.quickEntryFrame)
            #expect(message.minY >= root.minY - 0.5 && message.maxY <= root.maxY + 0.5,
                    "the receipt lies whole inside the host — nothing clips")
            #expect(!message.intersects(bar), "the receipt never covers the quick-entry bar")
            #expect(message.maxY <= bar.minY + 0.5, "…it sits above the bar")
        }
    }

    /// Row 33 (a): a book row's LINE spans its row, so a click right of the
    /// word "book" is a click on the row (it was a dead click — the line
    /// was only as wide as its words).
    ///
    /// **Red on old** (behavioural revert: the `Spacer` out of the line):
    /// the line's width is its words' (~200 pt), not the row's.
    @Test func aBookRowsLineSpansTheRow() async throws {
        LibraryPanelOracle.reset()
        let line = VStack {
            CatalogBookLine(
                tokens: .fallback(for: .light), title: "essays in progress",
                detail: "book", onTitleTap: {})
        }
        .frame(width: 600)
        .coordinateSpace(name: LibraryCatalogView.probeSpace)
        let mounted = Self.mount(line, width: 600, height: 120)
        defer { mounted.tearDown() }
        #expect(await Self.settle(mounted.window, mounted.hosting) {
            LibraryPanelOracle.bookLineFrame != nil
        })
        let frame = try #require(LibraryPanelOracle.bookLineFrame)
        #expect(frame.width >= 590, "the line is as wide as its row (\(frame.width))")
    }

    /// Row 56: the List draws NO selection of its own — the pick's grammar
    /// is the wash + a tinted border in `rowBackground`, never the system
    /// band the old `List(selection:)` binding painted.
    ///
    /// **Red on old** (behavioural revert: the binding back): the composition
    /// carries `List<Set<String>`.
    @Test func theListCarriesNoSelectionBindingOfItsOwn() async throws {
        try await withLibrary { session, _ in
            let post = try session.operations.createPost(title: "picked")
            let model = LibraryCatalogModel(session: session)
            let library = LibraryViewModel(session: session)
            await model.search()
            model.clickNoteRow(post.id, modifiers: .command_)
            #expect(model.selectedPosts == [post.id], "the model still owns the pick")
            let composition = SurfaceComposition.text(
                of: Self.catalog(session, model, library: library).body)
            #expect(composition.contains("List<Swift.Never"), "a List with no selection of its own")
            #expect(!composition.contains("List<Swift.Set<"), "the system band's binding is gone")
        }
    }

    /// The Open door lands where the caret last was — from the Library's
    /// side: a note whose memory holds block 2 (she was there, then left)
    /// mounts with the caret in block 2, not at the document's start or
    /// end. Door class: the mechanism is batch C's (`CurrentBlockMemory` →
    /// `registerDetail` → the bare arrival), pinned there with red-on-old;
    /// this pins the Library's promise on the same road.
    @Test func theOpenDoorLandsWhereTheCaretLastWas() async throws {
        try await withLibrary { session, db in
            let post = try session.operations.createPost(title: "reopened")
            var blocks: [String] = []
            for text in [
                "Block one, the document's start.",
                "Block two — where she left off last time.",
                "Block three, the document's end.",
            ] {
                blocks.append(try session.operations.newBlock(in: post.id, text: text).block.id)
            }
            let router = session.commandRouter
            router.forgetCurrentBlock(for: post.id)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            defer {
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                router.forgetCurrentBlock(for: post.id)
            }
            // She was in block 2 and closed the note (the detail unmounted).
            let token = router.registerDetail(postID: post.id, mode: .write) { _ in }
            router.noteFocusedBlock(blocks[1], variantID: nil, postID: post.id)
            router.unregisterDetail(token)
            #expect(router.currentBlock(for: post.id)?.blockID == blocks[1])

            let slots = try await db.read { [id = post.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let blockTwo = index.range(ofEntryAt: 1)

            // The Library's Open door: `onOpen(.post(id))` → the shell mounts
            // the detail fresh — exactly this.
            let mounted = Self.mount(
                PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)),
                width: 1100, height: 750)
            defer { mounted.tearDown() }
            #expect(await Self.settle(mounted.window, mounted.hosting) {
                guard let editor = Self.views(EditorTextView.self, in: mounted.hosting).first,
                      editor.window != nil, editor.string.count >= index.documentLength,
                      router.focusedBlock != nil else { return false }
                return editor.selectedRange().location == blockTwo.location
            }, "the caret lands at block 2's start")
            let editor = try #require(Self.views(EditorTextView.self, in: mounted.hosting).first)
            #expect(editor.selectedRange().location == blockTwo.location)
            #expect(router.focusedBlock?.blockID == blocks[1])
        }
    }
}
