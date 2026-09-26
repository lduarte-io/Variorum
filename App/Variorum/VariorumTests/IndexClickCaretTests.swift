//
//  IndexClickCaretTests.swift
//  VariorumTests
//
//  **18l UNIT U0, item 1 — her report (2026-09-25), verbatim:** *"While in
//  index mode on a book, clicking onto text isn't working correctly. When I'm
//  in sherlock holmes and I click on top of a line of text, my cursor moves to
//  the empty paragraph / block between the text and then I have to try
//  clicking again to get onto the actual text."* — and the same evening:
//  *"I'm clicking DIRECTLY on the line of text and I always go to an empty
//  line when I click, so it's not a slight mislick, it's a refusal of clicking
//  into the text."*
//
//  The fixture is HER note's shape, not a tidy one: the sample library's
//  stories are bulk-imported Gutenberg text, and the k−1 spacing rule keeps
//  the blank line between two paragraphs as CONTENT — 211 of *Copper
//  Beeches*' 212 blocks end in one `\n` (18k C6b, measured). So every block
//  but the last carries a trailing newline, and a caret parked at a block's
//  END sits on the empty line under its text: exactly the "empty paragraph /
//  block between the text" she keeps landing on.
//
//  The claim pinned is hers, as geometry a caret can be checked against: a
//  REAL click (down + up through `NSApp.sendEvent`, the canvas rig's window
//  shape — the one that delivers pointer events to a SwiftUI hosting view) on
//  a line of a READ-TIER block makes that block live with its caret ON THE
//  LINE CLICKED — never on the empty line under it, never at the block's end.
//  Two lines per block, the ones her walk names: the first line, and the last
//  line (the one DIRECTLY ABOVE the empty separator — her trigger); on two
//  blocks — one over a blank line, and the note's LAST block (no trailing
//  newline, so a caret parked at its end sits on its last line, not a blank).
//
//  **RED ON OLD, measured (`18l-u0-pin1-prefix2.log`):** the book Index
//  parked EVERY click at the block's END — 366 of 366 on the block over a
//  blank line, i.e. ON THE EMPTY LINE (her symptom, deterministic, whichever
//  line was clicked); the last block's END is its last line, so a first-line
//  click landed four lines low. The note's Read ▸ edit — the same read-tier →
//  live swap — parked every click at the block's START (the note's entry
//  rule, `PaneCaretLanding.entering` → `.start`), so a last-line click landed
//  on line 0. Neither surface ever handed the click's PLACE to the pane: the
//  read tier is SwiftUI `Text` with an `onTapGesture`, which knows no point.
//
//  **The rig's coordinate fact (measured by this pin's first run):** SwiftUI's
//  `.global` frame is the WINDOW's y-down space here, titlebar included — a
//  click aimed through the hosting view's space from a `.global` frame landed
//  one titlebar low (the rendered ink sat 28+ pt above the reported frame),
//  so the book pin converts through `windowPoint(global:)`. Read's oracle
//  records in its host's own named space, which IS the hosting view's.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// Prose long enough to wrap to several lines at the Index's 640-pt measure in
/// either voice — Gutenberg's own sentences, so the line breaks fall where hers
/// do.
private let paragraphs = [
    "“To the man who loves art for its own sake,” remarked Sherlock Holmes, tossing aside "
        + "the advertisement sheet of the Daily Telegraph, “it is frequently in its least "
        + "important and lowliest manifestations that the keenest pleasure is to be derived. "
        + "It is pleasant to me to observe, Watson, that you have so far grasped this truth.”",
    "“And yet,” said I, smiling, “I cannot quite hold myself absolved from the charge of "
        + "sensationalism which has been urged against my records.” “You have erred, "
        + "perhaps,” he observed, taking up a glowing cinder with the tongs and lighting with "
        + "it the long cherry-wood pipe which was wont to replace his clay when he was in a "
        + "disputatious rather than a meditative mood.",
    "It was a cold morning of the early spring, and we sat after breakfast on either side of "
        + "a cheery fire in the old room at Baker Street. A thick fog rolled down between the "
        + "lines of dun-coloured houses, and the opposing windows loomed like dark, shapeless "
        + "blurs through the heavy yellow wreaths.",
]

/// The caret's LINE in a live pane, read from TK2's own line fragments — the
/// same geometry the pane draws the caret against. `nil` means the caret sits
/// on the EMPTY line after a trailing newline (the line her click keeps
/// landing on); otherwise the index of the text line it is on.
@MainActor
private func caretLine(in pane: NSTextView) -> (line: Int?, lines: Int) {
    let text = pane.string as NSString
    let caret = pane.selectedRange().location
    var ranges: [NSRange] = []
    if let layout = pane.textLayoutManager, let content = layout.textContentManager {
        layout.enumerateTextLayoutFragments(
            from: layout.documentRange.location, options: [.ensuresLayout]
        ) { fragment in
            let start = content.offset(
                from: content.documentRange.location, to: fragment.rangeInElement.location)
            for line in fragment.textLineFragments where line.characterRange.length > 0 {
                ranges.append(NSRange(
                    location: start + line.characterRange.location,
                    length: line.characterRange.length))
            }
            return true
        }
    }
    if caret >= text.length, text.length > 0, text.character(at: text.length - 1) == 10 {
        return (nil, ranges.count)
    }
    for (index, range) in ranges.enumerated() {
        if caret < NSMaxRange(range) { return (index, ranges.count) }
    }
    return (ranges.isEmpty ? nil : ranges.count - 1, ranges.count)
}

