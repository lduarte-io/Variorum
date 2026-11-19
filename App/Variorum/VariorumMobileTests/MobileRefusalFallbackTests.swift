//
//  MobileRefusalFallbackTests.swift
//  VariorumMobileTests
//
//  **VM-62 — the phone's road ends in words** (umbrella VM-55, batch 2b). The
//  fix's own contract, beside the pins (`MobileRawErrorPinTests`, which hold
//  the doors): the three shared refusal homes the phone speaks through each
//  gain a road that keeps every sentence they had and ends in the shared
//  table's ONE plain fallback instead of a dump —
//
//  · `OpsRefusalCopy.sentence(for:roads:)` — the table's words, else the
//    plain fallback (`OpsRefusalCopy.unexpectedFailure`, a DRAFT line —
//    PROVISIONAL P-55-12), the raw detail to the unified log;
//  · `DeletionRefusal.sentence(_:act:roads:)` / `plainFallback(_:roads:)` —
//    the deletion story's arms first, unchanged;
//  · `VersionActs.sentence(_:roads:)` — the versions family's arms first.
//
//  And the Mac's roads are untouched: `DeletionRefusal.words`, `.fallback`,
//  `VersionActs.words` and `OpsRefusalCopy.message` still answer exactly as
//  before (held here for the shared files both targets compile; the Mac half
//  is `VM62MacRefusalWordsPinTests`).
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-62 — the phone's road ends in words, never a dump")
struct MobileRefusalFallbackTests {
    private struct NotAnOperationError: Error {}

    /// A spread of `OperationError`s the phone's doors can meet — worded and
    /// unworded alike.
    private static let sample: [OperationError] = [
        .referenceNotFound(id: "f"),
        .lockedReading(id: "r"),
        .blockNotFound(id: "b"),
        .wrongReadingKind(id: "g", expected: .book),
        .wrongReadingKind(id: "g", expected: .gathering),
        .readingSealed(id: "r"),
        .noteInSealedBook(postID: "p", readingID: "r"),
        .containerNotFound(id: "c"),
        .readingNotFound(id: "r"),
        .lockedPost(id: "p"),
        .lockedVariant(id: "v"),
        .variantIsChosen(id: "v"),
        .containerNotDeleted(id: "c"),
        .purgeTargetNotDeleted(table: "container", id: "c"),
    ]

    /// The first word of an error's own description — the case name a dump
    /// would carry.
    private static func caseName(_ error: Error) -> String {
        String(String(describing: error).prefix { $0 != "(" })
    }

    @Test func anUnwordedFailureSpeaksTheOnePlainFallback() {
        #expect(OpsRefusalCopy.sentence(for: NotAnOperationError(), roads: .phone)
                == OpsRefusalCopy.unexpectedFailure)
        #expect(OpsRefusalCopy.sentence(for: OperationError.referenceNotFound(id: "f"), roads: .phone)
                == OpsRefusalCopy.unexpectedFailure)
        #expect(OpsRefusalCopy.unexpectedFailure == "That couldn't be done.")
    }

    @Test func theTablesWordsStillComeFirst() {
        for error in Self.sample {
            if let words = OpsRefusalCopy.words(for: error, roads: .phone) {
                #expect(OpsRefusalCopy.sentence(for: error, roads: .phone) == words)
            }
        }
    }

    @Test func theDeletionStoryKeepsItsArmsAndEndsPlain() {
        for act in [DeletionRefusal.Act.delete, .putBack] {
            for error in Self.sample {
                let phone = DeletionRefusal.sentence(error, act: act, roads: .phone)
                if let known = DeletionRefusal.knownWords(error, act: act) {
                    #expect(phone == known, "an arm's sentence never moves")
                    #expect(DeletionRefusal.words(error, act: act) == known)
                } else {
                    #expect(phone == (OpsRefusalCopy.words(for: error, roads: .phone)
                                      ?? OpsRefusalCopy.unexpectedFailure))
                    // The Mac's road keeps its shipped last resort.
                    #expect(DeletionRefusal.words(error, act: act) == DeletionRefusal.fallback(error))
                }
            }
        }
        #expect(DeletionRefusal.plainFallback(RecoveryRefusal.originalHasNoNote, roads: .phone)
                == RecoveryRefusal.originalHasNoNote.sentence)
        #expect(DeletionRefusal.plainFallback(NotAnOperationError(), roads: .phone)
                == OpsRefusalCopy.unexpectedFailure)
        #expect(DeletionRefusal.fallback(NotAnOperationError())
                == "That couldn't be done — \(String(describing: NotAnOperationError()))."
                , "the Mac's fallback is byte-identical")
    }

    @Test func theVersionsFamilyKeepsItsArmsAndEndsPlain() {
        #expect(VersionActs.sentence(VersionActs.Refusal.unsavedChanges, roads: .phone)
                == OpsRefusalCopy.unsavedChanges)
        #expect(VersionActs.sentence(OperationError.lockedPost(id: "p"), roads: .phone)
                == VersionActs.words(OperationError.lockedPost(id: "p"), seal: .phone))
        #expect(VersionActs.sentence(OperationError.notVersionHistory(version: "v", note: "p"), roads: .phone)
                == "That isn't one of this note's saved versions any more.")
        #expect(VersionActs.sentence(NotAnOperationError(), roads: .phone)
                == OpsRefusalCopy.unexpectedFailure)
        // The Mac's road keeps its shipped last resort.
        #expect(VersionActs.words(NotAnOperationError(), seal: .phone)
                == DeletionRefusal.fallback(NotAnOperationError()))
        #expect(VersionActs.words(OperationError.referenceNotFound(id: "f"), seal: .phone)
                == DeletionRefusal.words(OperationError.referenceNotFound(id: "f")))
    }

    /// The property the bug is about: whatever the error, the phone's roads
    /// never put its case name or its associated values on the screen.
    @Test func noPhoneRoadCarriesACaseName() {
        let errors: [Error] = Self.sample + [NotAnOperationError(), VersionActs.Refusal.unsavedChanges]
        for error in errors {
            let name = Self.caseName(error)
            let lines = [
                OpsRefusalCopy.sentence(for: error, roads: .phone),
                DeletionRefusal.sentence(error, act: .delete, roads: .phone),
                DeletionRefusal.sentence(error, act: .putBack, roads: .phone),
                DeletionRefusal.plainFallback(error, roads: .phone),
                VersionActs.sentence(error, roads: .phone),
            ]
            for line in lines {
                #expect(!line.contains(name), "\(name) leaked: \(line)")
                #expect(!line.contains("id: \""), "an associated value leaked: \(line)")
                #expect(!line.isEmpty)
            }
        }
    }
}
