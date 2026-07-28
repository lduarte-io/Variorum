//
//  EditorBehaviorSettings.swift
//  Variorum
//
//  13d batch 4 — the two THIS-MAC editor-behaviour settings her intake
//  asked for: A23 (a paragraph-tall gap between paragraphs) and A24
//  (levels of spellchecking). Both follow the precedent set by the hover
//  handles (13b 4D / S4-19) and the phantom kill switch (13c 1E): app-local
//  `UserDefaults`, stored NOWHERE in the schema, so `renderedText`, export,
//  and the Fragments bridge are byte-untouched by either.
//
//  Why local and not the synced `setting` table: both describe how ONE
//  Mac's text surfaces behave — not what a document MEANS. (A16, in the
//  same batch, is the opposite case and is synced for exactly that reason:
//  segmentation changes what entry DOES to the store.)
//

import AppKit
import SwiftUI

// MARK: - A23: the paragraph gap

/// How much air sits after every paragraph. The 2026-07-12 ruling's
/// presentation half made the gap UNIFORM and per-PARAGRAPH — never
/// per-block-seam, because AppSpec §12 keeps block boundaries invisible at
/// rest and a seam-only gap would make every boundary inferable. This
/// setting scales that one uniform gap; it does not introduce a second,
/// seam-shaped one, and it changes no stored byte.
nonisolated enum ParagraphGap: String, CaseIterable, Sendable {
    /// What has shipped since Phase 13 C1: half the prose font's point size
    /// (plus the inline-comment room when that is on).
    case standard
    /// Her A23: *"Setting: paragraph-tall gap between blocks"* — a whole
    /// line of the prose font ON TOP of the standard gap, so the air
    /// between paragraphs reads as a blank line.
    ///
    /// ADDITIVE rather than absolute, deliberately: with inline comments on
    /// the standard gap is already taller than a line, so an absolute
    /// "one line" would silently do nothing there. Additive always shows,
    /// and composes with the comment room instead of fighting it.
    case paragraphTall

    static let settingKey = "editorParagraphGap"

    /// This Mac's current choice. Read at style-construction time (not
    /// cached in `EditorTypography.current`) so every surface that rebuilds
    /// `EditorDocument.baseParagraphStyle` picks up a change with no global
    /// to keep in sync — the ordering hazard a cached copy would create.
    static var current: ParagraphGap {
        UserDefaults.standard.string(forKey: settingKey)
            .flatMap(ParagraphGap.init(rawValue:)) ?? .standard
    }

    /// Extra points after each paragraph, on top of the resolved typography.
    func extraSpacing(for font: NSFont) -> CGFloat {
        switch self {
        case .standard: 0
        case .paragraphTall: Self.lineHeight(of: font)
        }
    }

    /// One line of this font, the standard typographic way (no layout
    /// manager — TEXTKIT2 §4.2 forbids reaching for TK1 APIs, and a font
    /// metric needs neither).
    static func lineHeight(of font: NSFont) -> CGFloat {
        (font.ascender - font.descender + font.leading).rounded()
    }
}

// MARK: - A24: spellcheck levels

/// Her A24: *"different levels of spellchecking"* — kept deliberately
/// COARSE (three levels, no finer) because TEXTKIT2 §3 records that
/// continuous spell checking together with the word-completion popover has
/// crashed NSTextView. The levels are the three the text system actually
/// distinguishes, and the level actively turns automatic *completion* OFF
/// whenever it turns checking on — AppKit hands every surface completion
/// ON by default, so that pairing was one setting away.
nonisolated enum SpellcheckLevel: String, CaseIterable, Sendable {
    /// Today's shipped behaviour, and the default: neither flag set on any
    /// surface. Spelling stays reachable through Edit ▸ Spelling and
    /// Grammar, exactly as it always has.
    case off
    /// Red underlines as you type — `isContinuousSpellCheckingEnabled`.
    case checkWhileTyping
    /// …plus macOS's automatic correction of what it is confident about.
    case checkAndCorrect

    static let settingKey = "editorSpellcheckLevel"

    static var current: SpellcheckLevel {
        UserDefaults.standard.string(forKey: settingKey)
            .flatMap(SpellcheckLevel.init(rawValue:)) ?? .off
    }

    var continuousChecking: Bool { self != .off }
    var automaticCorrection: Bool { self == .checkAndCorrect }

    /// Applies the level to a TK2 surface, WRITE-GATED. The gate is the
    /// 13c A47c lesson applied on day one: an unguarded property write on a
    /// live text view is never free (that trace found a full-range
    /// attribute write destroying rendering surfaces), so a no-op level
    /// application must be a genuine no-op — nothing is written when
    /// nothing changed.
    @MainActor
    func apply(to view: NSTextView) {
        if view.isContinuousSpellCheckingEnabled != continuousChecking {
            view.isContinuousSpellCheckingEnabled = continuousChecking
        }
        if view.isAutomaticSpellingCorrectionEnabled != automaticCorrection {
            view.isAutomaticSpellingCorrectionEnabled = automaticCorrection
        }
        // Grammar checking rides the "check while typing" level: it is the
        // same underline vocabulary, and a fourth level for it would be the
        // fineness the §3 warning tells us not to add.
        if view.isGrammarCheckingEnabled != continuousChecking {
            view.isGrammarCheckingEnabled = continuousChecking
        }
        // THE §3 CRASH PAIRING, closed here — and this was a FINDING, not a
        // precaution: `isAutomaticTextCompletionEnabled` is TRUE by default
        // on every NSTextView in this app (measured by the pin that first
        // failed), so simply turning continuous checking on would have put
        // every surface into exactly the pairing TEXTKIT2 §3 records as
        // crashing NSTextView — "continuous spell checking + the
        // word-completion popover". Completion is therefore OFF whenever
        // checking is ON, and restored to AppKit's default at `.off`, so a
        // round trip through the setting leaves the surface where it began.
        let completion = !continuousChecking
        if view.isAutomaticTextCompletionEnabled != completion {
            view.isAutomaticTextCompletionEnabled = completion
        }
    }
}
