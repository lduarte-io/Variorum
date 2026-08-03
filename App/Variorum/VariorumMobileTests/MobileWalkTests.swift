//
//  MobileWalkTests.swift
//  VariorumMobileTests
//
//  THE MOBILE ACCEPTANCE SPINE (the execution plan's P-6 analog), BORN at
//  Stage 1 batch 1: a scripted walk over the phone's happy paths that
//  grows with every stage and rides every batch run — a broken walk step
//  is a regression by definition.
//
//  Batch 1's walk: open note → type → autosave lands → identity intact →
//  canary silent. It runs against the REAL `MobileEditorTextView` (the
//  TK2-explicit view, canary armed, storage delegate live) — typing goes
//  through the view's own `insertText` input path, so the walk exercises
//  the genuine UIKit editing machinery this simulator run can reach (the
//  full touch/keyboard pipeline stays the device round's, per the memo's
//  obligation 6).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile walk — the acceptance spine (S1 batch 1)")
struct MobileWalkTests {
    /// Walk step 1: today's entry, opened and written in the continuous
    /// editor, lands in the store with identity intact and the canary
    /// silent.
    @Test func walk1_openTypeAutosaveIdentityCanary() async throws {
        try await withEditorWorld { session, db in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let model = MobileEditorViewModel(
                session: session, postID: entry.container.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }

            // The REAL surface: TK2-explicit view in the keyboard-avoiding
            // container, canary armed at attach.
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            #expect(surface.textView.textLayoutManager != nil, "TK2-explicit construction holds")

            await model.loadOnce()

            // TYPE through the view's own input path.
            surface.textView.insertText("Walked and wrote.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()

            // The autosave landed (one-block journal semantics).
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote."])

            // Typing continues into the minted block.
            surface.textView.insertText(" Then more.")
            await model.awaitMintSettle()
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote. Then more."])
            let blockCount = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block") ?? -1
            }
            #expect(blockCount == 1, "a journal entry is ONE block")

            // Identity intact: the projection agrees with the index
            // authority everywhere (the obligation-1 audit ran after every
            // edit), and the surface never desynced.
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(EditorDocument.blockID(at: 0, in: surface.textView.textStorage) != nil)

            // Canary silent: TK2 never fell back across the whole walk.
            #expect(!surface.textView.canaryFired)
            #expect(model.canaryMessage == nil)

            // No refusal spoke during the happy path.
            #expect(model.statusMessage == nil)

            // Teardown lands everything; the store holds exactly the walk's
            // bytes (the L9 contract riding the spine).
            await model.finish()
            #expect(try await storedBlockTexts(db, postID: entry.container.id)
                    == ["Walked and wrote. Then more."])
        }
    }

    /// Walk step 2: a multi-block note — typing past a paragraph
    /// crystallizes it; the walk's bytes are byte-stable through teardown.
    @Test func walk2_freshNoteCrystallizesWhileTyping() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "walk note", profile: .blog)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()

            surface.textView.insertText("First thought.\n")
            surface.textView.insertText("Second thought begins")
            await model.awaitMintSettle()

            // The completed paragraph crystallized; the trailing one is the
            // open tail until teardown.
            #expect(try await storedBlockTexts(db, postID: post.id) == ["First thought."])
            #expect(surface.textView.textStorage.string == "First thought.\nSecond thought begins")

            await model.finish()
            #expect(try await storedBlockTexts(db, postID: post.id)
                    == ["First thought.", "Second thought begins"])
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
            #expect(!surface.textView.canaryFired)
        }
    }
}
