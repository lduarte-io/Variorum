//
//  MCPPlaceTwiceFacesTests.swift
//  VariorumTests (Mac)
//
//  VX-565 — THE PROBE'S FACE HALF (the VX-620 run, batch 3; the record
//  `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 3 RECORD). Her
//  report: "PlanetLillian (and "o ladrão de raios") show twice in the pane with
//  different rungs." The headless half (`MCPPlaceTwiceProbeTests`) finds her shape
//  gone since VX-393 and proves every other way one place lists twice is an honest
//  second row. This half reads the WORDS each such pair of Shared with AI rows
//  wears — exactly what `MCPSharedRowView` draws: the place's title, its kind chip,
//  its distinguisher (`MCPPane.distinguisher`, from the door's ladder) and the detail
//  line `MCPPaneCopy.sharedDetail` (client · rung · duration) — and finds the
//  difference SAID in each: no two rows of one place read the same.
//  Green by design (a probe; no fix was owed). Pure reads — no window, no pane.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withGrants<T>(_ body: @MainActor (Operations, AppDatabase) throws -> T) throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 565))
    } operation: { @MainActor in
        try body(Operations(), db)
    }
}

/// One Shared with AI row, as `MCPSharedRowView` draws it: title · kind chip ·
/// distinguisher (when its name collides), then the detail line.
@MainActor
private func drawn(
    _ row: MCPSharedRow, _ labels: (books: [String: String], wings: [String: String])
) -> String {
    let head = [row.targetTitle ?? MCPPaneCopy.missingTarget, MCPPaneCopy.kindChip(row.grant.scopeKind),
                MCPPane.distinguisher(row, labels)].compactMap { $0 }
    return head.joined(separator: " ") + " / "
        + MCPPaneCopy.sharedDetail(client: row.clientName, rung: row.grant.rung, duration: row.grant.duration)
}

@MainActor
@Suite("VX-565 — one place shown twice: each row says what differs")
struct MCPPlaceTwiceFacesTests {
    private func approved(_ ops: Operations, _ name: String) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "1.0")
        _ = try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func spec(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// The door's distinguisher ladder, read as `MCPDoor.placeDistinguishers` reads it.
    private func labels(_ db: AppDatabase) throws -> (books: [String: String], wings: [String: String]) {
        let places = try db.read { try Queries.mcpGrantPlaces($0) }
        let now = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)
        return (places.bookDistinguishers(now: now).merging(places.gatheringDistinguishers(now: now)) { b, _ in b },
                places.wingDistinguishers(now: now))
    }

    /// The rows of Shared with AI that name one place's TITLE, drawn.
    private func drawnRows(_ db: AppDatabase, titled title: String) throws -> [String] {
        let labels = try labels(db)
        return try db.read { try Queries.mcpSharedGroups($0) }
            .filter { !$0.isGroup && $0.lead.targetTitle == title }
            .map { drawn($0.lead, labels) }
    }

    @Test func twoClientsOnOnePlaceReadAsTheirOwnClients() throws {
        try withGrants { ops, db in
            let claude = try approved(ops, "claude-code")
            let codex = try approved(ops, "codex")
            let wing = try ops.createWing(name: "PlanetLillian")
            _ = try ops.grantMCPAccess(claude.id, spec(.edit, .wing, wing.id))
            _ = try ops.grantMCPAccess(codex.id, spec(.read, .wing, wing.id))
            let rows = try drawnRows(db, titled: "PlanetLillian")
            #expect(rows.count == 2 && Set(rows).count == 2, "two rows, each its own words: \(rows)")
            #expect(rows.contains { $0.contains("claude-code \u{00B7} ") } && rows.contains { $0.contains("codex \u{00B7} ") },
                    "each names its client: \(rows)")
        }
    }

    @Test func aOnceBesideAStandingGrantReadsItsDuration() throws {
        try withGrants { ops, db in
            let client = try approved(ops, "claude-code")
            let wing = try ops.createWing(name: "PlanetLillian")
            _ = try ops.grantMCPAccess(client.id, spec(.read, .wing, wing.id))
            _ = try ops.grantMCPAccess(client.id, spec(.writeNew, .wing, wing.id, .once))
            let rows = try drawnRows(db, titled: "PlanetLillian")
            #expect(rows.count == 2 && Set(rows).count == 2, "\(rows)")
            #expect(rows.contains { $0.hasSuffix("\u{00B7} \(MCPPaneCopy.durationWord(.once))") }
                        && rows.contains { $0.hasSuffix("\u{00B7} \(MCPPaneCopy.durationWord(.always))") },
                    "the once row says once, the standing row always: \(rows)")
        }
    }

    @Test func twoPlacesSharingANameReadWithTheirDistinguishers() throws {
        try withGrants { ops, db in
            let client = try approved(ops, "claude-code")
            let first = try ops.createWing(name: "PlanetLillian")
            let second = try ops.createWing(name: "PlanetLillian")
            let bookA = try ops.createReading(name: "o ladrão de raios", kind: .book, wingId: first.id)
            let bookB = try ops.createReading(name: "o ladrão de raios", kind: .book, wingId: first.id)
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .wing, first.id))
            _ = try ops.grantMCPAccess(client.id, spec(.read, .wing, second.id))
            _ = try ops.grantMCPAccess(client.id, spec(.suggest, .book, bookA.id))
            _ = try ops.grantMCPAccess(client.id, spec(.read, .book, bookB.id))
            for title in ["PlanetLillian", "o ladrão de raios"] {
                let rows = try drawnRows(db, titled: title)
                #expect(rows.count == 2 && Set(rows).count == 2, "\(title): \(rows)")
                // Even at ONE rung the twins would read apart — the distinguisher
                // is in the head, before the detail line.
                let heads = rows.map { $0.components(separatedBy: " / ")[0] }
                #expect(Set(heads).count == 2, "\(title): each twin's head says which it is: \(heads)")
            }
        }
    }
}
