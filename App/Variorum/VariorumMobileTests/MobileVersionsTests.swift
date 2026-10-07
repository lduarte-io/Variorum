//
//  MobileVersionsTests.swift
//  VariorumMobileTests
//
//  **NOTE ▸ VERSIONS — the phone's fourth place** (round 2, batch 6c;
//  MobileSoul PL-14(f), `mobile-round-2.md` §69.6).
//
//  Until this batch the phone had NO Versions face while all three of its
//  operations were already core — so her saved moments existed on the phone
//  and were unreachable from it. Every pin here MOUNTS THE REAL SURFACE AND
//  DRIVES THE REAL CONTROL (§15's trap (b)), and every confirm is asserted
//  as a live `UIAlertController` and then driven through its own installed
//  action, which is the edge batch 4's BLOCKER lived in.
//
//  **The three verbs are pinned to HER RATIFIED shapes, not to taste:**
//  Restore CONFIRMS (#80(d), her words *"i like restore having a confirm"*),
//  Promote is FAST WITH NO CONFIRM (#80(c), *"promote having no confirm"*),
//  Delete confirms and goes to the Trash for its 30 days.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func saveAMoment(_ session: AppSession, of postID: String) async throws {
    try await session.runner.run { ops in try ops.saveNoteVersion(postID) }
}

@MainActor
@Suite("Mobile Versions — the note's moments (batch 6c)")
struct MobileVersionsTests {
    // MARK: - The door (the design record's finding 2 — the grain pairing)

