//
//  SampleLibraryJekyllBook.swift
//  Shared (Variorum + VariorumMobile)
//
//  18l-c U6 — *THE STRANGE CASE OF DR JEKYLL AND MR HYDE*: the third seeded
//  book's reserved identities and its front-matter note. The author's own
//  request (her 18l-c kickoff message, verbatim in
//  `notes/plans/phase-18l-c-navigation-feel.md`): *"make an example file
//  called takemania for me, so that I can use it to test. It should come with
//  a decent amount of history and feel like a note that has been edited very
//  heavily"* — seeded, restorable, *"it'll just be like the others."*
//
//  R-18l-11 gives takemania ITS OWN SMALL BOOK, riding
//  `SampleLibrarySeeder` exactly like Sherlock (`Book.jekyllAndHyde`): the
//  front matter below, two chapters of the novella as straight text
//  (`JekyllAndHyde.txt`, derived by `notes/source/jekyll-extract.py`), and
//  between them takemania — the middle of the story, reworked, minted by a
//  SCRIPTED HISTORY of real operations (`Takemania.swift`), never painted
//  rows.
//
//  R-18l-12 rules the sample-library dedupe question AS A DISCLAIMER, never
//  machinery: the front-matter note carries the three things she named —
//  the deleted/Leaving blocks are on purpose and age out, Restore gives the
//  full experience back, and a second device can show the book twice. The
//  wording is PROVISIONAL — hers to polish (the U6 record says so).
//

import Foundation
import VariorumCore

nonisolated enum SampleLibraryJekyllBook {
    /// The book's reserved name — EXACT and case-sensitive for discovery.
    /// **Lowercased at 13s-b U1b (R-13s-37/38, her words: "dr jekyll and mr
    /// hyde restorable (also needs consistent casing)" · "one casing, do
    /// not mix several … that's fine for it only changing the defaults for
    /// fresh mints"):** the seed's own style ("the adventures of sherlock
    /// holmes", "the field guide"). FRESH MINTS ONLY by construction — the
    /// restore door mints with this name; an existing store's title-case
    /// copy is her data, never renamed, and a Restore press beside one
    /// mints a lowercase copy rather than finding the old (the recorded
    /// consequence — nothing lost, either deletable; Jekyll is outside the
    /// pristine dedupe, QUESTIONS #155). The ATTRIBUTION below keeps the
    /// published work's title case — a citation is prose, not a label
    /// (Sherlock's own front matter is the precedent).
    static let name = "the strange case of dr jekyll and mr hyde"
    /// The reserved tag path — a top-level sibling of `sherlock holmes` and
    /// `encryption explained`, so the whole book is findable and removable
    /// as a set.
    static let tagName = "jekyll and hyde"
    static let frontMatterChapter = "about this book"
    static let frontMatterTitle = "About this book"
    /// The bundled resource: the two QUIET chapters (`%%% <title>` lines
    /// separate them and are never stored). takemania is not in it.
    static let resourceName = "JekyllAndHyde"
    /// The defaults mark's suffix — its OWN mark
    /// (`SampleLibrarySeeded.<variant>.jekyll-and-hyde`), so an existing
    /// store whose Sherlock and encryption-book marks are set still seeds
    /// this book at its next occasion.
    static let markSuffix = "jekyll-and-hyde"

    /// **The book's own clock: 5 January 1886, the day Longmans published
    /// the novella** — Sherlock's m6 precedent (`SampleLibrarySeeder.
    /// publicationStamp`): the skeleton, the front matter and the two quiet
    /// chapters sort to the bottom of every recency view instead of landing
    /// above her own writing. takemania's HISTORY does not run on it — see
    /// `Takemania`'s header for why its clock is relative to the seed.
    static let publicationStamp = "1886-01-05T00:00:00.000Z"
    static let publicationDate =
        DateFormatter.variorumISO8601.date(from: publicationStamp)
            ?? Date(timeIntervalSince1970: 0)

    /// The front-matter note: the attribution, what the book holds, and
    /// R-18l-12's disclaimer in three plain paragraphs — (1) the tray ships
    /// full on purpose and empties on the ordinary clock, so Restore is how
    /// to get the full experience back; (2) a second device can show the
    /// book twice, and how to remove one copy — its notes AND the book,
    /// because deleting a book keeps its notes (the U6 ladder's F3; the
    /// shared tag cannot tell the two copies apart); (3) the tag sentence the
    /// other seeded books carry. PROVISIONAL wording — hers to polish.
    ///
    /// Paragraphs are separated by ONE newline, so each lands as a block
    /// with no stored blank line (the whole book's shape — the U6 record's
    /// design call 4). The Restore door is named as the Mac spells it: the
    /// phone has no restore row for this book (none for Sherlock either —
    /// recorded at QUESTIONS #155(b)).
    static let aboutThisBook = """
        \u{201C}The Strange Case of Dr Jekyll and Mr Hyde\u{201D} by Robert Louis Stevenson, first \
        published in January 1886. The novella is in the public domain; the text comes from \
        Project Gutenberg\u{2019}s edition (eBook #42), with Project Gutenberg\u{2019}s own header \
        and licence matter removed and the hard line wrapping undone.
        Two chapters stand here as Stevenson wrote them: the first, \u{201C}Story of the \
        Door\u{201D}, and the last, \u{201C}Henry Jekyll\u{2019}s Full Statement of the \
        Case\u{201D}. Between them is takemania \u{2014} the middle of the story, reworked by \
        hand over several weeks. It is a note to practise on, and its history is real: blocks \
        with several takes beside blocks with none, savepoints spread over the weeks (some of \
        them named), paragraphs that were divided and merged (their originals wait in the \
        note\u{2019}s tray and behind the lineage doors), and a few blocks already deleted. \
        Divide it, merge it, delete from it, try the takes.
        Those deleted blocks are in takemania\u{2019}s tray on purpose, and they leave on the \
        same thirty-day clock as anything you delete. To have the whole thing again \u{2014} \
        after you have played with it, or after time has passed \u{2014} delete the takemania \
        note and, on the Mac, choose Help \u{25B8} Restore \u{201C}\(name)\u{201D}: a fresh \
        takemania comes back with its full history.
        If you use Variorum on more than one device, this book can appear twice: each device \
        sets it up on its own, and a book that arrives with a history of its own is never \
        folded into the other copy automatically. To keep just one, open the copy you \
        don\u{2019}t want and delete its notes, then the book \u{2014} deleting a book on its \
        own keeps its notes, and they would wait in the Pool. Both go to the Trash like \
        anything else you delete.
        Every note here is tagged \u{201C}\(tagName)\u{201D}, so the whole book is findable \
        and removable as a set.
        """
}
