//
//  BlocksWorkbenchFaceTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch C — the Blocks workbench's face:
//  row 25 (the selection lag — MEASURED, with a stated budget), row 18 (the
//  draggable, remembered divider), the list-first render (the rows before
//  the facts). The two MECHANISMS are mounted alone in a real window and
//  driven by REAL events (the canvas rig's technique): the row shell's tap
//  and the seam's drag. (The whole workbench was mounted first: its context
//  panel's `PaneTextView`, added under the rig's event pump, tripped the
//  Swift runtime's executor check in `viewDidMoveToWindow` three runs in a
//  row — the mechanism pins isolate what the rows are about from that.)
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
@Suite("The Blocks workbench's face (the Act 10 correction round, batch C)", .serialized)
struct BlocksWorkbenchFaceTests {
    /// Row 25's budget: a click is SELECTED within this. The old shell held
    /// every single click for the double-click interval (0.5 s on her Mac),
    /// so the pin is RED on old by a third of a second at least; the fixed
    /// shell acts in the same event cycle.
    static let selectionBudget: TimeInterval = 0.15

    private static func row(_ i: Int) -> Queries.TOCRow {
        Queries.TOCRow(
            blockID: "b\(i)", placementID: "p\(i)", name: nil, variantID: "v\(i)",
            text: "block \(i) text", hasFan: i == 2, variantLocked: i == 3)
    }

    private static func facts(_ i: Int, words: Int, edited: String, tags: [String] = []) -> Queries.WorkbenchRow {
        Queries.WorkbenchRow(
            blockID: "b\(i)", placementID: "p\(i)", name: nil, variantID: "v\(i)",
            text: "block \(i) text", activeVariantCount: i == 2 ? 2 : 1,
            liveVariantCount: i == 2 ? 2 : 1, commentCount: i == 1 ? 1 : 0,
            variantLocked: i == 3, wordCount: words, editedAt: edited, tagPaths: tags)
    }

