//
//  RemoveFromBook.swift
//  Variorum (Mac)
//
//  13i-c U4 — THE REMOVE / RELEASE DOORS (the sitting record §20: "REMOVING A
//  NOTE FROM A BOOK — the doors, enumerated"; §25 lesson 5). The operation is
//  one (`removePostFromReading`, a membership tombstone that answers whether
//  the note is now BOOKLESS); the VOCABULARY carries the ownership
//  distinction:
//
//  - a plain book: **"Remove from This Book"** — "the note itself is
//    untouched" (it lives on in its other books, or the Pool);
//  - an OWNED book: **"Release from This Book"** — the note goes bookless, to
//    the Pool (lesson 5: "Remove it and it goes back to the Pool, whole");
//  - a GATHERING has no remove door, because there is no membership — the
//    honest door is **"Remove the #tag"** (the rule's positive tags the note
//    wears; `removeTag`, no new op). Removing a tag is not removing a note.
//
//  ONE act (`.removeFromBook`) whose verb is a per-target function, rendered
//  by every door §20 names — the book's Index/Outline note-row menus, the
//  sidebar note box's book context, the membership chip's rows — and by
//  Manage Notes…'s row; the gathering's honest door is `.removeRuleTag`, the
//  chip's. It lives in the SHARED home because two features render it.
//

import GRDB // `Database` in the worn-tags read
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence the remove/release doors say. Wording PROVISIONAL (13s);
/// the truths are ruled (§20; lesson 5).
nonisolated enum RemoveFromBookCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    /// The registry's verb (a plain book's — the act's common reading).
    static let removeVerb = "Remove from This Book"
    /// An OWNED book's reading of the same act (§20).
    static let releaseVerb = "Release from This Book"

    /// **The per-target verb** — the act is one; the word follows the book.
    static func verb(owned: Bool) -> String { owned ? releaseVerb : removeVerb }

    /// The chip's row grammar (its "diverge" / "remove" quiet words).
    static func rowWord(owned: Bool) -> String { owned ? "release" : "remove" }

    static func help(owned: Bool, book: String) -> String {
        owned
            ? "Take this note out of \(quoted(book)) \u{2014} it owns its notes, so the note goes "
                + "back to the Pool, whole"
            : "Take this note out of \(quoted(book)) (the note itself is untouched)"
    }

    // MARK: Receipts

    /// Plain: "Removed from “X” — the note itself is untouched." — and when
    /// that left it in no book, where it is now.
    static func removed(book: String, bookless: Bool) -> String {
        let base = "Removed from \(quoted(book)) \u{2014} the note itself is untouched."
        return bookless ? base + " It\u{2019}s in the Pool now." : base
    }

    /// Owned: "Released from “X” — it's in the Pool now."
    static func released(book: String) -> String {
        "Released from \(quoted(book)) \u{2014} it\u{2019}s in the Pool now."
    }

    /// 13i-d U4: an ARCHIVED note leaving a book is NOT in the Pool (the Pool
    /// is every live, UN-archived bookless note) — it stays archived, and the
    /// receipt says so instead of the Pool sentence (the archived line's
    /// Remove door, and any remove door that reaches an archived note).
    static func receipt(
        book: String, owned: Bool, bookless: Bool, archived: Bool = false
    ) -> String {
        if archived { return leftArchived(book: book, owned: owned) }
        return owned ? released(book: book) : removed(book: book, bookless: bookless)
    }

    /// "Removed from “X” — the note itself is untouched. It stays archived." /
    /// "Released from “X” — it stays archived."
    static func leftArchived(book: String, owned: Bool) -> String {
        owned
            ? "Released from \(quoted(book)) \u{2014} it stays archived."
            : "Removed from \(quoted(book)) \u{2014} the note itself is untouched. It stays archived."
    }

    // MARK: The gathering's honest door

    /// "Remove the #path tag" — one row per worn rule tag.
    static func removeTagVerb(path: String) -> String { "Remove the #\(path) tag" }

    /// The chip's quiet row word for it.
    static func removeTagRowWord(path: String) -> String { "remove #\(path)" }

    static func removeTagHelp(gathering: String) -> String {
        "\(quoted(gathering)) holds no notes \u{2014} it shows what its rule matches. Taking "
            + "this tag off the note is the honest way out of it."
    }

    static func removedTag(path: String, gathering: String, stillShows: Bool) -> String {
        stillShows
            ? "Removed #\(path) \u{2014} \(quoted(gathering)) still shows this note through "
                + "another of its tags."
            : "Removed #\(path) \u{2014} \(quoted(gathering)) no longer shows this note."
    }

    /// The registry's honest notes.
    static let unavailableNote =
        "A note leaves a book from the book's own rows \u{2014} right-click it in the book's "
        + "Index or Outline, or use the book chip on the note."
    static let removeTagUnavailableNote =
        "A gathering holds no notes \u{2014} take the tag off the note (the book chip on the "
        + "note offers it)."
}

