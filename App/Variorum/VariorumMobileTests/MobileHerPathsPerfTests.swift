//
//  MobileHerPathsPerfTests.swift
//  VariorumMobileTests
//
//  VM-66 (the VM-64 run, batch 3) — **THE SPEED TESTS RUN HER PATHS.**
//  The record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 3;
//  §7 its closeout, which tables every series below and which later batch
//  tightens it).
//
//  Her words, the reason the run exists: *"There's significant lag when going
//  to the quick entry box, when going from the quick entry box into a note."*
//  Her bar (MobileSoul §2): *"I do not want the mobile app to choke even on
//  100k words."*
//
//  `MobilePerfWalkTests` measures a WINDOWLESS editor that never starts its
//  live updates — no screen, no shell, no push (audit F §4/§9: "the second
//  projection read, the delivery `ingest`, the chips, the liveness read and
//  the SwiftUI push are outside every recorded number"). This suite measures
//  the paths she takes, on the REAL surfaces:
//
//  · the real `MobileWriteScreen`, mounted in a key window, whose `.task`
//    registers the editor, arrives and STARTS its live updates — a short note
//    and the 100k note;
//  · the real `MobileShellView` and its NavigationStack PUSH — Open from the
//    capture box (her lag 2) and a Library row — with the Library mounted
//    off screen in the band exactly as in the app;
//  · the capture box's autosaves waking that off-screen Library;
//  · owner adoption at fixture scale with nothing to adopt; the savepoints a
//    leaving sets off; the autosave registry across opens; and what one
//    typing pause costs in the 100k note.
//
//  ## It READS VM-65's timing layer — it does not time what the layer times
//
//  The spans, counting windows and counters are batch 1's
//  (`Shared/AppTiming.swift` says what each one measures). The marks feed the
//  app's ONE recorder (`AppTiming.recorder`), which the test host enables at
//  launch (`VariorumMobileApp.init` → `MobileTiming.start()`; a test host
//  never persists it). A test cannot hand the marks a recorder of its own —
//  the listings' fetch closures run on GRDB's queues, which inherit no
//  task-local — so this suite reads the process's recorder, and that is why
//  **IT MUST RUN ALONE, in an `xcodebuild` invocation of its own**: any other
//  suite running in parallel in the same process would add its opens and
//  saves to these windows. Inside the suite every test is serialized. Where
//  the layer does not time something (open → the first LIVE delivery, a
//  listing's query, one delivery's main-thread ingest), the test's own clock
//  does, and the series name and the comment say so.
//
//  ## What a test host can and cannot reach (said once, honestly)
//
//  REACHED: the SwiftUI screen and shell, the band, the NavigationStack push
//  and its `navigationDestination` builder, the screen's `.task` (liveness
//  registration, arrival, `start()`), the first paint (the timing layer's
//  next-frame tick), the editor's real autosave debounce, the leaving's
//  `onDisappear`, the background flush (`mobileScenePhaseChanged`, driven by
//  the same call the app's scene handler makes), and an on-disk ENCRYPTED WAL
//  store (each world is an on-disk copy opened by `openStore(at:)`, whose own
//  migration encrypts it, as on her phone).
//  NOT REACHED: the software keyboard (the simulator under `xcodebuild test`
//  stays in hardware-keyboard mode, so the two "→ keyboard up" spans never
//  fill here); a finger (doors are driven through accessibility activation
//  or the model the face calls); the launch and unlock spans (a test host
//  never opens through the bootstrap — `AppBootstrap.Launch`); sync rounds
//  (no services, signed out); a real lock (the Castle arm below runs the
//  phone's own `onWillLock` and removes the tree exactly as the bootstrap's
//  state flip does, but closes no pool and drops no key); the device's CPU,
//  GPU and flash. **Every number here is a SIMULATOR number**, and the
//  machine running it may be loaded.
//
//  ## The output: one greppable line per series
//
//  `VM64-PERF|<series>|n=<runs>|median=<v>|min=<v>|max=<v>|<ms|count>` —
//  at least five runs per series, the median and the range. A count that is
//  deterministic shows it as min = max.
//
//  ## What is asserted, and what is only recorded
//
//  **Counts are ASSERTED only where today's behaviour is a deliberate
//  guarantee** (owner adoption adopts nothing when nothing is unowned; an
//  edited note's leaving is savepointed). **A count that measures a defect a
//  later batch fixes is RECORDED and never asserted**, with a comment naming
//  the batch that will tighten it — so batches 4–7 can each turn one into an
//  assertion that is red on today's code. No test here is red on today's
//  code by design. The only other assertions keep the probes honest (a dead
//  probe must not pass silently: every series must have gathered its runs).
//  **No new duration budget is set**: a budget is written with its measured
//  basis, and the basis is the BEFORE numbers this suite produces (the
//  record, §5) — the existing budgets in `MobilePerfWalkTests` stay as they
//  are.
//

import Dependencies
import Foundation
import GRDB
import QuartzCore
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The line

/// The one greppable output shape the run's record lifts the numbers from.
nonisolated enum VM64Perf {
    enum Unit: String { case ms, count }

    /// The median (the mean of the middle two when the count is even).
    static func median(_ samples: [Double]) -> Double {
        guard !samples.isEmpty else { return 0 }
        let sorted = samples.sorted()
        let mid = sorted.count / 2
        return sorted.count % 2 == 1 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2
    }

    static func line(_ series: String, _ samples: [Double], _ unit: Unit) -> String {
        func format(_ value: Double) -> String {
            switch unit {
            case .ms: return String(format: "%.2f", value)
            case .count:
                return value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
            }
        }
        let n = samples.count
        let low = samples.min() ?? 0
        let high = samples.max() ?? 0
        return "VM64-PERF|\(series)|n=\(n)|median=\(format(median(samples)))"
            + "|min=\(format(low))|max=\(format(high))|\(unit.rawValue)"
    }

    /// Prints the line, and holds the probe honest: a series must have
    /// gathered its runs (a dead probe never passes silently).
    static func report(
        _ series: String, _ samples: [Double], _ unit: Unit, expecting runs: Int,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        print(line(series, samples, unit))
        #expect(samples.count == runs,
                "\(series): gathered \(samples.count) of \(runs) runs",
                sourceLocation: sourceLocation)
    }
}

