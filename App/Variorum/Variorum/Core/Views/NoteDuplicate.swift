//
//  NoteDuplicate.swift
//  Variorum (Mac)
//
//  **DUPLICATE A NOTE — the ONE act behind every door** (VX-372, VX-383 U1 —
//  D-C-2; the run record `notes/plans/fixes/vx-383-duplicate-note.md`). Her
//  ticket: *"a direct duplicate door, with tags / without tags; a duplicate
//  with tags counts as tagging."* Two registry acts (`.duplicateNoteWithTags`,
//  `.duplicateNoteWithoutTags`), one body: the copy family's flush-first entry
//  (`AppSession.runCopying` — a note duplicated while she is typing in it must
//  carry what she just typed, 13e E10), then `Operations.duplicateAsVersion`
//  with her tag choice (`DuplicateTags` — with tags, each live tag is APPLIED
//  through the one road, so a book that collects it may take the copy in, in
//  the same act).
//
//  `CopyForAI`'s shape and home, for its reason: every door — the File menu,
//  ⌘K, both bars' `note ▾`, the Library's and the Pool's rows, the boards'
//  inline rows — runs THIS, so no door can say something another does not.
//  The receipt says what landed and WHERE (the Pool, or the book(s) whose
//  rule took the copy in — an applied tag can do that now, so "in the Pool"
//  is no longer always true), and carries the one-press door to the copy (the
//  AI receipts' "Open ›" idiom, R-13nb-27, and R67's "the copy is one click
//  away, never hunted for"). The book chip keeps its own popover voice and
//  reads the same words (`run`).
//

import AppKit
import Foundation
import VariorumCore

@MainActor
enum NoteDuplicate {
    /// What one duplicate landed: the copy, and the words that say where.
    struct Landed: Equatable, Sendable {
        let copyID: String
        let words: String
    }

    /// **The act, for a door with its own voice** (the book chip's popover):
    /// flush, duplicate with her tag choice, then read where the copy landed
    /// (∝ the one copy's memberships and the library's readings — author-scale
    /// metadata, never the corpus). Refusals throw for the caller to word
    /// (`OpsRefusalCopy` — the op's own refusals, e.g. a blockless note).
    static func run(
        postID: String, tags: Operations.DuplicateTags, session: AppSession
    ) async throws -> Landed {
        let copy: Operations.PostCopyResult = try await session.runCopying(from: postID) { ops in
            try ops.duplicateAsVersion(postID, tags: tags)
        }
        let books = try await session.database.read { db in
            try Queries.readingsContaining(db, postID: copy.post.id)
                .filter { $0.kind == .book }
                .map(\.name)
        }
        return Landed(copyID: copy.post.id, words: DuplicateCopy.landed(tags: tags, books: books))
    }

    /// **The act, spoken on the status centre** — every door but the chip:
    /// a RECEIPT (her `receipt_style` governs where it shows) carrying the
    /// one-press door to the copy, or the operations layer's refusal in the
    /// app's words (P-2: a door that did nothing says why).
    static func perform(
        postID: String, tags: Operations.DuplicateTags, session: AppSession
    ) async {
        do {
            let landed = try await run(postID: postID, tags: tags, session: session)
            let copyID = landed.copyID
            session.status.deliver(
                landed.words, kind: .receipt,
                action: StatusCenter.Item.Action(label: DuplicateCopy.openCopy) {
                    NotificationCenter.default.post(
                        name: .variorumOpenPost, object: nil, userInfo: ["postID": copyID])
                })
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

/// **Duplicate's words, in one place** (VX-372 — sentence case, her standing
/// rule; PROVISIONAL for her VX-234 pass). `nonisolated` for `DivergeCopy`'s
/// reason: the capability table is nonisolated and reads its verbs here.
nonisolated enum DuplicateCopy {
    /// The two verbs (P-C-1) — the core's `DuplicateTags.verb`, which is also
    /// the undo entry's label, so the door, the Edit menu and ⌥⌘Z's receipt
    /// say one word.
    static let withTagsVerb = Operations.DuplicateTags.applied.verb
    static let withoutTagsVerb = Operations.DuplicateTags.none.verb

    static func verb(_ tags: Operations.DuplicateTags) -> String { tags.verb }

    /// What a door with no note in reach answers (P-2).
    static let unavailableNote =
        "Duplicating acts on the note you have open \u{2014} open one, or use a note's row in the Library."

    /// The inline doors' hover words.
    static func help(_ tags: Operations.DuplicateTags) -> String {
        switch tags {
        case .applied:
            "A full copy of this note \u{2014} takes and all, wearing its tags \u{2014} as a "
                + "new note, linked to it as a version"
        case .none:
            "A full copy of this note \u{2014} takes and all, with no tags \u{2014} as a "
                + "new note, linked to it as a version"
        }
    }

    /// The receipt's one-press door to the copy (the AI receipts' idiom).
    static let openCopy = "Open \u{203A}"

    /// **Where the copy landed.** With no tags it is always bookless (the
    /// Pool); with tags, a book whose rule hears one may have taken it in —
    /// named when it is one, counted when it is several. (An ARRIVAL is not a
    /// membership: a copy waiting at a book's Arrivals is still in the Pool,
    /// and the book's own Arrivals icon says so.)
    static func landed(tags: Operations.DuplicateTags, books: [String]) -> String {
        let lead = switch tags {
        case .applied: "Duplicated with tags"
        case .none: "Duplicated without tags"
        }
        switch books.count {
        case 0: return "\(lead) \u{2014} the copy is in the Pool."
        case 1: return "\(lead) \u{2014} the copy is in \u{201C}\(books[0])\u{201D}."
        default: return "\(lead) \u{2014} the copy is in \(books.count) books."
        }
    }
}
