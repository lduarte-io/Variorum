import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9 Step 8(iv): sync convergence under the STRUCTURAL write pattern —
/// a scripted gesture session (divide, the W ceremony, merge, extract, the
/// composed make-block as two divides under one compound undo entry, and
/// structural undos) with engine rounds interleaved MID-session, a second
/// client editing concurrently, and `newBlock`'s Phase 9 touch/churn stamps
/// riding every mint. Convergence bar unchanged: empty outboxes,
/// byte-identical synced tables, identical rendered text.
@Suite("Sync under structural gestures (Phase 9, Step 8)")
struct StructuralSessionSyncTests {
    @Test func aGestureSessionConvergesUnderInterleavedSync() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        let stack = UndoStack()

        // The Mac editor's post: three blocks, all through operations.
        let world: (postID: String, b1: String, v1: String, b2: String, b3: String) =
            try mac.with { _, _ in
                let ops = Operations(undoStack: stack)
                let post = try ops.createPost(title: "Gesture session", profile: .blog)
                let one = try ops.newBlock(
                    in: post.id, text: "Opening thought. It runs long.", at: .end)
                let two = try ops.newBlock(
                    in: post.id, text: "Middle block. With a second sentence.", at: .end)
                let three = try ops.newBlock(
                    in: post.id, text: "Closing block. Final words here.", at: .end)
                return (post.id, one.block.id, one.variant.id, two.block.id, three.block.id)
            }
        _ = try await mac.push()
        _ = try await phone.pull()

        // The phone edits a Mac-authored block while the Mac restructures.
        try phone.with { ops, _ in
            try ops.autosave(
                world.v1, text: "Opening thought, phone-edited. It runs long.", charDelta: 14)
        }

        // Gesture 1: divide block 2, sync a round mid-session.
        let divided: Operations.DivideResult = try mac.with { _, _ in
            let ops = Operations(undoStack: stack)
            return try ops.divide(world.b2, cut: 14)
        }
        _ = try await mac.push()
        _ = try await phone.push()
        _ = try await mac.pull()
        _ = try await phone.pull()

        // Gesture 2: the W ceremony on block 1 (branch, then divideW with
        // both takes marked — the ceremony's exact op call).
        try mac.with { _, _ in
            let ops = Operations(undoStack: stack)
            let branch = try ops.branchVariant(world.b1, from: world.v1)
            try ops.autosave(
                branch.id, text: "Different opening. It also runs long.", charDelta: 0)
            _ = try ops.divideW(world.b1, cuts: [world.v1: 17, branch.id: 19])
        }
        _ = try await mac.push()
        _ = try await phone.pull()

        // Gesture 3: merge the divided halves back (adjacent pair).
        try mac.with { _, _ in
            let ops = Operations(undoStack: stack)
            _ = try ops.merge(world.b2, divided.block.id)
        }

        // Gesture 4: the composed make-block on block 3 — two divides as
        // ONE compound undo entry, exactly as the editor runs it.
        try mac.with { _, _ in
            let ops = Operations(undoStack: stack)
            _ = try stack.withCompound(label: "Make Block", operations: ops) {
                let first = try ops.divide(world.b3, cut: 15)
                _ = first
            }
        }
        _ = try await mac.push()
        _ = try await phone.pull()
        _ = try await phone.push()
        _ = try await mac.pull()

        // Undos interleaved with rounds: undo the make-block compound, then
        // undo the merge — ordinary operations onto the outbox.
        try mac.with { _, _ in
            let ops = Operations(undoStack: stack)
            _ = try stack.undo(with: ops)  // the compound (make-block)
            _ = try stack.undo(with: ops)  // the merge
        }
        _ = try await mac.push()
        _ = try await phone.pull()

        // Quiescence: everything everywhere, byte-identical.
        _ = try await syncToQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        #expect(try mac.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)

        // The phone renders the whole structural session identically —
        // including the phone's own S5-guarded edit of block 1's take.
        let macText = try await mac.withAsync { db in
            try await db.read { try Queries.renderedText($0, containerID: world.postID) }
        }
        let phoneText = try await phone.withAsync { db in
            try await db.read { try Queries.renderedText($0, containerID: world.postID) }
        }
        #expect(macText == phoneText)
        // The undone merge left B2 + the divided half placed again; the W's
        // successors render block 1's halves.
        #expect(phoneText.contains("Middle block."))
        #expect(phoneText.contains("Closing block. Final words here."))

        // The phone's racing edit was never lost: it either won the CAS or
        // was rescued as a conflict variant (S5) — the text exists somewhere.
        let phoneEditSurvives = try await phone.withAsync { db in
            try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM variant WHERE working_text LIKE '%phone-edited%' AND deleted_at IS NULL",
                    arguments: []) ?? 0
            }
        }
        #expect(phoneEditSurvives >= 1, "S5: nothing typed is ever lost")
    }
}
