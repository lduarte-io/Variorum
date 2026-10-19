//
//  ProtectionWordsPlanTests.swift
//  VariorumTests — VX-306 U2 piece 1: THE WORDS ARE THE PLAN'S. Every string §7c drafts
//  (`notes/plans/vx-306-castle-open-road.md` — built exactly as drafted, PROVISIONAL, hers at the bundle) is pinned
//  BYTE-EQUAL to the plan file itself, read here: the plan's prose wraps lines and sets each string in *italics*, so
//  the text is read with its whitespace runs collapsed to one space and each string looked up between its asterisks.
//  An edit to §7c's words (her sitting) turns this red until `ProtectionWords.swift` follows. The notice's two
//  sentences and the offer's are the MODEL's constants (`LibraryNotice`, `KeyFileOffer`) — pinned against the plan
//  here too, never restated in the words file.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — the words are the plan's (§7c, byte-equal)")
struct ProtectionWordsPlanTests {
    /// The plan file, its whitespace runs collapsed (the prose wraps mid-sentence).
    static func plan() throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("notes/plans/vx-306-castle-open-road.md")
        let text = try String(contentsOf: url, encoding: .utf8)
        return text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
    }

    /// The §7c section alone (from its heading to §8's).
    static func section7c() throws -> String {
        let plan = try plan()
        let start = try #require(plan.range(of: "## 7c. THE WORDS"))
        let end = try #require(plan.range(of: "## 8. ENVIRONMENT TRAPS"))
        return String(plan[start.lowerBound..<end.lowerBound])
    }

    static func italic(_ string: String) -> String { "*\(string)*" }

    @Test func theOfferRule27TheNoticeTheRestoreAndTheReminderAreSection7cVerbatim() throws {
        let words = try Self.section7c()
        let drafted: [String] = [
            // (2) the offer
            ProtectionWords.offerUseIt, ProtectionWords.offerNotNow, ProtectionWords.offerRestoredFromKeychain,
            // (VX-414: §7c (2)'s split-pair line is dropped — no state reaches it; the plan keeps its draft as history.)
            // (3) rule 27 + its doors
            ProtectionWords.noKeyFileAnywhere, ProtectionWords.noKeyFileAnywhereAccountRoad,
            ProtectionWords.noKeyFileRestoreDoor, ProtectionWords.noKeyFileOpenDoor, ProtectionWords.noKeyFileStartDoor,
            // (4) the notice's one button
            ProtectionWords.noticeOK,
            // (6) rule 1's restore
            ProtectionWords.restoredFromMirror,
            // (7) the reminder and the set-passphrase sheet
            ProtectionWords.reminderLine, ProtectionWords.reminderSetDoor, ProtectionWords.reminderNotNow,
            ProtectionWords.reminderDontShowAgain, ProtectionWords.setPassphraseTitle, ProtectionWords.setPassphraseLead,
            ProtectionWords.setPassphraseField, ProtectionWords.setPassphraseAgain, ProtectionWords.setPassphraseButton,
            ProtectionWords.passphraseSetReceipt,
        ]
        for string in drafted {
            #expect(words.contains(Self.italic(string)), "§7c drafts *\(string)* — byte-equal")
        }
        // The backup receipt is drafted as its tail ("*… from the backup from <date>.*") after the keychain one's head.
        #expect(words.contains(Self.italic("\u{2026} from the backup from <date>.")))
        #expect(ProtectionWords.offerRestoredFromBackup("<date>") == "Key file restored from the backup from <date>.")
        #expect(ProtectionWords.offerRestoredFromKeychain.hasPrefix("Key file restored from "))
    }

    /// VX-306 U3 — Make this my library's confirm, its receipt and Look inside's frame line (§7c (8)–(10)), and the
    /// two doors' names (the plan's U3 addendum: "each row with *Look inside…* and *Make this my library…*").
    @Test func theTwoDoorsWordsAreSection7cAndTheAddendumVerbatim() throws {
        let words = try Self.section7c()
        for string in [
            ProtectionWords.makeMineTitle, ProtectionWords.makeMineLead, ProtectionWords.makeMineCopySecretField,
            ProtectionWords.makeMineWordsField, ProtectionWords.makeMinePassphraseField, ProtectionWords.makeMineButton,
            ProtectionWords.makeMineReceipt, ProtectionWords.lookInsideFrame("<date>"),
        ] {
            #expect(words.contains(Self.italic(string)), "§7c drafts *\(string)* — byte-equal")
        }
        // The lead the confirm shows is the drafted one whenever a passphrase is set (P-VX306-U3-3: without one, the
        // passphrase clause alone is left out).
        #expect(ProtectionWords.makeMineLeadShown(passphraseSet: true) == ProtectionWords.makeMineLead)
        let without = ProtectionWords.makeMineLeadShown(passphraseSet: false)
        #expect(!without.contains("passphrase") && without.contains("under your current twelve words — with a fresh key"))
        let plan = try Self.plan()
        let addendum = try #require(plan.range(of: "**U3 brief addendum"))
        let doors = String(plan[addendum.lowerBound...])
        #expect(doors.contains(Self.italic(ProtectionWords.lookInsideDoor)))
        #expect(doors.contains(Self.italic(ProtectionWords.makeMineDoor)))
    }

    /// The model's constants — her sentences — are the plan's too (the face reads them, never restates them).
    @Test func theNoticeAndTheOfferSentencesAreTheModelsAndThePlans() throws {
        let words = try Self.section7c()
        #expect(words.contains(Self.italic(LibraryNotice.olderCopyWords)))
        #expect(words.contains(Self.italic(LibraryNotice.differentLibraryWords)))
        #expect(words.contains(Self.italic("\(KeyFileOffer.besideDoesNotOpenIt) \(KeyFileOffer.keychainHoldsOne)")))
        #expect(words.contains(KeyFileOffer.backupHoldsOne))
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Shared/Protection/ProtectionWords.swift"),
            encoding: .utf8)
        for theirs in [LibraryNotice.olderCopyWords, LibraryNotice.differentLibraryWords,
                       KeyFileOffer.besideDoesNotOpenIt, KeyFileOffer.keychainHoldsOne] {
            #expect(!source.contains(theirs), "the words file never restates the model's sentence: \(theirs)")
        }
    }

    /// The day written in for `<date>`: her example's form, the year only when it isn't this year's.
    @Test func theDayReadsAsHerExampleDoes() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "UTC"))
        let august3 = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 3, hour: 12)))
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 18, hour: 12)))
        let later = try #require(calendar.date(from: DateComponents(year: 2027, month: 1, day: 5, hour: 12)))
        let thisYear = ProtectionWords.day(august3, now: now, calendar: calendar)
        let lastYear = ProtectionWords.day(august3, now: later, calendar: calendar)
        #expect(thisYear.contains("3") && !thisYear.contains("2026"), "\(thisYear)")
        #expect(lastYear.contains("2026"), "\(lastYear)")
    }
}
