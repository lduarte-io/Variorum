//
//  TourScript.swift
//  Variorum
//
//  13s-b U2 — **THE TOUR'S WORDS**, VERBATIM from mockup v5 (the approved
//  fifth draft — her R-13s-27: *"tour looks great!"*;
//  `notes/plans/13s-mockups/onboarding-tour.html`), in her register (R-13s-7,
//  R-13s-22: plain, calm, no emoji, no em dashes). Every departure from the
//  frozen copy is one of the brief's BUILD-VERIFY resolutions or a fact the
//  real app forced, each recorded in the plan file's U2 RECORD with its
//  alternative:
//
//  · step 6 — the margin glyph is the badge's own (⑂, with the block's real
//    count), not the mockup's drawn ψ (P-U2-1);
//  · step 7 — Takes mode chooses with the card's "choose" header, not a ✓
//    door (BUILD-VERIFY 1, P-U2-2);
//  · step 9 — the book's Index arrives with the NOTE selected; the paragraph
//    comes back one door later, at step 10's "edit here" (BUILD-VERIFY 3,
//    P-U2-3);
//  · leg 1 — a note has no masthead star; the star lives on the note's
//    rows (P-U2-5);
//  · leg 4 — the note-side panel's name is its door's, "Scraps"
//    (BUILD-VERIFY 2, P-U2-2's sibling).
//
//  The words that NAME a door quote the door's own constant, so a rename can
//  never leave the tour describing a door that is gone (13u4 UNIT S3's rule).
//  Rendering: the step label, the title and the buttons are CHROME
//  (`chromeLabel` — Terminal lowercases them, the voice's own law); the body
//  is prose and keeps its case.
//

import Foundation
import VariorumCore

/// Main-actor (the target's default): it quotes `PostDetailView`'s door name.
enum TourScript {
    /// One coach card's words.
    nonisolated struct Card: Equatable, Sendable {
        let title: String
        let body: String
    }

    // MARK: - Chrome

    static let next = "next \u{27F6}"
    static let endTour = "End tour"
    /// **A7 — PROVISIONAL P-U2-15, NEW WORDS (not in the approved mockup;
    /// hers to strike).** Said under a card whose ring is the road BACK to
    /// its step's place rather than the step's own target (she wandered), so
    /// the ring and the sentence above it never contradict each other.
    static let roadBack = "Follow the ring back."

    /// The small count line (the mockup's "STEP 1 OF 11", in sentence case —
    /// her caps ban, R-13s-30, and rendered text is sentence case).
    static func label(_ position: Tour.Position) -> String? {
        switch position {
        case .main(let number, let secondBeat):
            let count = "Step \(number) of \(Tour.mainStepCount)"
            return secondBeat ? "\(count) \u{00B7} and home" : count
        case .endCard:
            return nil
        case .leg(let number):
            return "Keep going \u{00B7} \(number) of \(Tour.legStopCount)"
        case .legEnd:
            return "The end"
        }
    }

    // MARK: - Facts the words depend on

    /// Step 3's story — also how the tour finds it (`Queries.tourLandmarks`).
    static let firstStoryTitle = "A Scandal in Bohemia"

    /// **The take badge's glyph** — Write's margin badge reads `⑂N`
    /// (`BadgeOverlayController`, pinned by `TourScriptTests`); the tour's
    /// badge locator and step 6's sentence both read this one constant.
    static let takeBadgeGlyph = "\u{2442}"

    // MARK: - The cards

