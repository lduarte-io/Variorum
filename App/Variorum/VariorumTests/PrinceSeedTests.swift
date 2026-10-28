//
//  PrinceSeedTests.swift
//  VariorumTests
//
//  VX-633 U2 — *THE PRINCE*, BILINGUAL: the seeded book's acceptance bar as
//  state evidence (`notes/plans/vx-633-prince-book.md`, the U2 brief and
//  record). What a fresh seed leaves in the store, block by block — the four
//  parts and the front matter, 27 notes in book order, every paragraph two
//  takes (Marriott's chosen, the Italian labelled "il principe 1532"), the
//  six Ricci third takes and Dacre's verse on the last block, the verse
//  blocks' line breaks on both sides, the 1532 clock on every row, the tag
//  on every note — plus the seeder's contracts on this book: the resource
//  pair, the drift pins against U1's generated table and the raw sources,
//  a resumed seed reusing its parts by name, a re-membered chapter never
//  passed twice, the restore door, and the book kept out of the dedupe.
//
//  The shape numbers are EXACT on purpose (the Jekyll suite's rule): the
//  content is generated and validated upstream, so any drift is loud here.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withPrinceWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1532))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // BOTH session mark leaves injected (the Jekyll suite's F2 rule): the
        // restore road reads and WRITES them, and the production leaves write
        // the test host's — the Debug app's — defaults.
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

/// A defaults-free mark, so a pin never touches this machine's real ones.
@MainActor
private final class PrinceMark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

