//
//  TakeStructureDoorTests.swift
//  VariorumTests
//
//  Phase 13e, batch 3 — take↔block structure. This file holds the DOOR half
//  (the core half is `VariorumCoreTests/TakeStructureTests.swift`):
//
//  - E6's clipboard door (her A21, verbatim: *"keyboard shortcut for copying
//    all takes together to clipboard"*): one brain (`TakeClipboard`), the
//    ratified export shape, the flush-first contract, the right-click's
//    explicit target, and the registry declaration with its chord.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withTakesWorld<T>(
    seedBlocks: [String],
    _ body: @MainActor (TakesWorld) async throws -> T
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
        let post = try session.operations.createPost(title: "13e batch 3")
        for text in seedBlocks {
            _ = try session.operations.newBlock(in: post.id, text: text)
        }
        let world = TakesWorld(
            session: session, database: db,
            model: TakesViewModel(session: session, postID: post.id),
            postID: post.id)
        try world.reload()
        return try await body(world)
    }
}

@MainActor
private struct TakesWorld {
    let session: AppSession
    let database: AppDatabase
    let model: TakesViewModel
    let postID: String

    /// The store's truth, adopted by hand (the observation never fires under
    /// the test host).
    func reload() throws {
        model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
    }

    func focus(blockID: String, variantID: String) {
        model.focus(TakesViewModel.PaneKey(
            columnID: TakesViewModel.takesMainColumnID,
            blockID: blockID, variantID: variantID))
    }

    func projection(of blockID: String) throws -> (markdown: String, takeCount: Int) {
        try database.read { try Queries.blockTakes($0, blockID: blockID) }
    }

    func fan(of blockID: String) throws -> [Variant] {
        try database.read { try Queries.blockFan($0, blockID: blockID) }
    }
}

/// A pasteboard of this test's own — her real clipboard is never touched.
@MainActor
private func scratchPasteboard(_ name: String) -> TakeClipboard.Destination {
    let destination = TakeClipboard.Destination.named("io.lduarte.variorum.tests.\(name)")
    destination.pasteboard.clearContents()
    return destination
}

// MARK: - E5 / E6b: the take↔block doors (her A20/A21, under AR-1)

@MainActor
@Suite("The take↔block doors (13e E5/E6b, A20/A21)")
struct TakeToBlockDoorTests {
    /// Adds a second take ("Second take.") to the world's one block and
    /// returns (slot, firstTakeID, secondTakeID) against the fresh
    /// projection.
    @MainActor
    private func fanned(
        _ world: TakesWorld
    ) throws -> (slot: Queries.RenderedBlock, first: String, second: String) {
        let slot = try #require(world.model.projection.slots.first)
        let first = try #require(slot.variantID)
        let second = try world.session.operations.branchVariant(slot.blockID, from: first)
        try world.session.operations.autosave(second.id, text: "Second take.", charDelta: 0)
        try world.reload()
        return (try #require(world.model.projection.slots.first), first, second.id)
    }

    @Test func theBoardDoorMovesTheTakeYoureInAndTheRingFollowsIt() async throws {
        try await withTakesWorld(seedBlocks: ["Shown take."]) { world in
            let fan = try fanned(world)
            world.focus(blockID: fan.slot.blockID, variantID: fan.second)

            await world.model.moveTakeIntoBlockBelow()
            try world.reload()

            // Two blocks now, the new one immediately below, carrying the
            // take's text; the original is ARCHIVED on its own block (AR-1).
            let slots = world.model.projection.slots
            #expect(slots.count == 2)
            #expect(slots[0].blockID == fan.slot.blockID)
            #expect(slots[1].text == "Second take.")
            let archived = try world.fan(of: fan.slot.blockID)
                .first { $0.id == fan.second }
            #expect(archived?.status == .archived)
            #expect(archived?.deletedAt == nil)
            // The ring hands over to the minted block's pane (the
            // insert-below handover), and the receipt names the road back.
            #expect(world.model.focusedPane?.blockID == slots[1].blockID)
            #expect(world.model.statusMessage?.contains("archived") == true)
        }
    }

    /// **THE BOARD'S STRUCTURAL RECEIPTS ARE NOT ALARMS** (the 18i ladder
    /// round 1, MINOR-4 — J34). Five of this controller's messages reported
    /// acts that LANDED and went through `speak`, the fire-and-speak door for
    /// a door that CANNOT act — so `WriteTakesPanel`'s own slot painted them
    /// `tokens.alarm` (`status.isRefusal ? alarm : muted`), and *"Take moved
    /// earlier — ⌥⌘Z undoes it."* had been reading as an error since the
    /// post-13l polish round. 18i re-classed them, and this is the pin that
    /// fix owed: `theBoardTellsAReceiptFromARefusal` drives `setStatus`/`speak`
    /// directly, so it pins the MECHANISM and says nothing about which of the
    /// two these SITES call.
    ///
    /// **Red on old** by the one-word revert the fix itself made — `setStatus`
    /// back to `speak` at `TakesStructureController`'s two move doors.
    @Test func theBoardsStructuralReceiptsAreNotAlarms() async throws {
        try await withTakesWorld(seedBlocks: ["Shown take.", "Next block."]) { world in
            let fan = try fanned(world)
            world.focus(blockID: fan.slot.blockID, variantID: fan.second)

            // (1) the take moves within its fan — the act landed.
            await world.model.moveTake(fan.second, in: fan.slot.blockID, by: -1)
            #expect(world.model.status?.isRefusal == false,
                    "a take that MOVED is a receipt, not an alarm: \(world.model.status?.text ?? "nil")")
            #expect(world.model.status?.text.contains("Take moved") == true)

            // (2) the take becomes the block below — the second door, same class.
            try world.reload()
            let after = try #require(world.model.projection.slots.first)
            world.focus(blockID: after.blockID, variantID: try #require(after.variantID))
            await world.model.moveTakeIntoBlockBelow()
            #expect(world.model.status?.isRefusal == false,
                    "a take that BECAME a block is a receipt: \(world.model.status?.text ?? "nil")")

            // …and the door that genuinely cannot act still refuses, so the
            // pin cannot pass by the class simply never being a refusal.
            await world.model.moveTake(fan.second, in: "no-such-block", by: 1)
            #expect(world.model.status?.isRefusal == true)
        }
    }

