import Foundation

/// **THE ONBOARDING TOUR'S RULE** (13s-b U2 — mockup v5, approved at R-13s-27,
/// `notes/plans/13s-mockups/onboarding-tour.html`; the plan file's U2 RECORD
/// carries the build-verify resolutions and every PROVISIONAL).
///
/// Coach marks over the REAL app: a ring on the thing to touch (never a dim —
/// R-13s-12), a small card saying one idea, her real click advancing, End tour
/// always there, the step count visible. Thirteen steps since VX-292 U3
/// (R-292-13's approved flow — step 7 has two beats, step 11 three), an end
/// card over the note she just opened, a five-stop "keep going" leg, and
/// both roads ending at the field guide (R-13s-1).
///
/// This file is the tour's WHOLE decision, pure, so every step is walked
/// headlessly (`TourWalkTests` — P-6: the tour is an executable spec, and a step
/// a later phase breaks is a regression by definition). The app reports what is
/// on screen as `Facts`, presses `next` / End tour / the end card's choices as
/// `Event`s, and performs the `Effect`s this hands back; the copy is the app's
/// (`TourScript`), because it names the app's own doors.
///
/// **Off-target clicks are tolerated by construction** (the assessment's B2/B3):
/// a step advances on a FACT about where she is, never on a click it expects,
/// and its ring is a list of candidates of which the first one actually on
/// screen lights — so wandering off re-anchors the ring on the road back
/// (`ringGroups`). Nothing here depends on board state she can mutate: the
/// seeded book and its first story are looked up when the tour starts, and a
/// missing one degrades to "any book" / "any note".
///
/// **The tutorial wins by driving** (VX-292 R-292-11): a note that ARRIVES in
/// a mode its step does not teach in — a remembered Takes or Read winning the
/// note's own memory — is driven to the step's mode, once per arrival
/// (`expectedNoteMode`, `drive`). Wandering is never chased; nothing is
/// erased.
public enum Tour {

    // MARK: - The steps

    public enum Step: String, CaseIterable, Sendable {
        // The main leg (VX-292 U3 — R-292-13's approved flow, thirteen steps):
        // 1–6 as mockup v5; 7 the take flip in two beats (`takesMode`, then
        // `takesFlipBack`); 8 Read in the note; 9 Lenses, live; 10 Compare
        // and Blocks, briefly; 11 the book arc in three beats (`upToBook`,
        // `bookAndRead`, `downAndUp` — R-292-10); 12 home; 13 one of her own.
        case navigation, seededBook, insideBook, write, makeTake, takeIcon
        case takesMode, takesFlipBack, readInNote, lensesLive, deeperModes
        case upToBook, bookAndRead, downAndUp, home, ownNote
        /// "That's the tour." — over the note she just opened (A3).
        case endCard
        // The keep-going leg (R-13s-1's optional leg; Q13's four stops, and
        // VX-292 R-292-8's fifth — the Settings stop) and its end.
        case legStar, legTags, legBook, legSnippets, legSettings, legEnd
    }

    /// The main leg's count, as the cards say it ("Step 1 of 13").
    public static let mainStepCount = 13
    /// The leg's count ("Keep going · 1 of 5").
    public static let legStopCount = 5

    /// Where a card sits in the count — what its small label says.
    public enum Position: Equatable, Sendable {
        /// `number` of `mainStepCount`; `beat` (1-based) is which card of a
        /// step that has more than one (step 7's flip and its way back, step
        /// 11's book arc). The label says the number alone.
        case main(number: Int, beat: Int)
        /// The end card carries no count.
        case endCard
        /// `number` of `legStopCount`.
        case leg(number: Int)
        /// "The end".
        case legEnd
    }

    public static func position(of step: Step) -> Position {
        switch step {
        case .navigation: .main(number: 1, beat: 1)
        case .seededBook: .main(number: 2, beat: 1)
        case .insideBook: .main(number: 3, beat: 1)
        case .write: .main(number: 4, beat: 1)
        case .makeTake: .main(number: 5, beat: 1)
        case .takeIcon: .main(number: 6, beat: 1)
        case .takesMode: .main(number: 7, beat: 1)
        case .takesFlipBack: .main(number: 7, beat: 2)
        case .readInNote: .main(number: 8, beat: 1)
        case .lensesLive: .main(number: 9, beat: 1)
        case .deeperModes: .main(number: 10, beat: 1)
        case .upToBook: .main(number: 11, beat: 1)
        case .bookAndRead: .main(number: 11, beat: 2)
        case .downAndUp: .main(number: 11, beat: 3)
        case .home: .main(number: 12, beat: 1)
        case .ownNote: .main(number: 13, beat: 1)
        case .endCard: .endCard
        case .legStar: .leg(number: 1)
        case .legTags: .leg(number: 2)
        case .legBook: .leg(number: 3)
        case .legSnippets: .leg(number: 4)
        case .legSettings: .leg(number: 5)
        case .legEnd: .legEnd
        }
    }

    /// Whether the card carries a "next" door. The cards that teach without
    /// asking for an act carry it (steps 1, 8, 10, and 11's first beat); every
    /// other card advances on her act. **Leg 4 carries it too (PROVISIONAL
    /// P-U2-4):** its copy asks for no act, and the real app's snippet click
    /// OPENS the snippet — the mockup's ring-click advance would yank her out
    /// of what she opened.
    ///
    /// VX-292 U3: step 7's two beats keep the next step 7 always had (a flip
    /// is offered, never required — PROVISIONAL P-292-8); step 8 is a next
    /// card (Read is visited and its switch shown, PROVISIONAL P-292-9); step
    /// 11's first beat describes the book she arrives in, so it waits for her
    /// next like the step it reworks (`placeFollows`); and the Settings stop
    /// carries next because Settings is its own window (PROVISIONAL P-292-10).
    public static func hasNext(_ step: Step) -> Bool {
        switch step {
        case .navigation, .takesMode, .takesFlipBack, .readInNote, .deeperModes, .upToBook,
             .legSnippets, .legSettings: true
        default: false
        }
    }

    /// Whether the card carries "End tour". Every coach card does (the brief's
    /// "End tour always present"); the end card is the fork itself and offers
    /// its own three ways out.
    public static func hasEndTour(_ step: Step) -> Bool { step != .endCard }

    // MARK: - What the app reports

    /// The sidebar's five places (R44 + Archived).
    public enum Area: String, CaseIterable, Sendable {
        case bookcase, library, pool, snippets, archived
    }

    /// Where the window's focused pane stands.
    public enum Place: Hashable, Sendable {
        case area(Area)
        /// A book or a gathering (a `reading`).
        case book(String)
        /// A note (a post container).
        case note(String)
        /// A snippets group opened in its editor (a pool container).
        case snippetGroup(String)
        /// Anything the tour has no use for (a tag folder, the Trash).
        case elsewhere
    }

