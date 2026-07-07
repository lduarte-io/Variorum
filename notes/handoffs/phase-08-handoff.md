# Phase 8 handoff — iOS journal capture (closed 2026-07-07)

Self-contained checkpoint for the author. Everything a fresh session needs to answer your
questions about this phase is in this file plus the pointers at the bottom — the build
sessions are cold; never wake them.

---

## Your checklist (in this order)

1. ~~**Deploy the sync-server fix (one paste).**~~ **DONE (author, 2026-07-07 — deployed
   in the Supabase SQL editor; QUESTIONS #6 resolved). The env-gated integration test stays
   optional at the device round (step 4).** Open the Supabase SQL editor (Variorum
   project) and run **`Server/supabase/03_visibility_horizon.sql`** — same flow as Phase 5's
   setup. It closes the changefeed visibility-skew race from the Fragments post-mortem
   (SyncSpec §5). Clients need no change; sync simply sees a ~2 s-delayed head. *(I wrote
   and test-pinned the file but could not deploy it: the permission system refused headless
   access to your production project — correctly.)* Optional afterwards: run the env-gated
   integration test (`VARIORUM_SUPABASE_URL/_API_KEY/_TOKEN` from `.env.supabase.local`,
   then `swift test --filter SupabaseIntegrationTests`) — it is now horizon-aware.

2. **Install the phone app — as a RELEASE build (this matters).** Plug in + trust the
   iPhone, then in Xcode: scheme `VariorumMobile` → Edit Scheme → Run → Build Configuration
   → **Release** → run to your device once. Why Release: the A4 dev-store fence means a
   *debug* build launched from the home screen always opens the separate dev store, where
   **sync is deliberately off with no setup door** — a debug install would dead-end step 3.
   (The fence exists so dev-session bugs can never touch your writing or your mirror; its
   iOS consequence is ratify item #4 below, with "iOS defaults to the real store" on the
   table if Release-install annoys you.)

3. **Paste the sync credentials — on BOTH apps.** Each app's sync status row → "Set up…" →
   paste the project URL + API key (token field blank is fine; it reuses the key). Stored in
   the Keychain; nothing is bundled or committed; re-paste after your key rotation. The Mac
   app needs this too — it is sandboxed and cannot read `.env.supabase.local`. **Mac note:**
   like the phone, the Mac's *debug* default is the dev store (sync off) — for real use run
   a Release build, or add the `-VariorumRealStore` launch argument to the Variorum scheme
   (that choice is ratify item #4).

4. **The real-device verification round (Step 7 iii/iv):**
   - Journal an entry on the phone ("Today") → confirm it appears on the Mac.
   - Edit the SAME entry's text on both devices across an airplane-mode window → sync →
     confirm the **Mac fan shows the losing text as a conflict variant** and the phone
     shows the winner — nothing lost (S5).
   - One more offline capture (airplane mode) → back online → confirm it syncs.

5. **Ratifications — four of six DONE at the checkpoint (2026-07-07, coordinator session):**
   **#2** capture control = `TextEditor` as shipped · **#4** daily-drive = **Release builds
   on both devices** (fence unchanged — step 2's Release-install is the settled procedure,
   not a workaround) · **#5** `newBlock` will stamp `last_touched_at` + churn (your call:
   option (a); **Phase 9 implements it**) · **#7** re-dating onto an occupied day stays
   silently allowed. Recorded in the phase plan's checkpoint ratification round + AppSpec
   §14. **The remaining two closed 2026-07-07 (mid-Phase-9 QUESTIONS walk): #3 RATIFIED
   as shipped (Keychain paste-in on both platforms) and #6 DONE (the A5 paste deployed —
   checklist item 1). All six are settled.** Also recorded for your eyes (closeout "Interpretations"): Mac-side sync
   wiring; the "All posts" scope on the phone; archived-entry-opens (live sibling now
   outranks it).
6. **Skim the review dispositions** (two rounds, every finding + what changed):
   `notes/plans/phase-08-ios-capture.md`, sections "Review round 1" and "Review round 2".
7. **Still pending from Phase 7:** your manual §5 feel pass on the Mac editor (record the
   result in the Phase 7 plan when you run it).
8. **Standing ritual:** after the first real week of two-device journaling, run the manual
   dump-compare of both stores (five minutes; Phase 12's soak formalizes it later).
9. **Kick off Phase 9 in a fresh session** whenever ready (`/run-phase`). Its plan was
   pre-written at your forward-planning session and is reconciled with Phase 8's outcomes
   (`notes/plans/phase-09-structural-gestures.md`, banner + checklist).

---

## What shipped (and why it's shaped that way)

**The phone is a second client of the same store — not a second model.** `VariorumMobile`
wraps the same `VariorumCore` + Phase 5 sync engine; every write flows through Operations
onto the trigger-fed outbox exactly like the Mac (pillar 8: journal restrictions are a UI
profile). The Phase 7 shell (recoverable open, session, runner, autosave coordinator) moved
to `App/Variorum/Shared/` and compiles into both targets — shared, never forked.

- **Capture:** "Today" (and "Entry for a date…") is **create-or-open** — your notebook rule
  at the operations level (`createOrOpenJournalEntry`): one entry per calendar day; an
  existing live entry opens (live outranks archived; converged double-creates open the
  earliest, identically on every device); malformed day keys refuse (the Fragments bridge
  will feed this exact door). `entry_date` is yours to set — any day, past or future;
  `created_at` never moves. The first keystroke on an empty entry mints THE block;
  everything after is ordinary autosave. Fans are invisible on the phone: a fanned block
  shows and edits exactly the chosen take. Sealed posts read-only with the refusal shown.
- **The list:** journal entries newest-day-first, plus an "All posts" scope so you can edit
  any post's block text from the phone (the pillar's second capability). Both bounded (P1).
