//
//  MobilePerfWalkTests.swift
//  VariorumMobileTests
//
//  Parity round Stage B, batch B2 — THE SCRIPTED MEASUREMENT WALK: the
//  soul document's bar made executable ("I do not want the mobile app
//  to choke even on 100k words"; MEMORY is a first-class metric — iOS
//  jetsam). Two suites:
//
//  · `MobilePerfFixtureTests` — the fixture's shape pins: the ~100k
//    post is really 100k-shaped with chrome staged, the control post is
//    byte-identical across worlds, the corpus spans six books at scale,
//    nothing is journal-shaped (R57), the generator is deterministic,
//    and the dev-store door find-or-seeds without duplicating.
//  · `MobilePerfWalkTests` — the measurements: post OPEN-TIME (open →
//    first render) · TYPING latency at the viewport · SCROLL through
//    the full post · PEAK MEMORY across the whole walk. Two assertion
//    kinds (the Mac PerfBenchmarkTests precedent, Phase 4): FLATNESS
//    pins where the ratio genuinely binds (the corpus-open axis), and
//    PER-EVENT BUDGET pins at the 100k bar where the floor binds (the
//    post axis — FIX-B2's measured ruling; the walk suite's constants
//    block has the derivation) — plus RECORDED absolutes (printed
//    "PERF[sim]" lines harvested into the batch record, explicitly
//    SIMULATOR numbers; the on-device run is Stage D's exit gate). The
//    memory CEILING pin's bound is proposed from measurement and
//    marked PROVISIONAL.
//
//  THE AXES, stated so nobody pins the wrong thing flat:
//  · TYPING and PER-STEP SCROLL must be flat in POST size (P1's heart —
//    keystroke and scroll-tick cost bound to the viewport, never the
//    document; the Apple-Notes failure mode, banned).
//  · OPEN must be flat in CORPUS size (the library around the post).
//    Open is NOT flat in the post's OWN length by design — the storage
//    fill is O(post) (AppSpec §4: "reading a post is one indexed
//    query"); the 100k open is a recorded absolute, never a flatness
//    pin.
//  · MEMORY: the walk's sampled peak footprint (phys_footprint — the
//    jetsam-relevant number) bounded by a PROVISIONAL ceiling over the
//    walk's own start.
//
//  Windowless throughout (the corrected A3 machinery lesson). All
//  measured sections are SYNCHRONOUS on the main actor — other
//  suites' @MainActor tests cannot interleave inside a timed section;
//  awaits (the open road's DB hop) are protected by median-of-N and
//  the generous factors instead.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The worlds (static, built once — the Mac CorpusFactory shape)

@MainActor
enum PerfWorlds {
    struct World {
        let db: AppDatabase
        let seed: MobilePerfFixtureSeeder.SeedResult
    }

    /// The BIG world: the ~100k-word mega post + the full corpus
    /// (300 notes across six books) + the control post.
    static let big = Result { try build(
        corpusNotes: MobilePerfFixtureSeeder.fullCorpusNoteCount, includeMega: true) }
    /// The SMALL world: the SAME control post bytes, the same six
    /// books, 1/25 the corpus, no mega post — the corpus-flatness
    /// pins' other side.
    static let small = Result { try build(corpusNotes: 12, includeMega: false) }

    private static func build(corpusNotes: Int, includeMega: Bool) throws -> World {
        MobileEditorStyle.voice = .terminal
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_783_123_200)
        let tick = LockIsolated(0)
        return try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 33))
        } operation: {
            let seed = try MobilePerfFixtureSeeder.seed(
                ops: Operations(undoStack: nil),
                corpusNotes: corpusNotes,
                includeMegaPost: includeMega)
            return World(db: db, seed: seed)
        }
    }
}

/// Per-test entry over a prebuilt world: ambient deps + a fresh
/// AppSession. UUIDs are LIVE-random here (a second `.incrementing`
/// stream would re-mint the world's own IDs); dates are live —
/// measurement tests assert time and memory, never rows-by-ID.
@MainActor
private func withPerfWorld<T>(
    _ world: PerfWorlds.World,
    _ body: @MainActor (AppSession) async throws -> T
) async throws -> T {
    MobileEditorStyle.voice = .terminal
    return try await withDependencies {
        $0.database = world.db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator { Date() }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 77))
    } operation: { @MainActor in
        try await body(AppSession(database: world.db))
    }
}

// MARK: - Measurement helpers

private func median(_ samples: [Double]) -> Double {
    guard !samples.isEmpty else { return 0 }
    let sorted = samples.sorted()
    return sorted[sorted.count / 2]
}

