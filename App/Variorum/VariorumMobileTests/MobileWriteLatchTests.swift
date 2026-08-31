//
//  MobileWriteLatchTests.swift
//  VariorumMobileTests
//
//  **ONE GESTURE, ONE ROW** — the pins for `MobileWriteLatch` and the three
//  doors that adopted it, from the phone's cold architectural review
//  (2026-08-30), MAJOR 1.
//
//  Every one of these drives the review's traced mechanism literally: a
//  SwiftUI `Button { Task { … } }` spawns an independent unstructured task
//  per tap, and a door whose `.disabled` is a pure function of fields that
//  do not change during the write stays hittable for the whole flight. Two
//  `Task`s on the main actor reproduce that exactly — the first runs to its
//  first suspension, the second then runs the guard the door either has or
//  does not.
//
//  What is deliberately NOT pinned here is "every unlatched door". The
//  review's own caution is the discipline: a door over an idempotent
//  operation (`createOrOpenJournalEntry` is create-*or*-open inside one
//  serialized write) is safe by the OPERATION's property, and latching it
//  would pin nothing. These three are the doors where a second flight
//  MINTS A SECOND ROW with no layer beneath to catch it.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func liveRows(_ db: AppDatabase, sql: String, _ args: StatementArguments) async throws
    -> Int
{
    try await db.read { db in try Int.fetchOne(db, sql: sql, arguments: args) ?? 0 }
}

@MainActor
@Suite("Mobile write latch — one gesture, one row (architecture review MAJOR 1)")
struct MobileWriteLatchTests {

    // MARK: The latch itself

    /// The whole contract, on the bare object: the second flight is
    /// DECLINED (nil, distinguishable from a refusal), and the latch is
    /// clear again afterwards so the next real gesture is free.
    @Test func aSecondFlightIsDeclinedWhileTheFirstIsInTheAir() async throws {
        let latch = MobileWriteLatch()
        var landings = 0
        let first = Task { await latch.run { () -> Int in
            await Task.yield()
            landings += 1
            return landings
        } }
        let second = Task { await latch.run { () -> Int in
            landings += 1
            return landings
        } }
        let a = await first.value
        let b = await second.value
        #expect(landings == 1, "one gesture ran once")
        #expect(a == 1)
        #expect(b == nil, "the declined flight says nil, never a refusal")
        #expect(!latch.isBusy, "and the door is free again")
    }

    /// A body that throws its way out must not wedge the door shut — a
    /// latch that can stick is worse than the duplicate it prevents.
    @Test func theLatchClearsEvenWhenTheFlightFails() async throws {
        let latch = MobileWriteLatch()
        _ = await latch.run { () -> Bool in false }
        #expect(!latch.isBusy)
        let ran = await latch.runIfFree {}
        #expect(ran)
        #expect(!latch.isBusy)
    }

    // MARK: The comment door — the sharpest unlatched mint in the app

