//
//  RoadAccountWordsTests.swift
//  VariorumTests — VX-308 U1 piece 1: THE ACCOUNT SECTION'S WORDS. Rule 16's two sentences and rule 7's are HER words,
//  byte-equal to `notes/CastleRules.md` (read here); the turning-on lead is the lifecycle page's stage 12, byte-equal to
//  the rendered page; the sign-out confirm is today's shipped copy, byte-reused. The signed-out screens are drafted to the
//  CURRENT rules (her word 2026-10-19: the 10-13 block is superseded) — pinned AS DRAFTED, provisional, never against
//  the superseded block. No line shouts. Pure (also runs headless in the implementer's SwiftPM harness).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U1 — the account section's words")
struct RoadAccountWordsTests {
    static func repoFile(_ relative: String) throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent(relative)
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// `notes/CastleRules.md`, its whitespace runs collapsed and its bold marks dropped (the rules wrap mid-sentence and
    /// bold a rule's head).
    static func rules() throws -> String {
        try repoFile("notes/CastleRules.md").replacingOccurrences(of: "**", with: "")
            .split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
    }

    static func lowercasingFirst(_ string: String) -> String { string.prefix(1).lowercased() + string.dropFirst() }

    /// Rule 16: "Leaving an account changes none of your library's keys or secrets — it stops syncing, and the server
    /// keeps what you pushed (removing it is the account-deletion road). Signing back in is a join (rule 7)."
    @Test func rule16sTwoSentencesAreHersVerbatim() throws {
        let rules = try Self.rules()
        #expect(rules.contains("16. \(ProtectionWords.ruleSixteen)"))
        #expect(rules.contains("\(ProtectionWords.ruleSixteen) \(ProtectionWords.signingBackInIsAJoin.dropLast()) (rule 7)."))
    }

    /// Rule 7: "A device holds one pair of secrets at a time." and the join's sentence, italic in the rule.
    @Test func rule7sSentencesAreHersVerbatim() throws {
        let rules = try Self.rules()
        #expect(rules.contains("7. \(ProtectionWords.onePairAtATime)"))
        #expect(rules.contains("*\(Self.lowercasingFirst(String(ProtectionWords.joinWordsSentence.dropLast())))*"))
    }

    /// The turning-on lead is the lifecycle page's stage 12 ("Turning sync on first"), byte-equal to the rendered page.
    @Test func theTurningOnLeadIsTheLifecyclePages() throws {
        let page = try Self.repoFile("notes/plans/vx-266/castle-lifecycle.html")
        #expect(page.contains(String(ProtectionWords.turnOnSyncLead.dropLast(" Nothing is replaced.".count))))
        #expect(page.contains("Nothing is replaced"))
    }

    /// The sign-out confirm is today's shipped copy (decision 20's §4), byte-reused.
    @Test func theSignOutConfirmIsTheShippedCopy() {
        #expect(ProtectionWords.accountSignOutTitle == ProtectionCopy.signOutTitle)
        #expect(ProtectionWords.accountSignOutBody == ProtectionCopy.signOutBody)
        #expect(ProtectionWords.accountSignOutButton == ProtectionCopy.signOutDoor)
    }

