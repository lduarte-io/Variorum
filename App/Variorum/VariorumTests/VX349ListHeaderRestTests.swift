//
//  VX349ListHeaderRestTests.swift
//  VariorumTests (Mac)
//
//  **VX-349 (the VX-348 run, U3) — the List's first header draws ONE line at
//  rest.** Her report (2026-10-14): under the Library List's "Notes" header
//  the rule read doubled and extra-thick when the list was at rest; while
//  scrolling, one line.
//
//  THE MECHANISM (traced — `LibraryListFace.swift`): a header's `pinned` is
//  "its top sits at the scroll view's top" (`frame(in: .scrollView).minY <=
//  0.5`), and the FIRST header's natural place IS the top — so at rest, with
//  nothing scrolled under it, it drew the FLOATING face. In light that face
//  lays the material's darker inset hairline over the resting separator AND a
//  full-width shadow line one point BELOW the header — on the empty 10-pt
//  lead, two adjacent lines: the doubled, thick rule. (An offscreen replica
//  of the face measured it: the separator row at the foot, the full-width
//  line at foot + 1; a pull past the top moves the header below the top,
//  un-pins it, and leaves the separator alone — one line.)
//
//  THE FIX: the floating face needs content UNDER the header — the list
//  scrolled (`LibraryListScrollReader` on the host's scroll view). At rest
//  the first header is the resting header, as every header mid-list is.
//
//  THE PIN, RED ON OLD BY BEHAVIOUR (pre-fix APIs only — the mounted catalog
//  and its pixels, `LibraryListFaceTests`' road): at rest, light, both voices,
//  the first header's foot carries the separator and NOTHING one point below
//  it, and the separator stops 16 pt in (it is the resting one). Before: the
//  full-width shadow line under it. Scrolled, the floating face is still
//  drawn (its full-width shadow line) — a GUARD, green on both sides. Dark at
//  rest: one line (a guard — VX-20's dark face already drew one).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-349 — the List's first header draws one line at rest", .serialized)
struct VX349ListHeaderRestTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The notes list's own scroll view — the one whose document is taller
    /// than its frame (the panel and the field's scroll views are not).
    private static func listScrollView(in view: NSView) -> NSScrollView? {
        var best: NSScrollView?
        func walk(_ view: NSView) {
            if let scroll = view as? NSScrollView,
               let document = scroll.documentView,
               document.frame.height > scroll.frame.height + 50,
               scroll.frame.width > 400 {
                best = scroll
            }
            for sub in view.subviews { walk(sub) }
        }
        walk(view)
        return best
    }

    /// The mounted catalog's pixels, read as `LibraryListFaceTests` reads them.
    @MainActor
    private struct Pixels {
        let rep: NSBitmapImageRep
        let scale: CGFloat

        init(_ hosting: NSView) throws {
            let rep = try #require(hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds))
            hosting.cacheDisplay(in: hosting.bounds, to: rep)
            self.rep = rep
            self.scale = CGFloat(rep.pixelsWide) / hosting.bounds.width
        }

        func at(_ x: CGFloat, _ y: CGFloat) -> NSColor? {
            rep.colorAt(x: Int(x * scale), y: Int(y * scale))?.usingColorSpace(.sRGB)
        }

        static func differs(_ a: NSColor?, _ b: NSColor?) -> Bool {
            guard let a, let b else { return false }
            return abs(a.redComponent - b.redComponent) + abs(a.greenComponent - b.greenComponent)
                + abs(a.blueComponent - b.blueComponent) > 0.03
        }

        static func text(_ color: NSColor?) -> String {
            guard let color else { return "nil" }
            return String(format: "%.3f,%.3f,%.3f", color.redComponent, color.greenComponent, color.blueComponent)
        }
    }

    @Test(arguments: [(ThemeVoice.terminal, false), (.study, false), (.terminal, true), (.study, true)])
    func atRestTheFirstHeaderDrawsOneLine(voice: ThemeVoice, dark: Bool) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx349-header-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 349))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Notes only (no books): the "Notes" header is the List's first.
            for index in 0..<40 {
                let note = try session.operations.createPost(title: String(format: "A note named %02d", index))
                _ = try session.operations.newBlock(in: note.id, text: "words \(index)")
            }
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            await model.search()
            LibraryPanelOracle.reset()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1000, height: 640),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 640)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await Self.settle(window, hosting, 1.5)
            let face = "\(voice) \(dark ? "dark" : "light")"

            // AT REST — the first header's foot.
            let region = try #require(LibraryPanelOracle.notesRegionFrame, "\(face): the notes list reported")
            let foot = region.minY + LibraryListFace.headerHeight
            let rest = try Pixels(hosting)
            let paper = rest.at(600, foot + 5)             // the empty lead below the header
            let line = rest.at(600, foot - 0.5)            // the header's own rule
            let under = rest.at(600, foot + 0.5)           // one point below it
            let edgeLine = rest.at(8, foot - 0.5)          // the rule's row, inside the 16-pt inset
            let edgeUnder = rest.at(8, foot + 0.5)
            print("[VX-349 rest] \(face) · foot \(foot) · paper \(Pixels.text(paper)) · line \(Pixels.text(line)) · under \(Pixels.text(under)) · edge \(Pixels.text(edgeLine)) / \(Pixels.text(edgeUnder))")
            #expect(Pixels.differs(line, paper), "\(face): the header's rule is drawn at its foot (y \(foot - 0.5))")
            #expect(!Pixels.differs(under, paper),
                    "\(face): at rest a SECOND line lies one point under the header's rule — the doubled, thick line (\(Pixels.text(under)) on \(Pixels.text(paper)))")
            #expect(!Pixels.differs(edgeUnder, paper) && !Pixels.differs(edgeLine, paper),
                    "\(face): at rest the rule is the resting separator, 16 pt in — nothing runs edge to edge (\(Pixels.text(edgeLine)) / \(Pixels.text(edgeUnder)))")

            // SCROLLED — content under the header: the floating face (GUARD).
            let scroll = try #require(Self.listScrollView(in: hosting), "\(face): the notes list's scroll view")
            scroll.contentView.scroll(to: NSPoint(x: 0, y: 120))
            scroll.reflectScrolledClipView(scroll.contentView)
            await Self.settle(window, hosting, 0.8)
            let scrolled = try Pixels(hosting)
            let floatingUnder = scrolled.at(8, foot + 0.5)
            let roomEdge = scrolled.at(8, foot + 12)
            print("[VX-349 scrolled] \(face) · under-edge \(Pixels.text(floatingUnder)) · below \(Pixels.text(roomEdge)) · offset \(scroll.contentView.bounds.origin.y)")
            if !dark {
                #expect(Pixels.differs(floatingUnder, roomEdge),
                        "\(face): scrolled, the header floats — its full-width shadow line under it (\(Pixels.text(floatingUnder)))")
            }
        }
        #endif
    }
}
