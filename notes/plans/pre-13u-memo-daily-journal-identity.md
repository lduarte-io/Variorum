# DESIGN MEMO — the daily Journal's first-class identity (and why it can never be hard-deleted)

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
  AND for her. The 30-day Trash window does not help: the purge is final and the bridge's
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
