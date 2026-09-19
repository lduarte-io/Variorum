//
//  TitleSuggestionChipTests.swift
//  VariorumTests
//
//  **13u3 UNIT B — the capture half of her item 4** (RULED 2026-08-21):
//  *"the title-suggestion chip at quick-note/capture (first words offered,
//  one tap to adopt, ignorable forever — a suggestion, never an action taken
//  for her)"*, beside *"STORED Apple-Notes-style auto-title DEFINITIVELY
//  rejected — what I hate is battling the apple notes title."*
//
//  So the load-bearing cell in this file is the NEGATIVE one: a capture she
//  never clicks the chip on files exactly as it always did — untitled. The
//  rest pin that one click does what it says, on both capture surfaces, and
//  that the decision travels with her text rather than outliving it.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The title suggestion at capture (13u3 UNIT B — her item 4)")
struct TitleSuggestionChipTests {

    private func withCapture<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func storedTitle(_ db: AppDatabase, _ postID: String) async throws -> String? {
        try await db.read { db in
            try String.fetchOne(
                db, sql: "SELECT title FROM container WHERE id = ?", arguments: [postID])
        }
    }

    // MARK: - The offer

    /// **AN OFFER IS NOT AN ACT.** Typing raises the chip; filing without
    /// touching it mints an UNTITLED note, exactly as the bar always did.
    @Test func theBarOffersAndFilesUntitledUnlessSheClicks() async throws {
        try await withCapture { session, db in
            let box = QuickEntryModel(session: session)
            #expect(box.suggestedTitle == nil, "an empty box offers nothing")

            box.text = "Garden plans for the spring, and what to do about the fence."
            #expect(box.suggestedTitle == NoteCardFace.suggestedTitle(forTypedText: box.text),
                    "the chip's words are the one brain's, never a second rule")
            #expect(!box.titleFromFirstWords, "nothing is adopted for her")

            let postID = try #require(await box.submit())
            #expect(try await self.storedTitle(db, postID) == nil,
                    "the note she never named is untitled — her rule, untouched")
        }
    }

    /// **ONE CLICK ADOPTS IT** — through the real operation, no seam: the
    /// stored title is the offered words.
    @Test func oneClickMakesTheFirstWordsTheTitle() async throws {
        try await withCapture { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "Garden plans for the spring.\n\nBeds first, then the fence."
            let offered = try #require(box.suggestedTitle)
            box.titleFromFirstWords.toggle()  // the chip's one click

            let postID = try #require(await box.submit())
            #expect(try await self.storedTitle(db, postID) == offered)
            #expect(offered == "Garden plans for the spring.")

            // The words are still the note's own text as well — adopting a
            // name never moves her prose out of the note.
            let slots = try await db.read { try Queries.renderPost($0, containerID: postID) }
            #expect(slots.compactMap(\.text).first?
                .hasPrefix("Garden plans for the spring.") == true)
        }
    }

    /// The decision travels with the TEXT: it is read from what is filed, it
    /// resets when the box clears, and a refusal keeps both.
    @Test func theDecisionRidesTheTextAndResetsWithIt() async throws {
        try await withCapture { session, _ in
            let box = QuickEntryModel(session: session)
            box.text = "The first capture."
            box.titleFromFirstWords = true

            // A REFUSAL keeps her text and her decision — a second ⏎ must do
            // what the first one was asked to.
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            #expect(await box.submit() == nil)
            #expect(box.text == "The first capture.")
            #expect(box.titleFromFirstWords, "her decision survives a refusal too")

            // A completed hand-off carries the adopted name…
            let seen = LockIsolated<String?>(nil)
            box.mint = { _, title in
                seen.setValue(title)
                return "post-1"
            }
            #expect(await box.submit() == "post-1")
            #expect(seen.value == "The first capture.")
            // …and the next capture starts as a fresh decision.
            #expect(box.text.isEmpty)
            #expect(!box.titleFromFirstWords)
        }
    }

    /// An empty box files nothing and forgets a decision made about words
    /// that are no longer there.
    @Test func anEmptiedBoxForgetsTheDecision() async throws {
        try await withCapture { session, _ in
            let box = QuickEntryModel(session: session)
            box.text = "   \n "
            box.titleFromFirstWords = true
            #expect(await box.submit() == nil)
            #expect(!box.titleFromFirstWords)
        }
    }

    // MARK: - The floating pad, same offer

    /// The quick-note pad makes the same offer and keeps the same default:
    /// untitled unless she clicks.
    @Test func thePadOffersTheSameNameAndFilesUntitledByDefault() async throws {
        try await withCapture { session, db in
            let quiet = QuickNotePad(session: session)
            quiet.text = "A thought I had on the stairs."
            #expect(quiet.suggestedTitle == "A thought I had on the stairs.")
            #expect(!quiet.titleFromFirstWords)
            let untitled = try #require(await quiet.fileExplicitly().postID)
            #expect(try await self.storedTitle(db, untitled) == nil)

            let adopted = QuickNotePad(session: session)
            adopted.text = "Frost on the window, and a fox in the lane."
            adopted.titleFromFirstWords = true
            let named = try #require(await adopted.close().postID)
            #expect(try await self.storedTitle(db, named)
                    == "Frost on the window, and a fox in the lane.")
            #expect(!adopted.titleFromFirstWords, "the pad cleared itself, decision and all")
            #expect(await adopted.close() == .nothingToFile,
                    "one summon, one note — unchanged")
        }
    }

    /// **THE CHIP SHOWS THE NAME SHE WILL GET** — the walk's find: the whole
    /// label went through `chromeLabel`, which lowercases in the Terminal
    /// voice, so the chip read *name it “garden plans…”* over a note that
    /// would be titled *“Garden plans…”*. Only the app's own words are
    /// case-folded now; her prose is drawn verbatim.
    ///
    /// RED ON OLD (behavioural revert, verified): render the label as one
    /// `chromeLabel` string again — i.e. drop `voicedLabel` and let
    /// `VoicedChip` fold the whole thing — and the first expectation fails
    /// under the Terminal voice.
    @Test func theChipDrawsHerWordsVerbatimAndOnlyFoldsItsOwn() {
        let suggestion = "Garden plans for the spring"
        let terminal = VoiceTokens.terminalLight
        #expect(terminal.chromeLabel(suggestion) != suggestion,
                "premise: this voice WOULD fold her words — that was the defect")

        for adopted in [false, true] {
            let segments = TitleSuggestionChip.segments(
                suggestion: suggestion, adopted: adopted)
            let drawn = TitleSuggestionChip.rendered(segments, tokens: terminal)
            #expect(drawn.contains(suggestion),
                    "\(adopted): the chip shows the name she will actually get: \(drawn)")
            // …and the app's own words still speak the voice.
            #expect(segments.filter(\.voiced).allSatisfy {
                drawn.contains(terminal.chromeLabel($0.text))
            })
        }

        let chip = TitleSuggestionChip(
            tokens: terminal, suggestion: suggestion, adopted: false, onToggle: {})
        #expect(chip.label == "\(TitleSuggestionChip.offerLead)\u{201C}\(suggestion)\u{201D}?")
    }

    /// **A NAME IS NOT A TRUNCATION.** A long opening is offered — and
    /// stored — whole to its word edge, without the card lead's ellipsis.
    @Test func aLongOpeningIsOfferedWithoutTheEllipsis() async throws {
        try await withCapture { session, db in
            let box = QuickEntryModel(session: session)
            box.text =
                "The lighthouse keeper counted the storms and wrote none of them down, ever."
            let offered = try #require(box.suggestedTitle)
            #expect(!offered.hasSuffix(NoteCardFace.ellipsis))
            #expect(offered.count <= NoteCardFace.leadCap)
            box.titleFromFirstWords = true
            let postID = try #require(await box.submit())
            #expect(try await self.storedTitle(db, postID) == offered)
        }
    }
}
