//
//  SavepointNamingTests.swift
//  VariorumTests
//
//  13u3 UNIT D — **named commits** (master plan item 14; her ruling
//  R-13u3-1, *"Editable"*).
//
//  The op's own transitions are core's (`SavepointNameTests`). What is
//  pinned here is everything the APP decides: what a savepoint row SAYS once
//  a name exists, what the name field's two keys mean, and that the commit
//  door's skip road is still two keys and exactly one savepoint.
//
//  **These are a new capability's pins, not a defect's** — the brief says so
//  and says not to manufacture reds for one. The single cell here that IS
//  defect-shaped names itself.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("A savepoint's name (13u3 UNIT D — item 14)")
struct SavepointNameFaceTests {
    private let when = Date(timeIntervalSince1970: 1_782_864_000)

    private func savepoint(
        _ id: String = "c1", kind: CommitKind = .manual, message: String? = nil
    ) -> CommitPoint {
        CommitPoint(
            id: id, variantId: "v1", text: "a saved moment", kind: kind,
            message: message, createdAt: when)
    }

    /// **THE NAME LEADS** — her ruling's display half, as a value.
    @Test func theNameIsTheFirstThingTheRowSays() {
        let named = savepoint(message: "before the AI edit")
        #expect(SavepointRowFace.name(named) == "before the AI edit")
        #expect(SavepointRowFace.meta(named, predatesSplit: false).first == "before the AI edit",
                "a name she can only find past a date is a name the row is hiding")
        // The details follow it, whole and in their shipped order.
        #expect(SavepointRowFace.meta(named, predatesSplit: false).dropFirst()
            == SavepointRowFace.details(named, predatesSplit: false)[...])
    }

    /// An unnamed savepoint reads EXACTLY as it always has — the ordering
    /// change costs the shipped rows nothing.
    @Test func anUnnamedSavepointReadsExactlyAsItAlwaysHas() {
        let plain = savepoint()
        #expect(SavepointRowFace.name(plain) == nil)
        #expect(SavepointRowFace.meta(plain, predatesSplit: false)
            == SavepointRowFace.details(plain, predatesSplit: false))
        #expect(SavepointRowFace.meta(plain, predatesSplit: false).contains("saved by hand"))
        #expect(SavepointRowFace.meta(plain, predatesSplit: true)
            .contains(BlockHistoryCopy.predatesSplitMark))
    }

    /// **THE OCCASION IS NEVER OVERWRITTEN BY THE NAME** (her ruling's own
    /// note): a renamed QUIET savepoint still says *quiet*, because the
    /// rename writes `message` and leaves `kind` alone.
    @Test func aNamedQuietSavepointStillSaysQuiet() {
        let quiet = savepoint(kind: .auto, message: "the one before I left")
        let meta = SavepointRowFace.meta(quiet, predatesSplit: false)
        #expect(meta.first == "the one before I left")
        #expect(meta.contains("quiet"))
        #expect(SavepointRowFace.details(quiet, predatesSplit: false).contains("quiet"))
    }

    /// A face can never show a name the store would have normalised away —
    /// both roads read the ONE rule.
    @Test func theFaceReadsTheSameNameRuleTheStoreWritesBy() {
        #expect(SavepointRowFace.name(savepoint(message: "   ")) == nil)
        #expect(SavepointRowFace.name(savepoint(message: "")) == nil)
        #expect(SavepointRowFace.name(savepoint(message: "  padded  ")) == "padded")
    }

    /// The door's verb says what it does on THIS row (the `putBackHelp`
    /// rule, one region up), and the receipts quote the name back.
    @Test func theRenameDoorWordsItselfToItsRow() {
        #expect(BlockHistoryCopy.nameVerb(savepoint()) == BlockHistoryCopy.nameSavepointVerb)
        #expect(BlockHistoryCopy.nameVerb(savepoint(message: "named"))
            == BlockHistoryCopy.renameSavepointVerb)
        #expect(BlockHistoryCopy.nameHelp(savepoint()) != BlockHistoryCopy.nameHelp(
            savepoint(message: "named")))
        #expect(BlockHistoryCopy.renamed("before the AI edit").contains("before the AI edit"))
        #expect(BlockHistoryCopy.renamed(nil) == BlockHistoryCopy.savepointNameCleared)
    }
}

