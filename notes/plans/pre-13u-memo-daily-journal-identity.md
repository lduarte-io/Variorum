# DESIGN MEMO — the daily Journal's first-class identity (and why it can never be hard-deleted)

> **⚠️ RE-SCOPED BY THE AUTHOR, 2026-09-04 (at the Fragments bridge retirement's close — read §0 before the rest; §§1–7 below are the pre-retirement design, kept as history and as the sitting's starting material).**

## 0. AUTHOR RULING 2026-09-04 — "a 'journal book' is dead as a concept"

**Her words, verbatim (the bridge retirement session, 2026-09-04):** *"Can you add a note to whichever plan was
supposed to determine the shape of a Journal (I believe it's 13i-e) that the special shape of a journal book as
a fragments bridge is unneeded? also, journal books don't need to have anything at all against multiple day
entries at this point - I think we did allow the collision before but maybe it was discouraged in the UI somehow?
not sure, but at this point a 'journal book' is dead as a concept - it would only be a book auto stamped with its
date when an entry is created, like any other book."*

**What this rules (recorded, not re-derived):**
1. **The bridge-shaped identity need is GONE.** The Fragments bridge was retired 2026-09-04 (pre-13x batch 0b;
   tag `archive/fragments-bridge-2026-09-04`; `notes/archive/fragments-bridge.md`). This memo's §2 problem
   statement, §3 "the ONE book the bridge shelves into", §4's hard-delete guard ("there's no bridge with
   fragments and that's unfortunate"), and every bridge-motivated edge in §5 lose their reason. Whatever
   identity the daily Journal keeps is on her ordinary-book grounds alone.
2. **No guard against multiple entries on one day.** "journal books don't need to have anything at all against
   multiple day entries at this point."
3. **The concept is dead:** a "journal book" is only *"a book auto stamped with its date when an entry is
   created, like any other book"* — an ordinary book whose entries get their `entry_date` stamped at creation.

**What the code does TODAY (facts for the sitting, checked 2026-09-04 — this answers her "not sure"):** the
STORE never forbade two entries on one day (no uniqueness on `container.entry_date`); the collision was
discouraged at the DOORS by the Phase 8 "notebook rule" (author, 2026-07-07): Today's Entry (⌘J) and a book's
"+ new entry" for a date both go through `createOrOpenJournalEntry`, which looks the day up
(`Queries.canonicalJournalEntry`) and OPENS the existing entry rather than minting a second (an archived one
included, when it is all the day has); the book's day page reads the same canonical lookup; and the retired
bridge PAUSED its push on a duplicate day. So: allowed in the store, steered away at the doors — exactly her
recollection. `profile='journal'` on a note still means "sort by `entry_date`" in the journal lens and the
phone's journal list; `reading.profile='journal'` + `entry_date` ascending is the daily book's mint shape (the
SyncSpec §7 keeper repair keys on it); `setting.daily_journal_book` is the ⌘J designation.

**What the 13i-e sitting now owns (listed, NOT decided here — each is hers):**
- (a) Whether `createOrOpenJournalEntry`'s create-OR-open stays as ⌘J's convenience ("open today's entry")
  or ⌘J becomes plain "new entry, date-stamped" — her ruling says nothing is needed AGAINST a collision; it does
  not say the convenience must go.
- (b) Whether `profile='journal'` survives as anything more than "date-stamp at creation + sort by date"
  (the journal lens, the phone's journal list, the tutorial's books chapter line), or folds into an ordinary
  book with a per-book "stamp entries with their date" trait.
- (c) The daily-book DESIGNATION (`setting.daily_journal_book`, ⌘J's target, the phone's capture target): keep
  as "the book ⌘J files into", derive it, or drop ⌘J's filing and let the entry land where any new note lands.
- (d) The SyncSpec §7 keeper repair (two devices minting the daily mint-shape offline): with no bridge and no
  special identity, whether the repair stays as the mint-shape dedupe it is, or retires with the concept.
- (e) The hard-delete guard (§4): DISSOLVED as a bridge argument (C7 re-base, QUESTIONS #89); whether any
  never-hard-delete rule remains for the daily book on identity grounds alone is this sitting's call, per #89.
- (f) The phone (`MobileStarterJournal`, the capture door) and the tutorial's journal lesson — the faces that
  follow whatever (a)–(c) rule.

**HER SECOND MESSAGE, same sitting (2026-09-04) — two of the six settled, verbatim:** *"We should remove the door
discouragement. I do think Today's Entry is nice as a button for mobile - so maybe a journal book is still special
only in that it's where Today's Entry and the shortcut takes you? I do like command J, so maybe it shouldn't be
retired."*
- **(a) RULED — the door discouragement goes.** `createOrOpenJournalEntry`'s create-OR-open (the Phase 8
  notebook rule) is retired: Today's Entry / ⌘J / a book's "+ new entry" for a date always MINT a new
  date-stamped entry; nothing at any door steers away from a second entry on one day. (`Queries.canonicalJournalEntry`
  and the book day page's single-entry reading follow — the sitting says how a day with two entries reads.)
- **(a′)/(c) HER LEAN, uncertainty preserved ("maybe"):** ⌘J STAYS ("I do like command J, so maybe it shouldn't be
  retired"), Today's Entry stays as a mobile button, and the journal book is special ONLY as the destination —
  *"where Today's Entry and the shortcut takes you"* — i.e. the designation survives in exactly that role and
  nothing else about the book is special. (b), (d), (e), (f) remain the sitting's, read in that light.
- **Owner of the build — RULED (her third message, 2026-09-04): 13i-e.** *"13i-e is the right place to handle the
  changes to the journal book"* — not a 17 entry; nothing built from this here.
- **(e) HER LEAN, same message, uncertainty kept:** *"if there's a command that opens it, it probably still
  shouldn't be deletable"* — the never-hard-delete guard PROBABLY survives on the new ground (⌘J opens it), no
  longer on the bridge's; the sitting confirms the wording.

*(Sections 1–7 below predate this ruling. Read them for the edges they enumerate, not for their conclusions.)*

**Provenance:** written 2026-08-31 at the pre-13u round's tail, at the author's instruction after
the final ladder's F6 finding exposed the gap. A P-5 design memo: the intended behavior whole,
the edges enumerated on paper, her rulings verbatim. **Owner: 13y** (the pre-release `Sync/`
phase — her word: "link it to 13y for now"); a `KnownIssuesAndTechDebt.md` row points here.
Nothing in this memo is built by the pre-13u round; the round's F6 fix (the narrowed
mint-signature predicate) is the SAFE INTERIM — it can no longer merge a deliberate second
notebook — and this memo is the real answer.

## 1. Her rulings (verbatim)

- *"i do agree it needs a first-class identity."*
- *"i also think we should stop people from hard deleting the journal - it can be moved to
  archived, but if they hard delete it there's no bridge with fragments and that's unfortunate
  for them and me, becuase you can't get that back in any way."*
- The scenario that surfaced it, hers: *"what if you just decided to download variorum mobile?
  and it mints a journal the first time you open it, then you log in to your account, but
  *surprise*, you don't see your journal there and it's not syncing with the fragments bridge
  correctly? … there's only one special journal that has a bridge with fragments in the whole
  app … renaming the phone one won't lead to a convergence, right?"*

## 2. The problem, precisely

"The daily Journal" — the ONE book ⌘J opens, the bridge shelves Fragments days into, and the
phone's first write mints — has **no identity of its own today**. It is inferred from a profile
string (`reading.profile = 'journal'`, which deliberate second notebooks ALSO wear — the shelf's
"Create Journal Book" door, §14 item 10) and a name (`Journal`, which the author may rename), and
its designation lives in a synced `setting` (`daily_journal_book`) resolved by **last-writer-wins
CAS**. Consequences: (a) two daily books minted offline could only be recognized by name+profile
(the F6 interim), so a RENAMED daily book never converges with a fresh phone mint — two books;
(b) with two books, the designation races: whichever device wrote last decides which book the
bridge shelves into — her "surprise"; (c) the identity is reconstructible by no repair, because
nothing on the row says "this one".

## 3. The design — identity ON THE ROW, designation DERIVED

**One rule: the daily Journal is a distinguished KIND of book, marked on its own row.**

- **`reading.profile = 'daily'`** for THE daily Journal (zero schema — `reading.profile` is free
  text; the documented values 'journal' | 'book' | 'collection' gain 'daily'). Every other
  journal-style notebook keeps `'journal'`. The daily mint (`shelveInDailyJournalBook`'s ensure —
  the ONE door since #37(iii), the phone's first-write mint routed through it at ladder R1/F9)
  writes `'daily'`; "Create Journal Book" writes `'journal'`.
- **The designation becomes DERIVED:** "the daily book" = the live reading with `profile='daily'`
  (`Queries.dailyJournalBook`). The `daily_journal_book` setting is RETIRED as truth — kept only
  as a cache the ensure rewrites, or dropped; either way no CAS race decides identity.
- **Convergence keys on the marker, never the name** (E13 preserved — names are never keys): two
  `'daily'` readings meeting via sync converge by the existing keeper repair (smaller id keeps;
  memberships and chapters re-pointed BEFORE any tombstone applies — ladder R1/F1's arrival-order
  independence; the loser tombstoned; outbox rows explicit). Renaming the daily book on any
  device changes nothing about convergence. A deliberate `'journal'` notebook can never be
  merged, by construction.
- **The bridge and ⌘J** read `Queries.dailyJournalBook`; the bridge's shelving target is
  therefore deterministic across the account, and the phone-first-then-sign-in path ends with
  ONE daily book holding both devices' entries.

## 4. The hard-delete guard (her ruling)

- **`deleteReading` REFUSES the daily book** with a typed refusal (`dailyJournalCannotBeDeleted`)
  spoken by every door (the Trash road, the shelf's context menu, ⌘⌫, the phone's swipe) — the
  registry declares the capability unavailable for the `'daily'` reading so no door renders a
  delete that would only refuse (P-2: fire-and-DO or don't render).
- **Archive stays open** (`container.archived_at`-style — the reading's own archive door): an
  archived daily Journal keeps its identity, its entries, and its bridge target; the ensure
  UN-ARCHIVES it on the next daily mint rather than minting a second one ("the Journal is where
  your days go; it came back because a day arrived").
- **Why refusal and not the Trash:** her words — the bridge with Fragments is the one relationship
  in the app that cannot be rebuilt from the store; a purged daily book severs it for the user
  AND for her. *(Rationale re-based 2026-09-04: the bridge is RETIRED — pre-13x batch 0b, tag
  `archive/fragments-bridge-2026-09-04`; whether the daily Journal stays never-hard-deletable on identity
  grounds alone is 13i-e's sitting call — PROVISIONAL, QUESTIONS #89.)* The 30-day Trash window does not help: the purge is final and the bridge's
  day-keyed landing would then mint into a NEW book with a different id, orphaning the mirror's
  history. Entries inside the Journal remain individually deletable (a day is a note; the Trash
  road holds).

## 5. Edges, enumerated (decided on paper, not discovered by her)

1. **Existing stores:** a one-time ensure at the first launch of the build — the CURRENTLY
   designated live book gets `profile='daily'` through an ordinary operation (`setReadingProfile`
   or the ensure's own write; synced like any metadata; server-version-wins is safe because every
   device runs the same ensure against the same designated id). A store with NO designation and
   several 'journal' books: mark none; the next ⌘J/bridge/first-write mints the daily book fresh
   (today's behavior).
2. **Two devices both first-writing offline:** two `'daily'` readings → the keeper repair
   converges them (§3). The renamed corner DISSOLVES (F6's #85(a) amendment is superseded by this
   memo when built).
3. **A user who deliberately wants a second daily-style notebook:** creates a `'journal'` book —
   never converged, never bridged. The tutorial's books chapter says which is which in one line.
4. **Wings (13i):** ONE daily Journal per ACCOUNT, living in the Home wing (13i's ruling: Home is
   undeletable and holds the daily Journal). If 13i ever rules per-wing journals, `'daily'` is
   per-wing by adding the wing to the predicate — not this memo's call.
5. **Archive + a new day arriving:** the ensure un-archives (§4) — pin: archived daily book +
   ⌘J → the same book, live, with the new entry.
6. **Sync of the marker itself:** `profile` is plain metadata (server-version-wins); a device that
   has not yet run the ensure sees `'journal'` on the designated book until its pull lands the
   updated row — during that window its OWN ensure would mark the same id (idempotent). No
   lockstep event: the mirror carries `profile` already; no new column.
7. **The near-empty re-key corner is unrelated** — T1's guard (built at wave 2a) warns before a
   re-push; her open question whether the near-empty case should REFUSE is a separate one-line
   ruling, recorded in the pre-13u handoff's ratify list.
8. **Restore from Trash:** moot for the daily book (never in the Trash); `restoreReading` for
   other books is unchanged.

## 6. What 13y builds (the checklist)

- [ ] `profile='daily'` written by the one daily mint; `Queries.dailyJournalBook` (derived);
      the setting retired-as-truth; ⌘J, the bridge, and the phone's mint read the query.
- [ ] The keeper repair's predicate → `profile='daily'` (replacing the F6 interim's name leg);
      SyncSpec §7's paragraph amended; QUESTIONS #85(a)'s renamed corner closed.
- [ ] The one-time ensure for existing stores (edge 1), pinned on a store with a designated
      'journal' book + a second deliberate 'journal' book (exactly one becomes 'daily').
- [ ] `deleteReading` refuses the daily book (typed); the registry hides the door; archive +
      un-archive-on-next-mint pinned; every door's refusal copy (functional; 13s re-words).
- [ ] Mobile: the same query + refusal by construction (`Shared/`); the phone's swipe-delete
      hides for the daily book (a face).
- [ ] The tutorial's books chapter: one sentence on daily vs. other journals; re-seed.
- [ ] Red-on-old pins for every row above; convergence suites for edges 2/5/6.

## 7. Open for her (at 13y's kickoff)

- Should a `'journal'` notebook be PROMOTABLE to the daily book (a "make this my daily Journal"
  door that swaps the marker — the old daily becomes 'journal')? Cheap, and it answers "I started
  the wrong one."
- The near-empty re-key REFUSAL (edge 7) — warn (today, her ruling) or refuse.

**OWNER MOVED 2026-09-01 (the Act 10 correction round's sitting, R-cor-13): 13y → 13i-e** — the daily Journal's
first-class identity is now the fifth letter of the 13i split (`notes/plans/phase-13i-smart-book-identity-brief.md`'s
2026-09-02 addendum; the master plan's 13i row). The design here is unchanged.
