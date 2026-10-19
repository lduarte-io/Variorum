//
//  LookInsideRoadTests.swift
//  VariorumTests — VX-306 U3 piece 7b: LOOK INSIDE end to end over planted keychain leaves and a temp slot with the real
//  file leaves (`PlantedRoad` — no keychain; the suite also runs headless in the implementer's SwiftPM harness). Rule
//  17: "opens read-only with its own secrets (or its own quiet road on this Mac). The app writes nothing … Close it and
//  the app forgets it." — the orchestrator's ruling P-VX306-U3-15, (b) the read-only facts sheet. THE PROOF: across look
//  → read → close every keychain leaf's WRITE LOG stays empty, every item and every container byte is unchanged, and the
//  private folder is gone after the close. And the look's brain (`LookInsideModel`) over the real road: its own quiet
//  road first, the copy's secret asked when that fails, a wrong one refused, the right one opening; a note read; Close
//  and Make this my library each forgetting; the look with NO library open (the missing face's road).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum LookPlant {
    /// The library on `road` with one note of two blocks (through the ordinary ops on the app's open), the pool closed.
    static func note(_ road: PlantedRoad, key: StoreKey, title: String, blocks: [String]) throws {
        let database = try AppDatabase.onDisk(url: road.slot.places.slot, key: key)
        try withDependencies {
            $0.database = database
            $0.uuid = .init { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: title)
            for text in blocks { _ = try ops.newBlock(in: post.id, text: text) }
        }
        let (_, binding) = database.asRebindable()
        binding.lock()
    }

    /// What the look must leave untouched: every keychain leaf's state and the container's every byte.
    struct Untouched: Equatable {
        var custody: Set<CustodyItemFact>
        var memory: Set<String>
        var apple: [String: String]
        var container: [String: Data]
    }

    static func untouched(_ road: PlantedRoad) throws -> Untouched {
        Untouched(
            custody: Set(road.custody.items.keys), memory: Set(road.memory.items.keys), apple: road.apple.stamps,
            container: try CopyDoorsPlant.tree(road.slot.places.container))
    }

    static func writeLogs(_ road: PlantedRoad) -> [String] {
        road.custody.writes + road.memory.writes + road.apple.writes
    }

    static func privateFolders(_ road: PlantedRoad) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: road.slot.places.scratch.path)) ?? [])
            .filter { $0.hasPrefix("vx306-probe-") }
    }
}

