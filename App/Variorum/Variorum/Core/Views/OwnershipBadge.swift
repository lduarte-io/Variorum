//
//  OwnershipBadge.swift
//  Variorum (Mac)
//
//  13i-c U4 — THE BADGE FAMILY (the sitting record §6: "the badge family —
//  direction ruled; toggleable as a set; silence the common case: in a book
//  view, the ruled shared-membership badge; in gatherings/listings/search, an
//  owned-by badge (click-through via the panel bridge). Ordinary free notes:
//  nothing, ever."). The 13i-c plan §3's badge facts; P-13ic-10's one switch
//  (`ownership_badges`, synced, default on).
//
//  The DIRECTION is the rule (the brief's item 6): the badge marks SHARED
//  membership INSIDE a book (this note also lives in other books — hover
//  names them: editing it here edits it there, §2's law made visible); the
//  OWNED-BY badge marks it OUTSIDE (a gathering, the Pool, a tag listing, the
//  Library — "owned by “X”", and a click opens that book at the note: the
//  ascent, `MembershipChip.ascend`).
//
//  Four pieces (P-9): the WORDS (`OwnershipBadgeCopy`), the RULE
//  (`OwnershipBadgeFace` — which badge, if any, a row wears: pure), the FACTS
//  (`OwnershipFactsModel` — ONE page-driven observation per listing over
//  `Queries.ownershipFacts`, ∝ the page, P1), the FACE (`OwnershipBadgeView`).
//  Shared home: five features render it.
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every word the badges say. Wording PROVISIONAL (13s); the direction is
/// ruled (§6).
nonisolated enum OwnershipBadgeCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    /// The shared badge's hover — the books, and the law it makes visible.
    static func sharedHelp(_ books: [String]) -> String {
        "Also in \(MembershipChoiceCopy.list(books)) \u{2014} editing it here edits it there too"
    }

    /// The owned-by badge's words.
    static func ownedBy(_ book: String) -> String { "owned by \(quoted(book))" }

    static func ownedByHelp(_ book: String) -> String {
        "\(quoted(book)) owns this note \u{2014} click to open the book at it"
    }

    /// **A ROW's hover, carrying its badge's sentence** (13i-c U4 walk, W-2):
    /// macOS shows the OUTERMOST help on a row whose whole face is one click
    /// target (a card's Button, a row's tap shell), so a badge's own `.help`
    /// inside it never surfaced — hovering the shared mark said "click to
    /// open this note". The row's help now says both.
    static func rowHelp(_ base: String, badge: OwnershipBadgeFace.Badge?) -> String {
        switch badge {
        case .shared(let books): return base + "\n" + sharedHelp(books)
        case .ownedBy(let book): return base + "\n" + ownedByHelp(book.name)
        case nil: return base
        }
    }
}

// MARK: - The rule (which badge a row wears)

nonisolated enum OwnershipBadgeFace {
    /// Where the row is drawn: inside a BOOK (its own view), or outside one
    /// (a gathering's view, the Pool, a tag listing, the Library).
    enum Placement: Equatable, Sendable { case inBook, outside }

    enum Badge: Equatable, Sendable {
        /// The note also lives in these OTHER books (the book view's badge).
        case shared([String])
        /// An owned book holds the note (the outside badge — click-through).
        case ownedBy(Queries.BookRef)
    }

    /// **The rule.** Silence the common case: a free note, or a note whose
    /// only book is the one being viewed, wears nothing; the setting off
    /// silences the family as a SET (P-13ic-10).
    static func badge(
        _ facts: Queries.OwnershipFacts?, placement: Placement, badgesOn: Bool
    ) -> Badge? {
        guard badgesOn, let facts else { return nil }
        switch placement {
        case .inBook:
            return facts.otherBooks.isEmpty ? nil : .shared(facts.otherBooks.map(\.name))
        case .outside:
            return facts.ownedBy.map(Badge.ownedBy)
        }
    }
}

