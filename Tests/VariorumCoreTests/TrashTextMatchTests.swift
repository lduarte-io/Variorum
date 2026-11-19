//
//  TrashTextMatchTests.swift
//  VariorumCoreTests
//
//  VX-93 (the vx-980 run, batch 3; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — THE TRASH'S OWN MATCH, pure. Her rulings: R-980-10 (every typed word,
//  case and accents ignored, partial words match, no grammar) and R-980-11
//  (one passage line — the words around the first match, only on a row
//  matched by text it does not already show).
//
//  A feature batch: these pins state the NEW contract (no red-on-old leg is
//  owed). Each can fail — the sameness pins are measured against the linked
//  index's own tokenizer, scalar by scalar, so a fold that kept apart what the
//  finder equates turns them red; every other expectation is an exact value.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-93 — the Trash's own match: every word, folded, a contained run")
struct TrashTextMatchTests {
    // MARK: - The words (whitespace separates; nothing else is grammar)

    @Test func whitespaceSeparatesAndEveryOtherCharacterBelongsToAWord() {
        #expect(TrashTextMatch.words("rhubarb") == ["rhubarb"])
        #expect(TrashTextMatch.words("  rhubarb   crumble ") == ["rhubarb", "crumble"])
        #expect(TrashTextMatch.words("a\tb\nc\r\nd") == ["a", "b", "c", "d"], "tabs and newlines separate too")
        #expect(TrashTextMatch.words("#garden -weeds \"east bed\" 1+1") == ["#garden", "-weeds", "\"east", "bed\"", "1+1"],
                "no grammar: a #, a dash, quotes and + are characters of their words")
        #expect(TrashTextMatch.words("red Red red") == ["red", "Red"], "an exact duplicate collapses, first spelling kept")
        #expect(TrashTextMatch.words("") == [])
        #expect(TrashTextMatch.words(" \t\n ") == [], "only whitespace asks nothing")
    }

    // MARK: - Holds (a contained run, case and accents folded)

    @Test func aWordIsAContainedRunWithCaseAndAccentsFolded() {
        // Case.
        #expect(TrashTextMatch.holds("Rhubarb crumble", "rhubarb"))
        #expect(TrashTextMatch.holds("rhubarb crumble", "RHUBARB"))
        // Accents, both ways, composed and decomposed.
        #expect(TrashTextMatch.holds("Café crème", "cafe"))
        #expect(TrashTextMatch.holds("cafe creme", "CAFÉ"))
        #expect(TrashTextMatch.holds("e\u{301}cole", "école"))
        #expect(TrashTextMatch.holds("école", "e\u{301}cole"))
        #expect(TrashTextMatch.holds("Ångström and naïve", "angstrom"))
        #expect(TrashTextMatch.holds("İstanbul", "istanbul"))
        // Partial words.
        #expect(TrashTextMatch.holds("the garden plans", "gard"))
        #expect(TrashTextMatch.holds("the garden plans", "rden pl"), "a run may cross a space inside one text")
        #expect(TrashTextMatch.holds("rhubarb", "bar"))
        // Punctuation and symbols are the characters they are.
        #expect(TrashTextMatch.holds("1 + 1 = 2", "+"))
        #expect(TrashTextMatch.holds("learning c++ today", "c++"))
        #expect(TrashTextMatch.holds("tagged #garden here", "#garden"))
        #expect(TrashTextMatch.holds("😀 hello", "😀"))
        #expect(!TrashTextMatch.holds("don’t", "don't"), "a straight apostrophe is not a curly one — no grammar, no smart quotes")
        #expect(!TrashTextMatch.holds("1+1", "1 + 1"), "spacing is characters too")
        // Absent, and the empty edges.
        #expect(!TrashTextMatch.holds("rhubarb", "pear"))
        #expect(!TrashTextMatch.holds("", "pear"))
        #expect(!TrashTextMatch.holds("pear", ""))
    }

    @Test func everyWordMustBeFoundEachInOneOfTheRowsTexts() {
        let texts = ["garden plans", "moved the rhubarb to the east bed", "a second take"]
        #expect(TrashTextMatch.matchesEvery(["rhubarb"], in: texts))
        #expect(TrashTextMatch.matchesEvery(["garden", "rhubarb"], in: texts), "words may sit in different texts")
        #expect(TrashTextMatch.matchesEvery(["GARD", "Rhub", "secon"], in: texts))
        #expect(!TrashTextMatch.matchesEvery(["rhubarb", "pear"], in: texts), "every word, or the row does not match")
        #expect(!TrashTextMatch.matchesEvery(["bedasecond"], in: ["the east bed", "a second take"]),
                "a word never spans two texts")
        #expect(!TrashTextMatch.matchesEvery([], in: texts), "no words is no search — nothing matches it")
        #expect(!TrashTextMatch.matchesEvery(["rhubarb"], in: []))
    }

    // MARK: - The passage (R-980-11)

    @Test func aRowThatShowsEveryWordCarriesNoPassage() {
        #expect(TrashTextMatch.passage(
            words: ["garden"], shown: "Garden plans", texts: ["the garden is full"]) == nil)
        #expect(TrashTextMatch.passage(
            words: ["garden", "plan"], shown: "garden plans", texts: ["a garden plan"]) == nil)
    }

    @Test func thePassageIsCutAroundTheFirstWordTheRowDoesNotShow() {
        // The preview she picked: "…moved the rhubarb to the east bed…".
        let body = "We spent the whole of Saturday morning outside, and in the end we moved the rhubarb "
            + "to the east bed where it gets the afternoon sun and the frost lifts first. Next spring "
            + "we will see whether it forgives us for the disturbance."
        let line = TrashTextMatch.passage(
            words: ["rhubarb"], shown: "garden plans", texts: [body], lead: 10, tail: 20)
        #expect(line == "\u{2026}moved the rhubarb to the east bed\u{2026}",
                "cut at word edges (the tail's cut fell inside where and stepped back), an ellipsis each side: \(line ?? "nil")")
        // The shipped measures keep a few words before and more after.
        let shipped = TrashTextMatch.passage(
            words: ["rhubarb"], shown: "garden plans", texts: [body])
        #expect(shipped?.hasPrefix("\u{2026}") == true && shipped?.contains("moved the rhubarb to the east bed") == true,
                "\(shipped ?? "nil")")

        // A word the name already shows does not choose the passage: the
        // first word it does NOT show does.
        let both = TrashTextMatch.passage(
            words: ["garden", "east"], shown: "garden plans",
            texts: ["the garden first", "then the east bed"], lead: 40, tail: 40)
        #expect(both == "then the east bed", "the second text holds the unexplained word; the whole text fits")

        // Earliest text first, earliest place within it.
        let order = TrashTextMatch.passage(
            words: ["pear", "apple"], shown: "", texts: ["no fruit here", "an apple then a pear", "pear"],
            lead: 40, tail: 40)
        #expect(order == "an apple then a pear")
    }

    @Test func thePassageNeverCutsTheMatchAndSaysWhereItWasCut() {
        // At the text's start: no leading ellipsis.
        #expect(TrashTextMatch.excerpt(
            "rhubarb crumble with custard and cream", around: range("rhubarb", in: "rhubarb crumble with custard and cream"),
            lead: 10, tail: 8) == "rhubarb crumble\u{2026}")
        // At the text's end: no trailing ellipsis.
        let tail = "two cups of rhubarb"
        #expect(TrashTextMatch.excerpt(tail, around: range("rhubarb", in: tail), lead: 7, tail: 10)
                == "\u{2026}of rhubarb")
        // Whitespace runs collapse — a newline becomes one space; the passage is one line.
        let lines = "first line\n\n  rhubarb   here\nlast"
        #expect(TrashTextMatch.excerpt(lines, around: range("rhubarb", in: lines), lead: 40, tail: 40)
                == "first line rhubarb here last")
        // A match inside one long word is kept whole even when the measures are small.
        let long = "xx supercalifragilisticrhubarbexpialidocious yy"
        let line = TrashTextMatch.excerpt(long, around: range("rhubarb", in: long), lead: 3, tail: 3)
        #expect(line.contains("rhubarb"), "the match itself is never cut: \(line)")
        #expect(line.hasPrefix("\u{2026}") && line.hasSuffix("\u{2026}"))
    }

    // MARK: - The sameness (the finder's third rule — R-13o-11)

    /// The fold is the tag offer's — the app's own Swift statement of the
    /// index's sameness — and the match's search agrees with it.
    @Test func theSamenessIsTheTagOffersAndTheSearchAgreesWithTheFold() {
        let pairs: [(String, String)] = [
            ("Café crème", "cafe"), ("CAFÉ", "café"), ("naïve", "NAIVE"), ("e\u{301}cole", "école"),
            ("Ångström", "angstrom"), ("İstanbul", "istanbul"), ("rhubarb", "RHUB"), ("1 + 1", "+"),
            ("don’t", "don't"), ("한국어", "국"), ("😀 hi", "😀"), ("garden", "gard"), ("ø", "o"), ("ł", "l"),
        ]
        for (text, word) in pairs {
            #expect(TrashTextMatch.fold(text) == SearchTagOffer.fold(text), "one fold: \(text)")
            #expect(TrashTextMatch.holds(text, word)
                    == TrashTextMatch.fold(text).contains(TrashTextMatch.fold(word)),
                    "the search and the fold agree: \(text) ~ \(word)")
        }
    }

    /// **The Trash never keeps apart what the finder equates** — swept over
    /// every Unicode scalar against the LINKED index's tokenizer, built from
    /// the live DDL's options: wherever the index folds a scalar to a token,
    /// the Trash's fold reduces the scalar and that token to the same text.
    /// So a word the Library's search would find by its folding, the Trash's
    /// search finds too. (The other way is the recorded residual below: the
    /// Trash folds a little MORE.)
    @Test func theTrashNeverKeepsApartWhatTheIndexFoldsTogether() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let ddl = try #require(try String.fetchOne(
                db, sql: "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'search_fts'"))
            #expect(ddl.contains(SearchTokenCharacters.tokenizerOptions),
                    "the options swept are the live index's:\n\(ddl)")
            let tokenizer = try db.makeTokenizer(FTS5TokenizerDescriptor(
                components: SearchTokenCharacters.tokenizerOptions.split(separator: " ").map(String.init)))
            var folded = 0
            var disagreements: [String] = []
            for value in UInt32(0)...0x10FFFF {
                guard let scalar = Unicode.Scalar(value) else { continue }
                let character = String(Character(scalar))
                let tokens = try tokenizer.tokenize(query: character).map(\.token)
                guard tokens.count == 1, let token = tokens.first, token != character else { continue }
                folded += 1
                if TrashTextMatch.fold(character) != TrashTextMatch.fold(token),
                   disagreements.count < 40
                {
                    disagreements.append(String(format: "U+%04X", value) + " \(character) → index \(token)")
                }
            }
            #expect(folded > 1_000, "premise: the index folds case and accents (\(folded) scalars)")
            #expect(disagreements.isEmpty,
                    "the Trash keeps apart what the index folds together:\n\(disagreements.joined(separator: "\n"))")
        }
    }

    /// **The recorded residual: the Trash folds a little MORE than the index.**
    /// Foundation's case folding expands ß and the ligatures and its accent
    /// folding reaches Greek polytonic and some Cyrillic marks that SQLite's
    /// table leaves alone (measured: 475 such groups and 17 expansions). So a
    /// few words find more in the Trash than the Library would. Pinned so a
    /// change to the fold is deliberate (PROVISIONAL P-980-B3-2 in the record).
    @Test func theTrashFoldsALittleMoreThanTheIndexAndSaysWhere() {
        #expect(TrashTextMatch.holds("Straße", "strasse"), "ß folds to ss (the index keeps them apart)")
        #expect(TrashTextMatch.holds("ﬁne", "fine"), "a ligature unfolds (the index keeps ﬁ)")
        #expect(TrashTextMatch.holds("ά", "α"), "Greek accents fold (the index keeps ά)")
        #expect(!TrashTextMatch.holds("ø", "o"), "a letter with no decomposition stays itself, as in the index")
    }

    private func range(_ word: String, in text: String) -> Range<String.Index> {
        text.range(of: word)!
    }
}
