//
//  LandingAuthority.swift
//  Variorum (Mac) — Surface (the surface authorities' home, beside
//  `BookHeightManifest`, `ProseHeightModel` and `PaneTextAuthority`)
//
//  **Phase 13u2b UNIT 2 — ONE landing authority.**
//
//  The binding design record is `notes/plans/navigation-landing-architecture-trace.md`
//  §3 and §5(c): *"The Outline's discipline was hand-copied into the flow and
//  half-exists in Takes and Index. Hoist the aim/hold/quiet/hop brain to one
//  home … parameterized per surface, with the DEBUG story built in — so the
//  next surface cannot fork the discipline, and a Release-safe, content-free
//  signpost variant of the landing story ships with it."* Four hand-tuned
//  copies existed when that was written; this file is the one they collapse
//  into, and **this phase converts TWO of them** (the book Outline and the
//  reading flow). Takes and the book Index adopt at their next touch — their
//  ~15 timing pins and `KnownIssuesAndTechDebt` row 49's residues are owner
//  12's, and four surfaces in one phase is the over-scope the sizing guidance
//  names.
//
//  **What a landing IS, in one paragraph** (the row-53 discipline, which is
//  the thing being hoisted): put an anchor at the top of a page with ONE
//  unanimated scroll, then watch. Every geometry report and every change in
//  the column's content height re-arms a short QUIET interval; when the
//  interval passes with the target at the top — and the MINIMUM HOLD is over,
//  because the rows around it load their heights asynchronously — the landing
//  is done. When it passes with the target away from the top, the landing
//  CORRECTS once, against a layout that has had the interval to settle, and
//  waits again. A CEILING on the re-arm keeps a busy column from starving the
//  check forever; a WATCHDOG ends a landing that will not settle rather than
//  chasing the page for the rest of the session; and a scroll of her own ends
//  it at once, because the one thing a landing must never do is fight her
//  hand.
//
//  **The decision is PURE** (`LandingSettle.decide`) — given the target's last
//  reported top, the corrections spent, the time elapsed and whether the
//  surface says it may finish, it answers done / give up / correct / look
//  again in N seconds. That is what makes the discipline testable without a
//  window, and it is where the two surfaces' differences live as POLICY
//  rather than as two copies of a loop.
//
//  **P-9:** this authority is ONE concern — aim and settle. It does not own
//  board layout, text authority, or manifest arithmetic; the facts it prints
//  about a column are handed IN (`LandingFacts`), and what a row is tall is
//  `BookHeightManifest`'s question, never this file's.
//

import CoreGraphics
import Foundation
import os

// MARK: - The policy (what differs between two surfaces, stated once)

/// After a CORRECTION, how long before the authority looks again.
nonisolated enum LandingCorrectionPace: Equatable {
    /// The quiet interval. The book Outline's: its corrections are cheap and
    /// its budget generous, so it converges fast and the watchdog is the
    /// real fence.
    case quiet
    /// The rest of the minimum hold, never less than the quiet interval. The
    /// reading flow's, and it is the whole lesson of ledger row 100: a
    /// correction issued from inside a content storm is UNDONE (SwiftUI's
    /// `ScrollView` re-applies its own offset on a content-size change), so
    /// with a small budget each correction must be issued from quiet or all
    /// of them are spent on 2-pt drifts.
    case spacedByTheHold
}

/// **The surfaces that have adopted the authority.** A closed type, and that
/// is load-bearing rather than tidy: the signpost's vocabulary is exactly
/// this plus integers (`LandingSignpost.isContentFree`), so a surface that
/// joins must add a case here and cannot smuggle a name into the line.
nonisolated enum LandingSurface: String, Equatable, CaseIterable {
    case bookOutline = "BookOutline"
    case readingFlow = "ReadingFlow"
}

