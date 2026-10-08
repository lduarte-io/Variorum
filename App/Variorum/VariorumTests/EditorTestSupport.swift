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

/// A slot literal for pure mapping tests. `archived` is the count of
/// ARCHIVED takes on the block (13c Stage 1 ladder, R1-1) and `comments`
/// the count of live block comments (R2-1) — neither is in the fan, both
/// are prose the slot does not show; the default of none is the ordinary
/// case and any test that means otherwise says so.
func slot(
    _ blockID: String,
    variant variantID: String? = nil,
    text: String?,
    fan activeVariantCount: Int = 1,
    archived archivedVariantCount: Int = 0,
    comments commentCount: Int = 0,
    locked variantLocked: Bool = false
) -> Queries.RenderedBlock {
    Queries.RenderedBlock(
        blockID: blockID, placementID: "p-\(blockID)", position: "m",
        variantID: variantID ?? (text == nil ? nil : "v-\(blockID)"),
        text: text,
        activeVariantCount: activeVariantCount,
        liveVariantCount: activeVariantCount + archivedVariantCount,
        commentCount: commentCount,
        variantLocked: variantLocked)
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
/// **The Mac harness world's "now"** (13j): the recovery queries take a
/// required clock, because the 30-day Trash window is what "in the Trash"
/// means. Every hosted world here stamps its fixtures from 2026-07-01, so a
/// listing asked as of this moment sees what the test just deleted — and a
/// test that wants the far side of the window passes its own date.
let harnessNow = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)

/// 13s closeout — the Study-default harness class as a NAMED PIN, for
/// harnesses that cannot route through `withEditor` (a suite's own session
/// helper; a pure-board test whose layout math reads `EditorDocument.baseFont`
/// through a computed property). Same mechanism as the factory block below:
/// save the process typography globals, begin process-fresh Terminal — the
/// state every calibrated constant assumed pre-13s — and `restore()`, always
/// in the caller's `defer`, puts them back as found. A harness that also
/// opens a store should pair this with `setThemeVoice(.terminal)` so any
/// in-test adoption keeps the calibrated voice.
@MainActor
struct TerminalMetricsPin {
    private let typography: EditorTypography.Resolved
    private let adopted: Bool

    init() {
        typography = EditorTypography.current
        adopted = EditorTypography.isAdopted
        EditorTypography.current = EditorTypography.resolve(
            voice: .terminal, inlineComments: false)
        EditorTypography.isAdopted = false
    }

    func restore() {
        EditorTypography.current = typography
        EditorTypography.isAdopted = adopted
    }
}

