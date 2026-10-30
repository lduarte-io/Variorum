//
//  TourEngine.swift
//  Variorum
//
//  13s-b U2 — **THE TOUR, RUNNING** (mockup v5; the rule is
//  `VariorumCore/Domain/Tour`, the words `TourScript`, the faces
//  `TourOverlay`, the ring `Core/Views/TourSpotlight`).
//
//  One per WINDOW: `RootView` keeps it in its `TourSlot` (`@State`) while a
//  tour runs and drops it at the end, and it is born at the one entry U1a left
//  (`RootView.startTour()` — the offer's "yes" and Help ▸ Take the Tour). It
//  holds no decision of its own: it feeds the window's facts to the pure
//  rule, hands the rule's rings to the spotlight, and performs the rule's
//  effects through the doors the composition root gives it (P-4: the shell
//  decides what a destination means; this only names it).
//

import Foundation
import GRDB
import Observation
import VariorumCore

@MainActor
@Observable
final class TourEngine {
    /// The rule's state. nil never happens while the engine lives: the end
    /// of a tour is the composition root dropping the engine.
    private(set) var state: Tour.State
    /// The window's ring (the anchors read it through the environment).
    let spotlight = TourSpotlight()
    /// The store's answer about `Tour.noteOfInterest` (its id rides beside
    /// it, so an answer about another note is never mistaken for this one).
    private(set) var noteFacts: (id: String, facts: Queries.TourNoteFacts)?

    /// What the rule's effects DO — the composition root's doors.
    struct Doors {
        /// Take the window's focused pane to a place.
        var navigate: (Tour.Place) -> Void
        /// Open the field guide (Help's own door).
        var openFieldGuide: () -> Void
        /// The end card arrived: retire the offer as completed.
        var recordCompleted: () -> Void
        /// The tour is over (`completed`: how it ended).
        var finished: (_ completed: Bool) -> Void
        /// Open the Pool's "in gatherings" run (F-U2-W-2, option A — leg 3).
        var showPoolTucked: () -> Void = {}
        /// **VX-292 R-292-11 — the tutorial wins by driving**: take the
        /// focused pane to this NOTE in this mode (a note arrived in a mode
        /// its step does not teach in — `Tour.drive`). The composition root
        /// performs it through the existing landing roads: the rail's own
        /// mode switch on the mounted note, else the book open door's mode
        /// landing. Defaulted so a fixture that never drives needs nothing.
        var drive: (Tour.Place, Tour.NoteMode) -> Void = { _, _ in }
        /// **VX-292 U2 (A-292-1/3) — bring this ring on screen in this
        /// place** (`Tour.arrivalReveal`: step 3's arrival in the seeded book
        /// lands the toured chapter's Outline card). The composition root
        /// performs it through the book's ascent road; an anchor with no
        /// road does nothing (its card keeps its corner). Defaulted.
        var reveal: (Tour.Anchor, Tour.Place) -> Void = { _, _ in }
    }

    @ObservationIgnored private let doors: Doors
    @ObservationIgnored private let session: AppSession
    /// The readme honesty gate (extra-pass MINOR-1), read once with the
    /// landmarks: the end card's readme sentence renders only when true.
    @ObservationIgnored let readmeNoteExists: Bool
    /// Whether the tour has ended (a second end is a no-op).
    @ObservationIgnored private var over = false

    init(
        session: AppSession, landmarks: Queries.TourLandmarks, facts: Tour.Facts, doors: Doors
    ) {
        self.session = session
        self.doors = doors
        self.readmeNoteExists = landmarks.readmeNoteExists
        let begun = Tour.start(
            seededBookID: landmarks.seededBookID, firstStoryID: landmarks.firstStoryID,
            fieldGuideID: landmarks.fieldGuideID, facts: facts)
        self.state = begun.state
        spotlight.setGroups(Tour.ringGroups(begun.state))
        perform(begun.effects)
    }

