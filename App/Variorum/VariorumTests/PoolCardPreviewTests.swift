//
//  PoolCardPreviewTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch G — **row 87 (R-cor-11(2)): the Pool
//  card's first-words preview via the picker's road.** The orchestrator's
//  walk found the Pool a wall of bare dates — ten titleless notes showing
//  only their day and a lone `+` — while the note picker already carried a
//  two-line preview under every match. The model now reads the listed
//  notes' snippets through `Queries.notePickerNotes(ids:)` (one brain), and
//  `PoolCardFace.preview` shows them under a TITLELESS card only. RED ON
//  OLD: the model had no snippets, and no rule existed.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The Pool card's first-words preview (correction round, row 87)")
struct PoolCardPreviewTests {
    @Test func theRuleShowsTheSnippetUnderATitlelessCardOnly() {
        #expect(PoolCardFace.preview(title: nil, snippet: "The first words of the note.")
            == "The first words of the note.")
        #expect(PoolCardFace.preview(title: "", snippet: "The first words.") == "The first words.")
        #expect(PoolCardFace.preview(title: "   ", snippet: "The first words.") == "The first words.")
        #expect(PoolCardFace.preview(title: "A titled note", snippet: "The first words.") == nil,
                "a titled card already says what it is")
        #expect(PoolCardFace.preview(title: nil, snippet: nil) == nil)
        #expect(PoolCardFace.preview(title: nil, snippet: "  \n") == nil, "no words, no line")
    }

    @MainActor
    @Test func theModelReadsTheListedNotesFirstWordsThroughThePickersRoad() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 87))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Two bookless notes — the Pool's population: one titleless with
            // words, one titled.
            let bare = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(
                in: bare.id, text: "The lighthouse keeper counted the storms, and wrote none down.")
            let titled = try session.operations.createPost(title: "a titled note")
            _ = try session.operations.newBlock(in: titled.id, text: "Its own first words.")

            let model = PoolPostsModel(session: session)
            let watching = Task { await model.start() }
            defer { watching.cancel() }
            let deadline = Date().addingTimeInterval(4)
            while Date() < deadline, model.snippets[bare.id] == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(model.posts.map(\.postID).contains(bare.id), "the bare note is in the Pool")
            #expect(model.snippets[bare.id]?.hasPrefix("The lighthouse keeper counted") == true,
                    "the picker's snippet rode in for the bare note: \(model.snippets[bare.id] ?? "nil")")
            #expect(PoolCardFace.preview(title: nil, snippet: model.snippets[bare.id]) != nil,
                    "…and the card shows it under its day")
            #expect(PoolCardFace.preview(title: "a titled note", snippet: model.snippets[titled.id]) == nil,
                    "the titled card keeps its title alone")
        }
    }
}
