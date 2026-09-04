//
//  MobilePerfFixtureSeeder.swift
//  VariorumMobile
//
//  Parity round Stage B, batch B2 — THE PERFORMANCE FIXTURE (the soul
//  document's bar made executable: "I do not want the mobile app to
//  choke even on 100k words"; MEMORY is a first-class metric — iOS
//  jetsam). Seeds THE PROVING GROUND: a ~100k-word post shaped like
//  real writing — crystallization-scale blocks, a deterministic
//  realistic paragraph distribution, SOME fanned/commented/callout
//  blocks so the chrome layer participates in every measurement — plus
//  a LARGE CORPUS around it (hundreds of notes across six books, the
//  scale that proves corpus-flatness) and a small CONTROL post of the
//  same prose shape (the flatness pins' small-fixture control;
//  byte-identical in every world because its generator is seeded
//  independently of everything else).
//
//  THE B1 DOOR FAMILY: the seeding DOOR is DEBUG-only (Settings,
//  beside the pocket guide's) and Debug builds resolve the DEV store
//  by construction (the A4 fence) — the fixture never reaches her real
//  corpus from this batch. The seeder type compiles unconditionally so
//  the measurement suites (Debug) drive it headlessly.
//
//  DETERMINISM: all prose comes from `PerfProse`, a SplitMix64-seeded
//  generator — no Date.now randomness anywhere in the content, so runs
//  compare (the B2 brief's letter). Every write goes through Operations
//  (never ad-hoc rows — the CorpusFactory/B1 discipline: a seed is a
//  scale smoke test of the operations layer too), on the QUIET facade
//  (undoStack: nil — a seed is not HER act). All content is NON-JOURNAL
//  (`.generic`, no entry dates — the R57 discipline mirrored from B1;
//  the dev store never syncs, but no fixture row may ever be shaped
//  like a daily Journal entry).
//

import Foundation
import GRDB
import VariorumCore

// MARK: - The deterministic prose generator

/// SplitMix64-seeded prose: sentences of 8–18 bank words (occasional
/// comma), paragraphs of 3–6 sentences — realistic paragraph
/// distribution at crystallization scale (~40–110 words a paragraph).
/// Pure and deterministic: the same seed always yields the same bytes.
nonisolated struct PerfProse {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    private mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    private mutating func int(_ range: ClosedRange<Int>) -> Int {
        range.lowerBound + Int(next() % UInt64(range.count))
    }

    /// A bounded deterministic draw for the seeder's structural choices
    /// (block counts per corpus note) — the same SplitMix64 stream.
    mutating func probe(_ bound: UInt64) -> UInt64 {
        next() % max(1, bound)
    }

    /// A small bank of ordinary words, varied lengths — prose-shaped,
    /// ASCII, no markdown accidents.
    private static let bank: [String] = [
        "the", "a", "morning", "light", "harbor", "letter", "stone", "window",
        "garden", "river", "quiet", "slow", "warm", "gray", "paper", "coffee",
        "road", "field", "winter", "summer", "voice", "thought", "door", "shelf",
        "book", "page", "margin", "pencil", "rain", "cloud", "long", "small",
        "early", "late", "open", "closed", "bright", "heavy", "thin", "near",
        "walked", "wrote", "waited", "watched", "turned", "carried", "held",
        "found", "left", "kept", "toward", "across", "between", "under",
        "beside", "without", "through", "again", "almost", "together", "still",
    ]

    /// One sentence: 8–18 words, first capitalized, ~25% carry a comma.
    mutating func sentence() -> (text: String, words: Int) {
        let count = int(8...18)
        var words: [String] = []
        words.reserveCapacity(count)
        for _ in 0..<count {
            words.append(Self.bank[int(0...(Self.bank.count - 1))])
        }
        words[0] = words[0].prefix(1).uppercased() + words[0].dropFirst()
        if count >= 10, int(0...3) == 0 {
            let at = count / 2
            words[at - 1] += ","
        }
        return (words.joined(separator: " ") + ".", count)
    }

    /// One paragraph: 3–6 sentences.
    mutating func paragraph() -> (text: String, words: Int) {
        let count = int(3...6)
        var sentences: [String] = []
        var words = 0
        for _ in 0..<count {
            let s = sentence()
            sentences.append(s.text)
            words += s.words
        }
        return (sentences.joined(separator: " "), words)
    }

    /// One block of `paragraphs` paragraphs joined by internal newlines
    /// (I4: newlines are content — multi-paragraph blocks are part of
    /// the real shape).
    mutating func block(paragraphs: Int) -> (text: String, words: Int) {
        var parts: [String] = []
        var words = 0
        for _ in 0..<max(1, paragraphs) {
            let p = paragraph()
            parts.append(p.text)
            words += p.words
        }
        return (parts.joined(separator: "\n"), words)
    }
}

