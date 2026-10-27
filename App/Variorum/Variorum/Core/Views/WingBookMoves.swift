//
//  WingBookMoves.swift
//  Variorum
//
//  13i-d U5b — THE BOOK-MOVE HALF's Mac doors (R-13id-6, the U5 RECORD's
//  BOOK-MOVE PROPOSAL ruled whole; her R-13id-4 backdoor). Two acts on the
//  wings' shared brain (`WingsModel` — the Bookcase row and the switcher both
//  hold the one the composition root owns):
//
//  · **Move to Wing ▸** on a Bookcase book row (books AND gatherings): the
//    other wings, Home first; never drawn on the daily Journal (item 7) nor
//    while one library stands alone (P-2). The ask reads the act's own
//    preview: a member's stay-behind membership in a FINISHED or SEALED book
//    refuses AT THE DOOR naming it (item 3(a)'s clause — P-2's fire-and-do);
//    otherwise the confirm COUNTS the notes that come (archived ones said),
//    LISTS every stay-behind membership the move severs (item 1(a)), counts
//    the waiting notes it dismisses (item 5(a)) and names a destination book
//    of the same name (8(a)'s letter). It ALWAYS asks (P-13id-U5b-4 — no
//    undo; the confirm is the net).
//  · **Move Everything to Another Wing ▸** on the switcher (ADDITIONAL wings
//    only): the confirm counts what moves and says what becomes of the wing's
//    tags — the ones that join a same-named tag, the ones made there, and,
//    NAMED, the ones nothing uses that are let go — and that the wing then
//    ends empty (item 8). She stays where she is: the emptied wing's Delete
//    is the next door (P-13id-U5b-3).
//
//  Every word is 13s-revoicable (PROVISIONAL P-13id-U5b-9).
//

import Foundation
import SwiftUI
import VariorumCore

/// The book door's DRAWING RULE — pure data the Bookcase row reads (P-2:
/// a door that can never act is not drawn), pinned.
nonisolated enum WingBookMoveDoor {
    /// Drawn while another wing exists, and never on the daily Journal (its
    /// 'daily' marker — 13i-a M-3 moves the marker with the designation, so
    /// the marker IS the daily Journal on every face).
    static func drawn(reading: Reading, destinations: Int) -> Bool {
        destinations > 0 && !Queries.isDailyJournalMintShape(reading)
    }
}

extension WingsModel {
    // MARK: - Move to Wing ▸ (a book or a gathering)

    /// What the book move's confirm says — the act's own preview.
    struct BookMoveAsk: Identifiable, Equatable {
        let readingID: String
        let name: String
        let isGathering: Bool
        let wingID: String
        let wingName: String
        let preview: Queries.BookWingMovePreview
        var id: String { readingID + "→" + wingID }
    }

    /// The book move's ask. nil = the door spoke instead (a frozen
    /// stay-behind book refuses naming it; a book gone meanwhile, or the
    /// daily Journal reached by a stale face, speaks the op's refusal).
    func bookMoveAsk(reading: Reading, to wingID: String) async -> BookMoveAsk? {
        let readingID = reading.id
        let preview = try? await session.database.read { db in
            try Queries.bookWingMovePreview(db, readingID: readingID, to: wingID)
        }
        guard let preview else {
            session.status.refuse(OpsRefusalCopy.message(
                for: OperationError.readingNotFound(id: readingID)))
            return nil
        }
        if preview.isDailyJournal {
            session.status.refuse(OpsRefusalCopy.message(
                for: OperationError.dailyJournalIsHomeOnly(id: readingID)))
            return nil
        }
        if let frozen = preview.frozen {
            session.status.refuse(WingCopy.bookFrozen(reading.name, because: frozen))
            return nil
        }
        return BookMoveAsk(
            readingID: readingID, name: reading.name, isGathering: reading.kind == .gathering,
            wingID: wingID, wingName: name(of: wingID), preview: preview)
    }

