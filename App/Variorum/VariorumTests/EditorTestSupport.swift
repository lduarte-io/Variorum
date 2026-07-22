//
//  EditorTestSupport.swift
//  VariorumTests
//
//  Deterministic harness for editor tests: an in-memory store with the core
//  test dependencies (incrementing UUIDs, ticking clock), a real AppSession,
//  and — where a test drives the live pipeline — a REAL EditorTextView wired
//  through EditorSurfaceDelegate, so edits travel the production path:
//  shouldChangeTextIn → storage edit → didProcessEditing → index/autosave.
//
//  ── Test conventions worth knowing before you write a pin ──────────────
//
//  TYPE BOTH SIDES OF A NUMERIC `#expect` (13b Stage 4 gate + ladder round
//  3, NIT-B — the trap cost one green suite a false RED). `#expect`
//  decomposes its operands, and a mismatched pair like
//  `CGFloat == <Int literal sum>` resolves through implicit `AnyHashable`
//  promotion — where CGFloat skips the cross-type numeric canonicalization
//  Double gets: `AnyHashable(CGFloat(460)) == AnyHashable(460)` is FALSE
//  for bit-identical values (the Double twin is true). The fix is never a
//  tolerance: type the literal (`CGFloat(250 + 170 + 40)`) and keep exact
//  equality. Live example + trace: `CanvasAndPoolTests`'
//  `theGridStartsBelowThePositionedBoundingBox`.
//  The INVERSE is the dangerous direction and was swept at round 3: a
//  mismatched `#expect(a != b)` is silently TRUE — a pin that can never
//  fail. The sweep found the repo CLEAN of that shape; keep it clean by
//  typing both sides.
//

import AppKit
import Dependencies
import Foundation
import VariorumCore
@testable import Variorum

/// Deterministic RNG for fractional-index jitter (mirrors the core tests'
/// SeededGenerator — SplitMix64).
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

/// A slot literal for pure mapping tests.
func slot(
    _ blockID: String,
    variant variantID: String? = nil,
    text: String?,
    fan activeVariantCount: Int = 1,
    locked variantLocked: Bool = false
) -> Queries.RenderedBlock {
    Queries.RenderedBlock(
        blockID: blockID, placementID: "p-\(blockID)", position: "m",
        variantID: variantID ?? (text == nil ? nil : "v-\(blockID)"),
        text: text,
        activeVariantCount: activeVariantCount, variantLocked: variantLocked)
}

@MainActor
struct EditorHarness {
    let session: AppSession
    let database: AppDatabase
    let model: EditorViewModel
    let textView: EditorTextView
    let surfaceDelegate: EditorSurfaceDelegate
    let postID: String

    /// Loads the current store projection into the editor (the observation
    /// path, driven by hand for determinism).
    func reload() throws {
        let (slots, header) = try database.read { db in
            (try Queries.renderPost(db, containerID: postID),
             try Queries.containerHeader(db, containerID: postID))
        }
        model.adoptHeader(header)
        model.applyProjection(slots)
    }

    /// Types text at the caret through the REAL NSTextInputClient path.
    func type(_ text: String, at location: Int? = nil) {
        if let location {
            textView.setSelectedRange(NSRange(location: location, length: 0))
        }
        textView.insertText(text, replacementRange: textView.selectedRange())
    }

    /// Replaces a range through the real path (delete = empty replacement).
    func replace(_ range: NSRange, with text: String) {
        textView.insertText(text, replacementRange: range)
    }

    var documentText: String { textView.string }

    /// Waits for in-flight mints/autosaves to settle (bounded).
    func settle() async {
        for _ in 0..<2000 {
            if !model.mintInFlight && !model.autosave.isDirty { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// Flushes pending autosaves immediately.
    func flush() async {
        // A deferred cross-block compound (#11a / merge-then-edit) lands
        // first — its own flush + rewrite ride inside it.
        while let pending = model.pendingCrossBlockTask {
            await pending.value
            if model.pendingCrossBlockTask == nil { break }
            // A chained schedule replaced the handle; loop once more.
            if pending == model.pendingCrossBlockTask { break }
        }
        await model.autosave.flushNow()
        await settle()
    }

    /// The store's rendered slots, fresh.
    func storeSlots() throws -> [Queries.RenderedBlock] {
        try database.read { try Queries.renderPost($0, containerID: postID) }
    }
}

/// Runs `body` against a fresh in-memory store + live editor pipeline with
/// deterministic dependencies. `profile` seeds the post (journal = one_block).
@MainActor
func withEditor<T>(
    profile: Profile? = nil,
    seedBlocks: [String] = [],
    _ body: @MainActor (EditorHarness) async throws -> T
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
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "T", profile: profile)
        for text in seedBlocks {
            _ = try session.operations.newBlock(in: post.id, text: text)
        }
        let model = EditorViewModel(session: session, postID: post.id)
        // Deterministic tests: the idle-mint clock never fires on its own —
        // tests drive `idleMintTail()` explicitly.
        model.tailIdleSleep = { _ in throw CancellationError() }
        let (scrollView, textView) = EditorTextView.makeEditor()
        let surfaceDelegate = EditorSurfaceDelegate(model: model)
        surfaceDelegate.wire(to: textView)
        model.attach(textView: textView, scrollView: scrollView)
        let harness = EditorHarness(
            session: session, database: db, model: model,
            textView: textView, surfaceDelegate: surfaceDelegate, postID: post.id)
        try harness.reload()
        return try await body(harness)
    }
}