    @Test func theListRendersFromTheRowsBeforeTheFactsArriveAndTheFactsLandOntoThem() {
        let rows = (1...3).map(Self.row)
        // No facts yet: every row shows, in note order, facts nil.
        let early = WorkbenchRows.display(rows: rows, facts: [], filter: "", show: .all, sort: .noteOrder)
        #expect(early.map(\.row.blockID) == ["b1", "b2", "b3"])
        #expect(early.allSatisfy { $0.facts == nil })
        #expect(early.map(\.ordinal) == [1, 2, 3])
        // A fact-SORT waits honestly for the facts (note order meanwhile)…
        let sortedEarly = WorkbenchRows.display(rows: rows, facts: [], filter: "", show: .all, sort: .longest)
        #expect(sortedEarly.map(\.row.blockID) == ["b1", "b2", "b3"])
        // …and a fact-FILTER admits nothing until they land; the TOC row's
        // own facts (takes, lock) answer at once.
        #expect(WorkbenchRows.display(rows: rows, facts: [], filter: "", show: .tagged, sort: .noteOrder).isEmpty)
        #expect(WorkbenchRows.display(rows: rows, facts: [], filter: "", show: .withTakes, sort: .noteOrder)
                .map(\.row.blockID) == ["b2"])
        #expect(WorkbenchRows.display(rows: rows, facts: [], filter: "", show: .locked, sort: .noteOrder)
                .map(\.row.blockID) == ["b3"])
        // The facts land onto the rows: sort, tag filter and word counts wake.
        let facts = [
            Self.facts(1, words: 10, edited: "2026-08-01"),
            Self.facts(2, words: 30, edited: "2026-08-03", tags: ["voice"]),
            Self.facts(3, words: 20, edited: "2026-08-02"),
        ]
        let late = WorkbenchRows.display(rows: rows, facts: facts, filter: "", show: .all, sort: .longest)
        #expect(late.map(\.row.blockID) == ["b2", "b3", "b1"])
        #expect(late.first?.facts?.wordCount == 30)
        #expect(WorkbenchRows.display(rows: rows, facts: facts, filter: "voice", show: .all, sort: .noteOrder)
                .map(\.row.blockID) == ["b2"])
        #expect(WorkbenchRows.display(rows: rows, facts: facts, filter: "", show: .withComments, sort: .noteOrder)
                .map(\.row.blockID) == ["b1"])
        // The ordinal is the NOTE ordinal whatever the sort.
        #expect(late.map(\.ordinal) == [2, 3, 1])
    }

    @Test func theDividerWidthIsClampedSoNeitherSideCanBeSwallowed() {
        // A comfortable window: the panel stays inside its band.
        #expect(BlocksWorkbenchLayout.panelWidth(proposed: 320, total: 1200) == 320)
        #expect(BlocksWorkbenchLayout.panelWidth(proposed: 100, total: 1200) == 260)
        #expect(BlocksWorkbenchLayout.panelWidth(proposed: 900, total: 1200) == 640)
        // A narrow one: the list keeps its 320 — the panel gives way…
        #expect(BlocksWorkbenchLayout.panelWidth(proposed: 500, total: 700) == 380)
        // …down to its own floor, never below.
        #expect(BlocksWorkbenchLayout.panelWidth(proposed: 500, total: 400) == 260)
    }

    // MARK: - The rig (the canvas rig's window + event pump)

    @MainActor
    final class Rig {
        let window: NSPanel
        let hosting: NSHostingView<AnyView>

        init<V: View>(_ view: V, width: CGFloat = 900, height: CGFloat = 400) {
            window = NSPanel(
                contentRect: NSRect(x: 120, y: 120, width: width, height: height),
                styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isFloatingPanel = true
            window.becomesKeyOnlyIfNeeded = false
            window.hidesOnDeactivate = false
            hosting = NSHostingView(rootView: AnyView(view))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
        }

        /// The app's own event pump: SwiftUI's gestures conclude only under
        /// `NSApp.nextEvent` dispatch (a bare `RunLoop.run` left a tap
        /// un-fired for seconds — measured in this batch).
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

        /// A point in the hosting view's y-down space → WINDOW coordinates.
        func windowPoint(_ point: CGPoint) -> CGPoint {
            let local = hosting.isFlipped
                ? NSPoint(x: point.x, y: point.y)
                : NSPoint(x: point.x, y: hosting.bounds.height - point.y)
            return hosting.convert(local, to: nil)
        }

        func send(_ type: NSEvent.EventType, at point: CGPoint, clickCount: Int = 1) {
            guard let event = NSEvent.mouseEvent(
                with: type, location: point, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil,
                eventNumber: 1, clickCount: clickCount,
                pressure: type == .leftMouseUp ? 0 : 1)
            else { return }
            NSApp.sendEvent(event)
        }

        func close() {
            window.orderOut(nil)
            window.close()
        }
    }

    /// The row shell's clicks, recorded.
    @MainActor
    final class Clicks {
        var singles: [EventModifiers] = []
        var doubles = 0
    }

    @Test func aSingleClickOnARowActsWithinTheBudgetAndADoubleStillOpens() async throws {
        let clicks = Clicks()
        let tokens = VoiceTokens.fallback(for: .light)
        let rig = Rig(
            VStack(spacing: 0) {
                WorkbenchRowShell(
                    tokens: tokens, picked: false, focused: false, whisper: false,
                    onClick: { clicks.singles.append($0) },
                    onDoubleClick: { clicks.doubles += 1 }
                ) {
                    Text("01  a block as an object — click me")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 60)
                Spacer()
            }
            .padding(20))
        defer { rig.close() }
        await rig.poll(timeout: 2) { false }  // let it lay out
        let point = rig.windowPoint(CGPoint(x: 300, y: 50))

        rig.send(.leftMouseDown, at: point)
        rig.pump(0.005)
        let clock = ContinuousClock()
        let start = clock.now
        rig.send(.leftMouseUp, at: point)
        let acted = await rig.poll(timeout: 2) { !clicks.singles.isEmpty }
        let elapsed = clock.now - start
        print("[batch-c row 25] click → acted in \(elapsed) (budget \(Self.selectionBudget) s; the old two-gesture shell waited the \(NSEvent.doubleClickInterval) s double-click interval)")
        #expect(acted, "the click acted at all")
        #expect(elapsed < .seconds(Self.selectionBudget),
                "a single click acts at once — never after the double-click interval")
        #expect(clicks.singles == [[]], "one plain click, no chord")
        #expect(clicks.doubles == 0)

        // A DOUBLE click — a second click inside the system's interval —
        // still opens in Write, once; the first click's selection stands.
        rig.send(.leftMouseDown, at: point, clickCount: 2)
        rig.pump(0.005)
        rig.send(.leftMouseUp, at: point, clickCount: 2)
        #expect(await rig.poll(timeout: 2) { clicks.doubles == 1 }, "double-click opens, once")
        #expect(clicks.singles.count == 1, "the double's second click is not a second selection")
        // A click well after the interval is a plain click again.
        try? await Task.sleep(for: .seconds(NSEvent.doubleClickInterval + 0.1))
        rig.send(.leftMouseDown, at: point)
        rig.pump(0.005)
        rig.send(.leftMouseUp, at: point)
        #expect(await rig.poll(timeout: 2) { clicks.singles.count == 2 }, "a later click selects again")
        #expect(clicks.doubles == 1)
    }

    /// The seam's host — the workbench's own remembered width, bound the
    /// same way (`@AppStorage` under the same key).
    private struct SeamHost: View {
        static let space = "seam-pin"
        @AppStorage(BlocksWorkbenchView.panelWidthKey) private var panelWidth: Double
            = BlocksWorkbenchLayout.defaultPanelWidth
        let total: CGFloat

        var body: some View {
            HStack(spacing: 0) {
                Color.clear
                WorkbenchSeam(
                    tokens: .fallback(for: .light), spaceName: Self.space,
                    totalWidth: total, panelWidth: $panelWidth)
                Color.clear
                    .frame(width: BlocksWorkbenchLayout.panelWidth(
                        proposed: panelWidth, total: Double(total)))
            }
            .frame(width: total, height: 300)
            .coordinateSpace(name: Self.space)
        }
    }

    @Test func theSeamDragsThePanelWidthAndItIsRemembered() async throws {
        UserDefaults.standard.removeObject(forKey: BlocksWorkbenchView.panelWidthKey)
        #if DEBUG
        BlocksWorkbenchOracle.reset()
        #endif
        let total: CGFloat = 900
        let rig = Rig(SeamHost(total: total), width: total, height: 300)
        defer {
            rig.close()
            UserDefaults.standard.removeObject(forKey: BlocksWorkbenchView.panelWidthKey)
        }
        #expect(await rig.poll { BlocksWorkbenchOracle.dividerFrame != nil }, "the seam laid out")
        let seam = try #require(BlocksWorkbenchOracle.dividerFrame)
        #expect(abs(seam.midX - (total - 320)) < 6, "the default 320-pt panel puts the seam at \(total - 320)")
        #expect(UserDefaults.standard.object(forKey: BlocksWorkbenchView.panelWidthKey) == nil,
                "nothing remembered yet — the default rules")

        // A REAL drag: down on the grip, a walk of 100 pt to the LEFT, up.
        let from = CGPoint(x: seam.midX, y: seam.midY)
        rig.send(.leftMouseDown, at: rig.windowPoint(from))
        rig.pump(0.005)
        for step in 1...10 {
            rig.send(.leftMouseDragged, at: rig.windowPoint(CGPoint(x: from.x - CGFloat(step) * 10, y: from.y)))
            rig.pump(0.005)
        }
        rig.send(.leftMouseUp, at: rig.windowPoint(CGPoint(x: from.x - 100, y: from.y)))
        #expect(await rig.poll {
            (UserDefaults.standard.object(forKey: BlocksWorkbenchView.panelWidthKey) as? Double)
                .map { abs($0 - 420) < 6 } ?? false
        }, "the panel grew by the drag's 100 pt — 320 → ~420 — and the width is REMEMBERED (\(String(describing: UserDefaults.standard.object(forKey: BlocksWorkbenchView.panelWidthKey))))")
        #expect(await rig.poll {
            (BlocksWorkbenchOracle.dividerFrame?.midX).map { abs($0 - (from.x - 100)) < 6 } ?? false
        }, "the seam itself moved with the drag")
        // A drag past the list's floor is clamped: the panel can never
        // swallow the list.
        let seam2 = try #require(BlocksWorkbenchOracle.dividerFrame)
        let from2 = CGPoint(x: seam2.midX, y: seam2.midY)
        rig.send(.leftMouseDown, at: rig.windowPoint(from2))
        rig.pump(0.005)
        for step in 1...8 {
            rig.send(.leftMouseDragged, at: rig.windowPoint(CGPoint(x: from2.x - CGFloat(step) * 60, y: from2.y)))
            rig.pump(0.005)
        }
        rig.send(.leftMouseUp, at: rig.windowPoint(CGPoint(x: from2.x - 480, y: from2.y)))
        #expect(await rig.poll {
            (UserDefaults.standard.object(forKey: BlocksWorkbenchView.panelWidthKey) as? Double)
                .map { abs($0 - BlocksWorkbenchLayout.panelWidth(proposed: 900, total: Double(total))) < 6 } ?? false
        }, "clamped at the list's floor: \(BlocksWorkbenchLayout.panelWidth(proposed: 900, total: Double(total)))")
    }
}
