//
//  SampleLibraryPrinceBook.swift
//  Shared (Variorum + VariorumMobile)
//
//  VX-633 — *THE PRINCE*, BILINGUAL: the launch's seeded book since this
//  effort (her rulings R-633-1…14, `notes/plans/vx-633-prince-book.md`). The
//  whole book — the dedication and all twenty-six chapters — one note per
//  chapter, every paragraph a block carrying TWO takes: W. K. Marriott's 1908
//  English (chosen — the page opens on it) and Machiavelli's Italian (the
//  1814 printing Wikisource transcribes, re-paragraphed by hand to Marriott's
//  breaks, words untouched — the U1 record), labelled "il principe 1532".
//  A few of the most quoted lines carry a THIRD take, Luigi Ricci's
//  translation ("ricci 1903", R-633-19 — the label carries the TEXT's own
//  date per the book's convention (il principe 1532, marriott 1908): Ricci
//  first published 1903, Grant Richards; PG #57037 transcribes the Oxford
//  1909 printing, the credits' fact), and the book's last block — the
//  Petrarch stanza Marriott prints in Italian — carries Edward Dacres' 1640
//  English verse ("dacres 1640", R-633-13 + R-633-20: the catalogues'
//  spelling of his name; Marriott's apparatus line prints "Dacre" and the
//  raw-source pin keeps that spelling where it asserts HIS line).
//
//  ── HOW IT SEEDS (the seeder's own road, `Book.prince`) ──────────────────
//  The English imports exactly as Sherlock's stories do (`ThePrince.txt`,
//  `%%% <title>` lines, one paragraph per line, the typed-note shape — no
//  stored blank line). Then, IN THE SAME RUNNER TURN as the note's import, the
//  take pass below walks the minted blocks in placement order and attaches
//  the other takes through the operations her own hands reach —
//  `newBlankVariant` + `autosave` + `setTakeLabel` (the Takemania road), on
//  the quiet facade, under the book's clock — so a note never exists without
//  its Italian, and the seeder's cancel/resume road stays correct by
//  construction (cancellation lands only between turns). Nothing is chosen
//  but Marriott's takes.
//
//  The Italian (`ThePrinceItaliano.txt`) carries the SAME `%%%` titles in the
//  same order; its paragraphs are separated by a BLANK line, because two of
//  them hold newlines of their own (the Virgil couplet, the Petrarch stanza —
//  newlines inside a block are content, I4). Pairing is by title and
//  paragraph index; `notes/source/prince-extract.py` enforces the per-note
//  count equality at generation, the seed-shape suite pins it in the build,
//  and the pass refuses a drifted pair at seed time (DEBUG: loud; Release:
//  that note's takes are skipped, never a crashed seed).
//
//  Every CHAPTER also ships with SAVED LENSES (R-633-15 — her words: "saved
//  lenses on the seed book is definitely a need"), minted by the same pass
//  in the same turn, named by the take-label pattern: "marriott 1908" (every
//  block its English take, by explicit id — the way back after choosing
//  Italian), "il principe 1532" (every block its Italian), and on the
//  chapters that carry them "ricci 1903" / "dacres 1640" (that block its
//  third take, the rest following the chosen). A lens is never rendering
//  truth — the page still opens on Marriott.
//
//  The note's book is grouped into the FOUR PARTS her R-633-5 names (its
//  second set, lowercased to the shelf idiom) rather than one chapter per
//  note: the notes ARE the chapters, the book's `reading_section` rows are the
//  parts (`NoteGrouping.princeParts`), plus the front note's own section and —
//  R-633-17 — the Dedication's own, "dedication", before part one.
//
//  ── OUTSIDE THE PRISTINE DEDUPE (the Jekyll precedent) ───────────────────
//  A born-fanned copy always reads EDITED to the sync engine's pristine-copy
//  classifier, so the book joins `Book.all` with `joinsPristineDedupe: false`
//  and the engine's facts stay byte-identical (zero `Sync/`). Two devices that
//  each seed before their first sync therefore keep two copies — R-633-7's
//  two-copies line said so; R-633-18 (U2b, her word: "it seems worse to say
//  it") takes it OUT of the front note, which lands with her edited text.
//

