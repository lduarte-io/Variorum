# VX-510 — the orchestrator cutover (2026-10-24)

## THE KICKOFF (paste this into a fresh session on the Pro)

```
/architect-phase vx-510

You are the SUCCESSOR orchestrator of the run VX-510 ("Run: the first-run sync failures"), taking over at a planned
cutover (her ruling R-510-19). Read, in this order, before anything else:
  1. <home>/dev/variorum-vx-510/notes/plans/fixes/vx-510-orchestrator-handoff.md — this file, WHOLE
  2. <home>/dev/variorum-vx-510/notes/plans/fixes/vx-510-first-run-sync.md — the run record, WHOLE
  3. the rest of /architect-phase's preflight (CLAUDE.md and its canon, SyncSpec, CastleRules, SurfaceContracts'
     protection bullet, the resiliency protocol, the master plan, TICKETS, QUESTIONS' tail).
Your work, in order: the VX-527 rider (one implementer); the ladder over the WHOLE run diff (fable-reviewer first, an
opus-reviewer if Fable stalls on safeguards — R-510-5); the closing stage batch (the whole Mac target + the phone
suites); YOUR OWN re-walk of the first-run legs on the final build (re-validate, never trust, the previous orchestrator's
walk claims — re-read the server rows yourself); then the closeout and the PR. Treat everything below as claims to
verify. Commits carry NO trailers of any kind.
```

## Role, as amended

