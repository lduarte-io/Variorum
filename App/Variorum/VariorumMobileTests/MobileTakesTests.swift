//
//  MobileTakesTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 2, batch 1 — the swipe-peek's brain (`MobileTakesController`
//  + the VM's thin routing), headless over the bare-storage seam. The
//  binding cores under test: a flip PEEKS with ZERO store writes (variant
//  rows, chosen pointer, AND the outbox all untouched — pinned); the peek
//  is sticky across deliveries; ✓ is the ONLY choosing act and its
//  refusals speak; typing into a peeked block edits the PEEKED take's
//  `working_text` (R8/R23 — route autosave to the displayed variant); the
//  identity audit stays clean throughout.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

/// A post with a FANNED first block (chosen a1 + take a2) and a fanless
/// second block — the batch's standing fixture.
@MainActor
private func seedFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String, blockB: String, b1: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "takes", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        return (post.id, a.block.id, a.variant.id, take.id, b.block.id, b.variant.id)
    }
}

@MainActor
private func chosenVariantID(_ db: AppDatabase, blockID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: """
                SELECT chosen_variant_id FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """,
            arguments: [blockID])
    }
}

@MainActor
private func outboxCount(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
    }
}

/// One fresh coherent read, applied with fresh-read authority. (Since the
/// S3 ladder's MAJOR 3, an observation DELIVERY is a signal that settles
/// by exactly this fresh application — driving the fresh half directly
/// keeps these pins deterministic; the delivery arm has its own pin in
/// `MobileEditorTests`.)
@MainActor
private func deliver(_ model: MobileEditorViewModel, _ db: AppDatabase) async throws {
    let fresh = try await db.read { [postID = model.postID] in
        try Queries.takesProjection($0, post: postID)
    }
    model.ingest(fresh)
}

// MARK: - The suite

@MainActor
@Suite("Mobile takes — the swipe-peek brain (S2 batch 1)")
struct MobileTakesTests {
    // MARK: The peek's zero-write core (M6)

    @Test func flipPeeksInPlaceWithZeroStoreWrites() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")