    /// A note's mode (the sidebar rail's vocabulary).
    public enum NoteMode: String, CaseIterable, Sendable {
        case write, takes, read, lenses, compare, blocks, canvas
    }

    /// A book's mode (the book masthead's four word-tabs).
    public enum BookMode: String, CaseIterable, Sendable {
        case outline, index, book, read
    }

    /// Write's caret, when Write's editor is the one she is writing in.
    public struct Caret: Equatable, Sendable {
        public var noteID: String
        public var blockID: String
        /// 1-based, current order.
        public var ordinal: Int
        /// The caret block's live takes (1 for an unfanned block).
        public var takeCount: Int
        /// Write's takes panel is up (it is a sheet over the window).
        public var panelOpen: Bool

        public init(
            noteID: String, blockID: String, ordinal: Int, takeCount: Int, panelOpen: Bool = false
        ) {
            self.noteID = noteID
            self.blockID = blockID
            self.ordinal = ordinal
            self.takeCount = takeCount
            self.panelOpen = panelOpen
        }
    }

    /// The store's facts about ONE note — the note the current step is
    /// interested in (`noteOfInterest`): the candidate at step 11, then the
    /// note of her own for the leg.
    public struct NoteFacts: Equatable, Sendable {
        public var noteID: String
        public var starred: Bool
        public var tagCount: Int
        /// Live BOOK memberships (a gathering holds none).
        public var bookCount: Int

        public init(noteID: String, starred: Bool, tagCount: Int, bookCount: Int) {
            self.noteID = noteID
            self.starred = starred
            self.tagCount = tagCount
            self.bookCount = bookCount
        }
    }

    /// **The store's facts about the block step 7 flips** (VX-292 U3 — the
    /// take flip, R-292-3/13: *"choosing the Italian take visibly flips the
    /// page's language"*). The block is the toured paragraph — the one she
    /// made a take of at step 5 — while it carries a fan, else the toured
    /// note's first fanned block (R-292-17's fallback shape;
    /// `Queries.tourFlipFacts`). nil until the store answered, or when the
    /// note carries no fan at all.
    public struct BlockFacts: Equatable, Sendable {
        public var noteID: String
        public var blockID: String
        /// The take the note shows at this block (the placement's chosen,
        /// falling back to the block's default exactly as rendering does).
        public var chosenTakeID: String?
        /// The block's live, active takes, in fan order.
        public var takeIDs: [String]
        /// The take the card NAMES (the Prince's "il principe 1532"), when
        /// the block carries one — the flip's preferred target.
        public var namedTakeID: String?

        public init(
            noteID: String, blockID: String, chosenTakeID: String?, takeIDs: [String],
            namedTakeID: String? = nil
        ) {
            self.noteID = noteID
            self.blockID = blockID
            self.chosenTakeID = chosenTakeID
            self.takeIDs = takeIDs
            self.namedTakeID = namedTakeID
        }
    }

    /// One report of what the window shows.
    public struct Facts: Equatable, Sendable {
        public var place: Place
        /// The focused note's mode (nil unless `place` is a note).
        public var noteMode: NoteMode?
        /// Write's caret (nil unless Write's editor reports one).
        public var caret: Caret?
        /// A book's sidebar note box is LIVE — the "edit here" door took.
        public var bookNoteLive: Bool
        /// A book's sidebar note box HOLDS a note (selected or live) — the
        /// "edit here" door exists (F-U2-W-3: the fresh-store walk reached
        /// step 10 in a book whose box was empty, so the beat had no ring).
        public var bookNoteSelected: Bool
        /// Facts about `noteOfInterest` (nil until the store answered).
        public var note: NoteFacts?
        /// **The focused book's mode** (VX-292 U3 — step 11's book arc: the
        /// Book tab, then Read). nil unless `place` is a book that said it.
        public var bookMode: BookMode?
        /// **How many columns the note's Lenses board shows** (VX-292 U3 —
        /// step 9: a second column opened beside the note's own is the act).
        /// nil unless `place` is a note whose Lenses board is up.
        public var lensColumns: Int?
        /// Facts about the block step 7 flips (`flipInterest`; nil until the
        /// store answered).
        public var block: BlockFacts?

        public init(
            place: Place, noteMode: NoteMode? = nil, caret: Caret? = nil,
            bookNoteLive: Bool = false, bookNoteSelected: Bool = false,
            note: NoteFacts? = nil, bookMode: BookMode? = nil, lensColumns: Int? = nil,
            block: BlockFacts? = nil
        ) {
            self.place = place
            self.noteMode = noteMode
            self.caret = caret
            self.bookNoteLive = bookNoteLive
            self.bookNoteSelected = bookNoteSelected
            self.note = note
            self.bookMode = bookMode
            self.lensColumns = lensColumns
            self.block = block
        }

        /// Where a fresh tour begins before the window has said anything.
        public static let unknown = Facts(place: .elsewhere)
    }

    // MARK: - The run's state

    public struct State: Equatable, Sendable {
        public internal(set) var step: Step
        /// The seeded book (*the prince* since VX-292 U1 — the launch's book),
        /// looked up at the start; nil ⇒ the tour accepts any book at step 2.
        public let seededBookID: String?
        /// The chapter step 3 rings (*The Prince*'s XVII, whether it is better
        /// to be loved or feared — the app names it, VX-292 P-292-1).
        public let firstStoryID: String?
        /// The field guide — the leg end's ring and its finish.
        public let fieldGuideID: String?
        /// The note opened at step 3 (any note is accepted).
        public internal(set) var tourNoteID: String?
        /// The block she made a take of (step 5).
        public internal(set) var tourBlockID: String?
        /// The note of her own (step 11).
        public internal(set) var ownNoteID: String?
        /// The end card has been reached: the tour counts as completed.
        public internal(set) var completed: Bool
        /// The last facts the window reported.
        public internal(set) var facts: Facts

        // Step-local memories (each step's entry resets them).
        /// Step 4: the caret block the step first saw — a click elsewhere
        /// is the act.
        var writeBaseline: String?
        /// Step 5: the caret block and its take count when the caret came to
        /// rest there — a count that GROWS is the act (a block that already
        /// had takes, from an earlier tour, must not count as made).
        var takeBaseline: TakeBaseline?
        /// Step 7 (VX-292 U3 — the flip): the take the note showed at the
        /// flip's block when the step first saw it ("the English take" her
        /// second beat brings back), and that block. Set once per run of
        /// step 7's first beat; its second beat reads them.
        var flipOriginalTakeID: String?
        var flipBlockID: String?
        /// The place before the latest report — for "arrived from".
        var previousPlace: Place?
        /// The note box's liveness before the latest report — step 10's edge.
        var previousBookNoteLive: Bool
        /// **An ARRIVAL waiting to be judged** (VX-292 R-292-11 — the
        /// tutorial wins by driving): set at every step's entry and whenever
        /// the reported place changes; spent by the first report at a note
        /// that carries a mode (`drive`). One judgment per arrival — so a
        /// mode she picks herself on the same note is hers, and a correction
        /// that does not take is never asked twice.
        var arrivalUnjudged: Bool

