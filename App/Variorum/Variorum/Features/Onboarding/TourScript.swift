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
//    (BUILD-VERIFY 2, P-U2-2's sibling);
//  · steps 2–3 — VX-292 U1 (R-292-1): the launch seeds *The Prince* since
//    VX-633, so the two Sherlock cards carry the architect's U1 COPY DRAFTS
//    (`notes/plans/vx-292-onboarding.md`), the book and its toured chapter
//    read from the Prince's own constants (chapter XVII, PROVISIONAL
//    P-292-1);
//  · steps 7–11 and leg 5 — VX-292 U3 (R-292-3/7/8/10/13): the grown tour's
//    cards carry the architect's U3 COPY DRAFTS, each departure a real-app
//    fact recorded in the plan's U3 RECORD with its alternative (the mode
//    list's home is the sidebar's "this note" section, not a "rail"; choosing
//    a take flips ONE paragraph, not the page).
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
    /// her caps ban, R-13s-30, and rendered text is sentence case). VX-292
    /// U3: a step's beats share its number (step 7's flip and its way back,
    /// step 11's book arc); the mockup's "· and home" beat retired when home
    /// became step 12 of its own (R-292-13's flow).
    static func label(_ position: Tour.Position) -> String? {
        switch position {
        case .main(let number, _):
            return "Step \(number) of \(Tour.mainStepCount)"
        case .closing, .endCard:
            return nil
        case .leg(let number):
            return "Keep going \u{00B7} \(number) of \(Tour.legStopCount)"
        case .legEnd:
            return "The end"
        }
    }

    // MARK: - Facts the words depend on

    /// **Step 2's book** — the book the launch seeds (VX-292 R-292-1: *The
    /// Prince* since VX-633), by its reserved name from the book's own
    /// constants; step 2's card says it, and the tour finds the book by it
    /// (`Queries.tourLandmarks`, an exact match). `TourScriptTests` pins it to
    /// `Book.launchBook`, so a future launch swap turns the tour red rather
    /// than leaving it naming a book a fresh store does not hold.
    static let seededBookName = SampleLibraryPrinceBook.name

    /// **Step 3's chapter** — XVII, whether it is better to be loved or
    /// feared (PROVISIONAL P-292-1: famous, eight paragraphs so the note has
    /// a real middle for step 4, and it carries a Ricci third take; the
    /// alternative is chapter III). The note's exact seeded title, read from
    /// the book's constants; also how the tour finds it
    /// (`Queries.tourLandmarks`). The card names it by its question, not its
    /// title (a roman numeral would read as shouted caps on a card).
    static let firstStoryTitle = SampleLibraryPrinceBook.lovedOrFearedChapterTitle

    /// **The take badge's glyph** — Write's margin badge reads `⑂N`
    /// (`BadgeOverlayController`, pinned by `TourScriptTests`); the tour's
    /// badge locator and step 6's sentence both read this one constant.
    static let takeBadgeGlyph = "\u{2442}"

    /// **Step 7's take and step 9's column** (VX-292 U3) — the Prince's
    /// Italian: every paragraph's second take wears this label, and every
    /// chapter's saved lens of the whole Italian is named by it (R-633-15).
    /// Read from the book's constants; the tour's flip query looks the take
    /// up by it (`Queries.tourFlipFacts`).
    static let italianName = SampleLibraryPrinceBook.italianTakeLabel

    /// **The palettes Settings offers, spelled** (VX-292 U3, the Settings
    /// stop): every palette but Custom (your own hex), counted from the enum
    /// the strip renders — the search blurb's own count
    /// (`PaletteDerivationTests.theSearchBlurbCountsThePalettesTheStripShows`),
    /// so a new preset can never leave the card a number behind.
    static var paletteCountWord: String {
        let count = ThemePalette.allCases.filter { $0 != .custom }.count
        let speller = NumberFormatter()
        speller.locale = Locale(identifier: "en_US")
        speller.numberStyle = .spellOut
        return speller.string(from: NSNumber(value: count)) ?? "\(count)"
    }

    /// **Step 3's last sentence when the ring is NOT on the chapter the
    /// approved sentence names** (VX-292 U3 — the U2 RECORD's copy note:
    /// R-292-17's fallback can ring another fanned chapter when XVII stands
    /// without its fan). NEW WORDS, PROVISIONAL P-292-11 — hers to strike;
    /// the alternative is the approved sentence always (a ring and a sentence
    /// that disagree in that one case).
    static let insideBookRingedChapter = "Click into the chapter the ring marks."

    // MARK: - The cards

    // swiftlint:disable line_length
    /// `namedChapter` (VX-292 U3): whether step 3's ring is on the chapter
    /// its approved last sentence names (`Queries.TourLandmarks.firstStoryIsNamed`).
    static func card(_ step: Tour.Step, takeCount: Int = 2, namedChapter: Bool = true) -> Card? {
        switch step {
        case .navigation:
            return Card(
                title: "Navigation",
                body: "Everything lives in one of the places on the left. Bookcase holds your books. Library is everything, searchable. Pool holds notes that aren't in a book, and Snippets keeps pieces of text you reuse between notes.")
        case .seededBook:
            // VX-292 U1 (R-292-1): the U1 COPY DRAFT, the book's name read
            // from its constant (it opens the sentence in the shelf's
            // lowercase, the end card's "readme" precedent).
            return Card(
                title: "The Prince, in Variorum",
                body: "\(seededBookName) comes with the app, so you can try everything on real writing. Machiavelli's Italian rides under every paragraph. Click into it.")
        case .insideBook:
            // VX-292 U1: the approved first three sentences verbatim; the
            // last names the toured chapter (`firstStoryTitle`) by its
            // question, the U1 COPY DRAFT.
            // VX-292 U3 (P-292-11): when R-292-17's fallback rings another
            // chapter, the last sentence names the ring, not XVII.
            let last = namedChapter
                ? "Click into the chapter on whether it is better to be loved or feared."
                : insideBookRingedChapter
            return Card(
                title: "Inside a book",
                body: "A book opens on its Outline: every chapter, and the beginning of every note. A book works like a scrapbook. Put a note in and it stays there. \(last)")
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
        case .takesMode, .takesFlipBack:
            // VX-292 U3 — the flip (both beats, one card: it names both acts
            // in order, and the ring moves from the Italian's band to the
            // English take's). BUILD-VERIFY 1 (P-U2-2) stands: the board's
            // card chooses with its header band (`TakeChooseHeader`'s
            // words, quoted). Departure (a real-app fact): choosing a take
            // flips ONE paragraph, so "this paragraph", not "the page".
            return Card(
                title: "Both takes, side by side",
                body: "This is Takes mode: the whole note, with every version of every block. The \u{2713} take is what the note says. Find the take named \(italianName) and press \(TakeChooseHeader.chooseWord): this paragraph now reads Italian. Choose the English take to bring it back. Choosing decides what the note says; clicking into a take just works in it.")
        case .readInNote:
            // VX-292 U3 (R-292-7). BUILD-VERIFY: Read's switch opens on
            // `edit` (`ReadModeView.rememberedFace`'s default — her ruling;
            // a note she flipped to `read` before remembers it). Departure: the
            // mode list sits in the sidebar's "this note" section — "the rail"
            // is the code's word, never the app's.
            return Card(
                title: PostMode.read.rawValue,
                body: "Click \(PostMode.read.rawValue) in the sidebar. It opens on edit, an outline of the note you can type in; flip the switch to read for the calm page. When you want to write again, click any sentence and you land back at that very block.")
        case .lensesLive:
            // VX-292 U3 (R-292-3, VX-633's lens direction). BUILD-VERIFY: a
            // note opens in Lenses on its own one column, with the dashed
            // "＋ column" door beside it whose menu opens each saved lens
            // (`LensesBoardView.addColumnStub`); every Prince chapter saves a
            // lens of the whole Italian, named by its take label.
            return Card(
                title: PostMode.lenses.rawValue,
                body: "\(PostMode.lenses.rawValue) shows different takes of this note side by side. Click \(PostMode.lenses.rawValue) in the sidebar, then open the column named \(italianName): the whole chapter in Italian beside the English. Same note, two readings.")
        case .deeperModes:
            // VX-292 U3: reworked — Lenses is a live visit now (step 9).
            return Card(
                title: "Two more, for later",
                body: "\(PostMode.compare.rawValue) sets other notes beside this one. \(PostMode.blocks.rawValue) is a workbench for many blocks at once. The field guide teaches each of them.")
        case .upToBook:
            // VX-292 U3 — the book arc's first beat (R-292-10; reworks
            // step 9's climb). BUILD-VERIFY: the book icon's ascent lands the
            // note's own card at the Outline's top (`requestReveal`), the
            // book's four tabs quoted from the row that draws them.
            let tabs = BookView.tabOrder.map(BookView.tabLabel)
            return Card(
                title: "Up to the book",
                body: "Click the book icon: you're back in \(seededBookName), one level up, with your chapter in view. A book has four views of its own along the top: \(tabs[0]), \(tabs[1]), \(tabs[2]) and \(tabs[3]).")
        case .bookAndRead:
            // VX-292 U3 — the second beat: the book's Book tab (the spread —
            // each note a page), then its Read.
            return Card(
                title: "\(BookView.tabLabel(.spread)) and \(BookView.tabLabel(.read))",
                body: "Click \(BookView.tabLabel(.spread)): the chapters become pages, like a bound copy. Then click \(BookView.tabLabel(.read)) to read straight through. Books are for reading whole; notes are where you write.")
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
        case .protectPassphrase, .protectWords, .endCard:
            // The closing cards' words are the Castle faces' own approved
            // sentences (`ProtectionWords`, drawn by `TourClosingCard`), and
            // the end card has its own below.
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
        case .legSettings:
            // VX-292 U3 (R-292-8) — the Settings stop: the U3 COPY DRAFT, its
            // facts read from their homes (the palettes counted from the
            // strip's enum, the default's name its label, the pane its
            // title). Settings opens on General in its own window; this card
            // stays here with next (PROVISIONAL P-292-10).
            return Card(
                title: "Make it yours",
                body: "Settings holds the look: two voices, light and dark, and \(paletteCountWord) colour palettes, \(PaletteCopy.label(Queries.ThemeSettings.unsetStorePalette).lowercased()) leading. The \(SettingsPane.mcp.title) pane connects an AI to your library if you ever want one; nothing connects unless you turn it on. Have a look, then come back.")
        case .legEnd:
            return Card(
                title: "The field guide",
                body: "Everything deeper lives in the field guide: takes in depth, divide and merge, books that collect, privacy. Interactive lessons, in order or as needed. That's the tour. Go write.")
        }
    }

    // MARK: - The closing cards (VX-735 — the end card's two asks, split)

    /// **The passphrase card's title** — the set-passphrase sheet's own,
    /// quoted (`ProtectionWords.setPassphraseTitle`). A forced departure of
    /// the split (recorded in the run's B1 RECORD with its alternative, no
    /// title): the ask stood under the end card's title; standing alone it
    /// wears the title this same ask already carries elsewhere — never new
    /// words. Everything else on the card is the end card's block, verbatim.
    static let protectPassphraseTitle = ProtectionWords.setPassphraseTitle
    /// **The words card's title** — Settings ▸ Protection's words section's
    /// own (`ProtectionWords.wordsSectionTitle`), quoted, for the same reason.
    static let protectWordsTitle = ProtectionWords.wordsSectionTitle

    // MARK: - The end card (the fork, restaged over her own note — A3)

    static let endTitle = "That's the tour."
    static let endBody = "Navigation on the left. Books on the Bookcase. Takes on any block. Your place follows you."
    /// R-13s-28/39: the readme sentence stands although readme seeds later.
    /// A5: no time promise on the main leg — "two more minutes" lives on the
    /// fork's first door only. VX-713 (absorbed by VX-292 U3): "a short
    /// welcome note" became "a welcome note" — the readme VX-105 seeded is her
    /// letter, about 1,800 words, and the sentence must stay true of it.
    static let endAside = "\(ReadmeSeeder.title), a welcome note, is waiting in your Library. And \u{2318}J opens today's journal entry, whenever you want one."
    /// The no-readme form (the extra-pass MINOR-1 honesty gate, PROVISIONAL):
    /// an existing store that predates the seeded readme must not be promised
    /// one, so the aside keeps only the journal sentence — the approved
    /// second sentence minus its connective. The full aside returns the
    /// moment a readme exists (a fresh store, or VX-105's landing).
    static let endAsideJournalAlone = "\u{2318}J opens today's journal entry, whenever you want one."
    static let keepGoing = "Keep going: two more minutes on stars, tags, books and snippets"
    static let openFieldGuide = "Open the field guide, every feature as a lesson"
    static let done = "Done, go write"
    // swiftlint:enable line_length
}
