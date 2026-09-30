//
//  BookLeavingSavepointTests.swift
//  VariorumTests
//
//  18o U4 — R-18k-6, her ruling: *"a note edited inside a book should get a
//  savepoint when you open it"*, clarified at once to **"When I move to
//  another note"** — in a book, the note she edited gets its leaving savepoint
//  when she moves into a different note, or leaves the book, exactly as
//  leaving a note on its own already does. Compare peers follow the same rule,
//  PROVISIONAL (QUESTIONS #163). The batch record is
//  `notes/plans/phase-18o-correctness-singles.md` → UNIT U4 RECORD.
//
//  THE GAP (18k C1's trace T3 case 2 and its named residual 1): the Mac's
//  leaving roads read `WorkspaceModel.shownNoteIDs`, which counts only a
//  pane's OWN note — a pane showing a book contributes nothing, and a Compare
//  peer is not the pane's note — so a note edited in a book or as a peer got
//  its J11 savepoint only at ⌘Q, the lock, or the 2 h idle backstop, and its
//  registry entry stayed until then.
//
//  HOW THESE PINS ARE BUILT — red on dead wiring, the J11 suite's own rule
//  (`SavepointOnLeaveTests`' header): nothing here calls a seam. Each pin
//  MOUNTS the real surface in a window and drives only doors that exist on the
//  pre-fix tree — `BookView` hosted with its model, `model.focus`, the Index's
//  `requestLanding`, typing into the real live editor or pane, the board's
//  `setPeer` / `paneEdited`, and a window's content going away (SwiftUI runs
//  the departing views' `onDisappear`, the real "leave the book" road). What is
//  measured is the savepoint ROW's arrival (the C1 pin style) and, for the
//  registry half, the counts C1's pins read (`openAutosaveCount`,
//  `quitFinalize.count`), extended here — C1's own pins ride unmodified.
//
//  THE FIXTURE savepoints every take at setup (a manual commit per take), so a
//  savepoint row that appears afterwards is one the LEAVING wrote, and a take
//  she did not change gets nothing — `closeAutoCommit`'s dedupe, byte-for-byte.
//  (A take never savepointed at all counts as unsaved on every leaving road —
//  the op's own `isDirty`; the one pin that needs that state says so.)
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The world

private typealias Blocks = [String: [(blockID: String, variantID: String)]]

@MainActor
private func withLeavingBook<T>(
    posts: Int = 3,
    savepointed: Bool = true,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String, _ postIDs: [String], _ blocks: Blocks
    ) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        // LIVE uuids: nothing this suite mounts shares an id with another
        // suite's world (the C8 attribute-uniquing class).
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 14))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the leaving book", kind: .curated)
        var postIDs: [String] = []
        var blocks: Blocks = [:]
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "note \(p)")
            var made: [(String, String)] = []
            for b in 0..<2 {
                let block = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(b) of note \(p), long enough to read like real prose.")
                if savepointed { try session.operations.commit(block.variant.id) }
                made.append((block.block.id, block.variant.id))
            }
            blocks[post.id] = made
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs, blocks)
    }
}

