//
//  MobileTabBarTests.swift
//  VariorumMobileTests
//
//  VM-52 (the VM-47 run, batch 4) — **THE BOTTOM BAR: three words on a chip
//  with real tap areas, on every root and list.** Her ruling, LK-5 — "Words
//  on a chip": three words at 17 pt (Starred · Bookcase · Library), the
//  current one on a chip, 56 pt targets; shown on roots and lists, hidden
//  inside a note ("Roots and lists, not notes").
//
//  WHAT IS PINNED, and how (a design row her ruling settles: geometry oracles
//  and the mounted shell, not a defect pin):
//  · the FIT — every word whole on every phone width iOS 26 ships, at every
//    text size, in both voices; and at Display Zoom a word that cannot hold
//    its size shrinks no further than the 13 pt floor and still fits;
//  · the BAR alone — three cells a third of the width and at least 56 tall,
//    one row in band order, the current one selected, each a button speaking
//    its plain word, the chrome holding at the accessibility sizes;
//  · the MOUNTED SHELL — the doors 56 tall and a third of the screen (RED ON
//    OLD: the pre-batch doors were word-sized, ~20 pt tall and word-wide); a
//    pushed list wears the bar and a tab tap returns to that root, the stack
//    left behind back at its root; inside a note no door is on screen; the
//    Versions listing wears the bar and its reader does not;
//  · the ROUTE RULE, as the destination builder's source (the lists carry the
//    bar; the note, the Read page and Protection do not).
//
//  THE WALKER'S THREE PAGES (`MobileNavigationTests`' recorded fact): the
//  harness walks raw subviews, so the two offscreen roots — each wearing its
//  own bar, a screen away — are in every walk. A door is counted here only
//  when its frame is ON the window.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The portrait widths the phone ships on iOS 26: the 375 pt family (SE, 13
/// mini), 393, 402, 430, 440.
private let shippedWidths: [CGFloat] = [375, 393, 402, 430, 440]
/// Display Zoom on the 375 pt phones.
private let displayZoomWidth: CGFloat = 320

private let barSizes: [DynamicTypeSize] = [.xSmall, .large, .xxxLarge, .accessibility5]

@MainActor
private func tokens(_ voice: ThemeVoice) -> VoiceTokens {
    voice == .study ? .studyLight : .terminalLight
}

/// The doors of one word that are ON the window (see the header).
@MainActor
private func onScreen<V: View>(_ surface: HostedSurface<V>, _ label: String) -> [NSObject] {
    let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
    return surface.visibleElements.filter {
        $0.accessibilityLabel == label
            && $0.accessibilityTraits.contains(.button)
            && window.intersects($0.accessibilityFrame)
    }
}

/// Drive the on-window copy of a door (the offscreen roots' copies come first
/// in tree order and would act on a page that is not showing).
@MainActor
private func activateOnScreen<V: View>(_ surface: HostedSurface<V>, _ label: String) -> Bool {
    onScreen(surface, label).first?.accessibilityActivate() ?? false
}

@MainActor
@Suite("The bottom bar — words on a chip, 56 pt targets (VM-52)", .serialized)
struct MobileTabBarTests {

    // MARK: - The fit (pure)

