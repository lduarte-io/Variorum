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
8. **Unit 1's taste flags (implementer U1; seen on the simulator walk, built as the brief says, none invented):**
   (a) P-VM8-7 — the sync row's own *protection…* door (VX-486's, injected per the brief) and the standing *protection…*
   row sit one above the other while sync reads locked / not-yet (B15); (b) the Terminal voice lowercases every phone
   chrome label, so the shared door names read "delete the account from this iphone…" and the gate heading "on this
   iphone" (B11, B06) — the standing phone rule (the lobby's own "unlock with face id"), hers to keep or carve a
   proper-noun exception; (c) the phone speaks NO protection receipts — `roadStanding.speak` has no phone home, so the
   join's "Sync is on, and you're in Castle now…" is unsaid there (the first-round sheet says the outcome) — unit 2's,
   with the open receipts PL-51 left unspoken.

## PROVISIONALS (the running list)

- **P-VM8-1** — the phone's pre-design face renders Start fresh… only (no Open Library door: the phone has no picker
  road; the standing lobby's own precedent).
- **P-VM8-2** — the phone's Protection screen is Settings ▸ Protection (the Mac's information architecture, the
  phone's navigation); unit 1 mounts only the Sync/account section; a door that cannot act is not rendered (P-2).
- **P-VM8-3** (F-U1-2 (a), ruled (B)) — the gate line on the phone: "This iPhone keeps the new key behind Face ID."
  (`ProtectionWords.gateTouchIDLine`'s phone arm; the Mac's "…behind your fingerprint." byte-identical).
- **P-VM8-4** (F-U1-2 (b), ruled (B)) — `Words.exportAPlainCopyFirst` is NOT said on the phone (no Data Safety, no
  plain-copy road there — PL-13); whether the phone gets its own advisory is hers.
- **P-VM8-5** (F-U1-2 (c), ruled (B)) — the first-round close note on the phone: "You can close this — sync keeps going,
  and Settings says when it's done." (the Mac's "…the bar at the bottom of the window…" byte-identical).
- **P-VM8-6** (F-U1-2 (d), ruled (B)) — the third leave's pointer on the phone: "To delete the account itself, and
  everything it keeps on the server, choose Account… in Settings' sync row, then Delete Account." (the Mac's "…in the
  sidebar's sync row…" byte-identical).
- **P-VM8-7** (taste, the walk's B15) — while sync reads keys-locked / not-yet, the sync row's injected *protection…*
  door and the standing *protection…* row stand together: (a, built) both, as the brief says · (b) the standing row
  hides while the row offers its own door · (c) the standing row moves out of the Sync section.
- **F-U1-1 (A), ruled — NOT a sentence, a door rule:** the phone's unit-1 section renders neither rule-12 arm (the
  Castle-leaving join / Move, the follow out of Castle); F-PH-2 is hers.

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

## UNIT 2 BRIEF (the orchestrator, 2026-10-25 — PROVISIONAL sizing under the overnight latitude; her split
ratification stands in the bundle; the ladder reviews the whole run's diff either way)

**The unit:** the phone's Protection screen grows the faces the kickoff charters, MINUS every leave-direction arm —
one implementer session, acceptance = the doors walked on the pinned simulator + the suites green.

