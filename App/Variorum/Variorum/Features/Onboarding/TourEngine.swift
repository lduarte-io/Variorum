//
//  TourEngine.swift
//  Variorum
//
//  13s-b U2 — **THE TOUR, RUNNING** (mockup v5; the rule is
//  `VariorumCore/Domain/Tour`, the words `TourScript`, the faces
//  `TourOverlay`, the ring `Core/Views/TourSpotlight`).
//
//  One per WINDOW: `RootView` holds it in `@State` while a tour runs and nils
//  it at the end, and it is born at the one entry U1a left
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
    }

    @ObservationIgnored private let doors: Doors
    @ObservationIgnored private let session: AppSession
    /// Whether the tour has ended (a second end is a no-op).
    @ObservationIgnored private var over = false

    init(
        session: AppSession, landmarks: Queries.TourLandmarks, facts: Tour.Facts, doors: Doors
    ) {
        self.session = session
        self.doors = doors
        let begun = Tour.start(
            seededBookID: landmarks.seededBookID, firstStoryID: landmarks.firstStoryID,
            fieldGuideID: landmarks.fieldGuideID, facts: facts)
        self.state = begun.state
        spotlight.setGroups(Tour.ringGroups(begun.state))
        perform(begun.effects)
    }

    /// The tour's landmarks in the wing she is in (the seeded book, its
    /// first story, the field guide) — read once, at the start.
    static func landmarks(session: AppSession) async -> Queries.TourLandmarks {
        let wing = session.wing.currentID
        let seeded = SampleLibrarySeeder.bookName
        let story = TourScript.firstStoryTitle
        let guide = TutorialSeeder.bookName
        let found = try? await session.database.read { db in
            try Queries.tourLandmarks(
                db, seededBookName: seeded, firstStoryTitle: story,
                fieldGuideName: guide, wingID: wing)
        }
        return found ?? .init(seededBookID: nil, firstStoryID: nil, fieldGuideID: nil)
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
            case .navigate(let place): doors.navigate(place)
            case .openFieldGuide: doors.openFieldGuide()
            case .recordCompleted: doors.recordCompleted()
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
        case .tag, .recovery: .elsewhere
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

    /// The window's facts, assembled (pure over what the sources read).
    static func facts(
        selection: SidebarSelection?, detail: (postID: String?, mode: PostMode?),
        caret: TourCaretReading?, bookNoteLive: Bool,
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
        if case .book = place { bookLive = bookNoteLive }
        let noteFacts = note.map {
            Tour.NoteFacts(
                noteID: $0.id, starred: isStarred($0.id),
                tagCount: $0.facts.tagCount, bookCount: $0.facts.bookCount)
        }
        return Tour.Facts(
            place: place, noteMode: noteMode, caret: tourCaret,
            bookNoteLive: bookLive, note: noteFacts)
    }
}