// MARK: - The seeder

enum MobilePerfFixtureSeeder {
    // MARK: Reserved identities (how discovery finds its own objects —
    // the B1 discipline; disjoint from the pocket guide's and the Mac's)

    nonisolated static let fixtureBookName = "the proving ground"
    nonisolated static let megaPostTitle = "the long haul"
    nonisolated static let controlPostTitle = "the short walk"
    nonisolated static let tagName = "perf fixture"
    nonisolated static let corpusBookNames = [
        "field journal vol. i", "field journal vol. ii",
        "field journal vol. iii", "field journal vol. iv",
        "field journal vol. v", "field journal vol. vi",
    ]

    // MARK: Full scale (the door's scale; tests may pass smaller)

    nonisolated static let fullCorpusNoteCount = 300
    nonisolated static let megaTargetWords = 100_000
    nonisolated static let controlTargetWords = 4_000

    // The chrome-staging cadence in the mega post (primes, so nothing
    // aligns): fans every 41st block, comments every 53rd, callouts
    // every 97th — the chrome layer participates in every measurement.
    nonisolated static let fanStride = 41
    nonisolated static let commentStride = 53
    nonisolated static let calloutStride = 97

    // Generator seeds — each content family is seeded INDEPENDENTLY so
    // one family's presence/size never perturbs another's bytes (the
    // control post is byte-identical in every world by construction).
    private nonisolated static let megaSeed: UInt64 = 0xA110_0001
    private nonisolated static let megaTakeSeed: UInt64 = 0xA110_7A4E
    private nonisolated static let controlSeed: UInt64 = 0xC701_0001
    private nonisolated static let controlTakeSeed: UInt64 = 0xC701_7A4E
    private nonisolated static let noteSeedBase: UInt64 = 0xC0_0000

    // MARK: The prose plans (pure — the determinism pin drives these)

    /// The mega post's block plan: paragraph-per-block predominantly,
    /// every 7th block two paragraphs, every 19th three (multi-paragraph
    /// blocks are load-bearing — I4), until the word target is crossed.
    nonisolated static func megaProse(
        targetWords: Int
    ) -> [(text: String, words: Int, paragraphs: Int)] {
        prose(seed: megaSeed, targetWords: targetWords)
    }

    /// The control post: the SAME shape rules, its own seed, ~1/25 the
    /// size — the small-fixture control the flatness pins compare
    /// against (chrome staged on it too, so both sides of every ratio
    /// run the same machinery).
    nonisolated static func controlProse(
        targetWords: Int
    ) -> [(text: String, words: Int, paragraphs: Int)] {
        prose(seed: controlSeed, targetWords: targetWords)
    }

    private nonisolated static func prose(
        seed: UInt64, targetWords: Int
    ) -> [(text: String, words: Int, paragraphs: Int)] {
        var gen = PerfProse(seed: seed)
        var blocks: [(text: String, words: Int, paragraphs: Int)] = []
        var words = 0
        var i = 0
        while words < targetWords {
            let paragraphs = i % 19 == 11 ? 3 : (i % 7 == 3 ? 2 : 1)
            let block = gen.block(paragraphs: paragraphs)
            blocks.append((block.text, block.words, paragraphs))
            words += block.words
            i += 1
        }
        return blocks
    }

    // MARK: Discovery (the doomed/found set — the B1 reserved-identity shape)