        struct TakeBaseline: Equatable, Sendable {
            var blockID: String
            var takeCount: Int
        }

        init(seededBookID: String?, firstStoryID: String?, fieldGuideID: String?, facts: Facts) {
            self.step = .navigation
            self.seededBookID = seededBookID
            self.firstStoryID = firstStoryID
            self.fieldGuideID = fieldGuideID
            self.completed = false
            self.facts = facts
            self.previousPlace = nil
            self.previousBookNoteLive = facts.bookNoteLive
            self.arrivalUnjudged = true
        }
    }

    /// What can happen to a running tour.
    public enum Event: Equatable, Sendable {
        /// The window reported what it shows.
        case facts(Facts)
        /// The card's "next".
        case next
        /// The card's "End tour".
        case endTour
        /// One of the end card's three ways on.
        case choose(EndChoice)
    }

    /// The end card's three choices (mockup v5's fork).
    public enum EndChoice: Equatable, Sendable {
        /// "Keep going: two more minutes on stars, tags, books and snippets".
        case keepGoing
        /// "Open the field guide, every feature as a lesson".
        case fieldGuide
        /// "Done, go write".
        case done
    }

    /// What the app must DO.
    public enum Effect: Equatable, Sendable {
        /// Take the focused pane here (the tour's own choreography — the start
        /// on the Bookcase and the leg's stops; done visibly, P-2).
        ///
        /// **`mode`** (VX-292 R-292-11 — her words: *"if you were in takes on
        /// some chapter in the prince where the tutorial expects you to be in
        /// write, the tutorial wins"*): a NOTE arrived in a mode its step does
        /// not teach in, and the tour drives it to the one it does
        /// (`expectedNoteMode`, `drive`). nil — every other navigate — leaves
        /// the mode to the note, exactly as before.
        case navigate(Place, mode: NoteMode? = nil)
        /// Open the field guide (the Help menu's own door).
        case openFieldGuide
        /// The end card was reached: retire the offer as COMPLETED now, so a
        /// quit during the leg still counts.
        case recordCompleted
        /// The tour is over (`completed` says how it ended).
        case finish(completed: Bool)
        /// **Open Settings on its General pane** (VX-292 U3 — R-292-8: *"show
        /// people the settings pane for theme and how to connect their mcp"*):
        /// the leg's fifth stop, through the shell's own Settings road.
        /// Settings is its own window; the card stays in this one and carries
        /// next (PROVISIONAL P-292-10).
        case openSettings
        /// **Open the Pool's "in gatherings" run** (F-U2-W-2, option A —
        /// ruled 2026-10-08): leg 1's star makes her note a starred-notes
        /// match, so the Pool TUCKS it behind its masthead's "show"; leg 3
        /// opens that run as it arrives (the same act as "show"), so her row
        /// and its add to book are on screen. Tour-scoped: leaving the Pool
        /// tucks it again, as every visit does.
        case showPoolTucked
        /// **Bring this ring on screen, in this place** (VX-292 U2 —
        /// A-292-1/3): step 3's ARRIVAL in the seeded book asks the book to
        /// land the toured chapter's Outline card at the top of its page —
        /// once per arrival (`arrivalReveal`), through the book's own ascent
        /// road, which turns a book that arrived in Read to its Outline first
        /// (the tutorial wins at the book level). The Outline virtualizes its
        /// far rows, so the card is often not even drawn until it is landed.
        case reveal(Anchor, in: Place)
    }

    /// One step of the rule: the state after (nil = the tour is over) and
    /// what to do.
    public struct Outcome: Equatable, Sendable {
        public var state: State?
        public var effects: [Effect]
    }

    // MARK: - The rule

    /// A tour begins at step 1 (Q12 — a start is always a restart; there is no
    /// resume), on the Bookcase.
    public static func start(
        seededBookID: String?, firstStoryID: String?, fieldGuideID: String?,
        facts: Facts = .unknown
    ) -> (state: State, effects: [Effect]) {
        let state = State(
            seededBookID: seededBookID, firstStoryID: firstStoryID,
            fieldGuideID: fieldGuideID, facts: facts)
        let effects: [Effect] = facts.place == .area(.bookcase) ? [] : [.navigate(.area(.bookcase))]
        return (state, effects)
    }

    /// The whole rule.
    public static func reduce(_ state: State, _ event: Event) -> Outcome {
        var state = state
        var effects: [Effect] = []
        switch event {
        case .endTour:
            return Outcome(state: nil, effects: [.finish(completed: state.completed)])

        case .next:
            guard hasNext(state.step), let following = nextStep(after: state.step) else {
                return Outcome(state: state, effects: [])
            }
            enter(following, &state, &effects)
            settle(&state, &effects, freshReport: false)
            drive(&state, &effects)
            // Round 2 (the U2 ladder): the leg's end finishes at the guide on
            // THIS road too — a "next" pressed while she already sits at the
            // field guide (her report outran the leg's navigate) must finish,
            // not stall with `enter`'s navigate skipped and nothing said.
            // Mirrors the `.facts` arm below; only leg 4's and leg 5's nexts
            // can land here (`settle` cannot cascade through either without a
            // fresh report). VX-292 U3: the guide finishes from the Settings
            // stop too — the leg's destination reached ahead of its card.
            if finishesAtGuide(state.step), let finished = finishAtGuide(state) {
                return Outcome(state: nil, effects: effects + finished)
            }
            return Outcome(state: state, effects: effects)

        case .choose(let choice):
            guard state.step == .endCard else { return Outcome(state: state, effects: []) }
            switch choice {
            case .keepGoing:
                enter(.legStar, &state, &effects)
                settle(&state, &effects, freshReport: false)
                drive(&state, &effects)
                return Outcome(state: state, effects: effects)
            case .fieldGuide:
                return Outcome(state: nil, effects: [.openFieldGuide, .finish(completed: true)])
            case .done:
                return Outcome(state: nil, effects: [.finish(completed: true)])
            }

        case .facts(let facts):
            state.previousPlace = state.facts.place
            state.previousBookNoteLive = state.facts.bookNoteLive
            // R-292-11: a new place is a new arrival, judged by `drive`.
            if facts.place != state.facts.place { state.arrivalUnjudged = true }
            state.facts = facts
            settle(&state, &effects, freshReport: true)
            drive(&state, &effects)
            if finishesAtGuide(state.step), let finished = finishAtGuide(state) {
                return Outcome(state: nil, effects: effects + finished)
            }
            return Outcome(state: state, effects: effects)
        }
    }