1. **The posture section and the crossings, entering only:** Use Castle… with both secrets typed, the gate choice
   (Face ID made at the press / Always ask) and the standing gate-style row, the export-off notice as a durable mark
   (reconciled at every ready; only OK or Turn it back on clears it — rendered with P-VM8-4's nil in mind: the
   phone HAS rule 11's export-off notice only if a scheduled export exists there — verify in code; if the phone has no
   scheduled export, the notice never fires and nothing renders), the Face ID re-arm question (the shared interlude
   already renders it). **Use Standard… does NOT land in this unit** — its confirm says her rule-12 sentence (F-PH-2,
   hers; the door is NOT rendered on the phone yet, exactly as unit 1's account section holds its two arms).
2. **The key doors:** Change passphrase, Reset forgotten passphrase (Castle by Face ID or the words; Standard the
   plain confirm), New Words through the look, Replace All Keys — over the shared `RoadKeyDoorsModel`/`RoadKeyDoorFaces`,
   each saying VX-263's one line, the synced doors re-wrapping the account's lock in the same act (rule 7), the
   changed-elsewhere refusals naming the device and day (VX-113/PL-59) and pointing at the follow (R-529-3). VX-530's
   at-most-one-Touch-ID-read and VX-517's by-name forgets are core — verify on the phone posture, don't re-trace.
   **The phone's passphrase setter:** the shared `SetPassphraseModel` — the 12-character floor as its only refusal plus
   the quiet strength hint (VX-211) — rendered phone-side.
3. **The follow, the in/into arms + the pair:** `assess`'s followNow door with its notice (the vault's last writer and
   day); one secret in or into Castle; THE PAIR follow (VX-529 — "Follow your account…", either current secret, typed
   words dropping the stale passphrase lock with the sheet saying so and the Reset chain — R-529-5), the durable Done
   (VX-457; the stale done-line hidden while a follow is owed — P-VX529-U2-2). **The follow OUT of Castle does NOT
   land** (rule 12's sentence — F-PH-2). VX-542's repetition is NOT copied (the pair sentence once, beside the doors).
4. **The check door:** "Check my passphrase or twelve words…" over the shared `ProtectionSecretCheck` — reads one typed
   secret, WRITES NOTHING, the four answers (VX-513's sentences), naming a change elsewhere and pointing at the
   catch-up where owed.
5. **Protection receipts' phone home:** give `roadStanding.speak` a phone rendering (unit 1's flag (c)) — the join's
   and the acts' receipts land somewhere honest (the phone's one status seam; a quiet line in Settings/Protection is
   the natural home — PROVISIONAL, flag the shape). The two open receipts re-worded at VX-329 (P-VX329-PH-1) become
   SPOKEN — confirm their wording is the device-neutral re-worded pair, no new words.
6. **Evidence:** pins red-on-old per behavior fix; the unit suites + `MobileNoRedirectSweepTests` green (no exemption
   widened — the leave arms stay unreachable); a simulator walk of every new door (the prod test road's `castle` and
   `std` accounts as fits; key-door acts against TEST accounts only); captures gitignored. The same hard limits as
   unit 1 (the record's ENVIRONMENT TRAPS + the F-U1-4 helper's guards). Zero `Sync/` lines; stop-and-report if one
   seems needed.

## UNIT 1 BRIEF FACTS (checked at kickoff, 2026-10-25)

- The stage read FREE at kickoff; claim it for every simulator run anyway (other sessions may wake).
*[removed for publication]*
  iPhone 17 Pro; deployment target iOS 26; the id, never the name, in every destination).
- The throwaway road's credentials still stand on the Pro (`~/.variorum/dev-vault-throwaway.env`,
  `dev-vault-throwaway-passphrase`, `dev-vault-throwaway-words`) — the ~110k-row corpus for VX-494's test user A is
  likely intact; VERIFY with a read before planning the scale walk on it. The prod test accounts stand
  (`~/.variorum/prod-test-accounts.env`, `prod-test-words-castle` / `-std` / `-del`).

## UNIT 1 — LIVE STATUS (the implementer owns this section; every unverified claim PENDING)