    struct Existing: Sendable {
        var fixtureBookIDs: [String] = []
        var corpusBookIDs: [String] = []
        var taggedPostIDs: [String] = []
        var tagID: String?
        var isSeeded: Bool { !fixtureBookIDs.isEmpty }
    }

    nonisolated static func discover(_ db: Database) throws -> Existing {
        var existing = Existing()
        let corpusNames = Set(corpusBookNames)
        for reading in try Queries.readings(db) {
            if reading.name == fixtureBookName {
                existing.fixtureBookIDs.append(reading.id)
            } else if corpusNames.contains(reading.name) {
                existing.corpusBookIDs.append(reading.id)
            }
        }
        if let tag = try Queries.allTags(db).first(where: { $0.path == tagName }) {
            existing.tagID = tag.id
            existing.taggedPostIDs = try Queries
                .everythingTagged(db, tagID: tag.id, includeSubtree: false)
                .postIDs
        }
        return existing
    }

    // MARK: The door (find-or-seed; never destructive, so no confirm)

    /// An existing fixture book simply reports (`seeded == nil`) — the
    /// door can never mint a second proving ground. No fixture book ⇒
    /// the full seed runs (a live `perf fixture` tag from residue is
    /// reused — createTag refuses duplicate live paths). There is
    /// deliberately NO wholesale-replace door in this batch (nothing
    /// here is ever destroyed; PROVISIONAL PB2, the batch record).
    @MainActor
    @discardableResult
    static func findOrSeed(
        session: AppSession,
        corpusNotes: Int = fullCorpusNoteCount,
        megaWords: Int = megaTargetWords
    ) async throws -> (bookID: String, seeded: SeedResult?) {
        let existing = try await session.database.read { db in try discover(db) }
        if let bookID = existing.fixtureBookIDs.first { return (bookID, nil) }
        let result = try await session.runner.run { _ in
            // The QUIET facade (the B1/Mac MINOR-D1 discipline): a seed
            // is not her act — nothing lands on the structural-undo stack.
            let quiet = Operations(undoStack: nil)
            return try seed(
                ops: quiet, corpusNotes: corpusNotes, megaWords: megaWords,
                existingTagID: existing.tagID)
        }
        return (result.fixtureBookID, result)
    }

    // MARK: The seed

    struct SeedResult: Sendable {
        var fixtureBookID: String
        var megaPostID: String?
        var megaWordCount = 0
        var megaBlockCount = 0
        var megaMultiParagraphBlocks = 0
        var megaFannedBlocks = 0
        var megaCommentedBlocks = 0
        var megaCalloutBlocks = 0
        var controlPostID: String
        var controlWordCount = 0
        var controlBlockCount = 0
        var corpusNoteCount = 0
        var corpusBlockCount = 0
    }

