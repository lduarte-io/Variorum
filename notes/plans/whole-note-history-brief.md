# Whole-note version history — a design brief

**Status: a BRIEF, binding nothing.** Written as a Phase 13j deliverable
(batch 7) under the author's S4-16 deferral condition — *deferral moves work
in time, never into vagueness*. It exists so a future design sitting can start
from facts rather than from scratch: what the app can already derive, what a
real structure history would cost, and the knots that are hers to rule.

**Founding quote (hers, verbatim — the 13j sitting, round 1):**

> "what do you think the utility of a global lineage list is? what is the
> usecase here? i think it makes more sense per note if we do want to keep it
> (a lineage list and a deleted blocks list, but tbh that also seems quite
> confusing?). if a user has deleted a block completely, the idea that it
> deletes the previous version makes a certain amount of sense. **offering
> whole note version history (with all the blocks, etc.) seems like it makes a
> lot more sense than this lineage history**, but maybe i'm not seeing some
> potential use for it."

Her round-2 ruling on it: a future row plus this brief. (The lineage half of
the question was answered the same round — the global unplaced-blocks listing
was REMOVED, and lineage now lives per-note: the tray's Preserved originals
section and the successor block's own History face.)

---

## 1. What "version history" means here, and why the app doesn't have it yet

Variorum's history is **per take**, by construction. A `commit_point` row
belongs to one `variant`; a variant belongs to one block. So the app can
always answer *"what did THIS take say on Tuesday?"* and cannot, today,
answer *"what did this NOTE look like on Tuesday?"* — because a note is not a
thing that holds text. A note is an ordered list of pointers at blocks, each
pointer naming a chosen take (`container_block.position`,
`chosen_variant_id`). Its rendered text is a traversal, computed at read time.

That is the model working as designed (OverallModel §1: *every view is a
traversal of one graph*), and it is exactly why note-level history is a design
question rather than a query: **the note's past is not stored anywhere.**

What partially serves the want today:

- **Per-take History** (note ▾ ▸ History in Write; the same face on the Takes
  bar): savepoints for the take you are in, with Restore.
- **The block's past region** (13j batch 3): where the block came from
  (preserved originals) and the takes it has deleted, with Put back.
- **Lenses**: a saved set of *which take each block shows* — a stored,
  named, restorable **choice** snapshot (see §3, which is the load-bearing
  observation of this brief).
- **Versions**: `duplicateAsVersion` mints a whole second note, linked — a
  deliberate fork, not a timeline.
- **The Trash and the tray**: what was deleted, for 30 days.

What none of them answers: *"put this note back the way it was on Tuesday —
blocks, order, choices and text."*

---

## 2. What the J11 cadence now makes DERIVABLE (zero schema)

Phase 13j's savepoint cadence (her round-1 ruling, built in batch 5) changed
the arithmetic: **leaving a note now writes one quiet savepoint per take you
changed**, with a ~2 h idle backstop, governed by one setting. So the store
now accumulates, for free, a *time-stamped trail per take* at roughly
session grain — which was not true before (the only automatic occasion was a
24 h idle timer, which is why her history looked thin).

That makes a **session-grain TEXT browser** derivable with no schema at all:

- group every savepoint under the note's current blocks by time bucket
  (a sitting = a run of savepoints written within one leaving);
- render each bucket as a read-only page: for each block the app shows today,
  the text of its chosen take *as of that moment*;
- offer, per block, the existing per-take Restore — the doors already exist.

**Its honest limits, and they are the whole reason §4 exists.** A derived
browser can only speak about blocks that are in the note NOW and takes that
still exist. It cannot show:

- a block that was **deleted since** (its text is reachable in the tray/Trash
  for 30 days, but not in its place in the page);
- a block that was **added since** (it correctly shows nothing — but "nothing"
  and "this paragraph did not exist yet" look identical);
- the note's **order** at that time (a reorder leaves no trace);
- **which take was chosen** at that time (choosing writes no history);
- structural acts (divide/merge/extract) — the successors' savepoints exist,
  but the shape they replaced does not.

So the derived browser is *"what these paragraphs said then"*, never *"what
this note was then"*. It is genuinely useful and it is genuinely not the
thing her question asked for. Whether that is enough is a taste call — hers.

**Cost:** small. One query grouping `commit_point` rows for the note's blocks
by `created_at`, one read-only face, no new rows, no sync surface, no §12
event. Bounded by the note's own history (P1-safe if the face is opened
deliberately, like the tray — never held while typing, because it reads
`variant`/`commit_point`, the tables autosave writes).

---

## 3. The load-bearing observation: a lens is already half a snapshot

`lens` + `lens_choice` (Phase 11a) store, per note, **which take each block
shows** — named, restorable, and already synced. A note snapshot is exactly
that, plus two more facts:

| A note's state at a moment | Stored today? |
|---|---|
| which blocks are in it | no (only the CURRENT placements) |
| in what order | no (positions are current-only) |
| which take each shows | **yes — that is a lens** |
| what each take said | **yes — savepoints, at J11's cadence** |

So the missing half is **placement**: a stored, ordered list of block ids per
snapshot. That is what makes §4 a schema question rather than a face.

