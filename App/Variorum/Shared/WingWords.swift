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
    static func contents(_ c: Queries.WingContents) -> String {
        var parts: [String] = []
        func add(_ n: Int, _ one: String, _ many: String) {
            if n > 0 { parts.append("\(n) \(n == 1 ? one : many)") }
        }
        add(c.books, "book", "books")
        add(c.gatherings, "gathering", "gatherings")
        add(c.notes, "note", "notes")
        add(c.tags, "tag", "tags")
        switch parts.count {
        case 0: return "nothing"
        case 1: return parts[0]
        default: return parts.dropLast().joined(separator: ", ") + " and " + parts.last!
        }
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
