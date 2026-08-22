//
//  MobileSavepointOnLeavingTests.swift
//  VariorumMobileTests
//
//  **PR7 — the phone's own on-leaving savepoint hook** (round 2, batch 4).
//  Her 13j words are the whole reason it matters: *"unless you've been
//  remembering to commit version history is kind of weak right now."*
//
//  13j built the ANSWER — `AppSession.savepointOnLeaving`, the sixth quiet
//  auto-commit occasion — and put it deliberately OUTSIDE the
//  `#if os(macOS)` fence so a second platform would owe a HOOK, never a
//  rule. The parity inventory then verified the hook did not exist: **zero
//  call sites in `VariorumMobile/`.**
//
//  The phone has two leavings, and on iOS the second one is the important
//  one — **backgrounding is the nearest thing to ⌘Q** (MobileSoul §5.1: the
//  app dies without warning), which is precisely the leaving the Mac's own
//  hook could never cover.
//
//  Red-on-old: with the savepoint leg removed from `performBackgroundFlush`
//  the recorder stays empty and no `kind:'auto'` savepoint exists — both
//  pins fail. Verified by behavioural revert.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func autoSavepointTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT c.text FROM commit_point c
                JOIN variant v ON v.id = c.variant_id
                JOIN container_block cb
                  ON cb.block_id = v.block_id AND cb.container_id = ?
                WHERE c.kind = 'auto'
                ORDER BY c.created_at, c.id
                """,
            arguments: [postID])
    }
}

@MainActor
@Suite("Mobile savepoint on leaving — PR7")
struct MobileSavepointOnLeavingTests {
    /// **Backgrounding leaves a savepoint behind.** The whole leg, end to
    /// end: an editor with unflushed keystrokes, the scene going to
    /// background, and afterwards a quiet `kind:'auto'` savepoint holding
    /// exactly what was typed.
    @Test func backgroundingLeavesASavepointForTheOpenNote() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Draft."])
            let (model, surfaceView) = await makeSurfaceEditor(session, postID: postID)
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)

            surfaceView.textView.selectedRange = NSRange(
                location: model.index.documentLength, length: 0)
            surfaceView.textView.insertText(" And more.")
            #expect(model.autosave.isDirty)
            #expect(try await autoSavepointTexts(db, postID: postID).isEmpty)

            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { await session.savepointOnLeaving($0) },
                grant: .none)

            // The text landed…
            #expect(try await storedBlockTexts(db, postID: postID) == ["Draft. And more."])
            // …and history is real without her remembering to commit.
            #expect(try await autoSavepointTexts(db, postID: postID)
                == ["Draft. And more."])
        }
    }

    /// **The ORDER is the leg's whole correctness.** `closeAutoCommit`
    /// reads `working_text` ROWS, so the flush must land first or the
    /// savepoint captures the text as of half a second before the last
    /// keystrokes (13e's copy-door class, arriving here). And the savepoint
    /// must precede the sync round, or its rows wait for the next
    /// foreground.
    @Test func theSavepointRunsAfterTheFlushAndBeforeTheSyncRound() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Draft."])
            let (model, surfaceView) = await makeSurfaceEditor(session, postID: postID)
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)
            surfaceView.textView.selectedRange = NSRange(
                location: model.index.documentLength, length: 0)
            surfaceView.textView.insertText(" typed")

            let seen = LockIsolatedBox<[String]>([])
            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { postID in
                    // What the store holds AT SAVEPOINT TIME is the oracle:
                    // if the flush had not landed, this read would show the
                    // pre-keystroke text.
                    let texts = (try? await storedBlockTexts(db, postID: postID)) ?? []
                    seen.value += texts
                    await session.savepointOnLeaving(postID)
                },
                grant: .none)

            #expect(seen.value == ["Draft. typed"],
                    "the flush had already landed when the savepoint ran")
        }
    }

    /// Every OPEN note is covered, and each exactly once — two tab stacks
    /// can hold the same note, and a leaving must not savepoint it twice.
    @Test func everyOpenNoteIsSavepointedOnceEach() async throws {
        try await withEditorWorld { session, _ in
            let a = try await makePost(session, blocks: ["A."])
            let b = try await makePost(session, blocks: ["B."])
            let editors = MobileLivenessAuthority()
            let (modelA, _) = await makeSurfaceEditor(session, postID: a)
            let (modelB, _) = await makeSurfaceEditor(session, postID: b)
            // The same note open on BOTH stacks — the shell's real shape.
            let (modelA2, _) = await makeSurfaceEditor(session, postID: a)
            await editors.register(modelA, tab: .shelf)
            await editors.register(modelB, tab: .library)
            await editors.register(modelA2, tab: .library)

            let seen = LockIsolatedBox<[String]>([])
            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { seen.value.append($0) }, grant: .none)

            #expect(Set(seen.value) == Set([a, b]))
            #expect(seen.value.count == 2, "deduped: \(seen.value)")
        }
    }

    /// The scene handler really passes the hook through — the routing, not
    /// just the routine (the round's own lesson: *a pin over a configured
    /// property proves nothing about what runs*).
    @Test func theScenePhaseHandlerCarriesTheSavepointThrough() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Draft."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)

            let seen = LockIsolatedBox<[String]>([])
            let work = mobileScenePhaseChanged(
                .background, editors: editors, sync: nil,
                savepoint: { seen.value.append($0) }, grant: .none)
            await work?.value
            #expect(seen.value == [postID])
        }
    }

    /// A leaving is not a moment to refuse at: a sealed note takes no
    /// savepoint and throws nothing (`closeAutoCommit`'s own quiet no-op),
    /// so the background flush can never be the thing that fails.
    @Test func aSealedNoteLeavesQuietlyWithNoSavepoint() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Sealed draft."], locked: true)
            let editors = MobileLivenessAuthority()
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await editors.register(model, tab: .shelf)

            let before = try await autoSavepointTexts(db, postID: postID)
            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { await session.savepointOnLeaving($0) }, grant: .none)
            #expect(try await autoSavepointTexts(db, postID: postID) == before)
        }
    }

    /// The cadence setting is honored, and it is the CORE's rule — the
    /// phone owes a hook, never a second reading of the enum. Under
    /// `.onlyOnCommit` a leaving writes nothing.
    @Test func theCadenceSettingGovernsTheLeaving() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Draft."])
            let (model, surfaceView) = await makeSurfaceEditor(session, postID: postID)
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)
            try await session.runner.run { ops in
                try ops.setSavepointCadence(.onlyOnCommit)
            }
            surfaceView.textView.selectedRange = NSRange(
                location: model.index.documentLength, length: 0)
            surfaceView.textView.insertText(" typed")

            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { await session.savepointOnLeaving($0) }, grant: .none)

            // The TEXT still lands (the flush is not the cadence's to gate)…
            #expect(try await storedBlockTexts(db, postID: postID) == ["Draft. typed"])
            // …and no savepoint was written.
            #expect(try await autoSavepointTexts(db, postID: postID).isEmpty)
        }
    }
}
