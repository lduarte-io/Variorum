//
//  IndexLandingCaretTests.swift
//  VariorumTests
//
//  **18l-b UNIT U4, item 2 — where a book-Index LANDING puts the caret**
//  (18l U0's sweep finding S4, owned here; QUESTIONS #153, PROVISIONAL).
//
//  Her U0 report, verbatim: *"When I'm in sherlock holmes and I click on top
//  of a line of text, my cursor moves to the empty paragraph / block between
//  the text"* — U0 fixed the Index CLICK (the click brings its place); S4 is
//  the same artifact on the Index's other road in: a Read ▸ Scroll sentence
//  click (and the paged reader's, and the note box's "edit here") LANDS in the
//  Index through `BookViewModel.requestLanding` → `BookIndexEditModel
//  .takePendingLiveBlock`, whose pane went live with `.leave` — the selection
//  where AppKit's `string =` left it, the take's END. Her notes keep the blank
//  line between paragraphs as CONTENT (211 of *Copper Beeches*' 212 blocks end
//  in `\n`), so the END is the EMPTY LINE under the text: U0's scratch probe
//  measured caret 329 of 329.
//
//  **The decision (#153, PROVISIONAL — the trace is in the U4 RECORD):** no
//  face on this road hands on WHERE in the block she clicked (Read ▸ Scroll's
//  paragraph is a SwiftUI `Text` with a bare tap; the paged leaf passes a
//  block, not its CoreText index — cheap to wire, but a Read click seeding a
//  caret at a character is #149's product question), so the landing carries no
//  offset and `LandingTarget.utf16Offset` — set by no production site — is
//  deleted; the arriving pane puts a landing's caret at the landed block's
//  START, which is the rule the value was designed with — its deleted field's
//  doc, quoted at #153 (*"the landing then puts the caret at the block's
//  start"*), what note Read's twin click-through
//  does on a block she was NOT last in (`ReadModeView.openInEdit` → the entry
//  rule's `.start`; the block she was last in lands at her remembered caret
//  there — #153's (a′), not built), QUESTIONS #97's built (a), and exactly
//  where the landing puts her eyes (the block's
//  top at the page's top). A CLICK still brings its own place (U0), and every
//  other road keeps `.leave`.
//
//  RED ON OLD: the landing's pane armed `.leave`, and the caret sat on the
//  empty line after the text (`caret N of N`).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// Her note's shape: Gutenberg paragraphs, every block but the last ending in
/// ONE newline (the k−1 blank line kept as content).
private let paragraphs = [
    "“To the man who loves art for its own sake,” remarked Sherlock Holmes, tossing aside "
        + "the advertisement sheet of the Daily Telegraph, “it is frequently in its least "
        + "important and lowliest manifestations that the keenest pleasure is to be derived.”",
    "“And yet,” said I, smiling, “I cannot quite hold myself absolved from the charge of "
        + "sensationalism which has been urged against my records.” “You have erred, "
        + "perhaps,” he observed, taking up a glowing cinder with the tongs.",
    "It was a cold morning of the early spring, and we sat after breakfast on either side of "
        + "a cheery fire in the old room at Baker Street.",
]

private struct Minted: Sendable {
    let blockID: String
    let variantID: String
    let text: String
}

@MainActor
private func withStoryBook<T>(
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String,
        _ postIDs: [String], _ blocks: [String: [Minted]]
    ) async throws -> T
) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 53))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the stories", kind: .curated)
        var postIDs: [String] = []
        var blocks: [String: [Minted]] = [:]
        for p in 0..<3 {
            let post = try session.operations.createPost(title: "story \(p)")
            var made: [Minted] = []
            for (i, prose) in paragraphs.enumerated() {
                let text = i < paragraphs.count - 1 ? prose + "\n" : prose
                let minted = try session.operations.newBlock(in: post.id, text: text)
                made.append(Minted(blockID: minted.block.id, variantID: minted.variant.id, text: text))
            }
            blocks[post.id] = made
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs, blocks)
    }
}

@MainActor
private func editablePanes(in view: NSView) -> [PaneTextView] {
    var out: [PaneTextView] = []
    if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
    for sub in view.subviews { out += editablePanes(in: sub) }
    return out
}

/// Is the caret on the EMPTY line after a trailing newline — the line her
/// click kept landing on? (`IndexClickCaretTests`' own reading, reduced to
/// the one question this pin asks.)
@MainActor
private func caretIsOnTheEmptyTail(_ pane: NSTextView) -> Bool {
    let text = pane.string as NSString
    let caret = pane.selectedRange().location
    return caret >= text.length && text.length > 0 && text.character(at: text.length - 1) == 10
}