    /// THE SIGNED-OUT SCREENS AS DRAFTED (PROVISIONAL — her morning eye decides): drafted to the current rules. The
    /// one-road shape (Continue / Cancel) and the true sentences of the 10-13 block stand; the block's "this Mac will stop
    /// using your old sync account" became the two steps the new road takes (the leave changes nothing — rule 16 — and Use
    /// Castle's own confirm types both secrets).
    @Test func theSignedOutScreensReadAsDrafted() {
        #expect(ProtectionWords.signedOutCastleTitle == "You're signed out of sync.")
        #expect(ProtectionWords.signedOutCastleLead == "Castle will apply to this library on this \(ProtectionCopy.deviceName) "
            + "only. First, this \(ProtectionCopy.deviceName) stops using your sync account \u{2014} none of your keys or "
            + "secrets change, and the account's copy on the server stays as it is. Then Use Castle asks for your passphrase "
            + "and your twelve words, as always.")
        #expect(ProtectionWords.signedOutCastleWholeAccount
            == "To put your whole account in Castle instead, cancel, sign in, and choose Use Castle again.")
        #expect(ProtectionWords.accountContinue == "Continue" && ProtectionWords.accountCancel == "Cancel")
        #expect(ProtectionWords.bornCastleNote == "Set up sync again later with a new account and it starts in Castle.")
        #expect(ProtectionWords.accountSignedOutLine == "This library still syncs with an account, but no one is signed in "
            + "on this \(ProtectionCopy.deviceName), so nothing syncs. Sign in to sync again, or use this library on this "
            + "\(ProtectionCopy.deviceName) only \u{2014} the account's copy on the server stays as it is.")
        #expect(ProtectionWords.thisMacOnlyLead
            == "This \(ProtectionCopy.deviceName) stops using your sync account and forgets its sync keys.")
    }

    /// The third leave is LOCAL (P-VX308-U1-F1) — it says so, and points once at where the real deletion lives.
    @Test func theThirdLeaveSaysItIsLocalAndPointsOnceAtTheDeletion() {
        #expect(ProtectionWords.deleteHereLead.contains("isn't deleted"))
        #expect(ProtectionWords.deleteHerePointer.contains("Delete Account"))
        let lines = [ProtectionWords.deleteHereTitle, ProtectionWords.deleteHereLead, ProtectionWords.deleteHereButton,
                     ProtectionWords.deleteHereReceipt, ProtectionWords.deleteAccountHereDoor]
        #expect(lines.allSatisfy { !$0.contains("Delete Account") }, "one pointer sentence names the real door")
    }

    /// Her no-shouty-caps rule: no word in an account line is set in capitals for emphasis.
    @Test func noAccountLineShouts() {
        let lines = [
            ProtectionWords.ruleSixteen, ProtectionWords.signingBackInIsAJoin, ProtectionWords.onePairAtATime,
            ProtectionWords.joinWordsSentence, ProtectionWords.accountSectionTitle, ProtectionWords.accountLocalOnly,
            ProtectionWords.accountInSync, ProtectionWords.accountSignedInAs("a@b.c"), ProtectionWords.accountSignedOut,
            ProtectionWords.accountSignedOutLine, ProtectionWords.accountOtherAccount, ProtectionWords.accountOtherAccountLine,
            ProtectionWords.accountSameEmailDifferentAccount, ProtectionWords.accountSignInToTurnOnSync,
            ProtectionWords.turnOnSyncDoor, ProtectionWords.stopSyncingHereDoor, ProtectionWords.deleteAccountHereDoor,
            ProtectionWords.thisMacOnlyDoor, ProtectionWords.accountSignOutDoor, ProtectionWords.accountSignInDoor,
            ProtectionWords.moveNotYet, ProtectionWords.turnOnSyncTitle,
            ProtectionWords.turnOnSyncLead, ProtectionWords.turnOnSyncPosture(.standard),
            ProtectionWords.turnOnSyncPosture(.castle), ProtectionWords.turnOnSyncNewPassphraseLead,
            ProtectionWords.turnOnSyncButton, ProtectionWords.turnOnSyncReceipt, ProtectionWords.stopSyncingTitle,
            ProtectionWords.stopSyncingLead, ProtectionWords.stopSyncingButton, ProtectionWords.stopSyncingReceipt,
            ProtectionWords.deleteHereTitle, ProtectionWords.deleteHereLead, ProtectionWords.deleteHerePointer,
            ProtectionWords.deleteHereButton, ProtectionWords.deleteHereReceipt, ProtectionWords.thisMacOnlyTitle,
            ProtectionWords.thisMacOnlyLead, ProtectionWords.thisMacOnlyReceipt, ProtectionWords.accountWorking,
            ProtectionWords.accountActUnfinished, ProtectionWords.signedOutCastleLead,
            ProtectionWords.signedOutCastleWholeAccount, ProtectionWords.bornCastleNote,
        ]
        for line in lines {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { word in
                word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
            }
            #expect(shouting.isEmpty, "\(line) — \(shouting)")
        }
    }
}
