import Foundation
import GRDB

/// **HAS THIS LIBRARY EVER HAD AN MCP CLIENT?** — ONE monotone fact, read by every
/// face that waits for it (VX-590 — the VX-620 run, RB-3 ratified at #245; VX-641 —
/// the VX-648 run, her ruling 2026-10-28: "i think it should be hidden if there's no
/// AI to share with - otherwise it might be confusing").
///
/// The fact is VX-512's own read the other way: a client row exists — waiting,
/// approved or denied. "Ever": no road removes a client row but the waiting room's
/// cap, which forgets only the OLDEST pending request past fifty and never the one
/// just made; Deny keeps the row; an adopted library keeps its rows. Clients are
/// LOCAL-ONLY rows of this library on this Mac (never synced, never carried into
/// another library), so a library started fresh or filled by sync begins with none.
///
/// Two faces read it: Settings ▸ MCP's sharing face (`MCPPane.showsSharingFace`) and
/// the PRIVATE row — a note's (its ▾ menu) and a book's (Book Settings). The row adds
/// one clause: a note or book ALREADY marked Private always shows it, because the mark
/// SYNCS (`ai_private_at`) while clients don't — a mark made on another Mac can arrive
/// here with no client, and it must never be invisible or out of reach.
public enum MCPLibraryClients {
    /// The fact over a count of client rows (any state).
    public static func everHadClient(clientRows: Int) -> Bool { clientRows > 0 }

    /// The Private row's gate: the library has had a client, or the mark is on
    /// (its own, or — for a note — a Private book's that holds it).
    public static func showsPrivateRow(everHadClient: Bool, marked: Bool) -> Bool { everHadClient || marked }
}

extension Queries {
    /// The store's answer: every client row, any state (bounded — the waiting
    /// room is capped, decided clients are few).
    public static func mcpLibraryHasHadClient(_ db: Database) throws -> Bool {
        MCPLibraryClients.everHadClient(clientRows: try mcpClientCount(db))
    }
}