- **Sync lifecycle (Step 6):** one `SyncScheduler` per app — rounds strictly serialized,
  pinned pull→push, triggers coalesce, **offline is free** (any error keeps the outbox and
  waits for the next trigger — airplane mode and iOS file-protection both land here).
  Triggers: launch, foreground/became-active, after writes settle, and (iOS) a
  background-transition flush that lands your in-flight typing in the store first, then
  pushes. One-row status surface on both apps.
- **Idle auto-commit finally scheduled (Step 5, KnownIssues resolved):** launch + hourly
  sweeps ask `idleAutoCommit` for posts idle past `idle_commit_hours` (24 h default) —
  windowed by a low-water mark so a sweep costs ∝ recent edits, never the corpus.
- **The amendments:** **A1** rotating store backups on the Mac (daily, keep 14 — Supabase is
  a mirror, not a backup); **A2** the fault-injection suite — lost acks, duplicated
  deliveries, mid-drain failures, stale replays, edits-during-push all converge **with zero
  engine changes** (the Phase 5 engine held; the suite pins it forever); **A3** the
  scheduler above; **A4** the dev-store fence — debug builds open `Variorum-dev/` and
  **never sync** (your corpus and your mirror are unreachable from dev smoke launches);
  **A5** the visibility-horizon fix (your paste, item 1); **A6** completeness walks that
  fail the build if a future migration ever adds a column sync would silently drop —
  including an in-repo check that the Postgres mirror DDL covers every synced column.

## Counts

- Core `swift test`: **423 green in 50 suites** (Phase 7 baseline: 383/39).
- Mac app: **101 green in 17 suites** (was 86/12).
- iOS (new): **11 green in 4 suites** — iPhone 17 Pro simulator, iOS 26.2.
- 15 commits `9a690d8..ee41f98` (Step 1's verify-fix through review round 2), plus the
  closeout-ritual commit carrying this handoff.

## The review, in brief (all dispositions written in the phase plan)

**Round 1 — 1 BLOCKER / 1 MAJOR / 5 MINOR / 3 NIT, all agreed + fixed with red-on-old
pins.** The BLOCKER: the A4 fence had a sync-shaped hole — debug and release share a
Keychain, so a dev-store session would have auto-adopted your pasted credentials and paired
the dev store with your one production mirror; dev sessions now never configure sync at
all. The MAJOR: the phone editor could adopt a stale projection at a clean instant, reset
its edit base, and overwrite freshly flushed text (plus a double-mint variant of the same
race); deliveries are now signals only — adoption happens exclusively through
generation-stamped fresh reads. MINORs: re-configure drains in-flight rounds; sweep marks
are per-store and held on failure; the iOS file-protection pick now happens *before* first
open (it was a post-open no-op); create-or-open prefers live over archived same-day
siblings; the sweep's coverage claim was corrected (and its residual gap pinned as a
documented test).

**Round 2 (fresh reviewer) — 4 MINOR / 1 NIT, zero new HIGH → no round 3.** Scheduler
`retire()` closes a stale-trigger revival window after re-configure; malformed day keys
refuse at the ops boundary; backgrounding now flushes the open editor's pending text before
the sync round (`onDisappear` never fires on whole-app backgrounding); the A4 iOS wrinkle
(checklist item 2) documented; one more sweep-coverage residual named in QUESTIONS #5.

## PROVISIONALs awaiting you

QUESTIONS #2 (TextEditor) · #3 (Keychain paste-in) · #4 (daily-drive + iOS install mode) ·
#5 (`newBlock` stamping, options a/b/c) · #7 (re-dating onto an occupied day). Plus the
closeout-recorded interpretations (Mac sync wiring; All-posts scope; archived-entry-opens).

## Pointers

- **Detailed record:** `notes/plans/phase-08-ios-capture.md` (closeout + both review rounds,
  every finding's disposition).
- **Open items:** `notes/QUESTIONS.md` (Phase 8 section, #2–#7).
- **Deferred work:** `notes/KnownIssuesAndTechDebt.md` (three rows resolved this phase;
  restore drill → 12; one new 9b-owned row).
- **Master plan:** `notes/DetailedPlanForPhases.md` (pointer → Phase 9; Phase 8 closeout
  paragraph).
- **Next phase:** `notes/plans/phase-09-structural-gestures.md` (pre-written, reconciled
  2026-07-07 — see the checklist under its banner).
- **Server change awaiting you:** `Server/supabase/03_visibility_horizon.sql`.
