//
//  CompareToggleIdentityTests.swift
//  VariorumTests
//
//  **VX-757 — Compare: turning a board toggle on and off flickers** (her
//  words: *"there is a flicker when you open compare and turn 'track
//  paragraphs' on and off sometimes"*; VX-770 batch 4 — the run record's
//  BATCH 4 RECORD carries the whole trace).
//
//  THE TRACED MECHANISM: the three header chips are display-only, but two of
//  them change the composition — "follow this note's order" moves every row of
//  a lineage-sharing pair between the ALIGNED and the FREE arm, and "related
//  blocks only" changes the peer side of a free stretch. The board keyed a
//  row by its kind and running index (`CompareRow.id`) and drew the two kinds
//  through two different view structures, so each such toggle tore down and
//  re-made every affected row — every cell's pane included. A made pane is
//  born at a 24-pt seed and measured before it has width; its real height
//  lands a turn later. A whole board of panes re-made at once re-lays from
//  wrong heights to right ones: the flicker. On a same-order pair the toggle
//  changes nothing she can see, so all of it is a rebuild of an identical
//  board. "Sometimes": only lineage-sharing pairs rebuild — a pair with no
//  lineage composes the same rows in both arms.
//
//  THE PINS read the mechanism's state transition — whether the toggle
//  re-made a pane (`PaneTextView` object identity, by its identifier
//  `pane:compare|<variant>`) — never a paint. Each also PRINTS the panes'
//  heights against their measurements, turn by turn after the toggle
//  (`VX757-TRACE`), so the window's red run records whether a wrong-height
//  turn is observable in the harness. The walk (W15) is the eye.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

#if DEBUG

// MARK: - The rig

@MainActor
private func pump(_ seconds: TimeInterval = 0.03) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func turn(_ window: NSWindow, _ hosting: NSView) async {
    hosting.layoutSubtreeIfNeeded()
    window.layoutIfNeeded()
    window.displayIfNeeded()
    pump()
    await Task.yield()
    try? await Task.sleep(for: .milliseconds(20))
}

@MainActor
private func settle(
    _ window: NSWindow, _ hosting: NSView,
    until predicate: () -> Bool, maxTurns: Int = 60
) async {
    for _ in 0..<maxTurns {
        await turn(window, hosting)
        if predicate() { return }
    }
}

@MainActor
private func comparePanes(in view: NSView) -> [PaneTextView] {
    var found: [PaneTextView] = []
    if let pane = view as? PaneTextView,
       pane.identifier?.rawValue.hasPrefix("pane:compare|") == true {
        found.append(pane)
    }
    for sub in view.subviews { found.append(contentsOf: comparePanes(in: sub)) }
    return found
}

/// Every Compare pane on the board, by its identifier (its take), as the
/// OBJECT that draws it.
@MainActor
private func paneObjects(in view: NSView) -> [String: ObjectIdentifier] {
    var map: [String: ObjectIdentifier] = [:]
    for pane in comparePanes(in: view) {
        if let id = pane.identifier?.rawValue { map[id] = ObjectIdentifier(pane) }
    }
    return map
}

/// The panes present on both sides whose drawing object changed — the
/// panes the toggle RE-MADE.
private func remade(
    _ before: [String: ObjectIdentifier], _ after: [String: ObjectIdentifier]
) -> [String] {
    before.keys.filter { key in after[key].map { $0 != before[key] } ?? false }.sorted()
}

@MainActor
private func makeWindow(width: CGFloat, height: CGFloat) -> NSWindow {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: width, height: height),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    return window
}

@MainActor
private struct ToggleWorld {
    let session: AppSession
    let db: AppDatabase
    let anchor: String
    let peer: String
    /// Every take the board shows once mounted (anchor + peer), by variant.
    let shownVariants: [String]
}

