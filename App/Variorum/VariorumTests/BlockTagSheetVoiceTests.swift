//
//  BlockTagSheetVoiceTests.swift
//  VariorumTests
//
//  **13u4 UNIT S3 — `KnownIssuesAndTechDebt` row 45:** *"`BlockTagAssignmentSheet`
//  — the ONE tag sheet three surfaces render (Snippets cards, the scraps
//  panel, canvas cards) — is unvoiced"*: system `.headline`/`List`/`Toggle`,
//  no `VoiceTokens`, so it looked identical in both voices while everything
//  around it changed. The row's second half: *"its title says 'block' on a
//  snippet face"*.
//
//  A typeface is a thing you SEE, so the acceptance evidence is the walk
//  (the unit record's table, both voices and both appearances). What is
//  pinnable, and is pinned here, is what would let it come back silently —
//  UNIT S2's `TimelineVoiceTests` form, one surface over.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The block-tag sheet wears the voice (13u4 UNIT S3 — row 45)")
struct BlockTagSheetVoiceTests {
    private static func source(_ relative: String) -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum/\(relative)")
        return (try? String(contentsOf: url, encoding: .utf8)) ?? ""
    }

    /// **The defect's own forms, banned by name.** Row 45 was a `.headline`
    /// title, a system `List` and system `Toggle`s. Anything in here that
    /// wants a size, an ink or a row wash takes it from `VoiceTokens`.
    @Test func theSheetTakesNoSystemFontInkOrListChrome() {
        let file = Self.source("Features/Pool/BlockTagViews.swift")
        #expect(!file.isEmpty, "the pin found the file it is about")
        for banned in [".font(.headline)", ".font(.caption)", ".font(.body)",
                       "foregroundStyle(.secondary)", "foregroundStyle(.tertiary)",
                       "foregroundStyle(.primary)",
                       // The `List`/`Toggle` pair IS the row's own wording:
                       // a system checkbox is the one control in this sheet
                       // that could never wear the voice.
                       "List(model.allTags", "Toggle("] {
            #expect(!file.contains(banned),
                    "row 45's class: \(banned) is chrome that cannot follow the voice")
        }
        for wanted in ["tokens.heading", "tokens.body", "tokens.small", "tokens.ink",
                       "tokens.muted", "tokens.faint", "tokens.wash", "tokens.room",
                       "CalmButtonStyle"] {
            #expect(file.contains(wanted), "the sheet reads \(wanted)")
        }
    }

    /// The ONE thing about a row that a pin can read without a window: an
    /// applied tag is marked with this app's own ✓ (the take cards' "✓
    /// chosen"), and the row still says on/off to a screen reader — which is
    /// what a checkbox was giving for free.
    @Test func anAppliedRowIsMarkedAndStillSaysOnOrOffOutLoud() {
        let file = Self.source("Features/Pool/BlockTagViews.swift")
        #expect(file.contains("\u{2713}"), "the app's own chosen marker")
        #expect(file.contains("accessibilityValue"), "on/off survives the checkbox")
        #expect(file.contains("accessibilityLabel"))
    }

    /// **The row's second half.** The title is a per-surface noun now, and
    /// the two SNIPPETS renderers pass the snippets word (K5's vocabulary
    /// ruling: the scraps area's UI word is "snippet").
    @Test func theTitleSaysTheSubjectsOwnWord() {
        #expect(BlockTagCopy.title(noun: BlockTagCopy.snippetNoun, preview: "a loose line")
            .contains("snippet"))
        #expect(!BlockTagCopy.title(noun: BlockTagCopy.snippetNoun, preview: "a loose line")
            .contains("block"))
        #expect(BlockTagCopy.title(noun: BlockTagCopy.blockNoun, preview: "a paragraph")
            .contains("block"))
        // The subject itself is quoted, clipped, and honest when empty.
        #expect(BlockTagCopy.title(noun: "block", preview: "a paragraph").contains("a paragraph"))
        #expect(BlockTagCopy.title(noun: "block", preview: "").contains("(empty)"))
        #expect(BlockTagCopy.title(noun: "block", preview: nil).contains("(empty)"))
        let long = String(repeating: "x", count: 200)
        #expect(BlockTagCopy.title(noun: "block", preview: long).count < 100,
                "a long first line is clipped, never the whole paragraph in a title")
    }

    /// Declared ⇔ rendered, at the two surfaces that own the word: the
    /// snippets renderers ASK for the snippets noun rather than repeating a
    /// literal, and the canvas keeps the default with its reason at the line
    /// (it is opened on a note OR on the scraps area).
    @Test func theSnippetsSurfacesPassTheSnippetsNoun() {
        for surface in ["Features/Pool/ScrapsPanel.swift", "Features/Pool/BlocksAreaView.swift"] {
            let file = Self.source(surface)
            #expect(!file.isEmpty, "the pin found \(surface)")
            #expect(file.contains("noun: BlockTagCopy.snippetNoun"),
                    "\(surface) speaks snippets (K5)")
        }
        let canvas = Self.source("Features/Canvas/CanvasView.swift")
        #expect(!canvas.contains("noun: BlockTagCopy"),
                "the canvas keeps the default — PROVISIONAL, QUESTIONS #133")
    }
}