/// The QUIET savepoints under a post's live takes, oldest first — the rows a
/// leaving writes (`kind = 'auto'`); the fixture's own savepoints are manual.
private func quietSavepoints(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT cp.text FROM commit_point cp
                  JOIN variant v ON v.id = cp.variant_id
                  JOIN container_block cb ON cb.block_id = v.block_id
                 WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND cp.kind = 'auto'
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

@MainActor
private func loadedBook(
    session: AppSession, db: AppDatabase, readingID: String, mode: BookStructureModel.ViewMode
) async throws -> (BookViewModel, BookStructureModel) {
    let model = BookViewModel(session: session, readingID: readingID)
    await model.adopt(try await db.read { [readingID] in
        try Queries.assembleReading($0, readingID: readingID)
    })
    let structure = BookStructureModel(session: session, readingID: readingID)
    structure.adopt(.init(
        reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
        sections: [], deletedSections: [], assignments: [:]))
    structure.mode = mode
    return (model, structure)
}

/// A real window hosting `view`, and the way a surface LEAVES it: the content
/// torn down first (SwiftUI runs the departing views' `onDisappear` — the
/// `DebugOracleTwoWindowTests` rig's shape), then the window itself.
@MainActor
private final class Mount {
    let window: NSWindow
    let hosting: NSView

    init<V: View>(_ view: V, width: CGFloat = 1200, height: CGFloat = 800) {
        window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        self.hosting = hosting
    }

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Pump SwiftUI until `predicate` holds (bounded — a red pin fails, it
    /// never hangs).
    @discardableResult
    func settle(maxTurns: Int = 120, until predicate: () -> Bool) async -> Bool {
        for _ in 0..<maxTurns {
            if window.contentView != nil {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
            }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return true }
        }
        return predicate()
    }

    /// Settle until an async condition holds — the spawned leaving roads
    /// detach from their caller deliberately.
    @discardableResult
    func settle(maxTurns: Int = 200, untilAsync predicate: () async throws -> Bool) async rethrows -> Bool {
        for _ in 0..<maxTurns {
            if window.contentView != nil {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
            }
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if try await predicate() { return true }
        }
        return try await predicate()
    }

    /// The surface leaves: its window's content goes away first.
    func unmount() {
        window.contentView = nil
    }

    func close() {
        window.contentView = nil
        window.orderOut(nil)
        window.close()
    }
}

@MainActor
private func type(_ text: String, into view: NSTextView?) {
    guard let view else { return }
    view.setSelectedRange(NSRange(location: (view.string as NSString).length, length: 0))
    view.insertText(text, replacementRange: view.selectedRange())
}

@MainActor
private func editablePanes(in view: NSView) -> [PaneTextView] {
    var out: [PaneTextView] = []
    if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
    for sub in view.subviews { out += editablePanes(in: sub) }
    return out
}

@MainActor
private func paneIdentifier(_ variantID: String) -> String {
    "pane:\(BookIndexEditModel.columnID)|\(variantID)"
}

// MARK: - The book

@Suite("18o U4 — a note left inside a book gets its leaving savepoint (R-18k-6)", .serialized)
@MainActor
struct BookLeavingSavepointTests {

    /// **OUTLINE — she edits a note, then moves into another one.** The
    /// leaving savepoint lands at the move (pre-fix: nothing until ⌘Q, the
    /// lock or the 2 h idle backstop), and once it has landed the note leaves
    /// the ⌘Q/lock walk — C1's drop conditions, reached through the leaving
    /// the book never reported before.
    @Test func movingIntoAnotherNoteInOutlineSavepointsTheNoteSheEdited() async throws {
        try await withLeavingBook { session, db, readingID, postIDs, blocks in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            defer { mount.close() }
            await mount.settle { !model.entries.isEmpty }

            model.focus(postIDs[0])
            await mount.settle {
                session.editorRouter.editing?.postID == postIDs[0]
                    && session.editorRouter.editing?.textView != nil
            }
            let editor = try #require(session.editorRouter.editing, "the Outline's live editor mounted")
            type(" Typed in the book.", into: editor.textView)
            #expect(try await quietSavepoints(db, postID: postIDs[0]).isEmpty,
                    "the premise: nothing has savepointed the note yet")

            model.focus(postIDs[1])
            let edited = blocks[postIDs[0]]![1].variantID
            try await mount.settle(untilAsync: {
                !(try await quietSavepoints(db, postID: postIDs[0]).isEmpty)
            })
            #expect(try await workingText(db, variantID: edited)?.hasSuffix(" Typed in the book.") == true,
                    "the typing landed")
            #expect(try await quietSavepoints(db, postID: postIDs[0])
                    == ["Paragraph 1 of note 0, long enough to read like real prose. Typed in the book."],
                    "moving into another note left ONE quiet savepoint for the take she edited — pre-fix, none")

            // The registry half (C1's counts, extended): only the note she is
            // IN now is registered; the one she left is gone from the ⌘Q/lock
            // walk once its savepoint landed.
            await mount.settle { session.openAutosaveCount == 1 }
            #expect(session.openAutosaveCount == 1,
                    "the note she left no longer rides the ⌘Q/lock walk — pre-fix it stayed until then")
            #expect(session.quitFinalize.count == 1)
        }
    }

    /// **INDEX — the one live pane moves into another note.** She types in a
    /// block of the first note; a landing makes a block of another note live
    /// (the ring MIGRATES — P-3). The note she left gets its savepoint then.
    @Test func movingIntoAnotherNoteInIndexSavepointsTheNoteSheEdited() async throws {
        try await withLeavingBook { session, db, readingID, postIDs, blocks in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .index)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure))
            defer { mount.close() }
            await mount.settle(maxTurns: 12) { false }

            let a = blocks[postIDs[0]]![0]
            model.requestLanding(LandingTarget(postID: postIDs[0], blockID: a.blockID))
            await mount.settle {
                editablePanes(in: mount.hosting).first?.identifier?.rawValue == paneIdentifier(a.variantID)
            }
            let pane = try #require(editablePanes(in: mount.hosting).first, "a's block is the live pane")
            type(" Typed in the index.", into: pane)
            #expect(try await quietSavepoints(db, postID: postIDs[0]).isEmpty,
                    "the premise: nothing has savepointed the note yet")

            let b = blocks[postIDs[1]]![0]
            model.requestLanding(LandingTarget(postID: postIDs[1], blockID: b.blockID))
            try await mount.settle(untilAsync: {
                !(try await quietSavepoints(db, postID: postIDs[0]).isEmpty)
            })
            #expect(try await quietSavepoints(db, postID: postIDs[0])
                    == ["Paragraph 0 of note 0, long enough to read like real prose. Typed in the index."],
                    "the live pane moving into another note savepointed the one she left — pre-fix, none")
            #expect(try await quietSavepoints(db, postID: postIDs[1]).isEmpty,
                    "the note she moved INTO owes nothing yet")

            // Leaving the book retires both entries: the index lets go of its
            // holds (its teardown), and each note has had its leaving.
            mount.unmount()
            await mount.settle { session.openAutosaveCount == 0 }
            #expect(session.openAutosaveCount == 0,
                    "every note she was in has been left and let go — pre-fix both stayed until ⌘Q")
            #expect(session.quitFinalize.count == 0)
        }
    }

    /// **LEAVING THE BOOK** — the pane navigates away (here: the surface's
    /// window content goes, which is what SwiftUI does to the book when the
    /// pane shows something else). The note she was in gets its savepoint.
    @Test func leavingTheBookSavepointsTheNoteSheWasIn() async throws {
        try await withLeavingBook { session, db, readingID, postIDs, _ in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            defer { mount.close() }
            await mount.settle { !model.entries.isEmpty }

            model.focus(postIDs[2])
            await mount.settle {
                session.editorRouter.editing?.postID == postIDs[2]
                    && session.editorRouter.editing?.textView != nil
            }
            type(" Written just before she left.", into: session.editorRouter.editing?.textView)
            #expect(try await quietSavepoints(db, postID: postIDs[2]).isEmpty)

            mount.unmount()
            try await mount.settle(untilAsync: {
                !(try await quietSavepoints(db, postID: postIDs[2]).isEmpty)
            })
            #expect(try await quietSavepoints(db, postID: postIDs[2])
                    == ["Paragraph 1 of note 2, long enough to read like real prose. Written just before she left."],
                    "leaving the book savepointed the note she was in — pre-fix, nothing until ⌘Q")
            await mount.settle { session.openAutosaveCount == 0 }
            #expect(session.openAutosaveCount == 0, "…and the note left the ⌘Q/lock walk")
            #expect(session.quitFinalize.count == 0)
        }
    }

    /// **A NOTE SHE DID NOT CHANGE GETS NOTHING** (the dedupe guard —
    /// `closeAutoCommit`'s, byte-preserved). She clicks into a note, reads,
    /// moves to another, and leaves the book: every take already matches its
    /// last savepoint, so no quiet row is written for either note.
    @Test func aNoteSheWasInButDidNotChangeGetsNothing() async throws {
        try await withLeavingBook { session, db, readingID, postIDs, _ in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            defer { mount.close() }
            await mount.settle { !model.entries.isEmpty }

            model.focus(postIDs[0])
            await mount.settle { session.editorRouter.editing?.postID == postIDs[0] }
            model.focus(postIDs[1])
            await mount.settle { session.editorRouter.editing?.postID == postIDs[1] }
            mount.unmount()
            await mount.settle { session.openAutosaveCount == 0 }

            for postID in postIDs {
                #expect(try await quietSavepoints(db, postID: postID).isEmpty,
                        "no take changed — nothing is written for \(postID)")
            }
        }
    }

    /// **A NOTE SHE ONLY LOOKED AT IS NEVER REPORTED.** The Index opens
    /// pointing at the first note (its arrival seed — a selection, no caret);
    /// she lands in another note and types there. The first note's takes have
    /// NEVER been savepointed, so reporting it as left would write them (the
    /// op counts a never-savepointed take as unsaved) — and it must not be
    /// reported: her caret was never in it.
    @Test func aNoteSheOnlyLookedAtGetsNothing() async throws {
        try await withLeavingBook(savepointed: false) { session, db, readingID, postIDs, blocks in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .index)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure))
            defer { mount.close() }
            await mount.settle { model.indexSelectedPostID == postIDs[0] }
            #expect(model.indexSelectedPostID == postIDs[0],
                    "the premise: the Index arrived pointing at the first note")

            let b = blocks[postIDs[1]]![0]
            model.requestLanding(LandingTarget(postID: postIDs[1], blockID: b.blockID))
            await mount.settle {
                editablePanes(in: mount.hosting).first?.identifier?.rawValue == paneIdentifier(b.variantID)
            }
            type(" Typed in the second note.", into: editablePanes(in: mount.hosting).first)
            mount.unmount()
            await mount.settle { session.openAutosaveCount == 0 }

            #expect(try await quietSavepoints(db, postID: postIDs[0]).isEmpty,
                    "a note her caret never entered is never reported as left")
            #expect(try await quietSavepoints(db, postID: postIDs[2]).isEmpty)
        }
    }

    /// **A MODE SWITCH INSIDE ONE NOTE IS NOT A LEAVING** (J11's own list; C1's
    /// `aModeSwitchIsNotALeaving` is the note's twin and rides unmodified).
    /// Outline → Index → Outline with her caret's note carried across: no
    /// savepoint is written by the switches.
    @Test func aModeSwitchInsideOneNoteIsNotALeaving() async throws {
        try await withLeavingBook { session, db, readingID, postIDs, _ in
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            defer { mount.close() }
            await mount.settle { !model.entries.isEmpty }

            model.focus(postIDs[1])
            await mount.settle {
                session.editorRouter.editing?.postID == postIDs[1]
                    && session.editorRouter.editing?.textView != nil
            }
            type(" Typed before switching.", into: session.editorRouter.editing?.textView)

            // What the mode picker does (`BookView.switchMode`): carry, then switch.
            model.carryPlace(from: structure.mode, readForm: structure.readForm)
            structure.mode = .index
            await mount.settle { model.indexSelectedPostID == postIDs[1] }
            #expect(model.indexSelectedPostID == postIDs[1], "the Index arrived in the same note")
            model.carryPlace(from: structure.mode, readForm: structure.readForm)
            structure.mode = .outline
            await mount.settle { session.editorRouter.editing?.postID == postIDs[1] }
            await mount.settle(maxTurns: 20) { false }

            #expect(try await quietSavepoints(db, postID: postIDs[1]).isEmpty,
                    "switching modes inside one note wrote no savepoint")
        }
    }

    /// **`savepoint_cadence` OFF keeps refusing the cadence occasion** (AppSpec
    /// §9: `closeAutoCommit` is one of the two CADENCE occasions). Moving to
    /// another note and leaving the book write NO savepoint in "Only when I
    /// commit" or "Idle only" — and the flush still lands her text, because a
    /// leaving must never lose text whatever the cadence says.
    @Test(arguments: [SavepointCadence.onlyOnCommit, .idleOnly])
    func theCadenceSettingStillGovernsTheBooksLeaving(_ cadence: SavepointCadence) async throws {
        try await withLeavingBook { session, db, readingID, postIDs, blocks in
            try session.operations.setSavepointCadence(cadence)
            let (model, structure) = try await loadedBook(
                session: session, db: db, readingID: readingID, mode: .outline)
            let mount = Mount(BookView(
                session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
            defer { mount.close() }
            await mount.settle { !model.entries.isEmpty }

            model.focus(postIDs[0])
            await mount.settle {
                session.editorRouter.editing?.postID == postIDs[0]
                    && session.editorRouter.editing?.textView != nil
            }
            type(" Typed under \(cadence.rawValue).", into: session.editorRouter.editing?.textView)
            model.focus(postIDs[1])
            mount.unmount()
            let edited = blocks[postIDs[0]]![1].variantID
            try await mount.settle(untilAsync: {
                try await workingText(db, variantID: edited)?.hasSuffix(" Typed under \(cadence.rawValue).") == true
            })
            await mount.settle(maxTurns: 20) { false }

            #expect(try await workingText(db, variantID: edited)?
                        .hasSuffix(" Typed under \(cadence.rawValue).") == true,
                    "the text landed — leaving never loses text")
            for postID in postIDs {
                #expect(try await quietSavepoints(db, postID: postID).isEmpty,
                        "\(cadence.rawValue): the cadence occasion stays off")
            }
        }
    }
}