    /// The steps at which opening the field guide FINISHES the tour: the
    /// leg's end, whose ring is the guide's row — and (VX-292 U3) the
    /// Settings stop before it, so the leg's destination reached ahead of its
    /// card is the finish there too (the guide is where both roads end,
    /// R-13s-1; the Round 1 MINOR-2 rule: never navigate off the guide she
    /// just opened).
    static func finishesAtGuide(_ step: Step) -> Bool {
        step == .legEnd || step == .legSettings
    }

    /// The step after a "next" (only the next-bearing steps ask). Step 7's
    /// next, from either beat, moves on to step 8: the flip is offered, never
    /// required (PROVISIONAL P-292-8).
    static func nextStep(after step: Step) -> Step? {
        switch step {
        case .navigation: .seededBook
        case .takesMode, .takesFlipBack: .readInNote
        case .readInNote: .lensesLive
        case .deeperModes: .upToBook
        case .upToBook: .bookAndRead
        case .legSnippets: .legSettings
        case .legSettings: .legEnd
        default: nil
        }
    }

    /// Run the current step's check against the latest facts, and keep going
    /// while each step it reaches is already satisfied (a step she did ahead
    /// of the card — the tolerance rule). Bounded by the step count.
    ///
    /// `freshReport`: whether the facts JUST arrived. The two edge checks
    /// (step 10's "the box went live", "she went down from the book", and the
    /// leg's "she left Snippets") count only on the report that carried the
    /// edge — a "next" pressed later must not find a stale one.
    static func settle(_ state: inout State, _ effects: inout [Effect], freshReport: Bool) {
        for _ in 0..<Step.allCases.count {
            remember(&state)
            guard let following = advance(state, freshReport: freshReport) else { return }
            // What the leaving step learned.
            switch state.step {
            case .makeTake:
                state.tourBlockID = state.facts.caret?.blockID
            case .ownNote:
                state.ownNoteID = ownNoteCandidate(state)
            default:
                break
            }
            if following == .endCard {
                state.completed = true
                effects.append(.recordCompleted)
            }
            enter(following, &state, &effects)
        }
    }

    /// The step a report moves the tour to, or nil to stay.
    static func advance(_ state: State, freshReport: Bool) -> Step? {
        let facts = state.facts
        switch state.step {
        case .navigation, .readInNote, .deeperModes, .upToBook, .endCard:
            return nil  // "next" (or the end card's choices) only

        case .seededBook:
            guard case .book(let id) = facts.place else { return nil }
            return state.seededBookID == nil || id == state.seededBookID ? .insideBook : nil

        case .insideBook:
            // Any note: the card asks for the first story, and the ring is on
            // it, but a different note serves every later step just as well.
            guard case .note = facts.place else { return nil }
            return .write

        case .write:
            // A click into a paragraph: Write's caret, on the note she is in,
            // moved off the block the step first saw — and not the note's
            // first paragraph (the card asks for "the middle"; PROVISIONAL
            // P-U2-6 says how lenient that is).
            guard facts.noteMode == .write, let caret = facts.caret,
                  case .note(let noteID) = facts.place, caret.noteID == noteID,
                  let baseline = state.writeBaseline, caret.blockID != baseline,
                  caret.ordinal >= 2
            else { return nil }
            return .makeTake

        case .makeTake:
            // The take was MADE: the caret block's count grew past where it
            // stood when the caret came to rest there.
            guard let caret = facts.caret, let baseline = state.takeBaseline,
                  caret.blockID == baseline.blockID, caret.takeCount > baseline.takeCount
            else { return nil }
            return .takeIcon

        case .takeIcon:
            guard case .note = facts.place, facts.noteMode == .takes else { return nil }
            return .takesMode

        case .takesMode:
            // VX-292 U3 — the flip: the take the note shows at the flip's
            // block CHANGED from the one the step first saw (she chose the
            // Italian). "next" moves on without it.
            guard let shown = flipShown(state), let original = state.flipOriginalTakeID,
                  shown != original
            else { return nil }
            return .takesFlipBack

        case .takesFlipBack:
            // …and back: the take the step first saw is shown again.
            guard let shown = flipShown(state), shown == state.flipOriginalTakeID
            else { return nil }
            return .readInNote

        case .lensesLive:
            // VX-292 U3 — Lenses, live: a second column stands beside the
            // note's own on the note's Lenses board (the saved "il principe
            // 1532" column the card names, or any other she opens — a note
            // with no saved lens still has the door's own new-lens rows).
            guard case .note = facts.place, facts.noteMode == .lenses,
                  (facts.lensColumns ?? 0) >= 2
            else { return nil }
            return .deeperModes

        case .bookAndRead:
            // VX-292 U3 — the book arc's second beat (R-292-10): the book
            // reads straight through, in its own Read.
            guard case .book = facts.place, facts.bookMode == .read else { return nil }
            return .downAndUp

        case .downAndUp:
            // Home first is the next beat already done.
            if facts.place == .area(.bookcase) { return .ownNote }
            guard freshReport else { return nil }
            // Down: the note box's edit here took (it lands the paragraph live,
            // in the book) — an EDGE, so a box already live when the card
            // arrived waits for her act…
            if case .book = facts.place, facts.bookNoteLive, !state.previousBookNoteLive {
                return .home
            }
            // …or she went down to the note's own page from the book.
            if case .note = facts.place, case .book = state.previousPlace { return .home }
            return nil

        case .home:
            return facts.place == .area(.bookcase) ? .ownNote : nil

        case .ownNote:
            return ownNoteCandidate(state) == nil ? nil : .endCard

        case .legStar:
            return ownFacts(state)?.starred == true ? .legTags : nil

        case .legTags:
            return (ownFacts(state)?.tagCount ?? 0) >= 1 ? .legBook : nil

        case .legBook:
            return (ownFacts(state)?.bookCount ?? 0) >= 1 ? .legSnippets : nil

        case .legSnippets:
            // "next", or she left the Snippets area by any road (the snippet's
            // own click opens it).
            if freshReport, state.previousPlace == .area(.snippets),
               facts.place != .area(.snippets) {
                return .legSettings
            }
            return nil

        case .legSettings:
            return nil  // "next" — Settings is its own window (P-292-10)

        case .legEnd:
            return nil  // finishes at the field guide (`finishAtGuide`)
        }
    }

    /// **The take the note shows at the flip's block** — read only for the
    /// block the step first saw (a report about another block, or another
    /// note, is not this flip's).
    static func flipShown(_ state: State) -> String? {
        guard let block = state.facts.block, block.blockID == state.flipBlockID,
              block.noteID == state.tourNoteID
        else { return nil }
        return block.chosenTakeID
    }

    /// **The take step 7's first beat asks her to choose**: the one the card
    /// names (the Italian) when the block carries it and it is not already
    /// the shown one; else the first other take in fan order (a note that is
    /// not the Prince's — the step still flips something real).
    static func flipTarget(_ state: State) -> String? {
        guard let block = state.facts.block, block.blockID == state.flipBlockID,
              let original = state.flipOriginalTakeID
        else { return nil }
        if let named = block.namedTakeID, named != original, block.takeIDs.contains(named) {
            return named
        }
        return block.takeIDs.first { $0 != original }
    }

