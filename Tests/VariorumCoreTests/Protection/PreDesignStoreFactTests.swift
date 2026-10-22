//
//  PreDesignStoreFactTests.swift
//  VariorumCoreTests — VX-329 U4 piece 1: THE PRE-DESIGN FACT (the plan's §6d, "THE FACT (pure, in the classifier)").
//  A live slot holding a store, NO format-3 key file beside it, and at least one key file wearing a PRE-DESIGN NAME
//  (`variorum-keys.json`, `variorum-keys-<fp16>.json` — names only, never read) reads as `preDesignStore` (CastleRules
//  rule 26: we don't handle them — detect and say). The other two arms stand unchanged: a keyless store keeps rule 27's
//  refusal, a format-3 slot keeps the lobby.
//
//  The §8 addendum's finding is the first arm's red: her real store's byte copy in the dev slot met the LOBBY (the dev
//  library's memory item and custody item beside it made "something might open it" true, so neither rule 27 nor any
//  other door appeared) — a wedge. Facts built directly and the verdict read through its PRINTED form, so this file
//  compiles on the pre-fix tree and the red-on-old run is honest (the old classifier prints `lobby`).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-329 U4 — the pre-design fact: a store from before this design is named by its key files' names alone")
struct PreDesignStoreFactTests {
    static let fixedName = PF.olderLegacyKeyFilename
    static var fingerprintName: String { PF.olderKeyFilename(PF.fp(StoreKey.mint())) }

    /// The slot before unlock, as the gatherer reads it: the store file's presence, the catalogue built from the
    /// container's listing (a pre-design name is listed BY NAME — no bytes), and whatever this Mac's keychain holds.
    static func facts(
        storeFile: StoreFileFact = .present, entries: [CatalogEntry], custody: [CustodyItemFact] = [],
        custodyOpensLibrary: Set<String>? = nil, rememberedLibraryIDs: Set<String> = [],
        rememberedKeyFileCopies: Set<String>? = nil, session: SessionFact = .signedOut
    ) -> ProtectionFacts {
        ProtectionFacts(
            scope: AWorld.scope, storeFile: storeFile, containerMarker: false, unlocked: nil,
            rememberedLibraryIDs: rememberedLibraryIDs, rememberedKeyFileCopies: rememberedKeyFileCopies,
            custody: custody, custodyOpensLibrary: custodyOpensLibrary, session: session,
            catalog: Catalog.build(entries), now: AWorld.now)
    }

    static func atTheRoot(_ name: String) -> CatalogEntry { CatalogEntry(place: .container, name: name) }

    static func launch(_ facts: ProtectionFacts) -> String { "\(assess(facts).launch)" }

    // MARK: - Arm 1: a pre-design store → the face (RED on the pre-fix tree — the old classifier lobbies it)

    @Test func aStoreWithAnOlderVariorumsKeyFileBesideItIsAPreDesignStore() {
        for names in [[Self.fixedName], [Self.fingerprintName], [Self.fixedName, Self.fingerprintName]] {
            let facts = Self.facts(entries: names.map(Self.atTheRoot))
            #expect(Self.launch(facts) == "preDesignStore", "\(names): \(Self.launch(facts))")
        }
        // A plaintext store wearing them is no store of this design either (this design writes only encrypted ones).
        let plaintext = Self.facts(storeFile: .plaintext, entries: [Self.atTheRoot(Self.fixedName)])
        #expect(Self.launch(plaintext) == "preDesignStore", "\(Self.launch(plaintext))")
        // The slot's other files never change the reading (a sidecar, her own file, a this-design marker name).
        let crowded = Self.facts(entries: [
            Self.atTheRoot(Self.fingerprintName), Self.atTheRoot("variorum.sqlite-wal"), Self.atTheRoot("notes.txt"),
            Self.atTheRoot(CatalogNames.restoreRecipeFilename),
        ])
        #expect(Self.launch(crowded) == "preDesignStore", "\(Self.launch(crowded))")
    }

    /// THE §8 ADDENDUM'S SHAPE: the byte copy in a slot whose Mac REMEMBERS a library of this design — its memory item
    /// carrying a key-file copy, a silent item that might open it, a session signed in. Before the fix each of these made
    /// "something might still open it" true, so the slot met the lobby's typed roads — roads no secret can satisfy. The
    /// fact is the slot's NAMES and precedes every road: the face, whatever the keychain holds.
    @Test func theFactPrecedesWhateverThisMacsKeychainHolds() {
        let remembered = PF.id()
        let mirror = PF.fp(StoreKey.mint())
        let silent = CustodyItemFact(fingerprint: PF.fp(StoreKey.mint()), itemClass: .silent)
        let touchID = CustodyItemFact(fingerprint: PF.fp(StoreKey.mint()), itemClass: .touchid)
        let facts = Self.facts(
            entries: [Self.atTheRoot(Self.fixedName), Self.atTheRoot(Self.fingerprintName)],
            custody: [silent, touchID], custodyOpensLibrary: nil, rememberedLibraryIDs: [remembered],
            rememberedKeyFileCopies: [mirror], session: .signedIn(accountID: PF.id(), email: "x@example.com"))
        #expect(Self.launch(facts) == "preDesignStore", "\(Self.launch(facts))")
    }

    // MARK: - Arm 2: keyless → rule 27's refusal, unchanged (green on both sides)

