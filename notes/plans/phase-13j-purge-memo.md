# The purge design — how "really deleted" actually works

**Phase 13j, batch 6 deliverable. Written FOR the author.** Plain language
first, mechanics second, the concrete deploy-ready DDL last. It folds the
long-standing **Tombstone GC** row from `notes/KnownIssuesAndTechDebt.md`
into ONE design, exactly as her J1 item required ("design WITH the
Tombstone-GC row… S2 bends only by that design, never a shortcut").

**Status: a design, not a build.** Batch 6 shipped the half that is safe on
its own — the 30-day clock, which HIDES. Nothing here removes a byte yet.
Her rulings at sitting rounds 8, 8b and 9 settled the four author-level
calls, so this memo is written TO them rather than as a menu; the build is
batch 6b.

---

## 1. What she asked for, and what it means technically

> *"some kind of 'true delete' should be added for posts (going to a Trash
> for 30 days before really deleting), because I already have posts in my
> library i don't want to have."*

Two different promises live inside that sentence:

1. **It leaves my app.** Nothing lists it, nothing finds it, no door offers
   it back. — **SHIPPED in batch 6.** A deleted thing crosses the 30-day
   boundary and disappears from the Trash, the note's tray, the block's
   History face and every recovery query at once.
2. **It is really gone.** The words are no longer on my disk, and not on the
   server either. — **THIS memo.** It is the harder half, and the reason is
   sync, not storage.

The store's founding rule (S2) is *deletes are tombstones*: a deleted row
stays as a row with a `deleted_at` stamp. That is what makes undo cheap,
restore exact, and sync convergent — a tombstone is how one device tells
another "this is gone", and a row that simply VANISHES says nothing at all.

**So the danger of a naive purge is precise, and it is not data loss — it is
resurrection.** If the Mac physically removes a note's rows while the phone
has not yet pulled the deletion, the phone still holds the note as live, and
its next push re-uploads it. The note comes back. Worse, it comes back
looking like a fresh write, so the Mac accepts it. A user watching that
happen learns the app cannot be trusted to delete things — which is the
opposite of what this phase is for.

---

## 2. The rule that makes purging safe: the horizon

**Purge only what every device on the account has already seen deleted.**

Concretely: each device tells the server how far it has read (its pull
cursor). The lowest cursor across the account's devices is the **horizon**.
A tombstone whose deletion was published BEFORE the horizon has been seen by
everyone; its rows can be removed, and no peer can re-push them because no
peer still believes the thing is live.

Three facts from the existing sync design bind this and are already true:

- **`server_seq` is the ordering authority, never wall clocks** (SyncSpec
  §9). The horizon is a seq number, not a date.
- **The changefeed has a visibility skew** (SyncSpec §5, the A5 amendment):
  a row is stamped with its seq at WRITE time and becomes visible at COMMIT
  time, so the feed already refuses to serve rows written in the last ~2
  seconds. The purge must respect the same safe horizon, for the same
  reason.
- **`sync_row_seq` already records, per row, the `server_seq` at which this
  device accepted it** (SyncSpec §3). That is what lets a client answer "was
  this deletion published before the horizon?" without asking the server
  about every row.

**Her rulings that shape it (round 8):**

- **A device unseen for 60 days leaves the horizon.** Otherwise one phone in
  a drawer freezes purging for the whole account forever. The dropped device
  is not forgotten silently — see the ledger below.
- **The clock the USER sees is not the horizon.** 30 days is when things
  leave every surface. The janitor trails behind, invisibly, and takes the
  bytes when it is safe. She never waits on it, and never sees it.

### The returner problem, and the ledger that answers it

A device that dropped out of the horizon and then comes back holds a stale
picture: it still believes purged things are live, and its outbox may still
hold writes for them. Two protections, both server-side and both cheap:

