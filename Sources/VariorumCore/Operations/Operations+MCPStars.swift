import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's STAR (VX-596 — her ruling 2026-10-27, verbatim: "let's add the
// star over the wire, it might as well be included"; the run record
// `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`, BATCH 1). Stars are
// not in the hers-alone trio (Private · Seal · Own — R-VX184-2), so the EDIT
// rung stars and un-stars a note or a book as she does at the keyboard
// (R-VX184-1). Like every act the door takes, an ORDINARY OPERATION: HER star
// write (`writeStar` — the union star's two stores, the cap of fifteen refusing
// in her words, the self-heal, intake hearing a note's star; un-starring a
// non-event), run inside ONE transaction behind the caller's `WriteGuard`, plus
// the one thing her door deliberately lacks and every MCP write carries
// (P-13nb-U2-4): a client-named structural-undo entry. Her own star door
// registers none ("trivially re-toggled" — `UndoStack`'s header), so the MCP
// road wraps it, `move_note_to_wing`'s precedent.
//
// THE UNDO STORY (the record's THE DESIGN, item 2): each half is
// COMPARE-AND-SET on the STAR — it writes only while the target still reads
// the value its partner (the act, or the last half) left there, starred or not,
// by the union `Queries.starred` reads — and is QUIET otherwise (VX-276: her own
// un-star or re-star since is hers; the entry retires, no redo writes over her).
// A half that takes a star off records WHERE in the Starred list it stood, and
// the half that puts it back restores it THERE (clamped), so an un-star's undo
// returns the row to its place, not to the end. The halves are not applying acts
// (`writeStar(heard: false)` — `apply_tag`'s replay doctrine: an exact revival
// seats nothing; a seat the act's star caused stays, as an un-star never evicts).
// A half that would star past the cap REFUSES in her words and keeps its entry
// (resolvable: un-star one, then ⌥⌘Z) — `starLimitReached`, through the wire's
// one refusal chain and her `OpsRefusalCopy`. A book star put back writes both
// stores (the union star's normal form — a column-only book comes back listed).
//
// These ops decide nothing about clients — who may act is the server's per-call
// rule (`MCPWriteTools+Star`).
extension Operations {
    /// What `setStarredForClient` did.
    public struct MCPStarChange: Equatable, Sendable {
        public let target: StarTarget
        public let starred: Bool
        /// False when the star already read as asked: nothing was written,
        /// no undo entry (VX-362's `apply_tag` shape).
        public let changed: Bool
    }

    /// **`set_starred`'s act — her star write**: the caller's guard FIRST
    /// inside the act's own transaction (the server's decision, re-made on the
    /// act's own facts, any once grant stamped there — AF-10 (a)), then the
    /// star as asked through `writeStar` (her cap refusing `starLimitReached`,
    /// intake hearing a note's star). A target that already reads as asked —
    /// starred by EITHER store of the union, or not starred at all — writes
    /// nothing (`changed: false`, no entry). ONE entry, `undoLabel`, whose
    /// halves restore the star compare-and-set, at its place (see the file's
    /// header).
    @discardableResult
    public func setStarredForClient(
        _ target: StarTarget, starred: Bool, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPStarChange {
        // `.some(place)`: the act wrote, and `place` is where the target stood
        // in the Starred list BEFORE it (nil: in none). `nil`: a no-op.
        let landed: Int?? = try database.write { db in
            try guardian?(db)
            let isStarred = try Queries.starred(db).contains { $0.target == target }
            guard isStarred != starred else { return nil }
            let place = try Queries.starredListItems(db).map(\.target).firstIndex(of: target)
            try writeStar(db, target, starred: starred, enforcingCap: true)
            return .some(place)
        }
        guard case .some(let place) = landed else {
            return MCPStarChange(target: target, starred: starred, changed: false)
        }
        // The place the next half that STARS puts the target back at — an
        // un-star's pre-image now; whatever the last un-starring half took it
        // from, after (a star act's first undo records it before any redo runs).
        let carried = LockIsolated<Int?>(place)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.replayMCPStar(target, to: !starred, place: carried) },
            redo: { try $0.replayMCPStar(target, to: starred, place: carried) })
        return MCPStarChange(target: target, starred: starred, changed: true)
    }

    /// **One half of the star entry** — the target's star set to `starred`,
    /// compare-and-set: only while it reads the OTHER value now (the union), and,
    /// to star, only while the target is live (a note or book trashed since is
    /// the world moving on — quiet). Un-starring records the place it took the
    /// target from in `place`; starring puts it back at `place`. Returns whether
    /// it wrote (VX-246 U2 — a quiet half retires the entry).
    func replayMCPStar(_ target: StarTarget, to starred: Bool, place: LockIsolated<Int?>) throws -> Bool {
        try database.write { db in
            let isStarred = try Queries.starred(db).contains { $0.target == target }
            guard isStarred != starred else { return false }
            if starred {
                guard try starTargetIsLive(db, target) else { return false }
                try writeStar(db, target, starred: true, enforcingCap: true, at: place.value, heard: false)
            } else {
                let stood = try Queries.starredListItems(db).map(\.target).firstIndex(of: target)
                place.setValue(stood)
                try writeStar(db, target, starred: false, enforcingCap: true, heard: false)
            }
            return true
        }
    }
}
