//
//  VX347SavepointLeaveRuleTests.swift
//  VariorumTests
//
//  VX-347 — **the leave rule, the settle-once box, and the take each host
//  files** (her ruling, superseding QUESTIONS #121(b): every way of leaving
//  the ⌘S name field but ⎋ files the commit, named with what was typed,
//  unnamed if nothing was). The record is `notes/plans/fixes/vx-348-
//  prelaunch-sweep.md`'s U2 UNIT RECORD.
//
//  These cells read the NEW seam's API (`SavepointNameLeave`,
//  `SavepointNameLeaving`, `fileSavepoint(_:named:)`) — they are the
//  contract's own pins, not red-on-old ones; the behavioural reds live in
//  `VX347CommitLeavesMountTests` (the product's presenter, pre-fix APIs only)
//  and the flipped `SavepointCommitDoorTests` cell.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule

@Suite("VX-347 — how the ⌘S field was left, and whether that files")
struct VX347LeaveRuleTests {
    /// **THE WHOLE CONTRACT, AS ONE TABLE.** At the commit door every leave
    /// but ⎋ files; at the rename door ⏎ alone renames (its shipped "⎋
    /// leaves it as it was", untouched — P-VX347-3).
    @Test func theLeaveTable() {
        #expect(SavepointNameLeave.returnKey.files(.newSavepoint))
        #expect(SavepointNameLeave.away.files(.newSavepoint),
                "a click away, typing on, the window going, ⌘S again — all commit")
        #expect(!SavepointNameLeave.escape.files(.newSavepoint),
                "⎋ alone is the deliberate \u{201C}don't save\u{201D}")
        #expect(SavepointNameLeave.returnKey.files(.rename))
        #expect(!SavepointNameLeave.away.files(.rename), "a rename dismissed keeps the name as it was")
        #expect(!SavepointNameLeave.escape.files(.rename))
    }

    /// **ONLY A FRESH ⎋ DELIVERED TO THIS POPOVER IS ⎋.** The popover's own
    /// closing is heard with whatever event AppKit is dispatching; ⎋ (and
    /// ⌘., the same Exit command) decides "don't save" only when it is that
    /// event — fresh, and addressed to the popover or the window it hangs
    /// from. Everything else is away, which files: the safe bias.
    @Test func onlyAFreshEscapeAddressedToThePopoverIsEscape() {
        func closing(
            keyDown: Bool = true, _ keyCode: UInt16, _ chars: String,
            _ modifiers: NSEvent.ModifierFlags = [], age: TimeInterval = 0.01,
            addressed: Bool = true
        ) -> SavepointNameLeave {
            SavepointNameLeave.closing(
                keyDown: keyDown, keyCode: keyCode, characters: chars,
                modifiers: modifiers, age: age, addressedToThisPopover: addressed)
        }
        #expect(closing(53, "\u{1b}") == .escape, "⎋")
        #expect(closing(47, ".", [.command]) == .escape, "⌘. — the Exit command's other key")
        #expect(closing(53, "\u{1b}", [.capsLock]) == .escape, "caps lock is not a chord")
        #expect(closing(53, "\u{1b}", addressed: false) == .away, "a ⎋ meant for another window")
        #expect(closing(53, "\u{1b}", age: 5) == .away, "a ⎋ from seconds ago caused nothing now")
        #expect(closing(53, "\u{1b}", age: -1) == .away, "a timestamp from the future is not a cause")
        #expect(closing(keyDown: false, 53, "\u{1b}") == .away, "not a key at all — a mouse-down outside")
        #expect(closing(1, "s", [.command]) == .away, "⌘S again")
        #expect(closing(53, "\u{1b}", [.shift]) == .away, "a chord on ⎋ is not the Exit command")
        #expect(closing(13, "w", [.command]) == .away, "⌘W closing the window")
    }

    @MainActor
    @Test func noEventAtAllIsAway() {
        #expect(SavepointNameLeave.closing(during: nil, popoverWindow: NSWindow()) == .away)
        #expect(SavepointNameLeave.closing(during: nil, popoverWindow: nil) == .away)
    }

    /// The commit door's hint says the new contract where she reads it, in
    /// the commit vocabulary (R-13s-31): leaving commits, ⎋ doesn't.
    @Test func theCommitDoorsHintSaysLeavingCommits() {
        let hint = SavepointNameCopy.hint(.newSavepoint)
        #expect(hint.contains("clicking away commits it"))
        #expect(hint.contains("\u{238B} doesn't"))
        #expect(!hint.contains("cancels"), "⎋ no longer cancels a commit she asked for by another road")
        #expect(SavepointNameCopy.hint(.rename).contains("\u{238B} leaves it as it was"),
                "the rename door's two keys are untouched")
    }
}

// MARK: - The settle-once box

