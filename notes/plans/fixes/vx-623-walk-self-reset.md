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

- **Q1 — the reset road:** headless guarded Management-API reset (recommended) · in-app Delete Account +
  re-mint per release · headless pre-step + in-app delete as cleanup. → PENDING
- **Q2 — the gate's scope:** the std release gate runs BOTH arms every release (set-up → join → cleanup;
  recommended) · set-up only, the join arm a separate mode for drills. → PENDING
- **Q3 — rider VX-536** (guard.sh wl2 gap; same files open): join this run (recommended) · stays on the
  board. → PENDING

**The cast (stated, hers to redirect):** the standing default — this Fable session orchestrates and
architect-rules; ONE `opus-implementer` session builds the script work; a fresh `fable-reviewer` runs the
ladder (the diff is a production-write tool — Fable judgment kept deliberately, though no editor seam,
`Sync/` or custody line is touched); the LIVE acceptance walk is driven by an OPUS walker under a held
stage claim (the R-510-5 precedent + the coordinator's brief: live walks and simulated input go to Opus).

## The design (the architect's; D-rows are the implementer's brief sections)

- **D-1 — the reset helper** (`Tools/WalkKit/reset-test-account.sh`, a sibling of the walk, calling the same
  Management-API endpoint `Tools/prod-read.sh` reads through): resets ONE allowlisted account to
  "exists, confirmed, vaultless, rowless" with the VX-439 release-tail statement — one atomic CTE mirroring
  `account_purge()` MINUS the auth user and the entitlement: the key_vault row, the data tables, device
  cursors, tenant seq, challenge nonces, write budget, the `kp:` proof secret (best-effort, the purge's own
  shape). Guards: the fence rules above (premise fence 2). Before/after reads printed and logged. Exit 5 on
  any guard, nothing written. `--self-test` over fixtures; `--dry-run` prints the plan + the before reads.
  *(If Q1 lands on the in-app road, D-1 becomes the pre-step healer only, and D-2's cleanup drives the
  Account sheet instead.)*
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
- **D-7 — rider VX-536** (if Q3 seats it): `guard.sh`'s on-this-Space check refuses, with a naming message,
  when its wl2 helper is absent — compile-or-refuse, never silently pass.

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
| 2 | The kickoff sitting (Q1–Q3) + her premise answer delivered | PENDING her answers |
| 3 | UNIT 1 — the script work (D-1…D-7) | NOT-STARTED (brief = this file's D-rows + traps) |
| 4 | UNIT 2 — the live acceptance on production | NOT-STARTED (stage claim via oct27coordinator; Opus walker) |
| 5 | The ladder (fresh fable-reviewer, whole diff) | NOT-STARTED |
| 6 | Closeout: canon delta (the standing ruling, two-file shape), tickets, handoff, merge | NOT-STARTED |

**Owned at kickoff:** the in-flight-row commit on main carries a `Co-Authored-By` trailer against her
standing no-trailer rule (the harness reminder was followed over CLAUDE.md for one commit; caught at once;
pushed history is never rewritten, so it stands). No later commit of this run carries one.