// MARK: - Reading the timing layer

/// Reads the app's ONE recorder (the suite header says why it is that one).
@MainActor
private enum Probe {
    typealias Snapshot = TimingSnapshot<AppTimingSeries, AppTimingCounter>

    static var recorder: TimingRecorder<AppTimingSeries, AppTimingCounter> { AppTiming.recorder }

    /// The test host's launch already enabled it (`MobileTiming.start`); this
    /// only makes a suite run that somehow precedes that equally live.
    static func arm() { recorder.setEnabled(true) }

    static func snap() -> Snapshot { recorder.snapshot() }

    /// The samples `series` gained since `before`, oldest first (bounded by
    /// the series' ring — no test here gathers anywhere near 64 at once).
    static func newSamples(_ series: AppTimingSeries, since before: Snapshot) -> [Double] {
        let now = recorder.snapshot()
        let gained = (now.stats(series)?.count ?? 0) - (before.stats(series)?.count ?? 0)
        guard gained > 0, let retained = now.stats(series)?.retained else { return [] }
        return Array(retained.suffix(min(gained, retained.count)))
    }

    static func delta(_ counter: AppTimingCounter, since before: Snapshot) -> Int {
        recorder.snapshot().counter(counter) - before.counter(counter)
    }
}

/// Waits, on the main actor, for `condition` — plain sleeps, never a forced
/// layout pass, so a timed section runs as the app's run loop runs it. A
/// timeout is a finding (the instrument never fired) and says which.
@MainActor
@discardableResult
private func waitUntil(
    _ what: String, timeout: Duration = .seconds(60), reportTimeout: Bool = true,
    sourceLocation: SourceLocation = #_sourceLocation,
    _ condition: @MainActor () -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        if clock.now >= deadline {
            if reportTimeout {
                Issue.record("VM-66: timed out waiting for \(what)", sourceLocation: sourceLocation)
            }
            return false
        }
        try? await Task.sleep(for: .milliseconds(5))
    }
    return true
}

/// The run loop for a while, untouched (the window a count is read over).
@MainActor
private func idle(_ duration: Duration) async {
    try? await Task.sleep(for: duration)
}

private func milliseconds(since start: CFTimeInterval) -> Double {
    (CACurrentMediaTime() - start) * 1000
}

// MARK: - Owner adoption, watched on the store's writer (VM-67)

/// **VM-67 (the VM-64 run, batch 4)** — what owner adoption runs on the store's
/// WRITER connection, and what each statement's query plan reads: the hosted twin
/// of the Core pins (`Tests/VariorumCoreTests/OwnerAdoptionTests.swift`).
/// Nonisolated so the trace closure GRDB calls on its writer queue carries no
/// actor isolation of the test's.
nonisolated enum OwnerAdoptionTrace {
    struct Statement: Sendable {
        let sql: String
        let expandedSQL: String
        var verb: String { String(sql.drop { $0.isWhitespace }.prefix { !$0.isWhitespace }).uppercased() }
    }

    static let writeVerbs: Set<String> = [
        "BEGIN", "COMMIT", "END", "SAVEPOINT", "RELEASE", "UPDATE", "INSERT", "DELETE", "REPLACE",
    ]

    /// Starts recording every statement the writer runs (until `stop`).
    static func start(on db: AppDatabase) throws -> LockIsolated<[Statement]> {
        let log = LockIsolated<[Statement]>([])
        try db.writeWithoutTransaction { connection in
            connection.trace(options: .statement) { event in
                guard case .statement(let statement) = event else { return }
                let entry = Statement(sql: statement.sql, expandedSQL: statement.expandedSQL)
                log.withValue { $0.append(entry) }
            }
        }
        return log
    }

    static func stop(on db: AppDatabase) throws {
        try db.writeWithoutTransaction { $0.trace(options: .statement, nil) }
    }

    /// Each data statement's query plan: a plan line that reads an owner table
    /// must read it through that table's unowned-row index (`idx_<t>_unowned`).
    static func planReadings(
        _ db: AppDatabase, _ statements: [Statement]
    ) throws -> (violations: [String], reached: Set<String>, ownerTables: Set<String>) {
        try db.writeWithoutTransaction { connection in
            let ownerTables = try SyncSchema.tables.map(\.name).filter { table in
                try Row.fetchAll(connection, sql: "PRAGMA table_info(\(table))")
                    .contains { ($0["name"] as String) == "owner_id" }
            }
            var violations: [String] = []
            var reached: Set<String> = []
            for statement in statements where ["SELECT", "UPDATE", "DELETE", "INSERT", "WITH"].contains(statement.verb) {
                let details = try Row.fetchAll(connection, sql: "EXPLAIN QUERY PLAN " + statement.expandedSQL)
                    .map { $0["detail"] as String }
                for detail in details {
                    for table in ownerTables {
                        let reads = ["SCAN \(table)", "SEARCH \(table)", "SCAN TABLE \(table)", "SEARCH TABLE \(table)"]
                            .contains { detail == $0 || detail.hasPrefix($0 + " ") }
                        guard reads else { continue }
                        reached.insert(table)
                        if !detail.contains("idx_\(table)_unowned") { violations.append("\(statement.sql) → \(detail)") }
                    }
                }
            }
            return (violations, reached, Set(ownerTables))
        }
    }
}

// MARK: - The worlds: on-disk copies of the static fixture worlds

/// One test's own store: an on-disk copy of a static fixture world, opened
/// the way the app opens one (`openStore(at:)` — a WAL pool, encrypted by the
/// open's own one-time migration, as her phone's store is). Each test writes
/// only to its copy, so the static worlds the other perf suites pin stay as
/// seeded.
@MainActor
private struct DiskWorld {
    let db: AppDatabase
    let seed: MobilePerfFixtureSeeder.SeedResult
    let folder: URL

