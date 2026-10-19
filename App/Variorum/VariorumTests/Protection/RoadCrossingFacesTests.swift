//
//  RoadCrossingFacesTests.swift
//  VariorumTests — VX-307 U2a piece 1: THE CROSSINGS' FACES, read from `assess` (`RoadCrossingFaces.derive`) over the
//  facts of a REAL library on the new road's planted leaves (no keychain — `PlantedRoad`; also runs headless in the
//  implementer's SwiftPM harness), mutated where a state is planted (an account, a vault reading, this Mac's biometry, a
//  copy under an Apple key this Mac can't read). And THE WORDS: rule 12's leave sentence and rule 9's promise are HER
//  sentences, read from `notes/CastleRules.md` and pinned byte-equal.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum CrossingPlant {
    /// The open library's facts and their assessment.
    static func read(
        _ road: PlantedRoad, _ session: ProtectionRoadSession, mutate: (inout ProtectionFacts) -> Void = { _ in }
    ) throws -> (facts: ProtectionFacts, assessment: Assessment) {
        var facts = try road.system().facts(session: .signedOut, unlocked: session.library)
        mutate(&facts)
        return (facts, assess(facts))
    }

    static func faces(
        _ road: PlantedRoad, _ session: ProtectionRoadSession, mutate: (inout ProtectionFacts) -> Void = { _ in }
    ) throws -> RoadCrossingFaces {
        let (facts, assessment) = try read(road, session, mutate: mutate)
        return try #require(RoadCrossingFaces.derive(facts, assessment) { "copy \($0)" })
    }
}