private func percentile(_ samples: [Double], _ p: Double) -> Double {
    guard !samples.isEmpty else { return 0 }
    let sorted = samples.sorted()
    let index = min(sorted.count - 1, Int(Double(sorted.count) * p))
    return sorted[index]
}

/// The flatness assertion (the Mac `expectFlat` shape): big must sit
/// within `factor` of the control, or under the absolute noise floor.
/// Absolutes land in the run log for the batch record — SIMULATOR
/// numbers by construction.
///
/// `knownIssue`: a pin whose violation is a TRACED, RECORDED finding
/// awaiting its owning fix wraps in `withKnownIssue` — the suite stays
/// green and honest, and the moment the fix lands the un-fired known
/// issue FAILS the test ("unexpectedly passed"), forcing the wrapper's
/// removal — the pin arms itself against the fix by construction.
private func expectFlat(
    control: Double, big: Double,
    factor: Double, floorMS: Double,
    _ label: Comment,
    knownIssue: Comment? = nil
) {
    print(String(
        format: "PERF[sim] %@ — control %.3f ms · big %.3f ms · ratio %.2fx (bound: factor %.1fx, floor %.1f ms)",
        "\(label)", control, big, control > 0 ? big / control : 0, factor, floorMS))
    let assertion = {
        #expect(
            big <= max(control * factor, floorMS),
            "\(label): control=\(control)ms big=\(big)ms")
    }
    if let knownIssue {
        withKnownIssue(knownIssue) { assertion() }
    } else {
        assertion()
    }
}

/// phys_footprint in MiB — the jetsam-relevant footprint (Xcode's
/// memory-gauge number), not a compressed estimate.
private func physFootprintMB() -> Double? {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(
        MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
    let kr = withUnsafeMutablePointer(to: &info) { ptr in
        ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
    }
    guard kr == KERN_SUCCESS else { return nil }
    return Double(info.phys_footprint) / 1_048_576
}

// MARK: - The surface (the walk-suite shape: real editor, windowless)

/// Opens the full real editor over a post and measures open → first
/// render: VM + surface construction, the authoritative `loadOnce`
/// read, the projection into storage, and the first layout pass with
/// the TK2 viewport laid out.
@MainActor
private func openSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView, openMS: Double) {
    let t0 = CACurrentMediaTime()
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    surface.textView.textLayoutManager?.textViewportLayoutController.layoutViewport()
    let ms = (CACurrentMediaTime() - t0) * 1000
    return (model, surface, ms)
}

/// An interior typing offset inside the block at `blockIndex` (clamped)
/// — one character before the block's end, so repeated inserts stay
/// in-block (no crystallization, no tail).
@MainActor
private func interiorOffset(
    _ model: MobileEditorViewModel, blockIndex: Int
) -> Int? {
    let entries = model.index.entries
    guard !entries.isEmpty else { return nil }
    let entry = entries[min(max(blockIndex, 0), entries.count - 1)]
    guard let range = model.rangeOfBlock(entry.blockID), range.length > 1 else { return nil }
    return range.location + range.length - 1
}

/// Types `keystrokes` single characters at a fixed interior position
/// through the policed road (gate → storage → reprocess → re-stamp),
/// forcing the layout pass each keystroke — the full latency a real
/// keystroke pays. Synchronous throughout (no interleaving noise).
@MainActor
private func typingSamples(
    _ model: MobileEditorViewModel, _ surface: MobileWriteSurfaceView,
    at offset: Int, keystrokes: Int = 24
) -> (samples: [Double], accepted: Int) {
    let storage = surface.textView.textStorage
    var samples: [Double] = []
    var accepted = 0
    for i in 0..<keystrokes {
        let t0 = CACurrentMediaTime()
        // One keystroke = one runloop turn on a real phone, and a turn
        // DRAINS its autorelease pool — the drain rides inside the timed
        // window (it is part of a real frame's cost). Without it the
        // synchronous loop accumulates every turn's autoreleased
        // garbage, and the walk's footprint measures a pile no real
        // phone ever holds (B3 — the harness-fidelity half of the
        // memory number).
        let ok = autoreleasepool {
            let ok = typeEdit(
                model, storage,
                range: NSRange(location: offset + i, length: 0), replacement: "x")
            surface.layoutIfNeeded()
            return ok
        }
        samples.append((CACurrentMediaTime() - t0) * 1000)
        if ok { accepted += 1 }
    }
    return (samples, accepted)
}

/// The spike's proven scroll-to-end loop (estimates revise as layout
/// lands, so the target is re-derived per iteration).
@MainActor
private func scrollToEnd(_ surface: MobileWriteSurfaceView) {
    let tv = surface.textView
    for _ in 0..<12 {
        let target = max(
            0, tv.contentSize.height + tv.adjustedContentInset.bottom - tv.bounds.height)
        if abs(tv.contentOffset.y - target) <= 1 { break }
        tv.setContentOffset(CGPoint(x: 0, y: target), animated: false)
        tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
        surface.layoutIfNeeded()
    }
}

