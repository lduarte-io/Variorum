//
//  MCPGrantRoadsTests.swift
//  VariorumTests (Mac)
//
//  THE VX-548 RUN, BATCH 1 — the grant road and Settings ▸ MCP (the record
//  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 1 RECORD):
//  - VX-516: EVERY road that opens THE grant sheet — the Clients row's door,
//    Shared with AI's add door, a row's Change…, a receipt's Change…, a shared
//    icon's Change… — built by its OWN door's builder, confirmed on ANOTHER
//    wing, leaves the wing it was opened on standing (her brief's warning:
//    prove each road by test, never by reading its opening). The headless
//    pin is `MCPGrantChangeTests` (red on the pre-fix decision); these drive
//    the app's own roads through the sheet's one act (`MCPGrantSheet.act`).
//  - VX-515: the Clients row's door ADDS and says so ("Share a place…");
//    Shared with AI's own "Share another place…" — declared once, drawn only
//    where it can act.
//  - VX-512: a library with no client says its clients are its own.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 548))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Wait (bounded) for a condition an async act or observation settles.
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
    for _ in 0..<300 {
        if condition() { return true }
        try await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

/// The client's LIVE grants on one place.
private func live(
    _ db: AppDatabase, _ client: String, _ kind: MCPGrantRule.ScopeKind, _ id: String
) throws -> [MCPGrantRow] {
    try db.read { try Queries.mcpGrants($0, clientID: client) }
        .filter { $0.ruleGrant.isLive && $0.scopeKind == kind && $0.scopeID == id }
}

@MainActor
@Suite("VX-516 · VX-515 · VX-512 — the grant road and Settings ▸ MCP (the VX-548 run, batch 1)", .serialized)
struct MCPGrantRoadsTests {
    private func approved(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return MCPClient(
            id: client.id, name: client.name, version: client.version, state: .approved,
            firstSeenAt: client.firstSeenAt, lastSeenAt: client.lastSeenAt, decidedAt: nil)
    }

    private func wing(_ id: String, _ rung: MCPGrantRule.Rung = .read) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: .wing, scopeID: id, duration: .always)
    }

    // MARK: - VX-516: every road, confirmed on another wing (RED ON OLD: the sheet passed `replacing` through)

    @Test func everyRoadConfirmedOnAnotherWingLeavesBothWingsStanding() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let planet = try ops.createWing(name: "PlanetLillian")
            let first = try ops.grantMCPAccess(client.id, wing(planet.id, .edit))
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { door.snapshot.sharedGroups.count == 1 })
            let row = try #require(door.snapshot.sharedGroups.first?.lead)
            let roads: [(String, MCPGrantOpening)] = [
                ("the Clients row's Share a place…", MCPGrantOpening.clientRow(client)),
                ("Shared with AI's Share another place…", MCPGrantOpening.shareAnotherPlace()),
                ("a Shared-with-AI row's Change…", try #require(await door.changeOpening(row))),
                ("a receipt's Change…", MCPDoor.receiptChangeOpening(
                    client: client, prefill: .wing(planet.id), rung: .edit, duration: .always, grantIDs: [first])),
                ("a shared icon's Change…", MCPReachPopover.changeOpening(client, row.grant)),
            ]
            for (index, (name, opening)) in roads.enumerated() {
                let other = try ops.createWing(name: "studio \(index)")
                let spec = wing(other.id)
                let act = try #require(MCPGrantSheet.act(
                    opening: opening, place: .wing, spec: spec, noteIDs: [], rung: .read, duration: .always))
                #expect(act == .grant(spec, replacing: []), "\(name): another place confirmed is a NEW grant")
                // Performed exactly as `submit` performs it.
                guard case .grant(let granted, let replacing) = act else { continue }
                let saying = opening.origin == .place ? MCPShareCopy.wingPlace(other.name) : nil
                if saying == nil, replacing.isEmpty {
                    door.grant(client.id, granted)
                } else {
                    door.grant(client, granted, replacing: replacing, saying: saying, change: nil)
                }
                #expect(try await settle { ((try? live(db, client.id, .wing, other.id)) ?? []).count == 1 },
                        "\(name): the new wing lands")
                #expect(try live(db, client.id, .wing, planet.id).map(\.id) == [first], "\(name): PlanetLillian stands")
            }
            #expect(try await settle { door.snapshot.sharedCount == 1 + roads.count }, "Shared with AI lists every wing")
        }
    }

    /// T-U3-8's replace, kept where it was ruled — the place the sheet was
    /// opened on: a row's Change… lowered on its own wing replaces it, and
    /// the sheet NAMES what it replaces before she confirms. Another place
    /// picked — or none yet — and the replace (and its line) go.
    @Test func changeOnItsOwnPlaceStillReplacesAndNamesWhatItReplaces() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = session.operations
            let client = try approved(ops)
            let planet = try ops.createWing(name: "PlanetLillian")
            let first = try ops.grantMCPAccess(client.id, wing(planet.id, .edit))
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { door.snapshot.sharedGroups.count == 1 })
            let lead = try #require(door.snapshot.sharedGroups.first?.lead)
            let opening = try #require(await door.changeOpening(lead))
            @MainActor
            func places(_ place: MCPGrantSheet.Place, book: String? = nil, wing: String = "") -> Set<MCPGrantChange.Place> {
                MCPGrantSheet.confirmedPlaces(place: place, noteID: nil, noteIDs: [], bookID: book, wingID: wing)
            }
            #expect(MCPGrantSheet.replacing(opening, confirmed: places(.wing, wing: planet.id)) == [first])
            #expect(MCPGrantSheet.replacing(opening, confirmed: places(.wing, wing: "")).isEmpty, "Home is another place")
            #expect(MCPGrantSheet.replacing(opening, confirmed: places(.book, book: "b")).isEmpty)
            #expect(MCPGrantSheet.replacing(opening, confirmed: places(.book)).isEmpty, "nothing picked yet")

            let lowered = wing(planet.id, .read)
            let act = MCPGrantSheet.act(
                opening: opening, place: .wing, spec: lowered, noteIDs: [], rung: .read, duration: .always)
            #expect(act == .grant(lowered, replacing: [first]))
            door.grant(client, lowered, replacing: [first], saying: nil, change: nil)
            #expect(try await settle {
                ((try? live(db, client.id, .wing, planet.id)) ?? []).map(\.rung) == [.read]
            }, "the lowered rung lands, one row")

            #expect(MCPPaneCopy.replacesLine(
                client: "claude-code", place: MCPShareCopy.wingPlace("PlanetLillian"), rung: .edit, duration: .always)
                == "Confirming replaces claude-code\u{2019}s grant on the PlanetLillian wing \u{2014} read, suggest, "
                    + "write new and edit, always.", "whose grant, which place, how far and how long")
            #expect(MCPPaneCopy.replacesLine == "Confirming replaces the grant you opened this from.",
                    "the plain sentence stays for a place with no name to hand")
        }
    }

    /// An act's Change… (WHERE said, never re-chosen) keeps its replace over
    /// the notes that stand; the approval road is untouched; an incomplete
    /// pick acts not at all.
    @Test func anActsChangeKeepsItsReplaceAndTheApprovalRoadIsUntouched() {
        let client = MCPClient(
            id: "c", name: "claude-code", version: nil, state: .approved, firstSeenAt: "", lastSeenAt: "",
            decidedAt: nil)
        let members = ["n1", "n2", "n3"].map { note in
            MCPSharedRow(
                grant: MCPGrantRow(
                    id: "g-\(note)", clientID: "c", rung: .read, scopeKind: .note, scopeID: note,
                    duration: .always, createdAt: "t", consumedAt: nil, revokedAt: nil),
                clientName: "claude-code", targetTitle: note)
        }
        let actOpening = MCPDoor.changeOpening(act: client, members: members)
        // n3 is gone since: the sheet's notes are the two that stand.
        #expect(MCPGrantSheet.act(
            opening: actOpening, place: .notes, spec: nil, noteIDs: ["n1", "n2"], rung: .suggest, duration: .always)
            == .grantNotes(["n1", "n2"], rung: .suggest, duration: .always, replacing: ["g-n1", "g-n2", "g-n3"]))
        #expect(MCPGrantSheet.act(
            opening: actOpening, place: .notes, spec: nil, noteIDs: [], rung: .suggest, duration: .always) == nil)

        let approval = MCPGrantOpening(client: client, approving: true)
        #expect(MCPGrantSheet.act(
            opening: approval, place: .nothing, spec: nil, noteIDs: [], rung: .read, duration: .once) == .approve(nil))
        let riding = wing("w")
        #expect(MCPGrantSheet.act(
            opening: approval, place: .wing, spec: riding, noteIDs: [], rung: .read, duration: .always)
            == .approve(riding))
        #expect(MCPGrantSheet.act(
            opening: .shareAnotherPlace(), place: .book, spec: nil, noteIDs: [], rung: .read, duration: .always) == nil,
                "no book picked: no act")
    }

    // MARK: - VX-515: the doors that ADD

    @Test func theClientRowsDoorAddsAndIsNamedForIt() {
        let row = CapabilityRegistry.capability(.mcpChangeClientAccess)
        #expect(row.verb == "Share a place\u{2026}", "it adds a grant — it read “Change…”, the replace verb")
        #expect(row.doors == [.surface])
        let approvedClient = MCPClient(
            id: "c", name: "claude-code", version: nil, state: .approved, firstSeenAt: "", lastSeenAt: "",
            decidedAt: nil)
        let opening = MCPGrantOpening.clientRow(approvedClient)
        #expect(opening.client?.id == "c" && !opening.approving)
        #expect(opening.place == nil && opening.rung == nil && opening.duration == nil && opening.replacing.isEmpty,
                "the client picked, nothing else pre-filled, nothing replaced")
        let denied = MCPClient(
            id: "d", name: "codex", version: nil, state: .denied, firstSeenAt: "", lastSeenAt: "", decidedAt: nil)
        #expect(MCPGrantOpening.clientRow(denied).approving, "a denied client's row is Approve…")
        // Every sentence naming the door says its name.
        #expect(MCPPaneCopy.approvalLead.contains(row.verb) && !MCPPaneCopy.approvalLead.contains("Change\u{2026}"))
        let blurb = SettingsCatalog.rows.first { $0.id == "mcpClients" }?.blurb ?? ""
        #expect(blurb.contains(row.verb) && !blurb.contains("Change\u{2026}"))
    }

    @Test func sharedWithAIsAddDoorIsDeclaredOnceAndDrawnOnlyWhereItCanAct() {
        let door = CapabilityRegistry.capability(.mcpShareAnotherPlace)
        #expect(door.verb == "Share another place\u{2026}" && door.doors == [.surface])
        #expect(MCPPane.surfaceCapabilities.contains(.mcpShareAnotherPlace), "the pane renders it")
        var snapshot = MCPDoor.Snapshot()
        #expect(!MCPPane.offersShareAnotherPlace(snapshot), "no approved client: no door (VX-272)")
        snapshot.approvedCount = 1
        #expect(!MCPPane.offersShareAnotherPlace(snapshot), "nothing listed yet: “another” would not be true")
        snapshot.sharedCount = 1
        #expect(MCPPane.offersShareAnotherPlace(snapshot))
        snapshot.approvedCount = 0
        #expect(!MCPPane.offersShareAnotherPlace(snapshot), "grants left but no approved client: no one to grant")
        let opening = MCPGrantOpening.shareAnotherPlace()
        #expect(opening.client == nil && !opening.approving && opening.place == nil && opening.replacing.isEmpty,
                "WHO asked, nothing pre-filled, nothing replaced")
        #expect(opening.origin == .pane, "its sheet speaks in the pane's caption")
    }

    // MARK: - VX-512: a library's clients are its own

    @Test func aLibraryWithNoClientSaysItsClientsAreItsOwn() async throws {
        try await withSession { (session: AppSession, _: AppDatabase) async throws in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            #expect(try await settle { MCPPane.saysClientsBelongToTheLibrary(door.snapshot) },
                    "a fresh library: no client at all")
            _ = try session.operations.recordMCPContact(name: "claude-code", version: "2")
            #expect(try await settle { !MCPPane.saysClientsBelongToTheLibrary(door.snapshot) },
                    "a connection request waits: the line goes")
        }
        var snapshot = MCPDoor.Snapshot()
        snapshot.clientCount = 1
        #expect(!MCPPane.saysClientsBelongToTheLibrary(snapshot), "an approved or denied client: no line")
        // The words: one line with the whole text behind its (i).
        let line = MCPPaneCopy.libraryClientsSummary, whole = MCPPaneCopy.libraryClientsDetail
        #expect(ExplainerLine.opens(line: line, detail: whole))
        let width = NSHostingController(rootView: Text(line).font(.caption).lineLimit(1).fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 200)).width
        #expect(width <= 420, "one line at the pane's room (MCPPaneTabsTests.paneLineRoom): \(width) pt")
        #expect(line.range(of: #"\bAI\b"#, options: .regularExpression) == nil, "VX-272")
        #expect(line.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil, "no shouted word")
        #expect(whole.contains("never synced") && whole.contains("run each client\u{2019}s setup again"),
                "the whole truth: local-only, and the road back")
    }
}
