import Testing
@testable import VariorumCore

/// **13s-b U2 — THE TOUR, WALKED HEADLESSLY** (P-6: the tour is an executable
/// spec; a step a later phase breaks is a regression by definition). The rule
/// is pure (`Domain/Tour`), so every card of mockup v5 is walked here — the
/// main leg, the end card, the keep-going leg and the leg's end — with the
/// facts the real window reports, plus the tolerance cases the assessment
/// named (B2: Today's Entry; B3 and "wandering off": the ring re-anchors).
/// What a pure walk cannot show (the cards' faces, the rings on the real
/// doors) is the Mac suite's and the scripted walk's.
@Suite("13s-b U2 — the tour walked headlessly")
struct TourWalkTests {
    // The world: the seeded book, its first story, the field guide, a note of
    // her own, a journal entry, and two blocks of the story.
    static let sherlock = "book-sherlock"
    static let scandal = "note-scandal"
    static let league = "note-league"
    static let guide = "book-guide"
    static let mine = "note-mine"
    static let journalEntry = "note-journal"
    static let first = "block-1"
    static let middle = "block-40"

    /// A running tour plus everything it has asked the app to do.
    struct Walker {
        var state: Tour.State?
        var effects: [Tour.Effect] = []

        init(
            seededBookID: String? = TourWalkTests.sherlock,
            firstStoryID: String? = TourWalkTests.scandal,
            fieldGuideID: String? = TourWalkTests.guide,
            at place: Tour.Place = .area(.bookcase)
        ) {
            let outcome = Tour.start(
                seededBookID: seededBookID, firstStoryID: firstStoryID,
                fieldGuideID: fieldGuideID, facts: Tour.Facts(place: place))
            state = outcome.state
            effects = outcome.effects
        }

        var step: Tour.Step? { state?.step }

        @discardableResult
        mutating func send(_ event: Tour.Event) -> [Tour.Effect] {
            guard let state else { return [] }
            let outcome = Tour.reduce(state, event)
            self.state = outcome.state
            effects.append(contentsOf: outcome.effects)
            return outcome.effects
        }

        @discardableResult
        mutating func report(_ facts: Tour.Facts) -> [Tour.Effect] { send(.facts(facts)) }

        var rings: [[Tour.Anchor]] { state.map(Tour.ringGroups) ?? [] }
    }

    static func write(
        _ block: String, ordinal: Int, takes: Int = 1, panel: Bool = false,
        note: String = scandal
    ) -> Tour.Facts {
        Tour.Facts(
            place: .note(note), noteMode: .write,
            caret: Tour.Caret(
                noteID: note, blockID: block, ordinal: ordinal, takeCount: takes, panelOpen: panel))
    }

    static func ownNote(
        _ id: String = mine, starred: Bool = false, tags: Int = 0, books: Int = 0,
        place: Tour.Place? = nil
    ) -> Tour.Facts {
        Tour.Facts(
            place: place ?? .note(id), noteMode: .write,
            note: Tour.NoteFacts(noteID: id, starred: starred, tagCount: tags, bookCount: books))
    }

    /// Walk the main leg to a named step, the way she would.
    static func walk(to target: Tour.Step) -> Walker {
        var w = Walker()
        func at(_ step: Tour.Step) -> Bool { w.step == step || w.state == nil }
        if at(target) { return w }
        w.send(.next)                                                     // → seededBook
        if at(target) { return w }
        w.report(.init(place: .book(sherlock)))                           // → insideBook
        if at(target) { return w }
        w.report(.init(place: .note(scandal), noteMode: .write))          // → write
        w.report(write(first, ordinal: 1))
        if at(target) { return w }
        w.report(write(middle, ordinal: 40))                              // → makeTake
        if at(target) { return w }
        w.report(write(middle, ordinal: 40, panel: true))
        w.report(write(middle, ordinal: 40, takes: 2, panel: true))      // → takeIcon
        if at(target) { return w }
        w.report(.init(place: .note(scandal), noteMode: .takes))          // → takesMode
        if at(target) { return w }
        w.send(.next)                                                     // → deeperModes
        if at(target) { return w }
        w.send(.next)                                                     // → placeFollows
        if at(target) { return w }
        w.report(.init(place: .book(sherlock)))
        w.send(.next)                                                     // → downAndUp
        if at(target) { return w }
        w.report(.init(place: .book(sherlock), bookNoteLive: true))       // → home
        if at(target) { return w }
        w.report(.init(place: .area(.bookcase)))                          // → ownNote
        if at(target) { return w }
        w.report(ownNote())                                               // → endCard
        return w
    }

