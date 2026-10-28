# VX-623 handoff — Run: the first-run walk resets its own test account (CLOSED 2026-10-27)

## Your checklist

1. **Nothing needs your hands.** The run is merge-ready; release step 0 is now self-serve — the next
   release's gate is `Tools/WalkKit/first-run-walk.sh std` under a held stage claim, and it resets, runs
   BOTH first-run arms (set-up and join) and cleans up by itself. No more "reset std first" line in any
   release REQUEST.
2. **One standing-ruling landing to know about:** your 2026-10-27 ruling ("the walk may reset its own
   allowlisted test accounts") is now canon — CLAUDE.md's Environment line carries the exception with
   `Tools/prod-reset-test-account.sh` as its one road (never your account, never an unlisted one, never
   after a stopped walk), and the dated narrative is in `notes/AppSpecRecord.md`. Your in-session word
   "go ahead on that tool" added three narrow allow rules in `.claude/settings.local.json` (the
   prod-read form).
3. **One small open ticket born of the run:** VX-627 (Low · Bug · Confirmed · Tests & tooling) —
   `Tools/VisualWalk/pins/guard-order.zsh` fails 7 of 9 on MAIN, traced to the `vw_abort` key-up-shift
   belt from `3723268b6`. Pre-existing, not this run's files; it waits for a sweep.
4. **Two owned process slips, recorded in the run record:** the kickoff in-flight commit on main carries
   a `Co-Authored-By` trailer against your rule (one commit, caught at once, pushed history never
   rewritten); and round 2 briefly ran TWO cold reviewers concurrently after a budget death's resume was
   misread as failed — no harm (their results agree on every point, recorded as independent
   corroboration), lesson recorded: confirm a dead agent is gone before spawning its twin.

## What shipped (the record is `notes/plans/fixes/vx-623-walk-self-reset.md`; ladders `vx-623-ladder-round1/2.md`)

- **`Tools/prod-reset-test-account.sh`** — resets ONE allowlisted vxtest account to its resting state
  (exists, confirmed, vaultless, rowless) in one atomic statement mirroring `account_purge()` minus the
  auth user and entitlement; guards R1–R4 (the walk's G1/G2 verbatim — a pin keeps the twins
  byte-identical — plus byte-equal email resolution and parse-whole reads); before/after reads logged;
  90 self-test cases including drift pins that read `account_purge()`'s own body.
- **The walk's new shape** — a pre-step reset (heals a leftover vault), the set-up arm as proven at
  VX-510, a JOIN ARM (first live gate exercise of "Sync this library…" ever), sign-out/quit, a cleanup
  reset on PASS only (a STOP never resets — failure evidence on production survives for diagnosis);
  `--arm setup|join|both`, default both.
- **The window-frame guard** (the autosave key deleted pre-launch, bounds asserted) and
  **capture-every-window** behind the now fail-closed **words guard** (anything unreadable withholds —
  the ladder's one MAJOR, fixed with two pins).
- **guard.sh** compiles its wl2 helper or refuses (VX-536, red-on-old 6/11→0/11).
- **The live proof:** the full std gate PASSED on production (18:58:47–19:01:33, one invocation) — pre-step
  reset of the 0.10.3 leftover vault → set-up → join → cleanup; std ends at rest; the dev slot restored
  exactly (197/197 cmp, e11e5233 held, Resume never pressed); prefs final diff 0 added · 0 removed.

## The numbers

Members VX-622 · VX-537 · VX-536 all Done at the merge. Ladder: round 1 — 1 MAJOR · 2 MINOR · 2 NIT, all
fixed, every pin red-on-old; round 2 — NO FINDINGS, closed with a clean bill, twice-corroborated. Self-tests
at the tip: walk 72/72 · helper 90/90 · D-7 pin 0/11 · P-1 pin 0/6 · P-2 all verdicts · syntax ×9 clean.
No `xcodebuild test` run was owed: the diff is Tools-only — zero Swift app/package source files changed, so
the suite baseline is the previous closeout's (the stage batch rule's letter, confirmed against the
changed-files list). canon-size after the delta: **126,190 / 150,000 (headroom 23,810)**. MOBILE PARITY:
nothing mobile-visible.

## Debris (done at the retirement, after the merge)

One more cmp of the live slot at zero instances, then: `Variorum-dev-safety-vx623walk` and the walker debris
(libraries 3f3d9fb8 · 918e9672) deleted; `DerivedData/vx623*` + the walk evidence folders deleted (the 13x
ruling: the record is the evidence of record); the `.env.supabase.local` symlink dies with the worktree;
branch deleted on GitHub and locally.
