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
//  P1: the whole-note count runs only when a selection lands EXACTLY on the
//  finder's words — a find step (or a hand selection of those very words),
//  a deliberate act whose own search already walks the note — never on a
//  keystroke (typing leaves an empty selection, which reads nothing, not even
//  the pasteboard).
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

    /// **What the readout says** — nil (nothing drawn) unless the find bar is
    /// up, a needle is armed, and the selection IS one of its matches; then
    /// that match's place among them, in the Takes bar's words ("2 of 15").
    /// The cheap gates run first: an empty selection (every keystroke) reads
    /// nothing at all.
    @MainActor
    static func face(
        barVisible: Bool, needle: @MainActor () -> Needle?, selection: NSRange, text: String
    ) -> String? {
        guard barVisible, selection.length > 0, selection.location != NSNotFound else { return nil }
        let haystack = text as NSString
        guard selection.upperBound <= haystack.length, let needle = needle() else { return nil }
        // The selection names the finder's words — the step just landed.
        guard haystack.substring(with: selection)
                .compare(needle.text, options: needle.options) == .orderedSame
        else { return nil }
        let matches = ranges(of: needle, in: text)
        guard let index = matches.firstIndex(of: selection) else { return nil }
        return TakesFindCopy.position(index + 1, of: matches.count, wrapped: false)
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