@MainActor
@Suite("VX-347 — one field, one leave, whichever road reports first")
struct VX347LeavingBoxTests {
    /// A host's ask and every filing it got.
    @MainActor
    private final class Host {
        var ask: SavepointNameAsk?
        var filed: [(SavepointNameAsk, String?)] = []
        let box = SavepointNameLeaving()

        func clear(_ left: SavepointNameAsk) { if ask == left { ask = nil } }
        func file(_ ask: SavepointNameAsk, _ name: String?) { filed.append((ask, name)) }

        /// ⌘S: the host's ask set, and the presenter hearing it move.
        func present(_ next: SavepointNameAsk) {
            let old = ask
            ask = next
            box.hostAskChanged(from: old, to: next, way: .away, clear: clear, file: file)
        }

        /// The model letting go (⌘S again) — the presenter hearing it move.
        func letGo() {
            let old = ask
            ask = nil
            box.hostAskChanged(from: old, to: nil, way: .away, clear: clear, file: file)
        }

        /// The host's change after a leave cleared it (SwiftUI's next pass).
        func heardCleared(from old: SavepointNameAsk) {
            box.hostAskChanged(from: old, to: ask, way: .away, clear: clear, file: file)
        }

        @discardableResult
        func leave(_ asked: SavepointNameAsk, _ way: SavepointNameLeave) -> Bool {
            box.leave(asked, way, clear: clear, file: file)
        }
    }

    private let take = SavepointNameAsk.naming(variantID: "v1")

    /// **⏎, THEN THE POPOVER'S OWN CLOSING, THEN THE HOST'S CHANGE — ONE
    /// FILING.** Three reports of one leave.
    @Test func theFirstReportDecidesAndEveryLaterOneIsANoOp() {
        let host = Host()
        host.present(take)
        #expect(host.leave(take, .returnKey))
        #expect(host.ask == nil, "the leave lets go of the host's ask")
        #expect(!host.leave(take, .away), "the popover's closing after ⏎ is the same leave")
        host.heardCleared(from: take)
        #expect(!host.leave(take, .away), "…and so is a closing heard after the host moved on")
        #expect(host.filed.count == 1)
        #expect(host.filed.first?.1 == nil, "unnamed when nothing was typed")
    }

    /// **⎋, THEN THE CLOSING — NOTHING FILED.**
    @Test func escapeThenTheClosingFilesNothing() {
        let host = Host()
        host.present(take)
        #expect(host.leave(take, .escape))
        #expect(!host.leave(take, .away))
        host.heardCleared(from: take)
        #expect(host.filed.isEmpty, "⎋ alone is \u{201C}don't save\u{201D}, whatever reports after it")
        #expect(host.ask == nil, "…and it still closes the field")
    }

    /// **A CLICK AWAY FILES, WITH WHAT WAS TYPED** — normalised through the
    /// ONE name rule, so spaces are no name.
    @Test func aClickAwayFilesWhatWasTyped() {
        let host = Host()
        host.present(take)
        host.box.typed("  before the AI edit  ", for: take)
        host.leave(take, .away)
        #expect(host.filed.count == 1)
        #expect(host.filed.first?.1 == "before the AI edit")

        let blank = Host()
        blank.present(take)
        blank.box.typed("   ", for: take)
        blank.leave(take, .away)
        #expect(blank.filed.count == 1)
        #expect(blank.filed.first?.1 == nil, "a name made of spaces is no name")
    }

    /// **A FRESH ⌘S ON THE SAME TAKE IS A FRESH FIELD.** The settled field
    /// stays settled until the host's ask moves; the next ⌘S moves it again.
    @Test func aFreshCommandSOnTheSameTakeIsAFreshField() {
        let host = Host()
        host.present(take)
        host.leave(take, .returnKey)
        host.heardCleared(from: take)
        host.present(take)  // ⌘S again, later, on the same take
        host.leave(take, .away)
        #expect(host.filed.count == 2, "her ⌘S never dedupes — two asks, two commits")
    }

    /// **⌘S AGAIN WHILE THE FIELD IS UP** (P-VX347-2): the model lets go of
    /// its ask, and the presenter hearing it move files the open field.
    @Test func theModelLettingGoOfAnOpenFieldFilesIt() {
        let host = Host()
        host.present(take)
        host.box.typed("kept", for: take)
        host.letGo()
        #expect(host.filed.count == 1)
        #expect(host.filed.first?.1 == "kept")
        #expect(!host.leave(take, .away), "the popover's closing that follows is the same leave")
        #expect(host.filed.count == 1)
    }

    /// **A HOST THAT APPEARED HOLDING ITS ASK** (no change was ever heard)
    /// still files on a leave — the box adopts the field it is told about.
    @Test func aFieldTheBoxNeverSawOpenStillFiles() {
        let host = Host()
        host.ask = take
        host.leave(take, .away)
        #expect(host.filed.count == 1)
    }

