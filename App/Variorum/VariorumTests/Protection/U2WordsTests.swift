//
//  U2WordsTests.swift
//  VariorumTests — VX-309 U2: THE WORDS UNIT's lines, pinned AS DRAFTED (every line here is PROVISIONAL — hers at the bundle —
//  unless it is her own sentence, which is pinned against where she said it). One file so the unit's words live together
//  and her pass can read them in one place. Pure; also runs headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U2 — the words unit's lines, as drafted")
@MainActor
struct U2WordsTests {
    /// A label as a sentence names it (the door's trailing ellipsis dropped).
    static func named(_ door: String) -> String {
        door.hasSuffix("\u{2026}") ? String(door.dropLast()) : door
    }

    /// Her no-shouty-caps rule ("I hate unnecessary caps"): no word in capitals but the platform's own.
    static func shouts(_ line: String) -> [Substring] {
        line.split(whereSeparator: { !$0.isLetter }).filter { word in
            word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
        }
    }

    // MARK: - Piece 3 — Move's not-yet line names the road (her ruling, 2026-10-19)

    /// RED ON OLD: "isn't ready in this build yet" said nothing she could do. The line names the road as the faces stand —
    /// This Mac Only renders only while signed out — in the doors' own names, and what the set-up does (rule 7's hand-up).
    @Test func moveNotYetNamesTheRoad() {
        let line = ProtectionWords.moveNotYet
        #expect(!line.contains("isn't ready"), "a road, not a not-yet")
        #expect(line == "To move this library to that account, sign out, choose Use this \(ProtectionCopy.deviceName) "
            + "only, then sign back in to that account and turn on sync. This library's passphrase and twelve words "
            + "become that account's.")
        #expect(line.contains(Self.named(ProtectionWords.thisMacOnlyDoor)), "This Mac Only by its own name")
        #expect(line.lowercased().contains(Self.named(ProtectionWords.turnOnSyncDoor).lowercased()))
        #expect(line.lowercased().contains(Self.named(ProtectionWords.accountSignOutDoor).lowercased()))
        #expect(Self.shouts(line).isEmpty)
    }

    // MARK: - Piece 4 — VX-264 item 5: her "older libraries" words where they're counted and deleted (#216)

    /// Her ruled sentences (QUESTIONS #216, VX-203's wording, verbatim): "…plus 2 older libraries Variorum kept when you
    /// opened or restored a different one." and "Those older libraries are your way back to what you had before — delete
    /// them only if you won't want them back."
    static let herOlderLibraries = "older libraries Variorum kept when you opened or restored a different one"
    static let herWayBack = "Those older libraries are your way back to what you had before \u{2014} delete them only if "
        + "you won't want them back."

    static func choice(backups: Int, previous: Int, opened: Int = 0, staying: Int = 0) -> CopyDeleteChoice {
        CopyDeleteChoice(
            libraryID: "lib-a", copyIDs: (0..<(backups + previous + opened)).map { "c:\($0)" }, backups: backups,
            previousLibraries: previous, openedCopies: opened, newest: Date(timeIntervalSince1970: 1_790_000_000),
            staying: staying)
    }

    /// RED ON OLD: the delete confirm counted "2 backups and a previous library" — the term she ruled out of every
    /// sentence ("set-aside") was gone, but her own "older libraries" sentence was not said. Now the count is hers, fitted to
    /// one library's copies (PROVISIONAL where fitting changed a word — the singular, the opened copies).
    @Test func theDeleteConfirmCountsInHerWords() {
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 27, previous: 2))
            == "That's 27 backups, plus 2 \(Self.herOlderLibraries).")
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 1, previous: 1))
            == "That's 1 backup, plus 1 older library Variorum kept when you opened or restored a different one.")
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 0, previous: 2))
            == "That's 2 \(Self.herOlderLibraries).")
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 3, previous: 0)) == "That's 3 backups.")
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 2, previous: 0, opened: 1))
            == "That's 2 backups and 1 copy you opened here.")
        #expect(ProtectionWords.deleteCopiesCounts(Self.choice(backups: 2, previous: 1, opened: 2))
            == "That's 2 backups, 2 copies you opened here, plus 1 older library Variorum kept when you opened or restored a "
            + "different one.")
    }

    /// Her way-back sentence, said where an older library is among what goes — and never where none is.
    @Test func theDeleteConfirmSaysHerWayBackSentenceOnlyOverAnOlderLibrary() {
        let two = ProtectionWords.deleteCopiesLead(Self.choice(backups: 1, previous: 2, staying: 1), libraryOpen: true)
        #expect(two.contains(Self.herWayBack), "\(two)")
        #expect(two.contains("One copy another Mac made stays.") && two.hasSuffix("Your library isn't touched."))
        let one = ProtectionWords.deleteCopiesLead(Self.choice(backups: 0, previous: 1), libraryOpen: false)
        #expect(one.contains("That older library is your way back to what you had before \u{2014} delete it only if you "
            + "won't want it back."), "\(one)")
        #expect(!one.contains("Your library"))
        let none = ProtectionWords.deleteCopiesLead(Self.choice(backups: 4, previous: 0), libraryOpen: true)
        #expect(!none.contains("way back"), "\(none)")
        for lead in [two, one, none] { #expect(Self.shouts(lead).isEmpty && !lead.lowercased().contains("set-aside")) }
    }

    /// Her words in the listing, said only where an older library is listed (P-2).
    @Test func theListingSaysHerOlderLibrariesLineOnlyWhereOneIsListed() throws {
        #expect(ProtectionWords.olderLibrariesLine.contains("older library Variorum kept when you opened or restored a "
            + "different one"))
        #expect(ProtectionWords.olderLibrariesLine.contains("your way back to what you had before"))
        #expect(ProtectionWords.olderLibrariesLine.hasPrefix("A " + ProtectionWords.copyKind(.previousLibrary).lowercased()),
                "it names the rows' own kind")
        let library = PlantCatalog.id(), other = PlantCatalog.id(), mac = PlantCatalog.id()
        let mine = try PlantCatalog.keyFile(libraryID: library)
        let theirs = try PlantCatalog.keyFile(libraryID: other)
        let backups = try PlantCatalog.backup(mine, mac: mac, at: PlantCatalog.day(1))
            + PlantCatalog.backup(theirs, mac: mac, at: PlantCatalog.day(2))
        #expect(!CopyDoorsListing.make(Catalog.build(backups), libraryID: library).listsAnOlderLibrary)
        let withAside = try backups + PlantCatalog.previous(theirs, at: PlantCatalog.day(3))
        #expect(CopyDoorsListing.make(Catalog.build(withAside), libraryID: library).listsAnOlderLibrary)
    }

    // MARK: - Piece 4 — VX-264 item 7: the confirm said concretely, per the open library's shape (+ VX-209's synced arm)

    /// §7c's lead IS the Standard, unsynced arm, byte for byte; in Castle the posture is said and rule 17's sentence (hers)
    /// follows; synced, VX-209's arm says the new library doesn't sync until she turns sync on for it; without a passphrase
    /// the passphrase clause goes in every posture.
    @Test func theMakeMineLeadIsConcretePerShape() throws {
        #expect(ProtectionWords.makeMineLead(posture: .standard, passphraseSet: true, synced: false)
            == ProtectionWords.makeMineLead, "§7c's draft is the Standard, unsynced arm")
        let castle = ProtectionWords.makeMineLead(posture: .castle, passphraseSet: true, synced: false)
        #expect(castle.hasPrefix("This copy becomes a new library \u{2014} in Castle, under your current twelve words and "
            + "passphrase \u{2014} with a fresh key of its own."), "\(castle)")
        #expect(!castle.contains("Standard") && castle.hasSuffix(" You never leave Castle by opening something."))
        let synced = ProtectionWords.makeMineLead(posture: .castle, passphraseSet: false, synced: true)
        #expect(synced.hasSuffix("You never leave Castle by opening something. The new library doesn't sync with your "
            + "account until you turn on sync for it in Settings \u{25B8} Protection."), "\(synced)")
        #expect(!synced.contains("passphrase"), "no passphrase set — the clause goes")
        #expect(ProtectionWords.makeMineLead(posture: .standard, passphraseSet: true, synced: true)
            == ProtectionWords.makeMineLead + " " + ProtectionWords.makeMineSyncedLine)
        for posture in [ProtectionMode.standard, .castle] {
            for passphrase in [true, false] {
                for synced in [true, false] {
                    let lead = ProtectionWords.makeMineLead(posture: posture, passphraseSet: passphrase, synced: synced)
                    #expect(Self.shouts(lead).isEmpty && !lead.contains("check"), "concrete — no 'check' (#216): \(lead)")
                }
            }
        }
        // Rule 17's sentence is hers, from the rules file.
        let rules = try RoadAccountWordsTests.rules()
        #expect(rules.contains(ProtectionWords.neverLeaveCastle), "rule 17, verbatim")
    }

    /// The confirm reads the open library's shape from its road (nil — a test's roads — keeps §7c's lead); the shape of a
    /// planted Castle library is Castle, local.
    @Test func theConfirmReadsTheOpenLibrarysShape() async throws {
        let entries = try PlantCatalog.previous(try PlantCatalog.keyFile(libraryID: "lib"), at: PlantCatalog.day(1))
        let row = CopyDoorRow(copy: try #require(Catalog.build(entries).copies.first), isThisLibrary: true, asOf: nil)
        func confirm(_ shape: OpenLibraryShape?) -> MakeMineModel {
            MakeMineModel(row: row, passphraseSet: true, shape: shape, opensQuietly: { true }, act: { _, _ in .made }) { _ in }
        }
        #expect(confirm(nil).lead == ProtectionWords.makeMineLead)
        #expect(confirm(OpenLibraryShape(posture: .castle, synced: true)).lead
            == ProtectionWords.makeMineLead(posture: .castle, passphraseSet: true, synced: true))
        // Through the doors' brain: a row's Make this my library… opens the confirm with the road's shape.
        let planted = PlantedCopyDoors()
        var roads = planted.roads
        roads.passphraseSet = { false }
        roads.libraryShape = { OpenLibraryShape(posture: .castle, synced: false) }
        let doors = CopyDoorsModel(roads: roads)
        await doors.openMakeMine(row)
        guard case .makeMine(let opened) = doors.phase else {
            Issue.record("the confirm stands: \(doors.phase)")
            return
        }
        #expect(opened.lead == ProtectionWords.makeMineLead(posture: .castle, passphraseSet: false, synced: false))
        let road = PlantedRoad()
        let (castle, _) = try await Crossing.inCastle(road)
        #expect(OpenLibraryShape.of(castle.library) == OpenLibraryShape(posture: .castle, synced: false))
        let fresh = PlantedRoad()
        let (standard, _) = try await fresh.created()
        #expect(OpenLibraryShape.of(standard.library) == OpenLibraryShape(posture: .standard, synced: false))
    }
}
