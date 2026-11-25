//
//  MobileLineDirectionTests.swift
//  VariorumMobileTests
//
//  **P-55-11 — A DIRECTION KEEPS ITS LINE** (umbrella VM-55, batch 2b; the
//  orchestrator's check of batch 2a, ruled PROVISIONAL in her absence). Batch
//  2a silenced every restoration as an ordinary act (P-55-4). A few of those
//  lines do more than confirm: they tell her the act landed somewhere other
//  than where she would look, or did something beyond what she asked. Those
//  are DIRECTIONS, and they take the class 2a gave P-55-7's ("Already
//  collected", the shelving notes) — the refusal class, always drawn:
//
//  · a take put back that returns ARCHIVED rather than to the fan (the Block
//    History, the Trash and the note's tray, and the lens's editions);
//  · a block put back at the END of its note, or set aside because its note
//    is gone (`putBackAtEnd`, `putBackUnplaced`) — the Trash's, the tray's,
//    and an original brought back with no successor left to land beside;
//  · "Added by tagging #‹tags› — “‹book›” collects by filter."
//
//  Every other line in 2a's list stays silent: the twin of each direction —
//  the same door, landing where she would look — is pinned silent here too
//  (2a's `MobileLineDoorTests.aPutBackSaysNothing` holds the Trash block's).
//
//  **How a regression trips them:** a door that went back to `.ordinary` for a
//  direction leaves `session.status.current` nil (the phone's placement drops
//  an ordinary receipt) — red; a door that drew every put back reds the
//  silent twins. The models' own records are unchanged (a receipt stays a
//  receipt) — the existing pins on them still hold.
//
//  **VM-265 (the VM-260 run, batch 1b; QUESTIONS #277, P-55-19 → (b), ruled
//  2026-11-22): A DIRECTION READS IN A NEUTRAL INK, NOT THE ALARM.** A direction
//  rides the refusal CLASS at the seam (always drawn — that is unchanged, and
//  every pin above still reads `kind == .refusal`); the face's INK is what
//  changes: the phone's muted, the ink a removal's line already wears, while a
//  refusal keeps the alarm. Each direction door above now also asks the face's
//  one ink rule (`MobileMessageLineModel.ink(for:)`) what its line wears —
//  `expectMutedInk`. RED ON OLD: every direction drew in the alarm (the face
//  inked by kind alone, and a direction's kind is the refusal's); a refusal's
//  twin (`aDirectionReadsMutedAndARefusalKeepsTheAlarm`) stays alarm on both.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

/// **VM-265 — a direction's line wears the muted ink, never the alarm** (the
/// face's one ink rule, asked of the item the door actually said).
@MainActor
func expectMutedInk(
    _ line: StatusCenter.Item, sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(MobileMessageLineModel.ink(for: line) == .muted,
            "a direction reads in the phone's muted ink, not the alarm (VM-265): \(line.text)",
            sourceLocation: sourceLocation)
}

@MainActor
@Suite("P-55-11 — a direction keeps its line")
struct MobileLineDirectionTests {

    // MARK: VM-265 — the ink follows the door's word, and a refusal keeps the alarm

    /// The seam's two always-drawn doors side by side: `direct` (a direction,
    /// nothing refused) and `refuse` (nothing happened). Both draw (the class
    /// is the refusal's — the placement is untouched); the face inks the
    /// direction muted and the refusal in the alarm. An offer keeps her ink, a
    /// removal the muted it always wore. RED ON OLD: the direction's line read
    /// the alarm.
    @Test func aDirectionReadsMutedAndARefusalKeepsTheAlarm() throws {
        let status = StatusCenter()
        status.direct("Already collected — it matches “By the Water”'s filter.")
        let direction = try #require(status.current, "a direction always draws")
        #expect(direction.kind == .refusal, "the seam's class is unchanged")
        expectMutedInk(direction)

        status.refuse("That take is archived — unarchive it first.")
        let refusal = try #require(status.current)
        #expect(MobileMessageLineModel.ink(for: refusal) == .alarm, "a refusal keeps the alarm")

        status.offer("Diverge?", action: .init(label: "Diverge", perform: {}))
        #expect(MobileMessageLineModel.ink(for: try #require(status.current)) == .ink)

        status.removal("Block deleted.", undo: .init(label: MobileLine.undoLabel, perform: {}))
        #expect(MobileMessageLineModel.ink(for: try #require(status.current)) == .muted)
    }

