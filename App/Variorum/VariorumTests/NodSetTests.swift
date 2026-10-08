//
//  NodSetTests.swift
//  VariorumTests
//
//  13g batch 7 — the pins for her round-6 nod set: tag chips on the top bar
//  (R6-1), the bottom bar's two slide-out groups (R6-2), the untitled-date
//  display rule's app half (R6-3), and the quick note's tag + smart book
//  (R6-4).
//
//  The CORE halves are pinned in `DisplayTitleTests` and `QuicknoteShelfTests`
//  (the brain, the export surfaces, the collect-and-leave semantics); these
//  are the app's own claims — what a chip is coloured, what the bar renders,
//  what the chrome says a note is called, and what one summon of the quick
//  pad leaves behind.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withStore<T>(
    _ body: @MainActor (AppDatabase, AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(db, AppSession(database: db))
    }
}

@MainActor
@Suite("The nod set (13g batch 7)", .serialized)
struct NodSetTests {

    // MARK: - R6-1: the tag chips

    /// Her ruling: *"I like it when there are little tag cards that are
    /// different colors."* The colour is the TAG's, keyed on its path
    /// through the 9d stable-hash family — so the same tag is the same
    /// colour in every note and across launches, and applying a new tag
    /// never re-ripples the ones already there.
    ///
    /// DISCRIMINATING REVERT: key `TagChipColor.hue` on `String.hashValue`
    /// instead of `BlockTint.stableHash` and the second expectation fails —
    /// Swift's hash is per-process seeded, so a tag's colour would change
    /// between launches (which is exactly why 9d wrote its own).
    @Test func aTagsColourIsItsOwnAndNeverRipples() {
        let life = TagChipColor.hue(forPath: "life/goals")
        #expect(TagChipColor.hue(forPath: "life/goals") == life)
        // Stable across processes: the value is arithmetic over the bytes,
        // so it is stated here as a literal rather than as a tautology.
        #expect(life == Double(BlockTint.stableHash("life/goals") % 360) / 360.0)
        // Different tags land on different hues (the point of a card).
        #expect(TagChipColor.hue(forPath: "work") != life)
        // A path is the key, not a leaf name: two tags called "goals" under
        // different parents are different cards.
        #expect(TagChipColor.hue(forPath: "life/goals") != TagChipColor.hue(forPath: "work/goals"))
    }

