//
//  ShellChromeTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — THE CHROME's pins: the flat shell
//  (row 2), the sidebar column's one row pitch and its height-threshold
//  compression (row 3), and the Open strip's rows back under the rail at
//  that pitch (row 3's "tabs").
//
//  Red-on-old, stated per pin:
//  · the flat shell — the pre-round `RootView` was a `NavigationSplitView`,
//    which AppKit backs with an `NSSplitView`; the flat `ShellSplit` is an
//    `HStack` with none. The mount walk below finds ZERO at rest on the
//    new tree and one on the old.
//  · the pitch — the pre-round Open strip drew ~21 pt rows (4 pt padding, a
//    19 pt floor, 1 pt spacing) at EVERY height; the oracle below reads the
//    row the column actually drew and asserts the generous 30.
//  · the threshold function did not exist (the bottom bar's precedent:
//    `CommitBar.usesTwoRows`) — pinned at its threshold both ways, and the
//    unmeasured case never compresses.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The sidebar's row pitch (correction round, row 3)")
struct SidebarLayoutTests {
    /// Twenty rows is the column at its fullest ordinary shape: one starred
    /// note, five areas, the SEVEN-mode rail (R-cor-5/7 — batch C; the
    /// fixture said "eight" until ladder R1-12) and seven strip rows in
    /// its window — with all three headed groups present.
    private let fullColumnRows = SidebarLayout.rowCount(
        starred: 1, areas: 5, rail: 7, openNotes: 12)

