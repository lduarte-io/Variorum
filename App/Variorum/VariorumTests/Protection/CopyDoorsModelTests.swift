//
//  CopyDoorsModelTests.swift
//  VariorumTests — VX-306 U3 piece 1: THE TWO DOORS' BRAIN, pure (planted catalogues and planted roads — no keychain,
//  no disk; the suite also runs headless in the implementer's SwiftPM harness). The Restore list's grouping and order
//  (this library's copies newest first, then every other library's; a copy no format-3 key file names left out — rule
//  26), Make this my library's confirm (§7c (8): the copy's own secret only when its quiet road doesn't open it, an
//  empty field trying her own pair — rule 4; her current pair always typed; the refusals worded), and the picked
//  flow's phases.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planting a catalogue the way the lister would list it.
@MainActor
enum PlantCatalog {
    static func id() -> String { UUID().uuidString.lowercased() }

    static func keyFile(libraryID: String, key: StoreKey = StoreKey.mint()) throws -> KeyFile {
        try KeyFile.building(
            libraryID: libraryID, key: key, epoch: 1,
            locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
    }

    /// A backup pair of `file`'s library in `Backups/<library8>/<mac8>/`, stamped `date`.
    static func backup(_ file: KeyFile, mac: String, at date: Date) throws -> [CatalogEntry] {
        let stem = CatalogNames.backupPrefix + CatalogNames.stampString(date) + "-"
            + StoreKeyEnvelope.shortFingerprint(file.fingerprint)
        let folders = [CatalogNames.backupsFolderName, String(file.libraryID.prefix(8)), String(mac.prefix(8))]
        return [
            CatalogEntry(place: .container, folders: folders, name: stem + ".sqlite"),
            CatalogEntry(place: .container, folders: folders, name: stem + ".keys.json", bytes: try file.encoded()),
        ]
    }

    /// A previous library (`Previous Libraries/<stamp>/`) with its key file.
    static func previous(_ file: KeyFile, at date: Date) throws -> [CatalogEntry] {
        let folders = [CatalogNames.previousLibrariesFolderName, CatalogNames.stampString(date)]
        return [
            CatalogEntry(place: .container, folders: folders, name: CatalogNames.libraryFilename),
            CatalogEntry(place: .container, folders: folders, name: ProtectionNames.keyFilename, bytes: try file.encoded()),
        ]
    }

    /// A copy from before this design: 13x's adoption safety copy with TODAY's key file name (foreign to the catalogue).
    static func preDesignSafetyCopy(at date: Date) -> [CatalogEntry] {
        let folders = [CatalogNames.backupsFolderName, CatalogNames.safetyCopiesFolderName,
                       CatalogNames.adoptionSafetyPrefix + CatalogNames.stampString(date)]
        return [
            CatalogEntry(place: .container, folders: folders, name: CatalogNames.libraryFilename),
            CatalogEntry(place: .container, folders: folders, name: "variorum-keys-0123456789abcdef.json", bytes: Data("{}".utf8)),
        ]
    }

    static func day(_ n: Int) -> Date { Date(timeIntervalSince1970: 1_782_864_000 + Double(n) * 86_400) }
}

/// Planted roads for the doors (each call recorded).
@MainActor
final class PlantedCopyDoors {
    var listing = CopyDoorsListing.empty
    var quiet = false
    var passphrase = false
    var makeMineAnswer: CopyDoorOutcome = .made
    var pickAnswer: PickOutcome = .refused("planted", detail: nil)
    private(set) var acts: [(copy: TypedSecrets, pair: TypedSecrets)] = []
    private(set) var probes = 0

    var roads: CopyDoorsRoads {
        CopyDoorsRoads(
            listing: { [unowned self] in self.listing },
            opensQuietly: { [unowned self] _ in self.probes += 1; return self.quiet },
            passphraseSet: { [unowned self] in self.passphrase },
            makeMine: { [unowned self] _, copySecrets, currentPair in
                self.acts.append((copySecrets, currentPair))
                return self.makeMineAnswer
            },
            pick: { [unowned self] _ in self.pickAnswer })
    }
}

@Suite("VX-306 U3 — the two doors' brain (planted, no keychain)")
@MainActor
struct CopyDoorsModelTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []
    static var wordsText: String { words.joined(separator: " ") }

