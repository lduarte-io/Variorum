//
//  VX204PrivacyLessonTests.swift
//  VariorumTests
//
//  VX-204 — the field guide's privacy lesson stops overstating (RUN VX-201,
//  unit U4; auditor C's C-1 in notes/plans/fixes/vx-191-audit/; the brief and
//  the record: notes/plans/fixes/vx-201-castle-prelaunch-fixes.md §F and
//  "U4 RECORD (VX-204 + VX-206)").
//
//  THE DEFECT: lesson 1 ("What's true in every mode") said sync encrypts
//  "everything" and that the server "stores what it can never read". What is
//  built seals every text-bearing and named field, while dates, the tag tree's
//  shape and which notes carry which tags, book membership, flags like starred
//  or finished, and sizes travel outside the encryption — the envelope the
//  website privacy brief discloses and the in-app guide did not.
//
//  THE PIN (string level — `ProtectionCopy` is the ONE copy home both seeders
//  render; the seeded-text pins `TutorialWalkTests`' chapter render pin and
//  `MobileTutorialWalkTests`' lesson render pin already prove each seeder puts
//  every paragraph of it in the guide verbatim). RED ON OLD (the record's
//  revert R-204 — the paragraph's pre-fix text): the lesson carries no honest
//  sentence and still says "everything is encrypted".
//

import Foundation
import Testing

@testable import Variorum

@Suite("VX-204 — the privacy lesson names what sync leaves outside the encryption")
struct VX204PrivacyLessonTests {
    private var lessonOne: String { ProtectionCopy.privacyLessonOneParagraphs.joined(separator: "\n") }
    private var bothLessons: String {
        (ProtectionCopy.privacyLessonOneParagraphs + ProtectionCopy.privacyLessonTwoParagraphs)
            .joined(separator: "\n")
    }

    @Test func theLessonSaysWhatIsSealedAndNamesTheShapeTheServerSees() {
        // The honest sentence rides lesson 1, verbatim from its constant.
        #expect(lessonOne.contains(ProtectionCopy.privacyServerSeesShapeSentence),
                "lesson 1 carries the sentence naming what travels outside the encryption")

        // It names the five classes the audit found plain (C-1), in everyday words.
        let sentence = ProtectionCopy.privacyServerSeesShapeSentence.lowercased()
        for word in ["dates", "tags", "books", "starred", "finished", "sizes"] {
            #expect(sentence.contains(word), "the shape sentence names \(word)")
        }

        // The overstatement is gone from the whole chapter.
        let chapter = bothLessons.lowercased()
        #expect(!chapter.contains("everything is encrypted"), "no 'everything is encrypted'")
        #expect(!chapter.contains("stores what it can never read"),
                "the server stores some things it can read — the chapter no longer says otherwise")

        // What IS sealed is still said, and still true: the writing and every
        // name — the keystone's "can never read your writing" stands.
        #expect(lessonOne.contains("your writing and everything you name"))
        #expect(lessonOne.contains("the Variorum server can never read them"))
    }

    /// The guide's register (copy's two-register rule and the no-shouty-caps
    /// rule): no key-family internal, no word capitalized for emphasis, and
    /// nothing the phone's lesson cannot say (it never names the Mac).
    @Test func theNewSentenceKeepsTheGuidesRegister() {
        let sentence = ProtectionCopy.privacyServerSeesShapeSentence
        #expect(!sentence.contains(CopyRegisterPinTests.forbidden))
        #expect(!sentence.contains("Mac") && !sentence.contains("Touch ID"))
        let shouted = sentence.split(separator: " ").filter { word in
            let letters = word.filter(\.isLetter)
            return letters.count > 1 && letters.allSatisfy(\.isUppercase)
        }
        #expect(shouted.isEmpty, "no capitals for emphasis: \(shouted)")
        #expect(sentence.first?.isUppercase == true && sentence.hasSuffix("."), "one sentence, sentence case")
    }
}
