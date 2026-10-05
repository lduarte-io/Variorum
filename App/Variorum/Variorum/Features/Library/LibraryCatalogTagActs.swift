//
//  LibraryCatalogTagActs.swift
//  Variorum (Mac)
//
//  **The Library catalog model's TAG ACTS**, extracted from
//  `LibraryCatalogModel.swift` at 13u4 UNIT S2 — `KnownIssuesAndTechDebt`
//  row 50's second mechanical move (the 18h ladder's R2-12 named it:
//  *"the 529-line model's tag acts are its next split"*).
//
//  A MECHANICAL move, byte-identical: not one line of these four bodies
//  changed and no test changed either, which is the parity proof (the 3C
//  pattern). They are the Library's half of the ONE tag road — the walk,
//  the validation and the refusals all live in `Shared/TypedTagPath` and
//  `TagAssignmentViewModel` (13u4 UNIT C1's hoist); what is here is the
//  BATCH semantics this surface adds over them: every post gets its turn,
//  already-tagged is a no-op, and partiality is reported.
//
//  The one line that is NOT a move is `report(_:)` on the model itself:
//  `private(set)` scopes a setter to its declaring FILE, so a split either
//  widens `lastError` to the whole module or names one door for its one
//  other writer. It names the door.
//

import Foundation
import VariorumCore

@MainActor
extension LibraryCatalogModel {
    /// R46: the addable tags surface — apply one tag to MANY posts inline.
    func applyTag(_ tagID: String, to postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.applyTag(tagID, toPost: postID)
                    } catch OperationError.alreadyTagged {
                        // Batch semantics: already-tagged is a no-op.
                    }
                }
            }
            await refresh()
        } catch {
            report(TagsViewModel.message(error))
        }
    }

    /// 13e E8 — the ADD half of her round-11 ask, through the SHIPPED
    /// type-to-create door (`TagAssignmentViewModel.applyTypedPath`, 13b
    /// 3D's N24 — the same door the context bar's `＋` uses, R6-1). So the
    /// hierarchy walk, the per-segment creation and the
    /// already-applied-is-a-no-op rule are one implementation with one set
    /// of semantics; this surface adds no tag rules of its own.
    ///
    /// The first post's turn creates whatever segments are missing and the
    /// rest find them existing, so a typed path applied to a selection
    /// mints the tag ONCE.
    func applyTypedPath(_ raw: String, to postIDs: [String]) async {
        // Ladder round B (B-2): the batch used to BREAK on the first
        // refusal in Set order — a vanished post's turn silently cost every
        // post after it, and WHICH posts got the tag depended on iteration
        // order. Now: deterministic order, every post gets its turn (the
        // REMOVE sibling's recorded forgiving-batch semantics — tagging is
        // idempotent and re-runnable; contrast the multi-delete door, whose
        // destructive act refuses whole), and partiality is REPORTED. A
        // path-shaped refusal simply fails every turn and reads as itself.
        var failed = 0
        var lastRefusal: String?
        for postID in postIDs.sorted() {
            let door = TagAssignmentViewModel(session: session, postID: postID)
            if await door.applyTypedPath(raw) == nil {
                failed += 1
                lastRefusal = door.lastError
            }
        }
        let report: String?
        if failed == 0 {
            report = nil
        } else if failed == postIDs.count {
            report = lastRefusal
        } else {
            report = "Tagged \(postIDs.count - failed) of \(postIDs.count) notes — "
                + "\(failed) refused (\(lastRefusal ?? "a note may be gone")). "
                + "The tagged ones keep the tag."
        }
        // The refresh AFTER, the report LAST — a successful `search()`
        // clears `lastError`, and the partiality report must survive it.
        await refresh()
        if let report { self.report(report) }
    }

    /// 13e E8 — the REMOVE half (*"see the posts at a high level and remove
    /// / add them"*). Keyed on the TAG the row is showing: it is drawn from
    /// the same rows this reads, and the operations layer refuses anything
    /// that changed underneath (`tagNotApplied` for a tag already taken off,
    /// which batch semantics treat as done rather than as an error — the
    /// `applyTag` mirror).
    func removeTag(_ tagID: String, from postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.removeTag(tagID, fromPost: postID)
                    } catch OperationError.tagNotApplied {
                        // Batch semantics: already off is a no-op.
                    }
                }
            }
            await refresh()
        } catch {
            report(TagsViewModel.message(error))
        }
    }

    /// The tags carried by the given notes, each once, in path order — the
    /// bulk UNTAG menu's rows (a menu offering a tag nothing selected wears
    /// would be a door that cannot act, P-2).
    func tagsOn(_ postIDs: Set<String>) -> [Tag] {
        var seen: Set<String> = []
        var result: [Tag] = []
        for postID in postIDs.sorted() {
            for tag in postTags[postID] ?? [] where seen.insert(tag.id).inserted {
                result.append(tag)
            }
        }
        return result.sorted { $0.path < $1.path }
    }
}