    func row(library: String = "lib", isThisLibrary: Bool = true) throws -> CopyDoorRow {
        let entries = try PlantCatalog.previous(try PlantCatalog.keyFile(libraryID: library), at: PlantCatalog.day(1))
        let copy = try #require(Catalog.build(entries).copies.first)
        return CopyDoorRow(copy: copy, isThisLibrary: isThisLibrary, asOf: copy.stamp)
    }

    // MARK: - The list

    @Test func theListGroupsThisLibraryFirstNewestFirstAndLeavesOutWhatNoKeyFileNames() throws {
        let mine = PlantCatalog.id(), theirs = PlantCatalog.id(), mac = PlantCatalog.id()
        let myFile = try PlantCatalog.keyFile(libraryID: mine)
        let theirFile = try PlantCatalog.keyFile(libraryID: theirs)
        var entries: [CatalogEntry] = []
        entries += try PlantCatalog.backup(myFile, mac: mac, at: PlantCatalog.day(1))
        entries += try PlantCatalog.backup(myFile, mac: mac, at: PlantCatalog.day(3))
        entries += try PlantCatalog.previous(theirFile, at: PlantCatalog.day(2))
        entries += try PlantCatalog.backup(theirFile, mac: mac, at: PlantCatalog.day(4))
        entries += PlantCatalog.preDesignSafetyCopy(at: PlantCatalog.day(5))
        let catalog = Catalog.build(entries)
        #expect(catalog.copies.count == 5, "the pre-design copy is catalogued — and left out of the list")
        let listing = CopyDoorsListing.make(catalog, libraryID: mine)
        #expect(listing.thisLibrary.map(\.asOf) == [PlantCatalog.day(3), PlantCatalog.day(1)])
        #expect(listing.thisLibrary.allSatisfy { $0.isThisLibrary && $0.kind == .backup })
        #expect(listing.otherLibraries.map(\.asOf) == [PlantCatalog.day(4), PlantCatalog.day(2)])
        #expect(listing.otherLibraries.map(\.kind) == [.backup, .previousLibrary])
        #expect(!listing.all.contains { $0.copy.library == nil }, "rule 26: nothing here could open it")
        // With no library open, every copy is another library's.
        let none = CopyDoorsListing.make(catalog, libraryID: nil)
        #expect(none.thisLibrary.isEmpty && none.otherLibraries.count == 4)
    }

    @Test func anUndatedCopySortsLast() throws {
        let a = try row(), b = try row()
        let dated = CopyDoorRow(copy: a.copy, isThisLibrary: true, asOf: PlantCatalog.day(1))
        let undated = CopyDoorRow(copy: b.copy, isThisLibrary: true, asOf: nil)
        #expect(CopyDoorsListing.newestFirst([undated, dated]).map(\.asOf) == [PlantCatalog.day(1), nil])
    }

    // MARK: - Make this my library's confirm

    @Test func aCopyItsQuietRoadOpensAsksOnlyHerPairAndTheActGetsIt() async throws {
        let roads = PlantedCopyDoors()
        roads.quiet = true
        var finished: [Bool] = []
        let r = try row()
        let model = MakeMineModel(
            row: r, passphraseSet: false, opensQuietly: { await roads.roads.opensQuietly(r.copy) },
            act: { await roads.roads.makeMine?(r, $0, $1) ?? .refused(.failed) }, finished: { finished.append($0) })
        await model.begin()
        #expect(!model.checking && !model.needsCopySecret, "the copy's own quiet road opens it — no copy field")
        #expect(!model.lead.contains("passphrase"), "no passphrase set — the lead names none (P-VX306-U3-3)")
        #expect(!model.canSubmit(words: "", passphrase: ""), "her twelve words are always typed")
        await model.submit(copySecret: "ignored — the field is hidden", words: Self.wordsText, passphrase: "")
        #expect(finished == [true])
        let act = try #require(roads.acts.first)
        #expect(act.pair.words == Self.words && act.pair.passphrase == nil)
        #expect(act.copy.words == Self.words, "a hidden copy field: the copy is tried with her own pair (and its quiet road)")
    }

