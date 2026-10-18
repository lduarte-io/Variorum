//
//  ProtectionLobbyModelTests.swift
//  VariorumTests — VX-306 U1b piece 3: THE NEW ROAD'S LOBBY MODEL from PLANTED FACTS (pure — no keychain, no
//  file, no store): the face `ProtectionLobbyFace.derive` reads from the core's assessment, and the model's
//  presses over planted roads. VX-310's two bugs are pinned here on the new road — and witnessed RED on today's
//  road (the pre-fix code, still Release's until VX-329) by `VX310TodayLobbyWitnessTests`, the same scenarios.
//
//  VX-310 (her report, 2026-10-13): (1) "a mac that doesn't have touchid set up … does still say use touchid to
//  enter even though they can't"; (2) "when you didn't put your touchid in when the app first offered it, the
//  button to make that prompt come up goes away … and you have to restart the app". The rule (design §3.10):
//  the button whenever a Touch ID item for the current key exists and Touch ID can work here, however many
//  times the prompt was dismissed; no finger enrolled ⇒ no button, one quiet line; unusable for now ⇒ the
//  button stays, a press says why and changes nothing.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planted lobby facts: a library in the slot, its live key file in the catalogue (the words lock always —
/// rule 2 — and a passphrase lock when asked), a Touch ID item for its key when asked.
nonisolated enum LobbyFixture {
    static let fastKDF = PassphraseKDF.Descriptor(
        algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13, memoryKiB: 256, iterations: 1,
        parallelism: 1, salt: PassphraseKDF.randomSalt(), outputBytes: 32)

    static func liveKeyFile(passphrase: Bool) throws -> KeyFile {
        let key = StoreKey.mint()
        let words = try RecoveryPhrase.generate()
        return try KeyFile.building(
            libraryID: UUID().uuidString.lowercased(), key: key, epoch: 1,
            locks: NewKeyLocks(
                passphrase: passphrase ? try PassphraseKey.derive("sesame", kdf: fastKDF) : nil,
                words: try WordsKey.derive(words)))
    }

    static func facts(
        file: KeyFile?, touchIDItem: Bool, biometry: BiometryFacts, silentItem: Bool = false
    ) throws -> ProtectionFacts {
        var entries: [CatalogEntry] = []
        if let file {
            entries.append(CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try file.encoded()))
        }
        let fingerprint = file?.fingerprint ?? String(repeating: "a", count: 16)
        var custody: [CustodyItemFact] = []
        if touchIDItem { custody.append(CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid)) }
        if silentItem { custody.append(CustodyItemFact(fingerprint: fingerprint, itemClass: .silent)) }
        return ProtectionFacts(
            scope: "vx306-lobby-fixture", storeFile: .present, containerMarker: true,
            slotFingerprintHint: file?.fingerprint, rememberedLibraryIDs: [], rememberedKeyFileCopies: [],
            custody: custody, custodyOpensLibrary: silentItem ? [fingerprint] : [], biometry: biometry,
            catalog: Catalog.build(entries), now: Date())
    }

    static func standing(_ facts: ProtectionFacts?, offered: Set<TypedRoad> = []) -> RoadLobbyFacts {
        RoadLobbyFacts(facts: facts, offeredTyped: offered)
    }
}

/// Planted roads: each Touch ID press answers `pressAnswer`, each refresh `refreshAnswer`.
@MainActor
final class PlantedRoads {
    var pressAnswer: RoadAttempt = .touchIDNotOpened(press: .cancelled, biometry: .ready, itemGone: false)
    var typedAnswer: RoadAttempt = .refused(ProtectionWords.passphraseDoesNotOpen)
    var refreshAnswer = RoadLobbyFacts(facts: nil, offeredTyped: [])
    private(set) var presses = 0
    private(set) var typed = 0
    private(set) var missing = 0

    func model(_ standing: RoadLobbyFacts) -> ProtectionLobbyModel {
        ProtectionLobbyModel(
            standing: standing,
            typedRoad: { [unowned self] _ in self.typed += 1; return self.typedAnswer },
            touchIDRoad: { [unowned self] _ in self.presses += 1; return self.pressAnswer },
            refreshRoad: { [unowned self] in self.refreshAnswer },
            opened: { _ in },
            recordMissing: { [unowned self] in self.missing += 1 })
    }
}

