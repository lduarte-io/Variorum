//
//  ReadNoteHeightsTests.swift
//  VariorumTests
//
//  **18l UNIT U1 — the arithmetic under note Read's watched landing**, pinned
//  without a window where it can be (the residual, the manifest's cost
//  shape, the signpost's vocabulary) and with one where only the drawing can
//  say (the derived heights against what the rows actually drew).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("Note Read's landing arithmetic (18l U1)")
struct ReadNoteLandingArithmeticTests {
    private func residual(
        top: CGFloat, height: CGFloat = 100, viewport: CGFloat = 700, anchor: CGFloat,
        offset: CGFloat = 500, min: CGFloat = 0, max: CGFloat = 5000
    ) -> CGFloat {
        ReadLandingResidual.residual(
            blockTop: top, blockHeight: height, viewportHeight: viewport, anchorY: anchor,
            offset: offset, minOffset: min, maxOffset: max)
    }

    /// Home is the block's anchor-point at the viewport's anchor-point — the
    /// SHIPPED anchors (the edit face centred, the page at 0.08), exactly
    /// `ViewportCarry`'s definition and `scrollTo(_:anchor:)`'s act.
    @Test func homeIsTheFacesOwnAnchor() {
        // Centred: (700 − 100) × 0.5 = 300 from the viewport's top.
        #expect(residual(top: 300, anchor: 0.5) == 0)
        #expect(residual(top: 350, anchor: 0.5) == 50, "below home: the page must scroll down")
        #expect(residual(top: 250, anchor: 0.5) == -50)
        // The page: (700 − 100) × 0.08 = 48.
        #expect(abs(residual(top: 48, anchor: 0.08)) < 0.001)
        // A block taller than the viewport, centred: its middle at the middle.
        #expect(residual(top: -150, height: 1000, anchor: 0.5) == 0)
    }

    /// A resting place the page cannot reach is replaced by the one it can —
    /// so the first block, "centred", is HOME at the page's top instead of a
    /// landing that can never finish (and the last one at the page's end).
    @Test func theNotesEndsClampHome() {
        // The first block at the top of a page at offset 0: centring it would
        // need offset −274.
        #expect(residual(top: 26, anchor: 0.5, offset: 0) == 0)
        // …but a page scrolled 100 pt down CAN bring it closer: 100 to go.
        #expect(residual(top: -74, anchor: 0.5, offset: 100) == -100)
        // The last block, the page at its maximum: centring it would need more.
        #expect(residual(top: 500, anchor: 0.5, offset: 1000, max: 1000) == 0)
        // Not at the edge: the page can move 200 pt of the 200 it needs.
        #expect(residual(top: 500, anchor: 0.5, offset: 500, max: 1000) == 200)
        // A content inset moves the reachable top (`minOffset` = −inset).
        #expect(residual(top: 26, anchor: 0.5, offset: -20, min: -20) == 0)
    }

    private static func rows(_ texts: [String], ids: [String]? = nil) -> [Queries.TOCRow] {
        texts.enumerated().map { i, text in
            Queries.TOCRow(
                blockID: "b\(i)", placementID: ids?[i] ?? "p\(i)", name: nil,
                variantID: "v\(i)", text: text, hasFan: false, variantLocked: false)
        }
    }

    /// **P1: the extents are taken ONCE per block-id list** (the
    /// `FlowExtentsCache` key) — an autosave's re-delivery of the same rows
    /// with new text takes nothing; a changed list (a structural act) takes
    /// them again, once.
    @MainActor
    @Test func theExtentsAreTakenOncePerBlockIDList() {
        let heights = ReadNoteHeights(face: .edit)
        heights.stand(contentWidth: 600, typeScale: 1)
        let first = Self.rows(["one paragraph\n", "another one\n", ""])
        heights.adopt(postID: "note", rows: first)
        heights.adopt(postID: "note", rows: first)
        #if DEBUG
        #expect(heights.extentTakes == 1, "the same list is taken once")
        #endif
        // The autosave shape: the same ids, one block's text longer.
        heights.adopt(postID: "note", rows: Self.rows(
            ["one paragraph, now edited at length\n", "another one\n", ""]))
        #if DEBUG
        #expect(heights.extentTakes == 1, "an autosave re-delivery takes NOTHING")
        #endif
        // A structural act: a block inserted.
        heights.adopt(postID: "note", rows: Self.rows(
            ["one paragraph\n", "new\n", "another one\n", ""], ids: ["p0", "pX", "p1", "p2"]))
        #if DEBUG
        #expect(heights.extentTakes == 2, "a changed list is taken again, once")
        #endif
    }

