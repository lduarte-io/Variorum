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
- **U1b — THE COPY DOORS (a fresh Opus implementer, headless + build-for-testing only):** piece 0 — F-U1a-1's fix
  (the U1a arbitration's option (a): a resumed Change/Reset whose only typed passphrase opens the lock being
  REPLACED rolls back — VX-450's second arm); T-5 (Make this my library from the MISSING face and rule 27's lobby,
  no library open — the empty-slot landing, nothing steps aside); VX-305's second hand-off (reopening this Mac's own
  set-aside copy, Previous Libraries, through the doors — verify the arc end to end, close its gaps, pin it); T-8
  (a plaintext export brought in as a NEW library through the import road — bulk entry, never reconciled truth).
  Evidence: pins red-on-old; Mac suites under the stage; the walk rows.
  *(Re-cut 2026-10-19 after U1a's survey: the original U1b carried nine pieces — the doors and the listing's faces
  split so each session holds one acceptance unit; the riders move to U1c.)*
- **U1c — THE LISTING'S FACES AND THE RIDERS (a fresh Opus implementer, headless + build-for-testing only):**
  VX-265 (the separate delete choice for other libraries' copies — core `offerDelete` exists, the DOOR is built:
  rule 19, never silently, never bundled); VX-210 (the honest line about copies in folders Variorum doesn't manage);
  **riders VX-444** (the words-recorded ledger — `variorum.calmAsks.words.<libraryID>.*` — carries across Make this
  my library onto the new library's id), **VX-451** (the pane's Lock Now row + idle dial through `changeSettings` —
  F-U4-1's first option) and **VX-454** (the Set-a-passphrase row re-reads after an act sets one — probe first,
  Suspected). Evidence: pins red-on-old; Mac suites under the stage; the walk rows.
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

## 5b. U1b BRIEF — THE COPY DOORS (a fresh Opus implementer; headless + build-for-testing ONLY)

**You are the U1b implementer for VX-309. Work from `~/dev/variorum-vx-309` on branch `vx-309-copies-and-words`.
HARD LIMITS: identical to §5a's first paragraph (headless + `build-for-testing` only; no stage, no store touch, no
network, no Linear, no subagents; today's road byte-unchanged; zero `Sync/`, `Server/`, schema, migration or
dependency lines; `lockstepVersion` 13; the resiliency protocol binds — commit per piece, push per commit, LIVE
STATUS from the first commit).**

