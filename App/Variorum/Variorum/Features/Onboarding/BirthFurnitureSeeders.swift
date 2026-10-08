//
//  BirthFurnitureSeeders.swift
//  Variorum (Mac)
//
//  13s-b U1b — the two small pieces of BIRTH furniture the seed reshape
//  added beside the field guide (R-13s-5/26/27/39):
//
//    · **The example snippet** — ONE snippet in its own small group in the
//      Snippets area, carrying the standard disclaimer line (her Q17
//      disposition, R-13s-26: *"snippet ex seed - your call, yes, make it
//      that standard any resemblance to real ppl is unintentional movie
//      book etc. line"*). The tour's keep-going leg points at the first
//      snippet card; this is the card it finds on a fresh store.
//    · **The readme placeholder** (piece 2 — R-13s-39): her welcome note,
//      verbatim from `notes/plans/13s-start-here-reference.md` through the
//      second end-alternates marker, the alternates built as REAL takes,
//      her dictated closer as the final block; seeded LAST so it tops the
//      Library by recency (R-13s-29 with the letter absent). Her finished
//      text and the letter are VX-105's, post-merge.
//
//  Both follow `TutorialSeeder.seedAtBirth`'s grammar exactly: they run
//  ONLY on the Welcome arrangement's arrange-now road (a fresh store's
//  birth under the sync gate, or the `pending` resume of one — never an
//  existing store), on the QUIET facade (nothing on ⌥⌘Z), silently
//  (R-13r-11 — furniture never speaks; one log line each), and one read
//  decides: a live copy wins, then her deletion (a tombstoned container of
//  the reserved title — the `pending`-resume window is the only road a
//  deletion can precede this seed on), else the mint. No door latch: these
//  objects have no doors to race.
//
//  MOBILE PARITY: the phone seeds neither (its onboarding furniture is the
//  mobile project's own) — recorded, never built here.
//

import Dependencies
import Foundation
import GRDB
import OSLog
import VariorumCore

/// **The Snippets example scrap** (R-13s-5/26 — Q17's disposition; the
/// shape is the implementer's call, logged PROVISIONAL in the U1b record).
@MainActor
enum ExampleSnippetSeeder {
    /// The group's reserved title — the fold's identity (lowercase, the
    /// seed's casing style). A snippet always lives in a group
    /// (`container.kind='pool'`), so the example scrap gets its own small
    /// one; seeded BEFORE the guide's "tutorial scraps", it is the oldest
    /// group and therefore the Snippets rail's first.
    nonisolated static let groupTitle = "example snippets"
    /// Her ruled text, EXACTLY (R-13s-26): the standard disclaimer line.
    nonisolated static let snippetText =
        "Any resemblance to actual persons, living or dead, is purely coincidental."

    enum BirthSeed: Equatable {
        case seeded(poolID: String)
        case alreadyPresent
        case deletedByTheReader
        case refused(String)
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "birth-furniture")

    @discardableResult
    static func seedAtBirth(session: AppSession) async -> BirthSeed {
        let outcome = await perform(session: session)
        log.notice(
            "example snippet at a fresh store's birth: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(session: AppSession) async -> BirthSeed {
        do {
            let (liveID, tombstoned) = try await session.database.read { db in
                (try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM container
                        WHERE kind = 'pool' AND title = ? AND deleted_at IS NULL
                        ORDER BY id LIMIT 1
                        """,
                    arguments: [groupTitle]),
                 try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM container
                                       WHERE kind = 'pool' AND title = ?
                                         AND deleted_at IS NOT NULL)
                        """,
                    arguments: [groupTitle]) ?? false)
            }
            if liveID != nil { return .alreadyPresent }
            if tombstoned { return .deletedByTheReader }
            let poolID = try await session.runner.run { _ -> String in
                let ops = Operations(undoStack: nil)
                let pool = try ops.createPool(title: groupTitle)
                _ = try ops.newBlock(in: pool.id, text: snippetText, at: .end)
                return pool.id
            }
            return .seeded(poolID: poolID)
        } catch {
            return .refused(String(describing: error))
        }
    }
}
