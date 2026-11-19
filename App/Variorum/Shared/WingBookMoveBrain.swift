//
//  WingBookMoveBrain.swift
//  Variorum (shared: Mac + Mobile)
//
//  13i-d U5b — THE BOOK-MOVE HALF of the wings' brain (R-13id-6, the U5
//  RECORD's BOOK-MOVE PROPOSAL ruled whole; her R-13id-4 backdoor): a book or
//  a gathering's Move to Wing, and Move Everything to Another Wing, each an
//  ask that reads the act's own preview and an act that speaks its receipt.
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — moved here from the
//  Mac's `Core/Views/WingBookMoves.swift` with the brain it extends
//  (`Shared/WingsModel.swift`), byte for byte but for the one words seam (a
//  refusal speaks `refusalWords`, the platform's — the Mac's are exactly the
//  `OpsRefusalCopy.message(for:)` it spoke before) — and with them the book
//  door's drawing rule (`WingBookMoveDoor` — pure data naming no Mac type:
//  whether a book's Move to Wing can act at all). The Mac's file keeps the
//  Mac's verbs and the two confirms — their faces and the titles and messages
//  they show. The words below are the ones the ACTS speak.
//

import Foundation
import VariorumCore

/// The book door's DRAWING RULE — pure data the Bookcase row reads (P-2:
/// a door that can never act is not drawn), pinned.
nonisolated enum WingBookMoveDoor {
    /// Drawn while another wing exists — on EVERY book and gathering, the
    /// daily Journal included since VX-435 (the VX-805 run: one Journal per
    /// store, movable to any wing; its entries move with it). `reading` stays
    /// in the signature so a future per-book rule has its one home here.
    static func drawn(reading: Reading, destinations: Int) -> Bool {
        _ = reading
        return destinations > 0
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
    /// stay-behind book refuses naming it; a book gone meanwhile speaks the
    /// op's refusal).
    func bookMoveAsk(reading: Reading, to wingID: String) async -> BookMoveAsk? {
        let readingID = reading.id
        let preview = try? await session.database.read { db in
            try Queries.bookWingMovePreview(db, readingID: readingID, to: wingID)
        }
        guard let preview else {
            session.status.refuse(refusalWords(OperationError.readingNotFound(id: readingID)))
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
            session.status.refuse(refusalWords(error))
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
            session.status.refuse(refusalWords(error))
        }
    }
}

// MARK: - The words the acts speak (13s-revoicable — PROVISIONAL P-13id-U5b-9)

nonisolated extension WingCopy {
    private static func quoted(_ s: String) -> String { "\u{201C}\(s)\u{201D}" }

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

    static func everythingMoved(from source: String, to wing: String) -> String {
        "Moved everything in \(quoted(source)) to \(quoted(wing)) \u{2014} \(quoted(source)) is empty now."
    }

    static func nothingToMove(_ source: String) -> String {
        "\(quoted(source)) is already empty \u{2014} there's nothing to move. Delete Wing\u{2026} can take it."
    }
}
