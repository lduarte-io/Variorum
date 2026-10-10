//
//  MCPNavigationTests.swift
//  VariorumTests (Mac)
//
//  13n-b U4 — NAVIGATION's app half (R-13nb-23 + R-13nb-26 (g); AF-11 F-2/
//  F-3): `show_in_app` refused unless Variorum is frontmost in a FULL window
//  (pinned at the decision seam — `MCPDoor.agentShow` applying
//  `MCPShowRule` — with nothing moved on a refusal), each target delivered
//  through her own roads (the shell's adoption door + the block landing + the
//  13o find seed; the see-takes landing; the Lenses board's lens landing;
//  Outline's chapter landing), the receipts' "Open ›" and the session's
//  "Show the AI's Last Change" (⌥⌘O, alive after the fade and under receipt
//  style off), the lens board's R83 column rule, and the two found-defect
//  refusal words (AF-11 F-1's approved J8 fix + its put-back twin).
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
import VariorumMCP
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13n-b U4 — navigation: the move dial, the offer door, the keyboard road", .serialized)
struct MCPNavigationTests {
    // MARK: - show_in_app's etiquette, at the decision seam

    @Test func showInAppMovesNothingUnlessVariorumIsFrontInAFullWindow() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let router = ShellRouter()
            let resting = router.workspace.focusedSelection
            let target = MCPShowTarget.note(noteID: "n1", blockID: "b1", select: "words")

