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

### THE REHEARSAL RECORD (the orchestrator, 2026-10-19 ~04:15–04:45 MDT; §5R run whole; no stage — network only, the coordinator's no-objection + ref guard on every apply)

- **The chain:** 01→09 `[]` each · the two 14c gate scripts `[]` · 10→16 `[]` each — EVERY numbered artifact landed
  on its FIRST run, in repo order, on a fresh hosted project. The two pre-13x maintenance pieces re-verified their own
  grants; `beta-signup-auto-entitle` `[]`. The grant sweep then read **63 OK · 4 INFO · 0 fail — byte-identical to
  production's 13n-b shape**: the throwaway is a faithful marker-13 mirror, and a FRESH-MIRROR RUNBOOK now exists
  proven (the §5R order with R-1's correction; named for 18b-class work).
- **R-1 (found by the sweep, fixed in §5R's own order):** `maintenance/pre13x-ladder-rotation-clearing-guard.sql` is
  an OVERLAY superseded by 12's fold-in — applied after 12 it re-creates the retired pre-challenge signature, which
  the sweep flagged as the exact lingering-overload class it exists to catch (one UNEXPECTED FUNCTION row). Dropped
  on the throwaway (production never had it — its sweep history is clean); the fresh-chain rule recorded: on a fresh
  mirror that overlay is NOT applied.
- **The planted preflight:** two auth users (ids in `~/.variorum/dev-vault-throwaway.env`, values nowhere else) and
  two pre-event `key_vault` rows — A Standard-shaped (apple-held wrap present, revision 3), B Castle-shaped (absent,
  revision 5), rotation columns null, proof hashes set (the insert trigger demands them — held). The checklist's
  preflight probe rehearsed: `apple_held` true/false as planted, `rotation_started_seq` null, marker 13.
- **ARTIFACT 17: `[]` ON ITS FIRST RUN on real Postgres** (16,600 bytes, one execution). The verify tail exact:
  marker **14**; `mode` text YES + `earlier_row_keys` jsonb YES + `journal_bridge_key_id` relaxed to YES
  (P-VX307-U1-1 held); **the mode backfill RIGHT ON BOTH ARMS** (A → `standard`, B → `castle` — P-VX307-U1-2's
  semantic, proven on rows, not just read); rotation columns cleared; `sync_reencrypt` zero rows.
- **R-2 (found by the post-17 sweep, FIXED IN REPO):** the sweep's expectation table still demanded
  `sync_reencrypt(jsonb,text,text,text)` — post-17 it reported MISSING, which the VX-329 window would have hit live.
  The sweep's function CTE is now MARKER-AWARE (the row demanded below marker 14, retired at it; one filtered
  `values` wrap, commented). Re-run on the marker-14 throwaway: **62 OK · 4 INFO · 0 fail**. On a marker-13 mirror the
  filter leaves every row standing (the logic is a plain `or marker < 14`); `AuthRLSDDLTests` +
  `VX307VaultArtifactTests` headless `✔ 83 tests in 2 suites` over the amended file. The checklist's sweep-row
  expectation corrected in its REHEARSED note.
- **The checklist** stays HELD, every row PENDING-UNTIL-LIVE; the REHEARSED banner carries the rehearsal's facts and
  the two findings. The throwaway now speaks marker 14 — exactly what the account-arm walk (§5 row 7) needs.
- No secrets in any record or echo; every apply carried the in-command ref guard. Scratch responses live in the
  session scratchpad only.

### U1 RECORD — THE ACCOUNT SECTION'S FACES (Opus implementer, 2026-10-19; VX-418's trunk + VX-264 + VX-239/VX-243 — BUILT; the Mac suites and the walk PENDING)

**Not done in U1, first:**
- **No Mac suite was RUN** (the brief: no `xcodebuild test`, no stage) — only BUILT (`build-for-testing` green on the final
  tree). The list below is the orchestrator's under a stage claim. What DID run: the planted and pure suites HEADLESS in
  this session's SwiftPM harness over the real `Shared/Protection/` files (192 / 30, the recipe below), and the core's
  protection set in both configurations (no core file changed). **The bootstrap-level red-on-old (VX-239 through
  `AppBootstrap` — `ProtectionAccountRouteTests.aSheetStandingWhenTheLibraryClosesNeverReturnsAfterTheUnlock`) is PENDING
  the stage: run it, then revert `finish`'s one `libraryClosed()` line to watch it red, then restore.**
- **The walk was not done** (the orchestrator's — §5 row 7; the recipe below). No Debug app was launched; the dev store, the
  real store and `/Applications` were never touched; no live network call was made anywhere.
- **U2's and U3's rows are untouched:** the join (turning sync on into an account that has its vault, Move) shows the honest
  not-yet line (R-4); the follow, VX-107, VX-113 (U2); the key doors (U3). The phone has no account section (the brains are
  shared; only the deletion's hook is wired there).
- **Today's road is untouched** — its VX-239/VX-243 close by its retirement at VX-329 (the new road's presenter is the fix
  there). **F-U1-2 (the passphrase floor) is routed, not fixed** (below).
- The canon delta (SurfaceContracts' "Library protection" line gains the account section, the one presenter, the signed-out
  road) and the QUESTIONS bundle rows are the closeout's (the shared-ledger rule); the PROVISIONALs are listed below.

**The build's history (kept):** STOPPED AT ONE DESIGN FORK BEFORE ANY CODE (F-FORK-1 below), ruled at the U1 ARBITRATION, then
built pieces 0–7. Preflight complete and not delegated: CLAUDE.md + canon, the resiliency protocol, CastleRules whole,
SurfaceContracts (the app + Doors/protection), SyncSpec whole, this plan whole, VX-307 §5a + §5b–§5e + §6 (U1 RECORD, U2a
RECORD + its fix leg, THE WALK RECORD) + §7, QUESTIONS #216 (the shipped copy AND her sitting's block), the core
(`Assessment`, `Assess`, `AccountActs`, `KeyDoors`, `Executor`, `Facts`, `VaultModel`'s snapshot, `AccountVaultClient`),
`Shared/Protection/` (`RoadCrossingsModel`, `RoadCrossingFaces`, `ProtectionCrossingActs`, `ProtectionWords`,
`ProtectionOpenRoad`, `ProtectionOpenFaces`, `ProtectionRoadActs`, `ProtectionSystem`, `ProtectionFactsGatherer`,
`WireVaultLeaf`, `ProtectionWalkSwitch`, `ProtectionRoad`), `RoadCrossingSheet`, `ProtectionPane`, `SettingsSceneContent`,
`AppBootstrap`'s new-road arms, `AppServices`' account doors, `AuthSession`, `AuthViews`, `ProjectConfig`, the lifecycle
page's stage 12, and the U2a harness recipe (the U2c harness's package + stubs, read from the VX-307 session's scratchpad).

**F-FORK-1 (THE ONE FORK — `deleteAccountHere`'s server half; the architect's ruling needed).** `assess` opens
`Door.deleteAccountHere` only while signed in to the library's account; the core's act (`leaveAccount(.deleteAccountHere)`)
is the PROTECTION HALF only — the record stops naming the account, this Mac forgets its sync keys (rule 16). The VX-305 U3
record says so outright: *"delete the account from this Mac (the server's deletion is the account lifecycle's — phase 4)"*.
The U1 brief lists the door among the three leaves ("the face still confirms") and is silent on the server's deletion. Today
the one deletion door is the Account sheet's *Delete Account…* (`AccountView` → `AppServices.deleteAccount`: her ruled
friction — copy §4's body, the subscription advisory, the account password re-authenticated, the typed *DELETE MY ACCOUNT* —
then the server purge and the sign-out, custody kept); on the new road it would purge the account and leave the record naming
it (the section then reads `.signedOut`, and This Mac Only closes it). Options:
- **(a) RECOMMENDED — the section's door is the deletion's new-road home.** *Delete your account…* (rendered only where
  `assess` opens `deleteAccountHere`) through the one presenter: one confirm carrying the SHIPPED deletion friction
  byte-reused (`ProtectionCopy.deleteAccountTitle`/`Body`, the advisory, the password, the typed phrase); the act = the
  existing lifecycle road (`AppServices.deleteAccount`, injected by the composition root — no new server act) THEN the
  protection half; a leave that fails after a landed deletion is said, and the signed-out road's This Mac Only finishes it.
  The Account sheet's own door stays as it is (today's road byte-unchanged; on the new road its rarer use leaves the record
  for This Mac Only). Why: the door exists in `assess` for exactly this moment and the brief binds every account door to the
  section and its one presenter.
- **(b)** The Account sheet stays the ONE deletion door everywhere; on the new road its success also runs the protection half
  through an injected after-deletion hook (nil on today's road); the section renders no delete door (`deleteAccountHere` read
  and hidden).
- **(c)** U1 composes no deletion: `deleteAccountHere` hidden; the composition becomes its own ticket.

**MY READINGS (each the brief's or her ruling's letter as I read it — building on them unless the architect overrules in the
same ruling):**
- **R-1 — VX-264's signed-out screen is her RULED one, not the shipped two doors.** The brief says #216's rulings are "STILL
  PENDING"; #216's HER SITTING block (2026-10-13) RULED it: *"One road, plain"* — the familiar Continue / Cancel, her approved
  mockup (*"You're signed out of sync."* / *"Castle will apply to this Mac only, and this Mac will stop using your old sync
  account. Its copy on the server stays as it is."* / *"To put your whole account in Castle instead, cancel, sign in, and
  choose Use Castle again."*), superseding VX-110's two doors and P-U2-1; plus *"Add it"* (the born-Castle Done sentence) and
  *"Drop the devices clause"*. VX-264 is that ruling's build. On the new road: while signed out `assess` refuses Use Castle
  `.signedOutUseThisMacOnly` ("the one plain road (This Mac Only) stands in its place") — so Use Castle renders its door, the
  press shows HER screen (her three sentences byte-equal, pinned), *Continue* runs the This-Mac-Only leave (rule 16 — nothing
  typed, no key changes) and then opens Use Castle's own confirm on the now-local library (both secrets, the gate choice — the
  crossings' road unchanged), *Cancel* writes nothing; her born-Castle sentence (*"Set up sync again later with a new account
  and it starts in Castle."* — true here: set-up hands the account the library's posture) ends that road's receipt. Use
  Standard and Replace All Keys while signed out keep U2a's sentences (her ruling is Castle entry's). The section's own
  signed-out state offers the same one road (This Mac Only — Continue / Cancel) and *Sign in…*; Stop syncing here (the same
  act) is not rendered beside it — one road, plain.
- **R-2 — ONE READ for the pane.** `assess` over the open library's facts with the CURRENT sign-in (read now — the open's is
  stale once she signs in or out) and a FRESH vault read for the signed-in account (decision 35: a synced door without it
  refuses `.needsFreshVault`; a local library needs it to tell set-up from a join). The crossings' faces and the account faces
  derive from that one assessment, and the crossings' press-time re-read (VX-108) reads the same way, so a shown door and its
  re-read compare like with like. Each act adopts the current sign-in into the executor's configuration under the session's
  one-act lock (reads never touch the executor). A local library with nobody signed in reads exactly as before (no fetch).