    /// **A BOARD DOOR THAT COULD NOT ACT STILL SPEAKS** (the 18i ladder round
    /// 2's BLOCKER — J38). Eight `TakesViewModel` messages that report that
    /// NOTHING happened were classed `RecoveryStatus.receipt`, which the board
    /// has carried since the post-13l polish round as a PANEL-COLOUR mistake.
    /// 18i's one load-bearing move — letting that class ride to the shell
    /// (`TakesViewModel.swift:143–154`) — turned it into a VISIBILITY one: her
    /// setting began deciding whether a refusal is shown at all, and neither
    /// board renders a local status slot, so under `.off` ⌘S with no take
    /// focused said nothing whatsoever.
    ///
    /// Two arms, the keyboard road and the click road.
    /// **Red on old:** `current == nil`, the sentence sitting in
    /// `lastDroppedReceipt`.
    @Test func aBoardDoorThatCouldNotActStillSpeaksUnderEverySetting() async throws {
        try await withTakesWorld(seedBlocks: ["Shown take."]) { world in
            world.session.status.receiptStyle = .off

            // (1) ⌘S with no pane focused — a guard-else that returns.
            #expect(world.model.focusedPane == nil, "no ring — the door cannot act")
            await world.model.commitFocusedTake()
            #expect(world.session.status.current?.text
                    == "Click into a take first — \u{2318}S commits the take you're in.")
            #expect(world.session.status.current?.kind == .refusal,
                    "a door that could not act always says why (P-2)")
            #expect(world.session.status.lastDroppedReceipt == nil,
                    "nothing was dropped — this was never a receipt")

            // (2) the click road: Adopt on the column that IS the note.
            world.session.status.clear()
            let main = try #require(world.model.columns.first)
            await world.model.adoptColumn(main.id)
            #expect(world.session.status.current?.text
                    == "This column IS the note — nothing to adopt.")
            #expect(world.session.status.current?.kind == .refusal)
            #expect(world.session.status.lastDroppedReceipt == nil)

            // …and a door that DID act is still a receipt, so the pin cannot
            // pass by the board having stopped speaking receipts at all.
            world.session.status.clear()
            world.session.status.receiptStyle = .quiet
            await world.model.setNewlinesMintBlocks(false)
            #expect(world.session.status.quietLine?.kind == .receipt)
            #expect(world.session.status.current == nil)
        }
    }

    @Test func theCardDoorActsOnItsOwnTakeNotTheFocusedOne() async throws {
        // A right-click never moves the keyboard (13k K6's lesson): the card
        // names both its block AND its take.
        try await withTakesWorld(seedBlocks: ["First block.", "Second block."]) { world in
            let slots = world.model.projection.slots
            let first = slots[0]
            let second = slots[1]
            let secondsExtra = try world.session.operations.branchVariant(
                second.blockID, from: try #require(second.variantID))
            try world.session.operations.autosave(
                secondsExtra.id, text: "Other take.", charDelta: 0)
            try world.reload()
            world.focus(blockID: first.blockID, variantID: try #require(first.variantID))

            await world.model.moveTakeIntoBlockBelow(
                blockID: second.blockID, variantID: secondsExtra.id)
            try world.reload()

            #expect(world.model.projection.slots.map(\.text)
                == ["First block.", "Second block.", "Other take."])
        }
    }

    @Test func theDoorFlushesFirstSoTheNewBlockCarriesWhatSheJustTyped() async throws {
        // The op reads the STORE; the pane buffer is a debounce ahead of it.
        // Without the flush the minted block would carry prose she had
        // already replaced on screen (the copy-doors class, KnownIssues).
        try await withTakesWorld(seedBlocks: ["Shown take."]) { world in
            let fan = try fanned(world)
            world.focus(blockID: fan.slot.blockID, variantID: fan.second)
            world.model.paneEdited(variantID: fan.second, newText: "Typed after branching.")

            await world.model.moveTakeIntoBlockBelow()
            try world.reload()

            #expect(world.model.projection.slots.last?.text == "Typed after branching.")
        }
    }

    @Test func aRefusalArrivesInWordsNotAsAnEnumDump() async throws {
        // A one-take block has nothing to move out (I10 — `lastActiveVariant`),
        // and that refusal used to dump the raw enum.
        try await withTakesWorld(seedBlocks: ["The only take."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            world.focus(blockID: slot.blockID, variantID: try #require(slot.variantID))

            await world.model.moveTakeIntoBlockBelow()
            try world.reload()

            #expect(world.model.projection.slots.count == 1)
            let message = try #require(world.model.statusMessage)
            #expect(message.contains("only one take"))
            #expect(message.contains("lastActiveVariant") == false)
        }
    }

    @Test func theConversionCountsItsBlocksAndNamesTheBlanksItSkipped() async throws {
        try await withTakesWorld(seedBlocks: ["Shown take."]) { world in
            let fan = try fanned(world)
            // Branched from the SECOND take, so it lands after it in the fan
            // (`branchVariant` puts a branch beside its source) — the run
            // below must come out in exactly that order.
            let third = try world.session.operations.branchVariant(
                fan.slot.blockID, from: fan.second)
            try world.session.operations.autosave(third.id, text: "Third take.", charDelta: 0)
            _ = try world.session.operations.newBlankVariant(fan.slot.blockID)  // skipped
            try world.reload()

            await world.model.turnTakesIntoBlocks(blockID: fan.slot.blockID)
            try world.reload()

            // The block still shows what it showed; the alternates follow in
            // fan order (AR-1(c)); the blank is left alone and NAMED (AR-1(d)).
            #expect(world.model.projection.slots.map(\.text)
                == ["Shown take.", "Second take.", "Third take."])
            let message = try #require(world.model.statusMessage)
            #expect(message.contains("2 takes are now their own blocks below"))
            #expect(message.contains("1 blank take was left alone"))
        }
    }

    @Test func theConversionRefusesHonestlyWhenThereIsNoOtherTake() async throws {
        try await withTakesWorld(seedBlocks: ["Alone."]) { world in
            let slot = try #require(world.model.projection.slots.first)

            await world.model.turnTakesIntoBlocks(blockID: slot.blockID)
            try world.reload()

            #expect(world.model.projection.slots.count == 1)
            let message = try #require(world.model.statusMessage)
            #expect(message.contains("no other takes with text"))
        }
    }

    @Test func bothActsAreDeclaredWithTheirChordsDoorsAndParity() {
        for (id, verb, label) in [
            (CapabilityID.takeToBlockBelow, "Move Take into a Block Below", "⌥⌘⏎"),
            (CapabilityID.takesToBlocks, "Turn All Takes into Blocks", "⇧⌥⌘⏎"),
        ] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.verb == verb)
            #expect(capability.scope == .take)
            #expect(capability.doors == [.menuBar, .contextMenu])
            #expect(capability.shortcutLabel == label)
            #expect(capability.takesAccess == .native)
            // R118: native in Takes, and never available where no note is.
            #expect(CapabilityRegistry.availability(
                id, in: CapabilityContext(mode: .takes)) == .act)
            #expect(CapabilityRegistry.availability(
                id, in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
            #expect(CapabilityRegistry.availability(id, in: CapabilityContext()) == .unavailable)
            #expect(EditorCommands.menuRendered.contains(id))
            #expect(TakesCellView.contextMenuCapabilities.contains(id))
            // The chord is wired in the ONE place keys are declared, and it
            // is a RETURN chord free of ⌘⏎ / ⌘⇧⏎.
            let key = try? #require(EditorCommands.keyEquivalent(for: id))
            #expect(key?.0 == .return)
        }
        #expect(EditorCommands.keyEquivalent(for: .takeToBlockBelow)?.1 == [.command, .option])
        #expect(EditorCommands.keyEquivalent(for: .takesToBlocks)?.1
            == [.command, .option, .shift])
    }
}

