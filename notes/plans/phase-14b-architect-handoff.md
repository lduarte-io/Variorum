# Phase 14b — ARCHITECT HANDOFF (mid-phase cutover, 2026-08-04)

> **Why this file exists:** the author's message at the copy/flow round's
> start tripped a model-routing safeguard and the orchestrator seat moved
> off Fable mid-phase. She is restarting the seat as a FRESH FABLE SESSION.
> This is the two-document handoff form (`/architect-phase`): role + state
> here, paste-ready kickoff prompt at the bottom. **THE PLAN FILE
> `notes/plans/phase-14b-suite-e2ee.md` REMAINS THE ONE RUNNING RECORD** —
> this file is the cutover's entry point only, and its CF-14/15/16 rows
> below must be folded into that file's CF ledger by the incoming
> architect (they were recorded here to avoid a write race with the
> running implementer).

## STATE AT CUTOVER (verified, not remembered)

**The phase is BUILT, LADDERED, DEPLOYED, MIGRATED, AND LIVE-VALIDATED.**
What remains is the copy/flow round, one cold pass, her walk, and closeout.

- **Design sitting:** rulings R-1…R-8 recorded in the plan file (vault on
  the Variorum project · wipe-and-repush · insights closed · passphrase-only
  enrollment · 12-word BIP-39 · enrollment-only unlock · Argon2id vendored ·
  master + per-class keys). Cast ALL-FABLE.
- **Batches 1–3:** shipped, architect-verified (crypto substrate · the
  `SyncSchema` classification + serializer seam + engine gating · vault
  client, both-form-factor flows, `vault-bootstrap` runner, bridge
  journal-class capability paused).
- **Ladder:** CLOSED at round 2 (R1: 1 MAJOR + 3 MINOR + 5 NIT, all fixed
  revert-verified; R2: every disposition HOLDS, 2 NIT residuals applied).
