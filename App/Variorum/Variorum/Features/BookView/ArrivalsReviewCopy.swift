//
//  ArrivalsReviewCopy.swift
//  Variorum
//
//  VX-821 (the VX-808 run, Unit B3 — R-808-5, her pick "Full book area, one
//  home") — THE REVIEW AREA'S WORDS, in one home: the header, the bar, Done,
//  the calm empty answer, WHY each row waits and SINCE WHEN, and the bulk
//  doors' receipts, refusals and confirm. The row's own judgment words (Add ·
//  Dismiss · Copy In · Move In, their receipts and the operation refusals)
//  stay `ArrivalsCopy`'s — this file speaks only what the review added.
//
//  EVERY sentence here is PROVISIONAL — drafted by the implementer for her
//  bundle at the merge (the run record, Unit B3): sentence case, calm, never
//  a capital for emphasis. Her ruled words are kept exactly: the header is
//  "Arrivals — N waiting" (`ArrivalsCopy.header`, the one home both the door
//  and the review read), the doors say ADD (never "seat"), "Add all ·
//  Dismiss all", and the selection's "Add N · Dismiss N".
//

import Foundation
import VariorumCore

nonisolated enum ArrivalsReviewCopy {
    // MARK: The doors (the registry's verbs — `chromeLabel` renders them)

    static let addAllVerb = "Add all"
    static let dismissAllVerb = "Dismiss all"
    /// The selection's two acts — their declared verbs; the bar draws the
    /// count-bearing labels below ("Add 3"), the Trash bulk row's idiom.
    static let addSelectedVerb = "Add selected"
    static let dismissSelectedVerb = "Dismiss selected"

    static func addSelectedLabel(_ count: Int) -> String { "Add \(count)" }
    static func dismissSelectedLabel(_ count: Int) -> String { "Dismiss \(count)" }

    /// The bar's lead while something is picked.
    static func selected(_ count: Int) -> String { "\(count) selected" }

    static let doneVerb = "Done"

    static let addAllHelp =
        "Add every waiting note to the book \u{2014} each lands at the end, in the order they arrived"
    static let dismissAllHelp = "Dismiss every waiting note \u{2014} asks first"
    static let addSelectedHelp = "Add the selected notes to the book (\u{23CE})"
    static let dismissSelectedHelp = "Dismiss the selected notes (\u{232B})"
    static let doneHelp = "Back to the book (esc)"
    static let checkboxHelp = "Select this note \u{2014} \u{2318}-click and \u{21E7}-click work on the row too"

    /// The bar's quiet lead while nothing is picked — the keyboard, said once.
    static let keysHint =
        "\u{2191} \u{2193} walk \u{00B7} \u{23CE} adds \u{00B7} \u{232B} dismisses \u{00B7} \u{2318}A selects all"

    /// The calm answer when nothing waits (her clutter mandate: one sentence,
    /// and Done beside it).
    static let nothingWaiting =
        "Nothing is waiting. Notes this book\u{2019}s rule brings in while its dial says "
        + "\u{201C}wait at \(ArrivalsCopy.word),\u{201D} and notes an AI proposes, wait here for you."

    // MARK: Why it waits (A-808-6's nine kinds; NULL, unknown or malformed = since-when only)

    /// **WHY this row waits**, in one line — nil when the row carries no
    /// readable cause (an arrival older than the column, a newer client's
    /// kind, malformed JSON): the face then says since-when alone, never a
    /// guess. The client rides where the act was a wire client's on the four
    /// kinds that name one (proposed · rule_edit · tagged · starred).
    static func why(_ arrival: Queries.BookArrival) -> String? {
        guard let provenance = arrival.provenance, let kind = provenance.knownKind else { return nil }
        let client = provenance.client.flatMap { $0.isEmpty ? nil : $0 }
        switch kind {
        case .proposed:
            return client.map { "Proposed by \($0)" } ?? "Proposed"
        case .ruleEdit:
            return "Matched the book\u{2019}s new rule" + (client.map { ", set by \($0)" } ?? "")
        case .backfill:
            return "Matched when the book was made"
        case .catchup:
            switch provenance.after.flatMap(ArrivalProvenance.CatchUpCause.init(rawValue:)) {
            case .restore?: return "Caught up after restoring the book"
            case .reopen?: return "Caught up after reopening the book"
            case .unarchive?: return "Caught up after un-archiving"
            case .unseal?: return "Caught up after unsealing the book"
            case nil: return "Caught up when the book resumed collecting"
            }
        case .tagged:
            let tagged = arrival.tagPath.map { "Tagged #\($0)" } ?? "Tagged"
            return tagged + (client.map { " by \($0)" } ?? "")
        case .starred:
            return "Starred" + (client.map { " by \($0)" } ?? "")
        case .journalFiling:
            return "Filed for today \u{2014} another book owns it"
        case .ownedElsewhere:
            return "Came back while another book owns it"
        case .wingMend:
            return "Filed here from another wing \u{2014} the note lives with another book now"
        }
    }

    /// A proposal's own words for why (VX-811's per-note reason — the
    /// client's prose, quoted, never chrome); nil for every other cause.
    static func reason(_ arrival: Queries.BookArrival) -> String? {
        guard let provenance = arrival.provenance, provenance.knownKind == .proposed,
              let reason = provenance.reason, !reason.isEmpty
        else { return nil }
        return "\u{201C}\(reason)\u{201D}"
    }

    /// **Since when** — the app's ONE stamp vocabulary (`TimeStampFace`),
    /// read from `BookArrival.waitingSince` (a demotion's own moment, else
    /// the row's birth). nil when the stamp is unreadable: nothing rather
    /// than a lie.
    static func since(_ iso: String, now: Date) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: iso) else { return nil }
        return "waiting since " + TimeStampFace.relative(date, now: now)
    }

    /// Its hover — the whole fact (VX-351's every-speaker rule).
    static func sinceHelp(_ iso: String) -> String? {
        TimeStampFace.tooltip(labelled: "Waiting since", iso: iso)
    }

    /// **Since when, short.** The form the row's why · since line falls back
    /// to when the whole form won't fit beside the why (F-2, `ArrivalMetaFit`;
    /// PROVISIONAL P-808-B3-8): the same stamp without "waiting". nil on the
    /// same terms as `since`.
    static func sinceShort(_ iso: String, now: Date) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: iso) else { return nil }
        return "since " + TimeStampFace.relative(date, now: now)
    }

    /// **The why's hover**: the why, then the since's whole fact on its own
    /// line. When the line runs short the since gives way first (F-2), so the
    /// why's hover keeps the fact the since stops showing. With no stamp, the
    /// hover is the why alone, byte for byte.
    static func whyHelp(_ why: String, since sinceHelp: String?) -> String {
        guard let sinceHelp, !sinceHelp.isEmpty else { return why }
        return why + "\n" + sinceHelp
    }

    // MARK: The bulk doors' words (A-808-11 F-3 / F-7 — PROVISIONAL P-808-B3-2)

    /// Several landed at once — where they went (the single receipt's "at the
    /// end", unfiled where the book has chapters; an archived waiter seats as
    /// an archived member, so the receipt says where it is).
    static func addedMany(_ count: Int, chaptered: Bool, archived: Int) -> String {
        var words = "Added \(count) notes at the end of the book"
            + (chaptered ? ", \(BookPanelCopy.unfiled)." : ".")
        if archived == 1 {
            words += " One is archived, so it waits in the book\u{2019}s archived line."
        } else if archived > 1 {
            words += " \(archived) are archived, so they wait in the book\u{2019}s archived line."
        }
        return words
    }

    /// Several dismissed at once — and the road back, as the single receipt
    /// teaches it.
    static func dismissedMany(_ count: Int) -> String {
        "Dismissed \(count) notes \u{2014} they won\u{2019}t come back on their own; "
            + "add any of them by hand any time."
    }

    /// The rows Add did not run because their arms need her choice (F-4):
    /// named, kept waiting, kept selected.
    static func waitOnChoice(_ names: [String]) -> String {
        names.count == 1
            ? "\(namedList(names)) waits on your choice \u{2014} it lives in another book, so Copy In "
                + "or Move In on its row decides."
            : "\(namedList(names)) wait on your choice \u{2014} each lives in another book, so Copy In "
                + "or Move In on its row decides."
    }

    /// Rows whose OWN refusal skipped them (already judged, the note gone):
    /// the count and the first reason (the Trash's both-facts shape).
    static func couldNot(_ count: Int, act: ArrivalsBulk.Act, reason: String) -> String {
        let verb = act == .add ? "added" : "dismissed"
        return "\(count) couldn\u{2019}t be \(verb): \(reason)"
    }

    /// The rows a BOOK-level refusal left waiting (F-5: capacity, a finished
    /// or sealed book, a book gone — every later row would hear the same).
    static func stillWaiting(_ count: Int, reason: String) -> String {
        "\(count) still \(count == 1 ? "waits" : "wait"): \(reason)"
    }

    /// A selection door pressed over nothing (the door is not drawn then;
    /// this answers the race).
    static let nothingSelected = "Nothing is selected."
    /// An "all" door pressed while nothing waits (the race, again).
    static let nothingWaitingToJudge = "Nothing is waiting."

    // MARK: Dismiss all's confirm (A-808-11 F-7(a) — the guard where undo is absent)

    static func dismissAllTitle(_ count: Int) -> String {
        count == 1 ? "Dismiss the waiting note?" : "Dismiss all \(count) waiting notes?"
    }

    static func dismissAllMessage(_ count: Int) -> String {
        count == 1
            ? "It won\u{2019}t come back on its own \u{2014} you can still add it by hand."
            : "None of them will come back on their own \u{2014} you can still add any of them by hand."
    }

    static func dismissAllConfirm(_ count: Int) -> String {
        count == 1 ? "Dismiss" : "Dismiss \(count)"
    }

    static let cancelVerb = "Cancel"

    // MARK: Helpers

    /// Names, quoted, joined — at most `cap` of them, the rest counted.
    static func namedList(_ names: [String], cap: Int = 3) -> String {
        guard names.count > cap else { return MembershipChoiceCopy.list(names) }
        let shown = names.prefix(cap).map { "\u{201C}\($0)\u{201D}" }.joined(separator: ", ")
        return "\(shown) and \(names.count - cap) more"
    }
}