    /// **THE HOST GOING FILES ITS OPEN FIELD** (a mode switch, a closed
    /// note, a closing window or sheet); a host with no field files nothing.
    @Test func theHostGoingLeavesItsOpenField() {
        let host = Host()
        host.present(take)
        host.box.hostLeft(holding: host.ask, clear: host.clear, file: host.file)
        #expect(host.filed.count == 1)
        host.box.hostLeft(holding: nil, clear: host.clear, file: host.file)
        #expect(host.filed.count == 1)
    }

    /// **AN ASK REPLACED BY ANOTHER LEAVES THE FIRST.** Neither field is
    /// ever dropped: the first files as it goes, the second when it is left.
    @Test func anAskReplacedByAnotherLeavesTheFirst() {
        let host = Host()
        let other = SavepointNameAsk.naming(variantID: "v2")
        host.present(take)
        host.present(other)
        #expect(host.filed.map(\.0.targetID) == ["v1"])
        host.leave(other, .returnKey)
        #expect(host.filed.map(\.0.targetID) == ["v1", "v2"])
    }

    /// **THE RENAME DOOR IS NOT ⌘S** (P-VX347-3): dismissed, it renames
    /// nothing; ⏎ renames.
    @Test func theRenameDoorRenamesOnReturnOnly() {
        let when = Date(timeIntervalSince1970: 1_782_864_000)
        let commit = CommitPoint(
            id: "c1", variantId: "v1", text: "words", kind: .manual,
            message: "the old name", createdAt: when)
        let rename = SavepointNameAsk.renaming(commit)

        let dismissed = Host()
        dismissed.present(rename)
        dismissed.box.typed("half typed", for: rename)
        dismissed.leave(rename, .away)
        #expect(dismissed.filed.isEmpty, "a click away keeps the name as it was")
        #expect(dismissed.ask == nil, "…and closes the field")

        let returned = Host()
        returned.present(rename)
        returned.box.typed("the new name", for: rename)
        returned.leave(rename, .returnKey)
        #expect(returned.filed.first?.1 == "the new name")
    }
}

// MARK: - Each host files the take ⌘S asked about

/// A one-post world with two blocks (the same dependency shape as the shipped
/// `withSavepointTakesWorld`, which is private to its file).
@MainActor
private func withTwoBlockWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 347))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "VX-347")
        _ = try session.operations.newBlock(in: post.id, text: "First take.")
        _ = try session.operations.newBlock(in: post.id, text: "Second take.")
        return try await body(session, db, post.id)
    }
}

@MainActor
private func manualCommits(_ db: AppDatabase, _ variantID: String) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND kind = 'manual'",
            arguments: [variantID]) ?? 0
    }
}