    static func copy(of world: PerfWorlds.World, _ tag: String) throws -> DiskWorld {
        let folder = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("vm66-\(tag)-\(UUID().uuidString)", isDirectory: true)
        let url = folder.appendingPathComponent("variorum.sqlite")
        try world.db.backup(to: url)
        return DiskWorld(db: try AppDatabase.openStore(at: url), seed: world.seed, folder: folder)
    }

    func remove() { try? FileManager.default.removeItem(at: folder) }
}

/// Ambient dependencies over a world, and a fresh session — the
/// `withPerfWorld` shape (live ids and dates: these tests assert counts and
/// times, never rows by id). `owner` signs the world in for owner adoption.
@MainActor
private func withHerWorld<T>(
    _ world: DiskWorld, owner: String? = nil,
    _ body: @MainActor (AppSession) async throws -> T
) async throws -> T {
    MobileEditorStyle.voice = .terminal
    Probe.arm()
    return try await withDependencies {
        $0.database = world.db
        $0.uuid = UUIDGenerator { UUID() }
        $0.date = DateGenerator { Date() }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 66))
        if let owner { $0.ownerIdentity = OwnerIdentity { owner } }
    } operation: { @MainActor in
        try await body(AppSession(database: world.db))
    }
}

/// Some notes of a world by title prefix, oldest title first.
private func noteIDs(_ db: AppDatabase, titled prefix: String, limit: Int) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(db, sql: """
            SELECT id FROM container
            WHERE kind = 'post' AND deleted_at IS NULL AND title LIKE ?
            ORDER BY created_at, id LIMIT ?
            """, arguments: ["\(prefix)%", limit])
    }
}

// MARK: - Mounting the real surfaces

/// The app's state flip, as a view: the bootstrap's `.ready` → `.opening`
/// removes the whole `.ready` tree, and that structural removal is what
/// fires every mounted screen's `onDisappear`. `mounted = false` does the
/// same to whatever this wraps — the same SwiftUI mechanism — while the
/// hosting window stays up.
@MainActor
@Observable
private final class MountGate {
    var mounted = true
}

private struct Gated<Content: View>: View {
    let gate: MountGate
    /// Built ONCE by the caller (a stored value, so this view's body never
    /// re-runs the content's initializer).
    let content: Content

    var body: some View {
        if gate.mounted {
            content
        } else {
            Color.clear
        }
    }
}

/// A real view in a real key window, behind a gate.
@MainActor
private final class Mounted<Content: View> {
    let gate = MountGate()
    let surface: HostedSurface<Gated<Content>>

    init(_ content: Content) {
        surface = HostedSurface(Gated(gate: gate, content: content))
    }

    /// Removes the content the way the app does (see `MountGate`) and waits
    /// for every leaving it set off to finish (a note's `onDisappear` work —
    /// its teardown and leaving savepoint — ends the layer's `noteLeave`
    /// span), then takes the window down.
    func unmount(leavings: Int, report: Bool = true, sourceLocation: SourceLocation = #_sourceLocation) async {
        let before = Probe.snap()
        gate.mounted = false
        if leavings > 0 {
            await waitUntil(
                "\(leavings) note leaving(s) to finish", timeout: .seconds(30),
                reportTimeout: report, sourceLocation: sourceLocation
            ) {
                Probe.newSamples(.noteLeave, since: before).count >= leavings
            }
        }
        await idle(.milliseconds(100))
        surface.tearDown()
    }
}

/// An interior offset inside the block at `blockIndex` — one character before
/// the block's end, so a typed key stays in the block (no crystallization).
@MainActor
private func interiorOffset(_ model: MobileEditorViewModel, blockIndex: Int) -> Int? {
    let entries = model.index.entries
    guard !entries.isEmpty else { return nil }
    let entry = entries[min(max(blockIndex, 0), entries.count - 1)]
    guard let range = model.rangeOfBlock(entry.blockID), range.length > 1 else { return nil }
    return range.location + range.length - 1
}

// MARK: - The suite

@MainActor
@Suite("VM-66 — the speed tests run her paths (VM-65's timing layer, read)", .serialized)
struct MobileHerPathsPerfTests {
    /// Runs per series (the record's rule: n ≥ 5, a median and a range).
    private static let runs = 5

    // MARK: 1 · A note opens on the real screen, its live updates started