/// Walks the whole document top to bottom in near-viewport steps (the
/// Stage 0 spike's walk shape), timing every step: offset set + TK2
/// viewport layout + the layout pass (which runs the chrome's
/// near-viewport refresh — the per-tick cost a real scroll pays).
@MainActor
private func scrollWalkSamples(
    _ surface: MobileWriteSurfaceView,
    onSample: ((Int) -> Void)? = nil
) -> (perStepMS: [Double], steps: Int) {
    let tv = surface.textView
    tv.setContentOffset(.zero, animated: false)
    tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
    surface.layoutIfNeeded()
    let stepHeight = max(200, tv.bounds.height - 40)
    var samples: [Double] = []
    var y = 0.0
    var steps = 0
    while y < tv.contentSize.height - tv.bounds.height, steps < 3000 {
        y += stepHeight
        let t0 = CACurrentMediaTime()
        // One step = one frame; a frame drains its pool (the typing
        // helper's B3 note — the drain is timed as part of the step).
        autoreleasepool {
            tv.setContentOffset(
                CGPoint(x: 0, y: min(y, max(0, tv.contentSize.height - tv.bounds.height))),
                animated: false)
            tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
            surface.layoutIfNeeded()
        }
        samples.append((CACurrentMediaTime() - t0) * 1000)
        steps += 1
        if steps % 16 == 0 { onSample?(steps) }
    }
    return (samples, steps)
}

// MARK: - Store truths (fixture-shape pins)

private func postWordCount(_ db: AppDatabase, postID: String) async throws -> Int {
    let texts = try await storedBlockTextsPlain(db, postID: postID)
    return texts.reduce(0) { count, text in
        count + text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
    }
}

private func storedBlockTextsPlain(
    _ db: AppDatabase, postID: String
) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(db, sql: """
            SELECT v.working_text FROM container_block cb
            JOIN block b ON b.id = cb.block_id
            JOIN variant v ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
            WHERE cb.container_id = ? AND cb.deleted_at IS NULL
            ORDER BY cb.position, cb.id
            """, arguments: [postID])
    }
}

private func chromeCounts(
    _ db: AppDatabase, postID: String
) async throws -> (fanned: Int, commented: Int, callouts: Int) {
    try await db.read { db in
        let fanned = try Int.fetchOne(db, sql: """
            SELECT COUNT(*) FROM (
              SELECT b.id FROM container_block cb
              JOIN block b ON b.id = cb.block_id
              JOIN variant v ON v.block_id = b.id
                AND v.deleted_at IS NULL AND v.status = 'active'
              WHERE cb.container_id = ? AND cb.deleted_at IS NULL
              GROUP BY b.id HAVING COUNT(v.id) >= 2
            )
            """, arguments: [postID]) ?? -1
        let commented = try Int.fetchOne(db, sql: """
            SELECT COUNT(DISTINCT bc.block_id) FROM block_comment bc
            JOIN container_block cb ON cb.block_id = bc.block_id
              AND cb.deleted_at IS NULL
            WHERE cb.container_id = ? AND bc.deleted_at IS NULL
            """, arguments: [postID]) ?? -1
        let callouts = try Int.fetchOne(db, sql: """
            SELECT COUNT(*) FROM block b
            JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
            WHERE cb.container_id = ? AND b.presentation IS NOT NULL
              AND b.deleted_at IS NULL
            """, arguments: [postID]) ?? -1
        return (fanned, commented, callouts)
    }
}

// MARK: - The fixture's shape (pins)

@MainActor
@Suite("Mobile perf fixture (parity B2 — the 100k fixture's shape)", .serialized)
struct MobilePerfFixtureTests {
    @Test func theMegaPostIsHundredKShapedWithChromeStaged() async throws {
        let world = try PerfWorlds.big.get()
        let megaID = try #require(world.seed.megaPostID)

        // The store's own truth equals the generator's arithmetic (the
        // seed is deterministic end to end).
        let words = try await postWordCount(world.db, postID: megaID)
        #expect(words == world.seed.megaWordCount)
        #expect(words >= 95_000 && words <= 110_000,
                "the bar's number: ~100k words (got \(words))")

        let texts = try await storedBlockTextsPlain(world.db, postID: megaID)
        #expect(texts.count == world.seed.megaBlockCount)
        #expect(texts.count >= 800, "crystallization-scale blocks (got \(texts.count))")
        let multiParagraph = texts.filter { $0.contains("\n") }.count
        #expect(multiParagraph == world.seed.megaMultiParagraphBlocks)
        #expect(multiParagraph >= 50, "multi-paragraph blocks are part of the real shape")

