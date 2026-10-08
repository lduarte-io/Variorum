import Foundation

/// **The quiet-run collapse** (Phase 13j, J11 — the legibility half of her
/// cadence ruling).
///
/// Leaving a note now leaves a quiet savepoint behind, so a history that used
/// to hold a handful of deliberate ⌘S rows will hold many more `kind:'auto'`
/// ones. Her ruling asked for the cadence AND for history that still reads:
/// *"history reads as one row per sitting"*. So a RUN of consecutive quiet
/// savepoints renders as one line she can open — and a deliberate commit is
/// never folded into anything.
///
/// **Pure, and generic over the row type on purpose.** The two history faces
/// hold different values (Write's carries the pre-split warning beside the
/// commit; the Takes sheet holds bare `CommitPoint`s) and show them in
/// different orders (newest-first inline, oldest-first in the sheet). Neither
/// difference belongs in a grouping rule, so this takes the two questions it
/// actually needs — *what identifies this row* and *is it quiet* — and groups
/// CONSECUTIVE quiet rows in whatever order it is handed. Order-agnostic is
/// not an accident: a run is contiguous read either way.
public enum SavepointRuns {
    /// One rendered row, carrying its own identity (a generic `Item` has
    /// none of its own, and both faces need `Identifiable` for `ForEach`).
    public enum Row<Item>: Identifiable {
        /// A deliberate savepoint — or a quiet one too short to collapse.
        case single(Item, id: String)
        /// `collapseFrom` or more consecutive quiet savepoints, in the order
        /// given. The id is the FIRST member's, so it is stable across
        /// expansion and while the list grows at the other end.
        case quietRun(id: String, items: [Item])

        public var id: String {
            switch self {
            case .single(_, let id): return id
            case .quietRun(let id, _): return "run:" + id
            }
        }

        /// What this row stands for: one item, or the whole run — what a
        /// face renders when the run is expanded.
        public var items: [Item] {
            switch self {
            case .single(let item, _): return [item]
            case .quietRun(_, let items): return items
            }
        }

        /// How many savepoints the collapsed line stands for; nil for a
        /// single row.
        public var runCount: Int? {
            switch self {
            case .single: return nil
            case .quietRun(_, let items): return items.count
            }
        }
    }

    /// **A single quiet savepoint never collapses.** "1 quiet savepoint —
    /// show" would be a line hiding one line behind a click; the run begins
    /// at two. (A build-time call, recorded at QUESTIONS #70.)
    public static let collapseFrom = 2

    /// The grouping: consecutive quiet items become one run; everything else
    /// stands alone.
    public static func rows<Item>(
        _ items: [Item], isQuiet: (Item) -> Bool, id: (Item) -> String
    ) -> [Row<Item>] {
        var rows: [Row<Item>] = []
        var run: [Item] = []

        func flushRun() {
            guard !run.isEmpty else { return }
            if run.count >= collapseFrom {
                rows.append(.quietRun(id: id(run[0]), items: run))
            } else {
                // Below the threshold a quiet savepoint renders as itself —
                // still quiet in the face's styling, just not hidden.
                rows.append(contentsOf: run.map { Row.single($0, id: id($0)) })
            }
            run = []
        }

        for item in items {
            if isQuiet(item) {
                run.append(item)
            } else {
                flushRun()
                rows.append(.single(item, id: id(item)))
            }
        }
        flushRun()
        return rows
    }

    // MARK: - The words

    /// The collapsed line, e.g. *"3 quiet commits"*. The verb beside it
    /// ("show" / "hide") is the face's, because only the face knows which way
    /// the row is currently open.
    ///
    /// 13s-b U4 (her R-13s-31, *"I want that changed everywhere"*): the
    /// user-facing word is COMMIT — this line was "N quiet savepoints". The
    /// type and its name keep the old word: code names are not the product's.
    public static func runLabel(count: Int) -> String {
        "\(count) quiet commit\(count == 1 ? "" : "s")"
    }

    public static let showVerb = "show"
    public static let hideVerb = "hide"

    /// What a quiet savepoint IS, said once — the help both faces hang on the
    /// collapsed row.
    public static let runHelp =
        "Commits Variorum made for you \u{2014} one per changed take each time "
        + "you left this note, plus the idle backstop. Settings \u{25b8} Writing "
        + "sets how often. \u{2318}S commits are never folded in here."
}
