//
//  BookNoteTitleMenuTests.swift
//  VariorumTests
//
//  VX-802 (the VX-878 run, batch 1 — her 2026-11-04 ask: "when you right
//  click on a note title, you should be able to rename or delete it, at
//  least"; the ruling A-878-1, PROVISIONAL D-802-1). A ruled BUILD (an
//  Improvement — no red-on-old owed; the walk captures the menu): the pins fix
//  the note-title menu's door set per book kind, its words' source (the note
//  rows' own grammar — a SUBSET, never a new vocabulary), the ruled left-offs,
//  its four right-click sites, and the asks' acts on the shared roads.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withMenuWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 802))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-802 — the book views' note-title menu", .serialized)
struct BookNoteTitleMenuTests {
    private static let allRoads = BookNoteTitleFacts(
        bookKind: .book, canOpenBeside: true, canOpenInNewWindow: true, canStar: true)

    // MARK: - The vocabulary

    /// **The subset pin** (A-878-1: "every label from its existing registry
    /// declaration"): the menu's note doors are the note rows' grammar — the
    /// shared note-row declaration plus the sidebar note rows' own acts —
    /// never a new act; its structure pair is the shipped one; and every act
    /// it draws is declared on the book view and doored for a context menu.
    @Test func theNoteDoorsAreASubsetOfTheNoteRowVocabulary() {
        let noteRowVocabulary = Set(SidebarView.contextMenuCapabilities)
            .union(SidebarView.noteRowMenuCapabilities)
        let noteDoorActs = Set(BookNoteTitleMenuTable.noteDoors.flatMap(\.capabilities))
        #expect(noteDoorActs.isSubset(of: noteRowVocabulary),
                "beyond the note rows' grammar: \(noteDoorActs.subtracting(noteRowVocabulary))")
        #expect(noteDoorActs == [
            .openBeside, .openInNewWindow, .toggleStar, .renameNote, .moveNoteToWing,
            .copyNoteToWing, .exportNote, .archiveNote, .deleteNote,
        ])
        #expect(BookNoteTitleMenuTable.structureDoors.flatMap(\.capabilities)
                == [.fileNoteInChapter, .removeFromBook], "the shipped pair, unchanged")
        let declared = Set(BookView.contextMenuCapabilities)
        for act in BookNoteTitleMenuTable.capabilities {
            #expect(declared.contains(act), "\(act) is declared on the book view")
            #expect(CapabilityRegistry.capability(act).doors.contains(.contextMenu), "\(act)")
        }
    }

    /// The ruled left-offs (A-878-1): the Open list's own acts, the Library
    /// row's own doors, a gathering's "remove #tag" — none is ever drawn.
    @Test func theRuledLeftOffsAreNeverDrawn() {
        let drawn = Set(BookNoteTitleMenuTable.capabilities)
        for act: CapabilityID in [
            .closeNote, .closeAllNotes, .duplicateNoteWithTags, .duplicateNoteWithoutTags,
            .mcpShareHere, .tagNote, .removeRuleTag,
        ] {
            #expect(!drawn.contains(act), "\(act) stays off (A-878-1)")
        }
    }

    // MARK: - The set per book kind

    /// A BOOK's note: the note's own doors, the shipped structure pair, then
    /// Archive · Delete set apart — Delete the very last.
    @Test func aBooksNoteCarriesItsOwnDoorsTheStructurePairAndDeleteLast() {
        #expect(BookNoteTitleMenuTable.groups(Self.allRoads) == [
            [.openBeside, .openInNewWindow, .star],
            [.rename, .wingDoors, .export],
            [.moveToChapter],
            [.removeFromBook],
            [.archive, .delete],
        ])
        #expect(BookNoteTitleMenuTable.doors(Self.allRoads).last == .delete)
        #expect(BookNoteTitleMenuTable.doors(Self.allRoads).contains(.rename),
                "her minimum: rename …")
        #expect(BookNoteTitleMenuTable.doors(Self.allRoads).contains(.delete), "… and delete")
    }

    /// A GATHERING's note: the note's OWN doors ride (they are the note's
    /// acts, not membership's); the membership rows stay exactly as today —
    /// none (no Move to Chapter, no Remove, no "remove #tag").
    @Test func aGatheringsNoteCarriesItsOwnDoorsAndNoMembershipRow() {
        var facts = Self.allRoads
        facts.bookKind = .gathering
        #expect(BookNoteTitleMenuTable.groups(facts) == [
            [.openBeside, .openInNewWindow, .star],
            [.rename, .wingDoors, .export],
            [.archive, .delete],
        ])
    }

    /// A book not read yet draws no structure door (its kind is unknown —
    /// the shipped rule); the note's own doors need no book.
    @Test func anUnreadBookDrawsNoStructureDoor() {
        let doors = BookNoteTitleMenuTable.doors(BookNoteTitleFacts(bookKind: nil))
        #expect(!doors.contains(.moveToChapter) && !doors.contains(.removeFromBook))
        #expect(doors == [.rename, .wingDoors, .export, .archive, .delete])
    }

    /// The composition's roads draw their doors only where they arrived (a
    /// harness mount has none — P-2: a door that cannot act is not drawn).
    @Test func theRoadDoorsDrawOnlyWhereTheirRoadsArrived() {
        let bare = BookNoteTitleMenuTable.doors(BookNoteTitleFacts(bookKind: .book))
        #expect(!bare.contains(.openBeside) && !bare.contains(.openInNewWindow) && !bare.contains(.star))
        #expect(bare.first == .rename)
        let starOnly = BookNoteTitleMenuTable.doors(BookNoteTitleFacts(bookKind: .book, canStar: true))
        #expect(starOnly.first == .star)
    }

    // MARK: - The four sites (grep form — a context menu is not evaluated by the test host)

    /// ONE builder, its four right-click sites (Outline's header and card, the
    /// navigator's note rows, the collapsed one-note chapter row); the old
    /// builder is gone; the book hosts the asks; the composition hands the
    /// roads; the Index row's ⋯ stays as shipped (A-878-1's sub-choice 3).
    @Test func theOneBuilderDrawsAtItsFourSitesAndTheIndexStaysAsShipped() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        func source(_ path: String) throws -> String {
            try String(contentsOf: appRoot.appending(path: "Variorum/" + path), encoding: .utf8)
        }
        let book = try source("Features/BookView/BookView.swift")
        #expect(book.components(separatedBy: "BookNoteTitleMenu(").count - 1 == 4, "four sites")
        #expect(!book.contains("outlineChapterMenu("), "the old builder is gone")
        #expect(book.contains(".bookNoteTitleAsks(noteDoors, session: session, wings: wings)"))
        let root = try source("RootView.swift")
        #expect(root.contains("noteRoads: BookNoteRoads("), "the composition hands the roads")
        let index = try source("Features/BookView/BookIndexView.swift")
        #expect(!index.contains("BookNoteTitleMenu("), "the Index row's ⋯ is unchanged")
    }

    // MARK: - The asks' acts (the shared roads)

    /// Rename… seeds the STORED title and runs the one body (a blank stores
    /// NULL — the note reads "Untitled" again).
    @Test func renameSeedsTheStoredTitleAndRunsTheOneBody() async throws {
        try await withMenuWorld { session, db in
            let note = try session.operations.createPost(title: "draft")
            let doors = BookNoteTitleDoors()
            await doors.beginRename(session: session, postID: note.id)
            #expect(doors.renameTarget == note.id && doors.renameTitle == "draft")

            await doors.rename(session: session, postID: note.id, title: "  the essay  ")
            #expect(try await db.read { try Queries.containerTitle($0, id: note.id) } == "the essay")
            await doors.rename(session: session, postID: note.id, title: "   ")
            #expect(try await db.read { try Queries.containerTitle($0, id: note.id) } == nil,
                    "a blank stores NULL")
        }
    }

    /// Delete Note… raises the one shared ask for this note.
    @Test func deleteRaisesTheOneSharedAsk() async throws {
        try await withMenuWorld { session, _ in
            let note = try session.operations.createPost(title: "draft")
            let doors = BookNoteTitleDoors()
            await doors.askDelete(session: session, postID: note.id)
            #expect(doors.pendingDelete?.postIDs == [note.id])
        }
    }

    /// Archive archives the note and says where it went (ledger row 25); in a
    /// book the note stays a member (the book's archived line).
    @Test func archiveArchivesAndSaysWhereTheNoteWent() async throws {
        try await withMenuWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Essays", kind: .book)
            let note = try ops.createPost(title: "draft")
            _ = try ops.addPostToReading(note.id, to: book.id)
            let doors = BookNoteTitleDoors()
            await doors.archive(session: session, postID: note.id)
            #expect(try await db.read { try Container.fetchOne($0, key: note.id) }?.archivedAt != nil)
            #expect(session.status.spoken?.text == RecoveryCopy.archivedNoteReceipt)
            let stillMember = try await db.read { db in
                try ReadingPost.filter(Column("reading_id") == book.id && Column("post_id") == note.id
                    && Column("deleted_at") == nil).fetchCount(db)
            }
            #expect(stillMember == 1, "membership is a fact — the note stays the book's")
        }
    }

    /// The Library's rename runs the SAME body (hoisted to `NoteRename`).
    @Test func theLibrarysRenameRunsTheSameBody() async throws {
        try await withMenuWorld { session, db in
            let note = try session.operations.createPost(title: "draft")
            let library = LibraryViewModel(session: session)
            await library.rename(postID: note.id, title: "  kept  ")
            #expect(try await db.read { try Queries.containerTitle($0, id: note.id) } == "kept")
        }
    }
}
