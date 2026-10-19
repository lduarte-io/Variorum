# VX-308 — Castle rebuild, phase 4: accounts and the key doors

**Status: PLANNED — written 2026-10-19 at VX-307's settling sitting (her rulings of that sitting are QUESTIONS #235's
HER RULINGS block and this plan's §1). Kicks off at her word with `/architect-phase vx-308` in a fresh session; holds
the one Sync/-or-custody slot.** The VX-308 TICKET'S BODY and its comment carry the hand-forwards; the core acts and
the WIRE are BUILT (VX-378 + VX-307 U1) — this phase is their FACES, the key doors, and the riders.

> **KICKOFF MESSAGE (paste-ready).** STEP 0: the bout ritual (pull both repos, `Tools/vx sync`), then from
> `~/dev/variorum` on `main`: `git worktree add -b vx-308-accounts-key-doors ~/dev/variorum-vx-308 origin/main`; push
> the branch; the in-flight row (HOLDS the Sync/-custody slot); Linear VX-308 → In Progress; announce to the stage
> coordinator. **Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`;
> `notes/CastleRules.md` (rules 7, 10, 12, 14–16 are this phase's heart); `notes/SyncSpec.md` WHOLE; the lifecycle
> page stages 10 and 12; `notes/plans/vx-307-castle-crossings.md` §6 (the U1 RECORD — how the wire is consumed — the
> U2a/U2b records, the arbitrations, THE WALK RECORD's machinery notes) and §5a's hard limits (they bind here
> verbatim); `notes/SurfaceContracts.md`'s protection section; the VX-308 ticket's comment (the hand-forwards); the
> core's `Acts/AccountActs.swift`, `Acts/Follow.swift`, `Acts/KeyDoors.swift`, `Assess/Assessment.swift`,
> `Protection/Wire/AccountVaultClient.swift`, `App/Variorum/Shared/Protection/` (the faces' homes).
>
> **The one law:** the new road stays DEBUG-ONLY; `SyncSchema.lockstepVersion` STAYS 13; the mirror artifact
> `17_phase_vx307_vault.sql` stays HELD (her ruling — the deploy + marker 14 ride VX-329's release). **THE WALK FACT
> the kickoff call needs:** the LIVE mirror still speaks marker 13 WITHOUT the new vault columns, and the new client
> refuses a mode-less row (`preLockstepRow`) BY DESIGN — so a live throwaway-account walk CANNOT run against the
> production mirror. Her kickoff call is therefore: (a) the account arms stand on the two-client fake-server suites
> alone (the VX-307 precedent), or (b) a SEPARATE throwaway Supabase project with the held artifact applied THERE
> (her accounts and hands; the production mirror untouched). **THE ORCHESTRATOR'S RECOMMENDATION, HER STANDING
> ACCEPTANCE AT THE VX-307 SETTLING SITTING PENDING HER KICKOFF WORD: (b), framed as the ARTIFACT'S DRESS REHEARSAL
> first and the walk second** — three consecutive lockstep deploys (13j's 42702 parameter shadow, 13y's run-1 grant
> refusal, 13i-a's missing definer DML grant) had LIVE-ONLY PL/pgSQL and grant findings the fake server cannot reach,
> and artifact 17 has never run on real Postgres; a throwaway project catches that class now, cheaply, instead of at
> VX-329's release window with her live client waiting. **The overnight-safe convention:** the kickoff session checks
> `~/.variorum/dev-vault-throwaway.env` (expected keys: `VARIORUM_THROWAWAY_PROJECT_URL`,
> `VARIORUM_THROWAWAY_ANON_KEY`, `VARIORUM_THROWAWAY_PAT`; values never committed or echoed — the dev-castle.env
> discipline, and note the file's lines need `export` or the session exports explicitly). File PRESENT → run the
> rehearsal (the artifact applied to the throwaway, every checklist row exercised, findings amended into the artifact)
> and the account-arm walk against it, Debug-only, the vault client alone pointed there (the row-sync engine stays
> off; the dev store's restore hold stands). File ABSENT → fake-server-only (option a), and the rehearsal lands as a
> bundled morning item with the five-minute setup note. Either way the phase closes; the rehearsal is additive
> evidence, never a gate she has to be awake for. Hard limits otherwise as §5a's: no not-pursued items,
> both secrets where the rules say, keychain tests under throwaway scopes, headless + build-for-testing for
> implementers, the orchestrator runs Mac suites and walks under the stage.

## 1. Her rulings standing at this plan's writing (2026-10-19)
- **VX-445 joins this phase** (the lock on the new road — Castle's idle lock and Lock Now; NIT-R2-1's by-library
  export-notice mark rides it).
- **VX-447 and VX-448 are riders** (the no-key-file banner becomes the door + the act proceeds on a file-less
  library; the clipboard's concealed-type + clear-at-lock/quit — the timer and the restore go).
- The guide chapters are NOT this phase's (VX-309's, her ruling); the walk question is HERS at kickoff (above).

## 2. The members (the ledger; the kickoff session cuts the units)
| Ticket | What closes it here |
|---|---|
| **VX-418** | THE ACCOUNT FACES: sync setup hands the pair up; the join ("your library's twelve words are now your account's twelve words; here they are; the old ones still open backups you made before today" — the "here they are" edge P-VX378-U2-3 is hers to eye); the follow in/out of Castle (the quiet out-notice's face, the replaced-key catch-up); leave the account (rule 16's three doors). The core acts + wire are built; faces only. |
| **VX-107** | The follow's facts survive the double-crash (core built); the Done's other-device sentence on the new face |
| **VX-113** | The face says *Your passphrase was changed on [device] on [day]* (core refusal `passphraseChangedElsewhere` built) |
| **VX-239 / VX-243** | ONE presenter for the protection sheets; an in-flight act's sheet never re-presents after unlock |
| **VX-264** | Her #216 rulings: the signed-out screens, the leaving/joining words |
| **VX-314** | New writing belongs to the library's account, not whoever is signed in |
| **The key doors** | Change Passphrase / New Words / the forgot road on the new road; library and account locks change together (rule 7); VX-263's sentences → one line each: *your current secrets open everything you've made of this library* |
| **VX-445** | The new road's relock: idle lock + Lock Now through the road session; NIT-R2-1's mark-by-library rides |
| **VX-447 · VX-448** | The riders (her rulings above) |
| Hand-forwards | F-4 (the restore hold's gate on synced crossings); the F-U2c-5 synced-banner variant folds into VX-447 |

## 4. THE KICKOFF RECORD (2026-10-19, the orchestrator — session `vx-308`)

**Her kickoff words (the mandate):** run under `/architect-phase` overnight — *"run it overnight under my mandate —
PROVISIONAL-and-continue, bundle everything for my morning read"*; *"work with the 1018coordinator for the stage"*;
*"my settling-sitting rulings stand (VX-445 joins, VX-447/VX-448 ride)"*; the walk call — *"if
~/.variorum/dev-vault-throwaway.env exists, take option (b) — rehearse artifact 17 on the throwaway project and walk
the account arms against it; if not, fake-server-only and bundle the rehearsal setup as a morning item"*; *"standing
cast unless I say otherwise."*

**THE WALK CALL RESOLVED: OPTION (B).** Before the round, at her sitting ("we can work together"), the throwaway
project was provisioned live: her stored Supabase PAT proved project-scoped (it could query the live project but not
read the org or create projects — two tokens tried, both 403 on create), so SHE created
**`variorum-vault-throwaway`** by hand in the dashboard (us-east-2; Data API on, auto-expose on, automatic RLS on —
each matched to the LIVE project's read baseline, not the dashboard's advice: the live mirror carries the platform's
`ensure_rls` event trigger and the auto-expose default ACLs, so the throwaway must too or the rehearsal would raise
false grant findings), then minted a PAT scoped to ONLY the throwaway. `~/.variorum/dev-vault-throwaway.env` is
written to the plan's convention (the three keys, `export`-prefixed, 0600) — so the overnight run CANNOT reach the
production mirror or any other project by construction. Fidelity checks run read-only against both projects: event
triggers identical (`ensure_rls` included), public default ACLs byte-identical, PostgREST config same shape; Postgres
17.11 (throwaway) vs 17.6 (live) — same major, noted. Keep-or-delete on the project is HER morning item (it bills
compute by the hour; cents until morning).

**The coordinator (1018coordinator):** the one Sync/-custody slot granted 03:18 MDT; the REQUEST/READY/GO/RELEASE
stage protocol + the eight walk terms accepted; its one guard adopted — every Management-API apply to the throwaway
asserts in-command that the target ref is the throwaway's and aborts otherwise, and the PAT never echoes. The
Management-API applies need no stage (no screen, no shared store — the coordinator's word).

**Dev-store facts at kickoff (the coordinator's):** library 86a82b4f, Standard on the new road, dev passphrase set,
unlocked, quiet open; the restore-hold marker + Resume Sync banner STAND (never press Resume); newest safety copy
`Backups/safety-copies/variorum-vx307-fixleg-2026-10-19T071917Z`; three keychain items from VX-307's throwaway
library B remain, named for her.

## 5. THE UNITS AND THE ORDER (the kickoff session's cut; sizing said per the guidance)

**Sizing statement (PhaseSizingGuidance):** two phase-sized units under the one theme — (1) THE ACCOUNT FACES
(VX-418 + VX-107 + VX-113 + VX-264 + VX-239/243, split across two implementer sessions, one acceptance unit each),
(2) THE KEY DOORS' FACES (+ VX-447's core arm). VX-445 + F-4, and VX-448, are bounded rider rows; VX-314 is a traced
one-seam fix (the orchestrator scopes it first — custody/Sync-adjacent, so Fable's by the standing cast). Within
guidance; nothing to raise.

**The order (strictly sequential, one agent at a time):**
0. The plan record (this commit) → **the artifact-17 dress rehearsal** (the orchestrator, network-only, §5R) — early,
   so findings reach her morning bundle and the throwaway is ready for the walk.
1. **U1 (Opus)** — the account section's faces: the one presenter, the doors from `assess`, sync setup, the leaves,
   the signed-out screens (VX-418's trunk + VX-264 + VX-239/243), + the DEBUG walk override (§5a piece 0).
2. **U2 (Opus)** — the join and the follow faces: the join's words moment, the follow in/into/out, the catch-up,
   VX-107, VX-113.
3. **U3 (Opus)** — the key doors' faces + VX-447 (the file-less-library arm + the banner-becomes-the-door) + VX-448
   (the clipboard rule).
4. **U4 (Opus)** — VX-445 (the lock on the new road + NIT-R2-1's by-library mark) + F-4 (the restore hold's gate on
   the synced crossings).
5. **VX-314** — the orchestrator traces the stamping seam and fixes it inline at a clean tree seam (no implementer
   holds the tree), red-on-old pin; if the trace shows more than a one-seam fix, it is re-cut as its own unit and said
   in the morning bundle.
6. **The ladder** — ONE ladder over the phase's whole diff, fresh `fable-reviewer` (custody), the cross-model flow.
7. **THE WALK** (the orchestrator, stage claim): the rehearsal's checklist rows already done at §5R; the
   account-sequence walk — signed in, out, into another account, back — on the Debug app against the throwaway
   (the vault client + auth pointed there per-launch; the row-sync engine stays OFF; the dev store's restore hold
   stands; posture restored at the end per the walk terms).
8. Closeout (serialize with the coordinator; shared ledgers at the merge on main; the handoff + morning bundle LAST).

Every batch brief binds: VX-307 §5a's hard limits VERBATIM (today's road byte-unchanged; Debug-only behind
`ProtectionRoad.newRoadIsLive`; `SyncSchema.lockstepVersion` STAYS 13; artifact 17 stays HELD; keychain tests under
throwaway scopes; headless + `build-for-testing` only — the Mac suites are the orchestrator's under the stage; no
subagents; checkpoint commits per piece with `Part of VX-NNN`), the resiliency protocol, and the no-shouty-caps and
two-voices copy rules. Nothing from CastleRules' considered-and-not-pursued list. The undrafted words ship PROVISIONAL
in `ProtectionWords`' VX-308 section, hers at the bundle (the P-VX307-U2a-1 shape).

## 5R. THE REHEARSAL RUNBOOK (the orchestrator's own — artifact 17's dress rehearsal on the throwaway)

**Why (her standing acceptance):** three consecutive lockstep deploys had live-only PL/pgSQL and grant findings the
fake server cannot reach; artifact 17 has never run on real Postgres. The rehearsal applies the chain to the empty
throwaway, then 17 as the rehearsed event, exercising the HELD checklist's verify rows; findings amend the artifact
IN REPO (the 13j read-fix-re-run road, rehearsed instead of live).

**The guard (the coordinator's term):** every apply asserts the target ref is the throwaway's inside the command and
aborts otherwise; the PAT and keys never echo and never land in any record or commit.

**The chain (fresh mirror, historical order — the role's birth decides the two maintenance insertions):**
`01_mirror_schema` → `02_sync_rpc` → `03_visibility_horizon` → `04_auth_rls` → `05`–`09` → `maintenance/
14c-gate-definer-owner` (births `variorum_definer`; 10 needs it) → `maintenance/14c-gate-grant-tidy` → `10`–`16`
(10 already carries the renamed pull parameter in repo, so the 13j window script is not re-run) → `maintenance/
pre13x-window-vault-delete-revoke` → `maintenance/pre13x-ladder-rotation-clearing-guard` → `maintenance/
beta-signup-auto-entitle` → the grant sweep (`maintenance/14c-post-deploy-grant-sweep`) expecting the 13n-b shape
(63 OK · 4 INFO · 0 fail) as the fidelity verdict. Any ordering surprise is a FINDING (recorded; the fresh-mirror
runbook is a deliverable for 18b-class work). THEN the rehearsal proper: plant two pre-VX307-shaped `key_vault` rows
(one Standard-shaped — the Apple-held wrap present; one Castle-shaped) for two throwaway auth users so the mode
backfill runs on real rows; `sync_schema_version()` = 13; apply `17_phase_vx307_vault.sql` VERBATIM; expect `[]`;
run its verify tail (marker 14, the four queries, both backfilled modes right); the grant sweep again (the artifact's
promised counts). Every finding → the artifact amended in repo + a checklist row annotation (the checklist itself
stays HELD and PENDING-until-live — the rehearsal never flips it; a REHEARSED note per row is added instead). The
account-arm walk (§5 row 7) then runs against the marker-14 throwaway.

## 5a. U1 BRIEF — THE ACCOUNT SECTION'S FACES (an Opus implementer; ticket VX-418's trunk + VX-264 + VX-239/VX-243)

**Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` (rules 7,
10, 12, 14–16 the heart); `notes/SurfaceContracts.md` "Doors to the outside" (Library protection) + "The app";
`notes/plans/vx-307-castle-crossings.md` §5a (the hard limits — they bind HERE verbatim), §6 U2a RECORD ("THE FACES AS
BUILT" — the pattern this unit extends) and §6 U1 RECORD (the wire the arms consume); the core's
`Protection/Assess/Assessment.swift` (the account doors + `AccountSituation`), `Executor/Acts/AccountActs.swift`;
`App/Variorum/Shared/Protection/` — `RoadCrossingsModel.swift`, `RoadCrossingFaces.swift`,
`ProtectionCrossingActs.swift`, `ProtectionWords.swift`; `App/Variorum/Variorum/Features/Protection/
RoadCrossingSheet.swift`; QUESTIONS #216 (the shipped signed-out copy this unit carries onto the new road — her
rulings on it are STILL PENDING, so everything stays provisional and byte-reuses the shipped sentences where they
fit). Work from `~/dev/variorum-vx-308`; commits say `Part of VX-418` (or VX-264/VX-239/VX-243 where a piece is
theirs).

