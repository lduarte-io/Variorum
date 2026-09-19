//
//  DoorSetTests.swift
//  VariorumTests
//
//  Phase 13e, batch 1 — THE DOOR SET's Mac-side pins:
//  **E1** (callout colour swatches + the system emoji picker),
//  **E13** (the duplicate-book-name refusal at every door that names a book),
//  **E11** (the book ascent, declared in the capability registry).
//
//  E13's core half — the pure `BookNaming` rule and the store-truthful
//  `assertBookNameIsFree` read the doors consult — is pinned in
//  `VariorumCoreTests/BookNameGuardTests.swift`.
//

import AppKit
import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The house store harness (each suite file keeps its own — the
/// `WalkBuildRoundTests` / `NodSetTests` pattern).
@MainActor
private func withStore<T>(
    _ body: @MainActor (AppDatabase, AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(db, AppSession(database: db))
    }
}

// MARK: - E13: the duplicate-book-name refusal, at the doors

/// Her ruling (13e kickoff sitting, round 3): the create/rename DOORS refuse
/// a case-insensitive match against any LIVE book's name, with honest
/// wording. Door-level by her explicit word — no schema, no operation-level
/// invariant, no SyncSpec §7 repair.
@MainActor
@Suite("E13 — duplicate book names refuse at the door (13e)")
struct DuplicateBookNameDoorTests {
    private func names(_ db: AppDatabase) async throws -> [String] {
        try await db.read { try Queries.readings($0) }.map(\.name)
    }

    /// **RED on the pre-13e code**, where `ReadingsViewModel.create` called
    /// `createReading` and nothing else.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `assertBookNameIsFree` line
    /// from `ReadingsViewModel.create` and this test fails at its first two
    /// expectations — the second book is created and `lastError` stays nil,
    /// leaving TWO books named "Ideas" (the exact state 13k K4 surfaced).
    @Test func theShelfsNewBookDoorRefusesANameAlreadyTaken() async throws {
        try await withStore { db, session in
            let readings = ReadingsViewModel(session: session)
            _ = try #require(await readings.create(name: "Ideas", kind: .curated))

            // Case-insensitively, and across KINDS — the curated/smart
            // "Ideas" pair is the one she named.
            let refused = await readings.create(name: "ideas", kind: .smart)
            #expect(refused == nil, "the door refuses rather than minting")
            #expect(readings.lastError == BookNameCopy.refusal(existing: "Ideas"))
            #expect(try await names(db) == ["Ideas"], "nothing was written")

            // Ends-trimmed, so " IDEAS " is the same name…
            #expect(await readings.create(name: "  IDEAS  ", kind: .curated) == nil)
            // …and a genuinely different name still goes through, clearing
            // the door's error line behind it.
            _ = try #require(await readings.create(name: "Ideas 2", kind: .curated))
            #expect(readings.lastError == nil)
            #expect(try await names(db).sorted() == ["Ideas", "Ideas 2"])
        }
    }

    /// The RENAME half — and the corner that makes `excluding:` load-bearing:
    /// a book may always be renamed to the name it already wears, casing
    /// included.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `assertBookNameIsFree` line
    /// from `ReadingsViewModel.rename` and the second expectation fails —
    /// "Orbit" is renamed to "ideas" and the shelf holds two.
    @Test func theShelfsRenameDoorRefusesAnotherBooksNameButNeverItsOwn() async throws {
        try await withStore { db, session in
            let readings = ReadingsViewModel(session: session)
            _ = try #require(await readings.create(name: "Ideas", kind: .curated))
            let orbit = try #require(await readings.create(name: "Orbit", kind: .curated))

            await readings.rename(orbit, to: "ideas")
            #expect(readings.lastError == BookNameCopy.refusal(existing: "Ideas"))
            #expect(try await names(db).sorted() == ["Ideas", "Orbit"], "nothing was written")

            // Its own name, and its own name recased: both legal.
            await readings.rename(orbit, to: "Orbit")
            #expect(readings.lastError == nil)
            await readings.rename(orbit, to: "ORBIT")
            #expect(readings.lastError == nil)
            #expect(try await names(db).sorted() == ["ORBIT", "Ideas"].sorted())
        }
    }

    /// The book's OWN door (the navigator's rename) carries the same guard —
    /// a rule enforced at one of two doors is not a rule.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `assertBookNameIsFree` line
    /// from `BookStructureModel.rename` and the refusal expectations fail.
    @Test func theNavigatorsRenameDoorCarriesTheSameGuard() async throws {
        try await withStore { db, session in
            let (ideas, orbit) = try await session.runner.run { ops -> (String, String) in
                (try ops.createReading(name: "Ideas", kind: .curated).id,
                 try ops.createReading(name: "Orbit", kind: .curated).id)
            }
            let structure = BookStructureModel(session: session, readingID: orbit)

            await structure.rename(to: "IDEAS")
            #expect(structure.lastError == BookNameCopy.refusal(existing: "Ideas"))
            #expect(try await names(db).sorted() == ["Ideas", "Orbit"])

            await structure.rename(to: "Orbit Two")
            #expect(structure.lastError == nil)
            #expect(try await names(db).sorted() == ["Ideas", "Orbit Two"])
            _ = ideas
        }
    }

    /// The conversion offer's FRESH COLLECTOR field is a book she names, so
    /// it is guarded — and the DERIVED default ("<book> (collecting)") is
    /// deliberately not, because a name the app computed is not "purposefully"
    /// naming two books the same thing (her ruling's own words).
    ///
    /// DISCRIMINATING REVERT (verified): drop the `assertBookNameIsFree` line
    /// from `ShelfViewModel.convertToCurated` and the first half's refusal
    /// expectations fail — the conversion runs and a second "Ideas" is minted.
    @Test func theConversionsTypedCollectorNameIsGuardedAndTheDerivedOneIsNot() async throws {
        try await withStore { db, session in
            let (smart, _) = try await session.runner.run { ops -> (String, String) in
                let smart = try ops.createReading(name: "Starred", kind: .smart)
                let taken = try ops.createReading(name: "Ideas", kind: .curated)
                return (smart.id, taken.id)
            }
            let shelf = ShelfViewModel(session: session)

            await shelf.convertToCurated(smart, keepCollecting: true, collectingName: "ideas")
            #expect(shelf.lastError == BookNameCopy.refusal(existing: "Ideas"))
            #expect(shelf.lastReport == nil)
            // The whole compound refused — the smart book is still smart.
            var kinds = try await db.read { try Queries.readings($0) }
                .filter { $0.id == smart }.map(\.kind)
            #expect(kinds == [.smart], "a refused name changes nothing")

            // The derived name goes through untouched.
            await shelf.convertToCurated(smart, keepCollecting: true, collectingName: nil)
            #expect(shelf.lastError == nil)
            kinds = try await db.read { try Queries.readings($0) }
                .filter { $0.id == smart }.map(\.kind)
            #expect(kinds == [.curated])
            #expect(try await names(db).contains("Starred (collecting)"))
        }
    }
}

// MARK: - E1: the callout colour swatches

/// Her A13(b) ask: *colour swatches + a real emoji picker*. The swatch is a
/// RENDERING of a palette token name (AppSpec §7 / R1 — the stored value is
/// never a colour), built once in `CalloutMenu` and drawn by all three
/// callout doors.
@MainActor
@Suite("E1 — callout colour swatches (13e)")
struct CalloutSwatchTests {
    /// The one vocabulary carries the token name; only the five colour rows
    /// do. Remove Callout deliberately has none — it takes a frame away
    /// rather than choosing a colour.
    @Test func onlyTheColourRowsCarryASwatchToken() {
        let rows = CalloutMenu.rows.filter { !$0.isSeparator }
        #expect(rows.compactMap(\.swatch) == CalloutPalette.names)
        #expect(rows.first { $0.title == "Toggle Callout" }?.swatch == nil)
        #expect(rows.first { $0.title == "Remove Callout" }?.swatch == nil)
        #expect(rows.first(where: \.promptsForEmoji)?.swatch == nil)
        // The WORDS are untouched — a swatch joins the colour's name, it does
        // not replace it (R93's legibility mandate, and what keeps the K6
        // drift pin comparing identical titles across the three renderers).
        #expect(CalloutMenu.rowTitles.contains("Green"))
    }

    /// **RED on the pre-13e code**, where the shared builder set no image at
    /// all — this expectation reads `NSMenuItem.image`, which has existed all
    /// along, so it fails by assertion rather than by compilation.
    ///
    /// DISCRIMINATING REVERT (verified): drop the `if let swatch = row.swatch`
    /// image line from `CalloutMenu.menuItem` and every `#require` below fails
    /// — the rows render with words and no chips.
    @Test func theSharedMenuBuilderDrawsASwatchOnEveryColourRow() throws {
        let item = CalloutMenu.menuItem { _ in }
        let submenu = try #require(item.submenu)
        let rows = submenu.items.filter { !$0.isSeparatorItem }

        for name in CalloutPalette.names {
            let row = try #require(rows.first { $0.title == name.capitalized })
            let image = try #require(row.image, "\(name) renders its swatch")
            #expect(image.size == NSSize(width: 14, height: 14))
            #expect(!image.isTemplate, "a template image would be tinted, not coloured")
            #expect(image.accessibilityDescription == name)
        }
        // …and nothing else grows one.
        for title in ["Toggle Callout", "Emoji\u{2026}", "Remove Callout"] {
            #expect(rows.first { $0.title == title }?.image == nil)
        }
    }

    /// The centre pixel of a drawn image, in whatever space the drawing
    /// context used.
    private func centrePixel(_ image: NSImage) throws -> NSColor {
        let data = try #require(image.tiffRepresentation)
        let rep = try #require(NSBitmapImageRep(data: data))
        return try #require(rep.colorAt(x: rep.pixelsWide / 2, y: rep.pixelsHigh / 2))
    }

    /// A flat reference chip, drawn through the SAME `NSImage` path the swatch
    /// uses so both land in the same colour space. Comparing the swatch to a
    /// fixed sRGB triple instead would compare across a profile hop and shift
    /// every channel by a few percent (measured on this machine: up to 0.054
    /// — which is why this reference exists rather than a tolerance wide
    /// enough to accept a genuinely wrong colour).
    private func reference(_ color: NSColor, size: CGFloat) -> NSImage {
        NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            color.setFill()
            rect.fill()
            return true
        }
    }

    private func same(_ a: NSColor, _ b: NSColor) -> Bool {
        abs(a.redComponent - b.redComponent) < 0.01
            && abs(a.greenComponent - b.greenComponent) < 0.01
            && abs(a.blueComponent - b.blueComponent) < 0.01
    }

    /// The chip is the PALETTE's colour, resolved per appearance — not a
    /// second source of truth. Read out of the drawn bitmap, because "it uses
    /// `CalloutPalette`" is only a claim until the pixels agree.
    @Test func theSwatchPaintsThePalettesOwnColourPerAppearance() throws {
        for name in CalloutPalette.names {
            for dark in [false, true] {
                let drawn = try centrePixel(
                    CalloutMenu.swatchImage(for: name, dark: dark, size: 20))
                let expected = try centrePixel(
                    reference(CalloutPalette.color(name, dark: dark), size: 20))
                #expect(same(drawn, expected), "\(name)/\(dark ? "dark" : "light")")
            }
        }
        // And the two inputs really are inputs: a different token, and the
        // same token under the other appearance, paint differently.
        let sandLight = try centrePixel(CalloutMenu.swatchImage(for: "sand", dark: false, size: 20))
        let roseLight = try centrePixel(CalloutMenu.swatchImage(for: "rose", dark: false, size: 20))
        let sandDark = try centrePixel(CalloutMenu.swatchImage(for: "sand", dark: true, size: 20))
        #expect(!same(sandLight, roseLight))
        #expect(!same(sandLight, sandDark))
    }

    /// **RED on the pre-13e code** by compilation (`MenuItemSpec` had no
    /// `image`): a pane's context menu — the take card's door — carries the
    /// spec's image through to the real `NSMenuItem`.
    ///
    /// DISCRIMINATING REVERT (verified): drop `menuItem.image = spec.image`
    /// from `PaneTextView.makeMenuItem` and the two `#require`s below fail
    /// while everything else about the menu still works.
    @Test func aPaneMenuSpecCarriesItsSwatchThroughToTheItem() throws {
        let view = PaneTextView(frame: NSRect(x: 0, y: 0, width: 300, height: 120))
        view.variorumMenu = {
            [.init(
                title: CalloutMenu.title,
                children: CalloutMenu.rows.compactMap { row in
                    guard !row.isSeparator, row.edit != nil else { return nil }
                    return .init(
                        title: row.title, action: {},
                        image: row.swatch.map { CalloutMenu.swatchImage(for: $0) })
                })]
        }
        let event = NSEvent.mouseEvent(
            with: .rightMouseDown, location: NSPoint(x: 10, y: 10),
            modifierFlags: [], timestamp: 0, windowNumber: 0, context: nil,
            eventNumber: 0, clickCount: 1, pressure: 1)!
        let menu = try #require(view.menu(for: event))
        let callout = try #require(menu.items.first { $0.title == CalloutMenu.title })
        let rows = try #require(callout.submenu).items
        let green = try #require(rows.first { $0.title == "Green" })
        #expect(green.image != nil, "the card's colour row wears its chip")
        #expect(rows.first { $0.title == "Remove Callout" }?.image == nil)
    }
}

