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
    /// **Row 87's rule, re-expressed over 13u3 UNIT B's lead.** Her
    /// R-cor-11(2) is untouched — a titled card shows no derived line, a
    /// titleless one does — but what the card LEADS with moved (item 4), so
    /// the rule is now asked of the card rather than of the raw title:
    /// a titleless card leads with its WORDS and this line carries on from
    /// them; a day-led card (a daily entry) shows them whole underneath.
    @Test func theRuleShowsTheDerivedLineUnderATitlelessCardOnly() {
        func card(title: String?, snippet: String?, journal: Bool = false) -> NoteCardFace.Card {
            PoolCardFace.card(
                Queries.TimelineItem(
                    postID: "p", title: title, entryDate: "2026-01-15",
                    createdAt: "2026-01-15T09:00:00.000Z", stamp: "2026-01-15T09:00:00.000Z",
                    profile: journal ? "journal" : nil),
                snippet: snippet)
        }

        // Titleless: the words LEAD, so the line under them is what is left
        // (nothing here — the note is one short sentence).
        let bare = card(title: nil, snippet: "The first words of the note.")
        #expect(bare.lead == .words("The first words of the note."))
        #expect(PoolCardFace.preview(bare) == nil, "it has already said the whole note")

        // …and a longer note's line carries on rather than repeating.
        let long = card(
            title: "",
            snippet: "The lighthouse keeper counted the storms and wrote none of them down.")
        #expect(PoolCardFace.preview(long)?.hasPrefix("wrote") == true)

        // A DAILY entry keeps its day and shows its words underneath.
        let entry = card(title: "   ", snippet: "Frost, and a fox.", journal: true)
        #expect(entry.lead == .day("2026-01-15"))
        #expect(PoolCardFace.preview(entry) == "Frost, and a fox.")

        // A titled card: her rule, unchanged.
        #expect(PoolCardFace.preview(card(title: "A titled note", snippet: "The first words."))
                == nil, "a titled card already says what it is")
        #expect(PoolCardFace.preview(card(title: nil, snippet: nil)) == nil)
        #expect(PoolCardFace.preview(card(title: nil, snippet: "  \n")) == nil,
                "no words, no line")
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
            // …and the card LEADS with those words (13u3 UNIT B), rather
            // than with the bare day it used to show.
            let bareItem = try #require(model.posts.first { $0.postID == bare.id })
            let bareCard = PoolCardFace.card(bareItem, snippet: model.snippets[bare.id])
            #expect(bareCard.lead.text.hasPrefix("The lighthouse keeper counted"),
                    "the card leads with the note's own words: \(bareCard.lead.text)")
            let titledItem = try #require(model.posts.first { $0.postID == titled.id })
            let titledCard = PoolCardFace.card(titledItem, snippet: model.snippets[titled.id])
            #expect(titledCard.lead == .title("a titled note"))
            #expect(PoolCardFace.preview(titledCard) == nil,
                    "the titled card keeps its title alone")
        }
    }
}
