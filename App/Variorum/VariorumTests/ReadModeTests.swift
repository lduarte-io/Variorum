//
//  ReadModeTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch C — READ's two faces (her rulings
//  R-cor-5/7): the host opens on `edit`; a click on a block in `edit` makes
//  exactly THAT block live (the one-live-editor invariant, P-3); the `read`
//  face has no live pane at all; a click on a paragraph in `read` flips to
//  `edit` at that block (row 38's note half — the ONE scrolled-open door);
//  the `pages` form renders the book's paged engine. The REAL host is
//  mounted in a real window and the clicks are REAL events (the canvas
//  rig's technique) — the gate is use, not mount (C-2), and a pin should be
//  as close to use as the harness allows.
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
@Suite("Read's two faces (the Act 10 correction round, batch C)", .serialized)
struct ReadModeTests {
    /// Every `PaneTextView` in the tree that is LIVE (editable) — the
    /// authority's invariant, read from the pixels' side.
    static func editablePanes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView, pane.isEditable { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: editablePanes(in: sub)) }
        return found
    }

    /// The app's own event pump from a non-async frame (a bare `RunLoop.run`
    /// is unavailable in async contexts; the BlockHistoryPaneTests shape).
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    static func frames(in view: NSView) -> [PageFrameNSView] {
        var found: [PageFrameNSView] = []
        if let page = view as? PageFrameNSView { found.append(page) }
        for sub in view.subviews { found.append(contentsOf: frames(in: sub)) }
        return found
    }

    @MainActor
    struct World {
        let session: AppSession
        let postID: String
        let blockIDs: [String]
        let variantIDs: [String]
        let model: BlockTOCViewModel
        let window: NSPanel
        let hosting: NSHostingView<AnyView>

        /// The app's own event pump (the canvas rig's): a bare RunLoop never
        /// DISPATCHES queued NSEvents.
        func pump(_ seconds: TimeInterval) {
            let deadline = Date().addingTimeInterval(seconds)
            while Date() < deadline {
                if let event = NSApp.nextEvent(
                    matching: .any, until: deadline, inMode: .default, dequeue: true) {
                    // A kit-/system-defined event (activation, window moves)
                    // must not be re-sent through `sendEvent` — AppKit asserts
                    // ("Invalid message sent to event", seen in this batch);
                    // dequeue it and move on.
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
        func poll(timeout: TimeInterval = 4, until condition: () -> Bool) async -> Bool {
            let deadline = Date().addingTimeInterval(timeout)
            while Date() < deadline {
                if condition() { return true }
                await turn()
            }
            return condition()
        }

        /// A frame the oracle recorded in the host's own named space (the
        /// host fills the hosting view; y-down) → its center in WINDOW
        /// coordinates. The hosting view may be flipped (it is, on this OS)
        /// — the rig's own rule.
        func windowCenter(of frame: CGRect) -> CGPoint {
            let local = hosting.isFlipped
                ? NSPoint(x: frame.midX, y: frame.midY)
                : NSPoint(x: frame.midX, y: hosting.bounds.height - frame.midY)
            return hosting.convert(local, to: nil)
        }

        /// A REAL click: down + up through `NSApp.sendEvent`, which is what
        /// sets `NSApp.currentEvent` for SwiftUI's gesture machinery.
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
            UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(postID))
        }
    }

    /// Mounts the REAL Read host in a real window over a three-block note,
    /// remembered on `face`, and waits for its rows to seed.
    private func mounted(
        face: ReadModeView.Face,
        _ body: @escaping (World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "two faces")
            var blocks: [String] = []
            var variants: [String] = []
            for text in [
                "The first block, a plain paragraph to read.",
                "The second block — the one the pins click.",
                "The third block, so a landing has somewhere further to go.",
            ] {
                let minted = try session.operations.newBlock(in: post.id, text: text)
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            ReadModeView.remember(face, postID: post.id)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            // The host registers its detail-less world: the router needs an
            // active post for the fact reports to land (the detail does this
            // in the app; here the host stands alone).
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .read) { _ in }
            let model = BlockTOCViewModel(session: session, postID: post.id)
            // The canvas rig's window shape — the one that DELIVERS pointer
            // events to a SwiftUI hosting view under the test runner.
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
            let world = World(
                session: session, postID: post.id, blockIDs: blocks, variantIDs: variants,
                model: model, window: window, hosting: hosting)
            defer { world.close() }
            await world.poll { !model.rows.isEmpty && ReadModeOracle.selectedBlockID != nil }
            try await body(world)
        }
    }

    @Test func theHostOpensOnEditWithNothingLiveAndTheRegistryHearsTheFace() async throws {
        try await mounted(face: .edit) { world in
            #expect(ReadModeOracle.face == .edit, "RULED: 'still default open to the index edit'")
            #expect(ReadModeOracle.selectedBlockID == world.blockIDs[0],
                    "no fact to enter on — the first block is current")
            #expect(ReadModeOracle.liveBlockID == nil, "nothing is live until a click")
            #expect(Self.editablePanes(in: world.hosting).isEmpty)
            #expect(world.session.commandRouter.readEditAttached,
                    "the editable face reports itself — ⌘B is honestly available here")
            #expect(CapabilityRegistry.isEnabled(
                .formatBold, in: world.session.commandRouter.currentContext()))
        }
    }

    @Test func aRealClickOnABlockInEditMakesExactlyThatBlockLiveAndASecondMigratesIt() async throws {
        try await mounted(face: .edit) { world in
            let second = world.blockIDs[1]
            let third = world.blockIDs[2]
            #expect(await world.poll { ReadModeOracle.editBlockFrames[second] != nil },
                    "the pane laid its blocks out")
            let frame = try #require(ReadModeOracle.editBlockFrames[second])
            world.click(at: world.windowCenter(of: frame))
            #expect(await world.poll { world.model.liveBlockID == second },
                    "the clicked block is THE live one")
            #expect(await world.poll { Self.editablePanes(in: world.hosting).count == 1 })
            let panes = Self.editablePanes(in: world.hosting)
            #expect(panes.count == 1, "exactly one live editor (P-3)")
            #expect(panes.first?.identifier?.rawValue == "pane:read-edit|\(world.variantIDs[1])")
            #expect(ReadModeOracle.selectedBlockID == second, "the click is the current block too")
            #expect(world.session.commandRouter.focusedBlock?.blockID == second,
                    "…and it is reported as the ONE fact (row 39)")

            // A second click migrates the ring — never a second ring.
            #expect(await world.poll { ReadModeOracle.editBlockFrames[third] != nil })
            let next = try #require(ReadModeOracle.editBlockFrames[third])
            world.click(at: world.windowCenter(of: next))
            #expect(await world.poll { world.model.liveBlockID == third })
            #expect(await world.poll {
                Self.editablePanes(in: world.hosting).map { $0.identifier?.rawValue }
                    == ["pane:read-edit|\(world.variantIDs[2])"]
            }, "the one live pane is now the third block's")
        }
    }

    @Test func theReadFaceHasNoLivePaneAndAParagraphClickLandsInEditAtThatBlock() async throws {
        try await mounted(face: .read) { world in
            #expect(ReadModeOracle.face == .read, "the per-note memory landed it on read")
            #expect(Self.editablePanes(in: world.hosting).isEmpty, "nothing editable on the page")
            #expect(!world.session.commandRouter.readEditAttached,
                    "the registry hears the read-only face — ⌘B honestly grey")
            #expect(!CapabilityRegistry.isEnabled(
                .formatBold, in: world.session.commandRouter.currentContext()))

            let third = world.blockIDs[2]
            #expect(await world.poll { ReadModeOracle.pageBlockFrames[third] != nil },
                    "the page laid its paragraphs out")
            let frame = try #require(ReadModeOracle.pageBlockFrames[third])
            world.click(at: world.windowCenter(of: frame))
            #expect(await world.poll { ReadModeOracle.face == .edit },
                    "the page turns to edit")
            #expect(await world.poll { world.model.liveBlockID == third },
                    "…with THAT block live (the scrolled-open door's promise)")
            #expect(ReadModeOracle.selectedBlockID == third)
            #expect(world.session.commandRouter.focusedBlock?.blockID == third)
            #expect(await world.poll { Self.editablePanes(in: world.hosting).count == 1 })
            #expect(world.session.commandRouter.readEditAttached)
            #expect(ReadModeView.rememberedFace(postID: world.postID) == .edit,
                    "the flip is remembered for this note")
        }
    }

    @Test func thePagesFormRendersTheBooksPagedEngineOverTheOneNote() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "leaves")
            for i in 1...6 {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: String(repeating: "Paragraph \(i) of a note long enough to page. ", count: 40))
            }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: AnyView(
                NotePagesView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let deadline = Date().addingTimeInterval(5)
            var drawn: [PageFrameNSView] = []
            while Date() < deadline {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                Self.pumpRunLoop(0.02)
                await Task.yield()
                drawn = Self.frames(in: hosting).filter { $0.visibleRange.length > 0 }
                if drawn.count >= 2 { break }
            }
            #expect(drawn.count == 2, "a spread — two leaves of the book's own engine, drawn")
            #expect(Self.editablePanes(in: hosting).isEmpty, "pages are paper, never an editor")
            // The whole note is one 'book' of one entry; the second leaf
            // continues the first (the text flows across the pages).
            if drawn.count == 2 {
                #expect(drawn[1].visibleRange.location >= drawn[0].visibleRange.upperBound)
            }
        }
    }
}