nonisolated struct LandingPolicy: Equatable {
    /// The surface's name in the story and the signpost.
    var surface: LandingSurface
    /// Within this many points of the top, a landing is DONE.
    var tolerance: CGFloat
    /// The quiet interval: this long with no event — no anchor report, no
    /// change in the column's content height, no correction — decides the
    /// landing. Long enough for the layout to absorb a size change before
    /// the next look reads it.
    var settleInterval: TimeInterval
    /// The minimum hold: a landing may not finish before this much time has
    /// passed, however quiet the column looks. The rows a landing realizes
    /// load their heights ASYNCHRONOUSLY (a DB read, then a projection fill),
    /// and a quiet interval alone races that load.
    var minimumHold: TimeInterval
    /// The ceiling on waiting: an EVENT re-arm runs no later than this after
    /// the landing's last decision, however busy the column is. Without it a
    /// column that re-reports forever starves the check and the landing
    /// neither corrects nor finishes.
    var maxWait: TimeInterval
    /// The most corrections one landing may make.
    var correctionBudget: Int
    /// The watchdog: a landing older than this stops wherever it is.
    var timeBudget: TimeInterval
    var correctionPace: LandingCorrectionPace
    /// May a correction be spent on a target that has never REPORTED?
    ///
    /// The book Outline says yes — that is how it reached a row a lazy
    /// container had never built, and it costs nothing now that every row
    /// exists. The reading flow says no, deliberately: every row there is a
    /// direct child whose position is known, so an unreported target means
    /// the page did not move, and row 100's measurement is that corrections
    /// issued blind are the instability rather than the cure.
    var correctsAnUnreportedTarget: Bool
    /// **The surface's own word for a correction, in the DEBUG story.** A
    /// shared authority would naturally print one word; these two are kept
    /// because the suites READ them — the flow's `aRevealOfTheTwelfthStory…`
    /// bounds its re-lands by counting lines that start `RE-LAND`, and a
    /// hoist that renamed them would have left that count permanently zero
    /// and the assertion unable to fail (the deleted-incrementer class). The
    /// word costs one field and keeps two pins honest; a surface that adopts
    /// later picks whichever word its own story already says.
    var correctionWord: String

    /// **The book Outline's** (13u2 row 53, measured and re-measured; the
    /// numbers are unchanged by this hoist — only their address moved).
    static let bookOutline = LandingPolicy(
        surface: .bookOutline, tolerance: 2, settleInterval: 0.25, minimumHold: 1.0,
        maxWait: 0.6, correctionBudget: 40, timeBudget: 4,
        correctionPace: .quiet, correctsAnUnreportedTarget: true,
        correctionWord: "HOP")

    /// **The reading flow's** (batch H + 13u2 UNIT A's row-100 fix; likewise
    /// unchanged). Its tolerance is 4 rather than 2 for a measured reason
    /// (ladder R2-7: at 2 pt the finisher re-landed on 3-pt drifts the pins
    /// would have accepted, and a book of many short notes could exhaust the
    /// budget on drifts).
    static let readingFlow = LandingPolicy(
        surface: .readingFlow, tolerance: 4, settleInterval: 0.25, minimumHold: 1.0,
        maxWait: 0.6, correctionBudget: 6, timeBudget: 4,
        correctionPace: .spacedByTheHold, correctsAnUnreportedTarget: false,
        correctionWord: "RE-LAND")

    /// How long after a decision the next look runs.
    func pause(elapsed: TimeInterval) -> TimeInterval {
        switch correctionPace {
        case .quiet: settleInterval
        case .spacedByTheHold: max(settleInterval, minimumHold - elapsed)
        }
    }
}

// MARK: - The decision, pure

nonisolated enum LandingDecision: Equatable {
    case done(top: CGFloat)
    case giveUp(top: CGFloat?)
    case correct
    case wait(TimeInterval)
}

nonisolated enum LandingSettle {
    /// **The quiet interval passed — what now?** Pure, so the discipline is
    /// pinnable without a window.
    ///
    /// - `top`: the target's last reported top, nil while it has never
    ///   reported (a row that has not MOVED has nothing to report, which is
    ///   why the authority seeds this from what every row last said).
    /// - `mayFinish`: the surface's own veto. The flow's is *"every near
    ///   story above the target has said it settled"* — geometry, never a
    ///   clock. The Outline has none.
    static func decide(
        top: CGFloat?, corrections: Int, elapsed: TimeInterval,
        mayFinish: Bool, policy: LandingPolicy
    ) -> LandingDecision {
        if let top, abs(top) <= policy.tolerance {
            if elapsed >= policy.minimumHold, mayFinish { return .done(top: top) }
            // At the top and waiting — for the hold, or (past it) for the
            // surface's own word that the rows above have stopped moving.
            return .wait(elapsed < policy.minimumHold
                ? policy.minimumHold - elapsed
                : policy.settleInterval)
        }
        if elapsed > policy.timeBudget { return .giveUp(top: top) }
        let mayCorrect = corrections < policy.correctionBudget
            && (top != nil || policy.correctsAnUnreportedTarget)
        return mayCorrect ? .correct : .wait(policy.pause(elapsed: elapsed))
    }

    /// The delay before the next look after an EVENT (a report, a content
    /// change): the quiet interval, capped by the ceiling measured from the
    /// landing's last decision. Identical on both surfaces before this hoist,
    /// and it stays one line.
    static func eventDelay(sinceDecision: TimeInterval, policy: LandingPolicy) -> TimeInterval {
        min(policy.settleInterval, max(0.01, policy.maxWait - sinceDecision))
    }
}

