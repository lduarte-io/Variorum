import Foundation

/// **THE ONBOARDING TOUR'S RULE** (13s-b U2 — mockup v5, approved at R-13s-27,
/// `notes/plans/13s-mockups/onboarding-tour.html`; the plan file's U2 RECORD
/// carries the build-verify resolutions and every PROVISIONAL).
///
/// Coach marks over the REAL app: a ring on the thing to touch (never a dim —
/// R-13s-12), a small card saying one idea, her real click advancing, End tour
/// always there, the step count visible. Eleven steps (step 10 has two beats),
/// an end card over the note she just opened, a four-stop "keep going" leg, and
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
public enum Tour {

    // MARK: - The steps

    public enum Step: String, CaseIterable, Sendable {
        // The main leg (mockup v5 steps 1–11; step 10 is two beats).
        case navigation, seededBook, insideBook, write, makeTake, takeIcon, takesMode
        case deeperModes, placeFollows, downAndUp, home, ownNote
        /// "That's the tour." — over the note she just opened (A3).
        case endCard
        // The keep-going leg (R-13s-1's optional leg; Q13's four stops) and its end.
        case legStar, legTags, legBook, legSnippets, legEnd
    }

    /// The main leg's count, as the cards say it ("Step 1 of 11").
    public static let mainStepCount = 11
    /// The leg's count ("Keep going · 1 of 4").
    public static let legStopCount = 4

    /// Where a card sits in the count — what its small label says.
    public enum Position: Equatable, Sendable {
        /// `number` of `mainStepCount`; `secondBeat` is step 10's "and home".
        case main(number: Int, secondBeat: Bool)
        /// The end card carries no count.
        case endCard
        /// `number` of `legStopCount`.
        case leg(number: Int)
        /// "The end".
        case legEnd
    }

    public static func position(of step: Step) -> Position {
        switch step {
        case .navigation: .main(number: 1, secondBeat: false)
        case .seededBook: .main(number: 2, secondBeat: false)
        case .insideBook: .main(number: 3, secondBeat: false)
        case .write: .main(number: 4, secondBeat: false)
        case .makeTake: .main(number: 5, secondBeat: false)
        case .takeIcon: .main(number: 6, secondBeat: false)
        case .takesMode: .main(number: 7, secondBeat: false)
        case .deeperModes: .main(number: 8, secondBeat: false)
        case .placeFollows: .main(number: 9, secondBeat: false)
        case .downAndUp: .main(number: 10, secondBeat: false)
        case .home: .main(number: 10, secondBeat: true)
        case .ownNote: .main(number: 11, secondBeat: false)
        case .endCard: .endCard
        case .legStar: .leg(number: 1)
        case .legTags: .leg(number: 2)
        case .legBook: .leg(number: 3)
        case .legSnippets: .leg(number: 4)
        case .legEnd: .legEnd
        }
    }

