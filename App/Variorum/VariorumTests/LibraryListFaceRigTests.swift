//
//  LibraryListFaceRigTests.swift
//  VariorumTests
//
//  **17y B-WALK W-1's MEASUREMENT RIG — the Library List's FACE and FEEL,
//  before and after the engine change** (her #187(i) answer at the walk,
//  2026-10-05: "the scroll itself is not fine. it's noticeable how laggy it
//  is… there's glitching and lags on the way down. ew!! not in our app" —
//  the ruled road: the List's notes on the lazy column Cards uses, wearing
//  the List's EXACT face).
//
//  OPT-IN (`TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1`), never in a normal
//  run: it writes captures into the gitignored screens folder and runs a
//  timed scroll. The author is at the machine for this round, so every
//  capture and every number here comes from a MOUNTED test-host window —
//  never the running app, never a GUI drive. Committed AHEAD of the engine
//  change so the SAME rig produced the before and the after
//  (`TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE_LABEL=before|after` names the
//  files).
//
//  - **The face:** the same fixture mounted at the same size, the same
//    scroll positions, both voices, light → `bwalk/face/<label>-<voice>-
//    <position>.png`, plus a geometry dump (row pitch, the separators'
//    pixel rows, each row's ink edges — the trailing stamp's right edge
//    among them) → `<label>-<voice>-geometry.txt`.
//  - **The feel:** an 822-note listing (the walk fixture's size), the notes
//    region scrolled at a hand's speed by a DISPLAY-LINK-driven clip (each
//    tick advances by the elapsed time × the speed, so a stalled frame jumps
//    as a real fling's momentum would), every frame gap recorded →
//    `<label>-feel.txt` (mean, max, >25/>50/>100 ms) for the List AND, as
//    the cadence the List must meet, Cards.
//

import AppKit
import Dependencies
import Foundation
import QuartzCore
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG
nonisolated enum LibraryListFaceRig {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_LIBRARY_LIST_FACE"] == "1"
    }
    static var label: String {
        ProcessInfo.processInfo.environment["VARIORUM_LIBRARY_LIST_FACE_LABEL"] ?? "run"
    }
}

@MainActor
@Suite(
    "17y B-WALK W-1 — the List's face and feel, measured (opt-in; DISABLED unless VARIORUM_LIBRARY_LIST_FACE=1)",
    .serialized,
    .enabled(
        if: LibraryListFaceRig.requested,
        "writes captures and runs a timed scroll — run deliberately with TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1"))
