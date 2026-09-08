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

/// The typography in force, movable by hand (the voice switch, without a
/// theme store).
@MainActor
private final class Stamp {
    var value = "terminal-14-7"
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
            defer { EditorTypography.current = restore }
            EditorTypography.current = resolved
            return EditorTypography.fingerprint
        }
        #expect(stamp(terminal) != stamp(study), "Terminal's 14-pt mono ≠ Study's 16-pt Iowan")
        #expect(stamp(terminal) != stamp(comments), "…and inline comments move the paragraph gap")
        #expect(!stamp(study).contains("|"), "the stamp never contains the record's separator")
        #expect(!FlowHeightEstimate.fingerprint.contains("|"))
        #expect(FlowHeightEstimate.fingerprint != stamp(terminal),
                "the page's type is its own — the flow's memories are not the Outline's")
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
}
