//
//  SearchLanding.swift
//  Variorum (Shared)
//
//  **13o U2 — LAND-AT-MATCH's value and its pure rules** (D6; her ruled
//  behavior from the 13o mockup's shared section: *"Clicking a passage opens
//  the note at that block with the match selected and the find bar armed, so
//  ⌘G keeps stepping"*). The `LandingTarget` precedent one file over: the
//  value a search hit hands the surface it lands in, carrying no decision —
//  which surface lands and how is the consumer's (the Mac's Write editor:
//  `EditorViewModel.applyFindSeed`, through its own find doors).
//
//  Shared because two features hand it over (the Library's answer sheet and
//  the ⌘K palette) and the shell carries it (`ShellRouter.BlockLanding`) —
//  and because the phone's search face (the mobile catch-up's) will hand the
//  same value to its own editor.
//

import Foundation
import VariorumCore

/// **What a search passage hands the editor it lands in.** A ONE-SHOT seed
/// beside the caret's, applied once at the arriving editor's first render.
///
/// `needle` is the matched words AS THE INDEX MARKED THEM in the passage's
/// snippet — the text as written, so a literal find meets it even though the
/// index folds case and accents (R-13o-11). `steps` says the match is in the
/// text the note SHOWS (a rendered take): the editor selects it. An
/// unrendered take's hit only ARMS the find bar — its words are not on the
/// page to select (PROVISIONAL P-13o-U2-4).
nonisolated struct EditorFindSeed: Equatable, Hashable, Sendable {
    let needle: String
    let steps: Bool
}

nonisolated enum SearchLanding {
    /// **The find seed a passage lands with** (D6): a TAKE's first matched
    /// run, as the index marked it in the snippet; it STEPS (is selected)
    /// only in the take the note shows (P-13o-U2-4). A name, label or comment
    /// hit lands at its block with no seed — its words are not in the prose.
    static func findSeed(
        kind: SearchPassage.Kind, rendered: Bool, snippet: [SearchSnippetSegment]
    ) -> EditorFindSeed? {
        guard kind == .take,
              let run = snippet.first(where: \.isMatch)?.text
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !run.isEmpty else { return nil }
        return EditorFindSeed(needle: run, steps: rendered)
    }
}

/// The seed's editor-side pure half (pinned): where the needle sits in the
/// surface's text, from the landed block's start onward.
nonisolated enum FindSeedLanding {
    /// The first occurrence of `needle` at or after `start` — the literal
    /// text first (the snippet's words ARE the source's), then folding case
    /// and diacritics (the index's own sameness, should the buffer differ in
    /// either); nil when the words are not there.
    static func range(of needle: String, in text: String, from start: Int) -> NSRange? {
        let haystack = text as NSString
        guard !needle.isEmpty, start >= 0, start <= haystack.length else { return nil }
        let rest = NSRange(location: start, length: haystack.length - start)
        for options: NSString.CompareOptions in [.literal, [.caseInsensitive, .diacriticInsensitive]] {
            let found = haystack.range(of: needle, options: options, range: rest)
            if found.location != NSNotFound { return found }
        }
        return nil
    }
}
