import Foundation

/// **THE HISTORY RAIL, AS A VALUE** (VX-801 — THE DESIGN MEMO's Commits face,
/// `notes/plans/fixes/vx-827-lineage.md`).
///
/// The face is one reading pane and one rail. The rail is B's vertical dot
/// timeline, newest at the top, and by her ruling it opens on ALL TAKES
/// INTERLEAVED — *"i think that showing all takes on one line is better -
/// sometimes multiple takes will have changed in a single pass round"*. The
/// take dropdown FILTERS it to one take, whose rail then leads with the hollow
/// "the take now" dot. Quiet runs fold to one line; an AI's before/after
/// bracket (`Operations.mcpEditCommitNames`) rides a quiet wash and NEVER
/// folds; archived takes' moments stay on the line (hollow dots).
///
/// Everything the face decides about the rail is here, pure, so a pin holds
/// the decision without rendering anything (the `SavepointRuns` precedent —
/// the fold itself IS `SavepointRuns`, unchanged): the lines, which of them a
/// press (or ↑/↓ — the fast swapper) can select, where the face opens, and
/// which run must open so the opening moment shows.
///
/// P1: a projection over ONE block's own takes and commits — the cost is the
/// block's own history, never the note's or the corpus's.
public enum CommitRail {
    /// What the rail shows: every take interleaved (the default), or one.
    public enum Filter: Hashable, Sendable {
        case all
        case take(String)
    }

    /// **What the reading pane can show** — a take as it stands now, or one
    /// saved moment. The swapper steps between these.
    public enum Moment: Hashable, Sendable {
        case now(takeID: String)
        case commit(commitID: String)
    }

    /// An AI client's bracket around its edit (R-13n-7's "before/after
    /// ‹client›'s edit" — the door's insurance commits).
    public enum Bracket: Equatable, Sendable {
        case before(client: String)
        case after(client: String)

        public var client: String {
            switch self {
            case .before(let client), .after(let client): return client
            }
        }
    }

    /// **Is this commit one half of an AI's bracket?** Read off the names the
    /// MCP door gives them (`Operations.mcpEditCommitNames` — "before
    /// ‹client›'s edit" / "after ‹client›'s edit"; `CommitRailTests` pins the
    /// two spellings equal, since a Domain rule does not reach up into the
    /// operations layer) on a QUIET commit — the occasion is insurance-class,
    /// always `kind = 'auto'`. A name she typed on a deliberate commit is never
    /// mistaken for one.
    public static func bracket(_ commit: CommitPoint) -> Bracket? {
        guard commit.kind == .auto, let name = SavepointName.normalized(commit.message),
              name.hasSuffix(bracketTail) else { return nil }
        let body = name.dropLast(bracketTail.count)
        if body.hasPrefix(beforeHead) {
            let client = String(body.dropFirst(beforeHead.count))
            return client.isEmpty ? nil : .before(client: client)
        }
        if body.hasPrefix(afterHead) {
            let client = String(body.dropFirst(afterHead.count))
            return client.isEmpty ? nil : .after(client: client)
        }
        return nil
    }

    static let beforeHead = "before "
    static let afterHead = "after "
    static let bracketTail = "'s edit"

    /// One line of the rail.
    public struct Line: Equatable, Sendable, Identifiable {
        public enum Content: Equatable, Sendable {
            /// The take as it stands now — the hollow ring.
            case now(takeID: String)
            /// One saved moment. `inRun` marks a member drawn under its open
            /// quiet run.
            case commit(CommitPoint, takeID: String, inRun: Bool)
            /// A folded (or opened) run of quiet moments: how many, which
            /// takes they belong to (fan order), and the span they cover.
            case quietRun(
                id: String, count: Int, takeIDs: [String], newest: Date, oldest: Date,
                expanded: Bool)
        }

        public let content: Content
        /// The AI bracket this moment is half of, if any.
        public let bracket: Bracket?
        /// Lines of ONE AI edit share this id (after above before) — the
        /// quiet wash spans them; nil for every other line.
        public let pairID: String?
        /// The moment of an ARCHIVED take — drawn hollow.
        public let archivedTake: Bool

        public init(
            content: Content, bracket: Bracket? = nil, pairID: String? = nil,
            archivedTake: Bool = false
        ) {
            self.content = content
            self.bracket = bracket
            self.pairID = pairID
            self.archivedTake = archivedTake
        }