@Suite("VX-307 U2a — the crossings' faces read from assess (planted facts)")
@MainActor
struct RoadCrossingFacesTests {
    /// A fresh library: Standard, no passphrase, no account. Use Castle is OPEN — both secrets typed (P-VX378-U2-2), the
    /// passphrase a NEW one (rule 3: none yet), rule 9's promise, the lead, the floor and the export-first line; Use
    /// Standard is not this posture's door (rendered as nothing); Replace All Keys has no account to act on (nothing).
    @Test func aFreshStandardLibraryOffersUseCastleAlone() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let faces = try CrossingPlant.faces(road, session) { $0.biometry = .ready }
        #expect(faces.mode == .standard)
        #expect(faces.useStandard == .hidden)
        #expect(faces.replaceAllKeys == .hidden, "no account — `.notSynced` renders nothing (P-2)")
        #expect(faces.gateRow == nil, "the gate-style row is Castle's")
        let open = try #require(faces.useCastle.openDoor)
        #expect(open.ask == .passphraseAndWords)
        #expect(open.newPassphrase, "no passphrase yet — the door sets the one typed")
        #expect(open.sentences == [
            ProtectionWords.castlePromise, ProtectionWords.useCastleLead, ProtectionWords.castleFloor,
            ProtectionWords.exportAPlainCopyFirst,
        ])
        #expect(open.undeletableCopies.isEmpty)
        #expect(!open.synced)
        #expect(open.gate == RoadGateChoice(touchIDAvailable: true, preselected: .touchID))
    }

    /// The gate choice follows THIS Mac: no finger enrolled (or no hardware) → Always ask is the only choice; an earlier
    /// choice of this Mac's is where the confirm opens.
    @Test func theGateChoiceFollowsThisMacsBiometryAndItsEarlierChoice() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        for biometry in [BiometryFacts.none, BiometryFacts(hardware: true, enrolled: false)] {
            let faces = try CrossingPlant.faces(road, session) { $0.biometry = biometry }
            #expect(faces.useCastle.openDoor?.gate == RoadGateChoice(touchIDAvailable: false, preselected: .alwaysAsk))
        }
        let chosen = try CrossingPlant.faces(road, session) {
            $0.biometry = .ready
            $0.unlocked?.thisMac.settings.gateStyle = .alwaysAsk
        }
        #expect(chosen.useCastle.openDoor?.gate == RoadGateChoice(touchIDAvailable: true, preselected: .alwaysAsk))
        // An earlier Touch ID choice on a Mac that can't serve it now opens on Always ask.
        let lost = try CrossingPlant.faces(road, session) {
            $0.biometry = .none
            $0.unlocked?.thisMac.settings.gateStyle = .touchID
        }
        #expect(lost.useCastle.openDoor?.gate == RoadGateChoice(touchIDAvailable: false, preselected: .alwaysAsk))
    }

    /// With a passphrase set the door asks the CURRENT one (no "again" field).
    @Test func aPassphraseSetIsAskedAsTheCurrentOne() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: "a passphrase") == .set)
        let faces = try CrossingPlant.faces(road, session)
        let open = try #require(faces.useCastle.openDoor)
        #expect(!open.newPassphrase)
    }

    /// In Castle: Use Standard is OPEN with rule 12's leave sentence (her words); Use Castle renders nothing; the
    /// gate-style row stands with this Mac's choice.
    @Test func inCastleUseStandardSaysTheLeaveSentenceAndTheGateRowStands() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let faces = try CrossingPlant.faces(road, session) {
            $0.unlocked?.record.mode = .castle
            $0.unlocked?.record.passphraseSet = true
            $0.unlocked?.thisMac.settings.gateStyle = .touchID
            $0.biometry = .ready
        }
        #expect(faces.mode == .castle)
        #expect(faces.useCastle == .hidden)
        let open = try #require(faces.useStandard.openDoor)
        #expect(open.ask == .passphraseAndWords)
        #expect(!open.newPassphrase)
        #expect(open.sentences == [ProtectionWords.useStandardLead, ProtectionWords.leaveSentence])
        #expect(open.gate == nil)
        #expect(faces.gateRow == RoadGateRow(current: .touchID, touchIDAvailable: true))
        // No choice yet reads as Always ask (no item exists without a press).
        let none = try CrossingPlant.faces(road, session) {
            $0.unlocked?.record.mode = .castle
            $0.unlocked?.thisMac.settings.gateStyle = nil
            $0.biometry = .none
        }
        #expect(none.gateRow == RoadGateRow(current: .alwaysAsk, touchIDAvailable: false))
    }

    /// The scheduled export on → Use Castle says it turns off (rule 11); a copy under an Apple key this Mac lists as its
    /// own but can't read → rule 25's sentence and the copy NAMED.
    @Test func useCastleNamesTheCopiesUnderAKeyThisMacCantDeleteAndTheExportTurningOff() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        road.apple.keys = [:]  // this Mac's own Apple key — left in an Apple account it no longer uses
        let (facts, assessment) = try CrossingPlant.read(road, session) {
            $0.unlocked?.thisMac.settings.scheduledExport = true
        }
        let backup = try #require(facts.catalog.copies.first { $0.kind == .backup })
        let faces = try #require(RoadCrossingFaces.derive(facts, assessment) { $0 == backup.id ? "the backup" : nil })
        let open = try #require(faces.useCastle.openDoor)
        #expect(open.undeletableCopies == ["the backup"])
        #expect(open.sentences.contains(ProtectionWords.copiesUnderAKeyThisMacCantDelete))
        #expect(open.sentences.last == ProtectionWords.scheduledExportTurnsOff)
        // A copy the catalogue no longer names is left out, and with none named the sentence goes with it.
        let gone = try #require(RoadCrossingFaces.derive(facts, assessment) { _ in nil })
        #expect(gone.useCastle.openDoor?.undeletableCopies == [])
        #expect(!(gone.useCastle.openDoor?.sentences.contains(ProtectionWords.copiesUnderAKeyThisMacCantDelete) ?? true))
    }

    /// A synced library: Replace All Keys opens (the account's sync key stays — P-VX378-U2-1); the doors' refusals say
    /// their sentence IN PLACE when the library can't act now (a follow owed; the vault unread; another account; signed
    /// out) — never a dead button.
    @Test func aSyncedLibrarysDoorsSayTheirRefusalsInPlace() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        func synced(_ facts: inout ProtectionFacts, session fact: SessionFact, vault: ProtectionMode?) {
            facts.unlocked?.record.account = "account-a"
            facts.unlocked?.record.accountRowKeyID = "row-1"
            facts.session = fact
            facts.vault = vault.map { VaultReading(accountID: "account-a", mode: $0, rowKeyID: "row-1") }
        }
        let inSync = try CrossingPlant.faces(road, session) {
            synced(&$0, session: .signedIn(accountID: "account-a", email: nil), vault: .standard)
        }
        let replace = try #require(inSync.replaceAllKeys.openDoor)
        #expect(replace.synced && replace.ask == .passphraseAndWords)
        #expect(replace.sentences == [ProtectionWords.replaceAllKeysLead])
        #expect(inSync.useCastle.openDoor?.synced == true)

        let unread = try CrossingPlant.faces(road, session) {
            synced(&$0, session: .signedIn(accountID: "account-a", email: nil), vault: nil)
        }
        #expect(unread.useCastle == .refused(ProtectionWords.doorRefusedNeedsVault))
        #expect(unread.replaceAllKeys == .refused(ProtectionWords.doorRefusedNeedsVault))

        let moved = try CrossingPlant.faces(road, session) {
            synced(&$0, session: .signedIn(accountID: "account-a", email: nil), vault: .castle)
        }
        #expect(moved.useCastle == .refused(ProtectionWords.doorRefusedFollowOwed))

        let other = try CrossingPlant.faces(road, session) {
            synced(&$0, session: .signedIn(accountID: "account-b", email: nil), vault: nil)
        }
        #expect(other.useCastle == .refused(ProtectionWords.doorRefusedOtherAccount))

        let out = try CrossingPlant.faces(road, session) { synced(&$0, session: .signedOut, vault: nil) }
        // VX-308 U1 (VX-264, R-1 as amended) — the deliberate flip: Use Castle while signed out renders its door, whose
        // press shows the signed-out screen (This Mac Only, then Use Castle); Replace All Keys keeps its sentence.
        #expect(out.useCastle == .signedOutRoad)
        #expect(out.replaceAllKeys == .refused(ProtectionWords.doorRefusedSignedOut))
    }

    /// What `SecretRequirement` asks, read into fields — exactly (the crossings' is both typed).
    @Test func theAskIsTheRequirementsExactly() {
        #expect(RoadDoorAsk.of(.passphraseAndWords(wordsMayBeNew: false)) == .passphraseAndWords)
        #expect(RoadDoorAsk.of(.oneSecret) == .oneSecret)
        #expect(RoadDoorAsk.of(.currentPassphrase) == .passphrase)
        #expect(RoadDoorAsk.of(.none) == .nothing)
        #expect(RoadDoorAsk.passphraseAndWords.asksPassphrase && RoadDoorAsk.passphraseAndWords.asksWords)
        #expect(!RoadDoorAsk.oneSecret.asksWords)
    }

    /// The act's refusals, said — what was typed, named; a door that closed meanwhile; anything else never claims more
    /// than "nothing changed".
    @Test func theActsRefusalsAreSaid() {
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.passphraseDoesNotOpen) == ProtectionWords.passphraseDoesNotOpen)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.wordsDoNotOpen) == ProtectionWords.wordsDoNotOpen)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.secretMissing) == ProtectionWords.crossingSecretsMissing)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.wrongMode(.castle)) == ProtectionWords.crossingDoorClosed)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.accountMoved) == ProtectionWords.doorRefusedFollowOwed)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.noLiveKeyFile) == ProtectionWords.crossingFailed)
        #expect(RoadCrossingFaces.actRefusalSentence(ExecutorRefusal.passphraseChangedElsewhere(device: "the Air", day: nil))
            == "Your passphrase was changed on the Air.")
    }
}