- **Gate steps 1–6: ALL EXECUTED AND VERIFIED.** A1 backup
  (`variorum-backup-2026-08-04-125511.sqlite`) + full mirror export ·
  `08_phase14b_lockstep.sql` deployed (marker 5, `key_vault` RLS'd) · her
  vault created in-app · the mirror TRUNCATED and REPUSHED (11 rounds,
  7,265 rows) · **the headline proof PASSED: zero plaintext across all 18
  encrypted columns, mirror rows == local rows exactly** · her phone
  enrolled and decrypted her whole corpus (device KDF **0.16 s**, L12
  satisfied) · the recovery-phrase road proven on the Mac with her paper
  words, her phone riding through the passphrase change untouched.
- **Her passphrase file is DELETED** (spent + stale). The live passphrase
  exists only in her head. **No secret material is available to any
  session — every future runner invocation needs her to supply it.**
- **Counts at cutover:** core 1155/124 · Mac 1202/210 (the standing
  `TakePaneMeasureTests` tripwire the ONE allowed red) · mobile 173/25 ·
  spine 51/7. **Never re-run at session start.**
- **HEAD at cutover:** `af32293`, pushed. Working tree carries the running
  implementer's UNCOMMITTED copy/flow-round edits (see below).

## THE RUNNING IMPLEMENTER (handle FIRST)

A copy/flow-round implementer was spawned from the retired session with the
plan file's round brief. At cutover it had **four modified files**
(`EncryptionKeychain.swift`, `EncryptionSession.swift`, `EncryptionViews.swift`,
`EncryptionFlowTests.swift`), **no commits, and no `### Copy/flow round —
record` section written**.

**It cannot be resumed from a new session** — background agents are scoped
to the session that spawned them, and its transcript is not a substitute
for a written record (this is precisely why repo-first exists).

**Do this, in order:** (1) `git status` — if the four files are still
modified and uncommitted, treat the work as ORPHANED; (2) **ADOPT-VERIFY-
COMMIT** it (never start over, never blind-commit): read the full diff
against the round brief's eight items, verify each claim yourself, run the
acceptance suites, commit what conforms with an honest record of what is
incomplete; (3) spawn a FRESH implementer for whatever the diff does not
cover. *(The adopt-verify-commit rule is the recorded lesson from this
phase's own sleep-suspend incident — see the session memory
`subagent-background-wait-death`.)*

## HER QUESTIONS AT CUTOVER — ANSWERED FROM THE CODE (she is waiting on these)

**Q1 — "How am I going to be able to walk [the new setup flow] again on the
Mac, since I already have my keys?"** Three states exist
(`EncryptionSession.refresh`): vault + local custody ⇒ `.enrolled` (the
enrolled surface); vault + NO custody ⇒ `.notEnrolled` (the ENROLLMENT
surface); NO vault ⇒ `.noVault` (the SETUP flow). So **CF-11's forget-keys
door reaches ENROLLMENT, not SETUP** — walking the new stepped setup flow
live requires the vault row to be gone. Options, honestly ranked:
  - **(a) A preview/screenshot walk of the setup steps (RECOMMENDED for the
    round's copy review):** the round implementer produces captures of each
    step so she reviews copy with zero production risk. Cheap; covers
    CF-1/5/6/7/9/10/13, which are all copy-and-sequence items.
  - **(b) A scratch-account walk: NOT AVAILABLE without changing the A4
    fence** — a Debug build is dev-store-fenced and has no sign-in door at
    all (`SyncStatusViews.swift:35–44`, and the Encryption door is gated on
    `sync.allowsSync` at :93), so a scratch account cannot reach these
    surfaces. Do not weaken the fence for a copy review.
  - **(c) The deliberate RE-KEY DRILL (optional, genuinely valuable):**
    forget keys on both devices → delete the `key_vault` row (admin) → the
    app shows SETUP → she walks the real flow → new keys → truncate → repush
    → phone re-enrolls. ~20 minutes; every piece of machinery is now proven
    and backed up. **This IS CF-8's road rehearsed** (see Q2), so it doubles
    as 14c design evidence. Requires her explicit go and the A1 rail; her
    passphrase must be re-supplied (the file is gone).

**Q2 — "is that resting on the 'delete remote store, re-encrypt and reupload'
pass?"** Yes — option (c) is exactly CF-8, which is recorded as owned by
14c's operationalia. The MACHINERY already exists (vault row delete + the
committed truncate artifact + `resyncReinitialize`/the runner); what 14c
owes is the in-app door and its guard rails.

**Q3 — "what impact will that have on the phone's logged in session — will
the phone be aware?"**
  - **Forget-keys on the Mac ONLY: the phone is unaffected** (the vault is
    untouched; her passphrase change already demonstrated this live).
  - **A full re-key: the phone's ACCOUNT SESSION is unaffected** (auth and
    encryption are separate), **but its stored class keys go stale.** The
    mirror's rows would be sealed under new class keys with a new key id,
    and `PayloadCipher`'s AAD binds the key id — so the phone's decrypt
    fails and its rounds refuse.
  - **CRITICAL GAP FOUND ANSWERING THIS — logged as CF-16 below: the phone
    will NOT know why.** `EncryptionSession.refresh()` determines local
    enrollment by `store.load() != nil` ALONE and never compares the vault's
    key ids against custody's — so a stale device still reports "This device
    holds your encryption keys" while the sync row shows a generic crypto
    failure.

**Q4 — "do I need to change anything on the phone to re-prompt encryption
verification?"** After a re-key: yes — forget keys, then re-enroll with the
new passphrase. **Until CF-11's door ships there is NO path on the phone**
(sign-out deliberately keeps custody, and iOS Keychain items survive app
deletion). This is why the proper phone drill is the round's acceptance.

## NEW LEDGER ROWS FROM THE CUTOVER MESSAGE (fold into the plan file's CF ledger)

