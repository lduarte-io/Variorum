# VX-623 — Run: the first-run walk resets its own test account

**STATUS: OPEN (kicked off 2026-10-27, /architect-phase; the orchestrator is a Fable architect session).**
Branch `vx-623-walk-self-reset` · worktree `~/dev/variorum-vx-623` · the Pro. PR takes this number.
Members BY THE SUB-ISSUE LISTING (re-listed at kickoff, 2026-10-27 19:06Z; re-list again before the ladder):
**VX-622** (cleanup leg + window-frame guard) · **VX-537** (join arm + capture every window of the pid).
Rider offered at kickoff: **VX-536** (guard.sh's on-this-Space check silently passes where its compiled wl2
helper is absent) — her answer pending below.

The 13b constitution (P-1…P-9, `.claude/skills/architect-phase/SKILL.md`) binds this run by reference, with
its applying precisions; this run's diff is Tools-only (no app code), so the registry/surface rules have no
new sites — P-7 (find bugs before she does; red-on-old absolute) and P-8 (standing law) are the live ones.
CLAUDE.md's standing rules bind throughout. Where this file is silent, the skill and CLAUDE.md speak.

## Her standing ruling (2026-10-27, to oct26coordinator — the run's charter)

"I want to give a standing ruling that the walk may reset its own allowlisted test accounts."
Scope: ONLY the walk's own ALLOWLISTED vxtest accounts (`~/.variorum/prod-test-accounts.env`); her own
account can never pass; production stays read-only everywhere else (`Tools/prod-read.sh`) except at her
hand. The ruling lands in canon at this run's merge in the two-file shape (CLAUDE.md's Environment
prod-test-road sentence gains the reset exception + this file as pointer; the dated narrative to
`notes/AppSpecRecord.md`).

## Her kickoff words (2026-10-27, the kickoff message — verbatim)

"This item was added so that hand fix after each walk and the need for an every time removal would end.
if you think that there's an issue with the premise of the ticket or that it would weaken the walks,
please let me know. send messages to oct27coordinater"

## The premise assessment (the orchestrator's, at her ask — recorded before any build)

**The premise is sound.** The hand reset is a real recurring cost (0.10.2 took the castle stand-in;
0.10.3 took two Management-API resets at her word mid-gate), it is already her-sanctioned by the standing
ruling, and scripting it changes WHO types the recorded statement, not what happens. The state it leaves —
account exists, confirmed, no vault — is a real product state (a user who signed up and never turned on
sync), so the set-up arm keeps testing truth, not a synthetic fixture.

**It does not weaken the walks, provided three fences (all binding on this run's design):**
1. **Never reset after a STOP.** The reset runs as a PRE-STEP (heal a leftover vault before the set-up arm)
   and as a CLEANUP LEG after a PASS only. A stopped walk's production state is diagnostic evidence; wiping
   it would weaken the walk. The next run's pre-step clears it after the diagnosis.
2. **The reset helper carries the walk's own guard rigor** — the G1/G2 shape verbatim (allowlist file checks,
   account ∈ {std, castle, del}, every entry vxtest-marked, the address plain and matched whole, listed),
   plus: the resolved auth user's email must equal the allowlist's entry, before/after reads are logged, and
   any doubt refuses. A `--self-test` proves the refusals over fixtures, like the walk's own.
3. **The evidence is logged before the cleanup runs** — P8's server reads land in the walk log first, so
   nothing of the PASS's proof is lost to the reset.

**Net effect on walk strength: positive.** Today's gate exercises the set-up arm only, after her hands fix
production; with this run the gate needs no hands AND gains the join arm ("Sync this library…"), which no
release gate has ever exercised live.

**Kickoff check #1, ANSWERED: the in-app account-deletion door EXISTS.** VX-439's tail searched the signed-in
Protection pane only (join + sign-out — a true dead end THERE). The door lives on the main window's
**Account… → Delete Account…** (password + typed "DELETE MY ACCOUNT"), proven live in VX-510's LEG D
(21:10:00, `road: deleteAccountHere`, prod after: auth user 0 · vault 0 · every row gone). So no gap ticket.
Whether the GATE should use that door per release (delete + re-mint through Create an account… + the PAT
confirm) or the headless recorded reset is a design fork — HER CALL at the kickoff sitting (Q1 below). The
orchestrator's recommendation: the headless reset for the gate (fewer GUI steps in gate plumbing = fewer
flakes; the reset is idempotent and heals aborted runs headlessly; the deletion and creation doors keep
their live coverage in lifecycle drills, where they already run), with the ticket's "prefer the app's road"
preference honestly surfaced rather than silently overridden.

## The kickoff sitting (2026-10-27 — questions put to her; her answers land here VERBATIM)

- **Q1 — the reset road: "Headless reset" (her pick, 2026-10-27, the kickoff sitting's question tool —
  the recommended option).** The gate uses the guarded Management-API statement as pre-step and cleanup;
  the deletion/creation doors keep their live coverage in lifecycle drills. The ticket's "prefer the app's
  road" preference was surfaced to her with the door's location and is RESOLVED by this pick.
- **Q2 — the gate's scope: "Both arms" (her pick, same sitting).** Set-up → join → cleanup every release;
  arms stay individually addressable (`--arm setup|join|both`, default both).
- **Q3 — rider VX-536: "Join this run" (her pick, same sitting).** Seated as a sub-issue; D-7 binds.

**The stage protocol (oct27coordinator, received at kickoff, 2026-10-27):** REQUEST early (what · minutes ·
claim name) → a separate READY ping → GO only from the coordinator with the exact claim line — never
self-claim, a FREE stage is no invitation; tell the coordinator BEFORE any renew; RELEASE runs
`Tools/stage release --who <claim>` then one result line naming each arm's outcome, the dev-store posture,
instance + sim state (strict forms `pgrep -lx Variorum` · `pgrep -lf "MacOS/Variorum$"` ·
`xcrun simctl list devices booted`), which allowlisted accounts were reset and their end state, and
EXECUTED test counts where tests ran. Every `xcodebuild test` needs the stage; headless never does. The
walk REQUEST must name the accounts reset and the helper's refusal shape; G7 is a whole-folder rename of
the as-found set with a cmp-verified safety copy first, restored exactly as VX-439's tail ran it; Debug
prefs re-exported and diffed if touched; secrets only via the `~/.variorum/bin` helpers; the throwaway
Supabase project is GONE (she deleted it) — nothing may target it; What's New dismissed after any Debug
launch. The coordinator's heads-up: the cleanup leg's end state (std clean) may serve a release window
right after the merge — answered at the acceptance result line.

**The cast (stated, hers to redirect):** the standing default — this Fable session orchestrates and
architect-rules; ONE `opus-implementer` session builds the script work; a fresh `fable-reviewer` runs the
ladder (the diff is a production-write tool — Fable judgment kept deliberately, though no editor seam,
`Sync/` or custody line is touched); the LIVE acceptance walk is driven by an OPUS walker under a held
stage claim (the R-510-5 precedent + the coordinator's brief: live walks and simulated input go to Opus).

## The design (the architect's; D-rows are the implementer's brief sections)

- **D-1 — the reset helper** (`Tools/prod-reset-test-account.sh`, a sibling of `Tools/prod-read.sh` and
  `Tools/prod-confirm-test-user.sh` — the prod-tooling family's home, calling the same
  Management-API endpoint `Tools/prod-read.sh` reads through): resets ONE allowlisted account to
  "exists, confirmed, vaultless, rowless" with the VX-439 release-tail statement — one atomic CTE mirroring
  `account_purge()` MINUS the auth user and the entitlement: the key_vault row, the data tables, device
  cursors, tenant seq, challenge nonces, write budget, the `kp:` proof secret (best-effort, the purge's own
  shape). Guards: the fence rules above (premise fence 2). Before/after reads printed and logged. Exit 5 on
  any guard, nothing written. `--self-test` over fixtures; `--dry-run` prints the plan + the before reads.
  *(Q1 ruled headless — this row stands as written.)* **The allow rule (R-510-3's shape, PROPOSED to her at
  the kickoff reply, hers to add or to have the orchestrator add at her word):** one narrow Bash rule for
  `Tools/prod-reset-test-account.sh` beside the five standing walk rules in `.claude/settings.local.json`,
  so the acceptance walker can run the guarded helper without an interactive prompt. **GIVEN — her word
  2026-10-27: "go ahead on that tool." Added by the orchestrator (the R-510-12 precedent) as three lines in
  the standing form: `Bash(Tools/prod-reset-test-account.sh *)` + the main checkout's and this worktree's
  absolute forms. The helper's own R1–R4 guards are the fence that makes the rule safe (its header says so).**
- **D-2 — the walk's two new seats:** a PRE-STEP after P3 (the account's id is in hand): if a vault row
  exists, run D-1's reset (logged); the set-up arm then always meets a vaultless account. A CLEANUP LEG
  after P8's reads land on a PASS: reset, leaving the resting state. On a STOP: never (fence 1).
