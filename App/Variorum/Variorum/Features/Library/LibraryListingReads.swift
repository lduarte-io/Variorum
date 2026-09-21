//
//  LibraryListingReads.swift
//  Variorum (Mac)
//
//  **The Library listing's two bounded read-time extras**, extracted from
//  `LibraryCatalogView.swift` at 13u4 UNIT S2 — `KnownIssuesAndTechDebt`
//  row 50, the 18h ladder's R2-12: that ladder extracted the MODEL
//  (`LibraryCatalogModel.swift`) and left these two loaders in the view
//  file, naming them as F-0/P-9's next two mechanical moves. This is the
//  first of them.
//
//  A MECHANICAL move, byte-identical: not one line of either body changed
//  and no test changed either, which is the parity proof (the 3C pattern).
//  Both are `nonisolated` pure loaders over a `Database`, consumed by the
//  Library's model AND by the Pool (`PoolPostsView`) — which is the other
//  reason they do not belong in one surface's view file.
//
//  The ONE doc edit: the two orphan lines describing *"one grouped
//  tag-chip load"* sat on `NoteCards` and describe `TagChips`; they now
//  head the enum they are about. Nothing else moved.
//

import Foundation
import GRDB  // Database, Row
import VariorumCore

/// 13g batch 6 (R5-6) — the Apple-Notes-shaped row's two read-time extras.
///
/// Her ask: *"I also want to make a different view in the library that is
/// more similar to the apple notes view where you can see the first little
/// bit of text."*
///
/// NOTHING IS STORED (the no-denormalization rule): the snippet is derived
/// on every read from the blocks themselves, and the books come from the
/// membership rows. Both are **bounded twice** — to the posts already
/// listed (the catalog's own limit), and, for the snippet, to each post's
/// FIRST FEW BLOCKS via a window function, so a 10,000-block note costs the
/// same as a three-block one (P1: cost ∝ what is listed, never ∝ the note).
///
/// Two honest simplifications, recorded rather than hidden:
///   · the snippet resolves `chosen → default` and requires that variant to
///     be live; the editor's full read-time rule ALSO falls back when the
///     chosen take is archived. A snippet that goes to the next block in
///     that corner is a display aid behaving conservatively, not a second
///     rendering brain — `renderPost` remains the one that matters;
///   · **the books are CURATED memberships PLUS the smart books that collect
///     the note** (13k K4 — her ruling reversing the shipped curated-only
///     card: *"the number of specifically defined smart books you have is
///     probably small, no? you still have to choose to deliberately create a
///     smart book"*). The earlier reading — that a smart walk "must not be
///     done for forty rows" — was right about the OBVIOUS query and wrong
///     about the necessary one: `Queries.smartBookMembership` drives from the
///     PAGE (a `CROSS JOIN` over its ids, one statement per smart book) and
///     is therefore ∝ books × THE ROWS IT IS HANDED and FLAT in corpus,
///     measured at 10× and pinned on the plan. A 200-row page costs 0.15 ms
///     at her one smart book, one-shot per listing load.
///
///     **What hands it those rows changed at 18h batch 2's ladder (R2-3):**
///     it used to be "rows on screen", which meant `limitPerKind` — a hard
///     40. With a DAY armed the listing is uncapped (the day's answer is a
///     SET, R1-4), so this runs over the day's whole answer. That is still
///     what P1 asks for — cost ∝ the answer the query returned, never ∝ the
///     corpus — and a day's answer is small by construction (her own walk
///     found "30-odd" for a busy day). The accepted ceiling, said plainly: a
///     day on which she edited a thousand notes would load a thousand cards
///     per keystroke. If that day ever exists, the fix is to bound these
///     derived reads to the DRAWN window rather than to the answer.
enum NoteCards {
    struct Card: Equatable {
        /// **The note's opening blocks' text, in order** (13u3 UNIT B): the
        /// ONE fact both of the card's lines are derived from — its LEAD
        /// (`NoteCardFace`, when the note has no name of its own) and the
        /// preview under it. Raw as the read returned them, because the
        /// rendering, the trimming and the cap are the brain's and a
        /// pre-chewed string would be a second rule.
        var leadingTexts: [String] = []
        var books: [String] = []

