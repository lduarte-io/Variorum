//
//  PinNote.swift
//  Variorum (Mac)
//
//  VX-803 — PINNED NOTES (the run record `notes/plans/fixes/vx-808-arrivals-books.md`
//  §3, her rulings: "SEVERAL pins allowed; the pinned group floats on top and
//  orders among itself by the book's own sort"; "pins hold EVERYWHERE"). The
//  float is the book order's own (`Queries.assembleReading`); this file is the
//  act's FACE — its words, its one door body, and the mark — ruled at the B4
//  fork (A-808-12 (h)/(i)):
//
//  - ONE act (`.pinNoteInBook`) whose verb follows the membership — "Pin to
//    Top" on an unpinned note, "Unpin" on a pinned one (`.removeFromBook`'s
//    per-target shape) — rendered by the book's note-row menus (the
//    navigator's and Outline's), the Book Panel's note menu and the Index
//    row's ⋯ menu. Never on a gathering (no membership — P-2; the op refuses
//    `wrongReadingKind` too).
//  - No receipt (the act's result is the note moving on the page — the Move
//    to Chapter precedent); a refusal is the operation's own, named for the
//    book with its road (a finished book's Reopen, a sealed one's Unseal).
//  - THE MARK: a muted pin on the two tables of contents only — the
//    navigator's note rows and the Book Panel's — "one grammar at two sizes";
//    the calm page (Outline's cards, the Index, the spread, Read) stays
//    unmarked: the order itself says it there.
//
//  All words PROVISIONAL — her copy pass at the bundle. It lives in the SHARED
//  home because two features render it (the book view, the Book Panel).
//

import SwiftUI
import VariorumCore

// MARK: - The words

nonisolated enum PinNoteCopy {
    /// The registry's verb (the act's common reading — an unpinned note's).
    static let pinVerb = "Pin to Top"
    /// A pinned note's reading of the same act.
    static let unpinVerb = "Unpin"

    /// **The per-target verb** — the act is one; the word follows the pin.
    static func verb(pinned: Bool) -> String { pinned ? unpinVerb : pinVerb }

    /// The registry's refusal copy where no book context exists.
    static let unavailableNote =
        "Pinning works on a note inside a book \u{2014} open the book, then pin the note from its row."

    /// The mark's hover.
    static let markHelp = "Pinned \u{2014} stays at the top of this book"

    /// The mark's symbol (an SF Symbol — monochrome, token-coloured).
    static let markSymbol = "pin"
}

// MARK: - The one door body

@MainActor
enum PinNoteDoor {
    /// **Pin or unpin** `postID` in `book` — the one road every renderer
    /// calls. Silent on success (the note moves; no receipt); a refusal is the
    /// operation's own, said on the status seam in the book's words.
    static func setPinned(
        session: AppSession, postID: String, book: Reading, pinned: Bool
    ) async {
        do {
            try await session.runner.run { ops in
                try ops.setMembershipPinned(postID, in: book.id, pinned: pinned)
            }
        } catch {
            session.status.refuse(BookStateCopy.refusal(
                for: error, name: book.name, sealed: book.sealedAt != nil))
        }
    }
}

// MARK: - The mark

/// The muted pin a pinned note's row wears on the two tables of contents.
/// Token-drawn (no literal colour), the row's own small size, its hover the
/// one sentence. Renders nothing for an unpinned row.
struct PinMark: View {
    let pinned: Bool
    let tokens: VoiceTokens

    var body: some View {
        if pinned {
            Image(systemName: PinNoteCopy.markSymbol)
                .font(tokens.small)
                .imageScale(.small)
                .foregroundStyle(tokens.muted)
                .help(PinNoteCopy.markHelp)
                .accessibilityLabel(PinNoteCopy.markHelp)
        }
    }
}
