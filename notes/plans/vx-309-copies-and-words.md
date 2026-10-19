# VX-309 — Castle rebuild, phase 5: copies and words

**Status: OPEN — KICKED OFF 2026-10-19 (session `vx-309`, `/architect-phase`; the orchestrator is Fable at xhigh).**
`Ticket: VX-309 · Project: Castle & backups before launch · Branch: vx-309-copies-and-words · Worktree: ~/dev/variorum-vx-309 (Pro)`
The copies' machinery and the words' truth, built to `notes/CastleRules.md` rules 17–19, 21 and 27 — the old VX-266
design is superseded wherever they differ. The one law carries forward: the new road stays DEBUG-ONLY behind
`ProtectionRoad.newRoadIsLive`; `SyncSchema.lockstepVersion` STAYS 13; the mirror artifact
`Server/supabase/17_phase_vx307_vault.sql` stays HELD (it is REHEARSED — green first-run on a real-Postgres mirror at
VX-308, the chain runbook proven, the grant sweep marker-aware; `notes/plans/vx-308-accounts-key-doors.md` §5R/§6);
the deploy and the marker-13→14 bump ride VX-329's release. The throwaway project is HERS to delete at merge+release
of the whole rebuild — this phase does not touch it unless a walk arm needs a synced library (then the VX-308 switch
and discipline, `~/.variorum/dev-vault-throwaway.env`, values never echoed or committed).

