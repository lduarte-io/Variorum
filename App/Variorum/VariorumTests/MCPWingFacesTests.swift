//
//  MCPWingFacesTests.swift
//  VariorumTests (Mac)
//
//  13n-c U6 — THE WING ON THE WIRE, the app's faces: a client's wing move
//  said as her own door says it (and her sweep as ONE line — the brief §10,
//  mockup §9), `show_in_app`'s wing target delivered as her switcher's own
//  act with the receipt naming who moved her (VX-158 — mockup §7), the move's
//  refusals in her words (her door's frozen sentence through the server's
//  hook; the divergence refusal on the undo door), the activity lines. Plus
//  the found defect D-U6-1 (red-on-old): a single act too long for the bar
//  said "made 1 changes".
//

import Dependencies
import Foundation
import GRDB
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 61))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func move(
    _ title: String?, to wingID: String, named wing: String, left: Int, client: String = "claude-code"
) -> MCPWriteReceipt {
    MCPWriteReceipt(
        clientName: client, act: .wingMove, targetID: wingID, targetTitle: wing, detail: title,
        show: .note(noteID: "n1", blockID: nil, select: nil), leftBooks: left)
}

@MainActor
@Suite("13n-c U6 — the wing on the wire: the app's faces", .serialized)
struct MCPWingFacesTests {
    // MARK: - The move's receipt (her door's words; her sweep, one line)

