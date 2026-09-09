//
//  SurfaceSizeMemoryTests.swift
//  VariorumTests
//
//  The 2026-09-06 use-report round, 18d batch 4 — **REMEMBERED NOTE
//  LENGTHS** (ledger row 25; her ruling U-12, verbatim: *"I see no reason
//  why we wouldn't add in remembering the length of notes so it can be
//  perfect after the first time"*).
//
//  Row 25 is a RULED row, not a bug class: before this batch the memory was
//  session-only BY DESIGN (`StableSurface.swift`'s batch-H header said so),
//  so there is no pre-fix tree on which a persistence pin could be red — the
//  capability did not exist. What IS pinned here is every promise the new
//  store makes, and the first pin states the OLD behaviour beside the new
//  one so the change is legible: a session-only memory (`init()`, still the
//  default, still what `ReadingFlowEstimateTests`' host uses) forgets, and a
//  namespaced one does not.
//
//  Five pins:
//   1. the round trip — a size persisted, read back by a FRESH memory (the
//      relaunch), refused under another typography, and returned again when
//      that typography comes back;
//   2. THE WRITE CADENCE — `remember` never touches the disk (a live editor
//      calls it on every keystroke's height change; `UserDefaults.set` costs
//      ~100 µs), `persist` writes once, and a settle that re-adopts the size
//      already stored writes nothing;
//   3. mounted, through the real `StableSurface`: a PERSISTED memory taller
//      than the surface settles DOWN onto the disk, and a shorter one settles
//      UP — the R1-1 rule's honesty now surviving the launch;
//   4. mounted: a persisted memory taken at ANOTHER WIDTH reserves nothing —
//      the width rides the record, so the refusal survives the launch too;
//   5. the two key spaces never read each other, an unreadable record is
//      simply no memory, and `forget` ends one.
//
//  `StableSurfaceTests` is untouched and rides unmodified: this batch changed
//  no line of `StableSurface` itself.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// Counts the writes so the cadence can be pinned rather than asserted.
private final class CountingDefaults: UserDefaults, @unchecked Sendable {
    var writes = 0

    override func set(_ value: Any?, forKey defaultName: String) {
        writes += 1
        super.set(value, forKey: defaultName)
    }
}


/// A bare session (the `ExportFacesTests` shape) — enough to write an
/// appearance setting and run the theme's own observation over it.
@MainActor
private func withSession<T>(
    _ body: @MainActor (AppSession) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_783_900_800)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 12))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

/// The typography in force, movable by hand (the voice switch, without a
/// theme store).
@MainActor
private final class Stamp {
    var value: String? = "terminal-14-7"
}

@MainActor
@Suite("A note's remembered length outlives the launch (18d batch 4 — row 25 · U-12)", .serialized)
struct SurfaceSizeMemoryTests {

    // MARK: - 1. The round trip, and the typography refusal

