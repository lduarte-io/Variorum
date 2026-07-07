//
//  StructuralSeamEdit.swift
//  Variorum
//
//  Phase 9 — the differential rewrite's PURE half (review round 1, MINOR 5:
//  the seam→edit derivation is a pure computation and its shape-guard
//  fallbacks deserve direct tests): given the operation's known seam, the
//  pre-edit BlockRangeIndex, and the fresh store projection, derive the ONE
//  minimal storage edit + attribute re-bracketing — or nil when the fresh
//  projection doesn't match the seam's expected shape (a concurrent sync
//  apply landed between the op and the fetch; the caller then re-renders
//  fully from the store, which is truth).
//
//  Never from diffing (OverallModel §8): the seam is TOLD by the op's
//  returned rows, and the derivations lean on the ops' proven trim
//  semantics — a divide's first half is a strict PREFIX of the old text, an
//  extract's remainder a strict prefix/suffix, a merge's halves verbatim —
//  so the minimal changed region is exactly computable, not guessed.
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

    static func derive(
        _ seam: StructuralSeam, oldIndex old: BlockRangeIndex, fresh: [Queries.RenderedBlock]
    ) -> Edit? {
        switch seam {
        case .divide(let i, let sourceID, let successorID):
            guard fresh.count == old.entries.count + 1,
                  i + 1 < fresh.count, i < old.entries.count,
                  old.entries[i].blockID == sourceID,
                  fresh[i].blockID == sourceID,
                  fresh[i + 1].blockID == successorID
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            let prefixLength = (fresh[i].text ?? "").utf16.count
            let successor = fresh[i + 1].text ?? ""
            guard prefixLength <= oldRange.length else { return nil }
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
                  old.entries[i].blockID == sourceID
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            switch edge {
            case .prefix:
                // The extracted block lands BEFORE the source; the source's
                // remainder is a strict suffix of its old text.
                guard fresh[i].blockID == extractedID, fresh[i + 1].blockID == sourceID
                else { return nil }
                let extracted = fresh[i].text ?? ""
                let remainderLength = (fresh[i + 1].text ?? "").utf16.count
                guard remainderLength <= oldRange.length else { return nil }
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
                guard remainderLength <= oldRange.length else { return nil }
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
                  fresh[i + 2].blockID == suffixID
            else { return nil }
            let oldRange = old.range(ofEntryAt: i)
            let prefixLength = (fresh[i].text ?? "").utf16.count
            let middle = fresh[i + 1].text ?? ""
            let suffixLength = (fresh[i + 2].text ?? "").utf16.count
            guard prefixLength + suffixLength <= oldRange.length else { return nil }
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
                  fresh[i].blockID == mergedID
            else { return nil }
            let lead = old.range(ofEntryAt: i)
            let trail = old.range(ofEntryAt: i + 1)
            let mergedLength = (fresh[i].text ?? "").utf16.count
            let join = mergedLength - lead.length - trail.length
            guard join == 0 || join == 1 else { return nil }
            // The 1-char separator becomes the join (a space, or nothing);
            // both halves' text stays put but changes identity to A'.
            return Edit(
                replaceRange: NSRange(location: lead.upperBound, length: 1),
                replacement: join == 1 ? " " : "",
                attributeRuns: [.init(
                    range: NSRange(location: lead.location, length: mergedLength),
                    blockID: mergedID)])
        }
    }
}
