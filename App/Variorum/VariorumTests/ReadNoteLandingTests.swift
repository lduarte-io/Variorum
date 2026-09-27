//
//  ReadNoteLandingTests.swift
//  VariorumTests
//
//  **18l UNIT U1 — note Read adopts the 13u4-F3 landing shape** (the health
//  review §1.2's diagnosis, verbatim: *"Note Read mode: a one-shot aim against
//  SwiftUI's lazy estimate with no second look — the target is nil'd
//  immediately, the lazy column re-realizes under the landed offset, SwiftUI
//  re-applies the pixel offset, and nothing re-aims. Same note + same width ⇒
//  same estimate error ⇒ the identical jump every time."*).
//
//  PIN FIRST (the round's standing rule): these were written and run against
//  the PRE-FIX tree before a line of the fix. The fixture is the class's own
//  shape rather than a uniform note — a Sherlock-like story whose opening is
//  short dialogue lines and whose body is long narrative paragraphs, so the
//  lazy column's estimate for the rows it has not realized (the average of
//  the ones it has) is WRONG, exactly as it is on her long notes. (A note of
//  215 identical paragraphs — `ReadLandingTests`' fixture — makes the average
//  exact and hides the class; that is why those pins stayed green.)
//
//  What each face owes, stated as her screen: the landed block rests at the
//  face's SHIPPED anchor — the page at 0.08 of the viewport, the edit face
//  centred (`ReadPageColumn.restingAnchor`, `ReadEditPane.restingAnchor`;
//  where a landing puts a block is product, and this unit keeps both) — and it
//  STAYS there: sampled once the landing has had time to settle and again a
//  second and a half later.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Note Read's far landing arrives at its anchor and holds (18l U1)", .serialized)
struct ReadNoteLandingTests {
    /// The story's shape: `shortOpening` lines of dialogue, then long
    /// narrative paragraphs of varied length (the Sherlock stories' own mix —
    /// 211 of *Copper Beeches*' 212 blocks end in a newline, and so do these).
    static let blockCount = 260
    static let shortOpening = 40
    /// The block the arrival lands on — far below the first screenful.
    static let landingIndex = 200
    /// Within this many points of its resting place a landed block is where
    /// she was taken (the authority's own tolerance plus a point of slack).
    static let restTolerance: CGFloat = 3

    static let narrative = "We were seated at breakfast one morning, my wife and I, when the "
        + "maid brought in a telegram. It was from Sherlock Holmes and ran in this way. "
    static let dialogue = "“Quite so,” said he."

    /// Block `i`'s text — deterministic, varied, ending in a newline.
    static func text(_ i: Int) -> String {
        if i < shortOpening { return "\(dialogue) (\(i))\n" }
        // 1…9 sentences in a fixed irregular walk, so neighbouring rows differ.
        let sentences = [3, 7, 1, 5, 9, 2, 6, 4, 8, 1, 5][i % 11]
        return "Paragraph \(i). " + String(repeating: narrative, count: sentences) + "\n"
    }

