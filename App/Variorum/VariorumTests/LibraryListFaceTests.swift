//
//  LibraryListFaceTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-113 (17y B-WALK W-1) — THE LIST'S FACE, PINNED ON
//  THE LAZY ENGINE.** Her ruling (#187(i) answered at the walk): the List's
//  notes move to the lazy column Cards uses, "wearing the List's exact face".
//  These pins hold the row geometry the shipped table drew, MEASURED off it
//  before the change (the B-WALK record's § THE W-1 FACE — the mounted rig's
//  `NSTableView` dump and its pixels, both voices):
//
//  - **pitch:** a note row is its content + 8 (the table's 4-pt row insets)
//    — 26 pt in Terminal, 30 in Study, for a row carrying chips;
//  - **separator:** 1 pt at each row's foot, from 16 pt in to 16 pt short of
//    the edge, in the system separator ink (the table's own);
//  - **the trailing stamp:** right-aligned at the row's 16-pt inset, every
//    row on one edge;
//  - **the first header floats at the very top** and its rows begin 10 pt
//    under it (the table's top inset, where the table drew it).
//
//  A parity pin, not a red-on-old one: the old engine drew these numbers; the
//  pin says the new engine draws them too.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-113 — the List's face on the lazy engine (pitch · separators · the stamp's edge)", .serialized)
struct LibraryListFaceTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(3_700) }
                return value
            }
        }
    }

    private func withLibrary<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
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

    private nonisolated static func pump(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    /// The table's measured note-row pitch, per voice (rows carrying chips).
    static func measuredPitch(_ voice: ThemeVoice) -> CGFloat {
        voice == .study ? 30 : 26
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theRowsWearTheTablesGeometry(voice: ThemeVoice) async throws {
        #if DEBUG
        try await withLibrary { session in
            let ops = session.operations
            let tag = try ops.createTag(parent: nil, name: "travel")
            for index in 0..<24 {
                let note = try ops.createPost(title: String(format: "A note named %02d", index))
                _ = try ops.newBlock(in: note.id, text: "words \(index)")
                _ = try ops.applyTag(tag.id, toPost: note.id)
            }
            try ops.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let suite = "bwalk-listface-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            model.scope = .posts
            await model.search()
            LibraryPanelOracle.reset()
            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1000, height: 640),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: .aqua)
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 640)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer { window.orderOut(nil); window.close() }
            for _ in 0..<80 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                Self.pump(0.02)
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }

            // PITCH — the content frames, in the catalog's own space.
            let frames = model.listedNoteIDs.compactMap { LibraryPanelOracle.noteRowFrames[$0] }
                .sorted { $0.minY < $1.minY }
            let region = try #require(LibraryPanelOracle.notesRegionFrame)
            let onScreen = frames.filter { $0.maxY < region.maxY - 4 }
            try #require(onScreen.count >= 8, "rows drawn (\(onScreen.count))")
            let pitch = Self.measuredPitch(voice)
            for (a, b) in zip(onScreen, onScreen.dropFirst()) {
                #expect(abs((b.minY - a.minY) - pitch) < 0.5,
                        "the table's pitch: \(pitch) pt (got \(b.minY - a.minY))")
            }
            #expect(abs(onScreen[0].height + 8 - pitch) < 0.5, "a row is its content + 8")
            #expect(abs(onScreen[0].minX - 16) < 0.5 && abs(onScreen[0].maxX - 984) < 0.5,
                    "the content sits 16 pt in on both sides")
            // The first header floats at the region's top; its first row's
            // content begins 28 (header) + 10 (the inset) + 4 under it.
            #expect(abs(onScreen[0].minY - (region.minY + 28 + 10 + 4)) < 0.5,
                    "the first row sits where the table put it (\(onScreen[0].minY) vs region \(region.minY))")

            // SEPARATORS + THE STAMP'S EDGE — the drawn pixels.
            let rep = try #require(hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds))
            hosting.cacheDisplay(in: hosting.bounds, to: rep)
            let scale = CGFloat(rep.pixelsWide) / hosting.bounds.width
            func pixel(_ x: CGFloat, _ y: CGFloat) -> NSColor? {
                rep.colorAt(x: Int(x * scale), y: Int(y * scale))?.usingColorSpace(.sRGB)
            }
            func differs(_ a: NSColor?, _ b: NSColor?) -> Bool {
                guard let a, let b else { return false }
                return abs(a.redComponent - b.redComponent) + abs(a.greenComponent - b.greenComponent)
                    + abs(a.blueComponent - b.blueComponent) > 0.03
            }
            var stampEdges: [CGFloat] = []
            for row in onScreen.prefix(8) {
                // The separator: 1 pt at the row's foot (content maxY + 4 − 1).
                let lineY = row.maxY + 4 - 0.5
                let paper = pixel(600, row.maxY + 1)
                let line = pixel(600, lineY)
                #expect(differs(line, paper), "a separator at the row's foot (y \(lineY))")
                #expect(!differs(pixel(17, lineY), line) && !differs(pixel(983, lineY), line),
                        "it runs from 16 pt in to 16 pt short of the edge")
                #expect(!differs(pixel(8, lineY), paper) && !differs(pixel(992, lineY), paper),
                        "and not into the insets")
                // The stamp's trailing ink in the row's band.
                var edge: CGFloat = 0
                var x: CGFloat = 990
                while x > 900 {
                    var ink = false
                    var y = row.minY + 2
                    while y < row.maxY - 2 {
                        if differs(pixel(x, y), paper) { ink = true; break }
                        y += 0.5
                    }
                    if ink { edge = x; break }
                    x -= 0.5
                }
                stampEdges.append(edge)
            }
            let first = try #require(stampEdges.first)
            #expect(first > 980 && first <= 984, "the stamp ends at the row's 16-pt inset (\(first))")
            #expect(stampEdges.allSatisfy { abs($0 - first) <= 0.5 },
                    "every row's stamp on ONE edge (\(stampEdges))")
        }
        #endif
    }
}
