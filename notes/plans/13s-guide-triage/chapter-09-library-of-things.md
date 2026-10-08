# Chapter 09 — the library of things (triage draft, U3 · R-13s-30)

Current seat: 9 of 10. Proposed seat: 8. Lessons: comments & tags · search · pool &
scraps · export — it's all yours · the seal. "Three ways of working" departs to the
welcome chapter under the proposed move-up (drafted in `chapter-01-welcome.md`; if she
declines the move it stays here, with the one-clause swap that file's change log
carries). The "search" lesson joined from VX-83's merge to main (VX-89; ground truth
read from MAIN's seeder at `~/dev/variorum` — this branch has not merged it yet). Its
seat honors P-VX83-B2 (right after "comments & tags"), which this pass's proposed
order leaves untouched: the chapter moves as one. Conventions: see `00-overview.md`.

---

## Lesson: comments & tags

### Final text

A comment is a working note on a block: about the writing, not in it. "Take 1 is
better, but take 2's ending…" This block carries one; it renders in the margin with a
// prefix. Click it to open the block's comments panel, or press ⌘⇧' anywhere. The
comments button sits in the bottom bar in Write and Takes alike.

Comments survive the knife: divide or merge a commented block and the note rides onto
the successors. Deleted comments stay visible in the panel and can be brought back. The
feature is deliberately never skimpy.

