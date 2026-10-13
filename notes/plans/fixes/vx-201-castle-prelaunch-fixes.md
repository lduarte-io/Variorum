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

**HER OVERNIGHT MANDATE (2026-10-13, live at the run, verbatim):** *"I'm going to bed and I want you to continue
working through these items throughout the night, culminating in an applications refresh. if someone merges in
before you, merge their work into yours and then merge. I'll read and handle my handoff from you on all of these
items in the morning. If you recommend that I look more into a specific issue or mint a new ticket, I'll see
that. If you find anything that should block launch, tell me explicitly as a high priority item. GOod luck with
the rest of your work tonight."* Read as: the full run to closeout tonight — units, ladder, walk, the QUESTIONS
#215 copy bundle (PROVISIONAL, her morning eye), the PR merge (merge-main-in first if others merged), the
`/Applications` refresh via the coordinator's window — with the morning handoff
(`notes/handoffs/vx-201-handoff.md`, her checklist at the top) carrying every held item; anything
launch-blocking is flagged HIGH PRIORITY and explicit at the handoff's head.

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
| U5 | VX-209 | FIRST a pin REPRODUCING §W.2's round-trip trace at HEAD (open a Standard-era backup of the same library, bring the Castle library back — lands Standard; the trace was read, never run — her carried-forward reminder 2); then the Open/Restore confirm line pinned on the classifier (backup pair + plaintext export arms); the guide warning written against U1's landed behavior AND the reproduced trace, PROVISIONAL |

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

## §D — U2 BRIEF (VX-110: the two doors for a signed-out enrolled library — ONE implementer session, Opus xhigh)

**Product frame first:** this is the author's own writing app hardening its OWN privacy promise before public
release — the app must never say Castle while the account's sync copy stays openable the old way, and it must
never trap a user who lost their account. Defensive work on her code, at her request. You are the U2
implementer. Work ONLY in `~/dev/variorum-vx-201`. Append `## U2 RECORD (VX-110)` to this file, LIVE STATUS
first, commit per piece ("Part of VX-110"), push after every commit, no attribution trailers
(`notes/SessionResiliencyProtocol.md` binds you — read it). The ENVIRONMENT TRAPS section above binds verbatim.