@MainActor
private func withToggleWorld(
    _ build: @MainActor (Operations) throws -> (anchor: String, peer: String),
    _ body: @MainActor (ToggleWorld) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 757))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let pair = try build(session.operations)
        let ids = [pair.anchor, pair.peer]
        let variants = try await db.read { db in
            try ids.flatMap { id in
                try Queries.renderPost(db, containerID: id).compactMap(\.variantID)
            }
        }
        try await body(ToggleWorld(
            session: session, db: db, anchor: pair.anchor, peer: pair.peer,
            shownVariants: variants))
    }
}

/// The paragraphs every world's notes are written in: a mix of one- and
/// two-line blocks, so a re-made pane's wrong first height differs from its
/// measured one.
nonisolated private let paragraphs = [
    "The opening paragraph sets the scene, and it runs long enough at a Compare column's measure that it wraps onto a second line.",
    "A short second block.",
    "The third paragraph carries the argument; it too is long enough to wrap at the column's width, which is the point of it here.",
    "Fourth, brief.",
    "The fifth paragraph turns the argument over and looks at its underside, at some length, so that it also wraps.",
    "The last block.",
]

/// A six-block draft and its duplicate-as-version twin: the same blocks in
/// the same order, every one kin — the pair whose two "follow" arms pair
/// every block identically.
@MainActor
private func sameOrderPair(_ ops: Operations) throws -> (anchor: String, peer: String) {
    let anchor = try ops.createPost(title: "the draft")
    for text in paragraphs { _ = try ops.newBlock(in: anchor.id, text: text, at: .end) }
    let twin = try ops.duplicateAsVersion(anchor.id)
    return (anchor.id, twin.post.id)
}

@MainActor
private func mount(
    _ model: CompareViewModel, _ world: ToggleWorld
) -> (NSWindow, NSView) {
    let window = makeWindow(width: 1100, height: 760)
    let hosting = NSHostingView(
        rootView: CompareBoardView(session: world.session, postID: world.anchor, model: model)
            .environment(ThemeStore(session: world.session)))
    hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 760)
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    return (window, hosting)
}

@MainActor
private func adoptFresh(_ model: CompareViewModel, _ world: ToggleWorld) async throws {
    let peers = model.peerSlots.compactMap(\.postID)
    model.adopt(try await world.db.read { [anchor = world.anchor] db in
        try CompareViewModel.read(db, anchor: anchor, peers: peers)
    })
}

/// A board with `world.peer` in its one peer column, mounted and settled until
/// every take in `expecting` has its pane.
@MainActor
private func mountedBoard(
    _ world: ToggleWorld, expecting: [String], configure: (CompareViewModel) -> Void = { _ in }
) async throws -> (CompareViewModel, NSWindow, NSView) {
    let model = CompareViewModel(session: world.session, anchorPostID: world.anchor)
    model.setPeer(slotID: model.peerSlots[0].id, postID: world.peer)
    configure(model)
    try await adoptFresh(model, world)
    let (window, hosting) = mount(model, world)
    let wanted = Set(expecting.map { "pane:compare|\($0)" })
    await settle(window, hosting, until: { wanted.isSubset(of: Set(paneObjects(in: hosting).keys)) })
    await settle(window, hosting, until: { false }, maxTurns: 6)
    return (model, window, hosting)
}