/// One minted block of the fixture note.
struct MintedBlock: Sendable {
    let blockID: String
    let variantID: String
    let text: String
}

@MainActor
private func editablePanes(in view: NSView) -> [PaneTextView] {
    var out: [PaneTextView] = []
    if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
    for sub in view.subviews { out += editablePanes(in: sub) }
    return out
}

/// Where a click lands on a block's read-tier prose.
enum IndexClickedLine: String, CaseIterable, CustomStringConvertible, Sendable {
    /// The block's first line.
    case first
    /// The block's LAST line — directly above the empty separator her note
    /// carries under every paragraph (the trigger).
    case last
    var description: String { rawValue }
}

@MainActor
@Suite("18l U0 — a click on an Index line lands the caret ON that line", .serialized)
struct IndexClickCaretTests {
    // MARK: - The rig

    @MainActor
    struct Rig {
        let window: NSPanel
        let hosting: NSView

        /// The app's own event pump: a bare RunLoop never DISPATCHES queued
        /// NSEvents (the canvas rig's rule, and `ReadModeTests`').
        func pump(_ seconds: TimeInterval) {
            let deadline = Date().addingTimeInterval(seconds)
            while Date() < deadline {
                if let event = NSApp.nextEvent(
                    matching: .any, until: deadline, inMode: .default, dequeue: true) {
                    if event.type == .appKitDefined || event.type == .systemDefined
                        || event.type == .applicationDefined {
                        continue
                    }
                    NSApp.sendEvent(event)
                }
            }
        }

        func turn() async {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }

        @discardableResult
        func poll(timeout: TimeInterval = 5, until condition: () -> Bool) async -> Bool {
            let deadline = Date().addingTimeInterval(timeout)
            while Date() < deadline {
                if condition() { return true }
                await turn()
            }
            return condition()
        }

        /// A point in the hosting view's y-down space → WINDOW coordinates
        /// (the hosting view is flipped on this OS; handled either way).
        func windowPoint(_ point: CGPoint) -> CGPoint {
            let local = hosting.isFlipped
                ? NSPoint(x: point.x, y: point.y)
                : NSPoint(x: point.x, y: hosting.bounds.height - point.y)
            return hosting.convert(local, to: nil)
        }

        /// A point in SwiftUI's `.global` space → WINDOW coordinates.
        /// **Measured, not assumed** (this pin's own first run): under this
        /// rig `.global` is the WINDOW's y-down space — titlebar included —
        /// not the hosting view's; the rendered ink of a block sat one
        /// titlebar ABOVE the frame `.global` reported, and a click aimed
        /// through the hosting view's space landed a line or more low. The
        /// window's base coordinates are the same space flipped.
        func windowPoint(global point: CGPoint) -> CGPoint {
            CGPoint(x: point.x, y: window.frame.height - point.y)
        }

        /// A REAL click: down + up through `NSApp.sendEvent`.
        func click(at point: CGPoint) {
            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                guard let event = NSEvent.mouseEvent(
                    with: type, location: point, modifierFlags: [],
                    timestamp: ProcessInfo.processInfo.systemUptime,
                    windowNumber: window.windowNumber, context: nil,
                    eventNumber: 1, clickCount: 1, pressure: type == .leftMouseUp ? 0 : 1)
                else { continue }
                NSApp.sendEvent(event)
                pump(0.01)
            }
        }

