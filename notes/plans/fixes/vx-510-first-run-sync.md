# VX-510 — Run: the first-run sync failures

**STATUS: OPEN (kickoff 2026-10-23). Branch `vx-510-first-run-sync`, worktree `~/dev/variorum-vx-510`, the Pro.
The charter is `notes/handoffs/vx-510-kickoff.md` (read whole); the window's trace is
`notes/plans/fixes/vx-494-catchup-hang.md` (R-494-4…13); the sync-keys seam beside this one is
`notes/plans/fixes/vx-488-window-hotfixes.md`. Members: VX-498 (the set-up act's silent no-round — the mechanism) ·
VX-507 (the act confirms its first round) · VX-506 (the pre-join wording, riding) · VX-509 (the standing first-run
*[removed for publication]*
one-statement act surfaced to her the moment it lands). Cast (R-510-5): Opus orchestrates (the session moved off
Fable at her word), Opus implements, one at a time; the ladder tries a fresh `fable-reviewer` first and runs on
`opus-reviewer`s if it stalls on safeguards. Three units (R-510-9): A the fixes, B the drill + the prod road, C the
two-posture lifecycle drill live on production.
Pin-before-fix PER MEMBER; commits say `Part of VX-nnn`; NO trailers.**

## HER KICKOFF RULINGS (2026-10-23, the kickoff message — verbatim-faithful; recorded before any work)

- **R-510-1 — THE PROD ROAD, ruled (the kickoff file's fork is DECIDED):** "The kickoff file talks about choosing
  between three roads for the live accounts — I'm ruling it now: make a deliberate, narrow exception so dev test
  accounts can reach production (a named road for named test accounts; never delete the fence that keeps every
  other walk off prod), because otherwise how will we ever know if something actually works in prod or not?"
  → The acceptance's fresh accounts run against PRODUCTION through a named, narrow exception: the fence stays for
  everything else; the exception admits only named test accounts. The exact seam is a design item below (D-ROAD).
- **R-510-2 — TWO TEST ACCOUNTS, RIGOROUS LIFECYCLE:** "maybe we need two dev accounts, one standard and one
  castle, and we need to go through RIGOROUS testing for both: signing up, syncing, making a backup, restoring a
  backup, changing keys, trying the backup again, etc." And: "You can also bring those testing items to me — maybe
  it's worth doing them now, as part of this. I don't know. I want to release soon and I NEED to know that
  everywhere where the rubber meets the road is alright."
  → Bundled as a kickoff-sitting decision below (THE SITTING BUNDLE): the first-run acceptance (several fresh
  accounts, set-up + join, both postures) lands in THIS run per the charter; whether the FULL lifecycle drill
  (backup → restore → key change → backup again, both postures) runs inside this run or as its own chartered
  follow-up is her call — the kickoff prompt's own words: "if the full two-posture lifecycle drill outgrows this
  run, charter it as its own written follow-up — but the first-run trace, fix, and live proof land in THIS run
  either way."
- **R-510-3 — PERMISSIONS:** "I do NOT CARE what I need to add to your permissions — propose narrow rules like
  prod-read and I'll add them." → Any new road this run needs is proposed to her as a narrow named rule
  (the `Tools/prod-read.sh` precedent), never worked around.
- **R-510-4 — THE UNDER-TESTED-SEAMS SWEEP:** "we NEED real testing on every area where the rubber meets the road
  because I want to launch soon. As part of this, sweep for what else is under-tested at the live seams and bring
  me the map." → A deliverable of this run: THE MAP — every seam where the product meets the real world (live
  Postgres, the real keychain, Touch ID, Sparkle, the DMG, the real filesystem, the MCP socket…), what evidence
  each has today, and what it lacks; propose-only, hers to slot.
- **R-510-5 — THE CAST, re-ruled mid-trace (2026-10-23, her words):** "I keep hitting safeguards on Fable - keep
  going. Try to do a Fable cold review at the end but if that cold review stalls out due to safeguards, do the
  ladder with Opus instead." → The session moved Fable → Opus 5.5 at her `/model`; this session (Opus) stays the
  orchestrator; implementers stay `opus-implementer`. THE LADDER: round 1 is tried with a fresh `fable-reviewer`
  (REVIEW_PROMPT verbatim); if that reviewer stalls on safeguards, the ladder runs with fresh `opus-reviewer`s
  instead (the R-494-1 precedent). No line of this run is planned inside `Sources/VariorumCore/Sync/` (the fix
  rides the scheduler's existing public API from `Shared/`); if one becomes necessary it is flagged here first.

## HER SITTING RULINGS (2026-10-23, the kickoff bundle — four questions; her answers verbatim where she wrote them)

- **R-510-6 — D-ROAD's shape: "Env flag + allowlist"** (the recommended option, chosen). Debug-only. A launch with
  `VARIORUM_PROD_TEST_ROAD=1` AND a local allowlist file `~/.variorum/prod-test-accounts.env` naming the test
  emails lets the DEV store sync with PRODUCTION only while signed into a listed account; any other account (hers
  included) keeps the fence and the row says why; Release builds byte-unchanged. Pinned: the fence holds with no
  flag; refuses an unlisted account. Built in unit B.
- **R-510-7 — the test accounts' confirmation: "can you confirm them in the dashboard via the PAT? i want you to
  be as capable as possible"** → the PAT road, as a NARROW named script per R-510-3 (the `Tools/prod-read.sh`
  shape): `Tools/prod-confirm-test-user.sh '<email>'` confirms ONE unconfirmed auth user whose email is on the
  allowlist file and carries the plainly-test marker, nothing else (the one statement, ref-pinned); its allow rule
  proposed to her. The orchestrator writes it (an environment act).
- **R-510-8 — the secrets: "Helper reads a file"** (the recommended option, chosen). A typing helper modelled on
  `type-throwaway-passphrase` reads `~/.variorum/prod-test-accounts.env` (walk-build-only guard; values never
  echoed, never committed); the orchestrator generates random values into the file without printing them; one
  narrow allow rule for the helper, proposed to her.
- **R-510-9 — the full two-posture lifecycle drill: "this run, I'll do a compact mid round if we need"** → IN THIS
  RUN, as unit C — her explicit split ruling over the two-units guidance (PhaseSizingGuidance §3: a third unit is a
  split ruled at the sitting — ruled: kept in one run); she will compact this orchestrator's context mid-run if
  needed. The drill: for a Standard and a Castle test account on production — sign up, set up, first round, a
  second library joins, back up, restore a backup, change keys (passphrase, new words; the Castle crossings),
  open the older backup again with the new secrets (rule 4/5's floor), every leg verified in the app AND server-side.
- **R-510-10 — the address shape, delegated: "you can pick the address shape."** → PICKED: plus-addresses on her
  *[removed for publication]*
  confirmation email; a made-up or reserved domain bounces at her auth mail provider, and at her low send volume a
  few bounces are a high bounce RATE (providers pause senders on it) — her real users' confirmation emails would
  pay. These deliver harmlessly to her inbox (plainly-test, filterable), and `Tools/prod-confirm-test-user.sh`
  confirms them, so she never clicks.
- **R-510-11 — VX-501 JOINS THE RUN: "Join this run (Recommended)"** (asked because the Castle lifecycle leg locks
  and unlocks under Always ask, where a typed unlock loads no sync keys). Built in unit B to her ruled direction
  (R-494-4: "a typed unlock should hold sync keys in session until lock"; the ticket names the existing shape —
  `KeyDoors.holdSyncKeysForTheSession` derives the master from a typed secret), pinned red-on-old, then proven
  live in unit C's Castle leg. Linear: parented under VX-510.
- **R-510-12 — the allow rules: "You add them"** → the orchestrator added exactly the five lines named in THE
  TEST-ACCOUNT ROAD below to `~/dev/variorum/.claude/settings.local.json` (19 → 24 rules, JSON validated; nothing
  else changed).

## THE TEST-ACCOUNT ROAD — the tools (built by the orchestrator, 2026-10-23; environment acts per R-510-7/-8)

- `Tools/prod-confirm-test-user.sh '<email>'` (committed `0043d2bf3`, this branch): the ONE UPDATE of
  `auth.users.email_confirmed_at` on a still-unconfirmed row whose email is on the allowlist and carries `vxtest`;
  plain-address guard (the email is spliced into SQL); ref-pinned to production. Its three refusals exercised
  offline (no marker · not listed · an injection-shaped string) — each refused before any network call.
- `~/.variorum/prod-test-accounts.env` (mode 600, LOCAL, never committed): the allowlist `VARIORUM_PRODTEST_EMAILS`
  + per account (`STD`, `CASTLE`, `DEL`) the email, a random 24-character sign-in password and a random
  28-character library passphrase (alphanumeric — System Events keystrokes them faithfully). Generated by a script;
  no value was ever printed.
- `~/.variorum/bin/type-prod-test-secret <account> <field>` (mode 700, LOCAL): types `email | password | passphrase
  | words` into the focused field — refuses unless the source is mode 600, the account's email is listed and carries
  `vxtest`, the frontmost app is the Debug build, and that process carries `VARIORUM_PROD_TEST_ROAD=1` and NO walk
  project (the two roads are exclusive). The `type-throwaway-passphrase` shape.
- `~/.variorum/bin/stash-prod-test-words <account>` (mode 700, LOCAL): after the words look's own Copy, writes the
  twelve words from the clipboard to `~/.variorum/prod-test-words-<account>` (mode 600) and clears the clipboard —
  never printed; the same frontmost/env guard; refuses anything but exactly twelve lowercase words.
- **The allow rules (R-510-3; ADDED by the orchestrator at R-510-12)** — in `.claude/settings.local.json`, the prod-read rule's form:
  `Bash(Tools/prod-confirm-test-user.sh *)`, `Bash(<home>/dev/variorum/Tools/prod-confirm-test-user.sh *)`,
  `Bash(<home>/dev/variorum-vx-510/Tools/prod-confirm-test-user.sh *)`,
  `Bash(<home>/.variorum/bin/type-prod-test-secret *)`,
  `Bash(<home>/.variorum/bin/stash-prod-test-words *)`.

## THE CHARTER (the kickoff file's, binding)

1. **THE TRACE, first and whole** — (a) the CURRENT 0.10 set-up/join acts end-to-end: the act → `SyncSession`/
   scheduler seam (does the Standard set-up act trigger the first round? does anything re-evaluate the row's last
   refusal after the act?), AND the act's own failure modes (can the vault write fail or be cancelled while the UI
   *[removed for publication]*
   *[removed for publication]*
   archaeology explains; only the current code gets fixed. Findings land HERE before any fix session sees them.
2. **The fixes, pin-before-fix per member:** VX-498 (red-on-old by behavioral revert), VX-507 (the act confirms
   its first round in its own sheet, or says what blocks it), VX-506 (the pre-join wording — her line: "sync
   shouldn't seem like you're restarting it"), VX-509 (the standing drill, built AS the run's evidence vehicle).
3. **THE ACCEPTANCE (hers, use-shaped):** SEVERAL fresh accounts made and proven END-TO-END — sign-up → set-up
   (and at least one JOIN from a second library) → the first round lands → the row reads "Synced ‹time›" WITHOUT
   a relaunch — each verified SERVER-SIDE by `Tools/prod-read.sh` (the vault row, the data rows, the device
   cursor). Per R-510-1 this runs on PRODUCTION through the named test-account road. Test accounts use
   plainly-test emails, are recorded here, and their cleanup (the account-deletion road — itself worth exercising
   once) is part of the run.
4. **Riders and neighbors:** VX-503 (the Standard join's Touch ID prompt — same seam, trace it if the window is
   *[removed for publication]*
   `Tools/prod-read.sh` at natural moments; the moment it lands, surface the one-statement act for her `!` hand.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight read whole (the kickoff file, vx-494 WHOLE, vx-488, CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE, SurfaceContracts, the resiliency protocol, the master plan, TICKETS, QUESTIONS tail); worktree + branch; in-flight row on main; VX-510 In Progress with members parented; this record with her kickoff rulings | DONE (this commit) |
*[removed for publication]*
*[removed for publication]*
| 3 | The kickoff sitting bundle answered (D-ROAD shape; lifecycle drill in-run or chartered; the acceptance's account set) | DONE — R-510-6…9 (env flag + allowlist; the PAT confirmation script; the typing helper over a generated file; the lifecycle drill IN this run as unit C) |
| 4 | The fixes: VX-498 + VX-507 + VX-506 (+ VX-503 if open), pins red-on-old per member | NOT STARTED |
| 5 | VX-509 — the standing first-run drill (state-transition pins at the act→scheduler seam + the scripted walk on the release checklist) | NOT STARTED |
| 6 | D-ROAD — the named prod test-account road (the fence exception per R-510-1), with its pins | NOT STARTED — shape proposed at the sitting bundle |
| 7 | THE ACCEPTANCE — several fresh accounts end-to-end on production, server-verified | NOT STARTED |
| 8 | THE MAP — the under-tested live seams (R-510-4), propose-only | DONE (drafted — THE MAP below; 17 seams; hers to slot) |
| 9 | The ladder (fresh `fable-reviewer`, whole run diff), dispositions, fixes | NOT STARTED |
| 10 | Closing runs (suites covering every changed source), PR, merge, closeout ledgers, handoff | NOT STARTED |

## ENVIRONMENT TRAPS (binding on every session of this run — the vx-494/vx-488 traps, with this run's deltas)

Instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by
STORE, never quit/kill; no Release builds or /Applications refreshes while one lives. EVERY `xcodebuild test` run
and anything touching the screen or a shared store holds a `Tools/stage` claim. Headless `swift build`/`swift
test` is stage-free. zsh `pipestatus`; NEVER a custom build configuration. Backups WAL-safe, UTC names, into
`Backups/safety-copies/` (A1). Walks on the DEV slot only; the throwaway env `ps eww`-verified before any
credential (MAP THE NAMES — the env file's keys are `VARIORUM_THROWAWAY_*`, the walk switch wants
`VARIORUM_WALK_*`); the dev Castle pair `~/.variorum/dev-castle.env`; the throwaway's users
`~/.variorum/dev-vault-throwaway.env`; her helpers `~/.variorum/bin/type-throwaway-passphrase` (+ credential
files), walk-build-only by their own guard; values never echoed, never committed, NEVER typed into driven UI.
The walk's Debug build lives at `App/Variorum/DerivedData/vx510` (never the standard path). The REAL dev slot is
the DEBUG container (`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/
Variorum-dev/`). The dev slot's files go aside by `mv`, ALL top-level files; restore whole before release;
sign the walk session OUT before restoring (O-B2). cliclick cannot press Touch ID; SwiftUI onSubmit needs System
Events `key code 36`. **Production is read-only except at her hand:** `Tools/prod-read.sh` for SELECTs
*[removed for publication]*
Debug app NEVER signs into her real account. Implementers: no subagents, no stage, no Debug launches, no
dev-store touch; headless + `build-for-testing` only; checkpoint commits per piece, push each, LIVE STATUS flips
in the same commit, PENDING on every unverified claim; foreground waits only (poll, never `tail -f`, never end a
turn waiting).

## THE TRACE (piece 1 — the orchestrator's own read, 2026-10-23; findings land here before any fix session sees them)

### T-1 — VX-498's MECHANISM (CONFIRMED in code, a REGRESSION from the release switch)

**On 0.10, nothing starts a sync round after an account act that lands on the open session.** The chain:

1. Sign-in → `AppServices.variorumSignInChanged` → `connectSyncIfAllowed` (`App/Variorum/Shared/AppServices.swift:396`)
   → `sync.configure(…)` + `sync.triggerSync()`. The outbox observation (`SyncSession.swift:154`) also fires once at
   configure (a fresh library's seed rows sit in the outbox) → a settle trigger 3 s later. Both rounds run BEFORE
   the set-up: `NewRoadSyncKeyProvider.currentKeys()` (`Shared/Protection/NewRoadSyncKeyProvider.swift:41`) throws
   `notEnrolled` (the record names no account) → the engine refuses `encryptionKeysUnavailable` → the row's status
   becomes "Sync locked". **Correct so far — the library has not joined.**
2. Settings ▸ Protection ▸ Turn on sync → `RoadAccountModel.open` → `RoadAccountConfirmModel.submit` →
   `roads.press` → `AppBootstrap.accountRoads().press` (`AppBootstrap.swift:991`) → (not re-keying)
   `ProtectionAccountRoad.press` → `perform` → `executor.setUpSync` (or `enroll` for a same-posture join)
   (`ProtectionAccountActs.swift:261–266`). The act lands: the vault written, the record names the account, the
   keys held (Standard: the silent item). `session.library = library` updates the ATTACHED session object, so
   the provider would now find keys **if asked**.
3. After the act: the confirm's `land` → `RoadAccountModel.refresh()` + `roads.landed()` → the bootstrap's
   `landed:` closure (`AppBootstrap.swift:1006–1012`): `roadCrossings.refresh`, `roadStanding.rereadPassphrase`,
   `rereadAccountBinding`, `roadKeyDoors.refresh`. **Faces only. Nothing reaches `AppServices`/`SyncSession`.**
   The bootstrap does not hold the services (they are composed per open in `VariorumApp`'s `.task`, which wires
   only `signOutRoad`, `afterAccountDeleted`, the backup hook and the restore hold's gates onto them).
4. The row's status changes only when a round completes (`SyncSession.status` ← `scheduler.statusUpdates()`), so
   it keeps saying "Sync locked" until something triggers a round. The Mac's trigger roads, exhaustively
   (`grep triggerSync|resumeSync|connectSyncIfAllowed` over `App/`): launch/sign-in (`connectSyncIfAllowed`), the
   outbox settle (a LOCAL WRITE — typing), `NSApplication.didBecomeActiveNotification` (`VariorumApp.swift:367`),
   the row's Sync now press (`SyncStatusViews.swift:596`), the restore hold's Resume. **The act is none of them.**
   Settings is a window of the same app, so returning to the main window is not a become-active either.

**The regression, by commit:** on 0.9.8 the old road's enrollment landing healed this by design —
`EncryptionSession.adoptEnrolledMaterial` called `onKeysChanged?()`, which `AppServices.start()` wired to
`sync.triggerSync()` ("Enrollment/setup landing keys heals the engine's keys-refusal immediately (Phase 14b): one
round, through the ordinary trigger" — `git show 58515fe9c:App/Variorum/Shared/AppServices.swift`, ~line 247).
**VX-329 U1 (`f2306a535`, 2026-10-22) deleted the encryption session with today's road and never rewired an
equivalent on the new road's account acts.** So every 0.10 user's Standard set-up sits locked until they type,
*[removed for publication]*

**Why the JOIN and the Castle set-up APPEARED to work (SUSPECTED, recorded — not load-bearing for the fix):** both
observed cases raised a SYSTEM authentication prompt mid-act — the Standard join's Touch ID prompt (VX-503, the
vx-494 walk's O-1) and the Castle set-up's Touch ID gate (the vx-488 rehearsal) — and a system prompt taking focus
then returning it is a `didBecomeActive`, which triggers a round. The plain Standard set-up raises no system prompt,
so no accidental become-active and no round. The fix below makes the round deterministic either way.

### T-2 — the act's own failure modes (can the vault write fail while the UI reads success?)

- **F-1 (CLEAN):** `perform` reports `.made` only when the core act returned (`acted != nil`) or the slot opens under
  the NEW key past a swap (`landedWhole: false` — a re-keying act; the next open's settle finishes it and says its
  Done). A thrown act whose slot still opens under the old key reports `.refused(sentence)` and the sheet shows the
  sentence. So on 0.10 a set-up whose vault write FAILED never reads as success in the sheet.
- **F-2 (the silent gap — VX-507's class):** "success" today means *the vault exists and the keys are held*; it
  never means *a round ran*. With T-1, a successful act is followed by NO round, and even with a round, its outcome
  (offline, lockstep refusal, the account-binding gate, a server refusal) reaches only the quiet row — never the
  sheet that said "done". This is the whole of VX-507.
- **F-3 (the pre-join words — VX-506's class):** before the act, the row reads "Sync locked — this Mac hasn't
  unlocked your account's sync keys" for a library that has NOT joined (and, for a vaultless account, keys that do
  not exist) — the line asserts a lock where there is only a not-yet; and Settings' door reads "Turn on sync" over
  the JOIN arm for an account that already syncs. Her words: "should that not be sign into sync instead of turn on?";
  "sync shouldn't seem like you're restarting it."
*[removed for publication]*
  it writes nothing and nothing afterward says sync is not on except the row (F-3's words). The fix for the
  walk-away class is F-3's honest row plus VX-507's sheet: the row must say "not on yet" (with its door) until a
  round has actually landed.
- **F-5 (owner adoption — a second silent gate, pre-existing):** `connectSyncIfAllowed` returns early when
  `runOwnerAdoption()` fails; the only trace is `account.lastError` (rendered on the Account sheet only). The chain
  stays uncomposed until sign-out/in or a relaunch, and every later trigger is a no-op (`scheduler == nil`). Not
  observed in the field; recorded for VX-507's design: the first-round confirmation must report "not configured"
  honestly rather than wait forever.
- **F-6 (re-keying acts):** a join across postures and every follow run through `accountActOnNewRoad` → the reopen
  → fresh services → `start()` → `connectSyncIfAllowed` → a trigger. So those DO get a round, through the rebuild.
  VX-507's confirmation for them must survive the reopen (the sheet's model is rebuilt with the bootstrap's open) —
  an implementer fork, below.

### T-3 — the production facts (read-only, `Tools/prod-read.sh`, 2026-10-23)

Per-account footprint (vault · key-proof enrollment secret `kp:<uid>` · challenges · write-budget · tenant-seq ·
*[removed for publication]*
*[removed for publication]*
2026-10-22 20:31, last password sign-in 20:32:58, vault 20:39:21 standard, proof hash set) 1 · **0** · 0 · 0 · 0 · 0
*[removed for publication]*
*[removed for publication]*
never held anything.

## THE ARCHAEOLOGY (piece 2 — the deleted code as the testers ran it; it explains, only the current code is fixed)

*[removed for publication]*
(`SyncEnrollmentModel` + `SyncEnrollmentView`, deleted at VX-329 U1) ran FOUR screens: Screen 1 explain → **Screen 2
the passphrase, which SET the library's passphrase on the spot** (`submitPassphrase` → `tie.setPassphrase(typed)`,
a local key-file write) → Screen 3 the twelve words through `WordsCeremony` (shown, "written down", then CONFIRMED
BY EXACT RE-ENTRY of all twelve) → only then `create()` → `encryption.setUp` → **the vault's server write** →
Screen 4 done. **THE SILENT WINDOW, FOUND:** everything a user would call "setting up sync" — choosing the
encryption passphrase — landed at Screen 2, while the account enrollment waited behind the twelve-word ceremony.
Closing the sheet (or failing the re-entry, or the Standard arm's iCloud-Keychain refusal at `create`) anywhere
after Screen 2 left a library WITH a passphrase and an account with NO vault; afterwards the row read **"Sync
locked — enter your encryption passphrase"** (0.9.4's `SyncStatusViews.lockedLabel`) — to a person who had just
chosen one, an invitation to believe it was set up and merely locked. This fits every fact: his memory ("he set up
sync, which forces you to set up a passphrase"), the server (no vault, no `kp:`, no cursor — not one round), and his
later "That passphrase doesn't open this library" (the library DID have a passphrase). It cannot be proven now (no
logs survive) — it is the one story the code and the server both allow without a failure nobody saw. The current
road has no such split: the set-up types both secrets on one sheet and the act is one plan (rule 20).

*[removed for publication]*
old road's set-up DID wire an immediate round (`adoptEnrolledMaterial` → `onKeysChanged` → `triggerSync`), and
0.9.8's `connectSyncIfAllowed` composed the chain at sign-in without waiting for enrollment. Yet no round reached
the key-proof step (T-3). The stories the code still allows: (A1) the chain never composed at her sign-in (F-5's
owner-adoption gate — its message lives only on the Account sheet), so the post-set-up trigger was a no-op and no
relaunch came before the deploy cut 0.9.8 off; (A2) the triggered round refused locally before the wire (the custody
save refused — "sync will ask again next launch" — or the lockstep read failed offline); (A3) the app quit or the Mac
slept before the round began, and no launch came before the deploy. The server cannot separate them. Her 0.10 road
is a JOIN (her vault exists) — under T-1 a same-posture join on 0.10 also lands with no round unless a system prompt
bounces focus. **Either way, VX-507 is the cure for the class:** the act's sheet confirms the first round or says
what blocks it, so silence becomes impossible on every build from this one.

## THE FIX DESIGN — UNIT A (VX-498 · VX-507 · VX-506; the architect's design, built by implementer session A)

- **D-A1 — the round after the act (VX-498).** `RoadAccountModel` gains a composition-root road beside
  `signOutRoad` (its precedent): `firstRound: (@MainActor () async -> FirstRoundOutcome)?`, wired where the services
  are composed (`VariorumApp`'s `.task`, beside `signOutRoad`) to `AppServices.runFirstRound()`. That method
  reconnects the chain when nothing configured it (the `resumeSync` shape) and then runs ONE round to its end:
  `SyncSession.roundNow()` = (held → `.held`; not configured → `.notConfigured`; else `scheduler.trigger()` +
  `awaitIdle()` + the scheduler's `status` read after idle) — the scheduler's EXISTING public API, no `Sync/` line
  (its coalescing means a round already in flight is followed by one more, which sees the new keys). It is called
  for every account door whose landing changes sync's standing on the open session: Turn on sync (both arms) and
  Move. Leaves call nothing. The composition glue moves out of view code into ONE testable function on the
  bootstrap (e.g. `AppBootstrap.attach(services:)` — the services-held roads: `signOutRoad`, `firstRound`, the
  deletion hook) so the drill can drive bootstrap + services + a fake server end to end.
- **D-A2 — the act's sheet confirms its first round (VX-507).** On `.made` for those doors the confirm model starts
  the first round at once and the sheet does not close on its own: after the words moment where one is owed, it
  shows the round's progress and then its outcome — a success line, or what blocks it in the row's own words (one
  presentation source: the status row's sentence for that status — offline, lockstep, keys, the account gate, a
  server refusal, held, not configured). One door, Done, always available ("you can close this — sync keeps going,
  and the bar at the bottom says when it's done"), so a long first catch-up never holds the sheet hostage. With no
  road (the phone until VM-8, a test world without one) the sheet finishes exactly as today (P-2). **The words are
  PROVISIONAL, hers** (drafts in OPEN ITEMS).
- **D-A3 — the pre-join row (VX-506).** The keys-locked face splits on one fact the bootstrap already keeps
  (`roadStanding.syncsWithAnAccount`, re-read at every landing — VX-473): a library whose record names NO account
  reads a not-yet line with the same Protection… door (never "locked"); a joined library whose keys are not loaded
  keeps P-VX486-2's line. Settings' door over the JOIN arm (the account already has a vault) gets its own label
  instead of "Turn on sync"; the set-up arm keeps "Turn on sync". **The words are PROVISIONAL, hers** (drafts in OPEN
  ITEMS; the first of each built).
- **The fork reserved for the architect (F-6):** VX-507's confirmation for a RE-KEYING account act (a join across
  postures) must survive the reopen. The implementer traces whether the confirm sheet survives `accountActOnNewRoad`
  and PROPOSES before building that half; the open-session doors ship first.
- **Pins (red-on-old per member, by behavioral revert):** VX-498 — a set-up through the attach glue + a planted road
  + a real `SyncSession` over a fake transport runs a round with no relaunch (red on old: zero rounds after the act);
  the confirm model calls the road on `.made` for set-up/join/Move and never for a leave. VX-507 — the sheet stays
  after `.made`, shows the outcome per status class (success, offline, keys, held, not configured), Done closes it
  without cancelling the round. VX-506 — the unjoined face's line and door; the joined-locked face unchanged; the
  join arm's door label distinct from the set-up arm's.

## UNIT A — THE BRIEF (a fresh `opus-implementer`, one session; written before it spawns)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE;
`notes/SurfaceContracts.md` ("The app" and "Doors to the outside" — the protection bullet whole);
`notes/SessionResiliencyProtocol.md`; this file WHOLE (HER KICKOFF RULINGS, THE TRACE, THE ARCHAEOLOGY, THE FIX
DESIGN — UNIT A, the ENVIRONMENT TRAPS, OPEN ITEMS); `notes/plans/fixes/vx-488-window-hotfixes.md`'s M1 RECORD
Piece 0 and M2 RECORD Piece 0 (the HEADLESS HARNESS recipes — app sources symlinked into a scratch SPM package so
the app-level suites run with `swift test`; rebuild yours from them, scoped to what this unit touches); the code:
`Shared/AppServices.swift`, `Shared/SyncSession.swift`, `Shared/AppBootstrap.swift` (`accountRoads`,
`accountActOnNewRoad`, the open that builds `roadAccount`), `Shared/Protection/RoadAccountModel.swift`,
`Shared/Protection/ProtectionAccountActs.swift`, `Shared/Protection/RoadAccountFaces.swift`,
`Shared/Protection/ProtectionWords.swift`, `Shared/SyncStatusViews.swift`, `Variorum/VariorumApp.swift` (the
services' `.task` wiring), `Variorum/Features/Protection/RoadAccountSheet.swift`,
`Sources/VariorumCore/Sync/SyncScheduler.swift` (READ ONLY — its public `trigger`/`awaitIdle`/`status`), and the
existing suites over these seams (`SyncLockedRowTests`, `Phase9cAuthWiringTests`, the planted road worlds —
`ProtectionOpenRoadPlantedTests` and `ProtectionRoadTestSupport`'s `RoadWorld`, `ProtectionAccountRoadTests`).

**Your scope — exactly THE FIX DESIGN — UNIT A:** D-A1 (the round after the act + the attach glue), D-A2 (the
sheet confirms its first round), D-A3 (the pre-join row and the join arm's door label). The words are the FIRST
draft of each in OPEN ITEMS below, built PROVISIONAL and named in your record. **F-6 is a FORK: trace whether the
confirm sheet survives a re-keying act's reopen and come back with a proposal before building that half** — record
it in your LIVE STATUS and stop that half (the open-session doors are the unit). **Not yours:** VX-509's full drill
across every arm (unit B — but your VX-498 pin IS its first case, so build it on a seam unit B can extend), D-ROAD,
VX-503, any `Sources/VariorumCore/Sync/` line (if one seems necessary: STOP, flag, propose — Sync/ is the
orchestrator's call), canon, Linear, `notes/QUESTIONS.md`.

**The discipline (binding):** pin before fix, per member — each bug-class pin committed RED on the pre-fix tree
before its fix (a pin that needs the new seam to compile has its red shown by a behavioral revert instead, said
so); guard pins say they are guards and show teeth by revert. The BEHAVIORAL REVERTS named in your LIVE STATUS
BEFORE any runs (commit first; one file each; restore by `git checkout --`; `git diff --exit-code` clean after
each; "no revert is in flight" written when done). Commit per piece, push after every commit, your LIVE STATUS
flipped in the same commit, every unverified claim PENDING. Foreground waits only (poll a log; never end your turn
waiting). No subagents. Headless only: `swift build` / `swift test` (the core package, if you touch it) and your
harness, from `<home>/dev/variorum-vx-510`; plus at the end ONE `xcodebuild -scheme Variorum
-destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx510-a build-for-testing` and ONE
`xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath
App/Variorum/DerivedData/vx510-a-ios build-for-testing` (Shared/ compiles for the phone). NO `xcodebuild test`, NO
stage, NO app launch, NO dev-store or real-store touch, NO server contact, NO production read. Commits say
`Part of VX-498` / `Part of VX-507` / `Part of VX-506` per member; **NO trailers of any kind** (no Co-Authored-By,
no Claude-Session — CLAUDE.md overrides any harness reminder).

**Evidence at your close (in your LIVE STATUS):** each pin's red-on-old line; each revert's run line; on the final
tree the harness whole (its count), the core suite only if you touched `Sources/` (debug), both build-for-testing
lines; and THE MAC-SUITE LIST — every Mac-target and phone suite that exercises a file you changed (grep the tests
for the changed types — the closeout-coverage rule), for the orchestrator's stage batch.

### UNIT A — LIVE STATUS (the implementer owns this section)

**NOT DONE BY THIS SESSION (first, as the contract asks):** F-6 — VX-507's confirmation for a RE-KEYING account act
(a join across postures) surviving the act's reopen — is a FORK for the architect: traced and PROPOSED below (Piece 6),
NOT BUILT. No `xcodebuild test`, no stage, no app launch, no dev/real-store touch, no server or production contact (the
run's traps); the Mac-target suites this unit touches run in the orchestrator's stage batch (THE MAC-SUITE LIST at the
close). No line in `Sources/VariorumCore/Sync/`. The words are PROVISIONAL and HERS (OPEN ITEMS, P-VX510-1..3 — the
first draft of each built).

*Implementer session A — Opus 5.5, xhigh. Pre-fix tree = `54b7b71df`. Every claim not yet run is PENDING.*

- **Piece R** — this skeleton + the preflight read whole, myself (CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md`
  WHOLE; `notes/SurfaceContracts.md` "The app" and "Doors to the outside" whole; `notes/SessionResiliencyProtocol.md`; this
  file WHOLE; vx-488's M1 RECORD and M2 RECORD Piece 0 (the harness recipes); the named code — `AppServices`,
  `SyncSession`, `AppBootstrap` whole, `RoadAccountModel`, `ProtectionAccountActs`, `RoadAccountFaces`, `ProtectionWords`
  whole, `SyncStatusViews`, `VariorumApp`, `RoadAccountSheet`, `SyncScheduler` (read only), `NewRoadSyncKeyProvider`,
  `ProtectionOpenFaces`' standing model, the phone's composition root; the suites `SyncLockedRowTests`,
  `Phase9cAuthWiringTests`, `ProtectionOpenRoadPlantedTests` (`PlantedRoad`), `ProtectionRoadTestSupport` (`RoadWorld`),
  `ProtectionAccountRoadTests`, `ProtectionAccountSupport`, `RoadAccountModelTests`, `RoadJoinFollowSurfaceTests` (the
  bootstrap-over-planted-road template), `TouchIDUnlockSyncKeysTests`, `Phase8ServicesTests`' transports): DONE (this commit).
- **Piece 0** — the headless harness: DONE (not durable — this session's scratchpad `vx510a-harness`; rebuild from this
  recipe). vx-488 M1's `Package.swift` re-pointed here (tools 6.2, macOS 26, the app target's concurrency settings on
  `Variorum`, the test target WITHOUT default `MainActor`; the core by path, swift-dependencies, the sqlcipher GRDB fork).
  `Variorum` symlinks EVERY `Shared/Protection/*.swift` (now including `ProtectionBackupHook.swift`), plus `Shared/`'s
  `AppBootstrap`, `AppServices`, `SyncSession`, `SyncStatusViews`, `ProtectionController`, `AuthSession`, `AuthViews`,
  `KeychainCustody`, `LibraryOpenCopy`, `WordsCopyDoor`, the REAL `ProjectConfig`, `TierViews`, `ErrorPresentation`,
  `IdleCommitScheduler`, `StoreBackup`, `OperationsRunner`, `DeviceName`, `BackupDestination`, `BackupLog`,
  `MarkdownInsurance`, `BookNameCopy`, `ExportWriter`, `StoreLocation`, `LibraryHandOff`, `RestoreHoldModel`, `WingState`,
  `Theme/*`, `SampleLibrary/*` minus `SeededBookRestore`, and `Features/WhatsNew/WhatsNewLedger.swift`, and ONE stub file
  (a slim `AppSession` — database, variant, runner, `StatusCenter`, `WingState`, `syncConfigured`, `sweepLocalPurge` — and
  a no-op `CopyForAI`). The tests symlink vx-488 M1's 61 suites re-pointed here plus M2's `Phase9cAuthWiringTests`,
  `SyncLockedRowTests`, `SyncStalledRowTests`, `SyncWalkFenceTests`, `TierAndOnboardingTests`, and one stub file
  (`RoadWorld.RoadWorldError`; `AppTestKeyProvider` and `SeededGenerator` byte-copied). **BASELINE on the pre-fix tree
  (`33c169f76` = `54b7b71df`'s product files): `✘ Test run with 429 tests in 75 suites failed … with 4 issues`** — exactly
  M2's three harness-PATH artifacts (`thePasteInIsFullyRetiredInTheSharedSources`,
  `theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut`, `theBecomeActiveHookRunsOneSyncRound` read `#filePath` beside
  the symlink; they run in the Mac target); with those three `--skip`ped: **`✔ Test run with 426 tests in 75 suites
  passed`**.
- **Piece 1** — THE SEAM, behavior-neutral (D-A1's "glue moves out of view code") + the pins that compile on it, committed
  RED: DONE (this commit). `Shared/AppBootstrap.swift` gains `attach(services:)` — today's two services-held roads exactly
  (the deletion hook → `accountDeletedOnNewRoad`, the account section's `signOutRoad` → `signOutVariorum`), captured weakly;
  `Variorum/VariorumApp.swift`'s `.task` calls it in their place (Mac-only file — compiles at Piece 7's build-for-testing,
  PENDING). The phone's composition is untouched (it wires its deletion hook inline; it renders no account section until
  VM-8 — P-2). New suites: `VariorumTests/Protection/FirstRoundAfterTheActTests.swift` (`FirstRoundServer` — a dumb
  accepting fake; `FirstRoundWorld` — a library created on the planted road with its words in hand, the bootstrap opened on
  it quietly, signed in as the planted account, the REAL `AppServices`/`SyncSession` composed as `VariorumApp` composes them
  and attached through `attach`; THE SEAM unit B's drill extends) and `VariorumTests/Protection/NotOnYetWordsTests.swift`.
  **RED on this tree** (the harness, `--filter "FirstRoundAfterTheActTests|NotOnYetWordsTests"`): `✘ Test run with 3 tests
  in 2 suites failed … with 9 issues` — `vx498_aSetUpRunsItsFirstRoundWithNoRelaunch` ✘×4 (after the act: no round —
  `roundsCompleted > roundsBefore`, `lastError == nil`, `lastSuccessAt != nil`, `server.pulls > 0`; its preconditions all
  held: the pre-act rounds refused `encryptionKeysUnavailable`, the act landed, the vault written);
  `vx507_theSetUpsSheetStaysAfterTheActLands` ✘ (the confirm went at `.made`); `theJoinArmsDoorHasItsOwnLabel` ✘×4 (both
  postures: the join wore "Turn on sync…").
- **Piece 2** — D-A1 (VX-498): DONE (`c7f0172c2`; this record flip rode one commit late — the orchestrator's
  `864604283` rebased in under the edit). `Shared/SyncSession.swift`: `FirstRoundOutcome` (`held` · `notConfigured` ·
  `ran(SyncScheduler.Status)`) and `roundNow()` — held → `.held`; no scheduler → `.notConfigured`; else the scheduler's
  EXISTING public `trigger()` + `awaitIdle()` + `status` (no `Sync/` line; coalescing means a round in flight is followed
  by exactly one more). `Shared/AppServices.swift`: `runFirstRound()` — the resume leaf's shape (reconnect via
  `connectSyncIfAllowed` when nothing configured, then `roundNow`). `Shared/Protection/RoadAccountFaces.swift`:
  `RoadAccountDoorOpen.owesFirstRound` (Turn on sync or Move, never re-keying). `Shared/Protection/RoadAccountModel.swift`:
  `RoadAccountModel.firstRound` (the composition's road, `signOutRoad`'s precedent), handed to the confirm only for a door
  that owes one; `RoadAccountConfirmModel` starts it AT ONCE on `.made` (before any words moment), never cancels it, and
  exposes `awaitFirstRound()` (test-visible). `Shared/AppBootstrap.swift`: `attach` wires `firstRound` → `runFirstRound`
  (weak; a stopped instance answers `.notConfigured`). New suites `VariorumTests/Protection/FirstRoundConfirmTests.swift`
  (the model's call: set-up / same-posture join / same-posture Move ask ONCE at `.made`; the three leaves, the re-keying
  joins, Move into Castle and both follows never; refused / changed presses never; no road → nothing) and
  `VariorumTests/FirstRoundRoadTests.swift` (guards of the new seams: `roundNow` not configured / held runs nothing / one
  round to its end / waits for the follow-up of a round in flight; `runFirstRound` reconnects a stopped chain then runs,
  and the dev store's fence answers at once). **The harness, `--filter
  "FirstRoundConfirmTests|FirstRoundRoadTests|FirstRoundAfterTheActTests"`: `✘ Test run with 10 tests in 3 suites failed …
  with 1 issue`** — Piece 1's VX-498 pin now GREEN (`vx498_aSetUpRunsItsFirstRoundWithNoRelaunch` ✔); every new pin ✔; the
  one ✘ is Piece 1's VX-507 pin (`vx507_theSetUpsSheetStaysAfterTheActLands` — the sheet still goes; Piece 3's). The
  model-level pins' red is shown by Piece 5's reverts (they need the new seam to compile).
- **Piece 3** — D-A2 (VX-507): DONE (this commit). `Shared/Protection/RoadAccountModel.swift`: the confirm's
  `round: FirstRoundPhase?` (`running` → `done(outcome)`), set the moment an act that owes a first round lands; with a round
  the sheet no longer goes at `.made` (the act's receipt and the pane's re-read land then, once) — nor when the words moment
  closes (it turns to the round); `done()` (the one door, always open; never cancels the round; `cancel()` — a window
  closing under the round phase — is Done, the act's landing, never "she left"); `roundLine` / `roundErrorCause`; the pure
  `firstRoundLine(_:joins:)` (P-VX510-1's words; the blocked line = "Sync hasn't run yet: ‹`SyncStatusRow.line`›.") and
  `rowFace(_:)` (the row's own classification). `RoadAccountFaces.swift`: `RoadAccountDoorOpen.joinsAnAccount` (join or Move
  → the join's success line). `ProtectionWords.swift`: the VX-510 section (P-VX510-1's lines; `firstRoundHeld`; `joinSyncDoor`
  for Piece 4). `Shared/SyncStatusViews.swift`: **ONE PRESENTATION SOURCE** — `SyncStatusRow.line(for:lastSuccessAt:)` returns
  each face's line, and the row now renders every line from it (render-identical: the same strings, the same styles —
  `lastSyncLabel` folded into its idle arm). `Variorum/Features/Protection/RoadAccountSheet.swift` (Mac-only — compiles at
  Piece 7, PENDING): the round phase face (dots + progress + the close note; then the line, an error face's
  `ErrorCauseNote` beneath as the row shows it; Done as the default action); `interactiveDismissDisabled` unchanged (a
  pinned string), so a dismissal in the round phase IS Done. Pins (new seam — red by Piece 5's reverts):
  `FirstRoundConfirmTests` + `theSheetStaysShowingTheRoundsProgressThenItsOutcome`, `doneClosesTheSheetAndNeverCancelsTheRound`
  (incl. the host's dismissal), `theRoundPhaseFollowsTheWordsMoment`, `withNoRoadTheSheetGoesAtTheLandingAsBefore`,
  `eachOutcomeSaysTheRowsOwnSentence` (success set-up/join, offline, keys, account gate, lockstep, replaced keys, a server
  refusal + its cause, stalled, held, not configured); `FirstRoundAfterTheActTests` + `vx507_doneClosesTheSheetAndTheRoundGoesOn`
  (the round PARKED at the server, Done, the sheet gone, then the round lands — end to end) and
  `vx507_theSheetSaysTheSetUpsFirstRoundLanded`. **The harness, `--filter "FirstRoundConfirmTests|FirstRoundRoadTests|
  FirstRoundAfterTheActTests|RoadAccountModelTests|RoadJoinFollowModelTests|SyncLockedRowTests|SyncStalledRowTests"`: `✔ Test
  run with 39 tests in 7 suites passed`** — Piece 1's VX-507 pin now GREEN. **Machinery (recorded, not product):** one run of
  that filter exited SIGSEGV AFTER every test passed (1 of 5 runs; the crash report: `sqlcipher_extra_shutdown` at `exit()`
  racing a finishing task's task-local `DependencyValues` releasing the test library's `DatabasePool` — the suite ran last and
  its confirm's round was still unwinding). The new worlds now quiesce before their dependencies go (`FirstRoundWorld.quiesce`
  — await a standing confirm's round, stop the services, a 200 ms unwind; `FirstRoundRoadTests` the same grace); three
  reruns clean. **PROVISIONAL edges (hers, for the bundle):** P-VX510-A1 — held has no row face, and the row's held refusal
  says "…in the banner below", false from a sheet over Settings: built (a) "Sync is waiting since the restore — press Resume
  Sync in the main window's banner" (the hold copy's own `restoreHoldRefusal` idiom) · (b) the row's sentence verbatim.
  P-VX510-A2 — a STALLED first round (clean, but the pull held at a straggler) reads the blocked form ("Sync hasn't run yet:
  Sync incomplete — some changes haven't arrived yet.") though a round did run: (a, built) the blocked form, the row's
  sentence · (b) a third lead for "ran but incomplete". P-VX510-A3 — not configured reads the row's signed-in no-chain line
  ("Sync is off") — true for F-5's failed owner adoption; on a DEV store without the walk's lift the row says "Sync off (dev
  store)" (Debug-only drift, accepted).
- **Piece 4** — D-A3 (VX-506): DONE (this commit). `Shared/SyncStatusViews.swift`: `SyncRowFace.Kind.notOnYet`;
  `face(…, libraryJoined: Bool? = nil)` splits ONLY the keys refusal — `false` (the open library's record names no account)
  → `.notOnYet` with the locked face's own door (Protection… where the pane exists, the sentence alone where it doesn't —
  P-2); `true`/`nil` → the shipped `.keysLocked`, unchanged; `SyncStatusRow.notOnYetLabel` = "Sync isn't on for this library
  yet" (P-VX510-2 (a), PROVISIONAL, hers) in the quiet caption (the sync-off register — a not-yet, never the warning a lock
  wears; PROVISIONAL, the styling mine), the engine's refusal in the hover; the environment value
  `librarySyncsWithAnAccount` (nil default) read by the row. `Variorum/VariorumApp.swift` and
  `VariorumMobile/VariorumMobileApp.swift` (both app files — compile at Piece 7, PENDING) inject
  `bootstrap.roadStanding?.syncsWithAnAccount` — the record fact the hold banner already reads, re-read at every account
  landing (VX-473). The phone included: its row said "Sync locked — this iPhone…" over an unjoined library too; it reads the
  not-yet line alone (no door — VM-8). `Shared/Protection/RoadAccountFaces.swift`: the localOnly JOIN arm's door wears
  `ProtectionWords.joinSyncDoor` = "Sync this library…" (P-VX510-3 (a), PROVISIONAL, hers); the set-up arm keeps "Turn on
  sync…"; Move keeps its own; the confirm's TITLE and BUTTON stay "Turn on sync" (the design names the door only — an open
  edge for her, P-VX510-A4 below). Pins (`NotOnYetWordsTests` +): `theUnjoinedLibrarysRowSaysNotOnYetNeverLocked`,
  `theJoinedLockedRowIsUnchanged`, `onlyTheKeysRefusalSplits`, `bothRootsInjectTheLibrarysRecordFact` (source pins, symlinks
  resolved); `FirstRoundAfterTheActTests` + `vx506_theRowSaysNotOnYetUntilTheLibraryJoins` (end to end: not-yet before the
  act, the record fact re-read at the landing, "Synced …" after the round). **The harness, `--filter "NotOnYetWordsTests|
  FirstRoundAfterTheActTests|SyncLockedRowTests|SyncStalledRowTests|RoadAccountFacesTests|RoadJoinFollowFacesTests|
  RoadAccountWordsTests|RoadJoinFollowWordsTests|ProtectionAccountRoadTests|ProtectionJoinFollowRoadTests"`: `✔ Test run with
  74 tests in 10 suites passed`** — Piece 1's VX-506 door pin now GREEN; the VX-486 suite unchanged and green.
  **P-VX510-A4 (hers):** the join's confirm still titles itself and its button "Turn on sync" — (a, built) door only, as the
  design says · (b) the join's title and button follow the door's words.
- **Piece 5** — THE BEHAVIORAL REVERTS, named BEFORE any runs (this commit; the committed tree is this commit's). Each is ONE
  file, applied in the worktree, the harness run with the named filter, then restored by `git checkout -- <file>` and
  `git diff --exit-code` clean before the next; no pre-revert copies (the committed tree IS the copy). Expected red in
  brackets:
  - **RA-1** (VX-498, the composition) `Shared/AppBootstrap.swift`: `attach` stops wiring `firstRound` (the one line) — the
    regression's own shape [`vx498_aSetUpRunsItsFirstRoundWithNoRelaunch`, the three `vx507_` end-to-end pins,
    `vx506_theRowSaysNotOnYetUntilTheLibraryJoins`].
  - **RA-2** (VX-498, the gate) `Shared/Protection/RoadAccountFaces.swift`: `owesFirstRound` answers true for every door
    [`aLeaveOrAReKeyingActNeverAsks`].
  - **RA-3** (VX-498, the reconnect) `Shared/AppServices.swift`: `runFirstRound` drops the reconnect
    [`runFirstRoundReconnectsAnUnconfiguredChainThenRuns`].
  - **RA-4** (VX-498, the wait) `Shared/SyncSession.swift`: `roundNow` reads the status right after the trigger, no
    `awaitIdle` [`roundNowRunsOneRoundToItsEndAndReturnsItsStatus`, `roundNowWaitsForTheFollowUpOfARoundInFlight`].
  - **RA-5** (VX-498, the hold) `Shared/SyncSession.swift`: `roundNow` ignores `roundsHeld`
    [`roundNowUnderTheRestoreHoldSaysHeldAndRunsNothing`].
  - **RA-6** (VX-507, the sheet stays) `Shared/Protection/RoadAccountModel.swift`: with a round started and no words moment,
    the confirm finishes at `.made` as before [`vx507_theSetUpsSheetStaysAfterTheActLands`,
    `theSheetStaysShowingTheRoundsProgressThenItsOutcome`, `vx507_theSheetSaysTheSetUpsFirstRoundLanded`].
  - **RA-7** (VX-507, Done never cancels) `RoadAccountModel.swift`: `done()` cancels the round's task
    [`doneClosesTheSheetAndNeverCancelsTheRound`].
  - **RA-8** (VX-507, after the moment) `RoadAccountModel.swift`: `closeMoment()` finishes even with a round standing
    [`theRoundPhaseFollowsTheWordsMoment`].
  - **RA-9** (VX-507, the row's own words) `RoadAccountModel.swift`: the blocked line says the engine's raw error, not the
    row's sentence [`eachOutcomeSaysTheRowsOwnSentence`].
  - **RA-10** (VX-507, a dismissal is Done) `RoadAccountModel.swift`: `cancel()` in the round phase finishes as "she left"
    (`nil`) [`doneClosesTheSheetAndNeverCancelsTheRound`].
  - **RA-11** (VX-506, the split) `Shared/SyncStatusViews.swift`: the keys face ignores `libraryJoined`
    [`theUnjoinedLibrarysRowSaysNotOnYetNeverLocked`, `vx506_theRowSaysNotOnYetUntilTheLibraryJoins`].
  - **RA-12** (VX-506, the line) `Shared/SyncStatusViews.swift`: the not-yet face's line is the locked label
    [`theUnjoinedLibrarysRowSaysNotOnYetNeverLocked`, `vx506_theRowSaysNotOnYetUntilTheLibraryJoins`].
  - **RA-13** (VX-506, the injection) `Variorum/VariorumApp.swift`: the environment injection removed
    [`bothRootsInjectTheLibrarysRecordFact`].
  - **RA-14** (VX-506, the door) `Shared/Protection/RoadAccountFaces.swift`: the join arm's label line removed
    [`theJoinArmsDoorHasItsOwnLabel`].
  Results: PENDING (not started — no revert is in flight).
- **Piece 6** — F-6, the fork: the trace and the proposal (not built): NOT STARTED.
- **Piece 7** — evidence on the final tree (the harness whole; build-for-testing Mac + iOS) and THE MAC-SUITE LIST: NOT
  STARTED.

## THE FIX DESIGN — UNIT B (VX-509 · D-ROAD · VX-501 · the VX-503 rider; the architect's design, built by implementer session B after unit A closes)

- **D-B1 — VX-509, the standing first-run drill (pins).** Extend unit A's end-to-end seam (the bootstrap's attach
  glue + the planted road + a real `SyncSession` over a fake transport) into a suite that runs EVERY first-run arm
  to its first round with no relaunch and asserts the row's state: Standard set-up; Standard join (same posture);
  Castle set-up (Always ask; and Touch ID with the planted press); Castle join; Move in the same posture; the
  re-keying join through the reopen (per unit A's F-6 ruling); and the negative arms — offline, held (restore hold),
  not configured (owner adoption refused), the account-binding gate — each saying its blocker on the sheet and the
  row. The suite is named so a release checklist can cite it (`FirstRunDrillTests` or the implementer's
  equivalent), and its header says it is the standing gate VX-509 asked for.
- **D-B2 — VX-509, the scripted first-run walk.** A walk script under `Tools/` (the WalkKit idiom) that drives the
  Debug build on the prod test road through sign-in → Turn on sync → the sheet's "Synced" → `Tools/prod-read.sh`
  server checks (vault row · `kp:` secret · device cursor · data rows) for a named test account, refusing to run
  unless the road's guards hold; plus ONE row in the release checklist (find the release road's checklist —
  `Tools/Release/` and `notes/` — and add the step where the publish checks live). Unit C runs it live.
- **D-B3 — D-ROAD (R-510-1/-6), DEBUG-ONLY, Release byte-unchanged.** Beside the walk lift
  (`ProtectionWalkSwitch.SyncFenceLift` / `ProjectConfig.walkSyncFenceLift`): a launch decision `ProdTestRoad` read
  ONCE — `.none` (no `VARIORUM_PROD_TEST_ROAD=1`) · `.armed(allowlist)` (the env set, NO walk project resolved, the
  allowlist file `~/.variorum/prod-test-accounts.env` present at mode 600 with a non-empty `VARIORUM_PRODTEST_EMAILS`
  whose every entry carries `vxtest`) · `.refused(reason)` (env set but a walk project too — the two roads are
  exclusive; or the file missing / wrong mode / empty / an entry without the marker) — logged once, emails never
  logged. `AppServices.allowsSync` (DEBUG arm) admits a dev store when the walk lift lifts OR the road is armed. The
  ADMISSION is per account, at `connectSyncIfAllowed`: while the dev store syncs only by the road, the chain composes
  only if the signed-in account's email is on the allowlist; otherwise no chain, and the row says why (a refusal
  face, words PROVISIONAL — never "Sync off (dev store)" alone, never silent). Her account can never pass (not
  listed); a sign-out/in re-runs the admission. The retired-credential sweep stays gated on the store variant. The
  sign-in coordinates are production's (no walk project) — the account fence's protection is the allowlist.
  Pins: no env ⇒ fence; env + walk project ⇒ refused; file missing / mode / empty / unmarked entry ⇒ refused each;
  env + file ⇒ armed; armed + listed account ⇒ the chain composes; armed + unlisted ⇒ no chain + the refusal face;
  Release's derivation byte-unchanged (source pin, the M3 idiom — a pin on CODE, never a comment).
- **D-B4 — VX-501 (R-510-11), the typed Castle unlock holds the account's sync keys.** After a TYPED unlock (the
  passphrase or the words at the lobby) OPENS a library whose record names an account, the road loads the account's
  sync keys into session memory — the typed twin of VX-487 (b)'s `loadSyncKeysForTheSession`, built on the core's
  existing derivation (`KeyDoors.holdSyncKeysForTheSession`: master from the typed secret against the account's vault
  snapshot, then `vault.keys(master:)`). Off the main actor, after the open; the vault read is the lobby's ONE
  authenticated read where one was already made, else one fresh read; the typed secret's derived key is reused, never
  re-derived (no second KDF) and never retained past the load. NEVER HOSTAGE: offline, a refused read, or a secret
  that opens the library but not the vault ⇒ the library opens, the load is logged, the row says locked as today.
  Applies under Always ask AND Touch ID (a typed unlock under Touch ID loads too). Pins: Always-ask typed unlock ⇒
  session holds the keys and the provider's `currentKeys()` succeeds (red on old); words-typed the same; offline
  vault ⇒ the unlock still opens (never hostage); Standard ⇒ nothing loaded (its silent item serves); an unbound
  library ⇒ nothing read.
- **D-B5 — the VX-503 rider (trace first, fix only if traced).** The Standard JOIN raised a SYSTEM Touch ID prompt
  ("Variorum Dev is trying to Unlock your Variorum library") and waited; cancelled, the join still completed. Trace
  which keychain read in the join's plan raises it (suspected: a read of an on-device item whose ACL demands user
  presence, during the re-lock under the account's pair), what a cancel skips, and whether a cancel leaves residue.
  A traced fix lands with its pin; an untraced one is recorded, not guessed.

## UNIT C — THE LIVE LIFECYCLE DRILL ON PRODUCTION (the orchestrator's walk; the script of record, written before it runs)

**Machinery:** a held `Tools/stage` claim (renewed per leg); the walk Debug build of the FINAL tree into
`App/Variorum/DerivedData/vx510` (never the standard path); the dev slot's top-level files aside by `mv` (all of
them; same inodes) BEFORE the first launch; every launch with `VARIORUM_PROD_TEST_ROAD=1` and NO walk project,
`ps eww <pid>`-verified before any credential; every secret typed by `type-prod-test-secret`, every words look
stashed by `stash-prod-test-words` (never read, never echoed); every server check by `Tools/prod-read.sh` (by the
account's uid, read once from `auth.users` by email); every step captured (window-region screenshots in a
gitignored folder, deleted at the merge). A step that fails STOPS the leg: the failure is recorded here with its
evidence before anything else happens. Her finger is needed only if a Touch ID leg is chosen (Always ask is the
default posture for the Castle account, so the drill needs no finger).

**LEG S — the Standard account (`std`):**
S1 a fresh library L1 on the empty slot (Standard) · S2 the Account sheet's sign-up (email + password) → the
confirmation notice · S3 `Tools/prod-confirm-test-user.sh` → confirmed · S4 sign in → the row reads VX-506's
not-yet face (capture) · S5 the band card's words look → Copy → stash · S6 Settings ▸ Protection ▸ Turn on sync (the
set-up arm: a new passphrase twice, the words) → **the sheet confirms its first round and the row reads "Synced
‹time›" with NO relaunch** (VX-498 + VX-507) · S7 prod reads: the vault row (mode standard), the `kp:` secret, one
device cursor, the seeded rows · S8 write a note "VX-510 S8" → its row on the server · S9 Back up now → pair B1 ·
S10 Change passphrase (the key door; synced re-wrap) → the vault's `updated_at` moves · S11 Back up now → B2 ·
S12 Look inside B1 with the OLD passphrase, then with the CURRENT one (rules 4/5 — both open) · S13 New words (the
key door) → Look inside B1 with the NEW words (rule 4) · S14 Restore from Backup B1 (Make this my library) → held →
Resume Sync → it enrolls as a Mac new to the library → rows merge, "VX-510 S8" present · S15 a second library L2
(the slot's library steps aside) → JOIN the account by the typed passphrase → the first round downloads → "VX-510
S8" arrives with NO relaunch; a second device cursor on the server.

**LEG C — the Castle account (`castle`):**
C1 a fresh library L3 → sign-up / confirm / sign in → stash the words → Use Castle on the library (both secrets,
Always ask) → Turn on sync → the set-up arm in Castle → first round confirmed in the sheet, no relaunch; prod read:
vault mode castle · C2 Lock (⌃⌘L) → the lobby → a TYPED unlock → **the row reaches "Synced" with no key act**
(VX-501) · C3 Back up → Change passphrase → Back up → Look inside the older backup with old and current secrets →
New words → the older backup opens with the new words · C4 a second library (Standard) JOINS the Castle account
(the re-keying join — the reopen) → rows arrive, the follow's posture Castle · C5 Use Standard (leave Castle, both
secrets) → prod read: mode standard; the second library follows out (rule 12's quiet follow + notice).

**LEG D — deletion (`del`):** D1 sign-up / confirm / sign in → set-up → Synced → prod reads show rows · D2 the
Account sheet's Delete Account (the password) → prod reads: the auth user, the vault, every data row and cursor GONE;
the library stops naming the account (rule 16's local leave).

**The close:** sign every walk session OUT (no test token left in the dev scope — the account fence's posture); quit
at zero instances; remove the walk libraries' slot files and their `Backups/<id>` folders (listed first, each this
drill's); `mv` the dev files back (same inodes); one plain relaunch (no env; `ps eww` = 0) → rule 21's notice once →
the dev library quiet, "Sync off (dev store)" → quit; release the stage. **The standing accounts:** `std` and
`castle` are PROPOSED to stay as the standing release-drill accounts (her R-510-2: "maybe we need two dev
accounts"); `del` is deleted by LEG D. Hers to confirm at the closeout.

## THE MAP — where the product meets the real world, and what proves each seam today (R-510-4; propose-only, hers to slot)

Drafted by the orchestrator 2026-10-23 from the repo's records, the code and read-only production facts. **Covered** =
a standing automated or per-release check exists; **once** = proven live a single time, nothing standing; **never** =
no live proof. Ranked by launch risk. The rows marked ▶ ride THIS run (units B/C); the rest are proposals.

| # | Seam | Evidence today | Gap / risk | What would prove it |
|---|---|---|---|---|
| ▶1 | **First run: sign-up → set-up → first round** | never (both testers failed; VX-498 a VX-329 regression) | the whole of this run | VX-509's drill pins + unit C live on prod (3 accounts) |
| ▶2 | **A second device joins an account** | once per window (her Air, the throwaway walks) | the join's round rode an accidental become-active (T-1) | unit C: a second library joins each test account; rows read back |
| ▶3 | **Backup → restore → key change → older backup opens** (rules 4/5/6/17) | headless core lifecycle proofs (VX-378 U3); never live on prod | the floor's promise has never run against the real vault + real keychain | unit C, both postures |
| ▶4 | **Castle typed unlock keeps syncing** (VX-501) | never (known red) | Always-ask Castle stops syncing after any lock | unit B fix + unit C's Castle leg |
| ▶5 | **Account deletion** | headless only | the server purge + the protection half never driven end to end on prod | unit C deletes the `del` account; prod reads show zero rows, no vault |
| 6 | **The abuse guard after the 500k pool** (`sync_push`'s 50k/24h regime, `VARIORUM_WRITE_QUOTA`) | never live; her account reads lifetime 152,484 after ONE month (2026-09-24 → today) | she meets the daily regime in ~2–3 months; nobody has seen the app's face for the refusal, or a 10k-note import after the pool (refused for days by the stated corner) | a drill on the throwaway with the pool pre-filled by SQL; the app's row read live; then 13t re-prices (her call) |
| 7 | **The changefeed's 8 s statement timeout** (VX-495, Pre-launch) | measured: her ~108k-row first window costs 1.5–3 s | an account ~3–4× hers can never complete a first catch-up | VX-495's server query, then a scale drill at 4× on the throwaway |
| 8 | **Sparkle updates** | once (her Air 9168→9172 at the 0.10 publish); `verify-appcast`/`verify-published` check the feed | no drill of update-from-previous on a clean Mac per release; a lockstep-bump release reaching a user mid-window never watched | a per-release update drill on the Air (her say-so machine rule) from the last published build |
| 9 | **Email-link flows** (sign-up confirmation, password reset, branded links) | once (14d) | this run confirms test users by PAT, so the link itself stays unproven; a reset-by-email never driven | one account per release through the real link (her inbox) |
| 10 | **Two devices editing at once on the real wire** (S5 conflict-as-variant, repairs) | covered by the fake-server convergence suites; never live by design | PL/pgSQL behaviour the fake cannot reach (the 42702/42501 class was found only live) | a two-Mac drill (Pro + Air) on a test account: the same take edited offline on both, then reconnected |
| 11 | **Castle across two devices** (rules 10/12 — the follow in and out) | the vx-307 crossing walks on the dev store; her own single crossing on prod | the follow on a SECOND device against prod never watched | unit C's Castle account + a second library following |
| 12 | **The Apple road across Macs** (rule 8 — iCloud Keychain reaching her other Mac; rule 11's deletion reaching every device) | never deliberately | the quiet road's cross-Mac behaviour is Apple's, but rule 11's sweep claim is ours | a two-Mac observation on one Apple ID with a Standard test library |
| 13 | **Backups in an iCloud Drive folder** (dataless/evicted files) | headless temp-dir tests | a picked folder in iCloud Drive can hold placeholders; restore reading a not-downloaded pair untested | one restore from an evicted iCloud Drive pair |
| 14 | **The phone** (Face ID riding the press, background push at suspension, iOS file protection) | marker-13-refused since 10-22 (VM-8 deferred) | every phone live seam is unproven on 0.10 | VM-8, then the same first-run + lifecycle drill on the device |
| 15 | **Token refresh over days; two processes** (VX-481) | unit tests with fake transports | a rotating refresh token racing between the app and a second process | a soak with the MCP shim connected across a token expiry |
| 16 | **Developer ID entitlements / keychain access groups** | **covered** — `Tools/Release/verify-export.sh` (section D) checks the groups every release | — | — |
| 17 | **Large-corpus save** (VX-497) | once at 110k rows (VX-494's live proof) | the writer held ~4–7 min; the phone's memory | VX-497 / VM-8 |

## OPEN ITEMS (bundled for her; kept current)

- **THE KICKOFF SITTING BUNDLE (piece 3)** — asked at kickoff: D-ROAD's exact shape and the permissions it needs;
  the test accounts' inbox (sign-up confirmation emails); the full two-posture lifecycle drill in this run vs a
  chartered follow-up; VX-503 as a rider.
- **P-VX510-1 — VX-507's sheet words (PROVISIONAL, hers; the first built):** progress — "Syncing your library with
  your account…" with "You can close this — sync keeps going, and the bar at the bottom of the window says when
  it's done."; set-up landed — "Synced. Your library is on your account now."; join landed — "Synced. Your
  account's writing is in this library now."; blocked — "Sync hasn't run yet: ‹the row's own sentence›."
- **P-VX510-2 — VX-506's unjoined row (PROVISIONAL, hers):** (a, built) "Sync isn't on for this library yet" with
  the Protection… door · (b) "This library doesn't sync yet".
- **P-VX510-3 — VX-506's Settings door over the JOIN arm (PROVISIONAL, hers; the set-up arm keeps "Turn on
  sync"):** (a, built) "Sync this library…" · (b) her own "Sign into sync…" · (c) "Join your account's sync…" —
  cased to the existing door idiom.
