//
//  EditorChurnCostTests.swift
//  VariorumTests
//
//  **Phase 13u1, UNIT 1 — the churn pair (the 2026-08-30 sweep's P24 + P25,
//  one mechanism found independently by two lenses).**
//
//  `container.last_major_revision_at` exists so that **fixing one typo never
//  reshuffles the library** — CoreDescription pillar 7, verbatim, and the
//  math AppSpec §10 defines. The Mac's Write editor computed its churn cost
//  from the RAW `NSTextStorage` edited-range report:
//
//      charDelta = (editedRange.length − delta) + editedRange.length
//
//  and macOS 26's attribute fixing WIDENS that report to the whole paragraph
//  including its terminator — measured and pinned in this very repo
//  (`IdentityProjectionAuditTests.appKitWidensAnInsertionsReportedRangeToTheParagraph`:
//  one character typed at offset 2 of "Alpha" reports `{2, 5}`), and recorded
//  in `notes/TEXTKIT2_NOTES.md` §3 as the macOS finding that FALSIFIED the
//  earlier "AppKit does not widen" belief. So a one-character insertion
//  recorded **nine**, and in general ≈ 2 × (the characters from the caret to
//  the paragraph's end).
//
//  13l applied that section's own rule — *clamp to the VERDICT's range, never
//  the report's* — to the attribute stamp two lines above, and not to the
//  arithmetic. The corrected value was already hoisted for both platforms
//  (`ArmedEdit.exactCost` = `range.length + replacementLength`, known at the
//  gate and immune to widening) and only the phone ever read it.
//
//  **P25's own words about what was missing: "No test in VariorumTests
//  asserts a charDelta recorded from the real typed path."** That is exactly
//  what these two pins are — one on the number, one on the consequence.
//

import AppKit
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("Churn is the edit's cost, not the report's (13u1 UNIT 1)")
struct EditorChurnCostTests {
    private static func container(_ db: AppDatabase, _ id: String) throws -> Container {
        try db.read { db in try Container.fetchOne(db, key: id)! }
    }

    /// **THE NUMBER.** One character typed mid-paragraph, through the REAL
    /// AppKit input path, into a block that is followed by another (which is
    /// what makes the report widen past the terminator). The cost recorded
    /// against the post must be the edit's — 0 deleted + 1 inserted — and
    /// not the report's.
    ///
    /// RED ON OLD: nine. `{2, 5}` widened, `delta` 1 ⇒ `(5 − 1) + 5`.
    @Test func aTypedCharacterRecordsItsExactCostNotTheWidenedReport() async throws {
        try await withEditor(seedBlocks: ["Alpha", String(repeating: "x", count: 100)]) { h in
            let before = try Self.container(h.database, h.postID)
            let stampBefore = before.lastMajorRevisionAt

            h.type("X", at: 2)
            await h.flush()

            let after = try Self.container(h.database, h.postID)
            #expect(h.textView.string.hasPrefix("AlXpha"), "the real typed path ran")
            #expect(after.churnAccumulator - before.churnAccumulator == 1,
                    "one character inserted costs one — the report said five")
            #expect(after.lastMajorRevisionAt == stampBefore,
                    "and one character is not a major revision")
        }
    }

    /// The same at a DELETION and at a REPLACEMENT, so the fix is the gate's
    /// arithmetic and not a special case for insertions.
    ///
    /// MEASURED, both halves, on the pre-fix tree: the deletion recorded its
    /// exact 5 (AppKit's deletion report is exact — the round-2 crash trace's
    /// own measurement, re-confirmed here), and the REPLACEMENT recorded
    /// **8 for a true cost of 6** — so the widening reaches replacements too,
    /// which neither P24 nor P25 had measured.
    @Test func aDeletionAndAReplacementRecordTheirExactCosts() async throws {
        try await withEditor(seedBlocks: ["Alpha beta", String(repeating: "x", count: 100)]) { h in
            let before = try Self.container(h.database, h.postID)
            h.replace(NSRange(location: 0, length: 5), with: "")   // 5 out, 0 in
            await h.flush()
            let afterDelete = try Self.container(h.database, h.postID)
            #expect(afterDelete.churnAccumulator - before.churnAccumulator == 5)

            h.replace(NSRange(location: 1, length: 4), with: "ZZ") // 4 out, 2 in
            await h.flush()
            let afterReplace = try Self.container(h.database, h.postID)
            #expect(afterReplace.churnAccumulator - afterDelete.churnAccumulator == 6)
        }
    }

    /// **THE CONSEQUENCE — P24's own worked example, driven for real.**
    /// A five-block note of 400-character paragraphs (baseline 1,600,
    /// accumulator 400 after the mints — the arithmetic is asserted below, so
    /// nothing here rests on a lucky seed). Three keystrokes fixing a typo
    /// near the START of the first paragraph is a true cost of 3.
    ///
    /// RED ON OLD: each of those three reported ≈ `{10, 391}` ⇒ ≈ 781 each,
    /// ≈ 2,343 for the burst — over the threshold, so the note stamped
    /// `last_major_revision_at` and REBASELINED. That is the library
    /// reshuffling on a typo fix: exactly what the stamp exists to prevent,
    /// and a value `reading.sort_field = 'last_major_revision'`, the Library
    /// sort and the Timeline all read.
    @Test func threeTypoKeystrokesInALongParagraphDoNotStampAMajorRevision() async throws {
        let paragraph = String(repeating: "word ", count: 80)  // 400 characters
        try await withEditor(seedBlocks: Array(repeating: paragraph, count: 5)) { h in
            let before = try Self.container(h.database, h.postID)
            // The fixture's arithmetic, stated so the pin is about the cost
            // and not about a lucky seed: the five mints leave baseline
            // 1,600 and accumulator 400, so the 0.8 threshold sits at 1,280
            // with 880 of headroom — room for three real keystrokes many
            // times over, and none at all for the widened burst.
            let threshold = 0.8 * Double(before.baselineLength)
            #expect(before.churnAccumulator + 3 < threshold,
                    "three characters of true cost fit under the threshold")
            #expect(before.churnAccumulator + 2_000 > threshold,
                    "…and the widened burst (~2,343) does not")
            let stampBefore = try #require(before.lastMajorRevisionAt)

            h.type("a", at: 10)
            h.type("b", at: 11)
            h.type("c", at: 12)
            await h.flush()

            let after = try Self.container(h.database, h.postID)
            #expect(after.churnAccumulator - before.churnAccumulator == 3,
                    "three characters typed cost three")
            #expect(after.lastMajorRevisionAt == stampBefore,
                    "fixing a typo must never reshuffle the library")
            #expect(after.baselineLength == before.baselineLength,
                    "…and must never rebaseline the note")
            #expect(after.lastTouchedAt != before.lastTouchedAt,
                    "it IS a touch, though — the noisy stamp still moves")
        }
    }
}
