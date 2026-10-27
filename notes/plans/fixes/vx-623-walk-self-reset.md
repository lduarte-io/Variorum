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
  so the acceptance walker can run the guarded helper without an interactive prompt.
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
| 4 | D-4 — the window-frame guard (autosave key deleted pre-launch; bounds asserted post-launch) | NOT-STARTED |
| 5 | D-2 + D-3 — the pre-step, `--arm setup\|join\|both`, the join arm, the cleanup leg | NOT-STARTED |
| 6 | D-6 — release.sh HANDOFF step 0 + README | NOT-STARTED |
| 7 | Final evidence: both self-tests' case lists, D-7 red-on-old, `zsh -n`, each D-row's acceptance (file:line) | NOT-STARTED |

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
| 3 | UNIT 1 — the script work (D-1…D-7) | IN FLIGHT — implementer spawned on this file's UNIT 1 BRIEF |
| 4 | UNIT 2 — the live acceptance on production | NOT-STARTED (stage claim via oct27coordinator; Opus walker) |
| 5 | The ladder (fresh fable-reviewer, whole diff) | NOT-STARTED |
| 6 | Closeout: canon delta (the standing ruling, two-file shape), tickets, handoff, merge | NOT-STARTED |

**Owned at kickoff:** the in-flight-row commit on main carries a `Co-Authored-By` trailer against her
standing no-trailer rule (the harness reminder was followed over CLAUDE.md for one commit; caught at once;
pushed history is never rewritten, so it stands). No later commit of this run carries one.