    /// The derived arm is the ONE paragraph model plus this face's chrome; a
    /// blank take stands one line; a measurement outranks the arithmetic; a
    /// new measure drops what was learned at the old one.
    @MainActor
    @Test func theManifestsPrecedenceAndItsMeasure() {
        let heights = ReadNoteHeights(face: .edit)
        heights.stand(contentWidth: 600, typeScale: 1)
        let rows = Self.rows([String(repeating: "word ", count: 120) + "\n", "", "short\n"])
        heights.adopt(postID: "note", rows: rows)
        let long = heights.derived("p0"), blank = heights.derived("p1"), short = heights.derived("p2")
        #expect(long > short, "a long paragraph stands taller than a short one")
        #expect(blank == (heights.metrics.blockChrome + heights.metrics.emptyLine).rounded(),
                "a blank take stands its one line")
        heights.learn("p0", height: 321)
        let manifest = heights.manifest(rows, width: 600, leading: 0)
        #expect(manifest.height(of: "p0") == 321 && manifest.source(of: "p0") == .measured)
        #expect(manifest.source(of: "p2") == .derived)
        #expect(manifest.derivedCount == 2)
        #expect(manifest.offset(of: "p1") == 321 + heights.metrics.rowSpacing)
        #expect(heights.manifest(rows, width: 600, leading: 26).offset(of: "p0") == 26,
                "the leading puts the first row where the column draws it (MINOR-3)")
        heights.stand(contentWidth: 400, typeScale: 1)
        #expect(heights.manifest(rows, width: 400, leading: 0).source(of: "p0") == .derived,
                "a height measured at another measure is not this row's height here")
        #expect(heights.derived("p0") > long, "narrower, so the long paragraph wraps taller")
    }

    /// **The extent IS `Queries.blockExtents`' numbers** (ladder round 1,
    /// NIT-1 — the first cut restated the implementation): a note seeded
    /// with a multi-paragraph block, a blank take and characters outside the
    /// Basic Multilingual Plane, its extents read BOTH ways — SQL's `LENGTH()`
    /// over the rendered take, and `ReadNoteHeightModel.extent` over the TOC
    /// rows the Read host holds — must agree block for block.
    @MainActor
    @Test func theExtentIsTheQueriesOwnNumbers() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 151))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "extents")
            for text in [
                "“Quite so,” said he.\n",
                "A first paragraph.\n\nA second, after a blank line.\nA third line.\n",
                "",
                "Fraktur 𝔄𝔅ℭ, a fox 🦊 and a family 👨‍👩‍👧 outside the BMP.\n",
                "No newline at all",
            ] {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            let (rows, extents) = try await db.read { db in
                (try Queries.blockTOC(db, post: post.id),
                 try Queries.blockExtents(db, containerIDs: [post.id]))
            }
            try #require(rows.count == 5 && extents.count == 5, "five blocks both ways")
            for (row, sql) in zip(rows, extents) {
                let mine = ReadNoteHeightModel.extent(postID: post.id, row: row)
                #expect(mine == sql, "block \(row.blockID): mine \(mine) vs SQL \(sql)")
            }
        }
    }

    /// **U1 ladder round 1, MINOR-1 — a stale seed cannot fake a settle.**
    /// The authority seeds a landing from where the target last said it was
    /// (`tops`) — a fact on columns whose every row exists and reports; on a
    /// LAZY column the block the face landed once may since have gone away,
    /// and its old "I am home" is no longer true. The review's pin, exactly:
    /// land X and hear it at 0.1 (settles); land X again with an aim that
    /// moves nothing and NO report — the second landing must go LOOKING for
    /// its block (a blind correction, the policy's own reason) and must not
    /// file `settled top=0` on the strength of the old report. RED on
    /// `2eff1b27`: `X LAND | X DONE: settled at top=0.1 after 0 hops`.
    @MainActor
    @Test func aStaleSeedCannotFakeASettle() async throws {
        #if DEBUG
        var story: [String] = []
        for policy in [LandingPolicy.readNote, .readNoteEdit] {
            story = []
            let landing = LandingAuthority(
                policy: policy,
                storyboard: LandingStoryboard(
                    note: { story.append($0) }, dump: { story.joined(separator: " | ") }))
            var aims = 0
            landing.land("X", aim: { _ in aims += 1 })
            landing.noteTop("X", 0.1)
            try await Task.sleep(for: .milliseconds(1400))
            #expect(story.contains { $0.contains("X DONE: settled") }, "the first landing settled")
            let second = story.count
            landing.land("X", aim: { _ in aims += 1 })
            try await Task.sleep(for: .milliseconds(1400))
            let after = story[second...]
            print("[18l U1 MINOR-1] \(policy.surface.rawValue), the second landing: \(after.joined(separator: " | "))")
            #expect(after.contains { $0.hasPrefix("HOP 1") },
                    "the second landing went looking for its block (a blind correction)")
            #expect(!after.contains { $0.contains("DONE: settled") },
                    "…and did not settle on the first landing's old report")
            landing.end()
        }
        #endif
    }

    /// **The signpost stays content-free on the new surfaces** — a manifest
    /// built from a note's real prose cannot put a word of it in the line.
    @MainActor
    @Test func theReadSignpostCarriesNumbersOnly() {
        let heights = ReadNoteHeights(face: .page)
        heights.stand(contentWidth: 684, typeScale: 1)
        let rows = Self.rows(["To Sherlock Holmes she is always the woman.\n",
                              "I had seen little of Holmes lately.\n"])
        heights.adopt(postID: "a scandal in bohemia", rows: rows)
        let facts = LandingFacts(manifest: heights.manifest(rows, width: 684, leading: 153), anchor: "p1")
        for surface in [LandingSurface.readNote, .readNoteEdit] {
            let line = LandingSignpost.line(
                surface: surface, facts: facts, corrections: 0, contentMoves: 1,
                elapsed: 1.01, outcome: .settled, top: 0)
            #expect(LandingSignpost.isContentFree(line), "\(line)")
            #expect(line.contains("surface=\(surface.rawValue) rows=2 target=1"))
            for word in ["Sherlock", "Holmes", "woman", "bohemia"] { #expect(!line.contains(word)) }
        }
    }
}

