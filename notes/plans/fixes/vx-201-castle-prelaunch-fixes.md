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

## §F — U4 BRIEF (VX-204 + VX-206: the guide's honest sentence + the ceremony ends on Protection — ONE implementer session, Opus xhigh)

**Product frame first:** the author's own writing app making its privacy guide honest and its ceremony's landing
calm before public release — the field guide must not claim more than the encryption covers, and entering Castle
from Settings ▸ Protection must put the user back where they acted, not on General. Defensive work on her code,
at her request. You are the U4 implementer. Work ONLY in `~/dev/variorum-vx-201`. APPEND
`## U4 RECORD (VX-204 + VX-206)` to this file — **append-only: never restructure, truncate or rewrite anything
above your own section** (95879dc3's truncation is the failure class; your close touches only your section).
LIVE STATUS first, commits per piece ("Part of VX-204" / "Part of VX-206"), push after every commit, no
attribution trailers. The ENVIRONMENT TRAPS section binds verbatim; `notes/SessionResiliencyProtocol.md` binds
you — read it. The orchestrator's notes-only commits in this worktree are expected: pull before each commit;
stop only if CODE files or your own sections move under you.

**Required reading (never delegated):** this file WHOLE — §A's VX-204 and VX-206 entries, the run LIVE STATUS's
**VX-206 MACHINERY RULING** (it is the binding design for VX-206), her compaction-seam rulings (the re-seed is
HERS in the morning — NOTHING in this unit touches her real store or re-seeds anything), the U1/U2/U3 records +
adjudications; `notes/SessionResiliencyProtocol.md`; the member tickets' comments (VX-204, VX-206); then the
code: `PostureCopy.swift:781` (`privacyLessonOneParagraphs`) and BOTH its seeders (`TutorialSeeder`,
`MobileTutorialSeeder` — verify both read the ONE copy home; if either carries its own copy, say so before
building), the website's privacy brief under `notes/brand/` (the honest plain-fields sentence you rhyme with),
`AppSettingsView.swift:175-192` (`adoptMCPRequest()` — the pattern you mirror) + `MCPDoor.settingsRequest` (the
request holder's shape), `PostureSwitchModel`/`PostureSwitch.swift` (where the ceremony completes and where the
re-key teardown closes the Settings window), `ProtectionPane.swift` (the pane's info popup the landing must
show).

**VX-204 — the guide sentence (copy-only, one structural consequence):**
1. Amend `privacyLessonOneParagraphs` so the lesson stops overstating: one honest sentence saying that dates,
   the tag tree's shape, memberships, flags and sizes travel outside the encryption (rhyme with the website
   privacy brief's own wording; everyday register, no key names; sentence case, no capitals for emphasis).
   The smallest edit that makes the paragraph true — this is her guide's voice, not a specification.
2. Both platforms ship it through the one copy home (verify, don't assume). Existing stores keep the stale
   sentence by design (seeded content): her real store's re-seed is HER morning press (ruled — out of scope
   here), and U5's guide warning rides the same seed, so one press covers both.
3. Pin: string-level — the lesson paragraphs carry the honest sentence (red-on-old by revert); plus a
   seeders-share-the-home pin if none exists.

**VX-206 — end on Protection (the MACHINERY RULING is the design; VX-214's narrow exception binds):**
1. Build the Protection twin of the MCP request pattern: a request holder the ceremony bumps at its END (the
   Done, and the teardown road that closes/reopens the Settings window across the re-key) + ONE adopter in
   `AppSettingsView` mirroring :175-192 — **nothing else in that file** (zero pane internals; VX-214 owns the
   panes this week; the orchestrator sends them the final hunks after you land).
2. The request fires only for a ceremony that was OPENED from Settings ▸ Protection (read how the ceremony
   knows its origin; if it genuinely cannot, bump where the Settings-origin road completes and say so in the
   record). The adopter selects Protection and shows the pane's info popup — the ticket's words: END on
   Protection with its info popup showing, not on General.
3. Pins (red-on-old by behavioral revert): (a) the Settings-origin ceremony's completion bumps the request and
   the adopter lands Protection + arms the popup; (b) a ceremony NOT from Settings bumps nothing (General's
   default untouched); (c) the request survives the re-key teardown (whatever holder shape you build, pin its
   life across the window close). The WALK evidence (§B: "walk-verified") is the ORCHESTRATOR's stage walk —
   you do not walk, do not launch the app, do not claim it.

**Copy:** every new or changed sentence in `### U4 COPY DRAFTS` for the QUESTIONS #215 bundle — sentence case,
no capitals for emphasis, everyday register.

**Constraints:** ZERO lines in `Sources/VariorumCore/Sync/`. No schema. Zero pane-internal lines beyond the
request holder + adopter. Mac-target suites are STAGE work — `build-for-testing` only (Mac AND phone: the
seeder copy is shared), suites listed PENDING with `-only-testing` arguments; headless `swift test` freely. One
read-only Sonnet for EXTERNAL facts only, if ever. Foreground waits only.

## §G — U5 BRIEF (VX-209: the way-back revert's confirm line + guide warning — ONE implementer session, Opus xhigh)

**Product frame first:** the author's own writing app being honest at the one door where Castle can quietly
come undone — opening or restoring an old copy of the library — before public release. Defensive work on her
code, at her request. You are the U5 implementer. Work ONLY in `~/dev/variorum-vx-201`. APPEND
`## U5 RECORD (VX-209)` to this file — **append-only: never restructure, truncate or rewrite anything above
your own section**; your close touches only your section. LIVE STATUS first, commits per piece ("Part of
VX-209"), push after every commit, no attribution trailers. The ENVIRONMENT TRAPS section binds verbatim;
`notes/SessionResiliencyProtocol.md` binds you — read it. The orchestrator's notes-only commits are expected:
pull before each commit; stop only if CODE files or your own sections move under you.

**Required reading (never delegated):** this file WHOLE — §A's VX-209 entry (the deeper fix is DELIBERATELY
out: the stranding argument; it is recorded on VX-209's ticket — do not build it), her carried-forward
reminder 2 in the run LIVE STATUS (the trace was READ, never RUN — your first deliverable runs it), the U1
RECORD + ADJUDICATION (F2 especially: the pre-fix outcome on disk persists, and the guide instruction is that
victim's road too; and belt c's exact shape — the landing arm refuses only while `switchPending`, so a
restore's silent-Standard PERSISTS once custody landed), the U2–U4 records; `notes/SessionResiliencyProtocol.md`;
`notes/plans/fixes/vx-191-encryption-audit.md` §W.2 (the trace, verbatim); `notes/SyncSpec.md` IN FULL (custody
seams); `notes/plans/phase-13x-library-portability.md` (the Open Library/adopt/restore machinery + decision 11);
`notes/plans/pre-13x-postures-design.md` §14 corner 45; then the code: `LibraryClassifier`,
`LibraryOpenModel`/`LibraryOpenCopy.swift`, the Data Safety Restore-from-Backup faces, `StoreBackup.swift` (the
pair), the plaintext-export adopt arm, `StoreLaunchGate.swift` (`rawKeyCustody`, corner 45, belt c's flag),
`PostureCopy.swift` (the field guide's Castle section — where your warning lives).

**The build — STRICTLY in this order (§B's amended evidence row; her reminder 2 binds):**
1. **FIRST, the reproduction pin — §W.2's round trip at HEAD.** A Castle library; open/restore a Standard-era
   backup pair of the SAME library — it lands Standard silently; then bring the Castle-era copy BACK — the
   trace claims it ALSO lands Standard (the way-back revert). Pin exactly what the trace claims, at the
   adopt/classifier level, headless where the machinery allows. If the pin comes out GREEN-ON-HEAD (no
   reproduction, in whole or in part), STOP that leg: record what actually happens, write NOTHING on the trace,
   and report to the orchestrator — the confirm line may still proceed on the classifier facts alone, the guide
   warning must be rewritten against the observed behavior.
2. **THEN the confirm line** on the Open Library / Restore confirm: when the CURRENT library is Castle and the
   INCOMING one reads Standard — BOTH classifier arms: a backup pair that reads Standard, AND a plaintext
   export (always effectively Standard) — one sentence saying the library will open the old way afterwards and
   naming the road back. Pinned on the classifier for both arms; red-on-old by revert. The line renders on
   every face that runs the adopt (File ▸ Open Library, the Data Safety twin, Restore from Backup) — one copy
   home, never three sentences.
3. **THEN the guide warning** in the field guide's Castle section: instructions for reading an old backup —
   afterwards check Settings ▸ Protection and choose Use Castle again. Written against U1's LANDED behavior
   (belt c refuses only while a switch is pending, so the instruction STANDS) and against your reproduced
   trace, never against the pre-fix code or the unrun reading. It is ALSO the pre-fix victims' road (F2's
   adjudication) — the sentence serves both honestly. It rides the same seeded guide as VX-204: the re-seed is
   HER morning press; say nothing about re-seeding.

**Copy:** every new or changed sentence in `### U5 COPY DRAFTS` for the QUESTIONS #215 bundle — sentence case,
no capitals for emphasis, everyday register (no key names on everyday surfaces).

**Constraints:** ZERO lines in `Sources/VariorumCore/Sync/`. No schema. No change to the adopt/restore
MACHINERY — this unit is a confirm line, a guide warning and the pins that hold them (the deeper fix is
VX-209's ticket). Mac-target suites are STAGE work — `build-for-testing` only, suites listed PENDING with
`-only-testing` arguments; headless `swift test` freely. One read-only Sonnet for EXTERNAL facts only, if ever.
Foreground waits only.

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
- 2026-10-13 post-compaction: the orchestrator resumed from the handoff (26ef247a) + this record, state verified
  by git/ListAgents. Coordinator ACK (verbatim-faithful): both seam rulings received and recorded their side —
  VX-233 time-boxed tonight inside this run, the re-seed HER hands in the morning, F6 stays pre-cleared. Window
  C protocol: READY when the pinned checkout finishes its rebuild; the coordinator may SPLIT the window (green
  pass + phone suites first, the seven revert cycles after another session's short window) if the queue wants
  it, else one ~90-min claim. The pinned checkout is ADVANCED to a208a24a deliberately — U2-complete and
  PRE-U3-Shared, so U2's seven revert patches (App/Variorum/Shared/) apply cleanly there while U3 keeps building
  in the live worktree; U3's own suites run at a later window at U3's tip.

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

**Not done in this unit (stated first):** no `xcodebuild test` of any kind (stage work, per §E) — the 4 Mac pins,
their four red-on-old revert cycles and every existing Mac/phone suite below are **PENDING** the orchestrator's stage
window; **no walk** (GUI work needs a held stage claim, which this unit was not granted — the walk recipe for the
orchestrator's window is below, under THE WALK); the phone's simulator suites not run. The headless half IS done:
the core pins and their three revert cycles ran here (below). No `notes/QUESTIONS.md` entry (merge-moment-only — the
drafts below are #215's input). Out of scope as briefed and untouched: B1e's unreachable second folder (VX-210) and
B1f's folder-level key files. Zero lines in `Sources/VariorumCore/Sync/`, no schema, no custody code.

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
- DONE — the three CORE revert cycles, run headless by me (each: `git apply`, `swift test --filter
  LibraryAsideCopiesTests`, `git checkout --` the one file, `git diff --stat` read EMPTY). Results, 6 tests each:
  **R-a** (no home reached) → RED: (a) the adoption's two copies · (b)'s control line (the Standard-current copy) ·
  the refusal pin's listing line · the listing pin; green: (c), the plan pin. **R-b** (any key file's `apple`
  qualifies) → RED: (b) alone — the O.4 two-key-file Castle copies listed, `isAppleOpenable` true, and the remover
  DELETED them. **R-c** (no naming match) → RED: (c) — the A1 rail folder and every foreign folder listed and
  removed — and the refusal pin's home-link leg (the patch drops the home-is-a-real-directory legs with the naming
  block: the remover deleted another library's copy through a planted link). Every bound green where expected.
- DONE `a4a0136c` — pieces 2 + 3 (status for the orchestrator's ping: built, and the Mac pins written):
  `PostureSwitch.swift` (two inert-by-default leaves `preSwitchLibraryCopies` / `deleteLibraryCopies`, wired in
  `.live` to the core; `Outcome.preSwitchLibraryCopies` + `Outcome.hasOffer`; `snapshotAndInsurance` — the ONE
  listing site — lists both kinds under the pairs' rule; `deletePreSwitchSnapshots` removes both and returns the
  sum; U1's `endSwitch`/`switchPending` and U2's `thisDeviceOnly` machinery untouched), `PostureCopy.swift` (the
  counted offer body + `plaintextExportsNotCovered` + their two by-the-outcome selectors), both models (the five
  `hasOffer` sites read `Outcome.hasOffer`; `offerBody` + `plaintextExportsLine`), the four faces (the Mac's
  `FollowSheet` + `PostureSwitchSheet` Done/offer phases only — VX-214 overlap: no pane section touched — and the
  phone's two sheets), and 4 Mac pins appended to `PostureSwitchTests` (its world's leaves wired to the same core
  functions `.live` composes).
- VERIFIED: Mac `build-for-testing` (Variorum, `-derivedDataPath DerivedData/vx201`) TEST BUILD SUCCEEDED; phone
  `build-for-testing` (VariorumMobile, generic iOS Simulator) TEST BUILD SUCCEEDED; zero warnings in changed lines
  (the three warnings in touched files are pre-existing lines). `df -h` data volume 40 GiB free.
- DONE `8b771c05` — the Mac revert patches R-d…R-g (`notes/plans/fixes/vx-201-u3-reverts/`), each `git apply
  --check` clean; the four applied TOGETHER (distinct hunks) COMPILED (`build-for-testing` TEST BUILD SUCCEEDED),
  restored by `git checkout --` the two Shared files, `git diff --stat` read EMPTY; then a fresh HEAD
  `build-for-testing` (TEST BUILD SUCCEEDED) so `DerivedData/vx201` holds the FIX's products. **No revert is applied
  now.** Their RUNS are stage work (PENDING — the pin table below).
- VERIFIED headless at the end (`swift test`, the whole core package): **2,697 tests in 308 suites passed** (the
  prior 2,691/307 + this unit's 6/1), VariorumMCPTests 135/20, the workbook 40/6 — the skips are the standing gated
  measurement/integration tests (read on the skip lines).
- CLOSED (this commit): the pin table, the stage protocol and suites, the walk recipe, the copy drafts, the
  PROVISIONALs and the findings.

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

### The traced mechanism (pin before fix — read at HEAD, confirmed)
- **VX-203 (B1d):** the offer's one listing (`PostureSwitchRunner.snapshotAndInsurance` → the `preSwitchSnapshots`
  leaf → `StoreBackup.existingBackups`) reads only the TOP LEVEL of the container's `Backups/` and the picked
  folder's `Backups/`, keeping `variorum-backup-<stamp>[-<fp8>].sqlite` files. A 13x adoption made while Standard
  leaves the outgoing library whole in `Previous Libraries/<stamp>/` (outside `Backups/`) and
  `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (a subfolder) — each beside a key file whose `apple` copy
  opens it through the Apple account. Neither is ever a candidate, nothing else deletes them, and the offer's words
  ("Delete the backups Variorum made… if you want Castle to cover everything you have ever written") imply they are
  covered. Red on old: R-a (core) and R-d (runner) reproduce the pre-fix listing; the pins fail exactly there.
- **VX-208 (B3c):** entering Castle turns the weekly export OFF (`snapshotAndInsurance`), which also stops its prune
  (`MarkdownInsurance.performRun` returns at the toggle guard), and nothing in the Castle process mentions the
  plain-text folders already written — nor Markdown exports made by hand. Red on old: R-f.

### THE PINS and the red-on-old protocol
**Core (headless — RUN HERE, all green at HEAD; reverts run, results in LIVE STATUS):**
`Tests/VariorumCoreTests/LibraryAsideCopiesTests.swift` — 6 tests.
| pin | test | red under |
|---|---|---|
| (a) the adoption's two copies listed, removed whole | `anAdoptedStandardEraLibrarysTwoCopiesAreListedAndEachGoesWhole` | **R-a** ✔ ran red |
| (b) Castle-era copies (plain + the O.4 two-key-file shape) never listed, survive | `aCastleEraCopyIsNeverListedAndSurvivesTheRemover` | **R-b** ✔ ran red (R-a reds its control line) |
| (c) only the adoption's naming in its own home (A1 rail untouched) | `onlyTheAdoptionsNamingInItsOwnHomeIsEverMatched` | **R-c** ✔ ran red |
| the remover's path guard (outside paths, `..`, another store, planted links) | `theRemoverRefusesEveryPathThatIsNotACopyBesideThisStore` | R-c (its home-link leg) · R-a (its listing line) ✔ ran red |
| (e, core) listing writes nothing; the current key's copy never named | `listingWritesNothingAndNeverNamesTheCurrentKeysCopy` | R-a ✔ ran red |
| the hoist changed no path | `thePlanStillSpellsBothHomesAsTheAdoptionAlwaysHas` | BOUND (green under all three) |

**Mac (`VariorumTests/PostureSwitchTests`, the U3 extension at the file's end — ALL PENDING, stage):**
| pin | test | expected red under |
|---|---|---|
| (a)(b)(c) through the runner: the enrolled ceremony, the local-only ceremony, the local road's RESUME; counts; Delete removes the two copies whole; the Castle-era copy and the A1 folder byte-identical | `theCeremonysOfferReachesTheCopiesAnAdoptionSetAsideAndDeletesThemWhole` | **R-d** (no copies listed; `hasOffer` false on the local road; delete count 1≠3) · **R-e** (delete count 1≠3, the copies survive) · **R-g** (no count prefix, no owning sentence) |
| (d) the follow's offer sees the same copies; its Done's exports line | `theFollowsOfferSeesTheSameCopiesAnAdoptionSetAside` | **R-d** · **R-e** (0≠2, copies remain) · **R-f** (the line) |
| (e)+(f) the model: the Done's exports line with the weekly export OFF, composed in the real `PostureSwitchSheet`; the counted offer composed; Keep Them leaves every copy byte-identical; no line off Castle | `decliningTheOfferLeavesEveryCopyAndTheCastleDoneSaysTheExportsLine` | **R-f** (model line + composition) · **R-g** (the offer body) · **R-d** (the body's counts) |
| the four faces read the model (Mac FollowSheet + PostureSwitchSheet; the phone's two sheets) | `everyFaceRendersTheCountedOfferAndTheExportsLineFromItsModel` | structural — a face reverted by hand (no patch) |

**Stage protocol (from `App/Variorum/`, under a held claim):** green first —
`xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx201
-only-testing:VariorumTests/PostureSwitchTests` (expect the suite's existing count + 4; read the skip lines). Then
each revert ALONE: `git apply ../../notes/plans/fixes/vx-201-u3-reverts/<R>.patch`, `xcodebuild build-for-testing …`
(same flags), the same `test-without-building` (a single test may be selected with
`-only-testing:VariorumTests/PostureSwitchTests/<testName>()`), read which tests fail, then `git checkout --
App/Variorum/Shared/` and confirm `git diff HEAD --stat` EMPTY (`git apply` is worktree-only — window A's index trap
does not apply). Rebuild HEAD after the last cycle.

**Existing suites (changed-SOURCE rule — every suite whose source names a changed type or file) — PENDING, one
stage run** with `-only-testing:VariorumTests/` + each of: PostureSwitchTests VX110SignedOutCastleTests
VX202ReopenRaceTests VX80CastleFollowRecoveryTests Phase13pControllerTests Phase13pProtectionBrainTests
EncryptionFlowTests AppleRelinkDoorTests CopyRegisterPinTests ProtectionTierFaceTests ProtectionSurfaceRenderTests
Phase13pCopySweepTests TravellingDotsIndicatorTests LibraryPortabilityDoorTests PostureSwitchDrillTests (opt-in:
`TEST_RUNNER_VARIORUM_POSTURE_DRILL=1` in xcodebuild's ENVIRONMENT, plain `test`; VX-233's rot is pre-existing).
Phone (simulator, by UDID): `VariorumMobileTests/MobileProtectionTests` + `VariorumMobileTests/MobileStructuralTests`
(the phone's copy-home sweep reads the new literals — none carries a forbidden register word, checked by eye against
`CopyRegisterPinTests.forbidden`).

### THE WALK (the orchestrator's window — dev store, Debug build, both voices)
1. Dev store in STANDARD (no sync — the dev store never syncs). File ▸ Send Library to Another Mac… into a scratch
   folder, then File ▸ Open Library… that folder → confirm. The dev library steps aside: `Previous Libraries/<stamp>/`
   + `Backups/safety-copies/variorum-adopt-safety-<stamp>/` appear beside the dev store (Standard-era: `apple` in the
   key file). Capture the two folders (Finder or `ls`).
2. Settings ▸ Protection ▸ Use Castle… → the screens → Enter Castle. On the Done: the exports line sits under the
   Done (and under the insurance notice if the weekly export was on). Capture (Terminal + Study).
3. Continue → the offer: "That's N backups, plus 2 whole-library copies Variorum set aside…" + the owning sentence.
   Capture. Keep Them → both folders still there (capture). A second round (Use Standard, then Use Castle again, or a
   fresh dev store) → Delete Them → both stamp folders gone, the A1 rail's `variorum-backup-a1-*` folders untouched.

### U3 COPY DRAFTS (for the QUESTIONS #215 bundle — every line PROVISIONAL until she approves)
Sentence case, no capitals for emphasis, the everyday register (no key named; "Apple account", never "iCloud key").
1. **The offer's body, counted** (`ProtectionCopy.deleteOldBackupsBody(snapshots:libraryCopies:)`; the title and the
   two doors unchanged). The lead by what was listed —
   - backups and set-aside copies: *That's 3 backups, plus 2 whole-library copies Variorum set aside when you opened
     or restored another library (in Previous Libraries, and with your backups' safety copies).*
   - set-aside copies alone: *That's 2 whole-library copies Variorum set aside when you opened or restored another
     library (in Previous Libraries, and with your backups' safety copies).*
   - backups alone: *That's 3 backups.* (singular: *1 backup* · *1 whole-library copy*)
   then the shipped sentences unchanged — *They still open through your Apple account, and they always will.
   Deleting them closes that door for what they hold.* — then, only when set-aside copies are listed, the owning
   sentence: *The set-aside copies are also your way back to the library you replaced — delete them only if you
   won't want it back.* — then the shipped tail unchanged (*Variorum can only delete its own backups — …Recently
   Deleted.*). Note: one adoption leaves TWO folders (the dated copy and its safety twin), so the count says
   "copies", never "libraries".
2. **The plain-text exports line (VX-208)** (`ProtectionCopy.plaintextExportsNotCovered`), under every Done that
   entered Castle: *Markdown exports made before today are plain text that Castle can't reach — if you made any (the
   weekly export keeps them in an md-exports folder inside the backup folder you chose), delete them yourself.*
   - Alternative (wider than her ruling's letter, offered, NOT shipped — F-U3-5): *Markdown exports and unencrypted
     copies you made before today are plain text that Castle can't reach — if you made any, delete them yourself (the
     weekly export keeps its copies in an md-exports folder inside the backup folder you chose).*

### PROVISIONALs (mine — each defended; the orchestrator's to confirm or bundle)
- **P-U3-1 — the exports line shows on EVERY Done that entered Castle, whether or not the weekly export was on**
  (orchestrator-approved): Markdown exports made by hand, and an earlier weekly export's folders (its prune stops when
  it is off), exist either way. Placement: right after the insurance notice, in the same alarm voice (the export
  story's neighborhood, §A's VX-208 entry).
- **P-U3-2 — the phone shows the line too** (the shared models; the run's phone-parity line). The phone writes no
  Markdown exports itself, but a Mac of the same account may have. Alternative: Mac-only (a face-level gate).
- **P-U3-3 — ONE door for pairs and set-aside copies** (the brief's granularity: the whole stamp folder, the confirm
  owning what they are). Alternative for her: a separate choice for the set-aside copies (see F-U3-3).
- **P-U3-4 — the copies ride the pairs' listing rule** (a written fresh snapshot; the road entered Castle; on the
  follow and the resume, this library was Standard-shaped) — the offer stays a Castle-entry event, never a surprise on
  a Castle follower's key replacement.

### Findings for the orchestrator (dispositions owed by the run)
- **F-U3-1 — ACCEPTED at the resume** (the orchestrator's adjudication): "a key file carries `apple`" = the key file
  `StoreKeyEnvelope.locate` would open the copy with, never any key file in the folder (O.4's leftover Standard-era
  key file travels with a Castle library into the aside home). Pinned (b) with the two-key-file shape; R-b proves it.
- **F-U3-2 — 13p-era copies** whose key sits RAW in the legacy iCloud escrow item
  (`io.lduarte.Variorum.store-key-escrow`, VX-191 §O.2's last row) are Apple-openable with no `apple` wrap in their
  key file; the key-file rule cannot see them (nor can the pairs' listing). Population: her own devices only (13p era).
  Record-only; O.2 already recommends one look on her Macs.
- **F-U3-3 — a set-aside copy can be a DIFFERENT library** (Open Library of another library, not a restore of this
  one): Delete Them then removes that library's only in-container copies. The owning sentence says so in plain words
  ("…your way back to the library you replaced — delete them only if you won't want it back"). Whether she wants
  set-aside copies as their own choice (P-U3-3's alternative) is a #215 question.
- **F-U3-4 — the one-time-offer class extends to the copies:** a Castle follower whose account was already Castle
  (a key replacement elsewhere) is never offered them, and a declined offer never returns — B1e's class, VX-210's
  (Parked) territory; recorded for that ticket, not built (P-U3-4).
- **F-U3-5 — the plaintext SQLite export** (decision 15, manual, warned) made before Castle is also plain text and
  equally uncovered; her ruling's letter names Markdown exports, so the shipped draft does too and the wider sentence
  is offered as an alternative.
- **F-U3-6 — the overlap with VX-214 (declared):** `ProtectionPane.swift` gained 14 lines inside the two ceremony
  sheets' Done phases (the exports line, 7 per sheet) and 2 changed lines in their offer phases (`model.offerBody`)
  — nothing of the pane's own sections; the phone's two sheets: 2 added lines + 2 changed (`git show a4a0136c
  --stat`: +16/−2 and +4/−2). Copy rhyme: none of these sentences sits on a
  Settings pane's own text.
- **F-U3-7 — machinery:** my first pass STOPPED at the reading's end, nothing written, when the orchestrator's
  notes-only commit `6913e6a5` landed in this worktree; resumed in the same session under the amended rule (notes-only
  orchestrator commits are expected). One more: a `git pull --rebase` refused before my `a4a0136c` (my own unstaged
  edits) — the commit and push landed cleanly; later pulls use `--no-rebase` as the orchestrator allowed.

### ORCHESTRATOR ADJUDICATION — U3 (verified against git before adoption: commits c0b96287 → c8329b75 as
reported, zero `Sources/VariorumCore/Sync/` lines by path diff, zero trailers, the four Mac revert patches
present and apply-checked per record; the remover's qualification READ by the orchestrator — re-run whole before
`removeItem`, real-directory-never-symlink at the folder AND the homes, canonical-path comparison, the planted-link
leg ran red under R-c; headless core 2,697/308 green at close)

- **F-U3-1 — stands ACCEPTED** (pre-build adjudication re-confirmed at hand-back): R-b's red run is the proof the
  locate-based reading earns its keep — under "any key file" the remover DELETED the O.4 two-key-file Castle copy.
- **F-U3-2 — RECORD-ONLY.** 13p-era copies openable through the legacy raw escrow item carry no `apple` wrap for
  the rule to see; population is her own devices; VX-191 §O.2's recommended look stands — named in the morning
  handoff's optional section, not a tonight action.
- **F-U3-3 — the owning sentence covers it; the structural question ("should set-aside copies be their own
  choice?") rides #215** beside P-U3-3's alternative. Accepted as built for tonight.
- **F-U3-4 — VX-210's (Parked) territory, confirmed:** a note lands on VX-210's ticket at closeout (the one-time
  offer class now spans pairs AND copies).
- **F-U3-5 — handled as ruled:** the shipped draft keeps her ruling's letter (Markdown exports); the wider
  sentence is #215's alternative.
- **F-U3-6 — overlap within the declared bounds** (ceremony-sheet phases only, zero pane sections); the final
  ProtectionPane/AppSettingsView hunks go to settingspaneupdater in ONE send after U4 lands.
- **F-U3-7 — machinery accepted;** the `--no-rebase` allowance stands for every later unit.
- **P-U3-1/P-U3-4 — CONFIRMED** (the exports line on every entered-Castle Done; the copies ride the pairs'
  listing rule). **P-U3-2 (the phone shows the line) — CONFIRMED provisionally,** bundled in #215 with the
  Mac-only alternative (the phone writes no exports; a Mac of the account may have). **P-U3-3 — CONFIRMED,**
  its alternative bundled (F-U3-3).
- Copy drafts adopted into the #215 input as written. U3's acceptance evidence still owes the stage: the 4 Mac
  pins + their four revert cycles + the existing-suite run + the 2 phone files — WINDOW D, at the branch tip,
  after window C phase 2 (U2's cycles must run at a208a24a, BEFORE the pinned checkout advances past U3's
  Shared/ changes).

### WINDOW C RECORD — PHASES 1+3 (orchestrator, stage claim vx201-u2-tests-p1; the pinned checkout at a208a24a)
- **Phase 1 (Mac green pass): `✔ Test run with 435 tests in 60 suites passed after 345.045 seconds`** — U2's
  whole changed-source list incl. the 9 VX110 pins and the 10 VX202 pins. Log /tmp/vx201-wc-greenpass.log.
- **Phase 1b (the gated drills):** migration drill + the connect drill's second leg green; the posture drill's 2
  issues are VX-233's bisect-proven pre-existing rot; the connect drill's sibling-pull leg fails with the
  IDENTICAL `@Dependency(\.date)` signature (Date.swift:37 via SyncEngine.swift:19) — classified VX-233's class,
  honestly marked NOT separately bisected; the time-boxed heal's re-run proves or re-opens it. Log
  /tmp/vx201-wc-drills.log.
- **Phase 3 (phone, sim by UDID): first attempt silently ran only 2 of 3 requested names** — the counts-read
  discipline caught it: `-only-testing` matches suite TYPES, and MobileProtectionTests/MobileStructuralTests are
  multi-struct FILES (window A's MobileWindowReplayTests matched only because file = type there). MACHINERY
  LESSON (every later phone window): translate file names to the struct names. Re-run with the 10 real types:
  **37 tests in 10 suites, 36 green, 1 red — `MobileNoRedirectSweepTests.nothingUserFacingNamesTheMac`,
  PRE-EXISTING** (9 of 10 offenders predate this run at 97329acc: LibraryOpenCopy's five = exactly VX-114
  [Todo], plus AcknowledgmentsCopy's four "(Mac only)" from 13n — VX-114 EXTENDED by comment, no duplicate
  minted, the coordinator's dedup catch). The 10th offender was U2's diagnostic log line in PostureSwitch.swift
  — FIXED (66863d50, device-neutral wording, a log line so no #215 ride); the sweep's re-run rides window D at
  the tip. Logs /tmp/vx201-wc-phone.log + -phone2.log.
- **U2's acceptance evidence so far:** green pass + phone pins green (MobilePhoneProtectionCopyTests' re-based
  consent pin among the 36); still owed = phase 2's seven revert cycles (queued ~04:35 behind VX-179 + VX-214
  windows). Simulators shut down; stage released after phase 3.

### WINDOW C RECORD — PHASE 2 (orchestrator, stage claim vx201-u2-tests-p2; the pinned checkout at a208a24a)
All SEVEN U2 revert cycles ran; each RED exactly on its pin-table legs, every restore verified clean (empty
porcelain), HEAD products rebuilt after the last cycle (exit 0). Per cycle: **R-a** (no doors) — pin (a) on all
seven asserts; pins (b) and (f) also red as the removed-fork SUPERSET behaving consistently (window B's R-a1
class; the per-leg attribution stands). **R-b1** (no forget) — pin (b) on 12 asserts (material rides behind the
gate; the follow re-adds `apple` and moves custody silent); pins (c)/(c2) red on their material-present lines,
the no-forget superset. **R-b2** (the Apple arm lands) — pin (b) alone, 4 asserts, all key-file/arm lines
(F-U2-1's red-on-old). **R-c** (resume no forget) — pin (c) alone. **R-c2** (resume ignores the flag) — pin
(c2) alone (ordinary Done shown). **R-f** (ordinary Done) — pins (b)/(c)/(c2)/(f) exactly on their Done
asserts. **R-7** (one act) — the item-2 pin alone, 12 asserts across both banner faces and the sync row. The
THREE BOUND pins (two-store isolation (d) · born-Castle (e) · faces-as-code) stayed GREEN through every cycle —
and (e) green at the stage means the Done's optional new-account sentence is AVAILABLE for #215 as the U2
record offered (not shipped in the draft; her call). **U2's red-on-old obligation DISCHARGED; VX-110's
acceptance evidence is COMPLETE** (green pass 435/60 + the phone pins + the seven cycles). Window D folds U3's
suites and U4's together at the tip (coordinator queue: batch3impl → vx-184 U3 → us). Logs /tmp/vx201-wc-R-*.log,
rollup /tmp/vx201-window-c.summary (deleted at closeout per the tidy rule).

## U4 RECORD (VX-204 + VX-206)

**Not done in this unit (stated first):** no `xcodebuild test` of any kind was run (stage work, per §F) — the 5 new
pins, their six red-on-old revert cycles and every existing Mac/phone suite below are **PENDING** the orchestrator's
stage window; **no walk** (§F: the walk is the orchestrator's — "ceremony-from-Protection ends on Protection with the
popup" is walk-verified there, recipe below); no launch of the app; the headless core suite NOT re-run (this unit
changed zero lines under `Sources/` — `git diff 64fbecc8..HEAD --stat -- Sources/` is empty — so the U3 close's
2,697/308 stands); her real store untouched and nothing re-seeded (her morning press, ruled); no `notes/QUESTIONS.md`
entry (merge-moment-only — the drafts below are #215's input); the canon copy record `notes/plans/pre-13x-copy.md`
not edited (F-U4-3); the sibling overstatement in `TierViews.whatItIs` NOT touched (F-U4-1 — one sentence was the
brief). Zero lines in `Sources/VariorumCore/Sync/`, no schema, zero `ProtectionPane.swift` lines, and in
`AppSettingsView.swift` only the adopter (two modifiers + one private func).

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- 2026-10-13 — U4 implementer (Opus) started. Reading done in this session, never delegated: this file whole (§A's
  VX-204/VX-206 entries, §B, §F, the run LIVE STATUS incl. the VX-206 MACHINERY RULING and her compaction-seam
  rulings, the U1/U2/U3 records + adjudications + windows A–C); `notes/SessionResiliencyProtocol.md`; VX-204 and
  VX-206 on the board (no comments on either); auditor C's C-1 + the website privacy brief
  (`notes/stargazing-privacy-policy-brief-2026-10-04.md` — the operator-visible envelope) + the product page's
  privacy section; the code: `PostureCopy.swift` (`privacyLessonOneParagraphs`), both seeders, the two existing
  render pins, `CopyRegisterPinTests`, `AppSettingsView.swift` whole head + the adopter, `MCPDoor.settingsRequest`,
  the Settings scene in `VariorumApp.swift`, `ProtectionPane.swift` (the presenters), `ProtectionController`'s
  ceremony-host section, `PostureSwitchModel` (the roads), the runner's re-key step, `AppBootstrap.rekeyLibrary`.
- Both seeders read the ONE copy home (verified, no own copy): `TutorialSeeder.swift:2465`,
  `MobileTutorialSeeder.swift:793`.
- DONE `ccacac61` — piece 1, VX-204: `privacyLessonOneParagraphs` amended + the new constant
  `privacyServerSeesShapeSentence` (PostureCopy.swift) + `VariorumTests/VX204PrivacyLessonTests` (2 tests).
- DONE `3aa029eb` — piece 2, VX-206: the holder + `requestProtectionPaneForCeremony()` (ProtectionController), the
  reopen's ask (AppBootstrap.rekeyLibrary, one call), the road's-return ask (PostureSwitchModel `phase` didSet), ONE
  adopter (AppSettingsView: two modifiers + one private func) + `VariorumTests/VX206ProtectionLandingTests` (3 tests).
- VERIFIED: Mac `build-for-testing` (Variorum, `-derivedDataPath DerivedData/vx201`, index store off) TEST BUILD
  SUCCEEDED with both pieces; zero warnings in changed lines (the one AppSettingsView warning, :1159, is a
  pre-existing line). Every test RESULT is PENDING the stage.
- IN-PROGRESS — the revert patches (`notes/plans/fixes/vx-201-u4-reverts/`): each made by editing the committed
  tree, `git diff > <R>.patch`, then `git checkout --` the one file; a death mid-step leaves at most ONE file
  reverted, and `git diff HEAD` shows which (the fix is committed — `git checkout --` is the safe restore).
  DONE `7479c16f`: the six patches written, each `git apply --check` clean, the tree restored (`git diff HEAD`
  empty).
- DONE (verified here): the COMPILE CHECK — combo 1 (R-204 + R-none + R-reopen + R-done + R-adopter, distinct files)
  TEST BUILD SUCCEEDED, restored, `git diff HEAD --stat` EMPTY; R-host alone (it shares R-none's hunk) TEST BUILD
  SUCCEEDED, restored, EMPTY; then a HEAD Mac `build-for-testing` (TEST BUILD SUCCEEDED) so `DerivedData/vx201`
  holds the FIX's products. **No revert is applied now.**
- VERIFIED: phone `build-for-testing` (VariorumMobile, generic iOS Simulator, same DerivedData) TEST BUILD
  SUCCEEDED; the four changed Shared files compiled for the phone target (read on the SwiftCompile lines); zero
  warnings in them. `df -h` data volume 35 GiB free before and after.
- CLOSED (this commit): the mechanism, the design, the pins table + expected reds, the stage protocol and suites,
  the walk recipe, the copy drafts, the PROVISIONALs, the findings, the VX-214 hunk.

### The traced mechanism (pin before fix — read at HEAD `64fbecc8`)
- **VX-204 (C-1, copy):** `ProtectionCopy.privacyLessonOneParagraphs[0]` said *"everything is encrypted on your
  device before it leaves, and the Variorum server stores what it can never read"*; built, every text-bearing and
  named field is sealed while dates, the tag tree's shape and which notes carry which tags, book membership, the
  flags (starred/finished/sealed/owned/archived/Private) and sizes travel plain — the envelope the website privacy
  brief (`notes/stargazing-privacy-policy-brief-2026-10-04.md`, "Operator-visible metadata") and the in-app
  Encryption tab's `disclosureCopy` already disclose. Both seeders render the one constant (`TutorialSeeder.swift`
  `lesson(privacy, …privacyLessonOneParagraphs)`, `MobileTutorialSeeder.swift` the same plus lesson 2) — no own copy.
- **VX-206 (her nit):** the Settings scene renders `AppSettingsView` only inside `if case .ready(let session) =
  bootstrap.state` (`VariorumApp.swift`, the `Settings {}` scene). `AppBootstrap.rekeyLibrary` sets `state =
  .opening` before the pool closes, so the Settings window's content becomes the scene's placeholder and the
  `AppSettingsView` (with its `@State pane`) is torn down; `beginOpening` → `.ready` builds a FRESH one whose `pane`
  starts at `.general`. The ceremony survives on the controller (`activeSwitch`), but its host was decided at
  `openSwitch` as `.pane` (a Protection pane was mounted), and only `ProtectionPane` presents `ceremony(for: .pane)`
  — so the During screen and then the Done sat unpresented until she clicked Protection (her report verbatim: "the
  info popup only shows on clicking Protection"). The "info popup" IS that sheet (no other popover exists on the
  pane — read). The window itself never closes (nothing in `onWillLock`/`macWillLock` closes windows — read).

### What landed (the design; the VX-206 MACHINERY RULING followed to the letter)
- **VX-204:** lesson 1's sync sentence now says what IS sealed — *"your writing and everything you name — titles,
  tags, books — are encrypted on your device before they leave, and the Variorum server can never read them"* —
  followed by ONE new sentence, its own constant `ProtectionCopy.privacyServerSeesShapeSentence` (so pins quote it,
  never re-type it). The rest of the paragraph, keystone 3, the open-app sentence and lesson 2 are byte-untouched.
- **VX-206 — the holder:** `ProtectionController.settingsRequest` (observable counter) + `settingsRequestAdopted`
  (`@ObservationIgnored`, the window's "seen" mark) — `MCPDoor.settingsRequest`'s exact shape, on the object that
  outlives the re-key (the bootstrap's `let protection`, the same one that already holds `activeSwitch` for this
  reason). **The one door:** `requestProtectionPaneForCeremony()` bumps only while `activeSwitch != nil` and
  `ceremonyHost == .pane` — the ceremony's ORIGIN as the app already records it (decided once at `openSwitch`
  from the mounted-pane count). **The two asks:** (1) `AppBootstrap.rekeyLibrary`, right after `awaitOpen()` — the
  teardown road's landing (the During screen comes back where she was); (2) `PostureSwitchModel.phase`'s `didSet`,
  `.running → anything` while this model is the controller's `activeSwitch` — the road's return (the Done, a
  refusal, a restart). **The adopter:** `AppSettingsView` gains `.onAppear { adoptProtectionRequest() }` +
  `.onChange(of: protection?.settingsRequest)` and one private func mirroring `adoptMCPRequest` (`adopts(request:
  adopted:)` reused; `query = ""`; `pane = .protection`). Landing Protection mounts the pane, which presents the
  ceremony's sheet exactly as it always has — no new popup machinery, zero pane lines. The phone never mounts a
  Protection pane (`protectionPaneAppeared` is called only by the Mac's `ProtectionPane`), so every phone ceremony
  is `.root`-hosted and the asks are inert there.

### THE PINS and the red-on-old protocol (ALL PENDING, stage)
`VariorumTests/VX204PrivacyLessonTests` (2 tests) and `VariorumTests/VX206ProtectionLandingTests` (3 tests,
`.serialized`; the production bootstrap + the PRODUCTION `rekeyLibrary` reopen + the ceremony opened through
`openSwitch`; the hosted legs build the REAL `AppSettingsView` in a real window and read the Protection pane's own
mount count, so the adopter is exercised, never re-derived). Run green first; then each revert ALONE: `git apply
notes/plans/fixes/vx-201-u4-reverts/<R>.patch`, `build-for-testing`, the same `test-without-building`, read which
tests fail, `git checkout -- App/Variorum/` and confirm `git diff HEAD --stat` EMPTY (`git apply` is worktree-only).
Rebuild HEAD after the last cycle.
| pin | test | expected red under |
|---|---|---|
| VX-204 the honest sentence | `VX204PrivacyLessonTests/theLessonSaysWhatIsSealedAndNamesTheShapeTheServerSees()` | **R-204** (`R-204-overstating-paragraph`): the sentence absent, "everything is encrypted" + "stores what it can never read" present, "your writing and everything you name" absent |
| VX-204 register | `…/theNewSentenceKeepsTheGuidesRegister()` | BOUND (green under every revert — the sentence's own register) |
| (a) the Done lands Protection, its sheet up | `VX206ProtectionLandingTests/aCeremonyOpenedFromProtectionEndsWithItsDoneUpOnProtection()` | **R-none** (`R-none-no-request`): no request; the hosted window stays on General (her report) · **R-done** (`R-done-no-ask`): `settingsRequest > atReopen` fails (the hosted leg stays green — the reopen's ask still lands it) · **R-adopter** (`R-adopter-none`): the pane never mounts, never adopted |
| (b) BOUND — the root's ceremony asks nothing | `…/aCeremonyTheMainWindowHostsLeavesSettingsWhereItWas()` | green on the pre-fix code by nature; **R-host** (`R-host-any-ceremony-asks`) shows its teeth: both asks fire, the hosted window lands Protection |
| (c) the ask outlives the teardown; a window already up | `…/theRequestOutlivesTheReKeysTeardownAndReachesAWindowAlreadyUp()` | **R-none**: nothing asked at the reopen, the window already up never moves · **R-reopen** (`R-reopen-no-ask`): `atReopen > beforeReopen` fails · **R-adopter**: the window already up never moves |
Expect "Test run with 5 tests in 2 suites" when both suites are selected alone (no `.enabled(if:)` gates). The hosted
legs need the GUI session the stage already has (a real `NSWindow` ordered front; the pins close it).

**Stage protocol (from `App/Variorum/`, under a held claim):** `xcodebuild test-without-building -scheme Variorum
-destination 'platform=macOS' -derivedDataPath DerivedData/vx201 -only-testing:VariorumTests/VX204PrivacyLessonTests
-only-testing:VariorumTests/VX206ProtectionLandingTests` (the HEAD products are in `DerivedData/vx201` now).

**Existing suites (changed-SOURCE rule — suites whose source names a changed type: `ProtectionCopy`'s privacy
lessons, `ProtectionController`'s ceremony host, `PostureSwitchModel`, `AppBootstrap.rekeyLibrary`,
`AppSettingsView`) — PENDING, one stage run** with `-only-testing:VariorumTests/` + each STRUCT TYPE:
VX204PrivacyLessonTests VX206ProtectionLandingTests TutorialPrivacyChapterTests TutorialBookShapeTests
TutorialCurrencyTests TutorialFurnitureFoldTests EncryptionExplainedDrillTests CopyRegisterPinTests
ProtectionSurfaceRenderTests Phase13pControllerTests PostureSwitchTests VX110SignedOutCastleTests
VX202ReopenRaceTests VX80CastleFollowRecoveryTests EncryptionFlowTests AppBootstrapOffMainTests MCPAsksWaitTests
SettingsShapeTests MCPPaneTests DiagnosticsPaneTests CalmAsksTests OwnershipBadgeTests, plus PostureSwitchDrillTests
opt-in (`TEST_RUNNER_VARIORUM_POSTURE_DRILL=1` in xcodebuild's ENVIRONMENT, plain `test`; VX-233's rot is
pre-existing). Phone (simulator by UDID, `-only-testing:VariorumMobileTests/` + each STRUCT TYPE — the file names
are multi-struct): MobilePocketGuidePrivacyTests MobileTutorialBookShapeTests MobileCopyRegisterSweepTests
MobileNoRedirectSweepTests (expect ONLY VX-114's pre-existing offenders — the new sentence names no Mac)
MobilePhoneProtectionCopyTests MobileWindowReplayTests (its follow rides `bootstrap.rekeyLibrary`, now with the
ask — a `.root`-hosted no-op on the phone).

### THE WALK (the orchestrator's window — dev store, Debug build, both voices)
1. Dev store in Standard. Settings ▸ Protection ▸ Use Castle… → the screens → Enter Castle. Watch the Settings
   window through the re-key: a moment of the scene's placeholder (F-U4-4), then Settings comes back ON PROTECTION
   with the During sheet, then the Done in place. Capture the Done on Protection (Terminal + Study) — the row's
   evidence, "not on General".
2. Continue → the offer (when listed) → Keep/Delete → the sheet closes on Protection.
3. Control: open the ceremony from outside Settings (the Account sheet's Replace All Keys, Settings closed or on
   another pane) → Settings, opened after, stands where it always does (General / where she left it).
4. Use Standard from Protection (no re-key — no teardown): ends on Protection, as before.
5. The field guide: a FRESH dev store (or the guide's restore door on the dev store) → keeping it private ▸ lesson
   1 reads the new sentence (capture once per voice).

### The VX-214 hunk (for the orchestrator's one send — VX-214 owns the panes this week)
`git show 3aa029eb -- App/Variorum/Variorum/Features/Settings/AppSettingsView.swift` — two modifiers after the MCP
adopter's pair and one private func (`adoptProtectionRequest`) after `adoptMCPRequest`; nothing else in the file.
`ProtectionPane.swift`: zero lines this unit.

### U4 COPY DRAFTS (for the QUESTIONS #215 bundle — every line PROVISIONAL until she approves)
Sentence case, no capitals for emphasis, everyday register (no key-family word; nothing that names the Mac, so the
phone's lesson carries it unchanged).
1. **Lesson 1's sync sentence, amended** (`privacyLessonOneParagraphs[0]`) — was: *Sync is end-to-end encrypted:
   everything is encrypted on your device before it leaves, and the Variorum server stores what it can never read.*
   Now: *Sync is end-to-end encrypted: your writing and everything you name — titles, tags, books — are encrypted on
   your device before they leave, and the Variorum server can never read them.*
2. **The new sentence** (`privacyServerSeesShapeSentence`, right after it, before *Both modes are like this.*):
   *What the server can see is the shape around your words: dates, how your tags nest and which notes carry them,
   which notes are in which books, flags like starred or finished, and sizes.*
   - Alternative A (auditor C's shape, one sentence): *Everything you write and name — text, titles, tags, book and
     shelf names — is encrypted on your device before it leaves; the server sees only the shape (dates, counts, how
     things are arranged), never a word.*
   - Alternative B (shorter, the Encryption tab's rhyme): *What the server still sees is the shape, not the words:
     dates, how things are tagged and ordered, which books they're in, a few flags, and sizes.*
3. **VX-206:** no new or changed user-facing sentence.

### PROVISIONALs (mine — each defended; the orchestrator's to confirm or bundle)
- **P-U4-1 — two asks, not one:** the reopen AND the road's return. The Done alone would leave the During screen
  invisible on General for the whole post-reopen tail (the custody move, the fresh backup, the sync reconnect —
  seconds on a real library) and leave Settings navigable under a hidden ceremony; the reopen's ask brings the
  sheet back where she acted, and the return's ask guarantees the END (the ticket's word) even if she moved.
- **P-U4-2 — "opened from Settings ▸ Protection" = `ceremonyHost == .pane`** (opened while a Protection pane is
  mounted — row 11's own decision, made once at `openSwitch`). It includes a ceremony opened from another door
  while Settings ▸ Protection is on screen; that ceremony IS the pane's sheet, so ending there is right.
- **P-U4-3 — every pane-hosted road asks** (Use Standard, Replace All Keys, the resume, not only Use Castle): the
  same defect shape for each that re-keys; a harmless re-landing for those that don't.
- **P-U4-4 — the adopter clears the Settings search** (`query = ""`), mirroring the MCP adopter.
- **P-U4-5 — the copy** (drafts 1–2) — #215.

### Findings for the orchestrator (dispositions owed by the run)
- **F-U4-1 — a sibling overstatement:** `TierViews.whatItIs` (Shared/TierViews.swift:50-52, the Account tab's
  hosted-sync tier section) says *"The server can never read what it stores."* — the C-1 class (the server stores
  the plain envelope and can read it). Not touched (one sentence was the brief; copy is hers). Candidate: a #215
  rider with a draft (*"…The server can never read your writing."* — keystone 1's own accurate clause) or a ticket.
- **F-U4-2 — the guide fold reads content:** the furniture fold pairs guide copies by CONTENT signature
  (`SeededFurnitureClassifier.guideVerdict` — every member note's own signature), so an old-text guide already
  synced and a new device's new-text guide do not fold (both stay). The class every guide edit has carried
  (VR-122, 13s-b); U5's warning lands in the same seed; population: pre-launch stores only (hers + the tester) —
  her morning re-seed is the road on hers. Record-only, no launch weight (public stores are born on the new text).
- **F-U4-3 — the canon copy record is stale:** `notes/plans/pre-13x-copy.md:419-421` carries lesson 1's old text;
  the #215 commit adds a supersession pointer (F-U2-6's pattern), never a rewrite.
- **F-U4-4 — the teardown is visible:** during the re-key the Settings window stays open and renders the scene's
  `.opening` branch, *"Open the main window first."* (`VariorumApp.swift`, the `Settings {}` scene's `else`) — a
  wrong instruction flashed mid-ceremony (pre-existing; the walk will see it). Not touched (outside the ruled
  hunk). Candidate for VX-214 (the panes' week) or a ticket: a neutral placeholder while `.opening`.
- **F-U4-5 — one road not covered:** a lock/unlock while a pane-hosted ceremony sits OPEN but idle (e.g., Screen 1,
  then Lock Now on a Castle library) also rebuilds Settings at General with the sheet unpresented — no re-key and
  no road return, so no ask. Pre-existing, rare; one more ask at every ready (the same door) would cover it — not
  built (the ticket's road is the ceremony's run).
- **F-U4-6 — record-only, unverified read:** `activeFollow` is presented by BOTH `ProtectionPane` and
  `ProtectionNoticeBar` (`.sheet(item:)` on each) — row 11's one-presenter rule was applied to the ceremony only. Not
  walked or pinned here; noted for the ladder.

### ORCHESTRATOR ADJUDICATION — U4 (verified against git before adoption: commits ccacac61 + 3aa029eb + 7479c16f
+ b96656eb as reported; zero `Sources/VariorumCore/Sync/` lines, zero `ProtectionPane.swift` lines, zero
trailers by log read; the AppSettingsView diff READ whole — two modifiers + one private func mirroring
`adoptMCPRequest`, the "nothing else in that file" constraint honored; all six U4 patches + U3's four
apply-check CLEAN at the tip in the pinned checkout)

- **The holder's home — ACCEPTED as the ruling's own shape:** the MACHINERY RULING's parenthetical put the
  holder "in AppSettingsView", but the MIRRORED pattern itself holds the request on the door object
  (`MCPDoor.settingsRequest`), and the mechanism REQUIRES the survivor's side — a holder on the view dies with
  the re-key's teardown, which is the defect. `ProtectionController.settingsRequest` is the pattern applied
  correctly; the file-constraint (adopter only in AppSettingsView) is what the ruling protected, and it holds.
- **P-U4-1 (two asks) — CONFIRMED.** A hidden ceremony mid-run is the theater class; the reopen's ask restores
  the During screen where she acted, the return's ask lands the ticket's END. **P-U4-2 (origin = `ceremonyHost
  == .pane`) — CONFIRMED** (the app's own record, decided once; the included edge is honest). **P-U4-3 (every
  pane-hosted road) — CONFIRMED** (the same defect shape per re-keying road; harmless elsewhere). **P-U4-4
  (query cleared) — CONFIRMED** (mirror fidelity). **P-U4-5 — #215.**
- **F-U4-1 (TierViews' sibling overstatement) — #215 RIDER with the implementer's draft,** flagged as beyond the
  run's members: lands at the #215 commit ONLY on her approval, else minted a ticket in the morning. One
  sentence, the C-1 class, same honesty argument.
- **F-U4-2 — record-only, agreed** (the guide fold's content pairing is every guide edit's property; her morning
  re-seed is the road on her store; public stores born on the new text).
- **F-U4-3 — the #215 commit's supersession pointer** (pre-13x-copy.md:419-421, F-U2-6's pattern — one commit
  carries both pointers).
- **F-U4-4 (the teardown's "Open the main window first." flash) — TAKEN BY VX-214** (their reply to the hunks
  send): minted as VX-240 (Backlog) on their side, no mint at our closeout; the fix is a neutral `.opening`
  face, wording hers (their morning bundle). Their rebase note for our merge picture: the Settings scene's stub
  arm now lives in SettingsSceneContent.swift on their branch (VX-224's refactor) — our diff touches neither,
  so merge order stays free; they rebase onto our merged shape.
- **F-U4-5 (lock/unlock while a pane-hosted ceremony sits idle) — TICKETED tonight** (pre-existing, rare, the
  same family one trigger over; the fix candidate is one more ask at every ready through the same door).
- **F-U4-6 (two presenters for `activeFollow`) — the ladder's** (an unverified read, honestly marked; the Fable
  reviewer re-examines).
- **Copy drafts adopted into the #215 input as written** (the amended sync sentence + the shape sentence with
  alternatives A/B). U4's acceptance evidence owes WINDOW D (folded with U3's): the 5 pins green, the six revert
  cycles red-as-named, the union suite run, the phone union incl. the no-Mac sweep reading ONLY VX-114's
  offenders — then the walk's VX-206 legs at my window.

### WINDOW D RECORD — PHASES 1+3 (orchestrator, stage claim vx201-u3u4-tests-p1; the pinned checkout at b96656eb)
- **Phase 1 (Mac union green pass): `✔ Test run with 314 tests in 27 suites passed after 333.390 seconds`** —
  27 of 28 requested: `Phase13pProtectionBrainTests` is a multi-struct FILE (the machinery lesson's second
  firing; it came from U3's suite list), its five real types (ProtectionDialsTests · ProtectionCopyTests ·
  ProtectionCadenceTests · StoreKeyGuardBackingTests · ProtectionDialsPerStoreTests) re-run at the tip under the
  same claim: `✔ 29 tests in 5 suites`. The U3 pins (PostureSwitchTests' extension) and U4's two pin suites
  (VX204PrivacyLessonTests 2 + VX206ProtectionLandingTests 3, hosted legs included) are GREEN inside the pass.
- **Phase 1b (the posture drill, opt-in env):** exactly VX-233's two pre-existing issues, nothing new at the tip.
- **Phase 3 (phone union, 14 struct types, sim by UDID): 64 tests / 14 suites, one red** — the no-Mac sweep,
  whose offender list now reads EXACTLY VX-114's nine pre-existing strings (4 AcknowledgmentsCopy + 5
  LibraryOpenCopy): the U2 log-line fix (66863d50) VERIFIED at the tip, zero new U3/U4 literals. Everything
  else green incl. MobilePocketGuidePrivacyTests (U4's phone seed) and MobileCopyRegisterSweepTests (U3's new
  strings under the register sweep). Simulators shut down; stage released. Logs /tmp/vx201-wd-*.log.
- **Still owed:** phase 2's ten revert cycles (READY sent; GO expected ~05:15), then U5's window E.

### WINDOW D RECORD — PHASE 2 (orchestrator, stage claim vx201-u3u4-reverts; the pinned checkout at b96656eb)
All TEN revert cycles ran (U3's four on PostureSwitchTests' 74; U4's six on its two pin suites); each RED exactly
on its pin-table legs, every restore clean, HEAD rebuilt (exit 0). U3: **R-d** — the ceremony pin on 10 asserts
(listing · counts · delete-sum 3 · folders survive · the local and resume arms), the follow pin on 4, the
declining pin's counts (2). **R-e** — the delete-sum legs alone (ceremony 3 · follow 2): the copies survive
Delete. **R-f** — the exports-line legs alone (follow 1 · model + composition 2). **R-g** — the counted-body
legs alone (ceremony 3 · declining 2). U4: **R-204** — the lesson pin on 5 asserts (the new sentence and words
absent, the old overstatement back); the register pin green (bound). **R-none** — pins (a) 4 + (c) 3; the bound
(b) green. **R-host** — the BOUND pin (b) red on 4 (both asks fire for a root-hosted ceremony) — the bound
showing its teeth exactly as designed. **R-reopen** — pin (c)'s two reopen-ask asserts. **R-done** — pin (a)'s
one road-return assert (the hosted leg green — the reopen's ask still lands it, as the table said). **R-adopter**
— pins (a) + (c) on `landed` + adopted (4). **U3's AND U4's red-on-old obligations DISCHARGED; with phases 1+3,
VX-203 + VX-208 + VX-204 + VX-206's acceptance evidence is COMPLETE** (walk legs ride my window). Logs
/tmp/vx201-wd-*.log; rollup /tmp/vx201-window-d.summary (deleted at closeout).

## U5 RECORD (VX-209)

**Not done in this unit (stated first):** no `xcodebuild test` of any kind (stage work, per §G) — the 9 new Mac
pins, their six revert cycles and every existing Mac/phone suite below are **PENDING** the orchestrator's stage
window, AS STAGE RUNS (every new pin and all six cycles DID run headless here, in a scratch-package harness that
compiles the production Mac + Shared code byte-copied — evidence of a different kind, recorded as such, never as the
stage's); **no walk** (GUI work needs a held stage claim — the recipe is below, THE WALK); the phone's simulator
suites not run (the phone's guide and faces are unchanged; its sweeps read the new Shared literals); **the deeper
fix NOT built** (corner 45 remembering a Castle store id — §A's stranding argument; VX-209's ticket) and **no
confirm line on the way-back step itself** (the brief's condition does not reach it — F-U5-3, options for her);
the enrolled-library shape traced from code, NOT pinned (the world is local-only — F-U5-4); her real store
untouched, nothing re-seeded (her morning press); no `notes/QUESTIONS.md` entry (merge-moment-only — the drafts
below are #215's input). Zero lines in `Sources/VariorumCore/Sync/`, no schema, no custody code, and **zero
adopt/restore MACHINERY lines** (the brief's constraint: `LibraryOpenModel`'s flow, `LibraryAdoption`,
`landCustody`, the gate and custody are byte-untouched — the model gained one computed confirm fact).

### LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)
- 2026-10-13 ~04:35 — U5 implementer (Opus) started. Reading done in this session, never delegated: this file
  whole (§A's VX-209 entry, §B, §G, the run LIVE STATUS incl. her carried-forward reminder 2, the U1 RECORD +
  adjudication — F2 and belt c's exact shape — and the U2–U4 records + adjudications);
  `notes/SessionResiliencyProtocol.md`; `notes/plans/fixes/vx-191-encryption-audit.md` whole (§W.2's trace
  verbatim); `notes/SyncSpec.md` in full; `notes/plans/phase-13x-library-portability.md` (the design look, the
  sittings, QA/QB/QC/QD, the restore-hold ruling, the U1 custody-collision memo, U2's settled design, the F1
  R1-BLOCKER trace); `notes/plans/pre-13x-postures-design.md` §1 (decisions 1–35) + §14 (corners 1–48, 45
  especially). Code: `LibraryClassifier`, `LibraryAdoption`, `CustodyCollisionRule`, `LibraryOpenModel`
  (whole), `LibraryOpenCopy` (whole), the Mac faces `LibraryOpenDoor.swift` (the ONE sheet every adopt road
  renders) + `DataSafetyPane`'s Restore section + `VariorumApp`'s two presenters, `StoreLaunchGate`
  (`effectiveGate`, `rawKeyCustody`, belt c's `switchPending`, `openWithAppleKey`), `StoreProtection`
  (`Posture.derive`, corner 45's `localReading`), `StoreKeyEnvelope`, `StoreKeyGuard`/`AppleKeyCustody`
  (the in-memory backings), `PostureSwitch.writeNewKeyFile`, `PostureCopy`'s privacy lessons + both seeders,
  and the pins that read lesson 2 (`TutorialWalkTests`, `MobileTutorialWalkTests`, `MobileProtectionTests`,
  `VX204PrivacyLessonTests`, `MobileNoRedirectSweepTests`).
- THE HEADLESS HARNESS (built before any repo line, so the reproduction runs HERE, not only at the stage): a
  scratch SwiftPM package OUTSIDE the repo (the session scratchpad, `vx209-harness/`) that compiles the
  worktree's `App/Variorum/Shared/**` + `App/Variorum/Variorum/**` BYTE-COPIED (one recorded exception: the
  `@main` attribute stripped from the COPY of `VariorumApp.swift`, so the library has no entry point beside the
  test runner's) into a library named `Variorum`, with the app target's Swift settings (Swift 6 mode, default
  MainActor isolation, approachable concurrency's two upcoming features, member import visibility), the
  worktree's core package by path, and the Mac target's package products (GRDB fork, swift-dependencies, the
  MCP SDK, Sparkle 2.10.0 — the xcodeproj's own pins). A Mac test file's `@testable import Variorum` resolves
  unchanged, so the SAME file the stage runs runs here under `swift test` (Swift Testing). Its own process,
  its own defaults domain, temp dirs and in-memory custody only — no stage, no dev store, no Keychain.
  Smoke-verified: the full Mac target compiles there (41 s) and a test runs.
- DONE (this commit) — STEP 1, THE REPRODUCTION PIN, RUN AT HEAD: **§W.2's trace REPRODUCES IN WHOLE.**
  `VariorumTests/VX209WayBackRoundTripTests` (1 test, a CHARACTERIZATION pin of the known hazard — it asserts what
  the shipped road does, and is to be FLIPPED, never deleted, when VX-209's deeper fix lands). Harness run at HEAD
  `31a25058` (+ this file): `✔ Test run with 1 test in 1 suite passed after 1.357 seconds` (the file's sha256 in the
  harness equals the worktree's, printed by `sync.sh`). The world: a LOCAL-ONLY library, Standard era under L_s
  (key file: passphrase copy + Apple copy), a backup pair made by the app's own `StoreBackup.performPrimaryLeg`,
  then Castle as the local road leaves it on disk (re-keyed to L_c via `StoreEncryptionMigration.rekey`, a new key
  file under the SAME store id with the passphrase copy and no Apple copy, the Standard-era file left beside it —
  O.4 — custody gated L_c, no silent item, A still readable). Driven through the PRODUCTION pieces: the classifier,
  `LibraryOpenModel` (begin → its own silent/Apple/typed roads → confirm → `confirmAdoption`, whose work is
  `LibraryAdoption.execute` + `landCustody`), a production `AppBootstrap` (test opener) whose launch routes to the
  Castle lobby and whose ready road runs after each adoption, and the gate's route read (`effectiveGate`).
  What the run shows, step by step:
  - Premise: the launch routes to the lobby (`.biometric`); Touch ID opens; no silent item exists.
  - **Step 1 (Restore the Standard-era backup):** opens SILENTLY through the Apple road (no unlock phase), lands;
    the live key file is the backup's (same store id, carries the Apple copy); custody = the silent item holds L_s;
    **the Castle library's Touch ID item is DELETED**; the next route reads `.auto` (no lobby). §W.2's "lands
    Standard silently" and its parenthetical (the gated item deleted under the same rule) — both CONFIRMED.
  - **Step 2 (bring the Castle copy back from `Previous Libraries/<stamp>/`):** the folder classifies as the pair
    served by the CASTLE key file (the newest of the two beside it); no silent road serves it (the silent item holds
    L_s, the copy carries no Apple copy, the gated item is gone) — the passphrase opens it; after the adoption the
    CASTLE key sits in the SILENT item, no Touch ID item exists, and **the brought-back Castle copy's key file has
    gained an Apple copy that unwraps to the Castle key** — §W.2's way-back revert, CONFIRMED.
  - **One refinement the run found (the trace said "the next route's landing arm"):** the Apple copy lands ALREADY
    at the adoption's own reopen — the ready road's R1-M3 condition evaluates `currentEffectiveGate`, whose landing
    arm writes — so the revert is complete in the SAME session, before any relaunch. The next route then reads
    `.auto` (Standard, no lobby).
  - **Attribution check (harness copy only, never the worktree):** corner 45's silent arm mutated
    (`localReading`'s `case .silent: return .standard` → `.castle`) in the harness's COPY of
    `StoreProtection.swift`; the same pin then fails on EXACTLY the step-2 facts — `backing.auto == castleKey`,
    `backing.gated == nil`, the Apple copy at the reopen (4 issues) — while every step-1 assertion stays green. The
    way-back revert is corner 45's, as the trace says. The copy restored by `sync.sh`, `cmp`-identical to the
    worktree; `git status` showed only the new pin file.
  - The Mac-target compile of this file in the real project (`build-for-testing`) — PENDING (one build after the
    confirm line lands); its stage run — PENDING (listed at the close).
- DONE (this commit) — STEP 2, THE CONFIRM LINE (code + pins; the revert cycles are the next commit):
  `LibraryOpenCopy.confirmLeavesCastle` (the ONE home, PROVISIONAL — drafts below); `LibraryOpenModel` gains the
  confirm fact `leavesCastle`, computed at `enterConfirm` (both roads) by the pure, nonisolated
  `LibraryOpenModel.leavesCastle(currentIsCastle:incoming:)` over the CLASSIFIER's verdict (kept as
  `incomingVerdict` at `land`): the plaintext arm (`.plaintextExport`/`.plaintextLibrary`) always, the pair arms
  (`.encryptedLibrary`/`.snapshotPair`/`.folderHoldingPair`) when the picked copy's OWN key file reads Standard by
  `Posture.derive` with no vault word and no custody in view (decision 8's before-sync rule — an Apple copy, or no
  passphrase copy at all); "current is Castle" = a library stands (`willStepAside`), the bootstrap is `.ready`, and
  `protection.posture == .castle` (only a ready library can stand behind this door in Castle: the Castle lobby and
  the failure face render no Open door; the File menu and Settings exist only at ready). The Mac sheet
  (`LibraryOpenSheet`, the ONE sheet every adopt road presents) renders it right under the confirm's lead, caption
  + the alarm voice (PROVISIONAL placement). Zero adopt/restore machinery lines (the brief's constraint): the
  model's flow, the adoption, custody and the gate are byte-untouched. The reproduction file's world moved into the
  shared internal `VX209CastleWorld` (+ a plaintext export of the Standard era; the reproduction's assertions are
  byte-unchanged).
  Pins `VariorumTests/VX209LeavesCastleConfirmTests` (4): the decision on real classifier verdicts (the backup pair,
  a carried folder pair, a never-passphrased Standard copy, the export — true over Castle, false over not-Castle;
  a Castle-era copy and refusal verdicts false) · the model on a Castle library at READY through the real flow (the
  backup and the export carry the line, a Castle copy of the same library — served by the one Touch ID ask — does
  not; after the backup is adopted the export no longer earns it) · the face (the sheet renders it under the fact;
  both presenters compose the one sheet; the File menu and the restore row drive them; the sentence rendered by
  the sheet ALONE across Shared + Mac + phone) · the register. Harness run at the fix: `✔ Test run with 5 tests in
  2 suites passed after 2.058 seconds` (both VX-209 suites; the face pin reads the harness's read-only mirrors of
  the three app folders, re-copied every sync).
- DONE (this commit) — THE STEP-2 REVERT CYCLES, all four RUN in the harness (announced at `ccd10881` before any
  started; each: `git apply` in the worktree → `sync.sh` → `git checkout --` the file at once → `git diff --stat`
  read EMPTY → build + `swift test --filter VX209LeavesCastleConfirmTests`; the cycle script
  `vx209-harness/revert-cycle.sh`). Each RED exactly on its named legs, every other pin green:
  **R-209-rule** — 6 issues: the classifier pin's four true arms (the backup pair, the carried folder, the
  never-passphrased copy, the export) + the model pin's two Castle-world lines (backup, export) · **R-209-plaintext**
  — 2 issues: the export leg of each · **R-209-model** — 2 issues: the model pin's two lines (the classifier pin
  green — the rule stands, the model never asks it) · **R-209-face** — 3 issues: the sheet's `if model.leavesCastle {`,
  its `Text(LibraryOpenCopy.confirmLeavesCastle)`, and the one-renderer sweep (`[]`). After the last cycle the
  harness re-synced to HEAD: `✔ Test run with 5 tests in 2 suites passed after 1.767 seconds`; the worktree clean.
- DONE (this commit) — STEP 3, THE GUIDE WARNING, after THE RE-VERIFICATION the brief asked for. **It CHANGED
  the instruction (F-U5-2):** §W.2's road ("check Settings ▸ Protection and choose Use Castle again") is
  INCOMPLETE at HEAD — every adoption lands HELD (13x round 3, `LibraryAdoption.execute(holding:)`), and a
  standing hold REFUSES Use Castle at its door with `ProtectionCopy.resumeSyncFirst` (13x F1 R1-M1, pinned by
  `Phase13pControllerTests.aStandingRestoreHoldRefusesTheRotationCeremoniesAtTheDoor`). The road that works is
  **Resume Sync first, then Use Castle** — now PINNED on the reproduced library itself (below). U1's landed
  behavior checked too: belt c refuses the Apple landing only while `switchPending` is set, and nothing sets it on
  an adoption — the reproduction ran at HEAD (U1 in) and the landing happened; the road back stands.
  Built: `ProtectionCopy.privacyOlderCopyParagraph` (PostureCopy, the guide's privacy section — PROVISIONAL, drafts
  below), rendered by the MAC's `TutorialSeeder` at the END of lesson 2 ("Standard and Castle: what you must
  keep") — `privacyLessonTwoParagraphs + [privacyOlderCopyParagraph]`; the phone's seeder untouched (its edition
  has no open/restore door — P-U5-3). Its last sentence is also F2's road (a library a pre-VX-202 build left reading
  Standard). The step-2 confirm line REVISED to the same verified road (Resume Sync, then Use Castle); its
  register pin gained the Resume Sync leg.
  Pins `VariorumTests/VX209GuideWarningTests` (4): the words (the doors by their own constants — Restore from
  Backup, File ▸ Open Library…, the Data Safety and Protection pane titles — Previous Libraries named as the road
  that does not undo it, Resume Sync BEFORE Use Castle, the generic Standard-when-you-chose-Castle sentence) · the
  register · the SEEDED Mac guide (a fresh in-memory `TutorialSeeder.restore`: lesson 2 carries the paragraph
  verbatim beside the Castle floor, the shared paragraphs whole) · **the road is real (a BOUND):** on the library
  §W.2's round trip leaves behind, with the composition root's hold wiring (`RestoreHoldModel.wireGates`): the hold
  stands, `PostureSwitchModel(.enter).start()` → `.failed(resumeSyncFirst)`; `hold.resume()` clears it; a fresh
  `.enter` start → `.explain` (Use Castle opens its first screen).
  HARNESS (test target now compiled with the xcodeproj's TEST settings — no default MainActor isolation, which the
  app target alone carries; the TestSupport `CopiedRow.swift` copied as the project shares it): all three VX-209
  suites + `TutorialPrivacyChapterTests` + `VX204PrivacyLessonTests`: `✔ Test run with 13 tests in 5 suites passed
  after 2.556 seconds`. Every suite in `TutorialWalkTests.swift` + `CopyRegisterPinTests` beside them: 94 tests in
  16 suites, ONE red — `CopyRegisterPinTests.theEncryptionBookNamesNoKeyFamilyInternalButItsOneRecordedSentence`,
  `.resourceMissing`: the harness copies no bundle resources (it reads `EncryptionExplained.txt`); a harness
  artifact, not a finding — PENDING its stage run like every other.
- DONE (this commit) — THE STEP-3 REVERT CYCLES, both RUN in the harness (announced at `7c7b00fe`; the same
  cycle; filter `VX209|TutorialPrivacyChapterTests|VX204PrivacyLessonTests`, 13 tests in 5 suites each):
  **R-209-guide-seed** — 1 issue: the seeded pin (`lessonTwo.contains(privacyOlderCopyParagraph)`), every other pin
  green (the chapter's two-lesson and copy-§7 pins included) · **R-209-guide-words** — 2 issues: the guide's road
  pin (`resume != nil && useCastle != nil`) and the confirm's register pin (`line.contains(resumeSyncDoor)`). The
  BOUND road pin stayed GREEN through both (it proves shipped behavior, not this unit's words). After the cycles the
  harness re-synced to HEAD: `✔ Test run with 13 tests in 5 suites passed after 3.388 seconds`; the worktree clean.
- DONE (this commit) — the reproduction pin gains the READY HOUSEKEEPING's leg (production runs the reconcile at
  every ready; the test opener skips it, so the pin calls `protection.reconcile()` after the way-back): VX-202's
  sweep (belt b) has nothing to act on (no Touch ID item beside the silent one) and the Apple arm VERIFIES the copy —
  `postureReading == .determined(.standard)`, `appleKeyVerified == true`, the Castle key still in the silent item.
  Nothing on the ready road heals the revert. Harness: `✔ Test run with 13 tests in 5 suites passed after 5.075
  seconds`. (Two harness-only probes, never in the repo, preceded it: the controller's posture projection reads
  CASTLE right after the way-back adoption and Standard after the next envelope refresh — F-U5-5; and the reconcile
  outcome above.)
- VERIFIED (the real project): Mac `build-for-testing` (Variorum, `-derivedDataPath DerivedData/vx201`, index store
  off) `** TEST BUILD SUCCEEDED **` at `6c8bfea2`'s tree, zero warnings in the changed files, the three VX-209 files
  compiled; phone `build-for-testing` (VariorumMobile, generic iOS Simulator, same DerivedData) `** TEST BUILD
  SUCCEEDED **`, the three changed Shared files compiled for the phone, zero warnings in them.
- VERIFIED: the Mac `build-for-testing` re-run at `0250cd3f` (the pin's reconcile leg) — `** TEST BUILD SUCCEEDED
  **`, zero warnings in the changed files; `DerivedData/vx201` holds HEAD's products. **No revert is applied.**
- CLOSED (this commit): the verdict, the design, the pins + cycles, the stage protocol and suites (struct types),
  the walk recipe, the copy drafts, the PROVISIONALs, the findings.

### THE VERDICT (the headline) — §W.2's trace REPRODUCED IN WHOLE, one step earlier than it said
Run at HEAD (U1–U4 in) through the production pieces, a LOCAL-ONLY Castle library that had a Standard era:
1. **Restoring the Standard-era backup lands Standard silently** — it opens through the Apple road with nothing
   typed; custody ends as the silent item holding the backup's key; **the Castle library's Touch ID item is
   deleted** (`landCustody`: `adoptOpeningKey`, the effective gate `.auto` by the backup's Apple copy).
2. **Bringing the Castle copy back from `Previous Libraries/<stamp>/` lands Standard too** — the passphrase opens
   it; `landCustody` finds the backup's key in the silent item for the SAME store id ⇒ `adoptOpeningKey`; the gate
   reads `.silent` + a key file with a passphrase copy and no Apple copy ⇒ corner 45 ⇒ Standard ⇒ `.auto` ⇒ the
   Castle key saved SILENT, no Touch ID item; **and the key file gains an Apple copy of the Castle key** — not only
   at "the next route" as §W.2 said, but already at the adoption's own reopen: the ready road's R1-M3 condition
   reads `currentEffectiveGate`, whose landing arm writes (F-U5-6). The ready housekeeping's reconcile then
   VERIFIES it (determined Standard, `appleKeyVerified == true`; VX-202's sweep has nothing to act on).
3. Attribution: corner 45's silent arm mutated in the harness COPY (`.silent → .castle`) reds exactly the step-2
   facts and nothing of step 1.
4. U1's belts do not touch it (as the U1 adjudication's F2 predicted): belt c refuses the landing only while
   `switchPending` is set — nothing sets it on an adoption; belt b needs a Touch ID item beside the silent one.

### What landed (the design)
- **Step 2 — the confirm line.** `LibraryOpenModel.leavesCastle(currentIsCastle:incoming:)` — pure, nonisolated,
  over the CLASSIFIER's verdict: the plaintext arm always; the pair arms (`.encryptedLibrary` / `.snapshotPair` /
  `.folderHoldingPair`) when the picked copy's OWN key file reads Standard by decision 8's before-sync rule
  (`Posture.derive` with no vault word and no custody in view: an Apple copy, or no passphrase copy at all); every
  refusal-shaped verdict false. "Current is Castle" = a library stands (`willStepAside`), the bootstrap is `.ready`
  and `protection.posture == .castle` — only a ready library can stand behind this door in Castle (the Castle lobby
  and the failure face render no Open door; the File menu and Settings exist only at ready). Computed once at
  `enterConfirm` (both roads) from the verdict kept at `land`. ONE copy home, `LibraryOpenCopy.confirmLeavesCastle`,
  rendered by the ONE sheet (`LibraryOpenSheet`) that File ▸ Open Library…, the lobby faces and Restore from Backup
  all present — right under the confirm's lead, caption + the alarm voice.
- **Step 3 — the guide warning.** `ProtectionCopy.privacyOlderCopyParagraph`, the LAST paragraph of the MAC's
  lesson 2 ("Standard and Castle: what you must keep") via `TutorialSeeder` (`privacyLessonTwoParagraphs +
  [privacyOlderCopyParagraph]`); the phone's edition untouched (it has neither door). Written against the RUN, and
  RE-VERIFIED (F-U5-2): Resume Sync first, then Use Castle. Its last sentence is also U1 F2's road (a library a
  pre-VX-202 build left reading Standard).

### THE PINS (9 new) — the harness's runs and the red-on-old protocol (stage runs PENDING)
| suite (struct type) | test | kind | red under (each RUN in the harness — LIVE STATUS) |
|---|---|---|---|
| `VX209WayBackRoundTripTests` | `aCastleLibraryOpenedOnAStandardEraBackupAndBroughtBackLandsStandardBothWays` | CHARACTERIZATION of the known hazard (P-U5-6) | the corner-45 mutation (harness copy): 4 issues, the step-2 facts only |
| `VX209LeavesCastleConfirmTests` | `theLineRidesThePairArmAndThePlaintextArmOfTheClassifier` | the decision on real verdicts | **R-209-rule** (4) · **R-209-plaintext** (1) |
| 〃 | `aCastleLibrarysConfirmCarriesTheLineForAStandardEraBackupAndAnExportOnly` | the model at READY, the real flow | **R-209-rule** (2) · **R-209-plaintext** (1) · **R-209-model** (2) |
| 〃 | `theOneSheetRendersTheLineForEveryAdoptRoad` | the face (source) | **R-209-face** (3) |
| 〃 | `theLineNamesTheRoadBackInTheEverydayRegister` | the words | **R-209-guide-words** (1) |
| `VX209GuideWarningTests` | `theWarningNamesTheDoorsAndTheRoadThatWorks` | the words | **R-209-guide-words** (1) |
| 〃 | `theWarningKeepsTheGuidesRegister` | the register | BOUND (green under every revert) |
| 〃 | `theMacsGuideClosesTheCastleLessonOnTheWarning` | the SEEDED Mac guide | **R-209-guide-seed** (1) |
| 〃 | `afterTheWayBackResumeSyncThenUseCastleIsTheRoadThatOpens` | BOUND — the shipped road the words lean on | green under every revert (it proves shipped behavior) |
`VX209CastleWorld` (in the round-trip file) is a shared fixture, NOT a suite — never pass it to `-only-testing`.
The six patches: `notes/plans/fixes/vx-201-u5-reverts/{R-209-rule,R-209-plaintext,R-209-model,R-209-face,
R-209-guide-seed,R-209-guide-words}.patch` (repo-root-relative; all `git apply --check` clean at the close).

**Stage protocol (from `App/Variorum/`, under a held claim):** green first —
`xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx201
-only-testing:VariorumTests/VX209WayBackRoundTripTests -only-testing:VariorumTests/VX209LeavesCastleConfirmTests
-only-testing:VariorumTests/VX209GuideWarningTests` — expect "Test run with 9 tests in 3 suites" (no `.enabled(if:)`
gates; the round-trip and road pins sleep 1.1 s each between two adoptions — whole-second stamps, F-U5-7). Then each
revert ALONE: `git apply notes/plans/fixes/vx-201-u5-reverts/<R>.patch` (from the repo root), `build-for-testing`
(same flags), the same `test-without-building`, read the reds against the table, `git checkout --` the patched
file(s), confirm `git diff HEAD --stat` EMPTY; rebuild HEAD after the last cycle. (The harness already ran all six;
the stage's cycles are the canonical record.)

**Existing suites (changed-SOURCE rule — suites whose source names a changed type: `LibraryOpenModel`,
`LibraryOpenCopy`, `LibraryOpenSheet`/`LibraryOpenPresenter`, `TutorialSeeder`, the privacy-lesson constants;
`ProtectionCopy` only GAINED a constant, so beyond the lesson readers its suites are covered by the copy sweeps
below) — PENDING, one stage run** with `-only-testing:VariorumTests/` + each STRUCT TYPE: VX209WayBackRoundTripTests
VX209LeavesCastleConfirmTests VX209GuideWarningTests LibraryPortabilityDoorTests CapabilityRegistryTests
CalmAsksTests NewModesTests ShellConfirmTests TakeCardDoorTests SnippetOpenTargetTests SnippetsLandingTests
SnippetTagDoorTests SampleLibraryWelcomeTests LaunchFurnitureTests EncryptionBookDoorTests EncryptionExplainedDrillTests
TourScriptTests TourSpotlightTests TourEngineTests TourPoolTuckTests TourEntryTests TourEndCardTests
TourEndCardAsideGateTests TutorialBooksLessonTests TutorialBooksRitualTests TutorialBuildFlavorTests
TutorialCurrencyTests TutorialFurnitureFoldTests TutorialMCPChapterTests TutorialMCPChapterCaptureTests
TutorialBookShapeTests TutorialDoorTests TutorialWritingActsTests TutorialTakesActsTests TutorialStructureActsTests
TutorialLookingActsTests TutorialLibraryActsTests TutorialDeletionActsTests TutorialWherePlacesActsTests
TutorialPrivacyChapterTests TutorialFannedMatrixTests VX204PrivacyLessonTests VX202ReopenRaceTests
CopyRegisterPinTests Phase13pCopySweepTests ProtectionCopyTests TerminologyPinTests RetiredNamesPinTests
NoLiteralColourTests StatusSeamVocabularyTests UnfiledWordTests. Already green in the harness (a different kind of
evidence): the three VX-209 suites, TutorialPrivacyChapterTests, VX204PrivacyLessonTests, every suite in
`TutorialWalkTests.swift`, NoLiteralColourTests, StatusSeamVocabularyTests, UnfiledWordTests, Phase13pCopySweepTests,
CopyRegisterPinTests bar its one bundle-resource test (`.resourceMissing` — the harness carries no resources).
Phone (simulator, by UDID — `-only-testing:VariorumMobileTests/` + each STRUCT TYPE; the files are multi-struct):
MobileStructuralTests MobileNoRedirectSweepTests (expect ONLY VX-114's pre-existing offenders — no new literal names
the Mac; pinned by the two `\bMac\b` legs here) MobileCopyRegisterSweepTests MobilePhoneProtectionCopyTests
MobilePocketGuidePrivacyTests MobileTutorialBookShapeTests.

### THE WALK (the orchestrator's window — the DEV store, Debug build, both voices; it ADOPTS copies on the dev store)
1. Dev store in Standard, local-only, a passphrase and the twelve words set. Settings ▸ Data Safety ▸ Back Up Now (a
   Standard-era pair). Settings ▸ Protection ▸ Use Castle… → Enter Castle. Relaunch: Touch ID asks.
2. Settings ▸ Data Safety ▸ Restore from Backup → the Standard-era row's Open… → the CONFIRM carries the Castle line
   under "Ready to open this library." — capture (Terminal + Study). Cancel. (Optional: File ▸ Open Library… on a
   plaintext export — the line again, capture.)
3. Restore it for real (Open This Library). Settings ▸ Protection reads Standard; the hold banner stands — capture.
4. File ▸ Open Library… → `Previous Libraries/<stamp>/` (the Castle copy) → the passphrase → the confirm carries NO
   line (F-U5-3, visible) → Open This Library → Protection STILL reads Standard (the reproduced way-back, live) —
   capture.
5. Use Castle… → "Resume sync first — this library was just restored from a copy…" — capture. Resume Sync → Use
   Castle… → Enter Castle → Done; relaunch asks Touch ID — capture.
6. The guide: Help ▸ Restore Tutorial… (or a fresh dev store) → keeping it private ▸ "Standard and Castle: what
   you must keep" → its last paragraph, both voices — capture.

### U5 COPY DRAFTS (for the QUESTIONS #215 bundle — every line PROVISIONAL until she approves)
Sentence case, no capitals for emphasis, the everyday register (no key named), no device literal (the phone's sweep).
1. **The confirm's Castle line** (`LibraryOpenCopy.confirmLeavesCastle`), under "Ready to open this library." when
   the library standing here is Castle and the picked copy isn't: *This copy isn't in Castle, so once it's open your
   library opens the old way — press Resume Sync, then choose Use Castle again in Settings ▸ Protection to put it
   back in Castle.*
   - Alternative A (concrete): *This copy isn't in Castle, so once it's open your library opens without asking and
     through your Apple account — press Resume Sync, then choose Use Castle again in Settings ▸ Protection.*
   - Alternative B (true for every account shape — F-U5-4): *This copy isn't in Castle. Once it's open, press Resume
     Sync, then check Settings ▸ Protection — if it doesn't say Castle, choose Use Castle again.*
2. **The guide's older-copy paragraph** (`ProtectionCopy.privacyOlderCopyParagraph`, the Mac's lesson 2, last):
   *Opening an older copy of your library — a backup in Settings ▸ Data Safety ▸ Restore from Backup, or a copy you
   pick with File ▸ Open Library… — makes that copy your library, and a copy from before Castle opens the old way.
   Bringing your Castle library back from Previous Libraries afterwards may not undo that. So once you're done with
   an older copy, press Resume Sync, then check Settings ▸ Protection: if it doesn't say Castle, choose Use Castle
   again. And any time Protection says Standard when you chose Castle, choose Use Castle again.*
   - Alternative (shorter): *If you open an older copy of your library (Restore from Backup, or File ▸ Open
     Library…), Castle may not come with it — even after you bring your Castle library back. When you're done,
     press Resume Sync and check Settings ▸ Protection; if it doesn't say Castle, choose Use Castle again.*

### PROVISIONALs (mine — each defended; the orchestrator's to confirm or bundle)
- **P-U5-1 — "the current library is Castle"** = a library stands + `.ready` + `protection.posture == .castle` (the
  acting posture the pane shows, an enrolled library's custody-shape reading included) — the brief's condition.
- **P-U5-2 — "the incoming copy reads Standard"** = its OWN key file by decision 8's before-sync rule (the classifier
  facts the brief names), never a prediction of how it lands on THIS Mac (that needs custody reads per store id).
- **P-U5-3 — the guide paragraph is the Mac's alone, at the END of lesson 2** (the phone has neither door).
  Alternative: right after the Castle paragraph.
- **P-U5-4 — the line's placement and voice:** right under the confirm's lead, caption + the alarm voice (the Castle
  notices' voice).
- **P-U5-5 — both texts name Resume Sync before Use Castle** (F-U5-2's verified road, not §W.2's).
- **P-U5-6 — the reproduction pin is a CHARACTERIZATION pin:** it asserts the hazard as it stands, so it is green at
  HEAD; in the brief's polarity (a pin asserting the Castle promise) it is RED on HEAD at every step-2 fact — the
  reproduction. When VX-209's deeper fix lands it goes red by design: FLIP it, never delete it.

### Findings for the orchestrator (dispositions owed by the run)
- **F-U5-1 — THE VERDICT: REPRODUCED IN WHOLE** (above), with one refinement: the Apple copy of the Castle key lands
  at the adoption's own reopen, not only at the next launch.
- **F-U5-2 — §W.2's road was INCOMPLETE; both texts carry the verified one.** Every adoption lands HELD, and a
  standing hold refuses Use Castle at its door (`resumeSyncFirst`, 13x F1 R1-M1). The road that works — Resume Sync,
  then Use Castle — is PINNED on the reproduced library (`afterTheWayBackResumeSyncThenUseCastleIsTheRoadThatOpens`).
  The handoff's and VX-209 ticket's wording of "today's honest instruction" should carry Resume Sync too.
- **F-U5-3 — the way-back step itself earns NO confirm line under the brief's condition** (by then the current
  library reads Standard), though it lands the old way while she believes she is restoring Castle. Options: (a) AS
  BUILT — the step-1 line and the guide name Use Castle (never Previous Libraries) as the road back; (b) a second
  condition and sentence — the picked copy reads Castle by its own key file AND this Mac's custody for the same store
  id is silent (the landing will read Standard-waiting) — e.g. *"This copy was in Castle, but on this Mac it will
  open the old way — press Resume Sync, then choose Use Castle again."*; (c) VX-209's deeper fix retires the need.
  Recommendation: (a) tonight, (c) after launch; (b) only if she wants it before launch (cheap: a custody READ in
  the model, no machinery line). Hers — a #215 question.
- **F-U5-4 — the ENROLLED shape (traced from code, NOT pinned — this world is local-only):** a Standard-era backup
  of an enrolled Castle library lands Castle-SHAPED (the indeterminate custody shape ⇒ behind Touch ID) with an Apple
  copy live in its key file until the 13x R1-BLOCKER follow re-keys it, and bringing the Castle copy back restores
  Castle custody. So for enrolled libraries the line's "opens the old way" overstates the gate half (the Apple half
  is true until the follow); the guide's "may not undo" and "if it doesn't say Castle" hold. Alternative B above is
  the shape-independent line.
- **F-U5-5 — the controller's posture projection reads CASTLE right after the way-back adoption** (observed in a
  harness-only probe): `adoptResident(opener)` makes `libraryKeyCustodyShape` say gated-or-none even under silent
  custody, so corner 45 reads the passphrase-only key file as Castle until the next envelope refresh — the ready
  housekeeping's reconcile, milliseconds later in production (a test opener skips it, so the pin calls it). Record-
  only; the resident-as-shape heuristic after an Auto-road adoption is worth naming on VX-209's deeper-fix ticket.
- **F-U5-6 — `currentEffectiveGate` is a read with a write** (the route's landing arm): every read — the ready's
  R1-M3 condition, `lock()`, the phone's relock coordinator, the migration facts — can land an Apple copy on a
  Standard-waiting-shaped library. By design for corner 45's heal, and exactly the vector that completes the way-back
  revert mid-session; for VX-209's deeper-fix ticket.
- **F-U5-7 — whole-second adoption stamps:** two adoptions inside one second collide on the stamp folders (the
  second refuses at its safety copy, nothing moved) — unreachable by hand through the sheets; the pins sleep 1.1 s.
  Record-only.
- **F-U5-8 — the headless harness (tooling, NOT in the repo):** a scratch SwiftPM package (`vx209-harness/` in the
  session scratchpad) compiles the Mac target + Shared byte-copied (the `@main` attribute stripped from the COPY of
  `VariorumApp.swift`; the app target's settings for the library, the test target's for the tests; the project's
  package pins; the `TestSupport` `CopiedRow.swift`; read-only mirrors of the app folders for source-reading pins) and
  runs Mac test files under `swift test` — its own process and defaults domain, no Keychain, no dev store, no stage.
  It ran this unit's pins, the six revert cycles, the attribution mutation and two probes; tests that read bundle
  resources fail there. Offered as a possible run tool (the stage stays the canonical run); `sync.sh` +
  `revert-cycle.sh` are its two scripts.

### ORCHESTRATOR ADJUDICATION — U5 (verified against git before adoption: commits 31a25058 → b4a7b261 as
reported; zero `Sources/` lines across U5's whole span by path diff — so zero `Sync/` — zero trailers; the
changed set is exactly the two LibraryOpen Shared files + PostureCopy + LibraryOpenDoor + TutorialSeeder + the
three pin files + six patches; the adopt/restore machinery byte-untouched as constrained)

- **F-U5-1 — THE VERDICT ADOPTED; this is the run's headline finding for the morning handoff.** §W.2 reproduced
  IN WHOLE at HEAD through the production pieces, with the refinement that the revert COMPLETES IN THE SAME
  SESSION (the adoption's own reopen reads `currentEffectiveGate`, whose landing arm writes — F-U5-6). Her
  carried-forward reminder 2 is fully vindicated: the pin-first order caught two things the read-only trace
  missed (the same-session completion AND the incomplete road back). NOT a new launch blocker: the hazard is
  §W.2's known one, now proven and honestly worded at both doors; the deeper fix remains VX-228's design space.
- **F-U5-2 — ADOPTED; the verified road is Resume Sync, then Use Castle.** Both shipped texts carry it, pinned
  on the reproduced library itself. Actions at closeout: a comment on VX-209's ticket correcting "today's honest
  instruction", and the morning handoff's wording carries Resume Sync. My U1-F2 adjudication's "the guide
  sentence STANDS" stands AS AMENDED by this road.
- **F-U5-3 — (a) CONFIRMED for tonight** (the step-1 line + the guide name Use Castle as the road back, never
  Previous Libraries); (b) offered in #215 with the implementer's draft (cheap, a custody READ only); (c) is
  VX-228's. Her call, bundled.
- **F-U5-4 — bundled:** Alternative B is the shape-independent line (the enrolled shape is traced, not pinned —
  honestly marked); the #215 bundle flags B's property so her pick is informed. The ladder re-examines the
  enrolled trace (custody).
- **F-U5-5 + F-U5-6 — record-only tonight; BOTH land as comments on VX-228** (the corner-45 deeper-fix ticket)
  at closeout: the resident-as-shape heuristic after an Auto-road adoption, and the read-that-writes vector
  (`currentEffectiveGate`) that completes the revert mid-session. **F-U5-7 — record-only** (unreachable by hand;
  the pins sleep).
- **F-U5-8 — the harness ADOPTED as evidence of its own kind, exactly as marked** (never the stage's; window E
  is the canonical record). The construction is fully recorded here, so the knowledge survives the scratchpad;
  offered to her in the morning handoff as a possible standing tool (her call; the stage remains canonical).
  Cleanup at closeout.
- **P-U5-1…6 — ALL CONFIRMED** (1/2 read the brief's condition correctly; 3's phone-less guide is right — the
  phone has neither door; 4's placement PROVISIONAL → #215; 5 is F-U5-2's verified road; 6's
  characterization-pin polarity — green at HEAD documenting the hazard, FLIP never delete at the deeper fix —
  is the honest shape and is recorded on VX-228 too).
- **Copy drafts adopted into the #215 input as written** (the confirm line + alternatives A/B, the guide
  paragraph + the shorter alternative). U5's acceptance evidence owes WINDOW E: the 9 pins green AS STAGE RUNS,
  the six revert cycles, the ~50-type Mac existing-suite run, the 6 phone types — at the branch tip, after
  window D phase 2 releases the pinned checkout. VX-233's time-boxed heal (her ruling: slots after U5) OPENS NOW
  in the live worktree; its drill re-run folds into window E.

## VX-233 BOX (the time-boxed drill-harness heal — her ruling: ~90 min cap, test-harness side only, auto-fallback)
- **The trace (within the box, building on windows A/C):** all three drill failures share one signature — the
  clock dependency "has no test implementation" resolved from the engine's stored property during the drills'
  push/pull legs. Those legs run inside `withDependencies` blocks that provide ONLY the database, while the same
  files' own SEEDING blocks provide the clock and id generators too (and pass). A stored `@Dependency` resolves
  at ACCESS time, so the engine legs trap exactly where the drill's scope stops providing values. The 13x
  precedent (phase-13x-library-portability.md:796) fixed this identical class the same way.
- **The fix (bc07cc76, test-harness side only, zero product lines):** every database-only `withDependencies`
  block in `PostureSwitchDrillTests.swift` (8 sites) and `ConnectDrillTests.swift` (2 sites) expanded to the
  files' own seeding idiom — `$0.uuid` + `$0.date` live-value generators beside the database. Mechanical edit,
  diff read, Mac `build-for-testing` green. Box spend: well under the cap.
- **The VERDICT is window E's drill leg** (the posture + connect drills under their env vars at the tip): green
  ⇒ VX-233 closes with the run (the connect drill's instance proves with it); still red ⇒ the ruled fallback —
  the post-launch ticket stands, the attempt recorded here.
- **VERDICT (window E phase 1b): PARTIAL HEAL — THE RULED FALLBACK FIRES for the remainder.** The CONNECT drill
  is fully healed (its failure gone at the stage; migration green beside it). The POSTURE drill's two tests still
  record the same clock-dependency trap (SyncEngine.swift:19) — the access happens inside the switch runner's
  own QUEUED work, where a test-scope override does not reach. The remaining fix is drill-world composition
  surgery (inject the runner's engine leaf with explicit dependency values) or a product-side dependency escape
  at the runner's queue hop — the second re-opens her test-harness-only ruling by definition; both are
  post-launch. VX-233 stays OPEN with tonight's attempt + the narrowed diagnosis commented on it; box spend
  ~45 min of the ~90. The drill's PRODUCT legs complete (window A's reading stands).

### WINDOW E RECORD — PHASES 1+3 (orchestrator, stage claim vx201-u5-tests-p1; the pinned checkout at e6634d0e)
- **Phase 1 (Mac green pass): `✔ Test run with 318 tests in 51 suites passed after 257.812 seconds`** — U5's
  whole suite list incl. its 9 pins: the §W.2 round-trip reproduction, the confirm-line pins, the guide pins and
  the Resume-Sync-road BOUND are all STAGE-VERIFIED at the tip.
- **Phase 1b:** the VX-233 verdict above (connect healed · posture's two remain · fallback fires).
- **Phase 3 (phone, 6 struct types): 35 tests / 6 suites,** the only red the standing VX-114 sweep reading
  exactly its nine pre-existing offenders (the twice-printed list read and counted). U5 adds no phone literal.
- **Still owed:** phase 2's six revert cycles (queued after vx-184's U4, ~07:35). The FABLE LADDER round 1
  starts now — no stage, the whole-run diff final and suite-verified at the tip; the cycles verify pins without
  changing code, so round 1's input is stable. Logs /tmp/vx201-we-*.log.
