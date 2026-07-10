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
> plan in full. **Baselines — do not re-run at session start** *(corrected 2026-07-09 by
> the 9b coordinator: Phase 9d ran out-of-band after this plan was authored)*: core
> `swift test` = 430 green in 51 suites; Mac app = **231 green in 42 suites** (was 222/40
> pre-9d); mobile = 11 green in 4 suites.
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

## Closeout (2026-07-09 — implementer: Fable, single session; awaiting the cold review)

### What shipped, by step

- **Step 1 — the contract layer** (`Sources/VariorumCore/Bridge/FragmentsContract.swift`,
  `FragmentsSession.swift`, `FragmentsTransport.swift`;
  `Tests/.../Support/FakeFragmentsServer.swift` + 3 suites, 23 tests).
  **THE CONTRACT FINDING (the phase's one gap, judged non-core-gating — mechanism below):**
  `notes/fragments-bridge-contract.md` pins the id RECIPE
  (`UUIDv5("journal|<canonical-user>|<dayKey>")`) but NOT the namespace UUID, NOT the
  worked examples this plan's Step 1 tests presumed ("matches the contract's worked
  examples EXACTLY"), NOT the canonical-user string's exact form, and NOT the RPC wire
  shapes. Stop-and-report vs proceed was weighed explicitly: the missing facts are
  consumable ONLY at the real-project pass, which the author had already deferred
  post-9c; the engine's correctness (hash guards, pause, landings, auto-commit occasion,
  graduated policy) is independent of the leaf constants; and the plan's own risk list
  anticipates contract-vs-reality drift as "a 9c-era finding; record, don't guess." So:
  the UUIDv5 **algorithm** is pinned against the RFC lineage vector (DNS ns +
  "python.org"), the composition against the recipe string, golden vectors frozen under
  a STAND-IN namespace (RFC URL ns), and the namespace/canonical-user/user-id ride
  `FragmentsBridgeConfiguration` as author-supplied facts — nothing guessed into code.
  The wire DTOs are **PROVISIONAL** (snake_case column-named keys, Supabase
  `rest/v1/rpc` POST convention), pinned by no-network tests. **Asks 8–13 appended to
  the contract file** (namespace; worked example; canonical-user form; wire shapes;
  created_at-on-update; and an optional return-replaced-body that would close the loss
  window below). The session seam is `FragmentsSessionProviding` (bearer session per
  call → 9c's refresh slots in behind it) + `StaticFragmentsSessionProvider`; zero
  coupling to the Phase 8 paste-in (no Keychain, no shared keys; pinned: a signed-out
  session refuses before any request composes). The fake server pins every contract
  fact by test: strict row-LWW on client `updated_at`, live-unique `(user_id, date)`
  rejecting foreign-id day forks, un-tombstone only strictly-newer, LWW-guarded
  deletes, created_at preserved on update, clock-ahead clamp, keyset
  `(server_updated_at, id)` pulls, logical-clock visibility horizon.

- **Step 2 — bridge state** (migration `v1_4_bridge_state`, own commits). **Delta from
  the plan's sketch: TWO tables, not one** — `bridge_day(day_key PK, last_synced_hash,
  last_remote_stamp)` (per-day protocol state) and `bridge_state(key, value)` (the
  keyset cursor — a per-bridge value has no day row to live on). `last_synced_hash` is
  the **agreed hash** (recorded on push-accept AND on every landing), deliberately more
  than the sketch's "last-pushed": recording agreement at landing time is what makes
  push echoes and replays skip and prevents the landing→push echo loop.
  `last_remote_stamp` was added mid-phase (v1_4 amended in place BEFORE any persistent
  store ran it — recorded in the commit): it carries the landed row's client-LWW
  `updated_at`, and pushes stamp `max(now, last_remote_stamp + 1s)` — traced mechanism:
  a re-projection push answering a landed row is a LATER editorial event, and without
  the bump any clock ahead of ours (her phone's) leaves truth's re-projection
  permanently `.stale` under strict row-LWW. Both tables joined
  `SyncSchema.localOnlyTables`; the standing walks (registry⇄schema identity,
  mirror-DDL coverage, local-only-never-mirrored) now KNOW they are deliberately
  unsynced, and `BridgeStateTests` additionally proves a WRONGLY-registered bridge
  table fails both walk predicates. Bridge writes provably never touch the outbox.
  SyncSpec §12 exempt (nothing on the mirror changed).

- **Steps 3+4 — the engine** (`Bridge/BridgeEngine.swift`; `BridgePushTests` 9 tests,
  `BridgeLandingTests` — 16 tests at phase close, 19 after the round-1 pins).
  Rounds pinned **pull → push** (reconcile before
  projecting — also what makes FIRST CONTACT safe: a pre-existing Fragments journal is
  fully landed and state-recorded before any push decision, so initial sync can never
  blind-overwrite). **Push:** eligibility = ALL live journal-profile posts with a valid
  `entry_date` (archived included — archive is a view concept; a stale projection
  would be silent divergence); duplicate days push NOTHING (day-scoped, visible,
  releasable — pinned including the release); unchanged never pushes (pinned to the
  fake server's write counter and untouched LWW stamp); `.stale` records nothing (the
  pull reconciles); emptiness is never a FIRST push (it could only LWW-blank an
  unlanded Fragments body); malformed legacy `entry_date`s are noted, never bridged.
  **Change detection is a full per-day hash sweep, deliberately** — traced:
  `chooseVariant`, `deleteBlock`, and `deleteVariant` change rendered text WITHOUT
  stamping the container, so every stamp-based dirty filter silently misses whole
  classes (a moveBlock out of a day is worse still); a silent stale projection is this
  bridge's worst failure shape, so correctness rides the hash. Cost is ∝ live journal
  days per round at round cadence, off-main — the P1 tension is recorded in
  KnownIssues (owner: Phase 12) with the remedy sketch. **Landing:** the brief's
  classifier verbatim — create-or-open + `newBlock` for unknown days; echo/replay skip
  on the agreed hash; only-Fragments-changed ⇒ **the fifth quiet auto-commit occasion**
  (`idleAutoCommit`'s dirtiness guard IS the spec'd guard — already-committed-identical
  takes no double commit, pinned) then `autosave`; both-changed ⇒ conflict-as-variant
  labeled `'fragments'` (via `resolveSyncConflict`, which gained a label parameter,
  default unchanged); graduated (multi-block or fanned) ⇒ push-only + first-block
  variant rescue, never diff-mapped; gap slots defer with the cursor HELD (the
  straggler posture — advancing would strand a Fragments body forever, traced in the
  design notes); foreign-user/malformed-day rows consumed with notes; replay dedupe by
  existing-live-variant check (crash-between-ops-and-state windows mint no duplicate
  cards); lost-ack reconciles through the pull's converged branch with zero
  gratuitous re-push (postmortem lesson 2's bridge twin, pinned). Every landing path
  ends in a live row, a labeled variant, or a commit.

- **Step 5 — scheduling + status** (`Bridge/BridgeScheduler.swift` + 5 core tests;
  `App/Variorum/Shared/BridgeSession.swift`, `BridgeStatusViews.swift`,
  `AppServices`/`SyncSession`/`RootView`/`VariorumApp` wiring + 3 Mac-app tests).
  `BridgeScheduler` = the A3 contract (serialized, coalescing, retire-able, offline is
  free — a failed round keeps cursor and hashes byte-intact, pinned). App-side:
  `BridgeSession` mirrors `SyncSession`; **the A4 fence extends to the bridge** (real
  store only — a dev-store session must never touch her live Fragments journal;
  `bridgeEnabled` is Mac-only this phase per the brief's scope, the mobile target
  constructs it fenced); bridge rounds ride `SyncSession.onRoundCompleted` (new hook)
  so they follow sync rounds and never interleave with one (pinned with a gated sync
  transport: zero bridge calls mid-sync-round, exactly one after). The status row
  shows last-bridged time, errors with retry, and the duplicate-day pause verbatim.
  **The bridge ships UNCONFIGURED in the app** — deliberately no setup door: the
  credential story is 9c's sign-in (the row says so), and configuration additionally
  needs the ask-8/10 facts. `BridgeSession.configure(engine:)` is the seam 9c wires.

- **Step 6 — `setEntryDate` validation** (Operations+Container + 3 tests in
  `JournalEntryTests`). Canonical `yyyy-MM-dd` or `OperationError.invalidEntryDate`;
  nil stays allowed (un-dating is legitimate). Red-on-old: the refusal tests fail on
  the pre-9b op (it accepted any string). The mobile picker verified by TEST, not
  assumption: it formats exclusively through `JournalDay.dayString`
  (EntryEditorView/EntryListViewModel), and every `dayString` output across calendars,
  paddings, year edges, and leap days passes the validation gate. **KnownIssues row
  resolved and removed.**

- **Step 7 — verification** (`BridgeSoakTests`): (i) full suites — counts below;
  (ii) the deterministic both-directions round-trip + the randomized soak (3 seeds ×
  60 actions: Variorum creates/edits/graduations-by-block-and-fan/duplicate-days/
  hand-merges interleaved with Fragments writes and deletions and engine rounds) —
  per-round, `pausedDays` is exactly the duplicated-day set; at quiescence, every
  day's surfaces agree byte-equal, the agreed hash matches the converged text, a
  quiescent round makes ZERO server writes, and **nothing is invented**: every
  `'fragments'`-labeled variant's text is a member of the ledger of bodies Fragments
  actually wrote; non-vacuity asserted per seed (pushes > 0, landings > 0,
  conflict/rescue variants > 0); (iii) the bridge and the MIRROR sync engine together
  (two `SyncClient` devices + the fake Fragments server): Mac-authored,
  phone-authored-via-mirror, and Fragments-authored days all reach all three
  surfaces; the two Variorum stores end **byte-identical** with empty outboxes
  (bridge landings ride the outbox like any operation); a final bridge round is
  quiescent. (iv) **The manual real-Fragments pass is deliberately NOT run** — the
  author defers all sync/device testing until 9c's sign-in exists (her 2026-07-07
  call); carried forward in the handoff as a post-9c gate item, now additionally
  gated on the contract asks 8–12.

### Test counts (the Phase 9c baselines — POST-round-1 fixes; pre-review counts were 493/59, 234/43, 11/4)

- Core `swift test`: **497 green in 59 suites** (was 430/51 at phase start — +67
  tests, +8 suites; the round-1 fix pass added 4 pins).
- Mac app: **235 green in 43 suites** (was 231/42 — +4 incl. the throttle test).
- Mobile: **11 green in 4 suites** (unchanged; the mobile target compiles the shared
  bridge files but constructs the session fenced).

### PROVISIONAL calls + readings (QUESTIONS #13/#14; walk at the checkpoint)

1. **The contract-gap handling** (above) — namespace/canonical-user/user-id as
   injectable configuration; wire DTOs PROVISIONAL; asks 8–13 filed. QUESTIONS #13.
2. **Variorum-side journal deletion does NOT propagate to Fragments** — `sync_delete`
   is implemented in the transport (the dialect is complete) but the engine never
   calls it: options were (a) don't propagate — the day just stops pushing (shipped);
   (b) push a tombstone via sync_delete; (c) push an empty body. (a) is the only
   option that can never destroy Fragments-side text the author didn't choose to
   lose, and deleting a Variorum entry while Fragments holds newer text would
   otherwise race. Consequence, recorded honestly: deleting a journal entry in
   Variorum leaves the day's body visible in Fragments until she edits it there
   (whereupon it re-lands in Variorum as a fresh entry — nothing typed is ever lost).
   QUESTIONS #14(a).
3. **The deletion-landing reading** (the plan's own flag): insure-then-empty when
   only Fragments changed (shipped exactly as the plan sketched — entry survives,
   text one restore away); when the deletion RACES a Variorum edit, the edit wins and
   truth re-projects (the SyncSpec §6 tombstone-rescue shape — a projection-side
   deletion of stale text must not destroy newer truth-side text); graduated/sealed
   deletions skip with truth re-projecting (a blank `'fragments'` card is noise).
   QUESTIONS #14(b).
4. **Sealed/locked entries land incoming bodies as `'fragments'` variants DESPITE the
   seal** — extends the ratified S5-outranks-the-seal posture (AppSpec §14,
   2026-07-06) to the second writer: the seal freezes authoring; a bridge landing is
   not authoring, and refusing would strand the body. The sealed text itself is never
   overwritten. The one residual corner: a **sealed EMPTY entry** has no block to
   carry a card and the seal refuses the mint — the row is consumed with a note, no
   state recorded (so no push can blank the surface); the body stays safe in
   Fragments but un-landed. Corner-of-corner (a deliberately sealed blockless entry);
   recorded, not solved. QUESTIONS #14(c).
5. **Edit-war convergence: truth re-projects.** After a both-changed conflict landing,
   the incoming hash is recorded as the agreed state, so the NEXT push projects
   Variorum's rendered text back over the Fragments row (with an LWW stamp that
   outranks the landed row's). Reading of the brief's "Fragments keeps its row-LWW
   winner… allowed to be momentarily behind": the LWW winner stands on their server
   during the race; the bridge then converges the projection to truth without
   fighting the CAS — and the war terminates because their clobber guard never
   re-pushes an unchanged body. Both texts always survive in Variorum.
   QUESTIONS #14(d).
6. **Archived entries stay push-eligible** (archive is kept-out-of-view, not gone;
   a silent projection freeze on archive would be invisible divergence).
   QUESTIONS #14(e).

### Documented residuals (recorded, deliberately not solved here)

- **The first-push overwrite window:** a Fragments-side save landing in the seconds
  between the bridge's pull and its FIRST-EVER push of that day (no bridge state)
  can be LWW-overwritten server-side before any pull serves it — the one acknowledged
  window where Fragments-typed text can be lost (their state-based feed serves current
  rows only). Bounded: requires same-day two-surface authoring inside one round's
  pull→push gap on a never-bridged day; steady-state days always have state and land
  first. Same class as SyncSpec §7's documented concurrent-divide duplication.
  Contract ask 13 (return the replaced body) would close it to zero; revisit at the
  real pass.
- **The check-then-act window** between a landing's classification read and its
  operation call (separate transactions — ops cannot nest in one write): a local
  edit landing in that window can shift the true classification (an
  only-Fragments-changed read that was really both-changed). *(Corrected in review
  round 1 — the original wording here overclaimed: pre-fix, an edit landing between
  the insurance and the overwrite transactions was NOT committed first, and the
  landed body itself had no insurance at all against the editor's later flush.
  Post-fix, `applyBridgeLanding` composes insurance + overwrite + landed-body
  commit in ONE transaction, so everything the store holds at landing time — and
  the landed body — is one restore away; the residual is only the mis-CLASSIFIED
  overwrite-instead-of-conflict-card, fully insured. The Phase 9 round-3 class:
  op-level expected-text preconditions remain a core change without cause.)*
- **The push sweep's corpus growth** — KnownIssues, owner Phase 12 (remedy sketch
  recorded there); the P1 relaxation is on the author's ratify list (QUESTIONS
  #15, round-1 MAJOR 2) and cadence triggers are interval-throttled since the
  fix round.
- **Sealed-empty-entry landings** — PROVISIONAL 4 above (pinned by test since the
  round-1 fixes, NIT 8).

### KnownIssues reconciliation

- REMOVED: "Bridge-side `setEntryDate` day-key validation" (Step 6 shipped the guard).
- ADDED: "Bridge push sweep is O(journal-days) per round" — owner Phase 12.

### Deferred, carried forward

- **The manual real-Fragments pass** (author-assist, post-9c with the real sign-in) —
  in the handoff checklist, gated on contract asks 8–12 landing first.
- Bridge-on-iOS (the brief's "later nicety") — unowned by design; the Mac bridge is
  the phase's whole scope.

### The 9c plan

Authored from `notes/plans/phase-09c-auth-brief.md` per the front-loaded-planning rule:
`notes/plans/phase-09c-auth-alignment.md` (kickoff at top; the brief's ratified
decisions binding; the trust-mechanism lookup ran at plan time per the brief's
instruction — findings recorded there).

### Review rounds

## Review round 1 (2026-07-09) — 2 MAJOR / 3 MINOR / 3 NIT; ALL AGREED; every
## bug-class fix red-on-old-pinned (pins verified red by behavioral revert);
## dispositions below anchor round 2

**MAJOR 1 — the landed Fragments body had no insurance of its own (AGREED; fixed;
pin verified red-on-old).** Mechanism, traced: with the day's entry open in the Mac
editor holding un-flushed keystrokes B over store text T (agreed = hash(T)), the
classifier reads the STORE (T == agreed → only-Fragments-changed), insures the
pre-image T, and autosaves F — then the editor's keep-pending flush (Phase 7) writes
B over F, and the next push (rendered B ≠ agreed hash(F)) LWW-replaces F on the
Fragments side with an outranking stamp: **F gone everywhere**, violating the
doctrine's bar and review focus 2, in a seconds-wide (autosave-debounce) window on
exactly the co-written day. The closeout's original residual claim ("committed by
the fifth-occasion guard before the overwrite") was additionally FALSE for the
sub-window between the two separate write transactions — corrected in the residuals
section above. **Fix:** the new operation `Operations.applyBridgeLanding` (the
`lockPost` compose-in-one-transaction precedent): insure-pre-image → overwrite →
**commit the landed body itself** (`kind:'auto'`; skipped for empty bodies — a
landed deletion is not losable text), all in ONE transaction; the engine's
only-Fragments-changed path now calls it instead of `idleAutoCommit`+`autosave`.
Pin: `theLandedBodyItselfSurvivesTheEditorsKeepPendingFlush` (land F → simulate the
flush with `autosave(B)` → push → F still one restore away) — verified RED on the
pre-fix code by behavioral revert, green after; the two existing landing tests'
commit expectations updated ([pre-image] → [pre-image, landed-body], and the
no-double-commit test still proves no duplicate of the identical pre-image).

**MAJOR 2 — the O(journal-corpus) hash sweep at edit-settle cadence, and the P1
relaxation never reached the author (AGREED, both halves; architectural — traced
mechanism, no pin owed).** Mechanism confirmed: bridge rounds fire after every sync
round; sync rounds fire post-write-settle; each round renders + hashes every live
journal day — recurring corpus-proportional work on the editing path (of ANY post),
P1's letter, growing with years of journals. The hash-over-stamp rationale stands
(the reviewer concurred), but per CLAUDE.md relaxing a performance invariant is an
**author-only call** — it was parked in KnownIssues without a ratify entry.
**Fix (both offered paths taken):** (1) **QUESTIONS #15** filed for the checkpoint
walk (options incl. pulling the dirty-day remedy forward; PROVISIONAL (a) =
hash-sweep + throttle, Phase 12 owns the remedy); (2) cadence triggers are now
**interval-throttled in `BridgeSession`** (default 60 s — an engineering default of
the `settleDebounce` class, named in #15 for adjustment): a settle burst forwards
one immediate round plus at most ONE trailing round (the last trigger is never
lost); manual "Bridge now"/"Retry" bypass. Tested:
`cadenceTriggersAreThrottledToTheMinimumInterval` (Mac wiring suite).

**MINOR 3 — the stamp-only bookkeeping no-opped on virgin days, re-opening the
`.stale` wedge (AGREED; fixed; pin verified red-on-old).** Mechanism confirmed:
the deletion-raced-an-edit branch records `(hash: nil, remoteStamp: R)`;
`recordDay`'s hash-nil arm was `UPDATE … WHERE day_key = ?` — a no-op with no
`bridge_day` row (first contact), losing R; the re-projection then pushed with
`now` and wedged `.stale` until the wall clock passed the tombstone's ahead stamp —
exactly the class the `last_remote_stamp` amendment closed elsewhere. **Fix:**
`bridge_day.last_synced_hash` made NULLABLE (second in-place v1_4 amendment, same
no-persistent-store-ran-it safety, recorded in the migration comment) and the
stamp-only record now UPSERTS a hash-NULL row; `dayRow`/`dayState`/the push scan
treat a stamp-only row as "no agreed body" (including the never-first-push-of-
emptiness guard). Pin: `aTombstoneRacingAnEditOnAVirginDayStillGetsOutranked`
(virgin day + ahead-stamped tombstone + local edit → the SAME round's push APPLIES,
never `.stale`) — verified RED on pre-fix code (pushed 0 / stale 1), green after.

**MINOR 4 — permanent per-day failures and stalls were invisible (AGREED; fixed;
pin verified red on the unwired status).** Mechanism confirmed: the scheduler
discarded `report.rejected`/`stalled`/`deferred`/all notes — a live Fragments row
under a NON-derived id (the legacy/drift class asks 8–10 exist to catch) lands by
date but rejects every push of that day forever, with the round reporting success
and `lastError` nil: a silently frozen projection, against "record, don't guess."
**Fix:** `BridgeScheduler.Status` gains `stalled` + `issueNotes` (landing notes +
push notes — per-day rejections recur every round and stay visible); the status row
shows "needs attention (n)" with the verbatim notes on hover. Pin:
`aPermanentPushRejectionSurfacesInTheStatus` — verified red with the wiring
reverted (notes empty), green wired. **The reviewer's optional adopt-the-foreign-id
alternative was NOT taken**, with rationale: contract fact 2 makes the derived id
the convergence key both apps must share; silently adopting a drifted id would
perpetuate exactly the divergence the asks exist to surface — visibility + the
(deferred) real-pass reconciliation is the record-don't-guess posture.

**MINOR 5 — "never interleaved" was one-directional and the UI buttons bypass it
(AGREED as a wording/mechanism gap; documented, no gate built).** Traced: bridge
landings grow the outbox; the settle observation can trigger a sync round while the
bridge is still landing — and consequences collapse into the documented
check-then-act class (both engines' writes are per-transaction atomic; the sync
engine treats bridge-written rows as ordinary dirty rows). Building a cross-session
sync-idle gate would couple the sessions for no correctness gain. **Disposition:**
the guarantee is now stated honestly at the wiring site (`BridgeSession.trigger`
doc), in the closeout Step 5 paragraph, and here: cadence bridge rounds START only
after a completed sync round; the reverse overlap is possible and benign; manual
triggers are deliberate off-cadence escape hatches, same as "Sync now."

**NIT 6 — archived entries count toward the duplicate-day pause (AGREED; recorded,
no behavior change).** Deliberate and conservative: an archived sibling is still
the day's text (createOrOpen can open it when it is all the day has), and pushing
the survivor would silently drop the archived text from the projection. But the
author's natural hand-merge gesture may be archiving — so the consequence is now in
the QUESTIONS #14(e) walk verbatim and the status-row copy says "delete or re-date
one to resume."

**NIT 7 — a both-changed conflict landing graduates the day (AGREED; recorded, no
behavior change).** The `'fragments'` card fans the block → the ratified graduated
policy flips the day push-only: subsequent Fragments edits land as further rescue
cards, not text updates, until the card is pruned/archived. Policy applied as
written; the regime flip is now flagged in the QUESTIONS #14(d) walk so it never
surprises.

**NIT 8 — the sealed-EMPTY branch was untested + a count typo (AGREED; fixed).**
New pin `sealedEmptyEntryConsumesTheRowWithoutStateOrBlanking` (sealed blockless
entry + incoming body → consumed with the note, NO day state, no block minted, and
the push half never blanks the Fragments body; next round quiet). This pins
existing behavior — a coverage pin, not a bug-class pin, so passing pre-fix is
expected and correct. The closeout's "15 tests" corrected (16 at phase close; 19
after this round's pins).

**Round-1 fix-pass counts: core `swift test` 497 green in 59 suites; Mac app 235
green in 43 suites; mobile 11 green in 4 suites — the corrected Phase 9c
baselines.** Fix commits: the `applyBridgeLanding` + engine/scheduler/session/test
changes and the schema amendment (nullable hash, own commit) — see git log; every
pin's red state verified by stashing the source fixes (batch A: MAJOR 1 + MINOR 3
pins red) and reverting the status wiring (batch B: MINOR 4 pin red).