    /// **TWO TAPS ON SUBMIT LEAVE ONE COMMENT.** `block_comment` carries no
    /// uniqueness BY DESIGN (AppSpec §7 — a note has no natural key), so
    /// there is no live-unique index, no `assert…IsFree`, nothing at all
    /// beneath the door: a double-fired submit simply left two identical
    /// comments on the block, and only the door could ever have known.
    @Test func twoTapsOnAddCommentLeaveOneComment() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "comments", profile: .blog)
                let minted = try ops.newBlock(in: post.id, text: "A block.", at: .end)
                return (post.id, minted.block.id)
            }
            let (model, _) = makeEditor(session, postID: seed.0)
            await model.loadOnce()
            model.comments.open(blockID: seed.1)
            await model.comments.refresh()

            let first = Task { await model.comments.add("the same note, twice") }
            let second = Task { await model.comments.add("the same note, twice") }
            await first.value
            await second.value

            let count = try await liveRows(
                db,
                sql: """
                    SELECT COUNT(*) FROM block_comment
                    WHERE block_id = ? AND deleted_at IS NULL
                    """,
                [seed.1])
            #expect(count == 1, "one gesture, one comment")
        }
    }

    // MARK: The take mints — the fan is a list, so a double tap grows it by two

    /// **TWO TAPS ON "branch this take" LEAVE ONE NEW TAKE.** This door
    /// awaits a flush before it writes (the S2 ladder's flush-first rule),
    /// which is a WIDE window on a button that stays hittable throughout,
    /// and `branchVariant` has no arm that could notice the second ask.
    @Test func twoTapsOnBranchLeaveOneNewTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "takes", profile: .blog)
                let minted = try ops.newBlock(in: post.id, text: "One take.", at: .end)
                return (post.id, minted.block.id)
            }
            let (model, _) = makeEditor(session, postID: seed.0)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.1)

            let first = Task { await model.takesBrowser.branchDisplayed() }
            let second = Task { await model.takesBrowser.branchDisplayed() }
            _ = await first.value
            _ = await second.value

            let takes = try await liveRows(
                db,
                sql: """
                    SELECT COUNT(*) FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                    """,
                [seed.1])
            #expect(takes == 2, "the original and ONE branch — not two branches")
        }
    }

    /// The blank-take door rides the same latch through `mint`.
    @Test func twoTapsOnBlankTakeLeaveOneNewTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "takes", profile: .blog)
                let minted = try ops.newBlock(in: post.id, text: "One take.", at: .end)
                return (post.id, minted.block.id)
            }
            let (model, _) = makeEditor(session, postID: seed.0)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.1)

            let first = Task { await model.takesBrowser.newBlank() }
            let second = Task { await model.takesBrowser.newBlank() }
            _ = await first.value
            _ = await second.value

            let takes = try await liveRows(
                db,
                sql: """
                    SELECT COUNT(*) FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                    """,
                [seed.1])
            #expect(takes == 2)
        }
    }

    // MARK: The create-book door — where the review pointed, and what it found

    /// **THE DUPLICATE BOOK WAS ALREADY CLOSED — BY THE LAYER BENEATH.**
    /// The review's sharpest case named this door, but `assertBookNameIsFree`
    /// landed INSIDE the runner closure at `66606c0`, after the review was
    /// written. So the second flight refuses at the core and the store was
    /// already safe; this pin holds that permanently.
    ///
    /// What the latch adds is the other half, and it is what this pin's
    /// second assertion is for: a gesture she made ONCE stops answering her
    /// with a refusal. On the unlatched door the second tap set
    /// `lastError` to the duplicate-name sentence — an error message for a
    /// book she asked for once, and got.
    @Test func twoTapsOnCreateBookLeaveOneBookAndNoRefusal() async throws {
        try await withEditorWorld { session, db in
            let model = MobileCreateBookModel(session: session)
            model.name = "Fieldwork"

            let first = Task { await model.create() }
            let second = Task { await model.create() }
            _ = await first.value
            _ = await second.value

            let books = try await liveRows(
                db,
                sql: "SELECT COUNT(*) FROM reading WHERE name = ? AND deleted_at IS NULL",
                ["Fieldwork"])
            #expect(books == 1, "the core guard's half — one book")
            #expect(model.lastError == nil,
                    "the latch's half — one gesture must not answer with a refusal")
        }
    }

    // MARK: The lenses adopt door — the falsifier of the class argument

    /// **TWO TAPS ON "✓ make this the note" LEAVE ONE PRESERVATION LENS.**
    ///
    /// The Fable sweep's finding 1 (2026-08-30). The fix round's record
    /// closed MAJOR 1 with a universal sentence — *"none of them can mint
    /// an uncaught duplicate row"* — and this door falsifies it. Every
    /// layer says yes to the second flight:
    ///
    /// · the door is a persistent plain `Button { Task { … } }`, so unlike
    ///   the alert-hosted save/rename doors it does not dismiss on the
    ///   first tap, and it keeps rendering because `viewDiverges` stays
    ///   true until the first flight's own refresh self-heals the peeks;
    /// · `adoptView` captures `picks` BEFORE its first suspension, so the
    ///   second flight passes `guard !picks.isEmpty` with the same picks;
    /// · `adoptPicksPreservingChosen` inserts its preservation `Lens`
    ///   UNCONDITIONALLY, ahead of any pick validation, and the `lens`
    ///   table carries no uniqueness (the only lens-side live-unique index
    ///   is `uq_lens_choice_live` on `(lens_id, block_id)`).
    ///
    /// So the store keeps both, and she is left hand-deleting a duplicate
    /// "chosen until …" lens — the same clutter class as the branch doors
    /// above, on a door the class argument said was covered.
    ///
    /// **AND THE PIN ASSERTS THE DECLINE, NOT ONLY THE COUNT** (R2-5, the
    /// fix diff's own cold review). A row count has a silent-green
    /// direction: if the second flight ever scheduled entirely after the
    /// first completed, the self-healed peeks would empty
    /// `displayedDivergences`, `adoptViewOnce` would return at
    /// `guard !picks.isEmpty`, and ONE row would be counted with the latch
    /// removed. `adoptView` now returns the latch's verdict, so the pin
    /// reads the thing it is actually about: the first tap FLEW and the
    /// second was TURNED AWAY. Both are asserted, because the count still
    /// carries the user-visible half.
    ///
    /// **Red-on-old:** point `adoptView` back at `adoptViewOnce` directly
    /// (drop the latch) and the second flight is admitted — the verdict is
    /// `true` and the count is two.
    @Test func twoTapsOnAdoptLeaveOnePreservationLens() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "lens adopt", profile: .blog)
                let a = try ops.newBlock(in: post.id, text: "Chosen words.", at: .end)
                let second = try ops.branchVariant(a.block.id, from: a.variant.id)
                try ops.autosave(second.id, text: "The other reading.", charDelta: 5)
                return (post.id, a.block.id)
            }
            let (model, _) = makeEditor(session, postID: seed.0)
            await model.loadOnce()
            let lenses = MobileLensesModel(
                session: session, postID: seed.0, editor: model)
            await lenses.refresh()

            // Arrange a divergent view — this is what renders the door.
            model.takes.flip(blockID: seed.1, forward: true)
            await lenses.refresh()
            #expect(lenses.viewDiverges, "the adopt door has ground to render")

            let first = Task { await lenses.adoptView() }
            let second = Task { await lenses.adoptView() }
            let firstFlew = await first.value
            let secondFlew = await second.value

            #expect(firstFlew, "the gesture she made really ran")
            #expect(!secondFlew,
                    "…and the second tap was DECLINED by the latch — not merely tidy")

            let preservations = try await liveRows(
                db,
                sql: """
                    SELECT COUNT(*) FROM lens
                    WHERE container_id = ? AND deleted_at IS NULL
                    """,
                [seed.0])
            #expect(preservations == 1,
                    "one gesture, ONE preserved arrangement — not two")
        }
    }
}
