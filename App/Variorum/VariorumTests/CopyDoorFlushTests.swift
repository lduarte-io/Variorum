//
//  CopyDoorFlushTests.swift
//  VariorumTests
//
//  Phase 13e, batch 7 — **E10: the copy doors' flush alignment** (the
//  KnownIssues row *"Copy doors read the store past a dirty buffer"*,
//  owner 13e).
//
//  THE MECHANISM (traced before the fix, and reproduced by every revert
//  below): the copying operations read `working_text` ROWS —
//  `copyPost` walks the store, never a surface — while the editor holds
//  keystrokes in a 500 ms autosave debounce. A copy taken inside that
//  window is minted from the PREVIOUS text, so the duplicate silently
//  lacks the sentence she had just finished typing. Nothing is lost from
//  the ORIGINAL (its own flush lands moments later); what is lost is the
//  copy's completeness, which is exactly the thing a duplicate is for.
//
//  The 13f cold review (R1-4) closed this for the ONE door it was
//  reviewing — the diverge doors, which are OFFERED at a guaranteed-dirty
//  moment — by giving `AppSession.divergeForBook` a flush-first body, and
//  recorded the rest of the family as tech debt. 13e E10 is the family
//  arriving at that same rule: the body is now `AppSession.runCopying`,
//  and every copy door runs through it.
//
//  THE PINS ARE DRIVEN AT THE DOORS, not at the entry: each view model's
//  own method is the thing the Button's action calls, and the pin asserts
//  what the STORE holds afterwards. (`MembershipChip.duplicate` is a
//  SwiftUI View's private method with no seam a pin can reach — the
//  `divergeForBook` precedent applies: the shared entry is pinned, and
//  the chip's row is a one-line route to it.)
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withCopyWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The copy that was minted beside `original` — the only other live post.
@MainActor
private func copyText(besides originalID: String, in db: AppDatabase) async throws -> String? {
    let copyID = try await db.read { db in
        try String.fetchOne(
            db,
            sql: """
                SELECT id FROM container
                 WHERE kind = 'post' AND deleted_at IS NULL AND id <> ?
                 ORDER BY created_at DESC LIMIT 1
                """,
            arguments: [originalID])
    }
    guard let copyID else { return nil }
    return try await db.read { db in
        try Queries.renderPost(db, containerID: copyID).first?.text
    }
}

/// A post with one block, and a keystroke PENDING in the shared
/// coordinator's debounce — the bug's exact state.
@MainActor
private func dirtyPost(
    _ session: AppSession, text: String = "Alpha beta.", typed: String = "Alpha beta. NEW"
) throws -> (postID: String, variantID: String) {
    let post = try session.operations.createPost(title: "shared")
    let block = try session.operations.newBlock(in: post.id, text: text)
    session.autosave(forPost: post.id).record(
        variantID: block.variant.id, text: typed, charDelta: 4)
    return (post.id, block.variant.id)
}

@Suite("13e E10 — the copy doors flush first", .serialized)
@MainActor
struct CopyDoorFlushTests {
    /// **RED ON THE PRE-FIX CODE** (`await run { ops in _ = try
    /// ops.duplicateAsVersion(postID) }` — the runner with no flush): the
    /// copy carried `"Alpha beta."` while the buffer held
    /// `"Alpha beta. NEW"`.
    @Test func theLibraryDuplicateDoorCarriesThePendingText() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let stored = try await db.read { db in
                try Queries.renderPost(db, containerID: post.postID).first?.text
            }
            #expect(stored == "Alpha beta.", "the premise: the store has not seen the edit yet")

            let library = LibraryViewModel(session: session)
            await library.duplicateAsVersion(postID: post.postID)