        // Chrome staged: the measurement never runs over a bare column.
        let chrome = try await chromeCounts(world.db, postID: megaID)
        #expect(chrome.fanned == world.seed.megaFannedBlocks)
        #expect(chrome.commented == world.seed.megaCommentedBlocks)
        #expect(chrome.callouts == world.seed.megaCalloutBlocks)
        #expect(chrome.fanned >= 20 && chrome.commented >= 15 && chrome.callouts >= 8,
                "fans \(chrome.fanned) · comments \(chrome.commented) · callouts \(chrome.callouts)")
        print("PERF[fixture] mega: \(words) words · \(texts.count) blocks · "
            + "\(multiParagraph) multi-paragraph · \(chrome.fanned) fanned · "
            + "\(chrome.commented) commented · \(chrome.callouts) callouts")
    }

    @Test func theControlPostMatchesAcrossWorldsByteForByte() async throws {
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()
        let bigControl = try await storedBlockTextsPlain(
            big.db, postID: big.seed.controlPostID)
        let smallControl = try await storedBlockTextsPlain(
            small.db, postID: small.seed.controlPostID)
        #expect(bigControl == smallControl,
                "the control is the same fixture in both worlds — the corpus is the only axis")
        #expect(!bigControl.isEmpty)

        // The control carries chrome too (both sides of every ratio run
        // the same machinery).
        let chrome = try await chromeCounts(big.db, postID: big.seed.controlPostID)
        #expect(chrome.fanned == 1 && chrome.commented == 1 && chrome.callouts == 1)
    }

    @Test func nothingSeededIsJournalShaped() async throws {
        // The R57 discipline mirrored from B1: no fixture row may be
        // shaped like something the Fragments bridge would sweep.
        let world = try PerfWorlds.big.get()
        let journalShaped = try await world.db.read { db in
            try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM container
                WHERE deleted_at IS NULL
                  AND (profile = 'journal' OR entry_date IS NOT NULL)
                """) ?? -1
        }
        #expect(journalShaped == 0)
    }

    @Test func theCorpusSpansSixBooksAtScale() async throws {
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()
        for (world, notes) in [(big, 300), (small, 12)] {
            let perBook: [Int] = try await world.db.read { db in
                let names = MobilePerfFixtureSeeder.corpusBookNames
                return try names.map { name in
                    try Int.fetchOne(db, sql: """
                        SELECT COUNT(*) FROM reading_post rp
                        JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                        WHERE r.name = ? AND rp.deleted_at IS NULL
                        """, arguments: [name]) ?? -1
                }
            }
            #expect(perBook.count == 6)
            #expect(perBook.reduce(0, +) == notes,
                    "\(notes) corpus notes across six books (got \(perBook))")
            #expect(perBook.allSatisfy { $0 == notes / 6 },
                    "evenly spread — corpus SIZE is the axis, never its shape")
            #expect(world.seed.corpusNoteCount == notes)
        }
    }

    @Test func theProseGeneratorIsDeterministic() {
        let a = MobilePerfFixtureSeeder.megaProse(targetWords: 20_000)
        let b = MobilePerfFixtureSeeder.megaProse(targetWords: 20_000)
        #expect(a.map(\.text) == b.map(\.text))
        #expect(a.map(\.words) == b.map(\.words))
        let c = MobilePerfFixtureSeeder.controlProse(targetWords: 2_000)
        let d = MobilePerfFixtureSeeder.controlProse(targetWords: 2_000)
        #expect(c.map(\.text) == d.map(\.text))
        // Independent seeds: the two families never share a stream.
        #expect(a.first?.text != c.first?.text)
    }

    @Test func theDevStoreDoorFindsOrSeedsWithoutDuplicating() async throws {
        // The door's semantics at a tiny scale (full-scale build
        // correctness is the static worlds' job; door semantics are
        // scale-free). Deterministic deps — a fresh world.
        MobileEditorStyle.voice = .terminal
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_783_296_000)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 55))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let first = try await MobilePerfFixtureSeeder.findOrSeed(
                session: session, corpusNotes: 3, megaWords: 600)
            #expect(first.seeded != nil, "a fresh store seeds")
            let second = try await MobilePerfFixtureSeeder.findOrSeed(
                session: session, corpusNotes: 3, megaWords: 600)
            #expect(second.seeded == nil, "an existing proving ground just reports")
            #expect(second.bookID == first.bookID)
            let fixtureBooks = try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading WHERE name = ? AND deleted_at IS NULL",
                    arguments: [MobilePerfFixtureSeeder.fixtureBookName]) ?? -1
            }
            #expect(fixtureBooks == 1, "never a second proving ground")
            // The quiet facade: a seed is not her act.
            #expect(session.undoStack.topLabel == nil)
        }
    }
}

// MARK: - The walk (measurements + pins)

/// FB2-1 — FIXED at Stage B batch B3 (2026-08-09; found and traced at
/// B2 — both batch records hold the full story). The B2 trace: the
/// Write surface's chrome refresh was DOCUMENT-scoped per keystroke
/// and every pass re-wrote `textContainer.exclusionPaths`, a
/// geometry↔exclusion invalidation loop (551 ms keystrokes · 48 ms
/// scroll steps · 5.8 GiB walk delta at 100k). The B3 probe found the
/// ROOT deeper than the writes: exclusion-path PRESENCE alone makes
/// TK2's post-edit relayout document-scale (~160–300 ms per keystroke
/// with even ONE rect installed, position-independent; ~0.5 ms with
/// zero) and inflates the height estimate ~1.4×. The fix: the
/// keystroke road's chrome pass is `.edit`-scoped (viewport ∪ edit),
/// and the gutter mechanism moved to first-paragraph PARAGRAPH-STYLE
/// reservations (`MobileEditorTextView.setTailReservation` /
/// `setLeadingFirstLineReservation`) — position-independent, so
/// relayout stays incremental; container exclusion paths are RETIRED
/// on the Write surface and pinned never to return
/// (`MobileTakesChromeTests.aKeystrokesChromePassIsEditScopedAnd
/// WriteFreeWhenNothingMoved`). The four pins below ride UNWRAPPED —
/// their `withKnownIssue(FB2-1)` wrappers self-armed against the fix
/// exactly as designed (each fired "known issue was not recorded" on
/// the fixed tree) and were removed with the fix, red-on-old in
/// reverse.

@MainActor
@Suite("Mobile perf walk (parity B2 — the 100k bar, measured)", .serialized)
struct MobilePerfWalkTests {
    // The bounds. Every pin asserts `big ≤ max(control × factor, floor)`
    // (the Mac precedent's shape) — but WHICH term binds differs by
    // axis, and each pin's name says what its teeth enforce (FIX-B2,
    // Stage B ladder round 1, MINOR 2 — a pin named "flat" whose floor
    // is the only binding bound is the record-claim class):
    //
    // · The CORPUS-open pin: the RATIO binds (control ~23 ms × 3 ≫ the
    //   30 ms floor; measured 0.94–1.13× — genuinely flat). It keeps
    //   its flatness name.
    // · The POST-axis pins (keystroke, scroll step): the FLOOR binds —
    //   a per-event absolute budget at the 100k bar. The FIX-B2
    //   re-measure (single-build ranges landed first; both roads'
    //   numbers in the fix-pass record) ruled the ratio CANNOT bind at
    //   3×: bare TK2 itself pays ~5 ms per edit at 1,370 paragraphs
    //   (B2's probe) against a 0.7 ms control TOTAL — a ~7× platform-
    //   only ratio — and the scroll walk measured 3.4–4.2× across
    //   clean runs (TK2's own estimate-revision traversal plus the ONE
    //   remaining O(entries) ranges walk per tick, which the design
    //   requires). The pins are NAMED for the budgets they enforce;
    //   the ratio term stays in the assertion so flatness teeth
    //   self-arm on any host where the control rises past floor/3, and
    //   every run still prints the ratio for the record.
    //
    // THE TYPING FLOOR WAS RE-DERIVED AT B3 (4 → 12 ms; PROVISIONAL —
    // the architect/author may re-bound): B2 set 4 ms as a noise floor
    // under a then-8 ms control, but the fix collapsed the control to
    // ~0.7 ms, making the floor the binding bound — and the floor sat
    // BELOW the PLATFORM's own measured cost: bare TK2 on the identical
    // 100k text pays ~5 ms per keystroke (B2's bare probe — TK2's own
    // per-edit bookkeeping at 1,370 paragraphs), so no app-layer fix
    // can meet 4 ms. Post-fix the 100k keystroke medians 6–8 ms =
    // platform ~5 + app road ≤ ~2.5 (audit, scoped chrome, index
    // walks — all O(entries), none O(bytes)). 12 ms = the platform
    // floor + the app road + host-variance headroom, still under ¾ of
    // a 60 Hz frame (no choke) and 45× tighter than the defect it
    // guards against (551 ms; any exclusion-path return measures
    // 160 ms+). NOT a widened factor: the 3× ratio stands untouched.
    private static let flatFactor = 3.0
    private static let openFloorMS = 30.0
    private static let typingFloorMS = 12.0
    private static let scrollFloorMS = 4.0

    /// The memory ceiling — ARMED at B3 (PB2-2's 250 MiB bound kept as
    /// proposed; still PROVISIONAL in its calibration — Stage D's
    /// on-device run is the real phone's number). Derivation (B2):
    /// bare TK2 holds the whole 100k walk FLAT (~75 MiB); the app
    /// road's OPEN adds ~27 MiB; 250 MiB of walk delta is ~9× the
    /// healthy open delta and categorically under iOS foreground
    /// jetsam limits. Pre-fix the walk measured 5,763 MiB of delta
    /// (FB2-1's churn); post-fix, with the harness draining its pool
    /// once per step exactly as a real frame does (the helpers' B3
    /// note — an undrained synchronous loop still measured 545 MiB of
    /// garbage no phone ever holds), the walk delta measures 43 MiB —
    /// 5.8× of headroom under the armed bound.
    private static let walkDeltaCeilingMB = 250.0

    @Test func openingAFixedPostIsFlatInCorpusSize() async throws {
        // The corpus axis: the SAME control post (byte-identical), a
        // 25× corpus around it. Median of 5 full opens each side.
        let big = try PerfWorlds.big.get()
        let small = try PerfWorlds.small.get()

        var smallSamples: [Double] = []
        try await withPerfWorld(small) { session in
            for _ in 0..<5 {
                let opened = await openSurface(session, postID: small.seed.controlPostID)
                smallSamples.append(opened.openMS)
                #expect(opened.model.index.entries.count == small.seed.controlBlockCount)
            }
        }
        var bigSamples: [Double] = []
        try await withPerfWorld(big) { session in
            for _ in 0..<5 {
                let opened = await openSurface(session, postID: big.seed.controlPostID)
                bigSamples.append(opened.openMS)
                #expect(opened.model.index.entries.count == big.seed.controlBlockCount)
            }
        }
        expectFlat(
            control: median(smallSamples), big: median(bigSamples),
            factor: Self.flatFactor, floorMS: Self.openFloorMS,
            "open(control post), 12-note vs 300-note corpus")
    }

    @Test func typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k() async throws {
        // The post axis, corpus held constant (both posts live in the
        // BIG world): keystroke cost must stay within the per-event
        // BUDGET (the 12 ms floor — the binding bound; the constants
        // block has the FIX-B2 ruling: the ratio cannot bind at 3×
        // because bare TK2's own per-edit cost at 1,370 paragraphs is
        // ~7× the control's total). Measured at the TOP viewport (the
        // worst case for index shifting — every downstream entry
        // moves) AND at the END after a real scroll (her actual
        // position in a long note).
        let big = try PerfWorlds.big.get()
        let megaID = try #require(big.seed.megaPostID)

        try await withPerfWorld(big) { session in
            let control = await openSurface(session, postID: big.seed.controlPostID)
            let controlOffset = try #require(interiorOffset(control.model, blockIndex: 1))
            let controlTyped = typingSamples(control.model, control.surface, at: controlOffset)
            #expect(controlTyped.accepted == controlTyped.samples.count)

            let mega = await openSurface(session, postID: megaID)
            print(String(
                format: "PERF[sim] open(100k post) — %.1f ms (recorded absolute; open scales with the post's own length by design)",
                mega.openMS))
            let topOffset = try #require(interiorOffset(mega.model, blockIndex: 1))
            let megaTop = typingSamples(mega.model, mega.surface, at: topOffset)
            #expect(megaTop.accepted == megaTop.samples.count)
            let recoveriesAfterTop = mega.model.desyncRecoveryCount

            scrollToEnd(mega.surface)
            let endBlock = mega.model.index.entries.count - 2
            let endOffset = try #require(interiorOffset(mega.model, blockIndex: endBlock))
            let megaEnd = typingSamples(mega.model, mega.surface, at: endOffset)
            #expect(megaEnd.accepted == megaEnd.samples.count)

            let controlMedian = median(controlTyped.samples)
            expectFlat(
                control: controlMedian, big: median(megaTop.samples),
                factor: Self.flatFactor, floorMS: Self.typingFloorMS,
                "keystroke(top viewport), 4k vs 100k post")
            expectFlat(
                control: controlMedian, big: median(megaEnd.samples),
                factor: Self.flatFactor, floorMS: Self.typingFloorMS,
                "keystroke(end of note), 4k vs 100k post")
            print(String(
                format: "PERF[sim] keystroke p95 — control %.3f ms · 100k top %.3f ms · 100k end %.3f ms",
                percentile(controlTyped.samples, 0.95),
                percentile(megaTop.samples, 0.95),
                percentile(megaEnd.samples, 0.95)))

            // **M12 — MEASUREMENT ONLY (round-2 ladder round 1, finding 5's
            // ownership).** A gate-less insertion whose iOS-widened report
            // overflows its owning entry cannot be routed by
            // `fallbackVerdict` and takes a `desyncRecovery()` — honest,
            // never a crash, and unchanged by batch 1. It is a candidate
            // cause of "the note flickered" on her phone, and the question
            // its disposition waits on is simply: does it fire during
            // ORDINARY TYPING? `desyncRecoveryCount` is already the oracle,
            // so the walk reads it out over 24 keystrokes per leg at both
            // ends of a 100k note. NO BUDGET IS ASSERTED — the number is
            // the deliverable; the fix (if any) is a separate row decided
            // on this evidence.
            print(String(
                format: "PERF[sim] desyncRecovery(typing) — control %d · 100k top %d · 100k end %d "
                    + "(%d keystrokes per leg; M12 measurement, no budget)",
                control.model.desyncRecoveryCount,
                recoveriesAfterTop,
                mega.model.desyncRecoveryCount - recoveriesAfterTop,
                megaTop.samples.count))

            // The probe is real: the typed characters landed on the
            // surface (a dead probe must not pass silently).
            #expect((mega.surface.textView.text ?? "").contains("xxxx"))
        }
    }

    @Test func theFullScrollHoldsThePerStepBudgetAt100kAndTheWalkHoldsTheMemoryCeiling() async throws {
        // THE FULL 100k TRAVERSAL, once, carrying BOTH assertions (one
        // walk instead of two — the traversal is the expensive half,
        // ~2 min while FB2-1 stood, seconds healthy):
        // · The post axis: the TOTAL cost of scrolling 100k words is
        //   O(document) by definition (you traverse it all); the
        //   PER-STEP cost is what P1 bounds — each tick lays out one
        //   viewport band, never the document. The binding bound is
        //   the per-step BUDGET (the 4 ms floor; the constants block
        //   has the FIX-B2 ruling — the walk measured 3.4–4.2× across
        //   clean runs, TK2's estimate-revision traversal plus the one
        //   designed O(entries) ranges walk per tick).
        // · The phone's own constraint: PEAK MEMORY across the whole
        //   walk (open → type → full scroll), sampled as phys_footprint
        //   — jetsam kills on footprint. The worlds are forced FIRST so
        //   the baseline sample excludes their build; the ceiling
        //   bounds the walk's own sampled delta.
        let big = try PerfWorlds.big.get()
        _ = try PerfWorlds.small.get()
        let megaID = try #require(big.seed.megaPostID)
        let start = try #require(physFootprintMB(), "footprint readable on this host")

        try await withPerfWorld(big) { session in
            var peak = start
            func sample() { peak = max(peak, physFootprintMB() ?? peak) }

            let control = await openSurface(session, postID: big.seed.controlPostID)
            let controlWalk = scrollWalkSamples(control.surface)
            #expect(controlWalk.steps >= 5, "the control walk is a real walk")

            let mega = await openSurface(session, postID: megaID)
            sample()
            let afterOpen = peak

            // The walk's typing leg (memory participation; the typing
            // FLATNESS pins live in the typing test).
            let topOffset = try #require(interiorOffset(mega.model, blockIndex: 1))
            _ = typingSamples(mega.model, mega.surface, at: topOffset, keystrokes: 8)
            sample()

            let megaWalk = scrollWalkSamples(mega.surface) { _ in sample() }
            sample()
            #expect(megaWalk.steps >= 100, "the 100k walk traverses the whole post")
            #expect(megaWalk.steps < 3000, "the walk terminates (estimates settled)")

            expectFlat(
                control: median(controlWalk.perStepMS), big: median(megaWalk.perStepMS),
                factor: Self.flatFactor, floorMS: Self.scrollFloorMS,
                "scroll step(full walk), 4k vs 100k post")
            print(String(
                format: "PERF[sim] scroll(100k post) — %d steps · total %.0f ms · p95 %.2f ms · worst %.2f ms",
                megaWalk.steps, megaWalk.perStepMS.reduce(0, +),
                percentile(megaWalk.perStepMS, 0.95), megaWalk.perStepMS.max() ?? 0))
            print(String(
                format: "PERF[sim] scroll(control post) — %d steps · total %.0f ms · p95 %.2f ms",
                controlWalk.steps, controlWalk.perStepMS.reduce(0, +),
                percentile(controlWalk.perStepMS, 0.95)))

            let delta = peak - start
            print(String(
                format: "PERF[sim] memory(100k walk) — start %.0f MiB · after open %.0f MiB · sampled peak %.0f MiB · walk delta %.0f MiB (phys_footprint; test-host absolutes — the on-device run is Stage D's gate)",
                start, afterOpen, peak, delta))
            // M12's second readout: the whole walk (open → type → full
            // scroll) on both posts. Measurement only, no budget — see the
            // typing test's note for what the number decides.
            print(String(
                format: "PERF[sim] desyncRecovery(walk) — control %d · 100k %d (M12 measurement, no budget)",
                control.model.desyncRecoveryCount, mega.model.desyncRecoveryCount))
            #expect(
                delta <= Self.walkDeltaCeilingMB,
                "the 100k walk's footprint delta \(delta) MiB exceeds the \(Self.walkDeltaCeilingMB) MiB ceiling (PB2-2, armed at B3)")
        }
    }

    /// **M2f — MEASUREMENT ONLY (round 2, batch 1).** The Read surface had
    /// ZERO perf coverage: `MobilePerfWalkTests` never mentioned Read, so
    /// the 100k proving ground — the executable form of her bar — had never
    /// been pointed at it. The stability survey's traced concern:
    /// `MobileReadNoteView` virtualizes per NOTE (a `LazyVStack` over notes,
    /// per-row lazy `.task`), which is right for a book of many notes, but
    /// within ONE realized row it materializes the whole note — the full
    /// rendered string, then `MarkdownRendering.render`'s second string plus
    /// its runs array, then one `AttributedString` per display line, then a
    /// SwiftUI `Text` per paragraph that the row must size.
    ///
    /// This measures exactly the part that is ours: the row's `.task` (the
    /// store read + join) and the paragraph transform, with the footprint
    /// across both. **NO OPTIMIZATION IS BUILT HERE AND NO BUDGET IS
    /// ASSERTED** — the number is the deliverable; whether it earns a fix
    /// (the survey's candidate: a per-note paragraph cap wearing the same
    /// visible-truncation grammar the lists already use) is a ruling, and
    /// the repo's guard forbids fixing on suspicion. The assertions below
    /// only keep the probe honest: a dead probe must not pass silently.
    @Test func theReadSurfaceAtTheHundredKBarIsMeasured() async throws {
        let big = try PerfWorlds.big.get()
        let megaID = try #require(big.seed.megaPostID)
        let start = try #require(physFootprintMB(), "footprint readable on this host")

        try await withPerfWorld(big) { session in
            // Leg 1 — the row's `.task`, byte for byte what the view runs.
            let t0 = CACurrentMediaTime()
            let text: String? = try? await session.database.read { [id = megaID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            let readMS = (CACurrentMediaTime() - t0) * 1000
            let source = try #require(text)
            let afterRead = physFootprintMB() ?? start

            // Leg 2 — the paragraph transform (the AttributedString set the
            // row then holds for its whole realized lifetime).
            let t1 = CACurrentMediaTime()
            let paragraphs = MobileReadPage.paragraphs(of: source, codeTint: nil)
            let transformMS = (CACurrentMediaTime() - t1) * 1000
            let afterTransform = physFootprintMB() ?? afterRead

            // The control note, for the shape of the ratio (recorded, not
            // asserted — the axis here is the note's OWN length, which the
            // survey's concern is precisely about).
            let controlText: String? = try? await session.database.read {
                [id = big.seed.controlPostID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            let controlSource = try #require(controlText)
            let t2 = CACurrentMediaTime()
            let controlParagraphs = MobileReadPage.paragraphs(of: controlSource, codeTint: nil)
            let controlMS = (CACurrentMediaTime() - t2) * 1000

            print(String(
                format: "PERF[sim] READ(100k note) — source %d chars · read+join %.1f ms · paragraphs %d · transform %.1f ms · total %.1f ms",
                (source as NSString).length, readMS, paragraphs.count, transformMS,
                readMS + transformMS))
            print(String(
                format: "PERF[sim] READ(control note) — source %d chars · paragraphs %d · transform %.1f ms (ratio %.1fx on the note's own length)",
                (controlSource as NSString).length, controlParagraphs.count, controlMS,
                controlMS > 0 ? transformMS / controlMS : 0))
            print(String(
                format: "PERF[sim] READ memory — start %.0f MiB · after read+join %.0f MiB (+%.0f) · after transform %.0f MiB (+%.0f); ONE realized row holds the transform's result for its lifetime",
                start, afterRead, afterRead - start,
                afterTransform, afterTransform - afterRead))

            // Probe liveness only (M2f is measure-only — no budget is
            // asserted; the number above is the deliverable).
            #expect((source as NSString).length > 400_000, "the 100k note really is the source")
            #expect(paragraphs.count > 800, "the transform really produced the note's lines")
            #expect(!controlParagraphs.isEmpty)
        }
    }
}