**Read first, in full, never delegated:** CLAUDE.md + canon; the resiliency protocol; `notes/CastleRules.md` WHOLE
(rules 2, 14, 17–19, 20–21, 26–27 are this unit's law); `notes/SyncSpec.md` WHOLE; `notes/SurfaceContracts.md`
(Doors — portability's restore hold + Library protection; The app's words rules); this plan WHOLE (§0–§3, §5a, the
§6 U1a RECORD + its ARBITRATION — piece 0's shape is ruled there); the lifecycle page stages 9, 10, 13, 14
(`notes/plans/vx-266/castle-lifecycle.html` — never hand-edit it; the fixture is
`Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/`); `notes/plans/vx-306-castle-open-road.md` §2 U3 + the §6/§9
U3 RECORD (the doors' birth, P-VX306-U3-*); `notes/plans/vx-308-accounts-key-doors.md` §6 ROUND-1 FIX LEG (MAJOR-1)
+ the U3 RECORD; the core — `Executor/Acts/Copies.swift` WHOLE (`makeThisMyLibrary` both forms, `lookInside`,
`openCopy`, `offerDelete`, `plaintextExport`, `MakeMineProgram`), `Acts/Creation.swift` (the no-library executor
road — T-5 follows its pattern), `Acts/KeyDoors.swift` (`resumeCannotFinish` — piece 0 extends it),
`PlanRunner.swift` (`derive`, `resume`, the press-secret check — F-U1a-1's trace in the U1a record is your map),
`Assess/Assess.swift` (the missing-slot and rule-27 facts), `Model/KeyFile.swift` (`building`); the app —
`CopyDoorsModel.swift` WHOLE · `LookInsideModel.swift` · `PickedCopy.swift` · `ProtectionCopyDoors.swift` ·
`ProtectionOpenRoad.swift` (`.startFresh` → `createLibrary`; the lobby's roads; `lobbyFacts`) ·
`ProtectionLobbyFace.swift` · `ProtectionOpenFaces.swift` (`RoadStandingModel`) · `ProtectionRoadActs.swift` ·
`AppBootstrap.swift` (the missing face's composition, `copyDoorsRoads`) · `LibraryRestoreHold` + `RestoreHoldModel`
(an ADOPTED copy lands held — keep that invariant on every new door) · the import road (`Domain/VariorumDocument`,
`DocumentImporter`, `Operations.importDocument`/`importBook`) · the export shapes (`MarkdownInsurance`,
`Acts/Copies.swift`'s `PlaintextExportProgram` — "a plaintext export carries its library ID") · `WordsBand.swift`
(the card's mint-at-first-look idiom); the test worlds (`ExecutorWorld`, `EX`, the scenario world, `CrashHarness`,
`KeyDoorResumeTests`, `MakeMineRouteTests`, `ProtectionOpenRoadPlantedTests`, `PlantedRoad`). HARNESS: rebuild U1a's
(its record's machinery notes — the APFS-clone, `--skip-update` road).

**The pieces (pins first wherever a pin can be red-on-old):**
0. **F-U1a-1's FIX (the U1a arbitration's option (a) — VX-450's second arm; core custody, `KeyDoors.swift` +
   wherever the trace leads in `PlanRunner.derive`/`resume`):** at a RESUME of Change or Reset, a typed passphrase
   that opens only the lock the act is REPLACING (no lock under the plan's fresh descriptor stands yet, and the
   typed one verifies against the OLD descriptor) is NOT the act's secret ⇒ `ActRollback` before any write — never
   a "finish" under the old passphrase on a new salt. The probe's two postures (Standard; Castle/Always ask) become
   pins RED ON THE PRE-FIX TREE; a resume holding the NEW passphrase still finishes (keep U1a's pins green); M1-c's
   press guard stays load-bearing. Record the synced twin's behaviour honestly.
1. **T-5 — THE EMPTY-SLOT LANDING.** From the MISSING face (no library in the slot) and rule 27's lobby, Make this
   my library lands a catalogued (or picked-and-filed) copy into the EMPTY slot as a NEW library — fresh identity,
   fresh key, fresh device ID, NOTHING steps aside (there is nothing to step aside; the act's step-aside half is
   skipped, not emptied). The door REQUIRES a typed secret of the copy's (rule 14's precedent — a quiet-road-only
   open does not carry a pair to lock the new library under): typed WORDS become the new library's words lock;
   a typed PASSPHRASE becomes its passphrase lock, and the new library's words are minted fresh and shown once
   through the band's one idiom (rule 2 — nothing stores words; the card says they will not be shown again).
   Posture: STANDARD (an empty slot has no posture; Castle is entered deliberately — PROVISIONAL, the options
   recorded). The adopted copy lands under the RESTORE HOLD exactly as every adoption does. `CopyDoorsRoads.makeMine`
   stops being nil at the missing face and the lobby; Look inside there is unchanged. Follow `createLibrary`'s
   executor pattern for the no-library road; one act, one plan, crash-safe (rule 20).
2. **VX-305's SECOND HAND-OFF — Previous Libraries through the doors.** Verify END TO END and pin: a library that
   stepped aside whole into `Previous Libraries/<stamp>/` is listed (rule 19's listing), opens read-only through
   Look inside with its own secrets or its own quiet road, and returns as the library through Make this my library —
   from an open library (the standing act: the current one steps aside) AND from the empty slot (piece 1's arm).
   Close the gaps the arc shows (a folder-shaped copy's serving key files, the list's rows, the doors' availability)
   and record each gap as its own finding with its pin.
3. **T-8 — A PLAINTEXT EXPORT IN, AS A NEW LIBRARY.** The picked-thing classifier (`CopyDoorsModel.begin(picked:)`
   and the open door's classifying faces) learns the plaintext export's shape; the door mints a NEW library (the
   creation's road — fresh identity, fresh key, the first-look words idiom; NO restore hold — a fresh mint never
   synced) and brings the export's content in THROUGH THE IMPORT ROAD as bulk entry (`importDocument`/`importBook`
   semantics — rows are minted fresh; "no export path ever writes a row" stays true: this is an import). **Before
   building this piece's mapping (what in the export's folder becomes books, chapters, pool notes), SEND YOUR
   PROPOSED MAPPING to the orchestrator via SendMessage (to: "main") and WAIT for the ruling — build pieces 0–2
   meanwhile.** Refusals name folder, file and line (the import road's idiom); a keyless or foreign pick keeps
   today's honest refusal.
4. **The record** (U1b RECORD in this file, the §6 form): readings, LIVE STATUS, the core lines for the ladder,
   COUNTS (headless + protection set Debug/Release + build-for-testing + phone + Release check), the Mac-suite list
   with red-on-old recipes, PROVISIONALs P-VX309-U1b-N, findings F-U1b-N, walk notes for the acceptance spine
   (stages 9, 10, 13, 14 and the restore drill — Look inside and Make this my library are THE walk's heart).

## 5c. U1c BRIEF — THE LISTING'S FACES AND THE RIDERS (a fresh Opus implementer; headless + build-for-testing ONLY)

**You are the U1c implementer for VX-309. Work from `~/dev/variorum-vx-309` on branch `vx-309-copies-and-words`.
HARD LIMITS: identical to §5a's first paragraph (headless + `build-for-testing` only; no stage, no store touch, no
network, no Linear, no subagents; today's road byte-unchanged; zero `Sync/`, `Server/`, schema, migration or
dependency lines; `lockstepVersion` 13; the resiliency protocol binds — commit per piece, push per commit, LIVE
STATUS from the first commit).**

**Read first, in full, never delegated:** CLAUDE.md + canon; the resiliency protocol; `notes/CastleRules.md` WHOLE
(rules 17–19, 21, 25 are this unit's law); `notes/SyncSpec.md` WHOLE; `notes/SurfaceContracts.md` (The app ·
Doors — portability + Library protection); this plan WHOLE (§0–§3, §5a–§5b-R, the §6 U1a and U1b RECORDS with their
ARBITRATIONS and Mac batches — F-U1b-5 is your VX-444 arm's second half; MB-1 changed `Retention.plan(now:)`);
`notes/plans/vx-308-accounts-key-doors.md` §6 U4 RECORD (F-U4-1 — your VX-451 piece builds its option (a); the
export-mark-by-library pattern; `changeSettings`' road) + the U3 RECORD (the pane's sections, the one presenter);
the code — the core `Executor/Acts/Copies.swift` (`offerDelete` — VX-265's act EXISTS, you build its door),
`Executor/Acts/DeviceActs.swift` (`changeSettings`), `Model/DeviceSection.swift` (`DeviceSettings.idleLockMinutes`),
`Assess/Catalog.swift` (`foreign`, `MacAttribution.unattributed`); the app — `CopyDoorsModel.swift` WHOLE (the
listing's rows, `CopyDoorsListing`), `ProtectionCopyDoors.swift`, `CopyDoorsSheet.swift`, `ProtectionPane.swift`
(the sections' order; the gate-style row), `RoadCrossingsModel`/`RoadCrossingFaces` (the gate row's home),
`ProtectionRoadLock.swift` (`RoadRelockPolicy`), `AppBootstrap.swift` (`canLock`/`lock`, `keyDoorRoads`, the pane
roads), `WordsBand.swift` (the ledger `variorum.calmAsks.words.<libraryID>.*` — VX-444's one home),
`ProtectionOpenFaces.swift` (`RoadStandingModel`), `SetPassphraseModel.swift` + the reminder's row
(`offersSetPassphrase` — VX-454's seam), `ProtectionWords.swift`; the test worlds (`PlantedRoad`,
`ProtectionFacesSupport`, `RoadLockTests`, `RoadKeyDoorSurfaceTests`, `WordsBandTests`, `CopyDoorsModelTests`).
HARNESS: the scratchpad `u1-harness` recipe (the U1a/U1b records' machinery notes).

**The pieces (pins first wherever a pin can be red-on-old):**
1. **VX-265 — THE DELETE DOOR FOR OTHER LIBRARIES' COPIES (rule 19: listed, deletable — never silently, never
   bundled).** The doors' listing already shows other libraries' copies (Previous Libraries included); each such
   row gains *Delete…* — ONE library's copies at a time, the confirm naming the library (its date and what it holds,
   as the listing knows it) and counting what goes (this Mac's copies of IT only — the core `offerDelete`'s own
   fence; another Mac's copies in a shared folder are never touched), confirmed each time, never part of any other
   act's confirm. The empty-slot listing and the open-library listing both carry it. Deleting never touches a copy
   of the OPEN library (the restore list's own rows — rule 19 is about OTHER libraries; the open library's copies
   are retention's). Refusals honest; a receipt names what went.
2. **VX-210 — THE HONEST LINE about copies in folders Variorum doesn't manage.** The catalogue's `foreign` entries
   and `unattributed` far copies are facts the listing can say ONE line about (rule 25's honest-limit idiom): copies
   in folders the app doesn't manage (today's flat files, a hand-made folder) are not listed here and are hers to
   manage in the Finder. ONE quiet line on the listing (and Data Safety's restore list where it already composes),
   rendered only when such entries exist (P-2: a line that can never be true is not rendered). The wording is a
   draft for U2's pass (PROVISIONAL).
3. **VX-444 (+ F-U1b-5) — THE WORDS-RECORDED LEDGER CARRIES.** (i) Make this my library (the standing act, an open
   library): the new library's id inherits the OUTGOING library's `recorded`/`dismissed` marks (the pair carries —
   rule 17's "under your current pair" — so words she recorded are still the words she knows); (ii) T-5 with the
   copy's own TYPED WORDS: the marks read RECORDED for the new id (she just typed them — F-U1b-5); T-5 with a
   PASSPHRASE (fresh words minted, dropped unseen) and T-8 (the creation's words): the card's fresh offer stays —
   carry NOTHING there. The ledger write lands where the new library's id is known, beside the act's landing; pins
   over a planted ledger, red-on-old (the card re-offers today).
4. **VX-451 — THE PANE'S LOCK NOW ROW + IDLE DIAL (F-U4-1's option (a); no core line).** In the pane's Castle
   section on the new road (where `RoadRelockPolicy` stands): a *Lock Now* door (the menu's ⌃⌘L twin — one
   capability, the registry's declaration carries both doors) and the idle-minutes picker (10 default · a small
   honest set · never) writing THIS MAC'S SEALED setting through the core's `changeSettings` road (never
   UserDefaults — the design's §3.2/§3.15 law U4's record states). Both render only where Castle stands (P-2);
   today's road byte-unchanged.
5. **VX-454 — PROBE FIRST (Suspected):** W-VX308-2's trace — "Set a passphrase…" still renders above the key doors
   after turn-on-sync set one (the ledger not re-read; self-heals at the next launch, unverified). Build the pin
   FIRST as the confirm (the planted road: turn-on-sync lands a passphrase → the pane's read): RED confirms and the
   fix proceeds (the re-read at the act's landing — the account section's `landed` chain already re-reads, find why
   the reminder's row doesn't); GREEN means record-only (close the ticket as unreproducible with the pin as the
   evidence). Either way the pin stays.
6. **The record** (U1c RECORD in this file, the §6 form): readings, LIVE STATUS, the lines for the ladder, COUNTS,
   the Mac-suite list with red-on-old recipes, PROVISIONALs P-VX309-U1c-N, findings F-U1c-N, walk notes.

## 5d. U2 BRIEF — THE WORDS (a fresh Opus implementer; headless + build-for-testing ONLY)

**You are the U2 implementer for VX-309 — the words unit. Work from `~/dev/variorum-vx-309` on branch
`vx-309-copies-and-words`. HARD LIMITS: identical to §5a's first paragraph, PLUS: no `Server/` line and no SQL run
anywhere (VX-213's `pg_temp` item is NOT yours — it runs only at her explicit go, held to VX-329's window; your share
of VX-213 is the record corrections and the privacy text below). Words rules that BIND every sentence you write:
sentence case, never a capitalized word for emphasis (her standing rule); the app's voice is calm and plain; refusals
honest; her drafted lines land VERBATIM-FAITHFUL (an obvious typo in a draft is corrected silently — e.g. "wrods" —
never a word substituted); every line you draft yourself is PROVISIONAL for her pass.**

**Read first, in full, never delegated:** CLAUDE.md + canon; the resiliency protocol; `notes/CastleRules.md` WHOLE
(the words must say the rules as built); `notes/SyncSpec.md` WHOLE; `notes/SurfaceContracts.md` WHOLE (The app's
words rules; the Library protection line); this plan WHOLE (§0–§5c, §5b-R, the §6 RECORDS with their ARBITRATIONS
and MAC BATCHES — F-U1a-3, P-VX309-U1b-3, P-VX309-U1c-1 name the undrafted words you now draft); `notes/QUESTIONS.md`
#235 + #236 (HER DRAFTS verbatim — the join moment's email-naming draft and its middle-clause note); the VX-308
record §6 U2 RECORD (the join moment as built, the follow's Done, `ProtectionWords`' sections) + the U3/U4 records'
words; the VX-213 and VX-264 ticket bodies (their remainders are quoted in the kickoff record and §1); the lifecycle
page (the chapters must agree with it); the field guide's seeded text (`TutorialSeeder.swift` / `LaunchFurniture
.swift` — where the Castle/backups chapters live) and `notes/plans/fixes/vx-191-encryption-audit.md` (the S1 record
corrections' targets); `notes/stargazing-castle-rebuild-delta-brief.md`; the code — `ProtectionWords.swift` WHOLE ·
`ProtectionCopy.swift` · `LibraryOpenCopy.swift` · `RoadAccountFaces`/`RoadJoinFollow*` (the join moment's seam,
VX-107's durable-fact pattern) · `RoadCrossingFaces` (the export-notice DURABLE MARK idiom — VX-457 reuses it) ·
`Model/KeyFile.swift` + `Wire/AccountVaultClient.swift` (VX-456's same-words compare — the words lock vs the vault's
recovery wrap; a CORE line, the ladder reads it) · `SetPassphraseModel.swift` (VX-211's fields) · `Domain/` (the
estimator's home) · the Settings search index (`AppSettingsView.swift` / the pane search seam — VX-453's) ·
`DataSafetyCopy.swift` + `DataSafetyModel.swift` (F-U2c-4's line; F-U1a-3's captions). HARNESS: the scratchpad
`u1-harness` (the records' machinery notes).

**The pieces (words pins as-drafted; core pins red-on-old where behaviour changes):**
1. **THE JOIN MOMENT REWORD + VX-456 (one piece — the clause rule depends on both).** The moment rewords to the
   library-adopts-account direction, naming the account by email — her refined draft verbatim (#236; "wrods"
   corrected): *"Your twelve words are <email>'s twelve words. If you don't have your account's words written down,
   you can make new ones at any time."* — the middle clause (*"If this is your first time signing in, your previous
   twelve words still open backups you made before today"*) DROPS because VX-456 lands in this same piece (her note:
   with VX-456 the moment fires only on a real replacement, so the previous-words clause would be unconditional
   noise; she allowed either, the cleaner arm is ruled here). **VX-456**: the moment stays QUIET when the typed words
   already are the account's — the core compare (the library's words lock against the vault's recovery wrap, by
   fingerprint/wrap identity, never by deriving or storing words) decides it; the walk's same-words join already
   showed no moment by accident of the typed road — make the rule explicit and pinned both arms (same words quiet;
   replaced words speak, red-on-old where the old build spoke on same-words or said the wrong direction).
2. **VX-457 — the follow's Done as a DURABLE pane notice until OK** (her "I agree with B"): the export-notice idiom
   (a durable mark keyed by library, reconciled at every ready, cleared only by OK), surviving `receipt_style` off
   and a quit; the one-shot receipt retires for this Done. Pins: the mark set at the follow's landing, standing
   after a simulated relaunch (a fresh faces build), cleared at OK, never set on today's road.
3. **`ProtectionWords.moveNotYet` REWORD** (her ruling): the line names the two-press road — leave this account
   with This Mac Only, then turn on sync while signed in as the other account; this library's pair becomes that
   account's. (VX-455's one-door compose stays post-release; no behaviour change — the words pin flips.)
4. **VX-264 ITEM 5 + ITEM 7 (+ VX-209's remainder — one piece).** Item 5's set-aside sentences land where set-aside
   copies are counted and deleted (the listings' other-library rows and VX-265's delete confirm): *"…plus N older
   libraries Variorum kept when you opened or restored a different one."* and *"Those older libraries are your way
   back to what you had before — delete them only if you won't want them back."* (her ruled words, fitted to the
   rows' grammar, PROVISIONAL where fitting changed a word). Item 7: the restore/make-mine confirm's posture line
   made CONCRETE, computed per library shape (what the copy IS — its posture and account facts — said plainly;
   VX-209's synced-confirm sentence is this line's synced arm; the mechanism is rule 17's, closed at VX-306).
5. **VX-263's ROUTE-FINDER SENTENCE as reworded:** *your current passphrase or words; on this Mac, its quiet road if
   it still holds that key* — wherever the route finder speaks (rule 4's one sentence; align the standing VX-263
   line's hosts without re-opening U3's pinned line unless the reword supersedes it — if it does, flip the pin
   deliberately and say so).
6. **VX-211 — THE QUIET STRENGTH HINT (her kickoff ruling).** The 12-character floor stays the ONLY refusal; the
   set/change passphrase fields gain ONE calm line of honest advice from a pure Domain estimator (word-count/length/
   variety class — e.g. a short common-shape passphrase earns *"short passphrases are easier to guess — a longer
   phrase is stronger"*; a long phrase earns nothing). NEVER a block, NEVER a meter bar, no colors. The estimator is
   a pure function with exact pins; the line's wording PROVISIONAL.
7. **THE FIELD GUIDE'S CASTLE/BACKUPS CHAPTERS + DATA SAFETY'S WORDS (VX-379's acceptance; #235's "written here").**
   Rewrite the guide's protection chapters against the rules AS BUILT (the Start Here chapter leads: your work is
   encrypted; write down your twelve words; set a passphrase; the Apple road is a convenience that works for most
   people forever) and the copies as this phase built them (pairs beside the library and in the picked folder,
   retention's honest numbers, the restore drill through Look inside / Make this my library, the delete door, the
   plaintext export in/out). Data Safety gains F-U2c-4's "what opens a backup" line (rule 5's sentence) and
   F-U1a-3's truths (the counts are this Mac's pairs of this library; why a second same-day Back Up Now adds no far
   pair). The SEEDED guide text changes in the seeder only — the truth-check and the REAL store's re-seed ride
   VX-329 (do not touch any store). The lifecycle page is never hand-edited; if a chapter sentence and the page
   disagree, the fixture-tested page wins and your sentence follows it.
8. **VX-213's REMAINDER (your share):** the S1 record corrections (Q1 kp2 in Supabase Vault, Q2 the pin reads file
   12, Q6 heal — correct the `notes/plans/fixes/vx-191-encryption-audit.md` record IN PLACE with a dated correction
   note, never silently); the privacy text — `notes/stargazing-castle-rebuild-delta-brief.md` gains the
   auth-audit-logs-outlive-a-deleted-account fact in plain words (the site agent reads it at VX-329). `pg_temp` is
   NOT YOURS (held for her go).
9. **THE UNDRAFTED WORDS OF U1a–U1c (F-U1a-3 · P-VX309-U1b-3 · P-VX309-U1c-1):** T-5's lead and receipt; the
   listing's lead and empty line; T-8's lead, button, working line, refusals and receipt; the delete door's words;
   VX-210's line — one pass, one voice, every line PROVISIONAL, the as-drafted pins flipped deliberately where a
   line changes.
10. **RIDER VX-453 — Settings search surfaces the account section** ("account" answers nothing today; the search
    self-describes as covering the app's own words): the account section's rows join the pane-search index through
    the existing seam; pin red-on-old ("account" finds the section; "sync" still finds what it found).
11. **The record** (U2 RECORD in this file, the §6 form) — including the MOBILE PARITY line (the phone shares
    `ProtectionWords`' shared strings: say exactly which changed lines the phone renders).

## 5b-R. THE T-8 MAPPING RULING (the orchestrator, 2026-10-19 — the U1b proposal gate; repo-first before piece 3
builds)

**The reading: (a) CONFIRMED** — "the plaintext export" is the unencrypted `.sqlite` (`StorePlaintextExport`,
`LibraryClassifier.plaintextExport`), the exact shape P-VX306-U3-5 refuses today; T-8 is that deferral come due. The
Markdown folder is a projection, not this door's source. The stale `Copies.swift` header line (the export no longer
carries its library ID — `protection_record` is local-only and dropped) is a FINDING, routed.

**The boundary that decides the items:** T-8 is a RESCUE door, not the variorum edition (R-13n-8 — full fidelity
lives at 13m). **Content and its placement ride — including its kept-out-of-view-ness; configuration does not.**
What the document format can say (books, chapters, memberships, notes, takes, tags, titles) plus the content-state
facts the catalog of containers gives (archived, pools) crosses; saved queries, stars, shelves, owned/sealed/
finished, outflow and the rest of item 8's list do not, and the confirm says so in one line (U2's words).

**Per item:** 1 — (a) for live books; ARCHIVED BOOKS take **(c)**, imported then `archiveReading` (the same doctrine
as item 4: archive is kept-out-of-view, not gone — surfacing everything she put away would be as wrong as losing
it); empty books skipped and named in the receipt. 2 — **(a)** (once, membered in each; the model's many-readings
default; each book's member order = the export's `(position, id)` order). 3 — **(a)**. 4 — **(a)**; versions never
ride. 5 — **(a)**. 6 — **(a)** (gatherings are configuration; the tags ride, so a hand-remade rule assembles the
same notes). 7 — **CONDITIONAL**: **(b)** when the import can ride an existing wing-context seam cheaply (each
non-empty wing minted by name, its content landing in it, tags adopting per wing — flattening would MERGE per-wing
tag vocabularies, R-13ia-1's legal twins, a real semantic change); otherwise **(a)** with the flattening said
plainly in the confirm, a PROVISIONAL row and a finding so the bundle carries the wing arm. Report which was built
and why in the record. 8 — agreed. 9 — agreed (the export is only read; a mid-way refusal stops the act and the
receipt says how far it got).

**The act: (a) CONFIRMED** — the creation's road (`createLibrary(passphrase: nil)`, Standard, fresh identity/key/
device ID, the words offered at the first look by the band card, no restore hold — a fresh mint never synced); with
a library open the current one steps aside WHOLE into Previous Libraries first; at the missing face it lands in the
empty slot. The import runs HEADLESS into the new store before its first open, no undo entry (a library's birth).
The crash window (a new library holding part of the export; the export untouched and re-importable) is RECORDED as
PROVISIONAL, not engineered around — with one requirement: the import's END writes a receipt/log line naming what
landed (N books · M notes · K snippets), so a partial landing is visible against it.

## 6-L. THE LADDER (closed 2026-10-20 ~03:00 MDT — the records `notes/plans/vx-309-ladder-round-1.md` ·
`-round-1-fixes.md` · `-round-2.md`)

**Round 1** (a fresh `fable-reviewer`, REVIEW_PROMPT verbatim, the whole phase diff, custody ⇒ Fable): **0 BLOCKER ·
0 MAJOR · 2 MINOR · 4 NIT**, with a sixteen-point clean bill over the phase's riskiest lines and the reviewer's own
red-on-old reproduction of VX-456's core pin. **The fix leg** (a fresh Opus implementer, the cross-model flow): six
agreed, zero disputed; F-R1 built as the honest-words arm with the delete fence UNWIDENED (the option question is her
bundle's), F-R2's clause lands with the guide's paragraph following the lead's list, F-R3/F-R4/F-R6 fixed, F-R5
record-only; every pin red-on-old or flipped deliberately, every mutation red and restored. **The fix-leg Mac delta**
(the orchestrator, stage claim `vx-309-fixleg-mac`): 97/16 green, F-R4's revert red-then-restored. **Round 2** (a
fresh `fable-reviewer`): **ALL SIX CONFIRMED CLOSED, 0 reopened, 0 new** — the reviewer reproduced the fix leg's
red-on-old itself in a scratch harness copy (10 issues, the claimed pins exactly); one routed words observation
(OBS-R2-1 — `copiesElsewhereLine`'s clauses don't describe a container copy whose key file doesn't read; the
P-VX309-R1-1 bundle sitting's). **No round 3 earned.** Main's VX-458 (Tools/notes only) merged in after round 2
(`cb806dae0`, the coordinator's no-re-test note); headless build green on the merged tree.

## 7. THE WALK PLAN (the orchestrator's, ONE stage window after the ladder closes; drafted at the U2 close from the
four unit records' walk notes — the §6 notes carry each row's detail; this is the ORDER and the posture rails)

**Rails (the coordinator's eight terms + the walk guards, every row):** the DEV store only; claim per the GO; renew
after EACH ROW; zero instances before any slot move; a cmp-verified safety copy of EVERY slot file first (no extension
filter — the lived-here marker); throwaways outside the slot removed or listed; the defaults domain pre-exported and
end-diffed; credentials from the env files only, never echoed; synced arms on the THROWAWAY project through VX-308's
walk switch (every launch asserts the ref ≠ production); never press Resume on the dev store; never a words look on
the dev library (F-U2b-5); window-scoped captures, light AND dark wherever a face renders; the result line names end
posture · library ID · hold+banner · keychain adds · 0 instances. Expect F-U2-2's odd banner sentence after T-5/
Make-mine (a recorded finding, not a walk failure).

**The rows, in order (detail in the §6 walk notes of U1a · U1b · U1c · U2):**
1. **The backups + counts row (U1a):** picked folder set → Back Up Now → the pair in BOTH places, same bytes; a second
   press → container only, the one-a-day caption's truth; Data Safety's rows count pairs; retention's log line.
2. **The restore drill (stage 9; U1b):** Look inside (read-only, nothing written) → Make this my library (held; the
   old library whole in Previous Libraries; item 7's concrete lead — capture in Standard, then the LOCAL Castle arm
   with rule 17's sentence, Standard restored after); the Previous Libraries arc (listed, dated, Look inside by its
   own road).
3. **T-5, the empty-slot landing (stage 9's empty arm; U1b):** the slot emptied (files MOVED aside) → the missing
   face → Restore from a Backup → the listing (lead; VX-210's line visible on the dev store) → the confirm (the new
   T-5 lead) → typed words → landed, held, the receipt; a wrong word refuses with nothing moved. The words card does
   NOT re-offer (VX-444 — the typed-words arm).
4. **VX-265 + item 5 (U1c, on THROWAWAYS seated in the slot only):** the delete door on a stepped-aside throwaway's
   rows — the confirm with her older-libraries sentences and the way-back line — the folder gone whole; the open
   library's rows carry no delete; at rule 27's lobby none.
5. **VX-451 + VX-448/445 spot-check (U1c):** the LOCAL Castle arm — the On this Mac section's dial (5 → the log line →
   back to 10) and Lock Library Now → the lobby; Standard restored (both secrets, the dev pair unchanged).
6. **The words rows (U2):** VX-263's line on the key doors; VX-211's floor + hint arcs on a throwaway (11 → refusal;
   12–19 → the quiet line, the set LANDS; repetition; 20+ varied → nothing); the guide's three lessons via Help ▸
   Restore Tutorial on a THROWAWAY slot; Data Safety's new lines (both voices).
7. **The account rows (U2, the THROWAWAY project):** the join by passphrase → her email-named moment (with the
   backups sentence); This Mac Only → re-join same passphrase → NO moment (VX-456); a follow's Done as the durable
   notice through a relaunch → OK clears (VX-457); Move's moveNotYet line. Signed out at the end (the account fence).
8. **T-8 (LAST — the coordinator's shape):** a THROWAWAY library seated in the dev slot (A aside whole first,
   cmp-verified, the hold marker with it); the export picked → the doors name it (the new lead) → Bring it in → the
   new library Standard, NOT held, the receipt with counts and the Previous Libraries tail; the content checked
   against the source (books a–z, chapters, memberships, archived things archived, versions absent, wings minted,
   the empty book named); then A RESTORED WHOLE (cmp-verified; the hold marker back; the banner standing), the
   throwaways cleared, the defaults end-diff reconciled, signed out, 0 instances.
9. **Stages 13/14:** pins only (the crash loops) + rule 27's face spot-check rode row 3/4; said in the record.

## 8. THE WALK RECORD (the orchestrator, 2026-10-20 02:34 MDT →, stage claim `vx-309-walk`, the coordinator's GO;
captures `/tmp/vx309-walk-caps/`, deleted at closeout; renew-per-row; THE DEV-LIBRARY HALF — checkpoint 1)

**Row 0:** 8/8 slot files cmp-verified into `Backups/safety-copies/variorum-vx309-walk-2026-10-20T083513Z` (no
extension filter); defaults pre-exported; Previous Libraries baseline two pre-existing entries; 0 instances; the
Debug app built from the merged tree.
**Row 1 (the backups + counts):** first Back Up Now → rule 5's pair in the container AND the picked folder
(`~/Documents/Variorum` — the dev store's standing destination), the same name, BOTH FILES BYTE-IDENTICAL (`cmp`);
second press → a second pair beside the library ONLY (the far one-a-day truth, P-VX309-U1a-2 live); the pane's
counts/newest/oldest read THIS device era's pairs; the far caption's one-a-day line and rule 5's F-U2c-4 sentence
render; VX-210's line renders WITH F-R1's can't-vouch clause (AX-read, byte-faithful). Light + dark captured.
**W-VX309-1 (finding):** the pair landed under a THIRD `<mac8>` (`a39ae6d7`) — the dev library's DEVICE ID changed
between VX-308's walk (`c31a4daf` era, 10-19 ~11:00 MDT) and this walk with NO identity-minting door pressed; the
zero "beside your library" count before the press was honest BY ITS RULE (the new device era owned no pairs), and
the earlier eras' pairs still LIST under the library while not COUNTING as this Mac's — the per-identity meaning of
"this Mac's copies" is part of the finding. DOES NOT touch the dev pair; the quiet open stayed quiet throughout.
Trace owed at closeout (suspect class: a test-host open on the real slot minting a device row).
**Row 2+3's drill (the restore list + Look inside + Make this my library):** the restore list groups THIS library's
rows first (the fresh pairs at the head), the older-libraries group after the way-back separator sentence (her item-5
words live); Look inside on the Oct-18 Previous Library opened READ-ONLY by its own quiet road, nothing asked,
the facts sheet's ruled sentence shown; the aside's bytes UNTOUCHED after the look (sha256 diff). **W-VX309-2
(finding):** Make this my library on that Oct-18 aside REFUSED "written by a newer Variorum" — the aside carries the
branch-era migration id (`v1_30_protection_record`, renumbered `v1_31` at the fold of main), so the schema gate
reads an unknown identifier as NEWER; honest by its rule, wrong in this dev-only case (migration-id renames break
the newer-refusal's honesty; release stores can't hit it). The drill re-ran on TODAY'S fresh pair: the confirm's
ITEM-7 CONCRETE LEAD (the Standard/unsynced arm, §7c's words with the way-back clause) captured pre-type; the
landing: a NEW library `e11e5233` (fresh key), the outgoing `86a82b4f` aside WHOLE (sqlite + key file) at
`Previous Libraries/2026-10-20-085330`, the old memory mirror staled beside a fresh one, the hold marker FRESH with
the COPY'S as-of (08:41Z), the banner's as-of updated, and the receipt said once: *This is your library now. The
previous one is in Previous Libraries.* The words card re-offers on the new id (the outgoing ledger held no
recorded mark — carry-of-nothing, consistent). **WALK SLIPS, said honestly (the coordinator told, term 7):** the
Make-mine words FIELD renders typed words in CLEAR TEXT (the passphrase field is concealed) — two post-type
captures held the dev words and were DELETED unCommitted; a words-field/passphrase-field concealment-consistency
row joins her bundle; the walk discipline became captures-before-typing only. One mis-click typed the passphrase
into the words field (cancelled; nothing landed); the dev pair never changed and `dev-castle.env` stays true; the
coordinator recommends NO rotation (hers to decide).
**Row 5 (+ VX-263's line) — the Castle round trip on the dev library:** the Protection pane's key doors render with
VX-263's REWORDED line (AX-read byte-faithful); Use Castle's confirm speaks rules 9/11 verbatim + the export-off
call line (captured pre-type); the crossing landed a NEW CASTLE KEY (`7b4159d4`) with NO Apple lock in the key
file, identity kept; the gate chose ALWAYS ASK; the pane then showed the export-off DURABLE notice, the gate row's
Always-ask sentence, VX-451's DIAL (picked 5, read back "5 minutes", RESTORED 10) and the Lock row's ⌃⌘L sentence;
the File menu gained Lock Library Now; **⌃⌘L → the library closed behind the LOBBY** (typed roads only, the honest
"Touch ID isn't set up for this library." line, the Settings window closed — VX-224), captured; the passphrase
reopened the SAME key (no re-key at a lock). **Use Standard's confirm speaks rule 12's leave sentence verbatim**
(captured pre-type); the leave landed a NEW STANDARD KEY (`77f4a14d`) with the APPLE LOCK BACK in the key file,
identity kept; Lock Library Now GONE from the File menu in Standard. The hold marker rode every crossing unchanged
(heldAt 08:53Z standing). *(The dev-library half ends: Standard, `e11e5233`, the dev pair intact and valid, held +
banner. The throwaway block follows — checkpoint 2 appends.)*

**CHECKPOINT 2 — the throwaway block (T = `a6b6213c`, fp `8c892a9f`, created by the create door, EMPTY by design).**
**T's backup (row 1's shape on T):** Back Up Now on T → the pair in the container (`Backups/a6b6213c/458dbc52/`,
09:12:26Z) AND the picked folder, BYTE-IDENTICAL (`cmp` both files); the pane's count/newest truthful ("1 copy"); the
receipt's tail "Copied to your folder too, 1 old copy retired" is the FLAT legacy leg speaking (today's `StoreBackup`
runs untouched beside the new road — its root copy of T landed in `~/Documents/Variorum/` and its folder-wide
retention retired one old flat copy; grounded against the folder listing). Three earlier presses landed NOTHING —
the Settings window had moved and the clicks hit desktop; the pane's zero stayed honest throughout.
**WALK SLIP 2, said honestly (term 7):** while carving T-5's missing face, the orchestrator launched a STALE Sep-12
Debug build (the standard DerivedData path — the walk's build lives at `App/Variorum/DerivedData/vx309`); in ~8 s on
the OLD road it minted a fresh store + key (`dd6e8928`), STALED T's key file and dropped its key beside the container
and picked-folder backups. Recovered whole: the minted store/key/droppings removed, T's key file un-staled and
`cmp`-IDENTICAL to its T1 aside copy, the mirror untouched (`cmp` T1), the missing face re-carved. T's own files and
pair were never at risk (aside cmp-verified first). The defaults carry the stale build's writes (end-diff will show
them; reconciled there). The CONTRAST is itself evidence: the old road silently minted over a missing library; the
merged build on the same face stopped and asked.
**Row 3 — T-5, the empty-slot landing (the PASSPHRASE arm):** the missing face renders (lock glyph, "Your library
file is missing." / "Variorum's library isn't where it was. Your lock hasn't changed.", three doors); Restore from a
Backup lists T's two 09:12 pairs FIRST (this library's rows lead) with NO delete on them, the dev-era copies after
WITH Delete… (VX-265's fence on the no-library face), the header carrying F-R1's can't-vouch clause; Make this my
library's EMPTY-SLOT confirm captured PRE-TYPE (the T-5 lead: fresh key, both-secrets arms, "The copy itself is not
changed.", NO steps-aside sentence — correct, nothing steps aside; ONE combined secret field, CONCEALED with a reveal
eye — a fact for the concealment-consistency bundle row); typed T's passphrase → LANDED: new library `d3c486ea`
(fresh key `a7242f40`, Standard with the Apple wrap, epoch 1), the copy's passphrase became the library's (its wrap
present), HELD (`asOf 09:12:26Z` = the copy's own moment, `heldAt 09:22:59Z`), T's mirror set aside whole in
`Previous Libraries/2026-10-20-092259/`, T's key file staled in place never overwritten, the quiet receipt "This is
your library now." (the empty-slot short form, no Previous-Libraries tail), and the FRESH-WORDS CARD OFFERED (the
passphrase arm's promise — "new twelve words offered once the library opens" — live). F-U2-2's banner sentence
present as expected (recorded, not a walk failure). **Honest gaps:** the wrong-secret refusal ran on the FULL face
instead (below); VX-444's typed-words NO-re-offer arm (a RECORDED mark carried) stays pin-covered, not walked — the
dev half walked the carry-of-nothing re-offer, this row the passphrase arm's offer. **The 0.9.8 what's-new card
greeted the adopted library's first open** — the calm-first-open rule's edge, a bundle row for her.

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

### U1a RECORD — THE COPIES' MACHINERY (Opus implementer, 2026-10-19; the far pair leg + VX-397 + VX-302/411 + VX-450 — BUILT; the Mac suite and the walk PENDING)

**Not done in U1a, first:**
- **No Mac suite was RUN and no walk was made** (the brief: headless + `build-for-testing` only — no `xcodebuild test`, no
  stage, no Debug launch, no store touch). ONE Mac-only suite is BUILT — `DataSafetyRoadCountsTests` (4: the Data Safety
  seam and the two restatements of `StoreBackup`'s rules); its run AND its red-on-old by behavioural revert are the
  orchestrator's (the recipe below). Every other new pin ran HEADLESS (the harness) or in core, red-on-old verified.
- **No face and no words changed.** The honest line about an unreachable picked folder, and anything Data Safety SAYS
  about the new road's copies, are U2's (the brief); the rows only count differently (R-U1a-4). Rule 19's other-libraries
  listing and its delete choice are U1b's door — nothing here deletes another library's copy (pinned).
- **F-U1a-1** (a resumed Change typing the OLD passphrase "finishes" under it and says resumed — pre-existing, adjacent to
  VX-450) is ROUTED, not built. **MAJOR-1's residue (1)** for Change and Reset is RECORDED, not built (the brief).
- **Two existing core files changed** besides the new pure rule `Assess/OwnCopies.swift`: `Assess/Retention.swift` (its
  predicate moved to `OwnCopies`, behaviour identical) and `Executor/Acts/KeyDoors.swift` (VX-450 — the custody line, THE
  CORE LINES below, for the Fable ladder). Zero `Sync/`, `Server/`, schema, migration, project or dependency lines;
  `StoreBackup.swift` untouched; `SyncSchema.lockstepVersion` 13. No live network call (SwiftPM and xcodebuild ran from
  APFS-cloned caches with `--skip-update` / `-skipPackageUpdates`); the dev store, the real store and `/Applications`
  untouched; no Linear write; no subagent.
- The canon delta (F-U1a-4) and the QUESTIONS rows for the PROVISIONALs are the closeout's.

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
- Piece 2 — VX-397: the far due-check (piece 1's, DONE there) + Data Safety's counts on the new road: DONE (`2c3175cda`).
  `Shared/Protection/ProtectionCopyCounts.swift` (harness-visible): `RoadCopyCounts` + `ProtectionCopyCounts.read(session)`
  — a FRESH catalogue read, `OwnCopies.summary` per place for the open library and this Mac. `RoadStandingModel` gains
  `copyCounts` (nil on a hand-made face; `make` builds it from the open's session, off the main actor). `DataSafetyModel`
  gains `roadCounts` (nil by default — today's road) and two pure maps `counted(_:_:)` (a row's count/newest/oldest from
  the pairs; its path and its folder's state as read); `refresh` takes the road's counts BEFORE assigning, so the face
  never flashes today's flat counts on the new road; `DataSafetyPane` hands `roadStanding?.copyCounts` to the model (the
  VX-379 gate: nil on today's road ⇒ `primary = read.primary`, `destination = read.secondary`, byte-unchanged). Pins:
  `ProtectionCopyCountsTests` (3, headless — the planted world: today's flat files in both places, another Mac's fresh
  pair in the shared folder AND beside the library, another library's pair, an orphan snapshot, a pair stamped ahead —
  counts 2 and 2, newest the trusted one; none for a library with no pairs; the pair road's own pairs counted in both
  places) `✔ 3 tests in 1 suite`; the whole harness `✔ Test run with 285 tests in 45 suites passed`. MUTATIONS on
  `2c3175cda` (each restored by `git checkout --`, `cmp`-identical): M-DS1 the counts in VX-397's WRONG SHAPE (every
  backup copy in the place, any Mac, any library) → `✘ theCountsAreThisMacsPairs…` (2 issues); M-DS2 the picked folder's
  count read from the container → `✘` the same (1). MAC PINS (BUILT — `build-for-testing` `** TEST BUILD SUCCEEDED **`, no
  warning in a touched file; the RUN PENDING the stage): `DataSafetyRoadCountsTests` (4 — the new road's rows 2 and 1
  over the planted world with today's road's rows 3 and 2 beside them; the maps; the two restatements equal to
  `StoreBackup`'s — `farInterval` = `Configuration().interval`, `stampIsTrusted` at five offsets; the composition by
  source). Its RED-ON-OLD is the orchestrator's behavioural revert (the recipe in the close).
- Piece 3 — RETENTION WIRED (VX-302, VX-411): DONE (`2d18617c8` pins first · `635a6a8e6` the wiring). The pair road
  (`ProtectionBackupHook.takePair`, now `takePair(_:now:guards:)` — `guards` `.all` in production) runs `prune(session,
  libraryID:deviceID:guards:)` after the far leg: core's `Retention.plan(… policy: .standard, guards:)` over a FRESH
  catalogue read for the pair's library and this Mac, EXACTLY its `prune` ids through `FileBackupsLeaf.deleteCopies`, ONE
  id per call (a failing delete logged, the rest still go), each id logged only when its file is gone after (a far
  folder out of reach since the read removes nothing and is not claimed); never raises. ONE PAIR ROAD AT A TIME (an
  `NSLock` around the whole road — R-U1a-5). Pins `ProtectionPairRetentionTests` (4, headless) RED ON THE PRE-WIRING
  TREE: `✘ Test run with 4 tests in 1 suite failed … with 21 issues` → GREEN with the wiring, + the DEBUG pin
  `ProtectionPairRetentionGuardMutationTests` (1 — the core guard off THROUGH the pair road: another Mac's copies pruned,
  VX-302's shape): `✔ Test run with 5 tests in 2 suites passed`; the whole harness `✔ Test run with 289 tests in 46 suites
  passed` before the DEBUG pin (290/47 with it — the close's count). MUTATIONS on `635a6a8e6` (each restored by `git
  checkout --`, `cmp`-identical to `u1a-prerevert/`): M-RT1 the road's prune with the guard off hard-coded → `✘
  anotherMacsAndAnotherLibrarysCopiesSurviveEveryPrune` (4 issues — the survival pin is not hollow); M-RT2 every doomed
  id in ONE delete call → `✘ aDeleteThatFailsNeverFailsThePairOrStopsThePrune` (2 — the first failure stopped the rest).
  M-RT3 (the lock removed) was named and NOT RUN: no deterministic pin can observe the race the lock closes (the leaf's
  check-then-act free-name pick, sub-second, between two detached runs) — the lock rests on inspection, recorded.
- Piece 4 — VX-450 (Change/Reset roll back on a resume that cannot finish): DONE (`e6bd14584` pins first · `7b9e5793f` the
  fix). `KeyDoorProgram.resumeCannotFinish` (`Acts/KeyDoors.swift`, the unit's ONE core custody file): on a RESUME
  (`ctx.resuming` — M1-c's guard kept first), the words act unchanged (its new words), Change and Reset their NEW
  passphrase (`ctx.secrets.passphrase` — derived at a resume only from one typed there), then for all three a live key
  file of the key; either missing at the vault or key-file step ⇒ `ActRollback` BEFORE anything is written, through
  `drive`'s one rollback. Pins `KeyDoorResumeTests` (core; 6 tests — the per-stop loop over 11 shapes, the plain Change
  and Reset after their begin, the synced Change after its landed vault write, a resume holding the new passphrase but no
  key file (both doors), a resume holding the new passphrase still finishing (both doors)): RED ON THE PRE-FIX TREE `✘
  Test run with 5 tests in 1 suite failed … with 35 issues` → GREEN `✔`, and with MAJOR-1's own suites `✔ Test run with 12
  tests in 2 suites passed`; the key-door neighbours (`FileLessWordsTests`, `FirstLookWordsTests`, `ExecutorKeyDoorTests`,
  `U2CrashHarnessTests` — its synced key door's typed resume still FINISHES —, `ExactWritesTests`,
  `ExecutorDeviceActTests`) `✔ Test run with 38 tests in 8 suites passed` (before the no-key-file arm joined). MUTATIONS
  on `7b9e5793f` (each restored by `git checkout --`, `cmp`-identical to `u1a-prerevert/KeyDoors.swift`): M-450a the
  Change/Reset arm dropped → `✘ … 37 issues` (the loop + the three explicit pins); M-450b the key-file arm narrowed to the
  words act → `✘ aResumeHoldingTheNewPassphraseButNoKeyFileRollsBackToo` both doors (`noLiveKeyFile` out of the settle);
  M-450c the `resuming` guard dropped (a press too) → `✘ … 12 issues` (the words door's own mint refuses — M1-c's pins:
  `FileLessWordsTests`, `NewWordsResumeTests` — the guard stays load-bearing). MAJOR-1's RESIDUE (1), carried — recorded,
  not built: a Change or Reset stopped AFTER its key-file write and BEFORE the plan records it resumes into the
  rollback with the live key file keeping the NEW passphrase lock (the one she typed at the press — seen, unlike the words
  act's unseen words); `rollBack` restores a file only across a key change, and putting the mirror's older lock back
  would be a repair by guessing (rule 21). The library opens by its quiet road or by the new passphrase, and the next
  Change re-locks from there — the loop pins exactly this as the second legal state (the old passphrase XOR the new
  opens the file, never both or neither). The synced twin: a landed vault write stands with the file rolled back (the
  account opens with the press's passphrase, the library with the old one) until the next Change, which re-locks both
  (pinned: `aSyncedChangeStoppedAfterItsVaultWriteRollsBackAndTheLandedWriteStands`). Residue (2) — rule 20's "says
  which" lives in Diagnostics only on the new road — is pre-existing for every act, unchanged. F-U1a-1 (below) is the
  adjacent class this fix does not reach.
- Piece 5 — the close: DONE (this commit) — the core and app lines as built, the counts, the Mac-suite list with its
  red-on-old recipe, the PROVISIONALs, the findings and the machinery notes below. (`f587b6382`: the backup hook's header
  comment names the far leg and retention — comment only.)
- No revert is in flight (every mutation and behavioural revert of this unit ran on a committed tree and was restored by
  `git checkout --`, `cmp`-identical to a copy in this session's scratchpad `u1a-prerevert/`; no scratch worktree; the
  tree is clean at the close).

**THE CORE LINES, LINE BY LINE (for the Fable ladder — `git diff 0965d68bd -- Sources/`):**
1. `Assess/OwnCopies.swift` (NEW, pure): `isThisMacsCopyOfThisLibrary(_:libraryID:thisMac:)` — retention's closure moved
   VERBATIM (kind `.backup`; `mac == .mac8(<this Mac's mac8>)`; `library == libraryID` from the pair's own key file;
   `folders[1]` the library's own `<library8>`); `of(_:libraryID:thisMac:in:)` — that predicate in one place;
   `stampIsTrusted` — `stamp <= now`, StoreBackup's 18o U1 rule restated byte-equal (a Mac pin holds them equal);
   `Summary` / `summary` — the count every own pair (as today's face counts every dated file), newest and oldest over
   trusted stamps; `farPairIsDue(_:libraryID:thisMac:now:interval:)` — due unless an own FAR pair has a trusted stamp
   younger than `interval` (today's far leg's question, asked of this Mac's own pairs of this library).
2. `Assess/Retention.swift`: the inner predicate calls `OwnCopies.isThisMacsCopyOfThisLibrary` — identical behaviour
   (`RetentionTests` + its DEBUG guard pin green unchanged); the guard-off arm untouched; the header names the caller.
3. `Executor/Acts/KeyDoors.swift` — `KeyDoorProgram.resumeCannotFinish` (VX-450): `guard ctx.resuming` FIRST (M1-c's, so
   a press never reaches the arm — pinned load-bearing by M-450c); then by act — the words act: its words in hand (as
   MAJOR-1 built it); Change and Reset: `ctx.secrets.passphrase` (at a resume derived ONLY from a passphrase typed there,
   under the plan's fresh descriptor — `derive`, `passphraseIsNew` true for these acts); any other act: nil; then for all
   three the live key file of the key. Same call site (the vault and key-file steps only), before any write →
   `ActRollback` → `drive`'s one rollback → `.rolledBack(act)`. Untouched: every press; a resume HOLDING a typed
   passphrase (the plan-level check in `resume` and the vault's refusals judge it — F-U1a-1 is the gap there); the memory
   step (no secret); the plan-less finish (`["memory"]`).

**THE APP LINES AS BUILT (for the ladder):** THE PAIR ROAD — `ProtectionBackupHook.takePair(_:now:guards:)`
(`ProtectionBackupPair.swift`): one road at a time (`oneAtATime`, an `NSLock` held for the whole road); the gates
unchanged (copies paused; the live key file of the key); `FileBackupsLeaf.writeContainerPair` (the old
`takeBackupPair` body, returning the snapshot it wrote — the protocol method calls it); then `landFarPair(session,
snapshot:keyFile:deviceID:now:)` — no far folder ⇒ `.noFarFolder`; a FRESH catalogue read → `OwnCopies.farPairIsDue(…,
interval: farInterval)` (24 h) ⇒ `.notDue`, or the leaf's `landFarPair(copying:key:keyFile:deviceID:)` (the picked
folder's scope claimed; the picked folder must exist — never re-made; the same two names under `Variorum/Backups/
<library8>/<mac8>/`; an existing name refused; verified — the key file reads back, the snapshot opens with the key; a
failed copy removed whole; the far catalogue id returned) ⇒ `.written(id)` or `.failed` — logged, never raised; then
`prune(session, libraryID:deviceID:guards:)` — a FRESH catalogue read → `Retention.plan(… .standard, guards:)` → one
`deleteCopies(ids: [id])` per prune id, a failure logged and skipped, each id logged once its file is gone. The pair's
outcome stays the container's, so every caller is unchanged (the hook's `copiesChanged`, VX-447's backed-up receipt).
DATA SAFETY — `ProtectionCopyCounts.read(session)` → `RoadCopyCounts` (container + far `OwnCopies.Summary`, a fresh
catalogue read); `RoadStandingModel.copyCounts` (built in `make` from the open's session, off the main actor; nil on a
hand-made face); `DataSafetyModel(roadCounts:)` — `refresh` takes the counts BEFORE assigning, then `counted(_:_:)` over
the rows as read (paths, `exists`, unset/unreachable kept); `DataSafetyPane` hands `roadStanding?.copyCounts` (nil on
today's road ⇒ `primary = read.primary`, `destination = read.secondary`, byte-unchanged).

**COUNTS (the final tree — `f587b6382` + this record):**
- HEADLESS HARNESS (U1's recipe rebuilt in this session's scratchpad `u1-harness`, re-pointed at this worktree; it now
  also symlinks `Shared/Protection/ProtectionCopyCounts.swift` and this unit's three headless suites): **`✔ Test run with
  290 tests in 47 suites passed after 3.359 seconds.`** (the 272/43 baseline + 18/4: `ProtectionFarPairTests` 10,
  `ProtectionCopyCountsTests` 3, `ProtectionPairRetentionTests` 4, `ProtectionPairRetentionGuardMutationTests` 1).
- CORE: the protection set (every `@Suite` type under `Tests/VariorumCoreTests/Protection` — 86 now, the filter re-derived
  from the files) Debug **`✔ Test run with 358 tests in 86 suites passed after 6.034 seconds.`** (347/84 + 11/2:
  `OwnCopiesTests` 5, `KeyDoorResumeTests` 6); Release (`swift test -c release`, the same filter) **`✔ Test run with 334
  tests in 82 suites passed after 4.822 seconds.`** (323/80 + 11/2). THE FULL CORE SUITE, Debug (`swift test`):
  VariorumCoreTests `✘ 3335 tests in 434 suites … with 1 issue` — `PerfBenchmarkTests
  .timelinePageIsFlatOrUnderBudgetInCorpusSize`, the P1 wall-clock RATIO bound under the full parallel run (small 3.25 ms
  vs big 10.24 ms, 3.15× against 3×, load average ~7.5 — the class VX-305's record names); ALONE `✔ Test run with 6 tests
  in 1 suite passed` (0.55 vs 0.92 ms, 1.66×); the third target `✔ 40 tests in 6 suites`; VariorumMCPTests `✘ 383 tests in
  71 suites … with 1 issue` — the ONE recorded VX-353 flake (`MCPHarnessTimeLimitTests
  .aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 19.2 s vs 15 s); ALONE `✔ 3 tests in 1 suite`. No
  Queries, Operations or MCP line in this diff.
- RED ON THE PRE-FIX TREES (each unit of pins committed first): piece 1 `✘ 8 tests … 9 issues`; piece 3 `✘ 4 tests … 21
  issues`; piece 4 `✘ 5 tests … 35 issues`. MUTATIONS (each on a committed tree, restored `cmp`-identical): M-OC1..3,
  M-FP1..4, M-DS1..2, M-RT1..2, M-450a..c — every one red at its own pins (the pieces' lines); M-RT3 named, not run.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
  -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (no
  warning in a touched file); the phone `-scheme VariorumMobile -destination 'generic/platform=iOS Simulator'
  -configuration Debug … build` → **`** BUILD SUCCEEDED **`**; **the Release check `-configuration Release build` → `**
  BUILD SUCCEEDED **`**.
- Release behaviour: unchanged by construction — the pair road (and so the far leg and retention) is reached only from a
  new-road session (the hook attaches only for one; VX-447's banner is new-road); `roadStanding` is nil on today's road,
  so `DataSafetyModel.roadCounts` is nil and `refresh` assigns exactly as before; the core lines are the new road's
  executor's. The binary is not byte-identical (rule 24's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309 test \
  -only-testing:VariorumTests/DataSafetyRoadCountsTests \
  -only-testing:VariorumTests/ProtectionFarPairTests \
  -only-testing:VariorumTests/ProtectionCopyCountsTests \
  -only-testing:VariorumTests/ProtectionPairRetentionTests \
  -only-testing:VariorumTests/ProtectionPairRetentionGuardMutationTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/NoKeyFileDoorTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionPaneWaveTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/RoadKeyDoorSurfaceTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/BackupRunTests \
  -only-testing:VariorumTests/BackupOwnFilesTests \
  -only-testing:VariorumTests/BackupRetentionTests \
  -only-testing:VariorumTests/BackupSingleFlightTests \
  -only-testing:VariorumTests/DataSafetyRunbookTests \
  -only-testing:VariorumTests/BackupFutureStampTests \
  -only-testing:VariorumTests/MarkdownInsuranceTests \
  -only-testing:VariorumTests/SyncSafetyFaceTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests
```
The first five are U1a's (4 + 10 + 3 + 4 + 1 = **22 tests**; only `DataSafetyRoadCountsTests` is Mac-only — the other four
are headless-green too; `DataSafetyRoadCountsTests` bookmarks a temp folder into a SCRATCH defaults suite, never
`.standard`). Then the suites over the files this unit touched: the pair road's callers (the hook, VX-447's banner door,
Make this my library's route), the file leaves, `PlantedRoad`'s users (`init(farFolder:)` — default unchanged),
`RoadStandingModel`'s hosts (its init grew a defaulted parameter), Data Safety's model and pane (`DataSafetyTests`' five
suites, the future-stamp, insurance and sync faces, the portability door that composes the pane), and the source scans
over the edited files. **THE RED-ON-OLD BY BEHAVIOURAL REVERT (the orchestrator's, from a committed tree, restored by
`git checkout --`):** (R-a) in `DataSafetyModel.refresh`, the road's three lines back to `primary = read.primary` /
`destination = read.secondary` (the `let counts` line dropped) → `DataSafetyRoadCountsTests
.theNewRoadsRowsCountThisMacsPairsOfThisLibraryAndTodaysRoadIsUnchanged` RED (the new road's rows read today's flat
counts, 3 and 2); (R-b) `ProtectionBackupHook.farInterval` → `12 * 60 * 60` → `theRestatedRulesAreStoreBackups` RED.

**WALK NOTES FOR THE ACCEPTANCE SPINE (the orchestrator's walk — the dev store, a throwaway picked folder, under a held
claim):** with a picked folder set, Back Up Now on the dev library → `Backups/<lib8>/<mac8>/` beside the library AND
`<picked>/Variorum/Backups/<lib8>/<mac8>/` hold the same new pair (`cmp` the two files); log lines `backup pair: written
under …`, `backup pair: copied to the picked folder — farFolder:Backups/<lib8>/<mac8>/variorum-backup-<stamp>-<fp8>
.sqlite`; a second Back Up Now → a second pair beside the library only (`… the picked folder holds this Mac's fresh pair
of this library — none copied there`); Data Safety's two rows count PAIRS (today's flat files beside them are not
counted on the new road); retention removes only past 14 beside the library / 14 + 4 in the picked folder (`backup pair:
retention removed …`). The dev store's own picked-folder setting is to be read (and restored) under term 3 — never left
pointing at the throwaway.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX309-U1a-1 — the far pair rides only a run that WROTE a container pair** (the brief's letter; the hook fires on a
  written run): (a) BUILT — a drive that returns after the day's run waits for the next written run (≤ the interval);
  (b) every run (an up-to-date one too) asks the far folder's due-ness and copies this Mac's newest container pair of
  this library (today's flat leg's own cadence — the hook would act on every hourly tick's record); (c) the far leg its
  own clock.
- **P-VX309-U1a-2 — no "force" for the far pair:** (a) BUILT — due-ness only, so a second Back Up Now within 24 h lands a
  second pair beside the library and none in the picked folder (today's flat leg copies on every forced run); (b) a
  forced run lands the far pair whatever its due-ness (the run's force would have to reach the hook — `BackupRunRecord`
  carries none, a `StoreBackup` line, READ ONLY here); (c) Back Up Now's own door calls the pair road with a force.
- **P-VX309-U1a-3 — the far pair is the container pair COPIED** (one backup in two places, one name — R-U1a-1): (a) BUILT;
  (b) a second snapshot taken straight into the picked folder (two instants; its check proves nothing of a transfer).
- **P-VX309-U1a-4 — a vanished picked folder is never re-made by the pair road** (today's flat leg's
  `createDirectory(withIntermediateDirectories:)` re-makes it — the leg writes into a folder nobody picked any more):
  (a) BUILT; (b) today's shape.
- **P-VX309-U1a-5 — Data Safety's rows on the new road keep their two paths and count this Mac's pairs of this library
  inside them** (R-U1a-4): (a) BUILT; (b) each row names the `<library8>/<mac8>` subfolder; (c) a row per Mac and per
  library (U1b's other-libraries listing is the place for the rest).
- **P-VX309-U1a-6 — retention runs after a pair the PAIR ROAD wrote** (the hook's written runs, VX-447's follow), not after
  an act's own `freshBackup` step (a crossing's pair — pruned at the next written run, the rule counting it among the
  14): (a) BUILT — the leaves stay dumb and no act's plan gains a delete step; (b) an executor step after each act's pair
  (a plan step that deletes copies); (c) a retention pass among each open's repairs.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U1a-1 (Bug, Confirmed by probe, Castle & sync — PRE-EXISTING, adjacent to VX-450; a ticket at closeout, the ladder
  may weigh it):** a Change (or Reset) stopped after its begin whose next open TYPES THE OLD PASSPHRASE — Castle under
  Always ask, where before the key-file step lands only the old passphrase opens the live key file, or any lobby —
  RESUMES and "finishes": `derive` reads the lobby's `typed.passphrase` under the plan's FRESH descriptor; `resume`'s
  press-secret check finds no lock under that descriptor yet and passes; the key-file step (synced, the vault step too)
  re-locks the library under the OLD passphrase on a new salt; the settle returns `.resumed(changePassphrase)` — the
  passphrase chosen at the press is never set, and nothing says so (Diagnostics only — residue (2)'s class). Not a wedge;
  the old passphrase keeps opening. A TRANSIENT probe on the fixed tree (written, run, removed — never committed):
  Standard and Castle/Always ask both `outcome=resumed(changePassphrase) … fileChanged=true kdfChanged=true oldOpens=true
  newOpens=false`. (Found by a test of mine passing `.none` into `relaunchAndSettle`'s `TypedSecrets?` — Swift's
  `Optional.none` — so the fixture's own secrets were typed.) Options: (a) a resume whose only typed passphrase opens
  the lock the act is REPLACING (no lock under the plan's descriptor yet) rolls back — it is not the act's secret (one
  more condition in VX-450's arm); (b) the lobby asks for the passphrase chosen at the press while a Change is in flight
  (a face); (c) accept, and say it as rolled back in Diagnostics.
- **F-U1a-2 (Debt, Test-only, Tests & tooling, Low):** `EX.relaunchAndSettle(_ typed: TypedSecrets? = nil, …)` — a test
  writing `.none` gets `Optional.none`, i.e. the fixture's OWN secrets typed, the opposite of what it reads as
  (`NewWordsResumeTests` spells `TypedSecrets.none`; mine first did not). Options: a non-optional parameter with an
  explicit `.fixturesOwn` case, or a distinct label.
- **F-U1a-3 (for U2's words):** the far leg speaks only in the log; on the new road Data Safety's picked-folder row's
  caption (*Kept there: the 14 most recent days that have a copy, plus one copy from each of the 4 weeks before those.*)
  is now TRUE of this Mac's pairs of this library, and nothing says the counts are this Mac's and this library's, nor
  why a second Back Up Now in a day adds none there (P-VX309-U1a-2) — U2's sentences, if any.
- **F-U1a-4 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains, in place, one pointer to this
  plan: on the new road a backup run lands rule 5's pair beside the library and, when due per library per Mac, the same
  pair in the picked folder; retention (newest 14 beside the library; 14 + 4 in the picked folder) prunes only this
  Mac's pairs of this library; Data Safety's counts there are this Mac's pairs of the open library. P-VX306-U1a-4's
  bundle row is superseded (its option (c) built, per library per Mac).
- **F-U1a-5 (Tests & tooling — record only):** the full core suite's two wall-clock reds under the parallel run (the
  VX-353 MCP bound; the P1 timeline-page ratio at load ~7.5), both green alone — existing classes, no line of this diff.
- **F-U1a-6 (MOBILE PARITY):** nothing mobile-visible — the phone runs no `StoreBackup` and no pair road (its store is
  re-derivable from the mirror, A1's own note); the shared files compile for iOS (the phone build green).

**U1a ARBITRATION (the orchestrator, 2026-10-19 — repo-first before U1b spawns):**
- **F-U1a-1** (a resumed Change/Reset typing the OLD passphrase "finishes" under it — the chosen passphrase never set,
  the outcome says resumed; Confirmed by probe, pre-existing): **FIX IN-PHASE, option (a), as U1b's piece 0** — it is
  VX-450's own class (a key-door act interrupted mid-plan ending in a state that is neither rule 20's old nor new,
  with nothing said), the arm is one more condition in the same core file this phase already holds open, and the
  ladder reviews it cold. The shape: at a RESUME of Change or Reset, a typed passphrase that opens only the lock the
  act is REPLACING (no lock under the plan's fresh descriptor stands yet) is not the act's secret ⇒ `ActRollback`
  before any write. Pins red-on-old per the probe's two postures (Standard; Castle/Always ask). PROVISIONAL
  P-VX309-U1b-0 — options (b) a face asking for the press's passphrase and (c) accept-and-say stay in the bundle for
  her. VX-450's ticket closes at the merge naming BOTH arms (piece 4 + this).
- **F-U1a-2** (the `TypedSecrets?` test trap): a TICKET at closeout (Debt, Test-only, Tests & tooling, Low).
- **F-U1a-3**: FOLDED into U2's brief (the far leg's and the counts' sentences, if any — her words pass).
- **F-U1a-4**: the closeout's canon delta list (supersedes P-VX306-U1a-4's bundle row).
- **F-U1a-5**: record-only (two known wall-clock classes, both green alone, no line of this diff).
- **F-U1a-6**: the MOBILE PARITY line at closeout ("nothing mobile-visible").
- **P-VX309-U1a-1..6: each stands as built** pending her bundle — the narrow arms, every one consistent with the
  rules' letter; U1a-2's visible consequence (a second same-day Back Up Now adds no far pair, unlike today's flat
  leg) is flagged to U2's words and the bundle row says it plainly.

**THE U1a MAC BATCH (the orchestrator, 2026-10-19 18:30–18:33 MDT first run, stage claim `vx-309-u1a-mac`, the
coordinator's GO; log `/tmp/vx309-u1a-mac-run.log`, deleted at closeout):** 183 tests / 31 suites, ONE real red —
and it was a REAL FIND, not a pin anchor:

- **MB-1 (Bug, Confirmed live — the orchestrator's own fix at adjudication, the commit above):**
  `ProtectionFarPairTests.onlyThisMacsOwnTrustedFreshFarPairMakesItNotDue`'s future-stamp arm red under the Mac
  host: the far due-check rightly distrusted the planted future-stamped pair and wrote the due pair — and RETENTION
  THEN PRUNED THE FRESH PAIR, because a future-stamped copy claimed the UTC day's slot (`keepDailiesAndWeeklies`
  newest-first) and the real pair fell to a covered-week remainder. Write-then-delete churn: under a clock-glitch
  copy, every written run's far pair would be deleted on landing until the wall clock passed the stamp; the same
  shape could crowd the container's newest-14. The implementer's headless green was UTC-MIDNIGHT LUCK (its run sat
  in the one hour where `now+1h` crossed the UTC day, so the two stamps took different day slots). THE FIX (core,
  new-road-only; today's `BackupRetention.keep` byte-unchanged — it retires with today's road): `Retention.plan`
  gains an explicit `now` (no default; every call site passes its clock — the pair road its own `now`, the scenario
  world its `clock`, the test fixtures `CF.stamp(1_000)`), and a copy whose stamp `OwnCopies.stampIsTrusted` rejects
  claims NO slot — kept exactly like an undated copy, never counted among the container's 14 or the far dailies and
  weeklies, never pruned (18o U1's rule extended from freshness-reads to slot-claims; "a real snapshot with a wrong
  date is never this rule's to delete" now also means it never gets a real one deleted). PIN
  `RetentionTests.aFutureStampedCopyClaimsNoSlotAndIsNeverPruned` (deterministic, fixed clock, both places);
  red-on-old = the batch's own observed red PLUS the behavioural revert (`trusted = dated`, the pre-fix slot rule) →
  the pin red with 2 issues, restored `cmp`-identical against `/tmp/vx309-mb1-premutation.swift`. Headless:
  `RetentionTests` + `RetentionGuardMutationTests` + `OwnCopiesTests` `✔ 12 tests in 3 suites`. **THE FULL CORE
  SUITE after the fix:** VariorumCoreTests `✔ Test run with 3336 tests in 434 suites passed` (U1a's 3335 + the MB-1
  pin; the PerfBenchmark ratio red of the implementer's run did not recur), the third target `✔ 40/6`,
  VariorumMCPTests `✘ 383/71 with 1 issue` — exactly the recorded VX-353 wall-clock flake (21.1 s vs 15 s under the
  parallel run). **THE FIVE-SUITE MAC RE-RUN after the fix: `✔ Test run with 22 tests in 5 suites passed`.** For the
  ladder: the one core file is `Assess/Retention.swift`; the call-site edits are mechanical (`now:` threaded).
- Every other suite green on the first run (the known skip-shaped lines were build-tool noise, no VX-310 witnesses in
  this batch's list); 0 instances at the run's end.
- **THE R-a / R-b BEHAVIOURAL REVERTS (run 2026-10-19 ~18:50 MDT, the same claim):** (R-a) `DataSafetyModel.refresh`'s
  road lines dropped → `theNewRoadsRowsCountThisMacsPairsOfThisLibraryAndTodaysRoadIsUnchanged` RED (2 issues — the
  new road's rows read today's flat counts), restored `cmp`-identical; (R-b) `farInterval` → 12 h →
  `theRestatedRulesAreStoreBackups` RED (1 issue), restored `cmp`-identical. The confirming re-run
  (`DataSafetyRoadCountsTests` + `ProtectionFarPairTests`) `✔ Test run with 14 tests in 2 suites passed`; tree clean;
  0 instances; the stage released with the coordinator's result line. **THE U1a MAC LEG IS CLOSED.**

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree. The harness was rebuilt in this
session's scratchpad from U1's recipe (the VX-308 harness's `Package.swift`, stubs and symlink list re-pointed); the
core's `.build`, the harness's `.build` and `App/Variorum/DerivedData/vx309/SourcePackages` were seeded by APFS clone from
existing caches (the main checkout's, the VX-308 harness's, the main checkout's Xcode DerivedData) with their absolute
paths re-pointed — no package fetch. One TRANSIENT probe file (`ZZProbeU1aF1.swift`, F-U1a-1) was created, run and
removed in the same command, never committed. One mutation edit (M-FP2's first) was malformed — it short-circuited the
guard into always refusing — and was DISCARDED and redone as the exact removal. Every pin set committed before its fix
(`2c2b7d412`, `2d18617c8`, `e6bd14584`); every mutation named in the record and committed before it ran. Commits:
`95659b477` (0) · `8e027494a` (1 core) · `9e0e4a13c` (record) · `2c2b7d412` (1 pins first) · `c09b93ed8` (1) ·
`09b087bde` (record) · `4b402d8e0` (record) · `2c3175cda` (2) · `7ee076ce8` (record) · `25abab3ed` (record) · `2d18617c8`
(3 pins first) · `635a6a8e6` (3) · `dd770eab1` (record) · `972dea6a4` (record) · `e6bd14584` (4 pins first) ·
`7b9e5793f` (4) · `63c326d4e` (record) · `1ed9866cf` (record) · `f587b6382` (comment) · the close commit.

### U1b RECORD — THE COPY DOORS (Opus implementer, 2026-10-19; piece 0 F-U1a-1 · T-5 · VX-305's second hand-off · T-8 — BUILT; the Mac suite and the walk PENDING)

**Not done in U1b, first:**
- NO MAC SUITE RUN, NO WALK, no stage, no Debug launch, no store touch, no network, no Linear, no subagent (the brief).
  Three new suites are Mac-only (the keychain or the app's source files) and were BUILT, never run:
  `EmptySlotMakeMineRouteTests`, `EmptySlotDoorsSurfaceTests`, `PlaintextExportBringInRouteTests` — the orchestrator's,
  under the stage (the list and the red-on-old recipes below). The planted suites ran headless only.
- EVERY NEW SENTENCE IS UNDRAFTED against her words (P-VX309-U1b-3 — U2's words pass): T-5's lead and receipt, the
  restore list's lead and its empty line, T-8's lead, button, working line, refusals and receipt.
- ROUTED, NOT BUILT (the findings below): F-U1b-1 (entering Castle leaves a Previous Library's quiet roads standing — a
  rule question); F-U1b-7's writing-road arm (a creation that refuses after T-8's step-aside leaves the slot empty —
  only the read-only arm is fixed); F-U1b-8 (T-8 from an open Castle library lands a Standard library — the ruled road,
  read against rule 17's last sentence); F-U1b-3 / F-U1b-4 (a test-tooling lift; a stale comment).
- T-8 brings in only THIS build's export (P-VX309-U1b-7): an earlier or a later build's refuses with words; no migration.
- No canon line, no QUESTIONS row, no ticket — the merging session's (the PROVISIONALs and findings below carry them).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE (rules 2, 14, 17–19, 20–21, 26–27 + the considered-and-not-pursued ledger); `notes/SyncSpec.md`
WHOLE (no `Sync/` line here); `notes/SurfaceContracts.md` whole (Doors — portability's restore hold + Library protection;
The app's words rules); this plan WHOLE (§0–§3, §5a, §5b, the §6 U1a RECORD with its ARBITRATION and MAC BATCH — MB-1's
`Retention.plan(now:)`); the lifecycle page's stages 9, 10, 13, 14 (read as text, never edited); `notes/plans/vx-306-castle-open-road.md`
§2 U3 + its addendum and the §9 U3 RECORD whole (P-VX306-U3-0..18, LOOK INSIDE AS BUILT, the U3 BATCH + WALK RECORD);
`notes/plans/vx-308-accounts-key-doors.md` §6 ROUND-1 FIX LEG (MAJOR-1's trace, fix, residue) + the U3 RECORD; the core —
`Executor/Acts/Copies.swift` WHOLE, `Acts/DeviceActs.swift` (`createLibrary` — the brief's "Creation.swift"), `Acts/KeyDoors.swift`,
`Acts/CommonSteps.swift`, `PlanRunner.swift`, `Executor.swift`, `Leaves.swift`, `Assess/Assess.swift`, `Assess/Catalog.swift`,
`Assess/CatalogNames.swift`, `Model/KeyFile.swift`, `Model/Plan.swift`, `Files/ProtectionLibraryFiles.swift`,
`Files/ProtectionCopyPeek.swift`, `Persistence/LibraryRestoreHold.swift`, `Persistence/StorePlaintextExport.swift`,
`Persistence/LibraryClassifier.swift`, `Domain/VariorumDocument.swift`, `Domain/VariorumDocumentFolder.swift`,
`Operations+DocumentImport.swift`, `Queries/Export.swift` (the bulk manifest); the app — `CopyDoorsModel.swift` WHOLE,
`LookInsideModel.swift`, `PickedCopy.swift`, `ProtectionCopyDoors.swift`, `ProtectionOpenRoad.swift`, `ProtectionLobbyFace.swift`,
`ProtectionOpenFaces.swift`, `ProtectionRoadActs.swift`, `ProtectionPlaces.swift`, `ProtectionSystem.swift`,
`SQLCipherLibraryLeaf.swift`, `FileKeyFileStoreLeaf.swift`, `CatalogLister.swift`, `WordsBand.swift`, `AppBootstrap.swift`
(the new-road arms, `copyDoorsRoads`/`copyDoorsRoadsWithoutALibrary`, `makeThisMyLibrary`, `makeMissingLobby`,
`LibraryMissingLobby`), `MarkdownInsurance.swift`, `ExportWriter.swift`, `LaunchFurniture.swift` + the seeder's marks, the Mac
faces `CopyDoorsSheet.swift`, `LibraryOpenDoor.swift`, `LibraryMissingView.swift`, `VariorumApp.swift`'s state arms, the import
door `DocumentImporter.swift` + `ImportModel.swift`; the test worlds — `ExecutorWorld`, `EX` (`ExecutorFixtures`), `CrashHarness`,
`KeyDoorResumeTests`, `U2CopyDoorTests` (`plantCopy`), `PlantedRoad` (`ProtectionOpenRoadPlantedTests`), `ProtectionTestSupport`,
`MakeMineRoadTests`, `MakeMineRouteTests`, `PickedCopyRoadTests`, `LookInsideRoadTests`. HARNESS: U1a's scratchpad package
`u1-harness` (this session's scratchpad — it survived; pointed at this worktree, `--skip-update`): the BASELINE on `cd22a9b44`
`✔ Test run with 290 tests in 47 suites passed after 3.589 seconds.` (U1a's close count, exactly).

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U1b-0 — F-U1a-1's ARM LIVES IN `resume`, AND IT DROPS THE SECRET (VX-450's arm then rolls back).** At a RESUME of Change
  or Reset (`passphraseIsNew`), the passphrase a lobby typed is derived under the plan's FRESH descriptor. It is NOT the act's
  secret when it opens no lock under that descriptor (the live key file, the sealed mirror) AND it opens a passphrase lock under
  an OLDER descriptor among them — the lock the act is replacing. Then `resume` drops it from the act's secrets before the
  plan-level and vault checks, and `KeyDoorProgram.resumeCannotFinish` (U1a's VX-450 arm) throws `ActRollback` at the vault or
  key-file step BEFORE any write; a resume whose only remaining step is `memory` (the new lock already landed and recorded)
  still finishes — honestly, the new passphrase IS set. The check is in `resume` because only there is the TYPED TEXT in hand
  (the act holds only the derived key). PENDING the probes: the three shapes this covers — (A) nothing landed (F-U1a-1's
  "finish under the old passphrase on a new salt"); (B) synced, the vault write landed, the key file not (the resume's vault
  check throws `passphraseDoesNotOpen` out of the settle — a wedge, by my trace); (C) the key-file write landed but not recorded,
  the old passphrase opening the library through the mirror (`passphraseDoesNotOpen` out of the settle — a wedge, by my trace).
- **R-U1b-1 — T-5 IS A NEW CORE ACT ON MAKE-MINE'S OWN STEPS, NO LIBRARY IN HAND.** `perform` cannot begin an act with no
  record to name it in, so the empty-slot landing begins itself (createLibrary's no-library pattern): the slot AND the live
  place must be empty (`libraryAlreadyInSlot` otherwise, before anything is minted); the copy must open by the TYPED secret
  alone (each typed road tried on its own, `.withoutAPress`; a quiet road's key never counts — rule 14's precedent: it carries
  no pair); then ONE plan sealed under the new key, its act `.makeMine` named by the new record's section — Make this my
  library's own steps, reordered so the keychain and the live place are written only once the copy is staged — and `drive`
  runs it. A crash before the swap leaves the slot empty (the old state) beside the press's own writes (each names a library
  that never landed — none of hers is touched); after it, the next open finds the new library by its silent item and the
  registry's `MakeMineProgram` finishes `forgetOtherLibraries` and `backup` from the plan. The words: the copy's own typed words
  ARE the new library's words lock; with its passphrase, a passphrase lock on a fresh descriptor and twelve words minted fresh
  (rule 2) — handed back, dropped unseen on the Mac, the card above the quick entry offering fresh ones at the first look (the
  creation's idiom). The APP's faces set aside what stands in the slot first — exactly *Start a New Library*'s pre-steps (a
  library no key file opens moves WHOLE; else a missing library's key file alone) — and hold the copy as every adoption does.
- **R-U1b-2 — PREVIOUS LIBRARIES THROUGH THE DOORS: VERIFY, PIN, CLOSE WHAT THE ARC SHOWS.** VX-305 U4's deferral (1)
  read §3.7's "a copy of a library this Mac remembers … is re-encrypted under that library's current key"; her rule 17
  (2026-10-16/17) superseded it — Make this my library makes ANY copy a NEW library (a fresh identity and key, under the
  current pair) — so "returns as the library" means returns as a NEW library holding its writing, exactly the doors' road;
  no identity-preserving road is built (the considered-and-not-pursued ledger: "an identity-preserving restore"). The arc
  is the doors' (listing · Look inside · Make this my library from an open library and from the empty slot); what it shows
  missing is closed in this unit when it is a door's, and routed when it is a rule's (F-U1b-1).
- **R-U1b-3 — T-8 IS THE CREATION'S ROAD PLUS THE IMPORT ROAD, HEADLESS, BEFORE THE FIRST OPEN** (the ruling §5b-R: reading
  (a) — the unencrypted `.sqlite`; "content and its placement ride — including its kept-out-of-view-ness; configuration
  does not"). The new library is exactly a creation (`ProtectionOpenRoad.create` — fresh identity, key, device ID, Standard,
  its words for the band), so it opens as a creation does (`.roadCreated`); before that open its store is opened once
  headless and the export's content minted into it through the ordinary operations (no undo stack — a library's birth).
  What stands in the slot steps aside WHOLE first — an open library (its pool closed by the bootstrap's seam) with its key
  file AND its restore hold (the hold is that library's), a missing library's key file, rule 27's unopenable library — and
  any hold still standing is cleared (the ruling: no restore hold). The export's schema must be this build's: the projection
  decodes current rows, and migrating a plaintext export would meet its outbox triggers naming dropped tables (13x's
  recorded reconciliation step) — P-VX309-U1b-7.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton + the readings + the harness baseline: DONE (this commit).
- Piece 0 — F-U1a-1's fix (VX-450's second arm): DONE (`3180d56c7` pins first · `22856d3dd` the fix). CORE (the custody
  line — THE CORE LINES below): `KeyDoorProgram.typedPassphraseOpensOnlyTheReplacedLock` (`Acts/KeyDoors.swift`, reads only)
  + its one call in `PlanRunner.resume` (the typed text is in hand only there): at a resume of Change or Reset, the passphrase
  the open typed is DROPPED from the act's secrets when it opens no passphrase lock under the plan's fresh descriptor (the live
  key file, this Mac's sealed mirror) and does open one under an older descriptor — so U1a's VX-450 arm rolls the act back
  before any write. Pins `KeyDoorOldPassphraseResumeTests` (core, 5): RED ON THE PRE-FIX TREE `✘ Test run with 4 tests in 1
  suite failed after 0.027 seconds with 15 issues.` — the probe's two postures, both doors, unsynced and synced, `.resumed`
  with the key file (and the synced vault) re-locked under the OLD passphrase on a new salt; shape B (synced, the vault write
  landed) and shape C (the key-file write landed, the old passphrase opening through the mirror) `the settle threw
  .passphraseDoesNotOpen` ×4 — the act in flight for good (my trace confirmed: R-U1b-0's B and C were real wedges, the same
  class as VX-450); the two guards (a resume typing the NEW passphrase after the key file landed; a passphrase re-chosen as it
  was) green on both trees. With the fix `✔ Test run with 5 tests in 1 suite passed`; with the key-door neighbours
  (`KeyDoorResumeTests`, `NewWordsResumeTests`, `FileLessWordsTests`, `FirstLookWordsTests`, `ExecutorKeyDoorTests`,
  `U2CrashHarnessTests`, `ExactWritesTests`, `ExecutorDeviceActTests`) `✔ Test run with 43 tests in 9 suites passed` (before
  the re-chosen guard joined); the core protection set (88 `@Suite` types re-derived from the files) Debug `✔ Test run with
  364 tests in 87 suites passed after 5.332 seconds.` MUTATIONS on `22856d3dd` (each restored by `git checkout --`,
  `cmp`-identical to `u1b-prerevert/`): M-0a the replaced-lock arm off → `✘ … 15 issues` (the pre-fix red set exactly);
  M-0b the plan-descriptor guard dropped → `✘ aPassphraseReChosenAsItWasIsTheActsOwnSecret` (1 issue); M-0c the call site
  without the sealed mirror → `✘ aKeyDoorWhoseKeyFileLanded…` (2 issues — shape C's old passphrase opens only the mirror).
  THE SYNCED TWIN, honestly: before its vault write a resumed synced Change typing the old passphrase rolls back with the
  vault untouched; after the vault write landed it rolls back with the landed write standing (the account then opens with the
  passphrase chosen at the press, the library with the old one) until the next Change re-locks both (pinned) — U1a's MAJOR-1
  consequence, now reached by the typed road too, where before it wedged. Shape C rolls back with the live file keeping the
  lock chosen at the press (MAJOR-1's residue (1), seen at the press) — pinned as the one legal state there. A same-text
  re-choice before the key file lands rolls back (indistinguishable from the replaced one — legal: the old state carries the
  same passphrase); after it lands, it finishes (pinned).
- Piece 1 — T-5, the empty-slot landing: DONE (`59e04579e` core · `f18824efc` the app's doors). CORE (THE CORE LINES below):
  `ProtectionExecutor.makeThisMyLibraryInTheEmptySlot(copy:in:typed:)` + `EmptySlotMakeMineProgram` + `LandedCopy` (`Acts/
  Copies.swift`) and `makeMineSwap(setAside:)` (default true — the standing act byte-unchanged). Pins `EmptySlotMakeMineTests`
  (core, 5 — the copy's words land it, nothing aside, one library, a pair; its passphrase lands it with fresh words never
  logged; a quiet road alone / a wrong secret refuses with nothing written; an occupied slot or a standing key file refuses;
  a crash after EVERY write leaves the empty slot or the new library, never a third state — a second press then lands it)
  `✔ 5 tests`; new API, so red by construction on the pre-unit tree. The protection set `✔ Test run with 369 tests in 88
  suites passed`. MUTATIONS on `59e04579e` (restored `cmp`-identical to `u1b-prerevert/`): M-1a the typed-road requirement off
  → `✘ aQuietRoadAlone…` (3 issues); M-1b the empty-slot guard dropped → `✘ anOccupiedSlot…` (4); M-1d `forgetOtherLibraries`
  dropped → `✘` the words test + the crash loop (22); M-1c (the swap's `setAside: false` → `true`) NAMED AND NOT RUN —
  unobservable (both leaves set nothing aside over an empty slot; the line is the brief's "skipped, not emptied", by reading).
  APP: `CopyDoorsRoads.landsInTheEmptySlot`; `MakeMineModel(intoTheEmptySlot:)` (no quiet probe; the copy's secret always asked;
  `canSubmitIntoTheEmptySlot` / `submitIntoTheEmptySlot` — the copy's secrets, NO current pair); `ProtectionCopyDoors
  .makeMineInTheEmptySlot` (preflight reads → the hold → `setAsideUnopenableLibraryFor` + `setAsideLiveKeyFileFor` — the faces'
  Start a New Library pre-steps → the core act → today's store id minted fresh; a refusal puts the hold back; past the swap
  made); `CopyDoorsContext.actExecutor()`; `AppBootstrap.makeThisMyLibraryInTheEmptySlot` (only at `.libraryMissing` or a
  rule-27 `.roadLobby`; one at a time; the reopen with the new key; T-5's receipt owed) and `copyDoorsRoadsWithoutALibrary()`'s
  `makeMine`; the Mac confirm's T-5 arm (`CopyDoorsSheet.MakeMineConfirm`); T-5's lead and receipt in `ProtectionWords`
  (PROVISIONAL P-VX309-U1b-3). Pins `EmptySlotLandingRoadTests` (4, planted — the missing face's backup lands, the missing
  library's key file aside byte-equal, held, a store id, one library, its note there; rule 27's library aside WHOLE and still
  opening under its own key; a wrong secret / a quiet road alone writes nothing; the confirm's brain) — the harness `✔ Test run
  with 294 tests in 48 suites passed`; `EmptySlotMakeMineRouteTests` (2, Mac only — through `AppBootstrap` on a throwaway scope;
  BUILT, the run the orchestrator's). `build-for-testing` → `** TEST BUILD SUCCEEDED **`. MUTATIONS on `f18824efc` (restored
  `cmp`-identical): M-1e the preflight's quiet-road refusal dropped → `✘ aWrongSecretOrAQuietRoadAlone…` (the hold restored but
  the missing key file moved — the typed check guards every write); M-1f the set-aside pre-steps dropped → `✘` both landing
  pins (3 — the core's belt refuses a standing key file / library); M-1g the store-id mint dropped → `✘ theMissingFaces…` (1).
- Piece 2 — VX-305's second hand-off (Previous Libraries through the doors): DONE (`53674fe03`). VERIFIED END TO END and
  pinned — `PreviousLibrariesArcTests` (5, planted, harness-visible): a library that stepped aside WHOLE (Make this my
  library's own step-aside) is LISTED among the other libraries on this Mac as a *Previous library* dated the day it stepped
  aside (rule 19); it opens READ-ONLY by its own quiet road and — that road gone — by its own words, nothing written (the
  planted write logs and the container's bytes unchanged); it RETURNS through Make this my library from an OPEN library (a
  new library, A's writing in it; B steps aside whole in its turn; A's own folder untouched) and from the EMPTY SLOT (T-5,
  under A's own words); a Previous Library picked by hand (its store or its folder) is the catalogue's copy, used where it is.
  The serving key file of a folder-shaped copy and the list's rows needed nothing (pinned as they stand). THE GAP the arc
  showed, CLOSED (F-U1b-2): with no library open nothing listed this Mac's copies — a Previous Library was reachable only by
  picking a folder inside the app's container — so on the new road the missing face's and rule 27's *Restore from Backup…*
  open the doors' listing (rule 17: "The app's Restore from Backup is this door"): `CopyDoorsModel.Phase.listing` +
  `beginListing()`, `LibraryOpenPresenter.openRestoreList(bootstrap:)`, the sheet's listing rows (each its Look inside… /
  Make this my library… — into the empty slot), `LibraryMissingView(restoreDoor:)` (gated on a home of copies —
  `LibraryMissingLobby.copiesHomeExists`; today's road keeps the Finder reveal byte for byte) and `RoadLockView(restoreDoor:
  copiesHome:)`; two lines (`emptySlotRestoreListLead`, `noCopiesOnThisMac`) PROVISIONAL P-VX309-U1b-3 — the availability arm
  itself PROVISIONAL P-VX309-U1b-5. Pins: the arc's `withNoLibraryOpenTheRestoreListOffers…` (the listing → the row's Make
  this my library → A's writing landed), `EmptySlotDoorsSurfaceTests` (2, Mac, by source — the needles verified against the
  files by the same comment-stripping read; red by construction). Harness `✔ Test run with 299 tests in 49 suites passed`;
  `build-for-testing` green. MUTATION on `53674fe03` (restored `cmp`-identical): M-2a `beginListing` lands an empty listing →
  `✘ withNoLibraryOpenTheRestoreListOffers…` (1). FOUND BY PROBE, ROUTED (F-U1b-1): VX-305 U4's deferral (1) at its heart —
  see the findings.
- Piece 3 — T-8: DONE to the ruling (§5b-R) — `1e9f4abb2` core · `10d9bb6d5` the app's door. CORE
  (`Operations+PlaintextExportImport.swift`, NEW): `PlaintextExportReading.read(exportAt:)` (the plan on a private staged
  copy — `LibraryClassifier.withStagedRead`; this build's schema only, `schemaNotCurrent(newer:)` otherwise; each living note
  through Copy full text's own projection parsed by `VariorumDocument.parse`, a blank one the format's stub, an untitled one
  named by its day; versions — `archived_at == created_at` — never; books a–z with chapters and members in the export's
  `(position, id)` order; snippet groups; wings) + `Operations.importPlaintextExport(_:landed:)` (content wings minted by
  name; every note once — `importDocument`; each book — ARCHIVED ones first, archived as they land — with its chapters and
  every member ADDED in order: once, membered in each; an empty book left out and named; archived notes and snippet groups
  archived after their memberships; snippet groups with their scraps — `createPool` + `importBlocks`; no undo entry) +
  `PlaintextExportLanding` (books · notes · snippet groups · wings · empty books · memberships left out). Pins
  `PlaintextExportImportTests` (3: the read plans exactly the content; the apply mints it fresh as ruled, row by row; an
  older or a newer build's export refuses) `✔ 3 tests` — new API, red by construction. MUTATIONS on `1e9f4abb2` (restored
  `cmp`-identical): M-3a versions not fenced → `✘` both content pins (4); M-3d archived notes not archived → `✘` the apply
  (1); M-3e the empty-book skip dropped → `✘` the apply (3); M-3f archived books not archived → `✘` the apply (1). WING
  ITEM 7 — BUILT AS (b): the import ops' own `wingId` parameters ARE an existing wing-context seam (`importDocument(_:
  wingId:)`, `createReading(…wingId:)`, tags adopting by path in the destination wing — R-13ia-1), so each export wing
  holding content is minted by name (`createWing`) and its notes and books land in it — no flattening, no merged
  vocabularies (pinned: Beta and its `studio/sketch` tag in the minted "studio" wing); a wing the export no longer has reads
  as Home. APP: `PickedCopy.Verdict.plaintextExport` (a plain-text FULL library keeps its refusal); `PickOutcome
  .plaintextExport` (never filed); `CopyDoorsModel.Phase.plaintextExport` + `bringIn(_:)` + `bringInStepsALibraryAside`;
  `CopyDoorRefusal.exportRefused(String)`; `CopyDoorsRoads.bringInPlaintextExport` (both roads); `ProtectionCopyDoors
  .readPlaintextExport` (preflight, reads) + `landPlaintextExport` (what stands steps aside WHOLE with its hold — `ProtectionOpenRoad
  .setAsideLibraryWholeFor(_:carryingHold:)`, which Start a New Library's own set-aside now calls, its behaviour unchanged;
  else the missing library's key file; any hold still standing cleared — the new library is never held; the creation's
  road; the content minted HEADLESS into the new store; the pool closed; the END'S LOG LINE naming what landed — the
  ruling's requirement); `AppBootstrap.bringInPlaintextExport` (`.ready`, the missing face, rule 27's lobby; the preflight
  before any teardown; with a library open the reopening seam's first half; nothing made ⇒ the open finds what stands, under
  the old key; made ⇒ `.roadCreated` — the creation's words dropped unseen, the band offers fresh ones — and the receipt
  `bringInReceipt` owed); the sheet's export phase; T-8's words (`bringInLead`, `bringInButton`, `bringInWorking`,
  `exportFromAnEarlierBuild`, `exportNoteUnreadable`, `bringInReceipt`) PROVISIONAL P-VX309-U1b-3. Pins
  `PlaintextExportBringInRoadTests` (4, planted: from an open library — a new library by the creation's road, the open one
  aside WHOLE with its key file and its hold, never held, the content there, the export only read, one library remembered,
  the receipt's words; from the missing face; the preflight's refusals write nothing; the doors' brain names the export and
  offers its door) + the FLIPPED `PickedCopyRoadTests.thePicksRefusalsAndTheChooser` (the export is NAMED, never filed — a
  JUSTIFIED EDIT); the harness `✔ Test run with 303 tests in 50 suites passed`; `PlaintextExportBringInRouteTests` (2, Mac
  only — through `AppBootstrap`, BUILT, the run the orchestrator's). `build-for-testing` green. MUTATIONS on `10d9bb6d5`
  (restored `cmp`-identical): M-3g the hold not carried → `✘ anExportComesIn…` (1); M-3i the missing key file not set aside
  → `✘ atTheMissingFace…` (1 — the creation wrote over it); M-3j the pick refusing the export → `✘ thePicksRefusals…` (1).
  HARNESS NOTE: the scratch harness's test target now names the author's GRDB fork directly (resolved OFFLINE from the
  existing pin and checkout, `--skip-update`) so the app pins can `import GRDB` as the Xcode target does — no repo change.
  AT THE CLOSE (self-assessment, two more commits on the same surface): `9c7785a34` — the landing LOGS WHAT THE EXPORT
  HOLDS BEFORE THE IMPORT (`road: bringing in a plaintext export — it holds N books · M notes · K snippet groups · W
  wings`), so a crash part of the way leaves that line without the end's and what landed reads against what was to land
  (the ruling's requirement on the crash window, made checkable from the log alone; a log line, no behaviour, unpinnable —
  `os_log`). `b923eabf6` pin first → `6d24bd2f5` fix (F-U1b-7's read-only arm): `landPlaintextExport` set what stood in the
  slot aside BEFORE the creation, and the creation refuses on a read-only road (`testRunNeverCreates`) — so on that road it
  left the slot EMPTY for nothing (the bootstrap's own `road.writes` guard kept the app's door off this path; the function
  did not guard itself). Now it refuses first. Pin `PlaintextExportBringInRoadTests.aReadOnlyRoadMovesNothing` RED on
  `b923eabf6` `✘ … 2 issues` (the container's tree changed; the library no longer opened in the slot), green on
  `6d24bd2f5`; the harness `✔ Test run with 304 tests in 50 suites passed`. The writing road's twin is ROUTED (F-U1b-7).
- Piece 4 — the close: DONE (this commit) — the core and app lines as built, the counts, the Mac-suite list with its
  red-on-old recipes, the walk notes, the PROVISIONALs, the findings and the machinery notes below.
- No revert is in flight (every mutation and behavioural revert of this unit ran on a committed tree and was restored by
  `git checkout --`, `cmp`-identical to a copy in this session's scratchpad `u1b-prerevert/`; no scratch worktree; the
  tree is clean at the close).

**THE CORE LINES, LINE BY LINE (for the Fable ladder — `git diff cd22a9b44 -- Sources/`; custody ⇒ Fable):**
1. `Executor/Acts/KeyDoors.swift` — `KeyDoorProgram.typedPassphraseOpensOnlyTheReplacedLock(_:act:planKDF:files:floor:)`
   (NEW, reads only): false unless the act is Change or Reset AND the plan names a descriptor; false when the typed text
   opens a passphrase lock UNDER THE PLAN'S DESCRIPTOR in any of `files` (the act's own secret — the same text re-chosen
   included); true when it opens a passphrase lock under an OLDER descriptor there (the lock the act replaces); false when
   it opens neither (the checks judge it as before). The floor is validated per descriptor; a derive or open failure
   counts as "does not open".
2. `Executor/PlanRunner.swift` — `resume`: `secrets` becomes `var`; ONE new `if` after `derive`: when the plan's
   `passphraseIsNew`, a passphrase was derived, and the typed text (`typed.newPassphrase ?? typed.passphrase`) answers true
   over `[library.keyFile, library.memory?.keyFileMirror]` (the live key file and this Mac's sealed mirror — M-0c pinned
   the mirror load-bearing), `secrets.passphrase = nil` and one log line; everything after it unchanged — so U1a's
   `resumeCannotFinish` throws `ActRollback` at the vault or key-file step before any write (`drive`'s one rollback), and
   a resume whose only remaining step is `memory` still finishes (the new lock landed). Untouched: every press; a resume
   typing the NEW passphrase; the plan-level and vault checks themselves.
3. `Executor/Acts/Copies.swift` — `ActContext.makeMineSwap(setAside: Bool = true)`: the default keeps the standing act
   byte-for-byte (the outgoing key file computed and passed exactly as before); `false` calls `swapStaged(setAside:
   false, asideKeyFile: nil)` — the step-aside half SKIPPED. NEW `EmptySlotMakeMineProgram` (T-5): steps `stage,
   recordIntoStaged, custodyItem, appleKey, keyFile, newMemory, swap` + `MakeMineProgram.afterCommit`
   (`forgetOtherLibraries, backup`); its `run` calls Make this my library's own step bodies (`makeMineStage`,
   `makeMineRecord(kind: .standard)`, `newCustodyItem(kind: .standard)`, `makeMineMemory`, `forgetOtherLibraries`,
   `freshBackup`), plus `appleKey` (this Mac's fresh Apple key, idempotent by id) and `keyFile`. NEW
   `ActContext.emptySlotKeyFile(apple:)` — idempotent (a live file of the new key stands ⇒ adopted); else `KeyFile
   .building(epoch: 1)` under `newLocks(passphrase: secrets.passphrase != nil, words: true, master: false, apple:)`. NEW
   `public struct LandedCopy` (library, `mintedWords` — redacted from `description`, outcome). NEW `public func
   ProtectionExecutor.makeThisMyLibraryInTheEmptySlot(copy:in:typed:)`: refuses `libraryAlreadyInSlot` when the slot is
   occupied OR a live key file stands (before anything is minted); opens the copy by each TYPED road on its own
   (`.withoutAPress`; `.quietRoad` ⇒ not counted) — words first, then passphrase; neither ⇒ `copyDoesNotOpen`; typed
   words ⇒ `secrets.words`; typed passphrase ⇒ `freshPassphrase` (a fresh descriptor) + twelve words minted (`mintedWords`);
   mints key, library ID, device ID, Apple key; `ActParameters(newKind: .standard, copyID:)` with `passphraseIsNew` when
   a passphrase, the new IDs and the Apple key id; ONE plan sealed under the new key, its act `.makeMine` begun in the
   new section; `drive`. No catch-and-clean: a failure before the swap leaves what a crash there leaves (P-VX309-U1b-4);
   after it the registry's `MakeMineProgram` finishes from the plan (the same step names).
4. `Operations/Operations+PlaintextExportImport.swift` (NEW; not custody — the import road): `PlaintextExportReading
   .read(exportAt:)` on `LibraryClassifier.withStagedRead` (key nil); `plan(_:)` refuses `notAnExport` without
   `grdb_migrations`/`container`, `schemaNotCurrent(newer:)` unless the applied migration set EQUALS this build's; notes
   `kind='post'`, live, NOT a version (`archived_at = created_at`), `(created_at, id)` order, each through
   `Queries.variorumDocumentText` → `VariorumDocument.parse` (`.empty` ⇒ the stub; any other parse failure ⇒
   `unreadableNote(title:line:)`), titled by `DisplayTitle.note` as fallback; books `kind IN ('book','curated')`, live,
   chapters and members `(position, id)` (members `status='member'` when the column exists, live posts only), a–z by
   `VariorumDocumentFolder.orderedBefore`; pools via `Queries.exportBlocks(includeVariants: false)` (blank scraps dropped);
   wings live by `(position, id)`. `Operations.importPlaintextExport(_:landed:)`: wings that hold content (a note, or a
   book WITH members) minted by name (`createWing`); notes `importDocument(_:wingId:)`; books archived-first then live, an
   empty one (no member note landed) named in `emptyBooks` and skipped, else `createReading(…, kind: .book, wingId:)` +
   `createSection` per chapter + per member `addPostToReading` then `assignPostToSection` when its chapter landed — a
   member op's refusal COUNTED (`membershipsLeftOut`), never thrown; `archiveReading` for an archived book; archived notes
   `archiveContainer` after every membership; pools `createPool` + `importBlocks` per scrap (+ `archiveContainer`).
   The first other refusal throws (what landed stands — the caller counts it). `landed:` reports the count even on a throw
   (`defer`). No `Sync/`, schema, migration or dependency line anywhere in this diff; `lockstepVersion` stays 13.

**THE APP LINES AS BUILT (for the ladder):** T-5 — `CopyDoorsRoads.landsInTheEmptySlot` (default false) + `makeMine` on
`AppBootstrap.copyDoorsRoadsWithoutALibrary()` → `makeThisMyLibraryInTheEmptySlot(_:copySecrets:)` (only at
`.libraryMissing` or a rule-27 `.roadLobby`; one landing at a time — `copyLandingRunning`; off the main actor:
`ProtectionCopyDoors.makeMineInTheEmptySlot` — the preflight's reads (the copy catalogued; opens by what she TYPED, a
quiet road refused; its schema current or behind), the restore hold set, `setAsideUnopenableLibraryFor` +
`setAsideLiveKeyFileFor`, the core act, `ensureStoreIdentity(fresh: true)`; a refusal before the swap puts the hold
back; past the swap `.made` with no key (the reopen finds it by its silent item)); then `beginOpening(unlockedKey:)` and
the receipt once. `MakeMineModel(intoTheEmptySlot:)` asks only the copy's secret (no current pair, no quiet probe);
`CopyDoorsSheet.MakeMineConfirm`'s T-5 arm. THE AVAILABILITY ARM (F-U1b-2) — `CopyDoorsModel.Phase.listing` +
`beginListing()`; `LibraryOpenPresenter.openRestoreList(bootstrap:)` (new road only, no doors already up);
`LibraryMissingView(restoreDoor:)` — `VariorumApp` passes it ONLY when `bootstrap.newRoad` (today's road: nil ⇒ the
Finder reveal byte for byte); `RoadLockView(restoreDoor:copiesHome:)` (the new road's face); each renders the door only
where `Backups/` or `Previous Libraries/` stands beside the store (P-2). T-8 — `PickedCopy.Verdict.plaintextExport`
(`todaysWords`' `.plaintextExport` arm; `.plaintextLibrary` keeps `plaintextCopyNotYet`); `ProtectionCopyDoors.pick` →
`PickOutcome.plaintextExport` (never filed); `CopyDoorsModel` — `.plaintextExport(URL)` phase where
`roads.bringInPlaintextExport` exists (else the old refusal), `bringIn(_:)` (made ⇒ `.done`; refused ⇒ the sentence under
the door), `bringInStepsALibraryAside`; `AppBootstrap.bringInPlaintextExport(_:)` (`.ready` with a writing session, the
missing face, rule 27's lobby; the preflight `readPlaintextExport` BEFORE any teardown; with a library open
`beginAct`, then the reopening seam's first half — `onWillLock`, `.opening`, the resident and per-open deferrals and the
custody session dropped, the pool closed off the main actor; `landPlaintextExport` — the read-only refusal FIRST, then
`setAsideLibraryWholeFor(carryingHold: true)` + `setAsideLiveKeyFileFor`, `LibraryRestoreHold.clear`, `ProtectionOpenRoad
.create(setAsideLiveKeyFile: false)`, the "it holds …" log line, the headless import under `withDependencies`
(`AppDatabase.onDisk` with the new key; database, uuid, date, RNG), the binding locked, the end's log line; nothing
created ⇒ the old key's reopen; created ⇒ the receipt queued and `finish(.roadCreated(session, words))`).
`ProtectionOpenRoad.setAsideLibraryWholeFor(_:carryingHold:)` is the old `setAsideUnopenableLibraryFor` body returning its
folder and, with `carryingHold`, moving the hold marker into it; `setAsideUnopenableLibraryFor` calls it with `false` and
logs the same line on the same condition (behaviour unchanged — `ProtectionOpenRoadPlantedTests`' rule-27 creation pins
green in the harness).

**COUNTS (the final tree — `6d24bd2f5` + this record):**
- HEADLESS HARNESS (U1a's scratchpad `u1-harness`, re-pointed at this worktree; it symlinks U1b's three new planted suites too):
  **`✔ Test run with 304 tests in 50 suites passed after 5.048 seconds.`** (U1a's 290/47 + 14/3: `EmptySlotLandingRoadTests`
  4, `PreviousLibrariesArcTests` 5, `PlaintextExportBringInRoadTests` 5; `PickedCopyRoadTests` flipped in place).
- CORE: the protection set (every `@Suite` type under `Tests/VariorumCoreTests/Protection` — 88 now, the filter re-derived
  from the files) Debug **`✔ Test run with 369 tests in 88 suites passed after 5.300 seconds.`** (U1a's 358/86 + MB-1's 1
  + 10/2: `KeyDoorOldPassphraseResumeTests` 5, `EmptySlotMakeMineTests` 5); Release (`swift test -c release`, the same
  filter) **`✔ Test run with 345 tests in 84 suites passed after 3.919 seconds.`** (334/82 + 1 + 10/2); T-8's core suite
  Release `✔ Test run with 3 tests in 1 suite passed`. THE FULL CORE SUITE, Debug (`swift test`): VariorumCoreTests
  **`✔ Test run with 3349 tests in 437 suites passed after 203.879 seconds.`** (3336/434 + 13/3); the third target `✔ 40
  tests in 6 suites`; VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — the ONE recorded VX-353 flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 19.4 s vs 15 s under the
  parallel run); ALONE `✔ Test run with 3 tests in 1 suite passed`. No MCP or Queries line in this diff.
- RED ON THE PRE-FIX TREES: piece 0 `✘ 4 tests … 15 issues` (`3180d56c7`); F-U1b-7's read-only arm `✘ … 2 issues`
  (`b923eabf6`); every other new suite is NEW API or a NEW road — red by construction. MUTATIONS (each on a committed
  tree, restored `cmp`-identical): M-0a..c, M-1a/b/d/e/f/g, M-2a, M-3a/d/e/f/g/i/j — every one red at its own pins (the
  pieces' lines above); M-1c named, not run (unobservable over an empty slot).
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
  -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (no
  warning in a line this unit wrote; the one warning in a touched file — `KeyDoors.swift:357`, `var parameters` never
  mutated — is `9217cfb84`'s, 2026-10-14, untouched); the phone `-scheme VariorumMobile -destination 'generic/platform=iOS
  Simulator' -configuration Debug … build` → **`** BUILD SUCCEEDED **`**; **the Release check `-configuration Release
  build` → `** BUILD SUCCEEDED **`**. All three on the final code tree (`6d24bd2f5`).
- Release behaviour: unchanged by construction — every door here is reached only from the new road (the copy doors'
  roads exist only there; `copyDoorsRoadsWithoutALibrary`, `bringInPlaintextExport` and `makeThisMyLibraryInTheEmptySlot`
  guard `newRoad`; `LibraryMissingView`'s `restoreDoor` is nil on today's road; `RoadLockView` is the new road's face);
  the core lines are the new road's executor's and a new import function nothing on today's road calls. The binary is not
  byte-identical (rule 24's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309 test \
  -only-testing:VariorumTests/EmptySlotMakeMineRouteTests \
  -only-testing:VariorumTests/EmptySlotDoorsSurfaceTests \
  -only-testing:VariorumTests/PlaintextExportBringInRouteTests \
  -only-testing:VariorumTests/EmptySlotLandingRoadTests \
  -only-testing:VariorumTests/PreviousLibrariesArcTests \
  -only-testing:VariorumTests/PlaintextExportBringInRoadTests \
  -only-testing:VariorumTests/PickedCopyRoadTests \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/CopyDoorsQuietProbeTests \
  -only-testing:VariorumTests/CopyDoorsPickRefreshTests \
  -only-testing:VariorumTests/LookInsideCopyDoorTests \
  -only-testing:VariorumTests/LookInsideRoadTests \
  -only-testing:VariorumTests/MakeMineRoadTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/NoKeyFileDoorTests \
  -only-testing:VariorumTests/RoadLockViewNamesPinTests \
  -only-testing:VariorumTests/RoadLockRouteTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/RoadRestoreHoldGateTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first seven are U1b's (2 + 2 + 2 + 4 + 5 + 5 + 3 = **23 tests**; the first three Mac-only — the two route suites run
`AppBootstrap` on a THROWAWAY keychain scope and a temp slot, `RoadWorld`'s, purged at the end; the surface pins read the
app's source files; the other four were headless-green). Then the suites over the files this unit touched: the doors'
brain and its pick (`CopyDoorsModel` — its phases grew; `PickedCopy`), Look inside and Make this my library on both
roads, the backup hook (`ProtectionCopyDoors`' other caller), `PlantedRoad`'s home suite (rule 27's creation calls the
refactored set-aside), rule 27's face and its no-key-file doors, `RoadLockView`'s and the missing face's hosts, the lobby
and the route, the words plans, the restore hold's gate and receipt, the presenter's host, the band (the creation's
words idiom T-8 lands on), the portability door, and the source scans over the edited files. **THE RED-ON-OLD BY
BEHAVIOURAL REVERT for the three Mac-only suites (the orchestrator's, from a committed tree, restored by `git checkout
--`):** (R-a) in `AppBootstrap.copyDoorsRoadsWithoutALibrary`, `makeMine:` back to `nil` → `EmptySlotMakeMineRouteTests
.theMissingFaceLandsACopyAsANewLibraryAndOpensReadyHeld` RED (`#require(roads.makeMine)`); (R-b) in `VariorumApp`,
`LibraryMissingView`'s `restoreDoor:` argument dropped → `EmptySlotDoorsSurfaceTests
.theFacesWithNoLibraryOpenTakeTheDoorsRestoreOnTheNewRoadOnly` RED; (R-c) in `AppBootstrap.bringInPlaintextExport`,
the `receiptsForNextRoadOpen.append(…)` line dropped → `PlaintextExportBringInRouteTests
.fromAnOpenLibraryTheExportLandsAsANewLibraryReadyNeverHeld` RED (the receipt said 0 times).

**WALK NOTES FOR THE ACCEPTANCE SPINE (the orchestrator's walk — the DEV store only, under a held claim, both voices
wherever a face renders; the log is `log show --predicate 'subsystem == "io.lduarte.Variorum" AND category == "protection"'`'s `road:` lines):**
- STAGE 9 + THE RESTORE DRILL (the walk's heart — Look inside and Make this my library, VX-306's door, unchanged here):
  with a backup pair beside the library, Data Safety's Restore from Backup rows → a row's *Look inside…* (its own words
  or its quiet road) → read-only, nothing written (the container's `ls -lR` before/after; no new keychain item) →
  *Make this my library…* (the current pair) → a NEW library, held (the banner — never press Resume), the old one whole in
  `Previous Libraries/<stamp>/`. PIECE 2's arc on top: the old library LISTED as *Previous library* dated today (rule
  19), *Look inside…* opening it by its own quiet road, nothing written.
- STAGE 9's EMPTY-SLOT ARM (T-5 — new): quit; MOVE (never delete) the slot's `Variorum.sqlite` and its sidecars into a
  scratch folder outside the container; relaunch → the missing face → *Restore from a Backup…* opens the doors' LISTING
  (lead "These are the copies of a library on this Mac. …") → a backup row → *Make this my library…* → T-5's confirm
  asks only the copy's secret (its twelve words — the dev library's own, `~/.variorum/dev-castle.env`, sourced, never
  written down) → lands: the log's `road: a copy landed in the empty slot — library <8> key <fp8>; nothing stepped
  aside; held`, the missing library's key file in `Previous Libraries/<stamp>/`, the hold banner, the receipt "This copy
  is your library now." once. A wrong word refuses with nothing moved. With the copy's PASSPHRASE instead, the card above
  the quick entry offers fresh words at the first look (the passphrase stays the dev file's; the WORDS change — update
  `dev-castle.env` in the same window if that arm runs). POSTURE AFTER: the typed-words arm keeps the dev file's values
  valid (a new library ID under the same words; Standard) — the moved-aside original file goes back to the trash only
  at the walker's call.
- STAGE 10 (someone's library): pick a THROWAWAY library's pair through *Open Library…* → filed → *Look inside…* with ITS
  secrets → *Make this my library…* (the standing act — the current posture, the current pair; "you never leave Castle
  by opening something"). Unchanged by this unit except the listing's availability with no library open.
- STAGE 13 (a crash): PINS ONLY — not walkable by timing; `EmptySlotMakeMineTests`' crash loop (every write of T-5, the
  slot empty or the new library, never a third state) and `KeyDoorOldPassphraseResumeTests` (F-U1a-1's three shapes roll
  back) carry it.
- STAGE 14 (wrong on disk — rule 27's face): from rule 27's face (VX-306 U2's walk recipe), *Restore from Backup…* is now
  the doors' listing (where `Backups/` or `Previous Libraries/` stands) — its row's *Make this my library…* lands T-5
  with the unopenable library moved WHOLE into `Previous Libraries/` first, still opening under its own key there.
- T-8 (a plaintext export in): the export to pick — Data Safety's *Export an unencrypted copy of your library.* where it
  renders on the new road (`DataSafetyPane.plaintextExportSection` needs today's `ProtectionController`; the executor's
  own `plaintextExport` act has no app door — if the section does not render, a throwaway export made headless as
  `ExportPlant.export` makes the pins'), saved OUTSIDE the container → *Open Library…* picks the `.sqlite` → the doors
  NAME it (lead "Bring this plain-text copy in as a new library? …", with a library open "Your current library steps aside
  whole into Previous Libraries.") → *Bring it in* → the log's `road: bringing in a plaintext export — it holds …` then
  `road: a plaintext export brought in as a new library — …` → a new library opens Standard, NOT held (no banner), the
  receipt "A new library holds the plain-text copy's writing: N books · M notes · K snippet groups." (the quiet receipt
  line), the band's card offering fresh words. CHECK against the source library: every book a–z with its chapters and its
  member order; a note in two books membered in both; archived books under Archived, archived notes archived; versions
  absent; snippet groups with their scraps; a non-Home wing minted by name with its own tags; an empty book named in the
  receipt; book settings, stars, shelves, commits and comments NOT there (the lead says so). The old library whole in
  `Previous Libraries/<stamp>/` WITH its hold marker. POSTURE AFTER — T-8 CHANGES THE DEV LIBRARY'S IDENTITY AND ITS
  WORDS (the creation's, dropped unseen): run it LAST; the walker restores the dev store before releasing the claim (the
  walk-restores-posture rule) — UNVERIFIED road, the walker's call: quit, move `Previous Libraries/<stamp>/`'s library,
  sidecars and key file back into the slot and live place (the new library's into a scratch folder), relaunch → the
  original opens by its own silent item with stage 14's "a different library" notice once — or update `dev-castle.env`
  to the new library's words in the same window.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX309-U1b-0 — F-U1a-1's arm** (the U1a arbitration's ruled shape): (a) BUILT — at a resume of Change or Reset, a
  typed passphrase that opens only the lock being replaced is dropped, so the act rolls back before any write; (b) the
  lobby asks for the passphrase chosen at the press while a Change is in flight (a face); (c) accept, and say it as rolled
  back in Diagnostics.
- **P-VX309-U1b-1 — at T-5 what stands in the slot steps aside whole first** (rule 27's library no key file opens; a
  missing library's key file still in the live place): (a) BUILT — exactly the faces' *Start a New Library* pre-steps,
  never written over; (b) refuse T-5 while anything stands (Start a New Library first); (c) the core act's own
  step-aside half run over what stands.
- **P-VX309-U1b-2 — T-5's posture is STANDARD** (an empty slot has no posture "now"): (a) BUILT — Castle is entered
  deliberately after; (b) the copy's own posture (a Castle copy lands in Castle — both its secrets typed); (c) ask at
  the door.
- **P-VX309-U1b-3 — every new sentence** (T-5's lead and receipt; the listing's lead and empty line; T-8's lead,
  button, working line, the two refusals, the receipt): (a) BUILT as drafted in `ProtectionWords`; U2's words pass
  rewrites against her words.
- **P-VX309-U1b-4 — T-5's pre-swap debris:** a landing that refuses or crashes before the swap leaves its own writes (the
  plan, the staged file, the new key's silent item, Apple key and memory item — each naming a library that never landed;
  what stepped aside stays aside): (a) BUILT — a refusal leaves exactly what a crash there leaves (the hold put back);
  (b) a refusal cleans its own writes (a refusal and a crash then differ); (c) the next open's repairs sweep them.
- **P-VX309-U1b-5 — the availability arm (F-U1b-2):** on the new road the missing face's and rule 27's *Restore from
  Backup…* open the doors' listing (rule 17: "The app's Restore from Backup is this door"): (a) BUILT; (b) keep the
  Finder reveal and add a separate *Copies on this Mac…* door; (c) the listing only when a Previous Library exists.
- **P-VX309-U1b-6 — T-8's wings:** (a) BUILT — the ruling's arm (b): each export wing holding content minted by name, its
  notes and books landing in it, tags adopting per wing (the import ops' own `wingId` parameters ARE the seam); (b) the
  ruling's fallback — everything into Home, the flattening said in the confirm.
- **P-VX309-U1b-7 — T-8 reads only THIS build's export:** (a) BUILT — an earlier or a later build's export refuses with
  words, nothing written; (b) migrate a staged copy first (needs 13x's reconciliation step — the export's outbox triggers
  name the dropped local-only tables); (c) a version-tolerant projection reading older schemas as they are.
- **P-VX309-U1b-8 — T-8's crash window** (ruled PROVISIONAL): a crash between the creation and the import's end leaves a
  new library holding part of the export (the export untouched, re-importable); (a) BUILT — the log says what the export
  holds before the import and what landed at its end, the receipt names what landed and says when it stopped part of the
  way; (b) import into a staged store and swap it in only when whole; (c) a resumable import plan.
- **P-VX309-U1b-9 — T-8 clears any restore hold still standing** (an open library's goes aside WITH it; a missing
  library's stray marker is removed): (a) BUILT — the ruling's "no hold"; (b) leave a missing library's stray marker (the
  new library would open held).
- **P-VX309-U1b-10 — a plain-text FULL library** (a store from before 13p's encryption) keeps its pick refusal: (a) BUILT
  — rule 26 (a copy from before this design is not handled); (b) bring it in as T-8 does an export (it would meet the same
  schema gate).

**FINDINGS AND HAND-FORWARDS (routed, not fixed here unless said):**
- **F-U1b-1 (Castle & sync — a RULE question, Confirmed by probe; the orchestrator's to arbitrate, likely her call):**
  VX-305 U4's deferral (1) at its heart. A library (B) made from library A's backup while A stepped aside: when B ENTERS
  CASTLE, rule 11 deletes B's own Apple and on-device items — A's (a Previous Library on this Mac, holding her older
  writing) survive, and A opens QUIETLY through Look inside. A TRANSIENT probe (written, run, removed in one command —
  never committed): `aSilentItemSurvives=true aAppleKeySurvives=true aPreviousLibraryQuietLook=opened`. Rule 17 makes A
  another library (its quiet roads its own); rule 25's exceptions name two older locks, not a previous library's roads.
  Options: (a) as today — a previous library is another library; its quiet roads go when she deletes it (rule 19);
  (b) entering Castle also sweeps every Previous Library's quiet roads on this Mac (they hold her writing; they then open
  only by their own typed secrets); (c) the Castle confirm says it (a rule-25-style line).
- **F-U1b-2 (the availability gap — FIXED in piece 2, P-VX309-U1b-5):** with no library open nothing listed this Mac's
  copies; the faces' Restore from Backup now open the listing.
- **F-U1b-3 (Tests & tooling, Low — a ticket at closeout):** the scenario world's generator still skips moves that reopen a
  Previous Library (no road existed); T-5 and the arc now give it one — the skip can be lifted and the generator taught
  the empty-slot landing.
- **F-U1b-4 (Debt, Low — the ruling's routed finding):** `Executor/Acts/Copies.swift` line 16's header — "A PLAINTEXT EXPORT
  carries its library ID." — is stale: `StorePlaintextExport` drops the local-only family, `protection_record` with it, so
  the export carries no library ID. A comment fix (the ladder's or a ticket).
- **F-U1b-5 (VX-444 hand-forward — U1c's rider):** T-5 with the copy's own TYPED WORDS lands a library whose words she
  just typed — the words-recorded ledger (`variorum.calmAsks.words.<libraryID>.*`) should count them recorded for the new
  library's id, or the card re-offers words she knows (VX-444's class exactly). With the copy's passphrase (fresh words,
  dropped unseen) and at T-8 (the creation's words), the card offering fresh words is right as it stands.
- **F-U1b-6 (MOBILE PARITY):** nothing mobile-visible — the phone has no copy doors, no missing face and no T-8; the shared
  files compile for iOS (the phone build green).
- **F-U1b-7 (Bug, Castle & sync / data safety — the READ-ONLY ARM FIXED here, the WRITING-ROAD ARM routed):** T-8 sets
  what stands in the slot aside BEFORE the creation. Fixed: on a read-only road the creation refuses, so the function now
  refuses first (pin above). Routed (Suspected — traced, not probed: the planted leaves carry no write-failure seam): on a
  WRITING road a creation that refuses after the step-aside (a keychain or key-file write failing) leaves the slot EMPTY
  with the library that was open whole in `Previous Libraries/`; the bootstrap's reopen with the old key then lands on the
  missing face, whose Restore list shows it — but returning it there is Make this my library, a NEW library (rule 17), not
  the same one (a synced library would lose its account linkage that way). A crash in that window leaves the same shape.
  Options: (a) as built; (b) a refused creation puts the set-aside folder back (the library, its sidecars, its key file,
  its hold) before returning; (c) the step-aside and the creation as one planned executor act (rule 20 for the crash too).
- **F-U1b-8 (Castle & sync — a reading against rule 17, for the orchestrator):** T-8 from an open CASTLE library lands the
  ruled road's STANDARD library (the creation) with the Castle library aside — while rule 17's last sentence reads "You
  never leave Castle by opening something" (and stage 10: "you never leave Castle by opening something"). The lead says
  "a new library in Standard" plainly. Options: (a) as ruled, the confirm naming it (U2's words); (b) T-8 refuses while
  the open library is in Castle; (c) the new library lands in the current posture (Castle — the current pair typed at the
  door, as Make this my library asks it).
- **F-U1b-9 (Tests & tooling — record only):** the full core suite's one wall-clock red under the parallel run (VX-353's
  MCP bound), green alone — an existing class, no line of this diff.

**U1b ARBITRATION (the orchestrator, 2026-10-19 — repo-first before the Mac batch and U1c):**
- **F-U1b-1** (Castle entry leaves a Previous Library's quiet roads standing — her older writing still opens quietly
  through Look inside): **HER BUNDLE, a HEADLINE item** — any arm is a CastleRules amendment (rule 9's promise vs rule
  17's "another library"), author-only. Recorded with the probe's facts; option (b) (the entry also sweeps Previous
  Libraries' quiet roads on this Mac — the library-ID stamps make it precise) is the spirit-of-rule-9 arm, (a) is the
  letter-of-rule-17 arm, (c) the honest-line arm; NO BUILD this phase without her word. A ticket at closeout carries
  it (Improvement, Confirmed, Castle & sync, Needs Lillian).
- **F-U1b-7's writing-road arm** (a creation refusing after T-8's step-aside leaves the slot empty, the old library
  whole in Previous Libraries): a TICKET at closeout (Bug, Suspected, Castle & sync, Medium) naming option (b) (a
  refused creation puts the set-aside back) as the likely fix — no pin can go red today (the planted leaves carry no
  write-failure seam), so building it would break the hallucination guard; the read-only arm is FIXED and pinned here.
- **F-U1b-8** (T-8 from an open Castle library lands a Standard library — read against rule 17's last sentence):
  **HER BUNDLE, a HEADLINE item** beside F-U1b-1 — stands as ruled meanwhile ((a): the lead says "a new library in
  Standard" plainly); (b) refuse-in-Castle and (c) land-in-Castle-with-the-pair-typed recorded as her options.
- **F-U1b-3** → a ticket (Debt, Test-only, Tests & tooling, Low). **F-U1b-4** → the ladder's NIT or the closeout's
  comment fix. **F-U1b-5** → FOLDED into U1c's brief (the VX-444 rider: T-5 with typed words counts them recorded for
  the new library's id). **F-U1b-9** → record only.
- **P-VX309-U1b-0..10: each stands as built** pending her bundle. Two flagged beside their rows: U1b-4 (pre-swap
  keychain debris for a library that never landed accumulates across failed presses — the ladder may weigh a sweep
  arm) and U1b-2 (T-5's Standard posture sits beside F-U1b-8's posture question — one bundle row should carry both).
- **The walk:** ONE phase walk at the end (after U1c and U2), the VX-308 shape; U1b's walk notes fold into it — and
  T-8's row runs THE COORDINATOR'S WAY (its 20:38 MDT heads-up, adopted): on a THROWAWAY library seated in the dev
  slot, with A set aside whole first (cmp-verified, the hold marker with it) and restored whole afterwards — A's
  identity and words NEVER change, `dev-castle.env` stays true, term 4 untouched. The implementer's
  restore-from-Previous-Libraries road is superseded for the walk.

**THE U1b MAC BATCH (the orchestrator, 2026-10-19 20:38–21:05 MDT, stage claim `vx-309-u1b-mac`, the coordinator's
GO; logs `/tmp/vx309-u1b-mac-*.log`, deleted at closeout):** 165 tests / 34 suites, ONE real red — a FIXTURE lie the
first Mac run exposed, plus one honest log line:

- **MB-2 (a test-world fix, the orchestrator's — commit above):** `EmptySlotMakeMineRouteTests
  .theMissingFaceLandsACopyAsANewLibraryAndOpensReadyHeld` red with `.refused(.unreadableCopy)` — the fixture took
  rule 5's pair STRAIGHT AFTER `world.created()`, before any open ran the migrator, so the snapshot held a store with
  no `grdb_migrations` table and the empty-slot preflight's schema read refused it. NO PRODUCTION PAIR CAN PRECEDE
  MIGRATION (the `.ready` arm migrates before any backup run, VX-447's door and every act's `freshBackup` run on an
  open library), so the preflight's refusal is CORRECT and the fixture was the lie: it now migrates the store once
  (`AppDatabase.onDisk`) before the pair, as every real open does. The suite's passing twin (`MakeMineRouteTests`)
  takes its pair at `.ready`, which is why it never saw this. The headless twin (`EmptySlotLandingRoadTests`, planted
  leaves) was structurally blind to it — the real `LibraryClassifier` runs only under the Mac host. ALSO KEPT: the
  preflight's unreadable arm now LOGS its verdict (`road: … the copy's schema could not be read (…)`) instead of
  swallowing it — the diagnosis took one log line that should always have been there. Re-run: the suite `✔ 2/1`;
  the harness after both edits `✔ Test run with 304 tests in 50 suites passed`.
- Every other suite green on the first run; the known `VariorumTests` warnings-not-failures only.
- **THE R-a / R-b / R-c BEHAVIOURAL REVERTS (the record's recipes, each from a committed tree):** R-a (`makeMine:`
  nil at `copyDoorsRoadsWithoutALibrary`) → `EmptySlotMakeMineRouteTests` RED (both tests — the `#require` and the
  wrong-word road gone); R-b (`VariorumApp`'s `restoreDoor:` dropped) → `EmptySlotDoorsSurfaceTests` RED at its
  needle; R-c (the `bringInReceipt` append dropped) → `PlaintextExportBringInRouteTests` RED at the receipt count.
  Each restored `cmp`-identical, `git status` clean. The confirming re-run (the three Mac-only suites) `✔ Test run
  with 6 tests in 3 suites passed`; 0 instances; the stage released with the coordinator's result line.
  **THE U1b MAC LEG IS CLOSED.**

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree. The harness is U1a's (this session's
scratchpad `u1-harness`), its test target given the author's GRDB fork as a direct dependency (resolved offline from the
existing pin and checkout; `Package.swift.u1a` keeps the pre-edit manifest) — scratch only, no repo change. One TRANSIENT
probe (F-U1b-1) was created, run and removed in one command, never committed. One scripted CODE edit (Python) ate a
closing quote in `ProtectionWords.swift` — caught by the build before its commit and fixed by hand. Every pin set committed before its fix (`3180d56c7`, `b923eabf6`) or red by construction (new API, new
roads); every mutation named in the record before it ran. Commits: `17920a573` (record) · `2d247bacf` (the orchestrator's
ruling) · `3180d56c7` (0 pins first) · `22856d3dd` (0) · `41a380500` (record) · `ee7510b66` (record) · `59e04579e` (1 core) ·
`216fda519` (record) · `f18824efc` (1 app) · `68253bdc2` (record) · `53674fe03` (2) · `f28e44da4` (record) · `1e9f4abb2` (3
core) · `10d9bb6d5` (3 app) · `74f3f4132` (record) · `9c7785a34` (3 log line) · `b923eabf6` (F-U1b-7 pin first) ·
`6d24bd2f5` (F-U1b-7 read-only arm) · the close commit.

### U1c RECORD — THE LISTING'S FACES AND THE RIDERS (Opus implementer, 2026-10-19; VX-265 · VX-210 · VX-444 (+F-U1b-5) · VX-451 · VX-454 — BUILT; the Mac suite and the walk PENDING)

**Not done in U1c, first:**
- NO MAC SUITE RUN, NO WALK, no stage, no Debug launch, no store touch, no network, no Linear, no subagent (the brief). FIVE
  new suites are Mac-only (they drive `AppBootstrap`, or read the Mac target's sources) and were BUILT, never run —
  `OtherLibrariesDeleteRouteTests` (2), `CopyListingFacesSurfaceTests` (2), `WordsLedgerCarryRouteTests` (2),
  `RoadIdleDialRouteTests` (2), `SetPassphraseRowRereadRouteTests` (1): the orchestrator's, under the stage (the list and the
  red-on-old recipes below). Every other new pin ran HEADLESS, red-on-old verified or red by construction, and every guard
  mutation-checked.
- TWO CORE CUSTODY LINES were written that the brief did not name (the Fable ladder reads them — THE CORE LINES below): the
  VX-265 act's own fence was WRONG (F-U1c-1 — `offerDelete` could never delete another library's backups; fixed and pinned
  red-on-old), and the no-library delete the brief asks for ("the empty-slot listing … carries it") had no core road
  (`offerDeleteWithNoLibraryOpen`, new). Zero `Sync/`, `Server/`, schema, migration or dependency lines; `SyncSchema
  .lockstepVersion` 13.
- EVERY NEW SENTENCE IS UNDRAFTED against her words (P-VX309-U1c-1 — U2's pass): the delete door, its confirm's title, lead,
  button, working line, receipt and failure; VX-210's line. VX-451's dial and Lock Now reuse TODAY's `ProtectionCopy` words
  (no new sentence there).
- Lock Library Now's ⌃⌘L is NOT in the registry declaration (P-VX309-U1c-4): declaring it would put a ⌘/ helper row in
  Release, and today's road stays byte-unchanged. Release changes nothing visible: the File menu's item reads the same words
  from the declaration.
- ROUTED, NOT BUILT: F-U1c-3 (a delete whose file removal fails mid-step leaves the open library's `offerDelete` act in flight —
  traced, no failure seam to pin); F-U1c-4 (another library's quiet roads outlive the delete of its copies — F-U1b-1's
  territory, her call).
- No canon line, no QUESTIONS row, no ticket — the merging session's (the PROVISIONALs and findings below carry them).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE (rules 17–19, 21, 23, 25, 27 + the considered-and-not-pursued ledger); `notes/SyncSpec.md`
WHOLE (no `Sync/` line here); `notes/SurfaceContracts.md` whole (The app · Doors — portability + Library protection); this
plan WHOLE (§0–§3, §5a–§5c, §5b-R, the §6 U1a and U1b RECORDS with their ARBITRATIONS and MAC BATCHES — MB-1's
`Retention.plan(now:)`, MB-2's migrated fixture and the said-not-swallowed verdict line, F-U1b-5); `notes/plans/vx-308-
accounts-key-doors.md` §6 U4 RECORD (F-U4-1, the export-mark-by-library pattern, `changeSettings`' road) + the U3 RECORD
(the pane's sections, the one presenter) + THE WALK RECORD (W-VX308-2); the VX-307 plan's F-U2b-3 + its arbitration
(VX-444's origin); the vx-266 design's §3.7 (the offer's other-libraries group — superseded where the rules differ); the
core — `Executor/Acts/Copies.swift` (`offerDelete`), `Executor/Acts/DeviceActs.swift` (`changeSettings`),
`Model/DeviceSection.swift` (`DeviceSettings.idleLockMinutes`), `Assess/Catalog.swift` (`foreign`, `MacAttribution
.unattributed`), `Assess/CatalogNames.swift`, `Assess/OwnCopies.swift`, `Executor/PlanRunner.swift` (`perform`, the
`needsLiveKeyFile` defaults), `Executor/Leaves.swift`; the app — `CopyDoorsModel.swift` WHOLE, `ProtectionCopyDoors.swift`,
`CopyDoorsSheet.swift`, `LibraryOpenDoor.swift` (the presenter), `DataSafetyPane.swift`, `SettingsSceneContent.swift`,
`ProtectionPane.swift` (the sections' order; today's Castle section), `RoadCrossingsModel`/`RoadCrossingFaces` +
`RoadCrossingSheet.swift` (the gate row's home), `ProtectionCrossingActs.swift` (`changeGate`), `ProtectionRoadLock.swift`
(`RoadRelockPolicy`), `AppBootstrap.swift` (`canLock`/`lock`, `copyDoorsRoads*`, `makeThisMyLibrary*`, `accountRoads`,
`keyDoorRoads`, `finish`), `WordsBand.swift` (the ledger), `ProtectionOpenFaces.swift` (`RoadStandingModel`,
`refreshPane`), `SetPassphraseModel.swift` + `PassphraseReminder.swift`, `RoadAccountModel.swift` (the landing chain),
`FileBackupsLeaf.swift`, `ProtectionRoadActs.swift` (the set-aside helpers), `CatalogLister.swift`, `ProtectionWords.swift`,
`EditorCommands.swift` (Lock Library Now, `menuRendered`, `keyEquivalent`), `Registry/Capability*.swift`, `HelperView.swift`;
the test worlds — `PlantedRoad`, `ProtectionFacesSupport`, `ProtectionAccountSupport`, `RoadLockTests`, `RoadLockRouteTests`,
`RoadKeyDoorSurfaceTests`, `WordsBandTests`, `CopyDoorsModelTests`, `MakeMineRoadTests`, `ProtectionAccountRouteTests`,
`CapabilityRegistryTests`, core `CopyActTests`. HARNESS: U1a's scratchpad package `u1-harness` (this session's scratchpad —
it survived, re-pointed at this worktree, `--skip-update`): the BASELINE on `ae5aca849` `✔ Test run with 304 tests in 50
suites passed after 4.986 seconds.` (U1b's close count, exactly).

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U1c-1 — RULE 19'S "THIS MAC'S" IS TOLD BY PLACE, AND THE CORE'S FENCE TOLD IT WRONG (a traced bug in VX-265's own act).**
  `offerDelete` fenced every copy with `copy.mac.isMac(library.section.mac8)` — the OPEN library's device ID. But a library's
  device ID is its own on each Mac (rule 23): Make this my library mints a fresh one (`parameters.newDeviceID`), so the
  library that stepped aside filed its backups under ITS `<mac8>` (`writeContainerPair(… deviceID: session.library.section
  .deviceID)`), and the fence never matched them — only `.thisMacsContainer` copies (its Previous Library) would ever go, its
  backups listed forever. The door cannot meet "counting what goes (this Mac's copies of IT)" over that fence, so the fence is
  fixed inside this unit (the same act, VX-265's own): every copy in this Mac's CONTAINER is this Mac's (per Mac and per
  login — `MacAttribution.thisMacsContainer`'s own reason); a FAR copy is this Mac's only under the `Backups/<library8>/
  <mac8>` subfolder this Mac's container files the same library under (the pair road copies the container pair there under
  that subfolder — R-U1a-1); another Mac's, an unattributed far copy and a copy no key file names are never claimed. One pure
  core rule (`OwnCopies.isThisMacsCopy` / `thisMacsCopies`) the act and the listing both read.
- **R-U1c-2 — ONE LIBRARY AT A TIME, ON EACH OF ITS ROWS.** The brief's "each such row gains *Delete…*": every other-library
  row whose library this Mac holds a copy of carries the door (P-2 — none where nothing would go); the press opens the
  library's own confirm (never part of another act's): the library named by its newest listed copy's day, what goes counted by
  kind (this Mac's copies — the act's fence read for the confirm), what stays said (another Mac's copies, an unattributed far
  copy), and — with a library open — that the library isn't touched. The act re-reads at the press (a fresh catalogue — what
  goes is what this Mac holds NOW) and the receipt names how many went. The open library's copies are never offered
  (retention's).
- **R-U1c-3 — WITH NO LIBRARY OPEN, THE REMEMBERED LIBRARY IS NEVER OFFERED.** At the empty-slot listing (the missing face,
  rule 27's lobby) every copy is "another library's" to the listing, including the library the slot is missing — whose copies
  are exactly what T-5 lands from. "Deleting never touches a copy of the OPEN library" has its twin there: a library this Mac
  REMEMBERS (rule 21) is never offered and the core act refuses it; a memory read that fails offers no delete at all
  (PROVISIONAL P-VX309-U1c-2). The no-library act is plan-less (no library holds it; deleting copies changes no key).
- **R-U1c-4 — AN ASIDE COPY IS ITS FOLDER.** A Previous Library stepped aside "whole, with its own key file" (rule 17); the
  leaf deleted only its `variorum.sqlite` and sidecars, leaving the key file (and T-8's carried hold marker) and the folder.
  Deleting it now takes the folder: the library, its sidecars, its key file(s), the hold — and never a file of hers (the folder
  then stays, holding only it). Backup pairs and retention's prune are unchanged.
- **R-U1c-5 — VX-210'S LINE IS ONE LINE OVER CATALOGUE FACTS.** The count behind it: a library-shaped (`.sqlite`) FOREIGN entry
  (today's flat backups beside the library and in the picked folder, the A1 rail's copies, a folder she made), a catalogued copy
  no format-3 key file names (rule 26 — never listed), a far copy outside any Mac's subfolder (`unattributed`); the line renders
  in both listings only when that count is above zero (P-2). Worded so it is true of all three ("left as they are … yours to
  manage in the Finder" — never "not listed", which an unattributed far copy is) — a draft for U2's pass (P-VX309-U1c-1).
- **R-U1c-6 — VX-444: THE MARKS RIDE THE PAIR; F-U1b-5: TYPED WORDS ARE RECORDED; A MINT IS NOT.** The ledger is per library
  ID and Make this my library mints a fresh one under the CURRENT pair, so the brief's "(i) inherits" carries the outgoing
  library's `recorded` AND `dismissed` (the ✕ declined the same pair's offer). The write lands where the new id is first known
  — `ProtectionCopyDoors.makeMine`, beside the act's landing — through the band's own ledger (the bootstrap's
  `reminderLedger.defaults`). T-5 with the copy's typed words marks RECORDED (she just typed the words that lock it); with its
  passphrase the words are minted and dropped unseen (rule 2 — the first look mints), so nothing is marked; T-8 likewise. The
  alternative read — "she typed her current words at the standing act's confirm, so mark recorded whatever the outgoing
  library had" — is P-VX309-U1c-3's option (b), not built (the brief says inherits).
- **R-U1c-7 — VX-451: THE CASTLE SECTION GROWS THE DIAL AND LOCK NOW; ONE DECLARATION, NO NEW RELEASE LINE.** "Where
  `RoadRelockPolicy` stands" = Castle, which is exactly where the crossings' gate-style row stands (`RoadCrossingFaces.gateRow` is
  Castle-only from the same record mode) — so both join that section (P-2 by construction). The dial writes THIS MAC'S sealed
  setting through `changeSettings` (the design's §3.2/§3.15 law — never UserDefaults); the monitors already read
  `RoadRelockPolicy.of(session.library)` per tick, so the value counts at once. Lock Now is the bootstrap's `lock()` (VX-445).
  "One capability, the registry's declaration carries both doors": `.lockLibraryNow` declared with the menu's and the pane's
  doors and today's one verb constant. Its chord is NOT the declaration's `shortcutLabel`: the discoverability guard
  (`everyDeclaredShortcutIsFindableInTheHelper`) would then demand a ⌘/ helper row, which RELEASE renders — and the hard limit is
  today's road byte-unchanged (P-VX309-U1c-4 carries the arm that declares it).
- **R-U1c-8 — VX-454: THE PROBE'S SHAPE, AND WHY THE LANDING CHAIN MISSED IT.** `offersSetPassphrase` is a STORED flag re-read
  only when a set-passphrase sheet closes or VX-447's mint lands; the faces are made per open, and turning sync on (setUpSync
  — a first device's hand-up with a NEW passphrase) and a same-posture join run on the OPEN session with no reopen to make
  fresh faces. The account section's `landed` re-read the crossings only; the pane's appearance (`refreshPane`) re-read the
  three sections' faces but never the row — which is why W-VX308-2 saw Change/Reset (the key doors re-read at the pane's
  next appearance) with "Set a passphrase…" still above them. The probe drives exactly that: turn on sync on the planted
  road, then the appearance. Rule 3's reminder on the card has the same stored state (`showing`) and the same miss; it
  retires in the same re-read ("Never shown once a passphrase exists") — one act's two faces, not a second unit.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton + the harness baseline: DONE (`441d4a1b9`).
- Piece 1 — VX-265 (the delete door for other libraries' copies): BUILT (`6ce2ebafd` core pin first · `8d4e028fb` core ·
  `fe90ec572` leaf pin first · `b1c25a7f8` leaf · `645ce1784` the app). CORE (R-U1c-1, R-U1c-3): the pin
  `OtherLibrarysCopiesDeleteTests.anotherLibrarysCopiesThisMacMadeGoWhateverMac8TheyCarry` RED ON THE PRE-FIX TREE `✘ Test
  run with 1 test in 1 suite failed … with 2 issues` (X's backup beside the library and in the picked folder never went) →
  with `OwnCopies.isThisMacsCopy` / `thisMacsCopies` + `offerDelete`'s fence reading it + NEW `offerDeleteWithNoLibraryOpen`
  green; the suite 3 tests (+ the pure rule, + the no-library road); `CopyActTests.theOfferDeletesOnlyThisMacsCopiesOfAnother
  Library` FLIPPED DELIBERATELY (its "another Mac's" copy now planted in the shared far folder — a container copy is this Mac's
  by place); the core protection set Debug `✔ Test run with 372 tests in 89 suites passed`. MUTATIONS on `8d4e028fb`
  (restored `cmp`-identical to `u1c-prerevert/`): M-1a the pre-fix fence = the pre-fix tree's red above; M-1b the far arm
  claiming any `<mac8>` → `✘ … 4 issues` (another Mac's copy deleted; the pure rule's two arms); M-1c the remembered exclusion
  dropped → `✘ … 4 issues`. LEAF (R-U1c-4): `ProtectionFileLeavesTests.deletingAnAsideCopyTakesItsFolderWholeAndNeverAFileOfHers`
  RED ON THE PRE-FIX TREE `✘ … 4 issues` → green with `FileBackupsLeaf.isAsideFolder` + `removeAsideFolder`; MUTATIONS on
  `b1c25a7f8`: M-1e the aside files kept → `✘ … 4 issues`; M-1f every file in the folder deleted → `✘` (her folder gone). APP
  (R-U1c-2): `CopyDeleteChoice` + `CopyDoorsListing.deleteChoices` / `deleteChoice(for:)` (`make` gains `protected:`);
  `CopyDeleteOutcome`; `CopyDoorRefusal.deleteFailed`; `CopyDoorsRoads.deleteCopies`; `CopyDeleteModel` (the confirm's brain);
  `CopyDoorsModel.Phase.deleteCopies` + `openDeleteCopies` (from the listing: back to it, re-read, the receipt above; from a row
  elsewhere: done) + `listingReceipt`; `ProtectionCopyDoors.protectedFromDelete` + `deleteCopies(session, libraryID:)` (the
  core's planned act on the OPEN session, one act at a time) + `deleteCopies(ctx, libraryID:)` (the no-library road);
  `AppBootstrap.copyDoorsRoads` (the receipt on the status seam) and `copyDoorsRoadsWithoutALibrary` (`deleteCopiesWithNoLibrary
  Open` — never at ready, one beside the landings); the Mac faces — `CopyDoorsSheet` (the listing rows' *Delete…*,
  `DeleteCopiesConfirm`), `RoadRestoreRows` (Data Safety's rows), `RoadDoorsHost.deleteCopies`, `LibraryOpenPresenter
  .beginDeleteCopies`, `SettingsSceneContent` + `DataSafetyPane` wiring; the words (`ProtectionWords` U1c section — PROVISIONAL
  P-VX309-U1c-1). Pins: `OtherLibrariesDeleteRoadTests` (4, planted, headless — the open-library road end to end, the
  empty-slot road with the remembered library never offered, the confirm's brain, VX-210's count) `✔ 4 tests`; the harness
  `✔ Test run with 309 tests in 51 suites passed`; Mac only, BUILT (the run the orchestrator's): `OtherLibrariesDeleteRouteTests`
  (2 — through `AppBootstrap` over the planted road) and `CopyListingFacesSurfaceTests` (2, by source); `build-for-testing` `**
  TEST BUILD SUCCEEDED **`, no warning in a touched file. App MUTATIONS on `645ce1784` (each restored `cmp`-identical to
  `u1c-prerevert/CopyDoorsModel.swift`): M-1g no choices computed → `✘ … 2 issues` (both roads' `deleteChoices[A]`); M-1h the
  protected set ignored → `✘ withNoLibraryOpenARememberedLibraryIsNeverOffered…` (1 — the remembered library offered).
- Piece 2 — VX-210 (the honest line): BUILT with piece 1's app commit (they share the listing): `CopyDoorsListing
  .unmanagedCopies(in:)` (R-U1c-5), `ProtectionWords.copiesElsewhereLine` (PROVISIONAL P-VX309-U1c-1), the line in the
  empty-slot sheet's listing and Data Safety's Restore list (`RoadRestoreRows`), each only above zero. Pins:
  `OtherLibrariesDeleteRoadTests.theLineCountsTheCopiesVariorumLeavesAsTheyAre` (headless) +
  `CopyListingFacesSurfaceTests.bothListingsSayTheOneLineOnlyWhenItIsTrue` (Mac, by source). MUTATION M-2a (the foreign arm
  off) → `✘ theLineCountsTheCopiesVariorumLeavesAsTheyAre` (2 issues), restored `cmp`-identical.
- Piece 3 — VX-444 + F-U1b-5 (the words-recorded ledger carries): BUILT (`c9fd33d92`). R-U1c-6. `WordsCardLedger
  .carry(from:to:)` (only a mark that stands is carried; the outgoing library keeps its own); `ProtectionCopyDoors.makeMine(…,
  wordsLedger:)` carries the outgoing library's `recorded`/`dismissed` onto the new id once the copy IS the library (the swap
  landed — including "swapped, then stopped": the record read after the act); `makeMineInTheEmptySlot(…, wordsLedger:)` marks
  the new id RECORDED when the copy's own typed words became its words lock (`LandedCopy.mintedWords == nil`); a passphrase
  landing and T-8 mark nothing (T-8's road takes no ledger); `AppBootstrap.makeThisMyLibrary` / `…InTheEmptySlot` pass the
  band's own ledger (`WordsCardLedger(defaults: reminderLedger.defaults)` — the one `RoadStandingModel.make` reads). Pins:
  `WordsLedgerCarryRoadTests` (5 — the carry with and without a mark (2 cases), the ✕'s mark, T-5 by typed words, T-5 by its
  passphrase, T-8's guard) headless `✔ 5 tests`; Mac only, BUILT: `WordsLedgerCarryRouteTests` (2 — through `AppBootstrap`,
  the band's `offersWords` after the standing act and after T-5 — RED ON OLD in the true sense: they compile on the pre-unit
  tree and read only its faces). `build-for-testing` green, no warning in a touched file. MUTATIONS on `c9fd33d92` (each
  restored `cmp`-identical to `u1c-prerevert/ProtectionCopyDoors.swift`): M-3a no carry → `✘ makeThisMyLibraryCarries…`
  (recorded → true: 2 issues); M-3b every T-5 landing marked recorded → `✘ theEmptySlotLandingByItsPassphrase…` (2); M-3c
  typed words never recorded → `✘ theEmptySlotLandingByTypedWords…` (2).
- Piece 4 — VX-451 (the pane's Lock Now row + idle dial): BUILT (`61afe294e`). R-U1c-7. SHARED: `RoadGateRow.idleMinutes`
  (THIS MAC'S sealed `DeviceSettings.idleLockMinutes`, read in `RoadCrossingFaces.derive`) + `RoadGateRow.idleChoices` (5 · 10
  · 30 · never — `DeviceSettings`' own offered set); `ProtectionCrossings.changeIdleLock(session, minutes:)` (the core's
  `changeSettings` on the open session, one act at a time; Castle only — Standard never locks, its write refuses);
  `RoadCrossingRoads.changeIdleLock` + `.lockNow` (defaulted — every existing test road unchanged); `RoadCrossingsModel
  .setIdleMinutes` (a same-value pick runs nothing; refusal in place; re-read after) + `.lockNow` (only where the Castle row
  stands). APP: `AppBootstrap.crossingRoads` wires both (`lockNow` IS `lock()` — VX-445's road); the REGISTRY declares
  `.lockLibraryNow` ONCE (verb `ProtectionCopy.lockNowLabel` — the one constant; doors `.menuBar` + `.surface`; NO
  `shortcutLabel` — P-VX309-U1c-4); `EditorCommands.menuRendered` gains it and the File menu's item renders `verb(.lockLibraryNow)`
  (the same words; the ⌃⌘L wiring unchanged at its call site); `RoadCrossingsSection` (the Castle-only "On this Mac" section)
  renders the dial (`ProtectionCopy`'s today's idle words — true on the new road: sleep and screen lock always lock in
  Castle) and Lock Library Now from the declaration, its `surfaceCapabilities` declared and joined to the registry walk's
  surface union (`CapabilityRegistryTests` — a JUSTIFIED one-line edit). Pins: `RoadIdleDialTests` (3, headless — the row's
  sealed minutes and the dial sealing 30 then never, read back by the row, the policy and a fresh unlock; Standard: no row, the
  write refuses; the model's dial and Lock Now over planted roads) `✔`; Mac only, BUILT: `RoadIdleDialRouteTests` (2 — through
  `AppBootstrap`: Standard no row; Castle the dial → the bootstrap's relock policy 30 at once, the pane's Lock Now → the lobby,
  the unlock reads 30 back; and the one declaration by source). `build-for-testing` green, no warning in a touched file.
  MUTATIONS on `61afe294e` (each restored `cmp`-identical to `u1c-prerevert/`): M-4a the row never reads the sealed minutes →
  `✘` (4 issues, two tests); M-4b the Castle guard dropped → `✘ standardHasNoRowAndTheDialRefuses` (2); M-4c nothing sealed
  (the `changeSettings` call skipped) → `✘ theCastleRowCarries…` (5).
- Piece 5 — VX-454 (probe first): CONFIRMED AND FIXED (`6aa235a67` the probe pin · `5aa955b4f` the fix). R-U1c-8. THE PROBE
  `SetPassphraseRowRereadTests.turningSyncOnWithANewPassphraseRetiresTheSetRowAndTheReminder` (headless; the planted vault)
  RED ON THE PRE-FIX TREE `✘ Test run with 1 test in 1 suite failed … with 2 issues` — the ticket is REAL, not hollow (the
  set row AND rule 3's reminder both stood after turn-on-sync set a passphrase, through the pane's appearance). THE FIX:
  `RoadStandingModel.rereadPassphrase()` (only ever retires: a passphrase exists ⇒ `offersSetPassphrase = false` and
  `reminder.passphraseWasSet()`), called FIRST by `refreshPane()` (the pane's appearance — the observed arm) and at an account
  act's LANDING (`AppBootstrap.accountRoads`' `landed`: the crossings' re-read as before, then the set row, then the key
  doors — Change/Reset stand where the set row retires). The probe green; the harness `✔ Test run with 318 tests in 54 suites
  passed`. Mac only, BUILT: `SetPassphraseRowRereadRouteTests` (1 — the landing arm through `AppBootstrap`, the pane never
  re-appearing: the set row and the reminder retire and Change passphrase… opens; RED ON OLD — the pin compiles on the
  pre-unit tree; the orchestrator's behavioural revert R-d below). `build-for-testing` green, no warning in a touched file.
  MUTATIONS on `5aa955b4f` (restored `cmp`-identical to `u1c-prerevert/ProtectionOpenFaces.swift`): M-5a the appearance never
  re-reads → `✘` (2 issues — the pre-fix red set exactly); M-5b the reminder never retired → `✘` (1). VX-454's TICKET: closes
  as FIXED (the brief's "red ⇒ the fix proceeds") — the pin is the evidence.
- Piece 1b — F-U1c-2 (self-review — rule 27's lobby is not the empty slot): FIXED (`71cc006c5` pins first · `df2bffa83` the
  fix). At rule 27's lobby (no library open, but a library no key file opens STANDS in the slot) its ID is inside the file no
  key opens; with this Mac's memory of it gone, ANY listed library could be it — and its older backups are its last road back
  (rule 4). The pins RED on `5aa955b4f`: core `withALibraryStandingInTheSlotTheNoLibraryDeleteRefuses` `✘ … 2 issues` (the
  no-library delete deleted over an occupied slot); app `withALibraryStandingInTheSlotNoDeleteIsOffered` `✘ … 3 issues` (the
  listing offered the other libraries a delete). THE FIX: the core's no-library act refuses `libraryAlreadyInSlot` before
  anything is deleted over an occupied slot; the listing's protected set is every library while the slot is occupied (or
  unreadable). Green; the harness `✔ Test run with 319 tests in 54 suites passed`. MUTATIONS on `df2bffa83` (restored
  `cmp`-identical): M-1i the core guard off → `✘` (2); M-1j the listing ignoring the occupied slot → `✘` (1).
- Piece 6 — the close: DONE (`571d34c37` + this tidy) — the core and app lines, the counts, the Mac-suite list with its red-on-old
  recipes, the walk notes, the PROVISIONALs, the findings and the machinery notes below.
- No revert is in flight (every mutation of this unit ran on a committed tree and was restored by `git checkout --`,
  `cmp`-identical to a copy in this session's scratchpad `u1c-prerevert/`; no scratch worktree; the tree is clean at the
  close).

**THE CORE LINES, LINE BY LINE (for the Fable ladder — `git diff ae5aca849 -- Sources/`; custody ⇒ Fable):**
1. `Assess/OwnCopies.swift` (pure, NEW functions): `isThisMacsCopy(_:in:)` — false for a copy no key file attributes to a
   library; TRUE for every `.container` copy (this Mac's container is per Mac and per login — `MacAttribution
   .thisMacsContainer`'s own reason, extended to the container's `<mac8>` subfolders, whose `<mac8>` is a library's OWN
   device ID on this Mac — rule 23); for a `.farFolder` copy, true only when it is a BACKUP pair (`.mac8`) whose
   `Backups/<library8>/<mac8>` subfolder (lowercased) equals that of a CONTAINER backup of the SAME library (the pair road
   copies the container pair under the same subfolder — R-U1a-1); false otherwise (another Mac's `<mac8>`, `.unattributed`,
   a far copy with no container twin). `thisMacsCopies(ofLibrary:in:)` = the library's copies filtered by it.
   `backupSubfolder` (private) — a backup's first three folders, lowercased, or nil.
2. `Executor/Acts/Copies.swift` — `offerDelete`: the fence `copy.mac.isMac(library.section.mac8)` REPLACED by
   `OwnCopies.isThisMacsCopy(copy, in: catalog)` (with `library != nil` and `library != this library` kept); the planned act,
   its one step and everything else unchanged. NEW `offerDeleteWithNoLibraryOpen(copies:catalog:)` (public, throws, returns the
   ids): refuses `libraryAlreadyInSlot` when the slot is occupied (before anything); reads `rememberedLibraryIDs()`; the
   deletable set = copies with a library not remembered and `isThisMacsCopy`; empty ⇒ `nothingToDo` (nothing written); else ONE
   `deleteCopies(ids:)`, one log line (a count — no names, no keys). No plan, no record write.
3. Tests: `OtherLibrarysCopiesDeleteTests` (4, NEW) + `CopyActTests.theOfferDeletesOnlyThisMacsCopiesOfAnotherLibrary` FLIPPED
   DELIBERATELY (its "another Mac's" copy moved to the shared far folder — the only place another Mac's copy can be).

**THE APP LINES AS BUILT (for the ladder):** VX-265 — the pure listing: `CopyDeleteChoice` (library, this Mac's copy ids by the
core's one fence, counts by kind, the library's newest listed day, the listed copies that stay); `CopyDoorsListing
.deleteChoices` (per OTHER library, none for a `protected` one or one with nothing to delete) + `deleteChoice(for:)` + `make(…,
protected:)`; `ProtectionCopyDoors.protectedFromDelete` (library open: it; none open: the remembered libraries — or EVERY
library while the slot is occupied or a read fails). The roads: `CopyDoorsRoads.deleteCopies` (library ID → `CopyDeleteOutcome`);
`ProtectionCopyDoors.deleteCopies(session, libraryID:)` (the open session's one-act lock; a fresh catalogue; this Mac's copies of
it NOW; the core's planned `offerDelete`; the copies-changed seam said; `.deleted(n)` / `copyGone` / `busy` / `deleteFailed`;
never the open library) and `deleteCopies(ctx, libraryID:)` (the core's no-library road); `AppBootstrap.copyDoorsRoads` (off-main;
the receipt on the status seam — `roadStanding?.speak`) and `copyDoorsRoadsWithoutALibrary` (`deleteCopiesWithNoLibraryOpen` —
never at `.ready`, one at a time beside T-5/T-8's landings: `copyLandingRunning`). The brain: `CopyDeleteModel` (the confirm —
lead, press, cancel, refusal in place) + `CopyDoorsModel.Phase.deleteCopies` / `openDeleteCopies` (from the listing: back to it,
re-read, `listingReceipt` above; from Data Safety's row: `.done`). The faces: `CopyDoorsSheet` (the listing rows' *Delete…* where a
choice exists; `DeleteCopiesConfirm`, its button `.destructive`), `RoadRestoreRows` (the other-library rows' *Delete…*),
`RoadDoorsHost.deleteCopies`, `LibraryOpenPresenter.beginDeleteCopies`, `SettingsSceneContent` + `DataSafetyPane` wiring. THE LEAF:
`FileBackupsLeaf.deleteCopies` — a `variorum.sqlite` inside an aside folder (`isAsideFolder`: `Previous Libraries/<stamp>/` or
`Backups/safety-copies/variorum-adopt-safety-<stamp>/`, read back by `CatalogNames.parseFolder`) also removes the folder's key
file(s) (any name `parseFile` calls a key file), the restore hold it carried and `.DS_Store`, then the folder when empty; a file of
hers keeps it. VX-210 — `CopyDoorsListing.unmanagedCopies(in:)` (foreign `.sqlite` + copies no key file names + unattributed
far copies) and `ProtectionWords.copiesElsewhereLine` in both listings, only above zero. VX-444 — `WordsCardLedger.carry(from:to:)`;
`ProtectionCopyDoors.makeMine(…, wordsLedger:)` (the outgoing id captured before the act, the carry once the copy is the library);
`makeMineInTheEmptySlot(…, wordsLedger:)` (typed words ⇒ recorded); the bootstrap passes `WordsCardLedger(defaults:
reminderLedger.defaults)`. VX-451 — `RoadGateRow.idleMinutes` + `.idleChoices`; `ProtectionCrossings.changeIdleLock`;
`RoadCrossingRoads.changeIdleLock` / `.lockNow` (defaulted); `RoadCrossingsModel.setIdleMinutes` / `.lockNow` / `idleBusy` /
`idleRefusal`; `AppBootstrap.crossingRoads` wiring; `CapabilityID.lockLibraryNow` + its one `Capability` (verb
`ProtectionCopy.lockNowLabel`, doors `.menuBar` + `.surface`, no `shortcutLabel`); `EditorCommands.menuRendered` + `Button(verb
(.lockLibraryNow))` (the chord unchanged at its call site); `RoadCrossingsSection.surfaceCapabilities` + the dial and the button in
the gate section; `CapabilityRegistryTests`' surface union (one line). VX-454 — `RoadStandingModel.rereadPassphrase()` (first in
`refreshPane()`) and `AppBootstrap.accountRoads`' `landed` (crossings, then the row, then the key doors).

**COUNTS (the final code tree — `df2bffa83`; this close commit changes only this file):**
- HEADLESS HARNESS (U1a's scratchpad `u1-harness`, re-pointed at this worktree; it now also symlinks U1c's five headless suites):
  **`✔ Test run with 319 tests in 54 suites passed after 5.719 seconds.`** (U1b's 304/50 + 15/4: `OtherLibrariesDeleteRoadTests`
  5, `WordsLedgerCarryRoadTests` 5, `RoadIdleDialTests` 3, `SetPassphraseRowRereadTests` 1, and `ProtectionFileLeavesTests` +1).
- CORE: the protection set (every `@Suite` type under `Tests/VariorumCoreTests/Protection` — 89 now, the filter re-derived from
  the files) Debug **`✔ Test run with 373 tests in 89 suites passed after 5.744 seconds.`** (369/88 + 4/1 —
  `OtherLibrarysCopiesDeleteTests`); Release (`swift test -c release`, the same filter) **`✔ Test run with 349 tests in 85 suites
  passed after 3.990 seconds.`** (345/84 + 4/1). THE FULL CORE SUITE, Debug (`swift test`): VariorumCoreTests **`✔ Test run with
  3353 tests in 438 suites passed after 207.432 seconds.`** (3349/437 + 4/1); the third target `✔ 40 tests in 6 suites`;
  VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — the ONE recorded VX-353 flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 19.1 s vs 15 s under the parallel
  run); ALONE `✔ Test run with 3 tests in 1 suite passed`. No MCP, Queries or Operations line in this diff.
- RED ON THE PRE-FIX TREES (pins committed first): the core fence `✘ … 2 issues` (`6ce2ebafd`); the leaf `✘ … 4 issues`
  (`fe90ec572`); VX-454's probe `✘ … 2 issues` (`6aa235a67`); F-U1c-2's two `✘ … 2 issues` + `✘ … 3 issues` (`71cc006c5`); every
  other new suite is NEW API — red by construction. MUTATIONS (each on a committed tree, restored `cmp`-identical): M-1b, M-1c,
  M-1e, M-1f, M-1g, M-1h, M-1i, M-1j, M-2a, M-3a..c, M-4a..c, M-5a..b — every one red at its own pins (the pieces' lines above).
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
  -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (no warning in a
  file this unit touched — checked after every piece's build); the phone `-scheme VariorumMobile -destination 'generic/platform=iOS
  Simulator' -configuration Debug … build` → **`** BUILD SUCCEEDED **`**; **the Release check `-configuration Release build` →
  `** BUILD SUCCEEDED **`**. All three on `df2bffa83`.
- Release behaviour: unchanged by construction — the delete roads, the line, the ledger carry, the dial, the pane's Lock Now and
  the re-read are reached only from the new road (`copyDoorsRoads*`, `crossingRoads`, `accountRoads`, `RoadStandingModel` exist
  only there; `DataSafetyPane.roadDoors` is nil on today's road); the core lines are the new road's executor's; the registry's new
  declaration renders the File menu's item with today's own constant (`ProtectionCopy.lockNowLabel` — the same string, the same
  chord, the same `canLock` gate) and adds no palette, helper or bar row. The binary is not byte-identical (rule 24's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309 test \
  -only-testing:VariorumTests/OtherLibrariesDeleteRouteTests \
  -only-testing:VariorumTests/CopyListingFacesSurfaceTests \
  -only-testing:VariorumTests/WordsLedgerCarryRouteTests \
  -only-testing:VariorumTests/RoadIdleDialRouteTests \
  -only-testing:VariorumTests/SetPassphraseRowRereadRouteTests \
  -only-testing:VariorumTests/OtherLibrariesDeleteRoadTests \
  -only-testing:VariorumTests/WordsLedgerCarryRoadTests \
  -only-testing:VariorumTests/RoadIdleDialTests \
  -only-testing:VariorumTests/SetPassphraseRowRereadTests \
  -only-testing:VariorumTests/ProtectionFileLeavesTests \
  -only-testing:VariorumTests/CapabilityRegistryTests \
  -only-testing:VariorumTests/HelperCurrencyTests \
  -only-testing:VariorumTests/WingSwitcherChordTests \
  -only-testing:VariorumTests/CommandRouterTests \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/CopyDoorsListRefreshTests \
  -only-testing:VariorumTests/CopyDoorsPickRefreshTests \
  -only-testing:VariorumTests/CopyDoorsQuietProbeTests \
  -only-testing:VariorumTests/LookInsideCopyDoorTests \
  -only-testing:VariorumTests/LookInsideRoadTests \
  -only-testing:VariorumTests/MakeMineRoadTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/EmptySlotLandingRoadTests \
  -only-testing:VariorumTests/EmptySlotMakeMineRouteTests \
  -only-testing:VariorumTests/EmptySlotDoorsSurfaceTests \
  -only-testing:VariorumTests/PreviousLibrariesArcTests \
  -only-testing:VariorumTests/PlaintextExportBringInRoadTests \
  -only-testing:VariorumTests/PlaintextExportBringInRouteTests \
  -only-testing:VariorumTests/PickedCopyRoadTests \
  -only-testing:VariorumTests/ProtectionBackupHookTests \
  -only-testing:VariorumTests/ProtectionPairRetentionTests \
  -only-testing:VariorumTests/ProtectionPairRetentionGuardMutationTests \
  -only-testing:VariorumTests/DataSafetyRoadCountsTests \
  -only-testing:VariorumTests/DataSafetyRunbookTests \
  -only-testing:VariorumTests/BackupRunTests \
  -only-testing:VariorumTests/SyncSafetyFaceTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/RoadCrossingFacesTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/RoadLockTests \
  -only-testing:VariorumTests/RoadLockRouteTests \
  -only-testing:VariorumTests/WordsClipboardLockRouteTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/Phase13pLobbyTests \
  -only-testing:VariorumTests/ProtectionPaneWaveTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/NoKeyFileDoorTests \
  -only-testing:VariorumTests/ProtectionAccountRoadTests \
  -only-testing:VariorumTests/ProtectionAccountRouteTests \
  -only-testing:VariorumTests/RoadAccountModelTests \
  -only-testing:VariorumTests/RoadKeyDoorRoadTests \
  -only-testing:VariorumTests/RoadKeyDoorsModelTests \
  -only-testing:VariorumTests/RoadKeyDoorSurfaceTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first five are U1c's Mac-only suites (2 + 2 + 2 + 2 + 1 = **9 tests**; the route suites drive a new-road `AppBootstrap` over
the PLANTED road — no keychain, a temp slot; `WordsLedgerCarryRouteTests` writes only its own library ids' keys into the test
bootstrap's reminder suite and removes them); the next five are U1c's headless suites (15 tests + the leaf pin, also green in the
harness). Then the suites over the files this unit touched: the registry and the menu (`EditorCommands`, the registry walk, the
helper, the ⌃⌘L chord's own pin), the doors' brain, listing and leaves (`CopyDoorsModel`, `ProtectionCopyDoors`,
`FileBackupsLeaf` — retention's prune calls it), Data Safety's pane and its hosts, the crossings' faces, model and acts, the lock,
the pane's wave and rows, the reminder and the band, the account and key-door roads (the landing chain), the words, and the
source scans over edited files.

**THE RED-ON-OLD BY BEHAVIOURAL REVERT for the Mac-only suites (the orchestrator's, each from a committed tree, restored by `git
checkout --`):**
- **(R-a)** in `AppBootstrap.copyDoorsRoads`, the `deleteCopies:` argument dropped → `OtherLibrariesDeleteRouteTests
  .withTheLibraryOpenTheDeleteRunsOnTheOpenSession…` RED (`#require(roads.deleteCopies)`); in `copyDoorsRoadsWithoutALibrary`, the
  same → `…withNoLibraryOpenTheRoadsDelete…` RED.
- **(R-b)** in `ProtectionCopyDoors.makeMine`, the `wordsLedger?.carry(…)` line dropped → `WordsLedgerCarryRouteTests
  .afterMakeThisMyLibraryTheCardNeverReOffersRecordedWords` RED (the card offers); in `makeMineInTheEmptySlot`, the
  `wordsLedger?.record(…)` line dropped → `…afterTheEmptySlotLandingByTypedWords…` RED. (These two compile on the PRE-UNIT tree
  too: run them on `ae5aca849` with only the test file added — RED there, the truest red-on-old.)
- **(R-c)** in `AppBootstrap.crossingRoads`, the `changeIdleLock:` and `lockNow:` arguments dropped → `RoadIdleDialRouteTests
  .theDialSealsThisMacsMinutesAndThePanesLockNowLocks` RED (the row stays 10; no lobby).
- **(R-d)** in `AppBootstrap.accountRoads`, `landed:` back to `{ [weak self] in await self?.roadCrossings?.refresh() }` →
  `SetPassphraseRowRereadRouteTests.turningSyncOnRetiresTheSetRowAtTheLanding` RED (the set row stands at the landing). (It too
  compiles on `ae5aca849` — RED there.)
- `CopyListingFacesSurfaceTests` and `RoadIdleDialRouteTests.lockLibraryNowIsOneDeclaration…` read sources and new API — red by
  construction.

**WALK NOTES FOR THE ACCEPTANCE SPINE (the orchestrator's ONE phase walk — the DEV store only, under a held claim, both voices
wherever a face renders; `road:` log lines as U1b's walk notes name them):**
- **VX-265 with the library open — ON A THROWAWAY ONLY.** The dev store's `Previous Libraries/` holds earlier walks' libraries
  that are NOT this unit's to delete: walk the delete on a THROWAWAY library seated in the slot (T-8's coordinator shape: A aside
  whole first, cmp-verified, restored whole after), with a second throwaway made to step aside (Make this my library on the
  throwaway's own backup). Data Safety ▸ Restore from Backup: the stepped-aside throwaway's rows carry *Delete…*, the open
  library's rows do not; the confirm — *Delete this library's copies?*, the lead naming the library by its day and counting
  "N backups and a previous library", "Your library isn't touched." — capture (light, dark); *Delete copies* → the quiet receipt
  *Deleted N copies of another library from this Mac.*; the rows gone; `Previous Libraries/<stamp>/` of it GONE whole (`ls`), its
  `Backups/<lib8>/<mac8>/` pairs gone; the open throwaway's own pairs untouched. Log: `road: deleted N of another library's copies
  on this Mac — library <8>`.
- **VX-265 at the missing face and rule 27's lobby.** Move the throwaway's library out of the slot (U1b's T-5 walk move) → the
  missing face → *Restore from a Backup…*: a non-remembered library's rows carry *Delete…* and it works (the listing re-reads with
  the receipt above it); the REMEMBERED library's rows carry none. At rule 27's lobby (U2's recipe) NO row carries *Delete…*.
- **VX-210.** The line *Copies outside the folders Variorum keeps — older backups, or a folder you made — are left as they are:
  they're yours to manage in the Finder.* in both listings — EXPECTED VISIBLE on the dev store (today's flat backups beside the
  library and the A1 rail's safety copies are such copies); on a throwaway slot with none, absent (P-2). Capture both.
- **VX-444.** After Make this my library on a throwaway whose card was recorded (its look closed past the warning), the card
  above the quick entry does NOT offer the words; after T-5 by the copy's typed words, not either; after T-5 by its passphrase,
  it does (fresh words). Never a words look on the dev library (F-U2b-5).
- **VX-451.** On a library in Castle (the dev library's LOCAL Use Castle, VX-308's walk machinery; Standard back at posture
  restore): Settings ▸ Protection ▸ *On this Mac*: the gate row, then *Lock after time away* (10) with *5 minutes · 10 minutes ·
  30 minutes · never*, the sentence, *Lock Library Now* and its line — capture (light, dark). Pick 5 → log `road: this Mac locks
  after 5 minutes away now`; *Lock Library Now* → the lobby, the Settings window closes (VX-224); the passphrase reopens. The File
  menu's *Lock Library Now* ⌃⌘L unchanged. In Standard none of the row. POSTURE: set the dial back to 10 before Use Standard (the
  sealed setting rides the dev library's record — term 3's spirit), then Use Standard.
- **VX-454.** A THROWAWAY library with no passphrase, the throwaway project (VX-308's walk switch): Settings ▸ Protection ▸ Turn
  on sync with a new passphrase → at once, with the pane still open: *Set a passphrase…* GONE, *Change passphrase…* / *Reset
  forgotten passphrase…* shown, the card's reminder gone. Capture. Signed out at the end.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared ledger is
the merging session's):**
- **P-VX309-U1c-1 — every new sentence** (the delete door *Delete…*, its title, lead, button *Delete copies*, working line, receipt,
  failure; VX-210's line): (a) BUILT as drafted in `ProtectionWords`' U1c section; U2's words pass rewrites against her words.
- **P-VX309-U1c-2 — with no library open the delete is the EMPTY slot's, and never a remembered library's:** (a) BUILT — at the
  missing face every listed library this Mac does not remember is offered; the remembered one (the slot's missing library) never;
  at rule 27's lobby (a library stands in the slot, its ID unknowable) none; the core act refuses the same; (b) every listed library
  offered with no library open (they are all "other libraries" there); (c) no delete at all without a library open.
- **P-VX309-U1c-3 — VX-444's carry:** (a) BUILT — the outgoing library's `recorded` and `dismissed` marks carry onto the new id;
  (b) the standing act marks the new id recorded unconditionally (she typed her current words at its confirm); (c) carry
  `recorded` only.
- **P-VX309-U1c-4 — Lock Library Now's chord is not in its declaration:** (a) BUILT — the declaration carries both doors and today's
  verb; the chord stays wired at the menu's call site; Release shows nothing new; (b) declare `shortcutLabel: "⌃⌘L"` and add the ⌘/
  helper row the discoverability guard then demands (a Release-visible line — true on both roads); (c) no declaration (two literal
  doors).
- **P-VX309-U1c-5 — this Mac's FAR copies of another library** are those filed under a `<library8>/<mac8>` its container files the
  same library under: (a) BUILT; (b) container copies only (the far folder's never deleted by the door); (c) every far copy of the
  library under any `<mac8>` (another Mac's — refused by rule 19's own fence, never an option in truth).
- **P-VX309-U1c-6 — deleting an aside copy takes its folder** (its key file, the hold it carried, the folder when nothing of hers is
  in it): (a) BUILT; (b) the library file and sidecars alone (the leaf as it was — a key file orphaned in a folder no list shows).
- **P-VX309-U1c-7 — the door on EVERY row of the other library** (the brief's "each such row"; the confirm counts the library's
  copies, not the row's): (a) BUILT; (b) one *Delete…* per library, the listing grouping other libraries' rows by library.
- **P-VX309-U1c-8 — VX-454's re-read also retires rule 3's reminder and re-reads the key doors at the landing:** (a) BUILT (one
  act's faces — the reminder's own rule: never shown once a passphrase exists); (b) the set row only.
- **P-VX309-U1c-9 — VX-451's dial in the Castle section, refused outside Castle, today's words reused:** (a) BUILT; (b) the dial in
  both postures (a Standard library never locks — rule 8's honest limit says so already); (c) new words for the new road.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here unless said):**
- **F-U1c-1 (Bug, Confirmed by pin — FIXED in piece 1, R-U1c-1):** `offerDelete`'s fence compared every copy's `<mac8>` with the
  OPEN library's device ID; a library's device ID is its own on each Mac (rule 23), so the core act could never delete another
  library's backups — only its Previous Library. Pin `OtherLibrarysCopiesDeleteTests.anotherLibrarysCopiesThisMacMadeGo…`.
- **F-U1c-2 (Bug, self-review — FIXED in piece 1b):** rule 27's lobby offered (and the no-library act ran) a delete while a library
  no key opens stands in the slot — whose own older backups could be the copies deleted.
- **F-U1c-3 (Bug, Suspected, Castle & sync, Medium — a ticket at closeout; VX-450's class):** with a library open, the delete runs
  the core's PLANNED `offerDelete`; a file removal that throws inside its one step (`deleteCopies` — permissions, a far folder gone
  mid-act) is not an `ActRollback`, so the act stays IN FLIGHT on the open library and every later act refuses `actInFlight` until
  the next open's settle re-runs the step (idempotent); a persistent failure wedges. Traced, not probed: the planted leaves carry no
  failure seam (the hallucination guard — no build). Options: (a) as is; (b) the program maps a leaf failure to `ActRollback`
  (a delete has no old state to restore — the ids already gone are gone; the refusal says how many went); (c) the door runs the
  plan-less road with a library open too.
- **F-U1c-4 (Castle & sync — her bundle, beside F-U1b-1):** deleting another library's copies leaves its quiet roads on this Mac —
  its silent custody item and Apple key, stamped with its library ID — though nothing they open remains. F-U1b-1's option (a) reads
  "its quiet roads go when she deletes it (rule 19)": that is NOT what is built (rule 19's delete takes copies only — the core
  act's own scope since VX-378 U1); the bundle row should say so. No build (CastleRules territory).
- **F-U1c-5 (MOBILE PARITY):** nothing mobile-visible — the phone has no doors' listing, no Data Safety, no Protection pane Castle
  section, no band ledger carry (no Make this my library); the shared files compile for iOS (the phone build green). The phone's
  relock still reads today's facts (F-U4-4).
- **F-U1c-6 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains, in place, one pointer to this plan: the
  doors' listings carry rule 19's delete (this Mac's copies of ONE other library, by place; never the open library's; with no
  library open never a remembered one, none over rule 27's library; an aside copy goes with its folder) and VX-210's one line; the
  band ledger carries across Make this my library; on the new road Castle's "On this Mac" section carries the idle dial and Lock
  Library Now (one capability with the File menu's). With F-U1a-4 and U1b's lines.
- **F-U1c-7 (record only):** VX-454's "self-heals at the next launch" holds (a fresh `RoadStandingModel` per open reads
  `offersSetPassphrase` anew); the probe confirmed the in-session staleness, so the ticket closes FIXED, not unreproducible.
- **F-U1c-8 (record only):** the full core suite's one wall-clock red under the parallel run (VX-353's MCP bound), green alone — an
  existing class, no line of this diff. F-U1b-4's stale `Copies.swift` header line is untouched (the ladder's NIT).

**U1c ARBITRATION (the orchestrator, 2026-10-19 — repo-first before the Mac batch and U2):**
- **F-U1c-1** (the fence bug — `offerDelete` compared copies' `<mac8>` against the OPEN library's device ID, so rule
  19's delete could never reach another library's backups): the in-unit FIX APPROVED — the trace is sound (rule 23:
  a device ID is per library), the pin was red-on-old, and the `CopyActTests` flip is a justified edit (another
  Mac's copy can only exist in the shared far folder under the place-told rule). The ladder reads the core lines.
- **F-U1c-2** (rule 27's lobby is not the empty slot): the self-review FIX APPROVED — pins first, both arms.
- **F-U1c-3** (a planned delete whose file removal fails mid-step wedges the open library's acts): a TICKET at
  closeout (Bug, Suspected, Castle & sync, Medium — the VX-450/F-U1b-7 class), option (b) named as the likely fix
  (a delete has no old state to restore, so a leaf failure maps to `ActRollback` honestly).
- **F-U1c-4** (deleting a library's copies leaves its quiet roads): HER BUNDLE, FOLDED INTO F-U1b-1's row — and that
  row's option (a) wording is CORRECTED as this finding says (what is built deletes copies only, never roads).
- **P-VX309-U1c-4** (the ⌃⌘L chord left out of the declaration): ACCEPTED as built — Release parity is the hard law;
  the (b) arm (declare the chord + the helper row) is the natural VX-329 follow-up when the new road ships Release,
  and the bundle row says so.
- **P-VX309-U1c-1..9 otherwise: each stands as built** pending her bundle. VX-454's ticket closes as FIXED at the
  merge (the probe red-on-old is the evidence; F-U1c-7 records the self-heal claim as verified).

**THE U1c MAC BATCH (the orchestrator, 2026-10-19 22:25–23:05 MDT, stage claim `vx-309-u1c-mac`, the coordinator's
GO after a short human-at-the-Mac hold; logs `/tmp/vx309-u1c-*.log`, deleted at closeout):** `✔ Test run with 379
tests in 68 suites passed` — ZERO real reds on the first run (the first unit batch of the phase with none). THE
REVERTS, each from the committed tree, restored `cmp`-identical, `git status` clean: **R-a** (both `deleteCopies:`
roads nil) → `OtherLibrariesDeleteRouteTests` RED both tests; **R-b** (both ledger lines dropped) →
`WordsLedgerCarryRouteTests` RED both tests; **R-c** (the dial and Lock Now args dropped) → `RoadIdleDialRouteTests`
RED (the sealed minutes stay 10, no lobby); **R-d** (the `landed` chain back to crossings-only) →
`SetPassphraseRowRereadRouteTests` RED at the landing. **THE PRE-UNIT RED-ON-OLD (the truest form):** a throwaway
detached checkout of `ae5aca849` at `/tmp/vx309-preunit` with ONLY the two test files added ran
`WordsLedgerCarryRouteTests` + `SetPassphraseRowRereadRouteTests` → `✘ 3 tests in 2 suites failed … 5 issues` (every
test red — the card re-offers recorded words; the set row, the reminder and the key doors all stale at the landing);
the checkout REMOVED and pruned, the worktree back at the branch tip, status clean. The confirming re-run (the five
Mac-only suites) `✔ Test run with 9 tests in 5 suites passed`; no `calmAsks.words` key in the debug defaults domain
(the route suite's keys live in its own test suite and are removed by it); 0 instances; the stage released with the
coordinator's result line. **THE U1c MAC LEG IS CLOSED — the implementer era's U1 theme is done whole.**

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree. The harness is U1a's (this session's
scratchpad `u1-harness` — it survived; U1c's five headless suites symlinked in). One record edit (a Python replace) failed its own
uniqueness assert (an anchor shared by three records) AFTER its code commit had been made in the same command; the record was
re-applied with unique anchors in the next commit (`ff6d7b52d`) — nothing lost, the order honest here. Every pin set committed
before its fix (`6ce2ebafd`, `fe90ec572`, `6aa235a67`, `71cc006c5`) or red by construction (new API); every mutation run on a
committed tree and restored `cmp`-identical from `u1c-prerevert/`. Commits: `441d4a1b9` (record) · `6ce2ebafd` (1 core pin first)
· `8d4e028fb` (1 core) · `fe90ec572` (1 leaf pin first) · `b1c25a7f8` (1 leaf) · `645ce1784` (1+2 app) · `c9fd33d92` (3) ·
`ff6d7b52d` (record) · `61afe294e` (4) · `6aa235a67` (5 probe pin first) · `5aa955b4f` (5) · `71cc006c5` (1b pins first) ·
`df2bffa83` (1b) · the close commit.

### U2 RECORD — THE WORDS (Opus implementer, 2026-10-19/20; the join moment + VX-456 · VX-457 · moveNotYet · VX-264 items 5+7 · VX-263 · VX-211 · the guide + Data Safety · VX-213's share · U1's undrafted words · VX-453 — BUILT; the Mac suite and the walk PENDING)

**Not done in U2, first:**
- NO MAC SUITE RUN, NO WALK, no stage, no Debug launch, no store touch, no network, no Linear, no subagent (the brief). Mac-only
  suites this unit added or flipped were BUILT, never run — `TutorialNewRoadChapterTests` (3, new), `SettingsAccountSurfaceTests`
  (3, new), `SettingsAccountSearchTests` (2, new — ALSO run headless, red-on-old, in a scratch harness), and the deliberate flips
  in `RoadJoinFollowSurfaceTests` (2 pins), `PlaintextExportBringInRouteTests` (both arms), plus the passphrase-fixture lifts in
  `RoadCrossingSurfaceTests`, `RoadKeyDoorSurfaceTests`, `RoadAccountSurfaceTests` — the orchestrator's, under the stage (the
  list and the red-on-old recipes below). Every other new pin ran HEADLESS, red-on-old verified or red by construction.
- `pg_temp` (VX-213's held half) NOT DONE — held for her go, VX-329's window. No `Server/` line, no SQL anywhere in the unit.
- THE ARM-10 PIN'S SCOPE FIX (VX-191 auditor A's Q2) is NOT made — a test line in a sync-adjacent core suite, outside the brief's
  record-correction share; routed (F-U2-6). The S1 record carries the dated correction saying so.
- THE GUIDE: the seeder only. No store was re-seeded (dev or real); the truth-check and the real store's re-seed ride VX-329.
  The phone's guide edition (`MobileTutorialSeeder`) is untouched (MOBILE PARITY below).
- ONE CORE CUSTODY LINE (piece 1, `Acts/AccountActs.swift` — reads only) and ONE pure Domain file (`PassphraseStrength.swift`)
  are the unit's core lines (THE CORE LINES below — the custody line is Fable's to read). Zero `Sync/`, `Server/`, schema,
  migration, project or dependency lines; `SyncSchema.lockstepVersion` 13.
- Today's road byte-unchanged in behaviour: every new face, line and seam is reached only from the new road (Release parity
  below); the binary is not byte-identical (rule 24's precedent).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE; `notes/SyncSpec.md` WHOLE; `notes/SurfaceContracts.md` WHOLE; this plan WHOLE (§0–§5d,
§5b-R, the §6 U1a/U1b/U1c RECORDS with their ARBITRATIONS and MAC BATCHES); `notes/QUESTIONS.md` #216 (her VX-264 /
VX-203 / VX-209 sitting words), #235, #236 (her drafts verbatim); `notes/plans/vx-308-accounts-key-doors.md` §6 U2 RECORD
(the join moment as built, the follow's Done), U3 RECORD (the key doors' words, VX-263's line, F-U3-4), U4 RECORD (the
export-notice durable mark, F-U4-1), U1 RECORD's F-U1-2 (the new road's unenforced floor) and THE WALK RECORD; the VX-308
handoff; the vx-266 design's §3.11 (VX-264's rulings as ruled at #216); `notes/TICKETS.md` (VX-211/213/263/264/379/453/
455/456/457 one-liners — the bodies are not readable without Linear; their remainders are §1's and #216's); the lifecycle
page (rendered as text, never edited); `notes/plans/fixes/vx-191-encryption-audit.md` whole + its auditor A file
(`vx-191-audit/A-ten-questions.md` — Q1/Q2/Q6) + auditor C's account-deletion line; `notes/plans/run-b-stress-pass.md`
(the S1 record those corrections are against); `notes/stargazing-castle-rebuild-delta-brief.md`; the code —
`ProtectionWords.swift` WHOLE, `ProtectionCopy` (`StoreProtection.swift`, `PostureCopy.swift` — the floor and copy §7),
`LibraryOpenCopy.swift`, `RoadAccountFaces.swift`, `RoadAccountModel.swift`, `RoadAccountSheet.swift`, `ProtectionOpenFaces
.swift`, `RoadCrossingsModel.swift` + `ProtectionCrossingActs.swift` (`ExportNoticeMark` — VX-457's idiom), the core
`AccountActs.swift` (the join's `sameWords`), `KeyFile.swift`, `KeyDoors.swift`, `CommonSteps.swift` (`newLocks`),
`VaultModel.swift`, `Secrets.swift` (`Lock` is RFC 3394 — deterministic), `RouteFinder.swift`, `AccountVaultClient.swift`;
`SetPassphraseModel.swift`; `Domain/` (the estimator's home); `SettingsShape.swift` + `AppSettingsView.swift` (VX-453's
seam); `DataSafetyCopy.swift`, `DataSafetyModel.swift`, `DataSafetyPane.swift`; `TutorialSeeder.swift` (the guide's
chapters), `LaunchFurniture.swift`, `BirthFurnitureSeeders.swift` (the readme's Start Here passages — the new-road gate
precedent). HARNESS: U1a's scratchpad package `u1-harness` (it survived in this session's scratchpad, pointed at this
worktree, `--skip-update`): the BASELINE on `4a3c867cd` `✔ Test run with 319 tests in 54 suites passed after 5.800
seconds.` (U1c's close count, exactly).

**MY READINGS (each the brief's letter as I read it — building on them):**
- **R-U2-1 — VX-456 IS DECIDABLE FROM THE FILES ONLY WHERE THE LIBRARY HAS NO WORDS LOCK OF ITS OWN.** `Lock` is RFC 3394
  (deterministic), and a synced key file's twelve-words copy of the master is the vault's recovery wrap copied byte for
  byte (§3.5a), so "the library's words ARE the account's" is provable without words exactly when the key file carries no
  own words lock, its copy equals the vault's `masterByWords`, and its master lock opens under the master the typed secret
  reached. A file WITH its own words lock beside a matching copy proves nothing: a New Words made while the library is
  local (after a leave) re-makes the own lock and leaves the copy as it was — quiet there would hide a real replacement.
  So the first device of an account (it handed its own pair up — its own lock stands) still hears the moment once on a
  passphrase re-join (true either way); every passphrase-typed join drops the own lock, so a later re-join is quiet. Built
  as the narrow arm; PROVISIONAL P-VX309-U2-1.
- **R-U2-2 — HER DRAFT IS THE PASSPHRASE-TYPED MOMENT; THE TYPED-WORDS MOMENT KEEPS RULE 7'S SENTENCE.** #236's "here they
  are" edge is P-VX378-U2-3's passphrase-typed notice (`joinWordsNotShown`) — her draft replaces it, the account named by
  the sign-in's email. The words-typed moment shows the typed words under rule 7's own sentence (`joinWordsSentence`, pinned
  byte-equal to `notes/CastleRules.md`) — canon, untouched here; whether her direction also reads onto rule 7's phrase is
  P-VX309-U2-3. The middle clause drops as §5d rules (F-U2-1 below records §1's other reading of her note).
- **R-U2-3 — VX-457's MARK IS WRITTEN WHERE THE DONE WAS OWED, NOWHERE ELSE.** The Done was a receipt owed at exactly two
  places (the press that landed whole; the open whose settle finished the follow — VX-107's once-said rule); the mark is
  written at exactly those two, by the open library's ID (a follow re-keys but never changes the library's ID), in the
  calm-asks ledger's defaults (the bootstrap's `reminderLedger` — a test bootstrap's own suite), and read by the account
  section at every landing — the export notice's "reconciled at every ready" is the section's re-read here (there is no state
  to reconcile against: the Done is a historical fact until she reads it). A follow stopped past its swap marks nothing at the
  press: the settle that finishes it marks (never twice — the mark is a value, not a count).
- **R-U2-4 — ITEM 7's "WHAT THE COPY IS" IS WHAT IT BECOMES.** The confirm can know the OPEN library's shape for certain (its
  record: posture and account), and rule 17 makes the copy a new library in exactly that posture, under that pair, with no
  sync identity — so "said plainly, per library shape" is the posture it lands in (in Castle: rule 17's own sentence), and,
  synced, that the new library doesn't sync until she turns sync on for it (VX-209's synced arm). The COPY's own former
  posture is not claimed: only its key file speaks of it, and an Apple lock there is not a reliable posture fact (a Standard
  key file can lack one for a while — VX-447's mint, a failed Apple write). Recorded as P-VX309-U2-5's option (b).
- **R-U2-5 — VX-263's REWORD SUPERSEDES U3's LINE IN ITS HOSTS.** The route finder (`RouteFinder.opensWith`) speaks nowhere
  in the app; "wherever the route finder speaks" is VX-263's one line's hosts — the three key doors and the New Words door
  (the VX-308 plan named `keyDoorsLine` "VX-263's one line"). The rules reduce the route finder to that one sentence, so the
  reword IS the line now: U3's plan-pinned test flipped, said here.
- **R-U2-6 — "THE FLOOR STAYS THE ONLY REFUSAL" NEEDS THE FLOOR ON THE NEW ROAD.** Her kickoff ruling presumes a standing
  12-character refusal; on the new road none of the four setters enforced it (VX-308's F-U1-2 / F-U3-4 — routed, and not in
  VX-308's filed list: VX-211, "12-character length floor but no strength check", is where it lives). Same fields, same
  sentence, her 17n rule — so the floor is built here as VX-211's first half, pinned red-on-old, with today's road's own
  constants (never a second number or sentence). The hint is advice only: a 12-character phrase that earns it is SET.
- **R-U2-7 — "CORRECT THE VX-191 RECORD" LANDS IN THE S1 RECORD THE CORRECTIONS ARE ABOUT.** The three sentences that are
  false (Q1's, Q6's) or whose pin is mis-aimed (Q2's) live in the 09-21 S1 record (`notes/plans/run-b-stress-pass.md`);
  the VX-191 record is the audit that FOUND them (its §V tidy-up row; auditor A's file the current reading). So the dated
  correction notes go in place under the S1 record's own verdicts, and the VX-191 record's row gains a dated note that
  they landed — both in place, nothing rewritten, nothing silent.
- **R-U2-8 — VX-453's ROW JOINS ONLY WHERE ITS SECTION RENDERS.** The account section is the new road's alone
  (`ProtectionPane`: `roadStanding?.account`; today's road has no such section in Settings), and the catalog's own rule is
  declared ⇔ rendered (a search that names a row the pane doesn't show is the defect class the catalog exists against). So the
  row is road-gated twice: by the build (Release keeps today's catalog byte for byte — the brief's parity line) and, at
  runtime, by the window (the results pane asks with the section's presence — a Debug build over the real store's variant,
  today's road, never names it).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton + the harness baseline: DONE (`fe2344041`).
- Piece 1 — THE JOIN MOMENT + VX-456: DONE (`9ed104688` pins first · `b11fc21f2` the core line · `ffce73716` the words and
  the face). CORE (`Acts/AccountActs.swift` — the unit's custody line, THE CORE LINES below): `ProtectionExecutor
  .wordsAreTheAccountsAlready(_:vault:master:)` (reads only) ORed into `join`'s `sameWords`. Pins `JoinWordsMomentTests`
  (core, 8): RED ON THE PRE-FIX TREE `✘ Test run with 7 tests in 1 suite failed after 0.019 seconds with 2 issues.` (a
  passphrase-joined library, left and back by the passphrase — or by the words — heard its words replaced); the five
  guards green on both trees; with the fix + the pure rule's pin `✔ Test run with 8 tests in 1 suite passed`; the
  account-act neighbours (`AccountJoinTests`, `LeaveAccountTests`, `U2PinsAccount*`, `U2CrashHarness*`, the follow and
  lifecycle suites) `✔ Test run with 45 tests in 10 suites passed`. MUTATIONS on `b11fc21f2` (each restored `cmp`-identical
  to `u2-prerevert/AccountActs.swift`): M-456a the own-lock guard dropped → `✘ … 3 issues` (the first device's arm, the
  new-words-after-a-leave arm, the pure rule); M-456b the byte identity dropped → `✘ theAccountsWordsChangedElsewhere…` (1);
  M-456c the master-lock check dropped → `✘ thePureRuleReadsTheFilesAlone` (1). APP: `ProtectionWords.joinWordsNotShown(_
  email:)` — her draft; `RoadAccountDoorOpen.accountEmail` (the join's and Move's doors, from the sign-in); the sheet's
  `.notShown` arm reads it. `RoadJoinFollowWordsTests`' two moment pins FLIPPED DELIBERATELY (they pinned the direction she
  ruled wrong). Pin `ProtectionJoinFollowRoadTests.vx456_aRejoinWhoseWordsAreAlreadyTheAccountsOwesNoMoment` (the planted
  road; the door carries her email) — RED ON OLD by behavioural revert (the core line back to `9ed104688`) `✘ … 1 issue`,
  restored `cmp`-identical; the harness's join suites `✔ Test run with 69 tests in 9 suites passed`.
- Piece 2 — VX-457 (the follow's Done, a durable pane notice until OK): DONE (`009135343` pin first · `58b3a3ef6`). R-U2-3
  below. `FollowDoneMark` (`ProtectionAccountActs.swift` — `variorum.calmAsks.followDone.<libraryID>.kind`, the export
  notice's idiom: by library, a kind name) written where the Done was owed — the press that landed whole (`ProtectionAccountRoad
  .owed(after:request:)`, the bootstrap's seam marks instead of owing a receipt) and the open whose settle finished the follow
  (`RoadStandingModel.make` from `report.settledFollow` — VX-107's durable reading); `RoadAccountModel.followDone` re-read at
  every landing, `followDoneOK()` the one clear; the section renders VX-107's sentence + *OK* (`ProtectionWords.followDoneOK`).
  The one-shot receipt RETIRES (`RoadStandingFaces.derive` owes it no more). Pins `FollowDoneNoticeTests` (6, headless): the
  receipt-retired arm RED ON OLD `✘ … 3 issues` (one per kind); the mark by library; the press arm's owed rule; the section's
  read and OK across a fresh model (the relaunch); the words; NEVER ON TODAY'S ROAD (by source — only new-road files name the
  mark; the press arm behind `guard newRoad`). FLIPPED DELIBERATELY: `ProtectionJoinFollowRoadTests.vx107_aDoubleCrashedFollow
  StillSaysItsDone` (no receipt; marked by the settling open, standing at a later open, cleared by OK) and the two Mac route
  pins in `RoadJoinFollowSurfaceTests` (no receipt; `account.followDone` after the reopen; OK clears — BUILT, their run the
  orchestrator's). Harness `✔ Test run with 46 tests in 6 suites passed`; `build-for-testing` `** TEST BUILD SUCCEEDED **`.
  MUTATIONS on `58b3a3ef6` (each restored `cmp`-identical to `u2-prerevert/`): M-457a the settle arm's mark dropped → `✘ vx107_…`
  (4 issues, both kinds); M-457b the section never re-reads → `✘ theSectionReadsTheDone…` (3); M-457c the press arm owes a
  follow's receipt again → `✘ aFollowThatLandedWhole…` (1).
- Piece 3 — `moveNotYet` names the road: DONE (`89d85e24c` pin first · `4737d6c56`). The line: *To move this library to that
  account, sign out, choose Use this Mac only, then sign back in to that account and turn on sync. This library's passphrase
  and twelve words become that account's.* — the brief's two presses fitted to the faces (This Mac Only renders only while
  signed out: `assess` refuses it `.otherAccountSignedIn`), PROVISIONAL P-VX309-U2-4. Pin `U2WordsTests.moveNotYetNamesTheRoad`
  RED ON OLD `✘ … 5 issues` (the old line held, the edit set aside in the gitignored `App/Variorum/DerivedData/u2-hold/` and
  restored `cmp`-identical), green after; the account words and faces suites `✔ 35 tests in 6 suites`.
- Piece 4 — VX-264 ITEMS 5 + 7 (+ VX-209's synced arm): DONE (`7b9384d83` + `9ef087ab2` pins first — the first of the two
  committed a test with three bare-`String` `Comment` arguments that did not compile; the second fixed them, machinery
  honesty · `f9b01dc6f`). R-U2-4 below. ITEM 5 — her #216 sentences where another library's copies are counted and deleted:
  `deleteCopiesCounts` (*That's 27 backups, plus 2 older libraries Variorum kept when you opened or restored a different
  one.* — fitted: the singular, the copies she opened here) and `deleteCopiesWayBack` (her way-back sentence; the singular
  fitted) in VX-265's confirm lead; `olderLibrariesLine` under the other libraries in BOTH listings, only where one is listed
  (`CopyDoorsListing.listsAnOlderLibrary`, P-2). ITEM 7 — the confirm's lead computed per the OPEN library's shape
  (`OpenLibraryShape` — posture + synced — through `CopyDoorsRoads.libraryShape`, the bootstrap's from the session):
  `makeMineLead(posture:passphraseSet:synced:)` — §7c's draft byte for byte is its Standard/unsynced arm; in Castle the
  posture said (*in Castle*) + rule 17's own sentence, hers (*You never leave Castle by opening something.* — pinned to the
  rules file); synced, VX-209's arm (`makeMineSyncedLine` — the new library carries no sync identity, P-VX378-U2-4).
  PROVISIONAL P-VX309-U2-5. Pins `U2WordsTests` (item 5's two RED ON OLD — `✘ Test run with 8 tests in 2 suites failed …
  with 10 issues`, with `OtherLibrariesDeleteRoadTests`' count pin FLIPPED DELIBERATELY; item 7's three new API, red by
  construction — no pin compiling on the old tree can feed a posture to a confirm that never read one: the old lead said
  *in Standard* for every library, a Castle one too); the harness's piece-4 suites `✔ Test run with 36 tests in 7 suites
  passed`. MUTATIONS on `f9b01dc6f` (each restored `cmp`-identical): M-4a the way-back sentence never said → `✘` (2); M-4b
  the posture ignored → `✘ theMakeMineLeadIsConcretePerShape` (3); M-4c `openMakeMine` drops the shape → `✘
  theConfirmReadsTheOpenLibrarysShape` (1); M-4d the older-libraries line on any listing → `✘ theListingSays…` (1).
- Piece 5 — VX-263's route-finder sentence: DONE (`c902c263c` pin first · `e7a182661`). R-U2-5 below. `keyDoorsLine` (the key
  doors' one line, and beneath New Words' door) is the rules' ledger sentence fitted: *Every copy of this library opens with
  your current passphrase or words; on this Mac, its quiet road opens it too, if it still holds that copy's key.*
  PROVISIONAL P-VX309-U2-6. U3's plan-pinned test FLIPPED DELIBERATELY to read `notes/CastleRules.md`
  (`RoadKeyDoorWordsTests.vx263sOneLineIsTheRulesRouteFinderSentence`) — RED ON OLD `✘ … 4 issues`; the key-door suites
  `✔ Test run with 39 tests in 5 suites passed`.
- Piece 6 — VX-211, "FLOOR + QUIET HINT": DONE (`385017df2` floor pins first · `f60eab50d`). R-U2-6 below. THE FLOOR
  (`NewPassphraseRule.floorRefusal`, `SetPassphraseModel.swift` — today's road's one number and sentence, `ProtectionCopy
  .passphraseFloor` / `.passphraseTooShort`; today's order: the floor, then the match) on the new road's four setters:
  `SetPassphraseModel` (the sheet and the tour's last card), `RoadCrossingConfirmModel`'s new passphrase,
  `RoadAccountConfirmModel`'s new passphrase, `RoadKeyDoorConfirmModel` (both presses; Change's CURRENT field never floored).
  THE QUIET HINT: the pure Domain estimator `PassphraseStrength.advice` (CORE, `Domain/PassphraseStrength.swift` — repetitive:
  fewer than 6 different characters, case folded, spaces aside; short: fewer than 20 characters; else nothing; an empty field
  nothing) and its one calm line (`ProtectionWords.passphraseHint` — the brief's example for the short shape, PROVISIONAL
  P-VX309-U2-7) under every field that SETS a passphrase (`PassphraseHintLine` in the set sheet, the key doors, a crossing's and
  turning sync on's new passphrase; the tour's last card in its own voice). Never a block, never a meter, no colour. Pins
  `PassphraseFloorRoadTests` (6): the floor RED ON OLD `✘ Test run with 4 tests in 1 suite failed … with 10 issues` (each of the
  four took 11 characters to its road); the hint is advice, never a block; the five homes by source. `PassphraseStrengthTests`
  (core, 4, exact). JUSTIFIED EDITS: nine suites' new-passphrase fixtures lifted above the floor (1-character passphrases now
  meet it — one, `ProtectionSheetPresenterTests`' act-gate wait, SPUN FOREVER on the refused press until lifted: a whole-harness
  run hung for 30 minutes under my own process, found by `sample`, the process killed, the fixture lifted). The whole harness
  `✔ Test run with 338 tests in 57 suites passed after 6.241 seconds.`; `build-for-testing` green. MUTATIONS on `f60eab50d`
  (restored `cmp`-identical): M-6a no floor → `✘ … 10 issues`; M-6b the Touch ID press unfloored → `✘ … 2`; M-6c the repetition
  arm dropped (core) → `✘ repetitionOutranksLength` (4); M-6d no hint → `✘ theQuietHintIsAdviceNeverABlock` (2).
- Piece 7 — THE FIELD GUIDE'S PROTECTION CHAPTER + DATA SAFETY'S WORDS ON THE NEW ROAD: DONE (`7da5ad2fc`). THE GUIDE: "keeping
  it private" re-seeds as three lessons on the new road only — *Your key and your twelve words* (LEADS with the readme's four
  Start Here passages verbatim, `ReadmeSeeder.startHerePassages` — one text, two homes; then VX-204's approved sync sentence +
  `privacyServerSeesShapeSentence`, `keystoneAccountPassword`, and what open means with the lock's door by its name), *Standard
  and Castle* (one posture at a time; rule 9's promise and rule 12's leave sentence, hers, verbatim; the follow; what you must
  keep; the floor as built), *Copies, backups and your way back* (rule 5's sentence — one text with the pane; retention's
  numbers as built, 14 · 14 + 4; Look inside / Make this my library by their own names; rule 17's sentence, hers; her item-5
  older-library words; VX-210's line; the plain-text roads out and back). The export lesson's two backup paragraphs say a
  PAIR and one-a-day in the picked folder (P-VX309-U1a-2). VX-209's older-copy warning retires on this road (a copy lands in
  the posture of now — rule 17). The gate is the readme's own: `TutorialSeeder.plan(onTheNewRoad:)` / `seed(… onTheNewRoad:
  = false)`, `restore` reading `ProtectionRoad.opensOnTheNewRoad(devStore: session.storeVariant == .dev)` (the birth seed and
  Help's restore both go through `restore`; in production the session's variant IS the bootstrap's, the one `LaunchFurniture`
  hands the readme). Today's road, Release included, seeds copy §7's chapter byte-unchanged. SEEDER ONLY — no store touched; the
  truth-check and the real store's re-seed ride VX-329. DATA SAFETY (behind `roadStanding != nil`; today's road unchanged): the
  counts are this Mac's pairs of this library (F-U1a-3 / VX-397), rule 5's sentence with VX-263's quiet-road clause (F-U2c-4),
  and the picked folder's caption gains *One copy a day goes there — a second Back Up Now on the same day adds one beside your
  library only.* PROVISIONAL P-VX309-U2-8 (the chapter) · P-VX309-U2-9 (the pane's lines). Pins `U2WordsTests` +3 (headless):
  the chapter says the rules as built (her sentences by constant, the numbers, the doors by name, nothing retired, nothing
  shouted, the two-register pattern — restated locally since `CopyRegisterPinTests` is Mac-only); the pane's lines; the faces by
  source (the pane's gate, the seeder's gate) — new API, red by construction on the old tree. Mac pin `TutorialNewRoadChapterTests`
  (3 — BUILT, its run the orchestrator's on the stage): the plan swaps only the privacy chapter; the DEV variant's restore seeds
  exactly `plan(onTheNewRoad: true)` with every paragraph, the export lesson's new words and none of today's; the REAL variant's
  keeps today's plan, VX-209's warning and none of the new road's words. Harness `✔ Test run with 9 tests in 1 suite passed`
  (U2WordsTests); `build-for-testing` `** TEST BUILD SUCCEEDED **`. MUTATIONS on `7da5ad2fc` (each restored `cmp`-identical to
  `u2-prerevert/p7/`): M-7a the pane's gate dropped → `✘ theNewRoadsLinesAreRenderedOnlyThere` (1); M-7b `restore` hard-wired to
  today's road → `✘ theNewRoadsLinesAreRenderedOnlyThere` (1 — the Mac pin's dev arm reds on the same revert, by its recipe
  R-U2-7-gate); M-7c rule 9's promise dropped from the postures → `✘ theGuidesNewRoadChapterSaysTheRulesAsBuilt` (1).
- Piece 8 — VX-213's SHARE: DONE (`e4d840c8b`; records only — no `Server/` line, no SQL, no test). R-U2-7 below. The S1
  record (`notes/plans/run-b-stress-pass.md`) gains a dated in-place correction note under Q1 (kp2 sits in Supabase Vault
  since 13y — `12_phase13y_tenant_seq.sql:626/:683`, `17_phase_vx307_vault.sql:238`, re-read today: "retains only
  `SHA-256(kp)`" is no longer true; the class — integrity/availability, never confidentiality — unchanged), Q2 (the
  delivered arm-10 pin reads file 12's body while `13_phase13i_wings.sql:479` redefines `sync_reencrypt`; 13's body carries
  the gate at :509 and no later file redefines it — re-read today; the pin's fix ROUTED, F-U2-6) and Q6 (the heal DOES fire
  after a reset with three devices; an Apple-ID switch on two devices re-homes the vault copy silently), plus one line under
  its verdict summary; every original sentence kept as written. The VX-191 record's §V tidy-up row gains a dated note
  pointing at them (and saying `pg_temp` is held). The delta brief gains the account-deletion fact in plain words —
  Supabase's own sign-in audit log (email, IP) outlives a deleted account — with what the repo shows (`account_purge`
  deletes the `auth.users` row; no `Server/` line names the audit log) and what VX-329 confirms (the log's contents and
  retention, outside the repo; no live lookup in this unit), plus one caution line.
- Piece 9 — U1a–U1c's UNDRAFTED WORDS, ONE PASS: DONE (`1b188af99`). The voice is §7c's (her drafted confirm and receipt,
  `makeMineLead` / `makeMineReceipt`): each new line takes §7c's own sentence where one fits and its shape where none does.
  T-5 — the lead (*This copy becomes your library — a new library, in Standard, with a fresh key of its own. Enter the copy's
  twelve words and they become your library's words, and you can set a passphrase after; or enter its passphrase and it
  becomes your library's, with new twelve words offered once the library opens. The copy itself is not changed.* — the pair
  the landing keeps AS BUILT: `EmptySlotMakeMineProgram` keeps no passphrase beside typed words); the receipt is §7c (9)'s first
  sentence, *This is your library now.* The empty-slot listing — the lead is `restoreListLead`'s sentence minus its step-aside
  clause; the empty line *Variorum isn't keeping any copies on this Mac.* (scoped to Variorum's own folders, so VX-210's line
  beneath never contradicts it). T-8 — the lead in §7c (8)'s shape with the ruling in ONE line (*Its notes and their takes,
  books, chapters, snippets and tags come in, written fresh; its commits, comments, note versions, book settings, stars and
  shelves don't.* — the document format carries no commits or comments, versions never ride) and §7c (8)'s own step-aside
  clause when a library is open; the earlier-build refusal in `LibraryOpenCopy.newerSchemaRefusal`'s shape; the unreadable-note
  refusal says *so nothing was brought in* (it refuses at the preflight); the receipt in §7c (9)'s shape (*This is your
  library now, made from the plain-text copy: …* + the empty books + *The previous one is in Previous Libraries.* when one
  stepped aside — `bringInReceipt(_:stoppedEarly:steppedAside:)`, the bootstrap passing `open != nil`, the lead's own test).
  The delete door — the door, title, button, working line and failure READ AND KEPT; the lead's opening and the receipt name
  the device through `ProtectionCopy` (*this Mac's copies of the library last copied …*); VX-210's line one plain line (the
  colon split into two sentences). `bringInButton` / `bringInWorking` kept. The guide's plain-text paragraph follows the
  lead's list. All PROVISIONAL P-VX309-U2-10. Pins `U2WordsTests` +4 (each line as re-drafted, §7c's sentences by constant,
  the register over every line of the pass) — RED ON THE AS-DRAFTED WORDS (the old strings under the new seam, `u2-prerevert/p9/`,
  restored `cmp`-identical) `✘ Test run with 18 tests in 2 suites failed after 0.675 seconds with 14 issues.`; red by
  construction on the pre-piece tree (`steppedAside:`). FLIPPED DELIBERATELY: `PlaintextExportBringInRoadTests`' receipt pin
  (headless) and `PlaintextExportBringInRouteTests`' (Mac — both arms now: the open library's receipt names Previous Libraries,
  the missing face's never; BUILT, its run the orchestrator's; recipe R-U2-9-aside: the bootstrap's `steppedAside: open != nil`
  → `false` reds the open arm). The harness `✔ Test run with 32 tests in 5 suites passed` (U2WordsTests ·
  PlaintextExportBringInRoadTests · OtherLibrariesDeleteRoadTests · EmptySlotLandingRoadTests · PreviousLibrariesArcTests);
  `build-for-testing` `** TEST BUILD SUCCEEDED **`.
- Piece 10 — RIDER VX-453 (Settings search surfaces the account section): DONE (`fd99e5c22` pins first · `88a18be02`).
  R-U2-8 below. The new road's Settings ▸ Protection ▸ Sync section joins the search through the existing seam: ONE catalog
  row (`SettingsCatalog.accountRow` — id `account`, pane Protection, title `ProtectionWords.accountSectionTitle`, the
  section's own title; "account" leads its keywords, with the doors' words — sign in/out, log in, email, turn on sync, stop
  syncing, other device, follow, move; blurb + keywords PROVISIONAL P-VX309-U2-11) declared beside the pane's own row and
  rendered there. The catalog, the rendered map and the index each take the road — `SettingsCatalog.rows(newRoad:)`,
  `AppSettingsView.rowIDsRendered(newRoad:)`, `SettingsSearch.settingsEntries(newRoad:)` / `wholeIndex(newRoad:)` — and the
  build's statics read `ProtectionRoad.newRoadIsLive`, so Release keeps `everyRoadsRows` / `everyRoadsRowIDs` byte for byte;
  the results pane asks with the window's road (`newRoad: roadStanding?.account != nil`). Pins: `SettingsAccountSearchTests`
  (2, old API, pinned FIRST) — RED ON THE PRE-FIX TREE in a scratch settings harness (`scratchpad/settings-harness`:
  `SettingsShape.swift` symlinked, the copy titles stubbed at their real values, the ⌘/ helper's two lists EMPTY — the Mac
  run reads the real ones; grep shows neither list says account, sign in, email or sync) `✘ Test run with 2 tests in 1 suite
  failed after 0.008 seconds with 11 issues.` ("account" and every door word found nothing; "sync" led with a row that only
  mentions syncing; the nothing-lost-or-reordered bound green on both sides), green after `✔ Test run with 2 tests in 1 suite
  passed`; `SettingsAccountSurfaceTests` (3, Mac, new API — BUILT, the run the orchestrator's: today's road keeps its catalog,
  the new road adds ONE row beside Protection's; declared ⇔ rendered on both roads; the results pane asks for the window's road,
  by source). One honest limit: "sign in" ALSO matches the Theme row's own search words ("design voice" holds "sign",
  "terminal" holds "in") at the same rank, which the catalog's order breaks — so the door words are pinned as FOUND, "account"
  as FIRST. `build-for-testing` `** TEST BUILD SUCCEEDED **`. MUTATIONS on `88a18be02` (restored `cmp`-identical to
  `u2-prerevert/p10/`): M-10a the row never joins → `✘ … 11 issues`; M-10b "account" dropped from the keywords → GREEN (the
  blurb says "your account" too — the row is found either way; recorded, not a hollow pin: the pin's claim is the finding,
  which two texts carry).
- Piece 11 — THE RECORD: DONE (this close commit; it changes only this file).
- No revert is in flight (every mutation and behavioural revert of this unit ran on a committed tree and was restored
  `cmp`-identical from `scratchpad/u2-prerevert/` — the in-worktree hold dir `App/Variorum/DerivedData/u2-hold/` used once at
  piece 3 and removed).

**THE CORE LINES, LINE BY LINE (for the Fable ladder — `git diff 4a3c867cd -- Sources/`; custody ⇒ Fable):**
- `Sources/VariorumCore/Protection/Executor/Acts/AccountActs.swift` (+33/−3, piece 1 — VX-456; READS only). In `join`:
  `sameWords` was "the typed WORDS open the library's own words lock"; it is now that OR
  `ProtectionExecutor.wordsAreTheAccountsAlready(liveFile, vault:, master:)` — `liveFile` is the library's key file only when its
  fingerprint is the library's key's (`library.keyFile?.fingerprint == library.fingerprint`); `master` is
  `VaultModel.master(of:passphrase:words:)` — what the typed secret reached in the vault (nil ⇒ false). The rule (static, pure over
  values): the file carries NO words lock of its own (`file.words == nil`), its `masterWordsCopy` equals the vault's
  `masterByWords` byte for byte (RFC 3394 deterministic; the copy is the vault's recovery wrap, copied — §3.5a), and its master
  lock opens under `master`. Effect: `parameters.wordsReplaced = !sameWords` — the moment (rule 7's sentence / her email draft)
  stays quiet on a join whose words already are the account's. It writes nothing, changes no act's steps, no lock, no secret;
  only `wordsReplaced` (a report flag the faces read). The arm it cannot prove (an own words lock beside a matching copy — the
  account's first device) answers false and the moment speaks (true either way) — P-VX309-U2-1. Pins `JoinWordsMomentTests` (8).
- `Sources/VariorumCore/Domain/PassphraseStrength.swift` (+37, NEW, piece 6 — VX-211's estimator): `PassphraseAdvice {none,
  short, repetitive}`; `advice(_:)` — empty → none; fewer than 6 different characters (case folded, spaces aside) → repetitive;
  fewer than 20 characters → short; else none. Pure; `PassphraseStrengthTests` (4, exact). No refusal reads it (the floor is
  the app's `NewPassphraseRule`, today's constants).

**THE APP LINES AS BUILT (for the ladder — `git diff 4a3c867cd -- App/`):** piece 1 — `ProtectionWords.joinWordsNotShown(_:)`
(her draft; nil email → "your account's"), `RoadAccountDoorOpen.accountEmail` (join + Move, from the sign-in), the sheet's
`.notShown` arm. Piece 2 — `FollowDoneMark` + `ProtectionAccountRoad.owed(after:request:)` (`ProtectionAccountActs.swift`),
`RoadStandingFaces.derive` no longer owes the follow's receipt, `RoadStandingModel.make` marks from `report.settledFollow`,
`RoadAccountModel.followDone` / `followDoneOK()`, the bootstrap's press arm (`accountActOnNewRoad`) and roads, the section's
notice + OK. Piece 3 — `moveNotYet`. Piece 4 — `deleteCopiesCounts` / `deleteCopiesWayBack` / `olderLibrariesLine`,
`CopyDoorsListing.listsAnOlderLibrary`, `OpenLibraryShape` + `CopyDoorsRoads.libraryShape` (the bootstrap's from the session),
`MakeMineModel.shape`, `makeMineLead(posture:passphraseSet:synced:)`, `neverLeaveCastle`, `makeMineSyncedLine`. Piece 5 —
`keyDoorsLine`. Piece 6 — `NewPassphraseRule` (`SetPassphraseModel.swift`) read by `SetPassphraseModel`,
`RoadCrossingConfirmModel`, `RoadAccountConfirmModel`, `RoadKeyDoorConfirmModel` (both presses); `passphraseHint`;
`PassphraseHintLine` (the set sheet) in the four sheets + the band card. Piece 7 — the guide's section + Data Safety's three
lines in `ProtectionWords`; `TutorialSeeder.plan(onTheNewRoad:)` / `seed(… onTheNewRoad:)` / `restore`'s gate; `DataSafetyPane`
behind `roadStanding != nil`. Piece 9 — U1's lines re-drafted; `bringInReceipt(_:stoppedEarly:steppedAside:)` + the bootstrap's
`steppedAside: open != nil`. Piece 10 — `SettingsCatalog.rows(newRoad:)` / `accountRow` / `everyRoadsRows`,
`AppSettingsView.rowIDsRendered(newRoad:)` / `everyRoadsRowIDs`, `SettingsSearch.settingsEntries(newRoad:)` /
`wholeIndex(newRoad:)`, the results pane's `newRoad:`.

**COUNTS (the final code tree — `0a5277c92`; this close commit changes only this file):**
- HEADLESS HARNESS (U1a's scratchpad `u1-harness`, re-pointed at this worktree; it now also symlinks U2's three headless suites
  `FollowDoneNoticeTests`, `U2WordsTests`, `PassphraseFloorRoadTests`): **`✔ Test run with 345 tests in 57 suites passed after
  5.985 seconds.`** (the baseline 319/54 + 26/3: `U2WordsTests` 13, `FollowDoneNoticeTests` 6, `PassphraseFloorRoadTests` 6,
  `ProtectionJoinFollowRoadTests` +1).
- SCRATCH SETTINGS HARNESS (`scratchpad/settings-harness`, piece 10 only — `SettingsShape.swift` + `SettingsAccountSearchTests`
  symlinked; the copy titles stubbed at their real values; the helper's lists empty): **`✔ Test run with 2 tests in 1 suite
  passed`**; on the pre-fix tree `✘ … 11 issues`.
- CORE: the protection set (every `@Suite` type under `Tests/VariorumCoreTests/Protection` — 90 — plus `PassphraseStrengthTests`;
  the filter re-derived from the files) Debug **`✔ Test run with 385 tests in 91 suites passed after 6.836 seconds.`** (U1c's
  373/89 + `JoinWordsMomentTests` 8 + `PassphraseStrengthTests` 4); Release (`swift test -c release`, the same filter) **`✔ Test
  run with 361 tests in 87 suites passed after 4.159 seconds.`** (349/85 + 12/2). THE FULL CORE SUITE, Debug (`swift test`):
  VariorumCoreTests **`✔ Test run with 3365 tests in 440 suites passed after 201.898 seconds.`** (3353/438 + 12/2); the third
  target `✔ 40 tests in 6 suites`; VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — the recorded VX-353 flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 19.2 s vs 15 s under the parallel
  run); ALONE `✔ Test run with 3 tests in 1 suite passed after 2.185 seconds.` No MCP line in this diff.
- RED ON THE PRE-FIX TREES (pins committed first): piece 1's core `✘ … 2 issues` (`9ed104688`) and the planted road's
  behavioural revert `✘ … 1 issue`; piece 2 `✘ … 3 issues`; piece 3 `✘ … 5 issues`; piece 4 `✘ … 10 issues`; piece 5 `✘ … 4
  issues`; piece 6 `✘ … 10 issues`; piece 9 (the as-drafted words under the new seam) `✘ … 14 issues`; piece 10 `✘ … 11 issues`;
  every other new pin is NEW API — red by construction. MUTATIONS (each on a committed tree, restored `cmp`-identical): M-456a..c,
  M-457a..c, M-4a..d, M-6a..d, M-7a..c, M-10a — every one red at its own pins; M-10b GREEN, recorded (piece 10's line).
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
  -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (after every
  piece; the one warning in a touched file — `AppSettingsView.swift:1268`, `spec(paths:joinAll:)` — is 2026-07-18's, not this
  unit's); the phone `-scheme VariorumMobile -destination 'generic/platform=iOS Simulator' … build` → **`** BUILD SUCCEEDED **`**;
  **the Release check `-configuration Release build` → `** BUILD SUCCEEDED **`** (into `DerivedData/vx309-release` —
  `/Applications` untouched). All three on `0a5277c92`.
- Release behaviour: unchanged by construction — every new face and line is reached only from the new road: the join moment, the
  follow's Done, Move, the make-mine confirm, the key doors, the crossings, the account section and the set-passphrase sheet are
  the new road's faces (`RoadStandingModel`, `copyDoorsRoads*`, `accountRoads` exist only there); the floor and hint read in the
  new road's models only (today's road keeps its own floor, `ProtectionCopy.passphraseFloor`, untouched); the guide's new chapter
  seeds only where `opensOnTheNewRoad` (false in Release); Data Safety's lines behind `roadStanding != nil`; the Settings row
  behind `ProtectionRoad.newRoadIsLive` (false in Release) and the window's road.

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309 test \
  -only-testing:VariorumTests/TutorialNewRoadChapterTests \
  -only-testing:VariorumTests/SettingsAccountSurfaceTests \
  -only-testing:VariorumTests/SettingsAccountSearchTests \
  -only-testing:VariorumTests/RoadJoinFollowSurfaceTests \
  -only-testing:VariorumTests/PlaintextExportBringInRouteTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/RoadKeyDoorSurfaceTests \
  -only-testing:VariorumTests/RoadAccountSurfaceTests \
  -only-testing:VariorumTests/U2WordsTests \
  -only-testing:VariorumTests/FollowDoneNoticeTests \
  -only-testing:VariorumTests/PassphraseFloorRoadTests \
  -only-testing:VariorumTests/ProtectionJoinFollowRoadTests \
  -only-testing:VariorumTests/RoadJoinFollowWordsTests \
  -only-testing:VariorumTests/RoadJoinFollowModelTests \
  -only-testing:VariorumTests/RoadJoinFollowFacesTests \
  -only-testing:VariorumTests/RoadKeyDoorWordsTests \
  -only-testing:VariorumTests/OtherLibrariesDeleteRoadTests \
  -only-testing:VariorumTests/OtherLibrariesDeleteRouteTests \
  -only-testing:VariorumTests/PlaintextExportBringInRoadTests \
  -only-testing:VariorumTests/EmptySlotLandingRoadTests \
  -only-testing:VariorumTests/EmptySlotMakeMineRouteTests \
  -only-testing:VariorumTests/EmptySlotDoorsSurfaceTests \
  -only-testing:VariorumTests/CopyListingFacesSurfaceTests \
  -only-testing:VariorumTests/PreviousLibrariesArcTests \
  -only-testing:VariorumTests/MakeMineRoadTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/RoadAccountModelTests \
  -only-testing:VariorumTests/RoadKeyDoorsModelTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionSheetPresenterTests \
  -only-testing:VariorumTests/ProtectionAccountRoadTests \
  -only-testing:VariorumTests/RoadAccountWordsTests \
  -only-testing:VariorumTests/RoadAccountFacesTests \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/DataSafetyRoadCountsTests \
  -only-testing:VariorumTests/DataSafetyTests \
  -only-testing:VariorumTests/DataSafetyFacesTests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/SettingsShapeTests \
  -only-testing:VariorumTests/CommitVocabularyTests \
  -only-testing:VariorumTests/DeadVocabularyTests \
  -only-testing:VariorumTests/TutorialWalkTests \
  -only-testing:VariorumTests/TutorialBooksChapterTests \
  -only-testing:VariorumTests/TutorialMCPChapterTests \
  -only-testing:VariorumTests/TutorialCurrencyTests \
  -only-testing:VariorumTests/TutorialBuildFlavorTests \
  -only-testing:VariorumTests/VX209GuideWarningTests \
  -only-testing:VariorumTests/LaunchFurnitureTests \
  -only-testing:VariorumTests/ReadmeStartHerePlanTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first eight are U2's Mac-only suites (3 + 3 + 2 new; the flips and fixture lifts in the next five); then U2's headless suites
(green in the harness) and the suites over the files this unit touched — the join/follow and account roads, the copy doors and
their listing, the make-mine confirm, the key doors and crossings (the floor), the reminder and the band (the hint), Data Safety,
the Settings catalog and search, the guide's seed (every tutorial suite — they read today's `plan`; a `.real` session seeds
today's edition, so they are unchanged), the readme's gate, the words plan pins and the source scans. A source-needle check over
every Mac source-reading pin naming a touched file found every needle in place (`scratchpad` script; the only unmatched needles
are runtime-string checks over constants this unit did not touch).

**THE RED-ON-OLD BY BEHAVIOURAL REVERT for the Mac-only suites (the orchestrator's, each from a committed tree, restored by `git
checkout --`):**
- **(R-U2-7-gate)** in `TutorialSeeder.restore(session:existing:)`, `onTheNewRoad: ProtectionRoad.opensOnTheNewRoad(…)` →
  `onTheNewRoad: false` → `TutorialNewRoadChapterTests.theDevStoresGuideSeedsTheNewRoadsChapter` RED.
- **(R-U2-7-seed)** in `TutorialSeeder.seed`, `if onTheNewRoad {` → `if false {` → the same pin RED (the plan pin stays green —
  it reads `plan(onTheNewRoad:)`).
- **(R-U2-7-fence)** `ProtectionRoad.opensOnTheNewRoad(devStore: session.storeVariant == .dev)` →
  `ProtectionRoad.newRoadIsLive` → `theRealStoresGuideKeepsTodaysChapter` RED.
- **(R-U2-9-aside)** in `AppBootstrap.bringInPlaintextExport`, `steppedAside: open != nil` → `steppedAside: false` →
  `PlaintextExportBringInRouteTests.fromAnOpenLibraryTheExportLandsAsANewLibraryReadyNeverHeld` RED; `→ true` →
  `fromTheMissingFaceTheExportLandsAsANewLibrary` RED.
- **(R-U2-10-window)** in `AppSettingsView`'s results pane call, `newRoad: roadStanding?.account != nil` → `newRoad: true` →
  `SettingsAccountSurfaceTests.theResultsPaneAsksForTheWindowsRoad` RED (by source); `SettingsCatalog.rows(newRoad:)`'s guard →
  always adds → `todaysRoadKeepsTodaysCatalogAndTheNewRoadAddsOneRow` and `theRowIsRenderedWhereItIsDeclared` RED.
- **(R-U2-10-old)** `SettingsAccountSearchTests` compiles on `fd99e5c22`'s parent tree — run it there: RED (11 issues headless).
- The two `RoadJoinFollowSurfaceTests` flips (piece 2): revert `RoadStandingFaces.derive` to owe the follow's receipt and drop
  `RoadStandingModel.make`'s mark → both RED (they read `account.followDone` after the reopen, and no receipt).

**WALK NOTES FOR THE ACCEPTANCE SPINE (the orchestrator's ONE phase walk — the DEV store only, under a held claim, both voices
wherever a face renders):**
- **The join moment (piece 1) + VX-456.** On the throwaway project (VX-308's walk switch), a library joining an account by its
  PASSPHRASE: the moment says *Your twelve words are <the email>'s twelve words. If you don't have your account's words written
  down, you can make new ones at any time.* — capture (light, dark). Then This Mac Only and a re-join by the same passphrase: NO
  moment (VX-456: the file proves the words are the account's). Signed out at the end; the Debug app never signs into her real
  account.
- **VX-457.** A follow that lands (the throwaway's second device is the walk machinery's): the account section shows VX-107's
  sentence with *OK*, through a quit and relaunch, and with Settings ▸ General ▸ Confirmations set to off; *OK* clears it.
- **moveNotYet (piece 3).** Signed in as another account than the library's: Move's line names the road (*sign out, choose Use
  this Mac only, then sign back in to that account and turn on sync …*).
- **Item 5 + item 7 (piece 4).** Data Safety ▸ Restore from Backup with a Previous Library listed: her older-libraries line under
  the listing; *Delete…* on a stepped-aside throwaway: the confirm counts *…, plus 1 older library Variorum kept when you opened
  or restored a different one.* and her way-back sentence. Make this my library on a copy while in Castle (the dev library's LOCAL
  Use Castle, VX-308's machinery; Standard restored after): the lead says *in Castle* and *You never leave Castle by opening
  something.* — capture. Synced (the throwaway): the lead ends with the synced line.
- **VX-263 (piece 5).** The key doors' line and beneath New Words: *Every copy of this library opens with your current
  passphrase or words; on this Mac, its quiet road opens it too, if it still holds that copy's key.*
- **VX-211 (piece 6).** On a throwaway with no passphrase: Set a passphrase… with 11 characters → *Your passphrase needs at least
  12 characters.* (today's sentence); 12–19 characters → the quiet line *Short passphrases are easier to guess — a longer phrase
  is stronger.* and the set LANDS; "aaaaaaaaaaaaaaaaaaaa" → the repetition line; a 20+ character varied phrase → no line. The
  same on Change passphrase…'s new field and turning sync on with a new passphrase. No colour, no meter.
- **The guide (piece 7).** ONLY on a throwaway slot (never the dev library's own guide — the brief's no-store-touch for this unit
  becomes the walk's choice): Help ▸ Restore Tutorial… → "keeping it private" holds *Your key and your twelve words* (the
  Start Here passages first), *Standard and Castle*, *Copies, backups and your way back*. Data Safety on the new road: the counts
  line, rule 5's sentence, and with a picked folder the one-a-day caption — capture both voices.
- **Piece 9.** T-5 (U1b's walk recipe): the confirm's new lead, the receipt *This is your library now.*; the empty-slot listing's
  lead and (on an empty throwaway home) *Variorum isn't keeping any copies on this Mac.*; T-8 from an open throwaway: the new lead
  and the receipt ending *The previous one is in Previous Libraries.*; the delete confirm's opening *This deletes this Mac's copies
  of …*; VX-210's line in its two sentences.
- **VX-453 (piece 10).** Settings search: "account" → the Sync row (Protection) first; click → the Protection pane with the Sync
  section; "sync" → the Sync row first, then what it found before.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared ledger is
the merging session's):**
- **P-VX309-U2-1 — VX-456's provable arm:** (a) BUILT — quiet only when the key file has no own words lock and its words copy is
  the vault's recovery wrap byte for byte with the master lock opening under the account's master; the account's first device
  (its own lock stands beside a matching copy) hears the moment once on a passphrase re-join; (b) compare the own lock's wrap too
  (it is salted per lock — no identity to compare; would need a stored marker); (c) record "words handed up" in the key file
  (a format change — not this unit's).
- **P-VX309-U2-2 — the join moment with no email at hand:** (a) BUILT — *your account's twelve words*; (b) say nothing.
- **P-VX309-U2-3 — the words-typed moment keeps rule 7's own sentence** (canon, pinned to the rules file): (a) BUILT — her
  draft replaces only the passphrase-typed notice; (b) her email direction also rewords rule 7's phrase (a rules change — hers).
- **P-VX309-U2-4 — moveNotYet's two presses fitted to the faces** (This Mac Only renders only signed out): (a) BUILT.
- **P-VX309-U2-5 — item 7's concrete lead says the posture the copy LANDS in** (rule 17), never the copy's own former posture
  (only its key file speaks of that, and an Apple lock there is no reliable posture fact): (a) BUILT; (b) also say the copy's
  own posture when its key file proves it.
- **P-VX309-U2-6 — VX-263's sentence fitted** (*… on this Mac, its quiet road opens it too, if it still holds that copy's key.*)
  superseding U3's line in its hosts: (a) BUILT.
- **P-VX309-U2-7 — the hint's words and thresholds** (short < 20 characters; repetitive < 6 different characters): (a) BUILT.
- **P-VX309-U2-8 — the guide's new-road chapter** (three lessons; VX-209's older-copy warning retired on that road): (a) BUILT.
- **P-VX309-U2-9 — Data Safety's three new-road lines:** (a) BUILT.
- **P-VX309-U2-10 — U1a–U1c's words re-drafted in §7c's voice** (T-5, the empty-slot listing, T-8, the delete door's lead and
  receipt, VX-210's line): (a) BUILT; the door, title, button, working line and failure kept as drafted.
- **P-VX309-U2-11 — VX-453's row** (its blurb and keywords; road-gated by the build AND the window): (a) BUILT; (b) gate by the
  build only (a Debug build over the real store's variant would name a section its pane doesn't show).

**FINDINGS AND HAND-FORWARDS (routed, not fixed here unless said):**
- **F-U2-1 (her bundle — the middle clause):** §1 reads her note as allowing either arm; §5d rules the clause dropped because
  VX-456 lands in the same piece. Built §5d's. Her draft's middle clause (*If this is your first time signing in, your previous
  twelve words still open backups you made before today*) is true only on a real replacement — which is now exactly when the
  moment fires; if she wants it back, it is one line in `joinWordsNotShown`.
- **F-U2-2 (Bug, Suspected, Castle & sync, Low — a face):** the restore-hold banner's `hasAccount` reads whether this Mac is
  SIGNED IN, not whether the library is BOUND; after Make this my library while signed in (the new library carries no sync
  identity — P-VX378-U2-4) the banner says *Resume to catch up with your account* over a library that does not sync, and Resume
  only clears the hold (the VX-314 gate refuses a sync there). Fix shape: on the new road, `hasAccount` = the open library's
  record names an account. Not this unit's surface.
- **F-U2-3 (Wording, Settings & onboarding, Low):** the Settings catalog's Protection row blurb says *The passphrase, when the
  library locks, escrow and the recovery key.* — retired words on BOTH roads ("escrow" is in the two-register rule's forbidden
  list; "recovery key" is today's road's old name). Not changed (today's road's row — Release parity); a one-line reword.
- **F-U2-4 (VX-329 — the delta brief predates the rules):** `notes/stargazing-castle-rebuild-delta-brief.md` (2026-10-14) still
  states facts CastleRules superseded — the Castle anchor (Tier 2; the ledger: superseded by rules 4 and 12), a salted hash of
  the hardware (Tier 2 + the restore FAQ; rule 23: no hardware fingerprinting), the key history / each copy's *Opens with* line
  (rules 17 and 21; the route finder reduced to one sentence), Re-link's library arm. Its header already has VX-329 re-check
  every fact; the finding is that several need RE-WRITING against the rules, not re-checking. This unit added one fact only.
- **F-U2-5 (VX-353, known):** the full core run's one red is the recorded wall-clock flake; alone green.
- **F-U2-6 (Debt, Test-only, Castle & sync, Low — VX-213's tidy-up):** `MultiTenantSyncAttackerTests`' arm-10 text pin reads file
  12's `sync_reencrypt` body while file 13 is deployed (re-read 2026-10-20: 13's body carries the gate at :509; no later file
  redefines it). Fix shape: read the final body (`AuthRLSDDLTests.finalBody(of:)`). A test line — rides `pg_temp`'s window or
  any Sync-adjacent run.
- **F-U2-7 (VM — mobile parity):** the phone's guide (`MobileTutorialSeeder`) has no new-road protection chapter, and the phone
  has no new-road passphrase setter yet (so no floor or hint face) — its own epic's items when it gets the new road's faces.

**MOBILE PARITY:** NOTHING MOBILE-VISIBLE. The phone renders only these `ProtectionWords` lines — the lobby's (`lobbyTitle`,
`passphraseLabel`, `wordsPlaceholder`, `wordsButton`, `wordsDoor`, `touchIDButton`, `openButton`, `opening`, `rearmYes/No`), the
words card's (`wordsCardTitle/Lead/Foot/Button`), the offer's (`offerUseIt`, `offerNotNow`), the notice's `noticeOK`, and the
no-key-file / keychain lines (`noKeyFileAnywhere`, `noKeyFileAfterAQuietOpen`, `noKeyFileAnywhereAccountRoad`,
`noKeyFileStartDoor`, `keychainUnreadable`, `liveKeyFileUnreadable`) — NONE changed by this unit. The shared brains this unit
changed (`NewPassphraseRule`, `FollowDoneMark`, `OpenLibraryShape`, the `AppBootstrap` seams, `bringInReceipt`'s signature)
compile into the phone (its build green) and no phone face reads them; the phone's guide edition is its own, untouched
(F-U2-7 for the VM board).

**Notes:** no machinery deaths after the compaction; the one hang (piece 6 — a refused press spinning a test's wait, 30 minutes
under my own process) was found by `sample`, killed, and its fixture lifted; no Sonnet lookup; no subagents; no scratch worktree.
The harnesses are scratchpad-only (`u1-harness` — U1a's; `settings-harness` — piece 10's), never committed.

**U2 ARBITRATION (the orchestrator, 2026-10-20 — repo-first before the Mac batch and the ladder):**
- **F-U2-1 — FIXED AT ADJUDICATION (the commit above):** her note's own reading is that with VX-456 the previous-words
  CLAUSE "applies unconditionally" — the sentence STAYS, its conditional lead-in goes. §5d's whole-sentence drop was the
  ORCHESTRATOR'S misreading (recorded as such); the moment now reads *"Your twelve words are <email>'s twelve words.
  Your previous twelve words still open backups you made before today. If you don't have your account's words written
  down, you can make new ones at any time."* PROVISIONAL; her bundle carries both texts beside her note verbatim.
- **F-U2-2** (the hold banner's catch-up sentence over a library that doesn't sync): a TICKET at closeout (Bug,
  Suspected, Castle & sync, Low) with the fix shape named (`hasAccount` = the open library's record names an account,
  new road). It predates this phase (the banner is 13x's); the WALK expects the odd sentence after T-5/Make-mine and
  does not count it a walk failure.
- **F-U2-3** (the Protection row's blurb says "escrow and the recovery key" on both roads): NOT this phase's to change
  (a Release-visible wording line) — a COMMENT on VX-234 (her settings wording pass) at closeout.
- **F-U2-4** (the delta brief predates the rules — several facts need REWRITING, not re-checking): a COMMENT on VX-329
  at closeout.
- **F-U2-6** (the arm-10 pin reads file 12's body): a TICKET at closeout (Debt, Test-only, Castle & sync, Low), riding
  `pg_temp`'s window or any Sync-adjacent run.
- **F-U2-7**: the VM comment at closeout (the phone's guide chapter + passphrase faces when it gets the new road).
- **P-VX309-U2-1..11: each stands as built** pending her bundle; M-10b's green mutation is honestly recorded (the
  finding's claim lives in two texts — not a hollow pin).

**THE U2 MAC BATCH (the orchestrator, 2026-10-20 01:12–01:55 MDT, stage claim `vx-309-u2-mac`, the coordinator's GO;
logs `/tmp/vx309-u2-*.log`, deleted at closeout):** the record's list ran as `✔ Test run with 313 tests in 54 suites
passed` — FOUR of its 58 names were PHANTOMS (`DataSafetyTests`, `DataSafetyFacesTests`, `TutorialBooksChapterTests`,
`TutorialWalkTests` — suites that don't exist under those names; xcodebuild silently ignores an unmatched
`-only-testing`, so the first count's 54 was the tell). THE SUPPLEMENTARY BATCH with the REAL names — the whole
executable tutorial family (`Tutorial*ActsTests`, the chapter suites, `TutorialPrivacyChapterTests` — exactly the
chapter piece 7 re-seeds — the fold, door, shape and matrix suites) and Data Safety's real family
(`DataSafetyRunbookTests`, `SyncSafetyFaceTests`, `MarkdownInsuranceTests`, `BackupFutureStampTests`,
`BackupRunTests`): `✔ Test run with 146 tests in 20 suites passed`. ZERO real reds across both runs. THE REVERTS,
each from the committed tree, restored `cmp`-identical: R-U2-7-gate RED (11 issues), R-U2-7-seed RED (11),
R-U2-7-fence RED (the real-store arm, 18), R-U2-9-aside RED both arms (1 each), R-U2-10-window RED (3 pins, 5
issues), the two follow-receipt flips RED (6 issues); R-U2-10-old ran HEADLESS in the scratch settings harness over
the pre-fix `SettingsShape.swift` (one file swapped from `fd99e5c22~1` and restored `cmp`-identical — no separate
checkout, no xcodebuild) → `✘ … 11 issues`, the pre-fix red reproduced. The confirming re-run (the eight
Mac-only/flipped suites) `✔ Test run with 27 tests in 8 suites passed`; tree clean at the branch tip; 0 instances;
the stage released with the coordinator's result line. A LESSON for the record: a unit's Mac-suite list is verified
against the suite TYPES before the run from now on (the phantom names cost one supplementary batch).
**THE U2 MAC LEG IS CLOSED — the implementer era of the phase is done. NEXT: THE LADDER.**