- **A content-free purged-ids ledger.** When the server purges rows it
  records `(table_name, row_id, purged_at_seq)` — ids only, no words, no
  metadata. A push naming a purged id is REFUSED with "this was purged", and
  the client drops that outbox entry instead of resurrecting the row. (The
  ledger is small and prunable: an entry is only needed until every live
  device's cursor passes it — the same horizon, one level up.)
- **A returner re-onboards rather than merges.** A device whose cursor is
  older than the oldest ledger entry cannot be reconciled row-by-row, so it
  re-initializes from the server (the `resyncReinitialize` road that already
  exists). Local unsynced writes are pushed first, so nothing typed is lost;
  what it loses is a stale belief.

---

## 3. What she ruled, in one place

| Question | Her ruling (round) |
|---|---|
| The window | **Fixed 30 days**, no setting; Delete Now is the impatience door (3) |
| Where full delete lives | **Inside the Trash only** — never a door in a note or the editor, ever (3) |
| Purge-intent shape | **One small synced `purge_intent` table**, and she **pre-authorized the DDL + mirror deploy** verbatim (8) |
| Horizon drop-out | **60 days** — a device unseen that long leaves the horizon; the ledger fences a returner (8) |
| Empty Trash | **Everything, always** — the confirm names the full count; scoped removal is the filter + per-row Delete Now (8) |
| Preserved originals | **Purge with their family**, and MOVE VISIBLY onto the family's clock beforehand so nothing disappears from a place that promised permanence (8b) |
| Savepoint pruning | **Default: older than 90 days, keep the newest 10 quiet savepoints per take; deliberate ⌘S commits never pruned** — plus a setting with a **"Never"** choice (9) |

---

## 4. The mechanics, end to end

### 4a. Delete Now (one row) and Empty Trash (all of it)

Both live ONLY inside the Trash surface, both confirm once, and both do the
same two things:

1. **Write a purge intent** — one row per thing being purged, in the new
   `purge_intent` table, which syncs like any other row. This is what makes
   the act travel: a peer that pulls the intent learns "this is going" and
   purges its own copy when its own horizon allows, instead of discovering a
   silent hole later.
2. **Remove the rows locally**, family and all (§4c), the moment the local
   horizon allows it — usually at once for a single-device account, and on
   the janitor's next pass otherwise.

The Trash rows vanish from every surface immediately either way: the 30-day
clock already hides, and Delete Now is "hide now, and mean it".

**Empty Trash is everything, always** (her ruling). The confirm names the
full count — *"Empty the Trash? 41 things go for good: 12 notes, 24 blocks,
3 takes, 2 books."* Scoped removal is the filter plus per-row Delete Now,
which is exactly why the filter had to exist before this door did.

### 4b. The janitor (the invisible half)

A small periodic pass, riding the existing sync scheduler:

1. read the horizon (the account's lowest live-device cursor, minus the
   visibility-skew margin);
2. collect every tombstone older than 30 days whose deletion was published
   before the horizon, plus every `purge_intent` row whose intent was;
3. remove the rows, family-complete (below), in ONE transaction per family;
4. record the purged ids in the ledger and clear the intents.

It is idempotent, resumable, and never blocks anything the author is doing.
If the horizon cannot be established (no server, no session), it does
nothing — the safe answer.

### 4c. What "the family" means (purge is never partial)

Purging a note takes: the note row, its placements, the blocks those
placements owned, every take of those blocks, every take's savepoints, the
blocks' comments, their tags applications, their canvas rows and lens picks,
their edges — and, per her round-8b ruling, **any preserved original whose
whole descendant family is going with it**.

That last one is the case she worried about, in her words: *"the issue I
don't want is for someone to think the ancestor being there in that one
ancestor tray is their guaranteed backup and then they freely delete a block
only to realize the ancestor disappeared later."* The design answer she
ruled — and batch 6 BUILT — is that nothing disappears from a place that
promised permanence: while any descendant lives, the original sits in the
tray's "Preserved originals" section with no clock; the moment its last live
descendant is deleted, the row MOVES into the clock-bearing section and the
Trash, wearing the family's countdown and the words *"preserved original —
goes with its deleted blocks"*. The delete that stranded it says so in its
own receipt. By the time the janitor takes it, she has been told twice.

### 4d. Savepoint pruning (her round-9 ruling)

Quiet savepoints (`kind:'auto'`) accumulate by design now that leaving a note
leaves one behind (13j J11). The janitor prunes them on the same road:

- **Standard (default):** once a quiet savepoint is older than **90 days**,
  keep only the **newest 10** quiet savepoints per take and purge the rest.
- **Never:** prune nothing.
- **Deliberate ⌘S commits are NEVER pruned, in either mode.** They are the
  ones she meant.

The setting is one synced enum beside the savepoint-cadence setting the same
phase shipped (`setting.value` stays enum-only — the E2EE column fence
holds). The janitor reads it before minting any savepoint purge intent, so
"Never" means never on every device.

### 4e. The Fragments bridge (checked, and quiet)

**Nothing breaks, and nothing new is owed.** The bridge's push sweep already
reads LIVE journal entries only (`deleted_at IS NULL`), so a journal day
became invisible to it the moment it was tombstoned — 30 days before any
purge. Purging removes rows the sweep had already stopped seeing.

The one behavior worth stating plainly, because it is unchanged and might
surprise: **deleting a journal day in Variorum does not delete it in
Fragments.** The Fragments-side entry stays as it was. If she later edits
that day in Fragments, the bridge's landing rule creates a fresh Variorum
entry for the day (create-or-open, never blind create) — a NEW note, not a
resurrection of the purged one. That is the honest outcome and it needs no
Fragments-side change; if she wants deletions to travel to Fragments, that is
a contract-file conversation and its own decision, not this design's.

### 4f. What S2 bends to, exactly

S2 stands, with one clause added:

> Deletes are tombstones. A tombstone may be physically removed only after
> the deletion it records has been seen by every live device on the account
> (the horizon), and only with a purged-ids ledger entry standing in its
> place for as long as any device could still push the row.

Nothing else in the sync design changes: `server_seq` stays the ordering
authority, CAS is untouched, the merge matrix is untouched, and the repairs
in SyncSpec §7 keep operating on rows that still exist.

---

## 5. The schema, deploy-ready (her pre-authorization)

Her words, round 8: *"The small purge_intent table is fine and I'll authorize
the DDL and mirror deploy right now - that's fine for them to have."* This is
that DDL, in the choreography SyncSpec §12 requires: **mirror first, then
every client, then the first write**.

**ONE §12 lockstep event: marker 6 → 7.**

### 5a. Client (migration `v1_14`)

```sql
-- The purge INTENT: "this is going, everywhere". One row per thing.
-- Synced like any other row so the act travels; tiny, and self-clearing.
CREATE TABLE purge_intent (
  id            TEXT PRIMARY KEY,          -- UUID, minted by the requesting device
  owner_id      TEXT,                      -- the standing multi-tenant column
  table_name    TEXT NOT NULL,             -- 'container' | 'block' | 'variant' | 'reading'
  row_id        TEXT NOT NULL,             -- the thing being purged
  requested_at  TEXT NOT NULL,             -- ISO-8601, display/audit only — NEVER ordering
  sync_version  INTEGER NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL,
  updated_at    TEXT NOT NULL,
  deleted_at    TEXT                       -- tombstoned when the janitor completes it
);
CREATE UNIQUE INDEX uq_purge_intent_live
  ON purge_intent(table_name, row_id) WHERE deleted_at IS NULL;   -- §6's live-row rule
CREATE INDEX idx_purge_intent_row ON purge_intent(table_name, row_id);
```

Plus the standing machinery every synced table carries: the AFTER
INSERT/UPDATE outbox trigger (§3's trigger-fed capture), and a
`SyncTable` classification of every column as PLAIN — **`purge_intent`
carries no user words at all**, which is deliberate: ids and enums only, so
the E2EE disclosure list gains nothing to disclose.

*Repair rule for its one unique index (SyncSpec §7): two devices asking to
purge the same row is not a conflict — keep the row with the smaller `id`,
tombstone the other. The act is idempotent by nature.*

### 5b. Mirror (`Server/supabase/10_phase13j_purge.sql`)

```sql
-- 1. The mirror twin: same columns, NO uniqueness beyond the PK, NO FKs
--    (SyncSpec §2's load-bearing rule), born multi-tenant like every table
--    since 14c.
CREATE TABLE public.purge_intent (
  owner_id      uuid NOT NULL,
  id            text NOT NULL,
  table_name    text NOT NULL,
  row_id        text NOT NULL,
  requested_at  text NOT NULL,
  created_at    text NOT NULL,
  updated_at    text NOT NULL,
  deleted_at    text,
  sync_version  integer NOT NULL DEFAULT 0,
  server_seq    bigint NOT NULL DEFAULT nextval('public.sync_seq'),
  written_at    timestamptz NOT NULL DEFAULT clock_timestamp(),
  PRIMARY KEY (owner_id, id)
);
CREATE INDEX purge_intent_seq_idx ON public.purge_intent (owner_id, server_seq);
ALTER TABLE public.purge_intent ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purge_intent FORCE ROW LEVEL SECURITY;
CREATE POLICY purge_intent_owner ON public.purge_intent
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
-- …plus the seq/updated trigger every mirror table carries.

-- 2. The per-device pull cursor: what makes a horizon computable at all.
CREATE TABLE public.device_cursor (
  owner_id    uuid NOT NULL,
  device_id   text NOT NULL,
  last_seq    bigint NOT NULL DEFAULT 0,
  seen_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (owner_id, device_id)
);
ALTER TABLE public.device_cursor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.device_cursor FORCE ROW LEVEL SECURITY;
CREATE POLICY device_cursor_owner ON public.device_cursor
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

-- 3. The content-free purged-ids ledger: ids only, no words.
CREATE TABLE public.purged_row (
  owner_id     uuid NOT NULL,
  table_name   text NOT NULL,
  row_id       text NOT NULL,
  purged_seq   bigint NOT NULL,
  PRIMARY KEY (owner_id, table_name, row_id)
);
ALTER TABLE public.purged_row ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purged_row FORCE ROW LEVEL SECURITY;
CREATE POLICY purged_row_owner ON public.purged_row
  USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());

-- 4. The horizon, as a function the janitor asks for. A device unseen for
--    60 days (her ruling) leaves the horizon.
CREATE FUNCTION public.sync_horizon() RETURNS bigint
LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT COALESCE(MIN(last_seq), 0) FROM public.device_cursor
   WHERE owner_id = auth.uid() AND seen_at > now() - interval '60 days';
$$;

-- 5. The pull RPC records the caller's cursor (one UPSERT, same round trip),
--    and the push RPC refuses any row named in `purged_row` with a typed
--    'purged' reject the client drops instead of retrying. Both are edits to
--    the EXISTING functions rather than new doors — the 14c signatures
--    already carry the device and the vault-key fence.

-- 6. The marker moves last, in the same transaction: 6 → 7.
UPDATE public.sync_meta SET schema_version = 7;
```

**The consequence to plan for, flagged at the sitting:** the marker bump
makes any client still at marker 6 refuse to sync until it is updated — by
design (SyncSpec §12: disagreement means refusal, never improvisation). Her
PHONE is at marker 6, so **the deploy window has to bundle a fresh phone
build**, exactly as the 13-era deploys did. Nothing is lost while it waits:
the phone stays writable offline, its outbox intact.

---

## 6. What still needs her — and what does not

**Settled by her rulings; nothing needed:** the window, the doors' homes,
the purge-intent shape, the DDL (pre-authorized), the horizon drop-out, Empty
Trash's scope, the lineage-originals rule, the pruning numbers and its
setting.

**The two genuinely open items, both small:**

1. **The purged-ids ledger's own retirement.** The ledger fences a returning
   device, and an entry stops being useful once every live device's cursor
   has passed it — i.e. it can be pruned on the SAME horizon. That is the
   design's own answer and it needs no ruling; what is worth her word is
   whether a returning device older than the whole ledger should
   **re-onboard silently** (it re-initializes from the server, keeping its
   unsynced writes) or **say so first** ("this phone has been away a while —
   it will reload from your account"). The build's default is to SAY SO: a
   silent reload of a whole device is exactly the kind of thing this phase
   exists to stop hiding.
2. **Whether Delete Now should confirm per row or once per sitting.** Her
   ruling is "both confirm once"; what is not settled is whether emptying
   five rows one after another should keep asking. The build's default is to
   ask every time (destructive, unrecoverable, rare) — trivially changed to a
   session-scoped "don't ask again" if it annoys her in use.

**And one honest statement she should hear once:** past the 30-day window,
before the janitor has run, a thing is unreachable but its rows still exist
on disk. It is not "recoverable" in any sense she can use — no door offers
it — but a forensic examination of the SQLite file would still find the
words. The purge is what makes the second sentence stop being true, and that
is the whole reason it is worth building.

---

## 7. Build shape (batch 6b), for the record

1. Migration `v1_14` + the `SyncTable` classification + the outbox trigger
   (schema commit of its own, per CLAUDE.md).
2. The janitor in `VariorumCore/Sync/` — **the standing Sync/ rider applies**
   (engine surgery is Fable's while the budget lasts).
3. The two doors (Delete Now, Empty Trash), in the Trash surface only, with
   their confirms.
4. The pruning pass + its setting row.
5. The mirror deploy (marker 6 → 7) at a window that bundles the Mac and
   phone refreshes.
6. Tests: the fake-server harness gains a horizon; the convergence suites
   gain "a purged row cannot be resurrected by a stale peer", "a device
   outside the 60-day window does not hold the horizon", and "an intent
   applied twice is one purge".
