//
//  EmptySlotMakeMineTests.swift
//  VariorumCoreTests — VX-309 U1b piece 1: T-5, THE EMPTY-SLOT LANDING (rule 17 with no library open — the missing face,
//  rule 27's lobby once its unopenable library stepped aside). Make this my library lands a catalogued copy into the EMPTY
//  slot as a NEW library: a fresh identity, key and device ID, Standard, NOTHING stepping aside; the door requires a typed
//  secret of the copy's (rule 14's precedent) — its own words become the new library's words lock, or its own passphrase its
//  passphrase lock beside twelve words minted fresh. One act on one plan, sealed under the new key: a crash after the swap
//  finishes at the next open; a crash before it leaves the slot empty (the old state). New API — red by construction on the
//  pre-unit tree (no such act existed: the missing face offered Look inside alone, P-VX306-U3-7 narrowed).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U1b — T-5: Make this my library into the EMPTY slot — a new library, nothing steps aside, a typed secret")
struct EmptySlotMakeMineTests {
    /// THE MISSING FACE: a library this Mac had (its backup pair catalogued, its silent item and memory item still here) whose
    /// file — and whose live key file (the doors set it aside first) — is gone from the slot.
    struct MissingFace {
        let fixture: EX
        let copy: CatalogCopy
        let catalog: Catalog
        let oldKey: StoreKey
        let oldLibraryID: String
    }

    static func missingFace(_ mode: ProtectionMode = .standard, gate: GateStyle? = nil) throws -> MissingFace {
        let fixture = try EX(mode, gate: gate)
        let backupFile = try #require(fixture.world.liveKeyFile)
        let record = fixture.liveRecord
        fixture.world.live = nil
        fixture.world.liveKeyFile = nil
        let (copy, catalog) = try plantCopy(
            fixture, libraryID: fixture.libraryID, key: fixture.key, keyFile: backupFile, record: record)
        fixture.world.writes = []
        return MissingFace(
            fixture: fixture, copy: copy, catalog: catalog, oldKey: fixture.key, oldLibraryID: fixture.libraryID)
    }