@Suite("VX-306 U1b — the new road's lobby model from planted facts (VX-310's two bugs pinned)")
@MainActor
struct ProtectionLobbyModelTests {
    // MARK: - VX-310 bug 1: no finger enrolled ⇒ no Touch ID button, no Touch ID prompt line

    @Test func bug1_aMacWithTouchIDHardwareButNoFingerShowsNoButtonOnlyTheQuietLine() throws {
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let facts = try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: BiometryFacts(hardware: true, enrolled: false))
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(facts))
        #expect(!face.touchIDButton, "no finger enrolled — no button")
        #expect(!face.autoAsk, "and no automatic ask")
        #expect(face.touchIDLine == .notSetUpOnThisMac)
        #expect(face.touchIDLineWords == "Touch ID isn't set up on this Mac.")
        #expect(face.passphraseField, "only the passphrase road (and the words beside it)")
        #expect(face.wordsRoad == .disclosure)
    }

    @Test func bug1_theModelNeverAsksTouchIDWithNoFingerEnrolled() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: BiometryFacts(hardware: true, enrolled: false))))
        await model.autoAskIfDue(appIsActive: true)
        await model.pressTouchID()
        #expect(roads.presses == 0, "no prompt is ever brought up that cannot work")
    }

    @Test func aFingerEnrolledAndAnItemForTheKeyShowTheButtonAndAskOnce() throws {
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        #expect(face.touchIDButton)
        #expect(face.autoAsk)
        #expect(face.touchIDLine == nil)
    }

    @Test func noItemForThisLibraryShowsNoButtonAndSaysSo() throws {
        let file = try LobbyFixture.liveKeyFile(passphrase: false)
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: false, biometry: .ready)))
        #expect(!face.touchIDButton)
        #expect(face.touchIDLine == .notSetUpForThisLibrary)
        #expect(!face.passphraseField, "no passphrase yet (rule 3)")
        #expect(face.wordsRoad == .field, "the words field directly (rule 2)")
        #expect(face.lead == "Enter your twelve words to open your library.")
    }

    // MARK: - VX-310 bug 2: a dismissed prompt never takes the button away

    @Test func bug2_aDismissedPromptNeverTakesTheButtonAwayHoweverManyTimes() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        // The one automatic ask — she dismisses the prompt.
        await model.autoAskIfDue(appIsActive: true)
        #expect(roads.presses == 1)
        #expect(model.face.touchIDButton, "the button survives the dismissed automatic ask")
        await model.autoAskIfDue(appIsActive: true)
        #expect(roads.presses == 1, "the automatic ask happens once")
        // Every press brings the prompt up again; every dismissal leaves the button standing.
        for expected in 2...4 {
            await model.pressTouchID()
            #expect(roads.presses == expected)
            #expect(model.face.touchIDButton)
            #expect(model.message == nil, "a cancel says nothing")
        }
    }

    @Test func bug2_aFirstReadThatMissedTheItemHealsWhenSheComesBackNoRelaunch() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        // The lobby was built from a read that did not see the item (the suspect: a probe that answered "no").
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: false, biometry: .ready)))
        #expect(!model.face.touchIDButton)
        roads.refreshAnswer = LobbyFixture.standing(try LobbyFixture.facts(file: file, touchIDItem: true, biometry: .ready))
        await model.refresh()
        #expect(model.face.touchIDButton, "her return to the app re-reads the roads — the button is back")
    }

    @Test func bug2_aReReadThatFailsOrMissesTheItemNeverRemovesTheButton() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        #expect(model.face.touchIDButton)
        roads.refreshAnswer = LobbyFixture.standing(nil)
        await model.refresh()
        #expect(model.face.touchIDButton, "a read that failed keeps the face it had")
        roads.refreshAnswer = LobbyFixture.standing(try LobbyFixture.facts(file: file, touchIDItem: false, biometry: .ready))
        await model.refresh()
        #expect(model.face.touchIDButton, "a read that misses the item is a flicker — only a press drops a button")
    }

    @Test func onlyAPressThatFindsNoItemDropsTheButton() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        roads.pressAnswer = .touchIDNotOpened(press: nil, biometry: .ready, itemGone: true)
        await model.pressTouchID()
        #expect(!model.face.touchIDButton)
        #expect(model.face.touchIDLine == .notSetUpForThisLibrary)
    }

    // MARK: - Unusable for now; the changed line

    @Test func unusableForNowKeepsTheButtonAndAPressSaysWhyAndChangesNothing() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: BiometryFacts(hardware: true, enrolled: true, transient: .lidClosed))))
        #expect(model.face.touchIDButton, "the lid is closed — the button stays")
        #expect(!model.face.autoAsk, "no automatic ask while Touch ID can't work")
        await model.autoAskIfDue(appIsActive: true)
        await model.pressTouchID()
        #expect(roads.presses == 0, "no prompt is attempted")
        #expect(model.message == "Open the lid to use Touch ID.")
        #expect(model.face.touchIDButton)
    }

    @Test func aPressThatFailsOnAnExistingItemShowsTheChangedLineAndKeepsTheButton() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        roads.pressAnswer = .touchIDNotOpened(press: .failedOnExistingItem, biometry: .ready, itemGone: false)
        await model.pressTouchID()
        #expect(model.face.touchIDButton)
        #expect(model.face.touchIDLine == .changed)
        #expect(model.face.touchIDLineWords == "Touch ID changed since you set it up — unlock with the passphrase.")
    }

    @Test func theAutomaticAskWaitsForVariorumToBeActive() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: true, biometry: .ready)))
        await model.autoAskIfDue(appIsActive: false)
        #expect(roads.presses == 0)
        await model.autoAskIfDue(appIsActive: true)
        #expect(roads.presses == 1)
    }

    // MARK: - The typed roads and the throwing edges

    @Test func theTypedRoadsIncludeTheMirrorsAndTheCataloguedFilesLocks() throws {
        // The live key file has only the words; a mirror or a backup's file carries a passphrase lock too.
        let file = try LobbyFixture.liveKeyFile(passphrase: false)
        let facts = try LobbyFixture.facts(file: file, touchIDItem: false, biometry: .none)
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(facts, offered: [.passphrase, .words]))
        #expect(face.passphraseField)
        #expect(face.wordsRoad == .disclosure)
        #expect(face.lead == "Enter your passphrase or your twelve words to open your library.")
    }

    @Test func anUnlistableKeychainShowsTheTypedFieldWithItsReasonAndClaimsNoTouchID() {
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(nil, offered: [.passphrase, .words]))
        #expect(face.keychainUnreadable)
        #expect(face.passphraseField && face.wordsRoad == .disclosure)
        #expect(!face.touchIDButton && face.touchIDLine == nil)
    }

    @Test func noRoadAtAllIsRule27sSentenceAndNoField() throws {
        // A library in the slot and nothing else: no key file anywhere, no custody, no memory.
        let facts = try LobbyFixture.facts(file: nil, touchIDItem: false, biometry: .ready)
        let face = ProtectionLobbyFace.derive(LobbyFixture.standing(facts))
        #expect(face.noKeyFileAnywhere != nil)
        #expect(!face.passphraseField && face.wordsRoad == .none)
    }

    @Test func aTypedRefusalSaysItsSentenceAndRecordMissingGoesToTheMissingFace() async throws {
        let roads = PlantedRoads()
        let file = try LobbyFixture.liveKeyFile(passphrase: true)
        let model = roads.model(LobbyFixture.standing(try LobbyFixture.facts(
            file: file, touchIDItem: false, biometry: .none)))
        await model.unlock(passphrase: "not it")
        #expect(model.message == "That passphrase doesn't open this library.")
        await model.unlock(passphrase: "")
        #expect(roads.typed == 1, "an empty passphrase is never tried")
        roads.typedAnswer = .recordMissing
        await model.unlock(wordsText: "  some words  ")
        #expect(roads.missing == 1, "K5: a store with no record — the missing face, no sentence")
    }
}
