//
//  VariorumMobileTests.swift
//  VariorumMobileTests
//
//  Phase 8, Steps 3–4 — the capture surface's view-model tests: exact row
//  sets for entry creation (state-transition style over an in-memory
//  store), edit-then-flush landing on the right variant, the sealed-target
//  refusal posture (surface + keep-pending), the bounded live listing, and
//  the pure edit-cost function.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

/// Deterministic RNG for fractional-index jitter (mirrors the core tests'
/// SeededGenerator — SplitMix64).
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// A fresh in-memory world with deterministic dependencies and a real
/// AppSession — the mobile twin of the Mac suite's editor harness.
@MainActor
private func withMobileWorld<T>(
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

/// An editor model with the autosave debounce clock disabled — tests flush
/// explicitly, deterministically.
@MainActor
private func makeEditorModel(_ session: AppSession, postID: String) -> EntryEditorViewModel {
    EntryEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
}

// MARK: - Step 3: create + edit

@MainActor
@Suite("Capture editor (Phase 8, Step 3)")
struct CaptureEditorTests {
    @Test func theFirstKeystrokeMintsExactlyTheEntryRowSet() async throws {
        try await withMobileWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            }
            // Before typing: the entry is one container row, blockless.
            #expect(try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM block") } == 0)

            let model = makeEditorModel(session, postID: entry.container.id)
            await model.loadOnce()
            model.setDraft("First words of the day.")
            await model.waitForMint()

            // Exactly the newBlock row set: block + variant + placement.
            let counts = try await db.read { db in
                (blocks: try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block") ?? -1,
                 variants: try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant") ?? -1,
                 placements: try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container_block") ?? -1,
                 containers: try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1)
            }
            #expect(counts == (1, 1, 1, 1))
            let row = try await db.read { db in
                try Row.fetchOne(db, sql: """
                    SELECT v.working_text AS text, cb.container_id AS container,
                           cb.chosen_variant_id AS chosen, v.id AS variant,
                           b.default_variant_id AS fallback
                    FROM variant v
                    JOIN block b ON b.id = v.block_id
                    JOIN container_block cb ON cb.block_id = v.block_id
                    """)
            }
            #expect(row?["text"] == "First words of the day.")
            #expect(row?["container"] == entry.container.id)
            #expect((row?["chosen"] as String?) == (row?["variant"] as String?))
            #expect((row?["fallback"] as String?) == (row?["variant"] as String?))
            // A second keystroke burst must NOT mint again.
            model.setDraft("First words of the day. More.")
            await model.waitForMint()
            #expect(try await db.read { try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM block") } == 1)
        }
    }

    @Test func editThenFlushLandsTheBufferOnTheRightVariant() async throws {
        try await withMobileWorld { session, db in
            // A two-block post (a graduated entry): editing block 2 must
            // never touch block 1's variant.
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "graduated", profile: .journal, entryDate: "2026-07-06")
            }
            let first = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "First block.", at: .end)
            }
            let second = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Second block.", at: .end)
            }

            let model = makeEditorModel(session, postID: post.id)
            await model.loadOnce()
            let secondSlot = try #require(model.slots.first { $0.variantID == second.variant.id })
            model.focus(secondSlot)
            model.setDraft("Second block, edited on the phone.")
            await model.autosave.flushNow()

            let texts = try await db.read { db in
                (first: try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [first.variant.id]),
                 second: try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [second.variant.id]))
            }
            #expect(texts.second == "Second block, edited on the phone.")
            #expect(texts.first == "First block.", "the sibling variant is untouched")
            // The churn/touch pipeline ran (AppSpec §10).
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT last_touched_at FROM container WHERE id = ?",
                    arguments: [post.id])
            } != nil)
        }
    }

    @Test func aFannedBlockEditsExactlyTheRenderedVariant() async throws {
        try await withMobileWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "fanned", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "The original take.", at: .end)
            }
            let branch = try await session.runner.run { ops in
                try ops.branchVariant(minted.block.id, from: minted.variant.id)
            }
            try await session.runner.run { ops in
                try ops.chooseVariant(minted.block.id, variantID: branch.id)
            }

            let model = makeEditorModel(session, postID: post.id)
            await model.loadOnce()
            // The fan is invisible; the slot shows the CHOSEN take.
            let slot = try #require(model.slots.first)
            #expect(slot.variantID == branch.id)
            model.focus(slot)
            model.setDraft("The chosen take, edited.")
            await model.autosave.flushNow()

            let texts = try await db.read { db in
                (original: try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id]),
                 chosen: try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [branch.id]))
            }
            #expect(texts.chosen == "The chosen take, edited.")
            #expect(texts.original == "The original take.",
                    "the other take keeps its own text — the fan is untouched")
        }
    }

    @Test func aSealedTargetSurfacesTheRefusalAndKeepsTheBuffer() async throws {
        try await withMobileWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "sealable", profile: .journal, entryDate: "2026-07-05")
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Before the seal.", at: .end)
            }

            let model = makeEditorModel(session, postID: post.id)
            await model.loadOnce()
            model.focus(try #require(model.slots.first))
            model.setDraft("Typed before the seal landed.")

            // The seal lands REMOTELY mid-typing (another device, mid-sync).
            try await session.runner.run { ops in try ops.lockPost(post.id) }
            await model.autosave.flushNow()

            // The refusal is surfaced, the typed text survives in pending
            // (the shared coordinator's keep-pending posture), and the
            // surface keeps showing the buffer.
            #expect(model.lastError != nil)
            #expect(model.autosave.isDirty, "the refused entry re-enters pending")
            #expect(model.draftText == "Typed before the seal landed.")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            } == "Before the seal.", "nothing lands under the seal")

            // A LOCALLY-known seal refuses at the surface: no autosave even
            // attempted, message shown.
            await model.loadOnce()  // header now shows locked … but the buffer is dirty
        }
    }

    @Test func aSealedPostRefusesFocusAndTyping() async throws {
        try await withMobileWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "sealed", profile: .journal, entryDate: "2026-07-04")
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Sealed text.", at: .end)
            }
            try await session.runner.run { ops in try ops.lockPost(post.id) }

            let model = makeEditorModel(session, postID: post.id)
            await model.loadOnce()
            #expect(model.isSealed)
            #expect(model.focusedVariantID == nil, "a sealed post never auto-focuses")
            model.focus(try #require(model.slots.first))
            #expect(model.focusedVariantID == nil)
            #expect(model.lastError != nil, "the refusal is surfaced, not silent")
        }
    }

    @Test func editCostCountsInsertsAndDeletesInUTF16() {
        #expect(EditCost.utf16Cost(from: "abc", to: "abxc") == 1)          // insert
        #expect(EditCost.utf16Cost(from: "abxc", to: "abc") == 1)          // delete
        #expect(EditCost.utf16Cost(from: "hello", to: "help!") == 4)       // prefix "hel": 2 deleted + 2 inserted
        #expect(EditCost.utf16Cost(from: "same", to: "same") == 0)
        #expect(EditCost.utf16Cost(from: "", to: "typed") == 5)
        // Emoji (surrogate pairs count as 2 UTF-16 units).
        #expect(EditCost.utf16Cost(from: "a", to: "a😀") == 2)
    }
}

