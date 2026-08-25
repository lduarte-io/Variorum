//
//  TrashSurfaceTests.swift
//  VariorumTests
//
//  Phase 13j, batch 6 — the Trash's FACE, the 30-day clock where she reads
//  it, block ARCHIVE's doors, the Blocks-mode section's routing, and the
//  batch's two copy riders.
//
//  Her rulings under test: everything deleted rides one filterable listing
//  with "N days left" and Put back (round 3); archived things keep no clock
//  and say so (rounds 3 + 7); a preserved original moves VISIBLY onto the
//  family's clock when its last descendant is deleted, and the delete's own
//  receipt names it (round 8b); the Blocks mode's tray section becomes a door
//  onto the one panel (round 7).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// **THE POOL/SCRAPS HONESTY CHECK** (13l Act 2, ledger item 5 — §8b:
/// *"verify a deleted POOL reads honestly in the Trash (kind naming, cascade
/// of its scraps, Put back) — the check is that its FACE never calls a pool
/// a note"*).
///
/// What the check FOUND, and what each finding became:
///
/// - **A deleted POOL itself is not reachable at all**, so it cannot be
///   mis-named: `Queries.trash`'s note arm fences `kind = 'post'`, and no
///   door in either app deletes a pool container (`deleteContainer`'s only
///   Mac caller is `LibraryViewModel.delete(postID:)`, reached from the
///   Library's and the Pool's note rows — both of which list `kind='post'`
///   hits, since the surface named "Pool" holds BOOKLESS NOTES, R29). Pinned
///   below so the day something does delete one, this says so.
/// - **A deleted SCRAP is reachable, and the face called its pool a note** —
///   three ways, all fixed in this batch: the row named the home through
///   `DisplayTitle.note` (a pool has no `entry_date`, so a nameless one read
///   *"Untitled"* where every other surface shows its created day — 13k K2);
///   the row's door said **Open note**; and it routed `.post`, opening a pool
///   as a note pane.
/// - **RECORDED, not fixed at seat 1** (it needs the landing to report its
///   container's kind, which is a `Sources/` change that batch was fenced out
///   of): the shared put-back RECEIPTS still said "note" for a scrap —
///   `RecoveryCopy.putBackAtEnd` / `.putBackUnplaced`. **FIXED at seat 2**
///   (ledger row 26, at the mechanism): `Operations.BlockRestoreLanding` now
///   carries the home container's KIND, read inside the restore's own
///   transaction, and `RecoveryCopy.landingReceipt` — the ONE place a landing
///   becomes words — picks the noun from it. Pinned below through the real
///   Trash model, and in core by `RecoveryOpsTests
///   .restoreBlockNamesTheScrapsAreaItCameOutOf`.
@MainActor
@Suite("A scrap's home is a pool, and the Trash says so (13l §8b)")
struct TrashPoolHonestyTests {
    @Test func aDeletedScrapNamesItsScrapsAreaAndOpensThere() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            // A NAMELESS pool — the case where the two display brains part.
            let poolID = try await editor.session.runner.run { (ops: Operations) -> String in
                let pool = try ops.createPool(title: nil)
                let scrap = try ops.newBlock(in: pool.id, text: "a loose sentence")
                try ops.deleteBlock(scrap.block.id)
                return pool.id
            }
            let model = RecoveryViewModel(session: editor.session)
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let scrapRow = try #require(rows.first { $0.kind == .block })
            #expect(scrapRow.noteID == poolID, "its home is the pool it was deleted from")
            model.adopt(archived: [], trash: rows)
            await model.loadPoolHomesForTests()

