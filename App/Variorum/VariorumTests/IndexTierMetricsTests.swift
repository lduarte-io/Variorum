//
//  IndexTierMetricsTests.swift
//  VariorumTests
//
//  **18l-c UNIT U5 — her 2026-09-27 report, verbatim:** *"when you click onto
//  text to edit, the whitespace around it moves around. This happens in both
//  book and individual note index mode… In the individual note I noticed some
//  words get compressed and there's different spacing, in the book mode a
//  larger space seems to be added."*
//
//  The two index-like surfaces — the book Index and the note's Read ▸ edit —
//  draw every block at rest as read-cheap SwiftUI `Text` and swap the clicked
//  one for THE live pane (P-3). The claim pinned is hers, as geometry: after a
//  REAL click turns a read-tier block live, the live pane's prose is the read
//  tier's prose, line for line —
//    · the same WRAP (every line starts at the same character),
//    · every line at the same HEIGHT (no compression),
//    · the same MEASURE (the prose's left and right edges),
//  and the block below does not move AT ALL — for every shape, including a
//  block stored over one or more BLANK lines (the sample library keeps one under
//  every paragraph — the "Sherlock shape"). Until 18l-c U5's rider the read tier
//  folded a stored blank line into its paragraph gap while the live editor had to
//  show it, so that shape's block below dropped by one blank line (25 / 30 pt);
//  her #154 ruling, option (b): the two index faces SHOW stored blank lines at
//  rest — display == stored — and nothing moves on a click, for any note.
//
//  "Text lines" on both sides are the lines that carry a character other than a
//  newline; a blank line is held by the block-below arm (its height is the only
//  thing about it that can differ) and by the replica's fidelity arm.
//
//  The read tier's lines come from the click's REPLICA
//  (`ReadTierClickPlace.lines`), whose agreement with what SwiftUI drew is
//  measured here too (the block's height, ±0.5 pt — U0's fidelity arm), so a
//  point release that moves SwiftUI's text metrics goes red here rather than
//  letting this pin compare against a fiction.
//
//  Rig: `IndexClickCaretTests.Rig` (the U0 pins' real-click window).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// Gutenberg's own sentences (A Scandal in Bohemia), long enough to wrap to
/// several lines on both hosts in both voices.
private let storyProse = [
    "I had seen little of Holmes lately. My marriage had drifted us away from each other. "
        + "My own complete happiness, and the home-centred interests which rise up around the "
        + "man who first finds himself master of his own establishment, were sufficient to "
        + "absorb all my attention, while Holmes, who loathed every form of society with his "
        + "whole Bohemian soul, remained in our lodgings in Baker Street.",
    "One night—it was on the twentieth of March, 1888—I was returning from a journey to a "
        + "patient (for I had now returned to civil practice), when my way led me through "
        + "Baker Street. As I passed the well-remembered door, which must always be associated "
        + "in my mind with my wooing, and with the dark incidents of the Study in Scarlet, I "
        + "was seized with a keen desire to see Holmes again.",
    "His rooms were brilliantly lit, and, even as I looked up, I saw his tall, spare figure "
        + "pass twice in a dark silhouette against the blind. He was pacing the room swiftly, "
        + "eagerly, with his head sunk upon his chest and his hands clasped behind him.",
    "He was at work again. He had risen out of his drug-created dreams and was hot upon the "
        + "scent of some new problem. I rang the bell and was shown up to the chamber which had "
        + "formerly been in part my own.",
]

/// The clicked block's shape.
enum IndexTierShape: String, CaseIterable, CustomStringConvertible, Sendable {
    /// One prose paragraph, no trailing newline — her own notes' shape.
    case prose
    /// Two prose paragraphs inside ONE block (an internal newline — I4).
    case paragraphs
    /// One prose paragraph over a STORED blank line — the sample library's
    /// shape, every block but a story's last.
    case overBlankLine
    /// A blank line BETWEEN two paragraphs of one block (`A\n\nB`).
    case aroundBlankLine
    /// Two stored blank lines under the text (`A\n\n`) — "or several".
    case overTwoBlankLines
    var description: String { rawValue }