    /// **The block step 7 watches, and in which note** (the app observes
    /// exactly this one, `Queries.tourFlipFacts`): the toured note, preferring
    /// the block she made a take of at step 5 — or, once the step has seen
    /// its block, that block. nil outside step 7.
    public static func flipInterest(_ state: State) -> (noteID: String, blockID: String?)? {
        switch state.step {
        case .takesMode, .takesFlipBack:
            guard let note = state.tourNoteID else { return nil }
            return (note, state.flipBlockID ?? state.tourBlockID)
        default:
            return nil
        }
    }

    /// Step 11's note: a note she opened that is BOOKLESS (the quick entry's
    /// note waits in the Pool — the card's own sentence) and is not the
    /// toured story. A journal entry (Today's Entry — the assessment's B2
    /// hazard) lives in the daily Journal, so it is never taken for hers.
    static func ownNoteCandidate(_ state: State) -> String? {
        guard case .note(let id) = state.facts.place,
              id != state.tourNoteID,
              let note = state.facts.note, note.noteID == id, note.bookCount == 0
        else { return nil }
        return id
    }

    static func ownFacts(_ state: State) -> NoteFacts? {
        guard let own = state.ownNoteID, let note = state.facts.note, note.noteID == own
        else { return nil }
        return note
    }

    /// The leg's end finishes when she opens the field guide (the ringed row).
    static func finishAtGuide(_ state: State) -> [Effect]? {
        guard case .book(let id) = state.facts.place else { return nil }
        if let guide = state.fieldGuideID, id != guide { return nil }
        return [.finish(completed: true)]
    }

    /// Arrive at a step: reset its memories, and the leg's own choreography.
    static func enter(_ step: Step, _ state: inout State, _ effects: inout [Effect]) {
        state.step = step
        state.writeBaseline = nil
        state.takeBaseline = nil
        // VX-292 U3: step 7's first beat sees its block afresh (a run that
        // pressed next mid-flip and came back by a restart starts over); its
        // second beat keeps what the first saw.
        if step == .takesMode {
            state.flipOriginalTakeID = nil
            state.flipBlockID = nil
        }
        // R-292-11: a step's entry is a landing of the tour's own — judged
        // on the next report at a note that carries a mode (`drive`).
        state.arrivalUnjudged = true
        remember(&state)
        let place = state.facts.place
        switch step {
        case .legStar, .legTags:
            if let own = state.ownNoteID, place != .note(own) { effects.append(.navigate(.note(own))) }
        case .legBook:
            if place != .area(.pool) { effects.append(.navigate(.area(.pool))) }
            effects.append(.showPoolTucked)
        case .legSnippets:
            if place != .area(.snippets) { effects.append(.navigate(.area(.snippets))) }
        case .legSettings:
            // VX-292 U3 (R-292-8): Settings opens on its General pane — unless
            // she has already opened the field guide, the leg's destination
            // (it finishes there, `finishesAtGuide`; never a window raised
            // over the guide she just opened).
            if finishAtGuide(state) == nil { effects.append(.openSettings) }
        case .legEnd:
            // Round 1 MINOR-2 (the U2 ladder): landing AT the field guide IS
            // the leg's finish — `finishAtGuide` accepts this very report —
            // so never navigate away from the guide she just opened. Every
            // other arrival heads home as designed (P-U2-7's choreography).
            if finishAtGuide(state) == nil, place != .area(.bookcase) {
                effects.append(.navigate(.area(.bookcase)))
            }
        default:
            break
        }
    }

    // MARK: - The tutorial wins (VX-292 R-292-11)

    /// **The note mode a step teaches in** — the tour's half of her ruling
    /// (R-292-11: *"the tour DRIVES; state untouched … landings force the
    /// mode the step expects — the tutorial wins by driving, never by
    /// erasing"*). Steps 4–6 teach in WRITE (the caret, the bar's Takes and
    /// the ⑂ badge are Write's); step 7's two beats teach in TAKES (the
    /// choose bands are the board's). nil: any mode — steps 8 and 9 ask HER
    /// to switch (Read, Lenses: driving there would do her act for her), step
    /// 10 only names two modes, and step 11's ladder and the leg's acts work
    /// from every mode. Every step listed is one of `followsTheNote`'s, so the
    /// note it judges is the toured note.
    public static func expectedNoteMode(_ step: Step) -> NoteMode? {
        switch step {
        case .write, .makeTake, .takeIcon: .write
        case .takesMode, .takesFlipBack: .takes
        default: nil
        }
    }

    /// **Judge the arrival, once** (R-292-11). On the first report at a note
    /// that carries a mode after a step's entry or a change of place: when
    /// the step teaches in another mode, ONE corrective navigate to the same
    /// note in the step's mode — the road a note's remembered mode would
    /// otherwise win (the toured chapter left in Takes by an earlier tour, a
    /// chapter she reads in Read). Either way the arrival is then judged:
    ///
    /// - a mode she switches to herself on the same note is hers (no report
    ///   changes the place, so nothing is judged — the ring's road back on
    ///   the rail stays the answer, `isRoadBack`);
    /// - a correction that does not take is never asked again (no loop);
    /// - wandering judges nothing: a place that is not a note carries no
    ///   mode, so the arrival waits — and coming back to the note is judged
    ///   when it lands, which is the point;
    /// - nothing is erased: the effect is a navigation, whose only write is
    ///   the one a mode switch always makes (the note's remembered mode).
    static func drive(_ state: inout State, _ effects: inout [Effect]) {
        guard state.arrivalUnjudged else { return }
        // VX-292 U2 (A-292-1/3): a book arrival that brings a ring on
        // screen — judged at once (a book reports no mode to wait for).
        if let (anchor, place) = arrivalReveal(state) {
            state.arrivalUnjudged = false
            effects.append(.reveal(anchor, in: place))
            return
        }
        guard case .note(let noteID) = state.facts.place, let mode = state.facts.noteMode
        else { return }
        state.arrivalUnjudged = false
        guard let expected = expectedNoteMode(state.step), mode != expected,
              noteID == state.tourNoteID
        else { return }
        effects.append(.navigate(.note(noteID), mode: expected))
    }

    /// **The ring a step's ARRIVAL brings on screen** (VX-292 U2 — the
    /// architect's A-292-1/3, the in-batch fork answered): step 3 in the
    /// SEEDED book lands the toured chapter's Outline card — always, once
    /// per arrival, never a delayed "is it visible yet?" check (the Outline
    /// draws a far card only once it is near the page, so at the arrival the
    /// card usually does not exist to be measured). She scrolls freely after;
    /// leaving the book and coming back is a new arrival. With no seeded book
    /// or no toured chapter (a missing landmark — "any book" / "any note")
    /// there is nothing to land. Every other step's ring is on screen by
    /// construction or keeps its recorded fallback (the plan's U2 RECORD).
    static func arrivalReveal(_ state: State) -> (Anchor, Place)? {
        guard state.step == .insideBook, case .book(let bookID) = state.facts.place,
              bookID == state.seededBookID, let story = state.firstStoryID
        else { return nil }
        return (.outlineCard(story), .book(bookID))
    }

