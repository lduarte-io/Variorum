# VX-329 — Castle rebuild: the release switch

**Status: OPEN — IN FLIGHT (kicked off 2026-10-22 under her overnight mandate; the kickoff record is §6; the run
pauses at U2's staging point — the real-store byte-copy rehearsal, the production deploy and the release are her
morning's). Plan written at VX-309's closeout, 2026-10-20; her kickoff calls ANSWERED at the 2026-10-22 sitting —
the kickoff block below carries them, QUESTIONS #237's answer block is the record.**
`Ticket: VX-329 · Project: Castle & backups before launch · Branch: vx-329-release-switch · Worktree:
~/dev/variorum-vx-329 (Pro)`. Holds the Sync/-custody slot.

> **KICKOFF MESSAGE (paste-ready).** STEP 0: the bout ritual (pull both repos, `Tools/vx sync`), then from
> `~/dev/variorum` on `main`: `git worktree add -b vx-329-release-switch ~/dev/variorum-vx-329 origin/main`; push
> the branch; the in-flight row (HOLDS the Sync/-custody slot); Linear VX-329 → In Progress; announce to the stage
> coordinator. **Read first, in full, never delegated:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`;
> `notes/CastleRules.md` WHOLE (rules 15, 26 and the considered-and-not-pursued ledger are this phase's heart);
> `notes/SyncSpec.md` WHOLE (§12 lockstep — the marker 13→14 bump is this phase's); `notes/SurfaceContracts.md`'s
> protection and doors sections; the VX-329 ticket body and its comments (VX-309's seven inputs);
> `notes/plans/vx-308-accounts-key-doors.md` §5R (the fresh-mirror runbook and the rehearsed artifact 17) and its
> WALK RECORD; `notes/plans/vx-309-copies-and-words.md` §8–§9 (the walk's machinery notes and the born tickets);
> `notes/plans/vx-266-castle-backups-prelaunch.md` §3.15 (today's deletion list — superseded where the ticket says
> "nothing is kept read-only"); QUESTIONS #237 (her VX-309 bundle — any answer there may reshape a unit).
> **Her calls — ANSWERED at the 2026-10-22 sitting (QUESTIONS #237's answer block is the record):**
> (1) the switch does NOT wait for VX-212 — phase 6 runs right after this merge, before her public launch.
> (2) the cold review is FABLE (credits are back; no waiver).
> (3) riders IN: VX-461 (the export door — rule 26 and §2 lean on it) · VX-465 (the device-ID drift trace) ·
> VX-462 · VX-464 · VX-473 · VX-463 (ruled: conceal the words fields, with a reveal eye) · VX-469's ruled (c)
> confirm line (wording) · VX-468 if it fits (ruled: the what's-new card waits after a restore). VX-213's `pg_temp`
> has her GO (2026-10-22 follow-up): rehearse it on the throwaway mirror with the rest; its PRODUCTION application
> rides the marker-14 deploy set in the release window — the deploy itself still runs only at her explicit go.
> **VX-470 is RULED but unsized**
> ((c) plus an explicit Standard choice, carried to T-5 — #237's shape): take it only if it fits a batch cleanly,
> else it leads the next run.
> (4) the release is **0.10** (her word: no 1.0 until public launch, and 0.9.9 "will just get more confusing");
> notes drafted for her.
> **VX-423 joins as its own unit** (U3 below — her call at the sitting).
> **No stage coordinator tonight:** VX-329 is the only session running — hold `Tools/stage` claims directly and
> skip the announce step.
> **The pause point (her word):** run U1, U3 and U2's throwaway rehearsal to completion, then PAUSE with everything
> staged for her hands — the byte-copy rehearsal of her real store waits for her morning (stage the byte copy if
> container access allows, else leave her the exact commands; A1 discipline and the zero-instance gate as ever).
> **The phone (her word):** the Macs switch first — see §3's revised deploy line and §4.

## 1. What this phase is

The last step of the rebuild: Release builds take the new road. One compile-time switch
(`ProtectionRoad.newRoadIsLive`) flips; today's whole deciding and writing code is deleted in the same change (the
old envelope, the legacy readers, the old markers, `CorpusRotation`, `PostureSwitch`, the posture drill VX-233, the
old suites whose release-floor reds are VX-406) — nothing is kept read-only. The `key_vault` lockstep (artifact
`Server/supabase/17_phase_vx307_vault.sql`, marker 13 → 14, registered in the DDL drift pin with `lockstepVersion` →
14 in ONE commit — VX-307's pinned pairing) deploys at her explicit go in this release's window. No migration (rule
26): everyone with a pre-design store exports or signs into sync before the switch, then starts fresh; her own old
stores are kept whole as copies.

## 2. The one question this phase must answer before any real store crosses

**How does a fresh new-road library get her synced writing back?** Today's account holds her rows sealed under
today's sync keys; the new account vault (artifact 17) is new. Rule 15 says the account keeps every sync key it has
ever had and a device joining years later reads everything — this phase must PROVE that holds across the switch (or
find that it doesn't and bring it to her), on the throwaway project, before her stores are touched. If the answer is
"export, then bring in", T-8 (VX-309) is the bring-in road and VX-461's export door must work first.

## 3. Proposed cut (the kickoff session's to make; acceptance units, one implementer each)

- **U1 — THE SWITCH (Fable-reviewed custody work):** flip the switch; delete today's road per the ticket; the
  lockstep commit (artifact 17 registered + `lockstepVersion` 14); the ⌃⌘L chord declared with its helper row
  (P-VX309-U1c-4 (b)); the protection suites green under the Release configuration (`swift test -c release`
  included — VX-380/VX-406's reds die with the deleted suites or are fixed). Evidence: the Release build runs the new
  road; the suites green under Release; the deletion is complete (a grep sweep table, each legacy symbol GONE).
- **U2 — SWITCH DAY, REHEARSED:** the step-by-step switch-day script for her (§2's answer inside it), run start to
  finish on the throwaway project with two test accounts and two devices' worth of libraries; then the rehearsal on a
  byte-copy of her real store on the dev slot (Look inside, then Make this my library — her hands, her credentials);
  the website delta brief REWRITTEN to the rules (F-U2-4) and handed to the site agent after a check against the
  shipped build; VX-379's truth-check of the guide and panes against the Release build, and her real store's re-seed
  plan. Evidence: the script walked green on the throwaway; her rehearsal done; the brief rewritten.
- **U3 — VX-423 (Fable-reviewed Sync/custody work):** one refresh authority for the scope's rotating refresh
  token — the vault leaf's provider (`FollowingSessionProvider` → its `AuthSession`) and the app's own `AuthSession`
  stop refreshing it independently (F-U1-1's trace, routed at VX-308; the reuse detection fires as
  `refresh_token_already_used` and sync stops until re-login). Evidence: a red-on-old pin on the two-refreshers
  race, and U2's throwaway rehearsal running with the fix in — switch day is wall-to-wall sign-ins, which is why
  this rides here rather than phase 6 (her call at the sitting).
- **The deploy and the release** are hers: the mirror deploy at her explicit go; **both Macs** updated in one window
  (her 2026-10-22 revision of "update every device first": the phone follows when VM-8's catch-up lands — *"it's ok
  if the phone doesn't sync for a day after the switch"* — and cannot sync against marker 14 until then); her
  acceptance on both Macs now and on the phone at its catch-up; the release at her word (**0.10**, notes drafted
  for her); then she deletes the throwaway project.

## 4. Dependencies and risks

- **The phone.** SETTLED at the 2026-10-22 sitting: VM-8 is still Backlog, so the Macs switch first and the phone
  joins when VM-8's faces land (its kickoff prompt is with her; that session runs AFTER this phase merges, on a
  main-based `vm-8` worktree — VM-5 retired the `mobile` branch 2026-10-07 and her phone runs MAIN-built installs,
  so it sits at main's marker today and there is no merge leg). Her current phone install cannot sync against
  marker 14 until the VM-8 build installs — accepted by her word.
- **The export door (VX-461)** writes an empty file today; rule 26's instruction must not name it until it's fixed.
- **Device-ID drift (VX-465)** must be traced: a drifting device ID in Release would make "this Mac's copies" and
  retention lie.
- **Release parity ends here:** every new-road face becomes Release-visible. The #237 calls are SETTLED
  (2026-10-22): VX-463's conceal-with-reveal-eye and VX-469's (c) confirm line ride this run; VX-468 waits-after-
  restore rides if it fits; VX-470's ruled shape is sized at the kickoff (see the kickoff block). VX-234's wording
  pass remains.
- **The cold review** is custody code — Fable, or her explicit waiver.

## 5. Records

Each unit appends its record here (the VX-309 §6 form); the ladder files `notes/plans/vx-329-ladder-round-N.md`;
the walk and the rehearsals in §8; the closeout in §9.

### U1 RECORD — THE SWITCH (Opus implementer, 2026-10-22; IN PROGRESS)

**Not done in U1, first:** PENDING (filled at the unit's end). Standing limits from the brief: no stage, no Debug launch, no
dev-store touch, no network, no Linear, no subagent, no `xcodebuild test` (the Mac suite list below is the orchestrator's);
zero `Sources/VariorumCore/Sync/` lines (the L1 flags below are the orchestrator's); `SyncSchema` untouched (L0's 14 stands).

**Preflight (complete, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md` whole;
`notes/CastleRules.md` WHOLE (rules 24, 26, "What we do not promise" and the considered-and-not-pursued ledger);
`notes/SurfaceContracts.md` whole (The app · Doors — Library portability + Library protection); this plan WHOLE (§1–§6, the
CUT, the OPEN DESIGN NOTE, the environment traps, §6a, the L0 RECORD, the VX-465 RECORD); `notes/plans/vx-266-castle-
backups-prelaunch.md` §3.12–§3.15; `ProtectionRoad.swift` WHOLE; `AppBootstrap.swift` WHOLE (the fork at :217, every
`newRoad` arm); `CapabilityRegistry.swift` around `.lockLibraryNow` + `Capability.swift`'s P-VX309-U1c-4 comment +
`HelperView.groups` + `CapabilityRegistryTests`' discoverability guard; the composition roots (`VariorumApp.swift`,
`AppServices.swift`, `LibraryOpenDoor.swift`); the envelope (`StoreKeyEnvelope.swift` WHOLE — the new core borrows its
fingerprint and its `PassphraseWrap`); the new road's names (`Protection/Model/Names.swift` — the format-3 key file is
`variorum-library-keys.json`, a name today's files never carry); the backup seam (`ProtectionBackupHook.swift`,
`ProtectionBackupPair.swift`, `StoreBackup.swift`'s outline); `LibraryHandOff.swift` WHOLE; the vx-309 §6 U1c record (the
form). Machinery note: the orchestrator's own commits interleave on this branch (`1d3b84a19`, VX-465; an untracked
`Server/` artifact in progress) — every U1 commit is pathspec-limited, rebased before each push.

