//
//  MobileTakeStructureCopy.swift
//  VariorumMobile
//
//  Round 2, batch 7 (PL-10(d)) — WHAT THE TAKE↔BLOCK DOORS SAY on the phone.
//
//  ONE home for both receipts, for the reason the Mac's `TakeStructureCopy`
//  gives for having one: the two doors are two halves of one act (this take
//  / all the takes) and a receipt written twice is a promise no test can
//  keep.
//
//  ── WHY THIS IS A PHONE-LOCAL MIRROR AND NOT A SHARED HOME ───────────────
//
//  The Mac's twin lives in `App/Variorum/Variorum/Registry/OpsRefusalCopy
//  .swift` — the MAC TARGET, which this batch is fenced out of (QUESTIONS
//  #94: the four hoists are deferred to the post-13u merge). So this is the
//  `MobileCallout` posture, deliberately: mirror the SEMANTICS, record the
//  fork, never invent a different promise. The fork is on the KnownIssues
//  forked-brains row with its siblings.
//
//  **And one difference is not drift but the no-redirect principle**
//  (MobileSoul §4.4): the Mac's lines end *"⌥⌘Z undoes it."* This phone has
//  no chord to name — its undo road is the receipt's own Undo BUTTON
//  (`MobileEditorViewModel.StatusAction.undo`, shipped at M20) and the note
//  ⋯. So these sentences carry the FACT and the caller carries the door,
//  exactly as `MobileStructuralController.blockDeletedStatus` does. A phone
//  receipt naming a Mac keystroke would point her at a key this surface
//  cannot receive.
//
//  Every line names where the ORIGINAL went, because AR-1's whole shape is
//  that nothing is lost: the take is archived on its own block, one tap from
//  the archived list under its fan — and this sheet is where that list is.
//

import Foundation

nonisolated enum MobileTakeStructureCopy {
    /// **E5's receipt** (`takeToBlockBelow`). It points at the archived list
    /// in the SAME sheet the act was taken in — which is the phone's whole
    /// advantage here, and the reason the road is worth naming: the original
    /// is one scroll away, not on another machine.
    static let movedNote =
        "That take is now the block below — the original is archived on its "
        + "block, in the archived list under its takes."

    /// **E6b's receipt**, counts and all — including the blank takes it
    /// passed over (#58(d): they are SKIPPED, and the door says so rather
    /// than leaving her to notice a missing block).
    static func convertedNote(blocks: Int, skippedBlanks: Int) -> String {
        var line = blocks == 1
            ? "1 take is now its own block below"
            : "\(blocks) takes are now their own blocks below"
        line += " — this block still shows the take it showed, and the "
            + "originals are archived on it."
        if skippedBlanks > 0 {
            line += skippedBlanks == 1
                ? " 1 blank take was left alone (there was nothing to make a block from)."
                : " \(skippedBlanks) blank takes were left alone "
                    + "(there was nothing to make blocks from)."
        }
        return line
    }
}