    @Test func ordinaryHeightsKeepTheGenerousPitch() {
        #expect(fullColumnRows == 20, "the strip counts only its window's rows")
        #expect(!SidebarLayout.compressesRows(columnHeight: 1000, rows: fullColumnRows))
        #expect(SidebarLayout.rowHeight(columnHeight: 1000, rows: fullColumnRows)
                == SidebarLayout.generousRowHeight)
        #expect(SidebarLayout.generousRowHeight == 30, "the mockup's `.sb-row` pitch")
    }

    @Test func aColumnTooShortForTheGenerousLayoutCompresses() {
        // 20 rows × 30 + the fixed chrome = 774 pt of generous layout.
        let needed = 20 * SidebarLayout.generousRowHeight + SidebarLayout.fixedChromeHeight
        #expect(SidebarLayout.compressesRows(columnHeight: needed - 1, rows: fullColumnRows))
        #expect(!SidebarLayout.compressesRows(columnHeight: needed, rows: fullColumnRows),
                "exactly fitting is fitting")
        #expect(SidebarLayout.rowHeight(columnHeight: 600, rows: fullColumnRows)
                == SidebarLayout.compactRowHeight)
    }

    /// Ladder R1-12: the chrome counts the headed groups actually present —
    /// a column with no starred group and no rail (one header, one
    /// separator) has ~82 pt more room for its rows than the full column.
    @Test func theChromeCountsOnlyTheHeadedGroupsPresent() {
        #expect(SidebarLayout.chromeHeight(headedGroups: 3) == SidebarLayout.fixedChromeHeight)
        #expect(SidebarLayout.chromeHeight(headedGroups: 1)
                == SidebarLayout.fixedChromeHeight - 2 * (SidebarLayout.groupHeaderHeight + SidebarLayout.separatorHeight),
                "one headed group's chrome, from the constants rather than a copied number")
        // 17o batch d (row 13): the header row grew 22 → 30, and the fit math
        // reads the SAME constant the header draws at — so this arithmetic
        // cannot silently disagree with the column again.
        #expect(SidebarLayout.groupHeaderHeight == SidebarLayout.generousRowHeight)
        // Twelve rows (five areas + seven strip rows) with ONE headed group
        // (the strip): the three-group chrome would compress at this height;
        // the honest count fits.
        let rows = SidebarLayout.rowCount(starred: 0, areas: 5, rail: 0, openNotes: 12)
        let height = 12 * SidebarLayout.generousRowHeight + SidebarLayout.chromeHeight(headedGroups: 1)
        #expect(SidebarLayout.compressesRows(columnHeight: height, rows: rows, headedGroups: 3),
                "counted as three groups it would compress")
        #expect(!SidebarLayout.compressesRows(columnHeight: height, rows: rows, headedGroups: 1),
                "counted as the one group present it fits")
    }

    @Test func fewRowsNeverCompressInAShortWindow() {
        // Five areas alone in a 400 pt column: plenty of room — a fixed
        // pixel threshold would have squeezed them for nothing.
        //
        // **A JUSTIFIED EDIT (17o batch d, row 13), the claim intact:** this
        // said `rows: 5` and took the DEFAULT three headed groups, which is
        // not the scenario it describes — five areas ALONE carry no header
        // and no separator. It passed on 17 pt of slack that the header row's
        // 22 → 30 growth consumed. The combination it was actually asserting
        // is unreachable (a column with three headed groups has more than
        // five rows — the rail alone is seven), so the fix is to ask the
        // question the comment asks.
        #expect(!SidebarLayout.compressesRows(columnHeight: 400, rows: 5, headedGroups: 0))
        // …and the reachable near-boundary still reads honestly.
        #expect(!SidebarLayout.compressesRows(columnHeight: 400, rows: 5, headedGroups: 1))
    }

    @Test func anUnmeasuredColumnNeverCompresses() {
        // Height 0 = the first pass before geometry lands (the bar's third
        // pin): generous, so the column does not flash compact while mounting.
        #expect(!SidebarLayout.compressesRows(columnHeight: 0, rows: 40))
    }

    /// **EDITED IN PLACE BY HER ASK — VX-285** (the VX-283 run, U1; her words
    /// 2026-10-13: *"Open tabs should extend the full height of the screen
    /// that they can (until the synced portion of the bottom row starts,
    /// wherever that is)"*). This pin held the strip's ~7½-row window (Act 10
    /// item 9's ruled shape); her later ask SUPERSEDES that window for the
    /// Open list, so the claim it held is gone by her word, not by a defect —
    /// the ruled-change class, no red-on-old owed for the edit itself (the
    /// mounted pins in `OpenListLayoutTests` carry VX-285's red-on-old).
    /// What it holds now: the list's tallest form is the room down to the
    /// footer, floored; and the column's FIT TEST still counts the strip at
    /// seven, unchanged (VX-285 moves how far the list grows, never when the
    /// column compresses). RENAMED at the VX-283 ladder's R1-5 — it was
    /// `theOpenStripWindowIsHerSevenAndAHalf`, a name still claiming the cap
    /// its body now asserts the list grows past.
    @Test func theOpenListsTallestFormIsTheRoomDownToTheFooter() {
        // The room under the list: visible 800, list top at 400, 12 of air.
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 800, listTop: 400, bottomPadding: 12, rowHeight: 30) == 388)
        // No longer the old 7½-row cap: a tall column gives the list far more.
        #expect(SidebarLayout.openListMaxHeight(
            visibleHeight: 1000, listTop: 300, bottomPadding: 12, rowHeight: 30) > 225)
        // The fit test's count is unchanged at seven.
        #expect(SidebarLayout.openListFitRows == 7)
        #expect(SidebarLayout.openStripRowsCounted(openNotes: 3) == 3)
        #expect(SidebarLayout.openStripRowsCounted(openNotes: 20) == 7)
    }
}

@MainActor
private func countSplitViews(in view: NSView) -> Int {
    var count = view is NSSplitView ? 1 : 0
    for sub in view.subviews { count += countSplitViews(in: sub) }
    return count
}

