import Foundation
import Testing
@testable import VariorumCore

/// **VX-801 (VX-827 U3a) — the history rail as a value** (THE DESIGN MEMO's
/// Commits face). A PRODUCT row: the suite does not compile on the
/// pre-change tree. It holds her rulings as the rail draws them — ALL TAKES
/// INTERLEAVED by default, newest at the top; the dropdown's one-take filter
/// leading with "the take now"; quiet runs folded with an AI's bracket never
/// folded; archived takes' moments on the line, hollow; the fast swapper's
/// order; and where the face opens (PROVISIONAL, the memo's lean).
@Suite("CommitRail — the history rail as a value (VX-801)")
struct CommitRailTests {
    static let t0 = Date(timeIntervalSince1970: 1_800_000_000)

    static func take(
        _ id: String, _ position: String, status: VariantStatus = .active, label: String? = nil
    ) -> Variant {
        Variant(
            id: id, blockId: "block", workingText: "\(id) now", status: status, label: label,
            fanPosition: position, createdAt: t0, updatedAt: t0)
    }

    static func commit(
        _ id: String, take: String, minute: Double, kind: CommitKind = .manual,
        name: String? = nil
    ) -> CommitPoint {
        CommitPoint(
            id: id, variantId: take, text: "\(id) text", kind: kind, message: name,
            createdAt: t0.addingTimeInterval(minute * 60))
    }

    /// A five-take-like block: plain (focused), spoken, an archived take, with
    /// a quiet run, a deliberate commit on each, and an AI pair on plain.
    static let takes = [
        take("plain", "a0", label: "plain"), take("spoken", "a1", label: "spoken"),
        take("first", "a2", status: .archived, label: "first pass"),
    ]
    static let commits: [String: [CommitPoint]] = [
        "plain": [
            commit("p-after", take: "plain", minute: 100.0001, kind: .auto,
                   name: "after claude-code's edit"),
            commit("p-before", take: "plain", minute: 100, kind: .auto,
                   name: "before claude-code's edit"),
            commit("p-tight", take: "plain", minute: 90, name: "tightened the second clause"),
            commit("p-q2", take: "plain", minute: 50, kind: .auto),
            commit("p-q1", take: "plain", minute: 40, kind: .auto),
            commit("p-first", take: "plain", minute: 10, name: "first shape"),
        ],
        "spoken": [
            commit("s-q", take: "spoken", minute: 45, kind: .auto),
            commit("s-kept", take: "spoken", minute: 80, name: "hearsay, kept"),
        ],
        "first": [commit("f-1", take: "first", minute: 5)],
    ]

    static func ids(_ lines: [CommitRail.Line]) -> [String] { lines.map(\.id) }

    // MARK: - All takes, interleaved (her ruling)

