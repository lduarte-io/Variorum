//
//  MCPDoor+HerEditor.swift
//  Variorum (MAC ONLY)
//
//  VX-275 (Run VX-246, U3 — the record `notes/plans/fixes/vx-246-mcp-door-
//  fixes-ai-docs.md`, U3 UNIT RECORD): HER EDITOR vs THE WIRE. Her ruling (a),
//  2026-10-13: before a wire delete lands, the app saves what she has typed
//  and moves her pane off the deleted note, exactly as her own Delete door
//  does (`NoteDeletion.report` — flush first, post the navigate-away after).
//  The door's two halves of that, wired into `MCPHostHooks` by
//  `reconcileServer`; the wire decides WHICH acts ask (the act list is
//  `MCPWriteTools.Job.flushesHerEditorFirst`, argued in the record).
//

import Foundation
import VariorumMCP

extension MCPDoor {
    /// **The flush before a wire act** (`MCPHostHooks.beforeWrite`): EVERY
    /// open post's pending typing lands — her own flush, one runner turn per
    /// dirty coordinator, BEFORE the act's turn (the wire awaits this). Every
    /// open post, not the act's own note (PROVISIONAL P-VX275-1): a block,
    /// take, commit or comment id would have to be resolved to its note
    /// outside the act's transaction, and before the grant decision — a
    /// timing oracle on ids the client cannot reach. `flushEveryOpenPost`'s
    /// own doc is the precedent (a source named by a block, not a post), and
    /// it costs nothing where nothing is pending (∝ the notes open — P1).
    /// Her Delete door's posture: the outcome is not consulted.
    func flushHerEditorBeforeWrite() async {
        await session?.flushEveryOpenPost()
    }

    /// **A landed wire write** (`MCPHostHooks.onWrite`): the notes the act
    /// left dead go on THE ONE navigate-away road FIRST — the very signal her
    /// Delete door posts (`.variorumNotesDeleted`; every full window runs
    /// `WorkspaceModel.notesDeleted` for its own panes and Open strip, a
    /// note-only window closes, the Library re-reads) — and then the receipt
    /// speaks. Posted after the act committed, so a listener that re-reads
    /// sees the truth (P-4: a signal, each window decides).
    func landWireWrite(_ receipt: MCPWriteReceipt) {
        if !receipt.notesLeftDead.isEmpty {
            NotificationCenter.default.post(
                name: .variorumNotesDeleted, object: nil,
                userInfo: ["postIDs": receipt.notesLeftDead])
        }
        landReceipt(receipt)
    }
}