@MainActor
private func poll(_ condition: @MainActor () -> Bool, turns: Int = 600) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// The repo's own files, read from the source tree (`TutorialCurrencyTests`'
/// `AppSource` precedent): U1's generated table and the raw Gutenberg text.
private enum RepoSource {
    static var root: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // the repo
    }

    static func read(_ relative: String) throws -> String {
        try String(contentsOf: root.appending(path: relative), encoding: .utf8)
    }

    /// The raw Marriott file's lines, its CRLF read as LF.
    static func marriottLines() throws -> [String] {
        try read("notes/source/prince-marriott-pg1232.txt")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
    }

    /// `count` lines of the raw Marriott text starting at the first line
    /// that begins with `opening`, each with its leading indent dropped.
    static func marriottVerse(startingWith opening: String, count: Int) throws -> [String] {
        let lines = try marriottLines()
        let start = try #require(lines.firstIndex { $0.hasPrefix(opening) })
        return lines[start..<(start + count)].map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

/// U1's generated third-take table (`notes/source/prince-famous-lines.json`).
private struct FamousTable: Decodable {
    struct Entry: Decodable {
        let noteTitle: String
        let paragraphIndex: Int
        let quoteHint: String
        let ricciText: String
    }
    let famousLines: [Entry]
}

/// One placed block of the book, read off the store.
private struct BlockFacts {
    var noteTitle: String
    var index: Int
    var takes: [Variant]
    var chosenID: String?
    var defaultID: String?
}

private let prince = SampleLibrarySeeder.Book.prince
private typealias PB = SampleLibraryPrinceBook

/// R-633-15: the saved lenses a chapter ships with, in the Lenses list's
/// order — the English and the Italian on every chapter; Ricci's where the
/// chapter carries a Ricci take; Dacre's on XXVI.
private func expectedLenses(_ title: String) -> [String] {
    var names = [PB.englishLensName, PB.italianTakeLabel]
    if PB.famousLines.contains(where: { $0.noteTitle == title }) { names.append(PB.ricciTakeLabel) }
    if PB.dacre.noteTitle == title { names.append(PB.dacreTakeLabel) }
    return names
}

/// A note's live lenses, in the Lenses list's order, each with its live
/// picks (block → take).
nonisolated private func lensPicks(_ db: Database, noteID: String) throws -> [(name: String, picks: [String: String])] {
    try Queries.lenses(db, post: noteID).map { lens in
        let rows = try Row.fetchAll(
            db,
            sql: "SELECT block_id, variant_id FROM lens_choice WHERE lens_id = ? AND deleted_at IS NULL",
            arguments: [lens.id])
        var picks: [String: String] = [:]
        for row in rows { picks[row["block_id"]] = row["variant_id"] }
        return (lens.name, picks)
    }
}

@MainActor
@Suite("The Prince, bilingual — the launch's seeded book (VX-633 U2)")
struct PrinceSeedTests {

    // MARK: - The two resources

    /// **The resource-pair pin.** The EN and IT resources name the same 27
    /// notes in the same order, and every note's English (as the import
    /// segments it) has EXACTLY as many paragraphs as its Italian — the
    /// pairing the take pass relies on. A drifted pair fails here, in the
    /// build, never at seed time.
    @Test("The two resources pair note for note and paragraph for paragraph")
    func theTwoResourcesPairNoteForNote() throws {
        let english = try SampleLibrarySeeder.loadStories(for: prince)
        let italian = try SampleLibrarySeeder.TakePass.princeBilingual.loadCompanion()
        #expect(english.count == 27, "the dedication and twenty-six chapters")
        #expect(english.first?.title == "Dedication")
        #expect(english.last?.title == "XXVI. An exhortation to liberate Italy from the barbarians")
        #expect(Set(italian.keys) == Set(english.map(\.title)), "the same titles")
        var pairs = 0
        for story in english {
            let blocks = SegmentationRules.bulkSegments(story.text, mode: SampleLibrarySeeder.segmentation)
            let paragraphs = try #require(italian[story.title], Comment(rawValue: story.title))
            #expect(blocks.count == paragraphs.count, Comment(rawValue: story.title))
            // The typed-note shape: no block stores a blank line (the Jekyll
            // book's design call 4 — the plan's U1 brief).
            #expect(blocks.allSatisfy { !$0.hasSuffix("\n") }, Comment(rawValue: story.title))
            #expect(paragraphs.allSatisfy { !$0.isEmpty }, Comment(rawValue: story.title))
            pairs += blocks.count
        }
        #expect(pairs == 200, "the U1 count table's total")
        // Only the two verse paragraphs hold a newline of their own.
        let lineBroken = italian.flatMap { title, paragraphs in
            paragraphs.enumerated().filter { $0.element.contains("\n") }.map { "\(title.prefix(6))\($0.offset)" }
        }
        #expect(Set(lineBroken) == ["XVII. 2", "XXVI. 10"])
    }

    /// **The drift pin** for the transcribed third-take table: every field of
    /// `SampleLibraryPrinceBook.famousLines` equals U1's generated JSON, byte
    /// for byte and in order — and each hint really is in its block's
    /// English (the seed-time check, pinned statically).
    @Test("The famous lines match U1's generated table, and each hint is in its English")
    func theFamousLinesMatchTheGeneratedTable() throws {
        let json = try RepoSource.read("notes/source/prince-famous-lines.json")
        let table = try JSONDecoder().decode(FamousTable.self, from: Data(json.utf8))
        #expect(table.famousLines.count == 6)
        #expect(PB.famousLines.count == table.famousLines.count)
        for (mine, generated) in zip(PB.famousLines, table.famousLines) {
            #expect(mine.noteTitle == generated.noteTitle)
            #expect(mine.paragraphIndex == generated.paragraphIndex)
            #expect(mine.quoteHint == generated.quoteHint)
            #expect(mine.text == generated.ricciText, Comment(rawValue: generated.noteTitle))
            #expect(mine.label == PB.ricciTakeLabel)
        }
        #expect(PB.ricciTakeLabel == "ricci 1903", "R-633-14, ratified")
        let english = Dictionary(
            uniqueKeysWithValues: try SampleLibrarySeeder.loadStories(for: prince).map { ($0.title, $0.text) })
        for third in PB.thirdTakes {
            let text = try #require(english[third.noteTitle], Comment(rawValue: third.noteTitle))
            let blocks = SegmentationRules.bulkSegments(text, mode: SampleLibrarySeeder.segmentation)
            #expect(blocks.indices.contains(third.paragraphIndex))
            #expect(blocks[third.paragraphIndex].contains(third.quoteHint), Comment(rawValue: third.quoteHint))
        }
    }

    /// **R-633-13's pin — Dacre's verse IS the raw source's four lines**
    /// (PG #1232 lines 3690–3693, indent dropped), the attribution line is
    /// not in the take, and it rides the book's last block.
    @Test("Dacre's take is the raw source's four lines, attribution excluded, on the last block")
    func dacresVerseIsTheRawSourcesFourLines() throws {
        let lines = try RepoSource.marriottVerse(startingWith: "Virtue against fury", count: 6)
        #expect(PB.dacre.text == lines[0..<4].joined(separator: "\n"))
        #expect(lines[4].isEmpty && lines[5] == "Edward Dacre, 1640.", "the attribution follows")
        #expect(!PB.dacre.text.contains("Dacre"), "and is not part of the take")
        #expect(PB.dacre.label == "dacre 1640", "R-633-13")
        let english = try SampleLibrarySeeder.loadStories(for: prince)
        let last = try #require(english.last)
        let blocks = SegmentationRules.bulkSegments(last.text, mode: SampleLibrarySeeder.segmentation)
        #expect(PB.dacre.noteTitle == last.title && PB.dacre.paragraphIndex == blocks.count - 1,
                "the book's last block")
    }

    /// The two English verse blocks are put back line by line from the raw
    /// source — and what the import stores is exactly their flattening.
    @Test("The English verse restorations are the raw source's lines, flattened by the import")
    func theVerseRestorationsAreTheRawSourcesLines() throws {
        let english = Dictionary(
            uniqueKeysWithValues: try SampleLibrarySeeder.loadStories(for: prince).map { ($0.title, $0.text) })
        let stanza = try RepoSource.marriottVerse(startingWith: "Virtu contro al Furore", count: 4)
        let couplet = try RepoSource.marriottVerse(startingWith: "\u{201C}Res dura", count: 2)
            .map { $0.replacingOccurrences(of: "[2]", with: "") }   // Marriott's footnote marker
        let expected = [
            "XVII. Concerning cruelty and clemency, and whether it is better to be loved than feared":
                couplet.joined(separator: "\n"),
            "XXVI. An exhortation to liberate Italy from the barbarians": stanza.joined(separator: "\n"),
        ]
        #expect(PB.verseRestorations.count == 2)
        for verse in PB.verseRestorations {
            #expect(verse.text == expected[verse.noteTitle], Comment(rawValue: verse.noteTitle))
            let text = try #require(english[verse.noteTitle])
            let blocks = SegmentationRules.bulkSegments(text, mode: SampleLibrarySeeder.segmentation)
            #expect(blocks[verse.paragraphIndex] == verse.flattened, "the import's flat line, exactly")
        }
    }

    // MARK: - The parts, the clock, the front note

    /// R-633-5's second set, lowercased: I–XI · XII–XIV · XV–XXIII · XXIV–XXVI,
    /// the Dedication opening the first part (PROVISIONAL).
    @Test("Every note falls in its part; the dedication opens the first")
    func everyNoteFallsInItsPart() throws {
        #expect(PB.parts.map(\.name) == [
            "types of principalities", "military and armies",
            "rulership, conduct, and virtue", "the state of italy and conclusion",
        ])
        let titles = try SampleLibrarySeeder.loadStories(for: prince).map(\.title)
        var perPart: [String: Int] = [:]
        for (offset, title) in titles.enumerated() {
            #expect(PB.chapterNumber(of: title) == (offset == 0 ? nil : offset), Comment(rawValue: title))
            perPart[PB.part(for: title), default: 0] += 1
        }
        #expect(perPart == [
            "types of principalities": 12, "military and armies": 3,
            "rulership, conduct, and virtue": 9, "the state of italy and conclusion": 3,
        ])
        #expect(prince.grouping.chapter(for: "Dedication") == "types of principalities")
        #expect(SampleLibrarySeeder.Book.sherlock.grouping.chapter(for: "A Scandal in Bohemia")
                == "A Scandal in Bohemia", "every earlier book: one chapter per note, unchanged")
    }

    @Test("The book's clock is the first printing's, and it round-trips byte-identically")
    func theClockIsTheFirstPrinting() {
        #expect(PB.publicationStamp == "1532-01-04T00:00:00.000Z")
        #expect(DateFormatter.variorumISO8601.string(from: PB.publicationDate) == PB.publicationStamp,
                "pre-1582: the store's own formatter reads and writes it alike")
        #expect(prince.clock == PB.publicationDate)
    }

    /// The front note names the door the registry actually renders (a
    /// renamed verb would make it lie), carries the tag sentence and the
    /// two-copies line, and stores no blank line.
    @Test("The front note names the real Restore door and stores no blank line")
    func theFrontNoteNamesTheRealRestoreDoor() {
        let text = PB.aboutThisText
        #expect(text.contains("Help \u{25B8} " + CapabilityRegistry.capability(.restorePrinceBook).verb))
        #expect(CapabilityRegistry.capability(.restorePrinceBook).verb == "Restore \u{201C}the prince\u{201D}")
        #expect(text.contains("\u{201C}\(PB.tagName)\u{201D}"), "the tag sentence")
        #expect(text.contains("can appear twice"), "R-633-7's two-copies line")
        #expect(!text.contains("\n\n"), "no stored blank lines")
        #expect(text.components(separatedBy: "\n").count == 5, "five paragraphs, five blocks")
    }

    // MARK: - The seed

    /// **THE SEED SHAPE.** A fresh seed of the Prince, block by block.
    @Test("The seed mints the bilingual book: parts, 27 chapters, every block two takes, the standouts three")
    func theSeedMintsTheBilingualBook() async throws {
        try await withPrinceWorld { session, db in
            let mark = PrinceMark()
            let clock = ContinuousClock()
            let began = clock.now
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince, loadMark: mark.load, saveMark: mark.save)
            print("[VX-633 U2] the Prince seed (skeleton + 27 imports + the take pass) took \(clock.now - began)")
            guard case .seeded(let bookID, let minted) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(minted == 27)
            #expect(mark.value, "the mark lands only after the COMPLETE seed")
            #expect(session.undoStack.depth == 0, "furniture never lands on her structural-undo stack")

            let englishTitles = try SampleLibrarySeeder.loadStories(for: prince).map(\.title)
            let italian = try SampleLibrarySeeder.TakePass.princeBilingual.loadCompanion()
            try await db.read { db in
                // THE BOOK — its name, its clock, plain until the arrangement.
                let book = try #require(try Queries.reading(db, id: bookID))
                #expect(book.name == "the prince" && book.kind == .book && book.profile == "book")
                #expect(book.createdAt == PB.publicationDate, "the book carries 1532")
                #expect(!book.owned, "owning is the Welcome arrangement's act, never the seed's")
                // THE CHAPTERS — the front matter's, then the four parts, once each.
                #expect(try Queries.readingSections(db, readingID: bookID).map(\.name)
                        == [PB.frontMatterChapter] + PB.parts.map(\.name))
                // THE NOTES — in book order, each in its part.
                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.compactMap(\.title) == [PB.frontMatterTitle] + englishTitles)
                for entry in entries {
                    let section = try String.fetchOne(
                        db,
                        sql: """
                            SELECT rs.name FROM reading_post rp
                            JOIN reading_section rs ON rs.id = rp.section_id
                            WHERE rp.reading_id = ? AND rp.post_id = ? AND rp.deleted_at IS NULL
                            """,
                        arguments: [bookID, entry.postID])
                    let title = try #require(entry.title)
                    let expected = title == PB.frontMatterTitle ? PB.frontMatterChapter : PB.part(for: title)
                    #expect(section == expected, Comment(rawValue: title))
                }
                // THE TAG on every note; the Pool blank.
                let tag = try #require(try Queries.allTags(db).first { $0.path == PB.tagName })
                #expect(try Queries.everythingTagged(db, tagID: tag.id).postIDs.count == 28)
                #expect(try Queries.poolPosts(db, limit: 100).isEmpty, "every note is a member")

                // THE FRONT NOTE — one take per paragraph, exactly the text.
                let front = try #require(entries.first?.postID)
                #expect(try Self.blocks(db, noteID: front, title: PB.frontMatterTitle)
                        .map { $0.takes.map(\.workingText) }
                        == PB.aboutThisText.components(separatedBy: "\n").map { [$0] })

                // EVERY BLOCK of the 27 chapters.
                var fanSizes: [Int: Int] = [:]
                var thirdLabels: [String: Int] = [:]
                for entry in entries.dropFirst() {
                    let title = try #require(entry.title)
                    let paragraphs = try #require(italian[title])
                    let blocks = try Self.blocks(db, noteID: entry.postID, title: title)
                    #expect(blocks.count == paragraphs.count, Comment(rawValue: title))
                    for block in blocks {
                        fanSizes[block.takes.count, default: 0] += 1
                        let marriott = try #require(block.takes.first)
                        #expect(marriott.label == nil, "Marriott's take is the original, unlabelled")
                        #expect(block.chosenID == nil || block.chosenID == marriott.id,
                                "nothing chosen but Marriott's")
                        #expect(block.defaultID == marriott.id, "the default stays Marriott's")
                        #expect(block.takes.count >= 2, "\(title) ¶\(block.index)")
                        guard block.takes.count >= 2 else { continue }
                        #expect(block.takes[1].label == PB.italianTakeLabel)
                        #expect(block.takes[1].workingText == paragraphs[block.index],
                                "\(title) ¶\(block.index): its own Italian")
                        for take in block.takes.dropFirst(2) { thirdLabels[take.label ?? "", default: 0] += 1 }
                        #expect(block.takes.allSatisfy {
                            $0.status == .active && !$0.locked
                                && $0.createdAt == PB.publicationDate && $0.updatedAt == PB.publicationDate
                        }, "every take active, unlocked, stamped 1532")
                    }
                }
                #expect(fanSizes == [2: 193, 3: 7], "200 blocks: 193 bilingual, 7 with a third take")
                #expect(thirdLabels == [PB.ricciTakeLabel: 6, PB.dacreTakeLabel: 1])

                // THE SAVED LENSES (R-633-15) — every chapter its set, each
                // lens exactly its picks; the front note none.
                #expect(try Queries.lenses(db, post: front).isEmpty, "the front note has no takes, so no lenses")
                var lensCount = 0
                for entry in entries.dropFirst() {
                    let title = try #require(entry.title)
                    let blocks = try Self.blocks(db, noteID: entry.postID, title: title)
                    let lenses = try lensPicks(db, noteID: entry.postID)
                    lensCount += lenses.count
                    #expect(lenses.map(\.name) == expectedLenses(title), Comment(rawValue: title))
                    for lens in lenses {
                        var expected: [String: String] = [:]
                        for block in blocks where block.takes.count >= 2 {
                            switch lens.name {
                            case PB.englishLensName:
                                expected[block.takes[0].blockId] = block.takes[0].id   // by explicit id
                            case PB.italianTakeLabel:
                                expected[block.takes[1].blockId] = block.takes[1].id
                            default:   // a third-take lens: only its blocks (sparse)
                                if block.takes.count == 3, block.takes[2].label == lens.name {
                                    expected[block.takes[2].blockId] = block.takes[2].id
                                }
                            }
                        }
                        #expect(lens.picks == expected, "\(title): “\(lens.name)”")
                    }
                }
                #expect(lensCount == 60, "27 × (english + italian) + 5 Ricci chapters + XXVI's Dacre")
                // Spot checks, spelled out (never derived from the table alone).
                let byTitle = Dictionary(uniqueKeysWithValues: entries.compactMap { e in e.title.map { ($0, e.postID) } })
                let seventeen = try #require(byTitle["XVII. Concerning cruelty and clemency, and whether it is better to be loved than feared"])
                let twentySix = try #require(byTitle["XXVI. An exhortation to liberate Italy from the barbarians"])
                let two = try #require(byTitle["II. Concerning hereditary principalities"])
                #expect(try lensPicks(db, noteID: seventeen).map(\.name) == ["marriott 1908", "il principe 1532", "ricci 1903"])
                #expect(try lensPicks(db, noteID: twentySix).map(\.name) == ["marriott 1908", "il principe 1532", "dacre 1640"])
                #expect(try lensPicks(db, noteID: two).map(\.name) == ["marriott 1908", "il principe 1532"])

                // THE THIRD TAKES — on their blocks, word for word.
                for third in PB.thirdTakes {
                    let note = try #require(entries.first { $0.title == third.noteTitle }?.postID)
                    let block = try Self.blocks(db, noteID: note, title: third.noteTitle)[third.paragraphIndex]
                    #expect(block.takes.map(\.label) == [nil, PB.italianTakeLabel, third.label])
                    #expect(block.takes.last?.workingText == third.text)
                    #expect(block.takes[0].workingText.contains(third.quoteHint))
                }

                // THE VERSE — line breaks on BOTH sides; the last block three
                // takes: Marriott's Italian printing chosen, the 1532 text,
                // Dacre (R-633-13).
                for verse in PB.verseRestorations {
                    let note = try #require(entries.first { $0.title == verse.noteTitle }?.postID)
                    let block = try Self.blocks(db, noteID: note, title: verse.noteTitle)[verse.paragraphIndex]
                    #expect(block.takes[0].workingText == verse.text)
                    #expect(block.takes[0].workingText.contains("\n") && block.takes[1].workingText.contains("\n"))
                }
                let lastNote = try #require(entries.last?.postID)
                let lastBlock = try #require(try Self.blocks(db, noteID: lastNote, title: "XXVI").last)
                #expect(lastBlock.takes.map(\.label) == [nil, PB.italianTakeLabel, PB.dacreTakeLabel])
                #expect(lastBlock.takes.map(\.workingText).allSatisfy { $0.components(separatedBy: "\n").count == 4 },
                        "three four-line stanzas side by side")

                // EVERY ROW of the seed carries the book's clock.
                let unstamped = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container c
                        JOIN reading_post rp ON rp.post_id = c.id AND rp.reading_id = ? AND rp.deleted_at IS NULL
                        WHERE c.created_at <> ? OR c.updated_at <> ? OR c.last_touched_at <> ?
                        """,
                    arguments: [bookID, PB.publicationStamp, PB.publicationStamp, PB.publicationStamp]) ?? -1
                #expect(unstamped == 0, "every note stamped 1532")
            }
        }
    }

    /// The book's placed blocks, in placement order, each with its live fan
    /// (fan order) and the pointer's choice.
    nonisolated private static func blocks(_ db: Database, noteID: String, title: String) throws -> [BlockFacts] {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id
                FROM container_block cb JOIN block b ON b.id = cb.block_id
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                ORDER BY cb.position, cb.id
                """,
            arguments: [noteID])
        return try rows.enumerated().map { index, row in
            let blockID: String = row["block_id"]
            let takes = try Variant.fetchAll(
                db,
                sql: """
                    SELECT * FROM variant WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID])
            return BlockFacts(
                noteTitle: title, index: index, takes: takes,
                chosenID: row["chosen_variant_id"], defaultID: row["default_variant_id"])
        }
    }

    // MARK: - Resume, re-member, restore

    /// **m5, for parts.** A seed cancelled after thirteen chapters (the
    /// dedication through XII — part one whole, part two begun) resumes at
    /// the next occasion: the missing fourteen mint, the parts are REUSED by
    /// name (five sections, never a doubled part), and every resumed chapter
    /// gets its takes.
    @Test("A cancelled seed resumes into the same parts, every chapter with its takes")
    func aCancelledSeedResumesIntoTheSameParts() async throws {
        try await withPrinceWorld { session, db in
            let stories = try SampleLibrarySeeder.loadStories(for: prince)
            let fresh = try await db.read { db in try SampleLibrarySeeder.discover(db, book: prince) }
            let partial = try await SampleLibrarySeeder.seed(
                session: session, book: prince, stories: Array(stories.prefix(13)), existing: fresh)
            #expect(partial.minted == 13)
            let halfway = try await db.read { db in try SampleLibrarySeeder.discover(db, book: prince) }
            #expect(Set(halfway.chapterIDsByName.keys)
                    == [PB.frontMatterChapter, "types of principalities", "military and armies"])

            let mark = PrinceMark()
            guard case .seeded(let bookID, let resumed) = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince, loadMark: mark.load, saveMark: mark.save)
            else {
                Issue.record("the resume seeds the rest")
                return
            }
            #expect(bookID == partial.readingID && resumed == 14)
            try await db.read { db in
                #expect(try Queries.readingSections(db, readingID: bookID).map(\.name)
                        == [PB.frontMatterChapter] + PB.parts.map(\.name), "five sections, none doubled")
                var fanSizes: [Int: Int] = [:]
                for entry in try Queries.assembleReading(db, readingID: bookID).dropFirst() {
                    for block in try Self.blocks(db, noteID: entry.postID, title: entry.title ?? "") {
                        fanSizes[block.takes.count, default: 0] += 1
                    }
                }
                #expect(fanSizes == [2: 193, 3: 7], "every chapter bilingual — the resumed ones too")
                for entry in try Queries.assembleReading(db, readingID: bookID).dropFirst() {
                    let title = try #require(entry.title)
                    #expect(try lensPicks(db, noteID: entry.postID).map(\.name) == expectedLenses(title),
                            "a note present ⇒ its full lens set present (R-633-15): \(title)")
                }
            }
        }
    }

    /// **The pass runs on FRESH imports only.** A chapter she took out of the
    /// book survives bookless and tagged (a STRAY) — Restore re-members it
    /// AS IT IS, never a second Italian take on top of hers; a chapter she
    /// deleted comes back fresh with its takes.
    @Test("Restore re-members a stray chapter untouched and mints a deleted one fresh with its takes")
    func restoreReMembersAStrayAndMintsADeletedChapterFresh() async throws {
        try await withPrinceWorld { session, db in
            let mark = PrinceMark()
            guard case .seeded(let bookID, _) = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: prince, loadMark: mark.load, saveMark: mark.save)
            else {
                Issue.record("expected a seed")
                return
            }
            let strayTitle = "XVIII. Concerning the way in which princes should keep faith"
            let deletedTitle = "XXV. What fortune can effect in human affairs and how to withstand her"
            let (stray, deleted) = try await db.read { db -> (String, String) in
                let entries = try Queries.assembleReading(db, readingID: bookID)
                return (try #require(entries.first { $0.title == strayTitle }?.postID),
                        try #require(entries.first { $0.title == deletedTitle }?.postID))
            }
            let (strayFans, strayLenses) = try await db.read { db in
                (try Self.blocks(db, noteID: stray, title: strayTitle).map(\.takes.count),
                 try lensPicks(db, noteID: stray).map(\.name))
            }
            let ops = session.operations
            #expect(try ops.removePostFromReading(stray, from: bookID), "bookless — a stray")
            try ops.deleteContainer(deleted)

            let restored = try await SeededBookRestore.restore(session: session, book: prince)
            guard case .restored(let sameBook, let minted) = restored else {
                Issue.record("the two chapters come back: \(restored)")
                return
            }
            #expect(sameBook == bookID && minted == 2)
            try await db.read { db in
                let entries = try Queries.assembleReading(db, readingID: bookID)
                #expect(entries.compactMap(\.title).count == 28)
                #expect(entries.first { $0.title == strayTitle }?.postID == stray, "the stray, re-membered")
                #expect(try Self.blocks(db, noteID: stray, title: strayTitle).map(\.takes.count) == strayFans,
                        "…untouched: no second Italian take")
                #expect(try lensPicks(db, noteID: stray).map(\.name) == strayLenses,
                        "…and no second set of lenses")
                let fresh = try #require(entries.first { $0.title == deletedTitle }?.postID)
                #expect(fresh != deleted, "the deleted chapter mints afresh")
                let blocks = try Self.blocks(db, noteID: fresh, title: deletedTitle)
                #expect(blocks.allSatisfy { $0.takes.count >= 2 && $0.takes[1].label == PB.italianTakeLabel })
                #expect(blocks[1].takes.count == 3, "fortune's river keeps Ricci's take")
                #expect(try lensPicks(db, noteID: fresh).map(\.name) == expectedLenses(deletedTitle),
                        "…and its lenses")
                #expect(try Queries.readingSections(db, readingID: bookID).count == 5, "no part doubled")
            }
        }
    }

    /// **Help ▸ Restore “the prince”** on an empty store: the book mints
    /// whole, the receipt counts chapters, and the Welcome arrangement the
    /// door composes OWNS it (fork-free) and shelves it on Welcome, its notes
    /// wearing #classics.
    @Test("The restore door mints the Prince owned, on Welcome, its notes #classics")
    func theRestoreDoorMintsThePrinceOwnedOnWelcome() async throws {
        try await withPrinceWorld { session, db in
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.restorePrinceBook()
            await poll { session.status.spoken != nil || session.status.current != nil }
            let spoken = try #require(session.status.spoken?.text)
            #expect(spoken.hasPrefix(SeededBookReceipt.restored(book: PB.name, unit: .chapter, minted: 27)),
                    "the receipt: \(spoken)")
            let selection = shell.pendingSelection
            try await db.read { db in
                let book = try #require(try Queries.readings(db).first { $0.name == PB.name })
                #expect(selection == .reading(book.id), "the door opens the book")
                #expect(book.owned, "owned — every chapter was the book's alone")
                let welcome = try #require(try Shelf.fetchOne(
                    db, sql: "SELECT * FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL"))
                #expect(book.shelfId == welcome.id, "on Welcome")
                let classics = try #require(try Queries.allTags(db, wingID: "").first {
                    $0.path == SampleLibrarySeeder.classicsTagPath
                })
                let tagged = Set(try String.fetchAll(
                    db, sql: "SELECT post_id FROM post_tag WHERE tag_id = ? AND deleted_at IS NULL",
                    arguments: [classics.id]))
                let notes = Set(try Queries.assembleReading(db, readingID: book.id).map(\.postID))
                #expect(notes.count == 28 && tagged == notes, "every shipped note wears #classics")
            }
        }
    }

    // MARK: - The swap and the dedupe

    /// **The swap pin (R-633-6).** The launch seeds the Prince alone; every
    /// earlier book keeps its restore door (Sherlock joins Jekyll as
    /// restore-only); the Prince stays OUT of the pristine dedupe, so the
    /// engine's facts list is byte-identical. RED ON OLD by construction: the
    /// old launch set was `[.sherlock]` and the Prince did not exist.
    @Test("The launch seeds the Prince; Sherlock and Jekyll stay restorable; the dedupe is untouched")
    func theLaunchSeedsThePrinceAndEveryDoorStays() {
        #expect(SampleLibrarySeeder.Book.launchSet == [.prince])
        #expect(SampleLibrarySeeder.Book.launchBook == .prince)
        #expect(SampleLibrarySeeder.Book.all == [.sherlock, .encryptionExplained, .jekyllAndHyde, .prince])
        for id in [CapabilityID.restorePrinceBook, .restoreSampleLibrary, .restoreJekyllBook] {
            #expect(CapabilityRegistry.capability(id).doors.contains(.menuBar), "\(id) on the Help menu")
            #expect(ShellActions.paletteActs.contains(id), "\(id) typeable in ⌘K")
        }
        #expect(!prince.joinsPristineDedupe)
        #expect(!SampleLibrarySeeder.Book.dedupeCovered.contains(prince))
        #expect(SampleLibrarySeeder.allDedupeFacts().map(\.bookName)
                == [SampleLibrarySeeder.bookName, SampleLibraryEncryptionBook.name],
                "the engine's facts: byte-identical (zero Sync/)")
        #expect(SampleLibrarySeeder.seededDefaultsKey(for: .real, book: prince)
                == "SampleLibrarySeeded.\(AppDatabase.StoreVariant.real.rawValue).the-prince", "its OWN mark")
        #expect(SampleLibraryWelcome.classicBooks.contains(prince))
        #expect(SampleLibraryWelcome.ownedBooks == [.sherlock, .prince])
    }
}
