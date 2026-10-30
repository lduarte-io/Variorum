//
//  OutsideWriteConfirmation.swift
//  Variorum
//
//  VX-664 (the VX-677 run, batch 1 — her ruling on the ticket, option (a)
//  scoped; the architect's A-677-1; the record `notes/plans/fixes/
//  vx-677-editor-panes-ai-door.md`): the ONE road by which a ring owner
//  turns `PaneTextAuthority`'s SUSPICION ("this delivery carries stored words
//  for the live pane's own take that it does not hold") into a ring-end.
//
//  The suspicion is read from a delivery, and a delivery can be a photograph
//  fetched before her own last write landed (the 13e E15 class): consumed
//  after the settle, it would carry words she has since replaced, and ending
//  her ring on it would drop the ring while she types. So the take's stored
//  words are read FRESH — one row by primary key (P1: ∝ one take), off the
//  main thread (P2) — and the authority's own rule decides again against
//  them (`confirmsOutsideWrite`). Only then does the owner end the ring, by
//  its own blur: VX-222/VX-440's shape (the flush is provably empty — the
//  rule requires nothing of hers pending — and the pane goes read and adopts
//  the stored words through the surface's existing read arm). A suspicion
//  the fresh read dispels changes nothing at all.
//
//  This is not a broadcast (P-4): nothing is posted or heard; each owner
//  consults stored state at its own delivery seam and decides for itself.
//

import Foundation
import GRDB
import VariorumCore

@MainActor
enum OutsideWriteConfirmation {
    /// The take's stored words NOW, or nil when the take cannot be read.
    static func storedText(of variantID: String, in database: AppDatabase) async -> String? {
        let read = try? await database.read { db in
            try Variant.fetchOne(db, key: variantID)?.workingText
        }
        return read ?? nil
    }

    /// Confirm `suspect` on a fresh read and, if the authority's rule still
    /// holds against the stored words, run the owner's ring-end. `authority`
    /// answers nil once the owner is gone; nothing then happens.
    static func endRing(
        ifConfirmed suspect: PaneTextAuthority.PaneKey?,
        in database: AppDatabase,
        authority: @escaping @MainActor () -> PaneTextAuthority?,
        isPending: @escaping @MainActor (String) -> Bool,
        endRing: @escaping @MainActor () -> Void
    ) {
        guard let suspect else { return }
        Task { @MainActor in
            guard let stored = await storedText(of: suspect.variantID, in: database),
                  let current = authority(),
                  current.confirmsOutsideWrite(suspect, storedText: stored, isPending: isPending)
            else { return }
            endRing()
        }
    }
}
