//
//  FindReadout.swift
//  Variorum (Mac)
//
//  **VX-441 (the VX-439 run, A-439-13) — Write's find bar says where you are:
//  "2 of 15".** Her ask (2026-10-18): *"a # of matches in find and replace
//  within write as you go down that count — so you can see if you're 2/3,
//  2/15, etc."*
//
//  THE TRACE FIRST (A-439-13's order): can AppKit's own find bar show it?
//  No. `NSTextFinder`'s bar has no count or position anywhere in its UI or its
//  strings (the macOS 27 SDK's `NSTextFinder.h`; AppKit's `TextFinder.loctable`
//  carries "Searching…", "find next", "find previous" and nothing else — the
//  run record's external-facts lookup), and the only public match surface,
//  `incrementalMatchRanges`, exists only under incremental searching, which
//  stays OFF in Write (ruled — TEXTKIT2_NOTES §3's rendering-attributes
//  class). No container or client hook can add text to the system bar. So the
//  readout is OURS, drawn muted at the bottom bar's trailing end (the status
//  seam's home), only while the find bar is up and the selection IS a match.
//
//  WHAT IT READS — nothing private, nothing of the editor's machinery:
//  · the finder's words and rule from the FIND PASTEBOARD, where NSTextFinder
//    communicates them (its search string, and its options under
//    `NSPasteboardTypeTextFinderOptions` — `NSTextFinder.h`); the app's own
//    find seed already arms the bar this way (`applyFindSeed`);
//  · the editor's string and selection (a find step SELECTS the match);
//  · the container's `isFindBarVisible` (its change reported by
//    `TypewriterScrollView`).
//
//  THE COUNT is the Takes bar's sameness rule (`TakesFindPlan.compareOptions`
//  — "Contains" + "Ignore Case", MEASURED against the real finder and pinned,
//  `TakesFindTests.theTwoBarsAgreeOnWhatAMatchIs`), with its non-overlapping
//  stepping, and the WORDS are that bar's ("2 of 15" — `TakesFindCopy`), so
//  the two bars can never call a match two things. The bar's case switch is
//  honoured (Ignore Case off ⇒ the same rule less case-folding — PROVISIONAL,
//  unmeasured); a matching kind this readout cannot honour exactly (Starts
//  With · Full Word · Ends With) draws NOTHING rather than a wrong count.
//
//  P1: the COUNT needs one walk of the note per (words, text) — that much is
//  her ask — and gets exactly one: the matches are CACHED against the finder's
//  words and the text's GENERATION (the editor bumps it on every character
//  edit), so a find step reads them with a binary search. A find step is NOT
//  itself a whole-note walk — `NSTextFinder` searches forward from the
//  selection to the NEXT match — and the readout must not make it one (the
//  VX-439 ladder's m-2 retracted this paragraph's earlier claim that a step's
//  own search "already walks the note"; it re-scanned per step, 2.6 ms at 100k
//  words, on main). The scan runs only past the cheap gates — a selection
//  landing EXACTLY on the finder's words — and never on a keystroke (typing
//  leaves an empty selection, which reads nothing, not even the pasteboard).
//

import AppKit
import Foundation