- **R-3 — the vault leaf follows the current sign-in.** `WireVaultLeaf.live` composes its own `AuthSession` per open, which
  caches the scope's stored session at first use — after a sign-out and a sign-in to ANOTHER account (the §5 row-7 walk's own
  sequence) the leaf answers `notSignedIn` until the next open. Its session provider re-reads the stored session per call and
  re-composes when the signed-in user changed (new road only; today's `KeyVaultClient` untouched). Routed beside it, not fixed:
  F-U1-1 — two `AuthSession` instances over one keychain item each refresh on their own (Supabase rotates refresh tokens) — a
  reuse-detection hazard VX-307 U1's leaf already carries; VX-329's live road decides it.
- **R-4 — the join arms are U2's (§5b).** `turnOnSync` with an account vault (`entersCastle`/`leavesCastle`/`sameMode`) and
  *Move it to …* are read into the model; U1 renders the honest not-yet line (the `plaintextCopyNotYet` precedent), which U2's
  join face replaces. U1's `turnOnSync` face is the set-up arm (`setsUpInLibrarysMode`).
- **R-5 — *Sign in…*** in the signed-out states opens the app's one sign-in surface (the Account sheet, `AccountView`) through
  the presenter; the section re-reads when it closes.
- **R-6 — the one presenter (VX-239 + VX-243's rule on the new road):** one protection sheet at a time; presented only by its
  HOST SCENE (Settings ▸ Protection — never two windows); kept across its own act's reopen (U2a's confirm survives it); DROPPED
  at any settled closed state (a lobby, the interlude, missing, failed — so it never re-presents after an unlock; U4's lock
  lands in the lobby and inherits the rule). The crossings' confirm moves onto it, its contents byte-unchanged. Today's road's
  two bugs close by its retirement at VX-329 (today's road untouched here).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece −1 — this record skeleton + the fork: DONE (`372f92703`).
- **BUILD RESUMED at the U1 ARBITRATION (below)** — F-FORK-1 ruled a refined (b); R-1 amended by her word (the 10-13 block
  superseded — the signed-out screens to the CURRENT rules, every line PROVISIONAL, divergences bundled); R-2/R-3/R-4/R-5/R-6
  approved; F-U1-1 routed to VX-423. Pieces 1, 3, 4 and 6 below are re-cut to the ruling as they land. HARNESS BASELINE (this
  session's scratchpad package — the U2c recipe pointed at this worktree; the pre-U1 tree): `✔ Test run with 149 tests in 23
  suites passed`.
- Piece 0 — THE WALK'S DOOR: DONE (this commit). `ProtectionWalkSwitch.projectOverride(environment:)` (DEBUG, pure: both
  `VARIORUM_WALK_PROJECT_URL` and `VARIORUM_WALK_ANON_KEY` set, trimmed, the URL https with a host → the pair; else nil) +
  `projectOverrideForThisLaunch` (the process environment, logged ONCE — that the coordinates are overridden and whether they
  name the production mirror's own host; never the URL or the key). `ProjectConfig`: the production coordinates named
  (`productionProjectURL`/`productionPublishableKey`); `variorumProjectURL`/`variorumPublishableKey` read the override inside
  `#if DEBUG` only, the Release arm the production pair alone (behaviour identical; the binary not byte-identical — rule 24's
  precedent). Every `ProjectConfig` reader follows in a Debug launch (the auth, the vault client, today's transports — the dev
  store never syncs, the A4 fence). PROVISIONAL P-VX308-U1-0. Pin `ProtectionWalkProjectTests` (3: both → the pair; one alone /
  blank / http / no host → nil; the source pin of the DEBUG fence — one `#if DEBUG`, the Release arm reads no environment).
  HEADLESS (+ `ProtectionWalkSwitchTests`): `✔ Test run with 7 tests in 2 suites passed`. The Mac build of `ProjectConfig`
  (app-only, outside the harness) PENDING — piece 6's `build-for-testing` covers it.
- Piece 1 — THE WORDS: DONE (this commit; re-cut to the arbitration). `ProtectionWords`' VX-308 account section: RULE 16's
  two sentences (its "(rule 7)" pointer dropped) and RULE 7's two (*A device holds one pair of secrets at a time.* + the
  join sentence, kept beside its rule for U2) BYTE-EQUAL to `notes/CastleRules.md`; the turning-on lead byte-equal to the
  lifecycle page's stage 12; the sign-out confirm today's shipped copy byte-reused (`ProtectionCopy.signOut*`); the
  signed-out screens drafted to the CURRENT rules and pinned AS DRAFTED (never the superseded 10-13 block — the arbitration's
  redirect); the third leave LOCAL with ONE pointer to the Account sheet's Delete Account (P-VX308-U1-F1). Every other line
  PROVISIONAL P-VX308-U1-1. Pins `RoadAccountWordsTests` (7: rule 16 ×2 and rule 7 ×2 against the rules file; the lead against
  the page; the sign-out copy; the signed-out screens as drafted; the third leave's pointer said once; no line shouts).
  HEADLESS `✔ Test run with 7 tests in 1 suite passed` (the harness stub gains `ProtectionCopy`'s three sign-out strings).
- Piece 2 — THE ONE PRESENTER: DONE (this commit; R-6). `Shared/Protection/ProtectionSheetPresenter.swift`: one protection
  sheet at a time (`present` refuses while one stands; `replace` hands the floor in place); presented ON a host scene
  (`ProtectionSheetHost.settings`) and answered to that host alone (`sheet(for:)` — VX-243: never two windows); a sheet goes
  only by its own id; the host's dismissal is the sheet's Cancel (a running act keeps its sheet); `libraryClosed()` drops the
  standing sheet (VX-239 — the bootstrap calls it at every settled closed state, piece 6), and an act still running under it
  finishes on its own road with no sheet. The Account sheet's request (`ProtectionSignInRequest`, R-5) hears its close.
  `RoadCrossingsModel`: the confirm is presented THROUGH the presenter (`init(roads:presenter:)`, a pin's own presenter by
  default; `confirm` read from it; `open(_:on:)`), its contents byte-unchanged. Pins `ProtectionSheetPresenterTests` (6).
  HEADLESS, the whole harness (U2a's crossing suites unchanged and green through the presenter): `✔ Test run with 165 tests
  in 26 suites passed`. The pane's sheet binding moves at piece 6 (U2a's `RoadCrossingSurfaceTests` source pin of the old
  binding moves with it).
- Piece 3 — THE ONE READ + THE LEAF'S SIGN-IN + THE ACCOUNT FACES: DONE (this commit; R-2, R-3, R-4).
  `ProtectionAccountActs.swift`'s `ProtectionPaneRead.read` (the open library's facts with the sign-in NOW and a FRESH vault
  read through the leaf — `VaultReadState` `.notAsked` / `.read(exists:)` / `.unreachable`, never guessed; the executor's
  cache stays the acts'); `ProtectionCrossings.readCrossings`/`preflight` gain `read:` (nil keeps their own read — U2a's
  planted pins unchanged), so the crossings and the account read the same way, shown and re-read alike.
  `RoadAccountFaces.swift` (pure): the situation, `turnOnSync` (signed out → *Sign in to turn on sync.* + Sign in; no vault →
  the set-up confirm — both typed, a NEW passphrase twice where none exists, the lifecycle lead + rule 7 + the posture the
  account takes; a vault → U2's join, the not-yet line; unreadable → the needs-vault sentence), the three LOCAL leaves ONE
  ROAD PER SITUATION (in sync: Stop syncing here + Delete the account from this Mac; signed out: This Mac Only — Continue;
  each confirm rule 16's two sentences, the third leave's one pointer last), Move U2's (not yet), Sign out / Sign in, the
  in-sync unreadable-vault line, and the account acts' refusal sentences (an act stopped mid-plan never says "nothing
  changed"). PROVISIONAL P-VX308-U1-2 (one road per situation). R-3: `FollowingSessionProvider` (an actor: who is signed in
  is read per call; a changed user gets a provider made for them; no one → `notSignedIn` before anything composes) — wired
  into `WireVaultLeaf.live` over the scope's stored session (app-only; its Mac build PENDING — piece 6). Test support
  `ProtectionAccountSupport.swift` (`PlantedVaultLeaf` — the core `ExecutorVault`'s semantics restated, no network;
  `PlantedSyncKeysLeaf`; `PlantedAccount`); `PlantedRoad` gains `vault`/`syncKeys`/`session` (nil/signed-out — every earlier
  suite unchanged). Pins `RoadAccountFacesTests` (10) + `FollowingSessionProviderTests` (1). HEADLESS, the whole harness:
  `✔ Test run with 176 tests in 28 suites passed`.
- Piece 4 — THE ACCOUNT ACTS ON THE SESSION: DONE (this commit). `ProtectionAccountRoad.press` (one act at a time; the door
  RE-READ through the one read — closed → refused, changed → re-shown, nothing written; VX-108) → `act` (the CURRENT
  sign-in adopted into the executor's configuration UNDER the act's lock — R-2; then `setUpSync` or `leaveAccount` on the
  OPEN session — no swap, so no reopen; a refusal said per `RoadAccountFaces.actRefusalSentence`, and an act stopped
  mid-plan says it finishes at the next open, never "nothing changed"). P-VX308-U1-F1's hook `accountDeleted(_:accountID:
  signIn:)` — the protection half (the third local leave) when THIS library names the deleted account; else nothing; when it
  cannot run, the signed-out screens catch it at the next read. Sign-out and sign-in are the composition's roads (piece 6 —
  the app's Account sheet and `AppServices`). Pins `ProtectionAccountRoadTests` (7, one parameterized over the three
  leaves): set-up hands the pair up (the vault opens with the typed passphrase AND the library's own words — never new
  ones), binds the record to the account and its sync key, holds the sync keys the Standard way, key unchanged, and the
  next read reads in sync — on a session composed SIGNED OUT (the sign-in adopted); a wrong word writes nothing (no vault,
  no binding, nothing in flight); the door re-read (another device turned sync on → refused; signed out → the sign-in
  line); a changed door re-shown (a passphrase set meanwhile); each LOCAL leave unbinds and forgets the sync keys while the
  key, the key file and the server's vault stay byte-equal (no vault write); the deletion's hook for this library's
  account only; a press during another act refuses. HEADLESS, the whole harness: `✔ Test run with 183 tests in 29 suites
  passed`.
- Piece 5 — THE MODELS + THE SIGNED-OUT ROAD'S BRAIN: DONE (this commit). `Shared/Protection/RoadAccountModel.swift`:
  `RoadAccountRoads` (read · press · landed · speak — injected); `RoadAccountConfirmModel` (exactly the ask's fields — set-up
  both typed, a NEW passphrase twice; a leave nothing, rule 16 — shaped before the road; untrimmed; a changed door re-shown,
  VX-108); `RoadSignOutModel` (today's shipped confirm); `RoadSignedOutCastleModel` (the signed-out screen — Continue / Cancel,
  the current rules' words); `RoadAccountModel` (OWNED BY THE BOOTSTRAP: the faces with the crossings' landing rule; each
  sheet through THE ONE PRESENTER — one at a time with the crossings'; a landed act's receipt spoken ONCE and the pane re-read,
  this section and the crossings via `landed`; *Sign in…* the Account sheet whose close re-reads; *Sign out…* only with the
  composition root's `signOutRoad`, P-2). The presenter gains the `.signedOutCastle` / `.account` / `.signOut` sheets. THE
  SIGNED-OUT ROAD (VX-264, R-1 as amended): `RoadDoorFace.signedOutRoad` — Use Castle refused `.signedOutUseThisMacOnly`
  renders its door (Use Standard / Replace All Keys keep their sentence); `RoadCrossingsModel.openSignedOutRoad` — Continue
  runs `RoadCrossingRoads.leaveForThisMacOnly` (default: refused — every earlier planted road unchanged), re-reads, and
  hands the floor (`presenter.replace`) to Use Castle's own confirm carrying `receiptNote: bornCastleNote` into its request
  (`RoadCrossingRequest.receiptNote`, additive); the preflight treats the face as closed. U2a's
  `RoadCrossingFacesTests.aSyncedLibrarysDoorsSayTheirRefusalsInPlace` pin FLIPPED deliberately at its signed-out line (`.signedOutRoad`
  — the old sentence was this unit's target; Replace All Keys' line kept). Pins `RoadAccountModelTests` (8). HEADLESS, the
  whole harness: `✔ Test run with 191 tests in 30 suites passed`.
- Piece 6 — THE MAC FACES + THE BOOTSTRAP'S ROADS + THE DELETION'S HOOK: DONE (this commit). `AppBootstrap`: the one
  presenter (`protectionSheets`) and the account section's model (`roadAccount`) made once at the first new-road ready beside
  the crossings (which present through it) and handed to each open library's faces (`RoadStandingModel.account`/`.sheets`);
  `finish` calls `libraryClosed()` at EVERY non-ready settled outcome (VX-239); `crossingRoads().read` reads through the pane's
  one read, `crossOnNewRoad`'s preflight re-reads the same way and ADOPTS the sign-in now under the act (R-2), its receipt
  carrying the request's note (the signed-out road's born-Castle sentence); `leaveForThisMacOnly` (the signed-out road's
  Continue — `ProtectionAccountRoad.leaveForUseCastle`, re-read at the press, pinned headless +1); `accountRoads()` (read ·
  press · landed → the crossings re-read · speak → the standing faces' status seam); `signInNow` (the stored session now —
  `RoadInputs.sessionFact`); `accountDeletedOnNewRoad` (P-VX308-U1-F1 — only when the open library names the deleted account,
  under the one-act lock; else the signed-out screens close it). `AppServices.afterAccountDeleted` (nil → today's deletion
  byte-unchanged in effect; the deleted account's id read before the purge; called after it lands, before the sign-out),
  wired on the new road in `VariorumApp` AND `VariorumMobileApp` (the gap is the phone's too), with the account section's
  `signOutRoad` (the Mac — `AppServices.signOutVariorum`). Mac faces `Features/Protection/RoadAccountSheet.swift`:
  `RoadAccountSection` (the situation in words, each door, the not-yet lines, Sign in / Sign out), `RoadAccountConfirmSheet`,
  `RoadSignOutSheet`, `RoadSignedOutCastleSheet`, and `ProtectionSheetsHost` (`.protectionSheets(_:services:)` — the
  presenter's standing sheet on its host alone; the host's dismissal its Cancel; *Sign in…* composes `AccountView`).
  `RoadCrossingsSection` renders `.signedOutRoad` as Use Castle's door → `openSignedOutRoad()`; its doors grey while ANY
  protection sheet stands. `ProtectionPane`: the account section beneath the crossings; the crossings' own sheet binding
  REPLACED by `.protectionSheets(roadStanding?.sheets, services:)`; the account re-read at each appearance. U2a's
  `RoadCrossingSurfaceTests` source pin moved to the presenter's host (and pins no second presenter);
  `TravellingDotsIndicatorTests`' surface list gains the new file. Mac suites `RoadAccountSurfaceTests` (3 — the section
  hosted in every situation, every sheet shape, the pane's composition pinned) + `ProtectionAccountRouteTests` (2 — VX-239
  through the bootstrap: a confirm standing when a reopen lands in the lobby is dropped and NOT re-presented after the words
  unlock, RED-ON-OLD BY REVERT of `finish`'s `libraryClosed()` line; turning sync on through the section then the deletion's
  hook end to end, planted vault) — BUILT, their RUN PENDING under the stage. `build-for-testing` → `** TEST BUILD SUCCEEDED
  **` (one compiler crash on a `??`-with-closure in `signInNow` rewritten plainly first); the two capture warnings in
  touched files cleared after that build — the close's re-build green with none.
- Piece 7 — THE CLOSE: DONE (the close commit) — the counts, the Mac suite list, the walk recipe, the PROVISIONALs and the
  findings below.
- No revert is in flight (every mutation run restored from git and `cmp`-checked; no scratch worktree was made).

**COUNTS (the final tree — the close commit):**
- HEADLESS (this session's SwiftPM harness — not durable; the U2a recipe pointed at this worktree: a package in the
  scratchpad, swift-tools 6.2, macOS 26, the app's concurrency settings, depending on this worktree's core by path; its
  `Variorum` target SYMLINKS every `App/Variorum/Shared/Protection/*.swift` but `ProtectionBackupHook.swift` and
  `WireVaultLeaf.swift`, plus `Shared/LibraryOpenCopy.swift`, plus the U2c stub file + `ProtectionCopy`'s three sign-out
  strings; its test target symlinks the U2c set — `CopyDoorsListRefreshTests`, `CopyDoorsModelTests`,
  `CopyDoorsPickRefreshTests`, `CopyDoorsQuietProbeTests`, `LookInsideRoadTests`, `MakeMineRoadTests`,
  `PassphraseReminderTests`, `PickedCopyRoadTests`, `ProtectionCrossingRoadTests`, `ProtectionFacesSupport`,
  `ProtectionFileLeavesTests`, `ProtectionLobbyModelTests`, `ProtectionNoticeFaceTests`, `ProtectionOfferFaceTests`,
  `ProtectionOpenRoadPlantedTests`, `ProtectionTestSupport`, `ProtectionWalkSwitchTests`, `ProtectionWordsPlanTests`,
  `ProtectionWordsVX307Tests`, `RoadCreationFaceTests`, `RoadCrossingFacesTests`, `RoadCrossingModelTests`,
  `RoadRearmTests`, `WordsBandTests` (the BASELINE on the pre-U1 tree: `✔ Test run with 149 tests in 23 suites passed`) —
  and this unit's `ProtectionWalkProjectTests`, `RoadAccountWordsTests`, `ProtectionSheetPresenterTests`,
  `ProtectionAccountSupport`, `RoadAccountFacesTests` (+ `FollowingSessionProviderTests`), `ProtectionAccountRoadTests`,
  `RoadAccountModelTests`): **`✔ Test run with 192 tests in 30 suites passed after 2.135 seconds.`**
- MUTATIONS (each run on the COMMITTED tree, restored with `git checkout --` and `cmp`-identical to HEAD): piece 0 — the https
  arm removed → `✘ oneAloneBlankOrNotHTTPSNamesNothing` (1 issue); piece 1 — rule 16's "or secrets" dropped → `✘
  rule16sTwoSentencesAreHersVerbatim` (2 issues); piece 2 — `libraryClosed()` not clearing → `✘
  theLibraryClosingDropsTheSheet…` (3) + `✘ theAccountSheetsCloseIsHeardByItsFace` (1); piece 3 — the read's unreachable arm
  guessed as "no vault" → `✘ anUnreadableVaultIsSaidNeverGuessed` (2) + `✘ inSyncAnUnreadableVaultIsSaidOnce` (1), the
  provider never re-made → `✘ itServesWhoeverIsSignedInNow…` (2); piece 4 — the sign-in adoption removed (the open's stale
  signed-out session — R-2's mechanism, red-on-old in effect) → `✘ turningSyncOnHandsThePairUp…` (2) + `✘
  aWrongWordWritesNothing` (1) + `✘ theDeletionsHook…` (2); piece 5 — the signed-out arm removed (the pre-U1 face) → U2a's
  flipped `✘ aSyncedLibrarysDoorsSayTheirRefusalsInPlace` (1).
- The core's protection set (the 82 `@Suite` types under `Tests/VariorumCoreTests/Protection`; no core file changed — zero
  `Sources/`/`Server/` lines in this unit, `SyncSchema.lockstepVersion` = 13): Debug `✔ Test run with 334 tests in 82 suites
  passed after 5.214 seconds.`; Release (`swift test -c release`, the same filter) `✔ Test run with 310 tests in 78 suites
  passed after 4.641 seconds.`
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (the final tree); the phone `-scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' -configuration Debug -derivedDataPath DerivedData/vx308 build` → `** BUILD SUCCEEDED **`;
  **the Release check `-configuration Release build` → `** BUILD SUCCEEDED **`**; no warning in a touched file.
- Release behaviour: unchanged by construction — every new line is a new file, sits behind `newRoad`/`roadStanding` (nil on
  today's road), under `#if DEBUG` (the walk's door), or is a nil hook (`afterAccountDeleted`, set only on the new road); the
  crossings' `readCrossings`/`preflight` gain defaulted parameters only. The binary is not byte-identical (rule 24's
  precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308 test \
  -only-testing:VariorumTests/ProtectionWalkProjectTests \
  -only-testing:VariorumTests/RoadAccountWordsTests \
  -only-testing:VariorumTests/ProtectionSheetPresenterTests \
  -only-testing:VariorumTests/RoadAccountFacesTests \
  -only-testing:VariorumTests/FollowingSessionProviderTests \
  -only-testing:VariorumTests/ProtectionAccountRoadTests \
  -only-testing:VariorumTests/RoadAccountModelTests \
  -only-testing:VariorumTests/RoadAccountSurfaceTests \
  -only-testing:VariorumTests/ProtectionAccountRouteTests \
  -only-testing:VariorumTests/RoadCrossingFacesTests \
  -only-testing:VariorumTests/RoadCrossingWordsTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/RoadRearmTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionWalkSwitchTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/ProtectionTierFaceTests \
  -only-testing:VariorumTests/EncryptionFlowTests \
  -only-testing:VariorumTests/LobbyVaultRoadTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first nine are U1's (3 + 7 + 6 + 10 + 1 + 8 + 8 + 3 + 2 = **48 tests**; the two route pins need the signed test host —
a planted road, no keychain, the planted vault; `aSheetStandingWhenTheLibraryClosesNeverReturnsAfterTheUnlock` is the
bootstrap red-on-old: revert `AppBootstrap.finish`'s one `libraryClosed()` line → red, restore); then the suites over the
files this unit touched (the crossings' model/faces/acts/sheet and their flipped and moved pins, the planted road, the
words, the bootstrap, `AppServices`' deletion, `ProjectConfig`, `WireVaultLeaf`, the pane) and the source pins over the
edited files. `VX310TodayLobbyWitnessTests` still reports its KNOWN ISSUES (expected — a pass of either is a FAILURE); read
the `skipped:` lines.

**THE WALK RECIPE (§5 row 7 — the orchestrator's, under a held stage claim, the DEV STORE only, against the THROWAWAY
project; the coordinator's ref guard on every live call; never the production mirror):**
0. Zero Debug instances (by PATH; `/Applications` never touched). Build: `cd App/Variorum && xcodebuild -scheme Variorum
   -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308 build`. Launch as the BINARY with
   the walk's door set from `~/.variorum/dev-vault-throwaway.env` (never echoed): `VARIORUM_WALK_PROJECT_URL=…
   VARIORUM_WALK_ANON_KEY=… OS_ACTIVITY_DT_MODE=YES App/Variorum/DerivedData/vx308/Build/Products/Debug/Variorum.app/
   Contents/MacOS/Variorum 2> ~/vx308-walk/run-N.log &`; the protection log says once `WALK SWITCH (VARIORUM_WALK_PROJECT_URL
   + VARIORUM_WALK_ANON_KEY): this launch's project coordinates are overridden — a walk project's, not the production mirror`
   (if it says "the production mirror's own host", STOP). **EVERY launch that signs in carries the override** (F-U1-5).
   Expected start: the dev library local (no account), Standard, the dev passphrase set. **Precondition — the dev pair in
   hand:** turning sync on types the passphrase AND the words (rule 7's hand-up): `source ~/.variorum/dev-castle.env`, then
   `export` (the file has no exports — VX-307's machinery note) — the passphrase and `VARIORUM_DEV_NEWROAD_WORDS`; never
   echoed. The throwaway account's vault is then locked under the dev pair (the throwaway's, hers to delete).
1. Settings ▸ Protection → beneath the crossings, **Sync**: *This library doesn't sync.*, *Sign in to turn on sync.*, *Sign
   in…*. Capture (light, dark). *Sign in…* → the Account sheet (the throwaway's account A) → Close → the section re-reads:
   *Turn on sync…*, *Sign out…*.
2. *Turn on sync…* → the confirm: the lifecycle lead, rule 7's *A device holds one pair of secrets at a time.*, *Your account
   starts in Standard, like this library.*, *Your passphrase*, *Your twelve words*. Capture. A WRONG word → refused in
   words, nothing written. The right pair → the receipt *Sync is on. Your passphrase and twelve words are your account's
   now.*; the section: *This library syncs with your account.* + *Signed in as …*, *Stop syncing here…*, *Delete the account
   from this Mac…*, *Sign out…*; the crossings: Use Castle now SYNCED (account-wide). Log: `set_up_sync: done`, `road:
   turnOnSync — … now names account …`. (The throwaway's `key_vault` gains A's marker-14 row — a read-only REST check.)
3. *Sign out…* → today's shipped confirm → *Sign Out* → the section: *You're signed out of sync.* + its line, *Use this Mac
   only…*, *Sign in…*; the crossings: *Use Castle…* still rendered (the signed-out road). Capture.
4. **The signed-out road:** *Use Castle…* → the signed-out screen (*You're signed out of sync.* / the current rules' lead /
   *To put your whole account in Castle instead, cancel, sign in, and choose Use Castle again.* / Cancel · Continue).
   Capture. Cancel → nothing. Again → *Continue* → the leave lands, the floor passes to Use Castle's own confirm (both
   secrets, the gate choice) → **Cancel there** (the walk keeps the dev store in Standard; a full entry is stage 6's, walked
   at VX-307) — the library is now LOCAL (*This library doesn't sync.*). Log: `this_mac_only: done`.
5. **The join line, then another account:** sign in as A again → *Turn on sync…* now reads the JOIN (A has its vault):
   *Joining an account that already syncs isn't ready in this build yet.* (U2's). Sign out; sign in as a FRESH throwaway
   account C (no vault) → *Turn on sync…* → set up (bound to C). Sign out; sign in as B → *Another account is signed in on
   this Mac.* + its line, *Moving this library to that account isn't ready in this build yet.*, *Sign out…*; the leaves render
   nothing. Capture (light, dark).
6. **The deletion's hook (P-VX308-U1-F1):** sign out; sign in as C (in sync) → the Account sheet ▸ Delete Account… (her ruled
   friction) → the section: *This library doesn't sync.* (log `road: the account was deleted — this library no longer names
   it`). ONLY ever on an account the walk made on the throwaway.
7. **Posture after the window:** the dev library LOCAL (no account), Standard, the dev passphrase unchanged (no crossing
   committed); **SIGNED OUT before the last quit** (F-U1-5 — the dev scope's stored session must not carry a throwaway
   token into a production launch); the throwaway accounts are hers to keep or delete with the project.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX308-U1-0 — the walk's door** (`VARIORUM_WALK_PROJECT_URL` + `VARIORUM_WALK_ANON_KEY`, DEBUG, both or neither, https,
  logged once): (a) BUILT; (b) a DEBUG settings toggle; (c) a launch argument.
- **P-VX308-U1-1 — the account section's undrafted words** (`ProtectionWords`' VX-308 section): the section's title
  (*Sync*), the situation lines, the doors' names, the not-yet lines, the turning-on confirm's posture line / new-passphrase
  lead / button / receipt, the leaves' leads / buttons / receipts, the third leave's pointer sentence, *Working…*, the
  unfinished-act sentence. HER sentences verbatim (pinned): rule 16 ×2, rule 7 ×2; the lifecycle page's stage-12 lead; today's
  shipped sign-out copy. (b) blank until her sitting; (c) other words.
- **P-VX308-U1-2 — one road per situation:** in sync → Stop syncing here + Delete the account from this Mac; signed out →
  Use this Mac only (Continue / Cancel); another account → Move (U2's) + Sign out, the leaves' "another account" refusals
  rendering nothing (the situation's line says it once). `assess` also opens the same act under the other names in those
  situations. (a) BUILT; (b) every door `assess` opens rendered (two doors for one act); (c) the leaves behind one disclosure.
- **P-VX308-U1-F1 — the arbitration's refined (b)** (built as ruled): the third door is the LOCAL leave with ONE pointer to the
  Account sheet's Delete Account; the deletion's success runs the protection half through `AppServices.afterAccountDeleted`
  (wired on the Mac AND the phone — the stranded-record gap is the phone's too); a hook that cannot run is caught by the
  signed-out screens at the next read. Her eye: the third door's wording, and whether she wants a deletion door in the
  section at all. Alternative recorded: (a) one deletion home in the section.
- **P-VX308-U1-3 — THE SIGNED-OUT SCREENS (VX-264, R-1 as amended by her word: "10-13 is probably old and superseded by
  now") — the whole copy PROVISIONAL. WHAT DIVERGED FROM QUESTIONS #216's 10-13 BLOCK, AND WHY:**
  - KEPT, true under the current rules: the title *You're signed out of sync.*; the one-road shape, *Continue* / *Cancel*;
    *To put your whole account in Castle instead, cancel, sign in, and choose Use Castle again.* (verbatim — rule 10: signed
    in, Use Castle is account-wide); the born-Castle sentence *Set up sync again later with a new account and it starts in
    Castle.* (verbatim — true: turning sync on hands the account the library's posture) — now ending the crossing's RECEIPT,
    since the new road has no Done screen (P-VX307-U2a-7).
  - REDRAFTED: the mockup's *Castle will apply to this Mac only, and this Mac will stop using your old sync account. Its copy
    on the server stays as it is.* → *Castle will apply to this library on this Mac only. First, this Mac stops using your
    sync account — none of your keys or secrets change, and the account's copy on the server stays as it is. Then Use Castle
    asks for your passphrase and your twelve words, as always.* — because on the new road *Continue* does not enter Castle by
    itself: it runs This Mac Only (rule 16 — no key, lock or secret changes; the server keeps what was pushed), and the
    crossing that follows types BOTH secrets in its own confirm (P-VX378-U2-2); "old sync account" became "sync account"
    (the record still names it — it is not old until the leave).
  - NOT CARRIED (the shipped VX-110 two-doors copy her 10-13 ruling had already superseded, and the known suspects): *This
    library still holds the sync keys for your account…* (the sync-keys-holding framing — the new road's signed-out state is
    the RECORD naming the account; its sync keys are custody, said nowhere); the Sign In… door's "Sign in, then choose Use
    Castle again" screen (her 10-13 ruling retired it); the This-Mac-Only Screen 1's re-key promise *Your library on this Mac
    gets a new key…* (true of the crossing, said by Use Castle's own confirm, never by the leave); her "drop the devices
    clause" is moot (no devices clause exists on the new road's receipts).
  - NEW, drafted to the rules: the section's own signed-out state (*You're signed out of sync.* + *This library still syncs
    with an account, but no one is signed in on this Mac, so nothing syncs. Sign in to sync again, or use this library on this
    Mac only — the account's copy on the server stays as it is.* + *Use this Mac only…* (Continue / Cancel) + *Sign in…*).
  Options: (a) BUILT; (b) the 10-13 mockup's words verbatim (its middle sentence would promise a Castle entry the leave does
  not make); (c) her redraft at the bundle.
- **P-VX308-U1-4 — a vault the read cannot read is ONE sentence** (*Variorum couldn't reach your account just now. Try again
  in a moment.* — U2a's): offline, a refused session, and a row this build can't read (`preLockstepRow` — the production
  mirror at marker 13) alike. (a) BUILT; (b) a distinct sentence for a row this build can't read; (c) hide the doors.
- **P-VX308-U1-5 — the signed-out road's receipt** = *You're in Castle now.* + the born-Castle sentence (one receipt). (a)
  BUILT; (b) no note; (c) the note as its own receipt.
- **P-VX308-U1-6 — the account acts run on the OPEN session** (no reopen — none swaps the key; the set-passphrase road's
  precedent): (a) BUILT; (b) the crossings' close-and-reopen seam for these too (no swap needs it).

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U1-1 → VX-423's family (the arbitration's routing; a closeout comment, no new ticket):** the vault leaf's provider
  (`FollowingSessionProvider` → its `AuthSession`) and the app's own `AuthSession` each refresh the scope's one rotating
  refresh token on their own — a reuse-detection hazard VX-307 U1's leaf already carried.
- **F-U1-2 (a ticket at closeout — Bug, Confirmed, Castle & sync; her 17n ruling):** the 12-character passphrase floor
  (`ProtectionCopy.passphraseFloor` — "it binds where a passphrase is SET") is enforced by NONE of the new road's setters —
  the set-passphrase sheet (VX-306), the crossings' new-passphrase field (VX-307), and now *Turn on sync…*'s; the core sets
  any length. Not fixed here: two of the three faces are not this unit's, and the floor belongs in one shared check.
- **F-U1-3 (the walk's caution, recorded):** a Debug launch WITHOUT the walk's door, signed in on the dev store, has the pane's
  read fetch the PRODUCTION mirror's vault row (read-only — today's road's `EncryptionSession.refresh` already reads it); a
  marker-13 row answers `preLockstepRow` (the pane says it couldn't reach the account); a set-up there on an account with
  NO row would POST marker-14 columns that PostgREST refuses (unknown column — fails closed, nothing written).
- **F-U1-4:** `ProtectionPane`'s `.task { await services?.encryption.refresh() }` (today's `KeyVaultClient`) still runs on the
  new road; under the walk's door it reads the throwaway's marker-14 row with today's format (read-only; today's rows are
  retired there) — VX-329's retirement of today's road ends it.
- **F-U1-5 (the walk's posture rule, recorded in the recipe):** a sign-in made under the walk's door leaves the dev scope's
  stored session holding the THROWAWAY's tokens; a later launch without the door presents them to production (a 401 →
  signed out). The walk signs out before its last quit.
- **F-U1-6 (the presenter's accepted consequence):** a crossing's confirm whose reopen lands anywhere but ready (the
  interlude, the lobby) is dropped by VX-239's rule — a refusal said after such a reopen is lost with it; a landed
  crossing's receipt still rides to the next ready.
- **F-U1-7 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains the account section (the situation
  and its doors from `assess`, one road per situation, the three local leaves, Sign in / Sign out), the one presenter, and
  the signed-out road, in place, one pointer to this plan.
- **F-U1-8 (MOBILE PARITY line):** the phone has no account section; only the deletion's hook is wired there.

**Notes:** no machinery deaths; no Sonnet lookup; no scratch worktree; the orchestrator's arbitration commits landed on this
branch mid-build (record-only, its own block) and were pulled at each push. Commits: `372f92703` (record + the fork) ·
`dd299f704` (0) · `71088dc21` (1) · `ff6ecf3bd` (2) · `c4e13b42f` (3) · `9133be4c6` (4) · `f5a75807d` (5) · `931b9a816` (6) ·
the close commit.

**U1 ARBITRATION (the orchestrator, 2026-10-19 ~05:30 MDT — repo-first before the build resumes; she is AWAKE and two
of her words land here verbatim):**
- **F-FORK-1 RULED: a refined (b) — rule 16's word "here" is load-bearing.** The section's three doors are rule 16's
  three LOCAL leaves exactly as the core act family defines them (`leaveAccount(.thisMacOnly/.stopSyncingHere/
  .deleteAccountHere)`): none touches the server's data, and each confirm says rule 16's sentence (the server keeps
  what you pushed; signing back in is a join). The third door renders as "delete the account from this Mac" — the
  local leave — with ONE pointer sentence naming where the real deletion lives (the Account sheet's door, her ruled
  friction, unchanged and unduplicated). THE GAP the fork found is closed on the OTHER side: on the new road the
  Account sheet's Delete Account… success also runs the protection half through an injected hook (the record stops
  naming the dead account; this Mac forgets its sync keys), so no stranded record; if the hook cannot run, the
  signed-out screens catch it at the next open — say so in the record. Option (a) stays recorded as the alternative
  (one deletion home in the section); PROVISIONAL P-VX308-U1-F1, her eye in the bundle (the third door's wording and
  whether she wants a deletion door in the section at all).
- **R-1 AMENDED BY HER WORD, just now, verbatim: "10-13 is probably old and superseded by now."** The #216 sitting
  block (2026-10-13) predates the 2026-10-16 simplification and everything since, so it is NOT treated as binding
  copy. U1 builds the signed-out screens TO THE CURRENT RULES (CastleRules as amended; `assess`'s situations; rule
  16's leave semantics), keeps the 10-13 mockup's SHAPE (one road, plain, Continue / Cancel) only where it still says
  something true under the current rules, drops or redrafts any sentence the current rules contradict (the old
  sync-keys-holding framing and any re-key promise are the known suspects), and the WHOLE screen's copy lands
  PROVISIONAL with a bundle note naming exactly what diverged from the 10-13 block and why. Her morning eye decides;
  the byte-equal pins piece 1 planned against #216's mockup sentences are REDIRECTED to pin the drafted text as
  drafted (provisional), never the superseded block.
- **R-2 (one read: sign-in fresh + vault fresh; re-check at the press), R-4 (join arms are U2's; honest not-ready
  line), R-5 (Sign in… opens the existing Account sheet through the presenter), R-6 (the presenter's semantics):
  APPROVED as stated.**
- **R-3 APPROVED** (the leaf re-reads the stored session per call); **F-U1-1 ROUTED, not fixed: it is VX-423's
  mechanism family** (the board's "refresh_token_already_used and sync stops until re-login" — Confirmed,
  Pre-launch). A comment lands on VX-423 at closeout naming the two-instances-one-rotating-token trace; no new
  ticket.
- **Her throwaway word (just now, verbatim): "i'll delete the throwaway when this is all merged to main &
  released."** The §4 morning item RESOLVES: the project stays up through the merge and release; nothing for the
  bundle but the reminder.
- **VX-314 CONFIRMED IN — her ruling at the kickoff sitting's tail (2026-10-19, verbatim): "ok include it. you can
  use a subagents to build it you want, up to you."** After her design questions were answered (how the binding
  lives on the record; the Move door as the only re-binding road; the gate's worth as one engine-mouth refusal), she
  ruled it in and went to sleep — the overnight mandate fully live from here. The orchestrator builds it INLINE
  (Fable work by the standing cast — the gate is at the engine's mouth) at the clean seam after U1's close, with
  fake-server pins red-on-old; the shape: a round refuses visibly (outbox intact, cursor unmoved — the lockstep
  refusal's grammar) when the signed-in account is not the library's bound account, on both roads' reads of the
  binding.

**THE U1 MAC BATCH (the orchestrator, 2026-10-19 05:03–05:14 MDT, stage claim `vx-308-u1-mac`, the coordinator's GO;
logs `vx308-u1-mac-run.log` · `-refix.log` · `-revert.log` · `-restore.log` in the worktree root, deleted at
closeout):** `✘ Test run with 223 tests in 42 suites failed … with 4 issues (including 3 known issues)` — the 3 are
`VX310TodayLobbyWitnessTests`' expected witnesses (a pass of either would be the failure); **ONE real red, fixed:**
`StatusSeamVocabularyTests.noStatusDoorIsNamedForItsPlacementInsteadOfItsClass` flagged U1's new
`RoadAccountRoads.speak` dot-call (`RoadAccountModel.swift:266`) — the member renamed to its class (`receipt`) at its
three sites (the struct, the call, the bootstrap wiring) plus the test's construction label; the pre-existing
`RoadStandingModel.speak` is untouched and unflagged (an assignment, not the retired call token — a ladder NIT
candidate at most). Re-run `✔ 14 tests in 3 suites` (StatusSeamVocabulary + RoadAccountModel + AppBootstrapOffMain).
**The bootstrap red-on-old VERIFIED BY BEHAVIORAL REVERT:** the one `libraryClosed()` line in `AppBootstrap.finish`
reverted → `ProtectionAccountRouteTests.aSheetStandingWhenTheLibraryClosesNeverReturnsAfterTheUnlock` RED (2 issues,
the sheet surviving the unlock — the pre-U1 behavior in effect); restored by `git checkout --`, `git diff` clean,
the suite `✔ 2/2` after. 0 instances at release; the stage released with the result line. **U1 IS CLOSED but for the
walk and the ladder.**

### VX-314 RECORD — THE ACCOUNT-BINDING GATE (the orchestrator's own hands, 2026-10-19 ~05:45 MDT; her ruling "ok include it")

**The traced mechanism:** the server stamps and fences every pushed row by the signed-in session's identity, and
nothing client-side refused a round when that session was not the library's bound account — so a library bound to X,
with Y signed in, pushes new writing into Y's partition (possibly sealed under X's corpus key: wrong on both axes,
silently). The protection layer's doors enforce the binding (`assess`'s `otherAccount` situation); the engine's mouth
did not.

**Built (one gate, the `keyProvider` pattern):**
- `SyncError.accountMismatch(bound:signedIn:)` (`SyncSchema.swift`) — the §12 refusal grammar; the description names
  the pair for logs and pins.
- `SyncAccountBinding` (two nil-tolerant async closures) + `SyncEngine.accountBinding` (default nil = INERT) +
  `refuseIfAccountMismatched()` in the round-entry cascade: push() after the re-key check and BEFORE keys (the bound
  account's keys may sit in custody — "keys unavailable" would name the wrong fix), and in `pullIgnoringMarker()` so
  `pull()` and `pullToHead()` are both gated. Refuses ONLY when both facts answer and disagree (an unbound library or
  a signed-out session is some other state's business).
- The wiring: `NewRoadSyncKeyProvider.boundAccount` (the SAME truth `currentKeys` reads — the record's account);
  `SyncSession.configure(accountBinding:)`; `AppServices` takes `boundAccountRead` and builds the binding with the
  signed-in side from its own auth session; `VariorumApp` passes the read on the NEW ROAD ONLY — today's road passes
  nothing, so the gate is inert there and Release is byte-unchanged until VX-329 (the phase's one law; the phone's
  composition passes nothing either — the gate arrives there with mobile's new-road wiring, the parity line).
- The face: `SyncRowFace.Kind.accountMismatch` + the EXACT-match detector (`isAccountMismatchError`, the
  `isKeysLockedError` exactness rule), the row arm (paused, warning-styled, the engine's sentence on hover, one door
  "Account…"), the label *Sync paused — this library belongs to a different account* (PROVISIONAL P-VX308-314-1 with
  the engine sentence P-VX308-314-2).

**Pins (`Tests/VariorumCoreTests/AccountBindingGateTests.swift`, 2; + the harness gains `SyncClient.accountBinding`,
nil default — every existing suite byte-untouched):** a mismatched sign-in refuses BOTH halves and `pullToHead`, the
outbox byte-intact, the cursor unmoved, nothing pushed past the refusal, and the SAME client heals with no state
surgery when the sign-in matches; nil-anywhere leaves the gate inert (all three arms). **MUTATION (red-on-old in
effect):** the gate neutered -> `✘ … 6 issues` (the second note reached the server, the cursor moved — VX-314's bug
live); restored `cmp`-identical; the suite + the lockstep neighbors `✔ 5 tests in 2 suites`.

**Counts:** full core Debug `✔ 3311 tests in 430 suites` + the third target `✔ 40/6`; the ONE red is the recorded
VX-353 wall-clock flake (`MCPHarnessTimeLimitTests…`, 19.1 s vs 15 s under the full parallel run; no MCP line in this
diff). The builds, DONE: `swift build -c release` `Build complete!`; Mac `build-for-testing` `** TEST BUILD SUCCEEDED **`
and the Release app build `** BUILD SUCCEEDED **` (one Sendable annotation owed on the composition-root closure —
fixed, the rebuild green); the phone `** BUILD SUCCEEDED **`.
The SyncStatusViews face pins (`PostureSwitchTests` · `SyncStalledRowTests` · `EncryptionFlowTests` ·
`TierAndOnboardingTests`) ride the NEXT stage batch's list.

### U2 RECORD — THE JOIN AND THE FOLLOW FACES (Opus implementer, 2026-10-19; VX-418's second half + VX-107 + VX-113 — BUILT; the Mac suites and the walk PENDING)

**Not done in U2, first:**
- **No Mac suite was RUN and no walk was made** (the brief: headless + `build-for-testing` only — no `xcodebuild test`, no
  stage, no Debug launch, no store touch). The Mac suites were BUILT (`build-for-testing` green); the list and the walk
  recipe below are the orchestrator's. What DID run: every new suite but the Mac-only one HEADLESS in this session's
  SwiftPM harness over the real `Shared/Protection/` files (225 / 34), and the core's protection set in both
  configurations (no core file changed — zero `Sources/`, `Server/` or `Sync/` lines). No live network call anywhere.
- **The key doors are U3's** (VX-113's "changed elsewhere" therefore has no in-app road to MAKE the change this phase —
  it is pinned over the planted vault, and its walk waits for U3's Change Passphrase door). **The phone** has no account
  section (the brains are shared; MOBILE PARITY below). **Today's road** is untouched.
- **A join that stops past its swap** is finished by the next open's settle with no receipt and no words moment (F-U2-2 —
  routed, not built: VX-107's class for the join, outside this unit's rows).
- The canon delta and the QUESTIONS bundle rows are the closeout's (the shared-ledger rule); the PROVISIONALs are below.

**Preflight (complete, not delegated):** CLAUDE.md + its canon; the resiliency protocol; CastleRules WHOLE; SyncSpec WHOLE;
SurfaceContracts (the app + Doors/protection); this plan whole (§1–§5d, the §6 U1 RECORD + its arbitration + Mac batch, the
VX-314 RECORD, §7); VX-307 §5a–§5e + §6 (the U1 wire record, the U2a record + fix leg, the U2b record — `WordsLookPanel`'s
idiom — the U2c record, THE WALK RECORD); the lifecycle page (stage 12 and the rest); QUESTIONS #205 (her ruling (ii)),
#235's HER RULINGS block, P-VX378-U2-3 (QUESTIONS + the VX-378 plan's adjudication 2); the core (`Follow.swift`,
`CommonSteps.swift`, `AccountActs.swift`, `Assess.swift`, `Assessment.swift`, `Facts.swift`, `Executor.swift`,
`PlanRunner.swift`, `EnterCastle.swift`, `VaultModel.swift`, `DeviceSection.swift`, `AccountVaultClient.day`); the shared
faces (`RoadAccountFaces`, `RoadAccountModel`, `ProtectionAccountActs`, `ProtectionSheetPresenter`, `RoadCrossingFaces`,
`RoadCrossingsModel`, `ProtectionCrossingActs`, `ProtectionOpenRoad`, `ProtectionOpenFaces`, `ProtectionWords`,
`ProtectionSystem`, `ProtectionFactsGatherer`, `WordsBand`), the Mac faces (`RoadAccountSheet`, `RoadCrossingSheet`,
`WordsBandCard`), `AppBootstrap`'s new-road arms (`finish`, `crossOnNewRoad`, `crossingRoads`, `accountRoads`), today's
follow (`PostureFollowModel`, the controller's `FollowNotice`, `PostureCopy`'s follow lines — the VX-107 precedent), and the
U1 suites + support the extension rides (`PlantedRoad`, `PlantedVaultLeaf`, `PlantedSyncKeysLeaf`, the account and
crossing road suites). HARNESS BASELINE (this session's scratchpad package `u1-harness`, U1's recipe pointed at this
worktree, the tree at `d6595ba6d`): `✔ Test run with 192 tests in 30 suites passed`.

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U2-1 — THE FOLLOW'S PLACEMENT: THE PLAN'S IDIOM FITS — THE PANE.** `assess` owes `OwedAct.follow` only over facts
  carrying a FRESH vault reading (`Assess.acts`: `if let vault, let reading`); the open's facts carry none (`ProtectionFacts
  Gatherer`: `vault: nil`, P-VX306-K3), so the interlude can never see a follow — the ONE place the owed act is read is the
  pane's one read (U1's R-2, `ProtectionPaneRead.read`). So the follow surfaces there, in U2a's idiom exactly: the account
  section renders `assess`'s `followNow` door (its notice in its place, the door's press a confirm through the one presenter
  asking exactly `spec.requires` — one secret into Castle and on a replaced key, with the gate choice into Castle; nothing
  out of Castle), and the act runs through the bootstrap's crossing seam (every follow re-keys — `FollowProgram` always runs
  `LibraryRekey`, so the app's pool closes and reopens around it, as a crossing's does). No second arm is built.
- **R-U2-2 — THE JOIN'S RE-KEYING ARMS RIDE THE SAME SEAM.** `join` re-keys exactly when it crosses postures
  (`rekeys = join != .sameMode` — `entersCastle`/`leavesCastle`); those run through the crossing seam (pool closed, reopen);
  a `sameMode` join changes no key (`joinKeyFile` + `bindAccount`) and runs on the open session like U1's set-up
  (P-VX308-U1-6's precedent). The seam is ONE (extracted from `crossOnNewRoad`, its order of operations unchanged), never a
  sibling.
- **R-U2-3 — A TYPO NEVER TEARS THE WINDOW DOWN, synced too.** U2a's preflight checks the typed pair against the live key
  file before the teardown, but leaves a synced crossing's pair to the act. The join's and the follow's typed secret is the
  ACCOUNT's, so their preflight checks it against the vault the pane's one read fetched (a READ — the same derivation and
  the same refusals the core's `join`/`follow` make before `perform`, VX-113's `passphraseChangedElsewhere` among them),
  before anything closes.
- **R-U2-4 — VX-107 ON THE NEW ROAD: the Done is re-said from durable facts.** A follow that stops past its swap is
  finished by an open's settle (`SettleOutcome.resumed`/`.finishedFromRecord`, `act == .follow`), whose `ActOutcome` carries
  only the notices of the steps THAT run ran (`.followedOutOfCastle` is appended at `memory` — lost when a crash came after
  it: VX-107's class exactly). The face reads the follow's kind the way the core's own plan-less finish does
  (`FollowProgram.finishingSteps`: the act in flight's `fromKind` against the record's mode) — the act in flight as the
  unlock read it from the record (sealed in the library), the mode after the settle — never this process's memory and never
  the outcome's notices alone.
- **R-U2-5 — THE WORDS MOMENT (rule 7; P-VX378-U2-3 (a) stands):** after a join whose outcome says
  `.wordsReplacedByAccount`, the confirm turns into the moment: words TYPED → rule 7's sentence (hers, verbatim) over the
  one look idiom (`WordsLookPanel` — the typed words, numbered, never selectable, privacy-sensitive, its Copy through the
  existing `copyWords` road — no new clipboard road; VX-448 is U3's), closed behind her warning; the PASSPHRASE typed → the
  notice that the words were replaced, WITHOUT showing them (a PROVISIONAL sentence — the "here they are" edge flagged for
  her bundle). The typed words live only in the confirm's model and go with it.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton + the readings: DONE (this commit).
- Piece 1 — THE WORDS: DONE (`af7df2220`). `ProtectionWords`' VX-308 U2 section: the join's lead (the lifecycle page's
  stage 12), its plan lines (`JoinPlan` — the consent says which) and receipts (the posture said where it changed), the
  passphrase-typed words moment (`joinWordsNotShown` — the words replaced, NOT shown: P-VX378-U2-3 (a), her eye flagged),
  Move's door/title/lead/button, the follow's door/title/button, its notice by kind (the vault's last writer and day),
  its ask (rule 10's once; rule 12's quietly), rule 10's "said plainly", its fields, and VX-107's Done by kind (the
  other-device sentence). Her sentences the faces say are the ones already in the file (rule 7 ×2, rule 12's leave sentence,
  rule 9's promise, rule 16) and VX-113's is U2a's `passphraseChangedElsewhere` (her #205 (ii) form). All new lines
  PROVISIONAL P-VX308-U2-1. Pins `RoadJoinFollowWordsTests` (6: her sentences re-read against the rules file; VX-113's three
  forms; VX-107's Done names the other device for every kind; the notice and the join as drafted; no line shouts) —
  HEADLESS `✔ 13 tests in 2 suites` (with U1's words suite). MUTATION (the out-follow's Done stripped of its other-device
  sentence) → `✘ … with 2 issues`, restored `cmp`-identical.
- Piece 2 — THE FACES: DONE (`99c4f7a15`). `RoadAccountFaces` (pure, from `assess` over the pane's one read): turning sync
  on into an account that ALREADY syncs is THE JOIN (`joinDoor`: Move's leave first where it is Move — rule 16 — then the
  join's lead and rule 7's first sentence, the plan line; into Castle Use Castle's own words — rule 9's promise, what entering
  does, the spec's floor / export-first / rule 25's copies / export-off — and the gate choice; out of Castle rule 12's
  sentence via the spec's `ruleFive`; ONE secret, rule 14); MOVE (`.moveToSignedInAccount` — the door names the account
  signed in; that account's vault unreadable → said; no vault there → the honest not-yet line, P-VX308-U2-6); THE FOLLOW
  (`.follow` — the door `assess` opens, its kind the owed act's: the notice, rule 10's line into Castle, rule 12's out of
  it, what it asks, rule 11's export line into Castle when this Mac's export is on; one secret into Castle and on a replaced
  key with the gate into Castle, nothing out of it). `RoadAccountDoorOpen` gains `gate` / `follow` / `notice` / `label` /
  `undeletableCopies` (defaulted — every U1 construction unchanged) and `rekeys` + `receipt` (the follow's Done — VX-107 —,
  a join's, else the door's). VX-113: `actRefusalSentence` names `passphraseChangedElsewhere(device:day:)` (her #205 (ii);
  the day the wire's `updated_at`) and `signedOutUseThisMacOnly`. Rule 25's copy names moved into one helper
  (`ProtectionCrossings.copyName`, Use Castle's and the join's). U1's join not-yet line RETIRED; two U1 pins FLIPPED
  DELIBERATELY (`RoadAccountFacesTests.signedInWithAVaultTurningSyncOnIsTheJoin` — U1's target pin; `ProtectionAccountRoad
  Tests.theDoorIsReReadAtThePress` — set-up → join now RE-SHOWS the changed door, VX-108, where U1 refused it closed);
  `RoadAccountSurfaceTests`' shape list and U1's words list follow the retired line. Pins `RoadJoinFollowFacesTests` (9).
  HEADLESS, the whole harness: `✔ Test run with 207 tests in 32 suites passed`. MUTATIONS (restored `cmp`-identical): the
  follow's face withheld (the pre-U2 face) → `✘ … with 3 issues`; VX-113's arm removed from the map → `✘ … with 2 issues`.
- Piece 3 — THE ACTS: DONE (`ed7beb995`). `ProtectionAccountRoad.perform` (the caller holds the one-act lock; for a
  re-keying act the app's pool is closed — piece 5's seam): the sign-in NOW adopted (R-2); into Castle (a join entering it,
  the follow into it) rule 11 FIRST through U2a's one home — the durable notice mark (`ProtectionCrossings
  .markCastleEntry`) and the weekly switch mirrored into the sealed setting (`mirroredExportSettings`; both extracted from
  `cross`, its order unchanged, Use Castle's pins green) — then the core's act: `setUpSync` or, the account already
  syncing, `enroll` (the join); `move`; `follow` (its kind the shown door's); `leaveAccount`; before a swap a refusal leaves
  the library under its old key (the mark cleared); PAST the swap the act LANDED (`AccountActResult.landedWhole` false —
  its Done owed to the next open's settle, VX-107's road), the switch following the act's own notice. U1's `act` is now a
  thin wrapper over it; `press` (the open session) refuses a re-keying door — never re-keyed under an open pool. THE
  PREFLIGHT (`preflight`, R-U2-3 — READS only): the door re-read through the pane's one read (VX-108), then the typed
  secret against the vault that read fetched (`ProtectionPaneFacts.snapshot`, new): the same derivation and refusals the
  core's `join`/`follow` make before their plans (a join's each typed secret must open it; the follow's passphrase when
  typed, else its words; an old passphrase whose lock is no longer the vault's names the change — VX-113), said through
  the act's own refusal map. VX-107: the open captures the act in flight BEFORE its settle; `RoadSettledFollow.kind`
  reads a finished follow's kind from durable facts (`fromKind` against the record's mode after — `FollowProgram
  .finishingSteps`' own reading; never the outcome's notices, never memory) into `RoadOpenReport.settledFollow`, and
  `RoadStandingFaces` owes `followDone(kind)` among the open's receipts. `RoadAccountPress.made` gains `receipt: String?`
  (nil — owed to the reopen) and `wordsReplaced` (rule 7's moment owed). Pins `ProtectionJoinFollowRoadTests` (12: the
  same-posture join adopting the account's pair, words typed and passphrase typed; a wrong secret writing nothing; the join
  INTO a Castle account entering Castle — the preflight refusing three typos with nothing written, the new key with the
  old in its history, no silent item, the Apple key retired, rule 11's export off + notice owed; the join OUT of Castle; Move
  — the old account's keys forgotten, the key kept; the follow into Castle — one secret, the gate, the new sync key followed,
  rule 11 for the follower, nothing owed after; the quiet follow out; the lagged library catching up; VX-113 — the old
  passphrase names "Studio Mac" and the day, the preflight's sentence IS the core act's own (`passphraseChangedElsewhere`
  with the same facts, nothing written), the new passphrase follows; VX-107 — the double crash into and out of Castle (the
  act stops past its swap in process, the first relaunch's settle stops again and says nothing, the second finishes and
  says the Done ONCE with its other-device sentence); `RoadSettledFollow`'s durable reading, pure). HEADLESS, the whole
  harness: `✔ Test run with 219 tests in 33 suites passed`. MUTATIONS (each on the committed tree, restored `cmp`-identical):
  A — the Done read from the outcome's NOTICES (the fragile face — VX-107's class) → `✘ … with 7 issues` (both double-crash
  arms + the pure reading); B — the pre-U2 open (no settled follow) → `✘ … with 4 issues`; C — VX-113's arm off the
  preflight → `✘ … with 1 issue`; D — the preflight's secret check skipped → `✘ … with 3 issues`; E — rule 11 not run
  around the follow into Castle → `✘ … with 1 issue`. **VX-107's red-on-old, in effect:** B is the pre-fix behaviour
  (the settle's follow said nothing — the Done lost whole); A is today's road's failure shape on the new road (a face that
  reads what the resume happened to say loses it at the second crash).
- Piece 4 — THE MODELS: DONE (`18cd0123e`). `RoadAccountConfirmModel`: ONE secret where the door asks it (rule 14 — the
  passphrase, the words, or both, as typed; the words' shape checked before the road is asked; never a new secret); the
  gate choice into Castle carried to the road (`RoadAccountRequest.gate`; a re-shown door with no Touch ID falls back to
  Always ask); THE WORDS MOMENT (R-U2-5): a join whose outcome says `wordsReplacedByAccount` keeps its sheet — the act's
  `landed` (its receipt, the pane's re-read) runs at once, then `moment` = `.shown(WordsLookModel)` (the typed words via a
  mint that hands them back — nothing minted, nothing stored, `saysRuleSix` false, Copy through the injected words road)
  closed behind the look's own warning, or `.notShown` (the passphrase typed) closed by OK; a window closing under it
  closes it (the act had landed — never a "nothing written" cancel); rule 7's hand-up (set-up) and a join whose words
  were already the library's show nothing. `RoadAccountModel.open` speaks a landed act's receipt ONCE (at the landing, or
  at the close when no moment stands). `RoadAccountRoads.copyWords` (new; default nothing). Pins `RoadJoinFollowModelTests`
  (6). HEADLESS, the whole harness: `✔ Test run with 225 tests in 34 suites passed`. MUTATIONS (restored `cmp`-identical):
  the moment never opened → `✘ … with 4 issues`; one secret's words dropped when a passphrase is typed → `✘ … with 1 issue`.
- Piece 5 — THE MAC FACES + THE ONE REOPENING SEAM: DONE (`eea4b5892`). `AppBootstrap`: `crossOnNewRoad`'s seam
  EXTRACTED into `reopenAround` (its order exactly the crossing's: `onWillLock`, `.opening`, the resident and per-open state
  dropped, the pool closed through the binding, the act off-main, `endAct`, the owed receipts handed to the reopen, the
  reopen through the new road with the key that opens the slot, Settings asked back) — `crossOnNewRoad` now calls it
  (behaviour unchanged) and so does the new `accountActOnNewRoad` (a join across postures and every follow — R-U2-2): the
  preflight first (R-U2-3), then `ProtectionAccountRoad.perform` inside the seam, its receipt owed to the reopen only when
  it landed WHOLE (else the reopen's settle says the follow's Done — VX-107, never twice), the press answering with no
  receipt of its own. `accountRoads()` routes a re-keying door there and hands the words moment the Mac's ONE words
  clipboard rule (`Self.copyWords` → `WordsClipboard.copy` — the card's own road; U3's VX-448 changes it for every look at
  once). `RoadAccountSheet.swift`: the section renders the follow FIRST with its notice beside its door, the join and
  Move as doors (Move's not-yet arm in its own row; U1's separate not-yet row retired); the confirm asks one secret (the
  account's fields for a join/Move, this library's for the follow), the gate choice (the crossings' own), rule 25's copies
  bulleted, her sentences (rules 16, 12, 9) in the primary ink, and rule 7's moment (`WordsLookPanel` under her sentence
  in the primary ink, or the notice alone with OK; `interactiveDismissDisabled` while it stands). Mac suite
  `RoadJoinFollowSurfaceTests` (5: the section's new shapes hosted; each new sheet shape hosted — one secret with and
  without Touch ID, the follow out, both moments; the moment's one-look idiom by source, no raw pasteboard; THE FOLLOW
  THROUGH THE SEAM via `AppBootstrap` over the planted road — a same-posture join on the open session with its notice-only
  moment, the account's other device entering Castle, the follow's press closing the pool and reopening in Castle under a
  new key, the reopened window's status seam saying the Done ONCE; VX-107 THROUGH THE SEAM — the follow stopped past its
  swap, the reopen's settle finishing it and saying the Done once, by the settle, never the press) — BUILT, the RUN
  PENDING under the stage. `build-for-testing` → `** TEST BUILD SUCCEEDED **`, no warning in a touched file.
- Piece 6 — THE CLOSE: DONE (this commit) — the counts, the Mac-suite list, the walk recipe, the PROVISIONALs and the
  findings below.
- No revert is in flight (every mutation ran on a committed tree and was restored by `git checkout --`, `cmp`-checked
  against a pre-mutation copy; no scratch worktree).

**THE FACES AS BUILT (for the ladder):** the pane's one read (U1's — the sign-in now, a fresh vault read; it now also
keeps the vault row it fetched, `ProtectionPaneFacts.snapshot`) feeds `RoadAccountFaces.derive`: turning sync on into an
account that already syncs is the JOIN door (`joinDoor` — the plan said at the consent, one secret, the gate into
Castle), another account signed in gives MOVE (the same door shape behind rule 16's leave; no vault there → not yet),
and in sync with the account moved elsewhere the FOLLOW door (`followDoor` — its notice, rule 10's or rule 12's
sentence, its ask, the gate into Castle). A press: the confirm composes exactly the ask (one secret) and the gate; a door
that changes no key (set-up, a same-posture join or Move, the leaves) runs `ProtectionAccountRoad.press` on the open
session (re-read, then `perform`); a re-keying door (`spec.rekeys` — a join across postures, every follow) runs
`AppBootstrap.accountActOnNewRoad`: `ProtectionAccountRoad.preflight` (the door re-read, the typed secret against the
vault row — the core's own refusals, VX-113's among them; all reads), then `reopenAround` (the crossing's one seam) around
`perform` (rule 11 first when it enters Castle; the core's `enroll`/`move`/`follow`), the receipt owed to the reopen. A
join whose words were replaced keeps its sheet for rule 7's moment. VX-107: every open on the new road reads the act in
flight before its settle, and a settle that finished a follow (`RoadSettledFollow.kind` — `fromKind` against the mode
after) owes `followDone(kind)` among the open's receipts. ZERO `Sources/`, `Sync/`, `Server/`, schema or dependency lines;
no new core act.

**COUNTS (the final tree — `eea4b5892` + this record):**
- HEADLESS HARNESS (this session's scratchpad package `u1-harness` — U1's recipe pointed at this worktree: tools 6.2, macOS
  26, the app's concurrency settings, the worktree's core by path; its `Variorum` target symlinks every
  `Shared/Protection/*.swift` but `ProtectionBackupHook.swift` and `WireVaultLeaf.swift`, plus `Shared/LibraryOpenCopy
  .swift`, plus the U2c stub file + `ProtectionCopy`'s three sign-out strings; its test target symlinks U1's set (the
  baseline `✔ 192 tests in 30 suites` on `d6595ba6d`) plus this unit's `RoadJoinFollowWordsTests`,
  `RoadJoinFollowFacesTests`, `ProtectionJoinFollowRoadTests`, `RoadJoinFollowModelTests`): **`✔ Test run with 225 tests in
  34 suites passed`** (192 + 6 + 9 + 12 + 6; U1's two flipped pins inside the 192).
- MUTATIONS (each on a committed tree, restored `cmp`-identical — the pieces' lines above): piece 1 (1), piece 2 (2),
  piece 3 (5 — VX-107's two behavioural reverts among them), piece 4 (2). Every one red.
- The core's protection set (the 82 `@Suite` types under `Tests/VariorumCoreTests/Protection` — U1's filter; no core file
  changed): Debug `✔ Test run with 334 tests in 82 suites passed after 6.104 seconds.`; Release (`swift test -c release`,
  the same filter) `✔ Test run with 310 tests in 78 suites passed after 4.535 seconds.`
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (no warning in a touched file); the phone `-scheme VariorumMobile
  -destination 'generic/platform=iOS Simulator' -configuration Debug -derivedDataPath DerivedData/vx308 build` → `** BUILD
  SUCCEEDED **`; **the Release check `-configuration Release build` → `** BUILD SUCCEEDED **`**.
- Release behaviour: unchanged by construction — every new line sits behind `roadStanding`/`roadAccount`/`newRoad` (nil
  or false on today's road), or in the new road's open (`ProtectionOpenRoad`, reached only behind the switch); the
  extraction of `reopenAround` serves only new-road acts. The binary is not byte-identical (rule 24's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308 test \
  -only-testing:VariorumTests/RoadJoinFollowSurfaceTests \
  -only-testing:VariorumTests/RoadJoinFollowWordsTests \
  -only-testing:VariorumTests/RoadJoinFollowFacesTests \
  -only-testing:VariorumTests/ProtectionJoinFollowRoadTests \
  -only-testing:VariorumTests/RoadJoinFollowModelTests \
  -only-testing:VariorumTests/RoadAccountWordsTests \
  -only-testing:VariorumTests/RoadAccountFacesTests \
  -only-testing:VariorumTests/ProtectionAccountRoadTests \
  -only-testing:VariorumTests/RoadAccountModelTests \
  -only-testing:VariorumTests/RoadAccountSurfaceTests \
  -only-testing:VariorumTests/ProtectionAccountRouteTests \
  -only-testing:VariorumTests/ProtectionSheetPresenterTests \
  -only-testing:VariorumTests/FollowingSessionProviderTests \
  -only-testing:VariorumTests/RoadCrossingFacesTests \
  -only-testing:VariorumTests/RoadCrossingWordsTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/RoadRearmTests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/ProtectionTierFaceTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/PostureSwitchTests \
  -only-testing:VariorumTests/SyncStalledRowTests \
  -only-testing:VariorumTests/EncryptionFlowTests \
  -only-testing:VariorumTests/TierAndOnboardingTests
```
The first five are U2's (5 + 6 + 9 + 12 + 6 = **38 tests**; `RoadJoinFollowSurfaceTests`' two seam pins need the signed
test host — a planted road, no keychain, the planted vault; the four headless ones also ran green in the harness). Then
U1's suites this unit touched (two pins flipped deliberately, one shape line, the retired line's list) and their
neighbours; U2a's crossing suites (the seam's extraction and the two rule-11 helpers `cross` now shares —
`ProtectionCrossingRouteTests` exercises the seam through the bootstrap); the open road's suites (its report and standing
faces gained the settled follow); the words band (the look the moment rides); the pane and bootstrap neighbours; the
source pins over edited files; and **the orchestrator's VX-314 status-face change riding this batch: `PostureSwitchTests`
· `SyncStalledRowTests` · `EncryptionFlowTests` · `TierAndOnboardingTests`**. `VX310TodayLobbyWitnessTests` still reports
its KNOWN ISSUES (a pass of either is a FAILURE); read the `skipped:` lines. **The optional red legs:** VX-107 through the
bootstrap — in `ProtectionOpenRoad.open` replace the `report.settledFollow = RoadSettledFollow.kind(…)` assignment with
nothing (the pre-U2 open) → `RoadJoinFollowSurfaceTests.vx107_aFollowStoppedPastItsSwapIsSaidOnceByTheReopensSettle`
red (nothing said), restore by `git checkout --`.

**THE WALK RECIPE (the orchestrator's, under a held stage claim; the DEV STORE only; against the THROWAWAY project with
U1's walk door — `VARIORUM_WALK_PROJECT_URL` + `VARIORUM_WALK_ANON_KEY` from `~/.variorum/dev-vault-throwaway.env`, never
echoed; light and dark where a face changed; never the production mirror):**
0. U1's recipe rows 0–2 (zero Debug instances by path; build; launch the binary with the walk's door; `source` the dev
   pair and `export`; sign in as throwaway account A; *Turn on sync…* — the set-up with the dev pair — so A's vault holds
   the dev pair). **Caveat for every row below:** two libraries on ONE Mac share the dev scope's sync-keys items (keyed by
   account) — a library set aside does not take its sync keys with it; the core reads them by account. Expected and
   harmless here (the libraries are the same account's devices).
1. **The join, the passphrase typed (the notice-only moment).** U1's rows 3–4 (sign out; the signed-out road's *Use this
   Mac only…* → the library local again). Sign in as A → Settings ▸ Protection ▸ Sync: *Turn on sync…* now opens THE JOIN
   — *Your account already syncs. Type its passphrase or its twelve words once — …*, *A device holds one pair of secrets
   at a time.*, *Your account is in Standard, like this library.*, the two fields *Your account's passphrase* / *Or your
   account's twelve words*. Capture (light, dark). A WRONG passphrase → refused in place, the window never closes. The dev
   PASSPHRASE → the sheet turns into the moment: *Your library's twelve words are now your account's twelve words — the
   ones you keep for your account. You joined with your passphrase, …* · *OK* (capture); the status line *Sync is on. Your
   library uses your account's passphrase and twelve words now.*; the section: in sync. (The dev words still open it —
   they ARE the account's; the edge F-U2-1 names.)
2. **The follow into Castle, then out (one Mac, two libraries — the account's "other device" is a throwaway library B).**
   Quit. Library A aside whole (U2b's walk row 1 — `mkdir -p ~/vx308-walk/A && mv` the slot, its sidecars and key files);
   launch → *Start a New Library* → B; Settings ▸ Protection ▸ Sync → signed in as A → *Turn on sync…* = the join → the
   dev passphrase → B joins A (the notice-only moment → OK). B: *Use Castle…* (synced — account-wide; both secrets: the dev
   pair; Always ask) → B in Castle; the account in Castle. Quit; B aside (`~/vx308-walk/B`), A back (rule 21's
   different-library notice once → OK). A's Settings ▸ Protection: the crossings say *Your account changed on another
   device. Follow it first.*; Sync says *Your account entered Castle on <this Mac's name> on <today>.*, *Until this Mac
   follows, it can still read what it already has — …*, *Follow your account…*. Capture (light, dark). Press → the
   confirm: the notice lines, *Type your passphrase or your twelve words once to follow it here.*, the gate choice, *Your
   passphrase* / *Or your twelve words*. A WRONG passphrase → refused in place. The dev passphrase (*Always ask*) → the
   window reopens → the status line *Your account entered Castle on another device, and this Mac followed it.*; Settings
   on Protection: *You're in Castle.*; Sync: in sync, no follow. Capture. Log: `follow: done #N under …`, `road: follow —
   library … now names account …, castle under …`. Then the follow OUT: quit; A aside, B back → B: *Use Standard…* (both
   secrets) → quit; B aside, A back → Sync: *Your account left Castle on <…> on <…>.*, rule 12's sentence *Your library and
   all your backups will open through your Apple account and this Mac again; if you want Castle-era writing to stay
   Castle-protected, don't leave.*, *This Mac follows it out without asking you for anything.*, *Follow your account…* →
   the confirm with NO fields → *Follow* → the reopen → *Your account left Castle on another device, and this Mac followed
   it out.*; *You're in Standard.*; the live key file has an `"apple"` wrap again. Capture each.
3. **(Optional) the shown moment — on THROWAWAY words only, never the dev pair on screen:** a throwaway account C set up by
   a throwaway library (words minted by its card's look and kept nowhere but the walker's head for the minute), then a
   second throwaway library joining C typing those WORDS → the moment shows them in two columns under rule 7's sentence
   (her words), *Copy* (the existing 60-second rule — U3 changes it), *I've written them down* → her warning → *Close*.
   Capture. Both throwaway libraries aside afterwards.
4. **Posture after the window:** A back in place, LOCAL (Settings ▸ Sync ▸ *Stop syncing here…* — rule 16, no key or secret
   change) in Standard, the dev pair unchanged (no key door ran; the passphrase-typed join adopted the account's pair,
   which IS the dev pair), **SIGNED OUT before the last quit** (F-U1-5); B (and any throwaway library) aside under
   `~/vx308-walk/`, removed at closeout; the throwaway accounts hers with the project. VX-113's walk waits for U3's
   Change Passphrase door (pinned over the planted vault here).

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX308-U2-1 — the join's and the follow's undrafted words** (`ProtectionWords`' VX-308 U2 section): the join's lead,
  its plan lines, its fields, its receipts; the passphrase-typed moment's sentence and *OK*; Move's door/title/lead/button;
  the follow's door/title/button, its notice, its ask, rule 10's line, its fields, its Done by kind. HER sentences verbatim
  (pinned): rule 7 ×2, rule 12's leave sentence, rule 9's promise, rule 16; VX-113's form her #205 (ii). (b) blank until her
  sitting; (c) other words.
- **P-VX308-U2-2 — where the follow surfaces: the pane** (R-U2-1 — the one read that sees it; the account section, the
  follow first with its notice). (a) BUILT; (b) also a calm bar on the open library pointing at the pane (an owed follow is
  otherwise seen only when she opens Settings ▸ Protection — F-U2-4); (c) the interlude at the open (needs a vault read at
  every open — P-VX306-K3 lifted).
- **P-VX308-U2-3 — the quiet follow out is a PRESS with nothing typed** (rule 12's "quietly" read as "typing nothing": the
  door, a confirm with no field saying rule 12's sentence, one button). (a) BUILT; (b) run at once when the pane's read
  finds it (an act on a read — R-2 forbids; and the window reopens under her on opening Settings); (c) run at the next open
  (a vault read at the open — (c) of P-VX308-U2-2).
- **P-VX308-U2-4 — the words moment's shape** (R-U2-5): (a) BUILT — in the confirm sheet, the typed words over
  `WordsLookPanel` under rule 7's sentence with the look's own Copy (the existing words road) and warning, the passphrase
  typed → the notice + *OK*; (b) no Copy on the moment (she just typed them); (c) the moment as a receipt only (no words
  shown — rule 7's "here they are" unmet).
- **P-VX308-U2-5 — one secret = two fields, either or both** (a join: each typed secret must open the account, both locks
  then the account's; the follow: the passphrase when typed, else the words). (a) BUILT; (b) a choice first (*Enter
  Passphrase…* / *Use Twelve Words…* — today's follow's two doors); (c) the passphrase with a *use your twelve words
  instead* door (the lobby's idiom).
- **P-VX308-U2-6 — Move to an account with NO vault yet: the honest not-yet line** (the core's `move` joins an account that
  already syncs; a leave plus a set-up is two acts and a design of its own). (a) BUILT; (b) compose This-Mac-Only-then-set-up
  as one face; (c) hide the door.
- **P-VX308-U2-7 — the follow's Done is a RECEIPT** on the status seam (`receipt_style` governs it), said at the press when
  the act landed whole and by the open whose settle finished it otherwise (VX-107). (a) BUILT; (b) a durable notice in the
  pane until *OK* (U2a's export-notice idiom — survives `receipt_style` off and a quit); (c) both.
- **P-VX308-U2-8 — the follow's notice names the vault's LAST writer and its day** (decision 34's
  `updated_by_device`/`updated_at` — which may be a later key door's device, not the one that entered Castle). (a) BUILT;
  (b) no device or day; (c) the device only.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U2-1 (her bundle — P-VX378-U2-3's "here they are" edge, with one more corner):** a join typing the PASSPHRASE can never
  show the words (nothing holds them) — the moment says they were replaced without showing them. And the core reports
  `wordsReplacedByAccount` for EVERY passphrase-typed join (`sameWords` is false when no words were typed), so a library
  whose own words already WERE the account's (signed out and back in — rule 16's "signing back in is a join") hears
  "your library's twelve words are now your account's" over the same words. Options for her: keep; have the core compare
  the library's words lock with the vault's recovery wrap (a core line, Fable's); or word the notice to cover both.
- **F-U2-2 (a ticket at closeout — Bug, Confirmed by trace, Castle & sync, Low):** a JOIN that stops past its swap (enroll
  or Move across postures) is finished by the next open's settle with no receipt and no words moment — the typed words died
  with the process (never stored), and `wordsReplacedByAccount` lives in the `memory` step (VX-107's class, for the join).
  Options: the open says a join's receipt from durable facts (the act in flight `enroll`/`move`, the record now naming the
  account) without the words; or accept.
- **F-U2-3 (for U3 — the words card on a synced library):** after a join, the card above the quick entry may still OFFER
  "record the twelve words" (its ledger is per library and the moment does not mark it); a look there mints NEW words,
  and on a synced library the new-words act re-wraps the ACCOUNT too (rule 7's together-change) — replacing the account's
  words she just typed, on every device. U3 owns the synced key doors and the look's road; options: the moment marks the
  card's ledger recorded; the card on a synced library sends her to U3's New Words door.
- **F-U2-4:** an owed follow is discovered only when the pane reads the vault (no vault read at the open — P-VX306-K3); the
  crossings and key doors say "Follow it first" there too. VX-329's live road (rule 15 — a device that has not followed
  cannot sync) is where it becomes urgent; P-VX308-U2-2 (b) is the cheap bridge.
- **F-U2-5 (the walk):** the follow needs another device of the account; the recipe uses two libraries on one Mac (they
  share the dev scope's sync-keys items by account — harmless, said in the recipe).
- **F-U2-6 (MOBILE PARITY):** the phone has no account section — no join, Move or follow face (the brains are shared).
- **F-U2-7 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains, in place, with one pointer to this
  plan: the join (its plan said at the consent, one of the account's secrets, rule 7's words moment — the typed words shown
  once, the passphrase-typed notice), Move, and the follow in the account section (its notice, one secret into Castle and
  on a replaced key, nothing out of it, its Done re-said by the open that finishes it — VX-107), VX-113's sentence, and the
  one reopening seam the re-keying account acts share with the crossings.
- **F-U2-8 (for the ladder — a note):** `RoadAccountDoor.receipt`'s `.follow`/`.moveToSignedInAccount` arms are fallbacks
  no face path reaches (their receipts are the open door's — `RoadAccountDoorOpen.receipt`); kept so the enum stays total.

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree; every mutation ran on a committed
tree and was restored by `git checkout --` (`cmp` against a pre-mutation copy). Commits: `a033de8e1` (0) · `af7df2220` (1) ·
`99c4f7a15` (2) · `bbe2d699c` (record) · `ed7beb995` (3) · `3f5b8479d` (record) · `18cd0123e` (4) · `eea4b5892` (5) · the
close commit.

**U2 ARBITRATION (the orchestrator, 2026-10-19 ~07:15 MDT — repo-first; the dispositions of U2's findings):**
- **F-U2-1** (the words-replaced notice fires on every passphrase-typed join, even one whose library words already
  were the account's — the core cannot verify untyped words): RECORD-ONLY for her bundle — the sentence stays TRUE in
  that case ("your library's twelve words are now your account's twelve words" — they already were); no change.
- **F-U2-2** (a join stopping past its swap is finished by the next open with no receipt and no words moment): a
  TICKET at closeout (Bug, Suspected, Castle & sync, Low) — the moment is a face nicety on a crash corner the core
  already heals; not this phase's.
- **F-U2-3** (after a join, the words card still offers a look; on a SYNCED library a look mints new words and
  re-wraps the ACCOUNT's words everywhere — rule 7 working as designed, but a quiet trap right after she typed the
  account's words): RULED, BUILT IN U3 — every door into the look on a synced library says plainly before minting
  that new words replace the account's words everywhere, one confirm line on the look's ask (PROVISIONAL, her
  bundle); the door is never blocked. The unsynced look is unchanged.
- **F-U2-4..8**: as routed in the U2 record (walk cautions and accepted consequences; nothing to build).
- **P-VX308-U2-1..8**: each built as its stated arm; bundled for her eye with the records' reasoning. P-VX308-U2-7
  (the follow's Done is a receipt, hidden under receipt_style off) is FLAGGED to her beside VX-107 — the other-device
  sentence is the point of the Done; if she wants it always-shown, it becomes a direction, one line.

**THE U2 MAC BATCH (the orchestrator, 2026-10-19 06:45–07:10 MDT, stage claim `vx-308-u2-mac`, the coordinator's GO;
log `vx308-u2-mac-run.log` + `-refix.log`, deleted at closeout):** 324 tests / 48 suites — ZERO expectation failures
beyond the 3 expected `VX310TodayLobbyWitnessTests` witnesses; the VX-314 status-face four ran green in the batch.
The batch's ONE failure was the TEST HOST CRASHING (SIGSEGV, the retired `.ips`'s triggered thread) inside
`PlantedVaultLeaf.fetchVault`'s bare `calls.append` — U1's planted account fakes carried unsynchronized mutable
state, and U2's seam makes the pane's read and an act's read CONCURRENT by design, so the fake corrupted its own
heap mid-`theFollowRunsThroughTheReopeningSeam`. FIXED test-side (`451fdcccb`): both planted fakes' bodies hold one
NSLock (the provider's idiom); the crash itself is the red-on-old in effect; the crashed family re-run `✔ 10 tests
in 3 suites`. 0 instances at release; the stage released with the result line. **U2 IS CLOSED but for the walk and
the ladder.**

### U3 RECORD — THE KEY DOORS' FACES + VX-447 + VX-448 (Opus implementer, 2026-10-19; VX-418's key doors + VX-447 + VX-448 + the F-U2-3 guard — BUILT; the Mac suites and the walk PENDING)

**Not done in U3, first:**
- **No Mac suite was RUN and no walk was made** (the brief: headless + `build-for-testing` only — no `xcodebuild test`, no
  stage, no Debug launch, no store touch). Two Mac-only suites are BUILT (`RoadKeyDoorSurfaceTests`,
  `WordsClipboardLockRouteTests`); every other new suite ran HEADLESS. The list and the walk recipe below are the
  orchestrator's. No live network call anywhere; the dev store, the real store and `/Applications` untouched.
- **A CORE CUSTODY LINE WAS WRITTEN (piece 1 — VX-447's arm, PROVISIONAL P-VX308-U3-1 — the Fable ladder reads it):**
  `KeyDoors.swift` only (the reasoning line by line under THE CORE LINE below); zero `Sync/`, `Server/`, schema or
  dependency lines; `lockstepVersion` 13.
- **VX-448's clear AT THE LOCK walks with U4** — the new road has no lock yet (`canLock` false); the clear sits where U4's
  lock lands (`finish`'s non-ready arm — F-U3-3) and is pinned through `AppBootstrap` (a reopen landing in the lobby).
- **Castle unsynced in rule 27's state is NOT widened** (P-VX308-U3-1 (b) is the alternative): the banner keeps her U2-7
  words there with no door.
- **Today's road is untouched**: its key doors (`KeyDoorView`) and its 60-second `WordsClipboard.copy` retire with it at
  VX-329 (R-U3-6). **The phone** has no key doors, no banner door and no concealed clipboard (F-U3-7 — MOBILE PARITY).
- The canon delta (SurfaceContracts' protection line — F-U3-8) and the QUESTIONS bundle rows are the closeout's.

**Preflight (complete, not delegated):** CLAUDE.md + its canon; the resiliency protocol; CastleRules WHOLE; SyncSpec WHOLE
(the arm writes a custody file and, synced, rides the key door's one vault write — no `Sync/` line); SurfaceContracts (the
app + Doors/protection); this plan whole (§1–§5d, the §6 U1 RECORD + arbitration + Mac batch, the VX-314 RECORD, the U2
RECORD + its arbitration + Mac batch, §7); VX-307 §3a, §5a (the hard limits), §5d, the §6 U2b RECORD + its arbitration
(`WordsLookPanel`, `WordsClipboard`, P-VX307-U2b-1's shape), the U2c record's F-U2c-1 / F-U2c-5 and THE WALK RECORD's
clipboard observation; QUESTIONS #235 (her rulings block — VX-447 / VX-448 verbatim); `phase-13u-feel-and-polish.md`'s
13u2 Copy-all design note (the concealed type's origin); the core (`KeyDoors.swift`, `PlanRunner.swift`, `Executor.swift`,
`CommonSteps.swift`, `AccountActs.swift`, `KeyFile.swift`, `KeyFileCrossings.swift`, `ProtectionRecord.swift`,
`Assessment.swift` — `NoKeyFileAnywhere`, `Fault.noKeyFileAnywhere` — and `Assess.swift`'s two fault arms, the key doors'
gates, `passphraseAsks`); the shared faces (`WordsBand`, `SetPassphraseModel`, `ProtectionWords`, `ProtectionOpenFaces`,
`ProtectionRoadActs`, `ProtectionOpenRoad`, `ProtectionAccountActs`, `RoadAccountFaces`, `RoadAccountModel`,
`RoadCrossingFaces`, `RoadCrossingsModel`, `ProtectionCrossingActs`, `ProtectionSheetPresenter`, `ProtectionSystem`,
`ProtectionBackupHook`, `FileBackupsLeaf`); the Mac faces (`ProtectionRoadBar`, `WordsBandCard`, `RoadAccountSheet`,
`RoadCrossingSheet`, `ProtectionPane`), `AppBootstrap`'s new-road arms (`finish`, `copyWords`, `crossingRoads`,
`accountRoads`, `reopenAround`, `lock`, `canLock`), `VariorumApp`'s ready composition, `VariorumAppDelegate`,
`WordsCopyDoor.swift` (`WordsClipboard`), today's `KeyDoorModel` (the forgot road's presence confirm — the "today's road,
kept" precedent), the test support (`PlantedRoad`, `ProtectionAccountSupport` — the lock rule for new fakes —
`ProtectionFacesSupport`, `ExecutorWorld`, `EX`, `FirstLookWordsTests`, `U2PinsRule27Tests`, `ProtectionRule27FaceTests`,
`ProtectionWordsVX307Tests`, `WordsCopyDoorTests`, `WordsBandSurfaceTests`). HARNESS: U1's scratchpad package `u1-harness`
(this session's scratchpad, pointed at this worktree — the recipe in the U1 RECORD's COUNTS).

**MY READINGS (each the brief's or her ruling's letter as I read it — building on them):**
- **R-U3-1 — THE VX-447 CORE ARM, AS NARROW AS THE STATE.** "The no-live-key-file state with the library open" is rule
  27's after-open fault's FIRST arm (`Assess.repairs`: nothing in the live place, no sealed mirror of the current key, no
  catalogued key file OF the current key, nothing in flight) — read by the act itself (`keyFileGoneEverywhere`, reads
  only; a remembered item's mirror read as stated counts too — conservative), never a guess. In exactly that state
  `regenerateWords` MINTS the key file it then locks (`KeyFile.building` — the current key, the record's epoch; the
  history cannot be carried: every copy that held it is gone, which is what the fault says). Authorization by the one
  secret the state can still check, each arm a TWIN of an existing core authorization: Standard + unsynced → nothing
  asked (the reset door's plain confirm — P-VX307-U2b-1's own twin; no passphrase lock survives anywhere to verify, so
  rule 3's fact reads none); SYNCED (either posture) → the account's passphrase, verified against the vault exactly as the
  synced arm already does, and the fresh file carries the passphrase lock, the new words lock and the master with its
  twelve-words copy (the file as a synced library's is), the vault's words re-wrapped by the act's one CAS write (rule
  7); Castle + unsynced → REFUSED `secretMissing` as today (no lock can verify a passphrase and Castle has no plain
  confirm — PROVISIONAL, options in the record). The SECOND fault arm (another key's file in the live place) is NOT
  widened: minting would write over a stray (rule 21 — never repair by guessing). Every other path byte-unchanged.
- **R-U3-2 — "THE BACKUP FOLLOWS" IS THE FACE'S, AFTER THE MINT.** The core arm writes the key file only; the face, once
  the act returns the words, takes rule 5's PAIR through the one pair road (`takePair` — the backup hook's, moved to a
  harness-visible file, behaviour unchanged). A backup is never a plan step that could fail the mint and lose the words
  before they are shown.
- **R-U3-3 — THE BANNER BECOMES THE DOOR (Mac):** after a quiet open with no key file anywhere and the live place EMPTY,
  `ProtectionRoadBar` says her first U2-7 sentence and the door sentence (the whole line the door — rule 2's "click here"
  idiom), the look (`WordsLookPanel`, one look at a time through the band) inline in the bar; the mint → the fresh key
  file → the pair → a receipt; the banner retires once the look closes over a remade file. The synced flavor adds the
  open-library variant of the account sentence (F-U2c-5). The stray arm keeps her U2-7 words with no door.
- **R-U3-4 — THE LOOK ASKS BY THE CORE'S OWN PASSPHRASE FACT.** `ProtectionRecord.passphraseExists` (a lock on the live
  key file, or the account's) — the record's stamp can be stale in the file-less state (stamped while the file stood), so
  the look would ask a passphrase nothing can verify. In every other state the two agree (the stamp IS that fact).
- **R-U3-5 — THE KEY DOORS (the pane):** `assess`'s three doors over THE PANE'S ONE READ (U1's R-2), presented through THE
  ONE PRESENTER, run on the OPEN session (no swap — the set-passphrase road's precedent; no reopening seam). Change
  passphrase… (current, new twice) and Reset forgotten passphrase… (Standard: the plain confirm; Castle: the words, or
  Touch ID where its item for the current key exists — the press is a READ of that item, today's road's presence confirm
  kept) render only where a passphrase exists (*Set a passphrase…* stands in their place otherwise) and not in rule 27's
  state (they need a key file). NEW WORDS is the Settings words section's door (U2b built it as rule 7's new-words door —
  one door, never two for one act), now reading `.newWords` (its refusal in place). Each door says VX-263's ONE line.
  Synced refusals (`followOwed` / `accountMoved`, `needsFreshVault`) in the pane's idiom (`RoadCrossingFaces`' maps).
- **R-U3-6 — VX-448 ON THE NEW ROAD; TODAY'S ROAD BYTE-UNCHANGED.** `WordsClipboard` (the one home) gains the new road's
  rule — the words as one line PLUS the concealed marker type (`org.nspasteboard.ConcealedType`), no timer, nothing
  restored; held until the library closes behind the lobby (the lock — `AppBootstrap.finish`'s non-ready arm, beside the
  presenter's `libraryClosed`) or the app quits (`applicationWillTerminate`), and cleared then ONLY if the board still
  holds this copy (`changeCount` — her later copy is never erased). Every new-road look rides it (the bootstrap's one
  `copyWords`: the band, the doors' look, U2's join moment). Today's `WordsClipboard.copy` (60 s) stays for today's
  screens, which retire with today's road at VX-329. (The walk's "restore" was never this code's — `clearContents()`
  empties; with the timer gone nothing clears at 60 s at all.)
- **R-U3-7 — F-U2-3 (the architect's ruling):** on a synced library every look (the card, Settings, the tour, the banner)
  asks first and says one line BEFORE minting — new words replace the account's words everywhere; her *Show my twelve
  words* is the yes. U2's join moment (typed words, nothing minted) never says it.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton + the readings: DONE (this commit).
- Piece 1 — THE VX-447 CORE ARM (`KeyDoors.swift`, R-U3-1) + core pins red-on-old: DONE (`577bd53dc`; the pins-first commit
  `8e465f7ea`). Pins `FileLessWordsTests` (6; 7 cases) committed FIRST and RED ON THE PRE-FIX TREE (`✘ … 6 tests in
  1 suite failed … with 3 issues` — Standard `Caught error: .secretMissing`, synced Standard and Castle `.noLiveKeyFile`);
  the arm built → `FileLessWordsTests` + `FirstLookWordsTests` + `ExecutorKeyDoorTests` `✔ 15 tests in 3 suites`. The
  four guard pins are green on both trees by design; MUTATIONS (each on `577bd53dc`, restored by `git checkout --`,
  `cmp`-identical to a pre-mutation copy): M1 the live-place guard dropped → `✘ anyCopyOfTheKeyFileStandingMeansNoMint`
  (2 issues — the stray written over, :171/:174); M2 both mirror guards dropped → the same test red at the mirror arm
  (:147/:150); M3 the catalogue guard dropped → red at the backup arm (:158/:161); M4 the Standard-only guard on the
  file-less nil arm dropped → `✘ castleUnsyncedFileLessStillRefuses` (2 issues); M5 the synced mint without the master
  lock → `✘ aSyncedLibrary…` both postures (4 issues). No revert in flight.
- Piece 2 — THE WORDS: DONE (`5314bb7a6`). `ProtectionWords`' VX-308 U3 section: VX-263's one line (*Your current
  secrets open everything you've made of this library.* — the plan's §2/§5c line as drafted, pinned against the plan
  file); the key doors' names, leads (Standard's plain confirm; Castle's words, or Touch ID where its item stands), fields,
  buttons, receipts; the synced key doors' rule-7 line; F-U2-3's say-before-mint line; VX-447's banner door — her U2-7 (1)
  FIRST SENTENCE REUSED (the prefix of her pinned constant, never restated), the door line, the open-library account
  sentence (F-U2c-5 folded), the remade receipt; VX-448's new-road Copy caption (today's `ProtectionCopy.wordsCopied`
  untouched). All new lines PROVISIONAL P-VX308-U3-2. Pins `RoadKeyDoorWordsTests` (5) — headless with U1's words suite
  and `WordsBandTests` `✔ 24 tests in 3 suites`. MUTATION (VX-263's line reworded) → `✘ vx263sOneLineIsThePlansAsDrafted`
  (2 issues), restored `cmp`-identical.
- Piece 3 — VX-448: DONE (`1b6a7403e`). `WordsClipboard` (the one home, `Shared/WordsCopyDoor.swift`) gains the
  new road's rule: `copyConcealed` (the words as one line + `org.nspasteboard.ConcealedType` with empty data; NO timer;
  nothing restored; the one copy HELD — board + `changeCount`) and `clearHeld` (empties the board only while it still
  holds that copy; lets go either way). `AppBootstrap.copyWords` — the ONE road every new-road look rides (the card, the
  Settings door, the tour, U2's join moment, U3's banner) — is `copyConcealed`; the LOCK's clear (`clearWordsAtLock`) sits
  in `finish`'s non-ready arm beside the presenter's `libraryClosed` (VX-239's rule — a library closed behind the lobby;
  U4's lock lands there — `if newRoad`); the QUIT's in `VariorumAppDelegate.applicationWillTerminate`. Today's
  `WordsClipboard.copy` (60 s) and its screens UNTOUCHED (R-U3-6). `WordsBandSurfaceTests`' bootstrap source pin FLIPPED
  DELIBERATELY (`copy(words)` → `copyConcealed(words)`). Pins `WordsConcealedClipboardTests` (4 — private named boards:
  one line + the concealed type; no timer and nothing restored; the clear empties only its own copy; the three wirings by
  source) — headless (the harness gains `WordsCopyDoor.swift` with two one-line stand-ins for its SwiftUI door's app
  types) `✔ 9 tests in 2 suites` with the words suite. RED-ON-OLD BY BEHAVIOURAL REVERT (the pre-VX-448 wiring: the
  road back to `WordsClipboard.copy`, no clear in `finish` or the delegate) → `✘ everyNewRoadLookRidesIt…` (4 issues),
  restored `cmp`-identical.
- Piece 4 — THE LOOK + THE BANNER'S BRAIN: DONE (`773940c38`). `WordsLookModel` gains `replacesAccountWords` (read at each
  open) and `saysAccountWords`: a SYNCED library's look always asks first and says F-U2-3's line before anything is minted
  (her *Show my twelve words* the yes; Cancel clears it); the band passes it to EVERY look it makes (the card, the tour,
  Settings, the banner); U2's join moment builds its own look and never says it. Every look asks by the core's own fact
  (`ProtectionOpenRoad.lookAsksPassphrase` — `ProtectionRecord.passphraseExists` over the live key file of the key, R-U3-4).
  A look's refusals in the pane's idiom (`lookRefusal` — signed out, another account, the vault out of reach, the account
  moved, an act running, the passphrase changed elsewhere; else U2b's sentence). `RoadStandingFaces.noKeyFileDoor` (the
  fault AND `report.besideIsEmpty`); `RoadStandingModel`: the banner's ONE look (`openNoKeyFileLook` — through the band, so
  one look holds words at a time and recording retires the card's offer), `mintLanded` (any home's mint: when the open
  found no key file anywhere and the key's live file now stands — `keyFileRemade`, the set row re-read, THE BACKUP
  FOLLOWS: rule 5's pair off the main actor through its one road, then ONE receipt), `showsNoKeyFileBanner` (until the
  remade file's look closes — the words never vanish from under her). The pair road (`PairOutcome` + `takePair`) MOVED
  VERBATIM to `ProtectionBackupPair.swift` (diffed byte-equal; the hook's file keeps its `StoreBackup` attachment) so it is
  harness-visible. Pins `NoKeyFileDoorTests` (7 — the Standard door end to end: nothing asked over a stale stamp, the fresh
  file, the banner standing while words show, the pair carrying the fresh file, the receipt, the banner retiring, the next
  open fault-free; the SYNCED door: asked first with the account line, the fresh file with the account's passphrase lock
  and master copy, the vault's words changed; the stray arm — no door, the stray untouched; F-U2-3 on an everyday synced
  library through the real road and unsynced unchanged; the look's pure rule; R-U3-4's fact; the refusal idiom) —
  headless `✔ 23 tests in 3 suites` with `WordsBandTests` + `ProtectionWordsVX307Tests` (U2b's look unchanged). RED-ON-OLD
  BY BEHAVIOURAL REVERT (`KeyDoors.swift` back to `8e465f7ea`, the pre-arm core) → `✘ … 4 issues` (both doors: the look
  refused, nothing written); restored `cmp`-identical. MUTATIONS (restored `cmp`-identical): MF1 the look asks by the
  record's stamp → `✘ theBannersDoorMints…` (2); MF2 the account line never said → 3 tests red (4 issues).
- Piece 5 — THE KEY DOORS: DONE (`07e668e62`). `RoadKeyDoorFaces` (pure — `assess`'s three doors over the pane's one read:
  Change and Reset only where a passphrase exists by the core's fact AND the key's live file stands — *Set a passphrase…*
  in their place otherwise, only New Words in rule 27's state; each says VX-263's line, synced the rule-7 line; Standard's
  forgot road `.plainConfirm`, Castle's `.wordsOrTouchID(touchID:)` — Touch ID where this Mac has its item for the current
  key and a finger; refusals via `RoadCrossingFaces.refusalSentence`). `ProtectionKeyDoorRoad` (the read; the press ON THE
  OPEN SESSION — one act at a time, the door RE-READ (VX-108), the sign-in now adopted (R-2), Castle's Touch ID PRESSED as a
  read of this Mac's item, then `changePassphrase` / `resetPassphrase`; an act stopped mid-plan says the next open finishes
  it). `RoadKeyDoorsModel` (bootstrap-owned; refresh with the crossings' landing rule; `open` presents `.keyDoor` through
  THE ONE PRESENTER — New Words never) + `RoadKeyDoorConfirmModel` (exactly the door's fields; the words' shape first; a
  mismatch refused before the road; a changed door re-shown; the receipt once; the doors re-read). The presenter gains
  `.keyDoor`. The Mac's `RoadKeyDoorSheet` + `RoadKeyDoorsSection` and the host's case landed in the same commit (every
  commit compiles). Pins `RoadKeyDoorRoadTests` (11) + `RoadKeyDoorsModelTests` (3) — headless `✔ 14 tests in 2 suites`
  (one TEST bug fixed before the commit: a discarded `PlantedRoad` freed its temp slot under the read). MUTATIONS
  (restored `cmp`-identical): MK1 the passphrase gate dropped → `✘ thePassphraseDoorsStandOnly…` (1); MK2 the Touch ID
  press skipped → `✘ castlesResetByTouchIDPressesTheItemFirst` (3); MK3 the VX-108 re-read skipped → `✘ vx108_…` (1); MK4
  the sign-in now not adopted (R-2) → `✘ syncedChange…` (4); MK5 the synced rule-7 line never said → `✘ syncedDoorsSay…`
  (1).
- Piece 6 — THE MAC FACES + THE BOOTSTRAP'S WIRING: DONE (this commit). `AppBootstrap`: `roadKeyDoors` made once at the
  first new-road ready beside the account section (the one presenter), `keyDoorRoads()` (read · press on the open session
  off-main · receipt → the status seam · landed → the account section re-read), handed to each open's faces
  (`roadStanding.keyDoors`). `ProtectionPane`: the set row, then `RoadKeyDoorsSection`, then the words section handed the
  key doors (New Words' face — its refusal in place, VX-263's line beside the door), the key doors re-read at each
  appearance. `WordsLookPanel`'s ask says F-U2-3's line above the passphrase field. `ProtectionRoadBar`: THE BANNER IS THE
  DOOR where the place beside is empty — her U2-7 first sentence, the door line as the whole door (rule 2's idiom), the
  look inline in the bar (`WordsLookPanel`), the refusal under it; the stray arm keeps her U2-7 words (`Text(ProtectionWords
  .noKeyFileAfterAQuietOpen)` — `ProtectionWordsVX307Tests`' source pin holds); the account sentence in its open-library
  variant (F-U2c-5). `TravellingDotsIndicatorTests`' surface list gains `RoadKeyDoorSheet.swift`. Mac suites (BUILT, the RUN
  PENDING under the stage): `RoadKeyDoorSurfaceTests` (5 — the section in every shape, each confirm's shape, the words
  section with New Words' face and the synced ask, the banner as the door / with the look / as her words over a stray, the
  composition by source) + `WordsClipboardLockRouteTests` (1 — VX-448's clear AT THE LOCK through `AppBootstrap` over the
  planted road: a private board's concealed copy emptied when the reopen lands in the lobby; red on old by construction —
  the pre-VX-448 bootstrap cleared nothing at the lock). `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`
  (one needless `try` in the new route pin dropped after it; no other warning in a touched file). THE WHOLE HARNESS:
  `✔ Test run with 255 tests in 39 suites passed` (the 225/34 baseline + 30/5 new).
- Piece 6b — THE LOOK ADOPTS THE SIGN-IN NOW: DONE (`15e2979a8`). Self-review found the New Words door's look (U2b's
  `mintFreshWords`) never adopted the sign-in NOW (U1's R-2) — a synced look after a sign-in made since the open would
  refuse "signed out". `mintFreshWords(session:passphrase:signIn:)` adopts it under its one-act lock (nil — every earlier
  caller — keeps the executor's); `RoadStandingModel.make` takes the bootstrap's `signInNow`, every look's mint reading it
  off the main actor. Pinned in `NoKeyFileDoorTests.aSyncedLibrarysLookSaysTheAccountLineBeforeMinting` (an executor
  carrying a stale signed-out sign-in); MUTATION (the adoption removed) → `✘ … 2 issues`, restored `cmp`-identical.
- Piece 6c — P-2 FOR THE BANNER'S DOOR: DONE (`052250050`). Castle unsynced (where the core's arm still refuses) keeps
  her U2-7 banner with NO door (`RoadStandingModel.make` clears `noKeyFileDoor` there). Pin
  `NoKeyFileDoorTests.castleUnsyncedKeepsHerBannerWithNoDoor` (no door; a look from another home refuses; nothing
  written); MUTATION (the gate removed) → `✘ … 2 issues`, restored `cmp`-identical. (`cee78df07`: one redundant `#require`
  — the final build's one warning in a touched file — dropped.)
- Piece 7 — THE CLOSE: DONE (this commit) — the core line, the counts, the Mac-suite list, the walk recipe, the
  PROVISIONALs and the findings below.
- No revert is in flight.

**THE CORE LINE, LINE BY LINE (`Sources/VariorumCore/Protection/Executor/Acts/KeyDoors.swift`, the unit's ONLY core file —
`git diff 8e465f7ea 577bd53dc -- Sources/`; for the Fable ladder):**
1. `KeyDoorProgram.mintsKeyFile` (default false) + `needsLiveKeyFile { !mintsKeyFile }`: the runner's up-front
   `noLiveKeyFile` refusal (`PlanRunner.perform`) is lifted ONLY for an act `regenerateWords` constructed with it — and it
   constructs it only after `keyFileGoneEverywhere` read true. Change and Reset construct none → their precheck is
   byte-unchanged (`true`, the protocol default's own value for those acts). The registry's `program(for:)` builds the
   program WITHOUT it, so a RESUME never mints (see F-U3-2: a words act cannot resume past its begin anyway — no words at a
   settle).
2. The `"keyFile"` step mints ONLY when `mintsKeyFile` AND the act is `.regenerateWords` AND `keyFileGoneEverywhere` reads
   true AT THE STEP (re-read, not trusted from the press — a file written back meanwhile, a mirror restored, means the
   ordinary arm). Otherwise it falls through to the unchanged guard (a stray in the live place → `noLiveKeyFile`, as before).
3. `mintKeyFile`: `KeyFile.building` (the creation's own builder — a NEW file for a key with no past) over the record's
   `libraryID`, the CURRENT key (`ctx.library.key` — never a new key, rule 6) and the record's `keyEpoch`; locks = the new
   words (always — `building` refuses a file the words would not open, rule 2), the passphrase only where the door verified
   one (synced: the vault's descriptor — one descriptor names one passphrase), and synced the master with the vault's
   twelve-words copy AFTER this act's own vault write (`freshVaults` — `noteFresh(written)`; a vault the new words don't
   open refuses `needsFreshVault` rather than writing a file the master can't open). No Apple lock (the key doors re-lock
   nothing else; the next open's `landAppleWrap` / `remakeAppleRoad` re-makes it in Standard — rule 8) and no history
   (every copy that carried rule 4's list is gone — the state itself). Written through the executor's one key-file write;
   the `"memory"` step then makes it this Mac's sealed mirror (rule 1's second home back).
4. `regenerateWords` computes `mints` AFTER `keyDoorParameters` (the synced gates — signed in as the account, a fresh
   vault, the account not moved — run first, unchanged) and BEFORE the secret: the everyday path short-circuits at
   `library.keyFile == nil` (false) with NO extra read.
5. The nil-passphrase arm, minting: Standard AND unsynced only (the reset door's plain confirm, twinned — P-VX307-U2b-1's
   exact twin: this Mac holds the key, the library is open, and no lock survives anywhere to verify a passphrase); Castle
   unsynced and every synced library refuse `secretMissing` exactly as before. Not minting: the U2b guard byte-unchanged.
6. The passphrase arm: synced, verified against the vault exactly as before (`passphraseDoesNotOpen` on a wrong one), then
   `mintsKeyFile: mints && synced`; unsynced, `verifiedPassphrase(against: nil)` refuses `passphraseDoesNotOpen` before any
   write (unchanged — nothing can verify a passphrase there).
7. `keyFileGoneEverywhere` (READS only) — `Assess.repairs`' first `Fault.noKeyFileAnywhere` arm restated over the leaves:
   NOTHING in the live place (the in-hand copy AND a fresh disk read — a stray is the fault's second arm, never widened:
   a mint would write over it, rule 21); no sealed mirror of the current key (the in-hand memory AND every remembered item
   read AS STATED — even an unverified copy refuses the mint: rule 1's restore is its road); no catalogued key file of this
   library carrying the current key (rule 21's offer is its road). A throwing read refuses (never a guess). Any copy
   anywhere means the history it carries is not lost — no fresh file over it. *(Amended at the ladder's round-1 fix
   leg, MINOR-1: "never a guess" holds for the READ; a remembered payload this build cannot DECODE is SKIPPED — read as no
   copy — deliberately and now logged, exactly as the unlock and the open's `refreshMemory` already read it; the trace is
   the ROUND-1 FIX LEG's MINOR-1 disposition.)*
Pins: `FileLessWordsTests` (6 / 7 cases) red on the pre-arm tree (3 issues) and green after; every guard red under its own
mutation (M1–M5, piece 1). The whole core suite green (below).

**THE FACES AS BUILT (for the ladder):** the pane's one read (U1's `ProtectionPaneRead.read`) feeds `RoadKeyDoorFaces.derive`
(`ProtectionKeyDoorRoad.read`); `RoadKeyDoorsModel` (bootstrap-owned beside the account section; `AppBootstrap
.keyDoorRoads`) presents `.keyDoor(RoadKeyDoorConfirmModel)` through the ONE presenter; the press (`ProtectionKeyDoorRoad
.press`, off-main) runs the core's act on the OPEN session — no swap, so no reopening seam. NEW WORDS is the Settings
words section's door (`WordsLookSection`, handed the key doors' model) over U2b's look; every look (card · Settings · tour
· banner) asks by the core's fact (`lookAsksPassphrase`), says F-U2-3's line first when synced, adopts the sign-in now
(`mintFreshWords(…, signIn:)`) and reports its refusals in the pane's idiom (`lookRefusal`). VX-447's banner
(`ProtectionRoadBar`) reads `RoadStandingModel` (`showsNoKeyFileBanner` / `offersNoKeyFileDoor` / `openNoKeyFileLook` /
`mintLanded` — the backup pair through `ProtectionBackupHook.takePair`, moved verbatim to `ProtectionBackupPair.swift`).
VX-448: `WordsClipboard.copyConcealed` / `clearHeld` — the bootstrap's one `copyWords`, `finish`'s non-ready arm, the
delegate's `applicationWillTerminate`. Today's road: every new line sits behind `newRoad` / `roadStanding` / the new road's
models (nil on today's road), or is a no-op there (`clearHeld` holds nothing today's road ever copies).

**COUNTS (the final tree — `cee78df07` + this record):**
- HEADLESS HARNESS (U1's scratchpad package `u1-harness` pointed at this worktree; it now also symlinks
  `Shared/WordsCopyDoor.swift` with two one-line stand-ins for its SwiftUI door's app types and `ProtectionCopy
  .wordsCopied`/`.wordsCopyAll`, and this unit's new `Shared/Protection` files + suites): **`✔ Test run with 256 tests in 39
  suites passed`** (the 225/34 baseline + 31/5 new: `RoadKeyDoorWordsTests` 5, `WordsConcealedClipboardTests` 4,
  `NoKeyFileDoorTests` 8, `RoadKeyDoorRoadTests` 11, `RoadKeyDoorsModelTests` 3).
- CORE: the protection set (U1's 82-suite filter + `FileLessWordsTests`) Debug **`✔ Test run with 340 tests in 83 suites
  passed`**; Release (`swift test -c release`) **`✔ Test run with 316 tests in 79 suites passed`**; THE FULL CORE SUITE,
  Debug (`swift test`): VariorumCoreTests **`✔ Test run with 3317 tests in 431 suites passed after 204.551 seconds`**, the
  third target `✔ 40 tests in 6 suites`, VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — the ONE recorded
  VX-353 wall-clock flake (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 18.7 s
  vs 15 s under the full parallel run); alone `✔ 3 tests in 1 suite`; no MCP line in this diff.
- MUTATIONS (each on a committed tree, restored by `git checkout --`, `cmp`-identical to a pre-mutation copy): piece 1 M1–M5
  (the arm's five guards) · piece 2 (VX-263's line) · piece 3 (the pre-VX-448 wiring, behavioural) · piece 4 (the pre-arm
  core, behavioural; MF1 the stale-stamp ask; MF2 the account line) · piece 5 MK1–MK5 · 6b (the adoption) · 6c (the
  gate). Every one red.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (no warning in a touched file after `cee78df07`); the phone `-scheme
  VariorumMobile -destination 'generic/platform=iOS Simulator' … build` → `** BUILD SUCCEEDED **`; **the Release check
  `-configuration Release build` → `** BUILD SUCCEEDED **`**.
- `SyncSchema.lockstepVersion` 13; zero `Sync/`, `Server/`, schema, migration or dependency lines.

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308 test \
  -only-testing:VariorumTests/RoadKeyDoorSurfaceTests \
  -only-testing:VariorumTests/WordsClipboardLockRouteTests \
  -only-testing:VariorumTests/RoadKeyDoorWordsTests \
  -only-testing:VariorumTests/WordsConcealedClipboardTests \
  -only-testing:VariorumTests/NoKeyFileDoorTests \
  -only-testing:VariorumTests/RoadKeyDoorRoadTests \
  -only-testing:VariorumTests/RoadKeyDoorsModelTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsCopyDoorTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/RoadAccountWordsTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionSheetPresenterTests \
  -only-testing:VariorumTests/RoadAccountSurfaceTests \
  -only-testing:VariorumTests/ProtectionAccountRouteTests \
  -only-testing:VariorumTests/RoadJoinFollowSurfaceTests \
  -only-testing:VariorumTests/RoadJoinFollowModelTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/LibraryWordsCardTests \
  -only-testing:VariorumTests/TourEndCardTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/QuitDoorTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first seven are U3's (5 + 1 + 5 + 4 + 8 + 11 + 3 = **37 tests**; `WordsClipboardLockRouteTests` drives a planted
new-road bootstrap — no keychain — and is VX-448's lock clear red on old by construction; `WordsConcealedClipboardTests`
and `RoadKeyDoorSurfaceTests` use PRIVATE named pasteboards only). Then the suites over the files this unit touched — the
words band and its look (the flipped bootstrap source pin in `WordsBandSurfaceTests`), today's `WordsClipboard.copy` (its
pins untouched), the bar's words pins, the moved pair road, the presenter's new case, the account section's host and
bootstrap route (`finish` touched), U2's join moment (the look's init grew a default), the pane's composition pins, the open
road and the reminder, the bootstrap neighbours, the delegate (`QuitDoorTests`), the source pins over edited files.
`VX310TodayLobbyWitnessTests` still reports its KNOWN ISSUES (a pass of either is a FAILURE); read the `skipped:` lines.

**THE WALK RECIPE (the orchestrator's, under a held stage claim; the DEV STORE only; light and dark where a face changed;
no account needed — the synced arms stand on the planted vault):**
0. Zero Debug instances (by PATH; `/Applications` never touched). Build + launch as U1's recipe row 0 (the walk's project
   door is NOT needed). `source ~/.variorum/dev-castle.env` and `export` the passphrase (never echoed). Expected: the dev
   library local, Standard, the dev passphrase set.
1. **The key doors on the dev library.** Settings ▸ Protection: *Your passphrase* — *Change passphrase…* · *Reset forgotten
   passphrase…*; *Your twelve words* — *Record your twelve words…* with *Your current secrets open everything you've made
   of this library.* beneath (DO NOT press the words door on the dev library — F-U2b-5). Capture (light, dark).
2. *Change passphrase…* → the sheet: VX-263's line in the primary ink, *Current passphrase*, *New passphrase*, *Again*. A
   WRONG current → *That passphrase doesn't open this library.* in place, the sheet stays. The dev passphrase as current, a
   TEMP new one twice → the status line *Your passphrase is changed.* Then *Change passphrase…* again: current = the TEMP,
   new = the dev passphrase twice (the dev value restored — `dev-castle.env` stays true). Capture each. Log: `road:
   changePassphrase — the current key re-locked (…)`.
3. *Reset forgotten passphrase…* (Standard): the line + *This Mac holds your library's key, so you can choose a new
   passphrase without the old one.*; new = the dev passphrase twice → *Your passphrase is reset.* Capture.
4. **VX-448 on a THROWAWAY library B** (U2b's walk row 1 machinery — A aside whole into `~/vx308-walk/A`): launch → *Start a
   New Library* → B. The card's sentence → the words shown → *Copy* → the caption *Copied. Your clipboard keeps them until
   you copy something else, your library locks or Variorum quits.* (capture). Read the board's types WITHOUT printing the
   words: `osascript -l JavaScript -e 'ObjC.import("AppKit"); ObjC.deepUnwrap($.NSPasteboard.generalPasteboard.types)'` →
   includes `org.nspasteboard.ConcealedType`. Wait 70 s → `pbpaste | wc -w` → 12 (no timer). *I've written them down* →
   *Close*. QUIT (⌘Q) → `pbpaste | wc -c` → 0 (cleared at quit). (The lock's clear walks with U4's lock — F-U3-3.)
5. **VX-447 on B** (B has no passphrase): quit; move B's live key file (`variorum-library-keys.json`) AND B's backup folder
   (`Backups/<B's library8>/`) aside into `~/vx308-walk/B-keys/`; launch with `VARIORUM_WALK_FORGET=memory` (forgets this
   Mac's memory item ONCE before the route — U2a's walk switch) → B opens by its silent item → the bottom bar: *Variorum
   opened your library, but found no key file for it anywhere.* + *Click here to record your twelve words — Variorum makes
   a new key file with them, then a backup.* Capture (light, dark). Click → the words in the bar AT ONCE (nothing asked) →
   *I've written them down* → *Close* → the bar gone; the status line *Your library has a key file again, and a backup holds
   a copy.* Log: `regenerateWords: no key file anywhere — a fresh one minted …`, `road: VX-447 — the fresh key file stands;
   the backup follows`, `backup pair: written under …`. Beside B a fresh `variorum-library-keys.json` (`grep -c` for any
   word → 0) and a new pair under `Backups/<B8>/<mac8>/`. Quit → relaunch (no switch) → no banner. Capture.
6. **Posture after the window:** B (and `~/vx308-walk/B-keys`) aside, A back (rule 21's different-library notice once →
   OK); the dev pair unchanged (changed and changed back, reset to the same value); the general pasteboard empty;
   `rm -r ~/vx308-walk` at closeout.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX308-U3-1 — VX-447's core arm (A CORE LINE):** (a) BUILT — `regenerateWords` mints the key file it locks exactly in
  rule 27's FIRST-ARM state, asking what the state can still check (Standard unsynced: nothing — the plain-confirm twin;
  synced: the account's passphrase against the vault), the fresh file carrying no history and no Apple lock; Castle
  unsynced refuses (the banner keeps her U2-7 words with no door); a stray or any copy anywhere means no mint; (b) Castle
  unsynced by `ResetAuthorization.touchID`'s twin (its item for the current key exists — the press that opened it) — it
  would leave a Castle library with no passphrase lock whose *Set a passphrase…* row refuses in Castle (its road: Reset by
  Touch ID or the words); (c) no core line — the banner door says the act cannot proceed (her ruling against).
- **P-VX308-U3-2 — the undrafted words** (`ProtectionWords`' VX-308 U3 section): the key doors' names, titles, fields,
  buttons, receipts and leads (*This Mac holds your library's key, so you can choose a new passphrase without the old
  one.*; *Confirm it's you with your twelve words [or Touch ID], then choose a new passphrase.*); the synced rule-7 line;
  *Your passphrase* (the section); F-U2-3's line; the banner door line, the open-library account sentence (F-U2c-5), the
  remade receipt (both forms); the new Copy caption. As drafted (pinned): VX-263's one line (the plan's own drafting —
  hers to keep or redraft); her U2-7 first sentence reused byte for byte. (b) blank until her sitting; (c) other words.
- **P-VX308-U3-3 — ONE new-words door (R-U3-5):** (a) BUILT — the Settings words section's door IS rule 7's new-words
  door, now reading `.newWords` (its refusal in place), its label kept *Record your twelve words…* (the ✕'s toast names
  it), VX-263's line beneath; (b) a second *New words…* door in the passphrase section (two doors for one act); (c) relabel
  the words door *New words…*.
- **P-VX308-U3-4 — the passphrase doors' gating and home:** (a) BUILT — a *Your passphrase* section with Change and Reset
  only where a passphrase exists (the core's fact) AND the key's live file stands; VX-306's *Set a passphrase…* row in
  their place otherwise; (b) both always rendered (a refusal line when none); (c) the doors inside the crossings' section.
- **P-VX308-U3-5 — Castle's forgot road by Touch ID is a PRESS at the door** (a read of this Mac's Touch ID item — it
  prompts; today's road's presence confirm kept, design §3.9): (a) BUILT; (b) no press — the core's `.touchID` reads the
  open as the press (a Touch ID button that never prompts).
- **P-VX308-U3-6 — where VX-263's line is said:** (a) BUILT — each passphrase door's confirm (first, the primary ink) and
  beneath the New Words door; (b) once for the section; (c) in the receipts.
- **P-VX308-U3-7 — VX-447's door and its backup:** (a) BUILT — her U2-7 first sentence then the door line, the look INLINE
  in the bottom bar; "the backup follows" = rule 5's PAIR through its one road right after the mint (the face's — never a
  plan step that could fail the mint and lose the words before they show), one receipt; the banner retires at the look's
  close; (b) the door opens Settings ▸ Protection's words section; (c) the backup as the app's Back Up Now (today's flat
  snapshot to both destinations + the hook's pair).
- **P-VX308-U3-8 — VX-448's "lock"** = the library closing behind the lobby (`finish`'s non-ready arm — where U4's lock
  lands): (a) BUILT; (b) also the Mac's screen lock; (c) also every teardown (a crossing's reopen).
- **P-VX308-U3-9 — the new Copy caption** (*Copied. Your clipboard keeps them until you copy something else, your library
  locks or Variorum quits.* — in Standard the library never locks, so quit is its clear): (a) BUILT; (b) *Copied.* alone;
  (c) no caption.
- **P-VX308-U3-10 — F-U2-3's line on the look's ask:** (a) BUILT — a synced look ALWAYS asks (the account's passphrase — the
  core asks it anyway) with the line above the field, her *Show my twelve words* the yes; (b) a separate confirm step
  before the ask; (c) the line on the card's offer itself, before the click.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U3-1 (an `assess` gap — for the architect / the ladder; a core line, Fable's):** on a SYNCED library while SIGNED OUT,
  `assess` OPENS the three key doors (their gate refuses another account, a follow owed and a missing fresh vault IN SYNC —
  not signed out); the act refuses `signedOutUseThisMacOnly`, said in the pane's idiom at the press (*You're signed out of
  this library's account. Sign in first.*). Options: `assess` refuses `.signedOutUseThisMacOnly` for the key doors (the
  crossings' precedent); or accept (the press says it).
- **F-U3-2 (a ticket at closeout — Bug, Suspected, Castle & sync; PRE-EXISTING, every key door):** a key-door act
  (`regenerateWords` above all) whose process dies after its begin and before its key-file step cannot be finished by the
  next open's settle — a settle has no typed secrets (`secretsRequired` throws out of `resume`, not an `ActRollback`), so
  the act stays in flight and every later act refuses `actInFlight`. The file-less arm inherits it (no worse). Options:
  a key door's resume that lacks its secrets ROLLS BACK (no key changed — rule 20's "the old state"); or accept.
- **F-U3-3 (U4 hand-forward):** VX-448's lock clear sits in `AppBootstrap.finish`'s non-ready arm (`clearWordsAtLock`, the
  new road only). U4's new-road lock must land there — or call `AppBootstrap.clearWordsAtLock()` itself;
  `WordsClipboardLockRouteTests` guards the lobby landing.
- **F-U3-4 (F-U1-2's list):** the key doors' new passphrase joins F-U1-2's unenforced 12-character floor (no shared check
  yet — the ticket's one check should cover Change and Reset too).
- **F-U3-5 (her eye — the stale stamp):** in rule 27's state the record's `passphraseSet` stamp says "a passphrase" until
  the next facts write; VX-306's *Set a passphrase…* row reads that stamp (`offersSetPassphrase`), so it stays back until
  the banner's act remakes the file (then it re-reads and is offered — pinned). Only the looks moved to the core's fact
  (R-U3-4).
- **F-U3-6 (the stray arm, for her eye):** the fault's SECOND arm (another key's file beside, nothing holding the library's
  own) keeps her U2-7 banner with no door — *Make a backup now, so a copy exists.* is still advice nothing can follow there
  (F-U2c-1's tension, narrowed to this arm).
- **F-U3-7 (MOBILE PARITY):** the phone has no key doors, no banner door (`MobileNoKeyFileSheet` keeps her U2-7 words and
  the lobby's account sentence), no concealed clipboard (its pasteboard arm is the mobile row's).
- **F-U3-8 (canon, the closeout's):** SurfaceContracts' "Library protection" line — *Copy (the clipboard clears after 60
  seconds by restoring its prior contents)* becomes the concealed type cleared at lock and at quit; the key doors (Change ·
  Reset · New Words, VX-263's line, synced together-change); the no-key-file banner as the door (record → fresh key file →
  the pair) with the open-library account sentence; F-U2-3's line on a synced look. AppSpec untouched.

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree; every mutation and behavioural revert
ran on a committed tree and was restored by `git checkout --` (`cmp` against a pre-mutation copy in this session's
scratchpad). One TEST bug of mine fixed before its commit (a discarded `PlantedRoad` freed its temp slot under the read).
Commits: `cfc0ebed8` (0) · `8e465f7ea` (1, pins first) · `577bd53dc` (1) · `40b365d16` (record) · `5314bb7a6` (2) ·
`1b6a7403e` (3) · `bdfcf2caa` (record) · `773940c38` (4) · `07e668e62` (5) · `5399f87d7` (6) · `15e2979a8` (6b) ·
`052250050` (6c) · `cee78df07` (a warning) · the close commit.

**U3 ARBITRATION (the orchestrator, 2026-10-19 ~08:30 MDT — repo-first before U4 spawns):**
- **F-U3-1** (`assess` opens the key doors on a synced library while signed out; the act refuses honestly at the
  press): a TICKET at closeout (Improvement, Confirmed, Castle & sync, Low) — the press-time re-read keeps her safe
  and says why; P-2's letter is bent transiently, and the fix is a core-assess line the ladder can weigh but this
  phase doesn't owe.
- **F-U3-2** (a key-door act interrupted mid-plan cannot be finished by the next open — no secrets in hand; the act
  stays in flight and later acts refuse): a TICKET at closeout (Bug, Confirmed, Castle & sync, Medium) — an existing
  class, pre-dating this phase; the honest fix is a design call (roll back instead of resume, or ask at the open).
- **F-U3-3** (U4's lock must clear the words clipboard — the non-ready arm, or `clearWordsAtLock()`): FOLDED INTO
  U4's brief at its spawn.
- **F-U3-8** (SurfaceContracts' 60-second clipboard sentence is now false): the closeout's canon delta list.
- **P-VX308-U3-1 (Castle unsynced not widened) and P-VX308-U3-3 (one words door): APPROVED as built** — both are the
  narrow arms; the bundle carries them.

**THE U3 MAC BATCH (the orchestrator, 2026-10-19 08:12–08:35 MDT, stage claim `vx-308-u3-mac`, the coordinator's GO;
logs `vx308-u3-mac-run.log` + `-refix.log`, deleted at closeout):** 200 tests / 42 suites — the 3 expected VX-310
witnesses; ONE real red, a SOURCE PIN: `VX379PaneRowsTests.theCastleWarningReadsTheOpenLibrarysPosture`'s needle
pinned the faces' `posture:` line WITH its closing paren, and U3's `mintFreshWords` argument growth turned that paren
into a comma — the pinned BEHAVIOR (the faces carry the record's mode) stands untouched; the needle re-anchored
without the paren, the suite re-run `✔ 4/1`. 0 instances at release; no stray HID input (the coordinator's morning
term). **U3 IS CLOSED but for the walk and the ladder.**

### U4 RECORD — THE LOCK ON THE NEW ROAD + THE HOLD'S GATE (Opus implementer, 2026-10-19; VX-445 + NIT-R2-1 + F-4 — BUILT; the Mac suites and the walk PENDING)

**Not done in U4, first:**
- **No Mac suite was RUN and no walk was made** (the brief: headless + `build-for-testing` only — no `xcodebuild test`, no
  stage, no Debug launch, no store touch). Two Mac-only pins are BUILT — `RoadLockRouteTests` (4) and
  `WordsClipboardLockRouteTests`' lock-road twin (1) — their run AND their red-on-old by behavioural revert are the
  orchestrator's (the recipe below). Every other new suite ran HEADLESS. No live network call anywhere; the dev store, the
  real store and `/Applications` untouched.
- **No face for the idle dial or Lock Now in the new road's pane** (F-U4-1 — routed, not built: a second face, not this
  unit's): today's Castle section (*Lock after time away*, *Lock Now*) retires behind the switch on the new road
  (P-VX307-U2a-4); the new road's Lock Now is the File menu's *Lock Library Now* (⌃⌘L — `canLock` now true in Castle), and
  the idle lock runs on this Mac's sealed setting at its default 10 with no face to change it.
- **F-4 gates exactly the ruled pair** (a synced Use Castle and Replace All Keys); no account act and no key door is gated
  (F-U4-3 — her eye). **The walk interplay** (F-U4-2 — the orchestrator's): the hold's marker is per SLOT, so U1's and
  U2's walk rows that show or press a SYNCED Use Castle on the dev store now meet F-4's refusal.
- **The phone**: its relock coordinator still reads today's facts (no Castle is reachable on the phone's new road this
  phase — F-U4-4, MOBILE PARITY). **Today's road is byte-unchanged in behaviour** (every new arm sits behind `newRoad`, the
  nil `roadRelock` hook, or new-road-only code). The canon delta (F-U4-5) and the QUESTIONS rows are the closeout's.
- Zero `Sources/`, `Sync/`, `Server/`, schema, migration or dependency lines; `SyncSchema.lockstepVersion` 13.

**Preflight (complete, not delegated):** CLAUDE.md + its canon; the resiliency protocol; CastleRules WHOLE; SyncSpec WHOLE
(the hold gates sync rounds; no `Sync/` line here); SurfaceContracts (the app + Doors — portability's restore hold and
Library protection); this plan whole (§1–§5d, the §6 rehearsal, U1, VX-314, U2 and U3 records with their arbitrations and
Mac batches, §7); VX-307 §5a–§5e, the §6 U2a RECORD (THE FACES AS BUILT, F-3/F-4, the arbitration) and its FIX LEG
(MAJOR-1's durable mark); `notes/plans/vx-307-ladder-round-2.md` (NIT-R2-1, the dispute calls); the VX-445 ticket (Linear,
read-only); the vx-266 design's §3.2/§3.10/§3.15 lines on the idle lock's home; the code — `AppBootstrap` whole (the open
road, `finish`, the seams, `lock`/`canLock`, the export switch), `ProtectionController` (the dials, `performLock`, the
relock monitors), `StoreProtection`'s `ProtectionDials`/`IdleLockClock`, `MacWillLock`, `VariorumApp`'s ready composition
(`onWillLock`, `lockTimeCopy`, the hold's `wireGates`), `EditorCommands`' Lock Library Now, `SettingsSceneContent`'s close
at a settled closed state, `ProtectionOpenRoad` (the route, the session, the lobby, `RoadInputs`), `ProtectionLobbyModel`,
`ProtectionCrossingActs`, `ProtectionAccountActs`' rule-11 arms, `RoadCrossingFaces`, `RoadCrossingsModel`,
`NewRoadSyncKeyProvider`, `DeviceSection`, the core's `Leaves` (session memory "gone at a relock"), `LibraryRestoreHold`,
`RestoreHoldModel`, today's gate (`PostureSwitchModel.start`, `ProtectionCopy.resumeSyncFirst`), `LibraryOpenCopy`'s hold
sentences; the test support (`PlantedRoad`, `ProtectionAccountSupport`, `ProtectionTestSupport`, `ProtectionRoadTestSupport`,
`PlantedExportSwitch`, `WordsClipboardLockRouteTests`, `ProtectionCrossingRouteTests`, `SettingsLockCloseTests`).
HARNESS: U1's scratchpad package `u1-harness` (the recipe in the U1 RECORD's COUNTS), pointed at this worktree.

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U4-1 — THE LOCK IS CASTLE'S.** "Castle's idle lock and Lock Now … `canLock` true where the road session stands":
  `canLock` and `lock()` act on the new road exactly where the open library's RECORD is in Castle (Touch ID, Always ask,
  or no choice yet). Standard never locks — its quiet roads would open it again at once (rule 8), today's Auto refusal
  (R13p-14: no theater ships), the VX-306 `canLock` comment's own reason.
- **R-U4-2 — THE LOCK'S TEARDOWN IS THE CROSSINGS' SEAM'S FIRST HALF, THEN THE LOBBY.** One act at a time: the lock takes
  the session's one-act lock (an act running, or an open in flight, is waited out — never torn under); the composition
  root's `onWillLock` (the Mac's `macWillLock` — flush, savepoint, stop); `.opening`; today's controller's resident key,
  per-open deferrals and custody session dropped (as every seam does); the account's sync keys in SESSION memory dropped
  (the leaf's contract: "gone at a relock"); the road session, its standing faces and the engine's key seam let go (no
  reference keeps the key); the app's pool CLOSED through the binding off the main actor; then THE LOBBY — the open road's
  own (`ProtectionOpenRoad.lobbyFacts` over a freshly composed road) landed through `finish(.roadLobby)`, so the one
  presenter drops its sheet and VX-448's clear runs (F-U3-3, by construction). The quiet roads are NOT tried at a lock (a
  lock is never theater — today's lock lands in its lobby the same way). Always ask types; Touch ID auto-asks: the
  lobby's existing behaviour, untouched.
- **R-U4-3 — THE IDLE SETTING HONORED IS THIS MAC'S SEALED ONE.** On the new road the setting that could weaken
  protection lives sealed in this Mac's facts, never UserDefaults (the design's §3.2 and §3.15 — "Castle settings in
  UserDefaults" die at the switch): `DeviceSettings.idleLockMinutes` (default 10, decision 18's, kept). The EXISTING timer —
  the controller's monitors (sleep and screen lock, always on in Castle; the 30-second tick over Variorum's own activity
  clock) — consults the new road's policy through ONE injected hook (nil on today's road: today's effective gate and
  dials decide, unchanged).
- **R-U4-4 — NIT-R2-1: THE MARK BY LIBRARY.** `variorum.calmAsks.exportOffNotice.<libraryID>.owed` (the brief's idiom);
  every reader and writer names the library (the switch's two closures take its id). The legacy one-per-domain mark
  (`variorum.protection.exportOffNoticeOwed`) MIGRATES: the first library whose mark is consulted adopts it (the first
  ready's reconcile — round 2's ordering: the library standing at the first ready after an entry is the one that entered)
  and the legacy key is removed. Notice-visibility only; the switch-off never depended on it.
- **R-U4-5 — F-4's SEAM: THE CROSSINGS' READ.** `ProtectionCrossings.readCrossings` — the pane's crossings read AND the
  press's re-read (the preflight calls it: VX-108, shown and re-read alike) — reads the hold marker beside the slot (the
  gates' one source, 13x R3-2) and turns a SYNCED Use Castle and Replace All Keys into their refusal sentence in place
  (P-VX307-U2a-2's idiom); the preflight then refuses with it, before anything closes. New-road-only code: today's road
  (its own gate in `PostureSwitchModel`) is byte-unchanged. Not `assess` (core): the hold is the app's landing-state
  marker beside the store, never a protection fact. Use Standard stays open (today's rule's own exemption — it drives no
  round), and a LOCAL Use Castle stays open (the hold is about sync — and the dev store's local walks stay walkable).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton + the readings: DONE (this commit).
- Piece 1 — F-4 (the hold's gate): DONE (`0a35a906b`; the pins-first commit `1a0c0d8ba`). `RoadRestoreHoldGateTests`
  committed FIRST and RED ON THE PRE-FIX TREE (`✘ … 2 tests in 1 suite failed … with 4 issues` — a synced library's Use
  Castle and Replace All Keys open with the marker beside the store; both presses' re-reads `.ready`; the local arm green
  by design). The gate (R-U4-5): `ProtectionCrossings.readCrossings` reads `LibraryRestoreHold.isHeld(besideStore:)` and
  `RoadCrossingFaces.heldForRestore()` turns an OPEN, SYNCED Use Castle / Replace All Keys into
  `ProtectionWords.restoreHoldRefusal(title)` in place (PROVISIONAL P-VX308-U4-1); the preflight refuses with it, nothing
  written; Resume's clear lifts it. Pins now 4 (+ the pure hold-back, + the sentence as drafted): with the crossing suites
  headless `✔ Test run with 27 tests in 4 suites passed`. MUTATION M-F4-1 (the `synced` guard dropped — every open door
  held) → `✘ aLocalLibrarysUseCastleStaysOpenUnderTheHold` (1 issue); restored by `git checkout --`, `cmp`-identical.
- Piece 2 — NIT-R2-1 (the mark by library): DONE (`c7025e8fc`). R-U4-4 built: `ScheduledExportSwitch`'s mark closures take
  the library's id; `ExportNoticeMark` (`ProtectionCrossingActs.swift` — `variorum.calmAsks.exportOffNotice.<libraryID>.owed`)
  is the one home the production switch runs (`AppBootstrap.markdownInsuranceSwitch`, both domains;
  `AppBootstrap.exportNoticeOwedKey` retired into `ExportNoticeMark.legacyKey`); every reader and writer names the library
  (Use Castle's and the account acts' mark — the id captured before the act, a crossing never changes it — the refusal's
  clear, the ready's reconcile, *OK*, *Turn it back on*, and the pane's read/dismiss through the OPEN library's id). THE
  EXISTING MARK MIGRATES (not re-derived — the mark exists precisely because the state cannot be re-derived: her later
  choice): the first library whose mark is consulted adopts an earlier build's unkeyed mark and the legacy key is
  removed. The in-memory test switch (`PlantedExportSwitch`) is keyed, its any-library reading kept for the one-library
  suites (two call sites in `ProtectionCrossingRoadTests` name the id). Pins `ExportNoticeByLibraryTests` (3) — with the
  crossing, join/follow, crossing-model and F-4 suites headless `✔ Test run with 40 tests in 5 suites passed`. RED BY
  BEHAVIOURAL REVERT (each on `c7025e8fc`, restored by `git checkout --`, `cmp`-identical): R1 — the key ignoring the id (one
  mark per domain, the pre-fix behaviour) → `✘ anotherLibrarysReadyNeverClearsANoticeItDidNotWrite` (B's ready and B's *OK*
  cleared A's notice) + the migration and key pins red; R2 — the migration skipped → `✘
  anEarlierBuildsUnkeyedMarkMigratesOntoTheFirstLibraryConsulted` (5 issues).
- Piece 3 — VX-445 (the lock): DONE (`094aaf693`). `Shared/Protection/ProtectionRoadLock.swift` (harness-visible):
  `RoadRelockPolicy.of(library)` (Castle → this Mac's sealed `idleLockMinutes`; Standard → nil), `ProtectionRoadLock
  .dropSessionMemory` (the bound account's sync keys out of session memory) and `.lobby(ctx)` (the open road's own
  `lobbyFacts`). `AppBootstrap`: `roadRelockPolicy` (ready, bound, a road session in Castle); `canLock` on the new road =
  that policy; `lock()` on the new road → `lockOnNewRoad` (R-U4-2: `awaitTheLockSeam` — the session's one-act lock held, an
  act or an open in flight waited out; a road composed BEFORE the teardown, or nothing closes; `onWillLock`; `.opening`;
  the resident key, per-open deferrals and custody session dropped; `dropSessionMemory`; `roadStanding`/`roadSession`
  nil, the engine's key seam detached; `binding.lock()` and the lobby's facts off-main; `finish(.roadLobby)` — the
  presenter's `libraryClosed` and VX-448's `clearWordsAtLock` by construction, F-U3-3). No lock-time byte copy on the new
  road (P-VX308-U4-3). Both inits wire `protection.roadRelock` on the new road only. `ProtectionController`: `roadRelock`
  (nil on today's road) — `relockIfPolicySays` (sleep/screen lock) and `relockIfIdle(now:)` (the 30-s tick, `IdleLockClock`
  over the policy's minutes) take the new road's arm when the hook is set, today's arms unchanged in effect (internal now
  for the route pins; `now` injectable, default `Date()`). Pins: `RoadLockTests` (4, headless — the policy Castle/Standard and
  the sealed minutes 10 → 30 → never; the lobby under Always ask, no quiet road TAKEN even over a stale silent item the
  route would open through; under Touch ID the one auto-ask's press opens it; the session drop) — `✔ Test run with 4 tests in
  1 suite passed`. MUTATIONS (each on `094aaf693`, restored by `git checkout --`, `cmp`-identical): MK-L1 Standard locks too →
  `✘ theRelockPolicyIsCastles…` (1); MK-L2 the default instead of the sealed setting → the same (2); MK-L3 nothing dropped →
  `✘ theLockDropsTheAccountsSyncKeysFromSessionMemory` (1). MAC PINS (BUILT — `build-for-testing` `** TEST BUILD SUCCEEDED
  **`, no warning in a touched file; the RUN PENDING the stage): `RoadLockRouteTests` (4) + `WordsClipboardLockRouteTests
  .lockNowOnACastleLibraryEmptiesTheWordsALookCopied` (the lock road's twin, F-U3-3) — their red-on-old by behavioural
  revert is the orchestrator's (the recipe in the close).
- Piece 4 — the close: DONE (this commit) — the counts, the Mac-suite list with the red-on-old recipe, the walk rows, the
  PROVISIONALs and the findings below; `ProtectionRoadRouteTests`' `!again.canLock` message re-worded (its assertion
  unchanged and still true: Standard never locks), and that touched file's one PRE-EXISTING warning (a needless `try` on
  `aReadOnlyRoadNeverCreates`' non-throwing body, VX-306's) dropped — the final `build-for-testing` green with no warning in
  a touched file.
- No revert is in flight (every mutation and behavioural revert ran on a committed tree, restored by `git checkout --` and
  `cmp`-checked against a pre-mutation copy in this session's scratchpad; no scratch worktree).

**THE FACES AS BUILT (for the ladder):** THE LOCK — `AppBootstrap.canLock` / `lock()` on the new road read
`roadRelockPolicy` (ready, bound, a road session whose record is in Castle → `RoadRelockPolicy` with this Mac's sealed
`idleLockMinutes`). `lockOnNewRoad`: `awaitTheLockSeam` (polls 100 ms: an open in flight or an act holding the session is
waited out; the session's one-act lock is then HELD through the teardown; nil on any settled non-Castle or closed state) →
the lobby's road composed FIRST (nothing closes without a place to land) → `onWillLock` → `.opening` → the controller's
resident key, per-open deferrals and custody session dropped → `ProtectionRoadLock.dropSessionMemory` → `roadStanding`,
`roadSession` nil, `newRoadSyncKeys.attach(nil)` → off-main `binding.lock()` + `ProtectionRoadLock.lobby(ctx)` (the open
road's `lobbyFacts` — never `route`, so no quiet road is TAKEN) → `endAct` → `finish(.roadLobby)` (the presenter's
`libraryClosed`, VX-448's `clearWordsAtLock`; the Settings window closes at the settled lobby — VX-224). The unlock is the
lobby's own road (`beginOpening(roadOpened:)` → a fresh session, the binding adopting the fresh pool). THE MONITORS —
`ProtectionController.roadRelock` (set by both inits on the new road only): `relockIfPolicySays` (sleep, screen lock) and
`relockIfIdle(now:)` (`IdleLockClock` over the policy's minutes, Variorum's own activity clock) → `performLock` → `lock()`.
NIT-R2-1 — `ScheduledExportSwitch`'s mark closures by library id; `ExportNoticeMark` the one home; the legacy mark adopted
at the first consult. F-4 — `ProtectionCrossings.readCrossings` → `RoadCrossingFaces.heldForRestore()` while
`LibraryRestoreHold.isHeld(besideStore: slot)`; the preflight re-reads through it.

**COUNTS (the final tree — this close commit):**
- HEADLESS HARNESS (U1's scratchpad package `u1-harness`, pointed at this worktree; it now also symlinks
  `Shared/Protection/ProtectionRoadLock.swift` and this unit's three headless suites): **`✔ Test run with 267 tests in 42
  suites passed after 2.610 seconds.`** (U3's 256/39 + 11/3: `RoadRestoreHoldGateTests` 4, `ExportNoticeByLibraryTests` 3,
  `RoadLockTests` 4).
- MUTATIONS / BEHAVIOURAL REVERTS (each on a committed tree, restored `cmp`-identical — the pieces' lines above): F-4's
  pre-fix tree (4 issues) + M-F4-1 (1); NIT-R2-1's R1 (one key per domain — the pre-fix behaviour) and R2 (no migration,
  5); VX-445's MK-L1 (1), MK-L2 (2), MK-L3 (1). Every one red.
- CORE: the protection set (the 83 `@Suite` types under `Tests/VariorumCoreTests/Protection`; no core file changed) Debug
  **`✔ Test run with 340 tests in 83 suites passed after 5.438 seconds.`**; Release (`swift test -c release`, the same
  filter) **`✔ Test run with 316 tests in 79 suites passed after 3.911 seconds.`**
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308
  build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (no warning in a touched file); the phone `-scheme VariorumMobile
  -destination 'generic/platform=iOS Simulator' -configuration Debug … build` → **`** BUILD SUCCEEDED **`**; **the Release
  check `-configuration Release build` → `** BUILD SUCCEEDED **`**.
- Release behaviour: unchanged by construction — `newRoad` is false there (`canLock`/`lock()` take today's arms), the
  controller's `roadRelock` stays nil (today's monitor arms; `relockIfIdle`'s `now` defaults to `Date()`), and the export
  mark, the hold's gate and the lock's parts are reached only from new-road code. The binary is not byte-identical (rule
  24's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx308 test \
  -only-testing:VariorumTests/RoadLockRouteTests \
  -only-testing:VariorumTests/WordsClipboardLockRouteTests \
  -only-testing:VariorumTests/RoadLockTests \
  -only-testing:VariorumTests/ExportNoticeByLibraryTests \
  -only-testing:VariorumTests/RoadRestoreHoldGateTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/RoadCrossingFacesTests \
  -only-testing:VariorumTests/RoadCrossingWordsTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionJoinFollowRoadTests \
  -only-testing:VariorumTests/RoadJoinFollowSurfaceTests \
  -only-testing:VariorumTests/ProtectionAccountRoadTests \
  -only-testing:VariorumTests/ProtectionAccountRouteTests \
  -only-testing:VariorumTests/RoadKeyDoorSurfaceTests \
  -only-testing:VariorumTests/WordsConcealedClipboardTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionLobbyModelTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/ProtectionDialsTests \
  -only-testing:VariorumTests/VX202ReopenRaceTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests
```
The first two are U4's Mac-only pins (4 + 1 — plus `WordsClipboardLockRouteTests`' U3 pin = 6 tests); the next three are
U4's headless suites (11, also green in the harness); then the suites over the files this unit touched — the crossings'
read, faces and acts (the gate; the mark's new signatures — `ProtectionCrossingRouteTests` runs the PRODUCTION switch
builder through the bootstrap), the account acts' rule-11 mark, the bootstrap (`finish`, the roads, the lock — today's lock
suites `Phase13pLobbyTests` / `SettingsLockCloseTests` / `VX202ReopenRaceTests` must hold unchanged), the controller's
monitors (`ProtectionDialsTests` carries `IdleLockClock`), the open road and its lobby, and the source pins over the edited
files. `VX310TodayLobbyWitnessTests` still reports its KNOWN ISSUES (a pass of either is a FAILURE); read the `skipped:`
lines.

**THE RED-ON-OLD BY BEHAVIOURAL REVERT (the orchestrator's, each from a committed tree, restored by `git checkout --`):**
- **(R-a) the pre-VX-445 bootstrap:** `AppBootstrap.lock()`'s first line back to `guard !newRoad else { return }` AND
  `canLock`'s new-road line back to `guard !newRoad else { return false }` → `RoadLockRouteTests` (all four) and
  `WordsClipboardLockRouteTests.lockNowOnACastleLibraryEmptiesTheWordsALookCopied` RED (no door, no lock, the copy kept).
- **(R-b) the pre-VX-445 monitors:** the two `if let roadRelock { … }` arms removed from `ProtectionController
  .relockIfPolicySays` / `relockIfIdle(now:)` → `theMonitorsLockACastleLibraryOnItsSealedIdleMinutesAndAtSleep` RED (today's
  effective gate is never demanded on the new road).
- **(R-c) a lock that routes:** in `lockOnNewRoad`, the lobby landing replaced by `beginOpening()` → `lockNowCloses…` RED at
  its stale-silent-item step (the route opens through it at once — theater).
- **(R-d) no wait:** `awaitTheLockSeam` returning nil when `beginAct()` fails → `aLockAskedWhileAnActRunsWaits…` RED (the
  lock gives up; the library stays open after the act).

**THE WALK ROWS (the orchestrator's walk, under a held stage claim; the DEV STORE only; light and dark where a face is
captured):**
0. U1's recipe row 0 (zero Debug instances by path; build; launch the binary with stderr captured). `source
   ~/.variorum/dev-castle.env` and `export` (never echoed). Expected start: the dev library local, Standard, the dev
   passphrase set, the restore hold standing (never press Resume).
1. **No door in Standard:** the File menu shows NO *Lock Library Now*. Capture.
2. **Into Castle (local — F-4 never gates a local crossing; the hold stands):** Settings ▸ Protection ▸ *Use Castle…* —
   the dev pair, *Always ask* → the reopen in Castle (U2a's walk row 1's machinery). The File menu now shows *Lock Library
   Now* ⌃⌘L. Capture.
3. **VX-448 at the lock — on a THROWAWAY library B only** (U3's walk row 4's machinery — never a look on the dev library,
   F-U2b-5): B fresh → the card's look → *Copy* (the concealed copy) → B: *Use Castle…* (a new passphrase twice; B's words
   pasted) → reopen in Castle (the copy still on the board — a crossing's reopen is not a lock, P-VX308-U3-8) → ⌃⌘L → THE
   LOBBY → `pbpaste | wc -c` → 0. Log: `road: locked — the library closed behind the lobby (VX-445)`, `road: the library
   closed — the twelve words left the clipboard (VX-448)`. B's passphrase opens it. B aside afterwards.
4. **The relock lobby, Always ask (the dev library A in Castle):** ⌃⌘L → the lobby asks a secret at once (no Touch ID
   button); any Settings window closes (VX-224). Capture (light, dark). A wrong passphrase → refused in place; the dev
   passphrase → the library opens; ⌃⌘L is back.
5. **Touch ID:** the gate-style row *Use Touch ID…* (the dev passphrase) → ⌃⌘L → the lobby AUTO-ASKS (the system prompt —
   her finger, or cancel and type). Capture. Then *Use Always ask* back.
6. **(Optional) the monitors:** the screen lock (⌃⌘Q) → unlock the Mac → Variorum stands at the lobby (log line as row 3);
   time away ≥ 10 minutes with no input → the lobby.
7. **F-4 (with U1/U2's account rows, the throwaway project — F-U4-2):** the dev library IN SYNC with the hold standing →
   Settings ▸ Protection: in *Use Castle…*'s place *Sync is waiting since the restore — press Resume Sync in the main
   window's banner, then choose Use Castle again.*, and Replace All Keys' twin. Capture (light, dark).
8. **Posture after the window:** *Use Standard…* on the dev library (both secrets — the dev pair unchanged), Always ask's
   gate row gone with Castle; B aside under `~/vx308-walk/`; the hold's marker standing as found; signed out.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX308-U4-1 — the hold's refusal** (*Sync is waiting since the restore — press Resume Sync in the main window's banner,
  then choose Use Castle again.* / *… Replace All Keys again.*): (a) BUILT — the shipped hold copy's idiom; (b) today's
  `ProtectionCopy.resumeSyncFirst` verbatim (*Resume sync first — this library was just restored from a copy, and sync is
  waiting for your go.*); (c) other words.
- **P-VX308-U4-2 — a lock asked while an act runs WAITS for it** (an act holding the session, or an open in flight, then the
  lock): (a) BUILT; (b) refuse (the idle tick retries in 30 s; a sleep's or screen lock's lock is then the idle clock's);
  (c) lock anyway (a teardown under a running act — unsafe).
- **P-VX308-U4-3 — no lock-time keyless byte copy on the new road:** (a) BUILT — rule 5: a backup is the library and its
  key file (the new road's backups are the pair); (b) today's keyless flat copy at the lock; (c) rule 5's pair taken at the
  lock (a backup act inside the teardown).
- **P-VX308-U4-4 — F-4's refusal IN PLACE of the door** (P-VX307-U2a-2's idiom): (a) BUILT; (b) today's shape — the door
  renders and its press refuses; (c) the doors hidden while held.
- **P-VX308-U4-5 — the legacy export mark MIGRATES** onto the first library consulted (the record's R-U4-4): (a) BUILT;
  (b) dropped (a standing notice lost once — notice-visibility only); (c) read as every library's (the NIT kept).

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U4-1 (a ticket at closeout — Improvement, Confirmed, Castle & sync; a VX-329 parity gap):** the new road's Protection
  pane carries no *Lock Now* and no idle dial (today's Castle section retires behind the switch, P-VX307-U2a-4); the menu's
  *Lock Library Now* is the new road's Lock Now, and the idle lock runs on the sealed default (10) with no face to change it.
  Options: the gate-style row grows the idle picker and a Lock Now door (through `changeSettings` — no core line); or
  VX-329's list.
- **F-U4-2 (THE WALK — for the orchestrator):** the restore hold's marker sits beside the SLOT, not the library — every
  library in the dev slot is held. U1's walk row 2 (the dev library in sync: "the crossings: Use Castle now SYNCED") now
  shows F-4's refusal in Use Castle's place (walk it as F-4's row — row 7 above), and U2's walk row 2 (throwaway library B,
  joined to account A, then a SYNCED *Use Castle…* to put the account in Castle for the follow) is REFUSED by the gate.
  Options for that row: move the marker aside with library A for the follow rows (`variorum-restore-hold.json` beside the
  slot → `~/vx308-walk/`, back with A at the posture restore — the dev store's hold as found after), or walk the follow
  with the coordinator's word on the marker; never press Resume on the dev store (the coordinator's term).
- **F-U4-3 (her eye — F-4's reach):** the ruled gate covers the two synced account-wide CROSSINGS exactly (13x R1-M1's
  pair); the account section's acts that write the vault — turning sync on, a join (including into a Castle account), Move,
  the follow — and the synced key doors (which re-wrap the account's vault) are not gated, and none runs a sync round.
  Recorded, not built (no invention); the bundle asks whether the hold should refuse every vault write until Resume.
- **F-U4-4 (MOBILE PARITY):** the phone's relock coordinator (`MobileRelock`) still reads today's effective gate and dials
  on the new road; a phone new-road library cannot enter Castle this phase (no crossing faces there), so nothing locks that
  should — the phone's new-road relock is the mobile row's.
- **F-U4-5 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains, in place, one pointer to this
  plan: on the new road a Castle library LOCKS — *Lock Library Now* (⌃⌘L), sleep and screen lock, and after this Mac's
  sealed idle minutes — into the open road's own lobby (Always ask types; Touch ID auto-asks), the lock clearing the words
  clipboard; a standing restore hold refuses the SYNCED Use Castle and Replace All Keys in place (naming Resume Sync); rule
  11's export notice is marked by library. The portability line's restore-hold sentence carries the new road's gate too.
- **F-U4-6 (a note for the ladder):** `awaitTheLockSeam` POLLS (100 ms) — `endAct` has no callback to the bootstrap; the
  poll exits on any settled non-Castle or closed state and on cancellation. A signalled wait would need a new seam on the
  session (not built — the poll is bounded by the act's own life).

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree; every mutation and behavioural revert
ran on a committed tree and was restored by `git checkout --` (`cmp` against a pre-mutation copy in this session's
scratchpad). Commits: `9787475dc` (0) · `1a0c0d8ba` (1, the pin first) · `0a35a906b` (1) · `2fae754d7` (record) ·
`c7025e8fc` (2) · `e0753fa9c` (record) · `094aaf693` (3) · `345325dbb` (record) · the close commit.

**U4 ARBITRATION (the orchestrator, 2026-10-19 ~09:40 MDT — repo-first before the ladder):**
- **F-U4-1** (the new road's pane has no Lock Now row and no idle dial; the menu's ⌃⌘L is the lock's one door): a
  TICKET at closeout (Improvement, Confirmed, Castle & sync, Low) — the capability exists and is walkable; the face
  rows are a small later piece (or VX-329's polish).
- **F-U4-2** (the hold's per-slot marker now gates the dev slot's synced crossings — the walk recipes' interplay):
  ACCEPTED — the walk takes the record's aside-the-marker option for the follow rows and NEVER presses Resume; folded
  into the walk plan below.
- **F-U4-3** (F-4 gates exactly the ruled pair — account acts and key doors that write the vault are NOT gated): for
  HER BUNDLE (the ruled letter is the pair; whether the hold should fence every vault write is her call — one
  sentence in the morning read).
- **F-U4-4** (the phone's relock reads today's facts): the MOBILE PARITY line at closeout.
- **F-U4-5**: the closeout's canon delta list (with U3's F-U3-8).
- **F-U4-6** (the lock's 100 ms wait poll — no endAct callback): record-only; a callback seam is a nicety the ladder
  may weigh.
- **P-VX308-U4-1..5: each stands as built** pending her bundle (the hold refusal's sentence, the migration arm — the
  mark adopted by the first reader because the state cannot be re-derived, the no-keyless-copy lock, the rest as the
  record states them).

**THE U4 MAC BATCH + THE FOUR REVERTS (the orchestrator, 2026-10-19 09:08–09:55 MDT, stage claim `vx-308-u4-mac`,
the coordinator's GO; logs `vx308-u4-*.log`, deleted at closeout):** 201 tests / 32 suites, ZERO real reds first run
(the 3 expected witnesses). The red-on-old reverts, each applied by exact text, run, and restored `git checkout`-clean:
**R-a** (the pre-VX-445 bootstrap lines) → RED across `RoadLockRouteTests` (all four) + the clipboard lock pin;
**R-b** (the monitors' new-road arms removed) → RED at exactly `theMonitorsLockACastleLibraryOnItsSealedIdleMinutes
AndAtSleep` — the orchestrator's FIRST R-b edit broke the file syntactically (a regex ate nested braces; compile
error), that run DISCARDED AS INVALID and the revert redone with exact text (the machinery honesty line);
**R-c** (the lock routing instead of the lobby) → RED at the four route pins; **R-d** (no wait on a running act) →
RED at exactly the wait pin. The restored suites `✔ 6/2`; 0 instances at release. **U4 IS CLOSED but for the walk and
the ladder — the implementer era of the phase is done.**

### ROUND-1 FIX LEG (Opus implementer, 2026-10-19; the cross-model ladder's round-1 fixes over `notes/plans/vx-308-ladder-round-1.md` — IN PROGRESS)

**Not done in this leg, first:** no Mac suite RUN, no walk, no stage, no Debug launch, no store touch (the brief:
headless + `build-for-testing` only — the Mac-suite delta below is the orchestrator's). PENDING on every unverified claim.

**Preflight (complete, not delegated):** CLAUDE.md + its canon; the resiliency protocol; CastleRules WHOLE (rules 20 and 27
the heart of MAJOR-1); the round-1 findings file whole; this plan's §1–§5d and the §6 U1, U2, U3 and U4 records with their
arbitrations and Mac batches; the core's `PlanRunner.swift` and `Acts/KeyDoors.swift` whole, `Plan.swift`'s
`pastCommitPoint`, `Executor.swift`'s unlock / `writeFacts` / `writeMemory` / `memoryValue`, `CommonSteps`' `freshRead` /
`material` / `rememberNewKey`, `Assess.swift`'s memory and rule-27 arms, `ExecutorRepairs`' `refreshMemory`; the executor's
test world (`ExecutorWorld`, `EX`, `CrashHarness`, `U2CrashHarnessTests`, `FileLessWordsTests`) and the scenario world's
settle + promise 6; the pane (`ProtectionPane`), the three section models' refresh rules, `AppBootstrap`'s three pane
roads, `ProtectionPaneRead`, `ProtectionKeyDoorRoad.read`, `ProtectionCrossings.readCrossings`; the `.signIn` host arm
and `ProtectionWords.joinedReceipt` with their pins. HARNESS: U1's scratchpad package `u1-harness` (this session's
scratchpad, pointed at this worktree).

**LIVE STATUS (per finding; PENDING = unverified):**
- **MAJOR-1** (the resumed new-words act wedges the recovery door) — AGREE, DONE (`653d236c2`; the pins-first commit
  `07add5577`). Pin `NewWordsResumeTests` RED ON THE PRE-FIX TREE (`✘ … 5 tests in 1 suite failed … with 14 issues`),
  green after with its sixth test (`✔ 6 tests in 1 suite`; with `FileLessWordsTests`, `FirstLookWordsTests`,
  `ExecutorKeyDoorTests`, `U2CrashHarnessTests` `✔ 24 tests in 5 suites`). MUTATIONS on `653d236c2`, each restored by `git
  checkout --` and `cmp`-identical: M1-a the no-words arm dropped → `✘ … 4 issues` (the everyday act's settle throws
  `secretsRequired`); M1-b the no-live-file arm dropped → `✘ aStoppedMintResumedHoldingWordsButNoKeyFileRollsBackToo` both
  arms (`noLiveKeyFile`); M1-c the `resuming` guard dropped (a press too) → `✘ … 11 issues` (the door's own mint refuses —
  the guard is load-bearing). The trace, the fix and the residue: THE DISPOSITIONS below.
- **MINOR-1** (`keyFileGoneEverywhere`'s decode-skip vs the record's "never a guess") — AGREE the record overclaims;
  disposition (b), DONE (`023d81d83`): the skip kept, made deliberate and logged by id; the U3 record's CORE LINE item 7
  amended in place; pin `FileLessWordsTests.anItemThisBuildCannotReadIsSkippedAndSaidNeverSilently` (`✔ 13 tests in 2
  suites` with `NewWordsResumeTests`) — RED BY BEHAVIOURAL REVERT (the log line removed — the unstated guess) → `✘ … 2
  issues`, restored `cmp`-identical. The trace: THE DISPOSITIONS below.
- **MINOR-2** (the pane's one read runs three times per appearance) — AGREE, FIXED (`48b92904e` + the order pin
  `dab9ab480`). Pin `ProtectionPaneWaveTests` (4, headless — the harness `✔ 270 tests in 43 suites` at the fix commit, the
  suite `✔ 4 tests in 1 suite` after the order pin) — RED BY BEHAVIOURAL REVERT (the wave calling each section's own
  refresh — the pre-fix appearance) → `✘ … 3 issues` (three fetches, not one); MUTATION (the read numbers taken AFTER the
  read) → `✘ aSectionsOwnReadDuringTheWaveIsNeverOverwrittenByIt`; each restored `cmp`-identical. Two Mac source pins
  FLIPPED deliberately (`RoadAccountSurfaceTests` / `RoadKeyDoorSurfaceTests` — the pane's one `.task`; the bootstrap's
  wiring). `build-for-testing` green, no warning in a touched file. The trace: THE DISPOSITIONS below.
- **NIT-1** (the `.signIn` services-nil fallback's untrue sentence) — AGREE. NOT-STARTED.
- **NIT-2** ("now … now" in Move's and the join's moved receipts) — AGREE. NOT-STARTED — a reword in `ProtectionWords`'
  VX-308 U2 section, sentence case, PROVISIONAL with the bundle row.
- No revert is in flight (MAJOR-1's three mutations ran on `653d236c2` and were restored `cmp`-identical).

**THE DISPOSITIONS (per finding; for round 2's fresh reviewer):**

**MAJOR-1 — AGREE, FIXED.** *My trace (self-made, line by line; the finding's mechanism confirmed and widened):* the door's
act (`regenerateWords`, `KeyDoorProgram(act:, mintsKeyFile: true)`) begins — the act in flight written to the record and
this Mac's memory item, then the sealed plan (`["vault","keyFile","memory"]` synced, `["keyFile","memory"]` unsynced;
`toFingerprint` nil). The words exist only in the process (`ActSecrets`); a plan never holds a secret. The process dies.
The next quiet open (rule 27's state is reached by the silent item; the open passes `TypedSecrets.none`) settles:
`settleAct` finds the plan sealed under the library's key and named by the section → `resume`. `derive(.none)` → no
words; a key door's `pastCommitPoint` is TRUE (`toFingerprint` nil), so neither resume-level rollback fires; the
registry's `KeyDoorProgram(act:)` has `mintsKeyFile` false. At the `vault` step: `guard let words … else { throw
secretsRequired }`; at the `keyFile` step: the mint arm skipped → `noLiveKeyFile` (file-less) or `secretsRequired` (a file
standing). Neither is an `ActRollback` → out of `drive`, `resume`, `settle`; the open road logs "could not settle" and opens
anyway — the act stays in flight, so `Assess`' rule-27 arm (it requires nothing in flight) no longer even raises the banner,
and every act refuses `actInFlight`, the door's own mint included. The pin found it at EVERY stop between the begin and the
key-file step's plan record (Standard unsynced writes 3–4; synced 3–6), and in the everyday new-words act too (F-U3-2's
"above all" case) — so the fix covers `regenerateWords` in both arms, which the finding's "at least the minting act" allows.
*The fix (`KeyDoors.swift` only):* `KeyDoorProgram.resumeCannotFinish` — on a RESUMED `regenerateWords` the `vault` and
`keyFile` steps first check for what they need: the act's words in hand, and a live key file of the key to lock (a resume
never mints); either missing → `ActRollback` BEFORE anything is written → `drive`'s one existing rollback → `.rolledBack(.
regenerateWords)`. A landed vault write stands as any landed CAS write does (the account's words are then values nobody saw
until the next New Words re-wraps them — the finding's accepted consequence; the account still opens by its passphrase).
Untouched: every press (`resuming` false — pinned load-bearing by M1-c), a resume holding words with its key file (the
scenario world's model — pinned), Change and Reset (the F-U3-2 ticket's design call), the plan-less finish (`["memory"]`).
*Residue, recorded honestly (not built — each is F-U3-2's general design question, for its ticket):* (1) the post-write
window — a stop AFTER the key-file step wrote but before the plan recorded it rolls back with the live file keeping the
act's unseen words lock (`rollBack` restores a file only across a key change; restoring the mirror's older lock would be a
repair by guessing, rule 21) — the library opens by its quiet road or passphrase and New Words re-mints at once (pinned by
the loop's stop after that write); Change/Reset carry the same window. (2) Rule 20's "says which": the new road's open
records a rollback in Diagnostics only (`report.settle`) — pre-existing for every act, not this finding's. (3) A press-time
race (a file or mirror appearing between the press and the key-file step) still leaves the act in flight for the session
(the press path is byte-unchanged); the next open's resume now rolls it back. **For the closeout (the orchestrator's):** the
F-U3-2 ticket's body names this arm as FIXED here (`regenerateWords`, both arms, VX-447's door un-wedged) and keeps
Change/Reset and residue (1); its Medium priority was set on U3's "no worse" premise, now moot for the words act.

**MINOR-1 — AGREE (the record overclaimed), disposition (b): the skip kept, deliberate and said.** *My trace:* the finding is
right that `try? decode … else { continue }` reads an undecodable remembered payload as "no mirror" while U3's record said
"never a guess". Option (a)'s premise — refusing keeps the payload for a later build that reads it — does not hold on this
road: the unlock reads THIS library's undecodable item as nothing remembered (`DeviceMemory.opening` → nil), so the open's
repair pass finds the memory not following (`Assess.memoryFollows` false) and runs `refreshMemory`, which REWRITES this
library's item and DELETES every other library's (rule 21's one-library rule, `ExecutorRepairs`) — before the banner, the
card or Settings is reachable. Every act's begin (`perform` → `writeFacts` → `writeMemory`) rewrites it again. So at the
door's moment an undecodable item can exist only if another process wrote it after the open; refusing then would protect a
payload the next open rewrites anyway, at the cost of refusing rule 27's recovery road. The skip is now logged by id (eight
characters — never key material) and the doc comment states it; the U3 record's sentence amended in place. No behaviour
changed (the pin's mint is green on both trees; its log assertions are the red).

**MINOR-2 — AGREE, FIXED.** *My trace:* the pane's three `.task`s each awaited a section's `refresh()` → its bootstrap
road's `read` → `ProtectionPaneRead.read` (a `session.system.facts` gather — keychain enumerations, key-file and catalogue
reads — and, signed in, one `fetchVault` over the wire), concurrently and independently: three gathers and three GETs per
appearance, each section derived from its own snapshot. U1's R-2 ("the crossings' faces and the account faces derive from
that one assessment") meant ONE. Not a wrong act (every press re-reads — VX-108), so no correctness pin; the evidence is
the fetch count. *The fix:* `ProtectionPaneRead.wave` takes the one read ONCE and derives the three faces through the SAME
functions each section's road uses (`ProtectionCrossings.readCrossings(…, read:)`, `ProtectionPaneRead.accountFaces(_:
session:)`, `ProtectionKeyDoorRoad.faces`); `ProtectionPaneRefresh.wave` takes each section's read number BEFORE the read
and lands by each section's own landing rule (the models' `refresh` split into `beginRead` + `land`, behaviour unchanged),
so a section's own newer read is never overwritten (pinned); `RoadStandingModel.refreshPane` takes the bootstrap's wave
road (`AppBootstrap.paneWave`, off-main, wired at each new-road ready) and falls back to the three own reads when none is
given (hand-made faces). Kept as they were, deliberately: every OTHER refresh trigger (a confirm's close, an act's
`landed` chain, a sign-in sheet's close, the signed-out road's Continue) re-reads only its own section with its own fresh
read — those are single-section events; and F-U1-4's `services?.encryption.refresh()` task (today's road) is untouched.

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
- 2026-10-19 ~04:45 MDT — **THE REHEARSAL DONE (§6 REHEARSAL RECORD):** the fresh chain whole and sweep-identical to
  production; artifact 17 `[]` first run, verify tail exact, the backfill right on both planted arms; findings R-1
  (fresh-chain overlay order — recorded) and R-2 (the sweep's sync_reencrypt row now marker-aware — fixed in repo,
  pins green 83/2). The throwaway speaks marker 14, ready for the account-arm walk. NEXT: U1 (the account section's
  faces — a fresh Opus implementer on §5a).

- 2026-10-19 ~05:15 MDT — **U1 CLOSED but for the walk and the ladder** (the §6 U1 RECORD + arbitration + Mac-batch
  paragraph): the account section's faces on the new road (the one presenter, the doors from assess, sync setup, the
  three local leaves, the signed-out road, the walk's project switch), 223/42 under the stage with one fixed
  vocabulary red, the bootstrap pin red-on-old by behavioral revert. VX-239/VX-243/VX-264 land with VX-418's trunk.
  NEXT: VX-314's engine-mouth gate (the orchestrator, headless), then U2 (the join + follow faces).
- 2026-10-19 ~07:10 MDT — **U2 CLOSED but for the walk and the ladder** (the §6 U2 RECORD + Mac-batch paragraph):
  the join (the plan said at the consent, one secret, the words moment both arms), the follow in/into/out with
  VX-107's once-said Done and VX-113's ruled sentence, the one reopening seam shared with the crossings; 324/48
  under the stage, the one host-crash traced to U1's test fakes and fixed. NEXT: U3 (the key doors + VX-447/VX-448).
- 2026-10-19 ~08:35 MDT — **U3 CLOSED but for the walk and the ladder** (the §6 U3 RECORD + arbitration + batch
  paragraph): the key doors through the one presenter, VX-447's banner-becomes-the-door with the one core custody arm
  (KeyDoors.swift alone, red-on-old), VX-448's concealed clear-at-lock/quit clipboard, F-U2-3's say-before-mint line;
  200/42 under the stage with one source pin re-anchored. NEXT: U4 (the lock + the hold's gate), the last implementer
  batch; then the ladder, then the walk.
- 2026-10-19 ~09:55 MDT — **U4 CLOSED but for the walk and the ladder**; the implementer era done (U1–U4 + VX-314
  all built, batched under the stage, arbitrated). NEXT: THE LADDER round 1 — a fresh fable-reviewer over the phase's
  whole diff (custody + the one Sync/ gate ⇒ Fable), notes/REVIEW_PROMPT.md verbatim, headless.