    @Test func allTakesInterleaveNewestFirstWithOneNowLine() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
        // now · the AI pair · plain's tightened · spoken's kept · the quiet
        // run (plain q2 · spoken q · plain q1 — consecutive in time across
        // takes) · plain's first · the archived take's moment.
        #expect(Self.ids(lines) == [
            "now:plain", "p-after", "p-before", "p-tight", "s-kept", "run:p-q2",
            "p-first", "f-1",
        ])
        guard case .quietRun(_, let count, let takeIDs, _, _, let expanded) = lines[5].content
        else { Issue.record("the sixth line is the folded run"); return }
        #expect(count == 3)
        #expect(takeIDs == ["plain", "spoken"], "the run names its takes, fan order")
        #expect(!expanded)
    }

    @Test func theAIPairNeverFoldsAndSharesOneWash() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
        let after = lines[1]
        let before = lines[2]
        #expect(after.bracket == .after(client: "claude-code"))
        #expect(before.bracket == .before(client: "claude-code"))
        #expect(after.pairID != nil && after.pairID == before.pairID, "one edit, one wash")
        #expect(lines[3].pairID == nil, "an ordinary moment rides no wash")
    }

    @Test func aLoneAfterIsItsOwnWash() {
        let commits: [String: [CommitPoint]] = [
            "plain": [Self.commit("a", take: "plain", minute: 9, kind: .auto,
                                  name: "after cursor's edit")],
        ]
        let lines = CommitRail.lines(
            takes: Self.takes, commits: commits, filter: .take("plain"), leadTakeID: nil)
        #expect(lines.last?.pairID == "a")
        #expect(lines.last?.bracket == .after(client: "cursor"))
    }

    @Test func archivedTakesMomentsStayOnTheLineHollow() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
        let archived = lines.first { $0.id == "f-1" }
        #expect(archived?.archivedTake == true)
        #expect(lines.first { $0.id == "p-first" }?.archivedTake == false)
    }

    // MARK: - The dropdown's filter

    @Test func filteringToOneTakeLeadsWithItsNow() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .take("spoken"), leadTakeID: "plain")
        #expect(Self.ids(lines) == ["now:spoken", "s-kept", "s-q"],
                "a lone quiet moment stands as itself")
    }

    @Test func filteringToAnArchivedTakeShowsItsHistory() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .take("first"), leadTakeID: nil)
        #expect(Self.ids(lines) == ["now:first", "f-1"])
        #expect(lines.allSatisfy { $0.archivedTake })
    }

    @Test func aFilterNamingNoTakeShowsNothing() {
        #expect(CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .take("gone"), leadTakeID: nil
        ).isEmpty)
    }

    // MARK: - Opening a run

    @Test func anOpenRunListsItsMembersUnderIt() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain",
            expandedRuns: ["run:p-q2"])
        #expect(Self.ids(lines) == [
            "now:plain", "p-after", "p-before", "p-tight", "s-kept", "run:p-q2",
            "p-q2", "s-q", "p-q1", "p-first", "f-1",
        ])
        if case .commit(_, let takeID, let inRun) = lines[7].content {
            #expect(takeID == "spoken" && inRun)
        } else {
            Issue.record("the run's second member")
        }
    }

    // MARK: - The fast swapper

    @Test func theSwapperStepsThroughWhatShowsAndStopsAtTheEnds() {
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
        let moments = CommitRail.selectable(lines)
        #expect(!moments.contains { if case .commit(let id) = $0 { return id == "p-q2" }; return false },
                "a folded run's members are not on screen, so not selectable")
        #expect(CommitRail.step(.commit(commitID: "p-tight"), by: 1, in: lines)
                == .commit(commitID: "s-kept"), "down is older")
        #expect(CommitRail.step(.commit(commitID: "p-tight"), by: -1, in: lines)
                == .commit(commitID: "p-before"), "up is newer")
        #expect(CommitRail.step(.commit(commitID: "s-kept"), by: 1, in: lines)
                == .commit(commitID: "p-first"), "the run's own line is stepped over")
        #expect(CommitRail.step(.now(takeID: "plain"), by: -1, in: lines)
                == .now(takeID: "plain"), "the top stops")
        #expect(CommitRail.step(.commit(commitID: "f-1"), by: 1, in: lines)
                == .commit(commitID: "f-1"), "the bottom stops")
        #expect(CommitRail.step(.commit(commitID: "gone"), by: 1, in: lines)
                == .now(takeID: "plain"), "a moment no longer shown starts from the top")
    }

    // MARK: - Where the face opens (PROVISIONAL P-U3a-2)

    @Test func theFaceOpensOnTheNewestMomentWhichAfterAnAIEditIsTheAfter() {
        #expect(CommitRail.opening(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
                == .commit(commitID: "p-after"))
        let lines = CommitRail.lines(
            takes: Self.takes, commits: Self.commits, filter: .all, leadTakeID: "plain")
        #expect(CommitRail.step(.commit(commitID: "p-after"), by: 1, in: lines)
                == .commit(commitID: "p-before"), "the before is one step down")
    }

    @Test func aBlockWithNoMomentsOpensOnItsNow() {
        #expect(CommitRail.opening(
            takes: Self.takes, commits: [:], filter: .all, leadTakeID: "spoken")
                == .now(takeID: "spoken"))
    }

    @Test func theNewestMomentInsideAFoldedRunOpensItsRun() {
        let commits: [String: [CommitPoint]] = [
            "plain": [
                Self.commit("q3", take: "plain", minute: 30, kind: .auto),
                Self.commit("q2", take: "plain", minute: 20, kind: .auto),
                Self.commit("m", take: "plain", minute: 10),
            ],
        ]
        let opening = CommitRail.opening(
            takes: Self.takes, commits: commits, filter: .all, leadTakeID: "plain")
        #expect(opening == .commit(commitID: "q3"))
        let hiding = CommitRail.runHiding(
            opening, takes: Self.takes, commits: commits, filter: .all, leadTakeID: "plain",
            expandedRuns: [])
        #expect(hiding == "run:q3")
        #expect(CommitRail.runHiding(
            opening, takes: Self.takes, commits: commits, filter: .all, leadTakeID: "plain",
            expandedRuns: ["run:q3"]) == nil, "already open")
        #expect(CommitRail.runHiding(
            .commit(commitID: "m"), takes: Self.takes, commits: commits, filter: .all,
            leadTakeID: "plain", expandedRuns: []) == nil, "a lone moment shows")
    }

    // MARK: - The lead take and the bracket names

    @Test func theLeadTakeIsTheFocusedOneElseTheFirstActive() {
        #expect(CommitRail.leadTake(Self.takes, focused: "spoken") == "spoken")
        #expect(CommitRail.leadTake(Self.takes, focused: "gone") == "plain")
        let archivedFirst = [Self.take("x", "a0", status: .archived), Self.take("y", "a1")]
        #expect(CommitRail.leadTake(archivedFirst, focused: nil) == "y")
        #expect(CommitRail.leadTake([], focused: nil) == nil)
    }

    /// The rail reads the door's bracket names; a Domain rule does not reach
    /// into the operations layer, so the two spellings are pinned EQUAL here.
    @Test func theBracketNamesAreTheDoorsOwn() {
        let names = Operations.mcpEditCommitNames(client: "claude-code")
        #expect(CommitRail.bracket(Self.commit("b", take: "t", minute: 0, kind: .auto,
                                                name: names.before))
                == .before(client: "claude-code"))
        #expect(CommitRail.bracket(Self.commit("a", take: "t", minute: 0, kind: .auto,
                                                name: names.after))
                == .after(client: "claude-code"))
        #expect(CommitRail.bracket(Self.commit("m", take: "t", minute: 0, kind: .manual,
                                                name: names.before)) == nil,
                "a deliberate commit she named so is hers, not a bracket")
        #expect(CommitRail.bracket(Self.commit("q", take: "t", minute: 0, kind: .auto,
                                                name: "before lunch")) == nil)
        #expect(CommitRail.bracket(Self.commit("u", take: "t", minute: 0, kind: .auto)) == nil)
    }
}
