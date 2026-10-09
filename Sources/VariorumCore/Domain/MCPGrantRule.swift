import Foundation

/// **THE GRANT RULE — the MCP door's security boundary** (13n-b, A-7; the
/// grammar is R-13n-4's, the journal fence R-13nb-1's, the Private leg
/// R-13nb-4's). ONE pure decision, consulted PER CALL by the server against
/// the store's CURRENT facts, read in the same transaction as the call's own
/// read: a note moved out of a granted book since the grant refuses today,
/// like any stale pointer; a revoked grant refuses on the very next call.
///
/// The grammar:
/// - **Rungs, cumulative:** read < suggest < write new < edit. A grant at a
///   rung covers every rung below it.
/// - **Scopes:** a note · a book (its live member notes, as of now) · a wing
///   (every note and book in it).
/// - **Durations:** once (consumed by the first content-bearing call it
///   authorizes) · while connected (revoked by the server when the client's
///   last connection closes, and swept at every server start) · always.
/// - **The open book:** one switch; read rung, everywhere, for APPROVED
///   clients only.
/// - **THE FENCE** (journal-class — R-13nb-1 + R-13nb-4): a FENCED note
///   matches no standing grant and never rides the open book; only a
///   per-ask grant naming THAT note, once or while connected, reaches it —
///   and its ask never offers "always". A fenced BOOK matches nothing at all
///   (its notes are fenced one by one; the book itself is never listed).
///
/// The rule decides; it never reads. `Queries.mcpNoteFacts` /
/// `mcpBookFacts` derive the facts (the fence's legs live there, in ONE
/// place); the server records consumption and activity.
public enum MCPGrantRule {
    // MARK: - The grammar's words

    public enum Rung: String, CaseIterable, Comparable, Sendable {
        case read
        case suggest
        case writeNew = "write_new"
        case edit

        private var order: Int {
            switch self {
            case .read: 0
            case .suggest: 1
            case .writeNew: 2
            case .edit: 3
            }
        }

        public static func < (lhs: Rung, rhs: Rung) -> Bool { lhs.order < rhs.order }
    }

    public enum ScopeKind: String, CaseIterable, Sendable {
        case note, book, wing
    }

    public enum Duration: String, CaseIterable, Sendable {
        case once
        case connection
        case always
    }

    public enum ClientState: String, CaseIterable, Sendable {
        case pending, approved, denied
    }

    /// Why a note or book is fenced. Journal = R-13nb-1's predicate (its
    /// own `profile='journal'`, or a live member of a live journal/daily
    /// book); privateMark = R-13nb-4's (its own mark, or a live member of a
    /// live marked book). Privacy wins ties: when both hold, the fence says
    /// `privateMark`.
    public enum Fence: String, Sendable, Equatable {
        case journal
        case privateMark = "private"
    }

    // MARK: - The inputs

    /// One grant row, as the rule needs it.
    public struct Grant: Equatable, Sendable {
        public var id: String
        public var rung: Rung
        public var scopeKind: ScopeKind
        /// A container, reading or wing id (`''` = the virtual Home wing).
        public var scopeID: String
        public var duration: Duration
        public var consumedAt: String?
        public var revokedAt: String?

        public init(
            id: String, rung: Rung, scopeKind: ScopeKind, scopeID: String,
            duration: Duration, consumedAt: String? = nil, revokedAt: String? = nil
        ) {
            self.id = id
            self.rung = rung
            self.scopeKind = scopeKind
            self.scopeID = scopeID
            self.duration = duration
            self.consumedAt = consumedAt
            self.revokedAt = revokedAt
        }

        /// Not revoked, and — for a once grant — not yet consumed.
        public var isLive: Bool {
            revokedAt == nil && !(duration == .once && consumedAt != nil)
        }
    }

    /// A note's current facts.
    public struct NoteFacts: Equatable, Sendable {
        public var id: String
        /// Its wing, with a dangling pointer already read as Home (`''`).
        public var wingID: String
        /// The live BOOKS it is a live member of (status 'member').
        public var bookIDs: Set<String>
        public var fence: Fence?

        public init(id: String, wingID: String, bookIDs: Set<String> = [], fence: Fence? = nil) {
            self.id = id
            self.wingID = wingID
            self.bookIDs = bookIDs
            self.fence = fence
        }
    }

    /// A book's current facts.
    public struct BookFacts: Equatable, Sendable {
        public var id: String
        public var wingID: String
        public var fence: Fence?

        public init(id: String, wingID: String, fence: Fence? = nil) {
            self.id = id
            self.wingID = wingID
            self.fence = fence
        }
    }

