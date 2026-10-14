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
/// - **THE FENCE** (journal-class — R-13nb-1 + R-13nb-4, re-keyed on THE
///   daily Journal by 13n-c's VX-163): a FENCED note
///   matches no standing grant and never rides the open book; only a
///   per-ask grant naming THAT note, once or while connected, reaches it —
///   and its ask never offers "always". A fenced BOOK matches nothing at all
///   (its notes are fenced one by one; the book itself is never listed).
///   A LIVE per-ask grant holder asking PAST its rung hears `rungTooLow`,
///   never the fence (13n-c U1 ladder F1 — its grant is its knowledge); a
///   spent or revoked grant is not live, so the fence's one answer returns.
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

    /// Why a note or book is fenced. Journal = R-13nb-1's predicate as
    /// RE-KEYED by 13n-c's VX-163 (a note's own `profile='journal'` — the
    /// ⌘J day entry's shape, D-1 — or a live member of a live book wearing
    /// THE daily Journal's 'daily' marker; a journal-TRAIT book is not a
    /// fence); privateMark = R-13nb-4's (its own mark, or a live member of a
    /// live marked book). Privacy wins ties: when both hold, the fence says
    /// `privateMark`. The legs are derived in ONE place
    /// (`Queries.mcpNoteFacts` / `mcpBookFacts`).
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

    /// The fence from its legs (`Queries.mcpNoteFacts` derives the legs in
    /// one place) — privacy wins ties (R-13nb-4).
    public static func fence(journal: Bool, privateMark: Bool) -> Fence? {
        if privateMark { return .privateMark }
        if journal { return .journal }
        return nil
    }

    // MARK: - The decision

    /// **The one decision.** `consumes` says whether this call is
    /// content-bearing (reading a note's text, or a write) — a once grant is
    /// spent only by such a call (`spends`, AF-7 as amended: a read grant by
    /// its first content read, a write grant by its first write of any rung),
    /// never by a listing; when a standing grant also covers the call, the
    /// once grant is not spent at all.
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
            return .allow(grantID: grant.id, consumesOnce: spends(grant, rung: rung, consumes: consumes))
        }
        // 13n-c U1 ladder F1 (the recorded F-8, built): a LIVE grant already
        // reaches the target — for a fenced note, necessarily its own per-ask
        // grant — so the honest answer is the rung, never the one not-shared
        // answer ("or doesn't exist") about a note the client can read this
        // second. The client's grant IS its knowledge: no oracle opens, and a
        // spent once grant or a revoked one is not live, so a lapsed grant
        // falls through to the fence below. A fenced target's ask still never
        // offers "always" (R-13n-4).
        if let highest = reaching.map(\.rung).max() {
            return .ask(.rungTooLow(granted: highest), offersAlways: fence == nil)
        }
        if let fence {
            return .ask(.fenced(fence), offersAlways: false)
        }
        return .ask(.notShared, offersAlways: true)
    }

    // MARK: - The WHY (13n-c U3 — VX-271 · VX-164: "readable through the Home wing grant")

    /// What lets an approved client reach a target right now.
    public enum Standing: Equatable, Sendable {
        /// A live grant authorizes it — its scope says why: the place's own
        /// grant, or a wider one (a book holding the note, the wing).
        case grant(Grant)
        /// The open book (read, everywhere unfenced — no grant row).
        case openBook
    }

    /// An approved client's reach on a target: how far, and why.
    public struct Reach: Equatable, Sendable {
        public let rung: Rung
        public let standing: Standing

        public init(rung: Rung, standing: Standing) {
            self.rung = rung
            self.standing = standing
        }
    }

    /// **The highest rung an APPROVED client reaches the target at right
    /// now, and the standing that authorizes it** — read OFF `decide` itself
    /// (its `.allow(grantID:)`; nil = the open book), never a parallel rule:
    /// the faces' WHY is exactly the grant the server would use. A
    /// non-consuming probe (`consumes: false`), so it spends nothing. nil =
    /// it reaches nothing (a fenced note reached by no per-ask grant of its
    /// own; a fenced book always).
    public static func reach(grants: [Grant], openBook: Bool, target: Target) -> Reach? {
        for rung in Rung.allCases.reversed() {
            guard case .allow(let grantID, _) = decide(
                client: .approved, grants: grants, openBook: openBook, target: target,
                rung: rung, consumes: false)
            else { continue }
            guard let grantID else { return Reach(rung: rung, standing: .openBook) }
            guard let grant = grants.first(where: { $0.id == grantID }) else { continue }
            return Reach(rung: rung, standing: .grant(grant))
        }
        return nil
    }

    /// **A GATHERING's reach, and the standing behind it** (VX-185 — her
    /// report: gatherings never wore the shared icon "even when you've shared
    /// the whole wing"; R-VX185-1: only a wing grant or the open book icons
    /// one). Read OFF `decideGathering` exactly as `reach` is read off
    /// `decide` — never a parallel rule: its `.allow(grantID:)` names the wing
    /// grant (nil = the open book); anything else reaches nothing (a fenced
    /// gathering, a note or book grant, another wing's grant). The rung is
    /// READ — `decideGathering`'s one rung: a gathering holds nothing to
    /// write, whatever the wing grant allows on the notes inside it.
    public static func reach(grants: [Grant], openBook: Bool, gathering: BookFacts) -> Reach? {
        guard case .allow(let grantID, _) = decideGathering(
            client: .approved, grants: grants, openBook: openBook, gathering: gathering)
        else { return nil }
        guard let grantID else { return Reach(rung: .read, standing: .openBook) }
        guard let grant = grants.first(where: { $0.id == grantID }) else { return nil }
        return Reach(rung: .read, standing: .grant(grant))
    }

    /// **ONCE: ONE WRITE MEANS ONE WRITE** (AF-7 AS AMENDED at the U2
    /// ladder's F4 — the ride-free clause covers READS only): a once READ
    /// grant is spent by its first content read (U1's letter, unchanged);
    /// a once WRITE grant (suggest or write new) is spent by its first
    /// CONTENT-BEARING WRITE of ANY rung it authorizes — the content reads
    /// it needs on the way ride free, writes never do. So a once-suggest
    /// grant authorizes ONE suggestion, a once-write-new grant ONE write of
    /// whatever rung; a take-plus-lens flow wants "while connected".
    static func spends(_ grant: Grant, rung: Rung, consumes: Bool) -> Bool {
        guard grant.duration == .once, consumes else { return false }
        return grant.rung == .read ? rung == .read : rung >= .suggest
    }

    /// **A WING-LEVEL decision** — `list_notes` with a wing (a listing:
    /// never consumes), and since U2 the wing-scoped WRITES (`create_note` /
    /// `import_document` landing in a wing, `create_book`): allowed only
    /// with wing-level reach — the open book on a read, or a live grant on
    /// THAT wing at the asked rung. A wing-scoped write spends a once wing
    /// grant exactly as `decide` does (AF-7). Every note a wing listing then
    /// shows still passes `decide` on its own — the fence filters per note,
    /// so a wing never lists a fenced note (a daily-Journal entry, a ⌘J entry,
    /// anything Private — 13n-c VX-163).
    public static func decideWing(
        client: ClientState?, grants: [Grant], openBook: Bool, wingID: String, rung: Rung,
        consumes: Bool = false
    ) -> Decision {
        switch client {
        case .approved: break
        case .denied: return .refuse(.clientDenied)
        case .pending, nil: return .refuse(.clientPending)
        }
        let reaching = grants.filter { $0.isLive && $0.scopeKind == .wing && $0.scopeID == wingID }
        if let grant = best(reaching.filter { $0.rung >= rung }) {
            return .allow(grantID: grant.id, consumesOnce: spends(grant, rung: rung, consumes: consumes))
        }
        if openBook, rung == .read { return .allow(grantID: nil, consumesOnce: false) }
        if let highest = reaching.map(\.rung).max() {
            return .ask(.rungTooLow(granted: highest), offersAlways: true)
        }
        return .ask(.notShared, offersAlways: true)
    }

    /// **A GATHERING — read facts under WING-LEVEL reach** (13n-c VX-273, her
    /// ruling: "granting a wing grants access to everything … unless it's
    /// deliberately marked private"; gatherings "do NOT become separate grant
    /// targets"). A gathering is never a grant's scope, so only wing-level
    /// reach on ITS wing reaches it — `decideWing`'s own READ: a live wing grant
    /// on that wing at any rung, or the open book. A note or book grant never
    /// does. Always at READ (a gathering holds nothing to write) and never
    /// consuming (its facts and its assembly spend no once grant); every MEMBER
    /// it shows is then decided on its own through `decide`, so the per-note
    /// fence filters it. A FENCED gathering — a 'daily' marker or a Private
    /// stamp, which no op mints on one but a stale row could carry — matches
    /// nothing, the same decision a fenced book gets (the one answer).
    public static func decideGathering(
        client: ClientState?, grants: [Grant], openBook: Bool, gathering: BookFacts
    ) -> Decision {
        switch client {
        case .approved: break
        case .denied: return .refuse(.clientDenied)
        case .pending, nil: return .refuse(.clientPending)
        }
        if let fence = gathering.fence { return .ask(.fenced(fence), offersAlways: false) }
        return decideWing(
            client: client, grants: grants, openBook: openBook, wingID: gathering.wingID, rung: .read)
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
    /// connected — then, AMONG EQUALS, the LEAST capability that suffices
    /// (AF-9, the U2 ladder's O2): the lowest rung first, the narrowest
    /// scope second (note < book < wing), the smaller id last as pure
    /// determinism. F4's amendment made WHICH once grant a write consumes
    /// matter; an id coin-flip could spend a once-write-new grant on a
    /// suggest-level write while a once-suggest grant sat unspent.
    static func best(_ grants: [Grant]) -> Grant? {
        func durationWeight(_ duration: Duration) -> Int {
            switch duration {
            case .always: 2
            case .connection: 1
            case .once: 0
            }
        }
        func scopeWeight(_ kind: ScopeKind) -> Int {
            switch kind {
            case .note: 0
            case .book: 1
            case .wing: 2
            }
        }
        return grants.min { lhs, rhs in
            let ld = durationWeight(lhs.duration), rd = durationWeight(rhs.duration)
            if ld != rd { return ld > rd }
            if lhs.rung != rhs.rung { return lhs.rung < rhs.rung }
            let ls = scopeWeight(lhs.scopeKind), rs = scopeWeight(rhs.scopeKind)
            if ls != rs { return ls < rs }
            return lhs.id < rhs.id
        }
    }
}
