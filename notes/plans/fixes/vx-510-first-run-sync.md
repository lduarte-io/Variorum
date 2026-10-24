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
- **R-510-13 — the words: "your word choices are fine for now and we'll keep moving forward provisionally."** →
  P-VX510-1…3 and P-VX510-A1…A4 (+ the not-yet row's quiet style) STAND as built, provisional; no re-ask until the
  closeout's canon pass.
- **R-510-14 — VX-511, the words card after a join: "Join retires the card (Recommended)"** → IN THIS RUN (unit B2,
  D-B6): an account act that lands with the library holding the account's pair marks the library's words recorded;
  Settings ▸ New Words stays the deliberate door. Linear: parented under VX-510.
- **R-510-15 — VX-513, the read-only check: "Yes, in this run (Recommended)"** → IN THIS RUN (unit B3, D-B7, its own
  small session after B2 — a new face). Linear: parented under VX-510.

## HER AIR REPORT (2026-10-23 evening, after the 0.10 update — her words verbatim, each item traced and dispositioned)

1. **"I tried running the variorum mcp reconnection on my macbook air post update and my variorum mcp connection is
   refusing with: Failed to connect to Variorum -32000. re-set up? unexpected or normal?"** — EXPECTED by construction:
   the MCP on-switch and every client binding live in the library's LOCAL-ONLY grants tables (`MCPSwitch.server`
   reads OFF with no row — `Sources/VariorumCore/Queries/MCPGrantQueries.swift`), and the crossing's Start fresh made
   a new library; the shim's -32000 is its "MCP server is not running" refusal (`MCPShim.refusalMessage(.notRunning)`).
   Remedy: Settings ▸ MCP ▸ Enable, then re-run each client's setup. The silence is a gap → **VX-512** (Improvement,
   Confirmed, MCP, Medium).
2. **"I also do have a 12 words popup banner which is weird since i had 12 words before this migration already"** — a
   REAL FINDING: the band card's ledger is marked recorded by the look, Make this my library's carry and the empty-slot
   landing, never by a JOIN; the card's look mints fresh words through rule 6's act, which on a synced library re-wraps
   the ACCOUNT's vault lock — so pressing the card would silently replace her account's recovery words. → **VX-511**
   (Bug, Confirmed, Castle & sync, High). Her safe move now: ✕ (or Later), never the card.
3. **"I also no longer seen an option in settings to test your passphrase / 12 words to make sure you have them
   right. Should I reset my 12 words?"** — the new road has no read-only check (the key doors only change secrets) →
   **VX-513** (Feature, Castle & sync, Medium). Answer: do NOT reset — her words should still be the account's (a join
   adopts the account's pair, rule 7). The read-only check today: Settings ▸ Data Safety ▸ Back up now, then Look inside
   that backup and type the twelve words (rule 17 — Look inside writes nothing; `LookInsideModel` reads twelve valid
   words as the words).
4. **Seen in her screenshot (not asked):** two seeded Sherlock books on Welcome, both owned — server-side, both
   created_at 1892-10-14, updated 10-07 (13 members) and 10-18 (14 members), so on every device and older than 0.10
   → **VX-514** (Bug, Suspected, Books, Low) — **CLOSED at her word, not a bug:** "you don't need to worry about the
   sherlock holmes double book. that's because i had edited one of them before we did the deduplication things. it's
   not a bug but i will delete one of them." (The dedupe kept both by design — an edited copy is never retired.)
5. **"how am I supposed to be able to grant multiple wings to claude code? I don't see the option to add another one
   here and when I added it, it was in the old MCP pane"** (her screenshot: Shared with AI, one PlanetLillian wing grant
   with Change… · Revoke) — WORKS, but hidden: the Clients tab's per-client "Change…" opens the grant sheet FRESH
   (`MCPGrantOpening(client:, approving: false)`, `replacing: []` — `MCPPane.clientRow`; nothing replaced), and ⌥⌘A opens
   the same sheet from anywhere (WHERE: a note · a book · a wing; one standing row per client × place since VX-393, so a
   second wing is a second row). Shared with AI's own Change… REPLACES. The labelling is the gap → **VX-515**
   (Improvement, Confirmed, MCP, Medium).
6. **"it keeps just changing what is shown though - it doesn't show both & I can see that the other one is revoked
   when I grant that one. file a ticket for it - this needs to be fixed but definitely not in this run. there also needs
   to be a way to see everything you've granted, following that more will be granted… Just let me know if you add that
   to VX-515."** — **The orchestrator's item-5 reading was WRONG in practice** (it read only the sheet's opening —
   `replacing: []`): a second wing grant REVOKES the first. Not the schema (`uq_mcp_grant_standing_place` is per client ×
   scope kind × scope id — `MCPGrantSchema.swift:263`); untraced, suspected in the grant road's upgrade-in-place.
   → **VX-516** (Bug, Confirmed, MCP, High; NOT this run, her word). Her "see everything granted" ask ADDED to VX-515
   (now two asks: a visible add door + one place listing every grant).
7. **"would it be better for the debug app to be less sandboxed? I just want the testing to catch any real issues."** —
   ANSWERED: no — the Release app is sandboxed, so a Debug app with a wider sandbox would test a different app and hide
   exactly the failures worth catching (the keychain access groups, file reach, the MCP socket's container path all live
   inside the sandbox). The closer Debug stays to Release, the more a walk proves; that is why F-B1-1 was ruled (B) — the
   test machinery reaches around the sandbox from outside, the app's own sandbox stays identical to Release's.