        /// **The first block with text in it** — the shape 13g shipped and
        /// what the 13g pins still hold. A computed answer now rather than a
        /// stored second fact, so the card's words and this one can never
        /// disagree.
        var snippet: String {
            leadingTexts.lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty } ?? ""
        }
    }

    /// How many leading blocks a snippet may consult before giving up.
    nonisolated static let blockWindow = 3
    /// How much text a snippet may carry (the row shows ~2 lines).
    nonisolated static let snippetLimit = 220

    /// `includingBooks: false` reads the WORDS only — the List mode's shape
    /// (13u3 UNIT B): its row has no book-names slot, so a listing that is
    /// not drawing one must not pay for the membership reads (the smart walk
    /// included). One flag rather than a second loader.
    nonisolated static func load(
        _ db: Database, postIDs: [String], includingBooks: Bool = true
    ) throws -> [String: Card] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        var result: [String: Card] = [:]

        let snippets = try Row.fetchAll(
            db,
            sql: """
                SELECT post_id, text FROM (
                  SELECT cb.container_id AS post_id,
                         substr(COALESCE(\(Queries.renderedTakeTextSQL), ''), 1, \(snippetLimit))
                           AS text,
                         ROW_NUMBER() OVER (
                           PARTITION BY cb.container_id ORDER BY cb.position, cb.id
                         ) AS n
                  FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  -- 13u3 UNIT G (UNIT B's hand-up): the ONE resolution the
                  -- note itself renders by. This read used to be a bare
                  -- `COALESCE(cb.chosen_variant_id, b.default_variant_id)`,
                  -- which previewed an ARCHIVED chosen take's words, blanked
                  -- the card on a TOMBSTONED one, and showed another block's
                  -- prose through a FOREIGN pointer.
                  \(Queries.renderedTakeJoinSQL)
                  WHERE cb.deleted_at IS NULL
                    AND cb.container_id IN (SELECT value FROM json_each(?))
                ) WHERE n <= \(blockWindow)
                ORDER BY post_id, n
                """,
            arguments: [json])
        for row in snippets {
            let postID: String = row["post_id"]
            // Every leading slot the window returned, in its own order — the
            // brain decides which of them is a name and which is the preview
            // (13u3 UNIT B; this used to keep the first non-empty one and
            // throw the rest away, which left a card that LEADS with a
            // heading nothing to say underneath it).
            result[postID, default: Card()].leadingTexts.append(row["text"] as String? ?? "")
        }

        guard includingBooks else { return result }

        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.post_id AS post_id, r.name AS name
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL
                  AND rp.post_id IN (SELECT value FROM json_each(?))
                ORDER BY rp.post_id, r.name
                """,
            arguments: [json])
        for row in books {
            result[row["post_id"] as String, default: Card()].books.append(row["name"])
        }

        // 13k K4: the smart half, through the ONE page-driven read. Curated
        // names come FIRST (a membership row is a decision she made; a smart
        // match is one the filter made), each half already in its own
        // alphabetical order, and a name appearing in both halves shows ONCE
        // — a card row reading "Ideas, Ideas" is worse than the rare
        // ambiguity of two same-named books (a build-time call, #53(l)).
        for (postID, names) in try Queries.smartBookMembership(db, postIDs: postIDs) {
            var merged = result[postID, default: Card()].books
            for name in names where !merged.contains(name) { merged.append(name) }
            result[postID, default: Card()].books = merged
        }
        return result
    }
}

/// One grouped tag-chip load shared by the Library and the Pool (round 2
/// NIT: the per-post loops were N round trips each).
enum TagChips {
    /// 13e E8: the chips load whole TAGS, not paths. Her round-11 ask was
    /// *"see the posts at a high level and remove / add them"*, and removing
    /// needs the tag's identity — resolving a path back to an id at click
    /// time would be a second lookup that can disagree with what is drawn.
    /// One grouped query still (the round-2 NIT's rule: never N round
    /// trips), bounded to the listed posts.
    nonisolated static func load(
        _ db: Database, postIDs: [String]
    ) throws -> [String: [Tag]] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT pt.post_id AS chip_post_id, t.*
                FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.deleted_at IS NULL
                  AND pt.post_id IN (SELECT value FROM json_each(?))
                ORDER BY pt.post_id, t.path
                """,
            arguments: [json])
        var result: [String: [Tag]] = [:]
        for row in rows {
            // The join's own column is aliased so it can never collide with
            // a tag column; `Tag` decodes the rest and ignores it.
            result[row["chip_post_id"] as String, default: []].append(try Tag(row: row))
        }
        return result
    }
}
