//
//  CommentDraftPark.swift
//  Variorum (Shared)
//
//  **RUN A ladder round 2, the MAJOR — a comment draft the store REFUSED
//  survives its surface's close** (the orchestrator's fork ruling: the
//  row-65 park's shape extended to the comment surfaces; PROVISIONAL,
//  QUESTIONS #140). **Amended at ladder round 3 (F2): the restore is a
//  NON-CONSUMING PEEK** — see the clear rule below.
//
//  The phone's comments sheet wiped its field on every close road — the
//  dim-tap, Done, and the projection's auto-close — including the close the
//  refusal's own sentence invites ("This note is locked — unlock it to
//  change comments": the unlock lives outside the sheet). The Mac panel's
//  drafts die with its per-presentation model the same way. Both are
//  KnownIssues row 65's class on a second and third surface: a refusal
//  preserves her words, and the close then destroys them. The sheet
//  inherited the shape honestly — it was built to "match the pad's shipped
//  pattern" BEFORE the pad had its park — which is why the fix is the
//  park's own shape and ONE brain, owned per surface (the phone's comments
//  CONTROLLER, the Mac's session), so the doors cannot drift:
//
//  · **REFUSED drafts only**, parked at REFUSAL time from the SUBMITTED
//    text — never the field's later tail, and never a draft she abandoned
//    unsubmitted (that is her ordinary abandon; guard-pinned). Parking at
//    refusal time is what covers every close road without touching any
//    close site.
//  · **ONE held draft, keyed to its block**; a refusal elsewhere REPLACES
//    it (newest wins — the bounded, recorded cost). The comment under edit
//    rides along, so a refused edit keeps its target too.
//  · **The restore is a PEEK, never a spend** (round 3's F2 — the ruling
//    amendment to binding 3, for the comment surfaces ONLY): the open of
//    the SAME block's surface reads the draft back into the box WITHOUT
//    clearing the park. The pad's clear-at-restore was safe because the
//    pad's CLOSE FILES — a close after its restore re-attempts the mint
//    and a re-refusal re-parks. These surfaces' closes never submit, so a
//    consuming restore made the reopen-then-close-without-filing road lose
//    the words for good — round 2's own class, one generation later. The
//    pad's `QuickNotePark` keeps its clear-at-restore; its premise holds
//    there.
//  · **The park clears on exactly three occasions**: a landed submit of
//    THE SAME DRAFT — identified as `(blockID, commentID)`, nil meaning
//    the add draft (the round-3 raise: a landed submit of a DIFFERENT
//    draft on the same block must not clear insurance that never landed —
//    the cross-kind arm is guard-pinned both directions); replacement by
//    a newer refusal; and the session's end.
//  · **Memory-only, deliberately** — the row-65 reasoning verbatim: the
//    refusal's commonest cause is a locked or unreachable store, which is
//    exactly the state in which no key exists to seal a persisted park.
//

import Foundation

@MainActor
final class CommentDraftPark {
    struct Held: Equatable {
        var blockID: String
        var text: String
        /// The comment under edit when the refusal struck — nil is the add
        /// draft. The edit arm's target rides the park (17b P4's second
        /// loss, kept closed across the close roads too), and it is HALF
        /// THE CLEAR KEY: the insurance clears only when this same draft
        /// lands (round 3's raise).
        var commentID: String?
        /// Why it is held: the store REFUSED it (true — every park before
        /// VX-257, and every phone park), or she LEFT it unfiled in the Mac
        /// panel's box when its host closed (false — VX-257). Only a refusal
        /// earns the restored line ("…couldn't be saved"): a draft she merely
        /// left was never refused, and the line would say so falsely.
        var refused = true
    }

    private(set) var held: Held?

    /// A refusal parks what was SUBMITTED. Newest wins, across blocks too.
    /// `refused: false` is the Mac panel's leaving (VX-257) — the same one
    /// held draft, the same newest-wins rule.
    func park(blockID: String, text: String, commentID: String?, refused: Bool = true) {
        held = Held(blockID: blockID, text: text, commentID: commentID, refused: refused)
    }

    /// **The open of the SAME block reads it back — and the park KEEPS
    /// holding it** (round 3's F2: a peek, never a spend). Another block's
    /// open gets nil and leaves it held. The insurance outlives any number
    /// of reopens she closes without filing; it lets go only through
    /// `clearIfHeld` (the same draft landed) or a newer refusal's
    /// replacement.
    func peek(forBlock blockID: String) -> Held? {
        guard let held, held.blockID == blockID else { return nil }
        return held
    }

    /// A landed submit of THE SAME DRAFT — `(blockID, commentID)` both
    /// matching (nil = the add draft): the words it insured have a row
    /// now. A landed submit of a DIFFERENT draft on the same block leaves
    /// it held (round 3's raise — clearing there would spend insurance
    /// that never landed).
    func clearIfHeld(blockID: String, commentID: String?) {
        if let held, held.blockID == blockID, held.commentID == commentID {
            self.held = nil
        }
    }

    /// The restored surface's one line — why the box is not empty. Its own
    /// register (nothing is being refused). ONE wording for both platforms,
    /// here on the brain, because two constants would be the drift class.
    /// PROVISIONAL (13s owns her voice); rides QUESTIONS #140.
    static let restoredNote = "the comment that couldn't be saved — here to try again"
}
