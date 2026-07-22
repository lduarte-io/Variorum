//
//  CutPropagation.swift
//  Variorum
//
//  Phase 9 Step 6 — pure cut proposals for the W ceremony (the ratified
//  contract, item 3): given the active variant's snapped cut, propose a cut
//  in another take by string-context matching. A window of N UTF-16 units
//  each side of the cut (clamped to grapheme boundaries and the text's
//  edges) is located in the target take; a UNIQUE match proposes the
//  corresponding position, snapped to the nearest legal interior boundary —
//  the same "legal cut" the planner uses (13b 4A: the ruled WORD rule with
//  the gentle settle; proposals stay INTERIOR deliberately — parking a take
//  at its end is a human decision, never a seed). Zero or multiple matches
//  propose nothing: a proposal is a seed, never a guess.
//

import Foundation
import VariorumCore

nonisolated enum CutPropagation {
    static func propose(
        activeCut: Int, activeText: String, targetText: String, window: Int = 16
    ) -> Int? {
        guard let cutIndex = BoundarySnapping.graphemeIndex(atUTF16: activeCut, in: activeText)
        else { return nil }

        // The context window, whole graphemes only.
        var start = cutIndex
        var used = 0
        while start > activeText.startIndex, used < window {
            let previous = activeText.index(before: start)
            used += String(activeText[previous]).utf16.count
            start = previous
        }
        var end = cutIndex
        used = 0
        while end < activeText.endIndex, used < window {
            used += String(activeText[end]).utf16.count
            end = activeText.index(after: end)
        }
        let needle = String(activeText[start..<end])
        guard needle.contains(where: { !$0.isWhitespace }) else { return nil }

        // Locate the context in the target — unique or nothing.
        var match: Range<String.Index>?
        var searchFrom = targetText.startIndex
        while searchFrom < targetText.endIndex,
              let found = targetText.range(of: needle, range: searchFrom..<targetText.endIndex) {
            if match != nil { return nil }  // ambiguous
            match = found
            searchFrom = targetText.index(after: found.lowerBound)
        }
        guard let match else { return nil }

        let intoNeedle = String(activeText[start..<cutIndex]).utf16.count
        let matchStart = String(targetText[..<match.lowerBound]).utf16.count
        return StructuralGesturePlanner.snapToInteriorBoundary(
            matchStart + intoNeedle, in: targetText)
    }
}


/// Phase 11, A9 (#11b — the sitting ruling, 2026-07-13): the named
/// "Delete in Every Take" command's locator. UNIQUE match or nothing —
/// the #10 discipline: exactly one occurrence of the visible take's piece
/// in the target take applies; zero or several SKIP (and the command
/// reports the skip — her explicit applied-and-reported call).
nonisolated enum TakeSpanMatch {
    static func uniqueRange(of needle: String, in text: String) -> NSRange? {
        guard !needle.isEmpty else { return nil }
        let haystack = text as NSString
        let first = haystack.range(of: needle)
        guard first.location != NSNotFound else { return nil }
        let after = NSRange(
            location: first.upperBound,
            length: haystack.length - first.upperBound)
        let second = haystack.range(of: needle, options: [], range: after)
        guard second.location == NSNotFound else { return nil }  // ambiguous
        return first
    }
}
