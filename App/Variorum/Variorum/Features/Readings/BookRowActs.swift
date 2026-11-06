//
//  BookRowActs.swift
//  Variorum
//
//  VX-829 (the VX-878 run, batch 1) — **THE BOOK ROW'S ACTS THAT TWO HOSTS
//  PERFORM.** Bind into a Book… and Make a Book… ran on the Bookcase's model
//  alone (`ShelfViewModel.bind` / `.spawnBook`); since the book row menu beyond
//  the Bookcase carries the Bookcase row's doors (her ask: "the options that
//  are available in bookcase on a book should be available on library"), its
//  brain (`BookRowDoors`) performs them too. The BODY of each act lives here
//  ONCE — the operation, and the receipt it earns — and each host speaks the
//  outcome in its own way (the board keeps `lastReport` / `lastError` and its
//  board-row refusal; the brain beyond speaks on the status seam). Two callers,
//  one body: never a forked brain.
//

import Foundation
import VariorumCore

@MainActor
enum BookRowActs {
    /// **BIND INTO A BOOK** (13i-b U3 — the sitting record §3, §14.6): the
    /// SAME row becomes the book (§19.6) and it keeps collecting. Returns the
    /// receipt (13i-c U3: it names the owned-notes limb's outcome); throws the
    /// operation's own error for the host to word.
    static func bind(
        session: AppSession, readingID: String,
        ownedNotes: Operations.BindOwnedNotes = .leaveOut
    ) async throws -> String {
        let result = try await session.runner.run { ops in
            try ops.convertSmartReadingToCurated(readingID, ownedNotes: ownedNotes)
        }
        return BindCopy.bound(
            result.reading.name, count: result.membershipIDs.count,
            copied: result.copied.count, leftOut: result.leftOut.count,
            hearsActs: BindCopy.hearsActs(result.reading))
    }

    /// **MAKE A BOOK FROM THIS GATHERING** (13i-b U3 — the spawn): a SIBLING
    /// book carrying the gathering's rule, in its wing, intake on;
    /// `createReading`'s creation-time backfill seats the current matches.
    /// `outflow` is the spawn sheet's CHOSEN set; nil = the prefill. The
    /// sibling lands where every non-context mint lands — unshelved (§19).
    /// Returns the new book and its receipt; throws the op's own error.
    static func spawnBook(
        session: AppSession, from gatheringID: String, named name: String,
        outflow chosen: [String]? = nil
    ) async throws -> (bookID: String, receipt: String) {
        let database = session.database
        let (book, seated, ruleState) = try await session.runner.run {
            ops -> (Reading, Int, RuleGrammar.ReadResult) in
            guard let gathering = try database.read({
                try Queries.reading($0, id: gatheringID)
            }) else { throw OperationError.readingNotFound(id: gatheringID) }
            guard gathering.kind == .gathering else {
                throw OperationError.wrongReadingKind(id: gatheringID, expected: .gathering)
            }
            try ops.assertBookNameIsFree(name)
            let ruleState = RuleGrammar.read(gathering.querySpec)
            let outflow = try database.read { db in
                try chosen.map { ids in
                    try ids.filter { try Queries.tagIsLive(db, id: $0, wingID: gathering.wingId) }
                } ?? ShelfViewModel.spawnPrefill(db, gathering: gathering)
            }
            let book = try ops.createReading(
                name: name, kind: .book,
                querySpec: gathering.querySpec, wingId: gathering.wingId,
                autoTagIDs: outflow)
            let seated = try database.read {
                try Queries.assembleReading($0, readingID: book.id).count
            }
            return (book, seated, ruleState)
        }
        return (book.id, BindCopy.spawned(book.name, count: seated, rule: ruleState))
    }
}
