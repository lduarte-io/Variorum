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