    private func mounted(
        face: ReadModeView.Face,
        texts: [String]? = nil,
        landingIndex: Int = ReadNoteLandingTests.landingIndex,
        _ body: @escaping (ReadModeTests.World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a scandal in bohemia")
            var blocks: [String] = []
            var variants: [String] = []
            for text in texts ?? (0..<Self.blockCount).map({ Self.text($0) }) {
                let minted = try session.operations.newBlock(in: post.id, text: text)
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            ReadModeView.remember(face, postID: post.id)
            #if DEBUG
            ReadModeOracle.reset()
            // Ladder round 1, MINOR-2: the landing story is a process-global
            // log — every mount starts it empty (the Outline's and the flow's
            // landing suites' own pattern), and a read matches its own target.
            ReadLandingStory.trace = []
            #endif
            // The row-39 road (`ReadLandingTests`' own): she was in block 201
            // elsewhere, then ⌘3 — the host ARRIVES on the current block and
            // lands both faces on it. A place reported after the registration
            // is not the note's opening (R-18l-1), so it lands by the standing
            // rules — the coldest landing there is: nothing below the first
            // screenful has ever been drawn.
            let router = session.commandRouter
            _ = router.registerDetail(postID: post.id, mode: .read) { _ in }
            router.noteFocusedBlock(
                blocks[landingIndex], variantID: variants[landingIndex], postID: post.id)
            let model = BlockTOCViewModel(session: session, postID: post.id)
            let window = NSPanel(
                contentRect: NSRect(x: 120, y: 120, width: 1100, height: 750),
                styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isFloatingPanel = true
            window.becomesKeyOnlyIfNeeded = false
            window.hidesOnDeactivate = false
            let hosting = NSHostingView(rootView: AnyView(
                ReadModeView(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let world = ReadModeTests.World(
                session: session, postID: post.id, blockIDs: blocks, variantIDs: variants,
                model: model, window: window, hosting: hosting)
            defer { world.close() }
            await world.poll { !model.rows.isEmpty && ReadModeOracle.selectedBlockID != nil }
            try await body(world)
        }
    }

    /// **The REAL long-note fixture** — the sample library's own *A Scandal in
    /// Bohemia*, seeded exactly as her store has it (one block per paragraph,
    /// the blank line between them kept as content), and the same row-39
    /// arrival at block `landingIndex + 1`.
    private func mountedOnTheStory(
        face: ReadModeView.Face,
        _ body: @escaping (ReadModeTests.World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
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
                session: session,
                loadMark: { mark.value },
                saveMark: { flag in mark.setValue(flag) })
            let bookID = try await db.read { db in
                try #require(Queries.readings(db)
                    .first { $0.name == SampleLibrarySeeder.bookName }).id
            }
            let entries = try await db.read { db in
                try Queries.assembleReading(db, readingID: bookID)
            }
            let story = try #require(entries.first { $0.title == "A Scandal in Bohemia" })
            let toc = try await db.read { db in try Queries.blockTOC(db, post: story.postID) }
            let blocks = toc.map(\.blockID)
            let variants = toc.map { $0.variantID ?? "" }
            try #require(blocks.count > Self.landingIndex + 20, "the story is long")
            ReadModeView.remember(face, postID: story.postID)
            #if DEBUG
            ReadModeOracle.reset()
            // Ladder round 1, MINOR-2: the landing story is a process-global
            // log — every mount starts it empty (the Outline's and the flow's
            // landing suites' own pattern), and a read matches its own target.
            ReadLandingStory.trace = []
            #endif
            let router = session.commandRouter
            _ = router.registerDetail(postID: story.postID, mode: .read) { _ in }
            router.noteFocusedBlock(
                blocks[Self.landingIndex], variantID: variants[Self.landingIndex],
                postID: story.postID)
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
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let world = ReadModeTests.World(
                session: session, postID: story.postID, blockIDs: blocks, variantIDs: variants,
                model: model, window: window, hosting: hosting)
            defer { world.close() }
            print("[18l U1] the real story: \(blocks.count) blocks, landing on block \(Self.landingIndex + 1)")
            await world.poll { !model.rows.isEmpty && ReadModeOracle.selectedBlockID != nil }
            try await body(world)
        }
    }

    #if DEBUG
    /// The last landing's DONE line in the DEBUG story (`ReadLandingStory`),
    /// nil when no note Read landing has finished — the pre-fix tree's
    /// answer, since nothing watched a note Read landing at all.
    static func lastStory(_ placementID: String? = nil) -> String? {
        ReadLandingStory.trace.last {
            $0.contains(" DONE: ") && (placementID.map($0.contains) ?? true)
        }
    }

    /// The placement id — the landing's anchor, which its story lines carry.
    static func placement(_ world: ReadModeTests.World, block index: Int) -> String? {
        world.model.rows.first { $0.blockID == world.blockIDs[index] }?.placementID
    }
    #endif

    /// Where the landed block sits against where its face's anchor puts it:
    /// the block's `anchor`-point at the viewport's `anchor`-point
    /// (`ViewportCarry`'s definition, which IS `scrollTo(_:anchor:)`'s). 0 is
    /// home; positive is below it.
    static func residual(block: CGRect, face: CGRect, anchor: CGFloat) -> CGFloat {
        let rest = face.minY + CGFloat(ViewportCarry.topInset(
            fraction: Double(anchor), blockHeight: Double(block.height),
            viewportHeight: Double(face.height)))
        return block.minY - rest
    }

    private func settledResidual(
        _ world: ReadModeTests.World, frames: () -> [String: CGRect], anchor: CGFloat
    ) async -> (first: CGFloat?, second: CGFloat?) {
        let target = world.blockIDs[Self.landingIndex]
        await world.poll(timeout: 8) { frames()[target] != nil }
        // The landing's own time to settle (the authority's hold is a second;
        // a correction adds one more), then a look — and another later, so a
        // landing that arrives and then slides is caught. The path on the way
        // is printed: every distinct place the landed block stood (a stutter
        // is a landing that arrives through a second place).
        var path: [Int] = []
        _ = await world.poll(timeout: 3) {
            if let block = frames()[target], let face = ReadModeOracle.faceFrames[world.postID] {
                let r = Int(Self.residual(block: block, face: face, anchor: anchor).rounded())
                if path.last != r { path.append(r) }
            }
            return false
        }
        print("[18l U1] the landed block's path (pt from its anchor): \(path)")
        let first = frames()[target].flatMap { block in
            ReadModeOracle.faceFrames[world.postID].map {
                Self.residual(block: block, face: $0, anchor: anchor)
            }
        }
        _ = await world.poll(timeout: 1.5) { false }
        let second = frames()[target].flatMap { block in
            ReadModeOracle.faceFrames[world.postID].map {
                Self.residual(block: block, face: $0, anchor: anchor)
            }
        }
        // What the face actually drew, for the record: the realized rows by
        // their place in the note, and the ones inside the viewport.
        let face = ReadModeOracle.faceFrames[world.postID] ?? .zero
        let drawn = frames()
        let indices = world.blockIDs.indices.filter { drawn[world.blockIDs[$0]] != nil }
        let onScreen = indices.filter { i in
            drawn[world.blockIDs[i]].map { $0.maxY > face.minY && $0.minY < face.maxY } ?? false
        }
        print("[18l U1] realized rows \(indices.first.map { $0 + 1 } ?? -1)…"
            + "\(indices.last.map { $0 + 1 } ?? -1) (\(indices.count)); on screen "
            + "\(onScreen.map { $0 + 1 }); face \(face)")
        #if DEBUG
        print("[18l U1] the landing's story: \(Self.lastStory(Self.placement(world, block: Self.landingIndex)) ?? "NONE")")
        #endif
        return (first, second)
    }

    /// **The landing was WATCHED** — the Console flip's pin (the health
    /// review §1.2: note Read's landings printed NOTHING, having no
    /// authority). The DEBUG story's last DONE line is this face's, it
    /// SETTLED, and it spent at most `maxHops` corrections. Red on the fixed
    /// tree when the faces' one-shot `scrollTo` is put back (R-watch — the
    /// record's revert): no landing is watched, so no line exists.
    private func expectWatched(
        _ surface: LandingSurface, _ world: ReadModeTests.World, maxHops: Int
    ) {
        #if DEBUG
        let target = Self.placement(world, block: Self.landingIndex)
        #expect(target != nil, "the landed block's placement id")
        let line = Self.lastStory(target ?? "no such placement")
        #expect(line?.hasPrefix("[\(surface.rawValue)] ") == true,
                "this face's landing was watched — its story: \(line ?? "NONE")")
        #expect(line?.contains("DONE: settled") == true, "…and it SETTLED: \(line ?? "NONE")")
        let hops = line.flatMap { l -> Int? in
            guard let r = l.range(of: " after ") else { return nil }
            return Int(l[r.upperBound...].prefix { $0.isNumber })
        }
        #expect(hops.map { $0 <= maxHops } == true,
                "…spending at most \(maxHops) correction(s): \(line ?? "NONE")")
        #endif
    }

    /// **`edit`: the far block lands CENTRED, and stays.**
    @Test func theEditFaceLandsAColdFarBlockCentredAndItStays() async throws {
        try await mounted(face: .edit) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.editBlockFrames }, anchor: 0.5)
            print("[18l U1] edit face: block \(Self.landingIndex + 1)'s distance from centre "
                + "= \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance,
                    "the landing arrived at the centre — it is \(a) pt away")
            #expect(abs(b) <= Self.restTolerance,
                    "…and it is still there 1.5 s later — \(b) pt away")
            // The lazy column's first aim misses this shape (the pre-fix
            // tree's red); the watched landing's second aim reaches it.
            expectWatched(.readNoteEdit, world, maxHops: LandingPolicy.readNoteEdit.correctionBudget)
        }
    }

    /// **The same two promises on the REAL story** (`mountedOnTheStory`) —
    /// and the charter's acceptance line, `hops=0` COLD: the lazy column's
    /// own first aim is exact on her story, so a correction here is a
    /// regression (the asserted-height rows the record measured and
    /// rejected stood 59 pt off and needed one).
    @Test func onTheRealStoryTheEditFaceLandsAColdFarBlockCentredAndItStays() async throws {
        try await mountedOnTheStory(face: .edit) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.editBlockFrames }, anchor: 0.5)
            print("[18l U1] the real story, edit face: distance from centre "
                + "= \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance, "arrived at the centre — \(a) pt away")
            #expect(abs(b) <= Self.restTolerance, "…and stayed — \(b) pt away")
            expectWatched(.readNoteEdit, world, maxHops: 0)
        }
    }

    @Test func onTheRealStoryTheReadFaceLandsAColdFarBlockAtItsAnchorAndItStays() async throws {
        try await mountedOnTheStory(face: .read) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.pageBlockFrames }, anchor: 0.08)
            print("[18l U1] the real story, read face: distance from its anchor "
                + "= \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance, "arrived at the anchor — \(a) pt away")
            #expect(abs(b) <= Self.restTolerance, "…and stayed — \(b) pt away")
            expectWatched(.readNote, world, maxHops: 0)
        }
    }

    /// **`read`: the far block lands at 0.08 of the page, and stays.**
    @Test func theReadFaceLandsAColdFarBlockAtItsAnchorAndItStays() async throws {
        try await mounted(face: .read) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.pageBlockFrames }, anchor: 0.08)
            print("[18l U1] read face: block \(Self.landingIndex + 1)'s distance from its "
                + "anchor = \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance,
                    "the landing arrived at the page's anchor — it is \(a) pt away")
            #expect(abs(b) <= Self.restTolerance,
                    "…and it is still there 1.5 s later — \(b) pt away")
            expectWatched(.readNote, world, maxHops: 0)
        }
    }

    // MARK: - U1 ladder round 1, MINOR-3 — the facts' offsets are in the content space

    /// **The manifest's offsets are the column's CONTENT-SPACE tops**
    /// (`BookHeightManifest.leading`'s contract: *"everything above the first
    /// row … so offsets are absolute in the column's content space"*). A
    /// landing on the FIRST block has nothing above it — its `offset=` must be
    /// exactly where the face draws that block's top: the edit column's 26-pt
    /// lead; the page's two paddings, its header row and one row gap. RED on
    /// `2eff1b27`, which passed `leading: 0` on both faces (every offset low).
    @Test(arguments: [ReadModeView.Face.edit, .read])
    func theFirstBlocksOffsetIsWhereTheFaceDrawsIt(_ face: ReadModeView.Face) async throws {
        try await mounted(face: face, landingIndex: 0) { world in
            let target = world.blockIDs[0]
            let frames: () -> [String: CGRect] = {
                face == .edit ? ReadModeOracle.editBlockFrames : ReadModeOracle.pageBlockFrames
            }
            await world.poll(timeout: 6) { frames()[target] != nil }
            _ = await world.poll(timeout: 1.5) { false }
            #if DEBUG
            let placement = try #require(Self.placement(world, block: 0))
            let lines = ReadLandingStory.trace
            let land = try #require(lines.lastIndex { $0.hasSuffix("\(placement) LAND") },
                                    "the first block's landing was watched")
            let manifest = try #require(lines[land...].first { $0.contains("] manifest ") })
            let offset = try #require(manifest.split(separator: " ")
                .first { $0.hasPrefix("offset=") }.flatMap { Int($0.dropFirst("offset=".count)) })
            let block = try #require(frames()[target])
            let viewport = try #require(ReadModeOracle.faceFrames[world.postID])
            // The block's content-space top: its place in the viewport plus how
            // far the face's own scroll view is scrolled (the AppKit scroll view
            // the face IS — the one whose size is the face's; the page face's
            // first block rests at 0.08, which is below the page's top air).
            func scrollViews(_ v: NSView) -> [NSScrollView] {
                (v is NSScrollView ? [v as! NSScrollView] : []) + v.subviews.flatMap(scrollViews)
            }
            let scroll = try #require(scrollViews(world.hosting).first {
                abs($0.frame.width - viewport.width) < 1.5 && abs($0.frame.height - viewport.height) < 1.5
            }, "the face's own scroll view")
            let drawn = block.minY - viewport.minY + scroll.contentView.bounds.origin.y
            print("[18l U1 MINOR-3] \(face): the story's offset=\(offset), the block drawn at \(drawn) — \(manifest)")
            #expect(abs(CGFloat(offset) - drawn) <= 1,
                    "the manifest's offset is the drawn content-space top: \(offset) vs \(drawn)")
            #endif
        }
    }

    // MARK: - U1 ladder round 1, MAJOR-1 — her click inside the landing's hold

    /// **A click into the landed block while the landing is still pending
    /// must not move the page.** The edit face's home is the block CENTRED,
    /// so it depends on the block's own height; her click swaps the block
    /// from the read tier to the live pane, whose line metrics differ
    /// (KnownIssues' S3 row), so its height changes while its top stays — and
    /// a landing still watching would "correct" the centre by half the change
    /// and scroll the page under the caret she just placed. The pane's own
    /// contract: *"clicking what you can see must not move it under you."*
    /// Her act ends the landing, as her scroll already did (`end=handedover`).
    ///
    /// The review's pin (ladder round 1): uniform five-sentence paragraphs, the
    /// arrival at block 41, a REAL click on its middle 0.15 s and 0.45 s after
    /// its frame first appears (both inside the one-second hold), the block's
    /// top sampled right after the swap and 3 s later. RED on `2eff1b27`
    /// (5.0 pt, both delays, measured by the reviewer); green on the pre-U1
    /// tree, which never watched a landing at all.
    @Test(arguments: [0.15, 0.45])
    func aClickIntoTheLandedBlockDuringTheHoldDoesNotMoveThePage(_ delay: Double) async throws {
        let paragraph = String(repeating: Self.narrative, count: 5) + "\n"
        let texts = (0..<80).map { "Paragraph \($0). " + paragraph }
        try await mounted(face: .edit, texts: texts, landingIndex: 40) { world in
            let target = world.blockIDs[40]
            let arrived = await world.poll(timeout: 8) {
                ReadModeOracle.editBlockFrames[target] != nil
            }
            try #require(arrived, "the landed block drew")
            try await Task.sleep(for: .milliseconds(Int(delay * 1000)))
            let frame = try #require(ReadModeOracle.editBlockFrames[target])
            world.click(at: world.windowCenter(of: frame))
            let live = await world.poll(timeout: 4) {
                ReadModeTests.editablePanes(in: world.hosting).count == 1
                    && world.model.liveBlockID == target
            }
            try #require(live, "the click made the landed block live")
            await world.turn()
            let afterSwap = try #require(ReadModeOracle.editBlockFrames[target])
            _ = await world.poll(timeout: 3) { false }
            let settled = try #require(ReadModeOracle.editBlockFrames[target])
            print("[18l U1 MAJOR-1] click at +\(delay) s: after the swap top=\(afterSwap.minY) "
                + "h=\(afterSwap.height); 3 s later top=\(settled.minY) h=\(settled.height)")
            #if DEBUG
            print("[18l U1 MAJOR-1] the story: \(ReadLandingStory.trace.suffix(6).joined(separator: " | "))")
            #endif
            #expect(abs(settled.minY - afterSwap.minY) <= 1,
                    "the page did not move under her click: \(afterSwap.minY) → \(settled.minY)")
            #if DEBUG
            #expect(Self.lastStory(world.model.rows[40].placementID)?
                        .contains("her click in the pane") == true,
                    "…because her click ENDED the landing (end=handedover)")
            #endif
        }
    }

    /// **…and so does her TYPING in the click-through's live pane** (the
    /// review's case (b)): a paragraph click on the page flips to `edit` with
    /// that block LIVE and lands it centred; she types at once, inside the
    /// hold — her words wrap the paragraph onto another line, its height
    /// grows, and a landing still watching would re-centre it under her
    /// caret. Red when the pane's edit report does not end the landing (the
    /// fix pass's own revert, recorded in the ladder file).
    @Test func typingInTheClickThroughsLivePaneDuringTheHoldDoesNotMoveThePage() async throws {
        let paragraph = String(repeating: Self.narrative, count: 5) + "\n"
        let texts = (0..<80).map { "Paragraph \($0). " + paragraph }
        try await mounted(face: .read, texts: texts, landingIndex: 40) { world in
            let target = world.blockIDs[40]
            let drawn = await world.poll(timeout: 8) {
                ReadModeOracle.pageBlockFrames[target] != nil
            }
            try #require(drawn, "the page landed the block")
            _ = await world.poll(timeout: 1.5) { false }
            let onPage = try #require(ReadModeOracle.pageBlockFrames[target])
            world.click(at: world.windowCenter(of: onPage))
            let live = await world.poll(timeout: 4) {
                ReadModeOracle.face == .edit
                    && ReadModeTests.editablePanes(in: world.hosting).count == 1
                    && world.model.liveBlockID == target
            }
            try #require(live, "the click-through opened edit with the block live")
            let pane = try #require(ReadModeTests.editablePanes(in: world.hosting).first)
            pane.setSelectedRange(NSRange(location: (pane.string as NSString).length, length: 0))
            pane.insertText(
                " And then she wrote one sentence more, long enough to carry the paragraph "
                    + "onto a line it did not have before, and then some more words to be sure.",
                replacementRange: NSRange(location: NSNotFound, length: 0))
            await world.turn()
            let afterEdit = try #require(ReadModeOracle.editBlockFrames[target])
            _ = await world.poll(timeout: 3) { false }
            let settled = try #require(ReadModeOracle.editBlockFrames[target])
            print("[18l U1 MAJOR-1b] typed in the hold: top \(afterEdit.minY) h \(afterEdit.height) "
                + "→ 3 s later top \(settled.minY) h \(settled.height)")
            #if DEBUG
            print("[18l U1 MAJOR-1b] the story: \(ReadLandingStory.trace.suffix(5).joined(separator: " | "))")
            #endif
            #expect(abs(settled.minY - afterEdit.minY) <= 1,
                    "the page did not move under her typing: \(afterEdit.minY) → \(settled.minY)")
        }
    }
}
