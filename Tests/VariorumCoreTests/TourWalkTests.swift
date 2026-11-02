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
        place: Tour.Place? = nil, asks: Tour.ClosingAsks? = nil
    ) -> Tour.Facts {
        Tour.Facts(
            place: place ?? .note(id), noteMode: .write,
            note: Tour.NoteFacts(noteID: id, starred: starred, tagCount: tags, bookCount: books),
            asks: asks)
    }

    /// VX-735 — a library that still owes both closing asks (a fresh store:
    /// no passphrase, the words never recorded here).
    static let bothOwed = Tour.ClosingAsks(passphrase: true, words: true)

    // VX-292 U3 — the flip's block: Marriott's English (chosen), her own take
    // from step 5, and the Italian the card names.
    static let english = "take-marriott"
    static let hers = "take-hers"
    static let italian = "take-italian"

    /// Step 7's block as the store says it, in Takes.
    static func flip(
        _ chosen: String, block: String = middle, note: String = scandal,
        takes: [String] = [english, hers, italian], named: String? = italian
    ) -> Tour.Facts {
        Tour.Facts(
            place: .note(note), noteMode: .takes,
            block: Tour.BlockFacts(
                noteID: note, blockID: block, chosenTakeID: chosen, takeIDs: takes,
                namedTakeID: named))
    }

    /// The note on its Lenses board, `columns` wide.
    static func lenses(_ columns: Int?, note: String = scandal) -> Tour.Facts {
        Tour.Facts(place: .note(note), noteMode: .lenses, lensColumns: columns)
    }

    /// The seeded book in a mode.
    static func book(
        _ mode: Tour.BookMode?, live: Bool = false, selected: Bool = false,
        id: String = sherlock
    ) -> Tour.Facts {
        Tour.Facts(
            place: .book(id), bookNoteLive: live, bookNoteSelected: selected, bookMode: mode)
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
        w.report(flip(english))
        if at(target) { return w }
        w.report(flip(italian))                                           // → takesFlipBack
        if at(target) { return w }
        w.report(flip(english))                                           // → readInNote
        if at(target) { return w }
        w.report(.init(place: .note(scandal), noteMode: .read))
        w.send(.next)                                                     // → lensesLive
        if at(target) { return w }
        w.report(lenses(1))
        w.report(lenses(2))                                               // → deeperModes
        if at(target) { return w }
        w.send(.next)                                                     // → upToBook
        if at(target) { return w }
        w.report(book(.outline))
        w.send(.next)                                                     // → bookAndRead
        if at(target) { return w }
        w.report(book(.book))
        w.report(book(.read))                                             // → downAndUp
        if at(target) { return w }
        w.report(book(.index, live: true))                                // → home
        if at(target) { return w }
        w.report(.init(place: .area(.bookcase)))                          // → ownNote
        if at(target) { return w }
        // VX-735: the closing cards show only while their asks are owed —
        // the walk reaches them on a library that owes both; every other
        // target walks a world with no protection faces, whose close is the
        // end card alone (as the end card drew without its asks there).
        if target == .protectPassphrase || target == .protectWords {
            w.report(ownNote(asks: bothOwed))                             // → protectPassphrase
            if at(target) { return w }
            w.send(.next)                                                 // → protectWords
            return w
        }
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
        #expect(w.rings == [[.takesBlock(Self.middle)]], "the block, until the store says its takes")
        // VX-292 U3 — step 7's flip: the Italian's choose band, then back.
        w.report(Self.flip(Self.english))
        #expect(w.step == .takesMode, "seeing the block is not the act")
        #expect(w.rings == [[.takeChoose(Self.italian), .takesBlock(Self.middle)]],
                "the take the card names, the block behind it (\(w.rings))")
        w.report(Self.flip(Self.italian))
        #expect(w.step == .takesFlipBack, "the page reads Italian")
        #expect(w.rings == [[.takeChoose(Self.english), .takesBlock(Self.middle)]],
                "the English take brings it back")
        w.report(Self.flip(Self.english))
        #expect(w.step == .readInNote)

        // Step 8 — Read in the note: the rail's Read, then its switch.
        #expect(w.rings == [[.sidebarMode(.read)]])
        w.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(w.step == .readInNote, "step 8 teaches; only next moves it")
        #expect(w.rings == [[.readFaceSwitch]])
        w.send(.next)

        // Step 9 — Lenses, live: the rail's Lenses, then the ＋ column door.
        #expect(w.step == .lensesLive)
        #expect(w.rings == [[.sidebarMode(.lenses)]])
        w.report(Self.lenses(1))
        #expect(w.step == .lensesLive)
        #expect(w.rings == [[.lensAddColumn]])
        w.report(Self.lenses(2))
        #expect(w.step == .deeperModes, "a column beside the note's own is the act")

        // Step 10 — Compare and Blocks, briefly.
        #expect(w.rings == [[.sidebarMode(.compare)]])
        w.send(.next)

        // Step 11 — the book arc (R-292-10): up, Book then Read, down and up.
        #expect(w.step == .upToBook)
        #expect(w.rings == [[.contextBarBook]], "in the note, the ring is the climb's door")
        w.report(Self.book(.outline))
        #expect(w.step == .upToBook, "the first beat describes the book; only next moves it")
        #expect(w.rings == [], "nothing to ring: the card describes the views along the top")
        w.send(.next)
        #expect(w.step == .bookAndRead)
        #expect(w.rings == [[.bookModeTab(.book)]])
        w.report(Self.book(.book))
        #expect(w.step == .bookAndRead)
        #expect(w.rings == [[.bookModeTab(.read)]])
        w.report(Self.book(.read))
        #expect(w.step == .downAndUp)
        // F-U2-W-3: in Read the box holds nothing, so the ring is the toured
        // note's Index row with the Index tab behind it (the road back).
        #expect(w.rings == [[.indexNoteRow(Self.scandal), .bookModeTab(.index)]])
        w.report(Self.book(.index, selected: true))
        #expect(w.rings == [[.noteBoxEditHere]])

        w.report(Self.book(.index, live: true))
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

    @Test func theKeepGoingLegVisitsItsFiveStopsAndEndsAtTheFieldGuide() {
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

        // VX-292 U3 (R-292-8) — leg 5, the Settings stop: Settings opens on
        // its General pane (its own window — nothing here rings), the card
        // stays and carries next.
        w.effects = []
        w.send(.next)
        #expect(w.step == .legSettings)
        #expect(w.effects == [.openSettings], "Settings opens, once (\(w.effects))")
        #expect(w.rings == [])
        #expect(w.state.map(Tour.isRoadBack) == false)
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.library)))
        #expect(w.step == .legSettings, "only next moves the Settings stop")
        #expect(w.effects == [.openSettings], "never asked twice")

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

    /// VX-292 U3 — R-292-13's approved flow, as the cards count it: thirteen
    /// main steps (7 in two beats, 11 in three), a five-stop leg.
    @Test func theCountsReadAsTheApprovedFlow() {
        let main: [(Tour.Step, Int, Int)] = [
            (.navigation, 1, 1), (.seededBook, 2, 1), (.insideBook, 3, 1),
            (.write, 4, 1), (.makeTake, 5, 1), (.takeIcon, 6, 1),
            (.takesMode, 7, 1), (.takesFlipBack, 7, 2), (.readInNote, 8, 1),
            (.lensesLive, 9, 1), (.deeperModes, 10, 1),
            (.upToBook, 11, 1), (.bookAndRead, 11, 2), (.downAndUp, 11, 3),
            (.home, 12, 1), (.ownNote, 13, 1),
        ]
        for (step, number, beat) in main {
            #expect(Tour.position(of: step) == .main(number: number, beat: beat), "\(step)")
        }
        #expect(main.count == Tour.Step.allCases.firstIndex(of: .protectPassphrase),
                "the table is every main card, in the enum's order")
        #expect(Tour.mainStepCount == 13)
        #expect(Set(main.map(\.1)) == Set(1...Tour.mainStepCount), "every number, none skipped")
        #expect(Tour.position(of: .endCard) == .endCard)
        // VX-735: the closing cards follow step 13 and carry no count.
        #expect(Tour.position(of: .protectPassphrase) == .closing)
        #expect(Tour.position(of: .protectWords) == .closing)
        #expect(Array(Tour.Step.allCases[main.count...].prefix(3))
                == [.protectPassphrase, .protectWords, .endCard], "passphrase, words, then the end card")
        let leg: [Tour.Step] = [.legStar, .legTags, .legBook, .legSnippets, .legSettings]
        for (i, step) in leg.enumerated() {
            #expect(Tour.position(of: step) == .leg(number: i + 1))
        }
        #expect(Tour.legStopCount == 5)
        #expect(Tour.position(of: .legEnd) == .legEnd)
        // The cards that teach carry next; every other card waits for her act.
        let nexting = Set(Tour.Step.allCases.filter(Tour.hasNext))
        #expect(nexting == [.navigation, .takesMode, .takesFlipBack, .readInNote, .deeperModes,
                            .upToBook, .protectPassphrase, .protectWords, .legSnippets, .legSettings])
        // End tour is always present — every coach card; the end card is the fork.
        #expect(Tour.Step.allCases.filter { !Tour.hasEndTour($0) } == [.endCard])
    }

    // MARK: - The close (VX-735 — the end card's asks, each a card of its own)

    /// **VX-735 — the split.** On a library that owes both asks, step 13's
    /// own note brings the PASSPHRASE card (rule 3's ask), whose next brings
    /// the WORDS card (rule 2's look), whose next brings the end card. The
    /// close counts as completed the moment its first card arrives — where
    /// the end card and its asks used to arrive — and only once. Each
    /// closing card is centred (nothing rung, never a road back) and carries
    /// next and End tour.
    @Test func theCloseIsThePassphraseThenTheWordsThenTheEndCard() {
        var w = Self.walk(to: .ownNote)
        let before = w.effects.count
        w.report(Self.ownNote(asks: Self.bothOwed))
        #expect(w.step == .protectPassphrase)
        #expect(w.state?.completed == true)
        #expect(w.state?.ownNoteID == Self.mine)
        #expect(Array(w.effects[before...]) == [.recordCompleted],
                "the close counts as completed the moment its first card arrives")
        for step in [Tour.Step.protectPassphrase, .protectWords] {
            #expect(Tour.hasNext(step) && Tour.hasEndTour(step), "\(step): next and End tour")
            #expect(Tour.fallbackCorner(step) == .center, "\(step): centred like the end card")
        }
        #expect(w.rings == [])
        #expect(w.state.map(Tour.isRoadBack) == false)
        // A report that changes nothing owed keeps the card.
        w.report(Self.ownNote(asks: Self.bothOwed))
        #expect(w.step == .protectPassphrase)
        w.send(.next)
        #expect(w.step == .protectWords)
        #expect(w.rings == [])
        #expect(w.state.map(Tour.isRoadBack) == false)
        w.report(Self.ownNote(asks: Self.bothOwed))
        #expect(w.step == .protectWords)
        w.send(.next)
        #expect(w.step == .endCard)
        #expect(w.effects.filter { $0 == .recordCompleted }.count == 1, "completed once")
        // The end card's three ways on are unchanged.
        w.send(.choose(.keepGoing))
        #expect(w.step == .legStar)
    }

    /// End tour on a closing card ends a COMPLETED tour (the thirteen steps
    /// are done; the close had arrived), and the end card's choices belong
    /// to the end card alone.
    @Test func endTourOnAClosingCardEndsACompletedTour() {
        for step in [Tour.Step.protectPassphrase, .protectWords] {
            var w = Self.walk(to: step)
            #expect(w.step == step)
            w.send(.choose(.done))
            #expect(w.step == step, "\(step): the end card's choices are the end card's")
            w.effects = []
            w.send(.endTour)
            #expect(w.state == nil)
            #expect(w.effects == [.finish(completed: true)], "\(step): completed")
        }
    }

    // MARK: - The suppression (VX-736 R-736-5 — a card shows only while its ask is owed)

    /// **R-736-5 — her *"we also have to make sure that this pane doesn't
    /// show if they already recorded their 12 words and stuff"*.** The five
    /// fixture worlds, as the library's faces say them (`Facts.asks`): a
    /// FRESH library owes both (the passphrase card first); a PASSPHRASE-SET
    /// library owes only the words (the passphrase card is skipped); a
    /// WORDS-RECORDED library owes only the passphrase (its next goes
    /// straight to the end card); BOTH done owes nothing (the end card at
    /// once); a LANDED ACCOUNT act marks the words recorded (the band's one
    /// ledger — VX-511), so it reads as words-recorded; and no faces at all
    /// (nil) skip both. Every world completes the tour once, at its close's
    /// first card. RED-ON-OLD (headless watch, the record): with a closing
    /// card's advance blind to the asks, every skipping row stays on a card
    /// that should not show.
    @Test func aClosingCardShowsOnlyWhileItsAskIsOwed() {
        struct World {
            let name: String
            let asks: Tour.ClosingAsks?
            /// The card step 13 lands on, then where next goes from it.
            let lands: Tour.Step
            let nextGoes: Tour.Step?
        }
        let worlds = [
            World(name: "fresh", asks: .init(passphrase: true, words: true),
                  lands: .protectPassphrase, nextGoes: .protectWords),
            World(name: "passphrase set", asks: .init(passphrase: false, words: true),
                  lands: .protectWords, nextGoes: .endCard),
            World(name: "words recorded", asks: .init(passphrase: true, words: false),
                  lands: .protectPassphrase, nextGoes: .endCard),
            World(name: "both done", asks: .init(passphrase: false, words: false),
                  lands: .endCard, nextGoes: nil),
            World(name: "landed account (words recorded by the act; passphrase typed)",
                  asks: .init(passphrase: false, words: false), lands: .endCard, nextGoes: nil),
            World(name: "landed account, no passphrase typed here", asks: .init(passphrase: true, words: false),
                  lands: .protectPassphrase, nextGoes: .endCard),
            World(name: "no protection faces", asks: nil, lands: .endCard, nextGoes: nil),
        ]
        for world in worlds {
            var w = Self.walk(to: .ownNote)
            let before = w.effects.count
            w.report(Self.ownNote(asks: world.asks))
            #expect(w.step == world.lands, "\(world.name): lands on \(String(describing: w.step))")
            #expect(Array(w.effects[before...]) == [.recordCompleted], "\(world.name): completed once, at once")
            if let next = world.nextGoes {
                w.send(.next)
                #expect(w.step == next, "\(world.name): next goes to \(String(describing: w.step))")
            }
            #expect(w.effects.filter { $0 == .recordCompleted }.count == 1, "\(world.name): never twice")
        }
    }

    /// **An ask answered on its own card moves on** (the tolerance rule: a
    /// step already satisfied advances). The passphrase set here retires the
    /// passphrase card — the words card follows; the look closing past its
    /// warning records the words — the end card follows. A report that
    /// still owes the card's ask keeps it, whatever else it says.
    @Test func anAskAnsweredOnItsCardMovesOn() {
        var w = Self.walk(to: .protectPassphrase)
        #expect(w.step == .protectPassphrase)
        w.report(Self.ownNote(asks: .init(passphrase: true, words: false)))
        #expect(w.step == .protectPassphrase, "still owed: the words' state is not this card's")
        w.report(Self.ownNote(asks: .init(passphrase: false, words: true)))
        #expect(w.step == .protectWords, "the passphrase set here: on to the words")
        w.report(Self.ownNote(asks: .init(passphrase: false, words: true)))
        #expect(w.step == .protectWords, "the words card waits for her (the look, or next)")
        w.report(Self.ownNote(asks: .init(passphrase: false, words: false)))
        #expect(w.step == .endCard, "the words recorded here: on to the end card")
        #expect(w.effects.filter { $0 == .recordCompleted }.count == 1)
    }

    // MARK: - How it ends

    @Test func endTourBeforeTheEndCardEndsItAndAfterItTheTourCountsAsCompleted() {
        for step in [Tour.Step.navigation, .write, .takesMode, .takesFlipBack, .readInNote,
                     .lensesLive, .upToBook, .bookAndRead, .ownNote] {
            var w = Self.walk(to: step)
            #expect(w.step == step)
            w.effects = []
            w.send(.endTour)
            #expect(w.state == nil)
            #expect(w.effects == [.finish(completed: false)], "\(step): ended, never completed")
        }
        for step in [Tour.Step.legStar, .legBook, .legSettings, .legEnd] {
            var w = Self.walk(to: .endCard)
            w.send(.choose(.keepGoing))
            if step != .legStar { w.report(Self.ownNote(starred: true, tags: 1)) }
            if step == .legSettings || step == .legEnd {
                w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
                w.send(.next)
            }
            if step == .legEnd { w.send(.next) }
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

        let u = Self.walk(to: .upToBook)
        #expect(u.state.map(Tour.isRoadBack) == false, "step 11's book icon is its own road")
        var t = Self.walk(to: .home)
        #expect(t.state.map(Tour.isRoadBack) == false, "step 12's Bookcase IS the step")
        t.report(.init(place: .area(.library)))
        #expect(t.state.map(Tour.isRoadBack) == false)
        // VX-292 U3: the rail's Read and Lenses are steps 8 and 9's own doors.
        var r = Self.walk(to: .readInNote)
        #expect(r.rings == [[.sidebarMode(.read)]])
        #expect(r.state.map(Tour.isRoadBack) == false, "the rail's Read is step 8's own door")
        r.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(r.rings == [[.readFaceSwitch]])
        #expect(r.state.map(Tour.isRoadBack) == false)
        var l = Self.walk(to: .lensesLive)
        l.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(l.rings == [[.sidebarMode(.lenses)]])
        #expect(l.state.map(Tour.isRoadBack) == false, "the rail's Lenses is step 9's own door")
        // Step 11's second beat, down in the note: the book icon is the way
        // back up, and the card says so.
        var b = Self.walk(to: .bookAndRead)
        b.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(b.rings == [[.contextBarBook]])
        #expect(b.state.map(Tour.isRoadBack) == true)
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

    /// Step 11's last beat (the old step 10, its card verbatim): it waits
    /// for its OWN edge — the box going live, or down to the note's page from
    /// the book — and either road down counts.
    @Test func stepElevensLastBeatWaitsForItsOwnEdgeAndAcceptsEitherRoadDown() {
        // A box already live when the beat arrives is not her act. In the app
        // the second beat ends in the book's Read, whose box is empty, so the
        // first report after it that shows a live box IS her edge; the rule's
        // own guard (a box live on the report the beat arrived with waits)
        // is held below with a box reported live through the arrival.
        var w = Self.walk(to: .downAndUp)
        w.report(Self.book(.index, live: true))
        #expect(w.step == .home, "from Read (no box) to a live box IS the edge")
        var x = Self.walk(to: .bookAndRead)
        x.report(Self.book(.book, live: true))
        x.report(Self.book(.read, live: true))
        #expect(x.step == .downAndUp)
        x.report(Self.book(.read, live: true))
        #expect(x.step == .downAndUp, "a box live when the beat arrived waits for her act")
        x.report(Self.book(.index, live: false))
        x.report(Self.book(.index, live: true))
        #expect(x.step == .home)
        // Down to the note's own page from the book counts too.
        var v = Self.walk(to: .downAndUp)
        v.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(v.step == .home)
        // A beat that ends in the note (her road down, before Read) never
        // leaves a stale edge for the next one.
        var u = Self.walk(to: .bookAndRead)
        u.report(.init(place: .note(Self.scandal), noteMode: .write))
        u.report(Self.book(.read))
        #expect(u.step == .downAndUp, "back up and Read: the second beat's act")
        #expect(u.step != .home, "the climb back up is not the way down")
    }

    @Test func goingHomeDuringStepElevenSkipsTheHomeStep() {
        var w = Self.walk(to: .downAndUp)
        w.report(.init(place: .area(.bookcase)))
        #expect(w.step == .ownNote)
    }

    @Test func leavingSnippetsByAnyRoadEndsTheSnippetsStop() {
        var w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(Self.ownNote(starred: true, tags: 1))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        w.report(.init(place: .area(.snippets)))
        #expect(w.step == .legSnippets)
        w.report(.init(place: .snippetGroup("group")))
        #expect(w.step == .legSettings, "VX-292 U3: the Settings stop is next")
        #expect(w.effects.last == .openSettings)
    }

    /// Round 1 MINOR-1 (the U2 ladder): wandering off the NOTE entirely
    /// during the tour's middle re-anchors the ring on the toured note's own
    /// Open-strip row — the road back, the legs' own shape — and the
    /// road-back sentence is earned. On the note with the step's target
    /// merely scrolled away, nothing rings and nothing is said (the
    /// implementer's refinement at the round-1 exchange: A7's contradiction,
    /// inverted, must not appear).
    @Test func anAreaWanderDuringTheMiddleStepsRingsTheRoadBackToTheNote() {
        for step in [Tour.Step.write, .makeTake, .takeIcon, .takesMode, .takesFlipBack,
                     .readInNote, .lensesLive, .deeperModes, .upToBook, .bookAndRead] {
            var w = Self.walk(to: step)
            w.report(.init(place: .area(.library)))
            #expect(w.step == step)
            #expect(w.rings == [[.sidebarOpenRow(Self.scandal)]],
                    "\(step): the Open row is the road back (\(w.rings))")
            #expect(w.state.map(Tour.isRoadBack) == true, "\(step): the card says so")
        }
        // Step 11's last beat wanders to a non-Bookcase area the same way
        // (the Bookcase itself advances it — the home skip, pinned elsewhere).
        var t = Self.walk(to: .downAndUp)
        t.report(.init(place: .area(.library)))
        #expect(t.step == .downAndUp)
        #expect(t.rings == [[.sidebarOpenRow(Self.scandal)]])
        #expect(t.state.map(Tour.isRoadBack) == true)
        // In the note but out of the step's mode, the rail is the road back
        // (step 7 gains Takes; step 6 keeps Write) — never the Open row.
        var v = Self.walk(to: .takesMode)
        v.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(v.rings == [[.sidebarMode(.takes)]])
        #expect(v.state.map(Tour.isRoadBack) == true)
        var u = Self.walk(to: .takeIcon)
        u.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(u.rings == [[.sidebarMode(.write)]])
        #expect(u.state.map(Tour.isRoadBack) == true)
        // On the note in the step's own mode, the fallback never fires: the
        // step's own ring stands (lit or not), and no road back is claimed.
        var s = Self.walk(to: .takeIcon)
        s.report(Self.write(Self.middle, ordinal: 40, takes: 2))
        #expect(s.rings == [[.takeBadge(Self.middle)]])
        #expect(s.state.map(Tour.isRoadBack) == false)
    }

    /// Round 1 MINOR-2 (the U2 ladder): leaving Snippets straight INTO the
    /// field guide is the leg's finish — the tour never navigates away from
    /// the guide she just opened. Every other exit keeps the designed yank
    /// home (P-U2-7's choreography).
    @Test func leavingSnippetsIntoTheFieldGuideFinishesWithoutYankingHerHome() {
        var w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(Self.ownNote(starred: true, tags: 1))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        w.report(.init(place: .area(.snippets)))
        #expect(w.step == .legSnippets)
        w.effects = []
        w.report(.init(place: .book(Self.guide)))
        #expect(w.state == nil)
        #expect(w.effects == [.finish(completed: true)],
                "no navigate off the guide, and no Settings raised over it: \(w.effects)")
        // A non-guide exit moves on as designed — VX-292 U3: to the Settings
        // stop (Settings opens), whose next heads home.
        var v = Self.walk(to: .endCard)
        v.send(.choose(.keepGoing))
        v.report(Self.ownNote(starred: true, tags: 1))
        v.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        v.report(.init(place: .area(.snippets)))
        v.effects = []
        v.report(.init(place: .book(Self.sherlock)))
        #expect(v.step == .legSettings)
        #expect(v.effects == [.openSettings])
        v.send(.next)
        #expect(v.step == .legEnd)
        #expect(v.effects == [.openSettings, .navigate(.area(.bookcase))])
        // …and opening the guide at the Settings stop finishes there too.
        var s = Self.walk(to: .endCard)
        s.send(.choose(.keepGoing))
        s.report(Self.ownNote(starred: true, tags: 1))
        s.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        s.send(.next)
        #expect(s.step == .legSettings)
        s.effects = []
        s.report(.init(place: .book(Self.guide)))
        #expect(s.state == nil)
        #expect(s.effects == [.finish(completed: true)])
    }

    /// Round 2 (the U2 ladder): the `.next` road into the leg's end while she
    /// is ALREADY at the field guide — her report from the guide landed
    /// before the leg's navigate settled, so leg 4 kept her — finishes there,
    /// exactly as the facts road does. Neither a navigate off the guide nor a
    /// silent stall: `finishAtGuide` speaks on both roads.
    @Test func nextAtLegFourWhileAlreadyAtTheGuideFinishesThereInsteadOfStalling() {
        var w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(Self.ownNote(starred: true, tags: 1))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        #expect(w.step == .legSnippets)
        // Her ⌘K to the guide lands BEFORE the leg's navigate settles:
        // previousPlace is the Pool, not Snippets, so leg 4 keeps her.
        w.report(.init(place: .book(Self.guide)))
        #expect(w.step == .legSnippets)
        w.effects = []
        w.send(.next)
        #expect(w.state == nil)
        #expect(w.effects == [.finish(completed: true)],
                "finish, not a stall: \(w.effects)")
        // At Snippets, the same press moves on to the Settings stop (VX-292
        // U3), and ITS next keeps the designed yank home (P-U2-7).
        var v = Self.walk(to: .endCard)
        v.send(.choose(.keepGoing))
        v.report(Self.ownNote(starred: true, tags: 1))
        v.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        v.report(.init(place: .area(.snippets)))
        v.effects = []
        v.send(.next)
        #expect(v.step == .legSettings)
        #expect(v.effects == [.openSettings])
        v.send(.next)
        #expect(v.step == .legEnd)
        #expect(v.effects == [.openSettings, .navigate(.area(.bookcase))])
    }

    /// F-U2-W-3 (the fresh-store walk, round 2's fix): at step 10 in a book
    /// whose note box holds NO note — the walked state: the direct-road
    /// ascent's Index arrived unselected — the edit-here door does not
    /// exist, so the ring falls to the toured note's own Index row (her
    /// verified recovery: clicking it selects, drops into index-edit and
    /// advances), with the Index tab behind it for the other book modes,
    /// and the road-back line is earned. With the box holding a note, the
    /// step's own edit-here ring stands and nothing extra is said.
    @Test func stepElevensLastBeatInABookWithAnEmptyNoteBoxRingsTheNotesIndexRow() {
        var w = Self.walk(to: .downAndUp)
        w.report(.init(place: .book(Self.sherlock)))
        #expect(w.step == .downAndUp)
        #expect(w.rings == [[.indexNoteRow(Self.scandal), .bookModeTab(.index)]],
                "an empty box: the note's row is the way back (\(w.rings))")
        #expect(w.state.map(Tour.isRoadBack) == true)
        var v = Self.walk(to: .downAndUp)
        v.report(.init(place: .book(Self.sherlock), bookNoteSelected: true))
        #expect(v.step == .downAndUp)
        #expect(v.rings == [[.noteBoxEditHere]],
                "a holding box: the step's own door (\(v.rings))")
        #expect(v.state.map(Tour.isRoadBack) == false)
    }

    @Test func nextIsInertOnACardThatWaitsForHerAct() {
        for step in [Tour.Step.seededBook, .write, .makeTake, .lensesLive, .bookAndRead,
                     .downAndUp, .ownNote] {
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

    // MARK: - The tutorial wins by driving (VX-292 R-292-11)

    /// Every moded navigate a walk asked for (the drives), in order.
    static func drives(_ effects: [Tour.Effect]) -> [Tour.Effect] {
        effects.filter {
            if case .navigate(_, let mode) = $0 { return mode != nil }
            return false
        }
    }

    /// The table IS the rule's data: steps 4–6 teach in Write, step 7's two
    /// beats in Takes (VX-292 U3: the flip's choose bands are the board's),
    /// and no other step drives a mode (steps 8–9 ask HER to switch — a drive
    /// would do her act for her; step 10 only names two modes; step 11 and
    /// the leg work from any mode).
    @Test func theStepsThatTeachInAModeAreExactlyStepsFourToSeven() {
        var table: [Tour.Step: Tour.NoteMode] = [:]
        for step in Tour.Step.allCases {
            if let mode = Tour.expectedNoteMode(step) { table[step] = mode }
        }
        #expect(table == [.write: .write, .makeTake: .write, .takeIcon: .write,
                          .takesMode: .takes, .takesFlipBack: .takes])
    }

    /// Her words: *"if you were in takes on some chapter in the prince where
    /// the tutorial expects you to be in write, the tutorial wins."* The
    /// toured chapter ARRIVES in the mode its own memory remembers (a road
    /// that is not the card's door — the Open row, the Library, ⌘K): the
    /// tour drives it to Write, once, and the step still waits for her click.
    @Test func aChapterRememberedInAnotherModeIsDrivenToWriteWhenItArrives() {
        for remembered in Tour.NoteMode.allCases where remembered != .write {
            var w = Self.walk(to: .insideBook)
            w.effects = []
            w.report(.init(place: .note(Self.scandal), noteMode: remembered))
            #expect(w.step == .write, "\(remembered): any note serves step 3, as ever")
            #expect(w.effects == [.navigate(.note(Self.scandal), mode: .write)],
                    "\(remembered): ONE drive, to Write (\(w.effects))")
            // The same report again (the drive has not landed yet): never
            // asked twice.
            w.report(.init(place: .note(Self.scandal), noteMode: remembered))
            #expect(Self.drives(w.effects).count == 1, "\(remembered): no second ask")
            // It lands: Write, and step 4 waits for her click as designed.
            w.report(Self.write(Self.first, ordinal: 1))
            #expect(w.step == .write)
            #expect(Self.drives(w.effects).count == 1)
            w.report(Self.write(Self.middle, ordinal: 40))
            #expect(w.step == .makeTake)
        }
    }

    /// The window can report the note a beat before its detail registers
    /// (no mode yet): the arrival waits and is judged when its mode comes.
    @Test func anArrivalWhoseModeComesLaterIsJudgedWhenItComes() {
        var w = Self.walk(to: .insideBook)
        w.effects = []
        w.report(.init(place: .note(Self.scandal)))
        #expect(w.step == .write)
        #expect(w.effects == [], "nothing to judge until the note says its mode")
        w.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(w.effects == [.navigate(.note(Self.scandal), mode: .write)])
    }

    /// A mode she picks HERSELF on the note she is in is hers: no arrival,
    /// so nothing is judged — the rail's road back stays the answer (the
    /// off-target tolerance, unchanged). Only a LANDING is driven.
    @Test func aModeSheChoosesOnTheSameNoteIsNeverOverruled() {
        var w = Self.walk(to: .write)
        w.effects = []
        w.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(w.effects == [], "her own switch: no drive (\(w.effects))")
        #expect(w.rings == [[.sidebarMode(.write)]])
        #expect(w.state.map(Tour.isRoadBack) == true)
        w.report(.init(place: .note(Self.scandal), noteMode: .lenses))
        #expect(w.effects == [])

        var v = Self.walk(to: .takesMode)
        v.effects = []
        v.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(v.effects == [], "step 7's own note, switched by her: no drive")
        #expect(v.rings == [[.sidebarMode(.takes)]])
    }

    /// Wandering is never chased (the off-target tolerance must not die):
    /// a place that is not a note judges nothing and asks for nothing —
    /// including mid-correction, before the drive has landed. Coming back
    /// to the note IS an arrival, and is judged when it lands.
    @Test func wanderingIsNeverChasedAndComingBackIsJudged() {
        var w = Self.walk(to: .write)
        w.effects = []
        for place: Tour.Place in [.area(.library), .book(Self.sherlock), .area(.pool), .elsewhere] {
            w.report(.init(place: place))
            #expect(w.effects == [], "\(place): wandering asks for nothing")
            #expect(w.step == .write)
        }
        // Back through the Open row: the note remembers Read.
        w.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(w.effects == [.navigate(.note(Self.scandal), mode: .write)])

        // Mid-correction: the drive is asked, and before it lands she leaves.
        var v = Self.walk(to: .insideBook)
        v.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(Self.drives(v.effects).count == 1)
        v.report(.init(place: .area(.library)))
        v.report(.init(place: .book(Self.sherlock)))
        #expect(Self.drives(v.effects).count == 1, "her wandering is hers, mid-drive too")
        #expect(v.step == .write)
    }

    /// Step 7 teaches in TAKES: a return to the toured note that lands in
    /// Write is driven back to Takes. The steps that teach in no particular
    /// mode never drive, whatever the note arrives in.
    @Test func stepSevenDrivesToTakesAndTheOtherStepsLeaveTheModeAlone() {
        var w = Self.walk(to: .takesMode)
        w.effects = []
        w.report(.init(place: .area(.library)))
        w.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(w.effects == [.navigate(.note(Self.scandal), mode: .takes)])

        for step in [Tour.Step.readInNote, .lensesLive, .deeperModes, .upToBook, .bookAndRead] {
            var v = Self.walk(to: step)
            v.effects = []
            v.report(.init(place: .area(.library)))
            v.report(.init(place: .note(Self.scandal), noteMode: .compare))
            #expect(v.effects == [], "\(step) teaches in any mode (\(v.effects))")
        }
        // Step 6 reached by a landing ALREADY in Takes is the act itself
        // (the card asks for Takes mode): it advances, nothing is driven.
        var u = Self.walk(to: .takeIcon)
        u.effects = []
        u.report(.init(place: .area(.library)))
        u.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(u.step == .takesMode)
        #expect(u.effects == [])
        // …and in Read, it is driven to Write, where the ⑂ badge lives.
        var t = Self.walk(to: .takeIcon)
        t.effects = []
        t.report(.init(place: .area(.library)))
        t.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(t.step == .takeIcon)
        #expect(t.effects == [.navigate(.note(Self.scandal), mode: .write)])
    }

    /// A RE-RUN after a completed tour: the first run left the toured
    /// chapter in Takes (step 7), so the second meets the remembered mode —
    /// the hostile case her words name. It is driven; and a note she takes
    /// in place of the chapter is driven the same way (the tour follows the
    /// note she took).
    @Test func aReRunAfterCompletionIsDrivenAndSoIsAnyNoteSheTakes() {
        var first = Self.walk(to: .endCard)
        first.send(.choose(.done))
        #expect(first.state == nil)

        var again = Walker()
        again.send(.next)
        again.report(.init(place: .book(Self.sherlock)))
        again.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(Self.drives(again.effects) == [.navigate(.note(Self.scandal), mode: .write)])

        var other = Self.walk(to: .insideBook)
        other.effects = []
        other.report(.init(place: .note(Self.league), noteMode: .read))
        #expect(other.state?.tourNoteID == Self.league)
        #expect(other.effects == [.navigate(.note(Self.league), mode: .write)])
    }

    /// The designed road drives nothing: the card's own door lands in Write
    /// (VX-303), so a walk of the whole tour — main leg, end card, the leg —
    /// asks for no drive at all. A book never drives (it keeps no mode
    /// memory; Outline is its arrival).
    @Test func theDesignedRoadDrivesNothing() {
        var w = Self.walk(to: .endCard)
        w.send(.choose(.keepGoing))
        w.report(Self.ownNote(starred: true))
        w.report(Self.ownNote(starred: true, tags: 1))
        w.report(Self.ownNote(starred: true, tags: 1, books: 1, place: .area(.pool)))
        w.report(.init(place: .area(.snippets)))
        w.send(.next)
        #expect(w.step == .legSettings)
        w.send(.next)
        #expect(w.step == .legEnd)
        w.report(.init(place: .area(.bookcase)))
        w.report(.init(place: .book(Self.guide)))
        #expect(w.state == nil)
        #expect(Self.drives(w.effects) == [], "\(w.effects)")
    }

    // MARK: - The grown tour's new cards (VX-292 U3 — R-292-3/7/8/10/13)

    /// Step 7, the flip (R-292-3, VX-633's *"the dual language example is
    /// great"*): the first beat rings the choose band of the take the card
    /// NAMES; any change of the shown take is the act (she may choose her own
    /// take instead — the page still flips); the second beat rings the take
    /// the step first saw and waits for it to be shown again. Reports about
    /// another block or another note are not this flip's; next moves on from
    /// either beat (the flip is offered, never required — P-292-8).
    @Test func stepSevensFlipAsksForTheNamedTakeAndBringsTheOriginalBack() {
        // Her own take chosen instead of the Italian: still a flip.
        var own = Self.walk(to: .takesMode)
        own.report(Self.flip(Self.hers))
        #expect(own.step == .takesFlipBack)
        #expect(own.rings == [[.takeChoose(Self.english), .takesBlock(Self.middle)]])

        // Another block's or another note's report is not this flip's.
        var other = Self.walk(to: .takesMode)
        other.report(Self.flip(Self.italian, block: "block-9"))
        #expect(other.step == .takesMode, "another block flipping is not the toured one")
        var stale = Self.flip(Self.italian)
        stale.block?.noteID = Self.league
        other.report(stale)
        #expect(other.step == .takesMode, "a report about another note's block is not hers")

        // Next skips the flip from either beat.
        var skip = Self.walk(to: .takesMode)
        skip.send(.next)
        #expect(skip.step == .readInNote)
        var half = Self.walk(to: .takesFlipBack)
        half.send(.next)
        #expect(half.step == .readInNote, "the page may stay Italian: her choice")

        // A block with no take wearing the card's name (a note that is not
        // the Prince's): the first other take, in fan order.
        var plain = Self.walk(to: .takeIcon)
        plain.report(.init(place: .note(Self.scandal), noteMode: .takes))
        plain.report(Self.flip(Self.english, takes: [Self.english, Self.hers], named: nil))
        #expect(plain.rings == [[.takeChoose(Self.hers), .takesBlock(Self.middle)]])

        // The Italian already shown when the step arrives (an earlier run's
        // skipped flip): the flip goes the other way, and back.
        var flipped = Self.walk(to: .takeIcon)
        flipped.report(.init(place: .note(Self.scandal), noteMode: .takes))
        flipped.report(Self.flip(Self.italian))
        #expect(flipped.rings == [[.takeChoose(Self.english), .takesBlock(Self.middle)]])
        flipped.report(Self.flip(Self.english))
        #expect(flipped.step == .takesFlipBack)
        #expect(flipped.rings == [[.takeChoose(Self.italian), .takesBlock(Self.middle)]])
        flipped.report(Self.flip(Self.italian))
        #expect(flipped.step == .readInNote)

        // The second beat teaches in Takes too: a return in Write is driven.
        var back = Self.walk(to: .takesFlipBack)
        back.effects = []
        back.report(.init(place: .area(.library)))
        back.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(back.effects == [.navigate(.note(Self.scandal), mode: .takes)])
    }

    /// The app watches exactly the flip's block: the toured note, preferring
    /// the block she made a take of — once the step has seen its block, that
    /// block — and nothing outside step 7.
    @Test func theFlipWatchesTheToursNoteAndItsBlockOnlyAtStepSeven() {
        let before = Self.walk(to: .takeIcon)
        #expect(before.state.flatMap(Tour.flipInterest) == nil)
        var w = Self.walk(to: .takeIcon)
        w.report(.init(place: .note(Self.scandal), noteMode: .takes))
        #expect(w.step == .takesMode)
        #expect(w.state.flatMap(Tour.flipInterest).map { [$0.noteID, $0.blockID] }
                == [Self.scandal, Self.middle])
        // The store's answer named a fallback block (the toured one lost its
        // fan): the step follows that block from then on.
        w.report(Self.flip(Self.english, block: "block-3"))
        #expect(w.state.flatMap(Tour.flipInterest).map { [$0.noteID, $0.blockID] }
                == [Self.scandal, "block-3"])
        #expect(w.rings == [[.takeChoose(Self.italian), .takesBlock("block-3")]])
        let after = Self.walk(to: .readInNote)
        #expect(after.state.flatMap(Tour.flipInterest) == nil)
    }

    /// Step 8, Read in the note (R-292-7): a next card — the rail's Read,
    /// then the switch; it never drives (switching is her act) and it never
    /// advances by itself, so the card's words stay up while she reads.
    @Test func stepEightShowsReadAndItsSwitchAndWaitsForNext() {
        var w = Self.walk(to: .readInNote)
        w.effects = []
        w.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(w.rings == [[.sidebarMode(.read)]])
        w.report(.init(place: .note(Self.scandal), noteMode: .read))
        #expect(w.rings == [[.readFaceSwitch]])
        #expect(w.step == .readInNote)
        #expect(w.effects == [], "no drive: Read is hers to open")
        w.send(.next)
        #expect(w.step == .lensesLive)
    }

    /// Step 9, Lenses live: the act is a second column beside the note's own
    /// on the note's Lenses board; a board her memory left two columns wide
    /// (an earlier run) advances the moment she arrives in Lenses — a step
    /// she did ahead of the card.
    @Test func stepNineAdvancesOnASecondColumnOnTheLensesBoard() {
        var w = Self.walk(to: .lensesLive)
        w.report(.init(place: .note(Self.scandal), noteMode: .read, lensColumns: 2))
        #expect(w.step == .lensesLive, "only the Lenses board's columns count")
        w.report(Self.lenses(nil))
        #expect(w.step == .lensesLive, "a board that has not said its columns yet")
        #expect(w.rings == [[.lensAddColumn]])
        w.report(Self.lenses(3))
        #expect(w.step == .deeperModes)

        var again = Self.walk(to: .lensesLive)
        again.report(Self.lenses(2))
        #expect(again.step == .deeperModes, "an earlier run's column: done on arrival")
    }

    /// Step 11's second beat (R-292-10: "what book mode is" and Read in the
    /// book): the Book tab, then Read; Read reached directly is the act too.
    @Test func stepElevensSecondBeatRingsBookThenReadAndReadIsTheAct() {
        var w = Self.walk(to: .bookAndRead)
        w.report(Self.book(nil))
        #expect(w.rings == [[.bookModeTab(.book)]], "a book that has not said its mode")
        w.report(Self.book(.index))
        #expect(w.rings == [[.bookModeTab(.book)]])
        w.report(Self.book(.read))
        #expect(w.step == .downAndUp, "straight to Read is the beat's act")
        // The first beat's next before she climbed: the book icon, said as
        // the road back up.
        var early = Self.walk(to: .deeperModes)
        early.send(.next)
        #expect(early.step == .upToBook)
        early.send(.next)
        #expect(early.step == .bookAndRead)
        #expect(early.rings == [[.contextBarBook]])
        #expect(early.state.map(Tour.isRoadBack) == true)
    }

    // MARK: - Step 3 brings its ring on screen (VX-292 U2 — A-292-1/3)

    /// Every reveal a walk asked for, in order.
    static func reveals(_ effects: [Tour.Effect]) -> [Tour.Effect] {
        effects.filter {
            if case .reveal = $0 { return true }
            return false
        }
    }

    /// The architect's A-292-3: step 3's ARRIVAL in the seeded book lands
    /// the toured chapter's Outline card — ALWAYS, once per arrival (the far
    /// card is often not drawn at all until it is landed, so no visibility
    /// check could decide it). Her moves inside the book are never chased;
    /// leaving and coming back is a new arrival.
    @Test func stepThreesArrivalInTheSeededBookLandsTheChapterOncePerArrival() {
        var w = Self.walk(to: .seededBook)
        w.effects = []
        w.report(.init(place: .book(Self.sherlock)))
        #expect(w.step == .insideBook)
        #expect(w.effects == [.reveal(.outlineCard(Self.scandal), in: .book(Self.sherlock))],
                "ONE reveal of the ringed chapter, in the book she is in (\(w.effects))")
        #expect(w.rings == [[.outlineCard(Self.scandal)]], "the ring is the card it lands")
        // Inside the book (the box, the page): no new arrival, nothing more.
        w.report(.init(place: .book(Self.sherlock), bookNoteSelected: true))
        w.report(.init(place: .book(Self.sherlock), bookNoteLive: true))
        #expect(Self.reveals(w.effects).count == 1, "her moves in the book are hers")
        // Home and back: a new arrival, a new landing.
        w.report(.init(place: .area(.bookcase)))
        #expect(Self.reveals(w.effects).count == 1, "the Bookcase lands nothing")
        w.report(.init(place: .book(Self.sherlock)))
        #expect(Self.reveals(w.effects).count == 2, "leaving and returning is a new arrival")
        // Into the chapter: step 4, and the note's own judgment as ever.
        w.report(.init(place: .note(Self.scandal), noteMode: .write))
        #expect(w.step == .write)
        #expect(Self.reveals(w.effects).count == 2)
        #expect(Self.drives(w.effects) == [])
    }

    /// Only the SEEDED book at STEP 3, with its chapter known: another book
    /// (the guide) lands nothing; a missing landmark has nothing to land; the
    /// later steps' book visits keep their own roads (step 9's Index carries
    /// the toured note itself).
    @Test func onlyTheSeededBookAtStepThreeLandsAnything() {
        var other = Self.walk(to: .insideBook)
        other.effects = []
        other.report(.init(place: .area(.bookcase)))
        other.report(.init(place: .book(Self.guide)))
        #expect(other.step == .insideBook)
        #expect(other.effects == [], "another book is not the toured chapter's (\(other.effects))")

        var missing = Walker(seededBookID: nil, firstStoryID: nil)
        missing.send(.next)
        missing.report(.init(place: .book("any-book")))
        #expect(missing.step == .insideBook)
        #expect(Self.reveals(missing.effects) == [], "no landmark, nothing to land")

        var noChapter = Walker(firstStoryID: nil)
        noChapter.send(.next)
        noChapter.report(.init(place: .book(Self.sherlock)))
        #expect(noChapter.step == .insideBook)
        #expect(Self.reveals(noChapter.effects) == [], "a chapter she deleted is hers")

        for step in [Tour.Step.upToBook, .bookAndRead, .downAndUp] {
            var later = Self.walk(to: step)
            later.effects = []
            later.report(.init(place: .area(.library)))
            later.report(.init(place: .book(Self.sherlock), bookNoteSelected: true))
            #expect(Self.reveals(later.effects) == [], "\(step): the book's own carry serves it")
        }
        // The whole designed road lands exactly once: step 3's arrival.
        var whole = Self.walk(to: .endCard)
        whole.send(.choose(.done))
        #expect(Self.reveals(whole.effects)
                == [.reveal(.outlineCard(Self.scandal), in: .book(Self.sherlock))])
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
            .takeChoose("t"), .readFaceSwitch, .lensAddColumn,
        ]
        #expect(all.filter(\.isInPanel) == [.panelNewTake, .panelOpenTakesMode])
        #expect(all.filter(\.isAppKit) == [.takeBadge("k")])
        #expect(Tour.fallbackCorner(.makeTake) == .bottomLeading,
                "the mockup's step 5 card sits clear of the panel, bottom left")
    }
}