    /// The steps whose toured note is the note she is in.
    static let followsTheNote: Set<Step> = [
        .insideBook, .write, .makeTake, .takeIcon, .takesMode, .takesFlipBack, .readInNote,
        .lensesLive, .deeperModes, .upToBook, .bookAndRead, .downAndUp,
    ]

    /// Fold the latest facts into the step's memories.
    static func remember(_ state: inout State) {
        let facts = state.facts
        // The toured note is whichever note she is in from step 3 to step 11:
        // the card asks for the first story, but every later step serves any
        // note, so the ring follows the one she actually took.
        if case .note(let id) = facts.place, followsTheNote.contains(state.step) {
            state.tourNoteID = id
        }
        switch state.step {
        case .takesMode:
            // VX-292 U3: the flip's block and the take it showed, the first
            // time the store says them for the toured note.
            if state.flipOriginalTakeID == nil, let block = facts.block,
               block.noteID == state.tourNoteID, let shown = block.chosenTakeID {
                state.flipBlockID = block.blockID
                state.flipOriginalTakeID = shown
            }
        case .write:
            if state.writeBaseline == nil, facts.noteMode == .write, let caret = facts.caret,
               case .note(let noteID) = facts.place, caret.noteID == noteID {
                state.writeBaseline = caret.blockID
            }
        case .makeTake:
            if let caret = facts.caret, facts.noteMode == .write,
               state.takeBaseline?.blockID != caret.blockID {
                state.takeBaseline = .init(blockID: caret.blockID, takeCount: caret.takeCount)
            }
        default:
            break
        }
    }

    /// The note whose store facts the current step needs (the app observes
    /// exactly this one): at step 11 the note she is in — is it bookless? —
    /// and for the leg, the note of her own.
    public static func noteOfInterest(_ state: State) -> String? {
        switch state.step {
        case .ownNote:
            if case .note(let id) = state.facts.place, id != state.tourNoteID { return id }
            return nil
        case .endCard, .legStar, .legTags, .legBook, .legSnippets, .legSettings, .legEnd:
            return state.ownNoteID
        default:
            return nil
        }
    }

    // MARK: - The rings

    /// The things a card points at. Each case is attached to ONE door in the
    /// app (`.tourAnchor(…)`); its associated id names WHICH row, card or
    /// block, so a list lights exactly one.
    public enum Anchor: Hashable, Sendable {
        /// The sidebar's five places, as a group (step 1).
        case sidebarAreas
        /// One of the sidebar's places.
        case sidebarArea(Area)
        /// A row of the sidebar's "this note" rail.
        case sidebarMode(NoteMode)
        /// A row of the sidebar's Open strip (a note id).
        case sidebarOpenRow(String)
        /// A book's row on the Bookcase (a reading id).
        case bookcaseRow(String)
        /// The Bookcase's quick-entry box.
        case quickEntry
        /// A note's card in a book's Outline (a note id).
        case outlineCard(String)
        /// A book masthead's mode tab.
        case bookModeTab(BookMode)
        /// A note's row in a book's Index column (a note id).
        case indexNoteRow(String)
        /// The sidebar note box's "edit here".
        case noteBoxEditHere
        /// Write's bottom bar "Takes".
        case barTakes
        /// Write's takes panel "＋ new take (branch)" (a sheet).
        case panelNewTake
        /// Write's takes panel "Open Takes mode" (a sheet).
        case panelOpenTakesMode
        /// Write's ⑂N badge in the margin (a block id) — AppKit.
        case takeBadge(String)
        /// A block's row on the Takes board (a block id).
        case takesBlock(String)
        /// **A take's choose band on the Takes board** (a take id — VX-292
        /// U3, step 7's flip: "choose" / "✓ chosen", `TakeChooseHeader`).
        case takeChoose(String)
        /// **Read's `edit · read` switch** (VX-292 U3, step 8 — the face bar's
        /// segmented control, `ReadModeView`).
        case readFaceSwitch
        /// **Lenses' "＋ column" door** (VX-292 U3, step 9 — the dashed stub
        /// beside the note's one column, whose menu opens a saved lens).
        case lensAddColumn
        /// The pane's book icon (the ascent).
        case contextBarBook
        /// The note masthead's ＃ tag door.
        case mastheadTagDoor
        /// A Pool card's "add to book" (a note id).
        case poolAddToBook(String)
        /// The Snippets area's first snippet.
        case firstSnippetCard

        /// Inside Write's takes panel — a sheet, which is its own window: the
        /// card cannot sit beside it, so it takes its step's corner.
        public var isInPanel: Bool {
            switch self {
            case .panelNewTake, .panelOpenTakesMode: true
            default: false
            }
        }

        /// Drawn by AppKit, not SwiftUI: the overlay finds it and rings it
        /// itself (read-only — nothing in the editor is decorated).
        public var isAppKit: Bool {
            if case .takeBadge = self { return true }
            return false
        }
    }