// MARK: - The facts (one observation per listing)

/// The badge facts of ONE listing's rows, observed. The statement is
/// page-driven (`Queries.ownershipFacts` — each id seeks its own rows; the
/// work is ∝ the ids passed, never the corpus), and it reads only the
/// membership tables, so it re-runs on membership changes, never on a
/// keystroke.
@MainActor
@Observable
final class OwnershipFactsModel {
    private(set) var facts: [String: Queries.OwnershipFacts] = [:]

    init() {}

    /// Observe the facts of `postIDs` (`inBook`: the book being viewed, left
    /// out of each note's other books). Hosted by `.task(id:)` on the ids.
    func observe(session: AppSession, postIDs: [String], inBook readingID: String?) async {
        guard !postIDs.isEmpty else {
            facts = [:]
            return
        }
        do {
            for try await value in session.database.observe({ db in
                try Queries.ownershipFacts(db, postIDs: postIDs, inBook: readingID)
            }) {
                // 17y B1 (k): a re-aimed observation re-delivers the facts it
                // already holds — an unchanged answer must not re-draw every
                // row that reads it.
                if value != facts { facts = value }
            }
        } catch {
            // A failed read draws no badge — silence, never a wrong mark.
        }
    }

    /// One read — the pins' seam (a hosted `.task` does not fire under the
    /// test host), and a host that wants the facts without holding them.
    func load(session: AppSession, postIDs: [String], inBook readingID: String?) async {
        guard !postIDs.isEmpty else {
            facts = [:]
            return
        }
        facts = (try? await session.database.read { db in
            try Queries.ownershipFacts(db, postIDs: postIDs, inBook: readingID)
        }) ?? [:]
    }

    func badge(
        for postID: String, placement: OwnershipBadgeFace.Placement, badgesOn: Bool
    ) -> OwnershipBadgeFace.Badge? {
        OwnershipBadgeFace.badge(facts[postID], placement: placement, badgesOn: badgesOn)
    }
}

// MARK: - The face

/// **One badge** — the shared mark (a small glyph; hover names the books) or
/// the owned-by words (a click opens that book at the note — the ascent).
struct OwnershipBadgeView: View {
    /// The owned-by badge is the book ascent's third renderer (the context
    /// bar's book icon and the membership chip's book rows are the others).
    static let surfaceCapabilities: [CapabilityID] = [.openBookAtNote]

    let tokens: VoiceTokens
    let badge: OwnershipBadgeFace.Badge
    let postID: String

    var body: some View {
        Group {
            switch badge {
            case .shared(let books):
                Image(systemName: "square.on.square")
                    .font(.system(size: 9))
                    .foregroundStyle(tokens.faint)
                    .help(OwnershipBadgeCopy.sharedHelp(books))
                    .accessibilityLabel(OwnershipBadgeCopy.sharedHelp(books))
            case .ownedBy(let book):
                Button {
                    MembershipChip.ascend(bookID: book.id, postID: postID)
                } label: {
                    // The book's name is hers — never chrome-labelled.
                    Text(OwnershipBadgeCopy.ownedBy(book.name))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .buttonStyle(.plain)
                .help(OwnershipBadgeCopy.ownedByHelp(book.name))
            }
        }
        #if DEBUG
        .onAppear { OwnershipBadgeProbe.drawn[postID] = badge }
        .onDisappear { if OwnershipBadgeProbe.drawn[postID] == badge { OwnershipBadgeProbe.drawn[postID] = nil } }
        #endif
    }
}

#if DEBUG
/// **WHICH BADGE EACH ROW DREW, AS A TEST ORACLE** (the `PoolTuckProbe`
/// pattern): recorded on appear, cleared on disappear — an absent row is an
/// honest "no badge drawn". DEBUG only.
@MainActor
enum OwnershipBadgeProbe {
    static var drawn: [String: OwnershipBadgeFace.Badge] = [:]
    static func reset() { drawn = [:] }
}
#endif