    var text: String {
        switch self {
        case .prose: storyProse[1]
        case .paragraphs: storyProse[1] + "\n" + storyProse[2]
        case .overBlankLine: storyProse[1] + "\n"
        case .aroundBlankLine: storyProse[1] + "\n\n" + storyProse[2]
        case .overTwoBlankLines: storyProse[1] + "\n\n"
        }
    }
}

/// Where the index surfaces live.
enum IndexTierHost: String, CaseIterable, CustomStringConvertible, Sendable {
    case bookIndex
    case readEdit
    var description: String { rawValue }
}

/// The live pane's prose, in the surface's own y-down space.
@MainActor
private struct PaneProse {
    var tops: [CGFloat] = []
    var starts: [Int] = []
    var left: CGFloat = 0
    var right: CGFloat = 0
}

@MainActor
private func editablePanes(in view: NSView) -> [PaneTextView] {
    var out: [PaneTextView] = []
    if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
    for sub in view.subviews { out += editablePanes(in: sub) }
    return out
}

/// Reads a live pane's TEXT lines (the empty line after a trailing newline is
/// not a text line) — each line's typographic top and first character — and
/// its prose edges, mapped into the host's space by `toSpace`.
@MainActor
private func proseOf(_ pane: PaneTextView, toSpace: (NSPoint) -> CGPoint) -> PaneProse {
    var result = PaneProse()
    guard let layout = pane.textLayoutManager, let content = layout.textContentManager else {
        return result
    }
    let origin = pane.textContainerOrigin
    let text = pane.string as NSString
    layout.enumerateTextLayoutFragments(
        from: layout.documentRange.location, options: [.ensuresLayout]
    ) { fragment in
        let frame = fragment.layoutFragmentFrame
        let base = content.offset(
            from: content.documentRange.location, to: fragment.rangeInElement.location)
        for line in fragment.textLineFragments where carriesText(line, base: base, in: text) {
            let y = origin.y + frame.minY + line.typographicBounds.minY
            result.tops.append(toSpace(NSPoint(x: origin.x, y: y)).y)
            result.starts.append(base + line.characterRange.location)
        }
        return true
    }
    let padding = pane.textContainer?.lineFragmentPadding ?? 0
    result.left = toSpace(NSPoint(x: pane.proseLeft + padding, y: origin.y)).x
    result.right = toSpace(NSPoint(x: pane.proseRight - padding, y: origin.y)).x
    return result
}

/// A TEXT line — one that carries a character other than a newline (a blank
/// line's fragment carries only its `\n`, the extra line after a trailing
/// newline carries nothing).
@MainActor
private func carriesText(_ line: NSTextLineFragment, base: Int, in text: NSString) -> Bool {
    let range = NSRange(
        location: base + line.characterRange.location, length: line.characterRange.length)
    guard range.length > 0, NSMaxRange(range) <= text.length else { return false }
    return !text.substring(with: range).trimmingCharacters(in: .newlines).isEmpty
}

@MainActor
@Suite("18l-c U5 — the index tiers speak ONE metrics vocabulary", .serialized)
struct IndexTierMetricsTests {
    typealias Rig = IndexClickCaretTests.Rig

    private static func panel(_ root: some View) -> Rig {
        let window = NSPanel(
            contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
            styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isFloatingPanel = true
        window.becomesKeyOnlyIfNeeded = false
        window.hidesOnDeactivate = false
        let hosting = NSHostingView(rootView: AnyView(root))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return Rig(window: window, hosting: hosting)
    }

    /// A store in `voice` with its `ThemeStore` STARTED (the tier's tokens
    /// and the pane's typography are the voice's, as in the app); the
    /// process-global typography put back afterwards.
    private static func withStore<T>(
        voice: ThemeVoice,
        _ body: @MainActor (AppSession, AppDatabase, ThemeStore) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
        }
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let started = Task { await theme.start() }
            defer { started.cancel() }
            for _ in 0..<200 where !(theme.settings.voice == voice && EditorTypography.isAdopted) {
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(theme.settings.voice == voice, "the store speaks \(voice)")
            return try await body(session, db, theme)
        }
    }