            #expect(try await copyText(besides: post.postID, in: db) == "Alpha beta. NEW",
                    "the duplicate carries what she just typed — the flush ran first")
            #expect(library.lastError == nil)
        }
    }

    /// The same door from the POOL's rows — one view model, two surfaces
    /// (the Library catalog and the Pool listing both call it), so this is
    /// the same pin's other caller rather than a second mechanism.
    @Test func thePoolRowsDuplicateIsTheSameDoor() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session, text: "Scrap one.", typed: "Scrap one. MORE")
            let library = LibraryViewModel(session: session)
            await library.duplicateAsVersion(postID: post.postID)
            #expect(try await copyText(besides: post.postID, in: db) == "Scrap one. MORE")
        }
    }

    /// **RED ON THE PRE-FIX CODE**: the takes board's own "Duplicate as
    /// Version" row. Its panes are LIVE editors, so this is the door most
    /// likely to be pressed with an unflushed buffer under the ring.
    @Test func theBoardsDuplicateDoorCarriesThePendingText() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session, text: "Board text.", typed: "Board text. NEW")
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "CopyDoorFlushTests.\(UUID().uuidString)")!)
            await model.duplicateAsVersion()

            #expect(try await copyText(besides: post.postID, in: db) == "Board text. NEW")
            #expect(model.statusMessage == nil)
        }
    }

    /// **RED ON THE PRE-FIX CODE**: `promoteLens` copies the post its lens
    /// belongs to, so it carries the identical hazard — the row named it by
    /// name.
    @Test func promotingALensCarriesThePendingText() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session, text: "Lensed.", typed: "Lensed. NEW")
            let lens = try session.operations.createLens(post: post.postID, name: "A way")
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "CopyDoorFlushTests.\(UUID().uuidString)")!)
            model.addLensColumn(lens.id)
            let column = try #require(model.columns.last)
            await model.promoteColumn(column.id)

            #expect(try await copyText(besides: post.postID, in: db) == "Lensed. NEW")
        }
    }

    /// The chip's row and every future copy door: the ENTRY itself flushes,
    /// which is what makes routing a door to it a fix rather than a promise.
    /// (`MembershipChip.duplicate` and `AppSession.divergeForBook` are both
    /// one-line calls to this.)
    @Test func theSharedCopyEntryFlushesBeforeItRuns() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session, text: "Chip text.", typed: "Chip text. NEW")
            let result = try await session.runCopying(from: post.postID) { ops in
                try ops.duplicateAsVersion(post.postID)
            }
            let copied = try await db.read { db in
                try Queries.renderPost(db, containerID: result.post.id).first?.text
            }
            #expect(copied == "Chip text. NEW")
        }
    }

    /// **R2-1 (13l, the end-of-phase ladder round 2): the entry flushes what
    /// exists and MINTS NOTHING.** LR-MINOR-2's mechanism at a second door —
    /// `autosave(forPost:)` mints on a miss, so every duplicate of a Library
    /// or Pool row this session never opened left a permanent map entry for
    /// `flushEveryOpenPost` to walk and a ⌘Q closure for a post no surface
    /// holds. The copy is asserted too, so the pin cannot pass on a door that
    /// simply stopped working.
    ///
    /// **Red on old** (behavioural revert to `autosave(forPost: postID)
    /// .flushNow()`): both counts move 0 → 3.
    @Test func duplicatingANeverOpenedRowMintsNothing() async throws {
        try await withCopyWorld { session, db in
            let entriesBefore = session.openAutosaveCount
            let quitBefore = session.quitFinalize.count

            // Three notes this session has never opened — the Library-row
            // and Pool-row case the entry's own doc names.
            let strangers = try await session.runner.run { (ops: Operations) -> [String] in
                try (0..<3).map { index -> String in
                    let post = try ops.createPost(title: "row \(index)")
                    _ = try ops.newBlock(in: post.id, text: "Row \(index) text.")
                    return post.id
                }
            }
            for postID in strangers {
                _ = try await session.runCopying(from: postID) { ops in
                    try ops.duplicateAsVersion(postID)
                }
            }

            let copies = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container
                         WHERE kind = 'post' AND deleted_at IS NULL
                        """) ?? 0
            }
            #expect(copies == 6, "they really were duplicated — the pin is about the cost")

            #expect(session.openAutosaveCount == entriesBefore,
                    "no coordinator was minted for a post nothing ever opened")
            #expect(session.quitFinalize.count == quitBefore,
                    "and no ⌘Q closure was left behind for it")
        }
    }

    /// **THE SWEEP'S FIND, pinned like the rest** (13e E10's class walk):
    /// `poolDragCopy` reads the SOURCE block's `working_text` too, and the
    /// source is a scrap that may be open in its own editor. The dropping
    /// editor is handed a block id, not a container, so the family's
    /// block-shaped entry flushes every open post.
    @Test func aScrapDraggedInCarriesItsOwnPendingText() async throws {
        try await withEditor { h in
            let pool = try h.session.operations.createPool(title: "Snippets")
            let scrap = try h.session.operations.newBlock(in: pool.id, text: "Scrap.")
            // The scrap's own editor holds a keystroke: its container is the
            // POOL, which the dropping editor cannot name.
            h.session.autosave(forPost: pool.id).record(
                variantID: scrap.variant.id, text: "Scrap. TYPED", charDelta: 6)

            #expect(h.model.poolDrop(blockID: scrap.block.id, atOffset: 0, includeFan: false))
            var copied: String?
            for _ in 0..<400 {
                copied = try h.storeSlots().first(where: { $0.text?.hasPrefix("Scrap.") == true })?.text
                if copied != nil { break }
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(copied == "Scrap. TYPED",
                    "the dropped copy carries the scrap's pending text")
        }
    }
}

// MARK: - 17b P7 (RUN A, batch A1) — THE BRANCH DOORS

/// **17b P7 — the boards' branch / ＋ new take / ⌘T doors copied the STORE
/// past a dirty buffer, while Write's identical gesture flushed first.**
///
/// THE MECHANISM (traced, then reproduced by the revert named on each
/// test): a live take pane is buffer-authoritative — `paneEdited` writes to
/// the authority and `AutosaveCoordinator.record`, whose debounce is 500 ms
/// — so the `variant` row lags the screen for up to half a second. ⌘T
/// routes to `branchTakeRevealed` → `branchTake` → a bare
/// `session.runner.run { ops.branchVariant(...) }`, and `branchVariant`
/// copies the SOURCE ROW's `working_text` inside the transaction. So the
/// minted take was a copy of the text as it stood before the last
/// sentence, the ring then moved onto that card, and the two takes
/// diverged permanently on words she never chose to drop.
///
/// This contradicts OverallModel §3 — *"Branching a variant INHERITS the
/// current buffer's text"* — and the app's own flush-first doctrine:
/// `EditorViewModel.mintCaretTake` awaits `autosave.flushNow()` before the
/// same operation, and the phone's `branchDisplayed` was given the same
/// flush at the mobile Stage-2 ladder for this exact mechanism. One
/// gesture meant two different things depending on which surface issued it.
///
/// The fix is the copy family's ONE entry (`AppSession.runCopying`), which
/// already exists for exactly this hazard — a branch mints a copy, so it
/// belongs to the family the 13e E10 sweep drew the line around.
@Suite("17b P7 — the branch doors flush first", .serialized)
@MainActor
struct BranchDoorFlushTests {
    /// The fan's takes, oldest first.
    private func fanTexts(_ db: AppDatabase, blockID: String) async throws -> [String] {
        try await db.read { database in
            try String.fetchAll(
                database,
                sql: """
                    SELECT working_text FROM variant
                     WHERE block_id = ? AND deleted_at IS NULL
                     ORDER BY fan_position, id
                    """,
                arguments: [blockID])
        }
    }

    private func blockID(_ db: AppDatabase, postID: String) async throws -> String {
        try await db.read { try Queries.renderPost($0, containerID: postID).first?.blockID ?? "" }
    }

    /// **RED ON OLD** (restore `try await session.runner.run { ops in try
    /// ops.branchVariant(...) }` in `TakesViewModel.branchTake`): the
    /// minted take read `"Alpha beta."` while the pane showed
    /// `"Alpha beta. NEW"`.
    @Test func newTakeBranchCarriesThePendingKeystrokes() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)

            let minted = try #require(await model.branchTake(
                blockID: blockID, from: post.variantID))

            let texts = try await self.fanTexts(db, blockID: blockID)
            #expect(texts.contains("Alpha beta. NEW"),
                    "the branch inherits the CURRENT buffer (OverallModel §3)")
            let mintedText = try await db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.id])
            }
            #expect(mintedText == "Alpha beta. NEW", "and it is the MINT that carries it")
            #expect(model.statusMessage == nil, "no refusal spoken")
        }
    }

    /// ⌘T's real route on the Takes board — the door the keyboard presses.
    @Test func theRoutedCommandTakesTheSameRoad() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)
            model.host = .takes

            let minted = try #require(await model.branchTakeRevealed(
                blockID: blockID, from: post.variantID))

            let mintedText = try await db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.id])
            }
            #expect(mintedText == "Alpha beta. NEW")
        }
    }

    /// The LENSES board's "diverge here" core — the same mint into a
    /// column's pick. **RED ON OLD** (the bare runner in
    /// `branchIntoColumn`).
    @Test func theLensesColumnBranchCarriesThePendingKeystrokes() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)
            model.host = .lenses
            model.addScratchColumn()
            let columnID = try #require(model.columns.last?.id)

            let minted = try #require(await model.branchTakeRevealed(
                blockID: blockID, from: post.variantID, preferredColumnID: columnID))

            let mintedText = try await db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.id])
            }
            #expect(mintedText == "Alpha beta. NEW")
        }
    }

    /// "+ Column → write new takes" and its two siblings all ride
    /// `branchAllFans`, which mints a per-block branch from the SHOWN
    /// take's `working_text`. **RED ON OLD** (the bare runner in
    /// `addWriteColumn`).
    @Test func writingNewTakesOnEveryBlockCarriesThePendingKeystrokes() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)

            await model.addWriteColumn()

            let texts = try await self.fanTexts(db, blockID: blockID)
            #expect(texts.contains("Alpha beta. NEW"),
                    "the whole-post write door inherits the buffer too")
        }
    }

    @Test func theTakesTabsWriteNewTakesEverywhereDoorCarriesThemToo() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)

            await model.writeNewTakesEverywhere()

            let texts = try await self.fanTexts(db, blockID: blockID)
            #expect(texts.contains("Alpha beta. NEW"))
        }
    }

    @Test func replacingAColumnWithANewWriteCarriesThemToo() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)
            let columnID = try #require(model.columns.first?.id)

            await model.replaceColumnWithNewWrite(columnID)

            let texts = try await self.fanTexts(db, blockID: blockID)
            #expect(texts.contains("Alpha beta. NEW"))
        }
    }

    /// **THE SWEEP'S NEGATIVE HALF, pinned so the line is visible:** a
    /// BLANK take reads no stored text at all (`newBlankVariant` mints
    /// `''`), so it is not in this class and deliberately keeps the bare
    /// runner — flushing before every board door would make every gesture
    /// pay for a hazard only the copying ones carry (`runCopying`'s own
    /// stated reason). The pending keystrokes still reach their OWN take,
    /// which is what matters: nothing is lost either way.
    @Test func aBlankTakeMintsEmptyAndLeavesThePendingTextOnItsOwnTake() async throws {
        try await withCopyWorld { session, db in
            let post = try dirtyPost(session)
            let blockID = try await self.blockID(db, postID: post.postID)
            let model = TakesViewModel(
                session: session, postID: post.postID,
                defaults: UserDefaults(suiteName: "BranchDoorFlushTests.\(UUID().uuidString)")!)

            let minted = try #require(await model.newBlankTake(blockID: blockID))

            let mintedText = try await db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.id])
            }
            #expect(mintedText == "", "a blank take is blank — it copies nothing")

            await session.autosave(forPost: post.postID).flushNow()
            let sourceText = try await db.read { database in
                try String.fetchOne(
                    database, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [post.variantID])
            }
            #expect(sourceText == "Alpha beta. NEW", "her keystrokes landed where she typed them")
        }
    }
}