// MARK: - The facts a landing can state about its column

/// **What the column KNOWS about this landing, as numbers** — handed in by
/// the surface from its height manifest, printed in the story and in the
/// Release signpost. Nothing here is text: an index, points, counts.
nonisolated struct LandingFacts: Equatable {
    /// Rows in the column.
    var rows: Int = 0
    /// The target's position in the column, 0-based; −1 when the manifest
    /// does not know the row.
    var targetIndex: Int = -1
    /// The target's computed top in the column's content space; −1 unknown.
    var offset: CGFloat = -1
    /// The column's whole computed content height.
    var total: CGFloat = 0
    /// How many rows still stand on ARITHMETIC rather than on a height the
    /// column measured or remembers. This is the number that should fall to
    /// zero as a book is read, and the one that explains a shift.
    var derived: Int = 0
    /// Nothing above the target is arithmetic — so nothing above it can move
    /// it, and the compensator has nothing to catch.
    var exactAbove: Bool = false

    init(
        rows: Int = 0, targetIndex: Int = -1, offset: CGFloat = -1,
        total: CGFloat = 0, derived: Int = 0, exactAbove: Bool = false
    ) {
        self.rows = rows
        self.targetIndex = targetIndex
        self.offset = offset
        self.total = total
        self.derived = derived
        self.exactAbove = exactAbove
    }

    /// The facts a `BookHeightManifest` states about one anchor.
    init(manifest: BookHeightManifest, anchor: String) {
        self.init(
            rows: manifest.rows.count,
            targetIndex: manifest.rows.firstIndex { $0.id == anchor } ?? -1,
            offset: manifest.offset(of: anchor) ?? -1,
            total: manifest.totalHeight,
            derived: manifest.derivedCount,
            exactAbove: manifest.isExactAbove(anchor))
    }
}

/// How a landing ended — a fixed word, so the signpost stays content-free.
nonisolated enum LandingOutcome: String, Equatable, CaseIterable {
    case settled
    case gaveup
    case handedover
}

// MARK: - The SIGNPOST (content-free, and it ships in Release)

/// **The landing story she can read from her own machine.**
///
/// The architectural trace's §5(c), verbatim: *"That signpost is also the
/// answer to 'her store reproduces what mine cannot': the next report she
/// files carries the trace."* The dev store could not be made to reproduce her
/// stutter regime (trace §4) — her window widths, her expansion set, her
/// remembered heights select it — so the surfaces now SAY what they did, in
/// numbers, in the shipping build.
///
/// **The content-free rule, and it is absolute:** every value in this line is
/// a number or a word from a fixed vocabulary. Never a title, never prose,
/// never an id — not because an id is prose, but because the line is written
/// to be pasted into a report without anyone having to read it first and
/// decide. The target is named by its INDEX in the column. Pinned:
/// `LandingSignpostTests`.
nonisolated enum LandingSignpost {
    /// The line, built from numbers alone.
    static func line(
        surface: LandingSurface, facts: LandingFacts, corrections: Int,
        contentMoves: Int, elapsed: TimeInterval,
        outcome: LandingOutcome, top: CGFloat?
    ) -> String {
        "landing surface=\(surface.rawValue)"
            + " rows=\(facts.rows) target=\(facts.targetIndex)"
            + " offset=\(Int(facts.offset.rounded())) total=\(Int(facts.total.rounded()))"
            + " derived=\(facts.derived) exact=\(facts.exactAbove ? 1 : 0)"
            + " hops=\(corrections) content=\(contentMoves)"
            + " ms=\(Int((elapsed * 1000).rounded()))"
            + " end=\(outcome.rawValue) top=\(top.map { Int($0.rounded()) } ?? -9999)"
    }

    /// **The proof, as a function rather than as a promise.** A line is
    /// content-free when it is the word `landing` followed by `key=value`
    /// pairs in which EVERY value is an integer, except `surface` (a
    /// `LandingSurface` case) and `end` (a `LandingOutcome` case). A
    /// character-class check would not do: a note's title is letters and
    /// spaces and would pass one. Pinned against a book, a chapter and a note
    /// whose names are prose.
    static func isContentFree(_ line: String) -> Bool {
        let tokens = line.split(separator: " ")
        guard tokens.first == "landing", tokens.count > 1 else { return false }
        for token in tokens.dropFirst() {
            let pair = token.split(separator: "=", maxSplits: 1)
            guard pair.count == 2 else { return false }
            switch pair[0] {
            case "surface":
                guard LandingSurface(rawValue: String(pair[1])) != nil else { return false }
            case "end":
                guard LandingOutcome(rawValue: String(pair[1])) != nil else { return false }
            default:
                guard Int(pair[1]) != nil else { return false }
            }
        }
        return true
    }
}