    /// Her note, three blocks: one over a blank line (above), the CLICKED
    /// block in `shape`, and the note's last block (below — the one whose
    /// movement is the whitespace she saw move).
    private static func mintNote(
        _ session: AppSession, shape: IndexTierShape
    ) throws -> (postID: String, blocks: [MintedBlock]) {
        let post = try session.operations.createPost(title: "a story")
        var blocks: [MintedBlock] = []
        for text in [storyProse[0] + "\n", shape.text, storyProse[3]] {
            let minted = try session.operations.newBlock(in: post.id, text: text)
            blocks.append(MintedBlock(
                blockID: minted.block.id, variantID: minted.variant.id, text: text))
        }
        return (post.id, blocks)
    }

    /// The ONE claim, stated once for both hosts. `column` is the clicked
    /// block's read-tier TEXT column and `nextTop` the block below's top, both
    /// read BEFORE the click; `nextTopAfter` after it; `pane` the live pane's
    /// prose in the same space.
    private static func expectOneVocabulary(
        _ label: String, shape: IndexTierShape, text: String,
        column: CGRect, nextTop: CGFloat, nextTopAfter: CGFloat, pane: PaneProse
    ) {
        let font = EditorDocument.baseFont
        let read = ReadTierClickPlace.lines(of: text, columnWidth: column.width, font: font)
        let readTops = read.map { column.minY + $0.top }
        let readStarts = read.map(\.displayStart)
        // The stored blank line's height, in the vocabulary (the paragraph
        // gap it follows, then one line of the voice) — REPORTED, since the
        // rider's (b) it is no longer an allowance: the block below must not
        // move by it (or by anything).
        // gap it follows, then one line of the voice (the replica's own
        // one-line height).
        let oneLine = ReadTierClickPlace.height(of: "x", columnWidth: 400, font: font)
        let blankLine = IndexProseColumn.lines.paragraphGap + oneLine
        let expectedShift: CGFloat = 0
        let shift = nextTopAfter - nextTop
        let deltas = zip(pane.tops, readTops).map { ($0 - $1).rounded(toPlaces: 1) }
        print("[18l-c U5 trace] \(label): read tier \(read.count) lines · pane \(pane.tops.count) lines"
            + " · wrap equal \(pane.starts == readStarts)"
            + " · per-line Δtop \(deltas)"
            + " · left Δ \((pane.left - column.minX).rounded(toPlaces: 1))"
            + " · right Δ \((pane.right - column.maxX).rounded(toPlaces: 1))"
            + " · block below moved \(shift.rounded(toPlaces: 1)) pt"
            + " (one stored blank line is \(blankLine.rounded(toPlaces: 1)) pt)")
        #expect(pane.starts == readStarts, Comment(rawValue:
            "\(label): the live pane wraps where the read tier did — pane line starts "
                + "\(pane.starts), read tier \(readStarts)"))
        #expect(pane.tops.count == readTops.count, Comment(rawValue:
            "\(label): \(pane.tops.count) text lines live, \(readTops.count) at rest"))
        for (index, (live, rest)) in zip(pane.tops, readTops).enumerated() {
            #expect(abs(live - rest) <= 1, Comment(rawValue:
                "\(label): line \(index) sits at \(live) live, \(rest) at rest — "
                    + "the lines moved under her pointer"))
        }
        #expect(abs(pane.left - column.minX) <= 0.5, Comment(rawValue:
            "\(label): the prose starts at \(pane.left) live, \(column.minX) at rest"))
        #expect(abs(pane.right - column.maxX) <= 0.5, Comment(rawValue:
            "\(label): the prose ENDS at \(pane.right) live, \(column.maxX) at rest — "
                + "a different measure re-wraps her lines"))
        let blockBelow = {
            #expect(abs(shift - expectedShift) <= 0.5, Comment(rawValue:
                "\(label): the block below moved \(shift) pt — it must not move at all "
                    + "(#154 (b): the index faces show stored blank lines at rest)"))
        }
        if shape == .overTwoBlankLines {
            // **The rider's ONE residual, TextKit 2's own (measured on 27.0 —
            // the RIDER record):** after an EMPTY last paragraph, TK2 lays the
            // extra line fragment that follows the final newline as a short
            // box overlapping the line above (bare TK2, plain style: `A\n\n`
            // stands 50 pt where three 22-pt lines stand 66). So the LIVE
            // editor draws a block's last stored blank line short when another
            // blank line precedes it, while the read tier draws both whole —
            // measured −10 pt (Terminal) / −20 pt (Study). Not imitated: a read
            // tier copying a layout anomaly would go wrong the day TK2 fixes
            // it. Known, not hidden — and the day this stops reproducing,
            // Swift Testing says so (a known issue that is not recorded fails).
            withKnownIssue(
                "TK2's extra line after an empty last paragraph stands short (27.0) — #154 (b)'s one residual",
                isIntermittent: false, blockBelow)
        } else {
            blockBelow()
        }
    }

    /// The middle of a read-tier column's LAST line — the blank line under its
    /// text, for a block stored over one (the tier draws it since the rider).
    private static func onItsBlankLine(_ column: CGRect) -> CGPoint {
        let oneLine = ReadTierClickPlace.height(
            of: "x", columnWidth: 400, font: EditorDocument.baseFont)
        return CGPoint(x: column.minX + column.width * 0.3, y: column.maxY - oneLine / 2)
    }

    /// Display == stored: what she clicked is where the caret goes — the
    /// blank line under the text, i.e. the stored text's end.
    private static func expectCaretOnTheBlankLine(_ pane: PaneTextView, text: String, label: String) {
        let length = (text as NSString).length
        #expect(text.hasSuffix("\n"), "the fixture's block above ends over a blank line")
        #expect(pane.selectedRange().location == length, Comment(rawValue:
            "\(label): a click on the shown blank line lands ON it — caret "
                + "\(pane.selectedRange().location) of \(length)"))
    }

    // MARK: - The book Index

    @Test(arguments: [ThemeVoice.terminal, .study], IndexTierShape.allCases)
    func theBookIndexsLivePaneIsItsReadTierLineForLine(
        _ voice: ThemeVoice, _ shape: IndexTierShape
    ) async throws {
        try await Self.withStore(voice: voice) { session, db, theme in
            try await Self.bookIndexCase(voice, shape, session, db, theme)
        }
    }

    private static func bookIndexCase(
        _ voice: ThemeVoice, _ shape: IndexTierShape,
        _ session: AppSession, _ db: AppDatabase, _ theme: ThemeStore
    ) async throws {
        let reading = try session.operations.createReading(name: "the index", kind: .curated)
        let note = try Self.mintNote(session, shape: shape)
        try session.operations.addPostToReading(note.postID, to: reading.id)
        let readingID = reading.id
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { try Queries.reading($0, id: readingID) },
            sections: [], deletedSections: [], assignments: [:]))
        structure.mode = .index
        #if DEBUG
        BookIndexGeometry.reset()
        #endif
        let rig = Self.panel(
            BookView(session: session, readingID: readingID, model: model, structure: structure)
                .environment(theme))
        defer { rig.close() }
        #if DEBUG
        let target = note.blocks[1], below = note.blocks[2]
        #expect(await rig.poll {
            BookIndexGeometry.paneReadTierFrames[target.blockID] != nil
                && BookIndexGeometry.paneReadTierFrames[below.blockID] != nil
        }, "the pane laid the blocks out read-cheap")
        let column = try #require(await rig.settled {
            BookIndexGeometry.paneReadTierFrames[target.blockID]
        })
        let nextTop = try #require(await rig.settled {
            BookIndexGeometry.paneReadTierFrames[below.blockID]
        }).minY
        // U0's fidelity arm, carried: the replica this pin compares against
        // IS what SwiftUI drew (the block's height).
        let replica = ReadTierClickPlace.height(
            of: target.text, columnWidth: column.width, font: EditorDocument.baseFont)
        #expect(abs(replica - column.height) <= 0.5, Comment(rawValue:
            "\(voice): the replica lays the block out at \(replica) pt; SwiftUI drew \(column.height)"))
        rig.click(at: rig.windowPoint(global: CGPoint(
            x: column.minX + column.width * 0.3, y: column.minY + 8)))
        let identifier = "pane:\(BookIndexEditModel.columnID)|\(target.variantID)"
        #expect(await rig.poll {
            editablePanes(in: rig.hosting).first?.identifier?.rawValue == identifier
        }, "the clicked block went live")
        let nextTopAfter = try #require(await rig.settled {
            BookIndexGeometry.paneReadTierFrames[below.blockID]
        }).minY
        let pane = try #require(editablePanes(in: rig.hosting).first)
        // `.global` here is the WINDOW's y-down space, titlebar included
        // (U0's measured rig fact).
        let livePane = proseOf(pane) { point in
            let window = pane.convert(point, to: nil)
            return CGPoint(x: window.x, y: rig.window.frame.height - window.y)
        }
        Self.expectOneVocabulary(
            "book Index · \(voice) · \(shape)", shape: shape, text: target.text,
            column: column, nextTop: nextTop, nextTopAfter: nextTopAfter, pane: livePane)
        // The new truth's other half (the rider): a click ON a blank line the
        // tier now shows lands ON it — the block above ends over one.
        let above = note.blocks[0]
        let aboveColumn = try #require(await rig.settled {
            BookIndexGeometry.paneReadTierFrames[above.blockID]
        })
        rig.click(at: rig.windowPoint(global: Self.onItsBlankLine(aboveColumn)))
        #expect(await rig.poll {
            editablePanes(in: rig.hosting).first?.identifier?.rawValue
                == "pane:\(BookIndexEditModel.columnID)|\(above.variantID)"
        }, "the block above went live")
        Self.expectCaretOnTheBlankLine(
            try #require(editablePanes(in: rig.hosting).first), text: above.text,
            label: "book Index · \(voice) · \(shape)")
        #endif
    }

    // MARK: - The note's Read ▸ edit

    @Test(arguments: [ThemeVoice.terminal, .study], IndexTierShape.allCases)
    func theReadEditLivePaneIsItsReadTierLineForLine(
        _ voice: ThemeVoice, _ shape: IndexTierShape
    ) async throws {
        try await Self.withStore(voice: voice) { session, _, theme in
            let note = try Self.mintNote(session, shape: shape)
            ReadModeView.remember(.edit, postID: note.postID)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            _ = session.commandRouter.registerDetail(postID: note.postID, mode: .read) { _ in }
            let model = BlockTOCViewModel(session: session, postID: note.postID)
            let rig = Self.panel(
                ReadModeView(session: session, postID: note.postID, model: model)
                    .environment(theme))
            defer {
                rig.close()
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(note.postID))
                session.commandRouter.forgetCurrentBlock(for: note.postID)
            }
            #if DEBUG
            let target = note.blocks[1], below = note.blocks[2]
            #expect(await rig.poll {
                !model.rows.isEmpty && ReadModeOracle.editBlockFrames[target.blockID] != nil
                    && ReadModeOracle.editBlockFrames[below.blockID] != nil
            })
            #expect(ReadModeOracle.liveBlockID == nil,
                    "nothing is live before the click (a live block above would move the rows)")
            // The oracle's frame is the whole ROW; the text column sits inside
            // it by the read tier's own padding (`IndexProseColumn`).
            let row = try #require(await rig.settled {
                ReadModeOracle.editBlockFrames[target.blockID]
            })
            let top = IndexProseColumn.readTierTop(
                resting: IndexProseColumn.readEditRestingTop, paneInset: PaneTextView.proseTopInset)
            let bottom = IndexProseColumn.readTierBottom(
                resting: IndexProseColumn.readEditRestingTop, paneInset: PaneTextView.proseTopInset)
            let leading = IndexProseColumn.readTierLeading(
                resting: IndexProseColumn.readEditResting, paneInset: PaneTextView.proseLeadingInset)
            let column = CGRect(
                x: row.minX + leading, y: row.minY + top,
                width: row.width - leading - IndexProseColumn.readEditResting,
                height: row.height - top - bottom)
            let nextTop = try #require(await rig.settled {
                ReadModeOracle.editBlockFrames[below.blockID]
            }).minY
            let replica = ReadTierClickPlace.height(
                of: target.text, columnWidth: column.width, font: EditorDocument.baseFont)
            #expect(abs(replica - column.height) <= 0.5, Comment(rawValue:
                "\(voice): the replica lays the block out at \(replica) pt; SwiftUI drew \(column.height)"))
            rig.click(at: rig.windowPoint(CGPoint(
                x: column.minX + column.width * 0.3, y: column.minY + 8)))
            #expect(await rig.poll {
                editablePanes(in: rig.hosting).first?.identifier?.rawValue
                    == "pane:\(ReadEditPane.role)|\(target.variantID)"
            }, "the clicked block went live")
            let nextTopAfter = try #require(await rig.settled {
                ReadModeOracle.editBlockFrames[below.blockID]
            }).minY
            let pane = try #require(editablePanes(in: rig.hosting).first)
            // Read's oracle records in its host's own named space, which IS
            // the hosting view's (U0's rig fact).
            let livePane = proseOf(pane) { point in
                let local = rig.hosting.convert(pane.convert(point, to: nil), from: nil)
                return CGPoint(
                    x: local.x,
                    y: rig.hosting.isFlipped ? local.y : rig.hosting.bounds.height - local.y)
            }
            Self.expectOneVocabulary(
                "note Read ▸ edit · \(voice) · \(shape)", shape: shape, text: target.text,
                column: column, nextTop: nextTop, nextTopAfter: nextTopAfter, pane: livePane)
            // The rider's other half: a click ON a shown blank line lands on it.
            let above = note.blocks[0]
            let aboveRow = try #require(await rig.settled {
                ReadModeOracle.editBlockFrames[above.blockID]
            })
            let aboveColumn = CGRect(
                x: aboveRow.minX + leading, y: aboveRow.minY + top,
                width: aboveRow.width - leading - IndexProseColumn.readEditResting,
                height: aboveRow.height - top - bottom)
            rig.click(at: rig.windowPoint(Self.onItsBlankLine(aboveColumn)))
            #expect(await rig.poll {
                editablePanes(in: rig.hosting).first?.identifier?.rawValue
                    == "pane:\(ReadEditPane.role)|\(above.variantID)"
            }, "the block above went live")
            Self.expectCaretOnTheBlankLine(
                try #require(editablePanes(in: rig.hosting).first), text: above.text,
                label: "note Read ▸ edit · \(voice) · \(shape)")
            #endif
        }
    }
}