// MARK: - E1: the real emoji picker

/// The second half of her A13(b) ask. The picker is the system's own
/// (`orderFrontCharacterPalette`) behind an ACCESSORY button — an `NSAlert`
/// button would end the modal session and dismiss the prompt the picked glyph
/// is meant to land in.
@MainActor
@Suite("E1 — the callout emoji picker (13e)")
struct CalloutEmojiPickerTests {
    /// **RED on the pre-13e code** by compilation (the prompt built a bare
    /// `NSTextField` inline and had no picker door at all).
    ///
    /// DISCRIMINATING REVERT (verified): drop the button from
    /// `CalloutMenu.emojiAccessory` and this fails at its `#require` — the
    /// accessory is a field alone, which is exactly the pre-13e prompt.
    @Test func theAccessoryOffersTheSystemPickerBesideTheField() {
        let accessory = CalloutMenu.emojiAccessory { _ in }
        #expect(accessory.pickerButton.title == CalloutMenu.emojiPickerButtonTitle)
        #expect(accessory.pickerButton.title == "Emoji & Symbols\u{2026}")
        #expect(accessory.pickerButton.target != nil, "the door has somewhere to go")
        #expect(accessory.pickerButton.action != nil)
        // The field is still there, and still typeable/pasteable — the picker
        // is an ADDITION, never a replacement (she may know the glyph).
        #expect(accessory.view.subviews.contains { $0 === accessory.field })
        #expect(accessory.view.subviews.contains { $0 === accessory.pickerButton })
    }