**The goal.** Settings ▸ Protection on the new road gains THE ACCOUNT SECTION — the account's situation and doors
read from `assess` exactly as the crossings' section reads its three (a door that cannot act is not rendered — P-2):
`turnOnSync` (both secrets typed, the words typed never made new — rule 7's hand-up; a new passphrase typed twice
where none exists, the crossings' precedent), the three leaves (`thisMacOnly` / `stopSyncingHere` /
`deleteAccountHere` — rule 16: no key, lock or secret changes; the face still confirms, P-VX378-U1-2),
`moveToSignedInAccount` + `signOut`, and the SIGNED-OUT screens (VX-264 — `AccountSituation.signedOut` /
`.otherAccount`: the #216 shipped copy carried onto the new road, provisional). The gate: every door through ONE
PRESENTER (VX-239 + VX-243): one protection-sheet presenter per window scene, owned beside the bootstrap's
`RoadCrossingsModel` so an in-flight act's sheet never re-presents after unlock and never on two windows at once —
the crossings' confirm moves onto it too (one home, zero behavior change to its contents). Today's road is UNTOUCHED
(its two bugs close by the road's retirement at VX-329; say so in the record).

**Piece 0 (the walk's door):** a DEBUG-only per-launch override of the project coordinates —
`ProjectConfig.variorumProjectURL`/`variorumPublishableKey` read `VARIORUM_WALK_PROJECT_URL` /
`VARIORUM_WALK_ANON_KEY` from the environment in DEBUG only (the `ProtectionWalkSwitch` fences' idiom: DEBUG, logged
once, per-launch); Release byte-unchanged. One pin (the override reads only in DEBUG and only when both are set).

**Hard limits:** VX-307 §5a's verbatim (today's road byte-unchanged; everything behind `roadStanding`/`newRoad`;
`lockstepVersion` stays 13; NO live network call in any test — the planted road + the U1 fakes; keychain tests under
throwaway scopes; headless `swift build`/`swift test` + `xcodebuild build-for-testing` ONLY; no stage, no Debug
launch, no dev-store touch; no subagents; checkpoint commits per piece, push each, LIVE STATUS flips in the same
commit, PENDING on every unverified claim; foreground waits only). The words: `ProtectionWords` gains the VX-308
account section — rule 16's and rule 7's sentences from `notes/CastleRules.md` BYTE-EQUAL and pinned; the rest
PROVISIONAL (one bundle row). No shouting caps; sentence case.

**Evidence closing the unit:** the new faces' suites green HEADLESS in the session harness (the U2a recipe — the
scratch SwiftPM package symlinking `Shared/Protection`) AND the core protection set green both configurations;
`build-for-testing` green; the phone builds; the Release build check green; the record (§6, the VX-306 §9 form) with
counts, the Mac-suite list for the orchestrator, mutations restored `cmp`-identical, PROVISIONALs bundled, findings
routed. The Mac batch and the walk are the orchestrator's.

## 5b. U2 BRIEF — THE JOIN AND THE FOLLOW FACES (a fresh Opus implementer; VX-418's second half + VX-107 + VX-113)

**Read first, in full:** the §5a list PLUS `Executor/Acts/Follow.swift`, `Executor/Acts/CommonSteps.swift` (the
join/pickup context), the U1 RECORD's piece 4 (the sync-key provider the follow rides), `notes/plans/vx-266/
castle-lifecycle.html` stage 12 (the page's words for the join and the account-wide follow), and U1's §6 record (the
presenter + section as built — this unit EXTENDS them, never a sibling). Commits say `Part of VX-418` (VX-107/VX-113
where theirs).

**The goal.** (1) THE JOIN (enroll / move): the door reads `assess`'s join plan (`entersCastle` / `leavesCastle` /
`sameMode` — the consent says which, rule 5's sentence on the leave), ONE of the account's secrets typed (rule 14),
and the WORDS MOMENT — rule 7's sentence (*your library's twelve words are now your account's twelve words; here they
are; the old ones still open backups you made before today*): the words SHOWN when typed there, and when the
passphrase was the typed secret the notice says they were replaced WITHOUT showing them (P-VX378-U2-3 (a) stands —
"the face shows them when typed"; the model reports `wordsReplacedByAccount`; her eye flagged in the bundle — the
ledger's "here they are" edge). The shown words ride the ONE look idiom (`WordsLookPanel`'s privacy posture — never
selectable, never stored, no new clipboard road; VX-448's rule arrives in U3 and must not be pre-built here). (2) THE
FOLLOW: `OwedAct.follow(kind, typesOneSecret:)` gets its face — the one-secret ask (into Castle: the gate choice,
`Follow.swift`'s own default), the QUIET follow out with its notice (rule 12's sentence), the catch-up on a replaced
key; surfaced where the owed act is read (the interlude/pane per U2a's idiom — the implementer proposes placement in
the record if the plan's idiom does not fit, the architect rules). (3) **VX-107:** the follow's Done keeps its
other-device sentence across the double-crash resume (the core's facts survive — the FACE must re-say it from the
outcome/notices, not from transient state; pin it on the planted road). (4) **VX-113:** the follow's refusal face for
`passphraseChangedElsewhere(device:day:)` says *Your passphrase was changed on [device] on [day]* (her #205 ruling
(ii); the day via the wire's `updatedAt` day — `AccountVaultClient.day`). Hard limits, words rule, and evidence:
§5a's verbatim (the fakes carry every vault shape needed — `ExecutorVault`/`ServerFake`/`FakeVaultHTTPServer`; no
live call in tests).

## 5c. U3 BRIEF — THE KEY DOORS' FACES + VX-447 + VX-448 (a fresh Opus implementer)

**Read first, in full:** the §5a list PLUS `Executor/Acts/KeyDoors.swift` (the three doors as built — the synced
vault half runs INSIDE the acts; rule 7's together-change is core truth, the face only says it),
`Shared/Protection/WordsBand.swift` + `SetPassphraseModel.swift` + the U2b RECORD (the look/words idiom and
`WordsClipboard`), QUESTIONS #235's HER RULINGS block (VX-447/VX-448 — her words), `Assessment.swift`'s
`NoKeyFileAnywhere` + `Fault.noKeyFileAnywhere`. Commits say `Part of VX-447` / `Part of VX-448` / `Part of VX-418`
(the doors are the flagship's scope).

**The goal.** (1) THE KEY DOORS on the new road's pane: Change Passphrase… (current verified, new twice), New Words…
(the look idiom mints and shows ONCE — the U2b panel composed for this door, rule 6's sentence), Reset forgotten
passphrase (the forgot road: `ResetAuthorization` — Castle by Touch ID or the words, Standard the plain confirm).
Each door says VX-263's ONE line: *your current secrets open everything you've made of this library* (rule 6's "the
doors say so in one sentence" — the exact drafting PROVISIONAL, pinned). Synced, the doors refuse `accountMoved` /
`needsFreshVault` in the pane's refusal idiom. (2) **VX-447 (her ruling, #235):** the no-key-file banner BECOMES THE
DOOR — in the `noKeyFileAnywhere` state the banner's sentence carries the act: record the words (the look) → the act
writes a FRESH key file → the backup follows; "the act can proceed" = the CORE's new-words act accepts a file-less
library (today `regenerateWords` refuses `noLiveKeyFile` — the arm is widened EXACTLY for the no-live-key-file state
with the library open, minting the file it then locks; a custody-core line, the P-VX307-U2b-1 shape: guarded, pinned
red-on-old, the Fable ladder reads it). The SYNCED flavor gains the open-library variant of the account sentence
(F-U2c-5 folded here — her ruling's words). (3) **VX-448 (her ruling, #235):** the words' Copy becomes a CONCEALED
pasteboard type cleared at lock and at quit; the 60-second timer and the restore-prior-contents GO (`WordsClipboard`
— one home; both the band's look and the doors' look ride it). Pins: the concealed type set, the clear at lock/quit,
the timer gone. Hard limits, words rule, and evidence: §5a's verbatim.

## 5d. U4 BRIEF — THE LOCK ON THE NEW ROAD + THE HOLD'S GATE (a fresh Opus implementer; VX-445 + F-4)

**Read first, in full:** the §5a list PLUS `AppBootstrap` (the lock road + `canLock`; VX-307 U2a's F-3 — "the
Always-ask lobby is reached by relaunch"), the ticket VX-445 (+ NIT-R2-1 in
`notes/plans/vx-307-ladder-round-2.md`), `Shared/Protection/ProtectionCrossingActs.swift` (the export mark —
`ScheduledExportSwitch.noticeOwed`, today keyed per defaults domain), the restore-hold marker's readers (the 13x
gates; `grep restoreHold` under `Shared/`). Commits say `Part of VX-445`.

**The goal.** (1) **VX-445:** Castle's idle lock and Lock Now WIRED on the new road — `canLock` true where the road
session stands, the lock running through the road session's teardown (the crossings' `onWillLock` idiom), the relock
landing in the lobby (Always ask types; Touch ID auto-asks — the open road's existing behavior, untouched); the idle
timer's existing setting honored. (2) **NIT-R2-1 rides:** the durable export-notice mark keyed BY LIBRARY (today one
defaults key per domain — multiple libraries at ready would share it; the key gains the library id, the
`variorum.calmAsks.*.<libraryID>` idiom; notice-visibility only, the switch-off cannot be lost). (3) **F-4:** the
restore hold's gate carried to the synced crossings — while the hold marker stands beside the store, Use Castle and
Replace All Keys REFUSE (the 13x F1 R1-M1 rule, now reachable because the account arms exist); the refusal's sentence
names Resume Sync (the shipped #216-family copy's idiom). Pins red-on-old for each. Hard limits, words rule, and
evidence: §5a's verbatim.

## 6. RECORDS (each unit appends; the VX-306 §9 form)

*(appended per batch)*

## 7. LIVE STATUS
- 2026-10-19 ~03:30 MDT — KICKED OFF (session `vx-308`). STEP 0 done: bout ritual, worktree
  `~/dev/variorum-vx-308`, branch pushed, in-flight row (holds the Sync/-custody slot) `969acce55` on main, Linear
  VX-308 → In Progress, coordinator announced + slot granted. Preflight COMPLETE (the orchestrator, nothing
  delegated): CLAUDE.md + canon, master plan + in-flight, workflow transition, TICKETS, QUESTIONS #235/#216/#205,
  the phase plan, resiliency protocol, SurfaceContracts (the app + Doors/protection), CastleRules WHOLE, SyncSpec
  WHOLE, lifecycle stages 10 + 12, VX-307 §5a + §6 (U1 RECORD, U2a/U2b records + fix leg + arbitrations + THE WALK
  RECORD) + §7, PhaseSizingGuidance, the VX-308 ticket + comments (the 2026-10-16 re-scope governs), the core
  (`AccountActs` · `Follow` · `KeyDoors` · `Assessment` · `AccountVaultClient` · `ProjectConfig`). THE WALK CALL:
  option (b) — the throwaway project live and fidelity-checked (§4). Next: the rehearsal (§5R), then U1.