        public var id: String {
            switch content {
            case .now(let takeID): return "now:" + takeID
            case .commit(let commit, _, _): return commit.id
            case .quietRun(let id, _, _, _, _, _): return id
            }
        }

        /// What selecting this line shows in the pane; nil for a run's own
        /// line (it opens and closes, it is not a moment).
        public var moment: Moment? {
            switch content {
            case .now(let takeID): return .now(takeID: takeID)
            case .commit(let commit, _, _): return .commit(commitID: commit.id)
            case .quietRun: return nil
            }
        }
    }

    /// **The take the all-takes rail's "now" line names** (PROVISIONAL
    /// P-U3a-1 — exploration A's one "now" line, the take she came from): the
    /// focused take where it is still one of the block's takes, else the
    /// first ACTIVE take, else the first take. nil only for a takeless block.
    public static func leadTake(_ takes: [Variant], focused: String?) -> String? {
        if let focused, takes.contains(where: { $0.id == focused }) { return focused }
        return takes.first { $0.status == .active }?.id ?? takes.first?.id
    }

    /// **The rail's lines**, newest at the top.
    ///
    /// - `takes` — the block's live takes in fan order, archived included
    ///   (`Queries.BlockHistory.takes`).
    /// - `commits` — each take's moments (any order; sorted here by
    ///   `(created_at, id)`, AppSpec §7's commit order, newest first).
    /// - `filter` — all takes interleaved, or one take.
    /// - `leadTakeID` — the all-takes "now" line's take (`leadTake`).
    /// - `expandedRuns` — the runs she opened (`Line.id` of the run).
    public static func lines(
        takes: [Variant], commits: [String: [CommitPoint]], filter: Filter,
        leadTakeID: String?, expandedRuns: Set<String> = []
    ) -> [Line] {
        let archived = Set(takes.filter { $0.status == .archived }.map(\.id))
        let fanOrder = Dictionary(uniqueKeysWithValues: takes.enumerated().map { ($1.id, $0) })

        let shownTakes: [String]
        let nowTake: String?
        switch filter {
        case .all:
            shownTakes = takes.map(\.id)
            nowTake = leadTakeID.flatMap { id in takes.contains { $0.id == id } ? id : nil }
                ?? leadTake(takes, focused: nil)
        case .take(let id):
            shownTakes = takes.contains { $0.id == id } ? [id] : []
            nowTake = shownTakes.first
        }

        struct Entry {
            let commit: CommitPoint
            let takeID: String
            let bracket: Bracket?
        }
        var entries: [Entry] = []
        for takeID in shownTakes {
            for commit in commits[takeID] ?? [] {
                entries.append(Entry(commit: commit, takeID: takeID, bracket: bracket(commit)))
            }
        }
        entries.sort {
            $0.commit.createdAt != $1.commit.createdAt
                ? $0.commit.createdAt > $1.commit.createdAt
                : $0.commit.id > $1.commit.id
        }

        // The AI pairs: an "after" directly above its own "before" (same take,
        // same client) is one edit; a bracket standing alone is its own.
        var pairOf: [String: String] = [:]
        var index = 0
        while index < entries.count {
            let entry = entries[index]
            guard let bracket = entry.bracket else {
                index += 1
                continue
            }
            if case .after(let client) = bracket, index + 1 < entries.count,
               let next = entries[index + 1].bracket, next == .before(client: client),
               entries[index + 1].takeID == entry.takeID {
                pairOf[entry.commit.id] = entry.commit.id
                pairOf[entries[index + 1].commit.id] = entry.commit.id
                index += 2
            } else {
                pairOf[entry.commit.id] = entry.commit.id
                index += 1
            }
        }

        var out: [Line] = []
        if let nowTake {
            out.append(Line(content: .now(takeID: nowTake), archivedTake: archived.contains(nowTake)))
        }
        // The fold is `SavepointRuns`' own, with ONE amendment: an AI bracket
        // is never quiet for folding — it is what she came to see.
        let rows = SavepointRuns.rows(
            entries, isQuiet: { $0.commit.kind == .auto && $0.bracket == nil },
            id: { $0.commit.id })
        for row in rows {
            switch row {
            case .single(let entry, _):
                out.append(Line(
                    content: .commit(entry.commit, takeID: entry.takeID, inRun: false),
                    bracket: entry.bracket, pairID: pairOf[entry.commit.id],
                    archivedTake: archived.contains(entry.takeID)))
            case .quietRun(_, let members):
                let open = expandedRuns.contains(row.id)
                var takeIDs: [String] = []
                for member in members where !takeIDs.contains(member.takeID) {
                    takeIDs.append(member.takeID)
                }
                takeIDs.sort { (fanOrder[$0] ?? 0) < (fanOrder[$1] ?? 0) }
                out.append(Line(
                    content: .quietRun(
                        id: row.id, count: members.count, takeIDs: takeIDs,
                        newest: members.first?.commit.createdAt ?? .distantPast,
                        oldest: members.last?.commit.createdAt ?? .distantPast,
                        expanded: open),
                    archivedTake: takeIDs.allSatisfy { archived.contains($0) }))
                if open {
                    for member in members {
                        out.append(Line(
                            content: .commit(member.commit, takeID: member.takeID, inRun: true),
                            archivedTake: archived.contains(member.takeID)))
                    }
                }
            }
        }
        return out
    }