            // RED ON OLD (behavioral revert: drop `homeIsPool`/`homeTitle`'s
            // pool arms). The query names the home with the NOTE brain…
            //
            // **13l Act 7 edited this line, and it strengthens it.** The
            // query's answer used to be the literal `"Untitled"` because the
            // arm called `DisplayTitle.note` without a `createdAt:` — the
            // walk's find, now fixed in all four arms. It is still the NOTE
            // brain reading a POOL row (a pool has no `entry_date`, and 13k
            // K2's rule for one is `DisplayTitle.pool`), which is exactly why
            // the surface corrects it below. Asserting "the query answers
            // SOMETHING, and the surface overrides it" is the fact this test
            // is about; asserting the placeholder was asserting a defect.
            #expect(scrapRow.noteTitle != nil,
                    "the query answers with the note brain — the surface corrects it")
            // …and the surface corrects it to the pool's.
            #expect(model.homeIsPool(scrapRow))
            let shown = try #require(model.homeTitle(scrapRow))
            #expect(shown != DisplayTitle.placeholder,
                    "a nameless pool shows its created day, never 'Untitled' (13k K2)")

            // A note's row is untouched by any of it.
            let notePost = try await editor.session.runner.run { (ops: Operations) -> String in
                let post = try ops.createPost(title: "Real note")
                let block = try ops.newBlock(in: post.id, text: "prose")
                try ops.deleteBlock(block.block.id)
                return post.id
            }
            let after: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            model.adopt(archived: [], trash: after)
            await model.loadPoolHomesForTests()
            let noteRow = try #require(after.first { $0.noteID == notePost })
            #expect(!model.homeIsPool(noteRow))
            #expect(model.homeTitle(noteRow) == "Real note",
                    "a note still reads through the note brain")
        }
    }

    /// **LEDGER ROW 26 — the put-back RECEIPT stops calling the scraps area a
    /// note**, driven through the real Trash model rather than through the
    /// copy function, because the whole defect was that the SURFACE could not
    /// know the kind: it read a landing that did not carry one.
    ///
    /// The road is the reachable one. A merge in the scraps releases both
    /// sources to lineage — their placement rows tombstone at RELEASE time,
    /// with the merge's stamp — so a later `deleteBlock` leaves nothing
    /// carrying the block's own tombstone and `restoreBlock` takes its
    /// fresh-at-end fallback. That is the exact branch whose sentence was
    /// *"Put back at the end of this note."* for a block that went back into
    /// the Blocks area.
    ///
    /// **RED ON OLD:** on the pre-fix tree this receipt read
    /// `RecoveryCopy.putBackAtEnd`'s single note-shaped constant, so the
    /// "scraps" expectation fails and the negative assertion fails with it.
    /// (Verified by behavioural revert — see the batch record.)
    @Test func aScrapsPutBackReceiptNamesTheScrapsAndNeverTheNote() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let released = try await editor.session.runner.run {
                (ops: Operations) -> String in
                let pool = try ops.createPool(title: "Scraps")
                let one = try ops.newBlock(in: pool.id, text: "a loose sentence")
                let two = try ops.newBlock(in: pool.id, text: "another one")
                // The merge releases both sources; the delete then finds no
                // live placement to stamp, so the put-back lands at the end.
                _ = try ops.merge(one.block.id, two.block.id)
                try ops.deleteBlock(one.block.id)
                return one.block.id
            }
            let model = RecoveryViewModel(session: editor.session)
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let scrapRow = try #require(rows.first { $0.id == released })
            await model.putBack(scrapRow)

            #expect(model.lastError == nil)
            let receipt = try #require(model.receipt)
            #expect(receipt == RecoveryCopy.putBackAtEnd(.pool))
            #expect(receipt.contains("scraps"), "it names where it actually went")
            #expect(!receipt.contains("note"),
                    "and never calls the scraps area a note — the row-26 defect")

            // A NOTE's block on the same road still says "note", which is the
            // guard against a fix that simply renamed the sentence.
            let fromNote = try await editor.session.runner.run {
                (ops: Operations) -> String in
                let post = try ops.createPost(title: "Real note")
                let one = try ops.newBlock(in: post.id, text: "first")
                let two = try ops.newBlock(in: post.id, text: "second")
                _ = try ops.merge(one.block.id, two.block.id)
                try ops.deleteBlock(one.block.id)
                return one.block.id
            }
            let after: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            await model.putBack(try #require(after.first { $0.id == fromNote }))
            #expect(model.receipt == RecoveryCopy.putBackAtEnd(.post))
            #expect(model.receipt?.contains("note") == true)
        }
    }

    /// The other half of the check, pinned as the FACT it rests on: nothing
    /// puts a pool CONTAINER in the Trash, so no row can call one a note.
    /// If a pool-deleting door is ever built, this goes red and its Trash
    /// story has to be designed with it.
    @Test func noDoorPutsAPoolContainerInTheTrash() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let poolID = try await editor.session.runner.run { (ops: Operations) -> String in
                let pool = try ops.createPool(title: "Scraps")
                _ = try ops.newBlock(in: pool.id, text: "a loose sentence")
                try ops.deleteContainer(pool.id)
                return pool.id
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(!rows.contains { $0.id == poolID },
                    "the note arm is fenced to kind='post' — a pool never lists")
            #expect(rows.allSatisfy { $0.kind != .note },
                    "and its scraps rode the cascade, so nothing strays either")
        }
    }
}

