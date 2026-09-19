//
//  QuickEntryBarTests.swift
//  VariorumTests
//
//  Phase 13l, ACT 3 / L-b — the quick-entry bar stops destroying her text.
//
//  RED ON THE PRE-FIX TREE: `submit()` wrote `entryText = ""` BEFORE the
//  mint, so `aRefusedMintKeepsHerText` fails at the first expectation (the
//  box is empty), and its refusal was a raw `"New note refused: \(error)"`
//  dump, so `aRefusalSpeaksInWords` fails on the sentence.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The quick-entry bar keeps her text (13l L-b)")
struct QuickEntryBarTests {
    private func withBox<T>(
        _ body: @MainActor (QuickEntryModel, AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            return try await body(QuickEntryModel(session: session), session, db)
        }
    }

    /// **THE DEFECT.** A refused mint used to leave her with an empty box
    /// and a raw enum dump — her words gone, in the bar she uses daily,
    /// because the box was cleared before the store was ever asked.
    @Test func aRefusedMintKeepsHerText() async throws {
        try await withBox { box, _, _ in
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            box.text = "the paragraph she just wrote"

            let opened = await box.submit()

            #expect(opened == nil)
            #expect(box.text == "the paragraph she just wrote",
                    "her text lives nowhere else — the box keeps it")
            #expect(box.lastError != nil)
        }
    }

    @Test func aRefusalSpeaksInWords() async throws {
        try await withBox { box, _, _ in
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            box.text = "hello"
            await box.submit()

            let message = try #require(box.lastError)
            #expect(message == QuickEntryCopy.refusal(for: OperationError.lockedPost(id: "c1")))
            #expect(message.contains("Your text is still here"),
                    "the reassurance is the load-bearing half — it is TRUE now")
            #expect(!message.contains("lockedPost"), "never a raw enum dump")
            #expect(!message.contains("New note refused"))
        }
    }

    /// A store-level failure is not an operations refusal, and must still
    /// not print its `description`.
    @Test func aStoreFailureIsNamedRatherThanDumped() async throws {
        struct Cutoff: Error { let detail = "NSCocoaErrorDomain 257" }
        try await withBox { box, _, _ in
            box.mint = { _, _ in throw Cutoff() }
            box.text = "hello"
            await box.submit()

            let message = try #require(box.lastError)
            #expect(!message.contains("Cutoff"))
            #expect(!message.contains("257"))
            #expect(message.contains("Your text is still here"))
            #expect(box.text == "hello")
        }
    }

    /// The other half — a completed hand-off clears, and hands back the note
    /// the bar then opens. Through the REAL operation, no seam.
    @Test func aMintedNoteClearsTheBoxAndIsHandedBack() async throws {
        try await withBox { box, _, db in
            box.text = "First paragraph.\n\nSecond paragraph."
            let minted = await box.submit()
            let opened = try #require(minted)

            #expect(box.text.isEmpty)
            #expect(box.lastError == nil)
            let slots = try await db.read { try Queries.renderPost($0, containerID: opened) }
            // Trimmed, deliberately: what this pin is about is that the REAL
            // `importPost` ran and segmented — not the exact trailing
            // whitespace its boundary rule leaves, which is its own subject.
            #expect(slots.compactMap(\.text).map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            } == ["First paragraph.", "Second paragraph."])
        }
    }

    /// Keystrokes that land DURING the mint are not in the note that was
    /// minted, so clearing them wholesale would lose them. They stay.
    @Test func typingDuringTheMintIsNotSweptAwayByItsSuccess() async throws {
        try await withBox { box, _, _ in
            // Staged from INSIDE the mint, which is the only place the
            // window really is: `submitted` has been read, the note does not
            // hold these keystrokes, and the clear is still ahead.
            box.mint = { _, _ in
                box.text = "first and then some more"
                return "post-1"
            }
            box.text = "first"
            let opened = await box.submit()

            #expect(opened == "post-1")
            #expect(box.text == "first and then some more",
                    "the mint read 'first'; what she typed after it is not in that note")
        }
    }

    /// An empty (or whitespace-only) box files nothing, keeps nothing, and
    /// drops a stale error with it.
    @Test func anEmptyBoxFilesNothingAndClearsItsStaleError() async throws {
        try await withBox { box, _, _ in
            box.mint = { _, _ in throw OperationError.lockedPost(id: "c1") }
            box.text = "hello"
            await box.submit()
            #expect(box.lastError != nil)

            box.text = "   \n  "
            let opened = await box.submit()

            #expect(opened == nil)
            #expect(box.text.isEmpty)
            #expect(box.lastError == nil)
        }
    }
}