    @Test func aCopyNoQuietRoadOpensAsksItsSecretAndAnEmptyFieldTriesHerPair() async throws {
        let roads = PlantedCopyDoors()
        roads.quiet = false
        let r = try row()
        let model = MakeMineModel(
            row: r, passphraseSet: true, opensQuietly: { false },
            act: { await roads.roads.makeMine?(r, $0, $1) ?? .refused(.failed) }, finished: { _ in })
        await model.begin()
        #expect(model.needsCopySecret)
        #expect(model.lead == ProtectionWords.makeMineLead, "a passphrase is set — the lead exactly as drafted")
        #expect(!model.canSubmit(words: Self.wordsText, passphrase: ""), "her passphrase is asked when one is set")
        await model.submit(copySecret: "", words: Self.wordsText, passphrase: "my passphrase")
        let act = try #require(roads.acts.first)
        #expect(act.pair.passphrase == "my passphrase" && act.pair.words == Self.words)
        #expect(act.copy.passphrase == "my passphrase" && act.copy.words == Self.words, "rule 4: her own pair")
    }

    @Test func theCopyFieldReadsTwelveWordsAsWordsAndAnythingElseAsAPassphrase() throws {
        let pair = TypedSecrets(passphrase: "mine", words: Self.words)
        let theirWords = try RecoveryPhrase.generate()
        let asWords = MakeMineModel.copySecrets(theirWords.joined(separator: "  "), currentPair: pair)
        #expect(asWords.words == theirWords && asWords.passphrase == nil)
        let asPassphrase = MakeMineModel.copySecrets(" their passphrase ", currentPair: pair)
        #expect(asPassphrase.passphrase == " their passphrase " && asPassphrase.words == nil, "untrimmed")
        let eleven = Array(theirWords.prefix(11)).joined(separator: " ")
        #expect(MakeMineModel.copySecrets(eleven, currentPair: pair).passphrase == eleven)
        #expect(MakeMineModel.copySecrets("", currentPair: pair).words == Self.words)
    }

    @Test func badWordsAreRefusedBeforeTheActAndARefusalIsWorded() async throws {
        let roads = PlantedCopyDoors()
        roads.makeMineAnswer = .refused(.copyDoesNotOpen)
        var finished: [Bool] = []
        let r = try row()
        let model = MakeMineModel(
            row: r, passphraseSet: false, opensQuietly: { false },
            act: { await roads.roads.makeMine?(r, $0, $1) ?? .refused(.failed) }, finished: { finished.append($0) })
        await model.begin()
        await model.submit(copySecret: "", words: "one two three", passphrase: "")
        #expect(model.refusal == ProtectionWords.wordsWrongCount(3))
        #expect(roads.acts.isEmpty, "a typo never reaches the act")
        await model.submit(copySecret: "theirs", words: Self.wordsText, passphrase: "")
        #expect(model.refusal == ProtectionWords.copyDoesNotOpen)
        #expect(finished.isEmpty, "a refusal keeps the confirm")
        model.cancel()
        #expect(finished == [false])
    }

    @Test func everyRefusalHasItsSentence() {
        #expect(CopyDoorRefusal.copyGone.sentence == ProtectionWords.copyGone)
        #expect(CopyDoorRefusal.wordsDoNotOpen.sentence == ProtectionWords.wordsDoNotOpen)
        #expect(CopyDoorRefusal.passphraseDoesNotOpen.sentence == ProtectionWords.passphraseDoesNotOpen)
        #expect(CopyDoorRefusal.newerCopy.sentence == LibraryOpenCopy.newerSchemaRefusal)
        #expect(CopyDoorRefusal.busy.sentence == ProtectionWords.copyDoorBusy)
        #expect(CopyDoorRefusal.failed.sentence == ProtectionWords.makeMineFailed)
        #expect(CopyDoorRefusal.wordsInvalid(.checksumMismatch).sentence == ProtectionWords.wordsChecksum)
    }