    /// Whether the card carries a "next" door. The mockup's cards that teach
    /// without asking for an act carry it (steps 1, 7, 8, 9); every other card
    /// advances on her act. **Leg 4 carries it too (PROVISIONAL P-U2-4):** its
    /// copy asks for no act, and the real app's snippet click OPENS the snippet
    /// — the mockup's ring-click advance would yank her out of what she opened.
    public static func hasNext(_ step: Step) -> Bool {
        switch step {
        case .navigation, .takesMode, .deeperModes, .placeFollows, .legSnippets: true
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

    /// One report of what the window shows.
    public struct Facts: Equatable, Sendable {
        public var place: Place
        /// The focused note's mode (nil unless `place` is a note).
        public var noteMode: NoteMode?
        /// Write's caret (nil unless Write's editor reports one).
        public var caret: Caret?
        /// A book's sidebar note box is LIVE — the "edit here" door took.
        public var bookNoteLive: Bool
        /// Facts about `noteOfInterest` (nil until the store answered).
        public var note: NoteFacts?

        public init(
            place: Place, noteMode: NoteMode? = nil, caret: Caret? = nil,
            bookNoteLive: Bool = false, note: NoteFacts? = nil
        ) {
            self.place = place
            self.noteMode = noteMode
            self.caret = caret
            self.bookNoteLive = bookNoteLive
            self.note = note
        }

        /// Where a fresh tour begins before the window has said anything.
        public static let unknown = Facts(place: .elsewhere)
    }

    // MARK: - The run's state

    public struct State: Equatable, Sendable {
        public internal(set) var step: Step
        /// The seeded book (*the adventures of sherlock holmes*), looked up at
        /// the start; nil ⇒ the tour accepts any book at step 2.
        public let seededBookID: String?
        /// Its first story (*A Scandal in Bohemia*) — step 3's ring.
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
        /// The place before the latest report — for "arrived from".
        var previousPlace: Place?
        /// The note box's liveness before the latest report — step 10's edge.
        var previousBookNoteLive: Bool

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
        case navigate(Place)
        /// Open the field guide (the Help menu's own door).
        case openFieldGuide
        /// The end card was reached: retire the offer as COMPLETED now, so a
        /// quit during the leg still counts.
        case recordCompleted
        /// The tour is over (`completed` says how it ended).
        case finish(completed: Bool)
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
            return Outcome(state: state, effects: effects)

        case .choose(let choice):
            guard state.step == .endCard else { return Outcome(state: state, effects: []) }
            switch choice {
            case .keepGoing:
                enter(.legStar, &state, &effects)
                settle(&state, &effects, freshReport: false)
                return Outcome(state: state, effects: effects)
            case .fieldGuide:
                return Outcome(state: nil, effects: [.openFieldGuide, .finish(completed: true)])
            case .done:
                return Outcome(state: nil, effects: [.finish(completed: true)])
            }

        case .facts(let facts):
            state.previousPlace = state.facts.place
            state.previousBookNoteLive = state.facts.bookNoteLive
            state.facts = facts
            settle(&state, &effects, freshReport: true)
            if state.step == .legEnd, let finished = finishAtGuide(state) {
                return Outcome(state: nil, effects: effects + finished)
            }
            return Outcome(state: state, effects: effects)
        }
    }

    /// The step after a "next" (only the next-bearing steps ask).
    static func nextStep(after step: Step) -> Step? {
        switch step {
        case .navigation: .seededBook
        case .takesMode: .deeperModes
        case .deeperModes: .placeFollows
        case .placeFollows: .downAndUp
        case .legSnippets: .legEnd
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
        case .navigation, .takesMode, .deeperModes, .placeFollows, .endCard:
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
                return .legEnd
            }
            return nil

        case .legEnd:
            return nil  // finishes at the field guide (`finishAtGuide`)
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
        remember(&state)
        let place = state.facts.place
        switch step {
        case .legStar, .legTags:
            if let own = state.ownNoteID, place != .note(own) { effects.append(.navigate(.note(own))) }
        case .legBook:
            if place != .area(.pool) { effects.append(.navigate(.area(.pool))) }
        case .legSnippets:
            if place != .area(.snippets) { effects.append(.navigate(.area(.snippets))) }
        case .legEnd:
            if place != .area(.bookcase) { effects.append(.navigate(.area(.bookcase))) }
        default:
            break
        }
    }

    /// The steps whose toured note is the note she is in.
    static let followsTheNote: Set<Step> = [
        .insideBook, .write, .makeTake, .takeIcon, .takesMode, .deeperModes, .placeFollows,
        .downAndUp,
    ]

    /// Fold the latest facts into the step's memories.
    static func remember(_ state: inout State) {
        let facts = state.facts
        // The toured note is whichever note she is in from step 3 to step 10:
        // the card asks for the first story, but every later step serves any
        // note, so the ring follows the one she actually took.
        if case .note(let id) = facts.place, followsTheNote.contains(state.step) {
            state.tourNoteID = id
        }
        switch state.step {
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
        case .endCard, .legStar, .legTags, .legBook, .legSnippets, .legEnd:
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

    /// **The rings, as ordered candidates.** Each inner list lights ONE ring:
    /// the first of its anchors that is actually on screen. A step with two
    /// lists lights two (step 6 points at the badge AND, while the panel is
    /// up, at its "Open Takes mode"). The first list's lit anchor is the one
    /// the card sits beside.
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
            // note but out of Write, the ring is the road back to it.
            if case .note = facts.place, facts.noteMode != .write { return [[.sidebarMode(.write)]] }
            return []
        case .makeTake:
            if case .note = facts.place, facts.noteMode != .write { return [[.sidebarMode(.write)]] }
            return facts.caret?.panelOpen == true ? [[.panelNewTake]] : [[.barTakes]]
        case .takeIcon:
            var groups: [[Anchor]] = [state.tourBlockID.map { [.takeBadge($0)] } ?? []]
            if facts.caret?.panelOpen == true { groups.append([.panelOpenTakesMode]) }
            return groups
        case .takesMode:
            return [state.tourBlockID.map { [.takesBlock($0)] } ?? []]
        case .deeperModes:
            return [[.sidebarMode(.lenses)]]
        case .placeFollows:
            switch facts.place {
            case .book:
                return [(state.tourNoteID.map { [Anchor.indexNoteRow($0)] } ?? [])
                        + [.bookModeTab(.index)]]
            case .note:
                return [[.contextBarBook]]
            default:
                return []
            }
        case .downAndUp:
            switch facts.place {
            case .book: return [[.noteBoxEditHere]]
            case .note: return [[.contextBarBook]]
            default: return []
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
        case .legEnd:
            guard facts.place == .area(.bookcase) else { return [[bookcase]] }
            return [state.fieldGuideID.map { [.bookcaseRow($0)] } ?? []]
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

    /// **Where a card goes.** Beside its anchor on the first preferred side
    /// where the whole card fits inside the container without covering the
    /// anchor; on none, its corner. The cross axis is clamped into the
    /// container.
    public static func place(
        card: (width: Double, height: Double), beside anchor: Rect?,
        in container: (width: Double, height: Double),
        sides: [Side], corner: Corner
    ) -> (x: Double, y: Double) {
        let m = cardMargin, g = cardGap
        func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double { min(max(v, lo), max(lo, hi)) }
        let maxX = container.width - card.width - m
        let maxY = container.height - card.height - m
        if let a = anchor {
            for side in sides {
                let x: Double, y: Double
                switch side {
                case .trailing:
                    x = a.maxX + g
                    y = clamp(a.y - 8, m, maxY)
                case .leading:
                    x = a.x - g - card.width
                    y = clamp(a.y - 8, m, maxY)
                case .below:
                    x = clamp(a.x, m, maxX)
                    y = a.maxY + g
                case .above:
                    x = clamp(a.maxX - card.width, m, maxX)
                    y = a.y - g - card.height
                }
                let fits = x >= m && y >= m && x <= maxX + 0.5 && y <= maxY + 0.5
                let covers = Rect(x: x, y: y, width: card.width, height: card.height).intersects(a)
                if fits && !covers { return (x, y) }
            }
        }
        switch corner {
        case .topTrailing: return (max(m, maxX), m)
        case .bottomLeading: return (m, max(m, maxY))
        case .bottomTrailing: return (max(m, maxX), max(m, maxY))
        case .center:
            return (max(m, (container.width - card.width) / 2),
                    max(m, container.height * 0.44 - card.height / 2))
        }
    }
}