            door.standingProvider = { (.notFrontmost, router) }
            #expect(await door.agentShow(target) == .refuse(MCPShowRule.notFrontmostWords))
            door.standingProvider = { (.frontmostOtherWindow, router) }
            #expect(await door.agentShow(target) == .refuse(MCPShowRule.otherWindowWords))
            #expect(router.workspace.focusedSelection == resting && router.blockLanding == nil,
                    "nothing moved — refused, never queued")

            door.standingProvider = { (.frontmostMainWindow, router) }
            #expect(await door.agentShow(target) == .navigate)
            #expect(router.workspace.focusedSelection == .post("n1"))
            #expect(router.blockLanding == ShellRouter.BlockLanding(
                containerID: "n1", blockID: "b1", find: EditorFindSeed(needle: "words", steps: true)),
                    "the 13o landing road verbatim: the block, the words selected, the find bar armed")
        }
    }

    @Test func aBookTargetParksOutlinesChapterLandingAndOpensTheBook() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let router = ShellRouter()
            door.standingProvider = { (.frontmostMainWindow, router) }
            #expect(await door.agentShow(.book(bookID: "r1", sectionID: "s1")) == .navigate)
            #expect(router.workspace.focusedSelection == .reading("r1"))
            #expect(router.pendingBookChapter == ShellRouter.BookChapterLanding(bookID: "r1", sectionID: "s1"))
            #expect(await door.agentShow(.book(bookID: "r2", sectionID: nil)) == .navigate)
            #expect(router.pendingBookChapter == nil, "a whole-book show parks no chapter")
        }
    }

    @Test func takesAndLensTargetsRideHerOwnLandingsOnTheMountedNote() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let router = ShellRouter()
            door.standingProvider = { (.frontmostMainWindow, router) }
            var applied: [PostMode] = []
            let token = session.commandRouter.registerDetail(postID: "n1", mode: .write) { applied.append($0) }
            defer { session.commandRouter.unregisterDetail(token) }

            #expect(await door.agentShow(.takes(noteID: "n1", blockID: "b1")) == .navigate)
            #expect(session.commandRouter.pendingTakesLanding == .bloom(postID: "n1", blockID: "b1"))
            #expect(applied == [.takes], "her see-takes door: the landing, then the mode")
            session.commandRouter.pendingTakesLanding = nil

            #expect(await door.agentShow(.lens(noteID: "n1", lensID: "L1")) == .navigate)
            #expect(session.commandRouter.pendingLensLanding == LensLanding(postID: "n1", lensID: "L1"))
            #expect(applied == [.takes, .lenses])
        }
    }

    // MARK: - The lens board's column rule (PROVISIONAL R83 swap)

    @Test func showLensFocusesAppendsThenSwapsTheLastColumn() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let defaults = try #require(UserDefaults(suiteName: "mcp-nav-\(UUID().uuidString)"))
            let model = TakesViewModel(session: session, postID: "lens-note", defaults: defaults)
            let start = model.columns.count
            #expect(start == 1)
            #expect(model.showLens("L1") == .added)
            #expect(model.showLens("L1") == .alreadyShown, "a lens already shown is not shown twice")
            #expect(model.showLens("L2") == .added)
            #expect(model.showLens("L3") == .added)
            #expect(model.columns.count == 4)
            let lastID = try #require(model.columns.last?.id)
            #expect(model.showLens("L4") == .replacedLast)
            #expect(model.columns.count == 4 && model.columns.last?.id == lastID
                    && model.columns.last?.kind == .lens("L4"), "R83: the last column swapped in place")
        }
    }

    // MARK: - The offer door and the keyboard road (AF-11 F-2)

    @Test func aWriteReceiptStaysAReceiptAndCarriesOpenAndTheChordOutlivesTheLine() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(!session.commandRouter.isEnabled(.showLastAIChange), "grey before any AI change")

            let target = MCPShowTarget.takes(noteID: "n1", blockID: "b1")
            door.speak(MCPWriteReceipt(
                clientName: "claude-code", act: .take, targetID: "n1", targetTitle: "ch 1", show: target))
            let line = try #require(session.status.quietLine, "a RECEIPT — her quiet default governs it")
            #expect(line.kind == .receipt && line.action?.label == "Open \u{203A}")
            #expect(session.status.current == nil, "never promoted to the toast (not an offer)")
            #expect(door.lastShow == target)
            #expect(session.commandRouter.isEnabled(.showLastAIChange))

            // Under receipt style OFF the line is dropped — the keyboard road
            // still stands (the ruled "alive under off").
            session.status.clear()
            session.status.receiptStyle = .off
            let next = MCPShowTarget.lens(noteID: "n1", lensID: "L1")
            door.speak(MCPWriteReceipt(
                clientName: "claude-code", act: .lens, targetID: "n1", targetTitle: "ch 1", detail: "x", show: next))
            #expect(session.status.spoken == nil)
            #expect(door.lastShow == next && session.commandRouter.isEnabled(.showLastAIChange))

            door.detach()
            #expect(door.lastShow == nil, "session-scoped: a closed library's last change goes with it")
        }
    }

    @Test func theKeyboardRoadIsDeclaredWithItsChord() {
        let capability = CapabilityRegistry.capability(.showLastAIChange)
        #expect(capability.doors == [.menuBar] && capability.shortcutLabel == "⌥⌘O")
        #expect(EditorCommands.menuRendered.contains(.showLastAIChange))
        let key = EditorCommands.keyEquivalent(for: .showLastAIChange)
        #expect(key?.0 == "o" && key?.1 == [.command, .option])
        #expect(capability.verb == "Show the AI\u{2019}s Last Change")
    }

    // MARK: - The found-defect refusal words (AF-11 F-1's approved J8 fix + its twin)

    /// RED ON OLD: both fell to the table's fallback and spoke the raw enum
    /// with a UUID in it — on the wire (`create_section` / `file_note_in_chapter`
    /// on a finished book; a raced `put_back`) and at every Mac door routed
    /// through the table.
    @Test func aFinishedBooksAndAnAlreadyBackBlocksRefusalsSpeakTheAppsWords() {
        #expect(OpsRefusalCopy.message(for: OperationError.lockedReading(id: "r"))
                == "This book is finished \u{2014} reopen it first; if it\u{2019}s sealed, unseal it.")
        #expect(OpsRefusalCopy.message(for: OperationError.blockNotDeleted(id: "b"))
                == "That block is already back.")
    }
}