            let outboxBefore = try await outboxCount(db)
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The DISPLAY moved to the take, in place…
            #expect(storage.string == "First block, the other way.\nSecond block, fanless.")
            #expect(model.takes.isPeeking(seed.blockA))
            // …and the STORE moved nowhere: texts, chosen pointer, outbox.
            #expect(try await storedBlockTexts(db, postID: seed.postID)
                    == ["First block, as chosen.", "Second block, fanless."])
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(try await outboxCount(db) == outboxBefore)
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.statusMessage == nil)
        }
    }

    @Test func flipWrapsAndLandingOnTheChosenTakeEndsThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            // The two-take carousel wraps back onto the CHOSEN take —
            // displaying truth is not a peek (M6's unambiguity rule).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")
            #expect(model.takes.originals[seed.blockA] == nil)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func flipDoesNothingOnFanlessOrUnknownBlocks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let before = storage.string

            model.takes.flip(blockID: seed.blockB, forward: true)
            model.takes.flip(blockID: "no-such-block", forward: true)
            #expect(storage.string == before)
            #expect(model.takes.peeks.isEmpty)
        }
    }

    // MARK: Editing the peeked take (the brief's item 4)

    @Test func typingIntoAPeekedBlockEditsThePeekedTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // Type at the peeked text's end (inside block A's range).
            let insertAt = ("First block, the other way." as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: insertAt, length: 0),
                replacement: " More."))
            await model.autosave.flushNow()

            // The PEEKED take took the edit; the chosen take and the
            // pointer are untouched (never silently the chosen one).
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way. More.")
            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(model.identityAuditFailures == 0)
            #expect(model.statusMessage == nil)
        }
    }

    @Test func anEditedPeekSurvivesFlippingAwayAndBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            let insertAt = ("First block, the other way." as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: insertAt, length: 0),
                replacement: " Edited."))

            // Away (onto chosen) and back — BEFORE any flush lands: the
            // ledger-first resolution must show the edited bytes, never
            // the fan cache's stale photograph.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, as chosen."))
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way. Edited."))

            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way. Edited.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func anEditedChosenTakeSurvivesFlippingAwayAndBack() async throws {
        // The S2 ladder round-1 BLOCKER's pin: the CHOSEN direction is
        // ledger-first exactly like the peeked one. Type into the chosen
        // take with the debounce held open (the injected sleep never
        // fires), flip away and back — the surface AND the ledger hold
        // the edited bytes (the old code restored the stale slot
        // photograph and overwrote the ledger with it), and the flush
        // lands them in the store.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let edited = "First block, as chosen. Typed."
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: ("First block, as chosen." as NSString).length,
                               length: 0),
                replacement: " Typed."))
            #expect(model.autosave.isDirty)

            // Away (onto the take) and back (onto chosen) — inside the
            // debounce window, before any flush lands.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way."))
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The surface and the surface's own truth record both hold
            // the edited bytes — never the stale photograph.
            #expect(storage.string.hasPrefix(edited))
            #expect(model.surfaceKnownText(variantID: seed.a1) == edited)

            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: seed.a1) == edited)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func typingAfterAFlipRoundTripNeverLosesTheEarlierEdit() async throws {
        // The BLOCKER's arm (b) — the permanent-loss shape: on the old
        // code, typing onto the reverted base replaced the pending
        // autosave entry with stale-based text and the earlier keystrokes
        // vanished from `working_text` with no commit anywhere. Both
        // edits must reach the store.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            #expect(typeEdit(
                model, storage,
                range: NSRange(location: ("First block, as chosen." as NSString).length,
                               length: 0),
                replacement: " Typed."))
            model.takes.flip(blockID: seed.blockA, forward: true)
            model.takes.flip(blockID: seed.blockA, forward: true)

            // Type again at block A's CURRENT end (wherever the round
            // trip left it), then flush: the store holds BOTH edits.
            let rangeA = try #require(model.rangeOfBlock(seed.blockA))
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: rangeA.location + rangeA.length, length: 0),
                replacement: " More."))
            await model.autosave.flushNow()

            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen. Typed. More.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: Stickiness (M9)

    @Test func thePeekIsStickyAcrossDeliveries() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            let rendersBefore = model.fullRenderCount

            // An unrelated edit lands elsewhere (the fanless block), then a
            // fresh delivery arrives — the peek holds.
            let bStart = ("First block, the other way.\n" as NSString).length
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: bStart, length: 0),
                replacement: "Now edited: "))
            await model.autosave.flushNow()
            try await deliver(model, db)

            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string
                    == "First block, the other way.\nNow edited: Second block, fanless.")
            #expect(model.fullRenderCount == rendersBefore, "deliveries echo, never rebuild")
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: ✓ — the one choosing act (M6)

    @Test func chooseCommitsThePeekThroughOperations() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            await model.takes.chooseDisplayed(blockID: seed.blockA)

            // The store's pointer moved (the Mac would follow); the peek
            // ended — the display IS the truth now.
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a2)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.statusMessage == nil)

            // The delivery confirms as an echo.
            let rendersBefore = model.fullRenderCount
            try await deliver(model, db)
            #expect(model.fullRenderCount == rendersBefore)
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func chooseUnderASealedNoteRefusesAndSpeaksWhileThePeekStays() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }

            await model.takes.chooseDisplayed(blockID: seed.blockA)

            #expect(model.statusMessage
                    == "This note is locked — unlock it to choose a take.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            // The PEEK is reading, not authoring — it survives the refusal.
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
        }
    }

    @Test func aSuccessfulChooseClearsThePriorRefusal() async throws {
        // The S2 ladder round-1 NIT-1 pin: the pill's ✓ adopts the
        // clearing posture the browser verbs already have. A sealed
        // refusal spoke; she unseals on the Mac; the delivery lands; the
        // ✓ succeeds — the stale locked-note copy must clear (the old
        // door left it showing).
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            try await session.runner.run { ops in try ops.lockPost(seed.postID) }
            await model.takes.chooseDisplayed(blockID: seed.blockA)
            #expect(model.statusMessage
                    == "This note is locked — unlock it to choose a take.")

            try await session.runner.run { ops in try ops.unlockPost(seed.postID) }
            await model.takes.chooseDisplayed(blockID: seed.blockA)

            #expect(model.statusMessage == nil, "success clears the prior refusal")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a2)
        }
    }

    @Test func peekingASealedNoteIsAllowedButEditingItRefuses() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }
            let header = try await db.read { [postID = model.postID] in
                try Queries.containerHeader($0, containerID: postID)
            }
            model.adoptHeader(header)

            // The flip is display-only — free under the seal (the seal
            // freezes AUTHORING; a peek is reading).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))

            // Typing into the peeked take refuses at the standing gate.
            #expect(!typeEdit(
                model, storage,
                range: NSRange(location: 0, length: 0),
                replacement: "x"))
            #expect(model.statusMessage
                    == "This note is locked — unlock it to edit.")
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way.")
        }
    }

    @Test func aLockedPeekedTakeRefusesEdits() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            try await deliver(model, db)

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way."))

            #expect(!typeEdit(
                model, storage,
                range: NSRange(location: 0, length: 0),
                replacement: "x"))
            // Parity C4a: the redirect dissolved WITH the phone's own
            // unlock door — the copy names the takes sheet's road.
            #expect(model.statusMessage
                    == "This take is locked — branch it, or unlock it from its card in the takes sheet (⑂).")
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way.")
        }
    }

    // MARK: Pruning & fulfillment

    @Test func archivingThePeekedTakeElsewherePrunesThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The Mac archives the very take being peeked; the delivery
            // prunes the peek and the surface heals to chosen.
            try await session.runner.run { ops in try ops.archiveVariant(seed.a2) }
            try await deliver(model, db)

            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string == "First block, as chosen.\nSecond block, fanless.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aRemoteChooseOfThePeekedTakeFulfillsThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)

            // The Mac chooses the same take she is peeking: the store
            // caught up — the peek is FULFILLED, the marker ends, the
            // display doesn't move.
            try await session.runner.run { ops in
                try ops.chooseVariant(seed.blockA, variantID: seed.a2)
            }
            try await deliver(model, db)

            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.identityAuditFailures == 0)
        }
    }

    // MARK: The pill's content brain (LK6)

    @Test func pillContentReportsPositionLabelAndChoosability() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            try await session.runner.run { ops in
                try ops.setTakeLabel(seed.a2, label: "the other way")
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Displaying the chosen truth: counts show, ✓ cannot act (P-2
            // renders the "✓ chosen" state instead).
            #expect(model.takes.pillContent(blockID: seed.blockA)
                    == .init(text: "take 1/2", canChoose: false))
            // Peeking: position + the take's label + a real ✓.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.takes.pillContent(blockID: seed.blockA)
                    == .init(text: "take 2/2 · the other way", canChoose: true))
            // Fanless blocks have no pill at all.
            #expect(model.takes.pillContent(blockID: seed.blockB) == nil)
        }
    }

    // MARK: B45-2 — the `displaySlot` / `slots[i]` coupling (4.5c-phone item 1)

    /// **THE CRYSTALLIZATION WINDOW IS REAL, AND IT IS THE WHOLE FINDING.**
    ///
    /// `finishMint` calls `index.crystallize(…)` and never assigns `slots`,
    /// so from the mint until the next projection `index.entries` genuinely
    /// outruns `slots`. This pins that state as a fact of the shipped code
    /// rather than a claim in a record — everything below rests on it.
    ///
    /// BOUNDARY CHARACTERIZATION: green on both trees (nothing this item
    /// changed touches the divergence; the fix changes what `displaySlot`
    /// does WITH it).
    @Test func aCrystallizedBlockIsInTheIndexBeforeItIsInTheSlots() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.slots.count == 2 && model.index.entries.count == 2)

            let minted = try await mintATailBlock(model, storage)

            #expect(model.index.entries.count == 3, "the index gained the minted block")
            #expect(model.slots.count == 2, "`slots` did NOT — this is the window")
            #expect(model.index.entries.last?.blockID == minted,
                    "and crystallize APPENDS, so the divergence is a length, not an order")
            #expect(model.slot(for: minted) == nil,
                    "which is exactly why every shipped caller bails first")
            _ = db
        }
    }

    /// **THE SHAPE A REORDER-TAKES DOOR PRODUCES — and it must not trap.**
    ///
    /// B45-2. `displaySlot` finds its entry in `index.entries` and then wrote
    /// `slots[i]`, two different arrays. Inside the window above, a block
    /// minted moments ago has a valid `entries` index that is OUT OF RANGE in
    /// `slots`. Nothing reaches that today only because both takes-controller
    /// doors guard on `slot(for:)` first — a caller-side accident, and batch
    /// 7's PR8 reorder-takes is scheduled straight into this room (the
    /// stability survey: *"a takes door on a fresh mint makes `slots[i]` an
    /// out-of-range trap"*).
    ///
    /// So this drives what such a door drives: `displaySlot` for a block the
    /// projection has not echoed back yet. **It is deliberately a call on the
    /// model's own door rather than through `flip`/`peek`** — those two bail
    /// at their guard, which is the accident under test; a pin routed through
    /// them would be green over nothing.
    ///
    /// **RED ON OLD (production, `MobileEditorViewModel.displaySlot`):** with
    /// `slots[i] = slot` restored, this test does not fail — it **TRAPS**
    /// ("Swift/ContiguousArrayBuffer.swift:690: Fatal error: Index out of
    /// range"), taking the runner down. The quoted output is in the batch
    /// record.
    @Test func displayingAFreshlyMintedBlocksSlotDoesNotTrap() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            let minted = try await mintATailBlock(model, storage)
            let mintedVariant = try #require(
                model.index.entries.last?.variantID, "the mint carries its variant")

            // A reorder door's own act: show this block a different text for
            // the take it now leads with.
            model.displaySlot(
                Queries.RenderedBlock(
                    blockID: minted, placementID: "p-\(minted)", position: "z",
                    variantID: mintedVariant, text: "Reordered.",
                    activeVariantCount: 2, liveVariantCount: 2, commentCount: 0,
                    variantLocked: false),
                for: minted)

            // The surface and the index moved… (the still-open tail "t" sits
            // after the minted block, so this is a contains, not a suffix).
            #expect(storage.string.contains("Reordered."))
            #expect(!storage.string.contains("Minted paragraph"))
            #expect(model.index.entries.last?.blockID == minted)
            #expect(model.index.entries.last?.length == ("Reordered." as NSString).length,
                    "the index entry was rebuilt for the new text")
            #expect(model.index.documentLength == storage.length,
                    "index and storage still agree — the tiling is intact")
            // …and `slots` was left alone, which is the honest end state: a
            // block the projection has not echoed back has no slot bookkeeping
            // to update, and the next projection brings it.
            #expect(model.slots.count == 2)
            #expect(model.slot(for: minted) == nil)
            #expect(model.identityAuditFailures == 0)
            _ = db
        }
    }

    /// The other half of the same door, so the fix is not "it stops writing":
    /// a block that IS in `slots` still has its slot updated, by identity.
    ///
    /// **RED ON OLD:** green on both trees by construction — inside this
    /// state the two indexes coincide, which is precisely why the shipped
    /// coupling looked safe. It is here as the fix's control: an
    /// implementation that satisfied the pin above by writing nothing at all
    /// would fail this one.
    @Test func aBlockTheProjectionKnowsStillHasItsSlotUpdated() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(model.slot(for: seed.blockA)?.variantID == seed.a2,
                    "the peeked take is what the slot bookkeeping now says")
            #expect(model.slots.count == 2)
            #expect(model.slots[1].blockID == seed.blockB,
                    "and the neighbour's slot was not the one written")
            _ = db
        }
    }
}

/// Opens a tail, types a paragraph past its own newline, and settles the
/// mint — leaving the editor in the crystallization window with the minted
/// block in `index.entries` and absent from `slots`. Returns its block id.
///
/// The timing is the shipped rule (`MobileEditorCrystallizationTests`'s own
/// sequence): a paragraph completes when the NEXT one begins.
@MainActor
private func mintATailBlock(
    _ model: MobileEditorViewModel, _ storage: NSTextStorage
) async throws -> String {
    let before = Set(model.index.entries.map(\.blockID))
    typeAtEnd(model, storage, "\n")
    typeAtEnd(model, storage, "Minted paragraph")
    typeAtEnd(model, storage, "\n")
    typeAtEnd(model, storage, "t")
    await model.awaitMintSettle()
    return try #require(
        model.index.entries.map(\.blockID).first { !before.contains($0) },
        "the tail crystallized into a block")
}