    /// The moments a press or the swapper can land on, top to bottom (a
    /// folded run's members are not on screen, so they are not among them).
    public static func selectable(_ lines: [Line]) -> [Moment] {
        lines.compactMap(\.moment)
    }

    /// **The fast swapper** (her ruling — *"you should be able to preview or
    /// scroll through the commit text without opening a named commit… maybe a
    /// fast swapper would be enough"*): the moment `by` steps from `current`
    /// among the selectable lines — negative is UP (newer), positive DOWN
    /// (older). It stops at the ends rather than wrapping; a `current` no
    /// longer on the rail starts from the top.
    public static func step(_ current: Moment?, by offset: Int, in lines: [Line]) -> Moment? {
        let moments = selectable(lines)
        guard !moments.isEmpty else { return nil }
        guard let current, let at = moments.firstIndex(of: current) else {
            return moments.first
        }
        return moments[min(max(at + offset, 0), moments.count - 1)]
    }

    /// **Where the face opens** (PROVISIONAL P-U3a-2, THE DESIGN MEMO's lean:
    /// "open on the newest moment (after an AI edit that IS the
    /// after-bracket, the before one step down)"): the newest saved moment
    /// among the shown takes; a block with none opens on its "now".
    public static func opening(
        takes: [Variant], commits: [String: [CommitPoint]], filter: Filter, leadTakeID: String?
    ) -> Moment? {
        // The newest moment may sit inside a folded quiet run, so the
        // commits are read directly rather than off the folded lines.
        var best: CommitPoint?
        for takeID in shownTakeIDs(takes: takes, filter: filter) {
            for commit in commits[takeID] ?? [] {
                if let current = best {
                    if commit.createdAt > current.createdAt
                        || (commit.createdAt == current.createdAt && commit.id > current.id) {
                        best = commit
                    }
                } else {
                    best = commit
                }
            }
        }
        if let best { return .commit(commitID: best.id) }
        return lines(
            takes: takes, commits: commits, filter: filter, leadTakeID: leadTakeID
        ).first?.moment
    }

    /// **The run that must open for `moment` to show**, or nil when it
    /// already shows (it is a "now", a lone commit, or its run is open).
    public static func runHiding(
        _ moment: Moment?, takes: [Variant], commits: [String: [CommitPoint]], filter: Filter,
        leadTakeID: String?, expandedRuns: Set<String>
    ) -> String? {
        guard case .commit(let commitID)? = moment else { return nil }
        let folded = lines(
            takes: takes, commits: commits, filter: filter, leadTakeID: leadTakeID,
            expandedRuns: [])
        guard !folded.contains(where: { $0.id == commitID }) else { return nil }
        // Which run holds it: open each folded run alone and look.
        for line in folded {
            guard case .quietRun(let id, _, _, _, _, _) = line.content,
                  !expandedRuns.contains(id) else { continue }
            let opened = lines(
                takes: takes, commits: commits, filter: filter, leadTakeID: leadTakeID,
                expandedRuns: [id])
            if opened.contains(where: { $0.id == commitID }) { return id }
        }
        return nil
    }

    private static func shownTakeIDs(takes: [Variant], filter: Filter) -> [String] {
        switch filter {
        case .all: return takes.map(\.id)
        case .take(let id): return takes.contains { $0.id == id } ? [id] : []
        }
    }
}
