# VX-201 — Run: Castle pre-launch fixes (the record)

**Status: OPEN — kicked off 2026-10-13 (architect shape, Fable orchestrator; her kickoff message named the
pre-build assessment below as the first deliverable). Branch `vx-201-castle-prelaunch-fixes` (cut from
`origin/vx-191-encryption-audit`, main merged in at kickoff), worktree `~/dev/variorum-vx-201`, the Pro.**

**Binding principles:** the 13b constitution P-1…P-9 binds this run verbatim as carried in
`.claude/skills/architect-phase/SKILL.md` (in-repo; copied by pointer for record leanness — the one recorded
deviation from the copy rule). CLAUDE.md's standing rules, the author-only list, SyncSpec §12, and the
hallucination guard (pin-before-fix PER MEMBER, red-on-old verified by revert) bind as everywhere.
**Product frame (leads every brief):** this is the author's own writing app hardening its OWN privacy promises
before public release — when the app says Castle, nothing current may still open the old way. Defensive work on
her code, at her request.

## KICKOFF MESSAGE (paste into a fresh session)

> /architect-phase vx-201
>
> This is RUN VX-201, "Castle pre-launch fixes" — seven members, all from the VX-191 encryption & Castle audit,
> all ruled pre-launch by the author on 2026-10-12/13. **Product frame first** (it keeps the safeguards calm): this
> is the author's own writing app hardening its OWN privacy promises before public release — making sure that when
> a user turns on Castle, the app never says "Castle" while something current is still reachable the old way.
> Defensive work on her code, at her request.
>
> **Branch:** create `vx-201-castle-prelaunch-fixes` FROM `origin/vx-191-encryption-audit` (it carries the audit
> record you need), in a fresh worktree `~/dev/variorum-vx-201`. The one PR (`VX-201: …`, merge commit) carries both
> VX-191's record and this run.
>
> **Read first (after CLAUDE.md's preflight):** `notes/plans/fixes/vx-191-encryption-audit.md` WHOLE (§O.3, §V, §W,
> §W.1, §W.2, §X are the briefs), the three auditor reports under `notes/plans/fixes/vx-191-audit/`, `notes/SyncSpec.md`
> (custody seams), `notes/plans/pre-13x-postures-design.md` §1, §3.4, §4, §14, and this file. The Linear tickets carry
> her rulings as comments — read each member's comments.
>
> **Members (pin-before-fix PER MEMBER; red-on-old verified by revert):**
> 1. **VX-202** — the re-key reopen's detached `saveAuto(L′)` (`AppBootstrap.swift:520-530`) races the custody move's
>    `deleteAuto` (§O.3). Fix: no re-save while a switch marker is set / a switch is in progress; belts: a lingering
>    silent item under a DEMANDED gate is deleted at ready, never read as posture; the route's landing arm
>    (`StoreLaunchGate.swift:367-376`) never lands mid-switch. Pin at the BOOTSTRAP level (the existing pins inject
>    their own `rekeyLibrary` and never exercise the production reopen) with a held `saveAuto`.
> 2. **VX-110** — signed out with sync custody held, Use Castle offers TWO doors: **Sign In…** (the account-wide
>    switch) and **Use Castle on This Mac Only** (forget the old account's keys here via the existing
>    `EncryptionSession.forgetDeviceKeys`, then the local road, with an HONEST Done: this Mac's library is in Castle;
>    the old account's sync copy is unchanged — delete that account if you still can). Signing back into the old
>    Standard account then lands on the join consent (Join / Cancel), never a silent revert. Also: de-cap
>    "ACCOUNT" in `ProtectionCopy.joinStandardConsent` and give that sentence a wording pass (her no-caps rule).
>    A flat "refuse unless signed in" is WRONG — it traps the lost-account user (§W).
> 3. **VX-203** — the Castle "delete old backups" offer must also reach `Previous Libraries/*/` and
>    `Backups/safety-copies/*/` (Standard-era whole-library copies), or at minimum name them (auditor B1d).
> 4. **VX-204** — the field guide's "everything is encrypted" (`PostureCopy.swift:781`) overstates; dates, tag-tree
>    shape, memberships, flags and sizes travel plain (the website privacy brief already says so). One sentence.
> 5. **VX-206** — entering Castle (run from Settings ▸ Protection) must END on Protection with its info popup showing,
>    not on General.
> 6. **VX-208** — ONE line in the Castle process: plaintext `.md` exports written before Castle aren't covered — delete
>    them yourself. No delete offer of our own (her ruling).
> 7. **VX-209** — a Castle library silently becomes Standard after Open Library / Restore of a Standard-era backup or a
>    plaintext export — and even on the way BACK for a backup of the same library (§W.2's trace — verify it with a pin
>    before building on it). Pre-launch scope (her rulings): a **confirmation line** on the Open/Restore confirm when
>    the current library is Castle and the incoming one reads Standard, and a **field-guide warning** in the Castle
>    section with instructions for reading an old backup (today's honest instruction: afterwards check Settings ▸
>    Protection and choose Use Castle again — re-verify against the fix you land). The deeper fix (corner 45 must not
>    read a previously-Castle store id as Standard-waiting) is welcome if it falls out of VX-202's belts; else ticket it.
>
> **Copy is hers:** every NEW or changed user-facing sentence (VX-110's Done + consent, VX-204, VX-208, VX-209's
> confirm line + guide text) is drafted, bundled in `notes/QUESTIONS.md`, and presented to her before it ships —
> PROVISIONAL until she approves. Sentence case, no capitals for emphasis.
>
> **Cast & review:** strictly sequential per CLAUDE.md; members 1, 2 and 7 touch custody/keychain ⇒ the cold review is
> Fable (`fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim) over the whole run's diff; the author may redirect
> (VX-99 moved to Opus at her word when Fable's safeguards fired — lead every brief with the product frame above).
> Phone parity: the Castle doors are `Shared/` — the phone compiles and its faces get the same copy.
>
> **Environment:** this is the ONE `Sync/`-or-custody effort in flight — check the in-flight table and declare it;
> every `xcodebuild test` needs a held `Tools/stage` claim (an `oct12coordinator` may be scheduling the Pro stage —
> ask it). Headless `swift test` runs freely. Record: this file (`notes/plans/fixes/vx-201-castle-prelaunch-fixes.md`),
> LIVE STATUS from the first commit, push after each piece. Close with the `/Applications` refresh at a zero-instance
> window, the PR (merge commit), members closed individually, VX-191 closed with it.

## §A — PRE-BUILD ADVERSARIAL ASSESSMENT (the orchestrator, 2026-10-13 kickoff; her ask: a second layer over the audit agent's self-authored tickets, VX-110 and the backup-adoption roads especially)

Method: every ticket-cited code site re-read at this branch's HEAD by this orchestrator (not delegated, not
trusted from the audit record): `AppBootstrap.swift:526-531` (the detached R1-M3 re-save) and `rekeyLibrary`
(:810-841), `PostureSwitch.swift:521/:535` (the enrolled guard) and the local road (:693-700),
`EncryptionSession.forgetDeviceKeys` (:579-583), `StoreLaunchGate.effectiveGate`'s landing arm (:362-383) and
`rawKeyCustody` (corner 45). **Every cited mechanism is real as described.** The members stand; the refinements
below are BINDING on the briefs. Verdict per member:

**VX-202 (the reopen race) — CONCUR, with four binding refinements.**
1. *Coverage, not just the ceremony:* the ceremony, the follow (both arms) and the marker RESUME all reach
   `rekeyLibrary` → the same reopen → the same R1-M3 arm. The fix must cover every reopen that is part of a
   switch. An in-memory `switchInProgress` on `AppBootstrap` (set by `rekeyLibrary`, cleared after the runner's
   custody move) covers the live path; the persisted `RotationMarker` covers a crash-resume's reopen. Prefer both.
2. *Belt (b) safety:* the at-ready sweep (a lingering silent item under a DEMANDED effective gate is deleted,
   never read as posture) must key on the CURRENT store id and fire only when the silent item's key is NOT the
   only opener left — i.e. the live key file carries P/W wraps for it or the gated item verifies. Under custody
   law that is always true in Castle, but the belt must check, not assume (a hand-damaged key file must not
   become an unopenable library). It must also stay inert during a 13x adoption's deliberate `landCustody`
   window (dials there reset to Auto, so the gate is not demanded — verify with a pin, don't assume).
3. *Belt (c) reality check:* the route's landing arm runs PRE-OPEN — `RotationMarker` is a database read and
   cannot be consulted there. The belt needs a store-id-scoped signal outside the DB (the dials' UserDefaults
   home is the natural neighbor): written when a switch begins, cleared when custody lands. This same signal is
   the only cheap road to VX-209's deeper fix — see VX-209 below for why we do NOT stretch it that far tonight.
4. *The pin:* must exercise the PRODUCTION reopen (`AppBootstrap.rekeyLibrary` → `beginOpening` → ready → the
   R1-M3 arm) with the utility save HELD until after the custody move — red on old by revert. The existing
   switch pins inject their own `rekeyLibrary` leaf and prove nothing here (the audit's own observation,
   re-confirmed: `PostureSwitchTests.swift:763`, `PostureSwitchDrillTests.swift:478`).

**VX-110 (the two doors) — CONCUR with her ruled design; five things the ticket does not say, each binding.**
1. *Crash ordering is the whole game.* If the forget runs LAST and the session dies between the re-key and the
   forget, custody still holds the old account's material — the next sign-in to that account is the silent
   follow-into-Standard revert, the exact bug. The forget must happen EARLY in the This-Mac-Only road (before or
   atomically with the custody move) AND be carried by the marker's resume so no crash window leaves it undone.
   Pin the crash window (kill between re-key and forget; the resume completes the forget).
2. *`forgetDeviceKeys` keeps the device identity* (read at :579 — material goes, identity stays). That is the
   RIGHT shape: a later sign-in to the old account is an ENROLL (the join consent — `EncryptionViews.swift:431-466`),
   and the identity-only custody record keeps the route's landing arm SKIPPED (`enrolled = syncCustodyPresent`),
   so the Castle shape is protected at every later launch. Both facts get pins, not prose.
3. *Her multiple-accounts worry, answered structurally:* custody is per STORE ID and holds exactly ONE account's
   material (the last enrolled — decision 17's adopt road replaces it). So "the old account" is singular per
   library, and forgetting on this library never touches another library's custody. The brief demands a pin:
   two stores, two custody records, forget on one, the other intact. The remaining multi-account corner —
   sign-in to a NEW account after This-Mac-Only — takes the sync-setup road, and a Castle library's vault is
   born Castle (decision 17 + corner 26). The audit flagged that road as NEVER EXERCISED BY TESTS; the Done copy
   leans on it ("delete that account… set up again"), so U2 lands a state-transition pin for born-Castle setup
   from a Castle library, or the Done copy drops the implication.
4. *The gate for the two doors* is "signed out AND sync custody material held" — the state from which the silent
   revert is reachable. A signed-out library with an enrolled-SHAPED key file but NO custody material cannot
   silently revert (its sign-in is an enroll with consent), so it keeps the plain local road; a genuinely
   pre-sync library is untouched (the kickoff's own line). The Sign In… door routes to sign-in and ends the
   ceremony (re-press after signing in); auto-resuming a custody ceremony across an async sign-in is
   choreography risk for zero honesty gain — PROVISIONAL, bundled.
5. *The phone:* the runner and copy are `Shared/`, but the audit never read the phone's door conditions
   (`MobileProtectionSheet`). U2 confirms the phone's Use Castle door state when signed out and gives it the
   same two-door or refusal shape — never the old silent local road with the ordinary Done.

**VX-203 (the offer's missed folders) — CONCUR; three bounds.** (1) The lister offers only folders whose key
file carries an `apple` wrap — a Castle-era prior library in `Previous Libraries/` is not Apple-openable and
must not be swept into a "Standard-era" delete. (2) Granularity is the whole `<stamp>/` folder with honest
counts in the confirm, and the offer's words must say these are the step-aside/way-back copies (the adoption
confirm called them a recoverable home — deleting them closes that road; the sentence owns it). (3) The same
lister serves the follow road (B1d's rider). `Backups/safety-copies/` matching stays on the adopt-safety naming
plus key-file inspection — never a blanket folder delete.

**VX-204 (the guide sentence) — CONCUR, copy-only, one structural consequence:** the paragraph is SEEDED
(`TutorialSeeder` + `MobileTutorialSeeder` share `PostureCopy.privacyLessonOneParagraphs`), so existing stores
keep the stale sentence — the closeout re-seeds her real store's field guide behind the A1 rail (the standing
closeout rule), and the phone's seeder ships the same words. Draft rides the QUESTIONS #215 bundle.

**VX-206 (end on Protection) — CONCUR; one coordination fact:** VX-214 (settings panes polish, live, author-
attended) owns the Settings panes' internals this week. U4 keeps this diff to the ceremony's LANDING (restore
the Protection selection + its popup across the re-key teardown), never pane internals; the overlap is declared
on the in-flight row and to the coordinator.

**VX-208 (the one line) — CONCUR as ruled** (no delete offer of our own). Home: the insurance-off notice's
neighborhood (`PostureCopy.swift:434-437`) so the line appears exactly where the export story is told.
PROVISIONAL placement, bundled with the copy.

**VX-209 (the way-back revert) — CONCUR with her pre-launch scope, and a deliberate refusal of the deeper fix
tonight.** The confirm line (outgoing Castle + incoming reads Standard, plaintext exports included) and the
guide warning both land. The deeper fix — corner 45 remembering "this store id was Castle" — looks one belt
away via VX-202's store-id signal, but it can STRAND a user: a pre-Castle Standard-era backup may carry NO
passphrase wrap (silent-only era), so forcing a demanded gate on a remembered-Castle store id would leave that
backup openable only by the twelve words, or not at all. That is a design sitting's tradeoff, not an overnight
belt (QUESTIONS/ticket per the kickoff's "else ticket it"). SEQUENCING: U5 (VX-209) runs AFTER U1 lands so the
guide's instruction is written against the shipped behavior, not the pre-fix one.

**Cross-cutting (binding):** every new or changed user-facing sentence is PROVISIONAL and bundles into
QUESTIONS **#215** before the PR merges; sentence case, no capitals for emphasis (VX-110's consent de-cap
included). This run is the ONE custody effort in flight (declared; VX-179's custody line closed before our
kickoff). All `xcodebuild test` under stage claims via `oct12coordinator`; headless `swift test` free. Mac-suite
closeout coverage follows the changed-SOURCE rule (grep tests for changed types, not changed test files).

## §B — ACCEPTANCE UNITS (strictly sequential; ONE implementer session each; evidence named)

| unit | members | evidence that closes it |
|---|---|---|
| U1 | VX-202 | the bootstrap-level race pin red-on-old by revert through the PRODUCTION reopen; belts (b)/(c) pinned incl. the adoption-window inertness; existing switch/drill suites green (stage) |
| U2 | VX-110 | state-transition pins: two doors offered on the gate state; forget-then-sign-in lands the consent, never the follow; the crash-window resume completes the forget; two-store custody isolation; born-Castle setup pin (or Done copy softened); the consent de-capped; phone door confirmed |
| U3 | VX-203 + VX-208 | lister pins red-on-old (apple-wrapped stamp folders listed, Castle-era ones not; follow road too); the confirm's honest counts; the one VX-208 line landed PROVISIONAL |
| U4 | VX-204 + VX-206 | the guide sentence landed on both seeders PROVISIONAL; ceremony-from-Protection ends on Protection with the popup (walk-verified); zero pane-internal lines (VX-214 overlap) |
| U5 | VX-209 | the Open/Restore confirm line pinned on the classifier (backup pair + plaintext export arms); the guide warning written against U1's landed behavior, PROVISIONAL |

Then: the fable ladder over the WHOLE run diff (members touch custody) with `notes/REVIEW_PROMPT.md` verbatim;
round 2 re-reviews fixes; my hands-on walk of the ceremony + the two doors on the dev store under a stage claim;
the QUESTIONS #215 copy bundle; closeout per the skill (refresh at a zero-instance window via the coordinator,
PR merge commit, members closed individually, VX-191 closed with it, her real store's guide re-seed behind A1).

## ENVIRONMENT TRAPS (every brief carries this verbatim)
Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances are
treated by STORE and never quit/killed; no Release builds or `/Applications` refreshes while one lives. Mac
tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; NEVER a
custom build configuration. zsh `pipestatus`. Backups WAL-safe, UTC names, into `Backups/safety-copies/`,
ALWAYS before touching the real store (A1). Never `git checkout` over uncommitted work; push after every
commit; synchronous foreground waits only (poll, don't `tail -f`). EVERY `xcodebuild test` needs a held
`Tools/stage` claim granted by `oct12coordinator` (READY → GO; release + one-line result after). Headless
`swift build`/`swift test` on the core package runs freely. The real Keychain drills (`PostureSwitchDrillTests`)
are stage work. Work ONLY in `~/dev/variorum-vx-201`.

## §C — U1 BRIEF (VX-202: the re-key reopen's silent re-save race — ONE implementer session, Opus xhigh)

**Product frame first:** this is the author's own writing app hardening its OWN privacy promise before public
release — after entering Castle, nothing current may still open the old way. Defensive work on her code, at her
request. You are the U1 implementer. Work ONLY in `~/dev/variorum-vx-201` (branch
`vx-201-castle-prelaunch-fixes`). Append your record as `## U1 RECORD (VX-202)` in this file, LIVE STATUS first,
commit per piece, push after every commit (`notes/SessionResiliencyProtocol.md` binds you — read it).

**Required reading before any edit (never delegated):** this file WHOLE (§A's VX-202 refinements are BINDING);
`notes/plans/fixes/vx-191-encryption-audit.md` §O.2–O.4 (the trace); `notes/SyncSpec.md` IN FULL (custody rule);
`notes/plans/pre-13x-postures-design.md` §1 (decisions 28/32/35 especially), §3.4, §4, §14 (corners 42/45);
then the code: `AppBootstrap.swift` (the ready path :500-545, `rekeyLibrary` :810-841, `lock`),
`PostureSwitch.swift` (the runner: `swapLibrary`, the marker steps, `moveCustodyForSwitch` call sites),
`ProtectionController.swift` (`moveCustody` :1346-1375, `reconcileFollow`, the Apple arm `reconcileAppleKey`),
`StoreLaunchGate.swift` (`effectiveGate` :362-383, `rawKeyCustody`), `Sources/VariorumCore/Persistence/StoreKey.swift`
(+ `StoreKeyGuard`), and the existing pins (`PostureSwitchTests`, `PostureSwitchDrillTests`, `Phase13pControllerTests`).

**The defect (traced, §O.3):** during a Standard→Castle switch (ceremony, follow, or resume), `rekeyLibrary`'s
reopen reaches `.ready`, where the 13p R1-M3 recovery arm (`AppBootstrap.swift:526-531`) sees an `unlockedKey`
under a not-yet-demanded gate (custody has not moved yet) and spawns a DETACHED utility task that re-saves L′
into the SILENT Keychain item. Nothing orders that save against the custody move's `deleteAuto`; a late save
leaves the current library key readable with no Touch ID and no passphrase, and on a local-only library the
route's landing arm then wraps L′ under the Apple key at the next launch (a silent, total reversion the Done
screen never mentioned).

**The fix (three legs, each with its own pin; §A's refinements are part of the spec):**
1. **Never spawn the R1-M3 re-save while a switch is in flight.** TWO gates, both required, because each covers
   a window the other cannot:
   (i) an IN-MEMORY `switchInProgress` on `AppBootstrap`, set synchronously before the re-key's `beginOpening`
   and cleared only after the runner's custody move completes (the runner owns the clear) — this covers the
   live path with zero race, because the arm then never spawns the task at all. A marker read INSIDE the
   detached task is NOT acceptable: the task can be delayed past the custody move and the marker clear, read
   "clear", and re-land the item AFTER `deleteAuto` — the same bug through the fix.
   (ii) the persisted `RotationMarker` (the `readSwitchPending` seam already at `AppBootstrap.swift:505-507`)
   gates the arm at an ORDINARY post-crash launch: the file is already under L′, the silent open fails, the
   lobby's typed word produces an `unlockedKey`, and without this gate the arm re-lands it silently mid-switch.
   At that instant no runner is racing (the resume starts later), so the async read is safe THERE and only there.
2. **Belt: the at-ready sweep.** At every ready under a DEMANDED effective gate, a lingering silent item for the
   CURRENT store id is a custody-law violation — delete it (the `CustodyHandover`-style delete carrying the DP
   flags), never read it as posture. Safety bounds (§A): only when the live key file carries P/W wraps for that
   key or the gated item verifies (never strand a hand-damaged store); prove by pin that it is INERT during a
   13x adoption's deliberate `landCustody` window (dials reset to Auto there — verify, don't assume).
3. **Belt: the route's landing arm.** `StoreLaunchGate.effectiveGate`'s landing arm must not land an Apple copy
   while a switch is pending for that store id. The route runs PRE-OPEN (no database), so the signal is a
   store-id-scoped flag OUTSIDE the DB, beside the dials' existing UserDefaults home: written when a switch
   begins, cleared when custody lands (the marker's resume clears it too). Do NOT stretch this to "ever was
   Castle" — that is VX-209's deeper fix and is deliberately out of tonight's scope (§A's stranding argument).

**The pins (red-on-old verified by BEHAVIORAL REVERT, each):** (a) the race pin at BOOTSTRAP level through the
PRODUCTION reopen — `AppBootstrap.rekeyLibrary` → `beginOpening` → ready — with the utility save HELD (an
injectable guard seam / gated `saveAuto`) until after the custody move, asserting the silent item is ABSENT at
the end; red on the pre-fix code. (b) the post-crash launch arm: marker set + unlockedKey at ready ⇒ no re-save.
(c) the sweep's delete under a demanded gate + its adoption-window inertness. (d) the landing arm's refusal
under a pending switch flag. Existing suites stay green. If a pin proves a leg hollow (green on both sides),
record it and do not fix — the hallucination guard.

**Constraints:** ZERO lines inside `Sources/VariorumCore/Sync/` — if the fix seems to need one, STOP and report
to the orchestrator (that seam is reserved). Zero user-facing copy in U1. No schema. Match surrounding idiom;
comments state constraints, not narration. One read-only Sonnet subagent for EXTERNAL facts only, if ever.

**Testing protocol:** headless `swift build` / `swift test` freely in the worktree. Mac-target suites
(`xcodebuild test`) are STAGE work — do NOT run or claim; instead `xcodebuild build-for-testing` to prove
compilation, list the exact suites + `-only-testing` arguments as PENDING in your record, and the orchestrator
runs them at a coordinator window. Confirm the "Test run with N tests" line semantics (skipped tests count —
read the skipped lines). Foreground waits only (poll, never `tail -f`). End your session with the record
flipped, everything pushed, PENDING marks honest.

## LIVE STATUS
- 2026-10-13 kickoff: preflight complete (CLAUDE.md canon, SyncSpec whole, postures design §1/§3.4/§4/§14, the
  audit record + all three auditor reports, the member tickets + her comments, QUESTIONS tail, board snapshot);
  main merged into the branch (a1efb7de); §A assessment + §B units written (c79ccd49); in-flight row on main.
- Coordinator (oct12coordinator): CUSTODY SLOT GRANTED to VX-201 explicitly (VX-184 and VX-214 both confirmed
  zero custody); stage READY→GO per window; the /Applications refresh may FOLD into a shared end-of-burst
  refresh — ask at merge. TWO coordination riders: (1) VX-206's landing may touch the Settings window's
  open-at-pane machinery, which is VX-214's surface tonight — sequence with settingspaneupdater BEFORE U4
  builds there; (2) VX-214 may reword Protection/Data Safety pane copy — rhyme-check our field-guide copy with
  theirs before either merges. (3) The real-store guide re-seed at closeout: cite the skill's standing closeout
  rule; the coordinator puts it to her if that's not authorization enough — answer owed at closeout.
- §C U1 brief written (9101432e); U1 implementer dispatched (VX-202 In Progress).
- **VX-206 MACHINERY RULING (settingspaneupdater, 2026-10-13, recorded in both run files — theirs:
  `notes/plans/fixes/vx-214-settings-launch-polish.md` "VX-206 machinery ruling"):** Settings pane selection is
  plain `@State` (`pane`) in `AppSettingsView`; the ONE programmatic open-at-pane road is the MCP request
  pattern (`MCPDoor.settingsRequest` → `adoptMCPRequest()`, `AppSettingsView.swift:175-192`); no generic door
  exists and VX-214 is not otherwise changing that machinery. VX-214 AUTHORIZES a narrow exception to the
  surface split: WE add the Protection twin of the request pattern to `AppSettingsView` (a request holder the
  ceremony bumps + one adopter mirroring :175-192, nothing else in the file) — or a small generic pane-carrying
  request if no bigger. We merge first; we send VX-214 the final hunks in their files; they rebase and
  generalize if her pane rulings want more. COPY RHYME: whoever merges second reconciles (in practice VX-214 —
  their Protection/Data Safety rewording waits for her sitting); our no-caps + two-register rules bind their
  rewording; if both runs are still open when their rewording lands, drafts are swapped before either merges.
  U4's brief cites this entry.