/// Flip a toggle and watch: per turn, how many panes are new objects and how
/// many render a height off their own measurement — printed, never asserted
/// (the window's red run reads it). Returns the board's panes once settled.
@MainActor
private func flip(
    _ label: String, _ window: NSWindow, _ hosting: NSView,
    from before: [String: ObjectIdentifier], expecting: [String],
    _ act: () -> Void
) async -> [String: ObjectIdentifier] {
    act()
    for turnIndex in 0..<6 {
        if turnIndex == 0 {
            hosting.layoutSubtreeIfNeeded()  // the toggle's own first layout
        } else {
            await turn(window, hosting)
        }
        let panes = comparePanes(in: hosting)
        let now = Dictionary(
            panes.compactMap { pane in pane.identifier.map { ($0.rawValue, ObjectIdentifier(pane)) } },
            uniquingKeysWith: { first, _ in first })
        let heights = panes.map(\.bounds.height)
        let diverged = panes.filter {
            abs($0.bounds.height - max(PaneMeasurement.height(of: $0), 24)) > PanePublisher.convergenceSlack
        }.count
        print("VX757-TRACE \(label) turn=\(turnIndex) panes=\(panes.count) "
            + "remade=\(remade(before, now).count) diverged=\(diverged) "
            + "heights=\(Int(heights.min() ?? 0))…\(Int(heights.max() ?? 0))")
    }
    let wanted = Set(expecting.map { "pane:compare|\($0)" })
    await settle(window, hosting, until: { wanted.isSubset(of: Set(paneObjects(in: hosting).keys)) })
    await settle(window, hosting, until: { false }, maxTurns: 4)
    return paneObjects(in: hosting)
}

private func isAligned(_ row: CompareRow) -> Bool {
    if case .aligned = row { return true }
    return false
}

// MARK: - The pins