    // MARK: - The main leg, card by card

    @Test func theMainLegWalksEveryCardInOrderAndTheRingsPointWhereTheMockupDoes() {
        var w = Walker(at: .note("somewhere"))
        // A start is step 1, ON THE BOOKCASE (the tour begins where mockup v5's
        // step 1 frame stands).
        #expect(w.step == .navigation)
        #expect(w.effects == [.navigate(.area(.bookcase))])
        #expect(w.rings == [[.sidebarAreas]])

        w.report(.init(place: .area(.bookcase)))
        #expect(w.step == .navigation, "step 1 teaches; only next moves it")
        w.send(.next)
        #expect(w.step == .seededBook)
        #expect(w.rings == [[.bookcaseRow(Self.sherlock)]])

        w.report(.init(place: .book(Self.sherlock)))
        #expect(w.step == .insideBook)
        #expect(w.rings == [[.outlineCard(Self.scandal)]])

        w.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(w.step == .write)
        #expect(w.rings == [], "step 4's paragraph is hers to choose — no ring on the live text")
        w.report(Self.write(Self.first, ordinal: 1))
        #expect(w.step == .write, "the note's opening caret is not her click")
        w.report(Self.write(Self.middle, ordinal: 40))
        #expect(w.step == .makeTake)
        #expect(w.rings == [[.barTakes]])

        w.report(Self.write(Self.middle, ordinal: 40, panel: true))
        #expect(w.step == .makeTake)
        #expect(w.rings == [[.panelNewTake]], "with the panel up, the ring moves to its door")
        w.report(Self.write(Self.middle, ordinal: 40, takes: 2, panel: true))
        #expect(w.step == .takeIcon)
        #expect(w.state?.tourBlockID == Self.middle)
        #expect(w.rings == [[.panelOpenTakesMode]],
                "ONE ring: while the panel is up, its Open Takes mode is the act (A3)")
        w.report(Self.write(Self.middle, ordinal: 40, takes: 2, panel: false))
        #expect(w.rings == [[.takeBadge(Self.middle)]])

        w.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(w.step == .takesMode)
        #expect(w.rings == [[.takesBlock(Self.middle)]])
        w.send(.next)
        #expect(w.step == .deeperModes)
        #expect(w.rings == [[.sidebarMode(.lenses)]])
        w.send(.next)
        #expect(w.step == .placeFollows)
        #expect(w.rings == [[.contextBarBook]], "in the note, the ring is the climb's door")
        w.report(.init(place: .book(Self.sherlock)))
        #expect(w.rings == [[.indexNoteRow(Self.scandal), .bookModeTab(.index)]])
        #expect(w.step == .placeFollows, "step 9 teaches; only next moves it")
        w.send(.next)
        #expect(w.step == .downAndUp)
        #expect(w.rings == [[.noteBoxEditHere]])

        w.report(.init(place: .book(Self.sherlock), bookNoteLive: true))
        #expect(w.step == .home)
        #expect(w.rings == [[.sidebarArea(.bookcase)]])
        w.report(.init(place: .area(.bookcase)))
        #expect(w.step == .ownNote)
        #expect(w.rings == [[.quickEntry]])

