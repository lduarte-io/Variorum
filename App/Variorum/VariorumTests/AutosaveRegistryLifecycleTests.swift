//
//  AutosaveRegistryLifecycleTests.swift
//  VariorumTests
//
//  18k C1 — the autosave-coordinator registry lets go (the 2026-09-21
//  health review §6.1; the batch record is `notes/plans/phase-18k-runtime-
//  hygiene.md` → UNIT C1 RECORD, whose trace T1–T5 these pins cite).
//
//  Every Mac surface took a coordinator through `AppSession.autosave(forPost:)`
//  and none gave it back, so the registry — and the ⌘Q/lock walk over it —
//  grew by one note for every note ANY surface touched in a session. Two
//  families of pin live here:
//
//  · THE COUNT PINS (red on the pre-fix tree): an open → navigate-away
//    cycle per surface family returns `openAutosaveCount` and
//    `quitFinalize.count` to where they started; the per-access /
//    per-call acquirers (Canvas, Compare) hold exactly ONE; the book index
//    hands back what it took; the seal fallback flushes without minting.
//
//  · THE GUARD PINS (the three verifications the brief names, plus the
//    mode switch): nothing about the release may cost a savepoint or split
//    a note's pipeline. These are GREEN on the old tree by construction —
//    it never let go of anything — and their teeth are shown against a
//    PLAIN-RELEASE mutation (a release that drops the entry the moment the
//    last holder lets go), recorded in the batch record.
//
//  How a surface "closes" here is how SwiftUI closes it: the model's
//  `teardown()` from `onDisappear`, then the last reference dropping. And
//  every surface family gets a DISCARDED TWIN — a second model built by a
//  re-init of the view struct (`State(initialValue:)` evaluates its argument
//  every time) and thrown away unmounted — because that twin acquires too
//  (trace T2), and a release that forgets it can never bring the count down.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The world