    /// Pressing it opens the picker AT THE FIELD — the insertion target is
    /// what makes a picked glyph land in the prompt instead of nowhere.
    /// Driven through the real `NSButton` target, which is where the
    /// trampoline pattern's retention could silently fail.
    @Test func pressingItOpensThePickerAtTheField() throws {
        var opened: [NSTextField] = []
        let accessory = CalloutMenu.emojiAccessory { opened.append($0) }
        let button = accessory.pickerButton
        _ = button.target?.perform(button.action, with: button)
        #expect(opened.count == 1, "the trampoline is retained and fires")
        #expect(opened.first === accessory.field)
    }

    /// **THE FIELD HAS ROOM TO TYPE IN** — 17p batch b, row 4 (her report:
    /// *"the callout pane is broken"*, image 9).
    ///
    /// **The traced mechanism:** the accessory is an `NSStackView`, which
    /// lays its arranged subviews out by INTRINSIC SIZE and priorities and
    /// discards the frame each was constructed with — so the
    /// `NSTextField(frame: 200 × 24)` above was never 200 wide. An EMPTY
    /// editable field's intrinsic width is next to nothing, and the button's
    /// title gives IT a real one, so the stack spent its width on the button
    /// and left the field the sliver in her screenshot.
    ///
    /// Measured in a real window, because "how wide is it" is a layout
    /// question and an unlaid-out stack answers with its construction frame.
    @Test func theEmojiFieldHasRoomToTypeIn() {
        let accessory = CalloutMenu.emojiAccessory { _ in }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        window.contentView?.addSubview(accessory.view)
        accessory.view.layoutSubtreeIfNeeded()

        // RED ON OLD (measured): the field was **0.0 pt** wide here — the
        // whole of her image 9 — while every other expectation below already
        // passed, i.e. the button kept its size and the stack its 320.
        #expect(accessory.field.frame.width >= CalloutMenu.emojiFieldMinWidth,
                "the field is typeable — it gets the 200 it asks for: \(accessory.field.frame)")
        // …and the picker door beside it keeps its own size — a fix that
        // squeezed the button would have moved the defect, not ended it.
        #expect(accessory.pickerButton.frame.width >= 80,
                "the picker door still reads: \(accessory.pickerButton.frame)")
        // The accessory ASKS for room enough for both, so `NSAlert` gives it
        // room: a stack whose own frame is narrower than its content is how
        // one of the two gets squeezed whatever the constraints say.
        #expect(accessory.view.frame.width
            >= accessory.field.frame.width + accessory.pickerButton.frame.width,
                "the accessory is as wide as what it holds: \(accessory.view.frame)")
        // Both inside their host, neither clipped.
        #expect(accessory.view.frame.width >= CalloutMenu.emojiAccessoryMinWidth,
                "never below the shipped 320: \(accessory.view.frame)")
        #expect(accessory.field.frame.minX >= -0.5)
        #expect(accessory.pickerButton.frame.maxX <= accessory.view.frame.width + 0.5)
        // And typing lands: the field is editable and the prompt reads it
        // back (`promptEmoji` returns `firstGrapheme(accessory.field
        // .stringValue)` since her R-13u3-4 — the guard is pinned in
        // `ProseGutterTests.aLeadingGlyphIsExactlyOneGrapheme`).
        #expect(accessory.field.isEditable)
        accessory.field.stringValue = "\u{1f4a1}"
        #expect(accessory.field.stringValue == "\u{1f4a1}")
    }

    /// The prompt's own contract is unchanged (K6's letter): the answer is the
    /// field's string, an EMPTY string is a real answer ("no glyph"), and only
    /// cancellation is nil. Pinned at the transform the answer flows into, the
    /// one part of a modal prompt a test can reach.
    @Test func anEmptyAnswerIsStillARealAnswer() {
        let framed = BlockPresentation(color: "sand", emoji: "\u{1f4a1}")
        #expect(CalloutEditRule.apply(.emoji(""), to: framed)?.emoji == nil)
        #expect(CalloutEditRule.apply(.emoji(""), to: framed)?.color == "sand")
        #expect(CalloutEditRule.apply(.emoji("\u{2728}"), to: framed)?.emoji == "\u{2728}")
    }
}

