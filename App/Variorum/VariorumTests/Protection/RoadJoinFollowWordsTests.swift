//
//  RoadJoinFollowWordsTests.swift
//  VariorumTests — VX-308 U2 piece 1: THE JOIN'S AND THE FOLLOW'S WORDS. Her sentences these faces say are the ones already
//  pinned byte-equal to `notes/CastleRules.md` (rule 7's join sentence and its first, rule 12's leave sentence, rule 9's
//  promise, rule 16's) — re-read here against the rules file, so a face that says them says hers; VX-113's sentence is her
//  #205 ruling (ii)'s form (*Your passphrase was changed on [device] on [day]*); the rest is PROVISIONAL P-VX308-U2-1,
//  pinned AS DRAFTED. VX-107's Done names the other device for every kind. No line shouts. Pure (also runs headless in the
//  implementer's SwiftPM harness).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U2 — the join's and the follow's words")
struct RoadJoinFollowWordsTests {
    /// Her sentences these faces say, against the rules file (U1's reader — the wrapped whitespace collapsed).
    @Test func herSentencesTheseFacesSayAreHersVerbatim() throws {
        let rules = try RoadAccountWordsTests.rules()
        func says(_ text: String) -> Bool { rules.contains(text) }
        // Rule 7's italic closes before its period; rule 12's around it.
        #expect(says("*\(RoadAccountWordsTests.lowercasingFirst(String(ProtectionWords.joinWordsSentence.dropLast())))*."),
                "rule 7's join sentence — the words moment's")
        #expect(says("7. \(ProtectionWords.onePairAtATime)"), "rule 7's first sentence — the join's")
        #expect(says("*\(RoadAccountWordsTests.lowercasingFirst(ProtectionWords.leaveSentence))*"),
                "rule 12's leave sentence — the join out of Castle's and the follow out's")
        #expect(says("9. \(ProtectionWords.castlePromise)"), "rule 9's promise — the join into Castle's")
        #expect(says("16. \(ProtectionWords.ruleSixteen)"), "rule 16's — Move's")
    }

    /// VX-113 — her #205 ruling (ii), verbatim in form: "I think your passphrase was changed on device on day would be good."
    @Test func vx113sSentenceNamesTheDeviceAndTheDay() {
        #expect(ProtectionWords.passphraseChangedElsewhere(device: "Studio Mac", day: "October 19")
            == "Your passphrase was changed on Studio Mac on October 19.")
        #expect(ProtectionWords.passphraseChangedElsewhere(device: nil, day: "October 19")
            == "Your passphrase was changed on October 19.")
        #expect(ProtectionWords.passphraseChangedElsewhere(device: "Studio Mac", day: nil)
            == "Your passphrase was changed on Studio Mac.")
    }

    /// VX-107 — every kind's Done carries its other-device sentence (the face re-says it from durable facts).
    @Test func vx107sDoneNamesTheOtherDeviceForEveryKind() {
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            #expect(ProtectionWords.followDone(kind).contains("on another device"), "\(kind)")
        }
        #expect(ProtectionWords.followDone(.intoCastle)
            == "Your account entered Castle on another device, and this \(ProtectionCopy.deviceName) followed it.")
        #expect(ProtectionWords.followDone(.intoStandard)
            == "Your account left Castle on another device, and this \(ProtectionCopy.deviceName) followed it out.")
        #expect(ProtectionWords.followDone(.keysReplaced)
            == "Your account's keys changed on another device, and this \(ProtectionCopy.deviceName) caught up.")
    }

    /// THE FOLLOW'S NOTICE AS DRAFTED (PROVISIONAL): the vault's last writer and its day where the read has them.
    @Test func theFollowsNoticeReadsAsDrafted() {
        #expect(ProtectionWords.followNotice(.intoCastle, device: "Studio Mac", day: "October 19")
            == "Your account entered Castle on Studio Mac on October 19.")
        #expect(ProtectionWords.followNotice(.intoStandard, device: nil, day: nil) == "Your account left Castle on another device.")
        #expect(ProtectionWords.followNotice(.keysReplaced, device: nil, day: "October 19")
            == "Your account's keys changed on another device on October 19.")
        #expect(ProtectionWords.followAsk(.intoStandard).contains("without asking you for anything"), "rule 12: quietly")
        #expect(ProtectionWords.followAsk(.intoCastle).contains("once") && ProtectionWords.followAsk(.keysReplaced).contains("once"),
                "rule 10: each typing a secret once")
    }

    /// THE JOIN AS DRAFTED (PROVISIONAL): the consent says which plan; the receipt says the posture where it changed; the
    /// words moment with the passphrase typed says the words were replaced WITHOUT showing them (P-VX378-U2-3 (a)).
    @Test func theJoinReadsAsDrafted() {
        #expect(ProtectionWords.joinPlanLine(.entersCastle, library: .standard)
            == "Your account is in Castle, so this library goes into Castle too.")
        #expect(ProtectionWords.joinPlanLine(.leavesCastle, library: .castle)
            == "Your account is in Standard, so this library leaves Castle.")
        #expect(ProtectionWords.joinPlanLine(.sameMode, library: .castle) == "Your account is in Castle, like this library.")
        #expect(ProtectionWords.joinPlanLine(.sameMode, library: .standard) == "Your account is in Standard, like this library.")
        #expect(ProtectionWords.joinPlanLine(.setsUpInLibrarysMode, library: .standard) == nil, "set-up is U1's confirm")
        #expect(ProtectionWords.joinedReceipt(.entersCastle, moved: false)
            == "Sync is on, and you're in Castle now, like your account.")
        // The ladder's round-1 NIT-2 — FLIPPED DELIBERATELY: Move's receipt says "now" once (it said it twice).
        #expect(ProtectionWords.joinedReceipt(.sameMode, moved: true)
            == "This library syncs with the signed-in account. Your library uses your account's passphrase and twelve "
            + "words now.")
        #expect(ProtectionWords.joinedReceipt(.entersCastle, moved: true)
            == "This library syncs with the signed-in account, and you're in Castle now, like your account.")
        for plan in [JoinPlan.entersCastle, .leavesCastle, .sameMode] {
            for moved in [false, true] {
                let receipt = ProtectionWords.joinedReceipt(plan, moved: moved)
                #expect(receipt.components(separatedBy: " now").count == 2, "one \"now\": \(receipt)")
            }
        }
        // VX-309 U2 — FLIPPED DELIBERATELY: the passphrase-typed moment is HER refined draft now (#236 — the library adopts
        // the ACCOUNT's words, named by email; the shipped "your library's twelve words are now your account's" read the
        // wrong way round). The middle clause keeps its sentence and drops only its conditional lead-in (the F-U2-1
        // arbitration: with VX-456 the moment fires only on a real replacement, so the previous-words fact is said
        // plainly, un-hedged, exactly when it is true).
        #expect(ProtectionWords.joinWordsNotShown("lillian@example.test")
            == "Your twelve words are lillian@example.test's twelve words. Your previous twelve words still open backups "
            + "you made before today. If you don't have your account's words written down, you can make new ones at any time.")
        #expect(ProtectionWords.joinWordsNotShown(nil)
            == "Your twelve words are your account's twelve words. Your previous twelve words still open backups you made "
            + "before today. If you don't have your account's words written down, you can make new ones at any time.")
        #expect(!ProtectionWords.joinWordsNotShown(nil).contains("here they are"), "the passphrase-typed moment shows nothing")
        #expect(!ProtectionWords.joinWordsNotShown(nil).contains("first time signing in"), "the conditional lead-in dropped")
        #expect(ProtectionWords.moveDoor("y@example.test") == "Move this library to y@example.test\u{2026}")
    }

    /// Her no-shouty-caps rule over every U2 line.
    @Test func noJoinOrFollowLineShouts() {
        var lines = [
            ProtectionWords.joinLead, ProtectionWords.joinPassphraseField, ProtectionWords.joinWordsField,
            ProtectionWords.joinWordsNotShown(nil), ProtectionWords.joinWordsMomentOK, ProtectionWords.moveDoor(nil),
            ProtectionWords.moveTitle, ProtectionWords.moveLead, ProtectionWords.moveButton, ProtectionWords.moveNotYet,
            ProtectionWords.followDoor, ProtectionWords.followTitle, ProtectionWords.followButton,
            ProtectionWords.followUntilThen, ProtectionWords.followPassphraseField, ProtectionWords.followWordsField,
        ]
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            lines += [ProtectionWords.followNotice(kind, device: "Studio Mac", day: "October 19"),
                      ProtectionWords.followAsk(kind), ProtectionWords.followDone(kind)]
        }
        for plan in [JoinPlan.entersCastle, .leavesCastle, .sameMode] {
            lines += [ProtectionWords.joinPlanLine(plan, library: .standard) ?? "",
                      ProtectionWords.joinedReceipt(plan, moved: false), ProtectionWords.joinedReceipt(plan, moved: true)]
        }
        for line in lines {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { word in
                word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
            }
            #expect(shouting.isEmpty, "\(line) — \(shouting)")
        }
    }
}