It also suggests the cheapest honest shape: **a snapshot is a lens with an
order** — the same pointer religion, one column-family wider. Any design that
copies TEXT into a snapshot is wrong by construction (denormalization; the
pointer religion; and it breaks the "one mutable text" rule that makes sync
tractable).

---

## 4. What a TRUE structure history would take

**Shape (sketch, not a proposal):** pointer-shaped snapshot rows.

```sql
-- one row per captured moment
note_snapshot(id, owner_id, container_id, taken_at, label, kind,
              created_at, updated_at, deleted_at, sync_version)
-- one row per block IN that moment, in order
note_snapshot_entry(id, owner_id, snapshot_id, block_id, variant_id,
                    position, created_at, deleted_at, sync_version)
```

Everything about it is ids, positions and stamps — **no user words**, so it
would travel PLAIN under E2EE and add nothing to the disclosure envelope
(the `purge_intent` precedent, 13j batch 6b).

**What it would cost, honestly:**

- **Rows ∝ blocks × snapshots.** A 60-block note snapshotted every sitting
  for a year is ~20k entry rows for one note. That is not fatal, but it is
  the number that decides the capture cadence and the pruning rule — and it
  is the reason "snapshot every session automatically" is not obviously
  right.
- **A §12 lockstep event** (mirror first, then every client, then the first
  write; marker 7 → 8 as things stand after 13j's purge deploy). Two new
  synced tables, born multi-tenant on the 14c pattern.
- **Purge interplay, which is the subtle one.** 13j's purge is
  family-complete and horizon-fenced: when a block's family is really deleted,
  its rows go. A snapshot entry naming a purged block must NOT resurrect it
  and must not dangle into a crash — so either snapshot entries join the
  family (the block's purge takes its snapshot rows with it, and old
  snapshots quietly lose paragraphs), or a snapshot PINS its blocks against
  purge (which would defeat "really deleted" — her whole J1 ask). **This is
  a ruling, not an implementation detail**, and it is the same shape as her
  round-8b preserved-originals question: what wins, permanence or deletion?
  The 13j answer there was deletion, visibly announced.
- **Pruning**, on the road her round-9 ruling already established for
  savepoints (Standard: older than 90 days keep the newest N; Never). A
  snapshot family would want the same setting rather than a second one.
- **Restore semantics** — the real design work (§5's knot 3).

**What it would buy:** the actual answer to her question — "put this note
back the way it was", including a paragraph she deleted three sittings ago,
in its place, with the take she had chosen then.

---

## 5. The knots — the calls that are hers

1. **Text history or structure history?** The derived browser (§2) is
   nearly free and answers *"what did these paragraphs say"*. The stored
   snapshot (§4) answers *"what was this note"* and costs a schema event,
   rows-per-block-per-snapshot, and a purge ruling. A middle road exists:
   ship the derived browser first, and let its own limits tell her whether
   the stored one is wanted.

2. **When is a snapshot taken?** Candidates: every leaving (the J11 cadence —
   most complete, most rows); once a day per note (cheap, coarse); on
   structural acts only (divide/merge/delete/reorder — exactly the events the
   derived browser is blind to, and far fewer rows); manually, a
   "mark this version" door (fewest rows, most deliberate, and it matches
   ⌘S's own grammar). These are not exclusive.

3. **What does Restore DO?** Three shapes, each defensible:
   (a) **read-only browse** (no restore door at all — the safest first ship);
   (b) **restore in place** — a compound of ordinary operations (re-place
   deleted blocks, re-order, re-choose takes, restore each take's text from
   its savepoint) under ONE structural undo entry; honest to the pointer
   religion, and every leg already exists as an op;
   (c) **restore as a new VERSION note** (`duplicateAsVersion`-shaped) — the
   old state arrives beside the current one, nothing is overwritten, and the
   two are comparable in Compare. This is the most Variorum-shaped answer and
   the least destructive; it is also the one that grows the library.

4. **What happens to a snapshot when a block is really deleted?** (The purge
   knot in §4.) Family-complete purge with a visible sentence, on the
   round-8b precedent, is the consistent answer — but it means old snapshots
   lose material, and she should say so out loud before it ships.

5. **Where does the face live?** The note ▾ menu's History is per-BLOCK today
   (it shows the caret block's savepoints plus its past region). A note-level
   history is a second, different thing under a name that is already taken —
   so either History becomes two tabs (this block · this note), or the note
   history gets its own door. Naming matters here more than usual, because
   her original confusion was about which surface answers which question.

6. **Does this retire anything?** If note history ships, the per-take History
   face keeps its job (a take is where writing happens). But "the block's
   past" + "the note's past" + "the Trash" + "versions" is four past-shaped
   surfaces, and her round-1 instinct was already that the app has one too
   many. A design sitting should decide what CONSOLIDATES, not only what is
   added.

---

## 6. Recommendation, stated as one (the sitting may ignore it)

Ship §2's derived browser first — it is small, schema-free, reversible, and
its limits are honest and visible. Let a month of real use answer knot 1: if
she reaches for it and finds a deleted paragraph missing from its place, that
is the evidence that buys §4's schema event. If she does not reach for it at
all, the store was never the problem.

**Owner:** a future phase row on the master plan (born at the 13j sitting,
round 2). Nothing here is built, and nothing here binds.
