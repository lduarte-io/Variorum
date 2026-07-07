//
//  StructuralSeamEdit.swift
//  Variorum
//
//  Phase 9 — the differential rewrite's PURE half (review round 1, MINOR 5:
//  the seam→edit derivation is a pure computation and its shape-guard
//  fallbacks deserve direct tests): given the operation's known seam, the
//  pre-edit BlockRangeIndex, the pre-edit surface text of the seam entries,
//  and the fresh store projection, derive the ONE minimal storage edit +
//  attribute re-bracketing — or nil when the fresh projection doesn't match
//  what the differential edit would assume, in which case the caller
//  re-renders fully from the store (which is truth).
//
//  Three guard layers (each directly pinned in StructuralSeamEditTests):
//  1. SEAM SHAPE — counts, the seam slots' block IDs, length arithmetic.
//  2. NON-SEAM GEOMETRY (review round 2, MAJOR) — every fresh slot outside
//     the seam must correspond to its old entry under the seam's index
//     mapping: same blockID, same UTF-16 length. A concurrent write (a sync
//     pull apply can commit between the op's transaction and the fetch)
//     that moved ANY other slot's geometry would otherwise de-synchronize
//     the rebuilt index from the surface — wrong autosave offsets (the
//     forbidden store-scrambling class) and unhealable deliveries.
//  3. RETAINED BYTES (author-directed 2026-07-07, round-1 MINOR 3 follow-
//     up) — the text within the seam's scope that the edit deliberately
//     does NOT rewrite (divide's kept first half, extract's retained
//     remainder, makeBlock's kept prefix and suffix, merge's two verbatim
//     halves) must byte-match the fresh projection. Length arithmetic alone
//     passes a same-length remote rewrite of a seam entry; bytes don't.
//
//  Honestly-documented residual (deliberate; O(seam) stays O(seam), P1): a
//  same-length BYTE change to a NON-seam slot still passes — geometry stays
//  aligned, so the index is safe and autosave offsets are correct; the
//  stale surface text heals through the ordinary projection delivery, which
//  is already in flight (the concurrent apply that caused it fired the
//  observation). Checking it would be O(document) per gesture. This is the
//  same delivery-window semantics every Phase 7 projection lives under.
//
//  Never from diffing (OverallModel §8): the seam is TOLD by the op's
//  returned rows, and the derivations lean on the ops' proven trim
//  semantics — a divide's first half is a strict PREFIX of the old text, an
//  extract's remainder a strict prefix/suffix, a merge's halves verbatim —
//  now VERIFIED byte-for-byte, not merely leaned on.
//

import Foundation
import VariorumCore

/// The operation result's seam, in PRE-edit entry coordinates — what
/// changed and which fresh block IDs must appear there.
nonisolated enum StructuralSeam: Equatable, Sendable {
    /// Entry i split in place: i keeps `sourceID` (a prefix of its old
    /// text), a fresh `successorID` follows.
    case divide(entryIndex: Int, sourceID: String, successorID: String)
    /// A boundary span left entry i: `.prefix` ⇒ the extracted block lands
    /// BEFORE the source, `.suffix` ⇒ after.
    case extract(entryIndex: Int, edge: BoundarySnapping.ExtractableSpan,
                 sourceID: String, extractedID: String)
    /// Entry i became three: prefix keeps `sourceID`, then `middleID`,
    /// then `suffixID`.
    case makeBlock(entryIndex: Int, sourceID: String, middleID: String, suffixID: String)
    /// Entries i and i+1 became one fresh `mergedID`.
    case merge(leadingIndex: Int, mergedID: String)
}