    /// The `＋` popover's autocomplete rule, pure: case-insensitive
    /// substring over PATHS, already-applied dropped, capped.
    @Test func theAdderSuggestsWhatSheHasNotAlreadyApplied() throws {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        func tag(_ path: String) -> VariorumCore.Tag {
            VariorumCore.Tag(
                id: path, name: path, path: path, createdAt: now, updatedAt: now)
        }
        let all = [tag("life"), tag("life/goals"), tag("work"), tag("Work/Deep")]

        // Empty query: everything, minus what the note already wears.
        #expect(
            TagChipAdder.suggestions(all, typed: "", applied: ["life"]).map(\.path)
                == ["life/goals", "work", "Work/Deep"])
        // Case-insensitive, and it matches ANYWHERE in the path so a leaf
        // name finds its nested tag.
        #expect(
            TagChipAdder.suggestions(all, typed: "wOr", applied: []).map(\.path)
                == ["work", "Work/Deep"])
        #expect(
            TagChipAdder.suggestions(all, typed: "goals", applied: []).map(\.path)
                == ["life/goals"])
        // Nothing matching ⇒ nothing suggested (the face then offers to MAKE
        // the typed path, which is `applyTypedPath`'s standing behaviour).
        #expect(TagChipAdder.suggestions(all, typed: "zzz", applied: []).isEmpty)
        // Capped, so a whole taxonomy never becomes a scroll in a popover.
        let many = (0..<20).map { tag("t\($0)") }
        #expect(TagChipAdder.suggestions(many, typed: "", applied: []).count == 8)
    }

    /// The bar's own rule: a pane holding a NOTE always has something to
    /// say — K11's constant row (a grey book door is still a door, and the
    /// tray badge lands here). A pane holding a place (shelf, library, a
    /// book) still renders nothing until it has been somewhere. *(The
    /// tag-door reason moved to the masthead cluster with the cards — Act
    /// 10 item 5; the note-constancy claim itself is unchanged.)*
    ///
    /// DISCRIMINATING REVERT: drop `isNote ||` from
    /// `ContextBarDoors.hasContent` and the second expectation fails.
    @Test func aNotePaneAlwaysCarriesTheBar() {
        func bar(isNote: Bool) -> ContextBar {
            ContextBar(
                tokens: .fallback(for: .light), originLabel: nil, forwardLabel: nil,
                books: [], isNote: isNote,
                onBack: {}, onForward: {}, onOpenBook: { _ in })
        }
        #expect(!bar(isNote: false).hasContent, "a place with no history says nothing")
        #expect(bar(isNote: true).hasContent, "a note always carries the row")
    }

    /// The wire: applying and removing through the chip's own doors are the
    /// standing operations, and the pane's list re-reads after each.
    @Test func theChipDoorsApplyAndRemoveThroughTheStandingOps() async throws {
        try await withStore { db, session in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "Tagged")
            }
            // The ＋'s door is `applyTypedPath` — the shipped type-to-create
            // path, hierarchy walk and all.
            let model = TagAssignmentViewModel(session: session, postID: post.id)
            _ = await model.applyTypedPath("life/goals")
            var applied = try await db.read { [id = post.id] in
                try Queries.postTags($0, postID: id).map(\.path)
            }
            #expect(applied == ["life", "life/goals"] || applied == ["life/goals"])
            #expect(applied.contains("life/goals"))

            // …and ✕ is `removeTag`, nothing more.
            let leaf = try await db.read { [id = post.id] in
                try Queries.postTags($0, postID: id).first { $0.path == "life/goals" }
            }
            let leafID = try #require(leaf?.id)
            try await session.runner.run { ops in
                try ops.removeTag(leafID, fromPost: post.id)
            }
            applied = try await db.read { [id = post.id] in
                try Queries.postTags($0, postID: id).map(\.path)
            }
            #expect(!applied.contains("life/goals"))
        }
    }

    // MARK: - R6-2: the bottom bar's two groups

    /// The regroup moved doors; it must not have LOST one. The registry
    /// walk (`theBottomBarsRenderExactlyTheDeclaredBarDoors`) is the
    /// standing guard; this states the same claim in the batch's own terms,
    /// naming the six acts that moved into `block ▾` and the one that moved
    /// into `note ▾`, so a future edit that quietly drops one from a menu
    /// fails here with its name.
    @Test func everyDoorTheGroupsSwallowedIsStillDeclaredByItsBar() {
        let write = Set(CommitBar.renderedCapabilities)
        let takes = Set(TakesBottomBar.renderedCapabilities)
        // block ▾, Write side.
        for id in [CapabilityID.divide, .extract, .makeBlock, .merge,
                   .insertBlockBelow, .deleteBlock] {
            #expect(write.contains(id), "Write's block ▾ lost \(id.rawValue)")
        }
        // block ▾, Takes side — the four structural doors moved off the flat
        // row into the group this batch.
        for id in [CapabilityID.divide, .extract, .makeBlock, .merge] {
            #expect(takes.contains(id), "Takes' block ▾ lost \(id.rawValue)")
        }
        // note ▾ carries the seal on both bars.
        #expect(write.contains(.sealPost))
        #expect(takes.contains(.sealPost))
        // And the union is still exactly the declared bottom-bar door set.
        #expect(write.union(takes) == CapabilityRegistry.doored(.bottomBar))
    }

    // MARK: - R6-3: the untitled-date rule, app side

    /// The chrome's ONE naming map now carries the DISPLAY name, so the pane
    /// line, the back chip, the Open strip and a star all say the same thing
    /// — and a NAMELESS note says its date instead of "Untitled".
    ///
    /// **UPDATED at 13k K1** (her ruling, 2026-08-02, overturning #52(a)):
    /// a note whose stored title IS the literal "Untitled" is TITLED, and
    /// the chrome says so. Only a blank title is absent now, and no sweep
    /// rewrites the legacy rows — *"i can delete them or rename them
    /// myself"*.
    ///
    /// DISCRIMINATING REVERT: put `Queries.containerTitle` back in
    /// `WorkspaceModel.resolveTitles`' `.post` arm and the second
    /// expectation fails with nil→"Untitled".
    @Test func theChromeNamesAnUntitledNoteByItsDate() async throws {
        try await withStore { db, session in
            let named = try await session.runner.run { ops in
                try ops.createPost(title: "Real name")
            }
            let bare = try await session.runner.run { ops in try ops.createPost(title: nil) }
            // The pre-13g mint's literal, exactly as it sits in her store —
            // a NAME since K1, and the chrome reads it as one.
            let legacy = try await session.runner.run { ops in
                try ops.createPost(title: "Untitled")
            }
            let resolved = try await db.read { [id = bare.id] in
                try Queries.noteDisplayTitle($0, id: id)
            }
            let day = try #require(resolved)

            let workspace = WorkspaceModel()
            workspace.select(.post(named.id))
            workspace.select(.post(bare.id))
            workspace.select(.post(legacy.id))
            await workspace.resolveTitles(session: session)

            #expect(workspace.label(for: .post(named.id)) == "Real name")
            #expect(workspace.label(for: .post(bare.id)) == day)
            #expect(workspace.label(for: .post(legacy.id)) == "Untitled")  // K1
            // An id that resolves to no row at all keeps the per-kind
            // fallback that was always there.
            #expect(workspace.label(for: .post("gone")) == "Untitled")
        }
    }

    /// The mint stops STORING the placeholder — a title she never typed was
    /// never hers. (Existing notes are carried by `DisplayTitle.isAbsent`,
    /// pinned in core.)
    @Test func aNewNoteIsMintedWithNoTitleAtAll() async throws {
        try await withStore { db, session in
            let model = LibraryViewModel(session: session)
            let id = try #require(await model.createPost())
            let stored = try await db.read { try Queries.containerTitle($0, id: id) }
            #expect(stored == nil, "the mint must not store the word \"Untitled\"")
        }
    }

    // MARK: - R6-4: the quick note's tag and its book

    /// Her ruling, end to end through the app's own door: one summon leaves
    /// a note wearing `quicknote`, and the smart book that collects the tag
    /// on the shelf.
    ///
    /// DISCRIMINATING REVERT: drop the `ops.fileAsQuicknote(...)` call from
    /// `QuickNoteMint.file` and every expectation below the mint fails — the
    /// note lands bookless and untagged, exactly as it did before this batch.
    @Test func oneSummonOfTheQuickPadFilesItselfUnderItsTag() async throws {
        try await withStore { db, session in
            let id = try #require(
                await QuickNoteMint.file("Jotted in a hurry.", session: session).postID)

            let (tags, bookID) = try await db.read { database in
                (try Queries.postTags(database, postID: id).map(\.path),
                 try Queries.quicknotesBookID(database))
            }
            #expect(tags == [Operations.quicknoteTagPath])
            let book = try #require(bookID)
            let collected = try await db.read {
                try Queries.assembleReading($0, readingID: book).map(\.postID)
            }
            #expect(collected == [id])
            // …and the note is still an ordinary bookless note in the
            // curated sense, which is what keeps the Pool listing it.
            let curated = try await db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ?",
                    arguments: [id])
            }
            #expect(curated == 0)
            // The status line says where it went, in her words' terms.
            // 18i: the filing receipt rides `spoken` (quiet by default).
            #expect(session.status.spoken?.text.contains(Operations.defaultQuicknoteBookName) == true)  // 13s-b U1b: the one name constant
        }
    }

    /// The pad's own rules are untouched by the filing: an empty summon
    /// still mints nothing, so no stray tag or book is ever created by one.
    @Test func anEmptySummonStillMintsNothingAndCreatesNoBook() async throws {
        try await withStore { db, session in
            #expect(await QuickNoteMint.file("   \n ", session: session) == .nothingToFile)
            let (posts, book) = try await db.read { database in
                (try Int.fetchOne(
                    database, sql: "SELECT COUNT(*) FROM container WHERE deleted_at IS NULL"),
                 try Queries.quicknotesBookID(database))
            }
            #expect(posts == 0)
            #expect(book == nil)
        }
    }
}
