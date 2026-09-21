//
//  BlockHistorySealTests.swift
//  VariorumTests
//
//  13u4 UNIT S3 — **KnownIssues row 69: Block History's rename door OPENED
//  its name field under a SEALED note and refused only at ⏎.** The op has
//  refused correctly since the 13u3 ladder's R1-2 fix; what remained was the
//  FACE — she typed a name into a field that could never keep it, and the
//  ladder's round 2 correctly deferred it because *"the pane would need the
//  seal fact plumbed in"*.
//
//  It is plumbed now: the model WATCHES the note's header for as long as the
//  pane is up, and the door's branch is a fact on the model
//  (`renameOpensTheField`) rather than an `if` inside a private view body —
//  UNIT S1's own reason one file over: a claim about what a door offers has
//  to be checkable.
//
//  **What did NOT change, and it is the pane's grammar:** the door still
//  ACTS and still SPEAKS under a seal (Restore does exactly this), and the
//  operation's own refusal is still the backstop underneath. The only thing
//  gated is the FIELD.
//

import Foundation
import Testing
import Dependencies
import VariorumCore
@testable import Variorum

@Suite("Block History's rename door under a seal (13u4 UNIT S3, row 69)", .serialized)
@MainActor
struct BlockHistorySealTests {
    private func withSealedNote(
        sealed: Bool,
        _ body: @escaping (AppSession, BlockHistoryModel) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the sealed note")
            let minted = try session.operations.newBlock(in: post.id, text: "A paragraph.")
            _ = try session.operations.commit(minted.variant.id, kind: .manual)
            if sealed { try session.operations.lockPost(post.id) }
            let model = BlockHistoryModel(
                session: session, postID: post.id, blockID: minted.block.id,
                focusedVariantID: minted.variant.id)
            try await body(session, model)
        }
    }

    /// Polls the model's own watch — the observation is live, so the fact
    /// arrives on its own turn rather than inside the call that starts it.
    private func settleSeal(_ model: BlockHistoryModel, until wanted: Bool) async {
        let watching = Task { await model.watchSeal() }
        defer { watching.cancel() }
        for _ in 0..<200 {
            if model.sealed == wanted { return }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
    }

    /// THE ROW: under a seal the field does not open, and the door says the
    /// standing sentence instead of saying nothing.
    @Test func aSealedNoteKeepsTheNameFieldShutAndSaysWhy() async throws {
        try await withSealedNote(sealed: true) { _, model in
            await settleSeal(model, until: true)
            #expect(model.sealed, "the watch landed the note's own seal")
            #expect(!model.renameOpensTheField,
                    "RED ON OLD: the pane had no seal fact, so the field always opened")
            model.refuseRenameUnderSeal()
            guard case .refusal(let said) = model.status else {
                Issue.record("a door that does nothing speaks a REFUSAL (18i's kind grammar)")
                return
            }
            #expect(said == TrayRefusalCopy.sealed,
                    "the standing sentence — not new copy for this door")
        }
    }

    /// And the ordinary note is untouched: the field opens exactly as it has
    /// since 13u3 UNIT D.
    @Test func anUnsealedNoteStillOpensTheField() async throws {
        try await withSealedNote(sealed: false) { _, model in
            await settleSeal(model, until: false)
            #expect(!model.sealed)
            #expect(model.renameOpensTheField)
        }
    }

    /// **Why it is a WATCH and not a one-shot read.** She can unseal from the
    /// masthead with this pane open; a door that stayed shut until the pane
    /// was re-opened would be a capability she cannot find — the same lie as
    /// the field that could not keep her name, pointing the other way.
    @Test func unsealingWhileThePaneIsOpenGivesTheDoorBack() async throws {
        try await withSealedNote(sealed: true) { session, model in
            let watching = Task { await model.watchSeal() }
            defer { watching.cancel() }
            var sawSeal = false
            for _ in 0..<200 where !sawSeal {
                if model.sealed { sawSeal = true; break }
                try? await Task.sleep(nanoseconds: 5_000_000)
            }
            #expect(sawSeal, "the seal arrived")
            #expect(!model.renameOpensTheField)

            try session.operations.unlockPost(model.postID)
            var sawUnseal = false
            for _ in 0..<200 where !sawUnseal {
                if !model.sealed { sawUnseal = true; break }
                try? await Task.sleep(nanoseconds: 5_000_000)
            }
            #expect(sawUnseal, "and the unseal reached the pane without re-opening it")
            #expect(model.renameOpensTheField)
        }
    }

    /// The BACKSTOP is untouched: even driven past the face, the operation
    /// refuses a rename under a seal and the pane speaks it. (The face half
    /// is what this unit built; the op half has been right since R1-2.)
    @Test func theOperationStillRefusesUnderneath() async throws {
        try await withSealedNote(sealed: true) { session, model in
            let blockID = model.blockID
            let commit = try await session.database.read { db in
                try Queries.blockHistory(db, blockID: blockID, now: Date())
            }.savepoints.values.first?.first
            let savepoint = try #require(commit, "the fixture's own savepoint")
            await model.rename(savepoint, to: "a name it cannot keep")
            guard case .refusal = model.status else {
                Issue.record("the op's refusal is the backstop and must still fire")
                return
            }
        }
    }
}