// MARK: - Step 4: the bounded live listing

@MainActor
@Suite("Entry list (Phase 8, Step 4)")
struct EntryListTests {
    @Test func observationDeliversOnEntryCreationAndEdit() async throws {
        try await withMobileWorld { session, _ in
            let model = EntryListViewModel(
                session: session,
                now: { Date(timeIntervalSince1970: 1_783_400_000) },  // 2026-07-07 UTC
                calendar: {
                    var utc = Calendar(identifier: .gregorian)
                    utc.timeZone = TimeZone(identifier: "UTC")!
                    return utc
                }())
            let observation = Task { await model.startJournal() }
            defer { observation.cancel() }

            let todayID = await model.openToday()
            #expect(todayID != nil)
            // The live listing delivers the new entry (bounded wait).
            for _ in 0..<2000 where model.journalEntries.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.journalEntries.map(\.postID) == [todayID])
            #expect(model.journalEntries.first?.entryDate == "2026-07-07")

            // Today again OPENS (the notebook rule) — no second row.
            let again = await model.openToday()
            #expect(again == todayID)
            #expect(model.journalEntries.count == 1)
        }
    }

    @Test func theListingStaysBounded() async throws {
        try await withMobileWorld { session, _ in
            for day in 10...19 {
                _ = try await session.runner.run { ops in
                    try ops.createOrOpenJournalEntry(entryDate: "2026-06-\(day)")
                }
            }
            let model = EntryListViewModel(session: session, listingLimit: 5)
            let observation = Task { await model.startJournal() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.journalEntries.count < 5 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.journalEntries.count == 5, "a held observation is viewport-shaped (P1)")
            #expect(model.journalEntries.first?.entryDate == "2026-06-19", "newest day first")
        }
    }
}

