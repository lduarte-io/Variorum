//
//  MobileWingDoorTests.swift
//  VariorumMobileTests
//
//  **VM-225 (the VM-55 run, "Wings underneath", batch 4) — THE PLAIN INTERIM
//  WING DOOR.** The acceptance evidence for the door: tap the wing's name on a
//  root, pick from a plain list of the wings, land on that wing's Bookcase.
//  A Feature — red-on-old does not bind; each pin says what it would catch.
//
//  · `MobileWingDoorTests` — the pick's state transitions over the shared
//    brains (`WingsModel`, `WingSwitcherBrain`): the switch, the landing (the
//    current wing included), every root re-scoping through batch 1's follow,
//    no line for a switch, the list read when it opens, the wing remembered
//    across a rebuilt session, a wing that dies while the list is open, the
//    one-wing list, the capture box filed in its own wing first (a real box),
//    and the line's letters unchanged by the door.
//  · `MobileWingDoorGeometryTests` — the door's target on each REAL root in a
//    real window (batch 2's lesson: a geometry rule fed numbers directly
//    missed a real inset — so these drive the views): at least 44 pt tall and
//    wide, below the status bar's inset, never reaching into what is drawn
//    under the line, and a real control that fires.
//  · `MobileWingListSheetTests` — the list itself, hosted: its rows in the
//    switcher's order with the current one marked, and a real row's press
//    switching and landing.
//  · `MobileWingDoorShellTests` — the whole road on the MOUNTED shell: the
//    name on the visible root opens the list, a row press lands on the
//    picked wing's Bookcase from the Library, the Bookcase re-scoped.
//
//  **How a regression trips it:** a pick that did not switch, did not land, or
//  landed only when the wing changed; a listing left scoped to the old wing; a
//  line drawn for the switch; a list drawn from a stale read; a switch that
//  forgot the device memory; a dead wing's row that switched the phone into
//  it; a draft filed into the wing she switched to; a door whose target is
//  under 44 pt, sits in the status bar, or reaches into the field or rows
//  below; a door that is not a real control; a line whose letters changed.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The pick's state transitions

@MainActor
@Suite("VM-225 — the interim wing door: a pick switches, lands and re-scopes", .serialized)
struct MobileWingDoorTests {
    /// The road end to end at the model level: the list opens in the
    /// switcher's order with Home marked; a pick of Work switches the shared
    /// wing, lands on the Bookcase once, closes the list and says nothing —
    /// and every root's held listing re-reads in Work (batch 1's follow), and
    /// the roots' title names it.
    @Test func aPickSwitchesLandsOnTheBookcaseAndEveryRootRescopes() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            try session.operations.setStarred(.post(world.homeNote), starred: true)
            try session.operations.setStarred(.post(world.workNote), starred: true)
            let wings = MobileWingDoor.phoneWings(session)
            let door = MobileWingDoor(wings: wings)
            let shelf = MobileShelfViewModel(session: session)
            let library = MobileLibraryViewModel(session: session)
            let stars = MobileStarsModel(session: session)
            let held = [
                Task { await shelf.start() },
                Task { await library.startAll() },
                Task { await stars.start() },
            ]
            defer { held.forEach { $0.cancel() } }
            #expect(await eventually { shelf.books.map(\.reading.id) == [world.homeBook] })