// MARK: - E11: the book ascent, declared

/// P-1 hygiene, and her word (2026-08-02): *"the registry should be kept up
/// to date, and keeping the registry up to date should be part of the plan."*
/// The act has worked since Phase 13; **nothing user-visible changes here** —
/// which is why the behaviour pins below are expected to pass on BOTH sides of
/// the change. That is the deliverable's own claim (#55(i)'s "declaring must
/// not change shipped behaviour"), and a pin that went red would be the bug.
@MainActor
@Suite("E11 — the book ascent is declared (13e)")
struct BookAscentDeclarationTests {
    private func book(_ name: String) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(id: name, name: name, kind: .curated, createdAt: now, updatedAt: now)
    }

    private func bar(books: [Reading]) -> ContextBar {
        ContextBar(
            tokens: .fallback(for: .light), originLabel: nil, forwardLabel: nil,
            books: books, isNote: true,
            onBack: {}, onForward: {}, onOpenBook: { _ in })
    }

    @Test func theAscentIsDeclaredOnceWithItsDoorAndItsRefusal() {
        let capability = CapabilityRegistry.capability(.openBookAtNote)
        #expect(capability.verb == "Open Book at This Note")
        #expect(capability.scope == .book)
        #expect(capability.doors == [.surface])
        #expect(capability.shortcutLabel == nil, "her ruling named no chord")
        #expect(!capability.unavailableNote.isEmpty, "#55(i)'s written refusal")
        #expect(capability.unavailableNote == WorkspaceNaming.ascentUnavailableNote)
    }

    /// The availability rule IS the shipped face: a note in a book can ascend,
    /// a bookless note's door is grey (her #55(b)/(g) ruling — visible and
    /// greyed with a tooltip, never hidden).
    @Test func theAvailabilityRuleMatchesTheShippedGreyDoor() {
        #expect(CapabilityRegistry.availability(
            .openBookAtNote, in: CapabilityContext(canAscendToBook: true)) == .act)
        #expect(!CapabilityRegistry.isEnabled(
            .openBookAtNote, in: CapabilityContext(canAscendToBook: false)))
    }

    /// …and the bar's own door now READS that rule instead of re-deriving it
    /// (P-1: gating is data). Byte-identical to the shipped `!books.isEmpty`,
    /// which is the point.
    @Test func theBarsBookDoorIsGatedByTheRegistry() {
        #expect(bar(books: [book("Orbit")]).bookEnabled)
        #expect(!bar(books: []).bookEnabled)
        // The row itself is unchanged: a bookless NOTE still renders all four
        // icons, the book one among them (13k K11's constant row).
        #expect(bar(books: []).renderedIcons.contains(.book))
    }

    /// Both renderers of the one act declare it, named explicitly so a future
    /// edit that drops one fails with its name rather than by set arithmetic
    /// (the `bothTextSurfacesDeclareTheDoorTheyRender` pattern).
    @Test func bothSurfacesDeclareTheAscentTheyRender() {
        #expect(ContextBar.surfaceCapabilities.contains(.openBookAtNote))
        #expect(MembershipChip.surfaceCapabilities.contains(.openBookAtNote))
        #expect(CapabilityRegistry.doored(.surface).contains(.openBookAtNote))
    }
}