        let before = w.effects.count
        w.report(.init(place: .note(Self.mine), noteMode: .write))
        #expect(w.step == .ownNote, "not hers until the store says it is bookless")
        w.report(Self.ownNote())
        #expect(w.step == .endCard)
        #expect(w.state?.ownNoteID == Self.mine)
        #expect(w.state?.completed == true)
        #expect(Array(w.effects[before...]) == [.recordCompleted],
                "the end card counts as completed the moment it arrives")
        #expect(w.rings == [])
    }

    @Test func theKeepGoingLegVisitsItsFourStopsAndEndsAtTheFieldGuide() {
        var w = Self.walk(to: .endCard)
        #expect(w.step == .endCard)
        w.effects = []

        w.send(.choose(.keepGoing))
        #expect(w.step == .legStar)
        #expect(w.effects == [], "she is already on her own note")
        #expect(w.rings == [[.sidebarOpenRow(Self.mine)]])

        w.report(Self.ownNote(starred: true))
        #expect(w.step == .legTags)
        #expect(w.rings == [[.mastheadTagDoor]])

        w.report(Self.ownNote(starred: true, tags: 1))
        #expect(w.step == .legBook)
        // The leg's own choreography — the Pool, with its in-gatherings run
        // open (F-U2-W-2: the star made her note a starred-notes match, which
        // the Pool tucks behind its masthead's "show").
        #expect(w.effects == [.navigate(.area(.pool)), .showPoolTucked])
        #expect(w.rings == [[.sidebarArea(.pool)]], "until the Pool is on screen")
        w.report(Self.ownNote(starred: true, tags: 1, place: .area(.pool)))
        #expect(w.rings == [[.poolAddToBook(Self.mine)]])

        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        #expect(w.step == .legSnippets)
        #expect(w.effects.last == .navigate(.area(.snippets)))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.snippets)))
        #expect(w.rings == [[.firstSnippetCard]])

        w.send(.next)
        #expect(w.step == .legEnd)
        #expect(w.effects.last == .navigate(.area(.bookcase)))
        w.report(.init(place: .area(.bookcase)))
        #expect(w.rings == [[.bookcaseRow(Self.guide)]])

        w.report(.init(place: .book(Self.sherlock)))
        #expect(w.step == .legEnd, "only the field guide finishes the leg")
        w.report(.init(place: .book(Self.guide)))
        #expect(w.state == nil)
        #expect(w.effects.last == .finish(completed: true))
    }

    @Test func theCountsReadAsTheMockupsCards() {
        let main: [(Tour.Step, Int, Bool)] = [
            (.navigation, 1, false), (.seededBook, 2, false), (.insideBook, 3, false),
            (.write, 4, false), (.makeTake, 5, false), (.takeIcon, 6, false),
            (.takesMode, 7, false), (.deeperModes, 8, false), (.placeFollows, 9, false),
            (.downAndUp, 10, false), (.home, 10, true), (.ownNote, 11, false),
        ]
        for (step, number, beat) in main {
            #expect(Tour.position(of: step) == .main(number: number, secondBeat: beat))
        }
        #expect(Tour.mainStepCount == 11)
        #expect(Tour.position(of: .endCard) == .endCard)
        let leg: [Tour.Step] = [.legStar, .legTags, .legBook, .legSnippets]
        for (i, step) in leg.enumerated() {
            #expect(Tour.position(of: step) == .leg(number: i + 1))
        }
        #expect(Tour.legStopCount == 4)
        #expect(Tour.position(of: .legEnd) == .legEnd)
        // The cards that teach carry next; every other card waits for her act.
        let nexting = Set(Tour.Step.allCases.filter(Tour.hasNext))
        #expect(nexting == [.navigation, .takesMode, .deeperModes, .placeFollows, .legSnippets])
        // End tour is always present — every coach card; the end card is the fork.
        #expect(Tour.Step.allCases.filter { !Tour.hasEndTour($0) } == [.endCard])
    }

    // MARK: - How it ends

    @Test func endTourBeforeTheEndCardEndsItAndAfterItTheTourCountsAsCompleted() {
        for step in [Tour.Step.navigation, .write, .takesMode, .ownNote] {
            var w = Self.walk(to: step)
            #expect(w.step == step)
            w.effects = []
            w.send(.endTour)
            #expect(w.state == nil)
            #expect(w.effects == [.finish(completed: false)], "\(step): ended, never completed")
        }
        for step in [Tour.Step.legStar, .legBook, .legEnd] {
            var w = Self.walk(to: .endCard)
            w.send(.choose(.keepGoing))
            if step != .legStar { w.report(Self.ownNote(starred: true, tags: 1)) }
            if step == .legEnd {
                w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
                w.send(.next)
            }
            #expect(w.step == step)
            w.effects = []
            w.send(.endTour)
            #expect(w.effects == [.finish(completed: true)], "\(step): the tour was completed")
        }
    }

    @Test func theEndCardsThreeChoices() {
        var guide = Self.walk(to: .endCard)
        guide.effects = []
        guide.send(.choose(.fieldGuide))
        #expect(guide.state == nil)
        #expect(guide.effects == [.openFieldGuide, .finish(completed: true)])

        var done = Self.walk(to: .endCard)
        done.effects = []
        done.send(.choose(.done))
        #expect(done.state == nil)
        #expect(done.effects == [.finish(completed: true)])

        // The choices belong to the end card alone.
        var early = Self.walk(to: .seededBook)
        early.send(.choose(.done))
        #expect(early.step == .seededBook)
    }

    @Test func aStartIsAlwaysStepOneAndOnTheBookcaseItMovesNothing() {
        let here = Walker(at: .area(.bookcase))
        #expect(here.step == .navigation)
        #expect(here.effects == [], "already on the Bookcase: nothing moves")
        let away = Walker(at: .book("x"))
        #expect(away.effects == [.navigate(.area(.bookcase))])
    }

    // MARK: - Tolerance: off-target clicks re-anchor, never strand

    @Test func wanderingOffAtStepTwoMovesTheRingToTheRoadBack() {
        var w = Self.walk(to: .seededBook)
        w.report(.init(place: .area(.library)))
        #expect(w.step == .seededBook)
        #expect(w.rings == [[.sidebarArea(.bookcase)]])
        w.report(.init(place: .area(.bookcase)))
        #expect(w.rings == [[.bookcaseRow(Self.sherlock)]])
        // Step 3, wandered home from the book: the road back into it.
        w.report(.init(place: .book(Self.sherlock)))
        w.report(.init(place: .area(.bookcase)))
        #expect(w.step == .insideBook)
        #expect(w.rings == [[.bookcaseRow(Self.sherlock)]])
    }

    /// A7 (PROVISIONAL P-U2-15): the card says "follow the ring back"
    /// exactly when the ring is a road back — never on a step's own road.
    @Test func theRoadBackIsSaidOnlyWhenTheRingIsOne() {
        var w = Self.walk(to: .seededBook)
        #expect(w.state.map(Tour.isRoadBack) == false, "on the Bookcase the row is the target")
        w.report(.init(place: .area(.library)))
        #expect(w.state.map(Tour.isRoadBack) == true)
        #expect(w.rings == [[.sidebarArea(.bookcase)]])

        var v = Self.walk(to: .write)
        v.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(v.state.map(Tour.isRoadBack) == true, "out of Write: the rail's Write is the way back")
        #expect(v.rings == [[.sidebarMode(.write)]])

        let u = Self.walk(to: .placeFollows)
        #expect(u.state.map(Tour.isRoadBack) == false, "step 9's book icon is its own road")
        var t = Self.walk(to: .home)
        #expect(t.state.map(Tour.isRoadBack) == false, "10b's Bookcase IS the step")
        t.report(.init(place: .area(.library)))
        #expect(t.state.map(Tour.isRoadBack) == false)
    }

    @Test func anyNoteServesStepThreeAndTheTourFollowsTheNoteSheTook() {
        var w = Self.walk(to: .insideBook)
        w.report(.init(place: .note(Self.league), noteMode: .write))
        #expect(w.step == .write)
        #expect(w.state?.tourNoteID == Self.league)
    }

    @Test func aMissingSeededBookAcceptsAnyBook() {
        var w = Walker(seededBookID: nil, firstStoryID: nil)
        w.send(.next)
        #expect(w.rings == [[]], "nothing to ring on the Bookcase; the card still speaks")
        w.report(.init(place: .book("any-book")))
        #expect(w.step == .insideBook)
    }

    @Test func todaysEntryIsNeverTakenForANoteOfHerOwn() {
        // The assessment's B2: Today's Entry clicked at step 11 opens a journal
        // entry, which lives in the daily Journal — the tour waits for hers.
        var w = Self.walk(to: .ownNote)
        w.report(Self.ownNote(Self.journalEntry, books: 1))
        #expect(w.step == .ownNote)
        #expect(w.rings == [[.sidebarArea(.bookcase)]], "the ring is the road back to the box")
        // Nor is the story she toured.
        w.report(Self.ownNote(Self.scandal, books: 0))
        #expect(w.step == .ownNote)
        w.report(.init(place: .area(.bookcase)))
        w.report(Self.ownNote())
        #expect(w.step == .endCard)
    }

    @Test func stepFourWantsAClickIntoAParagraphPastTheFirst() {
        var w = Self.walk(to: .write)
        w.report(Self.write(Self.first, ordinal: 1))
        w.report(Self.write("block-1b", ordinal: 1))
        #expect(w.step == .write, "the first paragraph is not the middle")
        w.report(Self.write("block-2", ordinal: 2))
        #expect(w.step == .makeTake)
        // A caret on ANOTHER note (an editor left standing) is not hers.
        var x = Self.walk(to: .write)
        x.report(Self.write(Self.first, ordinal: 1))
        x.report(Tour.Facts(
            place: .note(Self.scandal), noteMode: .write,
            caret: .init(noteID: "elsewhere", blockID: "b9", ordinal: 9, takeCount: 1)))
        #expect(x.step == .write)
    }

    @Test func aBlockThatAlreadyHadTakesMustGrowToCountAsMade() {
        // Q14: the toured take STAYS — a second tour clicking the same
        // paragraph finds it fanned already, and that is not "made".
        var w = Self.walk(to: .write)
        w.report(Self.write(Self.first, ordinal: 1))
        w.report(Self.write(Self.middle, ordinal: 40, takes: 2))
        #expect(w.step == .makeTake)
        w.report(Self.write(Self.middle, ordinal: 40, takes: 2, panel: true))
        #expect(w.step == .makeTake)
        w.report(Self.write(Self.middle, ordinal: 40, takes: 3, panel: true))
        #expect(w.step == .takeIcon)
        // A caret that moves resets the count it measures from.
        var v = Self.walk(to: .makeTake)
        v.report(Self.write("block-7", ordinal: 7, takes: 1))
        v.report(Self.write("block-7", ordinal: 7, takes: 2))
        #expect(v.step == .takeIcon)
        #expect(v.state?.tourBlockID == "block-7")
    }

    @Test func takesModeReachedAheadOfTheIconCardSkipsIt() {
        // The panel's own "Open Takes mode" pressed right after branching.
        var w = Self.walk(to: .makeTake)
        w.report(Tour.Facts(
            place: .note(Self.scandal), noteMode: .takes,
            caret: .init(noteID: Self.scandal, blockID: Self.middle, ordinal: 40, takeCount: 2)))
        #expect(w.step == .takesMode)
    }

    @Test func stepTenWaitsForItsOwnEdgeAndAcceptsEitherRoadDown() {
        // A box already live when the card arrives is not her act.
        var w = Self.walk(to: .placeFollows)
        w.report(.init(place: .book(Self.sherlock), bookNoteLive: true))
        w.send(.next)
        #expect(w.step == .downAndUp)
        w.report(.init(place: .book(Self.sherlock), bookNoteLive: true))
        #expect(w.step == .downAndUp)
        w.report(.init(place: .book(Self.sherlock), bookNoteLive: false))
        w.report(.init(place: .book(Self.sherlock), bookNoteLive: true))
        #expect(w.step == .home)
        // Down to the note's own page from the book counts too.
        var v = Self.walk(to: .downAndUp)
        v.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(v.step == .home)
        // A "next" never finds a stale edge.
        var u = Self.walk(to: .placeFollows)
        u.report(.init(place: .book(Self.sherlock)))
        u.report(.init(place: .note(Self.scandal), noteMode: .write))
        u.send(.next)
        #expect(u.step == .downAndUp)
    }

    @Test func goingHomeDuringStepTenSkipsTheHomeBeat() {
        var w = Self.walk(to: .downAndUp)
        w.report(.init(place: .area(.bookcase)))
        #expect(w.step == .ownNote)
    }

    @Test func leavingSnippetsByAnyRoadEndsTheLegsLastStop() {
        var w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(Self.ownNote(starred: true, tags: 1))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        w.report(.init(place: .area(.snippets)))
        #expect(w.step == .legSnippets)
        w.report(.init(place: .snippetGroup("group")))
        #expect(w.step == .legEnd)
        #expect(w.effects.last == .navigate(.area(.bookcase)))
    }

    @Test func nextIsInertOnACardThatWaitsForHerAct() {
        for step in [Tour.Step.seededBook, .write, .makeTake, .downAndUp, .ownNote] {
            var w = Self.walk(to: step)
            w.send(.next)
            #expect(w.step == step, "\(step) has no next")
        }
    }

    @Test func theAppObservesExactlyTheNoteTheStepNeeds() {
        var w = Self.walk(to: .takesMode)
        #expect(w.state.flatMap(Tour.noteOfInterest) == nil)
        w = Self.walk(to: .ownNote)
        w.report(.init(place: .note(Self.mine)))
        #expect(w.state.flatMap(Tour.noteOfInterest) == Self.mine)
        w.report(.init(place: .note(Self.scandal)))
        #expect(w.state.flatMap(Tour.noteOfInterest) == nil, "the toured story is never a candidate")
        w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(.init(place: .area(.library)))
        #expect(w.state.flatMap(Tour.noteOfInterest) == Self.mine)
    }

    // MARK: - Where a card sits

    @Test func aCardSitsBesideItsAnchorInsideTheWindowAndNeverOverIt() {
        let container = (width: 1100.0, height: 700.0)
        let card = (width: 300.0, height: 160.0)
        let sides: [Tour.Side] = [.trailing, .below, .leading, .above]
        // A small anchor with room to its right: beside it, top-aligned-ish.
        let small = Tour.Rect(x: 20, y: 200, width: 170, height: 30)
        let a = Tour.place(card: card, beside: small, in: container, sides: sides, corner: .topTrailing)
        #expect(a.x == small.maxX + Tour.cardGap)
        // A full-width row: no side room, so below it.
        let row = Tour.Rect(x: 220, y: 200, width: 860, height: 36)
        let b = Tour.place(card: card, beside: row, in: container, sides: sides, corner: .topTrailing)
        #expect(b.y == row.maxY + Tour.cardGap)
        // The quick entry at the window's foot: above it.
        let box = Tour.Rect(x: 220, y: 620, width: 860, height: 44)
        let c = Tour.place(
            card: card, beside: box, in: container,
            sides: Tour.preferredSides(.ownNote), corner: .topTrailing)
        #expect(c.y + card.height <= box.y)
        // Nothing to sit beside: the corner.
        let d = Tour.place(card: card, beside: nil, in: container, sides: sides, corner: .bottomLeading)
        #expect(d.x == Tour.cardMargin)
        #expect(d.y == container.height - card.height - Tour.cardMargin)
        // Every placement lies inside the window and off its anchor.
        for (anchor, p) in [(small, a), (row, b), (box, c)] {
            let placed = Tour.Rect(x: p.x, y: p.y, width: card.width, height: card.height)
            #expect(placed.x >= Tour.cardMargin && placed.maxX <= container.width - Tour.cardMargin + 0.5)
            #expect(placed.y >= Tour.cardMargin && placed.maxY <= container.height - Tour.cardMargin + 0.5)
            #expect(!placed.intersects(anchor))
        }
    }

    /// A2 (the U2 UI assessment's placement pattern): a card never covers a
    /// keep-clear region (the sidebar, a masthead, a bottom bar) or the ring
    /// it points at — it is PUSHED to the first free gutter along its side,
    /// and with no side free it takes a clear corner.
    @Test func aCardAvoidsTheKeepClearRegionsAndTheRingsOwnFrame() {
        let container = (width: 1100.0, height: 700.0)
        let card = (width: 300.0, height: 160.0)
        let sides: [Tour.Side] = [.trailing, .below, .leading, .above]
        let sidebar = Tour.Rect(x: 0, y: 0, width: 220, height: 700)
        let masthead = Tour.Rect(x: 220, y: 0, width: 880, height: 80)
        let bottomBar = Tour.Rect(x: 220, y: 664, width: 880, height: 36)
        let avoid = [sidebar, masthead, bottomBar]
        func rect(_ p: (x: Double, y: Double)) -> Tour.Rect {
            Tour.Rect(x: p.x, y: p.y, width: card.width, height: card.height)
        }
        func clear(_ p: (x: Double, y: Double), of anchor: Tour.Rect) -> Bool {
            let r = rect(p)
            let ring = Tour.Rect(
                x: anchor.x - Tour.ringClearance, y: anchor.y - Tour.ringClearance,
                width: anchor.width + 2 * Tour.ringClearance,
                height: anchor.height + 2 * Tour.ringClearance)
            return !avoid.contains { r.intersects($0) } && !r.intersects(ring)
                && r.x >= Tour.cardMargin && r.maxX <= container.width - Tour.cardMargin + 0.5
                && r.y >= Tour.cardMargin && r.maxY <= container.height - Tour.cardMargin + 0.5
        }

        // A sidebar row: the card is pushed past the sidebar into the first
        // gutter right of it, never over the navigation.
        let row = Tour.Rect(x: 10, y: 120, width: 170, height: 28)
        let a = Tour.place(card: card, beside: row, in: container, sides: sides,
                           corner: .topTrailing, avoid: avoid)
        #expect(a.x == sidebar.maxX + Tour.cardGap, "the first gutter right of the sidebar")
        #expect(clear(a, of: row))

        // The masthead's ＃: below it, pushed past the masthead.
        let tagDoor = Tour.Rect(x: 1000, y: 40, width: 24, height: 24)
        let b = Tour.place(card: card, beside: tagDoor, in: container, sides: sides,
                           corner: .topTrailing, avoid: avoid)
        #expect(b.y >= masthead.maxY + Tour.cardGap, "never on the masthead")
        #expect(clear(b, of: tagDoor))

        // Write's bar door at the foot: above it, never on the bar.
        let barDoor = Tour.Rect(x: 400, y: 670, width: 50, height: 22)
        let c = Tour.place(card: card, beside: barDoor, in: container, sides: sides,
                           corner: .topTrailing, avoid: avoid)
        #expect(clear(c, of: barDoor))

        // Nothing to sit beside and the step's corner blocked: a clear corner.
        let topRightBlock = Tour.Rect(x: 700, y: 0, width: 400, height: 300)
        let d = Tour.place(card: card, beside: nil, in: container, sides: sides,
                           corner: .topTrailing, avoid: avoid + [topRightBlock])
        #expect(!rect(d).intersects(topRightBlock), "the next corner, clear")

        // The pre-A2 placement still holds where nothing is in the way.
        let free = Tour.place(card: card, beside: row, in: container, sides: sides,
                              corner: .topTrailing)
        #expect(free.x == row.maxX + Tour.cardGap)
    }

    @Test func thePanelsDoorsTakeTheCornerAndOnlyTheBadgeIsAppKit() {
        let all: [Tour.Anchor] = [
            .sidebarAreas, .sidebarArea(.bookcase), .sidebarMode(.lenses), .sidebarOpenRow("n"),
            .bookcaseRow("b"), .quickEntry, .outlineCard("n"), .bookModeTab(.index),
            .indexNoteRow("n"), .noteBoxEditHere, .barTakes, .panelNewTake,
            .panelOpenTakesMode, .takeBadge("k"), .takesBlock("k"), .contextBarBook,
            .mastheadTagDoor, .poolAddToBook("n"), .firstSnippetCard,
        ]
        #expect(all.filter(\.isInPanel) == [.panelNewTake, .panelOpenTakesMode])
        #expect(all.filter(\.isAppKit) == [.takeBadge("k")])
        #expect(Tour.fallbackCorner(.makeTake) == .bottomLeading,
                "the mockup's step 5 card sits clear of the panel, bottom left")
    }
}