// MARK: - Review round 1 (MAJOR): stale projections must never reset the
// edit base, lose flushed text, or double-mint

@MainActor
@Suite("Stale projection races (Phase 8, review round 1)")
struct StaleProjectionTests {
    /// THE TEXT-LOSS PIN: an observation value is a photograph of a PAST
    /// commit; delivered at a clean instant after a newer flush, adopting
    /// it resets `draftText` + the edit base to stale text and the next
    /// keystroke overwrites the flushed text in the store — the forbidden
    /// class. The model must treat deliveries as signals only and adopt
    /// exclusively from generation-checked fresh reads.
    @Test func aStaleDeliveryAfterAFlushNeverResetsTheDraftOrLosesText() async throws {
        try await withMobileWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "raced", profile: .journal, entryDate: "2026-07-07")
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base text.", at: .end)
            }
            let model = makeEditorModel(session, postID: post.id)
            await model.loadOnce()
            #expect(model.focusedVariantID == minted.variant.id)

            // The stale photograph: fetched BEFORE the edit below — exactly
            // what GRDB can deliver late, after the flush has settled.
            let staleSlots = model.slots

            model.setDraft("Base text. Typed and flushed.")
            await model.autosave.flushNow()
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            } == "Base text. Typed and flushed.")

            // The stale delivery lands at a CLEAN instant (post-settle).
            model.projectionDelivered(staleSlots)
            await model.settleProjection()

            // The surface keeps the flushed text (pre-fix: reset to stale)…
            #expect(model.draftText == "Base text. Typed and flushed.",
                    "a stale delivery must never reset the draft")

            // …so the next keystroke builds on what the user sees, and
            // nothing typed is ever lost (pre-fix: the store loses
            // ' Typed and flushed.').
            model.setDraft(model.draftText + " More.")
            await model.autosave.flushNow()
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            } == "Base text. Typed and flushed. More.")
        }
    }

    /// THE DOUBLE-MINT PIN: a stale EMPTY delivery landing after the first
    /// block minted would drop focus and empty `slots`; the next keystroke
    /// would take the `slots.isEmpty` branch and mint a SECOND "first"
    /// block.
    @Test func aStaleEmptyDeliveryAfterTheMintNeverDoubleMints() async throws {
        try await withMobileWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            }
            let model = makeEditorModel(session, postID: entry.container.id)
            await model.loadOnce()
            let staleEmpty = model.slots
            #expect(staleEmpty.isEmpty, "precondition: the pre-mint photograph is blockless")

            model.setDraft("First words.")
            await model.waitForMint()
            await model.settleProjection()
            #expect(model.focusedVariantID != nil)

            // The pre-mint photograph arrives late, at a clean instant.
            model.projectionDelivered(staleEmpty)
            await model.settleProjection()

            // Typing continues: exactly ONE block, ever.
            model.setDraft("First words. And more.")
            await model.waitForMint()
            await model.autosave.flushNow()
            #expect(try await db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM block") ?? -1
            } == 1, "a stale empty delivery must never cause a second first-block mint")
            #expect(try await db.read {
                try String.fetchOne($0, sql: "SELECT working_text FROM variant") ?? ""
            } == "First words. And more.")
        }
    }
}