nonisolated enum FindReadout {
    /// The finder's current words and how it matches them.
    struct Needle: Equatable, Sendable {
        let text: String
        let options: NSString.CompareOptions

        static func == (lhs: Needle, rhs: Needle) -> Bool {
            lhs.text == rhs.text && lhs.options.rawValue == rhs.options.rawValue
        }
    }

    /// **The needle, from what the find pasteboard carries** — nil where
    /// nothing is armed, or where the bar is set to a matching kind this
    /// readout does not count. Absent options are the finder's defaults
    /// (Contains, Ignore Case — what the app's own find seed writes).
    static func needle(string: String?, options: [String: Any]?) -> Needle? {
        guard let string, !string.isEmpty else { return nil }
        let matching = (options?[NSPasteboard.PasteboardType.TextFinderOptionKey.textFinderMatchingTypeKey.rawValue] as? NSNumber)?.intValue
            ?? NSTextFinder.MatchingType.contains.rawValue
        guard matching == NSTextFinder.MatchingType.contains.rawValue else { return nil }
        let ignoresCase = (options?[NSPasteboard.PasteboardType.TextFinderOptionKey.textFinderCaseInsensitiveKey.rawValue] as? NSNumber)?.boolValue
            ?? true
        return Needle(
            text: string,
            options: ignoresCase
                ? TakesFindPlan.compareOptions
                : TakesFindPlan.compareOptions.subtracting(.caseInsensitive))
    }

    /// Every match of `needle` in `text`, left to right, NON-OVERLAPPING — the
    /// finder's own stepping (`TakesFindPlan.ranges`' loop, under the needle's
    /// own options).
    static func ranges(of needle: Needle, in text: String) -> [NSRange] {
        guard !needle.text.isEmpty, !text.isEmpty else { return [] }
        let haystack = text as NSString
        var found: [NSRange] = []
        var from = 0
        while from < haystack.length {
            let hit = haystack.range(
                of: needle.text, options: needle.options,
                range: NSRange(location: from, length: haystack.length - from))
            guard hit.location != NSNotFound, hit.length > 0 else { break }
            found.append(hit)
            from = hit.upperBound
        }
        return found
    }

    /// **The count's cache** (the VX-439 ladder's m-2): the matches of ONE
    /// needle in ONE text generation. Held by the caller (the editor's model),
    /// so the count's walk runs once per (words, text) and a step is a binary
    /// search over these.
    struct MatchCache: Sendable {
        let needle: Needle
        let generation: Int
        let ranges: [NSRange]
    }

    /// **What the readout says** — nil (nothing drawn) unless the find bar is
    /// up, a needle is armed, and the selection IS one of its matches; then
    /// that match's place among them, in the Takes bar's words ("2 of 15").
    /// The cheap gates run first: an empty selection (every keystroke) reads
    /// nothing at all. The matches come from `cache` when it holds this needle
    /// at this text `generation`; otherwise `scan` walks the text once and the
    /// cache keeps the answer (the tests' counting seam is `scan`).
    @MainActor
    static func face(
        barVisible: Bool, needle: @MainActor () -> Needle?, selection: NSRange, text: String,
        generation: Int, cache: inout MatchCache?,
        scan: (Needle, String) -> [NSRange] = { FindReadout.ranges(of: $0, in: $1) }
    ) -> String? {
        guard barVisible, selection.length > 0, selection.location != NSNotFound else { return nil }
        let haystack = text as NSString
        guard selection.upperBound <= haystack.length, let needle = needle() else { return nil }
        // The selection names the finder's words — the step just landed.
        guard haystack.substring(with: selection)
                .compare(needle.text, options: needle.options) == .orderedSame
        else { return nil }
        let matches: [NSRange]
        if let cached = cache, cached.needle == needle, cached.generation == generation {
            matches = cached.ranges
        } else {
            matches = scan(needle, text)
            cache = MatchCache(needle: needle, generation: generation, ranges: matches)
        }
        guard let index = place(of: selection, in: matches) else { return nil }
        return TakesFindCopy.position(index + 1, of: matches.count, wrapped: false)
    }

    /// The uncached form — one text, one look (the pure pins' shape).
    @MainActor
    static func face(
        barVisible: Bool, needle: @MainActor () -> Needle?, selection: NSRange, text: String
    ) -> String? {
        var cache: MatchCache?
        return face(
            barVisible: barVisible, needle: needle, selection: selection, text: text,
            generation: 0, cache: &cache)
    }

    /// The selection's place among the matches — a binary search: they are
    /// left to right and never overlap, so their locations ascend.
    static func place(of selection: NSRange, in matches: [NSRange]) -> Int? {
        var low = 0
        var high = matches.count
        while low < high {
            let mid = (low + high) / 2
            if matches[mid].location < selection.location { low = mid + 1 } else { high = mid }
        }
        return low < matches.count && matches[low] == selection ? low : nil
    }

    /// The live needle: the find pasteboard's string and options, read only
    /// when a gate above asks (never on a keystroke).
    @MainActor
    static func pasteboardNeedle() -> Needle? {
        let board = NSPasteboard(name: .find)
        return needle(
            string: board.string(forType: .string),
            options: board.propertyList(forType: .textFinderOptions) as? [String: Any])
    }

    /// The readout's hover (sentence case — her rule).
    static let help = "This match's place among the note's matches \u{2014} \u{2318}G next, \u{21E7}\u{2318}G previous"
}
