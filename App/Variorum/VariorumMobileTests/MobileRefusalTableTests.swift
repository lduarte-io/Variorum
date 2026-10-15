//
//  MobileRefusalTableTests.swift
//  VariorumMobileTests
//
//  18m U3 — **one refusal table, phone side.** The operations layer's refusal
//  table (`OpsRefusalCopy`, hoisted to `Shared/OpsRefusalTable.swift`) is the
//  phone's too now. The five phone refusal switches the charter named
//  collapse onto it by ONE rule (the U3 CLASSIFICATION RULING): an arm stays
//  local only for a phone door or a context the table lacks (the act, the
//  `nothingWas` verb, the book's name); everything else the table has words
//  for, the phone now says in those words; and where the table has NO words,
//  each site keeps its OWN fallback — so the collapse can only turn a raw
//  enum dump into a sentence, never a sentence into a dump.
//
//  The first and last tests are RED on the hoist-only tree (the dumps and the
//  crystallizer's raw error voice); the middle ones are GUARDS that hold on
//  both sides (the phone's own door words, its own fallbacks).
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("18m U3 — the phone's refusal switches speak the one table")
struct MobileRefusalTableTests {
    static let blockNotPlaced = "That block is no longer in this note — it may have "
        + "moved while you worked. Nothing was changed here."

    private struct NotAnOperationError: Error {}

