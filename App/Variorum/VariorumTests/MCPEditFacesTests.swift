//
//  MCPEditFacesTests.swift
//  VariorumTests (Mac)
//
//  13n-b U3 — the app half of the edit rung: the ACTIVITY face (the coarse
//  log, coalesced and capped with its "all N ›" road — R-13n-10), "Allow AI
//  here" (R-13n-11's connected push gesture; AF-10 (e)) and their registry
//  declarations (P-1).
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func row(
    _ id: Int64, _ act: String, target: String? = "n1", title: String? = "ch 7", allowed: Bool = true,
    client: String = "claude-code", kind: String? = "note"
) -> MCPActivityRow {
    MCPActivityRow(
        id: id, clientName: client, act: act, targetKind: kind, targetID: target, targetTitle: title,
        allowed: allowed, at: "2026-10-10T12:00:0\(id % 10).000Z")
}

@MainActor
@Suite("13n-b U3 — the activity face and Allow AI here", .serialized)
struct MCPEditFacesTests {
    // MARK: - The activity face (R-13n-10)

    @Test func theActivityFaceCoalescesARunAndSaysWhoDidWhatWhere() {
        // Newest first, as the log reads. (U3 ladder round 1, F4 — justified
        // edit: a coalesced CREATION run spans different creations, whose log
        // rows share the PLACE as target but carry each creation's own title,
        // so the plural line speaks the count plainly, never one title.)
        let lines = MCPActivityFace.lines([
            row(12, "create_note", target: "b1", title: "note b", kind: "book"),
            row(11, "create_note", target: "b1", title: "note a", kind: "book"),
            row(10, "create_section", target: "b1", title: "drafts", kind: "book"),
            row(9, "add_take"), row(8, "add_take"), row(7, "add_take"),
            row(6, "read_note"),
            row(5, "add_take", target: "n2", title: "ch 8", allowed: false),
            row(4, "edit_take"), row(3, "list_notes", target: nil, title: nil, kind: nil),
        ])
        #expect(lines.map(\.count) == [2, 1, 3, 1, 1, 1, 1],
                "a run of one client's same act on one target is one line")
        #expect(lines.first?.id == 12, "the line keeps its newest row's id and stamp")
        #expect(lines.map(MCPPaneCopy.activityLine) == [
            "claude-code made 2 notes",
            "claude-code added a chapter to \u{201C}drafts\u{201D}",
            "claude-code added 3 takes to \u{201C}ch 7\u{201D}",
            "claude-code read \u{201C}ch 7\u{201D}",
            "claude-code was refused add_take on \u{201C}ch 8\u{201D}",
            "claude-code edited \u{201C}ch 7\u{201D}",
            "claude-code listed its shared notes",
        ])
    }

    @Test func theSnapshotCarriesTheNewestActivityLinesAndTheRoadReachesTheWholeLog() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            try await db.write { db in
                for index in 0..<12 {
                    try operations.recordMCPActivity(
                        db, clientName: "claude-code", act: index.isMultiple(of: 2) ? "read_note" : "add_take",
                        targetKind: "note", targetID: "n\(index)", targetTitle: "ch \(index)", allowed: true)
                }
            }
            let snapshot = try await db.read { try MCPDoor.read($0) }
            #expect(snapshot.activity.count == MCPDoor.activityCap && snapshot.activityCount == 12)
            #expect(snapshot.activity.first?.targetTitle == "ch 11", "newest first")
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(await door.allActivity().count == 12, "the all-N road reaches every row")
        }
    }

    // MARK: - Allow AI here (R-13n-11; AF-10 (e))

    @Test func allowHereOffersApprovedClientsNotAlreadyReachingAndGrantsReadOnce() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let operations = Operations()
            let book = try operations.createReading(name: "shared", kind: .book)
            let note = try operations.createPost(title: "ch 1")
            _ = try operations.addPostToReading(note.id, to: book.id)
            let reaching = try operations.recordMCPContact(name: "claude-code", version: nil)
            _ = try operations.approveMCPClient(
                reaching.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            let other = try operations.recordMCPContact(name: "desktop", version: nil)
            _ = try operations.approveMCPClient(other.id, granting: nil)
            _ = try operations.recordMCPContact(name: "a stranger", version: nil)  // pending — never offered

            let state = try await db.read { try NotePrivacyState.read($0, postID: note.id) }
            #expect(state.allowable == ["desktop"], "approved, and not already reaching this note")
            await NoteAllowAct.allow("desktop", postID: note.id, session: session)
            #expect(session.status.spoken?.text == PrivateMarkCopy.allowedOnce("desktop"))
            let grants = try await db.read { try Queries.mcpGrants($0, clientID: other.id) }
            #expect(grants.map { [$0.rung.rawValue, $0.scopeKind.rawValue, $0.scopeID, $0.duration.rawValue] }
                    == [["read", "note", note.id, "once"]], "THAT note, read, once (R-13n-11)")
            let after = try await db.read { try NotePrivacyState.read($0, postID: note.id) }
            #expect(after.allowable.isEmpty, "nothing left to offer — the row goes (P-2)")

            // A journal entry: once is per-ask-legal, so it is offered too.
            let entry = try operations.createPost(title: "morning pages", profile: .journal)
            #expect(try await db.read { try NotePrivacyState.read($0, postID: entry.id) }.allowable.sorted()
                    == ["claude-code", "desktop"])
            await NoteAllowAct.allow("claude-code", postID: entry.id, session: session)
            #expect(try await db.read { try Queries.mcpGrants($0, clientID: reaching.id) }
                .contains { $0.scopeID == entry.id && $0.duration == .once })
        }
    }

    @Test func theEditFacesAreDeclaredWhereTheyRenderInTheAppsWords() {
        #expect(CapabilityRegistry.capability(.mcpAllowHere).verb == "Allow AI here")
        #expect(CapabilityRegistry.capability(.mcpAllowHere).doors == [.bottomBar])
        #expect(CommitBar.renderedCapabilities.contains(.mcpAllowHere))
        #expect(TakesBottomBar.renderedCapabilities.contains(.mcpAllowHere))
        #expect(MCPPaneCopy.offeredRungs.last == .edit, "the sheet offers the rung the server now serves")
    }
}
