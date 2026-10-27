import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-516 (the VX-548 run, batch 1 — the record
// `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 1 RECORD).
// Her Air report (2026-10-23, re-granting claude-code a second wing on a fresh
// library): "it keeps just changing what is shown though - it doesn't show both
// & I can see that the other one is revoked when I grant that one." Her
// urgency (2026-10-26): "allowing multiple grants is one of my highest
// priorities because it's so annoying that only you or planetlillian can be
// working at one time."
//
// THE TRACE: the one mint (`insertMCPGrant`) is per place (VX-393 — client ×
// scope kind × scope id), so no adding road can revoke another wing (the
// guards below prove each by test). The revoke came from Change…: every
// Change… road opens THE grant sheet pre-filled on the grant it names and
// names it to replace (T-U3-8), WHERE stays open to a new pick, and the
// sheet's confirm passed `replacing` through whatever place was confirmed —
// so Change… on the PlanetLillian wing with another wing picked revoked
// PlanetLillian. THE FIX (PROVISIONAL MB-1): the replace stands only while the
// confirmed place IS the opened one (`MCPGrantChange`), read at the sheet's
// one confirm; a different place is a new grant.

@Suite("VX-516 — Change… replaces only its own place; two wings stand together")
struct MCPGrantChangeTests {
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

    private func place(_ kind: MCPGrantRule.ScopeKind, _ id: String) -> MCPGrantChange.Place {
        .init(kind, id)
    }

    /// The client's LIVE grants on one place.
    private func live(
        _ db: AppDatabase, _ client: String, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) throws -> [MCPGrantRow] {
        try db.read { try Queries.mcpGrants($0, clientID: client) }
            .filter { $0.ruleGrant.isLive && $0.scopeKind == kind && $0.scopeID == id }
    }

    /// The client's reach on a wing, read off the ONE rule (`decideWing`'s).
    private func reach(_ db: AppDatabase, _ client: String, wing: String) throws -> MCPGrantRule.Rung? {
        let grants = try db.read { try Queries.mcpGrants($0, clientID: client) }.map(\.ruleGrant)
        return MCPGrantRule.reach(grants: grants, openBook: false, wing: wing)?.rung
    }

    /// **THE ACT HER REPRO PERFORMS — Change… confirmed on another place —
    /// through the sheet's one decision** (`MCPGrantSheet.submit` reads
    /// `MCPGrantChange.replacing` and hands the op what it decides).
    private func change(
        _ ops: Operations, _ client: MCPClient, opened: MCPGrantChange.Place, naming named: [String],
        confirming spec: Operations.MCPGrantSpec
    ) throws -> String {
        let decided = MCPGrantChange.replacing(
            named, opened: [opened], confirmed: [place(spec.scopeKind, spec.scopeID)])
        return try ops.grantMCPAccess(client.id, spec, replacing: decided)
    }

    // MARK: - THE PIN (RED ON OLD: the sheet passed `replacing` through, so the first wing was revoked)

    /// With PlanetLillian's standing wing grant held, Change… on it with
    /// ANOTHER wing picked must leave BOTH wings standing — each at its own
    /// rung, both reached, both listed in Shared with AI. And her "it keeps
    /// just changing what is shown": a second hop (Change… on the new row,
    /// back to PlanetLillian) changes PlanetLillian's own row in place and
    /// still leaves the other wing standing.
    @Test func changeOnOneWingConfirmedOnAnotherLeavesBothWingsStanding() throws {
        try withOperations { ops, db in
            let planetLillian = try ops.createWing(name: "PlanetLillian")
            let studio = try ops.createWing(name: "studio")
            let client = try approvedClient(ops)
            let first = try ops.grantMCPAccess(client.id, spec(.edit, .wing, planetLillian.id))

            let second = try change(
                ops, client, opened: place(.wing, planetLillian.id), naming: [first],
                confirming: spec(.read, .wing, studio.id))

            #expect(try live(db, client.id, .wing, planetLillian.id).map(\.id) == [first],
                    "the wing the sheet was opened on stands — nothing replaced")
            #expect(try live(db, client.id, .wing, studio.id).map(\.id) == [second], "the new wing stands beside it")
            #expect(try reach(db, client.id, wing: planetLillian.id) == .edit)
            #expect(try reach(db, client.id, wing: studio.id) == .read)
            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            #expect(Set(groups.map(\.lead.grant.id)) == [first, second], "Shared with AI shows both wings")

            // The second hop: Change… on the studio row, PlanetLillian picked
            // — a different place again, so studio stands; PlanetLillian's own
            // standing row is upgraded in place (VX-393), one row there.
            let third = try change(
                ops, client, opened: place(.wing, studio.id), naming: [second],
                confirming: spec(.suggest, .wing, planetLillian.id))
            #expect(try live(db, client.id, .wing, studio.id).map(\.id) == [second], "studio stands")
            #expect(try live(db, client.id, .wing, planetLillian.id).map(\.id) == [third],
                    "PlanetLillian holds one row — the new one")
            #expect(try db.read { try Queries.mcpSharedGroups($0) }.count == 2, "both wings, once each")
        }
    }

    /// Every Change… road meets the same decision — a receipt's (a place-door
    /// share, then its Change… on another wing), a shared icon's popover on a
    /// book confirmed on a wing, a note grant's confirmed on another note: in
    /// each the grant it was opened on stands (RED ON OLD in each).
    @Test func everyChangeRoadConfirmedElsewhereRevokesNothing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "PlanetLillian")
            let other = try ops.createWing(name: "studio")
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let noteA = try ops.createPost(title: "parser notes")
            let noteB = try ops.createPost(title: "grammar sketch")
            let client = try approvedClient(ops)

            // The receipt's Change… (it names the act's grants and their place).
            let shared = try ops.grantMCPAccess(client.id, spec(.read, .wing, wing.id), replacing: [])
            _ = try change(ops, client, opened: place(.wing, wing.id), naming: [shared],
                           confirming: spec(.read, .wing, other.id))
            #expect(try live(db, client.id, .wing, wing.id).map(\.id) == [shared])

            // A popover's Change… on a book grant, a wing confirmed.
            let onBook = try ops.grantMCPAccess(client.id, spec(.suggest, .book, book.id))
            _ = try change(ops, client, opened: place(.book, book.id), naming: [onBook],
                           confirming: spec(.read, .wing, ""))
            #expect(try live(db, client.id, .book, book.id).map(\.id) == [onBook], "the book stands")
            #expect(try live(db, client.id, .wing, "").count == 1, "and Home is granted beside it")

            // A note grant's Change…, another note confirmed (a while-connected
            // grant beside an always one — the duration changes too).
            let onNote = try ops.grantMCPAccess(client.id, spec(.read, .note, noteA.id))
            _ = try change(ops, client, opened: place(.note, noteA.id), naming: [onNote],
                           confirming: spec(.read, .note, noteB.id, .connection))
            #expect(try live(db, client.id, .note, noteA.id).map(\.id) == [onNote])
            #expect(try live(db, client.id, .note, noteB.id).count == 1)
        }
    }

    // MARK: - The replace still stands where it was ruled (T-U3-8 — guards)

    /// Change… on the SAME place keeps T-U3-8's replace: a lowered rung lands
    /// (one row, the new one), a ONCE grant changed to always is replaced
    /// (only the named replace takes a once row — VX-393's standing replace
    /// never does), and an act's Change… with a note gone since replaces every
    /// member, the gone one included.
    @Test func changeOnTheSamePlaceStillReplacesWhatItNames() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "PlanetLillian")
            let client = try approvedClient(ops)
            let old = try ops.grantMCPAccess(client.id, spec(.edit, .wing, wing.id))
            let lowered = try change(ops, client, opened: place(.wing, wing.id), naming: [old],
                                     confirming: spec(.read, .wing, wing.id))
            #expect(try live(db, client.id, .wing, wing.id).map(\.id) == [lowered], "the lowered rung lands")

            let note = try ops.createPost(title: "a note")
            let once = try ops.grantMCPAccess(client.id, spec(.edit, .note, note.id, .once))
            let standing = try change(ops, client, opened: place(.note, note.id), naming: [once],
                                      confirming: spec(.read, .note, note.id, .always))
            #expect(try live(db, client.id, .note, note.id).map(\.id) == [standing],
                    "the once grant it was opened on is replaced")

            let notes = try ["a", "b", "c"].map { try ops.createPost(title: $0).id }
            let act = try ops.grantMCPAccess(client.id, notes: notes, rung: .read, duration: .always)
            try ops.deleteContainer(notes[2])
            // The act's sheet says the notes that stand (a gone note leaves it).
            let decided = MCPGrantChange.replacing(
                act, opened: Set(notes.map { place(.note, $0) }),
                confirmed: Set(notes.prefix(2).map { place(.note, $0) }))
            #expect(decided == act, "an act's Change… keeps its replace")
            _ = try ops.grantMCPAccess(client.id, notes: Array(notes.prefix(2)), rung: .suggest,
                                       duration: .always, replacing: decided)
            let revoked = try db.read { db in
                try act.map { try #require(try Queries.mcpGrant(db, id: $0)).revokedAt != nil }
            }
            #expect(revoked == [true, true, true], "every member replaced, the gone note's included")
        }
    }

    /// The decision, whole.
    @Test func theDecisionTable() {
        let wingA = place(.wing, "a"), wingB = place(.wing, "b"), home = place(.wing, "")
        let note = place(.note, "x"), bookSameID = place(.book, "x")
        let named = ["g1", "g2"]
        // The very place: kept.
        #expect(MCPGrantChange.replacing(named, opened: [wingA], confirmed: [wingA]) == named)
        #expect(MCPGrantChange.replacing(named, opened: [home], confirmed: [home]) == named, "Home is a place")
        // Another place — another id, another kind, Home against a named wing: dropped.
        #expect(MCPGrantChange.replacing(named, opened: [wingA], confirmed: [wingB]).isEmpty)
        #expect(MCPGrantChange.replacing(named, opened: [note], confirmed: [bookSameID]).isEmpty,
                "a kind is part of the place")
        #expect(MCPGrantChange.replacing(named, opened: [home], confirmed: [wingA]).isEmpty)
        #expect(MCPGrantChange.replacing(named, opened: [wingA], confirmed: [home]).isEmpty)
        // An act: the notes that stand are its own (kept); any other note in the confirm drops it.
        let n1 = place(.note, "1"), n2 = place(.note, "2"), n3 = place(.note, "3")
        #expect(MCPGrantChange.replacing(named, opened: [n1, n2, n3], confirmed: [n1, n2, n3]) == named)
        #expect(MCPGrantChange.replacing(named, opened: [n1, n2, n3], confirmed: [n1, n3]) == named)
        #expect(MCPGrantChange.replacing(named, opened: [n1, n2], confirmed: [n1, n2, n3]).isEmpty)
        #expect(MCPGrantChange.replacing(named, opened: [n1, n2], confirmed: [n3]).isEmpty)
        // Nothing opened on (a fresh sheet) or nothing confirmed: nothing replaced.
        #expect(MCPGrantChange.replacing(named, opened: [], confirmed: [wingA]).isEmpty)
        #expect(MCPGrantChange.replacing(named, opened: [wingA], confirmed: []).isEmpty)
        #expect(!MCPGrantChange.keepsReplacing(opened: [], confirmed: []))
        // Nothing named stays nothing.
        #expect(MCPGrantChange.replacing([], opened: [wingA], confirmed: [wingA]).isEmpty)
    }

    // MARK: - Every ADDING road, proven by test (guards — green on both sides: the mint was always per place)

    /// The brief's warning, kept: prove each road by test, never by reading
    /// its opening. Each road that adds — the Clients row's door (its sheet
    /// opens fresh and confirms `grantMCPAccess(_:_:)`), a place-door sheet's
    /// new grant (`replacing: []`), ⌥⌘A and an ask's answer (the plain op),
    /// Approve… with a grant on an approved client — grants a SECOND wing and
    /// both stand.
    @Test func everyAddingRoadLeavesBothWingsStanding() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            typealias Road = (String, (Operations.MCPGrantSpec) throws -> String)
            let roads: [Road] = [
                ("grantMCPAccess(_:_:)", { try ops.grantMCPAccess(client.id, $0) }),
                ("grantMCPAccess(_:_:replacing: [])", { try ops.grantMCPAccess(client.id, $0, replacing: []) }),
                ("approveMCPClient(_:granting:)", { try #require(try ops.approveMCPClient(client.id, granting: $0)) }),
            ]
            for (index, (name, road)) in roads.enumerated() {
                let a = try ops.createWing(name: "first \(index)")
                let b = try ops.createWing(name: "second \(index)")
                let onA = try road(spec(.edit, .wing, a.id))
                let onB = try road(spec(.read, .wing, b.id))
                #expect(try live(db, client.id, .wing, a.id).map(\.id) == [onA], "\(name): the first wing stands")
                #expect(try live(db, client.id, .wing, b.id).map(\.id) == [onB], "\(name): the second beside it")
            }
        }
    }

    // MARK: - VX-515 ask 2: one place lists everything granted (a guard — the listing was honest)

    /// Shared with AI's read lists EVERY live grant of EVERY client, each a
    /// row with its place, rung and duration — two wings for one client are
    /// two rows; a bulk act is ONE row whose members are its road; a revoked
    /// grant and a spent once grant are not listed; the pane's capped page
    /// counts the rest (its "all N ›" road). Green on both sides: her "it
    /// doesn't show both" was VX-516's revoke, never a listing that hid one.
    @Test func sharedWithAIListsEveryLiveGrantOfEveryClient() throws {
        try withOperations { ops, db in
            let claude = try approvedClient(ops, "claude-code")
            let codex = try approvedClient(ops, "codex")
            let planetLillian = try ops.createWing(name: "PlanetLillian")
            let studio = try ops.createWing(name: "studio")
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let note = try ops.createPost(title: "parser notes")
            let bulk = try ["a", "b", "c"].map { try ops.createPost(title: $0).id }
            var expected: [String: (MCPGrantRule.ScopeKind, MCPGrantRule.Rung, MCPGrantRule.Duration)] = [:]
            func grant(_ client: MCPClient, _ s: Operations.MCPGrantSpec) throws {
                expected[try ops.grantMCPAccess(client.id, s)] = (s.scopeKind, s.rung, s.duration)
            }
            try grant(claude, spec(.edit, .wing, planetLillian.id))
            try grant(claude, spec(.read, .wing, studio.id))
            try grant(claude, spec(.read, .wing, ""))
            try grant(claude, spec(.suggest, .book, book.id))
            try grant(claude, spec(.writeNew, .note, note.id, .once))
            try grant(codex, spec(.read, .wing, planetLillian.id))
            let act = try ops.grantMCPAccess(claude.id, notes: bulk, rung: .read, duration: .always)
            // Not listed: a revoked grant and a spent once grant.
            let revoked = try ops.grantMCPAccess(codex.id, spec(.read, .book, book.id))
            try ops.revokeMCPGrant(revoked)
            let spent = try ops.grantMCPAccess(codex.id, spec(.read, .note, note.id, .once))
            try db.write { try ops.consumeMCPOnceGrant($0, spent) }

            let groups = try db.read { try Queries.mcpSharedGroups($0) }
            let listed = groups.flatMap(\.grantIDs)
            #expect(Set(listed) == Set(expected.keys).union(act), "every live grant, of every client")
            #expect(listed.count == Set(listed).count, "each exactly once")
            for group in groups where !group.isGroup {
                let shown = try #require(expected[group.lead.grant.id])
                #expect((group.lead.grant.scopeKind, group.lead.grant.rung, group.lead.grant.duration) == shown,
                        "a row says its place, rung and duration")
                #expect(group.lead.targetTitle != nil, "and names its place")
            }
            let claudeWings = groups.filter { !$0.isGroup && $0.lead.grant.clientID == claude.id
                && $0.lead.grant.scopeKind == .wing }
            #expect(claudeWings.count == 3, "PlanetLillian, studio and Home — three rows for one client")
            let actRow = try #require(groups.first { $0.isGroup })
            #expect(Set(actRow.grantIDs) == Set(act) && actRow.memberCount == 3)
            let members = try db.read { try Queries.mcpSharedActMembers($0, grantIDs: actRow.grantIDs) }
            #expect(Set(members.map(\.grant.id)) == Set(act), "the act's road names every member")
            // The pane's page: five acts shown, the count names all of them.
            let page = try db.read { try Queries.mcpSharedGroups($0, limit: 5) }
            #expect(page.count == 5)
            #expect(try db.read { try Queries.mcpSharedGroupCount($0) } == groups.count)
            #expect(!listed.contains(revoked) && !listed.contains(spent))
        }
    }
}