    /// The copy's own WORDS typed: a NEW library — fresh identity, key and device ID, Standard, no account, no past — whose
    /// words lock is the typed words (no passphrase: rule 3 asks later), this Mac's own fresh Apple lock; nothing stepped
    /// aside; this Mac remembers ONE library (the missing one's memory item forgotten — rule 21); the act ended, no plan, no
    /// staged file, copies running; a fresh pair taken (rule 5); the copy untouched.
    @Test func theCopysOwnWordsLandItAsANewLibraryAndNothingStepsAside() async throws {
        let face = try Self.missingFace()
        let world = face.fixture.world
        let copyBefore = try #require(world.copies[face.copy.id])
        let landed = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
            copy: face.copy, in: face.catalog, typed: TypedSecrets(words: face.fixture.words))
        #expect(landed.mintedWords == nil, "her typed words are the new library's words — nothing minted")
        let record = try #require(world.live?.record)
        let newKey = landed.library.key
        #expect(newKey != face.oldKey && world.live?.fingerprint == PF.fp(newKey), "a fresh key in the slot")
        #expect(record.libraryID != face.oldLibraryID, "a fresh identity (rule 17)")
        #expect(record.mode == .standard && record.account == nil, "Standard, no account (P-VX378-U2-4)")
        #expect(!record.passphraseSet)
        #expect(landed.library.section.deviceID != face.fixture.deviceID, "a fresh device ID (rule 23)")
        #expect(landed.library.section.actInFlight == nil)
        let file = try #require(world.liveKeyFile)
        #expect(file.libraryID == record.libraryID && file.history.isEmpty, "a new library carries no previous keys")
        #expect(try file.open(words: face.fixture.words) == newKey, "under the copy's own words, typed")
        #expect(file.passphrase == nil)
        let appleID = try #require(file.apple?.keyID)
        let apple = try #require(world.icloud.keys[appleID])
        #expect(try file.open(apple: apple) == newKey && world.icloud.stamps[appleID] == record.libraryID)
        #expect(world.custody[CustodyItemFact(fingerprint: PF.fp(newKey), itemClass: .silent)] == newKey)
        #expect(world.aside.isEmpty && world.asideKeyFiles.isEmpty, "nothing stepped aside — the slot was empty")
        #expect(Set(world.memories.keys) == [record.libraryID], "this Mac remembers ONE library (rule 21)")
        #expect(world.plan == nil && world.staged == nil && !world.paused)
        #expect(world.backups.last?.fingerprint == PF.fp(newKey), "a fresh pair under the new key (rule 5)")
        #expect(world.copies[face.copy.id]?.fingerprint == copyBefore.fingerprint, "the copy itself untouched")
        #expect(world.copies[face.copy.id]?.generation == copyBefore.generation)
        #expect(world.live?.generation == copyBefore.generation, "the copy's writing, landed")
    }

    /// The copy's own PASSPHRASE typed: its passphrase lock on a FRESH descriptor, and the new library's twelve words minted
    /// fresh (rule 2 — every library has words from its first moment), handed back to the caller and never stored.
    @Test func theCopysOwnPassphraseLandsItWithFreshWords() async throws {
        let face = try Self.missingFace()
        let world = face.fixture.world
        let copyKDF = try #require(world.liveKeyFileOfTheCopy(face)?.passphrase?.kdf)
        let landed = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
            copy: face.copy, in: face.catalog, typed: TypedSecrets(passphrase: face.fixture.passphrase))
        let minted = try #require(landed.mintedWords)
        #expect(minted.count == 12 && minted != face.fixture.words)
        let file = try #require(world.liveKeyFile)
        let newKey = landed.library.key
        #expect(try file.open(passphrase: .passphrase(face.fixture.passphrase), floor: PF.floor) == newKey)
        #expect(file.passphrase?.kdf != copyKDF, "a new passphrase lock takes a fresh descriptor")
        #expect(try file.open(words: minted) == newKey, "the minted words open it")
        #expect((try? file.open(words: face.fixture.words)) == nil, "the copy's own words do not")
        #expect(world.live?.record?.passphraseSet == true)
        #expect(!world.logLines.joined().contains(minted.joined(separator: " ")), "the words never reach the log")
    }

    /// THE DOOR REQUIRES A TYPED SECRET OF THE COPY'S: nothing typed, or a secret that does not open it, refuses
    /// `copyDoesNotOpen` — even though this Mac's silent item (its own quiet road) opens the copy — and NOTHING is written.
    @Test func aQuietRoadAloneNeverLandsACopyAndNothingIsWritten() async throws {
        let face = try Self.missingFace()
        let world = face.fixture.world
        #expect(world.custody[CustodyItemFact(fingerprint: PF.fp(face.oldKey), itemClass: .silent)] != nil,
                "its own quiet road on this Mac opens the copy")
        world.crashAfterWrites = 1  // any write at all would crash
        for typed in [TypedSecrets.none, TypedSecrets(words: try PF.words()), TypedSecrets(passphrase: "not its passphrase")] {
            await #expect(throws: ExecutorRefusal.copyDoesNotOpen) {
                _ = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
                    copy: face.copy, in: face.catalog, typed: typed)
            }
        }
        #expect(world.writes.isEmpty && world.live == nil && world.plan == nil)
    }

    /// The slot must be EMPTY — a library standing there, or a key file in the live place (a missing library's, which the
    /// doors set aside first), refuses `libraryAlreadyInSlot` before anything is minted or written.
    @Test func anOccupiedSlotOrAStandingKeyFileRefusesAndNothingIsWritten() async throws {
        let standing = try EX(.standard)
        let (copy, catalog) = try plantCopy(
            standing, libraryID: standing.libraryID, key: standing.key, keyFile: try #require(standing.world.liveKeyFile),
            record: standing.liveRecord)
        standing.world.writes = []
        await #expect(throws: ExecutorRefusal.libraryAlreadyInSlot) {
            _ = try await standing.executor().makeThisMyLibraryInTheEmptySlot(
                copy: copy, in: catalog, typed: TypedSecrets(words: standing.words))
        }
        #expect(standing.world.writes.isEmpty && standing.world.aside.isEmpty)

        let face = try Self.missingFace()
        let missingFile = try #require(face.fixture.world.liveKeyFileOfTheCopy(face))
        face.fixture.world.liveKeyFile = missingFile
        await #expect(throws: ExecutorRefusal.libraryAlreadyInSlot) {
            _ = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
                copy: face.copy, in: face.catalog, typed: TypedSecrets(words: face.fixture.words))
        }
        #expect(face.fixture.world.writes.isEmpty && face.fixture.world.liveKeyFile == missingFile,
                "a key file in the live place is never written over")
    }

    /// RULE 20, write by write: a crash after EVERY write of the clean landing. Before the swap the slot stays EMPTY (the old
    /// state — no library, nothing of hers touched; what the press wrote names a library that never landed), and a second
    /// press then lands the copy whole (the live key file the first wrote set aside first, as the doors do). From the swap
    /// on, the next open opens the NEW library by its silent item and the settle FINISHES it from its plan (or finds it done)
    /// — never a third state.
    @Test func aCrashAnywhereLeavesTheEmptySlotOrTheNewLibraryNeverAThirdState() async throws {
        let clean = try Self.missingFace()
        _ = try await clean.fixture.executor().makeThisMyLibraryInTheEmptySlot(
            copy: clean.copy, in: clean.catalog, typed: TypedSecrets(words: clean.fixture.words))
        let count = clean.fixture.world.writes.count
        #expect(count > 8)
        let swapAt = try #require(clean.fixture.world.writes.firstIndex { if case .swap = $0 { true } else { false } }) + 1
        for crashAt in 1...count {
            let context = "crash after write \(crashAt) (\(clean.fixture.world.writes[crashAt - 1])):"
            let face = try Self.missingFace()
            let world = face.fixture.world
            world.crashAfterWrites = crashAt
            do {
                _ = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
                    copy: face.copy, in: face.catalog, typed: TypedSecrets(words: face.fixture.words))
                Issue.record("\(context) no crash")
            } catch is SimulatedCrash {}
            world.relaunch()
            if crashAt < swapAt {
                #expect(world.live == nil, "\(context) the slot stays empty — the old state")
                #expect(world.aside.isEmpty && world.copies[face.copy.id] != nil, "\(context) nothing of hers touched")
                // A second press lands it whole (the doors set the first press's key file aside, never write over it).
                world.liveKeyFile = nil
                do {
                    let landed = try await face.fixture.executor().makeThisMyLibraryInTheEmptySlot(
                        copy: face.copy, in: face.catalog, typed: TypedSecrets(words: face.fixture.words))
                    let id = try #require(landed.library.record?.libraryID)
                    #expect(world.live?.fingerprint == landed.library.fingerprint && Set(world.memories.keys) == [id],
                            "\(context) the second press lands it, one library remembered")
                    #expect(world.plan == nil && world.staged == nil && landed.library.section.actInFlight == nil)
                } catch {
                    Issue.record("\(context) the second press refused \(error)")
                }
            } else {
                let settled: UnlockedLibrary
                do {
                    (_, settled, _) = try await face.fixture.relaunchAndSettle(TypedSecrets.none)
                } catch {
                    Issue.record("\(context) the next open could not settle: \(error)")
                    continue
                }
                expectSettled(face.fixture, settled, context)
                let record = try #require(world.live?.record)
                #expect(record.libraryID != face.oldLibraryID, "\(context) the new library")
                #expect(Set(world.memories.keys) == [record.libraryID], "\(context) one library remembered")
                #expect(world.backups.contains { $0.fingerprint == PF.fp(settled.key) }, "\(context) its pair taken")
            }
        }
    }
}

extension ExecutorWorld {
    /// The landing copy's own key file (the catalogued pair's) — the missing face keeps no live one.
    func liveKeyFileOfTheCopy(_ face: EmptySlotMakeMineTests.MissingFace) -> KeyFile? {
        face.catalog.servingKeyFiles(of: face.copy).first?.document
    }
}