struct LibraryListFaceRigTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(3_700) }
                return value
            }
        }
    }

    private static var outDir: URL {
        let dir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .deletingLastPathComponent()  // App
            .deletingLastPathComponent()  // repo
            .appending(path: "notes/plans/17y-screens/bwalk/face")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "17y-bwalk-face-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The face fixture: three books (the one-list shape), forty notes —
    /// tags (none · one · two), stated days, an untitled note that leads
    /// with its words.
    private func faceFixture(_ session: AppSession) throws {
        for name in ["Field Notes", "Journal", "Reading List"] {
            _ = try session.operations.createReading(name: name, kind: .book)
        }
        let travel = try session.operations.createTag(parent: nil, name: "travel")
        let drafts = try session.operations.createTag(parent: nil, name: "drafts")
        let titles = [
            "On the river at dusk", "A letter never sent", "Notes toward a chapter",
            "The long way home", "What the garden knew", "Morning pages",
            "An argument with myself", "A list of small things",
        ]
        for index in 0..<40 {
            let untitled = index % 11 == 7
            let note = try session.operations.createPost(
                title: untitled ? nil : "\(titles[index % titles.count]) \(index)",
                entryDate: index % 5 == 2 ? String(format: "2026-05-%02d", 1 + index % 27) : nil)
            _ = try session.operations.newBlock(
                in: note.id,
                text: untitled
                    ? "It is strange how a single word can hold a whole afternoon \(index)"
                    : "words of \(index)")
            if index % 3 != 0 { _ = try session.operations.applyTag(travel.id, toPost: note.id) }
            if index % 4 == 1 { _ = try session.operations.applyTag(drafts.id, toPost: note.id) }
        }
    }

    private func mount(
        _ session: AppSession, _ model: LibraryCatalogModel, theme: ThemeStore,
        width: CGFloat = 1000, height: CGFloat
    ) -> (NSWindow, NSHostingView<AnyView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        let hosting = NSHostingView(rootView: AnyView(
            LibraryCatalogView(
                session: session, model: model, library: LibraryViewModel(session: session),
                tags: TagsViewModel(session: session), onOpen: { _ in })
            .environment(theme)))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private static func scrollViews(in view: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        if let scroll = view as? NSScrollView { found.append(scroll) }
        for sub in view.subviews { found += scrollViews(in: sub) }
        return found
    }

    /// The scroll view carrying the notes — the tallest document.
    private static func notesScroll(in view: NSView) -> NSScrollView? {
        scrollViews(in: view).max {
            ($0.documentView?.frame.height ?? 0) < ($1.documentView?.frame.height ?? 0)
        }
    }

    private static func snapshot(_ view: NSView) -> NSBitmapImageRep? {
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
        view.cacheDisplay(in: view.bounds, to: rep)
        return rep
    }

    private static func write(_ rep: NSBitmapImageRep, _ name: String) {
        guard let data = rep.representation(using: .png, properties: [:]) else { return }
        try? data.write(to: outDir.appending(path: name))
    }

    private static func write(text: String, _ name: String) {
        try? text.write(to: outDir.appending(path: name), atomically: true, encoding: .utf8)
    }

    // MARK: - The face

    /// Same fixture, same size, same positions, both voices: the captures
    /// and the geometry the after must match.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theFace(voice: ThemeVoice) async throws {
        try await withLibrary { session in
            try faceFixture(session)
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("face"))
            await model.search()
            LibraryPanelOracle.reset()
            let (window, hosting) = mount(session, model, theme: theme, height: 720)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, 1.5)
            let label = LibraryListFaceRig.label
            var report = "# \(label) · \(voice) · 1000×720 · scope All · List\n"
            report += geometry(hosting, model: model, title: "top")
            if let rep = Self.snapshot(hosting) {
                Self.write(rep, "\(label)-\(voice)-top.png")
                report += Self.pixelReport(rep, scale: rep.size.width > 0
                    ? CGFloat(rep.pixelsWide) / rep.size.width : 2)
            }

            // Scrolled: the notes' region, 300 pt down (a header pinned over
            // rows under it, in either engine).
            if let scroll = Self.notesScroll(in: hosting) {
                let clip = scroll.contentView
                clip.scroll(to: NSPoint(x: 0, y: 300))
                scroll.reflectScrolledClipView(clip)
                await settle(window, hosting, 1.0)
                if let rep = Self.snapshot(hosting) {
                    Self.write(rep, "\(label)-\(voice)-scrolled300.png")
                }
                clip.scroll(to: NSPoint(x: 0, y: 0))
                scroll.reflectScrolledClipView(clip)
                await settle(window, hosting, 0.6)
            }

            // The pick and the panel's subject: one row selected (the panel
            // opens), a second ⌘-picked.
            let ids = model.listedNoteIDs
            if ids.count > 3 {
                model.clickNoteRow(ids[1], modifiers: .init(command: false, shift: false))
                model.clickNoteRow(ids[3], modifiers: .init(command: true, shift: false))
                await settle(window, hosting, 1.0)
                if let rep = Self.snapshot(hosting) {
                    Self.write(rep, "\(label)-\(voice)-picked.png")
                }
                report += geometry(hosting, model: model, title: "picked")
            }
            Self.write(text: report, "\(label)-\(voice)-geometry.txt")
        }
    }

    /// Forty books (the capped region) over the notes: the notes' own header
    /// at the top of their region.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func theFaceUnderManyBooks(voice: ThemeVoice) async throws {
        try await withLibrary { session in
            for index in 0..<40 {
                _ = try session.operations.createReading(
                    name: String(format: "book %02d", index), kind: .book)
            }
            try faceFixture(session)
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("books"))
            await model.search()
            let (window, hosting) = mount(session, model, theme: theme, height: 720)
            defer { window.orderOut(nil); window.close() }
            await settle(window, hosting, 1.5)
            if let rep = Self.snapshot(hosting) {
                Self.write(rep, "\(LibraryListFaceRig.label)-\(voice)-manybooks.png")
            }
        }
    }

    private func geometry(_ hosting: NSView, model: LibraryCatalogModel, title: String) -> String {
        var out = "## \(title) — note rows (content frames, catalog space)\n"
        let frames = LibraryPanelOracle.noteRowFrames
        let ordered = model.listedNoteIDs.compactMap { id in frames[id].map { (id, $0) } }
            .sorted { $0.1.minY < $1.1.minY }
        var lastTop: CGFloat?
        for (index, entry) in ordered.prefix(14).enumerated() {
            let f = entry.1
            let pitch = lastTop.map { String(format: "%.2f", f.minY - $0) } ?? "—"
            out += String(
                format: "row %02d  x %.2f…%.2f  y %.2f…%.2f  h %.2f  pitch %@\n",
                index, f.minX, f.maxX, f.minY, f.maxY, f.height, pitch)
            lastTop = f.minY
        }
        if let notes = LibraryPanelOracle.notesRegionFrame {
            out += String(format: "notes region  x %.2f…%.2f  y %.2f…%.2f\n",
                          notes.minX, notes.maxX, notes.minY, notes.maxY)
        }
        return out
    }

    /// Pixel facts, in points: the separator rows (a long uniform run across
    /// the middle band), and per text band the leftmost/rightmost ink.
    private static func pixelReport(_ rep: NSBitmapImageRep, scale: CGFloat) -> String {
        var out = "## pixels (points; scale \(scale))\n"
        let w = rep.pixelsWide, h = rep.pixelsHigh
        func px(_ x: Int, _ y: Int) -> (Int, Int, Int) {
            guard let c = rep.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { return (0, 0, 0) }
            return (Int(c.redComponent * 255), Int(c.greenComponent * 255), Int(c.blueComponent * 255))
        }
        // The background: the most common colour in column 0.94 W.
        let bgX = Int(Double(w) * 0.94)
        var counts: [String: Int] = [:]
        for y in stride(from: 0, to: h, by: 3) {
            let p = px(bgX, y); counts["\(p.0),\(p.1),\(p.2)", default: 0] += 1
        }
        let bg = counts.max { $0.value < $1.value }?.key ?? "?"
        out += "background (0.94W column mode): \(bg)\n"
        // Separator rows: across x ∈ [0.62W, 0.80W] (right of titles and
        // chips, left of the stamps), every sampled pixel equal and ≠ bg.
        let x0 = Int(Double(w) * 0.62), x1 = Int(Double(w) * 0.80)
        var lines: [String] = []
        for y in 0..<h {
            let first = px(x0, y)
            let key = "\(first.0),\(first.1),\(first.2)"
            guard key != bg else { continue }
            var uniform = true
            for x in stride(from: x0, through: x1, by: 7) where px(x, y) != first {
                uniform = false; break
            }
            if uniform {
                // The run's horizontal extent.
                var left = x0
                while left > 0, px(left - 1, y) == first { left -= 1 }
                var right = x1
                while right < w - 1, px(right + 1, y) == first { right += 1 }
                lines.append(String(
                    format: "y %.2f  x %.2f…%.2f  rgb %@", CGFloat(y) / scale,
                    CGFloat(left) / scale, CGFloat(right + 1) / scale, key))
            }
        }
        out += "uniform horizontal runs (separators, header bands):\n" + lines.joined(separator: "\n") + "\n"
        return out
    }

    // MARK: - The feel

    /// The display-link scroller: advances the clip by elapsed × speed on
    /// every tick and records the tick gaps.
    @MainActor
    private final class Flinger: NSObject {
        let scroll: NSScrollView
        let speed: CGFloat
        let limit: TimeInterval
        var link: CADisplayLink?
        var last: CFTimeInterval = 0
        var started: CFTimeInterval = 0
        var gaps: [Double] = []
        var travelled: CGFloat = 0
        var done = false
        /// Nothing more to list: the fling ends at the Library's end.
        var exhausted: () -> Bool = { false }

        init(scroll: NSScrollView, speed: CGFloat, limit: TimeInterval) {
            self.scroll = scroll
            self.speed = speed
            self.limit = limit
        }

        @objc func tick(_ link: CADisplayLink) {
            let now = CACurrentMediaTime()
            if last == 0 {
                last = now
                started = now
                return
            }
            let dt = now - last
            last = now
            gaps.append(dt * 1000)
            let clip = scroll.contentView
            let documentHeight = scroll.documentView?.frame.height ?? 0
            let maxY = max(0, documentHeight - clip.bounds.height)
            let step = speed * CGFloat(dt)
            let target = min(maxY, clip.bounds.origin.y + step)
            travelled += target - clip.bounds.origin.y
            clip.scroll(to: NSPoint(x: 0, y: target))
            scroll.reflectScrolledClipView(clip)
            if now - started > limit || (target >= maxY - 0.5 && exhausted()) { finish() }
        }

        func finish() {
            link?.invalidate()
            link = nil
            done = true
        }
    }

    private struct FeelRun {
        var label: String
        var gaps: [Double]
        var travelled: CGFloat
        var listed: Int
        var rowsBuilt: Int

        var summary: String {
            let n = gaps.count
            let mean = n == 0 ? 0 : gaps.reduce(0, +) / Double(n)
            let sorted = gaps.sorted()
            let p95 = n == 0 ? 0 : sorted[min(n - 1, Int(Double(n) * 0.95))]
            return String(
                format: "%@  frames %d  mean %.1f ms  p95 %.1f  max %.1f  >25 %d  >50 %d  >100 %d  travelled %.0f pt  listed %d  rows built %d",
                label, n, mean, p95, sorted.last ?? 0,
                gaps.filter { $0 > 25 }.count, gaps.filter { $0 > 50 }.count,
                gaps.filter { $0 > 100 }.count, travelled, listed, rowsBuilt)
        }
    }

    private func feel(
        _ session: AppSession, cards: Bool, speed: CGFloat, seconds: TimeInterval, run: Int
    ) async throws -> FeelRun {
        let theme = ThemeStore(session: session)
        let observing = Task { await theme.start() }
        defer { observing.cancel() }
        let model = LibraryCatalogModel(
            session: session, defaults: try scrubbed("feel-\(cards)-\(run)"))
        if cards { model.mode = .notes }
        model.scope = .posts
        await model.search()
        let (window, hosting) = mount(session, model, theme: theme, height: 800)
        defer { window.orderOut(nil); window.close() }
        await settle(window, hosting, 1.5)
        let scroll = try #require(Self.notesScroll(in: hosting))
        let before = LibraryPagedNotesProbe.rowBodies
        let flinger = Flinger(scroll: scroll, speed: speed, limit: seconds)
        let link = hosting.displayLink(target: flinger, selector: #selector(Flinger.tick(_:)))
        flinger.link = link
        flinger.exhausted = { !model.notesHaveMore && !model.loadingMoreNotes }
        link.add(to: .main, forMode: .common)
        let deadline = Date().addingTimeInterval(seconds + 5)
        while !flinger.done, Date() < deadline {
            Self.pumpRunLoop(0.05)
            await Task.yield()
        }
        flinger.finish()
        return FeelRun(
            label: "\(cards ? "Cards" : "List ") \(Int(speed)) pt/s run \(run)",
            gaps: flinger.gaps, travelled: flinger.travelled,
            listed: model.noteHits.count,
            rowsBuilt: LibraryPagedNotesProbe.rowBodies - before)
    }

    /// 822 notes; the List and Cards, each flung at a hand's speed (B1's
    /// brisk flick, ~3,750 pt/s) and at twice it, twice each. Every frame gap
    /// lands in the report; the summary line is what the record quotes.
    @Test func theFeel() async throws {
        try await withLibrary { session in
            let tag = try session.operations.createTag(parent: nil, name: "scale-fixture")
            let tagID = tag.id
            try await session.runner.run { ops in
                for index in 0..<822 {
                    let note = try ops.createPost(
                        title: index % 7 == 3 ? nil : String(format: "Fixture %04d — a note", index),
                        entryDate: index % 5 == 0 ? "2026-04-12" : nil)
                    _ = try ops.newBlock(
                        in: note.id, text: "the words of fixture note \(index), a line or so long")
                    if index % 4 != 3 { _ = try ops.applyTag(tagID, toPost: note.id) }
                }
            }
            var report = "# \(LibraryListFaceRig.label) — the feel (822 notes, scope Notes, 1000×800, Debug test host)\n"
            var detail = ""
            for speed in [CGFloat(3_750), 7_500] {
                for cards in [false, true] {
                    for run in 1...2 {
                        let result = try await feel(
                            session, cards: cards, speed: speed, seconds: 6, run: run)
                        report += result.summary + "\n"
                        detail += "## \(result.label)\n"
                            + result.gaps.map { String(format: "%.1f", $0) }.joined(separator: " ")
                            + "\n"
                    }
                }
            }
            Self.write(text: report, "\(LibraryListFaceRig.label)-feel.txt")
            Self.write(text: detail, "\(LibraryListFaceRig.label)-feel-frames.txt")
        }
    }
}
#endif
