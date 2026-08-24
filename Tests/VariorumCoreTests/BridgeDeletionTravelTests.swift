import Foundation
import Testing
@testable import VariorumCore

/// Phase 13l, ledger 20 — **journal-day deletions TRAVEL to Fragments**
/// (her ruling, 2026-08-19, on seeing the purge memo's §4e callout: *"I
/// didn't realize it wouldn't delete from fragments and that will have to
/// be fixed"*). Before this, the push half read LIVE journal notes only, so
/// a deleted day just went silent and the Fragments entry stayed forever.
///
/// The leg's rules and the reasoning behind each guard live at
/// `BridgeEngine.deletionScan`; these pins are the behavior. THE ONE
/// THAT MATTERS MOST is `aFragmentsEditAfterTheDeletionIsNeverBlanked` —
/// the S5 doctrine's letter, in the one place a deletion could break it.
@Suite("Bridge deletion travel (Phase 13l, ledger 20)")
struct BridgeDeletionTravelTests {

    // MARK: The happy road — travel once, self-heal on Put back

    @Test func aDeletedBridgedDayTravelsItsDeletionOnce() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "A day I later delete.")
            let first = try await bridge.engine.run()
            #expect(first.push.pushed == 1)
            #expect(first.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "A day I later delete.")

            // She deletes the note in Variorum (the 13j Trash road: an
            // ordinary tombstone, recoverable for 30 days).
            try bridge.ops.deleteContainer(entry.container.id)

            let travelled = try await bridge.engine.run()
            #expect(travelled.push.deletionsPushed == 1)
            #expect(travelled.push.pushed == 1)  // a deletion IS a push
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "")
            // The agreement now says "we agreed on nothing" — which is what
            // makes the next round quiet.
            #expect(try bridge.dayState("2026-07-09") == BridgeHash.body(""))

            // ONCE: a second round tells Fragments nothing new, and reaches
            // the server for no write at all.
            let writesAfter = await bridge.server.acceptedWriteCount
            let quiet = try await bridge.engine.run()
            #expect(quiet.push.deletionsPushed == 0)
            #expect(quiet.push.pushed == 0)
            #expect(await bridge.server.acceptedWriteCount == writesAfter)
        }
    }

    @Test func putBackRePushesTheBody() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Put me back.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)
            _ = try await bridge.engine.run()
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "")

            // Put back (13j's door). Nothing bridge-specific heals it: the
            // day is live again, its rendered text differs from the
            // agreed-empty hash, and the ordinary scan re-projects.
            try bridge.ops.restoreContainer(entry.container.id)
            let healed = try await bridge.engine.run()
            #expect(healed.push.pushed == 1)
            #expect(healed.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Put me back.")
        }
    }

    // MARK: THE GUARD — a deletion never destroys prose typed in Fragments
    // after it (the S5 doctrine's letter; the brief's one design
    // consideration)

    /// Direction 2 of the guard: she deletes the day in Variorum, then
    /// writes that day in Fragments. The round's PULL lands her words as a
    /// fresh note (create-or-open — the purge memo's documented outcome),
    /// which claims the day, so the deletion leg never sees it. Her prose
    /// survives on BOTH surfaces.
    ///
    /// The Fragments stamp here is deliberately the one that would TIE the
    /// bridge's minimal push stamp — the residual where LWW alone does not
    /// protect her (migration 7's ties go to the pusher). The guard is
    /// structural, not probabilistic.
    @Test func aFragmentsEditAfterTheDeletionIsNeverBlanked() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "The old body.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)

            // She opens that day on her phone and writes — stamped exactly
            // where LWW would NOT save her (the deletion's own minimal
            // stamp; ties go to the pusher under migration 7's `>=`). What
            // protects her here is the pull, not the clock.
            let agreedStamp = try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-07-09")!.remoteStamp!
            }
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Written in Fragments AFTER I deleted the note.",
                updatedAt: BridgeEngine.pushStamp(now: "", outranking: agreedStamp))

            let round = try await bridge.engine.run()
            // No deletion travelled…
            #expect(round.push.deletionsPushed == 0)
            // …because the landing re-created the day as a fresh note.
            #expect(round.landing.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09")
                    == "Written in Fragments AFTER I deleted the note.")
            // …and Fragments still holds exactly what she typed.
            #expect(try await bridge.fragmentsBody(day: "2026-07-09")
                    == "Written in Fragments AFTER I deleted the note.")
            // Nothing had to be rescued: no take was minted, no body was
            // durably preserved — the words were simply never at risk.
            #expect(round.push.rescuedReceipts == 0)
            #expect(try await bridge.db.read { try BridgeEngine.unrescuedBodyNotes($0) }.isEmpty)
        }
    }

    /// The same divergence, with the bridge OFFLINE in between (her real
    /// shape: the 14b→14d pause, or a laptop shut for a week). The
    /// catch-up round still lands before it projects, so the outcome is
    /// identical — the deletion is never the first thing a round does.
    @Test func aDivergedDayCaughtUpAfterAPauseStillLandsFirst() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Before the pause.")
            _ = try await bridge.engine.run()
            // …the bridge stops running…
            try bridge.ops.deleteContainer(entry.container.id)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Typed during the pause.", updatedAt: bridge.fragmentsStamp(3))
            // …and comes back.
            let round = try await bridge.engine.run()
            #expect(round.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Typed during the pause.")
        }
    }

    /// A STALLED pull withdraws the leg's authorization: the round did not
    /// finish learning what Fragments holds, and a deletion is the one push
    /// that blanks rather than replaces. The deleted day here is
    /// unambiguously deletable — it travels the moment the stall clears.
    @Test func aStalledRoundTravelsNoDeletion() async throws {
        try await withBridge { bridge in
            let doomed = try bridge.makeEntry(day: "2026-07-09", text: "Delete me.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(doomed.container.id)

            // A DIFFERENT day stalls the landing: a sealed, blockless entry
            // with an incoming Fragments body (the round-3 defer shape).
            let sealed = try bridge.ops.createOrOpenJournalEntry(entryDate: "2026-07-10").container
            try bridge.ops.lockPost(sealed.id)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-10",
                body: "Against a sealed empty day.", updatedAt: bridge.fragmentsStamp(0))

            let stalled = try await bridge.engine.run()
            #expect(stalled.landing.stalled)
            #expect(stalled.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Delete me.")

            // Unseal: the held row lands, the stall clears, and the same
            // deletion travels on the very next round.
            try bridge.ops.unlockPost(sealed.id)
            let healed = try await bridge.engine.run()
            #expect(!healed.landing.stalled)
            #expect(healed.push.deletionsPushed == 1)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "")
        }
    }

    /// A bare `push()` never travels deletions — the default is off because
    /// a caller that has not pulled cannot know whether the day diverged.
    @Test func aBarePushNeverTravelsDeletions() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Delete me.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)
            let report = try await bridge.engine.push()
            #expect(report.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Delete me.")
        }
    }

    // MARK: What is NOT a deletion

    /// A note that graduates OUT of the journal profile keeps its day — the
    /// ordinary push scan stops following it (pre-existing behavior), but
    /// its Fragments day must not be blanked: the note still exists.
    /// "Claimed" therefore means claimed by ANY live note, never by a live
    /// JOURNAL note.
    @Test func aNoteThatGraduatedOutOfTheJournalIsNotADeletion() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "This becomes a blog post.")
            _ = try await bridge.engine.run()
            try bridge.ops.setProfile(entry.container.id, profile: .blog)

            let round = try await bridge.engine.run()
            #expect(round.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "This becomes a blog post.")
        }
    }

    /// A day the bridge never agreed on cannot travel a deletion: there is
    /// no body it could be claiming to remove, and pushing emptiness could
    /// only LWW-blank something the bridge has not seen (the push half's
    /// standing never-a-first-push-of-emptiness rule, in the leg's terms).
    @Test func anUnbridgedDayNeverTravelsADeletion() async throws {
        try await withBridge { bridge in
            // A Fragments body the bridge has NEVER pulled, and a Variorum
            // note for the same day that is deleted before any round runs.
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Only Fragments has ever held this.",
                updatedAt: bridge.fragmentsStamp(0))
            let entry = try bridge.makeEntry(day: "2026-07-08", text: "Another day entirely.")
            try bridge.ops.deleteContainer(entry.container.id)

            let round = try await bridge.engine.run()
            #expect(round.push.deletionsPushed == 0)
            // The 07-09 body landed as a fresh note; nothing was blanked.
            #expect(try await bridge.fragmentsBody(day: "2026-07-09")
                    == "Only Fragments has ever held this.")
            // 07-08 was never bridged, so it has no bridge_day row at all.
            #expect(try bridge.dayState("2026-07-08") == nil)
        }
    }

    /// A day carrying a STAMP-ONLY `bridge_day` row (hash NULL — the
    /// deletion-raced-an-edit bookkeeping: an LWW stamp recorded with NO
    /// agreed body) has nothing to compare against, so its deletion does
    /// not travel. The `IS NOT NULL` filter is also what keeps the leg from
    /// reading a NULL into a non-optional `String`.
    @Test func aStampOnlyDayNeverTravelsADeletion() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Variorum text.")
            // A Fragments row that is then tombstoned, landing against a
            // Variorum edit the bridge never agreed on: the landing keeps
            // the edit and records the tombstone's LWW stamp ALONE.
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Phone text.", updatedAt: bridge.fragmentsStamp(0))
            _ = try await bridge.server.fragmentsAppDeletes(
                day: "2026-07-09", deletedAt: bridge.fragmentsStamp(1))
            _ = try await bridge.engine.pullAndLand()
            #expect(try bridge.dayState("2026-07-09") == nil)
            #expect(try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-07-09")?.remoteStamp
            } != nil)

            try bridge.ops.deleteContainer(entry.container.id)
            let round = try await bridge.engine.run()
            #expect(round.push.deletionsPushed == 0)
        }
    }

    /// A restaged day (the re-key / 14d migration sentinel) carries no
    /// COMPARABLE agreement — its wire body is sealed under a dead key —
    /// so a deletion in that window does not travel. A deliberate corner,
    /// not an omission: the guard's letter is "only when the Fragments side
    /// still matches the last-pushed hash", and a sentinel means the bridge
    /// cannot make that statement.
    ///
    /// **How long the corner lasts is NOT what this pin's original prose
    /// implied** — see `aDayDeletedBeforeARestageIsStrandedForeverAndSaysSo`
    /// below (Phase 13l, the ladder's LR-MAJOR-1): for a day with no live
    /// note the refusal is permanent, because only a successful push
    /// replaces a sentinel and the push scan follows live notes.
    ///
    /// The second round before staging is load-bearing and was found by
    /// this pin's own red-on-old check: it walks the cursor past the
    /// bridge's own pushed row, so the round under test pulls nothing. With
    /// the row still ahead of the cursor, the LANDING half resurrects the
    /// day first (the sentinel matches no incoming hash, so the day's own
    /// body re-lands through create-or-open) and the guard is never
    /// reached — see the resurrection pin below, which owns that behavior.
    @Test func aRestagedDayDoesNotTravelItsDeletion() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Agreed once.")
            _ = try await bridge.engine.run()
            _ = try await bridge.engine.run()  // the cursor passes our own push
            try await bridge.db.write { db in
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }
            try bridge.ops.deleteContainer(entry.container.id)

            let round = try await bridge.engine.run()
            #expect(round.landing.created == 0)  // nothing to pull — the leg IS reached
            #expect(round.push.deletionsPushed == 0)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Agreed once.")
        }
    }

    /// **A documented corner of the RESTAGE machinery, found while pinning
    /// the guard above** (Phase 13l Act 6; recorded rather than fixed —
    /// changing it means changing the landing classifier, which is not this
    /// act's, and the outcome is a recoverable extra note, never a loss).
    ///
    /// `stageRepushFromTruth` (the re-key / 14d migration act) replaces
    /// every agreed hash with a sentinel so truth re-pushes. If a day is
    /// DELETED inside that window while its Fragments row is still ahead of
    /// the pull cursor, the row re-lands: the sentinel matches no incoming
    /// hash, there is no live note, and create-or-open mints a FRESH note
    /// carrying the day's own last projected body. Deleted content comes
    /// back — from our own projection rather than from anything she typed.
    ///
    /// Pre-existing and independent of the deletion leg (the leg never runs
    /// for a day the landing just re-claimed); pinned here because this is
    /// where it was traced. QUESTIONS #76(c).
    @Test func aRestagedDeletedDayIsResurrectedByItsOwnRowReLanding() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Agreed once.")
            _ = try await bridge.engine.run()  // pushes; the row is now ahead of the cursor
            try await bridge.db.write { db in
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }
            try bridge.ops.deleteContainer(entry.container.id)

            let round = try await bridge.engine.run()
            #expect(round.landing.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09") == "Agreed once.")
            #expect(round.push.deletionsPushed == 0)
        }
    }

    // MARK: The STRANDED population (Phase 13l, the end-of-phase ladder's
    // LR-MAJOR-1)

    /// **The corner above is permanent, and it now says so.**
    ///
    /// Traced mechanism: `stageRepushFromTruth` stamps the sentinel onto
    /// EVERY `bridge_day` row carrying a hash — including rows for days whose
    /// note is already deleted. A sentinel is only ever replaced by a
    /// successful push, and the push half's scan reads LIVE journal notes, so
    /// a dead day's sentinel is never replaced by anything, ever. Guard 2
    /// then refuses that day's deletion on every round for the life of the
    /// store. The population is every day deleted BEFORE a restage (a re-key,
    /// or 14d's migration act of 2026-08-16) as well as inside its window.
    ///
    /// **Two halves, deliberately in one pin:**
    /// - The PERMANENCE half (`deletionsPushed == 0`, round after round, the
    ///   sentinel still in place) is **behavior, not a fix** — it passes
    ///   before and after. Whether such a deletion may travel anyway is a
    ///   product call and hers (QUESTIONS #78); this pin exists so the answer
    ///   is chosen rather than inherited.
    /// - The VISIBILITY half (`strandedDeletionDays`, and a note that names
    ///   the day) is the fix, and it is red on old: before it, the day was
    ///   dropped on the floor without a word — silent permanent divergence.
    @Test func aDayDeletedBeforeARestageIsStrandedForeverAndSaysSo() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Agreed once.")
            _ = try await bridge.engine.run()
            _ = try await bridge.engine.run()  // the cursor passes our own push

            // She deletes the note — and only THEN does a re-key stage every
            // bridged day for a re-push from truth. The dead day is staged
            // with the living ones.
            try bridge.ops.deleteContainer(entry.container.id)
            try await bridge.db.write { db in
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }

            // Round after round after round: nothing travels, nothing heals.
            for _ in 0..<3 {
                let round = try await bridge.engine.run()
                #expect(round.landing.created == 0)  // the leg IS reached
                #expect(round.push.deletionsPushed == 0)
                #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "Agreed once.")
                // THE FIX: the day is named, every round, like the
                // duplicate-day pause it resembles.
                #expect(round.push.strandedDeletionDays == ["2026-07-09"])
                #expect(round.push.notes.contains {
                    $0.contains("2026-07-09") && $0.contains("Fragments")
                })
            }
            // Permanence, stated at the mechanism: the sentinel is still
            // there, and nothing in the engine can replace it.
            #expect(try bridge.dayState("2026-07-09") == BridgeEngine.restagedHashSentinel)
        }
    }

    /// The stranded fact is about LOCAL STATE, not about a round's
    /// permissions: a bare `push()` may travel no deletions at all, and must
    /// still say which ones it can never travel.
    @Test func aStrandedDayIsNamedEvenWhenTheRoundMayTravelNothing() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Agreed once.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)
            try await bridge.db.write { db in
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }

            let report = try await bridge.engine.push()  // travelDeletions: off
            #expect(report.deletionsPushed == 0)
            #expect(report.strandedDeletionDays == ["2026-07-09"])
            #expect(report.notes.contains { $0.contains("2026-07-09") })
        }
    }

    /// A day that is merely deletable — sentinel-free — is never called
    /// stranded, and a day nothing has happened to says nothing at all. (The
    /// note recurs every round, so a false positive would become a permanent
    /// alarm.)
    @Test func anOrdinaryDeletableDayIsNeverCalledStranded() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Ordinary.")
            let first = try await bridge.engine.run()
            #expect(first.push.strandedDeletionDays.isEmpty)

            try bridge.ops.deleteContainer(entry.container.id)
            let travelled = try await bridge.engine.run()
            #expect(travelled.push.deletionsPushed == 1)
            #expect(travelled.push.strandedDeletionDays.isEmpty)

            // And once told, the agreed-EMPTY day is quiet rather than
            // stranded — the two refusals must not be confused.
            let quiet = try await bridge.engine.run()
            #expect(quiet.push.strandedDeletionDays.isEmpty)
            #expect(quiet.push.notes.isEmpty)
        }
    }

    /// Put back reaches even a stranded day: the note is live again, so it is
    /// claimed, so it is not stranded — and the ordinary scan re-pushes truth
    /// over the sentinel, which is the one thing that clears one.
    @Test func puttingTheNoteBackClearsTheStranding() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "Agreed once.")
            _ = try await bridge.engine.run()
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)
            try await bridge.db.write { db in
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }
            #expect(try await bridge.engine.run().push.strandedDeletionDays == ["2026-07-09"])

            try bridge.ops.restoreContainer(entry.container.id)
            let healed = try await bridge.engine.run()
            #expect(healed.push.strandedDeletionDays.isEmpty)
            #expect(healed.push.pushed == 1)  // truth re-pushed over the sentinel
            #expect(try bridge.dayState("2026-07-09") == BridgeHash.body("Agreed once."))
        }
    }

    // MARK: The residual, pinned as behavior rather than left to surprise

    /// The exact-tie residual, made concrete: a Fragments save the bridge
    /// never pulled, stamped so that the deletion's minimal stamp TIES it
    /// (ties go to the pusher), destroys it server-side — and the `replaced`
    /// receipt's no-landable-block arm preserves the full body DURABLY,
    /// re-surfacing every round until she clears it by hand. Nothing typed
    /// is lost; it is a note rather than a take only because the day has no
    /// note left to carry one.
    @Test func anUnseenBodyDestroyedByADeletionIsPreservedInFull() async throws {
        try await withBridge { bridge in
            let entry = try bridge.makeEntry(day: "2026-07-09", text: "The old body.")
            _ = try await bridge.engine.run()
            try bridge.ops.deleteContainer(entry.container.id)

            // A save the bridge cannot see, because this pin drives the
            // push half ALONE (no pull, exactly the state a stall or a
            // visibility horizon leaves) — stamped so the deletion's
            // minimal stamp lands on it exactly.
            let agreedStamp = try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-07-09")!.remoteStamp!
            }
            let tying = BridgeEngine.pushStamp(now: "", outranking: agreedStamp)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "A phone save nobody pulled.", updatedAt: tying)

            let report = try await bridge.engine.push(travelDeletions: true)
            #expect(report.deletionsPushed == 1)
            let preserved = try await bridge.db.read {
                try BridgeEngine.unrescuedBodyNotes($0)
            }
            #expect(preserved.count == 1)
            #expect(preserved[0].contains("A phone save nobody pulled."))
            // And it keeps re-surfacing until cleared by hand.
            let next = try await bridge.engine.push(travelDeletions: true)
            #expect(next.notes.contains { $0.contains("A phone save nobody pulled.") })
        }
    }
}
