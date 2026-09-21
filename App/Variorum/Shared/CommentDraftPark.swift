//
//  CommentDraftPark.swift
//  Variorum (Shared)
//
//  **RUN A ladder round 2, the MAJOR — a comment draft the store REFUSED
//  survives its surface's close** (the orchestrator's fork ruling: the
//  row-65 park's shape extended to the comment surfaces; PROVISIONAL,
//  QUESTIONS #140).
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
//  · **The next open of the SAME block's surface takes it back** and the
//    park clears in the same breath — the surface becomes the only home
//    again; a re-refusal re-parks. A different block's open shows nothing
//    of it and leaves it held.
//  · **A landed submit of the parked block clears it** — a draft with a
//    row must never come back as a ghost. Any refused draft still standing
//    at that moment lives in the OPEN surface and re-parks at its own next
//    refusal.
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
        /// loss, kept closed across the close roads too).
        var commentID: String?
    }

    private(set) var held: Held?

    /// A refusal parks what was SUBMITTED. Newest wins, across blocks too.
    func park(blockID: String, text: String, commentID: String?) {
        held = Held(blockID: blockID, text: text, commentID: commentID)
    }

    /// The next open of the SAME block takes it — and the park lets go in
    /// the same breath (no ghost, no double restore). Another block's open
    /// leaves it held and gets nil.
    func take(forBlock blockID: String) -> Held? {
        guard let held, held.blockID == blockID else { return nil }
        defer { self.held = nil }
        return held
    }

    /// A landed submit of the parked block: the words have a row now.
    func clearIfHeld(blockID: String) {
        if held?.blockID == blockID { held = nil }
    }

    /// The restored surface's one line — why the box is not empty. Its own
    /// register (nothing is being refused). ONE wording for both platforms,
    /// here on the brain, because two constants would be the drift class.
    /// PROVISIONAL (13s owns her voice); rides QUESTIONS #140.
    static let restoredNote = "the comment that couldn't be saved — here to try again"
}
