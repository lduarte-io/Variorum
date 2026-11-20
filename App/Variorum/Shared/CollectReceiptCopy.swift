//
//  CollectReceiptCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-78 batch A (VM-21) — R98'S COLLECT RECEIPT, hoisted so the phone's
//  membership sheet speaks the Mac chip's register instead of its own stale
//  fork (MobileSoul §3). Moved verbatim from the Mac's
//  `Features/Shelf/ShelfViewModel.swift` (`BookcaseCopy`'s receipt family)
//  and `Core/Views/MembershipChoice.swift` (`AddToBookCopy.collected` and its
//  "by tagging" word). Each Mac file now EXTENDS the enum declared here, so
//  every Mac call site and pin reads exactly as before and every string is
//  byte-identical. The board's own `collectReceipt` / `alreadyShowing`, the
//  shelf verbs and the chip's other words stay in the Mac's files.
//

import Foundation
import VariorumCore

/// The receipt family a collect or a mint inside a GATHERING speaks — what
/// the act made the note wear, and whether the gathering shows it now.
nonisolated enum BookcaseCopy {
    /// VX-250 (P-VX381-1, PROVISIONAL — the kickoff's ruling): R98's collect
    /// receipt SHORTENS with the mint's, to her register (QUESTIONS #217),
    /// so the one receipt family keeps one voice.
    static func shownByTagging(_ paths: [String]) -> String {
        "Tagged " + paths.map { "#\($0)" }.joined(separator: " ") + shownNowTail
    }

    /// The receipts' shared ending — her words, #217.
    private static let shownNowTail = " \u{2014} the gathering shows it now."

    /// **VX-241 — R98's collect on an ARCHIVED gathering** (PROVISIONAL
    /// wording, for her bundle). An archived gathering assembles EMPTY
    /// everywhere (13i-e), so "shows it now" would be false; the tags ARE
    /// applied (explicit adds stay open). The receipt says both halves:
    /// what the act did, and when the gathering will show it.
    ///
    /// VX-249: a collect that also STARRED the note names the star, composed
    /// as the mint's family composes it ("Tagged #essays and starred — …",
    /// "Starred — …"), with this arm's honest tail (R-VX381-A5's composition).
    ///
    /// Ladder r1 F-7: an act that wore NOTHING reads "Added — …" (the live
    /// arm's "Added to the gathering." twin, PROVISIONAL), never "Tagged  — …"
    /// with no tag in it. Unreachable through the op today (an empty plan that
    /// isn't already met is a planner/belt disagreement, and the belt throws).
    static func taggedWhileArchived(_ paths: [String], starred: Bool = false) -> String {
        (wore(paths, starred: starred) ?? "Added") + shownAfterUnarchiveTail
    }
    /// …and when the note already matched the rule (nothing was applied).
    static let alreadyMatchesWhileArchived = "It already matches" + shownAfterUnarchiveTail
    private static let shownAfterUnarchiveTail =
        " \u{2014} the gathering shows it once it's unarchived."

    /// What the act made the note wear, as the family says it: "Tagged #a
    /// #b", "Tagged #a and starred", "Starred" — nil when it wore nothing.
    private static func wore(_ paths: [String], starred: Bool) -> String? {
        let tags = paths.map { "#\($0)" }.joined(separator: " ")
        switch (paths.isEmpty, starred) {
        case (false, false): return "Tagged " + tags
        case (false, true): return "Tagged " + tags + " and starred"
        case (true, true): return "Starred"
        case (true, false): return nil
        }
    }

    /// VX-217 — a NEW note minted inside a gathering. VX-250 (1): her SHORTER
    /// words, verbatim (QUESTIONS #217): "Tagged #essays — the gathering shows
    /// it now." · "Tagged #essays and starred — the gathering shows it now." ·
    /// "Starred — the gathering shows it now." · "Added to the gathering."
    /// Tags alone read exactly `shownByTagging`. The last arm — nothing worn —
    /// is a rule a fresh note meets as it is (a NOT-only rule, VX-250 (3)).
    static func shownByMint(_ paths: [String], starred: Bool) -> String {
        wore(paths, starred: starred).map { $0 + shownNowTail } ?? "Added to the gathering."
    }
}

/// The add-to-book doors' shared words: a gathering is joined "by tagging"
/// (R98), and what that collect did is said by `collected`.
nonisolated enum AddToBookCopy {
    static let byTagging = "by tagging"

    /// R98's collect receipt on the chip (a gathering picked "by tagging").
    /// A live gathering keeps the chip's shipped words; an ARCHIVED one —
    /// which the picker offers (13i-e: explicit adds stay open) but which
    /// assembles empty — says the honest thing (VX-241, PROVISIONAL wording:
    /// the Bookcase's own sentence). The op's in-transaction fact decides.
    ///
    /// VX-249 (R-VX381-A5, PROVISIONAL): a collect that SET the star speaks
    /// the mint's family verbatim ("Starred — the gathering shows it now." /
    /// "Tagged #x and starred — …") — the chip's tags-only words stay as
    /// shipped until VX-216 unifies its voice.
    ///
    /// VM-78 batch A (VM-21): the phone's membership sheet — the chip's twin —
    /// speaks this too.
    static func collected(_ result: Operations.SmartCollectResult, gatheringName name: String) -> String {
        if result.gatheringArchived {
            return result.alreadyMatched
                ? BookcaseCopy.alreadyMatchesWhileArchived
                : BookcaseCopy.taggedWhileArchived(result.appliedTagPaths, starred: result.starred)
        }
        if result.starred {
            return BookcaseCopy.shownByMint(result.appliedTagPaths, starred: true)
        }
        return result.alreadyMatched
            ? "Already collected \u{2014} it matches \u{201C}\(name)\u{201D}'s filter."
            : "Added by tagging \(result.appliedTagPaths.map { "#\($0)" }.joined(separator: " ")) "
                + "\u{2014} \u{201C}\(name)\u{201D} collects by filter."
    }
}