    // swiftlint:disable line_length
    static func card(_ step: Tour.Step, takeCount: Int = 2) -> Card? {
        switch step {
        case .navigation:
            return Card(
                title: "Navigation",
                body: "Everything lives in one of the places on the left. Bookcase holds your books. Library is everything, searchable. Pool holds notes that aren't in a book, and Snippets keeps pieces of text you reuse between notes.")
        case .seededBook:
            return Card(
                title: "Sherlock Holmes, in Variorum",
                body: "The adventures of sherlock holmes comes with the app, so you can try everything on real writing. Click into it.")
        case .insideBook:
            return Card(
                title: "Inside a book",
                body: "A book opens on its Outline: every chapter, and the beginning of every note. A book works like a scrapbook. Put a note in and it stays there. Click into \(firstStoryTitle).")
        case .write:
            // R-13s-32: "savepoint" stays here, the explanation of the word
            // commit (her word: "keep it").
            return Card(
                title: "Write",
                body: "Notes open in Write. Everything autosaves as you type; commit \u{2318}S in the bottom bar keeps a savepoint of a moment worth keeping. Scroll to the middle of the note and click into a paragraph there.")
        case .makeTake:
            return Card(
                title: "Make a take",
                body: "A block can keep more than one version of itself. These are takes, like takes in film, and they are the heart of Variorum. Click Takes in the bottom bar, then \u{FF0B} new take (branch), and change a few words.")
        case .takeIcon:
            // P-U2-1: the badge's own glyph and count (the mockup drew ψ2).
            return Card(
                title: "The take icon",
                body: "The \(takeBadgeGlyph)\(max(2, takeCount)) in the margin marks any block that keeps more than one version. Click into it any time to see them. Click into it now, then Open Takes mode.")
        case .takesMode:
            // BUILD-VERIFY 1 (P-U2-2): the board's card chooses with its
            // header band ("choose" / "✓ chosen" — `TakeChooseHeader`), not a ✓.
            return Card(
                title: "Both takes, side by side",
                body: "This is Takes mode: the whole note, with every version of every block. The \u{2713} take is what the note says. Click into a take to work in it; choose, at the top of its card, makes it the one the page shows. The original keeps its own card.")
        case .deeperModes:
            return Card(
                title: "Three more, for later",
                body: "Lenses shows different takes of this note side by side. Compare sets other notes beside this one. Blocks is a workbench for many blocks at once. The field guide teaches each of them.")
        case .placeFollows:
            // BUILD-VERIFY 3 (P-U2-3): the Index arrives with the NOTE
            // selected (the mode switch carries the note, not the block); the
            // paragraph comes back at step 10's "edit here".
            return Card(
                title: "Your place follows you",
                body: "Bounce between Write (\u{2318}1) and Takes (\u{2318}2) as you like. Then click the book icon and pick Index, the book's own view of its notes. Your note is still selected there, one level up. Your place follows you everywhere.")
        case .downAndUp:
            return Card(
                title: "Down and up",
                body: "In a book, the selected note's \(NoteBoxCopy.editDoor) door drops you back into it, and the book icon brings you up again. The ladder runs both directions. Click into it.")
        case .home:
            return Card(
                title: "Head home",
                body: "When you're done exploring, Bookcase in the sidebar heads home. Click into it.")
        case .ownNote:
            return Card(
                title: "One of your own",
                body: "The dashed line at the bottom reads new note, just start typing. Type a first line and press \u{23CE} to open your first note. No book needed; it waits in the Pool until you give it one.")
        case .endCard:
            return nil
        case .legStar:
            // P-U2-5: there is no star on a note's masthead — the star is a
            // row's (right-click ▸ Star), and the note sits in the sidebar's
            // Open list the moment it opens.
            return Card(
                title: "Star a note",
                body: "Right-click your note under \(WorkspaceNaming.openSectionHeader) in the sidebar and choose \(StarCopy.starRow). Starred notes rise to the top of the sidebar, and the starred notes gathering on your Bookcase collects them automatically.")
        case .legTags:
            return Card(
                title: "Organize with tags",
                body: "The \u{FF03} on the masthead adds a tag. Tag a note ideas, and a gathering made from ideas shows it on its own. Make the tag.")
        case .legBook:
            return Card(
                title: "Put it in a book",
                body: "Your note has been waiting here in the Pool. Click into add to book, or make a new book around it. A note can sit in more than one book.")
        case .legSnippets:
            // BUILD-VERIFY 2: the note-side panel is the masthead's
            // "\(PostDetailView.scrapsDoorTitle)" door.
            return Card(
                title: "Snippets",
                body: "Pieces of text you reuse between notes live here: a phrase, a quote, a line you cut. From inside any note, the \(PostDetailView.scrapsDoorTitle) panel brings them alongside so you can pull one in. The snippet stays for next time.")
        case .legEnd:
            return Card(
                title: "The field guide",
                body: "Everything deeper lives in the field guide: takes in depth, divide and merge, books that collect, privacy. Interactive lessons, in order or as needed. That's the tour. Go write.")
        }
    }

    // MARK: - The end card (the fork, restaged over her own note — A3)

    static let endTitle = "That's the tour."
    static let endBody = "Navigation on the left. Books on the Bookcase. Takes on any block. Your place follows you."
    /// R-13s-28/39: the readme sentence stands although readme seeds later.
    /// A5: no time promise on the main leg — "two more minutes" lives on the
    /// fork's first door only.
    static let endAside = "readme, a short welcome note, is waiting in your Library. And \u{2318}J opens today's journal entry, whenever you want one."
    static let keepGoing = "Keep going: two more minutes on stars, tags, books and snippets"
    static let openFieldGuide = "Open the field guide, every feature as a lesson"
    static let done = "Done, go write"
    // swiftlint:enable line_length
}