    /// **The Today door's entry, opened but NOT filed** (the Journal is
    /// finished) — the shelving note is a direction she must see (the Mac ⌘J
    /// door's own class), and it reads muted. RED ON OLD: the alarm.
    @Test func theTodayDoorsUnfiledEntryReadsMuted() async throws {
        try await withEditorWorld { session, db in
            let model = MobileShelfViewModel(session: session)
            // The first open mints the daily Journal and files the day's entry.
            _ = await model.openToday(day: "2026-10-04")
            let journal = try #require(try await db.read { try Queries.dailyJournalBookID($0) })
            try await session.runner.run { ops in try ops.lockReading(journal) }

            session.status.clear()
            let opened = await model.openToday(day: "2026-10-05")
            #expect(opened != nil, "the entry still opens")
            let words = try #require(
                MobileTodayDoor.shelvingNote(.bookFinished), "the finished Journal's note")
            let line = try #require(session.status.current, "the unfiled entry keeps its line")
            #expect(line.text == words)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
        }
    }

    // MARK: A take back among the ARCHIVED takes

    /// Archived first, then deleted: the restore's exact flip (#68(b)) brings
    /// it back archived. Returns the take's id.
    private func archivedThenDeletedTake(
        _ session: AppSession, blockID: String, from variantID: String
    ) async throws -> String {
        try await session.runner.run { ops -> String in
            let take = try ops.branchVariant(blockID, from: variantID)
            try ops.archiveVariant(take.id)
            try ops.deleteVariant(take.id)
            return take.id
        }
    }

    private func deletedActiveTake(
        _ session: AppSession, blockID: String, from variantID: String
    ) async throws -> String {
        try await session.runner.run { ops -> String in
            let take = try ops.branchVariant(blockID, from: variantID)
            try ops.deleteVariant(take.id)
            return take.id
        }
    }

    @Test func theTrashsArchivedTakeSpeaksAndItsFanTwinDoesNot() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Alpha."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let blockID = model.index.entries[0].blockID
            let chosen = try #require(model.index.entries[0].variantID)
            let archived = try await archivedThenDeletedTake(session, blockID: blockID, from: chosen)
            let active = try await deletedActiveTake(session, blockID: blockID, from: chosen)
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let trash = MobileTrashModel(session: session)

            session.status.clear()
            await trash.putBack(try #require(rows.first { $0.id == active }))
            #expect(trash.receipt == RecoveryCopy.putBackReceipt(.take))
            #expect(session.status.current == nil, "a take back in the fan says nothing")

            await trash.putBack(try #require(rows.first { $0.id == archived }))
            #expect(trash.receipt == RecoveryCopy.takeRestoredArchived, "the model keeps its record")
            #expect(trash.lastError == nil, "a direction is not an error")
            let line = try #require(session.status.current, "the direction keeps its line")
            #expect(line.kind == .refusal, "P-55-7's class")
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.takeRestoredArchived)
        }
    }

    @Test func theTraysArchivedTakeSpeaksAndItsFanTwinDoesNot() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let blockID = model.index.entries[0].blockID
            let chosen = try #require(model.index.entries[0].variantID)
            let archived = try await archivedThenDeletedTake(session, blockID: blockID, from: chosen)
            let active = try await deletedActiveTake(session, blockID: blockID, from: chosen)
            let tray = MobileNoteTrayModel(session: session, postID: postID)

            session.status.clear()
            await tray.putBackTake(active)
            #expect(tray.status == .receipt(RecoveryCopy.putBackReceipt(.take)))
            #expect(session.status.current == nil, "a take back in the fan says nothing")

            await tray.putBackTake(archived)
            #expect(tray.status == .receipt(RecoveryCopy.takeRestoredArchived),
                    "the model's record stays a receipt")
            let line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.takeRestoredArchived)
        }
    }

    @Test func theBlockHistorysArchivedTakeSpeaksAndItsFanTwinDoesNot() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let blockID = model.index.entries[0].blockID
            let chosen = try #require(model.index.entries[0].variantID)
            let archived = try await archivedThenDeletedTake(session, blockID: blockID, from: chosen)
            let active = try await deletedActiveTake(session, blockID: blockID, from: chosen)
            model.blockHistory.open(blockID: blockID)
            await model.blockHistory.refresh()

            session.status.clear()
            await model.blockHistory.putBackTake(active)
            #expect(model.blockHistory.status == .receipt(BlockPastCopy.takeRestored))
            #expect(session.status.current == nil, "a take back in the fan says nothing")

            await model.blockHistory.putBackTake(archived)
            #expect(model.blockHistory.status == .receipt(BlockPastCopy.takeRestoredArchived))
            let line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == BlockPastCopy.takeRestoredArchived)
        }
    }

    @Test func aLensPickThatComesBackArchivedSpeaksAndItsFanTwinDoesNot() async throws {
        try await withEditorWorld { session, _ in
            let (postID, lensID, plainBlock, archivedBlock) = try await session.runner.run {
                ops -> (String, String, String, String) in
                let post = try ops.createPost(title: "lens world", profile: .blog)
                let a = try ops.newBlock(in: post.id, text: "Chosen words.", at: .end)
                let b = try ops.newBlock(in: post.id, text: "Other words.", at: .end)
                let lens = try ops.createLens(post: post.id, name: "two picks")
                // Block A's pick: deleted while ACTIVE — it comes back to the fan.
                let gone = try ops.branchVariant(a.block.id, from: a.variant.id)
                _ = try ops.setLensChoice(lens: lens.id, block: a.block.id, variant: gone.id)
                try ops.deleteVariant(gone.id)
                // Block B's pick: archived first, then deleted — it comes back
                // ARCHIVED (the exact flip), so the pick still dangles.
                let archived = try ops.branchVariant(b.block.id, from: b.variant.id)
                _ = try ops.setLensChoice(lens: lens.id, block: b.block.id, variant: archived.id)
                try ops.archiveVariant(archived.id)
                try ops.deleteVariant(archived.id)
                return (post.id, lens.id, a.block.id, b.block.id)
            }
            let (model, _) = makeEditor(session, postID: postID)
            await model.loadOnce()
            let lenses = MobileLensesModel(session: session, postID: postID, editor: model)
            await lenses.refresh()
            await lenses.activate(lensID)

            let plain = try #require(lenses.activeDangles.first { $0.blockID == plainBlock })
            session.status.clear()
            await lenses.restoreDangling(plain)
            #expect(lenses.status == MobileLensesModel.restoredDeleted)
            #expect(session.status.current == nil, "a take back in the fan says nothing")

            let archived = try #require(lenses.activeDangles.first { $0.blockID == archivedBlock })
            #expect(archived.state == .deleted)
            session.status.clear()
            await lenses.restoreDangling(archived)
            #expect(lenses.status == MobileLensesModel.restoredDeletedButArchived)
            let line = try #require(session.status.current, "the direction keeps its line")
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == MobileLensesModel.restoredDeletedButArchived)
        }
    }

    // MARK: A block that lands somewhere other than its place

    /// The core's own fallback fixture (`RecoveryOpsTests`): a divide-W releases
    /// A; deleting A later leaves no placement row to revive, so Put back lands
    /// it at the END of its note.
    @Test func aBlockPutBackAtTheEndOfItsNoteSpeaks() async throws {
        try await withEditorWorld { session, db in
            let (postID, blockID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "ends")
                let made = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
                let second = try ops.branchVariant(made.block.id, from: made.variant.id)
                try ops.autosave(second.id, text: "Alpha two. Beta two.", charDelta: 0)
                _ = try ops.divideW(made.block.id, cuts: [made.variant.id: 10, second.id: 10])
                try ops.deleteBlock(made.block.id)
                return (post.id, made.block.id)
            }
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let trash = MobileTrashModel(session: session)
            session.status.clear()
            await trash.putBack(try #require(rows.first { $0.id == blockID }))
            #expect(trash.receipt == RecoveryCopy.putBackAtEnd(.post))
            let line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.putBackAtEnd(.post))
            _ = postID
        }
    }

    /// Its note is gone: the block comes back, set aside on its own.
    @Test func aBlockPutBackWithItsNoteGoneSpeaks() async throws {
        try await withEditorWorld { session, db in
            let blockID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "gone")
                let made = try ops.newBlock(in: post.id, text: "orphan")
                try ops.deleteBlock(made.block.id)
                try ops.deleteContainer(post.id)
                return made.block.id
            }
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let trash = MobileTrashModel(session: session)
            session.status.clear()
            await trash.putBack(try #require(rows.first { $0.id == blockID }))
            #expect(trash.receipt == RecoveryCopy.putBackUnplaced(.post))
            let line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.putBackUnplaced(.post))
        }
    }

    /// The tray's deleted block, landing at the end — and an original brought
    /// back with no successor left (`PreservedOriginPutBack`'s end landing),
    /// beside its twin that lands where it came from and says nothing.
    @Test func theTraysEndLandingsSpeakAndItsBesideLandingDoesNot() async throws {
        try await withEditorWorld { session, _ in
            let (postID, divided, mergedFirst, mergedSecond, merged) = try await session.runner.run {
                ops -> (String, String, String, String, String) in
                let post = try ops.createPost(title: "tray")
                let made = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
                let second = try ops.branchVariant(made.block.id, from: made.variant.id)
                try ops.autosave(second.id, text: "Alpha two. Beta two.", charDelta: 0)
                _ = try ops.divideW(made.block.id, cuts: [made.variant.id: 10, second.id: 10])
                try ops.deleteBlock(made.block.id)
                let one = try ops.newBlock(in: post.id, text: "One.")
                let two = try ops.newBlock(in: post.id, text: "Two.")
                let result = try ops.merge(one.block.id, two.block.id)
                return (post.id, made.block.id, one.block.id, two.block.id, result.block.id)
            }
            let tray = MobileNoteTrayModel(session: session, postID: postID)

            session.status.clear()
            await tray.putBackDeleted(divided)
            #expect(tray.status == .receipt(RecoveryCopy.putBackAtEnd(.post)))
            var line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.putBackAtEnd(.post))

            // An original whose successor still stands lands beside it: silent.
            session.status.clear()
            await tray.putBackOriginal(mergedFirst)
            #expect(tray.status == .receipt(RecoveryCopy.putBackBeside))
            #expect(session.status.current == nil, "back where it came from says nothing")

            // Its successor deleted, the other original has nowhere beside to
            // land: the note's end — a direction.
            try await session.runner.run { ops in try ops.deleteBlock(merged) }
            session.status.clear()
            await tray.putBackOriginal(mergedSecond)
            #expect(tray.status == .receipt(RecoveryCopy.putBackAtEnd(.post)))
            line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == RecoveryCopy.putBackAtEnd(.post))
        }
    }

    // MARK: Added by tagging

    @Test func aCollectByTaggingSpeaksAndJoiningABookDoesNot() async throws {
        try await withEditorWorld { session, db in
            let (postID, bookID, gatheringID) = try await session.runner.run {
                ops -> (String, String, String) in
                let post = try ops.createPost(title: "Harbor")
                let book = try ops.createReading(name: "Essays", kind: .book)
                _ = try ops.createTag(name: "sea")
                let gathering = try ops.createReading(
                    name: "By the Water", kind: .gathering, querySpec: #"{"tags":["sea"]}"#)
                return (post.id, book.id, gathering.id)
            }
            let membership = MobileMembershipModel(session: session, postID: postID)
            await membership.refresh()

            session.status.clear()
            let book = try #require(try await db.read { try Queries.reading($0, id: bookID) })
            await membership.add(to: book)
            #expect(session.status.current == nil, "joining a book says nothing")

            session.status.clear()
            let gathering = try #require(
                try await db.read { try Queries.reading($0, id: gatheringID) })
            await membership.collect(into: gathering)
            let words = "Added by tagging #sea — “By the Water” collects by filter."
            #expect(membership.status == words)
            let line = try #require(session.status.current, "the direction keeps its line")
            #expect(line.kind == .refusal)
            expectMutedInk(line)
            #expect(line.text == words)
        }
    }

    // MARK: The pure fact under every door

    @Test func theDirectionsAreTheLandingsThatAreNotItsPlace() {
        #expect(!RecoveryCopy.isDirection(.itsOldPlace(home: .post)))
        #expect(RecoveryCopy.isDirection(.endOfNote(home: .post)))
        #expect(RecoveryCopy.isDirection(.endOfNote(home: .pool)))
        #expect(RecoveryCopy.isDirection(.unplaced(home: .post)))
        #expect(RecoveryCopy.isDirection(.unplaced(home: nil)))
        #expect(RecoveryCopy.isDirection(VariantStatus.archived))
        #expect(!RecoveryCopy.isDirection(VariantStatus.active))
        #expect(!TrashPutBack.Outcome.plain.isDirection)
        #expect(!TrashPutBack.Outcome.bookWhole(notes: 3).isDirection)
        #expect(TrashPutBack.Outcome.take(.archived).isDirection)
        #expect(TrashPutBack.Outcome.block(.unplaced(home: .post)).isDirection)
    }
}