    /// **The ring, as ordered candidates.** The tour lights exactly ONE ring
    /// (A3, the U2 UI assessment): the first anchor, list by list, that is
    /// actually on screen. Every step answers one list today; the shape
    /// stays a list of lists so a step can name a second road without a
    /// second ring. The lit anchor is the one the card sits beside.
    public static func ringGroups(_ state: State) -> [[Anchor]] {
        let facts = state.facts
        let bookcase = Anchor.sidebarArea(.bookcase)
        switch state.step {
        case .navigation:
            return [[.sidebarAreas]]
        case .seededBook:
            guard facts.place == .area(.bookcase) else { return [[bookcase]] }
            return [state.seededBookID.map { [.bookcaseRow($0)] } ?? []]
        case .insideBook:
            switch facts.place {
            case .book:
                return [state.firstStoryID.map { [.outlineCard($0)] } ?? []]
            case .area(.bookcase):
                return [state.seededBookID.map { [.bookcaseRow($0)] } ?? []]
            default:
                return [[bookcase]]
            }
        case .write:
            // The paragraph is hers to choose — no ring on the live text. In a
            // note but out of Write, the ring is the road back to it; off the
            // note entirely, the note's own Open-strip row (round 1 MINOR-1).
            guard case .note = facts.place else { return [roadBackRow(state)] }
            if facts.noteMode != .write { return [[.sidebarMode(.write)]] }
            return []
        case .makeTake:
            guard case .note = facts.place else { return [roadBackRow(state)] }
            if facts.noteMode != .write { return [[.sidebarMode(.write)]] }
            return facts.caret?.panelOpen == true ? [[.panelNewTake]] : [[.barTakes]]
        case .takeIcon:
            // ONE ring (A3, the U2 UI assessment — the walk showed two at
            // once, the badge's under the panel): while the panel is up its
            // "Open Takes mode" is the act; with it closed, the ⑂ badge.
            // Off Write, the road back (round 1 MINOR-1): the rail's Write in
            // the note, the Open row off it — the badge cannot exist there.
            guard case .note = facts.place else { return [roadBackRow(state)] }
            if facts.caret?.panelOpen == true { return [[.panelOpenTakesMode]] }
            if facts.noteMode != .write { return [[.sidebarMode(.write)]] }
            return [state.tourBlockID.map { [.takeBadge($0)] } ?? []]
        case .takesMode, .takesFlipBack:
            guard case .note = facts.place else { return [roadBackRow(state)] }
            if facts.noteMode != .takes { return [[.sidebarMode(.takes)]] }
            // VX-292 U3 — the flip: the choose band of the take to choose
            // (the Italian first, the original on the way back), the block's
            // own row behind it (a closed fan draws no bands — its row is
            // still the place to look).
            let take = state.step == .takesMode ? flipTarget(state) : state.flipOriginalTakeID
            let block = state.flipBlockID ?? state.tourBlockID
            return [(take.map { [Anchor.takeChoose($0)] } ?? [])
                    + (block.map { [Anchor.takesBlock($0)] } ?? [])]
        case .readInNote:
            // VX-292 U3 (R-292-7): the rail's Read, then — in Read — its
            // `edit · read` switch.
            guard case .note = facts.place else { return [roadBackRow(state)] }
            return facts.noteMode == .read ? [[.readFaceSwitch]] : [[.sidebarMode(.read)]]
        case .lensesLive:
            // VX-292 U3: the rail's Lenses, then — in Lenses — its "＋ column"
            // door (the saved lens opens from its menu).
            guard case .note = facts.place else { return [roadBackRow(state)] }
            return facts.noteMode == .lenses ? [[.lensAddColumn]] : [[.sidebarMode(.lenses)]]
        case .deeperModes:
            // VX-292 U3: Compare and Blocks, named; the ring on the first.
            guard case .note = facts.place else { return [roadBackRow(state)] }
            return [[.sidebarMode(.compare)]]
        case .upToBook:
            // VX-292 U3 — the book arc's first beat (R-292-10; it reworks
            // step 9's climb): the book icon. In the book the card describes
            // what she sees and waits for her next; nothing to ring there.
            switch facts.place {
            case .book: return []
            case .note: return [[.contextBarBook]]
            default: return [roadBackRow(state)]
            }
        case .bookAndRead:
            // VX-292 U3 — the second beat: Book, then Read.
            switch facts.place {
            case .book:
                return facts.bookMode == .book ? [[.bookModeTab(.read)]] : [[.bookModeTab(.book)]]
            case .note:
                return [[.contextBarBook]]
            default:
                return [roadBackRow(state)]
            }
        case .downAndUp:
            switch facts.place {
            case .book:
                // F-U2-W-3 (the fresh-store walk): the edit-here door exists
                // only while the box holds a note. An empty box — the walked
                // direct-road Index arrived unselected — rings the toured
                // note's own Index row instead (her verified recovery), the
                // Index tab behind it: step 9's own group shape.
                if facts.bookNoteSelected { return [[.noteBoxEditHere]] }
                return [(state.tourNoteID.map { [Anchor.indexNoteRow($0)] } ?? [])
                        + [.bookModeTab(.index)]]
            case .note: return [[.contextBarBook]]
            default: return [roadBackRow(state)]
            }
        case .home:
            return [[bookcase]]
        case .ownNote:
            return facts.place == .area(.bookcase) ? [[.quickEntry]] : [[bookcase]]
        case .endCard:
            return []
        case .legStar:
            return [state.ownNoteID.map { [.sidebarOpenRow($0)] } ?? []]
        case .legTags:
            if let own = state.ownNoteID, facts.place == .note(own) { return [[.mastheadTagDoor]] }
            return [state.ownNoteID.map { [.sidebarOpenRow($0)] } ?? []]
        case .legBook:
            guard facts.place == .area(.pool) else { return [[.sidebarArea(.pool)]] }
            return [state.ownNoteID.map { [.poolAddToBook($0)] } ?? []]
        case .legSnippets:
            return facts.place == .area(.snippets)
                ? [[.firstSnippetCard]] : [[.sidebarArea(.snippets)]]
        case .legSettings:
            // Settings is its own window: nothing in this one to ring.
            return []
        case .legEnd:
            guard facts.place == .area(.bookcase) else { return [[bookcase]] }
            return [state.fieldGuideID.map { [.bookcaseRow($0)] } ?? []]
        }
    }

    /// **The road back to the toured note when she has left it entirely**
    /// (round 1 MINOR-1, the U2 ladder): its row on the sidebar's Open strip
    /// — the legs' own shape, visible from every place. Used ONLY off the
    /// note (the implementer's round-1 refinement): on the note with the
    /// step's target merely scrolled away, nothing rings and the road-back
    /// sentence is never said — A7's contradiction must not return inverted.
    static func roadBackRow(_ state: State) -> [Anchor] {
        state.tourNoteID.map { [.sidebarOpenRow($0)] } ?? []
    }

    /// **Whether the ring is the ROAD BACK** — the step's own target is not
    /// where she is, so the ring points at the way back to it (she wandered).
    /// The card then adds one muted sentence (A7 of the U2 UI assessment,
    /// PROVISIONAL P-U2-15) so the ring and the words never contradict. The
    /// branches mirror `ringGroups`' fallbacks exactly; a step's own road
    /// (step 11's book icon, step 12's Bookcase, leg 1's Open row, the rail's
    /// Read and Lenses at steps 8–9) is never a road back.
    public static func isRoadBack(_ state: State) -> Bool {
        let place = state.facts.place
        switch state.step {
        case .seededBook, .ownNote, .legEnd:
            return place != .area(.bookcase)
        case .insideBook:
            if case .book = place { return false }
            return true
        case .write, .makeTake, .takeIcon:
            // Round 1 MINOR-1: off the note, the Open row is the road back.
            if case .note = place { return state.facts.noteMode != .write }
            return true
        case .takesMode, .takesFlipBack:
            if case .note = place { return state.facts.noteMode != .takes }
            return true
        case .readInNote, .lensesLive, .deeperModes:
            if case .note = place { return false }
            return true
        case .upToBook:
            switch place {
            case .book, .note: return false
            default: return true
            }
        case .bookAndRead:
            // In the note, the book icon is the way back up to the book.
            if case .book = place { return false }
            return true
        case .downAndUp:
            // F-U2-W-3: in a book, the ring is the step's own edit-here only
            // while the box holds a note; an empty box's row ring is the
            // road back, and the line says so.
            if case .book = place { return !state.facts.bookNoteSelected }
            return true
        case .legTags:
            guard let own = state.ownNoteID else { return false }
            return place != .note(own)
        case .legBook:
            return place != .area(.pool)
        case .legSnippets:
            return place != .area(.snippets)
        case .navigation, .home, .endCard, .legStar, .legSettings:
            return false
        }
    }