- **Opus orchestrates** (her R-510-5: "I keep hitting safeguards on Fable - keep going. Try to do a Fable cold review at the
  end but if that cold review stalls out due to safeguards, do the ladder with Opus instead."). Implementers are
  `opus-implementer` (model pinned to opus), ONE at a time, a fresh one per unit, briefed only from the record's named
  sections (repo-first: write the brief into the record BEFORE spawning).
- The ladder: `fable-reviewer` with `notes/REVIEW_PROMPT.md` VERBATIM and zero framing, over `git diff main...vx-510-first-run-sync`.
  The diff touches custody/keychain code (`Sources/VariorumCore/Protection/Executor/*`, `App/Variorum/Shared/Protection/*`)
  — that is why Fable is asked first. **No line under `Sources/VariorumCore/Sync/` changed** (verify: `git diff
  main...HEAD --stat -- Sources/VariorumCore/Sync` is empty). Cross-model flow per CLAUDE.md: findings → the implementer
  verbatim → agree/dispute → the reviewer's final call → the implementer applies confirmed fixes (red-on-old per finding) →
  a FRESH reviewer re-checks; hard cap three rounds.
- **Rigor, her question (2026-10-24): "this is a lot of walking and little cold reviewing ... how to keep it rigorous."**
  The answer this cutover encodes:
  1. The run has had NO cold review yet. The ladder is the next gate, not optional. Freeze scope: VX-529 is its own run
     (R-510-19), and no new members join before the ladder.
  2. The previous orchestrator designed, briefed, verified and walked. Its walk claims are evidence, but they're
     self-reported. You re-walk the core legs yourself on the FINAL build, and re-read the server rows with
     `Tools/prod-read.sh`, before the PR.
  3. Every unit's pins were verified by behavioral reverts in the implementers' records. The ladder reviewer judges the diff
     and the record cold. The closing stage batch is the first whole-target run since unit A (5141/902 at `92bd0740a`).

## State at cutover (VERIFY, don't trust)

- **Branch** `vx-510-first-run-sync`, worktree `~/dev/variorum-vx-510` (the Pro), in-flight row on main. The tip is the
  commit carrying this file. The members (Linear sub-issues of VX-510) are VX-498, 507, 506, 509, 501, 511, 513, 503, 517,
  plus the rider VX-527 (not built yet).
- **Units built and verified (the record's LIVE STATUS sections and its status table):**
  - A: VX-498, VX-507, VX-506. The first round runs on every account act, the row's not-yet face, and the join door "Sync this library…".
  - B1: the drill, `first-run-walk.sh`, the services generation, and the DEBUG prod test road.
  - B2: F-B1-1, VX-501 (a typed Castle unlock loads the sync keys), VX-511 (a landed account act retires the words card),
    and VX-503 (`material(for:)` derives from the vault first).
  - B3: VX-513, the read-only check door.
  - B4: VX-517, by-name forgets plus "a Standard library never reads the Touch ID class".
- **Headless evidence at the tip:**
  - B4's harness `vx510b4-harness`: 521 tests in 90 suites (plus three path artifacts).
  - The core protection set: 546 tests in 103 suites, re-run by the orchestrator through `scratchpad/b4/core-test.sh orch-verify PROT`.
  - Mac and iOS build-for-testing: green.
  - The harnesses live in the previous session's scratchpad,
    `/private/tmp/claude-501/-<home>-dev-variorum/e4cb0455-71b1-400e-8366-273031288432/scratchpad/` (`vx510b4-harness`, `b4/`).
    They aren't durable; rebuild from the recipes in units A and B4 if they're gone.
- **NOT RUN: every Mac-hosted and phone suite since unit A.** The lists are in the B2, B3 and B4 reports in the record
  (B4's is the superset):
  - the whole `VariorumTests/Protection` folder;
  - `AppBootstrapOffMainTests`, `LibraryHandOffTests`, `LibraryPortabilityDoorTests`, `SettingsLockCloseTests`,
    `OneRefreshAuthorityTests`, `ProdTestRoadTests`, `SyncWalkFenceTests`, `CopyRegisterPinTests`,
    `Phase13pCopySweepTests`, `TravellingDotsIndicatorTests`, `SyncLockedRowTests`, `Phase9cAuthWiringTests`;
  - the real-keychain `KeychainLeavesTests` (its new arm needs a Touch ID finger enrolled on the stage Mac, or it skips:
    read the `skipped:` lines) and `ProtectionKeychainFamilyTests`;
  - the phone: `MobileProtectionRoadTests`, `MobileProtectionTests`, `MobileEmptyStoreTests`, `MobileStructuralTests`,
    `MobileRefusalTableTests`, `MobileTutorialWalkTests`, `MobilePerfWalkTests`.
  - The simplest honest batch is the WHOLE Mac target plus those phone suites, under a held `Tools/stage` claim.
- **Live on production** (unit C, the record's "UNIT C — THE RECORD"), all walked by the previous orchestrator:
  - LEG S (std): set-up with no relaunch; keys; backups; restore; joins.
  - LEG D (del, now deleted): Delete Account.
  - LEG C (castle): Castle from scratch; VX-501's typed unlock; key changes; typed-secret backups; the re-keying join; VX-511; Use Standard.
  - VX-513's walk, rows 1–5 including offline.
  - VX-517's red leg (the pre-fix build: two Touch ID sheets on a Standard key door) and green leg (the post-fix build: none;
    the Castle guard intact; VX-530 seen live).
  - The VX-529 repro.
- **The stage is FREE; the dev store is BACK** (`e11e5233`; inodes matched; signed out; "Sync off (dev store)"). The walk
  checkout `~/dev/variorum-vx-510-stage` is removed. Make your own for the stage batch and the re-walk: a detached
  `git worktree add` at the tip, building into a non-standard DerivedData path.
*[removed for publication]*
  - `std`: Standard; passphrase = its PASSPHRASE2 after the S-leg change; the words from S13.
  - `castle`: Standard, vault revision 15, passphrase = its PASSPHRASE, the words from C3.
  - `del`: deleted.
  - The secrets are in `~/.variorum/prod-test-accounts.env` (mode 600) and the words in `~/.variorum/prod-test-words-{std,castle}`.
    Type them ONLY through `~/.variorum/bin/type-prod-test-secret <acct> <field>` (guarded: the frontmost app must be the
    Debug build launched with `VARIORUM_PROD_TEST_ROAD=1` and `VARIORUM_PRODTEST_EMAILS`). Stash words only through
    `~/.variorum/bin/stash-prod-test-words`.
  - Confirm a new sign-up with `Tools/prod-confirm-test-user.sh <email>` (one guarded UPDATE).
  - Read the server with `Tools/prod-read.sh "<SELECT>"` (SELECT only).
  - **Never print, commit or type a secret any other way.** The Debug app NEVER signs into her real account.
- **Whether the std and castle accounts stay** as standing release-drill accounts is her call at closeout.

## Your work, in order

1. **Preflight + seat yourself** (the skill's workspace rules; `git -C ~/dev/variorum-vx-510 pull --ff-only`; status clean).
2. **VX-527 (the rider):** the lock screen's "Use your twelve words instead" opens only from its tiny arrow. Her hand on the
   Pro's own trackpad confirmed it: "the click affordance is very small". Write D-B9 + UNIT B5's brief into the record
   (the whole label opens the disclosure; a red-on-old pin, e.g. the disclosure's label is a button or a tap target
   covering the text; one implementer; build-for-testing only), then spawn.
3. **The ladder** (above). Findings and dispositions land in the record before each next round.
4. **The closing stage batch** (above), under a held stage claim, from a clean detached checkout at the final tip.
5. **Your re-walk (independent):**
   - `Tools/WalkKit/first-run-walk.sh` (VX-509's scripted walk; B1/B2 record its use; its HANDOFF step 0 is on the
     release checklist) on the final build, with a FRESH test account. Sign it up through the prod road, confirm it with
     the PAT script, and add its address to the allowlist file. The file's `VARIORUM_PRODTEST_EMAILS` line is what the
     launcher passes; every address must carry `vxtest`.
   - Then a short Castle leg on the `castle` account: Use Castle (Always ask) → lock → typed unlock → a note pushes →
     "Synced" (VX-501); a second fresh library joins → both cards retire (VX-511); the check door's synced answer
     (VX-513); Use Standard → Change passphrase raises no Touch ID sheet (VX-517). Re-read the server rows yourself.
   - Restore the dev store exactly as the record's unit C close did (set aside, walk, remove the walk libraries by their
     key files' `library` id, move back, check inodes, sign out).
6. **Closeout**, per CLAUDE.md's ritual:
   - Canon deltas in the two-file shape. The contract lines go in place in `notes/SurfaceContracts.md`'s protection
     bullet: the first round on every account act and the sheet's round line; the row's not-yet face; the join door's
     label; the typed unlock loading the sync keys; the words card retiring on a landed account act; the check door; the
     Standard library never reading the Touch ID class. The DEBUG prod test road's fence exception goes where the dev
     fence is stated. The dated entry goes in `notes/AppSpecRecord.md`.
   - `Tools/canon-size` reported in the handoff.
   - The master plan's closeout paragraph; the in-flight row retired.
   - QUESTIONS: the PROVISIONAL bundle — P-VX510-1…3, A1…A4, B1-1, B1-2, B2-1, B3-1, B3-2, plus D-B8's (c) reading and
     F-B4-1's residue.
   - Ticket triage: the run filed VX-511…VX-531 (less VX-514). VX-529 is the NEXT run; write its plan with a kickoff
     message, respecting R-510-20.
   - The MOBILE PARITY line.
   - Her handoff `notes/handoffs/vx-510-handoff.md`.
   - The PR "VX-510: …" (merge commit).
   - Never a release or an `/Applications` refresh without her word. The testers need these fixes in a release, so the
     handoff asks her.

## Machinery lessons (don't relearn them)

- **Shared worktree.** The orchestrator and the implementer write the same record file. Edit it only when `git status` is
  clean, and commit at once; hold notes in your scratchpad while an implementer runs.
- **Walk helpers** (the previous scratchpad, not durable; rebuild as needed):
  - `walk-cap <pid> <dir>` captures per-window, and prints the bounds;
  - `walk-scroll x y n`;
  - `swap-lib.sh <from-aside> <to-aside>` (slot ↔ an aside folder; refuses with an instance up);
  - `launch-walk.sh <log>` (the prod road env; `WALK_APP=` for another build);
  - `ax-btnpos.applescript` / `ax-lobby.applescript` / `ax-disclose.applescript` (positions and AXPress without reading text).
- **Touch ID evidence.** No tool reads the data-protection keychain. Capture the screen REGION about 4 s after a press: the
  system sheet "Variorum Dev is trying to Unlock your Variorum library" waits, so a capture can't miss it. Touch ID presses
  aren't HID input, so the 10-minute idle lock can fire during a long Touch ID act.
- **Swapping libraries in the slot** raises "This is a different library than the one this Mac last had open" on the next
  open. It's a walk artifact; OK it.
- **The ambient as her signal** (memory `signal-her-with-the-ambient`) currently REFUSES from a session shell
  ("activation was declined"). VX-531 holds her ruled shape. Until that's fixed, post `osascript display notification …
  sound name "Glass"` and say so in the session.
- **Her messages arrive mid-turn.** Answer each point in her words, same turn. When you need her hands, END the turn with
  the exact step: she sees text when the turn ends.
- **The Castle design is FROZEN** (memory `castle-design-is-frozen`, her R-510-20). Never propose changing a rule or
  anything stored.