**Required reading (never delegated):** this file WHOLE — §A's VX-110 refinements, her carried-forward
reminder 1, the U1 RECORD + its adjudication (U1's `switchInProgress` / `endSwitch` / `switchPending` machinery
is now in these files; your roads must ride it, never duplicate it); `notes/plans/fixes/vx-191-encryption-audit.md`
§W/§W.1 (the user-position table + her ruling) and auditor A's VX-110 section; `notes/SyncSpec.md` IN FULL;
`notes/plans/pre-13x-postures-design.md` §1 (decisions 5/8/9/17/25/26/35), §4, §5 (the doors table), §14
(corners 26/27/34/43); then the code: `PostureSwitchModel.swift` (`start` ~:258 — where the door forks before
the explain), `PostureSwitch.swift` (`checkDoor` :413-419, `runCeremony`'s enrolled guard + local road),
`EncryptionSession.swift` (`forgetDeviceKeys`, `joinStandard` :382-410, the enroll road), `EncryptionViews.swift`
:431-466 (the join consent), `PostureCopy.swift` (:236-240 the consent, :326-328, :438-441 `enteredCastleDone`),
`ProtectionController.swift` (`reconcileFollow`'s follow-into-Standard arm :707-717), `ProtectionPane.swift`
:329-337, `MobileProtectionSheet` (the phone's door conditions — the audit never read them; you do),
`VariorumApp.swift` :295-304 (runner wiring).

**The defect (auditor A, confirmed at HEAD):** Use Castle on a library with sync custody but no live session
runs the silent local-only road: the vault and server stay Apple-openable, the Done claims the account-wide
switch ("your other devices will ask"), backups she deletes at the offer are gone for a Castle that never
happened, and the next signed-in ready SILENTLY reverts this Mac to Standard via the follow arm.

**Her ruling (the ticket's comment, binding):** signed out with sync custody held, Use Castle offers TWO doors —
**Sign in…** (the account-wide switch) and **Use Castle on this Mac only** (forget the old account's keys here
via `forgetDeviceKeys`, then the local road, with an HONEST Done). Signing back into the old Standard account
then lands on the join consent (Join / Cancel), never a silent revert. De-cap the consent's "ACCOUNT" and give
that sentence a wording pass. A flat "refuse unless signed in" is WRONG — it traps the lost-account user.

**The build (§A's refinements are part of the spec):**
1. **The gate:** the fork fires when posture reads Standard AND this store's sync custody holds MATERIAL (not an
   identity-only record — post-forget identity must NOT re-trigger the doors; in Standard the material is the
   silent item, readable without prompting) AND there is no live session. A genuinely pre-sync library (no
   custody material) keeps today's local road byte-untouched. Enrolled + signed in keeps the full road. Signed
   in but offline keeps the existing offline refusal. No road may reach the OLD silent local-only ceremony while
   custody material is held and the session is absent.
2. **Sign in…** routes to the sign-in door and ENDS the ceremony (no auto-resume across an async sign-in —
   PROVISIONAL, §A refinement 4; the face may say to press Use Castle again after signing in).
3. **Use Castle on this Mac only:** `forgetDeviceKeys` EARLY — before or atomically with the custody move, and
   CARRIED BY THE MARKER'S RESUME, so no crash window leaves the re-keyed library with the old account's
   material still held (§A refinement 1: if the forget runs last and the session dies after the re-key, the
   next sign-in is the silent revert THROUGH the fix). Then the local road (steps 4–7) exactly as a pre-sync
   library — it inherits U1's switch machinery automatically; VERIFY (don't assume) that the signed-out road
   sets and clears U1's per-store `switchPending` flag like the enrolled road does.
4. **The honest Done** (new copy, PROVISIONAL): this Mac's library is in Castle; the old account and its server
   copy are unchanged — delete that account if you still can; signing into it later will ask before anything
   changes. It must NOT say "your other devices will ask." Do not promise what a new account's posture will be
   unless your born-Castle pin (below) proves it.
5. **The consent:** de-cap "ACCOUNT" (`PostureCopy.swift:236-240`), wording pass, sentence case — PROVISIONAL.
6. **The phone:** read `MobileProtectionSheet`'s door conditions. The phone gets the same two doors through the
   shared model, or an honest refusal — NEVER the old silent road with the ordinary Done. The phone target must
   build; faces carry the shared copy.
7. **The ticket's item 2 (the NIT, in scope):** the Encryption-tab re-key banner/door and the sync-row door
   (`EncryptionViews.swift` ~:120/:664, `SyncStatusViews.swift` ~:147) still name ONE act for every pending
   marker — extend VX-99's `CeremonyAct` selector to those faces so the named act matches the marker's. String
   changes ride the copy-drafts section; a pin at the selector level.

**The pins (red-on-old by behavioral revert, each):** (a) the gate state presents the two doors; the pre-sync
and enrolled-signed-in states don't. (b) This-Mac-Only then sign-in to the OLD account lands the JOIN CONSENT,
never the silent follow (red on old: today it silently reverts). (c) the crash window: die between the re-key
and the forget — the resume completes the forget. (d) two stores, two custody records: forgetting one leaves
the other intact (her multiple-accounts worry, §A refinement 3). (e) BORN-CASTLE (her carried-forward reminder
1): sync setup from a Castle library mints a Castle vault (no Apple-held copy) — if this pin cannot be built
headless against the fake server, say so in the record and SOFTEN the Done instead; never ship copy that leans
on an untested road. (f) the Done's road shows the honest copy, not `enteredCastleDone`. Existing suites green.

**Copy:** every new or changed sentence lands in your record under `### U2 COPY DRAFTS` (for the QUESTIONS #215
bundle) — sentence case, no capitals for emphasis, the two-register rule (everyday surfaces name no key).

**Constraints:** ZERO lines in `Sources/VariorumCore/Sync/` (stop and report if needed). No schema. Mac-target
suites are STAGE work — `build-for-testing` only, list suites + `-only-testing` arguments PENDING; headless
`swift test` freely. One read-only Sonnet for EXTERNAL facts only, if ever. Foreground waits only.

## §E — U3 BRIEF (VX-203 + VX-208: the offer's reach + the one plaintext-exports line — ONE implementer session, Opus xhigh)

**Product frame first:** the author's own writing app making its Castle ceremony's promise honest before public
release — "delete the backups Variorum made" must reach every Apple-openable copy Variorum itself made inside
its own folders, and the ceremony must not stay silent about plaintext exports it once wrote. Defensive work on
her code, at her request. You are the U3 implementer. Work ONLY in `~/dev/variorum-vx-201`. Append
`## U3 RECORD (VX-203 + VX-208)` to this file, LIVE STATUS first, commits per piece ("Part of VX-203" /
"Part of VX-208" per the member each piece serves), push after every commit, no attribution trailers. The
ENVIRONMENT TRAPS section binds verbatim; `notes/SessionResiliencyProtocol.md` binds you — read it.

**Required reading (never delegated):** this file WHOLE (§A's VX-203/VX-208 entries; the U1 and U2 RECORDS —
you edit the same `PostureSwitch.swift` they touched); `notes/plans/fixes/vx-191-encryption-audit.md` §O.2 +
auditor B's B1 section whole (B1a–B1f) and B3c; `notes/SyncSpec.md` IN FULL; `notes/plans/pre-13x-postures-design.md`
§1 decision 11, §4 steps 6–7, §6, §14 corner 4; her rulings on the tickets (VX-208's comment: ONE line, no
delete offer of our own); then the code: `PostureSwitch.swift` (`preSwitchSnapshots` :1735-1759,
`deletePreSwitchSnapshots` :1760-1773, the offer sites :1226-1253 / the follow :863,:882 / the resume
:1533,:1612), `StoreBackup.swift` (`existingBackups` :704-715, `removeSnapshotPair` :598-604, the folder
layout :281-325), `LibraryAdoption.swift` :207-274 (what `Previous Libraries/<stamp>/` and
`Backups/safety-copies/variorum-adopt-safety-<stamp>/` hold and how they are named), `LibraryOpenCopy.swift`
:51-61, `PostureCopy.swift` (the offer body :462-468, the insurance notice :434-437), `MarkdownInsurance.swift`
(the prune guard), `StoreKeyEnvelope` (reading a folder's key files for the `apple` wrap).

**VX-203 — the offer's reach (auditor B1d, MAJOR; her ruling: list those folders too, or at minimum name
them — BUILD the listing, fall back to naming only if the listing proves unsafe, and say why in the record):**
1. The lister gains two arms beside the snapshot pairs: `Previous Libraries/<stamp>/` (the container's) and
   `Backups/safety-copies/variorum-adopt-safety-<stamp>/` — offering a STAMP FOLDER iff a key file inside it
   carries an `apple` wrap (§A bound 1: a Castle-era prior library is NOT Apple-openable and must not be swept;
   never a blanket folder delete — match by the adoption's own naming plus key-file inspection, so A1 safety
   copies and foreign folders are untouched).
2. Deletion is the WHOLE offered stamp folder; the confirm carries honest counts AND owns what these are: the
   step-aside/way-back copies the adoption confirm once named as a recoverable home — deleting closes that road
   (one sentence, PROVISIONAL).
3. The same lister serves the ceremony, the follow and the resume offer sites (B1d's rider) — one function,
   three callers, never three listers.
4. Out of scope: B1e's unreachable-second-folder class (VX-210, Parked) and B1f's folder-level key files.
**VX-208 — the one line (her ruling verbatim: "no delete offer of our own — one line in the Castle process
saying plaintext .md exports already written … are not covered and should be deleted by hand"):** home it at
the insurance-off notice's neighborhood (`PostureCopy.swift:434-437`) so the line lives where the export story
is told; it must reach the ceremony AND the follow (both share `snapshotAndInsurance`). Placement + wording
PROVISIONAL, drafted under `### U3 COPY DRAFTS`.

**The pins (red-on-old by behavioral revert, each):** (a) a crafted `Previous Libraries/<stamp>/` with an
apple-carrying key file IS listed and its whole folder goes at Delete; (b) a Castle-era stamp folder (no
`apple` wrap) is NOT listed and survives Delete; (c) the safety-copies arm matches only the adopt-safety naming
(an A1-style `variorum-backup-a1-*` folder untouched); (d) the follow road's offer sees the same folders;
(e) declining leaves everything; (f) the VX-208 line renders on the ceremony and follow notices (string-level
is fine). Existing backup/offer suites green.

**Copy:** every new or changed sentence in `### U3 COPY DRAFTS` for the QUESTIONS #215 bundle — sentence case,
no capitals for emphasis, everyday register (no key names).

**Constraints:** ZERO lines in `Sources/VariorumCore/Sync/`. No schema. Mac-target suites are STAGE work —
`build-for-testing` only, suites listed PENDING with `-only-testing` arguments; headless `swift test` freely.
Deletion code must be path-prefix-guarded to the two named homes (never a constructed path outside them). One
read-only Sonnet for EXTERNAL facts only, if ever. Foreground waits only.

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
- **HER CARRIED-FORWARD REMINDERS (via vx-184, 2026-10-13 — pasted from the VX-191 audit session, verbatim):**
  *"1. If VX-110's Done screen ends up suggesting 'set up a new account,' confirm that a new account set up
  from a Castle library actually starts out in Castle. The design says it does, but nothing in this audit
  tested it (it's flagged in §W of the record). 2. The claim that bringing a Castle library back also lands it
  in Standard comes from reading the code, not running it. The kickoff already asks for a test proving it
  before anything is built on it. 3. Close VX-191 together with the run's PR."* Dispositions: 1 = §A VX-110
  refinement 3 / U2's born-Castle pin (already binding); 2 = U5's evidence row AMENDED this commit — the
  trace-reproduction pin runs FIRST, before any U5 text is written on it; 3 = the kickoff's standing
  instruction, confirmed (VX-191 closes with this run's PR).

## U1 RECORD (VX-202)

**Not done in this unit (stated first):** no `xcodebuild test` of any kind was run (stage work, per §C) — every pin
result, every red-on-old run and every existing-suite result below is **PENDING** the orchestrator's stage window;
no walk (U1 has no face; the brief names the pins as its evidence); the phone's `MobileProtectionTests` (simulator)
not run; the ordinary-road ordering belt (the save on the custody queue) has no deterministic pin; the VX-209
deeper fix ("ever was Castle") deliberately not built; the local-only race OUTCOME already on disk is not healed by
either belt (finding F2). Zero lines in `Sources/VariorumCore/Sync/`, zero user-facing copy, no schema, no
`notes/QUESTIONS.md` entry (no product call was made; that ledger is merge-moment-only).

### LIVE STATUS (closed 2026-10-13 ~01:40; PENDING = unverified)
- Reading done in this session, never delegated: this file whole, the VX-191 record whole, `notes/SyncSpec.md` in
  full, the postures design §1/§3.4/§4/§14, `notes/SessionResiliencyProtocol.md`, the VX-80 record; the code named
  in §C plus `LibraryOpenModel.landCustody`, `PostureSwitchModel`/`PostureFollowModel`, `Posture.derive`, and the
  existing pins (`PostureSwitchTests`, `PostureSwitchDrillTests`, `Phase13pControllerTests`,
  `VX80CastleFollowRecoveryTests`, `Phase13pLobbyTests`, `MobileWindowReplayTests`).
- DONE 64c96bfe (the fix) · ffbcbd61 + 1d97f52d (the pins) · c2f188b7 (the revert patches) · this commit (record).
- VERIFIED here: `build-for-testing` green for `Variorum` (macOS) and `VariorumMobile` (generic iOS Simulator), zero
  warnings in the changed files; all six revert patches `git apply --check` clean AND compile (R-a1+R-c+R-d1+R-d2
  together, R-a2 alone, R-b alone — they share one hunk pairwise), tree restored to the committed fix each time.
- DerivedData: the run-tagged `App/Variorum/DerivedData/vx201` (gitignored; 2.4 GB after the Mac build, the phone
  build added to it) — built with `COMPILER_INDEX_STORE_ENABLE=NO`. `df -h` (data volume): 134 MiB free at the
  ENOSPC (~00:58) · 32 GiB at 01:20 after the coordinator's cleanup · 51 GiB at 01:35 after both builds.
- ENVIRONMENT INCIDENT (~00:58): the Pro's data volume hit 100% during my FIRST build-for-testing (default
  DerivedData path). I removed exactly that build's folder (`~/Library/Developer/Xcode/DerivedData/Variorum-
  diwnyrznuwxhklevjvupjqqgktgr`, 2.0 GB, created by it, its info.plist naming this worktree) and, after the
  coordinator's note, the same-path folder of my second build; nothing else was touched. Standing consumers then
  (read-only): DerivedData 35 GB across worktrees, CoreSimulator 32 GB, /private/tmp 9.4 GB, macOS update snapshots
  (one `MSUPrepareUpdate`).

### What landed (the mechanism, per leg)
1. **Gate i — `AppBootstrap.switchInProgress`** (in-memory, distinct from the controller's model-set flag): set by
   `rekeyLibrary` synchronously before its reopen; cleared ONLY by the runner after `moveCustodyForSwitch` returns
   (`Leaves.endSwitch`, wired in `.live` to `bootstrap.endSwitch()` on both platforms; inert default for scripted
   worlds). The R1-M3 arm's condition requires it clear, so the switch's own reopen schedules nothing. A road that
   throws before custody leaves it set (the switch is pending); the resume's custody move clears it.
2. **Gate ii — the marker**: on every other ready the arm schedules a MainActor task (`AppBootstrap.relanding`,
   test-visible like `opening`) that reads `readSwitchPending` (the persisted `RotationMarker`), then RE-READS both
   in-memory flags and requires the key to still be the key in hand, then saves through
   `ProtectionController.relandSilentItem` — on the controller's serial custody queue, enqueued synchronously after
   the checks, so it runs before any custody move enqueued later (ordering by construction; the old save was a
   detached utility task). The marker read happens only off the switch's road (gate i), as §C requires.
3. **Belt b — `ProtectionController.sweepLingeringSilentItem`**, first act of every reconcile after the vault read:
   fires only when (after the bootstrap adopted; no switch in flight; no marker) a silent item AND the gated item both
   exist, and the posture derived with the GATED item as the custody shape is a DETERMINED Castle (the vault's word,
   or the local rule; indeterminate writes nothing — decision 35). Safety: the silent key opens nothing current (the
   resident this ready opened with is another key) OR the live key file carries a passphrase/twelve-words copy of it
   by explicit fingerprint — else left, logged. The delete is the guard's (production: `StoreKeyKeychain.delete`,
   DP-flagged); a silent item that was the open's key stays in hand as the resident.
4. **Belt c — the store-id flag**: `StoreLaunchGate.switchPending`/`setSwitchPending` (live: `ProtectionDefaults`
   key `variorum.protection.<scope>.<storeID>.switchPending`, beside the dials; scripted: `ScriptedSwitchPendingBox`,
   inert default). The runner keeps it mirroring "the marker names a step before custody landed": set BEFORE writing
   a `.vaultWrite`/`.reencrypt`/`.rekeyLibrary`/`.custody` marker (and again once the new key file exists), cleared
   AFTER the `.snapshot` marker or any marker clear (end of road, `restartRequired`, the CAS→follow hand-over). The
   route's landing arm (`effectiveGate`) refuses while it is set — which also covers `currentEffectiveGate` and
   `landCustody`'s reads of the same function.

### The pins — `VariorumTests/VX202ReopenRaceTests` (10 tests) and the red-on-old protocol (ALL PENDING, stage)
Run green first, then each revert: `git apply notes/plans/fixes/vx-201-u1-reverts/<R>.patch`, `build-for-testing`,
`test-without-building -only-testing:VariorumTests/VX202ReopenRaceTests`, read which tests fail, then
`git checkout -- App/Variorum/Shared/` (the fix is committed; nothing else is uncommitted there).
| pin | test | expected red under |
|---|---|---|
| (a) the race, production reopen, save held past the move | `theReopensSilentSaveHeldPastTheCustodyMoveLeavesNoSilentItem` | **R-a1** (arm pre-fix): silent L′ after release + the relaunch opens without a lobby · **R-a2** (gate i removed): `relanding` non-nil |
| (b) post-crash marker | `aPendingSwitchMarkerKeepsTheRecoveryUnlockFromReLandingTheSilentItem` | **R-b** (marker unread): B lands silent |
| (b) control (VX-80 heal, no marker) | `withoutAMarkerTheRecoveryUnlockStillReLandsTheProvenKey` | green under every revert except R-a1 (its `scheduled` assert) |
| (c) sweep, local Castle | `theSweepRemovesASilentItemBesideTheGatedOneOnALocalCastleLibrary` | **R-c** (sweep not called): silent stays, posture Standard, the Apple arm wraps L′ under A |
| (c) sweep, enrolled Castle | `theSweepRemovesTheLingeringSilentItemOnAnEnrolledCastleAccount` | **R-c** |
| (c) safety: the only road in | `theSweepLeavesASilentItemThatMayBeTheOnlyRoadIn` | green both sides (a bound) |
| (c) corner 45 untouched | `theSweepLeavesAStandardWaitingLibraryAlone` | green both sides (a bound) |
| (c) adoption-window inertness | `theSweepIsInertOnEveryShapeTheAdoptionLandsCustodyIn` | green both sides (three `landCustody`/plaintext shapes) |
| (d) the landing arm | `theRoutesAppleLandingRefusesWhileASwitchIsPending` | **R-d1** (flag ignored): the copy lands |
| (d) the flag's life + resume | `theSwitchPendingFlagSpansExactlyTheCustodyPendingStepsAndTheResumeClearsIt` | **R-d2** (runner writes no flag) |
Expect "Test run with 10 tests" for the suite (no `.enabled(if:)` gates in it).

**Existing suites (changed-SOURCE rule — every Mac suite that drives the bootstrap, the controller's reconcile or
custody, the runner, the gate or the adoption) — PENDING, one stage run** from `App/Variorum/`:
`xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx201`
plus `-only-testing:VariorumTests/` + each of: VX202ReopenRaceTests VX80CastleFollowRecoveryTests PostureSwitchTests
Phase13pControllerTests Phase13pLobbyTests StoreLaunchRouteTests Phase13pKeyedDrillTests LobbyVaultRoadTests
LibraryPortabilityDoorTests AppleRelinkDoorTests AppBootstrapOffMainTests CustodyReleaseTests KeyDoorTests
WordsCopyDoorTests CopyRegisterPinTests ProtectionMigrationTests ProtectionSurfaceRenderTests ProtectionTierFaceTests
ProtectionDialsTests ProtectionDialsPerStoreTests ProtectionCopyTests ProtectionCadenceTests StoreKeyGuardBackingTests
RetiredNamesPinTests SyncLockedFaceTests EncryptionFlowTests CopyFlowRoundTests CrossoverRoundTests
AccountLifecycleDoorTests AccountDoorWiringTests TerminologyPinTests FreshAccountSetupGeneralityTests
AuthSessionLazyLoadTests EncryptionCustodyThreadTests ProtectionSetModeOffMainTests ProtectionReconcileOffMainTests
PostureSwitchDrillTests ProtectionMigrationDrillTests (the two drills are opt-in: add
`TEST_RUNNER_VARIORUM_POSTURE_DRILL=1` / `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` for the brief's "drill suites
green", and read their `skipped:` lines otherwise). Phone (simulator stage): `VariorumMobileTests/MobileWindowReplayTests`
(the one existing follow through `bootstrap.rekeyLibrary`; gate i makes its `backing.auto == nil` deterministic).

### Findings for the orchestrator (dispositions owed by the run, none acted on beyond the brief)
- **F1 — belt b's "demanded effective gate", interpreted (PROVISIONAL, the orchestrator's to confirm).** Read off the
  route's derivation it is unreachable for a local-only library: the lingering silent item IS corner 45's evidence
  (silent ⇒ Standard-waiting ⇒ `.auto`), so the leg would be hollow. Built instead on the custody law's own
  discriminator: two items for one key (silent beside gated) + the posture read with the GATED shape, determined.
  Without a gated item the silent item is the shape (Standard-waiting, a never-followed device, Always ask) and the
  sweep never acts — the follow/enroll machinery owns those (an enrolled Always-ask lingering item is healed by the
  standing enroll-join re-key; a local-only Always-ask one is gate i's to prevent).
- **F2 — the local-only race OUTCOME already on disk (a pre-fix build's) is NOT healed by either belt.** At the next
  launch the route's landing arm wraps L′ under A before any ready (belt c refuses only while a switch is pending;
  custody had landed), after which the library is genuinely Standard-shaped and the sweep has nothing to act on.
  Gate i prevents new instances. A "gated item present ⇒ never land" refusal at the landing arm would catch it — NOT
  built (§C: do not stretch belt c); candidate for VX-209's deeper-fix ticket.
- **F3 — VX-80's designed heal is overridden while a marker is pending** (§C's gate ii, exactly VX-80's stranded
  state): a switch crashed between swap and custody now asks the passphrase at every relaunch until the pane's
  resume, instead of re-opening silently. VX-80's own pin stays green (its store carries no marker); its doc
  sentence "losing this heal would re-strand every relaunch" now reads true only for the marker-less class.
- **F4 — a wrong-key silent item with NO marker on a Castle-shaped key file** (stale save or corruption) is still
  healed to the current key by the R1-M3 arm, and on a local-only library the next route can then land A — the
  corner-45 class (VX-209 territory). The one in-app road to that state I found (an ordinary ready's save delayed past
  a later switch) is closed by the custody-queue ordering + the key-in-hand check; not pinned (needs a production
  seam to hold the marker read).
- **F5 — adoption corner:** `landCustody` ignores its own delete results; if `deleteGated` is refused on the Auto
  arm, a silent K_in can sit beside a stale gated item on a Castle-era pair, and the sweep would remove the silent
  item at the next ready (the library then asks instead of opening silently). Not pinned; the state is already a
  custody-law violation. Also verified (§A's premise): the adoption's inertness comes from the custody SHAPE and the
  key file, not the dials (dials carry only Castle's gate style; `ProtectionDials()` never makes a gate undemanded).
- **F6 — her devices at the refresh:** the sweep can act on her REAL store at the first ready of the new build (a
  lingering silent copy beside the gated item on a determined-Castle library is removed, logged "custody sweep: …");
  that is the belt working, but it is a custody write on her store — worth naming at the A1-railed refresh.
- **F7 —** `MobileWindowReplayTests` composes the runner without the new `endSwitch` leaf (inert default): the
  bootstrap flag stays set after its follow, harmless to its assertions; production `.live` wires it on both
  platforms.

### ORCHESTRATOR ADJUDICATION — U1 (verified against git before adoption: the implementer's commits 8054825d →
95879dc3 interleaved with the orchestrator's 08479fff on one shared branch, HEAD pushed, tree clean; the true
U1 diff read from 97329acc..HEAD — five `App/Variorum/Shared/` files + the 704-line pin suite + six revert
patches, ZERO `Sources/VariorumCore/Sync/` lines, zero trailers; the record's counts adopted as recorded,
suites PENDING the stage window)

- **F1 — ACCEPTED.** The implementer's trace is right and the brief's wording was the imprecise part: "demanded
  effective gate" is circular for a local-only library (the lingering silent item IS what drives corner 45 to
  Standard-waiting/`.auto`, so the gate never reads demanded while the violation exists — the leg would have
  been hollow). The rebuilt discriminator — two items for one key, posture determined Castle with the GATED
  shape, no switch in flight/pending, the never-strand bound kept — is the custody law stated directly and
  serves §A's intent (never read as posture, never strand). PROVISIONAL stands for the ladder's re-examination.
- **F2 — ADOPTED AS SCOPED.** No heal tonight (§C's don't-stretch rule; the stranding tradeoff is VX-209's
  design space). Actions: the "gated item present ⇒ never land" candidate is RECORDED ON VX-209's ticket (done
  at this adjudication); U5's guide warning covers the generic symptom honestly (Protection unexpectedly reads
  Standard ⇒ choose Use Castle again), which is the pre-fix victim's road too. Population: pre-launch builds
  only (her devices + the one tester).
- **F3 — ACCEPTED AS DESIGNED.** An unfinished switch asking for the passphrase until the pane's resume is the
  truthful state — the mid-switch silent reopen was exactly the theater class R13p-14 forbids. VX-80's recovery
  door and the marker's resume remain the road out (one press). Rider noted: on macOS 27.0.1 (VX-81's crash) a
  crashed follow is now more user-visible until resumed — accepted, honesty over convenience; the ladder
  re-examines.
- **F4 — RECORD-ONLY residual.** No in-app road remains (the custody-queue ordering + key-in-hand check close
  the one found); the state needs a stale save or corruption. No pin owed — building a production seam solely
  to simulate an unreachable state is scope creep. The corner-45 class rides VX-209's ticket.
- **F5 — ACCEPTED as residual.** A refused `deleteGated` is already a custody-law violation; the sweep then
  restores the lawful shape and the library ASKS instead of opening silently — the safe direction, bounded by
  the never-strand check. Not pinned, recorded. §A's "dials reset to Auto" premise stands CORRECTED by the
  implementer's read (the inertness comes from the custody shape + the key file, not the dials) — a good catch,
  exactly what verify-don't-assume briefs are for.
- **F6 — ADOPTED, then RULED BY HER (2026-10-13, live at the run, her words verbatim):** *"yeah tha's fine on
  the removign a lingering silent key copy of my store - i have my passphrase, i'm not concerned."* The custody
  write on her real store is pre-cleared; F6 drops out of the morning bundle, and the refresh ask names it only
  as a done fact, not a question.
- **F7 — RECORD-ONLY,** with one hygiene note for the ladder: if the un-wired `endSwitch` leaf in that test
  world ever masks an assertion, wire the inert leaf there; tonight it provably affects nothing.

NEXT: the stage window (green pass over the listed suites + the 10 pins + both drills under their env vars +
the simulator replay suite; then the six red-on-old revert cycles per the pin table), via oct12coordinator.

### WINDOW A RECORD (orchestrator, stage claim vx201-u1-tests)
- GREEN PASS: `✔ Test run with 305 tests in 38 suites passed after 291.154 seconds`, EXIT 0, zero failures
  (log /tmp/vx201-u1-greenpass.log) — but BOTH drills SKIPPED (the counts-skipped trap, caught on the skip
  lines): `test-without-building` bakes the runner env at build time, so command-line TEST_RUNNER_ vars never
  arrive. Second trap same shape: TEST_RUNNER_ vars as xcodebuild ARGUMENTS are build settings, not runner env —
  "3 tests passed in 0.001s" with 5 skip lines. THE WORKING ROAD: TEST_RUNNER_ vars in xcodebuild's own
  ENVIRONMENT + plain `test` (recorded for every later window).
- DRILLS, really run: MIGRATION drill PASSED. POSTURE drill FAILED, 2 issues, BOTH the same signature:
  `@Dependency(\.date) has no test implementation` accessed from `VariorumCore/SyncEngine.swift:19` inside the
  drill's test context; the drill's product work otherwise completed (sibling followed, seams resumed, DONE
  lines). Precedent found: 13x hit this exact class at its U2 slot and ruled it A TEST-HARNESS GAP, not a
  product finding (phase-13x-library-portability.md:796 — fixed by wrapping the pin in `withDependencies`).
  But the drill ran GREEN at pre-13x 3b and leg 3, so U1's culpability is NOT yet excluded.
- BISECT IN FLIGHT (announced before starting; the tree is fully committed at HEAD, so `git checkout --` is the
  restore): `git checkout 97329acc -- App/Variorum/Shared/` + delete the uncommitted-at-97329acc pin file,
  build-for-testing, run the POSTURE drill alone with the env road above. Same failure ⇒ pre-existing harness
  gap (test-side fix, the 13x pattern). Pass ⇒ a real U1 regression to trace before anything else lands.
- BISECT VERDICT (the revert restored by `git checkout -- App/Variorum/`, tree clean at HEAD): the PRE-U1 tree
  (97329acc's Shared/, pin file absent) fails the posture drill IDENTICALLY — the same two tests, the same
  `@Dependency(\.date)` issue at SyncEngine.swift:19, 111.98 s of real work, zero skips. **NOT a U1 regression —
  a pre-existing drill-harness rot**, somewhere between pre-13x leg 3 (2026-09-07, last recorded green) and
  tonight's first real run since (VX-191 read the drills, never ran them). The 13x precedent classifies the
  class as a test-harness gap (a ready-path task missing the test's dependency scope — the detached-task
  task-local severance is the suspect). TICKETED rather than chased tonight (not a member, not U1's; the drill's
  PRODUCT work completes — sibling followed, all three seams resumed). U1's drill evidence stands as: migration
  drill GREEN; posture drill's product legs COMPLETE with the two harness issues documented pre-existing by
  bisect. Flagged for the morning bundle: whether she wants the drill harness healed before launch.
- Env-road note for later windows: TEST_RUNNER_ vars in xcodebuild's ENVIRONMENT pass through under
  `test-without-building` too (the bisect run proves it) — the bake-time trap is only for vars passed as
  command-line arguments.
- MACHINERY INCIDENT, honestly: 15af56c0 accidentally committed the bisect's REVERTED Shared/ files beside the
  verdict note — `git checkout 97329acc -- <paths>` had updated the INDEX as well as the worktree, so the
  restore `git checkout -- App/Variorum/` pulled the pre-U1 files back out of the index, and `git add -A`
  committed them. Caught one commit later by reading HEAD's stat; FIXED FORWARD (this commit restores the five
  files from 64761572's U1-intact tree; no history rewrite — 15af56c0 was already pushed). Lesson for every
  later revert in this run: after a `checkout <rev> -- <paths>` bisect, restore with
  `git restore --source=HEAD --staged --worktree <paths>` and verify `git diff HEAD --stat` is EMPTY before any
  commit. The window-B patches use `git apply` (worktree-only), which does not carry this trap.
- WINDOW A CLOSED: simulator leg `✔ Test run with 1 test in 1 suite passed after 4.409 seconds` (MobileWindowReplayTests,
  iPhone 17 Pro / iOS 26.2 by UDID — the bare name resolves ambiguously across three runtimes; the two "skipped"
  matches are appintentsmetadataprocessor build noise, read and dismissed), simulator shut down. The drill-harness
  rot ticketed as VX-233 (her pre-launch-or-after call in the morning bundle). Window A verdict: U1 GREEN —
  305/38 Mac incl. the 10 pins, migration drill green, posture drill pre-existing-red by bisect (VX-233),
  simulator green. Stage released; window B (the six revert cycles) next.

## U2 RECORD (VX-110)

**Not done in this unit (stated first):** no `xcodebuild test` of any kind was run (stage work, per §D) — every pin
result, every red-on-old run and every existing-suite result below is **PENDING** the orchestrator's stage window; **no
walk** (GUI work needs a held stage claim, which this unit was not granted — §B names the orchestrator's hands-on walk of
the two doors; a dev-store walk also needs custody MATERIAL planted, since the dev store never syncs — see F-U2-8); the
phone's simulator suites not run; the born-Castle pin (e) and the isolation pin (d) are BOUNDS (green both sides by
design — no line of this unit is on their roads), so the Done carries NO new-account sentence until (e) is green at the
stage (her carried-forward reminder 1 — the "set up again" sentence stays OUT of the shipped draft, offered as an
alternative below); no `notes/QUESTIONS.md` entry written (merge-moment-only ledger — the drafts below are #215's
input); the canon copy record (`notes/plans/pre-13x-copy.md`) not updated (F-U2-6). Zero lines in
`Sources/VariorumCore/Sync/`, no schema, no `RotationMarker` field (the This-Mac-Only fact rides a per-store flag beside
the dials instead).

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- 2026-10-13 — U2 implementer (Opus) started. Reading done in this session, never delegated: this file whole (§A's
  VX-110 refinements, §B, §D, the U1 RECORD + its adjudication + window A); her carried-forward reminders read
  VERBATIM from `08479fff` (see F-U2-0 — they are no longer in this file at HEAD); `notes/SessionResiliencyProtocol.md`;
  `notes/plans/fixes/vx-191-encryption-audit.md` whole (§W / §W.1 / §W.2); auditor A's VX-110 section + its
  "did not check" list; `notes/SyncSpec.md` in full; `notes/plans/pre-13x-postures-design.md` §1 (all decisions),
  §4, §5, §14 (all corners); `notes/plans/fixes/vx-99-ladder-round3.md` (the VX-110 MINOR + the banner NIT). Code:
  `PostureSwitch.swift` whole, `PostureSwitchModel.swift` whole, `EncryptionSession.swift` whole, `EncryptionViews.swift`
  whole, `PostureCopy.swift` whole, `EncryptionKeychain.swift` whole, `ProtectionController.swift` (the follow verdict,
  the reconcile, the sweep, the Apple arm, the custody move, `wireOneSecretHooks`), `StoreProtection.swift`
  (`Posture.derive`, `ProtectionDefaults`), `StoreLaunchGate.swift` (the gate, the route, `syncCustodyPresent`),
  `AppBootstrap.swift` (the ready road, the R1-M3 arm, `rekeyLibrary`, `endSwitch`), `SyncStatusViews.swift` whole,
  `ProtectionPane.swift` (the pane's doors, the notice bar, `PostureSwitchSheet`), `MobileProtectionSheet.swift` +
  `MobilePostureSheets.swift` whole, `VariorumApp.swift` (the runner wiring), `AppServices.swift` (custody + the marker
  read), and the harnesses I build on (`PostureSwitchTests`, `VX202ReopenRaceTests`, `Phase13pControllerTests`,
  `SyncEnrollmentTests`).
- DONE `2397ae55` (the Apple arm's consent guard, F-U2-1) · `4c4d136c` (item 2 — the banners name the marker's act) ·
  `7efdc887` (the two doors: model + runner + copy + both faces; the consent de-capped, its three pins re-based) ·
  `f1a7652a` (the pins, `VX110SignedOutCastleTests`, 9 tests). VERIFIED here: Mac `build-for-testing` green twice
  (after the fix, after the pins), zero warnings in changed/new lines (the 5 warnings the log shows inside touched
  FILES are pre-existing lines). Every test RESULT is PENDING the stage (Mac-target suites are stage work).
- DONE `598ee565` — the seven revert patches (`notes/plans/fixes/vx-201-u2-reverts/`), generated on the committed tree
  and restored; each `git apply --check` clean; COMPILED in two combos (R-a + R-b2 + R-f + R-7 + R-c, then R-b1 + R-c2 —
  R-c and R-c2 share a hunk), the tree restored by `git checkout -- App/Variorum/Shared/` after each and `git diff HEAD`
  read empty; then a third Mac `build-for-testing` of HEAD so the run-tagged DerivedData holds the FIX's products (a
  stage `test-without-building` must not run a revert's leftovers). **No revert is applied now.**
- VERIFIED here: phone `build-for-testing` (VariorumMobile, generic iOS Simulator) green — zero warnings in the phone
  files touched. DerivedData: `App/Variorum/DerivedData/vx201` (index store off). `df -h` data volume: 43 GiB free
  before the builds, 43 GiB after.
- CLOSED (this commit): the record below — the pins table + expected reds, the stage protocol, the suites, the copy
  drafts, the findings.

### The traced mechanism (pin before fix — every leg read at HEAD `97959e5d`)
1. **The fork is missing (auditor A, confirmed).** `PostureSwitchModel.start` sends `.enter` straight to `.explain`;
   `runCeremony`'s `enrolled = vault ∧ transport ∧ signedIn ∧ custody`, so a signed-out library holding sync custody
   MATERIAL (Standard ⇒ the silent bound item, readable without a prompt) takes the local road
   (`PostureSwitch.swift` local branch): the vault untouched, the material KEPT and moved behind the gate by the custody
   move (`SyncCustodyTransition.move` carries a record with material), the ordinary Castle Done.
2. **The silent revert, step by step.** At the next signed-in ready `reconcileFollow` finds material in hand
   (`heldSyncMaterial()` reads the session record the gated move left), the ids equal the vault's, the vault carries an
   Apple-held copy and the NEW key file carries none ⇒ the follow-into-Standard arm runs `followIntoStandard()`: the key
   file gains `apple`, custody moves silent. Her Castle act undone, one notice after the fact.
3. **A SECOND silent revert the audit did not trace — the Apple arm (NEW, F-U2-1).** Forgetting the material closes
   arm 2 but not this: signed in to a Standard account, `Posture.derive` takes the VAULT's word (decision 8) ⇒ determined
   Standard ⇒ `reconcileAppleKey` reads A (a READ is allowed even when minting is not) and LANDS the key file's `apple`
   copy over the library's own key (`landAppleCopyOffMain`), before any consent. The same hole exists today for EVERY
   Castle-born library joining a Standard account (corner 6, the design's "consent at enrollment"):
   `Phase13pControllerTests`'s (d) case asserts the consent facts, the landing count and custody — never the key file,
   whose world adopts the resident, so the arm lands there today. Without closing it, "signing into it later will ask
   before anything changes" would be false. Fixed in this unit (the arm writes nothing while the consent is owed);
   pinned red-on-old.
4. **What keeps the Castle shape at the ROUTE after a forget** (§A refinement 2, verified): `forgetDeviceKeys` →
   `DeviceKeyStore.clear()` keeps the IDENTITY-only bound record; the live gate's `syncCustodyPresent` is record
   presence (`E2EEKeychainStorage.load != nil`), so the route reads the library ENROLLED ⇒ indeterminate ⇒ the gated
   shape ⇒ the lobby, and the route's Apple landing arm is skipped. Pinned (bound).
5. **Item 7 (the NIT):** the Encryption tab's banner + door (`EncryptionViews.swift` `rekeyIncompletePrompt` /
   `finishReplacingKeysDoor`) and the sync row (`SyncStatusViews.swift` "Finish key replacement…") name ONE act for
   every pending `RotationMarker`; the panes already read `CeremonyAct(resuming:)`.

### The design (settled before code; PROVISIONALs marked)
- **The door (model):** `checkDoor` reports `signedOutHoldingSyncKeys` = no session ∧ custody MATERIAL in hand
  (`DeviceKeyStore.load() != nil` — the identity-only record reads nil). `start()`'s `.enter` arm forks to a new phase
  `.signedOutChoice` (the two doors) on that fact, else `.explain` byte-unchanged. Pre-sync (no material) and enrolled
  signed-in libraries keep today's road; signed-in-offline keeps the transport's offline refusal (the door check throws).
- **Sign In…** ends the ceremony (phase `.signInChosen`); both faces open the account surface over the ceremony sheet
  and closing it closes the ceremony. No auto-resume (PROVISIONAL, §A refinement 4); the choice screen says to choose
  Use Castle again after signing in.
- **Use Castle on This Mac Only** (model flag `thisDeviceOnly`) → an honest explain variant (the account-wide bullets
  would be false) → the ordinary screens → `runner.enterCastle(…, thisDeviceOnly: true)`.
- **The runner (the belt + the road):** a signed-out library holding material is REFUSED the local road unless
  `thisDeviceOnly` (`signInOrThisDeviceOnly` — the model re-offers the two doors); `thisDeviceOnly` with a session at the
  act is refused (`thisDeviceOnlyWhileSignedIn`). The This-Mac-Only road FORGETS FIRST — before its first marker,
  verified by a re-read (material must read nil, else `syncKeysNotForgotten`, nothing else changed) — then steps 4–7
  exactly as a pre-sync library (U1's gate i / `endSwitch` / `switchPending` ride along unchanged — asserted in a pin).
  Forget-first ELIMINATES the "re-keyed library still holding the old account's material" window rather than racing it:
  no marker of this road ever exists beside held material, and a crash after the swap meets a signed-in relaunch with
  nothing for the follow-into-Standard arm to act on (that arm reads no marker — see F-U2-2).
- **Carried by the resume (the belt):** a pending LOCAL Castle marker (entersCastle ∧ not a follow ∧ no corpus id —
  only the local road writes that shape) whose resume finds material in custody FORGETS it before finishing (verified):
  the This-Mac-Only road whose material came back between the crash and the resume (the reconcile's silent Standard
  enroll re-lands it when the crash left the library Standard-shaped and she signs in), or a pre-fix build's silent road.
- **The honest Done across a crash:** a per-store-id flag beside the dials (`ProtectionDefaults` —
  `thisDeviceOnlySwitch`, written before the forget, cleared with the marker) tells the resume this road was This Mac
  Only (the marker cannot carry it — `RotationMarker` lives in `Sources/VariorumCore/Sync/`). `Outcome.thisDeviceOnly`
  ⇒ the selector renders the This-Mac-Only Done (by the fresh snapshot's fate), never `enteredCastleDone`.
- **The Apple arm (F-U2-1's fix):** `reconcileAppleKey` writes nothing while the consent is owed — no sync custody at
  this ready, the library key behind the gate (resident adopted), and the library's OWN posture Castle. Robust to the
  stale `vaultReading` an offline ready keeps (unlike keying on `enrollReading`, which a nil reading clears).
- **The consent** de-capped + a wording pass (PROVISIONAL). **The phone** composes the same model; its sheet renders
  the two new phases and the explain variant (same copy). **Item 7:** the banner, its door, the sync row's label and
  door read the pending marker's act (`CeremonyAct(resuming:)`) through a new marker read on `EncryptionSession`.
- Zero lines in `Sources/VariorumCore/Sync/`; no schema.

### Findings for the orchestrator (dispositions owed by the run)
- **F-U2-0 — RECORD INTEGRITY: commit `95879dc3` (the U1 record close) truncated this file.** It replaced §C's body from
  "Append your record as `## U1 RECORD (VX-202)`" through the old LIVE STATUS — §C's required reading, defect, fix,
  pins, constraints and testing protocol; the run's LIVE STATUS (kickoff, coordinator grants + its three riders); the
  **VX-206 MACHINERY RULING**; and **HER CARRIED-FORWARD REMINDERS (verbatim)** — with the U1 record's top. The text is
  intact at `08479fff`/`c2f188b7` (`git show c2f188b7:notes/plans/fixes/vx-201-castle-prelaunch-fixes.md`, lines
  ~199–300). U4's brief is told to cite the VX-206 ruling that is no longer here. Not restored by me (the orchestrator's
  sections); flagged so a fresh session never reads the truncated text as the whole.
- **F-U2-1 — the second silent revert (the Apple arm), FIXED here (`2397ae55`).** See the trace's leg 3. The guard keys on
  the library's own shape (no sync custody at this ready · the key behind the gate · its own posture Castle), not on
  `enrollReading`: an offline ready clears that reading while `vaultReading` keeps the last Standard word, so a guard on it
  would let the arm land the copy at the first offline ready after a sign-in. Pre-existing for EVERY Castle-born library
  joining a Standard account (corner 6) — the existing pin `Phase13pControllerTests.enrollsFourDirections…` (d) never
  read the key file. A product reading the orchestrator should confirm: until Join, the Protection pane still reads
  "You're in Standard" (the account's word, decision 8) over a library that is Castle-shaped and asks at every open —
  pre-existing corner-6 display (F-U2-4), now with no write behind it.
- **F-U2-2 — `reconcileFollow`'s follow-into-Standard arm reads no MARKER** (only the controller's in-memory
  `switchInProgress`), so a crashed switch whose library holds the account's material can be silently followed at a
  signed-in relaunch. After this unit no local road leaves material beside its marker (forget-first + the resume's carry)
  and the enrolled roads' vault is already Castle when their marker stands, so no road is known to reach it; recorded
  for the ladder, not built (U1 gave the marker read to the Apple arm only).
- **F-U2-3 — the plain local road over an enrolled-SHAPED key file without material** (a restored copy of a synced
  library, or a library whose keys were forgotten earlier, signed out) keeps §A refinement 4's plain road AND the
  ordinary Done, whose "your other devices will ask the next time they open" is false there (no account follows). Not
  built: the This-Mac-Only Done's "delete that account if you still can" would be harmful advice for a copy whose account
  she still uses everywhere. A copy question for #215 (a third Done, or the ordinary Done minus its devices clause on any
  library whose account this road did not move).
- **F-U2-4 — signed in, not enrolled, Castle-shaped (after Cancel at the consent, or any corner-6 library):** the pane
  reads Standard and offers Use Castle…, whose road is the plain local road again (signed in ⇒ no doors, no material ⇒
  no belt) with the ordinary Done. Harmless (it re-keys locally), dishonest in its Done's devices clause. Pre-existing;
  candidate ticket.
- **F-U2-5 — a pre-existing unresumable window on EVERY road:** the `.rekeyLibrary` marker is written before
  `writeNewKeyFile`; a crash between them leaves a marker naming a key file that does not exist, and every resume throws
  `rekeyFailed("the new key file is missing…")` — sync refused for good. Tenths of a second (one Argon2id derivation).
  Not this unit's; candidate ticket.
- **F-U2-6 — the canon copy record is stale:** `notes/plans/pre-13x-copy.md:676` still carries the consent's FIRST
  wording (not even RUN A row 10's); the closeout lands her approved #215 wording there.
- **F-U2-7 — the Sign In… door's face is a nested sheet** (the account sheet over the ceremony sheet; closing it closes
  the ceremony) on both platforms — compiled, read as code by a pin, NOT walked (stage).
- **F-U2-8 — the walk needs a planted state:** the dev store never syncs (the A4 fence), so "signed out with the sync
  keys held" cannot arise there by use; the orchestrator's walk needs the dev scope's per-store sync item planted with
  material (a throwaway material is enough — the doors key on presence) or a scripted world.

### THE PINS — `VariorumTests/VX110SignedOutCastleTests` (9 tests) and the red-on-old protocol (ALL PENDING, stage)
Run green first; then each revert ALONE: `git apply notes/plans/fixes/vx-201-u2-reverts/<R>.patch`, `build-for-testing`,
`test-without-building -only-testing:VariorumTests/VX110SignedOutCastleTests`, read which tests fail, then
`git checkout -- App/Variorum/Shared/` and confirm `git diff HEAD --stat` is EMPTY (window A's index trap does not apply —
`git apply` is worktree-only). Expect "Test run with 9 tests in 1 suite" (no `.enabled(if:)` gates; (d) writes real
Keychain items under a throwaway scope `vx110-isolation-*`, deleted in its `defer`).
| pin | test | expected red under |
|---|---|---|
| (a) the doors + the belt + the lapsed-session re-offer | `theTwoDoorsStandExactlyWhereTheSilentRevertWasReachable` | **R-a** (`R-a-no-doors`): the held world reaches `.explain`; the direct `enterCastle` runs instead of throwing; the lapsed leg ends `.done`, not `.signedOutChoice` |
| (b) This Mac Only → the OLD account: consent, no follow, no Apple copy | `thisMacOnlyThenSigningIntoTheOldAccountLandsTheConsentNeverTheFollow` | **R-b1** (`R-b1-no-forget`): material rides behind the gate; after sign-in the follow re-adds `apple` and moves custody silent · **R-b2** (`R-b2-apple-arm-lands`): the key file gains `apple` at the sign-in ready · **R-f**: `model.doneBody` |
| (c) killed before the swap, material re-landed | `aThisMacOnlyRoadKilledBeforeItsSwapFinishesWithTheOldAccountsKeysForgotten` | **R-c** (`R-c-resume-no-forget`): material survives the resume and lands behind the gate · **R-b1**: material present right after the kill · **R-f**: the Done |
| (c2) killed after the swap | `aThisMacOnlyRoadKilledAfterItsSwapResumesToTheHonestDone` | **R-c2** (`R-c2-resume-ignores-flag`): `outcome.thisDeviceOnly` false → the ordinary Done · **R-f** |
| (d) per-store custody isolation | `forgettingOneLibrarysSyncKeysLeavesAnotherLibrarysCustodyWhole` | BOUND — green under every revert (the property the road leans on) |
| (e) born-Castle setup from the This-Mac-Only library | `syncSetUpFromTheThisMacOnlyLibraryBirthsACastleAccount` | BOUND — green under R-a/R-b2/R-c/R-c2/R-f/R-7 (no line of this unit on its road); R-b1 changes its precondition (material held) and may go red — irrelevant to the bound |
| (f) the words | `theThisMacOnlyScreensAndDoneNeverSpeakTheAccountWideWords` | **R-f** (`R-f-ordinary-done`) |
| faces as code | `bothFacesRenderTheTwoDoorsAndTheExplainByTheRoad` | a face reverted by hand (no patch — a structural pin) |
| item 2 | `theRekeyBannersAndTheSyncRowNameThePendingMarkersAct` | **R-7** (`R-7-one-act`) |

**Existing suites (changed-SOURCE rule — every Mac suite whose source names a changed type) — PENDING, one stage run**
from `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath
DerivedData/vx201` plus `-only-testing:VariorumTests/` + each of: VX110SignedOutCastleTests VX202ReopenRaceTests
VX80CastleFollowRecoveryTests PostureSwitchTests Phase13pControllerTests Phase13pLobbyTests StoreLaunchRouteTests
Phase13pKeyedDrillTests LobbyVaultRoadTests LibraryPortabilityDoorTests AppleRelinkDoorTests AppBootstrapOffMainTests
CustodyReleaseTests KeyDoorTests WordsCopyDoorTests CopyRegisterPinTests ProtectionMigrationTests
ProtectionSurfaceRenderTests ProtectionTierFaceTests ProtectionDialsTests ProtectionDialsPerStoreTests ProtectionCopyTests
ProtectionCadenceTests StoreKeyGuardBackingTests RetiredNamesPinTests SyncLockedFaceTests EncryptionFlowTests
CopyFlowRoundTests CrossoverRoundTests AccountLifecycleDoorTests AccountDoorWiringTests TerminologyPinTests
FreshAccountSetupGeneralityTests AuthSessionLazyLoadTests EncryptionCustodyThreadTests ProtectionSetModeOffMainTests
ProtectionReconcileOffMainTests SyncEnrollmentTests EnrollDirectionsTests ConnectLibraryTests Phase13pCopySweepTests
SecretCheckTests SyncOutOfDateFaceTests SyncSafetyFaceTests SyncStalledRowTests HostedSyncStatusReadTests
HostedSyncTierFaceTests MarkdownInsuranceTests PlaintextExportDoorTests ICloudDriveOfferTests SignUpPresentationTests
Phase9cAuthWiringTests TravellingDotsIndicatorTests BackupRunTests BackupOwnFilesTests BackupRetentionTests
BackupSingleFlightTests DataSafetyRunbookTests TutorialPrivacyChapterTests PostureSwitchDrillTests
ProtectionMigrationDrillTests ConnectDrillTests EncryptionExplainedDrillTests (the drills opt-in by env as window A
recorded — TEST_RUNNER_ vars in xcodebuild's ENVIRONMENT; the posture drill's VX-233 rot is pre-existing). The changed
consent pins live in `ProtectionCopyTests` (two of its tests). Phone (simulator stage, by UDID):
`VariorumMobileTests/MobileProtectionTests` (its consent pin re-based) + `VariorumMobileTests/MobileStructuralTests` (the
phone's copy-home sweep reads the new strings) + `VariorumMobileTests/MobileWindowReplayTests`.

### The phone's door (§D item 6 — read, confirmed)
`MobileProtectionSheet.postureSection` offers Use Castle… under `controller.posture == .standard` (the Mac's own rule)
and opens `controller.openSwitch(.enter, …)` — the SAME `PostureSwitchModel`, so the fork, the belt, the forget and the
honest Done are shared by construction. `MobilePostureSwitchSheet` now renders `.signedOutChoice` (Sign In… · Use Castle
on This iPhone Only · Cancel, the phone's stacked doors), `.signInChosen` (the account surface over the sheet, the page
style injected), and Screen 1 by the road (`model.explainBody` / `explainBullets`). The phone never reaches the old
silent road with the ordinary Done. Built (phone `build-for-testing` green); not run (simulator stage).

### PROVISIONALs (mine — each defended; the orchestrator's to confirm or bundle)
- **P-U2-1 — Sign In… ends the ceremony** (no auto-resume across an async sign-in — §A refinement 4's call, built as
  briefed); the account surface opens over the ended ceremony and closing it closes the ceremony.
- **P-U2-2 — forget-FIRST, before the first marker** (the brief allowed "before or atomically with the custody move"):
  no marker of this road ever stands beside held material, and a crash after the swap meets a signed-in relaunch with
  nothing for the follow-into-Standard arm (F-U2-2) to act on. The resume's carry is the belt for material that comes
  BACK (pin (c)). Cost: a This-Mac-Only road that fails after the forget but before its marker (one derivation) leaves the
  library unchanged but its keys forgotten — benign (a Standard library re-enrolls silently at the next sign-in).
- **P-U2-3 — the resume forgets on ANY local Castle marker beside material** (not only a flagged one): that state is the
  This-Mac-Only road whose material came back, or a pre-fix build's silent road; finishing either with the material in
  custody is the silent revert. A pre-fix marker's resume therefore BECOMES This Mac Only, honest Done included
  (population: pre-launch builds only — her devices + one tester; requires a crashed old road).
- **P-U2-4 — This Mac Only refuses when a session exists at the act** (`thisDeviceOnlyWhileSignedIn`, nothing written):
  the screens verified her words against the key file (the tie was absent at the door), so running the account-wide road
  on them is not this unit's to improvise.
- **P-U2-5 — the honest explain screen** (Screen 1's body and its first bullet replaced on This Mac Only; the backups
  bullet kept; the compromise bullet DROPPED on this road — its "set sync up again" implies a new account, her reminder
  1's subject).
- **P-U2-6 — item 2 changes words only for acts that ENTER Castle** (a key replacement and an unknown act keep the shipped
  sentences — the smallest change that makes every face name the marker's act).

### U2 COPY DRAFTS (for the QUESTIONS #215 bundle — every line PROVISIONAL until she approves)
Sentence case, no capitals for emphasis, the everyday register ("sync keys", never a key's technical name). The device
words ride interpolation (Mac / iPhone, login password / passcode, Touch ID / Face ID); shown here in the Mac's nouns.
1. **The two doors' title** (`signedOutChoiceTitle`): *You're signed out of sync.*
2. **The two doors' body** (`signedOutChoiceBody`; also the belt's refusal sentence): *This library still holds the sync
   keys for your account. To put the account and your other devices in Castle, sign in, then choose Use Castle again. If
   you can't sign in, or you're leaving that account, you can put only this Mac in Castle — it forgets those sync keys,
   and the account and its copy on the server stay as they are.*
3. **The doors:** *Sign In…* (the shipped `signInDoor`, reused) · *Use Castle on This Mac Only* (`useCastleThisDeviceOnlyDoor`
   — Title Case per the app's door convention; her ruling's words were "Use Castle on this Mac only") · *Cancel*.
4. **After Sign In…** (`signInFirstTitle` / `signInFirstBody`): *Sign in, then choose Use Castle again.* / *Your account
   and your other devices go into Castle together. Nothing has changed yet.*
5. **Screen 1 on This Mac Only — body** (`enterCastleThisDeviceOnlyBody`): *Your library on this Mac gets a new key. From
   now on this Mac's login password can't open it, and your Apple account holds no key to it. Opening takes Touch ID or
   your passphrase.*
6. **Screen 1 on This Mac Only — the first bullet** (then the shipped backups bullet, unchanged):
   *Only this Mac changes. It forgets your sync keys; your sync account and its copy on the server stay as they are, and
   your other devices aren't asked. If you sign into that account here again, Variorum asks before it changes anything.*
7. **The This-Mac-Only Done** (`enteredCastleThisDeviceOnlyDone`, three arms by the fresh backup's fate — the ordinary
   Done's own rule): *You're in Castle on this Mac. Your library here has a new key that your Apple account never held.*
   [*A fresh backup was made under it.* | *A fresh backup could not be made just now — check your Backups folder; your
   earlier backups are untouched.* | (the phone: nothing)] *This Mac asks for Touch ID from now on. Your sync account and
   its copy on the server are unchanged — delete that account if you still can. If you sign into it here again, Variorum
   asks before it changes anything.*
   - **Alternative, ONLY if pin (e) is green at the stage** (her reminder 1): append *Set up sync again later with a new
     account and it starts in Castle.* — NOT shipped in the draft.
8. **The two runner refusals:** *You signed in while this was open, so nothing was changed. Choose Use Castle again to
   put your account in Castle.* (`thisDeviceOnlySignedInSince`) · *This Mac couldn't forget your sync keys, so nothing
   was changed. Try again.* (`thisDeviceOnlyForgetRefused`)
9. **The consent, de-capped + reworded** (`joinStandardConsent`; her ruled order kept — cancel · the account into
   Castle · join again): *This account is in Standard, so if you join, this library will open without asking from now on
   and your Apple account will hold a key to it. If you'd rather stay in Castle: Cancel here, put the account itself in
   Castle from a device already signed into it (Settings ▸ Protection ▸ Use Castle…), then join again.*
   (was: *…will open silently from now on… If you'd rather not leave Castle: Cancel here, put the ACCOUNT in Castle…*)
10. **Item 2 — the sync row** (`SyncStatusRow.rekeyIncompleteLabel(for:)` / `SyncRowFace.rekeyIncompleteDoorLabel(for:)`,
    entering-Castle markers only): *Sync paused — entering Castle didn't finish on this device* · *Finish entering
    Castle…* (the banner reuses the shipped `ceremonyResumeTitle` + *Finish Entering Castle…* — no new sentence).
Copy rhyme (the VX-214 rider): none of these sit on a Settings pane's own text; the Protection pane renders only the
ceremony sheet's phases. Overlap declared: `ProtectionPane.swift` gained the ceremony sheet's two new phases and ONE
argument on each of the sheet's two presenter lines (`services:`), nothing of the pane's own sections.

### ORCHESTRATOR — F-U2-0 RESTORATION + U2 ADJUDICATION PART 1 (2026-10-13 ~03:20)
- **F-U2-0 RESTORED:** 95879dc3 (U1's record close) truncated 120 lines — §C's body, the run's whole
  `## LIVE STATUS` (the coordinator grants, the three riders, the VX-206 machinery ruling, her carried-forward
  reminders verbatim), and the `## U1 RECORD` header. All spliced back from c2f188b7's intact version
  (probe-verified: the VX-206 ruling, her reminders, the custody grant are all present again); U1's surviving
  record body kept in place under its restored header. Lesson recorded: implementers APPEND records — a close
  that rewrites earlier sections is the failure class here; later briefs say "append, never restructure".

### ORCHESTRATOR ADJUDICATION — U2 PART 2 (verified against git: commits 73b2f0ca → e5ec6d24 as reported, zero
`Sources/VariorumCore/Sync/` lines, zero trailers, seven revert patches present, builds green per record; the
F-U2-1 diff READ by the orchestrator — a 15-line early return in `reconcileAppleKey` keyed on the library's own
shape (no sync custody + gated/none + own posture Castle); an enrolled library carries custody and is untouched,
and a consented Join lands its copy on its own follow road)

- **F-U2-1 — ACCEPTED, in scope.** Without it, the two-door fix's own consent sentence ("asks before anything
  changes") would be false: the reconcile's Apple arm was the second silent road around the consent, pre-existing
  for every Castle-born library joining a Standard account. Mechanism verified by my read; red-on-old rides pin
  (b) under R-b2. The Fable ladder re-examines (custody).
- **P-U2-1 (Sign In… ends the ceremony) — CONFIRMED** (§A refinement 4's own shape); bundled in #215 as hers to
  reverse. **P-U2-2 (forget FIRST, before the first marker) — CONFIRMED,** stronger than the brief asked and
  better: removes the crash window instead of racing it. **P-U2-3 (the resume forgets for any local Castle
  marker beside held material) — CONFIRMED;** consequence noted: a PRE-FIX build's crashed signed-out ceremony
  resumes into This-Mac-Only semantics, which is the honest reading of what that user chose. **P-U2-4 (This Mac
  Only refuses while a session exists) — CONFIRMED** (a live session gets the full road or signs out first).
  **P-U2-5 (Screen 1 drops the compromise bullet) — copy call, #215.** **P-U2-6 (item 7 words change only for
  Castle-entering acts) — CONFIRMED.**
- **F-U2-2 — record-only** (no road reaches it after this unit; the ladder may look once).
- **F-U2-3 — #215's copy bundle** (the once-synced-no-keys copy's "your other devices will ask" line; the
  implementer's reason for not reusing the This-Mac-Only Done is right — "delete that account" would be harmful
  advice for a copy of a live account).
- **F-U2-4 — pre-existing (the VX-108 family); a comment lands on VX-108 at closeout,** not this run's.
- **F-U2-5 — TICKETED** (a crash between the `.rekeyLibrary` marker and the key-file write leaves a marker no
  resume can finish; every road; needs its own trace).
- **F-U2-6 — handled at the #215 commit:** `pre-13x-copy.md:676` gets a one-line supersession pointer to the
  de-capped consent (never a rewrite of the historical record).
- **F-U2-7/F-U2-8 — the walk's:** the Sign In… nested sheet walks in my window; the dev-store walk plants key
  material in the dev scope's sync item first (the record's own note).

### WINDOW B RECORD (orchestrator, stage claim vx201-u1-reverts — the pinned checkout, never the live worktree)
All SIX revert cycles ran; each RED exactly on its pin-table reds, each restore verified clean (empty porcelain):
R-a1 (arm pre-fix): the race pin + the marker pin + the control's `scheduled` assert — 5 issues (the marker pin's
red under R-a1 is the SUPERSET revert behaving consistently: the whole arm gone takes gate ii with it; the
table's per-leg attribution stands). R-a2 (gate i only): the race pin alone via `relanding` non-nil — 1 issue.
R-b (marker unread): the marker pin alone (the stale key overwritten) — 1 issue. R-c (no sweep): both sweep pins,
the local one on all four asserts (silent stays · posture Standard · the Apple copy lands · no lock) — 5 issues.
R-d1 (flag ignored): the landing-arm pin (the copy lands) — 1 issue. R-d2 (no flag written): the flag-span pin
on three asserts — 3 issues. The three BOUND pins (only-road-in · Standard-waiting untouched · adoption
inertness) stayed GREEN through every cycle. **U1's red-on-old obligation DISCHARGED; VX-202's acceptance
evidence is complete** (green pass 305/38 + drills disposition + simulator + the six cycles). Logs
/tmp/vx201-wb-*.log, rollup /tmp/vx201-window-b.summary (deleted at closeout per the tidy rule).

### HER TWO RULINGS AT THE COMPACTION SEAM (2026-10-13, the question tool, recorded verbatim-faithful)
- **VX-233 (the posture-drill harness rot): "Time-boxed tonight"** — the heal is attempted inside this run,
  capped at ~90 minutes of trace + fix; if the detached-task scope proves deeper, it falls back to the
  post-launch ticket automatically. Slots after U5, before/beside the ladder; the drill re-run needs a stage
  window; the fix is TEST-HARNESS side unless the trace proves otherwise (any product line re-opens the question).
- **The field-guide re-seed: "Morning, your hands"** — her real store is NOT re-seeded tonight; the morning
  handoff's checklist carries the one product-door press for her. The refresh tail drops the re-seed; F6's
  custody sweep stays a pre-cleared done fact to name. (The coordinator's veto question is answered by this
  ruling — relayed.)

## U3 RECORD (VX-203 + VX-208)

**Not done in this unit (stated first):** IN PROGRESS — this line is rewritten at the close.

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- 2026-10-13 ~03:15 — U3 implementer (Opus) started. Reading done in this session, never delegated: this file
  whole (§A, §B, §E, the U1 + U2 RECORDS and adjudications, windows A/B); `notes/SessionResiliencyProtocol.md`;
  `notes/SyncSpec.md` in full; VX-191 §O.2 + §V–§X; auditor B whole (B1a–B1f, B2, B3c); the postures design
  decisions 1–35, §4 steps 4–7, §5, §6, §14 corners 1–48; VX-203 (no comments) + VX-208 (her ruling comment);
  the code §E names plus `LibraryClassifier`, the four offer/Done face sites and `CopyRegisterPinTests`.
- MACHINERY NOTE: my first pass STOPPED at the reading's end (no write) when `6913e6a5` (the orchestrator's WINDOW
  B append) landed in this worktree; the orchestrator confirmed it was theirs, amended the rule (stop only if CODE
  files or my own sections move; notes-only orchestrator commits are expected), ACCEPTED F-U3-1 and approved the
  design below as written. Resumed in the same session.
- DONE `c0b96287` — piece 1 (core): the adoption's naming hoisted to constants (paths byte-identical, pinned) +
  `Sources/VariorumCore/Persistence/LibraryAsideCopies.swift` + `Tests/VariorumCoreTests/LibraryAsideCopiesTests.swift`
  (6 pins). VERIFIED headless: `swift test --filter "LibraryAsideCopiesTests|LibraryAdoptionTests"` — 13 tests in 2
  suites passed. Revert patches R-a/R-b/R-c in `notes/plans/fixes/vx-201-u3-reverts/` (git-apply-checked).
- IN-PROGRESS — the three CORE revert cycles (headless, mine to run): the tree is committed; each cycle is `git apply`
  of one patch, `swift test --filter LibraryAsideCopiesTests`, then `git checkout --
  Sources/VariorumCore/Persistence/LibraryAsideCopies.swift` (worktree-only — no index trap) and `git diff --stat`
  empty. If this line still reads IN-PROGRESS, check `git diff` for a reverted file before anything else.
- NOT-STARTED — piece 2 (Shared runner + models + faces): the two inert-by-default leaves, `Outcome.preSwitchLibraryCopies`
  + `Outcome.hasOffer`, the counted offer body, the four faces.
- NOT-STARTED — piece 3 (VX-208): the one line on every Done that entered Castle, both models, four faces.
- NOT-STARTED — piece 4: Mac pins (ceremony + follow road list, delete/keep, counts, the line, faces as code),
  revert patches under `notes/plans/fixes/vx-201-u3-reverts/`, `build-for-testing` (Mac + phone), the close.

### The settled design (approved by the orchestrator before any code; F-U3-1 ACCEPTED)
- **F-U3-1 — what "a key file carries `apple`" means:** the key file Variorum itself would open the copy with —
  `StoreKeyEnvelope.locate` beside the folder's ONE `.sqlite` (the classifier's own rule for an ordinary-named
  store, i.e. what File ▸ Open Library would read), NOT any key file in the folder. Mechanism: the acting device
  keeps its Standard-era key file (`apple` over the OLD key) beside a re-keyed Castle library (audit O.4/B6c), and an
  adoption moves BOTH key files aside — "any key file" would sweep a Castle-era copy into the Standard-era delete,
  the exact failure §A bound 1 forbids. `locate` picks by newest mtime; `moveItem` and `copyItem` both preserve
  mtimes (verified by experiment), so the rule holds in both homes.
- **Core:** the adoption's names move to constants `plan()` reads (paths byte-identical); `LibraryAsideCopies.swift`
  lists both homes oldest first, qualifies a folder (the adoption's naming + a stamp that reads back exactly + the
  parent IS the home + one store + the located key file carries `apple`), and its remover re-runs that whole
  qualification before removing the stamp folder — it can never delete a path outside the two homes, nor anything
  the lister would not list.
- **Shared:** `preSwitchLibraryCopies` / `deleteLibraryCopies` leaves inert by default (scripted worlds unchanged),
  `.live` wires the core; `snapshotAndInsurance` (the ONE site the ceremony, the follow and the resume share) lists
  both kinds under the existing condition (a written fresh snapshot, the road's listing rule); `Outcome.hasOffer`
  replaces the five `!preSwitchSnapshots.isEmpty` sites; `deletePreSwitchSnapshots` removes both and returns the sum;
  the offer body carries honest counts ("copies", never "libraries" — one adoption leaves two folders) and one
  owning sentence.
- **VX-208:** one line on every Done that entered Castle, right after the insurance notice, regardless of the weekly
  toggle (manual Markdown exports and an earlier export's leftovers exist either way); PROVISIONAL placement, the
  Mac-only alternative recorded.
