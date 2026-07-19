//
//  TakesModels.swift
//  Variorum
//
//  Phase 11, Step A3 — the takes/lens view family's PURE models (the
//  kickoff spike record, items 2–6). The governing vocabulary, hers:
//  VISIBLE is what you're looking at; CHOSEN is what the post is; a LENS
//  is a saved way of looking; a VERSION is a different post.
//

import Foundation
import VariorumCore

// MARK: - Columns (selection profiles)

/// What one side-by-side column looks THROUGH (spike record item 3:
/// columns are selection profiles; lenses make them durable).
enum TakesColumnKind: Equatable, Codable {
    /// The post's own chosen resolution — rendering truth's face.
    case main
    /// A view-local profile: sparse picks over chosen, persisted only via
    /// VIEW MEMORY (automatic, local, scroll-position class).
    case scratch
    /// A named, synced, LIVE-edited lens.
    case lens(String)
}

struct TakesColumn: Identifiable, Equatable, Codable {
    var id: String
    var kind: TakesColumnKind
    /// Scratch picks: blockID → variantID (sparse — un-picked slots follow
    /// chosen). Ignored for `.main`/`.lens` (a lens's picks live in the
    /// store).
    var picks: [String: String] = [:]
    /// The UNNAMED lens's display name ("Lens 1", "Lens 2"… — Sitting 9,
    /// R83: a scratch column IS an unnamed lens, visibly; auto-assigned at
    /// creation, persisted with the view memory). Named-lens columns show
    /// the lens's own name; nil on `.main`.
    var name: String?

    init(
        id: String = UUID().uuidString, kind: TakesColumnKind,
        picks: [String: String] = [:], name: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.picks = picks
        self.name = name
    }
}

// MARK: - View memory (automatic, LOCAL, scroll-position class)

/// "The view reopens as you left it" — column arrangement + the alignment
/// lock, per post, in UserDefaults (never synced, never rendering truth).
/// Fan EXPANSION state is deliberately absent: session-only (the plan's
/// letter — fans stay open once expanded within a session; nothing
/// persists).
struct TakesViewMemory: Equatable, Codable {
    var columns: [TakesColumn]
    var alignmentLocked: Bool

    static let defaultsKeyPrefix = "takesViewMemory."

    static func load(postID: String, defaults: UserDefaults = .standard) -> TakesViewMemory? {
        guard let data = defaults.data(forKey: defaultsKeyPrefix + postID) else { return nil }
        return try? JSONDecoder().decode(TakesViewMemory.self, from: data)
    }

    func save(postID: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.defaultsKeyPrefix + postID)
    }
}

// MARK: - Sameness (spike record item 4 — computed at read time, stored nowhere)

enum Sameness {
    /// Per-cell tint flags for one row of displayed texts: a byte-identical
    /// row stays QUIET (all false); in a divergent row, cells differing
    /// from the first present text TINT. `nil` texts (blank cells — an
    /// orphan row's empty side) never tint.
    static func tints(_ texts: [String?]) -> [Bool] {
        let present = texts.compactMap { $0 }
        guard let reference = present.first,
              present.contains(where: { $0 != reference })
        else { return texts.map { _ in false } }
        return texts.map { text in
            guard let text else { return false }
            return text != reference
        }
    }
}

// MARK: - Aligned posts (spike record item 6 — rows keyed by LINEAGE, never order)

/// One row of the two-post aligned composition: the anchor post's block
/// (or nil for an orphan row — a kin-less block of the other post) beside
/// its lineage kin from the other post (0 = blank, 1 = the pair, >1 = a
/// divide's span).
struct AlignmentRow: Equatable, Identifiable {
    var anchorBlockID: String?
    var otherBlockIDs: [String]
    /// True when this row's other-side kin arrive OUT of the other post's
    /// own relative order (a cross-version REORDER — the one case locked
    /// registration can't fully honor; marked, never guessed at).
    var moved: Bool
    var id: String { anchorBlockID ?? "orphan-\(otherBlockIDs.joined(separator: "+"))" }
}

enum PostAlignment {
    /// Builds the aligned rows: ANCHOR the opened post's order (round 6's
    /// answer); each other-side block lands beside its lineage kin
    /// (`kinship`: otherBlockID → anchorBlockID); kin-less other blocks
    /// become orphan rows placed after the row their PREDECESSOR landed in
    /// (keeping the other post readable top-to-bottom); anchor blocks with
    /// no kin keep a blank other side. Divides/merges align via spans and
    /// blanks regardless of counts.
    static func rows(
        anchorBlocks: [String], otherBlocks: [String], kinship: [String: String]
    ) -> [AlignmentRow] {
        let anchorIndex = Dictionary(
            uniqueKeysWithValues: anchorBlocks.enumerated().map { ($1, $0) })
        var kinByAnchor: [String: [String]] = [:]
        var movedAnchors: Set<String> = []
        /// Orphans keyed by the anchor row they follow (nil = before all).
        var orphansAfterAnchor: [String?: [[String]]] = [:]
        var pendingOrphanRun: [String] = []
        var lastAnchor: String?
        var runningMax = -1

        for other in otherBlocks {
            if let anchor = kinship[other], let index = anchorIndex[anchor] {
                if !pendingOrphanRun.isEmpty {
                    orphansAfterAnchor[lastAnchor, default: []].append(pendingOrphanRun)
                    pendingOrphanRun = []
                }
                kinByAnchor[anchor, default: []].append(other)
                if index < runningMax {
                    // The other post visits an EARLIER anchor after a later
                    // one — a cross-version reorder; mark, don't guess.
                    movedAnchors.insert(anchor)
                }
                runningMax = max(runningMax, index)
                lastAnchor = anchor
            } else {
                pendingOrphanRun.append(other)
            }
        }
        if !pendingOrphanRun.isEmpty {
            orphansAfterAnchor[lastAnchor, default: []].append(pendingOrphanRun)
        }

        var rows: [AlignmentRow] = []
        for run in orphansAfterAnchor[nil] ?? [] {
            rows.append(AlignmentRow(anchorBlockID: nil, otherBlockIDs: run, moved: false))
        }
        for anchor in anchorBlocks {
            rows.append(AlignmentRow(
                anchorBlockID: anchor,
                otherBlockIDs: kinByAnchor[anchor] ?? [],
                moved: movedAnchors.contains(anchor)))
            for run in orphansAfterAnchor[anchor] ?? [] {
                rows.append(AlignmentRow(anchorBlockID: nil, otherBlockIDs: run, moved: false))
            }
        }
        return rows
    }
}

// MARK: - Edit cost (AppSpec §10; the mobile capture helper's twin)

/// Inserted + deleted, equal weight, UTF-16 units — a whole-buffer diff by
/// common prefix/suffix, exact for any single contiguous edit. O(take) per
/// keystroke; a take is one block's text, so this is block-scale by
/// construction (P1).
enum TakeEditCost {
    nonisolated static func utf16Cost(from old: String, to new: String) -> Int {
        let oldUnits = Array(old.utf16)
        let newUnits = Array(new.utf16)
        var prefix = 0
        while prefix < oldUnits.count, prefix < newUnits.count,
              oldUnits[prefix] == newUnits[prefix] {
            prefix += 1
        }
        var suffix = 0
        while suffix < oldUnits.count - prefix, suffix < newUnits.count - prefix,
              oldUnits[oldUnits.count - 1 - suffix] == newUnits[newUnits.count - 1 - suffix] {
            suffix += 1
        }
        return (oldUnits.count - prefix - suffix) + (newUnits.count - prefix - suffix)
    }
}
