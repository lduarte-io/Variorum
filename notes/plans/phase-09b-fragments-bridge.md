# Phase 9b — The Fragments journal bridge (execution plan)

> Authored 2026-07-07 at Phase 9's closeout per the front-loaded-planning rule, FROM
> `notes/plans/phase-09b-fragments-bridge-brief.md` — the brief's author-ratified decisions
> are **binding** (the doctrine, the contract facts, the push/pull/landing rules, the
> duplicate-day pause, the fifth quiet auto-commit occasion, and the **graduated-entry
> policy, RATIFIED 2026-07-07**); its open interpretations are this plan's to answer.
> **Staffing (author, 2026-07-07): Fable implementer + Fable reviewer** — the bridge is
> sync-shaped and writes to her live Fragments journal; the standing rider applies to any
> `Sources/VariorumCore/Sync/` touch as always.

## Kickoff message (for a fresh session)

> You are starting **Phase 9b of Variorum** — the Fragments journal bridge: journal
> entries flow both ways between Variorum (the journal's HOME and TRUTH) and the author's
> Fragments app (a co-writer projection surface holding one plain-text body per calendar
> day). **First, verify Phase 9 is closed** (the master plan pointer says 9b; the Phase 9
> closeout + its three review-round sections exist in
> `notes/plans/phase-09-structural-gestures.md`) — if not, stop and report. Read, in
> order: `CLAUDE.md`, `notes/plans/phase-09b-fragments-bridge-brief.md` IN FULL (every
> ratified decision there is binding — doctrine, contract facts, landing rules, the
> graduated-entry policy), **`notes/fragments-bridge-contract.md` IN FULL** (the pinned
> Fragments-side facts the bridge builds against — if the contract seems wrong or
> insufficient, STOP AND REPORT; **never look at `~/dev/fragments`** — this repo's agents
> never read or touch it, hard author rule), `notes/SyncSpec.md` §5–§7 (the merge/repair
> doctrine the landing rules mirror) and §12 (lockstep — noting the bridge's state is
> LOCAL-ONLY and exempt), `notes/plans/phase-09c-auth-brief.md` (the NEXT phase
> generalizes session/auth — build the bridge's Fragments-side session machinery as a
> clean seam it can absorb, and do NOT couple it to the Phase 8 paste-in, which retires
> at 9c), QUESTIONS #9 (the auth decision's record), AppSpec §14's 2026-07-07 deltas
> (user-set `entry_date`; the notebook rule; the fifth auto-commit occasion), and this
> plan in full. **Baselines — do not re-run at session start:** core `swift test` = 430
> green in 51 suites; Mac app = 222 green in 40 suites; mobile = 11 green in 4 suites.
> **Author-availability note (her 2026-07-07 call): she defers ALL sync/device testing
> until 9b AND 9c are BOTH complete** — the bridge's manual real-project pass and the
> Phase 8 device rounds execute post-9c with the new sign-in, NOT with the paste-in; this
> phase therefore ends headless-verified against the fake Fragments server (one
> author-assist gate is deliberately deferred, and the closeout must say so). Views stay
> functional and unstyled; the only UI this phase touches is a bridge status row.

**Goal:** an entry created or edited in either app lands in the other; nothing typed is
ever lost Variorum-side (every landing path ends in a live row or a labeled variant);
duplicate-day pauses that day's push visibly; unchanged text never pushes; the
deterministic-id derivation matches the contract's worked examples — all proven against a
fake Fragments server pinned to the contract.

**References:** the 9b brief (binding); `notes/fragments-bridge-contract.md`; SyncSpec
§5–§7, §12; the 9c brief (the session seam's future); OverallModel §3 (the fifth quiet
auto-commit occasion); AppSpec §9 (`createPost`/`newBlock`/`autosave`/commit machinery the
landings ride); KnownIssues row "Bridge-side `setEntryDate` day-key validation" (owned
here — Step 6 resolves it).

---

## Ground rules

- **Variorum is truth; Fragments is a projection surface.** The bridge lands Fragments
  writing through ORDINARY Variorum operations only — zero direct row writes (review
  focus 1). S5's conflict-as-variant doctrine extends to the second writer.
- **The repo boundary is absolute:** nothing under `~/dev/fragments` is ever read or
  touched. The contract file is the whole interface; a contract gap is a stop-and-report,
  never an expedition.
- **The credential is user-auth** (the author's Fragments account), never the PAT, never
  committed; it lives untracked/Keychain-side. The session machinery is a SEAM (protocol
  + one concrete) that 9c will generalize into the real sign-in — do not couple it to the
  Phase 8 paste-in form or its Keychain keys.
- **Push idempotence is a correctness rule, not a nicety:** an unchanged body must never
  re-push (their row-LWW would let a pointless `updated_at` bump beat a real Fragments
  edit — mirroring their own editor's clobber guard).
- **The duplicate-day pause is deliberate** (never newest-wins): Fragments is DB-unique
  per (user, date) with a deterministic id — a slipped duplicate push would LWW-overwrite
  one text with the other THERE; an overwrite the author didn't choose is the forbidden
  outcome. The bridge holds the day, visibly, until she hand-merges.
- **The graduated-entry policy (RATIFIED):** two-way while the entry is a single unfanned
  block; a graduated entry (multi-block or fanned) turns push-only, and a Fragments-side
  edit against such a day lands as a `'fragments'`-labeled variant on the entry's FIRST
  block — never lost, never diff-mapped back across blocks (OverallModel §8).
- **The fifth quiet auto-commit occasion (author, 2026-07-07):** a landing about to
  overwrite entry text that differs from the variant's last commit appends ONE
  `commit_point(kind: 'auto')` first — Fragments has no history surface, so anything
  edited or deleted there stays one restore away in Variorum's commit view. The
  idleAutoCommit dirtiness guard applies (no commit when the last commit already equals
  the current text); landings are pull-cadence, so this is bounded.
- Schema/model changes get their own commit (the bridge-state migration, Step 2).

## Steps

### Step 1 — The contract layer: id derivation, transport, fake server
**Files:** `Sources/VariorumCore/Bridge/FragmentsContract.swift` (deterministic-id
derivation + day-key canon), `Bridge/FragmentsTransport.swift` (the RPC dialect:
`sync_push` guarded upsert / `sync_pull` keyset / `sync_delete`, honoring their ~2 s
visibility horizon), `Bridge/FragmentsSession.swift` (the auth SEAM: a protocol yielding
a bearer session, one concrete fed by an injected credential — the 9c-absorbable shape),
`Tests/.../Support/FakeFragmentsServer.swift` (pinned to the contract: live-unique
(user, date), row-LWW on client `updated_at`, un-tombstone only on strictly-newer,
visibility horizon).
**Tests:** UUIDv5 derivation matches the contract's worked examples EXACTLY (the join
key's whole trick); day-key canon rejects non-`yyyy-MM-dd`; transport wire shapes pinned
with no network (the Phase 5/8 `SupabaseTransport` test pattern); the fake server's LWW +
uniqueness + horizon behaviors pinned so bridge tests stand on verified ground.

### Step 2 — Bridge state (LOCAL-ONLY; own schema commit)
**Files:** `Persistence/Migrations.swift` (next migration: `bridge_state(day_key PK,
last_pushed_hash, fragments_cursor …)` — local-only like `sync_outbox`: never synced, no
outbox triggers, exempt from SyncSpec §12), record type, A6 completeness-walk updates
(the walks must KNOW it is deliberately unsynced — extend the local-only allowlist, with
a test proving a wrongly-registered bridge table would fail the walk).
**Tests:** migration applies; the table is absent from the sync registry and the mirror
DDL walk's synced set; outbox stays empty across bridge-state writes.

### Step 3 — The push half
**Files:** `Bridge/BridgeEngine.swift` (push side).
**Work:** eligible days = journal-profile posts with a live entry for their `entry_date`;
per day: render `renderedText`, hash-compare against `bridge_state.last_pushed_hash`,
push only on change (upsert under the deterministic id), record the hash on accept.
**Duplicate-day pause:** two live entries on one date ⇒ that day pushes NOTHING and the
status surface says so, until exactly one remains. Graduated entries still PUSH (the
policy's push-only direction — their rendered text is the projection).
**Tests:** unchanged-never-pushes (idempotence — call push twice, one upsert); changed
pushes once with the right id/body; duplicate-day holds that day only (other days flow);
the pause releases after hand-merge; a graduated entry pushes its rendered text.

### Step 4 — The pull + landing half (the doctrine's edge)
**Files:** `Bridge/BridgeEngine.swift` (pull side).
**Work:** keyset-pull `journal_entries` from `fragments_cursor`; per incoming day:
- **No Variorum entry for the date** → `createOrOpenJournalEntry(entryDate:)` +
  `newBlock(body)` (create-or-open, never blind create — the notebook rule).
- **Entry exists; only Fragments changed since last push** (current rendered ==
  last-pushed hash; incoming differs) → the fifth-occasion auto-commit guard, then
  `autosave` the body into the entry's single block.
- **Both changed** (current rendered ≠ last-pushed hash AND incoming ≠ either) → land the
  Fragments body as a **conflict variant labeled `'fragments'`** on the entry's block.
- **Graduated entry** (multi-block or fanned) → push-only: ANY incoming edit lands as the
  `'fragments'`-labeled variant on the FIRST block.
- **Incoming tombstone** (a Fragments deletion) → per the brief's wording ("a
  Fragments-side edit/deletion landing over uncommitted Variorum text auto-commits
  first"): insure via the same auto-commit guard, then land the deletion as the entry's
  text emptied through `autosave("")` — Variorum's entry row and history survive (truth
  keeps everything; the projection surface went blank). Record this reading in the
  closeout; if it feels product-shaped in implementation, PROVISIONAL it per the
  autonomous rule.
- **Never write under a dirty open editor buffer except via the conflict path** (the
  sync engine's exact discipline — reuse its posture, not new machinery).
**Tests (the brief's verification skeleton, one per scenario):** create-in-Fragments →
Variorum journal post exists with the body; create-in-Variorum → appears in Fragments;
Fragments-edit-over-uncommitted → auto-commit THEN autosave (the pre-edit text restorable
— assert the commit row), while already-committed-identical takes NO double commit;
both-changed → conflict variant labeled `'fragments'`, projection converges on the LWW
winner; deletion → insured then emptied; graduated → push-only + variant rescue;
duplicate-day → pull still lands but push pauses; cursor honors the visibility horizon.

### Step 5 — Scheduling + the status surface
**Files:** `App/Variorum/Shared/AppServices.swift` (+ a small `BridgeSession` wrapper),
status row alongside the sync row.
**Work:** the bridge rides the Mac app's existing sync cadence (launch / became-active /
post-write-settle — after the sync round, never interleaved with it); Mac-side only this
phase (Fragments-on-phone edits land when the Mac bridge runs — the brief's explicit
scope); the status row shows last-bridged time + the duplicate-day pause when active.
Dev-store sessions never bridge (the A4 fence's doctrine extends: the bridge pairs with
the real store only).
**Tests:** scheduler-level (the SyncScheduler test pattern): rounds serialize after sync;
a bridge failure keeps state (cursor/hashes) intact for retry; the dev-store fence holds.

### Step 6 — The KnownIssues row: `setEntryDate` day-key validation
**Work:** the landing path keys on `entry_date` and never re-dates entries — but the
row's question stands: `setEntryDate` remains the one permissive door to a malformed day
key that the bridge's join would then never find. Close it at the ops boundary the same
way `createOrOpenJournalEntry` was closed in Phase 8 (canonical `yyyy-MM-dd` or
`OperationError.invalidEntryDate`; nil stays allowed — un-dating a post is legitimate).
Red-on-old pin; the mobile date picker already produces canonical keys (verify by test,
not assumption). Resolve + remove the KnownIssues row.

### Step 7 — Phase verification (headless; the real-project pass is DEFERRED)
**Work:** (i) full suites, three targets. (ii) The round-trip matrix of Step 3–4 tests
against the fake server, plus a randomized soak: seeded interleavings of Variorum edits,
Fragments edits, deletions, duplicate-days, graduations — after every round, the
invariants hold (nothing lost: every body ever written exists live or as a variant or a
commit; hashes/cursor consistent; no gratuitous pushes). (iii) Convergence with the SYNC
engine running too (the bridge and the mirror sync interleaved — the bridge's writes ride
the outbox like any op). (iv) **The manual real-Fragments pass is deliberately NOT run
this phase** — the author defers all sync/device testing until 9c's sign-in exists (her
2026-07-07 call); the closeout and handoff must carry it forward explicitly as a
post-9c gate item.

## Explicitly out of scope
Running the bridge on Variorum-iOS (later nicety per the brief); any Fragments-side work
(the contract file carries asks — author-mediated only); auth/sign-in (9c — but the
session SEAM is built here to be absorbed); E2EE (14); graduated-entry diff-mapping
(permanently — OverallModel §8); views/styling.

## Risks / things to watch
- **This writes to the author's LIVE Fragments journal** once real credentials exist —
  which is exactly why this phase ships headless-verified and the real pass waits for
  9c's sign-in. Nothing in the automated suites may ever touch the real project.
- **LWW on the Fragments side means the bridge can destroy Fragments-side text by
  over-pushing.** The hash guard is the protection; treat any push not justified by a
  hash change as a defect of the forbidden class.
- **The contract is pinned, not guaranteed** — if the fake server's pinned behavior and
  the contract file disagree with reality at the (deferred) real pass, that's a 9c-era
  finding; record, don't guess.
- **The session seam is 9c's foundation** — a shortcut here (hardcoding, coupling to the
  paste-in) becomes 9c rework; the seam's shape is part of what the cold review checks.
- The A6 completeness walks were built to catch UNREGISTERED synced tables; Step 2 adds
  the opposite case (a deliberately-local table) — extend the walks' vocabulary, don't
  weaken them.

## Review foci (for the cold reviewer — written at plan time, no implementation context)
1. The bridge writes Variorum rows ONLY through Operations (zero direct row writes).
2. Nothing typed in either app can be permanently lost — every landing path ends in a
   live row, a labeled variant, or a commit; assert it per scenario AND in the soak.
3. Push idempotence: no gratuitous `updated_at` bumps (their clobber-guard mirror).
4. The credential is user-auth, untracked, never the PAT, never committed; the session
   seam is paste-in-independent and 9c-absorbable.
5. The repo boundary held: nothing under `~/dev/fragments` read or touched; the contract
   file is the only Fragments source.
6. The duplicate-day pause is really a pause (day-scoped, visible, releasable) — never
   newest-wins.
7. The graduated-entry policy exactly as ratified: two-way single-unfanned; push-only +
   first-block variant rescue after graduation.
8. `bridge_state` is provably local-only (registry, walks, outbox all agree).

## Closeout
*(Written by the implementer at phase end: what shipped, test counts, PROVISIONAL calls
— including the deletion-landing reading if it proved product-shaped — review
dispositions, KnownIssues reconciliation (the `setEntryDate` row must be resolved), the
deferred real-project pass carried forward, and the 9c plan authored from its brief per
the front-loaded-planning rule.)*