@Suite("VX-307 U2a — the crossings' words: hers verbatim from the rules, the rest sentence case")
struct RoadCrossingWordsTests {
    /// `notes/CastleRules.md`, its whitespace runs collapsed (the rules wrap mid-sentence).
    static func rules() throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("notes/CastleRules.md")
        let text = try String(contentsOf: url, encoding: .utf8)
        return text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
    }

    static func lowercasingFirst(_ string: String) -> String { string.prefix(1).lowercased() + string.dropFirst() }

    /// Rule 12: "The leave screen says so plainly: *your library and all your backups will open …, don't leave.*"
    @Test func theLeaveSentenceIsRule12sVerbatim() throws {
        let rules = try Self.rules()
        #expect(rules.contains("*\(Self.lowercasingFirst(ProtectionWords.leaveSentence))*"))
        #expect(rules.contains("leave screen says so plainly"))
    }

    /// Rule 9: "**Castle is one promise: no quiet road through Apple, ever, on any device of the account.**"
    @Test func thePromiseIsRule9sVerbatim() throws {
        #expect(try Self.rules().contains("**\(ProtectionWords.castlePromise)**"))
    }

    /// The doors carry the canon's names (an ellipsis on the door — a confirm follows), the confirm's title is the act,
    /// and each crossing speaks its own receipt.
    @Test func eachDoorCarriesItsNameTitleAndReceipt() {
        #expect(RoadCrossingDoor.allCases.map(\.doorLabel) == ["Use Castle\u{2026}", "Use Standard\u{2026}", "Replace All Keys\u{2026}"])
        #expect(RoadCrossingDoor.allCases.map(\.title) == ["Use Castle", "Use Standard", "Replace All Keys"])
        #expect(RoadCrossingDoor.allCases.map(\.receipt) == [
            ProtectionWords.enteredCastleReceipt, ProtectionWords.leftCastleReceipt, ProtectionWords.replacedKeysReceipt,
        ])
        #expect(RoadCrossingDoor.allCases.map(\.door) == [.useCastle, .useStandard, .replaceAllKeys])
    }

    /// Her no-shouty-caps rule: no word in a crossing's line is set in capitals for emphasis (the doors' canon names and
    /// "OK"/"ID" are the only capitals beyond a sentence's first letter and the proper names).
    @Test func noCrossingLineShouts() {
        let lines = [
            ProtectionWords.useCastleLead, ProtectionWords.castleFloor, ProtectionWords.exportAPlainCopyFirst,
            ProtectionWords.copiesUnderAKeyThisMacCantDelete, ProtectionWords.scheduledExportTurnsOff,
            ProtectionWords.gateTouchIDLine, ProtectionWords.gateAlwaysAskLine, ProtectionWords.useStandardLead,
            ProtectionWords.replaceAllKeysLead, ProtectionWords.crossingNewPassphraseLead, ProtectionWords.crossingFailed,
            ProtectionWords.crossingDoorClosed, ProtectionWords.exportTurnedOffNotice, ProtectionWords.gateRowTouchID,
            ProtectionWords.gateRowAlwaysAsk, ProtectionWords.rearmQuestion, ProtectionWords.enteredCastleReceipt,
            ProtectionWords.leftCastleReceipt, ProtectionWords.replacedKeysReceipt, ProtectionWords.doorRefusedOtherAccount,
            ProtectionWords.doorRefusedSignedOut, ProtectionWords.doorRefusedNeedsVault, ProtectionWords.doorRefusedFollowOwed,
        ]
        for line in lines {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { word in
                word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
            }
            #expect(shouting.isEmpty, "\(line) — \(shouting)")
        }
    }
}