@MainActor
@Suite("18l-b U4 — a book-Index LANDING puts the caret at the block's start, never the blank line (#153)", .serialized)
struct IndexLandingCaretTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: [], deletedSections: [], assignments: [:]))
        return structure
    }

    /// **The model's half, pure and fast:** a landing taken on the note's
    /// rows arms `.start` for the landed take; a CLICK still arms its own
    /// place (U0, unchanged); a pane's own focus request arms nothing
    /// (`.leave`, unchanged). RED ON OLD: the landing armed `.leave`.
    @Test func aLandingArmsTheBlocksStartAndAClickStillBringsItsPlace() async throws {
        try await withStoryBook { session, _, _, postIDs, blocks in
            let edit = BookIndexEditModel(session: session)
            defer { edit.teardown() }
            let target = blocks[postIDs[1]]![1]
            edit.requestLiveBlock(LandingTarget(postID: postIDs[1], blockID: target.blockID))
            let rows = blocks[postIDs[1]]!.map {
                Queries.TOCRow(
                    blockID: $0.blockID, placementID: "pl", name: nil,
                    variantID: $0.variantID, text: $0.text, hasFan: false, variantLocked: false)
            }
            #expect(edit.takePendingLiveBlock(postID: postIDs[1], rows: rows) == target.blockID)
            #expect(edit.caretLanding(forVariant: target.variantID) == .start,
                    "a LANDING puts the caret at the landed block's start — never `.leave` (the END, her blank line)")

            let other = blocks[postIDs[2]]![0]
            edit.makeLive(
                postID: postIDs[2], blockID: other.blockID, variantID: other.variantID,
                clickOffset: 17)
            #expect(edit.caretLanding(forVariant: other.variantID) == .offset(17),
                    "a CLICK still brings its own place (18l U0)")
            #expect(edit.caretLanding(forVariant: target.variantID) == .leave,
                    "…and only for its own take")

            edit.makeLive(postID: postIDs[2], blockID: other.blockID, variantID: other.variantID)
            #expect(edit.caretLanding(forVariant: other.variantID) == .leave,
                    "a pane's own focus request arms nothing")
        }
    }

    /// **The road she walks, end to end:** Read ▸ Scroll's sentence click —
    /// exactly what `BookView`'s flow `onWake` does (request the landing,
    /// switch to Index) — on a block that carries her blank line. The live
    /// pane's caret is at the block's START, on its first line of text; never
    /// on the empty line after it. A block-less landing (a title click) lands
    /// the note's first block the same way. RED ON OLD: `caret N of N`, on the
    /// empty line (S4's measured 329 of 329, in this fixture's numbers).
    @Test func aReadClickThroughLandsTheCaretAtTheBlocksStartNotOnItsBlankLine() async throws {
        try await withStoryBook { session, db, readingID, postIDs, blocks in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .read
            structure.readForm = .flow
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: BookView(
                    session: session, readingID: readingID, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 760)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 6)

            @MainActor func land(_ target: LandingTarget, expecting minted: Minted, _ what: String) async {
                model.requestLanding(target)
                structure.mode = .index
                let identifier = "pane:\(BookIndexEditModel.columnID)|\(minted.variantID)"
                await settle(window, hosting, until: {
                    editablePanes(in: hosting).first?.identifier?.rawValue == identifier
                })
                // The caret is placed on the liveness transition's render.
                await settle(window, hosting, until: { false }, maxTurns: 6)
                guard let pane = editablePanes(in: hosting).first,
                      pane.identifier?.rawValue == identifier
                else {
                    Issue.record("\(what): the landed block went live")
                    return
                }
                let length = (pane.string as NSString).length
                let caret = pane.selectedRange().location
                print("[18l-b U4 item 2] \(what): caret \(caret) of \(length)")
                #expect(minted.text.hasSuffix("\n"), "the premise: \(what)'s block carries her blank line")
                #expect(!caretIsOnTheEmptyTail(pane), Comment(rawValue:
                    "\(what): the caret must not sit on the empty line after the block's text "
                        + "(caret \(caret) of \(length))"))
                #expect(caret == 0, Comment(rawValue:
                    "\(what): a landing puts the caret at the block's START — caret \(caret) of \(length)"))
            }

            // Read ▸ Scroll's sentence click, on a block over her blank line.
            await land(
                LandingTarget(postID: postIDs[1], blockID: blocks[postIDs[1]]![1].blockID),
                expecting: blocks[postIDs[1]]![1], "the click-through")

            // A block-less landing (a title click) — the note's first block.
            structure.mode = .read
            await settle(window, hosting, until: { editablePanes(in: hosting).isEmpty })
            await land(
                LandingTarget(postID: postIDs[2]),
                expecting: blocks[postIDs[2]]![0], "a block-less landing")
        }
    }
}
