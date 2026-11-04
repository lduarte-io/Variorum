import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-763 (the VX-771 run, batch 4 — the record
// `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, BATCH 4 RECORD). Her
// sighting — PlanetLillian (a wing) and "o ladrão de raios" (a book) each twice in
// Shared with AI for one client, `read · always` beside `read, suggest, write new
// and edit · always` — is item 2 of the report she pasted on 2026-10-18 (VX-393's,
// fixed at 0.9.8; re-probed as VX-565 on 2026-10-27, `MCPPlaceTwiceProbeTests`).
// The re-trace on today's tree found ONE road left by which one client × one place
// lists two live standing rows: `uq_mcp_grant_standing_place` keys a place as
// scope KIND × id, and a reading's kind can change under its grants — a gathering
// bound into a book, and her ⌥⌘Z of that bind making it a gathering again. A BOOK
// grant made while it was a book then stands beside the gathering's own grant, and
// the listing titled it as a live book ("g" · book) although it names no book and
// reaches nothing. Its mirror was already honest: a GATHERING grant on a reading
// bound into a book reads GONE (`mcpScopeTitle(.gathering)` checks the kind —
// VX-549). The listing now reads a book grant's place the same way.

@Suite("VX-763 — a grant whose place changed kind lists as gone, never as a live twin")
struct MCPKindRevertedGrantTests {
    private func approvedClient(_ ops: Operations) throws -> MCPClient {
        let client = try ops.recordMCPContact(name: "claude-code", version: "2.1")
        try ops.approveMCPClient(client.id, granting: nil)
        return client
    }

    private func spec(
        _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String
    ) -> Operations.MCPGrantSpec {
        .init(rung: rung, scopeKind: kind, scopeID: id, duration: .always)
    }

    /// The Shared-with-AI rows (one per act — reading grants are single) naming `id`.
    private func rows(_ db: AppDatabase, _ id: String) throws -> [MCPSharedGroup] {
        try db.read { try Queries.mcpSharedGroups($0) }.filter { $0.lead.grant.scopeID == id }
    }

    /// **RED ON OLD:** a book grant made while the reading was a book, the bind
    /// undone (it is a gathering again), then a gathering grant on it — two live
    /// standing rows for one client × place (the index keys kind × id, so both
    /// stand). The book row read "g" as a live book: two rows wearing one name
    /// and two rungs, the sighting's very face. Now the book row reads GONE (no
    /// title — Revoke only), exactly as a gathering grant reads once its
    /// gathering is bound; the gathering's own row reads live.
    @Test func aBookGrantOnAReadingThatIsAGatheringAgainReadsGone() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let client = try approvedClient(ops)
            let tag = try ops.createTag(name: "t")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(name: "g", kind: .gathering, querySpec: rule)

            _ = try ops.convertSmartReadingToCurated(gathering.id)        // bound: a book
            let bookGrant = try ops.grantMCPAccess(client.id, spec(.read, .book, gathering.id))
            _ = try stack.undo(with: ops)                                 // her ⌥⌘Z: a gathering again
            let kind = try db.read { try Queries.reading($0, id: gathering.id) }?.kind
            #expect(kind == .gathering, "the bind's undo made it a gathering again")
            let gatheringGrant = try ops.grantMCPAccess(
                client.id, spec(.edit, .gathering, gathering.id))

            let listed = try rows(db, gathering.id)
            #expect(listed.count == 2, "two live standing rows on one client × place — kind × id keys them apart")
            let book = try #require(listed.first { $0.lead.grant.id == bookGrant })
            let own = try #require(listed.first { $0.lead.grant.id == gatheringGrant })
            let bookTitle = book.lead.targetTitle
            #expect(bookTitle == nil, "a book grant on a reading that is no book reads gone, never as a live book: \(String(describing: bookTitle))")
            #expect(book.goneCount == 1, "gone — so the pane offers Revoke only (no Change… on a place that isn't there)")
            #expect(own.lead.targetTitle == "g", "the gathering's own grant reads live")
            #expect(own.goneCount == 0)
            // The listing's two other doors read it the same way.
            let members = try db.read { try Queries.mcpSharedActMembers($0, grantIDs: [bookGrant]) }
            let memberTitles = members.map(\.targetTitle)
            #expect(memberTitles == [nil], "the act's members road: \(memberTitles)")
            let flat = try db.read { try Queries.mcpSharedRows($0) }.first { $0.grant.id == bookGrant }
            let flatTitle = flat?.targetTitle
            #expect(flat != nil && flatTitle == nil, "the flat listing: \(String(describing: flatTitle))")
        }
    }

    /// GUARD (green on both sides): the mirror, VX-549's — a gathering grant on a
    /// reading bound into a book since reads gone; the book's own grant reads live.
    @Test func aGatheringGrantOnAReadingBoundIntoABookReadsGone() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let tag = try ops.createTag(name: "t")
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(name: "g", kind: .gathering, querySpec: rule)
            let gatheringGrant = try ops.grantMCPAccess(client.id, spec(.read, .gathering, gathering.id))
            _ = try ops.convertSmartReadingToCurated(gathering.id)
            let bookGrant = try ops.grantMCPAccess(client.id, spec(.edit, .book, gathering.id))
            let listed = try rows(db, gathering.id)
            let stale = try #require(listed.first { $0.lead.grant.id == gatheringGrant })
            let own = try #require(listed.first { $0.lead.grant.id == bookGrant })
            #expect(stale.lead.targetTitle == nil && stale.goneCount == 1)
            #expect(own.lead.targetTitle == "g" && own.goneCount == 0)
        }
    }

    /// GUARD (green on both sides): a book grant on a live BOOK reads its name;
    /// one on a deleted book reads gone — the listing's book read is unchanged
    /// for every book.
    @Test func aBookGrantStillReadsItsBookAndADeletedOneReadsGone() throws {
        try withOperations { ops, db in
            let client = try approvedClient(ops)
            let book = try ops.createReading(name: "o ladrão de raios", kind: .book)
            let doomed = try ops.createReading(name: "doomed", kind: .book)
            let live = try ops.grantMCPAccess(client.id, spec(.read, .book, book.id))
            let gone = try ops.grantMCPAccess(client.id, spec(.read, .book, doomed.id))
            try ops.deleteReading(doomed.id)
            let liveRow = try #require(try rows(db, book.id).first { $0.lead.grant.id == live })
            let goneRow = try #require(try rows(db, doomed.id).first { $0.lead.grant.id == gone })
            #expect(liveRow.lead.targetTitle == "o ladrão de raios" && liveRow.goneCount == 0)
            #expect(goneRow.lead.targetTitle == nil && goneRow.goneCount == 1)
            let members = try db.read { try Queries.mcpSharedActMembers($0, grantIDs: [live, gone]) }
            #expect(members.map(\.targetTitle) == ["o ladrão de raios", nil], "the act's members read the same")
            let flat = try db.read { try Queries.mcpSharedRows($0) }.filter { [live, gone].contains($0.grant.id) }
            #expect(Set(flat.map(\.targetTitle)) == Set(["o ladrão de raios", nil]))
        }
    }
}
