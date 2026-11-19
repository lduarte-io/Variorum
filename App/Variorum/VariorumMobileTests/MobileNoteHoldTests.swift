//
//  MobileNoteHoldTests.swift
//  VariorumMobileTests
//
//  VM-70 r1 (the VM-64 run, batch 6) — **the editor's hold on its note's
//  coordinator follows its screen**: the leaving gives it back as its last act
//  (after teardown's flush and the leaving savepoint), and a screen shown
//  again takes it back. The record is `notes/plans/fixes/vm-64-timing-and-lags.md`
//  (§5 batch 6 ▸ "Iteration r1"; §7 batch 6 ▸ "Iteration r1").
//
//  These drive the editor model through the SCREEN's own sequence — the
//  arrival's `takeAutosaveHold()`, the leaving's `teardown()` →
//  `savepointOnLeaving` → `releaseAutosaveHold(ifNotShownSince:)` with the
//  arrival count captured at `onDisappear` — so the roads a hosted screen
//  cannot be driven through in process (a destination COVERED by a push and
//  shown again) are held deterministically. The screen-level pins are
//  `MobileNoteOpenOnceTests`' hazard (b) tests.
//
//  This suite names the new hold API, so it does not compile against the
//  pre-fix tree and is set aside for the red-on-old build.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The screen's leaving, exactly (`MobileWriteScreen.onDisappear`'s task):
/// the arrival count captured first, then the flush, the savepoint, the
/// give-back.
@MainActor
private func leave(_ model: MobileEditorViewModel, _ session: AppSession) async {
    let shown = model.arrivalCount
    await model.teardown()
    await session.savepointOnLeaving(model.postID)
    model.releaseAutosaveHold(ifNotShownSince: shown)
}

/// The screen's arrival, its hold half (`MobileWriteScreen`'s `.task` first act).
@MainActor
private func arrive(_ model: MobileEditorViewModel) async {
    await model.takeAutosaveHold()
}

@MainActor
private func seed(_ session: AppSession) async throws -> (postID: String, variantID: String) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: "hold", profile: .blog)
    }
    let block = try await session.runner.run { ops in
        try ops.newBlock(in: post.id, text: "Base.", at: .end)
    }
    return (post.id, block.variant.id)
}

@MainActor
@Suite("VM-70 r1 — the editor's hold follows its screen", .serialized)
struct MobileNoteHoldTests {

