//
//  SearchFoldsToNothingTests.swift
//  VariorumCoreTests
//
//  VX-1069 (the VX-1082 run, batch S; `notes/plans/fixes/vx-1082-nov-24-fixes.md`)
//  — her ruling of P-980-B1-1, option (b): beside a tag, the words that fold
//  to nothing drop out of the band's QUOTE. The quote lives app-side
//  (`SearchFieldWords`); the decision is core's ONE table, made public here as
//  `SearchComposer.foldsToNothing` — the same measured token set the question's
//  own reading uses (`textHalf`), so the quote and the answer can never
//  disagree about which words ask the index nothing. A pure contract pin for
//  the new door (a build pin, not a bug row: the quote's red-on-old is the
//  app's `SearchBandQuoteBesideATagTests`).
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-1069 — a typed word that folds to nothing, as the index reads it")
struct SearchFoldsToNothingTests {
    @Test func theWordsThatFoldAreTheIndexsOwn() {
        for word in ["—", "-", "+", "#", "…", "$", "©", "\"—\"", "\u{201C}\u{2014}\u{201D}"] {
            #expect(SearchComposer.foldsToNothing(word), "\(word) holds no token the index keeps")
        }
        for word in ["red", "9", "½", "V01\u{2013}V49", "\"a + b\"", "o'clock", "#flora"] {
            #expect(!SearchComposer.foldsToNothing(word), "\(word) holds a token")
        }
    }

    /// The door reads the ONE table the question's own reading reads: a lone
    /// word folds exactly when the question made of it folds to nothing.
    @Test func itAgreesWithTheQuestionsOwnReading() {
        for word in ["—", "+", "…", "$", "red", "9", "½", "a+b", "©", "™"] {
            let folded = SearchComposer.textHalf(SearchQuery(text: .word(word))) == .foldsToNothing
            #expect(SearchComposer.foldsToNothing(word) == folded, "\(word)")
        }
    }
}