    /// The tour's landmarks in the wing she is in (the seeded book, the
    /// chapter step 3 rings, the field guide) — read once, at the start.
    /// VX-292 U1 (R-292-1): the seeded book is the launch's, *The Prince*
    /// (`TourScript.seededBookName`, pinned to `Book.launchBook`); it read
    /// Sherlock's name, which a fresh store no longer holds, so steps 2–3
    /// rang nothing there.
    static func landmarks(session: AppSession) async -> Queries.TourLandmarks {
        let wing = session.wing.currentID
        let seeded = TourScript.seededBookName
        let story = TourScript.firstStoryTitle
        let guide = TutorialSeeder.bookName
        let found = try? await session.database.read { db in
            try Queries.tourLandmarks(
                db, seededBookName: seeded, firstStoryTitle: story,
                fieldGuideName: guide, wingID: wing,
                readmeTitle: ReadmeSeeder.title)
        }
        return found ?? .init(seededBookID: nil, firstStoryID: nil, fieldGuideID: nil)
    }

    // MARK: - VX-292 U2 (R-292-11, R-292-17) — the start ensures its PROPS

    /// **What the store says about the launch's book**, read with the restore
    /// road's own discovery (`SampleLibrarySeeder.discover` — wing-agnostic)
    /// so the start and the road can never disagree about "missing".
    struct LaunchBookFacts: Equatable, Sendable {
        /// The live launch book the restore would act on, in ANY wing.
        var liveBookID: String?
        /// Every shipped chapter is a live member (`Existing.isComplete` —
        /// the door's own "already whole"). Read only when it decides
        /// anything (the props are broken); true otherwise.
        var isComplete: Bool
    }

    /// **Whether a tour's start runs the launch book's own restore road
    /// first** (the "yes" / Help press is the consent). Pure, so the pins
    /// read exactly what the start decides. Never outside HOME (the launch's
    /// book is Home's: a restore from another wing would mint where this
    /// tour cannot see it, and a Prince she MOVED to another wing is her
    /// deliberate act — respected); never on an unreadable store. Two cases:
    ///
    /// 1. **No book** (R-292-11, PROVISIONAL P-292-7): the landmarks found no
    ///    seeded book and the store holds no live copy in any wing (a moved
    ///    one would only answer the door's "already whole" refusal, or have
    ///    chapters she deleted there minted back).
    /// 2. **Broken props** (R-292-17, her words: *"what if they've deleted all
    ///    the takes in the prince? wouldn't that ruin the tutorial?… maybe it
    ///    should still be restored"*): the book stands here but its props
    ///    are broken (`TourLandmarks.seededBookPropsBroken` — the named
    ///    chapter gone, or no live chapter carrying a fan) AND the door can
    ///    REACH a mend: the book is the one the road acts on and it is
    ///    INCOMPLETE (a shipped chapter is not a live member). The road mints
    ///    exactly the missing chapters, each fresh with its takes and lenses
    ///    (the seeder's own bilingual pass, in the chapter's own turn), and
    ///    never touches a chapter that stands. What it cannot reach — every
    ///    chapter standing with its fans emptied inside — it is NOT asked
    ///    (it would only refuse "already whole"): the tour walks on the
    ///    landmarks' fallback, its floor (the U2 RECORD). An intact or merely
    ///    edited book is never touched.
    nonisolated static func restoresLaunchBook(
        landmarks: Queries.TourLandmarks, wingID: String, store: LaunchBookFacts?
    ) -> Bool {
        guard wingID.isEmpty, let store else { return false }
        guard let seeded = landmarks.seededBookID else { return store.liveBookID == nil }
        return landmarks.seededBookPropsBroken && store.liveBookID == seeded && !store.isComplete
    }

    /// The store's facts for `restoresLaunchBook` (nil: unreadable — no
    /// restore is attempted). Completeness is read only when it could decide
    /// anything (broken props in Home): it needs the shipped chapter list,
    /// parsed from the bundled text off the main actor.
    static func launchBookFacts(
        session: AppSession, landmarks: Queries.TourLandmarks
    ) async -> LaunchBookFacts? {
        guard let found = try? await session.database.read({ db in
            try SampleLibrarySeeder.discover(db, book: .launchBook)
        }) else { return nil }
        var complete = true
        if landmarks.seededBookPropsBroken, found.bookID != nil,
           let stories = try? await Task.detached(priority: .utility, operation: {
               try SampleLibrarySeeder.loadStories(for: .launchBook)
           }).value {
            complete = found.isComplete(
                for: SampleLibrarySeeder.expectedTitles(for: .launchBook, stories: stories))
        }
        return LaunchBookFacts(liveBookID: found.bookID, isComplete: complete)
    }