    /// **The open she feels, short and 100k, through the screen's own road**
    /// — `MobileWriteScreen`'s `.task`: liveness registration, the arrival's
    /// load and first render, then `start()` and its first live delivery.
    ///
    /// · `note-open-to-screen-*` — the layer's span (`noteOpenToScreen`): the
    ///   screen built → its text on screen (the frame after the first render).
    /// · `note-open-to-live-*` — THIS TEST'S clock (the layer has no span for
    ///   it): the screen built → the live updates' first delivery ingested on
    ///   the main thread. Batch 6's second-read fix shows HERE, after paint.
    /// · `note-reads-per-open-*` — the layer's window (`noteReadsPerOpen`):
    ///   whole-note projection reads from the arrival to the first delivery.
    ///   **RECORDED, not asserted: audit F 2C's two reads. Batch 6 (VM-69)
    ///   tightens it to one** — its pin turns this into an assertion red on
    ///   today's code.
    ///
    /// One unrecorded warm-up open per note first (the process's first use of
    /// TextKit, the fonts and the screen's types is a once-per-launch cost
    /// her phone pays once, not per open).
    @Test func aNoteOpensOnTheRealScreenWithItsLiveUpdatesStarted() async throws {
        let big = try PerfWorlds.big.get()
        let megaID = try #require(big.seed.megaPostID)
        let world = try DiskWorld.copy(of: big, "open")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            for (label, postID) in [("short", big.seed.controlPostID), ("100k", megaID)] {
                var toScreen: [Double] = []
                var toLive: [Double] = []
                var readsPerOpen: [Double] = []
                for attempt in 0...Self.runs {
                    let router = MobileShellRouter()
                    let before = Probe.snap()
                    let t0 = CACurrentMediaTime()
                    let mounted = Mounted(MobileWriteScreen(
                        session: session, postID: postID, router: router, tab: .library))
                    guard await waitUntil("\(label): the first live delivery", {
                        Probe.delta(.noteProjectionDelivery, since: before) >= 1
                    }) else { await mounted.unmount(leavings: 0); return }
                    let live = milliseconds(since: t0)
                    await waitUntil("\(label): the paint span") {
                        !Probe.newSamples(.noteOpenToScreen, since: before).isEmpty
                    }
                    if attempt > 0 {
                        toLive.append(live)
                        toScreen += Probe.newSamples(.noteOpenToScreen, since: before)
                        readsPerOpen += Probe.newSamples(.noteReadsPerOpen, since: before)
                    }
                    await mounted.unmount(leavings: 1, report: false)
                }
                VM64Perf.report("note-open-to-screen-\(label)", toScreen, .ms, expecting: Self.runs)
                VM64Perf.report("note-open-to-live-\(label)", toLive, .ms, expecting: Self.runs)
                // RECORDED (batch 6, VM-69: 2 → 1). Only the probe is held.
                VM64Perf.report("note-reads-per-open-\(label)", readsPerOpen, .count, expecting: Self.runs)
                #expect(readsPerOpen.allSatisfy { $0 >= 1 }, "an open reads its note at least once")
            }
        }
    }

    // MARK: 2 · Through the shell's push: the capture box's Open (her lag 2)

    /// **The hand-off she named, on the mounted shell** (nine-wing world — her
    /// library's shape): text in the box, the box mints, then Open —
    /// `file()`, the shell's push, the Write screen's arrival and live start.
    ///
    /// · `shell-box-open-to-note` — the layer's span (`boxOpenToNote`): Open
    ///   pressed → the note's text on screen. The whole of lag 2.
    /// · `shell-box-file` — the layer's span (`boxFile`): the filing before
    ///   any navigation (audit F 2A).
    /// · `shell-box-open-to-live` — THIS TEST'S clock: Open → the first live
    ///   delivery ingested.
    /// · `shell-box-editor-builds-per-open` — the layer's counters: editor
    ///   view models built per note arrival across the push. **RECORDED:
    ///   audit F 2D's twin question, settled by this number; batch 6 (VM-69
    ///   / VM-70) fixes it only if it reads above one.**
    /// · `shell-box-note-reads-per-open` — as test 1's window, via the shell.
    ///   **RECORDED (batch 6).**
    ///
    /// Each run mounts a fresh shell (the push's pop is not drivable in
    /// process; a fresh shell is the honest reset). A warm-up run first.
    @Test func theCaptureBoxOpensItsNoteThroughTheShellsPush() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.nineWings.get(), "box-open")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            var openToNote: [Double] = []
            var file: [Double] = []
            var openToLive: [Double] = []
            var builds: [Double] = []
            var reads: [Double] = []
            for attempt in 0...Self.runs {
                let router = MobileShellRouter()
                let mountedAt = Probe.snap()
                let shell = Mounted(MobileShellView(session: session, services: nil, router: router))
                await waitUntil("the shell's Library listing") {
                    Probe.delta(.libraryDelivery, since: mountedAt) >= 1
                }
                router.quickNote.text = "A thought for the hand-off, run \(attempt)."
                await waitUntil("the box's mint") { router.quickNote.postID != nil }
                await idle(.milliseconds(400))

                let before = Probe.snap()
                let t0 = CACurrentMediaTime()
                router.quickNote.open()
                guard await waitUntil("the opened note's first live delivery", {
                    Probe.delta(.noteProjectionDelivery, since: before) >= 1
                }) else { await shell.unmount(leavings: 0); return }
                let live = milliseconds(since: t0)
                await waitUntil("the box → note span") {
                    !Probe.newSamples(.boxOpenToNote, since: before).isEmpty
                }
                // Let a late re-build of the destination (the twin) land in
                // the count before it is read.
                await idle(.milliseconds(500))
                if attempt > 0 {
                    openToNote += Probe.newSamples(.boxOpenToNote, since: before)
                    file += Probe.newSamples(.boxFile, since: before)
                    openToLive.append(live)
                    let arrivals = Probe.delta(.noteArrival, since: before)
                    builds.append(Double(Probe.delta(.editorBuilt, since: before)) / Double(max(arrivals, 1)))
                    reads += Probe.newSamples(.noteReadsPerOpen, since: before)
                }
                await shell.unmount(leavings: 1, report: false)
            }
            VM64Perf.report("shell-box-open-to-note", openToNote, .ms, expecting: Self.runs)
            VM64Perf.report("shell-box-file", file, .ms, expecting: Self.runs)
            VM64Perf.report("shell-box-open-to-live", openToLive, .ms, expecting: Self.runs)
            // RECORDED (batch 6 — the twin count; fixed only if above one).
            VM64Perf.report("shell-box-editor-builds-per-open", builds, .count, expecting: Self.runs)
            // RECORDED (batch 6, VM-69: 2 → 1).
            VM64Perf.report("shell-box-note-reads-per-open", reads, .count, expecting: Self.runs)
            #expect(builds.allSatisfy { $0 >= 1 }, "an arrival had an editor built for it")
        }
    }

    // MARK: 3 · Through the shell's push: a Library row (short and 100k)

    /// **Opening an existing note the way she does — the Library row** (the
    /// big world: the 100k note and the short control note are the Library's
    /// two newest rows). The tab door moves the band; the row's own button
    /// pushes the note onto the Library's stack.
    ///
    /// · `shell-library-open-to-screen-*` — the layer's span: the screen
    ///   built by the push → its text on screen.
    /// · `shell-library-editor-builds-per-open-*` — **RECORDED (batch 6).**
    /// · `shell-library-note-reads-per-open-*` — **RECORDED (batch 6).**
    @Test func aLibraryRowOpensItsNoteThroughTheShellsPush() async throws {
        let big = try PerfWorlds.big.get()
        let world = try DiskWorld.copy(of: big, "library-open")
        defer { world.remove() }
        let rows = [("short", MobilePerfFixtureSeeder.controlPostTitle),
                    ("100k", MobilePerfFixtureSeeder.megaPostTitle)]

        try await withHerWorld(world) { session in
            for (label, title) in rows {
                var toScreen: [Double] = []
                var builds: [Double] = []
                var reads: [Double] = []
                for attempt in 0...Self.runs {
                    let router = MobileShellRouter()
                    let mountedAt = Probe.snap()
                    let shell = Mounted(MobileShellView(session: session, services: nil, router: router))
                    await waitUntil("the shell's Library listing") {
                        Probe.delta(.libraryDelivery, since: mountedAt) >= 1
                    }
                    await shell.surface.settle(10)
                    #expect(shell.surface.activate("Library"), "the Library's tab door")
                    // The band's settle animation, and a laid-out lazy list.
                    await shell.surface.settle(20)

                    // The row's button, found by its title (the row's spoken
                    // label begins with it — the Library suites match rows
                    // the same way), and pressed through UIKit's own
                    // activation dispatch.
                    let matches = shell.surface.visibleElements.filter {
                        $0.accessibilityLabel?.hasPrefix(title) == true
                    }
                    let row = matches.first { $0.accessibilityTraits.contains(.button) } ?? matches.first
                    let before = Probe.snap()
                    guard let row, row.accessibilityActivate() else {
                        let labels = Array(shell.surface.visibleLabels.prefix(30))
                        Issue.record("the \(label) note's Library row was not on screen; labels were \(labels)")
                        await shell.unmount(leavings: 0)
                        return
                    }
                    guard await waitUntil("\(label): the first live delivery", {
                        Probe.delta(.noteProjectionDelivery, since: before) >= 1
                    }) else { await shell.unmount(leavings: 0); return }
                    await waitUntil("\(label): the paint span") {
                        !Probe.newSamples(.noteOpenToScreen, since: before).isEmpty
                    }
                    await idle(.milliseconds(500))
                    if attempt > 0 {
                        toScreen += Probe.newSamples(.noteOpenToScreen, since: before)
                        let arrivals = Probe.delta(.noteArrival, since: before)
                        builds.append(
                            Double(Probe.delta(.editorBuilt, since: before)) / Double(max(arrivals, 1)))
                        reads += Probe.newSamples(.noteReadsPerOpen, since: before)
                    }
                    await shell.unmount(leavings: 1, report: false)
                }
                VM64Perf.report("shell-library-open-to-screen-\(label)", toScreen, .ms, expecting: Self.runs)
                // RECORDED (batch 6).
                VM64Perf.report(
                    "shell-library-editor-builds-per-open-\(label)", builds, .count, expecting: Self.runs)
                // RECORDED (batch 6, VM-69: 2 → 1).
                VM64Perf.report(
                    "shell-library-note-reads-per-open-\(label)", reads, .count, expecting: Self.runs)
            }
        }
    }

    // MARK: 4 · Typing in the box wakes the off-screen Library

    /// **What one capture-box autosave sets off in the Library she cannot
    /// see** (audit F 1E/§7), on the mounted shell, the Library alive off
    /// screen in the band as in the app, over the nine-wing world. Each run
    /// is one change to the box's text → the box's coordinator's one write
    /// (the real 500 ms debounce) → the layer's per-save windows (1 s).
    ///
    /// · `library-rereads-per-box-save` / `library-redraws-per-box-save` —
    ///   the layer's windows over BOTH held listings (all + bookless).
    /// · `all-listing-rereads-per-box-save` / `bookless-rereads-per-box-save`
    ///   — the layer's counters, split by listing (the Pool's is the
    ///   corpus × gatherings one, audit F §5).
    ///   **All four RECORDED: batch 5 (VM-68) stops a write that changes
    ///   nothing the Library shows from re-running a corpus-sized query or
    ///   redrawing the hidden Library — its pins turn these into assertions.**
    /// · `library-listing-fetch-ninewings` / `bookless-listing-fetch-ninewings`
    ///   — THIS TEST'S clock around the very queries the held listings re-run
    ///   (`Queries.library` and `Queries.poolPosts`, the phone's 200 limit) on
    ///   this world: what each re-run costs off the main thread.
    @Test func typingInTheBoxWakesTheOffScreenLibrary() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.nineWings.get(), "box-wakes")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            let router = MobileShellRouter()
            let mountedAt = Probe.snap()
            let shell = Mounted(MobileShellView(session: session, services: nil, router: router))
            await waitUntil("both Library listings' first delivery") {
                Probe.delta(.libraryDelivery, since: mountedAt) >= 1
                    && Probe.delta(.booklessDelivery, since: mountedAt) >= 1
            }
            router.quickNote.text = "Typing in the box"
            await waitUntil("the box's mint") { router.quickNote.postID != nil }
            // Let the mint's own wake-ups pass before the first measured save.
            await idle(.milliseconds(1500))

            var rereads: [Double] = []
            var redraws: [Double] = []
            var allRereads: [Double] = []
            var booklessRereads: [Double] = []
            for attempt in 0...Self.runs {
                let before = Probe.snap()
                router.quickNote.text += " word\(attempt)"
                await waitUntil("the box's autosave write") {
                    Probe.delta(.autosaveWrite, since: before) >= 1
                }
                // The per-save windows close after a second (or at the next
                // save — there is none until this has been read).
                await idle(.milliseconds(1300))
                let windows = (Probe.newSamples(.libraryRereadsPerSave, since: before),
                               Probe.newSamples(.libraryRedrawsPerSave, since: before))
                if attempt > 0 {
                    rereads += windows.0
                    redraws += windows.1
                    allRereads.append(Double(Probe.delta(.libraryFetch, since: before)))
                    booklessRereads.append(Double(Probe.delta(.booklessFetch, since: before)))
                }
            }
            // RECORDED (batch 5, VM-68).
            VM64Perf.report("library-rereads-per-box-save", rereads, .count, expecting: Self.runs)
            VM64Perf.report("library-redraws-per-box-save", redraws, .count, expecting: Self.runs)
            VM64Perf.report("all-listing-rereads-per-box-save", allRereads, .count, expecting: Self.runs)
            VM64Perf.report("bookless-rereads-per-box-save", booklessRereads, .count, expecting: Self.runs)

            var libraryFetch: [Double] = []
            var booklessFetch: [Double] = []
            // The phone Library's listing limit (`MobileLibraryViewModel.init`'s
            // default — the shell builds it with no other value).
            let limit = 200
            for _ in 0..<Self.runs {
                var t0 = CACurrentMediaTime()
                _ = try await session.database.read { db in
                    try Queries.library(db, sort: .lastTouched, direction: .desc, limit: limit)
                }
                libraryFetch.append(milliseconds(since: t0))
                t0 = CACurrentMediaTime()
                _ = try await session.database.read { db in try Queries.poolPosts(db, limit: limit) }
                booklessFetch.append(milliseconds(since: t0))
            }
            VM64Perf.report("library-listing-fetch-ninewings", libraryFetch, .ms, expecting: Self.runs)
            VM64Perf.report("bookless-listing-fetch-ninewings", booklessFetch, .ms, expecting: Self.runs)

            await shell.unmount(leavings: 0)
        }
    }

    // MARK: 5 · Owner adoption at fixture scale, nothing to adopt

    /// **What every launch and every unlock pays before sync starts** (audit F
    /// 3A, 6A), at the 100k proving ground's scale on an on-disk encrypted
    /// store, with NOTHING to adopt — the ordinary case on her phone, where
    /// every row was adopted long ago.
    ///
    /// `AppServices.runOwnerAdoption` is private to a composition a test host
    /// cannot build (auth, sync, custody), so its body is run here VERBATIM —
    /// the same op on the same runner between the layer's own two marks — and
    /// the layer's `ownerAdoption` / `ownerAdoptionRows` series are read. The
    /// first run (which stamps every row) is not a sample.
    ///
    /// · `owner-adoption-nothing-to-adopt` — **RECORDED: batch 4 (VM-67)
    ///   stops this costing a scan of every synced table.**
    /// · `owner-adoption-rows-nothing-to-adopt` — **ASSERTED zero**: adoption
    ///   is idempotent by contract ("a second run adopts nothing",
    ///   `Operations.adoptOwnerID`), and batch 4 must keep it so.
    /// · **VM-67's guarantee, ASSERTED** after the series (batch 4): with
    ///   nothing unowned, a pass runs no write statement on the store's
    ///   writer and reads every owner table only through its unowned-row
    ///   index — red on the pre-fix build (`OwnerAdoptionTrace`).
    @Test func ownerAdoptionWithNothingToAdoptIsMeasuredAtFixtureScale() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.big.get(), "owner")
        defer { world.remove() }

        try await withHerWorld(world, owner: "vm66-perf-owner") { session in
            /// `AppServices.runOwnerAdoption`'s body, verbatim (its marks
            /// included); answers the rows it stamped.
            func runOwnerAdoption() async -> Int? {
                let timing = AppTiming.ownerAdoptionStarted()
                do {
                    let report = try await session.runner.run { ops in try ops.adoptOwnerID() }
                    AppTiming.ownerAdoptionEnded(timing, rows: report.total)
                    return report.total
                } catch {
                    AppTiming.ownerAdoptionEnded(timing, rows: nil)
                    Issue.record("owner adoption refused: \(error)")
                    return nil
                }
            }

            let first = await runOwnerAdoption()
            #expect((first ?? 0) > 0, "the fixture's rows were born unowned, so the first run adopts them")
            let before = Probe.snap()
            for _ in 0..<Self.runs { _ = await runOwnerAdoption() }
            let durations = Probe.newSamples(.ownerAdoption, since: before)
            let rows = Probe.newSamples(.ownerAdoptionRows, since: before)
            // RECORDED (batch 4, VM-67).
            VM64Perf.report("owner-adoption-nothing-to-adopt", durations, .ms, expecting: Self.runs)
            VM64Perf.report("owner-adoption-rows-nothing-to-adopt", rows, .count, expecting: Self.runs)
            // ASSERTED — the idempotence contract.
            #expect(rows.allSatisfy { $0 == 0 }, "nothing unowned ⇒ nothing adopted")
            print("PERF[sim] owner adoption — the first run stamped \(first ?? -1) rows at the 100k scale")

            // VM-67 (the VM-64 run, batch 4) — THE GUARANTEE behind the series
            // above, ASSERTED here at fixture scale on the encrypted on-disk
            // store: with nothing unowned, one more pass (after the series, so
            // the measured runs stay untraced; the op called the way
            // `runOwnerAdoption` calls it) runs NO write statement on the
            // store's writer — no BEGIN, no UPDATE, no COMMIT — and every
            // statement it runs reads an owner table only through that
            // table's unowned-row index (v1_38), never a scan. RED on the
            // pre-fix build: BEGIN IMMEDIATE + eleven UPDATEs, each
            // `SCAN <table>` over the whole fixture.
            let log = try OwnerAdoptionTrace.start(on: world.db)
            let quiet = try await session.runner.run { ops in try ops.adoptOwnerID() }
            try OwnerAdoptionTrace.stop(on: world.db)
            let statements = log.value
            #expect(quiet.total == 0)
            let writes = statements.filter { OwnerAdoptionTrace.writeVerbs.contains($0.verb) }
            #expect(writes.isEmpty, "VM-67: nothing unowned ⇒ no write statement; ran \(writes.map(\.sql))")
            let plans = try OwnerAdoptionTrace.planReadings(world.db, statements)
            #expect(plans.violations.isEmpty, "VM-67: adoption scanned an owner table: \(plans.violations)")
            #expect(plans.reached == plans.ownerTables, "VM-67: every owner table checked (the oracle ran)")
        }
    }

    // MARK: 6 · Savepoints per leaving: a note, and the app

    /// **A note left (popped) after an edit** — the layer's window
    /// (`savepointsPerLeaving`) from the screen's `onDisappear` over the
    /// savepoint attempts it sets off. **ASSERTED ≥ 1**: an edited note's
    /// leaving is savepointed (PR7 — the cadence occasion, OverallModel §3);
    /// the exact count is RECORDED (batch 7, VM-71: one per note that needs
    /// one).
    ///
    /// The window would close itself 10 s after the leaving; this test closes
    /// it once the leaving's own work has finished (the layer's `noteLeave`
    /// span) plus half a second, so five runs do not take a minute — nothing
    /// else runs in between.
    @Test func leavingAnEditedNoteCountsItsSavepointAttempts() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.small.get(), "note-leaving")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            let notes = try await noteIDs(session.database, titled: "corpus note", limit: Self.runs + 1)
            try #require(notes.count == Self.runs + 1)
            // Hygiene: a leaving window an earlier test's teardown opened.
            Probe.recorder.cancelWindow(.savepointsPerLeaving)
            var attempts: [Double] = []
            for (attempt, postID) in notes.enumerated() {
                let model = MobileEditorViewModel(session: session, postID: postID)
                let router = MobileShellRouter()
                let opened = Probe.snap()
                let mounted = Mounted(MobileWriteScreen(
                    session: session, postID: postID, router: router, tab: .library, editor: model))
                await waitUntil("the first live delivery") {
                    Probe.delta(.noteProjectionDelivery, since: opened) >= 1
                }
                // An edit inside the debounce — she types, then leaves.
                if let storage = model.textView?.textStorage,
                   let at = interiorOffset(model, blockIndex: 0) {
                    typeEdit(model, storage, range: NSRange(location: at, length: 0), replacement: "x")
                } else {
                    Issue.record("no text to type into")
                }
                let before = Probe.snap()
                await mounted.unmount(leavings: 1)
                await idle(.milliseconds(500))
                Probe.recorder.closeWindow(.savepointsPerLeaving)
                if attempt > 0 {
                    attempts += Probe.newSamples(.savepointsPerLeaving, since: before)
                }
            }
            // RECORDED (batch 7, VM-71) — and the guarantee below.
            VM64Perf.report("savepoints-per-note-leaving", attempts, .count, expecting: Self.runs)
            #expect(attempts.allSatisfy { $0 >= 1 }, "an edited note's leaving is savepointed")
        }
    }

    /// **The app backgrounded with one edited note open** — the app's own
    /// two calls in its scene handler's order (`MobileTiming.appLeaving()`,
    /// then `mobileScenePhaseChanged(.background, …)`), over the real
    /// registered editor. Two arms:
    ///
    /// · **Standard** (no re-lock): the background flush's savepoint.
    /// · **Castle** (her phone): the flush, then the re-lock — the phone's
    ///   own `onWillLock` (`mobileWillLock`: flush + savepoints again) and the
    ///   `.ready` tree's removal (the bootstrap's state flip, `MountGate`),
    ///   whose screen's `onDisappear` savepoints a third time. The pool close
    ///   and the key drop are not run (no store is really locked here).
    ///
    /// `savepoints-per-backgrounding-*`: **RECORDED — audit F 6C's "up to
    /// three"; batch 7 (VM-71) makes it one per note that needs one.**
    /// **ASSERTED ≥ 1**: an edited open note is savepointed on backgrounding
    /// (PR7 — backgrounding is the phone's ⌘Q).
    @Test func backgroundingWithAnEditedNoteOpenCountsItsSavepointAttempts() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.small.get(), "app-leaving")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            let notes = try await noteIDs(session.database, titled: "corpus note", limit: 2)
            try #require(notes.count == 2)
            Probe.recorder.cancelWindow(.savepointsPerLeaving)
            for (arm, castle) in [("standard", false), ("castle", true)] {
                var attempts: [Double] = []
                for attempt in 0...Self.runs {
                    let postID = notes[attempt % notes.count]
                    let model = MobileEditorViewModel(session: session, postID: postID)
                    let router = MobileShellRouter()
                    let opened = Probe.snap()
                    let mounted = Mounted(MobileWriteScreen(
                        session: session, postID: postID, router: router, tab: .library, editor: model))
                    await waitUntil("\(arm): the first live delivery") {
                        Probe.delta(.noteProjectionDelivery, since: opened) >= 1
                    }
                    if let storage = model.textView?.textStorage,
                       let at = interiorOffset(model, blockIndex: 0) {
                        typeEdit(model, storage, range: NSRange(location: at, length: 0), replacement: "y")
                    } else {
                        Issue.record("\(arm): no text to type into")
                    }

                    let before = Probe.snap()
                    let relock: MobileRelockCoordinator? = castle
                        ? MobileRelockCoordinator(
                            policy: { RoadRelockPolicy(idleMinutes: 10) },
                            lock: {
                                // `AppBootstrap.lockOnNewRoad`'s order: the
                                // phone's onWillLock, then the state flip.
                                await mobileWillLock(
                                    session: session, editors: router.editors, stopServices: {})()
                                mounted.gate.mounted = false
                            })
                        : nil
                    MobileTiming.appLeaving()
                    let work = mobileScenePhaseChanged(
                        .background, editors: router.editors, sync: nil,
                        quickNote: router.quickNote,
                        savepoint: { await session.savepointOnLeaving($0) },
                        grant: .none, relock: relock)
                    await work?.value
                    if castle {
                        // The removed screen's own leaving (its `onDisappear`).
                        await waitUntil("\(arm): the torn-down screen's leaving") {
                            !Probe.newSamples(.noteLeave, since: before).isEmpty
                        }
                    }
                    await idle(.milliseconds(500))
                    Probe.recorder.closeWindow(.savepointsPerLeaving)
                    if attempt > 0 {
                        attempts += Probe.newSamples(.savepointsPerLeaving, since: before)
                    }
                    // Standard: the app came back and the note stays open —
                    // take it down now, outside the measured window.
                    await mounted.unmount(leavings: castle ? 0 : 1, report: false)
                    Probe.recorder.cancelWindow(.savepointsPerLeaving)
                }
                // RECORDED (batch 7, VM-71) — and the guarantee below.
                VM64Perf.report("savepoints-per-backgrounding-\(arm)", attempts, .count, expecting: Self.runs)
                #expect(attempts.allSatisfy { $0 >= 1 }, "\(arm): an edited open note is savepointed")
            }
        }
    }

    // MARK: 7 · The autosave registry across opens and closes

    /// **Each note opened and closed leaves its autosave coordinator behind**
    /// (audit F §4, §12.4 — the phone never releases an editor's). The
    /// session's registry size (`openAutosaveCount`) before and after each
    /// open-and-close of a DIFFERENT note, through the real screen.
    ///
    /// `autosave-registry-growth-per-open-close`: **RECORDED — batch 6
    /// (VM-70) releases the coordinator when its note closes, and its pin
    /// turns this into "no growth", red on today's code.**
    @Test func theAutosaveRegistryAcrossOpensAndCloses() async throws {
        let world = try DiskWorld.copy(of: try PerfWorlds.small.get(), "registry")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            let notes = try await noteIDs(session.database, titled: "corpus note", limit: Self.runs)
            try #require(notes.count == Self.runs)
            let start = session.openAutosaveCount
            var growth: [Double] = []
            for postID in notes {
                let router = MobileShellRouter()
                let sizeBefore = session.openAutosaveCount
                let opened = Probe.snap()
                let mounted = Mounted(MobileWriteScreen(
                    session: session, postID: postID, router: router, tab: .library))
                await waitUntil("the first live delivery") {
                    Probe.delta(.noteProjectionDelivery, since: opened) >= 1
                }
                await mounted.unmount(leavings: 1)
                growth.append(Double(session.openAutosaveCount - sizeBefore))
            }
            // RECORDED (batch 6, VM-70).
            VM64Perf.report("autosave-registry-growth-per-open-close", growth, .count, expecting: Self.runs)
            print("PERF[sim] autosave registry — \(start) → \(session.openAutosaveCount) "
                + "after \(Self.runs) notes opened and closed")
        }
    }

    // MARK: 8 · One typing pause in the 100k note

    /// **What a typing pause costs in a 100k note with its live updates
    /// running** (audit F §4 "the autosave echo", §7): one key, the real
    /// debounce, the write, and what the write sets off.
    ///
    /// · `note-rereads-per-save-100k` — the layer's window
    ///   (`noteRereadsPerSave`): whole-note re-reads in the second after the
    ///   write.
    /// · `note-deliveries-per-save-100k` — the layer's counter: deliveries to
    ///   the main thread per save (the echo delivers because the take's text
    ///   changed).
    /// · `note-delivery-ingest-100k` — THIS TEST'S clock around the model's
    ///   own `ingest(_:fromDelivery: true)` of a fresh projection, the
    ///   steady-state (echo) arm: the main-thread work one delivery does —
    ///   fan adoption, `ledger.matches` over the whole note, a `.document`
    ///   chrome pass (the projection's read is off the main thread and not
    ///   inside it).
    ///
    /// **All three RECORDED.** This run's batches do not promise to change
    /// them (batch 6 settles the OPEN's reads, not the per-save echo); the
    /// per-pause echo is the second speed pass's (wave 4, VM-176 — "typing
    /// in long notes"), and these are its before numbers too.
    @Test func oneTypingPauseInTheHundredKNoteIsMeasured() async throws {
        let big = try PerfWorlds.big.get()
        let megaID = try #require(big.seed.megaPostID)
        let world = try DiskWorld.copy(of: big, "typing-pause")
        defer { world.remove() }

        try await withHerWorld(world) { session in
            let model = MobileEditorViewModel(session: session, postID: megaID)
            let router = MobileShellRouter()
            let opened = Probe.snap()
            let mounted = Mounted(MobileWriteScreen(
                session: session, postID: megaID, router: router, tab: .library, editor: model))
            guard await waitUntil("the 100k note's first live delivery", {
                Probe.delta(.noteProjectionDelivery, since: opened) >= 1
            }) else { await mounted.unmount(leavings: 0); return }
            await idle(.milliseconds(500))
            let at = try #require(interiorOffset(model, blockIndex: 1))

            var rereads: [Double] = []
            var deliveries: [Double] = []
            for attempt in 0...Self.runs {
                let storage = try #require(model.textView?.textStorage)
                let before = Probe.snap()
                #expect(typeEdit(model, storage, range: NSRange(location: at + attempt, length: 0),
                                 replacement: "x"), "the key was accepted")
                await waitUntil("the typed pause's autosave write") {
                    Probe.delta(.autosaveWrite, since: before) >= 1
                }
                await idle(.milliseconds(1300))
                if attempt > 0 {
                    rereads += Probe.newSamples(.noteRereadsPerSave, since: before)
                    deliveries.append(Double(Probe.delta(.noteProjectionDelivery, since: before)))
                }
            }

            var ingest: [Double] = []
            await waitUntil("the buffer to settle clean") { !model.autosave.isDirty }
            for _ in 0..<Self.runs {
                let projection = try await session.database.read { db in
                    try Queries.takesProjection(db, post: megaID)
                }
                let t0 = CACurrentMediaTime()
                model.ingest(projection, fromDelivery: true)
                ingest.append(milliseconds(since: t0))
                await idle(.milliseconds(50))
            }
            // RECORDED (wave 4, VM-176).
            VM64Perf.report("note-rereads-per-save-100k", rereads, .count, expecting: Self.runs)
            VM64Perf.report("note-deliveries-per-save-100k", deliveries, .count, expecting: Self.runs)
            VM64Perf.report("note-delivery-ingest-100k", ingest, .ms, expecting: Self.runs)
            #expect(model.identityAuditFailures == 0)

            await mounted.unmount(leavings: 1, report: false)
        }
    }
}