- **D-3 — the JOIN ARM (VX-537):** after the set-up arm's PASS, the walk quits its instance by identity,
  sets the walk library aside (the slot dance it already documents), relaunches fresh → a fresh library →
  sign in → **"Sync this library…"** → the account's passphrase (the typing helper; the passphrase the
  set-up arm just set from the env file) → the join sheet's confirm ("Synced. Your account's writing is in
  this library now." — the label read from the CURRENT code at build time, never from a record; VX-526's
  wording ticket may move it) → the row reads Synced → server reads: cursors +1, vault revision unchanged
  (a same-posture join changes no account lock — the third orchestrator's Castle-leg precedent). Arms are
  addressable (`--arm setup|join|both`); the release gate's default per Q2.
- **D-4 — the WINDOW-FRAME guard (VX-622):** before P1's launch, normalize the dev build's autosaved main
  window frame (the implementer traces the autosave key in the dev defaults domain and deletes it, so the
  window comes up at its default size), then after launch assert the footer row's window bounds are sane
  before any act. Restore nothing (the dev store's frame is walk state, not hers).
- **D-5 — CAPTURE EVERY WINDOW (VX-537):** `capture()` shoots every on-screen window of the pid (the
  `capture-windows.swift` listing road), named `<step>-<label>-w<n>`, window-scoped always (the standing
  privacy rule: never full-screen).
- **D-6 — the release checklist row:** `Tools/Release/release.sh`'s HANDOFF step-0 text names the walk's
  new shape (self-resetting; the arms per Q2), so no release REQUEST needs the "manual std reset" line
  again. The coordinator's standing brief line retires at the merge (said in the handoff).
- **D-7 — rider VX-536 (SEATED, Q3):** `guard.sh`'s on-this-Space check refuses, with a naming message,
  when its wl2 helper is absent — compile-or-refuse, never silently pass. Pin: a self-test/fixture case
  proving the refusal fires with the helper absent (red on the old silent-pass behavior).

**What this run never touches:** app code, `Sources/`, the schema, the mirror, custody, the dev store's
HELD library (e11e5233 — any walk restores it as found, never presses Resume), her account (cannot pass the
allowlist), her `/Applications` app (G4/G5 stand).

## Acceptance units + evidence (named before the first spawn — the sizing rule)

- **UNIT 1 (one `opus-implementer` session): the script work** — D-1…D-7 as ruled. Evidence of its kind:
  the walk's and the helper's `--self-test` green (every refusal firing over fixtures); `--dry-run` guard
  walk green; shellcheck-clean where the repo uses it; NO live production act by the implementer (the
  walk script's own birth rule: written and dry-checked, never run against production by its author).
- **UNIT 2 (the orchestrator + an Opus walker, under a stage claim through oct27coordinator): the LIVE
  acceptance** — one full std gate on production: pre-step reset heals the standing vault (std holds one
  today — run 3's completed set-up) → set-up arm PASS → join arm PASS (per Q2) → cleanup leg leaves
  vaultless → before/after reads logged. The use-shaped gate: the next release's step 0 needs NO hands.
- **The ladder:** one fresh `fable-reviewer` over the run's whole diff after unit 2's evidence lands;
  pin-before-fix PER MEMBER where a pin is expressible (the guard refusals are the pins' shape here —
  self-test cases red-on-old where a guard was missing).

## UNIT 1 — THE BRIEF (a fresh `opus-implementer`, one session; the implementer owns its LIVE STATUS below)

**Workspace:** `~/dev/variorum-vx-623` (branch `vx-623-walk-self-reset`, upstream set). Run EVERYTHING from
this absolute path. Commit per coherent piece with NO attribution trailer of any kind, push after every
commit, keep the LIVE STATUS section current in the same commits
(`notes/SessionResiliencyProtocol.md` binds you — read it).

**Required reading, in order, before any edit:** (1) THIS FILE WHOLE; (2) `Tools/WalkKit/first-run-walk.sh`
whole — its guard style, helpers and step grammar are the house style every change must match; (3)
`Tools/WalkKit/README.md` whole (walker facts; the capture privacy rule); (4) `Tools/prod-read.sh` and
`Tools/prod-confirm-test-user.sh` (the Management-API call shape and the allowlist-guard shape to mirror);
(5) `notes/plans/fixes/vx-439-sidebar-bar-export-quick-wins.md` lines 1229–1279 (THE RELEASE TAIL — the
reset statement's content and the before/after read discipline); (6) `notes/plans/fixes/vx-510-first-run-sync.md`
lines 3096–3220 (THE SUCCESSOR'S RE-WALK + THE THIRD ORCHESTRATOR'S CASTLE LEG — the join door driven live:
labels, the sheet's confirm line, cursor evidence) and lines 2550–2577 (LEG D); (7) `Tools/WalkKit/guard.sh`
(D-7's target). **Label truth comes from the CODE, not the records:** before writing the join arm's probes,
read the join sheet's current source (the protection pane / account faces under `App/Variorum/` and
`Shared/` — grep for "Sync this library" and the join confirm sentence) and use the exact current strings;
note each sourced label in your record with its file:line.

**Build D-1…D-7 exactly as ruled.** Shape notes, binding:
- The reset STATEMENT is one atomic CTE mirroring `account_purge()` minus the auth user and the entitlement.
  Read `account_purge()`'s definition from the repo's server artifacts (`Server/supabase/` — grep for
  `account_purge`) and derive the family from IT, never from memory; the helper takes the account's id from
  its own guarded email→id read (the same whole-value plain-address splice rule as the walk's P3 — F-R1-5).
- The helper and every walk change REFUSE by default: any guard failure is exit 5 with nothing written,
  matching the walk's grammar. The helper additionally refuses when the resolved auth row's email does not
  byte-equal the allowlist's entry for the named account.
- `--self-test` for the helper mirrors the walk's: fixtures only, every refusal shown firing, never her file,
  never production. EXTEND the walk's own `--self-test` for any new guard you add to the walk.
- The walk's new arms ride the existing step grammar (`step/press/focus/secret/waitfor/rowreads/capture`);
  the join arm's relaunch reuses the slot-aside discipline ALREADY DOCUMENTED in the walk's header (G7's
  files go aside by `mv` — in the LIVE walk that act is the walker's, so the join arm STOPS with a named
  message telling the walker what to move when the slot is occupied, exactly as G7 refuses today; the walk
  script itself never moves the dev store's files).
- D-4 (window-frame): trace the dev build's window-frame autosave key by inspection (`defaults read
  io.lduarte.Variorum.debug | grep -i frame` is the starting probe — note what you find); the guard deletes
  only that key, pre-launch, and post-launch asserts the main window's bounds hold the footer row.
- D-5 (capture every window): follow `capture-windows.swift`'s listing road; window-scoped only.
- **NEVER run anything against production.** No invocation of `prod-read.sh`, the new helper (outside
  `--self-test`), or the walk beyond `--self-test`. The live run is UNIT 2's, under a stage claim you will
  not hold. You need no stage: your evidence is headless.
- **Evidence to record:** both self-tests green with every case named; the D-7 fixture pin red-on-old
  (demonstrate the old silent pass with a one-line revert note); `zsh -n` clean on every changed script;
  each D-row's acceptance stated with file:line.

### UNIT 1 — LIVE STATUS (the implementer owns this section)

**Not done by this unit (by design): no production act of any kind** — no `Tools/prod-read.sh` invocation, no reset
helper run outside `--self-test`, no walk run beyond `--self-test`; no stage claim, no Variorum launch, nothing written
under `~/Library/Containers` (one read-only `defaults read` probe of the dev domain for D-4, as the brief names it).

Started 2026-10-27 by the UNIT 1 `opus-implementer` session. Required reading done in the brief's order (this file;
`first-run-walk.sh`; WalkKit README; `prod-read.sh` + `prod-confirm-test-user.sh`; vx-439 1229–1279; vx-510 3096–3220
and 2550–2577; `guard.sh`), plus `account_purge()`'s latest body (`Server/supabase/13_phase13i_wings.sql:851-922`) and
the join sheet's current source (`RoadAccountSheet.swift`, `ProtectionWords.swift`).

| Piece | Row | Status |
|---|---|---|
| 1 | D-7 — guard.sh compile-or-refuse + its red-on-old pin | DONE (this commit) — see "D-7 evidence" below |
| 2 | D-1 — `Tools/prod-reset-test-account.sh` + `--self-test` (incl. the `account_purge()` drift pin) | DONE (this commit) — `--self-test` 85/85 green; see "D-1 evidence" below. `--dry-run` and any live run are UNIT 2's (both read production) |
| 3 | D-5 — capture every window of the pid (+ the words guard before any capture) | DONE (this commit) — see "D-5 evidence" below |
| 4 | D-4 — the window-frame guard (autosave key deleted pre-launch; bounds asserted post-launch) | DONE (this commit) — see "D-4 evidence" below |
| 5 | D-2 + D-3 — the pre-step, `--arm setup\|join\|both`, the join arm, the cleanup leg | DONE (this commit) — see "D-2 + D-3 evidence" below; READINGS R-U1-3…R-U1-5 flagged for the architect |
| 6 | D-6 — release.sh HANDOFF step 0 + README | DONE (this commit) — step 0 names the self-resetting, both-arms walk; the WalkKit README carries the walk's new shape, the reset helper, `walk-cap`'s new arguments, the words guard and guard.sh's exit 8 |
| 7 | Final evidence: both self-tests' case lists, D-7 red-on-old, `zsh -n`, each D-row's acceptance (file:line) | DONE (this commit) — see "UNIT 1 CLOSED" below |

**UNIT 1 CLOSED — the script work, headless evidence complete (2026-10-27).** The tip this table describes is the commit
that carries it (on top of `be0435bed`). Commits, in order: `b090395e4` LIVE STATUS opened · `80eafaa06` D-7 ·
`9a71189e6` D-1 · `5454a0b09` D-5 · `9935050cf` D-4 · `e2bb002c1` D-2 + D-3 · `be0435bed` D-6 · this flip.

| Row | Acceptance (headless — the live acceptance is UNIT 2's) | Where |
|---|---|---|
| D-1 | the reset helper: guards R1–R4 (exit 5, nothing written), the one atomic CTE, the after-read always, exit 0/4/5; `--self-test` **85/85** | `Tools/prod-reset-test-account.sh` — R1 `guard_allowlist` :63 (refusal :391) · R2 :392 · R3 `id_sql` :85 + resolve in `PY_LIB` :115 (refusal :398) · R4 :402 · `counts_sql` :88 · `reset_sql` :103 · `at_rest` :170 · `after_verdict` :180 · `prodwrite` :191 · already-at-rest :408-412 · the write :418 · the verdict :426 · `--self-test` :201 |
| D-2 | the PRE-STEP after P3 (not at rest → reset; its id = P3's) and THE CLEANUP LEG after the last arm's PASS, behind E1 sign-out + E2 quit; a STOP never resets | `Tools/WalkKit/first-run-walk.sh` — `reset_account` :618 · P3r :647 · `stop()` :479 · E1 :776 · E2 :784 · E3 :787 · G8's helper check :407 |
| D-3 | `--arm setup\|join\|both` (default both); J1 quit → J2 the walk's own library aside (provenance-proven) → J3 relaunch → J4–J8 the join, cursors +1 with the lock unmoved | `first-run-walk.sh` — `arm_valid` :154 · `turnon_library` :157 · `keyfile_library` :163 · `aside_verdict` :173 · `aside_own_slot` :185 · `join_ready` :204 · `join_verdict` :212 · SLOT_AT_G7 :405 · `quit_walk_app` :605 · `open_protection` :589 · J1 :706 · J2 :709 · J4 :720 · J5 :733 · J6 :738 · J7 :746 · J8 :768 |
| D-4 | the main window's frame-autosave keys deleted pre-launch (zero instances), its bounds asserted inside a display's visible frame post-launch, before any act | `first-run-walk.sh` — `frame_keys` :132 · `rect_inside` :140 · `frame_reset` :521 · `frame_check` :533 · both run inside `launch_on_road` :541 (P1/J3) |
| D-5 | every on-screen window of the pid, window-scoped, `<time>-<step>-<label>-w<n>.png`, behind the words guard (fail-closed) | `first-run-walk.sh` `capture()` :469 · `Tools/WalkKit/capture-windows.swift:1-5` (prefix, `--every-layer`) · `Tools/WalkKit/words-guard.swift` (+ `--classify`) |
| D-6 | the release handoff's step 0 names the self-resetting both-arms walk; no manual reset line owed | `Tools/Release/release.sh:323-330` · `Tools/WalkKit/README.md` (the first-run walk section, the helpers) |
| D-7 | guard.sh compiles `wl2` or refuses (exit 8); RED ON OLD 6/11 → GREEN 11/11 | `Tools/WalkKit/guard.sh:22-26, 33-35` · `Tools/WalkKit/pins/guard-space-helper.zsh` |

**Evidence, run fresh at the tip:** `zsh -n` clean on `first-run-walk.sh`, `prod-reset-test-account.sh`, `guard.sh`,
`pins/guard-space-helper.zsh`; `bash -n` clean on `release.sh`; `swiftc` compiles `capture-windows.swift`,
`words-guard.swift`, `wl2.swift`. **The walk's `--self-test`: 64/64** (G1/G2 × 13 + the handed value × 1 — unchanged —
plus D-5 × 10, D-4 × 12, D-2/D-3 × 28: every case named in the D-rows' evidence above). **The helper's `--self-test`:
85/85** (named in "D-1 evidence"). **The D-7 pin: 0 failing of 11; against `b090395e4`'s guard.sh, 6 failing of 11**
(case 1 verbatim: `GUARD OK (, idle 99s)` with wl2 absent). shellcheck is not installed on this Pro and the scripts are
zsh (outside its grammar) — `zsh -n` is the syntax gate.

**PENDING (not this unit's — UNIT 2's live acceptance under a held stage):** every GUI label of the join arm and the
end (J4–J8, E1–E2, `close_settings`, the "Settings…" menu road) meeting the real window for the first time; the reset
statement's first live run (the pre-step against std's standing vault, then the cleanup); `--dry-run` of both scripts
(each reads production or needs the stage); the D-1 allow rule for `Tools/prod-reset-test-account.sh` (hers to add,
or the orchestrator's at her word). The LEDGER's row 3 is the orchestrator's to flip.

**AWAITING THE ARCHITECT'S RULING (each built, each a small change if overruled):** R-U1-1 (the `kp:` secret strict
inside the atomic statement) · R-U1-2 (the reset fires when NOT AT REST, a superset of "a vault exists") · R-U1-3 (the
walk renames ONLY a slot folder it proves its own between the arms, else stops naming the `mv`) · R-U1-4 (sign out and
quit before the cleanup leg) · R-U1-5 (the join arm walks Standard only).

**An observation outside this unit's surface (not touched; a ticket candidate for the triage):**
`Tools/VisualWalk/pins/guard-order.zsh` reads **7 failing of 9** on this tip, on the pre-change tree (`b090395e4`)
and on `origin/main` alike — its "author present → no osascript" cases now count the `key up shift` belt that
`vw_abort` gained at `3723268b6` (18l-c U7), after the pin was last set (`d019f170b`). No file under `Tools/VisualWalk/`
is in this run's diff.

**D-7 evidence (VX-536).** The traced mechanism: `guard.sh`'s full check ran `win=$("$S"/wl2 $pid)`; `Tools/WalkKit/wl2`
is gitignored, so a fresh worktree has none; the call printed "no such file" to stderr and left `win` EMPTY, which matched
no refusal arm (`case "$win" in offscreen)`), so the check printed `GUARD OK (, idle Ns)` on a window it never looked at.
The fix (`Tools/WalkKit/guard.sh:17-34`): compile `wl2` from `wl2.swift` when absent or older than its source (before the
frontmost read), REFUSE with exit 8 naming the helper when it cannot be had, and refuse (8) any answer that is neither
`offscreen` nor `onscreen X Y W H`. The pin `Tools/WalkKit/pins/guard-space-helper.zsh` (headless — the guard copied into
a temp WalkKit folder per case, pgrep/ioreg/osascript/swiftc PATH-shimmed and checked to shadow before any case):
- **RED ON OLD** (`zsh Tools/WalkKit/pins/guard-space-helper.zsh` against `b090395e4`'s guard.sh, via
  `git show b090395e4:Tools/WalkKit/guard.sh > $T/old.sh`): **6 failing of 11** — case 1 read verbatim
  `FAIL helper absent, no wl2.swift → refuse (8), naming wl2 — exit 0 (want 8) … no such file or directory: …/wk/wl2 |
  GUARD OK (, idle 99s)`; cases 2–6 the same class (no compile ever attempted; empty/nonsense answers passed).
- **GREEN ON THE FIX: 0 failing of 11** — the 11 cases: helper absent + no source → 8 · absent + compile fails → 8 ·
  absent + compiles → compiled, 0 · older than its source → recompiled · answers nothing → 8 · answers nonsense → 8 ·
  current, on this Space → 0 · offscreen → 6 · a point inside → 0 · a point outside → 7 · `--author` with no helper → 0,
  nothing compiled.

**D-1 evidence — `Tools/prod-reset-test-account.sh <std|castle|del> [--dry-run] [--log <file>] | --self-test`.**
Guards R1–R4 (exit 5, nothing written): R1 = the walk's G1/G2 VERBATIM (`guard_allowlist`, `plain_address`); R2 =
`Tools/prod-read.sh` + `.env.supabase.local`; R3 = the guarded email→id read — exactly one auth user, its email
BYTE-EQUAL to the allowlist's entry, a lowercase-UUID id (the only value any statement splices); R4 = the before-read
parses whole. Every read goes through `Tools/prod-read.sh`'s SELECT-only fence; the ONE write is the helper's own curl to
the same endpoint and pinned ref, the token fed on stdin (`-H @-`), never in argv. Already at rest → nothing written;
`--dry-run` → the plan and the before-read; else the one statement, then the after-read ALWAYS (exit 0 at rest · 4 not at
rest, with the reason · 5 refused). Before/after lines are printed and appended to the log (default
`App/Variorum/DerivedData/prod-reset/<UTC>-<account>.log`, gitignored; the walk passes `--log` into its run folder).
- **The statement** (`reset_sql`): ONE data-modifying CTE — the 21 data tables, `device_cursor`, `purged_row`,
  `sync_tenant_seq`, `key_proof_challenge`, `sync_write_budget`, `vault.secrets` `kp:<id>`, `key_vault` — derived from
  `account_purge()`'s latest body (`Server/supabase/13_phase13i_wings.sql:851-917`: `data_tables` 856-861, the server
  deletes + the secret + the vault 890-901) minus `entitlement` and `auth.users`.
- **READING R-U1-1 (the implementer's, flagged for the architect — built, one line to change):** the `kp:` secret is
  deleted INSIDE the atomic statement and the after-read DEMANDS kp 0, rather than best-effort. Traced: the purge may be
  best-effort because its uuid dies; a reset KEEPS the uuid, and a surviving `kp:<id>` makes the next set-up's
  `key_proof_enroll` raise `VARIORUM_KEY_PROOF_ALREADY_ENROLLED` (`12_phase13y_tenant_seq.sql:611-615`) — the loser
  "proceeds", and every later proof is then checked against the OLD master's kp2. "Best-effort" cannot be expressed
  inside one atomic CTE anyway; the VX-439 tail's statement evidently deleted it (run 3's fresh enrollment PASSED). If the
  role ever lacks the vault privilege the statement refuses whole — nothing written, exit 4 named — fail-closed.
- **READING R-U1-2 (likewise):** the helper resets when the account is NOT AT REST (any family row, not only a vault
  row), and writes nothing when it is — a superset of D-2's "if a vault row exists", so P8's cursor/row evidence can
  never be satisfied by rows a half-cleaned account carried in (e.g. a leftover `kp:` or cursor with no vault).
- **`--self-test`, 85 cases, green** (fixtures only; `prodread`/`prodwrite` replaced by tripwires that exit 99):
  R1 × 13 (the walk's own G1/G2 cases: good std · good castle · unknown account · mode 644 · unmarked entry · empty list
  · not listed · a link · no file · a quote · uppercase · a newline · the plus-address-with-digits shape) + R1's twin pins
  × 2 (`guard_allowlist` and `plain_address` byte-identical to `first-run-walk.sh`'s) · R3 × 11 (one auth user equal →
  the id · email differs by case · another address · a trailing space · no auth user · two auth users · an uppercase id
  · an id with a quote · an error answer · not JSON · a non-plain address refused at the splice) · R4 × 13 (clean → at
  rest · a vault + rows → not at rest · the summary line exact · a `kp:` alone not at rest · challenges alone not at rest ·
  a `purge_intent` row alone not at rest · no auth user not at rest · a missing count · a non-integer · a boolean · an
  unreadable vault_mode · two rows · an error answer) · AFTER × 5 (at rest → ok · auth user gone · entitlement changed ·
  `kp:` survived, named · a data row remains) · SQL × 33 (one statement, a CTE · each of the 26 owner tables deleted
  exactly once · the `kp:` secret and the vault once each · exactly 28 deletes · never `auth.users`/`entitlement` · the
  id spliced exactly 28 times and no other quoted value · a non-UUID id builds nothing · the counts read passes
  `prod-read.sh`'s OWN fence, its regex read from the file) · DRIFT × 7 (the latest `account_purge()` found · its
  `data_tables` = ours exactly · its owner deletes = ours exactly · it deletes `key_vault`+`entitlement` by user_id — we
  keep only the entitlement · it deletes `auth.users` by id — we keep it · it deletes the `kp:` secret — so do we · no
  maintenance file redefines it) · the network never reached × 1.
- **The pins bite (mutation runs on a temporary copy, deleted):** `purge_intent` dropped from the family → DRIFT data
  FAIL (+ the R4 case); one word changed in the guard → R1 twin FAIL; the `kp:` CTE removed → three SQL cases FAIL.

**D-5 evidence (VX-537's capture half).** `capture()` (`Tools/WalkKit/first-run-walk.sh`, the `capture()` definition)
now shoots EVERY on-screen window of the pid through `capture-windows.swift`'s listing road
(`Tools/WalkKit/capture-windows.swift` gains an optional name prefix and `--every-layer` — every layer the pid owns,
slivers under 48 pt skipped; its two-argument layer-0 behaviour, which the castle lib uses, is unchanged), each
`screencapture -x -o -l <id>` (window-scoped, never full-screen), named `<HHMMSS>-<step>-<label>-w<n>.png`, the listing
appended to the run's `captures.txt`. **The privacy consequence, owned:** capturing Settings and its sheets means a STOP
while the twelve-words look is up (P5: between "Record your twelve words…" and "I've written them down") would capture
the words. So every capture first runs the WORDS GUARD — `Tools/WalkKit/words-guard.swift`, VX-502's live-proven Castle
guard (twelve lowercase words, or the look's markers, re-read from the current code: `ProtectionWords.swift:679, 694,
696`) — and is WITHHELD (logged, never taken) when it says so or fails to answer. Its new `--classify <text>` mode makes
its teeth headless: the walk's `--self-test` gains 10 D-5 cases (withholds: twelve words · padded twelve · the look's
button · its warning · its reveal door; lets through: eleven words · thirteen · the join's landed line · the join's
words notice; a pid it cannot read → withheld). Both helpers compile in the walk's G9 beside the vis-* helpers.

**D-4 evidence (VX-622's window-frame guard).** THE TRACE (by inspection, read-only): the brief's probe
`defaults read io.lduarte.Variorum.debug | grep -i frame` found, among the dev domain's 2,378 keys, ONE main-window
frame autosave — `"NSWindow Frame variorum-main-AppWindow-1" = "60 144 1240 940 0 0 1728 1084"` — beside the note
window's, Settings', the helper/about/quick-note panels' and the split views' (left alone). Its source: SwiftUI autosaves
a WindowGroup's frame as `NSWindow Frame <id>-AppWindow-<n>`; the main group's id is `"variorum-main"`
(`EditorCommands.swift:1191`, the group at `VariorumApp.swift:62`, `.defaultSize(width: 1240, height: 840)` at `:94`).
THE GUARD (`first-run-walk.sh`): `frame_reset` runs PRE-LAUNCH (zero instances — after G5, and before every relaunch)
and deletes exactly the keys matching `NSWindow Frame variorum-main-AppWindow-[0-9]+` (whole-key, `defaults export … -`
parsed with plistlib), then proves none remain; nothing is restored. `frame_check` runs POST-LAUNCH in P2, before any
act: the pid's main window (vis-win) must lie inside ONE display's visible frame (NSScreen via JXA — no events — menu bar
and Dock excluded, 2 pt slack) and be at least 640×400; else it captures and STOPS naming the frame and the displays
(fail-closed with no geometry). The display read was validated once on this Pro: `0 33 1728 1084`. The walk's
`--self-test` gains 12 D-4 cases (the key filter picks exactly AppWindow-1 and -2 out of nine look-alikes · an empty
domain → none · the default window centred → holds · the probe's autosaved frame → holds · bottom past the visible frame
→ refused · off the left edge → refused · taller than the display → refused · a 600×300 sliver → refused · wholly on a
second display → holds · straddling two → refused · no display geometry → refused · no window frame → refused).

**D-2 + D-3 evidence (VX-622's cleanup leg, VX-537's join arm).** `first-run-walk.sh <account> [--arm setup|join|both]`
(default `both`, her Q2), the legs as functions, the arms composing them:
- **setup:** P1–P2 (launch, road, frame) → P3 (the id) → **P3r THE PRE-STEP** (`reset_account prestep` → the D-1 helper,
  its lines into `walk.log`, its log `reset-prestep.log`; exit ≠ 0 STOPS; its resolved id must equal P3's) → P4–P8 as
  before (P8's vault read now logs the revision) → THE END.
- **both:** the set-up arm → **J1** quit by identity (Settings closed first, so the relaunch restores none; our pid
  proven gone; zero instances by path, its own step) → **J2** the walk's OWN library aside → **J3** the window-frame
  guard + a fresh launch on the road (`app-join.log`) → the join arm → THE END.
- **join** (alone — e.g. after a `both` run stopped in the join arm): P1–P3 → the join arm → THE END. No pre-step (it
  would delete the vault the join needs).
- **The join arm:** **J4** the fresh library's row reads the not-yet line — signed in still (the session outlived the
  library, as VX-510's LEG D saw), or `sign_in` (P4's steps, factored) when "Sign in…" shows → **J5** the before-reads
  (vault mode + revision, device cursors) and `join_ready` — the vault must be STANDARD → **J6** Settings ▸ Protection
  ▸ "Sync this library…" → "Your account's passphrase" (the helper's `passphrase` — the value P6 set) → "Sync this
  library" → **J7** the words notice's OK when it shows → "Synced. Your account's writing is in this library now." (≤
  180 s) → Done → the row "Synced" (System Events, VX-621's road) → same pid → **J8** the after-reads and
  `join_verdict`: cursors EXACTLY +1, mode and revision unchanged.
- **THE END (after the last arm's PASS; every read above already in `walk.log` — fence 3):** **E1** sign out
  (Settings ▸ Protection ▸ "Sign out…" → "Sign Out" → "Sign in…" anywhere) → **E2** quit by identity, zero instances →
  **E3 THE CLEANUP LEG** (`reset_account cleanup`). **A STOP never resets** (fence 1): `stop()` exits 4 at once and now
  says so — "production left as it stands — the next run's pre-step resets it".
- **Labels, read from the CURRENT code:** "Sync isn't on for this library yet" `SyncStatusViews.swift:707` ·
  "Sync this library…" `ProtectionWords.swift:1061` (rendered `RoadAccountFaces.swift:341` → `RoadAccountSheet.swift:106`)
  · "Your account's passphrase" `ProtectionWords.swift:870` (`RoadAccountSheet.swift:312`) · "Sync this library" (the
  button) `ProtectionWords.swift:1065` (`RoadAccountFaces.swift:160` → `RoadAccountSheet.swift:193`) · the words notice
  `ProtectionWords.swift:893-897` and its "OK" `:898` (`RoadAccountSheet.swift:210-219`) · "Synced. Your account's
  writing is in this library now." `ProtectionWords.swift:1048` (chosen at `RoadAccountModel.swift:302`) · "Done"
  `ProtectionWords.swift:1058` · "Sync hasn't run yet: …" `ProtectionWords.swift:1053` · "Sign out…" / "Sign in…"
  `ProtectionWords.swift:756-757` · "Sign Out" `ProtectionCopy.swift:119` (`RoadAccountSheet.swift:371`) · the footer's
  "Sign in…" `SyncStatusViews.swift:146` · the road log line `road: turnOnSync — library <id8> now names account …`
  `ProtectionAccountActs.swift:387-390` · the key file `variorum-library-keys.json` `Names.swift:114`, its `libraryID`
  `KeyFile.swift:130` · Settings' window name "Variorum Dev Settings" and the "Settings…" menu road
  (`Tools/VisualWalk/lib.zsh:395-402`, in use there).
- **READING R-U1-3 (the between-arms aside — flagged; the one place the D-row text and the brief's shape note pull two
  ways):** D-3 says the walk "sets the walk library aside"; the brief's shape note says the walk script "never moves
  the dev store's files" and the join arm "STOPS with a named message telling the walker what to move when the slot
  is occupied". Read together: the walk sets aside ONLY its OWN library, and only when it can PROVE it — the slot
  folder was ABSENT at G7 (the coordinator's whole-folder G7 form, so this run made it) AND its key file names the
  library this run's set-up enrolled (the app log's turnOnSync line); then ONE same-volume whole-folder rename to
  `Variorum-dev-walk-<stamp>-setup` beside it, proven by the folder's inode (the "lived here" marker,
  `ProtectionPlaces.swift:61-63`, goes with it, so the relaunch routes `startFresh`, not the library-missing face —
  `Assess.swift:87`). ANY doubt (present at G7, no logged library, another library's key file, the name taken, a link)
  STOPS naming the exact `mv` for the walker, then `--arm join`. The literal alternative — always STOP between the
  arms — would make `both` two invocations every time; it is a one-line change in J2 if the architect rules it.
- **READING R-U1-4 (the end legs — flagged):** D-2 names the cleanup reset only; the walk now SIGNS OUT and QUITS
  before it. Traced: `sync_challenge` mints nonces with NO vault requirement (`12_phase13y_tenant_seq.sql:526-534`), so
  a still-signed-in walk app would write `key_proof_challenge` rows after the reset — the account would not be at rest
  (the helper would exit 4). Signed out is also the Debug app's resting posture (the VX-439 tail signed out and quit by
  hand), so the end needs no hands.
- **READING R-U1-5 (flagged):** the join arm walks only the same-posture STANDARD join (`join_ready`); a Castle account's
  join would enter Castle and offer the Touch ID / Always-ask gate — never walked by this script. `both` always meets
  Standard (the set-up arm sets up in a fresh library's mode).
- **Incidental fix, owned (same file, unpinned — a message-path):** P7's `waitfor "Sync hasn't run yet" 1` was an exact
  match against a line that renders "Sync hasn't run yet: <row sentence>." (`ProtectionWords.swift:1053`), so its
  blocked-round diagnosis never fired; it now matches the prefix (`VIS_AX_PREFIX=1`, as J7's twin does).
- **The walk's `--self-test` gains 28 D-2/D-3 cases** (`--arm` takes setup/join/both · refuses anything else · the
  set-up's library is the app log's LAST turnOnSync line, lowercased · no such line → none · the key file's libraryID
  read · an odd/unreadable/linked key file → none · the walk's own library → aside · present at G7 → STOP · no logged
  library → STOP · another library's key file → STOP · the aside name taken → STOP · no slot folder → STOP · a linked
  slot → STOP · the rename is ONE whole-folder move (slot gone, inode and contents beside it) · the rename never leaves
  the slot's parent · `join_ready`: Standard → ready · Castle → STOP · no vault → STOP · an error answer → STOP ·
  `join_verdict`: +1 with mode and revision unchanged → PASS · cursors unchanged → STOP · +2 → STOP · revision moved →
  STOP · mode moved → STOP · a read that did not answer → STOP · a boolean for a number → STOP · `helper_id` reads the
  helper's resolved id · nothing when the helper refused first). **The walk's self-test now: 64 cases, green.**

## UNIT 1 — THE ORCHESTRATOR'S VERIFICATION AND RULINGS (2026-10-27, after implementer session 1 closed)

**Verified, never trusted (the orchestrator's own runs):** 8 commits `b090395e4`…`2f656ddbc`, zero
attribution trailers; the walk's `--self-test` green ("every guard fired as expected", 64 cases) and the
helper's green (85 cases, the drift pins against `account_purge()`'s own body and the network-never-reached
case among them) — both run by the orchestrator's own hand; the D-7 pin RED-ON-OLD confirmed by the
orchestrator's own run (main's guard: **6 failing of 11**, the silent pass shown; this branch's guard:
**0 failing of 11**); `zsh -n` clean on all four changed scripts; the helper's header and guard order
read and matched to the ruled shape (R1–R4, the resting-state semantics, exit 0/4/5 grammar).

**The readings, adjudicated (the implementer proposed, the architect rules — each APPROVED as built):**
- **R-U1-1 APPROVED.** The `kp:` delete rides inside the atomic statement and the after-read demands kp 0.
  The mechanism is traced (a kept account id + a surviving secret ⇒ ALREADY_ENROLLED at the next set-up
  while proofs check the OLD master's kp2 — `12_phase13y_tenant_seq.sql:611-615`); the VX-439 record's
  "best-effort" described the purge's own shape, not a requirement on the reset.
- **R-U1-2 APPROVED.** The reset fires on ANY family row, not only a vault — P8's evidence must be
  attributable to this run, so the account must be fully at rest before the set-up arm.
- **R-U1-3 APPROVED.** The join arm renames only a slot folder it can PROVE it made (absent at G7, its key
  file naming the library this run's set-up enrolled); anything else stops naming the exact `mv`. The
  brief's "the script never moves files" line protected the DEV STORE's files; the proof condition
  guarantees the folder is not the dev store's, so `both` stays one invocation. The deviation from the
  brief's letter is recorded here with its reason, per the skill.
- **R-U1-4 APPROVED.** Sign out + quit precede the cleanup reset (`sync_challenge` needs no vault —
  a signed-in app would mint challenge rows after the reset and the after-read would read not-at-rest).
- **R-U1-5 APPROVED.** The join arm walks the same-posture Standard join only; `both` meets Standard by
  construction (the set-up arm just minted a standard vault). A Castle join is a lifecycle drill's matter
  (its Touch ID gate is a hands-moment, not gate plumbing).
- **The unpinned P7 prefix-match fix is ACCEPTED** (it changes only which stop message prints); flagged
  for the ladder's reviewer as part of the diff.

**Filed from unit 1's observation: VX-627** (Low · Bug · Confirmed · Tests & tooling, project 12) —
`Tools/VisualWalk/pins/guard-order.zsh` fails 7 of 9 cases on MAIN (reproduced by the orchestrator's own
run on `~/dev/variorum`); traced to `vw_abort`'s key-up-shift belt (`3723268b6`). No VX-623 file touches
VisualWalk; not this run's to fix.

## UNIT 2 — THE LIVE ACCEPTANCE (the script of record, written before it runs; an OPUS walker under the orchestrator)

**The coordinator's conditions (oct27coordinator, accepted 2026-10-27):** the 90-minute claim `vx-623-walk`
includes the FULL restoration and the relaunch proof; a mid-walk stop restores the dev slot FIRST and
reports after (the slot is never left set aside — production's stopped state still stays for diagnosis,
per fence 1: the slot restoration and the production reset are different things); renew only after asking;
the RELEASE line carries arm-by-arm outcome, std's end state, the dev slot's end state (e11e5233 held,
unlocked, signed out, the banner, Resume never pressed), the prefs diff, instance/sim state. **The pause
question, answered: the walk runs UNINTERRUPTED** — the arms are addressable so a split is possible in
principle, but a pause with the as-found slot back would add two extra slot-restoration cycles (the
riskiest manual steps); the coordinator schedules the one window when no merge-gating window is imminent.

**Preconditions (all verified before READY is sent):** the branch build at
`App/Variorum/DerivedData/vx623/Build/Products/Debug/Variorum.app` (G4's shape); her allow-rule word
(or she sits through the prompts); GO received with the exact claim line — the walker NEVER claims or
renews itself; zero instances by the strict forms (`pgrep -lx Variorum` · `pgrep -lf "MacOS/Variorum$"`)
AND the walk's own path form; `xcrun simctl list devices booted` empty.

**The sequence:**
1. Prefs export (`defaults export io.lduarte.Variorum.debug` to the run folder) — re-export + diff at the end.
2. The dev slot: cmp-verified safety copy of the as-found set first, then the WHOLE-FOLDER rename aside (G7).
3. Under the held claim: `Tools/prod-reset-test-account.sh std --dry-run` then
   `Tools/WalkKit/first-run-walk.sh std --app <the vx623 build> --dry-run` — every guard shown holding.
4. The gate: `first-run-walk.sh std --app <the vx623 build>` (default `--arm both`): pre-step reset (std's
   leftover vault from VX-439 run 3 is the expected target) → set-up arm → the join arm's relaunch →
   sign-out/quit → cleanup reset. A What's New sheet after any launch is dismissed before the first act.
5. On PASS: confirm std at rest from the helper's after-read; then the restoration order exactly as
   VX-439's tail ran it — walk slot folders removed BY their key files' library ids, the as-found set
   renamed back whole, cmp/inode-checked, ONE relaunch proving e11e5233 held (OK on the swap notice,
   NEVER Resume; the HELD banner read; signed out; "Sync off (dev store)") → quit by identity.
6. On STOP: captures kept, production UNTOUCHED (fence 1 — the next run's pre-step heals it after the
   diagnosis), the slot restored FIRST (step 5's order), then the report.
7. The orchestrator sends the RELEASE result line; the walker releases nothing itself.

**GO (oct27coordinator, 2026-10-27 18:53):** claim `vx-623-walk` HELD (claimed 18:53:47, 90 min) through the
coordinator's exact bridge line; floor verified by the orchestrator — zero instances (both strict forms),
zero booted sims, the dev slot holding the as-found 11-item set. **The as-found dev store (the coordinator's
word, as the 17:49 vx-562-confirm walk left it; LEG 0 records the ACTUALS before the set-aside):** library
e11e5233 HELD, signed out, Study voice with the APP Appearance set to DARK (macOS is Light — never touch
either), no books, ONE note (Oct-19), Walk Wing empty, MCP server OFF, claude-code approved with 0 grants,
Trash ~65. RELEASE line owes: arm-by-arm, std's end state, slot end state (banner read, Resume never
pressed), prefs diff, instance/sim state, stage.log times.

**Walker constraints (Opus, per the standing precedent):** secrets only via `~/.variorum/bin` helpers;
keys through `keys.sh`, never cliclick text; guarded acts ≥ 2.6 s apart; captures window-scoped only;
her app never launched, quit or typed into; extras killed by proven PID only; every renew request routes
through the orchestrator to the coordinator BEFORE it happens.

### UNIT 2 — THE WALKER'S RECORD (the Opus walker, 2026-10-27 18:55–19:06; the claim `vx-623-walk` held throughout)

**Not done by the walker (by design or left for the orchestrator):** the stage was neither claimed, renewed nor
released (the orchestrator's RELEASE); the LEDGER's row 4 is not flipped (the orchestrator's); the cmp-verified safety
copy `Variorum-dev-safety-vx623walk` is LEFT in the Debug container's Application Support beside the restored slot
(not asked to remove it — the orchestrator's or coordinator's call); the worktree's gitignored `.env.supabase.local`
SYMLINK (below) is left in place; the four walk-made `calmAsks` keys in the dev defaults domain are left (inert, named for
the debris libraries — the prefs diff below). **One deviation, owned:** the worktree had no `.env.supabase.local`, so
LEG 2's first helper dry-run REFUSED at R2 (exit 5, nothing read or written); the walker linked it from main
(`ln -s ~/dev/variorum/.env.supabase.local` into the worktree root — gitignored by `.env.*.local`; no copy, the value
never read or printed), the VX-510 S3 and VX-529 precedent, rather than hand back with the slot set aside (a hand-back
would have cost an extra slot-restoration cycle). Every guard then held.

**Evidence:** the walker's folder `App/Variorum/DerivedData/first-run-walk/walker-vx623-20261027T1856/` (walker.log,
the leg files, prefs-before/after.plist, `caps/` — the relaunch-proof captures, `debris/` — the walk's two libraries);
the gate's own run folder `App/Variorum/DerivedData/first-run-walk/run-20261028T005847Z-std/` (walk.log, 28
window-scoped captures listed in captures.txt, reset-prestep.log, reset-cleanup.log, app.log, app-join.log). Both
gitignored. Captures viewed by the walker: P7 synced-sheet, J7 synced-sheet, J7 synced-row, E1 signed-out, and the
three LEG 5 proofs. The P6/J6 confirm captures were NOT opened (their fields are `PeekableSecretField`, secure by
default — `RoadAccountSheet.swift:311-339`); no capture was taken while the words' look was up (P5 has none between
"Record your twelve words…" and "I've written them down").

- **LEG 0 (18:56) — the actuals.** Floor: `STAGE HELD by 'vx-623-walk'` (claimed 18:53:47, 90 min); zero instances by
  `pgrep -lx Variorum` · `pgrep -lf "MacOS/Variorum$"` · `pgrep -fl 'Variorum.app/Contents/MacOS'`; no booted sims. The
  slot `Variorum-dev` (folder inode 198725396) held the 11 items (Backups · Previous Libraries · three
  `variorum-keys-*.json` · `variorum-library-keys.json` · `variorum-library-lived-here` · `variorum-restore-hold.json` ·
  `variorum.sqlite` + `-shm` + `-wal`), the key file's libraryID **e11e5233**; `prefs-before.plist` (2,439 keys);
  `appearanceChoice` = dark; `variorum.whatsNew.lastVersion` = 0.10.3 = the build's version (no What's New sheet met).
- **LEG 1 (18:57) — safety copy + set-aside.** `cp -Rp Variorum-dev Variorum-dev-safety-vx623walk` (same Application
  Support folder); `cmp -s` over all **197 files: 197 same, 0 differ**, file lists identical; then
  `mv -n Variorum-dev Variorum-dev-aside-vx623walk` — one whole-folder rename, inode 198725396 unchanged, the slot absent.
- **LEG 2 (18:57–18:58) — dry-runs under the held claim.** The helper's first run: `prod-reset-test-account REFUSES:
  R2 — Tools/prod-read.sh or .env.supabase.local is missing` (exit 5) → the link above → re-run, exit 0, verbatim:
  ```
  *[removed for publication]*
  [00:58:01Z] prod-reset std: BEFORE: vault 1 (mode standard, rev 1) · kp 1 · cursors 1 · purged 0 · seq 1 · challenges 35 · budget 1 · data 3 (setting 3) · entitlement 1 · auth user 1
  [00:58:01Z] prod-reset std: DRY RUN — every guard holds. The plan (nothing written): ONE statement deleting this account's 21 data tables, device_cursor, purged_row, sync_tenant_seq, key_proof_challenge, sync_write_budget, its kp: proof secret and its key_vault row — never its auth user or entitlement — then the after-read. It holds 43 family row(s): a real run resets them.
  ```
  The walk's dry run, exit 0: `first-run-walk DRY RUN — every guard holds for 'std', arm 'both' (the slot folder absent
  at G7).` then the P1…E3 plan (in `leg2-walk-dryrun.out`).
- **LEG 3 (18:58:47 → 19:01:33) — THE GATE: `first-run-walk.sh std --app …/DerivedData/vx623/…/Variorum.app`,
  `--arm both`, EXIT 0 — every arm PASSED, no stop, no What's New, no retry.** Verbatim from its walk.log:
  - **The pre-step (P3r) — PASS:**
    ```
    [00:58:57Z] prod-reset std: BEFORE: vault 1 (mode standard, rev 1) · kp 1 · cursors 1 · purged 0 · seq 1 · challenges 35 · budget 1 · data 3 (setting 3) · entitlement 1 · auth user 1
    [00:58:57Z] prod-reset std: RESET — one atomic statement over 43 family row(s)
    [00:58:57Z] prod-reset std: the statement took: data_rows=3 device_cursor=1 purged_row=0 sync_tenant_seq=1 key_proof_challenge=35 sync_write_budget=1 kp=1 vault=1
    [00:58:58Z] prod-reset std: AFTER: vault 0 (mode -, rev -) · kp 0 · cursors 0 · purged 0 · seq 0 · challenges 0 · budget 0 · data 0 · entitlement 1 · auth user 1
    [00:58:58Z] prod-reset std: AT REST — the account exists, confirmed as it was, vaultless and rowless; its entitlement kept
    ```
  - **The set-up arm (P1–P8) — PASS:** P2 `PROD TEST ROAD (VX-510): ARMED`; the frame guard deleted
    `NSWindow Frame variorum-main-AppWindow-1` and the window `60 33 1240 940` held the footer row; P3 `account id
    *[removed for publication]*
    the sheet **"Synced. Your library is on your account now."** (19:00:18, 4 s after the press) → Done → the row
    Synced, same pid. P8: `key_vault: [{"mode":"standard","revision":1,"proof":true}]` · `kp secret: [{"n":1}]` ·
    `device cursors: [{"n":1}]` · `data rows (setting + container): [{"n":3}]`.
  - **The join arm (J1–J8) — PASS:** J1 quit by identity, zero instances; J2 `the set-up arm's library 3f3d9fb8 set
    aside WHOLE → Variorum-dev-walk-20261028T005847Z-setup`; J3 the frame guard, a fresh launch (pid 11939), the window
    `244 155 1240 840`; J4 the row read the not-yet line still signed in (the session outlived the library); J5
    `key_vault before: [{"mode":"standard","revision":1}]` · `device cursors before: [{"n":1}]`; J6 "Sync this library…"
    → the passphrase by the helper → "Sync this library"; J7 the words notice → OK → **"Synced. Your account's writing
    is in this library now."** (19:01:05) → Done → the row **"Synced 7:01 PM"**; J8 `key_vault after:
    [{"mode":"standard","revision":1}]` · `device cursors after: [{"n":2}]` — cursors +1, mode and revision unmoved.
  - **The end (E1–E3) — PASS:** E1 Sign out… → Sign Out → the footer "Signed out · Sign in…"; E2 quit by identity,
    zero instances; **E3 THE CLEANUP LEG:**
    ```
    [01:01:32Z] prod-reset std: BEFORE: vault 1 (mode standard, rev 1) · kp 1 · cursors 2 · purged 0 · seq 1 · challenges 62 · budget 1 · data 3 (setting 3) · entitlement 1 · auth user 1
    [01:01:32Z] prod-reset std: RESET — one atomic statement over 71 family row(s)
    [01:01:32Z] prod-reset std: the statement took: data_rows=3 device_cursor=2 purged_row=0 sync_tenant_seq=1 key_proof_challenge=62 sync_write_budget=1 kp=1 vault=1
    [01:01:33Z] prod-reset std: AFTER: vault 0 (mode -, rev -) · kp 0 · cursors 0 · purged 0 · seq 0 · challenges 0 · budget 0 · data 0 · entitlement 1 · auth user 1
    [01:01:33Z] prod-reset std: AT REST — the account exists, confirmed as it was, vaultless and rowless; its entitlement kept
    [19:01:33] done: PASSED — 'std', arm 'both'; signed out, quit, and the account at rest (exists, confirmed, vaultless, rowless)
    ```
- **LEG 4 (19:02) — std's end state, read.** The helper's dry run, exit 0, verbatim:
  ```
  *[removed for publication]*
  [01:02:07Z] prod-reset std: BEFORE: vault 0 (mode -, rev -) · kp 0 · cursors 0 · purged 0 · seq 0 · challenges 0 · budget 0 · data 0 · entitlement 1 · auth user 1
  [01:02:07Z] prod-reset std: DRY RUN — every guard holds. The plan (nothing written): … It is ALREADY AT REST: a real run writes nothing.
  ```
  plus `Tools/prod-read.sh` → `[{"confirmed":true,"vault":0}]`. Zero instances by all three forms (19:02:07).
- **LEG 5 (19:02–19:05) — the restoration.** The walk's two slot folders identified by their key files' libraryID AND
  the app logs' `road: created — library <id>` lines: `Variorum-dev` = **918e9672** (app-join.log) and
  `Variorum-dev-walk-20261028T005847Z-setup` = **3f3d9fb8** (app.log) → moved whole into the walker's `debris/`
  (`lib-918e9672-join`, `lib-3f3d9fb8-setup`); then `mv -n Variorum-dev-aside-vx623walk Variorum-dev` (19:02:36).
  **`ls -i` against LEG 0: every name, inode, size and mtime MATCHES** (the 11 items + the folder's 198725396); `cmp`
  against the safety copy: 197/197 same. **ONE relaunch**, plain `open -n` (pid 13580; `ps eww` carries no `VARIORUM_`
  variable): the notice "This is a different library than the one this Mac last had open" → **OK** (the only control;
  no Resume targeted) → library e11e5233 open in Study, dark; **the HELD banner, its AX value verbatim: "This is your
  library as of October 20, 2026. This library doesn't sync, so Resume changes nothing in it." — "Resume Sync" NEVER
  pressed**; the footer **"Sync off (dev store)"**; Settings ▸ Protection: "Sign in…" present, "Sign out…" absent →
  **signed out**; Settings closed; quit by identity (19:04:35), the pid gone. After the relaunch the store's mtime and
  its `-wal`/`-shm` changed (any open/quit does that; still 11 items). Zero instances by all three forms (19:04:45); no
  booted sims. **Prefs:** `appearanceChoice` still **dark**; the diff (2,439 → 2,443 keys) is walk state only —
  `NSWindow Frame variorum-main-AppWindow-1` `60 144 1240 940 …` → `244 122 1240 840 …` (D-4, restore nothing),
  *[removed for publication]*
  and four ADDED `variorum.calmAsks.{passphrase….launches, words….recorded}` keys for 3f3d9fb8 and 918e9672.
- **Stage:** `2026-10-27 18:53:47 CLAIMED who=vx-623-walk … minutes=90`; still HELD at the record's commit (~79 min
  left at 19:05); not released by the walker.

## Environment traps (binding; carried into every brief verbatim)

The vx-510 run's traps apply: instance checks by PATH (`pgrep -fl 'Variorum.app/Contents/MacOS'`), her
real-store instance never quit; the stage HELD for every GUI act (G6); the dev slot set aside by `mv`
BEFORE a walk (G7) and restored as found — the HELD library e11e5233, NEVER press Resume; walk captures
window- or region-scoped, never full-screen; secrets typed only by the `~/.variorum/bin` helpers, values
never printed; keys through `keys.sh`, never cliclick's `t:`; guarded acts ≥ 2.6 s apart (the self-trip
rule); quit by identity, kill extras by proven PID; zsh `pipestatus`; push after every commit.

## LEDGER (every row owned; flip per piece, same commit)

| # | Item | Status |
|---|---|---|
| 1 | Kickoff: worktree, in-flight row, Linear flips, this record | DONE (in-flight row on main `VX-623 kickoff`; members In Progress 19:06Z) |
| 2 | The kickoff sitting (Q1–Q3) + her premise answer delivered | DONE 2026-10-27 — headless · both arms · VX-536 seated; premise answer in the kickoff reply |
| 3 | UNIT 1 — the script work (D-1…D-7) | DONE 2026-10-27 (`b090395e4`…`2f656ddbc`; self-tests 64/64 + 85/85 and the D-7 pin red-on-old ALL re-run by the orchestrator; R-U1-1…5 adjudicated APPROVED; VX-627 filed) |
| 4 | UNIT 2 — the live acceptance on production | **DONE 2026-10-27 — the std gate PASSED LIVE** (walker commits `21a7b8b1b` + `a9e5fbd92`; all five arms pass 18:58:47–19:01:33, exit 0, no retry; the claim 18:53:47–19:07:18 by stage.log, ~75 of 90 min; std at rest RE-VERIFIED by the orchestrator's own dry-run read 19:07; the slot restored exactly — 11 items inode-matched, 197/197 cmp-identical, e11e5233 held, banner read, Resume never pressed; RELEASE line sent, the coordinator verified independently). **Walker deviation ADJUDICATED ACCEPTED:** the gitignored `.env.supabase.local` symlink in the worktree root (R2 refused without it; the VX-510 S3 / VX-529 precedent; nothing copied, read or printed; dies with the worktree). **The window-rule prefs tail: the four ADDED keys were the two debris libraries' calmAsks state — deleted at zero instances; the final export reads 0 added · 0 removed vs pre-walk** (the accepted bookkeeping classes remain as value changes only). Closeout owes: one more cmp of the live slot at zero instances, THEN delete `Variorum-dev-safety-vx623walk` + the debris libraries (3f3d9fb8, 918e9672); the symlink's death confirmed in the retirement line. |
| 5 | The ladder (fresh fable-reviewer, whole diff) | ROUND 1 IN FLIGHT — roster re-listed pre-ladder (VX-622 · VX-537 · VX-536, unchanged); findings land in `notes/plans/fixes/vx-623-ladder-round1.md` (`14ad4a09c`: 1 MAJOR · 2 MINOR · 2 NIT). **The implementer's answers landed** in its "ROUND 1 — THE IMPLEMENTER'S ANSWERS" section (all five AGREE; fixes and pins stated; NOTHING applied) — awaiting the reviewer's final call, then the confirmed fixes |
| 6 | Closeout: canon delta (the standing ruling, two-file shape), tickets, handoff, merge | NOT-STARTED |

**Owned at kickoff:** the in-flight-row commit on main carries a `Co-Authored-By` trailer against her
standing no-trailer rule (the harness reminder was followed over CLAUDE.md for one commit; caught at once;
pushed history is never rewritten, so it stands). No later commit of this run carries one.
