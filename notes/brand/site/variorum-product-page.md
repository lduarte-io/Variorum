# Website product page — draft

Drafted 2026-10-04 for stargazing.tech: the full "what is Variorum" reference
page — the one curious visitors land on, distinct from the launch blog post.
Written as final page copy below the line; `[brackets]` are hers to fill or
confirm. Facts are checked against canon as of today; the two items marked
PENDING (search scope, mobile) should be re-checked at publish time. The page
is long by design — it's the reference — but every section stands alone, so
cutting sections is safe; reordering within sections isn't always (they build).

---

# Variorum

**A writing app that keeps every version of a paragraph.**

A *variorum* is an edition of a text that preserves its variant readings — the
scholars' format for showing every version a line ever had, beside the one
that prevailed. This is that, for your own drafts, while they're still alive.

Variorum is a native Mac app for journaling, blogging, and book-length work —
one app, one store, three very different kinds of writing. It's built on a
single conviction: a draft is a braid of open decisions, and your tools
shouldn't force those decisions closed before their time.

`[Download / waitlist CTA · current version · macOS requirement]`

---

## Contents

1. [The heart of it: blocks and takes](#takes)
2. [Savepoints: a history for every take](#savepoints)
3. [Nothing is ever destroyed](#safety)
4. [Shaping text: split and merge](#shaping)
5. [Seven ways to see one note](#modes)
6. [Books, gatherings, and the bookcase](#books)
7. [The daily journal](#journal)
8. [Tags, sorting, and finding things](#organization)
9. [Snippets and references](#snippets)
10. [Fast, as a law](#speed)
11. [Private, honestly](#privacy)
12. [Make it yours](#themes)
13. [Variorum on iPhone](#mobile)
14. [The philosophy](#philosophy)
15. [Questions you might have](#faq)

---

<a name="takes"></a>
## 1. The heart of it: blocks and takes

Most writing apps treat a document as one long string of text. Variorum
treats it as a sequence of **blocks** — usually paragraphs — and every block
has permanent identity. That one decision is where everything else comes from.

Because a block is a real thing and not just a stretch of characters, it can
hold **takes**: parallel versions of itself. Rewrite a paragraph and the old
version doesn't die — it stays, as a take, side by side with the new one. Want
to try the paragraph angrier? Shorter? Restructured from scratch? Fan out as
many takes as you like.

- **Takes sit side by side, open** — not buried in a version-history drawer.
  Compare them on the page, in context.
- **Click a take and the page re-reads itself** with that version in place,
  while everything around it holds still.
- **Choose whenever you're ready.** Next week is fine. The unchosen takes stay
  exactly where you left them, for as long as you want.
- **Branch or start blank.** A new take can inherit the current text (the
  everyday gesture) or start empty (a genuinely fresh attempt).
- **Label takes** ("the funny one," "editor's cut") and **lock** any take to
  freeze it against stray edits — locking is a guard, always reversible.

Takes are deliberate, not ambient: most paragraphs live their whole lives with
exactly one. The machinery appears when you summon it and folds away when
you're done. At rest, a Variorum note looks like seamless, minimalist prose.

<a name="savepoints"></a>
## 2. Savepoints: a history for every take

Variorum autosaves continuously, like everything should. On top of that, each
take carries its own **savepoint history** — deliberate, named moments you pin
on purpose.

- Hit the savepoint shortcut when a paragraph is good. Keep rewriting,
  fearlessly. Restore any savepoint whenever — restoring never erases the
  savepoints after it, because the history only ever grows.
- Savepoints can be **named** ("before I cut the ending"), and renamed later.
- **Quiet automatic savepoints** cover the moments you'd regret most: closing
  a note with unsaved changes, a long idle stretch mid-edit, and right before
  any operation that would overwrite text you couldn't otherwise get back.
  You don't have to remember to be careful; the app is careful for you.
- The savepoint cadence is adjustable — but the insurance moments are always
  on, in every mode.

Beyond per-take savepoints, you can save a **version of a whole note** — a
complete snapshot of every block and take, restorable later — before a big
restructuring, or just at the end of a good day.

<a name="safety"></a>
## 3. Nothing is ever destroyed

The deepest rule in Variorum: **mutation never reaches anything you've decided
to keep.** Only one thing in the entire system is ever mutable — the text of
the take you're currently typing in. Everything else is append-only.

- **Delete a block** and it parks in the note's **tray**. One click puts it
  back — in its exact slot.
- **Deleted notes and books** go to the Trash and come back whole: blocks,
  takes, history, chapter structure, tags.
- **Structural undo and redo** exist alongside ordinary text undo, as a
  separate stack: splitting, merging, moving, and deleting blocks are all
  undoable as operations, and undoing them restores the exact original rows —
  not reconstructions.
- **Sealing a note** marks it complete and refuses every edit under it —
  reversibly. Un-seal and keep going. Locks are guards, never snapshots.
- When history and safety collide, safety wins quietly: any action about to
  overwrite text you edited takes a savepoint first, automatically.

This is also why Variorum is deliberately **coarse, not forensic**. It
preserves choices and lineage — which versions existed, what descended from
what — and not a keystroke-by-keystroke surveillance log. A family tree, not a
court record. Tools that record everything become archives you're afraid to
touch; tools that record decisions stay light enough to live in.

<a name="shaping"></a>
## 4. Shaping text: split and merge

Blocks are born as you type — new text crystallizes into blocks paragraph by
paragraph, and pasted or imported text is segmented on arrival (one block per
paragraph by default; journals default to one block per entry; it's
adjustable per note). After that, blocks change shape only when you say so:

- **Extract** — chop a sentence off a paragraph's edge into its own block,
  painlessly. The source survives untouched. This is how you give one
  sentence its own fan of takes.
- **Divide** — cut a block in two at any point. The everyday case is a
  trivial in-place cut. When a block carries multiple takes, you decide what
  happens to them: keep them on the top half, the bottom half, copy them to
  both — or open **Divide choosing takes…**, the full ceremony, and place the
  cut inside each take yourself (so the first half of attempt one can pair
  with the second half of attempt three). The original block is preserved
  whole in the background; dividing is reversible, and nobody's five drafts
  disappear.
- **Merge** — combine adjacent blocks into a fresh one, with lineage edges
  back to both. The page reads byte-identical before and after. When the
  sides carry takes, **Merge choosing takes…** lets you pair them by hand —
  pair 1 with 1 and 2 with 2, and a divided block comes back exactly. Takes
  are never multiplied combinatorially; pairing is choosing, not exploding.
- **Move a span to a new take** — select a passage and lift it out of the
  take, into a fresh take on the same block, with the remainder staying put.
- Cuts snap gently to word edges, sentence ends, and line breaks — one rule
  everywhere, so the gesture always lands where your eye expects.

Every one of these is a pointer move under the hood, which is why every one
of them is fast, and why every one of them can be undone.

<a name="modes"></a>
## 5. Seven ways to see one note

A note in Variorum is one store of blocks — and seven surfaces over it, each a
keystroke away. Many views over one text is the point: different work wants
different rooms.

- **Write** — the plain drafting surface. Just prose.
- **Takes** — the fan room: single-column focus on one block's takes, tinted
  cards, the chosen one marked, one live editor at a time.
- **Read** — two faces: an editable index with a block outline down the
  margin, and a calm, book-like page (continuous or paged) with none of the
  machinery — where clicking any sentence drops you back into editing at that
  exact spot.
- **Lenses** — side-by-side columns over the whole note, each column a
  different set of take choices: entire alternate readings of the same draft,
  held open together, editable in place.
- **Compare** — versions side by side, plus the outline view that maps a
  draft against what it derived from.
- **Blocks** — the power workbench: multi-select, bulk actions, a context
  panel with every detail of a block in one place.
- **Canvas** — the same note as spatial cards you arrange freely: the
  sticky-notes-on-a-desk view, for when order isn't settled yet.

Across every surface, the same editor language holds: block boundaries are
invisible at rest (dotted seams on a toggle if you want them), comments and
callouts live in the margin so the prose column never jumps, and only the
block you're editing is "live" — which is why everything stays calm and
everything stays fast.

<a name="books"></a>
## 6. Books, gatherings, and the bookcase

Notes don't live in folders. They live in your library, and **books point at
them.**

- A **book** is an ordered collection of notes with real, reorderable
  **chapters**. Because a book points at notes rather than containing them,
  one note can live in several books at once — your best essay can sit in
  the collection *and* the retrospective without being copied.
- A **gathering** is a saved rule — "everything tagged `essays/2026`,"
  "everything starred" — that assembles itself at read time. Shape one by
  hand and it becomes a book that *keeps collecting*: new matches arrive and
  wait politely for your decision instead of barging into your order.
- An **owned book** is the opt-in exception for projects that want real
  ownership — a novel whose chapters shouldn't also be floating around
  elsewhere. Your call, per book.
- Books can be **finished** (declared done) and **sealed** (every word under
  them frozen — reversibly, like every lock in the app). Books you're not
  using can be **archived** — kept, out of view, restorable.
- Books have optional **word targets** and **fixed lengths** (a 100-entry
  journal) — always progress displays, never refusals. The app never tells
  you to stop writing.
- The **bookcase** is where books live, on **shelves** you arrange yourself.
  **Wings** are a level above: separate rooms in the same house — a wing for
  the journal and quick notes (**Home**, always there), a wing for work,
  a wing for the novel. Nothing crosses wings; each is its own quiet library.
- Every note that belongs to a book carries a collapsible **book panel** — the
  book's table of contents riding alongside, with drag-to-reorder and
  click-through — so stepping from a note up into its book is one gesture.

<a name="journal"></a>
## 7. The daily journal

Journaling is a first-class citizen, not a template. One shortcut opens
today's entry; entries file themselves into your daily Journal book, ordered
by day. Journal notes default to the simplest shape — one block per entry —
and there is **zero migration** between "journal entry" and "real note": an
entry that grows up into an essay just… is one. Same store, same powers,
takes and all. The journal restriction was only ever a default.

<a name="organization"></a>
## 8. Tags, sorting, and finding things

- **Hierarchical tags** — `life/goals/2026` — on notes, and cheaply on
  individual blocks. Tags drive gatherings, so organizing and collecting are
  the same act.
- **Capture microsyntax** — type `{#essays/drafts}` or `{t:"A title"}` while
  capturing and the tokens become the tag and the title, then disappear.
- **Sorting that respects your attention:** the library can sort by when
  something was *meaningfully* edited — a threshold of real change — so fixing
  one typo in an old piece never reshuffles your whole library. Noisy
  "last touched" sorting exists too, if you want it.
- **The library** shows everything, as a list or as cards, with sort controls
  and a by-day filter`[; date-range filtering — confirm shipped at publish]`.
- **Search** `[PENDING — re-check scope at publish; written to the settled
  design]`: full-text search across the whole library, scoped to one book or
  one note when you want it, with filters for tags, dates, and kinds of book.
  Search is client-side by design — it has to be, because the sync server
  can't read your writing (see Privacy) — and it runs over a real database,
  which is exactly where local search is fast.`[ If the takes/savepoints
  scope ships: Search also sees your takes and savepoints — the sentence you
  cut three weeks ago is findable.]`

<a name="snippets"></a>
## 9. Snippets and references

- **Snippets** is the holding area for scraps: loose sentences, fragments,
  ideas that don't have a home yet. Drag a snippet into a draft and it lands
  as a copy with lineage back to the original — the scrap survives, and the
  draft remembers where the piece came from. (Deliberately *not* shared
  ownership or transclusion: no spooky action between documents, ever.)
- **References** attach source material — PDFs, files, links — beside a note,
  as a reading pane next to your draft. PDFs remember your page. Text dragged
  out of a reference lands as an ordinary copy in your draft. Deliberately a
  *viewing aid*, not a knowledge base: no citation manager, no annotation
  database — your sources next to your writing, nothing more.
- **Export** is plain Markdown, including a fan export that writes a block's
  alternate takes as readable "Alternates" sections — your variants survive
  outside the app, in a format anything can open.

<a name="speed"></a>
## 10. Fast, as a law

Variorum has a performance constitution, and its first article is: **no
operation's cost may scale with the size of the document or the library —
only with what's on screen and what's being edited.**

That isn't an optimization; it's an architectural rule that everything is
built under. The editor lays out only the viewport. Unfocused paragraphs are
lightweight rendered text; exactly one paragraph at a time is a live editor.
Every keystroke writes one tiny record, never the whole document.

The consequence you feel: typing in a 50,000-word manuscript feels the same as
typing in an empty note, and keystroke latency stays flat as your library
grows. The app where a long document gradually becomes unusable — you know
the one — is the failure mode this architecture exists to make impossible.

It's native Swift on a real Mac text engine. No web wrapper, no Electron.

<a name="privacy"></a>
## 11. Private, honestly

Your writing lives in a single database file on your own Mac, **encrypted at
rest** — the whole store, always, not an optional checkbox.

- **The app lock is real.** When Variorum is locked, your words are actually
  encrypted on disk — not hidden behind a curtain with the door unlocked.
  (Many "lock this note" features in other apps are exactly that curtain.
  Variorum deliberately doesn't ship per-note locks, because they teach you
  to trust protection that isn't there. The store itself is the protection.)
- **Unlock your way:** automatically, by Touch ID, or by passphrase on every
  open — with a simple Standard / Locked-down choice and dials beneath it.
- **One secret, recoverable:** a passphrase plus a 12-word recovery phrase.
  Optional iCloud Keychain escrow if you want convenience; off if you don't.
- **Sync is end-to-end encrypted** — multi-device sync where every
  text-bearing field is sealed before it leaves your machine. The server
  stores ciphertext; it never sees your prose and couldn't index it if it
  wanted to.
- **Conflicts never eat words.** If two devices edit the same paragraph
  offline, the "losing" version isn't overwritten or auto-merged into word
  salad — it arrives as another take on the block, side by side, yours to
  judge. The conflict dialog is just… the fan.
- **You own the file.** Your whole collection is one encrypted database file.
  Back it up, or take it to a new Mac: Send Library to Another Mac packs it
  with its key file into one folder — AirDrop the folder and open it there,
  through your Apple account or with your passphrase. No export-import dance,
  no server in the loop, and in transit it's noise to anyone without your
  keys. `[publish with the first public release that carries 13x]`
- **The exit is always open:** plain-Markdown export of anything, anytime.
  `[open-format guarantee wording — hers; the release strategy wants this
  loud]`

<a name="themes"></a>
## 12. Make it yours

Two designed **voices** — Terminal and Study — each a complete typographic
personality, in light and in dark, where dark is a genuinely black room, not
gray. Under the voice, a **colour palette**: sixteen presets or your own hex,
recoloring the room, the washes, and the take tints in one move. Follow the
system's appearance or pin light/dark. Seams, editing indicators, and status
receipts are each adjustable from invisible to present. Every font is a
system font; every surface honors the same rule — calm by default, visible
machinery only on request.

<a name="mobile"></a>
## 13. Variorum on iPhone `[PENDING — status wording at publish]`

A real companion app, in progress — not a viewer. Capture on the go, write
today's journal entry, edit anything, work with takes — against the same
store, over the same end-to-end-encrypted sync. The phone is a smaller room,
not a lobotomized one.

<a name="philosophy"></a>
## 14. The philosophy

Three rules run all the way down, and knowing them explains most of the app:

1. **Nothing owns text; everything points at it.** Documents are ordered
   pointers to blocks; books are pointers to notes. That's why one note can
   live in many books, why reorganizing is instant, and why every structural
   act is reversible.
2. **Mutation is ephemeral; permanence is append-only.** The only mutable
   text in the system is the take you're typing in. History can't be
   overwritten because no operation overwrites it.
3. **Coarse, not forensic.** Variorum keeps your choices and their lineage —
   a family tree of your drafts — and refuses, on principle, to be a
   keystroke surveillance log.

<a name="faq"></a>
## 15. Questions you might have

**Is this a knowledge base / second brain?**
No — deliberately. No transclusion, no blocks shared between documents, no
graph of everything. Reuse is copy-plus-lineage: the draft remembers where a
piece came from, and the piece belongs to one home. It's a writing tool.

**Is it collaborative?**
Today it syncs *your* writing between *your* devices. Collaboration is
eventually on the map — in Variorum's shape: a piece shared between two
libraries, syncing on sync's own clock, where simultaneous edits never
collide because versions simply become takes. Real-time co-typing in one
document is out of scope on purpose, and the shared-piece future is further
out — end-to-end encryption makes it genuinely hard, and it's worth doing
right.

**Does it track my edits?**
It keeps what you choose to keep: takes, savepoints, lineage. It does not
record keystrokes or reconstruct every change. Coarse, not forensic.

**What's the file format?**
A single SQLite database (encrypted), local to your Mac — a file you can back
up, or send to a new Mac as one folder with its key file and open there.
Markdown export for everything, anytime. `[open-format guarantee line]`
`[publish with the first public release that carries 13x]`

**What does it cost?**
*[removed for publication]*
*[removed for publication]*

**Why "Variorum"?**
Because the dictionary wrote the pitch: *an edition of a text that preserves
its variant readings.* It's how we've always treated writing we love. Your
drafts deserve it while they're still alive.

`[Download / waitlist CTA repeated]`
