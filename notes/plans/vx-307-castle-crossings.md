# VX-307 — Castle rebuild, phase 3: the crossings' faces and the account's new shape (the `key_vault` lockstep)

**Status: OPEN — kicked off 2026-10-18 ~18:45 MDT (`/architect-phase vx-307`, the author; worktree
`~/dev/variorum-vx-307`, branch `vx-307-castle-crossings`; the in-flight row HOLDS the one Sync/-custody slot; the stage
coordinator is `1018coordinator`, the slot granted 18:44 — stage protocol REQUEST/READY/GO/RELEASE, dev store 86a82b4f
Standard on the new road, dark, restore hold standing). Originally written 2026-10-18 at VX-306's closeout, to
`notes/CastleRules.md` (the contract) and the lifecycle page.** The VX-307 TICKET'S BODY IS THE OLD DESIGN (the anchor, the rotation, VX-107/VX-109's lines) and is
SUPERSEDED by this plan where they differ — the core already holds every act to the rules (VX-378): `useCastle`,
`useStandard`, `replaceAllKeys`, `follow`, `setUpSync`/`enroll`/`move`/`leaveAccount`, and the vault's new shape
(`VaultModel`: the master under the passphrase and the words only, the MODE flag, the current sync key, the earlier sync
keys under the current master, the key proof's hash, the last writer).

- **The contract:** `notes/CastleRules.md` rules 7–16 (and 25) — read in full. **The walk:** `notes/plans/vx-266/
  castle-lifecycle.html` stages 6, 7, 8, 11, 12. **The road this phase extends:** VX-306's (`notes/plans/vx-306-castle-open-
  road.md` — §2's units, §9's records, §8's environment traps; the Debug-only switch stays; nothing reaches Release until
  VX-329).
- **Tickets:** VX-307 (this phase); VX-301 (the Apple keys' lifecycle — built in the core at VX-378/VX-390; this phase's
  faces say it); VX-310's second half (the Touch ID RE-ARM question after a press fails on an existing item — `answerTouch
  IDRearm`); VX-380 and VX-406 ride if their fix is one line in a touched suite. The `key_vault` change is THE lockstep
  event (SyncSpec §12) — the mirror deploy only at her explicit go.

> **KICKOFF MESSAGE (paste-ready).** STEP 0: from `~/dev/variorum` on `main`, `git pull`; `git worktree add -b
> vx-307-castle-crossings ~/dev/variorum-vx-307 origin/main`; push the branch; the in-flight row (it HOLDS the one
> Sync/-or-custody slot — this phase writes `Sync/` lines: the vault leaf over the RPCs and the sync keys' custody); Linear
> VX-307 → In Progress; announce to the stage coordinator. **Read first, in full:** `CLAUDE.md` and its canon;
> `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md`; `notes/SyncSpec.md` WHOLE (§3's custody paragraph and §12's
> lockstep rule bind every line here); the lifecycle page; this plan; VX-306's plan §9 (the records — how the road, the
> faces and the leaves are wired; its walk findings); the core's `Executor/VaultModel.swift`, `Acts/EnterCastle.swift`,
> `LeaveCastle.swift`, `ReplaceAllKeys.swift`, `Follow.swift`, `AccountActs.swift`, `Assess/Assessment.swift` (the doors,
> `OwedAct.follow`, `VaultVerdict`); `Server/supabase/11_pre13x_postures.sql` (today's vault RPCs) and the engine's
> vault client in `Sources/VariorumCore/Sync/`; `App/Variorum/Shared/Protection/*` (the leaves — `UnreachableVaultLeaf`
> and `KeychainSyncKeysLeaf` are this phase's to make real), `ProtectionController.swift`/`PostureSwitchModel.swift`/
> `PostureFollowModel.swift` (today's crossing faces, retired behind the new ones on the new road), `PostureCopy.swift`.
>
> **The one law:** the new road stays DEBUG-ONLY (VX-306's switch); Release runs today's road byte-unchanged. **Hard
> limits:** every `Sync/` line is FABLE's (CLAUDE.md); the lockstep's mirror deploy runs ONLY at her explicit go; nothing
> from the rules' considered-and-not-pursued list (no anchor, no stuck leave, no rotation walk — rule 15's kept list reads
> every row); no migration of pre-design stores (rule 26); both secrets at Use Castle and Use Standard (P-VX378-U2-2, her
> ruling); Private, Seal, Own and the MCP door untouched.

## 1. What this phase is, and how it closes

The crossings get FACES on the new road and the ACCOUNT gets its new shape on the server: **Use Castle** (rule 11 — the
door asks the passphrase and the words, names the copies under a key it can't delete (`Words.copiesUnderAKeyThisMacCantDelete`),
the gate style (Touch ID or Always ask), the export-off notice; the act on its plan), **Use Standard** (rule 12 — the leave
screen's sentence: *your library and all your backups will open through your Apple account and this Mac again; if you want
Castle-era writing to stay Castle-protected, don't leave*; both secrets), **Replace All Keys** (rule 6's door-family cousin —
the library re-keys, the account's sync key stays, P-VX378-U2-1), **the follow** (rules 10, 12, 15 — into Castle and
catching up on a replaced sync key: one secret typed; out of Castle: quiet with a notice `ActNotice.followedOutOfCastle`;
VX-113's refusal naming the change — *Your passphrase was changed on [device] on [day]* from `VaultReading.updatedByDevice`/
`updatedAt`), **sync setup and the join** (rules 7, 14 — the first device hands its pair up; a joining device types one
secret and is told *your library's twelve words are now your account's twelve words; here they are; the old ones still open
backups you made before today* — P-VX378-U2-3's shape when the passphrase was typed), **the Touch ID re-arm question** (§3.10,
VX-310's second half, `answerTouchIDRearm`), and **the sync keys' custody** on the new road (`KeychainSyncKeysLeaf`, by the
account's mode — rule 15's custody; today's `SyncCustodyRecord` road retires on the new road only).

**THE LOCKSTEP EVENT (SyncSpec §12; marker 13 → 14):** the `key_vault` row takes the rules' shape — the Apple-held master
wrap and `apple_key_id` LEAVE; a MODE flag and the earlier-sync-keys list (each under the current master) ARRIVE; the
rotation fields (`corpus_previous_key_id`, `corpus_previous_wrapped_by_master`, `rotation_started_seq`) and
`sync_reencrypt` RETIRE; `key_vault_update` stays the one CAS write (the key proof unchanged — the 13y challenge protocol
stands). ONE artifact `Server/supabase/17_phase_vx307_vault.sql`, additive where it can be (new nullable columns; the
retired columns left in place, unread), the RPC bodies redefined; the production `VaultLeaf` over `fetch`/`create`/
`updateVault`; the engine's key provider reads `AccountKeys` from the new custody. The choreography: the mirror FIRST at
her go, then her Mac's Debug build (the Release road never reads the new columns until VX-329 — say so in the checklist:
a marker-14 mirror with a marker-13 Release client means the RELEASE app visibly refuses to sync until VX-329 ships; the
bump therefore WAITS for VX-329 unless she rules otherwise — PROVISIONAL at kickoff, her call). **HER RULING (2026-10-18, at VX-306's close, verbatim): "I think it makes sense to wait to bump the mirror until we're ready to release this so that my client doesn't stop syncing." — RULED, no longer provisional: the mirror deploy and the marker-13→14 bump WAIT for the release that carries VX-329's switch; VX-307 ships the SQL artifact and the production vault leaf behind the Debug-only switch, proven on the two-client fake server (U1's suites), and no deploy checklist row runs before that release's window. The kickoff call above is answered.**

**Closes on USE-shaped evidence:** the dev store walked through stages 6, 7, 8 and 12 (the account arms stand on the two-client fake-server convergence suites here — the throwaway-account question moved to VX-308 with the account faces, her ruling 2026-10-18), a convergence suite per account act (two clients, the fake server emulating the new RPCs),
the crash harness over every crossing (the core's — already green), the Fable ladder (every line here is custody or
`Sync/`), both configurations green.

## 2. The units

### U1 — THE VAULT'S NEW SHAPE ON THE WIRE (Fable's lines; the lockstep's artifact; the production VaultLeaf + SyncKeysLeaf)
The SQL artifact + its deploy checklist (the 13y/13i-e shape; the mirror runs only at her go); the fake server's new RPCs; the
production `VaultLeaf` (fetch/create/update over the RPCs with the key proof); the production `KeychainSyncKeysLeaf` wired
(the engine's `SyncKeyProviding` reads the new custody on the new road); the two-client convergence suites for sync setup,
join, the follow into/out of Castle, a lagging device (rule 15). Evidence: the suites green in both configurations; the
lockstep checklist written with PENDING-until-live rows.

### U2 — THE CROSSINGS' FACES (Use Castle, Use Standard, Replace All Keys, the gate choice, the export-off notice, the re-arm)
Each door reads `assess`'s `DoorState` (open/refused with its sentence), asks exactly what `SecretRequirement` says, runs
the act, speaks its receipt/notice; the Protection pane under the new road carries them (today's doors retire there);
VX-310's re-arm question after a failed press. Evidence: the dev store walked through stages 6, 7, 8 (Castle entry under
Touch ID and under Always ask — `dev-castle.env`'s values; the walk restores Standard before release), 11's re-arm on a
planted failure; pins per door from planted facts; the words checked against the rules (VX-379's standing item).

### U3 — THE ACCOUNT FACES — MOVED TO VX-308 (VX-418). RULED by her, 2026-10-18: "yeah it's fine to keep them in phase 4" — this phase is TWO units (U1, U2) and the riders; nothing account-facing builds here (the wire and its convergence suites are U1's). For the record, the moved unit read: sync setup, the join, the follow, leave the account, VX-107, VX-113, VX-314, VX-239/243's one presenter, VX-264's screens; evidence the convergence suites, the walk if her kickoff call allows a throwaway account, the words).

## 2a. THE MEMBERS BY TICKET (her phase-3 list, reconciled 2026-10-18 — every one is a sub-issue of VX-307 on the board; the plan's units above are the build order, this table is the ledger)

| Ticket | Unit | What closes it here |
|---|---|---|
| **VX-108** Posture doors gate on a stale reading | U2 | every door reads `assess`'s `DoorState`; every act reads the vault it fetched (never the local posture) |
| **VX-109** A concurrent Use Standard vs a rotation | U1 | rotation is gone; the ONE-ROW CAS write refuses the loser plainly (`Sync/`, Fable's lines) |
| ~~VX-233~~ The posture drill | — | RETIRED at her word (2026-10-18, "I'm down to retire it"): it drives today's crossing code, which VX-329 deletes; the drill file goes with it (parented under VX-329, Canceled). The crossings' proof here is the lifecycle scenario, the crash harness and this phase's walk |
| **VX-235** A crash between the marker and the key-file write | U2 | the crossings run the core's planned acts (prepare-then-commit, rule 20 — built at VX-378); the crash harness proves every crossing |
| **VX-313** Sealed plans running the real acts | U1/U2 | the acts run the core's sealed plans on the production leaves; a file or keychain edit cannot steer custody (rule 21) |
| **VX-301** The Apple keys' lifecycle | U2 | reduced: the core's sweep by the catalogue + VX-390's stamp at entering Castle; this phase's faces SAY it |
| **VX-310** (second half) The Touch ID re-arm question | U2 | `answerTouchIDRearm` after a press fails on an existing item |
| **VX-416** the `key_vault` lockstep (absorbs VX-109 and VX-313's wire half) | U1 | the SQL artifact, the production vault leaf, the fake server's RPCs; the MIRROR DEPLOY AND MARKER 14 WAIT for the release carrying VX-329 (her ruling, §1) |
| **VX-417** the crossings' faces (absorbs VX-108, VX-301's saying, VX-310's re-arm, VX-235's proof) | U2 | both crossings type the passphrase AND the words (P-VX378-U2-2); the leave screen's sentence; the follow-out's quiet notice; the export-off notice, reversible |
| **VX-412** The twelve words, her way | U2 | the band card, the tour's end, Copy, warn-before-close, rule 3's reminder folded in (rules 2/3/7 already amended) |
| **VX-413** Look inside's Copy door | U2 | Copy full text out of the facts sheet (her word: required here) |
| **VX-414** The dropped split-pair line + her two U2-7 sentences | U2 | wording, pinned byte-equal |
| **VX-379** (its rows) The guide and the panes to the rules | U2 | the Castle/backups chapters, Data Safety + the protection panes, the tutorial's last card |
| ~~VX-263~~ The anchor written at the leave | — | SUPERSEDED at her word (one posture; the leave hands everything out) — CANCELED on the board 2026-10-18 |
| → VX-308 | — | **VX-418** the account faces, with VX-107 · VX-113 · VX-314 · VX-239 · VX-243 · VX-264's screens — moved; RULED by her 2026-10-18 ("it's fine to keep them in phase 4") |

## 3a. HER RULINGS OF 2026-10-18 ON THE VX-306 BUNDLE (verbatim where quoted; they bind this phase)

- **The mirror:** "I think it makes sense to wait to bump the mirror until we're ready to release this so that my client doesn't stop syncing." (recorded in §1 — the deploy and marker 14 wait for the release carrying VX-329.)
- **Look inside** (P-VX306-U3-15): "I think it's fine for Look inside to be a facts sheet." Then: "Can you still copy text out of it? … I think that should be done somewhere in this phase because otherwise look inside isn't that useful." → **VX-413 is a REQUIRED piece of this phase** (a Copy door on the note page; the format RULED: Copy full text — "copy full text is a good idea").
- **Make this my library's fresh store identity** (U3-9): "it's fine for make this my library change your settings, I think that's fair." ACCEPTED.
- **The interlude card** (U2-1): "I think 3 is fine, I'll wait and see it when I'm going through the whole tutorial flow on a fresh account to see how it looks." STANDS; her fresh-account walk is the check.
- **The crossover** (U3-5): "I'm not worried about what happens in the crossover before the new system really." ACCEPTED.
- **THE TWELVE WORDS, HER WAY — VX-412 (High, Needs Lillian on one fork):** "I don't want the new library to show those words at creation before the bookcase and before the tour offer. that breaks my idea of opening the app for the first time being a calm moment where the user can just type. i think it should show at the end of the tour and maybe as a separate notice on the same screen the first time a user opens - having two cards on the screen isn't my favorite, but it's fine I think. maybe a card above the 'write note here' line that just says 'your library is encrypted. click here to record the 12 words that are its key' or however you want to say it. but opening the app for the first time can still be calm - and that card can be present until the user clicks the dismissing x button on it. in fact, I feel like that would be better than showing things in the lobby in general. i do think that for the notice or key file offer the lobby is fine because it should be more obvious, but first open should still be calm. … it should also show a toast when dismissed like 'look in settings, protection for this information' or something. I think a snoozed card showing on next launch is fine." Her drawing of the band — between the shelf listing and the quick-entry line, the main column's full width: `notes/plans/vx-307/her-cards-area-2026-10-18.png`. **The fact that shapes the build:** the app never keeps the words (rule 2; `OnceShownWords` lives until the card's button), so a later card MINTS fresh words when she chooses to look (rule 6's act, the Settings new-words door's) — recommended; keeping them until recorded is the alternative. **Her addendum, minutes later:** "ok if the words aren't kept it can warn them before they close the card or that can be handled differently than i suggested. i dont want the lobby at start though." — so the HARD rule is NO LOBBY AT START; **her refinement:** "the card can be offering to click on it to bring the words up and not have shown them at all. we could *not* show them until the card is clicked on if that would make it more secure." — the words are never shown before a click; the first click (the band card or the tour's end) mints and shows the words she records; the once-shown card may warn before it closes — *these words won't be shown again* — and the band card then reads as the door to fresh words), nothing stored. **Her word the same afternoon: "I agree with your suggestion on the dismissed card's reminder job overlapping with rule 3's passphrase reminder. go ahead and change the rules appropriately. … the cadence is fine." — RULES 2, 3 AND 7 AMENDED on main at her word (the band card is the one home for the words and rule 3's reminder; U2's bottom-bar reminder retires into it at VX-412; the cadence unchanged). The rules were amended ahead of the build (the words shown once — at the tour's end or from the card, no longer before the first screen; the tutorial's last card asks the passphrase AND shows the words). The **tour offer as a card in the same band** is VX-415, PARKED at her word ("that change doesn't have to be in these plans").
- **The words** (U2-6/U2-7): "sure we can drop the sentence" · "I agree with your suggested wording" → **VX-414** (a rider here; the two sentences are in the ticket).
- **The design principle these add (for every face this phase builds):** the FIRST OPEN STAYS CALM — nothing stands between launch and the Bookcase; what must be said later is a dismissible card in the band above the quick entry; the lobby's room is for what must be obvious (rule 21's notice, the key-file offer, rule 27).

## 3. Hand-forwards into this phase (from VX-306)
- **From VX-306's ladder (round 2, NITs 1–2):** (i) Make this my library on a copy only Touch ID opens prompts TWICE (the preflight and the act) — one press once a Touch ID item exists; (ii) a wrong typed secret in Look inside falls through to a Touch ID press — pinned as EXPECTED by `LookInsideRoadTests.theLooksFirstTryNeverPressesTouchIDAndHerOpenMay`, a deliberate flip-target here; (iii) `Copies.swift`'s `openCopy` carries the PROMPTING default (`.includingTouchID`) on the core layer while the app's twin defaults to `.withoutAPress` — drop the core default and make every caller choose when this seam is touched. (iv) The core's `createLibrary` preflight (round 2 m3) is built at VX-306's close.
P-VX306-U3-18 (no Look inside on the phone); W-11 (the renumber residue on the dev store's previous libraries); W-13 (the
Restore list's refresh — if the VX-306 ladder did not fix it); W-14/W-15 (the phone's chrome case and "on this Mac" —
her taste calls); VX-379's rows (the posture box's sentence, the Data Safety restoring paragraph, the protection pane's
today's rows). The sync keys' two-systems coexistence on the dev store (P-VX306-K3) ends here.

## 4. Risks
The lockstep with a Release client still on today's road (above — her call); the real keychain's synchronizable items
under a Castle entry (deletion reaching the Apple account — the simulator and the Pro share no Apple account for the dev
scope: the walk sees one device); the one-write vault CAS under a real network.

## 5. HER KICKOFF RULINGS (2026-10-18, the sitting at kickoff — question tool, her picks verbatim-faithful)

- **The cast:** "Fable fork builds U1 (Recommended)" — a Fable FORK of the orchestrator (inherits the full preflight
  context, runs as its own implementer session under the checkpoint protocol) implements U1; Opus implements U2 fresh as
  ever; a fresh `fable-reviewer` per ladder round (every line here is custody or `Sync/`). The orchestrator keeps its own
  context for walks, arbitration, the ladder and closeout.
- **Riders:** "Plan's two only" — VX-380 and VX-406 ride only if their fix is one line in a touched suite; VX-152
  (AppBootstrap.lock() reentrancy) was offered and stays on the board.
- **Run shape:** "Overnight mandate" — U1 → U2 → walks → ladder → closeout continuously, PROVISIONAL-and-continue on
  anything short of an author-only stop, everything bundled for her morning read (the #234 pattern). She may interject.
- Standing from §1/§3a (already ruled, restated for the fork): the mirror deploy and the marker-13→14 bump WAIT for the
  release carrying VX-329; the account faces are VX-308's (this phase is U1 + U2 + riders); VX-413 is REQUIRED here;
  VX-412 builds the amended rules 2/3/7 (the words never shown before a click; a look mints fresh words; no lobby at
  start).

## 5a. U1 BRIEF — THE VAULT'S NEW SHAPE ON THE WIRE (the Fable fork; read with §1's lockstep paragraph and §2 U1)

**The goal.** The core's `VaultModel`/`AccountVault` (rules 7, 11, 12, 14, 15 — the master under P and W only, the MODE
flag, the current sync key, the earlier sync keys each under the current master, the key proof's hash, the last writer)
gets its WIRE: the lockstep artifact written (NOT deployed), the fake server speaking the new shape, the production
`VaultLeaf` replacing `UnreachableVaultLeaf` on the new road, the engine's sync-key custody reading
`KeychainSyncKeysLeaf` on the new road, and the two-client convergence suites proving sync setup, the join, the follow
into/out of Castle and the lagging device (rule 15). Tickets: VX-416 (the unit), VX-109 and VX-313's wire halves.

**Hard limits (every one binding):**
- `SyncEngine.lockstepVersion` (the client's marker) is UNTOUCHED — it stays 13. Her Release client keeps syncing; the
  bump rides VX-329's release (her ruling, §1). The ARTIFACT bumps the mirror's marker to 14 when it eventually runs.
- NO live network call lands anywhere in this unit's tests — the fake server only. The production leaf is wired on the
  NEW ROAD only (Debug; the dev store binds no account, so no act reaches it live).
- Today's road stays BYTE-UNCHANGED: `KeyVaultClient`'s existing methods, `KeyVaultFormat`, `CorpusRotation`'s
  call sites, today's `SyncCustodyRecord`/`DeviceKeySyncProvider` custody — Release behavior identical by construction
  (new files or new-road-gated lines only). The Release build check (`xcodebuild -configuration Release build`) runs
  before the record closes.
- Nothing from CastleRules' considered-and-not-pursued list: no rotation, no anchor, no re-seal of the account, no
  Apple wrap in the vault. The sync key changes ONLY at a Castle entry, in ONE CAS write.
- Keychain tests under throwaway scopes only (`KeychainTestTripwire`); no stage, no `xcodebuild test`, no Debug launch,
  no dev-store touch — headless `swift build`/`swift test` + `xcodebuild build-for-testing` only; the Mac suites are the
  orchestrator's to run under a stage claim after the record ends PENDING.
- VX-306's §8 environment traps bind verbatim (checkpoint commits per piece, push after each, LIVE STATUS flips in the
  same commit, PENDING on every unverified claim, foreground waits only, no subagents, `Part of VX-416` in messages).

**The pieces (suggested order; the fork may re-cut at a clean seam, recording why):**
1. **The SQL artifact `Server/supabase/17_phase_vx307_vault.sql`** (the 13y/13i-e shape: re-run guard keyed on marker 14
   / a new column; additive where it can be). ARRIVES: `mode text` (nullable) and `earlier_row_keys` (nullable —
   key-id → base64 wrap map, each under the CURRENT master). RETIRES-AS-UNREAD (left in place): `corpus_previous_key_id`,
   `corpus_previous_wrapped_by_master`, `rotation_started_seq`, `master_wrapped_by_apple_held`, `apple_key_id`.
   DROPPED: `sync_reencrypt` (the rotation's walk — rule 15's kept list replaces it). `key_vault_update` REDEFINED: the
   rotation arms go (`VARIORUM_ROTATION_IN_PROGRESS`, `rotation_started_seq` assignment, `VARIORUM_ROTATION_ROWS_REMAIN`);
   it stays the ONE CAS write under the challenge-verified proof (13y's protocol byte-unchanged, `key_proof_mac` arm for
   a new hash included). The journal-bridge columns' NOT NULL relaxes (the bridge is retired; a new vault mints no bridge
   key) — PROVISIONAL, record it. The mode backfill for pre-VX307 rows is decided by a PRE-WINDOW PROBE row in the
   checklist (today's posture encoding: the Apple-held wrap present ⇒ Standard), never guessed in the artifact silently —
   PROVISIONAL, record the chosen arm. Marker 13→14 at the artifact's end. The deploy checklist
   `notes/plans/vx307-deploy-checklist.md` (the 13i-e shape) with every live-only row PENDING-until-live and the
   choreography stated: the mirror runs ONLY in the VX-329 release window at her go; the client bump rides that release.
2. **The fake server** (`Tests/.../ScriptedVaultServer` / the two-client harness's vault): the new row shape, CAS order
   (proof before CAS — the pre-13x gate's order), `createVault` insert-with-proof, `updateVault` whole-row CAS, typed
   refusals matching `VaultRefusal`.
3. **The production vault leaf** — a core adapter (headless in both configurations, the `ProtectionLibraryFiles`
   precedent) translating `AccountVault` ↔ the wire row over the PostgREST/RPC transport patterns (`KeyVaultClient`'s
   auth posture: signed-out refuses before composing; one 401 refresh-retry; typed refusals; single-flight fetch), new
   methods/types ADDITIVE beside today's (today's road untouched). A row without `mode` (pre-VX307) answers a typed
   refusal, never a guess. `VaultRefusal` mapping total: conflict/proof/absent/exists/unreachable/notSignedIn.
   The app's compose site (`ProtectionSystem.live`) swaps `UnreachableVaultLeaf` → the real leaf on the new road.
4. **The sync keys' custody on the new road:** the engine's key provider reads `AccountKeys` from
   `KeychainSyncKeysLeaf`/session memory for the bound account on the new road (today's `SyncCustodyRecord` road retires
   THERE ONLY — P-VX306-K3's coexistence ends); `touchIDCandidates` wired from the record's bound account. Today's road
   byte-unchanged.
5. **The convergence suites** (two clients against the fake server, the engine's own harness): sync setup hands the pair
   up (rule 7); the join adopts the account's pair + `wordsReplacedByAccount`; the follow into Castle (one secret, the
   history grows, no quiet road survives); the quiet follow out (no secret, `followedOutOfCastle`); the lagging device
   catching up on a replaced sync key (rule 15 — a row sealed under an earlier key still reads); VX-109's pin — a
   concurrent Use Standard vs. Use Castle: the ONE-ROW CAS refuses the loser plainly (`revisionConflict`), nothing
   silent; VX-313's wire half — the acts run sealed plans on the production leaf shapes (a tampered plan/keychain value
   cannot steer custody; the core's seal checks pinned at the leaf seam).
6. **Riders if one-line in a touched suite only:** VX-380, VX-406.

**Evidence closing the unit:** the new suites green in BOTH configurations headless; the protection set green both
configurations; `xcodebuild build-for-testing` green (Mac) and the mobile target builds; the Release build check green;
the artifact + checklist committed with PENDING rows; the record's counts in §9-style form below (§6), every unverified
claim PENDING. The Mac batch is the orchestrator's under the stage.

## 6. RECORDS (each unit appends; the VX-306 §9 form)

### U1 RECORD — THE VAULT'S NEW SHAPE ON THE WIRE (the Fable fork, 2026-10-18; ticket VX-416)

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — the SQL artifact `Server/supabase/17_phase_vx307_vault.sql` + the deploy checklist
  `notes/plans/vx307-deploy-checklist.md` (PENDING-until-live rows; NOT deployed — her ruling, §1): NOT STARTED.
- Piece 2 — the fake server's new vault shape (CAS order, proof before CAS, typed refusals): NOT STARTED.
- Piece 3 — the production vault leaf (core adapter, additive beside today's client; swapped in at
  `ProtectionSystem.live` on the new road): NOT STARTED.
- Piece 4 — the engine's sync-key custody on the new road (`KeychainSyncKeysLeaf`; today's road byte-unchanged):
  NOT STARTED.
- Piece 5 — the two-client convergence suites (sync setup · join · follow in/out · lagging device · VX-109's CAS pin ·
  VX-313's sealed-plan wire half): NOT STARTED.
- Piece 6 — riders VX-380/VX-406 only if one-line in a touched suite: NOT STARTED.
- No revert is in flight.

## 7. LIVE STATUS
- 2026-10-18 ~18:45 — KICKED OFF. Preflight complete (the orchestrator): CastleRules + SyncSpec whole, the lifecycle
  stages, SurfaceContracts, VX-306 §8/§9 records + handoff, QUESTIONS #234 (ACCEPTED by this kickoff, her entry's own
  sentence — the status flip rides the closeout merge), the board, the core acts/VaultModel/Assessment/leaves, today's
  `key_vault` DDL + RPCs, `KeyVaultClient`. Her kickoff rulings in §5. The custody slot held; coordinator announced.
- U1 (VX-416): BRIEFED (§5a) — the Fable fork spawning next. NOT STARTED.
- U2 (VX-417): NOT STARTED — briefed after U1's record closes.