- **CF-14 — RULED (her UI call): the Encryption surface folds UNDER the
  Account button as a TAB**, not a sibling door. Her reason, recorded:
  "account will one day show payment." Applies to both form factors (the
  shared seam); the sync row's separate "Encryption…" button retires into
  it, while the LOCKED state's "Unlock…" door stays reachable in place (it
  is the fix-naming refusal's own affordance — do not bury it).
- **CF-15 — the sync chrome FLICKER, mechanism confirmed
  (`SyncStatusViews.swift:45–47` vs :78–87):** the `isSyncing` branch
  REPLACES the row's content with `ProgressView` + "Syncing…", so "Sync
  now" and "Account…" vanish and reappear every round, while the
  "Encryption…" button (an independent `if` at :93) stays put — exactly what
  she observed. Her ruling: **the buttons must not move; "Sync now" is
  merely DISABLED while a round runs** (the progress indicator may show
  beside the label). **Both platforms fix at once** — `MobileSettingsView`
  embeds this same shared `SyncStatusRow`. Pin: a syncing-state snapshot
  asserting both buttons are still present and "Sync now" is disabled.
- **CF-16 — the stale-key blindness (found answering Q3; architect-logged,
  her call at the walk):** `refresh()` should compare the vault's
  `corpus_key_id` (and the journal-bridge id) against local custody and
  project a distinct state — e.g. "This account's encryption keys were
  replaced. Enter your passphrase to re-enroll." — instead of reporting a
  healthy enrolled device; the engine's key-id-mismatch refusal should route
  to that same state. **Cheap now, and it is the honesty half of CF-8's
  road** (a re-key must not leave other devices silently broken). Recommend
  building it in the round with CF-11/CF-14; defer only if she prefers.

## REMAINING WORK, IN ORDER

1. **Handle the orphaned implementer diff** (adopt-verify-commit; above).
2. **Finish the COPY/FLOW ROUND** — the plan file's round brief (CF-1…CF-13
   + the biometric mini-batch) PLUS CF-14/15/16 above. Her governing
   principle is CF-10 (first real E2EE for many users). Her hard rulings
   inside it: the recovery phrase is MANDATORY at setup; the checkbox
   sentence is hers verbatim; the warning must say the LOCAL copy survives;
   biometric-OR-passphrase-NEVER-the-device-passcode; nothing is ever called
   "Passkey" (pinned by a string test).
3. **Produce the setup-flow preview/screenshot walk** (Q1 option (a)) so she
   can review copy she cannot reach live.
4. **ONE cold-review pass** over the round's diff (`REVIEW_PROMPT.md`
   verbatim, fresh reviewer, zero framing), findings recorded before any fix
   session; the hallucination guard binds.
5. **HER WALK** — the new flow + the disclosure list's final copy (her ONE
   outstanding ratify, staged in the plan file's GATE RATIFY block) + the
   proper phone drill (forget keys → re-enroll via the 12 words).
6. **CLOSEOUT, in full** per CLAUDE.md: results + counts in the plan file;
   master-plan table/pointer/closeout paragraph; roll the superseded pointer
   and 13k's closeout paragraph into `notes/PhaseCloseoutArchive.md`; the
   AppSpec §14 delta for this phase (schema `key_vault`/marker 5 + the E2EE
   semantics) with 13k's delta rolled to `notes/AppSpecDeltaArchive.md`;
   SyncSpec §12's lockstep-events record gains the marker 4→5 event;
   KnownIssues — the **E2EE decision row RESOLVES here** (14b built it) and
   the GM-1 windowless capture is already recorded on its 13e row; the
   MobileSoul **PL-6 parity line** (design-time row exists — mark what
   shipped, note the phone half is live); `notes/handoffs/phase-14b-handoff.md`
   with her checklist at top; **the 14c kickoff draft** (its scope ledger is
   the master plan's 14c row — the one-batch Fragments handoff, custom
   domain before it, SMTP, account deletion, `setting` owner-scoping,
   isolation, the tier, plus THIS phase's contributions: CF-8's remote-reset
   door, the admin-link-bypasses-signups fact, and GM-3's burst-pacing note
   for stranger-scale initial pushes).
