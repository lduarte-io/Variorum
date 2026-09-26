//
//  InlineEditorWidthReflowTests.swift
//  VariorumTests
//
//  **18l UNIT U0, item 2 — her report (2026-09-25), verbatim:** *"the bottom
//  line of text in Read view is very slightly cut off at the bottom - in this
//  image, it's clear that the G's in the final line of text in book view with
//  a note extended are slightly cut off towards the bottom."* (Her capture:
//  `notes/plans/18l-inputs/2026-09-25-book-last-line-descenders-clipped.png` —
//  the book Outline, *About this book* expanded and LIVE, the caret in its
//  last paragraph, "tagged" cut through its descenders — and the paragraph's
//  last two lines, which the seeded text carries, not drawn at all.)
//
//  **The mechanism, measured (the U0 record's ITEM 2 trace).** The Outline's
//  live note is `InlineEditorSurface`: a bare, content-sized TK2 view whose
//  frame height is whatever its coordinator last REPORTED. It re-measured on
//  exactly two triggers — a storage edit and a SwiftUI update pass — and a
//  WIDTH change is neither: SwiftUI lays the new width out AFTER the update
//  pass it runs for the resize (traced: the one `updateNSView` of a 1200→820
//  narrowing saw the view at an intermediate 902 pt, measured the OLD wrap,
//  and the final 629-pt frame arrived in layout with nothing left to
//  re-measure). The text re-wraps into more lines inside a frame sized for
//  fewer: the last line is cut through — her descenders — and anything below
//  it is not drawn. Widening does the mirror (a frame taller than its text).
//  Both sides of 18k C2's deferral measured identically (C2 moved WHEN a
//  report is made, never WHAT triggers one).
//
//  **The pin:** the real Outline, the seeded note focused and live, the window
//  narrowed and widened — after each settle the editor's FRAME must be the
//  height of the text it now holds, in both voices.
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
@Suite("18l U0 — the Outline's live note keeps its height across a width change", .serialized)
struct InlineEditorWidthReflowTests {
    private func pump(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The editor holding the note's text (the Outline mounts one).
    private func editor(in view: NSView) -> EditorTextView? {
        var found: [EditorTextView] = []
        func walk(_ v: NSView) {
            if let e = v as? EditorTextView { found.append(e) }
            for s in v.subviews { walk(s) }
        }
        walk(view)
        return found.max(by: { $0.string.count < $1.string.count })
    }

    /// A window resize the way a drag of its edge delivers one: the window's
    /// frame set and displayed in one call.
    private func resize(_ window: NSWindow, _ hosting: NSView, width: CGFloat) {
        let height = hosting.frame.height
        var frame = window.frame
        frame.size = window.frameRect(forContentRect: NSRect(
            x: 0, y: 0, width: width, height: height)).size
        window.setFrame(frame, display: true)
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
    }

    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func theLiveNoteIsAsTallAsItsTextAfterTheWindowNarrowsAndWidens(_ voice: ThemeVoice) async throws {
        let db = try AppDatabase.inMemory()
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            try await Self.run(voice: voice, db: db, harness: self)
        }
    }

    /// The case's body — a function of its own (the region-isolation pass
    /// crashes on it as one inline closure, as it did on the Index pin's).
    private static func run(
        voice: ThemeVoice, db: AppDatabase, harness: InlineEditorWidthReflowTests
    ) async throws {
        let session = AppSession(database: db)
        try session.operations.setThemeVoice(voice)
        let theme = ThemeStore(session: session)
        let started = Task { await theme.start() }
        defer { started.cancel() }
        for _ in 0..<200 where !(theme.settings.voice == voice && EditorTypography.isAdopted) {
            try? await Task.sleep(for: .milliseconds(10))
        }
        // Her note, as the sample library stores it: the front matter, one
        // block per paragraph, the blank line between them kept as content.
        let reading = try session.operations.createReading(name: "sherlock", kind: .curated)
        let about = try session.operations.createPost(title: SampleLibrarySeeder.frontMatterTitle)
        let paragraphs = SampleLibrarySeeder.attributionText.components(separatedBy: "\n\n")
        for (i, paragraph) in paragraphs.enumerated() {
            _ = try session.operations.newBlock(
                in: about.id, text: i < paragraphs.count - 1 ? paragraph + "\n" : paragraph)
        }
        try session.operations.addPostToReading(about.id, to: reading.id)
        for n in 0..<3 {
            let post = try session.operations.createPost(title: "story \(n)")
            _ = try session.operations.newBlock(in: post.id, text: "A short story body \(n).")
            try session.operations.addPostToReading(post.id, to: reading.id)
        }
        let readingID = reading.id
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { try Queries.reading($0, id: readingID) },
            sections: [], deletedSections: [], assignments: [:]))
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            BookView(session: session, readingID: readingID, model: model, structure: structure)
                .environment(theme)))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        defer {
            window.orderOut(nil)
            window.close()
        }
        await harness.settle(window, hosting, turns: 10)
        model.focus(about.id)
        for _ in 0..<60 where (harness.editor(in: hosting)?.string.count ?? 0) < 100 {
            await harness.settle(window, hosting, turns: 1)
        }
        await harness.settle(window, hosting, turns: 20)

        // Three widths, each settled: the start, much narrower (the text
        // re-wraps into MORE lines), and back (fewer again).
        for (step, width) in [("mounted", 1200.0), ("narrowed", 820.0), ("narrowed more", 700.0), ("widened", 1200.0)] {
            if step != "mounted" { harness.resize(window, hosting, width: width) }
            await harness.settle(window, hosting, turns: 30)
            let live = try #require(harness.editor(in: hosting), "the note is live")
            let text = PaneMeasurement.height(of: live)
            print("[18l U0 item 2] \(voice) · \(step): frame \(live.frame.height) · text \(text) · width \(live.frame.width)")
            #expect(live.frame.height >= text - 0.5, Comment(rawValue:
                "\(voice) · \(step): the frame (\(live.frame.height) pt) is SHORTER than the text it "
                    + "holds (\(text) pt) — the last line is cut through"))
            #expect(live.frame.height <= text + 0.5, Comment(rawValue:
                "\(voice) · \(step): the frame (\(live.frame.height) pt) is TALLER than the text it "
                    + "holds (\(text) pt) — a gap under the last line"))
        }
    }
}