    @Test func aWingMoveSpeaksAsHerDoorDoesAndASweepIsOneLine() {
        #expect(MCPReceiptCopy.line([move("ch 7", to: "w1", named: "variorum", left: 0)])
                == "claude-code moved \u{201C}ch 7\u{201D} to \u{201C}variorum\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(MCPReceiptCopy.line([move("ch 7", to: "w1", named: "variorum", left: 1)])
                == "claude-code moved \u{201C}ch 7\u{201D} to \u{201C}variorum\u{201D} \u{2014} it left 1 book "
                    + "\u{00B7} \u{2325}\u{2318}Z undoes")
        #expect(MCPReceiptCopy.line([move("ch 7", to: "", named: "Home", left: 2)])
                == "claude-code moved \u{201C}ch 7\u{201D} to Home \u{2014} it left 2 books \u{00B7} \u{2325}\u{2318}Z undoes",
                "Home is a place-name, never quoted")
        // The mockup §9's own line overflows the bar's budget: the note's
        // title goes first (Open › opens it), never where it went or the books.
        #expect(MCPReceiptCopy.line([move("parser notes", to: "w1", named: "variorum", left: 2)])
                == "claude-code moved a note to \u{201C}variorum\u{201D} \u{2014} it left 2 books \u{00B7} "
                    + "\u{2325}\u{2318}Z undoes")
        let sweep = (1...14).map { move("note \($0)", to: "w1", named: "variorum", left: 1) }
        #expect(MCPReceiptCopy.line(sweep)
                == "claude-code moved 14 notes to \u{201C}variorum\u{201D} \u{00B7} \u{2325}\u{2318}Z undoes",
                "her sweep reads as one line")
        #expect(Operations.MCPWriteAct.wingMove.undoLabel(client: "claude-code") == "claude-code's wing move",
                "the Edit menu's “Undo claude-code's wing move”")
    }

    /// D-U6-1 (bug-class, found tracing the wing move's line): a single act
    /// whose line overflows the bar fell to "made 1 changes".
    @Test func aSingleActTooLongForTheBarSaysAChangeNeverOneChanges() {
        let long = MCPWriteReceipt(
            clientName: "claude-code", act: .note, targetID: "n1",
            targetTitle: String(repeating: "a very long title ", count: 4))
        #expect(MCPReceiptCopy.line([long]) == "claude-code made a change \u{00B7} \u{2325}\u{2318}Z undoes")
        let tagged = MCPWriteReceipt(
            clientName: "claude-code", act: .tag, targetID: "n1", targetTitle: "x",
            detail: String(repeating: "t", count: 60))
        #expect(MCPReceiptCopy.line([long, tagged]) == "claude-code made 2 changes \u{00B7} \u{2325}\u{2318}Z undoes")
    }

    // MARK: - show_in_app → a wing (her switcher's own act)

    @Test func showInAppToAWingSwitchesItAsHerSwitcherDoesAndSaysWho() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let router = ShellRouter()
            let resting = router.workspace.focusedSelection
            door.standingProvider = { (.notFrontmost, router) }
            let target = MCPShowTarget.wing(wingID: "w1", name: "variorum", shownBy: "claude-code")
            #expect(await door.agentShow(target) == .refuse(MCPShowRule.notFrontmostWords))
            #expect(session.wing.currentID == "" && session.status.quietLine == nil, "behind: nothing moved, nothing said")

            door.standingProvider = { (.frontmostMainWindow, router) }
            #expect(await door.agentShow(target) == .navigate)
            #expect(session.wing.currentID == "w1")
            let line = try #require(session.status.quietLine)
            #expect(line.text == "Now in \u{201C}variorum\u{201D} \u{2014} claude-code showed you this wing.")
            #expect(line.kind == .receipt, "a receipt — her receipt style governs it")
            #expect(router.workspace.focusedSelection == resting, "no pane moved: a wing scopes listings")

            session.status.clear()
            #expect(await door.agentShow(target) == .navigate)
            #expect(session.status.quietLine == nil, "already there: nothing moves, nothing is said")

            #expect(await door.agentShow(.wing(wingID: "", name: "Home", shownBy: "codex")) == .navigate)
            #expect(session.wing.currentID == "")
            #expect(session.status.quietLine?.text == "Now in Home \u{2014} codex showed you this wing.")
        }
    }

    // MARK: - Her words on the move's refusals; the activity lines

    @Test func theMovesRefusalsSpeakHerWords() {
        #expect(MCPDoor.wingMoveFrozenWords("parser notes", "launch notes")
                == WingCopy.frozen("parser notes", book: "launch notes"),
                "the wire's frozen refusal IS her Move to Wing door's sentence — one source")
        let changed = OpsRefusalCopy.message(for: OperationError.wingMoveChangedSince(postID: "n-1"))
        #expect(changed.contains(WingCopy.moveToWingVerb), "the way through is named")
        #expect(!changed.contains("wingMoveChangedSince") && !changed.contains("n-1"), "never the raw enum")
        #expect(StructuralUndoCopy.undoFailed(changed).hasPrefix("Undo failed: That note joined a book"))
    }

    @Test func theActivitySaysTheMoveAndTheShow() {
        func line(_ act: String, kind: String, title: String) -> String {
            MCPPaneCopy.activityLine(MCPActivityFace.Line(
                id: 1, clientName: "claude-code", act: act, targetKind: kind, targetID: "x", targetTitle: title,
                allowed: true, count: 1, at: "2026-10-11T00:00:00.000Z"))
        }
        #expect(line("move_note_to_wing", kind: "note", title: "ch 7")
                == "claude-code moved \u{201C}ch 7\u{201D} to another wing")
        #expect(line("show_in_app", kind: "wing", title: "variorum")
                == "claude-code showed you \u{201C}variorum\u{201D}")
    }

    // MARK: - The live round's staging (DEBUG-only, env-gated — `ScaleFixture`'s wing part)

    @Test func theScaleSeedsWingPartMintsTheLiveRoundsWorldOnce() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            try ops.approveMCPClient(client.id, granting: nil)
            let request = ScaleFixture.Request(notes: 3, longBlocks: 1, wing: 1)
            #expect(ScaleFixture.Request.parse("notes=30,long=1,books=20,shelves=3,wing=1")
                    == ScaleFixture.Request(notes: 30, longBlocks: 1, books: 20, shelves: 3, wing: 1))
            #expect(try await ScaleFixture.seed(session: session, request: request))
            let (wing, gathering) = try await db.read { db in
                (try Wing.fetchOne(db, sql: "SELECT * FROM wing WHERE name = ?", arguments: [ScaleFixture.wingName]),
                 try Reading.fetchOne(db, sql: "SELECT * FROM reading WHERE name = ?",
                                      arguments: [ScaleFixture.gatheringName]))
            }
            let wingID = try #require(wing?.id)
            #expect(gathering?.kind == .gathering && gathering?.wingId == wingID)
            let members = try await db.read { try Queries.assembleReading($0, readingID: gathering!.id) }
            #expect(members.count == 3, "three #parser notes gathered")
            let fenced = try await db.read { db in
                try Queries.mcpNoteFacts(db, noteIDs: members.map(\.postID)).values.filter { $0.fence != nil }.count
            }
            #expect(fenced == 1, "one of them Private — the member a wing grant must never list")
            let grants = try await db.read { try Queries.mcpGrants($0, clientID: client.id) }
            #expect(grants.map { "\($0.rung.rawValue)·\($0.scopeKind.rawValue)·\($0.scopeID)" }.sorted()
                    == ["edit·wing·", "write_new·wing·\(wingID)"], "her sweep's two grants (staging)")
            #expect(try await ScaleFixture.seed(session: session, request: request) == false, "a relaunch mints nothing")
        }
    }
}