7. Commit and push at every bout end.

## STANDING CAUTIONS (unchanged, all still binding)

- Her **Variorum-usage PAUSE** holds until the 14 family completes.
- The mirror is **LIVE PRODUCTION**: announced changes only, committed
  artifacts verbatim, her explicit go, the A1 rail first. The signups-off
  toggle is NEVER touched (14c's).
- **Zero `Sources/VariorumCore/Sync/` lines** in the round (any need = stop
  and report). `notes/sync-postmortem-fragments.md` is mandatory reading
  before any such line in any phase.
- Sessions never touch `~/dev/fragments` or the Fragments project; asks ride
  `notes/fragments-bridge-contract.md`, carried by her.
- **Implementer briefs must instruct SYNCHRONOUS waits** on builds/tests and
  repo-first records BEFORE long verification (this phase lost two sessions
  to the background-wait and sleep-suspend classes).
- **GM-1 unblock:** if the Mac test runner reports "timed out while
  preparing", launch the Debug app from DerivedData once, wait up to a
  minute for its window, quit it, retry (the captured launch-time Keychain
  block; the fix is 13e's).
- Instance checks by PATH (`pgrep -fl 'Variorum.app/Contents/MacOS'`); never
  quit a real-store instance without her word; no `/Applications` refresh
  while one lives.

---

## PASTE-READY KICKOFF PROMPT (for the fresh Fable architect session)

You are the FRESH ARCHITECT for Variorum Phase 14b (repo ~/dev/variorum,
branch main), taking over mid-phase under `/architect-phase` discipline (the
skill file governs; CLAUDE.md binds). The prior architect ran the design
sitting, all three build batches, the two-round cold-review ladder, the
mirror deploy, and the full gate — the phase is BUILT, DEPLOYED, MIGRATED,
and LIVE-VALIDATED. What remains is the copy/flow round, one cold pass, her
walk, and closeout.

READ FIRST, in your own context, in order: (1)
`notes/plans/phase-14b-architect-handoff.md` — THE entry point: verified
state, the orphaned-implementer instruction, her four answered questions,
the new CF-14/15/16 rows, remaining work in order, standing cautions. (2)
`notes/plans/phase-14b-suite-e2ee.md` IN FULL — the ONE running record:
sitting rulings R-1…R-8, THE DESIGN, the three batch records, the ladder,
the gate/wipe/repush execution records, her validation walk (CF-1…CF-13),
and the COPY/FLOW ROUND brief that is your work order. (3)
`notes/release-and-v1-strategy.md` §4. (4) The master plan's 14b/14c rows.
(5) `notes/sync-postmortem-fragments.md` before ANY
`Sources/VariorumCore/Sync/` line (the standing rule — the round should need
none).

THEN, in order: (1) handle the ORPHANED implementer diff per the handoff's
adopt-verify-commit instruction — never start over, never blind-commit. (2)
Finish the COPY/FLOW ROUND (the brief + CF-14/15/16), fresh implementer
sessions, repo-first records, red-on-old pins revert-verified. (3) Produce
the setup-flow preview/screenshot walk she cannot reach live (handoff Q1
option (a)). (4) ONE cold-review pass, `notes/REVIEW_PROMPT.md` verbatim,
zero framing, findings recorded before any fix session. (5) HER WALK: the
new flow, the disclosure-list ratify, and the proper phone drill. (6) The
CLOSEOUT ritual in full per the handoff's step 6, ending with the 14c
kickoff draft. (7) Report to her; she opens 14c.

STANDING: her Variorum-usage PAUSE holds until Phase 14 completes; the
signups-off toggle is the sole corpus guard and nothing you do touches it;
the mirror is live production (announced changes only, committed artifacts,
her explicit go, the A1 rail); ZERO `Sync/` lines in this round; her
passphrase file is DELETED — any runner invocation needs her to supply the
passphrase herself; baselines are in the handoff — never re-run at session
start; commit AND push at every bout end.
