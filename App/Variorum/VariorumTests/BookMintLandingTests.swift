//
//  BookMintLandingTests.swift
//  VariorumTests
//
//  VX-1039 (the VX-1036 run, batch 1) — A NEW NOTE MADE INSIDE A BOOK ENDS ON
//  THE PAGE, LIVE, WITH THE CARET IN IT. Her report: "when making a new note
//  within a book, it's made at the bottom of a long list sometimes and then you
//  can't actually see the new note ready to be edited." The design record's
//  §3a traced two roads to it (by reading):
//
//  - the navigator foot's doors never asked the page to go to the note at all
//    (`reveal: false` — pinned by `BookMintDoorsLandSourceTests`);
//  - the doors that DID ask (the page foot, ⌥⌘N) could lose the ask: the act
//    requested the reveal in the turn the mint returned, while the book's
//    entries — fed by an observation that needs the write's re-fetch AND the
//    card-preview prime read before it publishes — still held the book as it
//    was. `landOutlineReveal` found the note missing from a non-empty list,
//    consumed the reveal as foreign and returned; when the entries arrived
//    nothing was parked (row 73's parking covers only an EMPTY book).
//    SUSPECTED at the trace — `theMintsLandingSurvivesEntriesArrivingAfterTheAct`
//    is its CONFIRM.
//
//  The hosted harness never fires a view's `.task` (the book's observation), so
//  the entries change only when a test delivers them — which lets the pin hand
//  them over in the ORDER the app's observation delivers them: after the act's
//  own turn. The book is ordered by creation, so the note is shown LAST under
//  every placement rule this run builds (N-2's "under a stamp order the place
//  is the order's") — the pin isolates the landing from the placement.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A book of `posts` notes with realistic (three-line) card previews, so its
/// end sits far below the fold. Live uuids: the book's DEBUG geometry oracle
/// keys on anchor ids, and suites run in parallel (`NewNoteInBookTests`' reason).
@MainActor
func withMintLandingBook<T>(
    posts: Int, chapters: Int = 0,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String], _ sectionIDs: [String]) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1039))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the allotment year", kind: .book)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "note \(p)")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "Prose of note \(p). Two afternoons and it still comes back; fork it out whole, "
                    + "because every broken root is another plant by June, and the bed by the gate "
                    + "fills first after rain.")
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        var sectionIDs: [String] = []
        if chapters > 0 {
            let per = max(1, posts / chapters)
            for c in 0..<chapters {
                let section = try session.operations.createSection(in: reading.id, name: "chapter \(c)")
                sectionIDs.append(section.id)
                for i in (c * per)..<min(c * per + per, posts) {
                    try session.operations.assignPostToSection(postIDs[i], in: reading.id, section: section.id)
                }
            }
        }
        return try await body(session, db, reading.id, postIDs, sectionIDs)
    }
}

@MainActor
@Suite("VX-1039 — a note made inside a book ends on the page, live, the caret in it", .serialized)
struct BookMintLandingTests {
    static let windowWidth: CGFloat = 1100
    static let windowHeight: CGFloat = 760

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 120
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

    private func entries(_ db: AppDatabase, _ readingID: String) async throws -> [Queries.ReadingEntry] {
        try await db.read { try Queries.assembleReading($0, readingID: readingID) }
    }

    private func snapshot(_ db: AppDatabase, _ readingID: String) async throws -> BookStructureModel.Snapshot {
        try await db.read { db in
            .init(
                reading: try Queries.reading(db, id: readingID),
                sections: try Queries.readingSections(db, readingID: readingID),
                deletedSections: [],
                assignments: try Queries.sectionAssignments(db, readingID: readingID))
        }
    }

    private func anchorTop(_ postID: String) -> CGFloat? {
        BookOutlineGeometry.anchorTops[BookOutlineRows.Row.noteAnchor(postID)]
    }

    /// The note's row stands on the page (its header within the window).
    private func onThePage(_ postID: String) -> Bool {
        guard let top = anchorTop(postID) else { return false }
        return top >= -BookView.landingTolerance && top < Self.windowHeight - 60
    }

    /// The live editor under the caret is this note's, and it holds the keyboard.
    private func liveWithTheCaret(_ postID: String, session: AppSession, window: NSWindow) -> Bool {
        guard let editing = session.editorRouter.editing, editing.postID == postID,
              let textView = editing.textView
        else { return false }
        return window.firstResponder === textView
    }

    /// **PIN B — THE CONFIRM (red on the pre-batch tree).** ⌥⌘N in a long book
    /// (the act that asked for its reveal even before this batch): the act runs
    /// and its turn passes with the book's entries as they were (the app's
    /// order — the observation publishes after the write's re-fetch and the
    /// card prime read); THEN the entries arrive holding the new note. The note
    /// must end on the page, live, with the caret in it.
    ///
    /// RED ON OLD: `landOutlineReveal` met the reveal while the note was not
    /// among the (non-empty) entries, consumed it as foreign, and the entries'
    /// arrival found nothing parked — the note stayed at the end of the book,
    /// far below the page, its row never near enough to mount its editor.
    @Test func theMintsLandingSurvivesEntriesArrivingAfterTheAct() async throws {
        try await withMintLandingBook(posts: 40) { session, db, readingID, postIDs, _ in
            // Ordered by creation: the new note is shown last whatever its
            // stored position (the pin is about the landing, not the place).
            try session.operations.setReadingSort(readingID, field: .createdAt, direction: .asc)
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await entries(db, readingID))
            let structure = BookStructureModel(session: session, readingID: readingID)
            structure.adopt(try await snapshot(db, readingID))
            BookOutlineGeometry.forgetAnchorTops()

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: Self.windowWidth, height: Self.windowHeight),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let theme = ThemeStore(session: session)
            @MainActor func view(_ token: UUID?) -> some View {
                BookView(
                    session: session, readingID: readingID, model: model, structure: structure,
                    mintRequest: token, onMintRequestConsumed: {})
                    .environment(theme)
            }
            let hosting = NSHostingView(rootView: AnyView(view(nil)))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { anchorTop(postIDs[0]) != nil })
            // The premise: the book's end is far below the page.
            #expect((anchorTop(postIDs[39]) ?? 0) > Self.windowHeight,
                    "the last card starts below the fold: \(anchorTop(postIDs[39]) ?? -1)")

            // ⌥⌘N — the act runs; its turn (and a few more) pass on the old entries.
            hosting.rootView = AnyView(view(UUID()))
            await settle(window, hosting, until: { model.focusedPostID != nil })
            let minted = try #require(model.focusedPostID, "the act minted and focused a note")
            #expect(!postIDs.contains(minted))
            await settle(window, hosting, until: { false }, maxTurns: 8)

            // The entries arrive, holding the new note.
            await model.adopt(try await entries(db, readingID))
            await settle(window, hosting, until: {
                onThePage(minted) && liveWithTheCaret(minted, session: session, window: window)
            }, maxTurns: 180)

            #expect(onThePage(minted),
                    "the new note's row is on the page — not left at the book's end: top \(anchorTop(minted) ?? -1)")
            #expect(liveWithTheCaret(minted, session: session, window: window),
                    "the new note is live and holds the caret (editing: \(session.editorRouter.editing?.postID ?? "nothing"))")
        }
    }
}