@MainActor
func withEditor<T>(
    profile: Profile? = nil,
    seedBlocks: [String] = [],
    _ body: @MainActor (EditorHarness) async throws -> T
) async throws -> T {
    // 13s closeout (the whole-target run's trace — the TakesEntryBand
    // idiom, 5787e3fe, applied at the family's ONE factory): the editor
    // harness is born PROCESS-FRESH. `EditorTypography.current` and its
    // `isAdopted` latch are process globals; since the Study no-voice
    // default (U1a piece 3), the first voiceless store a suite opens
    // adopts STUDY and leaves it set, so every LATER harness in the same
    // process — the next test in this very suite included — would measure
    // serif metrics its constants never assumed. Pre-13s a voiceless
    // store adopted Terminal, which IS process-fresh, so this block pins
    // the historical invariant rather than changing one; the globals go
    // back as found so a mixed batch's neighbours see what they saw.
    let foundTypography = EditorTypography.current
    let foundAdopted = EditorTypography.isAdopted
    defer {
        EditorTypography.current = foundTypography
        EditorTypography.isAdopted = foundAdopted
    }
    EditorTypography.current = EditorTypography.resolve(voice: .terminal, inlineComments: false)
    EditorTypography.isAdopted = false
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
        // The same closeout trace's second half: the store CARRIES the
        // Terminal voice row (the TakesEntryBand fixture's own shape), so
        // any adoption DURING a test — a theme store an attached view
        // starts, a landing's read — adopts Terminal, exactly what every
        // measurement in this family was calibrated against before the
        // Study no-voice default existed. A suite probing the default
        // itself builds its own voiceless store on purpose.
        try session.operations.setThemeVoice(.terminal)
        let post = try session.operations.createPost(title: "T", profile: profile)
        for text in seedBlocks {
            // **A FIXTURE MINT IS NOT A GESTURE** (13u1 UNIT 2). `newBlock`
            // joined AppSpec §9's structural-undo list at her ruling R-13u-3,
            // so every mint registers an entry — right for the doors she
            // presses, wrong for the blocks a harness lays down before the
            // act a test is actually about. A suite that counts `depth`
            // after building a three-block note is asserting something about
            // the OPERATION under test, not about how its fixture came to
            // exist, so the seed passes the same `registeringUndo: false` the
            // type-time crystallizers pass, for the same stated reason. Every
            // depth assertion in this target therefore reads exactly as it
            // did before the ruling.
            _ = try session.operations.newBlock(
                in: post.id, text: text, registeringUndo: false)
        }
        let model = EditorViewModel(session: session, postID: post.id)
        // Deterministic tests: the idle-mint clock never fires on its own —
        // tests drive `idleMintTail()` explicitly.
        model.tailIdleSleep = { _ in throw CancellationError() }
        // 13c 1E, same discipline: the phantom fix's debounce never fires
        // on its own — `LongBlockLayoutTests` drives
        // `runLongBlockLayoutPass()` explicitly, and every other suite's
        // geometry stays exactly what it measured before this batch
        // (notably `PhantomSpaceTests`, whose whole job is to characterize
        // the UN-corrected estimate).
        model.longBlockLayout.sleep = { _ in throw CancellationError() }
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

// MARK: - A pin that starts a REAL ThemeStore (the round-end Fable pass, round 2 — NIT-2)

/// Runs `body` with a REAL `ThemeStore` started for `session`, and puts the
/// three process globals the store's adoption reaches — `EditorTypography.current`,
/// `EditorTypography.isAdopted`, `MarkdownStyling.palette` — back where it
/// found them, on BOTH exits, AFTER the store's own task has finished.
///
/// Why this shape and not a `defer` (the round-end Fable pass's round 2,
/// NIT-2 — both stand-ins' rider, verified): `ThemeStore.start` adopts on
/// EVERY emission, and `Task.cancel()` does not join — a value whose
/// continuation resumed before the cancel is an enqueued main-actor job that
/// runs AFTER a body's synchronous `defer`, so a restore in a `defer` is
/// overtaken by the very adoption it undoes (and defers unwind in reverse,
/// so a restore declared beside the cancel-defer runs FIRST). `defer` cannot
/// `await`, so the join is explicit here and runs on the THROW path too — a
/// FAILING pin is exactly the run where a leaked Study adoption matters,
/// because every later suite in the process inherits it (and a leaked
/// `isAdopted` switches off the inertness a storeless host is designed to
/// have, so later mounted book pins write real `.outline` records into
/// `UserDefaults.standard` under a voice no host chose). `start()` returns
/// on cancellation, so the await is finite. The palette is restored for
/// every caller, even one whose host writes it nowhere — one rule, three
/// sites (`NoteBoxMountTests`, `MastheadLayoutTests` ×2).
@MainActor
func withAdoptedTheme<T>(
    session: AppSession,
    _ body: (ThemeStore) async throws -> T
) async throws -> T {
    let current = EditorTypography.current
    let adopted = EditorTypography.isAdopted
    let palette = MarkdownStyling.palette
    let store = ThemeStore(session: session)
    let watching = Task { await store.start() }
    func finish() async {
        watching.cancel()
        await watching.value
        EditorTypography.current = current
        EditorTypography.isAdopted = adopted
        MarkdownStyling.palette = palette
    }
    do {
        let result = try await body(store)
        await finish()
        return result
    } catch {
        await finish()
        throw error
    }
}
