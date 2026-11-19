import Foundation
import VariorumCore

/// **THE RECEIPT RUN — which of a client's landed acts her one line counts** (13n-b U2's run,
/// moved out of `MCPDoor` by VX-133 — the VX-981 run, batch 2; the record
/// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 2 RECORD). A pure value the app's door
/// holds: consecutive acts by ONE client on ONE target (VX-812: a list call's `runKey` in the
/// target's place) inside `window` speak as one coalesced line ("added 2 takes and saved the lens
/// …"); any other act starts a new run.
///
/// **VX-133 — the count stays TRUE across her undo.** The line is composed over the receipts that
/// STAND (`standing`): an undo that walks back one of the run's acts (`walked` — `UndoStack.Walk`,
/// matched by the entry token the act's receipt carries, `MCPWriteReceipt.undoEntryID`) takes it
/// out of the count, its redo puts it back, and a QUIET half (VX-276 — the act's result was
/// already gone, nothing written) changes nothing. Walking back does not end the run: the
/// client's next act on the same key inside the window joins it, so a run walked back to nothing
/// then reads as that one act — never a stale count.
public struct MCPReceiptRun: Sendable, Equatable {
    /// How long a run stays open to the client's next act (13n-b U2).
    public static let window: TimeInterval = 120

    /// Every receipt of the run, walked back or not, in landing order.
    public private(set) var receipts: [MCPWriteReceipt] = []
    /// When the run's newest act landed.
    public private(set) var landedAt = Date.distantPast
    /// The undo entries of the run's acts that are walked back now.
    private var walkedBack: Set<Int> = []

    public init() {}

    /// The receipts her line counts — every receipt of the run whose act stands.
    public var standing: [MCPWriteReceipt] {
        receipts.filter { receipt in receipt.undoEntryID.map { !walkedBack.contains($0) } ?? true }
    }

    /// A receipt landed: it joins the run (same client, same key, inside the window) or starts
    /// a new one — 13n-b U2's rule, unchanged.
    public mutating func land(_ receipt: MCPWriteReceipt, now: Date) {
        if let last = receipts.last, last.clientName == receipt.clientName,
           (last.runKey ?? last.targetID) == (receipt.runKey ?? receipt.targetID),
           now.timeIntervalSince(landedAt) < Self.window {
            receipts.append(receipt)
        } else {
            receipts = [receipt]
            walkedBack = []
        }
        landedAt = now
    }

    /// A structural undo or redo completed (`UndoStack.addWalkObserver`): an undo that CHANGED
    /// something walks its act out of the count, a redo that did walks it back in; a quiet half
    /// (VX-276 — nothing written) and a walk naming no act of this run (her own entry, an older
    /// run's) change nothing.
    public mutating func walked(_ walk: UndoStack.Walk) {
        guard walk.changed, receipts.contains(where: { $0.undoEntryID == walk.entryID }) else { return }
        switch walk.direction {
        case .undo: walkedBack.insert(walk.entryID)
        case .redo: walkedBack.remove(walk.entryID)
        }
    }
}