@Suite("The name field's value (13u3 UNIT D)")
struct SavepointNameAskTests {
    /// **THE COMMIT DOOR OPENS EMPTY; THE RENAME DOOR OPENS ON WHAT IS
    /// THERE.** The seeding IS the difference between the two gestures: one
    /// offers a name, the other edits one — and clearing the seeded field is
    /// how a name is removed (the op's clear road, reached with ⌫ and ⏎).
    @Test func theAskSeedsItselfFromWhatItIsNaming() {
        let ask = SavepointNameAsk.naming(variantID: "v1")
        #expect(ask.kind == .newSavepoint)
        #expect(ask.seed.isEmpty)
        #expect(ask.targetID == "v1")

        let when = Date(timeIntervalSince1970: 1_782_864_000)
        let named = CommitPoint(
            id: "c9", variantId: "v1", text: "words", kind: .manual,
            message: "before the AI edit", createdAt: when)
        let rename = SavepointNameAsk.renaming(named)
        #expect(rename.kind == .rename)
        #expect(rename.targetID == "c9")
        #expect(rename.seed == "before the AI edit")

        let unnamed = CommitPoint(
            id: "c8", variantId: "v1", text: "words", kind: .auto, createdAt: when)
        #expect(SavepointNameAsk.renaming(unnamed).seed.isEmpty,
                "a quiet savepoint takes a name from empty — its occasion is not its name")
        // Two asks about different rows are different presentations; the two
        // kinds about the same id are too (a host can only hold one anyway).
        #expect(SavepointNameAsk.naming(variantID: "v1").id != rename.id)
    }

    /// The field's two roads say what they are, and the prompt/hint differ by
    /// gesture (the commit door's says the empty name is fine — that IS the
    /// enter-to-skip promise, written where she can read it).
    @Test func theFieldTeachesItsTwoKeys() {
        let new = SavepointNameCopy.hint(.newSavepoint)
        #expect(new.contains("\u{23CE}") && new.contains("\u{238B}"))
        #expect(new.lowercased().contains("empty name is fine"))
        let rename = SavepointNameCopy.hint(.rename)
        #expect(rename.contains("Clearing the field removes the name"))
        #expect(rename.contains("never changes"), "I5, said at the door")
        #expect(SavepointNameCopy.prompt(.newSavepoint) != SavepointNameCopy.prompt(.rename))
        #expect(SavepointNameCopy.filed("before the AI edit").contains("before the AI edit"))
    }
}

@MainActor
@Suite("The commit door asks for a name (13u3 UNIT D)")
struct SavepointCommitDoorTests {
    private func savepoints(_ h: EditorHarness) throws -> [CommitPoint] {
        let variantID = try #require(try h.storeSlots().first?.variantID)
        return try h.database.read { try Queries.commitHistory($0, variantID: variantID) }
    }

    /// **THE SKIP ROAD — TWO KEYS, ONE SAVEPOINT** (her words: *"enter-to-skip
    /// keeps ⌘S instant"*). ⌘S opens the field; ⏎ on it empty files exactly
    /// what ⌘S filed before this unit existed.
    @Test func commandSThenReturnFilesOneUnnamedSavepoint() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()

            h.model.commitCaretVariant()  // the door: ⌘S and the bar's button
            let ask = try #require(h.model.savepointAsk)
            #expect(ask.kind == .newSavepoint)
            let variantID = try #require(try h.storeSlots()[0].variantID)
            #expect(ask.targetID == variantID)
            #expect(ask.seed.isEmpty, "the commit door opens on an empty field")
            #expect(try savepoints(h).isEmpty)  // the door itself writes nothing

            await h.model.fileSavepoint(named: nil)  // ⏎, empty