    @Test func aSettledSizeIsReadBackByAFreshMemoryAndRefusedUnderAnotherTypography() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let stamp = Stamp()
        func memory() -> SurfaceSizeMemory {
            SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { stamp.value })
        }
        let settled = CGSize(width: 696, height: 20154.5)

        // THE OLD BEHAVIOUR, stated: a session-only memory keeps a size for
        // as long as it lives and hands nothing to its successor.
        let sessionOnly = SurfaceSizeMemory()
        sessionOnly.remember("p1", settled)
        #expect(sessionOnly.size("p1") == settled)
        #expect(SurfaceSizeMemory().size("p1") == nil,
                "a session-only memory is exactly what it was before this batch")

        // A report alone reaches no disk (pin 2 measures this; here it is the
        // reason the round trip needs the settle).
        let first = memory()
        first.remember("p1", settled)
        #expect(memory().size("p1") == nil, "…nothing is stored until the surface settles")

        // The settle: a FRESH memory — the next launch — knows the size.
        first.persist("p1")
        #expect(memory().size("p1") == settled,
                "her ruling: perfect after the first time")

        // The voice switches: the record was taken under type that no longer
        // stands, so it is refused exactly as a record at another width is.
        stamp.value = "IowanOldStyle-Roman-16-8"
        #expect(memory().size("p1") == nil,
                "a memory taken under another typography reserves nothing")
        // …and it was refused, never destroyed: the old voice comes back and
        // so does the memory.
        stamp.value = "terminal-14-7"
        #expect(memory().size("p1") == settled)

        // The stamp is felt WITHIN a session too, not only across launches.
        let live = memory()
        #expect(live.size("p1") == settled)
        stamp.value = "IowanOldStyle-Roman-16-8"
        #expect(live.size("p1") == nil)
    }

    /// The two voices really do stamp differently — the refusal above is not
    /// pinned against a string only this test believes in.
    @Test func theTypographyStampSeparatesTheTwoVoices() {
        let terminal = EditorTypography.resolve(voice: .terminal, inlineComments: false)
        let study = EditorTypography.resolve(voice: .study, inlineComments: false)
        let comments = EditorTypography.resolve(voice: .terminal, inlineComments: true)
        func stamp(_ resolved: EditorTypography.Resolved) -> String {
            let restore = EditorTypography.current
            let wasAdopted = EditorTypography.isAdopted
            defer {
                EditorTypography.current = restore
                EditorTypography.isAdopted = wasAdopted
            }
            EditorTypography.adopt(resolved)
            return EditorTypography.fingerprint ?? "<unadopted>"
        }
        #expect(stamp(terminal) != stamp(study), "Terminal's 14-pt mono ≠ Study's 16-pt Iowan")
        #expect(stamp(terminal) != stamp(comments), "…and inline comments move the paragraph gap")
        #expect(!stamp(study).contains("|"), "the stamp never contains the record's separator")
        #expect(!FlowHeightEstimate.fingerprint.contains("|"))
        #expect(FlowHeightEstimate.fingerprint != stamp(terminal),
                "the page's type is its own — the flow's memories are not the Outline's")

        // 18d ladder MINOR-2: before the settings land there is no stamp to
        // give — not the leading voice's, which would be a guess.
        let restore = EditorTypography.current
        let wasAdopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = restore
            EditorTypography.isAdopted = wasAdopted
        }
        // Round 2, NIT-2: the window in which this process global is not
        // what the app left it is ONE statement long — captured, put back,
        // and only then asserted (a concurrently mounting surface in another
        // suite reads these).
        EditorTypography.isAdopted = false
        let unadopted = EditorTypography.fingerprint
        EditorTypography.current = restore
        EditorTypography.isAdopted = wasAdopted
        #expect(unadopted == nil, "an unadopted typography names no voice")
    }

    // MARK: - 2. The write cadence

    @Test func geometryCadenceNeverWritesAndASettledSizeWritesOnce() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = CountingDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let memory = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })

        // A live editor reports a new height on every keystroke that reflows.
        for step in 0..<200 {
            memory.remember("p1", CGSize(width: 696, height: 900 + CGFloat(step)))
        }
        #expect(defaults.writes == 0,
                "geometry cadence never touches UserDefaults (~100 µs a call — 17o batch b)")

        memory.persist("p1")
        #expect(defaults.writes == 1, "the settle writes once")

        // The surface settles again at the SAME size — the common case for a
        // note read and left alone: nothing more is written.
        memory.persist("p1")
        memory.remember("p1", CGSize(width: 696, height: 1099))
        memory.persist("p1")
        #expect(defaults.writes == 1, "a settle that re-adopts the stored size writes nothing")

        // A real change does write.
        memory.remember("p1", CGSize(width: 696, height: 2000))
        memory.persist("p1")
        #expect(defaults.writes == 2)

        // And a memory that reads a record back does not re-write it.
        let fresh = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
        #expect(fresh.size("p1") == CGSize(width: 696, height: 2000))
        fresh.persist("p1")
        #expect(defaults.writes == 2, "reading a record back is not a reason to write it again")
    }

    // MARK: - 3 & 4. Mounted, through the real StableSurface

    @MainActor
    private final class Frames {
        var rowHeight: CGFloat?
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    /// The Outline's own wiring, in miniature: the surface reads its memory,
    /// reports into it, and persists on the SETTLE (`BookView`'s two call
    /// sites, `BookViewModel.persistSurfaceSize`).
    private func mount(
        memory: SurfaceSizeMemory, key: String, content: CGSize, frames: Frames
    ) -> (NSWindow, NSHostingView<AnyView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 600, height: 900),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            VStack(alignment: .leading, spacing: 0) {
                StableSurface(
                    known: memory.size(key), followsShrinks: false,
                    settled: { memory.persist(key) },
                    remember: { memory.remember(key, $0) }
                ) {
                    Color.red.frame(width: content.width, height: content.height)
                }
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                    frames.rowHeight = $0
                }
                Spacer(minLength: 0)
            }
            .frame(width: 600, height: 900, alignment: .top)))
        hosting.frame = NSRect(x: 0, y: 0, width: 600, height: 900)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// A PERSISTED memory taller than the surface settles DOWN onto the disk,
    /// and a shorter one settles UP: R1-1's "honest in both directions" now
    /// survives the launch, so a stale record can never hold a blank gap under
    /// a story for more than one settle interval, ever again.
    @Test(arguments: [CGFloat(400), CGFloat(120)])
    func aPersistedMemoryIsCorrectedByTheSettleInBothDirections(stored: CGFloat) async throws {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        func memory() -> SurfaceSizeMemory {
            SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
        }

        // A previous launch left this record behind.
        let seed = memory()
        seed.remember("p1", CGSize(width: 400, height: stored))
        seed.persist("p1")

        let frames = Frames()
        let live = memory()
        #expect(live.size("p1") == CGSize(width: 400, height: stored),
                "the surface starts from what the last launch left")
        let (window, hosting) = mount(
            memory: live, key: "p1", content: CGSize(width: 400, height: 200), frames: frames)
        defer {
            window.orderOut(nil)
            window.close()
        }
        // Waiting on the DISK, not on the row: for a memory SHORTER than the
        // surface the row is already right on its first frame (a `minHeight`
        // never squashes content), so a pin that watched the row alone would
        // pass before the settle had written anything — it did, on the first
        // run of this pin, and read the stale 120 back.
        let corrected = await settle(
            window, hosting, timeout: stableSurfaceSettleInterval + 5
        ) {
            (frames.rowHeight.map { abs($0 - 200) < 1 } ?? false)
                && memory().size("p1") == CGSize(width: 400, height: 200)
        }
        let row = String(describing: frames.rowHeight)
        let disk = String(describing: memory().size("p1"))
        #expect(corrected,
                "the row ends at the content's height and the settle writes it: \(row) / \(disk)")
        #expect(memory().size("p1") == CGSize(width: 400, height: 200),
                "…and the settled size is what the NEXT launch reads")
    }

    /// A persisted memory taken at another WIDTH reserves nothing — the width
    /// rides the record, so `StableSurface`'s refusal (R1-1) is as true after
    /// a relaunch as it is inside a session.
    @Test func aPersistedMemoryAtAnotherWidthReservesNothing() async throws {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        func memory() -> SurfaceSizeMemory {
            SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
        }
        // Left behind by a launch at a narrower window.
        let seed = memory()
        seed.remember("p1", CGSize(width: 300, height: 400))
        seed.persist("p1")
        #expect(memory().size("p1") == CGSize(width: 300, height: 400),
                "the WIDTH round-trips — the comparison downstream has honest input")

        let frames = Frames()
        let (window, hosting) = mount(
            memory: memory(), key: "p1", content: CGSize(width: 400, height: 200), frames: frames)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let start = Date()
        let dropped = await settle(window, hosting, timeout: 3) {
            frames.rowHeight.map { abs($0 - 200) < 1 } ?? false
        }
        let elapsed = Date().timeIntervalSince(start)
        #expect(dropped, "a memory at another width reserves nothing: \(String(describing: frames.rowHeight))")
        #expect(elapsed < stableSurfaceSettleInterval,
                "…decided by the width comparison at once, not by the settle (\(elapsed) s)")
    }

    // MARK: - 5. The key spaces, the unreadable record, forgetting

    @Test func theTwoKeySpacesNeverMeetAndAnUnreadableRecordIsSimplyNoMemory() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let outline = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
        let flow = SurfaceSizeMemory(.flow, defaults: defaults, fingerprint: { "t" })

        // ONE note, TWO measures: Write's in the Outline, the page's on the
        // flow. Sharing a key would make each refuse the other's width
        // forever, one settle at a time.
        outline.remember("p1", CGSize(width: 696, height: 20000))
        outline.persist("p1")
        flow.remember("p1", CGSize(width: 600, height: 26000))
        flow.persist("p1")
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" }).size("p1")
                == CGSize(width: 696, height: 20000))
        #expect(SurfaceSizeMemory(.flow, defaults: defaults, fingerprint: { "t" }).size("p1")
                == CGSize(width: 600, height: 26000))
        #expect(SurfaceSizeMemory.key(.outline, "p1") != SurfaceSizeMemory.key(.flow, "p1"))

        // Anything this app did not write is no memory — never an error.
        for junk in ["", "nonsense", "696|", "696|20000", "|20000|t", "0|20000|t", "696|-3|t",
                     "696|nan|t", "a|b|c"] {
            defaults.set(junk, forKey: SurfaceSizeMemory.key(.outline, "junk"))
            #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
                        .size("junk") == nil, "unreadable: \(junk)")
        }
        // …and a fingerprint carrying its own separators still round-trips
        // (the record splits at most twice).
        defaults.set("696|20000|a-b-c", forKey: SurfaceSizeMemory.key(.outline, "odd"))
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "a-b-c" })
                    .size("odd") == CGSize(width: 696, height: 20000))

        // Forgetting ends it here and on disk (the note was deleted).
        let live = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" })
        #expect(live.size("p1") != nil)
        live.forget("p1")
        #expect(live.size("p1") == nil)
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { "t" }).size("p1") == nil)
        #expect(defaults.string(forKey: SurfaceSizeMemory.key(.outline, "p1")) == nil)
    }

    // MARK: - 6. The ladder's MINOR-2: the voice is known where it LANDS

    /// **RED ON OLD.** `ThemeStore.start` adopts the resolved typography the
    /// moment a settings value lands. Before this fix the only adoption was
    /// `RootView`'s `.onChange(of: theme.settings)` — a VIEW noticing — so in
    /// a host that runs the store without that view (and, in the app, for a
    /// SwiftUI update cycle after every launch) `EditorTypography.current`
    /// still named the compile-time default while the store already held her
    /// Study settings, and every Study-stamped record was refused.
    ///
    /// The pin forces a known ADOPTED Terminal state first, so its failure on
    /// the old tree cannot be an accident of whatever a parallel suite left
    /// in the process global — and restores what it found, for the same
    /// reason (batch 1's MINOR-3 class).
    @Test func theTypographyIsAdoptedWhereTheSettingsLandNotWhereAViewNoticesThem() async throws {
        try await withSession { session in
            let restore = EditorTypography.current
            let wasAdopted = EditorTypography.isAdopted
            defer {
                EditorTypography.current = restore
                EditorTypography.isAdopted = wasAdopted
            }
            EditorTypography.adopt(
                EditorTypography.resolve(voice: .terminal, inlineComments: false))
            let terminalStamp = EditorTypography.fingerprint

            try await session.runner.run { try $0.setThemeVoice(.study) }
            let store = ThemeStore(session: session)
            let task = Task { await store.start() }
            defer { task.cancel() }

            // Round 2, NIT-2: the process globals this pin moves are shared
            // across Swift Testing's parallel suites, so the window is kept
            // as small as the mechanism allows — a 2 s bound on an in-memory
            // store's single read, and the answer CAPTURED and the globals
            // put back before anything is asserted.
            let deadline = Date().addingTimeInterval(2)
            while Date() < deadline, store.settings.voice != .study {
                try? await Task.sleep(for: .milliseconds(10))
            }
            let landed = store.settings.voice
            let study = EditorTypography.fingerprint
            let adopted = EditorTypography.current
            EditorTypography.current = restore
            EditorTypography.isAdopted = wasAdopted

            #expect(landed == .study, "the settings landed")
            #expect(study != terminalStamp,
                    "the landing adopted the voice: \(String(describing: study))")
            #expect(adopted == EditorTypography.resolve(voice: .study, inlineComments: false),
                    "…and it is exactly the Study resolution, not merely a different one")
        }
    }

    /// **The clobber MINOR-2 names, and the fix.** A geometry report arriving
    /// before the voice is known used to stamp the SESSION record with the
    /// compile-time default and, one settle later, write that guess over the
    /// record she measured in her own voice. Now a report with no stamp is
    /// dropped and the loaded record stands.
    ///
    /// The first half REPRODUCES the old mechanism with a wrong-but-present
    /// stamp (green on both trees — it is the trace, not the pin); the second
    /// half is the pin, and it could not exist on the old tree, where the
    /// memory had no way to say "the voice is not known".
    @Test func aReportBeforeTheVoiceIsKnownNeitherStampsNorClobbers() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let study = "IowanOldStyle-Roman-16-8"
        let terminal = ".AppleSystemUIFontMonospaced-Regular-14-7"
        let hers = CGSize(width: 696, height: 20993)

        func seedHerRecord() {
            let seed = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { study })
            seed.remember("p1", hers)
            seed.persist("p1")
        }

        // THE MECHANISM (the old behaviour, reproduced): a report stamped with
        // a voice that is not hers replaces the loaded record, and the settle
        // writes the guess over her measurement.
        seedHerRecord()
        let guessing = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { terminal })
        _ = guessing.size("p1")                       // loads her record
        guessing.remember("p1", CGSize(width: 696, height: 40))
        guessing.persist("p1")
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { study })
                    .size("p1") == nil,
                "her Study record is gone — this is what MINOR-2 described")

        // THE FIX: with no stamp to write, the report is dropped and her
        // record survives the whole window.
        defaults.removeObject(forKey: SurfaceSizeMemory.key(.outline, "p1"))
        seedHerRecord()
        let stamp = Stamp()
        stamp.value = nil                              // the voice has not landed
        let unknowing = SurfaceSizeMemory(
            .outline, defaults: defaults, fingerprint: { stamp.value })
        // Round 2's MAJOR-1 refined this half: an unverifiable record is
        // still ANSWERED (a guess beats the unmeasured fallback, and refusing
        // it is what MINOR-2 was raised about). What the window forbids is
        // WRITING one.
        #expect(unknowing.size("p1") == hers, "the record is a guess, and a guess is answered")
        unknowing.remember("p1", CGSize(width: 696, height: 40))
        unknowing.persist("p1")
        stamp.value = study                            // the settings land
        #expect(unknowing.size("p1") == hers,
                "her record survived the window, in the very memory that saw the report")
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { study })
                    .size("p1") == hers,
                "…and on disk")
    }

    // MARK: - 7. The ladder's NIT-3: one occasion, every per-note memory

    /// **RED ON OLD.** The app's "this note's memories go" door
    /// (`CommandRouter.forgetCurrentBlock`) now drops the surface records in
    /// BOTH key spaces beside the current-block one. Before this it dropped
    /// only the current block, so a note's `surfaceSize.*` keys outlived it.
    @Test func theNotesEvictionDoorDropsEveryKeySpacesRecord() async throws {
        try await withSession { session in
            let postID = "walked-\(UUID().uuidString)"
            defer { SurfaceSizeMemory.forgetPersisted(postID) }
            let outline = SurfaceSizeMemory(.outline, fingerprint: { "t" })
            let flow = SurfaceSizeMemory(.flow, fingerprint: { "t" })
            outline.remember(postID, CGSize(width: 696, height: 20993))
            outline.persist(postID)
            flow.remember(postID, CGSize(width: 600, height: 20071))
            flow.persist(postID)
            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.outline, postID)) != nil)
            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.flow, postID)) != nil)

            session.commandRouter.forgetCurrentBlock(for: postID)

            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.outline, postID)) == nil,
                    "the Outline's record went with the note")
            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.flow, postID)) == nil,
                    "…and the flow's")
        }
    }

    // MARK: - 8. Round 2's MAJOR-1: the SECOND adoption door is closed

    /// **RED ON `ecacfa42`.** Round 1 gave `SurfaceSizeMemory` a guard —
    /// no stamp, no record — and then defeated it one door over:
    /// `applyVoiceChrome` called `EditorTypography.adopt`, and BOTH its hosts
    /// build that chrome from `themeStore?.settings ?? Queries.ThemeSettings()`,
    /// which is the compile-time Terminal placeholder both when there is no
    /// store AND while a real store has not answered. So a surface
    /// materializing in Study before the theme landed latched `isAdopted` on
    /// the guess, `fingerprint` went non-nil-and-wrong, and the guard stopped
    /// guarding.
    ///
    /// The pin reaches it through the PRODUCTION door — a real
    /// `EditorTextView` taking the chrome an un-answered store hands out —
    /// and then does what the flow's empty-read road does: `remember` and
    /// `persist` in the same turn, with no settle interval standing between a
    /// wrong stamp and the disk.
    @Test func aSurfaceTakingChromeBeforeTheVoiceLandsCannotRecordUnderTheGuess() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let restore = EditorTypography.current
        let wasAdopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = restore
            EditorTypography.isAdopted = wasAdopted
        }

        // Her record, written in her own voice by a previous launch. The
        // stamp is INJECTED, not read from the process global — round 2's
        // NIT-2: this suite touches that global for exactly as long as the
        // claim requires and no longer.
        let herStamp = "IowanOldStyle-Roman-16-8"
        let hers = CGSize(width: 696, height: 20993)
        let seed = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { herStamp })
        seed.remember("p1", hers)
        seed.persist("p1")

        // Everything the production door needs, built BEFORE the window.
        let textView = EditorTextView.makeInlineEditor()
        let unlanded = EditorSurfaceChrome(tokens: Queries.ThemeSettings(), dark: false)

        // THE WINDOW — one call long. The voice is not known; a surface
        // materializes and takes the chrome an UN-ANSWERED store hands out
        // (`ThemeStore.settings` IS `Queries.ThemeSettings()` until its
        // observation returns, which is also the hosts' own `?? ` fallback).
        EditorTypography.isAdopted = false
        textView.applyVoiceChrome(unlanded)
        let latched = EditorTypography.isAdopted
        EditorTypography.current = restore
        EditorTypography.isAdopted = wasAdopted
        #expect(latched == false,
                "drawing is not adopting — only the settings' authority adopts")

        // What that used to cost, replayed on an injected unknown stamp: the
        // memory wired as `BookViewModel` wires it, then the flow's own
        // same-turn road (`remember` then `persist`, no settle between).
        let stamp = Stamp()
        stamp.value = nil
        let live = SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { stamp.value })
        #expect(live.size("p1") == hers,
                "her record is answered as a guess — refusing it is MINOR-2's own complaint")
        live.remember("p1", CGSize(width: 696, height: 40))
        live.persist("p1")

        stamp.value = herStamp
        #expect(live.size("p1") == hers, "her record survived the surface's guess")
        #expect(SurfaceSizeMemory(.outline, defaults: defaults, fingerprint: { herStamp })
                    .size("p1") == hers, "…and on disk")
    }

    /// **The round-end Fable pass, MINOR-1 (the 18d cap's residue, J44).**
    /// Round 2 closed the LATCH — `applyVoiceChrome` no longer adopts — and
    /// left the VALUE the latch guards writable by any drawing host: it still
    /// wrote `EditorTypography.current` unconditionally, and `fingerprint`
    /// derives from `current` once adopted. The app mints one `ThemeStore`
    /// per window kind, each holding the Terminal placeholder until its own
    /// read returns, so a NOTE WINDOW opened in a Study session applied a
    /// Terminal chrome under `isAdopted == true`: the stamp became the
    /// monospace, her Study-stamped lengths were REFUSED in the main window's
    /// Outline, and a settle in that window wrote a Study-measured height
    /// under the Terminal stamp over her record.
    ///
    /// Through the production door, one statement wide: her session is
    /// adopted (Study), her record stands, a real inline editor takes the
    /// chrome an UN-LANDED store hands out — and the stamp must not move, her
    /// record must still be answered, and the flow's same-turn `remember` +
    /// `persist` must write under HER stamp. The process globals are captured
    /// and put back before anything is asserted (round 2's NIT-2).
    ///
    /// RED ON OLD (measured by behavioural revert of the one line): the stamp
    /// moved to `.AppleSystemUIFontMonospaced-Regular-14-7`, her record was
    /// refused, and the disk record ended in the monospace stamp.
    @Test func aDrawingHostCannotMoveTheStampOnceTheVoiceIsAdopted() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let restore = EditorTypography.current
        let wasAdopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = restore
            EditorTypography.isAdopted = wasAdopted
        }
        let textView = EditorTextView.makeInlineEditor()
        let unlanded = EditorSurfaceChrome(tokens: Queries.ThemeSettings(), dark: false)
        let hers = CGSize(width: 696, height: 20993)
        let live = SurfaceSizeMemory(
            .outline, defaults: defaults, fingerprint: { EditorTypography.fingerprint })

        // THE WINDOW: adopted in Study, her record written in her voice, then
        // the second window's un-landed chrome — and the flow's same-turn road
        // replayed under whatever stamp that left behind.
        EditorTypography.adopt(EditorTypography.resolve(voice: .study, inlineComments: false))
        let herStamp = EditorTypography.fingerprint
        live.remember("p1", hers)
        live.persist("p1")
        textView.applyVoiceChrome(unlanded)
        let stampAfter = EditorTypography.fingerprint
        let answered = live.size("p1")
        live.remember("p1", CGSize(width: 696, height: 40))
        live.persist("p1")
        let onDisk = defaults.string(forKey: SurfaceSizeMemory.key(.outline, "p1"))
        EditorTypography.current = restore
        EditorTypography.isAdopted = wasAdopted

        let study = try? #require(herStamp)
        #expect(study?.contains("Iowan") == true, "the adopted stamp is Study's: \(String(describing: herStamp))")
        #expect(stampAfter == herStamp,
                "a drawing host cannot move the stamp once the voice is adopted: \(String(describing: stampAfter)) vs \(String(describing: herStamp))")
        #expect(answered == hers,
                "her Study record is still answered after the un-landed chrome: \(String(describing: answered))")
        #expect(onDisk?.hasSuffix("|\(herStamp ?? "?")") == true,
                "the same-turn remember + persist wrote under HER stamp, never the guess: \(String(describing: onDisk))")
    }

    /// **The round-end Fable pass, round 2 — MINOR-1: the stamp moves with the
    /// paragraph-gap dial.** This Mac's A23 setting (`ParagraphGap`) adds a
    /// whole line after EVERY paragraph under `.paragraphTall`, and it reaches
    /// the surface through `EditorDocument.baseParagraphStyle`, NOT through
    /// `resolve` — so the stamp, derived from `Resolved` alone, did not move
    /// with it, and a height measured under `.standard` was ANSWERED under
    /// `.paragraphTall`: a wrong reservation for one settle on every
    /// remembered note, the moment she flipped the dial (the chrome's
    /// `Equatable` gate re-styles every mounted surface at once; the stored
    /// records kept the old stamp). Now the stamp and the layout read ONE
    /// arithmetic, `EditorTypography.laidOutParagraphSpacing`.
    ///
    /// The globals and the defaults key are captured and put back before
    /// anything is asserted (round 2's NIT-2; `ParagraphGapTests.withGap`'s
    /// own restore shape). Every flipper of this key in the suite is
    /// `@MainActor` and this body is synchronous, so nothing can move the key
    /// inside it.
    ///
    /// RED ON OLD (measured by behavioural revert of the one line in
    /// `fingerprint`, in place on the committed tree): the stamp read
    /// `.AppleSystemUIFontMonospaced-Regular-14-7` under BOTH gaps, and her
    /// record was answered under the tall one.
    @Test func aParagraphGapChangeMovesTheStamp() {
        let suiteName = "surface-size-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let restore = EditorTypography.current
        let wasAdopted = EditorTypography.isAdopted
        let savedGap = UserDefaults.standard.string(forKey: ParagraphGap.settingKey)
        defer {
            EditorTypography.current = restore
            EditorTypography.isAdopted = wasAdopted
            if let savedGap {
                UserDefaults.standard.set(savedGap, forKey: ParagraphGap.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: ParagraphGap.settingKey)
            }
        }
        EditorTypography.adopt(EditorTypography.resolve(voice: .terminal, inlineComments: false))
        let live = SurfaceSizeMemory(
            .outline, defaults: defaults, fingerprint: { EditorTypography.fingerprint })

        // Her record, measured under the standard gap…
        UserDefaults.standard.set(ParagraphGap.standard.rawValue, forKey: ParagraphGap.settingKey)
        let hers = CGSize(width: 696, height: 20993)
        live.remember("p1", hers)
        live.persist("p1")
        let standardStamp = EditorTypography.fingerprint
        // …then the dial flipped: the stamp must move, and the record must
        // not be answered under a gap it was never measured in.
        UserDefaults.standard.set(ParagraphGap.paragraphTall.rawValue, forKey: ParagraphGap.settingKey)
        let tallStamp = EditorTypography.fingerprint
        let answered = live.size("p1")
        EditorTypography.current = restore
        EditorTypography.isAdopted = wasAdopted

        #expect(tallStamp != standardStamp,
                "a dial that changes every paragraph's height moves the stamp: \(String(describing: standardStamp)) vs \(String(describing: tallStamp))")
        #expect(answered == nil,
                "a height measured under one gap is not reserved under another: \(String(describing: answered))")
    }

    // MARK: - 9. Round 2's MINOR-3: the door the app really walks

    /// **RED ON `ecacfa42`.** Round 1 wired `forgetPersisted` to
    /// `CommandRouter.forgetCurrentBlock`, whose only callers were pins, and
    /// then said in two comments that the app walked it. J43's trace found
    /// the one production occasion where a note's per-note view state should
    /// die: the Mac's **Delete Now on a note** — the purge, not the delete,
    /// because a deleted note is in the Trash and Put back must find her
    /// caret and her lengths where she left them.
    ///
    /// The pin drives the real door end to end: a real note, deleted, listed
    /// in the Trash, confirmed through `RecoveryViewModel.confirmPendingPurge`
    /// — and asserts both per-note memories go with it.
    @Test func deleteNowOnANoteTakesItsPerNoteMemoriesWithIt() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let postID = editor.postID
            defer { SurfaceSizeMemory.forgetPersisted(postID) }

            // She read this note: a current block and both surface records.
            var blocks = CurrentBlockMemory()
            blocks.remember(
                FocusedBlock(
                    postID: postID,
                    blockID: try #require(editor.model.slots.first?.blockID),
                    variantID: nil, utf16Offset: 12))
            blocks.persist(postID: postID)
            let outline = SurfaceSizeMemory(.outline, fingerprint: { "t" })
            let flow = SurfaceSizeMemory(.flow, fingerprint: { "t" })
            outline.remember(postID, CGSize(width: 696, height: 20993))
            outline.persist(postID)
            flow.remember(postID, CGSize(width: 600, height: 20071))
            flow.persist(postID)
            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.outline, postID)) != nil)

            // The note goes to the Trash, and then for good.
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteContainer(postID)
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let note = try #require(rows.first { $0.kind == .note && !$0.isVersion })
            let model = RecoveryViewModel(session: editor.session)
            model.requestDeleteNow(note)
            await model.confirmPendingPurge(try #require(model.pendingConfirm))
            #expect(model.lastError == nil, "the purge went through: \(String(describing: model.lastError))")

            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.outline, postID)) == nil,
                    "the Outline's record went with the note")
            #expect(UserDefaults.standard.string(
                forKey: SurfaceSizeMemory.key(.flow, postID)) == nil, "…and the flow's")
            #expect(UserDefaults.standard.string(
                forKey: CurrentBlockMemory.key(postID)) == nil,
                    "…and the current block, through the same one door")
        }
    }
}
