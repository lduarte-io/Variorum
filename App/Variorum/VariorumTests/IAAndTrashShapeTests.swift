//
//  IAAndTrashShapeTests.swift
//  VariorumTests
//
//  **THE POST-13L POLISH ROUND, BATCH 2 — the IA pass + the Trash reshaped.**
//
//  Her rulings under test, by ledger row:
//
//  · **7 (B1)** — the Library's ⋯ menu dissolves into a trash icon; the
//    tutorial door is Help's alone.
//  · **8 (B2)** — Archived is its OWN sidebar surface, archived NOTES only,
//    with its own search; version history never lists there (the V1
//    classifier's exclusion, built before the versions exist).
//  · **3 + 22 (A3 + G7)** — Trash rows name their context by GROUPING under
//    the note they came from, and stranded ancestors nest under the deletion
//    that stranded them.
//  · **11 (D1)** — takes never row in the global Trash; the data and the
//    clock are untouched.
//  · **21 (G6)** — Empty Trash purges exactly what it rows, and says out
//    loud that sparing a take is not keeping it.
//  · **18 (G3)** — "unplaced" never reaches her eyes.
//  · **25 (found-item 2)** — the archive-a-note door is declared, and it says
//    where the note went.
//

import AppKit
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The IA pass & the Trash's new shape (the post-13l polish round, batch 2)")
struct IAAndTrashShapeTests {

    // MARK: - Row 7 (B1): the masthead

    /// **THE ⋯ MENU IS GONE AND THE TRASH HAS THE ICON.**
    ///
    /// `mastheadDoors` is what the header ITERATES, so this drives the
    /// decision the view makes rather than a constant standing beside it.
    /// The tutorial's absence is pinned two ways: it is not a masthead door,
    /// and the view no longer carries an `onOpenTutorial` callback at all —
    /// a fact the compiler keeps, since `RootView` builds this view without
    /// one.
    ///
    /// **RED ON OLD** by behavioural revert (restore the `Menu { … }` with
    /// its two `Button`s and drop `mastheadDoors`): the file does not
    /// compile, which is the strongest possible reading of "this door moved".
    @Test func theLibraryMastheadCarriesTheTrashIconAndNoTutorialDoor() {
        #expect(LibraryCatalogView.mastheadDoors == [.trash])
        let trash = LibraryCatalogView.MastheadDoor.trash
        #expect(trash.destination == .recovery)
        #expect(trash.icon == "trash")
        // 13f W10a: the label is the door's ONE name, so the copy that points
        // here and the door itself cannot drift.
        #expect(trash.label == RecoveryPath.menuLabel)
        #expect(trash.label == RecoveryCopy.trashSection)
        // …and nothing in the masthead opens the tutorial: its door is Help's
        // (`EditorCommands`' Help group) and ⌘K's row.
        #expect(!LibraryCatalogView.mastheadDoors.contains { $0.label.contains("Tutorial") })
    }

    // MARK: - Row 8 (B2): Archived is its own room

