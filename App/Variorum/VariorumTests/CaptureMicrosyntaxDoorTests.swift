//
//  CaptureMicrosyntaxDoorTests.swift
//  VariorumTests
//
//  13u4 UNIT C1 — the microsyntax AT THE TWO MAC CAPTURE DOORS (the shelf's
//  quick-entry bar and the floating quick-note pad), driven end to end
//  through the REAL `importPost` and the REAL tag operations, against a real
//  in-memory store. The parse's own arms are `CaptureMicrosyntaxTests`; what
//  is here is the three things only the doors can answer:
//
//  1. the note really lands TITLED and TAGGED with the tokens gone;
//  2. a smart book keyed on that tag really collects it — by the STANDING
//     tag rules and nothing else (her R-13u4-1: *"if there's a smart book
//     based on that tag, it would go in that smart book based on standard
//     tag rules"*). There is no routing machinery anywhere in this unit, and
//     this pin is what says so in behaviour rather than in prose;
//  3. FILING NEVER BLOCKS ON A TOKEN — a tag that cannot land leaves the
//     note filed and speaks a refusal.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The capture microsyntax at both Mac doors (13u4 C1)")
struct CaptureMicrosyntaxDoorTests {
    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func facts(
        _ db: AppDatabase, _ postID: String
    ) async throws -> (title: String?, tags: [String], text: [String]) {
        try await db.read { db in
            (try Queries.containerHeader(db, containerID: postID)?.title,
             try Queries.postTags(db, postID: postID).map(\.path),
             try Queries.renderPost(db, containerID: postID).compactMap(\.text).map {
                 $0.trimmingCharacters(in: .whitespacesAndNewlines)
             })
        }
    }

    // MARK: - The shelf's quick-entry bar

    /// Her own example at the door she types in every day.
    @Test func theShelfBoxFilesATitledTaggedNoteWithTheTokensGone() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "{t:\"Ocean dream\"} Had a weird dream about the ocean {#dream}"

            let noteID = try #require(await box.submit())
            let (title, tags, text) = try await facts(db, noteID)