// MARK: - The runner

#if DEBUG
/// The verbose DEBUG story's two ends: where a line goes, and how the whole
/// story is read back when the landing finishes. Both belong to the SURFACE
/// (its own oracle — `BookOutlineGeometry.trace`, `ReadingFlowGeometry.trace`),
/// so every pin that reads those keeps reading exactly what it read before
/// this hoist, and the walk's `log show` story keeps the surface's own extra
/// lines (a row's height, a scroll phase, the manifest's own line) that the
/// authority never writes.
@MainActor
struct LandingStoryboard {
    var note: (String) -> Void
    var dump: () -> String
}
#endif

/// **The one pending landing, on any surface.**
@MainActor
final class LandingAuthority {
    let policy: LandingPolicy

    /// Where every row last said it was. **This is not a convenience — it is
    /// what makes a landing on the row the page is ALREADY at terminate.**
    ///
    /// Found on 13u2b UNIT 1's dev-store walk of the Outline (`gave up at
    /// top=unrealized after 15 hops, 4200 ms`, three times) and measured again
    /// on the reading flow at UNIT 2 before a line of this file was written
    /// (`gave up at top=unreported after 0 re-lands, 4211 ms`, 2/2): a landing
    /// learns where its target is from geometry reports, and
    /// `onGeometryChange` reports a CHANGE — so when the scroll moves nothing,
    /// no report arrives and the loop reads that as "the target never
    /// realized". Nothing moves on screen; there is a landing spinning for
    /// four seconds with her own scroll fighting it. Seeding from what the
    /// row last said ends it at the hold instead. Every adopting surface gets
    /// this for free, which is most of the argument for one authority.
    private var tops: [String: CGFloat] = [:]

    private(set) var anchor: String?
    private var facts = LandingFacts()
    private var began = Date()
    private var lastDecision = Date()
    private(set) var corrections = 0
    private(set) var lastTop: CGFloat?
    /// How many times the column's content height moved during this landing —
    /// the stutter's own driver, and a number worth having in her report.
    private var contentMoves = 0
    private var check: DispatchWorkItem?
    private var aim: ((String) -> Void)?
    private var mayFinish: () -> Bool = { true }

    #if DEBUG
    private let storyboard: LandingStoryboard?
    #endif

    private static let log = Logger(subsystem: "io.lduarte.Variorum", category: "landing")

    #if DEBUG
    init(policy: LandingPolicy, storyboard: LandingStoryboard? = nil) {
        self.policy = policy
        self.storyboard = storyboard
    }
    #else
    init(policy: LandingPolicy) {
        self.policy = policy
    }
    #endif

    var isPending: Bool { anchor != nil }

    /// **Put this anchor at the top of the page, and watch it settle.**
    ///
    /// - `aim`: the surface's one act — an UNANIMATED `scrollTo(id, anchor:
    ///   .top)`. Never animated: an animation travels toward an ESTIMATED
    ///   offset while rows realize under it (row 44's class).
    /// - `facts`: what the column's manifest knows about this landing.
    /// - `mayFinish`: the surface's veto, re-taken at every look.
    func land(
        _ anchorID: String, facts: LandingFacts = LandingFacts(),
        mayFinish: @escaping () -> Bool = { true },
        aim: @escaping (String) -> Void
    ) {
        check?.cancel()
        self.anchor = anchorID
        self.facts = facts
        self.aim = aim
        self.mayFinish = mayFinish
        corrections = 0
        contentMoves = 0
        began = Date()
        lastDecision = Date()
        // The seed (see `tops`).
        lastTop = tops[anchorID]
        #if DEBUG
        storyboard?.note("\(anchorID) LAND")
        if facts.rows > 0 {
            storyboard?.note(
                "manifest rows=\(facts.rows) target=\(facts.targetIndex) "
                + "offset=\(Int(facts.offset.rounded())) total=\(Int(facts.total.rounded())) "
                + "derived=\(facts.derived) exactAbove=\(facts.exactAbove ? "Y" : "N")")
        }
        #endif
        aim(anchorID)
        armAfterEvent()
    }

    /// A row reported where its top sits. Recorded for every row (the seed);
    /// for the pending TARGET it also re-arms the quiet interval — the
    /// decision is the interval's, never the report's (row 53, and row 100's
    /// measurement that a correction issued from a report is undone).
    func noteTop(_ anchorID: String, _ top: CGFloat) {
        tops[anchorID] = top
        guard anchorID == anchor else { return }
        lastTop = top
        armAfterEvent()
    }

