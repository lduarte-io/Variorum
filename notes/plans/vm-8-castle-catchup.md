# VM-8 — the phone's Castle catch-up (the run record)

**STATUS: OPEN — kicked off 2026-10-25 overnight (her word: full orchestrator slot, overnight protocol, provisional
judgments, pause only where her hands are truly needed). Unit 1 in flight.**

**The one sentence:** the Macs run 0.10.2 against marker 14; her phone runs a pre-0.10 build that refuses marker 14 by
design and has no new-road account faces — this run gets her phone pulling her library whole under her account's Castle
mode (Face ID gate), then gives the phone the protection faces it owes.

**Machinery:** ticket VM-8 (flagship, team VM) · branch `vm-8-protection-recovery-faces` · worktree
`~/dev/variorum-vm-8` (the Pro) · PR `VM-8: …` (merge commit) · **this run HOLDS THE CUSTODY SLOT** (VX-500 and VX-212
wait for the merge). The kickoff is `notes/handoffs/vm-8-kickoff.md` (supersedes `vx-494-handoff.md` Appendix B).
Cast: Fable orchestrates (live Castle walks are handed to Opus agents — the `fable-safeguards` rule); a fresh
`opus-implementer` per unit; a fresh **Opus** cold reviewer per ladder round (her kickoff word). Zero
`Sources/VariorumCore/Sync/` lines expected — any line that must land there is Fable's.

---

## THE BINDING PRINCIPLES (the 13b constitution, copied per the architect skill; P-1…P-9 verbatim)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book),
  per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces
  render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability
  matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done
  visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't
  rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement
  brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity
  machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does
  this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never
  re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes
  are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode
  changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness
  depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The
  response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on
  paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo.
  Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos
  owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path.
  It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a
  tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the
  board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough.
  Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the
  substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering
  attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is
  THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing
  splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate,
  applied where it was being waived.

Mobile-specific law on top: `notes/MobileSoul.md` whole (P1–P3 verbatim on the phone; memory is an invariant; the
decision grammar §4; brains shared, faces platform-owned). The protection contract is `notes/CastleRules.md` (27
rules) — **the Castle design is FROZEN (her 2026-10-24 word): nothing stored changes shape; fixes live in acts, doors
and words.** No new product words invented: shared ruled copy wherever it exists; an unavoidable new sentence lands
PROVISIONAL in her bundle.

## THE CHARTER, VERIFIED IN CODE (2026-10-25, the orchestrator's own reads)

- **F-U4-2 confirmed:** `AssessRules.preDesignStore` fires on the phone and `ProtectionLobbyModel` carries
  `offersStartFresh`/`startFresh()` (shared), but `MobileRoadLockView` (`VariorumMobile/Features/Protection/
  MobileRoadFaces.swift`) reads no `face.preDesignStore` — the phone renders the standing lobby fields over a
  pre-design store. Her phone's library predates the design, so this face is likely its first screen on the new build.
  **Verify which arm her phone actually meets at the device moment — never assume.**
- **The phone CAN sign in today:** the shared `SyncStatusRow` (`Shared/SyncStatusViews.swift`) renders "Sign in…" on
  the phone and presents the shared `AccountView` (`Shared/AuthViews.swift`) as a sheet. What the phone LACKS is the
  ACCOUNT SECTION's doors: Turn on sync / the JOIN ("Sync this library…"), the words moment, the first-round sheet
  (P-VX510-1's stays-to-confirm shape), the leaves, the follow — all pure shared values (`RoadAccountFaces.swift`,
  `RoadAccountModel.swift`) with no phone renderer. The Mac renders them in Settings ▸ Protection's Sync section
  (`ProtectionPane.swift`, Mac-only).
- **`AppBootstrap.attach(services:)` (the first-round seam, VX-510) is shared and UNCALLED by the phone's composition**
  (`VariorumMobileApp.swift` — no `attach` call; `roadAccount` has no phone host). Wiring it is part of landing the
  account section.
