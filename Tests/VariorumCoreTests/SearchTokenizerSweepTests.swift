//
//  SearchTokenizerSweepTests.swift
//  VariorumCoreTests
//
//  VX-955 (the VX-980 run, batch 1; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — THE SWEEP. A typed word is asked of the search index exactly when the
//  INDEX would find a token in it, so the composer's word rule
//  (`SearchComposer.hasTokenCharacter`) must say what the index's own
//  tokenizer says, scalar for scalar.
//
//  The oracle is the tokenizer itself, as LINKED into the app (SQLCipher's
//  prebuilt FTS5), built from the options the LIVE index's DDL carries — read
//  out of a freshly migrated store's `sqlite_master`, never restated here — so
//  a SQLCipher bump that moves SQLite's category table, or a migration that
//  changes the tokenizer's options, turns this suite red instead of silently
//  emptying answers. SQLite's table is NOT the OS's Unicode (measured: 😀
//  U+1F600 is a separator and 🙂 U+1F642 a token; combining marks separate;
//  `½` and `²` are tokens; every scalar its table does not know is a token),
//  so the rule must follow the index, never Unicode's general categories.
//
//  RED on the pre-fix tree (the rule counted every symbol and mark as a token
//  character), GREEN once the rule follows the tokenizer.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// The live index's tokenizer options, read from the DDL a migrated store
/// carries (`tokenize = '…'` inside `CREATE VIRTUAL TABLE search_fts`).
private func liveTokenizerOptions(_ db: Database) throws -> [String] {
    let ddl = try #require(try String.fetchOne(
        db, sql: "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'search_fts'"))
    let key = try #require(ddl.range(of: "tokenize"), "the index's DDL names its tokenizer:\n\(ddl)")
    let afterKey = ddl[key.upperBound...]
    let open = try #require(afterKey.firstIndex(of: "'"))
    let rest = afterKey[afterKey.index(after: open)...]
    let close = try #require(rest.firstIndex(of: "'"))
    return rest[..<close].split(whereSeparator: \.isWhitespace).map(String.init)
}

/// Does the linked tokenizer find at least one token in `word`, as a MATCH
/// string's phrase would be tokenized (`FTS5_TOKENIZE_QUERY`)?
private func indexFindsAToken(_ tokenizer: any FTS5Tokenizer, _ word: String) throws -> Bool {
    !(try tokenizer.tokenize(query: word)).isEmpty
}

private func scalarName(_ value: UInt32) -> String { String(format: "U+%04X", value) }

@Suite("VX-955 — the words search asks the index about follow the index's own tokenizer")
struct SearchTokenizerSweepTests {
    /// The table names the options it was measured under, and they are the
    /// live index's — a migration that changes them must re-measure (the
    /// sweep below then says what moved).
    @Test func theTableWasMeasuredUnderTheLiveIndexsTokenizer() throws {
        let db = try AppDatabase.inMemory()
        let live = try db.read { db in try liveTokenizerOptions(db) }
        #expect(live.joined(separator: " ") == SearchTokenCharacters.tokenizerOptions)
        #expect(SearchTokenCharacters.transitions == SearchTokenCharacters.transitions.sorted()
                && Set(SearchTokenCharacters.transitions).count == SearchTokenCharacters.transitions.count,
                "the transition points ascend strictly")
    }

    /// EVERY Unicode scalar (U+0000…U+10FFFF, the surrogates being no
    /// scalars): a one-scalar word is asked of the index exactly when the
    /// linked tokenizer finds a token in it. On a disagreement the message
    /// carries the MEASURED table (the transition points: from the first
    /// listed scalar a run of tokens begins, from the next a run of
    /// separators, alternating), so a moved link is re-measured mechanically.
    @Test func everyScalarIsAskedExactlyWhenTheLinkedTokenizerFindsAToken() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let options = try liveTokenizerOptions(db)
            let tokenizer = try db.makeTokenizer(FTS5TokenizerDescriptor(components: options))
            var checked = 0
            var tokenScalars = 0
            var measured: [UInt32] = []
            var inTokenRun = false
            var disagreements = 0
            var samples: [String] = []
            for value in UInt32(0)...0x10FFFF {
                guard let scalar = Unicode.Scalar(value) else { continue }
                let word = String(Character(scalar))
                let indexed = try indexFindsAToken(tokenizer, word)
                checked += 1
                if indexed { tokenScalars += 1 }
                if indexed != inTokenRun {
                    measured.append(value)
                    inTokenRun = indexed
                }
                if SearchComposer.hasTokenCharacter(word) != indexed {
                    disagreements += 1
                    if samples.count < 40 {
                        samples.append("\(scalarName(value)) (\(scalar.properties.generalCategory)): "
                                       + "the index \(indexed ? "finds a token" : "finds none")")
                    }
                }
            }
            #expect(checked == 1_112_064, "every scalar is swept")
            #expect(
                disagreements == 0,
                """
                \(disagreements) of \(checked) scalars are asked of the index differently from how the \
                linked tokenizer (\(options.joined(separator: " "))) reads them — first: \
                \(samples.joined(separator: "; ")). The MEASURED table (\(measured.count) transition \
                points, \(tokenScalars) token scalars): \
                \(measured.map { String(format: "0x%X", $0) }.joined(separator: ", "))
                """)
        }
    }

    /// Words of SEVERAL scalars — combining sequences in both orders, emoji
    /// sequences (ZWJ, a flag, a variation selector), symbols inside and
    /// beside letters and digits, private use — each asked exactly when the
    /// linked tokenizer finds a token in the whole word (`unicode61` begins a
    /// token at the first token character; a combining mark only continues
    /// one, never begins it).
    @Test(arguments: [
        "e\u{301}", "\u{301}e", "\u{301}", "\u{301}\u{308}", "😀", "🙂", "👩\u{200D}💻", "🇫🇷",
        "❤\u{FE0F}", "\u{FE0F}", "\u{200D}", "+", "$", "©", "$5", "C++", "a+b", "1+1", "½", "x²",
        "—…!?", "#", "_", "'", "\u{E000}", "\u{F0000}", "日本", "٣", "ﷺ", "℃", "№", "™", "∞",
    ])
    func aWordIsAskedExactlyWhenTheLinkedTokenizerFindsATokenInIt(_ word: String) throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let tokenizer = try db.makeTokenizer(FTS5TokenizerDescriptor(components: try liveTokenizerOptions(db)))
            let indexed = try indexFindsAToken(tokenizer, word)
            #expect(
                SearchComposer.hasTokenCharacter(word) == indexed,
                "\(word.unicodeScalars.map { scalarName($0.value) }): the index \(indexed ? "finds a token" : "finds none")")
        }
    }
}