    // MARK: - Events

    func observe(_ facts: Tour.Facts) {
        guard facts != state.facts else { return }
        apply(Tour.reduce(state, .facts(facts)))
    }

    func next() { apply(Tour.reduce(state, .next)) }

    func endTour() { apply(Tour.reduce(state, .endTour)) }

    func choose(_ choice: Tour.EndChoice) { apply(Tour.reduce(state, .choose(choice))) }

    private func apply(_ outcome: Tour.Outcome) {
        guard !over else { return }
        if let next = outcome.state {
            state = next
            spotlight.setGroups(Tour.ringGroups(next))
        }
        perform(outcome.effects)
    }

    private func perform(_ effects: [Tour.Effect]) {
        for effect in effects {
            switch effect {
            case .navigate(let place, let mode):
                // R-292-11: a moded navigate is the tour DRIVING a note to the
                // mode its step teaches in; every other one is a plain place.
                if let mode { doors.drive(place, mode) } else { doors.navigate(place) }
            case .openFieldGuide: doors.openFieldGuide()
            case .recordCompleted: doors.recordCompleted()
            case .showPoolTucked: doors.showPoolTucked()
            case .reveal(let anchor, let place): doors.reveal(anchor, place)
            case .finish(let completed):
                guard !over else { continue }
                over = true
                spotlight.setGroups([])
                doors.finished(completed)
            }
        }
    }

    // MARK: - The note the step waits on

    /// The note whose store facts the current step needs (nil: none).
    var noteOfInterest: String? { Tour.noteOfInterest(state) }

    /// Watch `noteOfInterest`'s tags and books for as long as the step asks
    /// (the overlay's `.task(id:)` restarts this when the note changes). A
    /// held observation on two small indexed counts — never the corpus (P1).
    func watchNoteFacts() async {
        guard let noteID = noteOfInterest else {
            noteFacts = nil
            return
        }
        do {
            for try await value in session.database.observe({ db in
                try Queries.tourNoteFacts(db, postID: noteID)
            }) {
                noteFacts = (noteID, value)
            }
        } catch {
            // A failed observation leaves the step waiting; End tour is
            // always on the card.
        }
    }
}

// MARK: - The composition root's slot

/// **Where a window keeps its running tour** (`RootView`'s `@State`). A class
/// so the engine's doors can reach it weakly: the engine holds the doors, the
/// doors must not hold the engine back.
@MainActor
@Observable
final class TourSlot {
    var engine: TourEngine?
    /// VX-292 U2 (R-292-11): a start is on its way — reading the landmarks
    /// and, when the launch's book is missing, restoring it. Set at the PRESS
    /// (synchronously), cleared when the engine is made: a second press
    /// meanwhile is that same start (never a second restore racing the first
    /// through the seeder's latch into an "already whole" refusal). A press
    /// once the tour runs is Q12's restart, as ever.
    @ObservationIgnored var starting = false
}

// MARK: - The facts, read from the window

/// **Where the window stands, in the rule's words** — the composition root
/// hands these readers to the overlay, whose body evaluates them, so the
/// observation they register lands on the smallest view in the tree (the
/// note box's lesson — never the shell's body).
struct TourFactSources {
    /// What the focused pane shows.
    var selection: () -> SidebarSelection?
    /// The mounted note detail's note and mode.
    var noteDetail: () -> (postID: String?, mode: PostMode?)
    /// Write's editor under the caret (`EditorRouter.editing`).
    var caret: () -> TourCaretReading?
    /// A book's sidebar note box is live (the composition root derives it
    /// from the box the focused book published).
    var bookNoteLive: () -> Bool
    /// The box HOLDS a note — selected or live (F-U2-W-3: step 10's
    /// edit-here ring exists only then; an empty box re-anchors on the
    /// toured note's Index row). Defaulted so a fixture without a box
    /// reads "empty", the honest unknown.
    var bookNoteSelected: () -> Bool = { false }
    /// The star (the window's stars model — store state).
    var isStarred: (String) -> Bool
}