    /// **THE NOTE ⋯ CARRIES THE NOTE'S TWO TIME CONTROLS.** The Mac teaches
    /// the two sizes of moment with two chords (⌘S = this take's, ⌘⇧S = this
    /// note's); the phone has no chord culture, so the teaching lives in its
    /// two ⋯ menus — block ⋯ = Commit Take + Block History…, note ⋯ = Save a
    /// Version + Versions…. Driven on the real masthead door and the real
    /// sheet rows.
    @Test func theNoteMenuCarriesBothTimeControls() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["A note with moments."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: editor)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains(VersionsPath.saveVerb), "labels were \(labels)")
                #expect(labels.contains(VersionsPath.menuLabel), "labels were \(labels)")
                // The note's ⋯ holds the NOTE grain. The take's savepoint
                // door is the BLOCK's ⋯, and it must not have wandered here
                // — two menus, two grains, is the whole teaching.
                #expect(!labels.contains(BlockHistoryPath.name))
            }
        }
    }

    /// **THE VERSIONS… ROW REALLY OPENS THE ROOM.** The row dismisses the
    /// sheet and asks the shell to push — the settings-sheet grammar, a
    /// proven road on this app rather than a sheet-over-sheet race.
    @Test func theVersionsRowReallyAsksTheShellToPush() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Push me."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            let pushed = LockIsolatedBox(false)
            try await withHostedSurface(
                MobileWriteScreen(
                    session: session, postID: postID,
                    onOpenVersions: { pushed.value = true }, editor: editor)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate(VersionsPath.menuLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(30)
            }
            #expect(pushed.value, "the row really opens the note's Versions")
        }
    }

    /// **SAVE A VERSION, DRIVEN ON THE REAL ROW**, and the store really
    /// holds a moment afterwards. The receipt is the shared sentence — the
    /// Mac and the phone must not describe one machinery two ways.
    @Test func theSaveVersionRowReallySavesAMoment() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["The words as they are."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: editor)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate(VersionsPath.saveVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }
            let moments = try await db.read { db in
                try Queries.noteVersions(db, of: postID)
            }
            #expect(moments.count == 1, "the note really has a moment now")
            #expect(moments.first?.blockCount == 1)
            #expect(editor.statusMessage == VersionsPath.saved)
        }
    }

    // MARK: - The listing and the reader (Q9 — the tap is Read)

    /// The room lists every moment, newest first, and each row leads with
    /// the DATE (V6 — no title mutation; the listing derives its display).
    @Test func theRoomListsEveryMoment() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["First words."])
            try await saveAMoment(session, of: postID)

            let model = MobileVersionsModel(session: session, postID: postID)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                #expect(model.versions.count == 1)
                let item = try #require(model.versions.first)
                let labels = surface.visibleLabels
                #expect(labels.contains {
                    $0.contains(MobileVersionsModel.rowTitle(item))
                }, "labels were \(labels)")
            }
        }
    }

    /// **THE TAP IS READ, AND THE PHONE COVERS RATHER THAN PEEKS** (Q9, and
    /// the design record's §5.1: the Mac reads a moment BESIDE the note in a
    /// side panel, which is exactly what the phone cannot have). Driving the
    /// row shows the moment's own words and the three verbs — and the verbs
    /// are on the MOMENT, never on the row, because four verbs do not fit a
    /// phone row.
    @Test func aRowsTapReadsTheMomentAndTheVerbsSitOnIt() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["It had been raining."])
            try await saveAMoment(session, of: postID)

            let model = MobileVersionsModel(session: session, postID: postID)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                let item = try #require(model.versions.first)
                // No verb is on the LISTING's row.
                #expect(!surface.visibleLabels.contains(VersionsPath.restoreVerb))

                #expect(surface.activate(
                    "\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                #expect(model.reading?.postID == item.postID)
                #expect(model.readingBlocks == ["It had been raining."])
                let labels = surface.visibleLabels
                #expect(labels.contains(VersionsPath.restoreVerb), "labels were \(labels)")
                #expect(labels.contains(VersionsPath.promoteVerb))
                #expect(labels.contains(VersionsPath.deleteVerb))
                // **NO PURGE DOOR** — her evolved rule: Delete Now lives on
                // trash surfaces only, and a moment's Delete is the ordinary
                // move-to-Trash road.
                #expect(!labels.contains(RecoveryCopy.deleteNowVerb))
                #expect(!labels.contains(RecoveryCopy.emptyTrashVerb))

                // And the way back is a real door.
                #expect(surface.activate(MobileVersionsView.backToListing))
                await surface.settle(20)
                #expect(model.reading == nil)
            }
        }
    }

    // MARK: - The three verbs, at her ratified shapes

    /// **RESTORE CONFIRMS** (#80(d), ratified: *"i like restore having a
    /// confirm"*) — and the confirm's whole point is that *"where it is now
    /// is saved first"* is readable BEFORE the press. The action is driven
    /// through its own installed handler with SwiftUI's write-back landed in
    /// the same turn (batch 4.5b's BLOCKER edge).
    @Test func restoreConfirmsAndThenMakesTheNoteSayItAgain() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["The old words."])
            try await saveAMoment(session, of: postID)
            // The note moves on.
            let slots = try await db.read { db in
                try Queries.renderPost(db, containerID: postID).compactMap(\.variantID)
            }
            try await session.runner.run { ops in
                for variantID in slots {
                    try ops.autosave(variantID, text: "The new words.", charDelta: 4)
                }
            }

            let model = MobileVersionsModel(session: session, postID: postID)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                let item = try #require(model.versions.first)
                #expect(surface.activate(
                    "\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))"))
                await surface.settle(40)
                #expect(surface.activate(VersionsPath.restoreVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                let alert = try #require(surface.presentedAlert,
                                         "Restore must really ask")
                #expect(alert.title == VersionsPath.restoreConfirmTitle)
                #expect(alert.message == VersionsPath.restoreConfirmDetail)
                #expect(alert.message?.contains("saved as a new version first") == true)
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("cancel"))

                // Asking is not doing.
                let stillNew = try await db.read { db in
                    try Queries.renderedText(db, containerID: postID)
                }
                #expect(stillNew == "The new words.")

                #expect(surface.tapAlertAction(
                    VersionsPath.restoreVerb,
                    writeBack: { model.restorePresented = false }),
                        "the confirm's real action must be drivable")
                await surface.settle(40)
            }

            let now = try await db.read { db in
                try Queries.renderedText(db, containerID: postID)
            }
            #expect(now == "The old words.", "the note says the moment again")
            // And the save-first promise the confirm made is kept: where it
            // WAS is a moment of its own now.
            let moments = try await db.read { db in
                try Queries.noteVersions(db, of: postID)
            }
            #expect(moments.count == 2, "the moment of NOW was saved first")
            #expect(model.status?.text == VersionsPath.restored)
            #expect(model.status?.isRefusal == false)
        }
    }

    /// **PROMOTE IS FAST AND ASKS NOTHING** — her ratified #80(c),
    /// verbatim: *"promote having no confirm"*. The pin asserts the ABSENCE
    /// of an alert on a surface it has just proven can present one (the
    /// restore pin above), and then that the moment really left the listing
    /// as a note of its own.
    @Test func promoteIsFastAndHasNoConfirm() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Take me out of the past."])
            try await saveAMoment(session, of: postID)

            let model = MobileVersionsModel(session: session, postID: postID)
            let versionID = try await db.read { db in
                try Queries.noteVersions(db, of: postID).first?.postID
            }
            let promoted = try #require(versionID)

            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                let item = try #require(model.versions.first)
                #expect(surface.activate(
                    "\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))"))
                await surface.settle(40)
                #expect(surface.activate(VersionsPath.promoteVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.presentedAlert == nil,
                        "Promote fires instantly — her ratified shape")
            }

            #expect(model.versions.isEmpty, "it has left this list for good")
            #expect(model.status?.text == VersionsPath.promoted)
            // (Row is not Sendable under main's stricter concurrency — carry
            // the two values out, not the Row; the VM-5 merge's mechanical fix.)
            let live: (archived: String?, locked: Int)? = try await db.read { db in
                try Row.fetchOne(
                    db, sql: "SELECT archived_at, locked FROM container WHERE id = ?",
                    arguments: [promoted])
                    .map { ($0["archived_at"], $0["locked"] ?? 0) }
            }
            let row = try #require(live)
            #expect(row.archived == nil, "unarchived — a note of its own")
            #expect(row.locked == 0, "and unsealed")
        }
    }

    /// **DELETE CONFIRMS AND GOES TO THE TRASH** — the ordinary
    /// move-to-Trash road (the ratified shape: *"deleting a single version
    /// from the listing should go into trash for 30 days"*). It is NOT a
    /// purge: the moment waits out its days like everything else, and the
    /// Trash row announces itself as a saved version (batch 6a's LR2-4).
    @Test func deleteConfirmsAndSendsTheMomentToTheTrash() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["A moment to lose."])
            try await saveAMoment(session, of: postID)

            let model = MobileVersionsModel(session: session, postID: postID)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                let item = try #require(model.versions.first)
                #expect(surface.activate(
                    "\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))"))
                await surface.settle(40)
                #expect(surface.activate(VersionsPath.deleteVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                let alert = try #require(surface.presentedAlert, "Delete must really ask")
                #expect(alert.message == VersionsPath.deleteHelp)
                #expect(alert.message?.contains("\(TrashWindow.days) days") == true)

                #expect(surface.tapAlertAction(
                    "Delete", writeBack: { model.deletePresented = false }),
                        "the confirm's real action must be drivable")
                await surface.settle(40)
            }

            #expect(model.versions.isEmpty)
            #expect(model.status?.text == VersionsPath.deleted)
            // It is IN THE TRASH, on the clock — never purged.
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            #expect(rows.contains { $0.isVersion }, "the moment is a Trash row")
            let intents = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? -1
            }
            #expect(intents == 0, "a moment's Delete is not a purge")
        }
    }

    // MARK: - The words

    /// **EVERY SENTENCE ABOUT THE MACHINERY COMES FROM
    /// `Shared/VersionsCopy.swift`** — the file exists precisely so the
    /// phone's face cannot re-write the sentences that describe one
    /// machinery.
    ///
    /// **THE PHONE-VOICED LINES ARE ENUMERATED, NOT COUNTED** (renamed and
    /// widened at the 6c fix wave — the cold review's m2: the batch shipped
    /// FOUR phone-voiced strings while this pin's name, its doc, and the
    /// batch record all said *"the one gap"*, and one of the three it did
    /// not name was a near-verbatim rewrite of a clause inside
    /// `VersionsPath.empty` — the same sentence living twice, which that
    /// shared file's header forbids in as many words).
    ///
    /// The four, and the rule each is held to:
    ///
    /// 1. `MobileVersionsModel.noVersions` — a **RE-VOICE**, and the one
    ///    line allowed to track a shared sentence closely: its whole job is
    ///    to say `VersionsPath.empty` without the ⌘⇧S a phone cannot offer
    ///    (the `noSavepoints` precedent; MobileSoul §4.4's no-redirect rule).
    /// 2. `MobileNoteActionsSheet.saveRowDetail` — **INVENTED**, because a
    ///    sheet row's subtitle is a face fact with no shared home. Held
    ///    clear of every shared sentence by the overlap check below.
    /// 3. `MobileNoteActionsSheet.versionsRowDetail` — composed from the
    ///    shared VERBS, so it cannot drift from them.
    /// 4. `MobileVersionsView.backToListing` — the reader's door, composed
    ///    from `VersionsPath.name`.
    @Test func theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed()
        async throws {
        #expect(VersionsPath.name == "Versions")
        #expect(VersionsPath.saveVerb == "Save a Version")
        #expect(VersionsPath.menuLabel == "Versions\u{2026}")
        #expect(VersionsPath.openVerb == "Read")
        #expect(VersionsPath.restoreVerb == "Restore")
        #expect(VersionsPath.promoteVerb == "Promote")
        #expect(VersionsPath.deleteVerb == "Delete\u{2026}")

        // 1. The re-voiced empty line: the shared VERB, no chord.
        let empty = MobileVersionsModel.noVersions
        #expect(empty.contains(VersionsPath.saveVerb))
        #expect(!empty.contains("\u{2318}"), "no chord ever reaches the phone")
        #expect(VersionsPath.empty.contains("\u{2318}"),
                "the Mac's own line does name one — which is why this gap exists")

        // 3 and 4: composed, so their pieces are the shared ones by
        // construction rather than by resemblance.
        #expect(MobileNoteActionsSheet.versionsRowDetail
            .contains(VersionsPath.restoreVerb.lowercased()))
        #expect(MobileNoteActionsSheet.versionsRowDetail
            .contains(VersionsPath.promoteVerb.lowercased()))
        #expect(MobileVersionsView.backToListing.contains(VersionsPath.name))

        // 2 (and, as a class, every INVENTED line): none of them may be a
        // near-verbatim rewrite of a shared sentence. The measure is a run
        // of six or more consecutive words in common — the first draft's
        // save-row detail shared SEVEN with `VersionsPath.empty` (*"the
        // whole note as it is right now"*, one word off), which is the
        // shape this check exists to catch. The re-voiced empty line is
        // deliberately NOT in this set: tracking the shared sentence is its
        // entire purpose, and it is pinned above on its own terms.
        let invented = [
            MobileNoteActionsSheet.saveRowDetail,
            MobileNoteActionsSheet.versionsRowDetail,
            MobileVersionsView.backToListing,
        ]
        let shared = [
            VersionsPath.empty, VersionsPath.explainer, VersionsPath.restoreHelp,
            VersionsPath.promoteHelp, VersionsPath.deleteHelp, VersionsPath.saved,
            VersionsPath.restored, VersionsPath.promoted, VersionsPath.deleted,
            VersionsPath.restoreConfirmTitle, VersionsPath.restoreConfirmDetail,
        ]
        for phone in invented {
            for sentence in shared {
                let run = longestSharedWordRun(phone, sentence)
                #expect(run < 6, """
                    "\(phone)" re-writes a shared sentence (\(run) words in \
                    common with "\(sentence)") — say it in the phone's own \
                    words, or give the sentence a home in VersionsCopy.
                    """)
            }
        }
    }

    /// The empty room says the phone's line, and it says it on screen.
    @Test func anEmptyRoomInvitesTheFirstMoment() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Nothing saved yet."])
            let model = MobileVersionsModel(session: session, postID: postID)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                #expect(model.versions.isEmpty)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.contains(VersionsPath.saveVerb) },
                        "labels were \(labels)")
            }
        }
    }

    /// A refusal is CLASSED where it is produced and rendered in the alarm
    /// slot — never guessed from the text by the view (`RecoveryStatus`, the
    /// shared rule). A sealed note refuses a restore, in the family's own
    /// voice rather than a raw enum dump.
    @Test func aSealedNoteRefusesARestoreInTheFamilysVoice() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Sealed later."])
            try await saveAMoment(session, of: postID)
            let model = MobileVersionsModel(session: session, postID: postID)
            await model.load()
            let item = try #require(model.versions.first)
            try await session.runner.run { ops in try ops.lockPost(postID) }

            await model.confirmRestore(item)
            #expect(model.status?.isRefusal == true)
            // VM-5 whole-round pass, MINOR 3's rider: the phone's OWN seal
            // words (its button is Unlock Note), composed through the one
            // sealed-note sentence — never the Mac's "unseal". This pin used
            // to hold the shared home's Mac-worded literal; red on that tree.
            #expect(model.status?.text
                == SealedNoteCopy.sentence(act: "restore a version", words: .phone))
            #expect(model.status?.text
                == "This note is locked — unlock it to restore a version.")
        }
    }

    // MARK: - The 6c fix wave (the cold review's m1, m3, m4, n6)

    /// **THE META LINE SAYS EVERYTHING THE TITLE DOES NOT — AND THE
    /// COUPLING IT RESTS ON IS PINNED** (m1).
    ///
    /// `MobileVersionsModel.rowMeta` composes the shared meta pieces minus
    /// the one the row's title is already saying. The first draft dropped
    /// element 0 on the strength of the date being first — a positional
    /// coupling to an array whose contract promises no order and whose own
    /// doc names a live future that will edit it (13w's automated rotation
    /// renders in that same list). The composition now drops the title's
    /// piece BY NAME, and this pin holds the assumption underneath it out
    /// loud: if `VersionsPath.rowMeta` ever leads with something else, the
    /// third expectation here goes red and names the coupling instead of a
    /// row quietly losing its block count.
    ///
    /// **Honest about what it is: NEW COVERAGE, not red-on-old.** `rowMeta`
    /// had no pin at all — that absence IS the finding — and the drift it
    /// guards against cannot be staged from here, because staging it means
    /// editing `Shared/VersionsCopy.swift`, which is fenced.
    @Test func theRowsMetaSaysEverythingButTheTitle() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(
                session, blocks: ["The moment's very first words.", "And a second block."])
            try await saveAMoment(session, of: postID)
            let model = MobileVersionsModel(session: session, postID: postID)
            await model.load()
            let item = try #require(model.versions.first)

            let title = MobileVersionsModel.rowTitle(item)
            let meta = MobileVersionsModel.rowMeta(item)
            // The title's own piece never repeats in the line beneath it…
            #expect(!meta.contains(title), "meta was \(meta)")
            // …and everything else the shared meta says survives.
            #expect(meta.contains("2 blocks"), "meta was \(meta)")
            #expect(meta.contains("The moment's very first words."),
                    "the moment's first words lead the preview — meta was \(meta)")
            for piece in VersionsPath.rowMeta(item) where piece != title {
                #expect(meta.contains(piece), "\(piece) fell out — meta was \(meta)")
            }
            // The coupling, said out loud: a 13w reorder reds HERE.
            #expect(VersionsPath.rowMeta(item).first == title,
                    "the shared meta still leads with the date the title shows")
        }
    }

    /// **THE LISTING IS WINDOWED, AND THE WINDOW IS NEVER SILENT** (m3).
    ///
    /// This was the one new phone listing reading unbounded — every sibling
    /// takes `window + 1` and renders a visible marker, and
    /// `Queries.noteVersions` had carried its `limit` all along. *"Versions
    /// are hand-saved, so there are few"* is exactly the true-today that
    /// 13w's automated rotation un-makes.
    ///
    /// **RED-ON-OLD:** with the un-windowed read and no marker, both the
    /// count and the marker expectations fail.
    @Test func theVersionsListingIsWindowedAndSaysSo() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Many moments."])
            for _ in 0..<3 { try await saveAMoment(session, of: postID) }

            let model = MobileVersionsModel(session: session, postID: postID, window: 2)
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight)
            ) { surface in
                await surface.settle(40)
                #expect(model.versions.count == 2, "the window holds")
                #expect(model.truncated, "and the probe row says there are more")
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileRoomListing.truncationMarker(shown: 2)),
                        "labels were \(labels)")
            }
        }
    }

    /// **A FAILED MOMENT READ LANDS ON THE LISTING** (n6) — never in an
    /// empty reader wearing Restore, Promote and Delete over words she never
    /// saw. `read` opens the cover first so it appears immediately; a read
    /// that then refuses must take the cover back down with it.
    ///
    /// **The failure is INJECTED, and deliberately at the storage layer:**
    /// an in-memory world has no other way to make a read throw (a missing
    /// container renders as nothing, per the read-side gap rule — SyncSpec
    /// §5 — rather than raising). What is pinned is the surface's contract,
    /// never the injection.
    ///
    /// **RED-ON-OLD:** without `closeReader()` in the catch, `reading` stays
    /// set and the three verbs stand over an empty reader.
    @Test func aFailedMomentReadLandsOnTheListingNotInAnEmptyReader() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Readable."])
            try await saveAMoment(session, of: postID)
            let model = MobileVersionsModel(session: session, postID: postID)
            await model.load()
            let item = try #require(model.versions.first)

            // The injection: the render's own table, out from under it.
            try await db.write { db in
                try db.execute(sql: "ALTER TABLE container_block RENAME TO container_block_gone")
            }
            await model.read(item)

            #expect(model.reading == nil, "the reader closed rather than standing empty")
            #expect(model.readingBlocks.isEmpty)
            #expect(model.status?.isRefusal == true, "and the refusal is spoken")
        }
    }

    /// **THE VERSIONS… ROW OPENS THE ROOM THROUGH THE WHOLE SHELL** (m4).
    ///
    /// The row dismisses its sheet and then calls up the tree; the shipped
    /// comment justified that order by citing a "proven road on this app"
    /// which, traced, is DEBUG-only, unpinned, and a different shape (the
    /// shell flipping its own presentation flag and appending in one
    /// scope). No failure was ever observed — the CLAIM was the defect. So
    /// the road is driven instead of asserted: a real `MobileShellView`,
    /// the shelf's own Today door into a note, the real ⋯ sheet, the real
    /// row — and the Versions room really arrives.
    ///
    /// **RED-ON-OLD:** dropping the shell's `onOpenVersions:` wiring (the
    /// row keeps rendering — the door is optional by design) leaves the
    /// sheet dismissed and no room pushed.
    @Test func theVersionsRowOpensTheRoomThroughTheWholeShell() async throws {
        try await withEditorWorld { session, _ in
            let suite = "versions-shell-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let router = MobileShellRouter(defaults: defaults)

            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(50)
                // Into a note, by the shelf's own door.
                #expect(surface.activate(MobileShelfFaces.todayDoorSpoken),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(50)
                #expect(surface.activate(VersionsPath.menuLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                // The room really arrived: a note with no moments yet says
                // the phone's own empty line, and that line carries its
                // plain sentence as its label.
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileVersionsModel.noVersions),
                        "labels were \(labels)")
            }
        }
    }
}

/// The longest run of consecutive words two sentences share, case- and
/// punctuation-insensitive. Used by the vocabulary pin to tell a sentence
/// written in the phone's own voice from a rewrite of a shared one.
private func longestSharedWordRun(_ a: String, _ b: String) -> Int {
    func words(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    let left = words(a), right = words(b)
    guard !left.isEmpty, !right.isEmpty else { return 0 }
    // Ordinary longest-common-substring over word arrays.
    var previous = [Int](repeating: 0, count: right.count + 1)
    var best = 0
    for i in 1...left.count {
        var current = [Int](repeating: 0, count: right.count + 1)
        for j in 1...right.count where left[i - 1] == right[j - 1] {
            current[j] = previous[j - 1] + 1
            best = max(best, current[j])
        }
        previous = current
    }
    return best
}
