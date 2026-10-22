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
        // VX-309 ladder round 1, F-R1 — FLIPPED DELIBERATELY: what stays may be a copy no Mac can be named for (an
        // unattributed far copy) — the reviewer's "can't vouch for" clause (PROVISIONAL P-VX309-R1-1).
        #expect(two.contains("One copy another Mac made, or that this \(ProtectionCopy.deviceName) can't vouch for, stays.")
            && two.hasSuffix("Your library isn't touched."))
        let three = ProtectionWords.deleteCopiesLead(Self.choice(backups: 1, previous: 0, staying: 3), libraryOpen: true)
        #expect(three.contains(" 3 copies another Mac made, or that this \(ProtectionCopy.deviceName) can't vouch for, stay."),
                "\(three)")
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

    // MARK: - Piece 7 — the field guide's protection chapter on the new road + Data Safety's truths (VX-379; #235)

    /// The two-register rule — `CopyRegisterPinTests.forbidden`'s pattern restated, since that suite is Mac-only and this one
    /// also runs headless: no key-family internal in user copy.
    static var forbidden: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }

    /// The words no rule as built says any more.
    static let retired = ["escrow", "recovery key", "recovery phrase", "set-aside", "set aside copy", "anchor", " box"]

    /// Every paragraph of the chapter and the export lesson's two, read for the rules AS BUILT: her sentences verbatim where
    /// they exist; the numbers as built (the floor, retention's 14 · 14 + 4); the doors by their own names; nothing retired;
    /// nothing shouted; no device named by a literal.
    @Test func theGuidesNewRoadChapterSaysTheRulesAsBuilt() throws {
        let postures = ProtectionWords.guidePosturesLesson.joined(separator: "\n")
        let copies = ProtectionWords.guideCopiesLesson.joined(separator: "\n")
        #expect(postures.contains(ProtectionWords.castlePromise), "rule 9's promise, hers")
        #expect(postures.contains(ProtectionWords.leaveSentence), "rule 12's leave sentence, hers")
        #expect(postures.contains("at least 12 characters"), "the floor, as built (VX-211)")
        #expect(postures.contains("one at a time") && postures.contains("twelve words"))
        #expect(copies.contains(ProtectionWords.neverLeaveCastle), "rule 17's sentence, hers")
        #expect(copies.contains(ProtectionWords.dataSafetyWhatOpensABackup), "rule 5's sentence — one text with the pane")
        #expect(copies.contains(ProtectionWords.copiesElsewhereLine), "VX-210's line — one text with the listings")
        #expect(copies.contains("the newest 14") && copies.contains("the 14 most recent days")
            && copies.contains("4 weeks"), "retention's honest numbers (VX-302)")
        #expect(copies.contains("older library Variorum kept when you opened or restored a different one"), "her item-5 words")
        for door in [ProtectionWords.lookInsideDoor, ProtectionWords.makeMineDoor] {
            #expect(copies.contains(Self.named(door)), "\(door) by its own name")
        }
        #expect(copies.contains(LibraryOpenCopy.restoreSectionTitle) && copies.contains("Previous Libraries"))
        let all = ProtectionWords.guidePosturesLesson + ProtectionWords.guideCopiesLesson + [
            ProtectionWords.guideSyncSentence, ProtectionWords.guideOpenMeansReadable, ProtectionWords.guideBackupsHappen,
            ProtectionWords.guideSecondFolderLead, ProtectionWords.guideKeyLessonTitle,
            ProtectionWords.guidePosturesLessonTitle, ProtectionWords.guideCopiesLessonTitle,
        ]
        for paragraph in all {
            #expect(Self.shouts(paragraph).filter { $0 != "ID" }.isEmpty, "\(paragraph)")
            #expect(!paragraph.contains(Self.forbidden), "the two-register rule: \(paragraph)")
            for word in Self.retired { #expect(!paragraph.lowercased().contains(word), "\(word) in \(paragraph)") }
            #expect(paragraph.firstMatch(of: /\bMac\b/) == nil || ProtectionCopy.deviceName == "Mac",
                    "shared copy names the device through ProtectionCopy")
        }
        #expect(ProtectionWords.guideBackupsHappen.contains("a pair") && ProtectionWords.guideSecondFolderLead.contains("once a day"))
        #expect(ProtectionWords.guideOpenMeansReadable.contains("Lock Library Now"), "the lock's door by its name (VX-451)")
    }

    /// Data Safety on the new road: rule 5's sentence (F-U2c-4), what the counts are (F-U1a-3 / VX-397), and why a second
    /// same-day Back Up Now adds nothing to the picked folder (P-VX309-U1a-2).
    @Test func dataSafetysNewRoadLinesSayTheCopiesAsBuilt() {
        let opens = ProtectionWords.dataSafetyWhatOpensABackup
        #expect(opens.hasPrefix("A backup is your library plus its key file."), "rule 5's first sentence")
        #expect(opens.contains("the passphrase and twelve words you had when you made it") && opens.contains("current ones"))
        #expect(opens.contains("quiet road while it still holds that backup's key"), "VX-263's clause")
        #expect(ProtectionWords.dataSafetyTheCountsAreThisMacs.contains("this \(ProtectionCopy.deviceName)'s copies of this library"))
        let kept = ProtectionWords.dataSafetySecondFolderKept
        #expect(kept.hasPrefix("Kept there: the 14 most recent days that have a copy, plus one copy from each of the 4 weeks "
            + "before those."), "today's caption, unchanged, leads")
        #expect(kept.contains("a second Back Up Now on the same day adds one beside your library only"))
        for line in [opens, ProtectionWords.dataSafetyTheCountsAreThisMacs, kept] {
            #expect(Self.shouts(line).isEmpty && !line.contains(Self.forbidden))
        }
    }

    /// The faces (by source): Data Safety renders the new road's lines behind its road gate and keeps today's caption on
    /// today's road; the guide's seed gates its new chapter by the road's own rule.
    @Test func theNewRoadsLinesAreRenderedOnlyThere() throws {
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let pane = try String(contentsOf: app.appendingPathComponent("Variorum/Features/Settings/DataSafetyPane.swift"),
                              encoding: .utf8)
        let gate = try #require(pane.components(separatedBy: "if roadStanding != nil {").dropFirst().first)
        #expect(gate.prefix(500).contains("ProtectionWords.dataSafetyTheCountsAreThisMacs")
            && gate.prefix(500).contains("ProtectionWords.dataSafetyWhatOpensABackup"))
        // VX-329 U1: one road — the second folder's line is the road's, unconditionally (today's caption left with it), and
        // the guide seeds the road's chapter in every store (no road parameter is left).
        #expect(pane.contains("Text(ProtectionWords.dataSafetySecondFolderKept)"))
        let seeder = try String(contentsOf: app.appendingPathComponent("Variorum/Features/Tutorial/TutorialSeeder.swift"),
                                encoding: .utf8)
        #expect(!seeder.contains("onTheNewRoad"), "no road parameter is left")
        #expect(!seeder.contains("opensOnTheNewRoad"), "the dev-store fence is gone")
    }

    // MARK: - Piece 9 — U1a–U1c's undrafted words, one pass in §7c's voice (P-VX309-U1b-3, P-VX309-U1c-1 → P-VX309-U2-10)

    /// T-5 and the empty-slot listing say §7c's own sentences where one fits: the receipt is §7c (9)'s first sentence (no
    /// library stepped aside), the listing's lead is `restoreListLead`'s sentence without its step-aside clause, and the
    /// lead says the pair the landing keeps AS BUILT (the copy's words → the library's words, no passphrase rides; its
    /// passphrase → the library's, beside new words the card offers).
    @Test func theEmptySlotLinesSpeakInSection7csVoice() {
        #expect(ProtectionWords.makeMineEmptySlotReceipt == "This is your library now.")
        #expect(ProtectionWords.makeMineReceipt.hasPrefix(ProtectionWords.makeMineEmptySlotReceipt + " "),
                "§7c (9)'s own first sentence")
        #expect(ProtectionWords.emptySlotRestoreListLead
            == "Look inside a copy to read it without changing anything, or make it your library.")
        #expect(ProtectionWords.restoreListLead.hasPrefix(String(ProtectionWords.emptySlotRestoreListLead.dropLast()) + " "),
                "the open listing's lead, minus the step-aside clause")
        let lead = ProtectionWords.makeMineEmptySlotLead
        #expect(lead.hasPrefix("This copy becomes your library \u{2014} a new library, in Standard, with a fresh key of its "
            + "own."), "§7c (8)'s shape; Standard as built (P-VX309-U1b-2)")
        #expect(lead.contains("Enter the copy's twelve words and they become your library's words, and you can set a "
            + "passphrase after"))
        #expect(lead.contains("or enter its passphrase and it becomes your library's, with new twelve words offered once "
            + "the library opens."))
        #expect(lead.hasSuffix("The copy itself is not changed."))
        #expect(ProtectionWords.noCopiesOnThisMac
            == "Variorum isn't keeping any copies on this \(ProtectionCopy.deviceName).")
    }

    /// T-8: the lead says the ruling in ONE line (content rides, configuration doesn't) and, with a library open, §7c (8)'s
    /// own step-aside clause; the refusals name what happened and that nothing moved; the receipt is §7c (9)'s shape.
    @Test func theBringInLinesSayTheRulingAndSection7csShape() throws {
        let aside = ProtectionWords.bringInLead(stepsALibraryAside: true)
        let empty = ProtectionWords.bringInLead(stepsALibraryAside: false)
        let clause = "steps aside whole into Previous Libraries, where you can look inside it or make it your library again."
        #expect(ProtectionWords.makeMineLead.contains(clause), "§7c (8)'s own clause")
        #expect(aside.contains("Your current library " + clause) && !empty.contains("Previous Libraries"))
        for lead in [aside, empty] {
            #expect(lead.hasPrefix("This plain-text copy becomes a new library \u{2014} in Standard, with a fresh key of "
                + "its own; its new twelve words are offered once it opens."))
            // VX-309 ladder round 1, F-R2 — FLIPPED DELIBERATELY: the one line names the two losses it left unsaid —
            // gatherings (configuration — ruling item 6) and every note's entry date (the format carries none: a brought-in
            // note is minted with no entry date).
            #expect(lead.contains("Its notes and their takes, books, chapters, snippets and tags come in, written fresh; its "
                + "gatherings, entry dates, commits, comments, note versions, book settings, stars and shelves don't."),
                    "the ruling's one line")
            #expect(lead.hasSuffix(" The copy itself is not changed."))
        }
        // The guide's plain-text paragraph follows the lead's list (one list, two hosts — never drifting).
        let guide = try #require(ProtectionWords.guideCopiesLesson.last)
        #expect(guide.contains("its gatherings, entry dates, commits, comments, note versions, book settings, stars and "
            + "shelves stay behind."), "\(guide)")
        #expect(ProtectionWords.exportFromAnEarlierBuild
            == "This plain-text copy was written by an earlier Variorum than this one, which can't bring it in.")
        #expect(LibraryOpenCopy.newerSchemaRefusal.hasPrefix("This library was written by a newer Variorum than this one."),
                "the sibling refusal's shape it mirrors")
        #expect(ProtectionWords.exportNoteUnreadable("Spring", line: 12)
            == "The note \u{201C}Spring\u{201D} couldn't be read from this copy (line 12), so nothing was brought in.")
        #expect(ProtectionWords.exportNoteUnreadable("Spring", line: nil)
            == "The note \u{201C}Spring\u{201D} couldn't be read from this copy, so nothing was brought in.")
        var landing = PlaintextExportLanding()
        landing.books = 2; landing.notes = 1; landing.snippets = 0
        #expect(ProtectionWords.bringInReceipt(landing, stoppedEarly: false, steppedAside: false)
            == "This is your library now, made from the plain-text copy: 2 books \u{00B7} 1 note \u{00B7} 0 snippet groups.")
        landing.wings = 1; landing.emptyBooks = ["Drafts", "Later"]
        #expect(ProtectionWords.bringInReceipt(landing, stoppedEarly: true, steppedAside: true)
            == "This is your library now, made from the plain-text copy: 2 books \u{00B7} 1 note \u{00B7} 0 snippet groups "
            + "\u{00B7} 1 wing. Empty books were left out: Drafts, Later. The previous one is in Previous Libraries. It "
            + "stopped part of the way \u{2014} the copy is unchanged and can be brought in again.")
        #expect(ProtectionWords.bringInReceipt(landing, stoppedEarly: false, steppedAside: true)
            .hasPrefix(String(ProtectionWords.makeMineReceipt.prefix(24))), "§7c (9)'s opening")
    }

    /// The delete door's lines: the door, title, button, working line and failure stand as drafted; the lead's opening and
    /// the receipt name the device through `ProtectionCopy` (shared copy); VX-210's line is one plain line.
    @Test func theDeleteLinesAndVX210sLineAfterThePass() {
        let lead = ProtectionWords.deleteCopiesLead(Self.choice(backups: 2, previous: 0), libraryOpen: true)
        #expect(lead.hasPrefix("This deletes this \(ProtectionCopy.deviceName)'s copies of the library last copied "), "\(lead)")
        #expect(ProtectionWords.deleteCopiesReceipt(1) == "Deleted 1 copy of another library from this \(ProtectionCopy.deviceName).")
        #expect(ProtectionWords.deleteCopiesReceipt(4)
            == "Deleted 4 copies of another library from this \(ProtectionCopy.deviceName).")
        // VX-309 ladder round 1, F-R1 — FLIPPED DELIBERATELY: the line now also counts a far copy no container twin vouches
        // for — inside a folder Variorum writes — so it gains the clause that keeps it true of that copy (PROVISIONAL
        // P-VX309-R1-1).
        #expect(ProtectionWords.copiesElsewhereLine == "Copies outside the folders Variorum keeps \u{2014} older backups, or "
            + "a folder you made \u{2014} are left as they are, and so are copies in your second folder that this "
            + "\(ProtectionCopy.deviceName) can't vouch for as its own. They're yours to manage in the Finder.")
        #expect([ProtectionWords.deleteCopiesDoor, ProtectionWords.deleteCopiesTitle, ProtectionWords.deleteCopiesButton,
                 ProtectionWords.deleteCopiesWorking, ProtectionWords.deleteCopiesFailed]
            == ["Delete\u{2026}", "Delete this library's copies?", "Delete copies", "Deleting the copies\u{2026}",
                "Variorum couldn't delete those copies just now. Nothing more was deleted."], "as drafted, read and kept")
    }

    /// Every line of the pass keeps the register: nothing shouted, no key-family internal, no retired word.
    @Test func everyLineOfThePassKeepsTheRegister() {
        var landing = PlaintextExportLanding()
        landing.books = 1; landing.notes = 1; landing.snippets = 1; landing.emptyBooks = ["Drafts"]
        let lines = [
            ProtectionWords.makeMineEmptySlotLead, ProtectionWords.makeMineEmptySlotReceipt,
            ProtectionWords.emptySlotRestoreListLead, ProtectionWords.noCopiesOnThisMac,
            ProtectionWords.bringInLead(stepsALibraryAside: true), ProtectionWords.bringInLead(stepsALibraryAside: false),
            ProtectionWords.bringInButton, ProtectionWords.bringInWorking, ProtectionWords.exportFromAnEarlierBuild,
            ProtectionWords.exportNoteUnreadable("A note", line: 3),
            ProtectionWords.bringInReceipt(landing, stoppedEarly: true, steppedAside: true),
            ProtectionWords.deleteCopiesLead(Self.choice(backups: 1, previous: 1, opened: 1, staying: 2), libraryOpen: true),
            ProtectionWords.deleteCopiesReceipt(2), ProtectionWords.copiesElsewhereLine,
        ]
        for line in lines {
            #expect(Self.shouts(line).isEmpty, "\(line)")
            #expect(!line.contains(Self.forbidden), "the two-register rule: \(line)")
            for word in Self.retired { #expect(!line.lowercased().contains(word), "\(word) in \(line)") }
        }
    }
}