@MainActor
private func withRegistryWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A condition the spawned roads reach on their own (the leaving road and a
/// release that completes one both detach from their caller) — bounded, so a
/// pin that is red fails rather than hangs.
@MainActor
private func eventually(_ condition: @MainActor () -> Bool) async {
    for _ in 0..<400 {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// Every savepoint text under a post's live takes, oldest first.
private func savepointTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT cp.text FROM commit_point cp
                  JOIN variant v ON v.id = cp.variant_id
                  JOIN container_block cb ON cb.block_id = v.block_id
                 WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                 ORDER BY cp.created_at, cp.id
                """,
            arguments: [postID])
    }
}

private func workingText(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [variantID])
    }
}

/// A live Write editor that can actually DIE — the harness in
/// `EditorTestSupport` holds its model for the whole test, which is exactly
/// what this suite must not do. Same wiring as `withEditor`.
@MainActor
private final class MountedEditor {
    let model: EditorViewModel
    let textView: EditorTextView
    let scrollView: NSScrollView
    let surfaceDelegate: EditorSurfaceDelegate

    init(session: AppSession, database: AppDatabase, postID: String) throws {
        let model = EditorViewModel(session: session, postID: postID)
        model.tailIdleSleep = { _ in throw CancellationError() }
        model.longBlockLayout.sleep = { _ in throw CancellationError() }
        let made = EditorTextView.makeEditor()
        let surfaceDelegate = EditorSurfaceDelegate(model: model)
        surfaceDelegate.wire(to: made.textView)
        model.attach(textView: made.textView, scrollView: made.scrollView)
        let (slots, header) = try database.read { db in
            (try Queries.renderPost(db, containerID: postID),
             try Queries.containerHeader(db, containerID: postID))
        }
        model.adoptHeader(header)
        model.applyProjection(slots)
        self.model = model
        self.textView = made.textView
        self.scrollView = made.scrollView
        self.surfaceDelegate = surfaceDelegate
    }

    func type(_ text: String) {
        textView.setSelectedRange(NSRange(location: (textView.string as NSString).length, length: 0))
        textView.insertText(text, replacementRange: textView.selectedRange())
    }

    /// **The surface's death puts the process's text state back** (18k UNIT C8 —
    /// the test-isolation leak this suite introduced; the trace is the C8 RECORD
    /// in `notes/plans/phase-18k-runtime-hygiene.md`).
    ///
    /// Dropping this helper does NOT free its text stack: the dead view's
    /// `NSTextStorage` / `NSTextContentStorage` / `NSTextLayoutManager` sit in a
    /// main-thread autorelease pool the test runner keeps open under async test
    /// bodies, and live on for the rest of the run (measured: alive 3 s later;
    /// `leaks --traceTree` roots the content storage in a pool page chained to
    /// `_main_thread`). The open-tail pins leave that storage holding their
    /// TYPED text, which teardown's finalize crystallized and stamped with block
    /// id `00000000-0000-0000-0000-000000000001` — the id `.incrementing` gives
    /// every harness world's first block. AppKit uniques content-equal attribute
    /// dictionaries process-wide, so every later harness storage's first block
    /// was handed THIS storage's live dictionary (and its paragraph-style
    /// object), and AppKit's paragraph fixing in the later editor found nothing
    /// to re-apply: `MacIdentityAuditWiringTests.appKitWidensAnInsertionsReported
    /// RangeToTheParagraph` read `{2,1}` for `{2,5}` in every full run after this
    /// suite joined the target.
    ///
    /// So the helper empties its storage as it dies — the delegates detached
    /// FIRST, so the empty-out is never reported to the torn-down model as her
    /// edit (no autosave, no selection memory, no savepoint can come of it). Every
    /// assertion in this file reads the store, never the surface after this point.
    isolated deinit {
        textView.delegate = nil
        textView.textStorage?.delegate = nil
        textView.textStorage?.setAttributedString(NSAttributedString())
    }
}

// MARK: - The count pins (red on the pre-fix tree)

@Suite("18k C1 — every autosave acquisition lets go at its owner's end of life", .serialized)
@MainActor
struct AutosaveRegistryLifecycleTests {

    /// **WRITE, the ordinary road.** She opens a note, navigates away: the
    /// workspace's leaving road fires at the click, the editor unmounts after
    /// it. The note is gone from the ⌘Q/lock walk once its leaving savepoint
    /// has landed — the old tree kept it (and its twin's hold) for the session.
    @Test func writeLetsGoOnceTheNoteIsLeft() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "write")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            var model: EditorViewModel? = EditorViewModel(session: session, postID: post.id)
            _ = EditorViewModel(session: session, postID: post.id)  // the discarded twin (T2)
            #expect(session.openAutosaveCount == entries + 1, "the premise: one entry per note")

            let leaving = Task { await session.savepointOnLeaving(post.id) }
            await model?.teardown()?.value
            model = nil
            await leaving.value
            await eventually { session.openAutosaveCount == entries }

            #expect(session.autosaveHolderCount(forPost: post.id) == 0,
                    "the live editor AND its discarded twin each gave back what they took")
            #expect(session.openAutosaveCount == entries,
                    "the note left the registry once it was left — pre-fix it stayed all session")
            #expect(session.quitFinalize.count == quits,
                    "and ⌘Q / the lock no longer walk a note she left")
        }
    }

    /// The other order: the leaving savepoint lands while the editor is still
    /// alive (its finalize still running), and the editor dies AFTER. The
    /// release then completes the leaving itself — it re-takes the savepoint
    /// (the surface's last writes are in it) and the entry goes.
    @Test func writeLetsGoWhenItsEditorOutlivesTheLeaving() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "write-late")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount

            var model: EditorViewModel? = EditorViewModel(session: session, postID: post.id)
            await session.savepointOnLeaving(post.id)
            #expect(session.openAutosaveCount == entries + 1,
                    "a leaving that lands while a surface still holds the note keeps the entry")

            await model?.teardown()?.value
            model = nil
            await eventually { session.openAutosaveCount == entries }
            #expect(session.openAutosaveCount == entries,
                    "the last holder letting go of a LEFT note finishes the leaving")
        }
    }

    /// TAKES (the board, the Lenses board and the Write takes panel all build
    /// a `TakesViewModel` eagerly in their view's init).
    @Test func takesLetsGoOnceTheNoteIsLeft() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "takes")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            var model: TakesViewModel? = TakesViewModel(session: session, postID: post.id)
            _ = TakesViewModel(session: session, postID: post.id)
            let leaving = Task { await session.savepointOnLeaving(post.id) }
            model?.teardown()
            model = nil
            await leaving.value
            await eventually { session.openAutosaveCount == entries }

            #expect(session.autosaveHolderCount(forPost: post.id) == 0)
            #expect(session.openAutosaveCount == entries)
            #expect(session.quitFinalize.count == quits)
        }
    }

    /// BLOCKS and READ (both build a `BlockTOCViewModel`).
    @Test func blocksAndReadLetGoOnceTheNoteIsLeft() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "toc")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            var model: BlockTOCViewModel? = BlockTOCViewModel(session: session, postID: post.id)
            _ = BlockTOCViewModel(session: session, postID: post.id)
            let leaving = Task { await session.savepointOnLeaving(post.id) }
            model?.teardown()
            model = nil
            await leaving.value
            await eventually { session.openAutosaveCount == entries }

            #expect(session.autosaveHolderCount(forPost: post.id) == 0)
            #expect(session.openAutosaveCount == entries)
            #expect(session.quitFinalize.count == quits)
        }
    }

    /// CANVAS acquired on EVERY read of a computed property (trace T1): init,
    /// each projection delivery, each keystroke, each focus move. One model
    /// now holds exactly one, and gives it back.
    @Test func canvasHoldsExactlyOneAndLetsGo() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "canvas")
            let block = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            var model: CanvasViewModel? = CanvasViewModel(session: session, containerID: post.id)
            _ = CanvasViewModel(session: session, containerID: post.id)
            let projection = try await db.read { db in
                try Queries.canvasProjection(db, container: post.id)
            }
            for _ in 0..<3 { model?.adopt(projection) }
            model?.paneEdited(blockID: block.block.id, variantID: block.variant.id, newText: "Alpha!")
            model?.blur()
            #expect(session.autosaveHolderCount(forPost: post.id) == 1,
                    "one live canvas, one hold — pre-fix every read of `coordinator` took another")

            let leaving = Task { await session.savepointOnLeaving(post.id) }
            model?.teardown()
            model = nil
            await leaving.value
            await eventually { session.openAutosaveCount == entries }

            #expect(session.autosaveHolderCount(forPost: post.id) == 0)
            #expect(session.openAutosaveCount == entries)
            #expect(session.quitFinalize.count == quits)
        }
    }

    /// COMPARE acquired on every CALL of `coordinator(for:)` — each projection's
    /// dirty check, each settle, each keystroke — and once more per post inside
    /// its own teardown (trace T1). Now: one hold per post per board.
    @Test func compareHoldsOnePerPostAndLetsGo() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "compare")
            let block = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            var model: CompareViewModel? = CompareViewModel(session: session, anchorPostID: post.id)
            _ = CompareViewModel(session: session, anchorPostID: post.id)
            for text in ["Alpha!", "Alpha!!", "Alpha!!!"] {
                model?.paneEdited(postID: post.id, variantID: block.variant.id, newText: text)
            }
            model?.blur()
            #expect(session.autosaveHolderCount(forPost: post.id) == 1,
                    "one board, one hold on its anchor — pre-fix every call took another")

            let leaving = Task { await session.savepointOnLeaving(post.id) }
            model?.teardown()
            model = nil
            await leaving.value
            await eventually { session.openAutosaveCount == entries }

            #expect(session.autosaveHolderCount(forPost: post.id) == 0)
            #expect(session.openAutosaveCount == entries)
            #expect(session.quitFinalize.count == quits)
        }
    }

    /// The BOOK INDEX hands back what it took when it lets go of a note. The
    /// entry itself STAYS — a note edited inside a book is never "left" (the
    /// workspace's shown set holds only a pane's own note, trace T3 case 2),
    /// so its ⌘Q/lock savepoint is still owed — until a leaving savepoint does
    /// land for it.
    @Test func theBookIndexHandsBackWhatItTook() async throws {
        try await withRegistryWorld { session, _ in
            let post = try session.operations.createPost(title: "book-note")
            let block = try session.operations.newBlock(in: post.id, text: "Alpha.")
            let entries = session.openAutosaveCount

            var edit: BookIndexEditModel? = BookIndexEditModel(session: session)
            edit?.paneEdited(
                postID: post.id, variantID: block.variant.id, oldText: "Alpha.", newText: "Alpha!")
            #expect(session.autosaveHolderCount(forPost: post.id) == 1)

            edit?.teardown()
            await eventually { session.autosaveHolderCount(forPost: post.id) == 0 }
            #expect(session.autosaveHolderCount(forPost: post.id) == 0,
                    "the index's hold went back when its cache let go of the note")
            #expect(session.openAutosaveCount == entries + 1,
                    "…and the entry stays: nothing has LEFT this note, so ⌘Q still owes it a savepoint")

            edit = nil
            await session.savepointOnLeaving(post.id)
            #expect(session.openAutosaveCount == entries,
                    "a leaving savepoint that lands with nobody holding the note takes it out")
        }
    }

    /// The SEAL fallback (`ShellActions.toggleSeal` in a handler-less mode)
    /// only needs a FLUSH before `lockPost` — it minted a coordinator, and a
    /// holder nobody would ever release, for every press (trace T5).
    @Test func theSealFallbackFlushesWithoutMinting() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "seal-me")
            _ = try session.operations.newBlock(in: post.id, text: "a block.")
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .compare) { _ in }
            let entries = session.openAutosaveCount
            let quits = session.quitFinalize.count

            ShellActions(session: session, shell: ShellRouter()).toggleSeal()
            await eventually { session.status.current?.text.contains("Sealed") == true }
            let sealed = try await db.read { db in
                try Queries.containerHeader(db, containerID: post.id)?.locked
            }
            #expect(sealed == true, "the premise: the fallback acted")
            #expect(session.openAutosaveCount == entries, "no coordinator minted for a flush")
            #expect(session.quitFinalize.count == quits, "and no ⌘Q closure left behind")
        }
    }

    /// The seal fallback still lands what a surface was holding: the flush
    /// reaches the SAME coordinator the surface records into, so the seal's
    /// insurance savepoint carries the last keystrokes. (Parity guard — the
    /// old mint returned that same coordinator too.)
    @Test func theSealFallbackStillFlushesAnOpenSurfacesTyping() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "seal-typed")
            let block = try session.operations.newBlock(in: post.id, text: "Before.")
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .compare) { _ in }
            let toc = BlockTOCViewModel(session: session, postID: post.id)
            toc.paneEdited(variantID: block.variant.id, oldText: "Before.", newText: "Before, typed.")
            #expect(toc.autosave.isDirty, "the premise: the keystroke is still in the debounce")

            ShellActions(session: session, shell: ShellRouter()).toggleSeal()
            await eventually { session.status.current?.text.contains("Sealed") == true }
            #expect(try await workingText(db, variantID: block.variant.id) == "Before, typed.")
            #expect(try await savepointTexts(db, postID: post.id).contains("Before, typed."),
                    "the seal's insurance savepoint carries the flushed text")
            toc.teardown()
        }
    }
}

// MARK: - The guard pins (nothing about letting go may cost a savepoint or split a pipeline)

@Suite("18k C1 — letting go never costs a savepoint or splits a note's pipeline", .serialized)
@MainActor
struct AutosaveRegistryReleaseGuardTests {

    /// **(a), the open-tail road (trace T3 case 3).** She types a new last
    /// paragraph and navigates away before it crystallizes. The workspace's
    /// leaving savepoint runs first and cannot see the tail — the tail is in
    /// no row until the editor's finalize mints it, AFTER. The release that
    /// follows re-takes the leaving savepoint, so the tail is in her history
    /// without waiting for ⌘Q. (Pre-fix it waited for ⌘Q or the lock — the
    /// leaked entry was its only road.)
    @Test func theOpenTailOfANoteLeftMidParagraphIsInItsLeavingSavepoint() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "tail")
            var surface: MountedEditor? = try MountedEditor(
                session: session, database: db, postID: post.id)
            surface?.type("a paragraph she never finished")
            #expect(surface?.model.hasOpenTail == true, "the premise: the text is an open tail")

            let leaving = Task { await session.savepointOnLeaving(post.id) }
            await surface?.model.teardown()?.value
            surface = nil
            await leaving.value
            await eventually { session.openAutosaveCount == 0 }

            #expect(try await savepointTexts(db, postID: post.id)
                    == ["a paragraph she never finished"],
                    "the leaving savepoint carries the tail the editor minted on its way out")
        }
    }

    /// **(a), stated as the brief states it — the leaving savepoint still
    /// LANDS for a note closed with unsaved changes, by ⌘Q at the latest.**
    /// Green on the old tree (its leaked entry reached the tail at ⌘Q); RED
    /// under a release that drops the entry the moment the editor dies, which
    /// would leave the tail to the 2 h idle backstop.
    @Test func theOpenTailIsSavepointedByQuitAtTheLatest() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "tail-quit")
            var surface: MountedEditor? = try MountedEditor(
                session: session, database: db, postID: post.id)
            surface?.type("the last thing she wrote")

            let leaving = Task { await session.savepointOnLeaving(post.id) }
            await surface?.model.teardown()?.value
            surface = nil
            await leaving.value
            await session.quitFinalize.finalizeAll()
            await eventually { session.openAutosaveCount == 0 }

            #expect(try await savepointTexts(db, postID: post.id)
                    .contains("the last thing she wrote"))
        }
    }

    /// **(a) for a note edited inside a BOOK (trace T3 case 2).** Nothing ever
    /// reports a book's note as left, so its ⌘Q/lock savepoint is its only
    /// leaving road: the index letting go must not take that away.
    @Test func aNoteEditedInABookKeepsItsQuitAndLockSavepoint() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "in-a-book")
            let block = try session.operations.newBlock(in: post.id, text: "Chapter one.")
            let edit = BookIndexEditModel(session: session)
            edit.paneEdited(
                postID: post.id, variantID: block.variant.id,
                oldText: "Chapter one.", newText: "Chapter one, revised.")
            edit.teardown()
            await eventually { session.autosaveHolderCount(forPost: post.id) == 0 }
            #expect(try await workingText(db, variantID: block.variant.id)
                    == "Chapter one, revised.", "the premise: the flush landed")
            #expect(try await savepointTexts(db, postID: post.id).isEmpty,
                    "the premise: no leaving has savepointed it yet")

            await macWillLock(session: session, stopServices: {})()

            #expect(try await savepointTexts(db, postID: post.id) == ["Chapter one, revised."],
                    "the lock walk still reached the book-edited note")
        }
    }

    /// **(b) — ⌘Q and the lock still finalize every note that is STILL OPEN.**
    /// A: a live surface holds it, with a keystroke still in the debounce.
    /// B: still SHOWN, but its surface is gone — a split's unfocused pane,
    /// which the shell re-renders read-cheap (trace T3 case 1); its edit landed
    /// but no leaving has savepointed it. C: left and closed — its savepoint
    /// already landed at the leaving, so the walk no longer carries it.
    @Test func quitStillFinalizesEveryNoteThatIsStillOpen() async throws {
        try await withRegistryWorld { session, db in
            let a = try session.operations.createPost(title: "A")
            let blockA = try session.operations.newBlock(in: a.id, text: "A.")
            let b = try session.operations.createPost(title: "B")
            let blockB = try session.operations.newBlock(in: b.id, text: "B.")
            let c = try session.operations.createPost(title: "C")
            let blockC = try session.operations.newBlock(in: c.id, text: "C.")

            let tocA = BlockTOCViewModel(session: session, postID: a.id)
            tocA.paneEdited(variantID: blockA.variant.id, oldText: "A.", newText: "A, pending.")

            var tocB: BlockTOCViewModel? = BlockTOCViewModel(session: session, postID: b.id)
            tocB?.paneEdited(variantID: blockB.variant.id, oldText: "B.", newText: "B, flushed.")
            await tocB?.autosave.flushNow()
            tocB?.teardown()
            tocB = nil   // the unfocused pane: surface gone, note still shown

            var tocC: BlockTOCViewModel? = BlockTOCViewModel(session: session, postID: c.id)
            tocC?.paneEdited(variantID: blockC.variant.id, oldText: "C.", newText: "C, left.")
            let leaving = Task { await session.savepointOnLeaving(c.id) }
            tocC?.teardown()
            tocC = nil
            await leaving.value
            await eventually { session.autosaveHolderCount(forPost: c.id) == 0 }

            await session.quitFinalize.finalizeAll()

            #expect(try await workingText(db, variantID: blockA.variant.id) == "A, pending.",
                    "⌘Q flushed the open surface's debounce")
            #expect(try await savepointTexts(db, postID: a.id) == ["A, pending."])
            #expect(try await savepointTexts(db, postID: b.id) == ["B, flushed."],
                    "the still-shown note whose surface is gone got its ⌘Q savepoint")
            #expect(try await savepointTexts(db, postID: c.id) == ["C, left."],
                    "the left note has its one leaving savepoint — and no second")
            tocA.teardown()
        }
    }

    /// (b), the LOCK road — the same walk through `macWillLock`, the factory
    /// the relock wires.
    @Test func theLockStillFinalizesEveryNoteThatIsStillOpen() async throws {
        try await withRegistryWorld { session, db in
            let b = try session.operations.createPost(title: "B")
            let blockB = try session.operations.newBlock(in: b.id, text: "B.")
            var tocB: BlockTOCViewModel? = BlockTOCViewModel(session: session, postID: b.id)
            tocB?.paneEdited(variantID: blockB.variant.id, oldText: "B.", newText: "B, locked.")
            await tocB?.autosave.flushNow()
            tocB?.teardown()
            tocB = nil
            // The surface is really gone (its teardown Task held it) before
            // the walk takes its snapshot — otherwise the walk would reach B
            // by timing, not by the registry keeping it.
            await eventually { session.autosaveHolderCount(forPost: b.id) == 0 }

            await macWillLock(session: session, stopServices: {})()

            #expect(try await savepointTexts(db, postID: b.id) == ["B, locked."])
            #expect(session.openAutosaveCount == 0,
                    "and a savepoint that landed with nobody holding the note lets it go")
        }
    }

    /// **(c) — the N3 shape.** A note open in two surfaces; one closes. The
    /// survivor keeps the ONE coordinator (a second pipeline could flush a
    /// stale buffer over a newer one — 13b 1a's N3), its typing reaches it,
    /// and the ⌘Q walk still flushes that typing.
    @Test func twoSurfacesOnOneNoteKeepOneCoordinatorWhenOneCloses() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "two")
            let block = try session.operations.newBlock(in: post.id, text: "One.")
            let entries = session.openAutosaveCount

            var editor: EditorViewModel? = EditorViewModel(session: session, postID: post.id)
            let takes = TakesViewModel(session: session, postID: post.id)
            let shared = takes.autosave
            #expect(editor?.autosave === shared, "the premise: one coordinator")

            await editor?.teardown()?.value
            editor = nil
            #expect(session.openAutosaveCount == entries + 1, "the note is still open — one entry")
            #expect(session.autosaveHolderCount(forPost: post.id) == 1, "the survivor's hold")

            takes.paneEdited(variantID: block.variant.id, newText: "One, from the survivor.")
            #expect(takes.autosave === shared, "still THE coordinator")
            await session.quitFinalize.finalizeAll()
            #expect(try await workingText(db, variantID: block.variant.id)
                    == "One, from the survivor.", "⌘Q reached the survivor's typing")
            takes.teardown()
        }
    }

    /// **A mode switch is not a leaving** (J11's own list). Write closes and
    /// Takes opens on the same note with no leaving between: no savepoint is
    /// written by the release, and Takes picks up the SAME pipeline.
    @Test func aModeSwitchIsNotALeaving() async throws {
        try await withRegistryWorld { session, db in
            let post = try session.operations.createPost(title: "modes")
            let block = try session.operations.newBlock(in: post.id, text: "Written.")
            var toc: BlockTOCViewModel? = BlockTOCViewModel(session: session, postID: post.id)
            let coordinator = toc?.autosave
            toc?.paneEdited(variantID: block.variant.id, oldText: "Written.", newText: "Written, then.")
            toc?.teardown()
            toc = nil
            await eventually { coordinator?.isDirty == false }
            #expect(try await workingText(db, variantID: block.variant.id) == "Written, then.")

            let takes = TakesViewModel(session: session, postID: post.id)
            #expect(takes.autosave === coordinator,
                    "the note never left, so its entry — and its one pipeline — stayed")
            try await Task.sleep(for: .milliseconds(50))
            #expect(try await savepointTexts(db, postID: post.id).isEmpty,
                    "switching modes wrote no savepoint")
            takes.teardown()
        }
    }
}