@MainActor
@Suite("The Trash surface, block archive & the batch-6 riders (13j)")
struct TrashSurfaceTests {
    // MARK: - The clock, where she reads it

    /// The row's words: a countdown for deleted things, the promise of NO
    /// countdown for archived ones — one of the two, never both, never
    /// neither (her round-3 + round-7 distinction, rendered).
    @Test func theCountdownWordsAreTheWindowsOwnAnswer() {
        #expect(TrayPath.daysLeftLabel(30) == "30 days left")
        #expect(TrayPath.daysLeftLabel(1) == "1 day left")
        #expect(TrayPath.daysLeftLabel(0) == "leaves today")
        #expect(TrayPath.archivedForever.contains("no clock"))
        // The tray's two block sections wear the distinction the labels
        // above make: one section says the clock in its header, the other
        // says there is none. (This asserted the single "Deleted & archived"
        // header until her G5 ruling split it — the CLAIM is unchanged and
        // is now checked at its strongest in
        // `NoteTrayTests.theTraysSectionsNameOnlyStatesTheProductCanProduce`.)
        #expect(TrayPath.leavingSection.contains("\(TrashWindow.days)-day"))
        #expect(TrayPath.archivedSection.contains("no clock"))
        // The Trash surface names the window in words, so a countdown is
        // never a bare threat.
        #expect(RecoveryPath.windowNote.contains("30 days"))
        #expect(RecoveryPath.trashSection == "Trash")
    }

