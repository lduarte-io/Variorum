//
//  TimelineVoiceTests.swift
//  VariorumTests
//
//  **13u4 UNIT S2 — `KnownIssuesAndTechDebt` row 54:** *"The Library's
//  TIMELINE rows render in a SANS face, not the voice's type — the same
//  dates are monospaced in List and sans in Timeline."* Found by 18j's dark
//  sweep and re-seen in Study at its ladder: a VOICE defect, not a dark
//  one, reading identically wrong in the light.
//
//  A typeface is a thing you SEE, so the acceptance evidence is the walk
//  (both voices, both appearances — the unit record's table). What is
//  pinnable, and is pinned here, is the two things that would let it come
//  back silently:
//
//    1. **no system-font / system-tier call survives in the file** — the
//       exact forms the rows used (`.font(.caption)`, `.font(.caption2)`,
//       `.foregroundStyle(.secondary)`, `.foregroundStyle(.tertiary)`), in
//       the 18j literal-colour pin's own grep form;
//    2. **which stamp each lens is about** is the Library's ONE rule, not a
//       second copy of it — because the fix also stopped this list printing
//       the RAW stored column beside the Library's worded stamps (the 18h
//       ladder's R3-2, met a third time one mode over).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The Library's Timeline wears the voice (13u4 UNIT S2 — row 54)")
struct TimelineVoiceTests {
    private static var timelineSource: String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum/Features/Timeline/TimelineView.swift")
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    /// **The defect's own forms, banned by name.** Row 54 was four calls:
    /// two system font sizes and two system ink tiers. A row that wants a
    /// size or an ink takes it from `VoiceTokens`, which is what every
    /// other listing in the app does.
    @Test func theTimelineRowsTakeNoSystemFontOrInkTier() throws {
        let source = Self.timelineSource
        #expect(!source.isEmpty, "the pin found the file it is about")
        for banned in [".font(.caption)", ".font(.caption2)", ".font(.body)",
                       "foregroundStyle(.secondary)", "foregroundStyle(.tertiary)",
                       "foregroundStyle(.primary)"] {
            #expect(!source.contains(banned),
                    "row 54's class: \(banned) in the Timeline is a row that cannot wear the voice")
        }
        // …and it does take the voice's own type and inks.
        for wanted in ["tokens.body", "tokens.small", "tokens.ink", "tokens.muted",
                       "tokens.faint", "tokens.chromeLabel", "tokens.surface"] {
            #expect(source.contains(wanted), "the rows read \(wanted)")
        }
    }

    /// **Which stamp a lens is ABOUT is the Library's one rule.** The
    /// Timeline says which SORT each lens is and asks
    /// `LibrarySortFace.stampSubject` — so a lens cannot word a stamp one
    /// way while the Library words the same stamp another.
    @Test func eachLensAsksTheOneRuleWhichStampItIsShowing() {
        #expect(TimelineViewModel.Lens.entryDate.sort == .entryDate)
        #expect(TimelineViewModel.Lens.lastTouched.sort == .lastTouched)
        #expect(TimelineViewModel.Lens.lastMajorRevision.sort == .lastMajorRevision)
        #expect(TimelineViewModel.Lens.library.sort == .lastTouched,
                "the total surface is ordered by last-touched — its own doc says so")

        #expect(TimelineViewModel.Lens.entryDate.stampSubject == .dated)
        #expect(TimelineViewModel.Lens.lastTouched.stampSubject == .edited)
        #expect(TimelineViewModel.Lens.library.stampSubject == .edited)
        #expect(TimelineViewModel.Lens.lastMajorRevision.stampSubject == .edited,
                "the major-revision stamp is an edit stamp — the Library's own call, not a new one")

        for lens in TimelineViewModel.Lens.allCases {
            #expect(lens.stampSubject == LibrarySortFace.stampSubject(lens.sort),
                    "\(lens): one rule, asked — never a second copy of it")
        }
    }

    /// **The words themselves are `TimeStampFace`'s**, which is what the
    /// rows now print instead of the raw stored column. A row under the
    /// entry-date lens says the day ONCE (R3-2's rule): the trailing stamp
    /// IS the stated day there, so the beside-the-title slot stands down —
    /// pinned as the condition the row's own `if` expresses.
    @Test func aStampIsWordedByTheOneBrainAndADayIsNeverSaidTwice() throws {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        let stored = "2026-06-30T12:00:00.000Z"
        let worded = try #require(TimeStampFace.stamp(.edited, iso: stored, now: now))
        #expect(worded != stored, "the row says words, never the stored column")
        #expect(worded.hasPrefix("edited "))

        let day = try #require(TimeStampFace.stamp(.dated, day: "2026-06-29", now: now))
        #expect(!day.contains("2026-06-29"), "a stated day is worded too")

        // The row's own condition: the second slot draws only when the
        // lens's subject is not already the stated day.
        for lens in TimelineViewModel.Lens.allCases {
            let saysTheDayTwice = lens.stampSubject == .dated
            #expect(saysTheDayTwice == (lens == .entryDate),
                    "\(lens): only the entry-date lens's trailing stamp IS the stated day")
        }
    }
}
