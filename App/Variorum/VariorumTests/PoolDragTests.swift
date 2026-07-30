//
//  PoolDragTests.swift
//  VariorumTests
//
//  Phase 10 Step 7 — the minimal pool's drag-into-draft: the UI path emits
//  EXACTLY the Phase 3 `poolDragCopy` (fresh block, copied variant(s),
//  `pool_copy` lineage edge, placement at the drop's boundary; commits
//  never copied; P stays in its pool), the drop-point → insertion mapping,
//  the ⌥-carries-the-fan modifier, and the no-text-on-the-pasteboard
//  discipline (review focus 6).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Pool drag (Phase 10 Step 7)")
struct PoolDragTests {
    /// Seeds a pool scrap (with a commit + a second take for the fan
    /// cases) beside the editor's post.
    @MainActor
    private func seedPool(_ h: EditorHarness) throws -> (poolID: String, scrapID: String) {
        let pool = try h.session.operations.createPool(title: "P")
        let scrap = try h.session.operations.newBlock(in: pool.id, text: "a loose idea")
        _ = try h.session.operations.commit(scrap.variant.id, kind: .manual)
        _ = try h.session.operations.branchVariant(scrap.block.id, from: scrap.variant.id)
        return (pool.id, scrap.block.id)
    }

    @Test func aDropEmitsExactlyPoolDragCopy() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            let (poolID, scrapID) = try seedPool(h)
            let before = try h.storeSlots()

            // Drop at offset 1 — the first half of "alpha" ⇒ before it.
            let consumed = h.model.poolDrop(blockID: scrapID, atOffset: 1, includeFan: false)
            #expect(consumed)
            await h.settle()
            for _ in 0..<200 {
                if try h.storeSlots().count == 3 { break }
                await Task.yield()
            }

            let after = try h.storeSlots()
            #expect(after.count == 3)
            let copy = after[0]
            #expect(copy.text == "a loose idea")
            #expect(copy.blockID != scrapID, "a COPY — never shared ownership")
            #expect(after[1].blockID == before[0].blockID)

