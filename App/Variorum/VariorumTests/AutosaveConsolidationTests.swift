//
//  AutosaveConsolidationTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the N3 pins: ONE AutosaveCoordinator per open
//  post. The old shape minted one per view model (Editor / Takes /
//  BlockTOC — EditorViewModel.swift:37, TakesViewModel.swift:36,
//  BlockTOCView.swift:33), so with the Write takes panel open TWO
//  debounced pipelines ran over one post and could flush a STALE buffer
//  over a newer one — convergence rode two independent defer/echo systems
//  agreeing by luck of timing (Stage 0 survey §5.5, top risk 3).
//
//  Both pins are RED on the old shape (verified by behavioral revert of
//  the session-registry wiring): the identity pin because each VM owned
//  its own instance; the clobber pin because the second coordinator's
//  later flush landed the older text.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("Autosave consolidation (13b 1a, N3)")
struct AutosaveConsolidationTests {
    /// THE IDENTITY PIN: every surface editing one post shares the SAME
    /// coordinator instance; a different post gets a different one.
    @Test func everySurfaceOfOnePostSharesOneCoordinator() async throws {
        try await withWorld { session, _ in
            let postA = try session.operations.createPost(title: "A")
            _ = try session.operations.newBlock(in: postA.id, text: "alpha")
            let postB = try session.operations.createPost(title: "B")
            _ = try session.operations.newBlock(in: postB.id, text: "beta")

            let editor = EditorViewModel(session: session, postID: postA.id)
            let takes = TakesViewModel(session: session, postID: postA.id)
            let toc = BlockTOCViewModel(session: session, postID: postA.id)
            let other = TakesViewModel(session: session, postID: postB.id)

            #expect(editor.autosave === takes.autosave,
                    "Write and Takes share the post's ONE coordinator")
            #expect(takes.autosave === toc.autosave,
                    "the TOC shares it too")
            #expect(takes.autosave !== other.autosave,
                    "a different post gets its own")
            editor.teardown()
            takes.teardown()
            toc.teardown()
            other.teardown()
        }
    }

    /// THE CLOBBER PIN (the hazard itself): the takes panel records an
    /// edit for a variant; the editor then records NEWER text for the same
    /// variant; both surfaces flush, panel-last. Old shape: two
    /// coordinators — the panel's later flush lands the STALE text over
    /// the newer save. New shape: one pending entry per variant — the
    /// newest text wins regardless of flush order.
    @Test func interleavedSurfacesConvergeToTheNewestText() async throws {
        try await withWorld { session, db in
            let post = try session.operations.createPost(title: "shared")
            let minted = try session.operations.newBlock(in: post.id, text: "original")

            let takes = TakesViewModel(session: session, postID: post.id)
            takes.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            let editor = EditorViewModel(session: session, postID: post.id)

            // The panel's edit first…
            takes.paneEdited(variantID: minted.variant.id, newText: "older panel text")
            // …then the editor records NEWER text for the same variant
            // (the shape recordAutosave produces).
            editor.autosave.record(
                variantID: minted.variant.id, text: "newer editor text", charDelta: 5)

            // Flush editor-first, panel-last — the old shape's clobber order.
            await editor.autosave.flushNow()
            await takes.autosave.flushNow()

            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [minted.variant.id])
            }
            #expect(stored == "newer editor text",
                    "the newest text wins — no stale flush can clobber it (stored: \(stored ?? "nil"))")
            editor.teardown()
            takes.teardown()
        }
    }
}