            door.open()
            #expect(door.isOpen)
            await door.listOpened()
            #expect(door.switcher.rows.map(\.name) == ["Home", "Work"],
                    "the switcher's order, Home first")
            #expect(door.switcher.currentID == "", "the current wing is the marked row")

            await door.pick(world.work)
            #expect(session.wing.currentID == world.work, "the shared wing switched")
            #expect(door.landings == 1, "the pick landed on the Bookcase")
            #expect(!door.isOpen, "the list closed")
            #expect(session.status.current == nil, "no line for a switch (her ruling)")
            #expect(MobileWingTitle.name(of: wings) == "Work", "every root's title names it")
            #expect(await eventually { shelf.books.map(\.reading.id) == [world.workBook] },
                    "the Bookcase re-scoped")
            #expect(await eventually { library.all.map(\.postID) == [world.workNote] },
                    "the Library re-scoped")
            #expect(await eventually { stars.items.map(\.target) == [.post(world.workNote)] },
                    "Starred re-scoped")
        }
    }

    /// "Pick a wing" means one thing on every road (VX-833): the CURRENT wing,
    /// picked, lands on its Bookcase too — and switches nothing, files
    /// nothing, says nothing.
    @Test func pickingTheCurrentWingLandsAndSwitchesNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let filings = Tally()
            let door = MobileWingDoor(
                wings: MobileWingDoor.phoneWings(session), fileCaptureFirst: { filings.count += 1 })
            door.open()
            await door.listOpened()
            await door.pick(world.work)
            #expect(session.wing.currentID == world.work)
            #expect(door.landings == 1, "the current wing lands too")
            #expect(!door.isOpen)
            #expect(filings.count == 0, "nothing changed wings, so nothing is filed")
            #expect(session.status.current == nil)
        }
    }

    /// The list is READ when it opens (the brief's rule): a wing made after
    /// the brain last read — here, never read at all — is on the list once it
    /// opens.
    @Test func theListIsReadWhenItOpens() async throws {
        try await withEditorWorld { session, _ in
            let door = MobileWingDoor(wings: MobileWingDoor.phoneWings(session))
            let late = try session.operations.createWing(name: "Late")
            #expect(door.switcher.rows.map(\.id) == [""], "nothing read yet: Home alone")
            door.open()
            await door.listOpened()
            #expect(door.switcher.rows.map(\.id) == ["", late.id], "the open read the store")
        }
    }

    /// The pick goes through the shared `WingState`, so the device memory
    /// remembers it: a session rebuilt over the same store and the same
    /// memory (what the bootstrap does at the next launch or unlock) stands in
    /// the picked wing, and its own wings read keeps it (the wing is live).
    /// A scratch defaults suite — never the test host's.
    @Test func thePickIsRememberedAcrossARebuiltSession() async throws {
        let suite = "vm225-wing-door-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.attachMemory(defaults)
            #expect(session.wing.currentID == "", "a device that never switched stands in Home")
            let door = MobileWingDoor(wings: MobileWingDoor.phoneWings(session))
            door.open()
            await door.listOpened()
            await door.pick(world.work)
            #expect(defaults.string(forKey: WingState.memoryKey) == world.work)

            let rebuilt = AppSession(database: db)
            rebuilt.wing.attachMemory(defaults)
            #expect(rebuilt.wing.currentID == world.work, "the rebuilt session stands where she picked")
            let rebuiltWings = MobileWingDoor.phoneWings(rebuilt)
            await rebuiltWings.load()
            #expect(rebuilt.wing.currentID == world.work, "a live wing survives the revalidation")
            #expect(MobileWingTitle.name(of: rebuiltWings) == "Work")
        }
    }

    /// A wing that dies while the list is open (here: it arrives deleted by
    /// sync, still holding a note): the held read returns the phone to Home,
    /// the open list drops the row and marks Home, and a press on the row that
    /// just died (a stale tap) switches nothing, lands nothing, keeps the list
    /// up and says the shared table's own words — a door that did nothing
    /// speaks a refusal.
    @Test func aWingThatDiesWhileTheListIsOpenReturnsThePhoneHome() async throws {
        try await withEditorWorld { session, db in
            let world = try TwoWingWorld.make(session)
            session.wing.switchTo(world.work)
            let wings = MobileWingDoor.phoneWings(session)
            let door = MobileWingDoor(wings: wings)
            let held = Task { await wings.track() }
            defer { held.cancel() }
            #expect(await eventually { wings.wings.map(\.id) == [world.work] })
            door.open()
            await door.listOpened()
            #expect(door.switcher.currentID == world.work)

            try await tombstoneWingAsSyncWould(db, world.work)
            #expect(await eventually { session.wing.currentID == "" },
                    "the dead wing returned the phone to Home")
            #expect(door.switcher.rows.map(\.id) == [""], "the dead wing's row left the open list")
            #expect(door.switcher.currentID == "", "Home is the marked row now")
            #expect(door.isOpen, "the list stays up")

            await door.pick(world.work)
            #expect(session.wing.currentID == "", "a dead wing is never stood in")
            #expect(door.landings == 0, "nothing landed")
            #expect(door.isOpen, "nothing changed, so the list stays")
            let line = try #require(session.status.current, "the door that did nothing says so")
            #expect(line.kind == .refusal)
            #expect(line.text == OpsRefusalCopy.sentence(
                for: OperationError.wingNotFound(id: world.work), roads: .phone))
            #expect(line.text == "That library isn't there any more \u{2014} nothing changed.",
                    "the table's existing sentence — no new words")
        }
    }

    /// One wing (P-55-15, PROVISIONAL): the name is still a door; the list
    /// opens with Home alone, marked, and its pick lands on Home's Bookcase.
    @Test func withOneWingTheListOpensWithHomeAlone() async throws {
        try await withEditorWorld { session, _ in
            let wings = MobileWingDoor.phoneWings(session)
            let door = MobileWingDoor(wings: wings)
            door.open()
            await door.listOpened()
            #expect(door.switcher.rows == [WingSwitcherBrain.Row(id: "", name: "Home")])
            #expect(door.switcher.currentID == "")
            await door.pick("")
            #expect(door.landings == 1)
            #expect(session.wing.currentID == "")
            #expect(!door.isOpen)
            #expect(session.status.current == nil)
            #expect(MobileWingTitle.name(of: wings) == "Home")
        }
    }

    /// P-55-18 (PROVISIONAL) on a REAL capture box: a draft typed on Home's
    /// Bookcase and not yet minted (the box mints after about a second) is
    /// filed IN HOME before the switch — it lands in Home's Pool and the box
    /// is empty in Work. Filed after the switch it would mint in Work, a wing
    /// she never typed it in.
    @Test func aSwitchFilesTheCaptureDraftInTheWingItWasWrittenIn() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let box = MobileQuickNoteModel(session: session)
            box.sleep = { _ in throw CancellationError() }  // the mint clock: off
            box.autosaveSleep = { _ in throw CancellationError() }
            box.text = "a thought from home"
            #expect(box.postID == nil, "not minted yet")
            let door = MobileWingDoor(
                wings: MobileWingDoor.phoneWings(session),
                fileCaptureFirst: { await box.fileOnLeaving() })
            door.open()
            await door.listOpened()
            await door.pick(world.work)
            #expect(session.wing.currentID == world.work)
            #expect(box.text.isEmpty, "the box is empty in Work")
            let filed = try await session.database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT c.id FROM container c
                    JOIN container_block cb ON cb.container_id = c.id AND cb.deleted_at IS NULL
                    JOIN variant v ON v.block_id = cb.block_id AND v.deleted_at IS NULL
                    WHERE c.deleted_at IS NULL AND v.working_text = ?
                    """, arguments: ["a thought from home"])
            }
            let note = try #require(filed.first, "the draft was filed")
            let wing = try await session.database.read { db in
                try Queries.effectiveWing(db, ofPost: note)
            }
            #expect(wing == "", "it lives in Home, where she wrote it")
        }
    }

    /// The door changes no letter of the line batch 1 drew: its three pieces,
    /// put together, are `VoiceTokens.path` over the same words (plus the
    /// Shelf's count), in both voices.
    @Test func theLineReadsTheSameWithItsDoor() {
        for voice in [ThemeVoice.terminal, .study] {
            let tokens = VoiceTokens.resolve(voice: voice, dark: false)
            for (wing, page, trailing) in [
                ("Home", "Library", ""), ("Work", MobileStarsModel.pageName, ""),
                ("Taxes 2025", "Shelf", tokens.chromeLabel("  ·  6 books")),
            ] {
                let parts = MobileWingTitle.doorParts(
                    tokens, wing: wing, page: page, trailing: trailing)
                #expect(parts.lead + parts.door + parts.rest
                        == tokens.path(MobileWingTitle.components(wing: wing, page: page)) + trailing)
                #expect(parts.door == tokens.chromeLabel(wing), "the door's piece is the name")
                #expect(String(MobileWingPath.title(parts, tokens: tokens).characters)
                        == parts.lead + parts.door + parts.rest, "the drawn title is those letters")
            }
        }
    }

    /// P-55-13's binding: nothing the door can put on a phone screen names a
    /// Mac door or key — its header, its one refusal, its close word.
    @Test func nothingTheDoorCanSayNamesAMacDoor() {
        let said = [
            WingWords.switcherHeader,
            OpsRefusalCopy.sentence(for: OperationError.wingNotFound(id: "x"), roads: .phone),
            "Done",
        ]
        for words in said {
            for mac in ["Mac", "unseal", "Delete Wing", "\u{23CE}", "\u{2318}", "esc ", "menu"] {
                #expect(!words.contains(mac), "\(words) names \(mac)")
            }
        }
        // The Mac's own header (its ▾ list says it); the Mac's `WingCopy`
        // forwards to this one declaration (pinned on the Mac side by
        // `VocabularySweepTests`).
        #expect(WingWords.switcherHeader == "Wings \u{2014} each a separate library")
    }
}

// MARK: - The door's target, on the real roots

@MainActor
@Suite("VM-225 — the wing door's target on each real root", .serialized)
struct MobileWingDoorGeometryTests {
    /// The smallest status-bar inset a supported phone has (a Home-button
    /// iPhone SE) — the strictest case for a target near the top. Fed to the
    /// real host as a safe-area inset, the way the device feeds it.
    static let statusBarInset: CGFloat = 20

    /// One root, measured: the door is found by the wing's name with a button
    /// trait; its target is at least 44 × 44, starts below the status bar's
    /// inset, and reaches no lower than the top of the first thing drawn under
    /// the line (the search field, the books, the first row); and pressing it
    /// fires the door. VM-55 ladder round 1, finding 7: the door's
    /// accessibility VALUE is the rest of the line as it is drawn (the page,
    /// and the Shelf's count) — so VoiceOver reads "Home, Library", as batch
    /// 1's plain line read the whole path (red on the tree before the fix,
    /// where the value is nil).
    private func measure<V: View>(
        _ surface: HostedSurface<V>, pressed: () -> Int, root: String, value: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        surface.host.additionalSafeAreaInsets.top = Self.statusBarInset
        await surface.settle(30)
        let elements = surface.visibleElements
        let door = try #require(
            elements.first {
                $0.accessibilityLabel == "Home" && $0.accessibilityTraits.contains(.button)
            },
            "\(root): no door named Home; labels were \(surface.visibleLabels)",
            sourceLocation: sourceLocation)
        #expect(door.accessibilityValue == value,
                "\(root): the door's value is \(door.accessibilityValue ?? "nil")",
                sourceLocation: sourceLocation)
        let frame = door.accessibilityFrame
        #expect(frame.height >= MobileWingDoorMetrics.minimumSide,
                "\(root): the target is \(frame.height) pt tall", sourceLocation: sourceLocation)
        #expect(frame.width >= MobileWingDoorMetrics.minimumSide,
                "\(root): the target is \(frame.width) pt wide", sourceLocation: sourceLocation)
        #expect(frame.minY >= Self.statusBarInset - 0.5,
                "\(root): the target starts at \(frame.minY), inside the status bar's inset",
                sourceLocation: sourceLocation)
        // Everything drawn under the line: elements wholly below the door's
        // text band (the line's middle), excluding the door itself.
        // (Same-line doors start about 19 pt into the line; anything starting
        // past three quarters of the target is drawn under the line.)
        let below = elements
            .map(\.accessibilityFrame)
            .filter { !$0.isEmpty && $0.minY > frame.minY + frame.height * 0.75 && $0 != frame }
        let firstBelow = try #require(below.map(\.minY).min(),
                                      "\(root): nothing measured under the line",
                                      sourceLocation: sourceLocation)
        #expect(frame.maxY <= firstBelow + 0.5,
                "\(root): the target reaches \(frame.maxY), into what starts at \(firstBelow)",
                sourceLocation: sourceLocation)
        let before = pressed()
        #expect(door.accessibilityActivate(), "\(root): the door is a real control",
                sourceLocation: sourceLocation)
        await surface.settle(5)
        #expect(pressed() == before + 1, "\(root): pressing it opened the list",
                sourceLocation: sourceLocation)
    }

    private static let study = VoiceTokens.resolve(voice: .study, dark: false)

    @Test func theStarredRootsDoor() async throws {
        try await withEditorWorld { session, _ in
            var presses = 0
            try await withHostedSurface(
                MobileStarredView(
                    stars: MobileStarsModel(session: session), tokens: Self.study,
                    wingName: "Home", onWingDoor: { presses += 1 },
                    tabBar: { EmptyView() }, onOpen: { _ in })
            ) { surface in
                try await measure(
                    surface, pressed: { presses }, root: "Starred", value: MobileStarsModel.pageName)
            }
        }
    }

    @Test func theShelfRootsDoor() async throws {
        try await withEditorWorld { session, _ in
            var presses = 0
            try await withHostedSurface(
                MobileShelfView(
                    model: MobileShelfViewModel(session: session),
                    stars: MobileStarsModel(session: session),
                    quickNote: MobileQuickNoteModel(session: session),
                    tokens: Self.study,
                    wingName: "Home", onWingDoor: { presses += 1 },
                    tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onSettings: {}, onOpenTrash: {})
            ) { surface in
                // The page and the count, as the line draws them (an empty
                // store: no books).
                try await measure(
                    surface, pressed: { presses }, root: "Shelf",
                    value: "Shelf" + Self.study.chromeLabel("  ·  0 books"))
            }
        }
    }

    @Test func theLibraryRootsDoor() async throws {
        try await withEditorWorld { session, _ in
            var presses = 0
            try await withHostedSurface(
                MobileLibraryView(
                    model: MobileLibraryViewModel(session: session),
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: MobileShelfViewModel(session: session),
                    tokens: Self.study,
                    wingName: "Home", onWingDoor: { presses += 1 },
                    tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                try await measure(surface, pressed: { presses }, root: "Library", value: "Library")
            }
        }
    }

    /// Without a door wired (every existing harness), the line is the single
    /// text batch 1 drew — no button carries the wing's name.
    @Test func withoutADoorTheLineIsPlainText() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
                MobileStarredView(
                    stars: MobileStarsModel(session: session), tokens: Self.study,
                    wingName: "Home", tabBar: { EmptyView() }, onOpen: { _ in })
            ) { surface in
                await surface.settle(10)
                #expect(!surface.visibleElements.contains {
                    $0.accessibilityLabel == "Home" && $0.accessibilityTraits.contains(.button)
                })
                // The line as the voice draws it (Study "Home · Starred",
                // Terminal "~/home/starred") — never a literal in one voice.
                let line = Self.study.path(MobileWingTitle.components(
                    wing: "Home", page: MobileStarsModel.pageName))
                #expect(surface.visibleLabels.contains { $0.contains(line) },
                        "labels were \(surface.visibleLabels)")
            }
        }
    }
}

// MARK: - The list, hosted

@MainActor
@Suite("VM-225 — the wing door's plain list", .serialized)
struct MobileWingListSheetTests {
    /// The list as drawn: the Mac's header, the rows in the switcher's order
    /// as real buttons, the current one marked (selected); pressing a row
    /// switches and lands.
    @Test func theListsRowsAreTheWingsInOrderAndARowPressLands() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let door = MobileWingDoor(wings: MobileWingDoor.phoneWings(session))
            door.open()
            let tokens = VoiceTokens.resolve(voice: .study, dark: false)
            await withHostedSurface(
                MobileWingListSheet(door: door, tokens: tokens)
            ) { surface in
                // The sheet's own read (its `.task`) fills it.
                #expect(await eventually { door.switcher.rows.count == 2 })
                await surface.settle(10)
                // The header as the sheet's voice draws it (never the bare
                // constant — a Terminal sheet lowercases it).
                #expect(surface.visibleLabels.contains(tokens.chromeLabel(WingWords.switcherHeader)),
                        "labels were \(surface.visibleLabels)")
                let rows = surface.visibleElements.filter {
                    ["Home", "Work"].contains($0.accessibilityLabel ?? "")
                        && $0.accessibilityTraits.contains(.button)
                }
                #expect(rows.compactMap(\.accessibilityLabel) == ["Home", "Work"],
                        "Home first, then the wings")
                #expect(rows.first?.accessibilityTraits.contains(.selected) == true,
                        "the current wing is marked")
                #expect(rows.last?.accessibilityTraits.contains(.selected) == false)
                for row in rows {
                    let height = row.accessibilityFrame.height
                    #expect(height >= MobileWingDoorMetrics.minimumSide, "a row is \(height) pt tall")
                }

                #expect(surface.activate("Work"), "a row is a real button")
                #expect(await eventually { session.wing.currentID == world.work })
                #expect(door.landings == 1)
                #expect(!door.isOpen)
            }
        }
    }
}

// MARK: - The whole road, on the mounted shell

@MainActor
@Suite("VM-225 — the wing door on the mounted shell", .serialized)
struct MobileWingDoorShellTests {
    /// From the LIBRARY root: the name opens the list (a real sheet), a row
    /// press switches to Work and lands on the Shelf (the phone's Bookcase),
    /// whose books are Work's; the roots' titles say Work.
    @Test func fromTheLibraryAPickLandsOnTheWingsBookcase() async throws {
        try await withEditorWorld { session, _ in
            let world = try TwoWingWorld.make(session)
            let router = MobileShellRouter()
            await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate("Library"), "labels were \(surface.visibleLabels)")
                await surface.settle(30)
                #expect(surface.element(labeled: "Library")?.accessibilityTraits
                    .contains(.selected) == true, "on the Library root")

                #expect(surface.activate("Home"), "the name is a door; labels were \(surface.visibleLabels)")
                await surface.settle(30)
                #expect(surface.host.presentedViewController != nil, "the list is up")
                // The header as the shell's VOICE draws it (Terminal lowercases
                // chrome — the window's red at 5c80d058b compared the unvoiced
                // words); the doors' labels are names, never voiced.
                let voiced = VoiceTokens.resolve(voice: router.voice, dark: false)
                    .chromeLabel(WingWords.switcherHeader)
                #expect(surface.visibleLabels.contains(voiced),
                        "labels were \(surface.visibleLabels)")

                #expect(surface.activate("Work"), "labels were \(surface.visibleLabels)")
                #expect(await eventually { session.wing.currentID == world.work })
                await surface.settle(40)
                #expect(surface.host.presentedViewController == nil, "the list went")
                #expect(surface.elements(selected: "Shelf"), "landed on the Bookcase")
                #expect(surface.visibleElements.contains {
                    $0.accessibilityLabel == "Work" && $0.accessibilityTraits.contains(.button)
                }, "the title names the wing; labels were \(surface.visibleLabels)")
                #expect(session.status.current == nil, "no line for a switch")
            }
        }
    }
}

/// A counter a `@MainActor` closure can bump (a captured `var` cannot be
/// mutated from a sendable closure).
@MainActor
private final class Tally {
    var count = 0
}

private extension HostedSurface {
    /// Every rendered copy of a tab door is selected (each root wears its own
    /// bar; only the visible root's copies are on screen).
    func elements(selected label: String) -> Bool {
        let doors = visibleElements.filter { $0.accessibilityLabel == label }
        return !doors.isEmpty && doors.allSatisfy { $0.accessibilityTraits.contains(.selected) }
    }
}