    // MARK: - Where a card sits

    /// A rectangle in the overlay's own space (points, top-left origin).
    /// Its own type so this rule needs nothing beyond Foundation.
    public struct Rect: Equatable, Sendable {
        public var x: Double
        public var y: Double
        public var width: Double
        public var height: Double

        public init(x: Double, y: Double, width: Double, height: Double) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }

        public var maxX: Double { x + width }
        public var maxY: Double { y + height }

        func intersects(_ other: Rect) -> Bool {
            x < other.maxX && other.x < maxX && y < other.maxY && other.y < maxY
        }
    }

    /// The side of its anchor a card may take.
    public enum Side: Equatable, Sendable { case trailing, below, leading, above }

    /// The corner a card takes when nothing it points at can be sat beside.
    public enum Corner: Equatable, Sendable { case topTrailing, bottomLeading, bottomTrailing, center }

    /// The sides a step's card tries, in order.
    public static func preferredSides(_ step: Step) -> [Side] {
        switch step {
        case .ownNote: [.above, .trailing, .leading, .below]
        case .seededBook, .legEnd: [.below, .above, .trailing, .leading]
        default: [.trailing, .below, .leading, .above]
        }
    }

    /// The step's corner when no anchor can be sat beside (nothing lit, or the
    /// lit anchor lives in Write's takes panel — the mockup put step 5's card
    /// at the bottom left, clear of the panel).
    public static func fallbackCorner(_ step: Step) -> Corner {
        switch step {
        case .makeTake, .takeIcon: .bottomLeading
        case .endCard: .center
        default: .topTrailing
        }
    }

    /// The gap between a card and what it points at, and the margin it keeps
    /// from the window's edges.
    public static let cardGap: Double = 14
    public static let cardMargin: Double = 16

    /// How far a card keeps from the ring it points at (the ring's outset
    /// and its glow — the card never sits on the ring's own frame).
    public static let ringClearance: Double = 12

    /// **Where a card goes** (A2 of the U2 UI assessment — the placement
    /// pattern): beside its anchor, on the first preferred side where the
    /// whole card fits inside the container WITHOUT covering the ring's own
    /// frame or any KEEP-CLEAR region (the bottom bars, the mastheads, the
    /// sidebar's navigation — `avoid`). On each side it tries the anchor's
    /// own alignment first, then centred on it, then its far alignment, then
    /// the container's two ends; a candidate that lands on a keep-clear
    /// region is PUSHED along its side past that region (so a card beside a
    /// sidebar row lands in the first free gutter right of the sidebar, never
    /// over it). With no side free, the corners in order — the step's own
    /// first — under the same rules; and only when nothing at all is clear,
    /// the old rule (beside the anchor, then the corner) as the last resort.
    public static func place(
        card: (width: Double, height: Double), beside anchor: Rect?,
        in container: (width: Double, height: Double),
        sides: [Side], corner: Corner, avoid: [Rect] = []
    ) -> (x: Double, y: Double) {
        let m = cardMargin, g = cardGap
        let w = card.width, h = card.height
        func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double { min(max(v, lo), max(lo, hi)) }
        let maxX = container.width - w - m
        let maxY = container.height - h - m
        let ring = anchor.map {
            Rect(x: $0.x - ringClearance, y: $0.y - ringClearance,
                 width: $0.width + 2 * ringClearance, height: $0.height + 2 * ringClearance)
        }
        func inside(_ x: Double, _ y: Double) -> Bool {
            x >= m - 0.5 && y >= m - 0.5 && x <= maxX + 0.5 && y <= maxY + 0.5
        }
        func blocker(_ x: Double, _ y: Double) -> Rect? {
            let r = Rect(x: x, y: y, width: w, height: h)
            if let ring, r.intersects(ring) { return ring }
            return avoid.first { r.intersects($0) }
        }
        // Beside the anchor, side by side, pushing past keep-clear regions.
        if let a = anchor {
            for side in sides {
                let starts: [(Double, Double)]
                switch side {
                case .trailing, .leading:
                    let x = side == .trailing ? a.maxX + g : a.x - g - w
                    starts = [a.y - 8, a.y + a.height / 2 - h / 2, a.maxY - h + 8, m, maxY]
                        .map { (x, clamp($0, m, maxY)) }
                case .below, .above:
                    let y = side == .below ? a.maxY + g : a.y - g - h
                    let first = side == .below ? a.x : a.maxX - w
                    let far = side == .below ? a.maxX - w : a.x
                    starts = [first, a.x + a.width / 2 - w / 2, far, m, maxX]
                        .map { (clamp($0, m, maxX), y) }
                }
                for start in starts {
                    var (x, y) = start
                    for _ in 0..<4 {
                        guard inside(x, y) else { break }
                        guard let block = blocker(x, y) else { return (x, y) }
                        switch side {
                        case .trailing: x = block.maxX + g
                        case .leading: x = block.x - g - w
                        case .below: y = block.maxY + g
                        case .above: y = block.y - g - h
                        }
                    }
                }
            }
        }
        // The corners, the step's own first.
        func point(_ c: Corner) -> (Double, Double) {
            switch c {
            case .topTrailing: (max(m, maxX), m)
            case .bottomLeading: (m, max(m, maxY))
            case .bottomTrailing: (max(m, maxX), max(m, maxY))
            case .center: (max(m, (container.width - w) / 2), max(m, container.height * 0.44 - h / 2))
            }
        }
        let corners = [corner] + [Corner.topTrailing, .bottomTrailing, .bottomLeading, .center]
            .filter { $0 != corner }
        for c in corners {
            let (x, y) = point(c)
            if inside(x, y), blocker(x, y) == nil { return (x, y) }
        }
        // Nothing is clear of everything: beside the anchor off the ring
        // alone (the pre-A2 rule), then the step's corner.
        if let a = anchor {
            for side in sides {
                let x: Double, y: Double
                switch side {
                case .trailing: (x, y) = (a.maxX + g, clamp(a.y - 8, m, maxY))
                case .leading: (x, y) = (a.x - g - w, clamp(a.y - 8, m, maxY))
                case .below: (x, y) = (clamp(a.x, m, maxX), a.maxY + g)
                case .above: (x, y) = (clamp(a.maxX - w, m, maxX), a.y - g - h)
                }
                if inside(x, y), !Rect(x: x, y: y, width: w, height: h).intersects(a) { return (x, y) }
            }
        }
        return point(corner)
    }
}
