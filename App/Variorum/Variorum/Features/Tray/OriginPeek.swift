//
//  OriginPeek.swift
//  Variorum (Mac)
//
//  **THE LINEAGE DOOR'S VOCABULARY** — what is left of 13j J3's peek after
//  the post-13l polish round (ledger row 17) absorbed the surface into the
//  Block History pane.
//
//  ── THE DOOR'S WHOLE HISTORY, IN THREE LANDINGS ──────────────────────────
//  13f W10b gave "See the original this came from" a navigation to Library →
//  Archived & Deleted → Unplaced blocks. Her 13j round-2 ruling removed that
//  room (*"what is that cursed table of lost hopes and dreams?"*), so the
//  door was repointed at the note's own tray as an honest bridge. 13j J3 gave
//  it its own read-only PEEK — the original's takes visible, with **Put back
//  in note** and **Open this note's tray**.
//
//  **This round is the third and last landing, and it is the honest end of
//  the sequence.** The 13l walk called the peek *"the best surface in the
//  walk"* and still filed P-3 against it: `Queries.unplacedOrigins` returns
//  an ARRAY, its own doc says a merge releases both sources, and the peek
//  took `.first` — so a door promising *"the original"* showed one of two.
//  Her C2 ruling is that the lineage door must show **ALL** of them (*"it
//  could be more than two originals even"*), and her G2 ruling put a
//  came-from region inside the Block History pane that does exactly that.
//  Two surfaces answering one question, one of them incompletely, is the
//  drift this round exists to end — so the peek's SHAPE is absorbed and its
//  WORDS stay here, where the registry's verb, the context row, the ⌘K row
//  and the pane's own region all read them.
//
//  The nested tray sheet dissolves with it (the architect's adjudication 3):
//  the pane is a side panel, so its "Open this note's tray" swaps the
//  column's occupant instead of stacking a sheet over a sheet.
//
//  The DOORS are unchanged and still exactly two, both summoned, which is
//  what her round-4 criterion asked for: the block's right-click menu and ⌘K.
//

import Foundation
import VariorumCore

nonisolated enum OriginPeekCopy {
    /// The palette's row and the registry's verb: the act with no target in
    /// hand, so it cannot name the act that released the original.
    static let genericVerb = "See the Original This Came From"

    /// The context row's words, which DO have a target — her ruled shape,
    /// "See original from divide…" / "…from merge…". An origin op the door
    /// has no word for falls back to the generic sentence rather than
    /// inventing one (`origin_op` is nullable and carries five values today).
    static func doorVerb(op: String?) -> String {
        guard let act = actWord(op) else { return "See the original this came from\u{2026}" }
        return "See original from \(act)\u{2026}"
    }

    /// The History face's quiet lineage row — "From a divide on 12 Aug — the
    /// original is preserved".
    static func lineageRow(op: String?, at: String) -> String {
        let act = actWord(op).map { "a \($0)" } ?? "an earlier change"
        guard let when = stamp(at) else {
            return "From \(act) — the original is preserved"
        }
        return "From \(act) on \(when) — the original is preserved"
    }

    /// The peek's own heading, same fact in the same words.
    static func heading(op: String?, at: String) -> String {
        lineageRow(op: op, at: at)
    }

    static let putBackVerb = "Put back in note"
    static let openTrayVerb = "Open this note's tray"

    /// What the peek says about itself, once, at the top: the original is not
    /// deleted and never was — the W preserves it whole and stands it to one
    /// side (OverallModel §7). Saying so is the whole point of the surface;
    /// her sitting question was "how do I even see the original one?"
    static let explainer =
        "This block was kept WHOLE and set aside — not deleted. It's waiting "
        + "here with its takes, and Put back returns it to the note beside "
        + "the blocks it became."

    /// The refusal for the door invoked where the block has no such original
    /// (the palette's context-blind row — fire-and-speak, P-2).
    static let noOriginHere =
        "This block wasn't divided or merged out of another one — there's no "
        + "original standing behind it."

    /// The original went somewhere while the peek was open (it was put back
    /// from the tray in another pane, or a successor moved). One honest line
    /// rather than an empty panel.
    static let originGone =
        "This original is no longer waiting here — it may already be back in "
        + "the note."

    private static func actWord(_ op: String?) -> String? {
        switch op {
        case "divide": return "divide"
        case "merge": return "merge"
        case "extract": return "extract"
        default: return nil
        }
    }

    /// The stored canonical stamp through the ONE parser, never re-parsed by
    /// hand; an unparseable stamp renders no date at all rather than raw ISO
    /// (`TrayRowPreview.stampText`'s rule).
    ///
    /// **DATE ONLY, deliberately** — and the capture is why: with the time of
    /// day in it, the lineage row read "From a merge on aug 18, 2026 at 6:30
    /// am — the original is p…", i.e. the sentence's own point fell off the
    /// end to make room for a minute nobody needs. A divide is a thing that
    /// happened on a DAY. The tray's rows keep their time (`TrayRowPreview
    /// .stampText`): "when did I delete this" is a same-day question.
    static func stamp(_ raw: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: raw) else { return nil }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