Tags organize notes (and blocks) without moving them: hierarchical paths like
life/goals/2024. A note wears them as little coloured cards on its masthead's right
edge. Click the ＃ beside them and a tag field opens with the cursor in it (type a
name; "/" nests, and a name that doesn't exist yet is made; ⏎ applies it), ✕ on a card
takes one off, and ⌘⇧I opens the same field from anywhere in the note. Every tag keeps
its own colour everywhere. The tag manager lives in Settings (⌘,), where Make a
Gathering… turns a tag into a gathering that shows everything wearing it.

Full disclosure: every lesson note wears the "tutorial" tag. That is exactly how Help ▸
Restore Tutorial… finds what to replace. Your own notes never wear it unless you put it
there; everything else in your library is invisible to the restore.

### Staged content

- The staged comment: "a comment lives in the margin: about the block, never inside
  its text" (em dash → colon)

### Change log

- COMMENT, BLOCK, TAGS caps → plain prose; em dashes out.
- The disclosure paragraph kept whole (it is the restore door's honesty, Stage 2's
  rule).
- All doors kept (the margin strip, ⌘⇧', the bars' comments button, the ＃ field,
  ⌘⇧I, Make a Gathering…).

---

## Lesson: search (joined from VX-83's merge; title is the seeder's `searchLessonTitle`)

### Final text

The search field at the top of the Library is the one place to look for anything you
wrote. Type words and it searches the text itself: the body of every note (every take,
not only the one showing), and titles, snippets, comments, block names and take labels.
Capitals and accents don't matter: "cafe" finds "Café".

Words answer as a sheet. A band under the field counts what was found (books, notes,
passages), and its chips say what is narrowing the search, starting with the wing
you're in ("in: Home"): search looks inside one wing, though snippets are found from
every wing. Books whose names match come first; then each note that matches, best
match first, with up to three of its matching lines and the words highlighted.
"all N ›" on a note opens the rest of its lines.

Click a line and you land in the note: in Write, at that block, the match selected and
the find bar already holding your words. ⌘G steps to the next match, ⇧⌘G back. A line
marked "in another take" matched a take that isn't showing. You land at its block with
the find bar ready, and nothing is selected, because those words aren't on the page.

A tag typed alone narrows the Library to the notes wearing it. Type #tutorial and the
Library shows this guide's notes (every lesson wears that tag) as its own rows, in the
order its sort ▾ says, with any books the tag flows into listed on top. A tag covers
the tags under it: #life finds a note tagged life/goals too. Put words beside a tag and
it narrows the search instead: #tutorial rain looks for rain in these lessons only
(the choosing lesson's rain takes answer). And when a word you type is the name of a
tag, the band offers it ("tag: #name ›"), and one click searches the tag.

when ▾, beside the sort, narrows the Library to a day. It opens a small calendar with
two choices above it. "on a day": click a day. "between days": click the first day,
then the last, and the run between them fills in. The sentence under the calendar
always says what is showing ("Showing notes edited on Oct 6.") and that sentence is the
confirmation: nothing changes until you click a day, and Esc or a click outside keeps
exactly what it says. "any day" clears it, and so does the ✕ on the day's chip in the
band. One honest limit: a note keeps one edit stamp, so a note edited on two days
answers for the later one. The earlier day finds it where a commit landed.

Archived notes stay out of the way: search leaves them out until you press
"+ archived" in the band, and that chip's ✕ leaves them out again. What you saved is
searchable the same way: "+ commits" brings in the words your commits kept, each such
line marked "commit" with the day it was saved. Inside a book, the 🔍 at the right of
the book's masthead searches that book alone: the same kind of answer, scoped to the
book. And ⌘K finds passages too: under the notes and books whose names match, a few
matching lines, and "All matches in the Library ›" to open the whole answer.

Try it: open the Library and type marginalia. This paragraph answers. Click its line
and you land right here, in Write, with the word selected and the find bar holding it.
Press ⌘G and the selection steps to the next marginalia. Then try #tutorial on its own,
and watch the Library become this guide.

### Change log

- Seat: after "comments & tags" (the tags it leans on), honoring P-VX83-B2; this
  pass's proposed order moves the whole chapter to seat 8 and leaves the lesson's seat
  inside it untouched.
- Voice pass only: em dashes out of the lesson's own prose; TEXT, IN, A TAG caps →
  plain prose. Every quoted door string, chip, and glyph is EXACTLY the seeder's
  spelling ("in: Home", "all N ›", "in another take", "tag: #name ›", when ▾, sort ▾,
  "on a day", "between days", "Showing notes edited on Oct 6.", "any day", ✕,
  "+ archived", "+ commits", "commit", 🔍, ⌘K, ⌘G, ⇧⌘G, "All matches in the Library
  ›") — constraint (3) from the search session, honored.
- **PINNED PRACTICE WORDS KEPT (constraint (1), verbatim):** "marginalia" appears
  exactly twice in the practice paragraph and nowhere else in the guide's drafts, so
  it answers with this lesson alone and ⌘G has a second landing; "#tutorial" alone
  stays the second act (the tag-alone listing pages the whole plan). The practice
  paragraph's flow is near-verbatim; only one em dash became a period
  ("This paragraph answers. Click its line…"). `theSearchLessonsPracticeHoldsOnTheGuideItself`
  re-pins to the re-voiced sentence at the port.
- **THE COMMITS FACET SENTENCE KEPT (constraint (2), R-VX83-10):** "+ commits" and
  the line wording "commit" with its day stand exactly; this aligns with our
  R-13s-31 sweep, her rationale on the record ("I like commits because I don't want
  people to think savepoint is for the whole note or something").
- R-13s-31 in the when ▾ paragraph: "the earlier day finds it where a savepoint
  landed" → "where a commit landed" (the one label the VX-83 text still carried;
  same fact, the chip's own word — the landing's cold review should confirm the
  TutorialCurrencyTests cell that scans this sentence, if any, moves with it).
- The lesson title stays the interpolated `searchLessonTitle` constant; the three
  search pins (`theSearchLessonFollowsTheTagsItLeansOn`,
  `theSearchLessonNamesEveryFinderDoorByItsOwnWord`,
  `theSearchLessonsPracticeHoldsOnTheGuideItself`) re-pin to the re-voiced prose at
  the port, per the landing brief's standing rule.
- **Landing flag:** this lesson's ground truth lives on MAIN (merged by VX-83) and not
  yet on this branch — the port happens after the orchestrator's next main merge, and
  the porter should diff this draft against the then-current seeder in case the
  VX-83 ladder's tail touched the strings.

---

## Lesson: pool & scraps

### Final text

Not everything starts as a note. The Pool (sidebar) holds notes that belong to no book
yet: drafts in waiting. Snippets (sidebar) holds exactly that: loose blocks that aren't
notes at all. Overheard lines, stray sentences, one-liners you'll want later.

A group named "tutorial scraps" was seeded for you with two snippets. The Snippets
area's groups column switches between groups, and "all snippets" at its top shows every
one at once. To drag a snippet into a note: open any lesson in Write (⌘1) and press the
Scraps button in the note's top-right corner (beside References). They sit beside the
page. Drag one in, and it lands as a copy with lineage back to the snippet, which stays
in its group. Hold ⌥ while dragging and the whole fan rides the copy, takes and all
(the second snippet has two, to try exactly that).

The Snippets area's own dashed box mints them: start typing in it, press ⏎, and the
line is kept as a standalone snippet. Drag pieces out as your drafts want them. Copy
out is the only direction, so the snippets never tangle with your notes.

Each snippet is its own item and can wear tags: right-click a snippet row (here, or in
the side panel) and Tags… opens its tag sheet. Worth keeping straight: a group is a
container (a snippet lives in exactly one; Move to Group moves it), while a tag is a
label (a snippet can wear many, and filtering by tag never moves anything).

### Staged content (unchanged mechanics)

- The seeded group "tutorial scraps" keeps its reserved name (a restore-door identity;
  the 13u4 UNIT S3 record's rule) and its two snippets: "a scrap: the harbor bell rang
  twice for no ship anyone could see." and the fanned "a scrap with two takes — ⌥-drag
  me and both come along." / "the second take of the scrap — riding along on an
  ⌥-drag." **Left as seeded:** these are snippet texts, not guide prose; their dashes
  ride (same disposition as sample prose; the ⌥-drag act depends on the fanned one).

### Change log

- POOL/SNIPPETS/COPY/TAGS/GROUP caps → real casing and plain prose; em dashes out of
  the lesson's own sentences.
- The chapter title's noun set (Snippets speaks groups; the bookless-notes Pool keeps
  its name) untouched, per the S3 vocabulary record.
- Both acts kept (the drag-in with ⌥ fan ride; the dashed-box mint).

---

## Lesson: export — it's all yours

### Final text

Your work is always yours to take out. Any note exports as Markdown or PDF from the
library's right-click Export menu; a block exports alone via File ▸ Export Block as
Markdown…; a book exports as one document, its chapters as headings, this very book
included, from its row's right-click on the Bookcase; and File ▸ Export Library… writes
the whole library as a folder of Markdown in one gesture.

Exports are honest projections: the chosen take in place, and Markdown with Takes… adds
a labeled Alternates section for every fanned block, so nothing you kept open is lost
on paper. Try it on the choosing lesson; its four rain takes all reach the page.

Backups happen on their own. Once a day while Variorum is open, it copies your whole
library into a backups folder right beside the library, on this Mac. No button, nothing
to remember. Those copies survive a mistake; they don't survive losing the Mac.

So you can add a second folder of your own choosing (iCloud Drive, an external drive,
any folder your cloud service syncs) and every backup lands there too: Settings ▸
\(SettingsPane.dataSafety.title), under "\(DataSafetyCopy.secondFolderSection)", its
\(CapabilityRegistry.capability(.chooseBackupFolder).verb) button. If you haven't
picked one, Variorum offers it a few days into your writing, with a quiet note at the
bottom of the window: "\(ProtectionCopy.iCloudOfferTitle)"

### Change log

- BACKUPS caps → plain prose; em dashes out; the backup paragraphs keep R-13r-14's
  facts and every interpolated surface name (\(SettingsPane.dataSafety.title),
  \(DataSafetyCopy.secondFolderSection), the registry verb,
  \(ProtectionCopy.iCloudOfferTitle)).
- Flagged (overview item 2): the TITLE "export — it's all yours" carries the guide's
  one em-dash title; proposed rename "export: it's all yours" (plan array, phone twin
  and pins ripple; hers to decline — the draft keeps the current title).
- The try-it export act kept.

---

## Lesson: the seal

### Final text

This note is sealed: marked complete. Everything under a sealed note refuses to change.
Typing, new takes, commits, divides, all of it, until you unseal.

Try to break it. Press ⌘S to commit, or ⌘⇧D to divide. Each attempt is answered out
loud at the bottom of the window: the app tells you the note is sealed rather than
doing nothing. Typing simply finds the text read-only. A door that can't act tells you
why, never nothing.

The seal is reversible and gentle: the unseal door sits in the bottom bar's note ▾
group. Unseal this note, change a word, seal it again (same place). Sealing quietly
commits any unsaved takes first. The guard insures exactly what it protects.

### Change log

- SEALED, OUT LOUD caps → plain prose; em dashes out.
- The lesson stays seeded sealed (`lockPost`); the try-to-break act and the
  unseal/reseal act kept exactly.
- Already commit-vocabulary; nothing to sweep.

---

## Departed lesson: three ways of working

Moved to the welcome chapter under the proposed reorder; its draft, staged take and
both-seat wording live in `chapter-01-welcome.md`. Nothing else in this chapter leans
on it.
