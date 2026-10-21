//
//  PassphraseFloorRoadTests.swift
//  VariorumTests — VX-309 U2 piece 6: VX-211 — "FLOOR + QUIET HINT" (her kickoff ruling, 2026-10-19): the 12-character
//  floor stays the ONLY refusal. Her 17n ruling binds the floor "where a passphrase is SET" (`ProtectionCopy
//  .passphraseFloor`, its one refusal sentence `ProtectionCopy.passphraseTooShort` — today's road's setters all say it), and
//  NONE of the new road's setters enforced it (F-U1-2 / F-U3-4, routed at VX-308): the Set a passphrase sheet, a crossing's
//  new passphrase, turning sync on with a new one, and the key doors' new passphrase took any length. RED ON OLD: each of the
//  four took an 11-character passphrase to its road. The floor binds only where one is SET: Change's CURRENT field is never
//  floored (an existing shorter passphrase keeps opening the library). Also runs headless in the implementer's harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U2 — VX-211: the 12-character floor on the new road's setters")
@MainActor
struct PassphraseFloorRoadTests {
    static let short = "elevenchars"            // 11
    static let floor = "twelve chars"           // 12 — the floor itself passes
    static let words = (try? RecoveryPhrase.generate()) ?? []

    /// THE QUIET HINT (the estimator's advice in words — PROVISIONAL): nothing for an empty field or a long, varied phrase;
    /// the short and the repetitive lines otherwise; NEVER a refusal (a 12-character passphrase that earns the hint is SET).
    @Test func theQuietHintIsAdviceNeverABlock() async {
        #expect(NewPassphraseRule.hint("") == nil)
        #expect(NewPassphraseRule.hint("the lamp by the north window") == nil)
        #expect(NewPassphraseRule.hint(Self.floor)
            == "Short passphrases are easier to guess \u{2014} a longer phrase is stronger.")
        #expect(NewPassphraseRule.hint("aaaaaaaaaaaaaaaaaaaaaaaa")
            == "Repeated characters are easy to guess \u{2014} a phrase of a few different words is stronger.")
        for advice in [PassphraseAdvice.short, .repetitive] {
            let line = ProtectionWords.passphraseHint(advice) ?? ""
            #expect(U2WordsTests.shouts(line).isEmpty && !line.isEmpty)
        }
        var asked: [String] = []
        let model = SetPassphraseModel(alreadySet: false, setRoad: { asked.append($0); return .set }) { _ in }
        await model.submit(passphrase: Self.floor, again: Self.floor)
        #expect(asked == [Self.floor] && model.refusal == nil, "the hint never blocks")
    }

    /// The hint's homes (by source): every new-road field that SETS a passphrase renders it, right under the field.
    @Test func everyNewPassphraseFieldRendersTheHint() throws {
        let protection = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features/Protection")
        for (file, field, text) in [
            ("SetPassphraseSheet.swift", "ProtectionWords.setPassphraseField", "passphrase"),
            ("RoadKeyDoorSheet.swift", "ProtectionWords.keyDoorNewPassphraseField", "new"),
            ("RoadCrossingSheet.swift", "ProtectionWords.crossingNewPassphraseField", "passphrase"),
            ("RoadAccountSheet.swift", "ProtectionWords.crossingNewPassphraseField", "passphrase"),
        ] {
            let source = try String(contentsOf: protection.appendingPathComponent(file), encoding: .utf8)
            let after = try #require(source.components(separatedBy: "PeekableSecretField(label: \(field)").dropFirst().first,
                                     "\(file) sets a passphrase")
            #expect(after.prefix(220).contains("PassphraseHintLine(passphrase: \(text))"), "\(file): the hint under the field")
        }
        let band = try String(contentsOf: protection.appendingPathComponent("WordsBandCard.swift"), encoding: .utf8)
        #expect(band.contains("NewPassphraseRule.hint(passphrase)"), "the tour's last card, in the card's voice")
    }

    /// THE SET-A-PASSPHRASE SHEET (rule 3's): under the floor refused with its one sentence, the road never asked.
    @Test func theSetPassphraseSheetRefusesUnderTheFloor() async {
        var asked: [String] = []
        let model = SetPassphraseModel(alreadySet: false, setRoad: { asked.append($0); return .set }) { _ in }
        #expect(Self.short.count == 11 && Self.floor.count == 12)
        await model.submit(passphrase: Self.short, again: Self.short)
        #expect(model.refusal == ProtectionCopy.passphraseTooShort && asked.isEmpty)
        await model.submit(passphrase: Self.floor, again: Self.floor)
        #expect(asked == [Self.floor], "the floor itself is enough")
    }

    /// A CROSSING's new passphrase (Use Castle on a library with none yet — rule 3: Castle needs one).
    @Test func aCrossingsNewPassphraseRefusesUnderTheFloor() async {
        var asked: [RoadCrossingRequest] = []
        let confirm = RoadCrossingConfirmModel(
            door: PlantedCrossingRoads.useCastle(newPassphrase: true),
            act: { asked.append($0); return .made(exportTurnedOff: false) }) { _ in }
        await confirm.submit(passphrase: Self.short, again: Self.short, words: Self.words.joined(separator: " "))
        #expect(confirm.refusal == ProtectionCopy.passphraseTooShort && asked.isEmpty)
        await confirm.submit(passphrase: Self.floor, again: Self.floor, words: Self.words.joined(separator: " "))
        #expect(asked.count == 1)
    }

    /// TURNING SYNC ON with a new passphrase (rule 14: the account is locked under the passphrase and the words).
    @Test func turningSyncOnWithANewPassphraseRefusesUnderTheFloor() async {
        var asked: [RoadAccountRequest] = []
        let confirm = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(newPassphrase: true),
            act: { asked.append($0); return .made(receipt: "on") }) { _ in }
        await confirm.submit(passphrase: Self.short, again: Self.short, words: Self.words.joined(separator: " "))
        #expect(confirm.refusal == ProtectionCopy.passphraseTooShort && asked.isEmpty)
        await confirm.submit(passphrase: Self.floor, again: Self.floor, words: Self.words.joined(separator: " "))
        #expect(asked.count == 1)
    }

    /// THE KEY DOORS' new passphrase — Change (its CURRENT field never floored) and the forgot road's both presses.
    @Test func theKeyDoorsNewPassphraseRefusesUnderTheFloorAndTheCurrentOneNever() async {
        var asked: [RoadKeyDoorRequest] = []
        let change = RoadKeyDoorConfirmModel(
            door: RoadKeyDoorsModelTests.open(.changePassphrase),
            act: { asked.append($0); return .made("changed") }) { _ in }
        await change.submit(current: "old", new: Self.short, again: Self.short)
        #expect(change.refusal == ProtectionCopy.passphraseTooShort && asked.isEmpty)
        await change.submit(current: "old", new: Self.floor, again: Self.floor)
        #expect(asked.count == 1 && asked.first?.current == "old", "a short CURRENT passphrase still opens — never floored")
        let reset = RoadKeyDoorConfirmModel(
            door: RoadKeyDoorsModelTests.open(.resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: true)),
            act: { asked.append($0); return .made("reset") }) { _ in }
        await reset.submitWithTouchID(new: Self.short, again: Self.short)
        #expect(reset.refusal == ProtectionCopy.passphraseTooShort && asked.count == 1)
        await reset.submit(new: Self.short, again: Self.short, words: Self.words.joined(separator: " "))
        #expect(reset.refusal == ProtectionCopy.passphraseTooShort && asked.count == 1)
    }
}