@MainActor
@Suite("VX-757 — a Compare toggle re-makes no pane that stays put", .serialized)
struct CompareToggleIdentityTests {
    /// **RED ON OLD — her toggle, her likely pair.** "follow this note's order"
    /// on a same-order twin: OFF moves every row from the aligned arm to the
    /// free arm and back ON — the same blocks side by side either way. The
    /// board must keep every pane it is showing; the old board re-made all of
    /// them, each time.
    @Test func followingTheNotesOrderOffAndOnRemakesNoPaneOnASameOrderPair() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withToggleWorld(sameOrderPair) { world in
            let (model, window, hosting) = try await mountedBoard(world, expecting: world.shownVariants)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            let mounted = paneObjects(in: hosting)
            try #require(mounted.count == world.shownVariants.count,
                         "fixture: every take of both notes has its pane (\(mounted.count) of \(world.shownVariants.count))")
            try #require(model.rows.allSatisfy(isAligned),
                         "premise: following the note's order, every row of the twin pair is aligned")

            let off = await flip("follow=off", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.followAnchorOrder = false
            }
            try #require(!model.rows.contains(where: isAligned),
                         "premise: OFF, every row flows free — the toggle moved the rows to the other arm")
            #expect(remade(mounted, off).isEmpty,
                    "turning it OFF re-made no pane (re-made \(remade(mounted, off).count) of \(mounted.count))")
            #expect(Set(off.keys) == Set(mounted.keys), "the same takes stay on the board")

            let on = await flip("follow=on", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.followAnchorOrder = true
            }
            #expect(remade(mounted, on).isEmpty,
                    "turning it back ON re-made no pane (re-made \(remade(mounted, on).count) of \(mounted.count))")
        }
    }

    /// **RED ON OLD.** "related blocks only" on a pair whose tails differ: the
    /// anchor's last block `b` has no kin, the twin's last block `x` has none.
    /// ON hides `x`; OFF shows it beside `b`. The panes that stay on the board —
    /// `b`'s among them — must stay the same panes; the old board re-made `b`'s
    /// (its row's id carried the peer side it changed).
    @Test func relatedBlocksOnlyOffAndOnKeepsThePanesThatStay() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        let bText = "An unrelated closing paragraph only the draft has, long enough to wrap at a Compare column's measure."
        let xText = "A closing paragraph only the twin has."
        try await withToggleWorld({ ops in
            let anchor = try ops.createPost(title: "the draft")
            for text in paragraphs.prefix(3) { _ = try ops.newBlock(in: anchor.id, text: text, at: .end) }
            let twin = try ops.duplicateAsVersion(anchor.id)
            _ = try ops.newBlock(in: anchor.id, text: bText, at: .end)
            _ = try ops.newBlock(in: twin.post.id, text: xText, at: .end)
            return (anchor.id, twin.post.id)
        }) { world in
            let peerID = world.peer
            let anchorID = world.anchor
            let x = try #require(try await world.db.read { db in
                try Queries.renderPost(db, containerID: peerID).last?.variantID
            })
            let b = try #require(try await world.db.read { db in
                try Queries.renderPost(db, containerID: anchorID).last?.variantID
            })
            let filtered = world.shownVariants.filter { $0 != x }
            let (model, window, hosting) = try await mountedBoard(world, expecting: filtered)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            #expect(model.relatedOnly, "fixture: the filter's default is ON")
            let mounted = paneObjects(in: hosting)
            try #require(mounted["pane:compare|\(b)"] != nil, "fixture: the draft's unrelated tail shows")
            try #require(mounted["pane:compare|\(x)"] == nil, "fixture: the twin's unrelated tail is filtered away")
            let rowsBefore = model.rows.map(\.id)

            let off = await flip("related=off", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.relatedOnly = false
            }
            try #require(off["pane:compare|\(x)"] != nil, "premise: OFF shows the twin's tail")
            try #require(model.rows.map(\.id) != rowsBefore,
                         "premise: the toggle changed the composition's rows")
            #expect(remade(mounted, off).isEmpty,
                    "turning it OFF re-made no pane that stayed (re-made: \(remade(mounted, off)))")

            let on = await flip("related=on", window, hosting, from: mounted, expecting: filtered) {
                model.relatedOnly = true
            }
            #expect(on["pane:compare|\(x)"] == nil, "ON hides the twin's tail again")
            #expect(remade(mounted, on).isEmpty,
                    "turning it back ON re-made no pane that stayed (re-made: \(remade(mounted, on)))")
        }
    }

    /// GUARD (green on both trees — the trace's inert arm): "lineage colors"
    /// changes only the rails, never a row, so it never re-made a pane.
    @Test func lineageColorsOffAndOnRemakesNoPane() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withToggleWorld(sameOrderPair) { world in
            let (model, window, hosting) = try await mountedBoard(world, expecting: world.shownVariants)
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            let mounted = paneObjects(in: hosting)
            let off = await flip("colors=off", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.lineageColorsOn = false
            }
            #expect(remade(mounted, off).isEmpty, "re-made: \(remade(mounted, off))")
            let on = await flip("colors=on", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.lineageColorsOn = true
            }
            #expect(remade(mounted, on).isEmpty, "re-made: \(remade(mounted, on))")
        }
    }

    /// GUARD (green on both trees — her "sometimes"): a pair with NO lineage
    /// composes the same free rows in both "follow" arms, so the toggle was
    /// always inert there. Filter off so both notes show whole.
    @Test func aPairWithNoLineageIsInertUnderTheOrderToggle() async throws {
        await HostLaunchSettle.wait()
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
        try await withToggleWorld({ ops in
            let anchor = try ops.createPost(title: "the draft")
            for text in paragraphs.prefix(4) { _ = try ops.newBlock(in: anchor.id, text: text, at: .end) }
            let stranger = try ops.createPost(title: "unrelated")
            for text in paragraphs.suffix(3) { _ = try ops.newBlock(in: stranger.id, text: text, at: .end) }
            return (anchor.id, stranger.id)
        }) { world in
            let (model, window, hosting) = try await mountedBoard(
                world, expecting: world.shownVariants, configure: { $0.relatedOnly = false })
            defer {
                model.teardown()
                window.orderOut(nil)
                window.close()
            }
            let mounted = paneObjects(in: hosting)
            let rowsBefore = model.rows.map(\.id)
            let off = await flip("stranger follow=off", window, hosting, from: mounted, expecting: world.shownVariants) {
                model.followAnchorOrder = false
            }
            #expect(model.rows.map(\.id) == rowsBefore,
                    "the trace's reason: no lineage, the same rows in both arms")
            #expect(remade(mounted, off).isEmpty, "re-made: \(remade(mounted, off))")
        }
    }
}

#endif