    func moveBook(_ ask: BookMoveAsk) async {
        do {
            let result = try await session.runner.run { ops in
                try ops.moveReadingToWing(ask.readingID, to: ask.wingID)
            }
            wingActLanded()  // VX-377: the window's one-shot wing reads re-ask
            session.status.receipt(WingCopy.bookMoved(
                ask.name, to: ask.wingName, notes: result.notes, isGathering: ask.isGathering))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    // MARK: - Move Everything to Another Wing ▸

    struct ContentsMoveAsk: Identifiable, Equatable {
        let sourceID: String
        let sourceName: String
        let wingID: String
        let wingName: String
        let preview: Queries.WingContentsMovePreview
        var id: String { sourceID + "→" + wingID }
    }

    /// The bulk move's ask — always from the CURRENT (additional) wing. An
    /// empty wing has nothing to move: the door says so and names the road
    /// that remains (Delete Wing…), never a confirm whose act does nothing.
    func contentsMoveAsk(to wingID: String) async -> ContentsMoveAsk? {
        let source = currentID
        guard !source.isEmpty else { return nil }
        guard let preview = try? await session.database.read({ db in
            try Queries.wingContentsMovePreview(db, from: source, to: wingID)
        }) else { return nil }
        if preview.contents.isEmpty {
            session.status.refuse(WingCopy.nothingToMove(name(of: source)))
            return nil
        }
        return ContentsMoveAsk(
            sourceID: source, sourceName: name(of: source),
            wingID: wingID, wingName: name(of: wingID), preview: preview)
    }

    func moveContents(_ ask: ContentsMoveAsk) async {
        do {
            _ = try await session.runner.run { ops in
                try ops.moveWingContents(from: ask.sourceID, to: ask.wingID)
            }
            wingActLanded()  // VX-377: the window's one-shot wing reads re-ask
            session.status.receipt(WingCopy.everythingMoved(from: ask.sourceName, to: ask.wingName))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

// MARK: - The words (13s-revoicable — PROVISIONAL P-13id-U5b-9)

nonisolated extension WingCopy {
    static let moveEverythingVerb = "Move Everything to Another Wing"
    static let bookUnavailableNote = "Moving a book to another wing acts on its row \u{2014} "
        + "right-click a book on the Bookcase."
    static let moveBookButton = "Move"
    static let moveEverythingButton = "Move Everything"

    private static func quoted(_ s: String) -> String { "\u{201C}\(s)\u{201D}" }

    private static func list(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        default: return items.dropLast().joined(separator: ", ") + " and " + items.last!
        }
    }

    // The book move.

    static func bookMoveTitle(_ name: String, to wing: String) -> String {
        "Move \(quoted(name)) to \(quoted(wing))?"
    }

    /// The confirm's message: what comes, what is severed, what is dismissed,
    /// where it lands, a twin name.
    static func bookMoveMessage(_ ask: WingsModel.BookMoveAsk) -> String {
        let p = ask.preview
        var sentences: [String] = []
        if ask.isGathering {
            // Walk W-2: never promise tags a star-only rule does not name.
            sentences.append("A gathering holds no notes \u{2014} in \(quoted(ask.wingName)) it shows "
                + "the notes there that match its rule. Any tags its rule names travel by name.")
        } else {
            if p.notes == 0 {
                sentences.append("It holds no notes.")
            } else {
                let archived = p.archived == 0 ? ""
                    : " (\(p.archived) archived \u{2014} \(p.archived == 1 ? "it stays" : "they stay") archived)"
                sentences.append("Its \(p.notes) note\(p.notes == 1 ? "" : "s") come\(p.notes == 1 ? "s" : "") "
                    + "with it\(archived), tags and all.")
            }
            // Item 1(a): every severed stay-behind membership, grouped by the
            // note's IDENTITY (walk W-1 — untitled notes are named by their
            // day, so different notes can share a name); notes whose clause
            // reads the same (same name, same books) merge with a count.
            var noteOrder: [String] = []
            var byNote: [String: (title: String, books: [String])] = [:]
            for leaves in p.alsoLeaves {
                if byNote[leaves.noteID] == nil {
                    noteOrder.append(leaves.noteID)
                    byNote[leaves.noteID] = (leaves.note, [])
                }
                byNote[leaves.noteID]?.books.append(quoted(leaves.book))
            }
            var clauseOrder: [String] = []
            var clauseCounts: [String: (title: String, books: [String], count: Int)] = [:]
            for id in noteOrder {
                guard let entry = byNote[id] else { continue }
                let key = entry.title + "\u{0}" + entry.books.joined(separator: "\u{0}")
                if let seen = clauseCounts[key] {
                    clauseCounts[key] = (seen.title, seen.books, seen.count + 1)
                } else {
                    clauseOrder.append(key)
                    clauseCounts[key] = (entry.title, entry.books, 1)
                }
            }
            if !clauseOrder.isEmpty {
                let clauses = clauseOrder.compactMap { key -> String? in
                    guard let c = clauseCounts[key] else { return nil }
                    return c.count == 1
                        ? "\(quoted(c.title)) also leaves \(list(c.books))"
                        : "\(c.count) notes called \(quoted(c.title)) also leave \(list(c.books))"
                }
                sentences.append(clauses.joined(separator: "; ")
                    + " \u{2014} a book only holds notes of its own wing.")
            }
            if p.waiting > 0 {
                // 17y B3 (h) — R-17y-2: the one word (the finish confirm's
                // sentence, shared).
                sentences.append(BookStateCopy.waitingLine(p.waiting))
            }
        }
        sentences.append("It arrives unshelved.")
        if let twin = p.nameTakenBy {
            sentences.append("\(quoted(ask.wingName)) already has one called \(quoted(twin)) "
                + "\u{2014} both keep their names.")
        }
        return sentences.joined(separator: " ")
    }

    /// Item 3(a)'s clause at the door: a member that also lives in a
    /// finished or sealed book that stays behind.
    static func bookFrozen(_ name: String, because frozen: Queries.AlsoLeaves) -> String {
        "\(quoted(frozen.note)) is also in \(quoted(frozen.book)), which is finished \u{2014} "
            + "reopen it (or unseal it) before moving \(quoted(name)) to another wing."
    }

    static func bookMoved(_ name: String, to wing: String, notes: Int, isGathering: Bool) -> String {
        if isGathering || notes == 0 { return "Moved \(quoted(name)) to \(quoted(wing))." }
        return "Moved \(quoted(name)) to \(quoted(wing)) with its \(notes) note\(notes == 1 ? "" : "s")."
    }

    // The bulk move.

    static func everythingTitle(from source: String, to wing: String) -> String {
        "Move everything in \(quoted(source)) to \(quoted(wing))?"
    }

    static func everythingMessage(_ ask: WingsModel.ContentsMoveAsk) -> String {
        let p = ask.preview
        var sentences: [String] = []
        // Walk W-2: each sentence says only what is true of what moves —
        // agreement on a single thing, the books sentence only with books,
        // the tags clause only with tags.
        let c = p.contents
        let counts = WingWords.contents(c)
        let single = c.notes + c.books + c.gatherings + c.tags == 1
        sentences.append("\(counts.prefix(1).uppercased() + counts.dropFirst()) "
            + "\(single ? "moves" : "move").")
        if c.books > 0 {
            sentences.append("Books keep their notes, chapters and waiting notes; finished and "
                + "sealed ones move as they are.")
        }
        switch (c.books, c.gatherings) {
        case (0, 0): break
        case (1, 0): sentences.append("The book arrives unshelved.")
        case (_, 0): sentences.append("Books arrive unshelved.")
        case (0, 1): sentences.append("The gathering arrives unshelved.")
        case (0, _): sentences.append("Gatherings arrive unshelved.")
        default: sentences.append("Books and gatherings arrive unshelved.")
        }
        if p.contents.tags > 0 {
            var parts: [String] = []
            if !p.tags.joins.isEmpty {
                parts.append("\(p.tags.joins.count) join\(p.tags.joins.count == 1 ? "s a tag" : " tags") "
                    + "\(quoted(ask.wingName)) already has")
            }
            if !p.tags.made.isEmpty {
                parts.append("\(p.tags.made.count) \(p.tags.made.count == 1 ? "is" : "are") made there")
            }
            if !p.tags.lettingGo.isEmpty {
                let names = list(p.tags.lettingGo.map { quoted("#" + $0) })
                parts.append("\(p.tags.lettingGo.count) nothing uses \(p.tags.lettingGo.count == 1 ? "is" : "are") "
                    + "let go \u{2014} \(names)")
            }
            sentences.append("Tags travel by name: \(list(parts)).")
        }
        if !p.nameCollisions.isEmpty {
            let names = list(p.nameCollisions.map(quoted))
            sentences.append("\(quoted(ask.wingName)) already has "
                + "\(p.nameCollisions.count == 1 ? "a book" : "books") named \(names) "
                + "\u{2014} both keep their names.")
        }
        sentences.append(c.tags > 0
            ? "\(quoted(ask.sourceName)) keeps none of its tags, so it ends empty "
                + "\u{2014} then Delete Wing\u{2026} can take it."
            : "\(quoted(ask.sourceName)) ends empty \u{2014} then Delete Wing\u{2026} can take it.")
        return sentences.joined(separator: " ")
    }

    static func everythingMoved(from source: String, to wing: String) -> String {
        "Moved everything in \(quoted(source)) to \(quoted(wing)) \u{2014} \(quoted(source)) is empty now."
    }

    static func nothingToMove(_ source: String) -> String {
        "\(quoted(source)) is already empty \u{2014} there's nothing to move. Delete Wing\u{2026} can take it."
    }
}

// MARK: - The two confirms

extension View {
    /// The book move's confirm (the Bookcase presents it).
    func wingBookMoveConfirm(
        _ pending: Binding<WingsModel.BookMoveAsk?>, wings: WingsModel?,
        onDone: @escaping () -> Void = {}
    ) -> some View {
        alert(
            pending.wrappedValue.map { WingCopy.bookMoveTitle($0.name, to: $0.wingName) } ?? "",
            isPresented: Binding(
                get: { pending.wrappedValue != nil },
                set: { if !$0 { pending.wrappedValue = nil } }),
            presenting: pending.wrappedValue
        ) { ask in
            Button(WingCopy.moveBookButton) {
                Task {
                    await wings?.moveBook(ask)
                    onDone()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { ask in
            Text(WingCopy.bookMoveMessage(ask))
        }
    }

    /// The bulk move's confirm (the switcher presents it).
    func wingContentsMoveConfirm(
        _ pending: Binding<WingsModel.ContentsMoveAsk?>, wings: WingsModel
    ) -> some View {
        alert(
            pending.wrappedValue.map { WingCopy.everythingTitle(from: $0.sourceName, to: $0.wingName) } ?? "",
            isPresented: Binding(
                get: { pending.wrappedValue != nil },
                set: { if !$0 { pending.wrappedValue = nil } }),
            presenting: pending.wrappedValue
        ) { ask in
            Button(WingCopy.moveEverythingButton) {
                Task { await wings.moveContents(ask) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { ask in
            Text(WingCopy.everythingMessage(ask))
        }
    }
}
