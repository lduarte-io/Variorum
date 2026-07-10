import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 4 — the pull + landing half: every Fragments-side body
/// lands through ORDINARY operations and ends in a live row, a labeled
/// variant, or a commit. The brief's verification skeleton, one scenario per
/// test.
@Suite("Bridge pull + landing (Phase 9b, Step 4)")
struct BridgeLandingTests {
    // MARK: Create

    @Test func createInFragmentsLandsAsAJournalPost() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Written on the phone, in Fragments.",
                updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09")
                    == "Written on the phone, in Fragments.")
            // The notebook rule: the entry is a journal-profile post.
            let profile = try bridge.db.fetchString(
                "SELECT profile FROM container WHERE entry_date = '2026-07-09' AND deleted_at IS NULL")
            #expect(profile == "journal")
            // Agreed state recorded → the push half will NOT echo it back.
            let push = try await bridge.engine.push()
            #expect(push.pushed == 0)
        }
    }

    @Test func createOrOpenLandsIntoAnExistingEmptyEntry() async throws {
        try await withBridge { bridge in
            let existing = try bridge.ops.createOrOpenJournalEntry(entryDate: "2026-07-09").container
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Body for the already-open day.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.created == 1)
            // No second entry minted — the day still has exactly one.
            #expect(try bridge.db.fetchInt("""
                SELECT COUNT(*) FROM container
                WHERE entry_date = '2026-07-09' AND deleted_at IS NULL
                """) == 1)
            #expect(try bridge.db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                [existing.id]) == 1)
        }
    }

    // MARK: Echoes and replays

    @Test func ownPushEchoSkipsWithoutWriting() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "My text.")
            _ = try await bridge.engine.run()  // pushes, state agreed
            let commitsBefore = try bridge.commitTexts(variantID: variantID)
            // The push's own row comes back on the feed: skipped, cursor
            // advances, no commit, no variant, no autosave.
            let report = try await bridge.engine.pullAndLand()
            #expect(report.skipped == 1)
            #expect(report.updated == 0 && report.created == 0)
            #expect(try bridge.commitTexts(variantID: variantID) == commitsBefore)
            let block = try bridge.firstBlockID(day: "2026-07-09")!
            #expect(try bridge.liveVariants(blockID: block).count == 1)
            // And the round after that pulls nothing new.
            let quiet = try await bridge.engine.pullAndLand()
            #expect(quiet.skipped == 0 && quiet.updated == 0 && quiet.created == 0)
        }
    }

    // MARK: The fifth quiet auto-commit occasion

    @Test func fragmentsEditOverUncommittedAutoCommitsThenAutosaves() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(
                day: "2026-07-09", text: "Uncommitted Variorum text.")
            _ = try await bridge.engine.run()  // agree on the current body
            // Fragments edits the day (only Fragments changed since).
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Rewritten in Fragments.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.updated == 1)
            // The overwrite landed…
            #expect(try bridge.rendered(day: "2026-07-09") == "Rewritten in Fragments.")
            // …the pre-edit text is ONE RESTORE AWAY, and (review round 1,
            // MAJOR 1) so is the LANDED body itself — both quiet auto
            // commits, ONE landing transaction.
            let commits = try bridge.commitTexts(variantID: variantID)
            #expect(commits == ["Uncommitted Variorum text.", "Rewritten in Fragments."])
            let kinds = try await bridge.db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT kind FROM commit_point WHERE variant_id = ? ORDER BY created_at, id",
                    arguments: [variantID])
            }
            #expect(kinds == ["auto", "auto"])
        }
    }

    @Test func alreadyCommittedIdenticalTextTakesNoDoubleCommit() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Committed text.")
            _ = try bridge.ops.commit(variantID, kind: .manual, message: nil)
            _ = try await bridge.engine.run()
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Fragments follow-up.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.updated == 1)
            // The buffer equalled its last commit — the pre-image guard adds
            // NOTHING (no duplicate of "Committed text."); the landed body's
            // own insurance commit still lands (review round 1, MAJOR 1).
            #expect(try bridge.commitTexts(variantID: variantID)
                    == ["Committed text.", "Fragments follow-up."])
        }
    }

    /// THE MAJOR-1 PIN (review round 1; red on pre-fix code): the realistic
    /// daily-use collision — the day's entry is open in the Mac editor with
    /// pending keystrokes when a Fragments edit lands. The editor's
    /// keep-pending flush (Phase 7) then writes the typed text over the
    /// landed body, and the next push replaces it on the Fragments side
    /// too. Pre-fix, the landed body ended in NO commit and NO variant —
    /// gone everywhere, the forbidden outcome. Now the landing transaction
    /// commits the landed body itself: one restore away, no matter what the
    /// editor does next.
    @Test func theLandedBodyItselfSurvivesTheEditorsKeepPendingFlush() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Agreed text.")
            _ = try await bridge.engine.run()  // agreed state
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Typed on the phone.", updatedAt: bridge.fragmentsStamp(0))
            _ = try await bridge.engine.pullAndLand()  // lands the body

            // The editor's keep-pending flush: keystrokes typed before the
            // landing, unflushed then, now written over the landed body.
            try bridge.ops.autosave(
                variantID, text: "Typed in the Mac editor.", charDelta: 24)
            // …and the next push projects the editor text to Fragments.
            _ = try await bridge.engine.push()
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Typed in the Mac editor.")

            // The phone-typed body must still be ONE RESTORE AWAY.
            #expect(try bridge.commitTexts(variantID: variantID)
                    .contains("Typed on the phone."),
                    "the landed Fragments body must never be lost on both surfaces")
        }
    }

    // MARK: Both changed — conflict-as-variant, second writer

    @Test func bothChangedLandsAFragmentsVariantAndTruthReprojects() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Original body.")
            _ = try await bridge.engine.run()  // agreed
            // BOTH surfaces edit.
            try bridge.ops.autosave(variantID, text: "Variorum rewrite.", charDelta: 10)
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Fragments rewrite.", updatedAt: bridge.fragmentsStamp(0))

            let landing = try await bridge.engine.pullAndLand()
            #expect(landing.conflictVariants == 1)
            // Variorum keeps BOTH texts: its own stays the entry's text…
            #expect(try bridge.rendered(day: "2026-07-09") == "Variorum rewrite.")
            // …and the Fragments body is a labeled card in the fan.
            let block = try bridge.firstBlockID(day: "2026-07-09")!
            let variants = try bridge.liveVariants(blockID: block)
            #expect(variants.map(\.text) == ["Variorum rewrite.", "Fragments rewrite."])
            #expect(variants.map(\.label) == [nil, "fragments"])

            // The projection converges: the next push projects Variorum's
            // truth back over the LWW surface (Fragments was "momentarily
            // behind" — the brief's edit-war asymmetry).
            let push = try await bridge.engine.push()
            #expect(push.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Variorum rewrite.")
        }
    }

    // MARK: Deletions

    @Test func fragmentsDeletionIsInsuredThenEmptied() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(
                day: "2026-07-09", text: "Text she deletes from her phone.")
            _ = try await bridge.engine.run()  // agreed
            _ = try await bridge.server.fragmentsAppDeletes(
                configuration: bridge.config, day: "2026-07-09",
                deletedAt: bridge.fragmentsStamp(0))

            let report = try await bridge.engine.pullAndLand()
            #expect(report.updated == 1)
            // The entry survives — truth keeps everything — with an empty
            // projection surface…
            #expect(try bridge.rendered(day: "2026-07-09") == "")
            // …and the deleted text one restore away.
            #expect(try bridge.commitTexts(variantID: variantID)
                    == ["Text she deletes from her phone."])
            // Quiescent afterwards: nothing re-pushes an agreed emptiness.
            let push = try await bridge.engine.push()
            #expect(push.pushed == 0)
        }
    }

    @Test func deletionRacingAVariorumEditLosesToTheEdit() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Original.")
            _ = try await bridge.engine.run()
            // Variorum edits; Fragments deletes (of the stale text).
            try bridge.ops.autosave(variantID, text: "Newer Variorum edit.", charDelta: 5)
            _ = try await bridge.server.fragmentsAppDeletes(
                configuration: bridge.config, day: "2026-07-09",
                deletedAt: bridge.fragmentsStamp(0))

            let landing = try await bridge.engine.pullAndLand()
            #expect(landing.skipped == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Newer Variorum edit.")
            // Truth re-projects: the push un-tombstones their row with the
            // surviving edit (strictly-newer un-tombstone, contract fact 4).
            let push = try await bridge.engine.push()
            #expect(push.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Newer Variorum edit.")
        }
    }

    /// THE MINOR-3 PIN (review round 1; red on pre-fix code): the same race
    /// on a VIRGIN day (no bridge_day row — first contact). The stamp-only
    /// bookkeeping was an UPDATE that no-opped with no row, losing the
    /// tombstone's ahead LWW stamp — the re-projection then pushed with
    /// `now` and wedged `.stale` until the wall clock caught up (exactly
    /// the wedge `last_remote_stamp` exists to close). Now the stamp-only
    /// record upserts, and the push outranks the tombstone immediately.
    @Test func aTombstoneRacingAnEditOnAVirginDayStillGetsOutranked() async throws {
        try await withBridge { bridge in
            // Fragments authored the day, then deleted it — both with
            // ahead (2027) stamps; the feed serves only the current state
            // (the tombstone).
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Phone text, later deleted there.", updatedAt: bridge.fragmentsStamp(0))
            _ = try await bridge.server.fragmentsAppDeletes(
                configuration: bridge.config, day: "2026-07-09",
                deletedAt: bridge.fragmentsStamp(1))
            // Variorum wrote its own entry for the day, never bridged.
            try bridge.makeEntry(day: "2026-07-09", text: "Local Variorum text.")

            let round = try await bridge.engine.run()
            #expect(round.landing.skipped == 1)  // the edit outranks the deletion
            // The re-projection must APPLY (outranking the tombstone's
            // ahead stamp), not wedge .stale.
            #expect(round.push.pushed == 1)
            #expect(round.push.stale == 0)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Local Variorum text.")
        }
    }

    // MARK: The graduated-entry policy (RATIFIED)

    @Test func graduatedEntryRescuesIncomingEditsOnTheFirstBlock() async throws {
        try await withBridge { bridge in
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "First paragraph.")
            try bridge.ops.newBlock(in: entry.id, text: "Second paragraph.", at: .end)
            _ = try await bridge.engine.run()  // pushes the rendered join
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Phone-side rewrite of the whole day.",
                updatedAt: bridge.fragmentsStamp(0))

            let landing = try await bridge.engine.pullAndLand()
            #expect(landing.rescuedVariants == 1)
            // Never diff-mapped back across blocks: block structure intact,
            // the body is a labeled variant on the FIRST block.
            #expect(try bridge.rendered(day: "2026-07-09")
                    == "First paragraph.\n\nSecond paragraph.")
            let first = try bridge.firstBlockID(day: "2026-07-09")!
            let variants = try bridge.liveVariants(blockID: first)
            #expect(variants.map(\.text)
                    == ["First paragraph.", "Phone-side rewrite of the whole day."])
            #expect(variants.map(\.label) == [nil, "fragments"])
            // Push-only: truth re-projects the rendered text.
            let push = try await bridge.engine.push()
            #expect(push.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09")
                    == "First paragraph.\n\nSecond paragraph.")
        }
    }

    @Test func fannedEntryIsGraduatedToo() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "The chosen take.")
            _ = try bridge.ops.branchVariant(
                try bridge.firstBlockID(day: "2026-07-09")!, from: variantID)
            _ = try await bridge.engine.run()
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Phone edit against a fanned day.", updatedAt: bridge.fragmentsStamp(0))
            let landing = try await bridge.engine.pullAndLand()
            #expect(landing.rescuedVariants == 1)
            // The chosen text was NOT overwritten (push-only regime).
            #expect(try bridge.rendered(day: "2026-07-09") == "The chosen take.")
        }
    }

    // MARK: Sealed / locked

    @Test func sealedEntryLandsIncomingAsAVariantDespiteTheSeal() async throws {
        try await withBridge { bridge in
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "Sealed text.")
            _ = try await bridge.engine.run()
            try bridge.ops.lockPost(entry.id)
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Typed in Fragments while sealed.", updatedAt: bridge.fragmentsStamp(0))
            let landing = try await bridge.engine.pullAndLand()
            // The S5 posture: the seal freezes authoring; a bridge landing
            // is not authoring — the body lands as a card, never lost,
            // never overwriting the sealed text.
            #expect(landing.rescuedVariants == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Sealed text.")
            let block = try bridge.firstBlockID(day: "2026-07-09")!
            #expect(try bridge.liveVariants(blockID: block).map(\.label)
                    == [nil, "fragments"])
        }
    }

    /// The sealed-EMPTY corner (review round 1, NIT 8 — the one landing
    /// path that had no test): a deliberately sealed, blockless entry has
    /// no block to carry a rescue card and the seal refuses the mint. The
    /// row is consumed with a note, NO day state is recorded, and the push
    /// half can never blank the Fragments body (the empty-first-push
    /// guard) — the body stays safe, un-landed, exactly as documented.
    @Test func sealedEmptyEntryConsumesTheRowWithoutStateOrBlanking() async throws {
        try await withBridge { bridge in
            let entry = try bridge.ops.createOrOpenJournalEntry(entryDate: "2026-07-09").container
            try bridge.ops.lockPost(entry.id)  // sealed while still blockless
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Phone text against a sealed empty day.",
                updatedAt: bridge.fragmentsStamp(0))

            let round = try await bridge.engine.run()
            #expect(round.landing.skipped == 1)
            #expect(round.landing.notes.contains { $0.contains("sealed empty") })
            // No agreement invented…
            #expect(try bridge.dayState("2026-07-09") == nil)
            // …no card, no block minted under the seal…
            #expect(try bridge.db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                [entry.id]) == 0)
            // …and the push half never blanks the Fragments body.
            #expect(round.push.pushed == 0)
            #expect(await bridge.fragmentsBody(day: "2026-07-09")
                    == "Phone text against a sealed empty day.")
            // Consumed: the next round does not re-see the row.
            let quiet = try await bridge.engine.pullAndLand()
            #expect(quiet.skipped == 0)
        }
    }

    // MARK: Duplicate days

    @Test func duplicateDayStillLandsWhilePushPauses() async throws {
        try await withBridge { bridge in
            // The converged offline race: two live entries on one date.
            let dupA = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupA.id, text: "Entry A.", at: .end)
            let dupB = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupB.id, text: "Entry B.", at: .end)
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Phone text for the doubled day.", updatedAt: bridge.fragmentsStamp(0))

            let round = try await bridge.engine.run()
            // The landing went to the day's canonical entry (earliest —
            // the notebook rule's preference)…
            #expect(round.landing.conflictVariants == 1)
            let blockA = try bridge.db.fetchString(
                "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                [dupA.id])!
            #expect(try bridge.liveVariants(blockID: blockA).map(\.label)
                    .contains("fragments"))
            // …while the push half held the day.
            #expect(round.push.pausedDays == ["2026-07-09"])
            #expect(round.push.pushed == 0)
            #expect(await bridge.fragmentsBody(day: "2026-07-09")
                    == "Phone text for the doubled day.")
        }
    }

    // MARK: Feed hygiene

    @Test func visibilityHorizonNeverSkipsARowForever() async throws {
        try await withBridge(visibilityHorizon: 2) { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Young row.", updatedAt: bridge.fragmentsStamp(0))
            // Too young: the feed withholds it; the cursor must NOT jump
            // past it.
            let early = try await bridge.engine.pullAndLand()
            #expect(early.created == 0)
            await bridge.server.advanceClock(by: 2)
            let later = try await bridge.engine.pullAndLand()
            #expect(later.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Young row.")
        }
    }

    @Test func replayedWindowLandsNothingTwice() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Landed once.", updatedAt: bridge.fragmentsStamp(0))
            _ = try await bridge.engine.pullAndLand()
            // A crash-before-cursor-advance replay: reset the cursor and
            // re-serve the same row.
            try await bridge.db.write { db in
                try db.execute(sql: "DELETE FROM bridge_state WHERE key LIKE 'cursor_%'")
            }
            let replay = try await bridge.engine.pullAndLand()
            #expect(replay.skipped == 1)
            #expect(replay.created == 0 && replay.updated == 0)
            #expect(try bridge.db.fetchInt("""
                SELECT COUNT(*) FROM container
                WHERE entry_date = '2026-07-09' AND deleted_at IS NULL
                """) == 1)
        }
    }

    @Test func foreignUserAndMalformedDayRowsAreConsumedHarmlessly() async throws {
        try await withBridge { bridge in
            // A foreign user's row (RLS should prevent this; the bridge
            // tolerates it) and a malformed day.
            _ = try await bridge.server.push([FragmentsEntry(
                id: "11111111-1111-4111-8111-111111111111",
                userID: "someone-else", date: "2026-07-09", body: "not ours",
                createdAt: bridge.fragmentsStamp(0), updatedAt: bridge.fragmentsStamp(0))])
            _ = try await bridge.server.push([FragmentsEntry(
                id: "22222222-2222-4222-8222-222222222222",
                userID: "user-author", date: "not-a-day", body: "undateable",
                createdAt: bridge.fragmentsStamp(1), updatedAt: bridge.fragmentsStamp(1))])
            let report = try await bridge.engine.pullAndLand()
            #expect(report.skipped == 2)
            #expect(report.notes.count == 2)
            #expect(try bridge.db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE deleted_at IS NULL") == 0)
            // Consumed: the next round does not re-see them.
            let quiet = try await bridge.engine.pullAndLand()
            #expect(quiet.skipped == 0)
        }
    }

    @Test func lostAckReconcilesThroughThePullWithoutARePush() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Pushed but the ack was lost.")
            // Simulate the lost ack: the push APPLIED server-side but the
            // day state was never recorded (crash between transport and
            // bookkeeping).
            _ = try await bridge.engine.push()
            try await bridge.db.write { db in
                try db.execute(sql: "DELETE FROM bridge_day")
            }
            let writesBefore = await bridge.server.acceptedWriteCount
            // Pull-first reconciles: our own row comes back, rendered ==
            // incoming → the converged branch records the agreement…
            let round = try await bridge.engine.run()
            #expect(round.landing.skipped == 1)
            // …and the push half stays silent (no gratuitous re-push, no
            // LWW bump — the lost-ack echo class, postmortem lesson 2).
            #expect(round.push.pushed == 0)
            #expect(await bridge.server.acceptedWriteCount == writesBefore)
        }
    }
}