        func close() {
            window.orderOut(nil)
            window.close()
        }
    }

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

    private static func withStore<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// Her note's shape: every block but the last ends in ONE newline.
    private static func mintNote(
        _ session: AppSession, title: String
    ) throws -> (postID: String, blocks: [MintedBlock]) {
        let post = try session.operations.createPost(title: title)
        var blocks: [MintedBlock] = []
        for (i, prose) in paragraphs.enumerated() {
            let text = i < paragraphs.count - 1 ? prose + "\n" : prose
            let minted = try session.operations.newBlock(in: post.id, text: text)
            blocks.append(MintedBlock(blockID: minted.block.id, variantID: minted.variant.id, text: text))
        }
        return (post.id, blocks)
    }

    /// The point on `line` of a read-tier text column, `xFraction` of the way
    /// across it — inside the line's glyph box, never in a gap.
    private static func point(
        on line: IndexClickedLine, of column: CGRect, xFraction: CGFloat = 0.3
    ) -> CGPoint {
        let x = column.minX + column.width * xFraction
        switch line {
        case .first: return CGPoint(x: x, y: column.minY + 8)
        case .last: return CGPoint(x: x, y: column.maxY - 8)
        }
    }

    /// What the click must produce, stated once for both surfaces.
    private static func expectCaret(
        in pane: PaneTextView, onLine line: IndexClickedLine, block: String, surface: String
    ) {
        let (caret, lines) = caretLine(in: pane)
        let expected = line == .first ? 0 : lines - 1
        let length = (pane.string as NSString).length
        let where_ = "\(surface) · \(block) · \(line) line"
        let at = pane.selectedRange().location
        print("[18l U0 pin] \(where_): caret \(at) of \(length) → line \(String(describing: caret)) of \(lines)")
        #expect(caret != nil, Comment(rawValue:
            "\(where_): the caret must land on the clicked line, not the empty line after "
                + "the block's text (caret \(at) of \(length))"))
        #expect(caret == expected, Comment(rawValue:
            "\(where_): the caret is on line \(String(describing: caret)) of \(lines); "
                + "the click was on line \(expected)"))
        #expect(pane.selectedRange().location < length || !pane.string.hasSuffix("\n"),
                "\(surface) · \(block) · \(line) line: never parked at the block's END")
    }

    // MARK: - The book Index (her report's surface)

    @Test(arguments: [IndexClickedLine.first, .last])
    func aClickOnABookIndexLineLandsTheCaretOnThatLine(_ line: IndexClickedLine) async throws {
        try await Self.withStore { session, db in
            let reading = try session.operations.createReading(name: "the index", kind: .curated)
            let note = try Self.mintNote(session, title: "a story")
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
                    .environment(ThemeStore(session: session)))
            defer { rig.close() }
            #if DEBUG
            // The middle block (a trailing newline under it) and the LAST
            // block (none) — one fresh landing each, the ring moving between.
            for target in [note.blocks[1], note.blocks[2]] {
                #expect(await rig.poll { BookIndexGeometry.paneReadTierFrames[target.blockID] != nil },
                        "the pane laid the block out read-cheap")
                await rig.poll(timeout: 0.3) { false }
                let column = try #require(BookIndexGeometry.paneReadTierFrames[target.blockID])
                print("[18l U0 pin] book Index column \(column) · click \(Self.point(on: line, of: column))")
                rig.click(at: rig.windowPoint(global: Self.point(on: line, of: column)))
                let identifier = "pane:\(BookIndexEditModel.columnID)|\(target.variantID)"
                let live = await rig.poll {
                    editablePanes(in: rig.hosting).first?.identifier?.rawValue == identifier
                }
                #expect(live, "the clicked block went live")
                await rig.poll(timeout: 0.3) { false }
                let pane = try #require(editablePanes(in: rig.hosting).first)
                Self.expectCaret(
                    in: pane, onLine: line,
                    block: target.text.hasSuffix("\n") ? "a block over a blank line" : "the last block",
                    surface: "book Index")
            }
            #endif
        }
    }

    // MARK: - The note's Read ▸ edit (the same read-tier → live swap)

    @Test(arguments: [IndexClickedLine.first, .last])
    func aClickOnAReadEditLineLandsTheCaretOnThatLine(_ line: IndexClickedLine) async throws {
        try await Self.withStore { session, _ in
            let note = try Self.mintNote(session, title: "a story")
            ReadModeView.remember(.edit, postID: note.postID)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            _ = session.commandRouter.registerDetail(postID: note.postID, mode: .read) { _ in }
            let model = BlockTOCViewModel(session: session, postID: note.postID)
            let rig = Self.panel(
                ReadModeView(session: session, postID: note.postID, model: model)
                    .environment(ThemeStore(session: session)))
            defer {
                rig.close()
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(note.postID))
                session.commandRouter.forgetCurrentBlock(for: note.postID)
            }
            #if DEBUG
            #expect(await rig.poll { !model.rows.isEmpty && ReadModeOracle.selectedBlockID != nil })
            for target in [note.blocks[1], note.blocks[2]] {
                #expect(await rig.poll { ReadModeOracle.editBlockFrames[target.blockID] != nil })
                await rig.poll(timeout: 0.3) { false }
                // The oracle's frame is the whole BLOCK row (its padding
                // included); the text column sits inside it by the read tier's
                // own padding (`IndexProseColumn`).
                let row = try #require(ReadModeOracle.editBlockFrames[target.blockID])
                let top = IndexProseColumn.readTierTop(
                    resting: IndexProseColumn.readEditRestingTop,
                    paneInset: PaneTextView.proseTopInset)
                let column = CGRect(
                    x: row.minX + 11, y: row.minY + top,
                    width: row.width - 21,
                    height: row.height - top - IndexProseColumn.readEditRestingTop)
                rig.click(at: rig.windowPoint(Self.point(on: line, of: column)))
                let live = await rig.poll {
                    editablePanes(in: rig.hosting).first?.identifier?.rawValue
                        == "pane:\(ReadEditPane.role)|\(target.variantID)"
                }
                #expect(live, "the clicked block went live")
                await rig.poll(timeout: 0.3) { false }
                let pane = try #require(editablePanes(in: rig.hosting).first)
                Self.expectCaret(
                    in: pane, onLine: line,
                    block: target.text.hasSuffix("\n") ? "a block over a blank line" : "the last block",
                    surface: "note Read ▸ edit")
            }
            #endif
        }
    }
}