            // Row-level: one pool_copy edge from the copy to the source;
            // commits never copied; the copy carries ONE variant (rendered
            // take only — includeFan false).
            let (edges, commitCount, variantCount, poolSlots) =
                try await h.database.read { [copyID = copy.blockID] db in
                    (try Row.fetchAll(
                        db,
                        sql: "SELECT * FROM edge WHERE source_block_id = ? AND deleted_at IS NULL",
                        arguments: [copyID]),
                     try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM commit_point c
                            JOIN variant v ON v.id = c.variant_id
                            WHERE v.block_id = ?
                            """,
                        arguments: [copyID]) ?? -1,
                     try Int.fetchOne(
                        db,
                        sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                        arguments: [copyID]) ?? -1,
                     try Queries.renderPost(db, containerID: poolID))
                }
            #expect(edges.count == 1)
            #expect(edges[0]["target_block_id"] == scrapID)
            #expect(edges[0]["type"] == "derived_from")
            #expect(edges[0]["origin_op"] == "pool_copy")
            #expect(commitCount == 0, "commits are never copied")
            #expect(variantCount == 1, "includeFan false copies the rendered take only")
            #expect(poolSlots.map(\.blockID) == [scrapID], "P stays in its pool")
        }
    }

    @Test func optionCarriesTheWholeFan() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let (_, scrapID) = try seedPool(h)
            // The modifier rides the callback parameter (the view reads ⌥).
            _ = h.model.poolDrop(
                blockID: scrapID, atOffset: 999, includeFan: true)
            await h.settle()
            for _ in 0..<200 {
                if try h.storeSlots().count == 2 { break }
                await Task.yield()
            }
            let after = try h.storeSlots()
            #expect(after.count == 2)
            let copy = after[1]  // offset past everything ⇒ .end
            let variants = try await h.database.read { [id = copy.blockID] db in
                try Queries.blockFan(db, blockID: id)
            }
            #expect(variants.count == 2, "the whole live fan came along")
        }
    }

    @Test func dropOffsetsMapToBlockBoundaries() async throws {
        try await withEditor(seedBlocks: ["aaaa", "bbbb"]) { h in
            // Document: "aaaa\nbbbb" — entries at 0..<4 and 5..<9.
            let slots = try h.storeSlots()
            let a = slots[0].blockID
            let b = slots[1].blockID
            #expect(h.model.insertPosition(forOffset: 0) == .before(a))
            #expect(h.model.insertPosition(forOffset: 1) == .before(a))
            #expect(h.model.insertPosition(forOffset: 4) == .after(a))
            #expect(h.model.insertPosition(forOffset: 6) == .before(b))
            #expect(h.model.insertPosition(forOffset: 9) == .after(b))
            #expect(h.model.insertPosition(forOffset: 999) == .end)
        }
    }

    @Test func aSealedPostRefusesTheDropVisibly() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let (_, scrapID) = try seedPool(h)
            try h.session.operations.lockPost(h.postID)
            try h.reload()
            let consumed = h.model.poolDrop(blockID: scrapID, atOffset: 0, includeFan: false)
            #expect(consumed, "consumed — never falls through to a text insert")
            #expect(h.model.statusMessage?.contains("sealed") == true)
            await h.settle()
            #expect(try h.storeSlots().count == 1, "nothing landed under the seal")
        }
    }

    /// **13f W12 — RED ON THE PRE-FIX CODE** (her report: *"trying to drag a
    /// standalone block into a post is just not working"*).
    ///
    /// Every other pin in this suite drives `performDragOperation` — or the
    /// model door under it — DIRECTLY. AppKit does not: it sends
    /// `draggingEntered` → `draggingUpdated` → **`prepareForDragOperation`** →
    /// `performDragOperation`, and stops at a `false` from the third.
    /// `NSTextView`'s own `prepareForDragOperation` answers false for a
    /// pasteboard carrying only the pool type, so the pool branch was dead
    /// through every real drag while the suite stayed green. This pin drives
    /// the WHOLE sequence — the batch-1 input-path rule applied to the drop
    /// path.
    ///
    /// DISCRIMINATING REVERT: delete `EditorTextView.prepareForDragOperation`
    /// ⇒ this fails at the prepare step (and the drop never runs), while every
    /// other pin in the suite still passes.
    @MainActor
    @Test func theWholeAppKitDropSequenceReachesThePoolBranch() async throws {
        for (label, textView) in [
            ("full editor", EditorTextView.makeEditor().1),
            ("inline editor", EditorTextView.makeInlineEditor()),
        ] {
            textView.frame = NSRect(x: 0, y: 0, width: 400, height: 300)
            textView.string = "alpha\nbeta"
            var landed: (blockID: String, offset: Int, includeFan: Bool)?
            textView.onPoolDrop = { blockID, offset, includeFan in
                landed = (blockID, offset, includeFan)
                return true
            }

            let pasteboard = NSPasteboard(
                name: NSPasteboard.Name("io.lduarte.variorum.tests.pooldrag.\(label)"))
            pasteboard.clearContents()
            pasteboard.setData(Data("scrap-1".utf8), forType: EditorTextView.poolBlockType)
            let info = FakePoolDraggingInfo(pasteboard: pasteboard)

            #expect(textView.registeredDraggedTypes.contains(EditorTextView.poolBlockType),
                    "\(label): the destination accepts the pool type at all")
            #expect(textView.draggingEntered(info) == .copy,
                    "\(label): entering with a scrap shows the copy cursor")
            #expect(textView.draggingUpdated(info) == .copy,
                    "\(label): …and keeps showing it")
            #expect(textView.prepareForDragOperation(info),
                    """
                    \(label): AppKit's THIRD step — on the pre-fix code \
                    NSTextView answered false here and performDragOperation \
                    was never sent, so the copy cursor promised a drop that \
                    could not happen
                    """)
            #expect(textView.performDragOperation(info),
                    "\(label): the drop is consumed")
            #expect(landed?.blockID == "scrap-1",
                    "\(label): …by the POOL branch, carrying the scrap's id")
            #expect(landed?.includeFan == false,
                    "\(label): no ⌥ held ⇒ the rendered take only")
        }
    }

    @Test func theDragPayloadIsTheBlockIDNeverTheText() async throws {
        let provider = PoolViewModel.dragProvider(blockID: "block-123")
        #expect(provider.registeredTypeIdentifiers
                == [EditorTextView.poolBlockType.rawValue])
        let data: Data = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Data, Error>) in
            _ = provider.loadDataRepresentation(
                forTypeIdentifier: EditorTextView.poolBlockType.rawValue
            ) { data, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data ?? Data())
                }
            }
        }
        #expect(String(data: data, encoding: .utf8) == "block-123",
                "the payload is the ID; the text copy is the operation's (review focus 6)")
    }
}

/// The minimum an `NSDraggingInfo` must be to drive an `NSView` destination's
/// own four-step sequence (13f W12). Deliberately AppKit-only: SwiftUI's
/// hosting drop path calls PRIVATE selectors on the dragging info
/// (`_lastDragDestinationOperation` — measured), so a fake like this can drive
/// an NSTextView destination and can never drive a `.dropDestination`. That
/// asymmetry is why this pin exists here and why the chapter-drag half of the
/// same class stays honestly unpinnable.
private final class FakePoolDraggingInfo: NSObject, NSDraggingInfo {
    private let pasteboard: NSPasteboard
    init(pasteboard: NSPasteboard) { self.pasteboard = pasteboard }
    var draggingDestinationWindow: NSWindow? { nil }
    var draggingSourceOperationMask: NSDragOperation { [.copy, .generic] }
    /// Inside "alpha\nbeta" — any point over the text; the offset the branch
    /// derives from it is `characterIndexForInsertion`'s, not this pin's claim.
    var draggingLocation: NSPoint { NSPoint(x: 12, y: 12) }
    var draggedImageLocation: NSPoint { .zero }
    var draggedImage: NSImage? { nil }
    var draggingPasteboard: NSPasteboard { pasteboard }
    var draggingSource: Any? { nil }
    var draggingSequenceNumber: Int { 1 }
    func slideDraggedImage(to screenPoint: NSPoint) {}
    func enumerateDraggingItems(
        options: NSDraggingItemEnumerationOptions, for view: NSView?,
        classes classArray: [AnyClass],
        searchOptions: [NSPasteboard.ReadingOptionKey: Any],
        using block: @escaping (NSDraggingItem, Int, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {}
    var numberOfValidItemsForDrop: Int {
        get { 1 }
        set {}
    }
    var draggingFormation: NSDraggingFormation {
        get { .default }
        set {}
    }
    var animatesToDestination: Bool {
        get { false }
        set {}
    }
    var springLoadingHighlight: NSSpringLoadingHighlight { .none }
    func resetSpringLoading() {}
}

// MARK: - 13b Stage 3, Batch 3D (N19): every pool is reachable

/// The N19 listing half: `activePool = pools.first` made every pool but
/// the OLDEST unreachable — "tutorial scraps" rendered nowhere on any
/// store with an older pool. The picker's selection drives the listing;
/// the oldest stays the default; a dead selection falls back.
/// (Red-on-old verified by behavioral revert: `activePool` ignoring
/// `selectedPoolID` turns the selection half red.)
@MainActor
@Suite("Pool selection (13b 3D — N19)")
struct PoolSelectionTests {
    @Test func everyPoolIsReachableAndSelectionDrivesTheListing() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
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
            let session = AppSession(database: db)
            let (older, newer, olderBlock, newerBlock) = try await session.runner.run { ops in
                let older = try ops.createPool(title: "scraps")
                let olderBlock = try ops.newBlock(in: older.id, text: "the old scrap")
                let newer = try ops.createPool(title: "tutorial scraps")
                let newerBlock = try ops.newBlock(in: newer.id, text: "the tutorial scrap")
                return (older.id, newer.id, olderBlock.block.id, newerBlock.block.id)
            }

            let model = PoolViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }

            @MainActor func poll(_ predicate: @MainActor () -> Bool) async {
                for _ in 0..<2000 {
                    if predicate() { return }
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(1))
                }
            }

            await poll { model.pools.count == 2 && !model.items.isEmpty }
            #expect(model.pools.map(\.id) == [older, newer], "oldest first — the listing order")
            #expect(model.activePool?.id == older,
                    "the oldest stays the DEFAULT (the pre-13b truth)")
            #expect(model.items.map(\.block.blockID) == [olderBlock])

            // The picker's door: the newer pool's scraps become reachable.
            model.select(poolID: newer)
            await poll { model.items.map(\.block.blockID) == [newerBlock] }
            #expect(model.activePool?.id == newer, "selection wins")
            #expect(model.items.map(\.block.blockID) == [newerBlock],
                    "the listing follows the selection — N19's unreachable pool is reachable")

            // A dead selection falls back to the oldest.
            try await session.runner.run { ops in
                try ops.deleteContainer(newer)
            }
            await poll { model.pools.count == 1 }
            #expect(model.activePool?.id == older, "a dead selection falls back")
            await poll { model.items.map(\.block.blockID) == [olderBlock] }
            #expect(model.items.map(\.block.blockID) == [olderBlock])
        }
    }
}