- **VX-501's typed-unlock sync-key load is in shared `ProtectionOpenRoad`** (`loadSyncKeysAfterTypedUnlock`) — the
  phone's typed unlock should load the account's sync keys. VERIFY with a phone-posture pin, don't re-trace.
- **The sync row's not-yet line is already live on the phone** (VX-506; `VariorumMobileApp` injects
  `librarySyncsWithAnAccount`); the row's `.openProtection` door is nil on the phone (no Protection pane injected —
  P-2) so the keysLocked state says the sentence alone. Unit 1 gives the door a phone home.
- **The catch-up substrate is inherited whole** (VX-494: 2,000-row pull windows, the staged resumable download in
  `sync_pull_stage` v1_32, a retired round stops its download never its save; VX-487's sync-keys fix; VX-503's
  vault-first `material(for:)`; VX-517's by-name forgets). The phone's ~108k-row first catch-up is the acceptance
  ground; the save is one all-or-nothing transaction (~4 min 20 s on the Pro) — **VX-497 is deferred to this run at her
  word: measure the phone's save and report; the number decides VX-497's shape and its Pre-launch call.**
- **The pair catch-up (VX-529) is shared core** (`AssessRules.pairFollow`, `VaultRoad.answer`, the E6 heal). The SHARED
  lobby road carries the E6 passphrase field and the vault road — the phone's lobby may already behave; **a device walk
  decides live vs latent** (PL-59's VERIFY line).
- **Known, NOT this run's:** VX-544 (offline typed unlock leaves sync locked for the session — rides VX-500; a phone
  that unlocks offline will meet it: record, don't fix); VX-542 (the follow-owed pane repeats its pair sentence per
  locked door — if the phone's pane builds from the same copy, don't copy the repetition; note it on VX-542).

## THE UNITS (the scope split — HER RATIFY at the sitting; unit 1 pre-authorized by her kickoff's own words)

**UNIT 1 — the phone syncs again (the critical path; ends at the device install).** One acceptance unit: the shortest
road to her phone pulling her library whole under her account's Castle mode.
1. **The pre-design face on the phone lobby:** `MobileRoadLockView` gains the `preDesignStore` arm — her lead and body
   (`ProtectionWords.preDesignLead`/`preDesignBody`, device-neutral already), *Start fresh…* with her confirm line over
   the shared act (set-aside whole, crash-safe, no byte of the old store read). NO Open Library door on the phone (the
   phone has no picker road — the standing lobby precedent, PROVISIONAL P-VM8-1). The automatic biometry ask already
   stands down on the fact (F-U4-3, shared).
2. **The phone's Protection screen, minimal unit-1 form (PROVISIONAL P-VM8-2):** Settings gains a Protection row
   opening the phone's screen; unit 1 it carries ONLY the Sync/account section read from `assess`'s situations over
   the shared `RoadAccountModel`/`RoadAccountFaces`: sign in/out (the shared `AccountView` sheet), Turn on sync both
   arms — the JOIN is the expected one ("Sync this library…", ONE of the account's secrets typed, the words moment
   quiet-or-shown per VX-456/VX-462, the Face ID gate choice at the press / Always ask), the first-round sheet that
   STAYS to confirm (P-VX510-1's shape — "Synced. …" or the row's own sentence; Done always open, never cancelling),
   the three local leaves, the follow door IF `assess` offers it (the faces are shared values — render, don't invent).
   `attach(services:)` wired from the phone's composition; the sync row's `.openProtection` door injected on the phone
   (P-2 satisfied: the pane now exists). Crossings and key doors are NOT unit 1's (the screen says nothing where no
   door can act — P-2, never a disabled stub).
3. **The typed-unlock key-load verification** (VX-501 on the phone's posture) — a pin if none covers it; no re-trace.
4. **The catch-up at scale + the resume:** the staged download resumed across an iOS app switch (suspend) — the
   acceptance case; the save measured and reported (VX-497's number). Grounds: the walk-lift/throwaway road's ~110k-row
   corpus if it still stands (VX-494's test user A), else the prod test road (`vxtest` accounts; R-510-1/-6's rules —
   secrets via `~/.variorum/bin` helpers, never typed into commits or records) at the scale it holds, with the scale
   case re-proven on her real corpus at the device moment.
5. **Evidence:** the phone suites green (device-id-pinned destination — two "iPhone 17" simulators exist across iOS
   26.2/27.0; a name-only destination exits 70), a simulator walk of the whole road (pre-design face → Start fresh →
   words card → sign in → join with Face ID gate → first round → catch-up → resume → the library whole), THEN the
   device install (the devicectl road) and her sign-in — **HER HANDS: held for her morning.**

**UNIT 2 — the Protection screen's remaining faces (sized at her sitting; the kickoff charters it):** Use Castle / Use
Standard with the Face ID gate choice and the gate-style row; the key doors (change passphrase, reset forgotten
passphrase, new words, replace all keys) with their changed-elsewhere refusal faces (PL-59); the phone's passphrase
setter (12-character floor, the quiet strength hint — VX-211's parity); the follow, all three kinds (posture, key
replacement, VX-529's pair — the pair sheet lands with the account section), the durable notices' phone rendering, the
check door (PL-58/59).

**UNIT 3 — the cards and the guide (sized at her sitting):** the words card's phone band (VM-23 — the amended rules
2/3/7: retire the creation card into the band); VX-538's recurring E6 card on the phone's card home (R-529-6: the why
and the road, recurring until a passphrase lock lands, no don't-show-again); the pocket guide's new-road protection
chapter (the Mac's three lessons) and the compromise-recovery page (the Mac's is VX-379's; the pocket guide is its
own).

**Sizing note (PhaseSizingGuidance):** units 1 and 2 are both phase-sized — the guidance's cap under one theme. Unit 3
is small but distinct. The split proposal FOR HER: VM-8 carries units 1–2; unit 3 either rides as a tail (small) or
splits to a follow-up VM run — her call. Overnight: unit 1 builds now (her kickoff's own critical path); unit 2
proceeds PROVISIONALLY if the night allows, reviewable whole at the ladder.

## THE OLD VM-8 SCOPE (the 2026-10-06 Phase 6 — reconciled against CastleRules, the kickoff's demand)

| item | reconciliation (verify in code before ticketing) | disposition |
|---|---|---|
| "How Protection Works" explainer over `ProtectionShapes` | VERIFIED 2026-10-25: `ProtectionShapes` exists nowhere in the tree (left with today's road); the rebuild's honest equivalent is the pocket guide's protection chapter (unit 3) | folds into unit 3; no separate explainer |
| the live-checklist lead + unchosen-state indicator | today's-road faces (deleted at VX-329 U1) | retired by the rebuild — record, no ticket |
| T1 count-and-dates verify (PL-18) | pre-rebuild backup-verify design; the phone keeps no backups (rule: store re-derivable from the mirror) | retired — record, no ticket |
| the sample-library restore door (PL-17) | still owed (the Jekyll sweep exemption retires when it builds); off the critical path | own VM ticket, offered to her |
| the PL-13 residue (sync-status partly shipped; plaintext export awaits a document-picker road) | sync-status ships with unit 1's section; the export road is its own design | own VM ticket (export), offered |
| note-level multi-select | App shell, not protection | own VM ticket, offered |
| the Apple re-link door (#139(f)) | VERIFIED 2026-10-25: no re-link exists anywhere on the new road (the 17m door left with today's road); CastleRules' considered-and-not-pursued ledger retired re-link as rule 8's lobby normal path | RETIRED by the rebuild — record, no ticket |

## HER SITTING BUNDLE (grows as the run goes; nothing here is built without her)

1. **The scope split above** — ratify units 2/3's shape (and whether unit 3 splits out).
2. **F-PH-1 (wording, HERS):** the core model sentences the phone renders that name the Mac — rule 21's notice
   (`LibraryNotice.differentLibraryWords`, her CastleRules sentence verbatim) and the key-file offer
   (`KeyFileOffer.keychainHoldsOne`). Her phone wording or her "leave them".
3. **F-PH-2 (wording, HERS):** her rule-12 leave sentence's phone wording — the sweep exemption (`herRuleTwelve` in
   `MobileNoRedirectSweepTests`) retires when a phone leave face lands (unit 2's crossing/follow-out).
4. **The riders, her call each:** VM-15 (Pre-launch — a sibling phone that hasn't followed into Castle, and its iCloud
   device backup, stays Apple-openable; the same surface) · VM-16 (the phone's undo door mis-speaks a quiet press —
   App shell; only if the run has room).
5. **The old-scope tickets** (table above) — offered, never silently dropped.
6. **The device moment (HER HANDS):** which lobby arm her phone actually meets; whether the phone's OLD library holds
   unsynced writing (anything written on the phone since 2026-10-22 lives only there — the set-aside keeps it whole in
   Previous Libraries, recoverable, but say it before Start fresh); the devicectl install; her sign-in and join; the
   measured save on her corpus → VX-497's shape and Pre-launch call.
7. **PROVISIONALS built overnight** — every P-VM8-N below, reviewable at her pass.

## PROVISIONALS (the running list)

- **P-VM8-1** — the phone's pre-design face renders Start fresh… only (no Open Library door: the phone has no picker
  road; the standing lobby's own precedent).
- **P-VM8-2** — the phone's Protection screen is Settings ▸ Protection (the Mac's information architecture, the
  phone's navigation); unit 1 mounts only the Sync/account section; a door that cannot act is not rendered (P-2).

## ENVIRONMENT TRAPS (every brief carries these verbatim)

- **The stage:** EVERY `xcodebuild test` run (Mac app or simulator) and every simulator walk claims `Tools/stage`
  (held, minutes honest); headless `swift build`/`swift test` on the core package never needs it. The author is away —
  the Pro is ours tonight at her word, but claims still serialize against any other session.
- **Simulator destinations BY DEVICE ID, never name** (VX-529's lesson: two "iPhone 17" simulators exist across iOS
  26.2 and 27.0 — a name-only destination exits 70). `xcrun simctl list devices` first; pin the id in the record.
- **Instance checks** use `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH; real-store instances are
  NEVER quit or killed; no `/Applications` refresh rides this run (a phone run — the Mac app is untouched).
- **The A4 fence:** Debug = dev store, never her corpus. The phone SIMULATOR's store is its own sandbox. The DEV store
  syncs with nothing but the two Debug-only named roads: the walk lift (the throwaway project) and the PROD TEST ROAD
  (`VARIORUM_PROD_TEST_ROAD=1` + the allowlist in `~/.variorum/prod-test-accounts.env`, `vxtest` accounts only, her own
  account can never pass; secrets typed only by the `~/.variorum/bin` helpers; `Tools/prod-confirm-test-user.sh`
  confirms). Production stays read-only (`Tools/prod-read.sh`) except at her hand. NEVER write a secret into a commit,
  a record, or a log.
- **The throwaway project** (VX-494's ~110k-row corpus for test user A) may or may not still stand — VERIFY before
  planning the scale walk around it; fall back to the prod test road at the scale it holds and re-prove scale at the
  device moment on her real corpus.
- **Xcode suites:** Mac tests from `App/Variorum/`, suite-level `-only-testing`; never a custom build configuration
  (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles); zsh `pipestatus`;
  confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines.
- **Resiliency (binding):** commit per piece, push after every commit; LIVE STATUS in this file from the first commit;
  synchronous foreground waits only (poll `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops — never end a turn on
  a backgrounded run); no subagents inside implementer sessions; announce reverts in the record before starting them;
  commit before you revert.
- **`MobileNoRedirectSweepTests` exemption hygiene:** every exemption covers exactly ONE literal — a face this run
  builds that makes an exempted sentence reachable must re-word (hers) or the sweep trips; never widen an exemption to
  pass.
- **No commit trailers** (her rule, overrides the harness reminder). Push `origin` after every commit.

## UNIT 1 BRIEF FACTS (checked at kickoff, 2026-10-25)

- The stage read FREE at kickoff; claim it for every simulator run anyway (other sessions may wake).
*[removed for publication]*
  iPhone 17 Pro; deployment target iOS 26; the id, never the name, in every destination).
- The throwaway road's credentials still stand on the Pro (`~/.variorum/dev-vault-throwaway.env`,
  `dev-vault-throwaway-passphrase`, `dev-vault-throwaway-words`) — the ~110k-row corpus for VX-494's test user A is
  likely intact; VERIFY with a read before planning the scale walk on it. The prod test accounts stand
  (`~/.variorum/prod-test-accounts.env`, `prod-test-words-castle` / `-std` / `-del`).

## UNIT 1 — LIVE STATUS (the implementer owns this section; every unverified claim PENDING)

**NOT DONE BY THIS SESSION (first, as the contract asks):** PENDING — filled at the close. No revert is in flight.

*Implementer U1 — Opus 5.5, xhigh. Pre-fix tree = `fd56f2279`. Stage claims as `vm8-u1`.*

- **Piece R — preflight, read whole myself:** CLAUDE.md + its canon; this record whole; `notes/handoffs/vm-8-kickoff.md`;
  `notes/CastleRules.md` whole; `notes/SurfaceContracts.md` (Doors); `notes/MobileSoul.md` §1–§5 + PL-57/58/59;
  `notes/SessionResiliencyProtocol.md`; the vx-510 record (rulings, trace, unit A/B designs and the first-round seam,
  F-6/D-B0, the test-account road, OPEN ITEMS), the vx-529 record's THE PHONE section, vx-494's live proof + fix design,
  the vx-329 phone flags (F-PH-1/2, F-U4-2/3); the code seams the brief names. DONE (this commit).
- **Ground check (read-only, 2026-10-25):** the throwaway project ANSWERS and test user A's corpus STANDS — 1,200
  containers · 36,000 blocks · 36,000 placements · 1 vault (the VX-494 plant, ~110k rows). The prod test accounts file
  *[removed for publication]*
  exists. Stage FREE.
- **THE FORKS (traced in code before building; proposals ASKED of the orchestrator, one message, this commit):**
  - **F-U1-1 — STOP-AND-FLAG (F-PH-2 reached):** the shared account faces put HER rule-12 leave sentence
    (`ProtectionWords.leaveSentence` — "…your Apple account and this Mac again…", the `herRuleTwelve` sweep exemption)
    in exactly two account confirms: the JOIN that LEAVES Castle (`joinSpec(.leavesCastle)` → `Words.ruleFive`) and the
    FOLLOW OUT of Castle (`followNow` with `.intoStandard` → `.ruleFive`). Rendering the section generically on the phone
    makes that exempted sentence reachable. Proposal **(A, recommended)**: unit 1's phone section does NOT render those
    two arms (nothing in their place — the phone had no road there before either); every other door renders from the
    shared faces; F-PH-2 moves to the top of her bundle (unit 2 builds both arms with her phone wording). (B) render her
    sentence as is and re-word the exemption's `why` — refused by the brief (never widen). (C) interpolate the device into
    her sentence — invents her words. Her critical path is the OTHER join arm (a fresh Standard library joining her Castle
    account — `.entersCastle`), which says no rule-12 sentence.
  - **F-U1-2 — four SHARED sentences are false or a redirect on the phone** (none names the Mac, so the sweep cannot see
    them), three on her critical path: (a) `gateTouchIDLine` "This iPhone keeps the new key behind your fingerprint." (the
    Face ID gate); (b) `exportAPlainCopyFirst` "…export one first from Settings ▸ Data Safety." (the join into Castle — the
    phone has no Data Safety and no plain-copy road at all, PL-13's residue); (c) `firstRoundCloseNote` "…the bar at the
    bottom of the window says when it's done." (the first-round sheet — the phone's sync row lives in Settings); (d)
    `deleteHerePointer` "…choose Account… in the sidebar's sync row…" (the third leave — the phone has no sidebar).
    Proposal **(B, recommended)**: phone variants behind `ProtectionRoad.isMac` (the shipped `rearmQuestion` precedent —
    the Mac byte-identical), drafted PROVISIONAL P-VM8-3…6: (a) "This iPhone keeps the new key behind Face ID." (b) not
    said on the phone (`RoadCrossingFaces.sentence` answers nil there — the `.sameEmailDifferentAccount` idiom; no road
    exists to point at) (c) "You can close this — sync keeps going, and Settings says when it's done." (d) "…choose
    Account… in Settings' sync row, then Delete Account." (A) render the Mac text and bundle each — a false sentence on
    her phone at the device moment.
  - **F-U1-3 — the reopen (composition, not product — built, not asked):** her join is RE-KEYING (Standard → Castle), so
    `reopenAround` tears the `.ready` tree down — the phone's Settings sheet and the screen hosting the confirm go with
    it, while the confirm (its words moment, its first round) lives on in the presenter (which then refuses every other
    sheet). The phone adopts `ProtectionController.settingsRequest` (VX-206's road — `reopenAround` already asks it) and
    re-presents Settings at Protection, which re-presents the presenter's sheet.
  - **F-U1-4 — typing secrets into the SIMULATOR:** both `~/.variorum/bin` helpers refuse unless the frontmost app is the
    MAC Debug build (by design). Proposal: one more local helper, `~/.variorum/bin/type-sim-secret <road> <field>` (mode
    700, never committed), the same shape and guards made simulator-true — the frontmost app is Simulator, the pinned
    device is the booted one, the phone Debug app's host process carries the road's launch env (the throwaway ref and no
    production ref; or `VARIORUM_PROD_TEST_ROAD=1` with no walk project, the account listed and `vxtest`-marked), values
    never printed. An environment act (her R-510-8 shape) — asked, not assumed.
- **THE ORCHESTRATOR'S RULINGS ON THE FORKS (2026-10-25, repo-first before the forked halves build):**
  - **F-U1-1 → (A), RULED.** Unit 1's phone section renders NEITHER rule-12 arm (the Castle-leaving join, the follow
    out of Castle) — nothing in their place, never a disabled stub (P-2's letter: the phone had no road there before).
    Every other door renders from the shared faces. The `herRuleTwelve` sweep exemption stays byte-untouched. **F-PH-2
    moves to the TOP of her sitting bundle**; unit 2 builds both arms to her phone wording. Her critical path
    (`.entersCastle`) is unaffected.
  - **F-U1-2 → (B), RULED.** Phone variants behind `ProtectionRoad.isMac` (the `rearmQuestion` precedent); the Mac's
    sentences and their pins stay BYTE-IDENTICAL. The four drafted sentences stand AS DRAFTED — PROVISIONAL
    P-VM8-3…P-VM8-6, her bundle — with one mechanic's precision: where an existing interpolation seam already carries
    the platform fact (`ProtectionCopy.deviceName`, the biometry word), ride it rather than hard-coding, words
    unchanged. (b)'s nil answer is accepted: the phone has no export road (PL-13), and a sentence naming a nonexistent
    road is the no-redirect doctrine's exact red flag; whether the phone gets its own advisory sentence is hers
    (bundled with P-VM8-4).
  - **F-U1-3 — accepted as built** (composition, the designed `settingsRequest` road). Note for the closeout's parity
    row: PL-47's "VX-206 — the phone never mounts a Protection pane; the asks are inert there by construction" line is
    SUPERSEDED by this build — the phone now mounts one and adopts the request road.
  - **F-U1-4 → APPROVED, with the constraints binding:** `~/.variorum/bin/type-sim-secret` in the R-510 helper shape —
    mode 700, never committed, values never printed, echoed or logged (read from the `~/.variorum` files directly);
    HARD guards exactly as proposed (Simulator frontmost; the booted device IS the pin
    *[removed for publication]*
    throwaway ref with no production ref, or `VARIORUM_PROD_TEST_ROAD=1` with no walk project and a listed,
    `vxtest`-marked account); the throwaway road reads only the throwaway files, the prod road only the allowlist (her
    own account can never pass — the standing fence); a `--check` dry-run that verifies every guard and types nothing;
    typing only under the held stage claim. The helper's path, guard list and deletion offer land in this record and
    in her handoff (hers to keep or delete at closeout, the vx-494 precedent).
- **Piece 1 — the pre-design face on the phone lobby:** CODE DONE (this commit; the pins COMPILED — phone
  `build-for-testing` EXIT 0; their RUN and red-on-old PENDING the stage). `MobileRoadLockView` (`VariorumMobile/
  Features/Protection/MobileRoadFaces.swift`): on `face.preDesignStore` HER face only — the lock glyph, her lead as the
  heading (no lobby title — P-VX329-U4-1), her body, *Start fresh…* (only where `offersStartFresh` — P-2) opening an
  `.alert` with her confirm line, *Start fresh* / *Cancel*, the shared act on the yes; the busy line the dots alone; NO
  *Open Library…* (PROVISIONAL P-VM8-1). Every other slot renders the standing lobby exactly as before (moved whole into
  `standingLobby`), plus — the same surface, shared ruled copy, no new words — the E6 line beneath the lead
  (`face.accountPassphraseLine`, P-VX529-U2-1; the Mac's `RoadLockView` said it, the phone rendered the field without its
  why). Pins: `MobilePreDesignFaceTests` (hosted — `MobileSurfaceDriver`): her words + Start fresh alone; the confirm
  first, the act on the yes; a guard for the standing lobby.
- **Piece 2 — the phone's Protection screen (the account section), `attach(services:)`, the row's door:** CODE DONE
  (this commit; COMPILED, runs PENDING). NEW `VariorumMobile/Features/Protection/MobileProtectionScreen.swift`: the screen
  (pushed `MobileRoute.protection` on the shelf's stack — the settings-sheet grammar), the account section over the
  bootstrap's `RoadAccountModel` (situation, the follow's durable Done, the follow door where offered, every account door
  as `assess` says it, *Sign in…* / *Sign out…*), F-U1-1 (A) — `RoadAccountDoorOpen.saysRuleTwelve` (shared, pure:
  `spec.words.contains(.ruleFive)`) arms render nothing; the presenter's phone host (`.settings`): the account confirm
  (exactly the door's fields through `PeekableSecretField`, the Face ID / Always ask gate rows, rule 7's words moment —
  `MobileWordsLookPanel`, NO Copy door (the phone has no words clipboard road — P-2), the first-round phase with Done),
  the sign-out confirm, the Account sheet (the phone's page style). F-U1-2 (B) in SHARED words behind
  `ProtectionRoad.isMac`, the Mac byte-identical: `gateTouchIDLine` (P-VM8-3, riding `biometryName`),
  `RoadCrossingFaces.sentence(.exportAPlainCopyFirst)` → nil on the phone (P-VM8-4), `firstRoundCloseNote` (P-VM8-5),
  `deleteHerePointer` (P-VM8-6). `MobileSettingsView`: the *Protection…* row (the sync row's own door name, P-VX486-1)
  and the sync row's `.openProtection` door injected (`protectionPaneDoor`) — both only where the screen can act (the
  shell's road AND an account section). `MobileShellView`: the route, `openProtection()`, and F-U1-3's adoption
  (`adoptsProtectionRequest` — once per ask; on appear and on change; pushes the screen). `VariorumMobileApp`:
  `bootstrap.attach(services: fresh)` BEFORE `start()` (replacing the inline deletion hook). `WordsFieldsConcealTests`
  (Mac target) gains the phone confirm's three words-field sites. Pins: `MobileProtectionAccountSectionTests` (hosted:
  the join arm's door and confirm in the phone's words; the rule-12 arms render nothing; the first round stays with the
  phone's close note then its outcome, Done once; the words moment with no Copy) and `MobileProtectionCompositionTests`
  (attach before start; the ask adopted once; the shell's adoption and push; Settings' gating).
- **Pieces 1+2 — GREEN on the pinned simulator** (stage claim `vm8-u1`; `-only-testing` the three new suites):
  `✔ Test run with 10 tests in 3 suites passed after 14.239 seconds` (0 skipped).
- **THE BEHAVIORAL REVERTS, named BEFORE any runs** (the committed tree is the copy: each file restored by `git checkout
  -- <file>`, `git diff --exit-code` clean after each batch; two batches, each revert's red disjoint from its batch's
  others). Expected red in brackets:
  - batch A — **RV-1** `MobileRoadFaces.swift` ← `fd56f2279` (the pre-fix face) [`herFaceSaysHerWordsAndOffersStartFreshAlone`,
    `startFreshAsksHerConfirmThenActsOnTheYes`; the guard green] · **RV-2** `MobileProtectionScreen.swift`: the
    `saysRuleTwelve` arm removed [`theRuleTwelveArmsRenderNothing`] · **RV-3a** `ProtectionWords.swift` ← `fd56f2279`
    [`theJoinArmsDoorAndConfirmSpeakThePhonesWords` (the fingerprint line), `theFirstRoundSheetStays…` (the window bar)] ·
    **RV-4** `VariorumMobileApp.swift` ← `fd56f2279` [`thePhonesRootAttachesItsServicesBeforeStart`].
  - batch B — **RV-3b** `RoadCrossingFaces.swift` ← `fd56f2279` [`theJoinArmsDoorAndConfirmSpeakThePhonesWords` (Data
    Safety)] · **RV-5** `MobileShellView.swift`: `adoptsProtectionRequest` stops marking the ask adopted
    [`theReopensAskIsAdoptedOnceAndPushesTheScreen`].
  - GUARDS (green on both sides by design): `everyOtherSlotKeepsTheStandingLobby`, `theWordsMomentShowsTheTypedWords…`
    (P-2's no-Copy — a new face, no pre-fix twin), `settingsOpensTheScreenOnlyWhereItCanAct` (source).
  RESULTS: PENDING. **Reverts NOT yet started** (this commit announces them).
- **Piece 3 — VX-501 on the phone's posture:** NOT-STARTED.
- **Piece 4 — the simulator walk + the measured save:** NOT-STARTED.
- **Piece 5 — evidence (pins red-on-old, the phone suites):** NOT-STARTED.

## THE LEDGER (numbered; every row owned; updated repo-first)

| # | item | owner | status |
|---|---|---|---|
| 1 | Unit 1 — the phone syncs again (pieces 1–5 above) | implementer U1 | IN FLIGHT |
| 2 | Unit 2 — crossings, key doors, follows, check door | after unit 1 | NOT STARTED |
| 3 | Unit 3 — the cards + the pocket guide | at her split call | NOT STARTED |
| 4 | Old-scope reconciliation tickets | orchestrator | table drafted; tickets at the sitting |
| 5 | Her sitting bundle | orchestrator | OPEN — grows |
| 6 | The ladder (fresh Opus reviewer per round, REVIEW_PROMPT verbatim, whole-run diff) | after the build | NOT STARTED |
| 7 | The device install + her live round + the measured save (VX-497) | HER MORNING | HELD |
| 8 | Closeout (canon two-file shape; PL ledger row; master plan; handoff; tickets triaged) | orchestrator | NOT STARTED |

## LIVE STATUS

- 2026-10-25 (orchestrator): kickoff complete — preflight read whole (kickoff file, VM-8 ticket + comments, MobileSoul
  PL-47…59, CastleRules whole, SurfaceContracts Doors, SyncSpec whole, sizing guidance, resiliency protocol, the
  VX-529 record's THE PHONE section, the vx-329 phone flags F-U4-2/F-U4-3/F-PH-1/F-PH-2, the sweep exemption list);
  charter verified in code (the section above); worktree + branch + in-flight row + Linear In Progress done. Unit 1
  implementer spawning next.