    /// Every word stays whole — no shrink — on every shipped width, at every
    /// text size up to the accessibility sizes (the chrome holds at xxxLarge),
    /// in both voices. And on the phone the mockups are drawn on, at the
    /// default size, the current word's chip has the drawn 16 to each side.
    @Test func theFitKeepsEveryWordWholeOnEveryShippedWidth() {
        for voice in [ThemeVoice.study, .terminal] {
            let tokens = tokens(voice)
            for size in barSizes {
                for width in shippedWidths {
                    for page in MobileShellBand.pages {
                        let rendered = tokens.chromeLabel(MobileTabBar.word(page))
                        let word = MobileTabBarMetrics.wordWidth(
                            rendered, voice: voice, at: size.phoneCategory)
                        let side = MobileTabBarMetrics.chipSide(
                            wordWidth: word, cellWidth: width / 3)
                        #expect(side != nil,
                                "\(rendered) (\(word) pt) does not fit a \(width / 3) pt cell in \(voice) at \(size)")
                    }
                }
            }
            for page in MobileShellBand.pages {
                let rendered = tokens.chromeLabel(MobileTabBar.word(page))
                let word = MobileTabBarMetrics.wordWidth(rendered, voice: voice, at: .large)
                #expect(MobileTabBarMetrics.chipSide(wordWidth: word, cellWidth: 402 / 3)
                        == MobileTabBarMetrics.chipSides.first,
                        "\(rendered) at the default size on 402 pt")
            }
        }
    }

    /// The rule itself: the widest side that fits, in the scale's order; nil
    /// only when even the narrowest cannot.
    @Test func theFitRuleTakesTheWidestSideThatFits() {
        #expect(MobileTabBarMetrics.chipSides == [16, 8, 4])
        #expect(MobileTabBarMetrics.chipSide(wordWidth: 100, cellWidth: 132) == 16)
        #expect(MobileTabBarMetrics.chipSide(wordWidth: 100, cellWidth: 131) == 8)
        #expect(MobileTabBarMetrics.chipSide(wordWidth: 100, cellWidth: 115) == 4)
        #expect(MobileTabBarMetrics.chipSide(wordWidth: 100, cellWidth: 107) == nil)
    }

    /// Display Zoom (320 pt): a word whose cell cannot hold it at its size
    /// shrinks — and at the 13 pt floor it fits with the narrowest sides, so
    /// nothing in the bar is ever cut or set under 13.
    @Test func atDisplayZoomAWordShrinksNoFurtherThanTheFloorAndStillFits() {
        var shrinking: [String] = []
        for voice in [ThemeVoice.study, .terminal] {
            let tokens = tokens(voice)
            let role = PhoneType.spec(.tab, voice: voice)
            let current = PhoneTypeSpec(
                family: role.family, weight: .semibold, size: role.size,
                lineHeight: role.lineHeight, anchor: role.anchor, scaling: role.scaling)
            for size in barSizes {
                #expect(PhoneType.pointSize(role, at: size.phoneCategory) >= PhoneType.floorSize)
                for page in MobileShellBand.pages {
                    let rendered = tokens.chromeLabel(MobileTabBar.word(page))
                    let word = MobileTabBarMetrics.wordWidth(
                        rendered, voice: voice, at: size.phoneCategory)
                    guard MobileTabBarMetrics.chipSide(
                        wordWidth: word, cellWidth: displayZoomWidth / 3) == nil
                    else { continue }
                    shrinking.append("\(voice) \(size) \(rendered)")
                    let floorFont = PhoneType.baseUIFont(
                        current, voice: voice, pointSize: PhoneType.floorSize)
                    let atFloor = ceil((rendered as NSString)
                        .size(withAttributes: [.font: floorFont]).width)
                    #expect(atFloor + 2 * (MobileTabBarMetrics.chipSides.last ?? 0)
                            <= displayZoomWidth / 3,
                            "\(rendered) at the floor still does not fit 320 pt in \(voice)")
                }
            }
        }
        print("PERF[sim] VM-52 tab words that shrink at 320 pt: \(shrinking)")
    }

    // MARK: - The bar alone

    /// Three cells, a third of the width each and at least 56 tall (LK-5's
    /// targets — the whole cell answers), on one row in band order; the
    /// current one selected; each a button speaking its PLAIN word in both
    /// voices; and the chrome holds — the bar is no taller at AX5 than at
    /// xxxLarge.
    @Test func theBarHasThreeCellsAThirdWideAndFiftySixTall() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            for width in [CGFloat(402), 375] {
                var heights: [DynamicTypeSize: CGFloat] = [:]
                for size in [DynamicTypeSize.large, .xxxLarge, .accessibility5] {
                    let bar = VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        MobileTabBar(current: .shelf, tokens: tokens(voice), select: { _ in })
                    }
                    .dynamicTypeSize(size)
                    try await withHostedSurface(bar, size: CGSize(width: width, height: 400)) { surface in
                        await surface.settle(12)
                        var frames: [CGRect] = []
                        for page in MobileShellBand.pages {
                            let word = MobileTabBar.word(page)
                            let door = try #require(
                                surface.element(labeled: word),
                                "no \(word) door in \(voice) at \(size): \(surface.visibleLabels)")
                            let frame = door.accessibilityFrame
                            #expect(frame.height >= MobileTabBarMetrics.target - 0.5,
                                    "\(word) is \(frame.height) tall in \(voice) at \(size)")
                            #expect(abs(frame.width - width / 3) <= 1,
                                    "\(word) is \(frame.width) wide at \(width)")
                            #expect(door.accessibilityTraits.contains(.button))
                            #expect(door.accessibilityTraits.contains(.selected) == (page == .shelf),
                                    "\(word)'s selection in \(voice)")
                            frames.append(frame)
                        }
                        #expect(frames.allSatisfy { abs($0.midY - frames[0].midY) <= 0.5 }, "one row: \(frames)")
                        #expect(frames[0].maxX <= frames[1].minX + 0.5 && frames[1].maxX <= frames[2].minX + 0.5,
                                "band order, left to right: \(frames)")
                        heights[size] = frames[0].height
                    }
                }
                let xxx = try #require(heights[.xxxLarge])
                let ax5 = try #require(heights[.accessibility5])
                let large = try #require(heights[.large])
                #expect(abs(ax5 - xxx) <= 0.5, "the chrome holds past xxxLarge: \(xxx) → \(ax5)")
                #expect(xxx >= large, "the bar grows with the words to xxxLarge: \(large) → \(xxx)")
            }
        }
    }

    /// Each door calls the shell's tab road with its own page.
    @Test func eachDoorCallsTheTabRoadWithItsOwnPage() async throws {
        let picked = LockIsolatedBox<[MobileTab]>([])
        let bar = VStack(spacing: 0) {
            Spacer(minLength: 0)
            MobileTabBar(current: .library, tokens: .studyLight, select: { picked.value.append($0) })
        }
        try await withHostedSurface(bar, size: CGSize(width: 402, height: 300)) { surface in
            await surface.settle(10)
            for page in MobileShellBand.pages {
                #expect(surface.activate(MobileTabBar.word(page)), "labels: \(surface.visibleLabels)")
            }
            await surface.settle(4)
            #expect(picked.value == MobileShellBand.pages)
        }
    }

    // MARK: - The mounted shell

    /// **RED ON OLD.** On the real shell, the bar's doors are at least 56
    /// tall and a third of the screen wide, at the foot. The pre-batch doors
    /// were the words' own frames — about 20 pt tall and as wide as the word —
    /// so the two doors both trees carry ("Starred", "Library") fail here on
    /// the old tree; the third door's word is new ("Bookcase", SW-1).
    @Test func onTheMountedShellTheDoorsAreFiftySixTallAndAThirdOfTheScreen() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            let size = CGSize(width: 393, height: 852)
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router), size: size
            ) { surface in
                await surface.settle(30)
                for word in [MobileStarsModel.pageName, "Library", "Bookcase"] {
                    let doors = onScreen(surface, word)
                    #expect(doors.count == 1, "\(word) on screen: \(doors.count); labels \(surface.visibleLabels)")
                    guard let frame = doors.first?.accessibilityFrame else { continue }
                    #expect(frame.height >= MobileTabBarMetrics.target - 0.5, "\(word): \(frame)")
                    #expect(abs(frame.width - size.width / 3) <= 1, "\(word): \(frame)")
                    #expect(frame.minY >= size.height * 0.75, "\(word) sits at the foot: \(frame)")
                }
                #expect(onScreen(surface, "Bookcase").first?.accessibilityTraits.contains(.selected) == true,
                        "home is the Bookcase")
            }
        }
    }

    /// **A PUSHED LIST WEARS THE BAR, AND A TAB TAP RETURNS TO THAT ROOT.**
    /// Home → the Trash (a list, pushed on the Bookcase's stack): the bar is
    /// on screen under it, the Bookcase chosen. Tapping the CURRENT tab goes
    /// back to the Bookcase's root. Pushed again, a tap on Library changes
    /// the page AND leaves the Bookcase's stack at its root (P-47-19) — the
    /// Trash is gone from the walk entirely, and the Bookcase's root is back
    /// under the band.
    @Test func aPushedListWearsTheBarAndATabTapReturnsToThatRoot() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                let trashLine = MobileTrashView.emptyTrashLine

                // Into the Trash, by the Bookcase's own door.
                #expect(activateOnScreen(surface, MobileRecoveryDoors.trashLabel),
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(trashLine), "the Trash arrived: \(surface.visibleLabels)")
                let bookcase = try #require(onScreen(surface, "Bookcase").first,
                                            "the bar is on the pushed list: \(surface.visibleLabels)")
                #expect(bookcase.accessibilityTraits.contains(.selected))
                #expect(bookcase.accessibilityFrame.height >= MobileTabBarMetrics.target - 0.5)
                #expect(onScreen(surface, "Library").count == 1)

                // The current tab: back to its root.
                #expect(activateOnScreen(surface, "Bookcase"))
                await surface.settle(40)
                #expect(!surface.visibleLabels.contains(trashLine), "the Trash is gone: \(surface.visibleLabels)")
                #expect(surface.visibleLabels.contains("New Book"), "the Bookcase's root is back")

                // Another tab, from the pushed list.
                #expect(activateOnScreen(surface, MobileRecoveryDoors.trashLabel))
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(trashLine))
                #expect(activateOnScreen(surface, "Library"))
                await surface.settle(40)
                #expect(onScreen(surface, "Library").first?.accessibilityTraits.contains(.selected) == true,
                        "the page changed")
                #expect(!surface.visibleLabels.contains(trashLine),
                        "the stack left behind is back at its root — no Trash anywhere in the walk")
                #expect(surface.visibleLabels.contains("New Book"),
                        "the Bookcase's root stands under the band, a screen away")
            }
        }
    }

    /// **INSIDE A NOTE THE BAR IS GONE; THE VERSIONS LISTING WEARS IT.**
    /// The Bookcase's Today door opens a note in Write: no door of the bar is
    /// on screen. Note ▸ Versions (a list pushed over the note) wears it; a tap
    /// on Library from there leaves the Bookcase's stack at its root, so the
    /// note under the listing closes as Back would close it — its editor
    /// leaves the liveness authority.
    @Test func insideANoteTheBarIsGoneAndTheVersionsListingWearsIt() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(50)
                #expect(surface.activate(MobileShelfFaces.todayDoorSpoken),
                        "labels: \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(!router.editors.registeredPostIDs.isEmpty, "a note is open in Write")
                for word in [MobileStarsModel.pageName, "Bookcase", "Library"] {
                    #expect(onScreen(surface, word).isEmpty, "\(word) is on screen inside a note")
                }

                // Note ▸ Versions: a list over the note.
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel), "labels: \(surface.visibleLabels)")
                await surface.settle(50)
                #expect(surface.activate(VersionsPath.menuLabel), "labels: \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.visibleLabels.contains(MobileVersionsModel.noVersions),
                        "the Versions listing arrived: \(surface.visibleLabels)")
                #expect(onScreen(surface, "Bookcase").first?.accessibilityTraits.contains(.selected) == true,
                        "the listing wears the bar: \(surface.visibleLabels)")

                #expect(activateOnScreen(surface, "Library"))
                await surface.settle(60)
                #expect(onScreen(surface, "Library").first?.accessibilityTraits.contains(.selected) == true)
                #expect(!surface.visibleLabels.contains(MobileVersionsModel.noVersions))
                for _ in 0..<100 where !router.editors.registeredPostIDs.isEmpty {
                    await surface.settle(1)
                }
                #expect(router.editors.registeredPostIDs.isEmpty,
                        "the note under the listing closed as Back would close it")
            }
        }
    }

    /// **THE ONE LINE CLEARS THE BAR WHEREVER A BAR IS ON SCREEN** (the VM-55
    /// re-land, meeting 2). VM-55's message line lifts by the bar's measured
    /// height (`chromeInset`), and it keyed the lift to the ROOTS
    /// (`pagingAllowed`) — written before the bar rode pushed lists (VM-52). The
    /// shell now lifts it wherever a bar is on screen: on a root, on a pushed
    /// list, and not inside a note. Read off the line's own model, through the
    /// shell's host probe. RED ON THE OLD RULE by construction: on the pushed
    /// Trash the visible stack is not at its root, so the old lift was 0 and the
    /// line would have sat over the bar's doors.
    @Test func theMessageLineClearsTheBarWhereverABarIsOnScreen() async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                let line = try #require(Self.messageLine(in: surface.host.view),
                                        "the shell hosts its one line")
                let rootBar = try #require(onScreen(surface, "Bookcase").first?.accessibilityFrame)
                #expect(line.chromeInset >= MobileTabBarMetrics.target - 0.5,
                        "on a root the line clears the bar: \(line.chromeInset), bar \(rootBar)")

                // A pushed list wears the bar — and the line still clears it.
                #expect(activateOnScreen(surface, MobileRecoveryDoors.trashLabel),
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(MobileTrashView.emptyTrashLine))
                #expect(!onScreen(surface, "Bookcase").isEmpty, "the Trash wears the bar")
                #expect(line.chromeInset >= MobileTabBarMetrics.target - 0.5,
                        "on a pushed list the line clears the bar: \(line.chromeInset)")

                // Back to the root, then into a note: no bar, no lift.
                #expect(activateOnScreen(surface, "Bookcase"))
                await surface.settle(40)
                #expect(surface.activate(MobileShelfFaces.todayDoorSpoken), "labels: \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(!router.editors.registeredPostIDs.isEmpty, "a note is open in Write")
                #expect(line.chromeInset == 0, "inside a note there is no bar to clear: \(line.chromeInset)")
            }
        }
    }

    /// **A WING LANDING SHOWS THE BOOKCASE ITSELF** (the VM-55 re-land,
    /// meeting 4). VM-55's landing changes the page to the Shelf and touches no
    /// stack (P-55-14) — it relies on the Shelf's own stack standing at its root
    /// while hidden. This run's tab road keeps that true (P-47-19: a tab from a
    /// pushed list first returns the stack being left to its root), so the two
    /// agree: the Trash pushed on the Bookcase's stack, Library by its tab, the
    /// wing door, Work picked — the landing is Work's Bookcase ROOT, never the
    /// Trash left behind.
    @Test func aWingLandingAfterAListWasLeftShowsTheBookcaseItself() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                let trashLine = MobileTrashView.emptyTrashLine
                #expect(activateOnScreen(surface, MobileRecoveryDoors.trashLabel),
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(trashLine), "the Trash is on the Bookcase's stack")

                #expect(activateOnScreen(surface, "Library"))
                await surface.settle(40)
                #expect(onScreen(surface, "Library").first?.accessibilityTraits.contains(.selected) == true)
                #expect(activateOnScreen(surface, WingWords.home), "the Library's wing door: \(surface.visibleLabels)")
                await surface.settle(30)
                #expect(surface.host.presentedViewController != nil, "the list is up")
                #expect(surface.activate("Work"), "labels: \(surface.visibleLabels)")
                #expect(await eventually { session.wing.currentID == world.work })
                await surface.settle(40)
                #expect(surface.host.presentedViewController == nil, "the list went")
                #expect(onScreen(surface, "Bookcase").first?.accessibilityTraits.contains(.selected) == true,
                        "landed on the Bookcase")
                #expect(!surface.visibleLabels.contains(trashLine),
                        "the Bookcase's ROOT, not the Trash left on its stack — labels \(surface.visibleLabels)")
                #expect(!onScreen(surface, "Work").isEmpty, "the Bookcase root's wing door names Work")
            }
        }
    }

    /// The shell's one message line, found by its host probe in the shell's
    /// own view tree (the probe holds the line's model).
    static func messageLine(in view: UIView) -> MobileMessageLineModel? {
        if let probe = view as? MobileMessageLineHost.Probe { return probe.model }
        for sub in view.subviews {
            if let found = messageLine(in: sub) { return found }
        }
        return nil
    }

    /// The Versions screen's own rule: the bar rides the LISTING and leaves
    /// while a moment's words are read (the reader is her words, not a list).
    @Test func theVersionsReaderDoesNotWearTheBar() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "moment", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "It had been raining.", at: .end, registeringUndo: false)
                try ops.saveNoteVersion(post.id)
                return post.id
            }
            let model = MobileVersionsModel(session: session, postID: postID)
            let bar = MobileTabBar(current: .library, tokens: .terminalLight, select: { _ in })
            try await withHostedSurface(
                MobileVersionsView(model: model, tokens: .terminalLight, listingBar: AnyView(bar))
            ) { surface in
                await surface.settle(40)
                #expect(surface.element(labeled: "Library") != nil, "the listing wears the bar")
                let item = try #require(model.versions.first)
                #expect(surface.activate("\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))"),
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(model.reading != nil)
                #expect(surface.element(labeled: "Library") == nil, "the reader wears no bar")
                #expect(surface.activate(MobileVersionsView.backToListing))
                await surface.settle(20)
                #expect(surface.element(labeled: "Library") != nil, "back on the listing, the bar returns")
            }
        }
    }

    // MARK: - The route rule (source)

    /// The destination builder decides where the bar shows: each LIST route
    /// carries it, and the note, the Read page and Protection do not (her
    /// "Roots and lists, not notes"; P-47-18 for Protection).
    @Test func theRouteRuleIsTheDestinationBuilders() throws {
        let shell = try MobileProtectionCompositionTests.code(
            "VariorumMobile/Features/Shell/MobileShellView.swift")
        let start = try #require(shell.range(of: "private func destination("))
        let end = try #require(shell.range(of: "private func attachProtectionReceipts(", range: start.upperBound..<shell.endIndex))
        let builder = String(shell[start.upperBound..<end.lowerBound])
        var arms: [String: String] = [:]
        let pieces = builder.components(separatedBy: "        case .")
        for piece in pieces.dropFirst() {
            let name = String(piece.prefix { $0.isLetter })
            arms[name] = piece
        }
        #expect(Set(arms.keys) == ["book", "bookRead", "note", "trash", "archive", "versions", "protection"],
                "the arms read: \(arms.keys.sorted())")
        // MOVED at the VM-55 re-land (meeting 2): a list's bar is the same bar
        // COUNTED while it shows (`listBar(owner)`), so the one message line
        // knows to clear it — the rule pinned is unchanged: lists carry the
        // bar, the note, the Read page and Protection carry none.
        for list in ["book", "trash", "archive"] {
            #expect(arms[list]?.contains(".safeAreaInset(edge: .bottom, spacing: 0) { listBar(owner) }") == true,
                    "\(list) is a list and carries the bar")
        }
        #expect(arms["versions"]?.contains("listingBar: AnyView(listBar(owner))") == true)
        for bare in ["bookRead", "note", "protection"] {
            #expect(arms[bare]?.contains("tabBar") == false && arms[bare]?.contains("listBar") == false,
                    "\(bare) carries no bar")
        }
    }
}