    /// The sidebar destination exists, names itself from the one home, and is
    /// a PLACE rather than a note (so nothing tries to star it or treat it as
    /// a container).
    @Test func archivedIsItsOwnSidebarDestination() {
        #expect(SidebarSelection.archived.noteID == nil)
        #expect(WorkspaceNaming.label(for: .archived, titles: [:])
                == RecoveryPath.archivedSurface)
        #expect(RecoveryPath.archivedSurface == RecoveryCopy.archivedSection)
        #expect(StarTargeting.target(for: .archived) == nil, "a place is not a thing to star")
        // The two halves of the old one surface are now two names.
        #expect(RecoveryPath.menuLabel != RecoveryPath.archivedSurface)
    }

    /// Her "search it separately" half: a NAME filter over this listing, and
    /// it is a pure rule so it can be driven without mounting.
    @Test func theArchivedSurfaceSearchesItsOwnListing() {
        let items = [
            Queries.TimelineItem(
                postID: "a", title: "Orbits and endings", entryDate: nil, stamp: "s"),
            Queries.TimelineItem(
                postID: "b", title: nil, entryDate: "2026-03-04", stamp: "s"),
        ]
        #expect(ArchivedView.matches(items, query: "").count == 2, "no query narrows nothing")
        #expect(ArchivedView.matches(items, query: "   ").count == 2, "…nor does whitespace")
        #expect(ArchivedView.matches(items, query: "orbit").map(\.postID) == ["a"],
                "case-insensitive on the title")
        #expect(ArchivedView.matches(items, query: "2026-03").map(\.postID) == ["b"],
                "…and on the date a nameless note is known by")
        #expect(ArchivedView.matches(items, query: "nothing here").isEmpty)
    }

    /// A note ARCHIVED lands in the archived listing and nowhere near the
    /// Trash — the distinction her B2 direction split the surface over, driven
    /// through the real observation.
    @Test func anArchivedNoteListsInArchivedAndNeverInTheTrash() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let archived = try await editor.session.runner.run { (ops: Operations) -> String in
                let post = try ops.createPost(title: "set aside")
                _ = try ops.newBlock(in: post.id, text: "Prose.")
                try ops.archiveContainer(post.id)
                return post.id
            }
            let model = RecoveryViewModel(session: editor.session)
            let running = Task { await model.startArchived() }
            defer { running.cancel() }
            for _ in 0..<400 {
                if !model.archived.isEmpty { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(model.archived.map(\.postID) == [archived])

            let trash = try await editor.database.read { [now = editor.session.now] db in
                try Queries.trash(db, now: now)
            }
            #expect(!trash.contains { $0.id == archived },
                    "archive has no clock — it is not a deletion")
        }
    }

    // MARK: - Row 11 (D1): takes leave the global Trash

    /// **A DELETED TAKE NEVER ROWS IN THE TRASH — AND IS STILL DELETED.**
    ///
    /// Her words: *"I feel like takes should never appear in trash or archived
    /// alone - even if their parent block is live, it's really hard without
    /// context and a take alone is so small."* What comes out is the LISTING;
    /// the tombstone, the clock and the way back are untouched, which is what
    /// the second half of this pin checks against the store itself.
    ///
    /// **RED ON OLD** by behavioural revert (`TrashScope.listedKinds` back to
    /// `Set(Queries.TrashItem.Kind.allCases)`, or `startTrash` back to asking
    /// the enum): the take rows and the first expectation reds.
    @Test func aDeletedTakeIsAbsentFromTheTrashListingButNotFromTheStore() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let slot = try #require(editor.model.slots.first)
            let blockID = slot.blockID
            let second = try #require(editor.model.slots.dropFirst().first?.blockID)
            let takeID = try await editor.session.runner.run { (ops: Operations) -> String in
                let chosen = try #require(slot.variantID)
                let extra = try ops.branchVariant(blockID, from: chosen)
                try ops.deleteVariant(extra.id)
                try ops.deleteBlock(second)
                return extra.id
            }

            let model = RecoveryViewModel(session: editor.session)
            let running = Task { await model.startTrash() }
            defer { running.cancel() }
            for _ in 0..<400 {
                if !model.trash.isEmpty { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }

            #expect(!model.trash.contains { $0.kind == .take },
                    "a take alone has no context here — its home is its block's History")
            #expect(model.trash.contains { $0.kind == .block && $0.id == second },
                    "…while the block she deleted is exactly what the Trash is for")

            // The DATA is untouched: still tombstoned, still inside the
            // window, still reachable by the query that will feed the
            // block's own past surface.
            let stillDeleted = try await editor.database.read { db in
                try Bool.fetchOne(
                    db, sql: "SELECT deleted_at IS NOT NULL FROM variant WHERE id = ?",
                    arguments: [takeID]) ?? false
            }
            #expect(stillDeleted, "D1 removed a listing, never a tombstone")
            let byKind = try await editor.database.read { [now = editor.session.now] db in
                try Queries.trash(db, now: now, kinds: [.take])
            }
            #expect(byKind.contains { $0.id == takeID },
                    "the query still answers for takes — the SURFACE is what stopped asking")
        }
    }

    /// The scope is one decision, and the filter can never widen past it.
    @Test func theTrashScopeIsOneDecisionForBothSurfaces() {
        #expect(!TrashScope.listedKinds.contains(.take))
        #expect(TrashScope.listedKinds == [.note, .book, .block, .preservedOriginal])
        #expect(!TrashScope.filterKinds.contains(.take), "the picker cannot offer it either")
        #expect(TrashScope.kinds(filter: .block) == [.block])
        #expect(TrashScope.kinds(filter: nil) == TrashScope.listedKinds)
        #expect(TrashScope.kinds(filter: .take) == TrashScope.listedKinds,
                "a filter for a kind the Trash does not list widens to the listing, never to it")
        // (The phone's picker reads the same two constants — its face lives
        // in the mobile target, so its own suite is where that is asserted.)
    }

    // MARK: - Rows 3 + 22 (A3 + G7): the grouping

    private func item(
        _ kind: Queries.TrashItem.Kind, _ id: String, note: String? = nil,
        anchor: String? = nil, deletedAt: String = "2026-08-24T09:00:00.000Z"
    ) -> Queries.TrashItem {
        Queries.TrashItem(
            kind: kind, id: id, deletedAt: deletedAt, title: kind == .note ? id : nil,
            text: kind == .note ? nil : id, noteID: note, noteTitle: note,
            anchorBlockID: anchor)
    }

    /// **A NOTE'S ROWS GATHER UNDER ITS NAME** — the naming her A3 ruling
    /// asked for, said once instead of on every line (G7).
    @Test func blocksFromOneNoteGatherUnderThatNote() {
        let rows = [
            item(.block, "b1", note: "n1"),
            item(.block, "b2", note: "n1"),
            item(.book, "k1"),
        ]
        let entries = TrashGrouping.entries(rows)
        #expect(entries.count == 2)
        guard case .group(let group) = entries[0] else {
            Issue.record("the two blocks from one note gather: \(entries)")
            return
        }
        #expect(group.noteID == "n1")
        #expect(group.rows.map(\.item.id) == ["b1", "b2"])
        #expect(group.noteRow == nil, "the note is live — only its blocks are leaving")
        guard case .row(let book) = entries[1] else {
            Issue.record("a book has no note to gather under: \(entries)")
            return
        }
        #expect(book.item.id == "k1")
    }

    /// A group of ONE says less than the row it wraps — so a lone block keeps
    /// its own "from ‹note›" line and no header appears.
    @Test func aLoneBlockStaysAPlainRow() {
        let entries = TrashGrouping.entries([item(.block, "b1", note: "n1")])
        guard case .row(let row) = entries.first else {
            Issue.record("one row wants no ceremony: \(entries)")
            return
        }
        #expect(row.item.id == "b1")
        #expect(entries.count == 1)
    }

    /// When the NOTE itself is in the Trash, its own row heads the group —
    /// the note and what went with it, read as one thing.
    @Test func aDeletedNoteHeadsItsOwnGroup() {
        let entries = TrashGrouping.entries([
            item(.note, "n1"),
            item(.block, "b1", note: "n1"),
        ])
        #expect(entries.count == 1)
        guard case .group(let group) = entries[0] else {
            Issue.record("the note heads its blocks: \(entries)")
            return
        }
        #expect(group.noteRow?.id == "n1")
        #expect(group.rows.map(\.item.id) == ["b1"])
    }

    /// **HER TENTH-SITTING RULING: THE ANCESTORS NEST UNDER WHAT SHE JUST
    /// DELETED** — *"going to trash shows you what you just deleted rather
    /// than suddenly being overwhelmed by 31 random items"*.
    ///
    /// **RED ON OLD** by behavioural revert (drop the `nestedUnder` map and
    /// append every original as a top-level row): the nesting expectations
    /// red, reading back thirty-one flat rows.
    @Test func strandedAncestorsNestUnderTheDeletionThatStrandedThem() {
        let originals = (1...30).map {
            item(.preservedOriginal, "o\($0)", note: "n1", anchor: "b1")
        }
        let entries = TrashGrouping.entries([item(.block, "b1", note: "n1")] + originals)
        #expect(entries.count == 1, "one thing was deleted; it reads as one thing")
        guard case .row(let row) = entries[0] else {
            Issue.record("a lone block with its ancestors is still one row: \(entries)")
            return
        }
        #expect(row.item.id == "b1")
        #expect(row.nested.count == 30)
        #expect(row.nested.allSatisfy { $0.kind == .preservedOriginal })
    }

    /// An original whose anchor is NOT listed (windowed out, or a cascade
    /// victim) rows on its own — nesting never swallows a row.
    @Test func anOriginalWithNoListedAnchorStillRows() {
        let entries = TrashGrouping.entries([
            item(.preservedOriginal, "o1", note: "n1", anchor: "b-not-listed"),
        ])
        guard case .row(let row) = entries.first else {
            Issue.record("it must still be reachable: \(entries)")
            return
        }
        #expect(row.item.id == "o1")
        #expect(row.nested.isEmpty)
    }

    /// The listing's ORDER survives grouping: a group sits where its first
    /// row fell, so "newest first" still reads newest first.
    @Test func groupsSitWhereTheirFirstRowFell() {
        let entries = TrashGrouping.entries([
            item(.book, "k1", deletedAt: "2026-08-24T12:00:00.000Z"),
            item(.block, "b1", note: "n1", deletedAt: "2026-08-24T11:00:00.000Z"),
            item(.block, "b2", note: "n1", deletedAt: "2026-08-24T10:00:00.000Z"),
            item(.book, "k2", deletedAt: "2026-08-24T09:00:00.000Z"),
        ])
        let ids: [String] = entries.map {
            switch $0 {
            case .row(let row): return row.item.id
            case .group(let group): return group.noteID
            }
        }
        #expect(ids == ["k1", "n1", "k2"])
    }

    // MARK: - Row 21 (G6): the door takes exactly what it rows

    /// **EMPTY TRASH SPARES A TAKE ON A LIVING BLOCK — AND SAYS SO HONESTLY.**
    ///
    /// Her ruling: *"a deleted take on a living block might be the one item a
    /// user does want to keep… I just don't think a 'delete everything'
    /// button in the trash should delete items that aren't being shown."*
    /// And the caveat is hers too (*"i don't want it to be clock exempt"*):
    /// sparing is not keeping, and the confirm says which.
    ///
    /// **RED ON OLD** by behavioural revert (`emptyTrashConfirm`'s total back
    /// to `filter { $0.key != .preservedOriginal }`, and `TrashPurge.confirm`'s
    /// targets back to the same filter): the take is purged and both the
    /// survival and the sentence red.
    @Test func emptyTrashSparesADeletedTakeOnALivingBlockAndSaysWhy() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let slot = try #require(editor.model.slots.first)
            let second = try #require(editor.model.slots.dropFirst().first?.blockID)
            let takeID = try await editor.session.runner.run { (ops: Operations) -> String in
                let chosen = try #require(slot.variantID)
                let extra = try ops.branchVariant(slot.blockID, from: chosen)
                try ops.deleteVariant(extra.id)
                try ops.deleteBlock(second)
                return extra.id
            }

            let model = RecoveryViewModel(session: editor.session)
            await model.requestEmptyTrash()
            let confirm = try #require(model.pendingConfirm)
            guard case .emptyTrash(let counts) = confirm else {
                Issue.record("Empty Trash raises its counting confirm")
                return
            }
            #expect(counts[.block] == 1)
            #expect(counts[.take] == 1, "the take is COUNTED so the sentence can be honest")
            let message = confirm.message
            #expect(message.contains("1 thing goes for good"),
                    "…but the total counts only what the door takes: \(message)")
            #expect(message.contains("1 block"))
            #expect(!message.contains("1 take,"), "a take is never listed among the going")
            #expect(message.contains("stays"), "her caveat's first half: \(message)")
            #expect(message.contains("not kept"), "…and its second half")
            #expect(message.contains("\(TrashWindow.days) days"),
                    "the clock still runs — her own words")

            await model.confirmPendingPurge(confirm)
            #expect(model.lastError == nil)

            let (blockGone, takeAlive) = try await editor.database.read { db in
                (try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM block WHERE id = ?",
                    arguments: [second]) ?? 0,
                 try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE id = ?",
                    arguments: [takeID]) ?? 0)
            }
            #expect(blockGone == 0, "the door took what it rowed")
            #expect(takeAlive == 1, "…and left what it did not")
        }
    }

    /// The scope rule, stated once: which kinds the bulk door takes, and why
    /// the two it refuses are refused for two different reasons.
    @Test func theBulkDoorsScopeIsNamedRatherThanInlined() {
        #expect(TrashScope.emptyTrashTakes(.note))
        #expect(TrashScope.emptyTrashTakes(.book))
        #expect(TrashScope.emptyTrashTakes(.block))
        #expect(!TrashScope.emptyTrashTakes(.take), "G6: it is not rowed, so it is not taken")
        #expect(!TrashScope.emptyTrashTakes(.preservedOriginal),
                "round 8b: it rides its family and has no door of its own")
    }

    // MARK: - Row 18 (G3): "unplaced" never reaches her eyes

    /// The word is the MODEL's, the room it named was removed at 13j J6, and
    /// no sentence she can read says it.
    ///
    /// **RED ON OLD** by behavioural revert (restore either `putBackUnplaced`
    /// sentence): the first loop reds, reading the word back.
    @Test func noSentenceSheCanReadSaysUnplaced() {
        let sentences: [String] = [
            RecoveryCopy.putBackUnplaced(nil),
            RecoveryCopy.putBackUnplaced(.post),
            RecoveryCopy.putBackUnplaced(.pool),
            RecoveryCopy.goesWithItsFamily,
            RecoveryCopy.originalHasNoNote,
            RecoveryCopy.landingReceipt(.unplaced(home: .post)),
            RecoveryCopy.landingReceipt(.unplaced(home: .pool)),
            TrayPath.originalsPathWithDoor,
            CapabilityRegistry.capability(.showOriginBlock).unavailableNote,
        ]
        for sentence in sentences {
            #expect(!sentence.lowercased().contains("unplaced"),
                    "debug vocabulary in her face: \(sentence)")
        }
        // …and the sentences still say the TRUE thing, so the sweep did not
        // trade a bad word for a vague one.
        #expect(RecoveryCopy.putBackUnplaced(.pool).contains("scraps"))
        #expect(RecoveryCopy.putBackUnplaced(.post).contains("note"))
    }

    /// G3's presentation fold: a preserved original reads as what happened to
    /// it and how long it is kept, with the internal noun gone from the lead.
    @Test func aPreservedOriginalReadsAsWhatTheMergeDidToIt() {
        let label = RecoveryCopy.goesWithItsFamily
        #expect(label.contains("set aside"))
        #expect(label.contains("merge"))
        #expect(label.contains("family"))
        // The tray and the Trash read the SAME string — one label, two
        // surfaces (the `TrayPath` forwarder's founding rule).
        #expect(TrayPath.goesWithItsFamily == label)
        #expect(RecoveryPath.goesWithItsFamily == label)
    }

    // MARK: - Row 25 (found-item 2): the archive-a-note door

    /// The door is DECLARED, with the two renderers `.deleteNote` reaches.
    @Test func theArchiveNoteActIsDeclaredWithItsDoors() {
        let capability = CapabilityRegistry.capability(.archiveNote)
        #expect(capability.verb == "Archive")
        #expect(capability.scope == .post)
        #expect(capability.doors == [.contextMenu])
        #expect(SidebarView.contextMenuCapabilities.contains(.archiveNote))
        // Its honest note names the room the note goes to, and its promise.
        #expect(capability.unavailableNote.contains(RecoveryPath.archivedSurface))
        #expect(capability.unavailableNote.contains("no countdown"))
    }

    /// **THE ACT SAYS WHERE THE NOTE WENT.** It removes the row from the list
    /// she is standing in; in silence that reads exactly like a deletion.
    ///
    /// **RED ON OLD** by behavioural revert (drop the `receipt:` argument from
    /// `LibraryViewModel.archive`): `receipt` stays nil and this reds.
    @Test func archivingANoteNamesTheArchivedSurfaceInItsReceipt() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let postID = try await editor.session.runner.run { (ops: Operations) -> String in
                let post = try ops.createPost(title: "to set aside")
                _ = try ops.newBlock(in: post.id, text: "Prose.")
                return post.id
            }
            let library = LibraryViewModel(session: editor.session)
            await library.archive(postID: postID)
            #expect(library.lastError == nil)
            let receipt = try #require(library.receipt)
            #expect(receipt.contains(RecoveryPath.archivedSurface))
            #expect(receipt.contains("no countdown"), "the whole difference from Delete")
            #expect(!receipt.contains(RecoveryCopy.trashSection),
                    "archive is not a deletion and must not name the Trash")

            await library.unarchive(postID: postID)
            #expect(try #require(library.receipt).contains("Library"))
        }
    }
}
