//
//  PaletteSearchTests.swift
//  VariorumTests
//
//  **13o U2 — ⌘K gains body hits** (D7; her R-13o-7: *"I agree that library
//  field should be one giant finder"* — ⌘K keeps its quick-jump role WITH
//  body hits — and the mockup's shared section: *"⌘K gains a few passages
//  under its title hits"*). Pinned:
//
//  - a bounded few PASSAGES (5) under the title hits — body hits only (a
//    note's title is its row above; a book's name is the book row), each
//    landing AT its match (D6: the block and the find seed through `onLand`);
//  - R-13o-9's letter on the palette: the few are never the end of the road —
//    one last row, "All matches in the Library ›", hands the SAME words
//    (untrimmed — the same question, the same prefix) to the Library;
//  - no words, no passages, no road.
//
//  New road, new pins: on the pre-change tree they do not compile (the
//  palette's `.passage`/`.allMatches` kinds, `onLand` and `onSearchLibrary`
//  did not exist; ⌘K matched titles and named blocks by LIKE only).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — ⌘K's body hits and its road to the rest", .serialized)
struct PaletteSearchTests {
    private func withPalette<T>(_ body: @MainActor (AppSession, PaletteModel) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                start.addingTimeInterval(Double(tick.withValue { v -> Int in defer { v += 1 }; return v }))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            return try await body(session, PaletteModel(session: session))
        }
    }

    @Test func aFewPassagesSitUnderTheTitleHitsAndLandAtTheirMatch() async throws {
        try await withPalette { session, model in
            let ops = session.operations
            let titled = try ops.createPost(title: "Harbor")
            _ = try ops.newBlock(in: titled.id, text: "nothing here")
            var blocks: [String: String] = [:]
            for i in 0..<8 {
                let note = try ops.createPost(title: "note \(i)")
                let made = try ops.newBlock(in: note.id, text: "the harbor light number \(i)")
                blocks[made.block.id] = note.id
            }
            _ = try ops.createReading(name: "Harbor Book", kind: .book)

            model.query = "harbor"
            await model.refresh()
            let kinds = model.items.map(\.kind)
            let passages = model.items.filter { $0.kind == .passage }
            #expect(passages.count == PaletteModel.passageCount, "a bounded few — five")
            #expect(kinds.lastIndex(of: .post).map { $0 < kinds.firstIndex(of: .passage)! } == true,
                    "UNDER the title hits")
            #expect(!passages.contains { $0.homeContainerID == titled.id },
                    "the titled note's title is its row above, never a passage too")
            #expect(passages.allSatisfy { $0.title.lowercased().contains("harbor") })
            #expect(passages.allSatisfy { $0.find == EditorFindSeed(needle: "harbor", steps: true) })

            var landed: [(SidebarSelection, String, EditorFindSeed?)] = []
            for item in passages {
                model.execute(item, onOpen: { _, _ in Issue.record("a passage lands, it never just opens") },
                              onLand: { landed.append(($0, $1, $2)) })
            }
            #expect(landed.count == passages.count)
            #expect(landed.allSatisfy { entry in
                if case .post(let id) = entry.0 { return blocks[entry.1] == id } else { return false }
            }, "each lands in its own note, at its own block")

            // R-13o-9: the road to the rest, last, with the words as typed.
            let road = try #require(model.items.last)
            #expect(road.kind == .allMatches && road.title == CommandPaletteCopy.allMatches)
            var asked: String?
            model.execute(road, onOpen: { _, _ in }, onSearchLibrary: { asked = $0 })
            #expect(asked == "harbor", "the same question — a word still being typed stays a prefix")
        }
    }

    @Test func noWordsNoPassagesAndNoRoad() async throws {
        try await withPalette { session, model in
            let note = try session.operations.createPost(title: "x")
            _ = try session.operations.newBlock(in: note.id, text: "words")
            model.query = ""
            await model.refresh()
            #expect(!model.items.contains { $0.kind == .passage || $0.kind == .allMatches })
            model.query = "— "
            await model.refresh()
            #expect(!model.items.contains { $0.kind == .passage }, "punctuation finds no passage")
        }
    }

    @Test func thePalettesQuestionIsTheBodysOnly() {
        let query = PaletteModel.passageQuestion("dream #journal")
        #expect(query?.text == .prefix("dream"))
        #expect(query?.filter == .all([.tagPath("journal"),
                                       .all([.not(.docKind(.title)), .not(.family(.books))])]))
        #expect(PaletteModel.passageQuestion("#journal") == nil, "a tag alone asks the index nothing")
    }
}