    /// GRADUATED at batch 6b (a consequential pin edit, annotated in place
    /// — the batch-2/3 precedent): this pin shipped at batch 6 asserting NO
    /// purge door existed, because their backing (the sync-visible purge
    /// intent) was schema-shaped and STOP-gated. Batch 6b built the backing
    /// (v1_14 + the janitor), so the claim graduates to its ruled form: the
    /// doors EXIST, they are REGISTRY-DECLARED, and the Trash surface is
    /// their ONLY renderer, forever (her round-3 rider — "never accidental
    /// full delete from within a note"). The surface-walk union in
    /// `CapabilityRegistryTests` enforces the only-renderer half by
    /// construction; `TrashPurgeDoorsTests` carries the doors' behavior.
    @Test func thePurgeDoorsExistAndLiveInTheTrashOnly() {
        #expect(RecoveryView.surfaceCapabilities.contains(.deleteNow))
        #expect(RecoveryView.surfaceCapabilities.contains(.emptyTrash))
        for capability in CapabilityRegistry.all
        where capability.id == .deleteNow || capability.id == .emptyTrash {
            #expect(capability.doors == [.surface],
                    "\(capability.id): a purge act may never grow a menu/bar/palette door — in-Trash only is her rider's letter")
            #expect(capability.unavailableNote.contains("Trash"))
        }
    }

    // MARK: - The listing's face

    @Test func theTrashListsEveryKindWithItsContextAndOneVerb() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
                let book = try ops.createReading(name: "orbit", kind: .curated)
                try ops.deleteReading(book.id)
                let doomed = try ops.createPost(title: "doomed")
                try ops.deleteContainer(doomed.id)
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            #expect(Set(model.trash.map(\.kind)) == [.block, .book, .note])
            // Every row wears a countdown read from the session's own clock.
            for row in model.trash {
                #expect(model.daysLeft(row) == 30, "deleted just now — the full window")
            }
            // The block row carries its note's context and the note is live,
            // so the open-there door has something to open.
            let blockRow = try #require(model.trash.first { $0.kind == .block })
            #expect(blockRow.noteID == editor.postID)
            #expect(blockRow.noteIsDeleted == false)
            #expect(RecoveryPath.rowKind(.preservedOriginal) == "preserved original")
        }
    }

    @Test func putBackFromTheTrashUsesEachKindsOwnRoad() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(blockID) }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            await model.putBack(try #require(rows.first))
            #expect(model.lastError == nil)
            let live: [String] = try await editor.database.read { db in
                try Queries.renderPost(db, containerID: editor.postID).map(\.blockID)
            }
            #expect(live.contains(blockID), "the block is back in its note")
        }
    }

    /// **PUT BACK SAYS WHERE IT LANDED HERE TOO** — the hoist of the drift
    /// §49's MAJOR named (mobile round 2, batch 4.5b).
    ///
    /// The phone's Trash shipped a near-verbatim copy of `RecoveryViewModel`
    /// and it had already diverged in its first week, in exactly one place:
    /// the phone read `restoreBlock`'s LANDING and told her where the block
    /// went, while this model wrote `_ = try ops.restoreBlock(…)` and threw
    /// the answer away — so Put back landed **silently on the Mac**, even
    /// though `RecoveryView` renders `receipt` right beside `lastError`. Two
    /// recovery surfaces answering *"where did it go?"* two different ways is
    /// what M-C forbids, and shared WORDS could not have prevented it because
    /// the divergence was one layer under them, in the decision about which
    /// word to say. Both platforms now run `TrashPutBack`.
    ///
    /// **Red on old:** with the discarding `_ = try ops.restoreBlock(…)`
    /// restored, `receipt` is nil and this pin fails.
    @Test func putBackOnTheMacAlsoSaysWhereItLanded() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(blockID) }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            await model.putBack(try #require(rows.first))
            #expect(model.lastError == nil)
            #expect(model.receipt == RecoveryCopy.putBackWhereItWas,
                    "the Mac repeats the op's own answer, exactly as the phone does")
        }
    }

    /// **THE A1-MAJOR-1 PIN (13l Act 1 — red-on-old).** The hoisted put-back
    /// read `restoreBlock`'s landing but DISCARDED `restoreVariant`'s status
    /// (`case .take: _ = try ops.restoreVariant(item.id)`) and fell to the
    /// generic receipt — so a take that comes back ARCHIVED, into its block's
    /// archived listing, was told to her as *"Take put back."*, which sends
    /// her to the fan to look for something that is not there.
    ///
    /// **The row is reachable, and this pin proves each step:** `deleteVariant`
    /// accepts an archived take (I10's `ensureNotLastActive` counts only
    /// ACTIVE takes), `Queries.trash` lists deleted takes with no status
    /// filter, and the restore is the ruled exact flip (#68(b)) — so the take
    /// revives archived. The Mac's sibling door (`BlockPastModel.putBackTake`)
    /// has read the op's answer since 13j ladder A's A3; this door re-shipped
    /// the class the hoist exists to kill.
    ///
    /// **Red on old:** with `_ = try ops.restoreVariant(item.id)` restored,
    /// `receipt` is `RecoveryCopy.putBackReceipt(.take)` and the first
    /// expectation fails.
    @Test func putBackOfAnArchivedTakeFromTheTrashDoesNotClaimTheFan() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)

            let archived = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.archiveVariant(archived.id)
            try ops.deleteVariant(archived.id)

            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let takeRow = try #require(
                rows.first { $0.kind == .take && $0.id == archived.id },
                "an archived-then-deleted take IS a Trash row — no status filter")

            let model = RecoveryViewModel(session: editor.session)
            await model.putBack(takeRow)
            #expect(model.lastError == nil)
            #expect(model.receipt == RecoveryCopy.takeRestoredArchived,
                    "the receipt reads restoreVariant's own status — never \"the fan\" here")
            #expect(model.receipt != RecoveryCopy.putBackReceipt(.take))
            let status = try await editor.database.read { [id = archived.id] db in
                try Variant.fetchOne(db, key: id)?.status
            }
            #expect(status == .archived, "the exact flip stands — nothing un-archived")

            // …and an ACTIVE deleted take keeps the plain receipt, unchanged:
            // the fix reads the answer, it does not reword the common road.
            let active = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(active.id)
            let after: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let activeRow = try #require(after.first { $0.kind == .take && $0.id == active.id })
            await model.putBack(activeRow)
            #expect(model.lastError == nil)
            #expect(model.receipt == RecoveryCopy.putBackReceipt(.take))
        }
    }

    // MARK: - Block archive (her round-7 ruling), where she meets it

    @Test func theWriteDoorArchivesTheCaretBlockAndSaysWhereItWent() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            editor.textView.setSelectedRange(NSRange(location: 2, length: 0))
            editor.model.updateCaretContext()
            await editor.model.archiveCaretBlock()
            try editor.reload()

            #expect(!editor.model.slots.map(\.blockID).contains(blockID),
                    "the note renders on without it — no view-level filtering needed")
            let archived: [String] = try await editor.database.read { db in
                try Queries.archivedBlocks(db, postID: editor.postID).map(\.blockID)
            }
            #expect(archived == [blockID])
            // The receipt names the door she can actually see: the note menu
            // item, never the ⌫ badge (which counts deleted only).
            let status = try #require(editor.model.statusMessage)
            #expect(status.contains(TrayPath.menuLabel))
            #expect(status.contains("no countdown"))
            // And the tray lists it with no clock.
            let counts: Queries.TrayCounts = try await editor.database.read { db in
                try Queries.trayCounts(db, postID: editor.postID, now: harnessNow)
            }
            #expect(counts.archived == 1)
            #expect(counts.deleted == 0)
        }
    }

    /// **A JUSTIFIED EDIT** (the post-13l polish round, ledger row 14 / F1 —
    /// her *"archive rides beside delete at every block door"*): the act
    /// gained the two doors the pass found its twin standing alone at — both
    /// bars' `block ▾` (`.bottomBar`) and Blocks mode's row menu
    /// (`.surface`). The claim this pin holds is unchanged and is now checked
    /// at more places: the act is declared once, everywhere it is rendered,
    /// and it is honestly grey with no note open.
    @Test func theArchiveActIsDeclaredWithAllItsDoors() {
        let capability = CapabilityRegistry.capability(.archiveBlock)
        #expect(capability.verb == "Archive Block")
        #expect(capability.scope == .block)
        #expect(capability.doors == [.menuBar, .contextMenu, .bottomBar, .surface])
        // It acts where blocks live, and is honestly grey with no note open.
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: .write, writeEditorAttached: true))
                == .act)
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: .takes)) == .act,
            "Takes is never behind Write (R118)")
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: nil)) == .unavailable)
    }

    @Test func theBlockContextMenuCarriesTheArchiveRow() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            editor.textView.setSelectedRange(NSRange(location: 2, length: 0))
            editor.model.updateCaretContext()
            let titles = editor.model.contextMenuItems().map(\.title)
            #expect(titles.contains("Archive Block"))
        }
    }

    // MARK: - The stranded original (her round-8b ruling)

    @Test func theDeleteReceiptNamesAnOriginalItJustStranded() async throws {
        try await withEditor(seedBlocks: ["First half. Second half.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let variantID = try #require(editor.model.slots.first?.variantID)
            let w = try await editor.session.runner.run { ops -> Operations.DivideWResult in
                _ = try ops.branchVariant(blockID, from: variantID)
                return try ops.divideW(blockID, cuts: [variantID: 12])
            }
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(w.first.block.id)
            }
            // One descendant still lives: nothing to say.
            #expect(await StrandedOriginals.note(
                session: editor.session, blockIDs: [w.first.block.id]) == nil)

            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(w.second.block.id)
            }
            let note = try #require(await StrandedOriginals.note(
                session: editor.session, blockIDs: [w.second.block.id]))
            #expect(note.contains("rides the Trash"))

            // …and the tray MOVES the row: out of the forever section, into
            // the clock-bearing one (the visible move her ruling asked for).
            // (Ladder B, B5 — annotated pin edit, claim unchanged: the
            // clocks query gained `now:` and answers FATES.)
            let clocks: [String: Queries.OriginFamilyFate] = try await editor.database.read { db in
                try Queries.originFamilyClocks(db, postID: editor.postID, now: harnessNow)
            }
            #expect(clocks[blockID] != nil)
            let stranded: [String] = try await editor.database.read { db in
                try Queries.strandedOriginals(db, now: harnessNow).map(\.id)
            }
            #expect(stranded == [blockID])
            // **A JUSTIFIED PIN EDIT** (the post-13l polish round, ledger row
            // 18 — her G3 ruling's PRESENTATION half, a ruled rewording and
            // never a relaxed pin). The CLAIM is unchanged: the moved row
            // wears a label that says it goes with its family. The words
            // changed because the old ones led with the model's own noun
            // ("preserved original") and left the "why" to be guessed; hers
            // reads as what happened to it and how long it is kept.
            #expect(TrayPath.goesWithItsFamily.contains("family"))
            #expect(TrayPath.goesWithItsFamily.contains("set aside"))
            #expect(!TrayPath.goesWithItsFamily.lowercased().contains("unplaced"))
        }
    }

    /// **THE COMPOUND DOORS SAY IT TOO** (13j batch 7 — traced while the
    /// deletion chapter was being written, fixed at both sites).
    ///
    /// Batch 6 wired the stranding sentence into the two SINGLE-block delete
    /// doors and left the compound ones without it — and the compound is the
    /// likeliest door to strand a preserved original: picking a divide's two
    /// successors together and deleting them in one gesture is precisely how
    /// a family's last live descendant goes. Her round-8b failure mode is
    /// someone believing "the ancestor being there in that one ancestor tray
    /// is their guaranteed backup", and a receipt that stayed silent in the
    /// very case that moves it is the J8 defect exactly.
    ///
    /// RED ON OLD (behavioral revert, run and recorded in the batch-7
    /// record): with both appends removed, Write's arm reported only
    /// "2 blocks deleted — …" and the board's the same; both halves of this
    /// test went red.
    @Test func bothMultiDeleteDoorsNameAnOriginalTheyJustStranded() async throws {
        try await withEditor(seedBlocks: ["First half. Second half.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let variantID = try #require(editor.model.slots.first?.variantID)
            let w = try await editor.session.runner.run { ops -> Operations.DivideWResult in
                _ = try ops.branchVariant(blockID, from: variantID)
                return try ops.divideW(blockID, cuts: [variantID: 12])
            }
            try editor.reload()

            // WRITE's compound: both successors picked, one gesture.
            for successor in [w.first.block.id, w.second.block.id] {
                let i = try #require(
                    editor.model.index.entries.firstIndex { $0.blockID == successor })
                #expect(editor.model.pickBlock(
                    atOffset: editor.model.index.range(ofEntryAt: i).location,
                    extending: false))
            }
            await editor.model.deleteSelectedBlocks()
            await editor.flush()
            let written = try #require(editor.model.statusMessage)
            #expect(written.hasPrefix(BlockSelectionCopy.deletedNote(2)))
            #expect(written.hasSuffix(BlockSelectionCopy.strandedOriginalNote(1)),
                    "the receipt names the original it just put on the clock: \(written)")

            // THE BOARD's compound: the same act, the same sentence. Put the
            // pair back first so the board has the same world to delete.
            try await editor.session.runner.run { (ops: Operations) in
                _ = try ops.restoreBlock(w.first.block.id)
                _ = try ops.restoreBlock(w.second.block.id)
            }
            let takes = TakesViewModel(session: editor.session, postID: editor.postID)
            takes.adopt(try await editor.database.read { [postID = editor.postID] db in
                try Queries.takesProjection(db, post: postID)
            })
            takes.toggleMergeSelection(w.first.block.id)
            takes.toggleMergeSelection(w.second.block.id)
            await takes.deleteSelectedBlocks()
            let spoken = try #require(takes.statusMessage)
            #expect(spoken.hasPrefix(BlockSelectionCopy.deletedNote(2)))
            #expect(spoken.hasSuffix(BlockSelectionCopy.strandedOriginalNote(1)),
                    "…and the board's door says the same thing: \(spoken)")
        }
    }

    // MARK: - The riders

    // **RETIRED — the surface it defended is gone** (the post-13l polish
    // round, batch 4, ledger row 17). `theHistorySheetStopsPayingForAnEmptyPastSection`
    // held 13j ladder A's R2-N2: the Takes bar's history SHEET stacked an
    // always-mounted past section with `spacing: 8`, so an empty section cost
    // 16 pt of nothing, and `pastSectionTopPadding` cancelled one gap. Her G2
    // ruling absorbed that sheet — and Write's inline strip with it — into the
    // Block History pane, whose regions render only when they have something
    // to say (a `Section` that is not built takes no gap at all). There is no
    // value left to hold and no spacing left to defend; retiring it is honest,
    // and keeping a pin over a deleted constant would not be.

    /// **The enum-dump straggler, worded** (the round-1 sanity pass's routed
    /// observation): `noRenderableVariant` is reachable through every
    /// structural door on a gap slot, and spoke "Refused: <enum>".
    @Test func theGapSlotRefusalSpeaksInsteadOfDumpingItsEnum() {
        let message = OpsRefusalCopy.message(
            for: OperationError.noRenderableVariant(blockID: "b1"))
        #expect(!message.contains("noRenderableVariant"), "no raw dump: \(message)")
        #expect(!message.contains("Refused:"))
        #expect(message.contains("no text here yet"))
    }

    // MARK: - The post-13l polish round (ledger row 2 — her A2 ruling)

    /// **A FILTERED VIEW IS NOT AN EMPTY TRASH.** Her words on the walk's
    /// P-5(b): *"it can say the trash is empty, but there should be a filters
    /// applied chip or something of the sort to make it clear."*
    ///
    /// The walk selected **Notes**, saw nothing, and read *"The Trash is
    /// empty"* — with a block sitting in it — while **Empty Trash…**
    /// disappeared along with the filtered rows, because both reads asked
    /// `model.trash`, which is filtered IN SQL.
    ///
    /// This drives the real observations: a block in the Trash, the filter on
    /// Notes, so the filtered listing really is empty and the unfiltered one
    /// really is not.
    ///
    /// **RED ON OLD** by behavioural revert — restore either shipped
    /// expression (`trashIsEmptyUnfiltered = trash.isEmpty` in
    /// `startTrashTotal`, or `!model.trash.isEmpty` inside
    /// `showsEmptyTrashDoor`) and this reds, reading back the empty claim and
    /// the vanished door.
    @Test func aKindFilterWithNoMatchesNeitherEmptiesTheTrashNorHidesItsDoor() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
            }
            let model = RecoveryViewModel(session: editor.session)
            model.kindFilter = .note

            // Both observations, driven for real — the filtered one and the
            // deliberately-unfiltered one.
            let filtered = Task { await model.startTrash() }
            let total = Task { await model.startTrashTotal() }
            defer { filtered.cancel(); total.cancel() }
            // Bounded settle, the `EditorHarness.settle` shape.
            for _ in 0..<400 {
                if !model.trashIsEmptyUnfiltered { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }

            #expect(model.trash.isEmpty, "no NOTE is in the Trash")
            #expect(!model.trashIsEmptyUnfiltered, "…but the Trash holds a block")

            // 1. The sentence says which two facts are true at once.
            let line = RecoveryCopy.trashEmptyLine(
                filteredBy: model.kindFilter,
                holdsOtherKinds: !model.trashIsEmptyUnfiltered)
            #expect(line != "The Trash is empty.", "it is not: \(line)")
            #expect(line.contains(RecoveryCopy.kindLabel(.note)))
            #expect(line.contains("filter is on"))

            // 2. The bulk door — over the WHOLE Trash — stays on screen.
            #expect(RecoveryView.showsEmptyTrashDoor(model),
                    "Empty Trash acts on the whole Trash — a kind filter cannot decide whether it exists")

            // 3. The chip stands, and it names the filter that is on.
            let chip = RecoveryCopy.filterAppliedChip(.note)
            #expect(chip.contains(RecoveryCopy.kindLabel(.note)))
        }
    }

    // MARK: - Ledger row 4 — the scraps editor's honesty (her A4 ruling)

    /// **ROW 4(a): a deleted SCRAP is told where it actually went.**
    ///
    /// The scraps editor composes the same bar and the same controller over a
    /// `kind='pool'` container, so deleting a scrap printed *"…then in **This
    /// Note's Tray** — the ⌫ door in **the note's bar**"* on a surface that
    /// is not a note and shows no ⌫ badge. The road a scrap really takes is
    /// the one the walk watched work: the Trash, labelled "from scraps".
    ///
    /// **RED ON OLD** by behavioural revert (drop the `home:` argument at
    /// both `EditorSurfaceController` delete sites, or the `.pool` arm in
    /// `deletedNote`): this reds on the pool assertions, reading back the
    /// note-bar road on a scrap.
    @Test func deletingAScrapNamesTheTrashAndNotTheNotesTrayDoor() {
        let scrap = BlockSelectionCopy.deletedNote(1, home: .pool)
        #expect(scrap.contains(RecoveryCopy.trashSection),
                "the road a scrap actually takes: \(scrap)")
        #expect(!scrap.contains(TrayPath.menuLabel),
                "the scraps area is not a note and has no note's tray door")
        #expect(!scrap.contains(TrayPath.doorPhrase),
                "…and no ⌫ badge in a note's bar")
        #expect(scrap.contains("\u{2325}\u{2318}Z"),
                "the immediate reversal is the same gesture wherever it lived")
        // The plural door speaks the same road.
        #expect(BlockSelectionCopy.deletedNote(3, home: .pool)
            .contains(RecoveryCopy.trashSection))

        // A NOTE's receipt is byte-identical to what it has always said —
        // `.post` is the default, so no shipped caller moved.
        #expect(BlockSelectionCopy.deletedNote(1, home: .post)
            == BlockSelectionCopy.deletedNote(1))
        #expect(BlockSelectionCopy.deletedNote(1).contains(TrayPath.doorPhrase))
    }

    /// **ROW 4(b): the Snippets row can get rid of the scrap it shows.**
    ///
    /// Her A4 ruling on the walk's P-8: right-clicking a scrap in the
    /// Snippets list offered exactly one row, "Tags…" — the only delete door
    /// was inside the scraps EDITOR's bottom bar, so throwing away a line you
    /// could already see meant opening the editor first.
    ///
    /// Driven through the model the row calls, so the pin covers the ACT and
    /// its receipt, not a menu string. **The #77 fence rides with it**: this
    /// door deletes a BLOCK, and the pool it lived in must still be live.
    ///
    /// **RED ON OLD:** `PoolViewModel.deleteScrap` does not exist pre-fix, so
    /// the behavioural revert is the door's own body — make it a no-op
    /// (return before the op) and the pin reds on the tombstone assertion,
    /// reading back a scrap that could not be deleted from its row.
    @Test func theSnippetsRowDeletesItsScrapAndNeverItsPool() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let (poolID, scrapID) = try await editor.session.runner.run {
                (ops: Operations) -> (String, String) in
                let pool = try ops.createPool(title: "Scraps")
                let scrap = try ops.newBlock(in: pool.id, text: "a loose sentence")
                return (pool.id, scrap.block.id)
            }
            let model = PoolViewModel(session: editor.session)
            await model.deleteScrap(scrapID)

            #expect(model.lastError == nil)
            let receipt = try #require(model.receipt)
            #expect(receipt == BlockSelectionCopy.deletedNote(1, home: .pool),
                    "it speaks the scraps road from the ONE home")

            let (blockGone, poolAlive) = try await editor.database.read { db in
                (try Block.fetchOne(db, key: scrapID)?.deletedAt != nil,
                 try Container.fetchOne(db, key: poolID)?.deletedAt == nil)
            }
            #expect(blockGone, "the scrap really went")
            #expect(poolAlive,
                    "#77's fence: no door may tombstone the scraps area itself")

            // …and it rows in the Trash, which is the road the receipt named.
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            #expect(rows.contains { $0.id == scrapID && $0.kind == .block })
        }
    }

    /// **ROW 4(c): the block's own context menu carries BOTH verbs.**
    ///
    /// It shipped with **Archive Block** and no delete beside it — the two
    /// acts that exist to be told apart (one starts the 30-day clock, one
    /// keeps the block forever), and only one of them was on the door you
    /// reach by right-clicking the block itself.
    ///
    /// The second half is not decoration: with ONE block picked,
    /// `deleteVerb(picked: 1)` is the string "Delete Block", so rendering the
    /// caret row beside the selection row would put two identically-worded
    /// rows on one menu aiming at two different targets.
    ///
    /// **RED ON OLD** by behavioural revert (drop the `picked.isEmpty` arm):
    /// this reds on the first assertion, reading back a menu that can archive
    /// a block but not delete it.
    @Test func theBlockContextMenuCarriesDeleteBesideArchive() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            editor.textView.setSelectedRange(NSRange(location: 2, length: 0))
            editor.model.updateCaretContext()

            let verb = CapabilityRegistry.capability(.deleteBlock).verb
            let titles = editor.model.contextMenuItems().map(\.title)
            #expect(titles.contains(verb), "menu was \(titles)")
            #expect(titles.contains("Archive Block"), "…beside the verb it is told apart from")
            #expect(titles.filter { $0 == verb }.count == 1)

            // With a selection standing, the SELECTION's row is the one — and
            // it is still exactly one delete row.
            #expect(editor.model.pickBlock(atOffset: 2, extending: false))
            let picked = editor.model.contextMenuItems().map(\.title)
            #expect(picked.filter { $0 == verb }.count == 1,
                    "never two identically-worded rows: \(picked)")
        }
    }

    /// The other two readings of the same sentence, so the fix cannot
    /// over-correct into never saying the plain truth: with no filter, and
    /// with a filter over a genuinely empty Trash, "The Trash is empty" is
    /// what it says.
    @Test func anEmptyTrashStillSaysSoWithOrWithoutAFilter() {
        #expect(RecoveryCopy.trashEmptyLine(filteredBy: nil, holdsOtherKinds: false)
                == "The Trash is empty.")
        #expect(RecoveryCopy.trashEmptyLine(filteredBy: .block, holdsOtherKinds: false)
                == "The Trash is empty.",
                "a filter over an empty Trash is still an empty Trash")
        // …and an unfiltered listing never reaches the narrowed wording, even
        // if something is somehow waiting (the guard's first clause).
        #expect(RecoveryCopy.trashEmptyLine(filteredBy: nil, holdsOtherKinds: true)
                == "The Trash is empty.")
    }
}