    /// Mints the whole fixture. `includeMegaPost: false` is the SMALL
    /// control world's shape (the corpus-flatness pins' other side):
    /// same six books, same control post bytes, a fraction of the notes.
    nonisolated static func seed(
        ops: Operations,
        corpusNotes: Int = fullCorpusNoteCount,
        megaWords: Int = megaTargetWords,
        includeMegaPost: Bool = true,
        existingTagID: String? = nil
    ) throws -> SeedResult {
        let tagID: String
        if let existingTagID {
            tagID = existingTagID
        } else {
            tagID = try ops.createTag(name: tagName).id
        }

        let fixtureBook = try ops.createReading(
            name: fixtureBookName, kind: .curated, profile: "collection")

        // — The corpus: notes spread evenly across six books (the book
        //   COUNT is constant in every world — corpus size is the axis,
        //   never corpus shape).
        var corpusBooks: [Reading] = []
        for name in corpusBookNames {
            corpusBooks.append(
                try ops.createReading(name: name, kind: .curated, profile: "collection"))
        }
        var corpusBlocks = 0
        for n in 0..<max(0, corpusNotes) {
            var gen = PerfProse(seed: noteSeedBase &+ UInt64(n))
            let book = corpusBooks[n % corpusBooks.count]
            let post = try ops.newPostInReading(
                book.id, title: "corpus note \(n + 1)", profile: .generic)
            _ = try ops.applyTag(tagID, toPost: post.id)
            let blockCount = 4 + Int(gen.probe(5))
            var firstBlock: Operations.NewBlockResult?
            for _ in 0..<blockCount {
                let text = gen.paragraph().text
                let minted = try ops.newBlock(in: post.id, text: text, at: .end)
                if firstBlock == nil { firstBlock = minted }
                corpusBlocks += 1
            }
            // A sprinkling of chrome in the corpus too (real libraries
            // carry fans and comments; the shell's lists render them).
            if n % 10 == 4, let first = firstBlock {
                let take = try ops.branchVariant(first.block.id, from: first.variant.id)
                let alt = gen.paragraph().text
                try ops.autosave(take.id, text: alt, charDelta: alt.count)
            }
            if n % 15 == 7, let first = firstBlock {
                _ = try ops.addBlockComment(
                    to: first.block.id, text: "corpus margin note \(n + 1)")
            }
        }

        // — The control post (the flatness pins' small fixture): its own
        //   seeds, so its bytes never depend on corpus size or the mega
        //   post's presence. Chrome staged (one fan, one comment, one
        //   callout) so the control side of every ratio runs the same
        //   machinery as the mega side.
        let control = try ops.newPostInReading(
            fixtureBook.id, title: controlPostTitle, profile: .generic)
        _ = try ops.applyTag(tagID, toPost: control.id)
        var result = SeedResult(
            fixtureBookID: fixtureBook.id, megaPostID: nil, controlPostID: control.id)
        var controlTakes = PerfProse(seed: controlTakeSeed)
        for (i, block) in controlProse(targetWords: controlTargetWords).enumerated() {
            let minted = try ops.newBlock(in: control.id, text: block.text, at: .end)
            result.controlBlockCount += 1
            result.controlWordCount += block.words
            if i == 5 {
                let take = try ops.branchVariant(minted.block.id, from: minted.variant.id)
                let alt = controlTakes.paragraph().text
                try ops.autosave(take.id, text: alt, charDelta: alt.count)
            }
            if i == 8 {
                _ = try ops.addBlockComment(
                    to: minted.block.id, text: "control margin note")
            }
            if i == 10 {
                try ops.setBlockPresentation(
                    minted.block.id,
                    BlockPresentation(color: "blue", emoji: "\u{1F4A1}"))
            }
        }

        // — The mega post: ~100k words of realistic paragraphs, chrome
        //   staged on the prime strides.
        if includeMegaPost {
            let mega = try ops.newPostInReading(
                fixtureBook.id, title: megaPostTitle, profile: .generic)
            _ = try ops.applyTag(tagID, toPost: mega.id)
            result.megaPostID = mega.id
            var takes = PerfProse(seed: megaTakeSeed)
            for (i, block) in megaProse(targetWords: megaWords).enumerated() {
                let minted = try ops.newBlock(in: mega.id, text: block.text, at: .end)
                result.megaBlockCount += 1
                result.megaWordCount += block.words
                if block.paragraphs > 1 { result.megaMultiParagraphBlocks += 1 }
                if i % fanStride == 5 {
                    let take = try ops.branchVariant(minted.block.id, from: minted.variant.id)
                    let alt = takes.paragraph().text
                    try ops.autosave(take.id, text: alt, charDelta: alt.count)
                    result.megaFannedBlocks += 1
                }
                if i % commentStride == 9 {
                    _ = try ops.addBlockComment(
                        to: minted.block.id, text: "margin note at block \(i + 1)")
                    result.megaCommentedBlocks += 1
                }
                if i % calloutStride == 13 {
                    try ops.setBlockPresentation(
                        minted.block.id,
                        BlockPresentation(
                            color: i % (calloutStride * 2) == 13 ? "blue" : "sand",
                            emoji: i % (calloutStride * 3) == 13 ? "\u{1F4A1}" : nil))
                    result.megaCalloutBlocks += 1
                }
            }
        }

        result.corpusNoteCount = max(0, corpusNotes)
        result.corpusBlockCount = corpusBlocks
        return result
    }
}