    /// The column's content height changed (a row loaded its text, a story
    /// its editor): the layout is still settling, whatever the target last
    /// said.
    func contentChanged(_ height: CGFloat) {
        guard isPending else { return }
        contentMoves += 1
        #if DEBUG
        storyboard?.note("content=\(Int(height))")
        #endif
        armAfterEvent()
    }

    /// **An event the authority cannot see for itself** — something the
    /// surface knows can still move the page. The flow's is a story's surface
    /// SETTLING (`StableSurface.settled`: it held one real size, adopted it
    /// and dropped its reservation). Re-arms the quiet interval; the decision
    /// stays the interval's, exactly as for a report.
    func nudge() {
        guard isPending else { return }
        armAfterEvent()
    }

    /// She scrolled: the landing ends where she put the page.
    func userTookOver() {
        guard isPending else { return }
        finish(.handedover, why: "the user scrolled")
    }

    /// The surface is going away mid-landing — end it rather than letting its
    /// check re-arm against a dead proxy (ladder R2-12's class).
    ///
    /// **SILENT, deliberately:** nothing landed and the surface is gone, so
    /// there is no story to tell and no signpost to file. R2-12's own pin
    /// asserts exactly this — a flow torn down mid-landing must leave no
    /// `DONE` for the next flow to read.
    func end() {
        check?.cancel()
        check = nil
        anchor = nil
        aim = nil
        mayFinish = { true }
    }

    // MARK: - The loop

    private func armAfterEvent() {
        arm(after: LandingSettle.eventDelay(
            sinceDecision: Date().timeIntervalSince(lastDecision), policy: policy))
    }

    private func arm(after delay: TimeInterval) {
        check?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.look() }
        check = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    private func look() {
        guard let anchor else { return }
        let elapsed = Date().timeIntervalSince(began)
        switch LandingSettle.decide(
            top: lastTop, corrections: corrections, elapsed: elapsed,
            mayFinish: mayFinish(), policy: policy
        ) {
        case .done(let top):
            finish(.settled, why: "settled at top=\(top) after \(corrections) hops, \(Int(elapsed * 1000)) ms")
        case .giveUp(let top):
            // **"unrealized" is the word, on BOTH surfaces** — the book
            // Outline's, kept because its own pin asserts a settled landing
            // never says it (`landingAgainOnTheRowThePageIsAlreadyAt…`). A
            // hoist that quietly renamed it to the flow's "unreported" would
            // have left that assertion unable to fail, which is the
            // deleted-incrementer class this repo refuses.
            finish(.gaveup, why: "gave up at top=\(top.map { "\($0)" } ?? "unrealized") "
                + "after \(corrections) hops, \(Int(elapsed * 1000)) ms")
        case .correct:
            corrections += 1
            lastDecision = Date()
            #if DEBUG
            storyboard?.note("\(policy.correctionWord) \(corrections) at \(Int(elapsed * 1000)) ms"
                + (lastTop.map { " (top was \($0))" } ?? " (unreported)"))
            #endif
            aim?(anchor)
            // A correction that moves nothing produces no report — the
            // interval decides again.
            arm(after: policy.pause(elapsed: elapsed))
        case .wait(let delay):
            lastDecision = Date()
            arm(after: delay)
        }
    }

    private func finish(_ outcome: LandingOutcome, why: String) {
        let elapsed = Date().timeIntervalSince(began)
        #if DEBUG
        if anchor != nil {
            storyboard?.note("\(anchor ?? "") DONE: \(why)")
            if let dump = storyboard?.dump() {
                // The dev build's verbose story, readable from outside the
                // process: `log show --process Variorum --predicate
                // 'eventMessage CONTAINS "\(policy.surface) landing"'`.
                NSLog("%@ landing — %@", policy.surface.rawValue, dump)
            }
        }
        #endif
        // **THE SIGNPOST — this one SHIPS.** Content-free by construction
        // (`LandingSignpost`), emitted for every surface that adopts this
        // authority, so a landing in her own store can be read back from
        // Console instead of reproduced.
        if anchor != nil {
            let line = LandingSignpost.line(
                surface: policy.surface, facts: facts, corrections: corrections,
                contentMoves: contentMoves, elapsed: elapsed, outcome: outcome, top: lastTop)
            Self.log.notice("\(line, privacy: .public)")
        }
        check?.cancel()
        check = nil
        anchor = nil
        aim = nil
        mayFinish = { true }
    }
}