/// **Row 10 — the "Fill code · From Messages" popover over the note title.**
///
/// The traced HYPOTHESIS was wrong and is recorded as such: the title field's
/// prompt is the note's date, all digits, and the guess was that AppKit read a
/// digit prompt as a verification-code field. It does not. On macOS 26 the
/// suggestion is time-and-focus based and CONTENT-AGNOSTIC — Apple's own
/// documentation of the opt-out key says every text-input-capable field in
/// every Mac app is eligible whenever Messages or Mail has detected a one-time
/// code, a field has focus, and under three minutes have passed. (Hence the
/// same popover reported over spreadsheet cells and terminal emulators.) The
/// brief's API-free fallback — render the date as a `Text` behind an
/// empty-prompt field — would therefore have changed nothing.
///
/// The one documented opt-out is app-wide and lives in the bundle:
/// `NSAutoFillRequiresTextContentTypeForOneTimeCodeOnMac` (macOS 26+, default
/// `NO`). With it `YES`, only a field explicitly annotated `.oneTimeCode` gets
/// the suggestion — and Variorum declares that content type nowhere, which is
/// the point: it has no verification-code field to break. Credential AutoFill
/// is untouched (the auth views' `.password` / `.newPassword` / `.username`
/// annotations are a different mechanism).
///
/// **If a one-time-code field is ever added, it must carry
/// `.textContentType(.oneTimeCode)` or AutoFill will not offer it.** That is
/// the whole cost of this key, and this pin is where the next reader learns it.
@Suite("One-time-code AutoFill is opted out of (17o batch d, row 10)")
struct OneTimeCodeAutoFillTests {
    @Test func theBundleRequiresAnExplicitContentTypeForOneTimeCodes() throws {
        let key = "NSAutoFillRequiresTextContentTypeForOneTimeCodeOnMac"
        let raw = Bundle.main.object(forInfoDictionaryKey: key)
        #expect((raw as? NSNumber)?.boolValue == true,
                "declared as a real Boolean, not \(String(describing: raw))")
    }

    /// The key's cost, stated as an assertion: nothing in the app asks for
    /// one-time-code AutoFill today, so nothing loses it.
    @Test func noFieldInTheAppClaimsToBeAOneTimeCodeField() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        var claimants: [String] = []
        let wanted = ["Variorum", "Shared"]
        for folder in wanted {
            let root = sources.appendingPathComponent(folder)
            guard let walk = FileManager.default.enumerator(
                at: root, includingPropertiesForKeys: nil) else { continue }
            for case let url as URL in walk where url.pathExtension == "swift" {
                guard let text = try? String(contentsOf: url, encoding: .utf8) else { continue }
                if text.contains("oneTimeCode") { claimants.append(url.lastPathComponent) }
            }
        }
        #expect(claimants.isEmpty,
                "annotate it `.textContentType(.oneTimeCode)` or the bundle key blocks it: \(claimants)")
    }
}

@MainActor
@Suite("The flat shell (correction round, row 2) and the strip's pitch (row 3)")
struct ShellChromeTests {
    /// **Row 2 — the shell mounts FLAT.** The pre-round root was a
    /// `NavigationSplitView` (AppKit: an `NSSplitView` under the hosting
    /// view, drawing Tahoe's floating glass sidebar); the flat `ShellSplit`
    /// is an `HStack`. At rest — no inspector presented — the window's view
    /// tree holds no split view at all. RED ON OLD: one.
    ///
    /// **Row 3 — the Open strip's rows carry the column's generous pitch.**
    /// A note is visited so the strip shows it; the oracle reads the row the
    /// column DREW. RED ON OLD: ~21 pt (the strip's own compressed row).
    @Test func theShellMountsFlatAndTheStripRowsAreGenerous() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a tab")
            let router = ShellRouter()
            #if DEBUG
            // Row 50: this pin's OWN column, named by its own session.
            let column = SidebarGeometry.headers(session.debugProbeScope)
            column.resetHeaders()
            #endif

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<200 where router.workspace.history().current == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(countSplitViews(in: hosting) == 0,
                    "no NSSplitView backs the shell at rest — the flat HStack, not the system split view and its glass pane")

