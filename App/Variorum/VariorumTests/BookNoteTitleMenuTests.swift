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
        // VX-808 merge-in (JUSTIFIED EDIT): VX-803's Pin to Top / Unpin rode
        // the retired `outlineChapterMenu` beside Move to Chapter (A-808-12
        // (h)); it rides the structure group here, the pair otherwise unchanged.
        #expect(BookNoteTitleMenuTable.structureDoors.flatMap(\.capabilities)
                == [.fileNoteInChapter, .pinNoteInBook, .removeFromBook],
                "the shipped pair, with the pin beside Move to Chapter")
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
        // VX-808 merge-in (JUSTIFIED EDIT): the pin beside Move to Chapter,
        // before the divider — `outlineChapterMenu`'s shipped order (A-808-12 (h)).
        #expect(BookNoteTitleMenuTable.groups(Self.allRoads) == [
            [.openBeside, .openInNewWindow, .star],
            [.rename, .wingDoors, .export],
            [.moveToChapter, .pin],
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
        #expect(!doors.contains(.moveToChapter) && !doors.contains(.removeFromBook)
                && !doors.contains(.pin))
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

    // MARK: - The five sites (grep form — a menu is not evaluated by the test host)

    /// ONE builder, its four right-click sites (Outline's header and card, the
    /// navigator's note rows, the collapsed one-note chapter row); the old
    /// builder is gone; the book hosts the asks; the composition hands the
    /// roads. **VX-901 (the VX-914 run, batch 3 — A JUSTIFIED EDIT):** this
    /// pin held A-878-1's sub-choice 3, "the Index row's ⋯ stays as shipped",
    /// which her walkthrough ruling supersedes ("the index ... line should get
    /// the same options") — so the Index row's ⋯ is now the builder's FIFTH
    /// site, drawing the DERIVED face with the book's own asks and roads, and
    /// its hand-built copy of the structure doors is gone.
    @Test func theOneBuilderDrawsAtItsFourSitesAndTheIndexDrawsItsDerivedFace() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        func source(_ path: String) throws -> String {
            try String(contentsOf: appRoot.appending(path: "Variorum/" + path), encoding: .utf8)
        }
        let book = try source("Features/BookView/BookView.swift")
        #expect(book.components(separatedBy: "BookNoteTitleMenu(").count - 1 == 4, "four sites")
        #expect(!book.contains("outlineChapterMenu("), "the old builder is gone")
        #expect(book.contains(".bookNoteTitleAsks(noteDoors, session: session, wings: wings)"))
        #expect(book.contains("noteDoors: noteDoors, noteRoads: noteRoads)"),
                "the book hands the Index its hosted asks and the composition's roads")
        let root = try source("RootView.swift")
        #expect(root.contains("noteRoads: BookNoteRoads("), "the composition hands the roads")
        let index = try source("Features/BookView/BookIndexView.swift")
        #expect(index.components(separatedBy: "BookNoteTitleMenu(").count - 1 == 1,
                "the Index row's ⋯ is the builder's fifth site")
        #expect(index.contains("face: .indexRow"), "… drawing the derived face")
        #expect(!index.contains("chapterFilingMenu"), "the Index's own hand-built menu is gone")
        #expect(!index.contains("RemoveFromBookDoor.remove(") && !index.contains("PinNoteDoor.setPinned("),
                "no structure door is hand-copied in the Index any more")
    }

    // MARK: - VX-901: the Index face, DERIVED (the VX-829 two-faces precedent)

    private static func facts(
        _ kind: ReadingKind?, beside: Bool, window: Bool, star: Bool
    ) -> BookNoteTitleFacts {
        BookNoteTitleFacts(
            bookKind: kind, canOpenBeside: beside, canOpenInNewWindow: window, canStar: star)
    }

    /// **The derivation over every fact**: on every book kind (book,
    /// gathering, not read yet) × every subset of the composition's roads,
    /// the Index face is EXACTLY the title menu's groups with the Index's own
    /// pair at the head of the first (opening) group — or, where no opening
    /// door drew, as a group of its own above the rest. So a door added to the
    /// note-title menu reaches the Index by construction.
    @Test func theIndexFaceIsTheTitleMenuWithItsOwnPairLeadingOverEveryFact() {
        let pair: [BookNoteTitleDoor] = [.showInOutline, .openInFullEditor]
        #expect(BookNoteTitleMenuTable.indexLocalDoors == pair)
        var checked = 0
        for kind: ReadingKind? in [.book, .gathering, nil] {
            for mask in 0..<8 {
                let facts = Self.facts(kind, beside: mask & 1 != 0, window: mask & 2 != 0, star: mask & 4 != 0)
                let title = BookNoteTitleMenuTable.groups(facts)
                let index = BookNoteTitleMenuTable.groups(facts, face: .indexRow)
                let opening = facts.canOpenBeside || facts.canOpenInNewWindow || facts.canStar
                let expected = opening
                    ? [pair + title[0]] + Array(title.dropFirst())
                    : [pair] + title
                #expect(index == expected, "\(String(describing: kind)) mask \(mask): \(index)")
                #expect(BookNoteTitleMenuTable.doors(facts, face: .indexRow)
                        == pair + BookNoteTitleMenuTable.doors(facts), "flat, the same derivation")
                #expect(BookNoteTitleMenuTable.doors(facts, face: .titleMenu)
                        == BookNoteTitleMenuTable.doors(facts), "the source face is the default")
                checked += 1
            }
        }
        #expect(checked == 24)
    }

    /// The face her ruling asked for, spelled out on a BOOK's note with every
    /// road: the Index's pair, then the note-title menu's whole set — Move to
    /// Chapter ▸ and Pin to Top kept, Remove / Release kept, Archive · Delete
    /// set apart last.
    @Test func aBooksIndexRowCarriesTheNoteTitleSetBehindItsOwnPair() {
        #expect(BookNoteTitleMenuTable.groups(Self.allRoads, face: .indexRow) == [
            [.showInOutline, .openInFullEditor, .openBeside, .openInNewWindow, .star],
            [.rename, .wingDoors, .export],
            [.moveToChapter, .pin],
            [.removeFromBook],
            [.archive, .delete],
        ])
        #expect(BookNoteTitleMenuTable.doors(Self.allRoads, face: .indexRow).last == .delete)
    }

    /// A GATHERING's Index rows: the note's own doors, NO membership row — no
    /// Move to Chapter, no Pin, no Remove and no "remove #tag" (her ruling, as
    /// built: "which tag?").
    @Test func aGatheringsIndexRowCarriesTheNoteOwnDoorsAndNoMembershipRow() {
        var facts = Self.allRoads
        facts.bookKind = .gathering
        #expect(BookNoteTitleMenuTable.groups(facts, face: .indexRow) == [
            [.showInOutline, .openInFullEditor, .openBeside, .openInNewWindow, .star],
            [.rename, .wingDoors, .export],
            [.archive, .delete],
        ])
        let acts = Set(BookNoteTitleMenuTable.doors(facts, face: .indexRow).flatMap(\.capabilities))
        #expect(!acts.contains(.removeRuleTag) && !acts.contains(.removeFromBook)
                && !acts.contains(.fileNoteInChapter) && !acts.contains(.pinNoteInBook))
    }

    /// The Index's own pair keeps its shipped words — local navigation, never
    /// a registry act (it carries no capability).
    @Test func theIndexsOwnPairKeepsItsWordsAndIsNoRegistryAct() {
        #expect(BookNoteIndexActs.showInOutlineWord == "Show in Outline")
        #expect(BookNoteIndexActs.openInFullEditorWord == "Open in the full editor")
        #expect(BookNoteTitleDoor.showInOutline.capabilities.isEmpty)
        #expect(BookNoteTitleDoor.openInFullEditor.capabilities.isEmpty)
    }

    /// **P-1's walk line for the new face** (the registry change): the Index
    /// column's `.surface` declaration IS the derived face's acts (read from
    /// the table, never a hand list), the same acts the title menu draws; each
    /// is doored `.surface` (the walk's equality,
    /// `CapabilityRegistryTests.theSurfacesRenderExactlyTheDeclaredSurfaceActs`,
    /// unions this line) and keeps its `.contextMenu` door; and the eight
    /// declarations VX-901 grew are named.
    @Test func theIndexRowsDeclarationIsTheDerivedFacesActsDooredSurface() {
        #expect(BookIndexColumn.surfaceCapabilities == BookNoteTitleMenuTable.capabilities(.indexRow))
        #expect(Set(BookNoteTitleMenuTable.capabilities(.indexRow))
                == Set(BookNoteTitleMenuTable.capabilities(.titleMenu)))
        let surface = CapabilityRegistry.doored(.surface)
        for act in BookIndexColumn.surfaceCapabilities {
            #expect(surface.contains(act), "\(act) is doored .surface (the Index row's ⋯)")
            #expect(CapabilityRegistry.capability(act).doors.contains(.contextMenu),
                    "\(act) keeps its right-click door")
        }
        for act: CapabilityID in [
            .openBeside, .openInNewWindow, .toggleStar, .renameNote, .moveNoteToWing,
            .copyNoteToWing, .exportNote, .archiveNote,
        ] {
            #expect(CapabilityRegistry.capability(act).doors.contains(.surface), "VX-901 grew \(act)")
        }
        // The structure doors the Index ⋯ always declared are still there.
        for act: CapabilityID in [.removeFromBook, .pinNoteInBook, .fileNoteInChapter, .deleteNote] {
            #expect(BookIndexColumn.surfaceCapabilities.contains(act), "\(act)")
        }
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
