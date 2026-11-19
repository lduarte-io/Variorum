//
//  VM62MacRefusalWordsPinTests.swift
//  VariorumTests
//
//  **VM-62 — the Mac's refusal words are byte-identical after the phone's road
//  was added** (umbrella VM-55, batch 2b). VM-62 gave the PHONE a road through
//  the three shared refusal homes that ends in one plain sentence instead of a
//  dump (`OpsRefusalCopy.sentence(for:roads:)`, `DeletionRefusal.sentence` /
//  `plainFallback`, `VersionActs.sentence`), by splitting each home's words
//  from its last resort (`DeletionRefusal.knownWords`, `VersionActs.knownWords`).
//  P-55-11 added a direction flag beside the shared put-back receipts
//  (`TrashPutBack.answer`, `PreservedOriginPutBack.answer`). The Mac speaks
//  none of the new roads; this pins that the old ones answer exactly as they
//  did:
//
//  · `DeletionRefusal.words` / `.fallback` and `VersionActs.words` still end
//    in the shipped "That couldn't be done — ‹the case›." last resort, and
//    every arm's sentence is the arm's;
//  · `OpsRefusalCopy.message(for:roads:)` and the Mac's `message(for:)` still
//    end in "Refused: ‹the case›" for an unworded case;
//  · no table row moved: `words(for:roads: .mac)` for a spread of worded cases
//    is unchanged, and no row was added (the batch added none);
//  · no Mac source calls the phone's new roads (a source scan).
//
//  **How a regression trips it:** a split that changed a last resort reds the
//  fallback pins; a Mac door adopting the phone's plain fallback reds the
//  source scan — a deliberate adoption updates this pin in the same commit.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VM-62 — the Mac's refusal words are unchanged by the phone's road")
struct VM62MacRefusalWordsPinTests {
    private struct NotAnOperationError: Error {}

    @Test func theDeletionStorysLastResortIsTheShippedOne() {
        let unworded = OperationError.referenceNotFound(id: "f")
        #expect(DeletionRefusal.words(unworded)
                == "That couldn't be done — \(String(describing: unworded)).")
        #expect(DeletionRefusal.words(unworded, act: .putBack) == DeletionRefusal.fallback(unworded))
        #expect(DeletionRefusal.fallback(NotAnOperationError())
                == "That couldn't be done — \(String(describing: NotAnOperationError())).")
        #expect(DeletionRefusal.words(RecoveryRefusal.originalHasNoNote)
                == RecoveryRefusal.originalHasNoNote.sentence)
        // The arms, as shipped.
        #expect(DeletionRefusal.words(OperationError.containerNotFound(id: "c"))
                == "That note is already gone.")
        #expect(DeletionRefusal.words(OperationError.lockedPost(id: "p"), act: .putBack)
                == RecoveryCopy.sealedPutBackRefusal)
        #expect(DeletionRefusal.words(OperationError.lockedPost(id: "p"), act: .delete)
                == "This note is marked complete — unseal it first.")
        #expect(DeletionRefusal.words(OperationError.lockedReading(id: "r"))
                == "This book is finished \u{2014} reopen it first; if it\u{2019}s sealed, unseal it.")
    }

    @Test func theVersionsFamilysLastResortIsTheShippedOne() {
        let unworded = OperationError.referenceNotFound(id: "f")
        #expect(VersionActs.words(unworded, seal: .mac) == DeletionRefusal.words(unworded))
        #expect(VersionActs.words(NotAnOperationError(), seal: .mac)
                == DeletionRefusal.fallback(NotAnOperationError()))
        #expect(VersionActs.words(VersionActs.Refusal.unsavedChanges, seal: .mac)
                == OpsRefusalCopy.unsavedChanges)
        #expect(VersionActs.words(OperationError.lockedPost(id: "p"), seal: .mac)
                == "This note is sealed — unseal it to restore a version.")
        #expect(VersionActs.words(OperationError.containerNotFound(id: "c"), seal: .mac)
                == "That version is already gone.")
    }

    @Test func theTablesFallbacksAndRowsAreTheShippedOnes() {
        let unworded = OperationError.referenceNotFound(id: "f")
        #expect(OpsRefusalCopy.message(for: unworded, roads: .mac) == "Refused: \(unworded)")
        #expect(OpsRefusalCopy.message(for: unworded) == "Refused: \(unworded)")
        #expect(OpsRefusalCopy.message(for: NotAnOperationError(), roads: .mac)
                == String(describing: NotAnOperationError()))
        #expect(OpsRefusalCopy.words(for: unworded, roads: .mac) == nil, "no row was added")
        #expect(OpsRefusalCopy.words(for: OperationError.lockedReading(id: "r"), roads: .mac) == nil,
                "the finished-book sentence stays the Mac half's own")
        // A spread of rows, as shipped.
        #expect(OpsRefusalCopy.words(for: OperationError.readingSealed(id: "r"), roads: .mac)
                == "This book is sealed — unseal it to reopen it.")
        #expect(OpsRefusalCopy.words(for: OperationError.noteInSealedBook(postID: "p", readingID: "r"),
                                     roads: .mac)
                == "This note is in a book that is sealed — unseal the book to change it.")
        #expect(OpsRefusalCopy.words(for: OperationError.wrongReadingKind(id: "g", expected: .book),
                                     roads: .mac)
                == "That isn't a book — a gathering shows the notes its rule matches and holds none of its own.")
        #expect(OpsRefusalCopy.words(for: OperationError.containerNotFound(id: "c"), roads: .mac)
                == "That note isn't there any more — it may have just been deleted.")
    }

    /// No Mac source speaks the phone's new roads — the Mac's faces keep their
    /// shipped last resorts until a deliberate change says otherwise.
    ///
    /// *Extended in VM-63 (VM-55 batch 3):* the Mac brains hoisted to `Shared/`
    /// (`VM61MacStatusSeamPinTests.hoistedMacBrains`) speak on the Mac too, so
    /// the walk also reads them — a hoisted brain that named one of these roads
    /// itself, instead of speaking the words its platform hands it
    /// (`WingsModel.refusalWords`), would change the Mac's words.
    @Test func noMacDoorTakesThePhonesRoad() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        let macRoot = appRoot.appendingPathComponent("Variorum", isDirectory: true)
        let walk = try #require(FileManager.default.enumerator(
            at: macRoot, includingPropertiesForKeys: nil))
        let phoneRoads = [
            "OpsRefusalCopy.sentence(", "OpsRefusalCopy.unexpectedFailure",
            "DeletionRefusal.sentence(", "DeletionRefusal.plainFallback(",
            "VersionActs.sentence(",
        ]
        var urls = walk.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        let shared = appRoot.appendingPathComponent("Shared", isDirectory: true)
        for name in VM61MacStatusSeamPinTests.hoistedMacBrains {
            let url = shared.appendingPathComponent(name)
            #expect(FileManager.default.fileExists(atPath: url.path), "the hoisted brain is here: \(name)")
            urls.append(url)
        }
        var walked = 0
        var offenders: [String] = []
        for url in urls {
            walked += 1
            let source = try String(contentsOf: url, encoding: .utf8)
            for road in phoneRoads where source.contains(road) {
                offenders.append("\(url.lastPathComponent): \(road)")
            }
        }
        #expect(walked > 100, "the walk reached the Mac's sources (\(walked))")
        #expect(offenders.isEmpty, "a Mac door took the phone's road: \(offenders)")
    }
}