// MARK: - The derived heights against what the rows DREW (the calibration)

@MainActor
@Suite("Note Read's derived heights match what its rows draw (18l U1)", .serialized)
struct ReadNoteHeightsCalibrationTests {
    /// Held within a FIFTH either way, as a ratio — F3's calibration rule: the
    /// estimate's error is proportional (a model of wrapping), and a derived
    /// height governs only rows off screen, where it sizes the landing's facts.
    static let band: ClosedRange<Double> = 0.8...1.25

    /// The sample library's *A Scandal in Bohemia* in `voice`, its ThemeStore
    /// STARTED (so the tokens the rows draw with are the voice's), mounted in
    /// Read on `face` ARRIVING at block 151 — the story's dialogue stretch,
    /// where a screen holds a dozen rows (its first screen is three long
    /// paragraphs) — the process-global typography put back.
    private func onTheStory(
        voice: ThemeVoice, face: ReadModeView.Face,
        _ body: @MainActor (ReadModeTests.World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
        }
        let start = Date(timeIntervalSince1970: 1_782_950_400)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1661))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let mark = LockIsolated(false)
            _ = await SampleLibrarySeeder.seedIfNeeded(
                session: session, loadMark: { mark.value }, saveMark: { mark.setValue($0) })
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let started = Task { await theme.start() }
            defer { started.cancel() }
            for _ in 0..<200 where !(theme.settings.voice == voice && EditorTypography.isAdopted) {
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(theme.settings.voice == voice, "the store speaks \(voice)")
            let bookID = try await db.read { db in
                try #require(Queries.readings(db)
                    .first { $0.name == SampleLibrarySeeder.bookName }).id
            }
            let entries = try await db.read { db in
                try Queries.assembleReading(db, readingID: bookID)
            }
            let story = try #require(entries.first { $0.title == "A Scandal in Bohemia" })
            ReadModeView.remember(face, postID: story.postID)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            _ = session.commandRouter.registerDetail(postID: story.postID, mode: .read) { _ in }
            let toc = try await db.read { db in try Queries.blockTOC(db, post: story.postID) }
            session.commandRouter.noteFocusedBlock(
                toc[150].blockID, variantID: toc[150].variantID, postID: story.postID)
            let model = BlockTOCViewModel(session: session, postID: story.postID)
            let window = NSPanel(
                contentRect: NSRect(x: 120, y: 120, width: 1100, height: 750),
                styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isFloatingPanel = true
            window.becomesKeyOnlyIfNeeded = false
            window.hidesOnDeactivate = false
            let hosting = NSHostingView(rootView: AnyView(
                ReadModeView(session: session, postID: story.postID, model: model)
                    .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let world = ReadModeTests.World(
                session: session, postID: story.postID, blockIDs: [], variantIDs: [],
                model: model, window: window, hosting: hosting)
            defer { world.close() }
            await world.poll { !model.rows.isEmpty }
            try await body(world)
        }
    }

    /// Σ derived / Σ drawn over the rows the face drew.
    private func ratio(
        _ world: ReadModeTests.World, face: ReadNoteHeights.Face,
        frames: () -> [String: CGRect], typeScale: Double
    ) async -> (ratio: Double, rows: Int) {
        await world.poll(timeout: 6) { frames().count >= 10 }
        _ = await world.poll(timeout: 1.5) { false }
        let drawn = frames()
        let heights = ReadNoteHeights(face: face)
        let width = drawn.values.first?.width ?? 0
        heights.stand(contentWidth: width, typeScale: typeScale)
        heights.adopt(postID: world.postID, rows: world.model.rows)
        var derived = 0.0, measured = 0.0, count = 0
        for row in world.model.rows {
            guard let frame = drawn[row.blockID] else { continue }
            derived += Double(heights.derived(row.placementID))
            measured += Double(frame.height)
            count += 1
        }
        return (measured > 0 ? derived / measured : 0, count)
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theEditFacesDerivedHeightsAreNearWhatItsRowsDraw(_ voice: ThemeVoice) async throws {
        try await onTheStory(voice: voice, face: .edit) { world in
            let (r, rows) = await ratio(
                world, face: .edit, frames: { ReadModeOracle.editBlockFrames }, typeScale: 1)
            print("[18l U1] calibration, edit face, \(voice): Σderived/Σdrawn = \(r) over \(rows) rows")
            #expect(rows >= 10, "the face drew a screenful")
            #expect(Self.band.contains(r), "within a fifth — \(r)")
        }
    }

    @Test func thePageFacesDerivedHeightsAreNearWhatItsRowsDraw() async throws {
        try await onTheStory(voice: .terminal, face: .read) { world in
            let stored = UserDefaults.standard.double(forKey: "readModeTypeScale")
            let scale = stored > 0 ? stored : 1
            let (r, rows) = await ratio(
                world, face: .page, frames: { ReadModeOracle.pageBlockFrames }, typeScale: scale)
            print("[18l U1] calibration, read face (type scale \(scale)): Σderived/Σdrawn = \(r) over \(rows) rows")
            #expect(rows >= 10, "the page drew a screenful")
            #expect(Self.band.contains(r), "within a fifth — \(r)")
        }
    }
}