            // The strip: visit a note, let the column lay its row out.
            router.workspace.visit(.post(post.id))
            #if DEBUG
            for _ in 0..<200 where column.openRowHeight == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            let drawn = try #require(column.openRowHeight,
                                     "the strip drew its row for the visited note")
            #expect(drawn == SidebarLayout.generousRowHeight,
                    "an Open-strip row at an ordinary height is the generous 30 pt row (the pre-round strip drew ~21)")
            #endif
        }
    }

    /// **Row 13 — the sidebar's headers sit on their rows' edge, with air
    /// before the first wash.** Her punchlist 3 and its follow-up: *"'This
    /// note' is misaligned from write, takes…"*, *"Open… from the tabs"*,
    /// and *"the highlight on the mode you're in and the words 'this note'
    /// or 'open' is very close to touching and the items in that pane should
    /// all be aligned."*
    ///
    /// The mechanism: `header()` padded `groupPadding + rowPadding` while
    /// sitting INSIDE groups that already pad `groupPadding`, so its words
    /// landed 12 pt inboard of the rows beside them; and its 22-pt box with
    /// the text bottom-aligned left nothing between the words and the first
    /// row's wash. Both headed groups are checked, because the defect was
    /// one rule wrong in one place and would come back the same way.
    ///
    /// RED ON OLD: each header's words sit 12 pt right of its rows, and the
    /// gap to the first wash is 0.
    @Test func theSidebarHeadersSitOnTheirRowsEdgeWithAirBeforeTheWash() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a tab")
            _ = try session.operations.newBlock(in: post.id, text: "so the rail has a note.")
            let router = ShellRouter()
            #if DEBUG
            // Row 50: this pin's OWN column, named by its own session —
            // and a reset that clears its scope alone.
            let column = SidebarGeometry.headers(session.debugProbeScope)
            column.resetHeaders()
            #endif

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<200 where router.workspace.history().current == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            // A visited note gives BOTH headed groups: the rail ("this
            // note") and the Open strip.
            router.workspace.visit(.post(post.id))
            _ = router.workspace.select(.post(post.id))
            #if DEBUG
            for _ in 0..<400 where column.headerTextFrames.count < 2 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            for _ in 0..<20 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            print("[17o d row 13 keys] headers \(column.headerTextFrames.keys.sorted()) · rows \(column.firstRowContentFrames.keys.sorted())")
            for title in ["this note", WorkspaceNaming.openSectionHeader] {
                let words = try #require(column.headerTextFrames[title],
                                         "the \(title) header drew")
                let row = try #require(column.firstRowContentFrames[title],
                                       "…and its first row drew")
                let box = try #require(column.firstRowBoxFrames[title])
                print("[17o d row 13] \(title): words \(words) · row \(row) · box \(box)")
                #expect(abs(words.minX - row.minX) <= 0.5,
                        "\(title): the header's words start where its rows' do — \(words.minX) vs \(row.minX)")
                #expect(box.minY - words.maxY >= 5,
                        "\(title): air between the words and the first wash — \(box.minY - words.maxY)")
            }
            #endif
        }
    }

    /// **Row 9 — the seam's grip is wide, centred, and reaches into the
    /// detail.** Her words: *"the hitbox for adjusting the size of the left
    /// bar … too small … sometimes the I looking pointer."* It was a 9-pt
    /// `.overlay` on the 1-pt line, so it was not a layout participant at
    /// all — and the detail, the HStack's next sibling, drew and hit-tested
    /// after it, taking every point right of the line. She could reach about
    /// four points, on the sidebar side only.
    ///
    /// The claim a pin can hold is the geometry: the grip's own frame, ≥ 12
    /// pt, centred on the line, and reaching past the line on BOTH sides.
    /// The z-order half and the cursor half are the walk's (a pushed
    /// `NSCursor` versus the text view's own cursor rects is not something
    /// a mounted view can be asked about).
    ///
    /// RED ON OLD, measured: grip `(206.0, 52.0, 9.0, 792.0)` against a line
    /// at `(210.0, …, 1.0, …)` — nine points wide and reaching only four
    /// past the line's leading edge, which is the half over the sidebar. The
    /// grip is `(203.5, …, 14.0, …)` now: centred on the seam and seven
    /// points into each side.
    @Test func theSeamsGripIsWideCentredAndReachesIntoBothSides() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = ShellRouter()
            #if DEBUG
            ShellGeometry.reset()
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #if DEBUG
            for _ in 0..<300 where ShellGeometry.dividerGripFrame == nil {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            let grip = try #require(ShellGeometry.dividerGripFrame,
                                    "the grip publishes a frame of its own")
            let line = try #require(ShellGeometry.dividerLineFrame)
            print("[17o d row 9] grip \(grip) · line \(line)")
            #expect(grip.width >= 12,
                    "a reachable target, not the old 9: \(grip.width)")
            #expect(abs(grip.midX - line.midX) <= 0.5,
                    "centred on the seam: \(grip.midX) vs \(line.midX)")
            #expect(grip.minX < line.minX - 4 && grip.maxX > line.maxX + 4,
                    "…and it reaches into the sidebar AND the detail: \(grip) vs \(line)")
            #expect(grip.height >= 100, "it runs the seam, not a handle")
            #endif
        }
    }

    /// **The FOURTH seam** (18d's ladder round 2, MINOR-1): the pane row's
    /// divider, converted to the shared `SeamGrip` because it was the last
    /// copy of row 9's shape — a 9-pt `.overlay` with `NSCursor.push()` and
    /// no `zIndex`, in a row where `paneHost` is drawn after it and takes
    /// the grip's right half, over a live editor's I-beam.
    ///
    /// The claims are the shell seam's above, verbatim, over the pane row's
    /// own space. RED on the pre-fix shape (measured by behavioural revert:
    /// the 9-pt overlay, instrumented so it reported its own frame, gave
    /// `grip.width → 9.0` and did not reach past the line into the pane).
    @Test func thePaneSeamsGripIsWideCentredAndReachesIntoBothPanes() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            // Live ids: the seam oracle is keyed by the subject, and suites
            // run in parallel (round 2's MINOR-2).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 91))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let left = try session.operations.createPost(title: "Left", profile: nil)
            let right = try session.operations.createPost(title: "Right", profile: nil)
            _ = try session.operations.newBlock(in: left.id, text: "left text")
            _ = try session.operations.newBlock(in: right.id, text: "right text")
            let router = ShellRouter()
            // MY seam's key — this window's router and the seam's index (the
            // round-end Fable pass, MINOR-2 (b)); cleared for THIS key only
            // (MINOR-2 (c): a whole-oracle reset wiped parallel suites' seams,
            // which `onGeometryChange` never republishes).
            let seam = SeamGeometry.key(
                RootView.paneSeamFamily,
                subject: RootView.paneSeamSubject(router: router, index: 0))
            #if DEBUG
            SeamGeometry.forget(seam)
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<300 where router.workspace.history().current != .shelf {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            router.pendingSelection = .post(left.id)
            for _ in 0..<300 where session.commandRouter.activePostID != left.id {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            router.openBeside(.post(right.id))
            #if DEBUG
            for _ in 0..<300 where SeamGeometry.gripFrames[seam] == nil {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(router.workspace.panes.count == 2, "the split is really on screen")
            let grip = try #require(SeamGeometry.gripFrames[seam],
                                    "the pane seam's grip publishes a frame of its own")
            let line = try #require(SeamGeometry.lineFrames[seam])
            #expect(grip.width >= SeamGrip.width - 0.5,
                    "a reachable target, not the old 9: \(grip.width)")
            #expect(abs(grip.midX - line.midX) <= 0.5,
                    "centred on the seam: \(grip.midX) vs \(line.midX)")
            #expect(grip.minX < line.minX - 4 && grip.maxX > line.maxX + 4,
                    "…and it reaches into BOTH panes: \(grip) vs \(line)")
            #expect(grip.height >= 100, "it runs the seam, not a handle")
            #endif
        }
    }

    @Test func theSidebarWidthIsClampedToAUsableColumn() {
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(10) == 180)
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(210) == 210)
        #expect(ShellSplit<EmptyView, EmptyView>.clamped(5000) == 360)
    }

    /// The toggle is a declared act on both of its doors (P-1): the View
    /// menu on the platform's own ⌃⌘S, and the toolbar.
    @Test func theSidebarToggleIsDeclaredOnItsTwoDoors() {
        let cap = CapabilityRegistry.capability(.toggleSidebar)
        #expect(cap.doors.contains(.menuBar))
        #expect(cap.doors.contains(.surface))
        #expect(cap.shortcutLabel == "\u{2303}\u{2318}S")
        #expect(RootView.surfaceCapabilities == [.toggleSidebar])
        #expect(EditorCommands.menuRendered.contains(.toggleSidebar))
        let router = ShellRouter()
        #expect(router.sidebarShown, "a window opens with its sidebar")
        router.sidebarShown.toggle()
        #expect(!router.sidebarShown)
    }
}
