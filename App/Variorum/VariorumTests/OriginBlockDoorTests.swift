//
//  OriginBlockDoorTests.swift
//  VariorumTests
//
//  Phase 13f, batch 2 — W10, both halves. Her sitting question, verbatim:
//  *"I tried doing a divide and I see that it says 'won't come to either new
//  block' if I don't select it, remains whole on the original one, but how do
//  I even see the original one? I tried going to the history of one of the
//  post divide takes but I don't see it."*
//
//  Two answers, and this suite pins both:
//
//  W10a — the ceremony NAMES the destination, in the sheet and in the
//  completion. The copy lives as pure statics on `DivideWCeremony` precisely
//  so it is pinned here rather than read off a screenshot: a promise made in
//  a `Text` literal is a promise no test can keep.
//
//  W10b — a successor block offers a door straight back at its released
//  original. The door is registry-declared and rendered ONLY where such an
//  origin exists (P-2).
//
//  **13j MOVED W10b's landing TWICE, and the arms moved with it.** Her
//  round-2 ruling removed the global "Unplaced blocks" listing this door used
//  to navigate to, so batch 2 repointed it at the note's own tray as a
//  bridge; rounds 4 + 5 then ruled the final form, and batch 3 built it — the
//  door opens a READ-ONLY PEEK of the original, with Put back and the tray as
//  its two actions. Each move made the arms stronger, not weaker: what once
//  asserted a posted notification now asserts the raised request, which names
//  the destination rather than the signal. The peek's own behaviour (its two
//  actions, the op-aware wording, the History face's row) is pinned in
//  `RecoveryDoorsTests`; this suite keeps W10's claims.
//
//  What is NOT pinned here, deliberately and per the batch's honesty rule:
//  the SwiftUI drop/reveal geometry (the `ScrollViewReader` scroll and the
//  row's mark). Batch 1 measured that the hosted drag/drop path calls private
//  selectors and cannot be driven in this test host; the same applies to
//  asserting that a `List` really scrolled. Those halves are named in the
//  batch record as visual-verification-only.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The released original's door (13f W10)")
struct OriginBlockDoorTests {
    // MARK: - W10a: the copy names where the original goes