    /// **A screen shown again after its leaving gave the hold back takes it
    /// back — and is wired to the coordinator it now records into.** The
    /// leaving dropped the entry (the only holder, clean), so the arrival is
    /// handed a freshly minted coordinator and ADOPTS it: it listens to it,
    /// the registry's flush walks reach what it records, her typing lands.
    @Test func aScreenShownAgainAfterItsLeavingTakesTheHoldBackAndIsWiredToIt() async throws {
        try await withEditorWorld { session, db in
            let note = try await seed(session)
            let start = session.openAutosaveCount
            let (model, storage) = makeEditor(session, postID: note.postID)
            await arrive(model)
            await model.arrive(focus: false)
            #expect(model.holdsAutosave && model.arrivalCount == 1)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1)
            let given = model.autosave

            await leave(model, session)
            #expect(!model.holdsAutosave, "the leaving gave the hold back")
            #expect(session.openAutosaveCount == start, "and the registry let the entry go")
            #expect(!model.observesAutosave, "teardown stopped listening")

            await arrive(model)
            #expect(model.holdsAutosave && model.arrivalCount == 2, "shown again, it holds again")
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1)
            #expect(model.autosave !== given, "the entry was minted again — and adopted")
            #expect(model.observesAutosave, "it listens to the coordinator it records into")

            #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "R"))
            #expect(session.hasPendingAutosave, "what it records is the registry's to flush")
            await session.flushEveryOpenPost()
            #expect(try await storedText(db, variantID: note.variantID) == "BaseR.")

            await leave(model, session)
            #expect(session.openAutosaveCount == start)
        }
    }

    /// **A screen shown again joins the coordinator another tab opened
    /// meanwhile — never a second one for the note.** The S3 ladder BLOCKER's
    /// class: two coordinators for one note could flush a stale buffer over
    /// a newer one. The leaving dropped the entry; the other tab's editor of
    /// the same note minted a new one; the re-shown editor adopts THAT one.
    @Test func aScreenShownAgainJoinsTheCoordinatorAnotherTabOpenedMeanwhile() async throws {
        try await withEditorWorld { session, db in
            let note = try await seed(session)
            let start = session.openAutosaveCount
            let (first, firstStorage) = makeEditor(session, postID: note.postID)
            await arrive(first)
            await first.arrive(focus: false)
            await leave(first, session)
            #expect(session.openAutosaveCount == start)

            let (second, _) = makeEditor(session, postID: note.postID)
            await arrive(second)
            await second.arrive(focus: false)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1)

            await arrive(first)
            #expect(first.autosave === second.autosave, "ONE coordinator for the note")
            #expect(session.autosaveHolderCount(forPost: note.postID) == 2)
            #expect(first.observesAutosave)

            #expect(typeEdit(first, firstStorage, range: NSRange(location: 4, length: 0), replacement: "J"))
            #expect(second.autosave.isDirty, "the other tab's editor sees the same pending text")
            await second.autosave.flushNow()
            #expect(try await storedText(db, variantID: note.variantID) == "BaseJ.")

            await leave(first, session)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1, "the other tab still holds it")
            await leave(second, session)
            #expect(session.openAutosaveCount == start)
        }
    }

    /// **A screen shown again BEFORE its leaving finished keeps its hold.** The
    /// leaving is parked on a held store (its savepoint's read waits); the
    /// screen arrives again meanwhile; when the leaving ends it gives nothing
    /// back — the arrival came after it began — so the shown editor still
    /// holds the coordinator it records into.
    @Test func aScreenShownAgainBeforeItsLeavingFinishedKeepsItsHold() async throws {
        try await withEditorWorld { session, db in
            let note = try await seed(session)
            let (model, _) = makeEditor(session, postID: note.postID)
            await arrive(model)
            await model.arrive(focus: false)

            let entered = LockIsolated(false)
            let gate = DispatchSemaphore(value: 0)
            let held = Task.detached {
                try await db.write { _ in
                    entered.setValue(true)
                    gate.wait()
                }
            }
            var released = false
            defer { if !released { gate.signal() } }
            var spins = 0
            while !entered.value, spins < 5000 {
                spins += 1
                try await Task.sleep(for: .milliseconds(1))
            }
            #expect(entered.value, "the store is held")

            let leaving = Task { await leave(model, session) }
            try await Task.sleep(for: .milliseconds(300))
            await arrive(model)
            #expect(model.arrivalCount == 2)

            released = true
            gate.signal()
            try await held.value
            await leaving.value
            #expect(model.holdsAutosave, "shown again before its leaving finished, it kept its hold")
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1)

            await leave(model, session)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 0)
        }
    }

    /// **…and it LISTENS to the coordinator it records into** (the VM-64
    /// ladder, round 1, finding 2). The same parked leaving: teardown has run —
    /// its last act stopped this editor listening — and the leaving waits in
    /// its savepoint on the held store when the screen arrives again. The
    /// arrival must wire the editor back to its coordinator even though it
    /// still holds it (no give-back happened), or a flush settle no longer
    /// bumps its write generation or applies a deferred projection, and the
    /// coordinator's errors no longer reach its status line — until a full
    /// leave-and-return. RED on the pre-fix `takeAutosaveHold`, which returned
    /// at its hold guard before the re-observe.
    @Test func aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator() async throws {
        try await withEditorWorld { session, db in
            let note = try await seed(session)
            let (model, storage) = makeEditor(session, postID: note.postID)
            await arrive(model)
            await model.arrive(focus: false)
            #expect(model.observesAutosave, "an arrived editor listens")

            let entered = LockIsolated(false)
            let gate = DispatchSemaphore(value: 0)
            let held = Task.detached {
                try await db.write { _ in
                    entered.setValue(true)
                    gate.wait()
                }
            }
            var released = false
            defer { if !released { gate.signal() } }
            var spins = 0
            while !entered.value, spins < 5000 {
                spins += 1
                try await Task.sleep(for: .milliseconds(1))
            }
            #expect(entered.value, "the store is held")

            let leaving = Task { await leave(model, session) }
            try await Task.sleep(for: .milliseconds(300))
            // The posture: teardown ran to its end (nothing was pending, so it
            // never waited) and the leaving is parked in its savepoint.
            #expect(!model.observesAutosave, "teardown stopped listening; the leaving waits on the store")
            #expect(model.holdsAutosave, "…and has not given the hold back")

            await arrive(model)
            #expect(model.arrivalCount == 2)
            #expect(model.observesAutosave, "shown again, it listens again — before the leaving ends")

            released = true
            gate.signal()
            try await held.value
            await leaving.value
            #expect(model.holdsAutosave, "the leaving gave nothing back (the screen arrived again)")
            #expect(model.observesAutosave, "and the editor still listens to the coordinator it records into")
            #expect(session.autosaveHolderCount(forPost: note.postID) == 1)

            #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "L"))
            #expect(session.hasPendingAutosave, "what it records is the registry's coordinator's")
            await session.flushEveryOpenPost()
            #expect(try await storedText(db, variantID: note.variantID) == "BaseL.")

            await leave(model, session)
            #expect(session.autosaveHolderCount(forPost: note.postID) == 0)
        }
    }

    /// **The order is the flush, the savepoint, THEN the give-back** — read off
    /// the model, not the store: the leaving's text lands and its savepoint
    /// lands while the hold is still held, and only the leaving's last act
    /// gives it back (batch 7's `MobileLeavingSavesOnceTests` read the same
    /// order off the store's own record).
    @Test func theLeavingGivesTheHoldBackOnlyAfterTheFlushAndTheSavepoint() async throws {
        try await withEditorWorld { session, db in
            let note = try await seed(session)
            let (model, storage) = makeEditor(session, postID: note.postID)
            await arrive(model)
            await model.arrive(focus: false)
            #expect(typeEdit(model, storage, range: NSRange(location: 4, length: 0), replacement: "O"))

            let shown = model.arrivalCount
            await model.teardown()
            #expect(model.holdsAutosave, "after the flush, still held")
            #expect(try await storedText(db, variantID: note.variantID) == "BaseO.")
            await session.savepointOnLeaving(note.postID)
            #expect(model.holdsAutosave, "after the savepoint, still held")
            let savepoints = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM commit_point WHERE variant_id = ? AND kind = 'auto'",
                    arguments: [note.variantID]) ?? 0
            }
            #expect(savepoints >= 1, "the savepoint landed")
            model.releaseAutosaveHold(ifNotShownSince: shown)
            #expect(!model.holdsAutosave && session.autosaveHolderCount(forPost: note.postID) == 0,
                    "the give-back is the last act")
        }
    }
}