            #expect(title == "Ocean dream")
            #expect(tags == ["dream"])
            #expect(text == ["Had a weird dream about the ocean"])
            #expect(box.text.isEmpty, "a completed hand-off clears the box")
            #expect(box.lastError == nil)
        }
    }

    /// **HER RULING'S WHOLE PROMISE, in behaviour**: no routing machinery —
    /// the tag applied, and the smart book that collects that tag has the
    /// note because that is what smart books do.
    @Test func aSmartBookKeyedOnTheTagCollectsTheNoteByTheStandingRules() async throws {
        try await withWorld { session, db in
            // The book exists FIRST and knows nothing about captures.
            _ = try session.operations.createTag(name: "dream")
            let spec = try Queries.SmartQuerySpec(tags: ["dream"]).encodedJSON()
            let book = try session.operations.createReading(
                name: "Dream journal", kind: .smart, querySpec: spec)

            let box = QuickEntryModel(session: session)
            box.text = "Had a weird dream about the ocean {#dream}"
            let noteID = try #require(await box.submit())

            let (collected, books, curated) = try await db.read { db in
                (try Queries.assembleReading(db, readingID: book.id).map(\.postID),
                 try Queries.readingsContaining(db, postID: noteID).map(\.name),
                 try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ?",
                    arguments: [noteID]))
            }
            #expect(collected == [noteID], "the smart book has it")
            #expect(books.contains("Dream journal"))
            #expect(curated == 0, "collected by a predicate — NO membership row was written")
        }
    }

    /// A tag the taxonomy has never seen is created on the way, hierarchy
    /// and all — the hoisted typed-path brain's own rule, reached through a
    /// token.
    @Test func aTokenMayNameATagThatDoesNotExistYet() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "leg day {#health/workout}"
            let noteID = try #require(await box.submit())

            let (_, tags, _) = try await facts(db, noteID)
            #expect(tags == ["health/workout"], "the LEAF is applied")
            let all = try await db.read { try Queries.allTags($0).map(\.path) }
            #expect(all == ["health", "health/workout"], "every missing level created, parents first")
        }
    }

    @Test func severalTokensAllApply() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "{#dream} the ocean again {#sea}"
            let noteID = try #require(await box.submit())

            let (_, tags, text) = try await facts(db, noteID)
            #expect(tags.sorted() == ["dream", "sea"])
            #expect(text == ["the ocean again"])
        }
    }

    /// The other half of "only the braced forms parse", at the door: a bare
    /// hashtag files as the words she typed and tags nothing.
    @Test func aBareHashtagFilesAsTextAndTagsNothing() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "#dream about the ocean"
            let noteID = try #require(await box.submit())

            let (_, tags, text) = try await facts(db, noteID)
            #expect(tags.isEmpty)
            #expect(text == ["#dream about the ocean"])
            #expect(try await db.read { try Queries.allTags($0) }.isEmpty,
                    "nothing in the taxonomy was invented")
        }
    }

    /// A malformed brace is TEXT — it files, visibly, exactly as typed.
    @Test func aMalformedBraceFilesAsTypedText() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "a thought {#unclosed and more"
            let noteID = try #require(await box.submit())

            let (_, tags, text) = try await facts(db, noteID)
            #expect(tags.isEmpty)
            #expect(text == ["a thought {#unclosed and more"])
        }
    }

    // MARK: - Filing never blocks on a token

    /// A token that parses but names NO tag (`{#///}`) leaves the note filed
    /// and speaks a refusal — the whole posture of this unit in one pin.
    @Test func aTokenThatCannotApplyNeverCostsHerTheNote() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "a thought worth keeping {#///}"

            let noteID = try #require(await box.submit())
            let (_, tags, text) = try await facts(db, noteID)

            #expect(text == ["a thought worth keeping"], "THE NOTE IS SAFE")
            #expect(tags.isEmpty)
            let spoken = try #require(session.status.current)
            #expect(spoken.kind == .refusal, "a door that did nothing speaks a refusal (18i)")
            #expect(spoken.text.contains("///"), "it names the token that didn't land")
            #expect(spoken.text.contains("The note was filed"))
            #expect(spoken.text == CaptureMicrosyntax.tagRefusal(
                path: "///", reason: TypedTagPath.emptyMessage))
        }
    }

    /// A capture of NOTHING BUT TOKENS has no note for a tag to go on, so
    /// the door takes its standing empty branch (PROVISIONAL #127(f)).
    @Test func aCaptureOfNothingButTokensFilesNothing() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "{t:\"Title\"} {#dream}"

            #expect(await box.submit() == nil)
            #expect(box.text.isEmpty)
            #expect(box.lastError == nil)
            let notes = try await db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") ?? -1
            }
            #expect(notes == 0, "nothing was minted")
            #expect(try await db.read { try Queries.allTags($0) }.isEmpty)
        }
    }

    // MARK: - The title's two sources

    /// A `{t:"…"}` outranks the first-words chip when both are in play, and
    /// the chip — when it is the only one — reads the CLEANED text, so a
    /// token can never end up inside the stored name (#127(e)).
    @Test func aTitleTokenOutranksTheOfferedFirstWords() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.titleFromFirstWords = true
            box.text = "{t:\"Ocean dream\"} Had a weird dream"
            let withToken = try #require(await box.submit())
            #expect(try await facts(db, withToken).title == "Ocean dream")

            let second = QuickEntryModel(session: session)
            second.titleFromFirstWords = true
            second.text = "{#dream} Had a weird dream about the ocean"
            let withChip = try #require(await second.submit())
            let (title, tags, _) = try await facts(db, withChip)
            #expect(title == "Had a weird dream about the ocean")
            #expect(title?.contains("{#") == false, "the token is never in the name")
            #expect(tags == ["dream"])
        }
    }

    // MARK: - The quick-note pad (the same rule, the other door)

    @Test func thePadFilesATitledTaggedNoteWithTheTokensGone() async throws {
        try await withWorld { session, db in
            let pad = QuickNotePad(session: session)
            pad.text = "{t:\"Leg day\"} squats and a long walk {#health/workout}"

            let outcome = await pad.fileExplicitly()
            let noteID = try #require(outcome.postID)
            let (title, tags, text) = try await facts(db, noteID)

            #expect(title == "Leg day")
            #expect(tags.sorted() == ["health/workout", "quicknote"],
                    "her token rides BESIDE the pad's standing quicknote filing")
            #expect(text == ["squats and a long walk"])
            #expect(pad.text.isEmpty)
            #expect(pad.lastError == nil)
        }
    }

    @Test func thePadsCaptureOfNothingButTokensFilesNothing() async throws {
        try await withWorld { session, db in
            let pad = QuickNotePad(session: session)
            pad.text = "{#dream}"

            #expect(await pad.fileExplicitly() == .nothingToFile)
            let notes = try await db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container") ?? -1
            }
            #expect(notes == 0)
        }
    }

    /// The pad's own refusal road is untouched by the parse: a refused mint
    /// still keeps her words — TOKENS AND ALL, because nothing left the box.
    @Test func aRefusedPadKeepsTheWholeCaptureTokensIncluded() async throws {
        try await withWorld { session, _ in
            let pad = QuickNotePad(session: session)
            pad.mint = { _, _ in .refused("nope") }
            pad.text = "a thought {#dream}"

            #expect(await pad.fileExplicitly() == .refused("nope"))
            #expect(pad.text == "a thought {#dream}",
                    "her capture is byte-intact — the parse never touched the box")
            #expect(pad.lastError == "nope")
        }
    }

    /// And the mint is handed the CLEANED text and the token's title — the
    /// seam reads what the store was actually asked for.
    @Test func theMintIsAskedForTheCleanedTextAndTheTokensTitle() async throws {
        try await withWorld { session, _ in
            let box = QuickEntryModel(session: session)
            var asked: (String, String?)?
            box.mint = { text, title in
                asked = (text, title)
                return "post-1"
            }
            box.text = "{t:\"Ocean dream\"} Had a weird dream {#dream}"
            _ = await box.submit()

            let seen = try #require(asked)
            #expect(seen.0 == "Had a weird dream")
            #expect(seen.1 == "Ocean dream")
        }
    }
}
