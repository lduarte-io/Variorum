//
//  RoadKeyDoorWordsTests.swift
//  VariorumTests — VX-308 U3 piece 2: THE KEY DOORS' WORDS, VX-447's banner door and F-U2-3's line. VX-263's ONE line is
//  the plan's (§2's ledger and §5c — "your current secrets open everything you've made of this library"), read here and
//  pinned AS DRAFTED (the first letter capitalized, the period added); her U2-7 (1) first sentence is REUSED by the banner
//  door, never restated (the prefix of her pinned constant); the new road's Copy caption says the new rule (VX-448). Every
//  other line PROVISIONAL, pinned as drafted. No line shouts. Pure (also runs headless in the implementer's harness).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U3 — the key doors' words, the banner door, the synced look's line")
struct RoadKeyDoorWordsTests {
    /// The plan file, its whitespace runs collapsed (it wraps mid-sentence).
    static func plan() throws -> String {
        try RoadAccountWordsTests.repoFile("notes/plans/vx-308-accounts-key-doors.md")
            .split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
    }

    /// VX-263's one line — VX-309 U2, FLIPPED DELIBERATELY: the line is the route finder's ONE sentence as `notes/CastleRules.md`
    /// rewords it (the considered-and-not-pursued ledger: *your current passphrase or words; on this Mac, its quiet road if it
    /// still holds that key*), fitted to the key doors' sentence (PROVISIONAL P-VX309-U2-6). It superseded the VX-308 plan's
    /// draft (*your current secrets open everything you've made of this library*), which this pin read until now.
    @Test func vx263sOneLineIsTheRulesRouteFinderSentence() throws {
        let rules = try RoadAccountWordsTests.rules()
        #expect(rules.contains("*your current passphrase or words; on this Mac, its quiet road if it still holds that key.*"),
                "the rules' ledger sentence stands")
        let line = ProtectionWords.keyDoorsLine
        #expect(line == "Every copy of this library opens with your current passphrase or words; on this "
            + "\(ProtectionCopy.deviceName), its quiet road opens it too, if it still holds that copy's key.")
        for words in ["your current passphrase or words", "its quiet road", "if it still holds that"] {
            #expect(line.contains(words), "the rules' words: \(words)")
        }
    }

    /// VX-447: the banner door reuses her U2-7 (1) first sentence byte for byte (the prefix of her pinned constant —
    /// `ProtectionWordsVX307Tests` pins that constant to the VX-414 ticket), then its own door line.
    @Test func theBannerDoorReusesHerFirstSentence() {
        #expect(ProtectionWords.noKeyFileOpenedLead
            == "Variorum opened your library, but found no key file for it anywhere.")
        #expect(ProtectionWords.noKeyFileAfterAQuietOpen.hasPrefix(ProtectionWords.noKeyFileOpenedLead + " "))
        #expect(ProtectionWords.noKeyFileDoor == "Click here to record your twelve words \u{2014} Variorum makes a new key "
            + "file with them, then a backup.")
        #expect(ProtectionWords.noKeyFileAccountRoadOpen == "This library syncs with your account, so your writing is "
            + "kept there too \u{2014} your passphrase or twelve words bring it back on any device.")
        #expect(ProtectionWords.noKeyFileAccountRoadOpen != ProtectionWords.noKeyFileAnywhereAccountRoad,
                "F-U2c-5: the open library's variant, the lobby's sentence kept for the lobby")
        #expect(ProtectionWords.keyFileRemadeReceipt(backedUp: true)
            == "Your library has a key file again, and a backup holds a copy.")
        #expect(ProtectionWords.keyFileRemadeReceipt(backedUp: false) == "Your library has a key file again.")
    }

    /// F-U2-3 (the architect's ruling) and VX-448's caption, as drafted.
    @Test func theSyncedLookLineAndTheNewCopyCaptionReadAsDrafted() {
        #expect(ProtectionWords.wordsLookReplacesAccountWords == "This library syncs with your account, so new words also "
            + "replace your account's twelve words, on every device.")
        #expect(ProtectionWords.wordsLookCopied == "Copied. Your clipboard keeps them until you copy something else, your "
            + "library locks or Variorum quits.")
        #expect(!ProtectionWords.wordsLookCopied.contains("60"), "VX-448: the 60-second timer is gone from the new road")
        // (VX-329 U1: today's own sentence, `ProtectionCopy.wordsCopied`, left with today's words screens.)
    }

    /// The key doors as drafted (PROVISIONAL P-VX308-U3-2).
    @Test func theKeyDoorsReadAsDrafted() {
        #expect(ProtectionWords.changePassphraseDoor == "Change passphrase\u{2026}")
        #expect(ProtectionWords.resetPassphraseDoor == "Reset forgotten passphrase\u{2026}")
        #expect(ProtectionWords.resetPassphraseStandardLead == "This \(ProtectionCopy.deviceName) holds your library's "
            + "key, so you can choose a new passphrase without the old one.")
        #expect(ProtectionWords.resetPassphraseCastleTouchIDLead == "Confirm it's you with your twelve words or "
            + "\(ProtectionCopy.biometryName), then choose a new passphrase.")
        #expect(ProtectionWords.keyDoorsSyncedPassphraseLine == "This library syncs with your account, so your account's "
            + "passphrase changes with it, on every device.")
        #expect(ProtectionWords.keyDoorNewPassphraseField == ProtectionWords.crossingNewPassphraseField)
    }

    /// Her no-shouty-caps rule.
    @Test func noKeyDoorLineShouts() {
        let lines = [
            ProtectionWords.keyDoorsLine, ProtectionWords.keyDoorsSyncedPassphraseLine, ProtectionWords.passphraseSectionTitle,
            ProtectionWords.changePassphraseDoor, ProtectionWords.changePassphraseTitle,
            ProtectionWords.changePassphraseCurrentField, ProtectionWords.changePassphraseButton,
            ProtectionWords.changePassphraseReceipt, ProtectionWords.resetPassphraseDoor, ProtectionWords.resetPassphraseTitle,
            ProtectionWords.resetPassphraseStandardLead, ProtectionWords.resetPassphraseCastleLead,
            ProtectionWords.resetPassphraseCastleTouchIDLead, ProtectionWords.resetPassphraseWordsField,
            ProtectionWords.resetPassphraseButton, ProtectionWords.resetPassphraseWithTouchID,
            ProtectionWords.resetPassphraseTouchIDNotConfirmed, ProtectionWords.resetPassphraseReceipt,
            ProtectionWords.keyDoorCancel, ProtectionWords.keyDoorWorking, ProtectionWords.wordsLookReplacesAccountWords,
            ProtectionWords.noKeyFileOpenedLead, ProtectionWords.noKeyFileDoor, ProtectionWords.noKeyFileAccountRoadOpen,
            ProtectionWords.keyFileRemadeReceipt(backedUp: true), ProtectionWords.keyFileRemadeReceipt(backedUp: false),
            ProtectionWords.wordsLookCopied,
        ]
        for line in lines {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { word in
                word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
            }
            #expect(shouting.isEmpty, "\(line) — \(shouting)")
        }
    }
}