nonisolated enum StructuralSeamEdit {
    /// One storage edit (pre-edit document coordinates) plus the attribute
    /// runs to lay down afterwards (post-edit document coordinates;
    /// `blockID == nil` means the run carries no block identity).
    struct Edit: Equatable {
        let replaceRange: NSRange
        let replacement: String
        let attributeRuns: [Run]

        struct Run: Equatable {
            let range: NSRange
            let blockID: String?
        }
    }

    /// `oldTextAt` supplies the PRE-edit surface text of an entry; it is
    /// consulted for SEAM entries only (O(seam), never O(document)).
    static func derive(
        _ seam: StructuralSeam,
        oldIndex old: BlockRangeIndex,
        oldTextAt: (Int) -> String,
        fresh: [Queries.RenderedBlock]
    ) -> Edit? {
        switch seam {
        case .divide(let i, let sourceID, let successorID):
            guard fresh.count == old.entries.count + 1,
                  i + 1 < fresh.count, i < old.entries.count,
                  old.entries[i].blockID == sourceID,
                  fresh[i].blockID == sourceID,
                  fresh[i + 1].blockID == successorID,
                  nonSeamAligned(old: old, fresh: fresh, seamOld: i..<(i + 1), seamFresh: i..<(i + 2))
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            let prefixLength = (fresh[i].text ?? "").utf16.count
            let successor = fresh[i + 1].text ?? ""
            guard prefixLength <= oldRange.length else { return nil }
            // Retained bytes: the kept first half must BE the old prefix.
            let oldText = oldTextAt(i) as NSString
            guard oldText.length == oldRange.length,
                  oldText.substring(to: prefixLength) == (fresh[i].text ?? "")
            else { return nil }
            // The old text beyond the (seam-trimmed) first half becomes a
            // separator + the trimmed successor.
            let replaceRange = NSRange(
                location: oldRange.location + prefixLength,
                length: oldRange.length - prefixLength)
            return Edit(
                replaceRange: replaceRange,
                replacement: EditorDocument.separator + successor,
                attributeRuns: [.init(
                    range: NSRange(location: replaceRange.location + 1, length: successor.utf16.count),
                    blockID: successorID)])

        case .extract(let i, let edge, let sourceID, let extractedID):
            guard fresh.count == old.entries.count + 1,
                  i + 1 < fresh.count, i < old.entries.count,
                  old.entries[i].blockID == sourceID,
                  nonSeamAligned(old: old, fresh: fresh, seamOld: i..<(i + 1), seamFresh: i..<(i + 2))
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            let oldText = oldTextAt(i) as NSString
            guard oldText.length == oldRange.length else { return nil }
            switch edge {
            case .prefix:
                // The extracted block lands BEFORE the source; the source's
                // remainder is a strict suffix of its old text.
                guard fresh[i].blockID == extractedID, fresh[i + 1].blockID == sourceID
                else { return nil }
                let extracted = fresh[i].text ?? ""
                let remainderLength = (fresh[i + 1].text ?? "").utf16.count
                guard remainderLength <= oldRange.length,
                      // Retained bytes: the kept remainder IS the old suffix.
                      oldText.substring(from: oldText.length - remainderLength)
                          == (fresh[i + 1].text ?? "")
                else { return nil }
                return Edit(
                    replaceRange: NSRange(
                        location: oldRange.location,
                        length: oldRange.length - remainderLength),
                    replacement: extracted + EditorDocument.separator,
                    attributeRuns: [.init(
                        range: NSRange(location: oldRange.location, length: extracted.utf16.count),
                        blockID: extractedID)])
            case .suffix:
                guard fresh[i].blockID == sourceID, fresh[i + 1].blockID == extractedID
                else { return nil }
                let remainderLength = (fresh[i].text ?? "").utf16.count
                let extracted = fresh[i + 1].text ?? ""
                guard remainderLength <= oldRange.length,
                      // Retained bytes: the kept remainder IS the old prefix.
                      oldText.substring(to: remainderLength) == (fresh[i].text ?? "")
                else { return nil }
                let replaceRange = NSRange(
                    location: oldRange.location + remainderLength,
                    length: oldRange.length - remainderLength)
                return Edit(
                    replaceRange: replaceRange,
                    replacement: EditorDocument.separator + extracted,
                    attributeRuns: [.init(
                        range: NSRange(location: replaceRange.location + 1, length: extracted.utf16.count),
                        blockID: extractedID)])
            }

        case .makeBlock(let i, let sourceID, let middleID, let suffixID):
            guard fresh.count == old.entries.count + 2,
                  i + 2 < fresh.count, i < old.entries.count,
                  old.entries[i].blockID == sourceID,
                  fresh[i].blockID == sourceID,
                  fresh[i + 1].blockID == middleID,
                  fresh[i + 2].blockID == suffixID,
                  nonSeamAligned(old: old, fresh: fresh, seamOld: i..<(i + 1), seamFresh: i..<(i + 3))
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            let prefixLength = (fresh[i].text ?? "").utf16.count
            let middle = fresh[i + 1].text ?? ""
            let suffixLength = (fresh[i + 2].text ?? "").utf16.count
            guard prefixLength + suffixLength <= oldRange.length else { return nil }
            // Retained bytes: the kept prefix AND suffix must be the old edges.
            let oldText = oldTextAt(i) as NSString
            guard oldText.length == oldRange.length,
                  oldText.substring(to: prefixLength) == (fresh[i].text ?? ""),
                  oldText.substring(from: oldText.length - suffixLength)
                      == (fresh[i + 2].text ?? "")
            else { return nil }
            let replaceRange = NSRange(
                location: oldRange.location + prefixLength,
                length: oldRange.length - prefixLength - suffixLength)
            return Edit(
                replaceRange: replaceRange,
                replacement: EditorDocument.separator + middle + EditorDocument.separator,
                attributeRuns: [
                    .init(
                        range: NSRange(location: replaceRange.location + 1, length: middle.utf16.count),
                        blockID: middleID),
                    // The untouched suffix TEXT stays put but changes
                    // identity: it belongs to the fresh suffix block now.
                    .init(
                        range: NSRange(
                            location: replaceRange.location + 1 + middle.utf16.count + 1,
                            length: suffixLength),
                        blockID: suffixID),
                ])

        case .merge(let i, let mergedID):
            guard fresh.count == old.entries.count - 1,
                  i < fresh.count, i + 1 < old.entries.count,
                  fresh[i].blockID == mergedID,
                  nonSeamAligned(old: old, fresh: fresh, seamOld: i..<(i + 2), seamFresh: i..<(i + 1))
            else { return nil }
            let lead = old.range(ofEntryAt: i)
            let trail = old.range(ofEntryAt: i + 1)
            let leadText = oldTextAt(i)
            let trailText = oldTextAt(i + 1)
            guard leadText.utf16.count == lead.length,
                  trailText.utf16.count == trail.length
            else { return nil }
            // Retained bytes: the merged text must be the two old halves
            // VERBATIM around the join — byte equality decides the join
            // kind (and subsumes the former length arithmetic).
            let merged = fresh[i].text ?? ""
            let join: String
            if merged == leadText + " " + trailText {
                join = " "
            } else if merged == leadText + trailText {
                join = ""
            } else {
                return nil
            }
            // The 1-char separator becomes the join (a space, or nothing);
            // both halves' text stays put but changes identity to A'.
            return Edit(
                replaceRange: NSRange(location: lead.upperBound, length: 1),
                replacement: join,
                attributeRuns: [.init(
                    range: NSRange(location: lead.location, length: merged.utf16.count),
                    blockID: mergedID)])
        }
    }

    /// Review round 2, MAJOR: every fresh slot OUTSIDE the seam must
    /// correspond to its old entry under the seam's index mapping — same
    /// blockID, same UTF-16 length. O(#entries) value comparisons (the same
    /// class as the index rebuild the caller already performs); text BYTES
    /// of non-seam slots are deliberately not compared (the documented
    /// residual in the header).
    private static func nonSeamAligned(
        old: BlockRangeIndex, fresh: [Queries.RenderedBlock],
        seamOld: Range<Int>, seamFresh: Range<Int>
    ) -> Bool {
        let shift = seamFresh.count - seamOld.count
        for j in 0..<old.entries.count where !seamOld.contains(j) {
            let f = j < seamOld.lowerBound ? j : j + shift
            guard f >= 0, f < fresh.count else { return false }
            let entry = old.entries[j]
            guard fresh[f].blockID == entry.blockID,
                  (fresh[f].text ?? "").utf16.count == entry.length
            else { return false }
        }
        return true
    }
}