**NOT DONE BY THIS SESSION (first, as the contract asks):** (1) NO Mac-target `xcodebuild test` run — the brief keeps
the dev store's Mac slot off-limits and the Mac test host IS the dev-store app; the shared files changed compile on the
Mac (`build-for-testing` EXIT 0 at `4deb629cc`'s tree, `DerivedData/vm8u1-mac`) and THE MAC-SUITE LIST below is the
orchestrator's stage batch (PENDING). (2) The DEVICE install and her live round — HER MORNING by the brief (ledger row
7). (3) The phone's protection receipts (no `speak` home on the phone — her bundle 8(c), unit 2's). (4) The
pre-existing red `MobileMarkdownCaretTests` (VX-296, editor seam) is NOT this unit's: red on the PRE-FIX tree on the same
simulator — recorded, not touched. **No revert is in flight; the stage is released; the simulator is shut down and
signed out.**

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
  **RESULTS — DONE, every one RED as named, each batch restored `git diff --exit-code` clean; NO REVERT IS IN FLIGHT.**
  - batch A: `✘ Test run with 10 tests in 3 suites failed after 15.545 seconds with 17 issues` — RED exactly
    `herFaceSaysHerWordsAndOffersStartFreshAlone` (×4: no lead, no body, no door, the lobby title), `startFreshAsks…` (×5:
    no door to press, no confirm, nothing ran), `theJoinArms…` (×2: "…behind your fingerprint."), `theFirstRoundSheet…`
    (×2: "…the bar at the bottom of the window…"), `theRuleTwelveArms…` (×3: the leaving join, Move and the follow out
    all rendered), `thePhonesRootAttaches…` (×1: no `attach`); GREEN the guards and batch B's two.
  - batch B: `✘ Test run with 10 tests in 3 suites failed after 14.290 seconds with 2 issues` — RED exactly
    `theJoinArms…` (the Data Safety pointer said) and `theReopensAsk…` (the ask adopted twice); every other test green.
