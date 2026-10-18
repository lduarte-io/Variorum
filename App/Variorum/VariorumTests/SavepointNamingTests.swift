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
import GRDB
import SwiftUI
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
        // VX-347 (a justified edit): the commit door's hint says the new
        // contract — leaving commits, ⎋ doesn't. RED on the shipped hint
        // ("⏎ saves it · ⎋ cancels").
        #expect(new.contains("clicking away commits it"))
        let rename = SavepointNameCopy.hint(.rename)
        #expect(rename.contains("Clearing the field removes the name"))
        // I5 is the DOOR's help sentence, not the field's hint: the hint ran
        // to four lines at the field's width on the walk and truncated
        // mid-word, and the help is where there is room to say it.
        let when = Date(timeIntervalSince1970: 1_782_864_000)
        let named = CommitPoint(
            id: "c1", variantId: "v1", text: "x", kind: .manual,
            message: "a name", createdAt: when)
        #expect(BlockHistoryCopy.nameHelp(named).contains("never editable"), "I5, at the door")
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

    /// **ONLY ⎋ LEAVES THE FIELD WITHOUT A COMMIT — FLIPPED FOR VX-347**
    /// (a justified edit: this cell was `cancellingTheFieldFilesNothingAtAll`
    /// and encoded #121(b)'s PROVISIONAL — "⎋, a click outside and a closing
    /// window all cancel" — which her ruling supersedes: *"command S should
    /// always commit your take even without an extra keystroke to enter (but
    /// if you click escape, then that can deliberately not save)"*). It now
    /// drives the PRODUCT's presenter (Write's bar) and leaves the field the
    /// way a click away ENDS — SwiftUI writing nil through the host's binding,
    /// which also closes the popover (VX-347's fix leg re-shaped this road:
    /// the first rig looked the popover up before AppKit announced it, so the
    /// cell never reached the behaviour) — which files ONE commit, unnamed;
    /// then a second ⌘S left by ⎋ files nothing. **RED ON OLD** by behaviour
    /// (the pre-fix presenter filed nothing on a dismissal).
    @Test func onlyEscapeLeavesTheFieldWithoutACommit() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            let mounted = await SavepointFieldRig.mountWritesBar(h.model)
            defer { mounted.tearDown() }
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()

            _ = try await SavepointFieldRig.pressCommandS(h.model, mounted)
            await SavepointFieldRig.dismissTheField(h.model)  // a click outside, as it ends
            await SavepointFieldRig.awaitSavepoints(h, count: 1)

            let afterAClickAway = try savepoints(h)
            #expect(afterAClickAway.count == 1,
                    "leaving the field any way but \u{238B} files the commit (VX-347)")
            #expect(afterAClickAway.first?.message == nil, "unnamed when nothing was typed")
            #expect(afterAClickAway.first?.kind == .manual)

            let popover = try await SavepointFieldRig.pressCommandS(h.model, mounted)
            try await SavepointFieldRig.focusTheField(in: popover)
            await SavepointFieldRig.key(
                "\u{1b}", keyCode: 53, to: try SavepointFieldRig.deliveryWindow(for: popover))
            await SavepointFieldRig.turns(until: { h.model.savepointAsk == nil }, max: 120)
            await SavepointFieldRig.turns(60)

            #expect(try savepoints(h).count == 1,
                    "\u{238B} alone is the deliberate \u{201C}don't save\u{201D}")
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

/// **A SEALED NOTE'S ⌘S REFUSES AT THE DOOR — ON ALL FOUR ASK DOORS** (13u3
/// ladder round 1, R1-3, the implementer's widen confirmed: P-2's letter).
/// The shipped doors guarded their no-target state (open tail · no focused
/// pane · no live pane) and not the SEAL — and the boards' target facts are
/// the RAW `authority.livePane`, which a click under a seal still sets — so
/// on a sealed note the field opened over a commit the filer refuses, where
/// the pre-D road refused at the keypress. Each cell drives the real door
/// under a real seal: no field, and the seal's own sentence.
@MainActor
@Suite("The ask doors refuse under a seal (13u3 ladder R1-3)")
struct SavepointSealedDoorTests {
    private var sealedSentence: String {
        OpsRefusalCopy.message(for: OperationError.lockedPost(id: "x"))
    }