**MY READINGS (each the brief's letter as I read it):** PENDING — filled per piece.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece R — this record skeleton: IN-PROGRESS (this commit).
- Piece 0 — the flip (`ProtectionRoad.live` → true unconditionally; the dev-store fence's parameter deleted with its
  callers' discrimination; the bootstrap's and the composition roots' `!newRoad` arms deleted): NOT-STARTED.
- Piece 1 — the Shared/ deletions (today's deciding and writing road in the app): NOT-STARTED.
- Piece 2 — the Persistence/ deletions (the envelope, custody, the legacy arms; the primitives the new core borrows
  relocated byte-for-byte, never re-implemented): NOT-STARTED.
- Piece 3 — the old suites (VX-233's drill, VX-406's list, VX-380's attacker test, every test of deleted code): NOT-STARTED.
- Piece 4 — ⌃⌘L declared on `.lockLibraryNow` with its helper row (P-VX309-U1c-4 (b)): NOT-STARTED.
- Piece 5 — the honest-refusal check (the §6 OPEN DESIGN NOTE): NOT-STARTED.
- Piece 6 — the sweep table: NOT-STARTED.
- Evidence — `swift test` + `swift test -c release` (counts), `xcodebuild build-for-testing` (Mac), the iOS target build:
  PENDING.

**L1 FLAGS (Sync/ references to deleted symbols — the orchestrator's carve; file:line, symbol):** PENDING.

**STOP-AND-FLAG ITEMS (a face only today's road provided):** PENDING.

**PROVISIONALs / FINDINGS:** PENDING.

**MAC-SUITE LIST (the orchestrator's stage batch):** PENDING.

## 6. THE KICKOFF RECORD (2026-10-22, the orchestrator — session `vx-329`, Fable, overnight mandate)

**Her mandate (the /architect-phase argument, faithful):** the only session tonight — no coordinator, hold
`Tools/stage` directly. Run U1, U3, the riders and the throwaway rehearsal to completion, then pause with everything
staged for her hands — the byte-copy rehearsal of her real store waits for her morning. Cold reviews are Fable.
Release 0.10. `pg_temp` has her go: rehearse it on the throwaway; production rides the marker-14 deploy set at her
morning go.

**Preflight done (read in full, never delegated):** CLAUDE.md + canon · SessionResiliencyProtocol · CastleRules WHOLE
· SyncSpec WHOLE · SurfaceContracts (The app, Doors — protection + portability) · the VX-329 ticket + all seven-input
comments (read via the Linear API) · the rider tickets' bodies (VX-423, VX-213, VX-461..470, VX-473, VX-379, VX-234,
VX-406, VX-233) · vx-308 §5R + REHEARSAL RECORD + WALK RECORD · vx-309 §8–§9 · vx-266 §3.15 · QUESTIONS #237 whole ·
the master plan + in-flight table · TICKETS.md. Workspace: branch `vx-329-release-switch`, worktree
`~/dev/variorum-vx-329` (Pro), in-flight row pushed on main (`c6b093258`), VX-329 + VX-423 In Progress in Linear.
The Sync/-custody slot is HELD by this effort; no other effort is in flight.

**Sizing, said plainly (the guidance's say-so):** U1 and U2 are the two phase-sized units; U3 and the rider batch are
small units. All four were ruled IN by her at the 2026-10-22 sitting (the kickoff block), so the shape is hers.

### THE CUT (final; one acceptance unit per implementer session, the orchestrator's own legs lettered L)

- **L0 (the orchestrator, Fable — Sync/ is Fable work): THE LOCKSTEP COMMIT.** One commit:
  `SyncSchema.lockstepVersion` 13 → 14 + `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles`
  (the drift pin enforces the pairing — the vx307 checklist's preflight row) + the four
  `MCPGrantSchemaTests` marker pins and `VX307VaultArtifactTests` read 14. Headless green before U1 spawns.
  Consequence stated: from this commit the branch's builds speak marker 14 — they sync only against the throwaway
  (already marker 14 since §5R) until the production deploy at her morning go; the dev store doesn't sync, so
  nothing strands. **No `/Applications` refresh this phase until the production deploy lands (the skill's
  lockstep-hold rule).**
- **U1 (Opus implementer #1, Fable cold review): THE SWITCH.** `ProtectionRoad.live` → true for every build;
  `opensOnTheNewRoad`'s dev-store fence dissolves (every store, every variant, both configurations take the new
  road; the bootstrap's `!newRoad` arms die — `AppBootstrap.swift:217` is the seam). Delete today's whole deciding
  and writing road per the ticket + vx-266 §3.15 (superseded where the ticket says "nothing is kept read-only" —
  the legacy readers go entirely): the old envelope (`StoreKeyEnvelope`), `RawKeyCustody`, `Posture.derive`, the
  13p read-through, `effectiveGate`/`landCustody`/`CustodyCollisionRule`/`ensuredEnvelope`, custody-by-library-ID,
  several-key-files-per-folder + newest-modified, the `switchPending`/`thisDeviceOnly` defaults, the five
  "enrolled" definitions, the session-stamped owner, Castle settings in UserDefaults, the shared never-deleted
  Apple key as a live road + 17m's Re-link, the silent follow into Standard, VX-202's belts, the duplicate safety
  copy, the old confirm/guide lines, the Finder-revealing restore, the identity-only silent sync item, today's flat
  `StoreBackup` leg where it is today's road's writer, `PostureSwitch`/`PostureSwitchModel`/`PostureFollowModel`/
  `PostureCopy`/`EncryptionSession`/`AppleRelinkModel`/`WordsCeremony` and the legacy arms of
  `ProtectionController`, the posture drill (`PostureSwitchDrillTests.swift`, VX-233's retirement) and the old
  suites (VX-406's list: `CorpusRotationTests`, `StoreKeyEnvelopeTests`/`Format2`, StringsWorkbook's
  `StoreUnlockTests`; VX-380's red attacker test fixed or dead with its subject). **FENCE: `Sources/VariorumCore/
  Sync/**` is NOT touched by this unit** — anything in Sync/ referencing deleted symbols is FLAGGED to the
  orchestrator (L1 carves it). ⌃⌘L declared with its helper row (P-VX309-U1c-4 (b) — the `.lockLibraryNow`
  capability gains its `shortcutLabel` + the shortcuts helper row). Evidence: the grep sweep table (every legacy
  symbol GONE, instance × file, each cell DELETED or provably new-road); `swift build`/`swift test` green BOTH
  configurations (`-c release` included — the protection set and the full core suite's release floor now honest);
  `xcodebuild build-for-testing` green; the phone builds; a Release-configuration build of the Mac app compiles.
- **L1 (the orchestrator, Fable): THE SYNC/ CARVE.** After U1: delete `Sync/CorpusRotation.swift`; retire the
  in-file `RotationMarker`'s live-marker role and `sync_state.rekey_in_progress` writers; sweep U1's flagged Sync/
  references. Own commit(s), headless green both configurations.
- **U3 (Opus implementer #2, Fable cold review): VX-423 — ONE REFRESH AUTHORITY.** The app's `AuthSession`
  (`App/Variorum/Shared/AuthSession.swift`) and the lobby's (`LobbyVaultRoad`/`FollowingSessionProvider`) stop
  refreshing the rotating refresh token independently — one shared session provider or a cross-instance
  single-flight + keychain re-read, per F-U1-1's trace (the VX-423 comment carries file:line). Evidence: a
  red-on-old pin on the two-refreshers race (revert-verified); the suites green; U2's throwaway rehearsal then runs
  with the fix in (switch day is wall-to-wall sign-ins — her sequencing reason).
- **R1 (Opus implementer #3, Fable cold review rides the phase ladder): THE RIDERS.** Pin-before-fix PER MEMBER;
  commits say `Part of VX-nnn`. Members: **VX-461** (the export door's 0-byte file — the save-panel grant not
  held around the ATTACH is the lead; a file-access fix, rule 26's instruction leans on it) · **VX-463** (conceal
  the words fields with a reveal eye — her ruling) · **VX-464** (the join refusal's referent — "that passphrase
  doesn't open this account."-class line, the move sheet too) · **VX-473** (the hold banner's `hasAccount` reads
  the library's bound account on the new road, not the Mac's sign-in) · **VX-469 (c)** (the Use Castle confirm
  says Previous Libraries' quiet roads stand — one line, her ruled wording direction) · **VX-468** (the what's-new
  card waits after a restore/adoption first open — her "wait") · **VX-462** (the set-up arm's words moment goes
  quiet — custody-adjacent; its `withKnownIssue` wrappers drop). **VX-470 is sized at R1's door:** ruled (c) —
  T-8 from an open Castle library lands in Castle with the current pair typed, PLUS an explicit "land it in
  Standard instead" secondary choice with its consequence named, carried to T-5 the same way (supersedes
  P-VX309-U1b-2's Standard landing). If it doesn't fit R1 cleanly it LEADS THE NEXT RUN (her word).
- **VX-465 (the orchestrator): THE DEVICE-ID DRIFT TRACE** — owed before the switch; runs between batches
  (read-only trace first; a fix only with a traced mechanism + red-on-old pin, else the ticket carries the trace).
- **THE LADDER:** one ladder over the whole phase diff; FRESH `fable-reviewer` per round, REVIEW_PROMPT verbatim,
  zero framing; cross-model flow (findings → implementer agree/dispute → reviewer's final call → implementer
  applies; FINDER-FIXES and Sync/ lines the reviewer's own).
- **U2 (the orchestrator): SWITCH DAY, REHEARSED (tonight's half)** — the step-by-step switch-day script for her
  (§2's answer inside it); the §2 proof + the full script walked on the throwaway project (two test accounts, two
  devices' worth of libraries); the `pg_temp` artifact authored, REHEARSED on the throwaway, and added to the
  marker-14 deploy set (production at her morning go — VX-213's held half); the vx307 deploy checklist amended to
  her 2026-10-22 choreography (BOTH MACS in one window, the phone follows VM-8 — its marker-13 install visibly
  refuses until then, accepted by her word); `notes/stargazing-castle-rebuild-delta-brief.md` REWRITTEN to the
  rules (F-U2-4) and checked against the built Release product, staged for her to hand to the site agent;
  VX-379's truth-check of the guide and panes against the Release build; the 0.10 release notes DRAFTED for her;
  the real-store byte-copy rehearsal STAGED (the copy placed if container access allows, else her exact commands)
  with A1 discipline and the zero-instance gate. **PAUSE THERE — her morning: the byte-copy rehearsal, the
  production deploy (marker-14 set incl. `pg_temp`), both Macs' installs, the release at her word.**

### §2's proof, the planned shape (detail worked at U2, repo-first)

Rule 15 across the switch = a fresh new-road library joining an account whose vault was BORN today's-road-shaped
and crossed via artifact 17's backfill reads every row sealed under the pre-switch corpus key. The §5R rehearsal
proved the backfill's field arms on planted rows; U2 proves the client end-to-end on the throwaway: a
post-backfill-shaped vault under known secrets (the §5R planting recipe, `~/.variorum/dev-vault-throwaway.env`),
rows sealed under its corpus key, then join + full pull from a fresh library — everything decrypts, the words/
passphrase typed at the join are the account's. The sealing seam (AES-GCM, AAD, `e1:`) is byte-unchanged across
the switch, so key continuity is the whole question and the vault shape is the whole risk.

### OPEN DESIGN NOTE (resolve at U2; an author item if it bends the plan's sentence)

With the legacy readers gone entirely (the ticket's "nothing is kept read-only"), a pre-design store — hers
included — is a store the new road cannot open: Look inside and the live slot must give rule 26's HONEST REFUSAL
naming the road (export from the old build / sign into sync / start fresh), never a crash and never a guess. The
plan's U2 sentence "Look inside, then Make this my library on a byte-copy of her real store" is therefore read as:
the byte-copy rehearsal proves the HONEST-REFUSAL face plus the switch-day script's real road (her writing returns
by sync; the old store kept whole as a copy, openable by the old build she keeps). If the built classifier can do
better than refuse (it cannot, without a reader), or if she wants a kept reader after all, that is HERS — bundled
for the morning sitting. U1 must leave the refusal face honest (the classifier must not claim "keyless" when an
old-format key file sits beside the store — name it as from an older Variorum where the shape allows).

### Environment traps (binding on every session of this phase)

Instance checks `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by STORE,
never quit/kill; no Release builds or /Applications refreshes while one lives — and NO /Applications refresh at all
until the marker-14 deploy lands (L0's consequence). `xcodebuild build-for-testing` compiles without the runner;
Mac tests from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N tests" line and read
`skipped:` before claiming a gated suite ran; zsh `pipestatus`; NEVER a custom build configuration (non-"Debug"
strips the DEBUG oracles). EVERY `xcodebuild test` run and anything touching the screen or a shared store holds a
`Tools/stage` claim (no coordinator tonight — this session claims directly, renew-per-row on long walks). Headless
`swift build`/`swift test` is stage-free. Backups WAL-safe, UTC names, into `Backups/safety-copies/` (A1). The dev
Castle pair is `~/.variorum/dev-castle.env`, the throwaway's users `~/.variorum/dev-vault-throwaway.env` — values
never echoed, never committed; every throwaway apply carries the in-command ref guard (the §5R discipline). The
walk's Debug build lives at `App/Variorum/DerivedData/vx329` (the vx-309 stale-build slip's lesson: never launch
the standard-path build). Implementers: no subagents, no stage, no Debug launches, no dev-store touch; headless +
`build-for-testing` only; checkpoint commits per piece, push each, LIVE STATUS flips in the same commit, PENDING
on every unverified claim; foreground waits only (poll, don't `tail -f`).

## 6a. U1 BRIEF — THE SWITCH (an Opus implementer; ticket VX-329's trunk + VX-233 + VX-406/VX-380)

**Read first, in full:** CLAUDE.md + its canon; `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` WHOLE
(rules 24, 26 and "What we do not promise" are this unit's heart); `notes/SurfaceContracts.md` "Doors to the
outside" (Library protection + portability) and "The app"; this plan WHOLE (§1–§6 — §6's CUT carries your fence and
your deletion list); `notes/plans/vx-266-castle-backups-prelaunch.md` §3.15 (the deletion list's birth — superseded
where §6 says "nothing is kept read-only"); `App/Variorum/Shared/Protection/ProtectionRoad.swift` (the switch);
`App/Variorum/Shared/AppBootstrap.swift` (the road fork at :217 and every `newRoad` arm);
`App/Variorum/Variorum/Registry/CapabilityRegistry.swift` around `.lockLibraryNow` (P-VX309-U1c-4's comment).
Work from `~/dev/variorum-vx-329`; commits say `Part of VX-329` (the drill deletion `Part of VX-233`; the suite
resolutions name VX-406/VX-380 where theirs).

**The goal.** One compile-time change in one place turns the new road on for EVERY build: `ProtectionRoad.live`
returns true unconditionally (keep the pure function + its pin, flipped); `opensOnTheNewRoad`'s dev-store fence
dissolves — every store, every variant, both configurations. Then delete today's whole deciding and writing road in
the same change, per §6's U1 list — nothing kept read-only, no `#if` shrouds, no commented-out code. Today's road
must be GONE as code, not dormant.

**The fence (absolute):** you never edit anything under `Sources/VariorumCore/Sync/`. Where a Sync/ file references
a symbol you deleted, STOP on that file, flag it in your record (file:line, the symbol), and leave it — the
orchestrator carves Sync/ in its own commit (L1). If that fence makes your tree uncompilable mid-unit, flag it and
coordinate with the orchestrator rather than working around it.

**Pieces (suggested order; checkpoint commit + push per piece):**
0. The flip: `ProtectionRoad` (live → true; `opensOnTheNewRoad` loses the fence or states it vacuously true —
   prefer deleting the devStore parameter and its callers' discrimination), plus the bootstrap's `!newRoad` arms.
   Compile-first discipline: get the app building on the new road everywhere before deleting files wholesale.
1. The Shared/ deletions (PostureSwitch, PostureSwitchModel, PostureFollowModel, PostureCopy, EncryptionSession,
   AppleRelinkModel, WordsCeremony, the legacy arms of ProtectionController/AppServices/AppBootstrap/VariorumApp,
   the panes' today's-road rows — SettingsShape/AppSettingsView/ProtectionPane/DataSafetyPane legacy arms, the
   mobile sheets' legacy arms).
2. The Persistence/ deletions (StoreKeyEnvelope, RawKeyCustody, CustodyCollisionRule, Posture.derive, the legacy
   arms of StoreIdentity/AppDatabase/LibraryAdoption/StoreBackup — today's flat backup leg dies where it is
   today's road's writer; the new road's pair road is THE backup writer).
3. The old suites: delete `PostureSwitchDrillTests.swift` (VX-233, Canceled — say so in the commit), the VX-406
   list (`CorpusRotationTests`, `StoreKeyEnvelopeTests`/`Format2Tests`, StringsWorkbook's `StoreUnlockTests`),
   and every test of deleted code; VX-380's red attacker test is FIXED if its subject survives, deleted with its
   subject if not — never skipped. Tests of the new road are NEVER deleted or weakened.
4. ⌃⌘L: the `.lockLibraryNow` capability gains `shortcutLabel` ⌃⌘L + the Shortcuts helper row
   (P-VX309-U1c-4 (b)); the registry-walk pin covers it.
5. The honest-refusal check (the §6 OPEN DESIGN NOTE): with the readers gone, point the classifier suites at a
   pre-design-shaped store/key-file fixture and PIN what it says — the refusal must be honest (never "keyless"
   where an old-format key file exists, if the shape allows naming it; never a crash). If the built shape cannot
   name it better than the generic refusal, record that honestly for the orchestrator's morning bundle — do not
   invent a new face without a ruling.
6. The sweep table: `rg` every deleted symbol name + §6's list — instance × file, each cell DELETED or provably
   new-road/comment-only; the table lands in your record.

**Hard limits:** headless `swift build`/`swift test` (BOTH configurations — `-c release` is this unit's acceptance)
+ `xcodebuild build-for-testing` ONLY; no stage, no Debug launch, no dev-store touch, no network, no subagents;
today's road's behavior is not "improved" on its way out — it is deleted; every new-road behavior change beyond §6's
list is out of scope (flag, don't build); no shouting caps, sentence case. The lockstep marker is ALREADY 14 when
you start (L0) — do not touch `SyncSchema` or anything in Sync/. `Tools/canon-size` is not yours. If a deletion
exposes a genuine product-behavior hole (a face only today's road provided), STOP on it and flag — the orchestrator
rules or bundles for her.

**Evidence closing the unit:** the sweep table complete; `swift test` AND `swift test -c release` green (counts in
the record; the release floor honest — VX-406's reds GONE with their suites); `xcodebuild build-for-testing` green
for the Mac app; the iOS app target builds; the record (§5, the VX-309 §6 form) with counts, the Mac-suite list for
the orchestrator's stage batch, PROVISIONALs bundled, findings routed, LIVE STATUS flipped per piece.

### L0 RECORD — THE LOCKSTEP COMMIT (the orchestrator, Fable, 2026-10-22; commit `0d1820336` — DONE)

`SyncSchema.lockstepVersion` 13 → 14 and `17_phase_vx307_vault.sql` registered in `AuthRLSDDLTests.lockstepFiles`,
ONE commit (the vx307 checklist's preflight pairing row now reads true on this branch). The chain's resolution moved
with it: the deployed `key_vault_update` is now 17's mode-shaped body, so the rotation-era DDL pins were made
marker-aware (the R-2 class) — `theVaultUpdateDoorLocksForUpdateCASesAndRecordsTheRotationSeq` and
`theCompletionGuardLivesInTheCanonicalTwelveBody` read the last PRE-17 definition from `13_phase13i_wings.sql`'s own
file (13i-a re-carried 12's fold-in with the wing/shelf ciphertext registry — found when the 12-file read failed the
registry-exactness arm), the clearing-guard overlay test asserts the guard's history (11 never · 12/13 carried ·
17 retires), `everyMintSite…` reads M3 in 12's text and asserts the deployed door mints nothing, and ONE NEW pin
(`theMarker14VaultDoorRetiresRotationAndLandsTheModeShape`) holds the deployed truth: 17's body byte-equal as the
chain's final resolution, the FOR UPDATE/proof/CAS clauses kept, `VARIORUM_PRE_VX307_PAYLOAD` live, rotation absent
whole. The five "a local-only migration never moves the marker" pins read 14. **Red-on-old:** the drift pin verified
red with the constant reverted to 13 (the pairing is enforced), restored green. **Suites:** the four affected suites
106/106; the FULL core suite green — 3368 tests, 2 known issues (standing `withKnownIssue` wrappers), one UNRELATED
load flake (`MCPHarnessTimeLimitTests` — a 15-second wall-clock bound read 18.6 s under the parallel full-suite run;
green in isolation at 2.2 s; no product line near it). **Consequence standing:** this branch speaks marker 14 — live
sync only against the throwaway until the production deploy at her morning go; NO `/Applications` refresh until then.

### VX-465 RECORD — THE DEVICE-ID DRIFT TRACED (the orchestrator, Fable, 2026-10-22; read-only, no fix — a design
consequence, her call bundled for the morning)

**The mechanism, code-traced:** the device ID lives ONLY in the per-library memory item (rule 21's four facts —
`DeviceMemory.deviceID`), and the app deliberately remembers ONE library: every act that lands or creates a library
ends with the forget loop (`DeviceActs.createLibrary` :144, `Copies` make-mine :218, `PlanRunner` :578,
`ExecutorRepairs` :170 — "Rule 21: this Mac remembers ONE library"). With the memory item gone, the next open of the
forgotten library cannot recognise which record section is this Mac's (rule 23 — no hardware fingerprinting;
`DeviceFacts.thisMacsSection`'s own comment: "never a section guessed from the record") so it MINTS a fresh device
ID and writes fresh memory — stable from then on. **The dev drift, fully accounted:** VX-308's walk ran the dev
library A first (the c31a4daf-era pairs, 10-19 ~11:00), THEN created throwaways B, C and D in the same slot domain —
each creation deleted A's memory item; VX-309's walk row 1 was A's next open: fresh era `a39ae6d7`, the honest zero
count, consistent pairs thereafter. No identity door on the DEV library was pressed; a CREATION door on other
libraries was — the designed trigger. The ticket's suspect (a test-host open minting a device row) is superseded.
**Release consequence, bounded:** in ordinary single-library life the ID never drifts. It re-mints only when another
library is created or adopted on the Mac and the earlier one later returns to the live place (the hand-restore of
rule 21; slot swapping is a walk pattern). Then the earlier eras' pairs LIST under the library but never COUNT as
this Mac's, and retention never prunes them — conservative both ways (nothing deleted wrongly), honest by its rule,
surprising to read. Switch day is untouched (her old stores retire; a fresh library mints fresh identity by design).
**Her options (the morning bundle):** (a) accept as designed — the ticket closes traced-by-design, with one wording
row if the counts' per-era meaning should say itself; (b) remember more than one library (bends rule 21's one-library
line; each memory item holds a sealed key-file copy, so N memories = N standing sealed copies — adjacent to her
VX-469 (c) stance that kept Previous Libraries' roads standing); (c) does not exist by design (ID continuity without
fingerprinting). No code changed; the pin question is moot until she rules.

### THE PG_TEMP REHEARSAL RECORD (the orchestrator, Fable, 2026-10-22 — VX-213's held half, her go at the sitting;
network-only, no stage; the ref guard in every apply)

The artifact `Server/supabase/maintenance/vx213-pg-temp-search-path.sql` authored to the strict shape: one
`alter function … set search_path` per EXACT deployed signature (never a pg_proc loop — the 13y blanket lesson),
each list preserved with `pg_temp` appended LAST; the marker-14 guard (`VARIORUM_PGTEMP_NEEDS_14` — 17 redefines
`key_vault_update` with a bare `public` list, so this artifact rides AFTER it); a fail-loud verify DO (zero definer
functions in public without a trailing pg_temp) and a read-only config tail. **The rehearsal on the throwaway:**
run 1 REFUSED in the verify — `rls_auto_enable()` (the project's RLS auto-enable event trigger, postgres-owned,
`search_path=pg_catalog`, already in the grant sweep's expectation table) was not in my list; the artifact amended
IN REPO (its own list preserved: `pg_catalog, pg_temp`) — the read-fix-re-run road working as designed, the same
class every live window has caught. Run 2 landed WHOLE: the tail read all **19** functions with trailing pg_temp
(the 14 definer RPCs incl. `sync_challenge`'s `public, extensions, pg_temp`, the four definer-path helpers,
`rls_auto_enable`). **The grant sweep after: 62 OK · 4 INFO · 0 fail — byte-identical to the marker-14 expectation**
(R-2's corrected shape). PRODUCTION application rides the marker-14 deploy set in the release window, AFTER 17, at
her explicit go — the checklist's run section carries it. No secrets echoed; every apply ref-guarded to
`<supabase-project-ref>`.
