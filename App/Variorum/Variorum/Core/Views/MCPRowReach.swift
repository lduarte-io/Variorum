//
//  MCPRowReach.swift
//  Variorum (MAC ONLY) — Core/Views (the shared home: the Library, the
//  Timeline, the Pool, the Book Panel and the wings each hold one)
//
//  VX-268 — THE ROWS' REACH, HELD. Her report: "claude-code reaches two books,
//  the Bookcase wears the icon on both, and the Library shows nothing on those
//  books or on their notes." Every place the waiting-ask glyph marks now wears
//  the ONE shared icon too (`MCPSharedIcon`), and each host HOLDS the reach of
//  the rows it shows — so a grant made from a row's own menu, a revoke from
//  the icon's popover, a note marked Private or the open book switched shows on
//  the row at once, as it does on the Bookcase.
//
//  The reads are the core's (`Queries.mcpNoteReaches` / `mcpBookReaches` /
//  `mcpWingReaches` — the ONE rule, the batched twins of the singular reads the
//  Bookcase and the note's indicator use), sized to what the host SHOWS (P1);
//  this is only the hold. Its cost, said (`AppDatabase.observe`'s own rule): a
//  NOTE read touches `container`, which every autosave rewrites whole, so a
//  host's note hold re-runs at autosave rate while it is on screen — ONE
//  bounded batch (the window it shows), and only while an approved client holds
//  a live grant or the open book is on: otherwise the read stops at the grants
//  store and `container` is never in its region. A book or wing read never
//  touches `container`.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import VariorumCore

@MainActor
enum MCPRowReach {
    /// Hold `read` until the calling task is cancelled (a host's
    /// `.task(id:)` restarting on new rows, or its view leaving), landing each
    /// distinct answer. A failed read lands nothing — silence, never a wrong
    /// mark (the owned-by badge's rule).
    static func hold(
        _ session: AppSession,
        _ read: @escaping @Sendable (Database) throws -> [String: [MCPPlaceReach]],
        land: @escaping @MainActor ([String: [MCPPlaceReach]]) -> Void
    ) async {
        do {
            for try await value in session.database.observe(read) {
                guard !Task.isCancelled else { return }
                land(value)
            }
        } catch {}
    }
}
