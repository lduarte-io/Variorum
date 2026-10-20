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

### U1b RECORD — THE COPY DOORS (Opus implementer, 2026-10-19; piece 0 F-U1a-1 · T-5 · VX-305's second hand-off · T-8 — IN PROGRESS)

**Not done in U1b, first:** (PENDING — this list is rewritten at the close.)
- No Mac suite RUN, no walk, no stage, no Debug launch, no store touch, no network, no Linear, no subagent (the brief).
- T-8's mapping waits on the orchestrator's ruling (the proposal gate — sent by SendMessage 2026-10-19; the proposal's text
  is restated under piece 3 below once ruled).

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
- **R-U1b-1 — T-5 IS A NEW CORE ACT, NO LIBRARY IN HAND.** (PENDING — written with piece 1.)
- **R-U1b-2 — PREVIOUS LIBRARIES THROUGH THE DOORS.** (PENDING — written with piece 2.)
- **R-U1b-3 — T-8.** (PENDING — the orchestrator's ruling on the mapping.)

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
- Piece 1 — T-5, the empty-slot landing: NOT-STARTED.
- Piece 2 — VX-305's second hand-off (Previous Libraries through the doors): NOT-STARTED.
- Piece 3 — T-8: NOT-STARTED — WAITING on the mapping ruling (proposal sent).
- Piece 4 — the close: NOT-STARTED.
- No revert is in flight.