            #expect(h.model.savepointAsk == nil)
            let saved = try savepoints(h)
            #expect(saved.count == 1)
            #expect(saved[0].message == nil)
            #expect(saved[0].kind == .manual)
            #expect(saved[0].text == "draft text", "exactly the buffer, as always")
        }
    }

    /// **THE NAMED ROAD** — her motivating case, the 13n AI-edit story.
    @Test func aTypedNameRidesTheSavepointAndTheReceiptSaysIt() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()

            h.model.commitCaretVariant()
            await h.model.fileSavepoint(named: "before the AI edit")

            let saved = try savepoints(h)
            #expect(saved.count == 1)
            #expect(saved[0].message == "before the AI edit")
            #expect(saved[0].kind == .manual)
            #expect(h.model.statusMessage == SavepointNameCopy.filed("before the AI edit"))
        }
    }

    /// **⎋ CANCELS THE COMMIT WHOLE** (PROVISIONAL, #121): the ask goes away
    /// and nothing was written — which is also what a click outside and a
    /// closing window do, because they are all the same road.
    @Test func cancellingTheFieldFilesNothingAtAll() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()

            h.model.commitCaretVariant()
            #expect(h.model.savepointAsk != nil)
            h.model.savepointAsk = nil  // ⎋ / a click outside / the window going

            let after = try savepoints(h)
            #expect(after.isEmpty,
                    "a cancelled ask is not a savepoint with no name — it is no savepoint")
        }
    }

    /// **A FIELD NEVER OPENS OVER A GESTURE THAT CANNOT LAND** (P-2): the
    /// caret in the open tail has no take, so the door refuses where it
    /// always refused — before anything is presented.
    @Test func theDoorRefusesBeforeItOpensAFieldItCannotFile() async throws {
        try await withEditor(seedBlocks: ["block"]) { h in
            h.type("\n", at: 5)
            h.model.updateCaretContext()
            #expect(h.model.caretVariantID == nil)

            h.model.commitCaretVariant()

            #expect(h.model.savepointAsk == nil)
            #expect(h.model.statusMessage == "Place the caret in a block to commit.")
        }
    }

    /// The name reaches the STORE through the shipped parameter, and the row
    /// reads back with its name leading — the two halves of this unit meeting
    /// on one savepoint.
    @Test func theNamedSavepointReadsBackNameFirst() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            h.model.commitCaretVariant()
            await h.model.fileSavepoint(named: "  before the AI edit  ")

            let saved = try #require(try savepoints(h).first)
            #expect(saved.message == "before the AI edit", "normalised on the way in")
            #expect(SavepointRowFace.meta(saved, predatesSplit: false).first
                == "before the AI edit")
        }
    }
}

/// A takes board over a one-block note. (The two shipped `withTakesWorld`
/// helpers are `private` to their own files; this is the same shape, local.)
@MainActor
private func withSavepointTakesWorld<T>(
    _ body: @MainActor (TakesViewModel, AppDatabase, String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "named commits")
        _ = try session.operations.newBlock(in: post.id, text: "Shown take.")
        let model = TakesViewModel(session: session, postID: post.id)
        model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
        return try await body(model, db, post.id)
    }
}

@MainActor
@Suite("The takes board's commit door asks too (13u3 UNIT D)")
struct SavepointTakesDoorTests {
    /// The takes surfaces' ⌘S is the SAME gesture — one door, one field, one
    /// rule. Takes and Lenses share this model, so this pin covers both.
    @Test func theTakesDoorOpensTheFieldAndFilesWhatItIsGiven() async throws {
        try await withSavepointTakesWorld { model, db, _ in
            let slot = try #require(model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: slot.blockID, variantID: variantID))

            model.askSavepointName()
            let ask = try #require(model.savepointAsk)
            #expect(ask.targetID == variantID)
            #expect(ask.kind == .newSavepoint)

            await model.fileSavepoint(named: "before the AI edit")
            #expect(model.savepointAsk == nil)

            let saved = try await db.read { db in
                try Queries.commitHistory(db, variantID: variantID)
            }
            #expect(saved.count == 1)
            #expect(saved[0].message == "before the AI edit")
            #expect(saved[0].kind == .manual)

            // And the skip road, on the same take: one more savepoint, no name.
            model.askSavepointName()
            await model.fileSavepoint(named: nil)
            let both = try await db.read { db in
                try Queries.commitHistory(db, variantID: variantID)
            }
            #expect(both.count == 2)
            #expect(both.contains { $0.message == nil })
        }
    }
}