import Dependencies
import Foundation
import VariorumCore

nonisolated enum SampleLibraryPrinceBook {
    /// The book's reserved name — EXACT and case-sensitive for discovery
    /// (R-633-3: "the prince", the shelf's lowercase idiom).
    static let name = "the prince"
    /// The reserved tag path (R-633-9, her word: "the tag can be
    /// 'machiavelli' - i like that") — a top-level sibling of the other
    /// seeded books' tags, so the whole book is findable and removable as a
    /// set.
    static let tagName = "machiavelli"
    /// The front matter: its own section (Sherlock's `frontMatterChapter`
    /// pattern) and its note, both "about this text" (the plan's U2 brief).
    static let frontMatterChapter = "about this text"
    static let frontMatterTitle = "about this text"
    /// The two bundled resources, derived by `notes/source/prince-extract.py`.
    static let resourceName = "ThePrince"
    static let italianResourceName = "ThePrinceItaliano"
    /// The defaults mark's suffix — its OWN mark
    /// (`SampleLibrarySeeded.<variant>.the-prince`), the encryption and
    /// Jekyll books' precedent.
    static let markSuffix = "the-prince"

    /// **The book's own clock: 4 January 1532, Antonio Blado's Rome edition —
    /// the first printing** (the colophon: "Stampato in Roma, per Antonio
    /// Blado d'Asola, a di 4 de Gennaio del 1532") — Sherlock's m6 precedent
    /// (`SampleLibrarySeeder.publicationStamp`): every row of the seed sorts
    /// to the bottom of every recency view instead of landing above her own
    /// writing. Pre-1582, so the store's Gregorian formatter reads it on the
    /// Julian calendar — the SAME formatter parses and writes it, so the
    /// stamp round-trips byte-identically (the seed-shape suite pins it).
    static let publicationStamp = "1532-01-04T00:00:00.000Z"
    static let publicationDate =
        DateFormatter.variorumISO8601.date(from: publicationStamp)
            ?? Date(timeIntervalSince1970: 0)

    // MARK: - The take labels

    /// R-633-3 (her words: "the title in both and just the title changes to
    /// italian") — names the WORK; the 1814 printing is disclosed in the
    /// front note (R-633-10).
    static let italianTakeLabel = "il principe 1532"
    /// R-633-14 — ratified ("I think that's fine honestly"), its year
    /// CORRECTED to 1909 at U2b (the author's front-note edit, confirmed by
    /// the primary source: PG #57037's title page reads "OXFORD UNIVERSITY
    /// PRESS … 1909", `notes/source/prince-ricci-pg57037.txt` ~line 54; the
    /// earlier 1903 was an unverified recollection). It names the Ricci LENS
    /// too (the take-label pattern).
    static let ricciTakeLabel = "ricci 1903"
    /// R-633-13 — the ruled label pattern.
    static let dacreTakeLabel = "dacres 1640"
    /// R-633-15 — the English lens's name: the take-label pattern for
    /// Marriott's takes, which carry no label of their own (the chosen
    /// original). The other lenses are named by their takes' labels.
    static let englishLensName = "marriott 1908"

    // MARK: - The dedication and the four parts (R-633-5, her second set, lowercased; R-633-17)

    /// The Dedication's own chapter — R-633-17, her D3 ruling at the sitting:
    /// "the Dedication gets ITS OWN CHAPTER — a one-note section named
    /// 'dedication' before part one".
    static let dedicationChapter = "dedication"

    /// The book's chapters, in order: each one's name and the LAST chapter
    /// number it holds. Roman-numbered notes fall in by number; the
    /// Dedication has no number and sits ALONE in the first entry (R-633-17 —
    /// it holds no numbered chapter, hence 0), so the seed, which mints a
    /// chapter at its first note, makes "dedication" right after the front
    /// matter's and before part one. (U2 put the Dedication in part one,
    /// PROVISIONAL; her ruling superseded it.)
    static let parts: [(name: String, throughChapter: Int)] = [
        (dedicationChapter, 0),
        ("types of principalities", 11),
        ("military and armies", 14),
        ("rulership, conduct, and virtue", 23),
        ("the state of italy and conclusion", 26),
    ]

    /// The chapter a note's title belongs in. A title without a roman
    /// numeral — the Dedication — has its own (R-633-17).
    static func part(for title: String) -> String {
        guard let number = chapterNumber(of: title) else { return dedicationChapter }
        return parts.first { number <= $0.throughChapter }?.name ?? parts[parts.count - 1].name
    }

    /// `XVIII. Concerning…` → 18; nil for a title with no numeral prefix.
    static func chapterNumber(of title: String) -> Int? {
        guard let dot = title.firstIndex(of: ".") else { return nil }
        let numeral = title[..<dot]
        let values: [Character: Int] = ["I": 1, "V": 5, "X": 10, "L": 50, "C": 100]
        guard !numeral.isEmpty, numeral.allSatisfy({ values[$0] != nil }) else { return nil }
        let digits = numeral.compactMap { values[$0] }
        var total = 0
        for (index, value) in digits.enumerated() {
            let next = index + 1 < digits.count ? digits[index + 1] : 0
            total += value < next ? -value : value
        }
        return total
    }

    // MARK: - The front note

    // HER FINAL TEXT (the edit pass of 2026-10-28, landed verbatim in its
    // words; the typography normalized to the seeded books' own — curly
    // quotes and apostrophes, `\u{25B8}` for ▸, single spacing — exactly as
    // she blessed: "normalization of those items is good"). The Help door it
    // names is the registry's spelling (`restorePrinceBook`'s verb; the
    // seed-shape suite pins the match). Paragraphs are separated by ONE
    // newline, so each lands as a block with no stored blank line (the
    // Jekyll book's design call 4). The easter-egg paragraph's claims are
    // fact-checked (the plan's fact-check round: the Testina's dates, the
    // XVIII omissions collated in our own sources); the tutorial-restore
    // sentence is her knowing forward-promise on VX-292 (the plan's U3). The
    // two-copies paragraph is ruled OUT (R-633-18).
    static let aboutThisText = """
        This book is \u{201C}The Prince\u{201D} by Niccol\u{F2} Machiavelli, seeded here as an \
        example to show some of the capabilities of Variorum. True to the definition of variorum, \
        this is a literary work with variant readings across different languages and times. Every \
        chapter is a single note within the book and every paragraph carries at least two takes: \
        W. K. Marriott\u{2019}s 1908 English translation, which is the chosen take throughout the \
        book, and Machiavelli\u{2019}s original Italian beside it. While it was originally \
        published in 1532, the Italian version is from an 1814 printing.
        One easter egg in chapter XVIII shows how editions can differ in substance. The Italian \
        text here shares the same omissions as the clandestine printings \u{2014} the \
        \u{201C}Testina\u{201D} \u{2014} made while the book was banned in the 1600s. One such \
        omission is the missing \u{201C}contro alla fede\u{201D} (\u{201C}against \
        faith\u{201D}) in Machiavelli\u{2019}s list of what a prince must be ready to work \
        against. A few lines later, Machiavelli announces that a prince should *seem* to have \
        five qualities, but in Italian only four are listed \u{2014} faith is omitted again.
        Feel free to explore all the different ways to work with the same text \u{2014} the \
        tutorial walks you through much of it, but you can read these notes in the context of \
        their book or click into each note to experience the Write, Takes, Read, Lenses, \
        Compare, and Blocks modes. If you dismissed the tutorial offer, you can always begin it \
        under Help in the top menu bar.
        Each chapter has at least two saved lenses: in Lenses, the column titled \
        \u{201C}il principe 1532\u{201D} lets you see the whole chapter in Italian beside the \
        English. If you prefer to read in Italian, the Lenses page allows you to make that lens \
        the chosen reading. Some of the most famous lines \u{2014} whether it is better to be \
        loved or feared, for example \u{2014} also have a third take from Luigi Ricci\u{2019}s \
        1903 translation, and the closing stanza of Petrarch has Edward Dacres\u{2019} 1640 \
        verse due to Marriott\u{2019}s decision to keep that stanza in Italian.
        Credits: Marriott\u{2019}s English translation comes from Project Gutenberg\u{2019}s \
        eBook #1232 (published 1908), the Italian from Wikisource\u{2019}s transcription of an \
        1814 printing, Ricci (first published 1903) from Project Gutenberg\u{2019}s eBook \
        #57037, and Dacres\u{2019} verse from Marriott\u{2019}s own apparatus. All works are in \
        the public domain, with headers and license matter removed and the line wrapping edited \
        so each paragraph is one block. If you delete the book and want it back, it can always \
        be restored via the top bar\u{2019}s Help \u{25B8} Restore \u{201C}\(name)\u{201D}. \
        Restarting the tutorial will restore this book to its default state as well.
        """

    // MARK: - The seeded comments (her ruling at the edit-pass sitting,
    // 2026-10-28: Marriott's footnote and the editor's answer, two comments
    // in order on the block where the easter-egg hunt ends — "having
    // Marriott's footnote and then our own response in two comments shows
    // how comment chains can function". The quote is her trim of footnote
    // [4] (the raw source's words; his papal-sanction claim stays INSIDE the
    // attributed quote); the editor's note is her sentence with the (a)
    // citation form she picked ("study of the Testina editions").

    struct SeededComments: Sendable, Equatable {
        var noteTitle: String
        var paragraphIndex: Int
        /// In gutter order — minted a second apart on the book's clock.
        var texts: [String]
    }

    static let seededComments = [
        SeededComments(
            noteTitle: "XVIII. Concerning the way in which princes should keep faith",
            paragraphIndex: 3,
            texts: [
                "Marriott\u{2019}s 1908 footnote: \u{201C}It is noteworthy that these two "
                    + "phrases, \u{2018}contro alla fede\u{2019} and \u{2018}tutto fede,\u{2019} "
                    + "were omitted in the Testina edition, which was published with the "
                    + "sanction of the papal authorities. It may be that the meaning attached "
                    + "to the word \u{2018}fede\u{2019} was \u{2018}the faith,\u{2019} i.e. the "
                    + "Catholic creed.\u{201D}",
                "Editor\u{2019}s note: it should be noted that modern scholars dispute "
                    + "Marriott\u{2019}s claim of papal sanction. Refer to Adolph "
                    + "Gerber\u{2019}s 1906 study of the Testina editions to discover more "
                    + "about this history.",
            ])
    ]

    // MARK: - The English verse, line-broken again (the plan's ledger item 8)

    /// A block whose English the import flattened: bulk segmentation splits
    /// on every newline, so the EN resource carries each verse paragraph on
    /// one line (its lines joined by a space). The pass puts the line breaks
    /// back with one `autosave` of the chosen take — validated first: the
    /// line-broken text with each newline read as a space must be EXACTLY the
    /// imported text, or nothing is written (DEBUG: loud).
    struct VerseRestoration: Sendable, Equatable {
        var noteTitle: String
        var paragraphIndex: Int
        var text: String

        /// What the import stores for this paragraph.
        var flattened: String { text.replacingOccurrences(of: "\n", with: " ") }
    }

    static let verseRestorations: [VerseRestoration] = [
        // XVII — Dido's couplet (Virgil, *Aeneid* I.563–4), as Marriott sets it.
        VerseRestoration(
            noteTitle: "XVII. Concerning cruelty and clemency, and whether it is better to be loved than feared",
            paragraphIndex: 2,
            text: "\u{201C}Res dura, et regni novitas me talia cogunt\n"
                + "Moliri, et late fines custode tueri.\u{201D}"),
        // XXVI — Petrarch's stanza, which Marriott prints in Italian. His
        // second and fourth lines are indented in PG #1232; the indent is not
        // kept (four leading spaces would read as code in the markdown face).
        VerseRestoration(
            noteTitle: "XXVI. An exhortation to liberate Italy from the barbarians",
            paragraphIndex: 10,
            text: "Virtu contro al Furore\n"
                + "Prendera l\u{2019}arme, e fia il combatter corto:\n"
                + "Che l\u{2019}antico valore\n"
                + "Negli italici cuor non e ancor morto."),
    ]

    // MARK: - The third takes

    /// One block's third take: which block (the note and its 0-based
    /// paragraph index), what proves it is the right block (`quoteHint`, a
    /// verbatim fragment of that block's ENGLISH — checked at seed time
    /// before anything is written), the take's text and its label.
    struct ThirdTake: Sendable, Equatable {
        var noteTitle: String
        var paragraphIndex: Int
        var quoteHint: String
        var text: String
        var label: String
    }

    /// **R-633-4's standout lines, Ricci's rendering** — the U1 record's
    /// final set of six. TRANSCRIBED here from `notes/source/prince-famous-
    /// lines.json` (U1's generated table) rather than bundled, deliberately:
    /// the JSON is the extract script's output in `notes/source/`, outside
    /// the app's synchronized groups, so bundling it would mean a second
    /// copy (or a project-file edit) to keep in step anyway; a Swift table is
    /// parse-free at seed time and reads whole in review; and the drift pin
    /// (`PrinceSeedTests.theFamousLinesMatchTheGeneratedTable`) compares
    /// every field against the JSON byte for byte, so a regenerated table
    /// that is not re-transcribed fails the suite. Generated mechanically
    /// from the JSON (escapes for every non-ASCII character), never typed.
    static let famousLines: [ThirdTake] = [
        ThirdTake(
            noteTitle: "VI. Concerning new principalities which are acquired by one\u{2019}s own arms and ability",
            paragraphIndex: 4,
            quoteHint: "there is nothing more difficult to take in hand, more perilous to conduct, or more uncertain in its success, than to take the lead in the introduction of a new order of things",
            text: """
                Those who by heroic means such as these become princes, obtain their dominions with \
                difficulty but retain them easily, and the difficulties which they have in acquiring their \
                dominions arise in part from the new rules and regulations that they have to introduce in \
                order to establish their position securely. It must be considered that there is nothing more \
                difficult to carry out, nor more doubtful of success, nor more dangerous to handle, than to \
                initiate a new order of things. For the reformer has enemies in all those who profit by the \
                old order, and only lukewarm defenders in all those who would profit by the new order, this \
                lukewarmness arising partly from fear of their adversaries, who have the laws in their \
                favour; and partly from the incredulity of mankind, who do not truly believe in anything new \
                until they have had actual experience of it. Thus it arises that on every opportunity for \
                attacking the reformer, his opponents do so with the zeal of partisans, the others only \
                defend him half-heartedly, so that between them he runs great danger.
                """,
            label: ricciTakeLabel),
        ThirdTake(
            noteTitle: "XV. Concerning things for which men, and especially princes, are praised or blamed",
            paragraphIndex: 0,
            quoteHint: "how one lives is so far distant from how one ought to live",
            text: """
                It remains now to be seen what are the methods and rules for a prince as regards his \
                subjects and friends. And as I know that many have written of this, I fear that my writing \
                about it may be deemed presumptuous, differing as I do, especially in this matter, from the \
                opinions of others. But my intention being to write something of use to those who understand \
                it, it appears to me more proper to go to the real truth of the matter than to its \
                imagination; and many have imagined republics and principalities which have never been seen \
                or known to exist in reality; for how we live is so far removed from how we ought to live, \
                that he who abandons what is done for what ought to be done, will rather learn to bring \
                about his own ruin than his preservation. A man who wishes to make a profession of goodness \
                in everything must necessarily come to grief among so many who are not good.
                """,
            label: ricciTakeLabel),
        ThirdTake(
            noteTitle: "XVII. Concerning cruelty and clemency, and whether it is better to be loved than feared",
            paragraphIndex: 4,
            quoteHint: "it is much safer to be feared than loved",
            text: """
                From this arises the question whether it is better to be loved more than feared, or feared \
                more than loved. The reply is, that one ought to be both feared and loved, but as it is \
                difficult for the two to go together, it is much safer to be feared than loved, if one of \
                the two has to be wanting. For it may be said of men in general that they are ungrateful, \
                voluble, dissemblers, anxious to avoid danger, and covetous of gain; as long as you benefit \
                them, they are entirely yours; they offer you their blood, their goods, their life, and \
                their children, as I have before said, when the necessity is remote; but when it approaches, \
                they revolt. And the prince who has relied solely on their words, without making other \
                preparations, is ruined, for the friendship which is gained by purchase and not through \
                grandeur and nobility of spirit is merited but is not secured, and at times is not to be \
                had. And men have less scruple in offending one who makes himself loved than one who makes \
                himself feared; for love is held by a chain of obligation which, men being selfish, is \
                broken whenever it serves their purpose; but fear is maintained by a dread of punishment \
                which never fails.
                """,
            label: ricciTakeLabel),
        ThirdTake(
            noteTitle: "XVIII. Concerning the way in which princes should keep faith",
            paragraphIndex: 0,
            quoteHint: "it is necessary to be a fox to discover the snares and a lion to terrify the wolves",
            text: """
                How laudable it is for a prince to keep good faith and live with integrity, and not with \
                astuteness, every one knows. Still the experience of our times shows those princes to have \
                done great things who have had little regard for good faith, and have been able by \
                astuteness to confuse men's brains, and who have ultimately overcome those who have made \
                loyalty their foundation. You must know, then, that there are two methods of fighting, the \
                one by law, the other by force: the first method is that of men, the second of beasts; but \
                as the first method is often insufficient, one must have recourse to the second. It is \
                therefore necessary to know well how to use both the beast and the man. This was covertly \
                taught to princes by ancient writers, who relate how Achilles and many others of those \
                princes were given to Chiron the centaur to be brought up, who kept them under his \
                discipline; this system of having for teacher one who was half beast and half man is meant \
                to indicate that a prince must know how to use both natures, and that the one without the \
                other is not durable. A prince being thus obliged to know well how to act as a beast must \
                imitate the fox and the lion, for the lion cannot protect himself from snares, and the fox \
                cannot defend himself from wolves. One must therefore be a fox to recognise snares, and a \
                lion to frighten wolves. Those that wish to be only lions do not understand this. Therefore, \
                a prudent ruler ought not to keep faith when by so doing it would be against his interest, \
                and when the reasons which made him bind himself no longer exist. If men were all good, this \
                precept would not be a good one; but as they are bad, and would not observe their faith with \
                you, so you are not bound to keep faith with them. Nor are legitimate grounds ever wanting \
                to a prince to give colour to the non-fulfilment of his promise. Of this one could furnish \
                an infinite number of modern examples, and show how many times peace has been broken, and \
                how many promises rendered worthless, by the faithlessness of princes, and those that have \
                been best able to imitate the fox have succeeded best.
                """,
            label: ricciTakeLabel),
        ThirdTake(
            noteTitle: "XVIII. Concerning the way in which princes should keep faith",
            paragraphIndex: 4,
            quoteHint: "Every one sees what you appear to be, few really know what you are",
            text: """
                A prince must take great care that nothing goes out of his mouth which is not full of the \
                above-named five qualities, and, to see and hear him, he should seem to be all faith, all \
                integrity, all humanity, and all religion. And nothing is more necessary than to seem to \
                have this last quality, for men in general judge more by the eyes than by the hands, for \
                every one can see, but very few have to feel. Everybody sees what you appear to be, few feel \
                what you are, and those few will not dare to oppose themselves to the many, who have the \
                majesty of the state to defend them; and in the actions of men, and especially of princes, \
                from which there is no appeal, the end is everything.
                """,
            label: ricciTakeLabel),
        ThirdTake(
            noteTitle: "XXV. What fortune can effect in human affairs and how to withstand her",
            paragraphIndex: 1,
            quoteHint: "I compare her to one of those raging rivers",
            text: """
                I would compare her to an impetuous river that, when turbulent, inundates the plains, ruins \
                trees and buildings, removes earth from this side and places it on the other; every one \
                flies before it, and everything yields to its fury without being able to oppose it; and yet \
                though it is of such a kind, still when it is quiet, men can make provision against it by \
                dams and banks, so that when it rises it will either go into a canal or its rush will not be \
                so wild and dangerous. It happens similarly with fortune, which shows her power where no \
                measures have been taken to resist her, and turns her fury where she knows that no dams or \
                barriers have been made to hold her.
                """,
            label: ricciTakeLabel),
    ]

    /// **R-633-13 — Edward Dacre's 1640 English verse on the book's last
    /// block** (XXVI's closing Petrarch stanza). The four lines PG #1232
    /// prints after the stanza (raw lines 3690–3693), line breaks kept and
    /// the indent of the second and fourth lines dropped (the stanza
    /// restoration's reason); the "Edward Dacre, 1640." attribution line is
    /// NOT part of the take. Pinned against the raw source text
    /// (`PrinceSeedTests.dacresVerseIsTheRawSourcesFourLines`). The hint
    /// anchors on Marriott's first line of the stanza.
    static let dacre = ThirdTake(
        noteTitle: "XXVI. An exhortation to liberate Italy from the barbarians",
        paragraphIndex: 10,
        quoteHint: "Virtu contro al Furore",
        text: "Virtue against fury shall advance the fight,\n"
            + "And it i\u{2019} th\u{2019} combat soon shall put to flight:\n"
            + "For the old Roman valour is not dead,\n"
            + "Nor in th\u{2019} Italians\u{2019} brests extinguished.",
        label: dacreTakeLabel)

    /// Every third take, in seeding order.
    static var thirdTakes: [ThirdTake] { famousLines + [dacre] }

    // MARK: - The Italian

    /// `ThePrinceItaliano.txt`, parsed: note title → its paragraphs in
    /// order. The notes arrive already split by the seeder's own delimiter
    /// parse (`SampleLibrarySeeder.parse`, title + text); a note's paragraphs
    /// are separated by a BLANK line, because a paragraph may hold newlines
    /// of its own (the two verse paragraphs). Pure, so a pin can drive it.
    static func italianParagraphs(
        _ notes: [(title: String, text: String)]
    ) -> [String: [String]] {
        var byTitle: [String: [String]] = [:]
        for note in notes {
            byTitle[note.title] = note.text
                .components(separatedBy: "\n\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return byTitle
    }

    // MARK: - The take pass

    /// What one note's pass did — for the seed-shape pins and the log.
    struct PassReport: Equatable, Sendable {
        var italianTakes = 0
        var thirdTakes = 0
        var versesRestored = 0
        /// The saved lenses minted, by name, in minting order.
        var lenses: [String] = []
        /// The seeded comments minted (the XVIII footnote pair).
        var comments = 0
        /// Non-empty only when something did not match (and was skipped):
        /// a DEBUG build has already stopped on it.
        var skipped: [String] = []
    }

    /// **The per-note take pass** — run by the seeder right after a FRESH
    /// import of `title` (never on a re-membered or copied note: those carry
    /// their own takes and lenses), inside the same runner turn, on the quiet
    /// facade, under the book's clock. `noteID` and `blockIDs` are the
    /// import's (blocks in placement order); `italian` is the note's Italian
    /// paragraphs. The English each block holds is read from the STORE (the
    /// same ambient database the facade writes through — `Takemania`'s
    /// `liveActiveFan` precedent), never assumed from the resource. Its last
    /// acts are the note's saved lenses (R-633-15) and XVIII's seeded
    /// comment pair (her edit-pass ruling), so a note present implies its
    /// takes, lenses AND comments present (cancellation lands only between
    /// turns).
    ///
    /// A mismatch never writes and never crashes a Release seed: a missing
    /// or miscounted Italian skips the whole note's takes and lenses; a third
    /// take or verse whose English anchor is not where the table says skips
    /// just that write (and a third take skipped leaves its lens unminted).
    /// In DEBUG every skip is an `assertionFailure` — loud, by design (the
    /// brief's rule).
    @discardableResult
    static func attachTakes(
        _ ops: Operations, title: String, noteID: String, blockIDs: [String], italian: [String]?,
        undoLabel: String
    ) throws -> PassReport {
        var report = PassReport()
        func skip(_ why: String) {
            report.skipped.append(why)
            assertionFailure("VX-633 take pass: \(why)")
        }
        guard let italian, italian.count == blockIDs.count else {
            skip("\(title): \(italian?.count ?? 0) Italian paragraphs for \(blockIDs.count) blocks")
            return report
        }
        // A fresh import mints exactly ONE take per block — Marriott's.
        @Dependency(\.database) var database
        let fans = try database.read { db in try Queries.activeFans(db, blockIDs: blockIDs) }
        // The lenses' picks, block → take, gathered as the takes land.
        var englishPicks: [String: String] = [:]
        var italianPicks: [String: String] = [:]
        var thirdPicks: [String: [String: String]] = [:]   // label → block → take
        for (index, blockID) in blockIDs.enumerated() {
            guard let english = fans[blockID]?.first, fans[blockID]?.count == 1 else {
                skip("\(title) ¶\(index): the block is not a fresh one-take import")
                continue
            }
            englishPicks[blockID] = english.id
            // The English verse, line-broken again (validated first).
            if let verse = verseRestorations.first(where: {
                $0.noteTitle == title && $0.paragraphIndex == index
            }) {
                if verse.flattened == english.workingText {
                    try ops.autosave(
                        english.id, text: verse.text,
                        charDelta: english.workingText.count + verse.text.count)
                    report.versesRestored += 1
                } else {
                    skip("\(title) ¶\(index): the verse's English is not the imported text")
                }
            }
            // Take 2 — Machiavelli's Italian.
            italianPicks[blockID] = try addTake(ops, to: blockID, text: italian[index], label: italianTakeLabel)
            report.italianTakes += 1
            // Take 3 — Ricci's rendering, or Dacre's verse.
            for third in thirdTakes where third.noteTitle == title && third.paragraphIndex == index {
                guard english.workingText.contains(third.quoteHint) else {
                    skip("\(title) ¶\(index): \u{201C}\(third.quoteHint)\u{201D} is not in its English")
                    continue
                }
                thirdPicks[third.label, default: [:]][blockID] =
                    try addTake(ops, to: blockID, text: third.text, label: third.label)
                report.thirdTakes += 1
            }
        }
        // The saved lenses (R-633-15), through the operations layer's own
        // lens door (`saveLens` — the MCP door's `save_lens` body: picks
        // validated as `setLensChoice` validates them, never a placement's
        // chosen take touched; the quiet facade registers no undo). "marriott
        // 1908" names EVERY block explicitly — a lens that only followed the
        // chosen would be no way back once she chose Italian; "il principe
        // 1532" every block; the third-take lenses only their blocks (sparse
        // — the rest follow the chosen, the lens model's own default). Each
        // lens one SECOND after the last on the book's clock, so the Lenses
        // list (created_at, id) reads in this order on every device rather
        // than by random id (the stamps a few seconds into the book's day).
        var lenses: [(name: String, picks: [String: String])] = [
            (englishLensName, englishPicks), (italianTakeLabel, italianPicks),
        ]
        for label in [ricciTakeLabel, dacreTakeLabel] {
            if let picks = thirdPicks[label], !picks.isEmpty { lenses.append((label, picks)) }
        }
        @Dependency(\.date) var date
        let base = date.now
        for (offset, lens) in lenses.enumerated() where !lens.picks.isEmpty {
            try withDependencies {
                $0.date = .constant(base.addingTimeInterval(Double(offset)))
            } operation: {
                _ = try ops.saveLens(post: noteID, name: lens.name, picks: lens.picks, undoLabel: undoLabel)
            }
            report.lenses.append(lens.name)
        }
        // The seeded comments (her edit-pass ruling): minted LAST, a second
        // apart from ten seconds past the lenses' stamps, so the gutter
        // reads footnote-then-editor's-note on every device. Same skip
        // discipline as the takes: a block that is not where the table says
        // skips loudly in DEBUG and quietly in Release.
        for entry in seededComments where entry.noteTitle == title {
            guard blockIDs.indices.contains(entry.paragraphIndex) else {
                skip("\(title): no ¶\(entry.paragraphIndex) for the seeded comments")
                continue
            }
            let blockID = blockIDs[entry.paragraphIndex]
            for (offset, text) in entry.texts.enumerated() {
                try withDependencies {
                    $0.date = .constant(base.addingTimeInterval(Double(10 + offset)))
                } operation: {
                    _ = try ops.addBlockComment(to: blockID, text: text)
                }
                report.comments += 1
            }
        }
        return report
    }

    /// A genuinely different take, begun blank, written, named — never chosen
    /// (`newBlankVariant` appends at the fan's end and leaves the pointer's
    /// choice alone).
    private static func addTake(
        _ ops: Operations, to blockID: String, text: String, label: String
    ) throws -> String {
        let take = try ops.newBlankVariant(blockID)
        try ops.autosave(take.id, text: text, charDelta: text.count)
        try ops.setTakeLabel(take.id, label: label)
        return take.id
    }
}