8. **"I'm off the pro, so go ahead with the walk"** — the stage is the walk's (claim `vx-510`).

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
| 4 | The fixes: VX-498 + VX-507 + VX-506 (+ VX-503 if open), pins red-on-old per member | UNIT A DONE (`33c169f76`…`92bd0740a`; harness 449/79 green; 14 reverts red as named; Mac + iOS build-for-testing green; re-run by the orchestrator 37/6 green); F-6 RULED (A) → unit B1; **the stage batch at `92bd0740a`** (a detached clean checkout `~/dev/variorum-vx-510-stage`, stage claim `vx-510`, the WHOLE Mac target): `✔ Test run with 5141 tests in 902 suites passed after 2188.113 seconds with 14 known issues`, `** TEST SUCCEEDED **` (VX-494's closing 5118/898 + unit A's 23 tests in 4 suites, exactly); stage released |
| 5 | VX-509 — the standing first-run drill (state-transition pins at the act→scheduler seam + the scripted walk on the release checklist) | UNIT B1 DONE (`2576629c7`…`31b8e2636`; `FirstRunDrillTests` every arm + the negatives; `Tools/WalkKit/first-run-walk.sh` + release.sh's step-0 gate row; harness 477/82 green; 18 reverts red as named; re-run by the orchestrator 48/6 green); the Mac stage batch PENDING (the closing run) |
| 6 | D-ROAD — the named prod test-account road (the fence exception per R-510-1), with its pins | DONE — unit B1 (D-B3) + unit B2's F-B1-1 (`4a5ef39e3`: the list rides `VARIORUM_PRODTEST_EMAILS` in the launch env); ARMED and used live through unit C (three accounts) |
| 6b | VX-501 (typed Castle unlock loads the sync keys) + VX-511 (a join retires the words card) + the VX-503 trace | UNIT B2 DONE (`4a5ef39e3`…`f4af7e368`; harness 502/85 green; reverts RF-1…6, RD4-1…8, RD6-1…5, RD5-1…2 red as named; Mac + iOS build-for-testing green; claims spot-checked by the orchestrator); VX-501 + VX-511 GREEN LIVE on production (unit C C2/C4); VX-503 fixed (`226cf7c20`); T-B5-2 → **VX-517** (Needs Lillian); the Mac stage batch PENDING (the closing run) |
| 6c | VX-513 (the read-only check-your-secrets door) | IN FLIGHT — unit B3 (D-B7); its live walk on the synced arm follows on the held walk setup |
| 7 | THE ACCEPTANCE — several fresh accounts end-to-end on production, server-verified | LEGS S · D · C PASS (unit C — THE RECORD): three fresh accounts (std, del, castle) set up with no relaunch, server-verified; both postures; key changes; backups; typed secrets; a second library's join in each posture; Delete Account; Use Standard. Unit C's close (cleanup + dev store back) after B3's walk |
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
  **RESULTS — DONE, every one RED as named, every restore `git diff --exit-code` clean; NO REVERT IS IN FLIGHT** (the
  committed tree `1e9fb6e9c`; the harness's runner script `reverts/run.sh` in the session scratchpad, each run filtered):
  - **RA-1** `--filter FirstRoundAfterTheActTests`: `✘ Test run with 5 tests in 1 suite failed … with 9 issues` —
    `vx498_aSetUpRunsItsFirstRoundWithNoRelaunch` ✘×4, `vx507_theSetUpsSheetStaysAfterTheActLands` ✘,
    `vx507_doneClosesTheSheetAndTheRoundGoesOn` ✘, `vx507_theSheetSaysTheSetUpsFirstRoundLanded` ✘,
    `vx506_theRowSaysNotOnYetUntilTheLibraryJoins` ✘×2. (Its FIRST run HUNG: the Done pin waited at the server for a round
    nothing started; the helper was killed, the script restored the file — clean — and the pin now fails fast,
    `1e9fb6e9c`; the runner gained a 240 s watchdog.)
  - **RA-2** `--filter FirstRoundConfirmTests`: `✘ … 8 tests in 1 suite failed … with 24 issues` —
    `aLeaveOrAReKeyingActNeverAsks` ✘×24 (every leave, re-keying join, Move into Castle and follow owed and asked).
  - **RA-3** `--filter FirstRoundRoadTests`: `✘ … 5 tests in 1 suite failed … with 1 issue` —
    `runFirstRoundReconnectsAnUnconfiguredChainThenRuns` ✘ (`.notConfigured`, never reconnected).
  - **RA-4** `--filter FirstRoundRoadTests`: `✘ … 5 tests in 1 suite failed … with 6 issues` —
    `roundNowRunsOneRoundToItsEndAndReturnsItsStatus` ✘×3, `roundNowWaitsForTheFollowUpOfARoundInFlight` ✘×2,
    `runFirstRoundReconnectsAnUnconfiguredChainThenRuns` ✘ (the status read mid-round).
  - **RA-5** `--filter FirstRoundRoadTests`: `✘ … 5 tests in 1 suite failed … with 2 issues` —
    `roundNowUnderTheRestoreHoldSaysHeldAndRunsNothing` ✘×2 (a round ran under the hold).
  - **RA-6** `--filter "FirstRoundConfirmTests|FirstRoundAfterTheActTests"`: `✘ … 13 tests in 2 suites failed … with 6
    issues` — `theSheetStaysShowingTheRoundsProgressThenItsOutcome` ✘×2, `doneClosesTheSheetAndNeverCancelsTheRound` ✘×2,
    `vx507_theSetUpsSheetStaysAfterTheActLands` ✘, `vx507_theSheetSaysTheSetUpsFirstRoundLanded` ✘.
  - **RA-7** (same filter): `✘ … 13 tests in 2 suites failed … with 2 issues` — `doneClosesTheSheetAndNeverCancelsTheRound`
    ✘×2 (`cancelledAtResume == false` failed, twice — Done cancelled the round's task). The end-to-end
    `vx507_doneClosesTheSheetAndTheRoundGoesOn` stayed green under it: cancelling the WAITER never reaches the scheduler's
    round (it runs on its own task, `awaitIdle` is a plain continuation) — the mechanism that makes Done safe by design.
  - **RA-8** `--filter FirstRoundConfirmTests`: `✘ … 8 tests … with 1 issue` — `theRoundPhaseFollowsTheWordsMoment` ✘.
  - **RA-9** (same): `✘ … 8 tests … with 8 issues` — `eachOutcomeSaysTheRowsOwnSentence` ✘×8 (every blocked class said the
    engine's raw text).
  - **RA-10** (same): `✘ … 8 tests … with 1 issue` — `doneClosesTheSheetAndNeverCancelsTheRound` ✘ (`finished == [nil]` —
    a dismissal read as "she left").
  - **RA-11** `--filter "NotOnYetWordsTests|FirstRoundAfterTheActTests"`: `✘ … 10 tests in 2 suites failed … with 6
    issues` — `theUnjoinedLibrarysRowSaysNotOnYetNeverLocked` ✘×4, `vx506_theRowSaysNotOnYetUntilTheLibraryJoins` ✘×2.
  - **RA-12** (same): `✘ … 10 tests in 2 suites failed … with 4 issues` — `theUnjoinedLibrarysRowSaysNotOnYetNeverLocked`
    ✘×3, `vx506_theRowSaysNotOnYetUntilTheLibraryJoins` ✘.
  - **RA-13** `--filter NotOnYetWordsTests`: `✘ … 5 tests … with 1 issue` — `bothRootsInjectTheLibrarysRecordFact` ✘.
  - **RA-14** (same): `✘ … 5 tests … with 4 issues` — `theJoinArmsDoorHasItsOwnLabel` ✘×4 (both postures).
- **Piece 6** — F-6, THE FORK: TRACED and PROPOSED — NOT BUILT (this commit). The open-session doors are the unit and ship;
  a re-keying act (a join across postures; Move across postures; every follow) keeps today's close at `.made`
  (`owesFirstRound` false — pinned in `aLeaveOrAReKeyingActNeverAsks`), and its round still comes through the rebuild.
  **THE TRACE** (code read whole, then a TRANSIENT harness probe — never committed, removed after its run — over
  `FirstRoundWorld` with `onWillLock` mimicking production's stop, a Castle vault planted so the join entered Castle):
  1. The press: `AppBootstrap.accountRoads().press` → `request.shown.rekeys` → `accountActOnNewRoad` (AppBootstrap.swift:998,
     :1175) → preflight (reads) → `reopenAround` (:1151): `await onWillLock?()` (:1155 — production's
     `macWillLock { services?.stop(); services = nil }`, VariorumApp.swift:286/:293: THE SERVICES STOP AND ARE RELEASED) →
     `state = .opening` → the act off the main actor → `beginOpening(unlockedKey:)` + `awaitOpen()` (:1163) → `finish(.ready)`.
  2. **The confirm SURVIVES the reopen.** It lives in the bootstrap-owned presenter beside `roadAccount` (made once,
     :367); only a non-ready settle drops the presenter's sheet (:333 — `libraryClosed`). While Settings' pane is down
     (`SettingsSceneContent`'s `.opening` arm, :65/:140) its sheet host goes and the host's dismissal calls the confirm's
     `cancel()` (ProtectionSheetPresenter.swift:134), which the act's `busy` guard refuses (RoadAccountModel.swift:302);
     the returning pane re-presents the same model. Probe: `the confirm survives the reopen=true`, `presenter sheet id ==
     confirm id: true`, the words moment standing after it (`notShown`).
  3. **`.made` comes back AFTER the reopen settled** (probe: `state ready=true sawOpening=true onWillLock ran=1`, a new road
     session in Castle) — but **the services that would run a round do not exist yet**: the old ones were stopped and released
     by the teardown (probe: `the old services' chain configured=false`), and the new ones are composed by the main window's
     `.task` (VariorumApp.swift:219 `guard services == nil` → `AppServices(…)` → `bootstrap.attach(services: fresh)` :255 →
     `fresh.start()`), which runs only when SwiftUI re-renders the new `.ready` arm — after the press returned. So asking
     `roadAccount.firstRound` at `.made` would reach the released instance (weak → nil → `.notConfigured` — a false "Sync is
     off"), never the round the reopen's fresh services start on their own (`start()` → `connectSyncIfAllowed` → a trigger).
  **THE PROPOSAL (the architect's call):**
  - **(A — RECOMMENDED) the confirm waits for the reopen's services, then asks.** `AppBootstrap` keeps a services
    generation: `attach(services:)` bumps it and resumes waiters; a new `awaitAttachedServices(newerThan:)` (bounded — e.g. 30
    s, then `nil` → `.notConfigured`, since a closed main window never composes services) is the re-keying act's road:
    `roadAccount.firstRound` stays for the open session; a second road `firstRoundAfterReopen` takes the generation
    BEFORE the press and, at `.made`, awaits the next attach and asks THAT instance's `runFirstRound()` (which coalesces with
    its start's own round). The sheet already survives the reopen (2), so D-A2's phase shows unchanged; `owesFirstRound`
    widens to re-keying joins and Move (the follow too — its Done is VX-457's durable notice; the round line would sit beside
    it). Cost: one small bootstrap seam + the model choosing the road by `rekeys`; pins on `FirstRoundWorld` extended with
    an `onReady` hook that composes and attaches fresh services as `VariorumApp`'s `.task` does. No `Sync/` line.
  - **(B)** the bootstrap composes the services itself at each ready (out of `VariorumApp`'s `.task` — the backup hook, the
    hold's gates, `onWillLock`, the launch furniture), so `reopenAround` can hand the reopened instance to the act's result.
    Cleaner ownership, but a composition-root move on BOTH platforms — architect-scale, not this unit.
  - **(C)** accept the asymmetry: re-keying acts close at `.made` as today; their round runs through the rebuild and the row
    says it (and the follow's Done stays the durable notice). Cheapest; VX-507's letter then holds for the open-session doors
    only — hers to accept.
- **Piece 7** — EVIDENCE: DONE (the final tree = `c405f7a09`'s product files; foreground, in sequence):
  - THE HARNESS whole (debug; the four new suites symlinked in): `✘ Test run with 452 tests in 79 suites failed … with 4
    issues` — exactly the baseline's three harness-PATH artifacts (Piece 0); with those three `--skip`ped: **`✔ Test run
    with 449 tests in 79 suites passed`** (426/75 + this unit's 23 tests in 4 suites); no `signal` line.
  - RELEASE COMPILE (the harness's app sources, `swift build -c release --target Variorum`): **`Build complete!`**.
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx510-a
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `xcodebuild -scheme VariorumMobile -destination
    'generic/platform=iOS Simulator' -derivedDataPath App/Variorum/DerivedData/vx510-a-ios build-for-testing`: **`** TEST
    BUILD SUCCEEDED **`** — zero errors, and no warning in any file this unit touched (both logs grepped). (The Mac-only
    files — `VariorumApp.swift`, `RoadAccountSheet.swift` — and the phone's `VariorumMobileApp.swift` compile here; their
    PENDINGs above are discharged.)
  - Not run (no file touched): the core package (`Sources/` and `Tests/` untouched — no `Sync/` line).
  - **Machinery honesty:** the orchestrator committed to this branch IN THIS WORKTREE while the unit ran (`864604283`,
    `0043d2bf3`, `0c0019741`, `7e51c517e`, `2a1410377`, `43cd52b1f`, `9d092a1f2` — its own record sections and `Tools/`); this session staged
    explicit paths only, re-read the record before each edit, and never touched those files.
  **THE MAC-SUITE LIST (for the orchestrator's stage batch — every suite exercising a file this unit changed):**
  - NEW (harness-green): `FirstRoundAfterTheActTests`, `FirstRoundConfirmTests`, `FirstRoundRoadTests`, `NotOnYetWordsTests`.
  - `AppBootstrap` (`attach`): `AppBootstrapOffMainTests`, `LibraryHandOffTests`, `OneRefreshAuthorityTests`,
    `Phase9cAuthWiringTests` (its three source pins run only here), `QuickEntryLaunchFocusTests`, `SettingsLockCloseTests`,
    `WhatsNewWaitsAfterAdoptionTests`, and in `Protection/`: `CopyListingFacesSurfaceTests`, `EmptySlotDoorsSurfaceTests`,
    `EmptySlotMakeMineRouteTests`, `ExportNoticeByLibraryTests`, `FollowDoneNoticeTests`, `HoldBannerAccountTests`,
    `LookInsideCopyDoorTests`, `MakeMineRouteTests`, `OneSyncKeysLeafTests`, `OtherLibrariesDeleteRouteTests`,
    `PlaintextExportBringInRouteTests`, `PreDesignLandingsRouteTests`, `PreDesignStartFreshRouteTests`,
    `PreviousLibrariesArcTests`, `ProtectionCrossingRouteTests`, `ProtectionFacesRouteTests`, `ProtectionRoadRouteTests`,
    `ReadmeStartHerePlanTests`, `RoadAccountSurfaceTests`, `RoadIdleDialRouteTests`, `RoadJoinFollowSurfaceTests`,
    `RoadKeyDoorSurfaceTests`, `RoadLockRouteTests`, `SetPassphraseRowRereadRouteTests`, `WordsBandSurfaceTests`,
    `WordsConcealedClipboardTests`, `WordsLedgerCarryRouteTests`.
  - `AppServices` / `SyncSession`: `KeychainOffMainTests`, `SyncWalkFenceTests`, `TierAndOnboardingTests`,
    `LibraryPortabilityDoorTests`, `Phase8ServicesTests`, `SampleLibraryDedupeFactsTests`.
  - `SyncStatusViews` (the row's one presentation source, `.notOnYet`): `SyncLockedRowTests`, `SyncOutOfDateFaceTests`,
    `SyncStalledRowTests`, `TierAndOnboardingTests`.
  - `RoadAccountModel` / `RoadAccountFaces`: `PassphraseFloorRoadTests`, `ProtectionPaneWaveTests`, `RoadAccountModelTests`,
    `RoadJoinFollowModelTests`, `ProtectionAccountRoadTests`, `ProtectionJoinFollowRoadTests`, `RoadAccountFacesTests`,
    `RoadJoinFollowFacesTests`.
  - `RoadAccountSheet.swift` (source pins + hosted): `WordsFieldsConcealTests`, `SettingsAccountSearchTests`,
    `SettingsAccountSurfaceTests`, `TravellingDotsIndicatorTests` (+ the surface suites above).
  - `VariorumApp.swift` (source pins): `MCPAsksWaitTests` (+ `Phase9cAuthWiringTests`, `HoldBannerAccountTests`,
    `EmptySlotDoorsSurfaceTests`, `OneRefreshAuthorityTests`, `WhatsNewWaitsAfterAdoptionTests` above).
  - `ProtectionWords` (new constants only; the string-pinning suites): `ProtectionWordsPlanTests`,
    `ProtectionWordsVX307Tests`, `RoadAccountWordsTests`, `RoadJoinFollowWordsTests`, `RoadKeyDoorWordsTests`,
    `U2WordsTests`, `LibraryWordsCardTests`, `WordsBandTests`, `WordsLedgerCarryRoadTests`. (Every `Protection/` suite reads
    `ProtectionWords` — the simplest honest batch is the whole `VariorumTests/Protection` folder plus the top-level suites
    named above.)
  - THE PHONE (`VariorumMobileTests` — `AppServices`/`SyncSession`/`AppBootstrap`, and `VariorumMobileApp.swift`'s one line):
    `MobileEmptyStoreTests`, `MobilePerfWalkTests`, `MobileQuickNoteReadFailureTests`, `MobileStarterJournalTests`.
  **THE WALK (unit A's rows, for the stage — use-shaped, not this session's):** on the DEV-store Debug build under the walk's
  lift: (1) signed in, an unjoined library — the row reads "Sync isn't on for this library yet" with Protection…; (2) Turn on
  sync (set-up) — the sheet stays, "Syncing your library with your account…", then "Synced. Your library is on your account
  now."; the row reads "Synced ‹time›" with NO relaunch; (3) Done while a long round runs closes the sheet, the row finishes
  it; (4) a second library over the same account — the door reads "Sync this library…", the join's words moment, then the
  round phase and "Synced. Your account's writing is in this library now."; (5) a blocked round (offline) — "Sync hasn't run
  yet: Waiting to sync (offline)." Both voices where the sheet has a face.

## UNIT A — THE ORCHESTRATOR'S VERIFICATION AND RULINGS (2026-10-23, after implementer session A closed)

- **Verified, not trusted:** the commit chain `33c169f76 … 92bd0740a` read; the product diff read whole for the seam
  (`AppBootstrap.attach(services:)`, `AppServices.runFirstRound`, `SyncSession.roundNow` — the scheduler's existing
  public API only, the hold and not-configured honest, nothing cancels a round; `RoadAccountConfirmModel`'s round phase;
  `VariorumApp`'s one `attach` line); no `Sources/` line. **Re-run by the orchestrator** in the implementer's harness
  (`--filter "FirstRound|NotOnYet|SyncLockedRow|RoadAccountModel"`): `✔ Test run with 37 tests in 6 suites passed`.
- **F-6 — RULED (A), by the architect under the mandate:** the confirm waits for the reopen's services, then asks.
  Reasons: her VX-507 words ("it said sync is set up" while nothing had synced) bind every act that says "done",
  re-keying joins included — a Standard library joining a Castle account is exactly a second device's first run; (B)
  moves the composition root on both platforms (architect-scale, out of proportion); (C) leaves VX-507's letter true
  for only half the doors. Built in unit B1 (D-B0 below); the follow keeps VX-457's durable Done beside the round line.
- **Unit B is SPLIT into two implementer sessions** (unit A spent ~630k tokens — past the ~500k guideline — on a
  smaller scope): **B1** = D-B0 + D-B1 + D-B2 + D-B3 (F-6, the drill, the walk script, the prod road — what unit C
  needs first); **B2** = D-B4 + D-B5 (VX-501's custody seam, the VX-503 trace). Still one ruled unit of the run.
- **Her word bundle gains unit A's items** (OPEN ITEMS): P-VX510-A1…A4 and the not-yet row's quiet style.

## UNIT B1 — THE ORCHESTRATOR'S VERIFICATION AND RULINGS (2026-10-23, after implementer session B1 closed)

- **Verified, not trusted:** the commit chain `2576629c7 … 31b8e2636` read; the product diff read for the seams
  (`AppServices`' DEBUG fence derivation — Release's line byte-unchanged —, `prodTestRoadAdmits` at every connect over
  `auth.currentEmail`, the `start()`-in-flight wait in `runFirstRound`, the services generation in `AppBootstrap`); no
  `Sources/` line. **Re-run by the orchestrator** in B1's harness (`--filter "FirstRunDrill|FirstRoundAfterTheReopen|
  ProdTestRoad|FirstRoundAfterTheAct|FirstRoundConfirm|SyncWalkFence"`): `✔ Test run with 48 tests in 6 suites passed`.
  Two pin changes were DELIBERATE and are sound: `SyncWalkFenceTests`' derivation pin follows the code it pins;
  unit A's `aLeaveOrAReKeyingActNeverAsks` → `aLeaveNeverAsks` follows F-6 (A).
- **F-B1-1 — RULED (B), by the architect under the mandate:** the sandboxed Debug app cannot read `~/.variorum/` (the
  shared `Variorum.entitlements` sandboxes both configurations), so the road could never arm. **(B): the walk launcher
  — outside the sandbox — reads the allowlist file (mode 600, every entry `vxtest`), and hands the emails to the
  launch as `VARIORUM_PRODTEST_EMAILS`; the app reads that value instead of the file and keeps every in-app guard (the
  road's `1`, exclusive with a walk project, every entry carrying `vxtest`, admission per signed-in account at every
  connect).** Reasons: her R-510-6 is kept in substance — the allowlist FILE stays the one source of truth and the only
  thing the tools read; the protection that matters lives in the app and is unchanged (her account carries no `vxtest`
  marker, so no launch environment can ever admit it); (A) would widen the Debug build's sandbox (and the test host's)
  with a home-relative read exception and a second entitlements file to keep in step; (C) moves her ruled path and every
  tool reading it. Built as unit B2's FIRST piece (unit C waits on it); the walk script's header already names the line.
- **PROVISIONAL words from B1, hers (R-510-13's posture):** P-VX510-B1-1 the follow's success line "Synced. This library
  is up to date with your account again." · P-VX510-B1-2 the road's refusal "Sync off (dev store) — this account isn't a
  listed test account".
- **Unit C may start on B2's F-B1-1 commit:** the orchestrator builds the walk from a detached checkout at that commit
  (never the shared worktree — B2's uncommitted edits must not leak into it) and runs LEG S and LEG D while B2 builds
  VX-501/VX-511 headless; LEG C (Castle) waits for VX-501.

## THE FIX DESIGN — UNIT B (VX-509 · D-ROAD · VX-501 · the VX-503 rider; the architect's design, built by implementer sessions B1 then B2 after unit A closed)

- **D-B0 — F-6 (A), RULED: a re-keying act's first round after the reopen.** Exactly unit A's proposal (A) in its
  Piece 6: `AppBootstrap` keeps a services generation; `attach(services:)` bumps it and resumes waiters; a bounded
  `awaitAttachedServices(newerThan:)` (30 s; then nil ⇒ `.notConfigured` — a closed main window composes no services)
  is the re-keying act's road (`firstRoundAfterReopen`, the generation taken BEFORE the press); `owesFirstRound`
  widens to re-keying joins and Move, and the follow (its round line beside VX-457's durable Done). Pins on the
  first-round world extended with an `onReady` hook that composes and attaches fresh services as `VariorumApp`'s
  `.task` does; red by behavioral revert (the road answering at `.made` without waiting ⇒ the false "Sync is off").

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
- **D-B6 — VX-511 (R-510-14), a landed account act retires the words card.** When Turn on sync lands — the SET-UP arm
  (she typed the library's twelve words: rule 14's reminder moment) or the JOIN arm in either posture (the library's
  pair is now the account's, which she holds — rule 7) — and Move, the band card's ledger marks THIS library's words
  recorded (`WordsCardLedger.record(libraryID)` — the bootstrap's ledger, the same defaults the card reads), so the
  card stops offering a look that would mint new words and, synced, replace the account's. A re-keying act marks the
  library the reopen lands (its id may differ — read it after the reopen, the VX-444 carry's idiom). A refused act marks
  nothing; a leave marks nothing. The passphrase reminder half of the card is unchanged. Recorded consideration: a
  library that joined by PASSPHRASE may not hold the account's words — its road to fresh words is the deliberate New
  Words door (her ruling chose this). Pins: after a set-up / a join (each posture) / Move lands, the card offers no
  words for that library (red on old); a refused act leaves it offering; another library's ledger untouched.
- **D-B7 — VX-513 (R-510-15), the read-only "Check my passphrase or twelve words…" door (unit B3).** In Settings ▸
  Protection beside the key doors (the registry/door idiom the pane already uses — a door that cannot act is not
  rendered, P-2): a sheet with ONE concealed field (the shared field with its reveal eye — VX-463), read as Look inside
  reads it ("twelve valid words are the words, anything else a passphrase"); the check runs off the main actor: the
  typed secret against the OPEN library's live key file locks (the unlock's own derivation — `typedCandidates`' road;
  the result compared with the open key), and, on a synced library, against the account's vault snapshot
  (`VaultModel.master` non-nil); it SAYS one of: these open your library (and your account) · these open your library
  but not your account (an honest split — e.g. changed elsewhere, VX-113's class) · these don't open your library. It
  WRITES NOTHING — no key file, no keychain item, no vault, no ledger, no session hold — and keeps no secret past the
  check. Refusals in the existing words (the floor's KDF validation, the words' checksum sentence). Words PROVISIONAL.
  Pins: right passphrase / right words / wrong each; the synced split arm; a planted world's write counters zero across
  every arm; the door hidden where no library is open.

## UNIT B1 — THE BRIEF (a fresh `opus-implementer`, one session; written before it spawns)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE;
`notes/SurfaceContracts.md` ("The app" and "Doors to the outside" — the protection bullet whole);
`notes/SessionResiliencyProtocol.md`; this file WHOLE (her rulings R-510-1…12, THE TRACE, THE FIX DESIGN — UNIT A, UNIT
A's LIVE STATUS whole — its Piece 0 harness recipe and its Piece 6 F-6 trace are your starting points — UNIT A — THE
ORCHESTRATOR'S VERIFICATION AND RULINGS, THE FIX DESIGN — UNIT B, THE TEST-ACCOUNT ROAD, UNIT C's script, ENVIRONMENT
TRAPS, OPEN ITEMS); `notes/plans/fixes/vx-488-window-hotfixes.md`'s M3 RECORD (the walk lift — `SyncFenceLift`, its
pins, the HOLLOW-pin lesson RM3-4: a source pin matches CODE, never a comment); the code unit A changed (its diff
`54b7b71df..92bd0740a`), `Shared/Protection/ProtectionWalkSwitch.swift`, `Shared/ProjectConfig.swift`,
`Shared/AppServices.swift`, `Shared/AppBootstrap.swift` (`accountActOnNewRoad`, `reopenAround`, `attach`),
`Tools/WalkKit/` (the walk idiom), `Tools/Release/` (the release road — find where its checklist lives), and the tests
unit A added (`FirstRoundAfterTheActTests`, `FirstRoundConfirmTests`, `FirstRoundRoadTests`, `NotOnYetWordsTests`).
The harness unit A built is at
`/private/tmp/claude-501/-<home>-dev-variorum/e4cb0455-71b1-400e-8366-273031288432/scratchpad/vx510a-harness`
— reuse it (copy it to your own scratch folder first) or rebuild from its Piece 0 recipe.

**Your scope — exactly D-B0, D-B1, D-B2 and D-B3 in THE FIX DESIGN — UNIT B:** F-6 (A) as ruled; the standing
first-run drill across every arm (built on unit A's seam, extending its world rather than forking a second one); the
scripted first-run walk under `Tools/` plus its one release-checklist row; the prod test road (DEBUG-only, Release
byte-unchanged, admission per account). Words a face needs (the road's refusal line, a re-keying act's round line)
are drafted PROVISIONAL and named in your record. **Not yours:** D-B4 (VX-501) and D-B5 (VX-503) — unit B2's; any
`Sources/VariorumCore/Sync/` line (STOP, flag, propose); the live walk itself (the orchestrator's unit C — your walk
script is written and dry-checked for its guards only, never run against production); canon, Linear,
`notes/QUESTIONS.md`. A design fork STOPS and comes back as a proposal.

**The discipline, the evidence, the limits — exactly UNIT A — THE BRIEF's** (pin before fix per member, red-on-old;
behavioral reverts named in your record before any runs, each restored and `git diff --exit-code` clean, "no revert is
in flight" written; commit per piece, push each, your LIVE STATUS flipped in the same commit, PENDING on every
unverified claim; foreground waits only; no subagents; headless only plus ONE Mac and ONE iOS `build-for-testing` at the
end into `DerivedData/vx510-b1` / `vx510-b1-ios`; NO `xcodebuild test`, NO stage, NO app launch, NO store, server or
production contact). Commits say `Part of VX-509` / `Part of VX-507` (D-B0) / `Part of VX-510` (D-B3, the road);
**NO trailers of any kind.** The orchestrator may commit record sections to this branch in this worktree while you
work: stage explicit paths only, re-read the record before each edit of it, and never touch sections you do not own.

**Evidence at your close:** each pin's red line; each revert's run line; the harness whole on the final tree; the two
build-for-testing lines; the walk script's guard dry-runs (each refusal shown, nothing launched); and THE MAC-SUITE
LIST for every file you changed.

### UNIT B1 — LIVE STATUS (the implementer owns this section)

**NOT DONE BY THIS SESSION (first, as the contract asks):** **F-B1-1 — the prod test road cannot ARM on the Mac yet**: the
sandboxed Debug app cannot read `~/.variorum/prod-test-accounts.env`, so a live launch with the switch refuses
("the allowlist file can't be read") until the architect rules the fork (Piece 4: (A) a Debug-only entitlement · (B) the
launcher hands the emails · (C) move the file) — STOPPED, NOT BUILT; **unit C cannot run on the road until it is ruled and
built**. No `xcodebuild test`, no stage, no app launch, no dev/real-store touch, no server or production contact; the walk
script (D-B2) is written and guard-dry-checked only, never run — its GUI labels have never met the real window. The
Mac-target suites run in the orchestrator's stage batch (THE MAC-SUITE LIST, Piece 7). No line in
`Sources/VariorumCore/Sync/`. D-B4/D-B5 are unit B2's. Words PROVISIONAL, hers: P-VX510-B1-1 (the follow's line),
P-VX510-B1-2 (the road's refusal line).

*Implementer session B1 — Opus 5.5, xhigh. Pre-fix tree = `68835a08c` (unit A's product files; `c1f3cdaf0` adds only
unit B2's brief). Every claim not yet run is PENDING.*

- **Piece R** — the preflight read whole, myself: CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE;
  `notes/SurfaceContracts.md` ("The app", "Doors to the outside" whole); `notes/SessionResiliencyProtocol.md`;
  `notes/SyncSpec.md` WHOLE (the road changes sync's admission — no `Sync/` line); this file WHOLE; vx-488's M3 RECORD
  (+ the M3 member text); unit A's product diff `54b7b71df..92bd0740a` whole; `ProtectionWalkSwitch`, `ProjectConfig`,
  `AppServices`, `SyncSession`, `AppBootstrap` (whole), `RoadAccountModel`, `RoadAccountFaces`, `SyncStatusViews` (the face),
  `VariorumApp`'s services `.task`; `Tools/WalkKit/` (README + the three scripts); `Tools/Release/release.sh` (the
  publish-and-leave HANDOFF); `Tools/prod-read.sh`, `Tools/prod-confirm-test-user.sh`; the suites unit A added + their
  supports (`ProtectionAccountSupport`, `PlantedRoad`, `PlantedJoin`, `PlantedAccountRoads`, `Crossing`,
  `RoadJoinFollowSurfaceTests`' reopening seam, `TouchIDUnlockSyncKeysTests`' world, `SyncWalkFenceTests`,
  `EntitlementsTests`): DONE (this commit).
- **Piece 0** — the harness: DONE (not durable — this session's scratchpad `vx510b1-harness`, unit A's copied whole: its
  `Package.swift`, both stub files, every symlink; the SwiftPM checkouts carried, the build fresh — `Build complete!`; each
  new suite is symlinked in as it lands). Runner: `b1/test.sh <log> <filter>` (build, then the filtered run under a 300 s
  watchdog).
- **Piece 1** — D-B0's end-to-end pin, committed RED on the pre-fix tree: DONE (this commit). Unit A's `FirstRoundWorld`
  EXTENDED (never forked): `reopensComposeFreshServices()` — the composition root's lifecycle across a reopen, as
  `VariorumApp` runs it (the `onWillLock` teardown stops and releases the services; an `onReady` watch composes FRESH
  services over the reopened session and attaches them — attach, then start); `composed` (every instance, in order);
  `quiesce` awaits the watch and stops every instance. New suite `VariorumTests/Protection/FirstRoundAfterTheReopenTests.swift`:
  `vx507_aReKeyingJoinConfirmsItsFirstRoundOnTheReopensFreshServices` (a Standard library joins an account that syncs in
  CASTLE — the join enters Castle, re-keys, runs through the reopen). **RED on the pre-fix tree** (the harness, `--filter
  "FirstRoundAfterTheReopenTests|FirstRoundAfterTheActTests"`): `✘ Test run with 6 tests in 2 suites failed with 2 issues`
  — `vx507_aReKeyingJoinConfirmsItsFirstRoundOnTheReopensFreshServices` ✘×2 (`account.confirm === confirm` — the sheet went
  with the words moment; "a first round runs for the re-keying join" — none started); its preconditions all held (the door
  `.entersCastle` and re-keying, no refusal, the reopen in Castle, the record naming the account); unit A's five world pins
  green under the extended world.
- **Piece 2** — D-B0 (F-6 (A), ruled): DONE (`bab4692e5`; this record flip rode one commit late — the orchestrator's
  `ee50eb8a6` landed under the edit). `Shared/AppBootstrap.swift`: the services generation (`servicesGeneration`, bumped by
  every `attach`, which also answers the waiters); `awaitAttachedServices(newerThan:within:)` — at once when newer services
  are attached, else the next attach's instance, nil past the bound (30 s in production; the timer holds the bootstrap until
  it fires or an attach cancels it, so no waiter is left unanswered); `attach` wires the re-keying road
  `roadAccount.firstRoundAfterReopen` (the generation now; at `.made` the services attached after it, asked
  `runFirstRound()`). `Shared/Protection/RoadAccountModel.swift`: `RoadAccountModel.FirstRoundAfterReopen` + the property;
  `open(_:)` — the PRESSED door chooses the road (a door re-shown CHANGED may change its plan): the act closure records
  `(request.shown.rekeys, generation)` at the press, the first-round closure asks the reopen road with that generation or the
  open session's road; no road for the door ⇒ no round (P-2 kept). `Shared/Protection/RoadAccountFaces.swift`:
  `owesFirstRound` widened to every Turn on sync, Move and the follow (leaves never). `RoadAccountConfirmModel.firstRoundLine`
  gains `follows:` — the follow's clean round says `ProtectionWords.firstRoundFollowLanded` = "Synced. This library is up to
  date with your account again." (**PROVISIONAL P-VX510-B1-1**, my draft, hers; the follow's Done stays VX-457's durable
  notice). `Shared/AppServices.swift`: `runFirstRound` WAITS while `start()` is in flight (the reopen's services are attached
  just BEFORE their start — reaching for the chain first composed it twice, the start's configure retiring the round's
  scheduler mid-round; found in the trace, pinned). Pins (new seams — red by Piece 6's reverts): `FirstRoundConfirmTests` —
  **`aLeaveOrAReKeyingActNeverAsks` FLIPPED DELIBERATELY** to `aLeaveNeverAsks` (leaves only — F-6 (A) ruled the re-keying
  half the other way), `aReKeyingActAsksTheReopenRoadWithThePressGeneration` (join into/out of Castle, Move into Castle, both
  follows: the reopen road asked once with the generation taken BEFORE the planted press moved it on — the reopen's attach —
  never the open session's road; no reopen road ⇒ no round), `aDoorReShownAsReKeyingTakesTheReopenRoad`;
  `FirstRoundAfterTheReopenTests` + `theServicesGenerationAnswersTheNextAttachOrNothingWithinTheBound`,
  `aFirstRoundAskedWhileStartRunsRidesTheStartsChain` (the chain composed once). Test support: `PlantedAccountRoads.onPress`
  (what happens during a press; nil everywhere else). **The harness, `--filter "FirstRoundAfterTheReopenTests|
  FirstRoundAfterTheActTests|FirstRoundRoadTests|FirstRoundConfirmTests|RoadAccountModelTests|RoadJoinFollowModelTests"`:
  `✔ Test run with 37 tests in 6 suites passed`** — Piece 1's pin GREEN.
- **Piece 3** — D-B1 (VX-509): DONE (this commit). New suite `VariorumTests/Protection/FirstRunDrillTests.swift` — **THE
  STANDING GATE VX-509 asked for, named for the release checklist** (its header says so): every arm runs to its first round
  with NO RELAUNCH and asserts what she sees — the sheet stays, the round runs to its end, the sheet's line, the sync row's
  face (+ its line), Done closes it. Arms: `arm1_theStandardSetUpRunsItsFirstRound` (row not-on-yet before) ·
  `arm2_theStandardJoinRunsItsFirstRound` · `arm3_theCastleSetUpUnderAlwaysAskRunsItsFirstRound` (Use Castle through the
  bootstrap's crossing — its reopen composes fresh services — then the set-up in Castle) ·
  `arm4_theCastleSetUpUnderTouchIDRunsItsFirstRound` (a finger enrolled, the planted press; the keys filed in the Touch ID
  item) · `arm5_theCastleJoinRunsItsFirstRound` (same posture, open session) · `arm6_moveRunsItsFirstRound` (bound to
  another account before this Mac's open; Move, same posture) · `arm7_theReKeyingJoinRunsItsFirstRoundThroughTheReopen`
  (D-B0) — and the negatives, each saying its blocker on the sheet AND the row: `negative_offlineSaysWaitingOnTheSheetAndTheRow`
  (sheet "Sync hasn't run yet: Waiting to sync (offline)." · row offline) · `negative_heldSaysWaitingSinceTheRestore` (sheet
  the held line · row "Not synced yet" — **said plainly: under the hold the row itself has no held face; the hold's sentence
  is the banner's (`RestoreHoldBar`)**) · `negative_notConfiguredSaysSyncIsOff` (the owner adoption refused — F-5; sheet and
  row "Sync is off") · `negative_theAccountGateSaysPaused` (sheet and row the paused line). Unit A's world EXTENDED (never
  forked): `run`/`make` take `owner:` (nil ⇒ the adoption refuses), `biometry:` and `prepare:` (acts on the library before the
  bootstrap opens it); `composeServices(beforeStart:)` (the hold's gates wired before the start, as `VariorumApp` does);
  `servicesSignIn` (the gate arm); `useCastle(gate:)` (through the bootstrap's crossing roads); `awaitReadyCompose()`;
  `FirstRoundServer.goOffline()`. **The harness, `--filter "FirstRunDrillTests"`: `✔ Test run with 11 tests in 1 suite
  passed`**; with every first-round suite (`FirstRunDrillTests|FirstRoundAfterTheReopenTests|FirstRoundAfterTheActTests|
  FirstRoundRoadTests|FirstRoundConfirmTests|NotOnYetWordsTests`): **`✔ Test run with 39 tests in 6 suites passed`**. A
  standing gate — guards, green by design on this tree; its teeth are Piece 6's reverts (RB-1/RB-2 below turn its arms red).
- **Piece 4** — D-B3 (D-ROAD): DONE as designed, EXCEPT ONE FORK — STOPPED, NOT BUILT (F-B1-1 below) (this commit). Every
  line is DEBUG-only. `Shared/Protection/ProtectionWalkSwitch.swift` (`#if DEBUG` whole): the road beside the walk lift —
  `prodTestRoadKey` (`VARIORUM_PROD_TEST_ROAD`), `prodTestAllowlistPath` (`.variorum/prod-test-accounts.env` under the REAL
  home — `realHome` via `getpwuid`, never the sandbox container's), `prodTestEmailsKey`, `prodTestMarker` (`vxtest`);
  `AllowlistRead` (missing · unreadable · present(mode, text)); `ProdTestAllowlist.admits` (exact, case-folded; no email is
  never listed); `ProdTestRoadRefusal` (walk project too · missing · unreadable · not 600 · empty · unmarked entry);
  `ProdTestRoad` (none · armed · refused); the pure rule `prodTestRoad(switchValue:walkProject:allowlist:)` (exactly `1` asks;
  the allowlist read ONLY when asked, AFTER the walk-project exclusion); `allowlistEmails` (the one key, parsed as the shell
  sources it — the secrets beside it are never entries, never kept, never logged); `readAllowlist(atPath:)` (`lstat` — a link
  is never followed; the mode bits; the text); `prodTestRoadForThisLaunch` (logged once — armed with HOW MANY accounts, or
  refused and why; never an email). `Shared/ProjectConfig.swift` (its DEBUG fence): `prodTestRoad`, decided once from the
  walk project already resolved (never a second parse). `Shared/AppServices.swift`: `DevSyncFence` (the launch's two
  exceptions — the walk lift and the road — as ONE value; `thisLaunch` = `ProjectConfig`'s two decisions) behind a
  DEBUG-only dependency `\.devSyncFence` (live and test value: the launch's own — a test process carries no switch; a pin
  injects its own — the project's injection idiom, so `AppServices` reads no environment of its own, still pinned); the DEBUG
  derivation `allowsSync(storeVariant:walkLift:prodTestRoad:)` (a dev store syncs under the lift OR the armed road); the
  pure admission `prodTestRoadAdmits(storeVariant:fence:email:)` — while the dev store syncs ONLY by the road, only a listed
  account; `connectSyncIfAllowed` runs it at EVERY connect (launch, sign-in, resume, first round, the deletion's reconnect —
  one door) against `auth.currentEmail`, records `AccountState.notOnTheProdTestRoad` and composes nothing for an unlisted
  account (one log line, no email); a sign-out clears it. The Release arm's line byte-unchanged; the retired-credential sweep
  still gated on the store variant (its pin untouched). `Shared/SyncStatusViews.swift`: `SyncRowFace.Kind.notOnTheProdTestRoad`,
  the pure `SyncRowFace.prodTestRoadRefusal(refused:)` (its door Account…), consulted FIRST by the row's face; the line
  `SyncStatusRow.notOnTheProdTestRoadLabel` = "Sync off (dev store) — this account isn't a listed test account"
  (**PROVISIONAL P-VX510-B1-2**, my draft, hers), warning-styled. `Shared/SyncSession.swift`: its A4 header comment names the
  second exception (no code). Pins (new suite `VariorumTests/ProdTestRoadTests.swift`, 12 tests — new seams, teeth by Piece
  6's reverts): `withNoSwitchTheFenceHoldsAndNothingIsRead` · `theSwitchWithAWalkProjectRefuses` ·
  `eachAllowlistFaultRefusesAndTheFenceStands` (missing · unreadable · 644 · 640 · empty · no key · an unmarked entry) ·
  `theSwitchAndAPrivateMarkedListArmTheRoad` · `theAllowlistsOneKeyIsParsedAndNothingElse` ·
  `theReadReportsTheFilesModeAndNeverFollowsALink` (real temp files) · `thisLaunchsRoadWithNoSwitchIsNone` (guard) ·
  `theAdmissionIsPerAccount` · `armedAndListedComposesTheChain` (the DEV store's real services, the fence injected) ·
  `armedAndUnlistedComposesNothingAndTheRowSaysWhy` (no chain, the refusal face + line, a first round "not configured", then
  a sign-in as a LISTED account re-runs the admission and composes) · `theRowConsultsTheRoadsRefusalFirst` (source, code) ·
  `aReleaseBuildCompilesNothingOfTheRoad` (source: the text a Release build compiles — every `#if DEBUG` arm dropped, line
  comments stripped — names no road identifier in the four files; the stripper's own teeth: it keeps Release's derivation
  line). **`SyncWalkFenceTests.theDerivationReadsTheLaunchsLiftOnlyInDebug` UPDATED DELIBERATELY** (the code it pins changed:
  the DEBUG arm reads both exceptions from the launch's fence; the fence's live value is `ProjectConfig`'s two decisions;
  Release's line asserted byte-unchanged as before) — red on the pre-fix tree in its new form. **The harness, `--filter
  "ProdTestRoadTests|SyncWalkFenceTests|SyncLockedRowTests|SyncStalledRowTests|ProtectionWalkSwitchTests|
  ProtectionWalkProjectTests"`: `✔ Test run with 34 tests in 6 suites passed`.**
  - **F-B1-1 — THE FORK (STOPPED, NOT BUILT): the sandboxed Debug app cannot read the ruled allowlist path.** Both Mac
    configurations are App-Sandboxed (`ENABLE_APP_SANDBOX = YES`, one shared `Variorum.entitlements`), and the sandbox
    denies a read outside the container — `~/.variorum/prod-test-accounts.env` included (the container is the sandbox's
    home: `BackupDestination.displayPath`'s own note). So as built, a live launch with the switch reads `.unreadable` and the
    road REFUSES, fail-closed and said once ("the allowlist file can't be read") — **the road cannot arm on the Mac until the
    architect rules** (PENDING the live walk to observe; headless, the read is proven over temp files, unsandboxed). Options:
    **(A — recommended for literalness)** a Debug-only entitlements file — the shared file plus
    `com.apple.security.temporary-exception.files.home-relative-path.read-only` = `/.variorum/prod-test-accounts.env` — named
    by the DEBUG configuration's `CODE_SIGN_ENTITLEMENTS` only: the app reads the ruled file in place, exactly D-B3; Release's
    entitlements and signature untouched. Cost: a project-file edit, a second entitlements file kept in lockstep with the
    shared one (an `EntitlementsTests` pin can hold them equal but for the one key), a one-file read exception in the Debug
    build (the test host included). **(B — lightest)** the LAUNCHER hands the one key: the walk script (outside the sandbox)
    checks the file (mode 600, every entry marked — it already does, D-B2) and launches with `VARIORUM_PRODTEST_EMAILS` beside
    the switch; the app's rule reads that value instead of the file (the marker check stays in the app; the mode check moves
    to the launcher). No entitlement, no project change; the emails (never a secret) show in `ps eww`. A one-function swap of
    the rule's input. **(C)** the allowlist moves into the Debug container (readable without a grant) — moves her ruled path,
    and every tool that reads it, into a folder a dev-slot reset handles. The walk script (D-B2) is written for the current
    design and says which line changes under (B).
- **Piece 5** — D-B2 (VX-509): DONE — written and guard-dry-checked only, NEVER run (this commit). `Tools/WalkKit/first-run-walk.sh
  <std|castle|del> [--app …] [--dry-run] | --self-test` (zsh, the WalkKit/VisualWalk idioms — `guard.sh --author` before
  every GUI act, acts ≥ 2.6 s apart, presses by ACCESSIBILITY LABEL through VisualWalk's `vis-ax` addressed to OUR pid,
  captures by window id, quit by identity left to the walker): **nine guards, in order, each a refusal (exit 5, nothing
  launched, nothing read from production, nothing typed)** — G1 the account (std · castle · del); G2 the allowlist (a regular
  file never a link, mode 600, every entry `vxtest`, this account listed — read in a subshell, never printed); G3 no walk
  project in the environment; G4 a Debug build (bundle `io.lduarte.Variorum.debug`, a `…/Debug/Variorum.app` path) never under
  `/Applications`; G5 zero Variorum instances (by path); G6 the stage HELD; G7 the dev slot set aside (no `variorum.sqlite`
  — the `mv` is the walker's, never the script's); G8 `Tools/prod-read.sh` + `.env.supabase.local` present, the typing and
  stash helpers at mode 700, cliclick; G9 the GUI grants (VisualWalk's `vis-tcc` — checked, never prompted). Then the live
  phases (unit C's): P1 launch (`open -n --env VARIORUM_PROD_TEST_ROAD=1 --env OS_ACTIVITY_DT_MODE=YES --stderr`), P2 `ps
  eww` (the switch present, no walk project — never printed) + the app's own "PROD TEST ROAD (VX-510): ARMED" line (a
  REFUSED line stops it — F-B1-1 stops it HERE until ruled), P3 the account on production (exists, confirmed — its id read
  once), P4 sign in (the helper types email/password), P5 the row's not-yet line + Settings ▸ Protection ▸ Record your twelve
  words… → Copy → `stash-prod-test-words`, P6 Turn on sync… (the helper types the new passphrase twice and the words), P7 THE
  SHEET's "Synced. Your library is on your account now." (≤ 180 s; a "Sync hasn't run yet" line stops it with the capture) →
  Done → the row "Synced" → the same pid (no relaunch), P8 the server by the account's id: `key_vault` (mode + proof),
  `vault.secrets` `kp:<id>`, `device_cursor`, `container` rows (counts only). The GUI labels are the code's own constants
  (`ProtectionWords`, `AuthViews`) but have never met the real window: **its first live run is unit C's** (expect label
  adjustments there). **THE RELEASE-CHECKLIST ROW** — the publish checks live in `Tools/Release/release.sh`'s HANDOFF
  (release mode), so its step **0 — THE FIRST-RUN GATE (VX-509)**: `FirstRunDrillTests` green on this commit AND
  `Tools/WalkKit/first-run-walk.sh std` PASSED on a Debug build of this commit, before the DMG moves (printed text only — no
  release behaviour changes; `bash -n` clean; no test pins that text). `Tools/WalkKit/README.md` gains a short section.
  **THE GUARD DRY-RUNS (this session; nothing launched):** no args → `REFUSES: usage: …` exit 5 · `bogus` → `REFUSES: G1/G2 —
  unknown account 'bogus'` exit 5 · `VARIORUM_WALK_PROJECT_URL=… std` → `REFUSES: G3 — a walk project is set …` exit 5 ·
  `std --app /Applications/Variorum.app` → `REFUSES: G4 — … is under /Applications: her app is never launched by a walk` exit
  5 · `std --app /nonexistent/Debug/Variorum.app` and `std` (no `vx510` build yet) → `REFUSES: G4 — no Debug build at …` exit 5
  · `--self-test` → nine fixture cases, every one as expected (good std/castle accepted; unknown account, mode 644, an
  unmarked entry, an empty list, the account unlisted, a link, no file — each refused with its reason) `SELF-TEST: every guard
  fired as expected` exit 0. **Machinery honesty:** the self-test's FIRST run reported 7 of 9 cases wrong — its own harness
  read the exit status after a `local` assignment (always 0), so every case read "accept"; the self-test caught it (it FAILs
  loudly rather than passing hollow), fixed before this commit. The G5/G6 refusals are shown at Piece 7 against the
  build-for-testing's Debug app (PENDING).
- **Piece 6** — THE BEHAVIORAL REVERTS, named BEFORE any runs (this commit; the committed tree IS the pre-revert copy). First, a
  WORLD FIDELITY FIX found while naming them (test code, this commit): the world kept every services instance it composed
  (`composed`, strong) — production lets a stopped instance go at the teardown and the bootstrap's roads hold them weakly, so
  a revert whose road reached the RELEASED services would have reached a still-alive one here and passed hollow; now a count
  (`composedCount`), and the reopen pins keep no reference to the open session's services. Plus the follow's line pinned
  (`eachOutcomeSaysTheRowsOwnSentence` + the follow arm; `aReKeyingActAsksTheReopenRoadWithThePressGeneration` asserts each
  door's success line). Re-run on this tree: `--filter "FirstRunDrillTests|FirstRoundAfterTheReopenTests|
  FirstRoundAfterTheActTests|FirstRoundRoadTests|FirstRoundConfirmTests|ProdTestRoadTests|SyncWalkFenceTests"` **`✔ Test run
  with 53 tests in 7 suites passed`**. Each revert is ONE file, applied in the worktree, the harness run with the named filter
  (`b1/revert.sh` — build, the run under a 300 s watchdog, `git checkout --`, `git diff --exit-code`), expected red in
  brackets:
  - **RB-1** (D-B0, the wiring) `Shared/AppBootstrap.swift`: `attach` stops wiring `firstRoundAfterReopen` [the D-B0
    end-to-end pin, `arm7_…`, `theServicesGenerationAnswersTheNextAttachOrNothingWithinTheBound`].
  - **RB-2** (D-B0, THE NAMED ONE — "the road answering at `.made` without waiting ⇒ the false 'Sync is off'")
    `Shared/Protection/RoadAccountModel.swift`: the first-round closure asks the OPEN SESSION's road for a re-keying press too
    [the D-B0 end-to-end pin ("Sync hasn't run yet: Sync is off."), `arm7_…`, `aReKeyingActAsksTheReopenRoadWithThePressGeneration`,
    `aDoorReShownAsReKeyingTakesTheReopenRoad`].
  - **RB-3** (D-B0, the wait) `Shared/AppBootstrap.swift`: `awaitAttachedServices` answers at once with whatever is attached
    [`theServicesGenerationAnswersTheNextAttachOrNothingWithinTheBound`].
  - **RB-4** (D-B1 / unit A's composition) `Shared/AppBootstrap.swift`: `attach` stops wiring `firstRound` [every
    open-session arm of `FirstRunDrillTests` — arm1–arm6 and the four negatives].
  - **RB-5** (D-B0, the gate) `Shared/Protection/RoadAccountFaces.swift`: `owesFirstRound` back to unit A's form (open-session
    Turn on sync / Move only) [the D-B0 end-to-end pin, `arm7_…`, `aReKeyingActAsksTheReopenRoadWithThePressGeneration`].
  - **RB-6** (D-B0, the start race) `Shared/AppServices.swift`: `runFirstRound` drops the in-flight start's wait
    [`aFirstRoundAskedWhileStartRunsRidesTheStartsChain`].
  - **RB-7** (D-B0, the follow's line) `Shared/Protection/RoadAccountModel.swift`: `firstRoundLine` drops its follow arm
    [`eachOutcomeSaysTheRowsOwnSentence`, `aReKeyingActAsksTheReopenRoadWithThePressGeneration` (the follows)].
  - **RB-8** (D-B3, the derivation) `Shared/AppServices.swift`: `allowsSync`'s dev arm ignores the road [`theSwitchAndAPrivate
    MarkedListArmTheRoad`, `armedAndListedComposesTheChain`, `armedAndUnlistedComposesNothingAndTheRowSaysWhy`].
  - **RB-9** (D-B3, the admission's door) `Shared/AppServices.swift`: `connectSyncIfAllowed` loses its DEBUG admission block
    [`armedAndUnlistedComposesNothingAndTheRowSaysWhy`].
  - **RB-10** (D-B3, the admission's rule) `Shared/AppServices.swift`: `prodTestRoadAdmits` admits every account
    [`theAdmissionIsPerAccount`, `armedAndUnlistedComposesNothingAndTheRowSaysWhy`].
  - **RB-11** (D-B3, the exclusion) `Shared/Protection/ProtectionWalkSwitch.swift`: the rule ignores a resolved walk project
    [`theSwitchWithAWalkProjectRefuses`].
  - **RB-12** (D-B3, the mode) `ProtectionWalkSwitch.swift`: the mode-600 check removed [`eachAllowlistFaultRefusesAndTheFenceStands`].
  - **RB-13** (D-B3, the marker) `ProtectionWalkSwitch.swift`: the `vxtest` check removed [`eachAllowlistFaultRefusesAndTheFenceStands`].
  - **RB-14** (D-B3, links) `ProtectionWalkSwitch.swift`: `readAllowlist` follows a link (`stat`, not `lstat`)
    [`theReadReportsTheFilesModeAndNeverFollowsALink`].
  - **RB-15** (D-B3, the switch) `ProtectionWalkSwitch.swift`: any non-empty switch value asks [`withNoSwitchTheFenceHoldsAndNothingIsRead`].
  - **RB-16** (D-B3, the row) `Shared/SyncStatusViews.swift`: the row's face stops consulting the road's refusal
    [`theRowConsultsTheRoadsRefusalFirst`].
  - **RB-17** (D-B3, Release) `Shared/AppServices.swift`: the sign-out's `notOnTheProdTestRoad` reset leaves its `#if DEBUG`
    fence [`aReleaseBuildCompilesNothingOfTheRoad`].
  - **RB-18** (D-B3, the call site) `Shared/AppServices.swift`: the DEBUG derivation back to the walk-lift-only call
    [`theDerivationReadsTheLaunchsLiftOnlyInDebug`, `armedAndListedComposesTheChain`, `armedAndUnlistedComposesNothingAndTheRowSaysWhy`].
  **RESULTS — DONE, every one RED as named, every restore `git diff --exit-code` clean; NO REVERT IS IN FLIGHT** (the committed
  tree `a59972d3c`; the runner `b1/revert.sh` in the session scratchpad, each run filtered):
  - **RB-1** `--filter "FirstRoundAfterTheReopenTests|FirstRunDrillTests"`: `✘ Test run with 14 tests in 2 suites failed with 6
    issues` — `vx507_aReKeyingJoinConfirmsItsFirstRoundOnTheReopensFreshServices` ✘×2, `theServicesGenerationAnswers…` ✘,
    `arm7_theReKeyingJoinRunsItsFirstRoundThroughTheReopen` ✘×3.
  - **RB-2** (+ `FirstRoundConfirmTests`): `✘ … 24 tests in 3 suites failed with 14 issues` — `aDoorReShownAsReKeyingTakesTheReopenRoad`
    ✘, `aReKeyingActAsksTheReopenRoadWithThePressGeneration` ✘×10, the end-to-end pin ✘ (**its outcome `.done(.notConfigured)`
    — the released services: the false "Sync hasn't run yet: Sync is off.", exactly the named failure; it also proves the
    world lets the old instance go**), `arm7_…` ✘×2.
  - **RB-3** `--filter FirstRoundAfterTheReopenTests`: `✘ … 3 tests in 1 suite failed with 3 issues` —
    `theServicesGenerationAnswers…` ✘×2 and the end-to-end pin ✘.
  - **RB-4** `--filter FirstRunDrillTests`: `✘ … 11 tests in 1 suite failed with 23 issues` — arm1–arm6 and all four negatives
    ✘ (no round phase); `arm7_…` green (the re-keying road is wired separately — as designed).
  - **RB-5** (three suites): `✘ … 24 tests in 3 suites failed with 25 issues` — `aReKeyingActAsks…` ✘×20, the end-to-end pin
    ✘×2, `arm7_…` ✘×3.
  - **RB-6** `--filter FirstRoundAfterTheReopenTests`: `✘ … 3 tests in 1 suite failed with 6 issues` —
    `aFirstRoundAskedWhileStartRunsRidesTheStartsChain` ✘×2 (two chains; `CancellationError()`) AND the end-to-end pin ✘×4:
    **without the wait the reopen's first round is cancelled by the start's second configure and the sheet says "Sync hasn't
    run yet: Sync error." — the race is real on the shipped path, not hygiene**.
  - **RB-7** `--filter FirstRoundConfirmTests`: `✘ … 10 tests in 1 suite failed with 3 issues` — `eachOutcomeSaysTheRowsOwnSentence`
    ✘, `aReKeyingActAsks…` ✘×2 (the two follows).
  - **RB-8** `--filter "ProdTestRoadTests|SyncWalkFenceTests"`: `✘ … 19 tests in 2 suites failed with 7 issues` —
    `theSwitchAndAPrivateMarkedListArmTheRoad` ✘, `armedAndListedComposesTheChain` ✘×3, `armedAndUnlisted…` ✘×3.
  - **RB-9** (same): `✘ … with 3 issues` — `armedAndUnlistedComposesNothingAndTheRowSaysWhy` ✘×3 (a chain composed).
  - **RB-10** (same): `✘ … with 6 issues` — `theAdmissionIsPerAccount` ✘×3, `armedAndUnlisted…` ✘×3.
  - **RB-11** (same): `✘ … with 2 issues` — `theSwitchWithAWalkProjectRefuses` ✘×2.
  - **RB-12** (same): `✘ … with 6 issues` — `eachAllowlistFaultRefusesAndTheFenceStands` ✘×6 (644 and 640 armed).
  - **RB-13** (same): `✘ … with 3 issues` — `eachAllowlistFaultRefusesAndTheFenceStands` ✘×3 (the unmarked entry armed).
  - **RB-14** (same): `✘ … with 1 issue` — `theReadReportsTheFilesModeAndNeverFollowsALink` ✘ (the link followed).
  - **RB-15** (same): `✘ … with 15 issues` — `withNoSwitchTheFenceHoldsAndNothingIsRead` ✘×15.
  - **RB-16** (same): `✘ … with 1 issue` — `theRowConsultsTheRoadsRefusalFirst` ✘.
  - **RB-17** (same): `✘ … with 2 issues` — `aReleaseBuildCompilesNothingOfTheRoad` ✘×2.
  - **RB-18** (same): `✘ … with 7 issues` — `theDerivationReadsTheLaunchsLiftOnlyInDebug` ✘, `armedAndListed…` ✘×3,
    `armedAndUnlisted…` ✘×3.
- **Piece 7** — EVIDENCE: DONE (the final tree = this commit's product files; foreground, in sequence):
  - THE HARNESS whole (debug; this unit's three new suites symlinked in): `✘ Test run with 480 tests in 82 suites failed with
    4 issues` — exactly unit A's three harness-PATH artifacts (`theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut` ×2,
    `thePasteInIsFullyRetiredInTheSharedSources`, `theBecomeActiveHookRunsOneSyncRound` — they read `#filePath` beside the
    symlink; they run in the Mac target); with those three `--skip`ped: **`✔ Test run with 477 tests in 82 suites passed`**
    (unit A's 449/79 + this unit's 28 tests in 3 new suites and 2 more in `FirstRoundConfirmTests`); no `signal` line.
  - RELEASE COMPILE (the harness's app sources, `swift build -c release --target Variorum`): **`Build complete!`** — the road
    compiles out whole (the exhaustive row switches without their DEBUG case).
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx510-b1
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**, zero errors; ONE warning in a file this unit touched —
    `FirstRoundAfterTheReopenTests.swift:114` (an unnecessary `try` before a non-throwing `withDependencies`) — fixed in this
    commit AFTER that build (one token, test-only; re-verified in the harness: `--filter FirstRoundAfterTheReopenTests` `✔
    Test run with 3 tests in 1 suite passed`, no warning for the file — said plainly: the Mac target has not re-compiled
    the fixed line). `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS Simulator' -derivedDataPath
    App/Variorum/DerivedData/vx510-b1-ios build-for-testing`: **`** TEST BUILD SUCCEEDED **`**, zero errors, no warning in a
    touched file.
  - Not run (no file touched): the core package (`Sources/` and `Tests/` untouched — no `Sync/` line).
  - THE WALK SCRIPT against the built Debug app (read-only guards; nothing launched): `Tools/WalkKit/first-run-walk.sh std
    --app App/Variorum/DerivedData/vx510-b1/Build/Products/Debug/Variorum.app --dry-run` → G1–G5 held (the account listed, no
    walk project, the build `io.lduarte.Variorum.debug` outside `/Applications`, zero Variorum instances) → `REFUSES: G6 — the
    stage is not held (STAGE FREE); claim it first …` exit 5. (G5's refusal path is VisualWalk's own `pgrep` idiom — not
    exercised: no instance was running and none may be started here; G7–G9 sit behind G6.)
  - **Machinery honesty:** the orchestrator committed to this branch IN THIS WORKTREE while the unit ran (`c1f3cdaf0`,
    `ee50eb8a6`, `07c22ac8f`, `677cc46c0` — its own record sections); this session staged explicit paths only, re-read the
    record before each edit, and never touched those sections. One record flip rode a commit late (Piece 2 — said there).
  **THE MAC-SUITE LIST (for the orchestrator's stage batch — every suite exercising a file this unit changed):**
  - NEW (harness-green): `FirstRoundAfterTheReopenTests`, `FirstRunDrillTests` (VX-509's standing gate), `ProdTestRoadTests`.
  - CHANGED (harness-green): `FirstRoundAfterTheActTests` (the world), `FirstRoundConfirmTests` (the flipped pin + the new
    ones), `RoadAccountModelTests` (`PlantedAccountRoads.onPress`), `SyncWalkFenceTests` (the derivation pin, updated).
  - `AppServices` (the start-wait, the fence dependency, the derivation, the admission, `AccountState`): `FirstRoundRoadTests`,
    `OneRefreshAuthorityTests`, `Phase9cAuthWiringTests` (ALL — its three source pins run only there), `TierAndOnboardingTests`,
    `Phase8ServicesTests`, `KeychainOffMainTests`, `LibraryPortabilityDoorTests`, `SampleLibraryDedupeFactsTests`.
  - `AppBootstrap` (`attach`, the generation): `AppBootstrapOffMainTests`, `SettingsLockCloseTests`, `LibraryHandOffTests`,
    `QuickEntryLaunchFocusTests`, `WhatsNewWaitsAfterAdoptionTests`, `RoadAccountSurfaceTests`, `RoadJoinFollowSurfaceTests`,
    `RoadKeyDoorSurfaceTests`, `RoadLockRouteTests`, `SetPassphraseRowRereadRouteTests` (+ unit A's whole `Protection/` list).
  - `RoadAccountModel` / `RoadAccountFaces` / `ProtectionWords`: `FollowDoneNoticeTests`, `ProtectionPaneWaveTests`,
    `PassphraseFloorRoadTests`, `RoadJoinFollowModelTests`, `ProtectionAccountRoadTests`, `ProtectionJoinFollowRoadTests`,
    `RoadAccountFacesTests`, `RoadJoinFollowFacesTests`, `RoadAccountWordsTests`, `RoadJoinFollowWordsTests`,
    `ProtectionWordsPlanTests`, `ProtectionWordsVX307Tests`, `U2WordsTests`.
  - `SyncStatusViews` (the DEBUG kind, the refusal face, the row's `face`): `SyncLockedRowTests`, `SyncStalledRowTests`,
    `SyncOutOfDateFaceTests`, `NotOnYetWordsTests`, `TierAndOnboardingTests`.
  - `ProtectionWalkSwitch` / `ProjectConfig`: `ProtectionWalkSwitchTests`, `ProtectionWalkProjectTests`, `ProtectionCrossingRouteTests`,
    `RoadRearmTests`, `OneSyncKeysLeafTests`, `EntitlementsTests` (the Debug host's entitlements — untouched here, but F-B1-1's
    option (A) would change them).
  - The simplest honest batch: the whole `VariorumTests/Protection` folder + every top-level suite named above.
  - THE PHONE (`VariorumMobileTests` — `AppServices`/`SyncSession`/`AppBootstrap`/`SyncStatusRow`, and the `Shared/` sweeps over
    the new literals): `MobileEmptyStoreTests`, `MobileStructuralTests`, `MobilePerfWalkTests`, `MobileQuickNoteReadFailureTests`,
    `MobileStarterJournalTests`.
  **THE WALK (this unit's rows, for the stage — use-shaped, not this session's):** (1) a re-keying join (a Standard library
  joining a Castle account — the throwaway road or, once F-B1-1 is ruled, the prod test road): the sheet survives the reopen,
  then "Syncing your library with your account…" → "Synced. Your account's writing is in this library now."; the row
  "Synced ‹time›", no relaunch; (2) a follow (the account entered Castle on another device): the sheet's round line beside
  the section's durable Done; (3) the prod test road with an UNLISTED account signed in: the row reads "Sync off (dev store)
  — this account isn't a listed test account" with Account…; signing in as a listed account composes the chain (the road's
  log line ARMED first); (4) `Tools/WalkKit/first-run-walk.sh std` end to end (unit C's LEG S S4–S7). Both voices where the
  sheet and the row have a face.

## UNIT B2 — THE BRIEF (a fresh `opus-implementer`, one session; spawned only after unit B1 closes)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE (rules 7, 9, 14, 15
and 20 are this unit's ground); `notes/SyncSpec.md` §3 (the key provider, the custody record, the vault road);
`notes/SurfaceContracts.md`'s protection bullet whole; `notes/SessionResiliencyProtocol.md`; this file WHOLE (D-B4 and
D-B5 are your charter; THE TRACE; units A and B1's LIVE STATUS for the seams and harness they built);
`notes/plans/fixes/vx-488-window-hotfixes.md`'s M1 RECORD WHOLE (VX-487 (b) — `loadSyncKeysForTheSession`, the Touch ID
unlock's session load you are building the typed twin of; its never-hostage pins; OPEN ITEMS M1 (c) — this ticket's
origin) and the vx-494 record's R-494-4 (her ruled direction, verbatim); the code: `Shared/Protection/ProtectionOpenRoad.swift`
(the lobby's typed roads, `typedCandidates`, `pressTouchID`, `loadSyncKeysForTheSession`), `Shared/Protection/
KeychainSyncKeysLeaf.swift`, `Shared/Protection/NewRoadSyncKeyProvider.swift`, `Shared/Protection/WireVaultLeaf.swift`,
`Sources/VariorumCore/Protection/Executor/Acts/KeyDoors.swift` (`holdSyncKeysForTheSession`), the vault model
(`VaultModel.master`, `vault.keys(master:)`), and for D-B5 the join's plan (`Executor` `enroll` and the steps it runs —
every keychain read on that road) plus `KeychainCustodyLeaf.swift`.

**FIRST, before anything else — F-B1-1 (B) as ruled in UNIT B1 — THE ORCHESTRATOR'S VERIFICATION AND RULINGS** (unit C
waits on it): the app reads the allowlist from `VARIORUM_PRODTEST_EMAILS` (space-separated, the file's own shape)
instead of the file — every in-app guard kept (the road's `1`; refused with a walk project; empty refused; every entry
carrying `vxtest`; the admission per account at connect) — and `Tools/WalkKit/first-run-walk.sh` reads the file (mode
600, outside the sandbox) and passes the value at launch. Its pins updated (each file-reading pin becomes the env
form; a pin that an entry without the marker refuses; a pin that her-shaped address can never be admitted), its
reverts named and run, its own commit pushed AT ONCE, its hash written in your LIVE STATUS — the orchestrator builds
the live walk from that commit while you continue. Commits for it say `Part of VX-510`.

**Then your scope — exactly D-B4, D-B6 and D-B5:** VX-501's typed-unlock load (never hostage; no second KDF; the secret never
retained past the load; Standard and unbound libraries read nothing) with its pins red-on-old; VX-511's card retirement at
a landed account act (D-B6, its pins red-on-old; read `WordsBand.swift`, `ProtectionCopyDoors.swift`'s VX-444 carry and
mark, and the bootstrap's `accountRoads().landed` / `accountActOnNewRoad`); and the VX-503 trace —
which read raises the system Touch ID prompt during a Standard join, what a cancel skips, whether it leaves residue —
recorded with file:line evidence, a fix ONLY if traced (with its pin), else recorded for the orchestrator. **A seam that
would put LocalAuthentication or a network read into the core package, or any line in `Sources/VariorumCore/Sync/`, is
a FORK: stop and propose.** Not yours: everything else; canon, Linear, `notes/QUESTIONS.md`.

**The discipline, the evidence, the limits — exactly UNIT A — THE BRIEF's**, with `build-for-testing` into
`DerivedData/vx510-b2` / `vx510-b2-ios`, plus the core package's protection set debug AND release if you touch
`Sources/` (the vx-488 M1 filter: every suite under `Tests/VariorumCoreTests/Protection` + `AccountBindingGateTests`,
`AccountLifecycleTests`, `AuthRLSDDLTests`, `KeyVaultClientTests`, `SupabaseTransportTests`,
`SupabaseTransportSessionTests`). Commits say `Part of VX-501` / `Part of VX-511` / `Part of VX-503`; NO trailers of any
kind.

### UNIT B2 — LIVE STATUS (the implementer owns this section)

**NOT DONE BY THIS SESSION (first, as the contract asks):** **T-B5-2's listing blindness — RECORDED, NOT BUILT** (a finding
for the orchestrator, custody code, a ticket candidate: the production sync-keys leaf never lists a Touch ID-only item, so the
leaves and `holdSyncKeys`' drops never delete it — the source of the stale item behind VX-503; Piece 3's options (a)–(c)); the
VX-503 fix built is the traced READ only (the join no longer presses for it). No `xcodebuild test`, no stage, no app launch,
no dev/real-store touch, no server or production contact (the run's traps) — the Mac-target suites this unit touches run in
the orchestrator's stage batch (THE MAC-SUITE LIST, Piece 4). Two branches are unpinned, said in their pieces: VX-501's reuse
of a vault the settle already read, and VX-511's reopen-not-ready mark. The walk script's `--env` hand-off (F-B1-1) is
dry-checked only here — its live proof is unit C's (the orchestrator's walk ran on `4a5ef39e3`). No line in
`Sources/VariorumCore/Sync/`. PROVISIONAL, the architect's/hers: P-VX510-B2-1 (VX-501's 10 s vault bound).

*Implementer session B2 — Opus 5.5, xhigh. Pre-fix tree = `b07c2833f` (unit B1's product files). Every claim not yet run is
PENDING.*

- **Piece R** — the preflight read whole, myself: CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE;
  `notes/SyncSpec.md` §3 (read whole); `notes/SurfaceContracts.md`'s protection bullet whole; `notes/SessionResiliencyProtocol.md`;
  this file WHOLE; vx-488's M1 RECORD WHOLE + OPEN ITEMS M1 (c); vx-494's R-494-4; the walk switch's road, `ProjectConfig`,
  `ProdTestRoadTests`, `Tools/WalkKit/first-run-walk.sh`: DONE (the code for D-B4/D-B6/D-B5 is read as each piece starts).
- **Piece 0** — the harness: DONE (not durable — this session's scratchpad `vx510b2-harness`, unit B1's copied whole but its
  build products; runner `b2/test.sh <log> <filter|ALL>` under a watchdog, `b2/revert.sh` for the reverts). **BASELINE on the
  pre-fix tree (`b07c2833f`), the three harness-PATH artifacts `--skip`ped (unit A's Piece 0): `✔ Test run with 477 tests in
  82 suites passed`** — exactly B1's close.
- **Piece F — F-B1-1 (B), RULED (Part of VX-510): DONE — `4a5ef39e3` (pushed at once; THE COMMIT THE ORCHESTRATOR BUILDS
  THE LIVE WALK FROM).** `Shared/Protection/ProtectionWalkSwitch.swift`: the app reads the allowlist from the launch
  environment's `VARIORUM_PRODTEST_EMAILS` (the file's one key's shape — space-separated; one pair of surrounding quotes
  dropped), never a file — `AllowlistRead`, `readAllowlist`, `realHome`, `prodTestAllowlistPath` and the file parse DELETED;
  `prodTestRoad(switchValue:walkProject:allowlist:)`'s input is the handed value (nil = not handed), read only when asked;
  refusals now `walkProjectToo` · `allowlistNotHanded` (new) · `allowlistEmpty` · `unmarkedEntry` (the file's missing /
  unreadable / not-600 refusals left with the file); `prodTestRoadForThisLaunch(walkProject:environment:)` (the environment
  injectable, defaulting to the process's). Every in-app guard kept and unchanged: exactly `1` asks, a walk project refuses
  first, empty refuses, every entry carries `vxtest`, the admission per account at connect (`AppServices` untouched).
  `Shared/ProjectConfig.swift`: its comment. `Tools/WalkKit/first-run-walk.sh`: P1 reads the file's one key in a subshell
  (`allowlist_value` — after G2's checks: a regular file, mode 600, every entry marked, the account listed) and launches with
  `--env VARIORUM_PRODTEST_EMAILS="$LIST"` beside the switch (never printed; the emails are no secret — `ps eww` shows them;
  the secrets beside them are never handed); P2 also checks the process carries the handed list; the header's F-B1-1 note
  states the ruled shape; `--self-test` gains the handed-value case (the list key alone, never another key). `README.md`'s
  sentence. Pins (`ProdTestRoadTests`, every file-reading pin now the env form): `withNoSwitchTheFenceHoldsAndNothingIsRead`,
  `theSwitchWithAWalkProjectRefuses`, `eachAllowlistFaultRefusesAndTheFenceStands` (nil · empty · blank · `""` · an unmarked
  entry beside a marked one · alone · a her-shaped bare address beside a test one), `theSwitchAndAHandedMarkedListArmTheRoad`,
  `theHandedListIsParsedAsTheFilesOneKey`, **NEW** `theLaunchReadsTheHandedListFromItsEnvironment` (the launch's own reading:
  armed on the switch + the list; the switch alone refuses as nothing handed — no file read in its place; a list without the
  switch asks nothing; an unmarked handed entry refuses), **NEW** `theRoadReadsNoFile` (guard, code only: the road's section
  names no file API), **NEW** `aHerShapedAddressIsNeverAdmitted` (an armed list of plus-addresses admits neither the bare inbox
  address nor a case, plus or suffix variant; the bare address handed refuses the road outright); `aReleaseBuildCompilesNothing
  OfTheRoad` also names `VARIORUM_PRODTEST`. The new pins need the new seam to compile — their red is the reverts' below.
  **The harness, `--filter "ProdTestRoadTests|SyncWalkFenceTests|ProtectionWalkSwitchTests|ProtectionWalkProjectTests|
  SyncLockedRowTests"`: `✔ Test run with 34 tests in 5 suites passed`**; no warning in a touched file. The walk script:
  `zsh -n` clean; `--self-test` → every case as expected, `SELF-TEST: every guard fired as expected` exit 0.
  **THE REVERTS (named BEFORE any run; each one file — `ProtectionWalkSwitch.swift` — on the committed tree, the harness
  `--filter ProdTestRoadTests`, restored by `git checkout --`, `git diff --exit-code` clean after each):** **DONE on
  `4a5ef39e3` — every one RED as named, every restore clean; NO REVERT IS IN FLIGHT** (results in brackets after each):
  - **RF-1** the launch's reading hands the rule nothing (`allowlist: { nil }`) [`theLaunchReadsTheHandedListFromItsEnvironment`].
    → `✘ Test run with 14 tests in 1 suite failed with 3 issues` — `theLaunchReadsTheHandedListFromItsEnvironment` ✘×2 (the
    armed leg read `.refused(.allowlistNotHanded)`; the unmarked leg likewise), and `theRoadReadsNoFile` ✘ (its own teeth
    line: the handed read gone from the code).
  - **RF-2** the marker check removed [`eachAllowlistFaultRefusesAndTheFenceStands`, `aHerShapedAddressIsNeverAdmitted` (the
    outright refusal), `theLaunchReadsTheHandedListFromItsEnvironment` (the unmarked leg)]. → `✘ … 14 tests … with 11
    issues` — `eachAllowlistFaultRefusesAndTheFenceStands` ✘×9, `theLaunchReadsTheHandedListFromItsEnvironment` ✘,
    `aHerShapedAddressIsNeverAdmitted` ✘ (the bare address armed the road).
  - **RF-3** a list not handed reads as an empty one (`allowlist() ?? ""`) [`eachAllowlistFaultRefusesAndTheFenceStands` (nil),
    `theLaunchReadsTheHandedListFromItsEnvironment` (the switch alone)]. → `✘ … with 2 issues` — each of the two ✘.
  - **RF-4** the empty guard removed (an empty list arms) [`eachAllowlistFaultRefusesAndTheFenceStands`]. → `✘ … with 9
    issues` — that pin ✘×9 (the empty, blank and `""` lists armed an empty allowlist).
  - **RF-5** the quote drop removed [`theHandedListIsParsedAsTheFilesOneKey`, `eachAllowlistFaultRefusesAndTheFenceStands` (`""`)].
    → `✘ … with 3 issues` — `theHandedListIsParsedAsTheFilesOneKey` ✘×2, `eachAllowlistFaultRefusesAndTheFenceStands` ✘.
  - **RF-6** the admission matches loosely (an entry containing the address, or the address containing an entry)
    [`aHerShapedAddressIsNeverAdmitted`]. → `✘ … with 8 issues` — that pin ✘×8 (the bare and fragment addresses admitted).
  (The walk script's `--env` line has no headless revert — nothing may launch here; unit C's P2 proves it live.)
- **Piece 1 — D-B4 (VX-501, Part of VX-501): DONE** — 1a `6313178e7` (red pins) · 1b `b12ee17d2` (the fix) · 1c `8fb5f7b2f`
  (one pin leg tightened) + this commit (the revert results).
  - **1a — the pins that compile on the pre-fix tree, committed RED before the fix: DONE (this commit).** Read first:
    `ProtectionOpenRoad` whole (`openTyped`, `typedCandidates`, `pressTouchID`, `loadSyncKeysForTheSession`),
    `NewRoadSyncKeyProvider`, `WireVaultLeaf`, `ProtectionRoadLock.dropSessionMemory`, the core's `KeyDoors`
    (`holdSyncKeysForTheSession` — `internal` to the core, so the app cannot call it; its two derivation calls are the
    public `AccountVault.master(passphrase:words:)` and `keys(master:)`), `Executor` (`readVault`, `freshVaults`, `unlock`),
    `VaultModel`, `Secrets`, `KeyFile` (open roads; the master's words copy), `AccountActs.joinKeyFile` (the typed
    passphrase's lock IS the account's — "its descriptor the vault's" — so the lobby's derived key opens the vault's
    passphrase wrap with NO second Argon2id), the bootstrap's lobby roads and `lockOnNewRoad` (the lock stops the services
    and drops session memory; the unlock's ready composes fresh services whose first round reads the provider). New suite
    `VariorumTests/Protection/TypedUnlockSyncKeysTests.swift` (planted — `ProtectionAccountSupport`'s vault + sync keys; the
    Always-ask world `castleAlwaysAskSynced`, VX-487's Touch ID world reused): `vx501_aTypedPassphraseUnlockUnderAlwaysAsk
    LoadsTheAccountsKeys` (session holds the vault's keys, the provider reads them, ONE vault read, nothing written to the
    keychain), `vx501_theTwelveWordsTypedLoadThemToo`, `vx501_aTypedUnlockUnderTouchIDLoadsThemWithNoPress` (no Touch ID
    custody read, no sync-keys Touch ID read, no ride), `offlineTheTypedUnlockStillOpensAndLoadsNothing`,
    `aSecretThatOpensTheLibraryButNotTheVaultLoadsNothing` (the passphrase changed elsewhere), `anAccountThatMovedLoadsNothing`
    (the account's sync key replaced since this library followed); GUARDS `aStandardLibraryLoadsNothingAndReadsNoVault`,
    `anUnboundCastleLibraryReadsNothing`, `signedOutReadsNothing` (signed out, and signed into another account). **RED on
    the pre-fix tree** (the harness, `--filter TypedUnlockSyncKeysTests`): `✘ Test run with 9 tests in 1 suite failed with 10
    issues` — the passphrase pin ✘×3 (session nil · the provider read nothing · no vault read), the words pin ✘×2, the Touch
    ID pin ✘×2, and the "the read was tried" legs of offline / not-the-vault / moved ✘ each (their never-hostage legs pass
    on both sides, as pin 5's did at VX-487); every world's preconditions held (no issue in the setups); the three guards ✔
    (by design on both sides — their teeth are the reverts').
  - **1b — THE FIX: DONE (`b12ee17d2`).** `Shared/Protection/ProtectionOpenRoad.swift`: `openTyped` (now
    `openTyped(_:secret:syncKeysWithin:)`, the bound defaulted) calls the new **`loadSyncKeysAfterTypedUnlock`** on
    `.opened`, after the open and before the app's open goes on (off the main actor — the lobby's press is detached).
    The load: a read-only road (a hosted test run), an unbound library or a STANDARD one (the silent item serves — the
    design's own pin) reads nothing; keys already in session (or a silent item) that this library follows ⇒ nothing read;
    signed out or into another account ⇒ nothing read; the vault = the one this session's executor already read (an act's
    resume at the settle — the design's "where one was already made"), else ONE read through the vault leaf, BOUNDED
    (`boundedVaultRead` — the read races a timer, the first answer wins, the loser is cancelled and a late answer dropped:
    no hold can land after the open moved on); the master from the typed secret against the vault — the passphrase's key
    is the one the OPEN derived (`typedCandidatesAndKeys` now hands back the derived `PassphraseKey`s, one per descriptor;
    the account's lock carries the vault's descriptor — `joinKeyFile` — so no second Argon2id), the words' wrap key derived
    once (BIP-39's seed; the open's own key-file derivations are the core's, untouched); `keys(master:)`; held in session
    ONLY when they are the keys this library FOLLOWS (`record.accountRowKeyID` — what the Touch ID item would hold; a moved
    account leaves the follow to load them); never a Touch ID read (no prompt), nothing written to disk, the secret gone
    with the call. Every refusal is one protection-log line; the library opens all the same. `typedCandidates` keeps its
    signature (a wrapper). `NewRoadSyncKeyProvider.swift`: its header names the typed load (comment only). No core line:
    `holdSyncKeysForTheSession` is internal to the core, so the app makes its two public calls itself — no LocalAuthentication
    and no network read enters the core; no `Sync/` line. **PROVISIONAL P-VX510-B2-1 (the architect's / hers — timing, not
    words):** the vault bound is 10 s — (a, built) the unlock waits at most 10 s for the vault, then opens without the keys
    (the row says locked as before; a later answer dropped) · (b) a shorter bound (e.g. 3 s — a slow but working network
    then loses the load more often) · (c) no wait at all: the load runs after the open and a round is asked when it lands
    (needs a lock-race guard and the services' round road from the lobby — more machinery).
    Pins added (new seam — red by the reverts below): `aVaultReadPastTheBoundLeavesTheUnlockOnTimeAndALateAnswerIsDropped`
    (a planted fetch that answers after 2 s and IGNORES cancellation — `PlantedVaultLeaf.fetchDelay`, test support: the
    unlock returns inside 1.5 s, nothing loaded, and after the late answer still nothing held), `theTypedLoadNeverDerivesThe
    Passphrase` (guard, code only: the load names no passphrase derivation and no Touch ID read); guards `keysAlreadyHeld
    ReadNoVault`, `aReadOnlyRoadReadsNothing`; the Standard guard extended (its silent item removed: still no vault read —
    the posture's rule, not the item's). **The harness, `--filter "TypedUnlockSyncKeysTests|TouchIDUnlockSyncKeysTests|
    ProtectionAccountRoadTests|ProtectionJoinFollowRoadTests|ProtectionLobbyModelTests|ProtectionOpenRoadPlantedTests"`:
    `✔ Test run with 64 tests in 7 suites passed`** (before the last three pins); `--filter TypedUnlockSyncKeysTests` on
    this commit: **`✔ Test run with 13 tests in 1 suite passed`** — 1a's six red pins GREEN; no warning in a touched file.
  - **1c — THE REVERTS (named BEFORE any run; each one line of `ProtectionOpenRoad.swift` on this commit, the harness
    `--filter TypedUnlockSyncKeysTests`, restored by `git checkout --`, `git diff --exit-code` clean after each):** **DONE —
    every one RED as named, every restore clean; NO REVERT IS IN FLIGHT** (RD4-2…8 on `b12ee17d2`; RD4-1 first there,
    then again on `8fb5f7b2f` — see its line). Results after each:
    - **RD4-1** `openTyped` no longer calls the load (the pre-fix press) [the three `vx501_` pins; the "tried" legs of
      offline / not-the-vault / moved; the bound pin's "the read was made"]. → on `b12ee17d2`: `✘ Test run with 13 tests in
      1 suite failed with 10 issues` — the passphrase pin ✘×3, the words ✘×2, the Touch ID ✘×2, offline / not-the-vault /
      moved ✘ each — but the bound pin STAYED GREEN: its "the read was made" leg was HOLLOW (`calls.contains` counted the
      world's setup reads). Tightened to count this unlock's fetch (`8fb5f7b2f`, test only) and RD4-1 re-run there: `✘ … 13
      tests … with 11 issues` — the same ten plus the bound pin ✘ ("the read was made").
    - **RD4-2** the Castle gate removed [`aStandardLibraryLoadsNothingAndReadsNoVault` (its silent-item-gone leg)]. → `✘ …
      with 2 issues` — that pin ✘×2 (the vault read, the keys held — only once the silent item was gone: with it, the
      already-held check stops the read, which is why the leg exists).
    - **RD4-3** the signed-in gate always passes [`signedOutReadsNothing`]. → `✘ … with 3 issues` — that pin ✘×3.
    - **RD4-4** the follows check always passes (a moved account's keys held) [`anAccountThatMovedLoadsNothing`]. → `✘ …
      with 1 issue` — that pin ✘ (the moved keys held).
    - **RD4-5** the bound removed (the read awaited to its end) [`aVaultReadPastTheBoundLeavesTheUnlockOnTimeAndALateAnswer
      IsDropped`]. → `✘ … with 3 issues` — that pin ✘×3 (the unlock waited the read's 2 s; the late keys held).
    - **RD4-6** the read-only gate removed [`aReadOnlyRoadReadsNothing`]. → `✘ … with 1 issue` — that pin ✘.
    - **RD4-7** the already-held short-circuit never matches [`keysAlreadyHeldReadNoVault`]. → `✘ … with 1 issue` — that pin
      ✘ (a vault read with the keys already held).
    - **RD4-8** the already-held check reads the TOUCH ID item (the core door's order — a prompt) [`vx501_aTypedUnlockUnder
      TouchIDLoadsThemWithNoPress`, `theTypedLoadNeverDerivesThePassphrase`]. → `✘ … with 4 issues` — the Touch ID pin ✘×3
      (a Touch ID read; the item's keys seen as "already loaded", so nothing put in session) and the guard ✘.
    (Not pinned, said plainly: the reuse of a vault the settle already read — planting an act in flight resumed by a typed
    unlock is a world of its own; the branch is the design's one-read rule, read by the reviewer.)
- **Piece 2 — D-B6 (VX-511, Part of VX-511): DONE** — 2a `2275ad009` (red pins) · 2b `e0c3064a8` (the fix) · 2c this commit
  (the revert results).
  - **2a — the pins, committed RED before the fix: DONE (this commit).** Read first: `WordsBand.swift` whole (the ledger
    `WordsCardLedger` — `variorum.calmAsks.words.<libraryID>.*`; the band's `offersWords`, set at init from the ledger and
    retired by `later` / `dismiss` / `wordsRecorded`), `ProtectionCopyDoors`' VX-444 carry (Make this my library) and the
    empty-slot landing's mark, `ProtectionOpenFaces`' `RoadStandingModel.make` (the band built at every ready from the
    ledger), the bootstrap's `accountRoads()` (`press` — the open-session acts, and `accountActOnNewRoad` for a re-keying
    one through `reopenAround`, which awaits the reopen's ready — and `landed`, which re-reads faces only and knows no door).
    THE MECHANISM (traced): no account act ever writes the ledger, and the band computed at the ready keeps offering; a
    re-keying act's reopen rebuilds the band from the same unmarked ledger. New suite
    `VariorumTests/Protection/WordsCardAfterAccountActTests.swift` (the bootstrap over the planted road — unit A's
    `FirstRoundWorld`, no services; B1's `FirstRunDrillTests.press`): `vx511_theSetUpRetiresTheCard` (+ another library's
    ledger untouched), `vx511_aStandardJoinRetiresTheCard`, `vx511_aCastleJoinRetiresTheCard`,
    `vx511_aReKeyingJoinRetiresTheReopenedLibrarysCard` (the card the REOPEN built, the library the reopen landed),
    `vx511_moveRetiresTheCard`; GUARDS `aRefusedActMarksNothing` (a join with a wrong passphrase), `aLeaveMarksNothing` (Stop
    syncing here on a library bound before the open). **RED on the pre-fix tree** (the harness, `--filter
    WordsCardAfterAccountActTests`): `✘ Test run with 7 tests in 1 suite failed with 10 issues` — each of the five landings
    ✘×2 (the ledger not recorded · the card still offering); every precondition held (nothing recorded, the card offering,
    the act landed, the reopen built the card anew); the two guards ✔ (by design — the reverts show their teeth).
  - **2b — THE FIX: DONE (`e0c3064a8`).** `Shared/Protection/RoadAccountFaces.swift`: `RoadAccountDoor.landingRecordsTheWords`
    (Turn on sync — the set-up and the join, either posture — and Move; never the leaves, never the follow).
    `Shared/AppBootstrap.swift`: `accountRoads().press` keeps the press's answer and, on `.made` through such a door, calls
    the new `accountActHoldsTheWords(actedOn:)` — THE ONE WRITER: the library is read from the session the act ran on, AFTER
    the act (its record carried forward in place; a re-keying act's reopen opens that same slot library — the VX-457 mark's
    idiom), so even a reopen that settled anywhere but ready finds it marked; it records `WordsCardLedger(defaults: the
    calm-asks defaults).record(libraryID)` and, when the open library is that one, retires the live card
    (`roadStanding?.band?.accountHoldsTheWords()` — a re-keying act's reopen built its card from the unmarked ledger before
    the press returned). `Shared/Protection/WordsBand.swift`: `WordsBandModel.accountHoldsTheWords()` — the offer retires
    (`offersWords = false`, one log line); the reminder's half untouched; the ledger is the bootstrap's write. A refused act
    marks nothing. **The harness, `--filter "WordsCardAfterAccountActTests|WordsBandTests|WordsBandSurfaceTests|
    WordsLedgerCarryRoadTests|LibraryWordsCardTests|RoadAccountModelTests|RoadJoinFollowModelTests|FirstRunDrillTests|
    RoadAccountFacesTests"`: `✔ Test run with 59 tests in 7 suites passed`** (before the one-writer split); `--filter
    WordsCardAfterAccountActTests` on this commit: **`✔ Test run with 7 tests in 1 suite passed`** — 2a's five red pins
    GREEN; no warning in a touched file. (Not pinned, said plainly: the reopen-not-ready edge — the ledger marked with no
    ready card to retire; planting a re-keying reopen that settles in a lobby is a world of its own.)
  - **2c — THE REVERTS (named BEFORE any run; one file each on this commit, the harness `--filter
    WordsCardAfterAccountActTests`, restored by `git checkout --`, `git diff --exit-code` clean after each):** **DONE on
    `e0c3064a8` — every one RED as named, every restore clean; NO REVERT IS IN FLIGHT:**
    - **RD6-1** `AppBootstrap.swift`: the press never marks (the pre-fix press) [the five landing pins, both legs]. → `✘ Test
      run with 7 tests in 1 suite failed with 10 issues` — each of the five ✘×2.
    - **RD6-2** `AppBootstrap.swift`: the ledger is written but the live card is not retired [the five pins' card leg]. →
      `✘ … with 5 issues` — each of the five ✘ (the card still offering — the re-keying join's too: its reopen built the card
      from the unmarked ledger).
    - **RD6-3** `AppBootstrap.swift`: the card is retired but the ledger is not written [the five pins' ledger leg]. → `✘ …
      with 5 issues` — each of the five ✘ (the ledger unrecorded: a later open's card would offer again).
    - **RD6-4** `RoadAccountFaces.swift`: every door's landing records the words [`aLeaveMarksNothing`]. → `✘ … with 2
      issues` — that guard ✘×2.
    - **RD6-5** `AppBootstrap.swift`: the mark on any press answer, not only `.made` [`aRefusedActMarksNothing`]. → `✘ …
      with 2 issues` — that guard ✘×2.
- **Piece 3 — D-B5 (VX-503, Part of VX-503): THE TRACE DONE (this commit — code read, file:line; no keychain, no launch);
  the fix of the traced read DONE (3b-1 `58c4eb98c` red pins · 3b-2 `226cf7c20` the fix · 3b-3 the reverts, this
  commit).** The observation (vx-494 O-1): a Standard library JOINING a Standard
  account raised the system prompt "Variorum Dev is trying to Unlock your Variorum library. Touch ID to continue…", waited,
  was cancelled, and the join completed.
  - **T-B5-1 — WHICH READ:** the prompt's words are `KeychainCustodyLeaf.pressReason` ("Unlock your Variorum library",
    KeychainCustodyLeaf.swift:39), set on a FRESH `LAContext` by exactly two reads: the custody Touch ID read
    (`readTouchID`, :156–157 — a join never calls it: the plan runner's custody Touch ID read is a re-keying RESUME's,
    `reachNewKey`, PlanRunner.swift:464–473) and the context-less sync-keys Touch ID read (`KeychainSyncKeysLeaf
    .readSyncKeys(accountID:itemClass: .touchid)`, KeychainSyncKeysLeaf.swift:61–71). A same-posture join runs
    `pickUpJoinKeys` FIRST (AccountActs.swift:47, :82) → `pickUpKeys` (Follow.swift:124–129) → `material(for:)`
    (CommonSteps.swift:391) → `syncMaterial()` (:315–326), which reads the account's **TOUCH ID item before anything else**
    (:318–319) — even though the act already holds the typed secret that opens the vault (`join` verified it, AccountActs
    .swift:316–330). On the real leaf that read prompts IFF a Touch ID sync-keys item for that ACCOUNT exists in the scope
    (`exists` probes and listings never prompt — ProtectionKeychain.swift:86–98, :134–148).
  - **T-B5-2 — WHY AN ITEM WAS THERE (a fresh Standard library):** sync-keys items are keyed by SCOPE + ACCOUNT, never by
    library (`ProtectionNames.syncKeysAccount`), so a Touch ID item written by an EARLIER Castle + Touch ID library synced to
    the same account on this Mac outlives it: the production leaf's listing is BLIND to a Touch ID item with no silent
    sibling — `syncKeyItems()` probes Touch ID only for accounts in `touchIDCandidates ∪` the listed (silent) items
    (KeychainSyncKeysLeaf.swift:45–58), and production never wires the candidates (`AppBootstrap.init` mints
    `KeychainSyncKeysLeaf(scope:)` with the default `{ [] }`, AppBootstrap.swift:183 — the leaf's own comment, :30–31, says
    "VX-308's sync setup wires the bound account here"; it never did) — and in the Castle + Touch ID state the silent item is
    dropped (CommonSteps.swift:362). So every forget that walks the listing misses it: the leaves' `forgetSyncKeys(of:)` and
    `forgetUnboundSyncKeys` (AccountActs.swift:224–241), the rollback's sweep (PlanRunner.swift:544–547), and `holdSyncKeys`'
    `drop(.touchid)` on a move to Standard (CommonSteps.swift:342–347, :367 — the listing taken BEFORE the silent write).
    The walks add one more road: the dev slot is set aside by `mv`, the keychain untouched. The vx-494 walk's Mac had run
    the vx-488 rehearsal's Castle + Touch ID libraries synced to the throwaway accounts hours earlier — **the exact item on
    that Mac is UNVERIFIED** (no command-line tool reaches the data-protection keychain); the mechanism is the one road the
    code allows to that prompt at that step.
  - **T-B5-3 — WHAT A CANCEL SKIPS: nothing the join needs.** `errSecUserCanceled` → `readSyncKeys` answers nil
    (KeychainSyncKeysLeaf.swift:73–77) → the silent item → session memory → nil → `material(for:)` derives the keys from the
    vault with the typed secret (CommonSteps.swift:395–400). Had she pressed, the item's keys would be used only when they are
    the vault's current sync key under its master (:392) — the very keys the derivation gives. The prompt bought nothing.
  - **T-B5-4 — RESIDUE: the cancel leaves none of its own; the STALE ITEM SURVIVES THE JOIN.** Standard's `holdSyncKeys`
    (CommonSteps.swift:363–368) writes the silent item and calls `drop(.touchid)`, but `drop` consults the listing taken at
    :342, before that write — no silent sibling then, so the Touch ID item was not listed and is not dropped. The NEXT
    listing does see it (the sibling exists now), so a later act's `holdSyncKeys` drops it — but every road reading the Touch
    ID class FIRST prompts again before that: the key doors' `holdSyncKeysForTheSession` (KeyDoors.swift:258–261) — Change
    passphrase / New Words on the joined Standard library would raise the same prompt. **The same blindness reaches
    production with no walk:** Use Standard on a synced Castle + Touch ID library (`leaveCastleWrite` → `material(for:)`
    reads the Touch ID item — a prompt though both secrets were typed — then `holdSyncKeys(castleWay: false)` leaves the item,
    CommonSteps.swift:447–461), and every LEAVE of a Castle + Touch ID library (its only item is the Touch ID one — the
    leaves' forget never lists it).
  - **THE FIX, scoped to the traced read (3b, below):** the act stops reading custody when the TYPED secret already opens
    the vault — `material(for:)` derives from the vault first, custody only when no typed secret reaches the master (the
    quiet follow out of Castle; the key doors, whose secrets are the NEW ones). Same keys, no keychain read, no prompt: the
    observed Standard join, Use Standard's press, and Use Castle's resume all stop prompting. **RECORDED, NOT BUILT — a
    finding for the orchestrator (a ticket candidate, custody code):** T-B5-2's listing blindness (the leaves and the drops
    never delete a Touch ID-only item — rule 16's "this Mac forgets its sync keys" untrue for the Touch ID class; the Touch ID
    read on a STANDARD library in `holdSyncKeysForTheSession`). Options: (a) the forgets and `holdSyncKeys`' drops delete
    BOTH classes BY NAME for the account (the real delete is idempotent — `ProtectionKeychain.delete` accepts not-found;
    deleting an ACL'd item never prompts — `writeSyncKeys(.touchid)` already does it, KeychainSyncKeysLeaf.swift:104–105);
    (b) wire the production leaf's `touchIDCandidates` (the bound account + the act's forgets) as the leaf's comment
    intended; (c) never read the Touch ID class while the library is STANDARD (Standard files silently — rule 15). Its pins
    need a planted leaf whose listing is production-shaped (the planted leaf lists every item, which is why no planted test
    ever saw this).
  - **3b-1 — the pins, committed RED before the fix: DONE (this commit).** New suite
    `VariorumTests/Protection/TypedSecretNeverPressesTests.swift` (planted — `PlantedSyncKeysLeaf.touchIDReads` counts every
    context-less Touch ID read, each a prompt on the real leaf): `vx503_aStandardJoinWithAStaleTouchIDItemNeverPresses` (the
    observation's road: a fresh Standard library joins a Standard account by its passphrase with a stale Touch ID item
    standing — no Touch ID read; the vault's own keys filed silently), `vx503_useStandardWithBothSecretsTypedNeverPresses
    ForTheSyncKeys` (synced Castle + Touch ID → Use Standard, both secrets typed — no Touch ID sync-keys read); GUARD
    `theCustodyFallbackStandsWhenNoTypedSecretOpensTheVault` (Change passphrase — the key door's secrets are the NEW ones —
    still finds the held keys and re-wraps the account's lock). **RED on the pre-fix tree** (the harness, `--filter
    TypedSecretNeverPressesTests`): `✘ Test run with 3 tests in 1 suite failed with 2 issues` — each road ✘ exactly on
    `touchIDReads == presses` (the join and Use Standard landed; the preflight ready); the guard ✔. (The Use Standard pin's
    FIRST draft opened its door through `Crossing.press`, whose read is signed out — it failed on its precondition, not its
    claim; redrawn on the world's own signed-in read, then red on the claim.)
  - **3b-2 — THE FIX: DONE (`226cf7c20`).** `Sources/VariorumCore/Protection/Executor/Acts/CommonSteps.swift` — ONE function,
    `ActContext.material(for:)`: the vault with the secrets in hand FIRST (`VaultModel.master` → `keys(master:)` — no
    keychain read), custody's keys only when no secret in hand opens the vault (still checked current under the vault's
    master), else `secretsRequired` as before. Same keys either way (both the vault's current sync key under its master;
    the derivation reads every earlier key from the vault itself); every caller traced: the joins and Move
    (`pickUpKeys`), the follow, Use Castle's write and resume, Use Standard's write, set-up's `newLocks` (the new passphrase
    under the vault's own descriptor — the same keys as the act's cache), the key doors' vault step (their secrets are the
    NEW ones — the fallback serves, as before; Reset by the words and New Words by the current passphrase now derive — the
    same keys). No LocalAuthentication, no network read, no `Sync/` line enters the core. **The harness, `--filter
    "TypedSecretNeverPressesTests|TypedUnlockSyncKeysTests|TouchIDUnlockSyncKeysTests|ProtectionAccountRoadTests|
    ProtectionJoinFollowRoadTests|ProtectionCrossingRoadTests|RoadKeyDoorRoadTests|FirstRunDrillTests|
    WordsCardAfterAccountActTests"`: `✔ Test run with 84 tests in 10 suites passed`** — 3b-1's two red pins GREEN. The core
    protection set (debug + release) is Piece 4's.
  - **3b-3 — THE REVERTS (named BEFORE any run; `CommonSteps.swift` on this commit, the harness `--filter
    "TypedSecretNeverPressesTests|RoadKeyDoorRoadTests"`, restored by `git checkout --`, `git diff --exit-code` clean after
    each):** **DONE on `226cf7c20` — both RED as named, both restores clean; NO REVERT IS IN FLIGHT:**
    - **RD5-1** `material(for:)` back to custody first (the pre-fix order) [both `vx503_` pins]. → `✘ Test run with 14
      tests in 2 suites failed with 2 issues` — both `vx503_` pins ✘ (a Touch ID read each); the key doors' suite green.
    - **RD5-2** the custody fallback removed (the typed secret or nothing) [`theCustodyFallbackStandsWhenNoTypedSecretOpens
      TheVault`, and the key doors' road suite]. → `✘ … with 5 issues` — the guard ✘ and `RoadKeyDoorRoadTests
      .syncedChangeChangesTheAccountsPassphraseWithIt` ✘×4 (the key door's vault step found no keys).
- **Piece 4 — EVIDENCE: DONE** (the final tree = `e829e8d08`'s product files; foreground, in sequence):
  - THE HARNESS whole (debug; this unit's three new suites symlinked in): `✘ Test run with 505 tests in 85 suites failed with
    4 issues` — exactly the three harness-PATH artifacts (`theBecomeActiveHookRunsOneSyncRound`,
    `theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut` ×2, `thePasteInIsFullyRetiredInTheSharedSources` — they read
    `#filePath` beside the symlink; they run in the Mac target); with those three `--skip`ped: **`✔ Test run with 502 tests in
    85 suites passed`** (B1's 477/82 + this unit's 23 tests in 3 new suites + 2 more in `ProdTestRoadTests`); no `signal` line.
  - RELEASE COMPILE (the harness's app sources, `swift build -c release --target Variorum`): **`Build complete!`**.
  - THE CORE (`Sources/` touched — `CommonSteps.swift`): the protection + auth/account set (every suite under
    `Tests/VariorumCoreTests/Protection` + `AccountBindingGateTests`, `AccountLifecycleTests`, `AuthRLSDDLTests`,
    `KeyVaultClientTests`, `SupabaseTransportTests`, `SupabaseTransportSessionTests`; one `--filter`, 102 suite names — the
    first extraction missed `AccountVaultWireTests` (`@Suite struct` on one line), re-run with it): debug **`✔ Test run with
    533 tests in 102 suites passed`**; release (`swift build -c release --build-tests -Xswiftc -enable-testing`, then `swift
    test -c release --skip-build`, the same filter) **`✔ Test run with 509 tests in 98 suites passed`** — both exactly vx-488
    M1's close counts; 0 failures, 0 `skipped:` lines.
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx510-b2
    build-for-testing`: **`** TEST BUILD SUCCEEDED **`**; `xcodebuild -scheme VariorumMobile -destination 'generic/platform=iOS
    Simulator' -derivedDataPath App/Variorum/DerivedData/vx510-b2-ios build-for-testing`: **`** TEST BUILD SUCCEEDED **`** —
    zero errors, no warning in any file this unit touched (both logs grepped).
  - THE WALK SCRIPT (F-B1-1): `--self-test` → every case as expected incl. the handed value; `std --app
    App/Variorum/DerivedData/vx510-b2/Build/Products/Debug/Variorum.app --dry-run` → G1–G4 held, then `REFUSES: G5 — a Variorum
    instance is running` (the orchestrator's unit C walk build, from its stage checkout — left alone) exit 5: nothing launched.
  - **Machinery honesty:** the orchestrator committed to this branch while the unit ran (unit C's records — `532ad1376`,
    `e630c1015`, `39952dff5`, `97334e232`, `936ef3c3f` and others); this session staged explicit paths only, re-read the
    record before each edit, and never touched those sections. Two `git pull --rebase` calls made BEFORE a commit refused
    over this session's own unstaged edits ("Please commit or stash them") — each commit then pulled and pushed after
    itself; nothing was lost or reordered (verified `HEAD == origin` each time).
  **THE MAC-SUITE LIST (for the orchestrator's stage batch — every suite exercising a file this unit changed):**
  - NEW (harness-green): `TypedUnlockSyncKeysTests` (VX-501), `WordsCardAfterAccountActTests` (VX-511),
    `TypedSecretNeverPressesTests` (VX-503).
  - CHANGED (harness-green): `ProdTestRoadTests` (F-B1-1 — the env form + three new pins), `ProtectionAccountSupport`
    (`PlantedVaultLeaf.fetchDelay`; every suite that plants an account — below).
  - `ProtectionWalkSwitch` / `ProjectConfig` (F-B1-1): `ProtectionWalkSwitchTests`, `ProtectionWalkProjectTests`,
    `SyncWalkFenceTests`, `ProtectionCrossingRouteTests`, `RoadRearmTests`.
  - `ProtectionOpenRoad` (VX-501 — `openTyped`, `typedCandidatesAndKeys`, the load): `ProtectionLobbyModelTests`,
    `ProtectionOpenRoadPlantedTests`, `TouchIDUnlockSyncKeysTests`, `RoadLockTests`, `RoadLockRouteTests`, `RoadRearmTests`,
    `NoKeyFileDoorTests`, `OneRefreshAuthorityTests`, `OneSyncKeysLeafTests`, `PreDesignFaceTests`, `PreDesignStartFreshRouteTests`,
    `PreDesignStoreRefusalTests`, `PreviousLibrariesArcTests`, `ProtectionNoticeFaceTests`, `ProtectionOfferFaceTests`,
    `ProtectionReminderRoadTests`, `ProtectionRestoreReceiptTests`, `ProtectionRule27FaceTests`, `ProtectionWordsVX307Tests`,
    `SetPassphraseRowRereadTests`, `SetPassphraseRowRereadRouteTests`, `ProtectionCrossingRoadTests`.
  - `AppBootstrap` / `RoadAccountFaces` / `WordsBand` (VX-511): `FirstRoundConfirmTests`, `FirstRunDrillTests`,
    `FirstRoundAfterTheActTests`, `FirstRoundAfterTheReopenTests`, `RoadAccountFacesTests`, `RoadAccountModelTests`,
    `RoadAccountSurfaceTests`, `RoadJoinFollowFacesTests`, `RoadJoinFollowModelTests`, `RoadJoinFollowSurfaceTests`,
    `ProtectionAccountRoadTests`, `ProtectionJoinFollowRoadTests`, `WordsBandTests`, `WordsBandSurfaceTests`,
    `WordsLedgerCarryRoadTests`, `WordsLedgerCarryRouteTests`, `RoadKeyDoorSurfaceTests`, `AppBootstrapOffMainTests`,
    `SettingsLockCloseTests`, `HoldBannerAccountTests`.
  - `CommonSteps.material(for:)` (VX-503 — every act that picks up or re-wraps the account's keys): `RoadKeyDoorRoadTests`,
    `ProtectionAccountRoadTests`, `ProtectionJoinFollowRoadTests`, `ProtectionCrossingRoadTests`, `TouchIDUnlockSyncKeysTests`,
    `RoadRestoreHoldGateTests`, `ProtectionPaneWaveTests`, `NotOnYetWordsTests`, the first-round suites above, and the
    REAL-keychain suites over the leaves (throwaway scopes) `KeychainLeavesTests`, `ProtectionKeychainFamilyTests`.
  - The simplest honest batch: the whole `VariorumTests/Protection` folder + `ProdTestRoadTests`, `SyncWalkFenceTests`,
    `AppBootstrapOffMainTests`, `SettingsLockCloseTests`, `OneRefreshAuthorityTests`.
  - THE PHONE (`VariorumMobileTests` — `ProtectionOpenRoad`, `AppBootstrap`, the core's acts): `MobileProtectionRoadTests`,
    `MobileProtectionTests`, `MobileStructuralTests`, `MobileEmptyStoreTests`.
  **THE WALK (this unit's rows, for the stage — use-shaped; unit C has already shown VX-501 live, `936ef3c3f`):** (1) F-B1-1:
  the walk launch carries `VARIORUM_PRODTEST_EMAILS` (`ps eww`) and the app logs `PROD TEST ROAD (VX-510): ARMED`; (2) VX-501:
  a Castle (Always ask) library synced, ⌃⌘L, the passphrase typed at the lobby → the protection log's `the typed unlock loaded
  the account's sync keys for the session`, the row reaches "Synced ‹time›" with no key act; the twelve words the same;
  offline at the unlock → the library opens, the row says locked; (3) VX-511: after Turn on sync (set-up, then a join on a
  second library) and after Move, the card above the quick entry offers no words for that library; a relaunch keeps it so;
  (4) VX-503: on a Mac whose scope holds a Touch ID sync-keys item for an account (a Castle + Touch ID library synced to it,
  then left), a Standard library joining that account raises NO Touch ID prompt; Use Standard on a synced Castle + Touch ID
  library raises none for the sync keys. Both voices where the card and the row have a face.

## UNIT B3 — THE BRIEF (a fresh `opus-implementer`, one session; spawned only after unit B2 closes)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE; `notes/SurfaceContracts.md`'s
protection bullet whole (the key doors, VX-211's floor, VX-463's concealed field, VX-464's refusal naming);
`notes/SessionResiliencyProtocol.md`; this file WHOLE (D-B7 is your charter; units A/B1/B2's LIVE STATUS for the harness
and seams); the code: `Shared/Protection/RoadKeyDoorsModel.swift`, `RoadKeyDoorFaces.swift`, `ProtectionKeyDoorActs.swift`
(the key doors' road — your door sits beside them), `LookInsideModel.swift` (the one-field secret reading),
`ProtectionOpenRoad.swift` (`typedCandidates`), `ProtectionWords.swift`, the Mac pane that renders the key doors
(`Variorum/Features/Protection/`), and the core's `VaultModel` / `PassphraseKey` / `WordsKey`.

**Your scope — exactly D-B7:** the door, its sheet model, the read-only check road, its words (PROVISIONAL, named in your
record), and its pins (including the zero-writes pin across every arm). A seam that needs a core-package change, or any
`Sync/` line, is a FORK: stop and propose. Not yours: everything else; canon, Linear, `notes/QUESTIONS.md`.

**The discipline, the evidence, the limits — exactly UNIT A — THE BRIEF's**, with `build-for-testing` into
`DerivedData/vx510-b3` / `vx510-b3-ios`. Commits say `Part of VX-513`; NO trailers of any kind.

### UNIT B3 — LIVE STATUS (the implementer owns this section)

**NOT DONE BY THIS SESSION (first, as the contract asks):** PENDING — written at the close. No `xcodebuild test`, no stage,
no app launch, no dev/real-store touch, no server or production contact (the run's traps); the Mac-target suites this unit
touches run in the orchestrator's stage batch (THE MAC-SUITE LIST at the close). No line in `Sources/`.

*Implementer session B3 — Opus 5.5, xhigh. Pre-fix tree = `6acf5771f` (unit B2's product files, `f4af7e368`). Every claim
not yet run is PENDING.*

- **Piece R** — the preflight read whole, myself: CLAUDE.md + its auto-loaded canon; `notes/CastleRules.md` WHOLE;
  `notes/SurfaceContracts.md`'s protection bullet whole (the key doors, VX-211's floor, VX-463's concealed field, VX-464's
  refusal naming); `notes/SessionResiliencyProtocol.md`; this file WHOLE (D-B7; units A/B1/B2's LIVE STATUS; unit C's record
  through C5 — its W-10, a refusal line left standing after the field is retyped, is folded into this unit's sheet); the
  code: `RoadKeyDoorsModel`, `RoadKeyDoorFaces`, `ProtectionKeyDoorActs`, `LookInsideModel` (+ `MakeMineModel.copySecrets`,
  the one-field reading), `ProtectionOpenRoad` (`typedCandidatesAndKeys`, `boundedVaultRead`, VX-501's load), `ProtectionWords`,
  `ProtectionSheetPresenter`, `ProtectionOpenFaces` (`RoadStandingModel`, the pane wave), the bootstrap's `keyDoorRoads` and
  `finish`, the Mac pane (`ProtectionPane`, `RoadKeyDoorSheet`, `WordsLookSection`, the presenter's host in
  `RoadAccountSheet`), the core's `VaultModel` / `AccountVault.master` / `PassphraseKey` / `WordsKey` / `KeyFile.open` /
  `Executor.readVault` (its `freshVaults` cache — the check never goes through it) / `Follow`'s VX-113 test; the suites
  `RoadKeyDoorsModelTests`, `RoadKeyDoorRoadTests`, `RoadKeyDoorSurfaceTests`, `LookInsideRoadTests` (the write-nothing
  proof idiom), `ProtectionAccountSupport`, `ProtectionTestSupport`: DONE (this commit).
- **Piece 0** — the harness: DONE (not durable — B2's `vx510b2-harness` copied whole but its build products to this
  session's scratchpad `vx510b3-harness`, the SwiftPM checkouts carried, the build fresh — `Build complete!`; runner
  `b3/test.sh <log> <filter|ALL> [watchdog]`, `b3/revert.sh <name> <file> <filter>` for the reverts; each new suite or source
  file symlinked in as it lands). **BASELINE on the pre-fix tree, the three harness-PATH artifacts `--skip`ped (unit A's Piece
  0): `✔ Test run with 502 tests in 85 suites passed`** — exactly B2's close.
- **Piece 1** — the composition pins that compile on the pre-fix tree, committed RED: DONE (`b3fd67000`; this record flip
  rode one commit late — the edit missed the commit). New suite `VariorumTests/Protection/SecretCheckCompositionTests.swift`
  (source pins on CODE lines, `#filePath`'s symlinks resolved so they run in the harness):
  `thePaneRendersTheCheckDoorAfterTheWordsSection` (`RoadSecretCheckSection(model: keyDoors)` after the words section; still
  one presenter host), `thePresentersHostCarriesTheCheckSheet` (`case checkSecrets(RoadSecretCheckModel)` on the presenter,
  its sheet on the host), `theBootstrapWiresTheCheckRoadOnTheOpenSession` (`keyDoorRoads()`'s `check:` — ready only, the open
  session, detached, the sign-in now), and the GUARD `theCheckRoadNamesNoWriterAndNoKeychainRead` (the road's code names no
  writer of any home, never the executor — whose vault read fills `freshVaults` —, never the act lock, a ledger or a defaults
  domain, no custody or sync-keys read — a Touch ID read prompts, VX-503 —, no static state). **RED on the pre-fix tree**
  (the harness, `--filter SecretCheckCompositionTests`): `✘ Test run with 4 tests in 1 suite failed with 5 issues` — each of
  the four ✘ (no section on the pane; no case on the presenter nor the host ×2; no `check:` road; the road's file does not
  exist). The behavioural pins need the new seam to compile — their red is Piece 4's reverts.
- **Piece 2** — the read-only check road, its outcome and words, the door's standing, the road pins: DONE (this commit).
  NEW `Shared/Protection/ProtectionSecretCheck.swift`: `SecretCheckOutcome` (pure — `opens(kind, account:)` with the account's
  half `notSynced · opens · doesNotOpen(changedElsewhere:) · unchecked(why)`; `doesNotOpen(kind, opensAccount:)`;
  `refused(sentence)`; its `lines` and `warns`) and `ProtectionSecretCheck.check(_:typed:signIn:within:)` — the typed text read
  as Look inside reads it (`MakeMineModel.copySecrets`); the open library's in-hand live key file of the open key (else
  `refused(crossingDoorClosed)` — the door is not rendered then); the unlock's own derivation
  (`ProtectionOpenRoad.typedCandidatesAndKeys` — the KDF floor first, one derivation per descriptor) compared with the open key;
  twelve tokens that are not the words and open nothing say the words' own sentence (`ProtectionOpenRoad.sentence(for:)` —
  the count / an unknown word / the checksum); a library naming no account stops there; synced: signed out / another account
  → unchecked in the pane's sentences (no vault read), else ONE vault read THROUGH THE LEAF, bounded (`boundedVaultRead`,
  10 s — B2's P-VX510-B2-1 value; never the executor's `readVault`, which fills `freshVaults`), the master by the typed secret
  (the library check's derived passphrase key reused when its descriptor is the vault's, else derived once under the vault's
  after its floor; the words' wrap key), `AccountVault.master` non-nil → opens; a passphrase that opens the library but not
  the vault, its descriptor no longer the vault's → VX-113's `passphraseChangedElsewhere` (Follow's own test); one protection-
  log line per check, never the secret. No keychain read, no write, no act lock, no stored state. `ProtectionWords.swift`: the
  D-B7 section (the door's label is the design's; every other line **PROVISIONAL P-VX510-B3-1**, below).
  `RoadKeyDoorFaces.swift`: `checkStands` (the live key file of the open key beside it — the read's own `keyFileStands`; a
  hand-made face defaults to false). Pins — new suite `VariorumTests/Protection/SecretCheckRoadTests.swift` (planted road +
  vault + sync keys; `SecretCheckPlant.untouched` = every keychain leaf's items, the memory items, the Apple stamps, the
  container's every byte, the vault's snapshot, the sync keys' items AND session memory, the executor's `freshVaults`, the
  record and key file in hand; `writeLogs` = custody/memory/Apple writes + every non-fetch vault call):
  `rightAndWrongPassphraseAndWordsOnALibraryThatDoesntSync` (right passphrase / right words open; wrong each → the lobby's
  sentences; no vault read), `twelveTokensThatAreNotTheWordsSayTheWordsOwnSentence` (unknown word, broken checksum, another
  count, a passphrase-less library), `syncedTheRightSecretsOpenTheLibraryAndTheAccount` (one fresh fetch per check),
  `theHonestSplitWhenTheAccountsSecretsChangedElsewhere` (the old passphrase → the split + VX-113's sentence; the account's
  new passphrase → the account-not-library arm; the words' split the same, no device named), `theAccountUncheckedSaysWhy
  AndTheLibrarysHalfStands` (offline; signed out and another account with NO fetch; a server slower than the bound — back
  inside 1.5 s, the late answer dropped), `inCastleTheCheckReadsTheSameAndWritesNothing` (Always ask; no custody read, no
  sync-keys Touch ID read), `withNoKeyFileOfTheOpenKeyNothingIsChecked` (rule 27's state: the door not standing, a check
  refusing; the door standing beside the key file) — **every arm asserts zero writes and every home untouched.** **The
  harness, `--filter "SecretCheckRoadTests|RoadKeyDoorRoadTests|RoadKeyDoorsModelTests|ProtectionWordsPlanTests|
  ProtectionWordsVX307Tests|RoadKeyDoorWordsTests|U2WordsTests"`: `✔ Test run with 47 tests in 7 suites passed`**; no warning
  in a touched file. (Machinery: the last pin's first run failed on its own world — a destructured road let go, its temp slot
  deleted under the read; fixed by keeping the road, test-only.) New seam — the pins' red is Piece 4's reverts.
  - **PROVISIONAL P-VX510-B3-1 (the words — hers):** the door "Check my passphrase or twelve words…" (D-B7's own) · title
    "Check my passphrase or twelve words" · lead "Type your passphrase or your twelve words to check them. Checking changes
    nothing." · field "Passphrase or twelve words" · button "Check" · "Checking…" · "Close" · the results in the lobby's idiom:
    "That passphrase opens this library." / "Those twelve words open this library." · "…open(s) this library and your account."
    · "…open(s) this library, but not your account." (+ VX-113's "Your passphrase was changed on ‹device› on ‹day›." when the
    descriptor moved) · the not-opening lines are the lobby's own · the account-unchecked reasons the pane's own.
  - **PROVISIONAL P-VX510-B3-2 (a fourth arm — the architect's/hers):** D-B7 names three answers; on a SYNCED library a secret
    can also open the ACCOUNT but not this library (the account's passphrase or words changed on another device and this
    library's own locks still carry the old pair — rule 7's one pair drifted). (a) the design's three literally — "That
    passphrase doesn't open this library." though it is her account's current one (she might then reset this library's
    passphrase, re-wrapping the account's lock again); **(b, built)** check the vault in that case too and say "That passphrase
    doesn't open this library, but it opens your account." (the not-opening line otherwise). Cost of (b): a vault read (and at
    most one Argon2id) on a wrong secret.
  - **Recorded readings (mine, from the design's words):** the vault is read FRESH at every check (never a snapshot the session
    already holds — a check is about the account's secret NOW); an absent vault reads as unreachable (the pane maps
    `needsFreshVault` to the same sentence); a vault descriptor below the KDF floor opens to no passphrase (no cheap KDF, ever
    — the library side's own reading); twelve tokens that fail the words' validation and open nothing as a passphrase say the
    words' sentence — the reading stays Look inside's ("twelve valid words are the words").
- **Piece 3** — the door and its sheet: DONE (this commit). `Shared/Protection/RoadKeyDoorsModel.swift`:
  `RoadKeyDoorRoads.check` (optional — nil, no door: P-2); `RoadSecretCheckModel` (the sheet's brain — `busy`, `outcome`;
  `submit` untrimmed; `edited()` drops what was said the moment the field changes and a check still running then lands
  nothing — **unit C's W-10 folded in**; `close()` always — a check reads only, so the host's dismissal is Close even
  mid-check; the typed text never held — it lives in the sheet's field); `RoadKeyDoorsModel.offersCheck` (a check road AND
  the read's `checkStands`), `checkSheet`, `openCheck(on:)` (through THE ONE PRESENTER; nothing re-read, nothing said at the
  close). `ProtectionSheetPresenter.swift`: `case checkSecrets(RoadSecretCheckModel)` (its id; its cancel = Close).
  `Shared/AppBootstrap.swift` `keyDoorRoads()`: `check:` — the OPEN session (ready only, else `crossingDoorClosed`), the
  sign-in now, `Task.detached` → `ProtectionSecretCheck.check` (no act lock, no receipt, no landing). Mac (compile at Piece 5's
  build-for-testing, PENDING): NEW `Variorum/Features/Protection/RoadSecretCheckSheet.swift` — `RoadSecretCheckSection` (the
  one door, rendered only where `offersCheck`) and `RoadSecretCheckSheet` (title, lead, ONE `PeekableSecretField` — VX-463's
  concealed field with its eye —, the lines said — the first in the alarm voice when it warns —, Close, Check; `onChange`
  → `edited()`); `ProtectionPane.swift` renders the section AFTER the words section (the set row → the key doors → the words
  section order kept; one presenter host); `RoadAccountSheet.swift`'s host carries the case. `WordsFieldsConcealTests` gains
  the check's field (its label in the words-field list; its site among the concealed fields). Pins: NEW
  `VariorumTests/Protection/SecretCheckModelTests.swift` — suite "the door and sheet": `theDoorStandsOnlyWhereItCanAct` (no
  faces / not standing / no road → no door, nothing presented; standing → the sheet on Settings; one sheet at a time both
  ways), `theSheetChecksWhatWasTypedAndSaysWhatTheCheckSaid` (untrimmed; the lines; Close → gone, no receipt, no landing, no
  re-read), `retypingClearsWhatWasSaidAndALateAnswerLandsNothing` (W-10; a parked check + an edit → dropped; the host's
  dismissal mid-check closes, the late answer dropped), `theSheetKeepsNoSecret` (a `Mirror` walk over the sheet finds nothing
  of the typed text); suite "through AppBootstrap" (`FirstRoundWorld`, no services): `theOpenLibrarysCheckRunsOnTheOpenSession
  AndWritesNothing` (the door stands; words open / a wrong passphrase doesn't; Turn on sync; then the passphrase and the words
  open library AND account; keychain write logs, non-fetch vault calls and the library's calm-asks ledger keys unchanged; the
  executor's `freshVaults` unchanged), `withNoLibraryOpenTheDoorIsGone` (behind the lobby: no faces, no door, nothing
  presented; the road refuses). NEW `VariorumTests/Protection/SecretCheckSurfaceTests.swift` (Mac only, hosted — compiles at
  Piece 5, runs in the stage batch): the section standing and not; the sheet empty and saying each kind of answer. **The
  harness, `--filter "SecretCheck|RoadKeyDoorRoadTests|RoadKeyDoorsModelTests|WordsFieldsConcealTests|
  ProtectionSheetPresenterTests|ProtectionPaneWaveTests"`: `✔ Test run with 43 tests in 9 suites passed`** — Piece 1's four
  composition pins GREEN; no warning in a touched file. (Machinery: the bootstrap pin's first run asserted EXACTLY two fetches
  for two checks and saw more — the set-up's landing re-reads the pane's sections on their own tasks, each a fetch; now `≥`,
  the road suite pinning exactly one per check.)
- **Piece 4** — THE BEHAVIORAL REVERTS, named BEFORE any run (this commit; the committed tree IS the pre-revert copy — no
  copies kept). Each is ONE edit in ONE file (`b3/rv/<name>.old` → `.new`, applied exactly once by `b3/revert.sh`), the
  harness run with `--filter SecretCheck` (the four D-B7 suites: road, composition, model, bootstrap), restored by `git
  checkout --` and `git diff --exit-code` clean after each. Expected red in brackets:
  - **RC-1** (the vault read through the EXECUTOR — it fills `freshVaults`) `ProtectionSecretCheck.swift`: the account's half
    reads by `session.executor.readVault` [`theCheckRoadNamesNoWriterAndNoKeychainRead`; the split pin's untouched cache —
    the changed vault lands in `freshVaults`; any arm whose executor is not signed in as the account].
  - **RC-2** (the words never read as words) `ProtectionSecretCheck.swift`: the reading ignores twelve valid words [every
    right-words arm — unsynced, synced, the split, Castle, through the bootstrap].
  - **RC-3** (the library half never checked) `ProtectionSecretCheck.swift`: `opensLibrary` always true [every wrong-secret
    arm; the account-not-library arm].
  - **RC-4** (the account half never verified) `ProtectionSecretCheck.swift`: any vault read says opens [the split arms; a
    wrong passphrase on a synced library].
  - **RC-5** (VX-113's naming) `ProtectionSecretCheck.swift`: the changed-elsewhere branch never taken [the passphrase split].
  - **RC-6** (the sign-in gate) `ProtectionSecretCheck.swift`: another account signed in still reads the vault [the unchecked
    pin — the other-account leg and its no-fetch count].
  - **RC-7** (the bound) `ProtectionSecretCheck.swift`: the vault read waits 60 s [the unchecked pin's slow-server leg].
  - **RC-8** (the words' own sentence) `ProtectionSecretCheck.swift`: the twelve-token refusal removed [the twelve-tokens pin].
  - **RC-16** (a keychain read — a prompt) `ProtectionSecretCheck.swift`: the account's half first reads the sync keys' Touch
    ID item [`theCheckRoadNamesNoWriterAndNoKeychainRead`; the Castle pin's no-Touch-ID-read leg].
  - **RC-9** (W-10) `RoadKeyDoorsModel.swift`: `edited()` does nothing [`retypingClearsWhatWasSaidAndALateAnswerLandsNothing`].
  - **RC-10** (the late answer) `RoadKeyDoorsModel.swift`: `submit` lands its answer whatever changed meanwhile [the same pin's
    parked leg].
  - **RC-11** (the door's gate) `RoadKeyDoorsModel.swift`: `offersCheck` ignores the read's `checkStands` [`theDoorStandsOnly
    WhereItCanAct`; `withNoLibraryOpenTheDoorIsGone`].
  - **RC-14** (Close mid-check) `RoadKeyDoorsModel.swift`: `close()` refuses while a check runs [the retyping pin's host-
    dismissal leg].
  - **RC-15** (keeps no secret) `RoadKeyDoorsModel.swift`: the sheet keeps the last text it checked [`theSheetKeepsNoSecret`].
  - **RC-12** (the door's standing) `RoadKeyDoorFaces.swift`: `checkStands` always true [`withNoKeyFileOfTheOpenKeyNothingIsChecked`].
  - **RC-13** (the open session only) `AppBootstrap.swift`: the check road drops its ready guard [`withNoLibraryOpenTheDoorIsGone`
    — behind the lobby the retired session still answers; `theBootstrapWiresTheCheckRoadOnTheOpenSession`].
  RESULTS: PENDING (each run's line lands here; "no revert is in flight" written when done).
- **Piece 5** — evidence (the harness whole, the release compile, Mac + iOS build-for-testing) and THE MAC-SUITE LIST: NOT
  STARTED.

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

## UNIT C — THE RECORD (the orchestrator, live; stage claim `vx-510`; every step logged as it happens)

- **Setup (2026-10-23 ~20:30–20:36 MDT):** the walk's Debug build at B2's F-B1-1 commit `4a5ef39e3`, built from the
  DETACHED clean checkout `~/dev/variorum-vx-510-stage` into its `App/Variorum/DerivedData/vx510` (`** BUILD SUCCEEDED
  **`) — never the shared worktree, where B2 is editing. Grants: Accessibility ✔ and Screen Recording ✔ for this
  terminal. Zero Variorum instances. **The dev slot's 9 top-level files aside by `mv`** into the sibling
  `…/Application Support/Variorum-dev-aside-vx510/` — inodes 191598614–191598620, 193537660/193537661, identical
  after the move; `Backups/` and `Previous Libraries/` stay in the slot.
- **S1 (20:37)** — launched `open -n --env VARIORUM_PROD_TEST_ROAD=1 --env VARIORUM_PRODTEST_EMAILS=<the file's list>`
  (pid 57831); `ps eww`: both keys present, NO walk project. **The app's own line: "PROD TEST ROAD (VX-510): ARMED for
  this launch — the dev store may sync with PRODUCTION while one of the 3 listed test account(s) is signed in"** — F-B1-1
  (B) live. A fresh library `6fa0c827` (key `1aad910b`, device `737b3ed0`), Standard, signed out; the band card offers the
  words and the passphrase. OBSERVATION W-1: the fresh store got NO seeded content ("sample library … alreadySeeded" — the
  seeders' marks are this Mac's defaults, not the library's), so the drill's library holds only settings; on a stranger's
  first Mac it seeds as designed.
- **S2 (20:40)** — the Account sheet's Create an account…: the email and the password twice typed by
  `type-prod-test-secret std` (the form's own "At least 12 characters"); Create Account → **"Check your email for a
  confirmation link, then sign in here…"** (the confirmation road, as designed).
*[removed for publication]*
  unconfirmed; `Tools/prod-confirm-test-user.sh` (run from the branch worktree, the gitignored `.env.supabase.local`
  linked from main) → `email_confirmed_at` 02:41:54Z.
- **S4 (20:42)** — Back to sign in → email + password by the helper → **signed in**; the Account sheet: "Hosted sync is
  active on this account."; **the main window's row: "Sync isn't on for this library yet" with Protection… (VX-506's
  not-yet face, LIVE on a real account).**
- **S5 (20:43)** — the band card's look → Copy → `stash-prod-test-words std` ("stashed std's twelve words (12) … clipboard
  cleared") → "I've written them down" → "These words won't be shown again." → Close. **Machinery honesty:** the
  orchestrator looked at a downscaled layout capture to find the Copy button, and the words were still legible in it — so
  this disposable test library's words were seen once by the session; never written anywhere, never typed by hand (the
  helper types them from the stash), the capture deleted at once; LEG S's S13 replaces them anyway.
- **S6 (20:46:18)** — the row's **Protection… opened Settings AT the Protection pane** (VX-486 live); Sync: "This library
  doesn't sync." · Turn on sync… → the SET-UP arm ("Your library's passphrase and twelve words become the account's. Nothing
  is replaced. … Your account starts in Standard, like this library. This library has no passphrase yet. Choose one…") → a
  new passphrase twice + the words, all three by the helper (concealed — VX-463's eye) → Turn on sync → log
  *[removed for publication]*
  RELAUNCH, THE SHEET: "Synced. Your library is on your account now." with Done** (VX-498 + VX-507 LIVE ON PRODUCTION).
- **S7 (20:47)** — **prod reads by the uid:** `key_vault` mode **standard**, created 02:46:19Z (the press), proof hash set;
  *[removed for publication]*
  1** (last_seq 0 — the round's start, the 13j rule); **rows pushed 3** (the three `setting` rows; `sync_write_budget`
  lifetime 3); containers 0 (W-1). Done → **the main window's row: "Synced 8:46 PM"** — no relaunch. OBSERVATION W-2 (chrome,
  cosmetic): at the dev window's sidebar width the row's two buttons truncate to "Sync…" and "Accou…".
- **S8 (20:48:09)** — a note filed through the quick entry ("VX-510 S8 written on the std test account", ⏎) → 12 s later
  **prod: 1 container · 1 block · lifetime 7 rows** — the settle-triggered round pushed it; the row "Synced 8:48 PM".
- **S9 (20:48:53)** — Settings ▸ Data Safety (already "2 copies", the newest 8:46 PM — the set-up act's own backup) ▸ Back
  Up Now… → `backup pair: written under 1aad910b` — **B1** (holds the S8 note).
- **S10 (20:49:49)** — Protection ▸ Change passphrase… (its sheet: "This library syncs with your account, so your
  account's passphrase changes with it, on every device.") → current + new twice by the helper → log `road:
  changePassphrase — the current key re-locked (1aad910b), the account's lock with it` → **prod: the vault revision 1 → 2,
  updated 02:49:51Z.**
- **S11 (20:50:12)** — Back Up Now… → **B2**. The Restore list leads with this library's three rows (8:50 · 8:48 · 8:46 PM)
  carrying Look inside + Make this my library and NO Delete (rule 19 — never the open library's), then the older libraries'.
- **S12 (20:51) — HONEST LIMIT, by design:** Look inside on B1 opened WITHOUT asking any secret — the quiet road (rule 5:
  "or — on this Mac — by its quiet road while it still holds that backup's key"; Standard keeps the silent custody, and
  rule 6's passphrase change never changed the key `1aad910b`). So a TYPED secret against an older backup cannot be
  exercised on a Standard library on its own Mac: that leg moves to LEG C (Castle + Always ask — no quiet road). The facts
  sheet: "This is a copy from October 23…", 0 books, 1 note. **OBSERVATION W-3 (a small bug, ticketed at the close):** Look
  inside dates that note **2026-10-24** — the UTC day — while the app itself titles the same note **2026-10-23** (written
  20:48 MDT).
- **S13 (20:52:55)** — Protection ▸ Record your twelve words… on the SYNCED library: the look says "This library syncs with
  your account, so new words also replace your account's twelve words, on every device. Enter your passphrase to see your
  twelve words." → the current passphrase by the helper → Show my twelve words → (the words located and copied WITHOUT the
  session viewing them: the new buttons found by the accessibility tree's positions after a small scroll) → Copy →
  `stash-prod-test-words std` (the NEW words replace the stash) → I've written them down → "These words won't be shown
  again." → Close. **prod: the vault revision 2 → 3, updated 02:52:56Z — the moment SHOW was pressed.** OBSERVATION W-4
  (feeds VX-511): the look's mint re-wraps the ACCOUNT's words lock when the words are SHOWN, before "I've written them
  down" — so on a joined library the band card's look replaces the account's words even if she closes it unrecorded.
- **S14 (20:56:21) — RESTORE:** Data Safety ▸ B1 (8:48 PM) ▸ Make this my library… — the confirm: "This copy becomes a new
  library — in Standard, under your current twelve words and passphrase — with a fresh key of its own. Your current
  library steps aside whole into Previous Libraries… The new library doesn't sync with your account until you turn on sync
  for it in Settings ▸ Protection." → the current words + passphrase by the helper → log `road: made a copy this Mac's
  library — library dfe2ad68 key 2e677513; the previous one in Previous Libraries; held` → opened, device `ae835950`. The
  words card did NOT return (VX-444's ledger carry, live). The hold banner: "This is your library as of October 23, 2026.
  Sync is waiting until you press Resume. To keep something from this backup, duplicate it first — duplicates stay." →
  Resume Sync → the banner goes and the row reads **"Sync isn't on for this library yet"** (honest: the copy names no
  account). **OBSERVATION W-5 (wording, ticketed at the close):** on a restored library that names NO account the hold
  banner still promises "Sync is waiting until you press Resume … duplicates stay" — no sync follows the press; the
  confirm's own sentence ("doesn't sync … until you turn on sync") is the true one.
- **S15 (20:58:14) — A JOIN from the restored library:** Protection ▸ Sync: "This library doesn't sync." · **"Sync this
  library…"** (VX-506's join-arm door, LIVE) → the join sheet (its title still "Turn on sync" — P-VX510-A4): "Your account
  already syncs. Type its passphrase or its twelve words once…" → the account's passphrase by the helper → `enroll: begun #6
  *[removed for publication]*
  system Touch ID prompt** (VX-503 did not reproduce on this Mac's Standard join) → the words notice (passphrase typed):
  *[removed for publication]*
  made before today…" → OK → **the sheet: "Synced. Your account's writing is in this library now."** — no relaunch.
  **prod: device cursors 2 · live containers 1 (no duplicate — the copy's rows merged by id) · live blocks 1 · rows 8 ·
  vault revision 3 (a same-posture join changes no account lock).** OBSERVATION W-6 (ticketed at the close): the words
  notice SPOKE although the restored library's words already were the account's (the copy was made under the current pair
  — VX-456/VX-462's quiet arm missed for a restored copy, probably because the fresh key's lock is compared rather than
  the words), so "your previous twelve words" is untrue here.
*[removed for publication]*
  passphrase). The walk instance quit (its round sheet's Done first — a sheet up held ⌘Q); the walk library `dfe2ad68`'s 5
  slot files aside into `Variorum-dev-aside-vx510-walkL1/`; relaunched on the road (pid 65130, the road ARMED) → a fresh
  library **`413fb3bd`** (key `725fafc4`, device `7d96b569`), still signed in as std (the dev scope's session) → **the row:
  "Sync isn't on for this library yet" with Protection…** — the exact moment both testers met "Sync locked" on 0.10 →
  Protection ▸ "Sync this library…" → the account's passphrase by the helper → `enroll: done #1 under 725fafc4 · road:
  *[removed for publication]*
  the fresh library's words were replaced) → OK → **"Synced. Your account's writing is in this library now."** — NO
  relaunch → Done → **the Library shows "VX-510 S8 written on the std test account · edited today 8:48 PM" — the first
  library's note, downloaded into the fresh one**; the row "Synced 9:01 PM". **prod: device cursors 3 · live containers
  1.** **VX-511 LIVE RED on this pre-fix build (B2 builds the fix):** after the join the Bookcase's band card still reads
  "Your library is encrypted — click here to record the twelve words that are its key." — her Air report, exactly (its
  passphrase half retired, the library now holding the account's passphrase). The re-walk on B2's build owes its green.
- **LEG S: PASS** — every first-run leg live on production with no relaunch: sign-up, set-up, the first round, a note's
  push, a restore, a join from a restored copy, a join from a fresh library (the testers' road); the key doors (Change
  passphrase, New words) re-lock the account (vault revisions 1→2→3); three device cursors; zero duplicates. Deferred to LEG
  C by design: a typed secret against an older backup (Standard's quiet road answers first on its own Mac).
- **LEG D (21:03–21:10) — ACCOUNT DELETION:** quit; the joined library `413fb3bd`'s files aside (`…-aside-vx510-walkL2/`);
  relaunched (pid 66160, the road ARMED) → a fresh library **`2aa0214f`** (key `895bf4eb`, device `dd81f8f0`); Settings ▸
  Protection ▸ Sign out… ("Sign out of this Mac? This Mac stays signed out of sync until you sign in again…") → Sign Out →
  "Sign in to turn on sync." · Sign in… → the Account sheet over Settings → Create an account… → `del`'s email + password
  *[removed for publication]*
  (03:06:42Z) → signed in as del → the words look blind (Copy + stash, the helper's twelve-word check) → I've written them
  down → Close → Protection ▸ **"Turn on sync…"** (the SET-UP arm — distinct from the join's "Sync this library…", correct
  for an account with no vault) → del's passphrase twice + words → `road: turnOnSync — library 2aa0214f now names account
  *[removed for publication]*
  before: vault 1 · `kp:` 1 · cursor 1 · settings 3 · budget 1 · auth user 1. → the main window's Account… → Delete
  Account… — the form: "Your account, its sync copy on our server, and its keys are deleted. Nothing on this Mac or your
  other devices is touched…", the password + "DELETE MY ACCOUNT" → Delete Account (21:10:00) → log `road: deleteAccountHere
  — library 2aa0214f now names no account … the account was deleted — this library no longer names it (rule 16's local
  leave)` → signed out, the Account sheet back at sign-in. **prod after: auth user 0 · vault 0 · `kp:` 0 · cursors 0 ·
  settings 0 · budget 0 · entitlement 0 — the account and every row of it GONE.** **LEG D: PASS.** OBSERVATION W-7 (wording/
  logic, ticketed at the close): the deletion form tells this FREE test account "This account has an active hosted-sync plan
  — cancel it first." (the entitlement read answers "active" for an open-sync account with no purchase), so every free
  user is told to cancel a plan they never bought.
- **LEG C setup (21:11–21:12):** the walk build REBUILT at B2's tip **`e829e8d08`** (VX-501 + VX-511 + VX-503 in; from the
  detached checkout; `** BUILD SUCCEEDED **`); the stage renewed (240 min); the deleted account's library `2aa0214f` aside
  (`…-aside-vx510-walkL3/`); relaunched (pid 71389, the road ARMED) → a fresh library **`159caa3f`** (key `a2c73b2c`,
  device `3a62193d`), signed out.
*[removed for publication]*
  → the PAT script confirms (03:13:06Z) → signed in → the words look blind (Copy + stash, twelve-word check) → Protection ▸
  **Use Castle…** — its sheet ("Castle is one promise: no quiet road through Apple, ever, on any device of the account… The
  libraries in Previous Libraries keep their own quiet roads on this Mac — Castle protects the library you have open…") on
  a library with NO passphrase asks one ("This library has no passphrase yet. Choose one — Castle needs it.") + the words;
  **Always ask** chosen ("No copy of the key stays on this Mac; you type every time.") → `enter_castle: swapped … retired 1
  own Apple key(s) … done #2 under 5638db0a · road: useCastle — library 159caa3f now castle` (21:15:20) → Turn on sync… →
  the set-up arm IN CASTLE ("Your account starts in Castle, like this library.") → passphrase + words → `road: turnOnSync —
  *[removed for publication]*
  account now."** — the THIRD fresh account, the Castle posture, no relaunch. **prod: vault mode castle, revision 1 · `kp:`
  1 · cursor 1 · rows 3.** The row "Synced 9:16 PM".
- **C2 (21:17–21:18) — VX-501 LIVE: a TYPED Castle unlock keeps syncing.** A note filed ("VX-510 C2 castle note before the
  lock") → prod 1 container. **⌃⌘L** → `road: locked — the library closed behind the lobby (VX-445)` → the lobby: "Open
  your library — Enter your passphrase or your twelve words to open your library. Touch ID isn't set up for this library."
  → the passphrase TYPED (the helper) → Open → `road: opened — library 159caa3f …` (21:17:49) → **`road: the typed unlock
  loaded the account's sync keys for the session (sync key e1deb44d)`** → a second note filed ("…after the typed unlock") →
  **prod: 2 containers · rows 12** — a round with the account's keys ran after a typed unlock, with NO key act — and the row
  **"Synced 9:18 PM"**. Before VX-501 this posture stayed "Sync locked" until a key door (her M1 (c) report).
- **C3 (21:19–21:28) — the key changes and the backup floor IN CASTLE (no quiet road; every look typed).** Back Up Now →
  B1c `backup pair: written under 5638db0a` (21:19:15). **Change passphrase** (the sheet: "This library syncs with your
  account, so your account's passphrase changes with it, on every device.") → `road: changePassphrase — the current key
  re-locked (5638db0a), the account's lock with it` → prod vault **rev 2**. Back Up Now → B2c (21:20:13). **Record your
  twelve words** in Castle asks the passphrase INLINE ("This library syncs with your account, so new words also replace your
  account's twelve words, on every device. Enter your passphrase to see your twelve words.") → the changed passphrase typed →
  `regenerate_words: done #5 … rule 2's look — fresh words lock the key file; the key unchanged` → prod vault **rev 3**, mode
  castle. The words copied + stashed BLIND — the button row found by AX positions and a 36-pt strip capture, the words
  never captured ("Copy · I've written them down", then "Copied… · These words won't be shown again. · Go back · Close").
  Data Safety lists SIX rows (9:12 ×2 pre-Castle under `a2c73b2c`, 9:15, 9:16, 9:19, 9:20 — the folder holds 5 pairs:
  `031225-a2c73b2c`, `031519`, `031625`, `031915`, `032013`) while its header says "5 copies" → **W-8**. The looks:
  - the 9:19 copy (B1c, before BOTH key changes) → "This copy doesn't open by itself on this Mac. Enter its passphrase or
    twelve words." → **a wrong secret (std's passphrase) refuses**: "That doesn't open this copy. Enter the copy's own
    passphrase or twelve words." → **its own (original) passphrase opens it**: `road itsOwnSecrets — read-only, nothing
    written` (both notes listed) → **the CURRENT passphrase opens it**: `road currentSecretsThroughTheHistory` → **the
    CURRENT words open it**: same road.
  - a 9:12 copy — made BEFORE the library had a passphrase and BEFORE Castle, under the old key `a2c73b2c` whose Apple item
    the crossing retired → doesn't open by itself either (rule: the crossing Castle-protects the backups) → **the CURRENT
    passphrase opens it** through the history (empty, as it was at 9:12).
  The S12 gap (Standard's looks went the quiet road) is CLOSED here: every typed-secret arm met live.
  Observations: **W-3 again** (the look lists notes dated 2026-10-24 — UTC — where the app says 2026-10-23); **W-9** the look
  names the notes "Untitled" where the app titles them "2026-10-23"; **W-10** the error line from a failed try stays on
  screen after the field is retyped (the sheet grows and its Open button moves under the pointer).
- **B2's T-B5-2 → VX-517 (filed 2026-10-23, Needs Lillian):** the sync-keys leaf's Touch ID candidates are unwired
  (`AppBootstrap.swift:183`, the default `{ [] }`; the custody leaf's are wired at `ProtectionSystem.swift:60` — verified by
  the orchestrator), so the Touch ID class is never forgotten (rule 16). Join-or-separate is hers.
- **C4 (21:30–21:36) — a SECOND library joins the Castle account (the re-keying join, F-6) + VX-511 LIVE.** Quit (zero
  instances); `159caa3f` aside (`…-aside-vx510-walkL4/`); relaunch (pid 78401) → a fresh Standard library **`223c4e7e`**
  (key `7cde213b`), still signed in as `castle` (the dev-scoped session), the words card AND the passphrase card showing.
  Protection ▸ **"Sync this library…"** (VX-506's door — the account has a vault) → the sheet ("Your account already syncs.
  Type its passphrase or its twelve words once — your library's own passphrase and twelve words are replaced by your
  account's. … Your account is in Castle, so this library goes into Castle too." + the Castle promise text + On this Mac)
  → **Always ask** + the account's CURRENT passphrase → `enroll: done #1 under 508a5859 · road: turnOnSync — library
  *[removed for publication]*
  *[removed for publication]*
  twelve words. Your previous twelve words still open backups you made before today. …") → OK → **`road: an account act
  landed — the library holds the account's words; the words card's offer retires (VX-511)`** → the F-6 sheet waited for the
  reopened services and said **"Synced. Your account's writing is in this library now."** → prod **2 cursors**; the Library
  shows both Castle notes; the row "Synced 9:32 PM"; **the Bookcase's cards band EMPTY** (the words card and the passphrase
  card both retired — VX-511 GREEN live; red live on the pre-fix build at S-leg). **Relaunch** (pid 78965) → the Castle
  lobby → the TWELVE WORDS typed → `road: the typed unlock loaded the account's sync keys for the session (sync key
  e1deb44d)` (VX-501's words arm) → the band STILL EMPTY (the mark persisted) → a note from this second library → **prod 3
  containers, rows 16**, the row "Synced 9:35 PM".
- **C5 (21:37–21:38) — Use Standard (the account leaves Castle).** Protection ▸ **Use Standard…** (the sheet: "Leaving Castle
  hands everything to Standard: your library gets a new key, with a fresh Apple road and this Mac's on-device road back.
  Your library and all your backups will open through your Apple account and this Mac again; if you want Castle-era writing
  to stay Castle-protected, don't leave." — passphrase AND words asked) → `leave_castle: swapped — the library is under
  79e33327 … road: useStandard — library 223c4e7e now standard under 79e33327` → **prod vault mode standard, revision 4** →
  a note after the change → **prod 4 containers**, the row "Synced 9:38 PM". ("Replace All Keys…" seen, not exercised.)
- **LEG C PASS.** Observations: **W-11** the join door reads "Sync this library…" while its sheet's title and button still
  say "Turn on sync"; **W-12** the words notice's "backups you made before today" — backups made EARLIER TODAY, before the
  join, open with the previous words too (it means "before now"); **W-13 (Suspected, her hand)** the lobby's "Use your twelve
  words instead" disclosure did not open on three synthetic clicks across its label (AX geometry 487,547 240×14; the clicks
  inside it), while an AXPress opened it at once — real-mouse behavior unverified.
- **Held for B3's walk (the orchestrator's call):** the stage, the walk build and library `223c4e7e` (synced to `castle`,
  Standard) stay up so VX-513's check door can be walked on its synced arm the moment B3 lands; unit C's close follows that.

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
- **Unit A's word items (PROVISIONAL, hers — the record's Piece 3/4):** **P-VX510-A1** the held line reads "…press
  Resume Sync in the main window's banner" (the row's "in the banner below" is wrong from a sheet over Settings) ·
  **P-VX510-A2** a round that ran but stalled at a straggler still reads "Sync hasn't run yet: …" — a third lead? ·
  **P-VX510-A3** not configured reads the row's "Sync is off" (on a fenced dev store the row says "Sync off (dev
  store)" — a Debug-only mismatch, accepted) · **P-VX510-A4** the join's sheet TITLE and button still say "Turn on
  sync" (the design changed the door only) · the not-yet row wears the quiet caption style, not the warning style.
