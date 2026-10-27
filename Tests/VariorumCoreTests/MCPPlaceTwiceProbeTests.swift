import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-565 — THE PROBE (the VX-620 run, batch 3 — the record
// `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 3 RECORD). Her
// report (an agent's feedback, relayed 2026-10-26, before VX-548 merged):
// "PlanetLillian (and "o ladrão de raios") show twice in the pane with different
// rungs." Her kickoff: "VX-548 rebuilt that listing, re-probe on main."
//
// THE FINDING: that shape is VX-393's own report, word for word (the VX-348 record
// §U5: "PlanetLillian (wing) twice for claude-code — `read · always` AND `read,
// suggest, write new and edit · always` — and "o ladrão de raios" (book) twice"):
// a second grant on a place ADDED a row on every road but Change…. VX-393 fixed it
// at 0.9.8 (2026-10-18): the one mint replaces the place's standing row, v1_30
// merged the duplicates a store held, and `uq_mcp_grant_standing_place` refuses a
// second. These pins reconstruct her exact shape on TODAY's merged tree (VX-516's
// Change… rule and VX-515's "Share a place…" / "Share another place…" included) and
// find it gone; and they prove that every OTHER way one place can show twice is an
// honest second row whose listing says what differs — another client, a once grant
// beside a standing one (P-VX393-3), or a second place wearing the same name. The
// faces' words for those rows are the Mac pin `MCPPlaceTwiceFacesTests`.
//
// Green on this tree by design (a probe, not a fix: no mechanism was found to fix).
// Red-on-old for the duplicate shape is VX-393's own pins
// (`MCPOneGrantPerPlaceTests`, red before `98c88a686`).

@Suite("VX-565 — one place shown twice: her shape is gone; the honest twos say why")
struct MCPPlaceTwiceProbeTests {
    private func approvedClient(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func spec(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
        _ duration: MCPGrantRule.Duration = .always
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
    }

    /// The Shared-with-AI rows (one per act) naming one place.
    private func rows(
        _ db: AppDatabase, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) throws -> [MCPSharedRow] {
        try db.read { try Queries.mcpSharedGroups($0) }
            .filter { !$0.isGroup && $0.lead.grant.scopeKind == kind && $0.lead.grant.scopeID == id }
            .map(\.lead)
    }

    // MARK: - Her exact shape, on every road that mints today

    /// PlanetLillian (a wing) granted `read · always`, then `read, suggest, write
    /// new and edit · always`; "o ladrão de raios" (a book inside it) the same —
    /// for ONE client, through every road that can mint a grant on today's tree:
    /// the sheet's new grant (the pane's Share a place… and Share another place…,
    /// a place door, ⌘L — `grantMCPAccess(_:_:replacing: [])`), ⌥⌘A and an ask's
    /// answer (`grantMCPAccess(_:_:)`), Approve… with a grant on an approved
    /// client, and Change… kept on the same place (VX-516's `MCPGrantChange`
    /// keeps the replace). Each place lists ONCE, at the second grant's rung.
    @Test func herShapeListsEachPlaceOnceOnEveryRoad() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            typealias Road = (String, (Operations.MCPGrantSpec, _ held: String) throws -> String)
            let roads: [Road] = [
                ("the sheet's new grant", { spec, _ in try ops.grantMCPAccess(client.id, spec, replacing: []) }),
                ("⌥⌘A / an ask's answer", { spec, _ in try ops.grantMCPAccess(client.id, spec) }),
                ("Approve… with a grant", { spec, _ in try #require(try ops.approveMCPClient(client.id, granting: spec)) }),
                ("Change… on the same place", { spec, held in
                    let place = MCPGrantChange.Place(spec.scopeKind, spec.scopeID)
                    let decided = MCPGrantChange.replacing([held], opened: [place], confirmed: [place])
                    return try ops.grantMCPAccess(client.id, spec, replacing: decided)
                }),
            ]
            for (index, (name, road)) in roads.enumerated() {
                let planetLillian = try ops.createWing(name: "PlanetLillian \(index)")
                let book = try ops.createReading(name: "o ladrão de raios \(index)", kind: .book, wingId: planetLillian.id)
                for (kind, id) in [(MCPGrantRule.ScopeKind.wing, planetLillian.id), (.book, book.id)] {
                    let first = try ops.grantMCPAccess(client.id, spec(.read, kind, id))
                    let second = try road(spec(.edit, kind, id), first)
                    let shown = try rows(db, kind, id)
                    #expect(shown.map(\.grant.id) == [second], "\(name), the \(kind): one row, the newer")
                    #expect(shown.first?.grant.rung == .edit && shown.first?.grant.duration == .always)
                }
            }
        }
    }

    /// The store holds the family to one standing row per client × place by
    /// construction — no road, present or future, can mint her second row (the
    /// index VX-393 added; a once grant may stand beside it, P-VX393-3).
    @Test func theStoreRefusesASecondStandingRowOnHerPlace() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let planetLillian = try ops.createWing(name: "PlanetLillian")
            let held = try ops.grantMCPAccess(client.id, spec(.read, .wing, planetLillian.id))
            for duration in ["always", "connection"] {
                #expect(throws: (any Error).self, "a second live \(duration) row on PlanetLillian refuses") {
                    try db.write { db in
                        try db.execute(
                            sql: """
                                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                                  VALUES ('raw-\(duration)', ?, 'edit', 'wing', ?, ?, '2026-10-26T00:00:00.000Z')
                                """,
                            arguments: [client.id, planetLillian.id, duration])
                    }
                }
            }
            #expect(try rows(db, .wing, planetLillian.id).map(\.grant.id) == [held])
        }
    }

    // MARK: - The honest twos: each row's listing says what differs

    /// TWO CLIENTS on one place, at different rungs: two rows — each names its
    /// own client (the row's detail line leads with the client's name).
    @Test func twoClientsOnOnePlaceAreTwoRowsEachNamingItsClient() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops, "claude-code")
            let codex = try approvedClient(ops, "codex")
            let planetLillian = try ops.createWing(name: "PlanetLillian")
            _ = try ops.grantMCPAccess(claude.id, spec(.edit, .wing, planetLillian.id))
            _ = try ops.grantMCPAccess(codex.id, spec(.read, .wing, planetLillian.id))
            let shown = try rows(db, .wing, planetLillian.id)
            #expect(shown.count == 2)
            #expect(Set(shown.map(\.clientName)) == ["claude-code", "codex"], "each row names its client")
            #expect(Set(shown.map(\.grant.rung)) == [.edit, .read])
        }
    }

    /// A ONCE grant beside a STANDING one (an ask answered Once while a read
    /// grant stands — P-VX393-3: a once grant is one act's permission, never a
    /// standing row): two rows for one client and one place — their durations
    /// differ, and the once row leaves as soon as its one act spends it.
    @Test func aOnceGrantBesideAStandingOneIsTwoRowsUntilItsActSpendsIt() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let planetLillian = try ops.createWing(name: "PlanetLillian")
            let standing = try ops.grantMCPAccess(client.id, spec(.read, .wing, planetLillian.id))
            let once = try ops.grantMCPAccess(client.id, spec(.writeNew, .wing, planetLillian.id, .once))
            let shown = try rows(db, .wing, planetLillian.id)
            #expect(Set(shown.map(\.grant.id)) == [standing, once])
            #expect(Set(shown.map(\.grant.duration)) == [.always, .once], "the two rows' durations differ")
            #expect(Set(shown.map(\.clientName)) == ["claude-code"])
            try db.write { try ops.consumeMCPOnceGrant($0, once) }
            #expect(try rows(db, .wing, planetLillian.id).map(\.grant.id) == [standing], "spent, it leaves")
        }
    }

    /// TWO PLACES wearing ONE NAME (legal for wings and for books — a synced
    /// library, or a book a client made under a name it couldn't read): two rows,
    /// two places, and each row wears its distinguisher — the pane's own ladder
    /// (`MCPGrantPlaces`, read by `MCPDoor.placeDistinguishers`), distinct per twin.
    @Test func twoPlacesSharingANameAreTwoRowsEachWithItsDistinguisher() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let first = try ops.createWing(name: "PlanetLillian")
            let second = try ops.createWing(name: "PlanetLillian")
            let bookA = try ops.createReading(name: "o ladrão de raios", kind: .book, wingId: first.id)
            let bookB = try ops.createReading(name: "o ladrão de raios", kind: .book, wingId: first.id)
            _ = try ops.grantMCPAccess(client.id, spec(.edit, .wing, first.id))
            _ = try ops.grantMCPAccess(client.id, spec(.read, .wing, second.id))
            _ = try ops.grantMCPAccess(client.id, spec(.suggest, .book, bookA.id))
            _ = try ops.grantMCPAccess(client.id, spec(.read, .book, bookB.id))
            let wings = try db.read { try Queries.mcpSharedGroups($0) }
                .filter { $0.lead.grant.scopeKind == .wing }.map(\.lead)
            #expect(wings.map(\.targetTitle) == ["PlanetLillian", "PlanetLillian"], "two rows, one name")
            #expect(Set(wings.map(\.grant.scopeID)) == [first.id, second.id], "two places")

            let places = try db.read { try Queries.mcpGrantPlaces($0) }
            let now = Date(timeIntervalSince1970: 1_782_864_000 + 3_600)
            let wingLabels = places.wingDistinguishers(now: now)
            let bookLabels = places.bookDistinguishers(now: now)
            for (labels, a, b) in [(wingLabels, first.id, second.id), (bookLabels, bookA.id, bookB.id)] {
                let one = try #require(labels[a]), other = try #require(labels[b])
                #expect(!one.isEmpty && one != other, "each twin says which it is: \(one) / \(other)")
            }
        }
    }
}