// MARK: - Every OTHER pane is byte-unchanged (her ratification's own terms)

/// **Her ratification (2026-09-27, in-session):** *"yeah that's fine, it is
/// the goal for it to not change appearance when you start editing"* — the
/// block being edited in the two index-like faces adopts the reading rows'
/// spacing, and Write and Takes stay untouched. The second half is pinned
/// here: a pane whose host hands it no line metrics lays out with the Write
/// editor's base style exactly (Takes cards and article, lenses, Compare, the
/// Write takes panel, Canvas, the Blocks workbench), and only the two index
/// hosts hand it any.
@MainActor
@Suite("18l-c U5 — every other pane keeps the Write editor's base style")
struct PaneLineMetricsScopeTests {
    private static func mountedPane(_ view: PaneSurfaceView) async -> PaneTextView? {
        let hosting = NSHostingView(rootView: view.frame(width: 400))
        hosting.frame = NSRect(x: 0, y: 0, width: 400, height: 300)
        for _ in 0..<20 {
            hosting.layoutSubtreeIfNeeded()
            if let pane = Self.pane(in: hosting) { return pane }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return nil
    }

    private static func pane(in view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews { if let found = pane(in: sub) { return found } }
        return nil
    }

    /// The three places a pane's paragraph style lives — the stored text, the
    /// style it types with, and the view's default.
    private static func styles(_ pane: PaneTextView) -> [NSParagraphStyle?] {
        [
            pane.textStorage?.attribute(.paragraphStyle, at: 0, effectiveRange: nil)
                as? NSParagraphStyle,
            pane.typingAttributes[.paragraphStyle] as? NSParagraphStyle,
            pane.defaultParagraphStyle,
        ]
    }

    @Test func aPaneWithNoHostMetricsLaysOutWithTheWriteBaseStyle() async throws {
        let pane = try #require(await Self.mountedPane(PaneSurfaceView(text: "one\ntwo", isLive: true)))
        let base = EditorDocument.baseParagraphStyle
        for style in Self.styles(pane) {
            #expect(style?.lineSpacing == base.lineSpacing, "no line spacing a host did not ask for")
            #expect(style?.paragraphSpacing == base.paragraphSpacing, "the Write editor's own gap")
        }
    }

    @Test func aPaneHandedTheIndexMetricsLaysOutWithThem() async throws {
        let pane = try #require(await Self.mountedPane(
            PaneSurfaceView(text: "one\ntwo", isLive: true, lineMetrics: IndexProseColumn.lines)))
        for style in Self.styles(pane) {
            #expect(style?.lineSpacing == IndexProseColumn.lines.lineSpacing)
            #expect(style?.paragraphSpacing == IndexProseColumn.lines.textKitParagraphSpacing)
        }
    }

    /// Only the two index-like hosts hand a pane line metrics — a third
    /// caller is a look change on a surface she did not rule on, and must say
    /// so here first.
    @Test func onlyTheTwoIndexHostsHandAPaneLineMetrics() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        var callers: Set<String> = []
        for root in ["Variorum", "Shared"] {
            let walker = try #require(FileManager.default.enumerator(
                at: app.appendingPathComponent(root), includingPropertiesForKeys: nil))
            for case let file as URL in walker
            where file.pathExtension == "swift" && file.lastPathComponent != "PaneSurface.swift" {
                let source = try String(contentsOf: file, encoding: .utf8)
                let code = source.split(separator: "\n").filter {
                    let line = $0.trimmingCharacters(in: .whitespaces)
                    return !line.hasPrefix("//") && !line.hasPrefix("*")
                }
                if code.contains(where: { $0.contains("lineMetrics:") }) {
                    callers.insert(file.lastPathComponent)
                }
            }
        }
        #expect(callers == ["BookIndexView.swift", "ReadEditPane.swift"],
                "the hosts handing a pane line metrics: \(callers.sorted())")
    }

    // MARK: - The rider's blank rule is the two index hosts' alone

    /// Every Swift file under `root`, as (name, code lines — comments dropped).
    private static func codeLines(under root: String) throws -> [(String, [Substring])] {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        let walker = try #require(FileManager.default.enumerator(
            at: app.appendingPathComponent(root), includingPropertiesForKeys: nil))
        var out: [(String, [Substring])] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let source = try String(contentsOf: file, encoding: .utf8)
            out.append((file.lastPathComponent, source.split(separator: "\n").filter {
                let line = $0.trimmingCharacters(in: .whitespaces)
                return !line.hasPrefix("//") && !line.hasPrefix("*")
            }))
        }
        return out
    }

    /// **18l-c U5's rider (her #154 (b)):** the two index faces SHOW stored
    /// blank lines — and only they. The read page, the book's Read, the Library
    /// panel and the PHONE keep the flow's folded default, byte for byte. So:
    /// the vocabulary's name is read by exactly the two hosts, the click's
    /// replica and the two hosts' height models; nobody passes `.shown` by
    /// hand; and the phone never names the rule at all.
    @Test func onlyTheTwoIndexHostsShowStoredBlankLines() throws {
        var readers: Set<String> = []
        var literal: [String] = []
        for root in ["Variorum", "Shared"] {
            for (name, lines) in try Self.codeLines(under: root) {
                if lines.contains(where: { $0.contains("IndexProseColumn.blankLines") }) {
                    readers.insert(name)
                }
                if lines.contains(where: { $0.contains("blankLines: .shown") }) {
                    literal.append(name)
                }
            }
        }
        #expect(readers == [
            "BookIndexView.swift", "ReadEditPane.swift", "ReadTierClickPlace.swift",
            "BookIndexPaneHeights.swift", "ReadNoteLanding.swift",
        ], "the readers of the index tiers' blank rule: \(readers.sorted())")
        #expect(literal.isEmpty, "a hand-passed .shown: \(literal)")
        let phone = try Self.codeLines(under: "VariorumMobile")
            .filter { $0.1.contains(where: { $0.contains("blankLines") }) }.map(\.0)
        #expect(phone.isEmpty, "the phone names the blank rule: \(phone)")
    }

    /// **The two hosts' HEIGHT MODELS count the line the tier now draws**
    /// (the rider's brief point 5): a far row's reservation — the book Index
    /// pane's (F3) and Read ▸ edit's manifest (U1) — must stand at the new
    /// resting height, or every Sherlock story stands ~one line and one gap
    /// per paragraph short until it draws. Under `.shown` a block with a
    /// newline stands exactly one line of the model (its pitch less the line
    /// spacing a last line never carries) and one gap taller; a block with NO
    /// newline — her own notes' usual shape — is byte-unchanged; the Outline's
    /// and the flow's models keep `.folded`.
    @MainActor
    @Test func theHostHeightModelsCountTheShownBlankLine() {
        let folded = ProseHeightModel.Metrics(
            charsPerLine: 70, linePitch: 26, lineSpacing: 4, paragraphGap: 8)
        var shown = folded
        shown.blankLines = .shown
        func height(_ newlines: Int, _ metrics: ProseHeightModel.Metrics) -> CGFloat {
            ProseHeightModel.height(extents: [Queries.BlockExtent(
                containerID: "p", blockID: "b", characters: 420, newlines: newlines)],
                metrics: metrics) ?? 0
        }
        let delta: CGFloat = height(1, shown) - height(1, folded)
        let oneLineAndAGap: CGFloat = 26 - 4 + 8
        #expect(delta == oneLineAndAGap, "one shown blank line: one line + one gap")
        let unchanged: Bool = height(0, shown) == height(0, folded)
        #expect(unchanged, "no newline, no change (her own notes)")
        #expect(ProseHeightModel.Metrics().blankLines == .folded, "the default folds")
        #expect(BookIndexPaneHeights.metrics(columnWidth: 640).prose.blankLines == .shown)
        #expect(ReadNoteHeights.metrics(face: .edit, contentWidth: 640, typeScale: 1)
            .prose.blankLines == .shown)
        #expect(ReadNoteHeights.metrics(face: .page, contentWidth: 640, typeScale: 1)
            .prose.blankLines == .folded, "Read's page face keeps the flow's rule")
    }

    /// The shared transform's DEFAULT still folds — and the host choice shows.
    @Test func theSharedTransformStillFoldsByDefault() {
        let stored = "one\n\ntwo\n"
        #expect(FlowParagraph.paragraphs(of: stored).count == 2, "folded: the two text lines")
        let shown = FlowParagraph.paragraphs(of: stored, blankLines: .shown)
        #expect(shown.map { String($0.text.characters) } == ["one", "", "two", ""],
                "shown: every stored line, the blank ones empty (display == stored)")
        #expect(IndexProseColumn.blankLines == .shown)
    }
}

private extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let scale = CGFloat(pow(10, Double(places)))
        return (self * scale).rounded() / scale
    }
}