    /// The sheet said an unchecked take "stays whole on the original" and
    /// stopped. Both sentences now carry the road, in the same grammar the
    /// merge ceremony has used all along.
    @Test func theCeremonyCopyNamesTheRecoverySurface() {
        #expect(DivideWCeremony.checklistExplainer.contains(TrayPath.originalsPath),
                "the explainer names the full path, section included")
        // 18f ladder R1-4 (fable-reviewer): the caption's ONE home is the
        // card's status line now (`uncheckedRowNote` was retired — it had no
        // caller after batch 2's card, and this pin was green over it).
        #expect(CeremonyCardCopy.status(.original, words: nil).contains(TrayPath.originalsPath),
                "so does the caption under the unchecked take she is looking at")
        // 13j J6: the name is the DOOR's own — the tray panel's title and
        // its section header read the same constants the sentence does, so
        // the copy cannot point at a label that isn't there. (Before J6 this
        // pointed at the Library's removed "Unplaced blocks" section.)
        // **A JUSTIFIED EDIT** (the post-13l polish round, ledger row 17):
        // the DESTINATION moved — her G5 ruling put unclocked originals in
        // lineage, not the tray — and the eight copy sites followed the ONE
        // constant for free, which is the whole argument for the constant,
        // made good a second time. The CLAIM is unchanged: the sentence
        // names a place that really has that name and that door.
        #expect(TrayPath.originalsPath.contains(BlockHistoryPath.name))
        #expect(TrayPath.originalsPath.contains(BlockHistoryPath.cameFromSection))
        #expect(!TrayPath.originalsPath.contains(TrayPath.menuLabel),
                "the tray no longer lists them — pointing there would be a lie")
        #expect(TrayPath.originalsPathWithDoor.contains(BlockHistoryPath.doorPhrase),
                "the teaching form names the way in, not just the place")
    }

    /// The completion sentence: only when an unchecked take actually rode the
    /// original away, singular/plural honest, and always with the undo.
    @Test func theCompletionNamesTheDestinationOnlyWhenSomethingRodeAway() {
        #expect(DivideWCeremony.releasedOriginalNote(uncheckedTakes: 0) == nil,
                "every take checked — nothing she wasn't shown went anywhere")
        let one = try? #require(DivideWCeremony.releasedOriginalNote(uncheckedTakes: 1))
        #expect(one?.contains("1 uncut take") == true)
        #expect(one?.contains("uncut takes") == false, "singular stays singular")
        let three = try? #require(DivideWCeremony.releasedOriginalNote(uncheckedTakes: 3))
        #expect(three?.contains("3 uncut takes") == true)
        #expect(three?.contains(TrayPath.originalsPath) == true)
        #expect(three?.contains("\u{2325}\u{2318}Z") == true, "the ratified undo grammar")
    }

    /// End to end through the REAL ceremony: a three-take block divided on
    /// one take leaves two uncut, and the surface says where they went.
    @Test func confirmingWithUncheckedTakesSpeaksTheDestination() async throws {
        try await withBoard(seedBlocks: ["Alpha beta. Gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused(ceremony: true)
            let ceremony = try #require(board.model.divideWCeremony)
            // **A JUSTIFIED EDIT (18f batch 2), the CLAIM intact.** Her U-3
            // ruling (batch 1) retired this pin's SETUP: the sheet opens with
            // every take CHECKED, so "the seed take alone is checked" is no
            // longer a state the ceremony can be in. Two takes riding the
            // original away is now something she MAKES, under "Choose per
            // take…" — which is exactly where the sentence this pin is about
            // still has work to do. *(Red on the 18f batch 1 tree too,
            // verified by running this suite at `a990ccbd`: batch 1's closing
            // run did not include this suite.)*
            board.model.ceremony.setArrangement(.perTake)
            let opened = try #require(board.model.divideWCeremony)
            for take in opened.takes where take.id != chosen {
                board.model.ceremony.toggleTake(take.id)
            }
            let arranged = try #require(board.model.divideWCeremony)
            #expect(arranged.takes.count(where: { !$0.marked }) == 2,
                    "two takes are unchecked — they ride the original away")
            _ = ceremony

            await board.model.ceremony.confirm()
            let status = try #require(board.model.statusMessage)
            #expect(status.contains("2 uncut takes"), "\(status)")
            #expect(status.contains(TrayPath.originalsPath), "\(status)")
        }
    }

    /// …and stays quiet when nothing was left uncut: the original is still
    /// released (the W always preserves A whole), but a note on every divide
    /// would be noise where the ruling asked for an answer.
    @Test func confirmingWithEveryTakeCheckedKeepsTheOrdinaryCompletion() async throws {
        try await withBoard(seedBlocks: ["Alpha beta. Gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()

            board.focus(blockID: slot.blockID, variantID: chosen, caret: 11)
            await board.model.divideFocused(ceremony: true)
            let ceremony = try #require(board.model.divideWCeremony)
            // **A JUSTIFIED EDIT (18f batch 2), the CLAIM intact.** U-3 makes
            // "every take checked" the OPENING state rather than something
            // the pin has to construct, so the construction goes: the sheet
            // opens keep-on-top with the second take parked at its end, and
            // confirming there is precisely "nothing was left uncut".
            #expect(ceremony.takes.count(where: { !$0.marked }) == 0,
                    "U-3: the sheet opens with every take checked")
            await board.model.ceremony.confirm()

            let status = try #require(board.model.statusMessage)
            // 18f ladder R1-9: the receipt no longer echoes the retired sheet
            // title ("Divide into takes", U-4); it is the divide receipt's
            // own line — and since round 2's R2-3 it COUNTS: keep-on-top
            // parked the second take at its end, so one other take stayed on
            // the first block, and the receipt says so (the board's instant
            // road's own rule). The claim — no "uncut takes" note, because
            // nothing was left uncut — is unchanged.
            #expect(status == FannedDefaultsCopy.divided(kept: 1),
                    "the completion, in the receipt's one home: \(status)")
            #expect(!status.contains("uncut"), "nothing was left uncut, so no destination note")
        }
    }

    // MARK: - W10b: the door, and only where it can act

    @Test func theRegistryDeclaresTheDoorAsABlockScopedContextAct() {
        let door = CapabilityRegistry.capability(.showOriginBlock)
        // **A JUSTIFIED PIN EDIT (13j J3).** The CLAIM is unchanged — a
        // block-scoped act, native in Takes, grey with no post open — but her
        // rounds 4 + 5 gave the door its final grammar: three SUMMONED doors
        // (right-click, ⌘K, the History face's lineage row) and no ambient
        // chrome. The verb is the target-less form the palette shows; the
        // context row's op-aware words are `OriginPeekCopy.doorVerb`, pinned
        // in `RecoveryDoorsTests`.
        #expect(door.verb == OriginPeekCopy.genericVerb)
        #expect(door.scope == .block)
        // **A JUSTIFIED EDIT** (the post-13l polish round, ledger row 17):
        // the `.surface` door was the History face's lineage ROW, and the
        // face is now the pane this act LANDS in. Two summoned doors — which
        // is what her round-4 criterion asked for in the first place.
        #expect(door.doors == [.contextMenu, .palette])
        #expect(door.takesAccess == .native, "R118: not a Write privilege")
        // Acts where blocks are edited; honestly grey with no post open.
        #expect(CapabilityRegistry.availability(
            .showOriginBlock, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .showOriginBlock,
            in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(!CapabilityRegistry.isEnabled(
            .showOriginBlock, in: CapabilityContext(mode: nil)))
    }

    /// The whole W10b claim in Write, over a REAL divide-W: before the
    /// ceremony no block has an origin and the menu is exactly what it was;
    /// after it, both successors carry the door and it names A.
    @Test func onlyASuccessorOfAReleasedOriginalRendersTheDoor() async throws {
        try await withEditor(seedBlocks: ["Alpha beta. Gamma delta."]) { editor in
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            _ = try editor.session.operations.branchVariant(slot.blockID, from: chosen)

            @MainActor func refreshOrigins() throws {
                editor.model.adoptUnplacedOrigins(try editor.database.read {
                    [postID = editor.postID] db in
                    try Queries.unplacedOrigins(db, inContainer: postID)
                })
            }
            @MainActor func menuTitles() -> [String] {
                editor.model.contextMenuItems().map(\.title)
            }

            try refreshOrigins()
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            #expect(editor.model.caretBlockOriginID == nil)
            let before = menuTitles()
            // 13j J3: the row now says WHICH act released the original
            // (her ruled wording); the CLAIM — an ordinary block's menu is
            // untouched — is unchanged.
            #expect(!before.contains(where: { $0.hasPrefix("See original from") }),
                    "an ordinary block's menu is untouched: \(before)")

            let w = try editor.session.operations.divideW(
                slot.blockID, cuts: [chosen: 11])
            try editor.reload()
            try refreshOrigins()

            // The caret sits in the FIRST successor now.
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            #expect(editor.model.caretBlockID == w.first.block.id)
            #expect(editor.model.caretBlockOriginID == slot.blockID,
                    "the door names A — the block the ceremony preserved whole")
            #expect(menuTitles().contains(OriginPeekCopy.doorVerb(op: "divide")),
                    "the row names the act that released it: \(menuTitles())")
            #expect(menuTitles().count == before.count + 1,
                    "exactly one item joined; nothing else moved")

            // …and the SECOND successor too — both carry the edge.
            let secondSlot = try #require(try editor.storeSlots().last)
            let range = try #require(
                editor.model.index.entries.firstIndex { $0.blockID == secondSlot.blockID }
                    .map { editor.model.index.range(ofEntryAt: $0) })
            editor.textView.setSelectedRange(NSRange(location: range.location, length: 0))
            editor.model.updateCaretContext()
            #expect(editor.model.caretBlockOriginID == slot.blockID)
        }
    }

    /// The door is a PLACEMENT question, not a lineage one — and the SURFACE
    /// has to know that, not just the query. An ordinary in-place divide
    /// leaves A on the page, so its minted successor carries a `derived_from`
    /// edge and still gets NO door: the block it came from is right there.
    ///
    /// (This arm exists because revert W10b-A ran GREEN against the Mac suite
    /// without it — the standing rule is that a revert which passes gets a
    /// stronger arm before the work is trusted.)
    @Test func aPlainDividesSuccessorGetsNoDoorBecauseItsOriginIsStillOnThePage() async throws {
        try await withEditor(seedBlocks: ["Alpha beta. Gamma delta."]) { editor in
            let slot = try #require(try editor.storeSlots().first)
            let minted = try editor.session.operations.divide(slot.blockID, cut: 11)
            try editor.reload()
            editor.model.adoptUnplacedOrigins(try editor.database.read {
                [postID = editor.postID] db in
                try Queries.unplacedOrigins(db, inContainer: postID)
            })

            // The successor really does have the edge…
            let ancestors = try editor.database.read { db in
                try Queries.ancestors(db, of: minted.block.id)
            }
            #expect(ancestors.map(\.blockID) == [slot.blockID])

            // …and still no door, because A never left the page.
            let range = try #require(
                editor.model.index.entries.firstIndex { $0.blockID == minted.block.id }
                    .map { editor.model.index.range(ofEntryAt: $0) })
            editor.textView.setSelectedRange(NSRange(location: range.location, length: 0))
            editor.model.updateCaretContext()
            #expect(editor.model.caretBlockID == minted.block.id)
            #expect(editor.model.caretBlockOriginID == nil)
            #expect(!editor.model.contextMenuItems().map(\.title)
                .contains(where: { $0.hasPrefix("See original from") }))
        }
    }

    /// Fire-and-DO (P-2): invoking opens the block's HISTORY PANE, at its
    /// came-from region — the door's THIRD and last landing (the post-13l
    /// polish round, ledger row 17), after 13f's navigation to the listing J6
    /// removed and 13j J3's own peek.
    ///
    /// **A JUSTIFIED EDIT to what the pin drives, and the claim is stronger
    /// for it:** the peek showed `.first` of an array whose own doc says a
    /// merge releases both sources, so the pin could only ever assert that
    /// ONE original was reachable. The pane's region reads the whole array,
    /// which is the 13l walk's P-3 fixed — and `theCameFromRegionShowsEveryOne`
    /// in `RecoveryDoorsTests` is where that half is held.
    @Test func theDoorOpensTheBlocksHistoryAtItsCameFrom() async throws {
        try await withEditor(seedBlocks: ["one"]) { editor in
            #expect(editor.model.blockHistoryRequest == nil)
            let slot = try #require(try editor.storeSlots().first)
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            editor.model.requestBlockHistory()
            let request = try #require(editor.model.blockHistoryRequest)
            #expect(request.postID == editor.postID, "the note she is standing in")
            #expect(request.blockID == slot.blockID, "…and the block she is IN")
            #expect(request.focusedVariantID == slot.variantID,
                    "the take she is in, so its savepoint run opens expanded")
        }
    }

    /// The takes board carries the same door off the same projection field —
    /// R118's letter (the board is where she asked the question).
    @Test func theBoardsProjectionCarriesTheOriginsAndItsDoorActs() async throws {
        try await withBoard(seedBlocks: ["Alpha beta. Gamma delta."]) { board in
            let slot = try #require(try board.slots().first)
            let chosen = try #require(slot.variantID)
            _ = try board.session.operations.branchVariant(slot.blockID, from: chosen)
            try board.reload()
            #expect(board.model.projection.unplacedOrigins.isEmpty)

            let w = try board.session.operations.divideW(slot.blockID, cuts: [chosen: 11])
            try board.reload()
            // 13j J3: the projection's values carry the act and the date
            // now — a menu builder runs synchronously and cannot ask the
            // store which act released the block. Same CLAIM, richer value.
            let origins = try #require(
                board.model.projection.unplacedOrigins[w.first.block.id])
            #expect(origins.map(\.blockID) == [slot.blockID],
                    "the board reads the origin off its ordinary projection")
            #expect(origins.first?.originOp == "divide")

            board.model.revealOriginBlock(ofBlock: w.first.block.id)
            let request = try #require(board.model.blockHistoryRequest)
            #expect(request.postID == board.postID)
            // The pane is scoped to the SUCCESSOR — the block she right-clicked
            // — and its came-from region is what names the original.
            #expect(request.blockID == w.first.block.id)
        }
    }

    // MARK: - Harnesses (the TakesDivideTests shapes, local)

    @MainActor
    private struct Board {
        let session: AppSession
        let database: AppDatabase
        let model: TakesViewModel
        let postID: String

        func reload() throws {
            model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
        }

        func slots() throws -> [Queries.RenderedBlock] {
            try database.read { try Queries.renderPost($0, containerID: postID) }
        }

        func focus(blockID: String, variantID: String, caret: Int) {
            let key = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: blockID, variantID: variantID)
            model.focus(key)
            model.notePaneSelection(
                variantID: variantID, range: NSRange(location: caret, length: 0))
        }
    }

    private func withBoard<T>(
        seedBlocks: [String],
        _ body: @MainActor (Board) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "W10")
            for text in seedBlocks {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            let model = TakesViewModel(session: session, postID: post.id)
            let board = Board(
                session: session, database: db, model: model, postID: post.id)
            try board.reload()
            return try await body(board)
        }
    }
}