// MARK: - Compare peers (PROVISIONAL — QUESTIONS #163)

@Suite("18o U4 — a Compare peer follows the same rule, PROVISIONAL (QUESTIONS #163)", .serialized)
@MainActor
struct CompareLeavingSavepointTests {

    /// Three savepointed notes: the anchor and two candidate peers.
    private func withCompareNotes<T>(
        _ body: @MainActor (AppSession, AppDatabase, _ notes: [(postID: String, variantID: String)]) async throws -> T
    ) async throws -> T {
        try await withLeavingBook { session, db, _, postIDs, blocks in
            let notes = postIDs.map { (postID: $0, variantID: blocks[$0]![0].variantID) }
            return try await body(session, db, notes)
        }
    }

    /// **A PEER SWAPPED OUT** — she edits in a peer column, then picks a
    /// different note into that column. The peer she left gets its savepoint
    /// then (pre-fix: nothing until ⌘Q, the lock or the idle backstop).
    @Test func aPeerSwappedOutGetsItsLeavingSavepoint() async throws {
        try await withCompareNotes { session, db, notes in
            let (anchor, peer, next) = (notes[0], notes[1], notes[2])
            let model = CompareViewModel(session: session, anchorPostID: anchor.postID)
            let mount = Mount(CompareBoardView(session: session, postID: anchor.postID, model: model))
            defer { mount.close() }
            await mount.settle(maxTurns: 12) { false }

            model.setPeer(slotID: model.peerSlots[0].id, postID: peer.postID)
            model.paneEdited(
                postID: peer.postID, variantID: peer.variantID,
                newText: "Paragraph 0 of note 1, revised in the peer column.")
            #expect(try await quietSavepoints(db, postID: peer.postID).isEmpty)

            model.setPeer(slotID: model.peerSlots[0].id, postID: next.postID)
            try await mount.settle(untilAsync: {
                !(try await quietSavepoints(db, postID: peer.postID).isEmpty)
            })
            #expect(try await quietSavepoints(db, postID: peer.postID)
                    == ["Paragraph 0 of note 1, revised in the peer column."],
                    "the peer swapped out got its leaving savepoint — pre-fix, none")
            #expect(try await quietSavepoints(db, postID: anchor.postID).isEmpty,
                    "the anchor is not left by a peer swap")
        }
    }

    /// **THE BOARD LEFT** — every peer it was showing is left with it; the
    /// ANCHOR is not (it is the pane's own note: its leaving is the
    /// workspace's, and a mode switch away from Compare is not one). Once the
    /// peer's savepoint has landed it leaves the ⌘Q/lock walk; the anchor's
    /// entry stays, owed.
    @Test func leavingTheBoardSavepointsItsPeersButNotItsAnchor() async throws {
        try await withCompareNotes { session, db, notes in
            let (anchor, peer) = (notes[0], notes[1])
            let model = CompareViewModel(session: session, anchorPostID: anchor.postID)
            let mount = Mount(CompareBoardView(session: session, postID: anchor.postID, model: model))
            defer { mount.close() }
            await mount.settle(maxTurns: 12) { false }

            model.setPeer(slotID: model.peerSlots[0].id, postID: peer.postID)
            model.paneEdited(
                postID: peer.postID, variantID: peer.variantID,
                newText: "Paragraph 0 of note 1, written in the peer before leaving.")
            model.paneEdited(
                postID: anchor.postID, variantID: anchor.variantID,
                newText: "Paragraph 0 of note 0, written in the anchor.")

            mount.unmount()
            try await mount.settle(untilAsync: {
                !(try await quietSavepoints(db, postID: peer.postID).isEmpty)
            })
            #expect(try await quietSavepoints(db, postID: peer.postID)
                    == ["Paragraph 0 of note 1, written in the peer before leaving."],
                    "the board's peer was left with the board — pre-fix, nothing until ⌘Q")
            await mount.settle { session.openAutosaveCount == 1 }
            #expect(try await workingText(db, variantID: anchor.variantID)
                    == "Paragraph 0 of note 0, written in the anchor.", "the anchor's typing landed")
            #expect(try await quietSavepoints(db, postID: anchor.postID).isEmpty,
                    "the board's leaving is not the anchor's")
            #expect(session.openAutosaveCount == 1,
                    "the peer left the ⌘Q/lock walk; the anchor stays owed — pre-fix both stayed")
            #expect(session.quitFinalize.count == 1)
        }
    }
}