    // MARK: - The picked flow's phases

    @Test func aPickedCopyLandsOnItsDoorsAndMakeThisMyLibraryClosesTheSheet() async throws {
        let roads = PlantedCopyDoors()
        let picked = try row(library: "theirs", isThisLibrary: false)
        roads.pickAnswer = .copy(picked)
        roads.quiet = true
        let model = CopyDoorsModel(roads: roads.roads)
        await model.begin(picked: URL(fileURLWithPath: "/tmp/picked"))
        guard case .doors(let doors) = model.phase else {
            Issue.record("the picked copy's doors: \(model.phase)")
            return
        }
        #expect(doors == picked)
        await model.openMakeMine(doors)
        guard case .makeMine(let confirm) = model.phase else {
            Issue.record("the confirm: \(model.phase)")
            return
        }
        await confirm.submit(copySecret: "", words: Self.wordsText, passphrase: "")
        guard case .done = model.phase else {
            Issue.record("made — the sheet closes: \(model.phase)")
            return
        }
    }

    /// Look inside is offered wherever its road exists; Make this my library only with a library open (the missing
    /// face's roads carry no `makeMine` — T-5 is VX-309's). A look that can't open quietly asks; Close ends the sheet.
    @Test func theDoorsOfferLookInsideAndMakeThisMyLibraryOnlyWithALibraryOpen() async throws {
        let planted = PlantedCopyDoors()
        var roads = planted.roads
        roads.lookInside = { _, _ in .refused(.copyDoesNotOpen) }
        #expect(CopyDoorsModel(roads: roads).offersLookInside && CopyDoorsModel(roads: roads).offersMakeMine)
        roads.makeMine = nil
        let lookOnly = CopyDoorsModel(roads: roads)
        #expect(lookOnly.offersLookInside && !lookOnly.offersMakeMine)
        let r = try row()
        await lookOnly.openMakeMine(r)
        guard case .reading = lookOnly.phase else {
            Issue.record("no confirm without a library open: \(lookOnly.phase)")
            return
        }
        await lookOnly.openLookInside(r)
        guard case .lookInside(let look) = lookOnly.phase else {
            Issue.record("the look: \(lookOnly.phase)")
            return
        }
        #expect(look.phase == .needsSecret && !look.offersMakeMine)
        look.close()
        guard case .done = lookOnly.phase else {
            Issue.record("Close ends the sheet: \(lookOnly.phase)")
            return
        }
        #expect(!CopyDoorsModel(roads: planted.roads).offersLookInside, "no look road — no door")
    }

    @Test func aPickThatIsNotAPairSaysWhyAndSeveralStoresAreOffered() async throws {
        let roads = PlantedCopyDoors()
        roads.pickAnswer = .refused(ProtectionWords.plaintextCopyNotYet, detail: nil)
        let model = CopyDoorsModel(roads: roads.roads)
        await model.begin(picked: URL(fileURLWithPath: "/tmp/export.sqlite"))
        guard case .refused(let message, _) = model.phase else {
            Issue.record("the refusal: \(model.phase)")
            return
        }
        #expect(message == ProtectionWords.plaintextCopyNotYet)
        let stores = [URL(fileURLWithPath: "/tmp/a/variorum.sqlite"), URL(fileURLWithPath: "/tmp/b/variorum.sqlite")]
        roads.pickAnswer = .several(stores)
        await model.begin(picked: URL(fileURLWithPath: "/tmp"))
        guard case .choosing(let offered) = model.phase else {
            Issue.record("the chooser: \(model.phase)")
            return
        }
        #expect(offered == stores)
        model.close()
        guard case .done = model.phase else { Issue.record("closed"); return }
    }
}