    @Test func aKeylessStoreKeepsRule27sRefusal() {
        for entries in [
            [CatalogEntry](),
            // Names that are NOT an older Variorum's key file: her own file, a set-aside copy's shape (today's
            // `.stale-<epoch>` — rules 19/21 made it foreign), a near miss of each name.
            [Self.atTheRoot("notes.txt"), Self.atTheRoot("variorum-keys.stale-1791000000.json"),
             Self.atTheRoot("variorum-keys-0a1b2c3d.json"), Self.atTheRoot("variorum-keys-0A1B2C3D4E5F6A7B.json"),
             Self.atTheRoot("variorum-keys-0a1b2c3d4e5f6a7b.json.bak")],
        ] {
            let facts = Self.facts(entries: entries)
            let assessed = assess(facts)
            #expect("\(assessed.launch)" == "lobby", "\(entries.map(\.name))")
            #expect(assessed.lobby.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false),
                    "rule 27's honest refusal stands: \(assessed.lobby)")
        }
    }

    /// An older Variorum's key-file name ANYWHERE but beside the slot is not this slot's fact: a flat backup's in
    /// `Backups/`, one inside a Previous Libraries folder, the far folder's root.
    @Test func onlyTheSlotsOwnFolderCounts() {
        let stamp = CatalogNames.stampString(CF.stamp(3))
        for entry in [
            CatalogEntry(place: .container, folders: [CatalogNames.backupsFolderName], name: Self.fixedName),
            CatalogEntry(place: .container, folders: [CatalogNames.previousLibrariesFolderName, stamp],
                         name: Self.fingerprintName),
            CatalogEntry(place: .farFolder, name: Self.fixedName),
        ] {
            let facts = Self.facts(entries: [entry])
            #expect(Self.launch(facts) == "lobby", "\(entry.place) \(entry.folders) \(entry.name)")
            #expect(assess(facts).lobby.noKeyFileAnywhere != nil, "the keyless slot's own refusal")
        }
    }

    // MARK: - Arm 3: a format-3 slot → the lobby, unchanged (green on both sides)

    @Test func aFormat3SlotKeepsTheLobbyWhateverOlderNamesStandBesideIt() throws {
        let world = try KeyWorld()
        let key = StoreKey.mint()
        let live = CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try world.castleFile(key).encoded())
        // (A library of this design opened by a Debug build before the switch carries today's stub envelope beside its
        // format-3 file — the same names; the format-3 file decides.)
        let readable = Self.facts(entries: [live, Self.atTheRoot(Self.fixedName), Self.atTheRoot(Self.fingerprintName)])
        #expect(Self.launch(readable) == "lobby", "\(Self.launch(readable))")
        #expect(assess(readable).lobby.typed == [.passphrase, .words], "its typed roads stand")
        // A format-3 NAME this build cannot decode is still a format-3 slot (the lobby's unreadable-live-file line).
        let unreadable = Self.facts(entries: [
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: Data("{".utf8)),
            Self.atTheRoot(Self.fixedName),
        ])
        #expect(Self.launch(unreadable) == "lobby", "\(Self.launch(unreadable))")
        // And an empty slot is never a store: no library → a fresh start, whatever names stand there.
        let empty = Self.facts(storeFile: .absent, entries: [Self.atTheRoot(Self.fixedName)])
        #expect(Self.launch(empty) == "startFresh", "\(Self.launch(empty))")
    }

    // MARK: - One rule, two readers

    /// The slot's fact and the picked-copy classifier (R-U1-2 — `LibraryClassifier` names an older Variorum's key file
    /// beside a picked store, never calling it keyless) read ONE rule: a picked folder of an opaque store beside each
    /// name is `.encryptedLibrary` naming that file exactly when the slot's fact calls the name pre-design, and
    /// `.bareStoreWithoutKeyFile` exactly when it does not. (Added after the red-on-old run — it names the new rule.)
    @Test func theSlotsFactAndThePickedCopyClassifierReadOneRule() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx329-u4-names-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        for name in [Self.fixedName, Self.fingerprintName, "variorum-keys-0a1b2c3d.json",
                     "variorum-keys-0A1B2C3D4E5F6A7B.json", "variorum-keys.stale-1791000000.json"] {
            let folder = root.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let store = folder.appendingPathComponent(CatalogNames.libraryFilename)
            try Data((0..<4096).map { _ in UInt8.random(in: 0...255) }).write(to: store)
            let keyFile = folder.appendingPathComponent(name)
            try Data("never read".utf8).write(to: keyFile)
            let preDesign = CatalogNames.isPreDesignKeyFileName(name)
            #expect(Self.launch(Self.facts(entries: [Self.atTheRoot(name)])) == (preDesign ? "preDesignStore" : "lobby"),
                    "\(name)")
            switch LibraryClassifier.classify(at: folder) {
            case .encryptedLibrary(_, let named):
                #expect(preDesign && named.lastPathComponent == name, "\(name): the classifier named \(named.lastPathComponent)")
            case .bareStoreWithoutKeyFile:
                #expect(!preDesign, "\(name): the classifier calls it keyless")
            case let other:
                Issue.record("\(name): \(other)")
            }
        }
        #expect(!CatalogNames.isPreDesignKeyFileName(ProtectionNames.keyFilename), "this design's name is never pre-design")
    }

    // MARK: - Names only, never read

    /// The catalogue's listing reads a file's BYTES only for a name this design writes as a key file
    /// (`CatalogNames.parseFile(…)?.isKeyFile` — `CatalogLister.entry`); an older Variorum's names parse as nothing, so
    /// they are listed by name, never opened, and land in the catalogue's foreign list where the fact reads them.
    @Test func theOlderNamesAreListedByNameAndNeverRead() {
        for name in [Self.fixedName, Self.fingerprintName] {
            #expect(CatalogNames.parseFile(name) == nil, "\(name) is no name of this design — never read")
            let catalog = Catalog.build([Self.atTheRoot(name)])
            #expect(catalog.keyFiles.isEmpty && catalog.copies.isEmpty)
            #expect(catalog.foreign == [CatalogForeignEntry(place: .container, folders: [], name: name)])
        }
    }
}