    @Test func writesDoorRefusesASealedNoteBeforeOpeningTheField() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            try h.session.operations.lockPost(h.postID)
            try h.reload()  // the header's seal reaches the model
            #expect(h.model.header?.locked == true)

            h.model.commitCaretVariant()

            #expect(h.model.savepointAsk == nil, "no field over a sealed commit")
            // Round 2, R2-1: the SURFACE's own sentence — Write's filer's
            // words, which this door speaks at the keypress. **18m U3
            // (SANCTIONED EDIT S-1, the U3 CLASSIFICATION RULING):** Write's
            // private filer switch (`operationMessage`) was DELETED onto the
            // registry and the seal converged on ONE sentence, so the filer
            // and the registry now speak the same line — this literal moved
            // from "…unlock it first." to the converged "…unseal it first."
            // (PROVISIONAL, QUESTIONS #159). The equality cell below holds the
            // contract itself, unchanged.
            #expect(h.model.statusMessage == "This note is sealed — unseal it first.",
                    "the same sentence the post-\u{23CE} road speaks")
        }
    }

    /// **THE DOOR AND THE FILER SPEAK ONE SENTENCE — THIS DOOR ONLY** (13u3
    /// ladder round 2, R2-1, the equality-form contract). Write's ⌘S is the
    /// one seal-refusing door whose GESTURE has two refusal moments: the
    /// door's guard, or — when the seal lands under a stale `header` (the
    /// fail-open the design deliberately leaves to the filer) — the op road
    /// after ⏎. One gesture must not speak two sentences depending on header
    /// freshness. **Scoped to THIS door, deliberately:** Write's two shipped
    /// gesture-worded seal refusals (`shouldChangeText`'s "unseal it to
    /// edit." and `poolDrop`'s "unseal it to add to it.") are NOT in breach
    /// of this contract and must not be widened into it — their doors
    /// consume the gesture outright, so the door is the gesture's only
    /// worded refusal; this pin is not a surface-wide law. Consequence,
    /// stated (18m U3 ladder F-3 — the filer's voice IS the refusal table
    /// now): gesture-wording THIS door later means changing the table's
    /// `lockedPost` line (`SealedNoteCopy`) with it, or redding this cell
    /// honestly.
    @Test func writesDoorAndFilerSpeakOneSealSentence() async throws {
        try await withEditor(seedBlocks: ["draft text"]) { h in
            h.textView.setSelectedRange(NSRange(location: 3, length: 0))
            h.model.updateCaretContext()
            try h.session.operations.lockPost(h.postID)
            try h.reload()

            h.model.commitCaretVariant()  // the door's moment
            let atTheDoor = h.model.statusMessage
            #expect(h.model.savepointAsk == nil, "no field over a sealed commit")

            // The filer's moment — the same gesture reached through the
            // stale-header race's road (⏎ meeting the op).
            await h.model.commitCaret()
            let atTheFiler = h.model.statusMessage

            #expect(atTheDoor != nil)
            #expect(atTheDoor == atTheFiler,
                    "one \u{2318}S, one sentence, whichever moment refuses (R2-1: door \u{201C}\(atTheDoor ?? "")\u{201D} vs filer \u{201C}\(atTheFiler ?? "")\u{201D})")
        }
    }

    @Test func takesDoorRefusesASealedNoteBeforeOpeningTheField() async throws {
        try await withSavepointTakesWorld { model, db, postID in
            let slot = try #require(model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            // The widen's own mechanism: a click under a seal still sets the
            // RAW livePane (focus has no seal test; isPaneLive is where the
            // seal lives), so the target guard alone cannot refuse this.
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: slot.blockID, variantID: variantID))
            try model.session.operations.lockPost(postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(model.projection.sealed)
            #expect(model.focusedPane != nil, "the raw pointer survives the seal")

            model.askSavepointName()

            #expect(model.savepointAsk == nil, "no field over a sealed commit")
            #expect(model.status?.isRefusal == true)
            #expect(model.status?.text == sealedSentence)
        }
    }

    @Test func canvasDoorRefusesASealedNoteBeforeOpeningTheField() async throws {
        try await withSavepointTakesWorld { takes, db, _ in
            let session = takes.session
            let post = try session.operations.createPost(title: "canvas world")
            let minted = try session.operations.newBlock(in: post.id, text: "A card.")
            let model = CanvasViewModel(session: session, containerID: post.id)
            let projection = try await db.read {
                try Queries.canvasProjection($0, container: post.id)
            }
            model.adopt(projection)
            model.focus(blockID: minted.block.id, variantID: minted.variant.id)
            #expect(model.authority.livePane != nil)
            try session.operations.lockPost(post.id)
            model.adopt(CanvasFace(projection: projection, sealed: true))

            model.askSavepointName()

            #expect(model.savepointAsk == nil, "no field over a sealed commit")
            #expect(model.statusMessage == sealedSentence)
        }
    }

    /// **THE DISCRIMINATING PAIR (the sanity pass's S-2):** Compare crosses
    /// posts, so its guard reads the PANE's own post's seal — the fact the
    /// R1-3 disposition chose over the board-level `projection.anchor.sealed`
    /// it rejected. The anchor-only cell below cannot tell the two apart;
    /// these two can, one per direction. The second is the worse direction:
    /// a board-fact guard would refuse a commit she is entitled to make, on
    /// a note that is not sealed.
    @Test func compareDoorRefusesASealedPeersPane() async throws {
        try await withSavepointTakesWorld { takes, db, _ in
            let session = takes.session
            let (anchorID, twinID) = try await session.runner.run {
                ops -> (String, String) in
                let anchor = try ops.createPost(title: "the piece")
                _ = try ops.newBlock(in: anchor.id, text: "First block of the piece.")
                let twin = try ops.duplicateAsVersion(anchor.id)
                try ops.lockPost(twin.post.id)  // the PEER is sealed
                return (anchor.id, twin.post.id)
            }
            let model = CompareViewModel(session: session, anchorPostID: anchorID)
            model.peerSlots = [.init(postID: twinID)]
            model.adopt(try await db.read { db in
                try CompareViewModel.read(db, anchor: anchorID, peers: [twinID])
            })
            #expect(model.projection.anchor.sealed == false, "the ANCHOR is not sealed")
            let twinSlot = try #require(model.face(for: twinID)?.slots.first)
            model.focus(PaneTextAuthority.PaneKey(
                columnID: "compare-\(twinID)", blockID: twinSlot.blockID,
                variantID: try #require(twinSlot.variantID), context: twinID))

            model.askSavepointName()

            #expect(model.savepointAsk == nil,
                    "the PANE's post is sealed — a board-level fact would wrongly allow this")
            #expect(model.statusMessage == sealedSentence)
        }
    }

    @Test func compareDoorAllowsAnUnsealedPeerUnderASealedAnchor() async throws {
        try await withSavepointTakesWorld { takes, db, _ in
            let session = takes.session
            let (anchorID, twinID) = try await session.runner.run {
                ops -> (String, String) in
                let anchor = try ops.createPost(title: "the piece")
                _ = try ops.newBlock(in: anchor.id, text: "First block of the piece.")
                let twin = try ops.duplicateAsVersion(anchor.id)
                try ops.lockPost(anchor.id)  // the ANCHOR is sealed; the peer is not
                return (anchor.id, twin.post.id)
            }
            let model = CompareViewModel(session: session, anchorPostID: anchorID)
            model.peerSlots = [.init(postID: twinID)]
            model.adopt(try await db.read { db in
                try CompareViewModel.read(db, anchor: anchorID, peers: [twinID])
            })
            #expect(model.projection.anchor.sealed == true)
            let twinSlot = try #require(model.face(for: twinID)?.slots.first)
            model.focus(PaneTextAuthority.PaneKey(
                columnID: "compare-\(twinID)", blockID: twinSlot.blockID,
                variantID: try #require(twinSlot.variantID), context: twinID))

            model.askSavepointName()

            // The WORSE direction (S-2): the pane's post is NOT sealed, so
            // the field must open — a guard on the board-level fact would
            // refuse a commit she is entitled to make.
            #expect(model.savepointAsk != nil,
                    "an unsealed peer's commit is hers whatever the anchor's seal says")
            #expect(model.savepointAsk?.targetID == twinSlot.variantID)
        }
    }

    @Test func compareDoorRefusesASealedPanesOwnPost() async throws {
        try await withSavepointTakesWorld { takes, db, _ in
            let session = takes.session
            let anchor = try session.operations.createPost(title: "the piece")
            let minted = try session.operations.newBlock(
                in: anchor.id, text: "First block of the piece.")
            let model = CompareViewModel(session: session, anchorPostID: anchor.id)
            model.focus(PaneTextAuthority.PaneKey(
                columnID: "compare-\(anchor.id)", blockID: minted.block.id,
                variantID: minted.variant.id, context: anchor.id))
            try session.operations.lockPost(anchor.id)
            model.adopt(try await db.read { db in
                try CompareViewModel.read(db, anchor: anchor.id, peers: [])
            })
            #expect(model.projection.anchor.sealed)
            #expect(model.authority.livePane != nil)

            model.askSavepointName()

            #expect(model.savepointAsk == nil, "no field over a sealed commit")
            #expect(model.statusMessage == sealedSentence)
        }
    }
}

@MainActor
@Suite("Block History's rename door (13u3 UNIT D — R-13u3-1)", .serialized)
struct SavepointRenameDoorTests {
    /// Builds a note with one block, one take and one savepoint, and returns
    /// the pane's model already holding the block's history.
    private func world(
        _ h: EditorHarness, quiet: Bool = false
    ) async throws -> (model: BlockHistoryModel, commit: CommitPoint, variantID: String) {
        let ops = h.session.operations
        let slot = try h.storeSlots()[0]
        let variantID = try #require(slot.variantID)
        let commit: CommitPoint
        if quiet {
            try ops.autosave(variantID, text: "changed, unsaved", charDelta: 6)
            commit = try #require(try ops.idleAutoCommit(h.postID).first)
        } else {
            commit = try ops.commit(variantID)
        }
        let model = BlockHistoryModel(
            session: h.session, postID: h.postID, blockID: slot.blockID)
        model.adopt(try await h.session.database.read { [now = h.session.now] db in
            try Queries.blockHistory(db, blockID: slot.blockID, now: now)
        })
        return (model, commit, variantID)
    }

    private func message(_ h: EditorHarness, _ commitID: String) async throws -> String? {
        try await h.session.database.read { db in
            try CommitPoint.fetchOne(db, key: commitID)?.message
        }
    }

    /// **THE DOOR SHE RULED** — a savepoint's name is editable after the
    /// fact, and clearing the field removes it.
    @Test func renamingASavepointSetsAndClearsItsNameAndSaysSo() async throws {
        try await withEditor(seedBlocks: ["The sea took the boat."]) { h in
            let w = try await world(h)
            #expect(w.commit.message == nil)

            await w.model.rename(w.commit, to: "before the AI edit")
            #expect(try await message(h, w.commit.id) == "before the AI edit")
            #expect(w.model.status?.isRefusal == false)
            #expect(w.model.status?.text.contains("before the AI edit") == true)

            await w.model.rename(w.commit, to: "   ")
            #expect(try await message(h, w.commit.id) == nil, "clearing the field clears it")
            #expect(w.model.status?.text == BlockHistoryCopy.savepointNameCleared)
        }
    }

    /// **A ⏎ THAT WRITES NOTHING SAYS NOTHING** (13u3 ladder round 1, R1-2's
    /// face half — a receipt reports an act that LANDED, 18i's grammar). An
    /// unnamed savepoint's empty ⏎ used to speak *"Name cleared — …"* about a
    /// name that never existed, and the same name again re-spoke *"Saved
    /// moment named …"*; the receipt now rides the op's own did-write answer.
    @Test func aRenameThatWritesNothingSpeaksNoReceipt() async throws {
        try await withEditor(seedBlocks: ["The sea took the boat."]) { h in
            let w = try await world(h)
            #expect(w.commit.message == nil)

            // Empty ⏎ on an UNNAMED savepoint: no write, no words.
            await w.model.rename(w.commit, to: "")
            #expect(try await message(h, w.commit.id) == nil)
            #expect(w.model.status == nil,
                    "no \u{201C}Name cleared\u{201D} about a name that never existed")

            // The real write speaks…
            await w.model.rename(w.commit, to: "kept")
            #expect(w.model.status?.isRefusal == false)

            // …and the SAME name again (normalisation included) does not.
            await w.model.rename(w.commit, to: "  kept  ")
            #expect(try await message(h, w.commit.id) == "kept")
            #expect(w.model.status == nil,
                    "the same name again writes nothing and says nothing")
        }
    }

    /// **A QUIET SAVEPOINT TAKES A NAME TOO** (her unqualified "Editable"),
    /// and stays quiet — the occasion is not overwritten by the name.
    @Test func aQuietSavepointCanBeNamedAndStaysQuiet() async throws {
        try await withEditor(seedBlocks: ["The sea took the boat."]) { h in
            let w = try await world(h, quiet: true)
            #expect(w.commit.kind == .auto)

            await w.model.rename(w.commit, to: "the one before I left")

            let stored = try await h.session.database.read { [id = w.commit.id] db in
                try CommitPoint.fetchOne(db, key: id)
            }
            #expect(stored?.message == "the one before I left")
            #expect(stored?.kind == .auto, "the occasion stands")
            #expect(SavepointRowFace.details(try #require(stored), predatesSplit: false)
                .contains("quiet"))
        }
    }

    /// **THE SNAPSHOT IS NEVER TOUCHED** (I5), asserted where the door is.
    @Test func renamingNeverChangesWhatTheMomentHolds() async throws {
        try await withEditor(seedBlocks: ["The sea took the boat."]) { h in
            let w = try await world(h)
            let textBefore = w.commit.text
            // The take moves on AFTER the savepoint was written.
            try h.session.operations.autosave(
                w.variantID, text: "The sea gave it back.", charDelta: 6)

            await w.model.rename(w.commit, to: "the first ending")

            let stored = try await h.session.database.read { [id = w.commit.id] db in
                try CommitPoint.fetchOne(db, key: id)
            }
            #expect(stored?.text == textBefore, "the snapshot is the snapshot (I5)")
        }
    }

    /// A sealed note refuses the rename, in the pane's own refusal register
    /// — the seal refuses everything under the post (PROVISIONAL, #121).
    @Test func aSealedNoteRefusesTheRenameAndSaysWhy() async throws {
        try await withEditor(seedBlocks: ["The sea took the boat."]) { h in
            let w = try await world(h)
            try h.session.operations.lockPost(h.postID)

            await w.model.rename(w.commit, to: "too late")

            #expect(try await message(h, w.commit.id) == nil)
            #expect(w.model.status?.isRefusal == true)
            #expect(w.model.status?.text.isEmpty == false,
                    "a refusal that says nothing is not a refusal")
        }
    }
}