@MainActor
@Suite("VX-347 — a left field files the take ⌘S asked about, never the caret's now", .serialized)
struct VX347AskedTakeFilingTests {
    /// **WRITE** — the click away moves the caret into another block before
    /// the filing runs; the commit is still the asked take's.
    @Test func writeFilesTheAskedTake() async throws {
        try await withEditor(seedBlocks: ["first block", "second block"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            h.model.commitCaretVariant()
            let ask = try #require(h.model.savepointAsk)
            let slots = try h.storeSlots()
            #expect(ask.targetID == slots[0].variantID)

            let second = ("first block" as NSString).length + 1 + 3
            h.textView.setSelectedRange(NSRange(location: second, length: 0))
            h.model.updateCaretContext()
            #expect(h.model.caretVariantID == slots[1].variantID, "premise: the caret moved")

            await h.model.fileSavepoint(ask, named: nil)

            #expect(try await manualCommits(h.database, try #require(slots[0].variantID)) == 1)
            #expect(try await manualCommits(h.database, try #require(slots[1].variantID)) == 0)
            #expect(h.model.savepointAsk == nil)
        }
    }

    /// **TAKES / LENSES / WRITE'S TAKE PANEL** (one model) — the ring moves.
    @Test func takesFilesTheAskedTake() async throws {
        try await withTwoBlockWorld { session, db, postID in
            let model = TakesViewModel(session: session, postID: postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            let slots = model.projection.slots
            let first = try #require(slots[0].variantID)
            let second = try #require(slots[1].variantID)
            model.focus(.init(columnID: TakesViewModel.takesMainColumnID,
                              blockID: slots[0].blockID, variantID: first))
            model.askSavepointName()
            let ask = try #require(model.savepointAsk)

            model.focus(.init(columnID: TakesViewModel.takesMainColumnID,
                              blockID: slots[1].blockID, variantID: second))
            await model.fileSavepoint(ask, named: "asked")

            #expect(try await manualCommits(db, first) == 1)
            #expect(try await manualCommits(db, second) == 0)
        }
    }

    /// **CANVAS** — the live card moves.
    @Test func canvasFilesTheAskedTake() async throws {
        try await withTwoBlockWorld { session, db, postID in
            let model = CanvasViewModel(session: session, containerID: postID)
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            let slots = try await db.read { try Queries.renderPost($0, containerID: postID) }
            let first = try #require(slots[0].variantID)
            let second = try #require(slots[1].variantID)
            model.focus(blockID: slots[0].blockID, variantID: first)
            model.askSavepointName()
            let ask = try #require(model.savepointAsk)

            model.focus(blockID: slots[1].blockID, variantID: second)
            await model.fileSavepoint(ask, named: nil)

            #expect(try await manualCommits(db, first) == 1)
            #expect(try await manualCommits(db, second) == 0)
        }
    }

    /// **COMPARE** — the live pane moves to ANOTHER POST's column; the ask
    /// carries its own post, so the right coordinator flushes and the asked
    /// take is the one committed, with the text she had typed into it.
    @Test func compareFilesTheAskedTakeThroughItsOwnPost() async throws {
        try await withTwoBlockWorld { session, db, anchorID in
            let twinID = try await session.runner.run { ops in
                try ops.duplicateAsVersion(anchorID).post.id
            }
            let model = CompareViewModel(session: session, anchorPostID: anchorID)
            model.peerSlots = [.init(postID: twinID)]
            model.adopt(try await db.read { db in
                try CompareViewModel.read(db, anchor: anchorID, peers: [twinID])
            })
            let twinSlot = try #require(model.face(for: twinID)?.slots.first)
            let twinTake = try #require(twinSlot.variantID)
            let anchorSlot = try #require(model.face(for: anchorID)?.slots.first)
            let anchorTake = try #require(anchorSlot.variantID)

            model.focus(.init(columnID: "compare-\(twinID)", blockID: twinSlot.blockID,
                              variantID: twinTake, context: twinID))
            model.paneEdited(postID: twinID, variantID: twinTake, newText: "the twin, typed")
            model.askSavepointName()
            let ask = try #require(model.savepointAsk)
            #expect(ask.context == twinID, "the ask carries the pane's own post")

            model.focus(.init(columnID: "compare-\(anchorID)", blockID: anchorSlot.blockID,
                              variantID: anchorTake, context: anchorID))
            await model.fileSavepoint(ask, named: nil)

            #expect(try await manualCommits(db, twinTake) == 1)
            #expect(try await manualCommits(db, anchorTake) == 0)
            let text = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT text FROM commit_point WHERE variant_id = ?",
                    arguments: [twinTake])
            }
            #expect(text == "the twin, typed", "the twin's own coordinator flushed first")
        }
    }

    /// **⌘S AGAIN LETS GO OF THE OPEN ASK** on every model (P-VX347-2) —
    /// the presenter hearing that files it; no second field opens. Pre-fix
    /// the second press re-set the same ask and nothing happened.
    @Test func commandSAgainLetsGoOfTheOpenAskOnEveryModel() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            h.model.commitCaretVariant()
            #expect(h.model.savepointAsk != nil)
            h.model.commitCaretVariant()
            #expect(h.model.savepointAsk == nil, "Write")
        }
        try await withTwoBlockWorld { session, db, postID in
            let takes = TakesViewModel(session: session, postID: postID)
            takes.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            let slot = takes.projection.slots[0]
            takes.focus(.init(columnID: TakesViewModel.takesMainColumnID,
                              blockID: slot.blockID, variantID: try #require(slot.variantID)))
            takes.askSavepointName()
            #expect(takes.savepointAsk != nil)
            takes.askSavepointName()
            #expect(takes.savepointAsk == nil, "Takes")

            let canvas = CanvasViewModel(session: session, containerID: postID)
            canvas.adopt(try await db.read { try Queries.canvasProjection($0, container: postID) })
            canvas.focus(blockID: slot.blockID, variantID: try #require(slot.variantID))
            canvas.askSavepointName()
            #expect(canvas.savepointAsk != nil)
            canvas.askSavepointName()
            #expect(canvas.savepointAsk == nil, "Canvas")

            let compare = CompareViewModel(session: session, anchorPostID: postID)
            compare.adopt(try await db.read { db in
                try CompareViewModel.read(db, anchor: postID, peers: [])
            })
            compare.focus(.init(columnID: "compare-\(postID)", blockID: slot.blockID,
                                variantID: try #require(slot.variantID), context: postID))
            compare.askSavepointName()
            #expect(compare.savepointAsk != nil)
            compare.askSavepointName()
            #expect(compare.savepointAsk == nil, "Compare")
        }
    }
}
