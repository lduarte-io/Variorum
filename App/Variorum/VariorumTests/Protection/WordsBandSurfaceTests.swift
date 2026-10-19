//
//  WordsBandSurfaceTests.swift
//  VariorumTests — VX-307 U2b pieces 4 and 5 (VX-412): THE MAC FACES of the twelve words, her way — hosted in a real
//  window (a face that crashes or cannot lay out fails here) in every state, and the composition pinned by source:
//  the card sits BETWEEN the shelf listing and the quick-entry line (her drawing), rule 3's reminder left the bottom
//  bar for the card (its one home), the look's face has no raw pasteboard road, never a popup, and no Return shortcut
//  that could put the once-shown words away; the tour's last card carries the two asks on the new road and is exactly
//  as it was without them. The logic is the models' (`WordsBandTests`, headless); this suite pins the composition.
//  Mac only (hosting and the app's source tree).
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-307 U2b — the twelve words' Mac faces (hosted) and their composition", .serialized)
struct WordsBandSurfaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (comments dropped — they narrate the internals legitimately).
    private static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//") && !line.hasPrefix("///")
        }.joined(separator: "\n")
    }

    private func standing(_ world: PlantedBand, band: WordsBandModel) -> RoadStandingModel {
        RoadStandingModel(
            faces: .none, reminder: band.reminder, setPassphrase: { _ in .set },
            passphraseExists: { world.passphrase != nil }, receiptsOwed: { [] }, band: band,
            mintWords: { _ in .minted((1...12).map { "word\($0)" }) }, copyWords: { world.copies.append($0) })
    }

    /// The card hosts in each state: the offer, the reminder folded beside it, the look asking, the words shown, the
    /// warning — and nothing at all once there is nothing to say.
    @Test func theCardHostsInEveryState() async {
        let world = PlantedBand()
        let reminder = world.reminder(moment: .beforeFirstBackup)
        reminder.evaluate()
        let band = world.band(reminder: reminder)
        let standing = standing(world, band: band)
        func host() async {
            await SurfaceComposition.host(
                WordsBandCard(standing: standing, band: band, direct: { _ in }), size: NSSize(width: 900, height: 420))
        }
        await host()  // the offer + the reminder
        await band.look.open()
        #expect(band.look.phase == .shown)
        await host()  // the words, once
        band.look.copy()
        band.look.writtenDown()
        await host()  // the warning
        band.look.close()
        await reminder.notNow()
        #expect(!band.visible)
        await host()  // nothing to say: nothing drawn
        world.passphrase = "set"
        let asking = world.band()
        await asking.look.open()
        #expect(asking.look.phase == .asking)
        await SurfaceComposition.host(
            WordsBandCard(standing: self.standing(world, band: asking), band: asking, direct: { _ in }),
            size: NSSize(width: 900, height: 300))
    }

    /// The ✕ speaks its toast through the host's direction door (always shown — her "toast … look in Settings,
    /// Protection"), and the shell's door is the status seam's `direct`, never a receipt (which `receipt_style` may hide).
    @Test func theCrossSpeaksTheToastThroughTheDirectionDoor() throws {
        let card = try Self.code("Variorum/Features/Protection/WordsBandCard.swift")
        #expect(card.contains("if let toast = band.dismiss() { direct(toast) }"))
        let root = try Self.code("Variorum/RootView.swift")
        #expect(root.contains("direct: { session.status.direct($0) }"))
    }

    /// The tour's last card: with the two asks (the new road) and without (today's road) — both host; the doors wait
    /// while the words are on screen.
    @Test func theToursLastCardHostsWithAndWithoutTheTwoAsks() async throws {
        let tokens = VoiceTokens.fallback(for: .light)
        await SurfaceComposition.host(
            TourEndCard(tokens: tokens, scheme: .light, readmeExists: true) { _ in },
            size: NSSize(width: 520, height: 520))
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let standing = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes())
        let library = TourEndLibraryModel(standing: standing)
        await SurfaceComposition.host(
            TourEndCard(tokens: tokens, scheme: .light, readmeExists: true, library: library) { _ in },
            size: NSSize(width: 520, height: 900))
        await library.showWords()
        #expect(library.holdsTheDoors)
        await SurfaceComposition.host(
            TourEndCard(tokens: tokens, scheme: .dark, readmeExists: false, library: library) { _ in },
            size: NSSize(width: 520, height: 900))
    }

    /// Settings ▸ Protection's words section hosts (the door the ✕'s toast names).
    @Test func theSettingsSectionHosts() async {
        let world = PlantedBand()
        let band = world.band()
        await SurfaceComposition.host(
            Form { WordsLookSection(standing: standing(world, band: band)) }.formStyle(.grouped),
            size: NSSize(width: 640, height: 400))
    }

    // MARK: The composition, by source

    /// Her drawing: the card sits between the shelf listing and the quick-entry line — the board's ScrollView, then the
    /// band, then the entry bar — and the shell hands the Bookcase the card.
    @Test func theCardSitsBetweenTheListingAndTheQuickEntry() throws {
        let shelf = try Self.code("Variorum/Features/Shelf/ShelfView.swift")
        let body = try #require(shelf.range(of: "var body: some View {"))
        let tail = shelf[body.upperBound...]
        let listing = try #require(tail.range(of: "ScrollView {"))
        let band = try #require(tail.range(of: "if let wordsBand {"))
        let entry = try #require(tail.range(of: "entryBar\n"))
        #expect(listing.upperBound < band.lowerBound && band.upperBound < entry.lowerBound,
                "the listing, then the card, then the quick entry")
        let root = try Self.code("Variorum/RootView.swift")
        #expect(root.contains("wordsBand: wordsBand,"), "the shell hands the Bookcase the card")
        #expect(root.contains("WordsBandCard(standing:"))
    }

    /// Rule 3's one home: the bottom bar no longer renders the reminder; the card does.
    @Test func theReminderLeftTheBottomBarForTheCard() throws {
        let bar = try Self.code("Variorum/Features/Protection/ProtectionRoadBar.swift")
        for word in ["reminderLine", "reminderSetDoor", "reminderNotNow", "reminderDontShowAgain", "SetPassphraseSheet"] {
            #expect(!bar.contains(word), "the bottom bar still names \(word)")
        }
        let card = try Self.code("Variorum/Features/Protection/WordsBandCard.swift")
        for word in ["ProtectionWords.reminderLine", "ProtectionWords.reminderSetDoor", "ProtectionWords.reminderNotNow",
                     "ProtectionWords.reminderDontShowAgain"] {
            #expect(card.contains(word), "the card carries \(word)")
        }
    }

    /// The look's face: the words never selectable and privacy-sensitive; the clipboard only through the model's road
    /// (the bootstrap's `WordsClipboard` — 60 s); never a popup; no Return shortcut puts the words away.
    @Test func theLookFaceHasOneCopyRoadNoPopupAndNoReturnShortcut() throws {
        let card = try Self.code("Variorum/Features/Protection/WordsBandCard.swift")
        #expect(card.contains(".textSelection(.disabled)") && card.contains(".privacySensitive()"))
        for road in ["NSPasteboard", "UIPasteboard", ".textSelection(.enabled)", "keyboardShortcut", ".popover(",
                     ".alert(", ".confirmationDialog("] {
            #expect(!card.contains(road), "the words' faces name \(road)")
        }
        #expect(card.contains("look.copy()"), "Copy runs the model's road")
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("WordsClipboard.copy(words)"), "the one clipboard rule (decision 23)")
    }

    /// The retired creation card: the Mac's face is gone, and the Mac never lands on its state.
    @Test func theMacsCreationCardFaceIsRetired() {
        let face = Self.appRoot.appendingPathComponent("Variorum/Features/Protection/LibraryWordsCard.swift")
        #expect(!FileManager.default.fileExists(atPath: face.path))
        #expect(!ProtectionRoad.showsWordsAtCreation)
    }
}
