//
//  TagDeletionCopy.swift
//  Variorum — SHARED (both platforms)
//
//  **THE TAG-DELETE CONFIRM'S WORDS, HOISTED** (VX-221, 2026-10-13 — the run
//  record `notes/plans/fixes/vx-214-settings-launch-polish.md`, BATCH 3; the
//  13u4 UNIT C1 `TypedTagPath` precedent).
//
//  The phone's tag manager has confirmed this act since the parity round
//  (C3) with the consequence named; the Mac deleted on one click from a
//  context row. VX-221 gives the Mac a visible delete door and ONE confirm for
//  both of its doors — and the Mac ADOPTS the phone's already-ruled sentence
//  rather than writing a second one (two copies of one sentence is the
//  forked-brains drift class). `MobileTagsModel` keeps its two pre-move names
//  as forwarders, so no test on either platform moved (the 3C parity pattern
//  — a zero-test-edit run is the proof the hoist moved an address, not a
//  behaviour).
//
//  Why it confirms at all: the confirmation-consistency principle (13j,
//  written at 13l — recoverability × scale): a tag delete takes the whole
//  subtree off every note, and it has no restore road (VX-238).
//
//  VX-247 (Part of VX-381 — R-VX381-A3, PROVISIONAL): the delete gained ONE
//  structural-undo entry ("Undo Delete Tag" — ⌥⌘Z on the Mac, the note ⋯
//  sheet's undo on the phone: the same session stack), so the consequence's
//  old last sentence, "There is no undo for this.", was false on both
//  platforms and is DROPPED; the confirm still names the consequence. The
//  recorded alternative is a true line naming the road ("You can undo this
//  with Undo Delete Tag.").
//

import Foundation
import VariorumCore

nonisolated enum TagDeletion {
    /// The confirm's title — the phone's alert says the same.
    static let confirmTitle = "Delete Tag?"
    /// The confirm's destructive button.
    static let confirmVerb = "Delete"

    /// How many live tags sit UNDER this one (the subtree the delete takes
    /// along) — pure over the listed taxonomy, the same prefix rule the op's
    /// own SQL applies.
    static func subtreeCount(of tag: Tag, in all: [Tag]) -> Int {
        let prefix = tag.path + "/"
        return all.count { $0.path.hasPrefix(prefix) }
    }

    /// The confirm's message — the CONSEQUENCE named, never a platform (the
    /// C3 brief's letter). Two arms: a leaf tag, and a tag carrying a subtree.
    static func consequence(name: String, subtreeCount: Int) -> String {
        if subtreeCount == 0 {
            return "Deleting “\(name)” takes it off every note that wears it."
        }
        let word = subtreeCount == 1 ? "sub-tag" : "sub-tags"
        return "Deleting “\(name)” also deletes its \(subtreeCount) \(word) — "
            + "every note wearing any of them loses those tags."
    }
}