    /// The collapse, as a fact: a case the table words reaches her in words at
    /// every one of the five sites (it reached her as a raw dump before).
    @Test func eachSwitchSpeaksTheTableWhereItHasWords() {
        let gone = OperationError.blockNotPlaced(id: "b")
        #expect(MobileUndoDoor.refusal(gone) == Self.blockNotPlaced)
        #expect(MobileBlockMenuController.refusalMessage(gone, act: "name the block")
                == Self.blockNotPlaced)
        #expect(MobileCommentsController.refusalMessage(gone) == Self.blockNotPlaced)
        #expect(MobileStructuralController.refusalMessage(gone, act: "divide the block")
                == Self.blockNotPlaced)
        #expect(MobileMembershipModel.refusal(OperationError.readingNotFound(id: "r"), bookName: "B")
                == "That book can't be found — it may have been deleted, or removed on another device.")
    }

    /// The table's one-door-word slots are EMPTY on the phone: no ceremony
    /// road, no chord — the sentence ends at the fact that is true here.
    @Test func theTablesDoorSlotsStayEmptyOnThePhone() {
        let fanned = MobileStructuralController.refusalMessage(
            OperationError.fannedBlock(id: "b"), act: "divide the block")
        #expect(fanned == "This block has more than one take now — divide it again and the "
                + "take you're in splits while the others stay on the first block.")
        let onlyTake = MobileStructuralController.refusalMessage(
            OperationError.lastActiveVariant(id: "v"), act: "divide the block")
        #expect(onlyTake == "This block has only one take — a block keeps at least one take, "
                + "so delete the block instead, or divide it to split it into blocks.")
        for line in [fanned, onlyTake] {
            #expect(!line.contains("\u{2318}") && !line.contains("\u{2325}"), "no Mac chord: \(line)")
            #expect(!line.contains("Mac"), "no redirect: \(line)")
        }
    }

    /// GUARD: where the table has no words, each site keeps the fallback it had.
    ///
    /// *A justified edit (VX-362 — the VX-336 run record's U9):* this guard's
    /// unworded sample was `containerNotFound`, which the wire's sweep words in
    /// the shared table now (the next test). The guard keeps its meaning on a
    /// case that stays unworded — `referenceNotFound`, which the sweep proved
    /// no wire road reaches and no table words.
    @Test func eachSiteKeepsItsOwnFallbackWhereTheTableHasNoWords() {
        let unworded = OperationError.referenceNotFound(id: "f")
        #expect(MobileBlockMenuController.refusalMessage(unworded, act: "name the block")
                == DeletionRefusal.fallback(unworded))
        #expect(MobileUndoDoor.refusal(unworded) == String(describing: unworded))
        #expect(MobileCommentsController.refusalMessage(unworded) == String(describing: unworded))
        #expect(MobileStructuralController.refusalMessage(unworded, act: "divide the block")
                == String(describing: unworded))
        #expect(MobileMembershipModel.refusal(unworded, bookName: nil) == "Refused: \(unworded)")
    }

    /// **VX-362 (VX-336 U9) — MOBILE PARITY: the sweep's new shared words reach
    /// the phone.** The wire's sweep worded ten cases; those her doors can also
    /// meet live in the SHARED table, so every phone site that falls through to
    /// the table speaks them too. A note gone between a door's read and its
    /// write is the one this suite's sites meet (it was the guard's unworded
    /// sample above). *Red on the old tree:* each site's own fallback dump.
    @Test func theSweepsNoteGoneSentenceReachesEveryFallThroughSite() {
        let gone = OperationError.containerNotFound(id: "c")
        let words = "That note isn't there any more — it may have just been deleted."
        #expect(MobileBlockMenuController.refusalMessage(gone, act: "name the block") == words)
        #expect(MobileUndoDoor.refusal(gone) == words)
        #expect(MobileCommentsController.refusalMessage(gone) == words)
        #expect(MobileStructuralController.refusalMessage(gone, act: "divide the block") == words)
        #expect(MobileMembershipModel.refusal(gone, bookName: nil) == words)
    }

    /// GUARD: the seal keeps the phone's own door words ("Unlock Note") — the
    /// ONE stem, the platform noun a parameter.
    @Test func theSealStaysInThePhonesOwnDoorWords() {
        let sealed = OperationError.lockedPost(id: "p")
        #expect(MobileUndoDoor.refusal(sealed) == "This note is locked — unlock it first.")
        #expect(MobileCommentsController.refusalMessage(sealed)
                == "This note is locked — unlock it to change comments.")
        #expect(MobileBlockMenuController.refusalMessage(sealed, act: "name the block")
                == "This note is locked — unlock it to name the block.")
        #expect(MobileStructuralController.refusalMessage(sealed, act: "divide the block")
                == "This note is locked — unlock it to divide the block.")
    }

    /// **THE QUICK NOTE'S SEAL ARM JOINS THE ONE SENTENCE** (VM-5 whole-round
    /// pass, MINOR 3). The box OWNS the note it minted and autosaves into it,
    /// so a seal landing by sync mid-capture refuses its flush `.lockedPost`
    /// and this sentence renders in the box's red slot. It said *"This note is
    /// sealed, so it can't take new text. Unseal it in the note to keep
    /// writing."* — the Mac's noun and a door ("Unseal") that exists nowhere on
    /// the phone, whose button is Lock Note / Unlock Note. It now COMPOSES the
    /// shared shape with the phone's own words (QUESTIONS #159 (a)), never a
    /// literal of its own.
    ///
    /// *Red on the old tree:* the arm returned its own literal.
    @Test func theQuickNotesSealArmSpeaksThePhonesOwnDoorWords() {
        let line = MobileQuickNoteCopy.refusal(OperationError.lockedPost(id: "p"))
        #expect(line == SealedNoteCopy.sentence(act: "keep writing", words: .phone))
        #expect(line == "This note is locked — unlock it to keep writing.")
        #expect(!line.localizedCaseInsensitiveContains("seal"),
                "the Mac's seal vocabulary on the phone: \(line)")
    }

    /// Ruling V: the crystallizer's error voice (U2's host member, the phone's
    /// conformance) speaks the table instead of dumping the error — and a
    /// non-operation error keeps its description.
    @Test func theCrystallizersErrorVoiceSpeaksTheTable() async throws {
        try await withEditorWorld { session, _ in
            let post = try session.operations.createPost(title: "T")
            let (model, _) = makeEditor(session, postID: post.id)
            model.reportOperationError(OperationError.blockNotPlaced(id: "b"))
            #expect(model.statusMessage == Self.blockNotPlaced)
            model.reportOperationError(OperationError.lockedPost(id: post.id))
            #expect(model.statusMessage == "This note is locked — unlock it first.")
            model.reportOperationError(NotAnOperationError())
            #expect(model.statusMessage == String(describing: NotAnOperationError()))
        }
    }
}