// MARK: - The acts

/// What a remove door's act came to — the receipt, or the operation's own
/// refusal in words (a host with its own line shows either; else the 18i
/// status seam speaks it).
nonisolated enum RemoveOutcome: Equatable, Sendable {
    case receipt(String)
    case refusal(String)

    var text: String {
        switch self {
        case .receipt(let text), .refusal(let text): return text
        }
    }
}

/// The remove/release doors' one road, shared by every renderer.
@MainActor
enum RemoveFromBookDoor {
    /// **Remove (or release)** the note from the book. A refusal is the
    /// operation's own, named for its book (a finished book's road is Reopen,
    /// a sealed one's Unseal). `speak` (the default) says the outcome on the
    /// status seam; a host with its own line passes false and shows it there.
    @discardableResult
    static func remove(
        session: AppSession, postID: String, book: Reading, speak: Bool = true
    ) async -> RemoveOutcome {
        let database = session.database
        let outcome: RemoveOutcome
        do {
            let (bookless, archived) = try await session.runner.run { ops -> (Bool, Bool) in
                let bookless = try ops.removePostFromReading(postID, from: book.id)
                // 13i-d U4: an ARCHIVED note is not in the Pool afterwards —
                // the receipt reads its state in the act's own turn (one
                // primary-key read).
                let archived = try database.read { db in
                    try Container.fetchOne(db, key: postID)?.archivedAt != nil
                }
                return (bookless, archived)
            }
            outcome = .receipt(RemoveFromBookCopy.receipt(
                book: book.name, owned: book.owned, bookless: bookless, archived: archived))
        } catch {
            outcome = .refusal(BookStateCopy.refusal(
                for: error, name: book.name, sealed: book.sealedAt != nil))
        }
        if speak { say(outcome, on: session) }
        return outcome
    }

    /// **"Remove the #tag"** — the gathering's honest door (`removeTag`).
    /// The receipt says whether the gathering still shows the note.
    @discardableResult
    static func removeTag(
        session: AppSession, postID: String, tag: VariorumCore.Tag, gathering: Reading,
        speak: Bool = true
    ) async -> RemoveOutcome {
        let database = session.database
        let outcome: RemoveOutcome
        do {
            let stillShows = try await session.runner.run { ops -> Bool in
                try ops.removeTag(tag.id, fromPost: postID)
                return try database.read { db in
                    try Queries.readingsContaining(db, postID: postID)
                        .contains { $0.id == gathering.id }
                }
            }
            outcome = .receipt(RemoveFromBookCopy.removedTag(
                path: tag.path, gathering: gathering.name, stillShows: stillShows))
        } catch {
            outcome = .refusal(TagsViewModel.message(error))
        }
        if speak { say(outcome, on: session) }
        return outcome
    }

    private static func say(_ outcome: RemoveOutcome, on session: AppSession) {
        switch outcome {
        case .receipt(let text): session.status.receipt(text)
        case .refusal(let text): session.status.refuse(text)
        }
    }

    /// **The tags behind the honest door**: the note's live tags that lie in
    /// the subtree of one of the gathering's POSITIVE rule tags (subtree
    /// matching — the sitting record §19), in the note's own tag order. A
    /// star-only rule, or a note the rule matches through a star, offers no
    /// tag door (there is no tag to take off).
    nonisolated static func wornRuleTags(
        _ db: Database, postID: String, gathering: Reading
    ) throws -> [VariorumCore.Tag] {
        let ruleIDs = RuleGrammar.positiveTagIDs(of: RuleGrammar.decode(gathering.querySpec))
        let rulePaths = try ruleIDs.compactMap { id -> String? in
            guard let tag = try VariorumCore.Tag.fetchOne(db, key: id), tag.deletedAt == nil
            else { return nil }
            return tag.path
        }
        guard !rulePaths.isEmpty else { return [] }
        return try Queries.postTags(db, postID: postID).filter { worn in
            rulePaths.contains { worn.path == $0 || worn.path.hasPrefix($0 + "/") }
        }
    }
}
