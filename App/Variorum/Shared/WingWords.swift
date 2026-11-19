//
//  WingWords.swift
//  Variorum (shared: Mac + Mobile)
//
//  13i-d U5 — the wings' platform-neutral sentences (no sentence here names a
//  Mac door — the phone's wing face is the mobile catch-up's, and it will
//  speak these). All 13s-revoicable (PROVISIONAL P-13id-U5-11).
//

import Foundation
import VariorumCore

nonisolated enum WingWords {
    /// The built-in wing's name (R-13ia-2: Home is virtual — this word is its
    /// only form).
    static let home = "Home"

    /// Lesson 11's sentence (the sitting record §25 — the tutorial pins it;
    /// the New Wing prompt says it at the door).
    static let lesson = "A wing is a separate library in the same app — a different room in "
        + "the same house. Nothing crosses between wings except what you move or copy yourself."

    /// "2 books, 1 gathering, 12 notes and 4 tags" — what a wing still holds
    /// (R-13id-2's refusal NAMES it). Zero kinds are left out.
    ///
    /// 13i-e U2 (F-U1-8's copy rider): an ARCHIVED book or gathering is kept
    /// and counted, but it is off the Bookcase — so the count says where it
    /// is: "2 books (1 archived)".
    static func contents(_ c: Queries.WingContents) -> String {
        var parts: [String] = []
        func add(_ n: Int, _ one: String, _ many: String, archived: Int = 0) {
            guard n > 0 else { return }
            let count = "\(n) \(n == 1 ? one : many)"
            parts.append(archived > 0 ? "\(count) (\(archived) \(BookArchiveCopy.word))" : count)
        }
        add(c.books, "book", "books", archived: c.archivedBooks)
        add(c.gatherings, "gathering", "gatherings", archived: c.archivedGatherings)
        add(c.notes, "note", "notes")
        add(c.tags, "tag", "tags")
        switch parts.count {
        case 0: return "nothing"
        case 1: return parts[0]
        default: return parts.dropLast().joined(separator: ", ") + " and " + parts.last!
        }
    }

    /// **The list of wings' header** (13i-d U6 (b) — the list says what a wing
    /// is). HOISTED from the Mac's `WingCopy.switcherHeader` at VM-225 (the
    /// VM-55 run, batch 4) so the phone's interim wing door says the Mac's own
    /// words over the same list; the Mac forwards here, byte for byte.
    static let switcherHeader = "Wings \u{2014} each a separate library"

    /// **Settings ▸ Tags' header** (VX-838, R-828-2 — "Tags — in ‹wing›"):
    /// the vocabulary is per wing, so the tag list says whose it is. HOISTED
    /// from the Mac's `TagManagerCopy.title` at VM-60 (the VM-55 run) so the
    /// phone's tag manager says the Mac's own words; the Mac forwards here.
    static func tagsTitle(wingName: String) -> String {
        "Tags \u{2014} in \(wingName)"
    }

    /// R-13id-2's refusal, naming what remains — and, since 13i-d U5b, the
    /// R-13id-4 ROAD (R-13id-6 item 9: "the delete refusal's words gain '— or
    /// move everything to another wing'"; P-2 — the bulk door exists now).
    /// ONE sentence for the Delete door (`name` given) and the shared refusal
    /// table (`nil` — "That wing"), so the two can never drift.
    static func notEmpty(_ name: String?, _ c: Queries.WingContents) -> String {
        let subject = name.map { "\u{201C}\($0)\u{201D}" } ?? "That wing"
        return "\(subject) still holds \(contents(c)) — move or delete them first, "
            + "then the empty wing can go — or move everything to another wing."
    }
}