// MARK: - E6's clipboard half (her A21)

@MainActor
@Suite("Copy all takes (13e E6, A21)")
struct CopyAllTakesDoorTests {
    @Test func theDoorCopiesTheWholeFanInTheRatifiedShapeAndCountsIt() async throws {
        try await withTakesWorld(seedBlocks: ["Shown take."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let second = try world.session.operations.branchVariant(
                slot.blockID, from: try #require(slot.variantID))
            try world.session.operations.autosave(
                second.id, text: "Second take.", charDelta: 0)
            try world.reload()

            let destination = scratchPasteboard("copy-fan")
            let expected = try world.projection(of: slot.blockID)
            let outcome = await TakeClipboard.copyBlock(
                slot.blockID, session: world.session, to: destination)

            #expect(outcome == .copied(takes: 2))
            #expect(destination.pasteboard.string(forType: .string) == expected.markdown)
            #expect(expected.markdown.contains("Second take."))
            #expect(outcome.message.contains("2 takes"))
        }
    }

    @Test func aBlockWithNoTextCopiesNothingAndLeavesTheClipboardAlone() async throws {
        try await withTakesWorld(seedBlocks: [""]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let destination = scratchPasteboard("copy-empty")
            TakeClipboard.write("something older", to: destination)

            let outcome = await TakeClipboard.copyBlock(
                slot.blockID, session: world.session, to: destination)

            #expect(outcome == .nothingToCopy)
            // The refusal must not eat what she had on the clipboard.
            #expect(destination.pasteboard.string(forType: .string) == "something older")
        }
    }

    @Test func theDoorCarriesWhatSheJustTypedNotTheStoresLastWord() async throws {
        // The flush-first contract: the projection reads the STORE, and a pane
        // buffer is normally a debounce ahead of it. Without the flush the
        // clipboard would carry prose she has already replaced on screen.
        try await withTakesWorld(seedBlocks: ["Before typing."]) { world in
            let slot = try #require(world.model.projection.slots.first)
            let variantID = try #require(slot.variantID)
            world.focus(blockID: slot.blockID, variantID: variantID)
            world.model.paneEdited(variantID: variantID, newText: "After typing.")

            let destination = scratchPasteboard("copy-flush")
            await world.model.copyAllTakes(blockID: slot.blockID, to: destination)

            #expect(destination.pasteboard.string(forType: .string) == "After typing.")
            #expect(try world.projection(of: slot.blockID).markdown == "After typing.")
            #expect(world.model.statusMessage?.contains("Copied") == true)
        }
    }

    @Test func withNoBlockInHandTheDoorSaysWhatToDo() async throws {
        // Two blocks and no ring ⇒ nothing is "the block you're in"
        // (`commandTargetSlot`'s rule), so the door speaks instead of copying
        // a block she never pointed at.
        try await withTakesWorld(seedBlocks: ["One.", "Two."]) { world in
            await world.model.copyAllTakes()
            #expect(world.model.statusMessage?.contains("Click into a block first") == true)
        }
    }

    @Test func theRightClicksTargetIsTheCardsOwnBlockNotTheFocusedOne() async throws {
        // 13k K6's lesson, same fix: a right-click never moves the keyboard,
        // so the card's door names its block explicitly.
        try await withTakesWorld(seedBlocks: ["First block.", "Second block."]) { world in
            let slots = world.model.projection.slots
            #expect(slots.count == 2)
            let first = slots[0]
            let second = slots[1]
            world.focus(blockID: first.blockID, variantID: try #require(first.variantID))

            let destination = scratchPasteboard("copy-target")
            let outcome = await TakeClipboard.copyBlock(
                second.blockID, session: world.session, to: destination)

            #expect(outcome == .copied(takes: 1))
            #expect(destination.pasteboard.string(forType: .string) == "Second block.")
        }
    }

    @Test func theActIsDeclaredWithItsChordBothDoorsAndTakesParity() {
        let capability = CapabilityRegistry.capability(.copyAllTakes)
        #expect(capability.verb == "Copy All Takes")
        #expect(capability.scope == .take)
        #expect(capability.doors == [.menuBar, .contextMenu])
        #expect(capability.shortcutLabel == "⌘⇧C")
        #expect(capability.takesAccess == .native)
        // Native wherever takes are — and honestly grey where no note is open.
        #expect(CapabilityRegistry.availability(
            .copyAllTakes, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .copyAllTakes, in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(CapabilityRegistry.availability(
            .copyAllTakes, in: CapabilityContext()) == .unavailable)
        // The chord is wired in the ONE place keys are declared, and ⌘C is
        // untouched (it is the system's Copy).
        let key = EditorCommands.keyEquivalent(for: .copyAllTakes)
        #expect(key?.0 == "c")
        #expect(key?.1 == [.command, .shift])
        #expect(TakesCellView.contextMenuCapabilities.contains(.copyAllTakes))
        #expect(EditorCommands.menuRendered.contains(.copyAllTakes))
    }
}