@Suite("VX-306 U3 — Look inside, read-only and writing nothing (planted, no keychain)", .serialized)
@MainActor
struct LookInsideRoadTests {
    /// THE PROOF on a backup of this library (its own quiet road): read, then close — nothing written anywhere.
    @Test func aLookReadsTheCopyAndWritesNothingAndClosingForgets() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        try LookPlant.note(road, key: session.key, title: "A note in the backup", blocks: ["One.", "Two."])
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let row = try #require(ProtectionCopyDoors.listing(session).thisLibrary.first)
        let before = try LookPlant.untouched(road)
        let logsBefore = LookPlant.writeLogs(road)
        guard case .opened(let reader) = ProtectionCopyDoors.lookInside(CopyDoorsContext(session), copy: row.copy, typed: .none) else {
            Issue.record("its own quiet road opens a backup of this library")
            return
        }
        let notes = try reader.notes()
        #expect(notes.map(\.title) == ["A note in the backup"])
        let first = try #require(notes.first)
        let text = try #require(try reader.note(id: first.id))
        #expect(text.blocks == ["One.", "Two."])
        #expect(LookPlant.privateFolders(road).count == 1, "the look reads a private copy")
        reader.close()
        #expect(LookPlant.writeLogs(road) == logsBefore, "no keychain write, no memory write, no Apple key")
        #expect(try LookPlant.untouched(road) == before, "every item and every container byte unchanged")
        #expect(LookPlant.privateFolders(road).isEmpty, "closing forgets — the private folder gone")
    }

    /// Someone else's library (filed first): no quiet road here — its own words open it; the look's brain asks, refuses a
    /// wrong secret, opens with the right one, reads a note, and Close forgets.
    @Test func theLooksBrainAsksTheCopysSecretReadsAndForgetsAtClose() async throws {
        let mine = PlantedRoad()
        let (session, _) = try await mine.created()
        let theirs = PlantedRoad()
        let (theirSession, theirWords) = try await theirs.created()
        try CopyDoorsPlant.migrate(theirs, key: theirSession.key)
        try LookPlant.note(theirs, key: theirSession.key, title: "Their note", blocks: ["Theirs."])
        let downloads = mine.slot.root.appendingPathComponent("Downloads/vx306-airdrop", isDirectory: true)
        try FileManager.default.createDirectory(at: downloads, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: theirs.slot.places.slot, to: downloads.appendingPathComponent(CatalogNames.libraryFilename))
        try FileManager.default.copyItem(at: theirs.slot.places.liveKeyFile, to: downloads.appendingPathComponent(ProtectionNames.keyFilename))
        guard case .copy(let row) = ProtectionCopyDoors.pick(downloads, session: session) else {
            Issue.record("filed")
            return
        }
        let before = try LookPlant.untouched(mine)
        let logsBefore = LookPlant.writeLogs(mine)
        var exits: [LookInsideModel.Exit] = []
        let ctx = CopyDoorsContext(session)
        let look = LookInsideModel(
            row: row, offersMakeMine: true,
            open: { typed, quietRoads in
                await Task.detached { ProtectionCopyDoors.lookInside(ctx, copy: row.copy, typed: typed, quietRoads: quietRoads) }.value
            },
            finished: { exits.append($0) })
        let asOf = try #require(row.asOf)
        #expect(look.frameLine == ProtectionWords.lookInsideFrame(ProtectionWords.day(asOf)))
        await look.begin()
        #expect(look.phase == .needsSecret && look.refusal == nil, "no quiet road here — its own secret is asked")
        await look.submit(secret: (try RecoveryPhrase.generate()).joined(separator: " "))
        #expect(look.phase == .needsSecret && look.refusal == ProtectionWords.copyDoesNotOpen)
        await look.submit(secret: theirWords.joined(separator: " "))
        #expect(look.phase == .open && look.isHoldingAReader)
        #expect(look.notes.map(\.title) == ["Their note"])
        let theirNote = try #require(look.notes.first)
        await look.show(theirNote)
        #expect(look.shown?.blocks == ["Theirs."])
        look.back()
        #expect(look.shown == nil)
        look.close()
        #expect(exits == [.closed] && !look.isHoldingAReader && look.phase == .closed && look.notes.isEmpty)
        #expect(look.closing != nil, "the reader closes off the main actor (NIT 3)")
        await look.closing?.value
        #expect(LookPlant.writeLogs(mine) == logsBefore)
        #expect(try LookPlant.untouched(mine) == before)
        #expect(LookPlant.privateFolders(mine).isEmpty)
    }

    /// *Make this my library…* from inside the look closes the look first.
    @Test func makeThisMyLibraryFromTheLookForgetsTheLookFirst() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let row = try #require(ProtectionCopyDoors.listing(session).thisLibrary.first)
        let ctx = CopyDoorsContext(session)
        var exits: [LookInsideModel.Exit] = []
        let look = LookInsideModel(
            row: row, offersMakeMine: true,
            open: { typed, quietRoads in
                await Task.detached { ProtectionCopyDoors.lookInside(ctx, copy: row.copy, typed: typed, quietRoads: quietRoads) }.value
            },
            finished: { exits.append($0) })
        await look.begin()
        #expect(look.phase == .open)
        look.makeMine()
        await look.closing?.value
        #expect(exits == [.makeMine] && !look.isHoldingAReader && LookPlant.privateFolders(road).isEmpty)
    }

    /// THE LADDER'S ROUND-1 m2 at the look's brain: its first try, as the sheet opens, is AUTOMATIC — the road it hands
    /// is `.withoutAPress` (no Touch ID item read; the copy's own secret is asked); her typed *Open* is a press — the road
    /// it hands may read Touch ID, and a copy only Touch ID holds on this Mac opens at that press by that road.
    @Test func theLooksFirstTryNeverPressesTouchIDAndHerOpenMay() async throws {
        let road = PlantedRoad()
        let (session, row) = try await QuietProbePlant.backupOnlyTouchIDOpens(road)
        let ctx = CopyDoorsContext(session)
        var handed: [CopyQuietRoads] = []
        let look = LookInsideModel(
            row: row, offersMakeMine: true,
            open: { typed, quietRoads in
                handed.append(quietRoads)
                return await Task.detached {
                    ProtectionCopyDoors.lookInside(ctx, copy: row.copy, typed: typed, quietRoads: quietRoads)
                }.value
            },
            finished: { _ in })
        let before = QuietProbePlant.touchIDReads(road)
        await look.begin()
        #expect(handed == [.withoutAPress] && QuietProbePlant.touchIDReads(road) == before, "the opening pressed Touch ID")
        #expect(look.phase == .needsSecret && look.refusal == nil)
        await look.submit(secret: "not this copy's passphrase")
        #expect(handed == [.withoutAPress, .includingTouchID])
        #expect(QuietProbePlant.touchIDReads(road) == before + 1, "her press of Open reads the Touch ID item — the press")
        #expect(look.phase == .open, "the copy's own quiet road on this Mac (rule 17), at her press")
        look.close()
    }

    /// VX-307 U2c — VX-413 (her ruling, 2026-10-18: "copy full text is a good idea"): the note page's *Copy full text*
    /// puts the note shown on the clipboard IN THE DOCUMENT FORMAT (the title, its blocks — re-importable whole), speaks
    /// Copy full text's own receipt in the sheet, and writes NOTHING: every keychain write log and every container byte
    /// unchanged, the look still open and read-only; *Back* clears the line; closing forgets. A note with no text and
    /// no name says Copy full text's own refusal and copies nothing; a look with no clipboard road offers no door.
    @Test func theNotePagesCopyFullTextCarriesTheDocumentFormatAndWritesNothing() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        try LookPlant.note(road, key: session.key, title: "A note in the backup", blocks: ["One.", "Two."])
        do {  // an untitled note with no text — nothing to copy
            let database = try AppDatabase.onDisk(url: road.slot.places.slot, key: session.key)
            try withDependencies {
                $0.database = database
                $0.uuid = .init { UUID() }
                $0.date = .constant(Date(timeIntervalSince1970: 1_782_860_000))
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
            } operation: {
                _ = try Operations().createPost(title: nil)
            }
            let (_, binding) = database.asRebindable()
            binding.lock()
        }
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let row = try #require(ProtectionCopyDoors.listing(session).thisLibrary.first)
        let before = try LookPlant.untouched(road)
        let logsBefore = LookPlant.writeLogs(road)
        let ctx = CopyDoorsContext(session)
        var clipboard: [String] = []
        let look = LookInsideModel(
            row: row, offersMakeMine: true,
            open: { typed, quietRoads in
                await Task.detached { ProtectionCopyDoors.lookInside(ctx, copy: row.copy, typed: typed, quietRoads: quietRoads) }.value
            },
            finished: { _ in },
            copyText: { clipboard.append($0) })
        #expect(look.offersCopyFullText)
        await look.begin()
        #expect(look.phase == .open)
        let note = try #require(look.notes.first { $0.title == "A note in the backup" })
        await look.show(note)
        await look.copyFullText()
        #expect(clipboard.count == 1)
        let text = try #require(clipboard.first)
        #expect(text == "{t:\"A note in the backup\"}\n\nOne.\n\nTwo.", "the Copy full text format: \(text)")
        let parsed = try VariorumDocument.parse(text)
        #expect(parsed.title == "A note in the backup" && parsed.blocks.map(\.text) == ["One.", "Two."])
        #expect(look.copyLine == .copied && look.copyLine?.sentence == "Copied full text.")
        #expect(look.phase == .open && look.isHoldingAReader && look.shown?.id == note.id, "the look stays as it was")
        look.back()
        #expect(look.copyLine == nil)
        // The untitled, empty note: Copy full text's own refusal, nothing copied.
        let empty = try #require(look.notes.first { $0.title == nil })
        await look.show(empty)
        await look.copyFullText()
        #expect(look.copyLine == .nothingToCopy && clipboard.count == 1)
        #expect(look.copyLine?.sentence == "Nothing to copy \u{2014} this note has no text yet.")
        look.close()
        await look.closing?.value
        #expect(look.copyLine == nil)
        #expect(LookPlant.writeLogs(road) == logsBefore, "no keychain write, no memory write, no Apple key")
        #expect(try LookPlant.untouched(road) == before, "every item and every container byte unchanged")
        #expect(LookPlant.privateFolders(road).isEmpty, "closing forgets")
        // No clipboard road (the phone): no door, and the act does nothing.
        let doorless = LookInsideModel(
            row: row, offersMakeMine: false, open: { _, _ in .refused(.copyGone) }, finished: { _ in })
        #expect(!doorless.offersCopyFullText)
    }

    /// The missing face's road: NO library open — Look inside stands on the road's system alone.
    @Test func aLookNeedsNoLibraryOpen() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let ctx = CopyDoorsContext(road.context())
        #expect(ctx.libraryID == nil)
        let row = try #require(ProtectionCopyDoors.listing(ctx).otherLibraries.first, "no library open: every copy is another's")
        guard case .opened(let reader) = ProtectionCopyDoors.lookInside(ctx, copy: row.copy, typed: TypedSecrets(words: words)) else {
            Issue.record("its words open it with no library open")
            return
        }
        reader.close()
        #expect(LookPlant.privateFolders(road).isEmpty)
    }
}