/// What Write's editor says about its caret.
struct TourCaretReading: Equatable {
    var postID: String
    var blockID: String?
    var ordinal: Int?
    /// The on-screen fanned blocks' take counts (the badges).
    var takeCounts: [String: Int]
    var panelBlockID: String?
}

enum TourPlaces {
    static func place(_ selection: SidebarSelection?) -> Tour.Place {
        switch selection {
        case .shelf, nil: .area(.bookcase)
        case .library: .area(.library)
        case .poolPosts: .area(.pool)
        case .blocks: .area(.snippets)
        case .archived: .area(.archived)
        case .post(let id): .note(id)
        case .reading(let id): .book(id)
        case .pool(let id): .snippetGroup(id)
        case .tag, .recovery, .noteVersion: .elsewhere
        }
    }

    static func selection(_ place: Tour.Place) -> SidebarSelection? {
        switch place {
        case .area(.bookcase): .shelf
        case .area(.library): .library
        case .area(.pool): .poolPosts
        case .area(.snippets): .blocks
        case .area(.archived): .archived
        case .note(let id): .post(id)
        case .book(let id): .reading(id)
        case .snippetGroup(let id): .pool(id)
        case .elsewhere: nil
        }
    }

    static func mode(_ mode: PostMode) -> Tour.NoteMode {
        switch mode {
        case .write: .write
        case .takes: .takes
        case .read: .read
        case .lenses: .lenses
        case .compare: .compare
        case .blocks: .blocks
        case .canvas: .canvas
        }
    }

    /// The rule's mode, in the app's words — `mode(_:)`'s inverse (VX-292
    /// R-292-11: the drive door names the mode the step teaches in).
    static func postMode(_ mode: Tour.NoteMode) -> PostMode {
        switch mode {
        case .write: .write
        case .takes: .takes
        case .read: .read
        case .lenses: .lenses
        case .compare: .compare
        case .blocks: .blocks
        case .canvas: .canvas
        }
    }

    /// The window's facts, assembled (pure over what the sources read).
    static func facts(
        selection: SidebarSelection?, detail: (postID: String?, mode: PostMode?),
        caret: TourCaretReading?, bookNoteLive: Bool, bookNoteSelected: Bool = false,
        note: (id: String, facts: Queries.TourNoteFacts)?, isStarred: (String) -> Bool
    ) -> Tour.Facts {
        let place = place(selection)
        var noteMode: Tour.NoteMode?
        var tourCaret: Tour.Caret?
        if case .note(let noteID) = place {
            if detail.postID == noteID, let mode = detail.mode { noteMode = self.mode(mode) }
            if noteMode == .write, let caret, caret.postID == noteID,
               let blockID = caret.blockID, let ordinal = caret.ordinal {
                tourCaret = Tour.Caret(
                    noteID: noteID, blockID: blockID, ordinal: ordinal,
                    takeCount: caret.takeCounts[blockID] ?? 1,
                    panelOpen: caret.panelBlockID != nil)
            }
        }
        var bookLive = false
        var bookSelected = false
        if case .book = place {
            bookLive = bookNoteLive
            // F-U2-W-3: live is holding too (the one box state order).
            bookSelected = bookNoteSelected || bookNoteLive
        }
        let noteFacts = note.map {
            Tour.NoteFacts(
                noteID: $0.id, starred: isStarred($0.id),
                tagCount: $0.facts.tagCount, bookCount: $0.facts.bookCount)
        }
        return Tour.Facts(
            place: place, noteMode: noteMode, caret: tourCaret,
            bookNoteLive: bookLive, bookNoteSelected: bookSelected, note: noteFacts)
    }
}
