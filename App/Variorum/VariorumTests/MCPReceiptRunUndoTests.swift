//
//  MCPReceiptRunUndoTests.swift
//  VariorumTests (Mac)
//
//  VX-133 (the VX-981 run, batch 2 — a rider, R-981-2; the record
//  `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 2 RECORD): THE DOOR'S
//  HALF of "the receipt run's count stays true". Found at the 13n-b U4 walk —
//  capture 09 read "u3-walk made 4 changes" where three of the four had been
//  walked back: an undo never touched `MCPDoor.receiptRun`. The door now holds
//  the pure `MCPReceiptRun` and hears its session stack's walks
//  (`UndoStack.addWalkObserver`, hopped to the main actor), so the line counts
//  the acts that stand. The headless pins are `MCPReceiptRunTests` (the run),
//  `UndoStackWalkTests` (the stack) and `MCPReceiptUndoEntryServerTests` (the
//  wire's stamp); this file is the door, with REAL entries on the session's
//  stack and her REAL undo and redo halves.
//
//  RED ON THE SCAFFOLD by mechanism (the stack never told its observers, so
//  the door's run kept every act).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 133))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// A client's take receipt naming the undo entry its act registered.
private func take(_ entry: Int?, note: String) -> MCPWriteReceipt {
    var receipt = MCPWriteReceipt(clientName: "claude-code", act: .take, targetID: note, targetTitle: "ch 1")
    receipt.undoEntryID = entry
    return receipt
}

private let undoes = " \u{00B7} \u{2325}\u{2318}Z undoes"

@MainActor
@Suite("VX-133 — the door's receipt run counts the acts that stand across her undo", .serialized)
struct MCPReceiptRunUndoTests {
    /// **RED ON THE SCAFFOLD — four acts, three undone → the line says one.** Four real entries
    /// on the session's stack (each a client's act, as the wire's runner registers them), their
    /// receipts landed through the door; her structural undo walks three back — and the run's
    /// line now counts ONE. Her redo raises it to two; the client's next act joins the run.
    @Test func fourActsThreeUndoneTheLineSaysOne() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            let note = try session.operations.createPost(title: "ch 1")
            let now = Date(timeIntervalSince1970: 1_800_000_000)
            for index in 0..<4 {
                _ = try session.operations.newBlock(in: note.id, text: "Take \(index).")
                door.landReceipt(take(session.undoStack.newestEntryID, note: note.id),
                                 now: now.addingTimeInterval(Double(index)))
            }
            #expect(session.status.spoken?.text == "claude-code added 4 takes" + undoes, "the control")

            for _ in 0..<3 { _ = try session.undoStack.undoReporting(with: session.operations) }
            let lowered = try await settle { door.receiptRunLine == "claude-code added a take" + undoes }
            #expect(lowered, "RED ON THE SCAFFOLD: four acts, three undone — \(door.receiptRunLine ?? "nil")")

            _ = try session.undoStack.redoReporting(with: session.operations)
            let raised = try await settle { door.receiptRunLine == "claude-code added 2 takes" + undoes }
            #expect(raised, "RED ON THE SCAFFOLD: her redo raises it — \(door.receiptRunLine ?? "nil")")

            _ = try session.operations.newBlock(in: note.id, text: "Take 4.")
            door.landReceipt(take(session.undoStack.newestEntryID, note: note.id), now: now.addingTimeInterval(10))
            #expect(session.status.spoken?.text == "claude-code added 3 takes" + undoes,
                    "RED ON THE SCAFFOLD: the next act's line counts what stands")
        }
    }

    /// **RED ON THE SCAFFOLD — a run walked back to nothing speaks no stale count.** Both acts
    /// undone, the client's next act on the note reads as that one act.
    @Test func aRunWalkedBackToNothingThenReadsAsOneAct() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            session.status.receiptStyle = .quiet
            let note = try session.operations.createPost(title: "ch 1")
            let now = Date(timeIntervalSince1970: 1_800_000_000)
            for index in 0..<2 {
                _ = try session.operations.newBlock(in: note.id, text: "Take \(index).")
                door.landReceipt(take(session.undoStack.newestEntryID, note: note.id),
                                 now: now.addingTimeInterval(Double(index)))
            }
            for _ in 0..<2 { _ = try session.undoStack.undoReporting(with: session.operations) }
            let empty = try await settle { door.receiptRunLine == nil }
            #expect(empty, "RED ON THE SCAFFOLD: nothing stands — \(door.receiptRunLine ?? "nil")")
            _ = try session.operations.newBlock(in: note.id, text: "Take 2.")
            door.landReceipt(take(session.undoStack.newestEntryID, note: note.id), now: now.addingTimeInterval(5))
            #expect(session.status.spoken?.text == "claude-code added a take" + undoes,
                    "RED ON THE SCAFFOLD: one act, never a stale three")
        }
    }

    /// GUARDS: her OWN structural act's undo (an entry no receipt names) lowers nothing; and the
    /// door hears only the session it is attached to — tokens are per stack (a fresh session's
    /// stack counts from one again), so a let-go session's walks must never reach the run, or an
    /// undo in the old library would walk back an act in the new one.
    @Test func herOwnUndoAndALetGoSessionsWalksLowerNothing() async throws {
        try await withSession { (old: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: old)
            let oldNote = try old.operations.createPost(title: "old")
            _ = try old.operations.newBlock(in: oldNote.id, text: "Old take.")
            let oldToken = try #require(old.undoStack.newestEntryID)
            door.detach()

            let db = try AppDatabase.inMemory()
            let fresh = withDependencies { $0.database = db } operation: { AppSession(database: db) }
            door.attach(session: fresh)
            defer { door.detach() }
            fresh.status.receiptStyle = .quiet
            let note = try fresh.operations.createPost(title: "ch 1")
            _ = try fresh.operations.newBlock(in: note.id, text: "Take 0.")
            let token = try #require(fresh.undoStack.newestEntryID)
            #expect(token == oldToken, "the premise: the two stacks' first tokens collide")
            door.landReceipt(take(token, note: note.id), now: Date(timeIntervalSince1970: 1_800_000_000))

            _ = try old.undoStack.undoReporting(with: old.operations)  // the let-go library's walk
            let block = try fresh.operations.newBlock(in: note.id, text: "Hers.")
            try fresh.operations.deleteBlock(block.block.id)
            _ = try fresh.undoStack.undoReporting(with: fresh.operations)  // her own entry, undone
            try await Task.sleep(for: .milliseconds(100))
            #expect(door.receiptRunLine == "claude-code added a take" + undoes,
                    "neither walk names an act of the run: \(door.receiptRunLine ?? "nil")")
        }
    }
}