- **Piece 3 — VX-501 on the phone's posture:** PIN GREEN (this commit), red-on-old PENDING. No phone pin covered it (the
  mechanism is shared and Mac-pinned — `TypedUnlockSyncKeysTests`; not re-traced). NEW `MobileTypedUnlockSyncKeysTests`
  over NEW `MobilePlantedProtection.swift` (the Mac support's planted leaves COPIED VERBATIM — the two test bundles are
  separate modules): her phone's whole road through the PHONE'S OWN compiled bootstrap — a fresh library (the phone's
  words card), signed in to an account whose vault is in Castle, the JOIN ("Sync this library…", `.entersCastle`,
  re-keying through the reopen) with Always ask and the account's passphrase → Castle under the account, rule 7's
  notShown moment, the reopen's Protection ask; then a LOCK (the lobby, session memory dropped); then the TYPED UNLOCK →
  the account's keys in session memory, the engine's seam reads them. `✔ Test run with 1 test in 1 suite passed`.
  **RV-6, named before it runs:** `Shared/Protection/ProtectionOpenRoad.swift` — `openTyped`'s one
  `loadSyncKeysAfterTypedUnlock` call removed [`herPhonesJoinIntoCastleThenATypedUnlockLoadsTheSyncKeys` — the two
  load expectations]. **RAN: `✘ Test run with 1 test in 1 suite failed … with 2 issues`** — exactly the two (nothing in
  session memory; the engine's seam refuses); restored `git diff --exit-code` clean — **no revert in flight.** VX-501's
  typed-unlock load FIRES on the phone's posture. The LIVE check rides piece 4's Castle leg.
- **Piece 4 — the simulator walk + the measured save:** DONE — LEG A (scale + the app switch + the stage resume), LEG B
  (Castle + Face ID on the prod test road, the re-keying join through the reopen, VX-487/VX-501 live), LEG A2 (a kill
  MID-download — the partial-stage resume). Every leg below; captures `notes/plans/vm-8-u1-screens/` (gitignored).
  - **The walk's machinery (recorded):** Xcode 27 has NO Simulator.app — the simulator is hosted in Device Hub
    (`com.apple.dt.Devices`), so the helper's frontmost guard accepts that host too (recorded in its header; otherwise the
    ruled guards exactly). Captures are `xcrun simctl io <pin> screenshot` ONLY (the simulator's screen, never the host
    screen — a full-screen probe capture showed her own windows and was deleted at once); taps are `cliclick` at host
    points mapped from phone points (the screen calibrated by template match inside Device Hub's window). The words card's
    capture is redacted (a throwaway simulator library's words). Captures: `notes/plans/vm-8-u1-screens/` (gitignored).
    `~/.variorum/bin/type-sim-secret` (mode 700, never committed): `--check` passed before every typing; values never
    printed.
  - **LEG A — PASS (2026-10-25 11:28–11:41 UTC, stage claim `vm8-u1`, the phone Debug build of `d6eba3b38` on the pin,
    launched with the throwaway walk lift — `ps eww` showed the throwaway ref, no production ref):** a planted pre-design
    store (a 256 KB opaque `variorum.sqlite` + an older key-file NAME `variorum-keys.json`, never read) → **her face**
    (A01: her lead, her body, *start fresh…* alone, no Open Library) → *Start fresh…* → **her confirm** (A02: her line,
    Cancel · Start fresh) → **set aside whole** into `Previous Libraries/2026-10-25-112950/` (both files, bytes
    untouched) → **the words card** (A03, redacted) → the shelf (A04) → Settings: the sync row "Signed out" + *sign in…*
    and the new *protection…* row (A05) → **the Protection screen**: "This library doesn't sync." · "Sign in to turn on
    sync." · *sign in…* (A06) → the Account sheet (A07) → throwaway user A signed in by the helper (A09) → close → **the
    JOIN door** "sync this library…" + *sign out…* (A10) → the join confirm (sameMode — "Your account is in Standard,
    like this library.", one secret) (A11) → the passphrase by the helper → **rule 7's moment, the words not shown**
    (A12, the account named) → OK → **the first round STAYS** — "Syncing your library with your account…", the phone's
    close note (P-VM8-5), Done (A13).
  - **THE DOWNLOAD:** 2,000-row windows, ~80 calls (each a ~200 KB window), the stage growing ~5 MB / 5 s.
  - **THE APP SWITCH (the acceptance case):** at 11:32:34 the phone switched to the Settings app mid-download (~30% in).
    The download KEPT GOING inside the background grant ("Variorum flush before suspension"); iOS called the grant's
    expiration handler at 11:33:03 and the download reached the feed's end at 11:33:07 (the empty window); **iOS then
    SUSPENDED the app (state `Ss`, 0% CPU from 11:33:12) with the whole feed staged (store 78.9 MB) and the save NOT
    committed.**
  - **THE KILL + THE RESUME FROM THE STAGE (VX-494's hard case, live on the phone):** the suspended app was terminated
    (11:34:01 — a crash's shape) and relaunched (11:34:03): the Standard library opened quietly; **six small calls and
    ZERO data windows** (05:34:05.26–.69 local), then the save straight from the stage at ~100% of one core.
  - **THE MEASURED SAVE (VX-497's number):** **≈ 6 min 25 s** — 11:34:05 → the commit at ~11:40:30 UTC (the store
    79.3 MB → 150.3 MB, WAL to ~150 MB, CPU 97–100% of one core throughout, then ~12 small follow-up calls at 05:40:34);
    **peak RSS ≈ 457 MB** (447 MB in the download run). Ground: the iOS 26.2 SIMULATOR on the M3 Pro (the Pro's CPU, not
    the phone's), the throwaway's 1,200 notes × 30 paragraphs (~110k feed rows, 1.08M words). Her Mac's own save on her
    real corpus was ~4 min 20 s (VX-494); VX-494's throwaway walk ~7 min on a shared CPU. **The device number on her
    corpus stays the device moment's (HER HANDS).**
  - **THE PROOF OF COMMIT (server, read-only):** the phone's device `aa227b13…` reports `last_seq` **110,424** at
    11:40:34 UTC — exactly throwaway A's head (VX-494's own L2 reads the same). The shelf: "vx-494 scale corpus · 1200
    notes" (A16).
  - **MACHINERY FAULT, FOUND AND SAID (2026-10-25 11:47 UTC):** the walk's app was installed from
    `DerivedData/vm8u1-ios/Build/Products/Debug-iphonesimulator/` — but the "walk build" (`xcodebuild build` with no
    `-configuration`) had written RELEASE products, so the Debug app installed was the one the RV-6 revert run built:
    the committed tree EXCEPT `openTyped`'s one VX-501 load call. Everything LEG A walked (the pre-design face, Start
    fresh, the Standard join, the first round, the switch, the kill, the resume, the save) and LEG B up to the Face ID
    unlock never reaches that line, so they stand; the TYPED unlock at 11:46:57 met the revert and read **"Sync locked —
    this iPhone hasn't unlocked your account's sync keys"** (B15 — RV-6's red, LIVE on the phone, unintended). The Debug
    app was rebuilt from the clean tree (`-configuration Debug`, the dylib 05:48 local) and the typed unlock is re-walked
    below. Lesson for the brief: build the walk app with `-configuration Debug` and install from its own products.
  - **LEG B — PASS (11:42–11:50 UTC; the clean Debug build from 11:49; launched on the PROD TEST ROAD —
    `VARIORUM_PROD_TEST_ROAD=1` + the allowlist handed, NO walk project, `ps eww` checked; the `castle` vxtest account;
    Face ID ENROLLED on the simulator):** a fresh library (B01 — the words card, redacted) → Settings (B02) → Protection
    → the Account sheet (B03) → signed in as the castle test account by the helper (B04) → close → "sync this library…"
    (B05) → **THE JOIN INTO CASTLE in the phone's words** (B06): the join's lead, rule 7's first sentence, "Your account
    is in Castle, so this library goes into Castle too.", rule 9's promise, Use Castle's lead, the Previous Libraries
    line ("…on this iPhone…"), the floor naming Face ID — **NO Data Safety pointer (P-VM8-4)** — the gate rows **Face ID
    (preselected) · Always ask** with **"This iPhone keeps the new key behind Face ID." (P-VM8-3)** → the account's
    passphrase by the helper (B07) → *sync this library* at 11:44:38 → **the re-keying act through the reopen**
    (`enroll: … swapped — the library is under 9b1c04fa`, `retired 1 own Apple key(s)`, `turnOnSync — … castle`, `road:
    opened … custody silent 0 touchid 1` — the Face ID item made at the press) → **F-U1-3 LIVE: the shell adopted the
    reopen's ask and the presenter's sheet came back on the re-pushed Protection screen** with rule 7's moment (B08a/B08
    — within 3 s) → OK → the round phase (B09) → **"Synced. Your account's writing is in this library now."** (B10 — a
    re-keying act's first round through the reopen's FRESH services: D-B0's generation, on the phone) → Done → the
    section "This library syncs with your account." · *stop syncing here…* · *delete the account from this iphone…* ·
    *sign out…* (B11). Server (read-only `Tools/prod-read.sh`): the phone's device `a40aefcd…` at `last_seq` 28 = the
    account's head beside the Macs' devices; the vault untouched (Castle, its last writer her MacBook Pro — a join adopts
    the account's pair locally, rule 7).
    - **The Face ID unlock (VX-487 on the phone, live):** relaunch → the lobby's one automatic ask → the simulator
      approved it → `road: the Touch ID unlock loaded the account's sync keys for the session (sync key c6e40f99)` →
      Settings "Synced 5:46 AM" (B12–B13).
    - **The TYPED unlock (VX-501 on the phone, live):** Face ID UNENROLLED → relaunch → the Castle lobby ("Enter your
      passphrase or your twelve words…", "Face ID isn't set up on this iPhone.") (B14/B16) → the passphrase by the helper
      → *open* (11:49:41) → `road: the typed unlock loaded the account's sync keys for the session (sync key c6e40f99)`
      → Settings **"Synced 5:49 AM"** (B18). (On the RV-6 build at 11:46:57 the same press read "Sync locked" — B15: the
      red and the green of VX-501 both seen live on the phone.)
    - **A wart seen (taste — bundled, P-VM8-7):** while the row reads keys-locked / not-on-yet, the sync row's own
      *protection…* door (VX-486's, injected per the brief) sits directly above the standing *protection…* row — two
      doors, one name, one screen (B15). Built as the brief says; options in her bundle.
  - **LEG A2 — PASS (11:50–11:59 UTC, the clean Debug build, the throwaway again, a fresh library):** sign in A → *sync
    this library…* → the passphrase → the join (11:51:35) → **KILLED MID-DOWNLOAD** at 11:52:19 (the stage 29.6 MB, **23
    data windows** in) → relaunch 11:52:30 → **32 data windows** (05:52:33–05:53:02 local — only the REMAINING ones; 23 +
    32 = the feed's ~55, nothing fetched twice) → the save from 11:53:04 → the commit at ~11:59:26: **the save ≈ 6 min
    22 s** (the second sample; peak RSS ≈ 458 MB) → server: the new device `bfb075f7…` at `last_seq` **110,424** =
    head (A2-04).
  - **LEG C — the leaves and sign-out (12:12–12:16 UTC, the clean build, the throwaway library still in sync):** the
    in-sync section (C01) → *delete the account from this iphone…*'s confirm in the phone's words — rule 16's two
    sentences and **"…choose Account… in Settings' sync row, then Delete Account." (P-VM8-6)** (C02) → cancel →
    *stop syncing here…* → its confirm (C03) → *stop syncing* → **"This library doesn't sync." · *sync this library…*
    (signing back in is a join) · *sign out…*** (C04) → *sign out…* → the confirm (C05) → signed out (C06). A cosmetic
    found there: the medium-detent sign-out sheet left the system grey above and below its card (C05) — fixed (the room
    fills the sheet), re-walked after a fresh sign-in (C07–C08), signed out again (C09: the simulator rests signed out).
- **Piece 5 — evidence:** DONE.
  - **Pins, red-on-old by behavioral revert (each named before it ran, each restored clean):** RV-1…RV-5 (pieces 1–2,
    batches A/B above) and RV-6 (piece 3) — every named pin RED as named; guards green on both sides by design.
  - **THE PHONE TARGET WHOLE on the pinned simulator at the final tip `227ce0ca3`'s product tree (`-only-testing:
    VariorumMobileTests`, stage claim `vm8-u1`):** `✘ Test run with 819 tests in 130 suites failed after 420.635 seconds
    with 6 issues (including 4 known issues)` — the four DECLARED known issues (`MobileTrashTests`
    `anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` ×2, `MobileTutorialWalkTests`
    `theFannedDivideLessonLandsTheDuplicateShape` ×2 — the standing ones) and ONE red suite, **`MobileMarkdownCaretTests`
    ("VX-296 — the caret-aware face", `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` — `desyncRecoveryCount
    == 0`, 2 issues), PRE-EXISTING: the same suite ran RED on the PRE-FIX tree (`fd56f2279`, `git archive`d into the
    scratchpad, its own DerivedData) on the same simulator** — not this unit's (no editor-seam line in this diff); the
    orchestrator's to ticket (it may be the simulator's keyboard state after a host-keyboard walk, or VM-19's test-posture
    class — untraced). Zero skipped (the two "skipped" log lines are the AppIntents metadata tool's). The unit's own six
    suites at the tip: `✔ Test run with 18 tests in 6 suites passed` (`MobilePreDesignFaceTests`,
    `MobileProtectionAccountSectionTests`, `MobileProtectionCompositionTests`, `MobileTypedUnlockSyncKeysTests`,
    `MobileNoRedirectSweepTests`, `MobileProtectionRoadTests`). `MobileNoRedirectSweepTests` green — no exemption
    widened, the `herRuleTwelve` literal untouched and still unreachable on the phone (F-U1-1 (A)).
  - **Builds:** phone `build-for-testing` EXIT 0 (generic iOS Simulator); Mac `build-for-testing` EXIT 0 (the shared
    words' Mac arms byte-identical by construction — `ProtectionRoad.isMac`).
  - **THE MAC-SUITE LIST (the orchestrator's stage batch — every Mac suite reading a shared file this unit changed):**
    `ProtectionWords` (`gateTouchIDLine`, `firstRoundCloseNote`, `deleteHerePointer` became `ProtectionRoad.isMac`
    ternaries): `RoadCrossingWordsTests`, `RoadAccountWordsTests`, `RoadJoinFollowWordsTests`, `ProtectionWordsPlanTests`,
    `ProtectionWordsVX307Tests`, `U2WordsTests`, `FirstRoundConfirmTests`, `FirstRoundAfterTheActTests`,
    `RoadAccountSurfaceTests`, `RoadCrossingSurfaceTests`-family (the whole `VariorumTests/Protection` folder is the honest
    batch, as VX-510 unit A said); `RoadCrossingFaces.sentence` (the phone-nil arm): `RoadCrossingFacesTests`,
    `RoadJoinFollowFacesTests`, `ProtectionCrossingRoadTests`; `RoadAccountFaces.saysRuleTwelve` (new, read only by the
    phone): `RoadAccountFacesTests`; `WordsFieldsConcealTests` (three phone sites added — source); the source pins that
    read phone files: `NotOnYetWordsTests`, `OneRefreshAuthorityTests`, `ProtectionWordsVX307Tests`,
    `LobbyWordsDoorPressTargetTests`, `TravellingDotsIndicatorTests`, `WordsFieldsConcealTests`.
  - **The walk:** pieces 4's LEGS A · A2 · B · C above; 50 captures in `notes/plans/vm-8-u1-screens/` (gitignored; the
    two words cards redacted; the host screen never captured).
  - **The local helper (F-U1-4 — hers to keep or delete at closeout):** `~/.variorum/bin/type-sim-secret` (mode 700,
    never committed; `--check` types nothing). Guards: the source file exists at mode 600; the frontmost app is the
    simulator's host (Simulator, or Xcode 27's Device Hub — there is no Simulator.app in Xcode 27); exactly ONE booted
    *[removed for publication]*
    needs the throwaway ref in that process's environment and NO production ref (reads only the throwaway files); the
    prod road needs `VARIORUM_PROD_TEST_ROAD=1`, NO walk project, and the account's email on the allowlist with `vxtest`
    (reads only the allowlist file and the stashed words). Values never printed.
  - **Server residue (test accounts only):** throwaway A gained two simulator devices (`aa227b13…`, `bfb075f7…`, both at
    head); the prod `castle` vxtest account gained the simulator's device `a40aefcd…` (at head 28) — each a device cursor
    that now holds that account's purge horizon until it ages out or is cleaned (the VX-510 test-device precedent).
  - **Known, not met:** VX-544 (every unlock walked was online). VX-542's repetition not copied (no key doors on the phone
    in unit 1; the follow's notice renders once beside its door).

## THE LEDGER (numbered; every row owned; updated repo-first)

| # | item | owner | status |
|---|---|---|---|
| 1 | Unit 1 — the phone syncs again (pieces 1–5 above) | implementer U1 | CLOSED on the simulator (tip `11c4f2054`). **The Mac stage batch RAN (orchestrator, 2026-10-25): 625 tests / 132 suites, 4 declared skips, ONE red suite — `ProtectionPairRetentionTests` (3 issues), PROVEN RED ON MAIN the same day → pre-existing, filed VX-546; everything VM-8 touches green, the Mac's ruled sentences byte-identical by pin.** The device install HELD for her |
| 2 | Unit 2 — crossings (entering), key doors, follows (in/pair), check door, receipts' home — the UNIT 2 BRIEF above; leave-direction arms HELD for F-PH-2 | implementer U2 | BRIEF WRITTEN — spawns after the Mac batch |
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