    public enum Target: Equatable, Sendable {
        case note(NoteFacts)
        case book(BookFacts)
    }

    // MARK: - The output

    /// Why a call cannot proceed as asked. Each speaks to the client exactly
    /// as it would speak to her (`MCPRefusalCopy` in the server holds the
    /// words).
    public enum Reason: Equatable, Sendable {
        /// The client's connection request is waiting in Settings ▸ MCP.
        case clientPending
        /// She denied this client.
        case clientDenied
        /// No grant reaches this note or book (or it does not exist — the
        /// two are deliberately one answer: no existence oracle).
        case notShared
        /// A grant reaches it, at a lower rung than asked.
        case rungTooLow(granted: Rung)
        /// A fenced note: per-ask only.
        case fenced(Fence)
    }

    public enum Decision: Equatable, Sendable {
        /// Proceed. `grantID` is the grant that authorized the call (nil =
        /// the open book); `consumesOnce` says the caller must stamp that
        /// once grant consumed IN THE SAME TRANSACTION as the read.
        case allow(grantID: String?, consumesOnce: Bool)
        /// Not now — a just-in-time ask could change it (an approved client,
        /// past its grant). `offersAlways` is false for a fenced target (the
        /// ask never offers "always" — R-13n-4).
        case ask(Reason, offersAlways: Bool)
        /// No ask can change it (the client is not approved).
        case refuse(Reason)

        public var isAllowed: Bool {
            if case .allow = self { return true }
            return false
        }
    }

    // MARK: - The decision

    /// **The one decision.** `consumes` says whether this call is
    /// content-bearing (reading a note's text) — a once grant is spent only
    /// by such a call, never by a listing; when a standing grant also covers
    /// the call, the once grant is not spent at all.
    public static func decide(
        client: ClientState?, grants: [Grant], openBook: Bool,
        target: Target, rung: Rung, consumes: Bool
    ) -> Decision {
        switch client {
        case .approved: break
        case .denied: return .refuse(.clientDenied)
        case .pending, nil: return .refuse(.clientPending)
        }

        let fence: Fence? = switch target {
        case .note(let note): note.fence
        case .book(let book): book.fence
        }

        // Every live grant whose SCOPE reaches the target, as of now.
        let reaching = grants.filter { $0.isLive && reaches($0, target) }
        // The open book: read, everywhere, never a fenced target.
        if openBook, fence == nil, rung == .read {
            if let standing = best(reaching.filter { $0.duration != .once }) {
                return .allow(grantID: standing.id, consumesOnce: false)
            }
            return .allow(grantID: nil, consumesOnce: false)
        }
        let sufficient = reaching.filter { $0.rung >= rung }
        if let grant = best(sufficient) {
            return .allow(grantID: grant.id, consumesOnce: grant.duration == .once && consumes)
        }
        if let fence {
            return .ask(.fenced(fence), offersAlways: false)
        }
        if let highest = reaching.map(\.rung).max() {
            return .ask(.rungTooLow(granted: highest), offersAlways: true)
        }
        return .ask(.notShared, offersAlways: true)
    }

    /// Does this grant's SCOPE reach the target? The fence lives here: a
    /// fenced note is reached only by a per-ask grant naming it (a note
    /// scope, never "always"); a fenced book by nothing.
    public static func reaches(_ grant: Grant, _ target: Target) -> Bool {
        switch target {
        case .note(let note):
            if note.fence != nil {
                return grant.scopeKind == .note && grant.scopeID == note.id
                    && grant.duration != .always
            }
            switch grant.scopeKind {
            case .note: return grant.scopeID == note.id
            case .book: return note.bookIDs.contains(grant.scopeID)
            case .wing: return grant.scopeID == note.wingID
            }
        case .book(let book):
            guard book.fence == nil else { return false }
            switch grant.scopeKind {
            case .note: return false
            case .book: return grant.scopeID == book.id
            case .wing: return grant.scopeID == book.wingID
            }
        }
    }

    /// Among several sufficient grants, the one that should authorize: a
    /// standing grant before a once grant (so a once grant is never spent
    /// when something else already covers the call), always before while
    /// connected, then the smaller id (deterministic).
    static func best(_ grants: [Grant]) -> Grant? {
        func weight(_ duration: Duration) -> Int {
            switch duration {
            case .always: 2
            case .connection: 1
            case .once: 0
            }
        }
        return grants.max { lhs, rhs in
            let l = weight(lhs.duration), r = weight(rhs.duration)
            return l == r ? lhs.id > rhs.id : l < r
        }
    }
}