// **A MOUNTED PIN THIS UNIT TRIED AND DELETED, recorded rather than left
// passing vacuously.** I wrote a probe that mounts the real pane twice — a
// block with no savepoint and a block with one — and counts `KeyViewProxy`
// controls, to assert that a savepoint row now draws TWO doors (Name AND
// Restore) where it drew one. It measured **1 control in both mounts**: in
// this headless host the pane's ScrollView rows never realize, and the
// model's observation lands after the mount without rebuilding the tree
// (the pane's own batch-4 finding, one file over, met again from the other
// side). A probe that cannot see what it claims is not evidence, so the
// rename door's PRESENCE is walk evidence (capture `d-05`…`d-08`) and its
// decisions and its act are pinned above as values and through the model.

@MainActor
@Suite("The copy that teaches the name (13u3 UNIT D)")
struct SavepointNameCopyTests {
    /// **THE HELPER TEACHES THE TWO KEYS AND THE EDITABILITY.** ⌘S opens a
    /// field now; a dictionary entry and a shortcut row that stopped at
    /// "commit" would leave her at an unexplained box. RED ON OLD: neither
    /// carried ⏎ or the word "name".
    @Test func theHelperTeachesTheNameAndTheSkipKey() throws {
        let entry = try #require(HelperView.entries.first { $0.term == "commit" })
        #expect(entry.definition.contains("NAME"))
        #expect(entry.definition.contains("\u{23CE} saves it named or not"),
                "the two-key fast road, where someone looks up the word")
        #expect(entry.definition.contains("editable"),
                "her R-13u3-1 — a name is editable after the fact")
        #expect(entry.definition.contains("a name never touches the text"), "I5")
        // VX-347 (a justified edit): the definition says every way out of the
        // field but ⎋ commits — RED on the shipped entry.
        #expect(entry.definition.contains("any other way out of the field but \u{238B}"))

        let row = try #require(
            HelperView.groups.flatMap { $0.items }.first { $0.keys == "\u{2318}S" })
        #expect(row.does.contains("\u{23CE}"), "the shortcuts tab names the skip key too")
        #expect(HelperCheatSheet.summary.contains("\u{2318}S commit"),
                "the hover sheet still names the chord")
    }
}
