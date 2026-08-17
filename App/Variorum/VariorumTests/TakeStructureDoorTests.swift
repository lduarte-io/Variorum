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
}

/// A pasteboard of this test's own — her real clipboard is never touched.
@MainActor
private func scratchPasteboard(_ name: String) -> TakeClipboard.Destination {
    let destination = TakeClipboard.Destination.named("io.lduarte.variorum.tests.\(name)")
    destination.pasteboard.clearContents()
    return destination
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