> **KICKOFF MESSAGE (paste-ready).** STEP 0: the bout ritual (pull both repos, `Tools/vx sync`), then from
> `~/dev/variorum` on `main`: `git worktree add -b vx-309-copies-and-words ~/dev/variorum-vx-309 origin/main`; push
> the branch; the in-flight row (HOLDS the Sync/-custody slot — the copies are custody work); Linear VX-309 → In
> Progress; announce to the stage coordinator. **Read first, in full:** CLAUDE.md + its canon;
> `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` WHOLE (rules 17–19, 21 and 27 are this phase's heart,
> and the considered-and-not-pursued ledger binds); `notes/SyncSpec.md` WHOLE (the custody slot's price);
> `notes/SurfaceContracts.md`'s protection and doors sections; `notes/plans/vx-308-accounts-key-doors.md` §6 — the
> U3 record's pair road (`ProtectionBackupPair.swift`, rule 5's one road every backup rides) and the U4 record's
> by-library export mark are the seams this phase extends, and THE WALK RECORD's machinery notes save a night;
> the lifecycle page `notes/plans/vx-266/castle-lifecycle.html` stages 9, 10, 13 and 14 (the walk asserts against
> them; never hand-edit the page); QUESTIONS #235 (her guide ruling) and #236 (the standing VX-308 bundle — her
> acceptance may land rulings this phase builds); the VX-309 ticket's body (the member list is its); the VX-379
> ticket (the field guide's standing acceptance — the guide and Data Safety's words are rewritten against the rules
> AS BUILT, the truth-check at VX-329's release).
>
> **The cut (guidance, the kickoff session's to make):** two phase-sized units under one theme — U1 THE COPIES
> (machinery + faces), U2 THE WORDS (sentences + the guide chapters) — with the walk and restore drill as the
> acceptance spine. Riders: the kickoff checks the open Low/Medium tickets in Castle & sync and Settings &
> onboarding and offers them to her — the standing candidates from VX-308's close are VX-450 (Medium — the stuck-act
> class's remainder: Change/Reset share it), VX-449, VX-451 (the pane's Lock Now row + idle dial — a natural U1/U2
> rider), VX-452, VX-453 (Settings search misses the account section), VX-454. Already RIDING at her word: VX-456
> and VX-457 (words-unit members below). VX-455's compose is POST-RELEASE at her word (2026-10-19) — only its
> not-yet line rewords here. W-VX308-3 is RULED keep-app-level (record-only, nothing to build).

## 0. THE KICKOFF RECORD (2026-10-19, the orchestrator — session `vx-309`)

**STEP 0 done:** bout ritual (both repos pulled; `Tools/vx sync` → 245 open, snapshot pushed as "board snapshot");
worktree `~/dev/variorum-vx-309` cut from `origin/main` (`d3bb6a791`), branch pushed; the in-flight row on main
(`d41aff958` — HOLDS the Sync/-custody slot); Linear VX-309 In Progress (the branch-link automation); the stage
coordinator (`1018coordinator`) announced.

**THE COORDINATOR'S GRANT AND TERMS (received 2026-10-19, recorded verbatim-faithful):** the custody slot is
GRANTED as of 16:57 MDT (VX-308 freed it at 13:53; nothing else in flight; the slot frees at this phase's hard-stop
"nothing further owed"). THE STAGE IS NEVER SELF-CLAIMED: REQUEST it (what, minutes, claim name) and send READY only
when able to start NOW; the coordinator answers with a GO carrying the exact claim line; a free stage is never an
invitation; headless `swift build`/`test` and `xcodebuild build`/`build-for-testing` need no stage, EVERY
`xcodebuild test` does. THE MERGE runs only on the coordinator's GO-MERGE after a MERGE ASK at the ladder's close
(merge commit, never squash; origin/main in the branch; nothing outside notes/ changed since the tested tree).
**Dev-store facts at VX-308's close:** library `86a82b4f`, Standard (new road), the dev pair intact
(`~/.variorum/dev-castle.env`, words = `VARIORUM_DEV_NEWROAD_WORDS`); quiet open on main's Debug build; the
restore-hold marker beside the slot (63 B) so the Resume Sync banner shows — NEVER press Resume; the Debug app
SIGNED OUT; `appearanceChoice` dark; `variorum.backup.markdownInsurance.enabled = 1`; newest safety copy
`Backups/safety-copies/variorum-vx308-walk-2026-10-19T165332Z`; any synced arm uses the THROWAWAY project through
VX-308's walk switch (`~/.variorum/dev-vault-throwaway.env`), never production — every launch asserts the ref is
*[removed for publication]*
instances, then a cmp-verified safety copy of EVERY slot file, listed without an extension filter (the lived-here
marker is extensionless); (2) throwaway libraries outside the slot, removed or listed; (3) pre-export
`io.lduarte.Variorum.debug` and an end-diff against it — `defaults import` merges, so delete added keys and restore
found values; (4) credentials from the env files only, never looked at, never in any record, commit or message;
(5) planted env per-launch only; (6) the result line names end posture, library ID, restore hold and banner,
Keychain adds, and 0 instances; (7) window-scoped captures only; stop and tell the coordinator on any interference;
(8) renew after EACH ROW, not by the clock — a silent lapse past expiry is held by the coordinator until the dev
store's state is reported.

**Preflight COMPLETE (the orchestrator, nothing delegated):** CLAUDE.md + its auto-loaded canon; the master plan
(in-flight + latest closeout); the workflow-transition record; `notes/TICKETS.md` (2026-10-19 16:54 snapshot);
QUESTIONS #235 + #236 (every headline item ruled at her 2026-10-19 sittings; this kickoff is the bundle's
acceptance of the rest — the QUESTIONS status flip is the merge moment's); this plan; the resiliency protocol
whole; `notes/CastleRules.md` WHOLE (rules 17–19, 21, 27 + the considered-and-not-pursued ledger); `notes/SyncSpec.md`
WHOLE; `notes/SurfaceContracts.md` whole (the protection and doors sections this phase touches, plus the app's
words rules); `notes/plans/vx-308-accounts-key-doors.md` §6 — the U3 RECORD (the pair road `ProtectionBackupPair.swift`,
rule 5's one road; VX-447's core arm; the key doors), the U4 RECORD (the by-library export mark `ExportNoticeMark`;
the lock; F-4's hold gate) and THE WALK RECORD (machinery: renew-by-row, the walk switch's ref guard, the
`VARIORUM_WALK_FORGET=memory` switch, the aside-whole pattern, F-U2b-5 — never a words look on the dev library);
the lifecycle page stages 9, 10, 13, 14 (the walk asserts against them; never hand-edited); the VX-309 ticket body
(the member list); the VX-379 ticket (the guide's standing acceptance: every Castle face phase carries "the guide
and settings copy agree with the rules as built").

**#236 ACCEPTANCE NOTED:** her kickoff of VX-309 counts as accepting the VX-308 bundle's remaining PROVISIONALs
(the entry's own words); recorded here at kickoff, the QUESTIONS edit itself deferred to the merge moment per the
shared-ledger rule.

**HER KICKOFF RULINGS (the sitting, 2026-10-19 — verbatim-faithful):**
- **Riders:** she picked the faces set (VX-451 + VX-453 + VX-454) and delegated the rest: *"which of these do you
  think are most important to release ? VX-450 seems important enough to join along with the top 3, but I'm not sure
  if anything else should be included"*. **The orchestrator's delegated call (the reasoning in the ledger below):
  VX-450 joins** (her instinct — a crash mid-key-door wedges every later act; Confirmed, Medium, release-worthy);
  **VX-444 joins** (the words-recorded ledger across Make this my library — the card re-offers a pair she already
  recorded, a user-visible confusion sitting in this phase's OWN surface: T-5 and the VX-305 hand-off build exactly
  that door); **VX-449, VX-452, VX-101, VX-100 stay out** (VX-449: the press already refuses honestly — post-release
  polish; VX-452: Suspected, a narrow crash-timing edge, not release-gating; VX-101/VX-100: v1-readiness
  improvements for a later sweep, not this phase's seams). Riders therefore: **VX-450 · VX-451 · VX-453 · VX-454 ·
  VX-444**, plus the standing **VX-456 · VX-457**.
- **Cast:** the standing default confirmed (Fable orchestrates + cold-reviews — custody diff; fresh Opus
  implementers at xhigh, one per batch, one subagent at a time).
- **The unit cut:** *"U1 copies → U2 words"* confirmed — copies first so the words are written against the faces
  as built (VX-379's acceptance reads "the rules as built").
- **VX-211:** *"Floor + quiet hint"* — the 12-character floor stays the only refusal; the set/change fields gain
  one honest, calm strength line (an estimator's verdict as advice), never a block, never a meter bar.

## 1. The members (the ticket's list, restated; the kickoff session cuts the units)

**U1 — THE COPIES (rules 17–19, 21, 27):**
- The pair leg landing in the picked backup folder (P-VX306-U1a-4's deferral comes due).
- **VX-397** — the far due-check and Data Safety's count read the catalogue PER LIBRARY PER MAC (closed by
  construction when the catalogue read lands).
- **VX-302** — retention of this Mac's own pairs of this library on the new road (**VX-411** folded in: pairs
  accumulate with no retention today).
- **VX-265** — a separate delete choice for other libraries' copies (rule 19 — never silently, never bundled).
- **VX-210** — the honest line about copies in folders Variorum doesn't manage.
- **VX-209's remainder** — the synced confirm's sentence only (the mechanism closed by rule 17, built at VX-306).
- **T-5** — the empty-slot landing: Make this my library from the missing face, with no library open.
- **VX-305's second hand-off** — reopening this Mac's own set-aside copy (Previous Libraries) through the doors
  (her tracker carries it beside T-5).
- **T-8** — a plaintext export brought in as a NEW library (bulk entry through the import road; never reconciled truth).

**U2 — THE WORDS:**
- **VX-211** — passphrase strength (the floor stands; what more, if anything, is a design row for her).
- **VX-213's remainder** — pg_temp at her go, the record corrections, the privacy text.
- **VX-264's copy words** — item 5's set-aside sentences and item 7's concrete per-library-shape confirm line
  (VX-264 itself closed at VX-308; THESE TWO ITEMS live here by its body's own pointer — the reconciliation note).
- **VX-263's route-finder sentence** as reworded: *your current passphrase or words; on this Mac, its quiet road if
  it still holds that key.*
- **The join moment's reword + VX-456** (her rulings 2026-10-19, the handoff sitting). The moment reads in the
  library-adopts-account direction and NAMES THE ACCOUNT BY EMAIL — her refined draft, verbatim: *"Your twelve words
  are xyz (show the email)'s twelve words. If this is your first time signing in, your previous twelve wrods still
  open backups you made before today. If you don't have your account's words written down, you can make new ones at
  any time"* (superseding her first draft; the shipped phrasing read as if the ACCOUNT's words had been replaced by
  the library's, the wrong direction). Her note on the middle clause: with VX-456 built, "If this is your first time
  signing in" is unneeded (the moment then fires only on a real replacement, so the previous-words clause applies
  unconditionally) — "but it's fine to leave it too I suppose"; the builder drops it when VX-456 lands in the same
  unit. **VX-456** rides this unit — the core same-words line (the library's words lock compared to the vault's
  recovery wrap) so a same-words re-join's moment stays quiet; her word: "it's nice polish… if it naturally slides
  into phase 5 we can do it there" (it does — this unit owns the sentences and the phase holds the custody slot).
- **VX-457 rides as a rider** (her ruling 2026-10-19: "I agree with B" on P-VX308-U2-7): the follow's Done becomes a
  durable pane notice until OK (the export-notice idiom — survives `receipt_style` off and a quit).
- **Move's not-yet line names the road** (her ruling 2026-10-19: "reword that line to name the road & then leave
  VX-455 for post release"): `ProtectionWords.moveNotYet` stops saying "isn't ready in this build yet" and says the
  two-press road — leave this account (This Mac Only), then turn on sync while signed in as the other account; this
  library's pair becomes that account's. The one-door compose (VX-455) is post-release; the ticket's comment carries
  the ruling.
- **The field guide's Castle/backups chapters and Data Safety's words** against the rules as built (VX-379's
  standing acceptance + the Start Here chapter leads; her #235 ruling: written HERE; the truth-check AND the real
  store's re-seed ride VX-329's release window). **F-U2c-4 rides:** the new road's Data Safety gains its "what
  opens a backup" line (rule 5). The guide is the seeded field-guide book — the seeder and VX-379's ticket say
  where its chapters live.

**Superseded and gone (never build):** the family tree, the Castle offer's old-shared-key sheet, the key-map
acceptance table (the walk page replaced it).

## 1b. THE UNITS AND THE ORDER (the kickoff session's cut, under her ruled U1→U2 order; one acceptance unit per
implementer session, sized per `notes/PhaseSizingGuidance.md` — the phase's two themes, three implementer batches)

- **U1a — THE COPIES' MACHINERY (core custody; a fresh Opus implementer, headless + build-for-testing only):**
  the pair leg landing in the PICKED backup folder (P-VX306-U1a-4's deferral comes due); the far due-check and
  Data Safety's count reading the catalogue PER LIBRARY PER MAC (VX-397 closes by construction); retention of this
  Mac's own pairs of this library on the new road (VX-302, VX-411 folded); **rider VX-450** — a key-door act that
  cannot resume for want of secrets ROLLS BACK (rule 20's "the old state") instead of wedging. Evidence: exact
  state-transition pins red-on-old, revert-verified; the protection set green Debug + Release.
- **U1b — THE COPIES' DOORS AND FACES (a fresh Opus implementer, headless + build-for-testing only):** T-5 (Make
  this my library from the MISSING face, no library open — the empty-slot landing); VX-305's second hand-off
  (reopening this Mac's own set-aside copy, Previous Libraries, through the doors); T-8 (a plaintext export brought
  in as a NEW library through the import road — bulk entry, never reconciled truth); VX-265 (the separate delete
  choice for other libraries' copies, rule 19 — never silently, never bundled); VX-210 (the honest line about
  copies in folders Variorum doesn't manage); **riders VX-444** (the words-recorded ledger carries across Make this
  my library), **VX-451** (the pane's Lock Now row + idle dial through `changeSettings` — F-U4-1's first option)
  and **VX-454** (the Set-a-passphrase row re-reads after an act sets one). Evidence: pins red-on-old; Mac suites
  under the stage; the walk rows.
- **U2 — THE WORDS (a fresh Opus implementer, headless + build-for-testing only):** VX-211's quiet strength hint
  (her ruling above; the estimator a pure Domain rule); VX-213's remainder (pg_temp AT HER GO only, the record
  corrections, the privacy text); VX-264's items 5 + 7 (the set-aside sentences, the concrete per-library-shape
  confirm line); VX-263's route-finder sentence as reworded; VX-209's remainder (the synced confirm's sentence);
  the JOIN MOMENT reword to her email-naming draft + **VX-456** (the core same-words line; the middle clause drops
  with it); **VX-457** (the follow's Done as a durable pane notice until OK — the export-notice idiom);
  `ProtectionWords.moveNotYet` reworded to name the two-press road (VX-455 stays post-release); the field guide's
  Castle/backups chapters + Data Safety's words against the rules AS BUILT (VX-379's acceptance; F-U2c-4's "what
  opens a backup" line; the Start Here leads; the truth-check and the real store's re-seed ride VX-329);
  **rider VX-453** (Settings search surfaces the account section). Evidence: words pins against the plan's drafted
  lines; the guide's seeded-content checks; Mac suites under the stage; both-voices captures at the walk.
- **Then:** the ladder (fresh `fable-reviewer` per round over the whole diff — custody ⇒ Fable), the WALK + the
  restore drill as the acceptance spine (stages 9, 10, 13, 14 asserted against the faces as built), the closeout.

## 5a. U1a BRIEF — THE COPIES' MACHINERY (a fresh Opus implementer; headless + build-for-testing ONLY)

**You are the U1a implementer for VX-309 (Castle rebuild, phase 5). Work from `~/dev/variorum-vx-309` on branch
`vx-309-copies-and-words` — never the main checkout. HARD LIMITS: no `xcodebuild test`, no stage claim, no Debug app
launch, no store touch, no live network call, no Linear write, no subagents; headless `swift build`/`swift test` and
`xcodebuild build-for-testing`/`build` are your whole surface. Today's road stays BYTE-UNCHANGED in behaviour
(Release parity — every new line sits behind the new road's session/hook or new-road-only code; `StoreBackup.swift`'s
own legs keep running as they are). Zero `Sync/`, `Server/`, schema, migration or dependency lines;
`SyncSchema.lockstepVersion` stays 13. The resiliency protocol binds: commit per piece, push after every commit, LIVE
STATUS in your record from the first commit, PENDING on every unverified claim, synchronous foreground waits only.**

**Read first, in full, never delegated:** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/CastleRules.md` WHOLE (rules 1, 4, 5, 17–19, 20–21, 25 and 27 are this unit's law; the
considered-and-not-pursued ledger binds); `notes/SyncSpec.md` WHOLE (the custody slot's price; you write no `Sync/`
line); `notes/SurfaceContracts.md` (Doors — portability + Library protection); this plan WHOLE (§0–§3); the VX-308
record `notes/plans/vx-308-accounts-key-doors.md` §6 — the U3 RECORD (the pair road, THE CORE LINE, the mutation
discipline), the U4 RECORD and the ROUND-1 FIX LEG (MAJOR-1's trace, fix and residue — your VX-450 piece extends
exactly it); the VX-306 record `notes/plans/vx-306-castle-open-road.md` §6 U1a RECORD (the catalogue's birth,
P-VX306-U1a-1..5) and its U1b RECORD (the hook's birth); the code — `Sources/VariorumCore/Protection/` `Assess/
Catalog.swift` · `CatalogNames.swift` · `Retention.swift` (pure, UNWIRED — your piece 3 wires it) · `Assessment.swift`
· `Executor/Leaves.swift` (`BackupsLeaf`) · `Executor/Acts/KeyDoors.swift` (`resumeCannotFinish` — guards
`.regenerateWords` only today) · `PlanRunner.swift` (`resume`, `settleAct`, the rollback) · `Acts/CommonSteps.swift`;
the app side — `App/Variorum/Shared/Protection/ProtectionBackupPair.swift` (rule 5's one road) ·
`ProtectionBackupHook.swift` (the `StoreBackup.onRun` attachment) · `FileBackupsLeaf.swift` · `CatalogLister.swift` ·
`ProtectionPlaces.swift` (`farFolder()`, `withFile(catalogID:)`) · `StoreBackup.swift` (READ ONLY — the far leg's
due-check and `newestTrustedBackup`/`stampIsTrusted`, `BackupDestination`, `recordOwnFarSnapshot`) ·
`App/Variorum/Variorum/Features/Settings/DataSafetyModel.swift` (the counts; VX-379's road gating pattern,
`VX379PaneRowsTests`); the test worlds (`ExecutorWorld`, `EX`, `PlantedRoad`, the scenario world, `NewWordsResumeTests`,
`FileLessWordsTests`, `ProtectionBackupHookTests`, the retention suite under `Tests/VariorumCoreTests/Protection`).
The headless HARNESS recipe is VX-308's §6 U1 RECORD COUNTS paragraph (the scratchpad package `u1-harness` pointed at
this worktree — rebuild it per the recipe in YOUR session's scratchpad).

**The pieces (each a commit or a small series, pins first where a pin can be red-on-old):**
1. **THE FAR PAIR LEG (P-VX306-U1a-4's deferral comes due — rule 5 reaches the picked folder).** On the new road,
   a backup run that wrote a snapshot also lands rule 5's pair in the PICKED far folder, in the catalogue's shape
   `<picked>/Variorum/Backups/<library8>/<mac8>/` (`CatalogNames`' names; the snapshot + its frozen `.keys.json`
   beside it, written once, never rewritten), under the far folder's own due-ness: due when the catalogue holds NO
   trusted-stamped far pair OF THIS LIBRARY BY THIS MAC newer than the backup interval (`StoreBackup.stampIsTrusted`
   is the one freshness rule — reuse it or restate it byte-equal in core; a future stamp is not freshness). Copies
   paused ⇒ nothing; the live key file not the key's ⇒ nothing; no far folder picked or unreachable ⇒ nothing (the
   honest line about that is U2's words, not yours); failures logged, never raised; security-scoped access through
   `places.farFolder()!.withAccess`. Today's flat far leg keeps running untouched beside it.
2. **VX-397 CLOSES BY CONSTRUCTION — the new road's reads are PER LIBRARY PER MAC.** The far due-check of piece 1
   reads the catalogue (this library, this Mac, `.farFolder`, trusted stamps) — never the folder's newest flat file.
   Data Safety's counts on the NEW ROAD read the catalogue the same way (this Mac's pairs of this library per place),
   through the existing road-gating pattern in `DataSafetyModel` (VX-379's precedent); today's road's counts are
   byte-unchanged. Pin the wrong-shape red: another Mac's fresh copy (a planted `<library8>/<othermac8>/` pair) must
   NOT satisfy this Mac's due-check and must NOT count as this Mac's copy.
3. **RETENTION WIRED (VX-302; VX-411 folded).** After a pair lands (container or far), the new road prunes by core's
   `Retention.plan` (policy `.standard`: container newest-14; far 14 dailies + 4 weeklies) over a FRESH catalogue
   read, removing exactly the plan's `prune` ids through `FileBackupsLeaf.deleteCopies` (each snapshot with its own
   pair; far ids under `withAccess`). The pure rule already fences: only `.backup` kind, only this Mac's `mac8`
   subfolder of this library's `library8`, undated copies never pruned, `Previous Libraries/` and safety copies
   never candidates, foreign names never touched (rule 19's other-libraries listing is U1b's DOOR — nothing here
   deletes another library's copies). Off the main actor, logged (what was pruned, by id), failures logged never
   raised. Pin red-on-old: pairs past the policy accumulate before the wiring, are pruned after; another Mac's and
   another library's planted pairs SURVIVE every prune (the mutation pin: the guard off reproduces today's VX-302
   shape).
4. **VX-450 — the stuck-act class's remainder.** Extend MAJOR-1's rollback (`KeyDoorProgram.resumeCannotFinish`,
   `Acts/KeyDoors.swift`) to `changePassphrase` and `resetPassphrase`: a RESUMED key-door act that cannot finish for
   want of its secrets (or of a live key file of the key where the step needs one) throws `ActRollback` BEFORE
   anything is written — rule 20's "the old state" — instead of wedging every later act behind `actInFlight`. The
   press path stays byte-unchanged (`resuming` false — M1-c's guard is load-bearing, keep its pin green). Pins
   red-on-old per act and per stop point (the `NewWordsResumeTests` loop pattern; the pre-fix tree must wedge).
   MAJOR-1's residue (1) — the post-write window where a landed write keeps an unseen lock — stays RECORDED for
   these acts exactly as the fix leg recorded it for the words act (one honest paragraph in your record; not built).

**Evidence at the close (the record's COUNTS):** every new pin red-on-old verified by revert or mutation, restored
`cmp`-identical from a committed tree; the protection set green Debug AND Release (`swift test -c release`); the full
core suite Debug (the known VX-353 MCP flake is recorded, not yours); `xcodebuild … build-for-testing` green with no
warning in a touched file; the phone build green; the Release build check green. Your record lands IN THIS FILE as
"U1a RECORD" on the VX-308 §6 form (Not-done-first · preflight · readings R-U1a-N · LIVE STATUS per piece ·
THE FACES/LINES AS BUILT for the ladder · COUNTS · the Mac-suite list the orchestrator runs under the stage ·
PROVISIONALs as P-VX309-U1a-N with options · findings as F-U1a-N routed never fixed · machinery notes). Ambiguity
that doesn't gate: build the spec-defensible arm, mark PROVISIONAL, log the options in your record (the orchestrator
bundles QUESTIONS rows at closeout). Ambiguity that gates the core: stop and report in your record.

## 2. Evidence (the acceptance spine)
Walks in BOTH VOICES (Terminal and Study) over the new faces; the restore drill through Look inside and Make this my
library; the lifecycle page's stages 9, 10, 13 and 14 against the faces as built. Headless + build-for-testing for
implementers; the orchestrator runs Mac suites and walks under a held stage claim (the coordinator's terms). The dev
store's restore hold and banner stand; never press Resume.

## 3. Open questions riding into kickoff
- #236's HEADLINE ITEMS ARE ALL RULED at the 2026-10-19 handoff sitting (the entry carries her words verbatim): the
  join moment rewords to her email-naming draft (a words-unit member, with VX-456); W-VX308-3 keep app-level
  (record-only); P-U2-7 → VX-457 (a rider here); F-U4-3 keep as built (record-only); VX-455 post-release, its
  not-yet line reworded here. The rest of the bundle rides her kickoff as acceptance.
- VX-211's shape — the strength ask is design-flavored; bring options to a sitting rather than invent.

## 6. RECORDS (each unit appends; the VX-308 §6 form)

### U1a RECORD — THE COPIES' MACHINERY (Opus implementer, 2026-10-19; the far pair leg + VX-397 + VX-302/411 + VX-450 — IN PROGRESS)

**Not done in U1a, first:** PENDING — written at the close (the brief's hard limits: no `xcodebuild test`, no stage, no
Debug launch, no store touch, no live network call, no Linear write, no subagents — every Mac-only pin is BUILT, its run
the orchestrator's under the stage).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE (rules 1, 4, 5, 17–21, 25, 27 + the considered-and-not-pursued ledger); `notes/SyncSpec.md`
WHOLE (no `Sync/` line here); `notes/SurfaceContracts.md` whole (Doors — portability + Library protection); this plan
whole (§0–§3, §5a); `notes/plans/vx-308-accounts-key-doors.md` §6 — the U1 RECORD's COUNTS (the harness recipe), the U3
RECORD (the pair road, THE CORE LINE, the mutation discipline, F-U3-2), the U4 RECORD, the ROUND-1 FIX LEG (MAJOR-1's
trace, fix and residue) and the ladder's close; `notes/plans/vx-306-castle-open-road.md` §9 U1a RECORD (the catalogue's
birth, P-VX306-U1a-1..5 — P-VX306-U1a-4 is piece 1) and U1b RECORD (the hook's birth); the core —
`Assess/Catalog.swift` · `CatalogNames.swift` · `Retention.swift` · `Assessment.swift` · `Executor/Leaves.swift`
(`BackupsLeaf`) · `Executor/Acts/KeyDoors.swift` · `PlanRunner.swift` (`perform`, `drive`, `settleAct`, `resume`,
`rollBack`) · `Acts/CommonSteps.swift` · `ProtectionGuards.swift` · `Model/Names.swift` · `Files/ProtectionLibraryFiles
.swift`; the app — `Shared/Protection/ProtectionBackupPair.swift` · `ProtectionBackupHook.swift` · `FileBackupsLeaf.swift`
· `CatalogLister.swift` · `ProtectionPlaces.swift` · `ProtectionSystem.swift` · `ProtectionOpenFaces.swift`
(`RoadStandingModel`) · `ProtectionOpenRoad.swift` (the open's settle) · `ProtectionCopyDoors.swift`/`CopyDoorsModel.swift`
(the listing) · `Shared/StoreBackup.swift` (READ ONLY — the far leg's due-check, `newestTrustedBackup`/`stampIsTrusted`,
`recordOwnFarSnapshot`, `pruneSecond`) · `BackupDestination.swift` · `BackupRetention.swift` · `BackupLog.swift`
(`BackupRunRecord`) · `AppServices.swift` (the backup's construction) · `AppBootstrap.swift` (the ready's road wiring,
`copyDoorsRoads`) · `Features/Settings/DataSafetyModel.swift` + `DataSafetyPane.swift` + `SettingsSceneContent.swift`;
the test worlds — `ExecutorWorld`, `EX`, `CrashHarness`, `NewWordsResumeTests`, `U2CrashHarnessTests`, `RetentionTests`,
`CatalogTests`'s `CF`, `ProtectionBackupHookTests`, `PlantedRoad`, `ProtectionTestSupport`, `DataSafetyTests`,
`VX379PaneRowsTests`, the scenario world's backup service (`Alphabet.backupService`, `World.writePair`). HARNESS: U1's
recipe rebuilt in this session's scratchpad (`u1-harness`, swift-tools 6.2, macOS 26, the app's concurrency settings,
this worktree's core by path; the same 51 source + 45 test symlinks the VX-308 fix leg's harness held, re-pointed here):
the BASELINE on `0965d68bd` — `✔ Test run with 272 tests in 43 suites passed` (the fix leg's final count, exactly).
Machinery: the worktree's `.build` seeded by APFS clone from the main checkout's (`checkouts`, `repositories`,
`artifacts`, `workspace-state.json` re-pointed), and every `swift build`/`swift test` run `--skip-update` — no package
fetch, no network.

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U1a-1 — THE FAR PAIR IS THE CONTAINER PAIR, COPIED.** One backup in two places, not two backups (StoreBackup's own
  far-leg reasoning; 18k C7's hand-through rule — the act's own snapshot handed to the far leg, never re-discovered by
  listing; the scenario world's `writePair` writes ONE name in both places). The pair road hands the container pair it
  just wrote to the far leg, which copies both files under the SAME name into `<picked>/Variorum/Backups/<library8>/
  <mac8>/` (`ProtectionNames.backupsSubpath`), written once (an existing name refuses — never overwritten), verified (the
  key file reads back as the live key file; the snapshot opens with the library's key), and a half-landed far pair is
  removed (an orphan snapshot no key file names would sit outside every count and every prune for good).
- **R-U1a-2 — THE FAR LEG RIDES THE PAIR ROAD, ONLY AFTER A WRITTEN CONTAINER PAIR.** Rule 5's one road
  (`ProtectionBackupHook.takePair`) — so the hook's written runs and VX-447's "the backup follows" both reach the picked
  folder. Its own gates are the container's (copies paused ⇒ nothing; the live key file not the key's ⇒ nothing),
  re-checked for the pause at the far copy; no far folder picked, its bookmark unresolved, or the picked folder gone ⇒
  nothing (the leg never re-creates a vanished picked folder — today's flat leg's `withIntermediateDirectories` would);
  every failure logged, never raised. The executor's own `freshBackup` steps (a crossing's pair inside its plan) stay
  container-only: an act's step is never widened to a folder that may be unreachable, and the next written run reaches
  the far folder anyway. Today's flat far leg runs untouched beside it.
- **R-U1a-3 — THE FAR DUE-CHECK IS THE CATALOGUE'S, PER LIBRARY PER MAC (VX-397 by construction).** Due iff the catalogue
  (a FRESH read) holds no backup pair in the far place whose key file names THIS library, filed under THIS library's
  `<library8>` and THIS Mac's `<mac8>`, stamped no later than now (StoreBackup's `stampIsTrusted`, restated byte-equal in
  core) and younger than the backup interval (StoreBackup.Configuration's default 24 h, restated as the pair road's
  constant — both restatements pinned equal to StoreBackup's by a Mac pin). Another Mac's fresh pair, another library's,
  a pair whose key file doesn't read, today's flat files and a future-stamped pair never satisfy it.
- **R-U1a-4 — DATA SAFETY'S COUNTS ON THE NEW ROAD.** The same two rows (*Beside your library*; the picked folder), their
  paths and the folder's set/unset/unreachable states exactly as today; only the row's count, newest and oldest come from
  THIS Mac's pairs of THIS library in that place (newest/oldest over trusted stamps — 18o U1's rule; the count every
  pair, as today's count is every dated file). The gate is `roadStanding` (VX-379's precedent — nil on today's road, so
  today's counts are byte-unchanged): the open library's faces carry a `copyCounts` road built from the open's session
  (Settings re-builds its panes at every reopen — the `.opening` arm — so a road never outlives its library).
- **R-U1a-5 — RETENTION AFTER EVERY WRITTEN PAIR.** Over a FRESH catalogue read once the far leg is done, core's
  `Retention.plan(… policy: .standard)` for the pair's library and this Mac; exactly the plan's `prune` ids removed through
  `FileBackupsLeaf.deleteCopies`, ONE id per call (one failing delete never stops the rest), each logged by catalogue id
  (names and eight-character fingerprints only — never key material); off the main actor (the pair road runs detached).
  Today's flat files, `Previous Libraries/`, safety copies, foreign names, another Mac's and another library's pairs are
  never candidates (the pure rule's fence — the wiring adds no filter of its own, so the guard's mutation reaches it).
- **R-U1a-6 — VX-450: CHANGE AND RESET JOIN MAJOR-1's ROLLBACK.** `KeyDoorProgram.resumeCannotFinish` covers the three key
  doors: a RESUMED act lacking its own secret (the words act: its new words; Change and Reset: the NEW passphrase, the
  plan's fresh descriptor's — a resume typing only the words, or nothing, holds none) or a live key file of the key
  throws `ActRollback` at the vault or key-file step BEFORE writing; a press never reaches it (`resuming` false — M1-c's
  guard kept and pinned). MAJOR-1's residue (1) is recorded for Change and Reset, not built.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton + the readings + the harness baseline: DONE (this commit).
- Piece 1 — THE FAR PAIR LEG (+ the core `OwnCopies` rule it reads): DONE (`8e027494a` core · `2c2b7d412` pins first ·
  `c09b93ed8` the leg). CORE: `Assess/OwnCopies.swift` — retention's one predicate moved there verbatim (`Retention.plan`
  reads it; `RetentionTests` green unchanged), `of` / `summary` / `farPairIsDue`, `stampIsTrusted` restated byte-equal;
  pins `OwnCopiesTests` (5) — with the retention + catalogue suites `✔ 18 tests in 5 suites`. MUTATIONS on `8e027494a`
  (each restored by `git checkout --`, `cmp`-identical to `u1a-prerevert/OwnCopies.swift`): M-OC1 the `<mac8>` check
  dropped → `✘ … 80 issues` (`RetentionTests.overASharedFolderNothingForeignIsPruned` 29 among them); M-OC2 the
  trusted-stamp check dropped from the due-check → `✘ theFarPairIsDueUnless…` (the hour-ahead arm, 1 issue); M-OC3 the
  place filter dropped → `✘` the container arm + the summary + the per-place counts (4 issues). APP: `FileBackupsLeaf` —
  `takeBackupPair`'s body extracted verbatim as `writeContainerPair` (returns the snapshot it wrote; the protocol method
  calls it) + `landFarPair(copying:key:keyFile:deviceID:)` (the files' mechanics: under the picked folder's scope, the
  picked folder must exist — never re-made; the same two names copied; an existing name refused; verified — the key
  file reads back, the snapshot opens with the key; a failed copy removed whole; returns the far catalogue id, nil with
  no far folder); `ProtectionBackupHook` (the pair road, `ProtectionBackupPair.swift`) — after a written container pair,
  `landFarPair(session, snapshot:…, now:)`: no far folder ⇒ nothing; a FRESH catalogue read; `OwnCopies.farPairIsDue`
  over `farInterval` (24 h — StoreBackup's default restated) ⇒ the leaf's copy; logged, never raised; the pair's
  outcome stays the container's. `PlantedRoad` gains `init(farFolder:)`. Pins `ProtectionFarPairTests` (10, headless):
  RED ON THE PRE-FIX TREE (`2c2b7d412`): `✘ Test run with 8 tests in 1 suite failed … with 9 issues` (the four landing
  pins; the four guard pins green by design) → with the leg `✔ Test run with 10 tests in 1 suite passed` (+ the two leaf
  pins: a copy that doesn't verify removed whole; an existing name never overwritten). MUTATIONS on `c09b93ed8` (each
  restored by `git checkout --`, `cmp`-identical to `u1a-prerevert/`): M-FP1 the road's due-check in VX-397's WRONG
  SHAPE (any fresh far copy, any Mac, any library) → `✘ anotherMacsFreshFarPairNeverSatisfiesThisMacsDueCheck` +
  `onlyThisMacsOwn…` (2 issues); M-FP2 the picked-folder guard removed → `✘ aVanishedPickedFolderIsNeverRecreated` (1)
  (a first M-FP2 edit that short-circuited the guard into always refusing was DISCARDED as not the mutation and redone
  as the exact removal — machinery honesty); M-FP3 the half-landed cleanup removed → `✘ aFarCopyThatDoesNotVerify…` (1);
  M-FP4 the existing-name guard removed → `✘ aNameAlreadyInThePickedFolderIsNeverOverwritten` (2 — the planted file
  REMOVED by the failed copy's cleanup: the guard is what keeps her file).
- Piece 2 — VX-397: the far due-check (piece 1's) + Data Safety's counts on the new road: NOT-STARTED — R-U1a-3, R-U1a-4.
- Piece 3 — RETENTION WIRED (VX-302, VX-411): NOT-STARTED — R-U1a-5.
- Piece 4 — VX-450 (Change/Reset roll back on a resume that cannot finish): NOT-STARTED — R-U1a-6.
- Piece 5 — the close (counts, the Mac-suite list, PROVISIONALs, findings): NOT-STARTED.
- No revert is in flight.
